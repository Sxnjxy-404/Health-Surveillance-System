import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late Future<List<Map<String, dynamic>>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _alertsFuture = _fetchAlerts();
  }

  // --- MOCK DATA: A list of sample alerts for demonstration ---
  List<Map<String, dynamic>> _getMockAlerts() {
    return [
      {
        'title': 'High Cholera Risk Detected',
        'message': 'Multiple reports of severe diarrhea and vomiting. Please ensure water is boiled before consumption.',
        'village': 'Omalur',
        'severity': 'High',
        'timestamp': Timestamp.now(),
      },
      {
        'title': 'Contaminated Water Source',
        'message': 'The community well near the market has been reported as having cloudy and discolored water.',
        'village': 'Erode',
        'severity': 'Medium',
        'timestamp': Timestamp.fromMillisecondsSinceEpoch(Timestamp.now().millisecondsSinceEpoch - 86400000), // 1 day ago
      },
      {
        'title': 'Health Advisory: Monsoon Season',
        'message': 'Increased risk of water-borne diseases. Please maintain proper hand hygiene.',
        'village': 'All Regions',
        'severity': 'Low',
        'timestamp': Timestamp.fromMillisecondsSinceEpoch(Timestamp.now().millisecondsSinceEpoch - 172800000), // 2 days ago
      },
    ];
  }
  
  // Fetches alerts from Firestore, or returns mock data if none are found.
  Future<List<Map<String, dynamic>>> _fetchAlerts() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // If no alerts are in the database, return the sample alerts.
      return _getMockAlerts();
    }
    
    // Otherwise, return the real alerts from the database.
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _alertsFuture = _fetchAlerts();
    });
  }

  // Helper function to get a color based on severity
  Color _getSeverityColor(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'high':
        return Colors.red.shade100;
      case 'medium':
        return Colors.orange.shade100;
      case 'low':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade200;
    }
  }
  
  // Helper function to get an icon based on severity
  IconData _getSeverityIcon(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'high':
        return Feather.alert_octagon;
      case 'medium':
        return Feather.alert_triangle;
      case 'low':
        return Feather.info;
      default:
        return Feather.help_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Alerts')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching alerts: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Feather.shield, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('No Active Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Pull down to refresh.'),
              ]),
            );
          }

          final alerts = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alertData = alerts[index];
                final severity = alertData['severity'] as String?;
                final timestamp = alertData['timestamp'] as Timestamp?;
                final dateString = timestamp != null
                    ? DateFormat('dd MMM, yyyy - hh:mm a').format(timestamp.toDate())
                    : 'N/A';

                return Card(
                  color: _getSeverityColor(severity),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: Icon(_getSeverityIcon(severity), color: Colors.black54),
                    title: Text(alertData['title'] ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${alertData['message'] ?? ''}\n- Reported for: ${alertData['village'] ?? 'N/A'}\n- $dateString'),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

