import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/constants/lottie_constants.dart';
import '../../../helpers/gps_location_helper.dart';
import '../../../provider/dependencies/AdhanDependencyProvider.dart';
import '../../../provider/dependencies/GlobalDependencyProvider.dart';
import '../../../provider/locationProvider.dart';

// ─── Duration constants ───────────────────────────────────────────────────────
const _pageDuration = Duration(milliseconds: 500);
const _fadeDuration = Duration(milliseconds: 350);

// ─── Islamic color tokens ─────────────────────────────────────────────────────
const _primaryDeep = Color(0xFF2E3850);
const _primary = Color(0xFF404C6E);
const _gold = Color(0xFFCDAD80);
const _bgWhite = Color(0xFFFFFFFF);

// ─── Welcome Screen ───────────────────────────────────────────────────────────

class WelcomeScreen extends StatefulWidget {
  final bool showWarning;
  final String build;

  const WelcomeScreen({
    super.key,
    required this.showWarning,
    required this.build,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  int _currentPage = 0;
  final _pageCtrl = PageController();

  // Ambient rotation for the ornament
  late final AnimationController _ornamentCtrl;
  late final Animation<double> _ornamentAnim;

  // Page content entrance
  late final AnimationController _contentCtrl;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _ornamentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    _ornamentAnim = Tween<double>(begin: 0, end: 1).animate(_ornamentCtrl);

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic),
        );

    _contentCtrl.forward();
  }

  @override
  void dispose() {
    _ornamentCtrl.dispose();
    _contentCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _nextPage(int total) {
    if (_currentPage < total - 1) {
      _pageCtrl.animateToPage(
        _currentPage + 1,
        duration: _pageDuration,
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _skipToEnd(int total, LocationState locationState) {
    final target = locationState is LocationAvailable ? total - 1 : total - 3;
    _pageCtrl.animateToPage(
      target.clamp(0, total - 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _triggerContentAnim() {
    _contentCtrl.reset();
    _contentCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final globalProvider = context.watch<GlobalDependencyProvider>();
    final adhanDep = context.watch<AdhanDependencyProvider>();
    final locationProvider = context.watch<LocationProvider>();
    final locationState = locationProvider.locationState;

    final pages = _buildPages(
      context,
      adhanDep: adhanDep,
      locationProvider: locationProvider,
      locationState: locationState,
    );
    final total = pages.length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _bgWhite,
        body: Stack(
          children: [
            // ── Animated ornamental background ──────────────────────────
            const Positioned.fill(child: _AmbientBackground()),

            // ── Rotating geometric overlay ───────────────────────────────
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ornamentAnim,
                builder: (_, __) => CustomPaint(
                  painter: _OrnamentsBackgroundPainter(
                    progress: _ornamentAnim.value,
                  ),
                ),
              ),
            ),

            // ── Pages ────────────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageCtrl,
                      physics: const BouncingScrollPhysics(),
                      itemCount: total,
                      onPageChanged: (i) {
                        setState(() => _currentPage = i);
                        _triggerContentAnim();
                      },
                      itemBuilder: (_, i) => FadeTransition(
                        opacity: i == _currentPage
                            ? _contentFade
                            : const AlwaysStoppedAnimation(1.0),
                        child: SlideTransition(
                          position: i == _currentPage
                              ? _contentSlide
                              : const AlwaysStoppedAnimation(Offset.zero),
                          child: pages[i],
                        ),
                      ),
                    ),
                  ),

                  // ── Navigation bar ────────────────────────────────────
                  _NavBar(
                    currentPage: _currentPage,
                    total: total,
                    onNext: () => _nextPage(total),
                    onSkip: () => _skipToEnd(total, locationState),
                    onDone: () => globalProvider.welcomeComplete(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPages(
    BuildContext context, {
    required AdhanDependencyProvider adhanDep,
    required LocationProvider locationProvider,
    required LocationState locationState,
  }) {
    return [
      if (widget.showWarning)
        _WelcomePage(
          topOrnament: const _TopCrescentOrnament(color: Colors.amber),
          arabicTitle: '⚠',
          englishTitle: '${widget.build} Build',
          subtitle:
              'Thank you for testing this build. Bugs may exist — feedback is appreciated.',
          visual: const Icon(
            Icons.warning_amber_rounded,
            size: 96,
            color: Colors.amber,
          ),
        ),

      // ── Page 1 : As-salamu alaykum ───────────────────────────────────
      const _WelcomePage(
        topOrnament: _TopCrescentOrnament(color: _gold),
        arabicTitle: 'السَّلامُ عَلَيكُم',
        englishTitle: 'As-Salamu Alaykum',
        subtitle:
            'Welcome to your complete Islamic companion — Quran, Prayer, Dhikr and more.',
        visual: _AppLogoVisual(),
      ),

      // ── Page 2 : Features ────────────────────────────────────────────
      const _WelcomePage(
        topOrnament: _TopCrescentOrnament(color: _gold),
        arabicTitle: 'مَا تَجِدُ هُنَا',
        englishTitle: 'Everything You Need',
        subtitle:
            'Prayer times, Qibla direction, Quran audio, Adhkar, Tasbih, Names of Allah and a full Tafsir library.',
        visual: _FeaturesVisual(),
      ),

      // ── Page 3 : Location ────────────────────────────────────────────
      _WelcomePage(
        topOrnament: const _TopCrescentOrnament(color: _gold),
        arabicTitle: 'الموقع',
        englishTitle: 'location'.tr,
        subtitle: 'location_permission_request_short'.tr,
        visual: _LocationVisual(
          locationState: locationState,
          onRequest: () =>
              locationProvider.updateLocationWithGPS(background: false),
        ),
      ),

      // ── Page 4 : Complete ────────────────────────────────────────────
      _WelcomePage(
        topOrnament: const _TopCrescentOrnament(color: _gold),
        arabicTitle: locationState is LocationAvailable
            ? 'بِسْمِ اللهِ نَبدَأ'
            : 'اِستَمِرّ',
        englishTitle: locationState is LocationAvailable
            ? 'You\'re All Set!'
            : 'Continue Without Location',
        subtitle: locationState is LocationAvailable
            ? 'May Allah bless your journey. Tap Done to begin.'
            : 'You can set your location later from settings.',
        visual: _CompletionVisual(
          locationAvailable: locationState is LocationAvailable,
        ),
      ),
    ];
  }
}

// ─── Ambient gradient background ─────────────────────────────────────────────

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Warm white base
        Container(color: _bgWhite),
        // Top corner gradient bloom
        Positioned(
          top: -80,
          left: -60,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_gold.withValues(alpha: 0.13), Colors.transparent],
              ),
            ),
          ),
        ),
        // Bottom-right accent
        Positioned(
          bottom: -60,
          right: -60,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_primary.withValues(alpha: 0.07), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Rotating ornaments painter ───────────────────────────────────────────────

class _OrnamentsBackgroundPainter extends CustomPainter {
  final double progress;
  const _OrnamentsBackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    _drawStarGrid(canvas, size);
    _drawRotatingOrnament(canvas, size);
  }

  void _drawStarGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _primary.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    const step = 68.0;
    final cols = (size.width / step).ceil() + 2;
    final rows = (size.height / step).ceil() + 2;

    for (int r = -1; r < rows; r++) {
      for (int c = -1; c < cols; c++) {
        final cx = c * step + (r.isOdd ? step / 2 : 0.0);
        final cy = r * step;
        _drawStar8(canvas, paint, Offset(cx, cy), step * 0.28);
      }
    }
  }

  void _drawStar8(Canvas canvas, Paint paint, Offset center, double radius) {
    const n = 8;
    final inner = radius * 0.42;
    final path = Path();
    for (int i = 0; i < n * 2; i++) {
      final angle = (i * math.pi / n) - math.pi / 2;
      final r = i.isEven ? radius : inner;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawRotatingOrnament(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.28);
    final angle = progress * 2 * math.pi;
    final paint = Paint()
      ..color = _gold.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    for (int ring = 1; ring <= 3; ring++) {
      final r = ring * 45.0;
      const dots = 16;
      for (int i = 0; i < dots; i++) {
        final a = (2 * math.pi / dots) * i;
        final pos = Offset(r * math.cos(a), r * math.sin(a));
        canvas.drawCircle(pos, ring == 2 ? 2.5 : 1.5, paint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OrnamentsBackgroundPainter old) =>
      old.progress != progress;
}

// ─── Top crescent ornament ────────────────────────────────────────────────────

class _TopCrescentOrnament extends StatelessWidget {
  final Color color;
  const _TopCrescentOrnament({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _GoldLine(color: color),
          const SizedBox(width: 10),
          CustomPaint(
            size: const Size(22, 22),
            painter: _CrescentPainter(color: color),
          ),
          const SizedBox(width: 6),
          Text(
            '✦',
            style: TextStyle(
              color: color.withValues(alpha: 0.75),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          CustomPaint(
            size: const Size(22, 22),
            painter: _CrescentPainter(color: color, flipped: true),
          ),
          const SizedBox(width: 10),
          _GoldLine(color: color, reversed: true),
        ],
      ),
    );
  }
}

class _GoldLine extends StatelessWidget {
  final Color color;
  final bool reversed;
  const _GoldLine({required this.color, this.reversed = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 1.2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: reversed
              ? [Colors.transparent, color.withValues(alpha: 0.55)]
              : [color.withValues(alpha: 0.55), Colors.transparent],
        ),
      ),
    );
  }
}

class _CrescentPainter extends CustomPainter {
  final Color color;
  final bool flipped;
  const _CrescentPainter({required this.color, this.flipped = false});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.80)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    final cutPath = Path();
    final offset = flipped ? -r * 0.45 : r * 0.45;
    cutPath.addOval(
      Rect.fromCircle(
        center: Offset(cx + offset, cy - r * 0.1),
        radius: r * 0.82,
      ),
    );

    final crescent = Path.combine(PathOperation.difference, path, cutPath);
    canvas.drawPath(crescent, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Welcome page template ────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  final Widget topOrnament;
  final String arabicTitle;
  final String englishTitle;
  final String subtitle;
  final Widget visual;

  const _WelcomePage({
    required this.topOrnament,
    required this.arabicTitle,
    required this.englishTitle,
    required this.subtitle,
    required this.visual,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),

          // Top ornament row
          topOrnament,

          const SizedBox(height: 32),

          // Visual / illustration
          SizedBox(height: 210, child: visual),

          const SizedBox(height: 36),

          // Decorative divider
          _SectionDivider(),

          const SizedBox(height: 22),

          // Arabic title
          Text(
            arabicTitle,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'naskh',
              fontSize: 28,
              color: _gold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),

          // English title
          Text(
            englishTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'kufi',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _primary,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 14),

          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 14,
              color: _primary.withValues(alpha: 0.55),
              height: 1.7,
            ),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, _gold.withValues(alpha: 0.6)],
            ),
          ),
        ),
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _gold.withValues(alpha: 0.70),
          ),
        ),
        Text(
          '﷽',
          style: TextStyle(
            fontFamily: 'naskh',
            fontSize: 13,
            color: _gold.withValues(alpha: 0.65),
          ),
        ),
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _gold.withValues(alpha: 0.70),
          ),
        ),
        Container(
          width: 40,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_gold.withValues(alpha: 0.6), Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Visuals ──────────────────────────────────────────────────────────────────

/// App logo with glowing ring
class _AppLogoVisual extends StatelessWidget {
  const _AppLogoVisual();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer gold ring
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _gold.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
          ),
          // Middle ring
          Container(
            width: 155,
            height: 155,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _gold.withValues(alpha: 0.18),
                width: 1,
              ),
              gradient: RadialGradient(
                colors: [_gold.withValues(alpha: 0.06), Colors.transparent],
              ),
            ),
          ),
          // Logo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primary, _primaryDeep],
              ),
              boxShadow: [
                BoxShadow(
                  color: _primary.withValues(alpha: 0.28),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(22),
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),
          // Star at top
          const Positioned(
            top: 12,
            right: 50,
            child: CustomPaint(
              size: Size(14, 14),
              painter: _SmallStarPainter(color: _gold),
            ),
          ),
          // Star at bottom
          const Positioned(
            bottom: 14,
            left: 52,
            child: CustomPaint(
              size: Size(10, 10),
              painter: _SmallStarPainter(color: _gold),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallStarPainter extends CustomPainter {
  final Color color;
  const _SmallStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    const n = 8;
    final inner = r * 0.42;
    final path = Path();
    final paint = Paint()
      ..color = color.withValues(alpha: 0.80)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < n * 2; i++) {
      final angle = (i * math.pi / n) - math.pi / 2;
      final radius = i.isEven ? r : inner;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Feature icons grid
class _FeaturesVisual extends StatelessWidget {
  const _FeaturesVisual();

  static const _features = [
    (Icons.access_time_rounded, 'Prayer\nTimes'),
    (Icons.explore_rounded, 'Qibla\nDirection'),
    (Icons.menu_book_rounded, 'Holy\nQuran'),
    (Icons.spa_rounded, 'Adhkar\n& Dua'),
    (Icons.loop_rounded, 'Tasbih\nCounter'),
    (Icons.star_rounded, 'Names\nof Allah'),
  ];

  static const _palettes = [
    [Color(0xFF404C6E), Color(0xFF2E3850)],
    [Color(0xFF3D5A5A), Color(0xFF2A3E3E)],
    [Color(0xFF5A3E2B), Color(0xFF3E2A1A)],
    [Color(0xFF4A3D6B), Color(0xFF332A4E)],
    [Color(0xFF2E5449), Color(0xFF1F3B33)],
    [Color(0xFF5C4033), Color(0xFF3E2B22)],
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: _features.length,
      itemBuilder: (_, i) {
        final (icon, label) = _features[i];
        final palette = _palettes[i];
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: palette,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: palette[0].withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _gold, size: 24),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Location visual with status feedback
class _LocationVisual extends StatelessWidget {
  final LocationState locationState;
  final VoidCallback onRequest;

  const _LocationVisual({required this.locationState, required this.onRequest});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Location icon ring
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _gold.withValues(alpha: 0.12),
                      _primary.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: _gold.withValues(alpha: 0.30),
                    width: 1.5,
                  ),
                ),
              ),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primary, _primaryDeep],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withValues(alpha: 0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: _locationIcon,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Status & action
          _locationAction(context),
        ],
      ),
    );
  }

  Widget get _locationIcon {
    if (locationState is LocationFinding) {
      return const Padding(
        padding: EdgeInsets.all(22),
        child: CircularProgressIndicator(color: _gold, strokeWidth: 2.5),
      );
    }
    if (locationState is LocationAvailable) {
      return const Icon(Icons.check_circle_rounded, color: _gold, size: 38);
    }
    return const Icon(Icons.location_on_rounded, color: _gold, size: 38);
  }

  Widget _locationAction(BuildContext context) {
    if (locationState is LocationAvailable) {
      final loc = locationState as LocationAvailable;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2E5449).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2E5449).withValues(alpha: 0.30),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF2E5449),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'location_found'.tr,
                  style: const TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E5449),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            loc.locationInfo.address,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 11,
              color: _primary.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    if (locationState is LocationFinding) {
      return Text(
        'Finding your location…',
        style: TextStyle(
          fontFamily: 'kufi',
          fontSize: 13,
          color: _primary.withValues(alpha: 0.55),
        ),
      );
    }

    if (locationState is LocationNotAvailable) {
      final notAvail = locationState as LocationNotAvailable;
      if (notAvail.cause == locationNACausePermissionDeniedForever) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'permission_denied'.tr,
            style: const TextStyle(
              fontFamily: 'kufi',
              fontSize: 13,
              color: Colors.red,
            ),
          ),
        );
      }
      return _GoldButton(
        label: 'location_required'.tr,
        icon: Icons.my_location_rounded,
        onTap: onRequest,
      );
    }

    return _GoldButton(
      label: 'Grant Location',
      icon: Icons.my_location_rounded,
      onTap: onRequest,
    );
  }
}

/// Completion / done visual
class _CompletionVisual extends StatelessWidget {
  final bool locationAvailable;
  const _CompletionVisual({required this.locationAvailable});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lottie animation
          SizedBox(
            width: 150,
            height: 150,
            child: locationAvailable
                ? Lottie.asset(
                    LottieConstants.assetsLottieSun,
                    fit: BoxFit.contain,
                  )
                : Lottie.asset(
                    LottieConstants.assetsLottieMoon,
                    fit: BoxFit.contain,
                  ),
          ),
          const SizedBox(height: 10),
          // Arabic Quran phrase
          Text(
            locationAvailable
                ? '﴿ وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ ﴾'
                : '﴿ حَسْبُنَا اللَّهُ وَنِعْمَ الوَكِيلُ ﴾',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'naskh',
              fontSize: 17,
              color: _gold.withValues(alpha: 0.85),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Nav Bar ──────────────────────────────────────────────────────────────────

class _NavBar extends StatelessWidget {
  final int currentPage;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onDone;

  const _NavBar({
    required this.currentPage,
    required this.total,
    required this.onNext,
    required this.onSkip,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage >= total - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Row(
        children: [
          // Skip
          AnimatedOpacity(
            opacity: isLast ? 0 : 1,
            duration: _fadeDuration,
            child: GestureDetector(
              onTap: isLast ? null : onSkip,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _primary.withValues(alpha: 0.12)),
                ),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _primary.withValues(alpha: 0.60),
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          // Page indicator dots
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(total, (i) {
              final active = i == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: active ? 22 : 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: active ? _gold : _primary.withValues(alpha: 0.18),
                ),
              );
            }),
          ),

          const Spacer(),

          // Next / Done
          AnimatedSwitcher(
            duration: _fadeDuration,
            child: isLast
                ? _GoldButton(
                    key: const ValueKey('done'),
                    label: 'Done',
                    icon: Icons.check_rounded,
                    onTap: onDone,
                  )
                : _GoldButton(
                    key: const ValueKey('next'),
                    label: 'Next',
                    icon: Icons.arrow_forward_rounded,
                    onTap: onNext,
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable gold action button ──────────────────────────────────────────────

class _GoldButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GoldButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primary, _primaryDeep],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _primary.withValues(alpha: 0.28),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'kufi',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            Icon(icon, color: _gold, size: 16),
          ],
        ),
      ),
    );
  }
}
