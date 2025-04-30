import 'package:flutter/material.dart';
import 'package:workout_tracker/features/dashboard/screens/dashboard_screen.dart';
import '../../features/workout_log/screens/workout_log_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/custom_exercise/screens/custom_exercise_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/custom_workout/screens/workout_editor_screen.dart';
import '../../core/models/workout.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes {
    return {
      '/workout_log': (context) => WorkoutLogScreen(),
      '/analytics': (context) => AnalyticsScreen(),
      '/history': (context) => HistoryScreen(),
      '/add_exercise': (context) => CustomExerciseScreen(),
      '/settings': (context) => SettingsScreen(),
      '/create_workout': (context) => const WorkoutEditorScreen(),
      '/dashboard': (context) => const DashboardScreen(),
      '/edit_workout': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Workout;
        return WorkoutEditorScreen(workout: args);
      },
    };
  }
}
