import 'package:flutter/material.dart';

class AppTheme {
  // Modern Color Palette
  static const Color primaryColor = Color(0xFF2563EB); // Modern Blue
  static const Color secondaryColor = Color(0xFF10B981); // Emerald Green
  static const Color accentColor = Color(0xFFF59E0B); // Amber
  static const Color errorColor = Color(0xFFEF4444); // Red
  static const Color warningColor = Color(0xFFF97316); // Orange
  static const Color successColor = Color(0xFF22C55E); // Green
  
  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF8FAFC); // Light Gray
  static const Color surfaceColor = Color(0xFFFFFFFF); // White
  static const Color cardColor = Color(0xFFFFFFFF); // White
  static const Color onSurfaceColor = Color(0xFF1E293B); // Dark Gray
  static const Color onBackgroundColor = Color(0xFF475569); // Medium Gray
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: onSurfaceColor,
    letterSpacing: -0.5,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: onSurfaceColor,
    letterSpacing: -0.25,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: onSurfaceColor,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: onSurfaceColor,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: onSurfaceColor,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: onBackgroundColor,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: onBackgroundColor,
  );
  
  // Card Theme
  static CardTheme cardTheme = CardTheme(
    color: cardColor,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(
        color: Color(0xFFE2E8F0),
        width: 1,
      ),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );
  
  // Elevated Button Theme
  static ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
  
  // Outlined Button Theme
  static OutlinedButtonThemeData outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: primaryColor,
      side: const BorderSide(color: primaryColor, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
  
  // Input Decoration Theme
  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: backgroundColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: errorColor, width: 1),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    labelStyle: const TextStyle(color: onBackgroundColor, fontSize: 14),
    hintStyle: const TextStyle(color: onBackgroundColor, fontSize: 14),
  );
  
  // AppBar Theme
  static AppBarTheme appBarTheme = const AppBarTheme(
    backgroundColor: surfaceColor,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    titleTextStyle: heading2,
    iconTheme: IconThemeData(color: onSurfaceColor),
    actionsIconTheme: IconThemeData(color: onSurfaceColor),
  );
  
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: onSurfaceColor,
      onBackground: onBackgroundColor,
    ),
    cardTheme: cardTheme,
    elevatedButtonTheme: elevatedButtonTheme,
    outlinedButtonTheme: outlinedButtonTheme,
    inputDecorationTheme: inputDecorationTheme,
    appBarTheme: appBarTheme,
    scaffoldBackgroundColor: backgroundColor,
    textTheme: const TextTheme(
      displayLarge: heading1,
      displayMedium: heading2,
      displaySmall: heading3,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelSmall: caption,
    ),
  );
  
  // Dark Theme - Premium Dark Mode Design
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      // Core colors from AI suggestion
      primary: Color(0xFF3B82F6),      // Blue accent
      secondary: Color(0xFF3B82F6),    // Blue accent
      error: Color(0xFFEF4444),        // Red for errors
      surface: Color(0xFF1E1E1E),     // Card background
      background: Color(0xFF121212),  // Main app background
      onSurface: Color(0xFFE5E7EB),   // Primary text
      onBackground: Color(0xFFFFFFFF), // Background text
      outline: Color(0xFF2C2C2C),      // Borders/dividers
      onPrimary: Color(0xFFFFFFFF),    // Text on primary
      onError: Color(0xFFFFFFFF),      // Text on error
      tertiary: Color(0xFF2A2A2A),    // Elevated surfaces
      onTertiary: Color(0xFFE5E7EB),  // Text on tertiary
    ),
    scaffoldBackgroundColor: const Color(0xFF121212), // Primary background
    
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
      actionsIconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6), // Primary blue
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFE5E7EB),
        backgroundColor: const Color(0xFF2A2A2A),
        side: const BorderSide(color: Color(0xFF3A3A3A), width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF3B82F6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      labelStyle: const TextStyle(color: Color(0xFFA1A1AA)),
      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
      prefixIconColor: const Color(0xFFA1A1AA),
      suffixIconColor: const Color(0xFFA1A1AA),
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(
      color: Color(0xFFE5E7EB), // Primary icon color
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        inherit: true,
        color: Color(0xFFFFFFFF),
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: TextStyle(
        inherit: true,
        color: Color(0xFFFFFFFF),
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      displaySmall: TextStyle(
        inherit: true,
        color: Color(0xFFFFFFFF),
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: TextStyle(
        inherit: true,
        color: Color(0xFFFFFFFF),
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        inherit: true,
        color: Color(0xFFFFFFFF),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        inherit: true,
        color: Color(0xFFFFFFFF),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        inherit: true,
        color: Color(0xFFFFFFFF),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        inherit: true,
        color: Color(0xFFFFFFFF),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        inherit: true,
        color: Color(0xFFFFFFFF),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        inherit: true,
        color: Color(0xFFFFFFFF),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        inherit: true,
        color: Color(0xFFE5E7EB),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        inherit: true,
        color: Color(0xFFA1A1AA),
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        inherit: true,
        color: Color(0xFFFFFFFF),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        inherit: true,
        color: Color(0xFFE5E7EB),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        inherit: true,
        color: Color(0xFFA1A1AA),
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),
    
    // Dialog Theme
    dialogTheme: DialogTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        inherit: true,
        color: Color(0xFFFFFFFF),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        inherit: true,
        color: Color(0xFFE5E7EB),
        fontSize: 14,
      ),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Color(0xFF3B82F6),
      unselectedItemColor: Color(0xFFA1A1AA),
      type: BottomNavigationBarType.fixed,
    ),
    
    // List Tile Theme
    listTileTheme: const ListTileThemeData(
      tileColor: Color(0xFF121212),
      iconColor: Color(0xFFE5E7EB),
      textColor: Color(0xFFE5E7EB),
      titleTextStyle: TextStyle(
        inherit: true,
        color: Color(0xFFFFFFFF),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      subtitleTextStyle: TextStyle(
        inherit: true,
        color: Color(0xFFA1A1AA),
        fontSize: 14,
      ),
    ),
    
    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2C2C2C),
      thickness: 1,
    ),
    
    // Snack Bar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      contentTextStyle: const TextStyle(
        inherit: true,
        color: Color(0xFFFFFFFF),
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
