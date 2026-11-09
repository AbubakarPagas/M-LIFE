// ─────────────────────────────────────────────────────────────────────────────
// dars_history_screen.dart — Viewing history + Continue Learning section
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/dars_controller.dart';
import '../models/dars_models.dart';
import '../widgets/dars_widgets.dart';
import 'dars_detail_screen.dart';

class DarsHistoryScreen extends StatelessWidget {
  const DarsHistoryScreen({super.key});

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
                _HistoryAppBar(ctrl: ctrl, cs: cs),
                Expanded(
                  child: Obx(() {
                    final hist = ctrl.state.history;
                    if (hist.isEmpty) {
                      return const DarsEmptyState(
                        title: 'No History Yet',
                        subtitle:
                            'Lessons you watch or listen to will appear here.',
                        icon: Icons.history_rounded,
                      );
                    }

                    final inProgress =
                        hist.where((h) => !h.isCompleted).toList();
                    final completed =
                        hist.where((h) => h.isCompleted).toList();

                    return ListView(
                      padding:
                          EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 80.h),
                      children: [
                        // Continue Learning
                        if (inProgress.isNotEmpty) ...[
                          DarsSectionHeader(
                            title: 'Continue Learning',
                            arabicTitle: 'تابع التعلم',
                            icon: Icons.play_circle_rounded,
                            color: kDarsGreen,
                          ),
                          ...inProgress.map(
                            (h) => _HistoryTile(
                              entry: h,
                              ctrl: ctrl,
                              cs: cs,
                              isDark: isDark,
                            ),
                          ),
                          SizedBox(height: 10.h),
                        ],

                        // Completed
                        if (completed.isNotEmpty) ...[
                          DarsSectionHeader(
                            title: 'Completed',
                            icon: Icons.check_circle_rounded,
                            color: cs.primary,
                          ),
                          ...completed.map(
                            (h) => _HistoryTile(
                              entry: h,
                              ctrl: ctrl,
                              cs: cs,
                              isDark: isDark,
                            ),
                          ),
                        ],
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

class _HistoryAppBar extends StatelessWidget {
  final DarsController ctrl;
  final ColorScheme cs;
  const _HistoryAppBar({required this.ctrl, required this.cs});

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
            'History',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).hintColor,
            ),
          ),
          const Spacer(),
          Obx(() {
            if (ctrl.state.history.isEmpty) return const SizedBox.shrink();
            return GestureDetector(
              onTap: () => _confirmClear(context, ctrl),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: kDarsRed.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w600,
                    color: kDarsRed,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext ctx, DarsController ctrl) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(ctx).colorScheme.secondary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Text('Clear History',
            style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(ctx).hintColor)),
        content: Text(
            'This will remove all viewing history. Continue learning progress will be lost.',
            style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 12.sp,
                color: Theme.of(ctx).hintColor.withValues(alpha: 0.65))),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('Cancel',
                style: TextStyle(
                    fontFamily: 'kufi',
                    color: Theme.of(ctx).colorScheme.primary)),
          ),
          TextButton(
            onPressed: () {
              ctrl.clearHistory();
              Get.back();
            },
            child: Text('Clear',
                style: TextStyle(fontFamily: 'kufi', color: kDarsRed)),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final DarsHistoryEntry entry;
  final DarsController ctrl;
  final ColorScheme cs;
  final bool isDark;
  const _HistoryTile(
      {required this.entry,
      required this.ctrl,
      required this.cs,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    final dars = ctrl.getDarsById(entry.darsId);
    final prog = ctrl.getProgress(entry.darsId);
    final dateFmt = DateFormat('MMM d, h:mm a');

    return GestureDetector(
      onTap: () {
        if (dars != null) Get.to(() => DarsDetailScreen(dars: dars));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(11.r),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: entry.isCompleted
                ? cs.primary.withValues(alpha: isDark ? 0.10 : 0.07)
                : kDarsGreen.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color: entry.isCompleted
                        ? cs.primary.withValues(alpha: 0.09)
                        : kDarsGreen.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    entry.isCompleted
                        ? Icons.check_circle_rounded
                        : (entry.darsType == DarsType.video
                            ? Icons.play_circle_rounded
                            : Icons.headphones_rounded),
                    color: entry.isCompleted ? cs.primary : kDarsGreen,
                    size: 20.r,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.darsTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        entry.scholarName,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 10.sp,
                          color: cs.primary.withValues(alpha: 0.60),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      dateFmt.format(entry.watchedAt),
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 9.sp,
                        color: Theme.of(context)
                            .hintColor
                            .withValues(alpha: 0.35),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    GestureDetector(
                      onTap: () => ctrl.removeHistoryEntry(entry.darsId),
                      child: Icon(Icons.close_rounded,
                          size: 14.r,
                          color: Theme.of(context)
                              .hintColor
                              .withValues(alpha: 0.30)),
                    ),
                  ],
                ),
              ],
            ),
            if (prog != null && prog.percentComplete > 0 && !entry.isCompleted) ...[
              SizedBox(height: 8.h),
              DarsProgressBar(
                value: prog.percentComplete,
                color: kDarsGreen,
                height: 4,
                showLabel: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
