import 'package:flutter/material.dart';

class Activity {
  TimeOfDay? start = TimeOfDay.now();
  TimeOfDay? end = TimeOfDay.now();
  final String name;
  final Color color;

  Activity(this.name, this.color, [this.start, this.end]);

  double fractionOfDay() => ((end!.hour * 60 + end!.minute) -
      (start!.hour * 60 + start!.minute)) / 1440;

  String timeDisplay(TimeOfDay time) => '${time.hour}:${time.minute}';

  @override
  String toString() => '$name: ${timeDisplay(start!)} to ${timeDisplay(end!)} '
      '(${fractionOfDay().toStringAsFixed(2)}).\n';
}

/// Describes the absolute portion an Activity covers of a day (24).
/// For example, if you sleep 3x throughout a day, this class accumulates
/// the durations of those, for example to portion = 12.5 hrs
class ActivityPortion {
  final String name;
  final Color color;
  double portion;

  ActivityPortion(this.name, this.color, this.portion);
}