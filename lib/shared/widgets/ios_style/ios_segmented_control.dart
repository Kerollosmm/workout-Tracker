import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

// Updated 2025-05-20: Fixed imports to correctly reference AppColors

// Updated 2025-05-20: Created iOS-style segmented control component for consistent iOS look and feel
class IOSSegmentedControl<T extends Object> extends StatelessWidget {
  final Map<T, Widget> children;
  final T groupValue;
  final ValueChanged<T?> onValueChanged;
  final Color? selectedColor;
  final Color? backgroundColor;

  const IOSSegmentedControl({
    Key? key,
    required this.children,
    required this.groupValue,
    required this.onValueChanged,
    this.selectedColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? AppColors.primaryDark : AppColors.primaryLight;

    return CupertinoSlidingSegmentedControl<T>(
      groupValue: groupValue,
      children: children,
      onValueChanged: onValueChanged,
      thumbColor: selectedColor ?? primaryColor,
      backgroundColor:
          backgroundColor ??
          (isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA)),
    );
  }
}
