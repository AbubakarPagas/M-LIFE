part of '../surah_audio.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SurahAudioSegmentHelper
//
// Extension on AudioCtrl that manages word/ayah-level position tracking using
// segment timing data.  Enabled while AudioSurahWithAyahs is open, disabled
// when it closes.
// ─────────────────────────────────────────────────────────────────────────────

extension SurahAudioSegmentHelper on AudioCtrl {
  SurahAudioState get _segState => SurahAudioState();

  // ── Initialization ────────────────────────────────────────────────────────

  /// Load segment data for the currently active reader.
  /// Sets [isSegmentsAvailable] to false when the reader has no data.
  Future<void> initSegmentsForCurrentReader() async {
    final readerIndex = state.surahReaderIndex.value;
    final repo = SegmentRepository.instance;

    if (!repo.hasSegments(readerIndex)) {
      _segState.isSegmentsAvailable.value = false;
      _segState.currentSegmentAyahNumber.value = null;
      _segState.currentSegmentSurahNumber.value = null;
      return;
    }

    _segState.isSegmentsAvailable.value = true;

    // Avoid reloading if already cached.
    if (repo.isLoaded(readerIndex)) return;

    _segState.isSegmentsLoading.value = true;
    await repo.preloadSegments(readerIndex);
    _segState.isSegmentsLoading.value = false;
  }

  // ── Tracking ──────────────────────────────────────────────────────────────

  /// Subscribe to the audio position stream and update the current
  /// ayah/word observables in real time.
  void enableSegmentTracking(int surahNumber) {
    disableSegmentTracking(); // cancel any existing subscription

    final readerIndex = state.surahReaderIndex.value;
    final repo = SegmentRepository.instance;

    if (!repo.hasSegments(readerIndex) || !repo.isLoaded(readerIndex)) return;

    _segState.currentSegmentSurahNumber.value = surahNumber;

    SurahSegmentsData? cachedSurahData;
    int? lastSurah;

    _segState.segmentPositionSubscription = state.audioPlayer.positionStream
        .listen((position) async {
          final currentSurah = state.currentAudioListSurahNum.value;
          final positionMs = position.inMilliseconds;

          if (cachedSurahData == null || lastSurah != currentSurah) {
            cachedSurahData = await repo.getSegmentsForSurah(
              readerIndex,
              currentSurah,
            );
            lastSurah = currentSurah;
            _segState.currentSegmentSurahNumber.value = currentSurah;
          }

          if (cachedSurahData == null) return;

          final ayahNum =
              cachedSurahData!.getAyahNumberAtPosition(positionMs);
          if (ayahNum != null) {
            if (ayahNum != _segState.currentSegmentAyahNumber.value) {
              _segState.currentSegmentAyahNumber.value = ayahNum;
            }
            final wordIdx = cachedSurahData!
                .ayahs[ayahNum]
                ?.getWordIndexAtPosition(positionMs);
            if (wordIdx != null &&
                wordIdx != _segState.currentSegmentWordIndex.value) {
              _segState.currentSegmentWordIndex.value = wordIdx;
            }
          }
        });
  }

  /// Cancel the position subscription.
  void disableSegmentTracking() {
    _segState.segmentPositionSubscription?.cancel();
    _segState.segmentPositionSubscription = null;
  }

  /// Call this when the surah changes mid-session (e.g. auto-advance).
  void updateSegmentSurah(int surahNumber) {
    _segState.currentSegmentSurahNumber.value = surahNumber;
    _segState.currentSegmentAyahNumber.value = null;
    _segState.currentSegmentWordIndex.value = null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AudioSurahWithAyahsController
//
// GetX controller scoped to AudioSurahWithAyahs.  Initialises segment
// tracking on open and cleans up on close.
// ─────────────────────────────────────────────────────────────────────────────

class AudioSurahWithAyahsController extends GetxController {
  final _surahCtrl = AudioCtrl.instance;
  final segState = SurahAudioState();

  @override
  void onInit() {
    super.onInit();
    _initSegments();
  }

  Future<void> _initSegments() async {
    await _surahCtrl.initSegmentsForCurrentReader();
    _surahCtrl.enableSegmentTracking(
      _surahCtrl.state.currentAudioListSurahNum.value,
    );
  }

  @override
  void onClose() {
    _surahCtrl.disableSegmentTracking();
    super.onClose();
  }
}
