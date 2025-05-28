import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/themes/app_theme.dart';
import '../../../core/providers/settings_provider.dart';

class SetInputCard extends StatelessWidget {
  final int setNumber;
  final double weight;
  final int reps;
  final bool isHardSet;
  final Function(double) onWeightChanged;
  final Function(int) onRepsChanged;
  final Function(bool) onHardSetChanged;
  final VoidCallback onDelete;

  const SetInputCard({
    Key? key,
    required this.setNumber,
    required this.weight,
    required this.reps,
    required this.isHardSet,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onHardSetChanged,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final weightUnit = settingsProvider.weightUnit;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color currentTextColor = isDarkMode ? AppTheme.primaryTextColor : Colors.black87;
    final Color currentSecondaryTextColor = isDarkMode ? AppTheme.secondaryTextColor : Colors.black54;
    final Color currentBorderColor = isDarkMode ? AppTheme.primaryTextColor.withOpacity(0.2) : Colors.grey.shade400;
    final Color currentHintColor = isDarkMode ? AppTheme.secondaryTextColor.withOpacity(0.7) : Colors.grey.shade500;
    final Color currentSuffixColor = isDarkMode ? AppTheme.secondaryTextColor : Colors.grey.shade700;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing_xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 45,
            child: Text(
              'Set $setNumber',
              style: TextStyle(fontWeight: FontWeight.w500, color: currentTextColor, fontSize: 14),
            ),
          ),
          SizedBox(width: AppTheme.spacing_s),

          Expanded(
            flex: 3,
            child: TextFormField(
              style: TextStyle(color: currentTextColor, fontSize: 14),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacing_s, vertical: AppTheme.spacing_s + 2),
                hintText: '0.0',
                hintStyle: TextStyle(color: currentHintColor),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
                  borderSide: BorderSide(color: currentBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
                  borderSide: BorderSide(color: AppTheme.exerciseRingColor, width: 1.5),
                ),
                suffixText: weightUnit,
                suffixStyle: TextStyle(color: currentSuffixColor, fontSize: 12),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              initialValue: weight > 0 ? weight.toStringAsFixed(1) : '',
              onChanged: (value) {
                final parsedValue = double.tryParse(value) ?? 0;
                onWeightChanged(parsedValue);
              },
            ),
          ),
          SizedBox(width: AppTheme.spacing_s),

          Expanded(
            flex: 2,
            child: TextFormField(
              style: TextStyle(color: currentTextColor, fontSize: 14),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacing_s, vertical: AppTheme.spacing_s + 2),
                hintText: '0',
                hintStyle: TextStyle(color: currentHintColor),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
                  borderSide: BorderSide(color: currentBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
                  borderSide: BorderSide(color: AppTheme.exerciseRingColor, width: 1.5),
                ),
              ),
              keyboardType: TextInputType.number,
              initialValue: reps > 0 ? reps.toString() : '',
              onChanged: (value) {
                final parsedValue = int.tryParse(value) ?? 0;
                onRepsChanged(parsedValue);
              },
            ),
          ),
          SizedBox(width: AppTheme.spacing_s),

          InkWell(
            onTap: () => onHardSetChanged(!isHardSet),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing_s, vertical: AppTheme.spacing_xs + 2),
              decoration: BoxDecoration(
                color: isHardSet ? AppTheme.exerciseRingColor.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.borderRadius_s),
                border: Border.all(
                  color: isHardSet ? AppTheme.exerciseRingColor : currentBorderColor,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isHardSet ? Icons.local_fire_department_rounded : Icons.local_fire_department_outlined,
                    size: 16,
                    color: isHardSet ? AppTheme.exerciseRingColor : currentSecondaryTextColor,
                  ),
                  SizedBox(width: AppTheme.spacing_xs),
                  Text(
                    'Hard',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isHardSet ? AppTheme.exerciseRingColor : currentSecondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: AppTheme.spacing_xs),

          IconButton(
            icon: Icon(Icons.remove_circle_outline, color: AppTheme.moveRingColor),
            onPressed: onDelete,
            iconSize: 22,
            padding: EdgeInsets.all(AppTheme.spacing_xs),
            constraints: BoxConstraints(),
            tooltip: 'Delete Set',
          ),
        ],
      ),
    );
  }
}
