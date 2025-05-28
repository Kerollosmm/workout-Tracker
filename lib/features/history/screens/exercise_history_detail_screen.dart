import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/core/models/workout_set.dart';
import 'package:workout_tracker/core/providers/workout_provider.dart';
import 'package:workout_tracker/core/providers/settings_provider.dart'; // For weight unit

class ExerciseHistoryDetailScreen extends StatelessWidget {
  final String exerciseName;

  const ExerciseHistoryDetailScreen({Key? key, required this.exerciseName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context); // Get settings provider
    final allWorkouts = workoutProvider.workouts;

    // Updated 2025-05-28: Structure to hold dated sets for the specific exercise
    final List<Map<String, dynamic>> exerciseEntries = [];

    for (var workout in allWorkouts) {
      for (var exerciseInWorkout in workout.exercises) {
        if (exerciseInWorkout.exerciseName == exerciseName) {
          for (var set in exerciseInWorkout.sets) {
            if (set.reps > 0) { // Only include sets with completed reps
              exerciseEntries.add({
                'date': workout.date,
                'set': set,
              });
            }
          }
        }
      }
    }

    // Sort entries by date, most recent first
    exerciseEntries.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          exerciseName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: exerciseEntries.isEmpty
          ? Center(
              child: Text(
                'No history found for $exerciseName.',
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: exerciseEntries.length,
              itemBuilder: (context, index) {
                final entry = exerciseEntries[index];
                final DateTime date = entry['date'];
                final WorkoutSet set = entry['set'];
                final String weightUnit = settingsProvider.weightUnit;

                // Updated 2025-05-28: Determine difficulty tag based on isHardSet
                final String difficultyTag = set.isHardSet ? 'Hard' : 'Normal';
                final Color difficultyColor = set.isHardSet ? Colors.redAccent : Colors.green;

                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMM d, yyyy - hh:mm a').format(date),
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${set.reps} reps at ${set.weight.toStringAsFixed(1)} $weightUnit',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: difficultyColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: difficultyColor, width: 1),
                              ),
                              child: Text(
                                difficultyTag,
                                style: TextStyle(
                                  color: difficultyColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (set.notes != null && set.notes!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Notes: ${set.notes}',
                              style: TextStyle(color: Colors.grey[500], fontSize: 13, fontStyle: FontStyle.italic),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
