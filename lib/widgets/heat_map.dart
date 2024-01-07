import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:workout/data/date_time.dart';

class WorkoutHeatMap extends StatelessWidget {
  final Map<DateTime, int>? datasets;

  const WorkoutHeatMap({required this.datasets, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const spacing = 4.0;

    DateTime now = DateTime.now();
    DateTime startDate = getFirstDayOfMonth(now);
    DateTime endDate = getLastDayOfMonth(now);

    return Container(
      padding: const EdgeInsets.all(25),
      child: HeatMap(
        startDate: startDate,
        endDate: endDate,
        datasets: datasets,
        colorMode: ColorMode.color,
        defaultColor: Colors.grey[200],
        textColor: Colors.white,
        showColorTip: false,
        showText: true,
        scrollable: true,
        size: 30,
        colorsets: const {
          1: Colors.green,
        },
      ),
    );
  }

  DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
}
