// ─────────────────────────────────────────────────────────────────────────────
// ZakatAssetsModel — holds all zakatable asset categories
// ─────────────────────────────────────────────────────────────────────────────

class ZakatAssetsModel {
  // ── Cash ──────────────────────────────────────────────────────────────────
  final double cashAtHome;
  final double cashInBank;
  final double foreignCurrency;

  // ── Gold ──────────────────────────────────────────────────────────────────
  final double goldWeightGrams;
  final double goldPurity; // percentage 0–100
  final double goldMarketValueOverride; // 0 = use calculated

  // ── Silver ────────────────────────────────────────────────────────────────
  final double silverWeightGrams;
  final double silverMarketValueOverride; // 0 = use calculated

  // ── Investments ───────────────────────────────────────────────────────────
  final double stocks;
  final double mutualFunds;
  final double etfs;
  final double cryptocurrency;

  // ── Business ──────────────────────────────────────────────────────────────
  final double businessInventory;
  final double businessCash;
  final double businessReceivables;

  // ── Income ────────────────────────────────────────────────────────────────
  final double rentalIncome;
  final double savings;

  const ZakatAssetsModel({
    this.cashAtHome = 0,
    this.cashInBank = 0,
    this.foreignCurrency = 0,
    this.goldWeightGrams = 0,
    this.goldPurity = 100,
    this.goldMarketValueOverride = 0,
    this.silverWeightGrams = 0,
    this.silverMarketValueOverride = 0,
    this.stocks = 0,
    this.mutualFunds = 0,
    this.etfs = 0,
    this.cryptocurrency = 0,
    this.businessInventory = 0,
    this.businessCash = 0,
    this.businessReceivables = 0,
    this.rentalIncome = 0,
    this.savings = 0,
  });

  double get totalCash => cashAtHome + cashInBank + foreignCurrency;

  double get totalGold {
    if (goldMarketValueOverride > 0) return goldMarketValueOverride;
    return 0; // calculated externally with live price
  }

  double get totalSilver {
    if (silverMarketValueOverride > 0) return silverMarketValueOverride;
    return 0; // calculated externally with live price
  }

  double get totalInvestments => stocks + mutualFunds + etfs + cryptocurrency;

  double get totalBusiness =>
      businessInventory + businessCash + businessReceivables;

  double get totalIncome => rentalIncome + savings;

  ZakatAssetsModel copyWith({
    double? cashAtHome,
    double? cashInBank,
    double? foreignCurrency,
    double? goldWeightGrams,
    double? goldPurity,
    double? goldMarketValueOverride,
    double? silverWeightGrams,
    double? silverMarketValueOverride,
    double? stocks,
    double? mutualFunds,
    double? etfs,
    double? cryptocurrency,
    double? businessInventory,
    double? businessCash,
    double? businessReceivables,
    double? rentalIncome,
    double? savings,
  }) {
    return ZakatAssetsModel(
      cashAtHome: cashAtHome ?? this.cashAtHome,
      cashInBank: cashInBank ?? this.cashInBank,
      foreignCurrency: foreignCurrency ?? this.foreignCurrency,
      goldWeightGrams: goldWeightGrams ?? this.goldWeightGrams,
      goldPurity: goldPurity ?? this.goldPurity,
      goldMarketValueOverride:
          goldMarketValueOverride ?? this.goldMarketValueOverride,
      silverWeightGrams: silverWeightGrams ?? this.silverWeightGrams,
      silverMarketValueOverride:
          silverMarketValueOverride ?? this.silverMarketValueOverride,
      stocks: stocks ?? this.stocks,
      mutualFunds: mutualFunds ?? this.mutualFunds,
      etfs: etfs ?? this.etfs,
      cryptocurrency: cryptocurrency ?? this.cryptocurrency,
      businessInventory: businessInventory ?? this.businessInventory,
      businessCash: businessCash ?? this.businessCash,
      businessReceivables: businessReceivables ?? this.businessReceivables,
      rentalIncome: rentalIncome ?? this.rentalIncome,
      savings: savings ?? this.savings,
    );
  }

  Map<String, dynamic> toJson() => {
    'cashAtHome': cashAtHome,
    'cashInBank': cashInBank,
    'foreignCurrency': foreignCurrency,
    'goldWeightGrams': goldWeightGrams,
    'goldPurity': goldPurity,
    'goldMarketValueOverride': goldMarketValueOverride,
    'silverWeightGrams': silverWeightGrams,
    'silverMarketValueOverride': silverMarketValueOverride,
    'stocks': stocks,
    'mutualFunds': mutualFunds,
    'etfs': etfs,
    'cryptocurrency': cryptocurrency,
    'businessInventory': businessInventory,
    'businessCash': businessCash,
    'businessReceivables': businessReceivables,
    'rentalIncome': rentalIncome,
    'savings': savings,
  };

  factory ZakatAssetsModel.fromJson(Map<String, dynamic> json) =>
      ZakatAssetsModel(
        cashAtHome: (json['cashAtHome'] as num?)?.toDouble() ?? 0,
        cashInBank: (json['cashInBank'] as num?)?.toDouble() ?? 0,
        foreignCurrency: (json['foreignCurrency'] as num?)?.toDouble() ?? 0,
        goldWeightGrams: (json['goldWeightGrams'] as num?)?.toDouble() ?? 0,
        goldPurity: (json['goldPurity'] as num?)?.toDouble() ?? 100,
        goldMarketValueOverride:
            (json['goldMarketValueOverride'] as num?)?.toDouble() ?? 0,
        silverWeightGrams: (json['silverWeightGrams'] as num?)?.toDouble() ?? 0,
        silverMarketValueOverride:
            (json['silverMarketValueOverride'] as num?)?.toDouble() ?? 0,
        stocks: (json['stocks'] as num?)?.toDouble() ?? 0,
        mutualFunds: (json['mutualFunds'] as num?)?.toDouble() ?? 0,
        etfs: (json['etfs'] as num?)?.toDouble() ?? 0,
        cryptocurrency: (json['cryptocurrency'] as num?)?.toDouble() ?? 0,
        businessInventory: (json['businessInventory'] as num?)?.toDouble() ?? 0,
        businessCash: (json['businessCash'] as num?)?.toDouble() ?? 0,
        businessReceivables:
            (json['businessReceivables'] as num?)?.toDouble() ?? 0,
        rentalIncome: (json['rentalIncome'] as num?)?.toDouble() ?? 0,
        savings: (json['savings'] as num?)?.toDouble() ?? 0,
      );
}
