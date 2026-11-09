import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/hadith.dart';

// H1 — Duplicate bookmark fix:
//  • DB version bumped to 3 so onUpgrade recreates the table with the
//    UNIQUE(book_name, hadithnumber, hadith_language) constraint.
//  • addHadith() uses ConflictAlgorithm.ignore so rapid double-taps are
//    silently dropped at the SQLite level, with no crash or duplicate row.

class MyDatabaseHelper {
  MyDatabaseHelper._privateConstructor();
  static final MyDatabaseHelper instance =
      MyDatabaseHelper._privateConstructor();
  static Database? _database;

  static const String databaseName = "Bookmark.db";
  // Bumped to 3 — adds UNIQUE constraint on (book_name, hadithnumber, hadith_language)
  static const int databaseVersion = 3;

  static const String tableNameHadiths = "hadiths";
  static const String columnId = "_id";
  static const String columnHadithNumber = "hadithnumber";
  static const String columnArabicNumber = "arabicnumber";
  static const String columnTextArabic = "text_ara";
  static const String columnTextTranslated = "text";
  static const String columnGrades = "grades";
  static const String columnBookName = "book_name";
  static const String columnBookReference = "book_reference";
  static const String columnInBookReference = "inbook_reference";
  static const String columnLanguage = "hadith_language";

  // ── DB access ─────────────────────────────────────────────────────────────

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), databaseName);
    return openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        // Drop and recreate to pick up the new UNIQUE constraint
        await db.execute('DROP TABLE IF EXISTS $tableNameHadiths');
        await _onCreate(db, newVersion);
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableNameHadiths (
        $columnId                INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnHadithNumber      REAL,
        $columnArabicNumber      REAL,
        $columnTextArabic        TEXT,
        $columnTextTranslated    TEXT,
        $columnGrades            TEXT,
        $columnBookName          TEXT,
        $columnBookReference     INTEGER,
        $columnInBookReference   INTEGER,
        $columnLanguage          TEXT,
        UNIQUE($columnBookName, $columnHadithNumber, $columnLanguage)
      )
    ''');
  }

  // ── CRUD ─────────────────────────────────────────────────────────────────

  /// Inserts a bookmark. Silently ignores duplicates via ConflictAlgorithm.ignore,
  /// which maps to SQLite's INSERT OR IGNORE and respects the UNIQUE constraint.
  Future<void> addHadith(
    String bookName,
    dynamic hadithNumber,
    dynamic arabicNumber,
    String arabicHadithText,
    String translatedHadithText,
    List<Grade> grades,
    int inBookReference,
    int bookReference,
    String language,
  ) async {
    // Serialise grades as "name::grade&&name::grade&&"
    final allGrades = grades.map((g) => '${g.name}::${g.grade}').join('&&');

    final db = await instance.database;
    await db!.insert(
      tableNameHadiths,
      {
        columnBookName: bookName,
        columnHadithNumber: hadithNumber,
        columnArabicNumber: arabicNumber,
        columnTextArabic: arabicHadithText,
        columnTextTranslated: translatedHadithText,
        columnGrades: allGrades.isEmpty ? '' : '$allGrades&&',
        columnBookReference: bookReference,
        columnInBookReference: inBookReference,
        columnLanguage: language,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore, // ← H1 fix
    );
  }

  Future<List<Map<String, dynamic>>> readHadithData() async {
    final db = await instance.database;
    return db!.query(tableNameHadiths);
  }

  Future<int> updateData({
    required int rowId,
    required String bookName,
    required dynamic hadithNumber,
    required dynamic arabicNumber,
    required String arabicHadithText,
    required String translatedHadithText,
    required List<Grade> grades,
    required int bookReference,
    required int inBookReference,
    required String language,
    required String tableName,
  }) async {
    final allGrades = grades.map((g) => '${g.name}::${g.grade}').join('&&');
    final db = await instance.database;
    return db!.update(
      tableName,
      {
        columnBookName: bookName,
        columnHadithNumber: hadithNumber,
        columnArabicNumber: arabicNumber,
        columnTextArabic: arabicHadithText,
        columnTextTranslated: translatedHadithText,
        columnGrades: allGrades.isEmpty ? '' : '$allGrades&&',
        columnBookReference: bookReference,
        columnInBookReference: inBookReference,
        columnLanguage: language,
      },
      where: '$columnId=?',
      whereArgs: [rowId],
    );
  }

  Future<int> deleteOneRow(String tableName, int rowId) async {
    final db = await instance.database;
    return db!.delete(tableName, where: '$columnId=?', whereArgs: [rowId]);
  }

  Future<int> removeHadith(
    String bookName,
    dynamic hadithNumber,
    String hadithLanguage,
  ) async {
    final db = await instance.database;
    return db!.delete(
      tableNameHadiths,
      where:
          '$columnBookName=? AND $columnHadithNumber=? AND $columnLanguage=?',
      whereArgs: [bookName, hadithNumber, hadithLanguage],
    );
  }

  Future<int?> countTotal(String tableName) async {
    final db = await instance.database;
    final result = await db!.rawQuery('SELECT COUNT(*) FROM $tableName');
    return Sqflite.firstIntValue(result);
  }

  Future<void> deleteAllData(String tableName) async {
    final db = await instance.database;
    await db!.delete(tableName);
  }
}
