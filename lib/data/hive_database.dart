import 'package:hive_flutter/hive_flutter.dart';
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
    if (exerciseCompleted(workouts)) {
      myBox.put("COMPLETION_STATUS_${getTodayYYYYMMDD()}", 1);
    } else {
      myBox.put("COMPLETION_STATUS_${getTodayYYYYMMDD()}", 0);
    }

    myBox.put("WORKOUTS", workouts);
  }

  List<Workout> readFromDatabase() {
    return myBox.get("WORKOUTS", defaultValue: []) ?? [];
  }

  int getCompletionStatus(String yyyymmdd) {
    int completionStatus = myBox.get("COMPLETION_STATUS_$yyyymmdd") ?? 0;
    return completionStatus;
  }
}
