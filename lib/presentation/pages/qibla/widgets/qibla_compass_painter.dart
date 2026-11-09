// ── Qibla Compass Painter ────────────────────────────────────────────────────
// Islamic gold palette: gold ticks, primary cardinal letters, gold needle.

import 'dart:math' as math;

import 'package:flutter/material.dart';

const _kGold = Color(0xffCDAD80);
const _kGoldDeep = Color(0xffA8873A);
const _kGoldLight = Color(0xffE8C97A);

class QiblaCompassPainter extends CustomPainter {
  final double compassAngle;
  final double qiblaAngle;
  final double currentHeading;
  final bool isFacingQibla;
  final Color primaryColor;
  final Color accentColor;

  const QiblaCompassPainter({
    required this.compassAngle,
    required this.qiblaAngle,
    required this.currentHeading,
    required this.isFacingQibla,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Rotate the entire compass rose with device heading
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(compassAngle);

    _drawTickRing(canvas, radius);
    _drawCardinalLines(canvas, radius);
    _drawCardinalLetters(canvas, radius);

    canvas.restore();

    // Qibla needle (not rotated — points toward Qibla from screen north)
    _drawQiblaNeedle(canvas, center, radius);

    // Fixed top north marker
    _drawNorthMark(canvas, center, radius);
  }

  // ── Tick ring ──────────────────────────────────────────────────────────────

  void _drawTickRing(Canvas canvas, double radius) {
    // Faint outer ring
    canvas.drawCircle(
      Offset.zero,
      radius - 5,
      Paint()
        ..color = _kGold.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Degree ticks
    for (int i = 0; i < 360; i += 5) {
      final angle = i * math.pi / 180;
      final isMajor = i % 10 == 0;
      final isCardinal = i % 90 == 0;

      final tickLen = isCardinal
          ? radius * 0.16
          : isMajor
          ? radius * 0.09
          : radius * 0.04;
      final tickColor = isCardinal
          ? _kGoldDeep
          : isMajor
          ? _kGold.withValues(alpha: 0.65)
          : primaryColor.withValues(alpha: 0.20);
      final strokeW = isCardinal
          ? 2.2
          : isMajor
          ? 1.4
          : 0.8;

      final outer = _polar(radius - 5, angle);
      final inner = _polar(radius - 5 - tickLen, angle);

      canvas.drawLine(
        outer,
        inner,
        Paint()
          ..color = tickColor
          ..strokeWidth = strokeW,
      );
    }
  }

  // ── Cardinal direction lines ───────────────────────────────────────────────

  void _drawCardinalLines(Canvas canvas, double radius) {
    final paint = Paint()
      ..color = _kGold.withValues(alpha: 0.35)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      canvas.drawLine(
        _polar(radius * 0.36, angle),
        _polar(radius * 0.56, angle),
        paint,
      );
    }
  }

  // ── Cardinal letters ───────────────────────────────────────────────────────

  void _drawCardinalLetters(Canvas canvas, double radius) {
    const labels = ['N', 'E', 'S', 'W'];
    const angles = [0.0, math.pi / 2, math.pi, 3 * math.pi / 2];

    for (int i = 0; i < labels.length; i++) {
      final offset = _polar(radius * 0.46, angles[i]);
      final isNorth = i == 0;

      final span = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: isNorth ? Colors.redAccent.shade200 : _kGoldLight,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.13,
          letterSpacing: -0.5,
        ),
      );
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)
        ..layout();

      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(-compassAngle); // Keep letters upright
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  // ── Qibla needle (gold arrow) ──────────────────────────────────────────────

  void _drawQiblaNeedle(Canvas canvas, Offset center, double radius) {
    // Angle from north toward Qibla, accounting for current heading
    final angle = (qiblaAngle - currentHeading) * math.pi / 180.0;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final aligned = isFacingQibla;
    final color = aligned ? _kGoldDeep : _kGold;
    final glowColor = aligned ? _kGoldLight : _kGold;

    final tipY = -(radius * 0.66);
    final baseY = radius * 0.20;

    // Glow under the needle when aligned
    if (aligned) {
      canvas.drawLine(
        Offset(0, tipY),
        Offset(0, baseY),
        Paint()
          ..color = glowColor.withValues(alpha: 0.30)
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round,
      );
    }

    // Diamond-shaped needle body
    final path = Path()
      ..moveTo(0, tipY) // tip
      ..lineTo(-7, 0) // left shoulder
      ..lineTo(0, baseY) // tail
      ..lineTo(7, 0) // right shoulder
      ..close();

    // Shadow
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Fill — gradient-like using two halves
    canvas.drawPath(path, Paint()..color = color);

    // Top half lighter highlight
    final topPath = Path()
      ..moveTo(0, tipY)
      ..lineTo(-7, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(
      topPath,
      Paint()..color = glowColor.withValues(alpha: 0.45),
    );

    // Centre gem / pivot
    canvas.drawCircle(Offset.zero, 10, Paint()..color = color);
    canvas.drawCircle(
      Offset.zero,
      10,
      Paint()
        ..color = glowColor.withValues(alpha: 0.50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      Offset.zero,
      5,
      Paint()..color = Colors.white.withValues(alpha: 0.90),
    );

    canvas.restore();
  }

  // ── Fixed north triangle ───────────────────────────────────────────────────

  void _drawNorthMark(Canvas canvas, Offset center, double radius) {
    canvas.save();
    canvas.translate(center.dx, center.dy - radius + 1);

    final path = Path()
      ..moveTo(0, -9)
      ..lineTo(-5, 5)
      ..lineTo(5, 5)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.redAccent.shade200);
    canvas.restore();
  }

  // ── Utility ────────────────────────────────────────────────────────────────

  Offset _polar(double r, double angle) =>
      Offset(r * math.sin(angle), -r * math.cos(angle));

  @override
  bool shouldRepaint(QiblaCompassPainter old) =>
      old.compassAngle != compassAngle ||
      old.qiblaAngle != qiblaAngle ||
      old.currentHeading != currentHeading ||
      old.isFacingQibla != isFacingQibla;
}
