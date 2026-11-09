import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../core/utils/constants/lottie.dart';
import '../../../../core/utils/constants/lottie_constants.dart';
import '../controller/adhkar_dua_controller.dart';
import '../widgets/options_row.dart';
import '../widgets/text_widget.dart';

class AdhkarFav extends StatelessWidget {
  const AdhkarFav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final azkarCtrl = AzkarDuaController.instance;
    azkarCtrl.getAdhkar();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Obx(() {
        final list = azkarCtrl.state.adhkarList;

        if (list.isEmpty) {
          return _EmptyFavState();
        }

        return AnimationLimiter(
          child: ListView.builder(
            controller: azkarCtrl.state.favController,
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final azkar = list[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 400),
                child: SlideAnimation(
                  verticalOffset: 40.0,
                  child: FadeInAnimation(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(24),
                          OptionsRow(zekr: azkar, azkarFav: true),
                          TextWidget(zekr: azkar),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────

class _EmptyFavState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          customLottieWithColor(
            LottieConstants.assetsLottieOpenBook,
            height: 200.0,
            width: 200.0,
          ),
          const Gap(16),
          Text(
            'لا توجد أذكار محفوظة',
            style: TextStyle(
              fontFamily: 'naskh',
              fontSize: 18,
              color: cs.primary.withValues(alpha: 0.60),
              fontWeight: FontWeight.w600,
            ),
            textDirection: TextDirection.rtl,
          ),
          const Gap(8),
          Text(
            'احفظ أذكارك المفضلة من قائمة الأذكار',
            style: TextStyle(
              fontFamily: 'naskh',
              fontSize: 14,
              color: cs.primary.withValues(alpha: 0.40),
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}
