// ── Qibla Controller ─────────────────────────────────────────────────────────
// GetX controller that orchestrates compass, location, and settings state.
// Uses flutter_qiblah 3.2.0 — QiblahDirection has: qiblah, direction, offset.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
// import 'package:flutter_qiblah/flutter_qiblah.dart';
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
  // StreamSubscription<QiblahDirection>? _qiblahStream;

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

  /// True when compass readings may be unreliable (low heading stability).
  /// We track this by watching for large jumps between events.
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
    // _qiblahStream?.cancel();
    // FlutterQiblah().dispose();
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

  /// Human-readable accuracy label derived from compass heading stability.
  /// flutter_qiblah 3.x does not expose a separate accuracy field; we derive
  /// a rough quality indicator from whether the stream is active.
  // String get accuracyLabel => _qiblahStream != null ? 'High' : 'Unavailable';

  // ── Private: location init ─────────────────────────────────────────────────

  Future<void> _initLocation() async {
    isLoadingLocation.value = true;
    errorMessage.value = null;

    // Check sensor support (Android only; returns null/true on iOS).
    /*   final supported = await FlutterQiblah.androidDeviceSensorSupport();
    if (supported == false) {
      compassNotSupported.value = true;
    } */

    const helper = LocationHelper();
    final state = await helper.getLocationFromGPS(background: false);
    locationState.value = state;
    isLoadingLocation.value = false;

    if (state is LocationAvailable) {
      _recalculate(state.locationInfo);
      _startCompassStream();
    } else if (state is LocationNotAvailable) {
      errorMessage.value = state.cause;
    }
  }

  void _recalculate(LocationInfo info) {
    qiblaResult.value = _calcService.calculate(
      lat: info.latitude,
      lng: info.longitude,
    );
  }

  // ── Private: compass stream ────────────────────────────────────────────────

  void _startCompassStream() {
    // _qiblahStream?.cancel();
    // _qiblahStream = FlutterQiblah.qiblahStream.listen(_onQiblahEvent);
  }

  void _onQiblahEvent(event) {
    // ── Smooth heading (low-pass filter) ──────────────────────────────────────
    // event.direction = current device heading (0–360, north = 0)
    // event.qiblah   = Qibla direction relative to north
    final sensitivity = settings.value.compassSensitivity;
    final alpha = 0.1 + sensitivity * 0.4; // 0.1 – 0.5

    double diff = event.direction - _lastHeading;
    while (diff > 180) diff -= 360;
    while (diff < -180) diff += 360;

    // Large sudden jump → heading is unstable → suggest calibration.
    needsCalibration.value = diff.abs() > 45;

    final smoothed = (_lastHeading + diff * alpha + 360) % 360;
    _lastHeading = smoothed;
    compassHeading.value = smoothed;

    // Qibla offset from north — use the raw value from the plugin.
    qiblaDirection.value = event.qiblah;

    // ── Alignment detection ────────────────────────────────────────────────
    // The needle is aligned when qiblah ≈ 360 (or 0), meaning the phone
    // is pointing toward the Kaaba.  flutter_qiblah reports `qiblah` as
    // the heading + offset, so alignment = qiblah mod 360 ≈ 0.
    double needleDiff = event.qiblah % 360;
    if (needleDiff > 180) needleDiff = 360 - needleDiff;
    final aligned = needleDiff <= _kAlignmentTolerance;

    if (aligned && !isFacingQibla.value) {
      isFacingQibla.value = true;
      _onAligned();
    } else if (!aligned) {
      isFacingQibla.value = false;
      _hasVibratedForAlignment = false;
    }
  }

  void _onAligned() {
    if (!_hasVibratedForAlignment) {
      _hasVibratedForAlignment = true;
      if (settings.value.vibrationEnabled) {
        HapticFeedback.mediumImpact();
      }
    }
  }
}
