import 'package:flutter/material.dart';

class BMIResultCard extends StatelessWidget {
  final double bmi;
  final VoidCallback onEdit;

  const BMIResultCard({
    Key? key,
    required this.bmi,
    required this.onEdit,
  }) : super(key: key);

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Widget _buildInfoColumn(BuildContext context) {
    final category = _bmiCategory(bmi);
    final titleStyle = Theme.of(context)
        .textTheme
        .titleLarge!
        .copyWith(fontWeight: FontWeight.bold);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BMI', style: titleStyle),
        Text(
          bmi.toStringAsFixed(2),
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        Text(category, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildEditButton() {
    return IconButton(
      icon: const Icon(Icons.edit),
      tooltip: 'Edit Height',
      onPressed: onEdit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoColumn(context),
            _buildEditButton(),
          ],
        ),
      ),
    );
  }
}