import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // Assuming Uuid is still needed

// Assuming these are your actual imports and are correct
// Replace these placeholders with your actual file paths
// import 'package:workout_tracker/features/custom_exercise/providers/custom_exercise_provider.dart';
// import 'package:workout_tracker/shared/widgets/custom_snackbar.dart';
// import '../../../core/models/exercise.dart'; // If Exercise model is used directly
// import '../../../core/providers/exercise_provider.dart';
// import '../widgets/muscle_group_selector.dart';

// Mock Providers and Widgets for standalone example
// Replace these with your actual providers and widgets from your project

class CustomExerciseProvider with ChangeNotifier {
  String _exerciseName = '';
  String _muscleGroup = 'Chest'; // Default
  bool _isFavorite = false;
  String? _notes;

  String get exerciseName => _exerciseName;
  String get muscleGroup => _muscleGroup;
  bool get isFavorite => _isFavorite;
  String? get notes => _notes;

  void setExerciseName(String name) {
    _exerciseName = name;
    notifyListeners();
  }

  void setMuscleGroup(String group) {
    _muscleGroup = group;
    notifyListeners();
  }

  void setIsFavorite(bool fav) {
    _isFavorite = fav;
    notifyListeners();
  }

  void setNotes(String? newNotes) {
    _notes = newNotes;
    notifyListeners();
  }

  Future<void> saveExercise() async {
    // Simulate saving
    print(
      'Saving exercise: Name: $_exerciseName, Muscle Group: $_muscleGroup, Favorite: $_isFavorite, Notes: $_notes',
    );
    await Future.delayed(Duration(seconds: 1));
    // In a real app, this would interact with a database or service
    // Example: if (_exerciseName.isEmpty) throw Exception("Exercise name cannot be empty.");
  }

  // Optional: Call this if you want to clear form when screen is entered
  void reset() {
    _exerciseName = '';
    _muscleGroup = 'Chest';
    _isFavorite = false;
    _notes = null;
    notifyListeners();
  }
}

class ExerciseProvider with ChangeNotifier {
  List<String> get allMuscleGroups => [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Abs',
    'Full Body',
  ];
  // Add any other methods or properties your ExerciseProvider might have
}

class MuscleGroupSelector extends StatelessWidget {
  final List<String> muscleGroups;
  final String selectedMuscleGroup;
  final ValueChanged<String> onMuscleGroupSelected;

  const MuscleGroupSelector({
    Key? key,
    required this.muscleGroups,
    required this.selectedMuscleGroup,
    required this.onMuscleGroupSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedMuscleGroup,
      dropdownColor: AppColors.darkCardBackground,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.darkFieldBackground,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.accentColorBlue.withOpacity(0.7),
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.accentColorBlue, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        hintStyle: TextStyle(color: AppColors.secondaryTextColor),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      style: TextStyle(color: AppColors.primaryTextColor),
      items:
          muscleGroups.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(color: AppColors.primaryTextColor),
              ),
            );
          }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          onMuscleGroupSelected(newValue);
        }
      },
      iconEnabledColor: AppColors.secondaryTextColor,
    );
  }
}

class CustomSnackbar {
  static SnackBar success({required String message}) {
    return SnackBar(
      content: Text(
        message,
        style: TextStyle(color: AppColors.primaryTextColor),
      ),
      backgroundColor: AppColors.accentColorGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: EdgeInsets.all(10.0),
    );
  }

  static SnackBar error({required String message}) {
    return SnackBar(
      content: Text(
        message,
        style: TextStyle(color: AppColors.primaryTextColor),
      ),
      backgroundColor: AppColors.accentColorPink,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: EdgeInsets.all(10.0),
    );
  }
}
// --- End of Mock Providers and Widgets ---

// Define a class for your app's color palette
class AppColors {
  static const Color darkScaffoldBackground = Color(0xFF121212);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkFieldBackground = Color(0xFF2C2C2C);

  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFFB0B0B0);

  static const Color accentColorPink = Color(0xFFE91E63);
  static const Color accentColorGreen = Color(0xFF4CAF50);
  static const Color accentColorBlue = Color(
    0xFF0096D6,
  ); // From dashboard rings

  static const Color buttonColor = accentColorGreen; // Default button color
  static const Color iconColor = Colors.white;
}

class CustomExerciseScreen extends StatefulWidget {
  @override
  _CustomExerciseScreenState createState() => _CustomExerciseScreenState();
}

class _CustomExerciseScreenState extends State<CustomExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  // _nameController is removed as provider handles name state for TextFormField
  String _selectedMuscleGroup = 'Chest'; // Local state for UI
  bool _isFavorite = false; // Local state for UI
  bool _isSaving = false;
  // _notes local state is removed as provider handles notes state for TextFormField
  final uuid = Uuid(); // Keep if used

  @override
  void initState() {
    super.initState();
    // Initialize local state from provider if needed, or ensure provider has defaults
    // This ensures consistency if the screen is revisited or provider state changes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CustomExerciseProvider>(
        context,
        listen: false,
      );
      // provider.reset(); // Uncomment if you want to clear form on entry
      setState(() {
        _selectedMuscleGroup = provider.muscleGroup;
        _isFavorite = provider.isFavorite;
      });
    });
  }

  @override
  void dispose() {
    // _nameController.dispose(); // Removed
    super.dispose();
  }

  void _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;
    // _formKey.currentState!.save(); // Call if you have onSaved in TextFormFields

    setState(() => _isSaving = true);

    final customExerciseProvider = Provider.of<CustomExerciseProvider>(
      context,
      listen: false,
    );

    // Ensure provider has the latest local UI state before saving
    customExerciseProvider.setMuscleGroup(
      _selectedMuscleGroup,
    ); // Already set in onMuscleGroupSelected, but good for safety
    customExerciseProvider.setIsFavorite(_isFavorite);

    try {
      await customExerciseProvider.saveExercise();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar.success(message: 'Exercise saved successfully'),
      );
      Navigator.pop(context);
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

  // Helper for themed InputDecoration
  InputDecoration themedInputDecoration({
    required String labelText,
    String? hintText,
    String? errorText, // Note: errorText is usually handled by validator
    String? counterText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      // errorText: errorText, // Validator is preferred for dynamic errors
      counterText: counterText,
      labelStyle: TextStyle(color: AppColors.secondaryTextColor),
      hintStyle: TextStyle(
        color: AppColors.secondaryTextColor.withOpacity(0.7),
      ),
      errorStyle: TextStyle(color: AppColors.accentColorPink.withOpacity(0.9)),
      counterStyle: TextStyle(
        color: AppColors.secondaryTextColor.withOpacity(0.9),
      ),
      filled: true,
      fillColor: AppColors.darkFieldBackground,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      border: OutlineInputBorder(
        // Default border
        borderSide: BorderSide(
          color: AppColors.secondaryTextColor.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: AppColors.accentColorBlue.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.accentColorBlue, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: AppColors.accentColorPink.withOpacity(0.7),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.accentColorPink, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to ExerciseProvider for muscle groups list
    final exerciseDataProvider = Provider.of<ExerciseProvider>(context);
    // Use Consumer for parts of UI that depend on CustomExerciseProvider's changing data
    // or access it directly for initial values / onChanged calls.

    return Scaffold(
      backgroundColor: AppColors.darkScaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Add Custom Exercise',
          style: TextStyle(
            color: AppColors.primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.darkCardBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryTextColor),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise Name Field - Uses Consumer to get initialValue and set value
              Consumer<CustomExerciseProvider>(
                builder: (context, customExerciseState, _) {
                  return TextFormField(
                    key: ValueKey(
                      'exercise_name_${customExerciseState.exerciseName}',
                    ), // Helps update field if provider resets
                    initialValue: customExerciseState.exerciseName,
                    style: TextStyle(color: AppColors.primaryTextColor),
                    decoration: themedInputDecoration(
                      labelText: 'Exercise Name',
                      hintText: 'e.g., Barbell Bench Press',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Exercise name cannot be empty';
                      }
                      return null;
                    },
                    onChanged:
                        (value) => Provider.of<CustomExerciseProvider>(
                          context,
                          listen: false,
                        ).setExerciseName(value),
                  );
                },
              ),
              SizedBox(height: 24),

              // Muscle Group Selection
              Text(
                'Muscle Group',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTextColor,
                ),
              ),
              SizedBox(height: 8),
              MuscleGroupSelector(
                muscleGroups: exerciseDataProvider.allMuscleGroups,
                selectedMuscleGroup:
                    _selectedMuscleGroup, // Uses local state for display
                onMuscleGroupSelected: (muscleGroup) {
                  setState(() {
                    _selectedMuscleGroup =
                        muscleGroup; // Update local state for UI
                  });
                  // Update provider - can also be done in _saveExercise if preferred
                  Provider.of<CustomExerciseProvider>(
                    context,
                    listen: false,
                  ).setMuscleGroup(muscleGroup);
                },
              ),
              SizedBox(height: 24),

              // Favorite Checkbox
              Theme(
                // To style checkbox border color when unchecked
                data: Theme.of(
                  context,
                ).copyWith(unselectedWidgetColor: AppColors.secondaryTextColor),
                child: CheckboxListTile(
                  title: Text(
                    'Add to Favorites',
                    style: TextStyle(color: AppColors.primaryTextColor),
                  ),
                  value: _isFavorite, // Uses local state
                  onChanged: (value) {
                    setState(() {
                      _isFavorite = value ?? false; // Update local state
                    });
                  },
                  activeColor: AppColors.accentColorGreen,
                  checkColor: AppColors.darkFieldBackground, // Checkmark color
                  tileColor: AppColors.darkFieldBackground,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 4.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              SizedBox(height: 24),

              // Notes Field - Uses Consumer
              Consumer<CustomExerciseProvider>(
                builder: (context, customExerciseState, _) {
                  return TextFormField(
                    key: ValueKey(
                      'notes_${customExerciseState.notes}',
                    ), // Helps update field
                    initialValue: customExerciseState.notes,
                    style: TextStyle(color: AppColors.primaryTextColor),
                    decoration: themedInputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'e.g., focus on form, specific weight',
                      counterText:
                          '${200 - (customExerciseState.notes?.length ?? 0)} characters remaining',
                    ),
                    maxLength: 200,
                    maxLines: 3,
                    onChanged:
                        (value) => Provider.of<CustomExerciseProvider>(
                          context,
                          listen: false,
                        ).setNotes(value),
                  );
                },
              ),
              SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ).copyWith(
                    foregroundColor: MaterialStateProperty.all(
                      AppColors.primaryTextColor,
                    ),
                    textStyle: MaterialStateProperty.all(
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveExercise,
                  child:
                      _isSaving
                          ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.primaryTextColor,
                              strokeWidth: 3.0,
                            ),
                          )
                          : Text('Save Exercise'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// To run this example, you would need a main.dart like this:
/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Assuming your CustomExerciseScreen and providers are in 'custom_exercise_screen.dart'
// For this example, they are in the same file.
// import 'custom_exercise_screen.dart'; // Your actual screen file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CustomExerciseProvider()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
        // Add other providers your app uses
      ],
      child: MaterialApp(
        title: 'Workout Tracker',
        // It's good practice to define a global dark theme
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.darkScaffoldBackground,
          // Define other global theme properties if needed
          // e.g., appBarTheme, textTheme, inputDecorationTheme
        ),
        home: CustomExerciseScreen(), // Or your app's main screen
      ),
    );
  }
}
*/
