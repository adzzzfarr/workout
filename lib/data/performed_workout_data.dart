import 'package:flutter/material.dart';
import 'package:workout/data/date_time.dart';
import 'package:workout/data/hive_database.dart';
import 'package:workout/models/exercise.dart';
import 'package:workout/models/performed_workout.dart';

class PerformedWorkoutData extends ChangeNotifier {
  final db = HiveDatabase();

  List<PerformedWorkout> performedWorkoutList = [];
  List<PerformedWorkout> completedWorkoutList = [];

  // We only need to initialise completed workouts for display in Workout History
  // because we do not need to display uncompleted ones
  void initialiseCompletedWorkoutList() {
    db.savePerformedWorkoutsToDatabase([]);
    // Empties performedWorkoutList if navigated from PerformedWorkoutPage

    if (db.prevDataExists()) {
      completedWorkoutList = db.readCompletedWorkoutsFromDatabase();
    } else {
      db.saveCompletedWorkoutsToDatabase(completedWorkoutList);
    }
  }

  List<PerformedWorkout> getCompletedWorkoutList() {
    return completedWorkoutList;
  }

  int getNumberOfExercises(DateTime workoutDate) {
    PerformedWorkout? intendedWorkout =
        getIntendedPerformedWorkout(workoutDate);

    return intendedWorkout != null ? intendedWorkout.exercises.length : 0;
  }

  // Called when start is pressed
  void startPerformingWorkout(PerformedWorkout performedWorkout) {
    performedWorkoutList.add(performedWorkout);
  }

  void editSet(
    DateTime workoutDate,
    String exerciseName,
    int setNumber,
    double editedWeight,
    int editedReps,
  ) {
    PerformedWorkout? intendedWorkout =
        getIntendedPerformedWorkout(workoutDate);

    int exerciseIndex = intendedWorkout!.exercises
        .indexWhere((exercise) => exercise.name == exerciseName);

    if (exerciseIndex != -1) {
      Exercise intendedExercise = intendedWorkout.exercises[exerciseIndex];

      Map<int, List<dynamic>> setWithEditedWeightReps =
          Map.from(intendedExercise.setWeightReps);

      setWithEditedWeightReps[setNumber] = [editedWeight, editedReps];

      Exercise editedExercise = Exercise(
        name: intendedExercise.name,
        setWeightReps: setWithEditedWeightReps,
        isCompleted: intendedExercise.isCompleted,
      );

      intendedWorkout.exercises[exerciseIndex] = editedExercise;
      notifyListeners();
      db.savePerformedWorkoutsToDatabase(performedWorkoutList);
    } else {
      print('Exercise $exerciseName not found in ${intendedWorkout.name}');
    }
  }

  // Called when 'Finish' is pressed
  void finishWorkout(DateTime workoutDate) {
    PerformedWorkout? intendedWorkout =
        getIntendedPerformedWorkout(workoutDate);

    for (var exercise in intendedWorkout!.exercises) {
      exercise.isCompleted = true;
    }

    completedWorkoutList.add(intendedWorkout);

    notifyListeners();
    db.saveCompletedWorkoutsToDatabase(completedWorkoutList);

    loadHeatMap();
  }

  /* Alternatively, let each exercise be checked off manually
  void checkOffExercise(DateTime workoutDate, String exerciseName) {
    Exercise intendedExercise =
        getIntendedExerciseInPerformedWorkout(workoutDate, exerciseName);
    intendedExercise.isCompleted = !intendedExercise.isCompleted;

    notifyListeners();
    db.saveWorkoutsToDatabase(performedWorkoutList);
  }
  */

  Map<DateTime, int> heatMapDataSet = {};

  String getStartDate() {
    return db.getStartDate();
  }

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

  // Only used for editing set data, which is not done in completed workouts
  PerformedWorkout? getIntendedPerformedWorkout(DateTime workoutDate) {
    PerformedWorkout? performedWorkout = performedWorkoutList.firstWhere(
      (element) => element.date == workoutDate,
    );

    return performedWorkout;
  }

  Exercise getIntendedExerciseInPerformedWorkout(
      DateTime workoutDate, String exerciseName) {
    PerformedWorkout? intendedWorkout =
        getIntendedPerformedWorkout(workoutDate);

    return intendedWorkout!.exercises
        .firstWhere((element) => element.name == exerciseName);
  }
}
