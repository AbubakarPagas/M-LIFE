import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/toast/islamic_toast.dart';
import '../helper/bookhelper.dart';
import '../helper/databasehelper.dart';
import '../helper/hadith_notification_helper.dart';
import '../helper/jsonhelper.dart';
import '../helper/languagehelper.dart';
import '../helper/sharedpreferenceshelper.dart';
import '../models/hadith.dart';
import 'hadith_state.dart';

class HadithController extends GetxController {
  static HadithController get instance =>
      GetInstance().putOrFind(() => HadithController());

  final HadithState state = HadithState();

  // ── SharedPreferences keys ─────────────────────────────────────────────────
  static const _kLang = 'hadith_language';
  static const _kLastBook = 'hadith_last_book';
  static const _kLastSection = 'hadith_last_section';
  static const _kLastScroll = 'hadith_last_scroll';
  static const _kDailyNotifEnabled = 'hadith_daily_notif';
  static const _kDotdDate = 'hadith_dotd_date'; // "Hadith of the Day" date
  static const _kDotdIndex = 'hadith_dotd_index'; // index into loaded book

  // ── Convenience getters ────────────────────────────────────────────────────

  String get selectedLanguage => state.selectedLanguage.value;

  List<String> get booksForCurrentLanguage =>
      BookHelper.languageToFileNamesMap[selectedLanguage] ??
      BookHelper.fileNamesList;

  HadithsList? get currentBook => state.currentBook.value;

  bool get isLoadingBook => state.isLoadingBook.value;

  String get loadingBookSlug => state.loadingBookSlug.value;

  String get searchQuery => state.searchQuery.value;

  int bookIndexOf(String bookSlug) =>
      BookHelper.fileNamesList.indexOf(bookSlug);

  // ── M1: last read position ─────────────────────────────────────────────────
  String get lastReadBook => state.lastReadBook.value;
  int? get lastReadSectionKey => state.lastReadSectionKey.value;
  int get lastReadScrollIndex => state.lastReadScrollIndex.value;
  bool get hasLastRead => state.lastReadBook.value.isNotEmpty;

  // ── M4: notification enabled flag ─────────────────────────────────────────
  bool get isDailyNotifEnabled =>
      SharedPreferencesHelper.getBool(_kDailyNotifEnabled, false);

  // ── M7: Hadith of the Day ─────────────────────────────────────────────────
  Hadith? get hadithOfDay {
    final idx = state.hadithOfDayIndex.value;
    final book = currentBook;
    if (idx == null || book == null || idx >= book.hadiths.length) return null;
    return book.hadiths[idx];
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    final saved = SharedPreferencesHelper.getString(_kLang, 'eng');
    state.selectedLanguage.value = saved;

    // M1 — restore last read
    state.lastReadBook.value = SharedPreferencesHelper.getString(
      _kLastBook,
      '',
    );
    state.lastReadSectionKey.value =
        SharedPreferencesHelper.getInt(_kLastSection, -1) == -1
        ? null
        : SharedPreferencesHelper.getInt(_kLastSection, -1);
    state.lastReadScrollIndex.value = SharedPreferencesHelper.getInt(
      _kLastScroll,
      0,
    );

    _loadBookmarks();
  }

  @override
  void onClose() {
    state.searchDebounce?.cancel();
    super.onClose();
  }

  // ── Language ───────────────────────────────────────────────────────────────

  void changeLanguage(String lang) {
    state.selectedLanguage.value = lang;
    SharedPreferencesHelper.setString(_kLang, lang);
    state.currentBook.value = null;
    state.currentBookName.value = '';
    state.selectedSectionKey.value = null;
    state.searchQuery.value = '';
    state.hadithOfDayIndex.value = null;
    log('Language changed to $lang', name: 'HadithController');
  }

  List<String> get availableLanguages =>
      BookHelper.languageToFileNamesMap.keys.toList();

  String languageDisplayName(String code) =>
      LanguageHelper.getLanguageName(code);

  // ── Load a book ────────────────────────────────────────────────────────────

  Future<void> loadBook(String bookSlug) async {
    state.loadingBookSlug.value = bookSlug;
    state.isLoadingBook.value = true;
    state.selectedSectionKey.value = null;
    state.searchQuery.value = '';
    try {
      final path = JsonHelper.assetPath(selectedLanguage, bookSlug);
      final bookIndex = bookIndexOf(bookSlug);
      final loaded = await loadJson(path, bookIndex);
      state.currentBook.value = loaded;
      state.currentBookName.value = bookSlug;

      // M7 — resolve Hadith of the Day index for this book
      _resolveHadithOfDay(loaded);

      log(
        'Loaded $bookSlug ($selectedLanguage) — ${loaded.hadiths.length} hadiths',
        name: 'HadithController',
      );
    } catch (e, st) {
      log('Error loading $bookSlug: $e\n$st', name: 'HadithController');
      final ctx = Get.context;
      if (ctx != null) {
        IslamicToast.show(
          ctx,
          message: 'Could not load $bookSlug. Please try again.',
          type: IslamicToastType.warning,
        );
      }
    } finally {
      state.isLoadingBook.value = false;
      state.loadingBookSlug.value = '';
    }
  }

  // ── M1: Save / restore last read position ──────────────────────────────────

  void saveLastRead({
    required String bookSlug,
    required int? sectionKey,
    required int scrollIndex,
  }) {
    state.lastReadBook.value = bookSlug;
    state.lastReadSectionKey.value = sectionKey;
    state.lastReadScrollIndex.value = scrollIndex;
    SharedPreferencesHelper.setString(_kLastBook, bookSlug);
    SharedPreferencesHelper.setInt(_kLastSection, sectionKey ?? -1);
    SharedPreferencesHelper.setInt(_kLastScroll, scrollIndex);
  }

  /// Loads the last-read book (if needed) and navigates back to the section.
  /// Returns true if there was a last-read position to restore.
  Future<bool> resumeLastRead() async {
    if (!hasLastRead) return false;
    final book = lastReadBook;
    if (state.currentBookName.value != book) {
      await loadBook(book);
    }
    state.selectedSectionKey.value = lastReadSectionKey;
    return true;
  }

  // ── M4: Daily Hadith notification ──────────────────────────────────────────

  Future<void> setDailyNotification({required bool enabled}) async {
    await SharedPreferencesHelper.setBool(_kDailyNotifEnabled, enabled);
    if (enabled) {
      await HadithNotificationHelper.scheduleDailyHadith(hour: 7, minute: 0);
    } else {
      await HadithNotificationHelper.cancelDailyHadith();
    }
  }

  // ── M7: Hadith of the Day ─────────────────────────────────────────────────

  /// Picks a deterministic random index per calendar date so the same hadith
  /// is shown all day across sessions.
  void _resolveHadithOfDay(HadithsList book) {
    if (book.hadiths.isEmpty) {
      state.hadithOfDayIndex.value = null;
      return;
    }
    final today = _todayKey();
    final saved = SharedPreferencesHelper.getString(_kDotdDate, '');
    if (saved == today) {
      // Same day — restore saved index
      final idx = SharedPreferencesHelper.getInt(_kDotdIndex, 0);
      state.hadithOfDayIndex.value = idx.clamp(0, book.hadiths.length - 1);
    } else {
      // New day — pick a new random hadith
      final idx = math.Random().nextInt(book.hadiths.length);
      state.hadithOfDayIndex.value = idx;
      SharedPreferencesHelper.setString(_kDotdDate, today);
      SharedPreferencesHelper.setInt(_kDotdIndex, idx);
    }
  }

  static String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  // ── Sections ───────────────────────────────────────────────────────────────

  Map<String, String> get sections => currentBook?.metadata.sections ?? {};

  Map<String, Map<String, num>> get sectionDetails =>
      currentBook?.metadata.sectionDetails ?? {};

  void selectSection(int? sectionKey) {
    state.selectedSectionKey.value = sectionKey;
    state.searchQuery.value = '';
  }

  // ── Search with 300 ms debounce ────────────────────────────────────────────

  void setSearchQuery(String raw) {
    state.searchDebounce?.cancel();
    state.searchDebounce = Timer(const Duration(milliseconds: 300), () {
      state.searchQuery.value = raw;
    });
  }

  // ── Hadith filtering (section + text/number search) ────────────────────────

  List<Hadith> get hadithsForCurrentSection {
    final book = currentBook;
    if (book == null) return [];
    List<Hadith> list = book.hadiths;

    final sectionKey = state.selectedSectionKey.value;
    if (sectionKey != null) {
      final detail = sectionDetails[sectionKey.toString()];
      if (detail != null) {
        final first = detail['hadithnumber_first']?.toInt() ?? 0;
        final last = detail['hadithnumber_last']?.toInt() ?? 0;
        list = list.where((h) {
          final n = int.tryParse(h.hadithNumber.toString()) ?? 0;
          return n >= first && n <= last;
        }).toList();
      }
    }

    final query = searchQuery.toLowerCase().trim();
    if (query.isNotEmpty) {
      list = list.where((h) {
        if (h.text.toLowerCase().contains(query)) return true;
        if (h.textAra.contains(query)) return true;
        if (h.hadithNumber.toString().contains(query)) return true;
        return false;
      }).toList();
    }

    return list;
  }

  // ── M6: Global cross-section search ───────────────────────────────────────

  /// Searches all hadiths in the currently loaded book (all sections) for
  /// [query]. Used by the global search screen.
  List<Hadith> globalSearch(String query) {
    final book = currentBook;
    if (book == null || query.trim().isEmpty) return [];
    final q = query.toLowerCase().trim();
    return book.hadiths.where((h) {
      if (h.text.toLowerCase().contains(q)) return true;
      if (h.textAra.contains(q)) return true;
      if (h.hadithNumber.toString().contains(q)) return true;
      return false;
    }).toList();
  }

  // ── Hadith count ───────────────────────────────────────────────────────────

  int hadithCountForBook(String bookSlug) {
    final index = bookIndexOf(bookSlug);
    if (index < 0 || index >= BookHelper.hadithNumberList.length) return 0;
    return BookHelper.hadithNumberList[index];
  }

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  String _bookmarkId(String bookName, dynamic hadithNumber, String language) =>
      '$bookName-$hadithNumber-$language';

  bool isBookmarked(String bookName, dynamic hadithNumber) => state
      .bookmarkedIds
      .contains(_bookmarkId(bookName, hadithNumber, selectedLanguage));

  Future<void> toggleBookmark(Hadith hadith) async {
    final book = state.currentBookName.value;
    final id = _bookmarkId(book, hadith.hadithNumber, selectedLanguage);

    if (state.bookmarkedIds.contains(id)) {
      await MyDatabaseHelper.instance.removeHadith(
        book,
        hadith.hadithNumber,
        selectedLanguage,
      );
      state.bookmarkedIds.remove(id);
      final ctx = Get.context;
      if (ctx != null) {
        IslamicToast.show(
          ctx,
          message: 'Bookmark removed',
          arabicMessage: 'تم حذف الإشارة',
          type: IslamicToastType.warning,
          duration: const Duration(seconds: 1),
        );
      }
    } else {
      await MyDatabaseHelper.instance.addHadith(
        book,
        hadith.hadithNumber,
        hadith.arabicNumber,
        hadith.textAra,
        hadith.text,
        hadith.grades,
        hadith.reference.inBookReference,
        hadith.reference.bookReference,
        selectedLanguage,
      );
      state.bookmarkedIds.add(id);
      final ctx = Get.context;
      if (ctx != null) {
        IslamicToast.show(
          ctx,
          message: 'Bookmark added',
          arabicMessage: 'تمت إضافة الإشارة',
          type: IslamicToastType.success,
          duration: const Duration(seconds: 1),
        );
      }
    }
  }

  Future<void> _loadBookmarks() async {
    try {
      final rows = await MyDatabaseHelper.instance.readHadithData();
      final ids = rows.map((r) {
        final bookName = r[MyDatabaseHelper.columnBookName] as String? ?? '';
        final hadithNum = r[MyDatabaseHelper.columnHadithNumber];
        final lang = r[MyDatabaseHelper.columnLanguage] as String? ?? '';
        return _bookmarkId(bookName, hadithNum, lang);
      }).toSet();
      state.bookmarkedIds.assignAll(ids);
    } catch (e) {
      log('Error loading bookmarks: $e', name: 'HadithController');
    }
  }

  // ── Display names ─────────────────────────────────────────────────────────

  String bookDisplayName(String bookSlug) {
    const names = {
      'bukhari': 'Sahih al-Bukhari',
      'muslim': 'Sahih Muslim',
      'nasai': "Sunan an-Nasa'i",
      'abudawud': 'Sunan Abi Dawud',
      'tirmidhi': 'Jami at-Tirmidhi',
      'ibnmajah': 'Sunan Ibn Majah',
      'malik': 'Muwatta Malik',
    };
    return names[bookSlug] ?? bookSlug;
  }

  String bookArabicName(String bookSlug) {
    const names = {
      'bukhari': 'صحيح البخاري',
      'muslim': 'صحيح مسلم',
      'nasai': 'سنن النسائي',
      'abudawud': 'سنن أبي داود',
      'tirmidhi': 'جامع الترمذي',
      'ibnmajah': 'سنن ابن ماجه',
      'malik': 'موطأ مالك',
    };
    return names[bookSlug] ?? bookSlug;
  }
}
