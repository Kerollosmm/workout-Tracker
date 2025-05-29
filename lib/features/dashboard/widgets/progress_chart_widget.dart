import 'package:activity_ring/activity_ring.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../config/themes/app_theme.dart';
import '../providers/dashboard_provider.dart';

class ProgressChartWidget extends StatefulWidget {
  const ProgressChartWidget({super.key});

  @override
  State<ProgressChartWidget> createState() => _ProgressChartWidgetState();
}

class _ProgressChartWidgetState extends State<ProgressChartWidget> {
  Widget _buildTopBar(BuildContext context, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Row(
            children: [
              Text(
                DateFormat('MMMM d').format(DateTime.now()),
                style: TextStyle(fontSize: 16, color: textColor.withAlpha(180)),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRing(
    BuildContext context,
    String day,
    double movePercent,
    double exercisePercent,
    double standPercent,
    bool isToday,
  ) {
    const ringRadius = 20.0;
    const ringWidth = 4.0;
    // Updated 2025-05-29: Simplified for dark theme only
    final dayTextColor =
        isToday
            ? AppTheme
                .accentTextColor // Use accent for 'today' to make it pop
            : AppTheme.secondaryTextColor;

    final Color moveColorDaily = Colors.pinkAccent.shade100;
    final Color exerciseColorDaily = Colors.lightGreenAccent.shade200;
    final Color standColorDaily = Colors.lightBlueAccent.shade100;

    final Color moveBgColorDaily = moveColorDaily.withAlpha(
      (0.2 * 255).round(),
    );
    final Color exerciseBgColorDaily = exerciseColorDaily.withAlpha(
      (0.2 * 255).round(),
    );
    final Color standBgColorDaily = standColorDaily.withAlpha(
      (0.2 * 255).round(),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          day,
          style: TextStyle(
            color: dayTextColor,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: ringRadius * 2,
          height: ringRadius * 2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Ring(
                percent: 100,
                color: RingColorScheme(
                  ringColor: moveBgColorDaily,
                  backgroundColor: Colors.transparent,
                ),
                radius: ringRadius,
                width: ringWidth,
              ),
              Ring(
                percent: 100,
                color: RingColorScheme(
                  ringColor: exerciseBgColorDaily,
                  backgroundColor: Colors.transparent,
                ),
                radius: ringRadius - ringWidth - 1,
                width: ringWidth,
              ),
              Ring(
                percent: 100,
                color: RingColorScheme(
                  ringColor: standBgColorDaily,
                  backgroundColor: Colors.transparent,
                ),
                radius: ringRadius - (ringWidth * 2) - 2,
                width: ringWidth,
              ),
              if (movePercent > 0)
                Ring(
                  percent: movePercent * 100,
                  color: RingColorScheme(
                    ringColor: moveColorDaily,
                    backgroundColor: Colors.transparent,
                  ),
                  radius: ringRadius,
                  width: ringWidth,
                ),
              if (exercisePercent > 0)
                Ring(
                  percent: exercisePercent * 100,
                  color: RingColorScheme(
                    ringColor: exerciseColorDaily,
                    backgroundColor: Colors.transparent,
                  ),
                  radius: ringRadius - ringWidth - 1,
                  width: ringWidth,
                ),
              if (standPercent > 0)
                Ring(
                  percent: standPercent * 100,
                  color: RingColorScheme(
                    ringColor: standColorDaily,
                    backgroundColor: Colors.transparent,
                  ),
                  radius: ringRadius - (ringWidth * 2) - 2,
                  width: ringWidth,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklySummaryRings(
    BuildContext context,
    DashboardProvider dashboardProvider,
  ) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(days.length, (index) {
          final dayDate = weekStart.add(Duration(days: index));
          final activityData = dashboardProvider.getActivityRingData(dayDate);

          final movePercent =
              (activityData['moveCurrent'] ?? 0.0) /
              (activityData['moveGoal'] ?? 1.0);
          final exercisePercent =
              (activityData['exerciseCurrent'] ?? 0.0) /
              (activityData['exerciseGoal'] ?? 1.0);
          final standPercent =
              (activityData['standCurrent'] ?? 0.0) /
              (activityData['standGoal'] ?? 1.0);

          bool isTodayDate =
              dayDate.year == today.year &&
              dayDate.month == today.month &&
              dayDate.day == today.day;

          return _buildDailyRing(
            context,
            days[index],
            movePercent.clamp(0.0, 1.0),
            exercisePercent.clamp(0.0, 1.0),
            standPercent.clamp(0.0, 1.0),
            isTodayDate,
          );
        }),
      ),
    );
  }

  Widget _buildMainProgressRings(
    BuildContext context,
    DashboardProvider dashboardProvider,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final ringRadius = screenWidth * 0.35;
    final ringWidth = screenWidth * 0.08;

    final activityData = dashboardProvider.getActivityRingData(DateTime.now());

    final double movePercent =
        (activityData['moveCurrent'] ?? 0.0) /
        (activityData['moveGoal'] ?? 1.0);
    final double exercisePercent =
        (activityData['exerciseCurrent'] ?? 0.0) /
        (activityData['exerciseGoal'] ?? 1.0);
    final double standPercent =
        (activityData['standCurrent'] ?? 0.0) /
        (activityData['standGoal'] ?? 1.0);

    final Color moveColor = Colors.pinkAccent.shade200;
    final Color exerciseColor = Colors.lightGreenAccent.shade400;
    final Color standColor = Colors.lightBlueAccent.shade200;

    final Color moveBgColor = moveColor.withAlpha((0.2 * 255).round());
    final Color exerciseBgColor = exerciseColor.withAlpha((0.2 * 255).round());
    final Color standBgColor = standColor.withAlpha((0.2 * 255).round());

    return SizedBox(
      width: ringRadius * 2.2,
      height: ringRadius * 2.2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Ring(
            percent: 100,
            color: RingColorScheme(
              ringColor: moveBgColor,
              backgroundColor: Colors.transparent,
            ),
            radius: ringRadius,
            width: ringWidth,
          ),
          Ring(
            percent: 100,
            color: RingColorScheme(
              ringColor: exerciseBgColor,
              backgroundColor: Colors.transparent,
            ),
            radius: ringRadius - ringWidth - (ringWidth * 0.1),
            width: ringWidth,
          ),
          Ring(
            percent: 100,
            color: RingColorScheme(
              ringColor: standBgColor,
              backgroundColor: Colors.transparent,
            ),
            radius: ringRadius - (ringWidth * 2) - (ringWidth * 0.2),
            width: ringWidth,
          ),
          Ring(
            percent: movePercent * 100,
            color: RingColorScheme(
              ringColor: moveColor,
              backgroundColor: Colors.transparent,
            ),
            radius: ringRadius,
            width: ringWidth,
            // Updated 2025-05-29: Removed child text, will be added in a central Column
          ),
          Ring(
            percent: exercisePercent * 100,
            color: RingColorScheme(
              ringColor: exerciseColor,
              backgroundColor: Colors.transparent,
            ),
            radius: ringRadius - ringWidth - (ringWidth * 0.1),
            width: ringWidth,
            // Updated 2025-05-29: Removed child text, will be added in a central Column
          ),
          Ring(
            percent: standPercent * 100,
            color: RingColorScheme(
              ringColor: standColor,
              backgroundColor: Colors.transparent,
            ),
            radius: ringRadius - (ringWidth * 2) - (ringWidth * 0.2),
            width: ringWidth,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${(activityData['moveCurrent'] ?? 0.0).toInt()}/${(activityData['moveGoal'] ?? 1.0).toInt()}',
                style: TextStyle(
                  fontSize: ringWidth * 0.35, // Slightly larger for value
                  color: moveColor, // Use the ring's main color
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'MOVE',
                style: TextStyle(
                  fontSize: ringWidth * 0.25, // Slightly smaller for label
                  color: moveColor.withAlpha(200),
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: ringWidth * 0.1), // Spacing
              Text(
                '${(activityData['exerciseCurrent'] ?? 0.0).toInt()}/${(activityData['exerciseGoal'] ?? 1.0).toInt()}',
                style: TextStyle(
                  fontSize: ringWidth * 0.35,
                  color: exerciseColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'EXERCISE',
                style: TextStyle(
                  fontSize: ringWidth * 0.25,
                  color: exerciseColor.withAlpha(200),
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: ringWidth * 0.1), // Spacing
              Text(
                '${(activityData['standCurrent'] ?? 0.0).toInt()}/${(activityData['standGoal'] ?? 1.0).toInt()}',
                style: TextStyle(
                  fontSize: ringWidth * 0.35,
                  color: standColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'STAND',
                style: TextStyle(
                  fontSize: ringWidth * 0.25,
                  color: standColor.withAlpha(200),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);

    // Updated 2025-05-29: Simplified for dark theme only
    final cardBackgroundColor = AppTheme.cardColor; // Use from AppTheme
    final textColor = AppTheme.primaryTextColor; // Use from AppTheme

    return Card(
      elevation: 2.0,
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopBar(context, textColor),
            _buildWeeklySummaryRings(context, dashboardProvider),
            _buildMainProgressRings(context, dashboardProvider),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
