import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/workout.dart';
import '../../../core/models/workout_set.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../core/providers/exercise_provider.dart';

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
  final _workoutNameController = TextEditingController(); // Added for workout name
  final _uuid = Uuid();
  bool _isEditing = false;

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
      _workoutNameController.text = _workout.workoutName;
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
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    final exercises = exerciseProvider.exercises;

    final selectedExercise = await showDialog<WorkoutExercise>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Exercise'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return ListTile(
                title: Text(exercise.name),
                subtitle: Text(exercise.muscleGroup),
                onTap: () {
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
                      )
                    ],
                  );
                  Navigator.of(context).pop(workoutExercise);
                },
              );
            },
          ),
        ),
      ),
    );

    if (selectedExercise != null) {
      setState(() {
        _workout.exercises.add(selectedExercise);
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
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${exercise.exerciseName} Sets'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
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
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Text('Set ${setIndex + 1}'),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: set.weight.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Weight',
                                    suffixText: 'kg',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setDialogState(() {
                                      set.weight = double.tryParse(value) ?? 0;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: set.reps.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Reps',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setDialogState(() {
                                      set.reps = int.tryParse(value) ?? 0;
                                    });
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setDialogState(() {
                                    exercise.sets.removeAt(setIndex);
                                  });
                                  setState(() {}); // Trigger rebuild of main screen
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setDialogState(() {
                        exercise.sets.add(WorkoutSet(
                          id: _uuid.v4(),
                          weight: 0,
                          reps: 0,
                          timestamp: DateTime.now(),
                          isHardSet: false,
                        ));
                      });
                      setState(() {}); // Trigger rebuild of main screen
                    },
                    child: const Text('Add Set'),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {}); // Ensure UI updates when dialog closes
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveWorkout() async {
    if (_formKey.currentState!.validate()) {
      // Create a new workout with updated values instead of modifying the final properties
      final updatedWorkout = _workout.copyWith(
        notes: _notesController.text,
        workoutName: _workoutNameController.text,
      );
      
      // Update the _workout reference to the new instance
      _workout = updatedWorkout;

      final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);

      try {
        if (_isEditing) {
          await workoutProvider.updateWorkout(_workout);
        } else {
          await workoutProvider.addWorkout(_workout);
        }

        // Store the mounted state in a local variable before the async gap
        final isStillMounted = mounted;
        
        if (isStillMounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout saved successfully')),
          );
          Navigator.of(context).pop(true); // Return true to indicate successful save
        }
      } catch (e) {
        // Store the mounted state in a local variable before the async gap
        final isStillMounted = mounted;
        
        if (isStillMounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving workout: $e')),
          );
        }
      }
    }
  }

  void _confirmDeleteWorkout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: const Text(
          'Are you sure you want to delete this workout? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
              await workoutProvider.deleteWorkout(_workout.id);
              
              // Store the mounted state in a local variable before the async gap
              final isStillMounted = mounted;
              
              if (isStillMounted) {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to previous screen
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Workout' : 'Create Workout'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () => _confirmDeleteWorkout(context),
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveWorkout,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Add workout name field
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _workoutNameController,
                decoration: const InputDecoration(
                  labelText: 'Workout Name',
                  hintText: 'Enter a name for this workout',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a workout name';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Workout Notes',
                  hintText: 'Optional: Add notes about this workout',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text(
                    'Exercises',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Exercise'),
                    onPressed: _addExercise,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _workout.exercises.length,
                onReorder: _reorderExercises,
                itemBuilder: (context, index) {
                  final exercise = _workout.exercises[index];
                  return Card(
                    key: ValueKey(exercise.exerciseId + index.toString()),
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(exercise.exerciseName),
                      subtitle: Text(
                        '${exercise.muscleGroup} • ${exercise.sets.length} sets',
                      ),
                      leading: const Icon(Icons.fitness_center),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editExerciseSets(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeExercise(index),
                          ),
                          ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_handle),
                          ),
                        ],
                      ),
                      onTap: () => _editExerciseSets(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
