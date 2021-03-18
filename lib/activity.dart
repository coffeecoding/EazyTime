import 'package:flutter/material.dart';

abstract class IActivityProperties {
  String get name;
  int get color;
}

class Activity extends IActivityProperties {
  final int? id;
  final String name;
  final int color;
  int isActive;

  Activity(this.name, this.color, [this.id, this.isActive = 1]);

  bool equals(Activity other) {
    return this.name == other.name;
  }

  @override
  String toString() => '$id $name $color $isActive';

  Map<String, dynamic> toMap() {
    return {
      'activityId': id,
      'name': name,
      'color': color,
      'isActive': isActive
    };
  }
}

/// Describes the absolute portion an Activity covers of a day (24).
/// For example, if you sleep 3x throughout a day, this class accumulates
/// the durations of those, for example to portion = 12.5 hrs
class ActivityPortion extends IActivityProperties {
  Activity activity;
  double portion;
  DateTime? dateTime = DateTime.now();

  ActivityPortion(this.activity, this.portion, [this.dateTime]);

  /// Useful to load sample hist data, as activity info (name and color)
  /// will be inside hist object already
  ActivityPortion.s(this.activity, this.portion, String dateTime) {
    this.dateTime = DateTime.parse(dateTime);
  }

  String get name => activity.name;
  int get color => activity.color;
}

class ActivityHistory {
  final Activity activity;
  late List<ActivityPortion> portionSeries;

  ActivityHistory(this.activity) {
    this.portionSeries = List<ActivityPortion>.empty(growable: true);
  }

  void add(ActivityPortion portion) {
    if (portion.activity.name != this.activity.name)
      throw 'ActivityPortion has different name than this Activityhist!';
    portionSeries.add(portion);
  }

  String get name => activity.name;
  int get color => activity.color;
}

String getDateDisplay(DateTime date) {
  return '${date.year.toString().substring(2)}-${date.month}-${date.day}';
}