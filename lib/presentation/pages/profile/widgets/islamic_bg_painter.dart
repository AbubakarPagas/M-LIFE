import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Full-page Islamic geometric background painter.
/// Draws nested 8-point star polygons tiled across the canvas,
/// with an optional second layer of inner arabesque rings.
class IslamicBgPainter extends CustomPainter {
  final Color starColor;
  final Color ringColor;
  final double starOpacity;
  final double ringOpacity;
  final double tileSize;

  const IslamicBgPainter({
    required this.starColor,
    required this.ringColor,
    this.starOpacity = 0.055,
    this.ringOpacity = 0.025,
    this.tileSize = 72,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()
      ..color = starColor.withValues(alpha: starOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85;

    final ringPaint = Paint()
      ..color = ringColor.withValues(alpha: ringOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final cols = (size.width / tileSize).ceil() + 2;
    final rows = (size.height / tileSize).ceil() + 2;

    for (int row = -1; row < rows; row++) {
      for (int col = -1; col < cols; col++) {
        final cx = col * tileSize + (row.isOdd ? tileSize / 2 : 0.0);
        final cy = row * tileSize.toDouble();
        final r = tileSize * 0.36;

        _drawStar8(canvas, Offset(cx, cy), r, starPaint);
        // Inner arabesque circle
        canvas.drawCircle(Offset(cx, cy), r * 0.44, ringPaint);
        // Connecting line squares (rotated 45°)
        _drawSquare(canvas, Offset(cx, cy), r * 0.66, ringPaint);
      }
    }
  }

  void _drawStar8(Canvas canvas, Offset c, double r, Paint p) {
    final path = Path();
    const pts = 8;
    final inner = r * 0.42;
    for (int i = 0; i < pts * 2; i++) {
      final angle = (i * math.pi / pts) - math.pi / 2;
      final radius = i.isEven ? r : inner;
      final x = c.dx + radius * math.cos(angle);
      final y = c.dy + radius * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  void _drawSquare(Canvas canvas, Offset c, double r, Paint p) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) + math.pi / 4;
      final x = c.dx + r * math.cos(angle);
      final y = c.dy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(IslamicBgPainter old) =>
      old.starColor != starColor ||
      old.ringColor != ringColor ||
      old.starOpacity != starOpacity;
}

/// Paints a glowing radial halo — used behind the profile avatar area.
class IslamicHaloPainter extends CustomPainter {
  final Color color;
  final double opacity;
  const IslamicHaloPainter({required this.color, this.opacity = 0.18});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.38);
    final paint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
            radius: 0.7,
          ).createShader(
            Rect.fromCircle(center: center, radius: size.width * 0.65),
          );

    canvas.drawCircle(center, size.width * 0.65, paint);
  }

  @override
  bool shouldRepaint(IslamicHaloPainter old) =>
      old.color != color || old.opacity != opacity;
}
