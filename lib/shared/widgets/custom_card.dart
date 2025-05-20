import 'package:flutter/material.dart';

// Updated 2025-05-20: Created reusable card component with multiple variants
// for consistent UI elements across the app
enum CardVariant { elevated, outlined, filled, minimal }

class CustomCard extends StatelessWidget {
  final Widget child;
  final CardVariant variant;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final double elevation;
  final VoidCallback? onTap;
  final bool hasBorder;
  final Color? borderColor;

  const CustomCard({
    Key? key,
    required this.child,
    this.variant = CardVariant.elevated,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.elevation = 1,
    this.onTap,
    this.hasBorder = false,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);
    
    // Determine card styling based on variant
    Color effectiveBackgroundColor;
    double effectiveElevation;
    BorderSide borderSide = BorderSide.none;
    
    switch (variant) {
      case CardVariant.elevated:
        effectiveBackgroundColor = backgroundColor ?? theme.cardTheme.color ?? theme.colorScheme.surface;
        effectiveElevation = elevation;
        break;
      case CardVariant.outlined:
        effectiveBackgroundColor = backgroundColor ?? theme.cardTheme.color ?? theme.colorScheme.surface;
        effectiveElevation = 0;
        borderSide = BorderSide(
          color: borderColor ?? theme.dividerColor,
          width: 1.0,
        );
        break;
      case CardVariant.filled:
        effectiveBackgroundColor = backgroundColor ?? 
          theme.colorScheme.primary.withOpacity(0.1);
        effectiveElevation = 0;
        break;
      case CardVariant.minimal:
        effectiveBackgroundColor = backgroundColor ?? Colors.transparent;
        effectiveElevation = 0;
        break;
    }
    
    // Add border if specified
    if (hasBorder) {
      borderSide = BorderSide(
        color: borderColor ?? theme.dividerColor,
        width: 1.0,
      );
    }
    
    final cardContent = Padding(
      padding: padding,
      child: child,
    );
    
    // Apply tap behavior if onTap is provided
    if (onTap != null) {
      return Material(
        color: effectiveBackgroundColor,
        elevation: effectiveElevation,
        borderRadius: effectiveBorderRadius,
        shape: RoundedRectangleBorder(
          borderRadius: effectiveBorderRadius,
          side: borderSide,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          child: cardContent,
        ),
      );
    }
    
    // Regular card without tap behavior
    return Material(
      color: effectiveBackgroundColor,
      elevation: effectiveElevation,
      borderRadius: effectiveBorderRadius,
      shape: RoundedRectangleBorder(
        borderRadius: effectiveBorderRadius,
        side: borderSide,
      ),
      clipBehavior: Clip.antiAlias,
      child: cardContent,
    );
  }
}
