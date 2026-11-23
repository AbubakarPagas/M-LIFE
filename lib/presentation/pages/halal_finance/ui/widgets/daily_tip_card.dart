// ─────────────────────────────────────────────────────────────────────────────
// DailyTipCard — featured daily tip at the top of the finance page
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'finance_card_painter.dart';

const Color _kGold = Color(0xffCDAD80);
const Color _kGoldDeep = Color(0xffB8864E);
const Color _kEmerald = Color(0xff1A5C45);
const Color _kEmeraldLight = Color(0xff2E8B57);

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xff0A1F16),
                  const Color(0xff122B1F),
                  const Color(0xff0D2B1E),
                ]
              : [
                  _kEmerald,
                  _kEmeraldLight,
                  const Color(0xff1A6B4A),
                ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: _kEmerald.withValues(alpha: isDark ? 0.40 : 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: _kGold.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: Stack(
          children: [
            // Geometric background pattern
            const Positioned.fill(
              child: CustomPaint(
                painter: FinanceStarPainter(
                  color: Colors.white,
                  opacity: 0.035,
                ),
              ),
            ),
            // Top-right decorative ring
            Positioned(
              top: -28,
              right: -28,
              child: Container(
                width: 110.r,
                height: 110.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _kGold.withValues(alpha: 0.14),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -10,
              right: -10,
              child: Container(
                width: 60.r,
                height: 60.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _kGold.withValues(alpha: 0.10),
                    width: 1,
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(18.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Badge ─────────────────────────────────────────────────
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _kGold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: _kGold.withValues(alpha: 0.38),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wb_sunny_rounded,
                              color: _kGold,
                              size: 10.r,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              'Tip of the Day',
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
                  SizedBox(height: 14.h),
                  // ── Icon + title ───────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46.r,
                        height: 46.r,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            icon,
                            style: TextStyle(fontSize: 22.sp, height: 1.0),
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // ── Divider ────────────────────────────────────────────────
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _kGold.withValues(alpha: 0.40),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // ── Body text ──────────────────────────────────────────────
                  Text(
                    body,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.78),
                      height: 1.65,
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
