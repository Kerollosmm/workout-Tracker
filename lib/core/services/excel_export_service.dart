import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart' as excel_package;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_tracker/core/models/workout.dart';

class ExcelExportService {
  /// Exports the given list of workouts to an Excel file.
  ///
  /// Returns the path to the saved file, or null if the export fails or is cancelled.
  Future<String?> exportWorkouts(List<Workout> workouts) async {
    if (workouts.isEmpty) {
      debugPrint('ExcelExportService: No workouts to export.');
      return null;
    }

    // Check and request storage permissions on Android
    if (Platform.isAndroid) {
      PermissionStatus status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      if (!status.isGranted) {
        debugPrint('ExcelExportService: Storage permission denied for Excel export.');
        // Consider throwing a specific exception or returning an error code
        // that the UI can use to show a user-friendly message.
        return null;
      }
    }

    try {
      final excel = excel_package.Excel.createExcel();
      final sheet = excel['Workout Data'];

      // Add headers
      final headers = [
        'Date',
        'Workout Name',
        'Exercise Name',
        'Muscle Group',
        'Set Number',
        'Reps',
        'Weight',
        'Is Hard Set',
        'Set Notes',
        'Workout Notes',
        'Workout Duration (seconds)',
      ];
      for (var i = 0; i < headers.length; i++) {
        sheet
            .cell(excel_package.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = excel_package.TextCellValue(headers[i]);
      }

      int rowIndex = 1;
      for (final workout in workouts) {
        for (final exerciseInWorkout in workout.exercises) {
          if (exerciseInWorkout.sets.isEmpty) {
            // Log exercises with no sets
            final row = [
              excel_package.TextCellValue(DateFormat('yyyy-MM-dd HH:mm').format(workout.date)),
              excel_package.TextCellValue(workout.workoutName ?? ''),
              excel_package.TextCellValue(exerciseInWorkout.exerciseName),
              excel_package.TextCellValue(exerciseInWorkout.muscleGroup),
              excel_package.TextCellValue('-'), // Set Number
              excel_package.TextCellValue('-'), // Reps
              excel_package.TextCellValue('-'), // Weight
              excel_package.TextCellValue('-'), // Is Hard Set
              excel_package.TextCellValue('-'), // Set Notes
              excel_package.TextCellValue(workout.notes ?? ''),
              excel_package.IntCellValue(workout.duration),
            ];
            for (var i = 0; i < row.length; i++) {
              sheet
                  .cell(excel_package.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex))
                  .value = row[i];
            }
            rowIndex++;
          } else {
            for (var i = 0; i < exerciseInWorkout.sets.length; i++) {
              final set = exerciseInWorkout.sets[i];
              final row = [
                excel_package.TextCellValue(DateFormat('yyyy-MM-dd HH:mm').format(workout.date)),
                excel_package.TextCellValue(workout.workoutName ?? ''),
                excel_package.TextCellValue(exerciseInWorkout.exerciseName),
                excel_package.TextCellValue(exerciseInWorkout.muscleGroup),
                excel_package.IntCellValue(i + 1), // Set Number
                excel_package.IntCellValue(set.reps),
                excel_package.DoubleCellValue(set.weight),
                excel_package.TextCellValue(set.isHardSet.toString()),
                excel_package.TextCellValue(set.notes ?? ''),
                excel_package.TextCellValue(workout.notes ?? ''),
                excel_package.IntCellValue(workout.duration),
              ];
              for (var j = 0; j < row.length; j++) {
                sheet
                    .cell(excel_package.CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex))
                    .value = row[j];
              }
              rowIndex++;
            }
          }
        }
      }

      // Sequential file naming
      final prefs = await SharedPreferences.getInstance();
      int exportCounter = prefs.getInt('excel_export_counter') ?? 0;
      exportCounter++;

      final String suggestedFileName = 'workout_tracker_export_$exportCounter.xlsx';

      final List<int>? fileBytes = excel.encode();
      if (fileBytes == null) {
        debugPrint('ExcelExportService: Failed to encode Excel data to bytes.');
        return null;
      }

      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Select where to save the Excel file:',
        fileName: suggestedFileName,
        allowedExtensions: ['xlsx'],
        type: FileType.custom,
        bytes: Uint8List.fromList(fileBytes),
      );

      if (outputFile != null) {
        await prefs.setInt('excel_export_counter', exportCounter);
        debugPrint('ExcelExportService: Workout data exported to $outputFile');
        return outputFile;
      } else {
        debugPrint('ExcelExportService: Excel export cancelled or file saving failed.');
        return null;
      }
    } catch (e) {
      debugPrint('ExcelExportService: Error exporting workout data: $e');
      // Consider throwing a specific exception that the UI can catch
      // to show a user-friendly error message.
      return null;
    }
  }
}
