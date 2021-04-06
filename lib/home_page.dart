import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'activity_manager.dart';
import 'data_access.dart';
import 'activity.dart';
import 'entry.dart';
import 'entry_handler.dart';
import 'dart:async';
import 'partial_pie_chart.dart';
import 'storage_manager.dart';
import 'styles.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'time_extensions.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver, TickerProviderStateMixin {
  _HomePageState() {
    updateData(true, true);
  }

  int _hour = 0;
  int _minute = 0;
  int _selectedActivityIndex = 0;

  List<Activity> _activities = [];
  List<ActivityEntry> _entries = [];
  String lastSwitchDebugLog = "";
  
  late AnimationController watchPointerController;

  // ignore: unused_field
  Timer? _everyMinute;

  double fractionOfDayPassed() {
    TimeOfDay now = TimeOfDay.now();
    return (now.hour * 60 + now.minute) / 1440; // 1440 is minutes in a day
  }

  Future<void> updateData(bool updateEntries,
      [bool updateActivities = false]) async {
    if (updateActivities) {
      _activities = await DBClient.instance.getActiveActivities();
      _activities.sort((a, b) => a.name.compareTo(b.name));
    }
    if (updateEntries) {
      lastSwitchDebugLog += await EntrySwitchHandler.updateEntries(_entries);
    }
    if (_entries.isNotEmpty) {
      _hour = _entries.last.end.hour;
      _minute = _entries.last.end.minute;
    }
    watchPointerController.forward();
    setState(() {});
  }

  @override
  void initState() {
    watchPointerController = AnimationController(
        duration: const Duration(milliseconds: 500),
        
        vsync: this);
    super.initState();
    updateData(false, true);

    // Periodically set State
    _everyMinute = Timer.periodic(Duration(minutes: 4), (Timer t) async {
      updateData(true);
      if (_entries.isNotEmpty) {
        _hour = _entries.last.start.hour;
        _minute = _entries.last.start.minute;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: Stack(
            alignment: Alignment.center,
              children: [
            Container(
              color: Theme.of(context).backgroundColor,
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: FutureBuilder<Widget>(
                    future: buildEntryChart(context),
                    builder:
                        (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                      if (snapshot.hasData) {
                        return snapshot.data!;
                      } else {
                        return Text('Retrieving data ...',
                            style: Theme.of(context).textTheme.headline2);
                      }
                    }),
              ),
            ),
            Container(
              child: Image.asset('assets/watch.png',
              width: 120, height: 120,),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      blurRadius: 1,
                      offset: Offset(-1, -1),
                      color: Colors.white.withOpacity(0.5)
                  ),
                  BoxShadow(
                    blurRadius: 10,
                    spreadRadius: -2,
                    offset: Offset(1, 1),
                    color: Colors.black.withOpacity(0.8)
                  )
                ]
              ),
            ),
            RotationTransition(
              turns: Tween(begin: 0.0, end: fractionOfDayPassed())
                  .animate(watchPointerController),
              child: Image.asset('assets/watch_pointer.png',
                width: 120, height: 120, ),
            ),
          ]),
        ),
        Flexible(
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  height: 80,
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: buildStartTime(context),
                ),
                TextButton(
                  onPressed: () {
                    TimeOfDay time = TimeOfDay.now();
                    _hour = time.hour;
                    _minute = time.minute;
                    setState(() {});
                  },
                  child:
                      Text('Now', style: Theme.of(context).textTheme.caption),
                ),
                /*
                TextButton(
                  onPressed: () {
                    showInfoColored();
                  },
                  child: Text('Color',
                      style: Theme.of(context).textTheme.caption),
                ),*/
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                          lastSwitchDebugLog += val;
                          await updateData(true, true);
                        }).catchError((e) {
                          showInfo(e.toString());
                        });
                      },
                      child: Text('Switch',
                          style: Theme.of(context).textTheme.caption)),
                ),
              ]),
              Center(
                child: LimitedBox(
                  maxHeight: 200,
                  maxWidth: 200,
                  child: buildActivityList(context),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        child: Text('+ Activity',
                            style: Theme.of(context).textTheme.caption),
                        onPressed: () => {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ActivityManager(_activities)))
                                  .then(onNavigateHere)
                            }),
                    /*
                    TextButton(
                        onPressed: () {
                          showDebugInfo(context);
                          showInfo(lastSwitchDebugLog);
                        },
                        child: Text('DBG')),
                    TextButton(
                        onPressed: () async {
                          await DBClient.instance.deleteEntriesByDate(
                              DateUtils.dateOnly(DateTime.now()));
                          //await DBClient.instance.deleteAllActivities();
                          await updateData(true, true);
                        },
                        child: Text('CLR')),*/
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<Widget> buildEntryChart(BuildContext context) async {
    if (_entries.isEmpty)
      return Text('No entries found', style: SecondaryTextStyle(Colors.grey));

    bool showStartTimes =
        await StorageManager.readData(SMKey.showStartTimes.toString());

    List<charts.Series<ActivityEntry, int>> chartData = [
      new charts.Series<ActivityEntry, int>(
        id: 'Activities',
        domainFn: (ActivityEntry act, _) => _entries.indexOf(act),
        measureFn: (ActivityEntry act, _) => act.fractionOfDay(),
        data: _entries,
        colorFn: (ActivityEntry act, _) =>
            charts.ColorUtil.fromDartColor(Color(act.color)),
        labelAccessorFn: (ActivityEntry act, _) =>
            '${act.name}' + (showStartTimes ? ' (${act.start.display()})' : ''),
      )
    ];

    double passedFractionOfDay = 0.0;
    _entries.forEach((element) {
      passedFractionOfDay += element.fractionOfDay();
    });

    return PartialPieChart(chartData, passedFractionOfDay, animate: false);
  }

  Widget buildStartTime(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Start Time', style: Theme.of(context).textTheme.headline3),
        TextButton(
          onPressed: () async {
            TimeOfDay? picked = await showTimePicker(
                context: context, initialTime: TimeOfDay.now());
            if (picked == null) return;
            _hour = picked.hour;
            _minute = picked.minute;
            setState(() {});
          },
          child: Text(
              '${_hour.toString().padLeft(2, '0')} : ${_minute.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.bodyText1),
        )
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
            .map((e) =>
                Text(e.name, style: Theme.of(context).textTheme.bodyText1))
            .toList(),
        itemExtent: 48,
        physics: FixedExtentScrollPhysics(),
      ),
      IgnorePointer(
        child: Container(
          height: 200,
          decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    Theme.of(context).backgroundColor,
                    Theme.of(context).backgroundColor.withOpacity(0.0),
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
              color: Theme.of(context).backgroundColor,
              gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    Theme.of(context).backgroundColor.withOpacity(0.0),
                    Theme.of(context).backgroundColor,
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

  onNavigateHere(dynamic val) async {
    await updateData(true, true);
    setState(() {});
  }

  void showInfo(String text) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Info'),
            content: SingleChildScrollView(
                child:
                    Text(text, style: Theme.of(context).textTheme.headline1)),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Oh okay',
                      style: Theme.of(context).textTheme.caption))
            ],
          );
        });
  }

  void showInfoColored() {
    Color rndColor = ColorSpec.randomColor();
    String colorVal = rndColor.value.toRadixString(16);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Info'),
            content: SingleChildScrollView(
                child: Container(
                    width: 200,
                    height: 200,
                    color: rndColor,
                    child: Center(
                      child: Text(colorVal,
                          style: NormalTextStyleBold(
                              Colors.white.withOpacity(0.8))),
                    ))),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Oh okay',
                      style: Theme.of(context).textTheme.caption))
            ],
          );
        });
  }
}
