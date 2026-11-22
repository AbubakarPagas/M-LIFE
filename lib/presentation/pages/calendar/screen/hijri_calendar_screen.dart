part of '../events.dart';

class HijriCalendarScreen extends StatelessWidget {
  HijriCalendarScreen({super.key});

  final eventsCtrl = EventController.instance;

  @override
  Widget build(BuildContext context) {
    eventsCtrl.resetDate();
    eventsCtrl.ensureViewportFraction(MediaQuery.orientationOf(context));
    return GetBuilder<EventController>(
      builder: (eventCtrl) => Scaffold(
        backgroundColor: context.theme.colorScheme.primary,
        body: Stack(
          children: [
            // ─── Geometric Islamic background decoration ───────────────────
            Positioned.fill(child: _IslamicBackground()),
            SafeArea(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Portrait: calendar + bottom sheet
                  // Landscape: split left panel + right calendar
                  context.customOrientation(
                    const SizedBox.shrink(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _pageViewBuild(context, eventCtrl),
                    ),
                  ),
                  context.customOrientation(
                    Stack(
                      children: [
                        _valueListenableBuilderWidget(eventCtrl),
                        CustomSheetWidget(
                          controller: eventCtrl.controller,
                          scrollController: eventCtrl.scrollController,
                          minSheetOffset: 0.2,
                          maxSheetOffset: 0.65,
                          child: AllCalculatingEventsWidget(),
                        ),
                      ],
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FractionallySizedBox(
                        alignment: AlignmentDirectional.centerStart,
                        widthFactor: .5,
                        child: Column(
                          children: [
                            const Gap(8),
                            HijriWidget(
                              isInCalendar: true,
                              width: double.infinity,
                            ),
                            const Gap(8),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      context.theme.colorScheme.primaryContainer
                                          .withValues(alpha: .95),
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: Border.all(
                                    color: context.theme.colorScheme.surface
                                        .withValues(alpha: .25),
                                    width: 1,
                                  ),
                                ),
                                child: AllCalculatingEventsWidget(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  TopBarWidget(
                    isHomeChild: true,
                    isQuranSetting: false,
                    isNotification: false,
                    isCalendarSetting: true,
                    tabBarController: EventController.instance.tabBarController,
                    squareColor: context.theme.primaryColorLight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ValueListenableBuilder<double?> _valueListenableBuilderWidget(
    EventController eventCtrl,
  ) {
    return ValueListenableBuilder(
      valueListenable: eventCtrl.controller,
      builder: (context, offset, child) {
        final isSheetOpen = offset != null && offset > Get.height * .3;
        return Column(
          children: [
            if (isSheetOpen) ...[
              const Gap(80),
              context.customOrientation(
                HijriWidget(isInCalendar: true),
                const SizedBox.shrink(),
              ),
            ],
            if (!isSheetOpen) ...[
              const Gap(16.0),
              context.customOrientation(
                _pageViewBuild(context, eventCtrl),
                const SizedBox.shrink(),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _pageViewBuild(BuildContext context, EventController eventCtrl) {
    return Align(
      alignment: context.customOrientation(
        Alignment.center,
        AlignmentDirectional.centerEnd,
      ),
      child: SizedBox(
        height: context.customOrientation(Get.height * .8, Get.height * .9),
        width: context.customOrientation(Get.width, Get.width * .4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            context.customOrientation(const SizedBox.shrink(), const Gap(72)),
            Expanded(
              child: PageView.builder(
                padEnds: true,
                scrollDirection: Axis.vertical,
                controller: eventCtrl.pageController,
                onPageChanged: eventCtrl.onMonthChanged,
                physics: const ClampingScrollPhysics(),
                itemCount: 12,
                itemBuilder: (context, monthIndex) {
                  eventCtrl.calenderMonth.value = eventCtrl.months[monthIndex];
                  final daysInMonth = eventCtrl.getDaysInMonth(
                    eventCtrl.calenderMonth.value,
                    eventCtrl.calenderMonth.value.hYear,
                    eventCtrl.calenderMonth.value.hMonth,
                  );
                  final firstDayWeekday = eventCtrl.calculateFirstDayOfMonth(
                    eventCtrl.calenderMonth.value.hMonth,
                    eventCtrl.calenderMonth.value.hYear,
                  );
                  final controller = eventCtrl.pageController;
                  final currentPage =
                      controller.hasClients && controller.positions.length == 1
                      ? controller.page?.round()
                      : null;
                  final isActive = monthIndex == currentPage;

                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOut,
                    opacity: isActive ? 1.0 : 0.45,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOut,
                      scale: isActive ? 1.0 : 0.96,
                      child: _CalendarMonthCard(
                        monthIndex: monthIndex,
                        eventCtrl: eventCtrl,
                        daysInMonth: daysInMonth,
                        firstDayWeekday: firstDayWeekday,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  _IslamicBackground — subtle geometric ornament drawn with CustomPainter
// ════════════════════════════════════════════════════════════════════════════
class _IslamicBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _IslamicPatternPainter(
        accentColor: context.theme.colorScheme.surface,
        baseColor: context.theme.colorScheme.primary,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  final Color accentColor;
  final Color baseColor;

  _IslamicPatternPainter({required this.accentColor, required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor.withValues(alpha: 0.055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // ─── Top-right star rosette ──────────────────────────────────────────
    _drawStarRosette(canvas, Offset(size.width * 0.88, size.height * 0.06),
        size.width * 0.22, paint);

    // ─── Bottom-left star rosette ────────────────────────────────────────
    _drawStarRosette(canvas, Offset(size.width * 0.1, size.height * 0.92),
        size.width * 0.18, paint);

    // ─── Crescent + star at top-center ───────────────────────────────────
    final crescentPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;
    _drawCrescent(canvas, Offset(size.width * 0.5, size.height * 0.03),
        size.width * 0.065, crescentPaint);

    // ─── Thin arched border lines (decorative frame) ─────────────────────
    final framePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final inset = size.width * 0.045;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(inset, inset, size.width - inset * 2, size.height - inset * 2),
      const Radius.circular(32),
    );
    canvas.drawRRect(rrect, framePaint);

    // ─── Second inner frame ───────────────────────────────────────────────
    final inset2 = inset + 6;
    final rrect2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(inset2, inset2, size.width - inset2 * 2, size.height - inset2 * 2),
      const Radius.circular(28),
    );
    canvas.drawRRect(rrect2, framePaint);
  }

  void _drawStarRosette(Canvas canvas, Offset center, double r, Paint paint) {
    const int points = 8;
    for (int i = 0; i < points; i++) {
      final angle1 = (i * 2 * math.pi) / points;
      final angle2 = angle1 + math.pi / points;
      final p1 = Offset(center.dx + r * math.cos(angle1), center.dy + r * math.sin(angle1));
      final p2 = Offset(center.dx + r * math.cos(angle2), center.dy + r * math.sin(angle2));
      final pm = Offset(center.dx + (r * 0.42) * math.cos(angle1 + math.pi / points),
                        center.dy + (r * 0.42) * math.sin(angle1 + math.pi / points));
      canvas.drawLine(p1, pm, paint);
      canvas.drawLine(pm, p2, paint);
    }
    // inner circle
    canvas.drawCircle(center, r * 0.28, paint);
    canvas.drawCircle(center, r * 0.52, paint);
    canvas.drawCircle(center, r,        paint);
  }

  void _drawCrescent(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: r))
      ..addOval(Rect.fromCircle(
        center: Offset(center.dx + r * 0.45, center.dy),
        radius: r * 0.78,
      ));
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_IslamicPatternPainter old) =>
      old.accentColor != accentColor || old.baseColor != baseColor;
}

// ════════════════════════════════════════════════════════════════════════════
//  _CalendarMonthCard — beautiful month card with glassmorphic feel
// ════════════════════════════════════════════════════════════════════════════
class _CalendarMonthCard extends StatelessWidget {
  final int monthIndex;
  final EventController eventCtrl;
  final int daysInMonth;
  final int firstDayWeekday;

  const _CalendarMonthCard({
    required this.monthIndex,
    required this.eventCtrl,
    required this.daysInMonth,
    required this.firstDayWeekday,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = context.theme.colorScheme.surface;
    final canvasCol = context.theme.canvasColor;
    final containerCol = context.theme.colorScheme.primaryContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: containerCol.withValues(alpha: .10),
          border: Border.all(
            color: accentColor.withValues(alpha: .22),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              // ─── Month header ──────────────────────────────────────────
              _MonthHeader(
                eventCtrl: eventCtrl,
                accentColor: accentColor,
                canvasColor: canvasCol,
                containerCol: containerCol,
              ),
              // ─── Thin golden divider line ──────────────────────────────
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      accentColor.withValues(alpha: .55),
                      accentColor.withValues(alpha: .55),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),
              const Gap(6),
              // ─── Day-of-week labels ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: _StyledDaysName(
                  eventCtrl: eventCtrl,
                  accentColor: accentColor,
                  canvasColor: canvasCol,
                ),
              ),
              const Gap(4),
              // ─── Calendar grid ─────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: CalendarBuild(
                    daysInMonth: daysInMonth,
                    firstDayWeekday: firstDayWeekday,
                    month: eventCtrl.calenderMonth.value,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  _MonthHeader — the top section with SVG month name, year, and ornamental arc
// ════════════════════════════════════════════════════════════════════════════
class _MonthHeader extends StatelessWidget {
  final EventController eventCtrl;
  final Color accentColor;
  final Color canvasColor;
  final Color containerCol;

  const _MonthHeader({
    required this.eventCtrl,
    required this.accentColor,
    required this.canvasColor,
    required this.containerCol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: .22),
            accentColor.withValues(alpha: .08),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ─── Hijri month SVG name ──────────────────────────────────────
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentColor.withValues(alpha: .30),
                      width: 1,
                    ),
                  ),
                  child: customSvgWithColor(
                    'assets/svg/hijri/${eventCtrl.calenderMonth.value.hMonth}.svg',
                    color: canvasColor,
                    height: 32,
                  ),
                ),
                const Gap(10),
                // ─── Gregorian month + year badge ────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      eventCtrl.gregorianMonthFormat,
                      style: AppTextStyles.titleSmall().copyWith(
                        color: canvasColor.withValues(alpha: .65),
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      eventCtrl.now.year.toString(),
                      style: AppTextStyles.titleSmall().copyWith(
                        color: canvasColor.withValues(alpha: .45),
                        fontSize: 11,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ─── Hijri year number with elegant pill ──────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: .40),
                  accentColor.withValues(alpha: .20),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accentColor.withValues(alpha: .45),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: .15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  eventCtrl.calenderMonth.value.hYear
                      .toString()
                      .convertNumbersToCurrentLang(),
                  style: AppTextStyles.titleLarge().copyWith(
                    color: canvasColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const Gap(4),
                Text(
                  'هـ',
                  style: AppTextStyles.titleSmall().copyWith(
                    color: canvasColor.withValues(alpha: .75),
                    fontSize: 13,
                    height: 1.2,
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

// ════════════════════════════════════════════════════════════════════════════
//  _StyledDaysName — weekday header row with Islamic Friday highlight
// ════════════════════════════════════════════════════════════════════════════
class _StyledDaysName extends StatelessWidget {
  final EventController eventCtrl;
  final Color accentColor;
  final Color canvasColor;

  const _StyledDaysName({
    required this.eventCtrl,
    required this.accentColor,
    required this.canvasColor,
  });

  @override
  Widget build(BuildContext context) {
    // Week order: Sun=0, Mon=1, Tue=2, Wed=3, Thu=4, Fri=5, Sat=6
    const int fridayIndex = 5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final isFriday = index == fridayIndex;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: isFriday
                ? BoxDecoration(
                    color: accentColor.withValues(alpha: .22),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: accentColor.withValues(alpha: .40),
                      width: 0.8,
                    ),
                  )
                : null,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                eventCtrl.getWeekdayShortName(index).tr,
                style: AppTextStyles.titleMedium().copyWith(
                  color: isFriday
                      ? accentColor
                      : canvasColor.withValues(alpha: .75),
                  fontSize: 13,
                  fontWeight:
                      isFriday ? FontWeight.w700 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }),
    );
  }
}
