import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:workout_tracker/config/constants/app_constants.dart';
import '../../../config/themes/app_theme.dart';
import '../../../core/providers/settings_provider.dart';

class PerformanceChartProgress extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final String valueUnit;
  final Color? lineColor;
  final double? maxY;
  final bool showAverageLine;

  const PerformanceChartProgress({
    super.key,
    required this.data,
    required this.title,
    required this.valueUnit,
    this.lineColor,
    this.maxY,
    this.showAverageLine = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = Provider.of<SettingsProvider>(context);
    final chartColor = lineColor ?? theme.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            title,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        _buildChartContainer(theme, chartColor, settings),
      ],
    );
  }

  Widget _buildChartContainer(
    ThemeData theme,
    Color chartColor,
    SettingsProvider settings,
  ) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: data.isEmpty
          ? Center(
              child: Text(
                'No data available',
                style: theme.textTheme.bodyLarge,
              ),
            )
          : LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.brightness == Brightness.dark 
                      ? Colors.grey[800]! 
                      : Colors.grey[300]!,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: _buildTitlesData(settings),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: data.length > 1 ? (data.length - 1).toDouble() : 1,
                minY: 0,
                maxY: _calculateMaxY(),
                lineBarsData: _buildChartLines(chartColor, theme),
                lineTouchData: _buildTouchData(settings),
                backgroundColor: theme.cardColor,
              ),
            ),
    );
  }

  FlTitlesData _buildTitlesData(SettingsProvider settings) {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: 1,
          getTitlesWidget: (value, meta) => _buildDateTitle(value, meta),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 45,
          interval: _calculateMaxY() / 5,
          getTitlesWidget: (value, meta) => _buildValueTitle(value, settings, meta),
        ),
      ),
    );
  }

  Widget _buildDateTitle(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= data.length) return const SizedBox.shrink();
    
    final date = data[index]['date'] as DateTime;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SideTitleWidget(
        meta: meta,
        child: Text(
          DateFormat('MMM d').format(date),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondaryLight.withAlpha(179),
          ),
        ),
      ),
    );
  }

  Widget _buildValueTitle(double value, SettingsProvider settings, TitleMeta meta) {
    return SideTitleWidget(
      meta: meta,
      child: Text(
        '${value.toStringAsFixed(settings.weightUnit == 'kg' ? 1 : 0)}$valueUnit',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.textSecondaryLight.withAlpha(179),
        ),
      ),
    );
  }

  List<LineChartBarData> _buildChartLines(Color chartColor, ThemeData theme) {
    final spots = data.asMap().entries.map((entry) {
      final value = (entry.value['value'] as num).toDouble();
      return FlSpot(entry.key.toDouble(), value);
    }).toList();

    final lines = [
      LineChartBarData(
        spots: spots,
        isCurved: true,
        color: chartColor,
        barWidth: 2.5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, chart, index) => FlDotCirclePainter(
            radius: 4,
            color: theme.cardColor,
            strokeWidth: 2,
            strokeColor: chartColor,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              chartColor.withAlpha(77),
              chartColor.withAlpha(13),
            ],
            stops: const [0.0, 0.8],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ];

    if (showAverageLine) {
      final average = data.isEmpty 
          ? 0.0 
          : data.map((e) => (e['value'] as num).toDouble())
              .reduce((a, b) => a + b) / data.length;
      
      lines.add(
        LineChartBarData(
          spots: [
            FlSpot(0, average),
            FlSpot((data.length - 1).toDouble(), average)
          ],
          color: chartColor.withAlpha(128),
          barWidth: 1,
          dashArray: const [5, 5],
          isCurved: false,
          dotData: const FlDotData(show: false),
        ),
      );
    }

    return lines;
  }

  LineTouchData _buildTouchData(SettingsProvider settings) {
    return LineTouchData(
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipBorder: BorderSide(color: AppTheme.primaryColor.withAlpha(26)),
        tooltipRoundedRadius: 8,
        tooltipPadding: const EdgeInsets.all(8),
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
          final index = spot.x.toInt();
          final date = data[index]['date'] as DateTime;
          return LineTooltipItem(
            '${DateFormat.yMMMd().format(date)}\n'
            '${spot.y.toStringAsFixed(settings.weightUnit == 'kg' ? 1 : 0)}$valueUnit',
            const TextStyle(
              color: AppTheme.textPrimaryLight,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          );
        }).toList(),
      ),
    );
  }

  double _calculateMaxY() {
    if (maxY != null) return maxY!;
    if (data.isEmpty) return 10;

    final maxValue = data.map((e) => e['value'] as double).reduce(
      (a, b) => a > b ? a : b);
    return maxValue * 1.2;
  }
}
