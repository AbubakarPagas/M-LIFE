// ─────────────────────────────────────────────────────────────────────────────
// sadaqah_repository.dart
// Abstract contract + mock implementation.
// Swap MockSadaqahRepository for a real HTTP implementation in production.
// ─────────────────────────────────────────────────────────────────────────────

import '../data/mock_data.dart';
import '../models/campaign_model.dart';
import '../models/donation_model.dart';

abstract class SadaqahRepository {
  Future<List<CampaignModel>> fetchCampaigns();
  Future<List<DonationModel>> fetchDonationHistory();
  Future<bool> submitDonation({
    required String campaignId,
    required double amount,
    required String paymentMethod,
    required bool   isMonthly,
  });
}

class MockSadaqahRepository implements SadaqahRepository {
  static const _delay = Duration(milliseconds: 900);

  @override
  Future<List<CampaignModel>> fetchCampaigns() async {
    await Future.delayed(_delay);
    return List.from(SadaqahMockData.campaigns);
  }

  @override
  Future<List<DonationModel>> fetchDonationHistory() async {
    await Future.delayed(_delay);
    return List.from(SadaqahMockData.donationHistory);
  }

  @override
  Future<bool> submitDonation({
    required String campaignId,
    required double amount,
    required String paymentMethod,
    required bool   isMonthly,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return true; // always succeeds in mock
  }
}
