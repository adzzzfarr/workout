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
          setWeightReps: {
            1: [10.0, 10],
            2: [9.0, 9],
            3: [8.0, 8],
          },
        ),
      ],
    ),
    Workout(
      name: "Lower Body",
      exercises: [
        Exercise(
          name: "Squat",
          setWeightReps: {
            1: [10.0, 10],
            2: [9.0, 9],
            3: [8.0, 8],
          },
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

  void addNewExercise(
    String workoutName,
    String exerciseName,
    int sets,
  ) {
    Workout intendedWorkout = getIntendedWorkout(workoutName);

    Map<int, List<dynamic>> setWeightReps = {};

    for (int i = 1; i <= sets; i++) {
      setWeightReps[i] = [0.0, 0];
    }

    intendedWorkout.exercises.add(
      Exercise(
        name: exerciseName,
        setWeightReps: setWeightReps,
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

  void editExercise(
    String workoutName,
    String originalExerciseName,
    String editedExerciseName,
    int originalNoOfSets,
    int editedNoOfSets,
  ) {
    Workout intendedWorkout = getIntendedWorkout(workoutName);

    int index = intendedWorkout.exercises
        .indexWhere((exercise) => exercise.name == originalExerciseName);

    if (index != -1) {
      final editedSetWeightReps =
          intendedWorkout.exercises[index].setWeightReps;

      if (editedNoOfSets < originalNoOfSets) {
        editedSetWeightReps.removeWhere((key, value) => key > editedNoOfSets);
      } else if (editedNoOfSets > originalNoOfSets) {
        for (int i = originalNoOfSets + 1; i <= editedNoOfSets; i++) {
          editedSetWeightReps[i] = [0.0, 0];
        }
      }
      // if editedNoOfSets == originalNoOfSets, there is no need to change setWeightReps

      Exercise editedExercise = Exercise(
        name: editedExerciseName,
        setWeightReps: editedSetWeightReps,
        isCompleted: intendedWorkout.exercises[index].isCompleted,
      );

      intendedWorkout.exercises[index] = editedExercise;
      notifyListeners();
      db.saveToDatabase(workoutList);
    }
  }

  void editSet(
    String workoutName,
    String exerciseName,
    int setNumber,
    double editedWeight,
    int editedReps,
  ) {
    Workout intendedWorkout = getIntendedWorkout(workoutName);

    int exerciseIndex = intendedWorkout.exercises
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
      db.saveToDatabase(workoutList);
    } else {
      print('Exercise $exerciseName not found in $workoutName');
    }
  }

  void deleteExercise(String workoutName, String exerciseName) {
    Workout intendedWorkout = getIntendedWorkout(workoutName);

    intendedWorkout.exercises
        .removeWhere((exercise) => exercise.name == exerciseName);

    notifyListeners();
    db.saveToDatabase(workoutList);
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
