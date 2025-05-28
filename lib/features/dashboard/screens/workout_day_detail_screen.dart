import 'package:flutter/material.dart';
import 'package:workout_tracker/core/models/workout.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WorkoutDayDetailScreen extends StatefulWidget {
  final DateTime selectedDate;
  final String? dayName;

  const WorkoutDayDetailScreen({
    Key? key,
    required this.selectedDate,
    this.dayName,
  }) : super(key: key);

  @override
  _WorkoutDayDetailScreenState createState() => _WorkoutDayDetailScreenState();
}

class _WorkoutDayDetailScreenState extends State<WorkoutDayDetailScreen> {
  late TextEditingController _dayNameController;
  bool _isEditingDayName = false;

  @override
  void initState() {
    super.initState();
    _dayNameController = TextEditingController(text: widget.dayName ?? '');
  }

  Future<void> _updateWorkoutName(String newName) async {
    final box = Hive.box<Workout>('workouts');
    final workouts = box.values.where((workout) =>
      workout.date.year == widget.selectedDate.year &&
      workout.date.month == widget.selectedDate.month &&
      workout.date.day == widget.selectedDate.day
    ).toList();

    for (var workout in workouts) {
      final updatedWorkout = workout.copyWith(workoutName: newName);
      await box.put(updatedWorkout.id, updatedWorkout);
    }

    setState(() {
      _dayNameController.text = newName;
    });
  }

  @override
  void dispose() {
    _dayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMM d, y').format(widget.selectedDate);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _isEditingDayName
            ? TextField(
                controller: _dayNameController,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter day name',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                autofocus: true,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _updateWorkoutName(value.trim());
                  }
                  setState(() {
                    _isEditingDayName = false;
                  });
                },
              )
            : Text(
                _dayNameController.text.isNotEmpty
                    ? _dayNameController.text
                    : formattedDate,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          if (!_isEditingDayName)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isEditingDayName = true;
                });
              },
            ),
        ],
      ),
      body: ValueListenableBuilder<Box<Workout>>(
        valueListenable: Hive.box<Workout>('workouts').listenable(),
        builder: (context, box, _) {
          final workouts = box.values
              .where((workout) =>
                  workout.date.year == widget.selectedDate.year &&
                  workout.date.month == widget.selectedDate.month &&
                  workout.date.day == widget.selectedDate.day)
              .toList();

          if (workouts.isEmpty) {
            return Center(
              child: Text(
                'No workouts for this day',
                style: TextStyle(color: Colors.grey[400]),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return _buildWorkoutCard(workout);
            },
          );
        },
      ),
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
    return Card(
      color: const Color(0xFF1C1C1E),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  workout.workoutName ?? 'Workout',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${workout.duration} min',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...workout.exercises.map((exercise) => _buildExerciseTile(exercise)),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseTile(WorkoutExercise exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            exercise.exerciseName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...exercise.sets.asMap().entries.map((entry) {
          final set = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    '${entry.key + 1}',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${set.weight} kg × ${set.reps}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                if (set.notes?.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      set.notes!,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 12),
      ],
    );
  }
}
