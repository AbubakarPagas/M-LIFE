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

            // Reader selector with translate animation
            Expanded(
              child: _ReaderSelector(
                audioCtrl: audioCtrl,
                compact: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Expanded — seek bar + controls + repeat/auto-next toggles
// ─────────────────────────────────────────────────────────────────────────────

class _ExpandedPlayer extends StatefulWidget {
  const _ExpandedPlayer({
    required this.quranCtrl,
    required this.audioCtrl,
  });

  final QuranController quranCtrl;
  final AudioCtrl audioCtrl;

  @override
  State<_ExpandedPlayer> createState() => _ExpandedPlayerState();
}

class _ExpandedPlayerState extends State<_ExpandedPlayer> {
  StreamSubscription<PlayerState>? _autoNextSubscription;

  QuranController get quranCtrl => widget.quranCtrl;
  AudioCtrl get audioCtrl => widget.audioCtrl;

  @override
  void dispose() {
    _autoNextSubscription?.cancel();
    super.dispose();
  }

  /// Enables the auto-next-surah listener that fires once playback completes.
  void _enableAutoNextListener() {
    _autoNextSubscription?.cancel();
    _autoNextSubscription = audioCtrl.state.audioPlayer.playerStateStream
        .listen((playerState) async {
      if (playerState.processingState != ProcessingState.completed) return;
      if (!(quranCtrl.state.autoNextSurah.value)) return;

      // Find the next surah's first ayah.
      final surahs = quranCtrl.state.surahs;
      final currentSurahNum = audioCtrl.currentAyah.surahNumber;
      if (currentSurahNum! >= surahs.length) return; // already at last surah

      final nextSurah = surahs.firstWhereOrNull(
        (s) => s.surahNumber == currentSurahNum + 1,
      );
      if (nextSurah == null || nextSurah.ayahs.isEmpty) return;

      final ctx = Get.context;
      if (ctx == null || !ctx.mounted) return;

      GeneralController.instance.showAudioWidgetFor();
      audioCtrl.state.isDirectPlaying.value = true;
      quranCtrl.state.isPlayExpanded.value = true;

      await QuranLibrary().playAyah(
        context: ctx,
        currentAyahUniqueNumber: nextSurah.ayahs.first.ayahUQNumber,
        playSingleAyah: false,
      );
    });
  }

  void _disableAutoNextListener() {
    _autoNextSubscription?.cancel();
    _autoNextSubscription = null;
  }

  void _toggleRepeatAyah() async {
    final newValue = !quranCtrl.state.repeatAyah.value;
    quranCtrl.state.repeatAyah.value = newValue;
    await audioCtrl.state.audioPlayer.setLoopMode(
      newValue ? LoopMode.one : LoopMode.off,
    );
  }

  void _toggleAutoNextSurah() {
    final newValue = !quranCtrl.state.autoNextSurah.value;
    quranCtrl.state.autoNextSurah.value = newValue;
    if (newValue) {
      _enableAutoNextListener();
    } else {
      _disableAutoNextListener();
    }
  }

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

            // ── Reader selector ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ReaderSelector(
                audioCtrl: audioCtrl,
                compact: false,
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
                              onChangeEnd: audioCtrl.state.audioPlayer.seek,
                            );
                          },
                        ),
                ),
              ),
            ),

            // ── Playback controls row ────────────────────────────────────
            // Layout (RTL): [repeat] [skip-prev] [play] [skip-next] [auto-next]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ── Repeat Ayah icon toggle ──────────────────────────
                  Obx(
                    () => _ControlButton(
                      icon: Icons.repeat_one_rounded,
                      size: 24,
                      color: quranCtrl.state.repeatAyah.value
                          ? cs.primary
                          : cs.primary.withValues(alpha: .35),
                      onTap: _toggleRepeatAyah,
                      label: 'repeat_ayah',
                    ),
                  ),

                  // ── Skip previous (RTL-aware) ────────────────────────
                  _ControlButton(
                    icon: Icons.skip_next_rounded,
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

                  // ── Play / Pause ─────────────────────────────────────
                  _PlayPauseButton(size: 46, audioCtrl: audioCtrl),

                  // ── Skip next (RTL-aware) ────────────────────────────
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

                  // ── Auto Next Surah icon toggle ──────────────────────
                  Obx(
                    () => _ControlButton(
                      icon: Icons.playlist_play_rounded,
                      size: 26,
                      color: quranCtrl.state.autoNextSurah.value
                          ? cs.primary
                          : cs.primary.withValues(alpha: .35),
                      onTap: _toggleAutoNextSurah,
                      label: 'auto_next_surah',
                    ),
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
// Reader Selector — beautiful translate-animated reader name + dialog trigger
// ─────────────────────────────────────────────────────────────────────────────

class _ReaderSelector extends StatelessWidget {
  const _ReaderSelector({
    required this.audioCtrl,
    this.compact = true,
  });

  final AudioCtrl audioCtrl;

  /// [compact] = true  → used in the collapsed single-row player (no badge)
  /// [compact] = false → used in the expanded player (shows label badge)
  final bool compact;

  void _openReaderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _ReaderPickerDialog(
        audioCtrl: audioCtrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accentColor = cs.surface; // gold / accent (matches theme)
    final labelColor = cs.primary;

    return GestureDetector(
      onTap: () => _openReaderDialog(context),
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        button: true,
        label: 'Change Reader'.tr,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: compact
              ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
              : const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(compact ? 20 : 14),
            border: Border.all(
              color: accentColor.withValues(alpha: .22),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
            mainAxisAlignment: compact
                ? MainAxisAlignment.start
                : MainAxisAlignment.spaceBetween,
            children: [
              // ── Mic icon ──────────────────────────────────────────────
              Icon(
                Icons.mic_none_rounded,
                size: compact ? 15 : 17,
                color: accentColor.withValues(alpha: .75),
              ),

              const SizedBox(width: 6),

              // ── Animated reader name (slide-translate on change) ───────
              Flexible(
                child: GetBuilder<AudioCtrl>(
                  id: 'change_ayah_reader',
                  builder: (ctrl) {
                    final readerName = ReadersConstants
                        .activeAyahReaders[
                            ctrl.state.ayahReaderIndex.value]
                        .name
                        .tr;
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      transitionBuilder: (child, animation) {
                        // Slide up (translate) + fade
                        final offsetTween = Tween<Offset>(
                          begin: const Offset(0.0, 0.6),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ));
                        return SlideTransition(
                          position: offsetTween,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        readerName,
                        key: ValueKey<String>(readerName),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: compact ? 12.5 : 14,
                          fontWeight: FontWeight.w600,
                          color: labelColor,
                          letterSpacing: 0.1,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 4),

              // ── Animated chevron ──────────────────────────────────────
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: compact ? 16 : 18,
                color: accentColor.withValues(alpha: .70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reader Picker Dialog — beautiful bottom-sheet-style dialog with reader list
// ─────────────────────────────────────────────────────────────────────────────

class _ReaderPickerDialog extends StatelessWidget {
  const _ReaderPickerDialog({required this.audioCtrl});
  final AudioCtrl audioCtrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bgColor = Theme.of(context).primaryColor;
    final canvasColor = Theme.of(context).canvasColor;
    final accentColor = cs.surface;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.72,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .28),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ───────────────────────────────────────────────
              _DialogHeader(
                accentColor: accentColor,
                canvasColor: canvasColor,
              ),

              // ── Tab bar + content ────────────────────────────────────
              Flexible(
                child: DefaultTabController(
                  length: !kIsWeb ? 2 : 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tab bar
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: TabBar(
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorColor: accentColor,
                          indicatorWeight: 2.5,
                          labelColor: accentColor,
                          unselectedLabelColor:
                              canvasColor.withValues(alpha: .45),
                          labelStyle: const TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 13,
                          ),
                          dividerColor:
                              canvasColor.withValues(alpha: .10),
                          tabs: [
                            Tab(text: 'القراء'.tr),
                            if (!kIsWeb)
                              Tab(text: 'السور المحملة'.tr),
                          ],
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Tab content
                      Flexible(
                        child: TabBarView(
                          children: [
                            // ── Readers list ─────────────────────────
                            _ReaderList(
                              audioCtrl: audioCtrl,
                              accentColor: accentColor,
                              canvasColor: canvasColor,
                              bgColor: bgColor,
                            ),

                            // ── Download manager ──────────────────────
                            if (!kIsWeb)
                              AyahDownloadManagerSheet(
                                isInChangeReaderDialog: true,
                                onRequestDownload: (surahNum) async {
                                  if (audioCtrl
                                      .state.isDownloading.value) {
                                    return;
                                  }
                                  await AudioCtrl.instance
                                      .startDownloadAyahSurah(
                                    surahNum,
                                    context: context,
                                  );
                                },
                                onRequestDelete: (surahNum) async {
                                  await AudioCtrl.instance
                                      .deleteAyahSurahDownloads(
                                          surahNum);
                                },
                                isSurahDownloadedChecker: (surahNum) =>
                                    AudioCtrl.instance
                                        .isAyahSurahFullyDownloaded(
                                            surahNum),
                                initialSurahToFocus: AudioCtrl
                                    .instance.currentSurahNumber,
                                style: audioCtrl.ayahDownloadManagerStyle,
                                isDark: themeCtrl.isDarkMode,
                                ayahStyle: audioCtrl.ayahAudioStyle,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog header with gradient accent bar + title + close button
// ─────────────────────────────────────────────────────────────────────────────

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.accentColor,
    required this.canvasColor,
  });

  final Color accentColor;
  final Color canvasColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient accent strip at the top
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accentColor.withValues(alpha: .18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              // Mic icon badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: .15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withValues(alpha: .30),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.mic_rounded,
                  size: 18,
                  color: accentColor,
                ),
              ),

              const SizedBox(width: 10),

              // Title
              Expanded(
                child: Text(
                  'تغيير القارئ'.tr,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: canvasColor,
                  ),
                ),
              ),

              // Close button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: canvasColor.withValues(alpha: .60),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reader list inside dialog — animated selection with translate on tap
// ─────────────────────────────────────────────────────────────────────────────

class _ReaderList extends StatelessWidget {
  const _ReaderList({
    required this.audioCtrl,
    required this.accentColor,
    required this.canvasColor,
    required this.bgColor,
  });

  final AudioCtrl audioCtrl;
  final Color accentColor;
  final Color canvasColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    final readers = ReadersConstants.activeAyahReaders;

    return Obx(() {
      final selectedIndex = audioCtrl.state.ayahReaderIndex.value;

      return ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: readers.length,
        itemBuilder: (context, index) {
          final info = readers[index];
          final bool isSelected = selectedIndex == info.index;

          return _ReaderListItem(
            info: info,
            isSelected: isSelected,
            accentColor: accentColor,
            canvasColor: canvasColor,
            bgColor: bgColor,
            onTap: () {
              audioCtrl.state.ayahReaderIndex.value = index;
              Navigator.of(context).pop();
            },
          );
        },
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual reader list item with slide-in entrance and selection indicator
// ─────────────────────────────────────────────────────────────────────────────

class _ReaderListItem extends StatelessWidget {
  const _ReaderListItem({
    required this.info,
    required this.isSelected,
    required this.accentColor,
    required this.canvasColor,
    required this.bgColor,
    required this.onTap,
  });

  final ReaderInfo info;
  final bool isSelected;
  final Color accentColor;
  final Color canvasColor;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: .14)
              : canvasColor.withValues(alpha: .04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: .40)
                : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            splashColor: accentColor.withValues(alpha: .10),
            highlightColor: accentColor.withValues(alpha: .06),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: Row(
                children: [
                  // ── Selection dot / index number ─────────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: isSelected
                        ? Container(
                            key: const ValueKey('selected'),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: bgColor,
                            ),
                          )
                        : Container(
                            key: const ValueKey('unselected'),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: canvasColor.withValues(alpha: .08),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: canvasColor.withValues(alpha: .20),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${info.index + 1}',
                                style: TextStyle(
                                  fontFamily: 'kufi',
                                  fontSize: 10,
                                  color: canvasColor.withValues(alpha: .50),
                                ),
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(width: 12),

                  // ── Reader name with translate entrance ───────────────
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(
                          milliseconds: 200 + (info.index * 30).clamp(0, 300)),
                      curve: Curves.easeOutCubic,
                      builder: (ctx, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(12 * (1 - value), 0),
                          child: child,
                        ),
                      ),
                      child: Text(
                        info.name.tr,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 13.5,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? accentColor
                              : canvasColor.withValues(alpha: .80),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
