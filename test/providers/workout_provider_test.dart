import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:workout_tracker/core/models/workout.dart';
import 'package:workout_tracker/core/models/workout_exercise.dart';
import 'package:workout_tracker/core/models/workout_set.dart';
import 'package:workout_tracker/core/providers/workout_provider.dart';

// Generate mocks for Box and Workout
@GenerateMocks([Box, Workout])
import 'workout_provider_test.mocks.dart';

void main() {
  group('WorkoutProvider Tests', () {
    late WorkoutProvider workoutProvider;
    late MockBox<Workout> mockWorkoutsBox;

    setUp(() {
      mockWorkoutsBox = MockBox<Workout>();
      // It's important that the WorkoutProvider is instantiated with the mock box.
      workoutProvider = WorkoutProvider(mockWorkoutsBox);

      // Ensure the provider considers itself initialized after setup if box is provided.
      // This simulates the constructor logic: if (workoutsBox != null) { _isInitialized = true; }
      // Forcing initialization state for testing purposes if direct injection doesn't set it.
      // Alternatively, call an explicit initialize method if the constructor doesn't fully set it up.
      // For this test, we assume the constructor handles initialization when a box is passed.
    });

    tearDown(() {
      // It's good practice to close mocks if they have such methods, though not strictly necessary for Mockito.
      // verify(mockWorkoutsBox.close()).called(1); // Example if box had a close method to verify
    });

    test('Initial workouts list is empty if box is empty and provider is initialized', () {
      when(mockWorkoutsBox.values).thenReturn([]); // Simulate empty box
      // The constructor calls _updateCache if a box is provided.
      // So, re-instantiate or call an init method that uses the mocked box values.
      workoutProvider = WorkoutProvider(mockWorkoutsBox); // Re-init with mocked behavior
      expect(workoutProvider.workouts, isEmpty);
    });

    test('addWorkout adds a workout to the box and updates cache', () async {
      final workout = Workout(id: '1', date: DateTime.now(), exercises: []);

      // Mock the behavior of the box's add method.
      // Since box.add returns Future<int>, we mock it to return a dummy int.
      when(mockWorkoutsBox.add(any)).thenAnswer((_) async => 0);
      // Mock values to reflect the state after adding.
      when(mockWorkoutsBox.values).thenReturn([workout]);

      await workoutProvider.addWorkout(workout);

      verify(mockWorkoutsBox.add(workout)).called(1);
      expect(workoutProvider.workouts.length, 1);
      expect(workoutProvider.workouts.first.id, '1');
    });

    test('updateWorkout updates an existing workout in the box', () async {
      final originalWorkout = Workout(id: '1', date: DateTime.now(), exercises: [], notes: "Original");
      final updatedWorkout = Workout(id: '1', date: DateTime.now(), exercises: [], notes: "Updated");

      // Prime the provider with the original workout
      when(mockWorkoutsBox.values).thenReturn([originalWorkout]);
      workoutProvider = WorkoutProvider(mockWorkoutsBox); // Re-initialize to load initial data

      // Mock putAt for update
      // Assuming the workout is at index 0
      when(mockWorkoutsBox.putAt(0, updatedWorkout)).thenAnswer((_) async {});

      // After update, the box values should reflect the updated workout
      when(mockWorkoutsBox.values).thenReturn([updatedWorkout]);

      await workoutProvider.updateWorkout(updatedWorkout);

      verify(mockWorkoutsBox.putAt(0, updatedWorkout)).called(1);
      expect(workoutProvider.workouts.first.notes, "Updated");
    });

    test('deleteWorkout removes a workout from the box', () async {
      final workout1 = Workout(id: '1', date: DateTime.now(), exercises: []);
      final workout2 = Workout(id: '2', date: DateTime.now().add(Duration(days:1)), exercises: []);

      // Initial state with two workouts
      // Hive keys are dynamic, often integers for auto-increment. Let's assume keys 0 and 1.
      when(mockWorkoutsBox.values).thenReturn([workout1, workout2]);
      when(mockWorkoutsBox.toMap()).thenReturn({0: workout1, 1: workout2});
      workoutProvider = WorkoutProvider(mockWorkoutsBox);

      expect(workoutProvider.workouts.length, 2);

      // Mock delete operation for key 0 (workout1)
      when(mockWorkoutsBox.delete(0)).thenAnswer((_) async {});
      // After deletion, box values should only contain workout2
      when(mockWorkoutsBox.values).thenReturn([workout2]);
      when(mockWorkoutsBox.toMap()).thenReturn({1: workout2}); // Reflect deletion in map

      await workoutProvider.deleteWorkout('1');

      verify(mockWorkoutsBox.delete(0)).called(1); // Verifying deletion with the correct Hive key
      expect(workoutProvider.workouts.length, 1);
      expect(workoutProvider.workouts.first.id, '2');
    });

    test('getWorkoutsForDay returns correct workouts', () {
      final today = DateTime.now();
      final yesterday = today.subtract(Duration(days: 1));
      final tomorrow = today.add(Duration(days: 1));

      final workoutToday = Workout(id: 'today', date: today, exercises: []);
      final workoutYesterday = Workout(id: 'yesterday', date: yesterday, exercises: []);
      final workoutTomorrow = Workout(id: 'tomorrow', date: tomorrow, exercises: []);

      when(mockWorkoutsBox.values).thenReturn([workoutTomorrow, workoutToday, workoutYesterday]);
      workoutProvider = WorkoutProvider(mockWorkoutsBox); // Re-initialize

      final result = workoutProvider.getWorkoutsForDay(today);
      expect(result.length, 1);
      expect(result.first.id, 'today');
    });

    test('getLatestWorkout returns the most recent workout', () {
      final today = DateTime.now();
      final yesterday = today.subtract(Duration(days: 1));

      final workoutToday = Workout(id: 'today', date: today, exercises: []);
      final workoutYesterday = Workout(id: 'yesterday', date: yesterday, exercises: []);

      // Ensure workouts are sorted by date descending in the mock setup for `values`
      // as _updateCache sorts them.
      when(mockWorkoutsBox.values).thenReturn([workoutToday, workoutYesterday]);
      workoutProvider = WorkoutProvider(mockWorkoutsBox);

      final latest = workoutProvider.getLatestWorkout();
      expect(latest, isNotNull);
      expect(latest!.id, 'today');
    });

    test('getLatestWorkout returns null if no workouts exist', () {
      when(mockWorkoutsBox.values).thenReturn([]);
      workoutProvider = WorkoutProvider(mockWorkoutsBox);

      final latest = workoutProvider.getLatestWorkout();
      expect(latest, isNull);
    });

    test('createEmptyWorkout returns a non-null workout with a valid ID and current date', () {
      final emptyWorkout = workoutProvider.createEmptyWorkout();
      expect(emptyWorkout, isNotNull);
      expect(emptyWorkout.id, isNotEmpty);
      // Check if the date is recent (e.g., within the last few seconds)
      expect(DateTime.now().difference(emptyWorkout.date).inSeconds < 5, isTrue);
      expect(emptyWorkout.exercises, isEmpty);
      expect(emptyWorkout.workoutName, 'New Workout');
    });

    // Example of testing a stats calculation method
    test('getTotalWeightLifted calculates sum correctly', () {
        final exercises1 = [
            WorkoutExercise(exerciseId: 'e1', exerciseName: 'Ex1', muscleGroup: 'Chest', sets: [
                WorkoutSet(id: 's1', weight: 50, reps: 10, timestamp: DateTime.now()), // 500
                WorkoutSet(id: 's2', weight: 60, reps: 8, timestamp: DateTime.now()),  // 480
            ]), // Total for Ex1 = 980
        ];
         final exercises2 = [
            WorkoutExercise(exerciseId: 'e2', exerciseName: 'Ex2', muscleGroup: 'Legs', sets: [
                WorkoutSet(id: 's3', weight: 100, reps: 5, timestamp: DateTime.now()), // 500
            ]), // Total for Ex2 = 500
        ];
        final workout1 = Workout(id: 'w1', date: DateTime.now(), exercises: exercises1); // Total = 980
        final workout2 = Workout(id: 'w2', date: DateTime.now(), exercises: exercises2); // Total = 500

        when(mockWorkoutsBox.values).thenReturn([workout1, workout2]);
        workoutProvider = WorkoutProvider(mockWorkoutsBox);

        // Test for a specific date (today)
        expect(workoutProvider.getTotalWeightLifted(DateTime.now()), 980.0 + 500.0);
        // Test for all dates (by passing null or no argument)
        expect(workoutProvider.getTotalWeightLifted(), 980.0 + 500.0);
    });


  });
}
