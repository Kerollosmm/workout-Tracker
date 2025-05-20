import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../providers/dashboard_provider.dart';

class ActivitySummaryWidget extends StatelessWidget {
  const ActivitySummaryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final today = DateTime.now();
    final dailyStats = dashboardProvider.getDailyStats(today);

    // Check if we should suggest weight increase
    final shouldSuggestIncrease = userProvider.shouldSuggestWeightIncrease(
      workoutProvider,
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Activity', style: Theme.of(context).textTheme.titleLarge),
                if (shouldSuggestIncrease)
                  Tooltip(
                    message: 'Weight increase suggested',
                    child: Icon(Icons.trending_up, color: Colors.green),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActivityMetric(
                  context,
                  label: 'Move',
                  value: '${(dailyStats['caloriesBurned'] ?? 0).toInt()}',
                  target: '600',
                  unit: 'CAL',
                  progress: (dailyStats['caloriesBurned'] ?? 0) / 600,
                  color: Colors.pink,
                ),
                _buildActivityMetric(
                  context,
                  label: 'Exercise',
                  value: '${(dailyStats['minutesExercised'] ?? 0).toInt()}',
                  target: '30',
                  unit: 'MIN',
                  progress: (dailyStats['minutesExercised'] ?? 0) / 30,
                  color: Colors.green,
                ),
                _buildActivityMetric(
                  context,
                  label: 'Stand',
                  value: '${(dailyStats['standHours'] ?? 0).toInt()}',
                  target: '8',
                  unit: 'HRS',
                  progress: (dailyStats['standHours'] ?? 0) / 8,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricTile(
                  context,
                  label: 'Steps',
                  value: '${(dailyStats['steps'] ?? 0).toInt()}',
                ),
                _buildMetricTile(
                  context,
                  label: 'Distance',
                  value: '${(dailyStats['distance'] ?? 0.0).toStringAsFixed(1)} Mi',
                ),
              ],
            ),
            if (shouldSuggestIncrease) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.amber[800]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Based on your progress, consider increasing your training weight by 10% for optimal growth.',
                        style: TextStyle(color: Colors.amber[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityMetric(
    BuildContext context, {
    required String label,
    required String value,
    required String target,
    required String unit,
    required double progress,
    required Color color,
  }) {
    final cappedProgress = progress > 1.0 ? 1.0 : progress;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: cappedProgress,
                strokeWidth: 10,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.black,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          '$value/$target$unit',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
