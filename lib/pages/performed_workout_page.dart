import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/performed_workout_data.dart';
import 'package:workout/models/performed_workout.dart';
import 'package:workout/pages/home_page.dart';
import 'package:workout/widgets/exercise_tile.dart';

class PerformedWorkoutPage extends StatefulWidget {
  final PerformedWorkout performedWorkout;

  const PerformedWorkoutPage({required this.performedWorkout, super.key});

  @override
  State<PerformedWorkoutPage> createState() => _PerformedWorkoutPageState();
}

class _PerformedWorkoutPageState extends State<PerformedWorkoutPage> {
  final weightController = TextEditingController();
  final setsController = TextEditingController();
  final repsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<PerformedWorkoutData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: Text(widget.performedWorkout.name),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => finishWorkout(),
          child: const Text('Finish'),
        ),
        body: Builder(
          builder: (context) => ListView.builder(
            itemCount: value.getNumberOfExercises(widget.performedWorkout.date),
            itemBuilder: (context, index) => Builder(
              builder: (context) => ExerciseTile(
                workoutType: 'performed',
                exerciseName: value
                    .getIntendedPerformedWorkout(widget.performedWorkout.date)!
                    .exercises[index]
                    .name,
                setsList: value
                    .getIntendedPerformedWorkout(widget.performedWorkout.date)!
                    .exercises[index]
                    .getSetsList(),
                isCompleted: value
                    .getIntendedPerformedWorkout(widget.performedWorkout.date)!
                    .exercises[index]
                    .isCompleted,
                onEditSet: (exerciseName, setNumber) => showSetDetailsDialog(
                  exerciseName,
                  setNumber,
                  {
                    setNumber: value
                        .getIntendedPerformedWorkout(
                            widget.performedWorkout.date)!
                        .exercises[index]
                        .setWeightReps[setNumber]
                  },
                ),
                onCheckboxChanged: (value) {
                  setState(() {
                    widget.performedWorkout.exercises[index].isCompleted =
                        !widget.performedWorkout.exercises[index].isCompleted;
                  });
                },
                onTilePressed: null,
                onDismissed:
                    null, // Cannot delete exercises in a performed workout
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showSetDetailsDialog(
    String exerciseName,
    int setNumber,
    Map<int, dynamic> setDetails,
  ) {
    double? weight = setDetails[setNumber][0];
    int? reps = setDetails[setNumber][1];

    weightController.text = weight?.toString() ?? '';
    repsController.text = reps?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Set $setNumber Details',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              decoration: const InputDecoration(hintText: "Weight"),
            ),
            TextField(
              controller: repsController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: "Reps"),
            ),
          ],
        ),
        actions: [
          MaterialButton(
            onPressed: () => cancelEdit(),
            child: const Text('Cancel'),
          ),
          MaterialButton(
            onPressed: () {
              saveEditedSet(exerciseName, setNumber);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void cancelEdit() {
    Navigator.pop(context);
    weightController.clear();
    setsController.clear();
    repsController.clear();
  }

  void saveEditedSet(String exerciseName, int setNumber) {
    double weight = double.parse(weightController.text);
    int reps = int.parse(repsController.text);

    Provider.of<PerformedWorkoutData>(context, listen: false).editSet(
      widget.performedWorkout.date,
      exerciseName,
      setNumber,
      weight,
      reps,
    );

    Navigator.pop(context);
    weightController.clear();
    setsController.clear();
    repsController.clear();
  }

  void finishWorkout() {
    Provider.of<PerformedWorkoutData>(context, listen: false)
        .finishWorkout(widget.performedWorkout.date);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
      (route) => false,
    );
  }
}
