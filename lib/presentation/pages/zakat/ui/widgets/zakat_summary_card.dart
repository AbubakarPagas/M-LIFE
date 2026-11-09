// ─────────────────────────────────────────────────────────────────────────────
// ZakatSummaryCard — reusable stat card for the dashboard
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ZakatSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? valueColor;
  final String? subtitle;

  const ZakatSummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.valueColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: iconColor, size: 17.r),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 11.sp,
                    color: theme.hintColor.withValues(alpha: 0.55),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: valueColor ?? theme.hintColor,
              height: 1.2,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 3.h),
            Text(
              subtitle!,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 10.sp,
                color: theme.hintColor.withValues(alpha: 0.40),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
