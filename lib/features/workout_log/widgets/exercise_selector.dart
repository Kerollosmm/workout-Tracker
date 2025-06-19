import 'package:flutter/material.dart';
import '../../../config/themes/app_theme.dart'; // Import AppTheme
import '../../../core/models/exercise.dart';

class ExerciseSelector extends StatefulWidget {
  final List<Exercise> exercises;

  const ExerciseSelector({Key? key, required this.exercises}) : super(key: key);

  @override
  _ExerciseSelectorState createState() => _ExerciseSelectorState();
}

class _ExerciseSelectorState extends State<ExerciseSelector> {
  String _searchQuery = '';
  String _selectedMuscleGroup = 'All';

  List<Exercise> get filteredExercises {
    List<Exercise> result = widget.exercises;

    if (_selectedMuscleGroup != 'All') {
      result =
          result.where((e) => e.muscleGroup == _selectedMuscleGroup).toList();
    }

    if (_searchQuery.isNotEmpty) {
      result =
          result
              .where(
                (e) =>
                    e.name.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();
    }

    // Sort exercises alphabetically by name
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // The main container's background (AppTheme.cardColor) and top border radius
    // are already applied in workout_log_screen.dart where showModalBottomSheet is called.

    final muscleGroups = [
      'All',
      ...widget.exercises.map((e) => e.muscleGroup).toSet().toList()..sort(),
    ];

    return Column(
      // Removed outer Container, as styling is applied by the caller
      children: [
        // Handle
        Container(
          margin: EdgeInsets.only(
            top: AppTheme.spacing_s,
            bottom: AppTheme.spacing_xs,
          ),
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: AppTheme.secondaryTextColor.withOpacity(
              0.3,
            ), // Use AppTheme color
            borderRadius: BorderRadius.circular(AppTheme.borderRadius_s / 2),
          ),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacing_m,
            horizontal: AppTheme.spacing_m,
          ),
          child: Text(
            'Select Exercise',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryTextColor,
            ),
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing_m),
          child: TextField(
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontSize: AppTheme.darkTheme.textTheme.bodyLarge?.fontSize,
            ),
            decoration: InputDecoration(
              hintText: 'Search Exercises...',
              hintStyle: TextStyle(
                color: AppTheme.secondaryTextColor.withOpacity(0.7),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppTheme.secondaryTextColor,
                size: AppTheme.iconSize_m - 2,
              ),
              filled: true,
              fillColor: AppTheme.surfaceColor, // Use AppTheme.surfaceColor
              contentPadding: EdgeInsets.symmetric(
                vertical: AppTheme.spacing_s + 2,
                horizontal: AppTheme.spacing_m,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
                borderSide:
                    BorderSide
                        .none, // Consistent with AppTheme.inputDecorationTheme
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
                borderSide: BorderSide(
                  color: AppTheme.exerciseRingColor,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // Muscle group filter
        Container(
          height: 50, // Fixed height for the filter bar
          margin: EdgeInsets.symmetric(vertical: AppTheme.spacing_m),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: muscleGroups.length,
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing_m),
            itemBuilder: (context, index) {
              final muscleGroup = muscleGroups[index];
              final isSelected = _selectedMuscleGroup == muscleGroup;
              final colorForMuscle =
                  muscleGroup == 'All'
                      ? AppTheme.exerciseRingColor
                      : AppTheme.getColorForMuscleGroup(muscleGroup);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMuscleGroup = muscleGroup;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: AppTheme.spacing_s),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing_m,
                    vertical: AppTheme.spacing_s,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? colorForMuscle : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadius_m,
                    ), // Pill shape
                    border:
                        isSelected
                            ? null
                            : Border.all(
                              color: AppTheme.cardColor.withOpacity(0.5),
                            ), // Subtle border for unselected
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    muscleGroup,
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color:
                          isSelected
                              ? AppTheme.primaryTextColor
                              : AppTheme.primaryTextColor.withOpacity(0.8),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Exercise list
        Expanded(
          child:
              filteredExercises.isEmpty
                  ? Center(
                    child: Text(
                      'No exercises found',
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize:
                            AppTheme.darkTheme.textTheme.bodyLarge?.fontSize,
                      ),
                    ),
                  )
                  : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing_xs,
                    ),
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = filteredExercises[index];
                      return ListTile(
                        leading: Icon(
                          Icons
                              .fitness_center, // Consider specific icons per muscle group if available
                          color: AppTheme.getColorForMuscleGroup(
                            exercise.muscleGroup,
                          ),
                          size: AppTheme.iconSize_l - 4,
                        ),
                        title: Text(
                          exercise.name,
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(color: AppTheme.primaryTextColor),
                        ),
                        subtitle: Text(
                          exercise.muscleGroup,
                          style: AppTheme.darkTheme.textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.secondaryTextColor),
                        ),
                        trailing:
                            exercise.isFavorite ??
                                    false // Ensure isFavorite is not null
                                ? Icon(
                                  Icons.star_rounded,
                                  color: AppTheme.standRingColor,
                                  size: AppTheme.iconSize_m,
                                )
                                : null,
                        onTap: () {
                          Navigator.pop(context, exercise);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadius_s,
                          ),
                        ),
                      );
                    },
                  ),
        ),

        // "Add Custom Exercise" button at the bottom
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppTheme.spacing_m,
            AppTheme.spacing_m,
            AppTheme.spacing_m,
            AppTheme.spacing_m + MediaQuery.of(context).padding.bottom / 2,
          ),
          child: ElevatedButton.icon(
            icon: Icon(
              Icons.add_circle_outline_rounded,
              color: AppTheme.primaryTextColor,
              size: AppTheme.iconSize_m - 2,
            ),
            label: Text(
              'Add Custom Exercise',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.exerciseRingColor,
              minimumSize: Size(double.infinity, 50), // Prominent button
              padding: const EdgeInsets.symmetric(
                vertical: AppTheme.spacing_s + 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadius_m,
                ), // Pill shape
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context); // Close the selector first
              Navigator.pushNamed(context, '/add_exercise');
            },
          ),
        ),
      ],
    );
  }
}
