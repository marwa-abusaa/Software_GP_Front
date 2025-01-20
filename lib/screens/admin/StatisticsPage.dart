import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_1/screens/admin/adminservices.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Map<String, dynamic>? genderStats;
  List<Map<String, dynamic>>? userAgeStats;
  List<Map<String, dynamic>>? supervisorAgeStats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGenderData();
    fetchAgeData();
  }

  // Fetch gender statistics
  void fetchGenderData() async {
    try {
      final stats = await fetchGenderStatistics();
      setState(() {
        genderStats = stats['data'];
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching gender stats: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchAgeData() async {
    try {
      // Fetch data for user and supervisor
      final userStats = await fetchAgeStatistics('user');
      final supervisorStats = await fetchAgeStatistics('supervisor');

      // Update the state with the correct data
      setState(() {
        userAgeStats = userStats; // Directly assign the list
        supervisorAgeStats = supervisorStats; // Directly assign the list
      });
    } catch (e) {
      print("Error fetching age stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Statistics', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal, // Updated color for the AppBar
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading data...', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Gender Statistics (Pie Chart)
                  _buildSectionTitle('Gender Distribution'),
                  const SizedBox(height: 16),
                  if (genderStats != null)
                    SizedBox(
                      height: 250, // Set a fixed height
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: genderStats?['boys']?.toDouble() ?? 0.0,
                              title: 'Boys',
                              color: Colors.blue,
                              radius: 50,
                            ),
                            PieChartSectionData(
                              value: genderStats?['girls']?.toDouble() ?? 0.0,
                              title: 'Girls',
                              color: Colors.pink,
                              radius: 50,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    _buildErrorMessage('Failed to load gender statistics'),

                  const SizedBox(height: 40),
                  // Age Statistics (User Role Bar Chart)
                  _buildSectionTitle('Age Distribution (User)'),
                  const SizedBox(height: 16),
                  if (userAgeStats != null && userAgeStats!.isNotEmpty)
                    SizedBox(
                      height: 250, // Set a fixed height for the bar chart
                      child: BarChart(
                        BarChartData(
                          borderData: FlBorderData(show: false),
                          titlesData: const FlTitlesData(show: true),
                          gridData: const FlGridData(
                              show: true, horizontalInterval: 1),
                          barGroups:
                              userAgeStats!.map<BarChartGroupData>((ageStat) {
                            final age = ageStat['_id'];
                            final count = ageStat['count'];
                            return BarChartGroupData(
                              x: age,
                              barRods: [
                                BarChartRodData(
                                  toY: count.toDouble(),
                                  color: Colors.green,
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  else
                    _buildErrorMessage(
                        'Failed to load age statistics for users'),

                  const SizedBox(height: 40),

                  // Age Statistics (Supervisor Role Bar Chart)
                  _buildSectionTitle('Age Distribution (Supervisor)'),
                  const SizedBox(height: 16),
                  if (supervisorAgeStats != null &&
                      supervisorAgeStats!.isNotEmpty)
                    SizedBox(
                      height: 250, // Set a fixed height for the bar chart
                      child: BarChart(
                        BarChartData(
                          borderData: FlBorderData(show: false),
                          titlesData: const FlTitlesData(show: true),
                          gridData: const FlGridData(
                              show: true, horizontalInterval: 1),
                          barGroups: supervisorAgeStats!
                              .map<BarChartGroupData>((ageStat) {
                            final age = ageStat['_id'];
                            final count = ageStat['count'];
                            return BarChartGroupData(
                              x: age,
                              barRods: [
                                BarChartRodData(
                                  toY: count.toDouble(),
                                  color: Colors.orange,
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  else
                    _buildErrorMessage(
                        'Failed to load age statistics for supervisors'),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.teal, // Color to match the app's theme
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
