import 'package:flutter/foundation.dart';

enum TimerStatus { running, paused, stopped }

class RestTimerState extends ChangeNotifier {
  int _duration = 60; // Default duration in seconds
  int _remainingTime = 60;
  TimerStatus _status = TimerStatus.stopped;
  bool _soundEnabled = true;

  // Preset durations in seconds
  static const List<int> presets = [30, 60, 90, 120];

  int get duration => _duration;
  int get remainingTime => _remainingTime;
  TimerStatus get status => _status;
  bool get soundEnabled => _soundEnabled;

  void setDuration(int seconds) {
    _duration = seconds;
    _remainingTime = seconds;
    notifyListeners();
  }

  void tick() {
    if (_remainingTime > 0 && _status == TimerStatus.running) {
      _remainingTime--;
      notifyListeners();
    } else if (_remainingTime == 0) {
      _status = TimerStatus.stopped;
      notifyListeners();
    }
  }

  void start() {
    if (_status != TimerStatus.running) {
      _status = TimerStatus.running;
      notifyListeners();
    }
  }

  void pause() {
    if (_status == TimerStatus.running) {
      _status = TimerStatus.paused;
      notifyListeners();
    }
  }

  void reset() {
    _remainingTime = _duration;
    _status = TimerStatus.stopped;
    notifyListeners();
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
  }
}
