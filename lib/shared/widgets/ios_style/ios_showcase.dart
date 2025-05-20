import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:workout_tracker/constants/app_colors.dart';
import 'index.dart';
import '../../../config/themes/app_theme.dart';

// Updated 2025-05-20: Created iOS-style showcase to demonstrate all iOS components
class IOSStyleShowcase extends StatefulWidget {
  const IOSStyleShowcase({Key? key}) : super(key: key);

  @override
  State<IOSStyleShowcase> createState() => _IOSStyleShowcaseState();
}

class _IOSStyleShowcaseState extends State<IOSStyleShowcase> {
  bool _switchValue = false;
  double _sliderValue = 0.5;
  int _segmentedControlValue = 0;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We use isDarkMode in child widgets, defining it here for consistency

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('iOS-Style Components'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSection(context, 'Buttons', _buildButtonsShowcase()),
            _buildSection(context, 'Text Fields', _buildTextFieldsShowcase()),
            _buildSection(
              context,
              'Switches & Sliders',
              _buildSwitchesAndSlidersShowcase(),
            ),
            _buildSection(
              context,
              'Segmented Controls',
              _buildSegmentedControlsShowcase(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
        ),
        content,
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildButtonsShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            IOSButton(
              label: 'Filled Button',
              type: IOSButtonType.filled,
              onPressed: () {},
            ),
            IOSButton(
              label: 'Outlined Button',
              type: IOSButtonType.outlined,
              onPressed: () {},
            ),
            IOSButton(
              label: 'Text Button',
              type: IOSButtonType.text,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            IOSButton(
              label: 'With Icon',
              icon: CupertinoIcons.add,
              onPressed: () {},
            ),
            IOSButton(label: 'Loading', isLoading: true, onPressed: () {}),
          ],
        ),
        const SizedBox(height: 16),
        IOSButton(
          label: 'Full Width Button',
          isFullWidth: true,
          onPressed: () {},
        ),
        const SizedBox(height: 16),
        IOSButton(
          label: 'Custom Color',
          color: AppColors.accentPurple,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildTextFieldsShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const IOSTextField(placeholder: 'Basic Text Field'),
        const SizedBox(height: 16),
        const IOSTextField(label: 'With Label', placeholder: 'Enter text'),
        const SizedBox(height: 16),
        IOSTextField(
          placeholder: 'With Prefix & Suffix',
          prefix: const Icon(
            CupertinoIcons.search,
            size: 20,
            color: CupertinoColors.systemGrey,
          ),
          suffix: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            child: const Icon(
              CupertinoIcons.clear_circled_solid,
              size: 20,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const IOSTextField(placeholder: 'Password Field', obscureText: true),
        const SizedBox(height: 16),
        const IOSTextField(
          placeholder: 'With Error',
          errorText: 'This field is required',
        ),
      ],
    );
  }

  Widget _buildSwitchesAndSlidersShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IOSSwitch(
              value: _switchValue,
              onChanged: (value) {
                setState(() {
                  _switchValue = value;
                });
              },
            ),
            const SizedBox(width: 16),
            Text(
              _switchValue ? 'On' : 'Off',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Text('0'),
            Expanded(
              child: IOSSlider(
                value: _sliderValue,
                onChanged: (value) {
                  setState(() {
                    _sliderValue = value;
                  });
                },
              ),
            ),
            const Text('1.0'),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Value: ${_sliderValue.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('0'),
            Expanded(
              child: IOSSlider(
                value: _sliderValue,
                min: 0,
                max: 100,
                divisions: 10,
                activeColor: AppColors.accentGreen,
                onChanged: (value) {
                  setState(() {
                    _sliderValue = value;
                  });
                },
              ),
            ),
            const Text('100'),
          ],
        ),
      ],
    );
  }

  Widget _buildSegmentedControlsShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IOSSegmentedControl<int>(
          children: const {0: Text('Day'), 1: Text('Week'), 2: Text('Month')},
          groupValue: _segmentedControlValue,
          onValueChanged: (value) {
            if (value != null) {
              setState(() {
                _segmentedControlValue = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Selected: ${_segmentedControlValue == 0
              ? 'Day'
              : _segmentedControlValue == 1
              ? 'Week'
              : 'Month'}',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 24),
        IOSSegmentedControl<String>(
          children: const {
            'easy': Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('Easy'),
            ),
            'medium': Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('Medium'),
            ),
            'hard': Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('Hard'),
            ),
          },
          groupValue: 'medium',
          onValueChanged: (value) {
            // Update value
          },
          selectedColor: AppColors.accentOrange,
        ),
      ],
    );
  }
}
