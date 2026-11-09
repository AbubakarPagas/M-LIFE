import 'dart:async';
import 'dart:io' show Platform;

import 'package:connectivity_kit/connectivity_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';
import 'package:misbah_path/core/services/audio/quran_audio_handler.dart';
import 'package:misbah_path/core/services/background_services.dart';
import 'package:misbah_path/core/services/languages/dependency_inj.dart' as dep;
import 'package:misbah_path/core/services/services_locator.dart';
import 'package:misbah_path/core/utils/constants/extensions/convert_number_extension.dart';
import 'package:misbah_path/platforms/prayer_foreground_service.dart';
import 'package:provider/provider.dart';
// import 'package:quran_library/quran.dart';
import 'package:quran_library/quran_library.dart';
import 'package:timezone/data/latest.dart' as tz;
// import '/core/services/languages/dependency_inj.dart' as dep;
import 'package:get/get.dart';


import 'apps/views/apps.dart';
import 'core/services/home_widget_service.dart';
import 'core/utils/constants/shared_preferences_constants.dart';
import 'preference/preference.dart';
import 'presentation/pages/quran_page/quran.dart';
import 'provider/app_init_provider.dart';

// Notification tap stream — consumed by the rest of the app.
final StreamController<NotificationResponse> selectNotificationStream =
    StreamController<NotificationResponse>.broadcast();

const MethodChannel platform = MethodChannel(
  'dexterx.dev/flutter_local_notifications',
);

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print(
    'notification(${notificationResponse.id}) action tapped: '
    '${notificationResponse.actionId} with'
    ' payload: ${notificationResponse.payload}',
  );
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
      'notification action tapped with input: ${notificationResponse.input}',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── flutter_foreground_task: init isolate communication port ──────────────
  FlutterForegroundTask.initCommunicationPort();

  // ── Configure prayer foreground task options BEFORE anything else ─────────
  // This must run in main() so the options are set even when the app is
  // re-launched by the OS after being killed (autoRunOnBoot, etc.).
  initPrayerForegroundTask();

  // ── Localisation ──────────────────────────────────────────────────────────
  final Map<String, Map<String, String>> languages = await dep.init();

  // ── flutter_local_notifications bootstrap ─────────────────────────────────
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_notify');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
    // onDidReceiveNotificationResponse: selectNotificationStream.stream,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  // ── audio_service — background media session + lock-screen / Bluetooth ────
  // Must be registered before any AudioPlayer is created (or before the app
  // calls AudioCtrl.instance which lazily creates one inside quran_library).
  // QuranAudioHandler.register() calls AudioService.init() internally and
  // stores the singleton; the underlying AudioPlayer is attached later the
  // first time playSurahWithCache() is invoked.
  await QuranAudioHandler.register();
  // ── App-level init (preferences, services locator, Quran library) ─────────
  await initPreferences();
  await initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppInitProvider.create(),
      child: MyApp(languages: languages),
    ),
  );
}

Future<void> initializeApp() async {
    try {
    await dotenv.load();
  } catch (_) {
    // الملف اختياري — المساعد الذكي سيُظهر رسالة خطأ عند الاستخدام دون مفتاح.
  }
  final service = ConnectionService(
    options: const ConnectionOptions(enableReachability: true),
  );
  await service.init();

  Get.put(service, permanent: true);
  Get.put(ConnectionController(), permanent: true);
  // طابور الـ feedback: إرسال مؤجَّل يستأنف تلقائيًا عند عودة الاتصال.
  // await FeedbackQueue.init(service);
  await GetStorage.init();
  await QuranLibrary.init(
    numberConverter: (text, {languageCode}) =>
        text.convertNumbersToCurrentLang(),
  );
  QuranLibrary.initWordAudio();
  // NotifyHelper.initAwesomeNotifications();
  await ServicesLocator().init();
  tz.initializeTimeZones();
  // تهيئة Home Widgets - Initialize Home Widgets
  await HomeWidgetService.instance.initializeHomeWidgets();

  if (Platform.isIOS || Platform.isAndroid) {
    await BGServices().registerTask();
  }
  FlutterNativeSplash.remove();
  GetStorage().write(AUDIO_SERVICE_INITIALIZED, false);
  ReadersConstants.customAyahReaders = ayahReaderInfo;

  ReadersConstants.customSurahReaders = surahReaderInfo;
  // QuranLibrary().setFontsSelected = 1;
  // await QuranLibrary.init();
  FlutterNativeSplash.remove();
  // QuranAudioHandler player attachment is done lazily on first surah play
  // via SurahDownloadService.playSurahWithCache() — no extra call needed here.
}
