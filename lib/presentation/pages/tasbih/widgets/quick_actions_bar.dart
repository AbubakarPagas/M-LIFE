import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/toast/islamic_toast.dart';
import '../controller/tasbih_controller.dart';

class QuickActionsBar extends StatelessWidget {
  const QuickActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TasbihController>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const gold = Color(0xffCDAD80);

    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Reset button ─────────────────────────────────────────────────
          _ActionChip(
            icon: Icons.refresh_rounded,
            label: 'Reset',
            color: cs.primary,
            onTap: () => _showResetDialog(context, ctrl),
          ),

          SizedBox(width: 10.w),

          // ── Save session button ──────────────────────────────────────────
          _ActionChip(
            icon: Icons.save_alt_rounded,
            label: 'Save',
            color: gold,
            onTap: ctrl.count.value > 0
                ? () async {
                    await ctrl.saveSession();
                    _showSavedSnackbar(context, cs);
                  }
                : null,
          ),

          SizedBox(width: 10.w),

          // ── Vibration toggle ─────────────────────────────────────────────
          _ActionChip(
            icon: ctrl.vibrationEnabled.value
                ? Icons.vibration_rounded
                : Icons.phone_android_rounded,
            label: ctrl.vibrationEnabled.value ? 'Vibrate' : 'Silent',
            color: ctrl.vibrationEnabled.value
                ? const Color(0xff4CAF50)
                : theme.hintColor.withValues(alpha: 0.5),
            onTap: ctrl.toggleVibration,
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, TasbihController ctrl) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const gold = Color(0xffCDAD80);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cs.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: gold.withValues(alpha: 0.3), width: 1),
        ),
        title: Text(
          'Reset Counter',
          style: TextStyle(
            fontFamily: 'kufi',
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: theme.hintColor,
          ),
        ),
        content: Text(
          'Would you like to save the current session before resetting?',
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 13.sp,
            color: theme.hintColor.withValues(alpha: 0.75),
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ctrl.reset(save: false);
            },
            child: Text(
              'Reset only',
              style: TextStyle(
                fontFamily: 'kufi',
                color: cs.primary.withValues(alpha: 0.6),
                fontSize: 13.sp,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
            onPressed: () {
              Navigator.pop(context);
              ctrl.reset(save: true);
            },
            child: Text(
              'Save & Reset',
              style: TextStyle(
                fontFamily: 'kufi',
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSavedSnackbar(BuildContext context, ColorScheme cs) {
    IslamicToast.show(
      context,
      message: 'Session saved successfully',
      arabicMessage: 'تم حفظ الجلسة بنجاح',
      type: IslamicToastType.success,
      duration: const Duration(seconds: 2),
    );
  }
}

// ─── Reusable action chip ─────────────────────────────────────────────────────

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16.r),
              SizedBox(width: 5.w),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
