import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paints a subtle Islamic geometric star-polygon tile across the background.
class GeometricPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;

  const GeometricPatternPainter({required this.color, this.opacity = 0.06});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const tileSize = 72.0;
    final cols = (size.width / tileSize).ceil() + 1;
    final rows = (size.height / tileSize).ceil() + 1;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final cx = col * tileSize + (row.isOdd ? tileSize / 2 : 0);
        final cy = row * tileSize;
        _drawStar8(canvas, Offset(cx, cy), tileSize * 0.36, paint);
      }
    }
  }

  void _drawStar8(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const points = 8;
    final innerRadius = radius * 0.42;
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final r = i.isEven ? radius : innerRadius;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Inner decorative ring
    canvas.drawCircle(
      center,
      innerRadius * 0.55,
      paint..style = PaintingStyle.stroke,
    );
    paint.style = PaintingStyle.stroke;
  }

  @override
  bool shouldRepaint(GeometricPatternPainter old) =>
      old.color != color || old.opacity != opacity;
}
