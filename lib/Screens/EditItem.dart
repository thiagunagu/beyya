import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:provider/provider.dart';

import 'package:flushbar/flushbar.dart';

import 'package:beyya/CustomWidgets/ErrorAlert.dart';

import 'package:beyya/Models/UserDocument.dart';

import 'package:beyya/Services/DatabaseServices.dart';
import 'package:beyya/Services/KeyboardHeightProvider.dart';

import 'package:beyya/Screens/CategoryQuickAdd.dart';
import 'package:beyya/Screens/StoreQuickAdd.dart';

class EditItem extends StatefulWidget {
  final String currentItem;
  final String currentStore;
  final String currentCategory;
  final bool currentStar;

  EditItem({
    this.currentItem,
    this.currentStore,
    this.currentCategory,
    this.currentStar,
  });

  @override
  _EditItemState createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  String _item; //to save the item name after editing
  String _store; //to save the new store
  String _category; //to save the new store
  bool _star; //to save the new star
  FocusNode _editItemFocusNode;
  final _editItemKey = GlobalKey<FormState>();
  TextEditingController _itemController;
  bool _nullOrInvalidItem = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _editItemFocusNode = FocusNode();
    _itemController = TextEditingController(text: widget.currentItem);
    _item = widget.currentItem;
    _store = widget.currentStore;
    _category = widget.currentCategory;
    _star = widget.currentStar;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _editItemFocusNode.dispose();
    _itemController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_editItemFocusNode.hasFocus) {
      Provider.of<KeyboardHeightProvider>(context, listen: false)
          .setKeyboardHeight(MediaQuery.of(context).viewInsets.bottom);
    }

    return Form(
      key: _editItemKey,
      child: Container(
        color: Color(0xff757575),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              )),
          padding: EdgeInsets.only(
              left: 20.0,
              right: 8.0,
              bottom:
                  Provider.of<KeyboardHeightProvider>(context, listen: false)
                          .keyboardHeight ??
                      MediaQuery.of(context).viewInsets.bottom),
          child: Consumer<UserDocument>(
            builder: (_, data, __) {
              if (data is LoadingUserDocument) {
                return const CircularProgressIndicator();
              } else if (data is ErrorFetchingUserDocument) {
                String err = data.err;
                FirebaseCrashlytics.instance
                    .log('Error loading data for Edit item route: $err');
                return Center(
                  child: Text(
                      'Oops! Something went wrong. Please restart the app and try again.'),
                );
              } else if (data is UserData) {
                final List<String> categories = List.from(data.categories);
                categories
                    .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                categories.remove('Misc');
                categories.add('Misc');
                categories.add('Add category');
                final List<String> stores = List.from(data.stores);
                stores
                    .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                stores.remove('Other');
                stores.add('Other');
                stores.add('Add store');
                return Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: TextField(
                                autofocus: true,
                                controller: _itemController,
                                focusNode: _editItemFocusNode,
                                textCapitalization: TextCapitalization.sentences,
                                onChanged: (text) {
                                  if (text == null ||
                                      text.isEmpty ||
                                      text == widget.currentItem) {
                                    setState(() {
                                      _nullOrInvalidItem = true;
                                    });
                                    return null;
                                  } else {
                                    setState(() {
                                      _nullOrInvalidItem = false;
                                      _item = text;
                                    });
                                    return null;
                                  }
                                },
                                decoration: InputDecoration.collapsed(hintText: 'Add Item'))),
                        IconButton(
                          icon: Icon(_star ? Icons.star : Icons.star_border),
                          onPressed: () {
                            setState(() {
                              _star = !_star;
                              if (_star != widget.currentStar) {
                                _nullOrInvalidItem = false;
                              } else {
                                _nullOrInvalidItem = true;
                              }
                            });
                          },
                        ),
                        IconButton(
                          disabledColor: Colors.grey,
                          color: Colors.red[500],
                          icon: Icon(
                            Icons.save,
                          ),
                          onPressed: _nullOrInvalidItem
                              ? null
                              : () async {
                                  try {
                                    String encodedItem = DatabaseService()
                                        .encodeAsFirebaseKey(
                                            text: widget.currentItem);
                                    String encodedCategory = DatabaseService()
                                        .encodeAsFirebaseKey(
                                            text: widget.currentCategory);
                                    String encodedStore = DatabaseService()
                                        .encodeAsFirebaseKey(
                                            text: widget.currentStore);
                                    await DatabaseService(
                                            dbDocId: data.docIdOfListInUse)
                                        .editItem(
                                      item: _item,
                                      category: _category,
                                      store: _store,
                                      star: _star,
                                      id: encodedItem +
                                          encodedCategory +
                                          encodedStore,
                                    );
                                    Navigator.pop(context);
                                    Flushbar(
                                      flushbarPosition: FlushbarPosition.TOP,
                                      message: 'Updated \"$_item\"',
                                      duration: Duration(seconds: 2),
                                      margin: EdgeInsets.all(8),
                                      borderRadius: 10,
                                    )..show(context);
                                  } catch (e, s) {
                                    await FirebaseCrashlytics.instance.log(
                                        'Save button pressed in edit item modal bottom sheet');
                                    await FirebaseCrashlytics.instance.recordError(
                                        e, s,
                                        reason:
                                            'Save button pressed in edit item modal bottom sheet');
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return ErrorAlert(
                                              errorMessage: e.toString());
                                        });
                                  }
                                },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Spacer(),
                        Expanded(
                          //category dropdown
                          flex: 5,
                          child: Listener(
                            onPointerDown: (_) =>
                                FocusScope.of(context).unfocus(),
                            child: DropdownButton(
                              isExpanded: true,
                              value: _category,
                              items: categories
                                  .map<DropdownMenuItem<String>>(
                                    (category) => DropdownMenuItem(
                                      value: category,
                                      child: category == 'Add category'
                                          ? Text(
                                              category,
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            )
                                          : Text(category),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (newValue) {
                                if (newValue == 'Add category') {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CategoryQuickAdd();
                                      }).then((value) => setState(() {
                                        _category = value;
                                        if (value != widget.currentCategory) {
                                          _nullOrInvalidItem = false;
                                        } else {
                                          _nullOrInvalidItem = true;
                                        }
                                      }));
                                } else {
                                  setState(() {
                                    _category = newValue;
                                    if (newValue != widget.currentCategory) {
                                      _nullOrInvalidItem = false;
                                    } else {
                                      _nullOrInvalidItem = true;
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Spacer(),
                        Expanded(
                          //store dropdown
                          flex: 5,
                          child: Listener(
                            onPointerDown: (_) =>
                                FocusScope.of(context).unfocus(),
                            child: DropdownButton(
                              isExpanded: true,
                              value: _store,
                              items: stores
                                  .map<DropdownMenuItem<String>>(
                                    (store) => DropdownMenuItem(
                                      value: store,
                                      child: store == 'Add store'
                                          ? Text(
                                              store,
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            )
                                          : Text(store),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (newValue) {
                                if (newValue == 'Add store') {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return StoreQuickAdd();
                                      }).then((value) => setState(() {
                                        _store = value;
                                        if (value != widget.currentStore) {
                                          _nullOrInvalidItem = false;
                                        } else {
                                          _nullOrInvalidItem = true;
                                        }
                                      }));
                                } else {
                                  setState(() {
                                    _store = newValue;
                                    if (newValue != widget.currentStore) {
                                      _nullOrInvalidItem = false;
                                    } else {
                                      _nullOrInvalidItem = true;
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Spacer()
                      ],
                    ),
                  ],
                );
              }
              throw FallThroughError();
            },
          ),
        ),
      ),
    );
  }
}
