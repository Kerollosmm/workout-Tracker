import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../shared/widgets/ios_style/index.dart';
import '../../../shared/widgets/ios_style/activity_rings.dart';

// Updated 2025-05-20: Created iOS-style summary screen that mimics iOS fitness app design
class IOSSummaryScreen extends StatefulWidget {
  const IOSSummaryScreen({Key? key}) : super(key: key);

  @override
  State<IOSSummaryScreen> createState() => _IOSSummaryScreenState();
}

class _IOSSummaryScreenState extends State<IOSSummaryScreen> {
  int _selectedTabIndex = 0;

  // Mock data for the activity metrics
  final Map<String, dynamic> _activityData = {
    'move': {
      'current': 600,
      'goal': 900,
      'percentage': 0.67,
      'unit': 'CAL'
    },
    'exercise': {
      'current': 42,
      'goal': 30,
      'percentage': 1.4, // Over 100% is capped in the UI
      'unit': 'MIN'
    },
    'stand': {
      'current': 10,
      'goal': 12,
      'percentage': 0.83,
      'unit': 'HRS'
    },
    'steps': 8712,
    'distance': 3.81,
    'distanceUnit': 'MI',
  };

  // Mock data for workout history
  final List<Map<String, dynamic>> _workoutHistory = [
    {
      'type': 'Outdoor Walk',
      'distance': 0.57,
      'unit': 'MI',
      'date': 'Today',
    },
    {
      'type': 'Outdoor Walk',
      'distance': 1.51,
      'unit': 'MI',
      'date': 'Sunday',
    },
    {
      'type': 'Outdoor Walk',
      'distance': 0.69,
      'unit': 'MI',
      'date': 'Sunday',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : const Color(0xFFF2F2F7);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode 
        ? Colors.white.withOpacity(0.6) 
        : Colors.black.withOpacity(0.6);
    final cardColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Stack(
          children: [
            // Main content
            CustomScrollView(
              slivers: [
                // Header section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MONDAY, JUN 12',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Summary',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.accentBlue,
                              child: Text(
                                'JD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Activity',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Activity rings card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          // Left side - activity metrics
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildActivityMetric(
                                  'Move',
                                  _activityData['move']['current'],
                                  _activityData['move']['goal'],
                                  _activityData['move']['unit'],
                                  const Color(0xFFFF375F),
                                  textColor,
                                  secondaryTextColor,
                                ),
                                const SizedBox(height: 12),
                                _buildActivityMetric(
                                  'Exercise',
                                  _activityData['exercise']['current'],
                                  _activityData['exercise']['goal'],
                                  _activityData['exercise']['unit'],
                                  const Color(0xFF75FB4C),
                                  textColor,
                                  secondaryTextColor,
                                ),
                                const SizedBox(height: 12),
                                _buildActivityMetric(
                                  'Stand',
                                  _activityData['stand']['current'],
                                  _activityData['stand']['goal'],
                                  _activityData['stand']['unit'],
                                  const Color(0xFF33E5F7),
                                  textColor,
                                  secondaryTextColor,
                                ),
                              ],
                            ),
                          ),
                          
                          // Right side - activity rings
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: ActivityRings(
                              movePercentage: _activityData['move']['percentage'] > 1 
                                  ? 1 : _activityData['move']['percentage'],
                              exercisePercentage: _activityData['exercise']['percentage'] > 1 
                                  ? 1 : _activityData['exercise']['percentage'],
                              standPercentage: _activityData['stand']['percentage'] > 1 
                                  ? 1 : _activityData['stand']['percentage'],
                              size: 160,
                              strokeWidth: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Steps and distance
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Steps',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _activityData['steps'].toString(),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Distance',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_activityData['distance']} ${_activityData['distanceUnit']}',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // History section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'History',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Text(
                            'Show More',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.accentGreen,
                            ),
                          ),
                          onPressed: () {
                            // Navigate to detailed history
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Workout history list
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final workout = _workoutHistory[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.accentGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  CupertinoIcons.person_crop_circle_fill,
                                  color: AppColors.accentGreen,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      workout['type'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${workout['distance']} ${workout['unit']}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.accentGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    workout['date'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Icon(
                                    CupertinoIcons.right_chevron,
                                    size: 16,
                                    color: secondaryTextColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _workoutHistory.length,
                  ),
                ),

                // Trainer Tips section (placeholder)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trainer Tips',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              'Tips content will appear here',
                              style: TextStyle(
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Tab Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.9),
                      border: Border(
                        top: BorderSide(
                          color: secondaryTextColor.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTabItem(
                            0,
                            'Summary',
                            CupertinoIcons.circle_grid_hex_fill,
                            CupertinoIcons.circle_grid_hex,
                            AppColors.accentGreen,
                            secondaryTextColor,
                          ),
                          _buildTabItem(
                            1,
                            'Fitness+',
                            CupertinoIcons.play_circle_fill,
                            CupertinoIcons.play_circle,
                            AppColors.accentGreen,
                            secondaryTextColor,
                          ),
                          _buildTabItem(
                            2,
                            'Sharing',
                            CupertinoIcons.person_2_fill,
                            CupertinoIcons.person_2,
                            AppColors.accentGreen,
                            secondaryTextColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityMetric(
    String label,
    int current,
    int goal,
    String unit,
    Color color,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$current',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  TextSpan(
                    text: '/$goal$unit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabItem(
    int index,
    String label,
    IconData activeIcon,
    IconData inactiveIcon,
    Color activeColor,
    Color inactiveColor,
  ) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
