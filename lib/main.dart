import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => WorkoutLogProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Log',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.dark().copyWith(background: Colors.black),
      ),
      home: WorkoutLogScreen(),
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
              return WorkoutLogEntryCard(
                entry: entry,
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
    final workoutLogProvider = Provider.of<WorkoutLogProvider>(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Set the border radius here
      ),
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Color.fromARGB(193, 13, 13, 71),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(entry.workoutName),
            IconButton(
              onPressed: () {
                workoutLogProvider.deleteEntry(entry);
              },
              icon: Icon(Icons.delete),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
                onPressed: () {
                  workoutLogProvider.addWarmUpRow(
                      entry, WarmUpRow(weight: 0, reps: 0));
                },
                child: Text(
                  "+ Warm Up",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                )),
            SizedBox(height: 8.0),
            WarmUpList(
              warmUpRows: entry.warmUpRows,
              entry: entry,
            ),
            SizedBox(height: 8.0),
            SizedBox(height: 8.0),
            SetList(setRows: entry.setRows, entry: entry),
            TextButton(
                onPressed: () {
                  workoutLogProvider.addSetRow(
                      entry,
                      SetRow(
                          weight: 0, reps: 0, setNumber: entry.setRows.length+1));
                },
                child: Text(
                  "+ Set",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class WarmUpList extends StatelessWidget {
  final List<WarmUpRow> warmUpRows;
  final WorkoutLogEntry entry;

  WarmUpList({required this.warmUpRows, required this.entry});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: warmUpRows.length,
      itemBuilder: (context, index) {
        final warmUpRow = warmUpRows[index];
        return Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black),)
          ),
          child: Slidable(
            actionPane: SlidableDrawerActionPane(),
            key: Key('WarmUpRow_$index'),
            dismissal: SlidableDismissal(
              child: SlidableDrawerDismissal(),
              onDismissed: (actionType) {
                // Handle delete action for the set row
                Provider.of<WorkoutLogProvider>(context, listen: false)
                    .deleteWarmUpRow(entry, warmUpRow);
              },
              dismissThresholds: <SlideActionType, double>{
                SlideActionType.secondary: 1.0,
              },
              onWillDismiss: (actionType) {
                return false; // Prevent dismissal
              },
            ),
            secondaryActions: [
              IconSlideAction(
                caption: 'Delete',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () {
                  // Handle delete action for the set row
                  Provider.of<WorkoutLogProvider>(context, listen: false)
                      .deleteWarmUpRow(entry, warmUpRow);
                },
              ),
            ],
            child: ListTile(
              leading: Icon(Icons.person),
              title: Row(
                children: [
                  const Text('Weight: '),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none
                      ),
                      initialValue: warmUpRow.weight.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        Provider.of<WorkoutLogProvider>(context, listen: false)
                            .updateWarmUpWeight(
                                entry, warmUpRow, double.parse(value));
                      },
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Text('Reps: '),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none
                      ),
                      initialValue: warmUpRow.reps.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        Provider.of<WorkoutLogProvider>(context, listen: false)
                            .updateWarmUpReps(entry, warmUpRow, int.parse(value));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SetList extends StatelessWidget {
  final List<SetRow> setRows;
  final WorkoutLogEntry entry;

  SetList({required this.setRows, required this.entry});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: setRows.length,
      itemBuilder: (context, index) {
        final setRow = setRows[index];
        return Slidable(
          actionPane: SlidableDrawerActionPane(),
          key: Key('setRow_$index'),
          dismissal: SlidableDismissal(
            child: SlidableDrawerDismissal(),
            onDismissed: (actionType) {
              // Handle delete action for the set row
              Provider.of<WorkoutLogProvider>(context, listen: false)
                  .deleteSetRow(entry, setRow);
            },
            dismissThresholds: <SlideActionType, double>{
              SlideActionType.secondary: 1.0,
            },
            onWillDismiss: (actionType) {
              return false; // Prevent dismissal
            },
          ),
          child: ListTile(
            leading: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 63, 21, 131),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Color.fromARGB(255, 10, 2, 54).withOpacity(1),
                                  offset: Offset(2, 2),
                                  blurRadius: 10.0),
                            ],
              ),
              child: Text('${setRow.setNumber}', style: TextStyle(fontWeight: FontWeight.bold),)),
            title: Container(
              decoration: BoxDecoration(
                border: Border.all()
              ),
              child: Row(
                children: [
                  Text('Weight: '),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                          border: InputBorder.none
                        ),
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
                      decoration: InputDecoration(
                          border: InputBorder.none
                        ),
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
            ),
          ),
          secondaryActions: [
            IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () {
                // Handle delete action for the set row
                Provider.of<WorkoutLogProvider>(context, listen: false)
                    .deleteSetRow(entry, setRow);
              },
            ),
          ],
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
  TextEditingController _workoutNameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _workoutNameController = TextEditingController();
  }

  @override
  void dispose() {
    _workoutNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutLogProvider = Provider.of<WorkoutLogProvider>(context);

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
                id: WorkoutLogEntry.generateID(),
                workoutName: _workoutNameController.text,
                warmUpRows: [],
                setRows: [],
              );
              workoutLogProvider.addEntry(newEntry);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

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
  final int setNumber;
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
    notifyListeners();
  }
}
