import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/models/chartModel.dart';

class ProgressTrackerPage extends StatelessWidget {
  final List<ProgressData> readingData;
  final List<ProgressData> creatingData;
  final List<ProgressData> coursesData;

  ProgressTrackerPage({
    required this.readingData,
    required this.creatingData,
    required this.coursesData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offwhite,
      appBar: AppBar(
        title: const Text(
          'Progress Tracker',
          style: TextStyle(color: ourPink),
        ),
        backgroundColor: offwhite,
        iconTheme: const IconThemeData(color: ourPink),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildChartSection("Reading Stories", readingData),
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
        Container(
          height: 200,
          padding: const EdgeInsets.all(8.0),
          child: BarChart(
            BarChartData(
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
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
