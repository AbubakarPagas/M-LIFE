// ─────────────────────────────────────────────────────────────────────────────
// ZakatLiabilitiesModel — deductible liabilities
// ─────────────────────────────────────────────────────────────────────────────

class ZakatLiabilitiesModel {
  final double shortTermDebts;
  final double billsDue;
  final double businessExpenses;
  final double loansPayable;
  final double otherLiabilities;

  const ZakatLiabilitiesModel({
    this.shortTermDebts = 0,
    this.billsDue = 0,
    this.businessExpenses = 0,
    this.loansPayable = 0,
    this.otherLiabilities = 0,
  });

  double get total =>
      shortTermDebts +
      billsDue +
      businessExpenses +
      loansPayable +
      otherLiabilities;

  ZakatLiabilitiesModel copyWith({
    double? shortTermDebts,
    double? billsDue,
    double? businessExpenses,
    double? loansPayable,
    double? otherLiabilities,
  }) {
    return ZakatLiabilitiesModel(
      shortTermDebts: shortTermDebts ?? this.shortTermDebts,
      billsDue: billsDue ?? this.billsDue,
      businessExpenses: businessExpenses ?? this.businessExpenses,
      loansPayable: loansPayable ?? this.loansPayable,
      otherLiabilities: otherLiabilities ?? this.otherLiabilities,
    );
  }

  Map<String, dynamic> toJson() => {
    'shortTermDebts': shortTermDebts,
    'billsDue': billsDue,
    'businessExpenses': businessExpenses,
    'loansPayable': loansPayable,
    'otherLiabilities': otherLiabilities,
  };

  factory ZakatLiabilitiesModel.fromJson(Map<String, dynamic> json) =>
      ZakatLiabilitiesModel(
        shortTermDebts: (json['shortTermDebts'] as num?)?.toDouble() ?? 0,
        billsDue: (json['billsDue'] as num?)?.toDouble() ?? 0,
        businessExpenses: (json['businessExpenses'] as num?)?.toDouble() ?? 0,
        loansPayable: (json['loansPayable'] as num?)?.toDouble() ?? 0,
        otherLiabilities: (json['otherLiabilities'] as num?)?.toDouble() ?? 0,
      );
}
