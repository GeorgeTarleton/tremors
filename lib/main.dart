// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

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

Future<InputData> fetchData() async {
  final response = await http.get(Uri.parse("https://localhost:8080/get"));

  if (response.statusCode == 200) {
    return InputData.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to load data");
  }
}

class InputData {
  final int id;
  final int shakiness;
  final int concern;
  final double stddev;
  final DateTime date;

  const InputData({
    required this.id,
    required this.shakiness,
    required this.concern,
    required this.stddev,
    required this.date,
  });

  factory InputData.fromJson(Map<String, dynamic> json) {
    return InputData(
        id: json["id"],
        shakiness: json["shakiness"],
        concern: json["concern"],
        stddev: json["stddev"],
        date: DateTime.utc(json["year"], json["month"], json["day"]),
    );
  }
}

class TremorData {
  TremorData(this.date, this.concern);
  final DateTime date;
  final double concern;
}