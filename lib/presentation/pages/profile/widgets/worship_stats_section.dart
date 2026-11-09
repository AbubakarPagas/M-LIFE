import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/profile_controller.dart';
import 'profile_header.dart' show kGold, kGreen, kEmerald;
import 'profile_section_card.dart';

class WorshipStatsSection extends StatelessWidget {
  const WorshipStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileController>();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ProfileSectionCard(
      title: 'Worship Statistics',
      arabicTitle: 'إحصائيات العبادة',
      titleIcon: Icons.bar_chart_rounded,
      iconColor: kGreen,
      children: [
        // ── Dhikr progress ─────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
          child: Obx(() {
            final pct = ctrl.dhikrProgress.value;
            final labelColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 9.r,
                          height: 9.r,
                          decoration: const BoxDecoration(
                            color: kEmerald,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Daily Dhikr Progress',
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: kEmerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${(pct * 100).toInt()}%',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: kEmerald,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _ProgressBar(value: pct),
              ],
            );
          }),
        ),

        Divider(
          height: 1,
          thickness: 0.5,
          indent: 16.w,
          endIndent: 16.w,
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.06),
        ),

        // ── Stat grid ──────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.all(16.r),
          child: Obx(
            () => Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                _StatTile(
                  icon: Icons.menu_book_rounded,
                  label: 'Quran Sessions',
                  labelAr: 'جلسات القرآن',
                  value: '${ctrl.quranSessions.value}',
                  color: cs.primary,
                ),
                _StatTile(
                  icon: Icons.library_books_rounded,
                  label: 'Surahs Done',
                  labelAr: 'سور مكتملة',
                  value: '${ctrl.surahsCompleted.value}',
                  color: const Color(0xff6C63FF),
                ),
                _StatTile(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Prayer Streak',
                  labelAr: 'تسلسل الصلاة',
                  value: '${ctrl.prayerStreak.value}d',
                  color: const Color(0xffFF6B35),
                ),
                _StatTile(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Tasbih Total',
                  labelAr: 'مجموع التسبيح',
                  value: _fmt(ctrl.tasbihAllTime),
                  color: kGold,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

// ── Segmented progress bar ─────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final double value;
  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const segments = 10;

    return Row(
      children: List.generate(segments, (i) {
        final filled = (i + 1) / segments <= value;
        return Expanded(
          child: Container(
            height: 10.h,
            margin: EdgeInsets.only(right: i < segments - 1 ? 2.5.w : 0),
            decoration: BoxDecoration(
              color: filled
                  ? kEmerald.withValues(alpha: 0.88)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.07)),
              borderRadius: BorderRadius.horizontal(
                left: i == 0 ? Radius.circular(6.r) : Radius.zero,
                right: i == segments - 1 ? Radius.circular(6.r) : Radius.zero,
              ),
              boxShadow: filled
                  ? [
                      BoxShadow(
                        color: kEmerald.withValues(alpha: 0.32),
                        blurRadius: 5,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

// ── Stat tile ──────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String labelAr;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.labelAr,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = (MediaQuery.sizeOf(context).width - 84.w) / 2;

    final cardColor = isDark
        ? const Color(0xFF252525)
        : const Color(0xFFF7F7F7);
    final labelColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final arabicColor = kGold.withValues(alpha: isDark ? 0.70 : 0.60);

    return Container(
      width: w,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.22 : 0.14),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : color.withValues(alpha: 0.06),
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
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: color, size: 18.r),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1.1,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            labelAr,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'naskh',
              fontSize: 12.sp,
              color: arabicColor,
            ),
          ),
        ],
      ),
    );
  }
}
