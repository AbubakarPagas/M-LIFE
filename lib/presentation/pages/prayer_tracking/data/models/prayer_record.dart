/// Domain model for a single day's prayer record.
/// Stored as a Drift row; this plain Dart class is the domain/transfer layer.
library prayer_record;

/// Status of an individual prayer for a given day.
enum PrayerStatus {
  pending, // Not yet marked
  completed, // Prayed on time
  late, // Prayed but late
  missed, // Intentionally skipped
  congregation, // Prayed in congregation (Jama'ah)
  mosque, // At the mosque
  home, // At home
}

extension PrayerStatusX on PrayerStatus {
  String get label {
    return switch (this) {
      PrayerStatus.pending => 'Pending',
      PrayerStatus.completed => 'Completed',
      PrayerStatus.late => 'Late',
      PrayerStatus.missed => 'Missed',
      PrayerStatus.congregation => "Jama'ah",
      PrayerStatus.mosque => 'At Mosque',
      PrayerStatus.home => 'At Home',
    };
  }

  String get emoji {
    return switch (this) {
      PrayerStatus.pending => '⏳',
      PrayerStatus.completed => '✅',
      PrayerStatus.late => '⚠️',
      PrayerStatus.missed => '❌',
      PrayerStatus.congregation => '🕌',
      PrayerStatus.mosque => '🕌',
      PrayerStatus.home => '🏠',
    };
  }

  bool get countsAsCompleted =>
      this == PrayerStatus.completed ||
      this == PrayerStatus.late ||
      this == PrayerStatus.congregation ||
      this == PrayerStatus.mosque ||
      this == PrayerStatus.home;

  /// Serialise to string for storage
  String toStorageString() => name;

  static PrayerStatus fromStorageString(String? s) {
    if (s == null) return PrayerStatus.pending;
    try {
      return PrayerStatus.values.firstWhere((e) => e.name == s);
    } catch (_) {
      return PrayerStatus.pending;
    }
  }
}

/// Immutable record for one day's five obligatory prayers.
class PrayerRecord {
  /// ISO date string "yyyy-MM-dd"
  final String date;

  final PrayerStatus fajr;
  final PrayerStatus dhuhr;
  final PrayerStatus asr;
  final PrayerStatus maghrib;
  final PrayerStatus isha;

  /// Optional timestamps (ISO 8601) for when each prayer was marked
  final String? fajrTimestamp;
  final String? dhuhrTimestamp;
  final String? asrTimestamp;
  final String? maghribTimestamp;
  final String? ishaTimestamp;

  const PrayerRecord({
    required this.date,
    this.fajr = PrayerStatus.pending,
    this.dhuhr = PrayerStatus.pending,
    this.asr = PrayerStatus.pending,
    this.maghrib = PrayerStatus.pending,
    this.isha = PrayerStatus.pending,
    this.fajrTimestamp,
    this.dhuhrTimestamp,
    this.asrTimestamp,
    this.maghribTimestamp,
    this.ishaTimestamp,
  });

  /// The 5 statuses as an ordered list: [Fajr, Dhuhr, Asr, Maghrib, Isha]
  List<PrayerStatus> get statuses => [fajr, dhuhr, asr, maghrib, isha];

  /// Names matching the statuses list
  static const List<String> prayerNames = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  int get completedCount => statuses.where((s) => s.countsAsCompleted).length;

  double get completionPercentage => (completedCount / 5) * 100;

  int get missedCount => statuses.where((s) => s == PrayerStatus.missed).length;

  /// Worship score 0–100 weighted by prayer quality
  int get worshipScore {
    int score = 0;
    for (final s in statuses) {
      score += switch (s) {
        PrayerStatus.completed => 20,
        PrayerStatus.congregation => 27, // congregation bonus
        PrayerStatus.mosque => 25,
        PrayerStatus.home => 18,
        PrayerStatus.late => 10,
        _ => 0,
      };
    }
    return score.clamp(0, 100);
  }

  PrayerRecord copyWith({
    PrayerStatus? fajr,
    PrayerStatus? dhuhr,
    PrayerStatus? asr,
    PrayerStatus? maghrib,
    PrayerStatus? isha,
    String? fajrTimestamp,
    String? dhuhrTimestamp,
    String? asrTimestamp,
    String? maghribTimestamp,
    String? ishaTimestamp,
  }) => PrayerRecord(
    date: date,
    fajr: fajr ?? this.fajr,
    dhuhr: dhuhr ?? this.dhuhr,
    asr: asr ?? this.asr,
    maghrib: maghrib ?? this.maghrib,
    isha: isha ?? this.isha,
    fajrTimestamp: fajrTimestamp ?? this.fajrTimestamp,
    dhuhrTimestamp: dhuhrTimestamp ?? this.dhuhrTimestamp,
    asrTimestamp: asrTimestamp ?? this.asrTimestamp,
    maghribTimestamp: maghribTimestamp ?? this.maghribTimestamp,
    ishaTimestamp: ishaTimestamp ?? this.ishaTimestamp,
  );

  /// Serialise to JSON-compatible map (for storage / export)
  Map<String, dynamic> toMap() => {
    'date': date,
    'fajr': fajr.toStorageString(),
    'dhuhr': dhuhr.toStorageString(),
    'asr': asr.toStorageString(),
    'maghrib': maghrib.toStorageString(),
    'isha': isha.toStorageString(),
    'completionPercentage': completionPercentage,
    'fajrTimestamp': fajrTimestamp,
    'dhuhrTimestamp': dhuhrTimestamp,
    'asrTimestamp': asrTimestamp,
    'maghribTimestamp': maghribTimestamp,
    'ishaTimestamp': ishaTimestamp,
  };

  factory PrayerRecord.fromMap(Map<String, dynamic> m) => PrayerRecord(
    date: m['date'] as String,
    fajr: PrayerStatusX.fromStorageString(m['fajr'] as String?),
    dhuhr: PrayerStatusX.fromStorageString(m['dhuhr'] as String?),
    asr: PrayerStatusX.fromStorageString(m['asr'] as String?),
    maghrib: PrayerStatusX.fromStorageString(m['maghrib'] as String?),
    isha: PrayerStatusX.fromStorageString(m['isha'] as String?),
    fajrTimestamp: m['fajrTimestamp'] as String?,
    dhuhrTimestamp: m['dhuhrTimestamp'] as String?,
    asrTimestamp: m['asrTimestamp'] as String?,
    maghribTimestamp: m['maghribTimestamp'] as String?,
    ishaTimestamp: m['ishaTimestamp'] as String?,
  );

  /// Returns today's dateKey
  static String get todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
