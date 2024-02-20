import 'package:flutter/material.dart';
import 'package:workout/data/date_time.dart';
import 'package:workout/models/performed_workout.dart';

class WorkoutHistoryTile extends StatelessWidget {
  final PerformedWorkout completedWorkout;
  final Key tileKey;
  final void Function() onTilePressed;
  final void Function(DismissDirection direction) onDismissed;

  const WorkoutHistoryTile({
    required this.completedWorkout,
    required this.tileKey,
    required this.onTilePressed,
    required this.onDismissed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(top: screenHeight / 200),
      child: Column(
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
                  getFormattedDate(dateTimeToYYYYMMDD(completedWorkout.date)),
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
          GestureDetector(
            onTap: () => onTilePressed(),
            child: Dismissible(
              key: tileKey,
              onDismissed: (direction) => onDismissed(direction),
              child: Card(
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
                    top: screenHeight / 75,
                    bottom: screenHeight / 75,
                    left: screenWidth / 20,
                    right: screenWidth / 30,
                  ),
                  title: Text(
                    completedWorkout.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenHeight / 45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: screenHeight / 400),
                    child: Text(
                      completedWorkout.getFormattedDuration(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: screenHeight / 52.5,
                      ),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
          ),
        ],
      ),
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
