/// Represents the source of the stored location.
enum LocationMode {
  /// Live GPS fix obtained in the current session.
  live,

  /// Loaded from cache (GPS was unavailable but a prior fix exists).
  cached,

  /// User picked the location manually from a list.
  manual,
}

/// Full offline-capable location record.
class LocationInfo {
  final double latitude;
  final double longitude;

  /// Short display label (neighbourhood / area name).
  final String address;

  /// City / locality name.
  final String locality;

  /// State / province name (may be empty).
  final String state;

  /// Country name (may be empty).
  final String country;

  /// IANA timezone identifier, e.g. "Africa/Lagos".
  final String timezone;

  /// UTC offset string, e.g. "+01:00".
  final String utcOffset;

  final LocationMode mode;

  /// When this location was last successfully obtained.
  final DateTime lastUpdated;

  const LocationInfo({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.locality,
    this.state = '',
    this.country = '',
    this.timezone = '',
    this.utcOffset = '',
    this.mode = LocationMode.live,
    required this.lastUpdated,
  });

  // ── Backwards-compatible factory (used by legacy callers) ─────────────────
  factory LocationInfo.legacy(
    double latitude,
    double longitude,
    String address,
    String locality,
    LocationMode mode,
  ) => LocationInfo(
    latitude: latitude,
    longitude: longitude,
    address: address,
    locality: locality,
    mode: mode,
    lastUpdated: DateTime.now(),
  );

  LocationInfo copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? locality,
    String? state,
    String? country,
    String? timezone,
    String? utcOffset,
    LocationMode? mode,
    DateTime? lastUpdated,
  }) => LocationInfo(
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    address: address ?? this.address,
    locality: locality ?? this.locality,
    state: state ?? this.state,
    country: country ?? this.country,
    timezone: timezone ?? this.timezone,
    utcOffset: utcOffset ?? this.utcOffset,
    mode: mode ?? this.mode,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );

  LocationInfo copy() => copyWith();

  // ── Human-readable display helpers ────────────────────────────────────────

  /// "Lagos, Nigeria" — falls back to address if city/country empty.
  String get displayName {
    if (locality.isNotEmpty && country.isNotEmpty) {
      return '$locality, $country';
    }
    if (locality.isNotEmpty) return locality;
    if (country.isNotEmpty) return country;
    return address;
  }

  /// Source label shown in the UI.
  String get sourceLabel {
    switch (mode) {
      case LocationMode.live:
        return 'GPS Location';
      case LocationMode.cached:
        return 'Cached GPS Location';
      case LocationMode.manual:
        return 'Manual Selection';
    }
  }

  /// Whether this location can be used offline.
  bool get isOfflineAvailable => true; // always true once stored

  // ── Serialisation ─────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
    'lat': latitude,
    'lng': longitude,
    'address': address,
    'locality': locality,
    'state': state,
    'country': country,
    'timezone': timezone,
    'utcOffset': utcOffset,
    'mode': mode.name,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory LocationInfo.fromMap(Map<String, dynamic> m) => LocationInfo(
    latitude: (m['lat'] as num).toDouble(),
    longitude: (m['lng'] as num).toDouble(),
    address: m['address'] as String? ?? '',
    locality: m['locality'] as String? ?? '',
    state: m['state'] as String? ?? '',
    country: m['country'] as String? ?? '',
    timezone: m['timezone'] as String? ?? '',
    utcOffset: m['utcOffset'] as String? ?? '',
    mode: LocationMode.values.firstWhere(
      (e) => e.name == (m['mode'] as String? ?? 'cached'),
      orElse: () => LocationMode.cached,
    ),
    lastUpdated: m['lastUpdated'] != null
        ? DateTime.parse(m['lastUpdated'] as String)
        : DateTime.now(),
  );
}
