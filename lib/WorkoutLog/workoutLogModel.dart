import 'package:intl/intl.dart';

class WorkoutLogEntry {
  final int id;
  final String workoutName;
  List<WarmUpRow> warmUpRows = [];
  List<SetRow> setRows = [];
  static int generateID() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyyMMddHHmmss');
    final timestamp = formatter.format(now);
    return int.parse(timestamp);
  }

  WorkoutLogEntry({
    required this.id,
    required this.workoutName,
    required this.warmUpRows,
    required this.setRows,
  });
}

class SetRow {
  int setNumber;
  double weight;
  int reps;

  SetRow({
    required this.setNumber,
    required this.weight,
    required this.reps,
  });
}

class WarmUpRow {
  double weight;
  int reps;

  WarmUpRow({
    required this.weight,
    required this.reps,
  });
}