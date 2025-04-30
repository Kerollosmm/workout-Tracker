import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/workout_provider.dart';
import '../providers/dashboard_provider.dart';

class ProgressChartWidget extends StatefulWidget {
  const ProgressChartWidget({Key? key}) : super(key: key);

  @override
  _ProgressChartWidgetState createState() => _ProgressChartWidgetState();
}

class _ProgressChartWidgetState extends State<ProgressChartWidget> {
  String _selectedMetric = 'volume';

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    final weekData = dashboardProvider.getWeeklyChartData() ?? [];

    final spots = _getSpots(weekData, workoutProvider);
    final spots2 = _getSecondarySpots(weekData, workoutProvider);

    double maxY =
        spots.isNotEmpty
            ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.2
            : 10;

    return SizedBox(
      height: 300,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with metric selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Performance Trend',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedMetric,
                    underline: Container(),
                    items: const [
                      DropdownMenuItem(value: 'volume', child: Text('Volume')),
                      DropdownMenuItem(
                        value: 'tonnage',
                        child: Text('Tonnage'),
                      ),
                      DropdownMenuItem(
                        value: 'intensity',
                        child: Text('Intensity'),
                      ),
                      DropdownMenuItem(
                        value: 'density',
                        child: Text('Density'),
                      ),
                      DropdownMenuItem(
                        value: 'calories',
                        child: Text('Calories'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedMetric = value);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Chart
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < weekData.length) {
                              final date = weekData[index]['date'] as DateTime?;
                              if (date != null) {
                                return Text(
                                  DateFormat('E').format(date),
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              _formatAxisLabel(value),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // Primary metric
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Theme.of(context).primaryColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.2),
                        ),
                      ),
                      // Secondary metric (trend line)
                      if (_selectedMetric == 'volume' ||
                          _selectedMetric == 'calories')
                        LineChartBarData(
                          spots: spots2,
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          dashArray: const [5, 5],
                        ),
                    ],
                  ),
                ),
              ),

              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(
                    context,
                    'Actual',
                    Theme.of(context).primaryColor,
                  ),
                  if (_selectedMetric == 'volume' ||
                      _selectedMetric == 'calories')
                    _buildLegendItem(context, 'Trend', Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(width: 16, height: 3, color: color),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  List<FlSpot> _getSpots(
    List<Map<String, dynamic>> weekData,
    WorkoutProvider provider,
  ) {
    if (weekData.isEmpty) return [];

    try {
      switch (_selectedMetric) {
        case 'volume':
          return weekData.asMap().entries.map((entry) {
            final totalWeight = entry.value['totalWeight'] as double? ?? 0.0;
            return FlSpot(entry.key.toDouble(), totalWeight);
          }).toList();
        case 'tonnage':
          return _calculateTonnage(weekData, provider);
        case 'intensity':
          return _calculateIntensity(weekData, provider);
        case 'density':
          return _calculateDensity(weekData, provider);
        case 'calories':
          return _calculateCalories(weekData, provider);
        default:
          return [];
      }
    } catch (e) {
      debugPrint('Error calculating chart data: $e');
      return [];
    }
  }

  List<FlSpot> _calculateCalories(
    List<Map<String, dynamic>> weekData,
    WorkoutProvider provider,
  ) {
    return weekData.asMap().entries.map((entry) {
      final calories = entry.value['calories'] as double? ?? 0.0;
      return FlSpot(entry.key.toDouble(), calories);
    }).toList();
  }

  List<FlSpot> _getSecondarySpots(
    List<Map<String, dynamic>> weekData,
    WorkoutProvider provider,
  ) {
    if (_selectedMetric == 'volume' || _selectedMetric == 'calories') {
      // Calculate trend line
      final spots = _getSpots(weekData, provider);
      if (spots.length < 2) return [];

      // Simple linear regression for trend line
      double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
      for (var spot in spots) {
        sumX += spot.x;
        sumY += spot.y;
        sumXY += spot.x * spot.y;
        sumX2 += spot.x * spot.x;
      }

      double n = spots.length.toDouble();
      // Prevent division by zero
      if ((n * sumX2 - sumX * sumX) == 0) return [];

      double slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
      double intercept = (sumY - slope * sumX) / n;

      return spots.map((spot) {
        return FlSpot(spot.x, slope * spot.x + intercept);
      }).toList();
    }
    return [];
  }

  List<FlSpot> _calculateTonnage(
    List<Map<String, dynamic>> weekData,
    WorkoutProvider provider,
  ) {
    final workouts = provider.workouts ?? [];
    if (workouts.isEmpty) return [];

    return weekData.asMap().entries.map((entry) {
      double totalTonnage = 0;
      final date = entry.value['date'] as DateTime?;

      if (date != null) {
        final dayWorkouts = workouts.where(
          (w) =>
              w.date.year == date.year &&
              w.date.month == date.month &&
              w.date.day == date.day,
        );

        for (var workout in dayWorkouts) {
          for (var exercise in workout.exercises) {
            for (var set in exercise.sets) {
              totalTonnage += set.weight * set.reps;
            }
          }
        }
      }

      return FlSpot(entry.key.toDouble(), totalTonnage);
    }).toList();
  }

  List<FlSpot> _calculateIntensity(
    List<Map<String, dynamic>> weekData,
    WorkoutProvider provider,
  ) {
    final workouts = provider.workouts ?? [];
    if (workouts.isEmpty) return [];

    return weekData.asMap().entries.map((entry) {
      double avgIntensity = 0;
      int setCount = 0;
      final date = entry.value['date'] as DateTime?;

      if (date != null) {
        final dayWorkouts = workouts.where(
          (w) =>
              w.date.year == date.year &&
              w.date.month == date.month &&
              w.date.day == date.day,
        );

        for (var workout in dayWorkouts) {
          for (var exercise in workout.exercises) {
            for (var set in exercise.sets) {
              avgIntensity += set.reps;
              setCount++;
            }
          }
        }
      }

      return FlSpot(
        entry.key.toDouble(),
        setCount > 0 ? avgIntensity / setCount : 0,
      );
    }).toList();
  }

  List<FlSpot> _calculateDensity(
    List<Map<String, dynamic>> weekData,
    WorkoutProvider provider,
  ) {
    final workouts = provider.workouts ?? [];
    if (workouts.isEmpty) return [];

    return weekData.asMap().entries.map((entry) {
      int totalReps = 0;
      final date = entry.value['date'] as DateTime?;

      if (date != null) {
        final dayWorkouts = workouts.where(
          (w) =>
              w.date.year == date.year &&
              w.date.month == date.month &&
              w.date.day == date.day,
        );

        for (var workout in dayWorkouts) {
          for (var exercise in workout.exercises) {
            for (var set in exercise.sets) {
              totalReps += set.reps;
            }
          }
        }
      }

      // Assuming 60 minutes per workout
      double density = totalReps / 60.0;

      return FlSpot(entry.key.toDouble(), density);
    }).toList();
  }

  String _formatAxisLabel(double value) {
    switch (_selectedMetric) {
      case 'volume':
        return '${value.toInt()}kg';
      case 'tonnage':
        return '${(value / 1000).toStringAsFixed(1)}t';
      case 'intensity':
        return value.toStringAsFixed(1);
      case 'density':
        return '${value.toStringAsFixed(1)}/min';
      case 'calories':
        return '${value.toInt()} cal';
      default:
        return value.toStringAsFixed(1);
    }
  }
}
