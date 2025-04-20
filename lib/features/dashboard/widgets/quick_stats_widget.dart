// lib/features/dashboard/widgets/quick_stats_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/config/constants/app_constants.dart';
import '../../../config/themes/app_theme.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/analytics_provider.dart';
import '../../../utils/formatters.dart';
import '../providers/dashboard_provider.dart';

class QuickStatsWidget extends StatelessWidget {
  final int totalSets;
  final double totalWeight;

  const QuickStatsWidget({
    Key? key,
    required this.totalSets,
    required this.totalWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final analyticsProvider = Provider.of<AnalyticsProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final dashboardProvider = Provider.of<DashboardProvider>(context);

    // Get most trained exercise info
    final mostTrainedExercise = analyticsProvider.getMostTrainedExercise();

    // Calculate total volume for today (sets x reps x load)
    final today = DateTime.now();
    final totalVolume = _calculateTotalVolume(workoutProvider, today);
    
    // Get calories burned today
    final caloriesBurned = dashboardProvider.getDailyCaloriesBurned(today);

    return Column(
      children: [
        Row(
          children: [
            // Total Sets Card
            Expanded(
              child: _buildStatCard(
                context,
                'Total Sets',
                totalSets.toString(),
                Icons.fitness_center,
                Colors.blue,
              ),
            ),
            SizedBox(width: AppTheme.spacing_m),
            // Total Weight Card
            Expanded(
              child: _buildStatCard(
                context,
                'Weight Lifted',
                '${totalVolume.toStringAsFixed(1)} ${settingsProvider.weightUnit}',
                Icons.monitor_weight,
                Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacing_m),
        Row(
          children: [
            // Calories Burned Card
            Expanded(
              child: _buildStatCard(
                context,
                'Calories Burned',
                '${caloriesBurned.toInt()} cal',
                Icons.local_fire_department,
                Colors.orange,
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacing_m),
        // Most Trained Exercise Card
        _buildMostTrainedCard(context, mostTrainedExercise),
      ],
    );
  }

  // Helper to calculate total volume (sets x reps x load) for a given day
  double _calculateTotalVolume(WorkoutProvider workoutProvider, DateTime day) {
    final workouts = workoutProvider.workouts.where((w) =>
      w.date.year == day.year && w.date.month == day.month && w.date.day == day.day
    );
    double total = 0;
    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        for (final set in exercise.sets) {
          total += set.weight * set.reps;
        }
      }
    }
    return total;
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              iconColor.withOpacity(0.1),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 20, color: iconColor),
                  ),
                  SizedBox(width: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMostTrainedCard(BuildContext context, Map<String, dynamic> exerciseData) {
    final muscleGroup = exerciseData['muscleGroup'] as String? ?? '';
    final muscleGroupColor = AppTheme.getColorForMuscleGroup(muscleGroup);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius_l),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing_m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 18),
                SizedBox(width: 8),
                Text(
                  'Most Trained Exercise',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exerciseData['name'] as String? ?? 'None',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (muscleGroup.isNotEmpty)
                        Chip(
                          label: Text(
                            muscleGroup,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: muscleGroupColor,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                    ],
                  ),
                ),
                Text(
                  '${exerciseData['count']} sessions',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}