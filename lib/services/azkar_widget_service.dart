import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../presentation/pages/adhkar/controller/adhkar_controller.dart';

/// Manages the Azkar home-screen widget from the Flutter side.
///
/// Responsibilities:
///   • Load [assets/json/azkar.json] and serialize it for native consumption.
///   • Communicate with the Android Kotlin layer via [MethodChannel].
///   • Persist the ON/OFF toggle state in [GetStorage] so it survives restarts.
///
/// Channel methods exposed on the Kotlin side (MainActivity.kt):
///   setWidgetEnabled(enabled: bool)  → null
///   syncAzkar(azkar: String)         → int (count stored)
///   updateWidget()                   → null
///   getWidgetEnabled()               → bool
class AzkarWidgetService extends GetxController {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static AzkarWidgetService get instance =>
      GetInstance().putOrFind(() => AzkarWidgetService());

  // ── MethodChannel ──────────────────────────────────────────────────────────
  static const MethodChannel _channel = MethodChannel(
    'com.misbah.azkar_widget',
  );

  // ── Persistent storage ─────────────────────────────────────────────────────
  static const String _kEnabled = 'azkar_widget_enabled';
  final _box = GetStorage();

  // ── Reactive state ─────────────────────────────────────────────────────────
  /// Whether the ON/OFF toggle in Settings is currently ON.
  final RxBool isEnabled = false.obs;

  /// True while an async operation (enable/disable/sync) is in progress.
  final RxBool isLoading = false.obs;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadPersistedState();
  }

  /// Reads the persisted toggle state and syncs it from the native side.
  void _loadPersistedState() {
    // Restore from local storage first (instant, no async needed).
    final stored = _box.read<bool>(_kEnabled) ?? false;
    isEnabled.value = stored;

    // Then verify what the native side thinks (handles edge cases like
    // a fresh install where storage is empty but native prefs are set).
    if (Platform.isAndroid) {
      _channel
          .invokeMethod<bool>('getWidgetEnabled')
          .then((nativeValue) {
            if (nativeValue != null && nativeValue != stored) {
              isEnabled.value = nativeValue;
              _box.write(_kEnabled, nativeValue);
            }
          })
          .catchError((Object e) {
            log(
              'AzkarWidgetService: getWidgetEnabled failed — $e',
              name: 'AzkarWidgetService',
            );
            return null;
          });
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Toggle the widget ON or OFF.
  ///
  /// When turning ON:
  ///   1. Loads azkar.json and syncs data to Android.
  ///   2. Enables native scheduling.
  ///   3. Triggers an immediate widget refresh.
  ///
  /// When turning OFF:
  ///   1. Disables native scheduling.
  ///   2. Preserves all stored data (no delete).
  Future<void> setEnabled(bool enabled) async {
    if (!Platform.isAndroid) return;
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      if (enabled) {
        // Sync azkar data first so the widget has content before it appears.
        await _syncAzkar();
      }

      await _channel.invokeMethod('setWidgetEnabled', {'enabled': enabled});

      if (enabled) {
        // Immediately refresh the widget UI with the first/current azkar.
        await _channel.invokeMethod('updateWidget');
      }

      isEnabled.value = enabled;
      _box.write(_kEnabled, enabled);

      log(
        'AzkarWidgetService: widget ${enabled ? "enabled" : "disabled"}',
        name: 'AzkarWidgetService',
      );
    } on PlatformException catch (e) {
      log(
        'AzkarWidgetService: setEnabled($enabled) failed — ${e.message}',
        name: 'AzkarWidgetService',
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Forces an immediate widget refresh without toggling the enabled state.
  /// Useful for testing or after the app updates azkar data.
  Future<void> refreshWidget() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('updateWidget');
      log(
        'AzkarWidgetService: manual widget refresh triggered',
        name: 'AzkarWidgetService',
      );
    } on PlatformException catch (e) {
      log(
        'AzkarWidgetService: refreshWidget failed — ${e.message}',
        name: 'AzkarWidgetService',
      );
    }
  }

  // ── Internal helpers ───────────────────────────────────────────────────────

  /// Loads azkar.json via the existing [AzkarController] pipeline (which
  /// already handles field normalisation) and pushes the data to Android.
  Future<void> _syncAzkar() async {
    try {
      // Reuse the existing AzkarController's JSON-loading logic so we stay
      // consistent with how the rest of the app parses azkar.json.
      final azkarCtrl = AzkarController.instance;

      // Fetch the full parsed list (already normalised).
      final entries = await azkarCtrl.readJsonData();
      if (entries.isEmpty) {
        log(
          'AzkarWidgetService: azkar list is empty — skipping sync',
          name: 'AzkarWidgetService',
        );
        return;
      }

      // Serialize to a JSON array that the Kotlin side can parse.
      final jsonList = entries
          .map(
            (e) => {
              'id': e.id,
              'category': e.category,
              'count': e.count,
              'zekr': e.zekr,
              'zekrs': e.zekrs,
              'description': e.description,
              'descriptions': e.descriptions,
              'reference': e.reference,
              'references': e.references,
            },
          )
          .toList();

      final jsonString = jsonEncode(jsonList);

      final count = await _channel.invokeMethod<int>('syncAzkar', {
        'azkar': jsonString,
      });

      log(
        'AzkarWidgetService: synced $count azkar entries to Android',
        name: 'AzkarWidgetService',
      );
    } on PlatformException catch (e) {
      log(
        'AzkarWidgetService: syncAzkar failed — ${e.message}',
        name: 'AzkarWidgetService',
      );
      rethrow;
    } catch (e) {
      log(
        'AzkarWidgetService: unexpected error during sync — $e',
        name: 'AzkarWidgetService',
      );
      rethrow;
    }
  }
}
