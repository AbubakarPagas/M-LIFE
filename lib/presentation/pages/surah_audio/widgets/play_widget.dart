part of '../surah_audio.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Expanded player — full card with reciter avatar, name, surah, seek + controls
// ─────────────────────────────────────────────────────────────────────────────

class PlayWidget extends StatelessWidget {
  const PlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = AudioCtrl.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──────────────────────────────────────────────
          GestureDetector(
            onTap: () => ctrl.surahState.isPlayExpanded.value = false,
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.30),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Reciter avatar + name + surah ────────────────────────────
          Obx(() {
            final reciterId = currentReciterIdObs.value;
            final meta = _metaFor(reciterId);
            final surahNum = ctrl.state.currentAudioListSurahNum.value
                .toString();

            return Column(
              children: [
                // Reciter avatar — large with ring
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow ring
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20),
                          width: 2,
                        ),
                      ),
                    ),
                    // Avatar
                    _ReciterAvatar(reciterId: reciterId, size: 68),
                  ],
                ),

                const SizedBox(height: 12),

                // Reciter name — tappable to change reader
                GestureDetector(
                  onTap: () async {
                    // SurahChangeSurahReader handles the dialog internally.
                    // We just wait for it to close then refresh the observable.
                    await Future.delayed(const Duration(milliseconds: 600));
                    ctrl.refreshCurrentReciter();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        meta.displayName,
                        style: const TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withValues(alpha: 0.60),
                        size: 16,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Surah name — large layered SVG
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: 0.07,
                      child: surahNameWidget(
                        surahNum,
                        Colors.white,
                        height: 76,
                        width: 176,
                      ),
                    ),
                    surahNameWidget(
                      surahNum,
                      Colors.white,
                      height: 52,
                      width: 154,
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Full-screen player shortcut — small icon below surah name
                GestureDetector(
                  onTap: () => Get.to(
                    () => const AudioSurahWithAyahs(),
                    transition: Transition.fadeIn,
                    binding: BindingsBuilder(() {
                      Get.put(AudioSurahWithAyahsController());
                    }),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.open_in_full_rounded,
                          color: Colors.white.withValues(alpha: 0.80),
                          size: 12,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'fullPlayer'.tr.isEmpty
                              ? 'المشغّل الكامل'
                              : 'fullPlayer'.tr,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.80),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Hidden SurahChangeSurahReader for actual reader-change logic
                // (keeps quran_library state in sync) — rendered at 0 opacity
                // so its internal tap/dialog still works when the name row above
                // is tapped indirectly via the player card.
                SizedBox(
                  height: 0,
                  child: Opacity(
                    opacity: 0,
                    child: SurahChangeSurahReader(
                      style: ctrl.surahAudioStyle,
                      isDark: isDark,
                    ),
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 18),

          // ── Seek bar ────────────────────────────────────────────────
          const SurahSeekBar(),

          const SizedBox(height: 14),

          // ── Controls row ─────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PlayerIconBtn(
                icon: Icons.replay_5_rounded,
                size: 20,
                onTap: () => ctrl.state.audioPlayer.seek(
                  Duration(
                    seconds: (ctrl.state.seekNextSeconds.value -= 5).clamp(
                      0,
                      999999,
                    ),
                  ),
                ),
              ),
              SurahSkipToPrevious(
                style: ctrl.surahAudioStyle,
                languageCode: Get.locale!.languageCode,
              ),
              const OnlinePlayButton(isRepeat: true),
              SurahSkipToNext(
                style: ctrl.surahAudioStyle,
                languageCode: Get.locale!.languageCode,
              ),
              _PlayerIconBtn(
                icon: Icons.forward_5_rounded,
                size: 20,
                onTap: () => ctrl.state.audioPlayer.seek(
                  Duration(seconds: ctrl.state.seekNextSeconds.value += 5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small icon button inside the player controls row
// ─────────────────────────────────────────────────────────────────────────────

class _PlayerIconBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _PlayerIconBtn({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }
}
