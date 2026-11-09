// ─────────────────────────────────────────────────────────────────────────────
// ZakatGeometricPainter — eight-pointed star pattern (Islamic motif)
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:flutter/material.dart';

class ZakatGeometricPainter extends CustomPainter {
  final Color color;
  final double opacity;

  const ZakatGeometricPainter({required this.color, this.opacity = 0.05});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    const spacing = 50.0;
    const r = 18.0;
    const points = 8;
    const innerR = r * 0.42;

    for (double x = -spacing / 2; x < size.width + spacing; x += spacing) {
      for (double y = -spacing / 2; y < size.height + spacing; y += spacing) {
        final path = Path();
        bool first = true;
        for (int i = 0; i < points * 2; i++) {
          final angle = i * math.pi / points - math.pi / 2;
          final rad = i.isEven ? r : innerR;
          final px = x + rad * math.cos(angle);
          final py = y + rad * math.sin(angle);
          if (first) {
            path.moveTo(px, py);
            first = false;
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(ZakatGeometricPainter old) =>
      old.color != color || old.opacity != opacity;
}
