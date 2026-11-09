import 'package:flutter/cupertino.dart';
import 'package:misbah_path/helpers/gps_location_helper.dart';
import 'package:misbah_path/helpers/preferences.dart';

import '../apps/models/LocationInfo.dart';
import '../notifiers/notifiers.dart';
import '../platforms/prayer_foreground_service.dart';

class LocationProvider with ChangeNotifier {
  LocationProvider._() : _locationHelper = const LocationHelper();

  static LocationProvider? _instance;

  static LocationProvider getInstance() {
    _instance ??= LocationProvider._();
    return _instance!;
  }

  final LocationHelper _locationHelper;
  static LocationState _locationState = LocationNotAvailable(
    locationNACauseFinding,
  );

  LocationState get locationState => _locationState;

  /// True when we are using cached / offline data instead of a live GPS fix.
  bool get isOffline {
    final s = _locationState;
    if (s is LocationAvailable) {
      return s.locationInfo.mode == LocationMode.cached;
    }
    return false;
  }

  // ── Initialisation ────────────────────────────────────────────────────────

  Future<void> init() async {
    // Always try to restore a cached location first so Islamic services
    // are available immediately (even without network / GPS).
    final cached = getPersistentLocation();
    if (cached != null) {
      _locationState = LocationAvailable(cached);
    } else {
      final welcomeShown = sharedPrefWelcomeShown.value;
      if (welcomeShown) {
        _locationState = await _locationHelper.getLocationFromGPS(
          background: false,
        );
      } else {
        _locationState = LocationNotAvailable(locationNACausePermissionDenied);
      }
    }
  }

  // ── GPS refresh ───────────────────────────────────────────────────────────

  Future<void> updateLocationWithGPS({required bool background}) async {
    if (!background) {
      _locationState = LocationFinding();
      notifyListeners();
    }

    LocationState state = await _locationHelper.getLocationFromGPS(
      background: background,
    );

    // If GPS failed, the helper already returns the cached location.
    // Nothing extra needed here.
    _locationState = state;
    notifyListeners();
  }

  // ── Manual location set (e.g. from a city picker) ────────────────────────

  Future<void> setManualLocation(LocationInfo info) async {
    final manual = info.copyWith(mode: LocationMode.manual);
    await LocationHelper.saveLocation(manual);
    _locationState = LocationAvailable(manual);
    notifyListeners();
  }

  // ── Clear cache ───────────────────────────────────────────────────────────

  Future<void> clearSavedLocation() async {
    await sharedPrefLocationLatitude.updateValue(null);
    await sharedPrefLocationLongitude.updateValue(null);
    await sharedPrefLocationAddress.updateValue(null);
    await sharedPrefLocationLocality.updateValue(null);
    await sharedPrefLocationState.updateValue(null);
    await sharedPrefLocationCountry.updateValue(null);
    await sharedPrefLocationTimezone.updateValue(null);
    await sharedPrefLocationUtcOffset.updateValue(null);
    await sharedPrefLocationMode.updateValue(null);
    await sharedPrefLocationLastUpdated.updateValue(null);

    _locationState = LocationNotAvailable(locationNACausePermissionDenied);
    notifyListeners();
  }

  // ── Read cache ────────────────────────────────────────────────────────────

  /// Returns the full [LocationInfo] stored in SharedPreferences, or null.
  LocationInfo? getPersistentLocation() {
    final lat = sharedPrefLocationLatitude.value;
    final lng = sharedPrefLocationLongitude.value;
    if (lat == null || lng == null) return null;

    return LocationInfo(
      latitude: lat,
      longitude: lng,
      address: sharedPrefLocationAddress.value ?? '($lat, $lng)',
      locality: sharedPrefLocationLocality.value ?? '',
      state: sharedPrefLocationState.value ?? '',
      country: sharedPrefLocationCountry.value ?? '',
      timezone: sharedPrefLocationTimezone.value ?? '',
      utcOffset: sharedPrefLocationUtcOffset.value ?? '',
      mode: LocationMode.values.firstWhere(
        (e) => e.name == (sharedPrefLocationMode.value ?? 'cached'),
        orElse: () => LocationMode.cached,
      ),
      lastUpdated: sharedPrefLocationLastUpdated.value != null
          ? DateTime.tryParse(sharedPrefLocationLastUpdated.value!) ??
                DateTime.now()
          : DateTime.now(),
    );
  }

  /// Legacy alias kept for backward compatibility.
  LocationInfo? getPersistantLocation() => getPersistentLocation();

  // ── Notify + side-effects ─────────────────────────────────────────────────

  @override
  void notifyListeners() async {
    final state = _locationState;
    if (state is LocationAvailable) {
      scheduleNotification(showNowIfPersistent: true);
      startPrayerForegroundService();
    }
    super.notifyListeners();
  }
}
