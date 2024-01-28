import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/performed_workout_data.dart';
import 'package:workout/models/performed_workout.dart';
import 'package:fl_chart/fl_chart.dart';

class BodyPartsChart extends StatelessWidget {
  const BodyPartsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: getCurrentWeekBodyPartSetsData(context),
        centerSpaceRadius:
            50, //If you have a padding widget around the PieChart, make sure to set PieChartData.centerSpaceRadius to double.infinity
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black, width: 0.5),
        ),
        sectionsSpace: 0.1,
      ),
    );
  }

  List<PieChartSectionData> getCurrentWeekBodyPartSetsData(
      BuildContext context) {
    Map<String, int> bodyPartSets = {};
    // Keys are body parts, values are number of sets performed in the week for exercises involving that body part

    DateTime startOfCurrentWeek =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

    List<PerformedWorkout> completedWorkoutsInWeek =
        Provider.of<PerformedWorkoutData>(context, listen: false)
            .getCompletedWorkoutsInWeek(startOfCurrentWeek);

    for (var workout in completedWorkoutsInWeek) {
      for (var exercise in workout.exercises) {
        String bodyPart = exercise.getFormattedBodyPart(exercise.bodyPart);
        int noOfSets = exercise.setWeightReps!.length;

        if (bodyPartSets.containsKey(bodyPart)) {
          bodyPartSets[bodyPart] = bodyPartSets[bodyPart]! + noOfSets;
        } else {
          bodyPartSets[bodyPart] = noOfSets;
        }
      }
    }

    List<PieChartSectionData> sections = bodyPartSets.entries
        .map((entry) => PieChartSectionData(
              color: getColor(entry.key),
              value: entry.value.toDouble(),
              title: entry.key,
            ))
        .toList();

    return sections;
  }

  Color getColor(String bodyPart) {
    switch (bodyPart) {
      case 'Chest':
        return Colors.red;
      case 'Back':
        return Colors.green;
      case 'Legs':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }
}
