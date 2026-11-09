import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../provider/adhanProvider.dart';
import '../../../../widgets/timer.dart';
import 'adhanInfoDialog.dart';

class CurrentAdhanDisplay extends StatelessWidget {
  final String _userAddress;

  const CurrentAdhanDisplay(this._userAddress, {super.key});

  @override
  Widget build(BuildContext context) {
    final headingStyle = Theme.of(context).textTheme.headlineSmall!.copyWith(
      color: Theme.of(context).textTheme.headlineSmall?.color,
      fontSize: 70,
    );
    final adhanProvider = context.watch<AdhanProvider>();
    final currentAdhan = adhanProvider.currentAdhan;

    return Container(
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => showDialog(
          context: context,
          builder: (ctx) => const AdhanInfoDialog(),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (currentAdhan != null) ...[
              AutoSizeText(
                currentAdhan.title.toUpperCase(),
                style: headingStyle,
                maxLines: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Countdown(
                    currentAdhan.endTime,
                    // locale: context.appLocale.locale,
                    prefix: '${'until_adhan'.tr}: ',
                    suffix: '  |  ',
                    style: Theme.of(context).textTheme.bodyLarge,
                    rtl: Directionality.of(context) == TextDirection.rtl,
                  ),
                  ..._createLocationRow(context),
                ],
              ),
            ] else ...[
              AutoSizeText(
                'adhan_heading'.tr,
                style: headingStyle,
                maxLines: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _createLocationRow(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _createLocationRow(BuildContext context) {
    return [
      const Icon(Icons.my_location),
      const SizedBox(width: 8),
      AutoSizeText(
        _userAddress.length > 15
            ? "${_userAddress.substring(0, 15)}..."
            : _userAddress,
        // style: context.textTheme.bodyLarge,
        maxLines: 1,
      ),
    ];
  }
}
