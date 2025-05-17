import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:workout_tracker/features/focus_mode/models/focus_session.dart';
import 'package:workout_tracker/core/models/workout.dart';
import 'package:uuid/uuid.dart';

class FocusModeProvider with ChangeNotifier {
  final Box<FocusSession> _focusSessionBox;
  FocusSession? _currentSession;
  Timer? _focusTimer;
  Timer? _restTimer;
  bool _isInFocusMode = false;
  int _currentExerciseIndex = 0;
  final double _focusBrightness = 0.5;
  final int _defaultRestDuration = 90;
  final _screenBrightness = ScreenBrightness();

  // Getters
  bool get isInFocusMode => _isInFocusMode;
  FocusSession? get currentSession => _currentSession;
  int get currentExerciseIndex => _currentExerciseIndex;
  
  FocusModeProvider(this._focusSessionBox);

  Future<void> startFocusSession(Workout workout) async {
    if (_isInFocusMode) return;

    try {
      // Create new focus session
      final session = FocusSession(
        id: const Uuid().v4(),
        workoutId: workout.id,
        startTime: DateTime.now(),
      );

      // Save to Hive
      await _focusSessionBox.put(session.id, session);
      
      // Set current session
      _currentSession = session;
      
      // Initialize focus mode
      await _initializeFocusMode();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error starting focus session: $e');
      throw Exception('Failed to start focus session');
    }
  }

  Future<void> _initializeFocusMode() async {
    try {
      // Set screen brightness
      await _screenBrightness.setScreenBrightness(_focusBrightness);
      
      _isInFocusMode = true;
      _startFocusTimer();
    } catch (e) {
      debugPrint('Error initializing focus mode: $e');
      throw Exception('Failed to initialize focus mode');
    }
  }

  void _startFocusTimer() {
    _focusTimer?.cancel();
    _focusTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_currentSession != null) {
          _currentSession!.totalFocusTime++;
          notifyListeners();
        }
      },
    );
  }

  Future<void> endFocusSession() async {
    if (!_isInFocusMode || _currentSession == null) return;

    try {
      // Update session end time
      _currentSession!.endTime = DateTime.now();
      
      // Save to Hive
      await _focusSessionBox.put(_currentSession!.id, _currentSession!);
      
      // Reset focus mode
      await _resetFocusMode();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error ending focus session: $e');
      throw Exception('Failed to end focus session');
    }
  }

  Future<void> _resetFocusMode() async {
    _focusTimer?.cancel();
    _restTimer?.cancel();
    _isInFocusMode = false;
    _currentExerciseIndex = 0;
    _currentSession = null;
    
    // Reset screen brightness
    try {
      await _screenBrightness.resetScreenBrightness();
    } catch (e) {
      debugPrint('Error resetting screen brightness: $e');
    }
  }

  void nextExercise() {
    _currentExerciseIndex++;
    notifyListeners();
  }

  void startRestTimer(VoidCallback onComplete) {
    _restTimer?.cancel();
    int remainingTime = _defaultRestDuration;
    
    _restTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (remainingTime <= 0) {
          timer.cancel();
          onComplete();
        } else {
          remainingTime--;
          notifyListeners();
        }
      },
    );
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }
} 