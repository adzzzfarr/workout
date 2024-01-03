import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/workout_data.dart';
import 'package:workout/models/exercise.dart';
import 'package:workout/models/workout.dart';
import 'package:workout/pages/home_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(WorkoutAdapter());
  await Hive.openBox('workout-database');
  runApp(const MyApp());
}

// Use this after any changes to backend logic. Call await.clearHiveDatabase() before registering TypeAdapters. This deletes all data in the box.
// Alternatively, delete the app from the emulator, then run flutter clean and flutter pub get. Then call flutter run.
Future<void> clearHiveDatabase() async {
  var box = await Hive.openBox('workout-database');
  await box.clear();
  await box.close();
  Hive.deleteFromDisk();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkoutData(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}
