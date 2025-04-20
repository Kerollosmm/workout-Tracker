// lib/features/dashboard/providers/dashboard_provider.dart

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../core/providers/exercise_provider.dart';
import '../../../core/models/workout.dart';

class DashboardProvider with ChangeNotifier {
  final WorkoutProvider _workoutProvider;
  final ExerciseProvider _exerciseProvider;
  
  DashboardProvider(this._workoutProvider, this._exerciseProvider) {
    // Enhanced listener setup for more granular updates
    _workoutProvider.addListener(_handleWorkoutChanges);
    _exerciseProvider.addListener(() {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _workoutProvider.removeListener(_handleWorkoutChanges);
    super.dispose();
  }

  void _handleWorkoutChanges() {
    // Force recalculation of all stats when workouts change
    _clearCache();
    notifyListeners();
  }

  // Reset all dashboard state and cache
  void resetState() {
    _clearCache();
    notifyListeners();
  }

  // Cache management
  Map<DateTime, Map<String, dynamic>> _dailyStatsCache = {};
  Map<String, dynamic>? _weeklyStatsCache;
  DateTime? _lastCacheUpdate;

  void _clearCache() {
    _dailyStatsCache.clear();
    _weeklyStatsCache = null;
    _lastCacheUpdate = null;
  }

  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    final now = DateTime.now();
    return now.difference(_lastCacheUpdate!).inMinutes < 5; // Cache valid for 5 minutes
  }

  // Get today's date with time set to start of day
  DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  
  // Get today's progress with improved caching
  int get todayTotalSets {
    final stats = _getDailyStats(today);
    return stats['sets'] as int;
  }
  
  double get todayTotalWeight {
    final stats = _getDailyStats(today);
    return stats['weight'] as double;
  }
  
  Map<String, dynamic> _getDailyStats(DateTime date) {
    final cacheKey = DateTime(date.year, date.month, date.day);
    
    // Return cached value if valid
    if (_isCacheValid() && _dailyStatsCache.containsKey(cacheKey)) {
      return _dailyStatsCache[cacheKey]!;
    }
    
    // Calculate fresh stats
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(Duration(days: 1));
    
    final workouts = _workoutProvider.workouts.where((w) =>
      w.date.isAfter(dayStart.subtract(Duration(seconds: 1))) &&
      w.date.isBefore(dayEnd)
    ).toList();
    
    int totalSets = 0;
    double totalWeight = 0.0;
    
    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        totalSets += exercise.sets.where((set) => 
          set.weight > 0 && set.reps > 0
        ).length;
        
        for (final set in exercise.sets) {
          if (set.weight > 0 && set.reps > 0) {
            totalWeight += set.weight * set.reps;
          }
        }
      }
    }
    
    // Cache the results
    _dailyStatsCache[cacheKey] = {
      'sets': totalSets,
      'weight': totalWeight,
    };
    
    _lastCacheUpdate = DateTime.now();
    
    return _dailyStatsCache[cacheKey]!;
  }

  // Enhanced weekly data calculation with caching
  List<Map<String, dynamic>> getWeeklyChartData() {
    if (_isCacheValid() && _weeklyStatsCache != null) {
      return List<Map<String, dynamic>>.from(_weeklyStatsCache!['data']);
    }
    
    final weekData = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    // Calculate the start of the week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    // Generate data for each day of the week
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final stats = _getDailyStats(day);
      
      weekData.add({
        'date': day,
        'day': DateFormat('E').format(day),
        'totalWeight': stats['weight'],
        'totalSets': stats['sets'],
      });
    }
    
    // Cache the results
    _weeklyStatsCache = {
      'data': weekData,
      'timestamp': DateTime.now(),
    };
    
    return weekData;
  }
  
  // Get recent workouts (limited to 3)
  List<Workout> get recentWorkouts {
    final workouts = _workoutProvider.workouts;
    
    if (workouts.isEmpty) {
      return [];
    }
    
    // Return the 3 most recent workouts
    return workouts.take(3).toList();
  }
  
  // Get most recent workout exercise
  Map<String, dynamic> getMostRecentExercise() {
    final workouts = _workoutProvider.workouts;
    
    if (workouts.isEmpty || workouts.first.exercises.isEmpty) {
      return {
        'name': 'No exercise yet',
        'muscleGroup': '',
        'date': DateTime.now(),
      };
    }
    
    final latestWorkout = workouts.first;
    final latestExercise = latestWorkout.exercises.first;
    
    return {
      'name': latestExercise.exerciseName,
      'muscleGroup': latestExercise.muscleGroup,
      'date': latestWorkout.date,
    };
  }
  
  // Get total workout stats
  Map<String, dynamic> getTotalStats() {
    return {
      'totalWorkouts': _workoutProvider.workouts.length,
      'totalExercises': _getTotalExercisesPerformed(),
      'totalSets': _workoutProvider.getTotalSets(null),
      'totalWeight': _workoutProvider.getTotalWeightLifted(null),
    };
  }
  
  // Calculate total number of exercises performed across all workouts
  int _getTotalExercisesPerformed() {
    int total = 0;
    for (final workout in _workoutProvider.workouts) {
      total += workout.exercises.length;
    }
    return total;
  }
}
