import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_tracker/features/custom_exercise/providers/custom_exercise_provider.dart';
import 'package:workout_tracker/shared/widgets/custom_snackbar.dart';
import '../../../core/models/exercise.dart';
import '../../../core/providers/exercise_provider.dart';
import '../widgets/muscle_group_selector.dart';

class CustomExerciseScreen extends StatefulWidget {
  @override
  _CustomExerciseScreenState createState() => _CustomExerciseScreenState();
}

class _CustomExerciseScreenState extends State<CustomExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedMuscleGroup = 'Chest';
  bool _isFavorite = false;
  bool _isSaving = false;
  String? _notes;
  final uuid = Uuid();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Updated 2024-07-26: Changed to await void method and use try-catch
      await Provider.of<CustomExerciseProvider>(
        context,
        listen: false,
      ).saveExercise();

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
    final exerciseProvider = Provider.of<ExerciseProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Add Custom Exercise')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise Name Field
              Consumer<CustomExerciseProvider>(
                builder:
                    (context, provider, _) => TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Exercise Name',
                        errorText:
                            provider.exerciseName.isEmpty
                                ? 'Name required'
                                : null,
                      ),
                      onChanged: provider.setExerciseName,
                    ),
              ),
              SizedBox(height: 24),

              // Muscle Group Selection
              Text(
                'Muscle Group',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              MuscleGroupSelector(
                muscleGroups: exerciseProvider.allMuscleGroups,
                selectedMuscleGroup: _selectedMuscleGroup,
                onMuscleGroupSelected: (muscleGroup) {
                  Provider.of<CustomExerciseProvider>(
                    context,
                    listen: false,
                  ).setMuscleGroup(muscleGroup);
                },
              ),
              SizedBox(height: 24),

              // Favorite Checkbox
              CheckboxListTile(
                title: Text('Add to Favorites'),
                value: _isFavorite,
                onChanged: (value) {
                  setState(() {
                    _isFavorite = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              SizedBox(height: 24),

              // Notes Field
              TextFormField(
                maxLength: 200,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  counterText:
                      'Characters remaining: ${200 - (Provider.of<CustomExerciseProvider>(context).notes?.length ?? 0)}',
                ),
                onChanged:
                    (value) => Provider.of<CustomExerciseProvider>(
                      context,
                      listen: false,
                    ).setNotes(value),
              ),
              SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: StatefulBuilder(
                  builder:
                      (context, setState) => ElevatedButton(
                        onPressed: _isSaving ? null : _saveExercise,
                        child:
                            _isSaving
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text('Save Exercise'),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
