import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

// Updated 2025-05-20: Fixed imports to correctly reference AppColors

// Updated 2025-05-20: Created iOS-style slider component for consistent iOS look and feel
class IOSSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final ValueChanged<double> onChanged;
  final Color? activeColor;

  const IOSSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode
        ? AppColors.primaryDark
        : AppColors.primaryLight;
    
    return CupertinoSlider(
      value: value,
      min: min,
      max: max,
      divisions: divisions,
      activeColor: activeColor ?? primaryColor,
      thumbColor: Colors.white,
      onChanged: onChanged,
    );
  }
}
