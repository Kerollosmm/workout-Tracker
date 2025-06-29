import 'package:flutter/material.dart';
import 'package:workout_tracker/config/themes/app_theme.dart';

class SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? cardColor;
  final double? elevation;
  final ShapeBorder? shape;

  const SectionCard({
    Key? key,
    this.title,
    required this.child,
    this.margin = const EdgeInsets.symmetric(
      horizontal: AppTheme.spacing_m,
      vertical: AppTheme.spacing_s,
    ),
    this.padding = const EdgeInsets.all(AppTheme.spacing_l),
    this.cardColor,
    this.elevation,
    this.shape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor ?? AppTheme.cardColor,
      margin: margin,
      elevation: elevation ?? 0,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
      ),
      child: Padding(
        padding: padding!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null && title!.isNotEmpty) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith( // Changed to titleLarge for more prominence
                      fontWeight: FontWeight.w600, // Kept bold
                      color: AppTheme.primaryTextColor, // Ensured white color for dark theme
                    ),
              ),
              const SizedBox(height: AppTheme.spacing_s), // Reduced spacing after title for compactness
            ],
            child,
          ],
        ),
      ),
    );
  }
}
