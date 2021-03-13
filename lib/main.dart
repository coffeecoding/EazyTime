import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;

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
  List<String> _activities = <String>["Working", "Calisthenics", "Eating"];
  TextEditingController _textController = TextEditingController();
  int _selectedActivityIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Container(height: 100, child: buildTimeRow(context)),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextButton(
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
              ),
              ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Info'),
                            content: Text('List has ' +
                                _activities.length.toString() +
                                ' entries!'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'))
                            ],
                          );
                        });
                  },
                  child: Text('Switch')),
            ],
          ),
          Flexible(
              child: Container(
                alignment: Alignment.center,
                color: Colors.white,
                  child: SizedBox(
                    width: 350,
                      height: 180,
                      child: PartialPieChart.withSampleData()))),
        ],
      ),
    );
  }

  Widget buildTimeRow(BuildContext context) {
    return Row(
      children: [
        CustomText(_hour.toString().padLeft(2, '0')),
        CustomText(':'),
        CustomText(_minute.toString().padLeft(2, '0')),
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
}

class CustomText extends Text {
  CustomText(this.data, [this.color = Colors.white]) : super(data);
  final String data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(data,
        style: TextStyle(color: color, decoration: TextDecoration.none));
  }
}

class PartialPieChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool? animate;
  static final List<Color> chartColors = <Color>[Colors.blue.shade400, Colors.red, Colors.orange, Colors.yellow];

  PartialPieChart(this.seriesList, {this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory PartialPieChart.withSampleData() {
    return new PartialPieChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Configure the pie to display the data across only 3/4 instead of the full
    // revolution.
    return new charts.PieChart(seriesList,
        animate: animate,
        defaultRenderer: new charts.ArcRendererConfig(
            arcLength: 5 / 3 * pi,
            arcRendererDecorators: [
              new charts.ArcLabelDecorator(
                  labelPosition: charts.ArcLabelPosition.outside)
            ]));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearSales, int>> _createSampleData() {
    final data = [
      new LinearSales(0, 100),
      new LinearSales(1, 75),
      new LinearSales(2, 25),
      new LinearSales(3, 5),
    ];

    return [
      new charts.Series<LinearSales, int>(
        id: 'Sales',
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
        colorFn: (LinearSales sales, i) => charts.ColorUtil.fromDartColor(chartColors[i]),
        labelAccessorFn: (LinearSales row, _) => '${row.year}: ${row.sales}',
      )
    ];
  }
}

/// Sample linear data type.
class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}
