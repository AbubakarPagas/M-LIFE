// ─────────────────────────────────────────────────────────────────────────────
// dars_categories_screen.dart — Browse by category and topic
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../data/dars_mock_data.dart';
import '../models/dars_models.dart';
import '../widgets/dars_widgets.dart';
import 'dars_all_screen.dart';

class DarsCategoriesScreen extends StatelessWidget {
  const DarsCategoriesScreen({super.key});

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
                _CatAppBar(cs: cs),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 80.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Category grid ──────────────────────────────────
                        DarsSectionHeader(
                          title: 'Browse by Category',
                          arabicTitle: 'تصفح حسب الموضوع',
                          icon: Icons.category_rounded,
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.6,
                            mainAxisSpacing: 10.h,
                            crossAxisSpacing: 10.w,
                          ),
                          itemCount: DarsCategory.values.length,
                          itemBuilder: (_, i) {
                            final cat = DarsCategory.values[i];
                            final count = mockDarsList
                                .where((d) => d.category == cat)
                                .length;
                            return _CategoryCard(
                              category: cat,
                              count: count,
                              cs: cs,
                              isDark: isDark,
                            );
                          },
                        ),
                        SizedBox(height: 20.h),

                        // ── Topics section ─────────────────────────────────
                        DarsSectionHeader(
                          title: 'Browse by Topic',
                          arabicTitle: 'تصفح حسب المحور',
                          icon: Icons.topic_rounded,
                        ),
                        ...mockTopics.map(
                          (t) => _TopicTile(topic: t, cs: cs, isDark: isDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CatAppBar extends StatelessWidget {
  final ColorScheme cs;
  const _CatAppBar({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 12.w, 10.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Icon(Icons.arrow_back_rounded,
                color: Theme.of(context).hintColor, size: 22.r),
          ),
          SizedBox(width: 12.w),
          Text(
            'Categories',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final DarsCategory category;
  final int count;
  final ColorScheme cs;
  final bool isDark;
  const _CategoryCard(
      {required this.category,
      required this.count,
      required this.cs,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(
        () => DarsAllScreen(initialCategory: category),
      ),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: cs.primary.withValues(alpha: isDark ? 0.10 : 0.07),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.emoji,
                  style: TextStyle(fontSize: 22.sp),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.displayName,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                Text(
                  category.arabicName,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'naskh',
                    fontSize: 10.sp,
                    color: kDarsGold.withValues(alpha: 0.65),
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

class _TopicTile extends StatelessWidget {
  final DarsTopic topic;
  final ColorScheme cs;
  final bool isDark;
  const _TopicTile(
      {required this.topic, required this.cs, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(
        () => DarsAllScreen(initialCategory: topic.category),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: cs.primary.withValues(alpha: isDark ? 0.09 : 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.09),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Text(
                  topic.category.emoji,
                  style: TextStyle(fontSize: 18.sp),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  Text(
                    topic.arabicTitle,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'naskh',
                      fontSize: 10.sp,
                      color: kDarsGold.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${topic.darsCount}',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
                Text(
                  'lessons',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 9.sp,
                    color: Theme.of(context).hintColor.withValues(alpha: 0.40),
                  ),
                ),
              ],
            ),
            SizedBox(width: 4.w),
            Icon(Icons.chevron_right_rounded,
                color: cs.primary.withValues(alpha: 0.30), size: 18.r),
          ],
        ),
      ),
    );
  }
}
