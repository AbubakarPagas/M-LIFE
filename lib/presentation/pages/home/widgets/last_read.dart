import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:misbah_path/core/utils/constants/extensions/alignment_rotated_extension.dart';
import 'package:misbah_path/core/utils/constants/extensions/convert_number_extension.dart';
import 'package:misbah_path/core/utils/constants/extensions/extensions.dart';
import 'package:misbah_path/core/utils/constants/shared_preferences_constants.dart'
    show MSTART_PAGE;
import 'package:misbah_path/presentation/pages/calendar/events.dart';
import 'package:misbah_path/presentation/pages/quran_page/quran.dart';

import '../../../../core/utils/constants/lottie.dart';
import '../../../../core/utils/constants/lottie_constants.dart';
import '../../../controllers/general/general_controller.dart';

class LastRead extends StatelessWidget {
  LastRead({super.key});

  final countdownCtrl = EventController.instance;
  final generalCtrl = GeneralController.instance;
  final quranCtrl = QuranController.instance;

  @override
  Widget build(BuildContext context) {
    final lastReadPage = quranCtrl.state.box.read(MSTART_PAGE) ?? 1;

    // final generalCtrl = sl<GeneralController>();
    // final quranCtrl = sl<QuranController>();
    // final countdownCtrl = EventController.instance;
    // final generalCtrl = GeneralController.instance;
    // final quranCtrl = QuranController.instance;
    return GestureDetector(
      onTap: () {
        // Get.to(() => QuranHome(), transition: Transition.downToUp)!.then(
        //     (value) => quranCtrl
        //         .changeSurahListOnTap(generalCtrl.state.currentPageNumber.value + 1));
        /*   Get.to(() => QuranHome(), transition: Transition.downToUp)!.then(
            (value) => quranCtrl.changeSurahListOnTap(
                quranCtrl.state.currentPageNumber.value + 1)); */
        Future.delayed(const Duration(milliseconds: 300), () {
          quranCtrl.changeSurahListOnTap(
            lastReadPage + 1,
            // ),
          );
        });
      },
      child: Container(
        height: 125,
        width: 380,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(8.0),
            Text(
              'lastRead'.tr,
              style: TextStyle(
                fontSize: 16.0,
                fontFamily: 'kufi',
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 70,
                width: 380,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                ),
                child: Obx(() {
                  return Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: SvgPicture.asset(
                          'assets/svg/surah_name/00${quranCtrl.state.lastReadSurahNumber.value}.svg',
                          height: 60,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).cardColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      context.vDivider(height: 30),
                      Expanded(
                        flex: 7,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 120,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  // '${'pageNo'.tr}: ${quranCtrl.state.current .currentPageNumber.value.toString().convertNumbers()}',
                                  '${'pageNo'.tr}: ${(lastReadPage + 1).toString().convertNumbersToCurrentLang()}',

                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontFamily: 'naskh',
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).hintColor,
                                    height: 1.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface.withValues(alpha: .4),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                ),
                                alignmentLayout(
                                  RotatedBox(
                                    quarterTurns: 15,
                                    child: customLottie(
                                      LottieConstants.assetsLottieArrow,
                                      height: 50.0,
                                    ),
                                  ),
                                  RotatedBox(
                                    quarterTurns: 25,
                                    child: customLottie(
                                      LottieConstants.assetsLottieArrow,
                                      height: 50.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
