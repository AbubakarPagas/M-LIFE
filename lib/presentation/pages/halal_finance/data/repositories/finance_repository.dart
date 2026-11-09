// ─────────────────────────────────────────────────────────────────────────────
// FinanceRepository — data operations with local caching & bookmarks
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../datasources/finance_local_datasource.dart';
import '../models/finance_tip_model.dart';
import '../models/halal_haram_model.dart';

class FinanceRepository {
  static const _bookmarksKey = 'halal_finance_bookmarks';

  // ── Tips ──────────────────────────────────────────────────────────────────

  Future<List<FinanceTipModel>> getTips() async {
    final bookmarks = await _loadBookmarks();
    return FinanceLocalDatasource.tips.map((t) {
      return t.copyWith(isBookmarked: bookmarks.contains(t.id));
    }).toList();
  }

  Future<List<FinanceTipModel>> searchTips(String query) async {
    final all = await getTips();
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return all;
    return all.where((t) {
      return t.title.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q) ||
          t.category.label.toLowerCase().contains(q);
    }).toList();
  }

  Future<List<FinanceTipModel>> getTipsByCategory(
    FinanceCategory category,
  ) async {
    final all = await getTips();
    if (category == FinanceCategory.all) return all;
    return all.where((t) => t.category == category).toList();
  }

  // ── Daily tip ─────────────────────────────────────────────────────────────

  Map<String, String> getDailyTip() {
    final idx =
        DateTime.now().dayOfYear % FinanceLocalDatasource.dailyTips.length;
    return FinanceLocalDatasource.dailyTips[idx];
  }

  // ── Scripture ─────────────────────────────────────────────────────────────

  List<Map<String, String>> getScriptureCards() =>
      FinanceLocalDatasource.scriptureCards;

  // ── Halal / Haram ─────────────────────────────────────────────────────────

  List<HalalHaramEntry> getHalalEntries() =>
      FinanceLocalDatasource.halalEntries;

  List<HalalHaramEntry> getHaramEntries() =>
      FinanceLocalDatasource.haramEntries;

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  Future<void> toggleBookmark(String tipId) async {
    final bookmarks = await _loadBookmarks();
    if (bookmarks.contains(tipId)) {
      bookmarks.remove(tipId);
    } else {
      bookmarks.add(tipId);
    }
    await _saveBookmarks(bookmarks);
  }

  Future<Set<String>> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_bookmarksKey);
      if (raw == null) return {};
      final list = jsonDecode(raw) as List<dynamic>;
      return list.cast<String>().toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveBookmarks(Set<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_bookmarksKey, jsonEncode(ids.toList()));
    } catch (_) {}
  }
}

extension _DateTimeExt on DateTime {
  int get dayOfYear {
    final start = DateTime(year, 1, 1);
    return difference(start).inDays;
  }
}
