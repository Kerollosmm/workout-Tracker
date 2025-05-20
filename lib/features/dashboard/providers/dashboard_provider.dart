// lib/features/dashboard/providers/dashboard_provider.dart

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:workout_tracker/core/providers/exercise_provider.dart';
import '../../../core/providers/workout_provider.dart';

class DashboardProvider with ChangeNotifier {
  final WorkoutProvider _workoutProvider;

  // Cache
  Map<DateTime, Map<String, dynamic>> _dailyStatsCache = {};
  Map<String, dynamic>? _weeklyStatsCache;
  Map<String, dynamic>? _totalStatsCache;
  DateTime? _lastCacheUpdate;
  final _cacheTimeout = const Duration(minutes: 5);

  DashboardProvider(this._workoutProvider) {
    _workoutProvider.addListener(_handleWorkoutChanges);
  }

  void _handleWorkoutChanges() {
    _clearCache();
    notifyListeners();
  }

  void _clearCache() {
    _dailyStatsCache.clear();
    _weeklyStatsCache = null;
    _totalStatsCache = null;
    _lastCacheUpdate = null;
  }

  bool _isCacheValid() {
    return _lastCacheUpdate != null &&
        DateTime.now().difference(_lastCacheUpdate!) < _cacheTimeout;
  }

  Map<String, dynamic> getDailyStats(DateTime date) {
    final cacheKey = DateTime(date.year, date.month, date.day);

    if (_isCacheValid() && _dailyStatsCache.containsKey(cacheKey)) {
      return _dailyStatsCache[cacheKey]!;
    }

    // Calculate fresh stats using efficient list operations
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final workouts =
        _workoutProvider.workouts
            .where(
              (w) =>
                  w.date.isAfter(
                    dayStart.subtract(const Duration(seconds: 1)),
                  ) &&
                  w.date.isBefore(dayEnd),
            )
            .toList();

    final stats = workouts.fold<Map<String, dynamic>>(
      {
        'sets': 0,
        'weight': 0.0,
        'exercises': 0,
        'workout_sessions_count': 0,
      }, // Added workout_sessions_count
      (stats, workout) {
        stats['sets'] += workout.totalSets;
        stats['weight'] += workout.totalWeightLifted;
        stats['exercises'] += workout.exercises.length;
        return stats;
      },
    );
    stats['workout_sessions_count'] =
        workouts.length; // Store the count of workout sessions

    _dailyStatsCache[cacheKey] = stats;
    _lastCacheUpdate = DateTime.now();

    return stats;
  }

  List<Map<String, dynamic>> getWeeklyStats() {
    if (_isCacheValid() && _weeklyStatsCache != null) {
      return List<Map<String, dynamic>>.from(_weeklyStatsCache!['data']);
    }

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekData = List.generate(7, (index) {
      final day = weekStart.add(Duration(days: index));
      final stats = getDailyStats(day);
      return {
        'date': day,
        'day': DateFormat('E').format(day),
        'totalWeight': stats['weight'],
        'totalSets': stats['sets'],
      };
    });

    _weeklyStatsCache = {'data': weekData, 'timestamp': DateTime.now()};

    return weekData;
  }

  List<Map<String, dynamic>> getWeeklyChartData() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (index) {
      final day = weekStart.add(Duration(days: index));
      final stats = getDailyStats(day);
      return {
        'date': day,
        'sets': stats['sets'] ?? 0,
        'weight': stats['weight'] ?? 0.0,
        'exercises': stats['exercises'] ?? 0,
      };
    });
  }

  Map<String, dynamic> getTotalStats() {
    if (_isCacheValid() && _totalStatsCache != null) {
      return Map<String, dynamic>.from(_totalStatsCache!);
    }

    final stats = {
      'totalWorkouts': _workoutProvider.workouts.length,
      'totalExercises': _workoutProvider.workouts.fold<int>(
        0,
        (sum, w) => sum + w.exercises.length,
      ),
      'totalSets': _workoutProvider.workouts.fold<int>(
        0,
        (sum, w) => sum + w.totalSets,
      ),
      'totalWeight': _workoutProvider.workouts.fold<double>(
        0,
        (sum, w) => sum + w.totalWeightLifted,
      ),
    };

    _totalStatsCache = stats;
    return stats;
  }

  void resetState() {
    _clearCache();
    notifyListeners();
  }

  /// Forces a refresh of the dashboard data
  void refreshData() {
    _clearCache();
    notifyListeners();
  }

  @override
  void dispose() {
    _workoutProvider.removeListener(_handleWorkoutChanges);
    _clearCache();
    super.dispose();
  }

  Map<String, double> getActivityRingData(DateTime date) {
    final dailyStats = getDailyStats(date);

    final moveCurrent = dailyStats['weight']?.toDouble() ?? 0.0;
    final moveGoal = 500.0; // Target total weight lifted (e.g., kg)

    final exerciseCurrent =
        dailyStats['sets']?.toDouble() ??
        0.0; // Using total sets as proxy for exercise minutes (e.g., 1 set ~ 1 min active)
    final exerciseGoal = 30.0; // Target exercise units/minutes

    final standCurrent =
        (dailyStats['workout_sessions_count'] ?? 0) > 0 ? 1.0 : 0.0;
    final standGoal = 1.0; // Target: at least one workout session for the day

    return {
      'moveCurrent': moveCurrent,
      'moveGoal': moveGoal,
      'exerciseCurrent': exerciseCurrent,
      'exerciseGoal': exerciseGoal,
      'standCurrent': standCurrent,
      'standGoal': standGoal,
    };
  }
}
