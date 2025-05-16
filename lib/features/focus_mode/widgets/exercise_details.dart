import 'package:flutter/material.dart';
import 'package:workout_tracker/core/models/workout.dart';
import 'package:workout_tracker/shared/widgets/detail_row.dart';
import 'package:workout_tracker/shared/widgets/section_card.dart';
import 'package:workout_tracker/config/themes/app_styles.dart';

class ExerciseDetails extends StatelessWidget {
  final WorkoutExercise exercise;

  const ExerciseDetails({
    Key? key,
    required this.exercise,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasNotes = exercise.notes?.isNotEmpty ?? false;
    
    return SectionCard(
      title: 'Exercise Details',
      children: [
        DetailRow(
          label: 'Sets',
          value: exercise.sets.length.toString(),
          icon: Icons.repeat,
        ),
        DetailRow(
          label: 'Reps',
          value: exercise.reps.toString(),
          icon: Icons.fitness_center,
        ),
        DetailRow(
          label: 'Weight',
          value: '${exercise.weight} kg',
          icon: Icons.monitor_weight_outlined,
        ),
        if (hasNotes) ...[
          SizedBox(height: AppStyles.spacingS),
          Text(
            'Notes:',
            style: AppStyles.getSubtitleStyle(context),
          ),
          SizedBox(height: AppStyles.spacingXS),
          Text(
            exercise.notes!,
            style: AppStyles.getBodyStyle(context),
          ),
        ],
      ],
    );
  }

} 
