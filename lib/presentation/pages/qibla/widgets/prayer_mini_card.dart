// ── Prayer Mini Card ─────────────────────────────────────────────────────────
// Islamic design: gold header, surfaceContainer body, kufi/naskh typography

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:misbah_path/apps/views/apps.dart' show AdhanProviderWrapper;
import 'package:misbah_path/provider/adhanProvider.dart';
import 'package:provider/provider.dart';

import '../../adhan/widgets/adhan_theme.dart';

class PrayerMiniCard extends StatefulWidget {
  const PrayerMiniCard({super.key});

  @override
  State<PrayerMiniCard> createState() => _PrayerMiniCardState();
}

class _PrayerMiniCardState extends State<PrayerMiniCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wrapper = context.watch<AdhanProviderWrapper>();
    final adhan = wrapper.adhanProvider;

    return Container(
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
        children: [
          // ── Gold header bar ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primary.withValues(alpha: 0.08),
                  cs.primary.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              border: Border(
                bottom: BorderSide(color: kAdhanGold.withValues(alpha: 0.20)),
              ),
            ),
            child: Row(
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
                    Icons.access_time_filled_rounded,
                    size: 14,
                    color: kAdhanGold,
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
                        fontSize: 13,
                        color: kAdhanGold,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      'prayerTimes'.tr.isEmpty
                          ? 'Prayer Times'
                          : 'prayerTimes'.tr,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: cs.primary.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _HijriDateChip(cs: cs),
              ],
            ),
          ),

          // ── Prayer data row ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: adhan == null
                ? _NoPrayerRow(cs: cs)
                : _PrayerDataRow(adhan: adhan, cs: cs),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PrayerDataRow extends StatelessWidget {
  final AdhanProvider adhan;
  final ColorScheme cs;

  const _PrayerDataRow({required this.adhan, required this.cs});

  @override
  Widget build(BuildContext context) {
    final current = adhan.currentAdhan;
    final next = adhan.nextAdhan;
    final remaining = next.startTime.difference(DateTime.now());
    final hh = remaining.inHours.abs().toString().padLeft(2, '0');
    final mm = (remaining.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final ss = (remaining.inSeconds.abs() % 60).toString().padLeft(2, '0');

    return Row(
      children: [
        if (current != null) ...[
          Expanded(
            child: _PrayerItem(
              icon: Icons.wb_sunny_outlined,
              labelKey: 'currentPrayer',
              fallback: 'Current',
              value: current.title,
              color: kAdhanGold,
              cs: cs,
            ),
          ),
          _VerticalDivider(),
        ],
        Expanded(
          child: _PrayerItem(
            icon: Icons.arrow_forward_ios_rounded,
            labelKey: 'nextPrayer',
            fallback: 'Next',
            value: next.title,
            color: kAdhanGoldLight,
            cs: cs,
          ),
        ),
        _VerticalDivider(),
        Expanded(
          child: _PrayerItem(
            icon: Icons.timer_outlined,
            labelKey: 'countdown',
            fallback: 'In',
            value: '$hh:$mm:$ss',
            color: kAdhanGoldDeep,
            cs: cs,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: kAdhanGold.withValues(alpha: 0.20),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PrayerItem extends StatelessWidget {
  final IconData icon;
  final String labelKey;
  final String fallback;
  final String value;
  final Color color;
  final ColorScheme cs;

  const _PrayerItem({
    required this.icon,
    required this.labelKey,
    required this.fallback,
    required this.value,
    required this.color,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(height: 4),
        Text(
          labelKey.tr.isEmpty ? fallback : labelKey.tr,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 9,
            color: cs.primary.withValues(alpha: 0.50),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: cs.primary,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NoPrayerRow extends StatelessWidget {
  final ColorScheme cs;
  const _NoPrayerRow({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Text(
      'locationNeededForPrayer'.tr.isEmpty
          ? 'Enable location for prayer times'
          : 'locationNeededForPrayer'.tr,
      style: TextStyle(
        fontFamily: 'kufi',
        fontSize: 11,
        color: cs.primary.withValues(alpha: 0.50),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HijriDateChip extends StatelessWidget {
  final ColorScheme cs;
  const _HijriDateChip({required this.cs});

  @override
  Widget build(BuildContext context) {
    try {
      final h = HijriCalendar.now();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: kAdhanGold.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kAdhanGold.withValues(alpha: 0.25)),
        ),
        child: Text(
          '${h.hDay}/${h.hMonth}/${h.hYear}',
          style: const TextStyle(
            fontFamily: 'kufi',
            fontSize: 10,
            color: kAdhanGoldDeep,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}
