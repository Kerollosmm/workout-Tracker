import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../config/constants/app_constants.dart';
import '../../custom_workout/screens/workout_editor_screen.dart';
import '../components/day_workouts_widget.dart';
import '../../analytics/screens/analytics_screen.dart';
import '../../workout_log/screens/workout_log_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../settings/screens/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardContent(),
    WorkoutLogScreen(),
    AnalyticsScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];
  
  final List<String> _titles = [
    'Workout Dashboard',
    'Log Workout',
    'Analytics',
    'History',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Log',
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
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({Key? key}) : super(key: key);

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  String? _selectedExerciseId;
  
  @override
  Widget build(BuildContext context) {
    try {
      final workoutProvider = Provider.of<WorkoutProvider>(context);
      final stats = workoutProvider.getDashboardStats();
      final todayStats = (stats['today'] as Map<String, dynamic>?) ?? {};
      final dailyData = (stats['dailyData'] as List<dynamic>?) ?? [];

      final exercises = workoutProvider.workouts
          .expand((w) => w.exercises)
          .map((e) => {'id': e.exerciseId, 'name': e.exerciseName})
          .toSet()
          .toList();

      return Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 300));
            if (context.mounted) setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(todayStats),
                _buildExerciseDropdown(exercises),
                _buildPerformanceChart(workoutProvider, dailyData),
                _buildMuscleGroupChart(stats),
                _buildTodaysWorkouts(workoutProvider),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WorkoutEditorScreen()),
          ),
          backgroundColor: AppTheme.primaryColor,
          icon: const Icon(Icons.add),
          label: const Text('New Workout'),
        ),
      );
    } catch (e) {
      debugPrint('Dashboard error: $e');
      return const Center(child: Text('Error loading dashboard data'));
    }
  }

  Widget _buildHeaderSection(Map<String, dynamic> todayStats) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Progress',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Weight', '${todayStats['weight'] as num? ?? 0} kg', Icons.fitness_center),
              _buildStatCard('Sets', '${todayStats['sets'] as int? ?? 0}', Icons.repeat),
              _buildStatCard('Hard Sets', '${todayStats['hardSets'] as int? ?? 0}', Icons.star),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseDropdown(List<Map<String, dynamic>> exercises) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Track Exercise Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _selectedExerciseId,
              hint: const Text('Select Exercise'),
              isExpanded: true,
              underline: const SizedBox(),
              items: exercises
                  .where((exercise) => exercise['id'] != null && exercise['name'] != null)
                  .map((exercise) => DropdownMenuItem<String>(
                        value: exercise['id'] as String,
                        child: Text(exercise['name'] as String),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedExerciseId = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(WorkoutProvider provider, List<dynamic> dailyData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedExerciseId != null ? 'Exercise Progress' : 'Weekly Progress',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: _selectedExerciseId != null 
                    ? _buildExerciseProgressChart(provider)
                    : _buildWeeklyProgressChart(dailyData),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMuscleGroupChart(Map<String, dynamic> stats) {
    final muscleData = (stats['muscleGroupData'] as Map<String, int>?) ?? {};
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Muscle Group Focus',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: _buildMuscleGroupChartContent(muscleData),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMuscleGroupChartContent(Map<String, int> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No muscle group data available', style: TextStyle(color: Colors.grey)));
    }
    return PieChart(
      PieChartData(
        sections: data.entries.map((e) => PieChartSectionData(
          color: AppTheme.getColorForMuscleGroup(e.key),
          value: e.value.toDouble(),
          title: '${e.key}\n${e.value}',
          radius: 80,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        )).toList(),
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildTodaysWorkouts(WorkoutProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Workouts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DayWorkoutsWidget(
            workouts: provider.getWorkoutsForDay(DateTime.now()),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseProgressChart(WorkoutProvider provider) {
    try {
      if (_selectedExerciseId == null) {
        return const Center(child: Text('Select an exercise'));
      }

      final progressData = provider.getExerciseProgressData(_selectedExerciseId!);
      if (progressData.isEmpty) {
        return const Center(child: Text('No data available for this exercise'));
      }

      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxWeight(progressData) * 1.2,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value >= 0 && value < progressData.length) {
                    final date = (progressData[value.toInt()]['date'] as DateTime?) ?? DateTime.now();
                    return Text(DateFormat('MMM d').format(date), style: const TextStyle(color: Colors.grey, fontSize: 12));
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barGroups: progressData.asMap().entries.map((entry) => BarChartGroupData(
            x: entry.key,
            barRods: [BarChartRodData(
              toY: (entry.value['weight'] as num? ?? 0).toDouble(),
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor.withOpacity(0.7), AppTheme.primaryColor],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            )],
          )).toList(),
        ),
      );
    } catch (e) {
      debugPrint('Exercise chart error: $e');
      return const Center(child: Text('No data available for this exercise'));
    }
  }

  Widget _buildWeeklyProgressChart(List<dynamic> dailyData) {
    final validData = dailyData.whereType<Map<String, dynamic>>().toList();
    if (validData.isEmpty) return const Center(child: Text('No weekly data available', style: TextStyle(color: Colors.grey)));
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxValue(validData, 'volume') * 1.2,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value >= 0 && value < validData.length) {
                  return Text(validData[value.toInt()]['day']?.toString() ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12));
                }
                return const Text('');
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barGroups: validData.asMap().entries.map((entry) => BarChartGroupData(
          x: entry.key,
          barRods: [BarChartRodData(
            toY: (entry.value['volume'] as num? ?? 0).toDouble(),
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor.withOpacity(0.7), AppTheme.primaryColor],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          )],
        )).toList(),
      ),
    );
  }

  double _getMaxValue(List<Map<String, dynamic>> data, String key) {
    try {
      return data.fold(0.0, (max, item) {
        final value = (item[key] as num?)?.toDouble() ?? 0;
        return value > max ? value : max;
      }) * 1.2;
    } catch (e) {
      return 100;
    }
  }

  double _getMaxWeight(List<Map<String, dynamic>> data) {
    try {
      return data.fold(0.0, (max, item) {
        final value = (item['weight'] as num?)?.toDouble() ?? 0;
        return value > max ? value : max;
      });
    } catch (e) {
      return 100;
    }
  }
}