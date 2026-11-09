part of '../../quran.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Floating Islamic audio player card – shown at the bottom of QuranHome.
///
/// Visual anatomy:
/// ┌──────────────────────────────────────────────────────────────────────┐
/// │  ╔══ decorative svgSurahBanner1 watermark (faint, top-right)  ══╗   │
/// │  ║  [Surah SVG name artwork]        [ayah badge]                ║   │
/// │  ║  🎙 Reciter name                                             ║   │
/// │  ╠══════════════════════════════════════════════════════════════╣   │
/// │  ║  ⏮   ⏮10s   ▶   ⏭10s   ⏭    🎧  🖥  📄                    ║   │
/// │  ╚══════════════════════════════════════════════════════════════╝   │
/// └──────────────────────────────────────────────────────────────────────┘
/// ─────────────────────────────────────────────────────────────────────────────
class AudioWidget extends StatelessWidget {
  AudioWidget({Key? key}) : super(key: key);

  final quranCtrl = QuranController.instance;
  final audioCtrl = AudioCtrl.instance;

  // ── gold accent used for highlights ──────────────────────────────────────
  static const Color _gold = Color(0xFFD4A435);
  static const Color _goldLight = Color(0xFFF0C96A);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: cs.primaryContainer,
          ),
          child: Stack(
            children: [
              // ── Decorative banner watermark (top-right, very faint) ────────
              Positioned(
                top: -10,
                right: -10,
                child: Opacity(
                  opacity: 0.07,
                  child: SvgPicture.asset(
                    SvgPath.svgSurahBanner1,
                    width: 150,
                    colorFilter: const ColorFilter.mode(
                      _goldLight,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),

              // ── Main content ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Row 1: Surah info ────────────────────────────────────
                    const _SurahInfoRow(gold: _gold, goldLight: _goldLight),

                    const SizedBox(height: 8),

                    // ── Gold divider line ────────────────────────────────────
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            _gold.withValues(alpha: 0.45),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Row 2: Controls + action icons ───────────────────────
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _PlaybackControls(gold: _gold),
                        _ActionButtons(gold: _gold),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Row 1: Surah SVG name artwork + ayah badge  +  reciter info
// ─────────────────────────────────────────────────────────────────────────────
class _SurahInfoRow extends StatelessWidget {
  const _SurahInfoRow({required this.gold, required this.goldLight});
  final Color gold;
  final Color goldLight;

  @override
  Widget build(BuildContext context) {
    final audioCtrl = AudioCtrl.instance;
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      final uqNum = audioCtrl.state.currentAyahUniqueNumber.value;

      // ── Surah number & ayah number ─────────────────────────────────────────
      int surahNum = 1;
      int ayahNum = 0;
      String readerName = '';

      try {
        final surahData = QuranController.instance.getSurahDataByAyahUQ(uqNum);
        surahNum = surahData.surahNumber;
        final startUQ = surahData.ayahs.first.ayahUQNumber;
        ayahNum = uqNum - startUQ + 1;
      } catch (_) {}

      final readers = ReadersConstants.activeAyahReaders;
      final readerIdx = audioCtrl.state.ayahReaderIndex.value.clamp(
        0,
        readers.length - 1,
      );
      readerName = readers[readerIdx].name;

      // Pad to 3 digits for surah SVG path
      final surahKey = surahNum.toString().padLeft(3, '0');
      final surahSvgPath = 'assets/svg/surah_name/$surahKey.svg';

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Reciter avatar ─────────────────────────────────────────────────
          _ReciterAvatar(gold: gold),

          const SizedBox(width: 10),

          // ── Surah SVG name + reciter ───────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Surah calligraphic name from SVG asset
                SvgPicture.asset(
                  surahSvgPath,
                  height: 26,
                  colorFilter: ColorFilter.mode(cs.onPrimary, BlendMode.srcIn),
                  placeholderBuilder: (_) => Text(
                    '───',
                    style: TextStyle(
                      color: cs.onPrimary.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Reciter name with mic icon
                Row(
                  children: [
                    Icon(
                      Icons.mic_rounded,
                      size: 15,
                      color: gold.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        readerName.isNotEmpty ? readerName : '---',
                        style: TextStyle(
                          color: cs.onPrimary.withValues(alpha: 0.75),
                          fontFamily: 'kufi',
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Ayah badge ─────────────────────────────────────────────────────
          if (ayahNum > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: gold.withValues(alpha: 0.55),
                  width: 1,
                ),
                color: gold.withValues(alpha: 0.10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'آية',
                    style: TextStyle(
                      color: gold,
                      fontFamily: 'kufi',
                      fontSize: 8,
                    ),
                  ),
                  Text(
                    '$ayahNum',
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontFamily: 'kufi',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reciter circular avatar
// ─────────────────────────────────────────────────────────────────────────────
class _ReciterAvatar extends StatelessWidget {
  const _ReciterAvatar({required this.gold});
  final Color gold;

  @override
  Widget build(BuildContext context) {
    final audioCtrl = AudioCtrl.instance;
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      return Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gold.withValues(alpha: 0.65),
              gold.withValues(alpha: 0.30),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: gold.withValues(alpha: 0.30),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.5),
          child: ClipOval(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary,
              ),
              child: Image.network(
                audioCtrl.state.appIconUrl.value,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: SvgPicture.asset(
                    SvgPath.svgAlert,
                    colorFilter: ColorFilter.mode(
                      cs.onPrimary.withValues(alpha: 0.8),
                      BlendMode.srcIn,
                    ),
                    width: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Playback controls: ⏮  ▶/⏸  ⏭
// ─────────────────────────────────────────────────────────────────────────────
class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({required this.gold});
  final Color gold;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final audioCtrl = AudioCtrl.instance;
    final isRTL = Get.locale?.languageCode == 'ar';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Previous ────────────────────────────────────────────────────────
        _NavBtn(
          icon: Icons.skip_previous_rounded,
          size: 26,
          color: cs.onPrimary.withValues(alpha: 0.85),
          semanticLabel: 'skipToPrevious'.tr,
          onTap: () async {
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

        const SizedBox(width: 6),

        // ── Play / Pause ─────────────────────────────────────────────────────
        StreamBuilder<PlayerState>(
          stream: audioCtrl.state.audioPlayer.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final isLoadingOrBuffering =
                processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering ||
                (audioCtrl.state.isDownloading.value &&
                    audioCtrl.state.progress.value == 0);

            if (isLoadingOrBuffering) {
              return SizedBox(
                width: 48,
                height: 48,
                child: Padding(
                  padding: const EdgeInsets.all(11),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: gold,
                  ),
                ),
              );
            }

            final isPlaying = playerState != null && playerState.playing;

            return GestureDetector(
              onTap: () async {
                if (isPlaying) {
                  audioCtrl.pausePlayer();
                } else {
                  GeneralController.instance.showAudioWidgetFor();
                  QuranController.instance.state.selectedAyahIndexes.isNotEmpty
                      ? audioCtrl.state.isDirectPlaying.value = false
                      : audioCtrl.state.isDirectPlaying.value = true;
                  audioCtrl.playAyah(
                    context,
                    audioCtrl.currentAyah.ayahUQNumber,
                    playSingleAyah: true,
                  );
                }
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [gold, Color.lerp(gold, Colors.orange, 0.35)!],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withValues(alpha: 0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 6),

        // ── Next ─────────────────────────────────────────────────────────────
        _NavBtn(
          icon: Icons.skip_next_rounded,
          size: 26,
          color: cs.onPrimary.withValues(alpha: 0.85),
          semanticLabel: 'next'.tr,
          onTap: () async {
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action icon buttons: Audio / Display / Page
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.gold});
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionBtn(
          icon: Icons.headphones_rounded,
          label: 'audio'.tr,
          gold: gold,
          onTap: () => Get.bottomSheet(
            AudioSettingsSheet(),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
          ),
        ),
        const SizedBox(width: 6),
        _ActionBtn(
          icon: Icons.display_settings_outlined,
          label: 'display'.tr,
          gold: gold,
          onTap: () => Get.bottomSheet(
            const DisplaySettingsSheet(),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
          ),
        ),
        const SizedBox(width: 6),
        _ActionBtn(
          icon: Icons.menu_book_rounded,
          label: 'page'.tr,
          gold: gold,
          onTap: () {
           /*  final quranCtrl = QuranController.instance;
            quranCtrl.state.isPages.value = quranCtrl.state.isPages.value == 1
                ? 0
                : 1;
            quranCtrl.state.box.write(
              SWITCH_VALUE,
              quranCtrl.state.isPages.value,
            ); */
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small prev/next navigation icon button
// ─────────────────────────────────────────────────────────────────────────────
class _NavBtn extends StatelessWidget {
  const _NavBtn({
    required this.icon,
    required this.onTap,
    required this.color,
    this.size = 28,
    this.semanticLabel = '',
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double size;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings action icon column (icon + label)
// ─────────────────────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.gold,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color gold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: cs.primaryContainer.withValues(alpha: 0.07),
          border: Border.all(color: gold.withValues(alpha: 0.20), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: cs.onPrimary.withValues(alpha: 0.90), size: 30),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: cs.onPrimary.withValues(alpha: 0.70),
                fontSize: 8,
                fontFamily: 'kufi',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
