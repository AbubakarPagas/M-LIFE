import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../adhan/widgets/adhan_theme.dart';
import '../../bloc/prayer_tracking_bloc.dart';
import '../../data/models/prayer_record.dart';

/// Monthly calendar grid with colour-coded day cells.
class CalendarView extends StatefulWidget {
  final ValueChanged<DateTime> onDateSelected;
  const CalendarView({required this.onDateSelected, super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _viewing; // year+month being shown

  @override
  void initState() {
    super.initState();
    _viewing = DateTime(DateTime.now().year, DateTime.now().month);
    _loadMonth();
  }

  void _loadMonth() {
    context.read<PrayerTrackingBloc>().add(
      LoadMonthEvent(_viewing.year, _viewing.month),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTrackingBloc, PrayerTrackingState>(
      buildWhen: (_, s) =>
          s is MonthCalendarLoaded || s is PrayerTrackingLoading,
      builder: (ctx, state) {
        final records = state is MonthCalendarLoaded
            ? state.records
            : <String, PrayerRecord>{};
        final isLoading = state is PrayerTrackingLoading;

        return ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          children: [
            // Month navigation
            _MonthNav(
              viewing: _viewing,
              onPrev: () => setState(() {
                _viewing = DateTime(_viewing.year, _viewing.month - 1);
                _loadMonth();
              }),
              onNext: () {
                final now = DateTime.now();
                final next = DateTime(_viewing.year, _viewing.month + 1);
                if (!next.isAfter(DateTime(now.year, now.month))) {
                  setState(() {
                    _viewing = next;
                    _loadMonth();
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            // Legend
            _Legend(),
            const SizedBox(height: 12),
            // Grid
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(
                    color: AdhanColors.emeraldGlow,
                  ),
                ),
              )
            else
              _CalendarGrid(
                year: _viewing.year,
                month: _viewing.month,
                records: records,
                onDayTap: widget.onDateSelected,
              ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

// ── Month navigation header ───────────────────────────────────────────────────

class _MonthNav extends StatelessWidget {
  final DateTime viewing;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthNav({
    required this.viewing,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: AdhanColors.glassLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdhanColors.glassDark),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: AdhanColors.softWhite,
            ),
            onPressed: onPrev,
          ),
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy').format(viewing),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AdhanColors.pureWhite,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.chevron_right_rounded,
              color: AdhanColors.softWhite,
            ),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

// ── Legend ────────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      _LegendItem(color: Color(0xFF4CAF50), label: 'All Prayers'),
      _LegendItem(color: Color(0xFFFFC107), label: 'Partial'),
      _LegendItem(color: Color(0xFFEF5350), label: 'Missed'),
      _LegendItem(color: AdhanColors.glassDark, label: 'None'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items
          .map(
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: i,
            ),
          )
          .toList(),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AdhanColors.mutedWhite),
        ),
      ],
    );
  }
}

// ── Calendar grid ─────────────────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  final int year;
  final int month;
  final Map<String, PrayerRecord> records;
  final ValueChanged<DateTime> onDayTap;

  const _CalendarGrid({
    required this.year,
    required this.month,
    required this.records,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstWeekday = DateTime(year, month, 1).weekday % 7; // Sun=0
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdhanColors.glassLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdhanColors.glassDark),
      ),
      child: Column(
        children: [
          // Day-of-week header
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AdhanColors.goldLight,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          // Day cells
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: daysInMonth + firstWeekday,
            itemBuilder: (_, index) {
              if (index < firstWeekday) return const SizedBox();
              final day = index - firstWeekday + 1;
              final date = DateTime(year, month, day);
              final dateKey = PrayerRecord.dateKey(date);
              final record = records[dateKey];
              final isFuture = date.isAfter(today);
              final isToday =
                  date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;

              return GestureDetector(
                onTap: isFuture ? null : () => onDayTap(date),
                child: _DayCell(
                  day: day,
                  record: record,
                  isToday: isToday,
                  isFuture: isFuture,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final PrayerRecord? record;
  final bool isToday;
  final bool isFuture;

  const _DayCell({
    required this.day,
    required this.record,
    required this.isToday,
    required this.isFuture,
  });

  Color get _cellColor {
    if (isFuture || record == null) {
      return AdhanColors.glassLight;
    }
    final pct = record!.completionPercentage;
    if (pct == 100) return const Color(0xFF4CAF50);
    if (pct >= 60) return const Color(0xFFFFC107);
    if (pct > 0) return const Color(0xFFFF7043);
    return const Color(0xFFEF5350);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cellColor.withValues(alpha: isFuture ? 0.05 : 0.25),
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: AdhanColors.goldLight, width: 1.5)
            : Border.all(
                color: _cellColor.withValues(alpha: isFuture ? 0.1 : 0.4),
                width: 1,
              ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$day',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
              color: isFuture
                  ? AdhanColors.mutedWhite.withValues(alpha: 0.3)
                  : AdhanColors.pureWhite,
            ),
          ),
          if (record != null && !isFuture) ...[
            const SizedBox(height: 2),
            Text(
              '${record!.completedCount}/5',
              style: TextStyle(
                fontSize: 8,
                color: _cellColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
