import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/languages/app_constants.dart';
import '../../../../core/services/languages/language_models.dart';
import '../../../../presentation/controllers/theme_controller.dart';
import '../../tasbih/controller/tasbih_controller.dart';

// ── SharedPreferences keys ─────────────────────────────────────────────────────
const _kUserNameKey = 'profile_user_name';
const _kUserEmailKey = 'profile_user_email';
const _kIsPremiumKey = 'profile_is_premium';
const _kPrayerStreakKey = 'profile_prayer_streak';
const _kQuranSessionsKey = 'profile_quran_sessions';
const _kSurahsCompletedKey = 'profile_surahs_completed';
const _kDhikrProgressKey = 'profile_dhikr_progress';
const _kNotificationsKey = 'profile_notifications_on';
const _kCalcMethodKey = 'profile_calc_method';
const _kMadhabKey = 'profile_madhab';
const _kTranslationKey = 'profile_translation';
const _kAzanVoiceKey = 'profile_azan_voice';

class ProfileController extends GetxController {
  static ProfileController get instance =>
      GetInstance().putOrFind(() => ProfileController());

  // ── User identity ────────────────────────────────────────────────────────
  final RxString userName = 'Muslim'.obs;
  final RxString userEmail = 'user@example.com'.obs;
  final RxBool isPremium = false.obs;

  // ── Worship stats ────────────────────────────────────────────────────────
  final RxInt prayerStreak = 0.obs;
  final RxInt quranSessions = 0.obs;
  final RxInt surahsCompleted = 0.obs;
  final RxDouble dhikrProgress = 0.0.obs; // 0.0 → 1.0

  // ── App settings ─────────────────────────────────────────────────────────
  final RxBool notificationsOn = true.obs;

  // ── Islamic preferences ───────────────────────────────────────────────────
  final RxString calcMethod = 'Muslim World League'.obs;
  final RxString madhab = "Shafi'i".obs;
  final RxString translation = 'Sahih International'.obs;
  final RxString azanVoice = 'Makkah Azan'.obs;

  // ── Convenience getters ───────────────────────────────────────────────────
  ThemeController get themeCtrl => Get.find<ThemeController>();
  // SettingsController get settingsCtrl => Get.find<SettingsController>();

  int get tasbihAllTime {
    try {
      return Get.find<TasbihController>().totalAllTimeDhikr;
    } catch (_) {
      return 0;
    }
  }

  String get currentLanguageName =>
      'English'; // settingsCtrl.languageName.value.isEmpty
  //?
  //  'English';
  // : settingsCtrl.languageName.value;

  List<LanguageModel> get availableLanguages => AppConstants.languages;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _load();
  }

  // ── Public actions ────────────────────────────────────────────────────────

  void updateProfile({required String name, required String email}) {
    userName.value = name.trim().isEmpty ? 'Muslim' : name.trim();
    userEmail.value = email.trim();
    _persist();
  }

  void togglePremium() {
    isPremium.toggle();
    _persist();
  }

  void toggleNotifications() {
    notificationsOn.toggle();
    _persist();
  }

  void setCalcMethod(String method) {
    calcMethod.value = method;
    _persist();
  }

  void setMadhab(String value) {
    madhab.value = value;
    _persist();
  }

  void setTranslation(String value) {
    translation.value = value;
    _persist();
  }

  void setAzanVoice(String value) {
    azanVoice.value = value;
    _persist();
  }

  void changeLanguage(LanguageModel lang) {
    // settingsCtrl.changeLanguage(locale, lang.languageName);
  }

  void changeTheme(AppTheme theme) {
    themeCtrl.setTheme(theme);
  }

  Future<void> logout() async {
    userName.value = 'Muslim';
    userEmail.value = 'user@example.com';
    isPremium.value = false;
    await _persist();
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString(_kUserNameKey) ?? 'Muslim';
    userEmail.value = prefs.getString(_kUserEmailKey) ?? 'user@example.com';
    isPremium.value = prefs.getBool(_kIsPremiumKey) ?? false;
    prayerStreak.value = prefs.getInt(_kPrayerStreakKey) ?? 7;
    quranSessions.value = prefs.getInt(_kQuranSessionsKey) ?? 14;
    surahsCompleted.value = prefs.getInt(_kSurahsCompletedKey) ?? 5;
    dhikrProgress.value = prefs.getDouble(_kDhikrProgressKey) ?? 0.68;
    notificationsOn.value = prefs.getBool(_kNotificationsKey) ?? true;
    calcMethod.value =
        prefs.getString(_kCalcMethodKey) ?? 'Muslim World League';
    madhab.value = prefs.getString(_kMadhabKey) ?? "Shafi'i";
    translation.value =
        prefs.getString(_kTranslationKey) ?? 'Sahih International';
    azanVoice.value = prefs.getString(_kAzanVoiceKey) ?? 'Makkah Azan';
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_kUserNameKey, userName.value),
      prefs.setString(_kUserEmailKey, userEmail.value),
      prefs.setBool(_kIsPremiumKey, isPremium.value),
      prefs.setBool(_kNotificationsKey, notificationsOn.value),
      prefs.setString(_kCalcMethodKey, calcMethod.value),
      prefs.setString(_kMadhabKey, madhab.value),
      prefs.setString(_kTranslationKey, translation.value),
      prefs.setString(_kAzanVoiceKey, azanVoice.value),
    ]);
  }
}
