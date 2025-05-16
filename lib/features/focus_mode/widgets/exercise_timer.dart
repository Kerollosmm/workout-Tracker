import 'dart:async';
import 'package:flutter/material.dart';

class ExerciseTimer extends StatefulWidget {
  final int duration;
  final VoidCallback onComplete;

  const ExerciseTimer({
    Key? key,
    required this.duration,
    required this.onComplete,
  }) : super(key: key);

  @override
  _ExerciseTimerState createState() => _ExerciseTimerState();
}

class _ExerciseTimerState extends State<ExerciseTimer> {
  late Timer _timer;
  late int _remainingTime;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_remainingTime <= 0) {
          _timer.cancel();
          widget.onComplete();
        } else {
          setState(() => _remainingTime--);
        }
      },
    );
  }

  void _pauseTimer() {
    _timer.cancel();
    setState(() => _isRunning = false);
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    if (_isRunning) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 8,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatTime(_remainingTime),
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 10),
          IconButton(
            icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
            onPressed: _isRunning ? _pauseTimer : _startTimer,
            iconSize: 32,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
} 