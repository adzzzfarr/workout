import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/performed_workout_data.dart';
import 'package:workout/models/performed_workout.dart';

class CompletedWorkoutsChart extends StatelessWidget {
  const CompletedWorkoutsChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    List<int> weeklyCounts = getWeeklyCounts(context);

    DateTime startOfCurrentWeek =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    startOfCurrentWeek = getDateOnly(startOfCurrentWeek);

    List<DateTime> lastFourWeeks = List.generate(4,
            (index) => startOfCurrentWeek.subtract(Duration(days: index * 7)))
        .reversed
        .toList();

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
              left: screenWidth / 17.5,
              top: screenHeight / 55,
            ),
            child: Text(
              'Workouts Per Week',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenHeight / 37.5,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: screenWidth / 20,
                right: screenWidth / 20,
                top: screenHeight / 55,
                bottom: screenHeight / 110,
              ),
              child: BarChart(
                BarChartData(
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(sideTitles: SideTitles()),
                    leftTitles: AxisTitles(sideTitles: SideTitles()),
                    rightTitles: AxisTitles(sideTitles: SideTitles()),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: screenHeight / 15,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < 4) {
                            DateTime startDate = lastFourWeeks[index];
                            DateTime endDate =
                                startDate.add(const Duration(days: 6));

                            return Padding(
                              padding: EdgeInsets.only(top: screenHeight / 175),
                              child: SizedBox(
                                width: screenWidth / 5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 3),
                                      child: Text(
                                        '${startDate.day}/${startDate.month} -',
                                        style: TextStyle(
                                          color: colorScheme.onBackground,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${endDate.day}/${endDate.month}',
                                      style: TextStyle(
                                          color: colorScheme.onBackground),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                          return const Text('Error');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey, width: 0.5),
                  ),
                  barGroups: List.generate(
                    4,
                    (index) {
                      int count = weeklyCounts[index];

                      return BarChartGroupData(
                        x: index,
                        barRods: List.generate(
                          1,
                          (index) => BarChartRodData(
                            borderRadius: BorderRadius.circular(2.5),
                            toY: 7,
                            color: Colors.transparent,
                            width: screenWidth / 8.25,
                            rodStackItems: [
                              for (int i = 0; i < count; i++)
                                BarChartRodStackItem(
                                    i.toDouble(),
                                    i + 1,
                                    const Color.fromARGB(255, 9, 103, 137),
                                    const BorderSide(
                                      color: Colors.grey,
                                      width: 0.3,
                                    ))
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    checkToShowHorizontalLine: (value) => true,
                    getDrawingHorizontalLine: (value) {
                      if (value == 0) {
                        return FlLine(color: Colors.black, strokeWidth: 3);
                      }
                      return FlLine(
                          color: const Color(0xff37434d), strokeWidth: 0.5);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<int> getWeeklyCounts(BuildContext context) {
    DateTime startOfCurrentWeek =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    startOfCurrentWeek = getDateOnly(startOfCurrentWeek);

    List<int> fourWeekData = List.generate(4, (index) {
      DateTime startOfWeek =
          startOfCurrentWeek.subtract(Duration(days: index * 7));
      List<PerformedWorkout> completedWorkoutsInWeek =
          Provider.of<PerformedWorkoutData>(context, listen: false)
              .getCompletedWorkoutsInWeek(startOfWeek);

      return completedWorkoutsInWeek.length;
    }).reversed.toList();

    return fourWeekData;
  }

  // Removes timestamp to avoid errors when using a day as a key
  DateTime getDateOnly(DateTime dateTime) {
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    return dateOnly;
  }
}
