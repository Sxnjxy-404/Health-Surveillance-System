import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isOffline = true; // Start in offline mode by default

  ThemeMode get themeMode => _themeMode;
  bool get isOffline => _isOffline;

  // Toggles the theme between light and dark
  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Toggles the Firestore network connection for manual sync
  void toggleOfflineMode(bool offline) {
    _isOffline = offline;
    if (_isOffline) {
      FirebaseFirestore.instance.disableNetwork();
      print("Firestore network disabled. App is in offline mode.");
    } else {
      FirebaseFirestore.instance.enableNetwork();
      print("Firestore network enabled. Syncing data...");
    }
    notifyListeners();
  }
}

