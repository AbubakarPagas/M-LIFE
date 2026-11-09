// ─────────────────────────────────────────────────────────────────────────────
// ZakatController — GetX controller wiring data, domain & UI state
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../data/models/metal_price_model.dart';
import '../data/models/zakat_assets_model.dart';
import '../data/models/zakat_calculation_model.dart';
import '../data/models/zakat_liabilities_model.dart';
import '../data/services/metal_price_service.dart';
import '../data/services/zakat_storage_service.dart';
import '../domain/zakat_calculator.dart';

class ZakatController extends GetxController {
  static ZakatController get instance => Get.find<ZakatController>();

  final _metalService = MetalPriceService();
  final _storage = ZakatStorageService();

  // ── Reactive state ────────────────────────────────────────────────────────
  final Rx<ZakatAssetsModel> assets = const ZakatAssetsModel().obs;
  final Rx<ZakatLiabilitiesModel> liabilities =
      const ZakatLiabilitiesModel().obs;
  final Rx<MetalPriceModel?> metalPrices = Rx<MetalPriceModel?>(null);
  final Rx<ZakatCalculationModel?> lastResult = Rx<ZakatCalculationModel?>(
    null,
  );
  final RxList<ZakatCalculationModel> history = <ZakatCalculationModel>[].obs;
  final Rx<ZakatSettings> settings = ZakatSettings.defaults().obs;

  final RxBool isLoadingPrices = false.obs;
  final RxBool isSaving = false.obs;
  final RxString priceError = ''.obs;
  final RxBool pricesFromCache = false.obs;

  // ── Form controllers (reused across asset input page) ─────────────────────
  // We expose only a generic update API; input widgets call updateAsset/updateLiability

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    settings.value = await _storage.loadSettings();
    history.value = await _storage.loadHistory();
    if (history.isNotEmpty) lastResult.value = history.first;
    await fetchMetalPrices();
  }

  // ── Metal prices ─────────────────────────────────────────────────────────

  Future<void> fetchMetalPrices({bool forceRefresh = false}) async {
    isLoadingPrices.value = true;
    priceError.value = '';
    try {
      final prices = await _metalService.fetchPrices(
        currency: settings.value.currency,
        forceRefresh: forceRefresh,
      );
      metalPrices.value = prices;
      pricesFromCache.value = prices.isFromCache;
    } catch (e) {
      priceError.value = 'Unable to fetch metal prices';
      metalPrices.value = MetalPriceModel.fallback();
      pricesFromCache.value = true;
    } finally {
      isLoadingPrices.value = false;
    }
  }

  // ── Asset updates ─────────────────────────────────────────────────────────

  void updateAsset(ZakatAssetsModel updated) {
    assets.value = updated;
  }

  void updateLiabilities(ZakatLiabilitiesModel updated) {
    liabilities.value = updated;
  }

  // ── Calculation ───────────────────────────────────────────────────────────

  Future<ZakatCalculationModel?> calculate() async {
    final prices = metalPrices.value;
    if (prices == null) return null;

    final result = ZakatCalculator.calculate(
      assets: assets.value,
      liabilities: liabilities.value,
      metalPrices: prices,
      nisabMethod: settings.value.defaultNisabMethod,
      currency: settings.value.currency,
    );

    lastResult.value = result;
    isSaving.value = true;
    try {
      await _storage.saveCalculation(result);
      history.value = await _storage.loadHistory();
    } finally {
      isSaving.value = false;
    }
    return result;
  }

  // ── History ───────────────────────────────────────────────────────────────

  Future<void> deleteHistory(String id) async {
    await _storage.deleteCalculation(id);
    history.value = await _storage.loadHistory();
    if (lastResult.value?.id == id) {
      lastResult.value = history.isNotEmpty ? history.first : null;
    }
  }

  Future<void> updatePayment({
    required String id,
    required PaymentStatus status,
    required double amountPaid,
  }) async {
    final idx = history.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final updated = history[idx].copyWith(
      paymentStatus: status,
      amountPaid: amountPaid,
    );
    await _storage.updateCalculation(updated);
    history.value = await _storage.loadHistory();
    if (lastResult.value?.id == id) lastResult.value = updated;
  }

  Future<void> addNote({required String id, required String note}) async {
    final idx = history.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final updated = history[idx].copyWith(notes: note);
    await _storage.updateCalculation(updated);
    history.value = await _storage.loadHistory();
  }

  // ── Settings ──────────────────────────────────────────────────────────────

  Future<void> updateSettings(ZakatSettings updated) async {
    settings.value = updated;
    await _storage.saveSettings(updated);
    if (updated.currency != settings.value.currency) {
      await fetchMetalPrices(forceRefresh: true);
    }
  }

  // ── Computed helpers ──────────────────────────────────────────────────────

  /// Live preview of net wealth without persisting
  double get previewNetWealth {
    final prices = metalPrices.value;
    if (prices == null) return 0;
    final goldValue = assets.value.goldMarketValueOverride > 0
        ? assets.value.goldMarketValueOverride
        : assets.value.goldWeightGrams *
              (assets.value.goldPurity / 100) *
              prices.goldPerGram;
    final silverValue = assets.value.silverMarketValueOverride > 0
        ? assets.value.silverMarketValueOverride
        : assets.value.silverWeightGrams * prices.silverPerGram;
    final total =
        assets.value.totalCash +
        goldValue +
        silverValue +
        assets.value.totalInvestments +
        assets.value.totalBusiness +
        assets.value.totalIncome;
    return (total - liabilities.value.total).clamp(0, double.infinity);
  }

  double get previewZakat =>
      ZakatCalculator.calculateZakatFromWealth(previewNetWealth);

  NisabMethod get selectedNisab => settings.value.defaultNisabMethod;

  double get currentNisabValue {
    final p = metalPrices.value;
    if (p == null) return 0;
    return selectedNisab == NisabMethod.gold
        ? p.goldNisabValue
        : p.silverNisabValue;
  }

  bool get isAboveNisab => previewNetWealth >= currentNisabValue;

  // ── Formatting ────────────────────────────────────────────────────────────

  String formatCurrency(double value, {int decimals = 2}) {
    final symbol = _currencySymbol(settings.value.currency);
    if (value >= 1000000) {
      return '$symbol${(value / 1000000).toStringAsFixed(2)}M';
    }
    if (value >= 1000) {
      return '$symbol${NumberFormat('#,##0.${'0' * decimals}').format(value)}';
    }
    return '$symbol${value.toStringAsFixed(decimals)}';
  }

  String _currencySymbol(String code) {
    const map = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'SAR': 'SAR ',
      'AED': 'AED ',
      'MYR': 'RM ',
      'IDR': 'Rp ',
      'PKR': '₨ ',
      'BDT': '৳',
      'EGP': 'E£ ',
      'TRY': '₺',
    };
    return map[code] ?? '$code ';
  }

  /// Used for displaying on dashboard
  Color zakatStatusColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return isAboveNisab ? const Color(0xff2E7D32) : cs.primary;
  }
}
