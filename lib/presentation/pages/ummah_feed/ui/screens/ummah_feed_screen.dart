// ─────────────────────────────────────────────────────────────────────────────
// UmmahFeedScreen — Islamic vertical timeline feed
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../../tasbih/widgets/geometric_pattern_painter.dart';
import '../../controllers/ummah_feed_controller.dart';
import '../widgets/feed_category_chip_bar.dart';
import '../widgets/feed_post_card.dart';
import '../widgets/feed_skeleton.dart';

const _kGold = Color(0xffCDAD80);

class UmmahFeedScreen extends StatefulWidget {
  const UmmahFeedScreen({super.key});

  @override
  State<UmmahFeedScreen> createState() => _UmmahFeedScreenState();
}

class _UmmahFeedScreenState extends State<UmmahFeedScreen>
    with SingleTickerProviderStateMixin {
  late final UmmahFeedController _ctrl;
  late final ScrollController _scrollCtrl;
  late final TextEditingController _searchTextCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(UmmahFeedController(), permanent: false);
    _scrollCtrl = ScrollController()..addListener(_onScroll);
    _searchTextCtrl = TextEditingController();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      _ctrl.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchTextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: cs.secondary,
      body: Stack(
        children: [
          // ── Background pattern ──────────────────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: GeometricPatternPainter(
                color: isDark ? _kGold : cs.primary,
                opacity: isDark ? 0.040 : 0.048,
              ),
            ),
          ),
          // ── Top glow ────────────────────────────────────────────────────
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            child: Container(
              height: 280.h,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.85,
                  colors: [
                    cs.primary.withValues(alpha: isDark ? 0.14 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ── Main content ────────────────────────────────────────────────
          RefreshIndicator(
            color: cs.primary,
            onRefresh: _ctrl.refresh,
            child: CustomScrollView(
              controller: _scrollCtrl,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildAppBar(cs, isDark),
                // ── Category chips (pinned) ──────────────────────────────
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _ChipBarDelegate(
                    child: Container(
                      color: cs.secondary,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Obx(
                        () => FeedCategoryChipBar(
                          selected: _ctrl.selectedCategory.value,
                          onSelected: _ctrl.setCategory,
                        ),
                      ),
                    ),
                    height: 62.h,
                  ),
                ),
                // ── Body ────────────────────────────────────────────────
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  sliver: Obx(() => _buildBody(context, cs)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(ColorScheme cs, bool isDark) {
    final theme = Theme.of(context);
    return SliverAppBar(
      pinned: true,
      floating: false,
      elevation: 0,
      // ── Match AdhanAppBar: transparent, sits on cs.secondary background ──
      backgroundColor: cs.secondary,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      toolbarHeight: 64.h,
      title: Row(
        children: [
          // ── Circular gradient badge (exact AdhanAppBar style) ────────────
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [cs.primary, cs.primary.withValues(alpha: 0.70)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(Icons.hub_rounded, color: _kGold, size: 18.r),
          ),
          SizedBox(width: 10.w),
          // ── Title column (Arabic + English, exact AdhanAppBar style) ─────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ummah',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.hintColor,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Search toggle
        /* Obx(
          () => IconButton(
            icon: Icon(
              _ctrl.isSearchOpen.value
                  ? Icons.close_rounded
                  : Icons.search_rounded,
              color: cs.primary,
              size: 22.r,
            ),
            onPressed: () {
              _ctrl.toggleSearch();
              if (!_ctrl.isSearchOpen.value) _searchTextCtrl.clear();
            },
          ),
        ), */
        // Bookmarks with badge
        Obx(() {
          final count = _ctrl.bookmarkCount.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.bookmark_rounded,
                  color: count > 0 ? _kGold : cs.primary,
                  size: 22.r,
                ),
                onPressed: () => _showBookmarks(context),
              ),
              if (count > 0)
                Positioned(
                  top: 8.r,
                  right: 8.r,
                  child: Container(
                    width: 14.r,
                    height: 14.r,
                    decoration: BoxDecoration(
                      color: _kGold,
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.secondary, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 7.5.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
        SizedBox(width: 4.w),
      ],
    );
  }

  Widget _buildBody(BuildContext context, ColorScheme cs) {
    final state = _ctrl.loadState.value;

    if (state == FeedLoadState.loading) {
      return const SliverToBoxAdapter(child: FeedSkeleton());
    }

    if (state == FeedLoadState.error) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 52.r,
                color: cs.primary.withValues(alpha: 0.25),
              ),
              SizedBox(height: 14.h),
              Text(
                'Could not load feed',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 16.sp,
                  color: cs.primary.withValues(alpha: 0.45),
                ),
              ),
              SizedBox(height: 14.h),
              ElevatedButton(
                onPressed: _ctrl.refresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(fontFamily: 'kufi', fontSize: 13.sp),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Search bar ──────────────────────────────────────────────────────────
    final searchBar = Obx(
      () => _ctrl.isSearchOpen.value
          ? Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: _SearchBar(
                ctrl: _searchTextCtrl,
                onChanged: _ctrl.setSearch,
                cs: cs,
              ),
            )
          : const SizedBox.shrink(),
    );

    final posts = _ctrl.posts;

    if (posts.isEmpty) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            searchBar,
            SizedBox(height: 60.h),
            Icon(
              Icons.search_off_rounded,
              size: 48.r,
              color: cs.primary.withValues(alpha: 0.20),
            ),
            SizedBox(height: 12.h),
            Text(
              'No posts found',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 16.sp,
                color: cs.primary.withValues(alpha: 0.38),
              ),
            ),
          ],
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        children: [
          searchBar,
          AnimationLimiter(
            child: Column(
              children: List.generate(posts.length, (i) {
                return AnimationConfiguration.staggeredList(
                  position: i,
                  duration: const Duration(milliseconds: 380),
                  child: SlideAnimation(
                    verticalOffset: 20.h,
                    child: FadeInAnimation(
                      child: FeedPostCard(
                        post: posts[i],
                        isFirst: i == 0,
                        isLast: i == posts.length - 1 && !_ctrl.hasMore.value,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Load more
          Obx(() {
            if (_ctrl.isLoadingMore.value) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: SizedBox(
                  width: 22.r,
                  height: 22.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.primary,
                  ),
                ),
              );
            }
            if (!_ctrl.hasMore.value) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text(
                  '✦  You\'re all caught up  ✦',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13.sp,
                    color: _kGold.withValues(alpha: 0.55),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  void _showBookmarks(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.35,
        builder: (_, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.h, bottom: 6.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                child: Row(
                  children: [
                    Icon(Icons.bookmark_rounded, color: _kGold, size: 20.r),
                    SizedBox(width: 8.w),
                    Obx(
                      () => Text(
                        'Bookmarks (${_ctrl.bookmarkCount.value})',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  final bm = _ctrl.bookmarkedPosts;
                  if (bm.isEmpty) {
                    return Center(
                      child: Text(
                        'No bookmarks yet',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 13.sp,
                          color: cs.primary.withValues(alpha: 0.38),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: scrollCtrl,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: bm.length,
                    itemBuilder: (_, i) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: FeedPostCard(
                        post: bm[i],
                        isFirst: i == 0,
                        isLast: i == bm.length - 1,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search bar
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController ctrl;
  final ValueChanged<String> onChanged;
  final ColorScheme cs;

  const _SearchBar({
    required this.ctrl,
    required this.onChanged,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: cs.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Icon(
            Icons.search_rounded,
            color: cs.primary.withValues(alpha: 0.45),
            size: 18.r,
          ),
          Expanded(
            child: TextField(
              controller: ctrl,
              onChanged: onChanged,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 14.sp,
                color: cs.primary,
              ),
              decoration: InputDecoration(
                hintText: 'Search Quran, Hadith, articles…',
                hintStyle: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 13.sp,
                  color: cs.primary.withValues(alpha: 0.35),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 13.h,
                ),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: ctrl,
            builder: (_, val, __) => val.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      ctrl.clear();
                      onChanged('');
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 10.w),
                      child: Icon(
                        Icons.close_rounded,
                        color: cs.primary.withValues(alpha: 0.45),
                        size: 16.r,
                      ),
                    ),
                  )
                : SizedBox(width: 10.w),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category chip bar sliver delegate
// ─────────────────────────────────────────────────────────────────────────────
class _ChipBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  const _ChipBarDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext ctx, double shrinkOffset, bool overlaps) => child;

  @override
  bool shouldRebuild(_ChipBarDelegate old) => old.height != height;
}
