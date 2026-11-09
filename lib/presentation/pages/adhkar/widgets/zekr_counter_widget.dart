import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// A persistent tap-counter for a single Zekr item.
///
/// Progress is saved in [GetStorage] under a key derived from [storageKey].
/// Every new calendar day the counter automatically resets.
///
/// [storageKey]  – a unique string per zekr, e.g. "${zekr.category}_${zekr.count}"
/// [countStr]    – raw count string, e.g. "7", "3×33", "مرة واحدة"
class ZekrCounterWidget extends StatefulWidget {
  final String countStr;
  final String storageKey;

  const ZekrCounterWidget({
    super.key,
    required this.countStr,
    required this.storageKey,
  });

  @override
  State<ZekrCounterWidget> createState() => _ZekrCounterWidgetState();
}

class _ZekrCounterWidgetState extends State<ZekrCounterWidget>
    with SingleTickerProviderStateMixin {
  // ── Storage ───────────────────────────────────────────────────────────────
  static final _box = GetStorage();
  late final String _keyRemaining;
  late final String _keyDate;

  // ── State ─────────────────────────────────────────────────────────────────
  late int _target;
  late int _remaining;

  // ── Animation ─────────────────────────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // ── Helpers ───────────────────────────────────────────────────────────────
  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  /// Parses "7", "33", "3×33", "3x33", "مرة واحدة" → integer target.
  static int _parse(String raw) {
    final trimmed = raw.trim();
    final multi = RegExp(r'(\d+)\s*[×x]\s*(\d+)').firstMatch(trimmed);
    if (multi != null) {
      return int.parse(multi.group(1)!) * int.parse(multi.group(2)!);
    }
    final num = RegExp(r'\d+').firstMatch(trimmed);
    if (num != null) return int.parse(num.group(0)!);
    return 1; // "مرة واحدة" and similar
  }

  @override
  void initState() {
    super.initState();

    // Build storage keys from the caller-supplied unique key
    final safe = widget.storageKey.replaceAll(
      RegExp(r'[^a-zA-Z0-9_\u0600-\u06FF]'),
      '_',
    );
    _keyRemaining = 'zekr_rem_$safe';
    _keyDate = 'zekr_date_$safe';

    _target = _parse(widget.countStr);
    _remaining = _loadRemaining();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));
  }

  /// Loads persisted remaining count, resetting if the saved date ≠ today.
  int _loadRemaining() {
    final savedDate = _box.read<String>(_keyDate);
    final today = _todayStr();

    if (savedDate != today) {
      // New day — wipe and start fresh
      _box.write(_keyDate, today);
      _box.write(_keyRemaining, _target);
      return _target;
    }

    final saved = _box.read<int>(_keyRemaining);
    return saved ?? _target;
  }

  void _save() {
    _box.write(_keyRemaining, _remaining);
    _box.write(_keyDate, _todayStr());
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Interaction ───────────────────────────────────────────────────────────

  void _onTap() {
    if (_remaining <= 0) {
      // Tap after done → reset for the current session (not a new day)
      setState(() => _remaining = _target);
      _save();
      return;
    }
    HapticFeedback.lightImpact();
    _pulseCtrl.forward().then((_) => _pulseCtrl.reverse());
    setState(() => _remaining--);
    _save();
  }

  bool get _isDone => _remaining == 0;
  double get _progress => _target > 0 ? 1.0 - (_remaining / _target) : 1.0;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, child) =>
              Transform.scale(scale: _pulseAnim.value, child: child),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: _isDone
                  ? cs.primary.withValues(alpha: isDark ? 0.18 : 0.10)
                  : cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isDone
                    ? cs.primary.withValues(alpha: 0.40)
                    : cs.primary.withValues(alpha: 0.12),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: _isDone ? 0.14 : 0.06),
                  blurRadius: _isDone ? 14 : 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // ── Circular progress ring ───────────────────────────────
                _RingProgress(
                  progress: _progress,
                  isDone: _isDone,
                  remaining: _remaining,
                ),

                const SizedBox(width: 14),

                // ── Label + linear bar ───────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          _isDone
                              ? 'أحسنت! ✓'
                              : '${'repeat'.tr} ${widget.countStr}',
                          key: ValueKey(_isDone),
                          style: TextStyle(
                            fontFamily: 'naskh',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _isDone
                                ? cs.primary
                                : Theme.of(context).hintColor,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: _progress),
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                          builder: (_, v, __) => LinearProgressIndicator(
                            value: v,
                            minHeight: 4,
                            backgroundColor: cs.primary.withValues(alpha: 0.10),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              cs.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // ── Remaining badge / reset button ───────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isDone
                      ? GestureDetector(
                          onTap: _onTap,
                          key: const ValueKey('reset'),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.refresh_rounded,
                              color: cs.primary,
                              size: 18,
                            ),
                          ),
                        )
                      : Container(
                          key: const ValueKey('tap'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                cs.primary,
                                Color.lerp(
                                  cs.primary,
                                  isDark ? Colors.black : Colors.white,
                                  0.18,
                                )!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withValues(alpha: 0.28),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            '$_remaining',
                            style: TextStyle(
                              fontFamily: 'kufi',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : cs.secondary,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Circular ring ──────────────────────────────────────────────────────────────

class _RingProgress extends StatelessWidget {
  final double progress;
  final bool isDone;
  final int remaining;

  const _RingProgress({
    required this.progress,
    required this.isDone,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const size = 52.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Track
          CustomPaint(
            size: const Size(size, size),
            painter: _ArcPainter(
              progress: 1.0,
              color: cs.primary.withValues(alpha: 0.10),
              strokeWidth: 4.5,
            ),
          ),
          // Animated fill
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (_, v, __) => CustomPaint(
              size: const Size(size, size),
              painter: _ArcPainter(
                progress: v,
                color: cs.primary,
                strokeWidth: 4.5,
              ),
            ),
          ),
          // Centre label
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isDone
                ? Icon(
                    Icons.check_rounded,
                    key: const ValueKey('check'),
                    color: cs.primary,
                    size: 22,
                  )
                : Text(
                    '${(progress * 100).toInt()}%',
                    key: ValueKey(remaining),
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Arc painter ────────────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  const _ArcPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2 - strokeWidth / 2,
      ),
      -math.pi / 2, // start at 12 o'clock
      2 * math.pi * progress, // clockwise sweep
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}
