import 'package:flutter/cupertino.dart';
import 'package:misbah_path/preference/preference.dart';

// import '../../extensions/extensions.dart';

abstract class DependencyProvider with ChangeNotifier {
  // @inline
  void updateDataByRunning(Future Function() clbk) {
    clbk().then((value) => notifyListeners());
  }

  // @inline
  void updateDataWithPreference<T extends Object>(Preference<T> pref, T value) {
    pref.updateValue(value).then((value) => notifyListeners());
  }
}
