import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/workout.dart';
import '../../../core/providers/workout_provider.dart';

class WorkoutSummaryCard extends StatefulWidget {
  final Workout workout;
  final VoidCallback? onTap;

  const WorkoutSummaryCard({
    Key? key,
    required this.workout,
    this.onTap,
  }) : super(key: key);

  @override
  State<WorkoutSummaryCard> createState() => _WorkoutSummaryCardState();
}

class _WorkoutSummaryCardState extends State<WorkoutSummaryCard> {
  late Map<String, dynamic> _metrics;
  late Map<String, dynamic> _monthBest;

  @override
  void initState() {
    super.initState();
    _calculateMetrics();
  }

  @override
  void didUpdateWidget(WorkoutSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workout != widget.workout) {
      setState(() {
        _calculateMetrics();
      });
    }
  }

  void _calculateMetrics() {
    final totalExercises = widget.workout.exercises.length;
    final totalSets = widget.workout.totalSets;
    final totalWeightLifted = widget.workout.totalWeightLifted;
    final totalDuration = widget.workout.exercises.fold<int>(
      0,
      (sum, exercise) => sum + (exercise.sets.length * 60), // Assuming 1 min per set
    );

    _metrics = {
      'totalExercises': totalExercises,
      'totalSets': totalSets,
      'totalWeightLifted': totalWeightLifted,
      'totalDuration': totalDuration,
    };
  }

  Map<String, dynamic> _calculateMonthBest(WorkoutProvider provider) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    var bestSets = 0;
    var bestWeight = 0.0;
    var bestDuration = 0;

    for (final workout in provider.workouts) {
      if (workout.date.isAfter(startOfMonth) && workout.date.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        // Update best sets
        if (workout.totalSets > bestSets) {
          bestSets = workout.totalSets;
        }
        // Update best weight
        if (workout.totalWeightLifted > bestWeight) {
          bestWeight = workout.totalWeightLifted;
        }
        // Update best duration
        final duration = workout.exercises.fold<int>(
          0,
          (sum, exercise) => sum + (exercise.sets.length * 60),
        );
        if (duration > bestDuration) {
          bestDuration = duration;
        }
      }
    }

    return {
      'bestSets': bestSets,
      'bestWeight': bestWeight,
      'bestDuration': bestDuration,
    };
  }

  Widget _buildProgressIndicator({
    required double value,
    required Color color,
    required IconData icon,
    required String label,
    required String sublabel,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: value.clamp(0.0, 1.0),
                strokeWidth: 8,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Icon(icon, color: color, size: 24),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          sublabel,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildIndicators(WorkoutProvider provider) {
    final monthBest = _calculateMonthBest(provider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildProgressIndicator(
          value: monthBest['bestSets'] > 0
            ? _metrics['totalSets'] / monthBest['bestSets']
            : 0,
          color: Colors.green,
          icon: Icons.directions_walk,
          label: '${_metrics['totalSets']}/${monthBest['bestSets']}',
          sublabel: 'Sets',
        ),
        _buildProgressIndicator(
          value: monthBest['bestWeight'] > 0
            ? _metrics['totalWeightLifted'] / monthBest['bestWeight']
            : 0,
          color: Colors.orange,
          icon: Icons.local_fire_department,
          label: '${_metrics['totalWeightLifted'].toInt()}/${monthBest['bestWeight'].toInt()}',
          sublabel: 'kg',
        ),
        _buildProgressIndicator(
          value: monthBest['bestDuration'] > 0
            ? _metrics['totalDuration'] / monthBest['bestDuration']
            : 0,
          color: Colors.blue,
          icon: Icons.timer,
          label: '${(_metrics['totalDuration'] ~/ 60)}/${(monthBest['bestDuration'] ~/ 60)}',
          sublabel: 'min',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: const Color(0xFF1C1C1E),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Activity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'vs Monthly Best',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Consumer<WorkoutProvider>(
              builder: (context, provider, _) => _buildIndicators(provider),
            ),
          ],
        ),
      ),
    );
  }
} 