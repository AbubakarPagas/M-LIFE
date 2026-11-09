// ─────────────────────────────────────────────────────────────────────────────
// DailyTipCard — featured tip at the top of the page
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'finance_card_painter.dart';

const Color _kGold = Color(0xffCDAD80);

class DailyTipCard extends StatelessWidget {
  final String icon;
  final String title;
  final String body;

  const DailyTipCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary,
            cs.primary.withValues(alpha: 0.80),
            cs.primary.withValues(alpha: 0.65),
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: isDark ? 0.30 : 0.22),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: Stack(
          children: [
            // Background pattern
            const Positioned.fill(
              child: CustomPaint(
                painter: FinanceStarPainter(color: Colors.white, opacity: 0.04),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(18.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _kGold.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: _kGold.withValues(alpha: 0.40),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wb_sunny_rounded,
                              color: _kGold,
                              size: 11.r,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Daily Tip',
                              style: TextStyle(
                                fontFamily: 'kufi',
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: _kGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // Icon + title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        icon,
                        style: TextStyle(fontSize: 28.sp, height: 1.0),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  // Body
                  Text(
                    body,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.80),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
