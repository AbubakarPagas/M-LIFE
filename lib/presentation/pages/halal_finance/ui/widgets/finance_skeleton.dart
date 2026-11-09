// ─────────────────────────────────────────────────────────────────────────────
// FinanceSkeleton — shimmer loading placeholder
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class FinanceSkeleton extends StatelessWidget {
  const FinanceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? cs.primary.withValues(alpha: 0.12)
        : const Color(0xFFE0E0E0);
    final highlightColor = isDark
        ? cs.primary.withValues(alpha: 0.22)
        : const Color(0xFFF5F5F5);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero card skeleton
          _ShimmerBox(width: double.infinity, height: 140.h, radius: 22.r),
          SizedBox(height: 14.h),
          // Search bar
          _ShimmerBox(width: double.infinity, height: 46.h, radius: 14.r),
          SizedBox(height: 12.h),
          // Category chips
          Row(
            children: List.generate(
              5,
              (i) => Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _ShimmerBox(width: 70.w, height: 34.h, radius: 20.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Tips list
          ...List.generate(
            4,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _ShimmerBox(
                width: double.infinity,
                height: 110.h,
                radius: 18.r,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
