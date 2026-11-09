import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../../../core/utils/constants/extensions/extensions.dart';
import '../../../../core/widgets/app_bar_widget.dart';
import '../controller/adhkar_dua_controller.dart';
import 'widgets/dua_zekr_card.dart';

class AdhkarItem extends StatelessWidget {
  const AdhkarItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final azkarCtrl = AzkarDuaController.instance;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        appBar: AppBarWidget(
          isTitled: true,
          title: azkarCtrl.state.filteredDhekrList.isNotEmpty
              ? azkarCtrl.state.filteredDhekrList.first.category
              : '',
          isFontSize: true,
          searchButton: const SizedBox.shrink(),
          isNotifi: true,
          isBooks: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: context.customOrientation(
              EdgeInsets.zero,
              const EdgeInsets.symmetric(horizontal: 64.0),
            ),
            child: Obx(() {
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
                          child: DuaZekrCard(
                            zekr: zekr,
                            index: index,
                            storageKey:
                                '${zekr.category}_${zekr.count}_${zekr.id}',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
