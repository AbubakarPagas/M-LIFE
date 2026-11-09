import 'package:flutter/material.dart';

class Stat extends StatelessWidget {
  const Stat({
    Key? key,
    required this.animation,
    required this.label,
    required this.value,
    this.progress,
    this.negative = false,
    required this.star,
  }) : super(key: key);

  final Animation animation;
  final String? label;
  final double? progress;
  final num value;
  final bool star;
  final bool negative;

  @override
  Widget build(BuildContext context) {
    final currentProgress = progress ?? value / 5 * 100;
    final starValue = progress ?? value / 5;
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(flex: 2, child: Container()
            //   LinearPercentIndicator(
            //     animation: true,
            //     lineHeight: 10.0,
            //     animationDuration: 2500,
            //     percent: starValue,
            //     // backgroundColor: Colors.grey.shade200,
            //     barRadius: const Radius.circular(3),
            //     progressColor:
            //         negative ? bugColor : Theme.of(context).colorScheme.primary,
            //   ),
            // ),
            ),
        // Expanded(
        //   flex: 1,
        //   child: star
        //       ? customText(value.toStringAsFixed(1))
        //       : customText('${currentProgress.toStringAsFixed(0)}%'),
        // ),
      ],
    );
  }
}
