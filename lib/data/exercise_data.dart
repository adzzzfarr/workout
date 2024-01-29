import 'package:flutter/material.dart';
import 'package:workout/data/hive_database.dart';
import 'package:workout/data/defaults.dart';
import 'package:workout/models/performed_workout.dart';
import '../models/exercise.dart';

class ExerciseData extends ChangeNotifier {
  final db = HiveDatabase();

  List<Exercise> exerciseList = defaultExerciseList;
  Map<String, List<PerformedWorkout>> exerciseInstances = {};

  void initialiseExerciseList() {
    if (db.prevDataExists() &&
        db.myBox.get('EXERCISES') != null &&
        (db.myBox.get('EXERCISES') as List).isNotEmpty) {
      exerciseList = db.readExercisesFromDatabase();
    } else {
      // Save default exercises
      db.saveExercisesToDatabase(exerciseList);
    }

    List names = [];
    for (var e in exerciseList) {
      names.add(e.name);
    }

    print('Exercises: $names');
  }

  void initialiseExerciseInstances() {
    if (db.prevDataExists() &&
        db.myBox.get('EXERCISE_INSTANCES') != null &&
        (db.myBox.get('EXERCISE_INSTANCES') as Map).isNotEmpty) {
      exerciseInstances = db.readExerciseInstancesFromDatabase();
    } else {
      // Save default exercises
      db.saveExerciseInstancesToDatabase(exerciseInstances);
    }
  }

  // Call whenever you finish a workout
  void updateExerciseInstances(PerformedWorkout completedWorkout) {
    for (var exercise in completedWorkout.exercises) {
      if (!exerciseInstances.keys.toList().contains(exercise.name)) {
        exerciseInstances[exercise.name] = [completedWorkout];
      } else {
        exerciseInstances[exercise.name]!.add(completedWorkout);
      }

      // Most recent first
      exerciseInstances[exercise.name]!
          .sort((a, b) => (b.date).compareTo(a.date));
    }

    notifyListeners();
    db.saveExerciseInstancesToDatabase(exerciseInstances);
  }

  void addExerciseToExerciseList(String exerciseName, BodyPart bodyPart) {
    exerciseList.add(
      Exercise(
        name: exerciseName,
        setWeightReps: null,
        bodyPart: bodyPart,
      ),
    );

    notifyListeners();
    db.saveExercisesToDatabase(exerciseList);
  }

  void editExerciseInExerciseList(
    String originalExerciseName,
    String editedExerciseName,
    BodyPart editedBodyPart,
  ) {
    int index = exerciseList
        .indexWhere((element) => element.name == originalExerciseName);

    if (index != -1) {
      exerciseList[index] = Exercise(
        name: editedExerciseName,
        setWeightReps: null,
        bodyPart: editedBodyPart,
      );
    }

    notifyListeners();
    db.saveExercisesToDatabase(exerciseList);
  }

  void deleteExerciseFromExerciseList(String exerciseName) {
    exerciseList.removeWhere((element) => element.name == exerciseName);

    notifyListeners();
    db.saveExercisesToDatabase(exerciseList);
  }

  void addExerciseToExerciseListAtIndex(Exercise exercise, int index) {
    exerciseList.insert(index, exercise);

    notifyListeners();
    db.saveExercisesToDatabase(exerciseList);
  }
}
