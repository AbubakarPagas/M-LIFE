import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '/core/utils/constants/extensions/svg_extensions.dart';
import '../../../../core/utils/constants/svg_constants.dart';
import '../controller/adhkar_controller.dart';
// import '../screens/adhkar_item.dart';

class AdhkarList extends StatelessWidget {
  const AdhkarList({super.key});

  @override
  Widget build(BuildContext context) {
    final azkarCtrl = AzkarController.instance;
    return AnimationLimiter(
      child: Obx(() {
        return ListView.builder(
          controller: azkarCtrl.state.listController,
          itemCount: azkarCtrl.state.categories.length,
          padding: EdgeInsets.zero,
          itemBuilder: (BuildContext context, int index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 450),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: GestureDetector(
                    onTap: () {
                    /*   azkarCtrl.filterByCategory(
                        azkarCtrl.state.categories[index],
                      );
                      Get.to(
                        const AdhkarItem(),
                        transition: Transition.leftToRight,
                      ); */
                    },
                    child: Container(
                      margin: const EdgeInsets.all(5.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .1),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: customSvgWithCustomColor(
                              SvgPath.svgSliderIc2,
                              height: 30,
                            ),
                          ),
                          Expanded(
                            flex: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(4),
                                ),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4.0,
                                      ),
                                      child: Text(
                                        azkarCtrl.state.categories[index]
                                            .toString()
                                            .tr,
                                        style: TextStyle(
                                          color: Get.isDarkMode
                                              ? Get.theme.canvasColor
                                              : Theme.of(
                                                  context,
                                                ).primaryColorDark,
                                          fontSize: 22,
                                          fontFamily: 'naskh',
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                  ),
                                ],
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
          },
        );
      }),
    );
  }
}
