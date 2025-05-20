import 'package:flutter/material.dart';

class StreakCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subValue;
  final IconData? icon;
  final Color? iconColor;

  const StreakCard({
    Key? key,
    required this.title,
    required this.value,
    this.subValue,
    this.icon,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      // Using a slightly different background color than the main activity card for visual hierarchy
      color: const Color(
        0xFF2C2C2E,
      ), // A common dark grey for secondary cards in iOS
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Consistent corner radius
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize:
              MainAxisSize
                  .min, // Ensure card takes minimum necessary vertical space
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16, // Slightly smaller than main card titles
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                if (icon != null)
                  Icon(
                    icon,
                    color: iconColor ?? Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28, // Prominent value display
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (subValue != null && subValue!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  subValue!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
