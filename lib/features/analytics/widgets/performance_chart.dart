import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// import 'package:workout_tracker/config/constants/app_constants.dart'; // Removed due to name collision with themes/app_theme.dart
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
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final theme = Theme.of(context);
    final chartColor = lineColor ?? theme.colorScheme.secondary;

    if (data.isEmpty) {
      return Center(
        child: Text(
          'No data available for $title',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top:8.0, bottom: 8.0),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0, bottom: 8.0),
            child: _buildChartContainer(context, theme, chartColor, settingsProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildChartContainer(
    BuildContext context, 
    ThemeData theme,
    Color chartColor,
    SettingsProvider settings,
  ) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: _calculateMaxY(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.dividerColor.withAlpha(128), 
            strokeWidth: 1,
          ),
          horizontalInterval: _calculateInterval(),
        ),
        borderData: FlBorderData(show: false),
        titlesData: _buildTitlesData(context, settings), 
        lineBarsData: _buildChartLines(context, chartColor, theme), 
        lineTouchData: _buildTouchData(context, settings, theme), 
      ),
      duration: const Duration(milliseconds: 250),
    );
  }

  double _calculateInterval() {
    final effectiveMaxY = _calculateMaxY();
    if (effectiveMaxY <= 0) return 10;
    if (effectiveMaxY <= 10) return 2;
    if (effectiveMaxY <= 50) return 10;
    if (effectiveMaxY <= 100) return 20;
    if (effectiveMaxY <= 200) return 40;
    return 50;
  }

  // Updated 2025-05-21: Rebuilt titles data to match fl_chart 0.70.2 API
  FlTitlesData _buildTitlesData(BuildContext context, SettingsProvider settings) {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: _calculateInterval(),
          getTitlesWidget: (value, meta) => _buildValueTitle(context, value, settings, meta),
          reservedSize: 40,
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) => _buildDateTitle(context, value, meta),
          reservedSize: 25,
        ),
      ),
    );
  }

  // Updated 2025-05-21: Completely rebuilt date title function to match fl_chart 0.70.2 API
  Widget _buildDateTitle(BuildContext context, double value, TitleMeta meta) { 
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white70 : Colors.black54;
    if (value.toInt() < 0 || value.toInt() >= data.length) {
      return Container();
    }
    final date = data[value.toInt()]['date'] as DateTime;
    
    // Simple text rendering as a fallback for fl_chart 0.70.2
    return Text(
      DateFormat('MMM d').format(date),
      style: TextStyle(fontSize: 10, color: textColor),
      textAlign: TextAlign.center,
    );
  }

  // Updated 2025-05-21: Completely rebuilt value title function to match fl_chart 0.70.2 API
  Widget _buildValueTitle(BuildContext context, double value, SettingsProvider settings, TitleMeta meta) { 
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white70 : Colors.black54;
    // Basic filtering for cleaner axis
    if (value == 0 && meta.max > 0) return Container(); // Don't show 0 if there are positive values
    if (value == meta.max && data.length > 1) return Container(); // Avoid showing max value label if it's too close to others

    // Simple text rendering as a fallback for fl_chart 0.70.2
    return Text(
      value.toStringAsFixed(settings.weightUnit == 'kg' ? 1 : 0),
      style: TextStyle(fontSize: 10, color: textColor),
      textAlign: TextAlign.right,
    );
  }

  List<LineChartBarData> _buildChartLines(BuildContext context, Color chartColor, ThemeData theme) { 
    final spots = List.generate(data.length, (index) {
      final yValue = (data[index]['value'] as num?)?.toDouble() ?? 0.0;
      return FlSpot(index.toDouble(), yValue);
    });

    final averageValue = showAverageLine && spots.isNotEmpty
        ? spots.map((spot) => spot.y).reduce((a, b) => a + b) / spots.length
        : null;

    List<LineChartBarData> lines = [
      LineChartBarData(
        spots: spots,
        isCurved: true,
        color: chartColor,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: chartColor.withOpacity(0.15),
        ),
      ),
    ];

    if (averageValue != null) {
      lines.add(
        LineChartBarData(
          spots: [
            FlSpot(0, averageValue),
            FlSpot((data.length - 1).toDouble(), averageValue),
          ],
          color: theme.hintColor.withOpacity(0.7),
          barWidth: 2,
          dashArray: [4, 4],
          dotData: const FlDotData(show: false),
        ),
      );
    }

    return lines;
  }

  LineTouchData _buildTouchData(BuildContext context, SettingsProvider settings, ThemeData theme) { 
    // Updated 2025-05-21: Rebuilt LineTouchData to match fl_chart 0.70.2 API
    return LineTouchData(
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        // In fl_chart 0.70.2, using getTooltipColor instead of tooltipBgColor
        getTooltipColor: (_) => theme.cardColor.withAlpha(230),
        tooltipBorder: BorderSide(color: AppTheme.primaryColor.withAlpha(100)),
        tooltipRoundedRadius: AppTheme.borderRadius_m,
        tooltipPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing_s, vertical: AppTheme.spacing_xs),
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
          final index = spot.x.toInt();
          if (index < 0 || index >= data.length) return null;
          final date = data[index]['date'] as DateTime;
          final isDarkMode = Theme.of(context).brightness == Brightness.dark; 
          final tooltipTextColor = isDarkMode ? Colors.white : Colors.black87;

          return LineTooltipItem(
            '${DateFormat.yMMMd().format(date)}\n'
            '${spot.y.toStringAsFixed(settings.weightUnit == 'kg' ? 1 : 0)}$valueUnit',
            TextStyle(
              color: tooltipTextColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          );
        }).where((item) => item != null).toList().cast<LineTooltipItem>(),
      ),
      getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
        return spotIndexes.map((index) {
          return TouchedSpotIndicatorData(
            FlLine(color: barData.color ?? AppTheme.primaryColor, strokeWidth: 2),
            FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 5,
                color: barData.color ?? AppTheme.primaryColor,
                strokeWidth: 1.5,
                strokeColor: theme.scaffoldBackgroundColor, 
              ),
            ),
          );
        }).toList();
      },
    );
  }

  double _calculateMaxY() {
    if (maxY != null) return maxY!;
    if (data.isEmpty) return 10.0; 
    double maxVal = 0;
    for (var item in data) {
      final val = (item['value'] as num?)?.toDouble() ?? 0.0;
      if (val > maxVal) maxVal = val;
    }
    if (showAverageLine && data.isNotEmpty) {
      final averageValue = data.map((item) => (item['value'] as num?)?.toDouble() ?? 0.0).reduce((a, b) => a + b) / data.length;
      if (averageValue > maxVal) maxVal = averageValue;
    }
    return maxVal == 0 ? 10.0 : (maxVal * 1.2).ceilToDouble(); 
  }
}
