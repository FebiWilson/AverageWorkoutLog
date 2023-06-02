import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkoutLogProvider(),
      child: MaterialApp(
        title: 'Workout Log',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: WorkoutLogScreen(),
      ),
    );
  }
}

class WorkoutLogScreen extends StatelessWidget {
  const WorkoutLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Log'),
      ),
      body: Consumer<WorkoutLogProvider>(
        builder: (context, workoutLogProvider, _) {
          final workoutEntries = workoutLogProvider.workoutEntries;
          return ListView.builder(
            itemCount: workoutEntries.length,
            itemBuilder: (context, index) {
              final entry = workoutEntries[index];
              return Dismissible(
                key: Key(entry.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) {
                  Provider.of<WorkoutLogProvider>(context, listen: false)
                      .deleteEntry(entry);
                },
                child: WorkoutLogEntryCard(entry: entry),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open a dialog to add a new workout log entry
          showDialog(
            context: context,
            builder: (context) => AddWorkoutDialog(),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class WorkoutLogEntryCard extends StatelessWidget {
  final WorkoutLogEntry entry;

  WorkoutLogEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(entry.workoutName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Warm-up', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            WarmUpList(warmUpRows: entry.warmUpRows),
            SizedBox(height: 8.0),
            Text('Sets', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            SetList(setRows: entry.setRows, entry: entry),
          ],
        ),
      ),
    );
  }
}

class WarmUpList extends StatelessWidget {
  final List<String> warmUpRows;

  WarmUpList({required this.warmUpRows});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: warmUpRows.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.person),
          title: Text(warmUpRows[index]),
        );
      },
    );
  }
}

class SetList extends StatelessWidget {
  final List<SetRow> setRows;
  final WorkoutLogEntry entry; // Add this line

  SetList({required this.setRows, required this.entry});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: setRows.length,
      itemBuilder: (context, index) {
        final setRow = setRows[index];
        return ListTile(
          leading: Text('Set ${setRow.setNumber}'),
          title: Row(
            children: [
              Text('Weight: '),
              SizedBox(width: 8.0),
              Expanded(
                child: TextFormField(
                  initialValue: setRow.weight.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    Provider.of<WorkoutLogProvider>(context, listen: false)
                        .updateWeight(entry, setRow, double.parse(value));
                  },
                ),
              ),
              SizedBox(width: 16.0),
              Text('Reps: '),
              SizedBox(width: 8.0),
              Expanded(
                child: TextFormField(
                  initialValue: setRow.reps.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    Provider.of<WorkoutLogProvider>(context, listen: false)
                        .updateReps(entry, setRow, int.parse(value));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AddWorkoutDialog extends StatefulWidget {
  @override
  _AddWorkoutDialogState createState() => _AddWorkoutDialogState();
}

class _AddWorkoutDialogState extends State<AddWorkoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _workoutNameController = TextEditingController();
  final TextEditingController _warmUpController = TextEditingController();
  final TextEditingController _setController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Workout Log Entry'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _workoutNameController,
              decoration: InputDecoration(labelText: 'Workout Name'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a workout name.';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _warmUpController,
              decoration: InputDecoration(labelText: 'Warm-up'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter warm-up details.';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _setController,
              decoration: InputDecoration(labelText: 'Sets'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter set details.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newEntry = WorkoutLogEntry(
                id: WorkoutLogEntry.generateID() as int,
                workoutName: _workoutNameController.text,
                warmUpRows: [_warmUpController.text],
                setRows: [SetRow(setNumber: 1, weight: 0.0, reps: 0)],
              );
              Provider.of<WorkoutLogProvider>(context, listen: false)
                  .addEntry(newEntry);
              Navigator.pop(context);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}

class WorkoutLogEntry {
  final int id;
  final String workoutName;
  final List<String> warmUpRows;
  final List<SetRow> setRows;
  

static String generateID() {
  final now = DateTime.now();
  final formatter = DateFormat('yyyyMMddHHmmss');
  final timestamp = formatter.format(now);
  return timestamp;
}


  WorkoutLogEntry({
    required this.id,
    required this.workoutName,
    required this.warmUpRows,
    required this.setRows,
  });
}

class SetRow {
  final int setNumber;
  double weight;
  int reps;

  SetRow({
    required this.setNumber,
    required this.weight,
    required this.reps,
  });
}

class WorkoutLogProvider with ChangeNotifier {
  List<WorkoutLogEntry> workoutEntries = [
    WorkoutLogEntry(
      id: 1,
      workoutName: 'Overhead press',
      warmUpRows: ['Warm-up 1', 'Warm-up 2'],
      setRows: [
        SetRow(setNumber: 1, weight: 50.0, reps: 10),
        SetRow(setNumber: 2, weight: 60.0, reps: 8),
      ],
    ),
    WorkoutLogEntry(
      id: 2,
      workoutName: 'Barbell squat',
      warmUpRows: ['Warm-up 1', 'Warm-up 2'],
      setRows: [
        SetRow(setNumber: 1, weight: 100.0, reps: 10),
        SetRow(setNumber: 2, weight: 120.0, reps: 8),
      ],
    ),
    WorkoutLogEntry(
      id: 3,
      workoutName: 'Bench Press',
      warmUpRows: ['Warm-up 1', 'Warm-up 2'],
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
}
