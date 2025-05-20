// lib/core/providers/analytics_provider.dart

import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/workout.dart';
import 'workout_provider.dart';

class AnalyticsProvider with ChangeNotifier {
  final WorkoutProvider _workoutProvider;
  
  // Filters
  String _timeFilter = 'Monthly'; // Weekly, Monthly, All Time
  String? _selectedExerciseId;
  String? _selectedMuscleGroup;
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Cache
  Map<String, List<Map<String, dynamic>>>? _exerciseDataCache;
  Map<String, int>? _exerciseCountCache;
  DateTime? _lastCacheUpdate;
  
  AnalyticsProvider(this._workoutProvider) {
    _initializeDefaultState();
    // Listen to workout changes
    _workoutProvider.addListener(_handleWorkoutChanges);
  }

  void _initializeDefaultState() {
    // Set default date range (last 30 days)
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(days: 30));
    _smartClearCache();
  }

  void _handleWorkoutChanges() {
    if (_smartClearCache()) {
      notifyListeners();
    }
  }

  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    final now = DateTime.now();
    return now.difference(_lastCacheUpdate!).inMinutes < 5; // Cache valid for 5 minutes
  }

  /// Clears cache selectively. If [exerciseId] is null, clears all caches.
  bool _smartClearCache([String? exerciseId]) {
    _exerciseDataCache ??= {};
    _exerciseCountCache ??= {};

    if (exerciseId == null) {
      final hadCache = (_exerciseDataCache?.isNotEmpty ?? false)
        || (_exerciseCountCache?.isNotEmpty ?? false);
      _exerciseDataCache = {};
      _exerciseCountCache = {};
      _lastCacheUpdate = null;
      return hadCache;
    }
    
    final removedData = _exerciseDataCache?.remove(exerciseId) != null;
    final removedCount = _exerciseCountCache?.remove(exerciseId) != null;
    if (removedData || removedCount) {
      _lastCacheUpdate = null;
      return true;
    }
    return false;
  }
  
  // Getters
  String get timeFilter => _timeFilter;
  String? get selectedExerciseId => _selectedExerciseId;
  String? get selectedMuscleGroup => _selectedMuscleGroup;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  
  // Setters
  void setTimeFilter(String filter) {
    _timeFilter = filter;
    
    // Update date range based on filter
    _endDate = DateTime.now();
    
    switch (filter) {
      case 'Weekly':
        _startDate = _endDate!.subtract(const Duration(days: 7));
        break;
      case 'Monthly':
        _startDate = _endDate!.subtract(const Duration(days: 30));
        break;
      case 'All Time':
        _startDate = null; // No start date limit
        break;
    }
    
    _smartClearCache();
    notifyListeners();
  }
  
  void setSelectedExerciseId(String? exerciseId) {
    _selectedExerciseId = exerciseId;
    _smartClearCache();
    notifyListeners();
  }
  
  void setSelectedMuscleGroup(String? muscleGroup) {
    _selectedMuscleGroup = muscleGroup;
    _smartClearCache();
    notifyListeners();
  }
  
  void setCustomDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    _smartClearCache();
    notifyListeners();
  }
  
  // Reset analytics state
  void resetState() {
    _selectedExerciseId = null;
    _selectedMuscleGroup = null;
    _timeFilter = 'Monthly';
    _initializeDefaultState();
    if (_smartClearCache()) {
      notifyListeners();
    }
  }

  // Analytics data getters with caching
  List<FlSpot> getExerciseProgressChartData() {
    if (_selectedExerciseId == null) return [];
    
    final data = getExerciseProgressData(_selectedExerciseId!);
    
    return data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['weight'] as double);
    }).toList();
  }
  
  List<Map<String, dynamic>> getExerciseProgressData(String exerciseId) {
    // Check cache first
    if (_isCacheValid() && 
        _exerciseDataCache != null && 
        _exerciseDataCache!.containsKey(exerciseId)) {
      return List<Map<String, dynamic>>.from(_exerciseDataCache![exerciseId]!);
    }
    
    final workouts = getFilteredWorkouts();
    final result = <Map<String, dynamic>>[];
    
    // Find workouts containing this exercise
    final workoutsWithExercise = workouts.where((w) => 
      w.exercises.any((e) => e.exerciseId == exerciseId)
    ).toList();
    
    // Sort by date
    workoutsWithExercise.sort((a, b) => a.date.compareTo(b.date));
    
    for (var workout in workoutsWithExercise) {
      final exercise = workout.exercises.firstWhere(
        (e) => e.exerciseId == exerciseId,
        orElse: () => throw Exception('Exercise not found'),
      );
      
      if (exercise.sets.isNotEmpty) {
        // Find maximum weight used in the exercise
        final maxWeightSet = exercise.sets.reduce((curr, next) => 
          curr.weight > next.weight ? curr : next
        );
        
        // Track both max weight and total volume
        double totalVolume = 0;
        for (final set in exercise.sets) {
          if (set.weight > 0 && set.reps > 0) {
            totalVolume += (set.weight * set.reps);
          }
        }
        
        result.add({
          'date': workout.date,
          'weight': maxWeightSet.weight,
          'reps': maxWeightSet.reps,
          'totalVolume': totalVolume,
          'formattedDate': DateFormat('MMM d').format(workout.date),
        });
      }
    }
    
    // Cache the results
    _exerciseDataCache ??= {};
    _exerciseDataCache![exerciseId] = result;
    _lastCacheUpdate = DateTime.now();
    
    return result;
  }
  
  // Get the most trained exercise
  Map<String, dynamic> getMostTrainedExercise() {
    // Use cache if valid
    if (_isCacheValid() && _exerciseCountCache != null) {
      final mostTrained = _findMostTrainedFromCache();
      return mostTrained;
    }

    // Calculate exercise frequencies
    final exerciseCounts = <String, Map<String, dynamic>>{};
    
    for (final workout in _workoutProvider.workouts) {
      for (final exercise in workout.exercises) {
        if (!exerciseCounts.containsKey(exercise.exerciseId)) {
          exerciseCounts[exercise.exerciseId] = {
            'name': exercise.exerciseName,
            'muscleGroup': exercise.muscleGroup,
            'count': 0,
          };
        }
        exerciseCounts[exercise.exerciseId]!['count'] = 
          (exerciseCounts[exercise.exerciseId]!['count'] as int) + 1;
      }
    }

    // Cache the counts
    _exerciseCountCache = {};
    for (final entry in exerciseCounts.entries) {
      _exerciseCountCache![entry.key] = entry.value['count'] as int;
    }
    _lastCacheUpdate = DateTime.now();

    // Find the most trained exercise
    if (exerciseCounts.isEmpty) {
      return {
        'name': 'No exercises yet',
        'muscleGroup': '',
        'count': 0,
      };
    }

    final mostTrainedId = exerciseCounts.entries
        .reduce((a, b) => (a.value['count'] as int) > (b.value['count'] as int) ? a : b)
        .key;

    return exerciseCounts[mostTrainedId]!;
  }

  Map<String, dynamic> _findMostTrainedFromCache() {
    if (_exerciseCountCache == null || _exerciseCountCache!.isEmpty) {
      return {
        'name': 'No exercises yet',
        'muscleGroup': '',
        'count': 0,
      };
    }

    final mostTrainedId = _exerciseCountCache!.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Get exercise details from the workout provider
    for (final workout in _workoutProvider.workouts) {
      for (final exercise in workout.exercises) {
        if (exercise.exerciseId == mostTrainedId) {
          return {
            'name': exercise.exerciseName,
            'muscleGroup': exercise.muscleGroup,
            'count': _exerciseCountCache![mostTrainedId],
          };
        }
      }
    }

    // This should never happen if cache is consistent
    return {
      'name': 'Error retrieving exercise',
      'muscleGroup': '',
      'count': 0,
    };
  }

  // Helper methods
  List<Workout> getFilteredWorkouts() {
    // Start with all workouts
    List<Workout> filteredWorkouts = _workoutProvider.workouts;
    
    // Apply date filter if set
    if (_startDate != null) {
      filteredWorkouts = filteredWorkouts.where((w) => 
        w.date.isAfter(_startDate!) || w.date.isAtSameMomentAs(_startDate!)
      ).toList();
    }
    
    if (_endDate != null) {
      final endOfDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
      filteredWorkouts = filteredWorkouts.where((w) => 
        w.date.isBefore(endOfDay) || w.date.isAtSameMomentAs(endOfDay)
      ).toList();
    }
    
    // Apply muscle group filter if set
    if (_selectedMuscleGroup != null) {
      filteredWorkouts = filteredWorkouts.where((w) => 
        w.exercises.any((e) => e.muscleGroup == _selectedMuscleGroup)
      ).toList();
    }
    
    return filteredWorkouts;
  }
}
