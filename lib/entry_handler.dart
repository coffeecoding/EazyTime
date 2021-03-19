import 'package:flutter/material.dart';
import 'data_access.dart';
import 'data_access.dart';
import 'data_access.dart';
import 'entry.dart';
import 'time_extensions.dart';
import 'activity.dart';
import 'datetime_utils.dart';
import 'entry.dart';
import 'time_extensions.dart';

class EntrySwitchHandler {

  /// Refreshes entries and particularly handles two cases: 1) the regular refresh
  /// that should happen automatically, which updates the end time of the last
  /// entry. 2) Transition between days, i.e. removing all old entries from
  /// entries list and updating first entry/ies for today.
  static Future<void> refreshEntries(List<ActivityEntry> entries, TimeOfDay now) async {
    DateTime today = DateTime.now();

    List<ActivityEntry> entriesBeforeToday = entries.where(
            (e) => !e.date.isEqualTo(today)).toList();
    if (entriesBeforeToday.isNotEmpty) {
      // update entries from previous day and clear entries
      ActivityEntry lastEntryBeforeToday = entriesBeforeToday.last;
      lastEntryBeforeToday.end = TimeOfDay(hour: 24, minute: 0);
      await DBClient.instance.updateEntry(lastEntryBeforeToday);
      ActivityEntry newEntry = ActivityEntry(lastEntryBeforeToday.activity,
          today, TimeOfDay(hour: 0, minute: 0), now);
      await DBClient.instance.insertEntry(newEntry);
      entries = await DBClient.instance.getEntriesByDate(today);
    }
    else {
      ActivityEntry lastEntry = entries.last;
      lastEntry.end = now;
      await DBClient.instance.updateEntry(lastEntry);
      entries = await DBClient.instance.getEntriesByDate(today);
    }
  }

  /// Handles switching between activities given the current state by updating entries accordingly.
  static Future<void> handleSwitch(List<ActivityEntry> entries, Activity newAct, TimeOfDay startTime, TimeOfDay now) async {
    if (entries.isEmpty && startTime.isAfter(TimeOfDay(hour: 0, minute: 0)))
      throw 'First entry needs to start at 00:00.';

    DateTime today = DateTime.now();

    if (startTime.isSimultaneousTo(TimeOfDay(hour: 0, minute: 0)) || entries.isEmpty) {
      for (ActivityEntry e in entries) {
        await DBClient.instance.deleteEntry(e);
      }
      ActivityEntry newEntry = ActivityEntry(newAct, today, startTime, now);
      await DBClient.instance.insertEntry(newEntry);
      entries = await DBClient.instance.getEntriesByDate(today);
      return;
    }

    int idx = idxOfEntryStartingAfterAndEndingTheLatestAt(startTime, entries);
    int idxLast = entries.length-1;
    ActivityEntry lastEntry = entries.last;

    if (startTime.isBefore(lastEntry.start)) {
      ActivityEntry affectedEntry = entries[idx];
      affectedEntry.end = startTime;
      await DBClient.instance.updateEntry(affectedEntry);
      await removeAllAfterIndex(idx, entries);
      ActivityEntry newEntry = ActivityEntry(newAct, today, startTime, now);
      await DBClient.instance.insertEntry(newEntry);
    }

    else if (startTime.isSimultaneousTo(lastEntry.start)) {
      if (newAct.equals(lastEntry.activity)) {
        lastEntry.end = now;
        await DBClient.instance.updateEntry(lastEntry);
      }
      else {
        await DBClient.instance.deleteEntry(lastEntry);
        ActivityEntry newEntry = ActivityEntry(newAct, today, startTime, now);
        await DBClient.instance.insertEntry(newEntry);
      }
    }

    else if (startTime.isBefore(lastEntry.end)) {
      // due to the previous else case this case intentionally becomes:
      // startTime.isAfter(lastEntry.start) && startTime.isBefore(lastEntry.end)
      if (newAct.equals(lastEntry.activity)) {
        if (entries.length > 1) {
          ActivityEntry secondLastEntry = entries.elementAt(idxLast-1);
          secondLastEntry.end = startTime;
          await DBClient.instance.updateEntry(secondLastEntry);
          lastEntry.start = startTime;
        }
        lastEntry.end = now;
        await DBClient.instance.updateEntry(lastEntry);
      }
      else {
        lastEntry.end = startTime;
        await DBClient.instance.updateEntry(lastEntry);
        ActivityEntry newEntry = ActivityEntry(newAct, today, startTime, now);
        await DBClient.instance.insertEntry(newEntry);
      }
    }

    else if (startTime.isSimultaneousTo(lastEntry.end) ||
        startTime.isAfter(lastEntry.end)) {
      if (newAct.equals(lastEntry.activity)) {
        lastEntry.end = now;
        await DBClient.instance.updateEntry(lastEntry);
      }
      else {
        lastEntry.end = startTime;
        await DBClient.instance.updateEntry(lastEntry);
        ActivityEntry newEntry = ActivityEntry(newAct, today, startTime, now);
        await DBClient.instance.insertEntry(newEntry);
      }
    }
    entries = await DBClient.instance.getEntriesByDate(today);
  }

  static int idxOfEntryStartingAfterAndEndingTheLatestAt(TimeOfDay time, List<ActivityEntry> entries) {
    if (entries.isEmpty) return -1;
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].start.isAfter(time)) return i-1;
    }
    return -1;
  }

  static Future<void> removeAllAfterIndex(int i, List<ActivityEntry> entries) async {
    while (entries.length > i+1) {
      await DBClient.instance.deleteEntry(entries.elementAt(i+1));
    }
  }
}