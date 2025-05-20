// lib/core/providers/user_provider.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' as excel_package;
import 'package:path/path.dart' as path;
// removed share_plus import as it's now used in profile_screen.dart
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../providers/workout_provider.dart';

class UserProvider with ChangeNotifier {
  User _user = User(
    id: '1',
    name: 'User',
    email: 'user@example.com',
    photoUrl: '',
    height: 175, // cm
    weight: 70, // kg
    fitnessGoal: 'Build Muscle',
    activityLevel: 'Moderate',
  );

  User get user => _user;

  Future<void> init() async {
    // In a real app, you would load user data from local storage or API
    // For now, we'll just use the default user
    notifyListeners();
  }

  void updateUserName(String name) {
    _user = _user.copyWith(name: name);
    notifyListeners();
  }

  void updateUserEmail(String email) {
    _user = _user.copyWith(email: email);
    notifyListeners();
  }

  void updateUserHeight(double height) {
    _user = _user.copyWith(height: height);
    notifyListeners();
  }

  void updateUserWeight(double weight) {
    _user = _user.copyWith(weight: weight);
    notifyListeners();
  }

  void updateUserFitnessGoal(String goal) {
    _user = _user.copyWith(fitnessGoal: goal);
    notifyListeners();
  }

  void updateUserActivityLevel(String level) {
    _user = _user.copyWith(activityLevel: level);
    notifyListeners();
  }

  Future<void> pickAndUpdateProfilePhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        _user = _user.copyWith(photoUrl: pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking profile photo: $e');
      // Handle the error appropriately
      rethrow;
    }
  }

  Future<void> takeAndUpdateProfilePhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        _user = _user.copyWith(photoUrl: pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error taking profile photo: $e');
      // Handle the error appropriately
      rethrow;
    }
  }

  // Weight increase suggestion feature
  bool shouldSuggestWeightIncrease(WorkoutProvider workoutProvider) {
    // Logic to determine if we should suggest weight increase
    // For example, if the user has completed the same weight for an exercise
    // for 3 consecutive workouts, we might suggest increasing the weight

    final recentWorkouts =
        workoutProvider.workouts
            .where(
              (w) => w.date.isAfter(
                DateTime.now().subtract(const Duration(days: 30)),
              ),
            )
            .toList();

    if (recentWorkouts.length < 3) return false;

    // Check if there are any exercises that have been performed with the same weight
    // for at least 3 consecutive workouts
    final exerciseMap = <String, List<double>>{};

    for (final workout in recentWorkouts) {
      for (final exercise in workout.exercises) {
        final exerciseName = exercise.exerciseName;
        final avgWeight =
            exercise.sets.isNotEmpty
                ? exercise.sets.map((s) => s.weight).reduce((a, b) => a + b) /
                    exercise.sets.length
                : 0.0;

        if (!exerciseMap.containsKey(exerciseName)) {
          exerciseMap[exerciseName] = [];
        }

        exerciseMap[exerciseName]!.add(avgWeight);
      }
    }

    // Check if any exercise has at least 3 consecutive workouts with the same weight
    for (final weights in exerciseMap.values) {
      if (weights.length >= 3) {
        // Check if the last 3 weights are the same (within a small margin)
        final last3Weights = weights.sublist(weights.length - 3);
        final avgWeight = last3Weights.reduce((a, b) => a + b) / 3;

        // If all weights are within 2.5% of the average, suggest an increase
        final allSimilar = last3Weights.every(
          (w) => (w - avgWeight).abs() / avgWeight < 0.025,
        );

        if (allSimilar && avgWeight > 0) {
          return true;
        }
      }
    }

    return false;
  }

  // Export workout data to Excel
  Future<String> exportWorkoutDataToExcel(WorkoutProvider workoutProvider) async {
    try {
      final excel = excel_package.Excel.createExcel();
      final excel_package.Sheet sheet = excel['Workout Data'];

      // Add headers
      final headers = [
        'Date',
        'Workout Name',
        'Exercise',
        'Sets',
        'Reps',
        'Weight (kg)',
        'Notes',
      ];

      for (var i = 0; i < headers.length; i++) {
        final String headerText = headers[i];
        final excel_package.CellValue cellValue = excel_package.TextCellValue(headerText);
        sheet
            .cell(excel_package.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = cellValue as excel_package.CellValue?;
      }

      // Add workout data
      var rowIndex = 1;
      final workouts = workoutProvider.workouts;

      for (final workout in workouts) {
        final workoutDate = DateFormat('yyyy-MM-dd').format(workout.date);

        for (final exercise in workout.exercises) {
          for (var setIndex = 0; setIndex < exercise.sets.length; setIndex++) {
            final workoutSet = exercise.sets[setIndex];

            // Date
            sheet
                .cell(excel_package.CellIndex.indexByColumnRow(
                    columnIndex: 0,
                    rowIndex: rowIndex,
                  ),)
                .value = excel_package.TextCellValue(workoutDate);

            // Workout Name
            sheet
                .cell(excel_package.CellIndex.indexByColumnRow(
                    columnIndex: 1,
                    rowIndex: rowIndex,
                  ),)
                .value = excel_package.TextCellValue(workout.workoutName);

            // Exercise Name
            sheet
                .cell(excel_package.CellIndex.indexByColumnRow(
                    columnIndex: 2,
                    rowIndex: rowIndex,
                  ),)
                .value = excel_package.TextCellValue(exercise.exerciseName);

            // Set Number
            sheet
                .cell(excel_package.CellIndex.indexByColumnRow(
                    columnIndex: 3,
                    rowIndex: rowIndex,
                  ),)
                .value = excel_package.IntCellValue(setIndex + 1);

            // Reps
            sheet
                .cell(excel_package.CellIndex.indexByColumnRow(
                    columnIndex: 4,
                    rowIndex: rowIndex,
                  ),)
                .value = excel_package.IntCellValue(workoutSet.reps);

            // Weight
            sheet
                .cell(excel_package.CellIndex.indexByColumnRow(
                    columnIndex: 5,
                    rowIndex: rowIndex,
                  ),)
                .value = excel_package.DoubleCellValue(workoutSet.weight);

            // Notes
            sheet
                .cell(excel_package.CellIndex.indexByColumnRow(
                    columnIndex: 6,
                    rowIndex: rowIndex,
                  ),)
                .value = excel_package.TextCellValue(workoutSet.notes ?? '');

            rowIndex++;
          }
        }
      }

      // Save the Excel file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(
        directory.path,
        'workout_data_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      );

      final fileBytes = excel.encode();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);

        // Share the file is now moved to the profile screen
        // Return the file path instead
        return filePath;
      } else {
        throw Exception('Failed to encode Excel file');
      }
    } catch (e) {
      debugPrint('Error exporting workout data: $e');
      rethrow;
    }
  }
}
