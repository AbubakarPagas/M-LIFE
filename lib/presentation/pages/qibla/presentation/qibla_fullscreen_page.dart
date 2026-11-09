// ── Qibla Full-Screen Compass Page ──────────────────────────────────────────
// Immersive Islamic mode: dark scaffold + gold compass + wakelock

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../adhan/widgets/adhan_theme.dart';
import '../../tasbih/widgets/geometric_pattern_painter.dart';
import '../controllers/qibla_controller.dart';
import '../widgets/calibration_widget.dart';
import '../widgets/facing_qibla_banner.dart';
import '../widgets/qibla_compass_widget.dart';

class QiblaFullScreenPage extends StatefulWidget {
  const QiblaFullScreenPage({super.key});

  @override
  State<QiblaFullScreenPage> createState() => _QiblaFullScreenPageState();
}

class _QiblaFullScreenPageState extends State<QiblaFullScreenPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final ctrl = Get.find<QiblaController>();

    return Scaffold(
      backgroundColor: cs.primary, // Deep primary as immersive bg
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            // ── Subtle geometric Islamic pattern ──────────────────────────
            const Positioned.fill(
              child: CustomPaint(
                painter: GeometricPatternPainter(
                  color: kAdhanGold,
                  opacity: 0.06,
                ),
              ),
            ),

            // ── Central radial glow ────────────────────────────────────────
            Positioned(
              top: size.height * 0.20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: size.width * 0.90,
                  height: size.width * 0.90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        kAdhanGold.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Content ────────────────────────────────────────────────────
            SafeArea(
              child: FadeTransition(
                opacity: _fadeCtrl,
                child: Column(
                  children: [
                    // Mini header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                      child: Row(
                        children: [
                          const Text(
                            'اتجاه القبلة',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'naskh',
                              fontSize: 18,
                              color: kAdhanGold,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: kAdhanGold.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: kAdhanGold.withValues(alpha: 0.30),
                                ),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: kAdhanGoldLight,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Calibration (if needed)
                    Obx(
                      () => ctrl.needsCalibration.value
                          ? const Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                              child: CalibrationWidget(),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // Large compass
                    QiblaCompassWidget(
                      size: size.width * 0.82,
                      isFullScreen: true,
                    ),

                    const SizedBox(height: 28),

                    // Alignment banner
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: FacingQiblaBanner(),
                    ),

                    const Spacer(),

                    // Tap to exit hint
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        'tapToExit'.tr.isEmpty
                            ? 'Tap anywhere to exit'
                            : 'tapToExit'.tr,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 11,
                          color: kAdhanGold.withValues(alpha: 0.50),
                        ),
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
  }
}
