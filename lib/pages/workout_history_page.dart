import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/date_time.dart';
import 'package:workout/data/exercise_data.dart';
import 'package:workout/data/performed_workout_data.dart';
import 'package:workout/models/exercise.dart';
import 'package:workout/models/performed_workout.dart';
import 'package:workout/pages/completed_workout_page.dart';
import 'package:workout/widgets/workout_history_tile.dart';

class WorkoutHistoryPage extends StatefulWidget {
  const WorkoutHistoryPage({super.key});

  @override
  State<WorkoutHistoryPage> createState() => _WorkoutHistoryPageState();
}

class _WorkoutHistoryPageState extends State<WorkoutHistoryPage> {
  @override
  void initState() {
    super.initState();

    Provider.of<PerformedWorkoutData>(context, listen: false)
        .initialiseCompletedWorkoutList();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<PerformedWorkoutData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Workout History'),
        ),
        body: value.completedWorkoutList.isNotEmpty
            ? Builder(
                builder: (context) => ListView.builder(
                  itemCount: value.completedWorkoutList.length,
                  itemBuilder: (context, index) => WorkoutHistoryTile(
                    completedWorkout: value.completedWorkoutList[index],
                    tileKey: Key(
                        '${value.completedWorkoutList[index].name}${value.completedWorkoutList[index].date}'),
                    onTilePressed: () => goToCompletedWorkoutPage(
                        value.completedWorkoutList[index]),
                    onDismissed: (direction) {
                      PerformedWorkout deletedWorkout =
                          value.completedWorkoutList[index];
                      int deletedWorkoutIndex = index;

                      deleteCompletedWorkout(
                          deletedWorkout.name, deletedWorkout.date);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${deletedWorkout.name} deleted.'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () => undoDeleteCompletedWorkout(
                                deletedWorkout, deletedWorkoutIndex),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            : Center(
                child: Text(
                  'No completed workouts.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: screenHeight / 45,
                  ),
                ),
              ),
      ),
    );
  }

  void deleteCompletedWorkout(String workoutName, DateTime workoutDate) {
    Provider.of<PerformedWorkoutData>(context, listen: false)
        .deleteCompletedWorkout(workoutName, workoutDate);
  }

  void undoDeleteCompletedWorkout(
      PerformedWorkout deletedWorkout, int deletedWorkoutIndex) {
    Provider.of<PerformedWorkoutData>(context, listen: false)
        .addCompletedWorkoutAtIndex(deletedWorkout, deletedWorkoutIndex);
  }

  void goToCompletedWorkoutPage(PerformedWorkout completedWorkout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CompletedWorkoutPage(completedWorkout: completedWorkout),
      ),
    );
  }
}
