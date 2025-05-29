// lib/core/providers/user_provider.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' as excel_package;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
// removed share_plus import as it's now used in profile_screen.dart
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../providers/workout_provider.dart';
import 'package:file_picker/file_picker.dart';

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
    await _loadUserDataFromPreferences();
    notifyListeners();
  }

  Future<void> _loadUserDataFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final name = prefs.getString('user_name') ?? 'User';
      final email = prefs.getString('user_email') ?? 'user@example.com';
      final height = prefs.getDouble('user_height') ?? 175.0;
      final weight = prefs.getDouble('user_weight') ?? 70.0;
      final fitnessGoal =
          prefs.getString('user_fitness_goal') ?? 'Build Muscle';
      final activityLevel =
          prefs.getString('user_activity_level') ?? 'Moderate';
      final photoUrl = prefs.getString('user_photo_url') ?? '';
      final userId = prefs.getString('user_id') ?? '1';

      _user = User(
        id: userId,
        name: name,
        email: email,
        photoUrl: photoUrl,
        height: height,
        weight: weight,
        fitnessGoal: fitnessGoal,
        activityLevel: activityLevel,
      );
    } catch (e) {
      debugPrint('Error loading user data: $e');
      // Keep default user if loading fails
    }
  }

  Future<bool> isUserSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('user_signed_in') ?? false;
  }

  // Added 2025-05-29: Method to simulate user sign-in
  Future<void> signInUser(String name, String email) async {
    _user = _user.copyWith(name: name, email: email, id: Uuid().v4()); // Ensure a unique ID
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', _user.id);
    await prefs.setString('user_name', _user.name);
    await prefs.setString('user_email', _user.email);
    // Initialize other fields to default or empty if not provided at sign-in
    await prefs.setDouble('user_height', _user.height);
    await prefs.setDouble('user_weight', _user.weight);
    await prefs.setString('user_fitness_goal', _user.fitnessGoal);
    await prefs.setString('user_activity_level', _user.activityLevel);
    await prefs.setString('user_photo_url', ''); // Clear photo on new sign-in
    await prefs.setBool('user_signed_in', true);
    notifyListeners();
  }

  // Added 2025-05-29: Method to log out user
  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_photo_url');
    await prefs.remove('user_height');
    await prefs.remove('user_weight');
    await prefs.remove('user_fitness_goal');
    await prefs.remove('user_activity_level');
    await prefs.setBool('user_signed_in', false);

    // Reset user object to default state
    _user = User(
      id: '', // Clear ID
      name: 'User',
      email: 'user@example.com',
      photoUrl: '',
      height: 175,
      weight: 70,
      fitnessGoal: 'Build Muscle',
      activityLevel: 'Moderate',
    );
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    _user = _user.copyWith(name: name);
    await _saveToPreferences('user_name', name);
    notifyListeners();
  }

  Future<void> updateUserEmail(String email) async {
    _user = _user.copyWith(email: email);
    await _saveToPreferences('user_email', email);
    notifyListeners();
  }

  Future<void> updateUserHeight(double height) async {
    _user = _user.copyWith(height: height);
    await _saveToPreferences('user_height', height);
    notifyListeners();
  }

  Future<void> updateUserWeight(double weight) async {
    _user = _user.copyWith(weight: weight);
    await _saveToPreferences('user_weight', weight);
    notifyListeners();
  }

  Future<void> updateUserFitnessGoal(String goal) async {
    _user = _user.copyWith(fitnessGoal: goal);
    await _saveToPreferences('user_fitness_goal', goal);
    notifyListeners();
  }

  Future<void> updateUserActivityLevel(String level) async {
    _user = _user.copyWith(activityLevel: level);
    await _saveToPreferences('user_activity_level', level);
    notifyListeners();
  }

  // Updated 2025-05-28: Added method to directly update photo URL
  Future<void> updateUserPhotoUrl(String photoPath) async {
    // If an existing photo is being replaced, delete the old one if it's in app's directory
    if (_user.photoUrl.isNotEmpty && _user.photoUrl != photoPath) {
      try {
        final oldFile = File(_user.photoUrl);
        if (await oldFile.exists()) {
          // Check if the file is within the app's documents directory before deleting
          final appDir = await getApplicationDocumentsDirectory();
          if (path.isWithin(appDir.path, oldFile.path)) {
            await oldFile.delete();
            debugPrint('Old profile photo deleted: ${_user.photoUrl}');
          }
        }
      } catch (e) {
        debugPrint('Error deleting old profile photo: $e');
      }
    }

    // If a new photoPath is provided and it's not empty, copy it to a persistent location
    String finalPathToSave = photoPath;
    if (photoPath.isNotEmpty) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(photoPath)}';
        final savedImageFile = File(path.join(appDir.path, fileName));
        
        // Copy the picked file to the new persistent path
        await File(photoPath).copy(savedImageFile.path);
        finalPathToSave = savedImageFile.path;
        debugPrint('New profile photo saved to: $finalPathToSave');

        // If the original picked file (photoPath) is temporary (e.g., from cache), delete it if different from finalPathToSave
        // This step is crucial if image_picker returns a path to a temporary/cache file
        if (photoPath != finalPathToSave) {
            final tempFile = File(photoPath);
            if (await tempFile.exists()) {
                // Be cautious here: ensure it's truly a temp file before deleting
                // For simplicity, we assume if paths are different, original was temp.
                // A more robust check might involve checking if photoPath is in a known cache directory.
                // await tempFile.delete(); 
                // debugPrint('Temporary picked file deleted: $photoPath');
            }
        }

      } catch (e) {
        debugPrint('Error copying/saving new profile photo: $e');
        // If saving fails, don't update the URL to a potentially temporary/invalid path
        // Potentially revert to no photo or keep old one, depending on desired UX
        // For now, we'll proceed with the original photoPath if saving fails, but this might not be ideal
      }
    }

    _user = _user.copyWith(photoUrl: finalPathToSave);
    await _saveToPreferences('user_photo_url', finalPathToSave);
    notifyListeners();
  }

  Future<void> _saveToPreferences(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      }
    } catch (e) {
      debugPrint('Error saving to preferences: $e');
    }
  }

  Future<void> pickAndUpdateProfilePhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Save the image to app documents directory for persistence
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = await File(
          pickedFile.path,
        ).copy('${appDir.path}/$fileName');

        _user = _user.copyWith(photoUrl: savedImage.path);
        await _saveToPreferences('user_photo_url', savedImage.path);
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
        // Save the image to app documents directory for persistence
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = await File(
          pickedFile.path,
        ).copy('${appDir.path}/$fileName');

        _user = _user.copyWith(photoUrl: savedImage.path);
        await _saveToPreferences('user_photo_url', savedImage.path);
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
  Future<String?> exportWorkoutDataToExcel(
    WorkoutProvider workoutProvider,
  ) async {
    try {
      // Use file_picker to get the desired save location
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        // User canceled the picker
        return null;
      }

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
        final excel_package.CellValue cellValue = excel_package.TextCellValue(
          headerText,
        );
        sheet
            .cell(
              excel_package.CellIndex.indexByColumnRow(
                columnIndex: i,
                rowIndex: 0,
              ),
            )
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
                .cell(
                  excel_package.CellIndex.indexByColumnRow(
                    columnIndex: 0,
                    rowIndex: rowIndex,
                  ),
                )
                .value = excel_package.TextCellValue(workoutDate);

            // Workout Name
            sheet
                .cell(
                  excel_package.CellIndex.indexByColumnRow(
                    columnIndex: 1,
                    rowIndex: rowIndex,
                  ),
                )
                .value = excel_package.TextCellValue(
              workout.workoutName ?? "no data found ",
            );

            // Exercise Name
            sheet
                .cell(
                  excel_package.CellIndex.indexByColumnRow(
                    columnIndex: 2,
                    rowIndex: rowIndex,
                  ),
                )
                .value = excel_package.TextCellValue(exercise.exerciseName);

            // Set Number
            sheet
                .cell(
                  excel_package.CellIndex.indexByColumnRow(
                    columnIndex: 3,
                    rowIndex: rowIndex,
                  ),
                )
                .value = excel_package.IntCellValue(setIndex + 1);

            // Reps
            sheet
                .cell(
                  excel_package.CellIndex.indexByColumnRow(
                    columnIndex: 4,
                    rowIndex: rowIndex,
                  ),
                )
                .value = excel_package.IntCellValue(workoutSet.reps);

            // Weight
            sheet
                .cell(
                  excel_package.CellIndex.indexByColumnRow(
                    columnIndex: 5,
                    rowIndex: rowIndex,
                  ),
                )
                .value = excel_package.DoubleCellValue(workoutSet.weight);

            // Notes
            sheet
                .cell(
                  excel_package.CellIndex.indexByColumnRow(
                    columnIndex: 6,
                    rowIndex: rowIndex,
                  ),
                )
                .value = excel_package.TextCellValue(workoutSet.notes ?? '');

            rowIndex++;
          }
        }
      }

      // Save the Excel file to the selected directory
      final filePath = path.join(
        selectedDirectory,
        'workout_data_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      );

      final fileBytes = excel.encode();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);

        // Return the file path
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
