import 'package:flutter/material.dart';
import 'package:misbah_path/notifiers/notifiers.dart';
import 'package:misbah_path/platforms/android_flutter_background_service.dart';
import 'package:misbah_path/platforms/prayer_foreground_service.dart';
import 'package:misbah_path/provider/locationProvider.dart';

import 'dependencies/GlobalDependencyProvider.dart';

class AppInitProvider with ChangeNotifier {
  bool _initComplete = false;

  bool get initComplete => _initComplete;

  AppInitProvider._();

  factory AppInitProvider.create() => AppInitProvider._().._initFunction();

  void _setInitComplete(bool value) {
    _initComplete = value;
    notifyListeners();
  }

  void _initFunction() async {
    // 1. Initialise foreground task config (must be before startService).
    await initFlutterAndroidBackgroundService();

    // 2. Resolve location & global dependencies FIRST so that
    //    SharedPreferences already has lat/lng when the service starts.
    await GlobalDependencyProvider.getInstance().init();
    await LocationProvider.getInstance().init();

    // 3. Schedule the next adhan alarm — location is now available.
    await scheduleNotification(showNowIfPersistent: true);

    // 4. Start the persistent prayer-status notification.
    //    Location is resolved so _computeSnapshot() will succeed immediately.
    await startPrayerForegroundService();

    _setInitComplete(true);
  }
}
