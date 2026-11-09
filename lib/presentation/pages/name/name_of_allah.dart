import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import 'controller/allah_names_controller.dart';
import 'screens/flashcard_screen.dart';
import 'screens/name_detail_screen.dart';
import 'screens/quiz_screen.dart';
import 'widgets/name_card.dart';
import 'widgets/name_colors.dart';

class NameOfAllah extends StatefulWidget {
  const NameOfAllah({super.key});

  @override
  State<NameOfAllah> createState() => _NameOfAllahState();
}

class _NameOfAllahState extends State<NameOfAllah>
    with SingleTickerProviderStateMixin {
  late final AllahNamesController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(AllahNamesController(), permanent: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.secondary,
      body: Stack(
        children: [
          // ── Islamic geometric background ────────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _IslamicBgPainter(
                color: isDark ? kNameGold : cs.primary,
                opacity: isDark ? 0.04 : 0.045,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Header ───────────────────────────────────────────────
                _PageHeader(ctrl: _ctrl),

                // ── Search + filter row ──────────────────────────────────
                _SearchAndFilter(ctrl: _ctrl),

                SizedBox(height: 8.h),

                // ── Body ─────────────────────────────────────────────────
                Expanded(
                  child: Obx(() {
                    // Show recently viewed strip + names list/grid
                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Daily name card
                        SliverToBoxAdapter(child: _DailyNameCard(ctrl: _ctrl)),

                        // Progress + mode selector
                        SliverToBoxAdapter(
                          child: _ProgressAndModeBar(ctrl: _ctrl),
                        ),

                        // Recently viewed (only on 'all' filter when not searching)
                        if (_ctrl.activeFilter.value == NameFilter.all &&
                            _ctrl.searchQuery.value.isEmpty &&
                            _ctrl.recentlyViewed.isNotEmpty)
                          SliverToBoxAdapter(
                            child: _RecentlyViewed(ctrl: _ctrl),
                          ),

                        // Section label
                        SliverToBoxAdapter(child: _SectionLabel(ctrl: _ctrl)),

                        // Names grid or list
                        if (_ctrl.viewMode.value == ViewMode.grid)
                          _NamesGrid(ctrl: _ctrl)
                        else
                          _NamesList(ctrl: _ctrl),

                        SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),

      // ── Memorization FAB ─────────────────────────────────────────────────
      floatingActionButton: _MemorizeFab(),
    );
  }
}

// ─── Page header ──────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final AllahNamesController ctrl;
  const _PageHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 10.h),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: cs.primary,
                size: 16.r,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Title block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أسماء الله الحسنى',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'naskh',
                    fontSize: 20.sp,
                    color: kNameGold,
                    height: 1.1,
                  ),
                ),
                Text(
                  '99 Names of Allah',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).hintColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // View toggle
          Obx(
            () => GestureDetector(
              onTap: ctrl.toggleViewMode,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Icon(
                  ctrl.viewMode.value == ViewMode.grid
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded,
                  color: cs.primary,
                  size: 18.r,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Search + filter ──────────────────────────────────────────────────────────

class _SearchAndFilter extends StatelessWidget {
  final AllahNamesController ctrl;
  const _SearchAndFilter({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: ctrl.searchController,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 13.sp,
              color: theme.hintColor,
            ),
            decoration: InputDecoration(
              hintText: 'Search by name, meaning…',
              hintStyle: TextStyle(
                fontFamily: 'kufi',
                fontSize: 12.sp,
                color: theme.hintColor.withValues(alpha: 0.4),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: cs.primary,
                size: 18.r,
              ),
              suffixIcon: Obx(
                () => ctrl.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: theme.hintColor.withValues(alpha: 0.5),
                          size: 16.r,
                        ),
                        onPressed: ctrl.clearSearch,
                      )
                    : const SizedBox.shrink(),
              ),
              filled: true,
              fillColor: cs.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(
                  color: cs.primary.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: cs.primary, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // Filter chips
          Obx(
            () => Row(
              children: [
                _FilterChip(
                  label: 'All (99)',
                  isActive: ctrl.activeFilter.value == NameFilter.all,
                  onTap: () => ctrl.setFilter(NameFilter.all),
                  cs: cs,
                ),
                SizedBox(width: 8.w),
                _FilterChip(
                  label: 'Favorites (${ctrl.favorites.length})',
                  isActive: ctrl.activeFilter.value == NameFilter.favorites,
                  onTap: () => ctrl.setFilter(NameFilter.favorites),
                  cs: cs,
                  activeColor: Colors.red,
                  icon: Icons.favorite_rounded,
                ),
                SizedBox(width: 8.w),
                _FilterChip(
                  label: 'Learned (${ctrl.learnedNames.length})',
                  isActive: ctrl.activeFilter.value == NameFilter.learned,
                  onTap: () => ctrl.setFilter(NameFilter.learned),
                  cs: cs,
                  activeColor: kNameEmerald,
                  icon: Icons.check_circle_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final ColorScheme cs;
  final Color? activeColor;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.cs,
    this.activeColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? cs.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.12) : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isActive ? color.withValues(alpha: 0.5) : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isActive ? color : cs.primary.withValues(alpha: 0.4),
                size: 12.r,
              ),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 11.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                color: isActive
                    ? color
                    : Theme.of(context).hintColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Daily name card ──────────────────────────────────────────────────────────

class _DailyNameCard extends StatelessWidget {
  final AllahNamesController ctrl;
  const _DailyNameCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final name = ctrl.dailyName;

    return GestureDetector(
      onTap: () {
        ctrl.addToRecent(name.number - 1);
        Get.to(
          () => NameDetailScreen(name: name),
          transition: Transition.cupertino,
        );
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cs.primary, cs.primary.withValues(alpha: 0.78)],
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: kNameGold.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.22),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Star icon
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: kNameGold.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: kNameGold.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: kNameGold,
                size: 22.r,
              ),
            ),
            SizedBox(width: 12.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name of the Day',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 10.sp,
                      color: Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    name.arabic,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'naskh',
                      fontSize: 28.sp,
                      color: kNameGold,
                      height: 1.4,
                    ),
                  ),
                  Text(
                    '${name.transliteration} — ${name.meaning}',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.5),
              size: 20.r,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Progress + mode bar ──────────────────────────────────────────────────────

class _ProgressAndModeBar extends StatelessWidget {
  final AllahNamesController ctrl;
  const _ProgressAndModeBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Obx(
      () => Container(
        margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Progress column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Memorization Progress',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 10.sp,
                          color: theme.hintColor.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        '${ctrl.learnedCount}/99',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: kNameEmerald,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: LinearProgressIndicator(
                      value: ctrl.progressPercent,
                      minHeight: 7.h,
                      backgroundColor: cs.primary.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        kNameEmerald,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // Streak badge
            Column(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: const Color(0xffFF6B35),
                  size: 18.r,
                ),
                Text(
                  '${ctrl.streak.value}',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xffFF6B35),
                  ),
                ),
                Text(
                  'streak',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 8.sp,
                    color: theme.hintColor.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recently viewed ──────────────────────────────────────────────────────────

class _RecentlyViewed extends StatelessWidget {
  final AllahNamesController ctrl;
  const _RecentlyViewed({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 6.h),
          child: Text(
            'Recently Viewed',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: theme.hintColor,
            ),
          ),
        ),
        SizedBox(
          height: 76.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            scrollDirection: Axis.horizontal,
            itemCount: ctrl.recentNames.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, i) {
              final name = ctrl.recentNames[i];
              return GestureDetector(
                onTap: () {
                  ctrl.addToRecent(name.number - 1);
                  Get.to(
                    () => NameDetailScreen(name: name),
                    transition: Transition.cupertino,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: kNameGold.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name.arabic,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'naskh',
                          fontSize: 20.sp,
                          color: kNameGold,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        name.transliteration,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 10.sp,
                          color: theme.hintColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final AllahNamesController ctrl;
  const _SectionLabel({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final count = ctrl.filteredNames.length;
      String label;
      if (ctrl.searchQuery.value.isNotEmpty) {
        label = '$count result${count == 1 ? '' : 's'} found';
      } else {
        switch (ctrl.activeFilter.value) {
          case NameFilter.favorites:
            label = '$count Favorites';
          case NameFilter.learned:
            label = '$count Learned';
          case NameFilter.all:
            label = 'All 99 Names';
        }
      }
      return Padding(
        padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 4.h),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: theme.hintColor,
          ),
        ),
      );
    });
  }
}

// ─── Names grid ───────────────────────────────────────────────────────────────

class _NamesGrid extends StatelessWidget {
  final AllahNamesController ctrl;
  const _NamesGrid({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final names = ctrl.filteredNames;
      if (names.isEmpty) {
        return SliverToBoxAdapter(child: _EmptyState());
      }
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 0.72,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) => AnimationLimiter(
              child: NameGridCard(name: names[i], index: i),
            ),
            childCount: names.length,
          ),
        ),
      );
    });
  }
}

// ─── Names list ───────────────────────────────────────────────────────────────

class _NamesList extends StatelessWidget {
  final AllahNamesController ctrl;
  const _NamesList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final names = ctrl.filteredNames;
      if (names.isEmpty) {
        return SliverToBoxAdapter(child: _EmptyState());
      }
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => AnimationLimiter(
              child: NameListTile(name: names[i], index: i),
            ),
            childCount: names.length,
          ),
        ),
      );
    });
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48.r,
            color: Theme.of(context).hintColor.withValues(alpha: 0.25),
          ),
          SizedBox(height: 12.h),
          Text(
            'No names found',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 14.sp,
              color: Theme.of(context).hintColor.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Memorize FAB ─────────────────────────────────────────────────────────────

class _MemorizeFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FloatingActionButton.extended(
      backgroundColor: cs.primary,
      elevation: 6,
      icon: Icon(Icons.psychology_rounded, color: kNameGold, size: 20.r),
      label: Text(
        'Memorize',
        style: TextStyle(
          fontFamily: 'kufi',
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      onPressed: () => _showMemorizeSheet(context),
    );
  }

  void _showMemorizeSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(color: kNameGold.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 38.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            Text(
              'Memorization Mode',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).hintColor,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Choose how you want to learn the 99 Names',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 11.sp,
                color: Theme.of(context).hintColor.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: _ModeCard(
                    icon: Icons.style_rounded,
                    label: 'Flashcards',
                    desc: 'Learn one by one',
                    color: cs.primary,
                    onTap: () {
                      Get.back();
                      Get.to(
                        () => const FlashcardScreen(),
                        transition: Transition.cupertino,
                      );
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ModeCard(
                    icon: Icons.quiz_rounded,
                    label: 'Quiz',
                    desc: 'Test your knowledge',
                    color: kNameEmerald,
                    onTap: () {
                      Get.back();
                      Get.to(
                        () => const QuizScreen(),
                        transition: Transition.cupertino,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.label,
    required this.desc,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
        ),
        child: Column(
          children: [
            Container(
              width: 46.r,
              height: 46.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24.r),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 9.5.sp,
                color: Theme.of(context).hintColor.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Islamic background painter ───────────────────────────────────────────────

class _IslamicBgPainter extends CustomPainter {
  final Color color;
  final double opacity;
  const _IslamicBgPainter({required this.color, this.opacity = 0.05});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const tile = 68.0;
    final cols = (size.width / tile).ceil() + 1;
    final rows = (size.height / tile).ceil() + 1;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cx = c * tile + (r.isOdd ? tile / 2 : 0.0);
        final cy = r * tile;
        _drawStar8(canvas, Offset(cx, cy), tile * 0.34, paint);
      }
    }
  }

  void _drawStar8(Canvas canvas, Offset center, double radius, Paint p) {
    final path = Path();
    const pts = 8;
    final inner = radius * 0.42;
    for (int i = 0; i < pts * 2; i++) {
      final angle = (i * math.pi / pts) - math.pi / 2;
      final r = i.isEven ? radius : inner;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, p);
    canvas.drawCircle(center, inner * 0.5, p..style = PaintingStyle.stroke);
    p.style = PaintingStyle.stroke;
  }

  @override
  bool shouldRepaint(_IslamicBgPainter old) =>
      old.color != color || old.opacity != opacity;
}
