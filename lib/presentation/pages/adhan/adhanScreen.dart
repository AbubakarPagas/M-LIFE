import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../apps/views/apps.dart';
import '../../../helpers/gps_location_helper.dart';
import '../../../provider/adhanProvider.dart';
import '../../../provider/locationProvider.dart';
import 'widgets/AdhanAvailableScreen.dart';
import 'widgets/locationFindingScreen.dart';
import 'widgets/locationNotAvailableScreen.dart';
import 'widgets/unknownErrorScreen.dart';

class AdhanScreen extends StatelessWidget {
  const AdhanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationState = context.watch<LocationProvider>().locationState;

    if (locationState is LocationAvailable) {
      // AdhanProvider is pre-built at app startup inside AdhanProviderWrapper.
      // We expose it as a scoped ChangeNotifierProvider.value so the subtree
      // can watch it without reconstructing it on every rebuild.
      final adhanProvider = context.watch<AdhanProviderWrapper>().adhanProvider;

      if (adhanProvider != null) {
        return ChangeNotifierProvider<AdhanProvider>.value(
          key: const ValueKey('adhan_available'),
          value: adhanProvider,
          child: AdhanAvailableScreen(locationState.locationInfo),
        );
      }

      // Wrapper exists but hasn't resolved yet — show finding screen briefly.
      return const LocationFindingScreen(key: ValueKey('location_finding'));
    } else if (locationState is LocationFinding) {
      return const LocationFindingScreen(key: ValueKey('location_finding'));
    } else if (locationState is LocationNotAvailable) {
      return LocationNotAvailableScreen(
        locationState,
        key: const ValueKey('location_not_available'),
      );
    } else {
      return const UnknownErrorScreen(key: ValueKey('unknown_error'));
    }
  }
}
