import 'package:flutter/material.dart';

// Updated 2025-05-21: Defined AppTheme class matching Figma fitness app design
class AppTheme {
  // Dark theme colors matching the fitness app design
  static const Color primaryColor = Color(0xFF000000); // Pure black
  static const Color backgroundColor = Color(0xFF000000); // Black background
  static const Color cardColor = Color(0xFF1C1C1E); // Dark card background
  static const Color surfaceColor = Color(
    0xFF2C2C2E,
  ); // Slightly lighter surface

  // Activity ring colors matching Apple Fitness style
  static const Color moveRingColor = Color(0xFFFF2D55); // Red for Move/Calories
  static const Color exerciseRingColor = Color(
    0xFF4CD964,
  ); // Green for Exercise
  static const Color standRingColor = Color(0xFF007AFF); // Blue for Stand

  // Text colors
  static const Color primaryTextColor = Color(0xFFFFFFFF); // White text
  static const Color secondaryTextColor = Color(0xFFAAAAAA); // Gray text
  static const Color accentColor = Color(0xFF007BFF); // Example accent color
  static const Color errorColor = Color(0xFFFF0000); // Example error color
  static const Color accentTextColor = Color(0xFF4CD964); // Green accent

  // Spacing constants
  static const double spacing_xs = 4.0;
  static const double spacing_s = 8.0;
  static const double spacing_m = 16.0;
  static const double spacing_l = 24.0;
  static const double spacing_xl = 32.0;

  // Border radius constants
  static const double borderRadius_s = 8.0;
  static const double borderRadius_m = 16.0;
  static const double borderRadius_l = 24.0;

  // Added 2025-05-23: Icon size constants
  static const double iconSize_s = 18.0;
  static const double iconSize_m = 24.0; // Standard Material icon size
  static const double iconSize_l = 30.0;

  // Updated muscle group colors for better contrast on dark theme
  static final Map<String, Color> muscleGroupColors = {
    'Chest': const Color(0xFFFF2D55),
    'Back': const Color(0xFF007AFF),
    'Legs': const Color(0xFF4CD964),
    'Shoulders': const Color(0xFFFF9500),
    'Arms': const Color(0xFFAF52DE),
    'Core': const Color(0xFFFFD60A),
    'Cardio': const Color(0xFFFF2D92),
    'Full Body': const Color(0xFF64D2FF),
    'Other': const Color(0xFF8E8E93),
  };

  static Color getColorForMuscleGroup(String muscleGroupName) {
    return muscleGroupColors[muscleGroupName] ??
        const Color(0xFF8E8E93); // Return gray if not found
  }

  // Dark theme matching the fitness app design
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: primaryTextColor,
        unselectedItemColor: secondaryTextColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius_m),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: primaryTextColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: primaryTextColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: primaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: primaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: primaryTextColor, fontSize: 16),
        bodyMedium: TextStyle(color: secondaryTextColor, fontSize: 14),
        bodySmall: TextStyle(color: secondaryTextColor, fontSize: 12),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentTextColor,
        surface: cardColor,
        background: backgroundColor,
        onPrimary: primaryTextColor,
        onSecondary: primaryTextColor,
        onSurface: primaryTextColor,
        onBackground: primaryTextColor,
        error: errorColor,
      ),
    );
  }
  // Updated 2025-05-29: lightTheme getter removed as app is dark-theme only.
}
