import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:health_surveillance_app/screens/analytics_screen.dart';
import 'package:health_surveillance_app/screens/new_report_screen.dart';
import 'package:health_surveillance_app/screens/view_reports_screen.dart';
import 'package:health_surveillance_app/screens/alerts_screen.dart';
import 'package:health_surveillance_app/screens/education_screen.dart';
import 'package:health_surveillance_app/screens/profile_screen.dart';
import 'package:health_surveillance_app/screens/image_analysis_screen.dart';
import 'package:health_surveillance_app/screens/hotspot_map_screen.dart';
import 'package:provider/provider.dart';
import 'package:health_surveillance_app/theme_notifier.dart';

// A reusable widget for our dashboard menu items
class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  // We receive the user object from AuthGate to know who is logged in
  final User user;
  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- Logout Logic ---
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  // --- Confirmation Dialog for Logout ---
  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to log out?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _signOut(); // Then sign out
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the theme notifier to read and update the offline state
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Feather.user),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            tooltip: 'My Profile',
          ),
          IconButton(
            icon: const Icon(Feather.bar_chart_2),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
              );
            },
            tooltip: 'Analytics',
          ),
          IconButton(
            icon: const Icon(Feather.log_out),
            onPressed: _showLogoutConfirmationDialog,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Welcome Header ---
            Text(
              'Welcome,',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.user.email ?? 'Health Worker',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            
            // --- Manual Sync Toggle ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: SwitchListTile(
                title: const Text('Work Offline'),
                subtitle: Text(themeNotifier.isOffline ? 'Data is saved locally.' : 'Online & Syncing...'),
                secondary: Icon(themeNotifier.isOffline ? Feather.wifi_off : Feather.wifi),
                value: themeNotifier.isOffline,
                onChanged: (value) {
                  themeNotifier.toggleOfflineMode(value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value ? 'Working offline. Data will be saved on your device.' : 'Online. Synchronizing data with the server.'),
                      backgroundColor: value ? Colors.orange.shade700 : Colors.green.shade700,
                    ),
                  );
                },
              ),
            ),
            
            const Divider(height: 24),
            Text(
              'Select an action:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 16),
            
            // --- Feature Cards Grid ---
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  DashboardCard(
                    icon: Feather.edit,
                    title: 'New Health Report',
                    description: 'Submit data from the field.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NewReportScreen()),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Feather.list,
                    title: 'View My Reports',
                    description: 'See your past submissions.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ViewReportsScreen()),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Feather.bell,
                    title: 'Alerts',
                    description: 'Check for outbreak warnings.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AlertsScreen()),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Feather.book_open,
                    title: 'Education',
                    description: 'Hygiene & prevention info.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EducationScreen()),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Feather.map,
                    title: 'Hotspot Map',
                    description: 'View outbreak locations.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HotspotMapScreen()),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Feather.camera,
                    title: 'Image Analysis',
                    description: 'Get AI insights from a photo.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ImageAnalysisScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

