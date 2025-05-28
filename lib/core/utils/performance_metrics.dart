// First, let's create a new utility class for the performance calculations
// lib/core/utils/performance_metrics.dart

import 'dart:math';

import 'package:workout_tracker/core/models/workout_set.dart';

class PerformanceMetrics {
  // 1. Strength Training Calculations
  static double calculateOneRepMax(double weight, int reps, {String formula = 'epley'}) {
    if (formula == 'epley') {
      // Epley Formula: 1RM = Weight × (1 + Reps/30)
      return weight * (1 + reps / 30.0);
    } else if (formula == 'brzycki') {
      // Brzycki Formula: 1RM = Weight / (1.0278 - 0.0278 × Reps)
      return weight / (1.0278 - 0.0278 * reps);
    }
    return weight; // Default fallback
  }
  
  static double calculateTrainingVolume(List<WorkoutSet> sets) {
    // Volume = Sets × Reps × Weight
    double volume = 0;
    for (var set in sets) {
      volume += set.weight * set.reps;
    }
    return volume;
  }
  
  static double calculateRelativeStrength(double weightLifted, double bodyWeight) {
    // Strength Ratio = Weight Lifted / Body Weight
    if (bodyWeight == 0) return 0;
    return weightLifted / bodyWeight;
  }
  
  // 2. Progressive Overload Calculations
  static double calculateVolumeIncrease(double currentVolume, double previousVolume) {
    // % Change = [(Current Volume - Previous Volume) / Previous Volume] × 100
    if (previousVolume == 0) return 0;
    return ((currentVolume - previousVolume) / previousVolume) * 100;
  }
  
  static double calculateTonnage(List<WorkoutSet> sets) {
    // Total Tonnage = Sum of (Weight × Reps) for all sets
    double tonnage = 0;
    for (var set in sets) {
      tonnage += set.weight * set.reps;
    }
    return tonnage;
  }
  
  // 3. Cardiovascular Performance Calculations
  static double calculateHeartRateReserve(int maxHR, int restingHR) {
    // HRR = Max Heart Rate - Resting Heart Rate
    return (maxHR - restingHR).toDouble();
  }
  
  static double calculateTargetHeartRate(int restingHR, double intensityPercent, double hrr) {
    // Target HR = Resting HR + (% Intensity × HRR)
    return restingHR + (intensityPercent * hrr);
  }
  
  static double estimateVO2Max(int maxHR, int restingHR) {
    // VO2 Max ≈ 15 × (HR max / HR rest)
    if (restingHR == 0) return 0;
    return 15 * (maxHR / restingHR);
  }
  
  static double calculateCaloriesBurned(
    int age, 
    double weight, 
    int heartRate, 
    int time, 
    {String gender = 'male'}
  ) {
    if (gender == 'male') {
      // Men: Calories = [(Age × 0.2017) + (Weight × 0.1988) + (HR × 0.6309) - 55.0969] × Time/4.184
      return ((age * 0.2017) + (weight * 0.1988) + (heartRate * 0.6309) - 55.0969) * time / 4.184;
    } else {
      // Women: Calories = [(Age × 0.074) + (Weight × 0.1263) + (HR × 0.4472) - 20.4022] × Time/4.184
      return ((age * 0.074) + (weight * 0.1263) + (heartRate * 0.4472) - 20.4022) * time / 4.184;
    }
  }
  
  // 4. Body Composition Calculations
  static double calculateFFMI(double fatFreeMass, double height) {
    // FFMI = Fat Free Mass (kg) / Height (m)²
    if (height == 0) return 0;
    return fatFreeMass / (pow(height, 2));
  }
  
  static double calculateBodyFatPercentage(
    double waist, 
    double neck, 
    double height, 
    String gender,
    {double? hip}
  ) {
    if (gender == 'male') {
      // Navy Method (Men): BF% = 495 / (1.0324 - 0.19077 × log10(waist - neck) + 0.15456 × log10(height)) - 450
      return 495 / (1.0324 - 0.19077 * log(waist - neck) / ln10 + 0.15456 * log(height) / ln10) - 450;
    } else if (gender == 'female' && hip != null) {
      // Navy Method (Women): BF% = 495 / (1.29579 - 0.35004 × log10(waist + hip - neck) + 0.22100 × log10(height)) - 450
      return 495 / (1.29579 - 0.35004 * log(waist + hip - neck) / ln10 + 0.22100 * log(height) / ln10) - 450;
    }
    return 0;
  }
  
  // 5. Power Output Calculations
  static double calculatePower(double force, double distance, double time) {
    // Power = Force × Distance / Time
    if (time == 0) return 0;
    return (force * distance) / time;
  }
  
  static double calculatePowerFromWeight(double weight, double height, double time) {
    // Power = Weight × 9.81 × Height / Time
    if (time == 0) return 0;
    return (weight * 9.81 * height) / time;
  }
  
  static double calculateRateOfForceDevelopment(double forceChange, double timeChange) {
    // RFD = Force Change / Time Change
    if (timeChange == 0) return 0;
    return forceChange / timeChange;
  }
  
  // 6. Work Capacity Calculations
  static double calculateTrainingDensity(double totalVolume, double totalTime) {
    // Density = Total Volume / Total Time
    if (totalTime == 0) return 0;
    return totalVolume / totalTime;
  }
  
  static double calculateMETScore(double caloriesBurnedPerHour, double weightKg) {
    // METs = Calories burned per hour / (Weight in kg × 3.5)
    if (weightKg == 0) return 0;
    return caloriesBurnedPerHour / (weightKg * 3.5);
  }
  
  // 7. Recovery Metrics
  static double calculateHeartRateRecovery(int heartRateAtStop, int heartRateAfter1Min) {
    // HRR = Heart Rate at Exercise Stop - Heart Rate 1 min after
    return (heartRateAtStop - heartRateAfter1Min).toDouble();
  }
  
  // 8. Performance Ratios
  static double calculatePushPullRatio(double benchPress1RM, double row1RM) {
    // Push/Pull Ratio = Bench Press 1RM / Row 1RM
    if (row1RM == 0) return 0;
    return benchPress1RM / row1RM;
  }
  
  static double calculateSquatDeadliftRatio(double squat1RM, double deadlift1RM) {
    // Squat/Deadlift Ratio = Squat 1RM / Deadlift 1RM
    if (deadlift1RM == 0) return 0;
    return squat1RM / deadlift1RM;
  }
  
  // 9. Improvement Rate Calculations
  static double calculatePercentageImprovement(double currentValue, double previousValue) {
    // % Improvement = [(Current Value - Previous Value) / Previous Value] × 100
    if (previousValue == 0) return 0;
    return ((currentValue - previousValue) / previousValue) * 100;
  }
  
  static double calculateMonthlyProgressRate(double endOfMonthValue, double startOfMonthValue) {
    // MPR = (End of Month Value - Start of Month Value) / Start of Month Value × 100
    if (startOfMonthValue == 0) return 0;
    return ((endOfMonthValue - startOfMonthValue) / startOfMonthValue) * 100;
  }
  
  // Removed calculateBMI method 2025-05-28
  // static double calculateBMI(double weight, double height) {
  //   // BMI = Weight (kg) / Height (m)²
  //   if (height <= 0) return 0;
  //   final heightInMeters = height / 100; // Assuming height is in cm
  //   return weight / (heightInMeters * heightInMeters);
  // }
}