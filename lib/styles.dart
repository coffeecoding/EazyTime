import 'package:flutter/material.dart';

class PrimaryTextStyle extends TextStyle {
  PrimaryTextStyle([Color color = Colors.white]) : super(
    color: color,
    decoration: TextDecoration.none,
    fontSize: 40
  );
}

class SecondaryTextStyle extends TextStyle {
  SecondaryTextStyle() : super(
      color: Colors.white,
      decoration: TextDecoration.none,
      fontSize: 10
  );
}

class SmallSpacedTextStyle extends TextStyle {
  SmallSpacedTextStyle() : super(
    color: Colors.white,
    fontSize: 10.0,
    decoration: TextDecoration.none,
    letterSpacing: 6.0
  );
}