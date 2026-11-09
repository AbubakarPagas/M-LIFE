// ─────────────────────────────────────────────────────────────────────────────
// HalalHaramModel — an entry in the Halal vs Haram section
// ─────────────────────────────────────────────────────────────────────────────

class HalalHaramEntry {
  final String title;
  final String explanation;
  final bool isHalal;
  final String? reference;

  const HalalHaramEntry({
    required this.title,
    required this.explanation,
    required this.isHalal,
    this.reference,
  });
}
