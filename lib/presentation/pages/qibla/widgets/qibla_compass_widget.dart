// ── Qibla Compass Widget ─────────────────────────────────────────────────────
// Islamic-styled compass: gold ring, primary dial, gold needle

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../adhan/widgets/adhan_theme.dart';
import '../controllers/qibla_controller.dart';
import 'qibla_compass_painter.dart';

class QiblaCompassWidget extends StatefulWidget {
  final double size;
  final bool isFullScreen;

  const QiblaCompassWidget({
    super.key,
    this.size = 280,
    this.isFullScreen = false,
  });

  @override
  State<QiblaCompassWidget> createState() => _QiblaCompassWidgetState();
}

class _QiblaCompassWidgetState extends State<QiblaCompassWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(
      begin: 0.97,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QiblaController>();
    final cs = Theme.of(context).colorScheme;
    final size = widget.size;

    return Obx(() {
      final aligned = ctrl.isFacingQibla.value;
      final heading = ctrl.compassHeading.value;
      final qibla = ctrl.qiblaResult.value?.bearing ?? 0.0;
      final compassAngle = ctrl.compassRotationRad;

      return Stack(
        alignment: Alignment.center,
        children: [
          // ── Outer gold glow ring when aligned ──────────────────────────────
          if (aligned)
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Transform.scale(
                scale: _pulseAnim.value,
                child: Container(
                  width: size + 24,
                  height: size + 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: kAdhanGold.withValues(alpha: 0.55),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kAdhanGold.withValues(alpha: 0.25),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Gold gradient outer ring ───────────────────────────────────────
          Container(
            width: size + 16,
            height: size + 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  kAdhanGold.withValues(alpha: 0.40),
                  kAdhanGoldDeep.withValues(alpha: 0.20),
                  kAdhanGold.withValues(alpha: 0.50),
                  kAdhanGoldLight.withValues(alpha: 0.30),
                  kAdhanGold.withValues(alpha: 0.40),
                ],
              ),
            ),
          ),

          // ── Inner compass face background ──────────────────────────────────
          Container(
            width: size + 6,
            height: size + 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.surfaceContainer,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

          // ── Custom-painted compass dial ────────────────────────────────────
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: QiblaCompassPainter(
                compassAngle: compassAngle,
                qiblaAngle: qibla,
                currentHeading: heading,
                isFacingQibla: aligned,
                primaryColor: cs.primary,
                accentColor: kAdhanGold,
              ),
            ),
          ),

          // ── Kaaba centre piece ─────────────────────────────────────────────
          _KaabaCentre(aligned: aligned, cs: cs),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _KaabaCentre extends StatelessWidget {
  final bool aligned;
  final ColorScheme cs;

  const _KaabaCentre({required this.aligned, required this.cs});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QiblaController>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Kaaba icon in a gold-bordered circle
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.surfaceContainer,
            border: Border.all(
              color: aligned ? kAdhanGold : kAdhanGold.withValues(alpha: 0.45),
              width: aligned ? 2.5 : 1.5,
            ),
            boxShadow: aligned
                ? [
                    BoxShadow(
                      color: kAdhanGold.withValues(alpha: 0.30),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Icon(
            Icons.mosque_outlined,
            size: 26,
            color: aligned ? kAdhanGoldDeep : kAdhanGold,
          ),
        ),
        const SizedBox(height: 4),
        // Qibla bearing degrees
        Obx(() {
          final bearing = ctrl.qiblaResult.value?.bearing.round() ?? 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: kAdhanGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kAdhanGold.withValues(alpha: 0.30)),
            ),
            child: Text(
              '$bearing°',
              style: const TextStyle(
                fontFamily: 'kufi',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: kAdhanGoldDeep,
              ),
            ),
          );
        }),
      ],
    );
  }
}
