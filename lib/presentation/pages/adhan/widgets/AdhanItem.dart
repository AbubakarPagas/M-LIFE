import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../extensions.dart';
import '../../../../models/Adhan.dart';
import '../../../../provider/dependencies/AdhanDependencyProvider.dart';
import '../../../../widgets/timer.dart';

class AdhanItem extends StatelessWidget {
  static const _borderRadius = 16.0;
  static const _padding = 16.0;
  static const _iconSize = 28.0;

  final Adhan _adhan;
  final NumberFormat _formatter;

  const AdhanItem(this._adhan, this._formatter, {super.key});

  @override
  Widget build(BuildContext context) {
    final adhanDependency = context.watch<AdhanDependencyProvider>();
    final notifyID = adhanDependency.notifyID(_adhan.type);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
        /*  _adhan.isCurrent
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.9)
            : Theme.of(context).colorScheme.surface, */
        border: _adhan.isCurrent
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
            : null,
        /*  boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_adhan.isCurrent ? 0.15 : 0.08),
            blurRadius: _adhan.isCurrent ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ], */
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(_borderRadius),
          onTap: () {
            // Add tap functionality if needed
          },
          child: Padding(
            padding: const EdgeInsets.all(_padding),
            child: Row(
              children: [
                // Prayer Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _adhanIcon,
                ),
                const SizedBox(width: 16),
                // Prayer Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Prayer Name
                      Text(
                        _adhan.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Prayer Times
                      Text(
                        '${_adhan.startTime.localizeTimeTo()} - ${_adhan.endTime.localizeTimeTo()}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.7),
                        ),
                      ),

                      const SizedBox(height: 2),

                      // Duration
                      Text(
                        '${'duration'.tr}: ${getformatDuration(_adhan.timeOfWaqt, _formatter, showSeconds: false, hour: ' ${'hour'.tr} ', minute: ' ${'minute'.tr}')}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Notification Status
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(
                      notifyID,
                      context,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getNotificationIcon(notifyID),
                    size: _iconSize,
                    color: _getNotificationColor(notifyID, context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _adhanIcon {
    return Image.asset(
      _adhan.imageLocation,
      width: 32,
      height: 32,
      fit: BoxFit.contain,
    );
  }

  IconData _getNotificationIcon(int notifyID) {
    return switch (notifyID) {
      0 => Icons.notifications_off_outlined,
      1 => Icons.notifications_on_outlined,
      _ => Icons.volume_up_outlined,
    };
  }

  Color _getNotificationColor(int notifyID, BuildContext context) {
    return switch (notifyID) {
      0 => Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      1 => Theme.of(context).colorScheme.primary,
      _ => Theme.of(context).colorScheme.secondary,
    };
  }
}

class _VerticalDivider extends StatelessWidget {
  final double length;

  const _VerticalDivider(this.length);

  @override
  Widget build(BuildContext context) {
    return Container(
      color:
          (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black)
              .withOpacity(0.5),
      child: SizedBox(width: 1, height: length),
    );
  }
}
