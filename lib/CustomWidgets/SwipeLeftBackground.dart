import 'package:flutter/material.dart';

class SwipeLeftBackground extends StatelessWidget {
  const SwipeLeftBackground({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.redAccent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      alignment: Alignment.centerRight,
    );
  }
}