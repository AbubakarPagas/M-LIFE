import 'package:flutter/material.dart';

// import 'package:sturnic_vendor/styles/style.dart';
// import 'package:sturnic_vendor/widgets/ori_count_down.dart';

import 'count_down.dart';

class TimerBasic extends StatelessWidget {
  final CountDownTimerFormat format;
  final DateTime endTime;
  // final DateTime startTime;

  // final DateTime deliveredTime;
  // final bool delivered;

  const TimerBasic({
    required this.format,
    required this.endTime,
    // required this.startTime,
    // this.delivered = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimerCountdown(
      format: format,
      endTime: endTime,
      // startTime: startTime,
      onEnd: () {
        // cprint("Timer finished");
      },
      timeTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 15,
        fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
      ),
      colonsTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 15,
        fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
      ),
      descriptionTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
      ),
      spacerWidth: 0,
      daysDescription: "days",
      hoursDescription: "hours",
      minutesDescription: "minutes",
      secondsDescription: "seconds",
      enableDescriptions: false,
    );
  }
}
