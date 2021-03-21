import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_eazytime/partial_pie_chart.dart';
import 'package:flutter_eazytime/pie_chart.dart';
import 'package:flutter_eazytime/stacked_bar_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_eazytime/styles.dart';
import 'activity.dart';
import 'activity_manager.dart';
import 'data_access.dart';
import 'sample_data.dart' as mysamples;
import 'entry.dart';
import 'entry_handler.dart';
import 'styles.dart';
import 'time_extensions.dart';
import 'extensions.dart';
import 'datetime_utils.dart';
import 'dart:async';

void main() {
  runApp(EazyTime());
}

class EazyTime extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme:
          ThemeData(primarySwatch: Colors.blue, backgroundColor: Colors.white),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        key: Key('Test'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required Key key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  _MyHomePageState() {
    updateData(true, true);
  }

  _MyHomePageState.withSampleData() {
    //_activityHistories = mysamples.SampleData.getSampleHistory();
    _activities = mysamples.SampleData.getActivities();
    _entries = mysamples.SampleData.getSampleEntries();
  }

  Future<void> updateData(bool updateEntries, [bool updateActivities = false]) async {
    if (updateActivities) {
      _activities = await DBClient.instance.getActiveActivities();
      _activities.sort((a, b) => a.name.compareTo(b.name));
    }
    if (updateEntries) {
      await EntrySwitchHandler.refreshEntries(_entries);
      _entries = await DBClient.instance.getEntriesByDate(DateTime.now());
    }
    setState(() {});
  }

  Timer? _everyMinute;

  @override
  void initState() {
    super.initState();
    updateData(true, true);

    // Periodically set State
    _everyMinute = Timer.periodic(Duration(minutes: 1), (Timer t) async {
      updateData(true);
      setState(() {
      });
    });
  }

  int _hour = 0;
  int _minute = 0;
  int _selectedActivityIndex = 0;

  PageController _pageController = PageController(initialPage: 1);
  ScrollController _histChartScroller =
      ScrollController(keepScrollOffset: true);

  List<Activity> _activities = [];
  List<ActivityEntry> _entries = [];
  //Map<String, ActivityHistory> _activityHistories = {};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PageView(
        scrollDirection: Axis.horizontal,
        controller: _pageController,
        children: [
          Scaffold(
            appBar: AppBar(
                title: Text('History', style: NormalTextStyle()),
                actions: [
                  IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        _pageController.animateToPage(1,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeOut);
                      })
                ]),
            body: Container(
                alignment: Alignment.center,
                color: Colors.white,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        flex: 2,
                        child: SingleChildScrollView(
                            controller: _histChartScroller,
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                                width: 500,
                                height: 300,
                                child: FutureBuilder<Widget>(
                                    future: buildHistoryChart(),
                                    builder:
                                        (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                                      if (snapshot.hasData) {
                                        return snapshot.data!;
                                      } else {
                                        return Text('Retrieving data ...', style: SecondaryTextStyle(Colors.black));
                                      }
                                    }),
                            ),
                        ),
                      ),
                      Flexible(
                          flex: 1,
                          child:
                              Wrap(children: buildActivityLegend(_activities)))
                    ])),
          ),
          Column(
            children: [
              Flexible(
                  child: DefaultTabController(
                length: 2,
                child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.black,
                    title: TabBar(tabs: [
                      Tab(icon: Icon(Icons.album)),
                      Tab(icon: Icon(Icons.bar_chart)),
                    ]),
                  ),
                  body: TabBarView(
                    children: [
                      Container(
                          alignment: Alignment.center,
                          child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(child: buildEntryChart(context)))),
                      Row(children: [
                        Flexible(
                          flex: 2,
                          child: Container(
                              alignment: Alignment.center,
                              child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                      child: buildStackedChart(context)))),
                        ),
                        Flexible(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: SingleChildScrollView(
                                  child: Column(
                                      children: buildActivityPortionLegend(
                                          _entries))),
                            ))
                      ]),
                    ],
                  ),
                ),
              )),
              Flexible(
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 80,
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: buildStartTime(context),
                          ),
                          TextButton(
                              child: Text('Set', style: ButtonTextStyle()),
                              onPressed: () async {
                                TimeOfDay? picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now());
                                if (picked == null) return;
                                _hour = picked.hour;
                                _minute = picked.minute;
                                setState(() {});
                              }),
                          ElevatedButton(
                              onPressed: () {
                                TimeOfDay time = TimeOfDay.now();
                                _hour = time.hour;
                                _minute = time.minute;
                                setState(() {});
                              },
                              child: Text('Now', style: ButtonTextStyle())),
                          ElevatedButton(
                              onPressed: () {
                                showDebugInfo(context);
                              },
                              child: Text('DBG')),
                          ElevatedButton(
                              onPressed: () async {
                                await DBClient.instance
                                    .deleteEntriesByDate(DateUtils.dateOnly(DateTime.now()));
                                //await DBClient.instance.deleteAllActivities();
                                await updateData(true, true);
                                setState(() {});
                              },
                              child: Text('CLR')),
                    ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Center(
                            child: TextButton(
                                onPressed: () {
                                  _pageController.animateToPage(0,
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.ease);
                                },
                                child: Icon(Icons.arrow_back_ios,
                                    color: Colors.white24))),
                        LimitedBox(
                          maxHeight: 200,
                          maxWidth: 200,
                          child: buildActivityList(context),
                        ),
                        Center(
                            child: TextButton(
                                onPressed: () {
                                  _pageController.animateToPage(2,
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.ease);
                                },
                                child: Icon(Icons.arrow_forward_ios,
                                    color: Colors.white24))),
                      ],
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                              child: Text('My Activities',
                                  style: ButtonTextStyle()),
                              onPressed: () => {
                                    Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ActivityManager(
                                                        _activities)))
                                        .then(onNavigateHere)
                                  }),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: ElevatedButton(
                                onPressed: () async {
                                  TimeOfDay _selTime =
                                      TimeOfDay(hour: _hour, minute: _minute);
                                  Activity _selectedActivity =
                                      _activities[_selectedActivityIndex];

                                  await EntrySwitchHandler.handleSwitch(
                                          _entries,
                                          _selectedActivity,
                                          _selTime,
                                          DateUtils.dateOnly(DateTime.now()))
                                      .then((val) async {
                                    await updateData(true, true);
                                    setState(() {});
                                  }).catchError((e) {
                                    showError(e.toString());
                                  });
                                },
                                child:
                                    Text('Switch', style: ButtonTextStyle())),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Scaffold(
            appBar: AppBar(
                leading: BackButton(onPressed: () {
                  _pageController.animateToPage(1,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeOut);
                }),
                title: Text('All time statistics', style: NormalTextStyle())),
            body: Container(
              height: 800,
              color: Colors.white,
              alignment: Alignment.center,
              child: FutureBuilder<Widget>(
                  future: buildAllTimeChart(),
                  builder:
                      (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!;
                    } else {
                      return Text('Retrieving data ...', style: SecondaryTextStyle(Colors.black));
                    }
                  }),
            ),
          ),
        ],
      ),
    );
  }

  void showError(String text) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Info'),
            content: Text(text),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Oh okay', style: ButtonTextStyle()))
            ],
          );
        });
  }

  onNavigateHere(dynamic val) async {
    await updateData(true, true);
    setState(() {});
  }

  List<Widget> buildActivityLegend(List<Activity> activities) {
    return activities.map((i) => buildActivityLegendItem(i, i.name)).toList();
  }

  List<Widget> buildActivityPortionLegend(List<ActivityEntry> entries) {
    Map<String, ActivityPortion> map = getPortionsByName(entries);
    return map.entries
        .map((e) => buildActivityLegendItem(e.value,
            '${e.value.name} ${(e.value.portion * 100 / 24).toStringAsFixed(1)} %'))
        .toList();
  }

  Future<Widget> buildAllTimeChart() async {
    List<ActivityEntry> entries = await DBClient.instance.getAllEntries();

    if (entries.isEmpty)
      return Text('No data found.', style: SecondaryTextStyle(Colors.grey));

    Map<String, ActivityPortion> portions = getPortionsByName(entries);

    double totalHours = 0.0;
    portions.forEach((key, value) { totalHours += value.portion; });

    List<ActivityPortion> _data = [];

    for (var entry in portions.entries) {
      double percentage = entry.value.portion / totalHours * 100;
      _data.add(ActivityPortion(entry.value.activity, percentage));
    }

    var _series = [
      charts.Series<ActivityPortion, int>(
        id: 'TotalActivity',
        domainFn: (ActivityPortion act, _) => act.activity.id,
        measureFn: (ActivityPortion act, _) => act.portion,
        data: _data,
        colorFn: (ActivityPortion act, _) =>
            charts.ColorUtil.fromDartColor(Color(act.activity.color)),
        labelAccessorFn: (ActivityPortion act, _) =>
        '${act.activity.name} ${act.portion.toStringAsFixed(1)} %',
      )
    ];

    return SimplePieChart(_series, animate: true);
  }

  Widget? buildEntryChart(BuildContext context) {
    if (_entries.isEmpty)
      return Text('No entries found', style: SecondaryTextStyle(Colors.grey));

    List<charts.Series<ActivityEntry, int>> chartData = [
      new charts.Series<ActivityEntry, int>(
        id: 'Activities',
        domainFn: (ActivityEntry act, _) => _entries.indexOf(act),
        measureFn: (ActivityEntry act, _) => act.fractionOfDay(),
        data: _entries,
        colorFn: (ActivityEntry act, _) =>
            charts.ColorUtil.fromDartColor(Color(act.color)),
        labelAccessorFn: (ActivityEntry act, _) => '${act.name} (${act.start.display()})',
      )
    ];

    double passedFractionOfDay = 0.0;
    _entries.forEach((element) {
      passedFractionOfDay += element.fractionOfDay();
    });

    return PartialPieChart(chartData, passedFractionOfDay, animate: false);
  }

  Future<Widget> buildHistoryChart() async {
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
    List<ActivityPortion> allPortions
      = portionsByDate.values.reduce((all, list) => all + list);

    // Group list of all portions by activity name, so that we get the data in
    // the form that charts package needs to plot the stacked bar graph. That
    // is, for each activity, a series of portions, each associated with a date.
    Map<String, List<ActivityPortion>> portionSeriesByName
      = allPortions.groupBy<String>((portion) => portion.name);

    // Declare and fill the data structure needed to plot the data at hand.
    List<charts.Series<ActivityPortion, String>> data = [];
    for (var entry in portionSeriesByName.entries) {
      data.add(new charts.Series<ActivityPortion, String>(
        id: entry.key,
        domainFn: (ActivityPortion act, _) => act.dateTime!.toSimpleString(),
        measureFn: (ActivityPortion act, _) => act.portion,
        colorFn: (ActivityPortion act, _) =>
            charts.ColorUtil.fromDartColor(Color(act.color)),
        data: entry.value
      ));
    }

    return StackedBarChart(data, animate: true);
  }

  Widget? buildStackedChart(BuildContext context) {
    if (_entries.isEmpty)
      return Text('No data found', style: SecondaryTextStyle(Colors.grey));
    Map<String, ActivityPortion> _activityTotalsMap =
      getPortionsByName(_entries);
    List<charts.Series<ActivityPortion, String>> data = [];

    for (String _key in _activityTotalsMap.keys) {
      data.add(new charts.Series<ActivityPortion, String>(
        id: _key,
        domainFn: (__, _) => 'Today',
        measureFn: (ActivityPortion act, _) => act.portion,
        data: [_activityTotalsMap[_key]!],
        colorFn: (ActivityPortion act, _) =>
            charts.ColorUtil.fromDartColor(Color(act.color)),
        labelAccessorFn: (ActivityPortion act, _) => act.name,
        displayName: _key,
      ));
    }
    return StackedBarChart(data, animate: true);
  }

  Map<String, ActivityPortion> getPortionsByName(List<ActivityEntry> entries) {
    Map<String, ActivityPortion> _portionByName = {};
    for (ActivityEntry _entry in entries) {
      if (_portionByName.containsKey(_entry.name))
        _portionByName[_entry.name]!.portion +=
            (_entry.fractionOfDay() * 24);
      else
        _portionByName[_entry.name] =
            ActivityPortion(_entry.activity, _entry.fractionOfDay() * 24, _entry.date);
    }
    return _portionByName;
  }

  /// Parameter text is not necessary if we only want to display the name of
  /// the activity. However, for some legends we may want to display additional
  /// information such as percentage of day in the stacked chart for today.
  Widget buildActivityLegendItem(IActivityProperties activity, String text) {
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
          Text(text, style: LegendTextStyle(Colors.black))
        ],
      ),
    );
  }

  Widget buildStartTime(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Start Time', style: SmallSpacedTextStyle()),
        Text(
            '${_hour.toString().padLeft(2, '0')} : ${_minute.toString().padLeft(2, '0')}',
            style: PrimaryTextStyle())
      ],
    );
  }

  Widget buildActivityList(BuildContext context) {
    return Stack(children: [
      ListWheelScrollView(
        key: UniqueKey(),
        controller:
            FixedExtentScrollController(initialItem: _selectedActivityIndex),
        // Without this line it doesn't update!!!
        onSelectedItemChanged: (index) => updateSelectedActivity(index),
        overAndUnderCenterOpacity: 0.75,
        diameterRatio: 1.5,
        children: _activities
            .map((e) => Text(
                  e.name,
                  style: PrimaryTextStyle(),
                ))
            .toList(),
        itemExtent: 48,
        physics: FixedExtentScrollPhysics(),
      ),
      IgnorePointer(
        child: Container(
          height: 200,
          decoration: BoxDecoration(
              color: Colors.black,
              gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black.withOpacity(0.0),
                  ],
                  stops: [
                    0.0,
                    0.45
                  ])),
        ),
      ),
      IgnorePointer(
        child: Container(
          height: 200,
          decoration: BoxDecoration(
              color: Colors.black,
              gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black,
                  ],
                  stops: [
                    0.55,
                    1
                  ])),
        ),
      ),
    ]);
  }

  void updateSelectedActivity(int index) {
    _selectedActivityIndex = index;
  }

  void showDebugInfo(BuildContext context) async {
    String info = "Debug Information: \n";
    for (ActivityEntry _entry in _entries) info += _entry.toString();
    info += Colors.primaries[1].toString() + "\n";
    info += Colors.red.toString() + "\n";
    info += Colors.primaries
            .singleWhere((c) =>
                c.toString() ==
                'MaterialColor(primary value: Color(0xfff44336))')
            .toString() +
        "\n";
    info += Colors.red.value.toString() + "\n";
    Color x = new Color(Colors.red.value);
    Color y = Colors.red;
    info += x.toString() + "\n";

    info = await DBClient.instance.inspectDatabase();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Info'),
            content: SingleChildScrollView(child: Text(info)),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('K'))
            ],
          );
        });
  }
}