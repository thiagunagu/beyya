import 'package:beyya/CustomWidgets/UserTypeProvider.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:beyya/Services/AuthService.dart';

import 'package:beyya/CustomWidgets/ErrorAlert.dart';

import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController loginEmail = TextEditingController();
  final TextEditingController password = TextEditingController();
  final AuthService _auth = AuthService();
  final _loginFormKey = GlobalKey<FormState>();
  static final RegExp _validEmail = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
  bool _obscureText = true;
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle styleRed = ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 14, color: Colors.white),
        elevation: 4.0,
        primary: Colors.red[500],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.red)));
    return Scaffold(
      appBar:AppBar(
        title: Text('Login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _loginFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Text(
                  //     'Beyya',
                  //     style: GoogleFonts.baumans(textStyle: TextStyle(color: Colors.red[400],fontSize: 40.0,fontWeight: FontWeight.w400)),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: loginEmail,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        labelText: 'Email',
                      ),
                      validator: (value) {
                        if (!_validEmail.hasMatch(value)) {
                          return 'Please enter a valid email.';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextFormField(
                          controller: password,
                          obscureText: _obscureText,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline),
                            labelText: 'Password',
                          ),
                        ),
                        IconButton(
                            color: Colors.grey[400],
                            icon: Icon(_obscureText
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: _toggle)
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: styleRed,
                    onPressed: () async {
                      try {
                        if (_loginFormKey.currentState.validate()) {
                          // await showDialog(
                          //     barrierDismissible: false,
                          //     context: context,
                          //     builder: (context) {
                          //       Future.delayed(Duration(seconds: 2), () {
                          //         Navigator.of(context).pop(true);
                          //       });
                          //       return StatusAlert(
                          //         statusMessage: 'Logging in...',
                          //       );
                          //     });
                          Flushbar(
                            flushbarPosition: FlushbarPosition.TOP,
                            message:
                            'Logging in..',
                            duration: Duration(seconds: 2),
                            margin: EdgeInsets.all(8),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )..show(context);
                          await _auth.signInWithEmail(
                              email: loginEmail.text.trim(),
                              password: password.text.trim());
                          Provider.of<UserTypeProvider>(context, listen: false)
                              .setConvertedUserToTrue();
                          _auth.signOut();
                          await _auth.signInWithEmail(
                              email: loginEmail.text.trim(),
                              password: password.text.trim());
                        }
                      } catch (e, s) {
                        String _errorMessage;
                        await FirebaseCrashlytics.instance
                            .log('Pressed login button');
                        await FirebaseCrashlytics.instance
                            .recordError(e, s, reason: 'Pressed login button');
                        switch (e.code) {
                          case "ERROR_WRONG_PASSWORD":
                          case "wrong-password":
                            _errorMessage =
                                "Incorrect password.\nPlease try again or reset your password.";
                            break;
                          case "ERROR_USER_NOT_FOUND":
                          case "user-not-found":
                            _errorMessage =
                                "Hmmm.. That account doesn\'t exist. Please try again or sign up for a new account.";
                            break;
                          case "ERROR_USER_DISABLED":
                          case "user-disabled":
                            _errorMessage =
                                "Your account has been disabled. Please register with different email or write to us at teambeyya@gmail.com.";
                            break;
                          case "ERROR_TOO_MANY_REQUESTS":
                          case "operation-not-allowed":
                            _errorMessage =
                                "You tried too many times. Please try again after few hours or write to us at teambeyya@gmail.com.";
                            break;
                          case "ERROR_OPERATION_NOT_ALLOWED":
                          case "operation-not-allowed":
                            _errorMessage =
                                "Server error, please try again later or write to us at teambeyya@gmail.com..";
                            break;
                          case "ERROR_INVALID_EMAIL":
                          case "invalid-email":
                            _errorMessage = "Please enter a valid email.";
                            break;
                          case "ERROR_USER_NOT_FOUND":
                          case "user-not-found":
                            _errorMessage =
                                "Hmmm.. That account doesn\'t exist. Please try again or sign up for a new account.";
                            break;
                          default:
                            _errorMessage = e.toString();
                            break;
                        }
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ErrorAlert(errorMessage: _errorMessage);
                            });
                      }
                    },
                    child: Text(
                      "Login",
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.popAndPushNamed(context, '/Register');
                        },
                        child: Text(
                          "New User? Sign up!",
                        ),
                      ),
                      TextButton(
                        child: Text('Forgot password?'),
                        onPressed: () {
                          Navigator.popAndPushNamed(context, '/ForgotPassword');
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
