import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../apps/models/LocationInfo.dart';
import '../../../../helpers/gps_location_helper.dart';
import '../../../../provider/locationProvider.dart';
import 'adhan_theme.dart';

/// A card shown in adhan / location settings that presents full offline
/// location details and allows the user to refresh or clear the cache.
class OfflineLocationCard extends StatelessWidget {
  const OfflineLocationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locationProvider = context.watch<LocationProvider>();
    final locationState = locationProvider.locationState;

    if (locationState is LocationFinding) {
      return _buildFinding(cs);
    }

    if (locationState is LocationNotAvailable) {
      return _buildNotAvailable(context, cs, locationState, locationProvider);
    }

    if (locationState is LocationAvailable) {
      return _buildAvailable(
        context,
        cs,
        locationState.locationInfo,
        locationProvider,
      );
    }

    return const SizedBox.shrink();
  }

  // ── Available ─────────────────────────────────────────────────────────────

  Widget _buildAvailable(
    BuildContext context,
    ColorScheme cs,
    LocationInfo info,
    LocationProvider provider,
  ) {
    final isCached = info.mode == LocationMode.cached;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCached
              ? kAdhanGold.withValues(alpha: 0.35)
              : cs.primary.withValues(alpha: 0.2),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isCached
                  ? kAdhanGold.withValues(alpha: 0.08)
                  : cs.primary.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isCached ? Icons.wifi_off_rounded : Icons.location_on_rounded,
                  color: isCached ? kAdhanGold : cs.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📍 Current Location',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).hintColor,
                          fontFamily: 'kufi',
                        ),
                      ),
                      Text(
                        info.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isCached ? kAdhanGold : cs.primary,
                          fontFamily: 'kufi',
                        ),
                      ),
                    ],
                  ),
                ),
                // Offline badge
                if (isCached)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: kAdhanGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: kAdhanGold.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Text(
                      '✓ Offline',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: kAdhanGold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Detail rows ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.my_location_rounded,
                  label: 'Coordinates',
                  value:
                      '${info.latitude.toStringAsFixed(4)}, ${info.longitude.toStringAsFixed(4)}',
                  cs: cs,
                ),
                if (info.timezone.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'Time Zone',
                    value: info.timezone.isNotEmpty && info.utcOffset.isNotEmpty
                        ? '${info.timezone}  (UTC ${info.utcOffset})'
                        : info.timezone,
                    cs: cs,
                  ),
                ],
                if (info.state.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.map_outlined,
                    label: 'State / Province',
                    value: info.state,
                    cs: cs,
                  ),
                ],
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.info_outline_rounded,
                  label: 'Source',
                  value: info.sourceLabel,
                  cs: cs,
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.update_rounded,
                  label: 'Last Updated',
                  value: _formatDate(info.lastUpdated),
                  cs: cs,
                ),
              ],
            ),
          ),

          // ── Actions ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        provider.updateLocationWithGPS(background: false),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: Text('refresh_location'.tr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.primary,
                      side: BorderSide(
                        color: cs.primary.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'kufi',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => _confirmClear(context, provider),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: Text('clear_location'.tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.error,
                    side: BorderSide(color: cs.error.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'kufi',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Finding ───────────────────────────────────────────────────────────────

  Widget _buildFinding(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Finding location…',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'kufi',
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ── Not available ─────────────────────────────────────────────────────────

  Widget _buildNotAvailable(
    BuildContext context,
    ColorScheme cs,
    LocationNotAvailable state,
    LocationProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.error.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_off_rounded, color: cs.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'Location Unavailable',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'kufi',
                  color: cs.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.cause,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'kufi',
              color: cs.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  provider.updateLocationWithGPS(background: false),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text('try_again'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(fontSize: 13, fontFamily: 'kufi'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) {
      return 'Today ${DateFormat('hh:mm a').format(dt)}';
    }
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('d MMM yyyy, hh:mm a').format(dt);
  }

  void _confirmClear(BuildContext context, LocationProvider provider) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Clear Saved Location',
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'This will remove the saved offline location. '
          'Islamic services will require a new GPS fix.',
          style: TextStyle(fontFamily: 'kufi', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'cancel'.tr,
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.clearSavedLocation();
            },
            child: Text('clear_location'.tr, style: TextStyle(color: cs.error)),
          ),
        ],
      ),
    );
  }
}

// ── Detail row ─────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme cs;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: cs.primary.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'kufi',
              color: Theme.of(context).hintColor.withValues(alpha: 0.7),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'kufi',
              color: Theme.of(context).hintColor,
            ),
          ),
        ),
      ],
    );
  }
}
