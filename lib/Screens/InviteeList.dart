import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:beyya/CustomWidgets/ErrorAlert.dart';
import 'package:beyya/CustomWidgets/SwipeLeftBackground.dart';
import 'package:beyya/CustomWidgets/SwipeRightBackground.dart';

import 'package:beyya/Screens/SendInvite.dart';

import 'package:beyya/Services/DatabaseServices.dart';

class InviteeList extends StatelessWidget {
  const InviteeList({
    Key key,
    @required this.inviteesWhoJoined,
    @required this.uidsOfInviteesWhoJoined,
    @required this.inviteesYetToRespond,
    @required this.inviteesWhoDeclined,
    @required this.inviteesWhoLeft,
    @required this.docIdOfListInUse,
    @required this.ownerOfListInUse,
  }) : super(key: key);

  final List<String> inviteesWhoJoined;
  final Map uidsOfInviteesWhoJoined;
  final List<String> inviteesYetToRespond;
  final List<String> inviteesWhoDeclined;
  final List<String> inviteesWhoLeft;
  final String docIdOfListInUse;
  final String ownerOfListInUse;

  @override
  Widget build(BuildContext context) {
    final DatabaseService _db =
        DatabaseService(dbDocId: docIdOfListInUse, dbOwner: ownerOfListInUse);
    if (inviteesWhoJoined.isNotEmpty ||
        inviteesYetToRespond.isNotEmpty ||
        inviteesWhoLeft.isNotEmpty ||
        inviteesWhoDeclined.isNotEmpty) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListView.builder(
              itemCount: inviteesWhoJoined.length,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, inviteesWhoJoinedIndex) {
                return Dismissible(
                  key: ObjectKey(inviteesWhoJoined[inviteesWhoJoinedIndex]),
                  child: Card(
                    child: ListTile(
                      title: Text(inviteesWhoJoined[inviteesWhoJoinedIndex]),
                      trailing: Text('joined',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                  onDismissed: (direction) async {
                    try {
                      String uidOfInviteeWhoJoined = uidsOfInviteesWhoJoined[
                          _db.encodeAsFirebaseKey(
                              text:
                                  inviteesWhoJoined[inviteesWhoJoinedIndex])];
                      await DatabaseService(dbDocId: uidOfInviteeWhoJoined)
                          .setRemovedByInviter(inviter: ownerOfListInUse);
                      await DatabaseService(dbDocId: uidOfInviteeWhoJoined)
                          .setListInUse(
                              ownerOfListInUse:
                                  inviteesWhoJoined[inviteesWhoJoinedIndex],
                              docIdOfListInUse: uidOfInviteeWhoJoined);
                      await _db.removeFromInviteesWhoJoined(
                          invitee: inviteesWhoJoined[inviteesWhoJoinedIndex]);
                    } catch (e, s) {
                      await FirebaseCrashlytics.instance
                          .log('Deleted one of the invitees who joined');
                      await FirebaseCrashlytics.instance.recordError(e, s,
                          reason: 'Deleted one of the invitees who joined');
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ErrorAlert(errorMessage: e.toString());
                          });
                    }
                  },
                  background: SwipeRightBackground(),
                  secondaryBackground: SwipeLeftBackground(),
                );
              },
            ),
            ListView.builder(
              itemCount: inviteesYetToRespond.length,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, inviteesYetToRespondIndex) {
                return Dismissible(
                  key: ObjectKey(
                      inviteesYetToRespond[inviteesYetToRespondIndex]),
                  child: Card(
                    child: ListTile(
                      title:
                          Text(inviteesYetToRespond[inviteesYetToRespondIndex]),
                      trailing: Text('invite sent',
                          style: TextStyle(
                              color: Colors.amber[700],
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                  onDismissed: (direction) async {
                    try {
                      await _db.removeFromInviteesYetToRespond(
                          invitee:
                              inviteesYetToRespond[inviteesYetToRespondIndex]);
                    } catch (e, s) {
                      await FirebaseCrashlytics.instance.log(
                          'Deleted one of the invitees who is yet to respond');
                      await FirebaseCrashlytics.instance.recordError(e, s,
                          reason:
                              'Deleted one of the invitees who is yet to respond');
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ErrorAlert(errorMessage: e.toString());
                          });
                    }
                  },
                  background: SwipeRightBackground(),
                  secondaryBackground: SwipeLeftBackground(),
                );
              },
            ),
            ListView.builder(
              itemCount: inviteesWhoDeclined.length,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, inviteesWhoDeclinedIndex) {
                return Dismissible(
                  key: ObjectKey(inviteesWhoDeclined[inviteesWhoDeclinedIndex]),
                  child: Card(
                    child: ListTile(
                      title:
                          Text(inviteesWhoDeclined[inviteesWhoDeclinedIndex]),
                      trailing: Text('declined',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  onDismissed: (direction) async {
                    try {
                      await _db.removeFromInviteesWhoDeclined(
                          invitee:
                              inviteesWhoDeclined[inviteesWhoDeclinedIndex]);
                    } catch (e, s) {
                      await FirebaseCrashlytics.instance
                          .log('Deleted one of the invitees who declined');
                      await FirebaseCrashlytics.instance.recordError(e, s,
                          reason: 'Deleted one of the invitees who declined');
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ErrorAlert(errorMessage: e.toString());
                          });
                    }
                  },
                  background: SwipeRightBackground(),
                  secondaryBackground: SwipeLeftBackground(),
                );
              },
            ),
            ListView.builder(
              itemCount: inviteesWhoLeft.length,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, inviteeWhoLeftIndex) {
                return Dismissible(
                  key: ObjectKey(inviteesWhoLeft[inviteeWhoLeftIndex]),
                  child: Card(
                    child: ListTile(
                      title: Text(inviteesWhoLeft[inviteeWhoLeftIndex]),
                      trailing: Text('left',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  onDismissed: (direction) async {
                    try {
                      await _db.removeFromInviteesWhoLeft(
                          invitee: inviteesWhoLeft[inviteeWhoLeftIndex]);
                    } catch (e, s) {
                      await FirebaseCrashlytics.instance
                          .log('Deleted one of the invitees who left');
                      await FirebaseCrashlytics.instance.recordError(e, s,
                          reason: 'Deleted one of the invitees who left');
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ErrorAlert(errorMessage: e.toString());
                          });
                    }
                  },
                  background: SwipeRightBackground(),
                  secondaryBackground: SwipeLeftBackground(),
                );
              },
            ),
          ],
        ),
      );
    }
    else{
      return GestureDetector(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/crayon-2086.png',
                  fit: BoxFit.scaleDown,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child:  Text(
                ownerOfListInUse=='anonymousUser'?'You have to create an account to share your list with someone. Tap to create an account.':
                    'Tap to invite someone to share your list.',
                    style: TextStyle(
                        color: Colors.grey[400], fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          ownerOfListInUse=='anonymousUser'?Navigator.popAndPushNamed(context, '/Register'):showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => SingleChildScrollView(child: SendInvite()),
          );
        },
      );
    }
  }
}
