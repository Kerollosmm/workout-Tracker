// lib/features/dashboard/widgets/progress_card.dart

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/utils/performance_metrics.dart';

class ProgressCard extends StatefulWidget {
  const ProgressCard({Key? key}) : super(key: key);

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer2<WorkoutProvider, SettingsProvider>(
      builder: (context, workoutProvider, settingsProvider, _) {
        final weightUnit = settingsProvider.weightUnit;
        
        // Basic metrics using proper equations
        final totalVolume = workoutProvider.getTotalWeightLifted(null);
        final effectiveVolume = workoutProvider.getEffectiveWeightLifted(null);
        final totalHardSets = workoutProvider.getHardSetCount(null);
        
        // Calculate training density using the proper equation
        final trainingDensity = _calculateTrainingDensity(workoutProvider);
        
        // Calculate relative strength ratio
        final relativeStrength = _calculateRelativeStrength(workoutProvider, settingsProvider);
        
        // Calculate volume load (tonnage)
        final volumeLoad = _calculateVolumeLoad(workoutProvider);
        
        // Calculate progress rate using monthly progress rate equation
        final progressRate = _calculateProgressRate(workoutProvider);
        
        final List<_ProgressData> progressData = [
          _ProgressData(
            title: "Total Volume",
            value: totalVolume,
            color: Colors.orange,
            unit: weightUnit,
            description: "Sets × Reps × Weight",
          ),
          _ProgressData(
            title: "Effective Volume",
            value: effectiveVolume,
            color: Colors.blue,
            unit: weightUnit,
            description: "Hard Sets Only",
          ),
          _ProgressData(
            title: "Volume Load",
            value: volumeLoad,
            color: Colors.indigo,
            unit: weightUnit,
            description: "Progressive Overload",
          ),
          _ProgressData(
            title: "Training Density",
            value: trainingDensity,
            color: Colors.green,
            unit: "vol/min",
            description: "Volume / Time",
          ),
          _ProgressData(
            title: "Relative Strength",
            value: relativeStrength,
            color: Colors.red,
            unit: "",
            description: "Strength : Body Weight",
          ),
          _ProgressData(
            title: "Progress Rate",
            value: progressRate,
            color: Colors.purple,
            unit: "%",
            description: "Monthly Improvement",
          ),
        ];

        return GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              setState(() {
                _selectedIndex = (_selectedIndex - 1) % progressData.length;
                if (_selectedIndex < 0) _selectedIndex = progressData.length - 1;
              });
            } else if (details.primaryVelocity! < 0) {
              setState(() {
                _selectedIndex = (_selectedIndex + 1) % progressData.length;
              });
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
                        percent: _getNormalizedValue(progressData[_selectedIndex]),
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
                          color: index == _selectedIndex
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
  
  // Performance equation implementations using PerformanceMetrics class
  double _calculateTrainingDensity(WorkoutProvider provider) {
    final workouts = provider.workouts;
    if (workouts.isEmpty) return 0;
    
    double totalVolume = 0;
    double totalMinutes = 0;
    
    for (var workout in workouts.take(10)) { // Last 10 workouts
      for (var exercise in workout.exercises) {
        for (var set in exercise.sets) {
          totalVolume += set.weight * set.reps;
        }
      }
      totalMinutes += 60; // Assuming 1 hour per workout (you could track actual duration)
    }
    
    return PerformanceMetrics.calculateTrainingDensity(totalVolume, totalMinutes);
  }
  
  double _calculateRelativeStrength(WorkoutProvider provider, SettingsProvider settings) {
    // This would need user weight data - assuming 70kg for now
    double bodyWeight = settings.weightUnit == 'kg' ? 70 : 154;
    double maxBenchPress = _estimateOneRepMax(provider, 'Bench Press');
    
    return PerformanceMetrics.calculateRelativeStrength(maxBenchPress, bodyWeight);
  }
  
  double _calculateVolumeLoad(WorkoutProvider provider) {
    final workouts = provider.workouts;
    if (workouts.isEmpty) return 0;
    
    double totalVolumeLoad = 0;
    
    for (var workout in workouts.take(4)) { // Last month of workouts
      for (var exercise in workout.exercises) {
        totalVolumeLoad += PerformanceMetrics.calculateTonnage(exercise.sets);
      }
    }
    
    return totalVolumeLoad;
  }
  
  double _calculateProgressRate(WorkoutProvider provider) {
    final workouts = provider.workouts;
    if (workouts.length < 8) return 0; // Need at least 2 months of data
    
    double recentTotal = 0;
    double previousTotal = 0;
    
    // Recent 4 weeks
    for (var workout in workouts.take(4)) {
      recentTotal += workout.totalWeightLifted;
    }
    
    // Previous 4 weeks
    for (var workout in workouts.skip(4).take(4)) {
      previousTotal += workout.totalWeightLifted;
    }
    
    return PerformanceMetrics.calculateMonthlyProgressRate(recentTotal, previousTotal);
  }
  
  double _estimateOneRepMax(WorkoutProvider provider, String exerciseName) {
    final workouts = provider.workouts;
    double maxEstimate = 0;
    
    for (var workout in workouts) {
      for (var exercise in workout.exercises) {
        if (exercise.exerciseName == exerciseName) {
          for (var set in exercise.sets) {
            double estimate = PerformanceMetrics.calculateOneRepMax(set.weight, set.reps);
            if (estimate > maxEstimate) maxEstimate = estimate;
          }
        }
      }
    }
    
    return maxEstimate;
  }
  
  double _getNormalizedValue(_ProgressData data) {
    switch (data.title) {
      case "Progress Rate":
        return (data.value.clamp(-10, 20) + 10) / 30; // Normalize between -10% and 20%
      case "Relative Strength":
        return data.value.clamp(0, 3) / 3; // Normalize between 0 and 3x body weight
      case "Training Density":
        return data.value.clamp(0, 500) / 500; // Normalize between 0 and 500 vol/min
      default:
        return (data.value / 1000).clamp(0, 1); // Simple normalization for other metrics
    }
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