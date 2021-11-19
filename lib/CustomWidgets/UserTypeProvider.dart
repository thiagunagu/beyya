import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserTypeProvider extends ChangeNotifier {
  bool _convertedUser;
  SharedPreferences _pref;
  int _launchNumber;
  int _firstLaunchDate;
  int _noOfDaysFromLaunch;

  bool get convertedUser=>_convertedUser;
  int get launchNumber=>_launchNumber;
  int get noOfDaysFromLaunch=>_noOfDaysFromLaunch;

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

  incrementLaunchNumber()async{
    await _initPrefs();
    _launchNumber=_pref.getInt('launchNumber');
    if(_launchNumber==null){
      _launchNumber=1;
    }
    else{
      _launchNumber=_launchNumber+1;
    }
    _saveLaunchNumberToPrefs();
  }

  calculateDaysFromFirstLaunch()async{
    await _initPrefs();
    _firstLaunchDate=_pref.getInt('firstLaunchDate');
    if(_firstLaunchDate==null){
      _firstLaunchDate=DateTime.now().millisecondsSinceEpoch;
      _saveFirstLaunchDateToPrefs();
      _noOfDaysFromLaunch=0;
    }
    else{
      DateTime firstLaunch=DateTime.fromMillisecondsSinceEpoch(_firstLaunchDate);
      DateTime now = DateTime.now();
      Duration timeDifference = now.difference(firstLaunch);
      _noOfDaysFromLaunch = timeDifference.inDays;
    }
  }

  _saveLaunchNumberToPrefs() async {
    await _initPrefs();
    _pref.setInt('launchNumber', _launchNumber);
  }

  _saveFirstLaunchDateToPrefs() async {
    await _initPrefs();
    _pref.setInt('firstLaunchDate', _firstLaunchDate);
  }

  _initPrefs() async {
    if(_pref == null)
      _pref  = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();
    _convertedUser = _pref.getBool('UserType');
    _launchNumber=_pref.getInt('launchNumber');
    notifyListeners();
  }
  _saveToPrefs() async {
    await _initPrefs();
    _pref.setBool('UserType', _convertedUser);
  }
}