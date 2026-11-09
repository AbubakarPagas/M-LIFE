// ─────────────────────────────────────────────────────────────────────────────
// HalalFinanceScreen — Islamic Finance Tips page
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../controllers/halal_finance_controller.dart';
import '../../data/models/finance_tip_model.dart';
import '../widgets/category_chip_bar.dart';
import '../widgets/daily_tip_card.dart';
import '../widgets/finance_card_painter.dart';
import '../widgets/finance_search_bar.dart';
import '../widgets/finance_skeleton.dart';
import '../widgets/finance_tip_card.dart';
import '../widgets/halal_haram_section.dart';
import '../widgets/related_tools_section.dart';
import '../widgets/scripture_card.dart';

const Color _kGold = Color(0xffCDAD80);
const Color _kGoldDeep = Color(0xffCD9974);

class HalalFinanceScreen extends StatefulWidget {
  const HalalFinanceScreen({super.key});

  @override
  State<HalalFinanceScreen> createState() => _HalalFinanceScreenState();
}

class _HalalFinanceScreenState extends State<HalalFinanceScreen>
    with SingleTickerProviderStateMixin {
  late final HalalFinanceController _ctrl;
  late final PageController _pageCtrl;
  late final AnimationController _headerAnim;
  late final Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(HalalFinanceController(), permanent: false);
    _pageCtrl = PageController();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _headerAnim.dispose();
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
          // ── Background pattern ─────────────────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: FinanceStarPainter(
                color: isDark ? _kGold : cs.primary,
                opacity: isDark ? 0.045 : 0.050,
              ),
            ),
          ),
          // ── Radial top glow ────────────────────────────────────────────
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: Container(
              height: 280.h,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.85,
                  colors: [
                    cs.primary.withValues(alpha: isDark ? 0.12 : 0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ── Content ────────────────────────────────────────────────────
          Obx(() {
            final state = _ctrl.loadState.value;

            if (state == FinanceLoadState.loading) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 80.h),
                child: const FinanceSkeleton(),
              );
            }

            if (state == FinanceLoadState.error) {
              return _ErrorView(onRetry: _ctrl.refresh, cs: cs);
            }

            return RefreshIndicator(
              color: cs.primary,
              onRefresh: _ctrl.refresh,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  _buildAppBar(cs, isDark),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        SizedBox(height: 12.h),
                        // ── Daily tip ────────────────────────────────────
                        FadeTransition(
                          opacity: _headerFade,
                          child: Obx(() {
                            final tip = _ctrl.dailyTip.value;
                            if (tip == null) return const SizedBox.shrink();
                            return DailyTipCard(
                              icon: tip['icon'] ?? '💡',
                              title: tip['title'] ?? '',
                              body: tip['body'] ?? '',
                            );
                          }),
                        ),
                        SizedBox(height: 16.h),
                        // ── Search bar ───────────────────────────────────
                        FinanceSearchBar(onChanged: _ctrl.setSearch),
                        SizedBox(height: 12.h),
                      ]),
                    ),
                  ),
                  // ── Category chips (pinnable row) ────────────────────
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _ChipBarDelegate(
                      child: Container(
                        color: cs.secondary,
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Obx(
                          () => CategoryChipBar(
                            selected: _ctrl.selectedCategory.value,
                            onSelected: _ctrl.setCategory,
                          ),
                        ),
                      ),
                      height: 54.h,
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        SizedBox(height: 14.h),
                        // ── Tips list ────────────────────────────────────
                        _TipsList(ctrl: _ctrl),
                        SizedBox(height: 20.h),
                        // ── Scripture carousel ───────────────────────────
                        _ScriptureCarousel(
                          cards: _ctrl.scriptureCards,
                          pageCtrl: _pageCtrl,
                        ),
                        SizedBox(height: 20.h),
                        // ── Halal vs Haram ───────────────────────────────
                        Obx(
                          () => HalalHaramSection(
                            halalEntries: _ctrl.halalEntries,
                            haramEntries: _ctrl.haramEntries,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        // ── Related tools ────────────────────────────────
                        const RelatedToolsSection(),
                        SizedBox(height: 40.h),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(ColorScheme cs, bool isDark) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      elevation: 0,
      backgroundColor: cs.secondary,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: cs.primary,
          size: 20.r,
        ),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kGoldDeep, _kGold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 15.r,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halal Finance',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
                Text(
                  'Islamic financial guidance',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 9.5.sp,
                    color: cs.primary.withValues(alpha: 0.50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Obx(() {
          final bookmarks = _ctrl.bookmarkedTips;
          return Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.bookmark_rounded,
                  color: bookmarks.isNotEmpty ? _kGold : cs.primary,
                  size: 22.r,
                ),
                onPressed: () => _showBookmarks(context),
                tooltip: 'Bookmarks',
              ),
              if (bookmarks.isNotEmpty)
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
                        '${bookmarks.length}',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 8.sp,
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

  void _showBookmarks(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bookmarks = _ctrl.bookmarkedTips;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.60,
        maxChildSize: 0.90,
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
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Row(
                  children: [
                    Icon(Icons.bookmark_rounded, color: _kGold, size: 20.r),
                    SizedBox(width: 8.w),
                    Text(
                      'Bookmarks (${bookmarks.length})',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: bookmarks.isEmpty
                    ? Center(
                        child: Text(
                          'No bookmarks yet.\nTap ♥ on any tip to save it.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 13.sp,
                            color: cs.primary.withValues(alpha: 0.40),
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollCtrl,
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 4.h,
                        ),
                        itemCount: bookmarks.length,
                        separatorBuilder: (_, __) => SizedBox(height: 8.h),
                        itemBuilder: (_, i) => FinanceTipCard(
                          tip: bookmarks[i],
                          onBookmark: () =>
                              _ctrl.toggleBookmark(bookmarks[i].id),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tips list with staggered animation
// ─────────────────────────────────────────────────────────────────────────────
class _TipsList extends StatelessWidget {
  final HalalFinanceController ctrl;
  const _TipsList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      final tips = ctrl.visibleTips;

      if (tips.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48.r,
                color: cs.primary.withValues(alpha: 0.22),
              ),
              SizedBox(height: 12.h),
              Text(
                'No tips found',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: cs.primary.withValues(alpha: 0.40),
                ),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () {
                  ctrl.setSearch('');
                  ctrl.setCategory(FinanceCategory.all);
                },
                child: Text(
                  'Clear filters',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 12.sp,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return AnimationLimiter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Count indicator
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                children: [
                  Text(
                    '${tips.length} tip${tips.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(
                        context,
                      ).hintColor.withValues(alpha: 0.55),
                    ),
                  ),
                  if (ctrl.selectedCategory.value != FinanceCategory.all) ...[
                    SizedBox(width: 6.w),
                    Text(
                      '· ${ctrl.selectedCategory.value.label}',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 12.sp,
                        color: cs.primary.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ...tips.asMap().entries.map((e) {
              return AnimationConfiguration.staggeredList(
                position: e.key,
                duration: const Duration(milliseconds: 380),
                child: SlideAnimation(
                  verticalOffset: 24.h,
                  child: FadeInAnimation(
                    child: FinanceTipCard(
                      tip: e.value,
                      onBookmark: () => ctrl.toggleBookmark(e.value.id),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scripture PageView carousel
// ─────────────────────────────────────────────────────────────────────────────
class _ScriptureCarousel extends StatelessWidget {
  final RxList<Map<String, String>> cards;
  final PageController pageCtrl;

  const _ScriptureCarousel({required this.cards, required this.pageCtrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      if (cards.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: const Color(0xffCDAD80).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: const Color(0xffCDAD80),
                    size: 17.r,
                  ),
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quran & Hadith on Wealth',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    Text(
                      'Swipe to explore',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 10.sp,
                        color: Theme.of(
                          context,
                        ).hintColor.withValues(alpha: 0.40),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Page view
          SizedBox(
            height: 210.h,
            child: PageView.builder(
              controller: pageCtrl,
              itemCount: cards.length,
              itemBuilder: (_, i) => Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: ScriptureCard(data: cards[i]),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // Dot indicator
          Center(
            child: SmoothPageIndicator(
              controller: pageCtrl,
              count: cards.length,
              effect: WormEffect(
                dotHeight: 6.r,
                dotWidth: 6.r,
                activeDotColor: cs.primary,
                dotColor: cs.primary.withValues(alpha: 0.20),
                spacing: 5,
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chip bar sliver delegate
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

// ─────────────────────────────────────────────────────────────────────────────
// Error view
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  final ColorScheme cs;
  const _ErrorView({required this.onRetry, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 52.r,
              color: cs.primary.withValues(alpha: 0.28),
            ),
            SizedBox(height: 16.h),
            Text(
              'Could not load content',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: cs.primary.withValues(alpha: 0.45),
              ),
            ),
            SizedBox(height: 18.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(fontFamily: 'kufi', fontSize: 13.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
