import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

// Helper class to hold the processed data for each village
class VillageAnalyticsData {
  final String villageName;
  final int totalCases;
  final int totalPopulation;

  VillageAnalyticsData({
    required this.villageName,
    required this.totalCases,
    required this.totalPopulation,
  });
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late Future<List<VillageAnalyticsData>> _analyticsDataFuture;

  @override
  void initState() {
    super.initState();
    _analyticsDataFuture = _fetchAndProcessReportData();
  }

  // Fetches and processes data to create analytics for each village
  Future<List<VillageAnalyticsData>> _fetchAndProcessReportData() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('health_reports').get();
    
    final Map<String, Map<String, int>> villageDataAggregator = {};

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final village = data['village'] as String?;
      final caseCount = data['caseCount'] as int?;
      final totalPopulation = data['totalPopulation'] as int?;

      if (village != null && caseCount != null && totalPopulation != null && totalPopulation > 0) {
        villageDataAggregator.update(
          village,
          (value) {
            value['cases'] = (value['cases'] ?? 0) + caseCount;
            value['population'] = (value['population'] ?? 0) > totalPopulation ? value['population']! : totalPopulation;
            return value;
          },
          ifAbsent: () => {'cases': caseCount, 'population': totalPopulation},
        );
      }
    }

    final List<VillageAnalyticsData> processedData = [];
    villageDataAggregator.forEach((villageName, data) {
      processedData.add(VillageAnalyticsData(
        villageName: villageName,
        totalCases: data['cases']!,
        totalPopulation: data['population']!,
      ));
    });
    
    // Sort villages alphabetically
    processedData.sort((a, b) => a.villageName.compareTo(b.villageName));
    return processedData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Village Analytics')),
      body: FutureBuilder<List<VillageAnalyticsData>>(
        future: _analyticsDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Feather.pie_chart, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No data with population info available.'),
                ],
              ),
            );
          }

          final analyticsDataList = snapshot.data!;

          // Use a ListView of ExpansionTiles instead of a Dropdown
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: analyticsDataList.length,
            itemBuilder: (context, index) {
              final data = analyticsDataList[index];
              return Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ExpansionTile(
                  title: Text(
                    data.villageName,
                    // --- THIS IS THE UPDATED LINE ---
                    // Using a more standard style that is bold but not oversized.
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  children: [
                    _buildAnalyticsContent(data),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Widget to build the content inside the ExpansionTile
  Widget _buildAnalyticsContent(VillageAnalyticsData data) {
    final unaffectedPopulation = data.totalPopulation - data.totalCases;
    final affectedPercentage = (data.totalCases / data.totalPopulation * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: Colors.red.shade400,
                    value: data.totalCases.toDouble(),
                    title: '$affectedPercentage%',
                    radius: 30,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: Colors.green.shade400,
                    value: unaffectedPopulation.toDouble(),
                    title: '',
                    radius: 30,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegend(color: Colors.red.shade400, text: 'Affected: ${data.totalCases}'),
                const SizedBox(height: 8),
                _buildLegend(color: Colors.green.shade400, text: 'Unaffected: $unaffectedPopulation'),
                const SizedBox(height: 8),
                _buildLegend(color: Colors.grey.shade700, text: 'Total Pop: ${data.totalPopulation}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for the chart legend
  Widget _buildLegend({required Color color, required String text}) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}

