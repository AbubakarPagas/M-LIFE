part of '../surah_audio.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AudioSurahWithAyahs
//
// Full-screen immersive player.  Displays:
//   • Reciter avatar + name
//   • Ayah tracker (word-highlighted ayah when segment data is available)
//     or surah info card (fallback when no segment data)
//   • Full PlayWidget (seek bar + controls)
//
// Design mirrors the gradient card language of the main AudioScreen:
//   - Dynamic background derived from the active reciter accent colours
//   - _IslamicBgPainter subtle overlay
//   - _ReciterAvatar with glow ring
// ─────────────────────────────────────────────────────────────────────────────

class AudioSurahWithAyahs extends GetView<AudioSurahWithAyahsController> {
  const AudioSurahWithAyahs({super.key});

  @override
  Widget build(BuildContext context) {
    final surahCtrl = AudioCtrl.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (didPop) return;
        Navigator.pop(context);
      },
      child: Obx(() {
        final reciterId = currentReciterIdObs.value;
        final meta = _metaFor(reciterId);

        // Build background gradient using reciter accent colours + theme primary
        final cs = Theme.of(context).colorScheme;
        final bgA = Color.lerp(cs.primary, meta.colorA, 0.65)!;
        final bgB = Color.lerp(cs.primary, meta.colorB, 0.40)!;
        final surfaceBg =
            isDark ? Color.lerp(bgA, Colors.black, 0.28)! : bgA;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  surfaceBg,
                  isDark ? Color.lerp(bgB, Colors.black, 0.20)! : bgB,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // ── Subtle Islamic geometric overlay ──────────────────────
                Positioned.fill(
                  child: Opacity(
                    opacity: isDark ? 0.06 : 0.05,
                    child:
                        CustomPaint(painter: _IslamicBgPainter(Colors.white)),
                  ),
                ),

                // ── Main layout ───────────────────────────────────────────
                SafeArea(
                  child: Column(
                    children: [
                      // ── Close button (top-centre pill) ────────────────
                      _CloseBar(),
                      const SizedBox(height: 8),

                      // ── Reciter avatar + name ─────────────────────────
                      _ReciterHeader(meta: meta, reciterId: reciterId),
                      const SizedBox(height: 20),

                      // ── Surah name (large layered SVG) ────────────────
                      _SurahNameDisplay(),
                      const SizedBox(height: 20),

                      // ── Ayah tracker / surah info card ────────────────
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: Obx(() {
                          final isAvailable = controller
                              .segState
                              .isSegmentsAvailable
                              .value;
                          final surahNum =
                              controller
                                  .segState
                                  .currentSegmentSurahNumber
                                  .value ??
                              surahCtrl
                                  .state
                                  .currentAudioListSurahNum
                                  .value;

                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            child: isAvailable
                                ? _AyahTrackerCard(
                                    key: const ValueKey('tracker'),
                                    controller: controller,
                                    surahCtrl: surahCtrl,
                                    surahNum: surahNum,
                                  )
                                : _SurahInfoCard(
                                    key: const ValueKey('info'),
                                    surahNum: surahNum,
                                  ),
                          );
                        }),
                      ),

                      const Spacer(),

                      // ── Seek bar + controls ───────────────────────────
                      _PlayerControlsSection(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CloseBar — subtle top pill with close + reader-change shortcut
// ─────────────────────────────────────────────────────────────────────────────

class _CloseBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.20),
                ),
              ),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const Spacer(),
          // Screen label
          Text(
            'fullPlayer'.tr.isEmpty ? 'المشغّل الكامل' : 'fullPlayer'.tr,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const Spacer(),
          // Reader-change button (hidden SurahChangeSurahReader for dialog logic)
          Stack(
            alignment: Alignment.center,
            children: [
              // Visible tappable button
              GestureDetector(
                onTap: () async {
                  await Future.delayed(const Duration(milliseconds: 600));
                  AudioCtrl.instance.refreshCurrentReciter();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Icon(
                    Icons.headset_rounded,
                    color: Colors.white.withValues(alpha: 0.85),
                    size: 18,
                  ),
                ),
              ),
              // Zero-height hidden reader dialog trigger
              SizedBox(
                height: 0,
                child: Opacity(
                  opacity: 0,
                  child: SurahChangeSurahReader(
                    style: AudioCtrl.instance.surahAudioStyle,
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  ),
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
// _ReciterHeader
// ─────────────────────────────────────────────────────────────────────────────

class _ReciterHeader extends StatelessWidget {
  final FullReciterMeta meta;
  final String reciterId;

  const _ReciterHeader({required this.meta, required this.reciterId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar with glow ring
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    meta.colorA.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Border ring
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 2,
                ),
              ),
            ),
            // Avatar
            _ReciterAvatar(reciterId: reciterId, size: 72),
          ],
        ),

        const SizedBox(height: 10),

        // Reciter name
        Text(
          meta.displayName,
          style: const TextStyle(
            fontFamily: 'kufi',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SurahNameDisplay
// ─────────────────────────────────────────────────────────────────────────────

class _SurahNameDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final surahCtrl = AudioCtrl.instance;

    return Obx(() {
      final surahNum =
          surahCtrl.state.currentAudioListSurahNum.value.toString();
      return Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.08,
            child: surahNameWidget(
              surahNum,
              Colors.white,
              height: 80,
              width: 180,
            ),
          ),
          surahNameWidget(
            surahNum,
            Colors.white,
            height: 52,
            width: 150,
          ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AyahTrackerCard — shows the highlighted ayah word-by-word
// ─────────────────────────────────────────────────────────────────────────────

class _AyahTrackerCard extends StatelessWidget {
  final AudioSurahWithAyahsController controller;
  final AudioCtrl surahCtrl;
  final int surahNum;

  const _AyahTrackerCard({
    super.key,
    required this.controller,
    required this.surahCtrl,
    required this.surahNum,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ayahNum = controller.segState.currentSegmentAyahNumber.value ?? 1;
      final wordNum = controller.segState.currentSegmentWordIndex.value ?? 1;

      final selectedWordRef = WordRef(
        surahNumber: surahNum,
        ayahNumber: ayahNum,
        wordNumber: wordNum,
      );

      return AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
        constraints: const BoxConstraints(minHeight: 130, maxHeight: 260),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ayah number badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.20)),
              ),
              child: Text(
                '${'ayah'.tr.isEmpty ? 'الآية' : 'ayah'.tr} $ayahNum'
                    .convertNumbersToCurrentLang(),
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.80),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Ayah text with word highlight
            SingleChildScrollView(
              child: IgnorePointer(
                child: GetSingleAyah(
                  surahNumber: surahNum,
                  ayahNumber: ayahNum,
                  textHeight: 2.1,
                  enableWordSelection: true,
                  isDark: Theme.of(context).brightness == Brightness.dark,
                  externalSelectedWordRef: selectedWordRef,
                  textAlign: TextAlign.center,
                  textColor: Colors.white,
                  selectedWordColor: Colors.white.withValues(alpha: 0.35),
                  onWordTap: (_) {},
                  enabledTajweed:
                      QuranCtrl.instance.state.isTajweedEnabled.value,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SurahInfoCard — fallback when no segment data (shows surah metadata)
// ─────────────────────────────────────────────────────────────────────────────

class _SurahInfoCard extends StatelessWidget {
  final int surahNum;

  const _SurahInfoCard({super.key, required this.surahNum});

  @override
  Widget build(BuildContext context) {
    final surah = QuranCtrl.instance.surahs.firstWhere(
      (s) => s.surahNumber == surahNum,
      orElse: () => QuranCtrl.instance.surahs.first,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decorative Lottie / SVG quran icon
          Opacity(
            opacity: 0.25,
            child: customLottieWithColor(
              LottieConstants.assetsLottieQuranAuIc,
              height: 80,
              width: 80,
              isRepeat: false,
            ),
          ),
          const SizedBox(height: 12),
          // Surah name SVG
          surahNameWidget(
            surahNum.toString(),
            Colors.white,
            height: 60,
            width: 160,
          ),
          const SizedBox(height: 16),
          // Separator line
          Container(
            height: 1,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              color: Colors.white.withValues(alpha: 0.30),
            ),
          ),
          const SizedBox(height: 16),
          // Revelation type + ayah count chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoChip(
                icon: Icons.place_outlined,
                label: surah.revelationType?.tr ?? '',
              ),
              const SizedBox(width: 16),
              _InfoChip(
                icon: Icons.format_list_numbered_rounded,
                label:
                    '${'aya_count'.tr} ${surah.ayahs.length}'
                        .convertNumbersToCurrentLang(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.80)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PlayerControlsSection — seek bar + transport controls with white styling
// ─────────────────────────────────────────────────────────────────────────────

class _PlayerControlsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = AudioCtrl.instance;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Seek bar ────────────────────────────────────────────────
          GetBuilder<AudioCtrl>(
            id: 'surahDownloadManager_id',
            builder: (c) => c.state.isDownloading.value
                ? GetX<AudioCtrl>(
                    builder: (c) => SliderWidget.downloading(
                      currentPosition: c.state.downloadProgress.value.toInt(),
                      filesCount: c.state.fileSize.value,
                      horizontalPadding: 0,
                    ),
                  )
                : StreamBuilder<PackagePositionData>(
                    stream: c.positionDataStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return const SizedBox(height: 52);
                      }
                      c.state.positionData?.value = snapshot.data!;
                      final pos = snapshot.data!;
                      return SliderWidget.player(
                        horizontalPadding: 0,
                        duration: pos.duration,
                        position: c.state.lastTime != null
                            ? Duration(
                                seconds: c.state.lastPosition.value.toInt(),
                              )
                            : pos.position,
                        onChangeEnd: (newPos) {
                          c.state.audioPlayer.seek(newPos);
                          c.state.seekNextSeconds.value =
                              pos.position.inSeconds;
                        },
                        activeTrackColor: Colors.white,
                        textColor: Colors.white,
                        timeBackgroundColor:
                            Colors.white.withValues(alpha: 0.12),
                        timeShow: true,
                        thumbColor: Colors.white,
                      );
                    },
                  ),
          ),

          const SizedBox(height: 6),

          // ── Transport controls ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Rewind 5s
              _WhiteIconBtn(
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

              // Skip previous
              SurahSkipToPrevious(
                style: ctrl.surahAudioStyle,
                languageCode: Get.locale!.languageCode,
              ),

              // Play/Pause — larger button in white accent
              _FullScreenPlayButton(),

              // Skip next
              SurahSkipToNext(
                style: ctrl.surahAudioStyle,
                languageCode: Get.locale!.languageCode,
              ),

              // Forward 5s
              _WhiteIconBtn(
                icon: Icons.forward_5_rounded,
                size: 20,
                onTap: () => ctrl.state.audioPlayer.seek(
                  Duration(seconds: ctrl.state.seekNextSeconds.value += 5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Repeat toggle ────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<LoopMode>(
                stream:
                    ctrl.state.audioPlayer.loopModeStream,
                builder: (context, snapshot) {
                  final loopMode = snapshot.data ?? LoopMode.off;
                  final isLooping = loopMode != LoopMode.off;
                  return GestureDetector(
                    onTap: () {
                      const modes = [LoopMode.off, LoopMode.all];
                      final idx = modes.indexOf(loopMode);
                      ctrl.state.audioPlayer.setLoopMode(
                        modes[(idx + 1) % modes.length],
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isLooping
                            ? Colors.white.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isLooping
                              ? Colors.white.withValues(alpha: 0.50)
                              : Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.repeat_rounded,
                            color: Colors.white.withValues(
                              alpha: isLooping ? 1.0 : 0.50,
                            ),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isLooping
                                ? ('repeatOn'.tr.isEmpty
                                    ? 'تكرار مفعّل'
                                    : 'repeatOn'.tr)
                                : ('repeat'.tr.isEmpty
                                    ? 'تكرار'
                                    : 'repeat'.tr),
                            style: TextStyle(
                              fontFamily: 'kufi',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(
                                alpha: isLooping ? 1.0 : 0.55,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Full-screen play/pause button ─────────────────────────────────────────────

class _FullScreenPlayButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = AudioCtrl.instance;
    return StreamBuilder<PlayerState>(
      stream: ctrl.state.audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;

        if (processingState == ProcessingState.buffering ||
            processingState == ProcessingState.loading) {
          return Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.20),
              ),
            ),
          );
        }

        final isPlaying = playerState?.playing ?? false;

        return GestureDetector(
          onTap: () async {
            if (isPlaying) {
              ctrl.state.isPlaying.value = false;
              await ctrl.state.audioPlayer.pause();
            } else {
              NotificationManager.instance.trackAudioListening();
              await ctrl.playSurahWithCache(
                context: context,
                surahNumber: ctrl.state.currentAudioListSurahNum.value,
              );
            }
          },
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.35),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
          ),
        );
      },
    );
  }
}

// ── Small white icon button ───────────────────────────────────────────────────

class _WhiteIconBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _WhiteIconBtn({
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
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }
}
