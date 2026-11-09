import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../core/services/services_locator.dart';
import '../../../../database/bookmark_db/bookmark_database.dart';
import '../../../controllers/general/general_controller.dart';
import '../controller/adhkar_controller.dart';
import 'share/share_dhekr_options.dart';

// ─── Design tokens ─────────────────────────────────────────────────────────────
const kZekrGold = Color(0xFFCDAD80);

// Cycling Islamic palette — one per card index
const kZekrPalettes = [
  [Color(0xFF404C6E), Color(0xFF2E3850)],
  [Color(0xFF3D5A5A), Color(0xFF2A3E3E)],
  [Color(0xFF5A3E2B), Color(0xFF3E2A1A)],
  [Color(0xFF4A3D6B), Color(0xFF332A4E)],
  [Color(0xFF2E5449), Color(0xFF1F3B33)],
  [Color(0xFF5C4033), Color(0xFF3E2B22)],
  [Color(0xFF3B4F6B), Color(0xFF283750)],
  [Color(0xFF4A5240), Color(0xFF333A2C)],
];

// ─── Islamic Zekr Card ─────────────────────────────────────────────────────────

class ZekrCardWidget extends StatelessWidget {
  final AdhkarData zekr;
  final int index;
  final String storageKey;

  const ZekrCardWidget({
    super.key,
    required this.zekr,
    required this.index,
    required this.storageKey,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = kZekrPalettes[index % kZekrPalettes.length];
    final accentColor = palette[0];

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: cs.secondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.30 : 0.14),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.18 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Coloured header strip ──────────────────────────────────
            _ZekrCardHeader(zekr: zekr, index: index),

            // ── Main Arabic text ───────────────────────────────────────
            _ZekrCardBody(zekr: zekr, accentColor: accentColor),

            // ── Reference + description ────────────────────────────────
            _ZekrCardMeta(zekr: zekr, accentColor: accentColor),

            // ── Circle counter at center-bottom ────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
              child: Center(
                child: ZekrCircleCounter(
                  countStr: zekr.count,
                  storageKey: storageKey,
                  accentColor: accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Card Header ──────────────────────────────────────────────────────────────

class _ZekrCardHeader extends StatelessWidget {
  final AdhkarData zekr;
  // final List<Color> palette;
  final int index;

  const _ZekrCardHeader({
    required this.zekr,
    // required this.palette,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final azkarCtrl = AzkarController.instance;
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        /*  gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: palette,
        ), */
        color: cs.primary,
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          // Index badge
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(
                color: kZekrGold.withValues(alpha: 0.40),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Category
          Expanded(
            child: Obx(() {
              final isEn = azkarCtrl.isEnglish;
              return Text(
                isEn ? zekr.descriptions : zekr.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
                style: TextStyle(
                  fontFamily: isEn ? 'kufi' : 'naskh',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.90),
                ),
              );
            }),
          ),

          // Actions
          _ZekrHeaderActions(zekr: zekr),
        ],
      ),
    );
  }
}

// ─── Header action buttons ────────────────────────────────────────────────────

class _ZekrHeaderActions extends StatelessWidget {
  final AdhkarData zekr;
  const _ZekrHeaderActions({required this.zekr});

  @override
  Widget build(BuildContext context) {
    final azkarCtrl = AzkarController.instance;
    return Obx(() {
      final isEn = azkarCtrl.isEnglish;
      final zekrText = isEn ? zekr.zekrs : zekr.zekr;
      final refText = isEn ? zekr.references : zekr.reference;
      final descText = isEn ? zekr.descriptions : zekr.description;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Copy
          _ZekrHeaderBtn(
            icon: Icons.copy_rounded,
            onTap: () async {
              await Clipboard.setData(
                ClipboardData(
                  text:
                      '${zekr.category}\n\n$zekrText\n\n| $descText. | (التكرار: ${zekr.count})',
                ),
              );
            },
          ),
          const SizedBox(width: 4),
          // Share — wrapped in white icon tint
          ShareDhekrOptions(
            zekrText: zekrText,
            category: zekr.category,
            reference: refText,
            description: descText,
            count: zekr.count,
          ),
          const SizedBox(width: 4),
          // Bookmark
          /*    _ZekrHeaderBtn(
            icon: azkarCtrl.hasBookmark(zekr.category, zekr.zekr).value
                ? Icons.bookmark_rounded
                : Icons.bookmark_outline_rounded,
            onTap: () {},
          ), */
        ],
      );
    });
  }
}

class _ZekrHeaderBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ZekrHeaderBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.85),
          size: 15,
        ),
      ),
    );
  }
}

// ─── Card body — Arabic text ──────────────────────────────────────────────────

class _ZekrCardBody extends StatelessWidget {
  final AdhkarData zekr;
  final Color accentColor;

  const _ZekrCardBody({required this.zekr, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final azkarCtrl = AzkarController.instance;

    return Obx(() {
      final isEn = azkarCtrl.isEnglish;
      final text = isEn ? zekr.zekrs : zekr.zekr;
      final fontSize = sl<GeneralController>().state.fontSizeArabic.value;

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.14),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Decorative gold quote mark
            Positioned(
              top: -4,
              right: 0,
              child: Text(
                '❝',
                style: TextStyle(
                  fontSize: 28,
                  color: kZekrGold.withValues(alpha: 0.20),
                  fontFamily: 'naskh',
                ),
              ),
            ),
            RichText(
              text: TextSpan(
                children: azkarCtrl.buildTextSpans(text),
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  height: 2.0,
                  fontFamily: isEn ? 'kufi' : 'naskh',
                  fontSize: fontSize,
                ),
              ),
              textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      );
    });
  }
}

// ─── Card meta — reference + description ─────────────────────────────────────

class _ZekrCardMeta extends StatelessWidget {
  final AdhkarData zekr;
  final Color accentColor;

  const _ZekrCardMeta({required this.zekr, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final azkarCtrl = AzkarController.instance;

    return Obx(() {
      final isEn = azkarCtrl.isEnglish;
      final ref = isEn ? zekr.references : zekr.reference;
      final desc = isEn ? zekr.descriptions : zekr.description;

      if (ref.isEmpty && desc.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (ref.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      size: 14,
                      color: kZekrGold.withValues(alpha: 0.60),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ref,
                        textDirection: isEn
                            ? TextDirection.ltr
                            : TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: isEn ? 'kufi' : 'naskh',
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).hintColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (desc.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  desc,
                  textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: isEn ? 'kufi' : 'naskh',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).hintColor.withValues(alpha: 0.80),
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

// ─── Circle tap counter ───────────────────────────────────────────────────────

class ZekrCircleCounter extends StatefulWidget {
  final String countStr;
  final String storageKey;
  final Color accentColor;

  const ZekrCircleCounter({
    super.key,
    required this.countStr,
    required this.storageKey,
    required this.accentColor,
  });

  @override
  State<ZekrCircleCounter> createState() => _ZekrCircleCounterState();
}

class _ZekrCircleCounterState extends State<ZekrCircleCounter>
    with SingleTickerProviderStateMixin {
  static final _box = GetStorage();

  late final String _keyRem;
  late final String _keyDate;
  late int _target;
  late int _remaining;

  late final AnimationController _tapCtrl;
  late final Animation<double> _scaleAnim;

  static String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  static int _parse(String raw) {
    final m = RegExp(r'(\d+)\s*[×xX]\s*(\d+)').firstMatch(raw.trim());
    if (m != null) {
      return int.parse(m.group(1)!) * int.parse(m.group(2)!);
    }
    final n = RegExp(r'\d+').firstMatch(raw.trim());
    return n != null ? int.parse(n.group(0)!) : 1;
  }

  @override
  void initState() {
    super.initState();
    final safe = widget.storageKey.replaceAll(
      RegExp(r'[^a-zA-Z0-9_\u0600-\u06FF]'),
      '_',
    );
    _keyRem = 'zekr_rem_$safe';
    _keyDate = 'zekr_date_$safe';
    _target = _parse(widget.countStr);
    _remaining = _load();

    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.86,
    ).animate(CurvedAnimation(parent: _tapCtrl, curve: Curves.easeOut));
  }

  int _load() {
    if (_box.read<String>(_keyDate) != _today()) {
      _box.write(_keyDate, _today());
      _box.write(_keyRem, _target);
      return _target;
    }
    return _box.read<int>(_keyRem) ?? _target;
  }

  void _save() {
    _box.write(_keyRem, _remaining);
    _box.write(_keyDate, _today());
  }

  void _tap() {
    if (_remaining <= 0) {
      setState(() => _remaining = _target);
      _save();
      return;
    }
    HapticFeedback.lightImpact();
    _tapCtrl.forward().then((_) => _tapCtrl.reverse());
    setState(() => _remaining--);
    _save();
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    super.dispose();
  }

  bool get _done => _remaining == 0;
  double get _progress => _target > 0 ? 1.0 - (_remaining / _target) : 1.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = widget.accentColor;
    const size = 84.0;

    return GestureDetector(
      onTap: _tap,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Track ring
              CustomPaint(
                size: const Size(size, size),
                painter: _CircleArcPainter(
                  progress: 1.0,
                  color: accent.withValues(alpha: 0.12),
                  strokeWidth: 5,
                ),
              ),
              // Progress ring
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _progress),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                builder: (_, v, __) => CustomPaint(
                  size: const Size(size, size),
                  painter: _CircleArcPainter(
                    progress: v,
                    color: _done ? kZekrGold : accent,
                    strokeWidth: 5,
                    withTip: true,
                  ),
                ),
              ),
              // Circle body
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: size - 14,
                height: size - 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _done
                        ? [kZekrGold, const Color(0xFFB89060)]
                        : [
                            accent,
                            Color.lerp(
                              accent,
                              isDark ? Colors.black : Colors.white,
                              0.20,
                            )!,
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_done ? kZekrGold : accent).withValues(
                        alpha: 0.35,
                      ),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _done
                        ? const Icon(
                            Icons.check_rounded,
                            key: ValueKey('done'),
                            color: Colors.white,
                            size: 28,
                          )
                        : Column(
                            key: ValueKey(_remaining),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$_remaining',
                                style: const TextStyle(
                                  fontFamily: 'kufi',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                'repeat'.tr,
                                style: TextStyle(
                                  fontFamily: 'kufi',
                                  fontSize: 8,
                                  color: Colors.white.withValues(alpha: 0.70),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Arc painter ──────────────────────────────────────────────────────────────

class _CircleArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool withTip;

  const _CircleArcPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    this.withTip = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );

    if (withTip && progress > 0.02) {
      final tipAngle = -math.pi / 2 + 2 * math.pi * progress;
      final tipPos = Offset(
        center.dx + radius * math.cos(tipAngle),
        center.dy + radius * math.sin(tipAngle),
      );
      canvas.drawCircle(tipPos, strokeWidth * 0.9, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_CircleArcPainter old) =>
      old.progress != progress || old.color != color;
}
