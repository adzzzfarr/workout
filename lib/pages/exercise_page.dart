import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/date_time.dart';
import 'package:workout/data/exercise_data.dart';
import 'package:workout/models/performed_workout.dart';

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
            List<Map<int, List<dynamic>>> setData =
                values.map((e) => e[1] as Map<int, List<dynamic>>).toList();

            return Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                        '${dateTimeToYYYYMMDD(dates[0])} in ${performedWorkoutNames[0]}'),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: exerciseInstancesData.length,
                    itemBuilder: (context, index) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var setEntry in convertToSetsList(setData[index]))
                          Row(
                            children: [
                              Text('Set ${setEntry['set'].toString()}: '),
                              Text(
                                  '${setEntry['weight'].toString()} KG, ${setEntry['reps'].toString()} Reps'),
                            ],
                          ),
                      ],
                    ),
                    separatorBuilder: (context, index) {
                      int indexPlusOne = index + 1;
                      return Text(
                          '${dateTimeToYYYYMMDD(dates[indexPlusOne])} in ${performedWorkoutNames[indexPlusOne]}');
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Text('No exercise data');
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
    print(dateWorkoutSetData);
    return dateWorkoutSetData;
  }

  List<Map<String, dynamic>> convertToSetsList(
      Map<int, List<dynamic>> setWeightReps) {
    return setWeightReps.entries
        .map((entry) => {
              'set': entry.key,
              'weight': entry.value[0],
              'reps': entry.value[1],
            })
        .toList();
  }
}
