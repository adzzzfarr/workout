import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/themes/dark_theme.dart';
import 'package:workout/data/exercise_data.dart';
import 'package:workout/data/performed_workout_data.dart';
import 'package:workout/data/template_workout_data.dart';
import 'package:workout/models/exercise.dart';
import 'package:workout/models/performed_workout.dart';
import 'package:workout/models/template_workout.dart';
import 'package:workout/pages/navigation_bar_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(BodyPartAdapter());
  Hive.registerAdapter(TemplateWorkoutAdapter());
  Hive.registerAdapter(PerformedWorkoutAdapter());
  await Hive.openBox('workout-database');
  runApp(const MyApp());
}

// Use this after any changes to backend logic. Call await.clearHiveDatabase() before registering TypeAdapters. This deletes all data in the box.
// Alternatively, delete the app from the emulator, then run flutter clean and flutter pub get. Then call flutter run.
Future<void> clearHiveDatabase() async {
  var box = await Hive.openBox('workout-database');
  await box.clear();
  await box.close();
  Hive.deleteBoxFromDisk('workout-database');
  Hive.deleteFromDisk();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TemplateWorkoutData(),
        ),
        ChangeNotifierProvider(
          create: (context) => PerformedWorkoutData(),
        ),
        ChangeNotifierProvider(
          create: (context) => ExerciseData(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: darkTheme,
        home: const NavigationBarPage(),
      ),
    );
  }
}
