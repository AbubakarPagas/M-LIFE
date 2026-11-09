// ─────────────────────────────────────────────────────────────────────────────
// dars_all_screen.dart — Full Dars library with filters, sorting, infinite scroll
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/dars_controller.dart';
import '../models/dars_models.dart';
import '../widgets/dars_widgets.dart';
import 'dars_detail_screen.dart';

class DarsAllScreen extends StatefulWidget {
  final DarsCategory? initialCategory;
  const DarsAllScreen({super.key, this.initialCategory});

  @override
  State<DarsAllScreen> createState() => _DarsAllScreenState();
}

class _DarsAllScreenState extends State<DarsAllScreen> {
  late final DarsController _ctrl;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _ctrl = DarsController.instance;
    if (widget.initialCategory != null) {
      _ctrl.setCategory(widget.initialCategory);
    } else {
      _ctrl.loadDars(refresh: true);
    }
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _ctrl.loadDars();
    }
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.tertiary,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: DarsIslamicBgPainter(
                primaryColor: cs.primary,
                surfaceColor: cs.surface,
                isDark: isDark,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // ── AppBar ─────────────────────────────────────────────────
                _AllDarsAppBar(ctrl: _ctrl, cs: cs),

                // ── Filter bar ─────────────────────────────────────────────
                _FilterBar(ctrl: _ctrl),

                // ── Category chips ─────────────────────────────────────────
                _CategoryBar(ctrl: _ctrl),

                // ── List ───────────────────────────────────────────────────
                Expanded(
                  child: Obx(() {
                    if (_ctrl.state.isLoadingDars.value &&
                        _ctrl.state.allDars.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: DarsLoadingShimmer(count: 5),
                      );
                    }
                    if (_ctrl.state.errorMessage.value.isNotEmpty &&
                        _ctrl.state.allDars.isEmpty) {
                      return DarsErrorState(
                        message: _ctrl.state.errorMessage.value,
                        onRetry: () => _ctrl.loadDars(refresh: true),
                      );
                    }
                    if (_ctrl.state.allDars.isEmpty) {
                      return const DarsEmptyState(
                        title: 'No Lessons Found',
                        subtitle:
                            'Try a different category or clear the filters.',
                        icon: Icons.auto_stories_rounded,
                      );
                    }
                    return ListView.builder(
                      controller: _scrollCtrl,
                      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 80.h),
                      itemCount: _ctrl.state.allDars.length +
                          (_ctrl.state.hasMoreDars.value ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i == _ctrl.state.allDars.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Center(
                              child: SizedBox(
                                width: 24.r,
                                height: 24.r,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                          );
                        }
                        final dars = _ctrl.state.allDars[i];
                        final prog = _ctrl.getProgress(dars.id);
                        return Obx(
                          () => DarsCard(
                            dars: dars,
                            onTap: () =>
                                Get.to(() => DarsDetailScreen(dars: dars)),
                            isBookmarked: _ctrl.isBookmarked(dars.id),
                            onBookmarkTap: () => _ctrl.toggleBookmark(dars),
                            progress: prog?.percentComplete,
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllDarsAppBar extends StatelessWidget {
  final DarsController ctrl;
  final ColorScheme cs;
  const _AllDarsAppBar({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 12.w, 6.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Icon(Icons.arrow_back_rounded,
                color: Theme.of(context).hintColor, size: 22.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'All Lessons',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
          Obx(() {
            final total = ctrl.state.allDars.length;
            return Text(
              '$total lessons',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 11.sp,
                color: Theme.of(context).hintColor.withValues(alpha: 0.45),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final DarsController ctrl;
  const _FilterBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const sorts = [
      ('newest', 'Newest'),
      ('popular', 'Popular'),
      ('rating', 'Top Rated'),
    ];
    const types = [
      (null, 'All'),
      (DarsType.audio, 'Audio'),
      (DarsType.video, 'Video'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        children: [
          // Sort chips
          ...sorts.map(
            (s) => Obx(() {
              final selected = ctrl.state.sortBy.value == s.$1;
              return GestureDetector(
                onTap: () => ctrl.setSortBy(s.$1),
                child: Container(
                  margin: EdgeInsets.only(right: 6.w),
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: selected
                        ? cs.primary
                        : cs.primary.withValues(alpha: isDark ? 0.14 : 0.08),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: selected
                          ? cs.primary
                          : cs.primary.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Text(
                    s.$2,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : cs.primary.withValues(alpha: 0.80),
                    ),
                  ),
                ),
              );
            }),
          ),
          Container(
            width: 1,
            height: 18.h,
            color: cs.primary.withValues(alpha: 0.15),
            margin: EdgeInsets.symmetric(horizontal: 8.w),
          ),
          // Type chips
          ...types.map(
            (t) => Obx(() {
              final selected = ctrl.state.filterType.value == t.$1;
              return GestureDetector(
                onTap: () => ctrl.setFilterType(t.$1),
                child: Container(
                  margin: EdgeInsets.only(right: 6.w),
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: selected
                        ? kDarsGold
                        : kDarsGold.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: selected
                          ? kDarsGold
                          : kDarsGold.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    t.$2,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : kDarsGold.withValues(alpha: 0.80),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final DarsController ctrl;
  const _CategoryBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          // "All" chip
          Obx(
            () => GestureDetector(
              onTap: () => ctrl.setCategory(null),
              child: Container(
                margin: EdgeInsets.only(right: 6.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: ctrl.state.selectedCategory.value == null
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: ctrl.state.selectedCategory.value == null
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.20),
                  ),
                ),
                child: Text(
                  'All',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: ctrl.state.selectedCategory.value == null
                        ? Colors.white
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.80),
                  ),
                ),
              ),
            ),
          ),
          ...DarsCategory.values.map(
            (cat) => Obx(
              () => Padding(
                padding: EdgeInsets.only(right: 6.w),
                child: DarsCategoryChip(
                  category: cat,
                  selected: ctrl.state.selectedCategory.value == cat,
                  onTap: () => ctrl.setCategory(cat),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
