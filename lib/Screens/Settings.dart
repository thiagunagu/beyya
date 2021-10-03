import 'package:beyya/CustomWidgets/ErrorAlert.dart';
import 'package:beyya/CustomWidgets/StatusAlert.dart';
import 'package:beyya/CustomWidgets/UserTypeProvider.dart';
import 'package:beyya/Services/AuthService.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Container(
          alignment: Alignment.centerLeft,
          child: Text('Settings'),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Card(
            child: ListTile(
              title: Text('Change password'),
              onTap: () {
                Navigator.pushNamed(context, '/ChangePassword');
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Sign out'),
              onTap: () async {
                Provider.of<UserTypeProvider>(
                    context,
                    listen: false)
                    .setConvertedUserToTrue();
                try {
                  await showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        Future.delayed(Duration(seconds: 2), () {
                          Navigator.of(context).pop(true);
                        });
                        return StatusAlert(
                          statusMessage: 'Signing out..',
                        );
                      });
                  await AuthService().signOut();
                } catch (e, s) {
                  await FirebaseCrashlytics.instance
                      .log('Sign out button pressed');
                  await FirebaseCrashlytics.instance.recordError(e, s,
                      reason: 'Sign out button pressed');
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ErrorAlert(errorMessage: e.toString());
                      });
                } //signs out
              },
            )
          ),
          Card(
            child: ListTile(
              title: Text(
                'Delete account',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/DeleteAccount');
              },
            ),
          )
        ],
      ),
    );
  }
}
