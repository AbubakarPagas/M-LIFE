import 'dart:io' show Platform;

// import 'package:desktop_window/desktop_window.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../presentation/pages/books/books.dart';
import '../../presentation/pages/books/data/services/narrators_service.dart';
import '/presentation/controllers/daily_ayah_controller.dart';
import '/presentation/controllers/general/general_controller.dart';
import '/presentation/controllers/settings_controller.dart';
import '/presentation/controllers/theme_controller.dart';
import '../../presentation/pages/adhkar/controller/adhkar_controller.dart';
import '../../presentation/pages/adhkar_dua/controller/adhkar_dua_controller.dart';
// import '../../presentation/pages/books/controller/books_controller.dart';
import '../../presentation/pages/daras/controller/dars_controller.dart';
import '../../presentation/pages/quran_page/quran.dart';
import '../../presentation/pages/quran_page/widgets/search/controller/quran_search_controller.dart';
import '../../presentation/pages/sadaqah/controllers/sadaqah_controller.dart';
import '../../services/azkar_widget_service.dart';
import '../utils/constants/shared_preferences_constants.dart';
// import '../../presentation/pages/surah_audio/controller/surah_audio_controller.dart'
// show SurahAudioController;
import '../utils/helpers/ui_helper.dart';
import '../widgets/local_notification/controller/local_notifications_controller.dart';
import 'ayah_audio_share_service.dart';
import 'sync/sync_controller.dart';

final sl = GetIt.instance;

class ServicesLocator {
  // Future<void> _initPrefs() async =>
  /* await SharedPreferences.getInstance().then((v) {
     sl.registerSingleton<SharedPreferences>(v);
   }); */

  Future _windowSize() async {
    // if (Platform.isMacOS || Platform.isWindows || Platform.isLinux)
    // await DesktopWindow.setWindowSize(const Size(900, 840));
  }

  Future<void> init() async {
    await Future.wait([
      // _initPrefs(), // moved to notificationsCtrl
      _windowSize(),
    ]);

    // Controllers
    sl.registerLazySingleton<ThemeController>(
      () => Get.put<ThemeController>(ThemeController(), permanent: true),
    );

    sl.registerLazySingleton<GeneralController>(
      () => Get.put<GeneralController>(GeneralController(), permanent: true),
    );

    sl.registerSingleton<QuranController>(
      Get.put<QuranController>(QuranController(), permanent: true),
    );

    // sl.registerLazySingleton<TafsirAndTranslateController>(
    //   () => Get.put<TafsirAndTranslateController>(
    //     TafsirAndTranslateController(),
    //     permanent: true,
    //   ),
    // );

    sl.registerLazySingleton<BookmarksController>(
      () =>
          Get.put<BookmarksController>(BookmarksController(), permanent: true),
    );

    sl.registerLazySingleton<QuranSearchController>(
      () => Get.put<QuranSearchController>(
        QuranSearchController(),
        permanent: true,
      ),
    );

    sl.registerLazySingleton<SettingsController>(
      () => Get.put<SettingsController>(SettingsController(), permanent: true),
    );
    sl.registerSingleton<AzkarController>(
      Get.put<AzkarController>(AzkarController(), permanent: true),
    );
    sl.registerSingleton<AzkarDuaController>(
      Get.put<AzkarDuaController>(AzkarDuaController(), permanent: true),
    );

    sl.registerLazySingleton<ShareController>(
      () => Get.put<ShareController>(ShareController(), permanent: true),
    );
    
    sl.registerLazySingleton<AyahAudioShareService>(
      () => Get.put<AyahAudioShareService>(
        AyahAudioShareService(),
        permanent: true,
      ),
    );

     // eager وليس lazy: حتى يعمل تريغر الإطلاق/العودة للمستخدمين المُقرنين
    // دون الحاجة لفتح شاشة المزامنة أولًا (GetStorage مهيأ قبل init).
    sl.registerSingleton<SyncController>(
      Get.put<SyncController>(SyncController(), permanent: true),
    );

    sl.registerLazySingleton<PlayListController>(
      () => Get.put<PlayListController>(PlayListController(), permanent: true),
    );

    /* sl.registerLazySingleton<SplashScreenController>(() =>
        Get.put<SplashScreenController>(SplashScreenController(),
            permanent: true)); */

    /*    sl.registerLazySingleton<OurAppsController>(
        () => Get.put<OurAppsController>(OurAppsController(), permanent: true)); */

    sl.registerLazySingleton<KhatmahController>(
      () => Get.put<KhatmahController>(KhatmahController(), permanent: true),
    );

    sl.registerLazySingleton<DailyAyahController>(
      () =>
          Get.put<DailyAyahController>(DailyAyahController(), permanent: true),
    );

    sl.registerLazySingleton<BooksController>(
      () => Get.put<BooksController>(BooksController(), permanent: true),
    );

    sl.registerSingleton<SadaqahController>(
      Get.put<SadaqahController>(SadaqahController(), permanent: true),
    );

    sl.registerLazySingleton<AzkarWidgetService>(
      () => Get.put<AzkarWidgetService>(AzkarWidgetService(), permanent: true),
    );

    sl.registerLazySingleton<DarsController>(
      () => Get.put<DarsController>(DarsController(), permanent: true),
    );

    // تحميل خدمة الرواة في الخلفية
    Get.putAsync<NarratorsService>(() async {
      final service = NarratorsService();
      // لا نحتاج loadIndex — onInit يحاول التحميل من القرص تلقائياً
      return service;
    }, permanent: true);

    // sl.registerLazySingleton<WhatsNewController>(() =>
    //     Get.put<WhatsNewController>(WhatsNewController(), permanent: true));

    sl.registerLazySingleton<LocalNotificationsController>(
      () => Get.put<LocalNotificationsController>(
        LocalNotificationsController(),
        permanent: true,
      ),
    );
    // UiHelper.initReviewGate();

    // sl.registerLazySingleton<TafsirCtrl>(
    //     () => Get.put<TafsirCtrl>(TafsirCtrl(), permanent: true));
    // NotifyHelper().initializeNotification();
    // sl<NotificationsController>().initializeLocalNotifications();

    if (Platform.isIOS || Platform.isAndroid || Platform.isFuchsia) {
      // UiHelper.rateMyApp.init();
      // Future.delayed(const Duration(seconds: 7)).then((_) => {
      //       AudioService.init(
      //         builder: () => AudioPlayerHandler(),
      //         config: const AudioServiceConfig(
      //           androidNotificationChannelId:
      //               'com.alheekmah.alquranalkareem.alquranalkareem',
      //           androidNotificationChannelName: 'Audio playback',
      //           androidNotificationOngoing: true,
      //         ),
      //       )
      //     });
    }

    // if (Platform.isIOS) {
    // await AudioService.init(
    //   androidNotificationChannelId:
    //       'com.alheekmah.alquranalkareem.alquranalkareem',
    //   androidNotificationChannelName: 'Audio playback',
    //   androidNotificationOngoing: true,
    // );
    // }

    // Workmanager().initialize(sl<NotificationController>().callbackDispatcher);
    // sl<NotificationController>().registerBackgroundTask();
    await GetStorage.init();
    if (GetStorage().read(AUDIO_SERVICE_INITIALIZED) == null) {
      GetStorage().write(AUDIO_SERVICE_INITIALIZED, false);
    }

    final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
  }
}
