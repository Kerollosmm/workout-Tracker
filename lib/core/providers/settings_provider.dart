import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/user_settings.dart';
import '../models/workout.dart';
import '../services/notification_service.dart';
import 'exercise_provider.dart';
import 'analytics_provider.dart';
import '../../features/dashboard/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';

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
      _settingsBox = await Hive.openBox<UserSettings>('settings');
      
      if (_settingsBox == null || _settingsBox!.isEmpty) {
        // Create default settings
        _settings = UserSettings(
          language: 'en',
          weightUnit: 'kg',
          isDarkMode: false,
          notificationDays: [],
          notificationTime: '08:00',
          dateOfBirth: null,
          sex: '',
          height: '',
          weight: 0.0,
        );
        if (_settingsBox != null) {
          await _settingsBox!.add(_settings!);
        }
      } else {
        _settings = _settingsBox!.getAt(0);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing settings: $e');
      // Provide default settings in case of error
      _settings = UserSettings(
        language: 'en',
        weightUnit: 'kg',
        isDarkMode: false,
        notificationDays: [],
        notificationTime: '08:00',
        dateOfBirth: null,
        sex: '',
        height: '',
        weight: 0.0,
      );
    }
  }
  
  // Getters with null safety
  String get language => _settings?.language ?? 'en';
  String get weightUnit => _settings?.weightUnit ?? 'kg';
  bool get isDarkMode => _settings?.isDarkMode ?? false;
  List<String> get notificationDays => _settings?.notificationDays ?? [];
  String? get notificationTime => _settings?.notificationTime;
  DateTime? get dateOfBirth => _settings?.dateOfBirth;
  String get sex => _settings?.sex ?? '';
  String get height => _settings?.height ?? '';
  double get weight => _settings?.weight ?? 0.0;
  bool get isMetric => _settings?.isMetric ?? false;
  
  // Setters
  Future<void> setLanguage(String language) async {
    if (_settings != null) {
      _settings!.language = language;
      await _updateSettings();
    }
  }
  
  Future<void> setWeightUnit(String unit) async {
    if (_settings != null) {
      _settings!.weightUnit = unit;
      await _updateSettings();
    }
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
      if (_settings!.notificationDays.isEmpty || _settings!.notificationTime == null) {
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
      // Clear all Hive boxes
      final workoutsBox = Hive.box<Workout>('workouts');
      await workoutsBox.clear();
      
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
      
      await _settingsBox?.clear();
      await _settingsBox?.add(_settings!);
      
      // Cancel all notifications
      await _notificationService.cancelAll();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting data: $e');
      rethrow;
    }
  }

  void toggleTheme() {
    if (_settings != null) {
      _settings!.isDarkMode = !_settings!.isDarkMode;
      _updateSettings();
    }
  }

  void toggleMetricSystem() {
    if (_settings != null) {
      _settings!.isMetric = !_settings!.isMetric;
      _updateSettings();
    }
  }

  void updateUserProfile({
    DateTime? dateOfBirth,
    String? sex,
    String? height,
    double? weight,
  }) {
    if (dateOfBirth != null) _settings!.dateOfBirth = dateOfBirth;
    if (sex != null) _settings!.sex = sex;
    if (height != null) _settings!.height = height;
    if (weight != null) _settings!.weight = weight;
    _updateSettings();
  }
}
