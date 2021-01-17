import 'package:firebase_auth/firebase_auth.dart';

import 'package:beyya/Models/SignedInUser.dart';

import 'package:beyya/Services/DatabaseServices.dart';

class AuthService {
  static FirebaseAuth _auth = FirebaseAuth.instance;

  //Get a stream of firebase user objects, map it to "SignedInUser" objects
  Stream<SignedInUser> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  //Mapping function for the stream above
  SignedInUser _userFromFirebaseUser(user) {
    return user != null
        ? SignedInUser(userEmail: user.email, uid: user.uid)
        : null;
  }

  Future registerAccountWithEmail({String email, String password}) async {
    UserCredential signUpresult = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await DatabaseService(
            dbOwner: signUpresult.user.email, dbDocId: signUpresult.user.uid)
        .createUserDocumentWhileSigningUp();
  }

  Future signInWithEmail({String email, String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future forgotPassword({String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> changePassword({String password}) async {
    await _auth.currentUser.updatePassword(password);
  }

  Future<void> deleteAccount() async {
    await _auth.currentUser.delete();
  }

  Future signOut() async {
    await _auth.signOut();
  }
}
