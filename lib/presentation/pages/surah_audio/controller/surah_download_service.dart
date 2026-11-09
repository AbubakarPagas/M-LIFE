part of '../surah_audio.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SurahDownloadService
//
// Extension on AudioCtrl that exposes cache-aware download management.
// Delegates storage to AudioCacheManager (singleton).
//
// The reactive [currentReciterIdObs] observable is updated whenever the user
// picks a new reader via SurahChangeSurahReader.  All UI components (cache
// button, offline badge, storage screen) should observe this value so they
// automatically refresh when the reader changes.
// ─────────────────────────────────────────────────────────────────────────────

/// Shared reactive reciter-ID observable.  Updated by [SurahDownloadService]
/// whenever the stored preference changes.
final RxString currentReciterIdObs = 'ar.alafasy'.obs;

extension SurahDownloadService on AudioCtrl {
  AudioCacheManager get _cacheManager => AudioCacheManager.instance;

  // ── Current reciter helpers ──────────────────────────────────────────────

  /// The reciter ID currently selected by the user (stored in GetStorage).
  /// Also syncs [currentReciterIdObs] so reactive widgets rebuild.
  String get _currentReciterId {
    final stored = state.box.read<String>(SURAH_AUDIO_PLAYER_SOUND);
    final id = stored ?? 'ar.alafasy';
    // Keep the observable in sync (no-op if unchanged).
    if (currentReciterIdObs.value != id) currentReciterIdObs.value = id;
    return id;
  }

  /// Human-readable reciter name stored by quran_library.
  String get currentReciterName {
    final stored = state.box.read<String>(SURAH_AUDIO_PLAYER_NAME);
    return stored ?? _currentReciterId;
  }

  /// Call this after the reader dialog closes so the observable is refreshed
  /// immediately (the getter is lazy).
  void refreshCurrentReciter() {
    final stored = state.box.read<String>(SURAH_AUDIO_PLAYER_SOUND);
    final id = stored ?? 'ar.alafasy';
    currentReciterIdObs.value = id;
  }

  // ── Cache checks ─────────────────────────────────────────────────────────

  /// Returns true if surah [surahNumber] is already downloaded for the current
  /// reciter.
  Future<bool> isSurahCached(int surahNumber) =>
      _cacheManager.isCached(surahNumber, _currentReciterId);

  /// Returns the local file path if cached, null otherwise.
  Future<String?> getCachedSurahPath(int surahNumber) =>
      _cacheManager.getCachedPath(surahNumber, _currentReciterId);

  // ── Download ─────────────────────────────────────────────────────────────

  /// Start downloading [surahNumber] for the current reciter.
  Future<DownloadTask> startSurahDownload(int surahNumber) {
    final id = _currentReciterId;
    final url = SurahUrlBuilder.buildUrl(surahNumber, id);
    return _cacheManager.downloadSurah(
      surahId: surahNumber,
      reciterId: id,
      url: url,
    );
  }

  /// Cancel the active download for [surahNumber].
  Future<void> cancelSurahDownload(int surahNumber) =>
      _cacheManager.cancelDownload(surahNumber, _currentReciterId);

  /// Delete a cached surah file + database record.
  Future<void> deleteCachedSurah(int surahNumber) =>
      _cacheManager.deleteCachedSurah(surahNumber, _currentReciterId);

  /// Retry a failed download.
  Future<DownloadTask> retryFailedDownload(int surahNumber) {
    final id = _currentReciterId;
    final url = SurahUrlBuilder.buildUrl(surahNumber, id);
    return _cacheManager.retryDownload(
      surahId: surahNumber,
      reciterId: id,
      url: url,
    );
  }

  /// Active download task for [surahNumber], if any.
  DownloadTask? activeDownloadTask(int surahNumber) =>
      _cacheManager.getActiveTask(surahNumber, _currentReciterId);

  // ── Playback with cache priority ─────────────────────────────────────────

  /// Play a surah using the local cache when available; falls back to
  /// streaming from the network via quran_library's selectSurahFromList.
  ///
  /// Also updates the media notification (lock screen, Bluetooth, Android Auto)
  /// via [QuranAudioHandler] automatically.
  Future<void> playSurahWithCache({
    required BuildContext context,
    required int surahNumber,
  }) async {
    // ── Attach the AudioPlayer to the handler on first playback ────────────
    // AudioCtrl (and its AudioPlayer) is now fully constructed.  attachPlayer
    // is idempotent — subsequent calls with the same player are no-ops.
    QuranAudioHandler.instance.attachPlayer(state.audioPlayer);

    final cachedPath = await getCachedSurahPath(surahNumber);
    if (cachedPath != null) {
      log(
        'Playing from local cache: $cachedPath',
        name: 'SurahDownloadService',
      );
      await state.audioPlayer.setFilePath(cachedPath);
      state.audioPlayer.play();
    } else {
      log(
        'No cache — streaming surah $surahNumber',
        name: 'SurahDownloadService',
      );
      if (context.mounted) {
        await playSurah(context: context, surahNumber: surahNumber);
      }
    }

    // ── Update media notification with current track ──────────────────────
    // Runs regardless of cache vs stream so the notification always reflects
    // what is actually playing.
    final surahList = QuranController.instance.state.surahs;
    if (surahNumber > 0 && surahNumber <= surahList.length) {
      await _SurahPlaybackNotifier.show(
        surahNumber: surahNumber,
        surahName: surahList[surahNumber - 1].arabicName,
        reciterName: currentReciterName,
      );
    }
  }

  // ── Storage info ─────────────────────────────────────────────────────────

  Future<List<AudioCacheEntry>> getDownloadedSurahs() =>
      _cacheManager.getDownloaded();

  Future<int> audioCacheSizeBytes() => _cacheManager.totalCacheSizeBytes();

  /// Stream of ALL downloaded entries (all reciters).
  Stream<List<AudioCacheEntry>> watchDownloadedSurahs() =>
      _cacheManager.watchDownloaded();

  /// Stream of downloaded entries for a specific reciter.
  Stream<List<AudioCacheEntry>> watchDownloadedSurahsForReciter(
    String reciterId,
  ) => _cacheManager.watchDownloadedForReciter(reciterId);

  /// All distinct reciter IDs that have completed downloads.
  Future<List<String>> getDownloadedReciterIds() =>
      _cacheManager.getDownloadedReciterIds();

  Future<void> clearAllAudioCache() => _cacheManager.clearAllCache();
}
