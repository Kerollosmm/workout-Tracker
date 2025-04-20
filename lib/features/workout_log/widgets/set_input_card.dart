import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // Set number
          SizedBox(
            width: 40,
            child: Text(
              'Set $setNumber',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          
          // Weight input
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: TextFormField(
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  border: OutlineInputBorder(),
                  suffixText: weightUnit,
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                initialValue: weight > 0 ? weight.toString() : '',
                onChanged: (value) {
                  final parsedValue = double.tryParse(value) ?? 0;
                  onWeightChanged(parsedValue);
                },
              ),
            ),
          ),
          
          // Reps input
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: TextFormField(
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: reps > 0 ? reps.toString() : '',
                onChanged: (value) {
                  final parsedValue = int.tryParse(value) ?? 0;
                  onRepsChanged(parsedValue);
                },
              ),
            ),
          ),

          // Hard set toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              onTap: () => onHardSetChanged(!isHardSet),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isHardSet ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isHardSet ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 16,
                      color: isHardSet ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Hard',
                      style: TextStyle(
                        fontSize: 12,
                        color: isHardSet ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Delete button
          IconButton(
            icon: Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: onDelete,
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
