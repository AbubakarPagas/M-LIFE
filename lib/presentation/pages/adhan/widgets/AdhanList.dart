import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/Adhan.dart';
import '../../../../provider/adhanProvider.dart';
import 'AdhanItem.dart';

// const centerPage = 20000;

// class AdhanList extends StatelessWidget {
//   final PageController _pageController;

//   const AdhanList(this._pageController, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     final adhanProvider = context.read<AdhanProvider>();

//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: PageView.builder(
//         itemCount: centerPage * 2 + 1,
//         controller: _pageController,
//         physics: const BouncingScrollPhysics(),
//         onPageChanged: (newPage) {
//           adhanProvider.changeDayOfDate(newPage - centerPage);
//         },
//         itemBuilder: (ctx, index) {
//           return AdhanListView(
//             dateTime: DateTime.now().add(Duration(days: index - centerPage)),
//             key: ValueKey(index),
//           );
//         },
//       ),
//     );
//   }
// }

class AdhanListView extends StatelessWidget {
  final DateTime dateTime;

  const AdhanListView({required this.dateTime, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NumberFormat timeFormat = NumberFormat('00');
    final adhanProvider = context.read<AdhanProvider>();
    final List<Adhan> adhans = adhanProvider.getAdhanData(dateTime);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: adhans.length,
        itemBuilder: (_, i) {
          return Padding(
            padding: EdgeInsets.only(
              top: i == 0 ? 8 : 0,
              bottom: i == adhans.length - 1 ? 16 : 0,
            ),
            child: AdhanItem(adhans[i], timeFormat),
          );
        },
      ),
    );
  }
}
