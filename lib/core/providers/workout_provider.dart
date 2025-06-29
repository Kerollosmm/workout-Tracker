import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/workout.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// Added 2025-05-28: Imports for Excel export
import 'dart:io';
// Removed Excel and file picker related imports, as they are now in ExcelExportService
// import 'dart:io';
// import 'package:excel/excel.dart' as excel_package;
// import 'dart:typed_data';
// import 'package:file_picker/file_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class WorkoutProvider with ChangeNotifier {
  /// Hive box for storing workouts.
  /// Hive box for storing workouts.
  Box<Workout>? _workoutsBox;

  /// In-memory cache of workouts, sorted by date descending.
  List<Workout> _cachedWorkouts = [];

  /// Timestamp of the last cache update.
  DateTime? _lastCacheUpdate;

  /// Duration for how long the cache is considered valid.
  final Duration _cacheTimeout = const Duration(minutes: 5);

  /// Flag indicating whether the provider has been initialized.
  bool _isInitialized = false;

  /// Creates a new instance of [WorkoutProvider].
  ///
  /// Optionally accepts a [Box<Workout>] for testing or pre-initialized scenarios.
  /// If no box is provided, it will attempt to initialize one from Hive.
  WorkoutProvider([Box<Workout>? workoutsBox]) {
    if (workoutsBox != null) {
      _workoutsBox = workoutsBox;
      _updateCache();
      _isInitialized = true;
    } else {
      _tryInitialize();
    }
  }

  /// Tries to initialize the provider by opening the Hive box and loading initial data.
  /// This method is called by the constructor if no pre-initialized box is provided.
  /// It catches and logs errors during initialization to prevent app crashes.
  Future<void> _tryInitialize() async {
    try {
      await initialize();
    } catch (e) {
      debugPrint(
        'Deferred WorkoutProvider initialization will be attempted later: $e',
      );
    }
  }

  /// Initializes the [WorkoutProvider] by opening the 'workouts' Hive box
  /// and populating the cache.
  ///
  /// This method should be called before accessing workout data if the provider
  /// was not initialized with a pre-opened box.
  /// Throws an exception if Hive box initialization fails.
  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
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

  /// Safely retrieves the Hive box instance, attempting initialization if necessary.
  /// Returns the [Box<Workout>] or null if initialization fails.
  Future<Box<Workout>?> _getBox() async {
    if (_workoutsBox == null || !_isInitialized) {
      try {
        debugPrint(
          'WorkoutProvider: Box not initialized, attempting initialization',
        );
        await initialize();
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

  /// Updates the in-memory cache [_cachedWorkouts] from the Hive box.
  /// Sorts workouts by date in descending order.
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

  /// Checks if the current cache is still valid based on [_cacheTimeout].
  bool _isCacheValid() {
    return _lastCacheUpdate != null &&
        DateTime.now().difference(_lastCacheUpdate!) < _cacheTimeout;
  }

  /// Returns a list of all workouts.
  ///
  /// If the provider is not initialized, returns an empty list.
  /// Updates the cache if it's invalid before returning data.
  List<Workout> get workouts {
    if (!_isInitialized) {
      debugPrint('Warning: WorkoutProvider not initialized, returning empty list.');
      return [];
    }
    debugPrint(
      'WorkoutProvider: Getting workouts, cache valid: ${_isCacheValid()}',
    );
    if (!_isCacheValid()) {
      _updateCache();
    }
    return List<Workout>.unmodifiable(_cachedWorkouts);
  }

  /// Retrieves workouts relevant to a specific [date].
  /// If [date] is null, returns all workouts.
  List<Workout> _getRelevantWorkouts(DateTime? date) {
    if (!_isInitialized) return [];
    if (date == null) return workouts;

    final DateTime dayStart = DateTime(date.year, date.month, date.day);
    final DateTime dayEnd = dayStart.add(const Duration(days: 1));

    return workouts
        .where(
          (Workout w) =>
              w.date.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
              w.date.isBefore(dayEnd),
        )
        .toList();
  }

  /// Retrieves workouts for a specific [date].
  /// Alias for [_getRelevantWorkouts] to match usage in DashboardScreen.
  List<Workout> getWorkoutsForDate(DateTime date) {
    return getWorkoutsForDay(date);
  }

  /// Calculates the total weight lifted for workouts on a specific [date].
  /// If [date] is null, calculates for all workouts.
  double getTotalWeightLifted([DateTime? date]) {
    final List<Workout> relevantWorkouts = _getRelevantWorkouts(date);
    return relevantWorkouts.fold<double>(
      0.0,
      (double total, Workout workout) => total + workout.totalWeightLifted,
    );
  }

  /// Calculates the effective weight lifted (e.g., excluding bodyweight exercises if applicable)
  /// for workouts on a specific [date].
  /// If [date] is null, calculates for all workouts.
  double getEffectiveWeightLifted([DateTime? date]) {
    final List<Workout> relevantWorkouts = _getRelevantWorkouts(date);
    return relevantWorkouts.fold<double>(
      0.0,
      (double total, Workout workout) => total + workout.effectiveWeightLifted,
    );
  }

  /// Calculates the total number of sets performed for workouts on a specific [date].
  /// If [date] is null, calculates for all workouts.
  int getTotalSets([DateTime? date]) {
    final List<Workout> relevantWorkouts = _getRelevantWorkouts(date);
    return relevantWorkouts.fold<int>(
      0,
      (int total, Workout workout) => total + workout.totalSets,
    );
  }

  /// Calculates the total number of hard sets performed for workouts on a specific [date].
  /// If [date] is null, calculates for all workouts.
  int getHardSetCount([DateTime? date]) {
    final List<Workout> relevantWorkouts = _getRelevantWorkouts(date);
    return relevantWorkouts.fold<int>(
      0,
      (int total, Workout workout) => total + workout.hardSetCount,
    );
  }

  /// Adds a new [workout] to the Hive box and updates the cache.
  /// Notifies listeners after the operation.
  /// Throws an exception if the Hive box is unavailable or if the add operation fails.
  Future<void> addWorkout(Workout workout) async {
    final Box<Workout>? box = await _getBox();
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
      rethrow;
    }
  }

  /// Updates an existing [workout] in the Hive box and updates the cache.
  /// Notifies listeners after the operation.
  /// Throws an exception if the Hive box is unavailable or if the update operation fails.
  /// If the workout ID is not found, a debug message is printed.
  Future<void> updateWorkout(Workout workout) async {
    final Box<Workout>? box = await _getBox();
    if (box == null) {
      debugPrint(
        'WorkoutProvider: Workouts box is null, cannot update workout.',
      );
      throw Exception('WorkoutProvider: Workouts box is unavailable.');
    }
    try {
      final List<Workout> allWorkouts = box.values.toList();
      final int index = allWorkouts.indexWhere((w) => w.id == workout.id);

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
        // Consider throwing an exception if not found is an error state.
        // throw Exception('Workout with id ${workout.id} not found for update.');
      }
    } catch (e) {
      debugPrint('WorkoutProvider: Error updating workout: $e');
      rethrow;
    }
  }

  /// Deletes a workout with the given [id] from the Hive box and updates the cache.
  /// Notifies listeners after the operation.
  /// Throws an exception if the Hive box is unavailable or if the delete operation fails.
  Future<void> deleteWorkout(String id) async {
    final Box<Workout>? box = await _getBox();
    if (box == null) {
      debugPrint(
        'WorkoutProvider: Workouts box is null, cannot delete workout.',
      );
      throw Exception('WorkoutProvider: Workouts box is unavailable.');
    }
    try {
      // Hive's delete method uses the key, which for auto-incrementing boxes is not the ID.
      // We need to find the key of the workout with the given ID.
      final Map<dynamic, Workout> map = box.toMap();
      dynamic keyToDelete;
      map.forEach((key, value) {
        if (value.id == id) {
          keyToDelete = key;
        }
      });

      if (keyToDelete != null) {
        await box.delete(keyToDelete);
        _updateCache();
        notifyListeners();
        debugPrint('WorkoutProvider: Workout with id: $id deleted successfully');
      } else {
        debugPrint('WorkoutProvider: Workout with id: $id not found for deletion.');
      }
    } catch (e) {
      debugPrint('WorkoutProvider: Error deleting workout: $e');
      rethrow;
    }
  }

  /// Retrieves progress data for a specific exercise, identified by [exerciseId].
  /// Returns a list of maps, each containing date, max weight, total reps, total sets, and volume.
  /// Limits the data to the latest [limit] workouts (default is 10).
  /// Returns an empty list if the provider is not initialized.
  List<Map<String, dynamic>> getExerciseProgressData(
    String exerciseId, {
    int limit = 10,
  }) {
    if (!_isInitialized) return [];

    final List<Workout> workoutsWithExercise =
        workouts
            .where((Workout w) => w.exercises.any((e) => e.exerciseId == exerciseId))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date)); // Sorted ascending by date for chronological progress

    final List<Workout> limitedWorkouts =
        workoutsWithExercise.length > limit
            ? workoutsWithExercise.sublist(workoutsWithExercise.length - limit)
            : workoutsWithExercise;

    return limitedWorkouts.map((Workout w) {
      final WorkoutExercise exercise = w.exercises.firstWhere(
        (e) => e.exerciseId == exerciseId,
      );
      final double maxWeight = exercise.sets.fold<double>(
        0.0,
        (double max, WorkoutSet set) => set.weight > max ? set.weight : max,
      );
      final int totalReps = exercise.sets.fold<int>(0, (int sum, WorkoutSet set) => sum + set.reps);
      final int totalSets = exercise.sets.length;
      return <String, dynamic>{
        'date': w.date,
        'weight': maxWeight,
        'reps': totalReps,
        'sets': totalSets,
        'volume': exercise.sets.fold<double>(
          0.0,
          (double sum, WorkoutSet set) => sum + (set.weight * set.reps),
        ),
      };
    }).toList();
  }

  /// Calculates the distribution of exercises by muscle group across all workouts.
  /// Returns a map where keys are muscle group names and values are the count of exercises.
  /// Returns an empty map if the provider is not initialized.
  Map<String, int> getMuscleGroupDistribution() {
    if (!_isInitialized) return {};

    final Map<String, int> distribution = <String, int>{};

    for (final Workout workout in workouts) {
      for (final WorkoutExercise exercise in workout.exercises) {
        distribution[exercise.muscleGroup] =
            (distribution[exercise.muscleGroup] ?? 0) + 1;
      }
    }
    return distribution;
  }

  /// Retrieves statistics for the dashboard, including today's, week's, and month's performance,
  /// muscle group distribution, and daily workout volume for the last week.
  /// Returns default zeroed stats if the provider is not initialized.
  Map<String, dynamic> getDashboardStats() {
    if (!_isInitialized) {
      return <String, dynamic>{
        'today': <String, dynamic>{'workouts': 0, 'sets': 0, 'weight': 0.0, 'hardSets': 0},
        'week': <String, dynamic>{'workouts': 0, 'sets': 0, 'weight': 0.0, 'hardSets': 0},
        'month': <String, dynamic>{'workouts': 0, 'sets': 0, 'weight': 0.0, 'hardSets': 0},
        'muscleGroupData': <String, int>{},
        'dailyData': <Map<String, dynamic>>[],
      };
    }

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    const Map<String, dynamic> defaultStats = <String, dynamic>{
      'workouts': 0,
      'sets': 0,
      'weight': 0.0,
      'hardSets': 0,
    };

    return <String, dynamic>{
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

  /// Calculates period statistics (workouts, sets, weight, hard sets) for a given list of [workouts].
  /// Returns null if the list is empty.
  Map<String, dynamic>? _calculatePeriodStats(List<Workout> workouts) {
    if (workouts.isEmpty) return null;

    return <String, dynamic>{
      'workouts': workouts.length,
      'sets': workouts.fold<int>(0, (int sum, Workout w) => sum + w.totalSets),
      'weight': workouts.fold<double>(0.0, (double sum, Workout w) => sum + w.totalWeightLifted),
      'hardSets': workouts.fold<int>(0, (int sum, Workout w) => sum + w.hardSetCount),
    };
  }

  /// Retrieves workouts performed within the last [days].
  /// Returns an empty list if the provider is not initialized.
  List<Workout> _getRelevantWorkoutsForDays(int days) {
    if (!_isInitialized) return [];

    final DateTime now = DateTime.now();
    final DateTime startDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1)); // Inclusive of the start day

    return workouts
        .where(
          (Workout w) =>
              w.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
              w.date.isBefore(now.add(const Duration(days: 1))), // Inclusive of today
        )
        .toList();
  }

  /// Retrieves daily workout data (day name, total volume, date) for the last 7 days.
  /// Returns a list of 7 entries with zero volume if not initialized.
  List<Map<String, dynamic>> _getWeeklyDailyData() {
    if (!_isInitialized) {
      return List<Map<String, dynamic>>.generate(
        7,
        (int index) {
          final DateTime date = DateTime.now().subtract(Duration(days: 6 - index));
          return <String, dynamic>{
            'day': DateFormat('E').format(date), // 'E' gives abbreviated day name (e.g., 'Mon')
            'volume': 0.0,
            'date': date,
          };
        },
      );
    }

    final List<Map<String, dynamic>> dailyData = List<Map<String, dynamic>>.generate(7, (int index) {
      final DateTime date = DateTime.now().subtract(Duration(days: 6 - index));
      final List<Workout> dailyWorkouts = _getRelevantWorkouts(date);
      return <String, dynamic>{
        'day': DateFormat('E').format(date),
        'volume': dailyWorkouts.fold<double>(0.0, (double sum, Workout w) => sum + w.totalWeightLifted),
        'date': date,
      };
    });
    return dailyData;
  }

  /// Retrieves workouts for a specific [date].
  List<Workout> getWorkoutsForDay(DateTime date) {
    return _getRelevantWorkouts(date);
  }

  /// Returns the latest workout based on date.
  /// Returns null if not initialized or if there are no workouts.
  Workout? getLatestWorkout() {
    if (!_isInitialized || workouts.isEmpty) return null;
    // Assumes workouts list is already sorted by date descending by _updateCache
    return workouts.first;
  }

  /// Creates a new empty [Workout] object with a unique ID and current date.
  Workout createEmptyWorkout() {
    return Workout(
      id: const Uuid().v4(),
      date: DateTime.now(),
      exercises: [],
      notes: '',
      workoutName: 'New Workout', // Added workoutName
    );
  }

  // Note: exportWorkoutDataToExcel method has been removed and moved to ExcelExportService.
  // The UI should now call ExcelExportService directly, providing it with `workouts` from this provider.

  @override
  void dispose() {
    _cachedWorkouts.clear();
    super.dispose();
  }
}
