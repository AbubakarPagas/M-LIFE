/// نموذج بيانات توقيت آية واحدة ضمن ملف segments
class AyahSegmentModel {
  final int surahNumber;
  final int ayahNumber;
  final int timestampFrom;
  final int timestampTo;
  final int durationMs;

  /// توقيت الكلمات: كل عنصر [wordIndex, startMs, endMs]
  final List<List<int>> wordSegments;

  const AyahSegmentModel({
    required this.surahNumber,
    required this.ayahNumber,
    required this.timestampFrom,
    required this.timestampTo,
    required this.durationMs,
    required this.wordSegments,
  });

  factory AyahSegmentModel.fromJson(String key, Map<String, dynamic> json) {
    final parts = key.split(':');
    final surah = int.parse(parts[0]);
    final ayah = int.parse(parts[1]);

    final rawSegments = json['segments'] as List<dynamic>? ?? [];
    final wordSegments = rawSegments
        .map(
          (s) => (s as List<dynamic>).map((e) => (e as num).toInt()).toList(),
        )
        .toList();

    return AyahSegmentModel(
      surahNumber: surah,
      ayahNumber: ayah,
      timestampFrom: (json['timestamp_from'] as num).toInt(),
      timestampTo: (json['timestamp_to'] as num).toInt(),
      durationMs: (json['duration_ms'] as num).toInt(),
      wordSegments: wordSegments,
    );
  }

  int get firstWordStart =>
      wordSegments.isNotEmpty ? wordSegments.first[1] : timestampFrom;

  int get lastWordEnd =>
      wordSegments.isNotEmpty ? wordSegments.last[2] : timestampTo;

  int? getWordIndexAtPosition(int positionMs) {
    for (final seg in wordSegments) {
      if (positionMs >= seg[1] && positionMs < seg[2]) {
        return seg[0];
      }
    }
    return null;
  }
}

/// بيانات segments لسورة واحدة
class SurahSegmentsData {
  final int surahNumber;
  final Map<int, AyahSegmentModel> ayahs;

  const SurahSegmentsData({required this.surahNumber, required this.ayahs});

  int? getAyahNumberAtPosition(int positionMs) {
    for (final entry in ayahs.values) {
      if (positionMs >= entry.timestampFrom && positionMs < entry.timestampTo) {
        return entry.ayahNumber;
      }
    }
    return null;
  }
}
