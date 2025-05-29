import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/workout.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// Added 2025-05-28: Imports for Excel export
import 'dart:io';
import 'package:excel/excel.dart' as excel_package;
import 'dart:typed_data'; // Added 2025-05-30 for Uint8List
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'; // Added 2025-05-29 for permissions
import 'package:shared_preferences/shared_preferences.dart'; // Added 2025-05-29: For sequential file naming

class WorkoutProvider with ChangeNotifier {
  Box<Workout>? _workoutsBox;
  List<Workout> _cachedWorkouts = [];
  DateTime? _lastCacheUpdate;
  final _cacheTimeout = const Duration(minutes: 5);
  bool _isInitialized = false;

  // Make the constructor accept an optional Box parameter
  WorkoutProvider([Box<Workout>? workoutsBox]) {
    if (workoutsBox != null) {
      _workoutsBox = workoutsBox;
      _updateCache();
      _isInitialized = true;
    } else {
      _tryInitialize();
    }
  }

  // Try to initialize without throwing errors
  Future<void> _tryInitialize() async {
    try {
      await initialize();
    } catch (e) {
      debugPrint(
        'Deferred WorkoutProvider initialization will be attempted later: $e',
      );
    }
  }

  // Add initialization method for deferred initialization
  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        // Updated 2025-05-28: Check if box is already open, if not, open it
        if (!Hive.isBoxOpen('workouts')) {
          debugPrint('WorkoutProvider: Opening workouts box');
          _workoutsBox = await Hive.openBox<Workout>('workouts');
        } else {
          debugPrint('WorkoutProvider: Getting already open workouts box');
          _workoutsBox = Hive.box<Workout>('workouts');
        }

        if (_workoutsBox == null) {
          throw Exception('Failed to get workouts box after initialization');
        }

        _updateCache();
        _isInitialized = true;
        debugPrint(
          'WorkoutProvider: Successfully initialized with ${_workoutsBox!.length} workouts',
        );
        debugPrint(
          'WorkoutProvider: workouts box hashcode: ${_workoutsBox.hashCode}',
        );
      } catch (e) {
        debugPrint('Error initializing WorkoutProvider: $e');
        rethrow;
      }
    }
  }

  // Get box safely with error handling
  Future<Box<Workout>?> _getBox() async {
    if (_workoutsBox == null || !_isInitialized) {
      try {
        debugPrint(
          'WorkoutProvider: Box not initialized, attempting initialization',
        );
        await initialize();
        // After initialize, check again if box is available
        if (_workoutsBox == null) {
          debugPrint('WorkoutProvider: Box still null after initialization');
          return null;
        }
      } catch (e) {
        debugPrint('Could not get workouts box: $e');
        return null;
      }
    }
    return _workoutsBox;
  }

  void _updateCache() {
    if (_workoutsBox != null) {
      _cachedWorkouts =
          _workoutsBox!.values.toList()
            ..sort((a, b) => b.date.compareTo(a.date));
      _lastCacheUpdate = DateTime.now();
      debugPrint(
        'WorkoutProvider: Cache updated with ${_cachedWorkouts.length} workouts',
      );
    }
  }

  bool _isCacheValid() {
    return _lastCacheUpdate != null &&
        DateTime.now().difference(_lastCacheUpdate!) < _cacheTimeout;
  }

  List<Workout> get workouts {
    if (!_isInitialized) {
      debugPrint('Warning: WorkoutProvider not initialized');
      return [];
    }
    debugPrint(
      'WorkoutProvider: Getting workouts, cache valid: ${_isCacheValid()}',
    );
    if (!_isCacheValid()) {
      _updateCache();
    }
    return _cachedWorkouts;
  }

  List<Workout> _getRelevantWorkouts(DateTime? date) {
    if (!_isInitialized) return [];
    if (date == null) return workouts;

    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return workouts
        .where(
          (w) =>
              w.date.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
              w.date.isBefore(dayEnd),
        )
        .toList();
  }

  // Alias method to match DashboardScreen's expected method name
  List<Workout> getWorkoutsForDate(DateTime date) {
    return getWorkoutsForDay(date);
  }

  double getTotalWeightLifted([DateTime? date]) {
    final relevantWorkouts = _getRelevantWorkouts(date);
    return relevantWorkouts.fold(
      0.0,
      (total, workout) => total + workout.totalWeightLifted,
    );
  }

  double getEffectiveWeightLifted([DateTime? date]) {
    final relevantWorkouts = _getRelevantWorkouts(date);
    return relevantWorkouts.fold(
      0.0,
      (total, workout) => total + workout.effectiveWeightLifted,
    );
  }

  int getTotalSets([DateTime? date]) {
    final relevantWorkouts = _getRelevantWorkouts(date);
    return relevantWorkouts.fold(
      0,
      (total, workout) => total + workout.totalSets,
    );
  }

  int getHardSetCount([DateTime? date]) {
    final relevantWorkouts = _getRelevantWorkouts(date);
    return relevantWorkouts.fold(
      0,
      (total, workout) => total + workout.hardSetCount,
    );
  }

  Future<void> addWorkout(Workout workout) async {
    final box = await _getBox();
    if (box == null) {
      debugPrint('WorkoutProvider: Workouts box is null, cannot add workout.');
      throw Exception('WorkoutProvider: Workouts box is unavailable.');
    }
    try {
      await box.add(workout);
      _updateCache();
      notifyListeners();
      debugPrint(
        'WorkoutProvider: Workout added successfully with id: ${workout.id}',
      );
      debugPrint('WorkoutProvider: workouts box hashcode: ${box.hashCode}');
    } catch (e) {
      debugPrint('WorkoutProvider: Error adding workout: $e');
      rethrow; // Rethrow the exception to be handled by the caller
    }
  }

  Future<void> updateWorkout(Workout workout) async {
    final box = await _getBox();
    if (box == null) {
      debugPrint(
        'WorkoutProvider: Workouts box is null, cannot update workout.',
      );
      throw Exception('WorkoutProvider: Workouts box is unavailable.');
    }
    try {
      final index = box.values.toList().indexWhere((w) => w.id == workout.id);

      if (index != -1) {
        await box.putAt(index, workout);
        _updateCache();
        notifyListeners();
        debugPrint(
          'WorkoutProvider: Workout updated successfully with id: ${workout.id}',
        );
        debugPrint('WorkoutProvider: workouts box hashcode: ${box.hashCode}');
      } else {
        debugPrint(
          'WorkoutProvider: Workout with id ${workout.id} not found for update.',
        );
        // Optionally, throw an exception or handle as an add operation
        // throw Exception('Workout with id ${workout.id} not found for update.');
      }
    } catch (e) {
      debugPrint('WorkoutProvider: Error updating workout: $e');
      rethrow; // Rethrow the exception to be handled by the caller
    }
  }

  Future<void> deleteWorkout(String id) async {
    final box = await _getBox();
    if (box == null) {
      debugPrint(
        'WorkoutProvider: Workouts box is null, cannot delete workout.',
      );
      throw Exception('WorkoutProvider: Workouts box is unavailable.');
    }
    try {
      await box.delete(id);
      _updateCache();
      notifyListeners();
      debugPrint('WorkoutProvider: Workout with id: $id deleted successfully');
    } catch (e) {
      debugPrint('WorkoutProvider: Error deleting workout: $e');
      rethrow;
    }
  }

  List<Map<String, dynamic>> getExerciseProgressData(
    String exerciseId, {
    int limit = 10,
  }) {
    if (!_isInitialized) return [];

    final workoutsWithExercise =
        workouts
            .where((w) => w.exercises.any((e) => e.exerciseId == exerciseId))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    final limitedWorkouts =
        workoutsWithExercise.length > limit
            ? workoutsWithExercise.sublist(workoutsWithExercise.length - limit)
            : workoutsWithExercise;

    return limitedWorkouts.map((w) {
      final exercise = w.exercises.firstWhere(
        (e) => e.exerciseId == exerciseId,
      );
      final maxWeight = exercise.sets.fold(
        0.0,
        (max, set) => set.weight > max ? set.weight : max,
      );
      final totalReps = exercise.sets.fold(0, (sum, set) => sum + set.reps);
      final totalSets = exercise.sets.length;
      return {
        'date': w.date,
        'weight': maxWeight,
        'reps': totalReps,
        'sets': totalSets,
        'volume': exercise.sets.fold(
          0.0,
          (sum, set) => sum + (set.weight * set.reps),
        ),
      };
    }).toList();
  }

  Map<String, int> getMuscleGroupDistribution() {
    if (!_isInitialized) return {};

    final distribution = <String, int>{};

    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        distribution[exercise.muscleGroup] =
            (distribution[exercise.muscleGroup] ?? 0) + 1;
      }
    }

    return distribution;
  }

  Map<String, dynamic> getDashboardStats() {
    if (!_isInitialized) {
      return {
        'today': {'workouts': 0, 'sets': 0, 'weight': 0.0, 'hardSets': 0},
        'week': {'workouts': 0, 'sets': 0, 'weight': 0.0, 'hardSets': 0},
        'month': {'workouts': 0, 'sets': 0, 'weight': 0.0, 'hardSets': 0},
        'muscleGroupData': <String, int>{},
        'dailyData': <Map<String, dynamic>>[],
      };
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Initialize default values
    final defaultStats = {
      'workouts': 0,
      'sets': 0,
      'weight': 0.0,
      'hardSets': 0,
    };

    return {
      'today':
          _calculatePeriodStats(_getRelevantWorkouts(today)) ?? defaultStats,
      'week':
          _calculatePeriodStats(_getRelevantWorkoutsForDays(7)) ?? defaultStats,
      'month':
          _calculatePeriodStats(_getRelevantWorkoutsForDays(30)) ??
          defaultStats,
      'muscleGroupData': getMuscleGroupDistribution(),
      'dailyData': _getWeeklyDailyData(),
    };
  }

  Map<String, dynamic>? _calculatePeriodStats(List<Workout> workouts) {
    if (workouts.isEmpty) return null;

    return {
      'workouts': workouts.length,
      'sets': workouts.fold(0, (sum, w) => sum + w.totalSets),
      'weight': workouts.fold(0.0, (sum, w) => sum + w.totalWeightLifted),
      'hardSets': workouts.fold(0, (sum, w) => sum + w.hardSetCount),
    };
  }

  List<Workout> _getRelevantWorkoutsForDays(int days) {
    if (!_isInitialized) return [];

    final now = DateTime.now();
    final startDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1));

    return workouts
        .where(
          (w) =>
              w.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
              w.date.isBefore(now.add(const Duration(days: 1))),
        )
        .toList();
  }

  List<Map<String, dynamic>> _getWeeklyDailyData() {
    if (!_isInitialized) {
      return List.generate(
        7,
        (index) => {
          'day': '',
          'volume': 0.0,
          'date': DateTime.now().subtract(Duration(days: 6 - index)),
        },
      );
    }

    final dailyData = List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      final workouts = _getRelevantWorkouts(date);
      return {
        'day': DateFormat('E').format(date),
        'volume': workouts.fold(0.0, (sum, w) => sum + w.totalWeightLifted),
        'date': date,
      };
    });
    return dailyData;
  }

  List<Workout> getWorkoutsForDay(DateTime date) {
    return _getRelevantWorkouts(date);
  }

  Workout? getLatestWorkout() {
    if (!_isInitialized || workouts.isEmpty) return null;
    return workouts.first; // Already sorted by date in _updateCache
  }

  Workout createEmptyWorkout() {
    return Workout(
      id: const Uuid().v4(),
      date: DateTime.now(),
      exercises: [],
      notes: '',
      workoutName: 'New Workout', // Added workoutName
    );
  }

  // Updated 2025-05-29: Changed filename generation to be sequential
  Future<String?> exportWorkoutDataToExcel() async {
    if (!_isInitialized || _cachedWorkouts.isEmpty) {
      debugPrint(
        'WorkoutProvider: No workouts to export or provider not initialized.',
      );
      return null;
    }

    // Added 2025-05-29: Check and request storage permissions
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      if (!status.isGranted) {
        debugPrint('WorkoutProvider: Storage permission denied for Excel export.');
        // Optionally, communicate this back to the UI with a specific error/message
        return null; // Or throw an exception that the UI can catch
      }
    }

    try {
      final excel = excel_package.Excel.createExcel();
      final sheet = excel['Workout Data'];

      // Add headers
      // Updated 2025-05-28: Removed 'Exercise Notes' as it's not in the model
      final headers = [
        'Date',
        'Workout Name',
        'Exercise Name',
        'Set Number',
        'Reps',
        'Weight',
        'Is Hard Set',
        'Set Notes',
        // 'Exercise Notes', // Removed
        'Workout Notes',
        'Duration (seconds)',
      ];
      for (var i = 0; i < headers.length; i++) {
        sheet
            .cell(
              excel_package.CellIndex.indexByColumnRow(
                columnIndex: i,
                rowIndex: 0,
              ),
            )
            .value = excel_package.TextCellValue(headers[i]);
      }

      int rowIndex = 1;
      for (final workout in _cachedWorkouts) {
        for (final exercise in workout.exercises) {
          if (exercise.sets.isEmpty) {
            // Log exercises with no sets too
            final row = [
              excel_package.TextCellValue(
                DateFormat('yyyy-MM-dd HH:mm').format(workout.date),
              ),
              excel_package.TextCellValue(
                workout.workoutName ?? '',
              ), // Updated 2025-05-28
              excel_package.TextCellValue(exercise.exerciseName),
              excel_package.TextCellValue('-'), // Set Number
              excel_package.TextCellValue('-'), // Reps
              excel_package.TextCellValue('-'), // Weight
              excel_package.TextCellValue('-'), // Is Hard Set
              excel_package.TextCellValue('-'), // Set Notes
              // excel_package.TextCellValue(exercise.notes ?? ''), // Removed 2025-05-28
              excel_package.TextCellValue(workout.notes ?? ''),
              excel_package.IntCellValue(
                workout.duration,
              ), // Updated 2025-05-28
            ];
            for (var i = 0; i < row.length; i++) {
              sheet
                  .cell(
                    excel_package.CellIndex.indexByColumnRow(
                      columnIndex: i,
                      rowIndex: rowIndex,
                    ),
                  )
                  .value = row[i];
            }
            rowIndex++;
          } else {
            for (var i = 0; i < exercise.sets.length; i++) {
              final set = exercise.sets[i];
              final row = [
                excel_package.TextCellValue(
                  DateFormat('yyyy-MM-dd HH:mm').format(workout.date),
                ),
                excel_package.TextCellValue(
                  workout.workoutName ?? '',
                ), // Updated 2025-05-28
                excel_package.TextCellValue(exercise.exerciseName),
                excel_package.IntCellValue(i + 1), // Set Number
                excel_package.IntCellValue(set.reps),
                excel_package.DoubleCellValue(set.weight),
                excel_package.TextCellValue(
                  set.isHardSet.toString(),
                ), // Updated 2025-05-28
                excel_package.TextCellValue(set.notes ?? ''),
                // excel_package.TextCellValue(exercise.notes ?? ''), // Removed 2025-05-28
                excel_package.TextCellValue(workout.notes ?? ''),
                excel_package.IntCellValue(
                  workout.duration,
                ), // Updated 2025-05-28
              ];
              for (var j = 0; j < row.length; j++) {
                sheet
                    .cell(
                      excel_package.CellIndex.indexByColumnRow(
                        columnIndex: j,
                        rowIndex: rowIndex,
                      ),
                    )
                    .value = row[j];
              }
              rowIndex++;
            }
          }
        }
      }

      // Get a file path from the user
      // Updated 2025-05-29: Implement sequential file naming
      final prefs = await SharedPreferences.getInstance();
      int exportCounter = prefs.getInt('excel_export_counter') ?? 0;
      exportCounter++; // Increment for the new file

      final String suggestedFileName = 'workout_tracker_pro_$exportCounter.xlsx'; // Updated 2025-05-29: More specific name

      // Updated 2025-05-30: Encode Excel to bytes before picking file
      final List<int>? fileBytes = excel.encode();
      if (fileBytes == null) {
        debugPrint('WorkoutProvider: Failed to encode Excel data to bytes.');
        return null; // Or throw an appropriate exception
      }

      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: suggestedFileName,
        allowedExtensions: ['xlsx'], // Good for UX, might not be strictly needed with bytes
        type: FileType.custom,      // Good for UX, might not be strictly needed with bytes
        bytes: fileBytes != null ? Uint8List.fromList(fileBytes) : null, // Provide the Excel data as bytes
      );

      if (outputFile != null) {
        // Save the new counter only if file was saved successfully
        await prefs.setInt('excel_export_counter', exportCounter);
        debugPrint('WorkoutProvider: Excel data exported to $outputFile');
        return outputFile; // Path to the saved file
      } else {
        // User cancelled the picker or an error occurred during saving
        debugPrint('WorkoutProvider: Excel export cancelled by user or file saving failed.');
        return null;
      }
    } catch (e) {
      debugPrint('WorkoutProvider: Error exporting workout data to Excel: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _cachedWorkouts.clear();
    super.dispose();
  }
}
