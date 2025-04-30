import 'package:flutter/foundation.dart';

class AnalyticsProvider extends ChangeNotifier {
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  T? _getCachedValue<T>(String key, {Duration maxAge = const Duration(minutes: 5)}) {
    if (!_cache.containsKey(key)) return null;
    final timestamp = _cacheTimestamps[key]!;
    if (DateTime.now().difference(timestamp) > maxAge) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }
    return _cache[key] as T;
  }

  void _cacheValue<T>(String key, T value) {
    _cache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
  }

  bool _smartClearCache([String? affectedKey]) {
    if (affectedKey == null) {
      if (_cache.isEmpty) return false;
      _cache.clear();
      _cacheTimestamps.clear();
      return true;
    }
    return _cache.remove(affectedKey) != null
        ? _cacheTimestamps.remove(affectedKey) != null
        : false;
  }

  // Example usage in a method:
  Map<String, dynamic> getExerciseProgress(String exerciseId) {
    final cacheKey = 'exercise_progress_$exerciseId';
    final cachedValue = _getCachedValue<Map<String, dynamic>>(cacheKey);
    if (cachedValue != null) return cachedValue;

    // Calculate the actual value
    final value = _calculateExerciseProgress(exerciseId);
    _cacheValue(cacheKey, value);
    return value;
  }

  Map<String, dynamic> _calculateExerciseProgress(String exerciseId) {
    // Implementation here
    return {};
  }

  void updateExerciseProgress(String exerciseId) {
    final cleared = _smartClearCache('exercise_progress_$exerciseId');
    if (cleared) {
      notifyListeners();
    }
  }
}
