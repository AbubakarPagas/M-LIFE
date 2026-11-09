import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:misbah_path/core/utils/constants/extensions/extensions.dart';
import 'package:misbah_path/core/widgets/elevated_button_widget.dart';

import '../../../../apps/routes/route_name.dart';

class ListingQuran extends StatelessWidget {
  const ListingQuran({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ElevatedButtonWidget(
        padding: 10,
        onClick: () => Navigator.pushNamed(context, RoutesName.audio),
        // Get.to(RoutesName.audio, transition: Transition.downToUp),
        index: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: const BoxDecoration(
              /*    color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.15), */
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            child: Expanded(
              flex: 4,
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/svg/quran_au_ic.svg',
                    height: 60,
                    /* colorFilter: ColorFilter.mode(
                      Theme.of(context).cardColor,
                      BlendMode.srcIn,
                    ), */
                  ),
                  context.vDivider(height: 30),
                  Expanded(
                    flex: 5,
                    child: Container(
                      // width: 150,
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                        border: Border.all(
                          // color: Theme.of(context).colorScheme.surface,
                          width: 1,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'quranAudio'.tr,
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'kufi',
                            color: Get.theme.disabledColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
