import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/user_provider.dart';
import '../../../config/themes/app_theme.dart';

class OfflineSignInScreen extends StatefulWidget {
  const OfflineSignInScreen({super.key});

  @override
  State<OfflineSignInScreen> createState() => _OfflineSignInScreenState();
}

class _OfflineSignInScreenState extends State<OfflineSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String _selectedFitnessGoal = 'Build Muscle';
  String _selectedActivityLevel = 'Moderate';
  bool _isLoading = false;

  final List<String> _fitnessGoals = [
    'Lose Weight',
    'Build Muscle',
    'Maintain Weight',
    'Improve Endurance',
    'General Fitness',
  ];

  final List<String> _activityLevels = [
    'Sedentary',
    'Light',
    'Moderate',
    'Active',
    'Very Active',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // Save user data to SharedPreferences
      await prefs.setString('user_name', _nameController.text.trim());
      await prefs.setString('user_email', _emailController.text.trim());
      await prefs.setDouble(
        'user_height',
        double.parse(_heightController.text),
      );
      await prefs.setDouble(
        'user_weight',
        double.parse(_weightController.text),
      );
      await prefs.setString('user_fitness_goal', _selectedFitnessGoal);
      await prefs.setString('user_activity_level', _selectedActivityLevel);
      await prefs.setBool('user_signed_in', true);
      await prefs.setString(
        'user_id',
        DateTime.now().millisecondsSinceEpoch.toString(),
      );

      // Update UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.updateUserName(_nameController.text.trim());
      userProvider.updateUserEmail(_emailController.text.trim());
      userProvider.updateUserHeight(double.parse(_heightController.text));
      userProvider.updateUserWeight(double.parse(_weightController.text));
      userProvider.updateUserFitnessGoal(_selectedFitnessGoal);
      userProvider.updateUserActivityLevel(_selectedActivityLevel);

      // Navigate to dashboard
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to save user data. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppTheme.backgroundColor,
              elevation: 0,
              pinned: true,
              expandedHeight: 120.0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing_m,
                  vertical: AppTheme.spacing_s,
                ),
                title: Text(
                  'Welcome',
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 28, // Adjusted for Material Design
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: false,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing_m),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch, // Changed for button width
                    children: [
                      Text(
                        'Let\'s set up your profile to get started with your fitness journey.',
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing_xl),

                      _buildSectionTitle('Personal Information'),
                      const SizedBox(height: AppTheme.spacing_m),
                      _buildPersonalInfoSection(),

                      const SizedBox(height: AppTheme.spacing_xl),
                      _buildSectionTitle('Body Measurements'),
                      const SizedBox(height: AppTheme.spacing_m),
                      _buildBodyMeasurementsSection(),

                      const SizedBox(height: AppTheme.spacing_xl),
                      _buildSectionTitle('Fitness Goals'),
                      const SizedBox(height: AppTheme.spacing_m),
                      _buildFitnessGoalsSection(),

                      const SizedBox(height: AppTheme.spacing_xl * 2),
                      _buildSignInButton(),
                      const SizedBox(height: AppTheme.spacing_l),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppTheme.primaryTextColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
      ),
      color: AppTheme.cardColor,
      child: Column(
        children: [
          _buildMaterialTextField(
            controller: _nameController,
            labelText: 'Full Name',
            suffixIcon: Icon(
              Icons.person,
              color: AppTheme.secondaryTextColor,
              size: AppTheme.iconSize_m,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          _buildDivider(),
          _buildMaterialTextField(
            controller: _emailController,
            labelText: 'Email Address',
            keyboardType: TextInputType.emailAddress,
            suffixIcon: Icon(
              Icons.mail,
              color: AppTheme.secondaryTextColor,
              size: AppTheme.iconSize_m,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMeasurementsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
      ),
      color: AppTheme.cardColor,
      child: Column(
        children: [
          _buildMaterialTextField(
            controller: _heightController,
            labelText: 'Height (cm)',
            keyboardType: TextInputType.number,
            suffixIcon: Icon(
              Icons.height, // Changed Icon
              color: AppTheme.secondaryTextColor,
              size: AppTheme.iconSize_m,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your height';
              }
              final height = double.tryParse(value);
              if (height == null || height <= 0 || height > 300) {
                return 'Please enter a valid height';
              }
              return null;
            },
          ),
          _buildDivider(),
          _buildMaterialTextField(
            controller: _weightController,
            labelText: 'Weight (kg)',
            keyboardType: TextInputType.number,
            suffixIcon: Icon(
              Icons.monitor_weight, // Changed Icon
              color: AppTheme.secondaryTextColor,
              size: AppTheme.iconSize_m,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your weight';
              }
              final weight = double.tryParse(value);
              if (weight == null || weight <= 0 || weight > 500) {
                return 'Please enter a valid weight';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFitnessGoalsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
      ),
      color: AppTheme.cardColor,
      child: Column(
        children: [
          _buildMaterialPickerRow(
            title: 'Fitness Goal',
            value: _selectedFitnessGoal,

            onTap:
                () => _showMaterialPicker(
                  title: 'Select Fitness Goal',
                  items: _fitnessGoals,
                  selectedItem: _selectedFitnessGoal,
                  onSelected:
                      (value) => setState(() => _selectedFitnessGoal = value),
                ),
          ),
          _buildDivider(),
          _buildMaterialPickerRow(
            title: 'Activity Level',
            value: _selectedActivityLevel,

            onTap:
                () => _showMaterialPicker(
                  title: 'Select Activity Level',
                  items: _activityLevels,
                  selectedItem: _selectedActivityLevel,
                  onSelected:
                      (value) => setState(() => _selectedActivityLevel = value),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(color: AppTheme.primaryTextColor),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: AppTheme.secondaryTextColor),
        hintStyle: TextStyle(
          color: AppTheme.secondaryTextColor.withOpacity(0.7),
        ),
        filled: true,
        fillColor: AppTheme.cardColor,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
          borderSide: BorderSide(color: AppTheme.accentColor, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
          borderSide: BorderSide(color: AppTheme.errorColor, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
          borderSide: BorderSide(color: AppTheme.errorColor, width: 2.0),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildMaterialPickerRow({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacing_m,
          horizontal: AppTheme.spacing_m,
        ),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.primaryTextColor),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                SizedBox(width: AppTheme.spacing_s),
                Icon(Icons.arrow_drop_down, color: AppTheme.secondaryTextColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.only(
        left: AppTheme.spacing_xl + AppTheme.spacing_m,
      ),
      color: AppTheme.secondaryTextColor.withOpacity(0.3),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity, // Ensures button takes full width
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding:
              EdgeInsets
                  .zero, // Remove default padding to manage with Container
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
          ),
          // Primary color is managed by the gradient container
          backgroundColor:
              Colors.transparent, // Make button transparent to show gradient
          shadowColor: Colors.transparent, // No shadow if gradient is used
        ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
        onPressed: _isLoading ? null : _saveUserData,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.exerciseRingColor, AppTheme.moveRingColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius_m),
          ),
          child: Container(
            alignment: Alignment.center,
            child:
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  void _showMaterialPicker({
    required String title,
    required List<String> items,
    required String selectedItem,
    required Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadius_l),
        ),
      ),
      builder:
          (context) => _MaterialPickerContent(
            title: title,
            items: items,
            selectedItem: selectedItem,
            onSelected: onSelected,
          ),
    );
  }
}

class _MaterialPickerContent extends StatefulWidget {
  final String title;
  final List<String> items;
  final String selectedItem;
  final Function(String) onSelected;

  const _MaterialPickerContent({
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.onSelected,
  });

  @override
  State<_MaterialPickerContent> createState() => _MaterialPickerContentState();
}

class _MaterialPickerContentState extends State<_MaterialPickerContent> {
  late String tempSelectedItem;

  @override
  void initState() {
    super.initState();
    tempSelectedItem = widget.selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing_m),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppTheme.secondaryTextColor),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: AppTheme.exerciseRingColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    widget.onSelected(tempSelectedItem);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return ListTile(
                  title: Text(
                    item,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          item == tempSelectedItem
                              ? AppTheme.exerciseRingColor
                              : AppTheme.primaryTextColor,
                      fontSize: 18,
                      fontWeight:
                          item == tempSelectedItem
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      tempSelectedItem = item;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
