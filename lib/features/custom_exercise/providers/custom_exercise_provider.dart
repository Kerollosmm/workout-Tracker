// lib/features/custom_exercise/providers/custom_exercise_provider.dart

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/exercise.dart';
import '../../../core/providers/exercise_provider.dart';

class CustomExerciseProvider with ChangeNotifier {
  final ExerciseProvider _exerciseProvider;
  final uuid = Uuid();

  String _exerciseName = '';
  String _selectedMuscleGroup = 'Chest';
  bool _isFavorite = false;
  String? _notes;

  CustomExerciseProvider(this._exerciseProvider);

  // Getters
  String get exerciseName => _exerciseName;
  String get selectedMuscleGroup => _selectedMuscleGroup;
  bool get isFavorite => _isFavorite;
  String? get notes => _notes;
  List<String> get muscleGroups => _exerciseProvider.allMuscleGroups;

  // Setters
  void setExerciseName(String name) {
    _exerciseName = name;
    notifyListeners();
  }

  void setMuscleGroup(String muscleGroup) {
    _selectedMuscleGroup = muscleGroup;
    notifyListeners();
  }

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
  }

  // Added 2025-05-29: To directly set favorite status from UI controls like SwitchListTile
  void setIsFavorite(bool value) {
    _isFavorite = value;
    notifyListeners();
  }

  void setNotes(String? notes) {
    _notes = notes;
    notifyListeners();
  }

  // Reset form data
  void resetForm() {
    _exerciseName = '';
    _selectedMuscleGroup = 'Chest';
    _isFavorite = false;
    _notes = null;
    notifyListeners();
  }

  // Save custom exercise
  Future<void> saveExercise() async {
    if (_exerciseName.trim().isEmpty) {
      debugPrint('CustomExerciseProvider: Exercise name cannot be empty');
      throw Exception('Exercise name cannot be empty');
    }

    try {
      final newExercise = Exercise(
        id: uuid.v4(),
        name: _exerciseName.trim(),
        muscleGroup: _selectedMuscleGroup,
        isCustom: true,
        iconPath: 'assets/icons/custom_exercise.png',
        notes: _notes,
        isFavorite: _isFavorite,
      );

      await _exerciseProvider.addExercise(newExercise);
      debugPrint('CustomExerciseProvider: Exercise saved successfully: ${_exerciseName.trim()}');
      resetForm();
    } catch (e) {
      debugPrint('CustomExerciseProvider: Failed to save exercise: ${e.toString()}');
      rethrow;
    }
  }

  // Load exercise data for editing
  void loadExercise(Exercise exercise) {
    _exerciseName = exercise.name;
    _selectedMuscleGroup = exercise.muscleGroup;
    _isFavorite = exercise.isFavorite;
    _notes = exercise.notes;
    notifyListeners();
  }

  // Update existing exercise
  Future<void> updateExercise(String exerciseId) async {
    if (_exerciseName.trim().isEmpty) {
      debugPrint('CustomExerciseProvider: Exercise name cannot be empty for update');
      throw Exception('Exercise name cannot be empty');
    }

    final exerciseToUpdate = _exerciseProvider.getExerciseById(exerciseId);
    if (exerciseToUpdate == null) {
      debugPrint('CustomExerciseProvider: Exercise not found for update with id: $exerciseId');
      throw Exception('Exercise not found');
    }

    final updatedExercise = exerciseToUpdate.copyWith(
      name: _exerciseName.trim(),
      muscleGroup: _selectedMuscleGroup,
      isFavorite: _isFavorite,
      notes: _notes,
      isCustom: exerciseToUpdate.isCustom,
      iconPath: exerciseToUpdate.iconPath,
    );

    try {
      await _exerciseProvider.updateExercise(updatedExercise);
      debugPrint('CustomExerciseProvider: Exercise updated successfully: ${_exerciseName.trim()}');
      resetForm();
    } catch (e) {
      debugPrint('CustomExerciseProvider: Failed to update exercise: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> deleteExercise(String exerciseId) async {
    try {
      // Updated 2024-07-26: Call the correct delete method in ExerciseProvider
      await _exerciseProvider.deleteExercise(exerciseId);
      debugPrint('CustomExerciseProvider: Exercise deleted successfully: $exerciseId');
      // No return value needed
    } catch (e) {
      debugPrint('CustomExerciseProvider: Failed to delete exercise: ${e.toString()}');
      rethrow;
    }
  }
}
