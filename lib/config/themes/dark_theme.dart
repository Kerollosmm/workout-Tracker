// lib/config/themes/dark_theme.dart

import 'package:flutter/material.dart';
import 'package:workout_tracker/config/constants/app_constants.dart';
import 'app_theme.dart';

class DarkTheme {
  static ThemeData get theme {
    return ThemeData.dark().copyWith(
      primaryColor: AppTheme.primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: AppTheme.primaryColor,
        secondary: AppTheme.secondaryColor,
        error: AppTheme.errorColor,
        background: AppTheme.backgroundDark,
        surface: AppTheme.surfaceDark,
      ),
      scaffoldBackgroundColor: AppTheme.backgroundDark,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppTheme.cardDark,
        foregroundColor: AppTheme.textPrimaryDark,
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
        color: AppTheme.cardDark,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppTheme.surfaceDark,
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        labelStyle: const TextStyle(color: AppTheme.textPrimaryDark),
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
        fillColor: AppTheme.surfaceDark,
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
          color: AppTheme.textPrimaryDark,
        ),
        titleLarge: AppTheme.subheadingStyle.copyWith(
          color: AppTheme.textPrimaryDark,
        ),
        bodyLarge: AppTheme.bodyStyle.copyWith(
          color: AppTheme.textPrimaryDark,
        ),
        bodyMedium: AppTheme.captionStyle.copyWith(
          color: AppTheme.textSecondaryDark,
        ),
        labelLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimaryDark,
          letterSpacing: -0.2,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppTheme.cardDark,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryDark,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        thickness: 1,
        color: AppTheme.surfaceDark,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppTheme.primaryColor;
          }
          return AppTheme.textSecondaryDark;
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
          return AppTheme.textSecondaryDark;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppTheme.primaryColor.withOpacity(0.3);
          }
          return AppTheme.surfaceDark;
        }),
      ),
    );
  }
}
