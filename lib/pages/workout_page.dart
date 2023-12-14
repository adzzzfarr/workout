import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/workout_data.dart';
import 'package:workout/widgets/exercise_tile.dart';

class WorkoutPage extends StatefulWidget {
  final String workoutName;

  const WorkoutPage({required this.workoutName, super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final exerciseNameController = TextEditingController();
  final weightController = TextEditingController();
  final setsController = TextEditingController();
  final repsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: Text(widget.workoutName),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => createNewExercise(),
          child: const Icon(Icons.add),
        ),
        body: ListView.builder(
          itemCount: value.getNumberOfExercises(widget.workoutName),
          itemBuilder: (context, index) => ExerciseTile(
            exerciseName: value
                .getIntendedWorkout(widget.workoutName)
                .exercises[index]
                .name,
            weight: value
                .getIntendedWorkout(widget.workoutName)
                .exercises[index]
                .weight,
            sets: value
                .getIntendedWorkout(widget.workoutName)
                .exercises[index]
                .sets,
            reps: value
                .getIntendedWorkout(widget.workoutName)
                .exercises[index]
                .reps,
            isCompleted: value
                .getIntendedWorkout(widget.workoutName)
                .exercises[index]
                .isCompleted,
            onCheckboxChanged: (val) => onCheckBoxChanged(
              widget.workoutName,
              value
                  .getIntendedWorkout(widget.workoutName)
                  .exercises[index]
                  .name,
            ),
          ),
        ),
      ),
    );
  }

  void onCheckBoxChanged(String workoutName, String exerciseName) {
    Provider.of<WorkoutData>(context, listen: false)
        .checkOffExercise(workoutName, exerciseName);
  }

  void createNewExercise() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Exercise"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: exerciseNameController,
              decoration: const InputDecoration(hintText: "Exercise Name"),
            ),
            TextField(
              controller: weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: "Weight"),
            ),
            TextField(
              controller: setsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Sets"),
            ),
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Reps"),
            ),
          ],
        ),
        actions: [
          MaterialButton(
            onPressed: cancelNewExercise,
            child: const Text('Cancel'),
          ),
          MaterialButton(
            onPressed: saveNewExercise,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void saveNewExercise() {
    String newExerciseName = exerciseNameController.text;
    double weight = double.parse(weightController.text);
    int sets = int.parse(setsController.text);
    int reps = int.parse(repsController.text);

    Provider.of<WorkoutData>(context, listen: false).addExercise(
      widget.workoutName,
      newExerciseName,
      weight,
      sets,
      reps,
    );

    Navigator.pop(context);
    exerciseNameController.clear();
    weightController.clear();
    setsController.clear();
    repsController.clear();
  }

  void cancelNewExercise() {
    Navigator.pop(context);
    exerciseNameController.clear();
    weightController.clear();
    setsController.clear();
    repsController.clear();
  }
}
