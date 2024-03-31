import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class WorkoutHeatMapCalendar extends StatelessWidget {
  final Map<DateTime, int>? datasets;
  final void Function(DateTime dateTime) onBlockTapped;

  const WorkoutHeatMapCalendar({
    required this.datasets,
    required this.onBlockTapped,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      color: Colors.white38,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.grey[600]!,
          width: 0.5,
        ),
      ),
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.only(
          top: screenHeight / 80,
          bottom: screenHeight / 50,
          left: screenWidth / 40,
          right: screenWidth / 40,
        ),
        child: HeatMapCalendar(
          datasets: datasets,
          colorMode: ColorMode.color,
          defaultColor: Colors.grey,
          textColor: Colors.white,
          fontSize: screenHeight / 50,
          monthFontSize: screenHeight / 40,
          weekFontSize: screenHeight / 50,
          weekTextColor: Colors.white,
          showColorTip: false,
          flexible: true,
          colorsets: const {
            1: Colors.green,
          },
          onClick: (dateTime) => onBlockTapped(dateTime),
        ),
      ),
    );
  }
}
