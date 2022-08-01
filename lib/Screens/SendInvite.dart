import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:another_flushbar/flushbar.dart';

import 'package:provider/provider.dart';

import 'package:beyya/CustomWidgets/ErrorAlert.dart';

import 'package:beyya/Models/SignedInUser.dart';

import 'package:beyya/Services/DatabaseServices.dart';

class SendInvite extends StatefulWidget {
  @override
  _SendInviteState createState() => _SendInviteState();
}

class _SendInviteState extends State<SendInvite> {
  TextEditingController _inviteeEmailController = TextEditingController();
  final _sendInviteKey = GlobalKey<FormState>();
  static RegExp _validEmail = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 14, color: Colors.white),
        elevation: 4.0,
        primary: Colors.red[500],
        shape: StadiumBorder());
    final _inviterDb = DatabaseService(
        dbDocId: Provider.of<SignedInUser>(context, listen: false).uid);
    return Form(
      key: _sendInviteKey,
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
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  controller: _inviteeEmailController,
                  validator: (value) {
                    if (!_validEmail.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  decoration: InputDecoration.collapsed(
                    hintText: 'Enter email',
                  ),
                ),
              ),
              IconButton(
                  icon: Icon(
                    Icons.person_add,
                    size: 30,
                  ),
                  color: Colors.red[500],
                  onPressed: () async {
                    try {
                      if (_sendInviteKey.currentState.validate()) {
                        await _inviterDb.addToInviteesYetToRespond(
                            invitee: _inviteeEmailController.text.toLowerCase());
                        final String _inviteeEmail =
                            _inviteeEmailController.text.toLowerCase();
                        Flushbar(
                          flushbarPosition: FlushbarPosition.TOP,
                          message:
                              'Invite sent\. Ask $_inviteeEmail to login to Beyya to see your invite.',
                          margin: EdgeInsets.all(8),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          mainButton: TextButton(
                            child: Text('Ok'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        )..show(context);

                        _inviteeEmailController.text = '';
                      }
                    } catch (e, s) {
                      await FirebaseCrashlytics.instance.log(
                          'Invite button pressed in invite modal bottom sheet');
                      await FirebaseCrashlytics.instance.recordError(e, s,
                          reason:
                              'Invite button pressed in invite modal bottom sheet');
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ErrorAlert(errorMessage: e.toString());
                          });
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
