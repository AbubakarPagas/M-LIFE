// ─────────────────────────────────────────────────────────────────────────────
// dars_live_screen.dart — Live & upcoming lessons
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/dars_controller.dart';
import '../models/dars_models.dart';
import '../widgets/dars_widgets.dart';

class DarsLiveScreen extends StatelessWidget {
  const DarsLiveScreen({super.key});

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
                _LiveAppBar(cs: cs),
                Expanded(
                  child: Obx(() {
                    final live = ctrl.state.liveDars
                        .where((l) => l.isActive || l.isUpcoming)
                        .toList();
                    final ended = ctrl.state.liveDars
                        .where((l) => l.status == LiveDarsStatus.ended)
                        .toList();

                    if (live.isEmpty && ended.isEmpty) {
                      return const DarsEmptyState(
                        title: 'No Live Lessons',
                        subtitle: 'Check back soon for upcoming live sessions.',
                        icon: Icons.live_tv_rounded,
                      );
                    }

                    return ListView(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
                      children: [
                        if (live.isNotEmpty) ...[
                          const DarsSectionHeader(
                            title: 'Live & Upcoming',
                            arabicTitle: 'مباشر وقادم',
                            icon: Icons.sensors_rounded,
                            color: kDarsLive,
                          ),
                          ...live.map((l) => _LiveCard(live: l, ctrl: ctrl)),
                          SizedBox(height: 14.h),
                        ],
                        if (ended.isNotEmpty) ...[
                          DarsSectionHeader(
                            title: 'Ended Sessions',
                            icon: Icons.history_rounded,
                            color: cs.primary,
                          ),
                          ...ended.map((l) => _LiveCard(live: l, ctrl: ctrl)),
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

class _LiveAppBar extends StatelessWidget {
  final ColorScheme cs;
  const _LiveAppBar({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 12.w, 10.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Icon(
              Icons.arrow_back_rounded,
              color: Theme.of(context).hintColor,
              size: 22.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'البث المباشر',
                  // textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'naskh',
                    fontSize: 12.sp,
                    color: kDarsLive,
                  ),
                ),
                Text(
                  'Live Lessons',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
          const LiveBadge(),
        ],
      ),
    );
  }
}

class _LiveCard extends StatelessWidget {
  final LiveDars live;
  final DarsController ctrl;
  const _LiveCard({required this.live, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = live.isActive;
    final accentColor = isActive ? kDarsLive : cs.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isActive
              ? kDarsLive.withValues(alpha: 0.30)
              : cs.primary.withValues(alpha: isDark ? 0.10 : 0.07),
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: kDarsLive.withValues(alpha: 0.12),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  isActive ? Icons.sensors_rounded : Icons.event_rounded,
                  color: accentColor,
                  size: 22.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isActive)
                      Padding(
                        padding: EdgeInsets.only(bottom: 3.h),
                        child: const LiveBadge(),
                      ),
                    Text(
                      live.title,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    Text(
                      live.arabicTitle,
                      // textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'naskh',
                        fontSize: 11.sp,
                        color: kDarsGold.withValues(alpha: 0.70),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Description
          Text(
            live.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 11.sp,
              color: Theme.of(context).hintColor.withValues(alpha: 0.60),
              height: 1.5,
            ),
          ),
          SizedBox(height: 10.h),

          // Scholar + time row
          Row(
            children: [
              ScholarAvatar(scholar: live.scholar, size: 28),
              SizedBox(width: 7.w),
              Text(
                live.scholar.name,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 10.5.sp,
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.people_rounded,
                size: 12.r,
                color: Theme.of(context).hintColor.withValues(alpha: 0.40),
              ),
              SizedBox(width: 3.w),
              Text(
                '${live.registeredCount}',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 10.sp,
                  color: Theme.of(context).hintColor.withValues(alpha: 0.40),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Time display
          _TimeRow(live: live),
          SizedBox(height: 12.h),

          // Action buttons
          Row(
            children: [
              if (isActive)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.sensors_rounded, size: 16.r),
                    label: Text(
                      'Join Live',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDarsLive,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Obx(() {
                    final hasReminder = ctrl.hasLiveReminder(live.id);
                    return OutlinedButton.icon(
                      onPressed: () => ctrl.toggleLiveReminder(live),
                      icon: Icon(
                        hasReminder
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_none_rounded,
                        size: 16.r,
                        color: hasReminder ? kDarsGold : accentColor,
                      ),
                      label: Text(
                        hasReminder ? 'Reminder Set' : 'Set Reminder',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 12.sp,
                          color: hasReminder ? kDarsGold : accentColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: hasReminder
                              ? kDarsGold
                              : accentColor.withValues(alpha: 0.40),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    );
                  }),
                ),
              SizedBox(width: 8.w),
              Container(
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.share_rounded,
                    color: cs.primary,
                    size: 18.r,
                  ),
                  onPressed: () {},
                  padding: EdgeInsets.all(10.r),
                  constraints: BoxConstraints(minWidth: 44.r, minHeight: 44.r),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final LiveDars live;
  const _TimeRow({required this.live});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isActive = live.isActive;
    final fmt = DateFormat('EEE, MMM d · h:mm a');
    final timeStr = fmt.format(live.scheduledAt);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isActive
            ? kDarsLive.withValues(alpha: 0.08)
            : cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.radio_button_on_rounded : Icons.schedule_rounded,
            size: 12.r,
            color: isActive ? kDarsLive : cs.primary.withValues(alpha: 0.65),
          ),
          SizedBox(width: 6.w),
          Text(
            isActive ? 'Live now' : timeStr,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: isActive ? kDarsLive : cs.primary.withValues(alpha: 0.70),
            ),
          ),
          if (live.estimatedDuration != null) ...[
            const Spacer(),
            Text(
              '~${live.estimatedDuration!.inMinutes}min',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 9.5.sp,
                color: Theme.of(context).hintColor.withValues(alpha: 0.40),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
