// ─────────────────────────────────────────────────────────────────────────────
// NisabStatusBanner — shows ✅ / ❌ Zakat obligation status
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/zakat_controller.dart';
import '../../data/models/zakat_calculation_model.dart';

class NisabStatusBanner extends StatelessWidget {
  const NisabStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = ZakatController.instance;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final prices = ctrl.metalPrices.value;
      if (prices == null) return const SizedBox.shrink();

      final isObligatory = ctrl.isAboveNisab;
      final nisabMethod = ctrl.selectedNisab;
      final goldNisab = prices.goldNisabValue;
      final silverNisab = prices.silverNisabValue;

      final activeColor = isObligatory
          ? const Color(0xff2E7D32)
          : theme.colorScheme.primary;
      final activeBg = isObligatory
          ? const Color(0xff2E7D32).withValues(alpha: isDark ? 0.18 : 0.08)
          : theme.colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.08);

      return Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: activeBg,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: activeColor.withValues(alpha: 0.30),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: activeColor.withValues(alpha: isDark ? 0.12 : 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status headline ─────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: activeColor.withValues(alpha: isDark ? 0.22 : 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    isObligatory
                        ? Icons.verified_rounded
                        : Icons.info_outline_rounded,
                    color: activeColor,
                    size: 20.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isObligatory
                            ? '✅ Zakat is Obligatory'
                            : '❌ Nisab Not Reached',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: activeColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isObligatory
                            ? 'Your net wealth exceeds the Nisab threshold'
                            : 'Your net wealth is below the Nisab threshold',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 10.5.sp,
                          color: activeColor.withValues(alpha: 0.65),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Divider(color: activeColor.withValues(alpha: 0.15), height: 1),
            SizedBox(height: 12.h),
            // ── Nisab values ────────────────────────────────────────────────
            Row(
              children: [
                _NisabChip(
                  label: 'Gold Nisab',
                  value: ctrl.formatCurrency(goldNisab),
                  sublabel: '85g of gold',
                  isSelected: nisabMethod == NisabMethod.gold,
                  color: const Color(0xffCDAD80),
                ),
                SizedBox(width: 10.w),
                _NisabChip(
                  label: 'Silver Nisab',
                  value: ctrl.formatCurrency(silverNisab),
                  sublabel: '595g of silver',
                  isSelected: nisabMethod == NisabMethod.silver,
                  color: const Color(0xff9E9E9E),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _NisabChip extends StatelessWidget {
  final String label;
  final String value;
  final String sublabel;
  final bool isSelected;
  final Color color;

  const _NisabChip({
    required this.label,
    required this.value,
    required this.sublabel,
    required this.isSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.22 : 0.12)
              : theme.colorScheme.surfaceContainer.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.45)
                : color.withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.circle_outlined,
                  size: 13.r,
                  color: isSelected
                      ? color
                      : theme.hintColor.withValues(alpha: 0.30),
                ),
                SizedBox(width: 5.w),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10.sp,
                    color: isSelected
                        ? color
                        : theme.hintColor.withValues(alpha: 0.50),
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? color
                    : theme.hintColor.withValues(alpha: 0.60),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              sublabel,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 9.sp,
                color: theme.hintColor.withValues(alpha: 0.38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
