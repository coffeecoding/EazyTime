import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math';

class PartialPieChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool? animate;
  final double partiality;
  static final List<Color> chartColors = <Color>[Colors.blue.shade400, Colors.red, Colors.orange, Colors.yellow];

  PartialPieChart(this.seriesList, this.partiality, {this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory PartialPieChart.withSampleData() {
    return new PartialPieChart(
      _createSampleData(),
      5 / 3,
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
            arcLength: partiality * 2 * pi,
            arcWidth: 84,
            strokeWidthPx: 0,
            arcRendererDecorators: [
              new charts.ArcLabelDecorator(
                  labelPosition: charts.ArcLabelPosition.auto,
                  outsideLabelStyleSpec: charts.TextStyleSpec(
                    fontFamily: Theme.of(context).textTheme.headline1!.fontFamily,
                    color: charts.ColorUtil.fromDartColor(Theme.of(context).textTheme.headline1!.color),
                    fontSize: Theme.of(context).textTheme.headline1!.fontSize!.toInt()),
                  leaderLineStyleSpec:
                    charts.ArcLabelLeaderLineStyleSpec(
                        length: 10.0,
                        thickness: 1,
                        color: charts.ColorUtil.fromDartColor(Colors.grey))),
            ]),
    );
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