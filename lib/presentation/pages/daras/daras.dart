// ─────────────────────────────────────────────────────────────────────────────
// daras.dart — Entry point for the Dars (Islamic Lessons) feature.
// This file re-exports DarsHomeScreen so the existing route registration
// in routes.dart (which imports 'daras.dart') keeps working cleanly.
// ─────────────────────────────────────────────────────────────────────────────

export 'screens/dars_home_screen.dart' show DarsHomeScreen;
