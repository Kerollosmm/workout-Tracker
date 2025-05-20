import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

// Updated 2025-05-20: Fixed imports to correctly reference AppColors
// Updated 2025-05-20: Created iOS-style switch component for consistent iOS look and feel
class IOSSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  const IOSSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? AppColors.primaryDark : AppColors.primaryLight;

    return CupertinoSwitch(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor ?? primaryColor,
    );
  }
}
