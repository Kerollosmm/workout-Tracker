import 'package:flutter/material.dart';

// Updated 2025-05-20: Created reusable button component with multiple variants
// to ensure UI consistency across the app
enum ButtonSize { small, medium, large }
enum ButtonVariant { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine button size
    EdgeInsets buttonPadding;
    double fontSize;
    double iconSize;
    
    switch (size) {
      case ButtonSize.small:
        buttonPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        fontSize = 14;
        iconSize = 16;
        break;
      case ButtonSize.large:
        buttonPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
        fontSize = 18;
        iconSize = 24;
        break;
      case ButtonSize.medium:
      default:
        buttonPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
        fontSize = 16;
        iconSize = 20;
        break;
    }
    
    // Apply custom padding if provided
    final effectivePadding = padding ?? buttonPadding;
    
    // Apply custom border radius if provided
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(10);
    
    // Content with loading indicator or icon + text
    Widget content;
    if (isLoading) {
      content = SizedBox(
        height: iconSize,
        width: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == ButtonVariant.primary || variant == ButtonVariant.secondary
                ? Colors.white
                : theme.colorScheme.primary,
          ),
        ),
      );
    } else {
      final textColor = _getTextColor(theme);
      
      if (icon != null) {
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: textColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        );
      } else {
        content = Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        );
      }
    }

    // Button wrapper
    Widget button;
    
    switch (variant) {
      case ButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: effectivePadding,
            shape: RoundedRectangleBorder(
              borderRadius: effectiveBorderRadius,
            ),
            elevation: 1,
          ),
          child: content,
        );
        break;
        
      case ButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: Colors.white,
            padding: effectivePadding,
            shape: RoundedRectangleBorder(
              borderRadius: effectiveBorderRadius,
            ),
            elevation: 1,
          ),
          child: content,
        );
        break;
        
      case ButtonVariant.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            padding: effectivePadding,
            side: BorderSide(color: theme.colorScheme.primary),
            shape: RoundedRectangleBorder(
              borderRadius: effectiveBorderRadius,
            ),
          ),
          child: content,
        );
        break;
        
      case ButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            padding: effectivePadding,
            shape: RoundedRectangleBorder(
              borderRadius: effectiveBorderRadius,
            ),
          ),
          child: content,
        );
        break;
    }
    
    // Handle full width mode
    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    
    return button;
  }
  
  Color _getTextColor(ThemeData theme) {
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
        return Colors.white;
      case ButtonVariant.outline:
      case ButtonVariant.text:
        return theme.colorScheme.primary;
    }
  }
}
