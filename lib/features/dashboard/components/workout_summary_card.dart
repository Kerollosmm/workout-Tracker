import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // Not strictly needed for the new design with placeholders
import '../../../core/models/workout.dart';
// import '../../../core/providers/workout_provider.dart'; // Not strictly needed for the new design with placeholders

class WorkoutSummaryCard extends StatefulWidget {
  final Workout
  workout; // Kept for potential future use, but not directly used for new UI elements
  final VoidCallback? onTap;

  const WorkoutSummaryCard({Key? key, required this.workout, this.onTap})
    : super(key: key);

  @override
  State<WorkoutSummaryCard> createState() => _WorkoutSummaryCardState();
}

class _WorkoutSummaryCardState extends State<WorkoutSummaryCard> {
  // Removed _metrics, _monthBest, and their calculation methods as they don't fit the new design

  Widget _buildActivityStat({
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(top: 2.0), // Align baseline better
              child: Text(
                unit,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSingleRing({
    required double progress,
    required Color color,
    required double diameter,
    required double thickness,
  }) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: CircularProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        strokeWidth: thickness,
        backgroundColor: color.withOpacity(0.25),
        valueColor: AlwaysStoppedAnimation<Color>(color),
        strokeCap: StrokeCap.round, // Makes the ends of the progress line round
      ),
    );
  }

  Widget _buildFitnessRings() {
    // Placeholder values - ideally, these would come from a provider or the workout model
    final double moveProgress =
        0.85; // Example: 605/600 CAL (capped at 1.0 for display)
    final double exerciseProgress =
        1.0; // Example: 42/30 MIN (capped at 1.0 for display)
    final double standProgress =
        0.7; // Example: 10/6 HRS (capped at 1.0 for display)

    final Color moveColor = Colors.red.shade400; // Standard Apple Fitness Red
    final Color exerciseColor =
        Colors.green.shade400; // Standard Apple Fitness Green
    final Color standColor =
        Colors.cyan.shade400; // Standard Apple Fitness Blue/Cyan

    final double ringThickness = 10.0;
    final double baseRingDiameter = 90.0;

    return SizedBox(
      width:
          baseRingDiameter +
          ringThickness, // Adjusted for strokeCap: StrokeCap.round
      height: baseRingDiameter + ringThickness,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildSingleRing(
            progress: moveProgress,
            color: moveColor,
            diameter: baseRingDiameter,
            thickness: ringThickness,
          ),
          _buildSingleRing(
            progress: exerciseProgress,
            color: exerciseColor,
            diameter: baseRingDiameter - (ringThickness * 2.2),
            thickness: ringThickness,
          ),
          _buildSingleRing(
            progress: standProgress,
            color: standColor,
            diameter: baseRingDiameter - (ringThickness * 4.4),
            thickness: ringThickness,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Placeholder data for stats, matching Figma's visual
    const String moveValue = "605/600";
    const String exerciseValue = "42/30";
    const String standValue = "10/6";

    final Color moveColor = Colors.red.shade400;
    final Color exerciseColor = Colors.green.shade400;
    final Color standColor = Colors.cyan.shade400;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: const Color(0xFF1C1C1E), // Matches Figma's dark card background
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Figma uses 12px
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          16,
        ), // Figma seems to use ~16-20px padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22, // Figma: 20pt, SF Pro Bold
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActivityStat(
                        label: "Move",
                        value: moveValue,
                        unit: "CAL",
                        color: moveColor,
                      ),
                      const SizedBox(height: 10), // Figma: ~12-16px spacing
                      _buildActivityStat(
                        label: "Exercise",
                        value: exerciseValue,
                        unit: "MIN",
                        color: exerciseColor,
                      ),
                      const SizedBox(height: 10),
                      _buildActivityStat(
                        label: "Stand",
                        value: standValue,
                        unit: "HRS",
                        color: standColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildFitnessRings(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
