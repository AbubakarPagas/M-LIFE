import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'audio_cache_table.dart';

part 'audio_cache_database.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AudioCacheDatabase
//
// Separate Drift database dedicated to audio cache metadata.
// Kept separate from bookmark_database.db to avoid migration collisions.
// ─────────────────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [AudioCacheEntries])
class AudioCacheDatabase extends _$AudioCacheDatabase {
  AudioCacheDatabase._internal() : super(_openConnection());

  static final AudioCacheDatabase _instance = AudioCacheDatabase._internal();
  factory AudioCacheDatabase() => _instance;

  @override
  int get schemaVersion => 1;

  // ── CRUD ──────────────────────────────────────────────────────────────────

  /// Insert or replace a cache entry.
  Future<int> upsertEntry(AudioCacheEntriesCompanion entry) =>
      into(audioCacheEntries).insertOnConflictUpdate(entry);

  /// Convenience: insert/update with raw field values.
  Future<int> upsertEntryValues({
    int? id,
    required int surahId,
    required String reciterId,
    required String audioUrl,
    required String localFilePath,
    int fileSizeBytes = -1,
    required String downloadedAt,
    String status = 'downloading',
    int cacheVersion = 1,
  }) {
    return into(audioCacheEntries).insertOnConflictUpdate(
      AudioCacheEntriesCompanion(
        id: id != null ? Value(id) : const Value.absent(),
        surahId: Value(surahId),
        reciterId: Value(reciterId),
        audioUrl: Value(audioUrl),
        localFilePath: Value(localFilePath),
        fileSizeBytes: Value(fileSizeBytes),
        downloadedAt: Value(downloadedAt),
        status: Value(status),
        cacheVersion: Value(cacheVersion),
      ),
    );
  }

  /// Get entry by surahId + reciterId.
  Future<AudioCacheEntry?> getEntry(int surahId, String reciterId) =>
      (select(audioCacheEntries)
            ..where(
              (t) => t.surahId.equals(surahId) & t.reciterId.equals(reciterId),
            )
            ..limit(1))
          .getSingleOrNull();

  /// All completed entries (status == 'completed').
  Future<List<AudioCacheEntry>> getDownloadedEntries() => (select(
    audioCacheEntries,
  )..where((t) => t.status.equals('completed'))).get();

  /// All entries regardless of status.
  Future<List<AudioCacheEntry>> getAllEntries() =>
      select(audioCacheEntries).get();

  /// Delete a single entry by id.
  Future<int> deleteEntry(int id) =>
      (delete(audioCacheEntries)..where((t) => t.id.equals(id))).go();

  /// Delete entry by surahId + reciterId.
  Future<int> deleteEntryBySurah(int surahId, String reciterId) =>
      (delete(audioCacheEntries)..where(
            (t) => t.surahId.equals(surahId) & t.reciterId.equals(reciterId),
          ))
          .go();

  /// Update download status.
  Future<void> updateStatus(int id, String status) async {
    await (update(audioCacheEntries)..where((t) => t.id.equals(id))).write(
      AudioCacheEntriesCompanion(status: Value(status)),
    );
  }

  /// Wipe every entry (clear all cache metadata).
  Future<void> clearAll() => delete(audioCacheEntries).go();

  /// Sum of fileSizeBytes for completed entries.
  Future<int> totalCacheSizeBytes() async {
    final entries = await getDownloadedEntries();
    return entries.fold<int>(
      0,
      (sum, e) => sum + (e.fileSizeBytes > 0 ? e.fileSizeBytes : 0),
    );
  }

  /// Watch completed entries as a reactive stream.
  Stream<List<AudioCacheEntry>> watchDownloadedEntries() => (select(
    audioCacheEntries,
  )..where((t) => t.status.equals('completed'))).watch();

  /// Watch completed entries for a specific reciter.
  Stream<List<AudioCacheEntry>> watchDownloadedEntriesForReciter(
    String reciterId,
  ) =>
      (select(audioCacheEntries)
            ..where(
              (t) =>
                  t.status.equals('completed') & t.reciterId.equals(reciterId),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.surahId)]))
          .watch();

  /// Snapshot of completed entries for a specific reciter.
  Future<List<AudioCacheEntry>> getDownloadedEntriesForReciter(
    String reciterId,
  ) =>
      (select(audioCacheEntries)
            ..where(
              (t) =>
                  t.status.equals('completed') & t.reciterId.equals(reciterId),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.surahId)]))
          .get();

  /// All distinct reciter IDs that have at least one completed download.
  Future<List<String>> getDistinctReciterIds() async {
    final entries = await getDownloadedEntries();
    final seen = <String>{};
    final result = <String>[];
    for (final e in entries) {
      if (seen.add(e.reciterId)) result.add(e.reciterId);
    }
    return result;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'audio_cache.db'));
    return NativeDatabase(file);
  });
}
