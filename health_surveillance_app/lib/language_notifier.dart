import 'package:flutter/material.dart';

class LanguageNotifier extends ChangeNotifier {
  Locale _appLocale = const Locale('en'); // Default language is English

  Locale get appLocale => _appLocale;

  void changeLanguage(Locale newLocale) {
    if (_appLocale == newLocale) return;
    _appLocale = newLocale;
    notifyListeners(); // This tells the app to rebuild with the new language
  }
}

