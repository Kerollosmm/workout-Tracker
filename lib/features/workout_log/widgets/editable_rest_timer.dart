import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/themes/app_theme.dart'; // Import AppTheme

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
    // Initialize with minutes:seconds if needed, or just minutes for editing
    _timeController.text = (_currentSeconds ~/ 60).toString();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_currentSeconds <= 0) return; // Don't start if time is zero
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
      _isEditing = false; // Exit editing mode when timer starts
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
      // Reset to the original initialSeconds passed to the widget,
      // or to the last successfully set time if it was edited.
      // For now, let's assume widget.initialSeconds is the true reset point,
      // or manage an internal 'configuredSeconds' state.
      _currentSeconds = widget.initialSeconds;
      _timeController.text = (_currentSeconds ~/ 60).toString();
      _isEditing = false; // Exit editing mode
    });
  }

  void _onTimerComplete() {
    HapticFeedback.heavyImpact();
    // Optionally, reset or perform other actions
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _saveEditedTime() {
    final minutes = int.tryParse(_timeController.text) ?? (_currentSeconds ~/ 60);
    final newSeconds = minutes * 60;
    if (newSeconds >= 0) { // Ensure non-negative time
      setState(() {
        _currentSeconds = newSeconds;
        _isEditing = false;
        if (_isRunning) { // If timer was running, stop it and restart with new time
          _stopTimer();
          // Optionally auto-start: _startTimer();
        }
      });
      widget.onTimeChanged?.call(newSeconds);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using AppTheme constants directly
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacing_xs), // Reduced vertical margin
      padding: const EdgeInsets.all(AppTheme.spacing_m),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor, // Use surfaceColor to stand out slightly if nested in cardColor
        borderRadius: BorderRadius.circular(AppTheme.borderRadius_m), // Consistent border radius
      ),
      child: Column(
        children: [
          if (!_isEditing)
            Text(
              _formatTime(_currentSeconds),
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: 48, // Large, prominent timer text
                fontWeight: FontWeight.w300, // Light weight for modern feel
                fontFeatures: [FontFeature.tabularFigures()], // Ensures numbers align well
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing_m),
              child: TextField(
                controller: _timeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofocus: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: AppTheme.darkTheme.textTheme.headlineMedium?.fontSize ?? 24, // Slightly smaller for editing
                ),
                decoration: InputDecoration(
                  labelText: 'Set Minutes',
                  labelStyle: TextStyle(color: AppTheme.secondaryTextColor, fontSize: AppTheme.darkTheme.textTheme.bodySmall?.fontSize),
                  // Using filled style from AppTheme's inputDecorationTheme implicitly
                  filled: true,
                  fillColor: AppTheme.cardColor, // Darker background for input field
                  contentPadding: EdgeInsets.symmetric(vertical: AppTheme.spacing_s, horizontal: AppTheme.spacing_m),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
                    borderSide: BorderSide(color: AppTheme.exerciseRingColor, width: 1.5),
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppTheme.spacing_m), // Consistent spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute buttons evenly
            children: [
              _buildCircularButton(
                context: context,
                icon: _isEditing ? Icons.save_alt_outlined : (_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                onPressed: () {
                  if (_isEditing) {
                    _saveEditedTime();
                  } else {
                    _isRunning ? _stopTimer() : _startTimer();
                  }
                },
                // Use accent color for primary action (play/pause/save)
                color: AppTheme.exerciseRingColor,
              ),
              if (!_isEditing) // Show Reset and Edit only when not editing
                _buildCircularButton(
                  context: context,
                  icon: Icons.replay_rounded,
                  onPressed: _resetTimer,
                  color: AppTheme.secondaryTextColor.withOpacity(0.8),
                ),
              _buildCircularButton(
                context: context,
                icon: _isEditing ? Icons.cancel_outlined : Icons.edit_rounded,
                onPressed: () {
                  setState(() {
                    if (_isEditing) { // Cancel editing
                      _timeController.text = (_currentSeconds ~/ 60).toString(); // Reset controller text
                      _isEditing = false;
                    } else { // Start editing
                      _isEditing = true;
                      if(_isRunning) _stopTimer(); // Stop timer if running when editing starts
                    }
                  });
                },
                color: AppTheme.secondaryTextColor.withOpacity(0.8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15), // Consistent background opacity
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        iconSize: AppTheme.iconSize_m,
        padding: const EdgeInsets.all(AppTheme.spacing_s + AppTheme.spacing_xs), // 12dp padding, makes button ~48dp
        splashRadius: AppTheme.iconSize_l, // Appropriate splash radius
        tooltip: icon == Icons.play_arrow_rounded ? "Start Timer" :
                 icon == Icons.pause_rounded ? "Pause Timer" :
                 icon == Icons.replay_rounded ? "Reset Timer" :
                 icon == Icons.edit_rounded ? "Edit Time" :
                 icon == Icons.save_alt_outlined ? "Save Time" :
                 icon == Icons.cancel_outlined ? "Cancel Edit" : null,
      ),
    );
  }
}