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
  static Future<String> refreshEntries(List<ActivityEntry> entries) async {
    String debugLog = 'Entered refreshEntries(entries{${entries.length}})\n';

    DateTime today = DateTime.now();
    TimeOfDay now = TimeOfDay(hour: today.hour, minute: today.minute);

    List<ActivityEntry> entriesBeforeToday = entries.where(
            (e) => !e.date.equalsDateOf(today)).toList();
    debugLog += ' Queried entriesBeforeToday{${entriesBeforeToday.length}}\n';

    if (entriesBeforeToday.isNotEmpty) {
      // update entries from previous day and clear entries
      ActivityEntry lastEntryBeforeToday = entriesBeforeToday.last;
      lastEntryBeforeToday.end = TimeOfDay(hour: 24, minute: 0);
      await DBClient.instance.updateEntry(lastEntryBeforeToday);
      ActivityEntry newEntry = ActivityEntry(lastEntryBeforeToday.activity,
          today, TimeOfDay(hour: 0, minute: 0), now);
      await DBClient.instance.insertEntry(newEntry);
      debugLog += ' Updated entriesBeforeToday, added new ${newEntry.toString()}\n';
    }

    if (entries.isEmpty) {
      // If entries is empty, get the last entry, for example this could be
      // Entry 'Sleep' from the evening before, and add that activity to today
      // starting at midnight until the current moment (now)
      ActivityEntry? lastKnownEntry = await DBClient.instance.getLastEntry();
      if (lastKnownEntry == null)
        return debugLog;
      ActivityEntry newEntry = ActivityEntry(lastKnownEntry.activity, today,
        TimeOfDay(hour: 0, minute: 0), now);
      await DBClient.instance.insertEntry(newEntry);
      entries = await DBClient.instance.getEntriesByDate(today);
      debugLog += ' Added new ${newEntry.toString()} and entries=EntriesBy(today)\n';
      return debugLog;
    }

    entries = await DBClient.instance.getEntriesByDate(today);
    ActivityEntry lastEntry = entries.last;
    lastEntry.end = now;
    await DBClient.instance.updateEntry(lastEntry);
    debugLog += ' Updated last ${lastEntry.toString()}\n';
    entries = await DBClient.instance.getEntriesByDate(today);
    debugLog += ' Refreshed entriesBy(today){${entries.length}}\n';
    return debugLog;
  }

  /// Handles switching between activities given the current state by updating entries accordingly.
  static Future<String> handleSwitch(List<ActivityEntry> entries, Activity newAct, TimeOfDay startTime, DateTime day) async {
    String debugLog = 'Entered handleSwitch(entries{${entries.length}}\n';
    debugLog += ' Parameters:\n';
    debugLog += ' newAct = ${newAct.toString()}\n';
    debugLog += ' startTime = ${startTime.display()}\n';
    debugLog += ' day = ${day.toSimpleString()}\n';
    debugLog += await refreshEntries(entries);

    DateTime today = DateTime.now();
    TimeOfDay now = TimeOfDay(hour: today.hour, minute: today.minute);

    if (day.equalsDateOf(today) && startTime.isAfter(now))
      throw 'Start time cannot be in the future!';
    else if (day.isBeforeDayOf(today)) {
      // For handling history day-entries, now is always the end of the day
      now = TimeOfDay(hour: 24, minute: 0);
    }

    if (entries.isEmpty || startTime.isSimultaneousTo(TimeOfDay(hour: 0, minute: 0))) {
      for (ActivityEntry e in entries) {
        await DBClient.instance.deleteEntry(e);
      }
      ActivityEntry newEntry = ActivityEntry(newAct, day, startTime, now);
      await DBClient.instance.insertEntry(newEntry);
      entries = await DBClient.instance.getEntriesByDate(day);
      debugLog += ' Added new ${newEntry.toString()} and entries=EntriesBy(today)\n';
      return debugLog;
    }

    int idx = idxOfEntryStartingAfterAndEndingTheLatestAt(startTime, entries);
    int idxLast = entries.length-1;
    ActivityEntry lastEntry = entries.last;

    if (startTime.isBefore(lastEntry.start)) {
      debugLog += ' start < last.start\n';
      ActivityEntry affectedEntry = entries[idx];
      affectedEntry.end = startTime;
      await DBClient.instance.updateEntry(affectedEntry);
      await removeAllAfterIndex(idx, entries);
      ActivityEntry newEntry = ActivityEntry(newAct, day, startTime, now);
      await DBClient.instance.insertEntry(newEntry);
      debugLog += ' Added new ${newEntry.toString()}\n';
    }

    else if (startTime.isSimultaneousTo(lastEntry.start)) {
      debugLog += ' start == last.start\n';
      if (newAct.equals(lastEntry.activity)) {
        debugLog += ' newAct == last.act\n';
        lastEntry.end = now;
        await DBClient.instance.updateEntry(lastEntry);
        debugLog += ' Updated last ${lastEntry.toString()}\n';
      }
      else {
        debugLog += ' newAct != last.act\n';
        await DBClient.instance.deleteEntry(lastEntry);
        ActivityEntry newEntry = ActivityEntry(newAct, day, startTime, now);
        await DBClient.instance.insertEntry(newEntry);
        debugLog += ' Deleted last ${lastEntry.toString()}\n';
        debugLog += ' Added new ${newEntry.toString()}\n';
      }
    }

    else if (startTime.isBefore(lastEntry.end)) {
      debugLog += ' start < last.end\n';
      // due to the previous else case this case intentionally becomes:
      // startTime.isAfter(lastEntry.start) && startTime.isBefore(lastEntry.end)
      if (newAct.equals(lastEntry.activity)) {
        debugLog += ' newAct == last.act\n';
        if (entries.length > 1) {
          debugLog += ' entries.length > 1\n';
          ActivityEntry secondLastEntry = entries.elementAt(idxLast-1);
          secondLastEntry.end = startTime;
          await DBClient.instance.updateEntry(secondLastEntry);
          lastEntry.start = startTime;
          debugLog += ' Updated secondLast ${secondLastEntry.toString()}\n';
        }
        lastEntry.end = now;
        await DBClient.instance.updateEntry(lastEntry);
        debugLog += ' Updated last ${lastEntry.toString()}\n';
      }
      else {
        debugLog += ' newAct != last.act\n';
        lastEntry.end = startTime;
        await DBClient.instance.updateEntry(lastEntry);
        debugLog += ' Updated last ${lastEntry.toString()}\n';
        ActivityEntry newEntry = ActivityEntry(newAct, day, startTime, now);
        await DBClient.instance.insertEntry(newEntry);
        debugLog += ' Added new ${newEntry.toString()}\n';
      }
    }

    else if (startTime.isSimultaneousTo(lastEntry.end) ||
        startTime.isAfter(lastEntry.end)) {
      debugLog += ' start == last.end || start > last.end\n';
      if (newAct.equals(lastEntry.activity)) {
        debugLog += ' newAct == last.act\n';
        lastEntry.end = now;
        await DBClient.instance.updateEntry(lastEntry);
        debugLog += ' Updated last ${lastEntry.toString()}\n';
      }
      else {
        debugLog += ' newAct != last.act\n';
        lastEntry.end = startTime;
        await DBClient.instance.updateEntry(lastEntry);
        debugLog += ' Updated last ${lastEntry.toString()}\n';
        ActivityEntry newEntry = ActivityEntry(newAct, day, startTime, now);
        await DBClient.instance.insertEntry(newEntry);
        debugLog += ' Added new ${newEntry.toString()}\n';
      }
    }
    entries = await DBClient.instance.getEntriesByDate(day);
    debugLog += ' Refreshed entriesBy(today){${entries.length}}\n';
    return debugLog;
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