import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_eazytime/partial_pie_chart.dart';
import 'package:flutter_eazytime/stacked_bar_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'activity.dart';

void main() {
  runApp(EazyTime());
}

class EazyTime extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.indigo, backgroundColor: Colors.white),
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
  int _hour = 12;
  int _minute = 34;
  TextEditingController _textController = TextEditingController();
  int _selectedActivityIndex = 0;
  PageController _pageController = PageController(initialPage: 1);

  List<String> _activities = <String>[
    "Work",
    "Sports",
    "Eat",
    "Sleep",
    "Shower"
  ];
  List<Activity> _entries = <Activity>[
    Activity('Sleep', Colors.blue.shade300, TimeOfDay(hour: 0, minute: 0),
        TimeOfDay(hour: 7, minute: 0)),
    Activity('Eat', Colors.red.shade300, TimeOfDay(hour: 7, minute: 0),
        TimeOfDay(hour: 8, minute: 0)),
    Activity('Work', Colors.green.shade300, TimeOfDay(hour: 8, minute: 0),
        TimeOfDay(hour: 10, minute: 0)),
    Activity('Shower', Colors.amber.shade300, TimeOfDay(hour: 10, minute: 0),
        TimeOfDay(hour: 11, minute: 20)),
    Activity('Eat', Colors.red.shade300, TimeOfDay(hour: 11, minute: 20),
        TimeOfDay(hour: 13, minute: 0)),
    Activity('Work', Colors.green.shade300, TimeOfDay(hour: 13, minute: 0),
        TimeOfDay(hour: 16, minute: 30)),
  ];
  static List<Color> _colors = <Color>[
    Colors.purple,
    Colors.pink,
    Colors.red,
    Colors.deepOrange,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.blue,
    Colors.deepPurple
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PageView(
        scrollDirection: Axis.horizontal,
        controller: _pageController,
        children: [
          Center(
              child: SingleChildScrollView(
                  child: CustomText('Yoo, this is history!'))),
          Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  height: 100,
                  child: buildTimeRow(context),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: TextButton(
                      child: Text('Select'),
                      onPressed: () async {
                        TimeOfDay? picked = await showTimePicker(
                            context: context, initialTime: TimeOfDay.now());
                        _hour = picked!.hour;
                        _minute = picked.minute;
                        setState(() {});
                      }),
                ),
                ElevatedButton(
                    onPressed: () {
                      TimeOfDay time = TimeOfDay.now();
                      _hour = time.hour;
                      _minute = time.minute;
                      setState(() {});
                    },
                    child: Text('Now'))
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      child: Text('Manage Activities'),
                      onPressed: () => {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Add Activity'),
                                    content: TextFormField(
                                        controller: _textController),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        child: Text('Add'),
                                        onPressed: () {
                                          if (_textController.text.isNotEmpty) {
                                            _activities
                                                .add(_textController.text);
                                            setState(() {});
                                            _textController.text = "";
                                          }
                                          Navigator.pop(context);
                                        },
                                      )
                                    ],
                                  );
                                })
                          }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: ElevatedButton(
                        onPressed: () {
                          // Update current activity
                          TimeOfDay _selTime =
                              TimeOfDay(hour: _hour, minute: _minute);
                          TimeOfDay _now = TimeOfDay.now();
                          String _selectedActivity =
                              _activities[_selectedActivityIndex];
                          // If selected Time is in future alert User
                          if (_now.isBefore(_selTime)) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Info'),
                                    content: Text(
                                        'Selected time lies in the future!'),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Oh okay'))
                                    ],
                                  );
                                });
                            return;
                          }
                          // Check if selected Time is within a different entry
                          int _idx = isWithinPreviousEntry(_selTime);
                          if (_idx >= 0) {
                            // adjust entries accordingly, i.e. split the one its in
                            _entries[_idx].end = _selTime;
                            // remove all later entries
                            for (int i = _idx + 1; i < _entries.length; i++)
                              _entries.removeAt(i);
                          }
                          if (_entries.isNotEmpty) {
                            Activity _current = _entries.last;

                            // update current activity
                            int _lastEntryActivityIndex =
                                _activities.indexOf(_current.name);
                            if (_lastEntryActivityIndex ==
                                _selectedActivityIndex) {
                              _current.end = TimeOfDay.now();
                              return;
                            }
                          }
                          Activity _new = Activity(
                              _activities[_selectedActivityIndex],
                              _colors[_entries.length % _colors.length]);
                          _new.start = _selTime;
                          _new.end = _now;
                          _entries.add(_new);

                          setState(() {});
                        },
                        child: Text('Set Selected')),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        showDebugInfo(context);
                      },
                      child: Text('!'))
                ],
              ),
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
                          color: Colors.white,
                          child: SizedBox(
                              width: 500,
                              height: 300,
                              child: buildPieChart(context))),
                      Container(
                          alignment: Alignment.center,
                          color: Colors.white,
                          child: SizedBox(
                              width: 200,
                              height: 300,
                              child: buildStackedChart(context))),
                    ],
                  ),
                ),
              )),
            ],
          ),
          Center(child: CustomText('Yoo welcome, this alltime stats!')),
        ],
      ),
    );
  }

  Widget? buildPieChart(BuildContext context) {
    if (_entries.isEmpty) return null;
    return PartialPieChart(getChartData(), getPassedFractionOfDay(),
        animate: false);
  }

  int isWithinPreviousEntry(TimeOfDay time) {
    if (_entries.isEmpty) return -1;
    for (int i = 0; i < _entries.length; i++) {
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

  Widget? buildStackedChart(BuildContext context) {
    if (_entries.isEmpty) return null;
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

  Widget buildTimeRow(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomText('Start Time', fontSize: 10.0, letterSpacing: 6.0),
        Row(
          children: [
            CustomText(_hour.toString().padLeft(2, '0')),
            CustomText(':'),
            CustomText(_minute.toString().padLeft(2, '0')),
          ],
        ),
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
        children: _activities.map((e) => CustomText(e)).toList(),
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

class CustomText extends Text {
  CustomText(this.data,
      {this.color = Colors.white, this.fontSize = 40, this.letterSpacing = 0})
      : super(data);
  final String data;
  final Color color;
  final double fontSize;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Text(data,
        style: TextStyle(
            color: color,
            decoration: TextDecoration.none,
            fontSize: fontSize,
            letterSpacing: letterSpacing));
  }
}

extension on TimeOfDay {
  bool isAfter(TimeOfDay other) {
    int _timeValueNow = this.hour * 60 + this.minute;
    int _timeValueOther = other.hour * 60 + other.minute;
    return _timeValueNow > _timeValueOther;
  }

  bool isBefore(TimeOfDay other) {
    int _timeValueNow = this.hour * 60 + this.minute;
    int _timeValueOther = other.hour * 60 + other.minute;
    return _timeValueNow < _timeValueOther;
  }

  bool isSimultaneousTo(TimeOfDay other) {
    int _timeValueNow = this.hour * 60 + this.minute;
    int _timeValueOther = other.hour * 60 + other.minute;
    return _timeValueNow == _timeValueOther;
  }
}
