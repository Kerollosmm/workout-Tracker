import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

// Updated 2025-05-20: Created theme manager to handle theme switching and consistency
class AppThemeManager {
  static final AppThemeManager _instance = AppThemeManager._internal();
  factory AppThemeManager() => _instance;
  AppThemeManager._internal();

  // Theme mode preference
  ThemeMode _themeMode = ThemeMode.system;
  
  // Get current theme mode
  ThemeMode get themeMode => _themeMode;
  
  // Set theme mode and apply system UI overlay style
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _applySystemUIOverlayStyle(mode);
  }
  
  // Get the appropriate theme based on the brightness
  ThemeData getTheme(Brightness brightness) {
    return brightness == Brightness.light 
        ? getLightTheme() 
        : getDarkTheme();
  }
  
  // Get light theme configuration
  // Updated 2025-05-20: Added method to fix theme retrieval
  ThemeData getLightTheme() {
    return LightTheme.theme;
  }
  
  // Get dark theme configuration
  // Updated 2025-05-20: Added method to fix theme retrieval
  ThemeData getDarkTheme() {
    return DarkTheme.theme;
  }
  
  // Apply system UI overlay style based on theme mode
  void _applySystemUIOverlayStyle(ThemeMode mode) {
    final Brightness brightness;
    
    switch (mode) {
      case ThemeMode.light:
        brightness = Brightness.light;
        break;
      case ThemeMode.dark:
        brightness = Brightness.dark;
        break;
      case ThemeMode.system:
      default:
        brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        break;
    }
    
    if (brightness == Brightness.light) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: const Color(0xFF1C1C1E),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
    }
  }
  
  // Apply theme based on system changes
  void handleSystemBrightnessChange() {
    if (_themeMode == ThemeMode.system) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      _applySystemUIOverlayStyle(ThemeMode.system);
    }
  }
  
  // Get text theme color based on current brightness
  Color getTextColorForBrightness(BuildContext context, Brightness brightness) {
    final theme = Theme.of(context);
    return brightness == Brightness.light
        ? theme.textTheme.bodyLarge?.color ?? Colors.black
        : theme.textTheme.bodyLarge?.color ?? Colors.white;
  }
  
  // Initialize theme (call this in main.dart)
  void initialize() {
    // Apply initial system UI overlay style
    _applySystemUIOverlayStyle(_themeMode);
    
    // Set up listener for system brightness changes
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      handleSystemBrightnessChange();
    };
  }
}
