part of '../surah_audio.dart';

/// Returns the metadata for a reciter ID.
/// Looks up [kAllReciters] first; falls back to a hash-derived colour if unknown.
FullReciterMeta _metaFor(String reciterId) {
  // Fast lookup from the known list.
  for (final r in kAllReciters) {
    if (r.id == reciterId) return r;
  }
  // Fallback: derive a colour from the hash of the ID.
  final hash = reciterId.hashCode.abs();
  const fallbackColors = [
    [Color(0xff1A237E), Color(0xff7986CB)],
    [Color(0xff1B5E20), Color(0xff81C784)],
    [Color(0xff4A148C), Color(0xffBA68C8)],
    [Color(0xffE65100), Color(0xffFFB74D)],
    [Color(0xff006064), Color(0xff4DB6AC)],
  ];
  final pair = fallbackColors[hash % fallbackColors.length];
  final initial = reciterId.isNotEmpty ? reciterId[0].toUpperCase() : '?';
  return FullReciterMeta(
    id: reciterId,
    displayName: reciterId,
    initial: initial,
    colorA: pair[0],
    colorB: pair[1],
    country: '',
    url: '',
    routeName: '',
    img: '',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// _ReciterAvatar — circular gradient avatar with Arabic initial
// ─────────────────────────────────────────────────────────────────────────────

class _ReciterAvatar extends StatelessWidget {
  final String reciterId;
  final double size;

  const _ReciterAvatar({required this.reciterId, this.size = 52});

  @override
  Widget build(BuildContext context) {
    final meta = _metaFor(reciterId);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [meta.colorA, meta.colorB],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: meta.colorA.withValues(alpha: 0.40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          meta.initial,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: size * 0.40,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            shadows: const [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AudioStorageScreen
// ─────────────────────────────────────────────────────────────────────────────

class AudioStorageScreen extends StatelessWidget {
  const AudioStorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = AudioCtrl.instance;

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
          'audioStorage'.tr,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: cs.primary,
          ),
        ),
      ),
      body: StreamBuilder<List<AudioCacheEntry>>(
        stream: ctrl.watchDownloadedSurahs(),
        builder: (context, snapshot) {
          final entries = snapshot.data ?? [];
          final Map<String, List<AudioCacheEntry>> byReciter = {};
          for (final e in entries) {
            byReciter.putIfAbsent(e.reciterId, () => []).add(e);
          }
          for (final list in byReciter.values) {
            list.sort((a, b) => a.surahId.compareTo(b.surahId));
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _StorageSummaryCard(
                  entries: entries,
                  cs: cs,
                  isDark: isDark,
                ),
              ),
              // ── Active bulk-download banners ────────────────────────
              SliverToBoxAdapter(
                child: _ActiveDownloadsBanner(cs: cs, isDark: isDark),
              ),
              if (entries.isEmpty)
                SliverFillRemaining(child: _EmptyState(cs: cs))
              else ...[
                for (final reciterId in byReciter.keys)
                  _ReciterSection(
                    reciterId: reciterId,
                    entries: byReciter[reciterId]!,
                    cs: cs,
                    isDark: isDark,
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ReciterSection — collapsible card with avatar header
// ─────────────────────────────────────────────────────────────────────────────

class _ReciterSection extends StatefulWidget {
  final String reciterId;
  final List<AudioCacheEntry> entries;
  final ColorScheme cs;
  final bool isDark;

  const _ReciterSection({
    required this.reciterId,
    required this.entries,
    required this.cs,
    required this.isDark,
  });

  @override
  State<_ReciterSection> createState() => _ReciterSectionState();
}

class _ReciterSectionState extends State<_ReciterSection> {
  bool _expanded = true;

  FullReciterMeta get _meta => _metaFor(widget.reciterId);

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  int get _totalBytes => widget.entries.fold(
    0,
    (s, e) => s + (e.fileSizeBytes > 0 ? e.fileSizeBytes : 0),
  );

  // Prefer the live GetStorage name if the reciter is the currently active one.
  String get _displayName {
    final storedId = GetStorage().read<String>(SURAH_AUDIO_PLAYER_SOUND);
    if (storedId == widget.reciterId) {
      final stored = GetStorage().read<String>(SURAH_AUDIO_PLAYER_NAME);
      if (stored != null && stored.isNotEmpty) return stored;
    }
    return _meta.displayName;
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;
    final isDark = widget.isDark;
    final meta = _meta;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        decoration: BoxDecoration(
          color: isDark
              ? cs.primary.withValues(alpha: 0.07)
              : cs.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.primary.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Material(
              color: Colors.transparent,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: InkWell(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
                  child: Row(
                    children: [
                      // Reciter avatar with unique gradient + initial
                      _ReciterAvatar(reciterId: widget.reciterId, size: 52),
                      const SizedBox(width: 14),
                      // Name and stats
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _displayName,
                              style: TextStyle(
                                fontFamily: 'kufi',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: cs.primary,
                              ),
                              textDirection: TextDirection.rtl,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Obx(() {
                              final mgr = ReciterDownloadManager.instance;
                              final isRunning = mgr.isRunning(widget.reciterId);
                              final prog =
                                  mgr.progress[widget.reciterId] ?? 0.0;
                              final dlCount = mgr.downloaded[widget.reciterId];

                              if (isRunning) {
                                // Show live progress bar in section header.
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 10,
                                          height: 10,
                                          child: CircularProgressIndicator(
                                            value: prog > 0 ? prog : null,
                                            strokeWidth: 1.5,
                                            color: meta.colorA,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Downloading ${(prog * 114).toInt()}/114',
                                          style: TextStyle(
                                            fontFamily: 'kufi',
                                            fontSize: 10,
                                            color: meta.colorA,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () => mgr.cancelBulkDownload(
                                            widget.reciterId,
                                          ),
                                          child: Icon(
                                            Icons.close_rounded,
                                            size: 12,
                                            color: Colors.redAccent.withValues(
                                              alpha: 0.70,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                        value: prog,
                                        minHeight: 3,
                                        backgroundColor: cs.primary.withValues(
                                          alpha: 0.10,
                                        ),
                                        valueColor: AlwaysStoppedAnimation(
                                          meta.colorA,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  _MiniChip(
                                    label:
                                        '${widget.entries.length} ${'surah'.tr}',
                                    colorA: meta.colorA,
                                    colorB: meta.colorB,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 6),
                                  _MiniChip(
                                    label: _formatBytes(_totalBytes),
                                    colorA: meta.colorB,
                                    colorB: meta.colorA,
                                    isDark: isDark,
                                    isSize: true,
                                  ),
                                  if (dlCount != null && dlCount < 114)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: GestureDetector(
                                        onTap: () => mgr.startBulkDownload(
                                          widget.reciterId,
                                          reciterName: _displayName,
                                        ),
                                        child: _MiniChip(
                                          label: 'Download All',
                                          colorA: meta.colorA,
                                          colorB: meta.colorB,
                                          isDark: isDark,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                      // Delete all for this reciter
                      IconButton(
                        icon: Icon(
                          Icons.delete_sweep_rounded,
                          size: 20,
                          color: Colors.redAccent.withValues(alpha: 0.70),
                        ),
                        tooltip: 'clearAllCache'.tr,
                        onPressed: () => _confirmDeleteAll(context),
                      ),
                      // Collapse chevron
                      AnimatedRotation(
                        turns: _expanded ? 0.0 : -0.25,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          Icons.expand_more_rounded,
                          color: cs.primary.withValues(alpha: 0.45),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ── Surah list ────────────────────────────────────────────
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 260),
              crossFadeState: _expanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Column(
                children: [
                  Divider(height: 1, color: cs.primary.withValues(alpha: 0.08)),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    itemCount: widget.entries.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: cs.primary.withValues(alpha: 0.06),
                    ),
                    itemBuilder: (_, i) => _DownloadedSurahTile(
                      entry: widget.entries[i],
                      accentColor: meta.colorA,
                      cs: cs,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    final cs = widget.cs;
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cs.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'clearAllCache'.tr,
          style: TextStyle(fontFamily: 'kufi', color: cs.primary),
          textDirection: TextDirection.rtl,
        ),
        content: Text(
          _displayName,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 13,
            color: cs.primary.withValues(alpha: 0.75),
          ),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'cancel'.tr,
              style: TextStyle(fontFamily: 'kufi', color: cs.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(fontFamily: 'kufi', color: Colors.redAccent),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        for (final e in widget.entries) {
          AudioCacheManager.instance.deleteCachedSurah(e.surahId, e.reciterId);
        }
      }
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MiniChip — coloured pill in the section header
// ─────────────────────────────────────────────────────────────────────────────

class _MiniChip extends StatelessWidget {
  final String label;
  final Color colorA;
  final Color colorB;
  final bool isDark;
  final bool isSize;

  const _MiniChip({
    required this.label,
    required this.colorA,
    required this.colorB,
    required this.isDark,
    this.isSize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorA.withValues(alpha: isDark ? 0.28 : 0.14),
            colorB.withValues(alpha: isDark ? 0.18 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorA.withValues(alpha: 0.30), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'kufi',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isDark ? colorB : colorA,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StorageSummaryCard
// ─────────────────────────────────────────────────────────────────────────────

class _StorageSummaryCard extends StatelessWidget {
  final List<AudioCacheEntry> entries;
  final ColorScheme cs;
  final bool isDark;

  const _StorageSummaryCard({
    required this.entries,
    required this.cs,
    required this.isDark,
  });

  String _fmt(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  int get _totalBytes => entries.fold(
    0,
    (s, e) => s + (e.fileSizeBytes > 0 ? e.fileSizeBytes : 0),
  );

  int get _reciterCount {
    final seen = <String>{};
    for (final e in entries) seen.add(e.reciterId);
    return seen.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? cs.primary.withValues(alpha: 0.12)
            : cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storage_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'audioStorage'.tr,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(
                label: 'totalDownloaded'.tr,
                value: entries.length.toString(),
                cs: cs,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'reciters'.tr.isEmpty ? 'قارئ' : 'reciters'.tr,
                value: _reciterCount.toString(),
                cs: cs,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'storageUsed'.tr,
                value: _fmt(_totalBytes),
                cs: cs,
                isDark: isDark,
              ),
            ],
          ),
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmClearAll(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent, width: 0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                label: Text(
                  'clearAllCache'.tr,
                  style: const TextStyle(fontFamily: 'kufi', fontSize: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cs.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'clearAllCache'.tr,
          style: TextStyle(fontFamily: 'kufi', color: cs.primary),
          textDirection: TextDirection.rtl,
        ),
        content: Text(
          'clearAllCacheConfirm'.tr,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 13,
            color: cs.primary.withValues(alpha: 0.75),
          ),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'cancel'.tr,
              style: TextStyle(fontFamily: 'kufi', color: cs.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(fontFamily: 'kufi', color: Colors.redAccent),
            ),
          ),
        ],
      ),
    ).then((ok) {
      if (ok == true) AudioCtrl.instance.clearAllAudioCache();
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatChip
// ─────────────────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;
  final bool isDark;

  const _StatChip({
    required this.label,
    required this.value,
    required this.cs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 9,
                color: cs.primary.withValues(alpha: 0.60),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DownloadedSurahTile
// ─────────────────────────────────────────────────────────────────────────────

class _DownloadedSurahTile extends StatelessWidget {
  final AudioCacheEntry entry;
  final Color accentColor;
  final ColorScheme cs;
  final bool isDark;

  const _DownloadedSurahTile({
    required this.entry,
    required this.accentColor,
    required this.cs,
    required this.isDark,
  });

  String _fmt(int bytes) {
    if (bytes <= 0) return '—';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _fmtDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final surahs = QuranController.instance.state.surahs;
    final surahName = (entry.surahId > 0 && entry.surahId <= surahs.length)
        ? surahs[entry.surahId - 1].arabicName
        : 'Surah ${entry.surahId}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Number badge using reciter accent color
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.25),
                width: 0.8,
              ),
            ),
            child: Center(
              child: Text(
                entry.surahId.toString().convertNumbersToCurrentLang(),
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surahName,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_fmt(entry.fileSizeBytes)} • ${_fmtDate(entry.downloadedAt)}',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10,
                    color: cs.primary.withValues(alpha: 0.50),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _confirmDelete(context),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.20),
                  width: 0.8,
                ),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                size: 15,
                color: Colors.redAccent.withValues(alpha: 0.80),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cs.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'deleteCachedAudio'.tr,
          style: TextStyle(fontFamily: 'kufi', color: cs.primary),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'cancel'.tr,
              style: TextStyle(fontFamily: 'kufi', color: cs.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(fontFamily: 'kufi', color: Colors.redAccent),
            ),
          ),
        ],
      ),
    ).then((ok) {
      if (ok == true) {
        AudioCacheManager.instance.deleteCachedSurah(
          entry.surahId,
          entry.reciterId,
        );
      }
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ActiveDownloadsBanner
// Shows a compact banner for every reciter currently bulk-downloading.
// Visible at the top of AudioStorageScreen so the user can monitor / cancel.
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveDownloadsBanner extends StatelessWidget {
  final ColorScheme cs;
  final bool isDark;

  const _ActiveDownloadsBanner({required this.cs, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final mgr = ReciterDownloadManager.instance;

    return Obx(() {
      final running = mgr.progress.keys.toList();
      if (running.isEmpty) return const SizedBox.shrink();

      return Column(
        children: running.map((reciterId) {
          final prog = mgr.progress[reciterId] ?? 0.0;
          final meta = _metaFor(reciterId);
          // _metaFor already resolves from kAllReciters; use it directly.

          return Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: BoxDecoration(
              color: isDark
                  ? meta.colorA.withValues(alpha: 0.14)
                  : meta.colorA.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: meta.colorA.withValues(alpha: 0.30),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Small avatar
                    _ReciterAvatar(reciterId: reciterId, size: 34),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meta.displayName,
                            style: TextStyle(
                              fontFamily: 'kufi',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Downloading ${(prog * 114).toInt()} / 114 surahs',
                            style: TextStyle(
                              fontFamily: 'kufi',
                              fontSize: 10,
                              color: meta.colorA,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Percentage badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: meta.colorA.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(prog * 100).toInt()}%',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: meta.colorA,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Cancel button
                    GestureDetector(
                      onTap: () => mgr.cancelBulkDownload(reciterId),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.redAccent.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Colors.redAccent.withValues(alpha: 0.80),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: prog,
                    minHeight: 5,
                    backgroundColor: cs.primary.withValues(alpha: 0.10),
                    valueColor: AlwaysStoppedAnimation(meta.colorA),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EmptyState
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final ColorScheme cs;
  const _EmptyState({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.download_done_rounded,
            size: 64,
            color: cs.primary.withValues(alpha: 0.20),
          ),
          const SizedBox(height: 16),
          Text(
            'noDownloadsYet'.tr,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 15,
              color: cs.primary.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'downloadHintText'.tr,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 12,
              color: cs.primary.withValues(alpha: 0.30),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
