import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:beyya/CustomWidgets/ErrorAlert.dart';

import 'package:beyya/Services/DatabaseServices.dart';

class PendingInvitation extends StatelessWidget {
  const PendingInvitation({
    Key key,
    @required this.inviter,
    @required this.inviterDocId,
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
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text(
                  '$inviter invited you to join their shopping list',
                  style: TextStyle(fontSize: 20.0, color: Colors.grey[700]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.green[400])),
                      textColor: Colors.white,
                      color: Colors.green[400],
                      child: Text('Join'),
                      elevation: 4.0,
                      onPressed: () async {
                        try {
                          await _inviterDb.addToInviteesWhoJoined(
                              invitee: invitee, inviteeUid: inviteeDocId);
                          await _inviteeDb.setListInUse(
                              ownerOfListInUse: inviter, docIdOfListInUse: inviterDocId);
                          await _inviterDb.removeFromInviteesYetToRespond(
                              invitee: invitee);
                        } catch (e, s) {
                          await FirebaseCrashlytics.instance
                              .log('Join pressed in pending invitation');
                          await FirebaseCrashlytics.instance.recordError(e, s,
                              reason: 'Join pressed in pending invitation');
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ErrorAlert(errorMessage: e.toString());
                              });
                        }
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
                        try{
                        Navigator.pop(context);
                        await _inviterDb.addToInviteesWhoDeclined(invitee: invitee);
                        await _inviterDb.removeFromInviteesYetToRespond(
                            invitee: invitee);}
                        catch (e, s) {
                          await FirebaseCrashlytics.instance
                              .log('Decline pressed in pending invitation');
                          await FirebaseCrashlytics.instance.recordError(e, s,
                              reason: 'Decline pressed in pending invitation');
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
            ],
          ),
        ),
      ),
    );
  }
}
