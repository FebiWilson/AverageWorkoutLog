import 'package:averageworkoutlog/WorkoutLog/workoutLogModel.dart';
import 'package:averageworkoutlog/WorkoutLog/workoutLogProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';


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
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      color: Color(0xFF222838),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 5),
            Expanded(
              child: Text(entry.workoutName, style: TextStyle(
                fontWeight: FontWeight.bold
              ),),
            ),
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
            Row(
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
                        color: Color(0xFFc77f7b),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )),
              ],
            ),
            Divider(
              color: Colors.black,
              height: 1.0,
              thickness: 1.0,
            ),
            WarmUpList(
              warmUpRows: entry.warmUpRows,
              entry: entry,
            ),
            SetList(setRows: entry.setRows, entry: entry),
            TextButton(
                onPressed: () {
                  workoutLogProvider.addSetRow(
                      entry,
                      SetRow(
                          weight: 0,
                          reps: 0,
                          setNumber: entry.setRows.length + 1));
                },
                child: Text(
                  "+ Set",
                  style: TextStyle(
                    color: Color(0xFFc77f7b),
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
        return Slidable(
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
              color: Colors.black,
              icon: Icons.delete,
              onTap: () {
                // Handle delete action for the set row
                Provider.of<WorkoutLogProvider>(context, listen: false)
                    .deleteWarmUpRow(entry, warmUpRow);
              },
            ),
          ],
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(8.0),
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Color(0xFF222838),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Color(0xFF220720),
                          offset: Offset(2, 2),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: ColorFiltered(
                      colorFilter:
                          ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      child: Image.asset(
                        'assets/image/stretch.png',
                        height: 25,
                        width: 25,
                      )),
                ),
                title: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF222838),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Color(0xFF220720),
                          offset: Offset(2, 2),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        SizedBox(width: 30.0),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              suffixText: 'Kg',
                            ),
                            initialValue: warmUpRow.weight.toString(),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            onChanged: (value) {
                              Provider.of<WorkoutLogProvider>(context,
                                      listen: false)
                                  .updateWarmUpWeight(
                                      entry, warmUpRow, double.parse(value));
                            },
                          ),
                        ),
                        SizedBox(width: 30.0),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              suffixText: 'Reps',
                            ),
                            initialValue: warmUpRow.reps.toString(),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            onChanged: (value) {
                              Provider.of<WorkoutLogProvider>(context,
                                      listen: false)
                                  .updateWarmUpReps(
                                      entry, warmUpRow, int.parse(value));
                            },
                          ),
                        ),
                        SizedBox(width: 30.0),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(
                color: Colors.black,
                height: 1.0,
                thickness: 1.0,
              ),
            ],
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
          secondaryActions: [
            IconSlideAction(
              color: Colors.black,
              icon: Icons.delete,
              onTap: () {
                // Handle delete action for the set row
                Provider.of<WorkoutLogProvider>(context, listen: false)
                    .deleteSetRow(entry, setRow);
              },
            ),
          ],
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Color(0xFF222838),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Color(0xFF220720),
                            offset: Offset(2, 2),
                            blurRadius: 10.0),
                      ],
                    ),
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${setRow.setNumber}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))),
                title: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF222838),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Color(0xFF220720),
                          offset: Offset(2, 2),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        SizedBox(width: 30.0),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              suffixText: 'Kg',
                            ),
                            initialValue: setRow.weight.toString(),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            onChanged: (value) {
                              Provider.of<WorkoutLogProvider>(context,
                                      listen: false)
                                  .updateWeight(
                                      entry, setRow, double.parse(value));
                            },
                          ),
                        ),
                        SizedBox(width: 30.0),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              suffixText: 'Reps',
                            ),
                            initialValue: setRow.reps.toString(),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            onChanged: (value) {
                              Provider.of<WorkoutLogProvider>(context,
                                      listen: false)
                                  .updateReps(entry, setRow, int.parse(value));
                            },
                          ),
                        ),
                        SizedBox(width: 30.0),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(
                color: Colors.black,
                height: 1.0,
                thickness: 1.0,
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