import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../extensions.dart';
import '../../../../models/Adhan.dart';
import '../../../../provider/adhanProvider.dart';
import '../../../../provider/dependencies/AdhanDependencyProvider.dart';
import 'adhan_theme.dart';

/// Prayer Schedule Card — uses the same card / colour style as the Tasbih page:
/// cs.surfaceContainer for card backgrounds, cs.primary for accents, gold border.
class PrayerScheduleCard extends StatefulWidget {
  final DateTime dateTime;
  const PrayerScheduleCard({required this.dateTime, super.key});

  @override
  State<PrayerScheduleCard> createState() => _PrayerScheduleCardState();
}

class _PrayerScheduleCardState extends State<PrayerScheduleCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adhanProvider = context.watch<AdhanProvider>();
    final adhans = adhanProvider.getAdhanData(widget.dateTime);
    final isToday = widget.dateTime.isToday;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header (same style as Tasbih section labels)
        Row(
          children: [
            Container(
              width: 3,
              height: 15,
              decoration: BoxDecoration(
                color: kAdhanGold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'prayer_schedule'.tr.toUpperCase(),
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: theme.hintColor,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: adhans.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          padding: EdgeInsets.zero,
          itemBuilder: (ctx, i) => _PrayerRow(
            adhan: adhans[i],
            isToday: isToday,
            cs: cs,
            theme: theme,
          ),
        ),
      ],
    );
  }
}

// ── Single prayer row ─────────────────────────────────────────────────────────

class _PrayerRow extends StatelessWidget {
  final Adhan adhan;
  final bool isToday;
  final ColorScheme cs;
  final ThemeData theme;

  const _PrayerRow({
    required this.adhan,
    required this.isToday,
    required this.cs,
    required this.theme,
  });

  bool get _isCompleted => isToday && DateTime.now().isAfter(adhan.endTime);
  bool get _isActive => isToday && adhan.isCurrent;
  bool get _isNext {
    if (!isToday) return false;
    return DateTime.now().isBefore(adhan.startTime);
  }

  @override
  Widget build(BuildContext context) {
    final adhanDep = context.watch<AdhanDependencyProvider>();
    final notifyID = adhanDep.notifyID(adhan.type);

    final decoration = _isActive
        ? BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.primary.withValues(alpha: 0.22),
                cs.primary.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.primary.withValues(alpha: 0.55),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.14),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          )
        : BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isNext
                  ? kAdhanGold.withValues(alpha: 0.35)
                  : cs.primary.withValues(alpha: 0.10),
              width: 1,
            ),
          );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: cs.primary.withValues(alpha: 0.06),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                _PrayerIconBadge(
                  imageLocation: adhan.imageLocation,
                  isActive: _isActive,
                  isCompleted: _isCompleted,
                  cs: cs,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adhan.title,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _isActive
                              ? cs.primary
                              : _isCompleted
                              ? theme.hintColor.withValues(alpha: 0.45)
                              : theme.hintColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${adhan.startTime.localizeTimeTo()}  –  ${adhan.endTime.localizeTimeTo()}',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 12,
                          color: _isActive
                              ? kAdhanGold
                              : theme.hintColor.withValues(alpha: 0.50),
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(
                  isActive: _isActive,
                  isCompleted: _isCompleted,
                  isNext: _isNext,
                  notifyID: notifyID,
                  cs: cs,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Prayer icon badge ─────────────────────────────────────────────────────────

class _PrayerIconBadge extends StatelessWidget {
  final String imageLocation;
  final bool isActive;
  final bool isCompleted;
  final ColorScheme cs;

  const _PrayerIconBadge({
    required this.imageLocation,
    required this.isActive,
    required this.isCompleted,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isActive
            ? LinearGradient(
                colors: [
                  cs.primary,
                  Color.lerp(cs.primary, Colors.black, 0.25)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isActive ? null : cs.primary.withValues(alpha: 0.10),
        border: Border.all(
          color: isActive
              ? cs.primary.withValues(alpha: 0.60)
              : cs.primary.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.25),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: isCompleted ? 0.4 : 1.0,
            child: Image.asset(
              imageLocation,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              color: isCompleted ? AdhanColors.completedGrey : null,
            ),
          ),
          if (isCompleted)
            const Icon(
              Icons.check_circle,
              size: 15,
              color: AdhanColors.successGreen,
            ),
        ],
      ),
    );
  }
}

// ── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  final bool isCompleted;
  final bool isNext;
  final int notifyID;
  final ColorScheme cs;

  const _StatusBadge({
    required this.isActive,
    required this.isCompleted,
    required this.isNext,
    required this.notifyID,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.50),
            width: 1,
          ),
        ),
        child: Text(
          'NOW',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: cs.primary,
            letterSpacing: 1.4,
          ),
        ),
      );
    }

    if (isCompleted) {
      return const Icon(
        Icons.check_circle_outline,
        color: AdhanColors.successGreen,
        size: 20,
      );
    }

    if (isNext) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: kAdhanGold.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: kAdhanGold.withValues(alpha: 0.40),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: kAdhanGold,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'NEXT',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: kAdhanGold,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      );
    }

    return Icon(
      _notifyIcon(notifyID),
      size: 17,
      color: cs.primary.withValues(alpha: 0.30),
    );
  }

  IconData _notifyIcon(int id) => switch (id) {
    0 => Icons.notifications_off_outlined,
    1 => Icons.notifications_outlined,
    _ => Icons.volume_up_outlined,
  };
}
