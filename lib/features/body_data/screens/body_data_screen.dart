import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/body_data_provider.dart';
import '../../../core/models/body_data.dart';

class BodyDataScreen extends StatefulWidget {
  const BodyDataScreen({Key? key}) : super(key: key);

  @override
  State<BodyDataScreen> createState() => _BodyDataScreenState();
}

class _BodyDataScreenState extends State<BodyDataScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addEntry(BuildContext context) {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    if (weight == null || height == null || height == 0) return;
    final note = _noteController.text.isEmpty ? null : _noteController.text;
    final entry = BodyData(weight: weight, height: height, date: DateTime.now(), note: note);
    Provider.of<BodyDataProvider>(context, listen: false).addEntry(entry);
    _weightController.clear();
    _heightController.clear();
    _noteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Body Data & BMI')),
      body: Consumer<BodyDataProvider>(
        builder: (context, provider, _) {
          final bmi = provider.getLatestBMI();
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Body Data', style: Theme.of(context).textTheme.titleLarge),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        decoration: const InputDecoration(labelText: 'Weight (kg)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _heightController,
                        decoration: const InputDecoration(labelText: 'Height (m)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'Note (optional)'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _addEntry(context),
                  child: const Text('Add Entry'),
                ),
                const SizedBox(height: 24),
                if (bmi != null)
                  Text('Latest BMI: ${bmi.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Text('History', style: Theme.of(context).textTheme.titleLarge),
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.entries.length,
                    itemBuilder: (context, index) {
                      final entry = provider.entries[index];
                      final subtitle = 'Date: ${entry.date.toLocal().toString().split(" ")[0]}' + (entry.note != null ? '\nNote: ${entry.note}' : '');
                      return ListTile(
                        title: Text('Weight: ${entry.weight} kg, Height: ${entry.height} m'),
                        subtitle: Text(subtitle),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => provider.deleteEntry(index),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 