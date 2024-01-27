import 'package:flutter/material.dart';
import 'package:workout/data/date_time.dart';
import 'package:workout/data/hive_database.dart';
import 'package:workout/models/exercise.dart';
import 'package:workout/models/performed_workout.dart';

class PerformedWorkoutData extends ChangeNotifier {
  final db = HiveDatabase();

  List<PerformedWorkout> performedWorkoutList = [];
  List<PerformedWorkout> completedWorkoutList = [];
  List<DateTime> completedWorkoutDates = [];

  // We only need to initialise completed workouts for display in Workout History
  // because we do not need to display uncompleted ones
  void initialiseCompletedWorkoutList() {
    db.savePerformedWorkoutsToDatabase([]);
    // Empties performedWorkoutList if navigated from PerformedWorkoutPage

    if (db.prevDataExists() &&
        db.myBox.get('COMPLETED_WORKOUTS') != null &&
        (db.myBox.get('COMPLETED_WORKOUTS') as List).isNotEmpty) {
      completedWorkoutList = db.readCompletedWorkoutsFromDatabase();
    } else {
      db.saveCompletedWorkoutsToDatabase(completedWorkoutList);
    }

    if (db.prevDataExists() &&
        db.myBox.get('COMPLETED_WORKOUT_DATES') != null &&
        (db.myBox.get('COMPLETED_WORKOUT_DATES') as List).isNotEmpty) {
      completedWorkoutDates = db.readCompletedWorkoutDatesFromDatabase();
    } else {
      db.saveCompletedWorkoutDatesToDatabase(completedWorkoutList);
    }
  }

  List<PerformedWorkout> getCompletedWorkoutList() {
    return completedWorkoutList;
  }

  int getNumberOfExercisesInPerformedWorkout(
      DateTime workoutDate, String workoutName) {
    PerformedWorkout? intendedWorkout =
        getIntendedPerformedWorkout(workoutDate, workoutName);

    return intendedWorkout != null ? intendedWorkout.exercises.length : 0;
  }

  // Called when start is pressed
  void startPerformingWorkout(PerformedWorkout performedWorkout) {
    performedWorkoutList.add(performedWorkout);
  }

  void editSet(
    DateTime workoutDate,
    String workoutName,
    String exerciseName,
    int setNumber,
    double editedWeight,
    int editedReps,
  ) {
    PerformedWorkout? intendedWorkout =
        getIntendedPerformedWorkout(workoutDate, workoutName);

    int exerciseIndex = intendedWorkout!.exercises
        .indexWhere((exercise) => exercise.name == exerciseName);

    if (exerciseIndex != -1) {
      Exercise intendedExercise = intendedWorkout.exercises[exerciseIndex];

      Map<int, List<dynamic>> setWithEditedWeightReps =
          Map.from(intendedExercise.setWeightReps!);

      setWithEditedWeightReps[setNumber] = [editedWeight, editedReps];

      Exercise editedExercise = Exercise(
        name: intendedExercise.name,
        setWeightReps: setWithEditedWeightReps,
        bodyPart: intendedExercise.bodyPart,
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
  void finishWorkout(DateTime workoutDate, String workoutName) {
    PerformedWorkout? intendedWorkout =
        getIntendedPerformedWorkout(workoutDate, workoutName);

    for (var exercise in intendedWorkout!.exercises) {
      exercise.isCompleted = true;
    }

    completedWorkoutList.add(intendedWorkout);

    notifyListeners();
    db.saveCompletedWorkoutsToDatabase(completedWorkoutList);

    loadHeatMap();
  }

  int getNumberOfExercisesInCompletedWorkout(
      DateTime workoutDate, String workoutName) {
    PerformedWorkout? intendedWorkout =
        getIntendedCompletedWorkout(workoutDate, workoutName);

    return intendedWorkout != null ? intendedWorkout.exercises.length : 0;
  }

  void deleteCompletedWorkout(String workoutName) {
    completedWorkoutList.removeWhere((workout) => workout.name == workoutName);

    notifyListeners();
    db.saveCompletedWorkoutsToDatabase(completedWorkoutList);
  }

  // ONLY for undoing deletion of a completed workout
  void addCompletedWorkoutAtIndex(
      PerformedWorkout completedWorkout, int index) {
    completedWorkoutList.insert(index, completedWorkout);

    notifyListeners();
    db.saveTemplateWorkoutsToDatabase(completedWorkoutList);
  }

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
  PerformedWorkout? getIntendedPerformedWorkout(
      DateTime workoutDate, String workoutName) {
    PerformedWorkout? performedWorkout = performedWorkoutList.firstWhere(
      (element) => element.date == workoutDate && element.name == workoutName,
    );

    return performedWorkout;
  }

  Exercise getIntendedExerciseInPerformedWorkout(
      DateTime workoutDate, String workoutName, String exerciseName) {
    PerformedWorkout? intendedWorkout =
        getIntendedPerformedWorkout(workoutDate, workoutName);

    return intendedWorkout!.exercises
        .firstWhere((element) => element.name == exerciseName);
  }

  PerformedWorkout? getIntendedCompletedWorkout(
      DateTime workoutDate, String workoutName) {
    PerformedWorkout? completedWorkout = completedWorkoutList.firstWhere(
      (element) => element.date == workoutDate && element.name == workoutName,
    );

    return completedWorkout;
  }
}
