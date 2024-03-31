import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/exercise_data.dart';
import 'package:workout/firebase/firestore_service.dart';
import 'package:workout/models/performed_workout.dart';
import 'package:workout/widgets/exercise_page_tile.dart';
import '../data/performed_workout_data.dart';

class ExercisePage extends StatefulWidget {
  final String exerciseName;
  const ExercisePage({required this.exerciseName, super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  @override
  void initState() {
    super.initState();
    Provider.of<PerformedWorkoutData>(context, listen: false)
        .initialiseCompletedWorkoutList();
    Provider.of<ExerciseData>(context, listen: false)
        .initialiseExerciseInstances();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    Map<DateTime, List<dynamic>>? exerciseInstancesData =
        getExerciseInstancesData(widget.exerciseName);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
      ),
      body: Builder(
        builder: (context) {
          if (exerciseInstancesData != null) {
            List<DateTime> dates = exerciseInstancesData.keys.toList();
            List<List<dynamic>> values = exerciseInstancesData.values.toList();
            List<String> performedWorkoutNames =
                values.map((e) => e[0] as String).toList();
            List<Map<String, List<dynamic>>> setData =
                values.map((e) => e[1] as Map<String, List<dynamic>>).toList();

            return StreamBuilder<QuerySnapshot>(
              stream: FirestoreService().getExerciseInstancesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: screenHeight / 100,
                          bottom: screenHeight / 100,
                          left: screenWidth / 25,
                        ),
                        child: Text('Exercise History',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenHeight / 37.5)),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: exerciseInstancesData.length,
                          itemBuilder: (context, index) => Builder(
                            builder: (context) => ExercisePageTile(
                                dateTime: dates[index],
                                workoutName: performedWorkoutNames[index],
                                setsList: convertToSetsList(setData[index])),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            );
          } else {
            return Center(
              child: Text(
                'No exercise data.',
                style: TextStyle(
                  fontSize: screenHeight / 40,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // Returns a Map where the keys are the date the exercise was performed, Values are a List where element 0 is the name of the PerformedWorkout the exercise was performed in and element 1 is the set data
  Map<DateTime, List<dynamic>>? getExerciseInstancesData(String exerciseName) {
    Map<String, List<PerformedWorkout>> exerciseInstances =
        Provider.of<ExerciseData>(context, listen: false).exerciseInstances;

    Map<DateTime, List<dynamic>> dateWorkoutSetData = {};

    for (var exerciseNameKey in exerciseInstances.keys) {
      if (exerciseNameKey == exerciseName) {
        List<PerformedWorkout> completedWorkouts =
            exerciseInstances[exerciseNameKey]!;

        for (var workout in completedWorkouts) {
          dateWorkoutSetData[workout.date] = [
            workout.name,
            workout.exercises
                .firstWhere((element) => element.name == exerciseNameKey)
                .setWeightReps
          ];
        }
      }
    }

    if (dateWorkoutSetData.isEmpty) {
      return null;
    }
    return dateWorkoutSetData;
  }

  List<Map<String, dynamic>> convertToSetsList(
      Map<String, List<dynamic>> setWeightReps) {
    return setWeightReps.entries
        .map((entry) => {
              'set': entry.key,
              'weight': entry.value[0],
              'reps': entry.value[1],
            })
        .toList();
  }
}
