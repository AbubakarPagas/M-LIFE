import 'package:flutter/material.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:misbah_path/apps/routes/route_name.dart';
import 'package:misbah_path/core/utils/constants/extensions/alignment_rotated_extension.dart';
import 'package:misbah_path/core/utils/constants/extensions/convert_number_extension.dart';
import 'package:misbah_path/presentation/pages/calendar/events.dart';

import '../../../controllers/general/general_controller.dart';

class HijriDate extends StatelessWidget {
  const HijriDate({super.key});

  @override
  Widget build(BuildContext context) {
    var today = HijriCalendar.now();
    // final general = sl<GeneralController>();
    // general.updateGreeting();
    final generalCtrl = GeneralController.instance;
    final eventCtrl = EventController.instance;
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, RoutesName.calendar);
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 40,
                    width: 45,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: alignmentLayout(
                        const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                        const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ),
                    child: Text(
                      '${eventCtrl.hijriNow.hDay}'
                          .convertNumbersToCurrentLang(),
                      style: TextStyle(
                        fontSize: 26.0,
                        fontFamily: 'kufi',
                        color: Theme.of(context).canvasColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Gap(8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        eventCtrl.hijriNow.getDayName().tr,
                        style: TextStyle(
                          fontSize: 22.0,
                          fontFamily: 'kufi',
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '${'${eventCtrl.hijriNow.hYear}'.convertNumbersToCurrentLang()} هـ',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontFamily: 'kufi',
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              SvgPicture.asset(
                'assets/svg/hijri/${eventCtrl.hijriNow.hMonth}.svg',
                width: 122,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).primaryColor,
                  BlendMode.srcIn,
                ),
              ),
              const Gap(32),
            ],
          ),
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                RoundedProgressBar(
                  height: 25,
                  style: RoundedProgressBarStyle(
                    borderWidth: 0,
                    widthShadow: 5,
                    backgroundProgress: Theme.of(context).hoverColor,
                    colorProgress: Theme.of(context).colorScheme.surface,
                    colorProgressDark: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: .5),
                    colorBorder: Colors.transparent,
                    colorBackgroundIcon: Colors.transparent,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  percent:
                      ((eventCtrl.hijriNow.hDay / eventCtrl.getLengthOfMonth) *
                      100),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: eventCtrl.isLastDayOfMonth
                        ? Text(
                            '${'lastDayOf'.tr} ${eventCtrl.hijriNow.getLongMonthName().tr}',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontFamily: 'kufi',
                              color: Theme.of(context).disabledColor,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 7,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${'RemainsUntilTheEndOf'.tr} ${eventCtrl.hijriNow.getLongMonthName().tr}',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontFamily: 'kufi',
                                      color: Theme.of(context).disabledColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const Gap(16),
                              Expanded(
                                flex: 3,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    eventCtrl
                                        .daysArabicConvert(
                                          (eventCtrl.getLengthOfMonth -
                                              eventCtrl.hijriNow.hDay),
                                          (eventCtrl.getLengthOfMonth -
                                                  eventCtrl.hijriNow.hDay)
                                              .toString(),
                                        )
                                        .convertNumbersToCurrentLang(),
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontFamily: 'kufi',
                                      color: Theme.of(context).disabledColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          /*  Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: eventCtrl.isLastDayOfMonth
                        ? Text(
                            '${'lastDayOf'.tr} ${eventCtrl.hijriNow.getLongMonthName().tr}',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontFamily: 'kufi',
                              color: Theme.of(context).disabledColor,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 7,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${'RemainsUntilTheEndOf'.tr} ${eventCtrl.hijriNow.getLongMonthName().tr}',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontFamily: 'kufi',
                                      color: Theme.of(context).disabledColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const Gap(16),
                              Expanded(
                                flex: 3,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    eventCtrl
                                        .daysArabicConvert(
                                          (eventCtrl.getLengthOfMonth -
                                              eventCtrl.hijriNow.hDay),
                                          (eventCtrl.getLengthOfMonth -
                                                  eventCtrl.hijriNow.hDay)
                                              .toString(),
                                        )
                                        .convertNumbers(),
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontFamily: 'kufi',
                                      color: Theme.of(context).disabledColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ), */
        ],
      ),
    );
  }
}
