import 'package:beyya/CustomWidgets/ItemFilterProvider.dart';
import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:provider/provider.dart';

import 'package:beyya/CustomWidgets/ErrorAlert.dart';
import 'package:beyya/CustomWidgets/ItemTile.dart';
import 'package:beyya/CustomWidgets/StoreFilterDropdown.dart';
import 'package:beyya/CustomWidgets/SwipeLeftBackground.dart';
import 'package:beyya/CustomWidgets/SwipeRightBackground.dart';

import 'package:beyya/Models/Item.dart';
import 'package:beyya/Models/UserDocument.dart';

import 'package:beyya/Screens/AddItem.dart';

import 'package:beyya/Services/DatabaseServices.dart';

class CheckList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserDocument>(
      builder: (_, data, __) {
        if (data is LoadingUserDocument) {
          return const CircularProgressIndicator();
        } else if (data is ErrorFetchingUserDocument) {
          String err = data.err;
          FirebaseCrashlytics.instance
              .log('Error loading data for Checklist route: $err');
          return Center(
            child: Text(
                'Oops! Something went wrong. Please restart the app and try again.'),
          );
        } else if (data is UserData) {
          DatabaseService _db = DatabaseService(dbDocId: data.docIdOfListInUse);
          List<String> _categoriesInUse = [];
          final List<Item> _items = List.from(data.items);
          if (_items.isNotEmpty) {
            _items.sort(
                (a, b) => a.item.toLowerCase().compareTo(b.item.toLowerCase()));
            _items.forEach((item) {
              if (item.store ==
                      Provider.of<StoreFilterProvider>(context).storeFilter ||
                  Provider.of<StoreFilterProvider>(context).storeFilter ==
                      'All stores'&&item.item.toLowerCase().split(' ').any((word) => word.startsWith(Provider.of<ItemFilterProvider>(context).itemFilter))) {
                _categoriesInUse.add(item.category);
              }
            });
            _categoriesInUse = _categoriesInUse
                .toSet()
                .toList(); //converting to set to remove duplicates and again converting back to list
            _categoriesInUse
                .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
            if (_categoriesInUse.contains('Misc')) {
              _categoriesInUse.remove('Misc');
              _categoriesInUse.add('Misc');
            } //moving 'Misc' to last category
            return ListView.builder(
              padding: EdgeInsets.all(2.0),
              //List of categories
              itemBuilder: (context, categoryIndex) {
                return ListTile(
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            _categoriesInUse[categoryIndex],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              height: 0.3,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  subtitle: ListView.builder(
                    padding: EdgeInsets.all(2.0),
                    //2nd level list - list of items
                    physics: ClampingScrollPhysics(),
                    //to prevent scrolling at the second level of nested list
                    shrinkWrap: true,
                    //wraps the items under each categories
                    itemBuilder: (
                      context,
                      itemIndex,
                    ) {
                      return _categoriesInUse[categoryIndex] ==
                                  _items[itemIndex]
                                      .category && //filter for _items just under this category
                          _items[itemIndex].item.toLowerCase().split(' ').any((word) => word.startsWith(Provider.of<ItemFilterProvider>(context).itemFilter))&&
                              (Provider.of<StoreFilterProvider>(context)
                                          .storeFilter ==
                                      _items[itemIndex]
                                          .store || //if storeFilterDropdown is set to a specific store, filter only for item objects that have this store
                                  Provider.of<StoreFilterProvider>(context)
                                          .storeFilter ==
                                      'All stores') //display items from all stores if the storeFilterDropdown is set to "All stores"
                          ? Dismissible(
                            key: ObjectKey(_items[itemIndex]),
                            child: ItemTile(
                              docIdOfListInUse: data.docIdOfListInUse,
                              item: _items[itemIndex].item,
                              category: _items[itemIndex].category,
                              store: _items[itemIndex].store,
                              star: _items[itemIndex].star,
                              toggleStar: () {
                                String encodedItem =
                                _db.encodeAsFirebaseKey(text: _items[itemIndex].item);
                                String encodedCategory =
                                _db.encodeAsFirebaseKey(text: _items[itemIndex].category);
                                String encodedStore =
                                _db.encodeAsFirebaseKey(text: _items[itemIndex].store);
                                _db.toggleStar(
                                    star: _items[itemIndex].star,
                                    id: encodedItem +
                                        encodedCategory +
                                        encodedStore);
                              },
                            ),
                            background: SwipeRightBackground(),
                            secondaryBackground: SwipeLeftBackground(),
                            onDismissed: (direction) async {
                              String itemName=_items[itemIndex].item;
                              try {
                                String encodedItem =
                                    _db.encodeAsFirebaseKey(
                                        text: _items[itemIndex].item);
                                String encodedCategory =
                                    _db.encodeAsFirebaseKey(
                                        text: _items[itemIndex].category);
                                String encodedStore =
                                    _db.encodeAsFirebaseKey(
                                        text: _items[itemIndex].store);
                                await _db.deleteItem(
                                    id: encodedItem +
                                        encodedCategory +
                                        encodedStore);
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text('Deleted "$itemName"'),
                                  action: SnackBarAction(
                                    label: 'UNDO',
                                    textColor: Colors.amber,
                                    onPressed: () {
                                      _db.addItem(
                                        item: _items[itemIndex].item,
                                        store: _items[itemIndex].store,
                                        category: _items[itemIndex].category,
                                        star: _items[itemIndex].star,
                                      );
                                    },
                                  ),
                                ));
                              } catch (e, s) {
                                await FirebaseCrashlytics.instance
                                    .log('Item dismissed in checklist');
                                await FirebaseCrashlytics.instance
                                    .recordError(
                                        e, s,
                                        reason:
                                            'Item dismissed in checklist');
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ErrorAlert(
                                          errorMessage: e.toString());
                                    });
                              }
                            },
                          )
                          : SizedBox(); //return an empty box when the ternary operator returns false
                    },
                    itemCount: _items.length,
                  ),
                );
              },
              itemCount: _categoriesInUse.length,
            );
          } else {
            return GestureDetector(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/crayon_1538.png',
                        fit: BoxFit.scaleDown,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          'Tap to start building your checklist.',
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 18.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => SingleChildScrollView(child: AddItem()),
                );
              },
            );
          }
        }
        throw FallThroughError();
      },
    );
  }
}
