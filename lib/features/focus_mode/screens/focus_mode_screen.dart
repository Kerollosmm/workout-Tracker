import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/core/models/workout.dart';
import 'package:workout_tracker/features/focus_mode/providers/focus_mode_provider.dart';
import 'package:workout_tracker/features/focus_mode/widgets/exercise_timer.dart';
import 'package:workout_tracker/features/focus_mode/widgets/exercise_details.dart';
import 'package:workout_tracker/shared/widgets/custom_app_bar.dart';
import 'package:workout_tracker/shared/widgets/app_dialog.dart';
import 'package:workout_tracker/config/themes/app_styles.dart';

class FocusModeScreen extends StatefulWidget {
  final Workout workout;

  const FocusModeScreen({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  _FocusModeScreenState createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  late FocusModeProvider _focusModeProvider;

  @override
  void initState() {
    super.initState();
    _focusModeProvider = Provider.of<FocusModeProvider>(context, listen: false);
    _initializeFocusMode();
  }

  Future<void> _initializeFocusMode() async {
    try {
      await _focusModeProvider.startFocusSession(widget.workout);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start focus mode: $e')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _focusModeProvider.endFocusSession();
    super.dispose();
  }

  void _handleExerciseComplete() {
    if (_focusModeProvider.currentExerciseIndex < widget.workout.exercises.length - 1) {
      _focusModeProvider.nextExercise();
      _focusModeProvider.startRestTimer(() {
        // Rest period complete callback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rest period complete. Start next exercise!')),
        );
      });
    } else {
      // Workout complete
      _showWorkoutCompleteDialog();
    }
  }

  Future<void> _showWorkoutCompleteDialog() async {
    await AppDialog.showInfo(
      context: context,
      title: 'Workout Complete! 🎉',
      message: 'Great job! You\'ve completed ${widget.workout.name} in focus mode.',
      buttonText: 'Done',
      barrierDismissible: false,
    ).then((_) => Navigator.pop(context)); // Return to previous screen
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await AppDialog.showConfirmation(
          context: context,
          title: 'Exit Focus Mode?',
          message: 'Are you sure you want to exit focus mode? Your progress will be saved.',
          cancelText: 'Cancel',
          confirmText: 'Exit',
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Focus Mode',
          actions: [
            IconButton(
              icon: const Icon(Icons.stop_circle_outlined),
              onPressed: () async {
                final shouldEnd = await AppDialog.showConfirmation(
                  context: context,
                  title: 'End Workout?',
                  message: 'Are you sure you want to end this workout?',
                  cancelText: 'Cancel',
                  confirmText: 'End',
                );
                if (shouldEnd ?? false) {
                  await _focusModeProvider.endFocusSession();
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        body: Consumer<FocusModeProvider>(
          builder: (context, provider, _) {
            if (!provider.isInFocusMode) {
              return const Center(child: CircularProgressIndicator());
            }

            final currentExercise = widget.workout.exercises[provider.currentExerciseIndex];

            return Container(
              padding: AppStyles.paddingL,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentExercise.name,
                    style: AppStyles.getHeadingStyle(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppStyles.spacingXL),
                  ExerciseTimer(
                    duration: currentExercise.duration ?? 60,
                    onComplete: _handleExerciseComplete,
                  ),
                  SizedBox(height: AppStyles.spacingXL),
                  ExerciseDetails(exercise: currentExercise),
                  if (provider.currentExerciseIndex < widget.workout.exercises.length - 1)
                    Padding(
                      padding: EdgeInsets.only(top: AppStyles.spacingL),
                      child: Text(
                        'Next: ${widget.workout.exercises[provider.currentExerciseIndex + 1].name}',
                        style: AppStyles.getSubtitleStyle(context),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
} 
