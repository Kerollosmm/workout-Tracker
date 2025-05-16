import 'package:flutter/material.dart';

/// A reusable card widget for displaying sections of content with a consistent style.
/// Used throughout the app for displaying grouped information.
class SectionCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final double childSpacing;
  final TextStyle? titleStyle;

  const SectionCard({
    Key? key,
    this.title,
    required this.children,
    this.padding = const EdgeInsets.all(16.0),
    this.elevation = 2.0,
    this.childSpacing = 8.0,
    this.titleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: elevation,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: titleStyle ?? theme.textTheme.titleLarge,
              ),
              SizedBox(height: childSpacing + 2.0),
            ],
            ...List.generate(children.length * 2 - 1, (index) {
              // Add spacing between children but not after the last child
              if (index.isOdd) {
                return SizedBox(height: childSpacing);
              }
              return children[index ~/ 2];
            }),
          ],
        ),
      ),
    );
  }
}