import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geolocator/geolocator.dart'; // Import the geolocator package

class NewReportScreen extends StatefulWidget {
  const NewReportScreen({super.key});

  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _villageController = TextEditingController();
  final _casesController = TextEditingController();
  final _totalPopulationController = TextEditingController();
  final _notesController = TextEditingController();
  final _otherSymptomController = TextEditingController();

  // State variables for selections
  Position? _currentPosition; // State variable to hold the captured location
  bool _isGettingLocation = false;
  final List<String> _selectedSymptoms = [];
  String? _symptomSeverity;
  String? _waterSource;
  String? _waterOdor;
  String? _waterAppearance;
  bool _isLoading = false;

  // Options lists
  final List<String> _symptomOptions = [
    'Diarrhea', 'Vomiting', 'Fever', 'Abdominal Pain', 'Nausea', 'Headache', 'Dehydration', 'Fatigue',
  ];
  final List<String> _severityOptions = ['Mild', 'Moderate', 'Severe'];
  final List<String> _sourceOptions = ['Community Well', 'Tap Water', 'River/Stream', 'Borewell', 'Other'];
  final List<String> _odorOptions = ['Normal', 'Unusual', 'Chemical', 'Earthy'];
  final List<String> _appearanceOptions = ['Clear', 'Cloudy', 'Discolored', 'Foamy'];

  @override
  void dispose() {
    _villageController.dispose();
    _casesController.dispose();
    _totalPopulationController.dispose();
    _notesController.dispose();
    _otherSymptomController.dispose();
    super.dispose();
  }

  // Method to get the device's current location
  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied')));
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')));
        return;
      }
      _currentPosition = await Geolocator.getCurrentPosition();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  void _addCustomSymptom() {
    final customSymptom = _otherSymptomController.text.trim();
    if (customSymptom.isNotEmpty && !_selectedSymptoms.contains(customSymptom)) {
      setState(() {
        _selectedSymptoms.add(customSymptom);
        _otherSymptomController.clear();
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one symptom.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in.");

      await FirebaseFirestore.instance.collection('health_reports').add({
        'reporterId': user.uid,
        'reporterEmail': user.email,
        'village': _villageController.text.trim(),
        'caseCount': int.tryParse(_casesController.text.trim()) ?? 0,
        'totalPopulation': int.tryParse(_totalPopulationController.text.trim()),
        'symptoms': _selectedSymptoms,
        'symptomSeverity': _symptomSeverity,
        'waterSource': _waterSource,
        'waterOdor': _waterOdor,
        'waterAppearance': _waterAppearance,
        'notes': _notesController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        // Save location as a GeoPoint object in Firestore
        'location': _currentPosition != null
            ? GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude)
            : null,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted successfully!'), backgroundColor: Colors.green));
      if (mounted) Navigator.of(context).pop();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit report: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Health Report')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                title: 'Location & Population',
                icon: Feather.map_pin,
                child: Column(
                  children: [
                    TextFormField(controller: _villageController, decoration: const InputDecoration(labelText: 'Village / Community Name *'), validator: (v) => v!.isEmpty ? 'Required' : null),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _casesController, decoration: const InputDecoration(labelText: 'Affected Cases *'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null)),
                        const SizedBox(width: 16),
                        Expanded(child: TextFormField(controller: _totalPopulationController, decoration: const InputDecoration(labelText: 'Total Population'), keyboardType: TextInputType.number)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Clinical Assessment',
                icon: Feather.activity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Observed Symptoms *', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _symptomOptions.map((s) => FilterChip(label: Text(s), selected: _selectedSymptoms.contains(s), onSelected: (sel) => setState(() => sel ? _selectedSymptoms.add(s) : _selectedSymptoms.remove(s)))).toList(),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _otherSymptomController,
                      decoration: InputDecoration(
                        labelText: 'Other Symptoms',
                        hintText: 'Type symptom and press Add',
                        suffixIcon: IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _addCustomSymptom),
                      ),
                      onFieldSubmitted: (_) => _addCustomSymptom(),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(initialValue: _symptomSeverity, decoration: const InputDecoration(labelText: 'Symptom Severity', border: OutlineInputBorder()), items: _severityOptions.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(), onChanged: (newValue) => setState(() => _symptomSeverity = newValue)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Environmental Data',
                icon: Feather.droplet,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(initialValue: _waterSource, decoration: const InputDecoration(labelText: 'Primary Water Source'), items: _sourceOptions.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(), onChanged: (newValue) => setState(() => _waterSource = newValue)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(initialValue: _waterOdor, decoration: const InputDecoration(labelText: 'Water Odor'), items: _odorOptions.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(), onChanged: (newValue) => setState(() => _waterOdor = newValue)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(initialValue: _waterAppearance, decoration: const InputDecoration(labelText: 'Water Appearance'), items: _appearanceOptions.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(), onChanged: (newValue) => setState(() => _waterAppearance = newValue)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // --- New Section Card for GPS Location ---
              _buildSectionCard(
                title: 'GPS Location',
                icon: Feather.crosshair,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_currentPosition != null)
                      Text(
                        'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Long: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      )
                    else
                      const Text('No location captured yet.', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: _isGettingLocation
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Feather.map_pin),
                      label: const Text('Get Current Location'),
                      onPressed: _isGettingLocation ? null : _getCurrentLocation,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(controller: _notesController, decoration: const InputDecoration(labelText: 'Additional Notes'), maxLines: 3),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isLoading ? null : _submitReport, child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Report'))),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build the styled section cards
  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

