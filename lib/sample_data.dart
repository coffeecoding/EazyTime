import 'package:flutter/material.dart';
import 'activity.dart';
import 'styles.dart';

class SampleData {

  static List<Activity> getSampleEntries() {
    return <Activity>[
      Activity('Sleep', ColorSpec.myBlue, TimeOfDay(hour: 0, minute: 0),
          TimeOfDay(hour: 7, minute: 0)),
      Activity('Eat', ColorSpec.myRed, TimeOfDay(hour: 7, minute: 0),
          TimeOfDay(hour: 8, minute: 0)),
      Activity('Work', ColorSpec.myGreen, TimeOfDay(hour: 8, minute: 0),
          TimeOfDay(hour: 10, minute: 0)),
      Activity('Shower', ColorSpec.myAmber, TimeOfDay(hour: 10, minute: 0),
          TimeOfDay(hour: 11, minute: 20)),
      Activity('Eat', ColorSpec.myRed, TimeOfDay(hour: 11, minute: 20),
          TimeOfDay(hour: 13, minute: 0)),
      Activity('Work', ColorSpec.myGreen, TimeOfDay(hour: 13, minute: 0),
          TimeOfDay(hour: 16, minute: 30)),
    ];
  }

  static List<String> getSampleActivities() {
    return <String>[
      "Work",
      "Sports",
      "Eat",
      "Sleep",
      "Shower"
    ];
  }

  static Map<String, ActivityHistory> getSampleHistory() {
    var _sampleHistory = {
      'Sleep': ActivityHistory('Sleep', ColorSpec.myBlue),
      'Eat': ActivityHistory('Eat', ColorSpec.myRed),
      'Work': ActivityHistory('Work', ColorSpec.myGreen),
      'Shower': ActivityHistory('Shower', ColorSpec.myAmber),
      'Sports': ActivityHistory('Sports', ColorSpec.myPurple),
      'Groceries': ActivityHistory('Groceries', ColorSpec.myTeal),
    };
    _sampleHistory['Sleep']!.addSimple(ActivityPortion.simple(10, '2021-03-10'));
    _sampleHistory['Sleep']!.addSimple(ActivityPortion.simple(13, '2021-03-11'));
    _sampleHistory['Sleep']!.addSimple(ActivityPortion.simple(12, '2021-03-12'));
    _sampleHistory['Sleep']!.addSimple(ActivityPortion.simple(9, '2021-03-13'));
    _sampleHistory['Sleep']!.addSimple(ActivityPortion.simple(10, '2021-03-14'));
    _sampleHistory['Sleep']!.addSimple(ActivityPortion.simple(9.5, '2021-03-15'));
    _sampleHistory['Eat']!.addSimple(ActivityPortion.simple(3, '2021-03-10'));
    _sampleHistory['Eat']!.addSimple(ActivityPortion.simple(2, '2021-03-11'));
    _sampleHistory['Eat']!.addSimple(ActivityPortion.simple(2.2, '2021-03-12'));
    _sampleHistory['Eat']!.addSimple(ActivityPortion.simple(3, '2021-03-13'));
    _sampleHistory['Eat']!.addSimple(ActivityPortion.simple(1.5, '2021-03-14'));
    _sampleHistory['Eat']!.addSimple(ActivityPortion.simple(2.4, '2021-03-15'));
    _sampleHistory['Work']!.addSimple(ActivityPortion.simple(5, '2021-03-10'));
    _sampleHistory['Work']!.addSimple(ActivityPortion.simple(6, '2021-03-11'));
    _sampleHistory['Work']!.addSimple(ActivityPortion.simple(7, '2021-03-12'));
    _sampleHistory['Work']!.addSimple(ActivityPortion.simple(2, '2021-03-13'));
    _sampleHistory['Work']!.addSimple(ActivityPortion.simple(8, '2021-03-14'));
    _sampleHistory['Work']!.addSimple(ActivityPortion.simple(5, '2021-03-15'));
    _sampleHistory['Shower']!.addSimple(ActivityPortion.simple(1, '2021-03-10'));
    _sampleHistory['Shower']!.addSimple(ActivityPortion.simple(1, '2021-03-11'));
    _sampleHistory['Shower']!.addSimple(ActivityPortion.simple(0.5, '2021-03-12'));
    _sampleHistory['Shower']!.addSimple(ActivityPortion.simple(1.2, '2021-03-13'));
    _sampleHistory['Shower']!.addSimple(ActivityPortion.simple(0, '2021-03-14'));
    _sampleHistory['Shower']!.addSimple(ActivityPortion.simple(1.5, '2021-03-15'));
    _sampleHistory['Sports']!.addSimple(ActivityPortion.simple(0, '2021-03-10'));
    _sampleHistory['Sports']!.addSimple(ActivityPortion.simple(1.5, '2021-03-11'));
    _sampleHistory['Sports']!.addSimple(ActivityPortion.simple(0, '2021-03-12'));
    _sampleHistory['Sports']!.addSimple(ActivityPortion.simple(2, '2021-03-13'));
    _sampleHistory['Sports']!.addSimple(ActivityPortion.simple(0, '2021-03-14'));
    _sampleHistory['Sports']!.addSimple(ActivityPortion.simple(1.8, '2021-03-15'));
    _sampleHistory['Groceries']!.addSimple(ActivityPortion.simple(3, '2021-03-10'));
    _sampleHistory['Groceries']!.addSimple(ActivityPortion.simple(0, '2021-03-11'));
    _sampleHistory['Groceries']!.addSimple(ActivityPortion.simple(0, '2021-03-12'));
    _sampleHistory['Groceries']!.addSimple(ActivityPortion.simple(1.2, '2021-03-13'));
    _sampleHistory['Groceries']!.addSimple(ActivityPortion.simple(0, '2021-03-14'));
    _sampleHistory['Groceries']!.addSimple(ActivityPortion.simple(0.5, '2021-03-15'));
    return _sampleHistory;
  }
}