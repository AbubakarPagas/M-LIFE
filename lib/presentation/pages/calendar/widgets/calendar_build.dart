part of '../events.dart';

class CalendarBuild extends StatelessWidget {
  final int firstDayWeekday;
  final int daysInMonth;
  final HijriDate month;
  CalendarBuild({
    super.key,
    required this.firstDayWeekday,
    required this.daysInMonth,
    required this.month,
  });

  final eventCtrl = EventController.instance;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const int rows = 6;
        const int cols = 7;
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        final spacing = availableHeight < 300 ? 3.5 : 6.0;
        final fontSize = availableHeight < 300 ? 12.0 : 15.0;

        final cellWidth = (availableWidth - (cols - 1) * spacing) / cols;
        final cellHeight = (availableHeight - (rows - 1) * spacing - 16) / rows;
        final aspectRatio = (cellHeight > 0 && cellWidth > 0)
            ? cellWidth / cellHeight
            : 1.5;

        final accentColor = context.theme.colorScheme.surface;
        final canvasCol = context.theme.canvasColor;
        final containerCol = context.theme.colorScheme.primaryContainer;

        return GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 1.0),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            childAspectRatio: aspectRatio,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            final dayOffset = index - firstDayWeekday + 1;
            if (dayOffset < 1 || dayOffset > daysInMonth) {
              return const SizedBox();
            }

            final isCurrentDay = eventCtrl.isCurrentDay(month, dayOffset);
            final List<int> myMonths = [month.hMonth];
            final bool hasEvent = eventCtrl.isEvent(myMonths, dayOffset);
            final bool isReminder = hasEvent &&
                (eventCtrl.getIsReminder(myMonths, dayOffset)?.isReminder ??
                    false);

            // ─── Today: filled accent circle with glow ─────────────────
            BoxDecoration cellDecoration;
            if (isCurrentDay) {
              cellDecoration = BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    accentColor,
                    accentColor.withValues(alpha: .75),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: .45),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              );
            } else if (hasEvent && isReminder) {
              // Reminder event: outlined accent border
              cellDecoration = BoxDecoration(
                color: accentColor.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: accentColor.withValues(alpha: .55),
                  width: 1.1,
                ),
              );
            } else if (hasEvent) {
              // Non-reminder event: subtle tinted cell
              cellDecoration = BoxDecoration(
                color: canvasCol.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: canvasCol.withValues(alpha: .20),
                  width: 0.8,
                ),
              );
            } else {
              // Regular day: very subtle glass cell
              cellDecoration = BoxDecoration(
                color: canvasCol.withValues(alpha: .04),
                borderRadius: BorderRadius.circular(10),
              );
            }

            return GestureDetector(
              onTap: hasEvent
                  ? () => eventCtrl.showEvent(dayOffset, month.hMonth)
                  : null,
              child: Container(
                decoration: cellDecoration,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ─── Day number ──────────────────────────────────────
                    Center(
                      child: Text(
                        dayOffset.toString().convertNumbersToCurrentLang(),
                        style: AppTextStyles.titleMedium().copyWith(
                          fontSize: fontSize,
                          height: 1.5,
                          color: isCurrentDay
                              ? containerCol
                              : hasEvent
                                  ? isReminder
                                      ? accentColor
                                      : canvasCol.withValues(alpha: .85)
                                  : canvasCol.withValues(alpha: .78),
                          fontWeight: isCurrentDay
                              ? FontWeight.w700
                              : hasEvent
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                        ),
                      ),
                    ),
                    // ─── Tiny event dot at bottom ────────────────────────
                    if (hasEvent && !isCurrentDay)
                      Positioned(
                        bottom: 2,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(
                              alpha: isReminder ? .90 : .55,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
