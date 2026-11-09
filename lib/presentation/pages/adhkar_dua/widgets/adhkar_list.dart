import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../controller/adhkar_dua_controller.dart';
import '../screens/adhkar_item.dart';

// ─── Shared gold token ────────────────────────────────────────────────────────
// Matches the app-wide kZekrGold / dividerColor used across all themes.
const _kGold = Color(0xFFCDAD80);

// ─── Category → icon + subtitle ──────────────────────────────────────────────

class _CategoryMeta {
  final IconData icon;
  final String label;
  const _CategoryMeta({required this.icon, required this.label});
}

_CategoryMeta _metaFor(String cat) {
  final s = cat.toLowerCase();
  if (s.contains('صباح') || s.contains('morning')) {
    return const _CategoryMeta(
      icon: Icons.wb_sunny_rounded,
      label: 'أذكار الصباح',
    );
  }
  if (s.contains('مساء') || s.contains('evening')) {
    return const _CategoryMeta(
      icon: Icons.nights_stay_rounded,
      label: 'أذكار المساء',
    );
  }
  if (s.contains('نوم') || s.contains('sleep')) {
    return const _CategoryMeta(
      icon: Icons.bedtime_rounded,
      label: 'أذكار النوم',
    );
  }
  if (s.contains('صلاة') || s.contains('prayer')) {
    return const _CategoryMeta(
      icon: Icons.mosque_rounded,
      label: 'أذكار الصلاة',
    );
  }
  if (s.contains('قرآن') || s.contains('quran')) {
    return const _CategoryMeta(
      icon: Icons.menu_book_rounded,
      label: 'أذكار القرآن',
    );
  }
  if (s.contains('دعاء') || s.contains('dua')) {
    return const _CategoryMeta(
      icon: Icons.volunteer_activism_rounded,
      label: 'الأدعية',
    );
  }
  if (s.contains('سفر') || s.contains('travel')) {
    return const _CategoryMeta(
      icon: Icons.flight_rounded,
      label: 'أذكار السفر',
    );
  }
  if (s.contains('أكل') || s.contains('طعام') || s.contains('food')) {
    return const _CategoryMeta(
      icon: Icons.restaurant_rounded,
      label: 'أذكار الطعام',
    );
  }
  if (s.contains('مطر') || s.contains('rain')) {
    return const _CategoryMeta(
      icon: Icons.water_drop_rounded,
      label: 'أذكار المطر',
    );
  }
  return const _CategoryMeta(
    icon: Icons.auto_stories_rounded,
    label: 'الأذكار والأدعية',
  );
}

// ─── AdhkarList ───────────────────────────────────────────────────────────────

class AdhkarList extends StatelessWidget {
  const AdhkarList({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = AzkarDuaController.instance;

    return AnimationLimiter(
      child: Obx(() {
        final categories = ctrl.state.categories;
        return ListView.builder(
          controller: ctrl.state.listController,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
          itemCount: categories.length,
          itemBuilder: (context, i) {
            final cat = categories[i].toString();
            return AnimationConfiguration.staggeredList(
              position: i,
              duration: const Duration(milliseconds: 420),
              child: SlideAnimation(
                verticalOffset: 44,
                child: FadeInAnimation(
                  child: _AdhkarCard(
                    category: cat,
                    meta: _metaFor(cat),
                    index: i,
                    onTap: () {
                      ctrl.filterByCategory(cat);
                      Get.to(
                        const AdhkarItem(),
                        transition: Transition.rightToLeft,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _AdhkarCard extends StatelessWidget {
  final String category;
  final _CategoryMeta meta;
  final int index;
  final VoidCallback onTap;

  const _AdhkarCard({
    required this.category,
    required this.meta,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ── Card surface: each theme defines this as its light panel color ───────
    // blueTheme  → #FFFFFF   brownTheme → #FDF7F4
    // oldTheme   → #f3efdf   darkTheme  → #1E1E1E
    final cardBg = cs.primaryContainer;

    // ── Gold accent — always #CDAD80 (matches app divider color) ────────────
    const gold = _kGold;

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: gold.withValues(alpha: 0.10),
          highlightColor: gold.withValues(alpha: 0.06),
          child: Ink(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: gold.withValues(alpha: 0.28), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: gold.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 96,
                child: Stack(
                  children: [
                    // ── Watermark star (top-right corner) ──────────────────
                    Positioned(
                      right: -8,
                      top: -8,
                      child: CustomPaint(
                        size: const Size(88, 88),
                        painter: _StarWatermark(
                          color: gold.withValues(alpha: 0.06),
                        ),
                      ),
                    ),

                    // ── Left accent bar ────────────────────────────────────
                    Positioned(
                      left: 0,
                      top: 14,
                      bottom: 14,
                      child: Container(
                        width: 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              gold.withValues(alpha: 0.10),
                              gold.withValues(alpha: 0.80),
                              gold.withValues(alpha: 0.10),
                            ],
                          ),
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(3),
                          ),
                        ),
                      ),
                    ),

                    // ── Main content ───────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _IconBadge(icon: meta.icon, index: index),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _CardTexts(
                              category: category,
                              label: meta.label,
                              cs: cs,
                            ),
                          ),
                          const _ArrowButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Icon badge ───────────────────────────────────────────────────────────────

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final int index;

  const _IconBadge({required this.icon, required this.index});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const gold = _kGold;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Octagon outline
        SizedBox(
          width: 58,
          height: 58,
          child: CustomPaint(
            painter: _OctagonPainter(color: gold.withValues(alpha: 0.35)),
          ),
        ),
        // Inner icon circle
        Positioned(
          left: 5,
          top: 5,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primary.withValues(alpha: 0.10),
              border: Border.all(color: gold.withValues(alpha: 0.40), width: 1),
            ),
            child: Icon(icon, color: gold, size: 22),
          ),
        ),
        // Index chip
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gold,
              boxShadow: [
                BoxShadow(color: gold.withValues(alpha: 0.45), blurRadius: 6),
              ],
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2E3850),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Card texts ───────────────────────────────────────────────────────────────

class _CardTexts extends StatelessWidget {
  final String category;
  final String label;
  final ColorScheme cs;

  const _CardTexts({
    required this.category,
    required this.label,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    const gold = _kGold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Subtitle chip
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _kGold,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: gold.withValues(alpha: 0.85),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        // Category name
        // cs.primary is the dark theme color in every theme — readable on
        // the light primaryContainer card surface.
        Text(
          category.tr,
          textDirection: TextDirection.rtl,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'naskh',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: cs.primary,
            height: 1.3,
          ),
        ),

        const SizedBox(height: 6),

        // Gold separator
        Container(
          height: 1,
          width: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gold.withValues(alpha: 0.80), Colors.transparent],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}

// ─── Arrow button ─────────────────────────────────────────────────────────────

class _ArrowButton extends StatelessWidget {
  const _ArrowButton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const gold = _kGold;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cs.primary.withValues(alpha: 0.10),
        border: Border.all(color: gold.withValues(alpha: 0.35), width: 1),
      ),
      child: const Icon(
        Icons.arrow_back_ios_new_rounded,
        size: 13,
        color: _kGold,
      ),
    );
  }
}

// ─── Star watermark ───────────────────────────────────────────────────────────

class _StarWatermark extends CustomPainter {
  final Color color;
  const _StarWatermark({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.46;
    final inner = r * 0.42;
    final path = Path();

    for (int i = 0; i < 16; i++) {
      final angle = (i * math.pi / 8) - math.pi / 2;
      final radius = i.isEven ? r : inner;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, p);

    // inner ring
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.65,
      Paint()
        ..color = color.withValues(alpha: color.a * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );
  }

  @override
  bool shouldRepaint(covariant _StarWatermark old) => old.color != color;
}

// ─── Octagon painter ─────────────────────────────────────────────────────────

class _OctagonPainter extends CustomPainter {
  final Color color;
  const _OctagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.2
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
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _OctagonPainter old) => old.color != color;
}
