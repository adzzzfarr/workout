import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/date_time.dart';

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
    Map<DateTime, dynamic> exerciseInstances =
        getAllExerciseInstances(widget.exerciseName);
    List<DateTime> keys = exerciseInstances.keys.toList();
    List<dynamic> values = exerciseInstances.values.toList();

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
                child: Text(dateTimeToYYYYMMDD(keys[0])),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: exerciseInstances.length,
                itemBuilder: (context, index) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var setEntry in convertToSetsList(values[index]))
                      Row(
                        children: [
                          Text('Set ${setEntry['set'].toString()}: '),
                          Text(
                              '${setEntry['weight'].toString()} KG, ${setEntry['reps'].toString()} Reps'),
                        ],
                      ),
                  ],
                ),
                separatorBuilder: (context, index) =>
                    Text(dateTimeToYYYYMMDD(keys[index])),
              ),
            ),
          ],
        );
      }),
    );
  }

  Map<DateTime, dynamic> getAllExerciseInstances(String exerciseName) {
    final completedWorkoutList =
        Provider.of<PerformedWorkoutData>(context).getCompletedWorkoutList();

    Map<DateTime, dynamic> dateSetData = {};
    // Keys are the date the exercise was performed, Values are the set data

    for (var workout in completedWorkoutList) {
      for (var exercise in workout.exercises) {
        if (exercise.name == exerciseName) {
          dateSetData[workout.date] = exercise.setWeightReps;
        }
      }
    }

    final sorted = SplayTreeMap.from(
      dateSetData,
      (key1, key2) => (key1 as DateTime).compareTo((key2 as DateTime)),
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
