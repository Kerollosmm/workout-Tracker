import 'package:flutter/material.dart';
import '../../../config/themes/app_theme.dart';
import '../../../core/models/exercise.dart';

class ExerciseSelector extends StatefulWidget {
  final List<Exercise> exercises;

  const ExerciseSelector({
    Key? key,
    required this.exercises,
  }) : super(key: key);

  @override
  _ExerciseSelectorState createState() => _ExerciseSelectorState();
}

class _ExerciseSelectorState extends State<ExerciseSelector> {
  String _searchQuery = '';
  String _selectedMuscleGroup = 'All';
  
  List<Exercise> get filteredExercises {
    List<Exercise> result = widget.exercises;
    
    // Filter by muscle group if not "All"
    if (_selectedMuscleGroup != 'All') {
      result = result.where((e) => e.muscleGroup == _selectedMuscleGroup).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      result = result.where((e) => 
        e.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final muscleGroups = ['All', ...widget.exercises
      .map((e) => e.muscleGroup)
      .toSet()
      .toList()..sort()];

    // Determine theme colors
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color currentTextColor = isDarkMode ? AppTheme.primaryTextColor : Colors.black87;
    final Color currentSecondaryTextColor = isDarkMode ? AppTheme.secondaryTextColor : Colors.black54;
    final Color currentBorderColor = isDarkMode ? AppTheme.primaryTextColor.withOpacity(0.2) : Colors.grey.shade400;
    final Color currentHintColor = isDarkMode ? AppTheme.secondaryTextColor.withOpacity(0.7) : Colors.grey.shade500;
    final Color currentCardBgColor = isDarkMode ? AppTheme.cardColor : Colors.white;
    final Color currentSurfaceColor = isDarkMode ? AppTheme.surfaceColor : Colors.grey.shade100;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: currentCardBgColor, 
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.borderRadius_l), 
          topRight: Radius.circular(AppTheme.borderRadius_l), 
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: AppTheme.spacing_s, bottom: AppTheme.spacing_xs), 
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.secondaryTextColor.withOpacity(0.5) : Colors.grey[300], 
              borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing_m, horizontal: AppTheme.spacing_m), 
            child: Text(
              'Select Exercise',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: currentTextColor, 
              ),
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing_m), 
            child: TextField(
              style: TextStyle(color: currentTextColor), 
              decoration: InputDecoration(
                hintText: 'Search Exercises...',
                hintStyle: TextStyle(color: currentHintColor), 
                prefixIcon: Icon(Icons.search, color: currentSecondaryTextColor), 
                filled: true,
                fillColor: currentSurfaceColor, 
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
                  borderSide: BorderSide(color: currentBorderColor), 
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
                  borderSide: BorderSide(color: AppTheme.exerciseRingColor, width: 1.5), 
                ),
                contentPadding: EdgeInsets.symmetric(vertical: AppTheme.spacing_s, horizontal: AppTheme.spacing_m), 
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
            height: 50,
            margin: EdgeInsets.symmetric(vertical: AppTheme.spacing_m), 
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: muscleGroups.length,
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing_m), 
              itemBuilder: (context, index) {
                final muscleGroup = muscleGroups[index];
                final isSelected = _selectedMuscleGroup == muscleGroup;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMuscleGroup = muscleGroup;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: AppTheme.spacing_s), 
                    padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing_m, vertical: AppTheme.spacing_s), 
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? AppTheme.exerciseRingColor 
                        : currentSurfaceColor, 
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius_m), 
                      border: isSelected ? null : Border.all(color: currentBorderColor) 
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      muscleGroup,
                      style: TextStyle(
                        color: isSelected ? AppTheme.primaryTextColor : currentTextColor, 
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Exercise list
          Expanded(
            child: filteredExercises.isEmpty
                ? Center(
                    child: Text('No exercises found', style: TextStyle(color: currentSecondaryTextColor)), 
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing_xs), 
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = filteredExercises[index];
                      return ListTile(
                        leading: Icon( 
                          Icons.fitness_center, 
                          color: AppTheme.getColorForMuscleGroup(exercise.muscleGroup),
                        ),
                        title: Text(exercise.name, style: TextStyle(color: currentTextColor)), 
                        subtitle: Text(exercise.muscleGroup, style: TextStyle(color: currentSecondaryTextColor)), 
                        trailing: exercise.isFavorite
                            ? Icon(Icons.star, color: AppTheme.standRingColor) 
                            : null,
                        onTap: () {
                          Navigator.pop(context, exercise);
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius_s)),
                      );
                    },
                  ),
          ),
          
          // "Add Custom Exercise" button at the bottom
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing_m), 
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add_exercise');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing_m - AppTheme.spacing_xs, horizontal: AppTheme.spacing_s), 
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: AppTheme.primaryTextColor), 
                    SizedBox(width: AppTheme.spacing_s),
                    Text('Add Custom Exercise', style: TextStyle(color: AppTheme.primaryTextColor, fontWeight: FontWeight.bold)), 
                  ],
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.exerciseRingColor, 
                minimumSize: Size(double.infinity, 50), 
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
}
