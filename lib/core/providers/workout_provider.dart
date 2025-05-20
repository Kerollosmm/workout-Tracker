import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/workout.dart';
import 'package:intl/intl.dart';

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
      debugPrint('Deferred WorkoutProvider initialization will be attempted later: $e');
    }
  }

  // Add initialization method for deferred initialization
  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        _workoutsBox = Hive.box<Workout>('workouts');
        _updateCache();
        _isInitialized = true;
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
        await initialize();
      } catch (e) {
        debugPrint('Could not get workouts box: $e');
        return null;
      }
    }
    return _workoutsBox;
  }

  void _updateCache() {
    if (_workoutsBox != null) {
      _cachedWorkouts = _workoutsBox!.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      _lastCacheUpdate = DateTime.now();
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
    
    return workouts.where((w) =>
      w.date.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
      w.date.isBefore(dayEnd)
    ).toList();
  }

  // Alias method to match DashboardScreen's expected method name
  List<Workout> getWorkoutsForDate(DateTime date) {
    return getWorkoutsForDay(date);
  }

  double getTotalWeightLifted([DateTime? date]) {
    final relevantWorkouts = _getRelevantWorkouts(date);
    return relevantWorkouts.fold(0.0, 
      (total, workout) => total + workout.totalWeightLifted
    );
  }

  double getEffectiveWeightLifted([DateTime? date]) {
    final relevantWorkouts = _getRelevantWorkouts(date);
    return relevantWorkouts.fold(0.0, 
      (total, workout) => total + workout.effectiveWeightLifted
    );
  }

  int getTotalSets([DateTime? date]) {
    final relevantWorkouts = _getRelevantWorkouts(date);
    return relevantWorkouts.fold(0, 
      (total, workout) => total + workout.totalSets
    );
  }

  int getHardSetCount([DateTime? date]) {
    final relevantWorkouts = _getRelevantWorkouts(date);
    return relevantWorkouts.fold(0, 
      (total, workout) => total + workout.hardSetCount
    );
  }

  Future<void> addWorkout(Workout workout) async {
    final box = await _getBox();
    if (box == null) return;
    await box.add(workout);
    _updateCache();
    notifyListeners();
  }

  Future<void> updateWorkout(Workout workout) async {
    final box = await _getBox();
    if (box == null) return;
    final index = box.values.toList().indexWhere(
        (w) => w.id == workout.id);

    if (index != -1) {
      await box.putAt(index, workout);
      _updateCache();
      notifyListeners();
    }
  }

  Future<void> deleteWorkout(String id) async {
    final box = await _getBox();
    if (box == null) return;
    final index = box.values.toList().indexWhere((w) => w.id == id);

    if (index != -1) {
      await box.deleteAt(index);
      _updateCache();
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> getExerciseProgressData(String exerciseId, {int limit = 10}) {
    if (!_isInitialized) return [];
    
    final workoutsWithExercise = workouts
      .where((w) => w.exercises.any((e) => e.exerciseId == exerciseId))
      .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    
    final limitedWorkouts = workoutsWithExercise.length > limit 
      ? workoutsWithExercise.sublist(workoutsWithExercise.length - limit)
      : workoutsWithExercise;

    return limitedWorkouts.map((w) {
      final exercise = w.exercises.firstWhere((e) => e.exerciseId == exerciseId);
      final maxWeight = exercise.sets.fold(0.0, 
        (max, set) => set.weight > max ? set.weight : max
      );
      final totalReps = exercise.sets.fold(0, (sum, set) => sum + set.reps);
      final totalSets = exercise.sets.length;
      return {
        'date': w.date,
        'weight': maxWeight,
        'reps': totalReps,
        'sets': totalSets,
        'volume': exercise.sets.fold(0.0, 
          (sum, set) => sum + (set.weight * set.reps)
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
      'hardSets': 0
    };

    return {
      'today': _calculatePeriodStats(_getRelevantWorkouts(today)) ?? defaultStats,
      'week': _calculatePeriodStats(_getRelevantWorkoutsForDays(7)) ?? defaultStats,
      'month': _calculatePeriodStats(_getRelevantWorkoutsForDays(30)) ?? defaultStats,
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
    final startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
    
    return workouts.where((w) => 
      w.date.isAfter(startDate.subtract(const Duration(seconds: 1))) && 
      w.date.isBefore(now.add(const Duration(days: 1)))
    ).toList();
  }

  List<Map<String, dynamic>> _getWeeklyDailyData() {
    if (!_isInitialized) {
      return List.generate(7, (index) => {
        'day': '',
        'volume': 0.0,
        'date': DateTime.now().subtract(Duration(days: 6 - index)),
      });
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

  @override
  void dispose() {
    _cachedWorkouts.clear();
    super.dispose();
  }
}
