// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

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
          centerTitle: true,
          title: const Text('Patient X'),
        ),
        body:
            Center(
              child: Column(
                children: [
                  Container(
                      padding: const EdgeInsets.all(100),
                      child: Graph()
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      MiniInfo(above: "Above1", below: "Below1"),
                      MiniInfo(above: "Above2", below: "Below2"),
                    ],
                  )
                ],
              )
            ),
      ),
    );
  }
}

class Graph extends StatelessWidget {
  final List<TremorData> chartData = [
    TremorData(DateTime.utc(2022, 1, 1), 35),
    TremorData(DateTime.utc(2022, 1, 2), 28),
    TremorData(DateTime.utc(2022, 1, 3), 34),
    TremorData(DateTime.utc(2022, 1, 4), 32),
    TremorData(DateTime.utc(2022, 1, 5), 40),
  ];

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat.yMMMd(),
          intervalType: DateTimeIntervalType.days,
        ),
        series: <ChartSeries>[
          // Renders line chart
          LineSeries<TremorData, DateTime>(
              dataSource: chartData,
              xValueMapper: (TremorData sales, _) => sales.date,
              yValueMapper: (TremorData sales, _) => sales.concern
          )
        ]
    );
  }
}

class MiniInfo extends StatelessWidget {
  const MiniInfo({required this.above, required this.below});
  final String above;
  final String below;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Text(above)
          ],
        ),
        Column(
          children: [
            Text(below)
          ],
        )
      ],
    );
  }

}

class TremorData {
  TremorData(this.date, this.concern);
  final DateTime date;
  final double concern;
}