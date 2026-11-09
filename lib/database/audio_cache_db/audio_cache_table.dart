import 'package:drift/drift.dart';

/// Drift table — stores metadata for every downloaded Surah audio file.
/// One row per (surahId + reciterId) pair.
class AudioCacheEntries extends Table {
  /// Auto-increment primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Surah number (1–114).
  IntColumn get surahId => integer()();

  /// Reciter identifier stored by quran_library (e.g. "ar.alafasy").
  TextColumn get reciterId => text()();

  /// Original remote URL used to fetch the audio.
  TextColumn get audioUrl => text()();

  /// Absolute path to the local MP3 file.
  TextColumn get localFilePath => text()();

  /// File size in bytes; -1 if unknown.
  IntColumn get fileSizeBytes => integer().withDefault(const Constant(-1))();

  /// ISO-8601 timestamp of when the download completed.
  TextColumn get downloadedAt => text()();

  /// One of: 'downloading' | 'completed' | 'failed' | 'paused'
  TextColumn get status => text().withDefault(const Constant('downloading'))();

  /// Incremented when the cached file should be invalidated.
  IntColumn get cacheVersion => integer().withDefault(const Constant(1))();
}
