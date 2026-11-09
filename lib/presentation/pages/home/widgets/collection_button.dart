import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../provider/dependencies/tabProvider.dart';
import '../model/collection.dart';

class CollectionButton extends StatelessWidget {
  final bool enableSVG;
  const CollectionButton(this.collection, {super.key, this.enableSVG = false});
  final Collection collection;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (collection.title == "Prayer Times") {
          context.read<TabProvider>().onChangingTab(1);
        } else if (collection.title == "Quran") {
          context.read<TabProvider>().onChangingTab(3);
        } else {
          Navigator.pushNamed(context, collection.routeName);
        }
      },
      child: SizedBox(
        child: Column(
          children: [
            Container(
              height: 64,
              width: 64,
              margin: const EdgeInsets.all(4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: .1),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: enableSVG
                  ? SvgPicture.asset(
                      'assets/svg/collection/${collection.svgName}.svg',
                      height: 60,
                      // colorFilter: ColorFilter.mode(
                      //   Theme.of(context).primaryColor,
                      //   BlendMode.srcIn,
                      // ),
                    )
                  : Icon(
                      collection.assetName,
                      color: Theme.of(context).primaryColor,
                      size: 35,
                    ),
            ),
            SizedBox(
              width: 64.w,
              child: Text(
                collection.title,
                style: TextStyle(
                  fontFamily: "kufi",
                  fontSize: 13,
                  // fontWeight: FontWeight.bold,
                  color: Get.theme.disabledColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
