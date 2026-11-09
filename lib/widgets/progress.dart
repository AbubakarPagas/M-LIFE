import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    Key? key,
    this.color = Colors.red,
    this.backgroundColor = Colors.grey,
    this.enableAnimation = true,
    required this.progress,
  }) : super(key: key);

  final Color backgroundColor;
  final Color color;
  final double progress;
  final bool enableAnimation;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: color,
      ),
    );

    return Container(
      clipBehavior: Clip.hardEdge,
      height: 5,
      alignment: Alignment.centerLeft,
      decoration: const ShapeDecoration(
        shape: StadiumBorder(),
        color: Colors.grey,
      ),
      child: enableAnimation
          ? AnimatedAlign(
              duration: const Duration(seconds: 2000),
              alignment: const Alignment(1, 0),
              widthFactor: progress,
              child: child,
            )
          : FractionallySizedBox(
              widthFactor: progress,
              child: child,
            ),
    );
  }
}
