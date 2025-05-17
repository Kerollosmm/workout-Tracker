import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/workout.dart';
import '../../../core/providers/settings_provider.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    _calculateMetrics();
  }

  @override
  void didUpdateWidget(WorkoutSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workout != widget.workout) {
      _calculateMetrics();
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

    // Calculate muscle group distribution efficiently
    final muscleGroupCounts = widget.workout.exercises.fold<Map<String, int>>(
      {},
      (counts, exercise) {
        counts[exercise.muscleGroup] = (counts[exercise.muscleGroup] ?? 0) + 1;
        return counts;
      },
    );

    final primaryMuscleGroup = muscleGroupCounts.isEmpty
        ? 'N/A'
        : muscleGroupCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

    _metrics = {
      'totalExercises': totalExercises,
      'totalSets': totalSets,
      'totalWeightLifted': totalWeightLifted,
      'totalDuration': totalDuration,
      'primaryMuscleGroup': primaryMuscleGroup,
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

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

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
            const Text(
              'Activity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProgressIndicator(
                  value: _metrics['totalSets'] / 80, // Max sets per workout
                  color: Colors.green,
                  icon: Icons.directions_walk,
                  label: '${_metrics['totalSets']}/80',
                  sublabel: 'Sets',
                ),
                _buildProgressIndicator(
                  value: _metrics['totalWeightLifted'] / 500, // Max weight target
                  color: Colors.orange,
                  icon: Icons.local_fire_department,
                  label: '${_metrics['totalWeightLifted'].toInt()}/500',
                  sublabel: 'kg',
                ),
                _buildProgressIndicator(
                  value: _metrics['totalDuration'] / (30 * 60), // 30 min target
                  color: Colors.blue,
                  icon: Icons.timer,
                  label: '${(_metrics['totalDuration'] ~/ 60)}/30',
                  sublabel: 'min',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
