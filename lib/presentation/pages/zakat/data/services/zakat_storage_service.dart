// ─────────────────────────────────────────────────────────────────────────────
// ZakatStorageService — persists calculation history & settings via sqflite
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/zakat_calculation_model.dart';

class ZakatStorageService {
  static const _historyKey = 'zakat_calculation_history';
  static const _settingsKey = 'zakat_settings';

  // ── History ───────────────────────────────────────────────────────────────

  Future<List<ZakatCalculationModel>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ZakatCalculationModel.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCalculation(ZakatCalculationModel model) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadHistory();
    // Remove duplicate by id then prepend
    history.removeWhere((e) => e.id == model.id);
    history.insert(0, model);
    // Keep max 100 records
    final trimmed = history.take(100).toList();
    await prefs.setString(
      _historyKey,
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> updateCalculation(ZakatCalculationModel model) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadHistory();
    final idx = history.indexWhere((e) => e.id == model.id);
    if (idx >= 0) {
      history[idx] = model;
    } else {
      history.insert(0, model);
    }
    await prefs.setString(
      _historyKey,
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> deleteCalculation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadHistory();
    history.removeWhere((e) => e.id == id);
    await prefs.setString(
      _historyKey,
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // ── Settings ──────────────────────────────────────────────────────────────

  Future<ZakatSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_settingsKey);
      if (raw == null) return ZakatSettings.defaults();
      return ZakatSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return ZakatSettings.defaults();
    }
  }

  Future<void> saveSettings(ZakatSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ZakatSettings
// ─────────────────────────────────────────────────────────────────────────────

class ZakatSettings {
  final String currency;
  final NisabMethod defaultNisabMethod;
  final bool annualReminderEnabled;
  final bool ramadanReminderEnabled;
  final bool customReminderEnabled;
  final String? customReminderDate; // ISO date string

  const ZakatSettings({
    required this.currency,
    required this.defaultNisabMethod,
    required this.annualReminderEnabled,
    required this.ramadanReminderEnabled,
    required this.customReminderEnabled,
    this.customReminderDate,
  });

  factory ZakatSettings.defaults() => const ZakatSettings(
    currency: 'USD',
    defaultNisabMethod: NisabMethod.gold,
    annualReminderEnabled: true,
    ramadanReminderEnabled: true,
    customReminderEnabled: false,
  );

  ZakatSettings copyWith({
    String? currency,
    NisabMethod? defaultNisabMethod,
    bool? annualReminderEnabled,
    bool? ramadanReminderEnabled,
    bool? customReminderEnabled,
    String? customReminderDate,
  }) {
    return ZakatSettings(
      currency: currency ?? this.currency,
      defaultNisabMethod: defaultNisabMethod ?? this.defaultNisabMethod,
      annualReminderEnabled:
          annualReminderEnabled ?? this.annualReminderEnabled,
      ramadanReminderEnabled:
          ramadanReminderEnabled ?? this.ramadanReminderEnabled,
      customReminderEnabled:
          customReminderEnabled ?? this.customReminderEnabled,
      customReminderDate: customReminderDate ?? this.customReminderDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'currency': currency,
    'defaultNisabMethod': defaultNisabMethod.name,
    'annualReminderEnabled': annualReminderEnabled,
    'ramadanReminderEnabled': ramadanReminderEnabled,
    'customReminderEnabled': customReminderEnabled,
    'customReminderDate': customReminderDate,
  };

  factory ZakatSettings.fromJson(Map<String, dynamic> json) => ZakatSettings(
    currency: json['currency'] as String? ?? 'USD',
    defaultNisabMethod: NisabMethod.values.firstWhere(
      (e) => e.name == json['defaultNisabMethod'],
      orElse: () => NisabMethod.gold,
    ),
    annualReminderEnabled: json['annualReminderEnabled'] as bool? ?? true,
    ramadanReminderEnabled: json['ramadanReminderEnabled'] as bool? ?? true,
    customReminderEnabled: json['customReminderEnabled'] as bool? ?? false,
    customReminderDate: json['customReminderDate'] as String?,
  );
}
