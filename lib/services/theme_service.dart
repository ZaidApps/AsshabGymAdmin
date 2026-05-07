import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'theme_mode';
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'dark':
          themeNotifier.value = ThemeMode.dark;
          break;
        case 'light':
          themeNotifier.value = ThemeMode.light;
          break;
        case 'system':
          themeNotifier.value = ThemeMode.system;
          break;
        default:
          themeNotifier.value = ThemeMode.light;
      }
    }
  }

  static Future<void> setTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    themeNotifier.value = themeMode;
    
    String themeString;
    switch (themeMode) {
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
    }
    
    await prefs.setString(_themeKey, themeString);
  }

  static ThemeMode get currentTheme => themeNotifier.value;
  
  static bool isDarkMode(BuildContext context) {
    switch (themeNotifier.value) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }
}
