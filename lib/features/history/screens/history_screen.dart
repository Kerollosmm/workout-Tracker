import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/models/workout.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../core/providers/settings_provider.dart';
import './exercise_history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _uniqueExercisesSummary = [];

  @override
  void initState() {
    super.initState();
    _prepareExerciseSummaries();
  }

  void _prepareExerciseSummaries() {
    final workoutProvider = Provider.of<WorkoutProvider>(
      context,
      listen: false,
    );
    final allWorkouts = workoutProvider.workouts;
    final Map<String, Map<String, dynamic>> exerciseData = {};

    for (var workout in allWorkouts) {
      for (var exercise in workout.exercises) {
        if (exercise.sets.any((s) => s.reps > 0)) {
          if (!exerciseData.containsKey(exercise.exerciseName)) {
            exerciseData[exercise.exerciseName] = {
              'name': exercise.exerciseName,
              'lastPerformed': workout.date,
              'totalSets': 0,
              'icon': _getMuscleGroupIcon(exercise.muscleGroup),
            };
          }
          if (workout.date.isAfter(
            exerciseData[exercise.exerciseName]!['lastPerformed'] as DateTime,
          )) {
            exerciseData[exercise.exerciseName]!['lastPerformed'] =
                workout.date;
          }
          exerciseData[exercise.exerciseName]!['totalSets'] +=
              exercise.sets.where((s) => s.reps > 0).length;
        }
      }
    }
    _uniqueExercisesSummary = exerciseData.values.toList();
    _uniqueExercisesSummary.sort(
      (a, b) => (b['lastPerformed'] as DateTime).compareTo(
        a['lastPerformed'] as DateTime,
      ),
    );
    setState(() {});
  }

  IconData _getMuscleGroupIcon(String muscleGroup) {
    // Updated 2025-05-28: Added more accurate and visually distinct icons for each muscle group
    switch (muscleGroup.toLowerCase()) {
      case 'chest':
        return Icons.self_improvement; // Represents chest with arms
      case 'back':
        return Icons.airline_seat_recline_normal; // Represents back posture
      case 'legs':
        return Icons.directions_run; // Represents legs in motion
      case 'quadriceps':
      case 'quads':
        return Icons.directions_walk; // Represents quads/legs
      case 'hamstrings':
      case 'hams':
        return Icons.directions_walk; // Represents hamstrings/legs
      case 'calves':
        return Icons.directions_walk; // Represents calves/legs
      case 'shoulders':
        return Icons.accessible_forward; // Represents shoulder movement
      case 'delts':
        return Icons.accessible_forward; // Represents deltoids (shoulders)
      case 'biceps':
        return Icons.fitness_center; // Represents arm curls
      case 'triceps':
        return Icons.fitness_center; // Represents arm extensions
      case 'arms':
        return Icons.fitness_center; // Generic arm exercise
      case 'core':
      case 'abs':
      case 'abdominals':
        return Icons.self_improvement; // Represents core/abs
      case 'glutes':
        return Icons.self_improvement; // Represents glutes
      case 'forearms':
        return Icons.gesture; // Represents grip/forearm
      case 'traps':
      case 'trapezius':
        return Icons.airline_seat_recline_normal; // Represents upper back/traps
      case 'lats':
      case 'latissimus dorsi':
        return Icons.airline_seat_recline_normal; // Represents lats
      case 'chest & triceps':
      case 'push':
        return Icons.fitness_center; // Represents push movements
      case 'back & biceps':
      case 'pull':
        return Icons.accessible; // Represents pull movements
      case 'legs & core':
      case 'lower body':
        return Icons.directions_walk; // Represents lower body
      case 'full body':
      case 'total body':
        return Icons.accessibility_new; // Represents full body
      case 'cardio':
      case 'hiit':
        return Icons.directions_run; // Represents cardio
      default:
        return Icons.fitness_center; // Default exercise icon
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button
        title: const Text(
          'Exercise History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // This affects other icons in the app bar
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _prepareExerciseSummaries();
              });
            },
            tooltip: 'Refresh History',
          ),
        ],
      ),
      body:
          _uniqueExercisesSummary.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.history_toggle_off,
                      color: Colors.grey,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No exercise history found.',
                      style: TextStyle(color: Colors.grey[400], fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete some workouts to see your history here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 16.0,
                ),
                itemCount: _uniqueExercisesSummary.length,
                itemBuilder: (context, index) {
                  final summary = _uniqueExercisesSummary[index];
                  final String exerciseName = summary['name'];
                  final DateTime lastPerformed = summary['lastPerformed'];
                  final int totalSets = summary['totalSets'];
                  final IconData icon = summary['icon'];

                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.withOpacity(0.15),
                        child: Icon(icon, color: Colors.green, size: 24),
                      ),
                      title: Text(
                        exerciseName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                      subtitle: Text(
                        'Last: ${DateFormat('MMM d, yyyy').format(lastPerformed)} • Total Sets: $totalSets',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 24,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ExerciseHistoryDetailScreen(
                                  exerciseName: exerciseName,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
