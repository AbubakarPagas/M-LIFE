import 'package:misbah_path/helpers/preferences.dart';
import 'package:misbah_path/preference/preference.dart';

import 'dependency_provider.dart';

class DuaDependencyProvider extends DependencyProvider {
  String get translationLang => sharedPrefDuaTranslationLang.value;

  bool get showTranslation => sharedPrefDuaShowTranslation.value;

  bool get showTransliteration => sharedPrefDuaShowTransliteration.value;

  double get arabicFontSize => sharedPrefDuaArabicFontSize.value;

  double get otherFontSize => sharedPrefDuaOtherFontSize.value;

  bool get sameAsPrimaryLang => sharedPrefDuaSameAsPrimary.value;

  void changeFontSize({required bool isArabic, required double newSize}) =>
      updateDataWithPreference(
        (isArabic ? sharedPrefDuaArabicFontSize : sharedPrefDuaOtherFontSize) as Preference<double>,
        newSize,
      );

  void changeFontToDefault({required bool isArabic}) {
    final newSize = isArabic
        ? sharedPrefDuaArabicFontSize.defaultValue
        : sharedPrefDuaOtherFontSize.defaultValue;
    changeFontSize(isArabic: isArabic, newSize: newSize);
  }

  void changeShowTransliteration({required bool newValue}) =>
      updateDataWithPreference(sharedPrefDuaShowTransliteration as Preference<bool>, newValue);

  void changeShowTranslation({required bool newValue}) =>
      updateDataWithPreference(sharedPrefDuaShowTranslation as Preference<bool>, newValue);

  void setDuaLangToPrimary() {
    final primaryLang = sharedPrefAdhanCurrentLocalization.value;
    changeTranslationLang(primaryLang, usePrimary: true);
  }

  void changeTranslationLang(String newValue, {bool usePrimary = false}) {
    updateDataByRunning(
      () async {
        await sharedPrefDuaSameAsPrimary.updateValue(usePrimary);
        await sharedPrefDuaTranslationLang.updateValue(newValue);
      },
    );
  }

}
