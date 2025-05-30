// lib/features/custom_exercise/widgets/exercise_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:workout_tracker/config/constants/app_constants.dart'; // Removed due to name collision
import '../../../config/themes/app_theme.dart';
import '../../../core/models/exercise.dart';
import '../providers/custom_exercise_provider.dart';
// import '../../../utils/validators.dart'; // Removed unused import
import 'muscle_group_selector.dart';

class ExerciseForm extends StatefulWidget {
  final Exercise? exercise; // If provided, we're editing an existing exercise
  
  const ExerciseForm({Key? key, this.exercise}) : super(key: key);
  
  @override
  _ExerciseFormState createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<ExerciseForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  bool _isProcessing = false; // Added for loading state
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _notesController = TextEditingController();
    
    // If we're editing an existing exercise, populate the form
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.exercise != null) {
        final provider = Provider.of<CustomExerciseProvider>(context, listen: false);
        provider.loadExercise(widget.exercise!);
        _nameController.text = provider.exerciseName;
        _notesController.text = provider.notes ?? '';
      }
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CustomExerciseProvider>(context);
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Name Field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Exercise Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.fitness_center),
            ),
            onChanged: (value) {
              provider.setExerciseName(value);
            },
          ),
          SizedBox(height: AppTheme.spacing_l),
          
          // Muscle Group Selection
          Text(
            'Muscle Group',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppTheme.spacing_s),
          MuscleGroupSelector(
            muscleGroups: provider.muscleGroups,
            selectedMuscleGroup: provider.selectedMuscleGroup,
            onMuscleGroupSelected: (muscleGroup) {
              provider.setMuscleGroup(muscleGroup);
            },
          ),
          SizedBox(height: AppTheme.spacing_l),
          
          // Favorite Checkbox
          CheckboxListTile(
            title: Text('Add to Favorites'),
            value: provider.isFavorite,
            onChanged: (value) {
              provider.toggleFavorite();
            },
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          SizedBox(height: AppTheme.spacing_l),
          
          // Notes Field
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 3,
            onChanged: (value) {
              provider.setNotes(value.isEmpty ? null : value);
            },
          ),
          SizedBox(height: AppTheme.spacing_xl),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isProcessing = true);
                        try {
                          if (widget.exercise != null) {
                            // Update existing exercise
                            await provider.updateExercise(widget.exercise!.id);
                          } else {
                            // Create new exercise
                            await provider.saveExercise();
                          }

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Exercise ${widget.exercise != null ? 'updated' : 'saved'} successfully')),
                          );
                          Navigator.pop(context); // Pop on success
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed: ${e.toString()}'), backgroundColor: Colors.red),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => _isProcessing = false);
                          }
                        }
                      }
                    },
                    child: _isProcessing 
                        ? CircularProgressIndicator(color: Colors.white) 
                        : Text(
                            widget.exercise != null ? 'Update Exercise' : 'Save Exercise',
                            style: TextStyle(fontSize: 16),
                          ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.exercise != null)
                Padding(
                  padding: EdgeInsets.only(left: AppTheme.spacing_m),
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Exercise'),
                            content: Text('Are you sure you want to delete this exercise?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm ?? false) {
                          setState(() => _isProcessing = true);
                          try {
                            await provider.deleteExercise(widget.exercise!.id);
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Exercise deleted successfully')),
                            );
                            Navigator.pop(context); // Pop on success
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to delete: ${e.toString()}'), backgroundColor: Colors.red),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _isProcessing = false);
                            }
                          }
                        }
                      },
                      child: _isProcessing
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Delete', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
