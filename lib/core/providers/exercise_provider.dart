import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/exercise.dart';

class ExerciseProvider with ChangeNotifier {
  Box<Exercise>? _exercisesBox;
  final uuid = Uuid();
  bool _isInitialized = false;

  // Constructor to ensure built-in exercises exist
  ExerciseProvider() {
    _tryInitialize();
  }

  // Try to initialize without throwing errors
  Future<void> _tryInitialize() async {
    try {
      await initialize();
    } catch (e) {
      debugPrint(
        'Deferred ExerciseProvider initialization will be attempted later: $e',
      );
    }
  }

  // Initialize method to ensure box is open
  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        // Updated 2025-05-28: Check if box is already open, if not, open it
        if (!Hive.isBoxOpen('exercises')) {
          debugPrint('ExerciseProvider: Opening exercises box');
          _exercisesBox = await Hive.openBox<Exercise>('exercises');
        } else {
          debugPrint('ExerciseProvider: Getting already open exercises box');
          _exercisesBox = Hive.box<Exercise>('exercises');
        }

        if (_exercisesBox == null) {
          throw Exception('Failed to get exercises box after initialization');
        }

        _isInitialized = true;
        debugPrint(
          'ExerciseProvider: Successfully initialized with ${_exercisesBox!.length} exercises',
        );

        // Ensure default exercises exist
        await _ensureDefaultExercises();
      } catch (e) {
        debugPrint('Error initializing ExerciseProvider: $e');
        rethrow;
      }
    }
  }

  // Get box safely with error handling
  Future<Box<Exercise>?> _getBox() async {
    if (_exercisesBox == null || !_isInitialized) {
      try {
        debugPrint(
          'ExerciseProvider: Box not initialized, attempting initialization',
        );
        await initialize();
        // After initialize, check again if box is available
        if (_exercisesBox == null) {
          debugPrint('ExerciseProvider: Box still null after initialization');
          return null;
        }
      } catch (e) {
        debugPrint('Could not get exercises box: $e');
        return null;
      }
    }
    return _exercisesBox;
  }

  Future<void> _ensureDefaultExercises() async {
    // Check if default exercises need to be added
    final box = await _getBox();
    if (box == null) {
      debugPrint(
        'ExerciseProvider: Cannot ensure default exercises, box is null',
      );
      return;
    }

    if (box.isEmpty) {
      await _addDefaultExercises();
    }
  }

  Future<void> _addDefaultExercises() async {
    final box = await _getBox();
    if (box == null) {
      debugPrint('ExerciseProvider: Cannot add default exercises, box is null');
      return;
    }

    final defaultExercises = [
      Exercise(
        id: uuid.v4(),
        name: 'Bench Press',
        muscleGroup: 'Chest',
        isCustom: false,
        iconPath: 'assets/icons/bench_press.png',
      ),
      Exercise(
        id: uuid.v4(),
        name: 'Squat',
        muscleGroup: 'Legs',
        isCustom: false,
        iconPath: 'assets/icons/squat.png',
      ),
      Exercise(
        id: uuid.v4(),
        name: 'Deadlift',
        muscleGroup: 'Back',
        isCustom: false,
        iconPath: 'assets/icons/deadlift.png',
      ),
      // Add more default exercises here
    ];

    try {
      for (final exercise in defaultExercises) {
        await box.add(exercise);
      }
      debugPrint(
        'ExerciseProvider: Added ${defaultExercises.length} default exercises',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('ExerciseProvider: Error adding default exercises: $e');
      rethrow;
    }
  }

  // Reset and reinitialize exercises
  Future<void> resetExercises() async {
    await _exercisesBox?.clear();
    await _addDefaultExercises();
  }

  List<Exercise> get exercises {
    if (_exercisesBox == null) {
      debugPrint(
        'ExerciseProvider: Warning - exercises requested but box is null',
      );
      return [];
    }
    return _exercisesBox!.values.toList();
  }

  List<Exercise> getExercisesByMuscleGroup(String muscleGroup) {
    return exercises.where((e) => e.muscleGroup == muscleGroup).toList();
  }

  List<Exercise> get favoriteExercises =>
      exercises.where((e) => e.isFavorite).toList();

  Exercise? getExerciseById(String id) {
    try {
      return _exercisesBox?.values.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addExercise(Exercise exercise) async {
    final box = await _getBox();
    if (box == null) {
      debugPrint(
        'ExerciseProvider: Exercises box is null, cannot add exercise.',
      );
      throw Exception('ExerciseProvider: Exercises box is unavailable.');
    }

    try {
      await box.add(exercise);
      notifyListeners();
      debugPrint(
        'ExerciseProvider: Exercise added successfully with id: ${exercise.id}',
      );
    } catch (e) {
      debugPrint('ExerciseProvider: Error adding exercise: $e');
      rethrow;
    }
  }

  Future<void> updateExercise(Exercise exercise) async {
    final box = await _getBox();
    if (box == null) {
      debugPrint(
        'ExerciseProvider: Exercises box is null, cannot update exercise.',
      );
      throw Exception('ExerciseProvider: Exercises box is unavailable.');
    }

    try {
      final index = box.values.toList().indexWhere((e) => e.id == exercise.id);
      if (index != -1) {
        await box.putAt(index, exercise);
        notifyListeners();
        debugPrint(
          'ExerciseProvider: Exercise updated successfully with id: ${exercise.id}',
        );
      } else {
        debugPrint(
          'ExerciseProvider: Exercise with id ${exercise.id} not found for update.',
        );
        // Optionally, throw an exception if an exercise not found should be an error
        // throw Exception('Exercise with id ${exercise.id} not found for update.');
      }
    } catch (e) {
      debugPrint('ExerciseProvider: Error updating exercise: $e');
      rethrow;
    }
  }

  Future<void> toggleFavorite(String id) async {
    final exercise = getExerciseById(id);
    if (exercise != null) {
      exercise.isFavorite = !exercise.isFavorite;
      await updateExercise(exercise);
    }
  }

  Future<void> deleteExercise(String id) async {
    final box = await _getBox();
    if (box == null) {
      debugPrint(
        'ExerciseProvider: Exercises box is null, cannot delete exercise.',
      );
      throw Exception('ExerciseProvider: Exercises box is unavailable.');
    }

    try {
      final index = box.values.toList().indexWhere((e) => e.id == id);
      if (index != -1) {
        final exercise = box.getAt(index);
        if (exercise != null && exercise.isCustom) {
          await box.deleteAt(index);
          notifyListeners();
          debugPrint(
            'ExerciseProvider: Custom exercise deleted successfully with id: $id',
          );
        } else if (exercise != null && !exercise.isCustom) {
          debugPrint(
            'ExerciseProvider: Cannot delete default exercise with id: $id',
          );
          // Optionally throw an error or return a status
        } else {
          debugPrint(
            'ExerciseProvider: Exercise with id $id not found at index $index for deletion.',
          );
        }
      } else {
        debugPrint(
          'ExerciseProvider: Exercise with id $id not found for deletion.',
        );
      }
    } catch (e) {
      debugPrint('ExerciseProvider: Error deleting exercise: $e');
      rethrow;
    }
  }

  List<String> get allMuscleGroups {
    return [
      'Chest',
      'Back',
      'Shoulders',
      'Arms',
      'Legs',
      'Core',
      'Cardio',
      'Full Body',
    ];
  }

  // Updated 2025-05-28: Implement deleteCustomExercise to call deleteExercise
  Future<void> deleteCustomExercise(String exerciseId) async {
    await deleteExercise(exerciseId);
  }
}
