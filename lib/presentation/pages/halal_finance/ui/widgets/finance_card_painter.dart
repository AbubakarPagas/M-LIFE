// ─────────────────────────────────────────────────────────────────────────────
// FinanceCardPainter — subtle star/crescent pattern for card backgrounds
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:flutter/material.dart';

class FinanceStarPainter extends CustomPainter {
  final Color color;
  final double opacity;

  const FinanceStarPainter({required this.color, this.opacity = 0.06});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const spacing = 46.0;
    const r = 14.0;
    const points = 8;
    const innerR = r * 0.40;

    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        final path = Path();
        for (int i = 0; i < points * 2; i++) {
          final angle = i * math.pi / points - math.pi / 2;
          final rad = i.isEven ? r : innerR;
          final px = x + rad * math.cos(angle);
          final py = y + rad * math.sin(angle);
          if (i == 0) {
            path.moveTo(px, py);
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
  bool shouldRepaint(FinanceStarPainter old) =>
      old.color != color || old.opacity != opacity;
}
