import 'package:flutter/material.dart';

class AppTheme {
  // --- COLORS (LIGHT) ---
  static const Color lightPrimary = Color(0xFF4CAF50);
  static const Color lightOnPrimary = Colors.white;
  static const Color lightSecondary = Color(0xFF03A9F4);
  static const Color lightOnSecondary = Colors.white;
  static const Color lightSurface = Colors.white;
  static const Color lightOnSurface = Colors.black87;
  static const Color lightError = Color(0xFFB00020);

  // --- COLORS (DARK) ---
  static const Color darkPrimary = Color(0xFF4CAF50);
  static const Color darkOnPrimary = Colors.black;
  static const Color darkSecondary = Color(0xFF03A9F4);
  static const Color darkOnSecondary = Colors.black;
  static const Color darkSurface = Color(0xFF1F1F1F);
  static const Color darkOnSurface = Colors.white;
  static const Color darkError = Color(0xFFCF6679);

  // --- TYPOGRAPHY ---
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
    bodySmall: TextStyle(fontSize: 12),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
  );

  // --- LIGHT THEME ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: lightPrimary,
      onPrimary: lightOnPrimary,
      secondary: lightSecondary,
      onSecondary: lightOnSecondary,
      surface: lightSurface,
      onSurface: lightOnSurface,
      error: lightError,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: lightSurface,
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightPrimary,
      foregroundColor: lightOnPrimary,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimary,
        foregroundColor: lightOnPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
  );

  // --- DARK THEME ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: darkPrimary,
      onPrimary: darkOnPrimary,
      secondary: darkSecondary,
      onSecondary: darkOnSecondary,
      surface: darkSurface,
      onSurface: darkOnSurface,
      error: darkError,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: darkSurface,
    textTheme: textTheme.apply(bodyColor: darkOnSurface, displayColor: darkOnSurface),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkPrimary,
      foregroundColor: darkOnPrimary,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimary,
        foregroundColor: darkOnPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[850],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
  );
}