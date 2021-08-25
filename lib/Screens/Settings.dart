import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
  brightness: Brightness.dark,

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
