import 'package:adhan/adhan.dart';
import 'package:misbah_path/helpers/preferences.dart';
import 'package:misbah_path/platforms/prayer_foreground_service.dart';

import '../../helpers/adhan_dependencies.dart';
import 'dependency_provider.dart';

class AdhanDependencyProvider extends DependencyProvider {
  AdhanDependencyProvider();

  int get madhabIndex => sharedPrefAdhanMadhabIndex.value;

  int get calMethodIndex => sharedPrefCalcIndex.value;

  int get highLatRuleIndex => sharedPrefAdhanHighLatRule.value;

  List<bool> get _visibility =>
      sharedPrefAdhanVisibility.map((e) => e.value).toList();

  List<int> get _manualCorrection =>
      sharedPrefAdhanManualCorrect.map((e) => e.value).toList();

  List<int> get _notifyIDs =>
      sharedPrefAdhanNotifyID.map((e) => e.value).toList();

  List<int> get _notifyBefore =>
      sharedPrefAdhanNotifyBefore.map((e) => e.value).toList();

  bool get showPersistant => sharedPrefAdhanShowPersistentNotify.value;

  Future changePersistantNotifyStatus({required bool newVal}) async {
    await sharedPrefAdhanShowPersistentNotify.updateValue(newVal);
    if (newVal) {
      await startPrayerForegroundService();
    } else {
      await stopPrayerForegroundService();
    }
    notifyListeners();
  }

  CalculationParameters get params {
    final param = adhanCalculationMethods[calMethodIndex].getParameters();
    param.madhab = madhabs[madhabIndex];
    param.highLatitudeRule = highLatRules[highLatRuleIndex];
    return param;
  }

  int getNotifyBefore(int adhanType) {
    return _notifyBefore[adhanType];
  }

  // String get paranName {
  //   return adhanCalculationMethodNames[calMethodIndex];
  // }

  // String get paranDesc {
  //   return adhanCalculationMethodDescs[calMethodIndex];
  // }

  // String get highLatRuleName {
  //   return highLatRulesNames[highLatRuleIndex];
  // }

  // String get highLatRuleDesc {
  //   return highLatRulesDescs[highLatRuleIndex];
  // }

  bool getVisibility(int adhanID) {
    return _visibility[adhanID];
  }

  int getManualCorrection(int adhanIndex) {
    return _manualCorrection[adhanIndex];
  }

  int notifyID(int adhanType) {
    return _notifyIDs[adhanType];
  }

  // void silentAll() => updateDataByRunning(() async {
  //       for (final element in sharedPrefAdhanNotifyID) {
  //         element.updateValue(0);
  //       }
  //     });

  // void changeMadhab(int newMadhabIndex) =>
  //     updateDataWithPreference(sharedPrefAdhanMadhabIndex, newMadhabIndex);

  // void changeCalMethod(int newCalcMethod) =>
  //     updateDataWithPreference(sharedPrefCalcIndex, newCalcMethod);

  // void changeHighLatRuleIndex(int newIndex) =>
  //     updateDataWithPreference(sharedPrefAdhanHighLatRule, newIndex);

  // void changeVisibility(int adhanID, {required bool visible}) =>
  //     updateDataWithPreference(sharedPrefAdhanVisibility[adhanID], visible);

  // void changeManualCorrection(int adhanID, int minute) =>
  //     updateDataWithPreference(sharedPrefAdhanManualCorrect[adhanID], minute);

  String get manualCorrectionAll {
    return _manualCorrection.toString();
  }

  // void changeNotifyType(int adhanType, int newVal) =>
  // updateDataWithPreference(sharedPrefAdhanNotifyID[adhanType], newVal);

  // void changeNotifyDelay(int adhanType, int newVal) =>
  // updateDataWithPreference(sharedPrefAdhanNotifyBefore[adhanType], newVal);
}
