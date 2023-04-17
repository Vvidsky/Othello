 import 'package:flutter/material.dart';
 
 Widget buildAppName() {
    return Column(
      children: <Widget>[
        Text(
              'Othello',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 84,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 4
                  ..color = Colors.black,
              ),
            ),
            const Text(
              'A minute to learn, A lifeitme to master',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
      ],
    );
  }