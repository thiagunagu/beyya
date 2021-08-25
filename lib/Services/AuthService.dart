import 'package:firebase_auth/firebase_auth.dart';

import 'package:beyya/Models/SignedInUser.dart';

import 'package:beyya/Services/DatabaseServices.dart';


class AuthService {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  // SharedPreferences _pref;
  // bool _convertedUser;
  //
  // _initPrefs() async {
  //   if(_pref == null)
  //     _pref  = await SharedPreferences.getInstance();
  // }
  //
  // _saveToPrefs() async {
  //   await _initPrefs();
  //   _pref.setBool('UserType', _convertedUser);
  // }
  //
  // setConvertedUserToFalse(){
  //   _convertedUser=false;
  //   _saveToPrefs();
  // }

  //Get a stream of firebase user objects, map it to "SignedInUser" objects
  Stream<SignedInUser> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  //Mapping function for the stream above
  SignedInUser _userFromFirebaseUser(user) {
    // return user != null
    //     ? SignedInUser(userEmail: user.email, uid: user.uid)
    //     : null;

    if(user!=null){
      return user.isAnonymous? SignedInUser(userEmail: 'anonymousUser', uid: user.uid):SignedInUser(userEmail: user.email, uid: user.uid);
    }
    else{
      return null;
    }
  }

  Future registerAccountWithEmail({String email, String password}) async {
    UserCredential signUpresult = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await DatabaseService(
            dbOwner: signUpresult.user.email, dbDocId: signUpresult.user.uid)
        .createUserDocumentWhileSigningUp();
  }
  Future convertAnonymousUser({String email, String password}) async {
    final currentUser=_auth.currentUser;
    final credential=EmailAuthProvider.credential(email: email, password: password);
    await currentUser.linkWithCredential(credential);
    await DatabaseService(dbDocId: currentUser.uid).addUserEmail(email: email);
    await _auth.signOut();
    await _auth.signInWithCredential(credential);
  }
  Future signInWithEmail({String email, String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future signInAnon()async{
    UserCredential signupResult=await  _auth.signInAnonymously();
    await DatabaseService(
        dbOwner: 'anonymousUser', dbDocId: signupResult.user.uid)
        .createUserDocumentWhileSigningUp();
    //setConvertedUserToFalse();
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
