import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/themes/app_theme.dart';

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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color currentTextColor = isDarkMode ? AppTheme.primaryTextColor : Colors.black87;
    final Color currentSecondaryTextColor = isDarkMode ? AppTheme.secondaryTextColor : Colors.black54;
    final Color currentBorderColor = isDarkMode ? AppTheme.primaryTextColor.withOpacity(0.2) : Colors.grey.shade400;
    final Color currentCardBgColor = isDarkMode ? AppTheme.cardColor : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacing_s),
      padding: const EdgeInsets.all(AppTheme.spacing_l),
      decoration: BoxDecoration(
        color: currentCardBgColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius_l),
      ),
      child: Column(
        children: [
          if (!_isEditing)
            Text(
              _formatTime(_currentSeconds),
              style: TextStyle(
                color: currentTextColor,
                fontSize: 56,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing_xl),
              child: TextField(
                controller: _timeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  color: currentTextColor,
                  fontSize: 32,
                ),
                decoration: InputDecoration(
                  labelText: 'Minutes',
                  labelStyle: TextStyle(color: currentSecondaryTextColor),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: currentBorderColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.exerciseRingColor, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: AppTheme.spacing_s),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: AppTheme.spacing_xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCircularButton(
                icon: _isRunning ? Icons.pause : Icons.play_arrow,
                onPressed: _isRunning ? _stopTimer : _startTimer,
                color: AppTheme.exerciseRingColor,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(width: AppTheme.spacing_xl),
              _buildCircularButton(
                icon: Icons.refresh,
                onPressed: _resetTimer,
                color: isDarkMode ? AppTheme.secondaryTextColor.withOpacity(0.8) : Colors.grey.shade600,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(width: AppTheme.spacing_xl),
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
                color: isDarkMode ? AppTheme.secondaryTextColor.withOpacity(0.8) : Colors.grey.shade600,
                isDarkMode: isDarkMode,
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
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(isDarkMode ? 0.25 : 0.15),
      ),
      child: IconButton(
        icon: Icon(icon, color: color), // Icon color matches base color
        onPressed: onPressed,
        iconSize: AppTheme.iconSize_m, // Use AppTheme.iconSize_m
        padding: const EdgeInsets.all(AppTheme.spacing_m), // Use AppTheme padding
        splashRadius: AppTheme.iconSize_m + AppTheme.spacing_s, // Adjust splash radius
      ),
    );
  }
}