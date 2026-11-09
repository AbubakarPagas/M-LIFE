import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/tasbih_controller.dart';
import 'progress_ring_painter.dart';

class CounterArea extends StatefulWidget {
  const CounterArea({super.key});

  @override
  State<CounterArea> createState() => _CounterAreaState();
}

class _CounterAreaState extends State<CounterArea>
    with SingleTickerProviderStateMixin {
  late AnimationController _beadAnim;

  @override
  void initState() {
    super.initState();
    _beadAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _beadAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TasbihController>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final gold = const Color(0xffCDAD80);
    final ringSize = 260.0.r;

    return Obx(() {
      final progress = ctrl.progress;
      final isCompleted = ctrl.isCompleted.value;

      return SizedBox(
        width: ringSize,
        height: ringSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Geometric glow behind ring ──────────────────────────────
            Container(
              width: ringSize,
              height: ringSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    cs.primary.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  radius: 0.7,
                ),
              ),
            ),

            // ── Progress ring ───────────────────────────────────────────
            AnimatedBuilder(
              animation: ctrl.animController,
              builder: (_, __) => CustomPaint(
                size: Size(ringSize, ringSize),
                painter: ProgressRingPainter(
                  progress: progress,
                  trackColor: cs.primary.withValues(alpha: 0.12),
                  progressColor: isCompleted ? gold : cs.primary,
                  glowColor: isCompleted ? gold : cs.primary,
                  strokeWidth: 10.r,
                ),
              ),
            ),

            // ── Floating bead dots around the ring ─────────────────────
            if (progress > 0)
              AnimatedBuilder(
                animation: _beadAnim,
                builder: (_, __) => CustomPaint(
                  size: Size(ringSize, ringSize),
                  painter: _BeadDotsPainter(
                    progress: progress,
                    angle: _beadAnim.value * 2 * math.pi,
                    color: isCompleted ? gold : cs.primary,
                    ringRadius: (ringSize - 10.r) / 2,
                  ),
                ),
              ),

            // ── Inner content ───────────────────────────────────────────
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Arabic text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    ctrl.currentDhikr.arabic,
                    key: ValueKey(ctrl.selectedDhikrIndex.value),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'naskh',
                      fontSize: 18.sp,
                      color: gold,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: 6.h),

                // Counter number
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Text(
                    '${ctrl.count.value}',
                    key: ValueKey(ctrl.count.value),
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 62.sp,
                      fontWeight: FontWeight.w900,
                      color: isCompleted ? gold : theme.hintColor,
                      height: 1.0,
                      shadows: [
                        Shadow(
                          color: isCompleted
                              ? gold.withValues(alpha: 0.4)
                              : cs.primary.withValues(alpha: 0.2),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 4.h),

                // Target label
                Text(
                  'of ${ctrl.target}',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13.sp,
                    color: theme.hintColor.withValues(alpha: 0.5),
                    letterSpacing: 0.5,
                  ),
                ),

                SizedBox(height: 4.h),

                // Completed badge
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: isCompleted
                      ? Container(
                          key: const ValueKey('done'),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: gold.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: gold.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '✓  Completed',
                            style: TextStyle(
                              fontFamily: 'kufi',
                              fontSize: 11.sp,
                              color: gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : SizedBox(key: const ValueKey('empty'), height: 20.h),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

/// Paints small bead circles that trail along the progress arc.
class _BeadDotsPainter extends CustomPainter {
  final double progress;
  final double angle;
  final Color color;
  final double ringRadius;

  const _BeadDotsPainter({
    required this.progress,
    required this.angle,
    required this.color,
    required this.ringRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const beadCount = 7;
    final maxAngle = -math.pi / 2 + progress * 2 * math.pi;

    for (int i = 0; i < beadCount; i++) {
      final t = i / beadCount;
      final beadAngle = maxAngle - t * 0.45 + math.sin(angle + t * 2) * 0.04;
      final beadOpacity = (1.0 - t * 0.8).clamp(0.0, 1.0);
      final beadSize = (3.5 - t * 2.5).clamp(0.8, 3.5);

      canvas.drawCircle(
        Offset(
          center.dx + ringRadius * math.cos(beadAngle),
          center.dy + ringRadius * math.sin(beadAngle),
        ),
        beadSize,
        Paint()..color = color.withValues(alpha: beadOpacity * 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(_BeadDotsPainter old) =>
      old.progress != progress || old.angle != angle || old.color != color;
}
