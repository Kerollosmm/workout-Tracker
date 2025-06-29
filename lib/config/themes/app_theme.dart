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

  // Light theme definition
  static ThemeData get lightTheme {
    // Define light theme specific colors
    const Color lightPrimaryColor = Color(0xFFFFFFFF); // White
    const Color lightBackgroundColor = Color(0xFFF2F2F7); // System Gray 6
    const Color lightCardColor = Color(0xFFFFFFFF);    // White cards
    const Color lightSurfaceColor = Color(0xFFFFFFFF);   // White surfaces
    const Color lightPrimaryTextColor = Color(0xFF000000); // Black text
    const Color lightSecondaryTextColor = Color(0xFF3C3C43); // System Gray (opacity 60%)

    return ThemeData.light().copyWith(
      primaryColor: lightPrimaryColor,
      scaffoldBackgroundColor: lightBackgroundColor,
      cardColor: lightCardColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackgroundColor, // Light background for appbar
        foregroundColor: lightPrimaryTextColor, // Dark text for appbar
        elevation: 0, // Flat design
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: lightPrimaryTextColor,
          fontSize: 28, // iOS Large Title size
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: accentTextColor), // Accent color for icons like back button
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightCardColor, // Slightly off-white or white
        selectedItemColor: accentTextColor, // Use accent for selected items
        unselectedItemColor: lightSecondaryTextColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0, // Flat
      ),
      cardTheme: CardTheme(
        color: lightCardColor,
        elevation: 0, // Flat cards
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius_m),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: lightPrimaryTextColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: lightPrimaryTextColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: lightPrimaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: lightPrimaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: lightPrimaryTextColor, fontSize: 16),
        bodyMedium: TextStyle(color: lightSecondaryTextColor, fontSize: 14),
        bodySmall: TextStyle(color: lightSecondaryTextColor, fontSize: 12),
      ),
      colorScheme: const ColorScheme.light(
        primary: accentTextColor, // Main interactive color
        secondary: exerciseRingColor, // Another accent
        surface: lightSurfaceColor,
        background: lightBackgroundColor,
        onPrimary: lightPrimaryTextColor, // Text on primary color buttons
        onSecondary: lightPrimaryTextColor,
        onSurface: lightPrimaryTextColor,
        onBackground: lightPrimaryTextColor,
        error: errorColor,
      ),
      // Specific widget themes
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return accentTextColor;
          }
          return null; // Defaults to system gray
        }),
        trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return accentTextColor.withOpacity(0.5);
          }
          return null; // Defaults to system gray
        }),
      ),
      filterChipTheme: FilterChipThemeData(
        backgroundColor: lightSecondaryTextColor.withOpacity(0.1),
        selectedColor: accentTextColor,
        checkmarkColor: lightPrimaryTextColor,
        labelStyle: TextStyle(color: lightPrimaryTextColor.withOpacity(0.8)),
        secondaryLabelStyle: const TextStyle(color: lightPrimaryTextColor), // For selected chip
        shape: StadiumBorder(side: BorderSide(color: lightSecondaryTextColor.withOpacity(0.2))),
      ),
       radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return accentTextColor;
          }
          return lightSecondaryTextColor;
        }),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: accentTextColor, // Default icon color for ListTiles
      )
    );
  }
}
