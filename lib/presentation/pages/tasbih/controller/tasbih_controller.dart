import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/dhikr_preset.dart';
import '../model/tasbih_session_model.dart';

const _kCurrentCountKey = 'tasbih_current_count';
const _kSelectedDhikrKey = 'tasbih_selected_dhikr_idx';
const _kVibrationKey = 'tasbih_vibration_enabled';
const _kHistoryKey = 'tasbih_history_v2';

class TasbihController extends GetxController with GetTickerProviderStateMixin {
  // ─── Observable state ────────────────────────────────────────────────────

  final RxInt count = 0.obs;
  final RxInt selectedDhikrIndex = 0.obs;
  final RxBool vibrationEnabled = true.obs;
  final RxBool isCompleted = false.obs;
  final RxList<TasbihSession> history = <TasbihSession>[].obs;

  // ─── Tap animation ────────────────────────────────────────────────────────

  late final animController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    lowerBound: 0.92,
    upperBound: 1.0,
    value: 1.0,
  );

  // ─── Bead animation (floating beads around the ring) ─────────────────────

  late final beadController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  // ─── Getters ──────────────────────────────────────────────────────────────

  DhikrPreset get currentDhikr =>
      DhikrPreset.defaults[selectedDhikrIndex.value];

  int get target => currentDhikr.target;

  double get progress =>
      target > 0 ? (count.value / target).clamp(0.0, 1.0) : 0.0;

  int get remainingCount => (target - count.value).clamp(0, target);

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadPersistedState();
  }

  @override
  void onClose() {
    animController.dispose();
    beadController.dispose();
    super.onClose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> increment() async {
    if (isCompleted.value) return;

    count.value++;
    _persistCount();
    _playTapAnimation();

    if (vibrationEnabled.value) {
      HapticFeedback.mediumImpact();
    }

    if (count.value >= target) {
      isCompleted.value = true;
      _onComplete();
    }
  }

  void selectDhikr(int index) {
    if (selectedDhikrIndex.value == index) return;
    selectedDhikrIndex.value = index;
    _reset(save: false);
    _persistSelectedDhikr();
  }

  Future<void> reset({bool save = false}) async {
    if (save && count.value > 0) {
      await saveSession();
    }
    _reset(save: false);
  }

  Future<void> saveSession() async {
    if (count.value == 0) return;
    final session = TasbihSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dhikrName: currentDhikr.name,
      dhikrArabic: currentDhikr.arabic,
      targetCount: target,
      totalCount: count.value,
      date: DateTime.now(),
    );
    history.insert(0, session);
    await _persistHistory();
  }

  void toggleVibration() {
    vibrationEnabled.toggle();
    _persistVibration();
  }

  Future<void> deleteSession(String id) async {
    history.removeWhere((s) => s.id == id);
    await _persistHistory();
  }

  // ─── Daily stats helpers ─────────────────────────────────────────────────

  int get todayTotalCount {
    final today = DateTime.now();
    return history
        .where(
          (s) =>
              s.date.year == today.year &&
              s.date.month == today.month &&
              s.date.day == today.day,
        )
        .fold(0, (sum, s) => sum + s.totalCount);
  }

  int get todaySessionCount {
    final today = DateTime.now();
    return history
        .where(
          (s) =>
              s.date.year == today.year &&
              s.date.month == today.month &&
              s.date.day == today.day,
        )
        .length;
  }

  int get totalAllTimeDhikr => history.fold(0, (sum, s) => sum + s.totalCount);

  // ─── Private helpers ──────────────────────────────────────────────────────

  void _reset({bool save = true}) {
    count.value = 0;
    isCompleted.value = false;
    _persistCount();
  }

  void _onComplete() {
    if (vibrationEnabled.value) {
      HapticFeedback.heavyImpact();
      Future.delayed(
        const Duration(milliseconds: 200),
        () => HapticFeedback.heavyImpact(),
      );
    }
    beadController.forward(from: 0.0);
  }

  void _playTapAnimation() {
    animController.reverse().then((_) => animController.forward());
  }

  // ─── Persistence ──────────────────────────────────────────────────────────

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();

    final savedCount = prefs.getInt(_kCurrentCountKey) ?? 0;
    final savedDhikr = prefs.getInt(_kSelectedDhikrKey) ?? 0;
    final savedVibration = prefs.getBool(_kVibrationKey) ?? true;

    count.value = savedCount;
    selectedDhikrIndex.value = savedDhikr.clamp(
      0,
      DhikrPreset.defaults.length - 1,
    );
    vibrationEnabled.value = savedVibration;
    if (count.value >= target) isCompleted.value = true;

    await _loadHistory(prefs);
  }

  Future<void> _loadHistory(SharedPreferences prefs) async {
    final raw = prefs.getStringList(_kHistoryKey) ?? [];
    history.value = raw
        .map((s) {
          try {
            return TasbihSession.fromJson(s);
          } catch (_) {
            return null;
          }
        })
        .whereType<TasbihSession>()
        .toList();
  }

  Future<void> _persistCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCurrentCountKey, count.value);
  }

  Future<void> _persistSelectedDhikr() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSelectedDhikrKey, selectedDhikrIndex.value);
  }

  Future<void> _persistVibration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kVibrationKey, vibrationEnabled.value);
  }

  Future<void> _persistHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = history.map((s) => s.toJson()).toList();
    await prefs.setStringList(_kHistoryKey, encoded);
  }
}
