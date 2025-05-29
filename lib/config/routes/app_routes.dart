import 'package:flutter/material.dart';
import 'package:workout_tracker/core/models/workout.dart';
import 'package:workout_tracker/features/dashboard/screens/dashboard_screen.dart';
import 'package:workout_tracker/features/profile/screens/profile_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/auth/screens/offline_signin_screen.dart';
import '../../features/workout_log/screens/workout_log_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/history/screens/exercise_history_detail_screen.dart';
import '../../features/custom_exercise/screens/custom_exercise_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/custom_workout/screens/workout_editor_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes {
    return {
      '/': (context) => const SplashScreen(),
      '/splash': (context) => const SplashScreen(),
      '/signin': (context) => const OfflineSignInScreen(),
      '/workout_log': (context) => WorkoutLogScreen(),
      '/analytics': (context) => AnalyticsScreen(),
      '/history': (context) => HistoryScreen(),
      '/add_exercise': (context) => CustomExerciseScreen(),
      '/settings': (context) => SettingsScreen(),
      '/create_workout': (context) => WorkoutEditorScreen(),
      '/dashboard': (context) => const DashboardScreen(),
      '/profile': (context) => const ProfileScreen(),
      '/edit_workout': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Workout;
        return WorkoutEditorScreen(workout: args);
      },
      '/exercise_history_detail': (context) {
        final String? exerciseName = ModalRoute.of(context)?.settings.arguments as String?;
        if (exerciseName != null) {
          return ExerciseHistoryDetailScreen(exerciseName: exerciseName);
        }
        return const Scaffold(
          body: Center(child: Text('Error: Exercise name not provided.')),
        );
      },
    };
  }
}
