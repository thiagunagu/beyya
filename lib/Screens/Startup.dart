import 'package:flutter/material.dart';

import 'package:beyya/Screens/ForgotPassword.dart';
import 'package:beyya/Screens/Login.dart';
import 'package:beyya/Screens/Register.dart';

class Startup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Register(),
      theme: ThemeData(appBarTheme: AppBarTheme(brightness: Brightness.dark),
        primaryColor: Colors.red[500],
        accentColor: Colors.red[500],
      ),
      routes: {
        '/Login': (context) => Login(),
        '/ForgotPassword': (context) => ForgotPassword(),
      },
    );
  }
}
