import 'package:flutter/material.dart';
import 'dart:math';

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
    fontWeight: FontWeight.w200
  );
}

class NormalTextStyleBold extends TextStyle {
  NormalTextStyleBold(Color color) : super(
      color: color,
      decoration: TextDecoration.none,
      fontSize: 20,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400
  );
}

class ButtonTextStyle extends TextStyle {
  ButtonTextStyle(Color color) : super(
      color: color,
      decoration: TextDecoration.none,
      fontSize: 14,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400
  );
}

class SecondaryTextStyle extends TextStyle {
  SecondaryTextStyle(Color color) : super(
      color: color.withOpacity(0.5),
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
    Colors.blue.shade300,
    Colors.red.shade300,
    Colors.orange.shade300,
    Colors.green.shade300,
    Colors.pink.shade300,
    Colors.indigo.shade300,
    Colors.amber.shade300,
    Colors.purple.shade300,
    Colors.deepOrange.shade300,
    Colors.teal.shade300,
    Colors.blueGrey.shade300,
    Colors.lime.shade300,
    Colors.cyan.shade300
  ];

  static Color randomColor() {
    String hexAlpha = 'FF';
    String result = hexAlpha;
    // We need 3 color components: R, G, and B; the fourth one would be alpha
    // but we do not want random alpha, so we set fix it, see hexAlpha above.
    // From the 3, one should always be 0x42, and one 0xff, and the third one
    // a random value between 0x42 and 0xff; these constraints are in place
    // to always colors of roughly the same brightness but different colors
    var components = ['ff', '0', '1'];
    var rng = Random();
    while (components.isNotEmpty) {
      int nextIndex = rng.nextInt(components.length);
      if (components[nextIndex] == '0') {
        // get random number between 128 and 255 incl, corresponding to
        // the range of 0x42 and 0xff, which will be the third component
        int rangeOf255 = 128;
        int offset = 128;
        int nextComponent = rng.nextInt(rangeOf255);
        nextComponent += offset;
        result += nextComponent.toRadixString(16);
        result = result.padLeft(2, '0');
        components.removeLast();
      }
      else if (components[nextIndex] == '1') {
        // get random number between 128 and 255 incl, corresponding to
        // the range of 0x42 and 0xff, which will be the third component
        int rangeOf255 = 160;
        int offset = 92;
        int nextComponent = rng.nextInt(rangeOf255);
        nextComponent += offset;
        result += nextComponent.toRadixString(16);
        result = result.padLeft(2, '0');
        components.removeLast();
      } else {
        result += components[nextIndex];
        components.removeAt(nextIndex);
      }
    }
    Color rndColor = Color(int.parse(result, radix: 16));
    return rndColor;
  }
}