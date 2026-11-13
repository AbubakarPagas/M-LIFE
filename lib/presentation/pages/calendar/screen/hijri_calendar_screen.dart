part of '../events.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen>
    with TickerProviderStateMixin {
  final eventsCtrl = EventController.instance;

  late AnimationController _masterCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _calFade;
  late Animation<Offset> _calSlide;
  late Animation<double> _panelFade;
  late Animation<Offset> _panelSlide;

  @override
  void initState() {
    super.initState();
    _masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _headerFade = CurvedAnimation(
      parent: _masterCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _calFade = CurvedAnimation(
      parent: _masterCtrl,
      curve: const Interval(0.2, 0.75, curve: Curves.easeOut),
    );
    _calSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.2, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _panelFade = CurvedAnimation(
      parent: _masterCtrl,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    _panelSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _masterCtrl.forward();
  }

  @override
  void dispose() {
    _masterCtrl.dispose();
    super.dispose();
  }

  // ── theme shortcuts ───────────────────────────────────────────────────────
  Color get _primary => Get.theme.colorScheme.primary;
  Color get _surface => Get.theme.colorScheme.surface;
  Color get _container => Get.theme.colorScheme.primaryContainer;
  Color get _onPrimary => Get.theme.colorScheme.onPrimary;
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
              Positioned.fill(child: _buildBackground()),
              SlidingBox(
                controller: ctrl.boxController,
                minHeight: context.customOrientation(260.0, 72.0),
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
                      TopBarWidget(
                        isHomeChild: true,
                        isQuranSetting: false,
                        isNotification: false,
                        isCalendarSetting: true,
                        tabBarController:
                            EventController.instance.tabBarController,
                        squareColor: context.theme.primaryColorLight,
                      ),
                      Expanded(
                        child: context.customOrientation(
                          _buildPortrait(context, ctrl),
                          _buildLandscape(context, ctrl),
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
            ],
          ),
        ),
      ),
    );
  }

  // ── background ────────────────────────────────────────────────────────────
  Widget _buildBackground() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _primary,
              Color.lerp(_primary, _container, 0.55)!,
              _container,
            ],
            stops: const [0.0, 0.42, 1.0],
          ),
        ),
      ),
    );
  }

  // ── portrait ──────────────────────────────────────────────────────────────
  Widget _buildPortrait(BuildContext context, EventController ctrl) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Gap(10),
          SlideTransition(
            position: _headerSlide,
            child: FadeTransition(
              opacity: _headerFade,
              child: _buildDateHeader(context),
            ),
          ),
          const Gap(14),
          SlideTransition(
            position: _calSlide,
            child: FadeTransition(
              opacity: _calFade,
              child: _buildNavRow(context, ctrl),
            ),
          ),
          const Gap(10),
          SlideTransition(
            position: _calSlide,
            child: FadeTransition(
              opacity: _calFade,
              child: _buildDayNamesRow(context),
            ),
          ),
          const Gap(6),
          SlideTransition(
            position: _calSlide,
            child: FadeTransition(
              opacity: _calFade,
              child: SizedBox(
                height: 272,
                child: _buildPageView(ctrl, portrait: true),
              ),
            ),
          ),
          const Gap(12),
        ],
      ),
    );
  }

  // ── landscape ─────────────────────────────────────────────────────────────
  Widget _buildLandscape(BuildContext context, EventController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: FadeTransition(
              opacity: _calFade,
              child: Column(
                children: [
                  const Gap(8),
                  _buildNavRow(context, ctrl),
                  const Gap(10),
                  _buildDayNamesRow(context),
                  const Gap(6),
                  SizedBox(
                    height: 200,
                    child: _buildPageView(ctrl, portrait: false),
                  ),
                ],
              ),
            ),
          ),
          const Gap(14),
          Expanded(
            flex: 4,
            child: SlideTransition(
              position: _headerSlide,
              child: FadeTransition(
                opacity: _headerFade,
                child: Center(child: _buildDateHeader(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── date header ───────────────────────────────────────────────────────────
  Widget _buildDateHeader(BuildContext context) {
    final h = eventsCtrl.hijriNow;
    final textOnCard = _surface;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primary.withValues(alpha: .95),
            _primary.withValues(alpha: .78),
          ],
        ),
        border: Border.all(color: textOnCard.withValues(alpha: .18), width: 1),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: .4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Decorative watermark art
            Positioned(
              right: -12,
              top: -12,
              bottom: -12,
              child: Opacity(
                opacity: 0.10,
                child: SvgPicture.asset(
                  'assets/svg/hijri/${h.hMonth}.svg',
                  colorFilter: ColorFilter.mode(_canvas, BlendMode.srcIn),
                ),
              ),
            ),
            // Top shimmer line
            Positioned(
              top: 0,
              left: 32,
              right: 32,
              child: Container(
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      textOnCard.withValues(alpha: .6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Month icon
                  _MonthIconBox(
                    month: h.hMonth,
                    primary: _primary,
                    surface: _surface,
                    canvas: _canvas,
                  ),
                  const Gap(14),
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
                            height: 1.15,
                          ),
                        ),
                        const Gap(5),
                        // Year pill
                        _Pill(
                          label: '${h.hYear}  ${'AH'.tr}',
                          surface: _surface,
                        ),
                        const Gap(10),
                        // Today label
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
                                    color: _surface.withValues(alpha: .55),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const Gap(7),
                            Flexible(
                              child: Text(
                                '${'today'.tr}: ${h.hDay} ${h.getLongMonthName().tr}',
                                style: TextStyle(
                                  fontFamily: 'kufi',
                                  fontSize: 12,
                                  color: _canvas.withValues(alpha: .72),
                                  height: 1.4,
                                ),
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
          ],
        ),
      ),
    );
  }

  // ── nav row (year ← month →) ──────────────────────────────────────────────
  Widget _buildNavRow(BuildContext context, EventController ctrl) {
    return GetBuilder<EventController>(
      builder: (c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: _surface.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _surface.withValues(alpha: .14), width: 1),
        ),
        child: Row(
          children: [
            // ── Year section ─────────────────────────────────────────
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _NavButton(
                    icon: Icons.chevron_left_rounded,
                    surface: _surface,
                    onTap: () => c.onYearChanged(c.selectedDate.hYear - 1),
                  ),
                  const Gap(4),
                  Text(
                    '${c.selectedDate.hYear}',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _surface,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Gap(4),
                  _NavButton(
                    icon: Icons.chevron_right_rounded,
                    surface: _surface,
                    onTap: () => c.onYearChanged(c.selectedDate.hYear + 1),
                  ),
                ],
              ),
            ),
            // divider
            Container(
              width: 1,
              height: 28,
              color: _surface.withValues(alpha: .22),
            ),
            // ── Month section ────────────────────────────────────────
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _NavButton(
                    icon: Icons.chevron_left_rounded,
                    surface: _surface,
                    onTap: () {
                      if (c.pageController.page! > 0) {
                        c.pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  const Gap(4),
                  SizedBox(
                    width: 88,
                    child: Text(
                      c.calenderMonth.value.getLongMonthName().tr,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _surface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Gap(4),
                  _NavButton(
                    icon: Icons.chevron_right_rounded,
                    surface: _surface,
                    onTap: () {
                      if (c.pageController.page! < 11) {
                        c.pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── day names row ─────────────────────────────────────────────────────────
  Widget _buildDayNamesRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: List.generate(7, (i) {
          final name = eventsCtrl.getWeekdayShortName(i).tr;
          return Expanded(
            child: Center(
              child: Text(
                name,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _surface.withValues(alpha: .65),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── page view ────────────────────────────────────────────────────────────
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
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOut),
              ),
              child: child,
            ),
          ),
          child: Padding(
            key: ValueKey(
              '$monthIndex-${ctrl.calenderMonth.value.hYear}-$portrait',
            ),
            padding: EdgeInsets.zero,
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

  // ── calendar grid ────────────────────────────────────────────────────────
  Widget _buildGrid(
    BuildContext context, {
    required int daysInMonth,
    required int firstDayWeekday,
    required HijriDate month,
  }) {
    final ctrl = EventController.instance;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _surface.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _surface.withValues(alpha: .12), width: 1),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 2),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.0,
          mainAxisSpacing: 6,
          crossAxisSpacing: 4,
        ),
        itemCount: 42,
        itemBuilder: (context, index) {
          final day = index - firstDayWeekday + 1;
          if (day < 1 || day > daysInMonth) return const SizedBox.shrink();

          final isToday = ctrl.isCurrentDay(month, day);
          final hasEvent = ctrl.isEvent([month.hMonth], day);

          return GestureDetector(
            onTap: hasEvent ? () => ctrl.showEvent(day, month.hMonth) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: isToday
                    ? _surface
                    : hasEvent
                    ? _surface.withValues(alpha: .18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isToday
                    ? null
                    : hasEvent
                    ? Border.all(
                        color: _surface.withValues(alpha: .30),
                        width: 1,
                      )
                    : null,
                boxShadow: isToday
                    ? [
                        BoxShadow(
                          color: _surface.withValues(alpha: .40),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 14,
                      height: 1.0,
                      fontWeight:
                          isToday ? FontWeight.bold : FontWeight.w400,
                      color: isToday
                          ? _primary
                          : _surface.withValues(
                              alpha: hasEvent ? 1.0 : 0.82,
                            ),
                    ),
                  ),
                  if (hasEvent && !isToday)
                    Positioned(
                      bottom: 3,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _surface.withValues(alpha: .85),
                          shape: BoxShape.circle,
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

  // ── events panel ─────────────────────────────────────────────────────────
  Widget _buildEventsPanel(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.bottomEnd,
      child: Container(
        width: context.customOrientation(Get.width, Get.width * .42),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          border: Border.all(
            width: 1,
            color: _surface.withValues(alpha: .20),
          ),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -10),
              blurRadius: 32,
              color: _primary.withValues(alpha: .28),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_primary.withValues(alpha: .97), _primary],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // drag handle
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _surface.withValues(alpha: .30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Expanded(child: AllCalculatingEventsWidget()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── private helper widgets ────────────────────────────────────────────────

class _MonthIconBox extends StatelessWidget {
  const _MonthIconBox({
    required this.month,
    required this.primary,
    required this.surface,
    required this.canvas,
  });

  final int month;
  final Color primary;
  final Color surface;
  final Color canvas;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: surface.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: surface.withValues(alpha: .22), width: 1),
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (r) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [canvas, canvas.withValues(alpha: .50)],
          ).createShader(r),
          child: SvgPicture.asset(
            'assets/svg/hijri/$month.svg',
            height: 48,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.surface});
  final String label;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: surface.withValues(alpha: .28), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'kufi',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: surface,
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.surface,
    required this.onTap,
  });
  final IconData icon;
  final Color surface;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: surface.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: surface.withValues(alpha: .85), size: 20),
      ),
    );
  }
}
