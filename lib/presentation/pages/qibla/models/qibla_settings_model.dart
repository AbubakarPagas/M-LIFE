// ── Qibla Settings Model ────────────────────────────────────────────────────
// Persisted user preferences for the Qibla feature.

/// Whether bearing is computed from magnetic north or true north.
enum NorthType { magnetic, trueNorth }

/// All user-configurable settings for the Qibla page.
class QiblaSettings {
  final NorthType northType;
  final bool vibrationEnabled;
  final bool soundEnabled;
  final bool autoRefresh;
  final double compassSensitivity; // 0.1 – 1.0

  const QiblaSettings({
    this.northType = NorthType.magnetic,
    this.vibrationEnabled = true,
    this.soundEnabled = false,
    this.autoRefresh = true,
    this.compassSensitivity = 0.5,
  });

  QiblaSettings copyWith({
    NorthType? northType,
    bool? vibrationEnabled,
    bool? soundEnabled,
    bool? autoRefresh,
    double? compassSensitivity,
  }) => QiblaSettings(
    northType: northType ?? this.northType,
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    autoRefresh: autoRefresh ?? this.autoRefresh,
    compassSensitivity: compassSensitivity ?? this.compassSensitivity,
  );

  Map<String, dynamic> toMap() => {
    'northType': northType.name,
    'vibrationEnabled': vibrationEnabled,
    'soundEnabled': soundEnabled,
    'autoRefresh': autoRefresh,
    'compassSensitivity': compassSensitivity,
  };

  factory QiblaSettings.fromMap(Map<String, dynamic> m) => QiblaSettings(
    northType: NorthType.values.firstWhere(
      (e) => e.name == (m['northType'] as String? ?? 'magnetic'),
      orElse: () => NorthType.magnetic,
    ),
    vibrationEnabled: m['vibrationEnabled'] as bool? ?? true,
    soundEnabled: m['soundEnabled'] as bool? ?? false,
    autoRefresh: m['autoRefresh'] as bool? ?? true,
    compassSensitivity:
        (m['compassSensitivity'] as num?)?.toDouble() ?? 0.5,
  );
}
