import 'package:hive/hive.dart';

part 'focus_session.g.dart';

@HiveType(typeId: 5)
class FocusSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String workoutId;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  DateTime? endTime;

  @HiveField(4)
  int totalFocusTime;

  @HiveField(5)
  int interruptions;

  FocusSession({
    required this.id,
    required this.workoutId,
    required this.startTime,
    this.endTime,
    this.totalFocusTime = 0,
    this.interruptions = 0,
  });

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'],
      workoutId: json['workout_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      totalFocusTime: json['total_focus_time'] ?? 0,
      interruptions: json['interruptions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workout_id': workoutId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'total_focus_time': totalFocusTime,
      'interruptions': interruptions,
    };
  }
} 