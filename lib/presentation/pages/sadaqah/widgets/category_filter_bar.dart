// ─────────────────────────────────────────────────────────────────────────────
// category_filter_bar.dart — scrollable category chip row
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/sadaqah_controller.dart';
import '../models/campaign_model.dart';

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = SadaqahController.instance;
    final primary = Theme.of(context).primaryColor;

    return Obx(() {
      final selected = ctrl.selectedCategory.value;

      return SizedBox(
        height: 36.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: CampaignCategory.values.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (_, i) {
            final cat = CampaignCategory.values[i];
            final isSelected = cat == selected;

            return GestureDetector(
              onTap: () => ctrl.setCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: isSelected ? primary : primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? primary
                        : primary.withValues(alpha: 0.25),
                    width: 1.1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (cat != CampaignCategory.all) ...[
                      Text(
                        CampaignCategory.emoji(cat),
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      SizedBox(width: 4.w),
                    ],
                    Text(
                      cat,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontFamily: 'kufi',
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected ? Colors.white : primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
