import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/performed_workout_data.dart';
import 'package:workout/models/performed_workout.dart';
import 'package:fl_chart/fl_chart.dart';

class BodyPartsChart extends StatelessWidget {
  const BodyPartsChart({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, int> bodyPartSets = getCurrentWeekBodyPartSets(context);
    Map<String, int> sortedBySets = SplayTreeMap.from(
      bodyPartSets,
      (key1, key2) => bodyPartSets[key2]! > bodyPartSets[key1]! ? 1 : -1,
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final screenHeight = MediaQuery.of(context).size.height;
    print('SCREENHEIGHT: $screenHeight');
    final screenWidth = MediaQuery.of(context).size.width;
    print('SCREENWIDTH: $screenWidth');

    return Card(
      color: HSLColor.fromColor(colorScheme.background)
          .withLightness(0.2)
          .toColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.grey[600]!,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: screenWidth / 17.5, top: screenHeight / 50),
            child: Text(
              'Sets This Week',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenHeight / 37.5,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sections: getPieChartSectionData(bodyPartSets),
                      centerSpaceRadius: screenWidth /
                          7.5, //If you have a padding widget around the PieChart, make sure to set PieChartData.centerSpaceRadius to double.infinity
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.black, width: 0.5),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: screenHeight / 20, left: screenWidth / 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var bodyPart in sortedBySets.keys)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                height: screenHeight / 70,
                                width: screenWidth / 35,
                                color: getColor(bodyPart),
                              ),
                              SizedBox(width: screenWidth / 65),
                              Text(
                                bodyPart,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenHeight / 55,
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: screenHeight / 15),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> getCurrentWeekBodyPartSets(BuildContext context) {
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

    return bodyPartSets;
  }

  List<PieChartSectionData> getPieChartSectionData(
      Map<String, int> bodyPartSets) {
    List<PieChartSectionData> sections = bodyPartSets.entries
        .map((entry) => PieChartSectionData(
              color: getColor(entry.key),
              value: entry.value.toDouble(),
              title: entry.value.toString(),
              titleStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ))
        .toList();

    return sections;
  }

  Color getColor(String bodyPart) {
    switch (bodyPart) {
      case 'Arms':
        return Colors.orange;
      case 'Shoulders':
        return Colors.purple;
      case 'Chest':
        return Colors.red;
      case 'Back':
        return Colors.green;
      case 'Legs':
        return Colors.blue;
      case 'Core':
        return Colors.yellow;
      case 'Full Body':
        return Colors.brown;
      default:
        return Colors.black;
    }
  }
}
