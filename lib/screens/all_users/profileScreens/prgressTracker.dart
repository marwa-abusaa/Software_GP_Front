import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/models/chartModel.dart';
import 'package:http/http.dart' as http;

class ProgressTrackerPage extends StatefulWidget {
  final String email;

  const ProgressTrackerPage({required this.email, Key? key}) : super(key: key);

  @override
  State<ProgressTrackerPage> createState() => _ProgressTrackerPageState();
}

class _ProgressTrackerPageState extends State<ProgressTrackerPage> {
  List<ProgressData> readingData = [];
  List<ProgressData> creatingData = [];
  List<ProgressData> coursesData = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProgressData();
  }

  Future<void> fetchProgressData() async {
    try {
      // Fetch reading data
      var readingResponse = await http.get(
        Uri.parse('$progress?email=${widget.email}&type=contests'),
      );
      var creatingResponse = await http.get(
        Uri.parse('$progress?email=${widget.email}&type=creating'),
      );
      var coursesResponse = await http.get(
        Uri.parse('$progress?email=${widget.email}&type=courses'),
      );

      if (readingResponse.statusCode == 200 &&
          creatingResponse.statusCode == 200 &&
          coursesResponse.statusCode == 200) {
        setState(() {
          readingData = (json.decode(readingResponse.body) as List)
              .map((data) => ProgressData.fromJson(data))
              .toList();
          creatingData = (json.decode(creatingResponse.body) as List)
              .map((data) => ProgressData.fromJson(data))
              .toList();
          coursesData = (json.decode(coursesResponse.body) as List)
              .map((data) => ProgressData.fromJson(data))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching progress data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offwhite,
      appBar: AppBar(
        title: const Text(
          'Progress Tracker',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: offwhite,
        iconTheme: const IconThemeData(color: ourPink),
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  buildChartSection("contests participation", readingData),
                  buildChartSection("Creating Stories", creatingData),
                  buildChartSection("Courses Tracker", coursesData),
                ],
              ),
            ),
    );
  }

  Widget buildChartSection(String title, List<ProgressData> data) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ourPink,
            ),
          ),
        ),
        data.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "No Data Available",
                  style: TextStyle(color: ourPink),
                ),
              )
            : Container(
                height: 200,
                padding: const EdgeInsets.all(8.0),
                child: BarChart(
                  BarChartData(
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: true, reservedSize: 40),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) => Text(
                            data[value.toInt()].month,
                            style: const TextStyle(color: ourPink),
                          ),
                        ),
                      ),
                    ),
                    barGroups: data
                        .asMap()
                        .entries
                        .map((entry) => BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value.count.toDouble(),
                                  color: ourPink,
                                )
                              ],
                            ))
                        .toList(),
                  ),
                ),
              ),
      ],
    );
  }
}
