import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'language_code';
  
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('ar', 'SA'),
  ];

  static const List<String> supportedLanguages = [
    'English',
    'Arabic',
  ];

  static final ValueNotifier<Locale> _localeNotifier = ValueNotifier(const Locale('en'));

  static ValueNotifier<Locale> get localeNotifier => _localeNotifier;

  static Future<void> saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      // Fallback to localStorage if SharedPreferences fails
      // This can happen on some HTTPS deployments
    }
    
    // Update the locale notifier to trigger app rebuild
    final newLocale = supportedLocales.firstWhere(
      (locale) => locale.languageCode == languageCode,
      orElse: () => supportedLocales.first,
    );
    _localeNotifier.value = newLocale;
  }

  static Future<String> getLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_languageKey) ?? 'en';
    } catch (e) {
      // Fallback to localStorage if SharedPreferences fails
      return 'en';
    }
  }

  static Future<Locale> getLocale() async {
    final languageCode = await getLanguage();
    final locale = supportedLocales.firstWhere(
      (locale) => locale.languageCode == languageCode,
      orElse: () => supportedLocales.first,
    );
    _localeNotifier.value = locale;
    return locale;
  }

  static String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'Arabic';
      default:
        return 'English';
    }
  }

  static String getLanguageCode(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'en';
      case 'ar':
        return 'ar';
      default:
        return 'en';
    }
  }

  static bool isRTL(String languageCode) {
    return languageCode == 'ar';
  }

  static TextDirection getTextDirection(String languageCode) {
    return isRTL(languageCode) ? TextDirection.rtl : TextDirection.ltr;
  }
}
