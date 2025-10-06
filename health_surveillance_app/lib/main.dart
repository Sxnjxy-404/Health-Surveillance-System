import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_surveillance_app/firebase_options.dart';
import 'package:health_surveillance_app/push_notification_service.dart';
import 'package:health_surveillance_app/screens/splash_screen.dart';
import 'package:health_surveillance_app/theme_notifier.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  // Start the app with the network disabled (offline mode)
  await FirebaseFirestore.instance.disableNetwork();

  await PushNotificationService().initialize();

  // Wrap the entire app in a ChangeNotifierProvider to manage the theme state
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen for changes in the theme state
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    // --- Light Theme Definition ---
    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.light),
      textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );

    // --- Dark Theme Definition ---
    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
      textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white)),
       appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black12,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );

    return MaterialApp(
      title: 'Health Surveillance',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeNotifier.themeMode, // Apply the current theme mode
      // Set the SplashScreen as the new home page
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

