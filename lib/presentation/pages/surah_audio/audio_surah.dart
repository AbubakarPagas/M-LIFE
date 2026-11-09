part of 'surah_audio.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Audio Screen — main entry point
// ─────────────────────────────────────────────────────────────────────────────

class AudioScreen extends StatelessWidget {
  const AudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Wire the bulk-download notification callbacks once (idempotent).
    _BulkFlnNotifier.register();

    final ctrl = AudioCtrl.instance;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (didPop) return;
        // Stop playback and dismiss the media notification in one call.
        _SurahPlaybackNotifier.cancel();
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: cs.secondary,
        body: Stack(
          children: [
            // ── Subtle geometric background ─────────────────────────
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.04 : 0.03,
                child: CustomPaint(painter: _IslamicBgPainter(cs.primary)),
              ),
            ),

            // ── Main content ────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  // ── App bar ──────────────────────────────────────
                  _AudioAppBar(),
                  // ── Surah list ───────────────────────────────────
                  Expanded(child: SurahAudioList()),
                ],
              ),
            ),

            // ── Floating player card (bottom) ────────────────────
            const Align(
              alignment: Alignment.bottomCenter,
              child: _FloatingPlayerCard(),
            ),
          ],
        ),
      ),
    );
  }

  bool get wantKeepAlive => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// App bar
// ─────────────────────────────────────────────────────────────────────────────

class _AudioAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Back button
          _CircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () {
              _SurahPlaybackNotifier.cancel();
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          // Title
          Column(
            children: [
              Text(
                'quranAudio'.tr,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
              Text(
                'listenToQuran'.tr.isEmpty
                    ? 'القرآن الكريم'
                    : 'listenToQuran'.tr,
                style: TextStyle(
                  fontFamily: 'naskh',
                  fontSize: 12,
                  color: cs.primary.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Full-screen player button (only when playing)
          Obx(() {
            final isPlaying = AudioCtrl.instance.state.isPlaying.value;
            return isPlaying
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _CircleButton(
                      icon: Icons.open_in_full_rounded,
                      onTap: () => Get.to(
                        () => const AudioSurahWithAyahs(),
                        transition: Transition.fadeIn,
                        binding: BindingsBuilder(() {
                          Get.put(AudioSurahWithAyahsController());
                        }),
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }),
          // Storage button
          _CircleButton(
            icon: Icons.folder_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AudioStorageScreen()),
            ),
          ),
          const SizedBox(width: 8),
          // Audio settings button
          _CircleButton(
            icon: Icons.tune_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AudioSettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating player card — collapses / expands
// Redesigned: gradient based on active reciter color + reciter avatar visible
// ─────────────────────────────────────────────────────────────────────────────

class _FloatingPlayerCard extends StatelessWidget {
  const _FloatingPlayerCard();

  @override
  Widget build(BuildContext context) {
    final ctrl = AudioCtrl.instance;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final expanded = ctrl.surahState.isPlayExpanded.value;
      final reciterId = currentReciterIdObs.value;
      final meta = _metaFor(reciterId);

      // Blend reciter accent color with the theme primary for the card.
      final cardColorA = Color.lerp(cs.primary, meta.colorA, 0.55)!;
      final cardColorB = Color.lerp(cs.primary, meta.colorB, 0.35)!;
      final baseColor = isDark
          ? Color.lerp(cardColorA, Colors.black, 0.30)!
          : cardColorA;

      return GestureDetector(
        onVerticalDragUpdate: (d) {
          if (d.primaryDelta == null) return;
          if (d.primaryDelta! < -8) ctrl.surahState.isPlayExpanded.value = true;
          if (d.primaryDelta! > 8) ctrl.surahState.isPlayExpanded.value = false;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                baseColor,
                isDark
                    ? Color.lerp(cardColorB, Colors.black, 0.25)!
                    : cardColorB,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: cardColorA.withValues(alpha: 0.45),
                blurRadius: 28,
                spreadRadius: -2,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              children: [
                // Subtle Islamic pattern overlay on the card
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.05,
                    child: CustomPaint(
                      painter: _IslamicBgPainter(Colors.white),
                    ),
                  ),
                ),
                // Top highlight shimmer line
                Positioned(
                  top: 0,
                  left: 24,
                  right: 24,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.30),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Actual player content
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 280),
                  reverseDuration: const Duration(milliseconds: 220),
                  crossFadeState: expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const CollapsedPlayWidget(),
                  secondChild: const PlayWidget(),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small helpers
// ─────────────────────────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary.withValues(alpha: 0.12)),
        ),
        child: Icon(icon, color: cs.primary, size: 18),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Islamic geometric background painter (same as home page)
// ─────────────────────────────────────────────────────────────────────────────

class _IslamicBgPainter extends CustomPainter {
  final Color color;
  _IslamicBgPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 52.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        final c = Offset(x, y);
        const r = 14.0;
        for (int i = 0; i < 8; i++) {
          final a = (i * 3.14159 * 2) / 8;
          final ia = a + (3.14159 / 8);
          canvas.drawLine(
            Offset(c.dx + r * _c(a), c.dy + r * _s(a)),
            Offset(c.dx + r * 0.45 * _c(ia), c.dy + r * 0.45 * _s(ia)),
            paint,
          );
        }
      }
    }
  }

  double _c(double a) {
    double x = a % (2 * 3.14159265);
    return 1 - (x * x) / 2 + (x * x * x * x) / 24;
  }

  double _s(double a) {
    double x = a % (2 * 3.14159265);
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }

  @override
  bool shouldRepaint(_IslamicBgPainter o) => o.color != color;
}
