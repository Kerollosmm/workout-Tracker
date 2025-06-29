import 'package:flutter/material.dart';
import 'package:workout_tracker/config/themes/app_theme.dart'; // Assuming AppTheme is here

class CustomActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? minWidth;
  final double? minHeight;

  const CustomActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.minWidth = double.infinity,
    this.minHeight = 48,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppTheme.surfaceColor,
        foregroundColor: foregroundColor ?? AppTheme.accentTextColor,
        minimumSize: Size(minWidth!, minHeight!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacing_s,
          horizontal: AppTheme.spacing_m,
        ),
        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600, // Ensure consistent weight if needed
        ),
      ),
      onPressed: onPressed,
    );
  }
}
