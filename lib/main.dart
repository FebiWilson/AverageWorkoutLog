import 'package:averageworkoutlog/WorkoutLog/workoutLogProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'WorkoutLog/workoutLogScreen.dart';

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
      home: const WorkoutLogScreen(),
    );
  }
}




