import 'package:flutter/material.dart';

import '../screens/adhkar_fav.dart';
import 'adhkar_list.dart';

class TabBarViewWidget extends StatelessWidget {
  final TabController? controller;
  const TabBarViewWidget({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: TabBarView(
        controller: controller,
        children: const <Widget>[AdhkarList(), AdhkarFav()],
      ),
    );
  }
}
