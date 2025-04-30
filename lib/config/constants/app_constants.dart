// lib/config/themes/app_theme.dart

import 'package:flutter/material.dart';
import 'package:workout_tracker/config/themes/dark_theme.dart';
import 'package:workout_tracker/config/themes/light_theme.dart';

class AppTheme {
  // Get the current theme based on setting
  static ThemeData getTheme(bool isDarkMode) {
    return isDarkMode ? darkTheme : lightTheme;
  }

  // Convenience getters
  static ThemeData get lightTheme => LightTheme.theme;
  static ThemeData get darkTheme => DarkTheme.theme;

  // Updated color scheme to match the modern UI
  static const Color primaryColor = Color(0xFF246BFD); // Vibrant Blue
  static const Color secondaryColor = Color(0xFFFF9500); // Orange Accent
  static const Color successColor = Color(0xFF4CD964);
  static const Color errorColor = Color(0xFFFF3B30);
  static const Color warningColor = Color(0xFFFFCC00);
  static const Color backgroundLight = Color(0xFFF8F9FB);
  static const Color backgroundDark = Color(0xFF1E1E1E);

  // Surface and card colors
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF2C2C2E);
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1C1C1E);

  // Text colors
  static const Color textPrimaryLight = Color(0xFF1C1C1E);
  static const Color textSecondaryLight = Color(0xFF8E8E93);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFF8E8E93);

  // Spacing constants
  static const double spacing_xs = 4.0;
  static const double spacing_s = 8.0;
  static const double spacing_m = 16.0;
  static const double spacing_l = 24.0;
  static const double spacing_xl = 32.0;

  // Border radius
  static const double borderRadius_s = 8.0;
  static const double borderRadius_m = 16.0;
  static const double borderRadius_l = 24.0;
  static const double borderRadius_xl = 32.0;

  // Modern text styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: textPrimaryLight,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: textPrimaryLight,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.2,
    color: textPrimaryLight,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.1,
    color: textSecondaryLight,
  );

  static Color getColorForMuscleGroup(String muscleGroup) {
    return muscleGroupColors[muscleGroup] ?? Colors.grey;
  }

  static const Map<String, Color> muscleGroupColors = {
    'Chest': Color(0xFFF44336),     // Red
    'Back': Color(0xFF2196F3),      // Blue
    'Shoulders': Color(0xFFFF9800),  // Orange
    'Arms': Color(0xFF9C27B0),      // Purple
    'Legs': Color(0xFF4CAF50),      // Green
    'Core': Color(0xFFFFEB3B),      // Yellow
    'Cardio': Color(0xFFE91E63),    // Pink
    'Full Body': Color(0xFF009688), // Teal
  };
}
