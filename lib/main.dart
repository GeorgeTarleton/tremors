// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tremor',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Flutter'),
        ),
        body:
            Center(
              child: Column(
                children: [
                  Container(
                      padding: const EdgeInsets.all(100),
                      child: _graph()
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _miniInfo(),
                      _miniInfo()
                    ],
                  )
                ],
              )
            ),
      ),
    );
  }
}

Widget _graph() {
  final List<SalesData> chartData = [
    SalesData(2010, 35),
    SalesData(2011, 28),
    SalesData(2012, 34),
    SalesData(2013, 32),
    SalesData(2014, 40)
  ];

  return SfCartesianChart(
    // primaryXAxis: DateTimeAxis(),
      series: <ChartSeries>[
        // Renders line chart
        LineSeries<SalesData, int>(
            dataSource: chartData,
            xValueMapper: (SalesData sales, _) => sales.year,
            yValueMapper: (SalesData sales, _) => sales.sales
        )
      ]
  );
}

Widget _miniInfo() {
  return Column(
    children: [
      Column(
        children: const [
          Text("Above")
        ],
      ),
      Column(
        children: const [
          Text("Below")
        ],
      )
    ],
  );
}

class SalesData {
  SalesData(this.year, this.sales);
  final int year;
  final double sales;
}