import 'dart:io';
import 'package:flutter/material.dart';
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
  bool _isProcessingPhoto = false;

  Future<void> _pickImage(ImageSource source, UserProvider userProvider) async {
    try {
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

      if (!mounted) return;

      if (status.isGranted) {
        try {
          final XFile? pickedFile = await _picker.pickImage(source: source);
          if (!mounted) return;
          if (pickedFile != null) {
            userProvider.updateUserPhotoUrl(pickedFile.path);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image selection cancelled.')),
            );
          }
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
        }
      } else if (status.isPermanentlyDenied) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierColor: Colors.black.withAlpha(127),
          builder:
              (context) => AlertDialog(
                title: Text('Permission Required'),
                content: Text(
                  '${source == ImageSource.camera ? "Camera" : "Photo Library"} permission is permanently denied. Please enable it from app settings.',
                ),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: Text('Open Settings'),
                    onPressed: () {
                      openAppSettings();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${source == ImageSource.camera ? "Camera" : "Photo Library"} permission denied.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPhoto = false;
        });
      }
    }
  }

  void _removePhoto(UserProvider userProvider) {
    try {
      userProvider.updateUserPhotoUrl('');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile photo removed.')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error removing photo: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPhoto = false;
        });
      }
    }
  }

  void _showPhotoOptions(UserProvider userProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withAlpha(127),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadius_l),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppTheme.accentTextColor,
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: AppTheme.primaryTextColor),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  if (mounted) {
                    setState(() {
                      _isProcessingPhoto = true;
                    });
                  }
                  _pickImage(ImageSource.gallery, userProvider);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppTheme.accentTextColor,
                ),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(color: AppTheme.primaryTextColor),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  if (mounted) {
                    setState(() {
                      _isProcessingPhoto = true;
                    });
                  }
                  _pickImage(ImageSource.camera, userProvider);
                },
              ),
              if (userProvider.user.photoUrl.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete, color: AppTheme.errorColor),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(color: AppTheme.primaryTextColor),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    if (mounted) {
                      setState(() {
                        _isProcessingPhoto = true;
                      });
                    }
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(color: AppTheme.primaryTextColor),
          ),
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppTheme.primaryTextColor),
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
      ),
    );
  }

  Widget _buildUserInfo(UserProvider userProvider) {
    return Card(
      color: AppTheme.cardColor,
      margin: const EdgeInsets.all(AppTheme.spacing_m),
      elevation: 0,
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
    final photoUrl = userProvider.user.photoUrl;
    final hasPhoto = photoUrl.isNotEmpty;

    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppTheme.primaryTextColor.withAlpha(26),
          backgroundImage:
              hasPhoto
                  ? (Uri.tryParse(photoUrl)?.isAbsolute == true
                          ? NetworkImage(photoUrl)
                          : FileImage(File(photoUrl)))
                      as ImageProvider<Object>?
                  : null,
          child:
              !hasPhoto
                  ? Icon(
                    Icons.person,
                    size: 60,
                    color: AppTheme.primaryTextColor.withAlpha(
                      77,
                    ), // Updated 2025-05-29: Corrected color and opacity (0.3)
                  )
                  : null,
        ),
        if (_isProcessingPhoto)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(127),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacing_s),
            decoration: BoxDecoration(
              color: AppTheme.accentTextColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.backgroundColor, width: 2),
            ),
            child: GestureDetector(
              onTap: () => _showPhotoOptions(userProvider),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ), // Updated 2025-05-29: Added const
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(UserProvider userProvider) {
    return Card(
      color: AppTheme.cardColor,
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing_m,
        vertical: AppTheme.spacing_s,
      ),
      elevation: 0,
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
                    AppTheme.accentTextColor,
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
                    AppTheme.accentTextColor,
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
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppTheme.spacing_s),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
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
              const Icon(
                Icons.edit,
                color: AppTheme.secondaryTextColor,
                size: 12,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsSection(UserProvider userProvider) {
    return Card(
      color: AppTheme.cardColor,
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing_m,
        vertical: AppTheme.spacing_s,
      ),
      elevation: 0,
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
                color: AppTheme.accentTextColor,
              ),
              title: const Text(
                'Fitness Goal',
                style: TextStyle(color: AppTheme.primaryTextColor),
              ),
              subtitle: Text(
                userProvider.user.fitnessGoal.isNotEmpty
                    ? userProvider.user.fitnessGoal
                    : 'Tap to set goal',
                style: const TextStyle(color: AppTheme.secondaryTextColor),
              ),
              trailing: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: AppTheme.secondaryTextColor,
              ),
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
                color: AppTheme.accentTextColor,
              ),
              title: const Text(
                'Activity Level',
                style: TextStyle(color: AppTheme.primaryTextColor),
              ),
              subtitle: Text(
                userProvider.user.activityLevel.isNotEmpty
                    ? userProvider.user.activityLevel
                    : 'Tap to set activity level',
                style: const TextStyle(color: AppTheme.secondaryTextColor),
              ),
              trailing: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: AppTheme.secondaryTextColor,
              ),
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
      color: AppTheme.cardColor,
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing_m,
        vertical: AppTheme.spacing_s,
      ),
      elevation: 0,
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
            const SizedBox(height: AppTheme.spacing_m),
            _buildActionButton(
              icon: Icons.logout,
              label: 'Log Out',
              onPressed: _logoutUser,
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to export data: No file path returned'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
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
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
          ),
          title: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppTheme.primaryTextColor),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: AppTheme.primaryTextColor),
            decoration: InputDecoration(
              hintText: fieldHint,
              hintStyle: TextStyle(
                color: AppTheme.secondaryTextColor.withOpacity(0.7),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppTheme.secondaryTextColor.withOpacity(0.5),
                ),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppTheme.accentTextColor,
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.accentTextColor),
              ),
            ),
            TextButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Save',
                style: TextStyle(color: AppTheme.accentTextColor),
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
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
          border: Border.all(
            color: AppTheme.secondaryTextColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.accentTextColor, size: 20),
            const SizedBox(width: AppTheme.spacing_s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryTextColor,
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
            const Icon(
              Icons.edit,
              color: AppTheme.secondaryTextColor,
              size: 16,
            ), // Updated 2025-05-29
          ],
        ),
      ),
    );
  }

  // Added 2025-05-29: Logout functionality
  Future<void> _logoutUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      await userProvider.logoutUser();
      // Navigate to sign-in screen and remove all previous routes
      if (!mounted) return; // Check if the widget is still in the tree
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/sign_in', // Assuming '/sign_in' is your sign-in route
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Handle potential errors during logout, though unlikely with current setup
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20 /* color is set by foregroundColor */),
      label: Text(
        label /* style is merged from textStyle and foregroundColor */,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.surfaceColor, // Subtle background
        foregroundColor:
            AppTheme.accentTextColor, // Clear action text/icon color
        minimumSize: const Size(double.infinity, 48), // Already const
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
        ),
        padding: const EdgeInsets.symmetric(
          // Already const
          vertical: AppTheme.spacing_s,
          horizontal: AppTheme.spacing_m,
        ),
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      onPressed: onPressed,
    );
  }
}
