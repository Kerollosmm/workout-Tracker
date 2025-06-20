import 'package:hive/hive.dart';
import 'workout_set.dart';
part 'workout.g.dart';

@HiveType(typeId: 2)
class Workout extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  List<WorkoutExercise> exercises;

  @HiveField(3)
  int duration;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final String? workoutName;

  Workout({
    required this.id,
    required this.date,
    required this.exercises,
    this.duration = 0,
    this.notes,
    this.workoutName,
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
      total +=
          exercise.sets
              .where((set) => set.isHardSet && set.weight > 0 && set.reps > 0)
              .length;
    }
    return total;
  }

  // Add a totalDistance property to support dashboard screen
  double get totalDistance {
    // This is a placeholder implementation
    // In a real app, this would likely be calculated from GPS data or specific exercise types
    return 0.0;
  }

  Workout copyWith({
    String? id,
    DateTime? date,
    List<WorkoutExercise>? exercises,
    int? duration,
    String? notes,
    String? workoutName,
  }) {
    return Workout(
      id: id ?? this.id,
      date: date ?? this.date,
      exercises: exercises ?? List.from(this.exercises),
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      workoutName: workoutName ?? this.workoutName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Workout &&
          other.id == id &&
          other.date == date &&
          other.workoutName == workoutName;

  @override
  int get hashCode => Object.hash(id, date, workoutName);

  // Added 2025-05-30: For serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
      'duration': duration,
      'notes': notes,
      'workoutName': workoutName,
    };
  }
}

@HiveType(typeId: 3)
class WorkoutExercise {
  @HiveField(0)
  String exerciseId;

  @HiveField(1)
  String exerciseName;

  @HiveField(2)
  String muscleGroup;

  @HiveField(3)
  List<WorkoutSet> sets;

  @HiveField(4) // Added 2025-05-23: Rest time for this exercise
  final int? restTimeInSeconds;

  WorkoutExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required this.sets,
    this.restTimeInSeconds, // Added 2025-05-23
  });

  WorkoutExercise copyWith({
    String? exerciseId,
    String? exerciseName,
    String? muscleGroup,
    List<WorkoutSet>? sets,
    int? restTimeInSeconds, // Added 2025-05-23
  }) {
    return WorkoutExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      sets: sets ?? List.from(this.sets),
      restTimeInSeconds:
          restTimeInSeconds ?? this.restTimeInSeconds, // Added 2025-05-23
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutExercise &&
        other.exerciseId == exerciseId &&
        other.exerciseName == exerciseName &&
        other.muscleGroup == muscleGroup;
  }

  @override
  int get hashCode => Object.hash(exerciseId, exerciseName, muscleGroup);

  // Added 2025-05-30: Factory constructor for an empty/default instance
  factory WorkoutExercise.empty() {
    return WorkoutExercise(
      exerciseId: '',
      exerciseName: 'Unknown Exercise',
      muscleGroup: 'Unknown',
      sets: [],
      restTimeInSeconds: 60, // Default rest time
    );
  }

  // Added 2025-05-30: For serialization
  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'muscleGroup': muscleGroup,
      'sets': sets.map((set) => set.toMap()).toList(),
      'restTimeInSeconds': restTimeInSeconds,
    };
  }
}
