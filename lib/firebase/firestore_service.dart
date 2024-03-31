import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout/models/performed_workout.dart';
import 'package:workout/models/template_workout.dart';

import '../models/exercise.dart';

class FirestoreService {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot> getExercisesStream() {
    final uid = currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    return userDoc.collection("exercises").snapshots();
  }

  Stream<QuerySnapshot> getExerciseInstancesStream() {
    final uid = currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    return userDoc.collection("exercise-instances").snapshots();
  }

  Stream<QuerySnapshot> getTemplateWorkoutsStream() {
    final uid = currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    return userDoc.collection("template-workouts").snapshots();
  }

  Stream<QuerySnapshot> getCompletedWorkoutsStream() {
    final uid = currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    return userDoc.collection("completed-workouts").snapshots();
  }

  // This is only for ExerciseListPage
  Exercise readExerciseForExerciseListPageFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.data() != null) {
      return Exercise(
        name: snapshot.data()!['exerciseName'],
        setWeightReps: null,
        setsCompletion: null,
        bodyPart: getBodyPart(snapshot.data()!['bodyPart']),
        exerciseId: snapshot.data()!['exerciseId'],
      );
    }
    throw (e) {
      print('Error reading exercises from Firestore.');
    };
  }

  // This only reads the instances of ONE exercise, NOT all the instances of all exercises
  Map<String, dynamic> readExerciseInstancesFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.data() != null) {
      // The list of CompletedWorkouts in their json format
      final List<dynamic> instancesJsonList = snapshot.data()!['instances'];

      final List<PerformedWorkout> instancesList = [];

      // Convert to CompletedWorkouts
      for (var instanceJson in instancesJsonList) {
        final Map<String, dynamic> exercisesMap = instanceJson['exercises'];
        final List<Exercise> exerciseList = [];

        for (var exerciseMap in exercisesMap.values.toList()) {
          final exercise = Exercise(
            name: exerciseMap['exerciseName'],
            setWeightReps: (exerciseMap['setWeightReps'] as Map)
                .cast<String, List<dynamic>>(),
            setsCompletion:
                (exerciseMap['setsCompletion'] as Map).cast<String, bool>(),
            bodyPart: getBodyPart(exerciseMap['bodyPart']),
            exerciseId: exerciseMap['exerciseId'],
          );
          exerciseList.add(exercise);
        }

        final instance = PerformedWorkout(
          name: instanceJson['performedWorkoutName'],
          exercises: exerciseList,
          templateWorkoutId: instanceJson['templateWorkoutId'],
          date: (instanceJson['date'] as Timestamp).toDate(),
          durationInSeconds: instanceJson['durationInSeconds'],
          completedWorkoutId: instanceJson['completedWorkoutId'],
        );

        instancesList.add(instance);
      }

      return {
        'exerciseName': snapshot.data()!['exerciseName'],
        'instances': instancesList,
      };
    }
    throw (e) {
      print('Error reading exercise instances from Firestore.');
    };
  }

  TemplateWorkout readTemplateWorkoutFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.data() != null) {
      // Keys are the names of each exercise, Values are the json map of each exercise
      final Map<String, dynamic> exercisesMap = snapshot.data()!['exercises'];

      final List<Exercise> exerciseList = [];

      for (var exerciseMap in exercisesMap.values.toList()) {
        final exercise = Exercise(
          name: exerciseMap['exerciseName'],
          setWeightReps: (exerciseMap['setWeightReps'] as Map)
              .cast<String, List<dynamic>>(),
          setsCompletion:
              (exerciseMap['setsCompletion'] as Map).cast<String, bool>(),
          bodyPart: getBodyPart(exerciseMap['bodyPart']),
          exerciseId: exerciseMap['exerciseId'],
        );
        exerciseList.add(exercise);
      }

      return TemplateWorkout(
        name: snapshot.data()!['templateWorkoutName'],
        exercises: exerciseList,
        templateWorkoutId: snapshot.data()!['templateWorkoutId'],
      );
    }
    throw (e) {
      print('Error reading template workouts from Firestore.');
    };
  }

  PerformedWorkout readCompletedWorkoutFromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.data() != null) {
      final Map<String, dynamic> exercisesMap = snapshot.data()!['exercises'];

      final List<Exercise> exerciseList = [];

      for (var exerciseMap in exercisesMap.values.toList()) {
        final exercise = Exercise(
          name: exerciseMap['exerciseName'],
          setWeightReps: (exerciseMap['setWeightReps'] as Map)
              .cast<String, List<dynamic>>(),
          setsCompletion:
              (exerciseMap['setsCompletion'] as Map).cast<String, bool>(),
          bodyPart: getBodyPart(exerciseMap['bodyPart']),
          exerciseId: exerciseMap['exerciseId'],
        );
        exerciseList.add(exercise);
      }

      return PerformedWorkout(
        name: snapshot.data()!['performedWorkoutName'],
        exercises: exerciseList,
        templateWorkoutId: snapshot.data()!['templateWorkoutId'],
        date: (snapshot.data()!['date'] as Timestamp).toDate(),
        durationInSeconds: snapshot.data()!['durationInSeconds'],
        completedWorkoutId: snapshot.data()!['completedWorkoutId'],
      );
    }
    throw (e) {
      print('Error reading completed workouts from Firestore.');
    };
  }

  void saveExercisesToFirestore(List<Exercise> exercises) {
    final uid = currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    for (var exercise in exercises) {
      final exerciseJson = exercise.toJson();

      final exerciseId = exercise.exerciseId;

      userDoc.collection("exercises").doc(exerciseId).set(exerciseJson);
    }
  }

  void saveExerciseInstancesToFirestore(
      Exercise exercise, List<PerformedWorkout> instances) {
    final uid = currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    // Need to define the Json list here as we don't have an ExerciseInstance class where we can define a .toJson() method
    final instanceJsonList = [];

    for (var instance in instances) {
      final instanceJson = instance.toJson();
      instanceJsonList.add(instanceJson);
    }

    final Map<String, dynamic> exerciseInstancesMap = {
      'exerciseName': exercise.name,
      'instances': instanceJsonList,
    };

    userDoc
        .collection("exercise-instances")
        .doc(exercise.exerciseId)
        .set(exerciseInstancesMap);
  }

  void saveTemplateWorkoutToFirestore(TemplateWorkout templateWorkout) {
    final uid = currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    final templateWorkoutJson = templateWorkout.toJson();

    final templateWorkoutId = templateWorkout.templateWorkoutId;

    userDoc
        .collection("template-workouts")
        .doc(templateWorkoutId)
        .set(templateWorkoutJson);
  }

  void saveTemplateWorkoutsToFirestore(List<TemplateWorkout> templateWorkouts) {
    final uid = currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    for (var templateWorkout in templateWorkouts) {
      final templateWorkoutJson = templateWorkout.toJson();

      final templateWorkoutId = templateWorkout.templateWorkoutId;

      userDoc
          .collection("template-workouts")
          .doc(templateWorkoutId)
          .set(templateWorkoutJson);
    }
  }

  void saveCompletedWorkoutToFirestore(PerformedWorkout completedWorkout) {
    final uid = currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    final completedWorkoutJson = completedWorkout.toJson();

    final completedWorkoutId = completedWorkout.completedWorkoutId;

    userDoc
        .collection("completed-workouts")
        .doc(completedWorkoutId)
        .set(completedWorkoutJson);
  }

  void saveCompletedWorkoutsToFirestore(
      List<PerformedWorkout> completedWorkouts) {
    final uid = currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    for (var completedWorkout in completedWorkouts) {
      final completedWorkoutJson = completedWorkout.toJson();
      final completedWorkoutId = completedWorkout.completedWorkoutId;

      userDoc
          .collection("completed-workouts")
          .doc(completedWorkoutId)
          .set(completedWorkoutJson);
    }
  }

  void deleteExerciseFromFirestore(Exercise exercise) {
    final uid = currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    userDoc.collection("exercises").doc(exercise.exerciseId).delete();
  }

  void deleteTemplateWorkoutFromFirestore(TemplateWorkout templateWorkout) {
    final uid = currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    userDoc
        .collection("template-workouts")
        .doc(templateWorkout.templateWorkoutId)
        .delete();
  }

  // The update functions are only for data which has been changed after they have been saved to Firestore.
  // It does not apply for updates such as recording new set data in PerformedWorkoutPage as those changes are handled locally first before being uploaded to Firestore. They cannot be updated after they have been saved.

  // Only for ExerciseList
  void updateExerciseInFirestore(Exercise editedExercise) {
    final editedExerciseJson = editedExercise.toJson();

    final uid = currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    // Edited Exercises have the same id as the original exercise
    userDoc
        .collection("exercises")
        .doc(editedExercise.exerciseId)
        .update(editedExerciseJson);
  }

  void updateTemplateWorkoutInFirestore(TemplateWorkout editedTemplateWorkout) {
    final editedTemplateWorkoutJson = editedTemplateWorkout.toJson();

    final uid = currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    // Edited TemplateWorkouts have the same id as the original exercise
    userDoc
        .collection("template-workouts")
        .doc(editedTemplateWorkout.templateWorkoutId)
        .set(editedTemplateWorkoutJson);
  }

  BodyPart getBodyPart(String bodyPartName) {
    switch (bodyPartName) {
      case 'Arms':
        return BodyPart.arms;
      case 'Shoulders':
        return BodyPart.shoulders;
      case 'Chest':
        return BodyPart.chest;
      case 'Back':
        return BodyPart.back;
      case 'Legs':
        return BodyPart.legs;
      case 'Core':
        return BodyPart.core;
      case 'Full Body':
        return BodyPart.fullBody;
    }

    throw (e) {
      print('getBodyPart error');
    };
  }
}
