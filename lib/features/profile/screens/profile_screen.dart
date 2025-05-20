import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/workout_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _nameController.text = userProvider.user.name;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final user = userProvider.user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                userProvider.updateUserName(_nameController.text);
                setState(() => _isEditing = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated')),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildProfilePhoto(userProvider),
            const SizedBox(height: 24),
            _isEditing
                ? TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(user.name, style: theme.textTheme.headlineSmall),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        setState(() => _isEditing = true);
                      },
                    ),
                  ],
                ),
            const SizedBox(height: 32),
            _buildActionButtons(userProvider, workoutProvider),
            const SizedBox(height: 32),
            if (userProvider.shouldSuggestWeightIncrease(workoutProvider))
              _buildWeightIncreaseSuggestion(),
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
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            backgroundImage:
                userProvider.user.photoUrl.isNotEmpty
                    ? FileImage(File(userProvider.user.photoUrl))
                    : null,
            child:
                userProvider.user.photoUrl.isEmpty
                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: () => _showPhotoOptions(userProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    UserProvider userProvider,
    WorkoutProvider workoutProvider,
  ) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.file_download),
          label: const Text('Export to Excel'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: () async {
            try {
              final filePath = await userProvider.exportWorkoutDataToExcel(
                workoutProvider,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Exported to $filePath'),
                    action: SnackBarAction(
                      label: 'Share',
                      onPressed: () async {
                        try {
                          // Using the XFile constructor with a file path
                          await Share.shareXFiles(
                            [XFile(filePath)],
                            text: 'My Workout Data',
                          );
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to share file')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to export data: ${e.toString()}')),
                );
              }
            }
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.settings),
          label: const Text('App Settings'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ],
    );
  }

  Widget _buildWeightIncreaseSuggestion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb, color: Colors.amber[800]),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Based on your progress, consider increasing your training weight by 10% for optimal growth.',
              style: TextStyle(color: Colors.amber[900]),
            ),
          ),
        ],
      ),
    );
  }

  void _showPhotoOptions(UserProvider userProvider) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    if (!mounted) return;
                    final currentContext = context;
                    Navigator.pop(currentContext);
                    try {
                      await userProvider.pickAndUpdateProfilePhoto();
                    } catch (e) {
                      if (mounted) {
                        if (currentContext.mounted) {
                          ScaffoldMessenger.of(currentContext).showSnackBar(
                            SnackBar(content: Text('Failed to update photo: ${e.toString()}')),
                          );
                        }
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Photo'),
                  onTap: () async {
                    if (!mounted) return;
                    final currentContext = context;
                    Navigator.pop(currentContext);
                    try {
                      await userProvider.takeAndUpdateProfilePhoto();
                    } catch (e) {
                      if (mounted) {
                        if (currentContext.mounted) {
                          ScaffoldMessenger.of(currentContext).showSnackBar(
                            SnackBar(content: Text('Failed to take photo: ${e.toString()}')),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }
}
