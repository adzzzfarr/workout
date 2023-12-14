import 'package:flutter/material.dart';
import 'package:workout/data/date_time.dart';
import 'package:workout/data/hive_database.dart';
import 'package:workout/models/exercise.dart';
import 'package:workout/models/workout.dart';

class WorkoutData extends ChangeNotifier {
  final db = HiveDatabase();

  List<Workout> workoutList = [
    // default workouts
    Workout(
      name: "Upper Body",
      exercises: [
        Exercise(
          name: "Bench Press",
          weight: 10,
          sets: 3,
          reps: 10,
        ),
      ],
    ),
    Workout(
      name: "Lower Body",
      exercises: [
        Exercise(
          name: "Squat",
          weight: 10,
          sets: 3,
          reps: 10,
        ),
      ],
    ),
  ];

  void initialiseWorkoutList() {
    if (db.prevDataExists()) {
      workoutList = db.readFromDatabase();
    } else {
      // Save the default workouts
      db.saveToDatabase(workoutList);
    }

    loadHeatMap();
  }

  List<Workout> getWorkoutList() {
    return workoutList;
  }

  int getNumberOfExercises(String workoutName) {
    Workout intendedWorkout = getIntendedWorkout(workoutName);

    return intendedWorkout.exercises.length;
  }

  void addWorkout(String name) {
    workoutList.add(Workout(name: name, exercises: []));

    notifyListeners();

    db.saveToDatabase(workoutList);
  }

  void addExercise(
    String workoutName,
    String exerciseName,
    double weight,
    int sets,
    int reps,
  ) {
    Workout intendedWorkout = getIntendedWorkout(workoutName);

    intendedWorkout.exercises.add(
      Exercise(
        name: exerciseName,
        weight: weight,
        sets: sets,
        reps: reps,
      ),
    );

    notifyListeners();

    db.saveToDatabase(workoutList);
  }

  void checkOffExercise(String workoutName, String exerciseName) {
    Exercise intendedExercise = getIntendedExercise(workoutName, exerciseName);
    intendedExercise.isCompleted = !intendedExercise.isCompleted;

    notifyListeners();

    db.saveToDatabase(workoutList);
    loadHeatMap();
  }

  Workout getIntendedWorkout(String workoutName) {
    return workoutList.firstWhere((element) => element.name == workoutName);
  }

  Exercise getIntendedExercise(String workoutName, String exerciseName) {
    Workout intendedWorkout = getIntendedWorkout(workoutName);

    return intendedWorkout.exercises
        .firstWhere((element) => element.name == exerciseName);
  }

  String getStartDate() {
    return db.getStartDate();
  }

  Map<DateTime, int> heatMapDataSet = {};

  void loadHeatMap() {
    DateTime startDate = createDateTimeObj(getStartDate());

    int daysInBetween = DateTime.now().difference(startDate).inDays;

    for (int i = 0; i < daysInBetween + 1; i++) {
      String yyyymmdd = dateTimeToYYYYMMDD(startDate.add(Duration(days: i)));
      int completionStatus = db.getCompletionStatus(yyyymmdd);

      int year = startDate.add(Duration(days: i)).year;
      int month = startDate.add(Duration(days: i)).month;
      int day = startDate.add(Duration(days: i)).day;

      final eachDay = <DateTime, int>{
        DateTime(year, month, day): completionStatus
      };

      heatMapDataSet.addEntries(eachDay.entries);
    }
  }
}
