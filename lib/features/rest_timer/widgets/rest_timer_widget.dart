import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/features/rest_timer/models/rest_timer_state.dart';
import '../providers/rest_timer_provider.dart';
import '../../../config/themes/app_theme.dart';

class RestTimerWidget extends StatelessWidget {
  const RestTimerWidget({Key? key}) : super(key: key);

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RestTimerProvider>(
      builder: (context, provider, child) {
        final timerState = provider.timerState;

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(timerState.remainingTime),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPresetButton(context, provider, 30, '30s'),
                  _buildPresetButton(context, provider, 60, '1m'),
                  _buildPresetButton(context, provider, 90, '1.5m'),
                  _buildPresetButton(context, provider, 120, '2m'),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    context,
                    icon: Icons.refresh,
                    onPressed: provider.resetTimer,
                  ),
                  _buildControlButton(
                    context,
                    icon:
                        timerState.status == TimerStatus.running
                            ? Icons.pause
                            : Icons.play_arrow,
                    onPressed: () {
                      if (timerState.status == TimerStatus.running) {
                        provider.pauseTimer();
                      } else {
                        provider.startTimer();
                      }
                    },
                    isPrimary: true,
                  ),
                  _buildControlButton(
                    context,
                    icon:
                        timerState.soundEnabled
                            ? Icons.volume_up
                            : Icons.volume_off,
                    onPressed: provider.toggleSound,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPresetButton(
    BuildContext context,
    RestTimerProvider provider,
    int seconds,
    String label,
  ) {
    return OutlinedButton(
      onPressed: () => provider.setDuration(seconds),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: Theme.of(context).primaryColor),
      ),
      child: Text(label),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isPrimary
                ? Theme.of(context).primaryColor
                : Theme.of(context).cardColor,
        foregroundColor:
            isPrimary ? Colors.white : Theme.of(context).primaryColor,
        padding: const EdgeInsets.all(16),
        shape: const CircleBorder(),
        elevation: isPrimary ? 4 : 2,
      ),
      child: Icon(icon, size: 24),
    );
  }
}
