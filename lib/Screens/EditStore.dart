import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:flushbar/flushbar.dart';

import 'package:provider/provider.dart';

import 'package:beyya/CustomWidgets/ErrorAlert.dart';

import 'package:beyya/Models/Item.dart';
import 'package:beyya/Models/UserDocument.dart';

import 'package:beyya/Services/DatabaseServices.dart';

class EditStore extends StatefulWidget {
  final String currentStore;

  EditStore({this.currentStore});
  @override
  _EditStoreState createState() => _EditStoreState();
}

class _EditStoreState extends State<EditStore> {
  String _changedStore;
  TextEditingController _storeController;
  bool _nullOrInvalidOrSameStore = true;
  final _editStoreKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _storeController = TextEditingController(text: widget.currentStore);
  }

  @override
  void dispose() {
    super.dispose();
    _storeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _editStoreKey,
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
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Consumer<UserDocument>(
            builder: (_, data, __) {
              if (data is LoadingUserDocument) {
                return const CircularProgressIndicator();
              } else if (data is ErrorFetchingUserDocument) {
                String err = data.err;
                FirebaseCrashlytics.instance
                    .log('Error loading data for Edit store route: $err');
                return Center(
                  child: Text('Oops! Something went wrong. Please restart the app and try again.'),
                );
              } else if (data is UserData) {
                List<Item> items = List.from(data.items);
                return Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                          autofocus: true,
                          controller: _storeController,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (text) {
                            if (text == null ||
                                text.isEmpty ||
                                text == widget.currentStore) {
                              setState(() {
                                _nullOrInvalidOrSameStore = true;
                              });
                              return null;
                            } else {
                              setState(() {
                                _nullOrInvalidOrSameStore = false;
                                _changedStore = text;
                              });
                              return null;
                            }
                          },
                          decoration: InputDecoration.collapsed(hintText: 'Add Store')),
                    ),
                    IconButton(
                        iconSize: 24.0,
                        disabledColor: Colors.grey,
                        color: Colors.red[500],
                        icon: Icon(
                          Icons.save,
                        ),
                        onPressed: _nullOrInvalidOrSameStore
                            ? null
                            : () async {
                                try {
                                  items.forEach((item) async {
                                    if (item.store == widget.currentStore) {
                                      //update all items tied to current store
                                      String encodedItem=DatabaseService().encodeAsFirebaseKey(text: item.item);
                                      String encodedCategory=DatabaseService().encodeAsFirebaseKey(text: item.category);
                                      String encodedStore=DatabaseService().encodeAsFirebaseKey(text: item.store);
                                      await DatabaseService(
                                              dbDocId: data.docIdOfListInUse)
                                          .editItem(
                                              item: item.item,
                                              category: item.category,
                                              store: _changedStore,
                                              star: item.star,
                                              id: encodedItem +
                                                  encodedCategory +
                                                  encodedStore);
                                    }
                                  });
                                  await DatabaseService(
                                          dbDocId: data.docIdOfListInUse)
                                      .deleteStore(store: widget.currentStore);
                                  await DatabaseService(
                                          dbDocId: data.docIdOfListInUse)
                                      .addStore(store: _changedStore);
                                  Navigator.pop(context);
                                  Flushbar(
                                    flushbarPosition: FlushbarPosition.TOP,
                                    message: 'Updated \"$_changedStore\"',
                                    duration: Duration(seconds: 2),
                                    margin: EdgeInsets.all(8),
                                    borderRadius: 10,
                                  )..show(context);
                                } catch (e, s) {
                                  await FirebaseCrashlytics.instance.log(
                                      'Save button pressed in edit store modal bottom sheet');
                                  await FirebaseCrashlytics.instance.recordError(
                                      e, s,
                                      reason:
                                          'Save button pressed in edit store modal bottom sheet');
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return ErrorAlert(
                                            errorMessage: e.toString());
                                      });
                                }
                              }),
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
