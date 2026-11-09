import 'dart:async';
import 'dart:developer';
import 'dart:ui' show Color;

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QuranAudioHandler
//
// A clean AudioHandler that wraps the app's shared just_audio AudioPlayer
// (owned by quran_library's AudioCtrl).  Provides:
//
//  • Media notification with surah name, reciter, album art, seek progress
//  • Lock-screen controls (play, pause, prev, next, seek)
//  • Bluetooth / headset button support
//  • Android Auto compatibility
//  • Repeat and Shuffle mode bridging (UI ↔ OS)
//  • Playback state stream that keeps notification in sync automatically
//
// Usage
// ─────
//   1. Call QuranAudioHandler.register() in main() — this calls
//      AudioService.init() and stores the returned handler as the singleton.
//   2. Call QuranAudioHandler.instance.updateTrack(...) each time a surah
//      starts playing — the notification updates automatically.
// ─────────────────────────────────────────────────────────────────────────────

class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static QuranAudioHandler? _instance;

  static QuranAudioHandler get instance {
    assert(
      _instance != null,
      'QuranAudioHandler.register() must be called before accessing .instance',
    );
    return _instance!;
  }

  static bool get isInitialized => _instance != null;

  // The underlying just_audio player — shared with quran_library's AudioCtrl.
  // Assigned lazily on first playback via [attachPlayer].
  AudioPlayer? _player;

  // Stream subscriptions kept so they can be cancelled on dispose.
  final List<StreamSubscription<dynamic>> _subs = [];

  // ── Constructor ────────────────────────────────────────────────────────────
  QuranAudioHandler._();

  // ── Registration — call once in main() ────────────────────────────────────

  /// Registers the handler with audio_service and stores it as the singleton.
  ///
  /// Must be awaited in main() before runApp().
  static Future<QuranAudioHandler> register() async {
    if (_instance != null) return _instance!;

    final handler = await AudioService.init(
      builder: () => QuranAudioHandler._(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.mishab.quran.audio',
        androidNotificationChannelName: 'القرآن الكريم',
        androidNotificationIcon: 'drawable/ic_notify',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: true,
        notificationColor: Color(0xFF1B5E20), // Islamic green
        androidNotificationClickStartsActivity: true,
        rewindInterval: Duration(seconds: 10),
        fastForwardInterval: Duration(seconds: 10),
        preloadArtwork: false,
      ),
    );

    _instance = handler;
    log(
      'QuranAudioHandler registered via AudioService.init()',
      name: 'QuranAudioHandler',
    );
    return handler;
  }

  // ── Lazy player attachment — called on first playback ─────────────────────

  /// Wire the [player] to this handler.  Idempotent — safe to call again
  /// with the same player (no-op) or to re-attach after a restart.
  void attachPlayer(AudioPlayer player) {
    if (_player == player) return; // already wired — nothing to do
    _cancelSubs();
    _player = player;
    _bridgePlayerStreams();
    log('AudioPlayer attached to QuranAudioHandler', name: 'QuranAudioHandler');
  }

  // ── Track metadata ────────────────────────────────────────────────────────

  /// Push a new [MediaItem] to the notification whenever a surah changes.
  ///
  /// - [surahNumber]      1-based (1–114)
  /// - [surahArabicName]  e.g. "الفاتحة"
  /// - [reciterName]      e.g. "مشاري راشد العفاسي"
  /// - [artUri]           optional album artwork URI
  Future<void> updateTrack({
    required int surahNumber,
    required String surahArabicName,
    required String reciterName,
    Uri? artUri,
  }) async {
    final surahNumStr = surahNumber.toString().padLeft(3, '0');

    final item = MediaItem(
      id: 'quran_surah_$surahNumber',
      title: 'سورة $surahArabicName',
      artist: reciterName,
      album: 'القرآن الكريم',
      displayTitle: 'سورة $surahArabicName',
      displaySubtitle: reciterName,
      displayDescription: 'سورة رقم $surahNumStr • القرآن الكريم',
      artUri:
          artUri ??
          Uri.parse('android.resource://com.misbah/mipmap/ic_launcher'),
      // Duration is filled in automatically via the durationStream listener.
      duration: _player?.duration,
      extras: const {'source': 'quran_audio'},
    );

    mediaItem.add(item);

    log(
      'MediaItem updated: surah $surahNumber — $surahArabicName — $reciterName',
      name: 'QuranAudioHandler',
    );
  }

  // ── AudioHandler overrides — called by OS / notification buttons ──────────

  @override
  Future<void> play() async => _player?.play();

  @override
  Future<void> pause() async => _player?.pause();

  @override
  Future<void> stop() async {
    await _player?.stop();
    // Emit idle state so the notification is dismissed.
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
  }

  @override
  Future<void> seek(Duration position) async => _player?.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_player?.hasNext ?? false) await _player?.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player?.hasPrevious ?? false) await _player?.seekToPrevious();
  }

  @override
  Future<void> fastForward() async {
    if (_player == null) return;
    await _player!.seek(_player!.position + const Duration(seconds: 10));
  }

  @override
  Future<void> rewind() async {
    if (_player == null) return;
    final newPos = _player!.position - const Duration(seconds: 10);
    await _player!.seek(newPos < Duration.zero ? Duration.zero : newPos);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    await _player?.setLoopMode(_toLoopMode(repeatMode));
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    await _player?.setShuffleModeEnabled(
      shuffleMode != AudioServiceShuffleMode.none,
    );
  }

  @override
  Future<void> onTaskRemoved() => stop();

  // ── Stream bridge — player events → PlaybackState ─────────────────────────

  void _bridgePlayerStreams() {
    final p = _player;
    if (p == null) return;

    // Player state (playing / paused / buffering / completed).
    _subs.add(
      p.playerStateStream.listen(
        (_) => _pushPlaybackState(),
        onError: (Object e) =>
            log('playerStateStream error: $e', name: 'QuranAudioHandler'),
      ),
    );

    // Position — drives the seek bar in the notification.
    _subs.add(
      p.positionStream.listen(
        (_) => _pushPlaybackState(),
        onError: (Object e) =>
            log('positionStream error: $e', name: 'QuranAudioHandler'),
      ),
    );

    // Duration — update MediaItem once the track is loaded.
    _subs.add(
      p.durationStream.listen((duration) {
        if (duration == null) return;
        final current = mediaItem.value;
        if (current != null) {
          mediaItem.add(current.copyWith(duration: duration));
        }
      }),
    );

    // Loop mode — keep repeat button in notification in sync.
    _subs.add(
      p.loopModeStream.listen((loopMode) {
        playbackState.add(
          playbackState.value.copyWith(repeatMode: _fromLoopMode(loopMode)),
        );
      }),
    );

    // Shuffle mode — keep shuffle button in notification in sync.
    _subs.add(
      p.shuffleModeEnabledStream.listen((enabled) {
        playbackState.add(
          playbackState.value.copyWith(
            shuffleMode: enabled
                ? AudioServiceShuffleMode.all
                : AudioServiceShuffleMode.none,
          ),
        );
      }),
    );
  }

  void _pushPlaybackState() {
    final p = _player;
    if (p == null) return;
    final ps = p.playerState;
    playbackState.add(
      PlaybackState(
        controls: _controls(ps),
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        // Indices into [controls] for compact notification view:
        // [0]=skipToPrevious  [1]=play/pause  [2]=skipToNext
        androidCompactActionIndices: const [0, 1, 2],
        processingState: _toAudioProcessingState(ps.processingState),
        playing: ps.playing,
        updatePosition: p.position,
        bufferedPosition: p.bufferedPosition,
        speed: p.speed,
        repeatMode: _fromLoopMode(p.loopMode),
        shuffleMode: p.shuffleModeEnabled
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
      ),
    );
  }

  List<MediaControl> _controls(PlayerState ps) => [
    MediaControl.skipToPrevious,
    ps.playing ? MediaControl.pause : MediaControl.play,
    MediaControl.skipToNext,
    MediaControl.stop,
  ];

  // ── Mapping helpers ────────────────────────────────────────────────────────

  AudioProcessingState _toAudioProcessingState(ProcessingState ps) {
    switch (ps) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  LoopMode _toLoopMode(AudioServiceRepeatMode mode) {
    switch (mode) {
      case AudioServiceRepeatMode.none:
        return LoopMode.off;
      case AudioServiceRepeatMode.one:
        return LoopMode.one;
      case AudioServiceRepeatMode.group:
      case AudioServiceRepeatMode.all:
        return LoopMode.all;
    }
  }

  AudioServiceRepeatMode _fromLoopMode(LoopMode mode) {
    switch (mode) {
      case LoopMode.off:
        return AudioServiceRepeatMode.none;
      case LoopMode.one:
        return AudioServiceRepeatMode.one;
      case LoopMode.all:
        return AudioServiceRepeatMode.all;
    }
  }

  // ── Dispose ────────────────────────────────────────────────────────────────

  void _cancelSubs() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
  }

  /// Cancel all stream subscriptions.  Call when the app is fully closing.
  void dispose() {
    _cancelSubs();
  }
}
