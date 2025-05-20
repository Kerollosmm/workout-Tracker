import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/user_settings.dart';
import '../models/workout.dart';
import '../services/notification_service.dart';
import 'exercise_provider.dart';
import 'analytics_provider.dart';
import '../../features/dashboard/providers/dashboard_provider.dart';

class SettingsProvider with ChangeNotifier {
  Box<UserSettings>? _settingsBox;
  UserSettings? _settings;
  final NotificationService _notificationService = NotificationService();
  final ExerciseProvider _exerciseProvider;
  final AnalyticsProvider _analyticsProvider;
  final DashboardProvider _dashboardProvider;

  SettingsProvider(
    this._exerciseProvider,
    this._analyticsProvider,
    this._dashboardProvider,
  ) {
    _init();
  }

  Future<void> _init() async {
    try {
      _settingsBox = Hive.box<UserSettings>('settings');

      if (_settingsBox != null && _settingsBox!.isEmpty) {
        // Create default settings
        _settings = UserSettings(
          language: 'en',
          weightUnit: 'kg',
          isDarkMode: false,
          notificationDays: [],
          notificationTime: '08:00',
        );
        await _settingsBox!.add(_settings!);
      } else if (_settingsBox != null) {
        _settings = _settingsBox!.getAt(0);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing SettingsProvider: $e');
      // Will try again later when needed
    }
  }

  // Get box safely with error handling
  Future<Box<UserSettings>?> _getBox() async {
    if (_settingsBox == null) {
      try {
        _settingsBox = Hive.box<UserSettings>('settings');
        if (_settingsBox != null && _settingsBox!.isEmpty) {
          // Create default settings
          _settings = UserSettings(
            language: 'en',
            weightUnit: 'kg',
            isDarkMode: false,
            notificationDays: [],
            notificationTime: '08:00',
          );
          await _settingsBox!.add(_settings!);
        } else if (_settingsBox != null) {
          _settings = _settingsBox!.getAt(0);
        }
      } catch (e) {
        debugPrint('Could not get settings box: $e');
        return null;
      }
    }
    return _settingsBox;
  }

  // Getters with null safety
  String get language => _settings?.language ?? 'en';
  String get weightUnit => _settings?.weightUnit ?? 'kg';
  bool get isDarkMode => _settings?.isDarkMode ?? false;
  List<String> get notificationDays => _settings?.notificationDays ?? [];
  String? get notificationTime => _settings?.notificationTime;

  // Setters
  Future<void> updateSettings({
    String? language,
    String? weightUnit,
    bool? isDarkMode,
    List<String>? notificationDays,
    String? notificationTime,
  }) async {
    if (_settings == null) return;

    // Update local settings
    if (language != null) _settings!.language = language;
    if (weightUnit != null) _settings!.weightUnit = weightUnit;
    if (isDarkMode != null) _settings!.isDarkMode = isDarkMode;
    if (notificationDays != null)
      _settings!.notificationDays = notificationDays;
    if (notificationTime != null)
      _settings!.notificationTime = notificationTime;

    // Save to Hive
    final box = await _getBox();
    if (box != null) {
      await box.putAt(0, _settings!);
    }

    // Update notifications if needed
    if (notificationDays != null || notificationTime != null) {
      _updateNotifications();
    }

    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    await updateSettings(language: language);
  }

  Future<void> setWeightUnit(String unit) async {
    await updateSettings(weightUnit: unit);
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    if (_settings != null) {
      _settings!.isDarkMode = isDarkMode;
      await _updateSettings();
    }
  }

  Future<void> setNotificationDays(List<String> days) async {
    if (_settings != null) {
      _settings!.notificationDays = days;
      await _updateSettings();
      _updateNotifications();
    }
  }

  Future<void> setNotificationTime(String time) async {
    if (_settings != null) {
      _settings!.notificationTime = time;
      await _updateSettings();
      _updateNotifications();
    }
  }

  Future<void> _updateSettings() async {
    if (_settingsBox != null && _settings != null) {
      await _settingsBox!.putAt(0, _settings!);
      notifyListeners();
    }
  }

  void _updateNotifications() {
    if (_settings != null) {
      if (_settings!.notificationDays.isEmpty ||
          _settings!.notificationTime == null) {
        // Cancel all notifications if disabled
        _notificationService.cancelAll();
      } else {
        // Schedule notifications for selected days
        _notificationService.scheduleWeeklyNotifications(
          days: _settings!.notificationDays,
          time: _settings!.notificationTime!,
          title: 'Time to workout!',
          body: 'Don\'t miss your workout today. Stay consistent!',
        );
      }
    }
  }

  Future<void> resetAllData() async {
    try {
      // Try to get boxes safely
      final settingsBox = await _getBox();
      Box<Workout>? workoutsBox;

      try {
        workoutsBox = Hive.box<Workout>('workouts');
      } catch (e) {
        debugPrint('Could not access workouts box for reset: $e');
      }

      // Clear workouts if box is available
      if (workoutsBox != null) {
        await workoutsBox.clear();
      }

      // Reset exercises (this will clear and reinstall defaults)
      await _exerciseProvider.resetExercises();

      // Reset analytics state
      _analyticsProvider.resetState();

      // Reset dashboard state
      _dashboardProvider.resetState();

      // Reset settings to default
      _settings = UserSettings(
        language: 'en',
        weightUnit: 'kg',
        isDarkMode: false,
        notificationDays: [],
        notificationTime: '08:00',
      );

      // Update settings box if available
      if (settingsBox != null) {
        await settingsBox.clear();
        await settingsBox.add(_settings!);
      }

      // Cancel all notifications
      await _notificationService.cancelAll();

      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting data: $e');
      rethrow;
    }
  }
}
