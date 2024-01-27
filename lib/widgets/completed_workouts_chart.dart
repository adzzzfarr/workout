import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CompletedWorkoutsChart extends StatelessWidget {
  final List<DateTime> completedWorkoutDates;

  const CompletedWorkoutsChart(
      {required this.completedWorkoutDates, super.key});

  @override
  Widget build(BuildContext context) {
    List<int> weeklyCounts = getWeeklyCounts(completedWorkoutDates);

    DateTime startOfCurrentWeek =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    startOfCurrentWeek = getDateOnlyFromDateTime(startOfCurrentWeek);

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
                count,
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

  List<int> getWeeklyCounts(List<DateTime> completedWorkoutDates) {
    DateTime startOfCurrentWeek =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    startOfCurrentWeek = getDateOnlyFromDateTime(startOfCurrentWeek);

    Map<DateTime, int> weeklyCounts = {};
    // Keys are the first day of each week of the past 5 weeks, Values are the number of times user has worked out in that week

    print('CompletedWorkoutDates: $completedWorkoutDates');
    for (var date in completedWorkoutDates) {
      DateTime startOfWeekOfCompletion =
          date.subtract(Duration(days: date.weekday - DateTime.monday));
      startOfWeekOfCompletion =
          getDateOnlyFromDateTime(startOfWeekOfCompletion);

      if (weeklyCounts.containsKey(startOfWeekOfCompletion)) {
        weeklyCounts[startOfWeekOfCompletion] =
            weeklyCounts[startOfWeekOfCompletion]! + 1;
      } else {
        weeklyCounts[startOfWeekOfCompletion] = 1;
      }
    }

    List<int> fiveWeekData = List.generate(5, (index) {
      DateTime startOfWeek =
          startOfCurrentWeek.subtract(Duration(days: index * 7));
      startOfWeek = getDateOnlyFromDateTime(startOfWeek);

      return weeklyCounts[startOfWeek] ?? 0;
    }).reversed.toList();
    return fiveWeekData;
  }

  // Removes timestamp to avoid errors when using a day as a key
  DateTime getDateOnlyFromDateTime(DateTime dateTime) {
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    return dateOnly;
  }
}
