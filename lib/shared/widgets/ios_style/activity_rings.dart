import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

// Updated 2025-05-20: Created iOS-style activity rings component for fitness tracking visualization
class ActivityRings extends StatelessWidget {
  final double movePercentage;
  final double exercisePercentage;
  final double standPercentage;
  final double size;
  final Color moveColor;
  final Color exerciseColor;
  final Color standColor;
  final double strokeWidth;

  const ActivityRings({
    Key? key,
    required this.movePercentage,
    required this.exercisePercentage,
    required this.standPercentage,
    this.size = 200,
    this.moveColor = const Color(0xFFFF375F),
    this.exerciseColor = const Color(0xFF75FB4C),
    this.standColor = const Color(0xFF33E5F7),
    this.strokeWidth = 20,
  }) : assert(movePercentage >= 0 && movePercentage <= 1 &&
              exercisePercentage >= 0 && exercisePercentage <= 1 &&
              standPercentage >= 0 && standPercentage <= 1,
              'Percentage values must be between 0.0 and 1.0'),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ActivityRingsPainter(
          movePercentage: movePercentage,
          exercisePercentage: exercisePercentage,
          standPercentage: standPercentage,
          moveColor: moveColor,
          exerciseColor: exerciseColor,
          standColor: standColor,
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: Container(
            width: size - (strokeWidth * 3) - 10,
            height: size - (strokeWidth * 3) - 10,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityRingsPainter extends CustomPainter {
  final double movePercentage;
  final double exercisePercentage;
  final double standPercentage;
  final Color moveColor;
  final Color exerciseColor;
  final Color standColor;
  final double strokeWidth;

  _ActivityRingsPainter({
    required this.movePercentage,
    required this.exercisePercentage,
    required this.standPercentage,
    required this.moveColor,
    required this.exerciseColor,
    required this.standColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - strokeWidth / 2;
    final middleRadius = outerRadius - strokeWidth - 2;
    final innerRadius = middleRadius - strokeWidth - 2;

    // Draw background arcs
    _drawBackgroundArc(canvas, center, outerRadius, moveColor.withOpacity(0.2));
    _drawBackgroundArc(canvas, center, middleRadius, exerciseColor.withOpacity(0.2));
    _drawBackgroundArc(canvas, center, innerRadius, standColor.withOpacity(0.2));

    // Draw progress arcs
    _drawProgressArc(canvas, center, outerRadius, movePercentage, moveColor);
    _drawProgressArc(canvas, center, middleRadius, exercisePercentage, exerciseColor);
    _drawProgressArc(canvas, center, innerRadius, standPercentage, standColor);
  }

  void _drawBackgroundArc(Canvas canvas, Offset center, double radius, Color color) {
    final backgroundPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      math.pi * 2, // Full circle
      false,
      backgroundPaint,
    );
  }

  void _drawProgressArc(Canvas canvas, Offset center, double radius, double percentage, Color color) {
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      math.pi * 2 * percentage, // Arc based on percentage
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ActivityRingsPainter oldDelegate) =>
      oldDelegate.movePercentage != movePercentage ||
      oldDelegate.exercisePercentage != exercisePercentage ||
      oldDelegate.standPercentage != standPercentage;
}
