import 'package:flutter/material.dart';

import '../../../adhan/widgets/adhan_theme.dart';

/// Shared UI widgets reused across tracking analytics screens.

class TrackingSectionTitle extends StatelessWidget {
  final String title;
  const TrackingSectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AdhanColors.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AdhanTextStyles.sectionTitle(color: AdhanColors.gold),
        ),
      ],
    );
  }
}
