import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:provider/provider.dart';

import 'package:beyya/CustomWidgets/ErrorAlert.dart';

import 'package:beyya/Models/InvitationPendingResponse.dart';
import 'package:beyya/Models/SignedInUser.dart';
import 'package:beyya/Models/UserDocument.dart';

import 'package:beyya/Services/DatabaseServices.dart';

class Alert extends StatefulWidget {
  @override
  _AlertState createState() => _AlertState();
}

class _AlertState extends State<Alert> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.centerLeft,
          child: Text('Alert'),
        ),
      ),
      body: SafeArea(
        child: Consumer<UserDocument>(
          builder: (_, data, __) {
            if (data is LoadingUserDocument) {
              return CircularProgressIndicator();
            } else if (data is ErrorFetchingUserDocument) {
              String err = data.err;
              FirebaseCrashlytics.instance
                  .log('Error loading data for Alert route: $err');
              return Center(
                child: Text('Oops! Something went wrong. Please restart the app and try again.'),
              );
            } else if (data is UserData) {
              String secondInviter =
                  Provider.of<InvitationPendingResponse>(context).emailOfInviter;
              String secondInviterDocId =
                  Provider.of<InvitationPendingResponse>(context).docIdOfInviter;
              String firstInviter = data.ownerOfListInUse;
              String invitee = Provider.of<SignedInUser>(context).userEmail;
              final _inviterDb = DatabaseService(
                  dbOwner: secondInviter, dbDocId: secondInviterDocId);
              return Center(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        invitee != data.ownerOfListInUse
                            ? Text(
                                '$secondInviter invited you to join their shopping list, but you will have to leave $firstInviter\'s list before you accept this invite.',
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.grey[700]),
                              )
                            : Text(
                                '$secondInviter invited you to join their shopping list, but you will have to remove existing users, and open invitations before you accept this invite',
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.grey[700]),
                              ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.yellow[900])),
                                textColor: Colors.white,
                                color: Colors.yellow[900],
                                child: Text('Decide later'),
                                elevation: 4.0,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.red)),
                                textColor: Colors.white,
                                color: Colors.red[500],
                                child: Text('Decline'),
                                elevation: 4.0,
                                onPressed: () async {
                                  try {
                                    Navigator.pop(context);
                                    await _inviterDb.addToInviteesWhoDeclined(
                                        invitee: invitee);
                                    await _inviterDb
                                        .removeFromInviteesYetToRespond(
                                            invitee: invitee);
                                  } catch (e, s) {
                                    await FirebaseCrashlytics.instance
                                        .log('Decline pressed in Alert route');
                                    await FirebaseCrashlytics.instance
                                        .recordError(e, s,
                                            reason:
                                                'Decline pressed in Alert route');
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return ErrorAlert(
                                              errorMessage: e.toString());
                                        });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            throw FallThroughError();
          },
        ),
      ),
    );
  }
}
