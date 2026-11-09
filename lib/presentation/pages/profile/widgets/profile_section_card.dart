import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'profile_header.dart' show kGold;

/// Reusable section card — clean white / dark surface with gold accent.
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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = iconColor ?? cs.primary;

    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.06);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.30)
        : Colors.black.withValues(alpha: 0.04);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section label ─────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
          child: Row(
            children: [
              // Left accent bar
              Container(
                width: 3.5.w,
                height: 26.h,
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
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.20),
                    width: 1,
                  ),
                ),
                child: Icon(titleIcon, color: accent, size: 17.r),
              ),
              SizedBox(width: 10.w),

              // Text labels
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Card body ─────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 16,
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
                            indent: 58.w,
                            endIndent: 16.w,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.06),
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

// ── Reusable list tile ─────────────────────────────────────────────────────────

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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = iconColor ?? cs.primary;
    final bg = iconBg ?? color.withValues(alpha: isDark ? 0.18 : 0.10);
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = (isDark ? Colors.white : Colors.black).withValues(
      alpha: 0.42,
    );
    final chevronColor = (isDark ? Colors.white : Colors.black).withValues(
      alpha: 0.25,
    );

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
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: color.withValues(alpha: isDark ? 0.20 : 0.12),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: color, size: 19.r),
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
                        fontSize: 12.sp,
                        color: subtitleColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Trailing or chevron
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: chevronColor,
                  size: 20.r,
                ),
          ],
        ),
      ),
    );
  }
}
