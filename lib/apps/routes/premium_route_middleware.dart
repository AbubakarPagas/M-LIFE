// ─────────────────────────────────────────────────────────────────────────────
// premium_route_middleware.dart
//
// GetX route middleware that blocks direct URL navigation to premium pages
// when the user does not have an active premium subscription.
// Redirects non-premium users to the home route instead.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../presentation/pages/profile/controller/profile_controller.dart';
import 'route_name.dart';

class PremiumRouteMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Allow access if the user has an active premium subscription.
    bool isPremium = false;
    try {
      isPremium = Get.find<ProfileController>().isPremium.value;
    } catch (_) {
      // Controller not yet registered — deny access.
    }

    if (isPremium) return null; // allow

    // Redirect to home; the premium modal will be shown from there if needed.
    return const RouteSettings(name: RoutesName.home);
  }
}
