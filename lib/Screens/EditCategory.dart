import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:flushbar/flushbar.dart';

import 'package:provider/provider.dart';

import 'package:beyya/CustomWidgets/ErrorAlert.dart';

import 'package:beyya/Models/Item.dart';
import 'package:beyya/Models/UserDocument.dart';

import 'package:beyya/Services/DatabaseServices.dart';

class EditCategory extends StatefulWidget {
  final String currentCategory;

  EditCategory({this.currentCategory});
  @override
  _EditCategoryState createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {
  String _changedCategory;
  TextEditingController _categoryController;
  bool _nullOrInvalidOrSameCategory = true;
  final _editCategoryKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _categoryController = TextEditingController(text: widget.currentCategory);
  }

  @override
  void dispose() {
    super.dispose();
    _categoryController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _editCategoryKey,
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
                    .log('Error loading data for Edit category route: $err');
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
                          controller:
                              _categoryController, //fill the text field with tapped category
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (text) {
                            if (text == null ||
                                text.isEmpty ||
                                text == widget.currentCategory) {
                              setState(() {
                                _nullOrInvalidOrSameCategory = true;
                              });
                              return null;
                            } else {
                              setState(() {
                                _nullOrInvalidOrSameCategory = false;
                                _changedCategory = text;
                              });
                              return null;
                            }
                          },
                          decoration: InputDecoration.collapsed()),
                    ),
                    IconButton(
                        iconSize: 24.0,
                        disabledColor: Colors.grey,
                        color: Colors.red[500],
                        icon: Icon(
                          Icons.save,
                        ),
                        onPressed: _nullOrInvalidOrSameCategory
                            ? null
                            : () async {
                                try {
                                  items.forEach((item) async {
                                    if (item.category ==
                                        widget.currentCategory) {
                                      String encodedItem=DatabaseService().encodeAsFirebaseKey(text: item.item);
                                      String encodedCategory=DatabaseService().encodeAsFirebaseKey(text: item.category);
                                      String encodedStore=DatabaseService().encodeAsFirebaseKey(text: item.store);
                                      //update all items tie to the current category
                                      await DatabaseService(
                                              dbDocId: data.docIdOfListInUse)
                                          .editItem(
                                              item: item.item,
                                              category: _changedCategory,
                                              store: item.store,
                                              star: item.star,
                                              id: encodedItem +
                                                  encodedCategory +
                                                  encodedStore);
                                    }
                                  });
                                  await DatabaseService(
                                          dbDocId: data.docIdOfListInUse)
                                      .deleteCategory(
                                          category: widget.currentCategory);
                                  await DatabaseService(
                                          dbDocId: data.docIdOfListInUse)
                                      .addCategory(category: _changedCategory);
                                  Navigator.pop(context);
                                  Flushbar(
                                    flushbarPosition: FlushbarPosition.TOP,
                                    message:
                                        'Updated \"$_changedCategory\"',
                                    duration: Duration(seconds: 2),
                                    margin: EdgeInsets.all(8),
                                    borderRadius: 10,
                                  )..show(context);
                                } catch (e, s) {
                                  await FirebaseCrashlytics.instance.log(
                                      'Save button pressed in edit category modal bottom sheet');
                                  await FirebaseCrashlytics.instance.recordError(
                                      e, s,
                                      reason:
                                          'Save button pressed in edit category modal bottom sheet');
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
