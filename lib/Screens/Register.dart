import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:beyya/CustomWidgets/ErrorAlert.dart';
import 'package:beyya/CustomWidgets/StatusAlert.dart';

import 'package:beyya/Services/AuthService.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController loginEmail = TextEditingController();

  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  final AuthService _auth = AuthService();
  final _registerFormKey = GlobalKey<FormState>();

  static final RegExp _validEmail = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

  bool _obscurePassword = true;
  void _toggleObscurePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  bool _obscureConfirmPassword = true;
  void _toggleObscureConfirmPassword() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign up'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _registerFormKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
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
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: loginEmail,
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
                            obscureText: _obscurePassword,
                            controller: password,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline),
                              labelText: 'Password',
                            ),
                            validator: (value) {
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters.';
                              }
                              return null;
                            },
                          ),
                          IconButton(
                              color: Colors.grey[400],
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: _toggleObscurePassword)
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          TextFormField(
                            obscureText: _obscureConfirmPassword,
                            controller: confirmPassword,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline),
                              labelText: 'Confirm password',
                            ),
                            validator: (value) {
                              if (value != password.text) {
                                return 'Passwords don\'t match.';
                              }
                              return null;
                            },
                          ),
                          IconButton(
                              color: Colors.grey[400],
                              icon: Icon(_obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: _toggleObscureConfirmPassword)
                        ],
                      ),
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.red[500])),
                      textColor: Colors.white,
                      color: Colors.red[500],
                      child: Text(
                        "Sign up",
                      ),
                      onPressed: () async {
                        String loginEmailId = loginEmail.text.trim();
                        if (_registerFormKey.currentState.validate()) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0))),
                                  content: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'Is $loginEmailId the correct email address?'),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            FlatButton(
                                              child: Text('Yes'),
                                              onPressed: () async {
                                                try {
                                                  await showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (context) {
                                                        Future.delayed(
                                                            Duration(
                                                                seconds: 3),
                                                            () {
                                                          Navigator.of(context)
                                                              .pop(true);
                                                        });
                                                        return StatusAlert(
                                                          statusMessage:
                                                              'Creating your account...',
                                                        );
                                                      });
                                                  await _auth
                                                      .registerAccountWithEmail(
                                                          email: loginEmail.text
                                                              .trim(),
                                                          password: password
                                                              .text
                                                              .trim());
                                                } catch (e, s) {
                                                  String _errorMessage;
                                                  await FirebaseCrashlytics
                                                      .instance
                                                      .log(
                                                          'Pressed sign up button');
                                                  await FirebaseCrashlytics
                                                      .instance
                                                      .recordError(e, s,
                                                          reason:
                                                              'Pressed sign up button');
                                                  switch (e.code) {
                                                    case "ERROR_OPERATION_NOT_ALLOWED":
                                                    case 'operation-not-allowed':
                                                      _errorMessage =
                                                          "Something went wrong. Please write to us at teambeyya@gmail.com";
                                                      break;
                                                    case "ERROR_WEAK_PASSWORD":
                                                    case "invalid-password":
                                                      _errorMessage =
                                                          "Passwords must be atleast 6 characters long.";
                                                      break;
                                                    case "ERROR_INVALID_EMAIL":
                                                    case "invalid-email":
                                                      _errorMessage =
                                                          "That's not a valid email. ";
                                                      break;
                                                    case "ERROR_EMAIL_ALREADY_IN_USE":
                                                    case "account-exists-with-different-credential":
                                                    case "email-already-in-use":
                                                      _errorMessage =
                                                          "Looks like you already have an account tied to this email. Please login or reset your password";
                                                      break;
                                                    case "ERROR_INVALID_CREDENTIAL":
                                                    case "invalid-credential":
                                                      _errorMessage =
                                                          "That didn't work. Please check credentials and try again or write to us at teambeyya@gmail.com ";
                                                      break;

                                                    default:
                                                      _errorMessage =
                                                          e.toString();
                                                  }
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return ErrorAlert(
                                                            errorMessage:
                                                                _errorMessage);
                                                      });
                                                }
                                              },
                                            ),
                                            FlatButton(
                                              child: Text('No'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        }
                      },
                    ),
                    FlatButton(
                      child: Text(
                        "Already have an account? Log in!",
                      ),
                      onPressed: () {
                        //navigate to login screen
                        Navigator.pushNamed(context, '/Login');
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
