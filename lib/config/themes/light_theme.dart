// lib/config/themes/light_theme.dart

import 'package:flutter/material.dart';
import 'package:workout_tracker/config/constants/app_constants.dart';

class LightTheme {
  static ThemeData get theme {
    return ThemeData.light().copyWith(
      primaryColor: AppTheme.primaryColor,
      colorScheme: const ColorScheme.light(
        primary: AppTheme.primaryColor,
        secondary: AppTheme.secondaryColor,
        error: AppTheme.errorColor,
        background: AppTheme.backgroundLight,
        surface: AppTheme.surfaceLight,
      ),
      scaffoldBackgroundColor: AppTheme.backgroundLight,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppTheme.cardLight,
        foregroundColor: AppTheme.textPrimaryLight,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: AppTheme.textPrimaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius_xl),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing_l,
            vertical: AppTheme.spacing_m,
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius_l),
        ),
        color: AppTheme.cardLight,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppTheme.surfaceLight,
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        labelStyle: const TextStyle(color: AppTheme.textPrimaryLight),
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
        fillColor: AppTheme.backgroundLight,
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
        headlineMedium: AppTheme.headingStyle.copyWith(
          color: AppTheme.textPrimaryLight,
        ),
        titleLarge: AppTheme.subheadingStyle.copyWith(
          color: AppTheme.textPrimaryLight,
        ),
        bodyLarge: AppTheme.bodyStyle.copyWith(
          color: AppTheme.textPrimaryLight,
        ),
        bodyMedium: AppTheme.captionStyle.copyWith(
          color: AppTheme.textSecondaryLight,
        ),
        labelLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimaryLight,
          letterSpacing: -0.2,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppTheme.cardLight,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryLight,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        thickness: 1,
        color: AppTheme.backgroundLight,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppTheme.primaryColor;
          }
          return AppTheme.textSecondaryLight;
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
          return AppTheme.textSecondaryLight;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppTheme.primaryColor.withOpacity(0.3);
          }
          return AppTheme.backgroundLight;
        }),
      ),
    );
  }
}