import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:misbah_path/helpers/preferences.dart';

import '../apps/models/LocationInfo.dart';

// ── Error messages ────────────────────────────────────────────────────────────

const locationNACausePermissionDenied =
    'Permission Denied. Please check settings.';
const locationNACausePermissionDeniedForever =
    'Permission Denied Forever. Please check settings.';
const locationNACauseLatLongNull = 'Your location seems to be corrupted.';
const locationNACauseGPSNotEnabled =
    'Your Location Provider is disabled. Please enable it and try again!';
const locationNACauseFinding = 'Finding Your Location! Please wait.';
const locationNACauseNoInternet =
    'No internet connection. Using saved location.';

// ── LocationState hierarchy ───────────────────────────────────────────────────

abstract class LocationState {}

class LocationAvailable extends LocationState {
  final LocationInfo locationInfo;

  LocationAvailable(this.locationInfo);

  String locationAddressOfLength(int length) {
    return locationInfo.address.length < length
        ? locationInfo.address
        : '${locationInfo.address.substring(0, length)}...';
  }

  String get locationLocality => locationInfo.locality;
}

class LocationFinding extends LocationState {}

class LocationNotAvailable extends LocationState {
  final String cause;
  LocationNotAvailable(this.cause);
}

// ── LocationHelper ────────────────────────────────────────────────────────────

class LocationHelper {
  const LocationHelper();

  /// Fetch a fresh GPS fix. Returns [LocationAvailable] on success.
  /// On any failure falls back to the last cached location if available,
  /// otherwise returns [LocationNotAvailable].
  Future<LocationState> getLocationFromGPS({required bool background}) async {
    // ── 1. Check service enabled ──────────────────────────────────────────
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && !background) {
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    }
    if (!serviceEnabled) {
      return _fallbackOrError(locationNACauseGPSNotEnabled);
    }

    // ── 2. Check / request permission ─────────────────────────────────────
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && !background) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return _fallbackOrError(locationNACausePermissionDenied);
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return _fallbackOrError(locationNACausePermissionDeniedForever);
    }

    // ── 3. Get GPS position ───────────────────────────────────────────────
    late Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (_) {
      return _fallbackOrError(locationNACauseGPSNotEnabled);
    }

    final lat = position.latitude;
    final lng = position.longitude;

    // ── 4. Reverse-geocode (needs internet) ───────────────────────────────
    String address = '($lat, $lng)';
    String locality = '';
    String state = '';
    String country = '';

    try {
      final marks = await geocoding.placemarkFromCoordinates(lat, lng);
      if (marks.isNotEmpty) {
        final p = marks.first;
        locality = p.locality ?? p.subAdministrativeArea ?? '';
        state = p.administrativeArea ?? '';
        country = p.country ?? '';
        address = [
          p.name,
          p.subLocality,
          locality,
        ].where((s) => s != null && s.isNotEmpty).join(', ');
        if (address.isEmpty) address = '($lat, $lng)';
      }
    } catch (_) {
      // Reverse geocoding needs internet; fall back to coordinate string.
      // Try to fill from cache if available.
      final cached = _readCachedInfo();
      if (cached != null) {
        locality = cached.locality;
        state = cached.state;
        country = cached.country;
      }
    }

    // ── 5. Timezone ───────────────────────────────────────────────────────
    String timezone = '';
    String utcOffset = '';
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      timezone = tzInfo.identifier;
      final offset = DateTime.now().timeZoneOffset;
      final sign = offset.isNegative ? '-' : '+';
      final h = offset.inHours.abs().toString().padLeft(2, '0');
      final m = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
      utcOffset = '$sign$h:$m';
    } catch (_) {}

    // ── 6. Persist all fields ─────────────────────────────────────────────
    final now = DateTime.now();
    final info = LocationInfo(
      latitude: lat,
      longitude: lng,
      address: address,
      locality: locality,
      state: state,
      country: country,
      timezone: timezone,
      utcOffset: utcOffset,
      mode: LocationMode.live,
      lastUpdated: now,
    );

    await _persistLocation(info);
    return LocationAvailable(info);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Returns a [LocationAvailable] with the cached info if one exists,
  /// or a [LocationNotAvailable] with [cause].
  LocationState _fallbackOrError(String cause) {
    final cached = _readCachedInfo();
    if (cached != null) {
      // Upgrade mode to cached so UI can show the correct source label.
      return LocationAvailable(cached.copyWith(mode: LocationMode.cached));
    }
    return LocationNotAvailable(cause);
  }

  /// Reads previously persisted location from SharedPreferences.
  LocationInfo? _readCachedInfo() {
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

  /// Persists all location fields to SharedPreferences.
  static Future<void> _persistLocation(LocationInfo info) async {
    await sharedPrefLocationLatitude.updateValue(info.latitude);
    await sharedPrefLocationLongitude.updateValue(info.longitude);
    await sharedPrefLocationAddress.updateValue(info.address);
    await sharedPrefLocationLocality.updateValue(info.locality);
    await sharedPrefLocationState.updateValue(info.state);
    await sharedPrefLocationCountry.updateValue(info.country);
    await sharedPrefLocationTimezone.updateValue(info.timezone);
    await sharedPrefLocationUtcOffset.updateValue(info.utcOffset);
    await sharedPrefLocationMode.updateValue(info.mode.name);
    await sharedPrefLocationLastUpdated.updateValue(
      info.lastUpdated.toIso8601String(),
    );
  }

  /// Public helper so [LocationProvider] can also persist manual locations.
  static Future<void> saveLocation(LocationInfo info) => _persistLocation(info);
}
