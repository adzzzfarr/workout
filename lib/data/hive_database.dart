import 'package:hive_flutter/hive_flutter.dart';
import 'package:workout/models/exercise.dart';
import 'package:workout/models/workout.dart';
import 'package:workout/data/date_time.dart';

// Can try Hive type adaptation. Hive only works with primitive types i.e. Workout and Exercise classes cannot be saved otherwise.

class HiveDatabase {
  final myBox = Hive.box('workout-database');

  bool prevDataExists() {
    if (myBox.isEmpty) {
      print('Previous data does not exist.');
      myBox.put("START_DATE", getTodayYYYYMMDD());
      return false;
    } else {
      print('Previous data exists.');
      return true;
    }
  }

  String getStartDate() {
    return myBox.get("START_DATE");
  }

  bool exerciseCompleted(List<Workout> workouts) {
    for (var workout in workouts) {
      for (var exercise in workout.exercises) {
        if (exercise.isCompleted) {
          return true;
        }
      }
    }
    return false;
  }

  void saveToDatabase(List<Workout> workouts) {
    final workoutList = convertToWorkoutList(workouts);
    final exerciseList = convertToExerciseList(workouts);

    if (exerciseCompleted(workouts)) {
      myBox.put("COMPLETION_STATUS_${getTodayYYYYMMDD()}", 1);
    } else {
      myBox.put("COMPLETION_STATUS_${getTodayYYYYMMDD()}", 0);
    }

    myBox.put("WORKOUTS", workoutList);
    myBox.put("EXERCISES", exerciseList);
  }

  List<Workout> readFromDatabase() {
    List<Workout> savedWorkouts = [];

    List<String> workoutNames = myBox.get("WORKOUTS");
    final exerciseDetails = myBox.get("EXERCISES");

    for (int i = 0; i < workoutNames.length; i++) {
      List<Exercise> exercisesInEachWorkout = [];

      for (int j = 0; j < exerciseDetails[i].length; j++) {
        exercisesInEachWorkout.add(
          Exercise(
            name: exerciseDetails[i][j][0],
            weight: double.parse(exerciseDetails[i][j][1]),
            sets: int.parse(exerciseDetails[i][j][2]),
            reps: int.parse(exerciseDetails[i][j][3]),
            isCompleted: exerciseDetails[i][j][4] == "true" ? true : false,
          ),
        );
      }

      Workout workout =
          Workout(name: workoutNames[i], exercises: exercisesInEachWorkout);

      savedWorkouts.add(workout);
    }

    return savedWorkouts;
  }

  int getCompletionStatus(String yyyymmdd) {
    int completionStatus = myBox.get("COMPLETION_STATUS_$yyyymmdd") ?? 0;
    return completionStatus;
  }
}

List<String> convertToWorkoutList(List<Workout> workouts) {
  List<String> workoutList = [];

  for (int i = 0; i < workouts.length; i++) {
    workoutList.add(workouts[i].name);
  }

  return workoutList;
}

List<List<List<String>>> convertToExerciseList(List<Workout> workouts) {
  List<List<List<String>>> exerciseList = [];
  /*
   [
    (Upper Body) - List of a List of Strings
    [ [bench_press, 10kg, 10reps, 3sets], [shoulder_press, 10kg, 10reps, 3sets] ],

    (Lower Body) - List of a List of Strings
    [ [squat, 10kg, 10reps, 3sets], [leg_press, 10kg, 10reps, 3sets] ],
   ]
  */

  for (int i = 0; i < workouts.length; i++) {
    List<Exercise> exercisesInWorkout = workouts[i].exercises;

    List<List<String>> indivWorkout = [];
    /*
    (Upper Body) - List of a List of Strings
    [ [bench_press, 10kg, 10reps, 3sets], [shoulder_press, 10kg, 10reps, 3sets] ] 
    */

    for (int j = 0; j < exercisesInWorkout.length; j++) {
      List<String> indivExercise = [];
      indivExercise.addAll([
        exercisesInWorkout[j].name,
        exercisesInWorkout[j].weight.toString(),
        exercisesInWorkout[j].sets.toString(),
        exercisesInWorkout[j].reps.toString(),
        exercisesInWorkout[j].isCompleted.toString(),
      ]);
      indivWorkout.add(indivExercise);
    }

    exerciseList.add(indivWorkout);
  }

  return exerciseList;
}
