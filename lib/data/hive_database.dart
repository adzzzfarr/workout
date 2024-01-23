import 'package:hive_flutter/hive_flutter.dart';
import 'package:workout/models/exercise.dart';
import 'package:workout/models/performed_workout.dart';
import 'package:workout/models/template_workout.dart';
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

  bool allExercisesCompleted(PerformedWorkout performedWorkout) {
    for (var exercise in performedWorkout.exercises) {
      if (!exercise.isCompleted) {
        return false;
      }
    }
    return true;
  }

  void saveTemplateWorkoutsToDatabase(List<TemplateWorkout> templateWorkouts) {
    myBox.put("TEMPLATE_WORKOUTS", templateWorkouts);
  }

  void savePerformedWorkoutsToDatabase(
      List<PerformedWorkout> performedWorkouts) {
    // This includes both completed and uncompleted workouts, NOT exclusively uncompleted workouts
    myBox.put("PERFORMED_WORKOUTS", performedWorkouts);
  }

  void saveCompletedWorkoutsToDatabase(
      List<PerformedWorkout> performedWorkouts) {
    List<PerformedWorkout> completedWorkouts = [];

    for (var workout in performedWorkouts) {
      String yyyymmdd = dateTimeToYYYYMMDD(workout.date);
      if (allExercisesCompleted(workout)) {
        myBox.put("COMPLETION_STATUS_$yyyymmdd", 1);
        completedWorkouts.add(workout);
      } else {
        myBox.put("COMPLETION_STATUS_$yyyymmdd", 0);
      }
    }

    completedWorkouts.sort(
      (a, b) => b.date.compareTo(a.date),
    );

    List names = [];
    List durations = [];
    for (var element in completedWorkouts) {
      names.add(element.name);
      durations.add(element.durationInSeconds);
    }

    print(
        'I am saving these completed workouts: $names with corresponding durations: $durations');
    myBox.put("COMPLETED_WORKOUTS", completedWorkouts);
  }

  void saveExercisesToDatabase(List<Exercise> exercises) {
    exercises.sort((a, b) => a.name.compareTo(b.name));

    List names = [];
    List indices = [];
    for (int i = 0; i < exercises.length; i++) {
      names.add(exercises[i].name);
      indices.add(i);
    }
    print('I am reading these Exercises: $names with indices: $indices');
    myBox.put('EXERCISES', exercises);
  }

  void saveExerciseInstancesToDatabase(
      Map<String, List<PerformedWorkout>> exerciseInstances) {
    myBox.put('EXERCISE_INSTANCES', exerciseInstances);
  }

  List<TemplateWorkout> readTemplateWorkoutsFromDatabase() {
    List<TemplateWorkout> templateWorkouts =
        (myBox.get("TEMPLATE_WORKOUTS", defaultValue: []) as List<dynamic>)
            .map((e) => e as TemplateWorkout)
            .toList();

    List names = [];
    for (var element in templateWorkouts) {
      names.add(element.name);
    }

    print('I am reading these TemplateWorkouts: $names');

    return templateWorkouts;
  }

  List<Exercise> readExercisesFromDatabase() {
    List<Exercise> exercises =
        (myBox.get('EXERCISES', defaultValue: []) as List<dynamic>)
            .map((e) => e as Exercise)
            .toList();

    List names = [];
    for (var element in exercises) {
      names.add(element.name);
    }

    print('I am reading these Exercises: $names');

    return exercises;
  }

  Map<String, List<PerformedWorkout>> readExerciseInstancesFromDatabase() {
    Map<String, List<PerformedWorkout>> exerciseInstances =
        (myBox.get('EXERCISE_INSTANCES', defaultValue: [])
                as Map<dynamic, dynamic>)
            .map(
      (key, value) {
        String exerciseName = key as String;
        List<dynamic> dynamicData = value as List<dynamic>;
        List<PerformedWorkout> workouts =
            dynamicData.map((e) => e as PerformedWorkout).toList();

        return MapEntry(exerciseName, workouts);
      },
    );

    return exerciseInstances;
  }

  List<PerformedWorkout> readPerformedWorkoutsFromDatabase() {
    List<PerformedWorkout> performedWorkouts =
        (myBox.get("PERFORMED_WORKOUTS", defaultValue: []) as List<dynamic>)
            .map((e) => e as PerformedWorkout)
            .toList();

    List names = [];
    for (var element in performedWorkouts) {
      names.add(element.name);
    }

    print('I am reading these PerformedWorkouts: $names');

    return performedWorkouts;
  }

  List<PerformedWorkout> readCompletedWorkoutsFromDatabase() {
    List<PerformedWorkout> completedWorkouts =
        (myBox.get("COMPLETED_WORKOUTS", defaultValue: []) as List<dynamic>)
            .map((e) => e as PerformedWorkout)
            .toList();

    List names = [];
    List dates = [];
    List durations = [];
    for (var element in completedWorkouts) {
      names.add(element.name);
      durations.add(element.durationInSeconds);
      dates.add(dateTimeToYYYYMMDD(element.date));
    }

    print(
        'I am reading these CompletedWorkouts: $names with corresponding durations: $durations');

    for (var date in dates) {
      print('COMPLETION STATUS for  $date: ${getCompletionStatus(date)}');
    }

    return completedWorkouts;
  }

  int getCompletionStatus(String yyyymmdd) {
    int completionStatus = myBox.get("COMPLETION_STATUS_$yyyymmdd") ?? 0;
    return completionStatus;
  }
}
