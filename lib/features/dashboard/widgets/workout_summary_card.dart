import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/models/workout.dart'; // Keep if workout prop is still used, otherwise remove
import '../../../core/providers/settings_provider.dart'; // Keep if settingsProvider is still used
import '../providers/dashboard_provider.dart'; // Import DashboardProvider

class WorkoutSummaryCard extends StatefulWidget {
  // final Workout workout; // Workout prop might not be needed if data comes from DashboardProvider
  final VoidCallback? onTap;

  const WorkoutSummaryCard({
    Key? key,
    // required this.workout, // Workout prop might not be needed
    this.onTap,
  }) : super(key: key);

  @override
  State<WorkoutSummaryCard> createState() => _WorkoutSummaryCardState();
}

class _WorkoutSummaryCardState extends State<WorkoutSummaryCard> {
  // _metrics might not be needed if we directly use provider data in build
  // late Map<String, dynamic> _metrics; 

  // initState and didUpdateWidget might not be needed if we fetch data in build method directly from provider
  // @override
  // void initState() {
  //   super.initState();
  //   // _calculateMetrics(); // We will get data from provider
  // }

  // @override
  // void didUpdateWidget(WorkoutSummaryCard oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   // if (oldWidget.workout != widget.workout) { // Condition might change based on how data is passed
  //   //   // _calculateMetrics();
  //   // }
  // }

  // _calculateMetrics might be replaced by directly accessing provider data
  // void _calculateMetrics() { ... }

  Widget _buildProgressIndicator({
    required double value,
    required Color color,
    required IconData icon,
    required String label,
    required String sublabel,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: value.clamp(0.0, 1.0),
                strokeWidth: 8,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Icon(icon, color: color, size: 24),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          sublabel,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // final settingsProvider = Provider.of<SettingsProvider>(context); // Keep if needed
    // final dateFormat = DateFormat('MMM dd, yyyy'); // Keep if needed
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final activityData = dashboardProvider.getActivityRingData(DateTime.now());

    final moveCurrent = activityData['moveCurrent'] ?? 0.0;
    final moveGoal = activityData['moveGoal'] ?? 1.0;
    final exerciseCurrent = activityData['exerciseCurrent'] ?? 0.0;
    final exerciseGoal = activityData['exerciseGoal'] ?? 1.0;
    final standCurrent = activityData['standCurrent'] ?? 0.0;
    final standGoal = activityData['standGoal'] ?? 1.0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: const Color(0xFF1C1C1E),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // Changed for better spacing
              children: [
                _buildProgressIndicator(
                  value: moveGoal == 0 ? 0 : moveCurrent / moveGoal,
                  color: const Color(0xFFE53935), // Red for Move
                  icon: Icons.local_fire_department, // Example icon for Move
                  label: '${moveCurrent.toInt()}/${moveGoal.toInt()}',
                  sublabel: 'Move',
                ),
                _buildProgressIndicator(
                  value: exerciseGoal == 0 ? 0 : exerciseCurrent / exerciseGoal,
                  color: const Color(0xFF7CB342), // Green for Exercise
                  icon: Icons.fitness_center, // Example icon for Exercise
                  label: '${exerciseCurrent.toInt()}/${exerciseGoal.toInt()}',
                  sublabel: 'Exercise',
                ),
                _buildProgressIndicator(
                  value: standGoal == 0 ? 0 : standCurrent / standGoal,
                  color: const Color(0xFF03A9F4), // Blue for Stand
                  icon: Icons.accessibility_new, // Example icon for Stand
                  label: '${standCurrent.toInt()}/${standGoal.toInt()}',
                  sublabel: 'Stand',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
