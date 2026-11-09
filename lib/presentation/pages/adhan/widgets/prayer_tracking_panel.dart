import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../provider/adhanProvider.dart';
import 'adhan_theme.dart';

/// Prayer Tracking Panel — completion %, streak, achievements,
/// and per-prayer mark-as-done toggles (local ephemeral state).
class PrayerTrackingPanel extends StatefulWidget {
  const PrayerTrackingPanel({super.key});

  @override
  State<PrayerTrackingPanel> createState() => _PrayerTrackingPanelState();
}

class _PrayerTrackingPanelState extends State<PrayerTrackingPanel> {
  // Ephemeral prayer-completed set (keyed by Adhan.type)
  final Set<int> _completed = {};

  @override
  Widget build(BuildContext context) {
    final adhanProvider = context.watch<AdhanProvider>();
    final today = adhanProvider.getAdhanData(DateTime.now());
    final obligatory = today
        .where((a) => [0, 2, 3, 4, 5].contains(a.type))
        .toList();
    final completionPct = obligatory.isEmpty
        ? 0.0
        : _completed.length / obligatory.length;
    final streak = _completed.length;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
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
              'prayer_tracking'.tr.toUpperCase(),
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
        const SizedBox(height: 12),

        // Stats row
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.pie_chart_outline_rounded,
                value: '${(completionPct * 100).round()}%',
                label: 'daily_completion'.tr,
                cs: cs,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.local_fire_department_outlined,
                value: '$streak',
                label: 'prayers_today'.tr,
                cs: cs,
                color: kAdhanGold,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.emoji_events_outlined,
                value: _badgeLabel(_completed.length),
                label: 'achievement'.tr,
                cs: cs,
                color: kAdhanGoldLight,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Per-prayer toggles
        Container(
          decoration: AdhanDecorations.card(cs: cs),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'mark_as_prayed'.tr,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.hintColor.withValues(alpha: 0.7),
                  letterSpacing: 0.5,
                  fontFamily: 'kufi',
                ),
              ),
              const SizedBox(height: 12),
              _CompletionBar(progress: completionPct, cs: cs),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: obligatory.map((adhan) {
                  final done = _completed.contains(adhan.type);
                  return _PrayerToggleChip(
                    label: adhan.title,
                    isDone: done,
                    cs: cs,
                    onTap: () => setState(() {
                      done
                          ? _completed.remove(adhan.type)
                          : _completed.add(adhan.type);
                    }),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Achievements
        _AchievementsBadges(completedCount: _completed.length),
      ],
    );
  }

  String _badgeLabel(int count) {
    if (count >= 5) return '🥇';
    if (count >= 3) return '🥈';
    if (count >= 1) return '🥉';
    return '–';
  }
}

// ── Stat tile ─────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final ColorScheme cs;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.cs,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withValues(alpha: 0.10), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: theme.hintColor.withValues(alpha: 0.55),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Completion progress bar ────────────────────────────────────────────────────

class _CompletionBar extends StatelessWidget {
  final double progress;
  final ColorScheme cs;
  const _CompletionBar({required this.progress, required this.cs});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) => Stack(
        children: [
          Container(
            height: 6,
            width: constraints.maxWidth,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            height: 6,
            width: constraints.maxWidth * progress,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.primary.withValues(alpha: 0.6)],
              ),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.35),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Prayer toggle chip ────────────────────────────────────────────────────────

class _PrayerToggleChip extends StatelessWidget {
  final String label;
  final bool isDone;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _PrayerToggleChip({
    required this.label,
    required this.isDone,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isDone
              ? cs.primary.withValues(alpha: 0.15)
              : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDone
                ? cs.primary.withValues(alpha: 0.55)
                : cs.primary.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDone) ...[
              Icon(Icons.check, size: 12, color: cs.primary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isDone ? FontWeight.w700 : FontWeight.w400,
                color: isDone
                    ? cs.primary
                    : theme.hintColor.withValues(alpha: 0.7),
                fontFamily: 'kufi',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Achievements ──────────────────────────────────────────────────────────────

class _AchievementsBadges extends StatelessWidget {
  final int completedCount;
  const _AchievementsBadges({required this.completedCount});

  @override
  Widget build(BuildContext context) {
    final badges = _buildBadges(completedCount);
    if (badges.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: AdhanDecorations.glassCard,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'achievements'.tr.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AdhanColors.goldLight,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 10, children: badges),
        ],
      ),
    );
  }

  List<Widget> _buildBadges(int count) {
    final items = <_BadgeItem>[];
    if (count >= 1)
      items.add(const _BadgeItem(emoji: '🌙', label: 'First Prayer'));
    if (count >= 3) items.add(const _BadgeItem(emoji: '⭐', label: 'Half Way'));
    if (count >= 5)
      items.add(const _BadgeItem(emoji: '🏆', label: 'All 5 Prayers'));
    return items;
  }
}

class _BadgeItem extends StatelessWidget {
  final String emoji;
  final String label;

  const _BadgeItem({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x33D4A843), Color(0x22D4A843)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AdhanColors.gold.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AdhanColors.goldPale,
            ),
          ),
        ],
      ),
    );
  }
}
