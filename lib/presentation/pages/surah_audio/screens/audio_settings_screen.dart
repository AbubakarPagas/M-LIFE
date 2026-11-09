part of '../surah_audio.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AudioSettingsScreen — main widget
// ─────────────────────────────────────────────────────────────────────────────

class AudioSettingsScreen extends StatefulWidget {
  const AudioSettingsScreen({super.key});

  @override
  State<AudioSettingsScreen> createState() => _AudioSettingsScreenState();
}

class _AudioSettingsScreenState extends State<AudioSettingsScreen> {
  final _box = GetStorage();

  // ── Settings state ──────────────────────────────────────────────────────
  late String _currentReciterId;
  late double _playbackSpeed;
  late String _audioQuality;
  late bool _bgPlayback;
  late bool _autoResume;

  @override
  void initState() {
    super.initState();
    _currentReciterId =
        _box.read<String>(SURAH_AUDIO_PLAYER_SOUND) ?? 'ar.alafasy';
    _playbackSpeed = (_box.read<double>(AUDIO_PLAYBACK_SPEED) ?? 1.0).clamp(
      0.5,
      2.0,
    );
    _audioQuality = _box.read<String>(AUDIO_QUALITY) ?? 'high';
    _bgPlayback = _box.read<bool>(AUDIO_BG_PLAYBACK) ?? true;
    _autoResume = _box.read<bool>(AUDIO_AUTO_RESUME) ?? true;
  }

  // ── Persist helpers ─────────────────────────────────────────────────────
  void _setReciter(FullReciterMeta meta) {
    setState(() => _currentReciterId = meta.id);
    _box.write(SURAH_AUDIO_PLAYER_SOUND, meta.id);
    _box.write(SURAH_AUDIO_PLAYER_NAME, meta.displayName);
    AudioCtrl.instance.refreshCurrentReciter();
  }

  void _setSpeed(double v) {
    setState(() => _playbackSpeed = v);
    _box.write(AUDIO_PLAYBACK_SPEED, v);
    AudioCtrl.instance.state.audioPlayer.setSpeed(v);
  }

  void _setQuality(String q) {
    setState(() => _audioQuality = q);
    _box.write(AUDIO_QUALITY, q);
  }

  void _setBgPlayback(bool v) {
    setState(() => _bgPlayback = v);
    _box.write(AUDIO_BG_PLAYBACK, v);
  }

  void _setAutoResume(bool v) {
    setState(() => _autoResume = v);
    _box.write(AUDIO_AUTO_RESUME, v);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.secondary,
      appBar: AppBar(
        backgroundColor: cs.secondary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: cs.primary,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Audio Settings',
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: cs.primary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── 1. Default reciter ─────────────────────────────────────
          _SectionHeader(
            label: 'Default Reciter',
            icon: Icons.mic_rounded,
            cs: cs,
          ),
          const SizedBox(height: 10),
          _ReciterHorizontalList(
            currentId: _currentReciterId,
            isDark: isDark,
            cs: cs,
            onSelect: _setReciter,
          ),

          const SizedBox(height: 24),

          // ── 2. Playback speed ──────────────────────────────────────
          _SectionHeader(
            label: 'Playback Speed',
            icon: Icons.speed_rounded,
            cs: cs,
          ),
          const SizedBox(height: 10),
          _SpeedSelector(
            speed: _playbackSpeed,
            isDark: isDark,
            cs: cs,
            onChanged: _setSpeed,
          ),

          const SizedBox(height: 24),

          // ── 3. Audio quality ───────────────────────────────────────
          _SectionHeader(
            label: 'Audio Quality',
            icon: Icons.high_quality_rounded,
            cs: cs,
          ),
          const SizedBox(height: 10),
          _QualitySelector(
            quality: _audioQuality,
            isDark: isDark,
            cs: cs,
            onChanged: _setQuality,
          ),

          const SizedBox(height: 24),

          // ── 4. Toggle switches ─────────────────────────────────────
          _SectionHeader(
            label: 'Playback Options',
            icon: Icons.tune_rounded,
            cs: cs,
          ),
          const SizedBox(height: 10),
          _ToggleCard(
            icon: Icons.headphones_rounded,
            title: 'Background Playback',
            subtitle: 'Keep playing when the app is minimised',
            value: _bgPlayback,
            cs: cs,
            isDark: isDark,
            onChanged: _setBgPlayback,
          ),
          const SizedBox(height: 8),
          _ToggleCard(
            icon: Icons.replay_rounded,
            title: 'Auto-Resume',
            subtitle: 'Resume playback after calls or notifications',
            value: _autoResume,
            cs: cs,
            isDark: isDark,
            onChanged: _setAutoResume,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ReciterHorizontalList
// Horizontal scrollable list of reciter cards.
// Each card: avatar, name, country, downloaded badge, download-all button.
// ─────────────────────────────────────────────────────────────────────────────

class _ReciterHorizontalList extends StatelessWidget {
  final String currentId;
  final bool isDark;
  final ColorScheme cs;
  final void Function(FullReciterMeta) onSelect;

  const _ReciterHorizontalList({
    required this.currentId,
    required this.isDark,
    required this.cs,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: kAllReciters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _ReciterCard(
          meta: kAllReciters[i],
          isSelected: kAllReciters[i].id == currentId,
          isDark: isDark,
          cs: cs,
          onSelect: onSelect,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ReciterCard — single card in the horizontal list
// ─────────────────────────────────────────────────────────────────────────────

class _ReciterCard extends StatefulWidget {
  final FullReciterMeta meta;
  final bool isSelected;
  final bool isDark;
  final ColorScheme cs;
  final void Function(FullReciterMeta) onSelect;

  const _ReciterCard({
    required this.meta,
    required this.isSelected,
    required this.isDark,
    required this.cs,
    required this.onSelect,
  });

  @override
  State<_ReciterCard> createState() => _ReciterCardState();
}

class _ReciterCardState extends State<_ReciterCard> {
  final _mgr = ReciterDownloadManager.instance;

  @override
  void initState() {
    super.initState();
    _refreshDownloadedCount();
  }

  Future<void> _refreshDownloadedCount() async {
    final entries = await AudioCacheManager.instance.getDownloadedForReciter(
      widget.meta.id,
    );
    if (mounted) {
      // Always sync from DB so the count is accurate when the page opens.
      _mgr.downloaded[widget.meta.id] = entries.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.meta;
    final cs = widget.cs;
    final isDark = widget.isDark;
    final isSelected = widget.isSelected;

    return Obx(() {
      final isRunning = _mgr.isRunning(m.id);
      final prog = _mgr.progress[m.id] ?? 0.0;
      final dlCount = _mgr.downloaded[m.id] ?? 0;
      final pct = dlCount / 114;

      return GestureDetector(
        onTap: () => widget.onSelect(m),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 140,
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                      ? m.colorA.withValues(alpha: 0.22)
                      : m.colorA.withValues(alpha: 0.10))
                : (isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : cs.secondary),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? m.colorA.withValues(alpha: 0.55)
                  : cs.primary.withValues(alpha: 0.10),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: m.colorA.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar + selected check
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _ReciterAvatar(reciterId: m.id, size: 56),
                  if (isSelected)
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: m.colorA,
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.secondary, width: 2),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),

              // Name
              Text(
                m.displayName,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Country badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 10,
                    color: m.colorA.withValues(alpha: 0.70),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    m.country,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 9,
                      color: cs.primary.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),

              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$dlCount/114',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 9,
                          color: dlCount > 0
                              ? m.colorA
                              : cs.primary.withValues(alpha: 0.40),
                        ),
                      ),
                      if (dlCount == 114)
                        Icon(
                          Icons.offline_bolt_rounded,
                          size: 11,
                          color: m.colorA,
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: isRunning ? prog : pct,
                      minHeight: 4,
                      backgroundColor: cs.primary.withValues(alpha: 0.10),
                      valueColor: AlwaysStoppedAnimation(
                        dlCount == 114 ? m.colorA : m.colorB,
                      ),
                    ),
                  ),
                ],
              ),

              // Download / cancel button
              isRunning
                  ? GestureDetector(
                      onTap: () => _mgr.cancelBulkDownload(m.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: m.colorA.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: m.colorA.withValues(alpha: 0.30),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 9,
                              height: 9,
                              child: CircularProgressIndicator(
                                value: prog > 0 ? prog : null,
                                strokeWidth: 1.5,
                                color: m.colorA,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${(prog * 114).toInt()}/114',
                              style: TextStyle(
                                fontFamily: 'kufi',
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: m.colorA,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.close_rounded,
                              size: 10,
                              color: m.colorA.withValues(alpha: 0.70),
                            ),
                          ],
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: dlCount < 114
                          ? () => _mgr.startBulkDownload(
                              m.id,
                              reciterName: m.displayName,
                            )
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: dlCount == 114
                              ? m.colorA.withValues(alpha: 0.12)
                              : m.colorA.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: m.colorA.withValues(alpha: 0.30),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              dlCount == 114
                                  ? Icons.check_rounded
                                  : Icons.download_rounded,
                              size: 11,
                              color: m.colorA,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              dlCount == 114 ? 'Complete' : 'Download All',
                              style: TextStyle(
                                fontFamily: 'kufi',
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: m.colorA,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SpeedSelector — pill chips for playback speed
// ─────────────────────────────────────────────────────────────────────────────

class _SpeedSelector extends StatelessWidget {
  final double speed;
  final bool isDark;
  final ColorScheme cs;
  final void Function(double) onChanged;

  const _SpeedSelector({
    required this.speed,
    required this.isDark,
    required this.cs,
    required this.onChanged,
  });

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
  static const _labels = [
    '0.5×',
    '0.75×',
    '1×',
    '1.25×',
    '1.5×',
    '1.75×',
    '2×',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? cs.primary.withValues(alpha: 0.07)
            : cs.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.10)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current speed',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 12,
                  color: cs.primary.withValues(alpha: 0.60),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${speed == speed.roundToDouble() ? speed.toInt() : speed}×',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_speeds.length, (i) {
              final s = _speeds[i];
              final selected = (speed - s).abs() < 0.01;
              return GestureDetector(
                onTap: () => onChanged(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? cs.primary
                        : cs.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? cs.primary
                          : cs.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    _labels[i],
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? (isDark ? cs.secondary : Colors.white)
                          : cs.primary,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _QualitySelector
// ─────────────────────────────────────────────────────────────────────────────

class _QualitySelector extends StatelessWidget {
  final String quality;
  final bool isDark;
  final ColorScheme cs;
  final void Function(String) onChanged;

  const _QualitySelector({
    required this.quality,
    required this.isDark,
    required this.cs,
    required this.onChanged,
  });

  static const _opts = [
    ('low', 'Low', '64 kbps', Icons.signal_cellular_alt_1_bar_rounded),
    ('medium', 'Medium', '128 kbps', Icons.signal_cellular_alt_2_bar_rounded),
    ('high', 'High', '192 kbps', Icons.signal_cellular_alt_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? cs.primary.withValues(alpha: 0.07)
            : cs.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.10)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: _opts.map((opt) {
          final (id, label, bitrate, icon) = opt;
          final selected = quality == id;
          return GestureDetector(
            onTap: () => onChanged(id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? cs.primary.withValues(alpha: isDark ? 0.20 : 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? cs.primary.withValues(alpha: 0.45)
                      : cs.primary.withValues(alpha: 0.08),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: selected
                        ? cs.primary
                        : cs.primary.withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cs.primary,
                          ),
                        ),
                        Text(
                          bitrate,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 10,
                            color: cs.primary.withValues(alpha: 0.50),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check_circle_rounded,
                      color: cs.primary,
                      size: 18,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ToggleCard
// ─────────────────────────────────────────────────────────────────────────────

class _ToggleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ColorScheme cs;
  final bool isDark;
  final void Function(bool) onChanged;

  const _ToggleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.cs,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: value
            ? (isDark
                  ? cs.primary.withValues(alpha: 0.12)
                  : cs.primary.withValues(alpha: 0.06))
            : (isDark ? Colors.white.withValues(alpha: 0.03) : cs.secondary),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? cs.primary.withValues(alpha: 0.30)
              : cs.primary.withValues(alpha: 0.09),
          width: value ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: value
                ? cs.primary.withValues(alpha: 0.12)
                : cs.primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: value ? cs.primary : cs.primary.withValues(alpha: 0.50),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.primary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 10,
            color: cs.primary.withValues(alpha: 0.50),
          ),
        ),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: cs.primary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SectionHeader
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final ColorScheme cs;

  const _SectionHeader({
    required this.label,
    required this.icon,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.primary.withValues(alpha: 0.70)),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: cs.primary,
          ),
        ),
      ],
    );
  }
}
