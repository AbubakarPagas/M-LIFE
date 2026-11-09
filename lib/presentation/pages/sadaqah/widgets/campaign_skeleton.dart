// ─────────────────────────────────────────────────────────────────────────────
// campaign_skeleton.dart  —  shimmer loading placeholder for campaign cards.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class CampaignSkeleton extends StatelessWidget {
  const CampaignSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final high = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: high,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        shrinkWrap: true,
        separatorBuilder: (_, __) => SizedBox(height: 14.h),
        itemBuilder: (_, __) => _SkeletonCard(),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image area
          Container(
            height: 110.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _block(w: 180.w, h: 14.h),
                SizedBox(height: 8.h),
                _block(w: double.infinity, h: 10.h),
                SizedBox(height: 4.h),
                _block(w: 140.w, h: 10.h),
                SizedBox(height: 10.h),
                _block(w: double.infinity, h: 8.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _block({required double w, required double h}) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6.r),
    ),
  );
}
