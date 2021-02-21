import 'package:flutter/material.dart';

class ItemFilterProvider extends ChangeNotifier {
  String itemFilter = '';
  void changeItemFilter({newValue}) {
    itemFilter = newValue;
    notifyListeners();
  }
}
