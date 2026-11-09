/// Segment timing data constants for Quran audio recitation tracking.
/// Each reciter index maps to a URL hosting a gzipped JSON file
/// with word-level timing data (segments).
///
/// readerIndex matches the index used in [ReadersConstants.activeSurahReaders].
class SegmentConstants {
  SegmentConstants._();

  /// Directory name inside getApplicationDocumentsDirectory() for disk cache
  static const String cacheDir = 'quran_segments_cache';

  /// Reader indices that have segments data available
  static const Set<int> _readersWithSegments = {
    0, // عبد الباسط عبد الصمد
    2, // محمود خليل الحصري
    4, // ماهر المعيقلي
  };

  /// Segment file URLs indexed by readerIndex.
  /// These are gzipped JSON files hosted on a CDN.
  static const Map<int, String> _segmentUrls = {
    0: 'https://raw.githubusercontent.com/alheekmahlib/data/main/segments/abdulbasit.json.gz',
    2: 'https://raw.githubusercontent.com/alheekmahlib/data/main/segments/husary.json.gz',
    4: 'https://raw.githubusercontent.com/alheekmahlib/data/main/segments/muaiqly.json.gz',
  };

  /// Local cache file names indexed by readerIndex
  static const Map<int, String> _localFileNames = {
    0: 'abdulbasit_segments.json',
    2: 'husary_segments.json',
    4: 'muaiqly_segments.json',
  };

  /// Returns true if the given reader index has segment data
  static bool hasSegments(int readerIndex) =>
      _readersWithSegments.contains(readerIndex);

  /// Returns the remote URL for a reader's segment file, or null if unavailable
  static String? segmentUrl(int readerIndex) => _segmentUrls[readerIndex];

  /// Returns the local filename for caching, or null if not available
  static String? localFileName(int readerIndex) =>
      _localFileNames[readerIndex];
}
