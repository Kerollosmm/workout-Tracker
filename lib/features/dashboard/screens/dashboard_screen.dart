import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/progress_chart_widget.dart';
import '../widgets/workout_summary_card.dart';
import '../widgets/quick_stats_widget.dart';
import '../widgets/progress_card.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final today = dashboardProvider.today;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Fitness Dashboard'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader(context, 'Performance Overview'),
                SizedBox(height: 16),
                QuickStatsWidget(
                  totalSets: dashboardProvider.todayTotalSets,
                  totalWeight: dashboardProvider.todayTotalWeight,
                ),
                SizedBox(height: 24),
                _buildSectionHeader(context, 'Training Volume'),
                ProgressCard(),
                SizedBox(height: 24),
                _buildSectionHeader(context, 'Weekly Progress'),
                ProgressChartWidget(),
                SizedBox(height: 24),
                _buildSectionHeader(context, 'Recent Sessions'),
                _buildRecentWorkouts(context, dashboardProvider),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0: // Already on Dashboard
              break;
            case 1:
              Navigator.pushNamed(context, '/workout_log');
              break;
            case 2:
              Navigator.pushNamed(context, '/analytics');
              break;
            case 3:
              Navigator.pushNamed(context, '/history');
              break;
            case 4:
              Navigator.pushNamed(context, '/settings');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) => Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
      );

  Widget _buildRecentWorkouts(BuildContext context, DashboardProvider provider) {
    final recentWorkouts = provider.recentWorkouts;

    if (recentWorkouts.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No workouts yet. Start tracking your progress!',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Column(
      children: recentWorkouts.map((workout) {
        return WorkoutSummaryCard(
          workout: workout,
          onTap: () {
            // Navigate to workout details
          },
        );
      }).toList(),
    );
  }
}
