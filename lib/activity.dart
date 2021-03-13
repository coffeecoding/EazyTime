import 'package:flutter/material.dart';

class Activity {
  TimeOfDay? start = TimeOfDay.now();
  TimeOfDay? end = TimeOfDay.now();
  final String name;
  final Color color;

  Activity(this.name, this.color, [this.start, this.end]);

  double fractionOfDay() => ((end!.hour * 60 + end!.minute) - (start!.hour * 60 + start!.minute)) / 1440;

  String timeDisplay(TimeOfDay time) => '${time.hour}:${time.minute}';

  @override
  String toString() => '$name: ${timeDisplay(start!)} to ${timeDisplay(end!)} (${fractionOfDay().toStringAsFixed(2)}).\n';
}