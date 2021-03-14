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
  String name;
  Color color;
  double portion;
  DateTime? dateTime = DateTime.now();

  ActivityPortion(this.name, this.color, this.portion, [this.dateTime]);

  /// Useful to create ActivityPortion for history, as name and color info will be there already
  ActivityPortion.simple(this.portion, [String dateTime = '', this.name = '<simple>', this.color = Colors.blue]) {
    if (dateTime == '')
      this.dateTime = DateTime.now();
    else this.dateTime = DateTime.parse(dateTime);
  }
}

class ActivityHistory {
  final String name;
  final Color color;
  late List<ActivityPortion> portionSeries;

  ActivityHistory(this.name, this.color) {
    this.portionSeries = List<ActivityPortion>.empty(growable: true);
  }

  void add(ActivityPortion portion) {
    if (portion.color != color)
      throw 'ActivityPortion has different color than ActivityHistory!';
    portionSeries.add(portion);
  }

  /// doesn't need name and color in portion, will just use the one of this history
  void addSimple(ActivityPortion portion) {
    portion.color = this.color;
    portion.name = this.name;
    portionSeries.add(portion);
  }
}

String getDateDisplay(DateTime date) {
  return '${date.year.toString().substring(2)}-${date.month}-${date.day}';
}