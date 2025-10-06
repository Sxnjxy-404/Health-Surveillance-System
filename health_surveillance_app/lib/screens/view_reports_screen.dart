import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:health_surveillance_app/pdf_generator_service.dart'; // 1. Import the PDF service

class ViewReportsScreen extends StatefulWidget {
  const ViewReportsScreen({super.key});

  @override
  State<ViewReportsScreen> createState() => _ViewReportsScreenState();
}

class _ViewReportsScreenState extends State<ViewReportsScreen> {
  // State variables for loading, search, and data lists
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> _allReports = [];
  List<QueryDocumentSnapshot> _filteredReports = [];

  @override
  void initState() {
    super.initState();
    _fetchReports();
    _searchController.addListener(_filterReports);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetches all reports for the user from Firestore
  Future<void> _fetchReports() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('health_reports')
        .where('reporterId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();
    
    setState(() {
      _allReports = querySnapshot.docs;
      _filteredReports = _allReports;
      _isLoading = false;
    });
  }

  // Filters the list of reports based on the search query
  void _filterReports() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredReports = _allReports.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final villageName = (data['village'] as String?)?.toLowerCase() ?? '';
        return villageName.contains(query);
      }).toList();
    });
  }
  
  // Method to launch Google Maps with the given coordinates
  Future<void> _launchMaps(GeoPoint location) async {
    final lat = location.latitude;
    final long = location.longitude;
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$long');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open map application.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Submitted Reports')),
      body: Column(
        children: [
          // --- Search Bar UI ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Village Name',
                prefixIcon: const Icon(Feather.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          // --- Content Area (Loading, Empty, or List) ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredReports.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'No reports found.'
                              : 'No reports match your search.',
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchReports,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: _filteredReports.length,
                          itemBuilder: (context, index) {
                            return _buildReportTile(_filteredReports[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // Extracted widget for building each report tile
  Widget _buildReportTile(QueryDocumentSnapshot doc) {
    final reportData = doc.data() as Map<String, dynamic>;
    final timestamp = reportData['createdAt'] as Timestamp?;
    final dateString = timestamp != null ? DateFormat('dd MMM, yyyy').format(timestamp.toDate()) : 'N/A';
    final location = reportData['location'] as GeoPoint?;

    final caseCount = reportData['caseCount'];
    final totalPopulation = reportData['totalPopulation'];
    String affectedText = reportData['caseCount']?.toString() ?? '0';
    if (caseCount != null && totalPopulation != null && totalPopulation > 0) {
      final percentage = (caseCount / totalPopulation * 100).toStringAsFixed(1);
      affectedText = '$caseCount of $totalPopulation ($percentage%)';
    }

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        title: Text(
          reportData['village'] ?? 'N/A',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.primary),
        ),
        subtitle: Text(dateString, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        children: [
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildDetailRow('Affected Population', affectedText, icon: Feather.users),
          _buildDetailRow('Symptoms', (reportData['symptoms'] as List<dynamic>?)?.join(', '), icon: Feather.activity),
          _buildDetailRow('Severity', reportData['symptomSeverity'], icon: Feather.alert_triangle),
          _buildDetailRow('Water Source', reportData['waterSource'], icon: Feather.droplet),
          _buildDetailRow('Water Odor', reportData['waterOdor'], icon: Feather.wind),
          _buildDetailRow('Water Appearance', reportData['waterAppearance'], icon: Feather.eye),
          if (reportData['notes'] != null && reportData['notes'].isNotEmpty)
            _buildDetailRow('Notes', reportData['notes'], icon: Feather.file_text),
          
          if (location != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  _buildDetailRow(
                    'GPS', 
                    'Lat: ${location.latitude.toStringAsFixed(4)}, Long: ${location.longitude.toStringAsFixed(4)}', 
                    icon: Feather.crosshair
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Feather.map),
                    label: const Text('View on Map'),
                    onPressed: () => _launchMaps(location),
                  ),
                ],
              ),
            ),

          // --- 2. Add the Download Button ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextButton.icon(
              icon: const Icon(Feather.download),
              label: const Text('Download as PDF'),
              onPressed: () async {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Generating PDF...')),
                  );
                  await PdfGeneratorService.generateAndSavePdf(reportData);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to generate PDF: $e')),
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // Helper widget to display a row of data neatly
  Widget _buildDetailRow(String label, String? value, {IconData? icon}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0, bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, size: 16, color: Colors.grey.shade600) else const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

