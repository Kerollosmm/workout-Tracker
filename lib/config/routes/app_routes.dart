import 'package:flutter/material.dart';
import '../../features/workout_log/screens/workout_log_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/custom_exercise/screens/custom_exercise_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes {
    return {
      '/workout_log': (context) => WorkoutLogScreen(),
      '/analytics': (context) => AnalyticsScreen(),
      '/history': (context) => HistoryScreen(),
      '/add_exercise': (context) => CustomExerciseScreen(),
      '/settings': (context) => SettingsScreen(),
    };
  }
}
