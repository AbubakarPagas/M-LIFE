import 'package:flutter/material.dart';

class CircularImage extends StatelessWidget {
  const CircularImage(
      {Key? key, this.path, this.height = 50, this.isBorder = false})
      : super(key: key);
  final String? path;
  final double height;
  final bool isBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: isBorder ? 1 : 0),
        ),
        child: CircleAvatar(
          maxRadius: height / 2,
          child: ClipOval(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image:
                      ExactAssetImage("assets/images/img_not_available.jpeg"),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ));
  }
}

// Widget customNetworkImage(String path, {BoxFit fit = BoxFit.contain}) {
//   return CachedNetworkImage(
//     fit: fit,
//     imageUrl: path,
//     imageBuilder: (context, imageProvider) => Container(
//         decoration: BoxDecoration(
//       image: DecorationImage(
//         image: imageProvider,
//         fit: fit,
//       ),
//     )),
//     placeholderFadeInDuration: const Duration(milliseconds: 400),
//     placeholder: (context, url) =>
//         const Center(child: CupertinoActivityIndicator()),
//     errorWidget: (context, url, error) => Container(
//         decoration: BoxDecoration(
//       image: DecorationImage(
//         image: const ExactAssetImage("assets/images/img_not_available.jpeg"),
//         fit: fit,
//       ),
//     )),
//   );
// }
