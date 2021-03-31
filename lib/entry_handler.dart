import 'package:flutter/material.dart';
import 'data_access.dart';
import 'entry.dart';
import 'time_extensions.dart';
import 'activity.dart';
import 'datetime_utils.dart';
import 'extensions.dart';

class EntrySwitchHandler {

  /// Refreshes entries and particularly handles two cases: 1) the regular refresh
  /// that should happen automatically, which updates the end time of the last
  /// entry. 2) Transition between days, i.e. removing all old entries from
  /// entries list and updating first entry/ies for today.
  ///
  /// Gets Entry Information from the source of truth, the database, updates
  /// the entries list with that information. That is, updating and committing
  /// open entries from previous days and updating end time of last entry today.
  static Future<String> updateEntries(List<ActivityEntry> entries) async {
    DateTime today = DateTime.now();
    TimeOfDay now = TimeOfDay(hour: today.hour, minute: today.minute);
    today = DateUtils.dateOnly(today);

    String debugLog = '** UPDATING ENTRIES ${today.toSimpleString()}-${now.display()} **\n';
    entries.forEach((e) { debugLog += '  ${e.toString()}\n'; });

    debugLog += ' Retrieving open entries...\n';
    List<ActivityEntry> openEntries = await DBClient.instance.getAllOpenEntries();
    debugLog += ' Found ${openEntries.length} open entries:\n';
    openEntries.forEach((e) { debugLog += '  ${e.toString()}\n'; });

    debugLog += ' Grouping open entries by date...\n';
    Map<DateTime, List<ActivityEntry>> openEntriesByDate
      = openEntries.groupBy<DateTime>((e) => DateUtils.dateOnly(e.date));
    debugLog += ' Found open entries for '
        '${openEntriesByDate.keys.length} days:\n';
    openEntriesByDate.entries.forEach((e) {
      debugLog += ' ${e.key.toSimpleString()}\n';
      e.value.forEach((val) { debugLog += '  ${val.toString()}\n'; });
    });

    // If there is an open entry for today, update end to now
    debugLog += ' Looking for open entries of today...\n';
    if (openEntriesByDate.containsKey(today)) {
      debugLog += ' Found! Updating those...\n';
      ActivityEntry lastEntry = openEntriesByDate[today]!.last;
      debugLog += ' LastEntry = ${lastEntry.toString()}\n';
      lastEntry.end = now;
      await DBClient.instance.updateEntry(lastEntry);
      openEntriesByDate.remove(today);
    }
    // else, if there is no entry for today, get the last ever entry, and
    // add it as well for today starting at midnight
    else {
      debugLog += ' None found! Re-adding last known act today...\n';
      ActivityEntry? lastKnownEntry = await DBClient.instance.getLastEntry();
      debugLog += ' LastKnownEntry = ${lastKnownEntry.toString()}\n';
      if (lastKnownEntry == null)
        return debugLog;
      ActivityEntry newEntry = ActivityEntry(lastKnownEntry.activity,
          today, TimeOfDay(hour: 0, minute: 0), now);
      await DBClient.instance.insertEntry(newEntry);
    }

    // Either there were no open entries for today, or we removed it in the
    // if case above, so we can just update all remaining ones, which are older
    debugLog += ' Updating all open entries before today...\n';
    openEntriesByDate.entries.forEach((e) async {
      int count = e.value.length;
      // update all open entries up until last
      debugLog += ' Updating open entries of ${e.key.toSimpleString()}...\n';
      for (int i=0; i<count-1; i++) {
        ActivityEntry entry = e.value.elementAt(i);
        entry.committed = 1;
        await DBClient.instance.updateEntry(entry);
      }
      ActivityEntry lastEntryThatDay = e.value.last;
      lastEntryThatDay.end = TimeOfDay(hour: 24, minute: 0);
      lastEntryThatDay.committed = 1;
      await DBClient.instance.updateEntry(lastEntryThatDay);
    });

    debugLog += ' Retrieving all entries for today...\n';
    var _entries = await DBClient.instance.getEntriesByDate(today);
    entries.clear();
    entries.addAll(_entries);
    debugLog += ' Found ${entries.length} entries:\n';
    entries.forEach((e) { debugLog += '  ${e.toString()}\n'; });
    debugLog += '** FINISHED ${today.toSimpleString()}-${now.display()} **\n';
    return debugLog;
  }

  /// Handles switching between activities given the current state by updating entries accordingly.
  static Future<String> handleSwitch(List<ActivityEntry> entries, Activity newAct, TimeOfDay startTime, DateTime day) async {
    DateTime today = DateTime.now();
    TimeOfDay now = TimeOfDay(hour: today.hour, minute: today.minute);
    today = DateUtils.dateOnly(today);

    String debugLog = '==== LOG OF ${today.toSimpleString()}-${now.display()} ====\n';
    debugLog += 'Entered handleSwitch with entries(${entries.length}):\n';
    entries.forEach((e) { debugLog += '  ${e.toString()}\n'; });
    debugLog += ' Parameters:\n';
    debugLog += ' newAct = ${newAct.toString()}\n';
    debugLog += ' startTime = ${startTime.display()}\n';
    debugLog += ' now = ${now.display()}\n';
    debugLog += ' day = ${day.toSimpleString()}\n';
    debugLog += await updateEntries(entries);

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
      debugLog += ' Added new ${newEntry.toString()}\n';
      entries = await DBClient.instance.getEntriesByDate(day);
      debugLog += ' Reloaded entries(today){${entries.length}}\n';
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
    debugLog += ' Refreshed entries(${entries.length})\n';
    entries.forEach((e) { debugLog += '  ${e.toString()}\n'; });
    debugLog += '==== END LOG ${today.toSimpleString()}-${now.display()} ====\n';
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