// ─────────────────────────────────────────────────────────────────────────────
// FeedSkeleton — shimmer loading placeholder
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class FeedSkeleton extends StatelessWidget {
  const FeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final base = isDark
        ? cs.primary.withValues(alpha: 0.12)
        : const Color(0xFFE0E0E0);
    final highlight = isDark
        ? cs.primary.withValues(alpha: 0.22)
        : const Color(0xFFF5F5F5);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Box(w: double.infinity, h: 110.h, r: 14.r),
          SizedBox(height: 14.h),
          _Box(w: double.infinity, h: 38.h, r: 20.r),
          SizedBox(height: 16.h),
          ...List.generate(
            5,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      _Box(w: 28.w, h: 20.h, r: 0),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: _Box(w: 12.r, h: 12.r, r: 6.r),
                      ),
                      _Box(w: 2, h: 80.h, r: 0),
                    ],
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _Box(w: double.infinity, h: 110.h, r: 16.r),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  final double w, h, r;
  const _Box({required this.w, required this.h, required this.r});

  @override
  Widget build(BuildContext context) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(r),
    ),
  );
}
