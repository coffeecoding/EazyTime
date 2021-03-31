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
      title: 'EasyTimetracker',
      theme: ThemeData(
          textTheme: TextTheme(
            bodyText1: PrimaryTextStyle(Colors.black),
            bodyText2: NormalTextStyle(Colors.black),
            caption: ButtonTextStyle(Colors.black),
            headline1: SmallTextStyle(Colors.black),
            headline2: SecondaryTextStyle(Colors.black),
            headline3: SmallSpacedTextStyle(Colors.black),
            headline4: LegendTextStyle(Colors.black),
            headline5: NormalTextStyleBold(Colors.black)
          ),
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
          secondaryHeaderColor: Colors.black,
          primaryColor: Colors.white,
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          accentColor: Colors.blue,
          accentIconTheme: IconThemeData(color: Colors.black),
          dividerColor: Colors.grey.withOpacity(0.2)),
      darkTheme: ThemeData(
          textTheme: TextTheme(
            bodyText1: PrimaryTextStyle(Colors.white),
            bodyText2: NormalTextStyle(Colors.white),
            caption: ButtonTextStyle(Colors.white),
            headline1: SmallTextStyle(Colors.white),
            headline2: SecondaryTextStyle(Colors.white),
            headline3: SmallSpacedTextStyle(Colors.white),
            headline4: LegendTextStyle(Colors.white),
            headline5: NormalTextStyleBold(Colors.white)
          ),
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
          secondaryHeaderColor: Colors.white,
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          accentColor: Colors.blue,
          accentIconTheme: IconThemeData(color: Colors.yellow),
          dividerColor: Colors.grey.withOpacity(0.15)),
      themeMode: ThemeMode.system,
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

enum DisplayedPage { home, history, allTimeStats, help, about, preferences }

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  _MyHomePageState() : currentPage = DisplayedPage.home {
    updateData(true, true);
  }

  _MyHomePageState.withSampleData() : currentPage = DisplayedPage.home {
    //_activityHistories = mysamples.SampleData.getSampleHistory();
    _activities = mysamples.SampleData.getActivities();
    _entries = mysamples.SampleData.getSampleEntries();
  }

  int _hour = 0;
  int _minute = 0;
  int _selectedActivityIndex = 0;

  ScrollController _histChartScroller =
      ScrollController(keepScrollOffset: true);
  int historyChartBarCount = 0;

  List<Activity> _activities = [];
  List<ActivityEntry> _entries = [];

  String lastSwitchDebugLog = "";

  Timer? _everyMinute;
  DisplayedPage currentPage;

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
    setState(() {});
  }

  @override
  void initState() {
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
    Widget? _body;
    String _title = 'Today';
    switch (currentPage) {
      case DisplayedPage.home:
        {
          _title = 'Today';
          _body = buildHomePage(context);
          break;
        }
      case DisplayedPage.history:
        {
          _title = 'History';
          _body = HistoryPage();
          break;
        }
      case DisplayedPage.allTimeStats:
        {
          _title = 'All Time Statistics';
          _body = buildAllTimeStatsPage(context);
          break;
        }
      case DisplayedPage.help:
        {
          _title = 'Help Page';
          _body = buildHelpPage(context);
          break;
        }
      case DisplayedPage.about:
        {
          _title = 'About EasyTimetracker';
          _body = buildHomePage(context);
          break;
        }
      case DisplayedPage.preferences:
        {
          _title = 'Preferences';
          _body = buildHomePage(context);
          break;
        }
    }
    return SafeArea(
        child: Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            appBar: AppBar(
              title: Text(_title, style: Theme.of(context).textTheme.headline5),
            ),
            drawer: Drawer(
              elevation: 5.0,
              child: ListView(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: FractionalOffset.topCenter,
                            end: FractionalOffset.bottomCenter,
                            colors: [
                          Theme.of(context).dividerColor.withOpacity(0.1),
                          Theme.of(context).backgroundColor.withOpacity(0),
                        ],
                            stops: [
                          0.0,
                          1.0
                        ])),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Image.asset('assets/logo_strong.png',
                              height: 80, width: 120, fit: BoxFit.fitHeight),
                        ),
                        Text('EasyTimetracker',
                            style: Theme.of(context).textTheme.caption),
                        Text('Get ahold of your Time!',
                            style: Theme.of(context).textTheme.headline4),
                      ],
                    ),
                  ),
                  Divider(height: 1.0),
                  ListTile(
                      tileColor: Theme.of(context).accentColor.withOpacity(
                          currentPage == DisplayedPage.home ? 0.3 : 0),
                      leading: Icon(currentPage == DisplayedPage.home
                          ? Icons.pie_chart
                          : Icons.pie_chart_outline_sharp),
                      onTap: () {
                        currentPage = DisplayedPage.home;
                        setState(() {});
                        Navigator.pop(context);
                      },
                      title: Container(
                          alignment: Alignment.centerLeft,
                          child: Text('Today',
                              style: currentPage == DisplayedPage.home
                              ? Theme.of(context).textTheme.headline5
                              : Theme.of(context).textTheme.bodyText2))),
                  Divider(height: 1.0),
                  ListTile(
                      tileColor: Theme.of(context).accentColor.withOpacity(
                          currentPage == DisplayedPage.history ? 0.3 : 0),
                      leading: Icon(currentPage == DisplayedPage.history
                          ? Icons.bar_chart
                          : Icons.bar_chart_outlined),
                      onTap: () {
                        currentPage = DisplayedPage.history;
                        setState(() {});
                        Navigator.pop(context);
                      },
                      title: Container(
                          alignment: Alignment.centerLeft,
                          child: Text('History',
                              style: currentPage == DisplayedPage.history
                                  ? Theme.of(context).textTheme.headline5
                                  : Theme.of(context).textTheme.bodyText2))),
                  Divider(height: 1.0),
                  ListTile(
                      tileColor: Theme.of(context).accentColor.withOpacity(
                          currentPage == DisplayedPage.allTimeStats ? 0.3 : 0),
                      leading: Icon(currentPage == DisplayedPage.allTimeStats
                          ? Icons.analytics
                          : Icons.analytics_outlined),
                      onTap: () {
                        currentPage = DisplayedPage.allTimeStats;
                        setState(() {});
                        Navigator.pop(context);
                      },
                      title: Container(
                          alignment: Alignment.centerLeft,
                          child: Text('All Time Stats',
                              style: currentPage == DisplayedPage.allTimeStats
                                  ? Theme.of(context).textTheme.headline5
                                  : Theme.of(context).textTheme.bodyText2))),
                  Divider(height: 1.0),
                  ListTile(
                      tileColor: Theme.of(context).accentColor.withOpacity(
                          currentPage == DisplayedPage.preferences ? 0.3 : 0),
                      leading: Icon(currentPage == DisplayedPage.preferences
                          ? Icons.settings
                          : Icons.settings_outlined),
                      onTap: () {
                        currentPage = DisplayedPage.preferences;
                        setState(() {});
                        Navigator.pop(context);
                      },
                      title: Container(
                          alignment: Alignment.centerLeft,
                          child: Text('Preferences',
                              style: currentPage == DisplayedPage.preferences
                                  ? Theme.of(context).textTheme.headline5
                                  : Theme.of(context).textTheme.bodyText2))),
                  Divider(height: 1.0),
                  ListTile(
                      tileColor: Theme.of(context).accentColor.withOpacity(
                        currentPage == DisplayedPage.help ? 0.3 : 0),
                      leading: Icon(currentPage == DisplayedPage.help
                          ? Icons.help
                          : Icons.help_outline),
                      onTap: () {
                        currentPage = DisplayedPage.help;
                        setState(() {});
                        Navigator.pop(context);
                      },
                      title: Container(
                          alignment: Alignment.centerLeft,
                          child: Text('Help',
                              style: currentPage == DisplayedPage.help
                                  ? Theme.of(context).textTheme.headline5
                                  : Theme.of(context).textTheme.bodyText2))),
                  Divider(height: 1.0),
                  ListTile(
                      leading: Icon(currentPage == DisplayedPage.about
                          ? Icons.info
                          : Icons.info_outline),
                      onTap: () {
                        Navigator.pop(context);
                        showAboutDialog(
                          context: context,
                          applicationName: 'EasyTimetracker',
                          applicationVersion: '1.0.0',
                          applicationIcon: Icon(Icons.art_track),
                          applicationLegalese: 'Made by YousufCodes 2021\n'
                            'www.yousufcodes.com'
                        );
                      },
                      title: Container(
                          alignment: Alignment.centerLeft,
                          child: Text('About',
                              style: currentPage == DisplayedPage.about
                                  ? Theme.of(context).textTheme.headline5
                                  : Theme.of(context).textTheme.bodyText2))),
                  Divider(height: 1.0),
                ],
              ),
            ),
            body: _body));
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
                child:
                    Container(
                      width: 200,
                      height: 200,
                      color: rndColor,
                      child: Center(
                        child: Text(colorVal,
                            style: NormalTextStyleBold(Colors.white.withOpacity(0.8))),
                      )
                    )),
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

  onNavigateHere(dynamic val) async {
    await updateData(true, true);
    setState(() {});
  }

  List<Widget> buildActivityLegend(BuildContext context, List<Activity> activities) {
    return activities.map((i) => buildActivityLegendItem(context, i, i.name)).toList();
  }

  List<Widget> buildActivityPortionLegend(BuildContext context, List<ActivityEntry> entries) {
    Map<String, ActivityPortion> map = getPortionsByName(entries);
    return map.entries
        .map((e) => buildActivityLegendItem(context, e.value,
            '${e.value.name} ${(e.value.portion * 100 / 24).toStringAsFixed(1)} %'))
        .toList();
  }

  Future<Widget> buildAllTimeChart(BuildContext context) async {
    List<ActivityEntry> entries = await DBClient.instance.getAllEntries();

    if (entries.isEmpty)
      return Text('No data found.', style: Theme.of(context).textTheme.headline2);

    Map<String, ActivityPortion> portions = getPortionsByName(entries);

    double totalHours = 0.0;
    portions.forEach((key, value) {
      totalHours += value.portion;
    });

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
        labelAccessorFn: (ActivityEntry act, _) =>
            '${act.name} (${act.start.display()})',
      )
    ];

    double passedFractionOfDay = 0.0;
    _entries.forEach((element) {
      passedFractionOfDay += element.fractionOfDay();
    });

    return PartialPieChart(chartData, passedFractionOfDay, animate: false);
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

  Widget buildHomePage(BuildContext context) {
    return Column(
      children: [
        Flexible(
            child: Container(
                color: Theme.of(context).backgroundColor,
                alignment: Alignment.center,
                child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: buildEntryChart(context))))),
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
                  child: Text('Now', style: Theme.of(context).textTheme.caption),
                ),
                TextButton(
                  onPressed: () {
                    showInfoColored();
                  },
                  child: Text('Color',
                      style: Theme.of(context).textTheme.caption),
                ),
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
                        child: Text('CLR')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAllTimeStatsPage(BuildContext context) {
    return Container(
      height: 800,
      alignment: Alignment.center,
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
    );
  }

  Widget buildHelpPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text('How to use', style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.start),
          ),
          Text('This is an elaborate description in extreme detail of what this application is supposed to be used for and how exactly one goes about using it. Basically it is an app that should give the user a visual impression of where their time goes each day. This may help the user rationalise their time usage and cut out time-wasters from their daily routines. Needless to say, the benefit is only as good as the effort put up into using this app properly. Luckily, the app is designed to be as easy to use as possible and require as little time as possible. So let\'s take a look at how to use it using an example.',
              style: Theme.of(context).textTheme.bodyText2),
        ]
      ),
    );
  }
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

Future<Widget> buildActivityLegend(BuildContext context) async {
  List<Activity> _activities = await DBClient.instance.getDistinctUsedActivities();
  return Wrap(children:
    _activities.map((i) => buildActivityLegendItem(context, i, i.name)).toList()
  );
}

Map<String, ActivityPortion> getPortionsByName(List<ActivityEntry> entries) {
  Map<String, ActivityPortion> _portionByName = {};
  for (ActivityEntry _entry in entries) {
    if (_portionByName.containsKey(_entry.name))
      _portionByName[_entry.name]!.portion += (_entry.fractionOfDay() * 24);
    else
      _portionByName[_entry.name] = ActivityPortion(
          _entry.activity, _entry.fractionOfDay() * 24, _entry.date);
  }
  return _portionByName;
}

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  bool _showAbsolutePortions = false;
  ScrollController _histChartScroller =
    ScrollController(keepScrollOffset: true);
  int historyChartBarCount = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child:
        Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(
            flex: 2,
            child: CheckboxListTile(
              title: Text('Show absolute portions',
                  style: Theme.of(context).textTheme.headline1!),
              value: _showAbsolutePortions,
              activeColor: Theme.of(context).accentColor,
              checkColor: Colors.white,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (bool? newValue) {
                if (newValue == null) {
                  return;
                }
                _showAbsolutePortions = newValue;
                setState(() {});
              },
            )
          ),
          Flexible(
            flex: 9,
            child: SingleChildScrollView(
              controller: _histChartScroller,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: historyChartBarCount * 100,
                child: FutureBuilder<Widget>(
                    future: _showAbsolutePortions
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
