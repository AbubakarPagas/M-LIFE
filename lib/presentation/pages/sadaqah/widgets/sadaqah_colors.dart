// ─────────────────────────────────────────────────────────────────────────────
// sadaqah_colors.dart  —  colour tokens for the Sadaqah feature.
// All colours respect the existing app-theme gold-accent convention.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

abstract class SadaqahColors {
  // Gold accent shared across all app themes.
  static const gold       = Color(0xFFCDAD80);
  static const goldDark   = Color(0xFFB8955E);
  static const goldLight  = Color(0xFFE8D4A8);

  // Teal/emerald progress fill.
  static const teal       = Color(0xFF2E8B6E);
  static const tealLight  = Color(0xFF4CAF8A);

  // Background gradients.
  static const headerTop  = Color(0xFF1A2744);
  static const headerBot  = Color(0xFF2C3E6B);

  // Soft semantic colours.
  static const success    = Color(0xFF4CAF50);
  static const urgent     = Color(0xFFE53935);
}
