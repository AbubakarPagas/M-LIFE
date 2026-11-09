// ignore_for_file: prefer_single_quotes
import 'dart:math' as math;

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/svg_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Toast type
// ─────────────────────────────────────────────────────────────────────────────
enum IslamicToastType {
  success, // ✓ green accent — bookmark added, copy, session saved …
  info, // ℹ blue/primary accent — copy, neutral notifications
  warning, // ⚠ amber accent — errors, alerts, no internet
  exit, // special: double-back-press warning (bottom, with countdown)
}

// ─────────────────────────────────────────────────────────────────────────────
// Public API  ──  single call site for every toast in the app
// ─────────────────────────────────────────────────────────────────────────────
class IslamicToast {
  IslamicToast._();

  /// Show a top-aligned notification toast (success / info / warning).
  static void show(
    BuildContext context, {
    required String message,
    String? arabicMessage,
    IslamicToastType type = IslamicToastType.info,
    Duration duration = const Duration(milliseconds: 3000),
  }) {
    final cs = Theme.of(context).colorScheme;
    BotToast.showCustomNotification(
      enableSlideOff: true,
      useSafeArea: true,
      align: Alignment.topCenter,
      duration: duration,
      animationDuration: const Duration(milliseconds: 400),
      animationReverseDuration: const Duration(milliseconds: 280),
      toastBuilder: (_) => _IslamicToastWidget(
        message: message,
        arabicMessage: arabicMessage,
        type: type,
        colorScheme: cs,
        hintColor: Theme.of(context).hintColor,
      ),
    );
  }

  /// Show the special bottom exit-warning toast with a countdown ring.
  static void showExit(
    BuildContext context, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final cs = Theme.of(context).colorScheme;
    BotToast.showCustomNotification(
      enableSlideOff: true,
      useSafeArea: true,
      align: Alignment.bottomCenter,
      duration: duration,
      animationDuration: const Duration(milliseconds: 380),
      animationReverseDuration: const Duration(milliseconds: 260),
      toastBuilder: (_) => _ExitToastWidget(colorScheme: cs),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BuildContext extension  — mirrors old API so call sites stay minimal
// ─────────────────────────────────────────────────────────────────────────────
extension IslamicToastExtension on BuildContext {
  /// Drop-in replacement for the old showCustomErrorSnackBar.
  /// [isDone] true → success type, false → warning type.
  void showCustomErrorSnackBar(String text, {bool? isDone = false}) {
    IslamicToast.show(
      this,
      message: text,
      type: (isDone ?? false)
          ? IslamicToastType.success
          : IslamicToastType.warning,
    );
  }

  void showIslamicToast(
    String message, {
    String? arabicMessage,
    IslamicToastType type = IslamicToastType.info,
  }) {
    IslamicToast.show(
      this,
      message: message,
      arabicMessage: arabicMessage,
      type: type,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal constants
// ─────────────────────────────────────────────────────────────────────────────
const _kGold = Color(0xffCDAD80);

class _TypeConfig {
  final Color accent;
  final Color iconBg;
  final IconData icon;
  final String? svgPath;

  const _TypeConfig({
    required this.accent,
    required this.iconBg,
    required this.icon,
    this.svgPath,
  });
}

_TypeConfig _config(IslamicToastType type, ColorScheme cs) {
  switch (type) {
    case IslamicToastType.success:
      return _TypeConfig(
        accent: const Color(0xff4CAF50),
        iconBg: const Color(0xff4CAF50),
        icon: Icons.check_rounded,
        svgPath: SvgPath.svgCheckMark,
      );
    case IslamicToastType.warning:
      return _TypeConfig(
        accent: const Color(0xffE8A020),
        iconBg: const Color(0xffE8A020),
        icon: Icons.warning_rounded,
        svgPath: SvgPath.svgAlert,
      );
    case IslamicToastType.info:
      return _TypeConfig(
        accent: cs.primary,
        iconBg: cs.primary,
        icon: Icons.info_rounded,
      );
    case IslamicToastType.exit:
      return _TypeConfig(
        accent: cs.primary,
        iconBg: cs.primary,
        icon: Icons.exit_to_app_rounded,
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main toast widget
// ─────────────────────────────────────────────────────────────────────────────
class _IslamicToastWidget extends StatefulWidget {
  final String message;
  final String? arabicMessage;
  final IslamicToastType type;
  final ColorScheme colorScheme;
  final Color hintColor;

  const _IslamicToastWidget({
    required this.message,
    this.arabicMessage,
    required this.type,
    required this.colorScheme,
    required this.hintColor,
  });

  @override
  State<_IslamicToastWidget> createState() => _IslamicToastWidgetState();
}

class _IslamicToastWidgetState extends State<_IslamicToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.55),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _scale = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    final cfg = _config(widget.type, cs);

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: _ToastShell(
            colorScheme: cs,
            accentColor: cfg.accent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Left accent line ──────────────────────────────────────
                _AccentLine(color: cfg.accent),
                const SizedBox(width: 10),

                // ── Icon badge ────────────────────────────────────────────
                _IconBadge(cfg: cfg, cs: cs),
                const SizedBox(width: 12),

                // ── Text area ─────────────────────────────────────────────
                Flexible(
                  child: _MessageText(
                    message: widget.message,
                    arabicMessage: widget.arabicMessage,
                    hintColor: widget.hintColor,
                    accentColor: cfg.accent,
                  ),
                ),

                const SizedBox(width: 10),

                // ── Decorative crescent ────────────────────────────────────
                _CrescentDecor(color: cfg.accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Toast shell — card with gradient, border, shadow, arabesque corners
// ─────────────────────────────────────────────────────────────────────────────
class _ToastShell extends StatelessWidget {
  final ColorScheme colorScheme;
  final Color accentColor;
  final Widget child;

  const _ToastShell({
    required this.colorScheme,
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer,
            cs.primaryContainer.withValues(alpha: 0.94),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.28),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.18),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Arabesque corner decorations (subtle)
          Positioned(
            right: 8,
            top: 4,
            child: _ArabesqueCorner(color: accentColor.withValues(alpha: 0.10)),
          ),
          Positioned(
            left: 8,
            bottom: 4,
            child: _ArabesqueCorner(
              color: accentColor.withValues(alpha: 0.07),
              flip: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Accent line (left edge coloured bar)
// ─────────────────────────────────────────────────────────────────────────────
class _AccentLine extends StatelessWidget {
  final Color color;
  const _AccentLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3.5,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color, color.withValues(alpha: 0.4)],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Icon badge
// ─────────────────────────────────────────────────────────────────────────────
class _IconBadge extends StatelessWidget {
  final _TypeConfig cfg;
  final ColorScheme cs;

  const _IconBadge({required this.cfg, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            cfg.iconBg.withValues(alpha: 0.20),
            cfg.iconBg.withValues(alpha: 0.08),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: cfg.iconBg.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: cfg.svgPath != null
          ? Center(
              child: SvgPicture.asset(
                cfg.svgPath!,
                height: 20,
                colorFilter: ColorFilter.mode(cfg.accent, BlendMode.srcIn),
              ),
            )
          : Icon(cfg.icon, color: cfg.accent, size: 20),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Message text area
// ─────────────────────────────────────────────────────────────────────────────
class _MessageText extends StatelessWidget {
  final String message;
  final String? arabicMessage;
  final Color hintColor;
  final Color accentColor;

  const _MessageText({
    required this.message,
    this.arabicMessage,
    required this.hintColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (arabicMessage != null) ...[
          Text(
            arabicMessage!,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'naskh',
              fontSize: 13,
              color: accentColor.withValues(alpha: 0.80),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 2),
        ],
        Text(
          message,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: hintColor,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Decorative crescent (right side of toast)
// ─────────────────────────────────────────────────────────────────────────────
class _CrescentDecor extends StatelessWidget {
  final Color color;
  const _CrescentDecor({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(18, 18),
      painter: _CrescentPainter(color: color.withValues(alpha: 0.30)),
    );
  }
}

class _CrescentPainter extends CustomPainter {
  final Color color;
  const _CrescentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Outer circle
    final outerPath = Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    // Inner circle (offset to create crescent)
    final innerPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx + r * 0.35, cy - r * 0.15), radius: r * 0.75));

    final crescent = Path.combine(PathOperation.difference, outerPath, innerPath);
    canvas.drawPath(crescent, paint);
  }

  @override
  bool shouldRepaint(_CrescentPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Arabesque corner (geometric flower)
// ─────────────────────────────────────────────────────────────────────────────
class _ArabesqueCorner extends StatelessWidget {
  final Color color;
  final bool flip;
  const _ArabesqueCorner({required this.color, this.flip = false});

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: flip
          ? (Matrix4.identity()..scale(-1.0, -1.0))
          : Matrix4.identity(),
      alignment: Alignment.center,
      child: CustomPaint(
        size: const Size(22, 22),
        painter: _ArabesquePainter(color: color),
      ),
    );
  }
}

class _ArabesquePainter extends CustomPainter {
  final Color color;
  const _ArabesquePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2.2;

    // 8-petalled geometric flower (arabesque-style)
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final px = cx + r * 0.55 * math.cos(angle);
      final py = cy + r * 0.55 * math.sin(angle);
      canvas.drawCircle(Offset(px, py), r * 0.38, paint);
    }
    canvas.drawCircle(Offset(cx, cy), r * 0.35, paint);
  }

  @override
  bool shouldRepaint(_ArabesquePainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Exit toast (bottom, with countdown ring + bilingual text)
// ─────────────────────────────────────────────────────────────────────────────
class _ExitToastWidget extends StatefulWidget {
  final ColorScheme colorScheme;
  const _ExitToastWidget({required this.colorScheme});

  @override
  State<_ExitToastWidget> createState() => _ExitToastWidgetState();
}

class _ExitToastWidgetState extends State<_ExitToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.65),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: _ToastShell(
            colorScheme: cs,
            accentColor: _kGold,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AccentLine(color: _kGold),
                const SizedBox(width: 10),

                // Icon badge with exit icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        _kGold.withValues(alpha: 0.20),
                        _kGold.withValues(alpha: 0.06),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _kGold.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.exit_to_app_rounded,
                    color: _kGold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Bilingual text
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اضغط مرة أخرى للخروج',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'naskh',
                          fontSize: 13,
                          color: _kGold.withValues(alpha: 0.80),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Press back again to exit',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).hintColor,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),
                // Countdown ring
                _CountdownRing(colorScheme: cs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3-second countdown ring
// ─────────────────────────────────────────────────────────────────────────────
class _CountdownRing extends StatefulWidget {
  final ColorScheme colorScheme;
  const _CountdownRing({required this.colorScheme});

  @override
  State<_CountdownRing> createState() => _CountdownRingState();
}

class _CountdownRingState extends State<_CountdownRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
    _progress = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (_, __) => SizedBox(
        width: 34,
        height: 34,
        child: CustomPaint(
          painter: _RingPainter(
            progress: _progress.value,
            trackColor: _kGold.withValues(alpha: 0.15),
            arcColor: _kGold,
          ),
          child: Center(
            child: Text(
              '${(_progress.value * 3).ceil()}',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'kufi',
                fontWeight: FontWeight.bold,
                color: widget.colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color arcColor;

  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.arcColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 5) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress * 2 * math.pi,
      false,
      Paint()
        ..color = arcColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
