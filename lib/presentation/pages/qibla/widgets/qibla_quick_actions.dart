// ── Qibla Quick Actions ──────────────────────────────────────────────────────
// Islamic-styled action buttons: gold icon containers, kufi labels

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../helpers/gps_location_helper.dart';
import '../../adhan/widgets/adhan_theme.dart';
import '../controllers/qibla_controller.dart';
import '../presentation/qibla_manual_location_sheet.dart';
import '../presentation/qibla_settings_sheet.dart';

class QiblaQuickActions extends StatelessWidget {
  const QiblaQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final actions = [
      _ActionData(
        icon: Icons.fullscreen_rounded,
        labelKey: 'fullScreen',
        fallback: 'Full Screen',
        onTap: () => Get.find<QiblaController>().toggleFullScreen(),
      ),
      _ActionData(
        icon: Icons.mosque_outlined,
        labelKey: 'nearbyMosques',
        fallback: 'Mosques',
        onTap: () => _openMosques(context),
      ),
      _ActionData(
        icon: Icons.edit_location_alt_outlined,
        labelKey: 'manualLocation',
        fallback: 'Location',
        onTap: () => _openManual(context),
      ),
      _ActionData(
        icon: Icons.tune_rounded,
        labelKey: 'setting',
        fallback: 'Settings',
        onTap: () => _openSettings(context),
      ),
    ];

    return Row(
      children: actions.asMap().entries.map((e) {
        final idx = e.key;
        final a = e.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: idx == 0 ? 0 : 6,
              right: idx == actions.length - 1 ? 0 : 6,
            ),
            child: _ActionTile(data: a, cs: cs),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _openMosques(BuildContext context) async {
    final ctrl = Get.find<QiblaController>();
    final state = ctrl.locationState.value;
    double lat = 21.4225, lng = 39.8262;
    if (state is LocationAvailable) {
      lat = state.locationInfo.latitude;
      lng = state.locationInfo.longitude;
    }
    final uri = Uri.parse(
      'https://www.google.com/maps/search/mosque/@$lat,$lng,14z',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openManual(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const QiblaManualLocationSheet(),
    );
  }

  void _openSettings(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const QiblaSettingsSheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ActionData {
  final IconData icon;
  final String labelKey;
  final String fallback;
  final VoidCallback onTap;
  const _ActionData({
    required this.icon,
    required this.labelKey,
    required this.fallback,
    required this.onTap,
  });
}

class _ActionTile extends StatelessWidget {
  final _ActionData data;
  final ColorScheme cs;

  const _ActionTile({required this.data, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kAdhanGold.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kAdhanGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kAdhanGold.withValues(alpha: 0.25)),
              ),
              child: Icon(data.icon, size: 18, color: kAdhanGoldDeep),
            ),
            const SizedBox(height: 5),
            Text(
              data.labelKey.tr.isEmpty ? data.fallback : data.labelKey.tr,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
