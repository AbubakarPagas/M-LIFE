// ── Qibla Page ───────────────────────────────────────────────────────────────
// Full Islamic-design Qibla page matching the app's Adhan/Tasbih aesthetic:
//   • bg = cs.secondary + GeometricPatternPainter overlay
//   • Radial gold glow from top-center
//   • Cards use cs.surfaceContainer + gold borders
//   • Gold (0xffCDAD80) accent throughout
//   • naskh Arabic calligraphy header

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../adhan/widgets/adhan_theme.dart';
import '../../tasbih/widgets/geometric_pattern_painter.dart';
import '../controllers/qibla_controller.dart';
import '../widgets/calibration_widget.dart';
import '../widgets/facing_qibla_banner.dart';
import '../widgets/location_card_widget.dart';
import '../widgets/prayer_mini_card.dart';
import '../widgets/qibla_compass_widget.dart';
import '../widgets/qibla_info_card_widget.dart';
import '../widgets/qibla_quick_actions.dart';
import 'qibla_fullscreen_page.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage>
    with SingleTickerProviderStateMixin {
  late QiblaController _ctrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(QiblaController(), permanent: false);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: cs.secondary,
      body: Stack(
        children: [
          // ── 1. Islamic geometric pattern background ────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: GeometricPatternPainter(
                color: isDark ? kAdhanGold : cs.primary,
                opacity: isDark ? 0.045 : 0.055,
              ),
            ),
          ),

          // ── 2. Radial gold glow from top ──────────────────────────────────
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
              child: Obx(() {
                // Full-screen toggle
                if (_ctrl.isFullScreen.value) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _ctrl.isFullScreen.value = false;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const QiblaFullScreenPage(),
                      ),
                    );
                  });
                }
                return Column(
                  children: [
                    _QiblaAppBar(cs: cs),
                    Expanded(
                      child: _QiblaScrollBody(cs: cs, isDark: isDark),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _QiblaAppBar extends StatelessWidget {
  final ColorScheme cs;
  const _QiblaAppBar({required this.cs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: cs.primary,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title badge + Arabic calligraphy
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
                  Icons.explore_rounded,
                  color: kAdhanGold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اتجاه القبلة',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'naskh',
                      fontSize: 15,
                      color: kAdhanGold,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Qibla Direction',
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

          // Refresh button
          Obx(() {
            final ctrl = Get.find<QiblaController>();
            return GestureDetector(
              onTap: ctrl.retryLocation,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
                ),
                child: ctrl.isLoadingLocation.value
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(cs.primary),
                        ),
                      )
                    : Icon(Icons.refresh_rounded, color: cs.primary, size: 18),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Scrollable body ───────────────────────────────────────────────────────────

class _QiblaScrollBody extends StatelessWidget {
  final ColorScheme cs;
  final bool isDark;

  const _QiblaScrollBody({required this.cs, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QiblaController>();

    return Obx(() {
      if (ctrl.compassNotSupported.value) {
        return _CompassUnsupportedBody(cs: cs);
      }

      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  const SizedBox(height: 4),

                  // ── Location card ────────────────────────────────────────
                  const LocationCardWidget(),
                  const SizedBox(height: 16),

                  // ── Gold ornamental divider ──────────────────────────────
                  _IslamicDivider(cs: cs),
                  const SizedBox(height: 20),

                  // ── Calibration overlay ──────────────────────────────────
                  Obx(
                    () => ctrl.needsCalibration.value
                        ? const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: CalibrationWidget(),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // ── Compass ──────────────────────────────────────────────
                  Center(
                    child: QiblaCompassWidget(
                      size: MediaQuery.of(context).size.width * 0.74,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Facing Qibla banner ──────────────────────────────────
                  const FacingQiblaBanner(),
                  const SizedBox(height: 20),

                  // ── Gold ornamental divider ──────────────────────────────
                  _IslamicDivider(cs: cs),
                  const SizedBox(height: 16),

                  // ── Qibla info card ──────────────────────────────────────
                  const QiblaInfoCardWidget(),
                  const SizedBox(height: 14),

                  // ── Prayer mini card ─────────────────────────────────────
                  const PrayerMiniCard(),
                  const SizedBox(height: 20),

                  // ── Gold ornamental divider ──────────────────────────────
                  _IslamicDivider(cs: cs),
                  const SizedBox(height: 16),

                  // ── Quick actions ────────────────────────────────────────
                  const QiblaQuickActions(),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ── Islamic ornamental divider ────────────────────────────────────────────────

class _IslamicDivider extends StatelessWidget {
  final ColorScheme cs;
  const _IslamicDivider({required this.cs});

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
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: kAdhanGold,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const Text('✦', style: TextStyle(color: kAdhanGoldLight, fontSize: 12)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            width: 5,
            height: 5,
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

// ── Compass unsupported body ──────────────────────────────────────────────────

class _CompassUnsupportedBody extends StatelessWidget {
  final ColorScheme cs;
  const _CompassUnsupportedBody({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.surfaceContainer,
                border: Border.all(
                  color: kAdhanGold.withValues(alpha: 0.35),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.compass_calibration_outlined,
                size: 38,
                color: cs.primary.withValues(alpha: 0.40),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'compassNotSupported'.tr.isEmpty
                  ? 'Compass Not Supported'
                  : 'compassNotSupported'.tr,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'compassNotSupportedDesc'.tr.isEmpty
                  ? 'Your device does not have a magnetometer. Qibla direction is still calculated from your location.'
                  : 'compassNotSupportedDesc'.tr,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 12,
                color: cs.primary.withValues(alpha: 0.55),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            const QiblaInfoCardWidget(),
          ],
        ),
      ),
    );
  }
}
