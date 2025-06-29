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
  final Uuid uuid = Uuid();
  List<WorkoutExercise> selectedExercises = [];
  DateTime workoutDate = DateTime.now();
  String? notes;
  Workout? _existingWorkout;
  bool _isSaving = false;
  Timer? _debounceTimer;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();


  // Map to store GlobalKeys for superset timers
  final Map<String, GlobalKey<EditableRestTimerState>> _supersetTimerKeys = {};

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _supersetTimerKeys.clear();
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
          // Animate the addition
          _listKey.currentState?.insertItem(selectedExercises.length - 1, duration: const Duration(milliseconds: 300));
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
    if (selectedExercises.isEmpty) {
      // Optionally, allow saving an empty workout or show a specific message.
      // For now, let's consider an empty workout as valid if no exercises were added.
      return true;
    }
    for (final exercise in selectedExercises) {
      if (exercise.sets.isEmpty && selectedExercises.length == 1) {
        // Allow saving if it's the only exercise and has no sets yet (user might be building it)
        // This could be refined based on desired UX.
      } else if (exercise.sets.isEmpty && selectedExercises.length > 1) {
        // If there are multiple exercises, each should ideally have sets.
        // Or, this could be a prompt "Exercise X has no sets, continue?"
        // For now, strict: an exercise implies sets.
        // ScaffoldMessenger.of(context).showSnackBar(_buildValidationSnackBar('Exercise "${exercise.exerciseName}" has no sets.'));
        // return false; // Example of stricter validation
      }
      for (final set in exercise.sets) {
        if (set.weight <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(_buildValidationSnackBar('Weight must be greater than 0 for all sets.'));
          return false;
        }
        if (set.reps <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(_buildValidationSnackBar('Reps must be greater than 0 for all sets.'));
          return false;
        }
        // Consider adding upper bounds or other checks if necessary
      }
    }
    return true;
  }

  SnackBar _buildValidationSnackBar(String message) {
    return SnackBar(
      content: Text(message),
      backgroundColor: Colors.orangeAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
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

  GlobalKey<EditableRestTimerState> _getSupersetTimerKey(String supersetId) {
    _supersetTimerKeys.putIfAbsent(supersetId, () => GlobalKey<EditableRestTimerState>());
    return _supersetTimerKeys[supersetId]!;
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      if (exerciseIndex >= selectedExercises.length) return;
      final exercise = selectedExercises[exerciseIndex];
      exercise.sets.add(
        WorkoutSet(
          id: uuid.v4(),
          weight: 0, // Or copy from previous set
          reps: 0,   // Or copy from previous set
          timestamp: DateTime.now(),
          isHardSet: false,
        ),
      );

      // Check if this set completes a superset round
      if (exercise.supersetId != null) {
        _checkAndTriggerSupersetTimer(exercise.supersetId!, exerciseIndex);
      }
    });
  }

  String _getSupersetTitleWithProgress(List<WorkoutExercise> exercisesInSuperset, String supersetId, int supersetDisplayIndex) {
    if (exercisesInSuperset.isEmpty) return 'Superset';

    int completedRounds = exercisesInSuperset.map((e) => e.sets.length).fold(0, (prev, len) => prev == 0 ? len : (len < prev ? len : prev));
    if (exercisesInSuperset.any((e) => e.sets.isEmpty) && exercisesInSuperset.length > 0) completedRounds = 0;


    int currentRoundSetCount = completedRounds + 1;
    int exercisesDoneThisRound = 0;
    for (var exercise in exercisesInSuperset) {
      if (exercise.sets.length >= currentRoundSetCount) {
        exercisesDoneThisRound++;
      }
    }

    String baseTitle = 'Superset ${supersetDisplayIndex + 1}'; // Use passed display index
    if (exercisesInSuperset.every((ex) => ex.sets.length == completedRounds) && completedRounds > 0 && exercisesDoneThisRound == exercisesInSuperset.length) {
       return '$baseTitle (Round ${completedRounds + 1}: 0/${exercisesInSuperset.length} done)';
    }
     return '$baseTitle (Round $currentRoundSetCount: $exercisesDoneThisRound/${exercisesInSuperset.length} done)';
  }


  void _checkAndTriggerSupersetTimer(String supersetId, int currentExerciseOriginalIndex) {
    final exercisesInSuperset = selectedExercises
        .where((ex) => ex.supersetId == supersetId)
        .toList()
      ..sort((a, b) => (a.supersetOrder ?? 0).compareTo(b.supersetOrder ?? 0));

    if (exercisesInSuperset.isEmpty) return;

    final currentExerciseInSuperset = exercisesInSuperset.firstWhere(
        (ex) => selectedExercises.indexOf(ex) == currentExerciseOriginalIndex, // This comparison might be fragile if list order changes unexpectedly.
                                                                            // A more robust way is to compare exerciseId if they are unique within the workout log.
                                                                            // For now, assuming originalIndex is stable for this call.
        orElse: () => exercisesInSuperset.last // Fallback, though should be found
    );


    final currentExerciseOrder = currentExerciseInSuperset.supersetOrder;
    final isLastExerciseInSuperset = currentExerciseOrder == exercisesInSuperset.length - 1;

    if (isLastExerciseInSuperset) {
      // Check if all exercises in the superset have at least this many sets
      // (or more precisely, if this newly added set makes the counts equal for the current round)
      final currentSetNumber = currentExerciseInSuperset.sets.length;
      bool allExercisesCompletedThisRound = true;
      for (var exInSS in exercisesInSuperset) {
        if (exInSS.sets.length < currentSetNumber) {
          allExercisesCompletedThisRound = false;
          break;
        }
      }

      if (allExercisesCompletedThisRound) {
        debugPrint("Superset round completed for $supersetId. Triggering timer.");
        final timerKey = _getSupersetTimerKey(supersetId);
        // Reset timer to its initial value then start, or just start if it's already at initial.
        // The programmaticStartTimer in EditableRestTimer handles resetting if currentSeconds is 0.
        timerKey.currentState?.programmaticStartTimer();
      }
    }
  }


  void _removeExercise(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= selectedExercises.length) return;

    final WorkoutExercise removedItem = selectedExercises.removeAt(exerciseIndex);
    _listKey.currentState?.removeItem(
      exerciseIndex,
      (context, animation) => _buildRemovedItemWidget(removedItem, animation),
      duration: const Duration(milliseconds: 300),
    );
    // No need to call setState here as AnimatedList handles the UI update based on its internal state
    // and the underlying list (selectedExercises) is already modified.
    // However, if other parts of the UI depend on selectedExercises.length directly (outside AnimatedList),
    // a setState(() {}) might be needed, but it's generally better to avoid if list itself drives the change.
  }

  Widget _buildRemovedItemWidget(WorkoutExercise exercise, Animation<double> animation) {
    // This widget is shown during the removal animation.
    // It should visually represent the item being removed.
    // For simplicity, we create a Card similar to how items might look, but styled for removal.
    return SizeTransition(
      sizeFactor: animation,
      child: Opacity( // Optional: fade out
        opacity: animation.value,
        child: Card(
          margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
          color: Colors.red[800]?.withOpacity(0.8), // Indicate removal
          child: ListTile(
            title: Text(
              exercise.exerciseName,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.white70,
              ),
            ),
            subtitle: Text(
              exercise.muscleGroup.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () => _addExercise(context),
          heroTag: 'workoutLogFAB',
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    // Updated 2025-05-29: Made the empty state tappable to add an exercise
    return GestureDetector(
      onTap: () => _addExercise(context),
      child: Center(
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
            const SizedBox(height: 48), // Increased spacing
            // Updated 2025-05-29: Added explicit buttons for clarity
            ElevatedButton.icon(
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: Colors.white,
              ),
              label: const Text(
                'Add New Exercise',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => _addExercise(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.edit_note_rounded, color: Colors.green),
              label: const Text(
                'Create Custom Exercise',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/add_exercise');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green, width: 1.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesList() {
    // Reverted to ListView.builder for stability with current grouping logic.
    // Group exercises by supersetId
    final groupedExercises = groupBy(selectedExercises, (WorkoutExercise ex) => ex.supersetId);
    final List<Widget> exerciseWidgets = [];
    // final List<String?> processedSupersetIds = []; // This was used for Superset Title, re-adding for clarity

    // Iterate through selectedExercises to maintain original order for non-superset items
    // and first items of supersets.
    // Need to keep track of processed superset IDs to avoid rendering a superset group multiple times.
    List<String> localProcessedSupersetIds = [];


    for (int i = 0; i < selectedExercises.length; i++) {
      final currentExercise = selectedExercises[i];
      final supersetId = currentExercise.supersetId;

      if (supersetId != null) {
        if (!localProcessedSupersetIds.contains(supersetId)) {
          final exercisesInSuperset = groupedExercises[supersetId]!
            ..sort((a, b) => (a.supersetOrder ?? 0).compareTo(b.supersetOrder ?? 0));

          exerciseWidgets.add(
            _buildSupersetGroupWidget(exercisesInSuperset, supersetId, localProcessedSupersetIds.length),
          );
          localProcessedSupersetIds.add(supersetId);
        }
      } else {
        exerciseWidgets.add(
          _buildSingleExerciseItem(currentExercise, i),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Adjusted padding
      children: exerciseWidgets,
    );
  }

  // Helper for standard animation (No longer used here, kept for potential future use)
  // Widget _buildAnimatedItem(BuildContext context, Widget child, Animation<double> animation) {
  //   return SizeTransition(
  //     sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
  //     child: FadeTransition(
  //       opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
  //       child: child,
  //     ),
  //   );
  // }


  Widget _buildSupersetGroupWidget(List<WorkoutExercise> exercisesInSuperset, String supersetId, int supersetDisplayIndex) {
    return Card(
      key: ValueKey('superset_$supersetId'),
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green[700]!, width: 1), // Border to indicate group
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _getSupersetTitleWithProgress(exercisesInSuperset, supersetId, supersetDisplayIndex), // Use supersetDisplayIndex
                      style: TextStyle(color: Colors.green[300], fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.menu, color: Colors.green[300]),
                    onPressed: () => _showSupersetOptions(supersetId, exercisesInSuperset),
                  )
                ],
              ),
            ),
            ...exercisesInSuperset.map((exercise) {
              int originalIndex = selectedExercises.indexWhere((e) => e.exerciseId == exercise.exerciseId && e.supersetId == exercise.supersetId && e.supersetOrder == exercise.supersetOrder);
              return _buildExerciseItemContent(exercise, originalIndex, isPartOfSuperset: true);
            }).toList(),
            Padding( // Add exercise to superset button
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: TextButton.icon(
                icon: Icon(Icons.add_circle_outline, color: Colors.green[300], size: 20),
                label: Text('Add Exercise to Superset', style: TextStyle(color: Colors.green[300], fontSize: 14)),
                onPressed: () => _addExerciseToSupersetDialog(supersetId),
              ),
            ),
            // Timer for the entire superset group
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: EditableRestTimer(
                key: _getSupersetTimerKey(supersetId), // Use GlobalKey
                initialSeconds: 90, // Default superset rest, can be configurable
                onTimeChanged: (newTime) {
                  // Optionally save this preferred superset rest time to UserSettings or similar
                  debugPrint('Superset $supersetId rest time changed to $newTime');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleExerciseItem(WorkoutExercise exercise, int exerciseIndex) {
    // Use a more robust key if exercises can be reordered or have identical IDs temporarily
    return Container(
      key: ValueKey('single_${exercise.exerciseId}_${exerciseIndex}'),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!, width: 0.5),
      ),
      child: _buildExerciseItemContent(exercise, exerciseIndex),
    );
  }

  // Extracted content of a single exercise item, can be used for both single and superset exercises
  Widget _buildExerciseItemContent(WorkoutExercise exercise, int exerciseIndex, {bool isPartOfSuperset = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exercise Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced padding
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
                onPressed: () => _showExerciseOptions(exerciseIndex), // exerciseIndex here is the global index
              ),
            ],
          ),
        ),

        // Conditionally show Rest Timer for single exercises only
        if (!isPartOfSuperset)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: EditableRestTimer(
              key: ValueKey('timer_${exercise.exerciseId}_$exerciseIndex'), // Ensure unique key if list rebuilds
              initialSeconds: exercise.restTimeInSeconds ?? 60,
              onTimeChanged: (seconds) {
                debugPrint('Rest time for ${exercise.exerciseName} changed to: $seconds seconds');
                 setState(() {
                  selectedExercises[exerciseIndex].restTimeInSeconds = seconds;
                });
              },
            ),
          ),

        // Sets
        if (exercise.sets.isNotEmpty) ...[
          const SizedBox(height: 10), // Reduced spacing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16), // Reduced padding
            child: Row(
              children: [
                const SizedBox(width: 52), // Adjusted for new padding and set number width
                Expanded(
                  child: Text(
                    'WEIGHT (KG)',
                    style: TextStyle( // Slightly smaller font
                      fontSize: 11,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'REPS',
                    style: TextStyle( // Slightly smaller font
                      fontSize: 11,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // For delete icon alignment
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exercise.sets.length,
            itemBuilder: (context, setIndex) {
              final set = exercise.sets[setIndex];
              // Pass exerciseIndex (global index) to _buildSetRow
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
              onPressed: () => _addSet(exerciseIndex), // exerciseIndex is global index
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildSetRow(int exerciseIndex, int setIndex, WorkoutSet set) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Reduced padding
      child: Row(
        children: [
          // Set Number
          Container(
            width: 36, // Reduced size
            height: 36, // Reduced size
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
          const SizedBox(width: 12), // Reduced spacing

          // Weight Input
          Expanded(
            child: Container(
              height: 40, // Reduced height
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true), // Allow decimal for weight
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '0.0',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter weight';
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0) return 'Invalid >0';
                  return null;
                },
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
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter reps';
                  final reps = int.tryParse(value);
                  if (reps == null || reps <= 0) return 'Invalid >0';
                  return null;
                },
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
    final exercise = selectedExercises[exerciseIndex];
    final bool isPartOfSuperset = exercise.supersetId != null;
    // Can start a superset if this exercise is not in one, AND there's at least one other non-superset exercise.
    final bool canStartSuperset = !isPartOfSuperset && selectedExercises.any((ex) => ex.supersetId == null && ex.exerciseId != exercise.exerciseId);


    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container( // Handle for dragging
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (!isPartOfSuperset && canStartSuperset)
              ListTile(
                leading: Icon(Icons.link, color: Colors.green[300]),
                title: Text('Create Superset with...', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _promptToCreateSuperset(exerciseIndex);
                },
              ),
            if (!isPartOfSuperset && !canStartSuperset && selectedExercises.length >= 1) // Allow making a single exercise a superset
               ListTile(
                leading: Icon(Icons.link, color: Colors.green[300]),
                title: Text('Make this a Superset', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    final newSupersetId = uuid.v4();
                    selectedExercises[exerciseIndex].supersetId = newSupersetId;
                    selectedExercises[exerciseIndex].supersetOrder = 0;
                    selectedExercises = List.from(selectedExercises);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${exercise.exerciseName} is now a new superset. Add more exercises to it via its menu.')),
                  );
                },
              ),
            if (isPartOfSuperset)
              ListTile(
                leading: Icon(Icons.link_off, color: Colors.orange[300]),
                title: Text('Remove from Superset', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _removeFromSuperset(exerciseIndex);
                },
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

  void _promptToCreateSuperset(int exerciseIndex) async {
    final currentExercise = selectedExercises[exerciseIndex];
    // Filter for other exercises not already in a superset and not the current one
    final availableExercises = selectedExercises
        .where((ex) => ex.supersetId == null && ex.exerciseId != currentExercise.exerciseId)
        .toList();

    // This case should be covered by the logic in _showExerciseOptions enabling "Make this a Superset"
    // if (availableExercises.isEmpty) {
    //    setState(() {
    //     final newSupersetId = uuid.v4();
    //     selectedExercises[exerciseIndex].supersetId = newSupersetId;
    //     selectedExercises[exerciseIndex].supersetOrder = 0;
    //   });
    //   ScaffoldMessenger.of(context).showSnackBar(
    //      SnackBar(content: Text('${currentExercise.exerciseName} is now a superset. Add more exercises to it.')),
    //   );
    //   return;
    // }

    final WorkoutExercise? selectedPartner = await showDialog<WorkoutExercise>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Select exercise to superset with ${currentExercise.exerciseName}', style: TextStyle(color: Colors.white)),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableExercises.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(availableExercises[index].exerciseName, style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.of(context).pop(availableExercises[index]);
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.green[300])),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (selectedPartner != null) {
      setState(() {
        final newSupersetId = uuid.v4();
        selectedExercises[exerciseIndex].supersetId = newSupersetId;
        selectedExercises[exerciseIndex].supersetOrder = 0;

        final partnerIndex = selectedExercises.indexWhere((ex) => ex.exerciseId == selectedPartner.exerciseId && ex.supersetId == null);
        if (partnerIndex != -1) {
          selectedExercises[partnerIndex].supersetId = newSupersetId;
          selectedExercises[partnerIndex].supersetOrder = 1;
        }
        // Force a refresh of the list UI
        selectedExercises = List.from(selectedExercises);
      });
    }
  }

  void _addExerciseToSupersetDialog(String supersetId) async {
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    final Exercise? chosenExercise = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ExerciseSelector(exercises: exerciseProvider.exercises, title: "Add to Superset"),
      ),
    );

    if (chosenExercise != null && mounted) {
      setState(() {
        final exercisesInThisSuperset = selectedExercises.where((ex) => ex.supersetId == supersetId).toList();
        selectedExercises.add(
          WorkoutExercise(
            exerciseId: chosenExercise.id,
            exerciseName: chosenExercise.name,
            muscleGroup: chosenExercise.muscleGroup,
            sets: [],
            supersetId: supersetId,
            supersetOrder: exercisesInThisSuperset.length, // Append to the end
          ),
        );
         selectedExercises = List.from(selectedExercises); // Refresh list
      });
    }
  }

  void _removeFromSuperset(int exerciseIndex) {
    setState(() {
      final exercise = selectedExercises[exerciseIndex];
      final oldSupersetId = exercise.supersetId;
      exercise.supersetId = null;
      exercise.supersetOrder = null;

      // Re-order other exercises in the same old superset if any
      if (oldSupersetId != null) {
        final remainingInSuperset = selectedExercises
            .where((ex) => ex.supersetId == oldSupersetId)
            .toList()
          ..sort((a, b) => (a.supersetOrder ?? 0).compareTo(b.supersetOrder ?? 0));

        for(int i=0; i < remainingInSuperset.length; i++){
          remainingInSuperset[i].supersetOrder = i;
        }
        // If only one exercise remains in the superset, it's no longer a superset
        if(remainingInSuperset.length == 1){
          remainingInSuperset.first.supersetId = null;
          remainingInSuperset.first.supersetOrder = null;
        }
      }
       selectedExercises = List.from(selectedExercises); // Refresh list
    });
  }

  void _showSupersetOptions(String supersetId, List<WorkoutExercise> exercisesInSuperset) {
     showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
         decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
           children: [
             Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2),),),
            ListTile(
              leading: Icon(Icons.add_circle_outline, color: Colors.green[300]),
              title: Text('Add Exercise to this Superset', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _addExerciseToSupersetDialog(supersetId);
              },
            ),
            ListTile(
              leading: Icon(Icons.link_off, color: Colors.orange[300]),
              title: Text('Ungroup Superset', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _ungroupSuperset(supersetId);
              },
            ),
            // Add more options like "Reorder exercises" here
            const SizedBox(height: 20),
          ],
        ),
      )
    );
  }

  void _ungroupSuperset(String supersetId) {
    setState(() {
      for (var ex in selectedExercises) {
        if (ex.supersetId == supersetId) {
          ex.supersetId = null;
          ex.supersetOrder = null;
        }
      }
      selectedExercises = List.from(selectedExercises); // Refresh list
    });
  }


  bool _hasUnsavedChanges() {
    if (_existingWorkout == null) {
      return selectedExercises.isNotEmpty || notes != null;
    }

    return selectedExercises != _existingWorkout!.exercises ||
        notes != _existingWorkout!.notes;
  }
}