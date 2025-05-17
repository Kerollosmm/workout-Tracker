import 'package:flutter/material.dart';
import 'package:workout_tracker/core/models/workout.dart';
import 'package:workout_tracker/features/auth/screens/welcome_screen.dart';
import 'package:workout_tracker/features/auth/screens/personalization_screen.dart';
import 'package:workout_tracker/features/dashboard/screens/dashboard_screen.dart';
import 'package:workout_tracker/features/exercise_library/screens/exercise_library_screen.dart';
import 'package:workout_tracker/features/custom_exercise/screens/custom_exercise_screen.dart';
import 'package:workout_tracker/features/workout_log/screens/workout_log_screen.dart';
import 'package:workout_tracker/features/analytics/screens/analytics_screen.dart';
import 'package:workout_tracker/features/settings/screens/settings_screen.dart';
import 'package:workout_tracker/features/history/screens/history_screen.dart';
import 'package:workout_tracker/features/focus_mode/screens/focus_mode_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String dashboard = '/dashboard';
  static const String focusMode = '/focus-mode';
  static const String settings = '/settings';
  static const String history = '/history';

  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const WelcomeScreen(),
    dashboard: (context) => const DashboardScreen(),
    '/personalization': (context) => const PersonalizationScreen(),
    '/exercise-library': (context) => const ExerciseLibraryScreen(),
    '/custom-exercise': (context) => CustomExerciseScreen(),
    '/workout-log': (context) => WorkoutLogScreen(),
    '/analytics': (context) => const AnalyticsScreen(),
    settings: (context) => SettingsScreen(),
    history: (context) => HistoryScreen(),
    focusMode: (context) {
      final workout = ModalRoute.of(context)!.settings.arguments as Workout;
      return FocusModeScreen(workout: workout);
    },
  };
}
