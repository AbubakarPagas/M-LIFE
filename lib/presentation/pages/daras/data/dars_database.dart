// ─────────────────────────────────────────────────────────────────────────────
// dars_database.dart — SQLite persistence for the Dars feature
// Uses sqflite directly (no code generation required).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DarsDatabase {
  // ── Singleton ─────────────────────────────────────────────────────────────
  DarsDatabase._();
  static final DarsDatabase _instance = DarsDatabase._();
  factory DarsDatabase() => _instance;

  Database? _db;

  Future<Database> get _database async {
    _db ??= await _open();
    return _db!;
  }

  // ── Open / migrate ────────────────────────────────────────────────────────

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'dars_feature.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE dars_bookmarks (
        id TEXT PRIMARY KEY,
        dars_id TEXT NOT NULL,
        dars_title TEXT NOT NULL,
        scholar_name TEXT NOT NULL,
        thumbnail_url TEXT,
        dars_type TEXT NOT NULL,
        saved_at_ms INTEGER NOT NULL,
        saved_position_secs INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE dars_history (
        dars_id TEXT PRIMARY KEY,
        dars_title TEXT NOT NULL,
        scholar_name TEXT NOT NULL,
        thumbnail_url TEXT,
        dars_type TEXT NOT NULL,
        last_position_secs INTEGER NOT NULL DEFAULT 0,
        watched_at_ms INTEGER NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE dars_progress (
        dars_id TEXT PRIMARY KEY,
        position_secs INTEGER NOT NULL DEFAULT 0,
        total_duration_secs INTEGER NOT NULL DEFAULT 0,
        is_completed INTEGER NOT NULL DEFAULT 0,
        last_watched_ms INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE dars_downloads (
        id TEXT PRIMARY KEY,
        dars_id TEXT NOT NULL,
        dars_title TEXT NOT NULL,
        scholar_name TEXT NOT NULL,
        thumbnail_url TEXT,
        dars_type TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'notDownloaded',
        progress REAL NOT NULL DEFAULT 0.0,
        local_path TEXT,
        file_size_bytes INTEGER NOT NULL DEFAULT 0,
        downloaded_at_ms INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE dars_playlists (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        created_at_ms INTEGER NOT NULL,
        updated_at_ms INTEGER NOT NULL,
        cover_thumbnail_url TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE dars_playlist_items (
        playlist_id TEXT NOT NULL,
        dars_id TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        dars_title TEXT NOT NULL,
        scholar_name TEXT NOT NULL,
        thumbnail_url TEXT,
        dars_type TEXT NOT NULL,
        duration_secs INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (playlist_id, dars_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE dars_live_reminders (
        live_id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        scheduled_at_ms INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE dars_questions (
        id TEXT PRIMARY KEY,
        dars_id TEXT NOT NULL,
        question_text TEXT NOT NULL,
        asked_at_ms INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');
    await db.execute('''
      CREATE TABLE followed_scholars (
        scholar_id TEXT PRIMARY KEY,
        scholar_name TEXT NOT NULL,
        arabic_name TEXT NOT NULL,
        photo_url TEXT,
        followed_at_ms INTEGER NOT NULL
      )
    ''');
  }

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllBookmarks() async {
    final db = await _database;
    return db.query('dars_bookmarks', orderBy: 'saved_at_ms DESC');
  }

  Future<bool> isBookmarked(String darsId) async {
    final db = await _database;
    final rows = await db.query(
      'dars_bookmarks',
      where: 'dars_id = ?',
      whereArgs: [darsId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> insertBookmark(Map<String, dynamic> row) async {
    final db = await _database;
    await db.insert(
      'dars_bookmarks',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBookmark(String darsId) async {
    final db = await _database;
    await db.delete(
      'dars_bookmarks',
      where: 'dars_id = ?',
      whereArgs: [darsId],
    );
  }

  // ── History ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getHistory({int limit = 50}) async {
    final db = await _database;
    return db.query(
      'dars_history',
      orderBy: 'watched_at_ms DESC',
      limit: limit,
    );
  }

  Future<void> upsertHistory(Map<String, dynamic> row) async {
    final db = await _database;
    await db.insert(
      'dars_history',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearHistory() async {
    final db = await _database;
    await db.delete('dars_history');
  }

  Future<void> deleteHistoryEntry(String darsId) async {
    final db = await _database;
    await db.delete('dars_history', where: 'dars_id = ?', whereArgs: [darsId]);
  }

  // ── Progress ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllProgress() async {
    final db = await _database;
    return db.query('dars_progress');
  }

  Future<void> upsertProgress(Map<String, dynamic> row) async {
    final db = await _database;
    await db.insert(
      'dars_progress',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── Downloads ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllDownloads() async {
    final db = await _database;
    return db.query('dars_downloads', orderBy: 'downloaded_at_ms DESC');
  }

  Future<void> upsertDownload(Map<String, dynamic> row) async {
    final db = await _database;
    await db.insert(
      'dars_downloads',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteDownload(String id) async {
    final db = await _database;
    await db.delete('dars_downloads', where: 'id = ?', whereArgs: [id]);
  }

  // ── Playlists ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllPlaylists() async {
    final db = await _database;
    return db.query('dars_playlists', orderBy: 'updated_at_ms DESC');
  }

  Future<void> insertPlaylist(Map<String, dynamic> row) async {
    final db = await _database;
    await db.insert(
      'dars_playlists',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deletePlaylist(String id) async {
    final db = await _database;
    await db.delete('dars_playlists', where: 'id = ?', whereArgs: [id]);
    await db.delete(
      'dars_playlist_items',
      where: 'playlist_id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getPlaylistItems(String playlistId) async {
    final db = await _database;
    return db.query(
      'dars_playlist_items',
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
      orderBy: 'sort_order ASC',
    );
  }

  Future<void> addToPlaylist(Map<String, dynamic> row) async {
    final db = await _database;
    await db.insert(
      'dars_playlist_items',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFromPlaylist(String playlistId, String darsId) async {
    final db = await _database;
    await db.delete(
      'dars_playlist_items',
      where: 'playlist_id = ? AND dars_id = ?',
      whereArgs: [playlistId, darsId],
    );
  }

  // ── Live Reminders ────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getLiveReminders() async {
    final db = await _database;
    return db.query('dars_live_reminders');
  }

  Future<bool> hasLiveReminder(String liveId) async {
    final db = await _database;
    final rows = await db.query(
      'dars_live_reminders',
      where: 'live_id = ?',
      whereArgs: [liveId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> setLiveReminder(Map<String, dynamic> row) async {
    final db = await _database;
    await db.insert(
      'dars_live_reminders',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeLiveReminder(String liveId) async {
    final db = await _database;
    await db.delete(
      'dars_live_reminders',
      where: 'live_id = ?',
      whereArgs: [liveId],
    );
  }

  // ── Questions ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getQuestionsForDars(String darsId) async {
    final db = await _database;
    return db.query(
      'dars_questions',
      where: 'dars_id = ?',
      whereArgs: [darsId],
    );
  }

  Future<void> insertQuestion(Map<String, dynamic> row) async {
    final db = await _database;
    await db.insert(
      'dars_questions',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── Followed Scholars ─────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getFollowedScholars() async {
    final db = await _database;
    return db.query('followed_scholars');
  }

  Future<bool> isFollowing(String scholarId) async {
    final db = await _database;
    final rows = await db.query(
      'followed_scholars',
      where: 'scholar_id = ?',
      whereArgs: [scholarId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> followScholar(Map<String, dynamic> row) async {
    final db = await _database;
    await db.insert(
      'followed_scholars',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> unfollowScholar(String scholarId) async {
    final db = await _database;
    await db.delete(
      'followed_scholars',
      where: 'scholar_id = ?',
      whereArgs: [scholarId],
    );
  }
}
