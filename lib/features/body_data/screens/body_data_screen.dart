import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/features/body_data/widgets/BMIResultCard.dart';
import '../../../core/providers/body_data_provider.dart';
import '../../../core/models/body_data.dart';
import '../widgets/body_data_chart.dart';

class BodyDataScreen extends StatefulWidget {
  const BodyDataScreen({Key? key}) : super(key: key);

  @override
  State<BodyDataScreen> createState() => _BodyDataScreenState();
}

class _BodyDataScreenState extends State<BodyDataScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedMetric = 'weight';

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addEntry(BuildContext context) {
    final provider = Provider.of<BodyDataProvider>(context, listen: false);
    final weight = double.tryParse(_weightController.text);
    double? height;

    if (_heightController.text.isNotEmpty) {
      height = double.tryParse(_heightController.text);
    } else {
      height = provider.latestHeight;
    }

    if (weight == null || height == null || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid weight and height')),
      );
      return;
    }

    final entry = BodyData(
      weight: weight,
      height: height,
      date: DateTime.now(),
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );
    provider.addEntry(entry);
    if (_heightController.text.isNotEmpty) {
      provider.updateLatestHeight(entry);
    }

    _weightController.clear();
    _heightController.clear();
    _noteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Data & BMI'),
      ),
      body: SingleChildScrollView(
        child: Consumer<BodyDataProvider>(
          builder: (context, provider, _) {
            final latest = provider.entries.isNotEmpty ? provider.entries.first : null;
            final bmiValue = provider.getLatestBMI();
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Body Data',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _weightController,
                                  decoration: const InputDecoration(
                                    labelText: 'Weight (kg)',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.line_weight),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _heightController,
                                  decoration: InputDecoration(
                                    labelText: 'Height (m)',
                                    hintText: provider.latestHeight != null
                                        ? 'Current: 	${provider.latestHeight!.toStringAsFixed(2)}'
                                        : null,
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.height),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              labelText: 'Note (optional)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.note),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add Entry'),
                              onPressed: () => _addEntry(context),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (latest != null && bmiValue != null)
                    BMIResultCard(
                      bmi: bmiValue,
                      onEdit: () {
                        final heightController = TextEditingController();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Update Height'),
                            content: TextField(
                              controller: heightController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'New Height (m)',
                                hintText:
                                    'Current: ${provider.latestHeight?.toStringAsFixed(2)}',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  final newHeight =
                                      double.tryParse(heightController.text);
                                  if (newHeight != null && newHeight > 0) {
                                    final bodyData = BodyData(
                                      height: newHeight,
                                      date: DateTime.now(),
                                      weight: 0.0,
                                    );
                                    provider.updateLatestHeight(bodyData);
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'History',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              DropdownButton<String>(
                                value: _selectedMetric,
                                items: ['weight', 'height', 'bmi']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value.toUpperCase()),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedMetric = newValue!;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          BodyDataChart(
                              entries: provider.entries, metric: _selectedMetric),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: provider.entries.length,
                    itemBuilder: (context, index) {
                      final entry = provider.entries[index];
                      final subtitle =
                          'Date: ${entry.date.toLocal().toString().split(" ")[0]}' +
                              (entry.note != null ? '\nNote: ${entry.note}' : '');
                      return Dismissible(
                        key: Key(entry.date.toString()),
                        background: Container(color: Colors.red),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: const Text(
                                  'Are you sure you want to delete this entry?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) => provider.deleteEntry(index),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            title: Text(
                                'Weight: ${entry.weight} kg, Height: ${entry.height} m'),
                            subtitle: Text(subtitle),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => provider.deleteEntry(index),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
