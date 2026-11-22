// ─────────────────────────────────────────────────────────────────────────────
// premium_access_guard.dart
//
// Centralised premium-access verification utility.
// Use [PremiumAccessGuard.check] wherever a premium page is about to be opened.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../profile/controller/profile_controller.dart';
import 'premium_access_modal.dart';

/// Identifies every premium feature in the app.
enum PremiumFeature {
  sadaqahJariyah,
  quranContest,
  islamicLive,
  daras,
  fanarAi,
  quizTopic,
}

extension PremiumFeatureX on PremiumFeature {
  /// Human-readable label used in the modal.
  String get displayName {
    switch (this) {
      case PremiumFeature.sadaqahJariyah:
        return 'Sadaqah Jariyah';
      case PremiumFeature.quranContest:
        return "Qur'an Contest";
      case PremiumFeature.islamicLive:
        return 'Islamic Live';
      case PremiumFeature.daras:
        return 'Daras';
      case PremiumFeature.fanarAi:
        return 'Fanar AI';
      case PremiumFeature.quizTopic:
        return 'Quiz Topic';
    }
  }
}

/// Singleton guard.  Keeps access-check logic in one place so it is never
/// duplicated across the six premium pages.
class PremiumAccessGuard {
  PremiumAccessGuard._();

  // ── Public API ───────────────────────────────────────────────────────────

  /// Checks whether the current user has an active premium subscription.
  ///
  /// * If the user **is** a premium subscriber, [onAllowed] is invoked
  ///   immediately (e.g. navigate to the page) and the method returns `true`.
  /// * If the user is **not** a premium subscriber, the Premium Unlock modal
  ///   is displayed and [onAllowed] is NOT invoked.  The method returns `false`.
  ///
  /// [context] must be a valid [BuildContext] for the dialog to attach to.
  /// [feature] identifies which premium page was tapped (used in the modal).
  /// [onAllowed] is the navigation / action to perform on success.
  static Future<bool> check(
    BuildContext context, {
    required PremiumFeature feature,
    required VoidCallback onAllowed,
  }) async {
    // ── 1. Resolve premium state ──────────────────────────────────────────
    final bool isPremium = _resolvePremiumState();

    if (isPremium) {
      onAllowed();
      return true;
    }

    // ── 2. Not premium — show unlock modal ────────────────────────────────
    final result = await showPremiumAccessModal(
      context,
      featureName: feature.displayName,
    );

    // If the user unlocked (toggled premium), allow navigation now
    if (result == true) {
      onAllowed();
      return true;
    }

    return false;
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  /// Reads premium state from [ProfileController].
  /// Falls back to `false` if the controller is not yet registered (safe).
  static bool _resolvePremiumState() {
    try {
      return Get.find<ProfileController>().isPremium.value;
    } catch (_) {
      // Controller not registered yet — treat as non-premium.
      return false;
    }
  }
}
