import 'package:beyya/CustomWidgets/UserTypeProvider.dart';
import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:provider/provider.dart';

import 'package:beyya/CustomWidgets/ErrorAlert.dart';
import 'package:beyya/CustomWidgets/StatusAlert.dart';

import 'package:beyya/Models/SignedInUser.dart';

import 'package:beyya/Services/AuthService.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _currentPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmNewPassword = TextEditingController();
  final AuthService _auth = AuthService();
  final _changePasswordFormKey = GlobalKey<FormState>();
  bool _obscureCurrentPassword = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _toggleObscureCurrentPassword() {
    setState(() {
      _obscureCurrentPassword = !_obscureCurrentPassword;
    });
  }

  void _toggleObscurePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleObscureConfirmPassword() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
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
  brightness: Brightness.dark,

        title: Container(
          alignment: Alignment.centerLeft,
          child: Text('Change password'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _changePasswordFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextFormField(
                          obscureText: true,
                          controller: _currentPassword,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline),
                            labelText: 'Current password',
                          ),
                        ),
                        IconButton(
                            color: Colors.grey[400],
                            icon: Icon(_obscureCurrentPassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: _toggleObscureCurrentPassword)
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextFormField(
                          obscureText: true,
                          controller: _newPassword,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline),
                            labelText: 'New password',
                          ),
                          validator: (value) {
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
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
                          obscureText: true,
                          controller: _confirmNewPassword,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline),
                            labelText: 'Confirm new password',
                          ),
                          validator: (value) {
                            if (value != _newPassword.text) {
                              return 'Passwords don\'t match';
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
                  Container(height: 4.0,),
                  ElevatedButton(
                    style: styleRed,
                    onPressed: () async {
                      if (_changePasswordFormKey.currentState.validate()) {
                        try {
                          await showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                Future.delayed(Duration(seconds: 2), () {
                                  Navigator.of(context).pop(true);
                                });
                                return StatusAlert(
                                    statusMessage: 'Updating password..');
                              });
                          await _auth.signInWithEmail(
                              email: Provider.of<SignedInUser>(context,
                                      listen: false)
                                  .userEmail,
                              password: _currentPassword.text.trim());
                          await _auth
                              .changePassword(
                                  password: _newPassword.text.trim())
                              .then((value) {
                            Provider.of<UserTypeProvider>(
                                context,
                                listen: false)
                                .setConvertedUserToTrue();
                            _auth.signOut();
                          });
                        } catch (e, s) {
                          await FirebaseCrashlytics.instance
                              .log('Pressed change password button');
                          await FirebaseCrashlytics.instance.recordError(e, s,
                              reason: 'Pressed change password button');
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ErrorAlert(errorMessage: e.toString());
                              });
                        }
                      }
                    },
                    child: Text(
                      "Change password",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
