import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../core/providers/exercise_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedExerciseId;
  String _timeFilter = 'Monthly'; // Weekly, Monthly, All Time

  static _AnalyticsScreenState of(BuildContext context) {
    return context.findAncestorStateOfType<_AnalyticsScreenState>()!;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 48),
        child: _buildAppBar(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: const Text('Analytics'),
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Performance'),
          Tab(text: 'Muscle Groups'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: const [
        _PerformanceTab(),
        _MuscleGroupsTab(),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _timeFilter = label;
          });
        }
      },
    );
  }

  Widget _buildPerformanceChart(WorkoutProvider provider, String exerciseId) {
    // Determine how many data points to fetch based on filter
    int limit;
    switch (_timeFilter) {
      case 'Weekly':
        limit = 7;
        break;
      case 'Monthly':
        limit = 30;
        break;
      case 'All Time':
      default:
        limit = 100; // Just get all available points
        break;
    }

    final data = provider.getExerciseProgressData(exerciseId, limit: limit);

    if (data.isEmpty) {
      return const Center(child: Text('No data available for this exercise'));
    }

    // Transform to chart data points
    final spots = data.map((point) {
      // X-axis is the index (0, 1, 2, ...), Y-axis is the weight
      final index = data.indexOf(point).toDouble();
      return FlSpot(index, point['weight'] as double);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: 0,
        maxX: spots.length - 1.0,
        minY: 0,
        maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 0,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getMuscleGroupSections(Map<String, double> muscleGroups) {
    return muscleGroups.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: '${(entry.value * 100).toStringAsFixed(1)}%',
        color: _getMuscleGroupColor(entry.key),
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getMuscleGroupColor(String muscleGroup) {
    // Add more colors as needed
    final colors = {
      'Chest': Colors.blue,
      'Back': Colors.green,
      'Legs': Colors.red,
      'Shoulders': Colors.orange,
      'Arms': Colors.purple,
      'Core': Colors.teal,
    };
    return colors[muscleGroup] ?? Colors.grey;
  }
}

class _PerformanceTab extends StatefulWidget {
  const _PerformanceTab({Key? key}) : super(key: key);

  @override
  __PerformanceTabState createState() => __PerformanceTabState();
}

class __PerformanceTabState extends State<_PerformanceTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<ExerciseProvider>(
            builder: (context, provider, _) {
              final exercises = provider.exercises;
              if (_AnalyticsScreenState.of(context)._selectedExerciseId == null && exercises.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => setState(() => _AnalyticsScreenState.of(context)._selectedExerciseId = exercises.first.id),
                );
              }
              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Exercise',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                value: _AnalyticsScreenState.of(context)._selectedExerciseId,
                items: exercises
                    .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                    .toList(),
                onChanged: (value) => setState(() => _AnalyticsScreenState.of(context)._selectedExerciseId = value),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AnalyticsScreenState.of(context)._buildFilterChip('Weekly', _AnalyticsScreenState.of(context)._timeFilter == 'Weekly'),
              const SizedBox(width: 8),
              _AnalyticsScreenState.of(context)._buildFilterChip('Monthly', _AnalyticsScreenState.of(context)._timeFilter == 'Monthly'),
              const SizedBox(width: 8),
              _AnalyticsScreenState.of(context)._buildFilterChip('All Time', _AnalyticsScreenState.of(context)._timeFilter == 'All Time'),
            ],
          ),
        ),
        if (_AnalyticsScreenState.of(context)._selectedExerciseId != null)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<WorkoutProvider>(
                builder: (context, provider, _) {
                  final id = _AnalyticsScreenState.of(context)._selectedExerciseId!;
                  return _AnalyticsScreenState.of(context)._buildPerformanceChart(provider, id);
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _MuscleGroupsTab extends StatelessWidget {
  const _MuscleGroupsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, _) {
        final muscleGroups = provider.getMuscleGroupDistribution();
        if (muscleGroups.isEmpty) {
          return const Center(child: Text('No workout data available'));
        }
        // Convert int values to double
        final muscleGroupsDouble = Map<String, double>.fromEntries(
          muscleGroups.entries.map((e) => MapEntry(e.key, e.value.toDouble())),
        );
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: _AnalyticsScreenState.of(context)._getMuscleGroupSections(muscleGroupsDouble),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: muscleGroups.entries.map((entry) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        color: _AnalyticsScreenState.of(context)._getMuscleGroupColor(entry.key),
                      ),
                      const SizedBox(width: 4),
                      Text('${entry.key} (${(entry.value * 100).toStringAsFixed(1)}%)'),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
