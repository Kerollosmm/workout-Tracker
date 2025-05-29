import 'package:flutter/material.dart';
import '../../../config/themes/app_theme.dart'; // Added 2025-05-29: Import AppTheme

class UnitsSelector extends StatelessWidget {
  final String selectedUnit;
  final Function(String) onUnitChanged;

  const UnitsSelector({
    Key? key,
    required this.selectedUnit,
    required this.onUnitChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final units = [
      {'code': 'kg', 'name': 'Kilograms (kg)'},
      {'code': 'lbs', 'name': 'Pounds (lbs)'},
    ];
    
    return Column(
      children: units.map((unit) {
        final isSelected = selectedUnit == unit['code'];
        return RadioListTile<String>(
          // Updated 2025-05-29: Apply AppTheme styling
          title: Text(unit['name']!, style: const TextStyle(color: AppTheme.primaryTextColor)),
          value: unit['code']!,
          groupValue: selectedUnit,
          activeColor: AppTheme.accentTextColor, // Use accent color for selected radio
          onChanged: (value) {
            if (value != null) {
              onUnitChanged(value);
            }
          },
        );
      }).toList(),
    );
  }
}
