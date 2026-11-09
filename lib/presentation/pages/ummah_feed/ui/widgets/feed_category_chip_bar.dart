// ─────────────────────────────────────────────────────────────────────────────
// FeedCategoryChipBar — horizontal scrollable category filter chips
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/feed_post_model.dart';

class FeedCategoryChipBar extends StatelessWidget {
  final FeedCategory selected;
  final ValueChanged<FeedCategory> onSelected;

  const FeedCategoryChipBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 46.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: FeedCategory.values.length,
        separatorBuilder: (_, __) => SizedBox(width: 7.w),
        itemBuilder: (_, i) {
          final cat = FeedCategory.values[i];
          final isSelected = cat == selected;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: isSelected
                  ? cs.primary
                  : cs.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected
                    ? cs.primary
                    : cs.primary.withValues(alpha: 0.14),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(20.r),
                onTap: () => onSelected(cat),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cat.icon,
                        size: 15.r,
                        color: isSelected
                            ? Colors.white
                            : cs.primary.withValues(alpha: 0.55),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        cat.label,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 13.sp,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : cs.primary.withValues(alpha: 0.70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
