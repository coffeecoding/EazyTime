import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_eazytime/partial_pie_chart.dart';
import 'package:flutter_eazytime/pie_chart.dart';
import 'package:flutter_eazytime/stacked_bar_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_eazytime/styles.dart';
import 'activity.dart';
import 'activity_manager.dart';
import 'sample_data.dart' as mysamples;
import 'entry.dart';
import 'time_extensions.dart';

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
  _MyHomePageState();

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

  Map<String, ActivityHistory> _activityHistories = {};
  List<Activity> _activities = [];
  List<ActivityEntry> _entries = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PageView(
        scrollDirection: Axis.horizontal,
        controller: _pageController,
        children: [
          Scaffold(
            appBar: AppBar(
                title: Text('hist', style: NormalTextStyle()),
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
                      Expanded(
                        child: SingleChildScrollView(
                            controller: _histChartScroller,
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                                width: 500,
                                height: 300,
                                child: buildhistChart(context))),
                      ),
                      Wrap(children: buildhistLegend())
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
                              child: Center(child: buildPieChart(context)))),
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
                              onPressed: () {
                                _entries.clear();
                                setState(() { });
                              },
                              child: Text('CLR'))
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
                                onPressed: () {
                                  // Update current activity
                                  TimeOfDay _selTime =
                                      TimeOfDay(hour: _hour, minute: _minute);
                                  TimeOfDay _now = TimeOfDay.now();
                                  Activity _selectedActivity =
                                      _activities[_selectedActivityIndex];

                                  // First check for basic validity of action
                                  String _info = '';
                                  if (_now.isBefore(_selTime))
                                    _info = 'Start time lies in the future!';
                                  else if (_entries.isEmpty && _selTime.isAfter(TimeOfDay(hour: 0, minute: 0)))
                                    _info = 'First entry needs to start at 00:00!';
                                  else if (_entries.isNotEmpty && _selTime.isAfter(_entries.last.end))
                                    _info = 'Start time can\'t be after the end of the last entry!';
                                  if (_info.isNotEmpty) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Info'),
                                            content: Text(_info),
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
                                    return;
                                  }

                                  EntryHandler.handleSwitch(_entries, _selectedActivity, _selTime, _now);

                                  // Check if selected Time is within a different entry
                                  int _idx = isWithinPreviousEntry(_selTime);
                                  if (_idx >= 0) {
                                    Activity _prevEntry = _entries[_idx];

                                    if (_selTime.isSimultaneousTo(_prevEntry.start!)) {
                                      // and remove all entries
                                      _entries.clear();
                                    }
                                    else {
                                      // and remove all later entries
                                      int _entryCount = _entries.length;
                                      for (int i = _idx + 1;
                                      i < _entryCount;
                                      i++) _entries.removeAt(_idx +1);
                                      // If the previous entry is the same as the selected one ...
                                      if (_prevEntry.name == _activities[_selectedActivityIndex]) {
                                        // ... adjust its end time to now
                                        _prevEntry.end = _now;
                                        setState(() {});
                                        return;
                                      } else {
                                        // Otherwise, set its end time to the selected time
                                        _prevEntry.end = _selTime;
                                      }
                                    }
                                  }
                                  Activity _current = _entries.last;
                                  if (_selTime.isSimultaneousTo(_now)) {
                                    // update current activity
                                    int _lastEntryActivityIndex =
                                        _activities.indexOf(_current.name);
                                    if (_lastEntryActivityIndex ==
                                        _selectedActivityIndex) {
                                      _current.end = TimeOfDay.now();
                                      setState(() {});
                                      return;
                                    }
                                  }
                                  Activity _new = Activity(
                                      _activities[_selectedActivityIndex],
                                      ColorSpec.colorCircle[_entries.length %
                                          ColorSpec.colorCircle.length]);
                                  _new.start = _selTime;
                                  _new.end = _now;
                                  _entries.add(_new);
                                  setState(() {});
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

  onNavigateHere(dynamic val) {
    setState(() {});
  }

  List<Widget> buildhistLegend() {
    return _activities
        .map((a) => Container(
              height: 30,
              width: 80,
              child: Row(
                children: [
                  Container(
                      height: 15,
                      width: 15,
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      color: Colors.blue),
                  Text(a, style: LegendTextStyle(Colors.black))
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
      _data.add(new ActivityPortion(_entry.key, _entry.value.color, _total));
    }

    var _series = [
      charts.Series<ActivityPortion, int>(
        id: 'TotalActivity',
        domainFn: (ActivityPortion act, _) => _activities.indexOf(act.name),
        measureFn: (ActivityPortion act, _) => act.portion,
        data: _data,
        colorFn: (ActivityPortion act, _) =>
            charts.ColorUtil.fromDartColor(act.color),
        labelAccessorFn: (ActivityPortion act, _) => act.name,
      )
    ];

    return new SimplePieChart(_series);
  }

  Widget? buildPieChart(BuildContext context) {
    if (_entries.isEmpty)
      return Text('No entries found', style: SecondaryTextStyle(Colors.grey));
    return PartialPieChart(getChartData(), getPassedFractionOfDay(),
        animate: false);
  }

  int isWithinPreviousEntry(TimeOfDay time) {
    if (_entries.isEmpty) return -1;
    for (int i = 0; i < _entries.length-1; i++) {
      if (_entries[i].end!.isAfter(time)) return i;
    }
    return -1;
  }

  double getPassedFractionOfDay() {
    double totalFraction = 0.0;
    _entries.forEach((element) {
      totalFraction += element.fractionOfDay();
    });
    return totalFraction;
  }

  Widget? buildhistChart(BuildContext context) {
    if (_activityHistories.isEmpty)
      return Text('No hist data found.',
          style: SecondaryTextStyle(Colors.grey));
    List<charts.Series<ActivityPortion, String>> data = [];

    for (var _entry in _activityHistories.entries) {
      data.add(new charts.Series<ActivityPortion, String>(
          id: _entry.key,
          domainFn: (ActivityPortion act, _) => getDateDisplay(act.dateTime!),
          measureFn: (ActivityPortion act, _) => act.portion,
          colorFn: (ActivityPortion act, _) =>
              charts.ColorUtil.fromDartColor(_entry.value.color),
          data: _entry.value.portionSeries));
    }

    return StackedBarChart(data, animate: true);
  }

  Widget? buildStackedChart(BuildContext context) {
    if (_entries.isEmpty)
      return Text('No data found', style: SecondaryTextStyle(Colors.grey));
    var _activityTotalsMap = {};
    for (Activity _entry in _entries) {
      if (_activityTotalsMap.containsKey(_entry.name))
        _activityTotalsMap[_entry.name].portion +=
            (_entry.fractionOfDay() * 24);
      else
        _activityTotalsMap[_entry.name] = ActivityPortion(
            _entry.name, _entry.color, _entry.fractionOfDay() * 24);
    }

    List<charts.Series<ActivityPortion, String>> data = [];

    for (String _key in _activityTotalsMap.keys) {
      data.add(new charts.Series<ActivityPortion, String>(
        id: _key,
        domainFn: (__, _) => 'Today',
        measureFn: (ActivityPortion act, _) => act.portion,
        data: [_activityTotalsMap[_key]],
        colorFn: (ActivityPortion act, _) =>
            charts.ColorUtil.fromDartColor(act.color),
        labelAccessorFn: (ActivityPortion act, _) => act.name,
        displayName: _key,
      ));
    }
    return StackedBarChart(data, animate: true);
  }

  List<charts.Series<Activity, int>> getChartData() {
    return [
      new charts.Series<Activity, int>(
        id: 'Activities',
        domainFn: (Activity activity, _) => _entries.indexOf(activity),
        measureFn: (Activity activity, _) => activity.fractionOfDay(),
        data: _entries,
        colorFn: (Activity activity, _) =>
            charts.ColorUtil.fromDartColor(activity.color),
        labelAccessorFn: (Activity activity, _) => activity.name,
      )
    ];
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
                  e,
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

  void showDebugInfo(BuildContext context) {
    String info = "Debug Information: \n";
    for (Activity _entry in _entries) info += _entry.toString();
    info += "Passed: ${getPassedFractionOfDay()}";

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
