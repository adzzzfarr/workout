import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:workout/database/hive_database.dart';
import 'package:workout/data/defaults.dart';
import 'package:workout/models/performed_workout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout/firebase/firestore_service.dart';
import '../models/exercise.dart';

class ExerciseData extends ChangeNotifier {
  final db = HiveDatabase();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  List<Exercise> exerciseList = defaultExerciseList;
  Map<String, List<PerformedWorkout>> exerciseInstances = {};

  Future<void> initialiseExerciseList() async {
    if (currentUser != null) {
      final uid = currentUser!.uid;
      final CollectionReference exercisesCollectionRef = FirebaseFirestore
          .instance
          .collection("users")
          .doc(uid)
          .collection("exercises");

      final querySnapshot = await exercisesCollectionRef.get();
      final exercisesInFirestore = querySnapshot.docs
          .map((doc) => FirestoreService()
              .readExerciseForExerciseListPageFromSnapshot(
                  doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      if (exercisesInFirestore.isNotEmpty && !db.prevDataExists()) {
        // Handles the case of a user reading existing cloud data for the first time on a new device
        exerciseList = exercisesInFirestore;
        db.saveExercisesToDatabase(exerciseList);
      } else if (db.prevDataExists() &&
          db.myBox.get('EXERCISES') != null &&
          (db.myBox.get('EXERCISES') as List).isNotEmpty) {
        // Handles the case of a user having logged in before and thus having their cloud data saved to local storage already, as in the 'if' block
        exerciseList = db.readExercisesFromDatabase();
      } else {
        // Handles the case of a user not having any existing cloud data nor local data
        db.saveExercisesToDatabase(exerciseList);
        FirestoreService().saveExercisesToFirestore(exerciseList);
      }
    }
    throw (e) {
      print(e.toString());
    };
    /*if (db.prevDataExists() &&
        db.myBox.get('EXERCISES') != null &&
        (db.myBox.get('EXERCISES') as List).isNotEmpty) {
      exerciseList = db.readExercisesFromDatabase();
    } else {
      // Save default exercises
      db.saveExercisesToDatabase(exerciseList);
      
    }
    */
  }

  Future<void> initialiseExerciseInstances() async {
    if (currentUser != null) {
      final uid = currentUser!.uid;
      final CollectionReference exerciseInstancesCollectionRef =
          FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .collection("exercise-instances");

      final querySnapshot = await exerciseInstancesCollectionRef.get();

      final exerciseInstancesInFirestore = querySnapshot.docs
          .map((doc) => FirestoreService().readExerciseInstancesFromSnapshot(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      if (exerciseInstancesInFirestore.isNotEmpty) {
        for (var exerciseInstance in exerciseInstancesInFirestore) {
          /* Each exerciseInstance is still stored as 
          {
            'exerciseName': ...,
            'instances': ...,
          } 
          so we need to add them all to one common map where the keys are each exerciseName and the values are the corresponding instances. */

          final String exerciseName = exerciseInstance['exerciseName'];
          final List<PerformedWorkout> instances =
              exerciseInstance['instances'];

          exerciseInstances[exerciseName] = instances;
        }
        db.saveExerciseInstancesToDatabase(exerciseInstances);
        notifyListeners();
      } else {
        db.saveExerciseInstancesToDatabase({});
      }
    }
    throw (e) {
      print("USER IS NULL.");
    };
    /*
    if (db.prevDataExists() &&
        db.myBox.get('EXERCISE_INSTANCES') != null &&
        (db.myBox.get('EXERCISE_INSTANCES') as Map).isNotEmpty) {
      exerciseInstances = db.readExerciseInstancesFromDatabase();
    } else {
      // Save default exercises
      db.saveExerciseInstancesToDatabase(exerciseInstances);
    }
    */
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

      FirestoreService().saveExerciseInstancesToFirestore(
          exercise, exerciseInstances[exercise.name]!);
    }

    notifyListeners();
    db.saveExerciseInstancesToDatabase(exerciseInstances);
  }

  // This is for ExerciseListPage; we don't need the set data to build the ExerciseTiles.
  void addExerciseToExerciseList(String exerciseName, BodyPart bodyPart) {
    exerciseList.add(
      Exercise(
        name: exerciseName,
        setWeightReps: null,
        setsCompletion: null,
        bodyPart: bodyPart,
        exerciseId: const Uuid().v4(),
      ),
    );

    notifyListeners();
    db.saveExercisesToDatabase(exerciseList);
    FirestoreService().saveExercisesToFirestore(exerciseList);
  }

  void editExerciseInExerciseList(
    String originalExerciseName,
    String editedExerciseName,
    BodyPart editedBodyPart,
  ) {
    int index = exerciseList
        .indexWhere((element) => element.name == originalExerciseName);

    if (index != -1) {
      final editedExercise = Exercise(
        name: editedExerciseName,
        setWeightReps: null,
        setsCompletion: null,
        bodyPart: editedBodyPart,
        exerciseId: exerciseList[index].exerciseId,
      );

      exerciseList[index] = editedExercise;

      FirestoreService().updateExerciseInFirestore(exerciseList[index]);
    }

    notifyListeners();
    db.saveExercisesToDatabase(exerciseList);
  }

  void deleteExerciseFromExerciseList(String exerciseName) {
    int index =
        exerciseList.indexWhere((element) => element.name == exerciseName);
    FirestoreService().deleteExerciseFromFirestore(exerciseList[index]);

    exerciseList.removeWhere((element) => element.name == exerciseName);
    notifyListeners();
    db.saveExercisesToDatabase(exerciseList);
  }

  void addExerciseToExerciseListAtIndex(Exercise exercise, int index) {
    exerciseList.insert(index, exercise);

    notifyListeners();
    db.saveExercisesToDatabase(exerciseList);
    FirestoreService().saveExercisesToFirestore(exerciseList);
  }
}
