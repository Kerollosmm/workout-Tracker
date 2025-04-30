import 'package:flutter/material.dart';
import 'dart:async';

class RestTimer extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback? onComplete;
  const RestTimer({Key? key, this.initialSeconds = 60, this.onComplete}) : super(key: key);

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> {
  late int _secondsLeft;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.initialSeconds;
  }

  void _start() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
        if (widget.onComplete != null) widget.onComplete!();
      }
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = widget.initialSeconds;
      _isRunning = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Rest Timer', style: Theme.of(context).textTheme.titleMedium),
            Text('${_secondsLeft ~/ 60}:${(_secondsLeft % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? null : _start,
                  child: const Text('Start'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 