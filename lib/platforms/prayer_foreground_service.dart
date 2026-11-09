// ignore_for_file: avoid_print

import 'dart:io' show Platform;

import 'package:adhan/adhan.dart' as adhan_lib;
// Hide NotificationVisibility from flutter_foreground_task to avoid the name
// clash with flutter_local_notifications.
import 'package:flutter_foreground_task/flutter_foreground_task.dart'
    hide NotificationVisibility;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:misbah_path/helpers/adhan_dependencies.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

/// Service ID for flutter_foreground_task (keeps the Dart isolate alive).
const _kServiceId = 1001;

/// Notification ID for the rich prayer-status card.
/// Must NOT clash with adhan alert IDs in notifiers.dart (0 – 5).
const _kPrayerStatusNotifId = 900;

/// Channel used for the persistent prayer-status card.
const _kStatusChannelId = 'prayer_status_channel';
const _kStatusChannelName = 'Prayer Status';

// ─────────────────────────────────────────────────────────────────────────────
// Shared FlutterLocalNotificationsPlugin instance (for this isolate)
// ─────────────────────────────────────────────────────────────────────────────

final _fln = FlutterLocalNotificationsPlugin();
bool _flnInitialised = false;

Future<void> _ensureFln() async {
  if (_flnInitialised) return;
  await _fln.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('ic_notify'),
    ),
  );
  _flnInitialised = true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

class _PrayerRow {
  final String name;
  final DateTime time;
  final bool isPast;
  final bool isActive;

  const _PrayerRow({
    required this.name,
    required this.time,
    required this.isPast,
    required this.isActive,
  });

  /// "06:14 PM"
  String get clockTime {
    final h = time.hour;
    final m = time.minute;
    final amPm = h < 12 ? 'AM' : 'PM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $amPm';
  }
}

class _PrayerSnapshot {
  final String currentPrayerName;
  final String nextPrayerName;
  final String nextPrayerClock;
  final Duration remainingToNext;
  final bool isInPrayer;
  final List<_PrayerRow> schedule;

  const _PrayerSnapshot({
    required this.currentPrayerName,
    required this.nextPrayerName,
    required this.nextPrayerClock,
    required this.remainingToNext,
    required this.isInPrayer,
    required this.schedule,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

String _labelOf(adhan_lib.Prayer p) {
  switch (p) {
    case adhan_lib.Prayer.fajr:
      return 'Fajr';
    case adhan_lib.Prayer.sunrise:
      return 'Sunrise';
    case adhan_lib.Prayer.dhuhr:
      return 'Dhuhr';
    case adhan_lib.Prayer.asr:
      return 'Asr';
    case adhan_lib.Prayer.maghrib:
      return 'Maghrib';
    case adhan_lib.Prayer.isha:
      return 'Isha';
    case adhan_lib.Prayer.none:
      return 'Fajr'; // before fajr → next is fajr
  }
}

String _clockOf(DateTime dt) {
  final h = dt.hour;
  final m = dt.minute;
  final amPm = h < 12 ? 'AM' : 'PM';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $amPm';
}

/// "01:23:45"
String _fmtDuration(Duration d) {
  final h = d.inHours.toString().padLeft(2, '0');
  final m = (d.inMinutes % 60).toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}

// ─────────────────────────────────────────────────────────────────────────────
// Compute today's prayer snapshot from SharedPreferences + adhan library
// ─────────────────────────────────────────────────────────────────────────────

Future<_PrayerSnapshot?> _computeSnapshot() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    // Honour the user's persistent-notification toggle.
    // Key matches sharedPrefAdhanShowPersistentNotify ('show_persistent_notify').
    final showPersistent = prefs.getBool('show_persistent_notify') ?? true;
    if (!showPersistent) return null;

    final lat = prefs.getDouble('loc_lat');
    final lng = prefs.getDouble('loc_long');
    if (lat == null || lng == null) return null;

    final calcIndex = prefs.getInt('calc') ?? 0;
    final madhabIndex = prefs.getInt('madhab') ?? 0;
    final highLatIndex = prefs.getInt('hLat') ?? 0;

    final coords = adhan_lib.Coordinates(lat, lng);
    final params = adhanCalculationMethods[calcIndex].getParameters();
    params.madhab = madhabs[madhabIndex];
    params.highLatitudeRule = highLatRules[highLatIndex];

    final now = DateTime.now();
    final pt = adhan_lib.PrayerTimes(
      coords,
      adhan_lib.DateComponents.from(now),
      params,
    );

    final currentPrayer = pt.currentPrayer();
    final nextPrayer = pt.nextPrayer();

    // Resolve the exact DateTime when next prayer begins
    DateTime nextStart;
    switch (nextPrayer) {
      case adhan_lib.Prayer.fajr:
        // After Isha the next Fajr is tomorrow
        final tomorrowPT = adhan_lib.PrayerTimes(
          coords,
          adhan_lib.DateComponents.from(now.add(const Duration(days: 1))),
          params,
        );
        nextStart = tomorrowPT.fajr;
        break;
      case adhan_lib.Prayer.sunrise:
        nextStart = pt.sunrise;
        break;
      case adhan_lib.Prayer.dhuhr:
        nextStart = pt.dhuhr;
        break;
      case adhan_lib.Prayer.asr:
        nextStart = pt.asr;
        break;
      case adhan_lib.Prayer.maghrib:
        nextStart = pt.maghrib;
        break;
      case adhan_lib.Prayer.isha:
        nextStart = pt.isha;
        break;
      case adhan_lib.Prayer.none:
        nextStart = pt.fajr;
        break;
    }

    final remaining = nextStart.difference(now);
    final isInPrayer = currentPrayer != adhan_lib.Prayer.none;
    final currentLabel = _labelOf(currentPrayer);

    final schedule = <_PrayerRow>[
      _PrayerRow(
        name: 'Fajr',
        time: pt.fajr,
        isPast: pt.fajr.isBefore(now),
        isActive: currentLabel == 'Fajr' && isInPrayer,
      ),
      _PrayerRow(
        name: 'Sunrise',
        time: pt.sunrise,
        isPast: pt.sunrise.isBefore(now),
        isActive: currentLabel == 'Sunrise' && isInPrayer,
      ),
      _PrayerRow(
        name: 'Dhuhr',
        time: pt.dhuhr,
        isPast: pt.dhuhr.isBefore(now),
        isActive: currentLabel == 'Dhuhr' && isInPrayer,
      ),
      _PrayerRow(
        name: 'Asr',
        time: pt.asr,
        isPast: pt.asr.isBefore(now),
        isActive: currentLabel == 'Asr' && isInPrayer,
      ),
      _PrayerRow(
        name: 'Maghrib',
        time: pt.maghrib,
        isPast: pt.maghrib.isBefore(now),
        isActive: currentLabel == 'Maghrib' && isInPrayer,
      ),
      _PrayerRow(
        name: 'Isha',
        time: pt.isha,
        isPast: pt.isha.isBefore(now),
        isActive: currentLabel == 'Isha' && isInPrayer,
      ),
    ];

    return _PrayerSnapshot(
      currentPrayerName: currentLabel,
      nextPrayerName: _labelOf(nextPrayer),
      nextPrayerClock: _clockOf(nextStart),
      remainingToNext: remaining.isNegative ? Duration.zero : remaining,
      isInPrayer: isInPrayer,
      schedule: schedule,
    );
  } catch (e) {
    print('[PrayerFgService] snapshot error: $e');
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rich InboxStyle notification
//
// Collapsed:
//   🕌  Asr – Current Prayer
//       Next: Maghrib at 06:14 PM  •  01:23:45 remaining
//
// Expanded (InboxStyle lines):
//   ✅  Fajr        05:23 AM
//   ✅  Sunrise     06:47 AM
//   ✅  Dhuhr       12:11 PM
//   ▶   Asr         03:51 PM  ← active
//       Maghrib     06:14 PM
//       Isha        07:42 PM
//   ─────────────────────────
//              Today's Prayer Schedule
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _postRichNotification(_PrayerSnapshot snap) async {
  final countdown = _fmtDuration(snap.remainingToNext);

  final String title;
  final String body;

  if (snap.isInPrayer) {
    title = '🕌 ${snap.currentPrayerName} – Current Prayer';
    body =
        'Next: ${snap.nextPrayerName} at ${snap.nextPrayerClock}  •  $countdown remaining';
  } else {
    title = '🕌 Next: ${snap.nextPrayerName}';
    body = 'Starts at ${snap.nextPrayerClock}  •  in $countdown';
  }

  // Build the expanded InboxStyle rows
  final lines = snap.schedule.map((row) {
    final marker = row.isActive ? '▶ ' : (row.isPast ? '✅' : '   ');
    return '$marker  ${row.name.padRight(9)}  ${row.clockTime}';
  }).toList();

  final androidDetails = AndroidNotificationDetails(
    _kStatusChannelId,
    _kStatusChannelName,
    channelDescription: 'Live Islamic prayer time status',
    importance: Importance.low,
    priority: Priority.low,
    ongoing: true, // cannot be swiped away
    autoCancel: false,
    onlyAlertOnce: true, // no sound/vibration on update
    playSound: false,
    enableVibration: false,
    icon: 'ic_notify',
    visibility: NotificationVisibility.public,
    styleInformation: InboxStyleInformation(
      lines,
      contentTitle: title,
      summaryText: "Today's Prayer Schedule",
    ),
  );

  await _fln.show(
    id: _kPrayerStatusNotifId,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(android: androidDetails),
  );
}

Future<void> _postNoLocationNotification() async {
  const androidDetails = AndroidNotificationDetails(
    _kStatusChannelId,
    _kStatusChannelName,
    channelDescription: 'Live Islamic prayer time status',
    importance: Importance.low,
    priority: Priority.low,
    ongoing: true,
    autoCancel: false,
    onlyAlertOnce: true,
    playSound: false,
    enableVibration: false,
    icon: 'ic_notify',
    visibility: NotificationVisibility.public,
  );

  await _fln.show(
    id: _kPrayerStatusNotifId,
    title: '🕌 Prayer Times',
    body: 'Enable location permission to see prayer times',
    notificationDetails: const NotificationDetails(android: androidDetails),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TaskHandler — runs inside the flutter_foreground_task isolate
// Fires onRepeatEvent every 1 second → live countdown update
// ─────────────────────────────────────────────────────────────────────────────

@pragma('vm:entry-point')
class PrayerTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await _ensureFln();
    await _tick();
  }

  /// Called every second by the ForegroundTaskEventAction.repeat(1000).
  @override
  void onRepeatEvent(DateTime timestamp) {
    _tick();
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _ensureFln();
    await _fln.cancel(id: _kPrayerStatusNotifId);
  }

  @override
  void onReceiveData(Object data) {}

  Future<void> _tick() async {
    await _ensureFln();
    final snap = await _computeSnapshot();

    if (snap == null) {
      await _postNoLocationNotification();
      FlutterForegroundTask.updateService(
        notificationTitle: '🕌 Prayer Times',
        notificationText: 'Enable location to see prayer times',
      );
    } else {
      await _postRichNotification(snap);
      // Keep the flutter_foreground_task keep-alive shell minimal
      FlutterForegroundTask.updateService(
        notificationTitle: snap.isInPrayer
            ? '🕌 ${snap.currentPrayerName}'
            : '🕌 Next: ${snap.nextPrayerName}',
        notificationText: _fmtDuration(snap.remainingToNext),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry-point callback (must be top-level, annotated vm:entry-point)
// ─────────────────────────────────────────────────────────────────────────────

@pragma('vm:entry-point')
void prayerServiceCallback() {
  FlutterForegroundTask.setTaskHandler(PrayerTaskHandler());
}

// ─────────────────────────────────────────────────────────────────────────────
// Public API  — called from the main Flutter isolate
// ─────────────────────────────────────────────────────────────────────────────

/// Call once, before [startPrayerForegroundService], ideally in main().
void initPrayerForegroundTask() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'prayer_service_keepalive',
      channelName: 'Prayer Service',
      channelDescription: 'Keeps the prayer countdown running in background.',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      onlyAlertOnce: true,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      // Fire every 1 second → live countdown
      eventAction: ForegroundTaskEventAction.repeat(1000),
      autoRunOnBoot: true,
      autoRunOnMyPackageReplaced: true,
      allowWakeLock: false,
      allowWifiLock: false,
    ),
  );
}

/// Starts (or restarts) the foreground service.  Android only.
/// Does nothing if the user has not enabled the persistent notification.
Future<ServiceRequestResult> startPrayerForegroundService() async {
  if (!Platform.isAndroid) {
    return ServiceRequestFailure(
      error: Exception('Foreground service is Android-only'),
    );
  }

  // Check the user's persistent-notification preference before starting.
  final prefs = await SharedPreferences.getInstance();
  final showPersistent = prefs.getBool('show_persistent_notify') ?? true;
  if (!showPersistent) {
    // Preference is off — stop any running instance and bail out.
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.stopService();
    }
    return ServiceRequestFailure(
      error: Exception('Persistent notification is disabled by user'),
    );
  }

  // Ask for notification permission (Android 13+).
  // We request it and proceed regardless — if denied the notification just
  // won't appear, but we don't block the rest of app startup.
  // Wrap in try/catch: if called before the Activity is attached to the
  // FlutterEngine (e.g. during early app init), the platform channel throws
  // ActivityNotAttachedException. We can safely ignore it — the permission
  // dialog will appear on the next launch once the Activity is ready.
  try {
    await FlutterForegroundTask.requestNotificationPermission();
  } catch (_) {}

  if (await FlutterForegroundTask.isRunningService) {
    return FlutterForegroundTask.restartService();
  }

  return FlutterForegroundTask.startService(
    serviceId: _kServiceId,
    notificationTitle: '🕌 Prayer Times',
    notificationText: 'Starting…',
    callback: prayerServiceCallback,
  );
}

/// Stops the service and cancels the status-bar card.
Future<ServiceRequestResult> stopPrayerForegroundService() async {
  await _ensureFln();
  await _fln.cancel(id: _kPrayerStatusNotifId);
  return FlutterForegroundTask.stopService();
}
