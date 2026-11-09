import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../database/audio_cache_db/audio_cache_database.dart';
import 'surah_url_builder.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DownloadTask
// Holds mutable state for an active download so the UI can observe it.
// ─────────────────────────────────────────────────────────────────────────────

class DownloadTask {
  final int surahId;
  final String reciterId;
  final String url;

  /// 0.0 – 1.0
  final RxDouble progress = 0.0.obs;

  /// Received bytes
  final RxInt receivedBytes = 0.obs;

  /// Total bytes (-1 if unknown)
  final RxInt totalBytes = (-1).obs;

  /// 'downloading' | 'paused' | 'completed' | 'failed' | 'cancelled'
  final RxString status = 'downloading'.obs;

  CancelToken? _cancelToken;

  DownloadTask({
    required this.surahId,
    required this.reciterId,
    required this.url,
  });

  void cancel() => _cancelToken?.cancel('User cancelled');
}

// ─────────────────────────────────────────────────────────────────────────────
// AudioCacheManager — singleton service
// ─────────────────────────────────────────────────────────────────────────────

class AudioCacheManager {
  AudioCacheManager._();
  static final AudioCacheManager instance = AudioCacheManager._();

  final _db = AudioCacheDatabase();
  final _dio = Dio();

  /// Active download tasks keyed by "$surahId-$reciterId".
  final Map<String, DownloadTask> _activeTasks = {};

  // ── Directory helpers ─────────────────────────────────────────────────────

  /// Returns a reciter-specific sub-directory:
  ///   <appDocDir>/quran_audio_cache/<reciterId>/
  Future<Directory> _audioCacheDir({String? reciterId}) async {
    final base = await getApplicationDocumentsDirectory();
    final subPath = reciterId != null
        ? p.join(base.path, 'quran_audio_cache', _sanitize(reciterId))
        : p.join(base.path, 'quran_audio_cache');
    final dir = Directory(subPath);
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  /// Replaces any characters that are not safe for directory names.
  String _sanitize(String name) =>
      name.replaceAll(RegExp(r'[^a-zA-Z0-9_\-.]'), '_');

  String _taskKey(int surahId, String reciterId) => '$surahId-$reciterId';

  String _fileName(int surahId) {
    final surahNum = surahId.toString().padLeft(3, '0');
    return 'surah_$surahNum.mp3';
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns [true] if a completed cache file exists for this surah + reciter.
  Future<bool> isCached(int surahId, String reciterId) async {
    final entry = await _db.getEntry(surahId, reciterId);
    if (entry == null || entry.status != 'completed') return false;
    return File(entry.localFilePath).existsSync();
  }

  /// Returns the local file path if cached, otherwise null.
  Future<String?> getCachedPath(int surahId, String reciterId) async {
    final entry = await _db.getEntry(surahId, reciterId);
    if (entry == null || entry.status != 'completed') return null;
    final file = File(entry.localFilePath);
    if (!file.existsSync()) {
      await _db.deleteEntry(entry.id);
      return null;
    }
    return entry.localFilePath;
  }

  /// Returns the active [DownloadTask] for this surah, if any.
  DownloadTask? getActiveTask(int surahId, String reciterId) =>
      _activeTasks[_taskKey(surahId, reciterId)];

  /// Reactive stream of all completed entries.
  Stream<List<AudioCacheEntry>> watchDownloaded() =>
      _db.watchDownloadedEntries();

  /// Reactive stream of completed entries for a specific reciter.
  Stream<List<AudioCacheEntry>> watchDownloadedForReciter(String reciterId) =>
      _db.watchDownloadedEntriesForReciter(reciterId);

  /// All completed entries snapshot.
  Future<List<AudioCacheEntry>> getDownloaded() => _db.getDownloadedEntries();

  /// Completed entries snapshot for a specific reciter.
  Future<List<AudioCacheEntry>> getDownloadedForReciter(String reciterId) =>
      _db.getDownloadedEntriesForReciter(reciterId);

  /// All unique reciter IDs that have at least one completed download.
  Future<List<String>> getDownloadedReciterIds() => _db.getDistinctReciterIds();

  /// Total cache size in bytes.
  Future<int> totalCacheSizeBytes() => _db.totalCacheSizeBytes();

  // ── Download ──────────────────────────────────────────────────────────────

  /// Start downloading a surah.
  ///
  /// Returns immediately; observe [DownloadTask.progress] and [DownloadTask.status]
  /// for updates.
  Future<DownloadTask> downloadSurah({
    required int surahId,
    required String reciterId,
    required String url,
  }) async {
    final key = _taskKey(surahId, reciterId);

    // Return existing task if already downloading.
    if (_activeTasks.containsKey(key)) return _activeTasks[key]!;

    // Already cached → don't re-download.
    if (await isCached(surahId, reciterId)) {
      final dummyTask =
          DownloadTask(surahId: surahId, reciterId: reciterId, url: url)
            ..status.value = 'completed'
            ..progress.value = 1.0;
      return dummyTask;
    }

    final task = DownloadTask(surahId: surahId, reciterId: reciterId, url: url);
    _activeTasks[key] = task;
    task._cancelToken = CancelToken();

    // Upsert a 'downloading' record so we can track state across restarts.
    final dir = await _audioCacheDir(reciterId: reciterId);
    final filePath = p.join(dir.path, _fileName(surahId));
    await _db.upsertEntryValues(
      surahId: surahId,
      reciterId: reciterId,
      audioUrl: url,
      localFilePath: filePath,
      downloadedAt: DateTime.now().toIso8601String(),
      status: 'downloading',
    );

    _startDownload(task, filePath);
    return task;
  }

  void _startDownload(DownloadTask task, String filePath) {
    _dio
        .download(
          task.url,
          filePath,
          cancelToken: task._cancelToken,
          onReceiveProgress: (received, total) {
            task.receivedBytes.value = received;
            task.totalBytes.value = total;
            if (total > 0) {
              task.progress.value = received / total;
            }
          },
          options: Options(receiveTimeout: const Duration(minutes: 10)),
        )
        .then((_) async {
          task.status.value = 'completed';
          task.progress.value = 1.0;
          final fileSize = File(filePath).statSync().size;
          final entry = await _db.getEntry(task.surahId, task.reciterId);
          await _db.upsertEntryValues(
            id: entry?.id,
            surahId: task.surahId,
            reciterId: task.reciterId,
            audioUrl: task.url,
            localFilePath: filePath,
            fileSizeBytes: fileSize,
            downloadedAt: DateTime.now().toIso8601String(),
            status: 'completed',
          );
          _activeTasks.remove(_taskKey(task.surahId, task.reciterId));
          log(
            'Surah ${task.surahId} downloaded: $filePath',
            name: 'AudioCacheManager',
          );
        })
        .catchError((Object e) async {
          if (e is DioException && e.type == DioExceptionType.cancel) {
            task.status.value = 'cancelled';
            log(
              'Download cancelled: surah ${task.surahId}',
              name: 'AudioCacheManager',
            );
          } else {
            task.status.value = 'failed';
            log(
              'Download failed: surah ${task.surahId} — $e',
              name: 'AudioCacheManager',
            );
            final entry = await _db.getEntry(task.surahId, task.reciterId);
            if (entry != null) {
              await _db.updateStatus(entry.id, 'failed');
            }
          }
          _activeTasks.remove(_taskKey(task.surahId, task.reciterId));
        });
  }

  /// Cancel an active download.
  Future<void> cancelDownload(int surahId, String reciterId) async {
    final key = _taskKey(surahId, reciterId);
    final task = _activeTasks[key];
    if (task != null) {
      task.cancel();
      _activeTasks.remove(key);
    }
    await _db.deleteEntryBySurah(surahId, reciterId);
    final dir = await _audioCacheDir(reciterId: reciterId);
    final file = File(p.join(dir.path, _fileName(surahId)));
    if (file.existsSync()) await file.delete();
  }

  /// Delete a cached audio file and its DB record.
  Future<void> deleteCachedSurah(int surahId, String reciterId) async {
    final entry = await _db.getEntry(surahId, reciterId);
    if (entry != null) {
      final file = File(entry.localFilePath);
      if (file.existsSync()) await file.delete();
      await _db.deleteEntry(entry.id);
    }
    // Also cancel if still downloading.
    final key = _taskKey(surahId, reciterId);
    final task = _activeTasks[key];
    if (task != null) {
      task.cancel();
      _activeTasks.remove(key);
    }
    log(
      'Deleted cached surah $surahId ($reciterId)',
      name: 'AudioCacheManager',
    );
  }

  /// Delete ALL cached audio files and wipe the database.
  Future<void> clearAllCache() async {
    try {
      final dir = await _audioCacheDir();
      if (dir.existsSync()) {
        await dir.delete(recursive: true);
        await dir.create();
      }
    } catch (e) {
      log('Error clearing cache dir: $e', name: 'AudioCacheManager');
    }
    await _db.clearAll();
    for (final task in _activeTasks.values) {
      task.cancel();
    }
    _activeTasks.clear();
    log('All audio cache cleared', name: 'AudioCacheManager');
  }

  /// Retry a failed download.
  Future<DownloadTask> retryDownload({
    required int surahId,
    required String reciterId,
    required String url,
  }) async {
    await _db.deleteEntryBySurah(surahId, reciterId);
    return downloadSurah(surahId: surahId, reciterId: reciterId, url: url);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BulkDownloadNotifier
//
// Delegate callbacks wired up by the surah_audio barrel (which already
// imports flutter_local_notifications).  This lets ReciterDownloadManager
// trigger notifications without depending on the FLN package directly.
// ─────────────────────────────────────────────────────────────────────────────

class BulkDownloadNotifier {
  /// Called each time a surah finishes during a bulk download.
  static Future<void> Function({
    required int done,
    required int total,
    required String reciterName,
  })?
  onProgress;

  /// Called when the bulk download finishes or is cancelled.
  static Future<void> Function({
    required String reciterName,
    required bool cancelled,
  })?
  onComplete;

  static Future<void> _notifyProgress({
    required int done,
    required int total,
    required String reciterName,
  }) async {
    await onProgress?.call(done: done, total: total, reciterName: reciterName);
  }

  static Future<void> _notifyComplete({
    required String reciterName,
    required bool cancelled,
  }) async {
    await onComplete?.call(reciterName: reciterName, cancelled: cancelled);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ReciterDownloadManager
//
// Singleton that owns the bulk "download all 114 surahs" state per reciter.
// Survives navigation — both AudioSettingsScreen and AudioStorageScreen
// observe the same reactive progress/status maps.
// ─────────────────────────────────────────────────────────────────────────────

class ReciterDownloadManager {
  ReciterDownloadManager._();
  static final ReciterDownloadManager instance = ReciterDownloadManager._();

  /// progress 0.0–1.0 per reciterId currently bulk-downloading
  final RxMap<String, double> progress = <String, double>{}.obs;

  /// completed surah count per reciterId
  final RxMap<String, int> downloaded = <String, int>{}.obs;

  /// true while a bulk download is running for this reciterId
  bool isRunning(String reciterId) => progress.containsKey(reciterId);

  /// Starts (or resumes) bulk download for [reciterId].
  /// Safe to call again while already running — returns the same future.
  Future<void> startBulkDownload(
    String reciterId, {
    String reciterName = 'Reciter',
  }) async {
    if (isRunning(reciterId)) return;

    // Init reactive state with current DB count.
    progress[reciterId] = 0.0;
    final existingEntries = await AudioCacheManager.instance
        .getDownloadedForReciter(reciterId);
    downloaded[reciterId] = existingEntries.length;

    // Initial notification.
    await BulkDownloadNotifier._notifyProgress(
      done: existingEntries.length,
      total: 114,
      reciterName: reciterName,
    );

    const total = 114;

    for (int surahNum = 1; surahNum <= total; surahNum++) {
      if (!isRunning(reciterId)) {
        await BulkDownloadNotifier._notifyComplete(
          reciterName: reciterName,
          cancelled: true,
        );
        return;
      }

      final alreadyCached = await AudioCacheManager.instance.isCached(
        surahNum,
        reciterId,
      );

      if (!alreadyCached) {
        final url = SurahUrlBuilder.buildUrl(surahNum, reciterId);
        final task = await AudioCacheManager.instance.downloadSurah(
          surahId: surahNum,
          reciterId: reciterId,
          url: url,
        );

        // Wait only if the task hasn't already reached a terminal state.
        if (task.status.value == 'downloading') {
          await _waitForTask(task, reciterId);
        }
      }

      if (!isRunning(reciterId)) {
        await BulkDownloadNotifier._notifyComplete(
          reciterName: reciterName,
          cancelled: true,
        );
        return;
      }

      // Always read actual completed count from DB — avoids double-counting.
      final done = (await AudioCacheManager.instance.getDownloadedForReciter(
        reciterId,
      )).length;

      progress[reciterId] = surahNum / total;
      downloaded[reciterId] = done;

      await BulkDownloadNotifier._notifyProgress(
        done: done,
        total: total,
        reciterName: reciterName,
      );
    }

    // Final DB sync.
    final finalCount =
        (await AudioCacheManager.instance.getDownloadedForReciter(
          reciterId,
        )).length;
    downloaded[reciterId] = finalCount;
    progress.remove(reciterId);

    await BulkDownloadNotifier._notifyComplete(
      reciterName: reciterName,
      cancelled: false,
    );
  }

  /// Cancel a running bulk download for [reciterId].
  void cancelBulkDownload(String reciterId) {
    progress.remove(reciterId);
    BulkDownloadNotifier._notifyComplete(
      reciterName: reciterId,
      cancelled: true,
    );
  }

  Future<void> _waitForTask(DownloadTask task, String reciterId) {
    // If the task already reached a terminal state before we subscribed, done.
    final current = task.status.value;
    if (current == 'completed' ||
        current == 'failed' ||
        current == 'cancelled') {
      return Future.value();
    }

    final completer = Completer<void>();

    void resolve() {
      if (!completer.isCompleted) completer.complete();
    }

    // Subscribe — fires for each future status change.
    final worker = ever(task.status, (String s) {
      if (s == 'completed' || s == 'failed' || s == 'cancelled') resolve();
    });

    // Safety timeout — frees the completer if the status never fires.
    Future.delayed(const Duration(minutes: 5), resolve);

    return completer.future.then((_) => worker.dispose());
  }
}
