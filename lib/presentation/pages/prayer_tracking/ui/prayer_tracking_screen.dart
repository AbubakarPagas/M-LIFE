import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../adhan/widgets/adhan_theme.dart';
import '../bloc/prayer_tracking_bloc.dart';
import '../data/models/prayer_record.dart';
import 'notification_center_screen.dart';
import 'widgets/calendar_view.dart';
import 'widgets/monthly_analytics.dart';
import 'widgets/weekly_analytics.dart';

/// Full Prayer Tracking Screen — tabs: Today | Calendar | Weekly | Monthly
class PrayerTrackingScreen extends StatelessWidget {
  const PrayerTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PrayerTrackingBloc()
        ..add(LoadRecordsEvent(DateTime.now()))
        ..add(LoadStreakEvent()),
      child: const _PrayerTrackingView(),
    );
  }
}

class _PrayerTrackingView extends StatefulWidget {
  const _PrayerTrackingView();

  @override
  State<_PrayerTrackingView> createState() => _PrayerTrackingViewState();
}

class _PrayerTrackingViewState extends State<_PrayerTrackingView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  DateTime _selectedDate = DateTime.now();

  static const _tabLabels = ['Today', 'Calendar', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdhanColors.bgGradientTop,
      body: Stack(
        children: [
          // Background gradient
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AdhanGradients.background),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _AppBar(
                  selectedDate: _selectedDate,
                  onNotificationTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationCenterScreen(),
                    ),
                  ),
                ),
                _TabBar(controller: _tabs, labels: _tabLabels),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _DailyTab(
                        date: _selectedDate,
                        onDateChanged: (d) => setState(() {
                          _selectedDate = d;
                          context.read<PrayerTrackingBloc>().add(
                            LoadRecordsEvent(d),
                          );
                        }),
                      ),
                      CalendarView(
                        onDateSelected: (d) {
                          setState(() => _selectedDate = d);
                          context.read<PrayerTrackingBloc>().add(
                            LoadRecordsEvent(d),
                          );
                          _tabs.animateTo(0);
                        },
                      ),
                      const WeeklyAnalyticsTab(),
                      MonthlyAnalyticsTab(
                        year: _selectedDate.year,
                        month: _selectedDate.month,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onNotificationTap;

  const _AppBar({required this.selectedDate, required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AdhanColors.glassMid,
                shape: BoxShape.circle,
                border: Border.all(color: AdhanColors.glassDark),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AdhanColors.softWhite,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Prayer Tracker',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AdhanColors.pureWhite,
                ),
              ),
              Text(
                DateFormat('EEEE, d MMM yyyy').format(selectedDate),
                style: const TextStyle(
                  fontSize: 12,
                  color: AdhanColors.mutedWhite,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Notification bell
          _NotifBell(onTap: onNotificationTap),
        ],
      ),
    );
  }
}

class _NotifBell extends StatelessWidget {
  final VoidCallback onTap;
  const _NotifBell({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AdhanColors.glassMid,
          shape: BoxShape.circle,
          border: Border.all(color: AdhanColors.glassDark),
        ),
        child: const Icon(
          Icons.notifications_outlined,
          size: 18,
          color: AdhanColors.goldLight,
        ),
      ),
    );
  }
}

// ── Tab bar ───────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final TabController controller;
  final List<String> labels;

  const _TabBar({required this.controller, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AdhanColors.glassLight,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AdhanColors.glassDark),
        ),
        child: TabBar(
          controller: controller,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AdhanColors.emeraldMid, AdhanColors.emeraldDark],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AdhanColors.pureWhite,
          unselectedLabelColor: AdhanColors.mutedWhite,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          padding: const EdgeInsets.all(3),
          tabs: labels.map((l) => Tab(text: l)).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily Tab
// ─────────────────────────────────────────────────────────────────────────────

class _DailyTab extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;

  const _DailyTab({required this.date, required this.onDateChanged});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTrackingBloc, PrayerTrackingState>(
      builder: (ctx, state) {
        if (state is PrayerTrackingLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AdhanColors.emeraldGlow),
          );
        }

        PrayerRecord record;
        int streak = 0;

        if (state is DailyRecordLoaded) {
          record = state.record;
          streak = state.streak;
        } else {
          record = PrayerRecord(date: PrayerRecord.dateKey(date));
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          physics: const BouncingScrollPhysics(),
          children: [
            // Summary card
            _DailySummaryCard(record: record, streak: streak),
            const SizedBox(height: 16),
            // Date navigation
            _DatePicker(date: date, onChanged: onDateChanged),
            const SizedBox(height: 16),
            // Prayer rows
            ..._buildPrayerRows(ctx, record),
          ],
        );
      },
    );
  }

  List<Widget> _buildPrayerRows(BuildContext ctx, PrayerRecord record) {
    final statuses = record.statuses;
    return List.generate(5, (i) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _PrayerStatusRow(
          prayerName: PrayerRecord.prayerNames[i],
          prayerIndex: i,
          status: statuses[i],
          timestamp: [
            record.fajrTimestamp,
            record.dhuhrTimestamp,
            record.asrTimestamp,
            record.maghribTimestamp,
            record.ishaTimestamp,
          ][i],
          onStatusChanged: (newStatus) {
            ctx.read<PrayerTrackingBloc>().add(
              UpdatePrayerStatusEvent(
                dateKey: record.date,
                prayerIndex: i,
                status: newStatus,
              ),
            );
          },
        ),
      );
    });
  }
}

// ── Daily summary card ────────────────────────────────────────────────────────

class _DailySummaryCard extends StatelessWidget {
  final PrayerRecord record;
  final int streak;

  const _DailySummaryCard({required this.record, required this.streak});

  @override
  Widget build(BuildContext context) {
    final pct = record.completionPercentage / 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x550D5C3D), Color(0x330E7C53), Color(0x220B2E46)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AdhanColors.emeraldGlow.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Progress ring
          SizedBox(
            width: 80,
            height: 80,
            child: CustomPaint(
              painter: _DonutPainter(progress: pct),
              child: Center(
                child: Text(
                  '${record.completionPercentage.round()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AdhanColors.pureWhite,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatRow(
                  label: 'Completed',
                  value: '${record.completedCount}/5',
                  color: AdhanColors.emeraldGlow,
                ),
                const SizedBox(height: 6),
                _StatRow(
                  label: 'Score',
                  value: '${record.worshipScore}/100',
                  color: AdhanColors.goldLight,
                ),
                const SizedBox(height: 6),
                _StatRow(
                  label: 'Streak',
                  value: '$streak days 🔥',
                  color: AdhanColors.gold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow({
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
          style: TextStyle(
            fontSize: 12,
            color: AdhanColors.mutedWhite.withValues(alpha: 0.7),
          ),
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

// ── Donut painter ─────────────────────────────────────────────────────────────

class _DonutPainter extends CustomPainter {
  final double progress;
  _DonutPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const sw = 8.0;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AdhanColors.glassDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw,
    );

    if (progress <= 0) return;

    // Arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final shader = const SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + 2 * math.pi,
      colors: [
        AdhanColors.emeraldMid,
        AdhanColors.emeraldGlow,
        AdhanColors.goldLight,
      ],
      stops: [0.0, 0.6, 1.0],
    ).createShader(rect);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.progress != progress;
}

// ── Date picker row ───────────────────────────────────────────────────────────

class _DatePicker extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _DatePicker({required this.date, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NavBtn(
          icon: Icons.chevron_left_rounded,
          onTap: () => onChanged(date.subtract(const Duration(days: 1))),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AdhanColors.emeraldGlow,
                      onPrimary: AdhanColors.pureWhite,
                      surface: AdhanColors.bgGradientMid,
                      onSurface: AdhanColors.pureWhite,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) onChanged(picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AdhanColors.glassMid,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdhanColors.glassDark),
              ),
              child: Text(
                DateFormat('EEEE, d MMMM yyyy').format(date),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AdhanColors.pureWhite,
                ),
              ),
            ),
          ),
        ),
        _NavBtn(
          icon: Icons.chevron_right_rounded,
          onTap: date.isBefore(DateTime.now())
              ? () => onChanged(date.add(const Duration(days: 1)))
              : null,
        ),
      ],
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: onTap != null ? AdhanColors.glassMid : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: onTap != null ? AdhanColors.glassDark : Colors.transparent,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null
              ? AdhanColors.softWhite
              : AdhanColors.mutedWhite.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

// ── Prayer status row ─────────────────────────────────────────────────────────

class _PrayerStatusRow extends StatelessWidget {
  final String prayerName;
  final int prayerIndex;
  final PrayerStatus status;
  final String? timestamp;
  final ValueChanged<PrayerStatus> onStatusChanged;

  const _PrayerStatusRow({
    required this.prayerName,
    required this.prayerIndex,
    required this.status,
    required this.onStatusChanged,
    this.timestamp,
  });

  static const _prayerIcons = ['🌅', '☀️', '🌤️', '🌇', '🌙'];

  @override
  Widget build(BuildContext context) {
    final isCompleted = status.countsAsCompleted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isCompleted
            ? AdhanColors.emeraldMid.withValues(alpha: 0.2)
            : AdhanColors.glassLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted
              ? AdhanColors.emeraldGlow.withValues(alpha: 0.5)
              : AdhanColors.glassDark,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Icon
            Text(
              _prayerIcons[prayerIndex],
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 12),
            // Name + timestamp
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayerName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isCompleted
                          ? AdhanColors.emeraldGlow
                          : AdhanColors.pureWhite,
                    ),
                  ),
                  if (timestamp != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('HH:mm').format(DateTime.parse(timestamp!)),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AdhanColors.mutedWhite,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Status badge / picker
            _StatusPickerButton(current: status, onChanged: onStatusChanged),
          ],
        ),
      ),
    );
  }
}

class _StatusPickerButton extends StatelessWidget {
  final PrayerStatus current;
  final ValueChanged<PrayerStatus> onChanged;

  const _StatusPickerButton({required this.current, required this.onChanged});

  static const _options = [
    PrayerStatus.completed,
    PrayerStatus.congregation,
    PrayerStatus.mosque,
    PrayerStatus.home,
    PrayerStatus.late,
    PrayerStatus.missed,
    PrayerStatus.pending,
  ];

  Color _statusColor(PrayerStatus s) {
    return switch (s) {
      PrayerStatus.completed => AdhanColors.emeraldGlow,
      PrayerStatus.congregation => const Color(0xFF8BC34A),
      PrayerStatus.mosque => const Color(0xFF4CAF50),
      PrayerStatus.home => AdhanColors.emeraldMid,
      PrayerStatus.late => AdhanColors.gold,
      PrayerStatus.missed => const Color(0xFFEF5350),
      PrayerStatus.pending => AdhanColors.mutedWhite,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(current);

    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(current.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              current.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AdhanColors.bgGradientMid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AdhanColors.glassDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Set Prayer Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AdhanColors.pureWhite,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _options.map((s) {
                final isActive = s == current;
                final c = _statusColor(s);
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onChanged(s);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? c.withValues(alpha: 0.25)
                          : AdhanColors.glassMid,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? c : AdhanColors.glassDark,
                        width: isActive ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(s.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          s.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isActive ? c : AdhanColors.mutedWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
