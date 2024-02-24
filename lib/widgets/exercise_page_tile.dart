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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: screenHeight / 200,
                left: screenWidth / 50,
                right: screenWidth / 50,
              ),
              child: Text(
                getFormattedDate(dateTimeToYYYYMMDD(dateTime)),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: screenHeight / 60,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: screenHeight / 200,
                right: screenWidth / 100,
              ),
              child: SizedBox(
                width: screenWidth * 0.75,
                child: const Divider(
                  thickness: 2,
                ),
              ),
            ),
          ],
        ),
        Card(
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
              workoutName,
              style:
                  TextStyle(color: Colors.white, fontSize: screenHeight / 47.5),
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
        ),
      ],
    );
  }

  String getFormattedDate(String dateYYYYMMDD) {
    String year = dateYYYYMMDD.substring(0, 4);

    // Remove leading zeroes, if any
    String month = dateYYYYMMDD.substring(4, 6);
    month = int.parse(month).toString();

    String day = dateYYYYMMDD.substring(6, 8);
    day = int.parse(day).toString();

    return '$day/$month/$year';
  }
}
