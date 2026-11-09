// ─────────────────────────────────────────────────────────────────────────────
// ZakatCalculator — pure domain logic, no Flutter dependencies
// ─────────────────────────────────────────────────────────────────────────────

import '../data/models/metal_price_model.dart';
import '../data/models/zakat_assets_model.dart';
import '../data/models/zakat_calculation_model.dart';
import '../data/models/zakat_liabilities_model.dart';

class ZakatCalculator {
  /// Zakat rate: 2.5%
  static const double zakatRate = 0.025;

  /// Perform a full Zakat calculation.
  static ZakatCalculationModel calculate({
    required ZakatAssetsModel assets,
    required ZakatLiabilitiesModel liabilities,
    required MetalPriceModel metalPrices,
    required NisabMethod nisabMethod,
    required String currency,
    String? id,
  }) {
    final calcId = id ?? _generateId();

    // ── Gold value ────────────────────────────────────────────────────────────
    final double goldValue = assets.goldMarketValueOverride > 0
        ? assets.goldMarketValueOverride
        : assets.goldWeightGrams *
              (assets.goldPurity / 100) *
              metalPrices.goldPerGram;

    // ── Silver value ─────────────────────────────────────────────────────────
    final double silverValue = assets.silverMarketValueOverride > 0
        ? assets.silverMarketValueOverride
        : assets.silverWeightGrams * metalPrices.silverPerGram;

    // ── Total assets ─────────────────────────────────────────────────────────
    final double totalAssets =
        assets.totalCash +
        goldValue +
        silverValue +
        assets.totalInvestments +
        assets.totalBusiness +
        assets.totalIncome;

    // ── Total liabilities ────────────────────────────────────────────────────
    final double totalLiabilities = liabilities.total;

    // ── Net wealth ───────────────────────────────────────────────────────────
    final double netWealth = (totalAssets - totalLiabilities).clamp(
      0,
      double.infinity,
    );

    // ── Nisab value ──────────────────────────────────────────────────────────
    final double nisabValue = nisabMethod == NisabMethod.gold
        ? metalPrices.goldNisabValue
        : metalPrices.silverNisabValue;

    // ── Zakat obligation ─────────────────────────────────────────────────────
    final bool isObligatory = netWealth >= nisabValue;

    // ── Zakat due ────────────────────────────────────────────────────────────
    final double zakatDue = isObligatory ? netWealth * zakatRate : 0;

    return ZakatCalculationModel(
      id: calcId,
      calculatedAt: DateTime.now(),
      assets: assets,
      liabilities: liabilities,
      goldPricePerGram: metalPrices.goldPerGram,
      silverPricePerGram: metalPrices.silverPerGram,
      nisabMethod: nisabMethod,
      totalAssets: totalAssets,
      totalLiabilities: totalLiabilities,
      netWealth: netWealth,
      nisabValue: nisabValue,
      isZakatObligatory: isObligatory,
      zakatDue: zakatDue,
      currency: currency,
    );
  }

  static String _generateId() {
    return 'zakat_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Quick check: is the given net wealth above Nisab?
  static bool isAboveNisab(
    double netWealth,
    MetalPriceModel prices,
    NisabMethod method,
  ) {
    final nisab = method == NisabMethod.gold
        ? prices.goldNisabValue
        : prices.silverNisabValue;
    return netWealth >= nisab;
  }

  /// Calculate Zakat due from net wealth directly.
  static double calculateZakatFromWealth(double netWealth) {
    if (netWealth <= 0) return 0;
    return netWealth * zakatRate;
  }
}
