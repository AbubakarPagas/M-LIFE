import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// M4 — Daily Hadith notification helper.
//
// Uses flutter_local_notifications ^21.0.0 which requires all named parameters.
// Schedules a repeating notification every 24 hours using periodicallyShowWithDuration.
// A curated pool of short hadiths is embedded so no JSON load is needed at
// notification time.

class HadithNotificationHelper {
  HadithNotificationHelper._();

  static const int _notificationId = 9001;
  static const String _channelId = 'daily_hadith';
  static const String _channelName = 'Daily Hadith';
  static const String _channelDesc = 'Delivers one Hadith reminder per day';

  static const List<_HadithEntry> _pool = [
    _HadithEntry(
      title: 'Daily Hadith',
      body: '"Actions are judged by intentions." — Bukhari #1',
    ),
    _HadithEntry(
      title: 'Daily Hadith',
      body:
          '"None of you truly believes until he loves for his brother what he loves for himself." — Bukhari #13',
    ),
    _HadithEntry(
      title: 'Daily Hadith',
      body:
          '"The best of you are those who learn the Quran and teach it." — Bukhari #5027',
    ),
    _HadithEntry(
      title: 'Daily Hadith',
      body: '"Make things easy, do not make them difficult." — Bukhari #69',
    ),
    _HadithEntry(
      title: 'Daily Hadith',
      body:
          '"He who does not show mercy will not be shown mercy." — Bukhari #6013',
    ),
    _HadithEntry(
      title: 'Daily Hadith',
      body: '"Remove harm from the road; that is charity." — Muslim #1009',
    ),
    _HadithEntry(
      title: 'Daily Hadith',
      body:
          '"Whoever believes in Allah and the Last Day, let him speak good or remain silent." — Bukhari #6475',
    ),
    _HadithEntry(
      title: 'Daily Hadith',
      body: '"Smiling at your brother is charity." — Tirmidhi #1956',
    ),
  ];

  static final _plugin = FlutterLocalNotificationsPlugin();

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Schedules (or reschedules) one daily notification.
  /// Safe to call multiple times — cancels the existing schedule first.
  static Future<void> scheduleDailyHadith({
    int hour = 7,
    int minute = 0,
  }) async {
    // Cancel any existing schedule for this id first
    await _plugin.cancel(id: _notificationId);

    final entry = _pool[math.Random().nextInt(_pool.length)];

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: 'ic_notify',
    );

    // v21 periodicallyShowWithDuration uses all named params
    await _plugin.periodicallyShowWithDuration(
      id: _notificationId,
      title: entry.title,
      body: entry.body,
      repeatDurationInterval: const Duration(hours: 24),
      notificationDetails: const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'daily_hadith',
    );

    log(
      'Daily Hadith notification scheduled (every 24 h)',
      name: 'HadithNotificationHelper',
    );
  }

  /// Cancels the daily hadith notification.
  static Future<void> cancelDailyHadith() async {
    await _plugin.cancel(id: _notificationId);
    log(
      'Daily Hadith notification cancelled',
      name: 'HadithNotificationHelper',
    );
  }
}

class _HadithEntry {
  final String title;
  final String body;
  const _HadithEntry({required this.title, required this.body});
}
