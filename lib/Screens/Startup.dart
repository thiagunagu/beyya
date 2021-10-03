import 'package:flutter/material.dart';

import 'package:beyya/Screens/ForgotPassword.dart';
import 'package:beyya/Screens/Login.dart';
import 'package:beyya/Screens/Register.dart';

class Startup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Register(),
      theme: ThemeData(
        indicatorColor: Colors.white,
        primaryColor: Colors.red[500], colorScheme: ColorScheme.fromSwatch().copyWith(primary: Colors.red[500],secondary: Colors.red[500]),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: Colors.blueAccent, // This is a custom color variable
          ),
        ),
      ),
      routes: {
        '/Login': (context) => Login(),
        '/ForgotPassword': (context) => ForgotPassword(),
      },
    );
  }
}
