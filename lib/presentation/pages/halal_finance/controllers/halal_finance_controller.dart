// ─────────────────────────────────────────────────────────────────────────────
// HalalFinanceController — manages all state for the Halal Finance Tips page
// ─────────────────────────────────────────────────────────────────────────────

import 'package:get/get.dart';

import '../data/datasources/finance_local_datasource.dart';
import '../data/models/finance_tip_model.dart';
import '../data/models/halal_haram_model.dart';
import '../data/repositories/finance_repository.dart';

enum FinanceLoadState { loading, loaded, error }

class HalalFinanceController extends GetxController {
  static HalalFinanceController get instance =>
      Get.find<HalalFinanceController>();

  final FinanceRepository _repo;

  HalalFinanceController({FinanceRepository? repo})
    : _repo = repo ?? FinanceRepository();

  // ── State ─────────────────────────────────────────────────────────────────
  final Rx<FinanceLoadState> loadState = FinanceLoadState.loading.obs;
  final RxString searchQuery = ''.obs;
  final Rx<FinanceCategory> selectedCategory = FinanceCategory.all.obs;

  final RxList<FinanceTipModel> _allTips = <FinanceTipModel>[].obs;
  final RxList<FinanceTipModel> visibleTips = <FinanceTipModel>[].obs;
  final RxList<Map<String, String>> scriptureCards =
      <Map<String, String>>[].obs;
  final RxList<HalalHaramEntry> halalEntries = <HalalHaramEntry>[].obs;
  final RxList<HalalHaramEntry> haramEntries = <HalalHaramEntry>[].obs;
  final Rx<Map<String, String>?> dailyTip = Rx<Map<String, String>?>(null);

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _load();
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedCategory, (_) => _applyFilters());
  }

  Future<void> _load() async {
    loadState.value = FinanceLoadState.loading;
    try {
      final tips = await _repo.getTips();
      _allTips.value = tips;
      visibleTips.value = tips;
      scriptureCards.value = _repo.getScriptureCards();
      halalEntries.value = _repo.getHalalEntries();
      haramEntries.value = _repo.getHaramEntries();
      dailyTip.value = _repo.getDailyTip();
      loadState.value = FinanceLoadState.loaded;
    } catch (_) {
      loadState.value = FinanceLoadState.error;
    }
  }

  @override
  Future<void> refresh() async => _load();

  void _applyFilters() {
    var filtered = List<FinanceTipModel>.from(_allTips);

    // Category filter
    if (selectedCategory.value != FinanceCategory.all) {
      filtered = filtered
          .where((t) => t.category == selectedCategory.value)
          .toList();
    }

    // Search filter
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      filtered = filtered.where((t) {
        return t.title.toLowerCase().contains(q) ||
            t.description.toLowerCase().contains(q) ||
            t.category.label.toLowerCase().contains(q);
      }).toList();
    }

    visibleTips.value = filtered;
  }

  void setCategory(FinanceCategory cat) => selectedCategory.value = cat;

  void setSearch(String q) => searchQuery.value = q;

  Future<void> toggleBookmark(String tipId) async {
    await _repo.toggleBookmark(tipId);
    final idx = _allTips.indexWhere((t) => t.id == tipId);
    if (idx >= 0) {
      _allTips[idx] = _allTips[idx].copyWith(
        isBookmarked: !_allTips[idx].isBookmarked,
      );
      _applyFilters();
    }
  }

  List<FinanceTipModel> get bookmarkedTips =>
      _allTips.where((t) => t.isBookmarked).toList();

  int get totalTips => FinanceLocalDatasource.tips.length;
}
