import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:another_flushbar/flushbar.dart';

import 'package:provider/provider.dart';

import 'package:beyya/CustomWidgets/ErrorAlert.dart';

import 'package:beyya/Models/ListInUse.dart';
import 'package:beyya/Models/UserDocument.dart'
;
import 'package:beyya/Services/DatabaseServices.dart';

class StoreQuickAdd extends StatefulWidget {
  @override
  _StoreQuickAddState createState() => _StoreQuickAddState();
}

class _StoreQuickAddState extends State<StoreQuickAdd> {
  TextEditingController _storeController = TextEditingController();
  final _storeQuickAddKey = GlobalKey<FormState>();
  bool _nullOrInvalidStore;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nullOrInvalidStore = true;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _storeQuickAddKey,
      child: AlertDialog(
        content: Consumer<ListInUse>(builder: (_, data, __) {
          if (data is LoadingListInUse) {
            return const CircularProgressIndicator();
          } else if (data is ErrorFetchingListInUSe) {
            String err = data.err;
            FirebaseCrashlytics.instance.log(
                'Error fetching list in use for quick add store route: $err');
            return Center(
              child: Text('Oops! Something went wrong. Please restart the app and try again.'),
            );
          } else if (data is ListInUseId) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    autofocus: true,
                    controller: _storeController,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (text) {
                      if (text == null ||
                          text.isEmpty ) {
                        setState(() {
                          _nullOrInvalidStore = true;
                        });
                        return null;
                      } else {
                        setState(() {
                          _nullOrInvalidStore = false;
                        });
                        return null;
                      }
                    },
                    decoration: InputDecoration.collapsed(
                      hintText: 'Add store',
                    ),
                  ),
                ),
                Consumer<UserDocument>(
                  builder: (_, userDocumentData, __) {
                    return IconButton(
                        iconSize: 35.0,
                        disabledColor: Colors.grey,
                        color: Colors.red[500],
                        icon: Icon(
                          Icons.add_circle,
                        ),
                        onPressed: _nullOrInvalidStore
                            ? null
                            : () async {
                                if (userDocumentData is UserData &&
                                    userDocumentData.stores.length == 20) {
                                  Flushbar(
                                    flushbarPosition: FlushbarPosition.TOP,
                                    message:
                                        'You have already reached the maximum number of stores allowed. Delete some unused stores to make room for new ones.',
                                    duration: Duration(seconds: 6),
                                    margin: EdgeInsets.all(8),
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  )..show(context);
                                } else {
                                  try {
                                    await DatabaseService(
                                            dbDocId: data.docIdOfListInUse)
                                        .addStore(store: _storeController.text);
                                    final String _store = _storeController.text;
                                    if (_storeController.text.isNotEmpty) {
                                      Navigator.of(context).pop(_store);
                                    } else {
                                      Navigator.of(context).pop();
                                    }
                                    Flushbar(
                                      flushbarPosition: FlushbarPosition.TOP,
                                      message: 'Added \"$_store\"',
                                      duration: Duration(seconds: 2),
                                      margin: EdgeInsets.all(8),
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    )..show(context);
                                  } catch (e, s) {
                                    await FirebaseCrashlytics.instance.log(
                                        'Add button pressed in add store modal bottom sheet');
                                    await FirebaseCrashlytics.instance.recordError(
                                        e, s,
                                        reason:
                                            'Add button pressed in add store modal bottom sheet');
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return ErrorAlert(
                                              errorMessage: e.toString());
                                        });
                                  }
                                }
                              });
                  },
                ),
              ],
            );
          }
          throw FallThroughError();
        }),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
      ),
    );
  }
}
