// lib/config/themes/dark_theme.dart

import 'package:flutter/material.dart';
import 'package:workout_tracker/config/constants/app_constants.dart';

class DarkTheme {
  static ThemeData get theme {
    return ThemeData.dark().copyWith(
      primaryColor: AppTheme.primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: AppTheme.primaryColor,
        secondary: AppTheme.secondaryColor,
        error: AppTheme.errorColor,
        background: Color(0xFF1A1A1A), // Slightly darker background
        surface: Color(0xFF262626), // Slightly lighter surface
        onSurface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      scaffoldBackgroundColor: Color(0xFF1A1A1A),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFF2C2C2C), // Updated background color
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing_l,
            vertical: AppTheme.spacing_m,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: Color(0xFF262626),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Color(0xFF262626),
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        labelStyle: const TextStyle(color: Colors.white),
        secondaryLabelStyle: const TextStyle(color: AppTheme.primaryColor),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing_m,
          vertical: AppTheme.spacing_xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius_xl),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF262626),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius_l),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius_l),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius_l),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius_l),
          borderSide: const BorderSide(color: AppTheme.errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing_m,
          vertical: AppTheme.spacing_m,
        ),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
        headlineMedium: AppTheme.headingStyle.copyWith(color: Colors.white),
        labelLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF262626),
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.white70,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        thickness: 1,
        color: Color(0xFF262626),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppTheme.primaryColor;
          }
          return Colors.white70;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppTheme.primaryColor;
          }
          return Colors.white70;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppTheme.primaryColor.withOpacity(0.3);
          }
          return Color(0xFF262626);
        }),
      ),
    );
  }
}
