// ── Qibla Calculation Service ────────────────────────────────────────────────
// Pure Dart – no Flutter dependencies.
// Calculates the Qibla bearing from any coordinate to the Kaaba.

import 'dart:math' as math;

/// Geographic coordinates of the Kaaba in Makkah.
const double _kaabatLat = 21.4225241;
const double _kaabatLng = 39.8261818;

/// Earth's mean radius in km.
const double _earthRadiusKm = 6371.0;

/// Result of a Qibla calculation.
class QiblaResult {
  /// Bearing in degrees (0–360, clockwise from North).
  final double bearing;

  /// Great-circle distance to Makkah in km.
  final double distanceKm;

  const QiblaResult({required this.bearing, required this.distanceKm});

  /// Distance formatted as a human-readable string.
  String get distanceLabel {
    if (distanceKm < 1) return '${(distanceKm * 1000).round()} m';
    if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
    return '${distanceKm.round()} km';
  }
}

/// Stateless service; all methods are pure functions.
class QiblaCalculationService {
  const QiblaCalculationService();

  /// Calculates the Qibla bearing and distance from [lat], [lng].
  QiblaResult calculate({required double lat, required double lng}) {
    final bearing = _bearing(lat, lng, _kaabatLat, _kaabatLng);
    final distance = _haversine(lat, lng, _kaabatLat, _kaabatLng);
    return QiblaResult(bearing: bearing, distanceKm: distance);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  double _toRad(double deg) => deg * math.pi / 180.0;
  double _toDeg(double rad) => rad * 180.0 / math.pi;

  /// Forward azimuth (bearing) from point 1 to point 2, in degrees [0, 360).
  double _bearing(double lat1, double lng1, double lat2, double lng2) {
    final dLng = _toRad(lng2 - lng1);
    final radLat1 = _toRad(lat1);
    final radLat2 = _toRad(lat2);

    final y = math.sin(dLng) * math.cos(radLat2);
    final x = math.cos(radLat1) * math.sin(radLat2) -
        math.sin(radLat1) * math.cos(radLat2) * math.cos(dLng);

    final bearing = _toDeg(math.atan2(y, x));
    return (bearing + 360) % 360;
  }

  /// Haversine great-circle distance in km.
  double _haversine(double lat1, double lng1, double lat2, double lng2) {
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);

    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.pow(math.sin(dLng / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return _earthRadiusKm * c;
  }
}
