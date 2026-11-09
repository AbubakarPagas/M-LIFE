import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/tasbih_controller.dart';
import '../model/dhikr_preset.dart';

class DhikrSelectorCard extends StatelessWidget {
  const DhikrSelectorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TasbihController>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const gold = Color(0xffCDAD80);

    return Container(
      height: 82.h,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: gold.withValues(alpha: 0.25), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: DhikrPreset.defaults.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final dhikr = DhikrPreset.defaults[index];
          return Obx(() {
            final isSelected = ctrl.selectedDhikrIndex.value == index;
            return GestureDetector(
              onTap: () => ctrl.selectDhikr(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            cs.primary,
                            cs.primary.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isSelected
                        ? gold.withValues(alpha: 0.6)
                        : Colors.transparent,
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${dhikr.emoji}  ${dhikr.name}',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : cs.primary,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${dhikr.target}×',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 10.sp,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.75)
                            : gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
