import 'package:flutter/material.dart';
import 'time_extensions.dart';
import 'activity.dart';
import 'datetime_utils.dart';

class ActivityEntry extends IActivityProperties {
  TimeOfDay start;
  TimeOfDay end;
  final DateTime date;
  final int? activityId;
  final int? id;
  Activity activity;
  int committed;

  String get name => activity.name;
  int get color => activity.color;

  ActivityEntry(this.activity, this.date,
      [this.start = const TimeOfDay(hour: 0, minute: 0),
      this.end = const TimeOfDay(hour: 0, minute: 0), this.activityId, this.id, this.committed = 0]);

  double fractionOfDay() => ((end.hour * 60 + end.minute) -
      (start.hour * 60 + start.minute)) / 1440; // 1440 is minutes in a day

  double durationInHours() => ((end.hour * 60 + end.minute) -
      (start.hour * 60 + start.minute)) / 60;

  @override
  String toString() => '${this.activity.name} $committed '
      '${this.date.month}-${this.date.day}: '
      '${start.display()} to ${end.display()} '
      '(${fractionOfDay().toStringAsFixed(2)})';

  bool equals(ActivityEntry other) {
    return this.activity.equals(other.activity)
        && this.start == other.start
        && this.end == other.end;
  }

  Map<String, dynamic> toMap() {
    return {
      'entryId': id,
      'activityId': activity.id,
      'date': DateTimeUtils.dateToString(date),
      'startTime': DateTimeUtils.timeToString(start),
      'endTime': DateTimeUtils.timeToString(end),
      'committed': committed
    };
  }
}

/// Deprecated. This one only manipulates the local entries. The implementation
/// entry_handler.dart actually does the data handling with the database.
class EntryHandler {
  /// Handles switching between activities given the current state by updating entries accordingly.
  static void handleSwitch(List<ActivityEntry> entries, Activity newAct, TimeOfDay startTime, TimeOfDay now) {
    if (startTime.isAfter(now))
      throw 'Start time cannot be in the future.';
    else if (entries.isEmpty && startTime.isAfter(TimeOfDay(hour: 0, minute: 0)))
      throw 'First entry needs to start at 00:00.';
    else if (entries.isNotEmpty && startTime.isAfter(entries.last.end))
      throw 'Start time can\'t be after the end of the last entry!';

    DateTime today = DateTime.now();

    if (startTime.isSimultaneousTo(TimeOfDay(hour: 0, minute: 0)) || entries.isEmpty) {
      entries.clear();
      ActivityEntry newEntry = ActivityEntry(newAct, today, startTime, now);
      entries.add(newEntry);
      return;
    }

    int idx = idxOfEntryStartingAfterAndEndingTheLatestAt(startTime, entries);
    int idxLast = entries.length-1;
    ActivityEntry lastEntry = entries.last;

    if (startTime.isBefore(lastEntry.start)) {
      ActivityEntry affectedEntry = entries[idx];
      affectedEntry.end = startTime;
      removeAllAfterIndex(idx, entries);
      ActivityEntry newEntry = ActivityEntry(newAct, today, startTime, now);
      entries.add(newEntry);
    }

    else if (startTime.isSimultaneousTo(lastEntry.start)) {
      if (newAct.equals(lastEntry.activity)) {
        lastEntry.end = now;
      }
      else {
        entries.removeLast();
        ActivityEntry newEntry = ActivityEntry(newAct, today, startTime, now);
        entries.add(newEntry);
      }
    }

    else if (startTime.isBefore(lastEntry.end)) {
      // due to the previous else case this case intentionally becomes:
      // startTime.isAfter(lastEntry.start) && startTime.isBefore(lastEntry.end)
      if (newAct.equals(lastEntry.activity)) {
        if (entries.length > 1) {
          ActivityEntry secondLastEntry = entries.elementAt(idxLast-1);
          secondLastEntry.end = startTime;
          lastEntry.start = startTime;
        }
        lastEntry.end = now;
      }
      else {
        lastEntry.end = startTime;
        ActivityEntry newEntry = ActivityEntry(newAct, today, startTime, now);
        entries.add(newEntry);
      }
    }

    else if (startTime.isSimultaneousTo(lastEntry.end) ||
            startTime.isSimultaneousTo(now)) {
      if (newAct.equals(lastEntry.activity)) {
        lastEntry.end = now;
      }
      else {
        lastEntry.end = startTime;
        ActivityEntry newEntry = ActivityEntry(newAct, today, startTime, now);
        entries.add(newEntry);
      }
    }
  }

  static int idxOfEntryStartingAfterAndEndingTheLatestAt(TimeOfDay time, List<ActivityEntry> entries) {
    if (entries.isEmpty) return -1;
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].start.isAfter(time)) return i-1;
    }
    return -1;
  }

  static void removeAllAfterIndex(int i, List<ActivityEntry> entries) {
    while (entries.length > i+1) {
      entries.removeAt(i+1);
    }
  }
}