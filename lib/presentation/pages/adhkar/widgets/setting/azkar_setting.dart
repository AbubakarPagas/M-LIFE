import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:misbah_path/presentation/controllers/general/general_controller.dart';
import 'package:misbah_path/presentation/pages/quran_page/quran.dart';

import '../../../../../core/widgets/select_screen_build.dart';
import '../../../../controllers/theme_controller.dart';
import '../../controller/adhkar_controller.dart';

class AzkarSetting extends StatelessWidget {
  AzkarSetting({Key? key}) : super(key: key);
  final generalCtrl = GeneralController.instance;
  final quranCtrl = QuranController.instance;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cs = Theme.of(context).colorScheme;
    final azkarCtrl = AzkarController.instance;

    return GetBuilder<ThemeController>(
      builder: (_) {
        return Container(
          height: size.height * .72,
          width: size.width,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Container()
        /*   SafeArea(
            child: Obx(
              () => generalCtrl.state.screenSelectedValue.value.showSelectScreenPage.value
                  ? const SelectScreenBuild(isButtonBack: true, isButton: false)
                  : Column(
                      children: [
                        // ── Geometric header ──────────────────────────────
                        _IslamicHeader(cs: cs),

                        // ── Settings list ─────────────────────────────────
                        Flexible(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            children: [
                              // ── Section label ────────────────────────────
                              _SectionLabel(
                                label: 'Display'.tr,
                                arabicLabel: 'العرض',
                                cs: cs,
                              ),
                              const Gap(10),

                              // ── Language toggle card ──────────────────────
                              Obx(
                                () => _LanguageSettingRow(
                                  isEnglish: azkarCtrl.isEnglish,
                                  onToggle: azkarCtrl.toggleLanguage,
                                  cs: cs,
                                ),
                              ),

                              const Gap(28),

                              // ── Islamic divider ornament ──────────────────
                              _OrnamentsividerRow(cs: cs),

                              const Gap(28),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ), */
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header with geometric Islamic pattern strip
// ─────────────────────────────────────────────────────────────────────────────

class _IslamicHeader extends StatelessWidget {
  final ColorScheme cs;
  const _IslamicHeader({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Geometric pattern background strip
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 100,
            child: CustomPaint(
              painter: _GeometricPatternPainter(
                color: cs.primary.withValues(alpha: 0.06),
              ),
            ),
          ),
        ),

        // Gradient overlay at bottom of header
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 36,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cs.primaryContainer.withValues(alpha: 0.0),
                  cs.primaryContainer,
                ],
              ),
            ),
          ),
        ),

        // Handle bar
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),

        // Title row
        Positioned(
          bottom: 14,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Close button
                _CircleIconButton(
                  icon: Icons.close_rounded,
                  cs: cs,
                  onTap: () => Get.back(),
                ),
                const Gap(14),

                // Arabic ornament + title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إعدادات الأذكار',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        'Azkar Settings',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: cs.primary.withValues(alpha: 0.50),
                        ),
                      ),
                    ],
                  ),
                ),

                // Islamic star ornament
                _StarOrnament(cs: cs),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label with Arabic sub-label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final String arabicLabel;
  final ColorScheme cs;

  const _SectionLabel({
    required this.label,
    required this.arabicLabel,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 22,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [cs.surface, cs.surface.withValues(alpha: 0.4)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Gap(10),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: cs.primary.withValues(alpha: 0.55),
            letterSpacing: 0.8,
          ),
        ),
        const Gap(6),
        Text(
          '· $arabicLabel',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'naskh',
            fontSize: 13,
            color: cs.surface.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Language setting row — full-width elegant card
// ─────────────────────────────────────────────────────────────────────────────

class _LanguageSettingRow extends StatelessWidget {
  final bool isEnglish;
  final VoidCallback onToggle;
  final ColorScheme cs;

  const _LanguageSettingRow({
    required this.isEnglish,
    required this.onToggle,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: isDark ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.surface.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          // ── Row header ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cs.primary.withValues(alpha: 0.14),
                        cs.primary.withValues(alpha: 0.07),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.18),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'ع',
                      style: TextStyle(
                        fontFamily: 'naskh',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'لغة الأذكار',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        'Azkar language display',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 11,
                          color: cs.primary.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
                // Current badge
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey(isEnglish),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.18),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isEnglish ? 'EN' : 'AR',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Thin ornamental divider ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 0.8,
                    color: cs.surface.withValues(alpha: 0.20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 10,
                    color: cs.surface.withValues(alpha: 0.50),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 0.8,
                    color: cs.surface.withValues(alpha: 0.20),
                  ),
                ),
              ],
            ),
          ),

          // ── Segmented toggle ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: GestureDetector(
              onTap: onToggle,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: isDark ? 0.12 : 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Sliding pill
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeInOutCubic,
                      alignment: isEnglish
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                cs.primary,
                                Color.lerp(cs.primary, cs.surface, 0.25)!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withValues(alpha: 0.30),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Labels
                    Row(
                      children: [
                        // Arabic side (left in LTR layout)
                        Expanded(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 220),
                            style: TextStyle(
                              fontFamily: 'naskh',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isEnglish
                                  ? cs.primary.withValues(alpha: 0.40)
                                  : Colors.white,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text('العربية')],
                            ),
                          ),
                        ),

                        // English side
                        Expanded(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 220),
                            style: TextStyle(
                              fontFamily: 'kufi',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isEnglish
                                  ? Colors.white
                                  : cs.primary.withValues(alpha: 0.40),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text('English')],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Active state hint ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 14, right: 14),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Container(
                key: ValueKey(isEnglish),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: cs.surface,
                    ),
                    const Gap(8),
                    Text(
                      isEnglish
                          ? 'Displaying Azkar in English'
                          : 'عرض الأذكار باللغة العربية',
                      textDirection: isEnglish
                          ? TextDirection.ltr
                          : TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: isEnglish ? 'kufi' : 'naskh',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.primary.withValues(alpha: 0.70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ornamental divider row  ✦ — — ✦ — — ✦
// ─────────────────────────────────────────────────────────────────────────────

class _OrnamentsividerRow extends StatelessWidget {
  final ColorScheme cs;
  const _OrnamentsividerRow({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(cs),
        const Gap(8),
        _line(cs),
        const Gap(8),
        _dot(cs, large: true),
        const Gap(8),
        _line(cs),
        const Gap(8),
        _dot(cs),
      ],
    );
  }

  Widget _dot(ColorScheme cs, {bool large = false}) => Container(
    width: large ? 6 : 4,
    height: large ? 6 : 4,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: cs.surface.withValues(alpha: large ? 0.55 : 0.35),
    ),
  );

  Widget _line(ColorScheme cs) => Container(
    width: 40,
    height: 1,
    color: cs.surface.withValues(alpha: 0.25),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Small circle icon button
// ─────────────────────────────────────────────────────────────────────────────

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Icon(icon, size: 18, color: cs.primary),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Decorative 8-pointed Islamic star
// ─────────────────────────────────────────────────────────────────────────────

class _StarOrnament extends StatelessWidget {
  final ColorScheme cs;
  const _StarOrnament({required this.cs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: CustomPaint(
        painter: _IslamicStarPainter(color: cs.surface.withValues(alpha: 0.50)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter — 8-pointed Islamic star
// ─────────────────────────────────────────────────────────────────────────────

class _IslamicStarPainter extends CustomPainter {
  final Color color;
  _IslamicStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2;
    final innerR = outerR * 0.42;
    const points = 8;

    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = (math.pi / points) * i - math.pi / 2;
      final r = (i.isEven) ? outerR : innerR;
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
  bool shouldRepaint(covariant _IslamicStarPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter — repeating Islamic geometric pattern background
// ─────────────────────────────────────────────────────────────────────────────

class _GeometricPatternPainter extends CustomPainter {
  final Color color;
  _GeometricPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const cellSize = 28.0;
    final cols = (size.width / cellSize).ceil() + 1;
    final rows = (size.height / cellSize).ceil() + 1;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final cx = col * cellSize + (row.isOdd ? cellSize / 2 : 0.0);
        final cy = row * cellSize;
        _drawStar(canvas, paint, cx, cy, cellSize * 0.38);
      }
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double cx, double cy, double r) {
    const pts = 8;
    final innerR = r * 0.45;
    final path = Path();
    for (int i = 0; i < pts * 2; i++) {
      final angle = (math.pi / pts) * i - math.pi / 2;
      final radius = i.isEven ? r : innerR;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
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
  bool shouldRepaint(covariant _GeometricPatternPainter old) =>
      old.color != color;
}
