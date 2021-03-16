import 'package:flutter/material.dart';
import 'time_extensions.dart';
import 'activity.dart';

class ActivityEntry {
  TimeOfDay start;
  TimeOfDay end;
  final Activity activity;

  ActivityEntry(this.activity,
      [this.start = const TimeOfDay(hour: 0, minute: 0),
      this.end = const TimeOfDay(hour: 0, minute: 0)]);

  double fractionOfDay() => ((end.hour * 60 + end.minute) -
      (start.hour * 60 + start.minute)) / 1440;

  @override
  String toString() => '${this.activity.name}: '
      '${start.display()} to ${end.display()} '
      '(${fractionOfDay().toStringAsFixed(2)}).\n';

  bool equals(ActivityEntry other) {
    return this.activity.equals(other.activity)
        && this.start == other.start
        && this.end == other.end;
  }
}

class EntryHandler {

  /// Handles switching between activities given the current state by updating entries accordingly.
  static void handleSwitch(List<ActivityEntry> entries, Activity newAct, TimeOfDay startTime, TimeOfDay now) {
    ActivityEntry currentAct = entries.last;

    int idx =_isWithinPreviousEntryExcludingEndTime(entries, startTime);
    if (idx >= 0) {
      if (newAct.equals(currentAct.activity)) {
        
      }
    }

  }

  static int _isWithinPreviousEntryExcludingEndTime(List<ActivityEntry> _entries, TimeOfDay time) {
    if (_entries.isEmpty) return -1;
    for (int i = 0; i < _entries.length; i++) {
      if (_entries[i].end.isAfter(time)) return i;
    }
    return -1;
  }
}