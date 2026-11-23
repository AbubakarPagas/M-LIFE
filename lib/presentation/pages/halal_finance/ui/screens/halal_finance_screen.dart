// ─────────────────────────────────────────────────────────────────────────────
// HalalFinanceScreen — Islamic Finance Guidance
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

// ── Brand palette ─────────────────────────────────────────────────────────────
const Color _kGold = Color(0xffCDAD80);
const Color _kGoldDeep = Color(0xffB8864E);
const Color _kEmerald = Color(0xff1A5C45);

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
  late final Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(HalalFinanceController(), permanent: false);
    _pageCtrl = PageController();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut));
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
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: cs.secondary,
      body: Stack(
        children: [
          // ── Subtle geometric background ─────────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: FinanceStarPainter(
                color: isDark ? _kGold : _kEmerald,
                opacity: isDark ? 0.028 : 0.030,
              ),
            ),
          ),
          // ── Content ─────────────────────────────────────────────────────
          Obx(() {
            final state = _ctrl.loadState.value;

            if (state == FinanceLoadState.loading) {
              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 20.h,
                  ),
                  child: const FinanceSkeleton(),
                ),
              );
            }

            if (state == FinanceLoadState.error) {
              return _ErrorView(onRetry: _ctrl.refresh, cs: cs);
            }

            return RefreshIndicator(
              color: _kGold,
              backgroundColor: cs.surfaceContainer,
              onRefresh: _ctrl.refresh,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // ── Immersive hero app bar ──────────────────────────────
                  _buildHeroAppBar(cs, isDark),
                  // ── Body content ───────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 18.h),
                          // Daily tip
                          FadeTransition(
                            opacity: _headerFade,
                            child: SlideTransition(
                              position: _headerSlide,
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
                          ),
                          SizedBox(height: 16.h),
                          // Search bar
                          FinanceSearchBar(onChanged: _ctrl.setSearch),
                          SizedBox(height: 14.h),
                        ],
                      ),
                    ),
                  ),
                  // ── Pinned category chips ───────────────────────────────
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _ChipBarDelegate(
                      minH: 52.h,
                      maxH: 52.h,
                      child: Container(
                        color: cs.secondary,
                        padding: EdgeInsets.only(
                          bottom: 8.h,
                          top: 2.h,
                        ),
                        child: Obx(
                          () => CategoryChipBar(
                            selected: _ctrl.selectedCategory.value,
                            onSelected: _ctrl.setCategory,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // ── Tips list ───────────────────────────────────────────
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 14.h,
                    ),
                    sliver: _TipsSliver(ctrl: _ctrl),
                  ),
                  // ── Scripture carousel ──────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: _ScriptureCarousel(
                        cards: _ctrl.scriptureCards,
                        pageCtrl: _pageCtrl,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                  // ── Halal vs Haram ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Obx(
                        () => HalalHaramSection(
                          halalEntries: _ctrl.halalEntries,
                          haramEntries: _ctrl.haramEntries,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                  // ── Related tools ───────────────────────────────────────
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: RelatedToolsSection(),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 48.h)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Hero App Bar ──────────────────────────────────────────────────────────
  SliverAppBar _buildHeroAppBar(ColorScheme cs, bool isDark) {
    return SliverAppBar(
      expandedHeight: 160.h,
      collapsedHeight: kToolbarHeight,
      pinned: true,
      floating: false,
      elevation: 0,
      backgroundColor: isDark ? const Color(0xff0D2B1E) : _kEmerald,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white.withValues(alpha: 0.90),
          size: 20.r,
        ),
        onPressed: () => Navigator.maybePop(context),
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
                  color: bookmarks.isNotEmpty
                      ? _kGold
                      : Colors.white.withValues(alpha: 0.75),
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
                    width: 15.r,
                    height: 15.r,
                    decoration: BoxDecoration(
                      color: _kGold,
                      shape: BoxShape.circle,
                      border: Border.all(color: _kEmerald, width: 1.5),
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
        SizedBox(width: 6.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _HeroHeader(isDark: isDark),
        titlePadding: EdgeInsets.zero,
        title: const SizedBox.shrink(),
      ),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
          ),
          child: Column(
            children: [
              // Handle
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
                    Container(
                      width: 34.r,
                      height: 34.r,
                      decoration: BoxDecoration(
                        color: _kGold.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.bookmark_rounded,
                        color: _kGold,
                        size: 17.r,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Saved Tips (${bookmarks.length})',
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
              Divider(
                height: 1,
                color: cs.primary.withValues(alpha: 0.08),
              ),
              Expanded(
                child: bookmarks.isEmpty
                    ? _EmptyBookmarks(cs: cs)
                    : ListView.separated(
                        controller: scrollCtrl,
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 12.h,
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
// Hero header — Islamic banner with Bismillah + stats
// ─────────────────────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final bool isDark;
  const _HeroHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? const Color(0xff0D2B1E) : _kEmerald;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? const Color(0xff0A1F16) : const Color(0xff1A5C45),
            isDark ? const Color(0xff122B1F) : const Color(0xff2E8B57),
            isDark ? const Color(0xff0D2B1E) : const Color(0xff1A6B4A),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Geometric pattern overlay
          Positioned.fill(
            child: CustomPaint(
              painter: FinanceStarPainter(
                color: Colors.white,
                opacity: 0.04,
              ),
            ),
          ),
          // Gold arc accent top-right
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160.r,
              height: 160.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _kGold.withValues(alpha: 0.14),
                  width: 1.5,
                ),
              ),
            ),
          ),
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _kGold.withValues(alpha: 0.10),
                  width: 1,
                ),
              ),
            ),
          ),
          // Content
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 50.h, 20.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Bismillah badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _kGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: _kGold.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: _kGold,
                            size: 10.r,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            'بِسْمِ اللَّهِ',
                            style: TextStyle(
                              fontFamily: 'naskh',
                              fontSize: 11.sp,
                              color: _kGold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    // Title
                    Text(
                      'Halal Finance',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Guidance rooted in Islamic principles',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 11.sp,
                        color: Colors.white.withValues(alpha: 0.65),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    // Stats row
                    _HeroStats(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(icon: Icons.lightbulb_rounded, label: 'Tips & Guidance'),
        SizedBox(width: 8.w),
        _StatChip(icon: Icons.menu_book_rounded, label: 'Quran & Hadith'),
        SizedBox(width: 8.w),
        _StatChip(icon: Icons.balance_rounded, label: 'Halal Guide'),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.r, color: _kGold),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 9.sp,
              color: Colors.white.withValues(alpha: 0.80),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tips rendered as a sliver (avoids Column inside SliverList)
// ─────────────────────────────────────────────────────────────────────────────
class _TipsSliver extends StatelessWidget {
  final HalalFinanceController ctrl;
  const _TipsSliver({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      final tips = ctrl.visibleTips;

      if (tips.isEmpty) {
        return SliverToBoxAdapter(child: _EmptyTips(ctrl: ctrl, cs: cs));
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Header row
            if (index == 0) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 4.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kGold, _kGoldDeep],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${tips.length} tip${tips.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    if (ctrl.selectedCategory.value != FinanceCategory.all) ...[
                      SizedBox(width: 6.w),
                      Text(
                        '· ${ctrl.selectedCategory.value.label}',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 12.sp,
                          color: cs.primary.withValues(alpha: 0.50),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }

            // Tip card
            final tipIndex = index - 1;
            return AnimationConfiguration.staggeredList(
              position: tipIndex,
              duration: const Duration(milliseconds: 380),
              child: SlideAnimation(
                verticalOffset: 20.h,
                child: FadeInAnimation(
                  child: FinanceTipCard(
                    tip: tips[tipIndex],
                    onBookmark: () => ctrl.toggleBookmark(tips[tipIndex].id),
                  ),
                ),
              ),
            );
          },
          childCount: tips.length + 1, // +1 for header
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scripture carousel — properly bounded
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Section header ───────────────────────────────────────────────
          _SectionHeaderRow(
            icon: Icons.menu_book_rounded,
            iconColor: _kGold,
            iconBg: _kGold.withValues(alpha: 0.12),
            title: 'Quran & Hadith on Wealth',
            subtitle: 'Swipe to explore',
          ),
          SizedBox(height: 14.h),
          // ── Page view with explicit height ───────────────────────────────
          SizedBox(
            height: 220.h,
            child: PageView.builder(
              controller: pageCtrl,
              clipBehavior: Clip.none,
              itemCount: cards.length,
              itemBuilder: (_, i) => Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: ScriptureCard(data: cards[i]),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // ── Dot indicator ────────────────────────────────────────────────
          Center(
            child: SmoothPageIndicator(
              controller: pageCtrl,
              count: cards.length,
              effect: ExpandingDotsEffect(
                dotHeight: 5.r,
                dotWidth: 5.r,
                expansionFactor: 3,
                activeDotColor: _kGold,
                dotColor: cs.primary.withValues(alpha: 0.18),
                spacing: 4,
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared section header row
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeaderRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;

  const _SectionHeaderRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 36.r,
          height: 36.r,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: iconColor, size: 17.r),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: theme.hintColor,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 10.sp,
                color: theme.hintColor.withValues(alpha: 0.42),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty states
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyTips extends StatelessWidget {
  final HalalFinanceController ctrl;
  final ColorScheme cs;
  const _EmptyTips({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 34.r,
              color: cs.primary.withValues(alpha: 0.28),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'No tips found',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: cs.primary.withValues(alpha: 0.45),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Try a different keyword or category',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 12.sp,
              color: cs.primary.withValues(alpha: 0.30),
            ),
          ),
          SizedBox(height: 16.h),
          OutlinedButton.icon(
            onPressed: () {
              ctrl.setSearch('');
              ctrl.setCategory(FinanceCategory.all);
            },
            icon: Icon(Icons.refresh_rounded, size: 15.r),
            label: Text(
              'Clear filters',
              style: TextStyle(fontFamily: 'kufi', fontSize: 12.sp),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.primary,
              side: BorderSide(color: cs.primary.withValues(alpha: 0.35)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBookmarks extends StatelessWidget {
  final ColorScheme cs;
  const _EmptyBookmarks({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmark_border_rounded,
            size: 48.r,
            color: _kGold.withValues(alpha: 0.35),
          ),
          SizedBox(height: 12.h),
          Text(
            'No saved tips yet',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: cs.primary.withValues(alpha: 0.40),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Tap the bookmark icon on any tip to save it',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 12.sp,
              color: cs.primary.withValues(alpha: 0.28),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chip bar sliver delegate
// ─────────────────────────────────────────────────────────────────────────────
class _ChipBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minH;
  final double maxH;

  const _ChipBarDelegate({
    required this.child,
    required this.minH,
    required this.maxH,
  });

  @override
  double get minExtent => minH;
  @override
  double get maxExtent => maxH;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).colorScheme.secondary,
      elevation: shrinkOffset > 0 ? 1 : 0,
      shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      child: child,
    );
  }

  @override
  bool shouldRebuild(_ChipBarDelegate old) =>
      old.minH != minH || old.maxH != maxH;
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
            Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 38.r,
                color: cs.primary.withValues(alpha: 0.28),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Could not load content',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: cs.primary.withValues(alpha: 0.50),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please check your connection and try again',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 12.sp,
                color: cs.primary.withValues(alpha: 0.35),
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded, size: 16.r),
              label: Text(
                'Try Again',
                style: TextStyle(fontFamily: 'kufi', fontSize: 13.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kEmerald,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 13.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
