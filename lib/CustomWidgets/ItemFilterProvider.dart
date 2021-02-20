import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:provider/provider.dart';

import 'package:beyya/Models/UserDocument.dart';

class ItemFilterProvider extends ChangeNotifier {
  String itemFilter = '';
  void changeItemFilter({newValue}) {
    itemFilter = newValue;
    notifyListeners();
  }
}
