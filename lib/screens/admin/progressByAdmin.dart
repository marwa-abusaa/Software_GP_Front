import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:http/http.dart' as http;

class AdminProgressPage extends StatefulWidget {
  const AdminProgressPage({Key? key}) : super(key: key);

  @override
  State<AdminProgressPage> createState() => _AdminProgressPageState();
}

class _AdminProgressPageState extends State<AdminProgressPage> {
  Map<String, dynamic> contestsData = {};
  Map<String, dynamic> creatingData = {};
  Map<String, dynamic> coursesData = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAdminProgressData();
  }

  Future<void> fetchAdminProgressData() async {
    try {
      var contestsResponse = await fetchProgressDataByType('contests');
      var creatingResponse = await fetchProgressDataByType('creating');
      var coursesResponse = await fetchProgressDataByType('courses');

      if (!contestsResponse.containsKey('error') &&
          !creatingResponse.containsKey('error') &&
          !coursesResponse.containsKey('error')) {
        setState(() {
          contestsData = contestsResponse;
          creatingData = creatingResponse;
          coursesData = coursesResponse;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch admin progress data');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Admin Progress Tracker',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ourPink,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  buildChartSection("Contests Participation", contestsData),
                  buildChartSection("Creating Stories", creatingData),
                  buildChartSection("Courses Tracker", coursesData),
                ],
              ),
            ),
    );
  }

  Widget buildChartSection(String title, Map<String, dynamic> data) {
    // Validate data
    if (data == null || data['data'] == null || !(data['data'] is List)) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Invalid Data Format",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    List chartData = data['data'];

    // Validate if data is empty
    if (chartData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "No Data Available",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Map months to their names
    final Map<int, String> monthNames = {
      1: "Jan",
      2: "Feb",
      3: "Mar",
      4: "Apr",
      5: "May",
      6: "Jun",
      7: "Jul",
      8: "Aug",
      9: "Sep",
      10: "Oct",
      11: "Nov",
      12: "Dec",
    };

    // Find max Y value
    double maxY = chartData
        .map((e) => e['totalCount'] as int)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    // Generate FlSpots
    List<FlSpot> spots = chartData
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              (entry.value['totalCount'] as int).toDouble(),
            ))
        .toList();

    // Create a map for easy access to tooltip data
    Map<double, String> tooltipData = {
      for (int i = 0; i < chartData.length; i++)
        i.toDouble(): monthNames[int.parse(chartData[i]['_id'])] ?? ""
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.pinkAccent,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 300,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < chartData.length) {
                          int monthNumber =
                              int.tryParse(chartData[index]['_id']) ?? 0;
                          return Text(
                            monthNames[monthNumber] ?? "",
                            style: const TextStyle(color: Colors.pinkAccent),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                minX: 0,
                maxX: chartData.length.toDouble() - 1,
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.pinkAccent,
                    barWidth: 4,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.pinkAccent.withOpacity(0.3),
                    ),
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> fetchProgressDataByType(String type) async {
    try {
      final Uri uri = Uri.parse('$progressAdmin?type=$type');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': true, 'message': 'Failed to fetch data'};
      }
    } catch (error) {
      return {'error': true, 'message': 'An error occurred: $error'};
    }
  }
}
