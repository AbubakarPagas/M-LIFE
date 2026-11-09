import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../adhan/widgets/adhan_theme.dart';
import '../../bloc/prayer_tracking_bloc.dart';
import 'tracking_shared_widgets.dart';

class MonthlyAnalyticsTab extends StatefulWidget {
  final int year;
  final int month;

  const MonthlyAnalyticsTab({
    required this.year,
    required this.month,
    super.key,
  });

  @override
  State<MonthlyAnalyticsTab> createState() => _MonthlyAnalyticsTabState();
}

class _MonthlyAnalyticsTabState extends State<MonthlyAnalyticsTab> {
  @override
  void initState() {
    super.initState();
    context.read<PrayerTrackingBloc>().add(
      LoadMonthlyStatsEvent(widget.year, widget.month),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTrackingBloc, PrayerTrackingState>(
      buildWhen: (_, s) =>
          s is MonthlyStatsLoaded || s is PrayerTrackingLoading,
      builder: (ctx, state) {
        if (state is PrayerTrackingLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AdhanColors.emeraldGlow),
          );
        }

        if (state is! MonthlyStatsLoaded) {
          return Center(
            child: TextButton(
              onPressed: () => ctx.read<PrayerTrackingBloc>().add(
                LoadMonthlyStatsEvent(widget.year, widget.month),
              ),
              child: const Text(
                'Load Monthly Stats',
                style: TextStyle(color: AdhanColors.emeraldGlow),
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          physics: const BouncingScrollPhysics(),
          children: [
            _MonthHeader(year: widget.year, month: widget.month),
            const SizedBox(height: 16),
            const TrackingSectionTitle(title: 'PERFORMANCE OVERVIEW'),
            const SizedBox(height: 12),
            _PerformanceCard(state: state),
            const SizedBox(height: 24),
            const TrackingSectionTitle(title: 'WORSHIP TREND'),
            const SizedBox(height: 12),
            _TrendChart(weeklyScores: state.weeklyScores),
            const SizedBox(height: 24),
            const TrackingSectionTitle(title: 'STREAKS & RECORDS'),
            const SizedBox(height: 12),
            _StreakBadges(state: state),
            const SizedBox(height: 24),
            const TrackingSectionTitle(title: 'MOST CONSISTENT'),
            const SizedBox(height: 12),
            _MostConsistentCard(prayer: state.mostConsistentPrayer),
          ],
        );
      },
    );
  }
}

// ── Month header ──────────────────────────────────────────────────────────────

class _MonthHeader extends StatelessWidget {
  final int year;
  final int month;
  const _MonthHeader({required this.year, required this.month});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x440D5C3D), Color(0x330B2E46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AdhanColors.emeraldGlow.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_month_outlined,
            color: AdhanColors.goldLight,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat('MMMM yyyy').format(DateTime(year, month)),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AdhanColors.pureWhite,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Performance card ──────────────────────────────────────────────────────────

class _PerformanceCard extends StatelessWidget {
  final MonthlyStatsLoaded state;
  const _PerformanceCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final pct = state.completionPct / 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdhanColors.glassLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdhanColors.glassDark),
      ),
      child: Row(
        children: [
          // Ring
          SizedBox(
            width: 90,
            height: 90,
            child: CustomPaint(
              painter: _ArcPainter(progress: pct),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${state.completionPct.round()}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AdhanColors.pureWhite,
                      ),
                    ),
                    const Text(
                      'done',
                      style: TextStyle(
                        fontSize: 9,
                        color: AdhanColors.mutedWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  label: 'Completion',
                  value: '${state.completionPct.round()}%',
                  color: AdhanColors.emeraldGlow,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: 'Best Streak',
                  value: '${state.longestStreak} days',
                  color: AdhanColors.gold,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: 'Top Prayer',
                  value: state.mostConsistentPrayer,
                  color: AdhanColors.goldLight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InfoRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AdhanColors.mutedWhite),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── Trend chart (4 weekly buckets) ────────────────────────────────────────────

class _TrendChart extends StatelessWidget {
  final List<double> weeklyScores;
  const _TrendChart({required this.weeklyScores});

  @override
  Widget build(BuildContext context) {
    final scores = weeklyScores.length == 4
        ? weeklyScores
        : List.filled(4, 0.0);
    final maxScore = scores.fold<double>(0, math.max);

    return Container(
      height: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdhanColors.glassLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AdhanColors.glassDark),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(4, (i) {
                final norm = maxScore > 0 ? scores[i] / 100 : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${scores[i].round()}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AdhanColors.goldLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          height: 60 * norm.clamp(0.05, 1.0),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AdhanColors.emeraldGlow,
                                AdhanColors.emeraldDark,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4']
                .map(
                  (w) => Text(
                    w,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AdhanColors.mutedWhite,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Streak badges ─────────────────────────────────────────────────────────────

class _StreakBadges extends StatelessWidget {
  final MonthlyStatsLoaded state;
  const _StreakBadges({required this.state});

  @override
  Widget build(BuildContext context) {
    final badges = [
      _BadgeData(
        emoji: '🔥',
        title: '${state.longestStreak}-Day Streak',
        subtitle: 'Longest perfect streak',
        color: const Color(0xFFFF7043),
      ),
      if (state.completionPct >= 80)
        const _BadgeData(
          emoji: '🏆',
          title: 'High Performer',
          subtitle: '80%+ completion',
          color: AdhanColors.goldLight,
        ),
      if (state.completionPct == 100)
        const _BadgeData(
          emoji: '💎',
          title: 'Perfect Month',
          subtitle: 'All prayers completed',
          color: Color(0xFF64B5F6),
        ),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: badges.map((b) => _BadgeCard(data: b)).toList(),
    );
  }
}

class _BadgeData {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  const _BadgeData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

class _BadgeCard extends StatelessWidget {
  final _BadgeData data;
  const _BadgeCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 42) / 2,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: data.color.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            data.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: data.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.subtitle,
            style: const TextStyle(fontSize: 10, color: AdhanColors.mutedWhite),
          ),
        ],
      ),
    );
  }
}

// ── Most consistent prayer ────────────────────────────────────────────────────

class _MostConsistentCard extends StatelessWidget {
  final String prayer;
  const _MostConsistentCard({required this.prayer});

  static const _icons = {
    'Fajr': '🌅',
    'Dhuhr': '☀️',
    'Asr': '🌤️',
    'Maghrib': '🌇',
    'Isha': '🌙',
  };

  @override
  Widget build(BuildContext context) {
    final emoji = _icons[prayer] ?? '🕌';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x44D4A843), Color(0x220B2E46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdhanColors.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Most Consistent Prayer',
                style: TextStyle(fontSize: 12, color: AdhanColors.mutedWhite),
              ),
              const SizedBox(height: 4),
              Text(
                prayer,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AdhanColors.goldLight,
                ),
              ),
              const Text(
                'You rarely miss this prayer',
                style: TextStyle(fontSize: 11, color: AdhanColors.mutedWhite),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Arc painter ───────────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  final double progress;
  _ArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 7;
    const sw = 7.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AdhanColors.glassDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw,
    );

    if (progress <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..shader = const SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + 2 * math.pi,
          colors: [
            AdhanColors.emeraldMid,
            AdhanColors.emeraldGlow,
            AdhanColors.goldLight,
          ],
          stops: [0.0, 0.6, 1.0],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}
