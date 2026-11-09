import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/tasbih_controller.dart';

class TapCountButton extends StatelessWidget {
  const TapCountButton({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TasbihController>();
    final cs = Theme.of(context).colorScheme;
    final gold = const Color(0xffCDAD80);

    return Obx(() {
      final isCompleted = ctrl.isCompleted.value;

      return GestureDetector(
        onTap: isCompleted ? null : ctrl.increment,
        child: AnimatedBuilder(
          animation: ctrl.animController,
          builder: (_, child) =>
              Transform.scale(scale: ctrl.animController.value, child: child),
          child: Container(
            width: 160.r,
            height: 160.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isCompleted
                    ? [gold.withValues(alpha: 0.6), gold.withValues(alpha: 0.4)]
                    : [cs.primary, cs.primary.withValues(alpha: 0.75)],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isCompleted ? gold : cs.primary).withValues(
                    alpha: 0.35,
                  ),
                  blurRadius: 28,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: (isCompleted ? gold : cs.primary).withValues(
                    alpha: 0.12,
                  ),
                  blurRadius: 48,
                  spreadRadius: 8,
                ),
              ],
              border: Border.all(
                color: gold.withValues(alpha: isCompleted ? 0.6 : 0.3),
                width: 1.5,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Subtle inner ring
                Container(
                  width: 134.r,
                  height: 134.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                ),

                // Label
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCompleted
                          ? Icons.check_circle_outline_rounded
                          : Icons.touch_app_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 28.r,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      isCompleted ? 'Done' : 'Tap to Count',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.92),
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (!isCompleted) ...[
                      SizedBox(height: 3.h),
                      Text(
                        '${ctrl.remainingCount} remaining',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 9.5.sp,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
