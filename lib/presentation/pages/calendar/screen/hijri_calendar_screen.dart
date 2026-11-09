part of '../events.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen>
    with TickerProviderStateMixin {
  final eventsCtrl = EventController.instance;

  late AnimationController _entranceCtrl;
  late AnimationController _calendarCtrl;
  late AnimationController _panelCtrl;

  // Entrance animations
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _calendarFade;
  late Animation<double> _calendarScale;
  late Animation<double> _panelFade;
  late Animation<Offset> _panelSlide;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _calendarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _panelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _headerFade = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.25), end: Offset.zero).animate(
          CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic),
        );

    _calendarFade = CurvedAnimation(
      parent: _calendarCtrl,
      curve: Curves.easeOut,
    );
    _calendarScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _calendarCtrl, curve: Curves.easeOutCubic),
    );

    _panelFade = CurvedAnimation(parent: _panelCtrl, curve: Curves.easeOut);
    _panelSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _panelCtrl, curve: Curves.easeOutCubic));

    _entranceCtrl.forward();
    Future.delayed(
      const Duration(milliseconds: 160),
      () => mounted ? _calendarCtrl.forward() : null,
    );
    Future.delayed(
      const Duration(milliseconds: 320),
      () => mounted ? _panelCtrl.forward() : null,
    );
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _calendarCtrl.dispose();
    _panelCtrl.dispose();
    super.dispose();
  }

  // ── convenience ───────────────────────────────────────────────────────────
  Color get _primary => Get.theme.colorScheme.primary;
  Color get _surface => Get.theme.colorScheme.surface;
  Color get _container => Get.theme.colorScheme.primaryContainer;
  Color get _canvas => Get.theme.canvasColor;

  @override
  Widget build(BuildContext context) {
    eventsCtrl.resetDate();
    return GetBuilder<EventController>(
      builder: (ctrl) => Scaffold(
        backgroundColor: _primary,
        body: SafeArea(
          child: Stack(
            children: [
              // ── global decorative background ────────────────────────────
              Positioned.fill(child: _buildBackground()),

              Container(
                color: Colors.transparent,
                child: SlidingBox(
                  controller: ctrl.boxController,
                  minHeight: context.customOrientation(250.0, 70.0),
                  maxHeight: Get.height * .82,
                  color: Colors.transparent,
                  style: BoxStyle.none,
                  physics: const ClampingScrollPhysics(),
                  animationCurve: Curves.easeInOutCubic,
                  animationDuration: const Duration(milliseconds: 380),
                  draggableIconVisible: false,
                  collapsed: true,
                  borderRadius: const BorderRadius.all(Radius.circular(0)),
                  backdrop: Backdrop(
                    fading: false,
                    overlay: false,
                    body: Column(
                      children: [
                        // ── top nav ──────────────────────────────────────
                        TopBarWidget(
                          isHomeChild: true,
                          isQuranSetting: false,
                          isNotification: false,
                          isCalendarSetting: true,
                          tabBarController:
                              EventController.instance.tabBarController,
                          squareColor: context.theme.primaryColorLight,
                        ),
                        // ── content ──────────────────────────────────────
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: context.customOrientation(
                              _buildPortrait(context, ctrl),
                              _buildLandscape(context, ctrl),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  body: SlideTransition(
                    position: _panelSlide,
                    child: FadeTransition(
                      opacity: _panelFade,
                      child: _buildEventsPanel(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Decorative geometric background
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildBackground() {
    return IgnorePointer(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_primary, _container, _container],
                stops: const [0.0, 0.38, 1.0],
              ),
            ),
          ),
          // top-right corner ornament
          Positioned(
            top: -30,
            right: -30,
            child: Opacity(
              opacity: 0.07,
              child: SvgPicture.asset(
                'assets/svg/decorations.svg',
                width: 200,
                colorFilter: ColorFilter.mode(_surface, BlendMode.srcIn),
              ),
            ),
          ),
          // bottom-left corner ornament
          Positioned(
            bottom: 60,
            left: -30,
            child: Opacity(
              opacity: 0.05,
              child: SvgPicture.asset(
                'assets/svg/decorations.svg',
                width: 160,
                colorFilter: ColorFilter.mode(_surface, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Portrait layout
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildPortrait(BuildContext context, EventController ctrl) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          const Gap(12),
          // ── hero header card ──────────────────────────────────────────
          SlideTransition(
            position: _headerSlide,
            child: FadeTransition(
              opacity: _headerFade,
              child: _buildHeroCard(context),
            ),
          ),
          const Gap(16),
          // ── year / month pickers ──────────────────────────────────────
          FadeTransition(opacity: _calendarFade, child: _buildSelectors()),
          const Gap(14),
          // ── day-name row ──────────────────────────────────────────────
          ScaleTransition(
            scale: _calendarScale,
            child: FadeTransition(
              opacity: _calendarFade,
              child: _buildDayNames(context),
            ),
          ),
          const Gap(8),
          // ── month grid ───────────────────────────────────────────────
          ScaleTransition(
            scale: _calendarScale,
            child: FadeTransition(
              opacity: _calendarFade,
              child: SizedBox(
                height: 255,
                child: _buildPageView(ctrl, portrait: true),
              ),
            ),
          ),
          const Gap(10),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Landscape layout
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildLandscape(BuildContext context, EventController ctrl) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: FadeTransition(
            opacity: _calendarFade,
            child: Column(
              children: [
                const Gap(8),
                _buildSelectors(),
                const Gap(12),
                _buildDayNames(context),
                const Gap(8),
                SizedBox(
                  height: 200,
                  child: _buildPageView(ctrl, portrait: false),
                ),
              ],
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          flex: 4,
          child: SlideTransition(
            position: _headerSlide,
            child: FadeTransition(
              opacity: _headerFade,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_buildHeroCard(context)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Hero header card — month art + date info
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildHeroCard(BuildContext context) {
    final h = eventsCtrl.hijriNow;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primary.withValues(alpha: .92),
            _primary.withValues(alpha: .80),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _surface.withValues(alpha: .22), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: .35),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // ── large faded month art ───────────────────────────────────
            Positioned(
              right: -10,
              top: -10,
              bottom: -10,
              child: Opacity(
                opacity: 0.13,
                child: SvgPicture.asset(
                  'assets/svg/hijri/${h.hMonth}.svg',
                  height: 160,
                  colorFilter: ColorFilter.mode(_canvas, BlendMode.srcIn),
                ),
              ),
            ),
            // ── besmAllah watermark ─────────────────────────────────────
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Opacity(
                  opacity: 0.08,
                  child: SvgPicture.asset(
                    'assets/svg/besmAllah.svg',
                    width: 120,
                    colorFilter: ColorFilter.mode(_canvas, BlendMode.srcIn),
                  ),
                ),
              ),
            ),

            // ── content ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Month illustration (focused)
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: _surface.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _surface.withValues(alpha: .25),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: ShaderMask(
                        shaderCallback: (r) => LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [_surface, _surface.withValues(alpha: .55)],
                        ).createShader(r),
                        child: SvgPicture.asset(
                          'assets/svg/hijri/${h.hMonth}.svg',
                          height: 60,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(16),

                  // Date info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Month name
                        Text(
                          h.getLongMonthName().tr,
                          style: TextStyle(
                            fontFamily: 'naskh',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _canvas,
                            height: 1.2,
                          ),
                        ),
                        const Gap(4),
                        // Year pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _surface.withValues(alpha: .18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _surface.withValues(alpha: .3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${h.hYear} ${'AH'.tr}'
                                .convertNumbersToCurrentLang(),
                            style: TextStyle(
                              fontFamily: 'kufi',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _surface,
                            ),
                          ),
                        ),
                        const Gap(10),
                        // Today chip
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _surface,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _surface.withValues(alpha: .6),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const Gap(6),
                            Text(
                              '${'today'.tr}: ${h.hDay.toString().convertNumbersToCurrentLang()} ${h.getLongMonthName().tr}',
                              style: TextStyle(
                                fontFamily: 'kufi',
                                fontSize: 12,
                                color: _canvas.withValues(alpha: .75),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── gold top accent line ────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 2.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      _surface.withValues(alpha: .7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Year / Month selectors row
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSelectors() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: _container.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _surface.withValues(alpha: .12), width: 1),
      ),
      child: Row(children: [YearSelection(), const Gap(8), MonthSelection()]),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Day names row
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildDayNames(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primary.withValues(alpha: .14),
            _primary.withValues(alpha: .08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _surface.withValues(alpha: .10), width: 1),
      ),
      child: DaysName(),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PageView wrapper
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildPageView(EventController ctrl, {required bool portrait}) {
    return PageView.builder(
      controller: ctrl.pageController,
      onPageChanged: ctrl.onMonthChanged,
      physics: const ClampingScrollPhysics(),
      itemCount: 12,
      itemBuilder: (context, monthIndex) {
        ctrl.calenderMonth.value = ctrl.months[monthIndex];
        final int daysInMonth;
        final int firstDayWeekday;

        if (portrait) {
          daysInMonth = ctrl.getDaysInMonth(
            ctrl.calenderMonth.value,
            ctrl.calenderMonth.value.hYear,
            ctrl.calenderMonth.value.hMonth,
          );
          firstDayWeekday = ctrl.calculateFirstDayOfMonth(
            ctrl.calenderMonth.value.hMonth,
            ctrl.calenderMonth.value.hYear,
          );
        } else {
          daysInMonth = ctrl.calenderMonth.value.getDaysInMonth(
            ctrl.calenderMonth.value.hYear,
            ctrl.calenderMonth.value.hMonth,
          );
          firstDayWeekday = ctrl.calenderMonth.value.weekDay();
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: Padding(
            key: ValueKey(
              '$monthIndex-${ctrl.calenderMonth.value.hYear}-$portrait',
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildGrid(
              context,
              daysInMonth: daysInMonth,
              firstDayWeekday: firstDayWeekday,
              month: ctrl.calenderMonth.value,
            ),
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Calendar grid
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildGrid(
    BuildContext context, {
    required int daysInMonth,
    required int firstDayWeekday,
    required HijriDate month,
  }) {
    final ctrl = EventController.instance;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _container.withValues(alpha: .65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _surface.withValues(alpha: .10), width: 1),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 2),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.25,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        itemCount: 42,
        itemBuilder: (context, index) {
          final day = index - firstDayWeekday + 1;
          if (day < 1 || day > daysInMonth) return const SizedBox.shrink();

          final isToday = ctrl.isCurrentDay(month, day);
          final hasEvent = ctrl.isEvent([month.hMonth], day);
          final bgColor = ctrl.getDayColor(isToday, [month.hMonth], day);

          return GestureDetector(
            onTap: hasEvent ? () => ctrl.showEvent(day, month.hMonth) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: isToday
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_surface, _surface.withValues(alpha: .82)],
                      )
                    : hasEvent
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _surface.withValues(alpha: .22),
                          _surface.withValues(alpha: .12),
                        ],
                      )
                    : null,
                color: (!isToday && !hasEvent) ? bgColor : null,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isToday
                      ? _surface.withValues(alpha: .55)
                      : hasEvent
                      ? _surface.withValues(alpha: .25)
                      : _primary.withValues(alpha: .08),
                  width: isToday ? 1.5 : 1,
                ),
                boxShadow: isToday
                    ? [
                        BoxShadow(
                          color: _surface.withValues(alpha: .35),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    day.toString().convertNumbersToCurrentLang(),
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday
                          ? _container
                          : Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  if (hasEvent && !isToday)
                    Positioned(
                      bottom: 2,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: _surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _surface.withValues(alpha: .5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Events sliding panel
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildEventsPanel(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.bottomEnd,
      child: Container(
        width: context.customOrientation(Get.width, Get.width * .4),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
          border: Border.all(width: 1, color: _surface.withValues(alpha: .22)),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -8),
              blurRadius: 28,
              spreadRadius: 0,
              color: _primary.withValues(alpha: .22),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_primary.withValues(alpha: .98), _primary],
              ),
            ),
            child: Stack(
              children: [
                // faint decorative art behind content
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Opacity(
                    opacity: 0.05,
                    child: SvgPicture.asset(
                      'assets/svg/decorations.svg',
                      width: 180,
                      colorFilter: ColorFilter.mode(_canvas, BlendMode.srcIn),
                    ),
                  ),
                ),
                AllCalculatingEventsWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
