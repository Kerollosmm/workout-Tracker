import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/workout.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../features/workout_log/screens/workout_details_screen.dart';
import '../../../features/custom_workout/screens/workout_editor_screen.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  
  const WorkoutCard({Key? key, required this.workout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutDetailsScreen(workout: workout),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Workout on ${_formatDate(workout.date)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkoutEditorScreen(workout: workout),
                          ),
                        );
                        
                        if (result == true) {
                          // Refresh will happen automatically via provider
                        }
                      } else if (value == 'delete') {
                        _confirmDeleteWorkout(context);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Duration: ${_formatDuration(workout.duration)}'),
              const SizedBox(height: 4),
              Text('Exercises: ${workout.exercises.length}'),
              const SizedBox(height: 4),
              Text('Total sets: ${_calculateTotalSets()}'),
              if (workout.notes?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Text(
                  'Notes: ${workout.notes}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  int _calculateTotalSets() {
    return workout.exercises.fold(0, (sum, exercise) => sum + exercise.sets.length);
  }

  void _confirmDeleteWorkout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
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