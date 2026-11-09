import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../controller/adhkar_controller.dart';
import '../widgets/zekr_card_widget.dart';

class AdhkarEveningItem extends StatelessWidget {
  const AdhkarEveningItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final azkarCtrl = AzkarController.instance;
    azkarCtrl.getAdhkar('azkar_evening');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        body: Obx(() {
          final list = azkarCtrl.state.filteredDhekrList;
          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 32),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final zekr = list[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 450),
                  child: SlideAnimation(
                    verticalOffset: 48.0,
                    child: FadeInAnimation(
                      child: ZekrCardWidget(
                        zekr: zekr,
                        index: index,
                        storageKey: '${zekr.category}_${zekr.count}_${zekr.id}',
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
