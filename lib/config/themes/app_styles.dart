import 'package:flutter/material.dart';

/// A central class for app-wide styling constants to ensure consistency.
class AppStyles {
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Padding
  static const EdgeInsets paddingS = EdgeInsets.all(spacingS);
  static const EdgeInsets paddingM = EdgeInsets.all(spacingM);
  static const EdgeInsets paddingL = EdgeInsets.all(spacingL);
  
  static const EdgeInsets paddingHorizontalM = EdgeInsets.symmetric(horizontal: spacingM);
  static const EdgeInsets paddingVerticalM = EdgeInsets.symmetric(vertical: spacingM);
  
  // Card styling
  static const double cardElevation = 2.0;
  static const double cardBorderRadius = 8.0;
  static BorderRadius borderRadiusM = BorderRadius.circular(cardBorderRadius);
  
  // Text styles - these would be used in conjunction with the theme
  static TextStyle getHeadingStyle(BuildContext context) => 
      Theme.of(context).textTheme.headlineMedium!;
      
  static TextStyle getTitleStyle(BuildContext context) => 
      Theme.of(context).textTheme.titleLarge!;
      
  static TextStyle getSubtitleStyle(BuildContext context) => 
      Theme.of(context).textTheme.titleMedium!;
      
  static TextStyle getBodyStyle(BuildContext context) => 
      Theme.of(context).textTheme.bodyLarge!;
      
  static TextStyle getEmphasizedStyle(BuildContext context) => 
      Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontWeight: FontWeight.bold,
      );
  
  // Icon sizes
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 20.0;
  static const double iconSizeL = 24.0;
  
  // Get accent color from theme
  static Color getAccentColor(BuildContext context) => 
      Theme.of(context).colorScheme.secondary;
}