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
        appBar: AppBar(
          title: Text('Log Workout'),
          actions: [
            IconButton(icon: Icon(Icons.save), onPressed: _saveWorkout),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.calendar_today),
                  SizedBox(width: 8),
                  Text(
                    'Date: ${DateFormat('MMM dd, yyyy').format(workoutDate)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Spacer(),
                  TextButton(
                    child: Text('Change'),
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: workoutDate,
                        firstDate: DateTime.now().subtract(Duration(days: 30)),
                        lastDate: DateTime.now(),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          workoutDate = selectedDate;
                        });
                        await _loadExistingWorkout();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select a valid date')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            Divider(),

            Expanded(
              child:
                  selectedExercises.isEmpty
                      ? Center(
                        child: Text(
                          'Tap "Add Exercise" to begin',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                      : ListView.builder(
                        itemCount: selectedExercises.length,
                        itemBuilder: (context, exerciseIndex) {
                          final exercise = selectedExercises[exerciseIndex];
                          return Card(
                            margin: EdgeInsets.all(8.0),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.fitness_center),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          exercise.exerciseName,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        exercise.muscleGroup,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed:
                                            () =>
                                                _removeExercise(exerciseIndex),
                                      ),
                                    ],
                                  ),

                                  Divider(),

                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(width: 40),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Weight',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Reps',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Hard Set',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 48),
                                      ],
                                    ),
                                  ),

                                  ...List.generate(
                                    exercise.sets.length,
                                    (setIndex) => SetInputCard(
                                      setNumber: setIndex + 1,
                                      weight: exercise.sets[setIndex].weight,
                                      reps: exercise.sets[setIndex].reps,
                                      isHardSet:
                                          exercise.sets[setIndex].isHardSet,
                                      onWeightChanged: (value) {
                                        _updateSet(
                                          exerciseIndex,
                                          setIndex,
                                          weight: value,
                                        );
                                      },
                                      onRepsChanged: (value) {
                                        _updateSet(
                                          exerciseIndex,
                                          setIndex,
                                          reps: value,
                                        );
                                      },
                                      onHardSetChanged: (value) {
                                        _updateSet(
                                          exerciseIndex,
                                          setIndex,
                                          isHardSet: value,
                                        );
                                      },
                                      onDelete:
                                          () => _removeSet(
                                            exerciseIndex,
                                            setIndex,
                                          ),
                                    ),
                                  ),

                                  Center(
                                    child: TextButton.icon(
                                      icon: Icon(Icons.add),
                                      label: Text('Add Set'),
                                      onPressed: () => _addSet(exerciseIndex),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
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
