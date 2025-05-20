import 'package:flutter/material.dart';
import 'custom_app_bar.dart';
import 'custom_button.dart';
import 'custom_card.dart';
import 'custom_list_tile.dart';
import 'custom_text_field.dart';
import 'workout_progress_indicator.dart';

// Updated 2025-05-20: Created theme showcase to demonstrate reusable components
class ThemeShowcase extends StatelessWidget {
  const ThemeShowcase({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Design System'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(context, 'Buttons', _buildButtonsShowcase(context)),
          _buildSection(context, 'Cards', _buildCardsShowcase(context)),
          _buildSection(context, 'Text Fields', _buildTextFieldsShowcase(context)),
          _buildSection(context, 'List Tiles', _buildListTilesShowcase(context)),
          _buildSection(context, 'Progress Indicators', _buildProgressIndicatorsShowcase(context)),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content,
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildButtonsShowcase(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            CustomButton(
              label: 'Primary',
              variant: ButtonVariant.primary,
              onPressed: () {},
            ),
            CustomButton(
              label: 'Secondary',
              variant: ButtonVariant.secondary,
              onPressed: () {},
            ),
            CustomButton(
              label: 'Outline',
              variant: ButtonVariant.outline,
              onPressed: () {},
            ),
            CustomButton(
              label: 'Text',
              variant: ButtonVariant.text,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            CustomButton(
              label: 'Small',
              size: ButtonSize.small,
              onPressed: () {},
            ),
            CustomButton(
              label: 'Medium',
              size: ButtonSize.medium,
              onPressed: () {},
            ),
            CustomButton(
              label: 'Large',
              size: ButtonSize.large,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            CustomButton(
              label: 'With Icon',
              icon: Icons.add,
              onPressed: () {},
            ),
            CustomButton(
              label: 'Loading',
              isLoading: true,
              onPressed: () {},
            ),
            CustomButton(
              label: 'Full Width',
              fullWidth: true,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardsShowcase(BuildContext context) {
    return Column(
      children: [
        CustomCard(
          variant: CardVariant.elevated,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Elevated Card'),
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          variant: CardVariant.outlined,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Outlined Card'),
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          variant: CardVariant.filled,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Filled Card'),
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          variant: CardVariant.minimal,
          hasBorder: true,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Minimal Card with Border'),
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          variant: CardVariant.elevated,
          onTap: () {},
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Tappable Card'),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldsShowcase(BuildContext context) {
    return Column(
      children: [
        const CustomTextField(
          label: 'Regular Text Field',
          hint: 'Enter text here',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          hint: 'With Helper Text',
          helperText: 'This is a helper text',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          hint: 'With Error',
          errorText: 'This field is required',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          hint: 'Disabled',
          enabled: false,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hint: 'With Prefix & Suffix Icons',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {},
          ),
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          hint: 'Password',
          obscureText: true,
          suffixIcon: Icon(Icons.visibility),
        ),
      ],
    );
  }

  Widget _buildListTilesShowcase(BuildContext context) {
    return Column(
      children: [
        const CustomListTile(
          title: 'Basic List Tile',
          subtitle: 'With subtitle',
        ),
        const SizedBox(height: 8),
        CustomListTile(
          title: 'With Leading & Trailing',
          subtitle: 'And tappable',
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const SizedBox(height: 8),
        const CustomListTile(
          title: 'Selected List Tile',
          subtitle: 'This one is selected',
          selected: true,
        ),
        const SizedBox(height: 8),
        const CustomListTile(
          title: 'With Border',
          hasBorder: true,
        ),
        const SizedBox(height: 8),
        const CustomListTile(
          title: 'Dense List Tile',
          subtitle: 'Uses less vertical space',
          dense: true,
        ),
      ],
    );
  }

  Widget _buildProgressIndicatorsShowcase(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          WorkoutProgressIndicator(
            progress: 0.25,
            label: '25%',
          ),
          SizedBox(width: 16),
          WorkoutProgressIndicator(
            progress: 0.5,
            label: 'Half way',
          ),
          SizedBox(width: 16),
          WorkoutProgressIndicator(
            progress: 0.75,
            progressColor: Colors.orange,
            label: '75%',
          ),
          SizedBox(width: 16),
          WorkoutProgressIndicator(
            progress: 1.0,
            progressColor: Colors.green,
            label: 'Complete',
          ),
          SizedBox(width: 16),
          WorkoutTimerIndicator(
            remaining: Duration(minutes: 2, seconds: 30),
            total: Duration(minutes: 5),
            label: 'Rest Timer',
          ),
        ],
      ),
    );
  }
}
