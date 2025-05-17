import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/body_data.dart';

class BodyDataChart extends StatelessWidget {
  final List<BodyData> entries;
  final String metric; // 'weight', 'height', or 'bmi'

  const BodyDataChart({Key? key, required this.entries, required this.metric}) : super(key: key);

  List<FlSpot> _getSpots() {
    return entries.reversed.toList().asMap().entries.map((entry) {
      final idx = entry.key.toDouble();
      double value;
      switch (metric) {
        case 'weight':
          value = entry.value.weight;
          break;
        case 'height':
          value = entry.value.height;
          break;
        case 'bmi':
          value = entry.value.height > 0 ? entry.value.weight / (entry.value.height * entry.value.height) : 0;
          break;
        default:
          value = 0;
      }
      return FlSpot(idx, value);
    }).toList();
  }

  double _minY() {
    if (entries.isEmpty) return 0;
    final values = entries.map((e) {
      switch (metric) {
        case 'weight':
          return e.weight;
        case 'height':
          return e.height;
        case 'bmi':
          return e.weight / (e.height * e.height);
        default:
          return 0.0;
      }
    }).toList();
    return (values.reduce((a, b) => a < b ? a : b) * 0.95);
  }

  double _maxY() {
    if (entries.isEmpty) return 0;
    final values = entries.map((e) {
      switch (metric) {
        case 'weight':
          return e.weight;
        case 'height':
          return e.height;
        case 'bmi':
          return e.weight / (e.height * e.height);
        default:
          return 0.0;
      }
    }).toList();
    return (values.reduce((a, b) => a > b ? a : b) * 1.05);
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(child: Text('No data to display'));
    }
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: _getSpots(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
            ),
          ],
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(1)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= entries.length) return const Text('');
                  final date = entries.reversed.toList()[index].date;
                  return Text('${date.day}/${date.month}');
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            ),
          ),
          minX: 0,
          maxX: entries.length.toDouble() - 1,
          minY: _minY(),
          maxY: _maxY(),
        ),
      ),
    );
  }
} 