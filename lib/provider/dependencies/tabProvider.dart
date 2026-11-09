import 'package:flutter/cupertino.dart';

class TabProvider extends ChangeNotifier {
  int tabChange = 0;
  void onChangingTab(int tab) {
    tabChange = tab;
    notifyListeners();
  }
}
