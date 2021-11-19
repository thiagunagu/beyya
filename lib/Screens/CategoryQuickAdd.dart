import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:another_flushbar/flushbar.dart';

import 'package:provider/provider.dart';

import 'package:beyya/CustomWidgets/ErrorAlert.dart';

import 'package:beyya/Models/ListInUse.dart';
import 'package:beyya/Models/UserDocument.dart';

import 'package:beyya/Services/DatabaseServices.dart';

class CategoryQuickAdd extends StatefulWidget {
  @override
  _CategoryQuickAddState createState() => _CategoryQuickAddState();
}

class _CategoryQuickAddState extends State<CategoryQuickAdd> {
  TextEditingController _categoryController = TextEditingController();
  final _categoryQuickAddKey = GlobalKey<FormState>();
  bool _nullOrInvalidCategory = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _categoryQuickAddKey,
      child: AlertDialog(
        content: Consumer<ListInUse>(builder: (_, data, __) {
          if (data is LoadingListInUse) {
            return const CircularProgressIndicator();
          } else if (data is ErrorFetchingListInUSe) {
            String err = data.err;
            FirebaseCrashlytics.instance.log(
                'Error fetching list in use for quick add category route: $err');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Oops! Something went wrong. Please restart the app and try again.'),
              ),
            );
          } else if (data is ListInUseId) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    autofocus: true,
                    controller: _categoryController,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (text) {
                      if (text == null ||
                          text.isEmpty) {
                        setState(() {
                          _nullOrInvalidCategory = true;
                        });
                        return null;
                      } else {
                        setState(() {
                          _nullOrInvalidCategory = false;
                        });
                        return null;
                      }
                    },
                    decoration: InputDecoration.collapsed(
                      hintText: 'Add category',
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
                        onPressed: _nullOrInvalidCategory
                            ? null
                            : () async {
                                if (userDocumentData is UserData &&
                                    userDocumentData.categories.length >= 20) {
                                  Flushbar(
                                    flushbarPosition: FlushbarPosition.TOP,
                                    message:
                                        'You have already reached the maximum number of categories allowed. Delete some unused categories to make room for new ones.',
                                    duration: Duration(seconds: 6),
                                    margin: EdgeInsets.all(8),
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  )..show(context);
                                } else {
                                  try {
                                    await DatabaseService(
                                            dbDocId: data.docIdOfListInUse)
                                        .addCategory(
                                            category: _categoryController.text);
                                    final String _category =
                                        _categoryController.text;
                                    if (_categoryController.text.isNotEmpty) {
                                      Navigator.of(context).pop(_category);
                                    } else {
                                      Navigator.of(context).pop();
                                    }

                                    Flushbar(
                                      flushbarPosition: FlushbarPosition.TOP,
                                      message: 'Added \"$_category\"',
                                      duration: Duration(seconds: 2),
                                      margin: EdgeInsets.all(8),
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    )..show(context);
                                  } catch (e, s) {
                                    await FirebaseCrashlytics.instance.log(
                                        'Add button pressed in quick add category route');
                                    await FirebaseCrashlytics.instance.recordError(
                                        e, s,
                                        reason:
                                            'Add button pressed in quick add category route');
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
