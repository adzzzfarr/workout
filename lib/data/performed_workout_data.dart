import 'package:flutter/material.dart';
import 'package:workout/data/date_time.dart';
import 'package:workout/database/hive_database.dart';
import 'package:workout/models/exercise.dart';
import 'package:workout/models/performed_workout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout/firebase/firestore_service.dart';

class PerformedWorkoutData extends ChangeNotifier {
  final db = HiveDatabase();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  List<PerformedWorkout> performedWorkoutList = [];
  List<PerformedWorkout> completedWorkoutList = [];
  List<DateTime> completedWorkoutDates = [];

  // We only need to initialise completed workouts for display in Workout History
  // because we do not need to display uncompleted ones
  Future<void> initialiseCompletedWorkoutList() async {
    db.savePerformedWorkoutsToDatabase([]);
    // Empties performedWorkoutList if navigated from PerformedWorkoutPage

    if (currentUser != null) {
      final uid = currentUser!.uid;
      final CollectionReference completedWorkoutsCollectionRef =
          FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .collection("completed-workouts");

      final completedWorkoutsQuerySnapshot =
          await completedWorkoutsCollectionRef.get();
      final completedWorkoutsInFirestore = completedWorkoutsQuerySnapshot.docs
          .map((doc) => FirestoreService().readCompletedWorkoutFromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      if (completedWorkoutsInFirestore.isNotEmpty && !db.prevDataExists()) {
        // Handles the case of a user reading existing cloud data for the first time on a new device
        completedWorkoutList = completedWorkoutsInFirestore;
        db.saveCompletedWorkoutsToDatabase(completedWorkoutList);
        notifyListeners();
      } else if (db.prevDataExists() &&
          db.myBox.get('COMPLETED_WORKOUTS') != null &&
          (db.myBox.get('COMPLETED_WORKOUTS') as List).isNotEmpty) {
        // Handles the case of a user having logged in before and thus having their cloud data saved to local storage already, as in the 'if' block
        completedWorkoutList = db.readCompletedWorkoutsFromDatabase();
        notifyListeners();
      } else {
        // Handles the case of a user not having any existing cloud data nor local data
        db.saveCompletedWorkoutsToDatabase(completedWorkoutList);
      }
    }
    throw (e) {
      print("USER IS NULL.");
    };
    /*
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
    */
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
    String setNumber,
    double editedWeight,
    int editedReps,
  ) {
    PerformedWorkout? intendedWorkout =
        getIntendedPerformedWorkout(workoutDate, workoutName);

    int exerciseIndex = intendedWorkout!.exercises
        .indexWhere((exercise) => exercise.name == exerciseName);

    if (exerciseIndex != -1) {
      Exercise intendedExercise = intendedWorkout.exercises[exerciseIndex];

      Map<String, List<dynamic>> setWithEditedWeightReps =
          Map.from(intendedExercise.setWeightReps!);

      setWithEditedWeightReps[setNumber] = [editedWeight, editedReps];

      Exercise editedExercise = Exercise(
        name: intendedExercise.name,
        setWeightReps: setWithEditedWeightReps,
        setsCompletion: intendedExercise.setsCompletion,
        bodyPart: intendedExercise.bodyPart,
        exerciseId: intendedExercise.exerciseId,
      );

      intendedWorkout.exercises[exerciseIndex] = editedExercise;
      notifyListeners();
      db.savePerformedWorkoutsToDatabase(performedWorkoutList);
    } else {
      print('Exercise $exerciseName not found in ${intendedWorkout.name}');
    }
  }

  bool ensureValidSetData(
    DateTime workoutDate,
    String workoutName,
    String exerciseName,
    String setNumber,
  ) {
    PerformedWorkout? intendedWorkout =
        getIntendedPerformedWorkout(workoutDate, workoutName);

    int exerciseIndex = intendedWorkout!.exercises
        .indexWhere((exercise) => exercise.name == exerciseName);

    if (exerciseIndex != -1) {
      Exercise intendedExercise = intendedWorkout.exercises[exerciseIndex];

      // Check if no reps performed. Weight can be 0 (e.g. bodyweight exercises)
      if (intendedExercise.setWeightReps![setNumber]![1] == 0) {
        return false;
      }
      return true;
    } else {
      print('Exercise $exerciseName not found in ${intendedWorkout.name}');
      return false;
    }
  }

  void toggleSetCompletion(
    DateTime workoutDate,
    String workoutName,
    String exerciseName,
    String setNumber,
  ) {
    PerformedWorkout? intendedWorkout =
        getIntendedPerformedWorkout(workoutDate, workoutName);

    int exerciseIndex = intendedWorkout!.exercises
        .indexWhere((exercise) => exercise.name == exerciseName);

    if (exerciseIndex != -1) {
      Exercise intendedExercise = intendedWorkout.exercises[exerciseIndex];

      Map<String, bool> editedSetsCompletion =
          Map.from(intendedExercise.setsCompletion!);
      editedSetsCompletion[setNumber] = !editedSetsCompletion[setNumber]!;

      Exercise editedExercise = Exercise(
        name: intendedExercise.name,
        setWeightReps: intendedExercise.setWeightReps,
        setsCompletion: editedSetsCompletion,
        bodyPart: intendedExercise.bodyPart,
        exerciseId: intendedExercise.exerciseId,
      );

      intendedWorkout.exercises[exerciseIndex] = editedExercise;
      notifyListeners();
    } else {
      print('Exercise $exerciseName not found in ${intendedWorkout.name}');
    }
  }

  // Called when 'Finish' is pressed
  void finishWorkout(DateTime workoutDate, String workoutName) {
    PerformedWorkout? intendedWorkout =
        getIntendedPerformedWorkout(workoutDate, workoutName);

    completedWorkoutList.add(intendedWorkout!);
    completedWorkoutDates.add(intendedWorkout.date);

    notifyListeners();
    db.saveCompletedWorkoutsToDatabase(completedWorkoutList);

    for (var workout in completedWorkoutList) {
      FirestoreService().saveCompletedWorkoutToFirestore(workout);
    }

    // db.saveCompletedWorkoutDatesToDatabase(completedWorkoutList); Is this needed?
    loadHeatMap();
  }

  int getNumberOfExercisesInCompletedWorkout(
      DateTime workoutDate, String workoutName) {
    PerformedWorkout? intendedWorkout =
        getIntendedCompletedWorkout(workoutDate, workoutName);

    return intendedWorkout != null ? intendedWorkout.exercises.length : 0;
  }

  Map<DateTime, int> heatMapDataSet = {};

  String getStartDate() {
    return db.getStartDate();
  }

  List<PerformedWorkout> getCompletedWorkoutsInWeek(DateTime startOfWeek) {
    startOfWeek =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    DateTime endOfWeek =
        startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));

    return completedWorkoutList
        .where((element) =>
            (element.date.isAtSameMomentAs(startOfWeek) ||
                element.date.isAfter(startOfWeek)) &&
            element.date.isBefore(endOfWeek))
        .toList();
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

  // To store start date in Hive
  void putStartDate() {
    if (completedWorkoutList.isEmpty) {
      HiveDatabase().myBox.put("START_DATE", getTodayYYYYMMDD());
    } else {
      // Sort in ascending order
      completedWorkoutDates.sort();

      // Get earliest date
      final DateTime startDate = completedWorkoutDates[0];

      HiveDatabase().myBox.put("START_DATE", dateTimeToYYYYMMDD(startDate));
    }
  }
}
