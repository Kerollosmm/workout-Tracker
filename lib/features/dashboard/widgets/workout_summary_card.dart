import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/workout.dart';
import '../../../core/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class WorkoutSummaryCard extends StatefulWidget {
  final Workout workout;
  final VoidCallback? onTap;

  const WorkoutSummaryCard({
    Key? key,
    required this.workout,
    this.onTap,
  }) : super(key: key);

  @override
  State<WorkoutSummaryCard> createState() => _WorkoutSummaryCardState();
}

class _WorkoutSummaryCardState extends State<WorkoutSummaryCard> {
  late Map<String, dynamic> _metrics;

  @override
  void initState() {
    super.initState();
    _calculateMetrics();
  }

  @override
  void didUpdateWidget(WorkoutSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workout != widget.workout) {
      _calculateMetrics();
    }
  }

  void _calculateMetrics() {
    final totalExercises = widget.workout.exercises.length;
    final totalSets = widget.workout.totalSets;
    final totalWeightLifted = widget.workout.totalWeightLifted;

    // Calculate muscle group distribution efficiently
    final muscleGroupCounts = widget.workout.exercises.fold<Map<String, int>>(
      {},
      (counts, exercise) {
        counts[exercise.muscleGroup] = (counts[exercise.muscleGroup] ?? 0) + 1;
        return counts;
      },
    );

    final primaryMuscleGroup = muscleGroupCounts.isEmpty
        ? 'N/A'
        : muscleGroupCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

    _metrics = {
      'totalExercises': totalExercises,
      'totalSets': totalSets,
      'totalWeightLifted': totalWeightLifted,
      'primaryMuscleGroup': primaryMuscleGroup,
    };
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        dateFormat.format(widget.workout.date),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  /// Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat(context, '${_metrics['totalExercises']}', 'Exercises'),
                      _buildStat(context, '${_metrics['totalSets']}', 'Sets'),
                      _buildStat(
                        context,
                        '${_metrics['totalWeightLifted'].toStringAsFixed(0)}',
                        settingsProvider.weightUnit,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// Exercises List Preview
            if (widget.workout.exercises.isNotEmpty) ...[
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...widget.workout.exercises.take(2).map(
                      (exercise) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.fitness_center, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                exercise.exerciseName,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${exercise.sets.length} sets',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.workout.exercises.length > 2)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+ ${widget.workout.exercises.length - 2} more exercises',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
