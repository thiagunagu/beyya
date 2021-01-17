import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:provider/provider.dart';

import 'package:beyya/Models/UserDocument.dart';

class StoreFilterDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserDocument>(
      builder: (_, data, __) {
        if (data is LoadingUserDocument) {
          return Container();
        } else if (data is ErrorFetchingUserDocument) {
          String err = data.err;
          FirebaseCrashlytics.instance
              .log('Error loading data for store filter: $err');
          return Container();
        } else if (data is UserData) {
          final List<String> _storesList = List.from(data.stores);
          _storesList
              .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
          _storesList.insert(
              0, 'All stores'); //'adding 'All stores' as a filter option
          _storesList.remove('Other');
          _storesList.add('Other'); //moving the "Other" option to last
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
            child: DropdownButton<String>(
              value: Provider.of<StoreFilterProvider>(context).storeFilter,
              icon: Provider.of<StoreFilterProvider>(context).storeFilter ==
                      'All stores'
                  ? Icon(
                      Icons.filter_alt_outlined,
                      color: Colors.grey[200],
                    )
                  : Icon(
                      Icons.filter_alt_sharp,
                      color: Colors.grey[200],
                    ),
              iconSize: 24,
              elevation: 16,
              onChanged: (String newValue) {
                Provider.of<StoreFilterProvider>(context, listen: false)
                    .changeStoreFilter(
                  newValue,
                );
              },
              items: _storesList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 0, 4),
                    child: Text(
                      value,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }).toList(),
              dropdownColor: Theme.of(context).primaryColor,
              underline: Container(
                height: 1,
                color: Colors.white,
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}

class StoreFilterProvider extends ChangeNotifier {
  String storeFilter = 'All stores';
  void changeStoreFilter(newValue) {
    storeFilter = newValue;
    notifyListeners();
  }
}
