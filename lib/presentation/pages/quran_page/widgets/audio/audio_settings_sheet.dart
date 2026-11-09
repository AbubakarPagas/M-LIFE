part of '../../quran.dart';

const Color _kAudioGold = Color(0xFFD4A435);

/// Full-featured audio settings bottom sheet.
class AudioSettingsSheet extends StatelessWidget {
  AudioSettingsSheet({Key? key}) : super(key: key);

  final audioCtrl = AudioCtrl.instance;
  final RxDouble _volume = RxDouble(1.0);
  final RxBool _shuffle = false.obs;
  final _repeatMode = Rx<LoopMode>(LoopMode.off);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    _volume.value = audioCtrl.state.audioPlayer.volume;
    _shuffle.value = audioCtrl.state.audioPlayer.shuffleModeEnabled;
    _repeatMode.value = audioCtrl.state.audioPlayer.loopMode;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            const _AudioSheetHeader(),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: [
                  const _AudioSectionHeader(
                    icon: Icons.linear_scale_rounded,
                    label: 'Progress',
                  ),
                  const SizedBox(height: 8),
                  GetBuilder<AudioCtrl>(
                    id: 'audio_seekBar_id',
                    builder: (_) => Obx(
                      () => audioCtrl.state.isDownloading.value
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
                                final pos = snapshot.data;
                                return SliderWidget.player(
                                  horizontalPadding: 0.0,
                                  duration: pos?.duration ?? Duration.zero,
                                  position: pos?.position ?? Duration.zero,
                                  activeTrackColor: _kAudioGold,
                                  onChangeEnd: audioCtrl.state.audioPlayer.seek,
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _AudioSectionHeader(
                    icon: Icons.play_circle_outline_rounded,
                    label: 'Playback',
                  ),
                  const SizedBox(height: 12),
                  _FullPlaybackControls(
                    shuffle: _shuffle,
                    repeatMode: _repeatMode,
                  ),
                  const SizedBox(height: 28),
                  const _AudioSectionHeader(
                    icon: Icons.mic_rounded,
                    label: 'Reciter',
                  ),
                  const SizedBox(height: 12),
                  const _RecitationList(),
                  const SizedBox(height: 28),
                  const _AudioSectionHeader(
                    icon: Icons.volume_up_rounded,
                    label: 'Volume',
                  ),
                  const SizedBox(height: 8),
                  _VolumeSlider(volume: _volume),
                  const SizedBox(height: 28),
                  const _AudioSectionHeader(
                    icon: Icons.repeat_rounded,
                    label: 'Repeat Mode',
                  ),
                  const SizedBox(height: 10),
                  _RepeatModeSelector(repeatMode: _repeatMode),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sheet header ─────────────────────────────────────────────────────────────
class _AudioSheetHeader extends StatelessWidget {
  const _AudioSheetHeader();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                SvgPath.svgDecorations,
                height: 22,
                colorFilter: const ColorFilter.mode(
                  _kAudioGold,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Audio Settings',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: cs.onSurface,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 10),
              Transform.flip(
                flipX: true,
                child: SvgPicture.asset(
                  SvgPath.svgDecorations,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                    _kAudioGold,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _kAudioGold.withValues(alpha: 0.55),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Section header ───────────────────────────────────────────────────────────
class _AudioSectionHeader extends StatelessWidget {
  const _AudioSectionHeader({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _kAudioGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _kAudioGold.withValues(alpha: 0.30),
              width: 1,
            ),
          ),
          child: Icon(icon, size: 16, color: _kAudioGold),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'kufi',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _kAudioGold.withValues(alpha: 0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Full playback controls ───────────────────────────────────────────────────
class _FullPlaybackControls extends StatelessWidget {
  const _FullPlaybackControls({
    required this.shuffle,
    required this.repeatMode,
  });
  final RxBool shuffle;
  final Rx<LoopMode> repeatMode;

  @override
  Widget build(BuildContext context) {
    final audioCtrl = AudioCtrl.instance;
    final isRTL = Get.locale?.languageCode == 'ar';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Obx(
          () => _AudioIconBtn(
            icon: Icons.shuffle_rounded,
            isActive: shuffle.value,
            tooltip: 'Shuffle',
            onTap: () async {
              final v = !shuffle.value;
              shuffle.value = v;
              await audioCtrl.state.audioPlayer.setShuffleModeEnabled(v);
            },
          ),
        ),
        _AudioIconBtn(
          icon: Icons.skip_previous_rounded,
          size: 32,
          tooltip: 'Previous',
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
        StreamBuilder<PlayerState>(
          stream: audioCtrl.state.audioPlayer.playerStateStream,
          builder: (context, snapshot) {
            final isPlaying = snapshot.data?.playing ?? false;
            final isLoading =
                snapshot.data?.processingState == ProcessingState.loading ||
                snapshot.data?.processingState == ProcessingState.buffering;
            return GestureDetector(
              onTap: () async {
                if (isLoading) return;
                if (isPlaying) {
                  audioCtrl.pausePlayer();
                } else {
                  GeneralController.instance.showAudioWidgetFor();
                  audioCtrl.playAyah(
                    context,
                    audioCtrl.currentAyah.ayahUQNumber,
                    playSingleAyah: true,
                  );
                }
              },
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _kAudioGold,
                      Color.lerp(_kAudioGold, Colors.orange, 0.35)!,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _kAudioGold.withValues(alpha: 0.40),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
              ),
            );
          },
        ),
        _AudioIconBtn(
          icon: Icons.skip_next_rounded,
          size: 32,
          tooltip: 'Next',
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
        Obx(
          () => _AudioIconBtn(
            icon: repeatMode.value == LoopMode.one
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded,
            isActive: repeatMode.value != LoopMode.off,
            tooltip: repeatMode.value == LoopMode.one
                ? 'Repeat Ayah'
                : repeatMode.value == LoopMode.all
                ? 'Repeat All'
                : 'No Repeat',
            onTap: () async {
              final next = repeatMode.value == LoopMode.off
                  ? LoopMode.all
                  : repeatMode.value == LoopMode.all
                  ? LoopMode.one
                  : LoopMode.off;
              repeatMode.value = next;
              await audioCtrl.state.audioPlayer.setLoopMode(next);
            },
          ),
        ),
      ],
    );
  }
}

// ── Reader metadata ──────────────────────────────────────────────────────────
class _ReaderMeta {
  final String nameEn, nameAr, countryEn, flag;
  const _ReaderMeta({
    required this.nameEn,
    required this.nameAr,
    required this.countryEn,
    required this.flag,
  });
}

const List<_ReaderMeta> _readerMeta = [
  _ReaderMeta(
    nameEn: 'Abdul Basit Abdul Samad',
    nameAr:
        '\u0639\u0628\u062f \u0627\u0644\u0628\u0627\u0633\u0637 \u0639\u0628\u062f \u0627\u0644\u0635\u0645\u062f',
    countryEn: 'Egypt',
    flag: '\u{1F1EA}\u{1F1EC}',
  ),
  _ReaderMeta(
    nameEn: 'Muhammad Siddiq Al-Minshawi',
    nameAr:
        '\u0645\u062d\u0645\u062f \u0635\u062f\u064a\u0642 \u0627\u0644\u0645\u0646\u0634\u0627\u0648\u064a',
    countryEn: 'Egypt',
    flag: '\u{1F1EA}\u{1F1EC}',
  ),
  _ReaderMeta(
    nameEn: 'Mahmoud Khalil Al-Husary',
    nameAr:
        '\u0645\u062d\u0645\u0648\u062f \u062e\u0644\u064a\u0644 \u0627\u0644\u062d\u0635\u0631\u064a',
    countryEn: 'Egypt',
    flag: '\u{1F1EA}\u{1F1EC}',
  ),
  _ReaderMeta(
    nameEn: 'Ahmad Ibn Ali Al-Ajamy',
    nameAr:
        '\u0623\u062d\u0645\u062f \u0628\u0646 \u0639\u0644\u064a \u0627\u0644\u0639\u062c\u0645\u064a',
    countryEn: 'Kuwait',
    flag: '\u{1F1F0}\u{1F1FC}',
  ),
  _ReaderMeta(
    nameEn: 'Maher Al-Muaiqly',
    nameAr:
        '\u0645\u0627\u0647\u0631 \u0627\u0644\u0645\u0639\u064a\u0642\u0644\u064a',
    countryEn: 'Saudi Arabia',
    flag: '\u{1F1F8}\u{1F1E6}',
  ),
  _ReaderMeta(
    nameEn: 'Saud Al-Shuraim',
    nameAr: '\u0633\u0639\u0648\u062f \u0627\u0644\u0634\u0631\u064a\u0645',
    countryEn: 'Saudi Arabia',
    flag: '\u{1F1F8}\u{1F1E6}',
  ),
  _ReaderMeta(
    nameEn: 'Abdullah Al-Juhany',
    nameAr:
        '\u0639\u0628\u062f \u0627\u0644\u0644\u0647 \u0627\u0644\u062c\u0647\u0646\u064a',
    countryEn: 'Saudi Arabia',
    flag: '\u{1F1F8}\u{1F1E6}',
  ),
  _ReaderMeta(
    nameEn: 'Fares Abbad',
    nameAr: '\u0641\u0627\u0631\u0633 \u0639\u0628\u0627\u062f',
    countryEn: 'Algeria',
    flag: '\u{1F1E9}\u{1F1FF}',
  ),
  _ReaderMeta(
    nameEn: 'Muhammad Ayyub',
    nameAr: '\u0645\u062d\u0645\u062f \u0623\u064a\u0648\u0628',
    countryEn: 'Saudi Arabia',
    flag: '\u{1F1F8}\u{1F1E6}',
  ),
  _ReaderMeta(
    nameEn: 'Maher Al-Muaiqly (Mujawwad)',
    nameAr:
        '\u0645\u0627\u0647\u0631 \u0627\u0644\u0645\u0639\u064a\u0642\u0644\u064a (\u0645\u062c\u0648\u062f)',
    countryEn: 'Saudi Arabia',
    flag: '\u{1F1F8}\u{1F1E6}',
  ),
  _ReaderMeta(
    nameEn: 'Yasser Al-Dossary (Mujawwad)',
    nameAr:
        '\u064a\u0627\u0633\u0631 \u0627\u0644\u062f\u0648\u0633\u0631\u064a (\u0645\u062c\u0648\u062f)',
    countryEn: 'Saudi Arabia',
    flag: '\u{1F1F8}\u{1F1E6}',
  ),
];

// ── Recitation list (vertical) ───────────────────────────────────────────────
class _RecitationList extends StatelessWidget {
  const _RecitationList();
  @override
  Widget build(BuildContext context) {
    final audioCtrl = AudioCtrl.instance;
    final cs = Theme.of(context).colorScheme;
    final readers = ReadersConstants.activeAyahReaders;
    return Obx(() {
      final selected = audioCtrl.state.ayahReaderIndex.value;
      return Column(
        children: List.generate(readers.length, (i) {
          final isSelected = i == selected;
          final meta = i < _readerMeta.length
              ? _readerMeta[i]
              : _ReaderMeta(
                  nameEn: readers[i].name,
                  nameAr: readers[i].name,
                  countryEn: '',
                  flag: '\u{1F30D}',
                );
          return GestureDetector(
            onTap: () => audioCtrl.state.ayahReaderIndex.value = i,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: isSelected
                    ? _kAudioGold.withValues(alpha: 0.10)
                    : cs.surface.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? _kAudioGold
                      : cs.outline.withValues(alpha: 0.20),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _kAudioGold.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                _kAudioGold.withValues(alpha: 0.70),
                                _kAudioGold.withValues(alpha: 0.35),
                              ],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : cs.onSurface.withValues(alpha: 0.07),
                      border: Border.all(
                        color: isSelected
                            ? _kAudioGold.withValues(alpha: 0.60)
                            : cs.outline.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        audioCtrl.state.appIconUrl.value,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            meta.nameEn.isNotEmpty
                                ? meta.nameEn[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: isSelected
                                  ? Colors.white
                                  : cs.onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meta.nameEn,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected ? _kAudioGold : cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${meta.flag}  ${meta.countryEn}',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withValues(alpha: 0.50),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          meta.nameAr,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 11,
                            color: cs.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _kAudioGold.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: _kAudioGold,
                        size: 14,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      );
    });
  }
}

// ── Volume slider ────────────────────────────────────────────────────────────
class _VolumeSlider extends StatelessWidget {
  const _VolumeSlider({required this.volume});
  final RxDouble volume;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final audioCtrl = AudioCtrl.instance;
    return Obx(
      () => Row(
        children: [
          Icon(
            Icons.volume_mute_rounded,
            color: cs.onSurface.withValues(alpha: 0.40),
            size: 20,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: _kAudioGold,
                inactiveTrackColor: _kAudioGold.withValues(alpha: 0.18),
                thumbColor: _kAudioGold,
                overlayColor: _kAudioGold.withValues(alpha: 0.15),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                trackHeight: 3,
              ),
              child: Slider(
                value: volume.value.clamp(0.0, 1.0),
                min: 0.0,
                max: 1.0,
                onChanged: (v) {
                  volume.value = v;
                  audioCtrl.state.audioPlayer.setVolume(v);
                },
              ),
            ),
          ),
          const Icon(Icons.volume_up_rounded, color: _kAudioGold, size: 22),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: _kAudioGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _kAudioGold.withValues(alpha: 0.30),
                width: 1,
              ),
            ),
            child: Text(
              '${(volume.value * 100).round()}%',
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'kufi',
                fontWeight: FontWeight.bold,
                color: _kAudioGold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Repeat mode selector ─────────────────────────────────────────────────────
class _RepeatModeSelector extends StatelessWidget {
  const _RepeatModeSelector({required this.repeatMode});
  final Rx<LoopMode> repeatMode;
  @override
  Widget build(BuildContext context) {
    final audioCtrl = AudioCtrl.instance;
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _RepeatChip(
            label: 'Off',
            icon: Icons.do_not_disturb_alt_rounded,
            isSelected: repeatMode.value == LoopMode.off,
            onTap: () async {
              repeatMode.value = LoopMode.off;
              await audioCtrl.state.audioPlayer.setLoopMode(LoopMode.off);
            },
          ),
          _RepeatChip(
            label: 'Repeat All',
            icon: Icons.repeat_rounded,
            isSelected: repeatMode.value == LoopMode.all,
            onTap: () async {
              repeatMode.value = LoopMode.all;
              await audioCtrl.state.audioPlayer.setLoopMode(LoopMode.all);
            },
          ),
          _RepeatChip(
            label: 'Repeat Ayah',
            icon: Icons.repeat_one_rounded,
            isSelected: repeatMode.value == LoopMode.one,
            onTap: () async {
              repeatMode.value = LoopMode.one;
              await audioCtrl.state.audioPlayer.setLoopMode(LoopMode.one);
            },
          ),
        ],
      ),
    );
  }
}

class _RepeatChip extends StatelessWidget {
  const _RepeatChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? _kAudioGold.withValues(alpha: 0.15)
              : cs.surface.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? _kAudioGold
                : cs.outline.withValues(alpha: 0.22),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _kAudioGold.withValues(alpha: 0.20),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? _kAudioGold
                  : cs.onSurface.withValues(alpha: 0.55),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? _kAudioGold
                    : cs.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Generic icon button ───────────────────────────────────────────────────────
class _AudioIconBtn extends StatelessWidget {
  const _AudioIconBtn({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.tooltip = '',
    this.size = 26.0,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final String tooltip;
  final double size;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Icon(
          icon,
          size: size,
          color: isActive ? _kAudioGold : cs.onSurface.withValues(alpha: 0.50),
        ),
      ),
    );
  }
}

// ── Legacy alias kept so any remaining barrel references compile ─────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: _kAudioGold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Gap(8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'kufi',
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}
