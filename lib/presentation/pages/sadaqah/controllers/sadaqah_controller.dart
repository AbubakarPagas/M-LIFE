// ─────────────────────────────────────────────────────────────────────────────
// sadaqah_controller.dart — single source of truth for Sadaqah Jariyah feature
// ─────────────────────────────────────────────────────────────────────────────

import 'package:get/get.dart';

import '../models/campaign_model.dart';
import '../models/donation_model.dart';
import '../repositories/sadaqah_repository.dart';

enum SadaqahLoadState { loading, loaded, error }

class SadaqahController extends GetxController {
  // ── Singleton accessor (registered via GetIt/Get.put in services_locator) ─
  static SadaqahController get instance => Get.find<SadaqahController>();

  // ── DI ────────────────────────────────────────────────────────────────────
  final SadaqahRepository _repo;
  SadaqahController({SadaqahRepository? repo})
    : _repo = repo ?? MockSadaqahRepository();

  // ── State ─────────────────────────────────────────────────────────────────
  final Rx<SadaqahLoadState> loadState = SadaqahLoadState.loading.obs;
  final RxString errorMessage = ''.obs;

  final RxList<CampaignModel> _allCampaigns = <CampaignModel>[].obs;
  final RxList<CampaignModel> campaigns = <CampaignModel>[].obs;
  final RxList<DonationModel> donationHistory = <DonationModel>[].obs;

  final RxBool isLoadingHistory = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool donationSuccess = false.obs;

  final RxString selectedCategory = CampaignCategory.all.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isMonthly = false.obs;

  // ── Derived ────────────────────────────────────────────────────────────────
  double get totalDonated => donationHistory.fold(0.0, (s, d) => s + d.amount);

  List<CampaignModel> get favoriteCampaigns =>
      _allCampaigns.where((c) => c.isFavorite).toList();

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchCampaigns();
    _loadHistory();
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedCategory, (_) => _applyFilters());
  }

  // ── Data loading ──────────────────────────────────────────────────────────
  Future<void> fetchCampaigns() async {
    loadState.value = SadaqahLoadState.loading;
    try {
      final data = await _repo.fetchCampaigns();
      _allCampaigns.assignAll(data);
      _applyFilters();
      loadState.value = SadaqahLoadState.loaded;
    } catch (e) {
      errorMessage.value = 'Failed to load campaigns. Please try again.';
      loadState.value = SadaqahLoadState.error;
    }
  }

  Future<void> _loadHistory() async {
    isLoadingHistory.value = true;
    try {
      final data = await _repo.fetchDonationHistory();
      donationHistory.assignAll(data);
    } finally {
      isLoadingHistory.value = false;
    }
  }

  /// Pull-to-refresh
  @override
  Future<void> refresh() => Future.wait([fetchCampaigns(), _loadHistory()]);

  // ── Filtering ─────────────────────────────────────────────────────────────
  void _applyFilters() {
    var list = _allCampaigns.toList();

    if (selectedCategory.value != CampaignCategory.all) {
      list = list.where((c) => c.category == selectedCategory.value).toList();
    }

    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (c) =>
                c.title.toLowerCase().contains(q) ||
                c.description.toLowerCase().contains(q),
          )
          .toList();
    }

    campaigns.assignAll(list);
  }

  void setCategory(String? cat) {
    selectedCategory.value = cat ?? CampaignCategory.all;
  }

  void setSearchQuery(String q) => searchQuery.value = q;

  // ── Donation type ─────────────────────────────────────────────────────────
  void toggleMonthly() => isMonthly.value = !isMonthly.value;

  void setDonationType(bool monthly) => isMonthly.value = monthly;

  // ── Favourites ────────────────────────────────────────────────────────────
  void toggleFavorite(String id) {
    final idx = _allCampaigns.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    _allCampaigns[idx] = _allCampaigns[idx].copyWith(
      isFavorite: !_allCampaigns[idx].isFavorite,
    );
    _applyFilters();
  }

  // ── Donation submission ───────────────────────────────────────────────────
  Future<bool> donate({
    required String campaignId,
    required double amount,
    required String paymentMethod,
  }) async {
    isSubmitting.value = true;
    donationSuccess.value = false;
    try {
      final ok = await _repo.submitDonation(
        campaignId: campaignId,
        amount: amount,
        paymentMethod: paymentMethod,
        isMonthly: isMonthly.value,
      );
      if (ok) {
        donationSuccess.value = true;
        final idx = _allCampaigns.indexWhere((c) => c.id == campaignId);
        if (idx != -1) {
          _allCampaigns[idx] = _allCampaigns[idx].copyWith(
            amountRaised: _allCampaigns[idx].amountRaised + amount,
          );
          _applyFilters();
        }
      }
      return ok;
    } finally {
      isSubmitting.value = false;
    }
  }

  void resetSuccess() => donationSuccess.value = false;
}
