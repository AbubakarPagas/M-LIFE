part of '../quran.dart';

class QuranPages extends StatelessWidget {
  QuranPages({Key? key}) : super(key: key);
  final quranCtrl = QuranController.instance;
  final bookmarkCtrl = BookmarksController.instance;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GetBuilder<QuranController>(
        id: 'backgroundColor',
        builder: (quranCtrl) {
          return Container(
            height: Get.height,
            color: quranCtrl.backgroundColor,
            child: TextBuild(),
          );
        },
      ),
    );
  }
}

// class QuranPages extends StatelessWidget {
//   QuranPages({Key? key}) : super(key: key);
//   final quranCtrl = QuranController.instance;
//   final bookmarkCtrl = BookmarksController.instance;
//   final generalCtrl = GeneralController.instance;

//   @override
//   Widget build(BuildContext context) {
//     // Read page number once without registering as a reactive listener.
//     final pageNumber = quranCtrl.state.currentPageNumber.value;
//     // Schedule the notification after build so it never fires mid-frame.
//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       NotificationManager().updateBookProgress(
//         'quran'.tr,
//         'notifyQuranBody'.trParams({'currentPageNumber': '$pageNumber'}),
//         pageNumber,
//       );
//     });
//     return SafeArea(
//       child: GetBuilder<GeneralController>(
//         builder: (generalCtrl) {
//           return GestureDetector(
//             onTap: () {
//               // audioCtrl.clearSelection();
//             },
//             onScaleStart: (details) {
//               quranCtrl.state.baseScaleFactor.value =
//                   quranCtrl.state.scaleFactor.value;
//             },
//             onScaleUpdate: (ScaleUpdateDetails details) {
//               quranCtrl.state.scaleFactor.value =
//                   quranCtrl.state.baseScaleFactor.value * details.scale;
//             },
//             child: SizedBox(
//               height: MediaQuery.sizeOf(context).height,
//               child: Focus(
//                 focusNode: quranCtrl.state.quranPageRLFocusNode,
//                 onKeyEvent: (node, event) =>
//                     quranCtrl.controlRLByKeyboard(node, event),
//                 child: PageView.builder(
//                   controller: quranCtrl.pageController,
//                   itemCount: 604,
//                   scrollDirection: Axis.horizontal,
//                   physics: const ClampingScrollPhysics(),
//                   onPageChanged: quranCtrl.pageChanged,
//                   itemBuilder: (_, index) {
//                     // sl<TranslateDataController>().fetchTranslate();
//                     return !quranCtrl.state.isPageMode.value
//                         ? _regularModeWidget(context, index)
//                         : _pageModeWidget(context, index);
//                   },
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _pageModeWidget(BuildContext context, int pageIndex) {
//     return
//     // Responsive.isMobile(context) || Responsive.isMobileLarge(context)
//     //     ?
//     Center(
//       child: pageIndex.isEven
//           ? RightPage(child: TextBuild(pageIndex: pageIndex))
//           : LeftPage(child: TextBuild(pageIndex: pageIndex)),
//     );
//     // : Center(
//     //     child: pageIndex.isEven
//     //         ? RightPage(
//     //             child: Focus(
//     //               focusNode: quranCtrl.state.quranPageUDFocusNode,
//     //               onKeyEvent: (node, event) =>
//     //                   quranCtrl.controlUDByKeyboard(node, event),
//     //               child: Padding(
//     //                 padding: const EdgeInsets.symmetric(
//     //                   horizontal: 32.0,
//     //                 ),
//     //                 child: TextBuild(pageIndex: pageIndex),
//     //               ),
//     //             ),
//     //           )
//     //         : LeftPage(
//     //             child: Focus(
//     //               focusNode: quranCtrl.state.quranPageUDFocusNode,
//     //               onKeyEvent: (node, event) =>
//     //                   quranCtrl.controlUDByKeyboard(node, event),
//     //               child: Padding(
//     //                 padding: const EdgeInsets.symmetric(
//     //                   horizontal: 32.0,
//     //                 ),
//     //                 child: TextBuild(pageIndex: pageIndex),
//     //               ),
//     //             ),
//     //           ));
//   }

//   Widget _regularModeWidget(BuildContext context, int pageIndex) {
//     final size = MediaQuery.sizeOf(context);
//     return
//     // Responsive.isMobile(context) || Responsive.isMobileLarge(context)
//     //     ?
//     Center(
//       child: pageIndex.isEven
//           ? Container(
//               height: size.height,
//               color: quranCtrl.backgroundColor,
//               child: TextBuild(pageIndex: pageIndex),
//             )
//           : Container(
//               height: size.height,
//               color: quranCtrl.backgroundColor,
//               child: TextBuild(pageIndex: pageIndex),
//             ),
//     );
//     // : Center(
//     //     child: pageIndex.isEven
//     //         ? Container(
//     //             height: MediaQuery.sizeOf(context).height,
//     //             color: quranCtrl.backgroundColor,
//     //             child: Focus(
//     //               focusNode: quranCtrl.state.quranPageUDFocusNode,
//     //               onKeyEvent: (node, event) =>
//     //                   quranCtrl.controlUDByKeyboard(node, event),
//     //               child: Padding(
//     //                 padding: const EdgeInsets.symmetric(
//     //                   horizontal: 32.0,
//     //                 ),
//     //                 child: TextBuild(pageIndex: pageIndex),
//     //               ),
//     //             ),
//     //           )
//     //         : Container(
//     //             height: MediaQuery.sizeOf(context).height,
//     //             color: quranCtrl.backgroundColor,
//     //             child: Focus(
//     //               focusNode: quranCtrl.state.quranPageUDFocusNode,
//     //               onKeyEvent: (node, event) =>
//     //                   quranCtrl.controlUDByKeyboard(node, event),
//     //               child: Padding(
//     //                 padding: const EdgeInsets.symmetric(
//     //                   horizontal: 32.0,
//     //                 ),
//     //                 child: TextBuild(pageIndex: pageIndex),
//     //               ),
//     //             ),
//     //           ));
//   }
// }
