import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/date_time.dart';
import 'package:workout/data/performed_workout_data.dart';
import 'package:workout/models/performed_workout.dart';
import 'package:workout/widgets/exercise_tile.dart';

class CompletedWorkoutPage extends StatefulWidget {
  final PerformedWorkout completedWorkout;

  const CompletedWorkoutPage({required this.completedWorkout, super.key});

  @override
  State<CompletedWorkoutPage> createState() => _CompletedWorkoutPageState();
}

class _CompletedWorkoutPageState extends State<CompletedWorkoutPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PerformedWorkoutData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: Text(widget.completedWorkout.name),
        ),
        body: Builder(
          builder: (context) {
            return Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                          'Performed on ${dateTimeToYYYYMMDD(widget.completedWorkout.date)}. Duration of workout was ${widget.completedWorkout.getFormattedDuration()}.'),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: value.getNumberOfExercisesInCompletedWorkout(
                            widget.completedWorkout.date,
                            widget.completedWorkout.name),
                        itemBuilder: (context, index) => Builder(
                          builder: (context) => ExerciseTile(
                            workoutType: 'completed',
                            exercise: value
                                .getIntendedCompletedWorkout(
                                    widget.completedWorkout.date,
                                    widget.completedWorkout.name)!
                                .exercises[index],
                            onEditSet: null,
                            onCheckboxChanged: null,
                            onTilePressed: null,
                            onDismissed: null,
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
}
