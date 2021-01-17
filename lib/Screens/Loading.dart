import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.red[500],
        accentColor: Colors.red[500],
      ),
      home: Scaffold(
        backgroundColor: Colors.red[500],
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  color: Colors.red[500],
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Beyya',
                    style: GoogleFonts.baumans(
                        textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 65.0,
                            fontWeight: FontWeight.w400)),
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
