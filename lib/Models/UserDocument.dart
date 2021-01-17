// Model to stream the entire user document or the shared document from firestore.

import 'package:beyya/Models/Item.dart';

abstract class UserDocument {}

class UserData implements UserDocument {
  final List<String> inviteesWhoJoined;
  final List<String> inviteesWhoDeclined;
  final List<String> inviteesWhoLeft;
  final List<String> inviteesYetToRespond;
  final Map uidsOfInviteesWhoJoined;

  final String docId;
  final String owner;

  final String docIdOfListInUse;
  final String ownerOfListInUse;

  final String removedByInviter;

  final List<String> categories;
  final List<String> stores;

  final List<Item> items;

  UserData({
    this.inviteesWhoJoined,
    this.uidsOfInviteesWhoJoined,
    this.inviteesWhoDeclined,
    this.inviteesYetToRespond,
    this.inviteesWhoLeft,
    this.docId,
    this.owner,
    this.docIdOfListInUse,
    this.ownerOfListInUse,
    this.removedByInviter,
    this.categories,
    this.stores,
    this.items,
  });
}

class ErrorFetchingUserDocument implements UserDocument {
  final String err;
  ErrorFetchingUserDocument({
    this.err,
  });
}

class LoadingUserDocument implements UserDocument {
  const LoadingUserDocument();
}
