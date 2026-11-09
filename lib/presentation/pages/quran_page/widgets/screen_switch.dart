// part of '../quran.dart';

// /// Switches between [AyahsWidget] (list view, isPages == 1)
// /// and [QuranPages] (Mushaf page view, isPages == 0).
// ///
// /// Toggled by the Page button in [AudioWidget].
// class ScreenSwitch extends StatelessWidget {
//   ScreenSwitch({super.key});

//   final quranCtrl = QuranController.instance;

//   @override
//   Widget build(BuildContext context) {
//     return Obx(
//       () => AnimatedSwitcher(
//         duration: const Duration(milliseconds: 300),
//         transitionBuilder: (child, animation) =>
//             FadeTransition(opacity: animation, child: child),
//         child: quranCtrl.state.isPages.value == 1
//             ? AyahsWidget(key: const ValueKey('ayahs'))
//             : QuranPages(key: const ValueKey('pages')),
//       ),
//     );
//   }
// }
