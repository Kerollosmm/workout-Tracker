import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditableRestTimer extends StatefulWidget {
  final int initialSeconds;
  final Function(int)? onTimeChanged;

  const EditableRestTimer({
    Key? key,
    required this.initialSeconds,
    this.onTimeChanged,
  }) : super(key: key);

  @override
  State<EditableRestTimer> createState() => _EditableRestTimerState();
}

class _EditableRestTimerState extends State<EditableRestTimer> {
  late Timer? _timer;
  late int _currentSeconds;
  bool _isRunning = false;
  bool _isEditing = false;
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.initialSeconds;
    _timeController.text = (_currentSeconds ~/ 60).toString();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSeconds > 0) {
        setState(() {
          _currentSeconds--;
        });
      } else {
        _stopTimer();
        _onTimerComplete();
      }
    });
    setState(() {
      _isRunning = true;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _currentSeconds = widget.initialSeconds;
    });
  }

  void _onTimerComplete() {
    HapticFeedback.heavyImpact(); // Vibrate when timer completes
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString()}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _updateTime(String value) {
    final minutes = int.tryParse(value) ?? 0;
    final newSeconds = minutes * 60;
    setState(() {
      _currentSeconds = newSeconds;
    });
    widget.onTimeChanged?.call(newSeconds);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (!_isEditing)
            Text(
              _formatTime(_currentSeconds),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
              ),
            )
          else
            TextField(
              controller: _timeController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
              ),
              decoration: const InputDecoration(
                labelText: 'Minutes',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCircularButton(
                icon: _isRunning ? Icons.pause : Icons.play_arrow,
                onPressed: _isRunning ? _stopTimer : _startTimer,
                color: Colors.blue,
              ),
              const SizedBox(width: 24),
              _buildCircularButton(
                icon: Icons.refresh,
                onPressed: _resetTimer,
                color: Colors.grey,
              ),
              const SizedBox(width: 24),
              _buildCircularButton(
                icon: _isEditing ? Icons.check : Icons.edit,
                onPressed: () {
                  setState(() {
                    if (_isEditing) {
                      _updateTime(_timeController.text);
                    }
                    _isEditing = !_isEditing;
                  });
                },
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        iconSize: 28,
        padding: const EdgeInsets.all(12),
      ),
    );
  }
} 