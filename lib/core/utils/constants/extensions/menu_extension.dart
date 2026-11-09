// import 'package:bot_toast/bot_toast.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:get/get.dart';
// import 'package:misbah_path/presentation/pages/quran_page/quran.dart';

// import '/core/services/services_locator.dart';
// import '/core/utils/constants/svg_constants.dart';
// import '/core/widgets/share/share_ayah_options.dart';

// extension ContextMenuExtension on BuildContext {
//   void showAyahMenu({
//     required int surahNum,
//     required int ayahNum,
//     required String ayahText,
//     required int pageIndex,
//     required String ayahTextNormal,
//     required int ayahUQNum,
//     required String surahName,
//     dynamic details,
//   }) {
//     BotToast.showAttachedWidget(
//       target: details.globalPosition,
//       verticalOffset: 16.0,
//       horizontalOffset: 0.0,
//       preferDirection: sl<QuranController>().state.preferDirection,
//       animationDuration: const Duration(milliseconds: 220),
//       animationReverseDuration: const Duration(milliseconds: 160),
//       attachedBuilder: (cancel) => _AyahMenuCard(
//         surahNum: surahNum,
//         ayahNum: ayahNum,
//         ayahText: ayahText,
//         pageIndex: pageIndex,
//         ayahTextNormal: ayahTextNormal,
//         ayahUQNum: ayahUQNum,
//         surahName: surahName,
//         cancel: cancel,
//       ),
//     );
//   }
// }

// // ── Stateless card widget so we can use proper BuildContext ──────────────────

// class _AyahMenuCard extends StatelessWidget {
//   const _AyahMenuCard({
//     required this.surahNum,
//     required this.ayahNum,
//     required this.ayahText,
//     required this.pageIndex,
//     required this.ayahTextNormal,
//     required this.ayahUQNum,
//     required this.surahName,
//     required this.cancel,
//   });

//   final int surahNum;
//   final int ayahNum;
//   final String ayahText;
//   final int pageIndex;
//   final String ayahTextNormal;
//   final int ayahUQNum;
//   final String surahName;
//   final VoidCallback cancel;

//   @override
//   Widget build(BuildContext context) {
//     final cs = Get.theme.colorScheme;
//     final surface = cs.primaryContainer;
//     final accent = cs.surface;
//     final labelColor = Get.theme.hintColor;

//     final items = <_MenuItemData>[
//       _MenuItemData(
//         svgPath: SvgPath.svgTafsirIcon,
//         labelKey: 'tafseer',
//         child: TafsirButton(
//           surahNum: surahNum,
//           ayahNum: ayahNum,
//           ayahText: ayahText,
//           pageIndex: pageIndex,
//           ayahTextNormal: ayahTextNormal,
//           ayahUQNum: ayahUQNum,
//           cancel: cancel,
//         ),
//       ),
//       _MenuItemData(
//         svgPath: SvgPath.svgPlayArrow,
//         labelKey: 'playAyah',
//         child: PlayButton(
//           surahNum: surahNum,
//           ayahNum: ayahNum,
//           ayahUQNum: ayahUQNum,
//           singleAyahOnly: true,
//           cancel: cancel,
//         ),
//       ),
//       _MenuItemData(
//         svgPath: SvgPath.svgPlayAll,
//         labelKey: 'playSurah',
//         child: PlayButton(
//           surahNum: surahNum,
//           ayahNum: ayahNum,
//           ayahUQNum: ayahUQNum,
//           cancel: cancel,
//         ),
//       ),
//       _MenuItemData(
//         svgPath: SvgPath.svgBookmarkIcon,
//         labelKey: 'bookmark',
//         child: AddBookmarkButton(
//           surahNum: surahNum,
//           ayahNum: ayahNum,
//           ayahUQNum: ayahUQNum,
//           pageIndex: pageIndex,
//           surahName: surahName,
//           cancel: cancel,
//         ),
//       ),
//       _MenuItemData(
//         svgPath: SvgPath.svgCopyIcon,
//         labelKey: 'copy',
//         child: CopyButton(
//           ayahNum: ayahNum,
//           surahName: surahName,
//           ayahText: ayahText,
//           cancel: cancel,
//         ),
//       ),
//       _MenuItemData(
//         svgPath: SvgPath.svgShareIcon,
//         labelKey: 'share',
//         child: ShareAyahOptions(
//           ayahNumber: ayahNum,
//           ayahUQNumber: ayahUQNum,
//           surahNumber: surahNum,
//           ayahTextNormal: ayahTextNormal,
//           ayahText: ayahText,
//           surahName: surahName,
//           pageNumber: pageIndex,
//         ),
//       ),
//     ];

//     return Material(
//       color: Colors.transparent,
//       child: Container(
//         constraints: const BoxConstraints(maxWidth: 340),
//         decoration: BoxDecoration(
//           color: surface,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: accent.withValues(alpha: .25), width: 1.2),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: .18),
//               blurRadius: 24,
//               spreadRadius: 0,
//               offset: const Offset(0, 8),
//             ),
//             BoxShadow(
//               color: accent.withValues(alpha: .08),
//               blurRadius: 8,
//               spreadRadius: 0,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // ── Surah + ayah info header ───────────────────────────────
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 14,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: accent.withValues(alpha: .18),
//                   border: Border(
//                     bottom: BorderSide(
//                       color: accent.withValues(alpha: .2),
//                       width: 1,
//                     ),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       surahName,
//                       textDirection: TextDirection.rtl,
//                       style: TextStyle(
//                         fontFamily: 'naskh',
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                         color: labelColor,
//                         letterSpacing: 0.2,
//                       ),
//                     ),
//                     const Gap(6),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 2,
//                       ),
//                       decoration: BoxDecoration(
//                         color: accent.withValues(alpha: .3),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         '$ayahNum',
//                         style: TextStyle(
//                           fontFamily: 'kufi',
//                           fontSize: 12,
//                           color: labelColor.withValues(alpha: .85),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // ── Action buttons ─────────────────────────────────────────
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 6,
//                   vertical: 10,
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: items.map((item) {
//                     return _MenuActionSlot(
//                       data: item,
//                       accent: accent,
//                       labelColor: labelColor,
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ── Single action column: icon button + label ────────────────────────────────

// class _MenuActionSlot extends StatelessWidget {
//   const _MenuActionSlot({
//     required this.data,
//     required this.accent,
//     required this.labelColor,
//   });

//   final _MenuItemData data;
//   final Color accent;
//   final Color labelColor;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 3),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 44,
//             height: 44,
//             decoration: BoxDecoration(
//               color: accent.withValues(alpha: .15),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: accent.withValues(alpha: .18),
//                 width: 1,
//               ),
//             ),
//             child: Center(child: data.child),
//           ),
//           const Gap(4),
//           Text(
//             data.labelKey.tr,
//             style: TextStyle(
//               fontFamily: 'kufi',
//               fontSize: 9.5,
//               color: labelColor.withValues(alpha: .75),
//               height: 1.2,
//             ),
//             textAlign: TextAlign.center,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Data model for each menu item ────────────────────────────────────────────

// class _MenuItemData {
//   final String svgPath;
//   final String labelKey;
//   final Widget child;
//   const _MenuItemData({
//     required this.svgPath,
//     required this.labelKey,
//     required this.child,
//   });
// }
