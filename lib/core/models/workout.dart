import 'package:hive/hive.dart';
import 'workout_set.dart';
part 'workout.g.dart';

@HiveType(typeId: 1)
class Workout extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<WorkoutExercise> exercises;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? completedAt;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  String? notes;

  Workout({
    required this.id,
    required this.name,
    required this.exercises,
    required this.createdAt,
    this.completedAt,
    required this.date,
    this.notes,
  });

  // Helper methods to calculate workout stats
  double get totalWeightLifted {
    double total = 0;
    for (final exercise in exercises) {
      for (final set in exercise.sets) {
        if (set.weight > 0) {
          total += set.weight;
        }
      }
    }
    return total;
  }

  int get totalSets {
    int total = 0;
    for (final exercise in exercises) {
      total +=
          exercise.sets.where((set) => set.weight > 0 && set.reps > 0).length;
    }
    return total;
  }

  double get effectiveWeightLifted {
    double total = 0;
    for (final exercise in exercises) {
      for (final set in exercise.sets) {
        if (set.isHardSet && set.weight > 0 && set.reps > 0) {
          total += set.weight * set.reps;
        }
      }
    }
    return total;
  }

  int get hardSetCount {
    int total = 0;
    for (final exercise in exercises) {
      total += exercise.sets
          .where((set) => set.isHardSet && set.weight > 0 && set.reps > 0)
          .length;
    }
    return total;
  }

  int get totalDuration {
    return exercises.fold(
        0, (total, exercise) => total + (exercise.duration ?? 0));
  }
  
  // Added duration getter to fix references to workout.duration
  int get duration => totalDuration;

  int get completedExercises {
    return exercises.where((exercise) => exercise.isCompleted).length;
  }

  double get progress {
    return exercises.isEmpty ? 0 : completedExercises / exercises.length;
  }
}

@HiveType(typeId: 2)
class WorkoutExercise extends HiveObject {
  @HiveField(0)
  String exerciseId;

  @HiveField(1)
  String exerciseName;

  @HiveField(2)
  String muscleGroup;

  @HiveField(3)
  List<WorkoutSet> sets;

  @HiveField(4)
  String? notes;

  @HiveField(6)
  int? duration;

  @HiveField(5)
  bool isCompleted;

  WorkoutExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    List<WorkoutSet>? sets,
    this.notes,
    this.duration,
    this.isCompleted = false,
  }) : this.sets = sets ?? [];

  bool get isHardSet => sets.any((set) => set.isHardSet);

  double get totalWeight =>
      sets.fold(0.0, (sum, set) => sum + (set.weight * set.reps));
      
  // Alias for exerciseName to match the expected 'name' getter
  String get name => exerciseName;
  
  // Return reps from the first set, or 0 if no sets exist
  int get reps => sets.isNotEmpty ? sets.first.reps : 0;
  
  // Return weight from the first set, or 0 if no sets exist
  double get weight => sets.isNotEmpty ? sets.first.weight : 0.0;
}
