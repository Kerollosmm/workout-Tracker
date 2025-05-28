import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/features/dashboard/providers/dashboard_provider.dart';
import 'package:workout_tracker/features/dashboard/widgets/progress_chart_widget.dart';
import 'package:workout_tracker/core/providers/workout_provider.dart';
import 'package:workout_tracker/core/providers/user_provider.dart';
import 'package:workout_tracker/core/models/workout.dart';
import 'package:workout_tracker/features/workout_log/screens/workout_log_screen.dart';
import 'package:workout_tracker/features/history/screens/history_screen.dart';
import 'package:workout_tracker/features/custom_workout/screens/workout_editor_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const DashboardContent(),
    WorkoutLogScreen(),
    HistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Enable full screen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody:
          true, // This allows the bottom navigation bar to be transparent
      body: IndexedStack(
        index: _currentIndex,
        children:
            _screens.map((screen) {
              return Padding(
                // Add padding to account for system UI
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  bottom: 0,
                ),
                child: screen,
              );
            }).toList(),
      ),
      bottomNavigationBar: Container(
        height:
            70 + MediaQuery.of(context).padding.bottom, // Reduced from 80 to 70
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: Colors.grey[800]!, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey[600],
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11, // Reduced from 12 to 11
            height: 1.2, // Added to control text height
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 10, // Reduced from 11 to 10
            height: 1.2, // Added to control text height
          ),
          iconSize: 24, // Explicitly set icon size
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.donut_large, size: 24),
              ),
              label: 'Summary',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.fitness_center, size: 24),
              ),
              label: 'Fitness+',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.people_outline, size: 24),
              ),
              label: 'Sharing',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({Key? key}) : super(key: key);

  @override
  _DashboardContentState createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  Future<void> _navigateToProfile() async {
    // Navigate to profile screen
    await Navigator.pushNamed(context, '/profile');
    // Refresh data when returning from profile
    if (mounted) {
      Provider.of<DashboardProvider>(context, listen: false).refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: _navigateToProfile,
              child: Builder(
                builder: (context) {
                  final photoUrl = userProvider.user?.photoUrl;
                  final hasPhoto = photoUrl?.isNotEmpty == true;

                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[800],
                    child:
                        hasPhoto
                            ? ClipOval(
                              child:
                                  photoUrl!.startsWith('http')
                                      ? Image.network(
                                        photoUrl,
                                        fit: BoxFit.cover,
                                        width: 40,
                                        height: 40,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                ),
                                      )
                                      : Image.file(
                                        File(photoUrl),
                                        fit: BoxFit.cover,
                                        width: 40,
                                        height: 40,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                ),
                                      ),
                            )
                            : const Icon(Icons.person, color: Colors.white),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          dashboardProvider.refreshData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
            bottom: 20,
            left: 16,
            right: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Activity Summary Card
              const ProgressChartWidget(),

              // History Section
              _buildHistorySection(workoutProvider),

              // Add some spacing at the bottom
              _buildTrainerTipsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection(WorkoutProvider workoutProvider) {
    final recentWorkouts = workoutProvider.workouts.take(3).toList();
    final now = DateTime.now();

    String formatWorkoutDate(DateTime date) {
      final difference = now.difference(date);
      if (difference.inDays == 0) return 'Today';
      if (difference.inDays == 1) return 'Yesterday';
      if (difference.inDays < 7) return '${difference.inDays} days ago';
      return DateFormat('MMM d').format(date);
    }

    String getWorkoutTitle(Workout workout) {
      if (workout.workoutName != null && workout.workoutName!.isNotEmpty) {
        return workout.workoutName!;
      }
      return '${workout.exercises.length} ${workout.exercises.length == 1 ? 'Exercise' : 'Exercises'}';
    }

    String getWorkoutSubtitle(Workout workout) {
      return '${workout.totalSets} sets • ${workout.duration} min';
    }

    Widget _buildHistoryItem(
      String title,
      String subtitle,
      String day,
      Color color, {
      required DateTime date,
      VoidCallback? onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.fitness_center, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    day,
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Text(
            'Recent Workouts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (recentWorkouts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Text(
                'No recent workouts',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          )
        else
          ...recentWorkouts
              .map(
                (workout) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildHistoryItem(
                    getWorkoutTitle(workout),
                    getWorkoutSubtitle(workout),
                    formatWorkoutDate(workout.date),
                    Colors.green,
                    date: workout.date,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  WorkoutEditorScreen(workout: workout),
                        ),
                      );
                    },
                  ),
                ),
              )
              .toList(),
      ],
    );
  }

  Widget _buildTrainerTipsSection() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trainer Tips',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildTipItem(
                  Icons.fitness_center,
                  Colors.orange,
                  'Increase Your Weights',
                  'Based on your consistent performance, try increasing weights by 10% for better results.',
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey[800], height: 1),
                const SizedBox(height: 16),
                _buildTipItem(
                  Icons.water_drop,
                  Colors.blue,
                  'Stay Hydrated',
                  'Remember to drink at least 8 glasses of water daily for optimal performance.',
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey[800], height: 1),
                const SizedBox(height: 16),
                _buildTipItem(
                  Icons.nightlight,
                  Colors.indigo,
                  'Prioritize Recovery',
                  'Aim for 7-9 hours of quality sleep to maximize muscle recovery and growth.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildTipItem(
    IconData icon,
    Color color,
    String title,
    String subtitle,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
