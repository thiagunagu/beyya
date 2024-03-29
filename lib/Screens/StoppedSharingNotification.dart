import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:beyya/CustomWidgets/ErrorAlert.dart';

import 'package:beyya/Services/DatabaseServices.dart';

class StoppedSharingNotification extends StatelessWidget {
  const StoppedSharingNotification({
    Key key,
    this.inviter,
    this.inviteeDocId,
  }) : super(key: key);

  final String inviter;
  final String inviteeDocId;

  @override
  Widget build(BuildContext context) {
    final _inviteeDb = DatabaseService(dbDocId: inviteeDocId);
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
                '$inviter stopped sharing their list with you!',
                style: TextStyle(fontSize: 20.0, color: Colors.grey[700]),
              ),
              Container(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  //Leave the shared list
                  style: styleRed,
                  child: Text('Okay'),
                  onPressed: () async {
                    try {
                      await _inviteeDb.setRemovedByInviter(inviter: null);
                    } catch (e, s) {
                      await FirebaseCrashlytics.instance
                          .log('Pressed okay in Stopped sharing notification');
                      await FirebaseCrashlytics.instance
                          .recordError(e, s, reason: 'Pressed okay in Stopped sharing notification');
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
