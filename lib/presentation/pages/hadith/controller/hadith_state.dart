import 'dart:async';

import 'package:get/get.dart';

import '../models/hadith.dart';

class HadithState {
  // ── Selected language (ISO 639-2) ──────────────────────────────────────────
  final RxString selectedLanguage = 'eng'.obs;

  // ── Currently loaded book ──────────────────────────────────────────────────
  final Rxn<HadithsList> currentBook = Rxn<HadithsList>();
  final RxString currentBookName = ''.obs;

  // ── Loading flags ──────────────────────────────────────────────────────────
  final RxBool isLoadingBook = false.obs;

  // ── Per-card loading flag: slug of the book currently being fetched ─────────
  final RxString loadingBookSlug = ''.obs;

  // ── Selected section filter (null = all hadiths) ───────────────────────────
  final RxnInt selectedSectionKey = RxnInt(null);

  // ── Bookmarked hadith ids (set of "bookName-hadithNumber-language") ─────────
  final RxSet<String> bookmarkedIds = <String>{}.obs;

  // ── Search query (the committed value, updated after debounce) ─────────────
  final RxString searchQuery = ''.obs;

  // ── Debounce timer ─────────────────────────────────────────────────────────
  Timer? searchDebounce;

  // ── M1: Last read position ─────────────────────────────────────────────────
  // Stores {bookSlug, sectionKey, scrollIndex} so the user can resume reading.
  final RxString lastReadBook = ''.obs;
  final RxnInt lastReadSectionKey = RxnInt(null);
  final RxInt lastReadScrollIndex = 0.obs;

  // ── M7: Hadith of the Day index (index into the currently loaded book) ──────
  final RxnInt hadithOfDayIndex = RxnInt(null);
}
