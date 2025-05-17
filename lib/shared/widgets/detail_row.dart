import 'package:flutter/material.dart';

/// A reusable widget for displaying a row with an icon, label, and value.
/// Used across the app for consistent detail presentations.
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final double spacing;

  const DetailRow({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.labelStyle,
    this.valueStyle,
    this.spacing = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: iconColor ?? theme.colorScheme.secondary,
        ),
        SizedBox(width: spacing),
        Text(
          '$label:',
          style: labelStyle ?? theme.textTheme.titleMedium,
        ),
        SizedBox(width: spacing),
        Text(
          value,
          style: valueStyle ?? theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}