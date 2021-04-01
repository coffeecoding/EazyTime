import 'package:flutter/material.dart';
import 'data_access.dart';
import 'activity.dart';
import 'entry.dart';
import 'dart:async';
import 'package:charts_flutter/flutter.dart' as charts;
import 'extensions.dart';
import 'stacked_bar_chart.dart';
import 'storage_manager.dart';
import 'styles.dart';
import 'datetime_utils.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  bool? _showAbsolutePortions = false;
  ScrollController _histChartScroller =
  ScrollController(keepScrollOffset: true);
  int historyChartBarCount = 0;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  void loadSettings() async {
    _showAbsolutePortions =
    await StorageManager.readData(SMKey.showAbsolutePortions.toString());
    if (_showAbsolutePortions == null)
      _showAbsolutePortions = true;
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child:
        Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(
            flex: 2,

            child: SwitchListTile(
                controlAffinity: ListTileControlAffinity.trailing,
                title: Text('Show absolute portions', style:
                Theme.of(context).textTheme.bodyText2),
                value: _showAbsolutePortions!,
                activeColor: Theme.of(context).accentColor,
                onChanged: (newVal) {
                  _showAbsolutePortions = newVal;
                  StorageManager.saveData(SMKey.showAbsolutePortions.toString(),
                      newVal);
                  setState(() {
                  });
                }),
          ),
          Flexible(
            flex: 9,
            child: SingleChildScrollView(
              controller: _histChartScroller,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: historyChartBarCount * 100,
                child: FutureBuilder<Widget>(
                    future: _showAbsolutePortions == true
                        ? buildHistoryChartAbsolute(context)
                        : buildHistoryChart(context),
                    builder:
                        (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                      if (snapshot.hasData) {
                        return snapshot.data!;
                      } else {
                        return Center(
                          child: SizedBox(
                            height: 40, width: 100,
                            child: CircularProgressIndicator(
                                value: 10,
                                strokeWidth: 2,
                                backgroundColor: Colors.blue,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.red)),
                          ),
                        );
                      }
                    }),
              ),
            ),
          ),
          Flexible(
              flex: 2, child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: FutureBuilder<Widget>(
                future: buildActivityLegend(context),
                builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data!;
                  } else {
                    return Text('Retrieving data ...',
                        style: SecondaryTextStyle(Colors.black));
                  }
                },
              )))
        ]));
  }

  Future<Widget> buildActivityLegend(BuildContext context) async {
    List<Activity> _activities = await DBClient.instance.getDistinctUsedActivities();
    return Wrap(children:
    _activities.map((i) => buildActivityLegendItem(context, i, i.name)).toList()
    );
  }

  List<Widget> buildActivityPortionLegend(BuildContext context, List<ActivityEntry> entries) {
    Map<String, ActivityPortion> map = getPortionsByName(entries);
    return map.entries
        .map((e) => buildActivityLegendItem(context, e.value,
        '${e.value.name} ${(e.value.portion * 100 / 24).toStringAsFixed(1)} %'))
        .toList();
  }

  /// Parameter text is not necessary if we only want to display the name of
  /// the activity. However, for some legends we may want to display additional
  /// information such as percentage of day in the stacked chart for today.
  Widget buildActivityLegendItem(BuildContext context, IActivityProperties activity, String text) {
    return Container(
      height: 30,
      width: 90,
      child: Row(
        children: [
          Container(
              height: 18,
              width: 18,
              margin: EdgeInsets.only(right: 4.0),
              color: Color(activity.color)),
          Text(text, style: Theme.of(context).textTheme.headline4)
        ],
      ),
    );
  }

  Future<Widget> buildHistoryChartAbsolute(BuildContext context) async {
    // This method is commented as it does quite a bit of data transformation.
    // Get all existing entries from db.
    List<ActivityEntry> allEntries = await DBClient.instance.getAllEntries();

    // Group entries by date.
    Map<DateTime, List<ActivityEntry>> entriesByDate =
    allEntries.groupBy<DateTime>((e) => DateUtils.dateOnly(e.date));

    // For each date, get the absolute portions for each activity.
    Map<DateTime, List<ActivityPortion>> portionsByDate = {};
    entriesByDate.entries.forEach((e) {
      Map<String, ActivityPortion> portionByName = getPortionsByName(e.value);
      List<ActivityPortion> portions = portionByName.values.toList();
      portionsByDate.putIfAbsent(e.key, () => portions);
    });

    // Get a list of all portions from all days.
    List<ActivityPortion> allPortions =
    portionsByDate.values.reduce((all, list) => all + list);

    // Group list of all portions by activity name, so that we get the data in
    // the form that charts package needs to plot the stacked bar graph. That
    // is, for each activity, a series of portions, each associated with a date.
    Map<String, List<ActivityPortion>> portionSeriesByName =
    allPortions.groupBy<String>((portion) => portion.name);

    // Update hist chart bar count
    historyChartBarCount = entriesByDate.keys.length;

    // Declare and fill the data structure needed to plot the data at hand.
    List<charts.Series<ActivityPortion, String>> data = [];
    for (var entry in portionSeriesByName.entries) {
      data.add(new charts.Series<ActivityPortion, String>(
          id: entry.key,
          domainFn: (ActivityPortion act, _) => act.dateTime!.toSimpleString(),
          measureFn: (ActivityPortion act, _) => act.portion,
          colorFn: (ActivityPortion act, _) =>
              charts.ColorUtil.fromDartColor(Color(act.color)),
          data: entry.value));
    }

    return StackedBarChart(data, animate: true);
  }

  Future<Widget> buildHistoryChart(BuildContext context) async {
    // This method is commented as it does quite a bit of data transformation.
    // Get all existing entries from db.
    List<ActivityEntry> allEntries = await DBClient.instance.getAllEntries();

    // Group entries by date.
    Map<DateTime, List<ActivityEntry>> entriesByDate =
    allEntries.groupBy<DateTime>((e) => DateUtils.dateOnly(e.date));
    // Update hist chart bar count
    historyChartBarCount = entriesByDate.keys.length;

    // Declare and fill the data structure needed to plot the data at hand.
    List<charts.Series<ActivityEntry, String>> data = [];
    for (var entry in entriesByDate.entries) {
      data.add(new charts.Series<ActivityEntry, String>(
          id: entry.key.toSimpleString(),
          domainFn: (ActivityEntry act, _) => act.date.toSimpleString(),
          measureFn: (ActivityEntry act, _) => act.fractionOfDay() * 24,
          colorFn: (ActivityEntry act, _) =>
              charts.ColorUtil.fromDartColor(Color(act.color)),
          data: entry.value));
    }

    return StackedBarChart(data, animate: true);
  }
}
