import 'dart:async';

import 'package:flutter/widgets.dart';

enum CountDownFormat {
  daysHoursMinutesSeconds,
  daysHoursMinutes,
  daysHours,
  daysOnly,
  hoursMinutesSeconds,
  hoursMinutes,
  hoursOnly,
  minutesSeconds,
  minutesOnly,
  secondsOnly,
}

typedef OnTickCallBack = void Function(Duration remainingTime);

class Countdown extends StatefulWidget {
  /// Format for the timer coundtown, choose between different `CountDownFormat`s
  final CountDownFormat format;

  /// Defines the time when the timer is over.
  final DateTime endTime;

  /// Gives you remaining time after every tick.
  final OnTickCallBack? onTick;

  /// Function to call when the timer is over.
  final VoidCallback? onEnd;

  /// Toggle time units descriptions.
  final bool enableDescriptions;

  /// `TextStyle` for the time numbers.
  final TextStyle? timeTextStyle;

  /// `TextStyle` for the colons betwenn the time numbers.
  final TextStyle? colonsTextStyle;

  /// `TextStyle` for the description
  final TextStyle? descriptionTextStyle;

  /// Days unit description.
  final String daysDescription;

  /// Hours unit description.
  final String hoursDescription;

  /// Minutes unit description.
  final String minutesDescription;

  /// Seconds unit description.
  final String secondsDescription;

  /// Defines the width between the colons and the units.
  final double spacerWidth;

  final bool countdown;

  const Countdown({
    super.key,
    required this.endTime,
    this.format = CountDownFormat.daysHoursMinutesSeconds,
    this.enableDescriptions = true,
    this.onEnd,
    this.timeTextStyle,
    this.onTick,
    this.colonsTextStyle,
    this.descriptionTextStyle,
    this.daysDescription = "Days",
    this.hoursDescription = "Hours",
    this.minutesDescription = "Minutes",
    this.secondsDescription = "Seconds",
    this.spacerWidth = 10,
    this.countdown = true,
  });

  @override
  CountdownState createState() => CountdownState();
}

class CountdownState extends State<Countdown> {
  Timer? timer;
  late String countdownDays;
  late String countdownHours;
  late String countdownMinutes;
  late String countdownSeconds;
  late Duration difference;

  @override
  void initState() {
    _startTimer();
    super.initState();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  /// Calculate the time difference between now end the given [endTime] and initialize all UI timer values.
  ///
  /// Then create a periodic `Timer` which updates all fields every second depending on the time difference which is getting smaller.
  /// When this difference reached `Duration.zero` the `Timer` is stopped and the [onEnd] callback is invoked.
  void _startTimer() {
    if (widget.endTime.isBefore(DateTime.now())) {
      difference = Duration.zero;
    } else {
      difference = widget.endTime.difference(DateTime.now());
    }

    countdownDays = _durationToStringDays(difference);
    countdownHours = _durationToStringHours(difference);
    countdownMinutes = _durationToStringMinutes(difference);
    countdownSeconds = _durationToStringSeconds(difference);

    if (difference == Duration.zero) {
      if (widget.onEnd != null) {
        widget.onEnd!();
      }
    } else {
      if (widget.countdown) {
        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          difference = widget.endTime.difference(DateTime.now());
          widget.onTick?.call(difference);
          setState(() {
            countdownDays = _durationToStringDays(difference);
            countdownHours = _durationToStringHours(difference);
            countdownMinutes = _durationToStringMinutes(difference);
            countdownSeconds = _durationToStringSeconds(difference);
          });
          if (difference <= Duration.zero) {
            timer.cancel();
            if (widget.onEnd != null) {
              widget.onEnd!();
            }
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _countDownFormat();
  }

  /// Builds the UI colons between the time units.
  Widget _colon() {
    return Row(
      children: [
        SizedBox(
          width: widget.spacerWidth,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ":",
              style: widget.colonsTextStyle,
            ),
            if (widget.enableDescriptions)
              const SizedBox(
                height: 5,
              ),
            if (widget.enableDescriptions)
              Text(
                "",
                style: widget.descriptionTextStyle,
              ),
          ],
        ),
        SizedBox(
          width: widget.spacerWidth,
        ),
      ],
    );
  }

  /// Builds the timer days with its description.
  Widget _days(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          countdownDays,
          style: widget.timeTextStyle,
        ),
        if (widget.enableDescriptions)
          const SizedBox(
            height: 5,
          ),
        if (widget.enableDescriptions)
          Text(
            widget.daysDescription,
            style: widget.descriptionTextStyle,
          ),
      ],
    );
  }

  /// Builds the timer hours with its description.
  Widget _hours(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          countdownHours,
          style: widget.timeTextStyle,
        ),
        if (widget.enableDescriptions)
          const SizedBox(
            height: 5,
          ),
        if (widget.enableDescriptions)
          Text(
            widget.hoursDescription,
            style: widget.descriptionTextStyle,
          ),
      ],
    );
  }

  /// Builds the timer minutes with its description.
  Widget _minutes(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          countdownMinutes,
          style: widget.timeTextStyle,
        ),
        if (widget.enableDescriptions)
          const SizedBox(
            height: 5,
          ),
        if (widget.enableDescriptions)
          Text(
            widget.minutesDescription,
            style: widget.descriptionTextStyle,
          ),
      ],
    );
  }

  /// Builds the timer seconds with its description.
  Widget _seconds(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          countdownSeconds,
          style: widget.timeTextStyle,
        ),
        if (widget.enableDescriptions)
          const SizedBox(
            height: 5,
          ),
        if (widget.enableDescriptions)
          Text(
            widget.secondsDescription,
            style: widget.descriptionTextStyle,
          ),
      ],
    );
  }

  /// When the selected [CountDownFormat] is leaving out the last unit, this function puts the UI value of the unit before up by one.
  ///
  /// This is done to show the currently running time unit.
  String _twoDigits(int n, String unitType) {
    switch (unitType) {
      case "minutes":
        if (widget.format == CountDownFormat.daysHoursMinutes ||
            widget.format == CountDownFormat.hoursMinutes ||
            widget.format == CountDownFormat.minutesOnly) {
          if (difference > Duration.zero) {
            n++;
          }
        }
        if (n >= 10) return "$n";
        return "0$n";
      case "hours":
        if (widget.format == CountDownFormat.daysHours ||
            widget.format == CountDownFormat.hoursOnly) {
          if (difference > Duration.zero) {
            n++;
          }
        }
        if (n >= 10) return "$n";
        return "0$n";
      case "days":
        if (widget.format == CountDownFormat.daysOnly) {
          if (difference > Duration.zero) {
            n++;
          }
        }
        if (n >= 10) return "$n";
        return "0$n";
      default:
        if (n >= 10) return "$n";
        return "0$n";
    }
  }

  /// Convert [Duration] in days to String for UI.
  String _durationToStringDays(Duration duration) {
    return _twoDigits(duration.inDays, "days").toString();
  }

  /// Convert [Duration] in hours to String for UI.
  String _durationToStringHours(Duration duration) {
    if (widget.format == CountDownFormat.hoursMinutesSeconds ||
        widget.format == CountDownFormat.hoursMinutes ||
        widget.format == CountDownFormat.hoursOnly) {
      return _twoDigits(duration.inHours, "hours");
    } else {
      return _twoDigits(duration.inHours.remainder(24), "hours").toString();
    }
  }

  /// Convert [Duration] in minutes to String for UI.
  String _durationToStringMinutes(Duration duration) {
    if (widget.format == CountDownFormat.minutesSeconds ||
        widget.format == CountDownFormat.minutesOnly) {
      return _twoDigits(duration.inMinutes, "minutes");
    } else {
      return _twoDigits(duration.inMinutes.remainder(60), "minutes");
    }
  }

  /// Convert [Duration] in seconds to String for UI.
  String _durationToStringSeconds(Duration duration) {
    if (widget.format == CountDownFormat.secondsOnly) {
      return _twoDigits(duration.inSeconds, "seconds");
    } else {
      return _twoDigits(duration.inSeconds.remainder(60), "seconds");
    }
  }

  /// Switches the UI to be displayed based on [CountDownFormat].
  Widget _countDownFormat() {
    switch (widget.format) {
      case CountDownFormat.daysHoursMinutesSeconds:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _days(context),
            _colon(),
            _hours(context),
            _colon(),
            _minutes(context),
            _colon(),
            _seconds(context),
          ],
        );
      case CountDownFormat.daysHoursMinutes:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _days(context),
            _colon(),
            _hours(context),
            _colon(),
            _minutes(context),
          ],
        );
      case CountDownFormat.daysHours:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _days(context),
            _colon(),
            _hours(context),
          ],
        );
      case CountDownFormat.daysOnly:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _days(context),
          ],
        );
      case CountDownFormat.hoursMinutesSeconds:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _hours(context),
            _colon(),
            _minutes(context),
            _colon(),
            _seconds(context),
          ],
        );
      case CountDownFormat.hoursMinutes:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _hours(context),
            _colon(),
            _minutes(context),
          ],
        );
      case CountDownFormat.hoursOnly:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _hours(context),
          ],
        );
      case CountDownFormat.minutesSeconds:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _minutes(context),
            _colon(),
            _seconds(context),
          ],
        );

      case CountDownFormat.minutesOnly:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _minutes(context),
          ],
        );
      case CountDownFormat.secondsOnly:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _seconds(context),
          ],
        );
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _days(context),
            _colon(),
            _hours(context),
            _colon(),
            _minutes(context),
            _colon(),
            _seconds(context),
          ],
        );
    }
  }
}
