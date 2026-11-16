// ─────────────────────────────────────────────────────────────────────────────
// profile_section_card.dart  — Reusable section card & tile for Profile
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'profile_header.dart' show kGold;

// ─────────────────────────────────────────────────────────────────────────────
// ProfileSectionCard
// ─────────────────────────────────────────────────────────────────────────────

class ProfileSectionCard extends StatelessWidget {
  final String title;
  final String? arabicTitle;
  final IconData titleIcon;
  final List<Widget> children;
  final Color? iconColor;

  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.titleIcon,
    required this.children,
    this.arabicTitle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = iconColor ?? cs.primary;

    final cardColor   = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.055);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.28)
        : Colors.black.withValues(alpha: 0.038);
    final textColor   = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section label ───────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(left: 2.w, bottom: 10.h),
          child: Row(
            children: [
              // Gold accent bar
              Container(
                width: 3.5.w,
                height: 28.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [kGold, accent],
                  ),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(width: 10.w),

              // Icon badge
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(11.r),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.22),
                    width: 1,
                  ),
                ),
                child: Icon(titleIcon, color: accent, size: 18.r),
              ),
              SizedBox(width: 10.w),

              // Labels
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: 0.1,
                      ),
                    ),
                    if (arabicTitle != null)
                      Text(
                        arabicTitle!,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'naskh',
                          fontSize: 11.sp,
                          color: kGold.withValues(alpha: isDark ? 0.70 : 0.60),
                          height: 1.2,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Card body ───────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Column(
              children: children
                  .asMap()
                  .entries
                  .map(
                    (e) => Column(
                      children: [
                        e.value,
                        if (e.key < children.length - 1)
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            indent: 60.w,
                            endIndent: 16.w,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.055)
                                : Colors.black.withValues(alpha: 0.055),
                          ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ProfileTile  — Reusable list row
// ─────────────────────────────────────────────────────────────────────────────

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBg;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    final cs          = Theme.of(context).colorScheme;
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final color       = iconColor ?? cs.primary;
    final bg          = iconBg ?? color.withValues(alpha: isDark ? 0.17 : 0.09);
    final titleColor  = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor    = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.40);
    final chevron     = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.22);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      splashColor: color.withValues(alpha: 0.06),
      highlightColor: color.withValues(alpha: 0.03),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(13.r),
                border: Border.all(
                  color: color.withValues(alpha: isDark ? 0.22 : 0.12),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: color, size: 20.r),
            ),

            SizedBox(width: 14.w),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 11.5.sp,
                        color: subColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Trailing or chevron
            trailing ??
                Icon(Icons.chevron_right_rounded, color: chevron, size: 20.r),
          ],
        ),
      ),
    );
  }
}
