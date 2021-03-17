import 'package:flutter/material.dart';
import 'activity.dart';
import 'entry.dart';
import 'styles.dart';

class SampleData {

  static List<ActivityEntry> getSampleEntries() {
    return <ActivityEntry>[
      ActivityEntry(getActivities()[2], DateTime.now(), TimeOfDay(hour: 0, minute: 0),
          TimeOfDay(hour: 7, minute: 0)),
      ActivityEntry(getActivities()[1], DateTime.now(), TimeOfDay(hour: 7, minute: 0),
          TimeOfDay(hour: 8, minute: 0)),
      ActivityEntry(getActivities()[0], DateTime.now(), TimeOfDay(hour: 8, minute: 0),
          TimeOfDay(hour: 10, minute: 0)),
      ActivityEntry(getActivities()[3], DateTime.now(), TimeOfDay(hour: 10, minute: 0),
          TimeOfDay(hour: 11, minute: 20)),
      ActivityEntry(getActivities()[1], DateTime.now(), TimeOfDay(hour: 11, minute: 20),
          TimeOfDay(hour: 13, minute: 0)),
      ActivityEntry(getActivities()[0], DateTime.now(), TimeOfDay(hour: 13, minute: 0),
          TimeOfDay(hour: 16, minute: 30)),
    ];
  }

  static List<Activity> getActivities() {
    return <Activity>[
      Activity('Work', ColorSpec.myGreen.value),
      Activity('Eat', ColorSpec.myAmber.value),
      Activity('Sleep', ColorSpec.myBlue.value),
      Activity('Shower', ColorSpec.myTeal.value),
      Activity('Sports', ColorSpec.myRed.value),
      Activity('Groceries', ColorSpec.myPurple.value),
    ];
  }

  static Map<String, ActivityHistory> getSampleHistory() {
    var hist = {
      'Sleep': ActivityHistory(getActivities()[2]),
      'Eat': ActivityHistory(getActivities()[1]),
      'Work': ActivityHistory(getActivities()[0]),
      'Shower': ActivityHistory(getActivities()[3]),
      'Sports': ActivityHistory(getActivities()[4]),
      'Groceries': ActivityHistory(getActivities()[5]),
    };
    hist['Sleep']!.add(ActivityPortion.s(getActivities()[2], 10, '2021-03-10'));
    hist['Sleep']!.add(ActivityPortion.s(getActivities()[2], 13, '2021-03-11'));
    hist['Sleep']!.add(ActivityPortion.s(getActivities()[2], 12, '2021-03-12'));
    hist['Sleep']!.add(ActivityPortion.s(getActivities()[2], 9, '2021-03-13'));
    hist['Sleep']!.add(ActivityPortion.s(getActivities()[2], 10, '2021-03-14'));
    hist['Sleep']!.add(ActivityPortion.s(getActivities()[2], 9.5, '2021-03-15'));
    hist['Eat']!.add(ActivityPortion.s(getActivities()[1], 3, '2021-03-10'));
    hist['Eat']!.add(ActivityPortion.s(getActivities()[1], 2, '2021-03-11'));
    hist['Eat']!.add(ActivityPortion.s(getActivities()[1], 2.2, '2021-03-12'));
    hist['Eat']!.add(ActivityPortion.s(getActivities()[1], 3, '2021-03-13'));
    hist['Eat']!.add(ActivityPortion.s(getActivities()[1], 1.5, '2021-03-14'));
    hist['Eat']!.add(ActivityPortion.s(getActivities()[1], 2.4, '2021-03-15'));
    hist['Work']!.add(ActivityPortion.s(getActivities()[0], 5, '2021-03-10'));
    hist['Work']!.add(ActivityPortion.s(getActivities()[0], 6, '2021-03-11'));
    hist['Work']!.add(ActivityPortion.s(getActivities()[0], 7, '2021-03-12'));
    hist['Work']!.add(ActivityPortion.s(getActivities()[0], 2, '2021-03-13'));
    hist['Work']!.add(ActivityPortion.s(getActivities()[0], 8, '2021-03-14'));
    hist['Work']!.add(ActivityPortion.s(getActivities()[0], 5, '2021-03-15'));
    hist['Shower']!.add(ActivityPortion.s(getActivities()[3], 1, '2021-03-10'));
    hist['Shower']!.add(ActivityPortion.s(getActivities()[3], 1, '2021-03-11'));
    hist['Shower']!.add(ActivityPortion.s(getActivities()[3], 0.5, '2021-03-12'));
    hist['Shower']!.add(ActivityPortion.s(getActivities()[3], 1.2, '2021-03-13'));
    hist['Shower']!.add(ActivityPortion.s(getActivities()[3], 0, '2021-03-14'));
    hist['Shower']!.add(ActivityPortion.s(getActivities()[3], 1.5, '2021-03-15'));
    hist['Sports']!.add(ActivityPortion.s(getActivities()[4], 0, '2021-03-10'));
    hist['Sports']!.add(ActivityPortion.s(getActivities()[4], 1.5, '2021-03-11'));
    hist['Sports']!.add(ActivityPortion.s(getActivities()[4], 0, '2021-03-12'));
    hist['Sports']!.add(ActivityPortion.s(getActivities()[4], 2, '2021-03-13'));
    hist['Sports']!.add(ActivityPortion.s(getActivities()[4], 0, '2021-03-14'));
    hist['Sports']!.add(ActivityPortion.s(getActivities()[4], 1.8, '2021-03-15'));
    hist['Groceries']!.add(ActivityPortion.s(getActivities()[5], 3, '2021-03-10'));
    hist['Groceries']!.add(ActivityPortion.s(getActivities()[5], 0, '2021-03-11'));
    hist['Groceries']!.add(ActivityPortion.s(getActivities()[5], 0, '2021-03-12'));
    hist['Groceries']!.add(ActivityPortion.s(getActivities()[5], 1.2, '2021-03-13'));
    hist['Groceries']!.add(ActivityPortion.s(getActivities()[5], 0, '2021-03-14'));
    hist['Groceries']!.add(ActivityPortion.s(getActivities()[5], 0.5, '2021-03-15'));
    return hist;
  }
}