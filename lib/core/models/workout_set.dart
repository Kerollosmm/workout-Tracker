import 'package:hive/hive.dart';
part 'workout_set.g.dart';

@HiveType(typeId: 1)
class WorkoutSet extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  double weight;

  @HiveField(2)
  int reps;

  @HiveField(3)
  DateTime timestamp;

  // Optional
  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  bool isHardSet;

  WorkoutSet({
    required this.id,
    required this.weight,
    required this.reps,
    required this.timestamp,
    this.isCompleted = true,
    this.notes,
    this.isHardSet = false,
  });

  WorkoutSet copyWith({double? weight, int? reps, bool? isHardSet}) {
    return WorkoutSet(
      id: this.id,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      timestamp: this.timestamp,
      isCompleted: this.isCompleted,
      notes: this.notes,
      isHardSet: isHardSet ?? this.isHardSet,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSet &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          weight == other.weight &&
          reps == other.reps &&
          // Do not compare timestamp for equality in terms of user changes
          // timestamp == other.timestamp &&
          isCompleted == other.isCompleted &&
          notes == other.notes &&
          isHardSet == other.isHardSet;

  @override
  int get hashCode =>
      id.hashCode ^
      weight.hashCode ^
      reps.hashCode ^
      // timestamp.hashCode ^ // See comment above for == operator
      isCompleted.hashCode ^
      notes.hashCode ^
      isHardSet.hashCode;


  // Added 2025-05-30: For serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'reps': reps,
      'timestamp': timestamp.toIso8601String(),
      'isCompleted': isCompleted,
      'notes': notes,
      'isHardSet': isHardSet,
    };
  }

  // Added 2025-05-30: Factory constructor for an empty/default instance
  factory WorkoutSet.empty() {
    return WorkoutSet(
      id: '', // Consider using a UUID if an empty set still needs a unique ID upon creation
      weight: 0,
      reps: 0,
      timestamp: DateTime.now(),
      isCompleted: false,
      isHardSet: false,
      notes: '',
    );
  }

  @override
  String toString() {
    return 'WorkoutSet(id: $id, weight: $weight, reps: $reps, isHardSet: $isHardSet, isCompleted: $isCompleted, notes: $notes, timestamp: $timestamp)';
  }
}
