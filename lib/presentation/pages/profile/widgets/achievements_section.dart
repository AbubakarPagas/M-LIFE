import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/profile_controller.dart';
import 'profile_header.dart' show kGold, kGoldLight;
import 'profile_section_card.dart';

// ── Achievement data model ─────────────────────────────────────────────────────

class _AchievementData {
  final String emoji;
  final String title;
  final String arabicTitle;
  final String desc;
  final bool Function(ProfileController) condition;

  const _AchievementData({
    required this.emoji,
    required this.title,
    required this.arabicTitle,
    required this.desc,
    required this.condition,
  });
}

const _achievements = [
  _AchievementData(
    emoji: '📖',
    title: 'First Recitation',
    arabicTitle: 'أول تلاوة',
    desc: 'Completed first Quran session',
    condition: _quranOne,
  ),
  _AchievementData(
    emoji: '🌙',
    title: 'Night Worshipper',
    arabicTitle: 'القيّام',
    desc: '7-day prayer streak',
    condition: _streak7,
  ),
  _AchievementData(
    emoji: '☪️',
    title: 'Dhikr Master',
    arabicTitle: 'كثير الذكر',
    desc: '1,000 Tasbih completed',
    condition: _tasbih1k,
  ),
  _AchievementData(
    emoji: '🕌',
    title: 'Quran Scholar',
    arabicTitle: 'طالب علم',
    desc: 'Completed 10 Surahs',
    condition: _surah10,
  ),
  _AchievementData(
    emoji: '🌟',
    title: 'Ramadan Warrior',
    arabicTitle: 'مجاهد رمضان',
    desc: 'Active during Ramadan',
    condition: _never,
  ),
  _AchievementData(
    emoji: '🏅',
    title: 'Consistent',
    arabicTitle: 'المواظب',
    desc: '30-day prayer streak',
    condition: _streak30,
  ),
];

bool _quranOne(ProfileController c) => c.quranSessions.value >= 1;
bool _streak7(ProfileController c) => c.prayerStreak.value >= 7;
bool _tasbih1k(ProfileController c) => c.tasbihAllTime >= 1000;
bool _surah10(ProfileController c) => c.surahsCompleted.value >= 10;
bool _never(ProfileController c) => false;
bool _streak30(ProfileController c) => c.prayerStreak.value >= 30;

// ── Section widget ─────────────────────────────────────────────────────────────

class AchievementsSection extends StatelessWidget {
  const AchievementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileController>();

    return ProfileSectionCard(
      title: 'Achievements',
      arabicTitle: 'الإنجازات',
      titleIcon: Icons.emoji_events_rounded,
      iconColor: kGold,
      children: [
        Padding(
          padding: EdgeInsets.all(16.r),
          child: Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: _achievements
                .map((a) => _BadgeCard(data: a, unlocked: a.condition(ctrl)))
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ── Badge card ────────────────────────────────────────────────────────────────

class _BadgeCard extends StatelessWidget {
  final _AchievementData data;
  final bool unlocked;

  const _BadgeCard({required this.data, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = (MediaQuery.sizeOf(context).width - 88.w) / 2;

    final cardColor = isDark
        ? const Color(0xFF252525)
        : const Color(0xFFF7F7F7);
    final borderColor = unlocked
        ? kGold.withValues(alpha: isDark ? 0.45 : 0.38)
        : (isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.06));
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final descColor = (isDark ? Colors.white : Colors.black).withValues(
      alpha: 0.40,
    );

    return AnimatedOpacity(
      opacity: unlocked ? 1.0 : 0.40,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: w,
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          gradient: unlocked
              ? LinearGradient(
                  colors: [
                    kGold.withValues(alpha: isDark ? 0.14 : 0.10),
                    kGoldLight.withValues(alpha: isDark ? 0.07 : 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: unlocked ? null : cardColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: borderColor, width: unlocked ? 1.2 : 1),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: kGold.withValues(alpha: isDark ? 0.15 : 0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.20)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(data.emoji, style: TextStyle(fontSize: 26.sp)),
                const Spacer(),
                if (unlocked)
                  Container(
                    width: 22.r,
                    height: 22.r,
                    decoration: const BoxDecoration(
                      color: kGold,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 13.r,
                    ),
                  )
                else
                  Icon(
                    Icons.lock_outline_rounded,
                    color: (isDark ? Colors.white : Colors.black).withValues(
                      alpha: 0.22,
                    ),
                    size: 17.r,
                  ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              data.title,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              data.arabicTitle,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'naskh',
                fontSize: 13.sp,
                color: kGold.withValues(alpha: isDark ? 0.75 : 0.65),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              data.desc,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 11.sp,
                color: descColor,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
