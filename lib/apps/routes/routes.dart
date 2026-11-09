import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:misbah_path/presentation/pages/setting/setting_page.dart';

import '../../presentation/pages/Fanar_ai/fanar_ai.dart';
import '../../presentation/pages/adhan/adhanScreen.dart';
// import '../../presentation/pages/adhkar/screens/adhkar_setting.dart';
import '../../presentation/pages/adhkar/screens/adhkar_view.dart';
import '../../presentation/pages/adhkar_dua/screens/adhkar_view.dart';
import '../../presentation/pages/books/books.dart';
import '../../presentation/pages/calendar/events.dart' hide Hadith;
import '../../presentation/pages/daras/screens/dars_all_screen.dart';
import '../../presentation/pages/daras/screens/dars_bookmarks_screen.dart';
import '../../presentation/pages/daras/screens/dars_categories_screen.dart';
import '../../presentation/pages/daras/screens/dars_courses_screen.dart';
import '../../presentation/pages/daras/screens/dars_downloads_screen.dart';
import '../../presentation/pages/daras/screens/dars_history_screen.dart';
import '../../presentation/pages/daras/screens/dars_home_screen.dart';
import '../../presentation/pages/daras/screens/dars_live_screen.dart';
import '../../presentation/pages/daras/screens/dars_playlists_screen.dart';
import '../../presentation/pages/daras/screens/dars_search_screen.dart';
import '../../presentation/pages/direction/direction.dart';
import '../../presentation/pages/hadith/hadith.dart';
import '../../presentation/pages/halal_finance/ui/screens/halal_finance_screen.dart';
import '../../presentation/pages/name/name_of_allah.dart';
import '../../presentation/pages/prayer_tracking/ui/notification_center_screen.dart';
import '../../presentation/pages/prayer_tracking/ui/prayer_tracking_screen.dart';
import '../../presentation/pages/sadaqah/screens/sadaqah_screen.dart';
// import '../../presentation/pages/surah_audio/audio_surah.dart';
import '../../presentation/pages/surah_audio/surah_audio.dart';
import '../../presentation/pages/tabs.dart';
import '../../presentation/pages/tasbih/tasbih.dart';
import '../../presentation/pages/ummah_feed/ui/screens/post_detail_screen.dart';
import '../../presentation/pages/ummah_feed/ui/screens/ummah_feed_screen.dart';
import '../../presentation/pages/welcome/welcomeScreen.dart';
import '../../presentation/pages/zakat/ui/screens/zakat_assets_screen.dart';
import '../../presentation/pages/zakat/ui/screens/zakat_dashboard_screen.dart';
import '../../presentation/pages/zakat/ui/screens/zakat_education_screen.dart';
import '../../presentation/pages/zakat/ui/screens/zakat_history_screen.dart';
import '../../presentation/pages/zakat/ui/screens/zakat_liabilities_screen.dart';
import '../../presentation/pages/zakat/ui/screens/zakat_result_screen.dart';
import '../../presentation/pages/zakat/ui/screens/zakat_settings_screen.dart';
import 'custom_route.dart';
import 'route_name.dart';

abstract class Routes {
  static List<GetPage<dynamic>>? pages = [
    GetPage(name: RoutesName.home, page: () => const Tabs()),
    GetPage(name: RoutesName.setting, page: () => const SettingPage()),
    GetPage(name: RoutesName.prayerTime, page: () => const AdhanScreen()),
    GetPage(name: RoutesName.hadith, page: () => const Hadith()),
    GetPage(name: RoutesName.dua, page: () => const AdhkarViewDua()),
    GetPage(name: RoutesName.azkar, page: () => const AdhkarView()),
    GetPage(name: RoutesName.tasbih, page: () => const Tasbih()),
    GetPage(name: RoutesName.name, page: () => const NameOfAllah()),
    GetPage(name: RoutesName.direction, page: () => const Direction()),
    GetPage(name: RoutesName.daras, page: () => const DarsHomeScreen()),
    GetPage(
      name: RoutesName.welcome,
      page: () => const WelcomeScreen(showWarning: false, build: 'Stable'),
    ),
    GetPage(name: RoutesName.audio, page: () => const AudioScreen()),
    GetPage(name: RoutesName.calendar, page: () => const HijriCalendarScreen()),
    GetPage(name: RoutesName.books, page: () =>  BooksScreen()),
    //  GetPage(name: RoutesName.athkarSetting, page: () => const AdhkarSetting()),
    GetPage(
      name: RoutesName.prayerTracking,
      page: () => const PrayerTrackingScreen(),
    ),
    GetPage(
      name: RoutesName.notificationCenter,
      page: () => const NotificationCenterScreen(),
    ),
    GetPage(name: RoutesName.fanarAi, page: () => const FanarAiPage()),
    GetPage(
      name: RoutesName.fanarConversations,
      page: () => const ConversationListScreen(),
    ),
    GetPage(name: RoutesName.sadaqah, page: () => const SadaqahScreen()),
    // Zakat Calculator
    GetPage(name: RoutesName.zakat, page: () => const ZakatDashboardScreen()),
    GetPage(
      name: RoutesName.zakatAssets,
      page: () => const ZakatAssetsScreen(),
    ),
    GetPage(
      name: RoutesName.zakatLiabilities,
      page: () => const ZakatLiabilitiesScreen(),
    ),
    GetPage(
      name: RoutesName.zakatResult,
      page: () => const ZakatResultScreen(),
    ),
    GetPage(
      name: RoutesName.zakatHistory,
      page: () => const ZakatHistoryScreen(),
    ),
    GetPage(
      name: RoutesName.zakatEducation,
      page: () => const ZakatEducationScreen(),
    ),
    GetPage(
      name: RoutesName.zakatSettings,
      page: () => const ZakatSettingsScreen(),
    ),
    // Halal Finance Tips
    GetPage(
      name: RoutesName.halalFinance,
      page: () => const HalalFinanceScreen(),
    ),
    // Ummah Feed
    GetPage(name: RoutesName.ummahFeed, page: () => const UmmahFeedScreen()),
    GetPage(
      name: RoutesName.ummahFeedDetail,
      page: () => const PostDetailScreen(),
    ),

    // ── Dars (Islamic Lessons) ────────────────────────────────────────────────
    GetPage(name: RoutesName.darsAll, page: () => const DarsAllScreen()),
    GetPage(name: RoutesName.darsLive, page: () => const DarsLiveScreen()),
    GetPage(
      name: RoutesName.darsCategories,
      page: () => const DarsCategoriesScreen(),
    ),
    GetPage(name: RoutesName.darsSearch, page: () => const DarsSearchScreen()),
    GetPage(
      name: RoutesName.darsPlaylists,
      page: () => const DarsPlaylistsScreen(),
    ),
    GetPage(
      name: RoutesName.darsDownloads,
      page: () => const DarsDownloadsScreen(),
    ),
    GetPage(
      name: RoutesName.darsBookmarks,
      page: () => const DarsBookmarksScreen(),
    ),
    GetPage(
      name: RoutesName.darsHistory,
      page: () => const DarsHistoryScreen(),
    ),
    GetPage(
      name: RoutesName.darsCourses,
      page: () => const DarsCoursesScreen(),
    ),
  ];

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.home:
        return CustomRoute<bool>(builder: (_) => const Tabs());
      case RoutesName.setting:
        return CustomRoute<bool>(builder: (_) => const SettingPage());
      case RoutesName.prayerTime:
        return CustomRoute<bool>(builder: (_) => const AdhanScreen());
      case RoutesName.hadith:
        return CustomRoute<bool>(builder: (_) => const Hadith());
      case RoutesName.audio:
        return CustomRoute<bool>(builder: (_) => const AudioScreen());
      case RoutesName.tasbih:
        return CustomRoute<bool>(builder: (_) => const Tasbih());
      case RoutesName.name:
        return CustomRoute<bool>(builder: (_) => const NameOfAllah());
      case RoutesName.direction:
        return CustomRoute<bool>(builder: (_) => const Direction());
      case RoutesName.daras:
        return CustomRoute<bool>(builder: (_) => const DarsHomeScreen());
      case RoutesName.azkar:
        return CustomRoute<bool>(builder: (_) => const AdhkarView());
      case RoutesName.dua:
        return CustomRoute<bool>(builder: (_) => const AdhkarViewDua());
      case RoutesName.calendar:
        return CustomRoute<bool>(builder: (_) => const HijriCalendarScreen());
      case RoutesName.books:
        return CustomRoute<bool>(builder: (_) =>  BooksScreen());
      // case RoutesName.athkarSetting:
      //   return CustomRoute<bool>(builder: (_) => const AdhkarSetting());
      case RoutesName.prayerTracking:
        return CustomRoute<bool>(builder: (_) => const PrayerTrackingScreen());
      case RoutesName.notificationCenter:
        return CustomRoute<bool>(
          builder: (_) => const NotificationCenterScreen(),
        );
      case RoutesName.fanarAi:
        return CustomRoute<bool>(builder: (_) => const FanarAiPage());
      case RoutesName.fanarConversations:
        return CustomRoute<bool>(
          builder: (_) => const ConversationListScreen(),
        );
      case RoutesName.sadaqah:
        return CustomRoute<bool>(builder: (_) => const SadaqahScreen());
      case RoutesName.zakat:
        return CustomRoute<bool>(builder: (_) => const ZakatDashboardScreen());
      case RoutesName.zakatAssets:
        return CustomRoute<bool>(builder: (_) => const ZakatAssetsScreen());
      case RoutesName.zakatLiabilities:
        return CustomRoute<bool>(
          builder: (_) => const ZakatLiabilitiesScreen(),
        );
      case RoutesName.zakatResult:
        return CustomRoute<bool>(builder: (_) => const ZakatResultScreen());
      case RoutesName.zakatHistory:
        return CustomRoute<bool>(builder: (_) => const ZakatHistoryScreen());
      case RoutesName.zakatEducation:
        return CustomRoute<bool>(builder: (_) => const ZakatEducationScreen());
      case RoutesName.zakatSettings:
        return CustomRoute<bool>(builder: (_) => const ZakatSettingsScreen());
      case RoutesName.halalFinance:
        return CustomRoute<bool>(builder: (_) => const HalalFinanceScreen());
      case RoutesName.ummahFeed:
        return CustomRoute<bool>(builder: (_) => const UmmahFeedScreen());
      case RoutesName.ummahFeedDetail:
        return CustomRoute<bool>(builder: (_) => const PostDetailScreen());
      // ── Dars sub-routes ───────────────────────────────────────────────────
      case RoutesName.darsAll:
        return CustomRoute<bool>(builder: (_) => const DarsAllScreen());
      case RoutesName.darsLive:
        return CustomRoute<bool>(builder: (_) => const DarsLiveScreen());
      case RoutesName.darsCategories:
        return CustomRoute<bool>(builder: (_) => const DarsCategoriesScreen());
      case RoutesName.darsSearch:
        return CustomRoute<bool>(builder: (_) => const DarsSearchScreen());
      case RoutesName.darsPlaylists:
        return CustomRoute<bool>(builder: (_) => const DarsPlaylistsScreen());
      case RoutesName.darsDownloads:
        return CustomRoute<bool>(builder: (_) => const DarsDownloadsScreen());
      case RoutesName.darsBookmarks:
        return CustomRoute<bool>(builder: (_) => const DarsBookmarksScreen());
      case RoutesName.darsHistory:
        return CustomRoute<bool>(builder: (_) => const DarsHistoryScreen());
      case RoutesName.darsCourses:
        return CustomRoute<bool>(builder: (_) => const DarsCoursesScreen());
    }
    return null;
  }
}
