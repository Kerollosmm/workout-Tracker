import 'package:flutter/material.dart';
import 'dart:math' as math;

// Updated 2025-05-20: Created custom workout progress indicator for visualizing workout completion
class WorkoutProgressIndicator extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? child;
  final String? label;
  final bool showPercentage;
  final TextStyle? percentageTextStyle;
  final Animation<double>? animation;

  const WorkoutProgressIndicator({
    Key? key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8.0,
    this.progressColor,
    this.backgroundColor,
    this.child,
    this.label,
    this.showPercentage = true,
    this.percentageTextStyle,
    this.animation,
  })  : assert(progress >= 0 && progress <= 1, 'Progress must be between 0.0 and 1.0'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveProgressColor = progressColor ?? theme.colorScheme.primary;
    final effectiveBackgroundColor = backgroundColor ?? 
        theme.colorScheme.primary.withOpacity(0.2);
    
    // If an animation is provided, use it to animate the progress
    final effectiveProgress = animation != null 
        ? animation!.value * progress 
        : progress;
        
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background circle
          Center(
            child: SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: strokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(effectiveBackgroundColor),
              ),
            ),
          ),
          
          // Progress arc
          Center(
            child: SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: effectiveProgress,
                strokeWidth: strokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressColor),
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
          
          // Center content
          Center(
            child: child ?? (showPercentage 
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(effectiveProgress * 100).toInt()}%',
                        style: percentageTextStyle ?? 
                            theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (label != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          label!,
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  )
                : const SizedBox.shrink()
            ),
          ),
        ],
      ),
    );
  }
}

// A variation that displays remaining time
class WorkoutTimerIndicator extends StatelessWidget {
  final Duration remaining;
  final Duration total;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final bool showRemainingTime;
  final String? label;
  final TextStyle? timeTextStyle;
  final TextStyle? labelTextStyle;

  const WorkoutTimerIndicator({
    Key? key,
    required this.remaining,
    required this.total,
    this.size = 100,
    this.strokeWidth = 8.0,
    this.progressColor,
    this.backgroundColor,
    this.showRemainingTime = true,
    this.label,
    this.timeTextStyle,
    this.labelTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double progress = 1.0 - (remaining.inMilliseconds / total.inMilliseconds);
    
    // Ensure progress is within bounds
    progress = math.min(1.0, math.max(0.0, progress));
    
    String timeString = '';
    if (showRemainingTime) {
      final minutes = remaining.inMinutes;
      final seconds = remaining.inSeconds % 60;
      timeString = '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    
    return WorkoutProgressIndicator(
      progress: progress,
      size: size,
      strokeWidth: strokeWidth,
      progressColor: progressColor,
      backgroundColor: backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showRemainingTime) ...[
            Text(
              timeString,
              style: timeTextStyle ?? theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label!,
              style: labelTextStyle ?? theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
