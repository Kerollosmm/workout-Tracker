import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/workout.dart';
import '../../../config/constants/app_constants.dart';
import '../../custom_workout/screens/workout_editor_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/workout_provider.dart';

class DayWorkoutsWidget extends StatelessWidget {
  final List<Workout> workouts;

  const DayWorkoutsWidget({Key? key, required this.workouts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No workouts today', style: TextStyle(color: Colors.grey)),
      );
    }
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius_l),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header with total stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d').format(
                        workouts.isNotEmpty
                            ? workouts.first.date
                            : DateTime.now(),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${workouts.length} ${workouts.length == 1 ? 'workout' : 'workouts'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WorkoutEditorScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // List of all workouts for the day
            ...workouts
                .map((workout) => _buildWorkoutItem(context, workout))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutItem(BuildContext context, Workout workout) {
    final timeStr = DateFormat('h:mm a').format(workout.date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (workouts.indexOf(workout) > 0) const Divider(height: 24),

        // Workout header with time and actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppTheme.textSecondaryLight,
                ),
                const SizedBox(width: 4),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(workout.duration),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => WorkoutEditorScreen(workout: workout),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  onPressed: () => _confirmDeleteWorkout(context, workout),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // All exercises in this workout
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...workout.exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index > 0) const Divider(height: 24),

                    // Exercise header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.getColorForMuscleGroup(
                              exercise.muscleGroup,
                            ).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.fitness_center,
                            color: AppTheme.getColorForMuscleGroup(
                              exercise.muscleGroup,
                            ),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.exerciseName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                exercise.muscleGroup,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${exercise.sets.length} sets',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Exercise sets in a grid
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          exercise.sets.asMap().entries.map((setEntry) {
                            final setIndex = setEntry.key;
                            final set = setEntry.value;

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${setIndex + 1}. ',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${set.weight}kg × ${set.reps}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  if (set.isHardSet) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.star,
                                      size: 12,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _confirmDeleteWorkout(BuildContext context, Workout workout) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Workout'),
            content: const Text(
              'Are you sure you want to delete this workout? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final workoutProvider = Provider.of<WorkoutProvider>(
                    context,
                    listen: false,
                  );
                  workoutProvider.deleteWorkout(workout.id);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
