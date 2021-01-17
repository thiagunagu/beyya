import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flushbar/flushbar.dart';

import 'package:provider/provider.dart';

import 'package:beyya/CustomWidgets/ErrorAlert.dart';
import 'package:beyya/CustomWidgets/SwipeLeftBackground.dart';
import 'package:beyya/CustomWidgets/SwipeRightBackground.dart';

import 'package:beyya/Models/Item.dart';
import 'package:beyya/Models/UserDocument.dart';

import 'package:beyya/Screens/AddCategory.dart';
import 'package:beyya/Screens/EditCategory.dart';

import 'package:beyya/Services/DatabaseServices.dart';

class ShowCategories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool _numOfCategoriesLimitReached = false;
    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.centerLeft,
          child: Text('Categories'),
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
                  .log('Error loading data for Show category route: $err');
              return Center(
                child: Text('Oops! Something went wrong. Please restart the app and try again.'),
              );
            } else if (data is UserData) {
              final List<Item> _items = List.from(data.items);
              List<String> _categories = List.from(data.categories);
              _categories
                  .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
              _categories.remove('Misc');
              _categories.add('Misc');
              if (_categories.length == 20) {
                _numOfCategoriesLimitReached = true;
              } else {
                _numOfCategoriesLimitReached = false;
              }
              return ListView.builder(
                //build a list of category tiles
                itemCount: _categories.length,
                itemBuilder: (context, categoryIndex) {
                  return _categories[categoryIndex] != 'Misc'
                      ? Dismissible(
                          key: ObjectKey(_categories[categoryIndex]),
                          child: Card(
                            child: ListTile(
                                title: Text(_categories[categoryIndex]),
                                onTap: () {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) => SingleChildScrollView(
                                            child: EditCategory(
                                              currentCategory:
                                                  _categories[categoryIndex],
                                            ),
                                          ));
                                }),
                          ),
                          onDismissed: (direction) async {
                            try {
                              if (_categories[categoryIndex] != 'Misc') {
                                _items.forEach((item) async {
                                  if (item.category ==
                                      _categories[categoryIndex]) {
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
                                            category: 'Misc',
                                            store: item.store,
                                            star: item.star,
                                            id: encodedItem +
                                                encodedCategory +
                                                encodedStore);
                                  }
                                });
                                String _category = _categories[categoryIndex];
                                await DatabaseService(
                                        dbDocId: data.docIdOfListInUse)
                                    .deleteCategory(
                                        category: _categories[categoryIndex]);
                                Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        '$_category has been deleted. Items tied to this category have been moved to \"Misc\"')));
                              }
                            } catch (e, s) {
                              await FirebaseCrashlytics.instance
                                  .log('Swiped category (dismissed)');
                              await FirebaseCrashlytics.instance.recordError(e, s,
                                  reason: 'Swiped category (dismissed)');
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
                            //build a non-dismissible tile for "Other" category
                            title: Text(_categories[categoryIndex]),
                            onTap: () {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      "'Misc' can't be modified or deleted")));
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
        label: Text('Add category'),
        onPressed: () {
          if (_numOfCategoriesLimitReached == true) {
            Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              message:
                  'You have already reached the maximum number of categories allowed. Delete some unused categories to make room for new ones.',
              duration: Duration(seconds: 6),
              margin: EdgeInsets.all(8),
              borderRadius: 10,
            )..show(context);
          } else {
            showModalBottomSheet(
                //modal bottom sheet with text field to add new category
                context: context,
                builder: (context) =>
                    SingleChildScrollView(child: AddCategory()));
          }
        },
      ),
    );
  }
}
