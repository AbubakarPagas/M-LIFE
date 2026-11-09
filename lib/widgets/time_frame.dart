import 'package:flutter/material.dart';
import 'package:misbah_path/widgets/tile_color.dart';

const Color purple = Color.fromARGB(255, 63, 45, 149);

class TimerFrame extends StatelessWidget {
  final String description;
  final Widget timer;
  final Color? color;

  const TimerFrame({
    required this.description,
    required this.timer,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 5, left: 5, top: 5, bottom: 3),
      padding: const EdgeInsets.all(3),
      /* decoration: BoxDecoration(
        color: color ?? TileColors.expansionTile(context),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(width: 2, color: Colors.transparent),
      ), */
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        // crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (description.isNotEmpty)
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                letterSpacing: 0,
                color: Colors.white,
              ),
            ),
          const SizedBox(height: 3),
          timer,
        ],
      ),
    );
    /*  return Container(
      margin: const EdgeInsets.only(right: 5, left: 5, top: 5, bottom: 3),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: color ?? TileColors.expansionTile(context),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(width: 2, color: Colors.transparent),
      ),
      width: MediaQuery.of(context).size.width,
      child: Column(children: [timer]),
    ); */
  }
}

class TimerFrameRequest extends StatelessWidget {
  final String description;
  final Widget timer;
  final Color? color;

  const TimerFrameRequest({
    required this.description,
    required this.timer,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 5, left: 5, top: 5, bottom: 3),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: color ?? TileColors.expansionTile(context),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(width: 2, color: Colors.transparent),
      ),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          if (description.isNotEmpty)
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                letterSpacing: 0,
                // color: CupertinoColors.white,
              ),
            ),
          const SizedBox(height: 3),
          timer,
        ],
      ),
    );
  }
}
