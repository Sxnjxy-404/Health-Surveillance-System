import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:health_surveillance_app/screens/about_screen.dart';
import 'package:health_surveillance_app/theme_notifier.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Function to handle the password reset logic
  void _resetPassword(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to $email.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send reset email: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Get the theme notifier from the provider to read and update the theme state
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile & Settings'),
      ),
      body: Container(
        // Apply a gradient background only in dark mode
        decoration: isDarkMode
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade900,
                    Colors.grey.shade800,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 50,
                child: Icon(Feather.user, size: 50),
              ),
              const SizedBox(height: 20),
              Text(
                'Logged in as:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? 'No email available',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              const Divider(),
              
              // --- The Dark Mode Toggle Switch ---
              SwitchListTile(
                title: const Text('Dark Mode'),
                secondary: const Icon(Feather.moon),
                value: isDarkMode,
                onChanged: (value) {
                  themeNotifier.toggleTheme(value);
                },
              ),
              
              // --- ListTile to navigate to About Screen ---
              ListTile(
                leading: const Icon(Feather.info),
                title: const Text('About this App'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                },
              ),

              const Divider(),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Feather.lock),
                label: const Text('Send Password Reset Email'),
                onPressed: user?.email != null
                    ? () => _resetPassword(context, user!.email!)
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), // make button wide
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

