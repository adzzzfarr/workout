import 'package:flutter/material.dart';
import 'package:workout/data/defaults.dart';
import 'package:workout/data/hive_database.dart';
import 'package:workout/models/exercise.dart';
import 'package:workout/models/template_workout.dart';

import '../models/performed_workout.dart';

class TemplateWorkoutData extends ChangeNotifier {
  final db = HiveDatabase();

  List<TemplateWorkout> templateWorkoutList = defaultTemplateWorkoutList;

  void initialiseTemplateWorkoutList() {
    if (db.prevDataExists() &&
        db.myBox.get('TEMPLATE_WORKOUTS') != null &&
        (db.myBox.get('TEMPLATE_WORKOUTS') as List).isNotEmpty) {
      templateWorkoutList = db.readTemplateWorkoutsFromDatabase();
    } else {
      // Save the default workouts
      db.saveTemplateWorkoutsToDatabase(templateWorkoutList);
    }

    List names = [];
    for (var workout in templateWorkoutList) {
      names.add(workout.name);
    }

    print('TemplateWorkoutList: $names');
  }

  int getNumberOfExercises(String workoutName) {
    TemplateWorkout intendedWorkout = getIntendedTemplateWorkout(workoutName);

    return intendedWorkout.exercises.length;
  }

  void addWorkout(String name) {
    templateWorkoutList.add(TemplateWorkout(name: name, exercises: []));
    notifyListeners();
    db.saveTemplateWorkoutsToDatabase(templateWorkoutList);
  }

  void addExerciseToTemplateWorkout(
    String workoutName,
    String exerciseName,
    BodyPart bodyPart,
    int sets,
  ) {
    TemplateWorkout intendedWorkout = getIntendedTemplateWorkout(workoutName);

    Map<int, List<dynamic>> setWeightReps = {};

    for (int i = 1; i <= sets; i++) {
      setWeightReps[i] = [0.0, 0];
    }

    intendedWorkout.exercises.add(
      Exercise(
        name: exerciseName,
        setWeightReps: setWeightReps,
        bodyPart: bodyPart,
      ),
    );

    notifyListeners();
    db.saveTemplateWorkoutsToDatabase(templateWorkoutList);
  }

  void editExerciseInTemplateWorkout(
    String workoutName,
    String exerciseName,
    int originalNoOfSets,
    int editedNoOfSets,
  ) {
    TemplateWorkout intendedWorkout = getIntendedTemplateWorkout(workoutName);

    int index = intendedWorkout.exercises
        .indexWhere((exercise) => exercise.name == exerciseName);

    if (index != -1) {
      final editedSetWeightReps =
          intendedWorkout.exercises[index].setWeightReps;

      if (editedNoOfSets < originalNoOfSets) {
        editedSetWeightReps!.removeWhere((key, value) => key > editedNoOfSets);
      } else if (editedNoOfSets > originalNoOfSets) {
        for (int i = originalNoOfSets + 1; i <= editedNoOfSets; i++) {
          editedSetWeightReps![i] = [0.0, 0];
        }
      }
      // if editedNoOfSets == originalNoOfSets, there is no need to change setWeightReps

      Exercise editedExercise = Exercise(
        name: exerciseName,
        setWeightReps: editedSetWeightReps,
        bodyPart: intendedWorkout.exercises[index].bodyPart,
        isCompleted: intendedWorkout.exercises[index].isCompleted,
      );

      intendedWorkout.exercises[index] = editedExercise;
      notifyListeners();
      db.saveTemplateWorkoutsToDatabase(templateWorkoutList);
    }
  }

  void deleteExerciseFromTemplateWorkout(
      String workoutName, String exerciseName) {
    TemplateWorkout intendedWorkout = getIntendedTemplateWorkout(workoutName);

    intendedWorkout.exercises
        .removeWhere((exercise) => exercise.name == exerciseName);

    notifyListeners();
    db.saveTemplateWorkoutsToDatabase(templateWorkoutList);
  }

  void addExerciseToTemplateWorkoutAtIndex(
      String workoutName, Exercise exercise, int index) {
    TemplateWorkout intendedWorkout = getIntendedTemplateWorkout(workoutName);
    intendedWorkout.exercises.insert(index, exercise);

    notifyListeners();
    db.saveTemplateWorkoutsToDatabase(templateWorkoutList);
  }

  void deleteWorkout(String workoutName) {
    templateWorkoutList.removeWhere((workout) => workout.name == workoutName);

    notifyListeners();
    db.saveTemplateWorkoutsToDatabase(templateWorkoutList);
  }

  void addWorkoutAtIndex(TemplateWorkout workout, int index) {
    templateWorkoutList.insert(index, workout);

    notifyListeners();
    db.saveTemplateWorkoutsToDatabase(templateWorkoutList);
  }

  void updateTemplateWorkout(PerformedWorkout completedWorkout) {
    TemplateWorkout intendedTemplateWorkout =
        getIntendedTemplateWorkout(completedWorkout.name);

    intendedTemplateWorkout = TemplateWorkout(
        name: completedWorkout.name, exercises: completedWorkout.exercises);
  }

  TemplateWorkout getIntendedTemplateWorkout(String workoutName) {
    return templateWorkoutList
        .firstWhere((element) => element.name == workoutName);
  }

  Exercise getIntendedExerciseInTemplateWorkout(
      String workoutName, String exerciseName) {
    TemplateWorkout intendedWorkout = getIntendedTemplateWorkout(workoutName);

    return intendedWorkout.exercises
        .firstWhere((element) => element.name == exerciseName);
  }

  String getStartDate() {
    return db.getStartDate();
  }
}
