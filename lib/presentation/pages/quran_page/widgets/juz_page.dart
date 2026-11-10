// part of '../quran.dart';

// class QuranJuz extends StatelessWidget {
//   QuranJuz({super.key});

//   final quranCtrl = QuranController.instance;

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     final primaryColor = cs.primary;
//     final accentColor = cs.surface;
//     final bgColor = cs.primaryContainer;
//     final textColor = Theme.of(context).hintColor;

//     return CupertinoScrollbar(
//       controller: quranCtrl.juzController,
//       child: ColoredBox(
//         color: bgColor,
//         child: ListView.builder(
//           padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
//           physics: const AlwaysScrollableScrollPhysics(),
//           itemCount: 30,
//           controller: quranCtrl.juzController,
//           itemBuilder: (_, index) {
//             final juz = quranCtrl.state.allAyahs.firstWhere(
//               (a) => a.juz == index + 1,
//             );
//             final currentSurah = quranCtrl.getCurrentSurahByPage(juz.page);

//             return Padding(
//               padding: const EdgeInsets.only(bottom: 6),
//               child: GetX<QuranController>(
//                 builder: (ctrl) {
//                   final isCurrentJuz = ctrl.getCurrentJuzNumber(index).value;
//                   return Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       onTap: () {
//                         Get.to(
//                           () => QuranHome(),
//                           transition: Transition.downToUp,
//                         );
//                         quranCtrl.changeSurahListOnTap(juz.page);
//                       },
//                       borderRadius: BorderRadius.circular(14),
//                       splashColor: primaryColor.withValues(alpha: 0.12),
//                       highlightColor: primaryColor.withValues(alpha: 0.06),
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 250),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 14,
//                         ),
//                         decoration: BoxDecoration(
//                           color: isCurrentJuz
//                               ? primaryColor.withValues(alpha: 0.1)
//                               : Colors.transparent,
//                           borderRadius: BorderRadius.circular(14),
//                           border: Border.all(
//                             width: isCurrentJuz ? 1.5 : 1,
//                             color: isCurrentJuz
//                                 ? primaryColor.withValues(alpha: 0.6)
//                                 : primaryColor.withValues(alpha: 0.08),
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             // ── Juz number badge ──────────────────────────
//                             _JuzNumberBadge(
//                               number: index + 1,
//                               primaryColor: primaryColor,
//                               textColor: textColor,
//                               isHighlighted: isCurrentJuz,
//                             ),

//                             const SizedBox(width: 12),

//                             // ── Juz content ───────────────────────────────
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   // First ayah text preview
//                                   Text(
//                                     juz.text,
//                                     style: TextStyle(
//                                       color: textColor,
//                                       fontFamily: 'uthmanic2',
//                                       fontSize: 22,
//                                       fontWeight: FontWeight.w700,
//                                       height: 1.5,
//                                     ),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                   const SizedBox(height: 5),
//                                   // Surah + page info
//                                   Row(
//                                     children: [
//                                       Text(
//                                         currentSurah.arabicName,
//                                         style: TextStyle(
//                                           fontFamily: 'naskh',
//                                           fontWeight: FontWeight.w700,
//                                           fontSize: 14,
//                                           color: accentColor,
//                                         ),
//                                       ),
//                                       Container(
//                                         margin: const EdgeInsets.symmetric(
//                                           horizontal: 6,
//                                         ),
//                                         width: 4,
//                                         height: 4,
//                                         decoration: BoxDecoration(
//                                           color: accentColor.withValues(
//                                             alpha: 0.5,
//                                           ),
//                                           shape: BoxShape.circle,
//                                         ),
//                                       ),
//                                       Text(
//                                         '${'page'.tr} ${juz.page.toString().convertNumbersToCurrentLang()}',
//                                         style: TextStyle(
//                                           fontFamily: 'naskh',
//                                           fontSize: 13,
//                                           fontWeight: FontWeight.w600,
//                                           color: textColor.withValues(
//                                             alpha: 0.55,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             // ── Current juz dot indicator ─────────────────
//                             if (isCurrentJuz)
//                               Container(
//                                 width: 6,
//                                 height: 6,
//                                 decoration: BoxDecoration(
//                                   color: accentColor,
//                                   shape: BoxShape.circle,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// // ─── Juz number badge ─────────────────────────────────────────────────────────
// class _JuzNumberBadge extends StatelessWidget {
//   final int number;
//   final Color primaryColor;
//   final Color textColor;
//   final bool isHighlighted;

//   const _JuzNumberBadge({
//     required this.number,
//     required this.primaryColor,
//     required this.textColor,
//     required this.isHighlighted,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 50,
//       height: 50,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           RepaintBoundary(
//             child: SvgPicture.asset(
//               'assets/svg/sora_num.svg',
//               width: 50,
//               height: 50,
//               colorFilter: ColorFilter.mode(
//                 isHighlighted
//                     ? primaryColor
//                     : primaryColor.withValues(alpha: 0.75),
//                 BlendMode.srcIn,
//               ),
//             ),
//           ),
//           Transform.translate(
//             offset: const Offset(0, 1),
//             child: Text(
//               '$number'.convertNumbersToCurrentLang(),
//               style: TextStyle(
//                 color: isHighlighted ? Colors.white : textColor,
//                 fontFamily: 'kufi',
//                 fontSize: 15,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
