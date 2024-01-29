import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/performed_workout_data.dart';
import 'package:workout/models/performed_workout.dart';

class CompletedWorkoutsChart extends StatelessWidget {
  const CompletedWorkoutsChart({super.key});

  @override
  Widget build(BuildContext context) {
    List<int> weeklyCounts = getWeeklyCounts(context);

    DateTime startOfCurrentWeek =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    startOfCurrentWeek = getDateOnly(startOfCurrentWeek);

    List<DateTime> lastFiveWeeks = List.generate(5,
            (index) => startOfCurrentWeek.subtract(Duration(days: index * 7)))
        .reversed
        .toList();

    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles()),
          leftTitles: AxisTitles(sideTitles: SideTitles()),
          rightTitles: AxisTitles(sideTitles: SideTitles()),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < 5) {
                  DateTime startDate = lastFiveWeeks[index];
                  DateTime endDate = startDate.add(const Duration(days: 6));

                  return SizedBox(
                    width: 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 3),
                          child: Text('${startDate.day}/${startDate.month}'),
                        ),
                        Text('- ${endDate.day}/${endDate.month}')
                      ],
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
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        barGroups: List.generate(
          5,
          (index) {
            int count = weeklyCounts[index];

            return BarChartGroupData(
              x: index,
              barRods: List.generate(
                1,
                (index) => BarChartRodData(
                  borderRadius: BorderRadius.circular(5),
                  toY: 7,
                  color: Colors.transparent,
                  width: 50,
                  rodStackItems: [
                    for (int i = 0; i < count; i++)
                      BarChartRodStackItem(
                          i.toDouble(),
                          i + 1,
                          Colors.blue,
                          const BorderSide(
                              color: Colors.white,
                              width: 0.5,
                              strokeAlign: BorderSide.strokeAlignCenter))
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
            return FlLine(color: const Color(0xff37434d), strokeWidth: 0.3);
          },
        ),
      ),
    );
  }

  List<int> getWeeklyCounts(BuildContext context) {
    DateTime startOfCurrentWeek =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    startOfCurrentWeek = getDateOnly(startOfCurrentWeek);

    List<int> fiveWeekData = List.generate(5, (index) {
      DateTime startOfWeek =
          startOfCurrentWeek.subtract(Duration(days: index * 7));
      List<PerformedWorkout> completedWorkoutsInWeek =
          Provider.of<PerformedWorkoutData>(context, listen: false)
              .getCompletedWorkoutsInWeek(startOfWeek);

      return completedWorkoutsInWeek.length;
    }).reversed.toList();

    return fiveWeekData;
  }

  // Removes timestamp to avoid errors when using a day as a key
  DateTime getDateOnly(DateTime dateTime) {
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    return dateOnly;
  }
}
