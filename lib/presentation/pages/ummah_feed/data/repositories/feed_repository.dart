// ─────────────────────────────────────────────────────────────────────────────
// FeedRepository — data operations with local persistence
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../datasources/feed_local_datasource.dart';
import '../models/feed_post_model.dart';

class FeedRepository {
  static const _bookmarksKey = 'ummah_feed_bookmarks';
  static const _appreciationsKey = 'ummah_feed_appreciations';
  static const _readHistoryKey = 'ummah_feed_read_history';

  // ── Feed ──────────────────────────────────────────────────────────────────

  Future<List<FeedPostModel>> getFeedPosts({
    FeedCategory category = FeedCategory.all,
    String searchQuery = '',
    int page = 0,
    int pageSize = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400)); // simulate network
    final bookmarks = await _loadSet(_bookmarksKey);
    final appreciations = await _loadSet(_appreciationsKey);

    var all = FeedLocalDatasource.getByCategory(category);

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      all = all.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.authorName.toLowerCase().contains(q) ||
            p.category.label.toLowerCase().contains(q);
      }).toList();
    }

    return all
        .map(
          (p) => p.copyWith(
            isBookmarked: bookmarks.contains(p.id),
            isAppreciated: appreciations.contains(p.id),
          ),
        )
        .skip(page * pageSize)
        .take(pageSize)
        .toList();
  }

  Future<List<FeedPostModel>> getFeaturedPosts() async {
    final bookmarks = await _loadSet(_bookmarksKey);
    final appreciations = await _loadSet(_appreciationsKey);
    return FeedLocalDatasource.getFeatured()
        .map(
          (p) => p.copyWith(
            isBookmarked: bookmarks.contains(p.id),
            isAppreciated: appreciations.contains(p.id),
          ),
        )
        .toList();
  }

  // ── Bookmark ──────────────────────────────────────────────────────────────

  Future<bool> toggleBookmark(String postId) async {
    final set = await _loadSet(_bookmarksKey);
    final added = !set.contains(postId);
    if (added) {
      set.add(postId);
    } else {
      set.remove(postId);
    }
    await _saveSet(_bookmarksKey, set);
    return added;
  }

  Future<List<FeedPostModel>> getBookmarkedPosts() async {
    final bookmarks = await _loadSet(_bookmarksKey);
    return FeedLocalDatasource.posts
        .where((p) => bookmarks.contains(p.id))
        .map((p) => p.copyWith(isBookmarked: true))
        .toList();
  }

  // ── Appreciation ──────────────────────────────────────────────────────────

  Future<bool> toggleAppreciation(String postId) async {
    final set = await _loadSet(_appreciationsKey);
    final added = !set.contains(postId);
    if (added) {
      set.add(postId);
    } else {
      set.remove(postId);
    }
    await _saveSet(_appreciationsKey, set);
    return added;
  }

  // ── Read history ──────────────────────────────────────────────────────────

  Future<void> markAsRead(String postId) async {
    final history = await _loadList(_readHistoryKey);
    history.remove(postId);
    history.insert(0, postId);
    final trimmed = history.take(50).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_readHistoryKey, jsonEncode(trimmed));
  }

  Future<List<String>> getReadHistory() async => _loadList(_readHistoryKey);

  Future<List<FeedPostModel>> getRecentlyRead() async {
    final history = await _loadList(_readHistoryKey);
    return FeedLocalDatasource.posts
        .where((p) => history.contains(p.id))
        .toList();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<Set<String>> _loadSet(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null) return {};
      return (jsonDecode(raw) as List).cast<String>().toSet();
    } catch (_) {
      return {};
    }
  }

  Future<List<String>> _loadList(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null) return [];
      return (jsonDecode(raw) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveSet(String key, Set<String> set) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(set.toList()));
  }
}
