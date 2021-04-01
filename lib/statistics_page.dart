import 'package:flutter/material.dart';
import 'data_access.dart';
import 'activity.dart';
import 'entry.dart';
import 'dart:async';
import 'package:charts_flutter/flutter.dart' as charts;
import 'extensions.dart';
import 'pie_chart.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {

  Map<String, double> weeklyHoursByActivity = {};
  Map<String, double> dailyHoursByActivity = {};
  List<ActivityPortion> totalPortions = [];

  @override
  void initState() {
    super.initState();
    loadWeeklyStatistics();
    loadDailyStatistics();
    loadTotalPortions();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            title: TabBar(
              tabs: [
                Tab(text: 'All Time'),
                Tab(text: 'Weekly'),
                Tab(text: 'Daily'),
              ],
            )
        ),
        body: TabBarView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    child: FutureBuilder<Widget>(
                        future: buildAllTimeChart(context),
                        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                          if (snapshot.hasData) {
                            return snapshot.data!;
                          } else {
                            return Text('Retrieving data ...',
                                style: Theme.of(context).textTheme.headline2);
                          }
                        }),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Activity',
                            style: Theme.of(context).textTheme.headline5)),
                        DataColumn(label: Text('Percentage',
                            style: Theme.of(context).textTheme.headline5)),
                      ],
                      rows: buildTotalDataRows(context),
                    ),
                  ),
                ),
              ],
            ),
            DataTable(
              columns: [
                DataColumn(label: Text('Activity',
                    style: Theme.of(context).textTheme.headline5)),
                DataColumn(label: Text('Average Hours/Week',
                    style: Theme.of(context).textTheme.headline5)),
              ],
              rows: buildWeeklyDataRows(context),
            ),
            DataTable(
              columns: [
                DataColumn(label: Text('Activity',
                    style: Theme.of(context).textTheme.headline5)),
                DataColumn(label: Text('Average Hours/Day',
                    style: Theme.of(context).textTheme.headline5)),
              ],
              rows: buildDailyDataRows(context),
            ),
          ],
        ),
      ),
    );
  }

  List<DataRow> buildTotalDataRows(BuildContext context) {
    List<DataRow> rows = [];
    totalPortions.forEach((portion) {
      DataCell activityCell = DataCell(Text(portion.activity.name,
          style: Theme.of(context).textTheme.bodyText2));
      DataCell hoursCell = DataCell(Text(portion.portion.toStringAsFixed(2) +
          ' %',
          style: Theme.of(context).textTheme.bodyText2));
      DataRow row = DataRow(cells: [activityCell, hoursCell]);
      rows.add(row);
    });
    return rows;
  }

  List<DataRow> buildWeeklyDataRows(BuildContext context) {
    List<DataRow> rows = [];
    weeklyHoursByActivity.forEach((key, value) {
      DataCell activityCell = DataCell(Text(key,
          style: Theme.of(context).textTheme.bodyText2));
      DataCell hoursCell = DataCell(Text(value.toStringAsFixed(2),
          style: Theme.of(context).textTheme.bodyText2));
      DataRow row = DataRow(cells: [activityCell, hoursCell]);
      rows.add(row);
    });
    return rows;
  }

  List<DataRow> buildDailyDataRows(BuildContext context) {
    List<DataRow> rows = [];
    dailyHoursByActivity.forEach((key, value) {
      DataCell activityCell = DataCell(Text(key,
          style: Theme.of(context).textTheme.bodyText2));
      DataCell hoursCell = DataCell(Text(value.toStringAsFixed(2),
          style: Theme.of(context).textTheme.bodyText2));
      DataRow row = DataRow(cells: [activityCell, hoursCell]);
      rows.add(row);
    });
    return rows;
  }

  Future<void> loadDailyStatistics() async {
    List<ActivityEntry> entries = await DBClient.instance.getAllEntries();

    // group entries by date
    Map<DateTime, List<ActivityEntry>> entriesByDate =
    entries.groupBy<DateTime>((e) => e.date);

    // compute total amount of days, in order to compute average / day later
    int totalDays = entriesByDate.keys.length;

    // convert list of entries to list of portions
    Map<DateTime, List<ActivityPortion>> absolutePortionsByDate = {};
    entriesByDate.entries.forEach((e) {
      Map<String, ActivityPortion> portionByName = getPortionsByName(e.value);
      List<ActivityPortion> portions = portionByName.values.toList();
      absolutePortionsByDate.putIfAbsent(e.key, () => portions);
    });

    // map absolutePortionsByDate to Map<Activity, List<ActivityPortion>>
    // CAUTION: n^2 runtime complexity incoming !!!
    Map<String, List<ActivityPortion>> dailyPortionsByActivity = {};
    absolutePortionsByDate.forEach((key, value) {
      value.forEach((portion) {
        dailyPortionsByActivity.putIfAbsent((portion.activity.name), () => []);
        dailyPortionsByActivity[portion.name]!.add(portion);
      });
    });

    // Foreach activity, reduce List<ActivityPortion> to their average
    dailyHoursByActivity = dailyPortionsByActivity.map(
            (key, portions) {
          double totalHours = portions.fold(0.0,
                  (prevVal, p) => prevVal + p.portion);
          return MapEntry(key, totalHours / totalDays);
        });

    setState(() {
    });
  }

  Future<void> loadWeeklyStatistics() async {
    List<ActivityEntry> entries = await DBClient.instance.getAllEntries();

    // group entries by date
    Map<DateTime, List<ActivityEntry>> entriesByDate =
    entries.groupBy<DateTime>((e) => e.date);

    // group entries by week nr (next 7 days = next 1 week)
    Map<int, List<ActivityEntry>> entriesByWeekNr = {};
    int idx = 0;
    int totalWeeks = entriesByDate.keys.length ~/ 7;
    for (var keyValPair in entriesByDate.entries) {
      int weekNr = idx ~/ 7;
      // Partial weeks should not influence the statistics
      if (weekNr >= totalWeeks)
        break;
      entriesByWeekNr.putIfAbsent(weekNr, () => []);
      entriesByWeekNr[weekNr]!.addAll(keyValPair.value);
      idx++;
    }

    // convert list of entries to list of absolute portions for each week
    Map<int, List<ActivityPortion>> absolutePortionsByWeek = {};
    entriesByWeekNr.entries.forEach((e) {
      Map<String, ActivityPortion> portionByName = getPortionsByName(e.value);
      List<ActivityPortion> portions = portionByName.values.toList();
      absolutePortionsByWeek.putIfAbsent(e.key, () => portions);
    });

    // map absolutePortionsByWeek to Map<Activity, List<ActivityPortion>>
    // CAUTION: n^2 runtime complexity incoming !!!
    Map<String, List<ActivityPortion>> weeklyPortionsByActivity = {};
    absolutePortionsByWeek.forEach((key, value) {
      value.forEach((portion) {
        weeklyPortionsByActivity.putIfAbsent((portion.activity.name), () => []);
        weeklyPortionsByActivity[portion.name]!.add(portion);
      });
    });

    // Foreach activity, reduce List<ActivityPortion> to their average
    weeklyHoursByActivity = weeklyPortionsByActivity.map(
            (key, portions) {
          double totalHours = portions.fold(0.0,
                  (prevVal, p) => prevVal + p.portion);
          return MapEntry(key, totalHours / totalWeeks);
        });

    setState(() {
    });
  }

  Future<void> loadTotalPortions() async {
    List<ActivityEntry> entries = await DBClient.instance.getAllEntries();
    Map<String, ActivityPortion> portions = getPortionsByName(entries);

    double totalHours = 0.0;
    portions.forEach((key, value) {
      totalHours += value.portion;
    });

    totalPortions.clear();

    for (var entry in portions.entries) {
      double percentage = entry.value.portion / totalHours * 100;
      totalPortions.add(ActivityPortion(entry.value.activity, percentage));
    }

    setState(() {});
  }

  Future<Widget> buildAllTimeChart(BuildContext context) async {
    if (totalPortions.isEmpty)
      return Text('No entries found', style: Theme.of(context).textTheme.headline2);

    var _series = [
      charts.Series<ActivityPortion, int>(
        id: 'TotalActivity',
        domainFn: (ActivityPortion act, _) => act.activity.id,
        measureFn: (ActivityPortion act, _) => act.portion,
        data: totalPortions,
        colorFn: (ActivityPortion act, _) =>
            charts.ColorUtil.fromDartColor(Color(act.activity.color)),
        labelAccessorFn: (ActivityPortion act, _) =>
        '${act.activity.name}',
      )
    ];

    return SimplePieChart(_series, animate: true);
  }
}