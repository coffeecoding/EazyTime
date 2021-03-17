import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/widgets.dart';
import 'datetime_utils.dart';
import 'activity.dart';
import 'entry.dart';

class DataAccessClient {

  late final Future<Database> database;

  void initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    this.database = openDatabase(
      join(await getDatabasesPath(), 'easyTime_database.db'),

      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE activities(activityId INTEGER PRIMARY KEY, name TEXT, color INTEGER, isActive INTEGER DEFAULT 0;'
          'CREATE TABLE entries(entryId INTEGER PRIMARY KEY, activityId INTEGER, date TEXT, startTime TEXT, endTime TEXT;'
        );
      },

      version: 1,
    );
  }

  Future<void> insertActivity(Activity activity) async {
    final Database db = await database;

    Activity? existingActivity = await existsActivity(activity);
    if (existingActivity != null) {
      if (existingActivity.isActive) return;
      else {
        activity.isActive = true;
        await updateActivity(activity);
        return;
      }
    }

    await db.insert('activities', activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,);
  }
  
  Future<Activity?> existsActivity(Activity activity) async {
    final Database db = await database;
    
    List<Map<String, dynamic>> result =
      await db.query('SELECT * FROM activities WHERE name = ${activity.name}');

    if (result.isNotEmpty)
      return await getActivityByName(activity.name);
    return null;
  }

  Future<void> updateActivity(Activity activity) async {
    final Database db = await database;

    await db.update('activities', activity.toMap(),
      where: "activityId = ?", whereArgs: [activity.id]);
  }

  Future<void> deleteActivity(Activity activity) async {
    final Database db = await database;

    activity.isActive = false;
    await updateActivity(activity);
  }

  Future<Activity> getActivityById(int id) async {
    final Database db = await database;

    List<Map<String, dynamic>> map = await db.query('SELECT * from activities WHERE activityId = $id');

    return Activity(map[0]['name'], map[0]['color'], map[0]['activityId'], map[0]['isActive']);
  }

  Future<Activity> getActivityByName(String name) async {
    final Database db = await database;

    List<Map<String, dynamic>> map = await db.query('SELECT * from activities WHERE name = $name');

    return Activity(map[0]['name'], map[0]['color'], map[0]['activityId'], map[0]['isActive']);
  }

  Future<int> getActiveActivityCount() async {
    final Database db = await database;

    List<Activity> activeOnes = await getActiveActivities();
    return activeOnes.length;
  }

  Future<List<Activity>> getActiveActivities() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('SELECT * '
        'FROM activities WHERE isActive = 1');

    return List.generate(maps.length, (i) {
      return Activity(
          maps[i]['name'],
          maps[i]['color'],
          maps[i]['activityId'],
          maps[i]['isActive']
      );
    });
  }

  Future<void> insertEntry(ActivityEntry entry) async {
    final Database db = await database;

    await db.insert('entries', entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateEntry(ActivityEntry entry) async {
    final Database db = await database;

    await db.update('entries', entry.toMap(),
        where: "entryId = ?", whereArgs: [entry.id]);
  }

  Future<void> deleteEntry(ActivityEntry entry) async {
    final Database db = await database;

    await db.delete('entries', where: "entryId = ?", whereArgs: [entry.id]);
  }

  Future<List<ActivityEntry>> getEntries() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('SELECT * '
        'FROM entries INNER JOIN activities ON activities.activityId = entries.activityId');

    List<ActivityEntry> result = List.generate(maps.length, (i) {
      return ActivityEntry(
        Activity(maps[i]['name'], maps[i]['color']),
        maps[i]['date'],
        maps[i]['startTime'],
        maps[i]['endTime'],
        maps[i]['activityId'],
        maps[i]['entryId']
      );
    });
    return result;
  }

  Future<List<ActivityEntry>> getEntriesByDate(DateTime date) async {
    final Database db = await database;
    String dateString = DateTimeUtils.dateToString(date);

    final List<Map<String, dynamic>> maps = await db.query('SELECT * '
        'FROM entries INNER JOIN activities ON activities.activityId = entries.activityId '
        'WHERE date = $dateString');

    List<ActivityEntry> result = List.generate(maps.length, (i) {
      return ActivityEntry(
          Activity(maps[i]['name'], maps[i]['color']),
          maps[i]['date'],
          maps[i]['startTime'],
          maps[i]['endTime'],
          maps[i]['activityId'],
          maps[i]['entryId']
      );
    });
    return result;
  }

}