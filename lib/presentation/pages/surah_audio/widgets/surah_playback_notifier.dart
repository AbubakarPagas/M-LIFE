part of '../surah_audio.dart';

// ─────────────────────────────────────────────────────────────────────────────
// _SurahPlaybackNotifier
//
// Thin facade over QuranAudioHandler.  Call show() whenever a new surah
// starts playing; the handler updates the media notification (title, artist,
// seek bar) and keeps lock-screen / Bluetooth / Android-Auto controls in sync.
//
// cancel() stops the player and dismisses the notification cleanly.
// ─────────────────────────────────────────────────────────────────────────────

class _SurahPlaybackNotifier {
  _SurahPlaybackNotifier._();

  /// Update (or create) the media notification for the given surah.
  ///
  /// Must be called every time a new surah begins playing.
  static Future<void> show({
    required int surahNumber,
    required String surahName,
    String? reciterName,
  }) async {
    try {
      final handler = QuranAudioHandler.instance;
      final reciter = reciterName ?? AudioCtrl.instance.currentReciterName;

      await handler.updateTrack(
        surahNumber: surahNumber,
        surahArabicName: surahName,
        reciterName: reciter,
      );
    } catch (e) {
      // Handler may not be ready on very first launch; log and continue.
      log('QuranAudioHandler not ready: $e', name: '_SurahPlaybackNotifier');
    }
  }

  /// Stop playback and dismiss the media notification.
  static Future<void> cancel() async {
    try {
      await QuranAudioHandler.instance.stop();
    } catch (_) {
      // Ignore if handler not initialised yet.
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BulkFlnNotifier
//
// Separate flutter_local_notifications implementation for bulk download
// progress.  This is intentionally kept as a plain notification (not a media
// session) because it tracks file downloads, not audio playback.
// Registered as BulkDownloadNotifier callbacks at app start (AudioScreen).
// ─────────────────────────────────────────────────────────────────────────────

class _BulkFlnNotifier {
  static const _kChannelId = 'quran_bulk_download';
  static const _kChannelName = 'Quran Download';
  static const _kNotifId = 901;

  static final _fln = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> _ensureInit() async {
    if (_initialized) return;
    await _fln.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notify'),
      ),
    );
    _initialized = true;
  }

  static Future<void> onProgress({
    required int done,
    required int total,
    required String reciterName,
  }) async {
    await _ensureInit();
    final pct = total > 0 ? ((done / total) * 100).toInt() : 0;

    final details = AndroidNotificationDetails(
      _kChannelId,
      _kChannelName,
      channelDescription: 'Quran audio bulk download',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      playSound: false,
      enableVibration: false,
      icon: 'ic_notify',
      showProgress: true,
      maxProgress: total,
      progress: done,
      indeterminate: done == 0,
      visibility: NotificationVisibility.public,
      styleInformation: BigTextStyleInformation(
        '$done / $total surahs  •  $pct%',
        contentTitle: '⬇️ Downloading  $reciterName',
        summaryText: 'القرآن الكريم',
      ),
    );

    await _fln.show(
      id: _kNotifId,
      title: '⬇️ $reciterName',
      body: '$done / $total surahs ($pct%)',
      notificationDetails: NotificationDetails(android: details),
    );
  }

  static Future<void> onComplete({
    required String reciterName,
    required bool cancelled,
  }) async {
    await _ensureInit();

    if (cancelled) {
      await _fln.cancel(id: _kNotifId);
      return;
    }

    const details = AndroidNotificationDetails(
      _kChannelId,
      _kChannelName,
      channelDescription: 'Quran audio bulk download',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ongoing: false,
      autoCancel: true,
      playSound: false,
      enableVibration: false,
      icon: 'ic_notify',
    );

    await _fln.show(
      id: _kNotifId,
      title: '✅ اكتمل التنزيل',
      body: '$reciterName — 114 سورة تم تحميلها',
      notificationDetails: const NotificationDetails(android: details),
    );
  }

  /// Wire BulkDownloadNotifier callbacks.  Call once at app start.
  static void register() {
    BulkDownloadNotifier.onProgress = onProgress;
    BulkDownloadNotifier.onComplete = onComplete;
  }
}
