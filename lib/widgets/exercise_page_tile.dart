import 'package:flutter/material.dart';
import 'package:workout/data/date_time.dart';

class ExercisePageTile extends StatelessWidget {
  final DateTime dateTime;
  final String workoutName;
  final List<Map<String, dynamic>> setsList;

  const ExercisePageTile({
    required this.dateTime,
    required this.workoutName,
    required this.setsList,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
      child: ListTile(
        contentPadding: EdgeInsets.only(
          top: screenHeight / 100,
          bottom: screenHeight / 75,
          left: screenWidth / 17.5,
        ),
        title: Text(
          '$workoutName on ${dateTimeToYYYYMMDD(dateTime)}',
          style: TextStyle(color: Colors.white, fontSize: screenHeight / 47.5),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var setEntry in setsList)
              Row(
                children: [
                  Text(
                    'Set ${setEntry['set'].toString()}: ',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: screenHeight / 50),
                  ),
                  Text(
                    '${setEntry['weight'].toString()} KG, ${setEntry['reps'].toString()} Reps',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: screenHeight / 50),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
