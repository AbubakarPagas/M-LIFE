// ─────────────────────────────────────────────────────────────────────────────
// MetalPriceModel — live gold & silver prices per gram
// ─────────────────────────────────────────────────────────────────────────────

class MetalPriceModel {
  /// Price per gram in the selected currency
  final double goldPerGram;
  final double silverPerGram;
  final String currency;
  final DateTime fetchedAt;
  final bool isFromCache;

  // Nisab thresholds
  // Gold Nisab = 85 grams of gold
  // Silver Nisab = 595 grams of silver
  static const double goldNisabGrams = 85.0;
  static const double silverNisabGrams = 595.0;

  const MetalPriceModel({
    required this.goldPerGram,
    required this.silverPerGram,
    required this.currency,
    required this.fetchedAt,
    this.isFromCache = false,
  });

  double get goldNisabValue => goldPerGram * goldNisabGrams;
  double get silverNisabValue => silverPerGram * silverNisabGrams;

  MetalPriceModel copyWith({
    double? goldPerGram,
    double? silverPerGram,
    String? currency,
    DateTime? fetchedAt,
    bool? isFromCache,
  }) {
    return MetalPriceModel(
      goldPerGram: goldPerGram ?? this.goldPerGram,
      silverPerGram: silverPerGram ?? this.silverPerGram,
      currency: currency ?? this.currency,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  Map<String, dynamic> toJson() => {
    'goldPerGram': goldPerGram,
    'silverPerGram': silverPerGram,
    'currency': currency,
    'fetchedAt': fetchedAt.toIso8601String(),
  };

  factory MetalPriceModel.fromJson(Map<String, dynamic> json) =>
      MetalPriceModel(
        goldPerGram: (json['goldPerGram'] as num).toDouble(),
        silverPerGram: (json['silverPerGram'] as num).toDouble(),
        currency: json['currency'] as String,
        fetchedAt: DateTime.parse(json['fetchedAt'] as String),
        isFromCache: true,
      );

  /// Fallback prices (USD) used when offline and no cache exists
  factory MetalPriceModel.fallback() => MetalPriceModel(
    goldPerGram: 62.0, // approx USD per gram
    silverPerGram: 0.80,
    currency: 'USD',
    fetchedAt: DateTime.now(),
    isFromCache: true,
  );
}
