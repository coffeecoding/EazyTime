import 'package:flutter/material.dart';

class PrimaryTextStyle extends TextStyle {
  PrimaryTextStyle(Color color) : super(
    color: color,
    decoration: TextDecoration.none,
    fontSize: 40,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w300
  );
}

class NormalTextStyle extends TextStyle {
  NormalTextStyle(Color color) : super(
    color: color,
    decoration: TextDecoration.none,
    fontSize: 20,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w300
  );
}

class ButtonTextStyle extends TextStyle {
  ButtonTextStyle(Color color) : super(
      color: color,
      decoration: TextDecoration.none,
      fontSize: 14,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w300
  );
}

class SecondaryTextStyle extends TextStyle {
  SecondaryTextStyle(Color color) : super(
      color: color,
      decoration: TextDecoration.none,
      fontSize: 10,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w300
  );
}

class SmallSpacedTextStyle extends TextStyle {
  SmallSpacedTextStyle(Color color) : super(
    color: color,
    fontSize: 10.0,
    decoration: TextDecoration.none,
    letterSpacing: 7.0,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w300
  );
}

class SmallTextStyle extends TextStyle {
  SmallTextStyle(Color color) : super(
      color: color,
      fontSize: 12.0,
      decoration: TextDecoration.none,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w300
  );
}

class LegendTextStyle extends TextStyle {
  LegendTextStyle(Color color) : super(
      color: color,
      fontSize: 10.0,
      decoration: TextDecoration.none,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w300
  );
}

class ColorSpec {
  static Color myBlue = Colors.blue.shade300;
  static Color myRed = Colors.red.shade300;
  static Color myGreen = Colors.green.shade300;
  static Color myAmber = Colors.amber.shade300;
  static Color myPurple = Colors.purple.shade300;
  static Color myTeal = Colors.teal.shade300;

  static List<Color> colorCircle = <Color>[
    Colors.purple.shade300,
    Colors.pink.shade300,
    Colors.red.shade300,
    Colors.deepOrange.shade300,
    Colors.orange.shade300,
    Colors.amber.shade300,
    Colors.green.shade300,
    Colors.teal.shade300,
    Colors.blue.shade300,
    Colors.deepPurple.shade300
  ];
}