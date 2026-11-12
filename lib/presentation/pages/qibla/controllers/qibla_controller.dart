// ── Qibla Controller ─────────────────────────────────────────────────────────
// GetX controller that orchestrates compass, location, and settings state.
// Uses flutter_device_compass for real-time heading via device magnetometer.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
// import 'package:flutter_device_compass/flutter_device_compass.dart';
import 'package:get/get.dart';

import '../../../../apps/models/LocationInfo.dart';
import '../../../../helpers/gps_location_helper.dart';
import '../models/qibla_settings_model.dart';
import '../services/qibla_calculation_service.dart';
import '../services/qibla_settings_service.dart';

// ─────────────────────────────────────────────────────────────────────────────

/// Angle tolerance (degrees) for "facing Qibla" detection.
const double _kAlignmentTolerance = 5.0;

// ─────────────────────────────────────────────────────────────────────────────

class QiblaController extends GetxController {
  // ── Services ───────────────────────────────────────────────────────────────
  final QiblaSettingsService _settingsService = QiblaSettingsService();
  final QiblaCalculationService _calcService = const QiblaCalculationService();

  // ── Stream subscription ────────────────────────────────────────────────────
  // StreamSubscription<CompassEvent>? _compassSub;

  // ── Reactive state ─────────────────────────────────────────────────────────

  Rx<QiblaSettings> settings = const QiblaSettings().obs;
  Rx<LocationState> locationState = Rx<LocationState>(
    LocationNotAvailable(locationNACauseFinding),
  );

  /// Smoothed compass heading (degrees, 0–360).
  RxDouble compassHeading = 0.0.obs;

  /// Absolute Qibla bearing from north (degrees, 0–360).
  RxDouble qiblaDirection = 0.0.obs;

  /// True when user is within ±5° of Qibla.
  RxBool isFacingQibla = false.obs;

  /// True while the initial location fetch is in progress.
  RxBool isLoadingLocation = true.obs;

  /// Non-null when an error has occurred.
  RxnString errorMessage = RxnString();

  /// True when compass hardware is not available.
  RxBool compassNotSupported = false.obs;

  /// Cached Qibla calculation result.
  Rx<QiblaResult?> qiblaResult = Rx<QiblaResult?>(null);

  /// True when in full-screen compass mode.
  RxBool isFullScreen = false.obs;

  /// True when compass readings may be unreliable (accuracy deviation > 20°).
  RxBool needsCalibration = false.obs;

  // ── Internal ───────────────────────────────────────────────────────────────
  double _lastHeading = 0.0;
  bool _hasVibratedForAlignment = false;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    settings.value = _settingsService.load();
    _initLocation();
  }

  @override
  void onClose() {
    // _compassSub?.cancel();
    super.onClose();
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> retryLocation() => _initLocation();

  Future<void> updateSettings(QiblaSettings newSettings) async {
    settings.value = newSettings;
    await _settingsService.save(newSettings);
  }

  Future<void> setManualLocation(
    double lat,
    double lng, {
    String address = '',
    String locality = '',
    String country = '',
  }) async {
    final info = LocationInfo(
      latitude: lat,
      longitude: lng,
      address: address.isEmpty ? '($lat, $lng)' : address,
      locality: locality,
      country: country,
      lastUpdated: DateTime.now(),
      mode: LocationMode.manual,
    );
    locationState.value = LocationAvailable(info);
    _recalculate(info);
    isLoadingLocation.value = false;
    errorMessage.value = null;
  }

  void toggleFullScreen() => isFullScreen.value = !isFullScreen.value;

  // ── Compass rotation helpers (radians) ─────────────────────────────────────

  /// Rotates the compass rose so north stays at top.
  double get compassRotationRad => -compassHeading.value * math.pi / 180.0;

  /// Angle of the Qibla needle (absolute offset from north).
  double get qiblaRotationRad => qiblaDirection.value * math.pi / 180.0;

  // ── Private: location init ─────────────────────────────────────────────────

  Future<void> _initLocation() async {
    isLoadingLocation.value = true;
    errorMessage.value = null;

    // Check compass sensor availability.
    /* final hasSensors = await FlutterCompass.hasSensors ?? false;
    if (!hasSensors) {
      compassNotSupported.value = true;
    } */

    const helper = LocationHelper();
    final state = await helper.getLocationFromGPS(background: false);
    locationState.value = state;
    isLoadingLocation.value = false;

    if (state is LocationAvailable) {
      _recalculate(state.locationInfo);
      if (!compassNotSupported.value) {
        _startCompassStream();
      }
    } else if (state is LocationNotAvailable) {
      errorMessage.value = state.cause;
    }
  }

  void _recalculate(LocationInfo info) {
    final result = _calcService.calculate(
      lat: info.latitude,
      lng: info.longitude,
    );
    qiblaResult.value = result;
    // Keep qiblaDirection in sync with static calculation until compass fires.
    qiblaDirection.value = result.bearing;
  }

  // ── Private: compass stream ────────────────────────────────────────────────

  void _startCompassStream() {
    // _compassSub?.cancel();

    // Choose update profile based on sensitivity setting.
    final sensitivity = settings.value.compassSensitivity;
   /*  final CompassUpdateOptions options;
    if (sensitivity >= 0.7) {
      options = CompassUpdateOptions.fine;
    } else if (sensitivity >= 0.4) {
      options = CompassUpdateOptions.balanced;
    } else {
      options = CompassUpdateOptions.batterySaver;
    }

    _compassSub =
        FlutterCompass.eventsFor(options)?.listen(_onCompassEvent) ??
        FlutterCompass.events?.listen(_onCompassEvent); */
  }

  /* void _onCompassEvent(CompassEvent event) {
    final rawHeading = event.heading;

    // Null heading means sensor is unavailable.
    if (rawHeading == null) {
      compassNotSupported.value = true;
      return;
    }

    // ── Calibration hint from accuracy deviation ──────────────────────────
    // flutter_device_compass exposes accuracy as ±degrees deviation.
    final accuracy = event.accuracy;
    if (accuracy != null && accuracy.isFinite) {
      needsCalibration.value = accuracy > 20.0;
    }

    // ── Low-pass smooth heading ───────────────────────────────────────────
    final sensitivity = settings.value.compassSensitivity;
    final alpha = 0.1 + sensitivity * 0.4; // 0.1 – 0.5

    double diff = rawHeading - _lastHeading;
    while (diff > 180) diff -= 360;
    while (diff < -180) diff += 360;

    final smoothed = (_lastHeading + diff * alpha + 360) % 360;
    _lastHeading = smoothed;
    compassHeading.value = smoothed;

    // ── Qibla direction (bearing from north) ─────────────────────────────
    // qiblaResult.bearing is the absolute Qibla bearing from north.
    // The needle must point at (bearing - heading) relative to the dial.
    final bearing = qiblaResult.value?.bearing ?? 0.0;
    qiblaDirection.value = bearing;

    // ── Alignment detection ───────────────────────────────────────────────
    // User is facing Qibla when their heading matches the Qibla bearing.
    double needleDiff = (bearing - smoothed + 360) % 360;
    if (needleDiff > 180) needleDiff = 360 - needleDiff;
    final aligned = needleDiff <= _kAlignmentTolerance;

    if (aligned && !isFacingQibla.value) {
      isFacingQibla.value = true;
      _onAligned();
    } else if (!aligned) {
      isFacingQibla.value = false;
      _hasVibratedForAlignment = false;
    }
  } */

  void _onAligned() {
    if (!_hasVibratedForAlignment) {
      _hasVibratedForAlignment = true;
      if (settings.value.vibrationEnabled) {
        HapticFeedback.mediumImpact();
      }
    }
  }
}
