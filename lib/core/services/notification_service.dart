import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  // Global navigator key to handle navigation from notifications
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Initialize notification plugin with proper settings
  Future<void> initNotification() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    // Use a custom icon for notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // Enhanced iOS settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          defaultPresentAlert: true,
          defaultPresentBadge: true,
          defaultPresentSound: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // Set up notification click handling with better error handling
    await _notificationsPlugin
        .initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: _onNotificationTapped,
        )
        .catchError((error) {
          debugPrint('Error initializing notifications: $error');
          return false;
        });

    await _createNotificationChannel();
    _initialized = true;

    // Request notification permissions explicitly
    await _requestPermissions();
  }

  // Handle notification tap with enhanced logging
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped with payload: ${response.payload}');

    try {
      if (response.payload == 'dashboard') {
        // Use a post frame callback to ensure the navigator is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/dashboard',
            (route) => false,
          );
        });
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  // Request notification permissions with better error handling
  Future<void> _requestPermissions() async {
    try {
      // For Android
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }

      // For iOS
      final IOSFlutterLocalNotificationsPlugin? iOSImplementation =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();

      if (iOSImplementation != null) {
        await iOSImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
          critical: true,
        );
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  // Create enhanced notification channel with better visuals
  Future<void> _createNotificationChannel() async {
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'workout_reminder_channel',
        'Workout Reminders',
        description: 'Channel for workout reminder notifications',
        importance: Importance.max,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        ledColor: Color(0xFF6200EE),
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    } catch (e) {
      debugPrint('Error creating notification channel: $e');
    }
  }

  // Show visually enhanced test notification
  Future<void> showTestNotification() async {
    await initNotification();

    const AndroidNotificationDetails
    androidDetails = AndroidNotificationDetails(
      'workout_reminder_channel',
      'Workout Reminders',
      channelDescription: 'Channel for workout reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      styleInformation: BigTextStyleInformation(
        'Time to start your workout! Tap to open the app and begin your session.',
        htmlFormatBigText: true,
        contentTitle: '<b>Workout Time!</b>',
        htmlFormatContentTitle: true,
        summaryText: 'Tap to start',
        htmlFormatSummaryText: true,
      ),
      color: Color(0xFF6200EE),
      colorized: true,
      category: AndroidNotificationCategory.reminder,
      fullScreenIntent: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_sound.aiff',
        interruptionLevel: InterruptionLevel.timeSensitive,
        categoryIdentifier: 'workout',
      ),
    );

    await _notificationsPlugin.show(
      0,
      'Workout Time!',
      'Time to start your workout! Tap to open the app and begin your session.',
      notificationDetails,
      payload: 'dashboard',
    );
  }

  // Schedule weekly notifications with enhanced visual styling
  Future<void> scheduleWeeklyNotifications({
    required List<String> days,
    required String time,
    String title = 'Workout Time!',
    String body =
        'Time to start your workout! Tap to open the app and begin your session.',
  }) async {
    await initNotification();

    final dayMapping = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
    };

    try {
      await cancelAll();

      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      for (final day in days) {
        final dayOfWeek = dayMapping[day];
        if (dayOfWeek != null) {
          await _scheduleWeeklyNotification(
            id: dayOfWeek,
            dayOfWeek: dayOfWeek,
            hour: hour,
            minute: minute,
            title: title,
            body: body,
          );
        }
      }
    } catch (e) {
      debugPrint('Notification scheduling error: $e');
      rethrow;
    }
  }

  // Schedule a single weekly notification with enhanced details
  Future<void> _scheduleWeeklyNotification({
    required int id,
    required int dayOfWeek,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    // Updated 2025-05-29: Use custom sound 'notification_sound_trimmed'
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'workout_reminder_channel',
          'Workout Reminders',
          channelDescription: 'Channel for workout reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
          sound: const RawResourceAndroidNotificationSound('notification_sound_trimmed'), // Added custom sound for Android
          playSound: true,
          styleInformation: BigTextStyleInformation(
            body,
            htmlFormatBigText: true,
            contentTitle: '<b>$title</b>',
            htmlFormatContentTitle: true,
            summaryText: 'Your fitness journey continues',
            htmlFormatSummaryText: true,
          ),
          color: const Color(0xFF6200EE),
          colorized: true,
          category: AndroidNotificationCategory.reminder,
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_sound_trimmed.aiff', // Updated custom sound for iOS
        interruptionLevel: InterruptionLevel.timeSensitive,
        categoryIdentifier: 'workout',
      ),
    );

    // Updated 2025-05-29: Added logging for scheduling
    final tz.TZDateTime scheduledTime = _nextInstanceOfDayTime(dayOfWeek, hour, minute);
    debugPrint('[NotificationService] Attempting to schedule notification ID $id for $scheduledTime with title "$title"');

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'dashboard',
      );
      debugPrint('[NotificationService] Successfully scheduled notification ID $id for $scheduledTime');
    } catch (e) {
      debugPrint('[NotificationService] ERROR scheduling notification ID $id for $scheduledTime: $e');
      rethrow; // Rethrow to allow calling code to handle if needed
    }
  }

  // Calculate the next occurrence of a specific day and time
  tz.TZDateTime _nextInstanceOfDayTime(int dayOfWeek, int hour, int minute) {
    // Updated 2025-05-29: Added detailed logging
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    debugPrint('[NotificationService] _nextInstanceOfDayTime: Now: $now, Initial scheduledDate for day $dayOfWeek ($hour:$minute): $scheduledDate');

    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    debugPrint('[NotificationService] _nextInstanceOfDayTime: Adjusted scheduledDate for weekday match: $scheduledDate');

    final finalScheduledDate = scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 7))
        : scheduledDate;
    debugPrint('[NotificationService] _nextInstanceOfDayTime: Final scheduledDate for day $dayOfWeek, $hour:$minute is: $finalScheduledDate');
    return finalScheduledDate;
  }

  // Cancel all notifications
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
