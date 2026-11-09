import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'adhan_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// IslamicPatternPainter
// Draws a layered Islamic geometric background:
//   • Large tiling 8-pointed star lattice (gold outlines)
//   • Inner connecting squares rotated 45°
//   • Fine arabesque diamond grid
//   • Radial shimmer dots at tile intersections
// ─────────────────────────────────────────────────────────────────────────────

class IslamicPatternPainter extends CustomPainter {
  final double opacity;
  final Color color;
  const IslamicPatternPainter({
    this.opacity = 0.07,
    this.color = AdhanColors.gold,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ── Layer 1: large 8-pointed star grid ──────────────────────────────────
    final starPaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    // ── Layer 2: inner octagon rings ─────────────────────────────────────────
    final ringPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // ── Layer 3: connecting diamond lines ────────────────────────────────────
    final diamondPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;

    // ── Layer 4: accent dots at intersections ────────────────────────────────
    final dotPaint = Paint()
      ..color = color.withValues(alpha: opacity * 1.4)
      ..style = PaintingStyle.fill;

    const tileW = 72.0;
    const tileH = 72.0;
    final cols = (size.width / tileW).ceil() + 2;
    final rows = (size.height / tileH).ceil() + 2;

    for (int row = -1; row < rows; row++) {
      for (int col = -1; col < cols; col++) {
        // Hexagonal offset for denser packing
        final cx = col * tileW + (row.isOdd ? tileW / 2 : 0.0);
        final cy = row * tileH.toDouble();
        final center = Offset(cx, cy);
        const r = tileW * 0.36;

        // 8-pointed star
        _draw8Star(canvas, starPaint, center, r);

        // Inner octagon ring
        _drawOctagon(canvas, ringPaint, center, r * 0.56);

        // Rotated square (connecting lines)
        _drawSquare(canvas, diamondPaint, center, r * 0.68);

        // Small diamond at center
        _drawSquare(canvas, diamondPaint, center, r * 0.22);

        // Intersection dot
        canvas.drawCircle(center, 1.6, dotPaint);
      }
    }

    // ── Corner radial halos ───────────────────────────────────────────────────
    _paintCornerHalo(canvas, size, Offset.zero, opacity * 2.5);
    _paintCornerHalo(
      canvas,
      size,
      Offset(size.width, size.height),
      opacity * 1.8,
    );
  }

  void _draw8Star(Canvas canvas, Paint p, Offset c, double r) {
    const pts = 8;
    final inner = r * 0.42;
    final path = Path();
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

  void _drawOctagon(Canvas canvas, Paint p, Offset c, double r) {
    const pts = 8;
    final path = Path();
    for (int i = 0; i < pts; i++) {
      final angle = (i * 2 * math.pi / pts) - math.pi / 8;
      final x = c.dx + r * math.cos(angle);
      final y = c.dy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  void _drawSquare(Canvas canvas, Paint p, Offset c, double r) {
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

  void _paintCornerHalo(Canvas canvas, Size size, Offset corner, double op) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AdhanColors.emeraldGlow.withValues(alpha: op.clamp(0, 0.15)),
          Colors.transparent,
        ],
        radius: 0.7,
      ).createShader(Rect.fromCircle(center: corner, radius: size.width * 0.5));
    canvas.drawCircle(corner, size.width * 0.5, paint);
  }

  @override
  bool shouldRepaint(covariant IslamicPatternPainter old) =>
      old.opacity != opacity || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// IslamicPatternBackground — ready-to-use widget
// ─────────────────────────────────────────────────────────────────────────────

class IslamicPatternBackground extends StatelessWidget {
  final double opacity;
  final Color color;
  const IslamicPatternBackground({
    this.opacity = 0.07,
    this.color = AdhanColors.gold,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: IslamicPatternPainter(opacity: opacity, color: color),
      child: const SizedBox.expand(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// IslamicMosqueHorizon — decorative mosque silhouette at the bottom of header
// ─────────────────────────────────────────────────────────────────────────────

class IslamicMosqueSilhouettePainter extends CustomPainter {
  final Color color;
  final double opacity;
  const IslamicMosqueSilhouettePainter({
    required this.color,
    this.opacity = 0.12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Ground base
    final path = Path()..moveTo(0, h);

    // Left minaret
    path
      ..lineTo(0, h * 0.55)
      ..lineTo(w * 0.04, h * 0.55)
      ..lineTo(w * 0.04, h * 0.22)
      ..quadraticBezierTo(w * 0.06, h * 0.08, w * 0.08, h * 0.08)
      ..quadraticBezierTo(w * 0.10, h * 0.08, w * 0.10, h * 0.22)
      ..lineTo(w * 0.10, h * 0.55)
      // Left side buildings
      ..lineTo(w * 0.18, h * 0.55)
      ..lineTo(w * 0.18, h * 0.42)
      ..lineTo(w * 0.24, h * 0.42)
      ..lineTo(w * 0.24, h * 0.55)
      // Main dome base
      ..lineTo(w * 0.30, h * 0.55)
      ..lineTo(w * 0.30, h * 0.38)
      // Main dome — large arch
      ..quadraticBezierTo(w * 0.34, h * 0.10, w * 0.50, h * 0.05)
      ..quadraticBezierTo(w * 0.66, h * 0.10, w * 0.70, h * 0.38)
      ..lineTo(w * 0.70, h * 0.55)
      // Right side buildings
      ..lineTo(w * 0.76, h * 0.55)
      ..lineTo(w * 0.76, h * 0.42)
      ..lineTo(w * 0.82, h * 0.42)
      ..lineTo(w * 0.82, h * 0.55)
      // Right minaret
      ..lineTo(w * 0.90, h * 0.55)
      ..lineTo(w * 0.90, h * 0.22)
      ..quadraticBezierTo(w * 0.92, h * 0.08, w * 0.94, h * 0.08)
      ..quadraticBezierTo(w * 0.96, h * 0.08, w * 0.96, h * 0.22)
      ..lineTo(w * 0.96, h * 0.55)
      ..lineTo(w, h * 0.55)
      ..lineTo(w, h)
      ..close();

    canvas.drawPath(path, paint);

    // Crescent on main dome tip
    _drawCrescent(canvas, paint, Offset(w * 0.50, h * 0.02), h * 0.040);

    // Small crescents on minarets
    _drawCrescent(canvas, paint, Offset(w * 0.08, h * 0.04), h * 0.024);
    _drawCrescent(canvas, paint, Offset(w * 0.94, h * 0.04), h * 0.024);
  }

  void _drawCrescent(Canvas canvas, Paint p, Offset center, double r) {
    final path = Path()..addOval(Rect.fromCircle(center: center, radius: r));
    final hole = Path()
      ..addOval(
        Rect.fromCircle(
          center: center.translate(r * 0.35, -r * 0.2),
          radius: r * 0.72,
        ),
      );
    canvas.drawPath(Path.combine(PathOperation.difference, path, hole), p);
  }

  @override
  bool shouldRepaint(covariant IslamicMosqueSilhouettePainter old) =>
      old.color != color || old.opacity != opacity;
}
