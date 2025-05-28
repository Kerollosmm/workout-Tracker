import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';
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
        backgroundColor: Colors.transparent,
        builder:
            (context) => Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ExerciseSelector(exercises: exerciseProvider.exercises),
            ),
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
        SnackBar(
          content: const Text('Please complete all set information'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final workout = Workout(
        id: _existingWorkout?.id ?? uuid.v4(),
        date: workoutDate,
        exercises: List.from(selectedExercises),
        notes: notes,
        workoutName: 'Workout ${DateFormat('MMM d').format(workoutDate)}',
      );

      final workoutProvider = Provider.of<WorkoutProvider>(
        context,
        listen: false,
      );

      if (_existingWorkout != null) {
        await workoutProvider.updateWorkout(workout);
        debugPrint(
          'WorkoutLogScreen: _saveWorkout - workout updated: ${workout.id}',
        );
      } else {
        await workoutProvider.addWorkout(workout);
        debugPrint(
          'WorkoutLogScreen: _saveWorkout - workout added: ${workout.id}',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Workout saved successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        final isInTabView =
            context.findAncestorWidgetOfExactType<IndexedStack>() != null;

        if (isInTabView) {
          // Stay on the same screen in tab view
        } else if (Navigator.canPop(context)) {
          Navigator.pop(context, true);
        } else {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving workout: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
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
              _existingWorkout!.exercises.map((e) => e.copyWith()).toList();
          notes = _existingWorkout!.notes;
        } else {
          _existingWorkout = null;
          selectedExercises = [];
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
        if (_hasUnsavedChanges()) {
          final result = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  backgroundColor: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Unsaved Changes',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'Do you want to discard your changes?',
                    style: TextStyle(color: Colors.grey),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Discard',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
          );
          return result ?? false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Today\'s Workout',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (selectedExercises.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${selectedExercises.length} exercises',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date Selection Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[800]!,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              color: Colors.green,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Workout Date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat(
                                    'EEEE, MMM d, y',
                                  ).format(workoutDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),
                            onPressed: () async {
                              final selectedDate = await showDatePicker(
                                context: context,
                                initialDate: workoutDate,
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 30),
                                ),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Colors.green,
                                        onPrimary: Colors.white,
                                        surface: Color(0xFF1C1C1E),
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
                  ],
                ),
              ),

              // Content Section
              Expanded(
                child:
                    selectedExercises.isEmpty
                        ? _buildEmptyState()
                        : _buildExercisesList(),
              ),

              // Bottom Action Bar
              if (selectedExercises.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    border: Border(
                      top: BorderSide(color: Colors.grey[800]!, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.green, Color(0xFF32D74B)],
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(25),
                              onTap: _isSaving ? null : _saveWorkout,
                              child: Center(
                                child:
                                    _isSaving
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                        : const Text(
                                          'Save Workout',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () => _addExercise(context),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton:
            selectedExercises.isEmpty
                ? FloatingActionButton(
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => _addExercise(context),
                  heroTag: 'workoutLogFAB',
                )
                : null,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.fitness_center,
              size: 40,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Start Your Workout',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add exercises to begin tracking your workout',
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: selectedExercises.length,
      itemBuilder: (context, exerciseIndex) {
        final exercise = selectedExercises[exerciseIndex];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[800]!, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.exerciseName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            exercise.muscleGroup.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onPressed: () => _showExerciseOptions(exerciseIndex),
                    ),
                  ],
                ),
              ),

              // Rest Timer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: EditableRestTimer(
                  initialSeconds: 60,
                  onTimeChanged: (seconds) {
                    debugPrint('Rest time changed to: $seconds seconds');
                  },
                ),
              ),

              // Sets
              if (exercise.sets.isNotEmpty) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const SizedBox(width: 60),
                      const Expanded(
                        child: Text(
                          'WEIGHT (KG)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'REPS',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: exercise.sets.length,
                  itemBuilder: (context, setIndex) {
                    final set = exercise.sets[setIndex];
                    return _buildSetRow(exerciseIndex, setIndex, set);
                  },
                ),
              ],

              // Add Set Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add, color: Colors.green),
                    label: const Text(
                      'Add Set',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    onPressed: () => _addSet(exerciseIndex),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSetRow(int exerciseIndex, int setIndex, WorkoutSet set) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // Set Number
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  set.isHardSet
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.grey[800],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '${setIndex + 1}',
                style: TextStyle(
                  color: set.isHardSet ? Colors.orange : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Weight Input
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                initialValue: set.weight > 0 ? set.weight.toString() : '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                onChanged: (value) {
                  _updateSet(
                    exerciseIndex,
                    setIndex,
                    weight: double.tryParse(value) ?? 0,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Reps Input
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                initialValue: set.reps > 0 ? set.reps.toString() : '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                onChanged: (value) {
                  _updateSet(
                    exerciseIndex,
                    setIndex,
                    reps: int.tryParse(value) ?? 0,
                  );
                },
              ),
            ),
          ),

          // Hard Set Toggle
          IconButton(
            icon: Icon(
              set.isHardSet ? Icons.whatshot : Icons.whatshot_outlined,
              color: set.isHardSet ? Colors.orange : Colors.grey,
              size: 20,
            ),
            onPressed: () {
              _updateSet(exerciseIndex, setIndex, isHardSet: !set.isHardSet);
            },
          ),
        ],
      ),
    );
  }

  void _showExerciseOptions(int exerciseIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Remove Exercise',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeExercise(exerciseIndex);
                  },
                ),
                const SizedBox(height: 20),
              ],
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
