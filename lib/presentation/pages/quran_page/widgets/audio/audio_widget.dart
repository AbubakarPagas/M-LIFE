part of '../../quran.dart';

class AudioWidget extends StatelessWidget {
  AudioWidget({Key? key}) : super(key: key);

  final quranCtrl = QuranController.instance;
  final audioCtrl = AudioCtrl.instance;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Obx(
        () => AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: quranCtrl.state.isPlayExpanded.value
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          // ── Collapsed: single row ──────────────────────────────────────
          firstChild: _CollapsedPlayer(audioCtrl: audioCtrl),
          // ── Expanded: full player ──────────────────────────────────────
          secondChild: _ExpandedPlayer(
            quranCtrl: quranCtrl,
            audioCtrl: audioCtrl,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Collapsed — play button + reader info in one row
// ─────────────────────────────────────────────────────────────────────────────

class _CollapsedPlayer extends StatelessWidget {
  const _CollapsedPlayer({required this.audioCtrl});
  final AudioCtrl audioCtrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 58,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // Play / Pause button
            _PlayPauseButton(size: 38, audioCtrl: audioCtrl),

            const SizedBox(width: 10),

            // Thin vertical divider
            Container(
              width: 1,
              height: 26,
              color: cs.primary.withValues(alpha: .20),
            ),

            const SizedBox(width: 10),

            // Reader + surah info
            Expanded(
              child: AyahChangeReader(
                downloadManagerStyle: audioCtrl.ayahDownloadManagerStyle,
                style: audioCtrl.ayahAudioStyle,
                isDark: themeCtrl.isDarkMode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Expanded — seek bar + controls
// ─────────────────────────────────────────────────────────────────────────────

class _ExpandedPlayer extends StatelessWidget {
  const _ExpandedPlayer({
    required this.quranCtrl,
    required this.audioCtrl,
  });

  final QuranController quranCtrl;
  final AudioCtrl audioCtrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GetBuilder<AudioCtrl>(
      id: 'audio_seekBar_id',
      builder: (c) => SizedBox(
        height: 170,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 6),

            // ── Collapse handle ──────────────────────────────────────────
            GestureDetector(
              onTap: () => quranCtrl.state.isPlayExpanded.value = false,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Center(
                  child: Container(
                    width: 36,
                    height: 3,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: .25),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // ── Reader info ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AyahChangeReader(
                downloadManagerStyle: audioCtrl.ayahDownloadManagerStyle,
                style: audioCtrl.ayahAudioStyle,
                isDark: themeCtrl.isDarkMode,
              ),
            ),

            const SizedBox(height: 4),

            // ── Seek bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Obx(
                  () => c.state.isDownloading.value
                      ? Obx(
                          () => SliderWidget.downloading(
                            currentPosition: audioCtrl
                                .state
                                .downloadProgress
                                .value
                                .toInt(),
                            filesCount: audioCtrl.state.fileSize.value,
                            horizontalPadding: 0,
                          ),
                        )
                      : StreamBuilder<PackagePositionData>(
                          stream: audioCtrl.positionDataStream,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(height: 20);
                            }
                            final pos = snapshot.data!;
                            return SliderWidget.player(
                              horizontalPadding: 0,
                              duration: pos.duration ?? Duration.zero,
                              position: pos.position ?? Duration.zero,
                              activeTrackColor:
                                  Theme.of(context).colorScheme.primary,
                              onChangeEnd: audioCtrl
                                  .state
                                  .audioPlayer
                                  .seek,
                            );
                          },
                        ),
                ),
              ),
            ),

            // ── Playback controls ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip previous
                  _ControlButton(
                    icon: Icons.skip_next_rounded, // RTL: skip_next = previous
                    size: 28,
                    color: cs.primary.withValues(alpha: .85),
                    onTap: () async {
                      final isRTL = Get.locale?.languageCode == 'ar';
                      isRTL
                          ? await audioCtrl.skipPreviousAyah(
                              Get.context!,
                              audioCtrl.currentAyah.ayahUQNumber,
                            )
                          : await audioCtrl.skipNextAyah(
                              Get.context!,
                              audioCtrl.currentAyah.ayahUQNumber,
                            );
                    },
                  ),

                  // Play / Pause (larger)
                  _PlayPauseButton(size: 46, audioCtrl: audioCtrl),

                  // Skip next
                  _ControlButton(
                    icon: Icons.skip_previous_rounded,
                    size: 28,
                    color: cs.primary.withValues(alpha: .85),
                    onTap: () async {
                      final isRTL = Get.locale?.languageCode == 'ar';
                      isRTL
                          ? await audioCtrl.skipNextAyah(
                              Get.context!,
                              audioCtrl.currentAyah.ayahUQNumber,
                            )
                          : await audioCtrl.skipPreviousAyah(
                              Get.context!,
                              audioCtrl.currentAyah.ayahUQNumber,
                            );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared play/pause button — works in both collapsed and expanded states
// ─────────────────────────────────────────────────────────────────────────────

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.size, required this.audioCtrl});
  final double size;
  final AudioCtrl audioCtrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return StreamBuilder<PlayerState>(
      stream: audioCtrl.state.audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final processing = state?.processingState;
        final isLoading =
            processing == ProcessingState.loading ||
            processing == ProcessingState.buffering ||
            (audioCtrl.state.isDownloading.value &&
                audioCtrl.state.progress.value == 0);

        // Loading spinner
        if (isLoading) {
          return SizedBox(
            width: size,
            height: size,
            child: Padding(
              padding: EdgeInsets.all(size * .22),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cs.primary,
              ),
            ),
          );
        }

        final isPlaying = state != null && state.playing;
        final svgPath = isPlaying
            ? SvgPath.svgAudioPauseArrow
            : SvgPath.svgAudioPlayArrow;

        return GestureDetector(
          onTap: () {
            if (isPlaying) {
              QuranController.instance.state.isPlayExpanded.value = true;
              audioCtrl.pausePlayer();
            } else {
              GeneralController.instance.showAudioWidgetFor();
              QuranController.instance.state.selectedAyahIndexes.isNotEmpty
                  ? audioCtrl.state.isDirectPlaying.value = false
                  : audioCtrl.state.isDirectPlaying.value = true;
              QuranController.instance.state.isPlayExpanded.value = true;
              QuranLibrary().playAyah(
                context: context,
                currentAyahUniqueNumber: audioCtrl.currentAyah.ayahUQNumber,
                playSingleAyah: true,
              );
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primary,
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: .30),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                svgPath,
                height: size * .50,
                width: size * .50,
                colorFilter: ColorFilter.mode(
                  cs.surface,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Generic icon tap button for skip controls
// ─────────────────────────────────────────────────────────────────────────────

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.size,
    required this.color,
    required this.onTap,
    this.label = '',
  });

  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: size),
        ),
      ),
    );
  }
}
