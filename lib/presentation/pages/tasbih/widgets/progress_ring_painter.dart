import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Custom painter that draws a gradient arc progress ring.
class ProgressRingPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final Color trackColor;
  final Color progressColor;
  final Color glowColor;
  final double strokeWidth;

  const ProgressRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.glowColor,
    this.strokeWidth = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    const startAngle = -math.pi / 2; // top
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    // ── Track ───────────────────────────────────────────────────────────────
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress <= 0) return;

    // ── Glow shadow ─────────────────────────────────────────────────────────
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = glowColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // ── Progress arc with gradient ──────────────────────────────────────────
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + 2 * math.pi,
      colors: [
        progressColor.withValues(alpha: 0.6),
        progressColor,
        progressColor.withValues(alpha: 0.9),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // ── Tip dot ─────────────────────────────────────────────────────────────
    final tipAngle = startAngle + sweepAngle;
    final tipX = center.dx + radius * math.cos(tipAngle);
    final tipY = center.dy + radius * math.sin(tipAngle);
    canvas.drawCircle(
      Offset(tipX, tipY),
      strokeWidth / 2 + 1,
      Paint()..color = progressColor,
    );
  }

  @override
  bool shouldRepaint(ProgressRingPainter old) =>
      old.progress != progress ||
      old.progressColor != progressColor ||
      old.trackColor != trackColor;
}
