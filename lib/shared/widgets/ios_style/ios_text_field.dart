import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

// Updated 2025-05-20: Fixed imports to correctly reference AppColors

// Updated 2025-05-20: Created iOS-style text field component for consistent iOS look and feel
class IOSTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? label;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final Widget? prefix;
  final Widget? suffix;
  final int? maxLines;
  final int? maxLength;
  final bool autocorrect;
  final bool enabled;
  final String? errorText;

  const IOSTextField({
    Key? key,
    this.controller,
    this.placeholder,
    this.label,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onEditingComplete,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.maxLength,
    this.autocorrect = true,
    this.enabled = true,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Color definitions using our app colors
    final placeholderColor = isDarkMode
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    
    final backgroundColor = isDarkMode
        ? AppColors.surfaceDark
        : const Color(0xFFF2F2F7);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDarkMode
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          prefix: prefix != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: prefix,
                )
              : null,
          suffix: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: suffix,
                )
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          maxLines: maxLines,
          maxLength: maxLength,
          autocorrect: autocorrect,
          enabled: enabled,
          placeholderStyle: TextStyle(
            color: placeholderColor,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: errorText != null
                  ? AppColors.errorLight
                  : isDarkMode
                      ? AppColors.dividerDark
                      : AppColors.dividerLight,
            ),
          ),
          style: TextStyle(
            color: isDarkMode
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6.0, left: 4.0),
            child: Text(
              errorText!,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? AppColors.errorDark
                    : AppColors.errorLight,
              ),
            ),
          ),
      ],
    );
  }
}
