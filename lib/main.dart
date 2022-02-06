// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/percent_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<InputData>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tremor',
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('TrembleTracker'),
        ),
        body:
        Center(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                  child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Text("Patient x", style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30
                        ),),
                      ],
                    ),
                ),
                Container(
                    padding: const EdgeInsets.fromLTRB(80, 40, 80, 80),
                    child: Graph()
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    MiniInfo(above: "Latest", below: "10"),
                    MiniInfo(above: "Gradient", below: "10"),
                  ],
                )
              ],
            )
        ),
      ),
    );
  }
}

int getGradient(List<int> values) {
  var diff = List.empty();
  for (var i = 1; i < values.length; i++) {
    diff.add(values[i] - values[i-1]);
  }

  return diff.reduce((a,b) => a + b) / diff.length;
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
            Text(above, style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 40
            ))
          ],
        ),
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircularPercentIndicator(
                radius: 70.0,
                lineWidth: 7.0,
                percent: 1.0,
                center: Text(below, style: const TextStyle(
                  fontSize: 30
                ),),
                progressColor: Colors.green,
              )
            ],
          )
        )
      ],
    );
  }

}

Future<List<InputData>> fetchData() async {
  final response = await http.get(Uri.parse("https://localhost:8080/get"));

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    List listResponse = jsonResponse["data"];

    return listResponse.map((data) => InputData.fromJson(data)).toList();
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