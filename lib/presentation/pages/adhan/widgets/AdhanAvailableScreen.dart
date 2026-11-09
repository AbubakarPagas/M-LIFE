import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../apps/models/LocationInfo.dart';
import '../../../../apps/routes/route_name.dart';
import '../../../../helpers/gps_location_helper.dart';
import '../../../../provider/adhanProvider.dart';
import '../../../../provider/locationProvider.dart';
import '../../../../widgets/loading_location_widget.dart';
import '../../../pages/tasbih/widgets/geometric_pattern_painter.dart';
import 'AdhanDateChanger.dart';
import 'adhan_theme.dart';
import 'offline_location_card.dart';
import 'prayer_countdown_hero.dart';
import 'prayer_schedule_card.dart';
import 'prayer_tracking_panel.dart';

const centerPage = 20000;

/// Adhan Available Screen — same background / color approach as Tasbih:
///   • scaffoldBackgroundColor = theme.colorScheme.secondary
///   • GeometricPatternPainter overlay (cs.primary / gold)
///   • Radial glow from top using cs.primary
///   • All cards use cs.surfaceContainer + cs.primary tints + gold border
class AdhanAvailableScreen extends StatefulWidget {
  final LocationInfo locationInfo;
  const AdhanAvailableScreen(this.locationInfo, {super.key});

  @override
  State<AdhanAvailableScreen> createState() => _AdhanAvailableScreenState();
}

class _AdhanAvailableScreenState extends State<AdhanAvailableScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: centerPage);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adhanProvider = context.watch<AdhanProvider>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Match Tasbih: light icons when bg is dark, dark icons when bg is light
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      // ── Same as Tasbih ────────────────────────────────────────────────────
      backgroundColor: cs.secondary,

      body: Stack(
        children: [
          // ── 1. Islamic geometric pattern (same as Tasbih) ─────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: GeometricPatternPainter(
                color: isDark ? kAdhanGold : cs.primary,
                opacity: isDark ? 0.045 : 0.055,
              ),
            ),
          ),

          // ── 2. Radial glow from top (same as Tasbih) ─────────────────────
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.85,
                  colors: [
                    cs.primary.withValues(alpha: isDark ? 0.12 : 0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── 3. Content ────────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  _AdhanAppBar(cs: cs, isDark: isDark),
                  Expanded(
                    child: _ScrollBody(
                      pageController: _pageController,
                      adhanProvider: adhanProvider,
                      cs: cs,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── App bar (mirrors Tasbih _TasbihAppBar style) ──────────────────────────────

class _AdhanAppBar extends StatelessWidget {
  final ColorScheme cs;
  final bool isDark;
  const _AdhanAppBar({required this.cs, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locationState = context.watch<LocationProvider>().locationState;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          // Icon badge + title (Tasbih style)
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.primary.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.access_time_filled_rounded,
                  color: kAdhanGold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'مواقيت الصلاة',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'naskh',
                      fontSize: 15,
                      color: kAdhanGold,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Prayer Times',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.hintColor,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),

          // Location chip
          if (locationState is LocationAvailable)
            GestureDetector(
              onTap: () => _showLocationSheet(context, locationState),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        locationState.locationInfo.mode == LocationMode.cached
                        ? kAdhanGold.withValues(alpha: 0.4)
                        : cs.primary.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      locationState.locationInfo.mode == LocationMode.cached
                          ? Icons.wifi_off_rounded
                          : Icons.location_on_outlined,
                      size: 14,
                      color:
                          locationState.locationInfo.mode == LocationMode.cached
                          ? kAdhanGold
                          : kAdhanGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      locationState.locationLocality.length > 14
                          ? '${locationState.locationLocality.substring(0, 14)}…'
                          : locationState.locationLocality,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.hintColor,
                        fontFamily: 'kufi',
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const LoadingLocationWidget(),

          const SizedBox(width: 8),

          // Notification icon button (Tasbih quick-action style)
          _AppBarBtn(
            icon: Icons.notifications_outlined,
            cs: cs,
            onTap: () => Get.toNamed(RoutesName.notificationCenter),
          ),
          const SizedBox(width: 6),
          _AppBarBtn(
            icon: Icons.track_changes_rounded,
            cs: cs,
            onTap: () => Get.toNamed(RoutesName.prayerTracking),
          ),
        ],
      ),
    );
  }

  void _showLocationSheet(BuildContext context, LocationAvailable state) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ChangeNotifierProvider.value(
              value: LocationProvider.getInstance(),
              child: const OfflineLocationCard(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarBtn extends StatelessWidget {
  final IconData icon;
  final ColorScheme cs;
  final VoidCallback onTap;
  const _AppBarBtn({required this.icon, required this.cs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Icon(icon, color: cs.primary, size: 18),
      ),
    );
  }
}

// ── Scrollable body ───────────────────────────────────────────────────────────

class _ScrollBody extends StatelessWidget {
  final PageController pageController;
  final AdhanProvider adhanProvider;
  final ColorScheme cs;
  final bool isDark;

  const _ScrollBody({
    required this.pageController,
    required this.adhanProvider,
    required this.cs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // ── Date changer ────────────────────────────────────────────────
          AdhanDateChanger(pageController),

          const SizedBox(height: 22),

          // ── Countdown hero ───────────────────────────────────────────────
          const PrayerCountdownHero(),

          const SizedBox(height: 22),

          // ── Gold ornamental divider ──────────────────────────────────────
          _GoldDivider(cs: cs),

          const SizedBox(height: 18),

          // ── Prayer schedule (swipeable by day) ───────────────────────────
          SizedBox(
            height: 520,
            child: PageView.builder(
              itemCount: centerPage * 2 + 1,
              controller: pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (page) =>
                  adhanProvider.changeDayOfDate(page - centerPage),
              itemBuilder: (ctx, index) {
                final date = DateTime.now().add(
                  Duration(days: index - centerPage),
                );
                return SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: PrayerScheduleCard(
                    dateTime: date,
                    key: ValueKey(index),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Divider (same as Tasbih between sections)
          Divider(color: cs.primary.withValues(alpha: 0.12), thickness: 1),

          const SizedBox(height: 14),

          // ── Tracking panel ────────────────────────────────────────────────
          const PrayerTrackingPanel(),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ── Gold ornamental divider ───────────────────────────────────────────────────

class _GoldDivider extends StatelessWidget {
  final ColorScheme cs;
  const _GoldDivider({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  kAdhanGold.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: kAdhanGold,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const Text('✦', style: TextStyle(color: kAdhanGoldLight, fontSize: 13)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: kAdhanGold,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kAdhanGold.withValues(alpha: 0.55),
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
