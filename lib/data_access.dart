import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/widgets.dart';
import 'datetime_utils.dart';
import 'activity.dart';
import 'entry.dart';

class DBClient {

  // some of the code to making this class a singleton
  // is taken from https://stackoverflow.com/a/54223930/12213872

  DBClient._privateConstructor();
  static final DBClient instance = DBClient._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    return await openDatabase(
      join(await getDatabasesPath(), 'easyTime_database.db'),

      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE activities(activityId INTEGER PRIMARY KEY, name TEXT, color INTEGER, isActive INTEGER DEFAULT 0);'
        );
        await db.execute(
          'CREATE TABLE entries(entryId INTEGER PRIMARY KEY, activityId INTEGER, date TEXT, startTime TEXT, endTime TEXT);'
        );
      },

      onUpgrade: (db, oldVer, newVer) async {
        return await db.execute(
            'CREATE TABLE entries(entryId INTEGER PRIMARY KEY, activityId INTEGER, date TEXT, startTime TEXT, endTime TEXT);'
        );
      },

      version: 3,
    );
  }

  Future<int> insertActivity(Activity activity) async {
    final Database db = await database;

    Activity? existingActivity = await existsActivity(activity);
    if (existingActivity != null) {
      if (existingActivity.isActive == 1) return existingActivity.id!;
      else {
        existingActivity.isActive = 1;
        await updateActivity(existingActivity);
        return existingActivity.id!;
      }
    }

    return await db.insert('activities', activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,);
  }
  
  Future<Activity?> existsActivity(Activity activity) async {
    final Database db = await database;

    List<Map<String, dynamic>> result =
      await db.rawQuery('SELECT * FROM activities WHERE name = ?', [activity.name]);

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
    activity.isActive = 0;
    await updateActivity(activity);
  }

  Future<void> deleteActivityByName(String name) async {
    final Database db = await database;

    await db.delete('activities', where: "name = ?", whereArgs: [name]);
  }

  Future<void> deleteAllActivities() async {
    final Database db = await database;

    await db.rawQuery('delete from activities');
  }

  Future<Activity> getActivityById(int id) async {
    final Database db = await database;

    List<Map<String, dynamic>> map = await db.rawQuery('SELECT * from activities WHERE activityId = ?', [id]);

    return Activity(map[0]['name'], map[0]['color'], map[0]['activityId'], map[0]['isActive']);
  }

  Future<Activity> getActivityByName(String name) async {
    final Database db = await database;

    List<Map<String, dynamic>> map = await db.rawQuery('SELECT * from activities WHERE name = ?', [name]);

    return Activity(map[0]['name'], map[0]['color'], map[0]['activityId'], map[0]['isActive']);
  }

  Future<int> getActiveActivityCount() async {
    List<Activity> activeOnes = await getActiveActivities();
    return activeOnes.length;
  }
  
  Future<List<Activity>> getAllActivities() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('activities');

    return List.generate(maps.length, (i) {
      return Activity(
          maps[i]['name'],
          maps[i]['color'],
          maps[i]['activityId'],
          maps[i]['isActive']
      );
    });
  }

  Future<List<Activity>> getActiveActivities() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT * FROM activities WHERE isActive = ?', [1]);

    return List.generate(maps.length, (i) {
      return Activity(
          maps[i]['name'],
          maps[i]['color'],
          maps[i]['activityId'],
          maps[i]['isActive']
      );
    });
  }

  Future<void> deleteEntriesByDateString(String date) async {
    final Database db = await database;

    await db.delete('entries', where: "date = ?", whereArgs: [date]);
  }

  Future<void> deleteEntriesByDate(DateTime date) async {
    final Database db = await database;

    String dateString = DateTimeUtils.dateToString(date);

    await db.delete('entries', where: "date = ?", whereArgs: [dateString]);
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

    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * '
        'FROM entries INNER JOIN activities ON activities.activityId = entries.activityId');

    List<ActivityEntry> result = List.generate(maps.length, (i) {
      return ActivityEntry(
        Activity(maps[i]['name'], maps[i]['color'], maps[i]['activityId'], maps[i]['isActive']),
        DateTime.parse(maps[i]['date']),
        DateTimeUtils.parseTime(maps[i]['startTime']),
        DateTimeUtils.parseTime(maps[i]['endTime']),
        maps[i]['activityId'],
        maps[i]['entryId']
      );
    });
    return result;
  }

  Future<List<ActivityEntry>> getEntriesByDate(DateTime date) async {
    final Database db = await database;

    String dateString = DateTimeUtils.dateToString(date);

    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * '
        'FROM entries INNER JOIN activities ON activities.activityId = entries.activityId '
        'WHERE date = ?', [dateString]);

    List<ActivityEntry> result = List.generate(maps.length, (i) {
      return ActivityEntry(
          Activity(maps[i]['name'], maps[i]['color'], maps[i]['activityId'], maps[i]['isActive']),
          DateTime.parse(maps[i]['date']),
          DateTimeUtils.parseTime(maps[i]['startTime']),
          DateTimeUtils.parseTime(maps[i]['endTime']),
          maps[i]['activityId'],
          maps[i]['entryId']
      );
    });

    return result;
  }
  
  Future<String> inspectDatabase() async {
    final Database db = await database;
    String result = 'Db contents: \n';
    
    List<Activity> acts = await getAllActivities();
    List<ActivityEntry> entries = await getEntries();

    acts.forEach((element) { result += element.toString() + "\n"; });
    entries.forEach((element) { result += element.toString() + "\n"; });
    return result;
  }
}