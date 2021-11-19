import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:another_flushbar/flushbar.dart';

import 'package:provider/provider.dart';

import 'package:beyya/Models/InvitationPendingResponse.dart';
import 'package:beyya/Models/SignedInUser.dart';
import 'package:beyya/Models/UserDocument.dart';

import 'package:beyya/Screens/InviteeList.dart';
import 'package:beyya/Screens/PendingInvitation.dart';
import 'package:beyya/Screens/SharingStatus.dart';
import 'package:beyya/Screens/StoppedSharingNotification.dart';

import 'package:beyya/Screens/SendInvite.dart';

class Share extends StatefulWidget {
  @override
  _ShareState createState() => _ShareState();
}

class _ShareState extends State<Share> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Container(
          alignment: Alignment.centerLeft,
          child: Text('Share'),
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
                  .log('Error loading data for Share route: $err');
              return Center(
                child: Text('Oops! Something went wrong. Please restart the app and try again.'),
              );
            } else if (data is UserData) {
              if (data.removedByInviter != null) {
                return StoppedSharingNotification(
                  inviter: data.removedByInviter,
                  inviteeDocId: data.docId,
                );
              } else if (Provider.of<InvitationPendingResponse>(context)
                          .emailOfInviter !=
                      null &&
                  data.inviteesWhoJoined.isEmpty &&
                  data.inviteesYetToRespond.isEmpty &&
                  Provider.of<SignedInUser>(context).userEmail ==
                      data.ownerOfListInUse) {
                final inviterEmail =
                    Provider.of<InvitationPendingResponse>(context)
                        .emailOfInviter;
                final inviterDocId =
                    Provider.of<InvitationPendingResponse>(context)
                        .docIdOfInviter;
                return PendingInvitation(
                  inviter: inviterEmail,
                  inviterDocId: inviterDocId,
                  invitee: data.owner,
                  inviteeDocId: data.docId,
                );
              } else if (Provider.of<SignedInUser>(context).userEmail !=
                  data.ownerOfListInUse) {
                return SharingStatus(
                  invitee: Provider.of<SignedInUser>(context).userEmail,
                  inviteeDocId: Provider.of<SignedInUser>(context).uid,
                  inviter: data.ownerOfListInUse,
                  inviterDocId: data.docIdOfListInUse,
                );
              } else {
                final docIdOfListInUse = data.docIdOfListInUse;
                final ownerOfListInUse = data.ownerOfListInUse;
                final List<String> inviteesYetToRespond =
                    List.from(data.inviteesYetToRespond);
                final Map uidsOfInviteesWhoJoined =
                    Map.from(data.uidsOfInviteesWhoJoined);
                final List<String> inviteesWhoJoined =
                    List.from(data.inviteesWhoJoined);
                final List<String> inviteesWhoDeclined =
                    List.from(data.inviteesWhoDeclined);
                final List<String> inviteesWhoLeft =
                    List.from(data.inviteesWhoLeft);
                inviteesYetToRespond
                    .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                inviteesWhoJoined
                    .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                inviteesWhoDeclined
                    .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                inviteesWhoLeft
                    .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                return InviteeList(
                  inviteesWhoJoined: inviteesWhoJoined,
                  uidsOfInviteesWhoJoined: uidsOfInviteesWhoJoined,
                  inviteesYetToRespond: inviteesYetToRespond,
                  inviteesWhoDeclined: inviteesWhoDeclined,
                  inviteesWhoLeft: inviteesWhoLeft,
                  docIdOfListInUse: docIdOfListInUse,
                  ownerOfListInUse: ownerOfListInUse,
                );
              }
            }
            throw FallThroughError();
          },
        ),
      ),
      floatingActionButton: Consumer<UserDocument>(
        builder: (_, data, __) {
          if (data is UserData &&
              Provider.of<SignedInUser>(context).userEmail ==
                  data.ownerOfListInUse && data.ownerOfListInUse!='anonymousUser'&&
              data.removedByInviter == null &&
              (data.inviteesYetToRespond.isNotEmpty ||
                  data.inviteesWhoJoined.isNotEmpty ||
                  Provider.of<InvitationPendingResponse>(context)
                          .emailOfInviter ==
                      null)) {
            bool _numOfInviteesLimitReached;
            if (data.inviteesWhoJoined.length +
                    data.inviteesYetToRespond.length >=
                6) {
              _numOfInviteesLimitReached = true;
            } else {
              _numOfInviteesLimitReached = false;
            }
            return FloatingActionButton.extended(
              icon: Icon(Icons.person_add),
              label: Text('Invite'),
              onPressed: () {
                if (_numOfInviteesLimitReached) {
                  Flushbar(
                    flushbarPosition: FlushbarPosition.TOP,
                    message:
                        'You can share with your list with 5 people at a time. To make room for new users, remove less active users.',
                    duration: Duration(seconds: 6),
                    margin: EdgeInsets.all(8),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  )..show(context);
                } else {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) =>
                          SingleChildScrollView(child: SendInvite()));
                }
              },
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
