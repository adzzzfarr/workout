import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/date_time.dart';
import 'package:workout/data/performed_workout_data.dart';
import 'package:workout/models/performed_workout.dart';
import 'package:workout/widgets/completed_workout_exercise_tile.dart';

class CompletedWorkoutPage extends StatefulWidget {
  final PerformedWorkout completedWorkout;

  const CompletedWorkoutPage({required this.completedWorkout, super.key});

  @override
  State<CompletedWorkoutPage> createState() => _CompletedWorkoutPageState();
}

class _CompletedWorkoutPageState extends State<CompletedWorkoutPage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<PerformedWorkoutData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(),
        body: Builder(
          builder: (context) {
            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: screenHeight / 100,
                        bottom: screenHeight / 100,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: screenWidth / 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.completedWorkout.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenHeight / 35,
                              ),
                            ),
                            Text(
                              getFormattedDate(dateTimeToYYYYMMDD(
                                  widget.completedWorkout.date)),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: screenHeight / 47.5,
                              ),
                            ),
                            Text(
                              widget.completedWorkout.getFormattedDuration(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: screenHeight / 47.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: value.getNumberOfExercisesInCompletedWorkout(
                            widget.completedWorkout.date,
                            widget.completedWorkout.name),
                        itemBuilder: (context, index) => Builder(
                          builder: (context) => CompletedWorkoutExerciseTile(
                            exercise: value
                                .getIntendedCompletedWorkout(
                                    widget.completedWorkout.date,
                                    widget.completedWorkout.name)!
                                .exercises[index],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
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
