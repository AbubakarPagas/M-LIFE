import 'prayer_foreground_service.dart';

/// Called once during app initialisation.
/// Sets up the flutter_foreground_task options so that
/// [startPrayerForegroundService] can be called immediately after.
Future<void> initFlutterAndroidBackgroundService() async {
  initPrayerForegroundTask();
}
