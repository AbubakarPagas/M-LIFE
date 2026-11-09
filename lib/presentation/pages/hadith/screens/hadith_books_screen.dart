import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/hadith_controller.dart';
import '../helper/languagehelper.dart';
import 'hadith_sections_screen.dart';

/// The books grid — entry point after language selection.
class HadithBooksScreen extends StatelessWidget {
  const HadithBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = HadithController.instance;

    return Obx(() {
      final lang = ctrl.selectedLanguage;
      final books = ctrl.booksForCurrentLanguage;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LanguageStrip(ctrl: ctrl, currentLang: lang),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: books.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _BookCard(bookSlug: books[i], index: i, ctrl: ctrl),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

// ── Language selector ─────────────────────────────────────────────────────────

class _LanguageStrip extends StatelessWidget {
  final HadithController ctrl;
  final String currentLang;

  const _LanguageStrip({required this.ctrl, required this.currentLang});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final langs = ctrl.availableLanguages;

    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: langs.length,
        itemBuilder: (context, i) {
          final lang = langs[i];
          final isSelected = lang == currentLang;
          return GestureDetector(
            onTap: () => ctrl.changeLanguage(lang),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          cs.primary,
                          cs.primary.withValues(alpha: 0.75),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : cs.secondary,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? cs.surface.withValues(alpha: 0.6)
                      : cs.primary.withValues(alpha: 0.20),
                  width: isSelected ? 1.2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.30),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  LanguageHelper.getLanguageName(lang),
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).hintColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Book accent data ──────────────────────────────────────────────────────────

const _kBookData = [
  _BookAccent(
    color: Color(0xFF3D5A80),
    lightColor: Color(0xFF5B7FA6),
    arabicLabel: 'صحيح البخاري',
    symbol: '☽',
  ),
  _BookAccent(
    color: Color(0xFF4A7C59),
    lightColor: Color(0xFF6BA382),
    arabicLabel: 'صحيح مسلم',
    symbol: '✦',
  ),
  _BookAccent(
    color: Color(0xFF7B4E2D),
    lightColor: Color(0xFFA3724E),
    arabicLabel: 'سنن أبو داود',
    symbol: '❖',
  ),
  _BookAccent(
    color: Color(0xFF4C3A6E),
    lightColor: Color(0xFF705DA0),
    arabicLabel: 'سنن الترمذي',
    symbol: '◈',
  ),
  _BookAccent(
    color: Color(0xFF2D6059),
    lightColor: Color(0xFF4A9088),
    arabicLabel: 'سنن ابن ماجه',
    symbol: '✧',
  ),
  _BookAccent(
    color: Color(0xFF5C3D2E),
    lightColor: Color(0xFF8C6548),
    arabicLabel: 'سنن النسائي',
    symbol: '⬡',
  ),
  _BookAccent(
    color: Color(0xFF1E4D72),
    lightColor: Color(0xFF2E73AA),
    arabicLabel: 'موطأ مالك',
    symbol: '◇',
  ),
];

class _BookAccent {
  final Color color;
  final Color lightColor;
  final String arabicLabel;
  final String symbol;

  const _BookAccent({
    required this.color,
    required this.lightColor,
    required this.arabicLabel,
    required this.symbol,
  });
}

// ── Book card ─────────────────────────────────────────────────────────────────

class _BookCard extends StatelessWidget {
  final String bookSlug;
  final int index;
  final HadithController ctrl;

  const _BookCard({
    required this.bookSlug,
    required this.index,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _kBookData[index % _kBookData.length];
    final totalHadiths = ctrl.hadithCountForBook(bookSlug);

    return Obx(() {
      final isThisLoading = ctrl.loadingBookSlug == bookSlug;

      return GestureDetector(
        onTap: ctrl.isLoadingBook
            ? null
            : () async {
                await ctrl.loadBook(bookSlug);
                if (ctrl.currentBook != null) {
                  Get.to(
                    () => HadithSectionsScreen(bookSlug: bookSlug),
                    transition: Transition.rightToLeft,
                  );
                }
              },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: ctrl.isLoadingBook && !isThisLoading ? 0.40 : 1.0,
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              color: cs.secondary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accent.color.withValues(alpha: isDark ? 0.40 : 0.18),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.color.withValues(alpha: isDark ? 0.18 : 0.10),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  // ── Left accent panel with geometric pattern ──────────────
                  SizedBox(
                    width: 90,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Gradient background
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accent.color, accent.lightColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        // Geometric Islamic pattern overlay
                        CustomPaint(
                          painter: _IslamicPatternPainter(
                            color: Colors.white.withValues(alpha: 0.10),
                          ),
                        ),
                        // Book number badge
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
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
                        ),
                        // Center icon / spinner
                        Center(
                          child: isThisLoading
                              ? const SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const _IslamicStarIcon(
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      accent.symbol,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withValues(
                                          alpha: 0.70,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),

                  // ── Content ───────────────────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Arabic name
                          Text(
                            ctrl.bookArabicName(bookSlug),
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'naskh',
                              fontSize: 17,
                              color: accent.color,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // English / translated name
                          Text(
                            ctrl.bookDisplayName(bookSlug),
                            style: TextStyle(
                              fontFamily: 'kufi',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).hintColor.withValues(alpha: 0.75),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Divider line with ornament
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        accent.color.withValues(alpha: 0.50),
                                        accent.color.withValues(alpha: 0.05),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Stats row
                          Row(
                            children: [
                              // Hadith count
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      accent.color.withValues(alpha: 0.15),
                                      accent.color.withValues(alpha: 0.07),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: accent.color.withValues(alpha: 0.30),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.format_list_bulleted_rounded,
                                      size: 11,
                                      color: accent.color,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$totalHadiths hadiths',
                                      style: TextStyle(
                                        fontFamily: 'kufi',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: accent.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              // Arrow
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: accent.color.withValues(alpha: 0.10),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 12,
                                  color: accent.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ── Islamic 8-pointed star icon drawn with CustomPainter ─────────────────────

class _IslamicStarIcon extends StatelessWidget {
  final Color color;
  final double size;

  const _IslamicStarIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _StarPainter(color: color),
    );
  }
}

class _StarPainter extends CustomPainter {
  final Color color;
  const _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2;
    final innerR = outerR * 0.45;
    const points = 8;

    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final r = i.isEven ? outerR : innerR;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.color != color;
}

// ── Islamic geometric tiling pattern ─────────────────────────────────────────

class _IslamicPatternPainter extends CustomPainter {
  final Color color;
  const _IslamicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const tileSize = 24.0;
    final cols = (size.width / tileSize).ceil() + 1;
    final rows = (size.height / tileSize).ceil() + 1;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final cx = col * tileSize + (row.isOdd ? tileSize / 2 : 0);
        final cy = row * tileSize * 0.85;
        _drawStar(canvas, paint, Offset(cx, cy), tileSize * 0.38);
      }
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double r) {
    const points = 8;
    final innerR = r * 0.45;
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final radius = i.isEven ? r : innerR;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_IslamicPatternPainter old) => old.color != color;
}
