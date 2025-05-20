import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/config/constants/app_constants.dart';
import 'package:workout_tracker/core/models/workout.dart';
import 'package:workout_tracker/core/providers/workout_provider.dart';
import 'package:workout_tracker/features/dashboard/providers/dashboard_provider.dart';
import 'package:workout_tracker/features/dashboard/widgets/activity_summary_widget.dart';
import 'package:workout_tracker/features/profile/screens/profile_screen.dart';
import 'package:workout_tracker/features/workout_log/screens/workout_log_screen.dart';
import 'package:workout_tracker/features/history/screens/history_screen.dart';
import 'package:workout_tracker/features/custom_workout/screens/workout_editor_screen.dart';
import 'package:workout_tracker/core/providers/user_provider.dart';
import 'package:workout_tracker/config/themes/app_theme.dart';
import 'package:workout_tracker/features/dashboard/widgets/progress_card.dart';
import 'package:workout_tracker/features/dashboard/widgets/progress_chart_widget.dart';
import 'package:workout_tracker/features/dashboard/widgets/quick_stats_widget.dart';
import 'package:workout_tracker/features/dashboard/widgets/workout_summary_card.dart';
import 'package:workout_tracker/core/providers/settings_provider.dart';
import 'package:workout_tracker/core/providers/analytics_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  // Updated titles for the new 3-tab layout
  final List<String> _titles = ['Summary', 'Fitness+', 'Sharing'];
  // Updated screens to match the new 3-tab layout
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [const DashboardContent(), WorkoutLogScreen(), HistoryScreen()];
  }

  @override
  Widget build(BuildContext context) {
    final bool isSummaryTab = _currentIndex == 0;
    final String currentEyebrowText =
        isSummaryTab ? DateFormat('EEEE, MMM d').format(DateTime.now()) : '';

    return Scaffold(
      appBar: AppBar(
        title:
            isSummaryTab
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentEyebrowText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70, // Assuming AppBar is dark
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(_titles[_currentIndex]),
                  ],
                )
                : Text(_titles[_currentIndex]),
        actions:
            isSummaryTab
                ? [
                  Consumer<UserProvider>(
                    builder: (context, userProvider, _) {
                      final user = userProvider.user;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.white24,
                            backgroundImage:
                                user.photoUrl.isNotEmpty
                                    ? FileImage(File(user.photoUrl))
                                    : null,
                            child:
                                user.photoUrl.isEmpty
                                    ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    )
                                    : null,
                          ),
                        ),
                      );
                    },
                  ),
                ]
                : null,
        backgroundColor:
            AppTheme.primaryColor, // Or Colors.black for Figma match
        elevation: 0,
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[600],
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              label: 'Summary',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: 'Fitness+',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              label: 'Sharing',
            ),
          ],
        ),
      ),
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton.extended(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkoutEditorScreen(),
                      ),
                    ),
                backgroundColor: AppTheme.primaryColor,
                icon: const Icon(Icons.add),
                label: const Text('New Workout'),
                heroTag: 'dashboardFAB', // Unique heroTag
              )
              : null,
    );
  }
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({Key? key}) : super(key: key);

  @override
  _DashboardContentState createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  String _selectedTimePeriod =
      'Weekly'; // Add this property for time period selection

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final analyticsProvider = Provider.of<AnalyticsProvider>(
      context,
      listen: false,
    );

    final today = DateTime.now();
    final dailyStats = dashboardProvider.getDailyStats(today);

    // Calculate total sets and weight for QuickStatsWidget
    final totalSets = workoutProvider
        .getWorkoutsForDay(today)
        .expand((workout) => workout.exercises)
        .fold(0, (total, exercise) => total + exercise.sets.length);

    final totalWeight = workoutProvider
        .getWorkoutsForDay(today)
        .expand((workout) => workout.exercises)
        .expand((exercise) => exercise.sets)
        .fold(0.0, (total, set) => total + (set.weight * set.reps));

    return RefreshIndicator(
      onRefresh: () async {
        // Force refresh of data
        dashboardProvider.refreshData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Overview
            const ProgressCard(),
            const SizedBox(height: 16),

            // Performance Chart
            const ProgressChartWidget(),
            const SizedBox(height: 16),

            // Quick Stats
            QuickStatsWidget(totalSets: totalSets, totalWeight: totalWeight),
            const SizedBox(height: 16),

            // Workout Summary
            const WorkoutSummaryCard(),
            const SizedBox(height: 16),

            // Activity Summary
            const ActivitySummaryWidget(),
            const SizedBox(height: 16),

            // Today's Workouts
            Text(
              'Today\'s Workouts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildDayWorkoutsWidget(today),
            const SizedBox(height: 24),

            // History Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('History', style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Show More',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildWorkoutHistory(context, workoutProvider),
            const SizedBox(height: 24),

            // Trainer Tips
            Text('Trainer Tips', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _buildTrainerTips(context, userProvider, workoutProvider),
          ],
        ),
      ),
    );
  }

  // Add this method to handle day workouts widget
  Widget _buildDayWorkoutsWidget(DateTime date) {
    // Get workouts for this day
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final workoutsForDay = workoutProvider.getWorkoutsForDay(date);

    if (workoutsForDay.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                const Text('No workouts scheduled for today'),
                ElevatedButton(
                  onPressed: _navigateToWorkoutEditor,
                  child: const Text('Add Workout'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workoutsForDay.length,
      itemBuilder: (context, index) {
        final workout = workoutsForDay[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            title: Text(workout.workoutName),
            subtitle: Text('${workout.exercises.length} exercises'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _navigateToWorkoutDetails(workout),
          ),
        );
      },
    );
  }

  void _navigateToWorkoutEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WorkoutEditorScreen()),
    );
  }

  void _navigateToWorkoutDetails(Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutEditorScreen(workout: workout),
      ),
    );
  }

  Widget _buildWorkoutHistory(BuildContext context, WorkoutProvider provider) {
    final recentWorkouts = provider.workouts.take(3).toList();

    if (recentWorkouts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No workout history available'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentWorkouts.length,
      itemBuilder: (context, index) {
        final workout = recentWorkouts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: Icon(Icons.directions_walk, color: Colors.green),
            title: Text(
              workout
                  .workoutName, // Use workout name instead of hardcoded value
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${workout.exercises.length} exercises', // Display exercise count instead of distance
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: Text(
              DateFormat('EEEE').format(workout.date),
              style: TextStyle(color: Colors.grey),
            ),
            onTap: () {
              _navigateToWorkoutDetails(workout);
            },
          ),
        );
      },
    );
  }

  Widget _buildTrainerTips(
    BuildContext context,
    UserProvider userProvider,
    WorkoutProvider workoutProvider,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userProvider.shouldSuggestWeightIncrease(workoutProvider))
              ListTile(
                leading: Icon(Icons.fitness_center, color: Colors.orange),
                title: Text('Increase Your Weights'),
                subtitle: Text(
                  'Based on your consistent performance, try increasing weights by 10% for better results.',
                ),
              ),
            ListTile(
              leading: Icon(Icons.water_drop, color: Colors.blue),
              title: Text('Stay Hydrated'),
              subtitle: Text(
                'Remember to drink at least 8 glasses of water daily for optimal performance.',
              ),
            ),
            ListTile(
              leading: Icon(Icons.nightlight, color: Colors.indigo),
              title: Text('Prioritize Recovery'),
              subtitle: Text(
                'Aim for 7-9 hours of quality sleep to maximize muscle recovery and growth.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New method for time period selection
  Widget _buildTimePeriodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimePeriodButton('Weekly', _selectedTimePeriod == 'Weekly'),
        _buildTimePeriodButton('Monthly', _selectedTimePeriod == 'Monthly'),
        _buildTimePeriodButton('Yearly', _selectedTimePeriod == 'Yearly'),
      ],
    );
  }

  Widget _buildTimePeriodButton(String title, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTimePeriod = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
