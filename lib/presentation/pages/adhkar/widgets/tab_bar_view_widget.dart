import 'package:flutter/material.dart';

import '../screens/adhkar_evening.dart';
import '../screens/adhkar_morning.dart';

class TabBarViewWidget extends StatelessWidget {
  final TabController? controller;
  const TabBarViewWidget({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: TabBarView(
        controller: controller,
        children: const <Widget>[AdhkarMorningItem(), AdhkarEveningItem()],
      ),
    );
  }
}
