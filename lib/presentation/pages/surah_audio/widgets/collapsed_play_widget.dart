part of '../surah_audio.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Collapsed player — compact bar with reciter avatar + surah name + controls
// ─────────────────────────────────────────────────────────────────────────────

class CollapsedPlayWidget extends StatelessWidget {
  const CollapsedPlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = AudioCtrl.instance;

    return SizedBox(
      height: 76,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // ── Reciter avatar (reactive to reader changes) ──────────
            Obx(() {
              final reciterId = currentReciterIdObs.value;
              return _ReciterAvatar(reciterId: reciterId, size: 42);
            }),

            const SizedBox(width: 10),

            // ── Surah name + reciter name ────────────────────────────
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Surah name SVG
                  Obx(
                    () => surahNameWidget(
                      ctrl.state.currentAudioListSurahNum.value.toString(),
                      Colors.white,
                      height: 28,
                      width: 100,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Reciter name
                  Obx(() {
                    final reciterId = currentReciterIdObs.value;
                    final meta = _metaFor(reciterId);
                    return Text(
                      meta.displayName,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                    );
                  }),
                ],
              ),
            ),

            // ── Visualizer when playing ──────────────────────────────
            Obx(
              () => ctrl.state.isPlaying.value
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: MiniMusicVisualizer(
                        color: Colors.white.withValues(alpha: 0.70),
                        width: 2.5,
                        height: 14,
                        animate: true,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // ── Playback controls ────────────────────────────────────
            SurahSkipToPrevious(
              style: ctrl.surahAudioStyle,
              languageCode: Get.locale!.languageCode,
            ),
            const OnlinePlayButton(isRepeat: false),
            SurahSkipToNext(
              style: ctrl.surahAudioStyle,
              languageCode: Get.locale!.languageCode,
            ),

            const SizedBox(width: 4),

            // ── Expand chevron ───────────────────────────────────────
            GestureDetector(
              onTap: () => ctrl.surahState.isPlayExpanded.value = true,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: Colors.white.withValues(alpha: 0.80),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
