import 'package:flutter/material.dart';

class TileColors {
  static Color expansionTile(context) =>
      Theme.of(context).brightness == Brightness.light
          ? Colors.transparent.withOpacity(0.03)
          : const Color.fromARGB(255, 22, 22, 22);

  static Color serviceTile(context) =>
      Theme.of(context).brightness == Brightness.light
          ? Colors.transparent.withOpacity(0.025)
          : const Color(0xff0b0b0b);
}
