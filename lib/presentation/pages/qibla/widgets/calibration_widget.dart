// ── Calibration Widget ───────────────────────────────────────────────────────
// Islamic gold palette: orange for warning, gold border, naskh hint text

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../adhan/widgets/adhan_theme.dart';

class CalibrationWidget extends StatefulWidget {
  const CalibrationWidget({super.key});

  @override
  State<CalibrationWidget> createState() => _CalibrationWidgetState();
}

class _CalibrationWidgetState extends State<CalibrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.linear);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kAdhanGold.withValues(alpha: 0.40)),
        boxShadow: [
          BoxShadow(
            color: kAdhanGold.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated figure-8 icon
          SizedBox(
            width: 52,
            height: 52,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => CustomPaint(
                painter: _Figure8Painter(
                  progress: _anim.value,
                  color: kAdhanGold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'معايرة البوصلة',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'naskh',
                    fontSize: 14,
                    color: kAdhanGoldDeep,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'calibrationInstruction'.tr.isEmpty
                      ? 'Move your phone in a figure-8 to calibrate'
                      : 'calibrationInstruction'.tr,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10,
                    color: kAdhanGoldDeep.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Figure8Painter extends CustomPainter {
  final double progress;
  final Color color;
  const _Figure8Painter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rx = size.width * 0.30;
    final ry = size.height * 0.20;

    final pathPaint = Paint()
      ..color = color.withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i <= 360; i++) {
      final t = i * math.pi / 180;
      final x = center.dx + rx * math.sin(t);
      final y = center.dy + ry * math.sin(2 * t) / 2;
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    canvas.drawPath(path, pathPaint);

    // Animated dot
    final t = progress * 2 * math.pi;
    final dx = center.dx + rx * math.sin(t);
    final dy = center.dy + ry * math.sin(2 * t) / 2;

    canvas.drawCircle(Offset(dx, dy), 5, Paint()..color = color);
    canvas.drawCircle(
      Offset(dx, dy),
      5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_Figure8Painter old) => old.progress != progress;
}
