import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_tracker/core/models/exercise.dart';
import '../../../core/models/workout.dart';
import '../../../core/models/workout_set.dart';
import '../../../core/providers/exercise_provider.dart';
import '../../../core/providers/workout_provider.dart';
import '../widgets/exercise_selector.dart';
import '../widgets/set_input_card.dart';
import '../widgets/rest_timer.dart';
import '../widgets/editable_rest_timer.dart';

class WorkoutLogScreen extends StatefulWidget {
  @override
  _WorkoutLogScreenState createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  final uuid = Uuid();
  List<WorkoutExercise> selectedExercises = [];
  DateTime workoutDate = DateTime.now();
  String? notes;
  Workout? _existingWorkout;
  bool _isSaving = false;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _debounce(VoidCallback callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), callback);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingWorkout();
    });
  }

  Future<void> _addExercise(BuildContext context) async {
    final exerciseProvider = Provider.of<ExerciseProvider>(
      context,
      listen: false,
    );

    try {
      final result = await showModalBottomSheet<Exercise>(
        context: context,
        isScrollControlled: true,
        builder:
            (context) =>
                ExerciseSelector(exercises: exerciseProvider.exercises),
      );

      if (result != null && mounted) {
        setState(() {
          selectedExercises.add(
            WorkoutExercise(
              exerciseId: result.id,
              exerciseName: result.name,
              muscleGroup: result.muscleGroup,
              sets: [],
            ),
          );
        });
      }
    } catch (e) {
      debugPrint('Error adding exercise: $e');
    }
  }

  Future<void> _saveWorkout() async {
    if (_isSaving) return;

    if (!_validateWorkout()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all set information')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final workout = Workout(
        id: _existingWorkout?.id ?? uuid.v4(),
        date: workoutDate,
        exercises: List.from(selectedExercises), // Create a copy
        notes: notes,
      );

      final workoutProvider = Provider.of<WorkoutProvider>(
        context,
        listen: false,
      );

      if (_existingWorkout != null) {
        await workoutProvider.updateWorkout(workout);
      } else {
        await workoutProvider.addWorkout(workout);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout saved successfully')),
        );
        Navigator.pushReplacementNamed(
          context,
          '/dashboard',
        ); // Changed from pop
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving workout: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  bool _validateWorkout() {
    return !selectedExercises.any(
      (exercise) =>
          exercise.sets.any((set) => set.weight == 0 || set.reps == 0),
    );
  }

  void _updateSet(
    int exerciseIndex,
    int setIndex, {
    double? weight,
    int? reps,
    bool? isHardSet,
  }) {
    _debounce(() {
      if (!mounted) return;

      setState(() {
        if (exerciseIndex >= selectedExercises.length ||
            setIndex >= selectedExercises[exerciseIndex].sets.length) {
          return;
        }

        final currentSet = selectedExercises[exerciseIndex].sets[setIndex];
        selectedExercises[exerciseIndex].sets[setIndex] = WorkoutSet(
          id: currentSet.id,
          weight: weight ?? currentSet.weight,
          reps: reps ?? currentSet.reps,
          timestamp: DateTime.now(),
          isHardSet: isHardSet ?? currentSet.isHardSet,
        );
      });
    });
  }

  Future<void> _loadExistingWorkout() async {
    final workoutProvider = Provider.of<WorkoutProvider>(
      context,
      listen: false,
    );
    final workouts =
        workoutProvider.workouts
            .where(
              (w) =>
                  w.date.year == workoutDate.year &&
                  w.date.month == workoutDate.month &&
                  w.date.day == workoutDate.day,
            )
            .toList();

    if (mounted) {
      setState(() {
        if (workouts.isNotEmpty) {
          _existingWorkout = workouts.first;
          selectedExercises =
              _existingWorkout!.exercises
                  .map(
                    (e) => WorkoutExercise(
                      exerciseId: e.exerciseId,
                      exerciseName: e.exerciseName,
                      muscleGroup: e.muscleGroup,
                      sets:
                          e.sets
                              .map(
                                (s) => WorkoutSet(
                                  id: s.id,
                                  weight: s.weight,
                                  reps: s.reps,
                                  timestamp: s.timestamp,
                                  isHardSet: s.isHardSet,
                                ),
                              )
                              .toList(),
                    ),
                  )
                  .toList();
          notes = _existingWorkout!.notes;
        } else {
          _existingWorkout = null;
          selectedExercises.clear();
          notes = null;
        }
      });
    }
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      if (exerciseIndex >= selectedExercises.length ||
          setIndex >= selectedExercises[exerciseIndex].sets.length) {
        return;
      }
      selectedExercises[exerciseIndex].sets.removeAt(setIndex);
    });
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      if (exerciseIndex >= selectedExercises.length) return;

      selectedExercises[exerciseIndex].sets.add(
        WorkoutSet(
          id: uuid.v4(),
          weight: 0,
          reps: 0,
          timestamp: DateTime.now(),
          isHardSet: false,
        ),
      );
    });
  }

  void _removeExercise(int exerciseIndex) {
    setState(() {
      selectedExercises.removeAt(exerciseIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isSaving) return false;
        // Show confirmation dialog if there are unsaved changes
        if (_hasUnsavedChanges()) {
          final result = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Unsaved Changes'),
                  content: const Text('Do you want to discard your changes?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Discard'),
                    ),
                  ],
                ),
          );
          return result ?? false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1C1C1E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2C2C2E),
          elevation: 0,
          title: const Text(
            'Workout',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save, color: Colors.blue),
              onPressed: _saveWorkout
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              margin: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Date: ${DateFormat('MMM d, y').format(workoutDate)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: workoutDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Colors.blue,
                                onPrimary: Colors.white,
                                surface: Color(0xFF2C2C2E),
                                onSurface: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (selectedDate != null) {
                        setState(() {
                          workoutDate = selectedDate;
                        });
                        await _loadExistingWorkout();
                      }
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: selectedExercises.isEmpty
                      ? Center(
                        child: Text(
                        'Tap + to add an exercise',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[400],
                        ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: selectedExercises.length,
                        itemBuilder: (context, exerciseIndex) {
                          final exercise = selectedExercises[exerciseIndex];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(16),
                          ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                    children: [
                                    const Icon(
                                      Icons.fitness_center,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                      Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                          exercise.exerciseName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                            exercise.muscleGroup.toUpperCase(),
                                        style: TextStyle(
                                              color: Colors.red[400],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.white),
                                      onPressed: () {},
                                      ),
                                    ],
                                  ),
                              ),
                              EditableRestTimer(
                                initialSeconds: 60,
                                onTimeChanged: (seconds) {
                                  debugPrint(
                                      'Rest time changed to: $seconds seconds');
                                },
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: exercise.sets.length,
                                itemBuilder: (context, setIndex) {
                                  final set = exercise.sets[setIndex];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Set ${setIndex + 1}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF3C3C3E),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    initialValue:
                                                        set.weight.toString(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: 'Weight',
                                                      hintStyle: TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                      suffixText: 'kg',
                                                      suffixStyle: TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    onChanged: (value) {
                                                      _updateSet(
                                                        exerciseIndex,
                                                        setIndex,
                                                        weight: double.tryParse(
                                                                value) ??
                                                            0,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF3C3C3E),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: TextFormField(
                                              initialValue:
                                                  set.reps.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                hintText: 'Reps',
                                                hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              onChanged: (value) {
                                        _updateSet(
                                          exerciseIndex,
                                          setIndex,
                                                  reps:
                                                      int.tryParse(value) ?? 0,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.circle,
                                            color: set.isHardSet
                                                ? Colors.red[400]
                                                : Colors.grey[600],
                                            size: 20,
                                          ),
                                          onPressed: () {
                                        _updateSet(
                                          exerciseIndex,
                                          setIndex,
                                              isHardSet: !set.isHardSet,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: TextButton.icon(
                                  icon: const Icon(Icons.add,
                                      color: Colors.blue),
                                  label: const Text(
                                    'Add Set',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                      onPressed: () => _addSet(exerciseIndex),
                                    ),
                                  ),
                                ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () => _addExercise(context),
          tooltip: 'Add Exercise',
        ),
      ),
    );
  }

  bool _hasUnsavedChanges() {
    if (_existingWorkout == null) {
      return selectedExercises.isNotEmpty || notes != null;
    }

    return selectedExercises != _existingWorkout!.exercises ||
        notes != _existingWorkout!.notes;
  }
}
