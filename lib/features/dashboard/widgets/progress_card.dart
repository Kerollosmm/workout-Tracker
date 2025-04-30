// lib/features/dashboard/widgets/progress_card.dart

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../core/providers/settings_provider.dart';
// Removed unused import

class ProgressCard extends StatefulWidget {
  const ProgressCard({Key? key}) : super(key: key);

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> {
  int _selectedIndex = 0;
  Map<String, double> _cachedMetrics = {
    'totalVolume': 0.0,
    'effectiveVolume': 0.0,
    'trainingDensity': 0.0,
    'relativeStrength': 0.0,
    'volumeLoad': 0.0,
    'progressRate': 0.0,
  };
  DateTime? _lastMetricsUpdate;

  void _updateMetricsCache(
    WorkoutProvider workoutProvider,
    SettingsProvider settingsProvider,
  ) {
    final totalVolume = workoutProvider.getTotalWeightLifted(null) != null ? workoutProvider.getTotalWeightLifted(null) : 0.0;
    final effectiveVolume =
        workoutProvider.getEffectiveWeightLifted(null) != null ? workoutProvider.getEffectiveWeightLifted(null) : 0.0;

    _cachedMetrics = {
      'totalVolume': totalVolume,
      'effectiveVolume': effectiveVolume,
      'trainingDensity': _calculateTrainingDensity(workoutProvider),
      'relativeStrength': _calculateRelativeStrength(
        workoutProvider,
        settingsProvider,
      ),
      'volumeLoad': _calculateVolumeLoad(workoutProvider),
      'progressRate': _calculateProgressRate(workoutProvider),
    };

    _lastMetricsUpdate = DateTime.now();
  }

  bool _shouldUpdateMetrics() {
    return _lastMetricsUpdate == null ||
        DateTime.now().difference(_lastMetricsUpdate!) >
            const Duration(minutes: 5);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WorkoutProvider, SettingsProvider>(
      builder: (context, workoutProvider, settingsProvider, _) {
        final weightUnit = settingsProvider.weightUnit != null ? settingsProvider.weightUnit : 'kg';

        if (_shouldUpdateMetrics()) {
          _updateMetricsCache(workoutProvider, settingsProvider);
        }

        final List<_ProgressData> progressData = [
          _ProgressData(
            title: "Total Volume",
            value: _cachedMetrics['totalVolume']!,
            color: Colors.orange,
            unit: weightUnit,
            description: "Sets × Reps × Weight",
          ),
          _ProgressData(
            title: "Effective Volume",
            value: _cachedMetrics['effectiveVolume']!,
            color: Colors.blue,
            unit: weightUnit,
            description: "Hard Sets Only",
          ),
          _ProgressData(
            title: "Volume Load",
            value: _cachedMetrics['volumeLoad']!,
            color: Colors.indigo,
            unit: weightUnit,
            description: "Progressive Overload",
          ),
          _ProgressData(
            title: "Training Density",
            value: _cachedMetrics['trainingDensity']!,
            color: Colors.green,
            unit: "vol/min",
            description: "Volume / Time",
          ),
          _ProgressData(
            title: "Relative Strength",
            value: _cachedMetrics['relativeStrength']!,
            color: Colors.red,
            unit: "",
            description: "Strength : Body Weight",
          ),
          _ProgressData(
            title: "Progress Rate",
            value: _cachedMetrics['progressRate']!,
            color: Colors.purple,
            unit: "%",
            description: "Monthly Improvement",
          ),
        ];

        return GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! > 0) {
                setState(() {
                  _selectedIndex = (_selectedIndex - 1) % progressData.length;
                  if (_selectedIndex < 0)
                    _selectedIndex = progressData.length - 1;
                });
              } else if (details.primaryVelocity! < 0) {
                setState(() {
                  _selectedIndex = (_selectedIndex + 1) % progressData.length;
                });
              }
            }
          },
          child: Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header with indicator dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Performance Metrics",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Circular progress indicator
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularPercentIndicator(
                        radius: 100.0,
                        lineWidth: 18.0,
                        percent: _getNormalizedValue(
                          progressData[_selectedIndex],
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        backgroundColor: Colors.grey.shade200,
                        progressColor: progressData[_selectedIndex].color,
                        animation: true,
                        animationDuration: 800,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            progressData[_selectedIndex].title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${progressData[_selectedIndex].value.toStringAsFixed(1)} ${progressData[_selectedIndex].unit}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: progressData[_selectedIndex].color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            progressData[_selectedIndex].description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Indicator dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      progressData.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              index == _selectedIndex
                                  ? progressData[_selectedIndex].color
                                  : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Swipe to view more metrics",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateTrainingDensity(WorkoutProvider workoutProvider) {
    final workouts = workoutProvider.workouts;
    if (workouts.isEmpty) return 0.0;

    double totalVolume = 0.0;
    double totalDuration = 0.0;

    for (final workout in workouts) {
      totalVolume += workout.totalWeightLifted;
      // Ensure we have a valid duration
      if (workout.duration > 0) {
        totalDuration += workout.duration.toDouble();
      }
    }

    return totalDuration > 0 ? totalVolume / totalDuration : 0.0;
  }

  double _calculateRelativeStrength(
    WorkoutProvider provider,
    SettingsProvider settings,
  ) {
    final workouts = provider.workouts;
    if (workouts.isEmpty) return 0.0;

    double bodyWeight = settings.weightUnit == 'kg' ? 70 : 154;

    // Safety null checks for the whole chain
    final exerciseSets =
        workouts
            .expand((w) => w.exercises)
            .where((e) => e.exerciseName == 'Bench Press')
            .expand((e) => e.sets)
            .toList();

    if (exerciseSets.isEmpty) return 0.0;

    final maxWeight = exerciseSets.fold(
      0.0,
      (max, set) => set.weight > max ? set.weight : max,
    );

    return bodyWeight > 0 ? maxWeight / bodyWeight : 0.0;
  }

  double _calculateVolumeLoad(WorkoutProvider provider) {
    final workouts = provider.workouts;
    if (workouts.isEmpty) return 0.0;

    return workouts
        .take(4)
        .expand((w) => w.exercises)
        .expand((e) => e.sets)
        .fold(0.0, (total, set) => total + (set.weight * set.reps));
  }

  double _calculateProgressRate(WorkoutProvider provider) {
    final workouts = provider.workouts;
    if (workouts.length < 8) return 0;

    final recentWorkouts = workouts.take(4).toList();
    final previousWorkouts = workouts.skip(4).take(4).toList();

    final recentTotal = recentWorkouts.fold(
      0.0,
      (total, w) => total + w.totalWeightLifted,
    );
    final previousTotal = previousWorkouts.fold(
      0.0,
      (total, w) => total + w.totalWeightLifted,
    );

    return previousTotal > 0
        ? ((recentTotal - previousTotal) / previousTotal) * 100
        : 0;
  }

  double _getNormalizedValue(final _ProgressData data) {
    // Normalize the value to a percentage between 0 and 1
    double normalizedValue = 0.0;

    switch (data.title) {
      case "Total Volume":
        normalizedValue =
            data.value / 10000.0; // Assuming 10000 is a good max volume
        break;
      case "Effective Volume":
        normalizedValue =
            data.value / 5000.0; // Assuming 5000 is a good max effective volume
        break;
      case "Training Density":
        normalizedValue =
            data.value / 100.0; // Assuming 100 is a good max density
        break;
      case "Relative Strength":
        normalizedValue =
            data.value / 3.0; // Assuming 3x bodyweight is a good max
        break;
      case "Volume Load":
        normalizedValue = data.value / 20000.0; // Assuming 20000 is a good max
        break;
      case "Progress Rate":
        normalizedValue = data.value / 100.0; // Already a percentage
        break;
      default:
        normalizedValue = 0.5; // Default to 50%
        break;
    }

    // Ensure the value is between 0 and 1
    return normalizedValue.clamp(0.0, 1.0);
  }
}

class _ProgressData {
  final String title;
  final double value;
  final Color color;
  final String unit;
  final String description;

  _ProgressData({
    required this.title,
    required this.value,
    required this.color,
    required this.unit,
    required this.description,
  });
}
