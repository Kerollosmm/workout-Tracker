import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/themes/app_theme.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/notification_service.dart';
import '../widgets/theme_selector.dart';
import '../widgets/units_selector.dart';

class SettingsScreen extends StatelessWidget {
  Future<bool> _showResetConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Reset All Data'),
              content: const Text(
                'This will delete all your workouts, exercises, and reset all settings. This action cannot be undone. Are you sure you want to continue?',
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Reset'),
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

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacing_s,
            horizontal: AppTheme.spacing_xs,
          ),
          children: [
            _buildSettingsSection(
              context,
              title: 'Weight Unit',
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
                title: const Text('Reset All Data'),
                subtitle: const Text('Delete all workouts and settings'),

                onTap: () async {
                  final confirmed = await _showResetConfirmationDialog(context);
                  if (confirmed && context.mounted) {
                    try {
                      await settingsProvider.resetAllData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All data has been reset'),
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
                          SnackBar(content: Text('Error resetting data: $e')),
                        );
                      }
                    }
                  }
                },
              ),
            ),

            const SizedBox(height: AppTheme.spacing_s),
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
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing_m,
        vertical: AppTheme.spacing_s,
      ),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppTheme.spacing_m,
              top: AppTheme.spacing_m,
              right: AppTheme.spacing_m,
              bottom: AppTheme.spacing_xs,
            ),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: AppTheme.spacing_xs,
              right: AppTheme.spacing_xs,
              bottom: AppTheme.spacing_s,
            ),
            child: child,
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
      children: [
        SwitchListTile(
          title: const Text('Enable Reminders'),
          value: provider.notificationDays.isNotEmpty,
          onChanged: (value) {
            if (value) {
              provider.setNotificationDays(weekdays);
            } else {
              provider.setNotificationDays([]);
            }
          },
        ),
        if (provider.notificationDays.isNotEmpty)
          ListTile(
            title: const Text('Reminder Time'),
            subtitle: Text(
              provider.notificationTime != null
                  ? _parseNotificationTime(
                    provider.notificationTime!,
                  ).format(context)
                  : TimeOfDay(hour: 8, minute: 0).format(context),
            ),

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

                // Schedule notifications using the notification service
                await NotificationService().scheduleWeeklyNotifications(
                  days: provider.notificationDays,
                  time: formattedTime,
                  title: 'Workout Reminder',
                  body: 'Time for your daily workout! 💪',
                );
              }
            },
          ),
        if (provider.notificationDays.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  // Use the showTestNotification method from NotificationService
                  await NotificationService().showTestNotification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test notification sent!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              label: const Text('Test Notification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reminder Days',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    weekdays.map((day) {
                      final isSelected = provider.notificationDays.contains(
                        day,
                      );
                      return FilterChip(
                        label: Text(day.substring(0, 3)),
                        selected: isSelected,
                        onSelected: (selected) {
                          final updatedDays = List<String>.from(
                            provider.notificationDays,
                          );
                          if (selected) {
                            if (!updatedDays.contains(day)) {
                              updatedDays.add(day);
                            }
                          } else {
                            updatedDays.remove(day);
                          }
                          provider.setNotificationDays(updatedDays);
                        },
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ],
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
        const ListTile(title: Text('Name'), subtitle: Text('Kerollos Melad')),
        ListTile(
          title: const Text('GitHub'),
          subtitle: const Text(githubUrl),

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
        ListTile(
          title: const Text('Phone'),
          subtitle: const Text(phoneNumber),

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
