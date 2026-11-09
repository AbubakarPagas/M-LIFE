// ─────────────────────────────────────────────────────────────────────────────
// Sadaqah Progress Bar
// Animated progress bar styled for the charity feature.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SadaqahProgressBar extends StatefulWidget {
  final double progress; // 0.0 → 1.0
  final Color primaryColor;
  final double height;

  const SadaqahProgressBar({
    super.key,
    required this.progress,
    required this.primaryColor,
    this.height = 7,
  });

  @override
  State<SadaqahProgressBar> createState() => _SadaqahProgressBarState();
}

class _SadaqahProgressBarState extends State<SadaqahProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(covariant SadaqahProgressBar old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final track = widget.primaryColor.withValues(alpha: 0.12);

    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: widget.height.h,
            child: CustomPaint(
              painter: _ProgressPainter(
                progress: _animation.value,
                primaryColor: widget.primaryColor,
                trackColor: track,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color trackColor;

  const _ProgressPainter({
    required this.progress,
    required this.primaryColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.fill;
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor.withValues(alpha: 0.7), primaryColor],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final radius = size.height / 2;

    // Track
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ),
      trackPaint,
    );

    // Fill
    final fillWidth = size.width * progress;
    if (fillWidth > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, fillWidth, size.height),
          Radius.circular(radius),
        ),
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter old) =>
      old.progress != progress;
}
