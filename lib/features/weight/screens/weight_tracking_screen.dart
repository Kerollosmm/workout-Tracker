import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/body_data_provider.dart';
import '../../../core/models/body_data.dart';

class WeightTrackingScreen extends StatefulWidget {
  const WeightTrackingScreen({Key? key}) : super(key: key);

  @override
  State<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends State<WeightTrackingScreen> {
  String _selectedTimeRange = 'Day';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FA),
      appBar: AppBar(
        title: const Text('Weight',
          style: TextStyle(color: Color(0xFF2D3142)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Color(0xFF2D3142)),
            onPressed: () {
              // Navigate to detailed view
            },
          ),
        ],
      ),
      body: Consumer<BodyDataProvider>(
        builder: (context, bodyDataProvider, child) {
          final entries = bodyDataProvider.entries;
          final latestEntry = entries.isNotEmpty ? entries.first : null;
          final startingWeight = entries.isNotEmpty ? entries.last.weight : 0;
          final goalWeight = 95.0; // This should come from settings

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWeightCard((latestEntry?.weight ?? 0).toDouble(), startingWeight, goalWeight),
                  const SizedBox(height: 24),
                  _buildTimeRangeSelector(),
                  const SizedBox(height: 24),
                  _buildWeightChart(entries, goalWeight),
                  const SizedBox(height: 24),
                  _buildImportButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeightCard(num currentWeight, num startingWeight, num goalWeight) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1.0,
            blurRadius: 4.0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weight',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF2D3142),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currentWeight.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'kg',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF2D3142),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Starting: ${startingWeight.toStringAsFixed(1)} kg',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              Text(
                'Goal: ${goalWeight.toStringAsFixed(1)} kg',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: ['Day', 'Week', 'Month'].map((range) {
          final isSelected = _selectedTimeRange == range;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTimeRange = range),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2D3142) : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  range,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF2D3142),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeightChart(List<BodyData> entries, double goalWeight) {
    if (entries.isEmpty) {
      return const Center(
        child: Text('No weight data available'),
      );
    }

    final spots = entries.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.weight,
      );
    }).toList();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 3,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < entries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('d').format(entries[value.toInt()].date),
                        style: const TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
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
                      color: Color(0xFF9E9E9E),
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF2D3142),
              barWidth: 2,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: const Color(0xFF2D3142),
                  );
                },
              ),
            ),
            // Goal weight line
            LineChartBarData(
              spots: [
                FlSpot(0, goalWeight),
                FlSpot(entries.length.toDouble() - 1, goalWeight),
              ],
              color: const Color(0xFFFFA726),
              barWidth: 1,
              dotData: FlDotData(show: false),
              dashArray: [5, 5],
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpots) => Colors.black.withOpacity(0.8),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              tooltipRoundedRadius: 4.0,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot spot) {
                  return LineTooltipItem(
                    '${(spot.y as num).toDouble().toString()} kg',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImportButton() {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          // Implement import functionality
        },
        icon: const Icon(
          Icons.sync,
          color: Color(0xFF2D3142),
        ),
        label: const Text(
          'Import data',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontSize: 16,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }
} 