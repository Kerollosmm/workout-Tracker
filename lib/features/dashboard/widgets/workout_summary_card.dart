import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_tracker/config/constants/app_constants.dart';
import '../../../config/themes/app_theme.dart';
import '../../../core/models/workout.dart';
import '../../../core/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class WorkoutSummaryCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;

  const WorkoutSummaryCard({
    Key? key,
    required this.workout,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

    final totalExercises = workout.exercises.length;
    final totalSets = workout.totalSets;
    final totalWeightLifted = workout.totalWeightLifted;

    final muscleGroupCounts = <String, int>{};
    for (final exercise in workout.exercises) {
      muscleGroupCounts[exercise.muscleGroup] =
          (muscleGroupCounts[exercise.muscleGroup] ?? 0) + 1;
    }

    final primaryMuscleGroup = muscleGroupCounts.isEmpty
        ? 'N/A'
        : muscleGroupCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

    final muscleGroupColor = AppTheme.getColorForMuscleGroup(primaryMuscleGroup);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Container(
              decoration: BoxDecoration(
                color: muscleGroupColor.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        dateFormat.format(workout.date),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: muscleGroupColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      primaryMuscleGroup,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Time
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        timeFormat.format(workout.date),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  /// Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat(context, '$totalExercises', 'Exercises'),
                      _buildStat(context, '$totalSets', 'Sets'),
                      _buildStat(context,
                          '${totalWeightLifted.toStringAsFixed(0)}', settingsProvider.weightUnit),
                    ],
                  ),

                  /// Exercises List Preview
                  if (workout.exercises.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Divider(color: Colors.grey[300], height: 1),
                    const SizedBox(height: 10),
                    ...workout.exercises.take(2).map(
                      (exercise) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.fitness_center,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                exercise.exerciseName,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${exercise.sets.length} sets',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (workout.exercises.length > 2)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+ ${workout.exercises.length - 2} more exercises',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}
