import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../controller/tasbih_controller.dart';
import '../model/tasbih_session_model.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TasbihController>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Obx(() {
      if (ctrl.history.isEmpty && ctrl.count.value == 0) {
        return _EmptyState(theme: theme);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Daily statistics strip ────────────────────────────────────
          _DailyStatsStrip(ctrl: ctrl, theme: theme, cs: cs),

          SizedBox(height: 16.h),

          // ── Section title ─────────────────────────────────────────────
          if (ctrl.history.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Sessions',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.hintColor,
                    ),
                  ),
                  Text(
                    '${ctrl.history.length} saved',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 11.sp,
                      color: theme.hintColor.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 8.h),

          // ── History list ──────────────────────────────────────────────
          ...ctrl.history
              .take(8)
              .map((session) => _SessionCard(session: session, theme: theme)),
        ],
      );
    });
  }
}

// ─── Daily stats row ─────────────────────────────────────────────────────────

class _DailyStatsStrip extends StatelessWidget {
  final TasbihController ctrl;
  final ThemeData theme;
  final ColorScheme cs;

  const _DailyStatsStrip({
    required this.ctrl,
    required this.theme,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xffCDAD80);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.today_rounded,
            value: '${ctrl.todayTotalCount}',
            label: "Today's Dhikr",
            color: cs.primary,
            theme: theme,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _StatCard(
            icon: Icons.bookmark_rounded,
            value: '${ctrl.todaySessionCount}',
            label: 'Sessions Today',
            color: gold,
            theme: theme,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _StatCard(
            icon: Icons.auto_awesome_rounded,
            value: _formatBig(ctrl.totalAllTimeDhikr),
            label: 'All Time',
            color: const Color(0xff4CAF50),
            theme: theme,
          ),
        ),
      ],
    );
  }

  String _formatBig(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final ThemeData theme;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18.r),
          SizedBox(height: 5.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: theme.hintColor,
              height: 1.1,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 9.sp,
              color: theme.hintColor.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Session card ─────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  final TasbihSession session;
  final ThemeData theme;

  const _SessionCard({required this.session, required this.theme});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TasbihController>();
    final cs = theme.colorScheme;
    const gold = Color(0xffCDAD80);
    final dateStr = DateFormat('d MMM, hh:mm a').format(session.date);
    final isToday = _isToday(session.date);

    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: Colors.red,
          size: 22.r,
        ),
      ),
      onDismissed: (_) => ctrl.deleteSession(session.id),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: session.isCompleted
                ? gold.withValues(alpha: 0.35)
                : cs.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Completion ring
            SizedBox(
              width: 42.r,
              height: 42.r,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: session.completionRate,
                    strokeWidth: 3,
                    backgroundColor: cs.primary.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(
                      session.isCompleted ? gold : cs.primary,
                    ),
                  ),
                  Text(
                    '${(session.completionRate * 100).toInt()}%',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                      color: session.isCompleted ? gold : cs.primary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        session.dhikrName,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.hintColor,
                        ),
                      ),
                      if (isToday) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xff4CAF50,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'Today',
                            style: TextStyle(
                              fontFamily: 'kufi',
                              fontSize: 8.sp,
                              color: const Color(0xff4CAF50),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    session.dhikrArabic,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'naskh',
                      fontSize: 12.sp,
                      color: gold.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),

            // Count & date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${session.totalCount}/${session.targetCount}',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: session.isCompleted ? gold : theme.hintColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 9.sp,
                    color: theme.hintColor.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final ThemeData theme;
  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 28.h),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            size: 40.r,
            color: cs.primary.withValues(alpha: 0.3),
          ),
          SizedBox(height: 10.h),
          Text(
            'No sessions yet',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 14.sp,
              color: theme.hintColor.withValues(alpha: 0.4),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Start counting to see your history here',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 11.sp,
              color: theme.hintColor.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }
}
