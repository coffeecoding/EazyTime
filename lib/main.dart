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

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState() {
    initData();
  }

  void initData() async {
    await _updateActivities();
    await _getEntriesForToday();
    setState(() {

    });
  }

  _MyHomePageState.withSampleData() {
    _activityHistories = mysamples.SampleData.getSampleHistory();
    _activities = mysamples.SampleData.getActivities();
    _entries = mysamples.SampleData.getSampleEntries();
  }

  int _hour = 0;
  int _minute = 0;
  int _selectedActivityIndex = 0;

  PageController _pageController = PageController(initialPage: 1);
  ScrollController _histChartScroller =
      ScrollController(keepScrollOffset: true);

  List<Activity> _activities = [];
  List<ActivityEntry> _entries = [];
  Map<String, ActivityHistory> _activityHistories = {};

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
                                child: buildHistoryChart(context))),
                      ),
                      Flexible(
                          flex: 1, child: Wrap(children: buildHistoryLegend()))
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
                          child: SizedBox(
                              width: 500,
                              height: 300,
                              child: Center(child: buildEntryChart(context)))),
                      Container(
                          alignment: Alignment.center,
                          color: Colors.white,
                          child: SizedBox(
                              width: 200,
                              height: 300,
                              child:
                                  Center(child: buildStackedChart(context)))),
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
                                await DBClient.instance.deleteEntriesByDate(DateTime.now());
                                await _getEntriesForToday();
                                await _updateActivities();
                                setState(() { });
                              },
                              child: Text('CLR')),
                          /*ElevatedButton(
                              onPressed: () async {
                                await DBClient.instance.deleteAllActivities();
                                await _updateActivities();
                                await _getEntriesForToday();
                                setState(() { });
                              },
                              child: Text('DEL'))*/
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
                                  TimeOfDay _now = TimeOfDay.now();
                                  Activity _selectedActivity =
                                      _activities[_selectedActivityIndex];

                                  await EntrySwitchHandler.handleSwitch(_entries, _selectedActivity, _selTime, _now).then(
                                  (val) async {
                                    await _updateActivities();
                                    await _getEntriesForToday();
                                    setState(() {
                                    });
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
              color: Colors.white,
              alignment: Alignment.center,
              child: SizedBox(height: 300, child: buildAllTimeChart(context)!),
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
                  child: Text('Oh okay',
                      style: ButtonTextStyle()))
            ],
          );
        });
  }

  onNavigateHere(dynamic val) async {
    await _updateActivities();
    await _getEntriesForToday();
    setState(() {});
  }

  List<Widget> buildHistoryLegend() {
    return _activities
        .map((a) => Container(
              height: 30,
              width: 80,
              child: Row(
                children: [
                  Container(
                      height: 18,
                      width: 18,
                      margin: EdgeInsets.only(right: 4.0),
                      color: Color(a.color)),
                  Text(a.name, style: LegendTextStyle(Colors.black))
                ],
              ),
            ))
        .toList();
  }

  Widget? buildAllTimeChart(BuildContext context) {
    if (_activityHistories.isEmpty)
      return Text('No data found.', style: SecondaryTextStyle(Colors.grey));

    List<ActivityPortion> _data = [];

    for (var _entry in _activityHistories.entries) {
      double _total = 0.0;
      for (var _actPortion in _entry.value.portionSeries) {
        _total += _actPortion.portion;
      }
      _data.add(new ActivityPortion(_entry.value.activity, _total));
    }

    var _series = [
      charts.Series<ActivityPortion, int>(
        id: 'TotalActivity',
        domainFn: (ActivityPortion act, _) => _activities.indexOf(act.activity),
        measureFn: (ActivityPortion act, _) => act.portion,
        data: _data,
        colorFn: (ActivityPortion act, _) =>
            charts.ColorUtil.fromDartColor(Color(act.activity.color)),
        labelAccessorFn: (ActivityPortion act, _) => act.activity.name,
      )
    ];

    return new SimplePieChart(_series);
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
        labelAccessorFn: (ActivityEntry act, _) => act.name,
      )
    ];

    double passedFractionOfDay = 0.0;
    _entries.forEach((element) {
      passedFractionOfDay += element.fractionOfDay();
    });

    return PartialPieChart(chartData, passedFractionOfDay,
        animate: false);
  }

  Widget? buildHistoryChart(BuildContext context) {
    if (_activityHistories.isEmpty)
      return Center(
        child: Text('No hist data found.',
            style: SecondaryTextStyle(Colors.grey)),
      );
    List<charts.Series<ActivityPortion, String>> data = [];

    for (var _entry in _activityHistories.entries) {
      data.add(new charts.Series<ActivityPortion, String>(
          id: _entry.key,
          domainFn: (ActivityPortion act, _) => getDateDisplay(act.dateTime!),
          measureFn: (ActivityPortion act, _) => act.portion,
          colorFn: (ActivityPortion act, _) =>
              charts.ColorUtil.fromDartColor(Color(_entry.value.color)),
          data: _entry.value.portionSeries));
    }

    return StackedBarChart(data, animate: true);
  }

  Widget? buildStackedChart(BuildContext context) {
    if (_entries.isEmpty)
      return Text('No data found', style: SecondaryTextStyle(Colors.grey));
    var _activityTotalsMap = {};
    for (ActivityEntry _entry in _entries) {
      if (_activityTotalsMap.containsKey(_entry.name))
        _activityTotalsMap[_entry.name].portion +=
            (_entry.fractionOfDay() * 24);
      else
        _activityTotalsMap[_entry.name] = ActivityPortion(
            _entry.activity, _entry.fractionOfDay() * 24);
    }

    List<charts.Series<ActivityPortion, String>> data = [];

    for (String _key in _activityTotalsMap.keys) {
      data.add(new charts.Series<ActivityPortion, String>(
        id: _key,
        domainFn: (__, _) => 'Today',
        measureFn: (ActivityPortion act, _) => act.portion,
        data: [_activityTotalsMap[_key]],
        colorFn: (ActivityPortion act, _) =>
            charts.ColorUtil.fromDartColor(Color(act.color)),
        labelAccessorFn: (ActivityPortion act, _) => act.name,
        displayName: _key,
      ));
    }
    return StackedBarChart(data, animate: true);
  }

  Widget buildStartTime(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Start Time', style: SmallSpacedTextStyle()),
        Text('${_hour.toString().padLeft(2, '0')} : ${_minute.toString().padLeft(2, '0')}', style: PrimaryTextStyle())
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

  Future<void> _updateActivities() async {
    _activities = await DBClient.instance.getActiveActivities();
    _activities.sort((a,b) => a.name.compareTo(b.name));
  }

  Future<void> _getEntriesForToday() async {
    _entries = await DBClient.instance.getEntriesByDate(DateTime.now());
  }

  void showDebugInfo(BuildContext context) async {
    String info = "Debug Information: \n";
    for (ActivityEntry _entry in _entries)
      info += _entry.toString();
    info += Colors.primaries[1].toString() + "\n";
    info += Colors.red.toString() + "\n";
    info += Colors.primaries.singleWhere((c) => c.toString() == 'MaterialColor(primary value: Color(0xfff44336))').toString() + "\n";
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
            content: Text(info),
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
