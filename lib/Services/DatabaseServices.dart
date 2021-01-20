import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:beyya/Models/InvitationPendingResponse.dart';
import 'package:beyya/Models/Item.dart';
import 'package:beyya/Models/ListInUse.dart';
import 'package:beyya/Models/UserDocument.dart';

class DatabaseService {
  final String dbOwner;
  final String dbDocId;
  DatabaseService({this.dbOwner, this.dbDocId});

  static CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('beyya');

  //create a firestore doc with example data when the user creates an account
  Future createUserDocumentWhileSigningUp() async {
    return await collectionReference.doc(dbDocId).set(
      {
        'owner': dbOwner,
        'docId': dbDocId,
        'ownerOfListInUse': dbOwner,
        'docIdOfListInUse': dbDocId,
        'removedByInviter': null,
        'inviteesWhoJoined': [],
        'uidsOfInviteesWhoJoined': {},
        'inviteesYetToRespond': [],
        'inviteesWhoDeclined': [],
        'inviteesWhoLeft': [],
        'categories': [
          'Dairy',
          'Produce',
          'Household',
          'Misc'
        ],
        'stores': [
          "Farmer's market",
          'SuperMart',
          'Wholesale club',
          'Other'
        ],
        'items': {
          "TomatoesProduceFarmer's%20market": {
            'item': 'Tomatoes',
            'category': 'Produce',
            'store': "Farmer's market",
            'star': true,
          },
          "OnionProduceFarmer's%20market": {
            'item': 'Onion',
            'category': 'Produce',
            'store': "Farmer's market",
            'star': false,
          },
          "AvocadosProduceFarmer's%20market": {
            'item': 'Avocados',
            'category': 'Produce',
            'store': "Farmer's market",
            'star': true,
          },
          'Hand%20SoapHouseholdWholesale%20club': {
            'item': 'Hand Soap',
            'category': 'Household',
            'store': 'Wholesale club',
            'star': false,
          },
          'MilkDairySuperMart': {
            'item': 'Milk',
            'category': 'Dairy',
            'store': 'SuperMart',
            'star': true,
          },
          'YogurtDairySuperMart': {
            'item': 'Yogurt',
            'category': 'Dairy',
            'store': 'SuperMart',
            'star': false,
          }
        },
      },
    );
  }

  //get stream of document snapshots and map it to "UserDocument" objects
  Stream<UserDocument> get userDocument {
    return collectionReference
        .doc(dbDocId)
        .snapshots()
        .map(_userDocumentFromSnapshot);
  }

  UserDocument _userDocumentFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
        docId: snapshot.data()['docId'],
        owner: snapshot.data()['owner'],
        docIdOfListInUse: snapshot.data()['docIdOfListInUse'],
        ownerOfListInUse: snapshot.data()['ownerOfListInUse'],
        removedByInviter: snapshot.data()['removedByInviter'],
        categories: snapshot
            .data()['categories']
            .cast<String>()
            .map<String>((category) {
          return decodeFirebaseKey(text: category);
        }).toList(),
        stores: snapshot.data()['stores'].cast<String>().map<String>((store) {
          return decodeFirebaseKey(text: store);
        }).toList(),
        inviteesWhoJoined: snapshot.data()['inviteesWhoJoined'].cast<String>(),
        uidsOfInviteesWhoJoined: snapshot.data()['uidsOfInviteesWhoJoined'],
        inviteesWhoDeclined:
            snapshot.data()['inviteesWhoDeclined'].cast<String>(),
        inviteesYetToRespond:
            snapshot.data()['inviteesYetToRespond'].cast<String>(),
        inviteesWhoLeft: snapshot.data()['inviteesWhoLeft'].cast<String>(),
        items: snapshot.data()['items'].values.map<Item>((itemDetail) {
          return Item(
              item: decodeFirebaseKey(text: itemDetail['item']),
              store: decodeFirebaseKey(text: itemDetail['store']),
              category: decodeFirebaseKey(text: itemDetail['category']),
              star: itemDetail['star']);
        }).toList());
  }

  //Get a stream of invitations pending user response
  Stream<InvitationPendingResponse> get invitationPendingResponse {
    return collectionReference
        .where('inviteesYetToRespond', arrayContains: dbOwner)
        .snapshots()
        .map(_invitationPendingResponse);
  }

  InvitationPendingResponse _invitationPendingResponse(QuerySnapshot snapshot) {
    return InvitationPendingResponse(
        emailOfInviter: snapshot.docs[0].data()['owner'],
        docIdOfInviter: snapshot.docs[0].data()['docId']);
  }

  //this stream provides the id of the list in use - will be same as the
  // signed in user's list if he/she hasn't joined any shared list
  Stream<ListInUse> get idOfListInUse {
    return collectionReference
        .doc(dbDocId)
        .snapshots()
        .map(_idOfListInUseFromSnapshot);
  }

  ListInUse _idOfListInUseFromSnapshot(DocumentSnapshot snapshot) {
    return ListInUseId(
        ownerOfListInUse: snapshot.data()['ownerOfListInUse'],
        docIdOfListInUse: snapshot.data()['docIdOfListInUse']);
  }

  Future addItem({
    String item, //avocado, tomato, etc.
    String store, //WalMart, CostCo
    String category, //Produce, Dairy
    bool star, // starred items will show up in the "To buy" tab
  }) async {
    String encodedItem = encodeAsFirebaseKey(text: item);
    String encodedCategory = encodeAsFirebaseKey(text: category);
    String encodedStore = encodeAsFirebaseKey(text: store);
    await collectionReference.doc(dbDocId).set(
      {
        'items': {
          encodedItem + encodedCategory + encodedStore: {
            'item': encodedItem,
            'category': encodedCategory,
            'store': encodedStore,
            'star': star,
          }
        }
      },
      SetOptions(merge: true),
    );
  }

  Future deleteItem({String id}) async {
    await collectionReference
        .doc(dbDocId)
        .update({'items.$id': FieldValue.delete()}); //delete item
  }

  //edit details of an item =>first deletes the item, and adds the revised
  //version as a new item
  Future editItem({
    String item,
    String store,
    String category,
    bool star,
    String id,
  }) async {
    await deleteItem(id: id);
    await addItem(
      item: item,
      store: store,
      category: category,
      star: star,
    );
  }

  Future toggleStar({bool star, String id}) async {
    await collectionReference.doc(dbDocId).update({'items.$id.star': !star});
  }

  Future addCategory({String category}) async {
    String encodedCategory = encodeAsFirebaseKey(text: category);
    await collectionReference.doc(dbDocId).update({
      'categories': FieldValue.arrayUnion([encodedCategory])
    });
  }

  Future deleteCategory({String category}) async {
    String encodedCategory = encodeAsFirebaseKey(text: category);
    await collectionReference.doc(dbDocId).update({
      'categories': FieldValue.arrayRemove([encodedCategory])
    });
  }

  Future addStore({String store}) async {
    String encodedStore = encodeAsFirebaseKey(text: store);
    await collectionReference.doc(dbDocId).update({
      'stores': FieldValue.arrayUnion([encodedStore])
    });
  }

  Future deleteStore({String store}) async {
    String encodedStore = encodeAsFirebaseKey(text: store);
    await collectionReference.doc(dbDocId).update({
      'stores': FieldValue.arrayRemove([encodedStore])
    });
  }

  Future setListInUse(
      {String ownerOfListInUse, String docIdOfListInUse}) async {
    await collectionReference.doc(dbDocId).update(
      {
        'ownerOfListInUse': ownerOfListInUse,
        'docIdOfListInUse': docIdOfListInUse
      },
    );
  }

  Future setRemovedByInviter({String inviter}) async {
    await collectionReference.doc(dbDocId).update(
      {
        'removedByInviter': inviter,
      },
    );
  }

  Future addToInviteesYetToRespond({String invitee}) async {
    await collectionReference.doc(dbDocId).update({
      'inviteesYetToRespond': FieldValue.arrayUnion([invitee])
    });
  }

  Future removeFromInviteesYetToRespond({String invitee}) async {
    await collectionReference.doc(dbDocId).update({
      'inviteesYetToRespond': FieldValue.arrayRemove([invitee])
    });
  }

  Future addToInviteesWhoJoined({String invitee, String inviteeUid}) async {
    await collectionReference.doc(dbDocId).update({
      'inviteesWhoJoined': FieldValue.arrayUnion(
        [invitee],
      )
    });
    String encodedInvitee = encodeAsFirebaseKey(text: invitee);
    await collectionReference.doc(dbDocId).set(
      {
        'uidsOfInviteesWhoJoined': {encodedInvitee: inviteeUid}
      },
      SetOptions(merge: true),
    );
  }

  Future removeFromInviteesWhoJoined({String invitee}) async {
    String encodedInvitee = encodeAsFirebaseKey(text: invitee);
    await collectionReference.doc(dbDocId).update({
      'uidsOfInviteesWhoJoined.$encodedInvitee': FieldValue.delete(),
      'inviteesWhoJoined': FieldValue.arrayRemove([invitee])
    });
  }

  String encodeAsFirebaseKey({String text}) {
    return Uri.encodeComponent(text)
        .replaceAll('.', '%2E')
        .replaceAll('*', '%2A');
  }

  String decodeFirebaseKey({String text}) {
    return Uri.decodeComponent(text);
  }

  Future addToInviteesWhoDeclined({String invitee}) async {
    await collectionReference.doc(dbDocId).update({
      'inviteesWhoDeclined': FieldValue.arrayUnion([invitee])
    });
  }

  Future removeFromInviteesWhoDeclined({String invitee}) async {
    await collectionReference.doc(dbDocId).update({
      'inviteesWhoDeclined': FieldValue.arrayRemove([invitee])
    });
  }

  Future addToInviteesWhoLeft({String invitee}) async {
    await collectionReference.doc(dbDocId).update({
      'inviteesWhoLeft': FieldValue.arrayUnion([invitee])
    });
  }

  Future removeFromInviteesWhoLeft({String invitee}) async {
    await collectionReference.doc(dbDocId).update({
      'inviteesWhoLeft': FieldValue.arrayRemove([invitee])
    });
  }

  Future deleteUserDocument() async {
    await collectionReference.doc(dbDocId).delete();
  }
}
