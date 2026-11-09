// ─────────────────────────────────────────────────────────────────────────────
// donation_type_toggle.dart — pill toggle for One-Time vs Monthly donations
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/sadaqah_controller.dart';

class DonationTypeToggle extends StatelessWidget {
  const DonationTypeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = SadaqahController.instance;
    final primary = Theme.of(context).primaryColor;

    return Obx(() {
      final isMonthly = ctrl.isMonthly.value;

      return Container(
        height: 42.h,
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: primary.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            _Pill(
              label: 'One-Time',
              icon: Icons.volunteer_activism_rounded,
              isSelected: !isMonthly,
              primaryColor: primary,
              onTap: () => ctrl.setDonationType(false),
            ),
            _Pill(
              label: 'Monthly',
              icon: Icons.autorenew_rounded,
              isSelected: isMonthly,
              primaryColor: primary,
              onTap: () => ctrl.setDonationType(true),
            ),
          ],
        ),
      );
    });
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.all(3.r),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.30),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15.sp,
                color: isSelected ? Colors.white : primaryColor,
              ),
              SizedBox(width: 5.w),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
