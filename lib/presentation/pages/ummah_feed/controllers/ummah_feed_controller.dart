// ─────────────────────────────────────────────────────────────────────────────
// UmmahFeedController — GetX controller for the Ummah Feed
// ─────────────────────────────────────────────────────────────────────────────

import 'package:get/get.dart';

import '../data/datasources/feed_local_datasource.dart';
import '../data/models/feed_post_model.dart';
import '../data/repositories/feed_repository.dart';

enum FeedLoadState { loading, loaded, error }

class UmmahFeedController extends GetxController {
  static UmmahFeedController get instance => Get.find<UmmahFeedController>();

  final FeedRepository _repo;

  UmmahFeedController({FeedRepository? repo})
      : _repo = repo ?? FeedRepository();

  // ── State ─────────────────────────────────────────────────────────────────
  final Rx<FeedLoadState> loadState = FeedLoadState.loading.obs;
  final Rx<FeedCategory> selectedCategory = FeedCategory.all.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSearchOpen = false.obs;

  final RxList<FeedPostModel> posts = <FeedPostModel>[].obs;
  final RxList<FeedPostModel> featuredPosts = <FeedPostModel>[].obs;
  final RxList<FeedPostModel> bookmarkedPosts = <FeedPostModel>[].obs;
  final RxInt bookmarkCount = 0.obs;

  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  int _page = 0;
  static const _pageSize = 10;

  // Daily tip
  Map<String, String> dailyTip = {};

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    dailyTip = FeedLocalDatasource.getDailyTip();
    _loadInitial();
    ever(selectedCategory, (_) => _filterChanged());
    ever(searchQuery, (_) => _filterChanged());
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> _loadInitial() async {
    loadState.value = FeedLoadState.loading;
    _page = 0;
    hasMore.value = true;
    try {
      final results = await Future.wait([
        _repo.getFeedPosts(
          category: selectedCategory.value,
          searchQuery: searchQuery.value,
          page: 0,
          pageSize: _pageSize,
        ),
        _repo.getFeaturedPosts(),
        _repo.getBookmarkedPosts(),
      ]);
      posts.value = results[0];
      featuredPosts.value = results[1];
      bookmarkedPosts.value = results[2];
      bookmarkCount.value = bookmarkedPosts.length;
      hasMore.value = posts.length >= _pageSize;
      _page = 1;
      loadState.value = FeedLoadState.loaded;
    } catch (_) {
      loadState.value = FeedLoadState.error;
    }
  }

  @override
  Future<void> refresh() => _loadInitial();

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    try {
      final more = await _repo.getFeedPosts(
        category: selectedCategory.value,
        searchQuery: searchQuery.value,
        page: _page,
        pageSize: _pageSize,
      );
      if (more.isEmpty) {
        hasMore.value = false;
      } else {
        posts.addAll(more);
        _page++;
        if (more.length < _pageSize) hasMore.value = false;
      }
    } catch (_) {
      hasMore.value = false;
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _filterChanged() => _loadInitial();

  // ── Category & Search ─────────────────────────────────────────────────────

  void setCategory(FeedCategory cat) => selectedCategory.value = cat;

  void setSearch(String q) => searchQuery.value = q;

  void toggleSearch() {
    isSearchOpen.toggle();
    if (!isSearchOpen.value) setSearch('');
  }

  // ── Bookmark ──────────────────────────────────────────────────────────────

  Future<void> toggleBookmark(String postId) async {
    final added = await _repo.toggleBookmark(postId);
    // Update in main list
    final idx = posts.indexWhere((p) => p.id == postId);
    if (idx >= 0) {
      posts[idx] = posts[idx].copyWith(isBookmarked: added);
      posts.refresh();
    }
    // Update featured list
    final fidx = featuredPosts.indexWhere((p) => p.id == postId);
    if (fidx >= 0) {
      featuredPosts[fidx] = featuredPosts[fidx].copyWith(isBookmarked: added);
      featuredPosts.refresh();
    }
    // Refresh bookmarks list
    bookmarkedPosts.value = await _repo.getBookmarkedPosts();
    bookmarkCount.value = bookmarkedPosts.length;
  }

  // ── Appreciation ──────────────────────────────────────────────────────────

  Future<void> toggleAppreciation(String postId) async {
    final added = await _repo.toggleAppreciation(postId);
    final idx = posts.indexWhere((p) => p.id == postId);
    if (idx >= 0) {
      final current = posts[idx];
      posts[idx] = current.copyWith(
        isAppreciated: added,
        appreciateCount:
            added ? current.appreciateCount + 1 : current.appreciateCount - 1,
      );
      posts.refresh();
    }
  }

  // ── Read history ──────────────────────────────────────────────────────────

  Future<void> markAsRead(String postId) => _repo.markAsRead(postId);

  // ── Helpers ───────────────────────────────────────────────────────────────

  String formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '$count';
  }

  String formatDuration(int? seconds) {
    if (seconds == null) return '';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
