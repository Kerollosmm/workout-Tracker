import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../config/themes/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source, UserProvider userProvider) async {
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      if (Platform.isAndroid) {
        status = await Permission.storage.request();
      } else {
        status = await Permission.photos.request();
      }
    }

    if (status.isGranted) {
      try {
        final XFile? pickedFile = await _picker.pickImage(source: source);
        if (pickedFile != null) {
          userProvider.updateUserPhotoUrl(pickedFile.path);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image selection cancelled.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    } else if (status.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Permission Required'),
              content: Text(
                '${source == ImageSource.camera ? "Camera" : "Photo Library"} permission is permanently denied. Please enable it from app settings.',
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Open Settings'),
                  onPressed: () {
                    openAppSettings();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${source == ImageSource.camera ? "Camera" : "Photo Library"} permission denied.',
          ),
        ),
      );
    }
  }

  void _removePhoto(UserProvider userProvider) {
    userProvider.updateUserPhotoUrl('');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile photo removed.')));
  }

  void _showPhotoOptions(UserProvider userProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppTheme.primaryColor,
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery, userProvider);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppTheme.primaryColor,
                ),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera, userProvider);
                },
              ),
              if (userProvider.user.photoUrl.isNotEmpty)
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red[400]),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _removePhoto(userProvider);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer2<UserProvider, WorkoutProvider>(
        builder: (context, userProvider, workoutProvider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildUserInfo(userProvider),
                _buildStatsCards(userProvider),
                _buildGoalsSection(userProvider),
                _buildActionButtons(userProvider, workoutProvider),
                const SizedBox(height: AppTheme.spacing_l),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfo(UserProvider userProvider) {
    return Card(
      margin: const EdgeInsets.all(AppTheme.spacing_m),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing_l),
        child: Column(
          children: [
            _buildProfilePhoto(userProvider),
            const SizedBox(height: AppTheme.spacing_l),
            _buildEditableField(
              'Name',
              userProvider.user.name.isNotEmpty
                  ? userProvider.user.name
                  : 'Tap to add name',
              (value) => userProvider.updateUserName(value),
              Icons.person_outline,
            ),
            const SizedBox(height: AppTheme.spacing_m),
            _buildEditableField(
              'Email',
              userProvider.user.email.isNotEmpty
                  ? userProvider.user.email
                  : 'Tap to add email',
              (value) => userProvider.updateUserEmail(value),
              Icons.mail_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhoto(UserProvider userProvider) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: () => _showPhotoOptions(userProvider),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(color: AppTheme.primaryColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child:
                  userProvider.user.photoUrl.isNotEmpty
                      ? Image.file(
                        File(userProvider.user.photoUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey[400],
                          );
                        },
                      )
                      : Icon(Icons.person, size: 60, color: Colors.grey[400]),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing_s),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: GestureDetector(
            onTap: () => _showPhotoOptions(userProvider),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(UserProvider userProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing_m,
        vertical: AppTheme.spacing_s,
      ),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing_l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Body Stats',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing_m),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Weight',
                    '${userProvider.user.weight.toStringAsFixed(1)} kg',
                    Icons.scale_outlined,
                    AppTheme.primaryColor,
                    () => _showEditDialog(
                      context,
                      'Edit Weight',
                      userProvider.user.weight.toString(),
                      'Weight (kg)',
                      (value) {
                        final weight = double.tryParse(value);
                        if (weight != null) {
                          userProvider.updateUserWeight(weight);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing_m),
                Expanded(
                  child: _buildStatCard(
                    'Height',
                    '${userProvider.user.height.toStringAsFixed(0)} cm',
                    Icons.height_outlined,
                    AppTheme.primaryColor,
                    () => _showEditDialog(
                      context,
                      'Edit Height',
                      userProvider.user.height.toString(),
                      'Height (cm)',
                      (value) {
                        final height = double.tryParse(value);
                        if (height != null) {
                          userProvider.updateUserHeight(height);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsSection(UserProvider userProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing_m,
        vertical: AppTheme.spacing_s,
      ),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing_l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fitness Goals',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing_s),
            ListTile(
              leading: const Icon(
                Icons.flag_outlined,
                color: AppTheme.primaryColor,
              ),
              title: const Text('Fitness Goal'),
              subtitle: Text(
                userProvider.user.fitnessGoal.isNotEmpty
                    ? userProvider.user.fitnessGoal
                    : 'Tap to set goal',
              ),
              trailing: const Icon(Icons.edit_outlined, size: 20),
              onTap:
                  () => _showEditDialog(
                    context,
                    'Set Fitness Goal',
                    userProvider.user.fitnessGoal.isNotEmpty
                        ? userProvider.user.fitnessGoal
                        : '',
                    'Fitness Goal',
                    (value) => userProvider.updateUserFitnessGoal(value),
                  ),
            ),
            ListTile(
              leading: const Icon(
                Icons.local_fire_department_outlined,
                color: AppTheme.primaryColor,
              ),
              title: const Text('Activity Level'),
              subtitle: Text(
                userProvider.user.activityLevel.isNotEmpty
                    ? userProvider.user.activityLevel
                    : 'Tap to set activity level',
              ),
              trailing: const Icon(Icons.edit_outlined, size: 20),
              onTap:
                  () => _showEditDialog(
                    context,
                    'Set Activity Level',
                    userProvider.user.activityLevel.isNotEmpty
                        ? userProvider.user.activityLevel
                        : '',
                    'Activity Level',
                    (value) => userProvider.updateUserActivityLevel(value),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    UserProvider userProvider,
    WorkoutProvider workoutProvider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing_m,
        vertical: AppTheme.spacing_s,
      ),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing_l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing_m),
            _buildActionButton(
              icon: Icons.download_outlined,
              label: 'Export Workout Data',
              onPressed: () => _exportWorkoutData(workoutProvider),
            ),
            const SizedBox(height: AppTheme.spacing_m),
            _buildActionButton(
              icon: Icons.share_outlined,
              label: 'Share App',
              onPressed: () => _shareApp(),
            ),
            const SizedBox(height: AppTheme.spacing_m),
            _buildActionButton(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            const SizedBox(height: AppTheme.spacing_m),
            _buildActionButton(
              icon: Icons.privacy_tip_outlined,
              label: 'View Privacy Policy',
              onPressed: () => _launchURL('https://yourprivacypolicyurl.com'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportWorkoutData(WorkoutProvider workoutProvider) async {
    try {
      final filePath = await workoutProvider.exportWorkoutDataToExcel();
      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported to $filePath'),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () async {
                try {
                  await Share.shareXFiles([
                    XFile(filePath),
                  ], text: 'My Workout Data');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to share file')),
                  );
                }
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to export data: No file path returned'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export data: ${e.toString()}')),
      );
    }
  }

  void _shareApp() {
    Share.share('Check out this awesome workout tracker app! [Your App Link]');
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    String currentValue,
    String fieldHint,
    Function(String) onSave,
  ) {
    final TextEditingController controller = TextEditingController(
      text: currentValue,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: fieldHint,
              hintStyle: TextStyle(color: Theme.of(context).hintColor),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).hintColor.withOpacity(0.5),
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.primaryColor),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
            TextButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Save',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditableField(
    String label,
    String value,
    Function(String) onSave,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () => _showEditDialog(context, label, value, label, onSave),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing_m),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
          border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: AppTheme.spacing_s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? buttonColor,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            buttonColor ?? Theme.of(context).colorScheme.primaryContainer,
        foregroundColor:
            buttonColor != null
                ? Colors.white
                : Theme.of(context).colorScheme.onPrimaryContainer,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacing_s,
          horizontal: AppTheme.spacing_m,
        ),
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing_m),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppTheme.spacing_s),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (onTap != null)
              Icon(Icons.edit, color: Colors.grey[400], size: 12),
          ],
        ),
      ),
    );
  }
}
