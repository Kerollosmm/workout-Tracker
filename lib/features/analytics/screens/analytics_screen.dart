import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // Re-enable fl_chart
import '../../../core/providers/workout_provider.dart';
import '../../../core/providers/exercise_provider.dart';
import '../widgets/streak_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // Removed TabController and related logic
  String _selectedSegment = 'Workouts'; // Placeholder for segmented control
  String _timeFilter =
      'Monthly'; // Weekly, Monthly, All Time - Kept for now, might be reused or removed

  // Removed static of method as it's not needed without tabs

  @override
  void initState() {
    super.initState();
    // Removed TabController initialization
  }

  @override
  void dispose() {
    // Removed TabController disposal
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), // Simplified AppBar
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    // Changed return type to PreferredSizeWidget
    return AppBar(
      title: const Text('Trends'), // Updated title to 'Trends'
      // Removed bottom TabBar
      actions: [
        // Placeholder for potential future actions like a filter button
        IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: () {
            // TODO: Implement filter functionality if needed for the new design
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSegmentedControl(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 12.0),
            child: Text(
              'Current Streaks',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverGrid.count(
            // shrinkWrap: true, // Not needed for SliverGrid
            // physics: const NeverScrollableScrollPhysics(), // Not needed for SliverGrid
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio:
                (MediaQuery.of(context).size.width / 2 - 22) /
                130, // Adjust aspect ratio as needed
            children: [
              const StreakCard(
                title: 'Workouts per week',
                value: '3',
                subValue: 'Goal: 5 days',
                icon: Icons.fitness_center,
                iconColor: Colors.orangeAccent,
              ),
              const StreakCard(
                title: 'Perfect Weeks (Move)',
                value: '5',
                subValue: 'Current Streak',
                icon: Icons.local_fire_department,
                iconColor: Colors.redAccent,
              ),
              const StreakCard(
                title: 'Perfect Weeks (Exer.)',
                value: '2',
                subValue: 'Current Streak',
                icon: Icons.directions_run,
                iconColor: Colors.greenAccent,
              ),
              const StreakCard(
                title: 'Perfect Weeks (Stand)',
                value: '8',
                subValue: 'Current Streak',
                icon: Icons.accessibility_new,
                iconColor: Colors.blueAccent,
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSelectedChart(),
          ),
        ),
        SliverToBoxAdapter(
          child: const SizedBox(height: 20), // Add some padding at the bottom
        ),
      ],
    );
  }

  Widget _buildSelectedChart() {
    switch (_selectedSegment) {
      case 'Workouts':
        return _buildWorkoutTrendChart();
      case 'Body Fat %':
        return _buildBodyFatTrendChart(); // Call new method
      case 'Bodyweight':
        return _buildBodyweightTrendChart(); // Call new method
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWorkoutTrendChart() {
    // Placeholder data for the workout trend chart
    final List<FlSpot> spots = [
      const FlSpot(0, 3), // Week 1, 3 workouts
      const FlSpot(1, 5), // Week 2, 5 workouts
      const FlSpot(2, 2), // Week 3, 2 workouts
      const FlSpot(3, 4), // Week 4, 4 workouts
      const FlSpot(4, 3), // Week 5, 3 workouts
      const FlSpot(5, 5), // Week 6, 5 workouts
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workout Volume Over Time',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200, // Define a height for the chart container
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) {
                  return const FlLine(color: Colors.white10, strokeWidth: 1);
                },
                getDrawingVerticalLine: (value) {
                  return const FlLine(color: Colors.white10, strokeWidth: 1);
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      // Placeholder labels for weeks
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'W${value.toInt() + 1}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                    interval: 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      );
                    },
                    interval: 1, // Adjust based on data range
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.white24, width: 1),
              ),
              minX: 0,
              maxX: spots.length - 1.0,
              minY: 0,
              maxY:
                  spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) *
                  1.2, // Adjust maxY based on data
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyFatTrendChart() {
    // Placeholder data for the body fat trend chart
    final List<FlSpot> spots = [
      const FlSpot(0, 15.5), // Month 1, 15.5%
      const FlSpot(1, 15.2), // Month 2, 15.2%
      const FlSpot(2, 14.8), // Month 3, 14.8%
      const FlSpot(3, 14.9), // Month 4, 14.9%
      const FlSpot(4, 14.5), // Month 5, 14.5%
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Body Fat % Over Time',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine:
                    (value) =>
                        const FlLine(color: Colors.white10, strokeWidth: 1),
                getDrawingVerticalLine:
                    (value) =>
                        const FlLine(color: Colors.white10, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget:
                        (value, meta) => Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'M${value.toInt() + 1}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    interval: 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget:
                        (value, meta) => Text(
                          '${value.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                    interval: 0.5, // Adjust based on data range
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.white24, width: 1),
              ),
              minX: 0,
              maxX: spots.length - 1.0,
              minY: spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 1,
              maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 1,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.purpleAccent, // Different color for this chart
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.purpleAccent.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyweightTrendChart() {
    // Placeholder data for the bodyweight trend chart
    final List<FlSpot> spots = [
      const FlSpot(0, 70.2), // Month 1, 70.2 kg
      const FlSpot(1, 69.8), // Month 2, 69.8 kg
      const FlSpot(2, 69.5), // Month 3, 69.5 kg
      const FlSpot(3, 70.0), // Month 4, 70.0 kg
      const FlSpot(4, 69.2), // Month 5, 69.2 kg
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bodyweight Over Time',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine:
                    (value) =>
                        const FlLine(color: Colors.white10, strokeWidth: 1),
                getDrawingVerticalLine:
                    (value) =>
                        const FlLine(color: Colors.white10, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget:
                        (value, meta) => Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'M${value.toInt() + 1}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    interval: 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget:
                        (value, meta) => Text(
                          '${value.toStringAsFixed(1)}kg',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                    interval: 0.5, // Adjust based on data range
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.white24, width: 1),
              ),
              minX: 0,
              maxX: spots.length - 1.0,
              minY: spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 1,
              maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 1,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.tealAccent, // Different color for this chart
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.tealAccent.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedControl() {
    // Placeholder for the segmented control (Workouts, Body Fat %, Bodyweight, Sleep)
    // This could be implemented using CupertinoSegmentedControl or a custom Row of ToggleButtons/Chips
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSegmentChip('Workouts', _selectedSegment == 'Workouts'),
          _buildSegmentChip('Body Fat %', _selectedSegment == 'Body Fat %'),
          _buildSegmentChip('Bodyweight', _selectedSegment == 'Bodyweight'),
          // _buildSegmentChip('Sleep', _selectedSegment == 'Sleep'), // Sleep might be out of scope for now
        ],
      ),
    );
  }

  Widget _buildSegmentChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedSegment = label;
            // TODO: Update content based on selected segment
          });
        }
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color:
            isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  // Removed _buildFilterChip as it was tied to the old structure
  // Removed _buildPerformanceChart as it will be refactored and moved
  // Removed _getMuscleGroupSections and _getMuscleGroupColor as they were part of _MuscleGroupsTab
}

// Removed _PerformanceTab and _MuscleGroupsTab classes as their content will be integrated into the new _buildBody
// It's better to create new, focused widgets for the Figma design elements (Streak Cards, specific charts)
