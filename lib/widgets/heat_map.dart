import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class WorkoutHeatMap extends StatelessWidget {
  final Map<DateTime, int>? datasets;

  const WorkoutHeatMap({required this.datasets, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    DateTime now = DateTime.now();
    DateTime startDate = getFirstDayOfMonth(now);
    DateTime endDate = getLastDayOfMonth(now);

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
            child: HeatMap(
              startDate: startDate,
              endDate: endDate,
              datasets: datasets,
              colorMode: ColorMode.color,
              defaultColor: Colors.grey,
              textColor: Colors.white,
              showColorTip: false,
              showText: true,
              scrollable: true,
              size: 30,
              colorsets: const {
                1: Colors.green,
              },
            ),
          ),
        ],
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
