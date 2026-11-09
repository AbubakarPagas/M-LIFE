// ─────────────────────────────────────────────────────────────────────────────
// campaign_model.dart
// Immutable model for a single charity campaign.
// ─────────────────────────────────────────────────────────────────────────────

class CampaignModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String emoji;          // emoji icon used instead of network image
  final double amountRaised;
  final double goalAmount;
  final int donorCount;
  final bool isFeatured;
  final bool isFavorite;

  const CampaignModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.emoji,
    required this.amountRaised,
    required this.goalAmount,
    required this.donorCount,
    this.isFeatured = false,
    this.isFavorite = false,
  });

  double get progress =>
      goalAmount > 0 ? (amountRaised / goalAmount).clamp(0.0, 1.0) : 0.0;

  String get formattedRaised => '\$${_compact(amountRaised)}';
  String get formattedGoal   => '\$${_compact(goalAmount)}';

  String _compact(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000)    return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  CampaignModel copyWith({
    double? amountRaised,
    bool?   isFavorite,
  }) => CampaignModel(
    id: id,
    title: title,
    description: description,
    category: category,
    emoji: emoji,
    amountRaised: amountRaised ?? this.amountRaised,
    goalAmount: goalAmount,
    donorCount: donorCount,
    isFeatured: isFeatured,
    isFavorite: isFavorite ?? this.isFavorite,
  );
}

// ── Campaign categories ───────────────────────────────────────────────────────
abstract class CampaignCategory {
  static const String all               = 'All';
  static const String waterWell         = 'Water Well';
  static const String quranSponsorship  = 'Quran';
  static const String orphanSupport     = 'Orphan';
  static const String mosqueConstruction= 'Mosque';
  static const String islamicEducation  = 'Education';
  static const String emergencyRelief   = 'Emergency';

  static const List<String> values = [
    all,
    waterWell,
    quranSponsorship,
    orphanSupport,
    mosqueConstruction,
    islamicEducation,
    emergencyRelief,
  ];

  static String emoji(String category) {
    switch (category) {
      case waterWell:          return '💧';
      case quranSponsorship:   return '📖';
      case orphanSupport:      return '🤲';
      case mosqueConstruction: return '🕌';
      case islamicEducation:   return '🎓';
      case emergencyRelief:    return '🆘';
      default:                 return '🌙';
    }
  }
}
