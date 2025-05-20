import 'package:hive/hive.dart';

@HiveType(typeId: 4)
class WorkoutSet extends HiveObject {
  @HiveField(0)
  final double? weight;

  @HiveField(1)
  final int? reps;

  @HiveField(2)
  final bool? isHardSet;

  WorkoutSet({this.weight, this.reps, this.isHardSet});

  WorkoutSet copyWith({double? weight, int? reps, bool? isHardSet}) {
    return WorkoutSet(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      isHardSet: isHardSet ?? this.isHardSet,
    );
  }
}
