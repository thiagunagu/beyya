import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:flushbar/flushbar.dart';

import 'package:provider/provider.dart';

import 'package:beyya/CustomWidgets/ErrorAlert.dart';

import 'package:beyya/Models/ListInUse.dart';
import 'package:beyya/Models/UserDocument.dart';

import 'package:beyya/Services/DatabaseServices.dart';

class AddStore extends StatefulWidget {
  @override
  _AddStoreState createState() => _AddStoreState();
}

class _AddStoreState extends State<AddStore> {
  TextEditingController _storeController = TextEditingController();
  bool _nullOrInvalidStore=true;
  final _addStoreKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _addStoreKey,
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
          child: Consumer<ListInUse>(builder: (_, data, __) {
            if (data is LoadingListInUse) {
              return const CircularProgressIndicator();
            } else if (data is ErrorFetchingListInUSe) {
              String err = data.err;
              FirebaseCrashlytics.instance
                  .log('Error loading data for Add store route: $err');
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Oops! Something went wrong. Please restart the app and try again.'),
                ),
              );
            } else if (data is ListInUseId) {
              return Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      controller: _storeController,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (text) {
                        if (text == null ||
                            text.isEmpty) {
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
                                      userDocumentData.stores.length >= 20) {
                                    Flushbar(
                                      flushbarPosition: FlushbarPosition.TOP,
                                      message:
                                          'You have already reached the maximum number of stores allowed. Delete some unused stores to make room for new ones.',
                                      duration: Duration(seconds: 6),
                                      margin: EdgeInsets.all(8),
                                      borderRadius: 10,
                                    )..show(context);
                                  } else {
                                    try {
                                      await DatabaseService(
                                              dbDocId: data.docIdOfListInUse)
                                          .addStore(
                                              store: _storeController.text);
                                      final String _store =
                                          _storeController.text;
                                      Flushbar(
                                        flushbarPosition: FlushbarPosition.TOP,
                                        message: 'Added \"$_store\"',
                                        duration: Duration(seconds: 2),
                                        margin: EdgeInsets.all(8),
                                        borderRadius: 10,
                                      )..show(context);
                                      _storeController.text = '';
                                      setState(() {
                                        _nullOrInvalidStore = true;
                                      });
                                    } catch (e, s) {
                                      await FirebaseCrashlytics.instance.log(
                                          'Add button pressed in add store route');
                                      await FirebaseCrashlytics.instance
                                          .recordError(e, s,
                                              reason:
                                                  'Add button pressed in add store route');
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
        ),
      ),
    );
  }
}
