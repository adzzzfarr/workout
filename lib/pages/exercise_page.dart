import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/date_time.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    Map<DateTime, List<dynamic>> exerciseInstances =
        getAllExerciseInstances(widget.exerciseName);
    List<DateTime> dates = exerciseInstances.keys.toList();
    List<List<dynamic>> values = exerciseInstances.values.toList();
    List<PerformedWorkout> performedWorkouts =
        values.map((e) => e[0] as PerformedWorkout).toList();
    List<Map<int, List<dynamic>>> setData =
        values.map((e) => e[1] as Map<int, List<dynamic>>).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
      ),
      body: Builder(builder: (context) {
        return Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                    '${dateTimeToYYYYMMDD(dates[0])} in ${performedWorkouts[0].name}'),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: exerciseInstances.length,
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
                      '${dateTimeToYYYYMMDD(dates[indexPlusOne])} in ${performedWorkouts[indexPlusOne].name}');
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Map<DateTime, List<dynamic>> getAllExerciseInstances(String exerciseName) {
    final completedWorkoutList =
        Provider.of<PerformedWorkoutData>(context).getCompletedWorkoutList();

    Map<DateTime, List<dynamic>> dateWorkoutSetData = {};
    // Keys are the date the exercise was performed, Values are a List where element 0 is the PerformedWorkout the exercise was performed in and element 1 is the set data

    for (var workout in completedWorkoutList) {
      for (var exercise in workout.exercises) {
        if (exercise.name == exerciseName) {
          dateWorkoutSetData[workout.date] = [workout, exercise.setWeightReps];
        }
      }
    }

    // Most recent is first
    final sorted = SplayTreeMap.from(
      dateWorkoutSetData,
      (key1, key2) => (key2 as DateTime).compareTo((key1 as DateTime)),
    );
    return Map.from(sorted);
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
