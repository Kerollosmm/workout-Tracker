import 'package:flutter/material.dart';
import '../../../config/themes/app_theme.dart'; // Added for UI Enhancements

class MuscleGroupSelector extends StatelessWidget {
  final List<String> muscleGroups;
  final String selectedMuscleGroup;
  final Function(String) onMuscleGroupSelected;

  const MuscleGroupSelector({
    Key? key,
    required this.muscleGroups,
    required this.selectedMuscleGroup,
    required this.onMuscleGroupSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Updated 2025-05-29: UI Enhancements to use Wrap and chip-style buttons
    if (muscleGroups.isEmpty) {
      return const SizedBox.shrink(); // Return empty if no muscle groups
    }

    return Wrap(
      spacing: AppTheme.spacing_s, // Horizontal spacing between chips
      runSpacing: AppTheme.spacing_m, // Vertical spacing between lines of chips
      children:
          muscleGroups.map((muscleGroup) {
            final isSelected = selectedMuscleGroup == muscleGroup;
            return GestureDetector(
              onTap: () => onMuscleGroupSelected(muscleGroup),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal:
                      AppTheme
                          .spacing_l, // Generous horizontal padding for pill shape
                  vertical: AppTheme.spacing_m, // Vertical padding
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppTheme.accentTextColor
                          : AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(
                    AppTheme.spacing_xl,
                  ), // Pill shape
                  border: Border.all(
                    color:
                        isSelected
                            ? AppTheme.accentTextColor
                            : AppTheme.surfaceColor.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  muscleGroup,
                  style: TextStyle(
                    color:
                        isSelected
                            ? AppTheme.primaryColor
                            : AppTheme
                                .primaryTextColor, // Black text on green, white on dark grey
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14, // Slightly smaller font for chips
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
