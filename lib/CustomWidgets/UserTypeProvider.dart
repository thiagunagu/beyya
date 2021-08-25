import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserTypeProvider extends ChangeNotifier {
  bool _convertedUser;
  SharedPreferences _pref;

  bool get convertedUser=>_convertedUser;
  UserTypeProvider(){
    _convertedUser=false;
    _loadFromPrefs();
  }
  setConvertedUserToTrue(){
    _convertedUser=true;
    _saveToPrefs();
    notifyListeners();
  }
  setConvertedUserToFalse(){
    _convertedUser=false;
    _saveToPrefs();
    //notifyListeners();
  }
  setConvertedUserToNull(){
    _convertedUser=null;
    _saveToPrefs();
    notifyListeners();
  }
  _initPrefs() async {
    if(_pref == null)
      _pref  = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();
    _convertedUser = _pref.getBool('UserType');
    notifyListeners();
  }
  _saveToPrefs() async {
    await _initPrefs();
    _pref.setBool('UserType', _convertedUser);
  }


  // Future<bool> getUserType() async {
  //   bool convertedUser;
  //   var prefs = await SharedPreferences.getInstance();
  //   bool isFirstTime = prefs.getBool('firstTime');
  //   convertedUser =
  //   (isFirstTime == null || isFirstTime == true) ? false : prefs.getBool('convertedUser');
  //   return convertedUser;
  // }
  //
  // void setConvertedUserToTrue() async{
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.setBool('convertedUser', true);
  //   prefs.setBool('firstTime', false);
  //   notifyListeners();
  // }
  // void setConvertedUserToFalse() async{
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.setBool('convertedUser', false);
  //   prefs.setBool('firstTime', false);
  //   notifyListeners();
  // }



}