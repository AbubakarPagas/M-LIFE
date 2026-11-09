// ── Qibla Information Card ───────────────────────────────────────────────────
// Islamic design: surfaceContainer + gold dividers + kufi typography

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../adhan/widgets/adhan_theme.dart';
import '../controllers/qibla_controller.dart';

class QiblaInfoCardWidget extends StatelessWidget {
  const QiblaInfoCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QiblaController>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final result = ctrl.qiblaResult.value;
      if (result == null) return const SizedBox.shrink();

      final heading = ctrl.compassHeading.value.round();
      final qiblaAngle = result.bearing.round();
      // final accuracy = ctrl.accuracyLabel;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kAdhanGold.withValues(alpha: 0.20)),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: isDark ? 0.10 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gold icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: kAdhanGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: kAdhanGold.withValues(alpha: 0.30),
                    ),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: kAdhanGold,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'qiblaInfo'.tr.isEmpty ? 'Qibla Information' : 'qiblaInfo'.tr,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Grid of info tiles
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _InfoTile(
                  icon: Icons.near_me_rounded,
                  label: 'distanceToMakkah'.tr.isEmpty
                      ? 'Distance'
                      : 'distanceToMakkah'.tr,
                  value: result.distanceLabel,
                  cs: cs,
                  accentColor: kAdhanGold,
                ),
                _InfoTile(
                  icon: Icons.explore_rounded,
                  label: 'bearing'.tr.isEmpty ? 'Bearing' : 'bearing'.tr,
                  value: '$qiblaAngle°',
                  cs: cs,
                  accentColor: kAdhanGoldLight,
                ),
                _InfoTile(
                  icon: Icons.navigation_rounded,
                  label: 'currentHeading'.tr.isEmpty
                      ? 'Heading'
                      : 'currentHeading'.tr,
                  value: '$heading°',
                  cs: cs,
                  accentColor: kAdhanGoldDeep,
                ),
                /*  _InfoTile(
                  icon: Icons.compass_calibration_rounded,
                  label: 'compassAccuracy'.tr.isEmpty
                      ? 'Accuracy'
                      : 'compassAccuracy'.tr,
                  // value: accuracy,
                  cs: cs,
                  accentColor: kAdhanGold,
                ), */
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme cs;
  final Color accentColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.cs,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: accentColor),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 9,
                    color: cs.primary.withValues(alpha: 0.50),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
