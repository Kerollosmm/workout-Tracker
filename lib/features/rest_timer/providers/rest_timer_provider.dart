import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/rest_timer_state.dart';

class RestTimerProvider extends ChangeNotifier {
  final RestTimerState _timerState = RestTimerState();
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  RestTimerProvider();

  RestTimerState get timerState => _timerState;

  void setDuration(int seconds) {
    _timerState.setDuration(seconds);
    notifyListeners();
  }

  void startTimer() {
    _timerState.start();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timerState.tick();
      if (_timerState.remainingTime == 0) {
        timer.cancel();
        if (_timerState.soundEnabled) {
          _playNotificationSound();
        }
      }
    });
    notifyListeners();
  }

  void pauseTimer() {
    _timerState.pause();
    _timer?.cancel();
    notifyListeners();
  }

  void resetTimer() {
    _timerState.reset();
    _timer?.cancel();
    notifyListeners();
  }

  void toggleSound() {
    _timerState.toggleSound();
    notifyListeners();
  }

  Future<void> _playNotificationSound() async {
    await _audioPlayer.play(AssetSource('sounds/timer_complete.mp3'));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
