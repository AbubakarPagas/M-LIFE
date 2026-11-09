import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/notification_item.dart';
import '../models/prayer_record.dart';

/// SQLite datasource for prayer tracking + notification history.
/// Uses sqflite (already a project dependency) – no new packages needed.
class PrayerTrackingDb {
  PrayerTrackingDb._();
  static final PrayerTrackingDb instance = PrayerTrackingDb._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Init
  // ─────────────────────────────────────────────────────────────────────────

  Future<Database> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'prayer_tracking.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Prayer records table
    await db.execute('''
      CREATE TABLE prayer_records (
        date           TEXT    PRIMARY KEY,
        fajr           TEXT    NOT NULL DEFAULT 'pending',
        dhuhr          TEXT    NOT NULL DEFAULT 'pending',
        asr            TEXT    NOT NULL DEFAULT 'pending',
        maghrib        TEXT    NOT NULL DEFAULT 'pending',
        isha           TEXT    NOT NULL DEFAULT 'pending',
        fajrTs         TEXT,
        dhuhrTs        TEXT,
        asrTs          TEXT,
        maghribTs      TEXT,
        ishaTs         TEXT
      )
    ''');

    // Notification history table
    await db.execute('''
      CREATE TABLE notifications (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        title       TEXT    NOT NULL,
        body        TEXT    NOT NULL DEFAULT '',
        category    TEXT    NOT NULL DEFAULT 'prayerTime',
        receivedAt  TEXT    NOT NULL,
        isRead      INTEGER NOT NULL DEFAULT 0,
        isArchived  INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Index for quick date-range queries
    await db.execute('CREATE INDEX idx_pr_date ON prayer_records(date)');
    await db.execute(
      'CREATE INDEX idx_notif_received ON notifications(receivedAt)',
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Prayer records
  // ─────────────────────────────────────────────────────────────────────────

  Future<PrayerRecord?> getRecord(String date) async {
    final db = await database;
    final rows = await db.query(
      'prayer_records',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (rows.isEmpty) return null;
    return _rowToRecord(rows.first);
  }

  Future<List<PrayerRecord>> getRecordsForRange(
    DateTime from,
    DateTime to,
  ) async {
    final db = await database;
    final rows = await db.query(
      'prayer_records',
      where: 'date >= ? AND date <= ?',
      whereArgs: [PrayerRecord.dateKey(from), PrayerRecord.dateKey(to)],
      orderBy: 'date ASC',
    );
    return rows.map(_rowToRecord).toList();
  }

  Future<List<PrayerRecord>> getMonthRecords(int year, int month) async {
    final from = DateTime(year, month, 1);
    final to = DateTime(year, month + 1, 0); // last day of month
    return getRecordsForRange(from, to);
  }

  Future<void> upsertRecord(PrayerRecord record) async {
    final db = await database;
    await db.insert(
      'prayer_records',
      _recordToRow(record),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePrayerStatus({
    required String date,
    required int prayerIndex, // 0=Fajr … 4=Isha
    required PrayerStatus status,
  }) async {
    final existing = await getRecord(date) ?? PrayerRecord(date: date);
    final now = DateTime.now().toIso8601String();

    final updated = switch (prayerIndex) {
      0 => existing.copyWith(fajr: status, fajrTimestamp: now),
      1 => existing.copyWith(dhuhr: status, dhuhrTimestamp: now),
      2 => existing.copyWith(asr: status, asrTimestamp: now),
      3 => existing.copyWith(maghrib: status, maghribTimestamp: now),
      4 => existing.copyWith(isha: status, ishaTimestamp: now),
      _ => existing,
    };
    await upsertRecord(updated);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Analytics helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns current active streak (consecutive days with ≥ 1 completed prayer)
  Future<int> getPrayerStreak() async {
    final db = await database;
    final rows = await db.query(
      'prayer_records',
      orderBy: 'date DESC',
      limit: 365,
    );
    if (rows.isEmpty) return 0;

    int streak = 0;
    DateTime cursor = DateTime.now();

    for (final row in rows) {
      final rec = _rowToRecord(row);
      final recDate = DateTime.parse(rec.date);
      final diff = cursor.difference(recDate).inDays.abs();

      if (diff > 1) break; // gap in streak
      if (rec.completedCount > 0) {
        streak++;
        cursor = recDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  /// Weekly stats: last 7 days
  Future<_WeeklyStats> getWeeklyStats() async {
    final to = DateTime.now();
    final from = to.subtract(const Duration(days: 6));
    final records = await getRecordsForRange(from, to);
    final total = records.fold<int>(0, (s, r) => s + r.completedCount);
    final missed = records.fold<int>(0, (s, r) => s + r.missedCount);
    final pct = records.isEmpty ? 0.0 : total / (records.length * 5) * 100;
    return _WeeklyStats(
      completedTotal: total,
      missedTotal: missed,
      completionPct: pct,
      avgScore: records.isEmpty
          ? 0.0
          : records.fold<int>(0, (s, r) => s + r.worshipScore) / records.length,
    );
  }

  /// Monthly stats
  Future<_MonthlyStats> getMonthlyStats(int year, int month) async {
    final records = await getMonthRecords(year, month);
    final total = records.fold<int>(0, (s, r) => s + r.completedCount);
    final pct = records.isEmpty ? 0.0 : total / (records.length * 5) * 100;

    // Longest streak in month
    int streak = 0, maxStreak = 0, cur = 0;
    for (final r in records) {
      if (r.completedCount == 5) {
        cur++;
        if (cur > maxStreak) maxStreak = cur;
      } else {
        cur = 0;
      }
    }

    // Most consistent prayer
    final counts = List<int>.filled(5, 0);
    for (final r in records) {
      final sl = r.statuses;
      for (int i = 0; i < 5; i++) {
        if (sl[i].countsAsCompleted) counts[i]++;
      }
    }
    int maxIdx = 0;
    for (int i = 1; i < 5; i++) {
      if (counts[i] > counts[maxIdx]) maxIdx = i;
    }

    return _MonthlyStats(
      completionPct: pct,
      longestStreak: maxStreak,
      mostConsistentPrayer: PrayerRecord.prayerNames[maxIdx],
      weeklyScores: _buildWeeklyChartData(records),
    );
  }

  List<double> _buildWeeklyChartData(List<PrayerRecord> records) {
    // Return up to 4 weekly buckets (avg score per week)
    final buckets = <List<int>>[[], [], [], []];
    for (int i = 0; i < records.length; i++) {
      buckets[(i ~/ 7).clamp(0, 3)].add(records[i].worshipScore);
    }
    return buckets.map((b) {
      if (b.isEmpty) return 0.0;
      return b.fold<int>(0, (s, v) => s + v) / b.length;
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Notifications
  // ─────────────────────────────────────────────────────────────────────────

  Future<int> saveNotification(NotificationItem item) async {
    final db = await database;
    return db.insert('notifications', item.toMap());
  }

  Future<List<NotificationItem>> getNotifications({
    NotificationCategory? category,
    bool includeArchived = false,
    String? searchQuery,
    int limit = 200,
  }) async {
    final db = await database;
    final where = <String>[];
    final args = <dynamic>[];

    if (!includeArchived) {
      where.add('isArchived = 0');
    }
    if (category != null) {
      where.add('category = ?');
      args.add(category.toStorageString());
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      where.add('(title LIKE ? OR body LIKE ?)');
      final q = '%${searchQuery.trim()}%';
      args.addAll([q, q]);
    }

    final rows = await db.query(
      'notifications',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'receivedAt DESC',
      limit: limit,
    );
    return rows.map(NotificationItem.fromMap).toList();
  }

  Future<void> markNotificationRead(int id) async {
    final db = await database;
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAllRead() async {
    final db = await database;
    await db.update('notifications', {'isRead': 1});
  }

  Future<void> deleteNotification(int id) async {
    final db = await database;
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllNotifications() async {
    final db = await database;
    await db.delete('notifications');
  }

  Future<void> archiveNotification(int id) async {
    final db = await database;
    await db.update(
      'notifications',
      {'isArchived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getUnreadCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM notifications WHERE isRead = 0 AND isArchived = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Row ↔ model helpers
  // ─────────────────────────────────────────────────────────────────────────

  PrayerRecord _rowToRecord(Map<String, dynamic> row) => PrayerRecord(
    date: row['date'] as String,
    fajr: PrayerStatusX.fromStorageString(row['fajr'] as String?),
    dhuhr: PrayerStatusX.fromStorageString(row['dhuhr'] as String?),
    asr: PrayerStatusX.fromStorageString(row['asr'] as String?),
    maghrib: PrayerStatusX.fromStorageString(row['maghrib'] as String?),
    isha: PrayerStatusX.fromStorageString(row['isha'] as String?),
    fajrTimestamp: row['fajrTs'] as String?,
    dhuhrTimestamp: row['dhuhrTs'] as String?,
    asrTimestamp: row['asrTs'] as String?,
    maghribTimestamp: row['maghribTs'] as String?,
    ishaTimestamp: row['ishaTs'] as String?,
  );

  Map<String, dynamic> _recordToRow(PrayerRecord r) => {
    'date': r.date,
    'fajr': r.fajr.toStorageString(),
    'dhuhr': r.dhuhr.toStorageString(),
    'asr': r.asr.toStorageString(),
    'maghrib': r.maghrib.toStorageString(),
    'isha': r.isha.toStorageString(),
    'fajrTs': r.fajrTimestamp,
    'dhuhrTs': r.dhuhrTimestamp,
    'asrTs': r.asrTimestamp,
    'maghribTs': r.maghribTimestamp,
    'ishaTs': r.ishaTimestamp,
  };
}

// ── Simple analytics DTOs ────────────────────────────────────────────────────

class _WeeklyStats {
  final int completedTotal;
  final int missedTotal;
  final double completionPct;
  final double avgScore;
  const _WeeklyStats({
    required this.completedTotal,
    required this.missedTotal,
    required this.completionPct,
    required this.avgScore,
  });
}

class _MonthlyStats {
  final double completionPct;
  final int longestStreak;
  final String mostConsistentPrayer;
  final List<double> weeklyScores;
  const _MonthlyStats({
    required this.completionPct,
    required this.longestStreak,
    required this.mostConsistentPrayer,
    required this.weeklyScores,
  });
}
