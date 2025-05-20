import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';
import 'package:workout_tracker/config/constants/app_constants.dart';
import 'package:workout_tracker/core/models/workout.dart';
import 'package:workout_tracker/features/dashboard/providers/dashboard_provider.dart';
import 'config/routes/app_routes.dart';
import 'core/models/exercise.dart';
import 'core/models/workout_model.dart';
import 'core/models/workout_set.dart';
import 'core/models/user_settings.dart';
import 'core/providers/workout_provider.dart';
import 'core/providers/exercise_provider.dart';
import 'core/providers/analytics_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/models/body_data.dart';
import 'core/providers/body_data_provider.dart';

Future<void> initializeApp() async {
  // Request storage permissions
  await _requestStoragePermissions();

  // Initialize Hive
  await _initializeHive(null);

  // Initialize notification services
  await NotificationService().initNotification();
}

Future<void> _initializeHive(void _) async {
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // Register adapters
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(WorkoutSetAdapter());
  Hive.registerAdapter(WorkoutAdapter());
  Hive.registerAdapter(WorkoutExerciseAdapter());
  Hive.registerAdapter(UserSettingsAdapter());
  Hive.registerAdapter(BodyDataAdapter());

  // Open Hive boxes with error handling and retry mechanism
  try {
    await Future.wait([
      Hive.openBox<Exercise>('exercises'),
      Hive.openBox<Workout>('workouts'),
      Hive.openBox<UserSettings>('settings'),
      Hive.openBox<BodyData>('body_data'),
    ]);
  } catch (e) {
    debugPrint('Error opening Hive boxes: $e');
    // Retry once with delay - محاولة مرة أخرى بعد تأخير
    await Future.delayed(const Duration(seconds: 1));
    try {
      await Future.wait([
        Hive.openBox<Exercise>('exercises'),
        Hive.openBox<Workout>('workouts'),
        Hive.openBox<UserSettings>('settings'),
        Hive.openBox<BodyData>('body_data'),
      ]);
    } catch (e) {
      debugPrint('Failed to open Hive boxes after retry: $e');
    }
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
        NotificationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/dashboard',
          (route) => false,
        );
      });
    }
  }
}

Future<void> _requestStoragePermissions() async {
  // Request storage permissions
  Map<Permission, PermissionStatus> statuses =
      await [Permission.storage, Permission.manageExternalStorage].request();

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
  await initializeApp();

  final userProvider = UserProvider();
  await userProvider.init();

  // Create a single WorkoutProvider instance that will be initialized later
  final workoutProvider = WorkoutProvider();
  // Initialize it now if the box is already available
  try {
    await workoutProvider.initialize();
  } catch (e) {
    debugPrint('Could not initialize WorkoutProvider early: $e');
    // Will try again later when needed
  }

  final exerciseProvider = ExerciseProvider();
  final bodyDataProvider = BodyDataProvider();

  runApp(
    MultiProvider(
      providers: [
        // Use the same instance of WorkoutProvider
        ChangeNotifierProvider.value(value: workoutProvider),
        ChangeNotifierProvider.value(value: exerciseProvider),
        ChangeNotifierProvider.value(value: bodyDataProvider),
        ChangeNotifierProvider.value(value: userProvider),

        // Create DashboardProvider
        ChangeNotifierProxyProvider<WorkoutProvider, DashboardProvider>(
          create: (_) => DashboardProvider(workoutProvider),
          update: (_, workoutProvider, dashboardProvider) => dashboardProvider!,
        ),

        // Create AnalyticsProvider
        ChangeNotifierProxyProvider2<
          ExerciseProvider,
          WorkoutProvider,
          AnalyticsProvider
        >(
          create: (_) => AnalyticsProvider(workoutProvider),
          update:
              (_, exerciseProvider, workoutProvider, analyticsProvider) =>
                  analyticsProvider!,
        ),

        // Create SettingsProvider
        ChangeNotifierProxyProvider3<
          ExerciseProvider,
          AnalyticsProvider,
          DashboardProvider,
          SettingsProvider
        >(
          create: (context) {
            final analyticsProvider = Provider.of<AnalyticsProvider>(
              context,
              listen: false,
            );
            final dashboardProvider = Provider.of<DashboardProvider>(
              context,
              listen: false,
            );
            return SettingsProvider(
              exerciseProvider,
              analyticsProvider,
              dashboardProvider,
            );
          },
          update:
              (
                _,
                exerciseProvider,
                analyticsProvider,
                dashboardProvider,
                settingsProvider,
              ) => settingsProvider!,
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        return MaterialApp(
          navigatorKey: NotificationService.navigatorKey,
          title: 'Workout Tracker Pro',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          routes: AppRoutes.routes,
          debugShowCheckedModeBanner: false,
          initialRoute: '/splash',
        );
      },
    );
  }
}
