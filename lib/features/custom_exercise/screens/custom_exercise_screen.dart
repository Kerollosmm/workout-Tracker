import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_tracker/features/custom_exercise/providers/custom_exercise_provider.dart';
import 'package:workout_tracker/shared/widgets/custom_snackbar.dart';
import '../../../core/models/exercise.dart';
import '../../../core/providers/exercise_provider.dart';
import '../widgets/muscle_group_selector.dart';
import '../../../config/themes/app_theme.dart'; // Added for UI Enhancements

class CustomExerciseScreen extends StatefulWidget {
  @override
  _CustomExerciseScreenState createState() => _CustomExerciseScreenState();
}

class _CustomExerciseScreenState extends State<CustomExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  // String _selectedMuscleGroup = 'Chest'; // Removed 2025-05-29: State now fully managed by provider and MuscleGroupSelector reads from provider
  // bool _isFavorite = false; // Removed, state will be handled by provider
  bool _isSaving = false;
  String? _notes;
  final uuid = Uuid();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveExercise() async {
    // Updated 2025-05-29: Ensure provider has latest values before saving if not using direct binding for all fields.
    // For 'isFavorite', it's now directly updated in the provider by SwitchListTile.
    // For 'exerciseName' and 'notes', they are updated via provider.setExerciseName and provider.setNotes.
    // For 'selectedMuscleGroup', it's updated via provider.setMuscleGroup.

    final provider = Provider.of<CustomExerciseProvider>(
      context,
      listen: false,
    );

    // Validate form (exerciseName is crucial)
    if (provider.exerciseName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar.error(message: 'Exercise name is required.'),
      );
      return;
    }
    if (provider.selectedMuscleGroup.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar.error(message: 'Please select a muscle group.'),
      );
      return;
    }

    // No need to call _formKey.currentState!.validate() if TextFormFields don't use it for validation logic directly
    // and instead rely on provider state checks like above.
    // If TextFormFields have validators, then _formKey.currentState!.validate() is still needed.
    // Assuming basic validation is handled by checking provider's state for now.

    setState(() => _isSaving = true);

    try {
      // Provider's saveExercise method will use its internal state which should be up-to-date.
      await provider.saveExercise();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar.success(message: 'Exercise saved successfully'),
      );
      Navigator.pop(context); // Pop on success
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar.error(
          message: 'Failed to save exercise: ${e.toString()}',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Updated 2025-05-29: UI Enhancements based on image reference
    final exerciseProvider = Provider.of<ExerciseProvider>(
      context,
      listen: false,
    ); // Typically listen:false for data access in build if not directly rebuilding on change
    final customExerciseStateProvider = Provider.of<CustomExerciseProvider>(
      context,
    ); // Listen to changes for UI updates

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.accentTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),

        title: const Text('Add Custom Exercise'), // Theme should style this
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing_l), // Use theme spacing
        child: Form(
          key: _formKey, // Keep form key if using TextFormField validators
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // For full-width buttons
            children: [
              // Exercise Name Field
              TextFormField(
                initialValue: customExerciseStateProvider.exerciseName,
                style: const TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: 'Exercise Name',
                  labelStyle: const TextStyle(
                    color: AppTheme.secondaryTextColor,
                  ),
                  hintText: 'e.g., Barbell Bench Press',
                  hintStyle: TextStyle(
                    color: AppTheme.secondaryTextColor.withOpacity(0.7),
                  ),
                  filled: true,
                  fillColor: AppTheme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadius_m,
                    ),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadius_m,
                    ),
                    borderSide: const BorderSide(
                      color: AppTheme.accentTextColor,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing_m,
                    vertical: AppTheme.spacing_m,
                  ),
                  // errorText: customExerciseStateProvider.exerciseName.isEmpty ? 'Name required' : null, // Simplified validation in _saveExercise
                ),
                onChanged: customExerciseStateProvider.setExerciseName,
                validator: (value) {
                  // Keep validator if _formKey.currentState!.validate() is used
                  if (value == null || value.trim().isEmpty) {
                    return 'Exercise name is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing_l),

              // Muscle Group Selection
              Text(
                'Muscle Group',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: AppTheme.spacing_m,
              ), // Increased spacing before selector
              MuscleGroupSelector(
                muscleGroups: exerciseProvider.allMuscleGroups,
                selectedMuscleGroup:
                    customExerciseStateProvider.selectedMuscleGroup.isEmpty &&
                            exerciseProvider.allMuscleGroups.isNotEmpty
                        ? exerciseProvider.allMuscleGroups.first
                        : customExerciseStateProvider
                            .selectedMuscleGroup, // Ensure a default if provider's is empty
                onMuscleGroupSelected: (muscleGroup) {
                  customExerciseStateProvider.setMuscleGroup(muscleGroup);
                },
              ),
              const SizedBox(height: AppTheme.spacing_l),

              // Favorite Toggle (using SwitchListTile)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Add to Favorites',
                    style: TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: customExerciseStateProvider.isFavorite,
                  onChanged: (bool value) {
                    customExerciseStateProvider.setIsFavorite(value);
                  },
                  activeColor: AppTheme.accentTextColor,
                  inactiveThumbColor: AppTheme.secondaryTextColor,
                  inactiveTrackColor: AppTheme.surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing_m,
                    vertical: AppTheme.spacing_xs,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing_l),

              // Notes Field
              Text(
                'Notes (Optional)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacing_m),
              TextFormField(
                initialValue: customExerciseStateProvider.notes,
                style: const TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., Focus on form, 3-second eccentric',
                  hintStyle: TextStyle(
                    color: AppTheme.secondaryTextColor.withOpacity(0.7),
                  ),
                  filled: true,
                  fillColor: AppTheme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadius_m,
                    ),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadius_m,
                    ),
                    borderSide: const BorderSide(
                      color: AppTheme.accentTextColor,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing_m,
                    vertical: AppTheme.spacing_m,
                  ),
                  counterText:
                      '', // Hiding default counter, can add custom one if needed
                ),
                onChanged: customExerciseStateProvider.setNotes,
                maxLength: 200,
                maxLines: 3,
                minLines: 1,
              ),
              const SizedBox(
                height: AppTheme.spacing_xl + AppTheme.spacing_m,
              ), // More space before button
              // Save Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentTextColor, // Lime green
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacing_m + AppTheme.spacing_xs,
                  ), // ~20px vertical padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadius_l,
                    ), // Large rounding
                  ),
                  minimumSize: const Size(
                    double.infinity,
                    50,
                  ), // Ensure it's full width and has good height
                ),
                onPressed: _isSaving ? null : _saveExercise,
                child:
                    _isSaving
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                            strokeWidth: 3,
                          ),
                        )
                        : const Text(
                          'Save Exercise',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ), // Black text
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
