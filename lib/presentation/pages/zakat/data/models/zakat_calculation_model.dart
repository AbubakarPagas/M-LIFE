// ─────────────────────────────────────────────────────────────────────────────
// ZakatCalculationModel — result of a single Zakat calculation
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

import 'zakat_assets_model.dart';
import 'zakat_liabilities_model.dart';

enum NisabMethod { gold, silver }

enum PaymentStatus { pending, partiallyPaid, paid }

class ZakatCalculationModel {
  final String id;
  final DateTime calculatedAt;
  final ZakatAssetsModel assets;
  final ZakatLiabilitiesModel liabilities;
  final double goldPricePerGram;
  final double silverPricePerGram;
  final NisabMethod nisabMethod;
  final double totalAssets;
  final double totalLiabilities;
  final double netWealth;
  final double nisabValue;
  final bool isZakatObligatory;
  final double zakatDue;
  final String currency;
  final String? notes;
  final PaymentStatus paymentStatus;
  final double amountPaid;

  const ZakatCalculationModel({
    required this.id,
    required this.calculatedAt,
    required this.assets,
    required this.liabilities,
    required this.goldPricePerGram,
    required this.silverPricePerGram,
    required this.nisabMethod,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWealth,
    required this.nisabValue,
    required this.isZakatObligatory,
    required this.zakatDue,
    required this.currency,
    this.notes,
    this.paymentStatus = PaymentStatus.pending,
    this.amountPaid = 0,
  });

  double get remainingDue => (zakatDue - amountPaid).clamp(0, double.infinity);
  double get paymentProgress =>
      zakatDue > 0 ? (amountPaid / zakatDue).clamp(0.0, 1.0) : 0.0;

  ZakatCalculationModel copyWith({
    String? notes,
    PaymentStatus? paymentStatus,
    double? amountPaid,
  }) {
    return ZakatCalculationModel(
      id: id,
      calculatedAt: calculatedAt,
      assets: assets,
      liabilities: liabilities,
      goldPricePerGram: goldPricePerGram,
      silverPricePerGram: silverPricePerGram,
      nisabMethod: nisabMethod,
      totalAssets: totalAssets,
      totalLiabilities: totalLiabilities,
      netWealth: netWealth,
      nisabValue: nisabValue,
      isZakatObligatory: isZakatObligatory,
      zakatDue: zakatDue,
      currency: currency,
      notes: notes ?? this.notes,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amountPaid: amountPaid ?? this.amountPaid,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'calculatedAt': calculatedAt.toIso8601String(),
    'assets': assets.toJson(),
    'liabilities': liabilities.toJson(),
    'goldPricePerGram': goldPricePerGram,
    'silverPricePerGram': silverPricePerGram,
    'nisabMethod': nisabMethod.name,
    'totalAssets': totalAssets,
    'totalLiabilities': totalLiabilities,
    'netWealth': netWealth,
    'nisabValue': nisabValue,
    'isZakatObligatory': isZakatObligatory,
    'zakatDue': zakatDue,
    'currency': currency,
    'notes': notes,
    'paymentStatus': paymentStatus.name,
    'amountPaid': amountPaid,
  };

  factory ZakatCalculationModel.fromJson(
    Map<String, dynamic> json,
  ) => ZakatCalculationModel(
    id: json['id'] as String,
    calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    assets: ZakatAssetsModel.fromJson(json['assets'] as Map<String, dynamic>),
    liabilities: ZakatLiabilitiesModel.fromJson(
      json['liabilities'] as Map<String, dynamic>,
    ),
    goldPricePerGram: (json['goldPricePerGram'] as num?)?.toDouble() ?? 0,
    silverPricePerGram: (json['silverPricePerGram'] as num?)?.toDouble() ?? 0,
    nisabMethod: NisabMethod.values.firstWhere(
      (e) => e.name == json['nisabMethod'],
      orElse: () => NisabMethod.gold,
    ),
    totalAssets: (json['totalAssets'] as num?)?.toDouble() ?? 0,
    totalLiabilities: (json['totalLiabilities'] as num?)?.toDouble() ?? 0,
    netWealth: (json['netWealth'] as num?)?.toDouble() ?? 0,
    nisabValue: (json['nisabValue'] as num?)?.toDouble() ?? 0,
    isZakatObligatory: json['isZakatObligatory'] as bool? ?? false,
    zakatDue: (json['zakatDue'] as num?)?.toDouble() ?? 0,
    currency: json['currency'] as String? ?? 'USD',
    notes: json['notes'] as String?,
    paymentStatus: PaymentStatus.values.firstWhere(
      (e) => e.name == json['paymentStatus'],
      orElse: () => PaymentStatus.pending,
    ),
    amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0,
  );

  String toJsonString() => jsonEncode(toJson());
  factory ZakatCalculationModel.fromJsonString(String s) =>
      ZakatCalculationModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
