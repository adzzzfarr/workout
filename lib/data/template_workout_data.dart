import 'package:flutter/material.dart';
import 'package:workout/data/defaults.dart';
import 'package:workout/database/hive_database.dart';
import 'package:workout/models/exercise.dart';
import 'package:workout/models/template_workout.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout/firebase/firestore_service.dart';
import '../models/performed_workout.dart';

class TemplateWorkoutData extends ChangeNotifier {
  final db = HiveDatabase();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  List<TemplateWorkout> templateWorkoutList = defaultTemplateWorkoutList;

  Future<void> initialiseTemplateWorkoutList() async {
    if (currentUser != null) {
      final uid = currentUser!.uid;
      final CollectionReference templateWorkoutsCollectionRef =
          FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .collection("template-workouts");

      final querySnapshot = await templateWorkoutsCollectionRef.get();
      final templateWorkoutsInFirestore = querySnapshot.docs
          .map((doc) => FirestoreService().readTemplateWorkoutFromSnapshot(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      if (templateWorkoutsInFirestore.isNotEmpty && !db.prevDataExists()) {
        // Handles the case of a user reading existing cloud data for the first time on a new device
        templateWorkoutList = templateWorkoutsInFirestore;
        db.saveTemplateWorkoutsToDatabase(templateWorkoutList);
        notifyListeners();
      } else if (db.prevDataExists() &&
          db.myBox.get('TEMPLATE_WORKOUTS') != null &&
          (db.myBox.get('TEMPLATE_WORKOUTS') as List).isNotEmpty) {
        // Handles the case of a user having logged in before and thus having their cloud data saved to local storage already, as in the 'if' block
        templateWorkoutList = db.readTemplateWorkoutsFromDatabase();
      } else {
        // Handles the case of a user not having any existing cloud data nor local data
        db.saveTemplateWorkoutsToDatabase(templateWorkoutList);

        for (var templateWorkout in templateWorkoutList) {
          FirestoreService().saveTemplateWorkoutToFirestore(templateWorkout);
        }
      }
    }
    throw (e) {
      print("USER IS NULL.");
    };
    /*
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
    */
  }

  int getNumberOfExercises(String workoutName) {
    TemplateWorkout intendedWorkout = getIntendedTemplateWorkout(workoutName);

    return intendedWorkout.exercises.length;
  }

  void addWorkout(String name) {
    templateWorkoutList.add(
      TemplateWorkout(
        name: name,
        exercises: [],
        templateWorkoutId: const Uuid().v4(),
      ),
    );

    notifyListeners();
    db.saveTemplateWorkoutsToDatabase(templateWorkoutList);
    FirestoreService().saveTemplateWorkoutsToFirestore(templateWorkoutList);
  }

  void addExerciseToTemplateWorkout(
    String workoutName,
    Exercise exercise,
    int sets,
  ) {
    TemplateWorkout intendedWorkout = getIntendedTemplateWorkout(workoutName);

    Map<String, List<dynamic>> setWeightReps = {};
    Map<String, bool> setsCompletion = {};

    for (int i = 1; i <= sets; i++) {
      setWeightReps[i.toString()] = [0.0, 0];
      setsCompletion[i.toString()] = false;
    }

    intendedWorkout.exercises.add(
      Exercise(
        name: exercise.name,
        setWeightReps: setWeightReps,
        setsCompletion: setsCompletion,
        bodyPart: exercise.bodyPart,
        exerciseId: exercise.exerciseId,
      ),
    );

    notifyListeners();
    db.saveTemplateWorkoutsToDatabase(templateWorkoutList);
    FirestoreService().saveTemplateWorkoutsToFirestore(templateWorkoutList);
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
        editedSetWeightReps!
            .removeWhere((key, value) => int.parse(key) > editedNoOfSets);
      } else if (editedNoOfSets > originalNoOfSets) {
        for (int i = originalNoOfSets + 1; i <= editedNoOfSets; i++) {
          editedSetWeightReps![i.toString()] = [0.0, 0];
        }
      }
      // if editedNoOfSets == originalNoOfSets, there is no need to change setWeightReps

      Exercise editedExercise = Exercise(
        name: exerciseName,
        setWeightReps: editedSetWeightReps,
        setsCompletion: intendedWorkout.exercises[index].setsCompletion,
        bodyPart: intendedWorkout.exercises[index].bodyPart,
        exerciseId: intendedWorkout.exercises[index].exerciseId,
      );

      intendedWorkout.exercises[index] = editedExercise;
      notifyListeners();
      db.saveTemplateWorkoutsToDatabase(templateWorkoutList);
      FirestoreService().saveTemplateWorkoutsToFirestore(templateWorkoutList);
    }
  }

  void deleteExerciseFromTemplateWorkout(
      String workoutName, String exerciseName) {
    TemplateWorkout intendedWorkout = getIntendedTemplateWorkout(workoutName);

    intendedWorkout.exercises
        .removeWhere((exercise) => exercise.name == exerciseName);

    notifyListeners();
    db.saveTemplateWorkoutsToDatabase(templateWorkoutList);
    FirestoreService().updateTemplateWorkoutInFirestore(intendedWorkout);
  }

  void addExerciseToTemplateWorkoutAtIndex(
      String workoutName, Exercise exercise, int index) {
    TemplateWorkout intendedWorkout = getIntendedTemplateWorkout(workoutName);
    intendedWorkout.exercises.insert(index, exercise);

    notifyListeners();
    db.saveTemplateWorkoutsToDatabase(templateWorkoutList);
    FirestoreService().saveTemplateWorkoutsToFirestore(templateWorkoutList);
  }

  void deleteWorkout(String workoutName) {
    int index = templateWorkoutList
        .indexWhere((element) => element.name == workoutName);

    FirestoreService()
        .deleteTemplateWorkoutFromFirestore(templateWorkoutList[index]);

    templateWorkoutList.removeWhere((workout) => workout.name == workoutName);
    notifyListeners();
    db.saveTemplateWorkoutsToDatabase(templateWorkoutList);
  }

  void addWorkoutAtIndex(TemplateWorkout workout, int index) {
    templateWorkoutList.insert(index, workout);

    notifyListeners();
    db.saveTemplateWorkoutsToDatabase(templateWorkoutList);
    FirestoreService().saveTemplateWorkoutsToFirestore(templateWorkoutList);
  }

  void updateTemplateWorkout(PerformedWorkout completedWorkout) {
    int index = templateWorkoutList
        .indexWhere((element) => element.name == completedWorkout.name);

    templateWorkoutList[index] = TemplateWorkout(
      name: completedWorkout.name,
      exercises: completedWorkout.exercises,
      templateWorkoutId: templateWorkoutList[index].templateWorkoutId,
    );

    notifyListeners();
    db.saveTemplateWorkoutsToDatabase(templateWorkoutList);
    FirestoreService()
        .updateTemplateWorkoutInFirestore(templateWorkoutList[index]);
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
}
