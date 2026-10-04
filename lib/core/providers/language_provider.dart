import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('en');
  
  Locale get currentLocale => _currentLocale;
  
  bool get isArabic => _currentLocale.languageCode == 'ar';
  
  List<Locale> get supportedLocales => [
    const Locale('en'), // English
    const Locale('ar'), // Arabic
  ];
  
  LanguageProvider() {
    _loadSavedLanguage();
  }
  
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString(_languageKey);
      
      if (savedLanguageCode != null) {
        final savedLocale = Locale(savedLanguageCode);
        if (supportedLocales.contains(savedLocale)) {
          _currentLocale = savedLocale;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading saved language: $e');
    }
  }
  
  Future<void> changeLanguage(Locale newLocale) async {
    if (!supportedLocales.contains(newLocale)) {
      debugPrint('Unsupported locale: $newLocale');
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, newLocale.languageCode);
      
      _currentLocale = newLocale;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }
  
  String getLanguageDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return locale.languageCode.toUpperCase();
    }
  }
  
  String getLanguageNativeName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return locale.languageCode.toUpperCase();
    }
  }
}
