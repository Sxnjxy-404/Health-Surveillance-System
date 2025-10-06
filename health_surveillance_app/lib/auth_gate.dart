import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart'; // We will create this folder and file
import 'screens/dashboard_screen.dart'; // We will create this folder and file

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen to the authentication state changes from Firebase
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the connection is still waiting, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If the snapshot has data, it means the user is logged in
        if (snapshot.hasData) {
          // Pass the user object to the DashboardScreen
          return DashboardScreen(user: snapshot.data!);
        }
        
        // If there's no data, show the LoginScreen
        return const LoginScreen();
      },
    );
  }
}

