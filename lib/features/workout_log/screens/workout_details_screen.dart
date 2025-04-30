import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/workout.dart';
import '../../../config/constants/app_constants.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailsScreen({Key? key, required this.workout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('MMMM d, y').format(workout.date)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Volume',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${workout.totalWeightLifted.toStringAsFixed(1)} kg',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Sets',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${workout.totalSets}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Notes Section
            if (workout.notes?.isNotEmpty == true) ...[
              Text(
                'Notes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(workout.notes!),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Exercises List
            Text(
              'Exercises',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...workout.exercises.map((exercise) => Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppTheme.getColorForMuscleGroup(exercise.muscleGroup).withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          color: AppTheme.getColorForMuscleGroup(exercise.muscleGroup),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.exerciseName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                exercise.muscleGroup,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Sets Header
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Set',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Weight (kg)',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Reps',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Hard',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        // Sets List
                        ...exercise.sets.asMap().entries.map((entry) {
                          final index = entry.key;
                          final set = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text('${index + 1}'),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(set.weight.toStringAsFixed(1)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text('${set.reps}'),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: set.isHardSet
                                      ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                                      : const SizedBox(width: 20),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}