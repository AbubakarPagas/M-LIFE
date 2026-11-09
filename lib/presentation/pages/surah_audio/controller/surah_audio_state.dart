part of '../surah_audio.dart';

class SurahAudioState {
  // Singleton pattern
  static final SurahAudioState _instance = SurahAudioState._internal();
  factory SurahAudioState() => _instance;
  SurahAudioState._internal();

  /// -------- [Variables] ----------
  ArabicNumbers arabicNumber = ArabicNumbers();

  TextEditingController srchTxtCntroler = TextEditingController();
  late ItemScrollController surahsScrollController = ItemScrollController();
  final box = GetStorage();

  // For controlling successful page display after app loading
  RxBool surahReadersLoaded = false.obs;
  RxBool isPlayExpanded = false.obs;

  TextEditingController textController = TextEditingController();

  // ── Segment tracking state ────────────────────────────────────────────────

  /// Current ayah number derived from segment timing data
  Rx<int?> currentSegmentAyahNumber = Rx<int?>(null);

  /// Current word index within the ayah (0-based)
  Rx<int?> currentSegmentWordIndex = Rx<int?>(null);

  /// Current surah number as seen by the segment tracker
  Rx<int?> currentSegmentSurahNumber = Rx<int?>(null);

  /// Whether segment data is being loaded from disk/network
  RxBool isSegmentsLoading = false.obs;

  /// Whether the current reader has segment data available
  RxBool isSegmentsAvailable = false.obs;

  /// Position stream subscription (cancelled when the full-screen player closes)
  StreamSubscription<Duration>? segmentPositionSubscription;
}
