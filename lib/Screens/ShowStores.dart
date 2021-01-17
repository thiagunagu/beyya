import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:flushbar/flushbar.dart';

import 'package:provider/provider.dart';

import 'package:beyya/CustomWidgets/ErrorAlert.dart';
import 'package:beyya/CustomWidgets/SwipeLeftBackground.dart';
import 'package:beyya/CustomWidgets/SwipeRightBackground.dart';

import 'package:beyya/Models/Item.dart';
import 'package:beyya/Models/UserDocument.dart';

import 'package:beyya/Screens/AddStore.dart';
import 'package:beyya/Screens/EditStore.dart';

import 'package:beyya/Services/DatabaseServices.dart';

class ShowStores extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool _numOfStoresLimitReached = false;
    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.centerLeft,
          child: Text('Stores'),
        ),
      ),
      body: SafeArea(
        child: Consumer<UserDocument>(
          builder: (_, data, __) {
            if (data is LoadingUserDocument) {
              return const CircularProgressIndicator();
            } else if (data is ErrorFetchingUserDocument) {
              String err = data.err;
              FirebaseCrashlytics.instance
                  .log('Error loading data for Show store route: $err');
              return Center(
                child: Text('Oops! Something went wrong. Please restart the app and try again.'),
              );
            } else if (data is UserData) {
              final List<Item> items = List.from(data.items);
              List<String> _stores = List.from(data.stores);
              _stores.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
              _stores.remove('Other');
              _stores.add('Other');
              if (_stores.length == 20) {
                _numOfStoresLimitReached = true;
              } else {
                _numOfStoresLimitReached = false;
              }
              return ListView.builder(
                //build a list of store tiles
                itemCount: _stores.length,
                itemBuilder: (context, storeIndex) {
                  return _stores[storeIndex] != 'Other'
                      ? Dismissible(
                          key: ObjectKey(_stores[storeIndex]),
                          child: Card(
                            child: ListTile(
                              title: Text(_stores[storeIndex]),
                              onTap: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) => SingleChildScrollView(
                                          child: EditStore(
                                            currentStore: _stores[storeIndex],
                                          ),
                                        ));
                              },
                            ),
                          ),
                          onDismissed: (direction) async {
                            try {
                              if (_stores[storeIndex] != 'Other') {
                                items.forEach((item) async {
                                  if (item.store == _stores[storeIndex]) {
                                    String encodedItem = DatabaseService()
                                        .encodeAsFirebaseKey(
                                            text: item.item);
                                    String encodedCategory = DatabaseService()
                                        .encodeAsFirebaseKey(
                                            text: item.category);
                                    String encodedStore = DatabaseService()
                                        .encodeAsFirebaseKey(
                                            text: item.store);
                                    await DatabaseService(
                                            dbDocId: data.docIdOfListInUse)
                                        .editItem(
                                            item: item.item,
                                            category: item.category,
                                            store: 'Other',
                                            star: item.star,
                                            id: encodedItem +
                                                encodedCategory +
                                                encodedStore);
                                  }
                                });
                                String _store = _stores[storeIndex];
                                await DatabaseService(
                                        dbDocId: data.docIdOfListInUse)
                                    .deleteStore(store: _stores[storeIndex]);
                                Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        '$_store has been deleted. Items tied to this store have been moved to \"Other\"')));
                              }
                            } catch (e, s) {
                              await FirebaseCrashlytics.instance
                                  .log('Swiped store (dismissed)');
                              await FirebaseCrashlytics.instance.recordError(e, s,
                                  reason: 'Swiped store (dismissed)');
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ErrorAlert(errorMessage: e.toString());
                                  });
                            }
                          },
                          background: SwipeRightBackground(),
                          secondaryBackground: SwipeLeftBackground(),
                        )
                      : Card(
                          child: ListTile(
                            //build a non-dismissible tile for "Other" store
                            title: Text(_stores[storeIndex]),
                            onTap: () {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      "'Other' can't be modified or deleted")));
                            },
                          ),
                        );
                },
              );
            }
            throw FallThroughError();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text('Add store'),
        onPressed: () {
          if (_numOfStoresLimitReached == true) {
            Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              message:
                  'You have already reached the maximum number of stores allowed. Delete some unused stores to make room for new ones.',
              duration: Duration(seconds: 6),
              margin: EdgeInsets.all(8),
              borderRadius: 10,
            )..show(context);
          } else {
            showModalBottomSheet(
                //modal bottom sheet with text field to add new strore
                context: context,
                builder: (context) => SingleChildScrollView(child: AddStore()));
          }
        },
      ),
    );
  }
}
