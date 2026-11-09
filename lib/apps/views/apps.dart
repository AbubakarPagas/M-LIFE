import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' show ScreenUtilInit;
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:misbah_path/core/services/languages/app_constants.dart';
import 'package:misbah_path/core/services/languages/localization_controller.dart';
import 'package:misbah_path/core/services/languages/messages.dart';
import 'package:provider/provider.dart';

import '../../core/services/services_locator.dart';
import '../../helpers/gps_location_helper.dart';
import '../../presentation/controllers/theme_controller.dart';
import '../../provider/adhanProvider.dart';
import '../../provider/app_init_provider.dart';
import '../../provider/dependencies/AdhanDependencyProvider.dart';
import '../../provider/dependencies/GlobalDependencyProvider.dart';
import '../../provider/dependencies/tabProvider.dart';
import '../../provider/locationProvider.dart';
import '../routes/route_name.dart';
import '../routes/routes.dart';

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>> languages;
  const MyApp({Key? key, required this.languages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    sl<ThemeController>().checkTheme();
    final localizationCtrl = Get.find<LocalizationController>();
    // Consumed only for side-effects (triggers rebuild when init completes).
    Provider.of<AppInitProvider>(context, listen: true);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: GlobalDependencyProvider.getInstance(),
        ),
        ChangeNotifierProvider(create: (_) => TabProvider()),
        ChangeNotifierProvider.value(value: LocationProvider.getInstance()),
        ChangeNotifierProvider(create: (_) => AdhanDependencyProvider()),

        // ── AdhanProvider is created eagerly at the top of the tree so it is
        //    fully ready on first frame, regardless of which tab is open.
        //    ChangeNotifierProxyProvider2 automatically recreates it whenever
        //    LocationProvider or AdhanDependencyProvider changes.
        ChangeNotifierProxyProvider2<
          AdhanDependencyProvider,
          LocationProvider,
          AdhanProviderWrapper
        >(
          create: (_) => AdhanProviderWrapper(null),
          update: (_, adhanDep, locationProvider, previous) {
            final state = locationProvider.locationState;
            if (state is LocationAvailable) {
              return AdhanProviderWrapper(
                AdhanProvider(adhanDep, state.locationInfo),
              );
            }
            return previous ?? AdhanProviderWrapper(null);
          },
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return GetBuilder<ThemeController>(
            builder: (themeCtrl) {
              SystemChrome.setSystemUIOverlayStyle(
                SystemUiOverlayStyle(
                  systemNavigationBarColor: context.theme.colorScheme.tertiary,
                ),
              );
              return GetMaterialApp(
                builder: (context, child) {
                  final data = MediaQuery.of(context);
                  return BotToastInit()(
                    context,
                    MediaQuery(
                      data: data.copyWith(
                        textScaler: const TextScaler.linear(0.85),
                      ),
                      child: child!,
                    ),
                  );
                },
                debugShowCheckedModeBanner: false,
                title: 'appName'.tr,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                locale: localizationCtrl.locale,
                translations: Messages(languages: languages),
                fallbackLocale: Locale(
                  AppConstants.languages[1].languageCode,
                  AppConstants.languages[1].countryCode,
                ),
                theme: themeCtrl.currentThemeData,
                getPages: Routes.pages,
                navigatorObservers: [BotToastNavigatorObserver()],
                onGenerateRoute: Routes.onGenerateRoute,
                initialRoute: RoutesName.home,
              );
            },
          );
        },
      ),
    );
  }
}

// ── Public wrapper so AdhanProvider lives in the top-level MultiProvider ───────
//
// ChangeNotifierProxyProvider requires a ChangeNotifier as its output type.
// AdhanProviderWrapper is that thin shell — it holds the real AdhanProvider
// (nullable while location is still resolving) and exposes it to the subtree.
class AdhanProviderWrapper extends ChangeNotifier {
  AdhanProvider? adhanProvider;
  AdhanProviderWrapper(this.adhanProvider);
}
