import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Updated 2025-05-20: Created reusable text field component with multiple configurations
// to ensure UI consistency across the app
class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final BorderRadius? borderRadius;
  final bool filled;
  final Color? fillColor;
  final bool dense;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;

  const CustomTextField({
    Key? key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.borderRadius,
    this.filled = true,
    this.fillColor,
    this.dense = false,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(10);
    
    // Default borders
    final defaultBorder = OutlineInputBorder(
      borderRadius: effectiveBorderRadius,
      borderSide: BorderSide(color: theme.dividerColor),
    );
    
    final defaultFocusedBorder = OutlineInputBorder(
      borderRadius: effectiveBorderRadius,
      borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
    );
    
    final defaultErrorBorder = OutlineInputBorder(
      borderRadius: effectiveBorderRadius,
      borderSide: BorderSide(color: theme.colorScheme.error),
    );
    
    // Default padding based on density
    final defaultPadding = dense 
      ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
      : const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: enabled 
                ? theme.textTheme.bodyLarge?.color 
                : theme.disabledColor,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          readOnly: readOnly,
          enabled: enabled,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          onChanged: onChanged,
          onTap: onTap,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          inputFormatters: inputFormatters,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: enabled 
              ? theme.textTheme.bodyLarge?.color
              : theme.disabledColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            errorText: errorText,
            prefix: prefix,
            suffix: suffix,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: contentPadding ?? defaultPadding,
            prefixIconConstraints: prefixIconConstraints,
            suffixIconConstraints: suffixIconConstraints,
            filled: filled,
            fillColor: fillColor ?? (theme.brightness == Brightness.light 
              ? theme.colorScheme.surface
              : theme.colorScheme.surface.withOpacity(0.8)),
            isDense: dense,
            border: border ?? defaultBorder,
            enabledBorder: enabledBorder ?? defaultBorder,
            focusedBorder: focusedBorder ?? defaultFocusedBorder,
            errorBorder: errorBorder ?? defaultErrorBorder,
            focusedErrorBorder: defaultErrorBorder,
            errorStyle: TextStyle(color: theme.colorScheme.error),
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
            ),
          ),
        ),
      ],
    );
  }
}
