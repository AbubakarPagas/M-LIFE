part of '../surah_audio.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SurahCacheDownloadButton
//
// Shows the download / cached / downloading state for a single surah.
// Automatically re-checks the cache when the user switches reader because it
// observes [currentReciterIdObs].
// ─────────────────────────────────────────────────────────────────────────────

class SurahCacheDownloadButton extends StatefulWidget {
  final int surahNumber;
  const SurahCacheDownloadButton({super.key, required this.surahNumber});

  @override
  State<SurahCacheDownloadButton> createState() =>
      _SurahCacheDownloadButtonState();
}

class _SurahCacheDownloadButtonState extends State<SurahCacheDownloadButton> {
  final _ctrl = AudioCtrl.instance;
  bool _isCached = false;
  bool _isLoading = true;
  DownloadTask? _task;

  // Track the reciter we last checked so we know when it changes.
  String _lastCheckedReciter = '';

  @override
  void initState() {
    super.initState();
    _checkCache();
  }

  @override
  void didUpdateWidget(SurahCacheDownloadButton old) {
    super.didUpdateWidget(old);
    if (old.surahNumber != widget.surahNumber) _checkCache();
  }

  Future<void> _checkCache() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final cached = await _ctrl.isSurahCached(widget.surahNumber);
    final task = _ctrl.activeDownloadTask(widget.surahNumber);
    _lastCheckedReciter = _ctrl._currentReciterId;
    if (mounted) {
      setState(() {
        _isCached = cached;
        _task = task;
        _isLoading = false;
      });
    }
  }

  Future<void> _onTap() async {
    final cs = Theme.of(context).colorScheme;

    // ── Already cached: offer delete ──────────────────────────────────────
    if (_isCached) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: cs.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'deleteCachedAudio'.tr,
            style: TextStyle(fontFamily: 'kufi', color: cs.primary),
            textDirection: TextDirection.rtl,
          ),
          content: Text(
            'deleteCachedAudioConfirm'.tr,
            style: TextStyle(
              fontFamily: 'kufi',
              color: cs.primary.withValues(alpha: 0.75),
              fontSize: 13,
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
              child: Text(
                'delete'.tr,
                style: const TextStyle(
                  fontFamily: 'kufi',
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      );
      if (confirmed == true && mounted) {
        await _ctrl.deleteCachedSurah(widget.surahNumber);
        _checkCache();
      }
      return;
    }

    // ── Active download: cancel ───────────────────────────────────────────
    if (_task != null && _task!.status.value == 'downloading') {
      await _ctrl.cancelSurahDownload(widget.surahNumber);
      if (mounted) setState(() => _task = null);
      return;
    }

    // ── Failed: retry ──────────────────────────────────────────────────────
    if (_task != null && _task!.status.value == 'failed') {
      final newTask = await _ctrl.retryFailedDownload(widget.surahNumber);
      if (mounted) {
        setState(() => _task = newTask);
        _listenTask(newTask);
      }
      return;
    }

    // ── Start new download ────────────────────────────────────────────────
    final newTask = await _ctrl.startSurahDownload(widget.surahNumber);
    if (mounted) {
      setState(() => _task = newTask);
      _listenTask(newTask);
    }
  }

  void _listenTask(DownloadTask task) {
    ever(task.status, (String s) {
      if (s == 'completed' || s == 'failed' || s == 'cancelled') {
        _checkCache();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Observe the reactive reciter ID — re-check cache when it changes.
    return Obx(() {
      final reciterId = currentReciterIdObs.value;
      if (reciterId != _lastCheckedReciter && !_isLoading) {
        // Schedule a cache re-check without calling setState during build.
        WidgetsBinding.instance.addPostFrameCallback((_) => _checkCache());
      }

      if (_isLoading) {
        return const SizedBox(
          width: 32,
          height: 32,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ),
        );
      }

      // ── Cached: green check ─────────────────────────────────────────────
      if (_isCached) {
        return Tooltip(
          message: 'availableOffline'.tr,
          child: GestureDetector(
            onTap: _onTap,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xff5C7A5B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xff5C7A5B).withValues(alpha: 0.40),
                ),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xff5C7A5B),
                size: 16,
              ),
            ),
          ),
        );
      }

      // ── Active download: progress circle ────────────────────────────────
      if (_task != null) {
        return Obx(() {
          final status = _task!.status.value;
          final progress = _task!.progress.value;

          if (status == 'failed') {
            return Tooltip(
              message: 'retryDownload'.tr,
              child: GestureDetector(
                onTap: _onTap,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.redAccent,
                    size: 16,
                  ),
                ),
              ),
            );
          }

          return Tooltip(
            message: 'cancelDownload'.tr,
            child: GestureDetector(
              onTap: _onTap,
              child: SizedBox(
                width: 32,
                height: 32,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress > 0 ? progress : null,
                      strokeWidth: 2.5,
                      color: cs.primary,
                      backgroundColor: cs.primary.withValues(alpha: 0.15),
                    ),
                    Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: cs.primary.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      }

      // ── Not downloaded: download icon ───────────────────────────────────
      return Tooltip(
        message: 'downloadSurah'.tr,
        child: GestureDetector(
          onTap: _onTap,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.primary.withValues(alpha: 0.20)),
            ),
            child: Icon(
              Icons.download_rounded,
              color: cs.primary.withValues(alpha: 0.70),
              size: 16,
            ),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OfflineBadge — shown inline in surah tiles when the surah is cached
// ─────────────────────────────────────────────────────────────────────────────

class OfflineBadge extends StatelessWidget {
  const OfflineBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xff5C7A5B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xff5C7A5B).withValues(alpha: 0.30),
          width: 0.7,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.offline_bolt_rounded,
            size: 9,
            color: Color(0xff5C7A5B),
          ),
          const SizedBox(width: 3),
          Text(
            'offline'.tr,
            style: const TextStyle(
              fontFamily: 'kufi',
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Color(0xff5C7A5B),
            ),
          ),
        ],
      ),
    );
  }
}
