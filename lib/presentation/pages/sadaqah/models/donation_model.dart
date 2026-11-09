// ─────────────────────────────────────────────────────────────────────────────
// donation_model.dart
// ─────────────────────────────────────────────────────────────────────────────

class DonationModel {
  final String id;
  final String campaignId;
  final String campaignTitle;
  final String campaignEmoji;
  final double amount;
  final DateTime date;
  final String paymentMethod;
  final bool isMonthly;

  const DonationModel({
    required this.id,
    required this.campaignId,
    required this.campaignTitle,
    required this.campaignEmoji,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    this.isMonthly = false,
  });

  String get formattedDate {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get formattedAmount => '\$${amount.toStringAsFixed(0)}';
}

// ── Payment methods ───────────────────────────────────────────────────────────
enum PaymentMethod {
  card        ('Card',          '💳'),
  bankTransfer('Bank Transfer', '🏦'),
  wallet      ('Wallet',        '👛'),
  googlePay   ('Google Pay',    '🅶'),
  applePay    ('Apple Pay',     '🍎');

  const PaymentMethod(this.label, this.icon);
  final String label;
  final String icon;
}
