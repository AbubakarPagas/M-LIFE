// ─────────────────────────────────────────────────────────────────────────────
// mock_data.dart — replace repo calls with real API in production
// ─────────────────────────────────────────────────────────────────────────────

import '../models/campaign_model.dart';
import '../models/donation_model.dart';

abstract class SadaqahMockData {
  // ── Header quote ──────────────────────────────────────────────────────────
  static const String headerArabic =
      '﴿ مَّثَلُ الَّذِينَ يُنفِقُونَ أَمْوَالَهُمْ فِي سَبِيلِ اللَّهِ كَمَثَلِ حَبَّةٍ أَنبَتَتْ سَبْعَ سَنَابِلَ ﴾';
  static const String headerTranslation =
      '"The example of those who spend their wealth in the way of Allah is like a grain that sprouts seven spikes." — Al-Baqarah 2:261';

  // ── Campaigns ─────────────────────────────────────────────────────────────
  static List<CampaignModel> get campaigns => [
    const CampaignModel(
      id: 'c1',
      category: CampaignCategory.waterWell,
      emoji: '💧',
      isFeatured: true,
      title: 'Clean Water Wells — Africa',
      description:
          'Dig life-saving wells for remote villages in Sub-Saharan Africa. '
          'One well serves 500+ families with clean drinking water for decades.',
      amountRaised: 18500,
      goalAmount: 25000,
      donorCount: 342,
    ),
    const CampaignModel(
      id: 'c2',
      category: CampaignCategory.quranSponsorship,
      emoji: '📖',
      isFeatured: true,
      title: 'Distribute 10,000 Holy Qurans',
      description:
          'Print and distribute the Holy Quran to new Muslims, prisoners, '
          'and remote communities across the globe.',
      amountRaised: 7200,
      goalAmount: 15000,
      donorCount: 185,
    ),
    const CampaignModel(
      id: 'c3',
      category: CampaignCategory.orphanSupport,
      emoji: '🤲',
      title: 'Orphan Care — Syria',
      description:
          'Sponsor an orphan child in Syria with food, shelter, clothing '
          'and education for a full year.',
      amountRaised: 43000,
      goalAmount: 60000,
      donorCount: 612,
    ),
    const CampaignModel(
      id: 'c4',
      category: CampaignCategory.mosqueConstruction,
      emoji: '🕌',
      title: 'Build a Masjid — Bangladesh',
      description:
          'A rural community in Bangladesh needs a mosque so families '
          'can gather for Jumu\'ah and daily prayers.',
      amountRaised: 31000,
      goalAmount: 50000,
      donorCount: 421,
    ),
    const CampaignModel(
      id: 'c5',
      category: CampaignCategory.islamicEducation,
      emoji: '🎓',
      title: 'Islamic School Scholarships',
      description:
          'Fund scholarships for low-income children to attend quality '
          'Islamic schools in Southeast Asia.',
      amountRaised: 9800,
      goalAmount: 20000,
      donorCount: 218,
    ),
    const CampaignModel(
      id: 'c6',
      category: CampaignCategory.emergencyRelief,
      emoji: '🆘',
      isFeatured: true,
      title: 'Gaza Emergency Relief',
      description:
          'Urgent humanitarian aid — food parcels, medicine and '
          'emergency shelter for families in Gaza.',
      amountRaised: 126000,
      goalAmount: 200000,
      donorCount: 4750,
    ),
    const CampaignModel(
      id: 'c7',
      category: CampaignCategory.waterWell,
      emoji: '💧',
      title: 'Yemen Solar Water Pumps',
      description:
          'Install solar-powered water pumps to bring potable water '
          'to conflict-affected villages across Yemen.',
      amountRaised: 11300,
      goalAmount: 30000,
      donorCount: 198,
    ),
    const CampaignModel(
      id: 'c8',
      category: CampaignCategory.orphanSupport,
      emoji: '🤲',
      title: 'Orphan Eid Gift Parcels',
      description:
          'Give 500 orphan children a joyful Eid with new clothes, '
          'gifts and a special meal.',
      amountRaised: 4500,
      goalAmount: 10000,
      donorCount: 310,
    ),
  ];

  // ── Donation history ───────────────────────────────────────────────────────
  static List<DonationModel> get donationHistory => [
    DonationModel(
      id: 'd1',
      campaignId: 'c6',
      campaignTitle: 'Gaza Emergency Relief',
      campaignEmoji: '🆘',
      amount: 50,
      date: DateTime(2025, 3, 14),
      paymentMethod: 'Card',
      isMonthly: true,
    ),
    DonationModel(
      id: 'd2',
      campaignId: 'c1',
      campaignTitle: 'Clean Water Wells — Africa',
      campaignEmoji: '💧',
      amount: 100,
      date: DateTime(2025, 2, 28),
      paymentMethod: 'Google Pay',
    ),
    DonationModel(
      id: 'd3',
      campaignId: 'c3',
      campaignTitle: 'Orphan Care — Syria',
      campaignEmoji: '🤲',
      amount: 30,
      date: DateTime(2025, 1, 10),
      paymentMethod: 'Wallet',
      isMonthly: true,
    ),
    DonationModel(
      id: 'd4',
      campaignId: 'c2',
      campaignTitle: 'Distribute 10,000 Holy Qurans',
      campaignEmoji: '📖',
      amount: 25,
      date: DateTime(2024, 12, 5),
      paymentMethod: 'Bank Transfer',
    ),
  ];
}
