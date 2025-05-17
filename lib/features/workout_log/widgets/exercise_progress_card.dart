import 'package:flutter/material.dart';
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
    // Calculate progress metrics
    final totalSets = exercise.sets.length;
    final completedSets = exercise.sets.where((set) => set.reps > 0).length;
    final totalWeight = exercise.sets.fold<double>(0, (sum, set) => sum + (set.weight * set.reps));
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF363636),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.fitness_center, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.exerciseName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        exercise.muscleGroup,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isReadOnly)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ),
          
          // Progress Indicators
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressIndicator(
                  value: completedSets / (totalSets == 0 ? 1 : totalSets),
                  color: Colors.green,
                  icon: Icons.check_circle,
                  label: 'Sets',
                  text: '$completedSets/$totalSets',
                ),
                _buildProgressIndicator(
                  value: totalWeight / 1000, // Normalize for visualization
                  color: Colors.orange,
                  icon: Icons.local_fire_department,
                  label: 'Volume',
                  text: '${totalWeight.toStringAsFixed(1)} kg',
                ),
                _buildProgressIndicator(
                  value: exercise.sets.where((s) => s.isHardSet).length / (totalSets == 0 ? 1 : totalSets),
                  color: Colors.blue,
                  icon: Icons.timer,
                  label: 'Hard Sets',
                  text: '${exercise.sets.where((s) => s.isHardSet).length}',
                ),
              ],
            ),
          ),

          // Rest Timer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: EditableRestTimer(
              initialSeconds: 60,
              onTimeChanged: onRestTimeChanged,
            ),
          ),

          // Sets List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exercise.sets.length,
            itemBuilder: (context, setIndex) {
              final set = exercise.sets[setIndex];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Set ${setIndex + 1}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: isReadOnly
                          ? Text(
                              '${set.weight} kg',
                              style: const TextStyle(color: Colors.white),
                            )
                          : TextFormField(
                              initialValue: set.weight.toString(),
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Weight (kg)',
                                labelStyle: TextStyle(color: Colors.grey),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                              ),
                              onChanged: (value) => onUpdateSet?.call(
                                setIndex,
                                setIndex,
                                weight: double.tryParse(value) ?? 0,
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: isReadOnly
                          ? Text(
                              '${set.reps} reps',
                              style: const TextStyle(color: Colors.white),
                            )
                          : TextFormField(
                              initialValue: set.reps.toString(),
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Reps',
                                labelStyle: TextStyle(color: Colors.grey),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
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
                          color: set.isHardSet ? Colors.yellow : Colors.grey,
                        ),
                        onPressed: () => onUpdateSet?.call(
                          setIndex,
                          setIndex,
                          isHardSet: !set.isHardSet,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => onRemoveSet?.call(setIndex, setIndex),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

          // Add Set Button - Only show if not read-only
          if (!isReadOnly)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton.icon(
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Set', style: TextStyle(color: Colors.white)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => onAddSet?.call(exercise.sets.length),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator({
    required double value,
    required Color color,
    required IconData icon,
    required String label,
    required String text,
  }) {
    return Column(
      children: [
        SizedBox(
          height: 60,
          width: 60,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: value.clamp(0, 1),
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 8,
              ),
              Center(
                child: Icon(icon, color: color),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey[400]),
        ),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
} 