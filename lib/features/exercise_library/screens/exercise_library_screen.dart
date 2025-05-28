import 'package:flutter/material.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  String _search = '';
  String _selectedMuscle = 'All';

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with real exercise data
    final exercises = [
      {'name': 'Bench Press', 'muscle': 'Chest', 'image': null},
      {'name': 'Squat', 'muscle': 'Legs', 'image': null},
      {'name': 'Deadlift', 'muscle': 'Back', 'image': null},
    ];
    final filtered = exercises.where((e) =>
      (_selectedMuscle == 'All' || e['muscle'] == _selectedMuscle) &&
      (e['name'] as String).toLowerCase().contains(_search.toLowerCase())
    ).toList();
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search exercises',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          DropdownButton<String>(
            value: _selectedMuscle,
            items: ['All', 'Chest', 'Legs', 'Back'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) => setState(() => _selectedMuscle = v!),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final ex = filtered[i];
                return ListTile(
                  leading: (ex['image'] is String && (ex['image'] as String).isNotEmpty)
                    ? Image.asset(ex['image'] as String)
                    : const Icon(Icons.fitness_center),
                  title: Text((ex['name'] ?? '').toString()),
                  subtitle: Text((ex['muscle'] ?? '').toString()),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_circle_fill),
                    onPressed: () {
                      // TODO: Show exercise video
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 