import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/gps_location_helper.dart';
import '../../../../provider/locationProvider.dart';
import 'offline_location_card.dart';

class LocationNotAvailableScreen extends StatelessWidget {
  final LocationNotAvailable _locationNotAvailable;

  const LocationNotAvailableScreen(this._locationNotAvailable, {super.key});

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.read<LocationProvider>();
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),

          // Error icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cs.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(Icons.location_off, size: 72, color: cs.error),
          ),

          const SizedBox(height: 24),

          Text(
            'location_not_available'.tr,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: 'kufi',
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.error.withValues(alpha: 0.2)),
            ),
            child: Text(
              _locationNotAvailable.cause,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.8),
                fontFamily: 'kufi',
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          // Retry button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  locationProvider.updateLocationWithGPS(background: false),
              icon: const Icon(Icons.refresh_rounded),
              label: Text('try_again'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontSize: 14, fontFamily: 'kufi'),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ── Offline location card ─────────────────────────────────────
          // Shows cached location details if any exist so the user knows
          // Islamic services are still working offline.
          _OfflineFallbackSection(provider: locationProvider),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Offline fallback section ──────────────────────────────────────────────────

class _OfflineFallbackSection extends StatelessWidget {
  final LocationProvider provider;
  const _OfflineFallbackSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final cached = provider.getPersistentLocation();
    if (cached == null) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 16,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 6),
            Text(
              'Using Saved Location',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'kufi',
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Islamic services (prayer times, Qibla) continue working '
          'with your last saved location.',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'kufi',
            color: cs.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 16),
        const OfflineLocationCard(),
      ],
    );
  }
}
