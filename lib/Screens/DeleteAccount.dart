import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:provider/provider.dart';

import 'package:beyya/CustomWidgets/ErrorAlert.dart';
import 'package:beyya/CustomWidgets/StatusAlert.dart';

import 'package:beyya/Models/SignedInUser.dart';
import 'package:beyya/Models/UserDocument.dart';

import 'package:beyya/Services/AuthService.dart';
import 'package:beyya/Services/DatabaseServices.dart';

class DeleteAccount extends StatelessWidget {
  final TextEditingController _currentPassword = TextEditingController();
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final String _user =
        Provider.of<SignedInUser>(context, listen: false).userEmail;
    final String _userDocId =
        Provider.of<SignedInUser>(context, listen: false).uid;

    final ButtonStyle styleRed = ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 14, color: Colors.white),
        elevation: 4.0,
        primary: Colors.red[500],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.red)));

    return Scaffold(
      appBar:AppBar(
  brightness: Brightness.dark,

        title: Container(
          alignment: Alignment.centerLeft,
          child: Text('Delete account'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    obscureText: true,
                    controller: _currentPassword,
                    decoration: const InputDecoration(
                      labelText: 'Current password',
                    ),
                  ),
                ),
                Consumer<UserDocument>(builder: (_, data, __) {
                  return ElevatedButton(
                    style: styleRed,
                    onPressed: () async {
                      try {
                        if (data is UserData &&
                            _userDocId == data.docIdOfListInUse) {
                          await showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                Future.delayed(Duration(seconds: 4), () {
                                  Navigator.of(context).pop(true);
                                });
                                return StatusAlert(
                                  statusMessage:
                                      'Thanks for trying Beyya. Deleting your account and data... ',
                                );
                              });
                          final DatabaseService _inviterDb =
                              DatabaseService(dbDocId: data.docIdOfListInUse);
                          data.inviteesWhoJoined
                              .forEach((inviteeWhoJoined) async {
                            String uidOfInviteeWhoJoined = data.uidsOfInviteesWhoJoined[_inviterDb.encodeAsFirebaseKey(text:inviteeWhoJoined)];
                            await DatabaseService(dbDocId: uidOfInviteeWhoJoined)
                                .setRemovedByInviter(
                                inviter: _user);
                            await DatabaseService(dbDocId: uidOfInviteeWhoJoined)
                                .setListInUse(
                                    ownerOfListInUse: inviteeWhoJoined,
                                    docIdOfListInUse: uidOfInviteeWhoJoined);
                          });
                          await _inviterDb.deleteUserDocument();
                          await _auth.signInWithEmail(
                              email: _user,
                              password: _currentPassword.text.trim());
                          await _auth.deleteAccount();
                        } else if (data is UserData &&
                            _userDocId != data.docIdOfListInUse) {
                          await showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                Future.delayed(Duration(seconds: 4), () {
                                  Navigator.of(context).pop(true);
                                });
                                return StatusAlert(
                                  statusMessage:
                                      'Thanks for trying Beyya. Deleting your account and data... ',
                                );
                              });
                          final _inviteeDb = DatabaseService(
                              dbOwner: _user, dbDocId: _userDocId);
                          final DatabaseService _inviterDb =
                              DatabaseService(dbDocId: data.docIdOfListInUse);

                          await _inviterDb.addToInviteesWhoLeft(
                              invitee:
                                  _user); //: add user to inviter's inviteesWhoLeft list
                          await _inviterDb.removeFromInviteesWhoJoined(
                              invitee: _user);
                          await _inviteeDb.deleteUserDocument();
                          await _auth.signInWithEmail(
                              email: _user,
                              password: _currentPassword.text.trim());
                          await _auth.deleteAccount();
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ErrorAlert(
                                    errorMessage:
                                        'Something went wrong. Please try again, or write to us at teambeyya@gmail.com');
                              });
                        }
                      } catch (e, s) {
                        await FirebaseCrashlytics.instance
                            .log('Delete account button pressed');
                        await FirebaseCrashlytics.instance.recordError(e, s,
                            reason: 'Delete account button pressed');
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ErrorAlert(errorMessage: e.toString());
                            });
                      }
                    },
                    child: Text(
                      "Confirm delete",
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
