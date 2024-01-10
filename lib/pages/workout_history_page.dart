import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/date_time.dart';
import 'package:workout/data/performed_workout_data.dart';
import 'package:workout/models/performed_workout.dart';
import 'package:workout/pages/completed_workout_page.dart';

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
    return Consumer<PerformedWorkoutData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Workout History'),
        ),
        body: value.completedWorkoutList.isNotEmpty
            ? Builder(
                builder: (context) => Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(dateTimeToYYYYMMDD(
                            value.completedWorkoutList[0].date)),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: value.completedWorkoutList.length,
                        itemBuilder: (context, index) => Builder(
                          builder: (context) => Dismissible(
                            key: Key(value.completedWorkoutList[index].name),
                            onDismissed: (direction) {
                              PerformedWorkout deletedWorkout =
                                  value.completedWorkoutList[index];
                              int deletedWorkoutIndex = index;

                              deleteCompletedWorkout(deletedWorkout.name);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${deletedWorkout.name} deleted.'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () => undoDeleteCompletedWorkout(
                                        deletedWorkout, deletedWorkoutIndex),
                                  ),
                                ),
                              );
                            },
                            child: ListTile(
                              title:
                                  Text(value.completedWorkoutList[index].name),
                              subtitle: Text(value.completedWorkoutList[index]
                                  .getFormattedDuration()),
                              trailing: IconButton(
                                icon: const Icon(Icons.arrow_forward_ios),
                                onPressed: () => goToCompletedWorkoutPage(
                                    value.completedWorkoutList[index]),
                              ),
                            ),
                          ),
                        ),
                        separatorBuilder: (context, index) => Text(
                            dateTimeToYYYYMMDD(
                                value.completedWorkoutList[index].date)),
                      ),
                    ),
                  ],
                ),
              )
            : const Text('No completed workouts.'),
      ),
    );
  }

  void deleteCompletedWorkout(String workoutName) {
    Provider.of<PerformedWorkoutData>(context, listen: false)
        .deleteCompletedWorkout(workoutName);
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
