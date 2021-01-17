import 'package:flutter/material.dart';

class ErrorAlert extends StatelessWidget {
  const ErrorAlert({
    Key key,
    @required this.errorMessage,
  }) : super(key: key);

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text('Oops!')),
      content: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(errorMessage),
      ),
      actions: [
        RaisedButton(
          shape: StadiumBorder(),
          color: Theme.of(context).accentColor,
          child: Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      actionsPadding: EdgeInsets.all(8.0),
      buttonPadding: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
    );
  }
}
