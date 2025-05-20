import 'package:flutter/material.dart';

// Updated 2025-05-20: Created reusable list tile component for consistent UI across the app
class CustomListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? contentPadding;
  final BorderRadius? borderRadius;
  final bool dense;
  final bool selected;
  final Color? selectedColor;
  final bool hasBorder;
  final Color? borderColor;
  final double borderWidth;

  const CustomListTile({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.contentPadding,
    this.borderRadius,
    this.dense = false,
    this.selected = false,
    this.selectedColor,
    this.hasBorder = false,
    this.borderColor,
    this.borderWidth = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(10);
    
    final effectiveSelectedColor = selectedColor ?? theme.colorScheme.primary.withOpacity(0.1);
    final effectiveBackgroundColor = selected 
        ? effectiveSelectedColor 
        : (backgroundColor ?? theme.colorScheme.surface);
    
    return Material(
      color: effectiveBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: effectiveBorderRadius,
        side: hasBorder 
            ? BorderSide(
                color: borderColor ?? theme.dividerColor,
                width: borderWidth,
              )
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: effectiveBorderRadius,
        child: Padding(
          padding: contentPadding ?? 
              EdgeInsets.symmetric(horizontal: 16, vertical: dense ? 8 : 12),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 16),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
