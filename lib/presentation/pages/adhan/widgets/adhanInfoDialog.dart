import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:misbah_path/presentation/pages/adhan/widgets/iconedTextButton.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/gps_location_helper.dart';
import '../../../../provider/dependencies/AdhanDependencyProvider.dart';
import '../../../../provider/locationProvider.dart';

class AdhanInfoDialog extends StatelessWidget {
  const AdhanInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final adhanProvider = context.read<AdhanDependencyProvider>();
    // final appLocale = AppLocalizations.of(context)!;
    final locationProvider = context.read<LocationProvider>();
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Row(
        children: [
          const Icon(Icons.info, color: Colors.grey),
          const SizedBox(width: 8),
          Text('adhan_info'.tr),
        ],
      ),
      content: RichText(
        text: TextSpan(
          text:
              '${'using_location'.tr} ${(locationProvider.locationState as LocationAvailable).locationInfo.address}\n',
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: 'location_privacy_short'.tr,
              /*  style: TextStyle(
                color: context.textTheme.headline6?.color?.withOpacity(0.6),
              ), */
            ),
          ],
        ),
      ),
      actions: [
        IconedTextButton(
          iconData: Icons.volume_off,
          text: 'silent_all'.tr,
          onPressed: () {
            /* adhanProvider.silentAll();
            Navigator.pop(context); */
          },
        ),
        IconedTextButton(
          onPressed: () {
            locationProvider.updateLocationWithGPS(background: false);
            Navigator.pop(context);
          },
          text: 'update_location'.tr,
          iconData: Icons.edit_location,
        ),
        IconedTextButton(
          onPressed: () {
            /*  context.push(
              FeedbackTaker("Report Adhan Error", getAdhanReportForm()),
            ); */
          },
          iconData: Icons.error,
          text: 'report_an_error'.tr,
          color: Colors.red,
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('close'.tr, style: const TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
