import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/widgets/custom_snackbar.dart'; // Added 2025-05-29, path corrected
import '../../../config/themes/app_theme.dart'; // Added 2025-05-29
import '../../../core/models/workout.dart';
import '../../../core/models/workout_set.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../core/providers/exercise_provider.dart';
import '../../../core/models/exercise.dart';
// Updated 2025-05-29: Ensure ExerciseSelector and SetInputCard are themed or use AppTheme if modified.
import 'package:workout_tracker/features/workout_log/widgets/exercise_selector.dart';
import 'package:workout_tracker/features/workout_log/widgets/set_input_card.dart';

class WorkoutEditorScreen extends StatefulWidget {
  final Workout? workout;

  const WorkoutEditorScreen({Key? key, this.workout}) : super(key: key);

  @override
  State<WorkoutEditorScreen> createState() => _WorkoutEditorScreenState();
}

class _WorkoutEditorScreenState extends State<WorkoutEditorScreen> {
  late Workout _workout;
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _workoutNameController =
      TextEditingController(); // Added for workout name
  final _uuid = Uuid();
  bool _isEditing = false;
  bool _isSaving = false; // Added 2025-05-29: For save button state

  @override
  void initState() {
    super.initState();
    _isEditing = widget.workout != null;

    if (_isEditing) {
      _workout = Workout(
        id: widget.workout!.id,
        date: widget.workout!.date,
        exercises: List.from(widget.workout!.exercises),
        duration: widget.workout!.duration,
        notes: widget.workout!.notes,
        workoutName: widget.workout!.workoutName, // Added workoutName
      );
      _notesController.text = _workout.notes ?? '';
      _workoutNameController.text = _workout.workoutName ?? 'New Workout';
    } else {
      _workout = Workout(
        id: _uuid.v4(), // Use UUID instead of UniqueKey
        date: DateTime.now(),
        exercises: [],
        duration: 0,
        notes: '',
        workoutName: 'New Workout', // Default workoutName
      );
      _workoutNameController.text = 'New Workout';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _workoutNameController.dispose();
    super.dispose();
  }

  void _addExercise() async {
    final exerciseProvider = Provider.of<ExerciseProvider>(
      context,
      listen: false,
    );
    final exercises = exerciseProvider.exercises;

    final exercise = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseSelector(exercises: exercises),
    );

    if (exercise != null) {
      final workoutExercise = WorkoutExercise(
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        muscleGroup: exercise.muscleGroup,
        sets: [
          WorkoutSet(
            id: _uuid.v4(),
            weight: 0,
            reps: 0,
            timestamp: DateTime.now(),
            isHardSet: false,
          ),
        ],
      );
      setState(() {
        _workout.exercises.add(workoutExercise);
      });
    }
  }

  void _removeExercise(int index) {
    setState(() {
      _workout.exercises.removeAt(index);
    });
  }

  void _reorderExercises(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final exercise = _workout.exercises.removeAt(oldIndex);
      _workout.exercises.insert(newIndex, exercise);
    });
  }

  void _editExerciseSets(int exerciseIndex) async {
    final exercise = _workout.exercises[exerciseIndex];

    // Updated 2025-05-29: Style dialog and buttons with AppTheme
    await showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            // Changed context to dialogContext
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius_l),
            ),
            title: Text(
              'Edit ${exercise.exerciseName} Sets',
              style: const TextStyle(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: StatefulBuilder(
              builder: (context, setDialogState) {
                // Inner context for StatefulBuilder
                return SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: exercise.sets.length,
                          itemBuilder: (context, setIndex) {
                            final set = exercise.sets[setIndex];
                            // TODO: Ensure SetInputCard is styled with AppTheme or accepts theme parameters
                            return SetInputCard(
                              setNumber: setIndex + 1,
                              weight: set.weight,
                              reps: set.reps,
                              isHardSet: set.isHardSet,
                              onWeightChanged: (value) {
                                setDialogState(() {
                                  set.weight = value;
                                });
                              },
                              onRepsChanged: (value) {
                                setDialogState(() {
                                  set.reps = value;
                                });
                              },
                              onHardSetChanged: (value) {
                                setDialogState(() {
                                  set.isHardSet = value;
                                });
                              },
                              onDelete: () {
                                setDialogState(() {
                                  exercise.sets.removeAt(setIndex);
                                });
                                // No need to call setState(() {}) on the main screen state here,
                                // as the dialog's state is managed by setDialogState.
                                // The main screen will rebuild when the dialog is popped if necessary.
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing_m),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentTextColor,
                              foregroundColor:
                                  AppTheme.primaryColor, // Text color on accent
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadius_m,
                                ),
                              ),
                            ),
                            onPressed: () {
                              setDialogState(() {
                                exercise.sets.add(
                                  WorkoutSet(
                                    id: _uuid.v4(),
                                    weight: 0,
                                    reps: 0,
                                    timestamp: DateTime.now(),
                                    isHardSet: false,
                                  ),
                                );
                              });
                            },
                            child: const Text('Add Set'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(
                    () {},
                  ); // This setState is for the main screen to update if sets changed
                  Navigator.of(dialogContext).pop();
                },
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: AppTheme.accentTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _saveWorkout() async {
    if (_formKey.currentState!.validate()) {
      // Updated 2025-05-29: Add _isSaving state and use CustomSnackbar
      setState(() {
        _isSaving = true;
      });

      final updatedWorkout = _workout.copyWith(
        notes: _notesController.text,
        workoutName: _workoutNameController.text,
      );
      _workout = updatedWorkout; // Update the local workout instance

      final workoutProvider = Provider.of<WorkoutProvider>(
        context,
        listen: false,
      );

      try {
        if (_isEditing) {
          await workoutProvider.updateWorkout(_workout);
        } else {
          await workoutProvider.addWorkout(_workout);
        }

        if (!mounted) return; // Check mounted status after async operation
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackbar.success(
            message:
                _isEditing
                    ? 'Workout updated successfully!'
                    : 'Workout saved successfully!',
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(CustomSnackbar.error(message: e.toString()));
      } finally {
        if (mounted) {
          // Ensure widget is still mounted before calling setState
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  void _confirmDeleteWorkout(BuildContext dialogContext) {
    // Renamed context to avoid conflict
    // Updated 2025-05-29: Style dialog with AppTheme
    showDialog(
      context: dialogContext, // Use the passed context for showDialog
      builder:
          (BuildContext alertContext) => AlertDialog(
            // Inner context for AlertDialog
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius_l),
            ),
            title: const Text(
              'Delete Workout',
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Are you sure you want to delete this workout? This action cannot be undone.',
              style: TextStyle(color: AppTheme.secondaryTextColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(alertContext).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  // Use the dialogContext for Provider, as it's part of the widget tree that has the Provider
                  final workoutProvider = Provider.of<WorkoutProvider>(
                    dialogContext,
                    listen: false,
                  );
                  await workoutProvider.deleteWorkout(_workout.id);

                  if (!mounted) return; // Check mounted after async operation

                  Navigator.of(
                    alertContext,
                  ).pop(); // Close dialog using alertContext

                  // Pop the WorkoutEditorScreen itself using dialogContext (which is the original screen's context)
                  // This ensures we are popping the correct navigator.
                  if (Navigator.canPop(dialogContext)) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Updated 2025-05-29: Apply AppTheme styling
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.primaryTextColor,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Workout' : 'Create Workout',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          ),
        ),
        leading: IconButton(
          // Added consistent back button
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.primaryTextColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppTheme.errorColor,
                size: 26,
              ),
              onPressed:
                  () => _confirmDeleteWorkout(
                    context,
                  ), // Pass the Scaffold's context
              tooltip: 'Delete Workout',
            ),
          const SizedBox(
            width: AppTheme.spacing_s,
          ), // Maintain some spacing if other actions were present
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing_m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Workout Name TextFormField
                  TextFormField(
                    controller: _workoutNameController,
                    style: const TextStyle(color: AppTheme.primaryTextColor),
                    decoration: InputDecoration(
                      labelText: 'Workout Name',
                      labelStyle: const TextStyle(
                        color: AppTheme.secondaryTextColor,
                      ),
                      hintText: 'E.g., Morning Push Routine',
                      hintStyle: const TextStyle(
                        color: AppTheme.secondaryTextColor,
                      ),
                      filled: true,
                      fillColor: AppTheme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadius_m,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadius_m,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadius_m,
                        ),
                        borderSide: const BorderSide(
                          color: AppTheme.accentTextColor,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing_m,
                        vertical: AppTheme.spacing_m,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a workout name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing_m),

                  // Notes TextFormField
                  TextFormField(
                    controller: _notesController,
                    style: const TextStyle(color: AppTheme.primaryTextColor),
                    decoration: InputDecoration(
                      labelText: 'Workout Notes (Optional)',
                      labelStyle: const TextStyle(
                        color: AppTheme.secondaryTextColor,
                      ),
                      hintText: 'E.g., Focus on form, specific equipment used',
                      hintStyle: const TextStyle(
                        color: AppTheme.secondaryTextColor,
                      ),
                      filled: true,
                      fillColor: AppTheme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadius_m,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadius_m,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadius_m,
                        ),
                        borderSide: const BorderSide(
                          color: AppTheme.accentTextColor,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing_m,
                        vertical: AppTheme.spacing_m,
                      ),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: AppTheme.spacing_l,
            ), // Space before exercises section
            // Exercises Section Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing_s,
              ), // Adjusted padding from previous step
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exercises',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(
                      Icons.add,
                      size: 20,
                      color: AppTheme.primaryColor,
                    ),
                    label: const Text(
                      'Add',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _addExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentTextColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing_m,
                        vertical: AppTheme.spacing_s,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadius_m,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing_m),

            // Exercises List or Empty State
            Expanded(
              child:
                  _workout.exercises.isEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacing_xl),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons
                                    .fitness_center_outlined, // Or a more specific icon like Icons.list_alt
                                size: 60,
                                color: AppTheme.secondaryTextColor,
                              ),
                              const SizedBox(height: AppTheme.spacing_m),
                              Text(
                                'No exercises added yet.',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.secondaryTextColor,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacing_s),
                              Text(
                                'Tap "Add" to get started!',
                                textAlign: TextAlign.center,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : ReorderableListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: AppTheme.spacing_l,
                        ), // Padding for save button visibility
                        itemCount: _workout.exercises.length,
                        onReorder: _reorderExercises,
                        itemBuilder: (context, index) {
                          final exercise = _workout.exercises[index];
                          // Updated 2025-05-30: Styled ReorderableListView items
                          return Card(
                            key: ValueKey(
                              exercise.exerciseId + index.toString(),
                            ),
                            margin: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacing_xs,
                              horizontal: AppTheme.spacing_xs,
                            ),
                            color: AppTheme.cardColor,
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadius_m,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing_m,
                                vertical: AppTheme.spacing_s,
                              ),
                              leading: Icon(
                                Icons
                                    .fitness_center, // Consider exercise.icon if available
                                color: AppTheme.primaryColor,
                                size: 28,
                              ),
                              title: Text(
                                exercise.exerciseName,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.primaryTextColor,
                                  fontWeight: FontWeight.w600, // Bold title
                                ),
                              ),
                              subtitle: Text(
                                '${exercise.muscleGroup} • ${exercise.sets.length} sets',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.secondaryTextColor,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: AppTheme.accentTextColor,
                                    ),
                                    tooltip: 'Edit Sets',
                                    onPressed: () => _editExerciseSets(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: AppTheme.errorColor,
                                    ),
                                    tooltip: 'Remove Exercise',
                                    onPressed: () => _removeExercise(index),
                                  ),
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: const Padding(
                                      padding: EdgeInsets.all(
                                        AppTheme.spacing_s,
                                      ), // Smaller padding for drag handle icon
                                      child: Icon(
                                        Icons.drag_handle,
                                        color: AppTheme.secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => _editExerciseSets(index),
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: AppTheme.spacing_m),
            // Save Workout Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacing_m,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
                ),
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      AppTheme
                          .primaryTextColor, // Ensure text color is applied through textStyle
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _isSaving ? null : _saveWorkout,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryTextColor,
                        ),
                      ),
                    )
                  : Text(
                      _isEditing ? 'Save Workout' : 'Create Workout',
                      // Style is now in ElevatedButton.styleFrom's textStyle
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
