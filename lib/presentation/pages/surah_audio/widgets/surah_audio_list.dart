part of '../surah_audio.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SurahAudioList
//
// 114-surah list.  Tap behaviour:
//   1. Sets the selected index (highlights the tile immediately).
//   2. If the surah is already downloaded → plays from local file.
//   3. Otherwise → streams online via quran_library.
//
// Selected + playing state is derived from AudioCtrl reactive observables so
// every tile rebuilds only when its own state changes (Obx per tile).
// ─────────────────────────────────────────────────────────────────────────────

class SurahAudioList extends StatelessWidget {
  SurahAudioList({super.key});

  final QuranController quranCtrl = QuranController.instance;
  final AudioCtrl surahAudioCtrl = AudioCtrl.instance;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      controller: surahAudioCtrl.state.surahListController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: quranCtrl.state.surahs.length,
      itemBuilder: (_, index) {
        final surah = quranCtrl.state.surahs[index];

        return Obx(() {
          // Re-evaluate selection and play state reactively.
          final isSelected =
              surahAudioCtrl.state.selectedSurahIndex.value == index;
          final isPlaying = isSelected && surahAudioCtrl.state.isPlaying.value;

          return _SurahTile(
            surah: surah,
            index: index,
            isSelected: isSelected,
            isPlaying: isPlaying,
            isDark: isDark,
            cs: cs,
            onTap: () => _onTap(context, index, surah),
          );
        });
      },
    );
  }

  Future<void> _onTap(BuildContext context, int index, dynamic surah) async {
    // ── 1. Mark this surah as selected immediately (updates UI highlight) ──
    surahAudioCtrl.state.selectedSurahIndex.value = index;
    surahAudioCtrl.state.currentAudioListSurahNum.value = surah.surahNumber;
    surahAudioCtrl.state.isPlaying.value = false; // clear until playback starts

    // Expand the floating player card if it was collapsed.
    final surahState = surahAudioCtrl.surahState;
    if (!surahState.isPlayExpanded.value) {
      // Don't force-expand so it doesn't jump; just ensure it's visible.
    }

    // ── 2. Check cache, then play ──────────────────────────────────────────
    // selectSurahFromList wires quran_library internal state (reader, position
    // saving, etc.) without triggering its own autoPlay.
    await surahAudioCtrl.selectSurahFromList(context, index, autoPlay: false);

    if (!context.mounted) return;

    await surahAudioCtrl.playSurahWithCache(
      context: context,
      surahNumber: surah.surahNumber,
    );

    // ── 3. Sync isPlaying state after playback starts ──────────────────────
    // playSurahWithCache drives the underlying AudioPlayer; set the reactive
    // flag so all Obx widgets (tile visualiser, collapsed bar, etc.) update.
    surahAudioCtrl.state.isPlaying.value = true;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SurahTile — single row card
// ─────────────────────────────────────────────────────────────────────────────

class _SurahTile extends StatelessWidget {
  final dynamic surah;
  final int index;
  final bool isSelected;
  final bool isPlaying;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _SurahTile({
    required this.surah,
    required this.index,
    required this.isSelected,
    required this.isPlaying,
    required this.isDark,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                      ? cs.primary.withValues(alpha: 0.18)
                      : cs.primary.withValues(alpha: 0.08))
                : (isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : cs.secondary),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? cs.primary.withValues(alpha: 0.35)
                  : cs.primary.withValues(alpha: 0.10),
              width: isSelected ? 1.4 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.14),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // ── Number badge ──────────────────────────────────────
              _NumberBadge(
                number: surah.surahNumber,
                isSelected: isSelected,
                cs: cs,
                isDark: isDark,
              ),

              const SizedBox(width: 14),

              // ── Surah name SVG + English name + offline badge ─────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RepaintBoundary(
                      child: customSvgWithColor(
                        'assets/svg/surah_name/00${index + 1}.svg',
                        width: 100,
                        color: isSelected ? cs.primary : cs.inversePrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          surah.englishName,
                          style: TextStyle(
                            fontFamily: 'naskh',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? cs.primary.withValues(alpha: 0.75)
                                : Theme.of(context).hintColor,
                          ),
                        ),
                        const SizedBox(width: 5),
                        // Offline badge — rebuilds when reciter changes.
                        Obx(() {
                          currentReciterIdObs.value; // reactive dependency
                          return FutureBuilder<bool>(
                            future: AudioCtrl.instance.isSurahCached(index + 1),
                            builder: (_, snap) => (snap.data ?? false)
                                ? const OfflineBadge()
                                : const SizedBox.shrink(),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Animated visualiser (playing) or revelation chip ──
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: isPlaying
                    ? Padding(
                        key: const ValueKey('viz'),
                        padding: const EdgeInsets.only(right: 10),
                        child: MiniMusicVisualizer(
                          color: cs.primary,
                          width: 3,
                          height: 16,
                          animate: true,
                        ),
                      )
                    : Padding(
                        key: const ValueKey('chip'),
                        padding: const EdgeInsets.only(right: 10),
                        child: _RevelationChip(
                          type: surah.revelationType,
                          cs: cs,
                          isDark: isDark,
                        ),
                      ),
              ),

              // ── Per-surah download / cached indicator ─────────────
              SurahCacheDownloadButton(surahNumber: index + 1),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Number badge ─────────────────────────────────────────────────────────────

class _NumberBadge extends StatelessWidget {
  final int number;
  final bool isSelected;
  final ColorScheme cs;
  final bool isDark;

  const _NumberBadge({
    required this.number,
    required this.isSelected,
    required this.cs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  cs.primary,
                  Color.lerp(
                    cs.primary,
                    isDark ? Colors.black : Colors.white,
                    0.20,
                  )!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : cs.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          number.toString().convertNumbersToCurrentLang(),
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isSelected
                ? (isDark ? Colors.white : cs.secondary)
                : cs.primary,
          ),
        ),
      ),
    );
  }
}

// ── Meccan / Medinan chip ─────────────────────────────────────────────────────

class _RevelationChip extends StatelessWidget {
  final String? type;
  final ColorScheme cs;
  final bool isDark;

  const _RevelationChip({
    required this.type,
    required this.cs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isMeccan = (type ?? '').toLowerCase() == 'meccan';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: (isMeccan ? const Color(0xff5C7A5B) : const Color(0xff3D5A80))
            .withValues(alpha: isDark ? 0.20 : 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (isMeccan ? const Color(0xff5C7A5B) : const Color(0xff3D5A80))
              .withValues(alpha: 0.30),
          width: 0.8,
        ),
      ),
      child: Text(
        isMeccan ? 'مكية' : 'مدنية',
        style: TextStyle(
          fontFamily: 'kufi',
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: isMeccan ? const Color(0xff5C7A5B) : const Color(0xff3D5A80),
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}
