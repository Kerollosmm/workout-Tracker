import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';
import 'package:workout_tracker/config/constants/app_constants.dart';
import 'package:workout_tracker/features/dashboard/providers/dashboard_provider.dart';
import 'package:workout_tracker/features/focus_mode/models/focus_session.dart';
import 'package:workout_tracker/features/focus_mode/providers/focus_mode_provider.dart';
import 'config/routes/app_routes.dart';
import 'config/themes/app_theme.dart';
import 'core/models/exercise.dart';
import 'core/models/workout.dart';
import 'core/models/workout_set.dart';
import 'core/models/user_settings.dart';
import 'core/providers/workout_provider.dart';
import 'core/providers/exercise_provider.dart';
import 'core/providers/analytics_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/services/notification_service.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/models/body_data.dart';
import 'core/providers/body_data_provider.dart';

Future<void> initializeApp() async {
  // Request storage permissions
  await _requestStoragePermissions();

  // Initialize Hive
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // Register adapters
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(WorkoutSetAdapter());
  Hive.registerAdapter(WorkoutAdapter());
  Hive.registerAdapter(WorkoutExerciseAdapter());
  Hive.registerAdapter(UserSettingsAdapter());
  Hive.registerAdapter(BodyDataAdapter());
  Hive.registerAdapter(FocusSessionAdapter());

  // Open Hive boxes with error handling
  try {
    await Hive.openBox<Exercise>('exercises');
    await Hive.openBox<Workout>('workouts');
    await Hive.openBox<UserSettings>('settings');
    await Hive.openBox<BodyData>('body_data');
    await Hive.openBox<FocusSession>('focus_sessions');
  } catch (e) {
    debugPrint('Error opening Hive boxes: $e');
    // Handle the error appropriately
  }

  // Initialize notification services
  await NotificationService().initNotification();

  // Set up background/terminated state notification handling
  final NotificationAppLaunchDetails? launchDetails =
      await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();
  if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
    // App was launched from a notification
    debugPrint(
      'App launched from notification: ${launchDetails.notificationResponse?.payload}',
    );
    // Handle navigation if payload is 'dashboard'
    if (launchDetails.notificationResponse?.payload == 'dashboard') {
      // Use a WidgetsBinding callback to ensure context is available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationService.navigatorKey.currentState
            ?.pushNamedAndRemoveUntil('/dashboard', (route) => false);
      });
    }
  }
}

Future<void> _requestStoragePermissions() async {
  // Request storage permissions
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
    Permission.manageExternalStorage,
  ].request();

  // Check if permissions are granted
  bool allGranted = true;
  statuses.forEach((permission, status) {
    if (!status.isGranted) {
      allGranted = false;
      debugPrint('Permission $permission not granted: $status');
    }
  });

  if (!allGranted) {
    // Handle case where permissions are not granted
    debugPrint('Storage permissions not granted');
    // You might want to show a dialog to the user here
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<void> _initialization = initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => WorkoutProvider(Hive.box<Workout>('workouts')),
              ),
              ChangeNotifierProvider(create: (_) => ExerciseProvider()),
              ChangeNotifierProvider(
                create: (context) => AnalyticsProvider(
                  Provider.of<WorkoutProvider>(context, listen: false),
                ),
              ),
              ChangeNotifierProvider(
                create: (context) => DashboardProvider(
                  Provider.of<WorkoutProvider>(context, listen: false),
                ),
              ),
              ChangeNotifierProvider(
                create: (context) => SettingsProvider(
                  Provider.of<ExerciseProvider>(context, listen: false),
                  Provider.of<AnalyticsProvider>(context, listen: false),
                  Provider.of<DashboardProvider>(context, listen: false),
                ),
              ),
              ChangeNotifierProvider(
                create: (_) => BodyDataProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => FocusModeProvider(
                  Hive.box<FocusSession>('focus_sessions'),
                ),
              ),
            ],
            child: Consumer<SettingsProvider>(
              builder: (context, settingsProvider, _) {
                return MaterialApp(
                  navigatorKey: NotificationService.navigatorKey,
                  title: 'Workout Tracker Pro',
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: settingsProvider.isDarkMode
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  routes: AppRoutes.routes,
                  debugShowCheckedModeBanner: false,
                  initialRoute:
                      settingsProvider.dateOfBirth == null ? '/' : '/dashboard',
                );
              },
            ),
          );
        }

        // Show splash screen while initializing
        return MaterialApp(
          title: 'Workout Tracker Pro',
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
