import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_eazytime/partial_pie_chart.dart';
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
          primarySwatch: Colors.purple, backgroundColor: Colors.white),
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
  List<String> _activities = <String>[
    "Work",
    "Sports",
    "Eat",
    "Sleep",
    "Shower"
  ];
  List<Activity> _entries = <Activity>[
    Activity('Sleep', Colors.blue, TimeOfDay(hour: 0, minute: 0),
        TimeOfDay(hour: 7, minute: 0)),
    Activity('Eat', Colors.amber, TimeOfDay(hour: 7, minute: 0),
        TimeOfDay(hour: 8, minute: 0)),
    Activity('Work', Colors.green, TimeOfDay(hour: 8, minute: 0),
        TimeOfDay(hour: 10, minute: 0)),
    Activity('Shower', Colors.lightBlue, TimeOfDay(hour: 10, minute: 0),
        TimeOfDay(hour: 11, minute: 20)),
    Activity('Eat', Colors.amber, TimeOfDay(hour: 11, minute: 20),
        TimeOfDay(hour: 13, minute: 0)),
    Activity('Work', Colors.green, TimeOfDay(hour: 13, minute: 0),
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
      child: Column(
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
          Center(
            child: LimitedBox(
              maxHeight: 200,
              maxWidth: 200,
              child: buildActivityList(context),
            ),
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
                                content:
                                    TextFormField(controller: _textController),
                                actions: <Widget>[
                                  ElevatedButton(
                                    child: Text('Add'),
                                    onPressed: () {
                                      if (_textController.text.isNotEmpty) {
                                        _activities.add(_textController.text);
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
                      int _entryCount = _entries.length;
                      TimeOfDay _selTime = TimeOfDay(hour: _hour, minute: _minute);
                      // Check if selected Time is within a different entry
                      if (isWithinPreviousEntry(_selTime)) {
                        for (Activity _entry in _entries) {
                          if
                        }
                      }
                      TimeOfDay _now = TimeOfDay.now();
                      // If selected Time is in future alert User
                      int _timeValueNow = _now.hour * 60 + _now.minute;
                      int _selTimeValue = _selTime.hour * 60 + _selTime.minute;
                      if (_timeValueNow < _selTimeValue) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Info'),
                                content:
                                    Text('Selected time lies in the future!'),
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
                      if (_entryCount > 0) {
                        Activity _current = _entries[_entryCount - 1];
                        if (_entryCount > 0) _current.end = _selTime;

                        // add new activity
                        int _lastEntryActivityIndex =
                            _activities.indexOf(_current.name);
                        if (_lastEntryActivityIndex == _selectedActivityIndex) {
                          // update current
                          _current.end = TimeOfDay.now();
                          setState(() {});
                          return;
                        }
                      }

                      Activity _new = Activity(
                          _activities[_selectedActivityIndex],
                          _colors[_entryCount % _colors.length]);
                      _new.start = _selTime;
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
              child: Container(
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: SizedBox(
                      width: 500, height: 300, child: buildChart(context)))),
        ],
      ),
    );
  }

  Widget? buildChart(BuildContext context) {
    if (_entries.isEmpty) return null;
    return PartialPieChart(getChartData(), getPassedFractionOfDay(),
        animate: false);
  }

  double getPassedFractionOfDay() {
    double totalFraction = 0.0;
    _entries.forEach((element) {
      totalFraction += element.fractionOfDay();
    });
    return totalFraction;
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
  CustomText(this.data, {this.color = Colors.white, this.fontSize = 40, this.letterSpacing = 0}) : super(data);
  final String data;
  final Color color;
  final double fontSize;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Text(data,
        style: TextStyle(color: color, decoration: TextDecoration.none, fontSize: fontSize, letterSpacing: letterSpacing));
  }
}

extension on TimeOfDay {
  bool isAfter(TimeOfDay other) {
    return false;
  }
}