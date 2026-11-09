import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../provider/adhanProvider.dart';
import 'adhan_theme.dart';

/// Hero section: animated circular ring + countdown + status label.
class PrayerCountdownHero extends StatefulWidget {
  const PrayerCountdownHero({super.key});

  @override
  State<PrayerCountdownHero> createState() => _PrayerCountdownHeroState();
}

class _PrayerCountdownHeroState extends State<PrayerCountdownHero>
    with TickerProviderStateMixin {
  late AnimationController _ringController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  Timer? _ticker;
  Duration _remaining = Duration.zero;
  bool _isPrayerActive = false;
  String _statusLabel = '';
  String _prayerName = '';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    // Continuous ring rotation
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Subtle pulse for the active-prayer state
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _refresh();
    });
    _refresh();
  }

  void _refresh() {
    final provider = context.read<AdhanProvider>();
    final current = provider.currentAdhan;
    final next = provider.nextAdhan;
    final now = DateTime.now();

    setState(() {
      if (current != null) {
        // A prayer window is currently open
        _isPrayerActive = true;
        _prayerName = current.title;
        final elapsed = now.difference(current.startTime);
        final total = current.endTime.difference(current.startTime);
        _progress = (elapsed.inSeconds / total.inSeconds).clamp(0.0, 1.0);
        _remaining = current.endTime.difference(now);
        if (_remaining.isNegative) _remaining = Duration.zero;
        _statusLabel = 'current_prayer'.tr.toUpperCase();
      } else {
        _isPrayerActive = false;
        _prayerName = next.title;
        _remaining = next.startTime.difference(now);
        if (_remaining.isNegative) _remaining = Duration.zero;
        // progress: how far through the gap until the next prayer starts
        final gapStart = _findGapStart(provider);
        final total = next.startTime.difference(gapStart);
        if (total.inSeconds > 0) {
          final elapsed = now.difference(gapStart);
          _progress = (elapsed.inSeconds / total.inSeconds).clamp(0.0, 1.0);
        } else {
          _progress = 0.0;
        }
        _statusLabel = 'next_prayer_in'.tr.toUpperCase();
      }
    });
  }

  DateTime _findGapStart(AdhanProvider provider) {
    // Use the end-time of the last completed prayer as the gap origin
    final list = provider.getAdhanData(DateTime.now());
    DateTime gapStart = DateTime.now().subtract(const Duration(hours: 1));
    for (final a in list) {
      if (a.endTime.isBefore(DateTime.now()) && a.endTime.isAfter(gapStart)) {
        gapStart = a.endTime;
      }
    }
    return gapStart;
  }

  @override
  void dispose() {
    _ringController.dispose();
    _pulseController.dispose();
    _ticker?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    if (d.isNegative) d = Duration.zero;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AdhanProvider>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final ringDiameter = size.width * 0.62;

    // Derive colours directly from the active theme (same as Tasbih)
    const gold = kAdhanGold;
    const goldLight = kAdhanGoldLight;
    final arcActive = [cs.primary, kAdhanGoldLight, theme.primaryColorLight];
    final arcIdle = [
      cs.primary.withValues(alpha: 0.5),
      cs.primary,
      cs.primary.withValues(alpha: 0.5),
    ];
    final cdGradient = isDark
        ? [const Color(0xFF0D5C3D), const Color(0xFF071C12)]
        : [cs.primary, Color.lerp(cs.primary, Colors.black, 0.30)!];
    final cdBorder = isDark
        ? AdhanColors.emeraldGlow.withValues(alpha: 0.40)
        : gold.withValues(alpha: 0.65);
    final cdGlow = cs.primary.withValues(alpha: isDark ? 0.22 : 0.18);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status label
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            _statusLabel,
            key: ValueKey(_statusLabel),
            style: AdhanTextStyles.statusLabel(
              color: isDark ? goldLight : cs.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        // Ring
        SizedBox(
          width: ringDiameter,
          height: ringDiameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _DimRing(
                diameter: ringDiameter,
                borderColor: cs.primary.withValues(alpha: 0.20),
              ),
              AnimatedBuilder(
                animation: _ringController,
                builder: (_, __) => Transform.rotate(
                  angle: _ringController.value * 2 * math.pi,
                  child: _DecorativeDots(
                    diameter: ringDiameter - 8,
                    majorColor: gold,
                    minorColor: cs.primary.withValues(alpha: 0.18),
                  ),
                ),
              ),
              CustomPaint(
                size: Size(ringDiameter - 20, ringDiameter - 20),
                painter: _ProgressArcPainter(
                  progress: _progress,
                  isActive: _isPrayerActive,
                  activeColors: arcActive,
                  idleColors: arcIdle,
                  trackColor: cs.primary.withValues(alpha: 0.15),
                ),
              ),
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, child) => Transform.scale(
                  scale: _isPrayerActive ? _pulseAnim.value : 1.0,
                  child: child,
                ),
                child: _GlassCircle(
                  diameter: ringDiameter * 0.72,
                  gradientColors: cdGradient,
                  borderColor: cdBorder,
                  glowColor: cdGlow,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _prayerName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AdhanColors.pureWhite,
                          letterSpacing: 0.8,
                          fontFamily: 'kufi',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _format(_remaining),
                          style: AdhanTextStyles.countdownDisplay,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_isPrayerActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: gold.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: gold.withValues(alpha: 0.60),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'prayer_time_started'.tr,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: goldLight,
                              letterSpacing: 1.4,
                              fontFamily: 'kufi',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Supporting painters / sub-widgets ────────────────────────────────────────

class _DimRing extends StatelessWidget {
  final double diameter;
  final Color borderColor;
  const _DimRing({required this.diameter, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
    );
  }
}

class _GlassCircle extends StatelessWidget {
  final double diameter;
  final Widget child;
  final List<Color> gradientColors;
  final Color borderColor;
  final Color glowColor;
  const _GlassCircle({
    required this.diameter,
    required this.child,
    required this.gradientColors,
    required this.borderColor,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: gradientColors,
          stops: const [0.3, 1.0],
        ),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(color: glowColor, blurRadius: 28, spreadRadius: 4),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 16,
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: child,
        ),
      ),
    );
  }
}

class _DecorativeDots extends StatelessWidget {
  final double diameter;
  final Color majorColor;
  final Color minorColor;
  const _DecorativeDots({
    required this.diameter,
    required this.majorColor,
    required this.minorColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(diameter, diameter),
      painter: _DotsPainter(majorColor: majorColor, minorColor: minorColor),
    );
  }
}

class _DotsPainter extends CustomPainter {
  final Color majorColor;
  final Color minorColor;
  const _DotsPainter({required this.majorColor, required this.minorColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const dotCount = 24;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < dotCount; i++) {
      final angle = (2 * math.pi / dotCount) * i;
      final pos = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final isMajor = i % 6 == 0;
      paint.color = isMajor ? majorColor.withValues(alpha: 0.7) : minorColor;
      canvas.drawCircle(pos, isMajor ? 3 : 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DotsPainter old) =>
      old.majorColor != majorColor || old.minorColor != minorColor;
}

class _ProgressArcPainter extends CustomPainter {
  final double progress;
  final bool isActive;
  final List<Color> activeColors;
  final List<Color> idleColors;
  final Color trackColor;

  _ProgressArcPainter({
    required this.progress,
    required this.isActive,
    required this.activeColors,
    required this.idleColors,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 4.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    final sweepAngle = 2 * math.pi * progress;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final colors = isActive ? activeColors : idleColors;

    final shader = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + 2 * math.pi,
      colors: colors,
      stops: const [0.0, 0.5, 1.0],
    ).createShader(rect);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      Paint()
        ..shader = shader
        ..strokeWidth = strokeWidth + 1
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Tip glow dot
    final tipAngle = -math.pi / 2 + sweepAngle;
    final tipPos = Offset(
      center.dx + radius * math.cos(tipAngle),
      center.dy + radius * math.sin(tipAngle),
    );
    canvas.drawCircle(
      tipPos,
      6,
      Paint()
        ..color = colors.last.withValues(alpha: 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(tipPos, 4, Paint()..color = colors.last);
  }

  @override
  bool shouldRepaint(covariant _ProgressArcPainter old) =>
      old.progress != progress ||
      old.isActive != isActive ||
      old.trackColor != trackColor;
}
