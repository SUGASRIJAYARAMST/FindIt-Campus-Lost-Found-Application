import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  static const Map<String, Locale> supportedLocales = {
    'English': Locale('en'),
    'Tamil': Locale('ta'),
    'Hindi': Locale('hi'),
    'Malayalam': Locale('ml'),
    'Telugu': Locale('te'),
  };

  static const Map<String, String> languageNames = {
    'en': 'English',
    'ta': 'Tamil',
    'hi': 'Hindi',
    'ml': 'Malayalam',
    'te': 'Telugu',
  };

  String get languageName => languageNames[_locale.languageCode] ?? 'English';

  void setLocale(Locale locale) {
    if (_locale != locale) {
      _locale = locale;
      notifyListeners();
    }
  }
}
