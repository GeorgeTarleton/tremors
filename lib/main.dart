// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/percent_indicator.dart';

void main() {
  runApp(const MyApp());
}

// final List<TremorData> chartData = [
//   TremorData(DateTime.utc(2022, 1, 1), 35),
//   TremorData(DateTime.utc(2022, 1, 2), 28),
//   TremorData(DateTime.utc(2022, 1, 3), 34),
//   TremorData(DateTime.utc(2022, 1, 4), 32),
//   TremorData(DateTime.utc(2022, 1, 5), 40),
// ];

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
    futureData.then((value) => log(value.toString()));
  }

  @override
  Widget build(BuildContext context) {
    // var concerns = chartData.map((e) => e.concern).toList();
    // var gradient = getGradient(concerns).toStringAsFixed(2);
    // var latest = concerns[concerns.length-1];
    var gradient = 1;
    var latest = 1;

    return MaterialApp(
      title: 'TrembleTracker',
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('TrembleTracker'),
        ),
        body: Center(
          child: FutureBuilder<List<InputData>>(
            future: futureData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
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
                        child: Graph(chartData: snapshot.data!.map((e) => TremorData(e.date, e.concern)).toList(),)
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MiniInfo(above: "Latest", below: "$latest"),
                        MiniInfo(above: "Gradient", below: "$gradient"),
                      ],
                    )
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              return const Text("Loading...");
            },
          ),
        ),
      ),
    );
  }
}

double getGradient(List<double> values) {
  var diff = List.generate(values.length-1, (i) => values[i+1] - values[i]);

  return diff.reduce((a,b) => a + b) / diff.length;
}

class Graph extends StatelessWidget {
  const Graph({required this.chartData});
  final List<TremorData> chartData;

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
                radius: 90.0,
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
  final response = await http.get(Uri.parse("http://172.21.121.13:8080"),
  headers: {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD",
  });

  if (response.statusCode == 200) {
    // log(response.body.toString());
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
        id: json['uid'],
        shakiness: json['shakiness'],
        concern: json['concern'],
        stddev: json['stddev'],
        date: DateTime.utc(json['year'], json['month'], json['day']),
    );
  }
}

class TremorData {
  TremorData(this.date, this.concern);
  final DateTime date;
  final int concern;
}