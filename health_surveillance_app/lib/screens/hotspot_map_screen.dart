import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart'; // 1. Import the new package

class HotspotMapScreen extends StatefulWidget {
  const HotspotMapScreen({super.key});

  @override
  State<HotspotMapScreen> createState() => _HotspotMapScreenState();
}

class _HotspotMapScreenState extends State<HotspotMapScreen> {
  late Future<List<Marker>> _markersFuture;

  // The initial camera position, centered on a general area.
  static const LatLng _initialCameraPosition = LatLng(11.6643, 78.1460); // Centered on Salem, Tamil Nadu

  @override
  void initState() {
    super.initState();
    _markersFuture = _fetchReportMarkers();
  }

  // Fetches all reports with location data and converts them to map markers
  Future<List<Marker>> _fetchReportMarkers() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('health_reports')
        .where('location', isNotEqualTo: null)
        .get();

    final List<Marker> markers = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final location = data['location'] as GeoPoint?;
      final village = data['village'] as String?;
      final caseCount = data['caseCount'] as int?;

      if (location != null) {
        markers.add(
          Marker(
            point: LatLng(location.latitude, location.longitude),
            width: 80,
            height: 80,
            child: Tooltip(
              message: '${village ?? 'Report'}\nCases: ${caseCount ?? 'N/A'}',
              child: Icon(
                Icons.location_pin,
                color: Colors.red.shade700,
                size: 40,
              ),
            ),
          ),
        );
      }
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Outbreak Hotspot Map')),
      body: FutureBuilder<List<Marker>>(
        future: _markersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading map data: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Feather.map_pin, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No location data found in reports.'),
                ],
              ),
            );
          }

          final markers = snapshot.data!;

          return FlutterMap(
            options: const MapOptions(
              initialCenter: _initialCameraPosition,
              initialZoom: 10.0,
            ),
            children: [
              // The base map layer from OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.health_surveillance_app',
              ),
              // --- 2. Replace MarkerLayer with MarkerClusterLayerWidget ---
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 120,
                  size: const Size(40, 40),
                  markers: markers,
                  builder: (context, markers) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue,
                      ),
                      child: Center(
                        child: Text(
                          markers.length.toString(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

