import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/workout.dart';
import '../models/workout_set.dart';

class WorkoutProvider with ChangeNotifier {
  final Box<Workout> _workoutsBox = Hive.box<Workout>('workouts');
  final uuid = Uuid();

  List<Workout> get workouts {
    // Return sorted workouts by date (newest first)
    final workoutsList = _workoutsBox.values.toList();
    workoutsList.sort((a, b) => b.date.compareTo(a.date));
    return workoutsList;
  }

  double getTotalWeightLifted(DateTime? date) {
    double total = 0;
    
    final relevantWorkouts = date != null 
        ? _getWorkoutsForDate(date)
        : workouts;

    for (final workout in relevantWorkouts) {
      total += _calculateWorkoutWeight(workout);
    }
    
    return total;
  }

  double getEffectiveWeightLifted(DateTime? date) {
    double total = 0;
    
    final relevantWorkouts = date != null 
        ? _getWorkoutsForDate(date)
        : workouts;

    for (final workout in relevantWorkouts) {
      total += _calculateEffectiveWeight(workout);
    }
    
    return total;
  }

  int getTotalSets(DateTime? date) {
    int total = 0;
    
    final relevantWorkouts = date != null 
        ? _getWorkoutsForDate(date)
        : workouts;

    for (final workout in relevantWorkouts) {
      total += _calculateTotalSets(workout);
    }
    
    return total;
  }

  int getHardSetCount(DateTime? date) {
    int total = 0;
    
    final relevantWorkouts = date != null 
        ? _getWorkoutsForDate(date)
        : workouts;

    for (final workout in relevantWorkouts) {
      total += _calculateHardSets(workout);
    }
    
    return total;
  }

  // Private helper methods for calculations
  List<Workout> _getWorkoutsForDate(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(Duration(days: 1));
    
    return workouts.where((w) =>
      w.date.isAfter(dayStart.subtract(Duration(seconds: 1))) &&
      w.date.isBefore(dayEnd)
    ).toList();
  }

  double _calculateWorkoutWeight(Workout workout) {
    double total = 0;
    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        if (set.weight > 0 && set.reps > 0) {
          total += set.weight * set.reps;
        }
      }
    }
    return total;
  }

  double _calculateEffectiveWeight(Workout workout) {
    double total = 0;
    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        if (set.isHardSet) {
          total += set.weight * set.reps;
        }
      }
    }
    return total;
  }

  int _calculateTotalSets(Workout workout) {
    int total = 0;
    for (final exercise in workout.exercises) {
      total += exercise.sets.length;
    }
    return total;
  }

  int _calculateHardSets(Workout workout) {
    int total = 0;
    for (final exercise in workout.exercises) {
      total += exercise.sets.where((set) => set.isHardSet).length;
    }
    return total;
  }

  // CRUD operations
  Future<void> addWorkout(Workout workout) async {
    try {
      await _workoutsBox.add(workout);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding workout: $e');
      rethrow;
    }
  }

  Future<void> updateWorkout(Workout workout) async {
    try {
      // Find the workout in the box
      final workoutInBox = _workoutsBox.values.firstWhere(
        (w) => w.id == workout.id,
        orElse: () => throw Exception('Workout not found'),
      );
      
      // Get the key for this workout
      final key = workoutInBox.key;
      
      // Update the workout at this key
      await _workoutsBox.put(key, workout);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating workout: $e');
      rethrow;
    }
  }

  Future<void> deleteWorkout(String id) async {
    try {
      // Find the workout in the box
      final workoutInBox = _workoutsBox.values.firstWhere(
        (w) => w.id == id,
        orElse: () => throw Exception('Workout not found'),
      );
      
      // Get the key for this workout
      final key = workoutInBox.key;
      
      // Delete the workout using its key
      await _workoutsBox.delete(key);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting workout: $e');
      rethrow;
    }
  }

  // Get exercise performance data for charts
  List<Map<String, dynamic>> getExerciseProgressData(String exerciseId, {int limit = 10}) {
    final data = <Map<String, dynamic>>[];
    
    // Find workouts containing this exercise
    final workoutsWithExercise = workouts.where((w) => 
      w.exercises.any((e) => e.exerciseId == exerciseId)
    ).toList();
    
    // Sort by date
    workoutsWithExercise.sort((a, b) => a.date.compareTo(b.date));
    
    // Take only the most recent ones based on limit
    final limitedWorkouts = workoutsWithExercise.length > limit 
        ? workoutsWithExercise.sublist(workoutsWithExercise.length - limit) 
        : workoutsWithExercise;
    
    for (var workout in limitedWorkouts) {
      final exercise = workout.exercises.firstWhere((e) => e.exerciseId == exerciseId);
      
      // Calculate max weight for this exercise in this workout
      if (exercise.sets.isNotEmpty) {
        final maxWeight = exercise.sets.reduce((curr, next) => 
          curr.weight > next.weight ? curr : next
        ).weight;
        
        data.add({
          'date': workout.date,
          'weight': maxWeight,
        });
      }
    }
    
    return data;
  }
  
  // Get distribution of muscle groups trained
  Map<String, int> getMuscleGroupDistribution() {
    final distribution = <String, int>{};
    
    for (var workout in workouts) {
      for (var exercise in workout.exercises) {
        if (distribution.containsKey(exercise.muscleGroup)) {
          distribution[exercise.muscleGroup] = distribution[exercise.muscleGroup]! + 1;
        } else {
          distribution[exercise.muscleGroup] = 1;
        }
      }
    }
    
    return distribution;
  }
}
