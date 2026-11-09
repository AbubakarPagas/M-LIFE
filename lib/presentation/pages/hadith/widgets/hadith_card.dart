import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/services/services_locator.dart';
import '../../../controllers/general/general_controller.dart';
import '../controller/hadith_controller.dart';
import '../models/hadith.dart';

// ── Design tokens ────────────────────────────────────────────────────────────
const kHadithGold = Color(0xFFCDAD80);

const kHadithPalettes = [
  [Color(0xFF404C6E), Color(0xFF2E3850)],
  [Color(0xFF3D5A5A), Color(0xFF2A3E3E)],
  [Color(0xFF5A3E2B), Color(0xFF3E2A1A)],
  [Color(0xFF4A3D6B), Color(0xFF332A4E)],
  [Color(0xFF2E5449), Color(0xFF1F3B33)],
  [Color(0xFF5C4033), Color(0xFF3E2B22)],
  [Color(0xFF3B4F6B), Color(0xFF283750)],
  [Color(0xFF4A5240), Color(0xFF333A2C)],
];

// ── Hadith Card ───────────────────────────────────────────────────────────────

class HadithCard extends StatelessWidget {
  final Hadith hadith;
  final int index;
  final String bookName;

  const HadithCard({
    super.key,
    required this.hadith,
    required this.index,
    required this.bookName,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = kHadithPalettes[index % kHadithPalettes.length];
    final accentColor = palette[0];
    final ctrl = HadithController.instance;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
            _HadithCardHeader(
              hadith: hadith,
              accentColor: accentColor,
              bookName: bookName,
              ctrl: ctrl,
            ),
            // H5 — Arabic font size is read reactively from GeneralController
            _HadithTextBlock(
              text: hadith.textAra,
              accentColor: accentColor,
              isArabic: true,
            ),
            if (hadith.text.isNotEmpty && hadith.text != hadith.textAra)
              _HadithTextBlock(
                text: hadith.text,
                accentColor: accentColor,
                isArabic: false,
              ),
            _HadithMeta(hadith: hadith, accentColor: accentColor),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ── Card Header ──────────────────────────────────────────────────────────────

class _HadithCardHeader extends StatelessWidget {
  final Hadith hadith;
  final Color accentColor;
  final String bookName;
  final HadithController ctrl;

  const _HadithCardHeader({
    required this.hadith,
    required this.accentColor,
    required this.bookName,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: cs.primary,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          // Hadith number badge
          Container(
            constraints: const BoxConstraints(minWidth: 36),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(
                color: kHadithGold.withValues(alpha: 0.40),
                width: 1,
              ),
            ),
            child: Text(
              '#${hadith.hadithNumber}',
              style: const TextStyle(
                fontFamily: 'kufi',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ctrl.bookDisplayName(bookName),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
          _HeaderActions(hadith: hadith, bookName: bookName, ctrl: ctrl),
        ],
      ),
    );
  }
}

// ── Header action buttons ─────────────────────────────────────────────────────

class _HeaderActions extends StatelessWidget {
  final Hadith hadith;
  final String bookName;
  final HadithController ctrl;

  const _HeaderActions({
    required this.hadith,
    required this.bookName,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeaderBtn(
          icon: Icons.copy_rounded,
          onTap: () async {
            await Clipboard.setData(
              ClipboardData(
                text:
                    '${hadith.textAra}\n\n${hadith.text}\n'
                    '— ${ctrl.bookDisplayName(bookName)} #${hadith.hadithNumber}',
              ),
            );
          },
        ),
        const SizedBox(width: 4),
        _HeaderBtn(
          icon: Icons.share_rounded,
          onTap: () {
            SharePlus.instance.share(
              ShareParams(
                text:
                    '${hadith.textAra}\n\n${hadith.text}\n'
                    '— ${ctrl.bookDisplayName(bookName)} #${hadith.hadithNumber}',
                subject: ctrl.bookDisplayName(bookName),
              ),
            );
          },
        ),
        const SizedBox(width: 4),
        Obx(() {
          final saved = ctrl.isBookmarked(bookName, hadith.hadithNumber);
          return _HeaderBtn(
            icon: saved
                ? Icons.bookmark_rounded
                : Icons.bookmark_outline_rounded,
            onTap: () => ctrl.toggleBookmark(hadith),
          );
        }),
      ],
    );
  }
}

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderBtn({required this.icon, required this.onTap});

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

// ── Text block — H5: Arabic size driven by GeneralController ─────────────────

class _HadithTextBlock extends StatelessWidget {
  final String text;
  final Color accentColor;
  final bool isArabic;

  const _HadithTextBlock({
    required this.text,
    required this.accentColor,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(14, isArabic ? 14 : 8, 14, 0),
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
          if (isArabic)
            Positioned(
              top: -4,
              right: 0,
              child: Text(
                '❝',
                style: TextStyle(
                  fontSize: 28,
                  color: kHadithGold.withValues(alpha: 0.20),
                  fontFamily: 'naskh',
                ),
              ),
            ),
          // H5 — Arabic size reacts to the slider; translation is always 14
          isArabic
              ? Obx(() {
                  final fontSize =
                      sl<GeneralController>().state.fontSizeArabic.value;
                  return Text(
                    text,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontFamily: 'naskh',
                      fontSize: fontSize,
                      height: 2.0,
                      color: Theme.of(context).hintColor,
                    ),
                  );
                })
              : Text(
                  text,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 14,
                    height: 2.0,
                    color: Theme.of(context).hintColor,
                  ),
                ),
        ],
      ),
    );
  }
}

// ── Metadata strip (grades + reference) ──────────────────────────────────────

class _HadithMeta extends StatelessWidget {
  final Hadith hadith;
  final Color accentColor;

  const _HadithMeta({required this.hadith, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final hasGrades = hadith.grades.isNotEmpty;
    final ref =
        'Book ${hadith.reference.bookReference}, Hadith ${hadith.reference.inBookReference}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasGrades)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: hadith.grades.map((g) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    '${g.name}: ${g.grade}',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).hintColor.withValues(alpha: 0.75),
                    ),
                  ),
                );
              }).toList(),
            ),
          if (hasGrades) const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accentColor.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  size: 14,
                  color: kHadithGold.withValues(alpha: 0.60),
                ),
                const SizedBox(width: 6),
                Text(
                  ref,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 11,
                    color: Theme.of(context).hintColor.withValues(alpha: 0.60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
