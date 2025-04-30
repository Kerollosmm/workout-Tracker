// lib/features/dashboard/widgets/quick_stats_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/config/constants/app_constants.dart';
import '../../../config/themes/app_theme.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/analytics_provider.dart';
import '../../../utils/formatters.dart';

class QuickStatsWidget extends StatefulWidget {
  final int totalSets;
  final double totalWeight;

  const QuickStatsWidget({
    Key? key,
    required this.totalSets,
    required this.totalWeight,
  }) : super(key: key);

  @override
  State<QuickStatsWidget> createState() => _QuickStatsWidgetState();
}

class _QuickStatsWidgetState extends State<QuickStatsWidget> {
  Map<String, dynamic> _statsCache = {};
  DateTime? _lastUpdate;
  final _cacheTimeout = const Duration(minutes: 5);

  bool _shouldUpdateCache() {
    return _lastUpdate == null || 
           DateTime.now().difference(_lastUpdate!) > _cacheTimeout;
  }

  void _updateCache(WorkoutProvider workoutProvider) {
    final today = DateTime.now();
    _statsCache = {
      'totalVolume': _calculateTotalVolume(workoutProvider, today),
      'caloriesBurned': _calculateCaloriesBurned(workoutProvider, today),
      'mostTrainedExercise': _getMostTrainedExercise(workoutProvider),
    };
    _lastUpdate = DateTime.now();
  }

  double _calculateTotalVolume(WorkoutProvider provider, DateTime date) {
    final workouts = provider.getWorkoutsForDay(date);
    return workouts.fold(0.0, (total, workout) =>
      total + workout.exercises.fold(0.0, (exerciseTotal, exercise) =>
        exerciseTotal + exercise.sets.fold(0.0, (setTotal, set) =>
          setTotal + (set.weight * set.reps)
        )
      )
    );
  }

  int _calculateCaloriesBurned(WorkoutProvider provider, DateTime date) {
    final workouts = provider.getWorkoutsForDay(date);
    // Simple estimation: 3 calories per rep with weight
    return workouts.fold(0, (total, workout) =>
      total + workout.exercises.fold(0, (exerciseTotal, exercise) =>
        exerciseTotal + exercise.sets.fold(0, (setTotal, set) =>
          setTotal + (set.reps * 3)
        )
      )
    );
  }

// 2. In the _getMostTrainedExercise method of quick_stats_widget.dart:
Map<String, dynamic> _getMostTrainedExercise(WorkoutProvider provider) {
  final exerciseCounts = <String, int>{};
  final exerciseNames = <String, String>{};
  
  for (final workout in provider.workouts.take(30)) { // Last 30 days
    for (final exercise in workout.exercises) {
      final exerciseId = exercise.exerciseId ?? 'unknown';  // Add null check
      exerciseCounts[exerciseId] = (exerciseCounts[exerciseId] ?? 0) + 1;
      exerciseNames[exerciseId] = exercise.exerciseName;
    }
  }

  if (exerciseCounts.isEmpty) {
    return {'name': 'No exercises yet', 'count': 0};
  }

  final mostTrainedId = exerciseCounts.entries
    .reduce((a, b) => a.value > b.value ? a : b)
    .key;

  return {
    'name': exerciseNames[mostTrainedId] ?? 'Unknown',  // Add null check
    'count': exerciseCounts[mostTrainedId] ?? 0,  // Add null check
  };
}
  @override
  Widget build(BuildContext context) {
    return Consumer3<WorkoutProvider, AnalyticsProvider, SettingsProvider>(
      builder: (context, workoutProvider, analyticsProvider, settingsProvider, _) {
        if (_shouldUpdateCache()) {
          _updateCache(workoutProvider);
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Sets',
                    widget.totalSets.toString(),
                    Icons.fitness_center,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: AppTheme.spacing_m),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Volume',
                    '${_statsCache['totalVolume']?.toStringAsFixed(1)} ${settingsProvider.weightUnit}',
                    Icons.monitor_weight,
                    Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing_m),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Calories',
                    '${_statsCache['caloriesBurned']} cal',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                SizedBox(width: AppTheme.spacing_m),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Most Trained',
                    _statsCache['mostTrainedExercise']?['name'] ?? 'None',
                    Icons.star,
                    Colors.purple,
                    subtitle: _statsCache['mostTrainedExercise']?['count'] > 0
                      ? '${_statsCache['mostTrainedExercise']?['count']} times'
                      : null,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}