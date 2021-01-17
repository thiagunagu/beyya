import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:google_fonts/google_fonts.dart';

class ErrorScreen extends StatelessWidget {
  final String errorMessage;
  ErrorScreen({this.errorMessage});
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.log('Error screen');
    FirebaseCrashlytics.instance
        .recordError(errorMessage, null, reason: 'Error screen');
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.red[500],
          accentColor: Colors.red[500],
          buttonBarTheme: ButtonBarThemeData(
            alignment: MainAxisAlignment.center,
          )),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Oops'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Beyya',
                    style: GoogleFonts.baumans(
                        textStyle: TextStyle(
                            color: Colors.red[400],
                            fontSize: 40.0,
                            fontWeight: FontWeight.w400)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: errorMessage != null
                      ? Text(
                          'Error:$errorMessage '
                          '\n Oops! Something went wrong! Please restart the app! If the problem persists, please write to us at teambeyya@gmail.com',
                        )
                      : Text(
                          'Oops! Something went wrong! Please restart the app! If the problem persists, please write to us at teambeyya@gmail.com',
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
