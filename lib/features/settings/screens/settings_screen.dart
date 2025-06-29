import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/themes/app_theme.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/notification_service.dart';
import '../widgets/units_selector.dart';

class SettingsScreen extends StatelessWidget {
  Future<bool> _showResetConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            // Updated 2025-05-29: Themed AlertDialog
            return AlertDialog(
              backgroundColor: AppTheme.surfaceColor,
              title: Text(
                'Reset All Data',
                style: TextStyle(color: AppTheme.primaryTextColor),
              ),
              content: Text(
                'This will delete all your workouts, exercises, and reset all settings. This action cannot be undone. Are you sure you want to continue?',
                style: TextStyle(color: AppTheme.secondaryTextColor),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
              ),
              actions: [
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppTheme.accentTextColor),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      color: AppTheme.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    // Updated 2025-05-29: Apply AppTheme to Scaffold and AppBar
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Settings',
            style: TextStyle(color: AppTheme.primaryTextColor),
          ),
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppTheme.primaryTextColor),
        ),
        body: ListView(
          padding: const EdgeInsets.all(
            AppTheme.spacing_m,
          ), // Use consistent padding
          children: [
            // Updated 2025-05-29: Add ThemeSelector section
            _buildSettingsSection(
              context,
              title: 'Appearance',
              child: SwitchListTile(
                title: const Text('Dark Mode', style: TextStyle(color: AppTheme.primaryTextColor)),
                value: settingsProvider.isDarkMode,
                activeColor: AppTheme.accentTextColor,
                onChanged: (value) {
                  settingsProvider.setDarkMode(value);
                },
              ),
            ),
            _buildSettingsSection(
              context,
              title: 'Units',
              child: UnitsSelector(
                selectedUnit: settingsProvider.weightUnit,
                onUnitChanged: (unit) {
                  settingsProvider.setWeightUnit(unit);
                },
              ),
            ),
            _buildSettingsSection(
              context,
              title: 'Workout Reminders',
              child: _buildNotificationSettings(context, settingsProvider),
            ),
            _buildSettingsSection(
              context,
              title: 'Data Management',
              child: ListTile(
                // Updated 2025-05-29: Added icon and themed text for destructive action
                leading: const Icon(
                  Icons.delete_sweep_outlined,
                  color: AppTheme.errorColor,
                  size: 28,
                ),
                title: const Text(
                  'Reset All Data',
                  style: TextStyle(color: AppTheme.primaryTextColor),
                ),
                subtitle: Text(
                  'Delete all workouts, history, and settings.',
                  style: TextStyle(color: AppTheme.secondaryTextColor),
                ),
                tileColor:
                    AppTheme
                        .surfaceColor, // Ensure ListTile background matches card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
                ),
                onTap: () async {
                  final confirmed = await _showResetConfirmationDialog(context);
                  if (confirmed && context.mounted) {
                    try {
                      await settingsProvider.resetAllData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('All data has been reset'),
                            // Updated 2025-05-29: Replaced AppTheme.successColor with AppTheme.accentTextColor
                            backgroundColor: AppTheme.accentTextColor,
                          ),
                        );
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error resetting data: $e'),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ),
            // Updated 2025-05-29: Add Developer Info section
            _buildSettingsSection(
              context,
              title: 'About',
              child: _buildDeveloperInfo(context),
            ),
            const SizedBox(
              height: AppTheme.spacing_l,
            ), // Add some bottom spacing
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    // Updated 2025-05-29: Restored correct settings section structure and themed elements
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppTheme.spacing_m,
      ), // Outer padding for the section
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppTheme.spacing_xs,
              bottom: AppTheme.spacing_s,
            ),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.w600, // Emphasize title
              ),
            ),
          ),
          Material(
            elevation: 1.0, // Subtle elevation for card effect
            shadowColor: Colors.black.withOpacity(0.05), // Defined shadow
            color: AppTheme.surfaceColor, // Card background color from theme
            borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
            child: Padding(
              padding: const EdgeInsets.all(
                AppTheme.spacing_s,
              ), // Inner padding for the card content
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(
    BuildContext context,
    SettingsProvider provider,
  ) {
    final List<String> weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
      children: [
        SwitchListTile(
          title: const Text('Enable Reminders', style: TextStyle(color: AppTheme.primaryTextColor)),
          value: provider.notificationDays.isNotEmpty,
          activeColor: AppTheme.accentTextColor, // Color for the switch when it's on
          onChanged: (value) {
            if (value) {
              // If turning on, and no days were previously selected, select all. Otherwise, keep previous.
              if (provider.notificationDays.isEmpty) {
                provider.setNotificationDays(weekdays);
              } else {
                 provider.setNotificationDays(List.from(provider.notificationDays)); // Re-assert to trigger update if needed
              }
            } else {
              provider.setNotificationDays([]);
            }
          },
        ),
        if (provider.notificationDays.isNotEmpty) ...[ // Use ...[] to allow multiple widgets
          ListTile(
            title: const Text('Reminder Time', style: TextStyle(color: AppTheme.primaryTextColor)),
            subtitle: Text(
              provider.notificationTime != null
                  ? _parseNotificationTime(
                    provider.notificationTime!,
                  ).format(context)
                  : TimeOfDay(hour: 8, minute: 0).format(context), // Default display
              style: const TextStyle(color: AppTheme.secondaryTextColor),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.secondaryTextColor, size: 16), // iOS style chevron
            onTap: () async {
              final initialTime =
                  provider.notificationTime != null
                      ? _parseNotificationTime(provider.notificationTime!)
                      : const TimeOfDay(hour: 8, minute: 0);

              final selectedTime = await showTimePicker(
                context: context,
                initialTime: initialTime,
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Colors.blue,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (selectedTime != null) {
                final formattedTime =
                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                provider.setNotificationTime(formattedTime);
                // No need to call NotificationService().scheduleWeeklyNotifications here,
                // as provider.setNotificationTime() will trigger _updateNotifications()
                // which handles the scheduling.
              }
            },
          ),
        if (provider.notificationDays.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing_m, // Use AppTheme constant
              vertical: AppTheme.spacing_s,   // Use AppTheme constant
            ),
            child: CustomActionButton( // Replace ElevatedButton with CustomActionButton
              icon: Icons.notifications_active_outlined,
              label: 'Test Notification',
              onPressed: () async {
                try {
                  await NotificationService().showTestNotification();
                  if (context.mounted) { // Check if context is still valid
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Test notification sent!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) { // Check if context is still valid
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error sending test notification: $e')),
                    );
                  }
                }
              },
              // CustomActionButton uses AppTheme defaults, or you can override here if needed
              // backgroundColor: AppTheme.accentTextColor,
              // foregroundColor: AppTheme.primaryTextColor,
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing_m, vertical: AppTheme.spacing_s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reminder Days',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.primaryTextColor),
              ),
              const SizedBox(height: AppTheme.spacing_s),
              Wrap(
                spacing: AppTheme.spacing_s,
                runSpacing: AppTheme.spacing_xs, // Add runSpacing for vertical gap in wrapped lines
                children:
                    weekdays.map((day) {
                      final isSelected = provider.notificationDays.contains(day);
                      return FilterChip(
                        label: Text(day.substring(0, 3), style: TextStyle(color: isSelected ? AppTheme.primaryTextColor : AppTheme.primaryTextColor.withOpacity(0.8))),
                        selected: isSelected,
                        onSelected: (selected) {
                          final updatedDays = List<String>.from(provider.notificationDays);
                          if (selected) {
                            if (!updatedDays.contains(day)) {
                              updatedDays.add(day);
                            }
                          } else {
                            updatedDays.remove(day);
                          }
                          provider.setNotificationDays(updatedDays);
                        },
                        backgroundColor: AppTheme.surfaceColor, // Background for unselected
                        selectedColor: AppTheme.accentTextColor, // Background for selected
                        checkmarkColor: AppTheme.primaryTextColor, // Color of the checkmark
                        shape: StadiumBorder(side: BorderSide(color: isSelected ? AppTheme.accentTextColor : AppTheme.secondaryTextColor.withOpacity(0.5))),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
       ] // End of conditional widgets
    );
  }

  TimeOfDay _parseNotificationTime(String time) {
    try {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  Widget _buildDeveloperInfo(BuildContext context) {
    const String githubUrl = 'https://github.com/Kerollosmm';
    const String phoneNumber = '01274173806';

    return Column(
      children: [
        // Updated 2025-05-29: Apply AppTheme styling and add icon
        ListTile(
          leading: Icon(
            Icons.person_outline,
            color: AppTheme.primaryTextColor.withOpacity(0.7),
            size: 28,
          ),
          title: const Text(
            'Name',
            style: TextStyle(color: AppTheme.primaryTextColor),
          ),
          subtitle: const Text(
            'Kerollos Melad',
            style: TextStyle(color: AppTheme.secondaryTextColor),
          ),
        ),
        // Updated 2025-05-29: Apply AppTheme styling and add icon
        ListTile(
          leading: Icon(
            Icons.code_rounded,
            color: AppTheme.primaryTextColor.withOpacity(0.7),
            size: 28,
          ), // Placeholder for GitHub icon
          title: const Text(
            'GitHub',
            style: TextStyle(color: AppTheme.primaryTextColor),
          ),
          subtitle: Text(
            githubUrl,
            style: TextStyle(color: AppTheme.accentTextColor.withOpacity(0.8)),
          ), // Make URL stand out
          onTap: () async {
            final uri = Uri.parse(githubUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not launch $githubUrl')),
              );
            }
          },
        ),
        // Updated 2025-05-29: Apply AppTheme styling and add icon
        ListTile(
          leading: Icon(
            Icons.phone_outlined,
            color: AppTheme.primaryTextColor.withOpacity(0.7),
            size: 28,
          ),
          title: const Text(
            'Phone',
            style: TextStyle(color: AppTheme.primaryTextColor),
          ),
          subtitle: Text(
            phoneNumber,
            style: TextStyle(color: AppTheme.secondaryTextColor),
          ),
          onTap: () async {
            final uri = Uri.parse('tel:$phoneNumber');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not launch phone dialer')),
              );
            }
          },
        ),
      ],
    );
  }
}
