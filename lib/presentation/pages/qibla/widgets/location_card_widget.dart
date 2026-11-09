// ── Location Card Widget ─────────────────────────────────────────────────────
// Islamic design: surfaceContainer card + gold accents + kufi font

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../apps/models/LocationInfo.dart';
import '../../../../helpers/gps_location_helper.dart';
import '../../adhan/widgets/adhan_theme.dart';
import '../controllers/qibla_controller.dart';

class LocationCardWidget extends StatelessWidget {
  const LocationCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QiblaController>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final state = ctrl.locationState.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.primary.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: isDark ? 0.10 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: state is LocationAvailable
            ? _LocationInfo(info: state.locationInfo, cs: cs)
            : state is LocationFinding
            ? _LoadingRow(cs: cs)
            : _ErrorRow(
                cause: (state as LocationNotAvailable).cause,
                onRetry: ctrl.retryLocation,
                cs: cs,
              ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _LocationInfo extends StatelessWidget {
  final LocationInfo info;
  final ColorScheme cs;
  const _LocationInfo({required this.info, required this.cs});

  @override
  Widget build(BuildContext context) {
    final isOffline = info.mode == LocationMode.cached;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isOffline ? kAdhanGold : kAdhanGoldLight).withValues(
                  alpha: 0.15,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (isOffline ? kAdhanGold : kAdhanGoldLight).withValues(
                    alpha: 0.30,
                  ),
                ),
              ),
              child: Icon(
                isOffline ? Icons.wifi_off_rounded : Icons.location_on_rounded,
                color: isOffline ? kAdhanGold : kAdhanGoldLight,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.displayName,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    info.sourceLabel,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 10,
                      color: isOffline
                          ? kAdhanGold
                          : cs.primary.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            if (info.state.isNotEmpty)
              _Chip(
                icon: Icons.map_outlined,
                label: info.state,
                color: cs.primary,
              ),
            if (info.country.isNotEmpty)
              _Chip(
                icon: Icons.flag_outlined,
                label: info.country,
                color: cs.primary,
              ),
            _Chip(
              icon: Icons.my_location_rounded,
              label:
                  '${info.latitude.toStringAsFixed(4)}, ${info.longitude.toStringAsFixed(4)}',
              color: kAdhanGold,
            ),
          ],
        ),
        if (isOffline) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: kAdhanGold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kAdhanGold.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 12,
                  color: kAdhanGold,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'usingCachedLocation'.tr.isEmpty
                        ? 'Using cached location'
                        : 'usingCachedLocation'.tr,
                    style: const TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 10,
                      color: kAdhanGold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color.withValues(alpha: 0.70)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 10,
            color: color.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _LoadingRow extends StatelessWidget {
  final ColorScheme cs;
  const _LoadingRow({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(kAdhanGold),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'findingLocation'.tr.isEmpty
              ? 'Finding your location…'
              : 'findingLocation'.tr,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 12,
            color: cs.primary.withValues(alpha: 0.70),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ErrorRow extends StatelessWidget {
  final String cause;
  final VoidCallback onRetry;
  final ColorScheme cs;

  const _ErrorRow({
    required this.cause,
    required this.onRetry,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_off_rounded,
                color: Colors.red,
                size: 14,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                cause,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 11,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.primary.withValues(alpha: 0.20)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded, size: 14, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  'retry'.tr.isEmpty ? 'Retry' : 'retry'.tr,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
