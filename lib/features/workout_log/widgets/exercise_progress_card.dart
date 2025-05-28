import 'package:flutter/material.dart';
import '../../../config/themes/app_theme.dart';
import '../../../core/models/workout.dart';
import 'editable_rest_timer.dart';

class ExerciseProgressCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final VoidCallback? onDelete;
  final Function(int)? onAddSet;
  final Function(int, int)? onRemoveSet;
  final Function(int, int, {double? weight, int? reps, bool? isHardSet})? onUpdateSet;
  final Function(int)? onRestTimeChanged;

  const ExerciseProgressCard({
    Key? key,
    required this.exercise,
    this.onDelete,
    this.onAddSet,
    this.onRemoveSet,
    this.onUpdateSet,
    this.onRestTimeChanged,
  }) : super(key: key);

  bool get isReadOnly => onDelete == null && onAddSet == null && onRemoveSet == null && onUpdateSet == null;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color currentTextColor = isDarkMode ? AppTheme.primaryTextColor : Colors.black87;
    final Color currentSecondaryTextColor = isDarkMode ? AppTheme.secondaryTextColor : Colors.black54;
    final Color currentBorderColor = isDarkMode ? AppTheme.primaryTextColor.withOpacity(0.2) : Colors.grey.shade400;
    final Color currentCardBgColor = isDarkMode ? AppTheme.cardColor : Colors.white;
    final Color currentSurfaceColor = isDarkMode ? AppTheme.surfaceColor : Colors.grey.shade100;

    final totalSets = exercise.sets.length;
    final completedSets = exercise.sets.where((set) => set.reps > 0).length;
    final totalWeight = exercise.sets.fold<double>(0, (sum, set) => sum + (set.weight * set.reps));

    return Container(
      margin: const EdgeInsets.all(AppTheme.spacing_m),
      decoration: BoxDecoration(
        color: currentCardBgColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius_l),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing_m),
            decoration: BoxDecoration(
              color: currentSurfaceColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.borderRadius_l)),
            ),
            child: Row(
              children: [
                Icon(Icons.fitness_center, color: AppTheme.getColorForMuscleGroup(exercise.muscleGroup)),
                const SizedBox(width: AppTheme.spacing_m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.exerciseName,
                        style: TextStyle(
                          color: currentTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        exercise.muscleGroup,
                        style: TextStyle(
                          color: currentSecondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isReadOnly)
                  IconButton(
                    icon: Icon(Icons.delete, color: AppTheme.moveRingColor),
                    onPressed: onDelete,
                    tooltip: 'Delete Exercise',
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing_m),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressIndicator(
                  context: context,
                  value: completedSets / (totalSets == 0 ? 1 : totalSets),
                  color: AppTheme.exerciseRingColor,
                  icon: Icons.check_circle_outline,
                  label: 'Sets',
                  text: '$completedSets/$totalSets',
                ),
                _buildProgressIndicator(
                  context: context,
                  value: totalWeight / 1000,
                  color: AppTheme.standRingColor,
                  icon: Icons.fitness_center,
                  label: 'Volume',
                  text: '${totalWeight.toStringAsFixed(0)} kg',
                ),
                _buildProgressIndicator(
                  context: context,
                  value: exercise.sets.where((s) => s.isHardSet).length / (totalSets == 0 ? 1 : totalSets),
                  color: AppTheme.moveRingColor,
                  icon: Icons.star_outline,
                  label: 'Hard Sets',
                  text: '${exercise.sets.where((s) => s.isHardSet).length}',
                ),
              ],
            ),
          ),
          if (!isReadOnly)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing_m, vertical: AppTheme.spacing_s),
              child: EditableRestTimer(
                initialSeconds: exercise.restTimeInSeconds ?? 60,
                onTimeChanged: onRestTimeChanged,
              ),
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exercise.sets.length,
            itemBuilder: (context, setIndex) {
              final set = exercise.sets[setIndex];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing_m, vertical: AppTheme.spacing_xs),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: setIndex == exercise.sets.length - 1 ? Colors.transparent : currentBorderColor.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text(
                        'Set ${setIndex + 1}',
                        style: TextStyle(color: currentSecondaryTextColor, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing_s),
                    Expanded(
                      child: isReadOnly
                          ? Text(
                              '${set.weight} kg',
                              style: TextStyle(color: currentTextColor, fontSize: 16, fontWeight: FontWeight.w500),
                            )
                          : TextFormField(
                              initialValue: set.weight.toStringAsFixed(set.weight.truncateToDouble() == set.weight ? 0 : 1),
                              style: TextStyle(color: currentTextColor, fontSize: 16),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.transparent),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: AppTheme.exerciseRingColor, width: 1),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: AppTheme.spacing_xs),
                                isDense: true,
                              ),
                              onChanged: (value) => onUpdateSet?.call(
                                setIndex,
                                setIndex,
                                weight: double.tryParse(value) ?? 0,
                              ),
                            ),
                    ),
                    const SizedBox(width: AppTheme.spacing_m),
                    Expanded(
                      child: isReadOnly
                          ? Text(
                              '${set.reps} reps',
                              style: TextStyle(color: currentTextColor, fontSize: 16, fontWeight: FontWeight.w500),
                            )
                          : TextFormField(
                              initialValue: set.reps.toString(),
                              style: TextStyle(color: currentTextColor, fontSize: 16),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.transparent),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: AppTheme.exerciseRingColor, width: 1),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: AppTheme.spacing_xs),
                                isDense: true,
                              ),
                              onChanged: (value) => onUpdateSet?.call(
                                setIndex,
                                setIndex,
                                reps: int.tryParse(value) ?? 0,
                              ),
                            ),
                    ),
                    if (!isReadOnly) ...[
                      IconButton(
                        icon: Icon(
                          set.isHardSet ? Icons.star : Icons.star_border,
                          color: set.isHardSet ? AppTheme.standRingColor : currentSecondaryTextColor,
                          size: AppTheme.iconSize_m,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () => onUpdateSet?.call(
                          setIndex,
                          setIndex,
                          isHardSet: !set.isHardSet,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: AppTheme.moveRingColor.withOpacity(0.7), size: AppTheme.iconSize_m),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () => onRemoveSet?.call(setIndex, setIndex),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          if (!isReadOnly)
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing_m),
              child: ElevatedButton.icon(
                icon: Icon(Icons.add, color: AppTheme.primaryTextColor),
                label: Text('Add Set', style: TextStyle(color: AppTheme.primaryTextColor, fontWeight: FontWeight.bold)),
                onPressed: () => onAddSet?.call(exercise.sets.length),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.exerciseRingColor.withOpacity(0.8),
                  minimumSize: Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
                  ),
                  elevation: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator({
    required BuildContext context,
    required double value,
    required Color color,
    required IconData icon,
    required String label,
    required String text,
  }) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color currentTextColor = isDarkMode ? AppTheme.primaryTextColor : Colors.black87;
    final Color currentSecondaryTextColor = isDarkMode ? AppTheme.secondaryTextColor : Colors.black54;

    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value.isNaN || value.isInfinite ? 0 : value.clamp(0.0, 1.0),
                strokeWidth: 5,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                backgroundColor: color.withOpacity(0.2),
              ),
              Icon(icon, color: color, size: AppTheme.iconSize_l),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing_s),
        Text(
          label,
          style: TextStyle(color: currentSecondaryTextColor, fontSize: 12),
        ),
        Text(
          text,
          style: TextStyle(color: currentTextColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}