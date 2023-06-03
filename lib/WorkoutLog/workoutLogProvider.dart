import 'package:averageworkoutlog/WorkoutLog/workoutLogModel.dart';
import 'package:flutter/material.dart';


class WorkoutLogProvider with ChangeNotifier {
  List<WorkoutLogEntry> workoutEntries = [
    WorkoutLogEntry(
      id: 1,
      workoutName: 'Overhead press',
      warmUpRows: [
        WarmUpRow(weight: 50.0, reps: 10),
        WarmUpRow(weight: 60.0, reps: 8),
      ],
      setRows: [
        SetRow(setNumber: 1, weight: 50.0, reps: 10),
        SetRow(setNumber: 2, weight: 60.0, reps: 8),
      ],
    ),
    WorkoutLogEntry(
      id: 2,
      workoutName: 'Barbell squat',
      warmUpRows: [
        WarmUpRow(weight: 100.0, reps: 10),
        WarmUpRow(weight: 120.0, reps: 8),
      ],
      setRows: [
        SetRow(setNumber: 1, weight: 100.0, reps: 10),
        SetRow(setNumber: 2, weight: 120.0, reps: 8),
      ],
    ),
    WorkoutLogEntry(
      id: 3,
      workoutName: 'Bench Press',
      warmUpRows: [
        WarmUpRow(weight: 80.0, reps: 10),
        WarmUpRow(weight: 90.0, reps: 8),
      ],
      setRows: [
        SetRow(setNumber: 1, weight: 80.0, reps: 10),
        SetRow(setNumber: 2, weight: 90.0, reps: 8),
      ],
    ),
  ];

  void addEntry(WorkoutLogEntry entry) {
    workoutEntries.add(entry);
    notifyListeners();
  }

  void deleteEntry(WorkoutLogEntry entry) {
    workoutEntries.remove(entry);
    notifyListeners();
  }

  void updateWeight(WorkoutLogEntry entry, SetRow setRow, double weight) {
    setRow.weight = weight;
    notifyListeners();
  }

  void updateReps(WorkoutLogEntry entry, SetRow setRow, int reps) {
    setRow.reps = reps;
    notifyListeners();
  }

  void updateWarmUpWeight(
      WorkoutLogEntry entry, WarmUpRow setRow, double weight) {
    setRow.weight = weight;
    notifyListeners();
  }

  void updateWarmUpReps(WorkoutLogEntry entry, WarmUpRow setRow, int reps) {
    setRow.reps = reps;
    notifyListeners();
  }

  void addWarmUpRow(WorkoutLogEntry entry, WarmUpRow warmUpRow) {
    entry.warmUpRows.add(warmUpRow);
    notifyListeners();
  }

  void addSetRow(WorkoutLogEntry entry, SetRow setRow) {
    entry.setRows.add(setRow);
    notifyListeners();
  }

  void deleteWarmUpRow(WorkoutLogEntry entry, WarmUpRow warmUpRow) {
    entry.warmUpRows.remove(warmUpRow);
    notifyListeners();
  }

  void deleteSetRow(WorkoutLogEntry entry, SetRow setRow) {
    entry.setRows.remove(setRow);
    correctSetNumbers(entry);
    notifyListeners();
  }

  void correctSetNumbers(WorkoutLogEntry entry) {
    for (int i = 0; i < entry.setRows.length; i++) {
      entry.setRows[i].setNumber = i + 1;
    }
  }
}
