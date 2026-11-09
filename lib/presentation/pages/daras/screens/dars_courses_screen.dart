// ─────────────────────────────────────────────────────────────────────────────
// dars_courses_screen.dart — Browse courses + DarsCourseDetailScreen
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/dars_controller.dart';
import '../models/dars_models.dart';
import '../widgets/dars_widgets.dart';
import 'dars_detail_screen.dart';

class DarsCoursesScreen extends StatelessWidget {
  const DarsCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = DarsController.instance;

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
                _CoursesAppBar(cs: cs),
                Expanded(
                  child: Obx(() {
                    final courses = ctrl.state.courses;
                    if (ctrl.state.isLoadingCourses.value) {
                      return const DarsLoadingShimmer(count: 3);
                    }
                    if (courses.isEmpty) {
                      return const DarsEmptyState(
                        title: 'No Courses Available',
                        subtitle:
                            'Structured courses will be available soon.',
                        icon: Icons.school_rounded,
                      );
                    }
                    return ListView.builder(
                      padding:
                          EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 80.h),
                      itemCount: courses.length,
                      itemBuilder: (_, i) => _CourseCard(
                        course: courses[i],
                        cs: cs,
                        isDark: isDark,
                      ),
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

class _CoursesAppBar extends StatelessWidget {
  final ColorScheme cs;
  const _CoursesAppBar({required this.cs});

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
            'Courses',
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

class _CourseCard extends StatelessWidget {
  final DarsCourse course;
  final ColorScheme cs;
  final bool isDark;
  const _CourseCard(
      {required this.course, required this.cs, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => DarsCourseDetailScreen(course: course)),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: cs.primary.withValues(alpha: isDark ? 0.10 : 0.07),
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: isDark ? 0.05 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 54.r,
                  height: 54.r,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: isDark ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(Icons.school_rounded,
                      color: cs.primary, size: 26.r),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DarsCategoryChip(
                          category: course.category, small: true),
                      SizedBox(height: 4.h),
                      Text(
                        course.title,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).hintColor,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              course.arabicTitle,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'naskh',
                fontSize: 12.sp,
                color: kDarsGold.withValues(alpha: 0.70),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              course.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 11.sp,
                color: Theme.of(context).hintColor.withValues(alpha: 0.58),
                height: 1.5,
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                ScholarAvatar(scholar: course.scholar, size: 24),
                SizedBox(width: 6.w),
                Text(
                  course.scholar.name,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10.sp,
                    color: cs.primary.withValues(alpha: 0.70),
                  ),
                ),
                const Spacer(),
                Text(
                  '${course.lessonCount} lessons',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10.sp,
                    color: Theme.of(context).hintColor.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
            if (course.progressPercent > 0) ...[
              SizedBox(height: 10.h),
              DarsProgressBar(
                value: course.progressPercent,
                height: 5,
                showLabel: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DarsCourseDetailScreen
// ─────────────────────────────────────────────────────────────────────────────

class DarsCourseDetailScreen extends StatelessWidget {
  final DarsCourse course;
  const DarsCourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = DarsController.instance;
    final lessons = ctrl.getCourseLessons(course.id);

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
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180.h,
                pinned: true,
                backgroundColor: cs.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white),
                  onPressed: Get.back,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: cs.primary,
                    padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        DarsCategoryChip(
                            category: course.category, small: true),
                        SizedBox(height: 6.h),
                        Text(
                          course.title,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${course.lessonCount} lessons · ${course.scholar.name}',
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 11.sp,
                            color: Colors.white.withValues(alpha: 0.70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 80.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Progress
                    Obx(() {
                      final c = ctrl.state.courses
                          .firstWhereOrNull((c) => c.id == course.id);
                      final p = c?.progressPercent ?? course.progressPercent;
                      if (p == 0) return const SizedBox.shrink();
                      return Column(
                        children: [
                          DarsProgressBar(value: p, height: 6, showLabel: true),
                          SizedBox(height: 14.h),
                        ],
                      );
                    }),

                    // Description
                    Text(
                      'About this Course',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      course.description,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 12.sp,
                        color: Theme.of(context)
                            .hintColor
                            .withValues(alpha: 0.65),
                        height: 1.7,
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // Lessons
                    DarsSectionHeader(
                      title: 'Lessons',
                      arabicTitle: 'الدروس',
                      icon: Icons.list_rounded,
                    ),
                    if (lessons.isEmpty)
                      const DarsEmptyState(
                        title: 'No Lessons Yet',
                        subtitle: 'Lessons will appear here.',
                        icon: Icons.library_books_rounded,
                      )
                    else
                      ...lessons.asMap().entries.map(
                            (e) => _CourseLessonTile(
                          index: e.key + 1,
                          dars: e.value,
                          ctrl: ctrl,
                          cs: cs,
                          isDark: isDark,
                        ),
                      ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CourseLessonTile extends StatelessWidget {
  final int index;
  final Dars dars;
  final DarsController ctrl;
  final ColorScheme cs;
  final bool isDark;
  const _CourseLessonTile(
      {required this.index,
      required this.dars,
      required this.ctrl,
      required this.cs,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    final prog = ctrl.getProgress(dars.id);
    final isCompleted = prog?.isCompleted ?? false;

    return GestureDetector(
      onTap: () => Get.to(() => DarsDetailScreen(dars: dars)),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isCompleted
                ? kDarsGreen.withValues(alpha: 0.22)
                : cs.primary.withValues(alpha: isDark ? 0.09 : 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: isCompleted
                    ? kDarsGreen.withValues(alpha: 0.14)
                    : cs.primary.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? Icon(Icons.check_rounded,
                        color: kDarsGreen, size: 14.r)
                    : Text(
                        '$index',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        ),
                      ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dars.title,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      DarsTypeBadge(type: dars.type),
                      SizedBox(width: 6.w),
                      Text(
                        dars.durationFormatted,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 9.sp,
                          color: Theme.of(context)
                              .hintColor
                              .withValues(alpha: 0.40),
                        ),
                      ),
                    ],
                  ),
                  if (prog != null && prog.percentComplete > 0 && !isCompleted)
                    Padding(
                      padding: EdgeInsets.only(top: 5.h),
                      child: DarsProgressBar(
                          value: prog.percentComplete, height: 3),
                    ),
                ],
              ),
            ),
            Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.play_arrow_rounded,
              color: isCompleted
                  ? kDarsGreen
                  : cs.primary.withValues(alpha: 0.45),
              size: 20.r,
            ),
          ],
        ),
      ),
    );
  }
}
