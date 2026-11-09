/// Adhan screen design tokens.
///
/// Follows the same theme-aware approach as the Tasbih page:
/// - backgroundColor = theme.colorScheme.secondary
/// - cards / containers = cs.surfaceContainer or cs.primaryContainer
/// - accent = cs.primary
/// - gold = const Color(0xffCDAD80)  (universal across all themes)
library adhan_theme;

import 'package:flutter/material.dart';

// ── Universal gold constant (same as Tasbih page) ─────────────────────────────
const kAdhanGold = Color(0xffCDAD80);
const kAdhanGoldLight = Color(0xffE8C97A);
const kAdhanGoldDeep = Color(0xffA8873A);

// ── Static colour constants kept for painters (no BuildContext) ───────────────
class AdhanColors {
  AdhanColors._();

  static const gold = kAdhanGold;
  static const goldLight = kAdhanGoldLight;
  static const goldDeep = kAdhanGoldDeep;
  static const goldPale = Color(0xFFF5EAD6);

  // Status
  static const successGreen = Color(0xFF4CAF87);
  static const completedGrey = Color(0xFF8A9E8F);

  // Pure white for countdown text (always on dark circle)
  static const pureWhite = Color(0xFFFFFFFF);

  // Legacy aliases — kept so existing code compiles without changes
  static const emeraldDark = Color(0xFF0A3D2B);
  static const emerald = Color(0xFF0D5C3D);
  static const emeraldMid = Color(0xFF0E7C53);
  static const emeraldLight = Color(0xFF10A36C);
  static const emeraldGlow = Color(0xFF1ABA78);
  static const deepBlue = Color(0xFF0B1B3B);
  static const royalBlue = Color(0xFF1B3A6B);
  static const softWhite = Color(0xFFF0F4F0);
  static const warmWhite = Color(0xFFF7F4EE);
  static const mutedWhite = Color(0xCCFFFFFF);
  static const textOnAccent = pureWhite;
  static const glassLight = Color(0x1AFFFFFF);
  static const glassMid = Color(0x26FFFFFF);
  static const glassDark = Color(0x33FFFFFF);
  static const bgCard = Color(0x1AFFFFFF);
  static const bgCardAlt = Color(0x0DFFFFFF);
  static const borderSoft = Color(0x22FFFFFF);
  static const borderGold = Color(0x4DCDAD80);
  static const bgDeep = Color(0xFF0C1E15);
  static const bgMid = Color(0xFF112219);
  static const bgShade = Color(0xFF0F2B34);
  static const bgPage = bgDeep;
  static const bgGradientTop = bgDeep;
  static const bgGradientMid = bgMid;
  static const bgGradientBottom = bgShade;
  static const primary = emeraldMid;
  static const primaryLight = emeraldLight;
  static const primaryDark = emeraldDark;
  static const primaryFaint = Color(0x1A0D5C3D);
  static const primarySoft = Color(0x260D5C3D);
  static const goldFaint = Color(0x1ACDAD80);
  static const goldSoft = Color(0x33CDAD80);
  static const textPrimary = pureWhite;
  static const textSecondary = softWhite;
  static const textMuted = mutedWhite;
  static const divider = glassDark;
  static const activeGold = gold;
}

// ── Gradient helpers (static / const — used by painters) ─────────────────────
class AdhanGradients {
  AdhanGradients._();

  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AdhanColors.bgDeep, AdhanColors.bgMid, AdhanColors.bgShade],
    stops: [0.0, 0.55, 1.0],
  );

  static const header = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AdhanColors.emerald,
      AdhanColors.emeraldMid,
      AdhanColors.emeraldDark,
    ],
    stops: [0.0, 0.5, 1.0],
  );
}

// ── Text style helpers ────────────────────────────────────────────────────────
class AdhanTextStyles {
  AdhanTextStyles._();

  static const countdownDisplay = TextStyle(
    fontSize: 58,
    fontWeight: FontWeight.w200,
    color: AdhanColors.pureWhite,
    letterSpacing: 5,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // Context-aware helpers — call with cs.primary or gold as needed
  static TextStyle prayerNameActive({required Color color}) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: color,
    letterSpacing: 0.6,
    fontFamily: 'kufi',
  );

  static TextStyle prayerNameNormal({required Color color}) => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: color,
    letterSpacing: 0.3,
    fontFamily: 'kufi',
  );

  static TextStyle prayerTime({required Color color}) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: color,
    fontFamily: 'kufi',
  );

  static TextStyle statusLabel({required Color color}) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: color,
    letterSpacing: 2.2,
    fontFamily: 'kufi',
  );

  static TextStyle sectionTitle({required Color color}) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: color,
    letterSpacing: 1.2,
    fontFamily: 'kufi',
  );
}

// ── BoxDecoration helpers (context-aware) ─────────────────────────────────────
class AdhanDecorations {
  AdhanDecorations._();

  /// Standard card — matches Tasbih surfaceContainer card style
  static BoxDecoration card({
    required ColorScheme cs,
    bool isDark = false,
    double radius = 18,
  }) => BoxDecoration(
    color: cs.surfaceContainer,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: cs.primary.withValues(alpha: 0.12), width: 1),
    boxShadow: [
      BoxShadow(
        color: cs.primary.withValues(alpha: isDark ? 0.10 : 0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  /// Active / highlighted card
  static BoxDecoration activeCard({
    required ColorScheme cs,
    bool isDark = false,
    double radius = 18,
  }) => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        cs.primary.withValues(alpha: isDark ? 0.30 : 0.14),
        cs.primary.withValues(alpha: isDark ? 0.20 : 0.08),
      ],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: cs.primary.withValues(alpha: 0.45), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: cs.primary.withValues(alpha: isDark ? 0.20 : 0.10),
        blurRadius: 18,
        spreadRadius: 1,
      ),
    ],
  );

  /// Gold-tinted banner card (like the Dhikr header in Tasbih)
  static BoxDecoration goldBanner({
    required ColorScheme cs,
    double radius = 18,
  }) => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        cs.primary.withValues(alpha: 0.08),
        cs.primary.withValues(alpha: 0.03),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: kAdhanGold.withValues(alpha: 0.20), width: 1),
  );

  // Legacy static accessors kept for backward compat
  static BoxDecoration get glassCard => BoxDecoration(
    color: AdhanColors.glassMid,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AdhanColors.glassDark, width: 1),
  );

  static BoxDecoration get activeGlassCard => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x440D5C3D), Color(0x330E7C53), Color(0x220B2E46)],
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AdhanColors.emeraldGlow, width: 1.5),
  );
}
