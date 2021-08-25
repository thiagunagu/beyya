import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:beyya/CustomWidgets/ErrorAlert.dart';

import 'package:beyya/Services/DatabaseServices.dart';

class SharingStatus extends StatelessWidget {
  const SharingStatus({
    Key key,
    this.inviter,
    this.inviterDocId,
    this.invitee,
    this.inviteeDocId,
  }) : super(key: key);

  final String inviter;
  final String inviterDocId;
  final String invitee;
  final String inviteeDocId;

  @override
  Widget build(BuildContext context) {
    final _inviteeDb = DatabaseService(dbOwner: invitee, dbDocId: inviteeDocId);
    final _inviterDb = DatabaseService(dbOwner: inviter, dbDocId: inviterDocId);
    final ButtonStyle styleRed = ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 14, color: Colors.white),
        elevation: 4.0,
        primary: Colors.red[500],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.red)));
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You are using $inviter \'s shopping list!',
                style: TextStyle(fontSize: 20.0, color: Colors.grey[700]),
              ),
              Container(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  //Leave the shared list
                  style: styleRed,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.exit_to_app),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Leave this list'),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    try {
                      await _inviterDb.addToInviteesWhoLeft(invitee: invitee);
                      await _inviterDb.removeFromInviteesWhoJoined(
                          invitee: invitee);
                      await _inviteeDb.setListInUse(
                          ownerOfListInUse: invitee,
                          docIdOfListInUse:
                              inviteeDocId); //delete the inviter from userEmail's ownerOfListInUse list so that the userEmail can start reading and writing from his/her own database
                    } catch (e, s) {
                      await FirebaseCrashlytics.instance
                          .log('Leave the list pressed');
                      await FirebaseCrashlytics.instance
                          .recordError(e, s, reason: 'Leave the list pressed');
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ErrorAlert(errorMessage: e.toString());
                          });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
