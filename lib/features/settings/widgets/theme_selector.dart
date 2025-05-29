import 'package:flutter/material.dart';
import '../../../config/themes/app_theme.dart'; // Added 2025-05-29: Import AppTheme

class ThemeSelector extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const ThemeSelector({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile<bool>(
          // Updated 2025-05-29: Apply AppTheme styling
          title: const Text(
            'Light Mode',
            style: TextStyle(color: AppTheme.primaryTextColor),
          ),
          value: false,
          groupValue: isDarkMode,
          activeColor:
              AppTheme.accentTextColor, // Use accent color for selected radio
          onChanged: (value) {
            if (value != null) {
              onThemeChanged(value);
            }
          },
        ),
        RadioListTile<bool>(
          // Updated 2025-05-29: Apply AppTheme styling
          title: const Text(
            'Dark Mode',
            style: TextStyle(color: AppTheme.primaryTextColor),
          ),
          value: true,
          groupValue: isDarkMode,
          activeColor:
              AppTheme.accentTextColor, // Use accent color for selected radio
          onChanged: (value) {
            if (value != null) {
              onThemeChanged(value);
            }
          },
        ),
      ],
    );
  }
}
