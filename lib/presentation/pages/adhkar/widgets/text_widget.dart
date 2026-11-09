import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/core/services/services_locator.dart';
import '../../../../database/bookmark_db/bookmark_database.dart';
import '../../../controllers/general/general_controller.dart';
import '../controller/adhkar_controller.dart';

class TextWidget extends StatelessWidget {
  final AdhkarData zekr;
  const TextWidget({super.key, required this.zekr});

  @override
  Widget build(BuildContext context) {
    final azkarCtrl = AzkarController.instance;
    return Obx(() {
      final isEn = azkarCtrl.isEnglish;

      // Pick the correct fields based on language toggle
      final zekrText = isEn ? zekr.zekrs : zekr.zekr;
      final refText = isEn ? zekr.references : zekr.reference;
      final descText = isEn ? zekr.descriptions : zekr.description;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Main text ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: .1),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              width: double.infinity,
              child: RichText(
                text: TextSpan(
                  children: azkarCtrl.buildTextSpans(zekrText),
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                    height: 1.6,
                    fontFamily: isEn ? 'kufi' : 'naskh',
                    fontSize:
                        sl<GeneralController>().state.fontSizeArabic.value,
                  ),
                ),
                textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
                textAlign: TextAlign.justify,
              ),
            ),
          ),

          // ── Reference ─────────────────────────────────────────────────────
          if (refText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Align(
                alignment: isEn ? Alignment.centerLeft : Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: .15),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    refText,
                    textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
                    style: TextStyle(
                      color: Theme.of(context).hintColor.withValues(alpha: .6),
                      fontSize: 13,
                      fontFamily: isEn ? 'kufi' : 'naskh',
                    ),
                  ),
                ),
              ),
            ),

          // ── Description ───────────────────────────────────────────────────
          if (descText.isNotEmpty)
            Align(
              alignment: Alignment.center,
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: .15),
                    width: 1,
                  ),
                ),
                child: Text(
                  descText,
                  textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
                  style: TextStyle(
                    color: Theme.of(context).hintColor.withValues(alpha: .8),
                    fontSize: 14,
                    fontFamily: isEn ? 'kufi' : 'naskh',
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
        ],
      );
    });
  }
}
