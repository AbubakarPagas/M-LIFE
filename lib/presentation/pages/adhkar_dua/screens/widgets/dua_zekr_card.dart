import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../core/services/services_locator.dart';
import '../../../../../database/bookmark_db/bookmark_database.dart';
import '../../../../controllers/general/general_controller.dart';
import '../../../adhkar/widgets/zekr_card_widget.dart' show ZekrCircleCounter;
import '../../controller/adhkar_dua_controller.dart';
import '../../widgets/share/share_dhekr_options.dart';

// ─── Dua Zekr Card ────────────────────────────────────────────────────────────
// Clean Islamic card — no background image.
// Header uses cs.primary with gold accents, body uses subtle tinted container.

class DuaZekrCard extends StatelessWidget {
  final AdhkarData zekr;
  final int index;
  final String storageKey;

  const DuaZekrCard({
    super.key,
    required this.zekr,
    required this.index,
    required this.storageKey,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark
        ? const Color(0xFFD4AF37)
        : const Color(0xFF8B6914);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: cs.secondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: goldColor.withValues(alpha: isDark ? 0.22 : 0.14),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: goldColor.withValues(alpha: isDark ? 0.10 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ────────────────────────────────────────────────
            _DuaCardHeader(zekr: zekr, index: index),

            // ── Arabic text body ───────────────────────────────────────
            _DuaCardBody(zekr: zekr),

            // ── Reference + description ────────────────────────────────
            _DuaCardMeta(zekr: zekr),

            // ── Tap counter ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
              child: Center(
                child: ZekrCircleCounter(
                  countStr: zekr.count,
                  storageKey: storageKey,
                  accentColor: cs.primary,
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

class _DuaCardHeader extends StatelessWidget {
  final AdhkarData zekr;
  final int index;

  const _DuaCardHeader({required this.zekr, required this.index});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark
        ? const Color(0xFFD4AF37)
        : const Color(0xFF8B6914);

    return Container(
      color: cs.primary,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          // ── Index badge with Islamic octagon outline ──────────────
          SizedBox(
            width: 32,
            height: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(32, 32),
                  painter: _OctagonPainter(
                    color: goldColor.withValues(alpha: 0.45),
                  ),
                ),
                Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // ── Category name ─────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  zekr.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'naskh',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                // Golden thin line under title
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  height: 1,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        goldColor.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),

          // ── Action buttons ────────────────────────────────────────
          _DuaHeaderActions(zekr: zekr),
        ],
      ),
    );
  }
}

// ─── Header action buttons ────────────────────────────────────────────────────

class _DuaHeaderActions extends StatelessWidget {
  final AdhkarData zekr;
  const _DuaHeaderActions({required this.zekr});

  @override
  Widget build(BuildContext context) {
    final ctrl = AzkarDuaController.instance;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Copy
        _DuaHeaderBtn(
          icon: Icons.copy_rounded,
          onTap: () async {
            await Clipboard.setData(
              ClipboardData(
                text:
                    '${zekr.category}\n\n${zekr.zekr}\n\n| ${zekr.description}. | (التكرار: ${zekr.count})',
              ),
            );
          },
        ),
        const SizedBox(width: 4),

        // Share
        ShareDhekrOptions(
          zekrText: zekr.zekr,
          category: zekr.category,
          reference: zekr.reference,
          description: zekr.description,
          count: zekr.count,
        ),
        const SizedBox(width: 4),

        // Bookmark
        Obx(
          () => _DuaHeaderBtn(
            icon: ctrl.hasBookmark(zekr.category, zekr.zekr).value
                ? Icons.bookmark_rounded
                : Icons.bookmark_outline_rounded,
            onTap: () async {
              ctrl.hasBookmark(zekr.category, zekr.zekr).value
                  ? ctrl.deleteAdhkar(zekr)
                  : await ctrl.addAdhkar(zekr);
            },
          ),
        ),
      ],
    );
  }
}

class _DuaHeaderBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _DuaHeaderBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
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

class _DuaCardBody extends StatelessWidget {
  final AdhkarData zekr;

  const _DuaCardBody({required this.zekr});

  @override
  Widget build(BuildContext context) {
    final ctrl = AzkarDuaController.instance;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark
        ? const Color(0xFFD4AF37)
        : const Color(0xFF8B6914);
    final fontSize = sl<GeneralController>().state.fontSizeArabic.value;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: isDark
            ? cs.primary.withValues(alpha: 0.08)
            : cs.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: goldColor.withValues(alpha: isDark ? 0.18 : 0.12),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Decorative gold opening mark (top-right)
          Positioned(
            top: -8,
            right: -2,
            child: Text(
              '﴿',
              style: TextStyle(
                fontSize: 26,
                color: goldColor.withValues(alpha: 0.18),
                fontFamily: 'naskh',
              ),
            ),
          ),
          // Decorative gold closing mark (bottom-left)
          Positioned(
            bottom: -8,
            left: -2,
            child: Text(
              '﴾',
              style: TextStyle(
                fontSize: 26,
                color: goldColor.withValues(alpha: 0.18),
                fontFamily: 'naskh',
              ),
            ),
          ),
          RichText(
            text: TextSpan(
              children: ctrl.buildTextSpans(zekr.zekr),
              style: TextStyle(
                color: Theme.of(context).hintColor,
                height: 2.1,
                fontFamily: 'naskh',
                fontSize: fontSize,
              ),
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}

// ─── Card meta — reference + description ─────────────────────────────────────

class _DuaCardMeta extends StatelessWidget {
  final AdhkarData zekr;

  const _DuaCardMeta({required this.zekr});

  @override
  Widget build(BuildContext context) {
    if (zekr.reference.isEmpty && zekr.description.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark
        ? const Color(0xFFD4AF37)
        : const Color(0xFF8B6914);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Reference row
          if (zekr.reference.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: goldColor.withValues(alpha: isDark ? 0.20 : 0.14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      zekr.reference,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'naskh',
                        fontSize: 12,
                        color: goldColor.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.menu_book_rounded,
                    size: 13,
                    color: goldColor.withValues(alpha: 0.55),
                  ),
                ],
              ),
            ),

          // Description row
          if (zekr.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: isDark ? 0.07 : 0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                zekr.description,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'naskh',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).hintColor.withValues(alpha: 0.80),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Octagon painter ─────────────────────────────────────────────────────────

class _OctagonPainter extends CustomPainter {
  const _OctagonPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 1;
    final path = Path();

    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * math.pi / 8) - math.pi / 8;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OctagonPainter old) => old.color != color;
}
