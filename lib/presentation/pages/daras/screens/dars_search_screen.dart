// ─────────────────────────────────────────────────────────────────────────────
// dars_search_screen.dart — Search lessons by title, scholar, topic, category
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/dars_controller.dart';
import '../models/dars_models.dart';
import '../widgets/dars_widgets.dart';
import 'dars_detail_screen.dart';

class DarsSearchScreen extends StatefulWidget {
  const DarsSearchScreen({super.key});

  @override
  State<DarsSearchScreen> createState() => _DarsSearchScreenState();
}

class _DarsSearchScreenState extends State<DarsSearchScreen> {
  late final DarsController _ctrl;
  final TextEditingController _textCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = DarsController.instance;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _focusNode.dispose();
    _ctrl.clearSearch();
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
                // ── Search bar ─────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 6.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _ctrl.clearSearch();
                          Get.back();
                        },
                        child: Icon(Icons.arrow_back_rounded,
                            color: Theme.of(context).hintColor, size: 22.r),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Container(
                          height: 44.h,
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainer,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: cs.primary.withValues(alpha: 0.20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded,
                                  color: cs.primary.withValues(alpha: 0.55),
                                  size: 18.r),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  controller: _textCtrl,
                                  focusNode: _focusNode,
                                  onChanged: (v) =>
                                      _ctrl.setSearchQuery(v),
                                  style: TextStyle(
                                    fontFamily: 'kufi',
                                    fontSize: 13.sp,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        'Search lessons, scholars, topics…',
                                    hintStyle: TextStyle(
                                      fontFamily: 'kufi',
                                      fontSize: 12.sp,
                                      color: Theme.of(context)
                                          .hintColor
                                          .withValues(alpha: 0.40),
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              Obx(
                                () => _ctrl.state.searchQuery.value.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          _textCtrl.clear();
                                          _ctrl.clearSearch();
                                        },
                                        child: Icon(Icons.close_rounded,
                                            color: cs.primary
                                                .withValues(alpha: 0.45),
                                            size: 16.r),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Filter chips ───────────────────────────────────────────
                SizedBox(
                  height: 34.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: DarsCategory.values
                        .map(
                          (cat) => Obx(
                            () => Padding(
                              padding: EdgeInsets.only(right: 6.w),
                              child: DarsCategoryChip(
                                category: cat,
                                selected:
                                    _ctrl.state.selectedCategory.value == cat,
                                onTap: () {
                                  if (_ctrl.state.selectedCategory.value ==
                                      cat) {
                                    _ctrl.state.selectedCategory.value = null;
                                  } else {
                                    _ctrl.state.selectedCategory.value = cat;
                                  }
                                },
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                SizedBox(height: 6.h),

                // ── Results ────────────────────────────────────────────────
                Expanded(
                  child: Obx(() {
                    final query = _ctrl.state.searchQuery.value;
                    final catFilter = _ctrl.state.selectedCategory.value;

                    if (query.isEmpty && catFilter == null) {
                      return _SearchSuggestions(ctrl: _ctrl);
                    }

                    var results = List.of(_ctrl.state.searchResults);
                    if (catFilter != null) {
                      results = results
                          .where((d) => d.category == catFilter)
                          .toList();
                    }

                    if (_ctrl.state.isSearching.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (results.isEmpty) {
                      return DarsEmptyState(
                        title: 'No Results',
                        subtitle:
                            'Try different keywords or browse categories.',
                        icon: Icons.search_off_rounded,
                        actionLabel: 'Browse Categories',
                        onAction: Get.back,
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
                          child: Text(
                            '${results.length} result${results.length != 1 ? 's' : ''} for "$query"',
                            style: TextStyle(
                              fontFamily: 'kufi',
                              fontSize: 11.sp,
                              color: Theme.of(context)
                                  .hintColor
                                  .withValues(alpha: 0.50),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding:
                                EdgeInsets.fromLTRB(16.w, 0, 16.w, 80.h),
                            itemCount: results.length,
                            itemBuilder: (_, i) {
                              final dars = results[i];
                              return Obx(
                                () => DarsCard(
                                  dars: dars,
                                  onTap: () => Get.to(
                                      () => DarsDetailScreen(dars: dars)),
                                  isBookmarked: _ctrl.isBookmarked(dars.id),
                                  onBookmarkTap: () =>
                                      _ctrl.toggleBookmark(dars),
                                  progress: _ctrl
                                      .getProgress(dars.id)
                                      ?.percentComplete,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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

// ── Search suggestions shown when query is empty ──────────────────────────────

class _SearchSuggestions extends StatelessWidget {
  final DarsController ctrl;
  const _SearchSuggestions({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 80.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent history as quick-access
          Obx(() {
            final hist = ctrl.state.history.take(3).toList();
            if (hist.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DarsSectionHeader(
                  title: 'Recently Watched',
                  icon: Icons.history_rounded,
                  color: kDarsGold,
                ),
                ...hist.map(
                  (h) => ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
                    leading: Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        h.darsType == DarsType.video
                            ? Icons.videocam_rounded
                            : Icons.headphones_rounded,
                        color: cs.primary,
                        size: 16.r,
                      ),
                    ),
                    title: Text(
                      h.darsTitle,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 12.sp,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    subtitle: Text(
                      h.scholarName,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 10.sp,
                        color: cs.primary.withValues(alpha: 0.60),
                      ),
                    ),
                    trailing: Icon(
                      Icons.north_west_rounded,
                      size: 14.r,
                      color: Theme.of(context).hintColor.withValues(alpha: 0.30),
                    ),
                    onTap: () {
                      final dars = ctrl.getDarsById(h.darsId);
                      if (dars != null) {
                        Get.to(() => DarsDetailScreen(dars: dars));
                      }
                    },
                  ),
                ),
                SizedBox(height: 14.h),
              ],
            );
          }),

          // Quick category links
          DarsSectionHeader(
            title: 'Browse Categories',
            icon: Icons.category_rounded,
          ),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: DarsCategory.values
                .map(
                  (cat) => DarsCategoryChip(
                    category: cat,
                    onTap: () {
                      ctrl.state.selectedCategory.value = cat;
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
