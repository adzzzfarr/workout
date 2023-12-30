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
          onPressed: () => showExerciseDetails(
            exerciseName: null,
            weight: null,
            sets: null,
            reps: null,
          ),
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
            onTilePressed: (exerciseName) => showExerciseDetails(
              exerciseName: exerciseName,
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
            ),
            onDismissed: () => deleteExercise(
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

  void showExerciseDetails({
    String? exerciseName,
    double? weight,
    int? sets,
    int? reps,
  }) {
    exerciseNameController.text = exerciseName ?? '';
    weightController.text = weight?.toString() ?? '';
    setsController.text = sets?.toString() ?? '';
    repsController.text = reps?.toString() ?? '';

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
            onPressed: cancelExercise,
            child: const Text('Cancel'),
          ),
          MaterialButton(
            onPressed: () {
              if (exerciseName == null) {
                saveNewExercise();
              } else {
                saveEditedExercise(exerciseName);
              }
            },
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

  void cancelExercise() {
    Navigator.pop(context);
    exerciseNameController.clear();
    weightController.clear();
    setsController.clear();
    repsController.clear();
  }

  void saveEditedExercise(String originalExerciseName) {
    String editedExerciseName = exerciseNameController.text;
    double weight = double.parse(weightController.text);
    int sets = int.parse(setsController.text);
    int reps = int.parse(repsController.text);

    Provider.of<WorkoutData>(context, listen: false).editExercise(
      widget.workoutName,
      originalExerciseName,
      editedExerciseName,
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

  void deleteExercise(String workoutName, String exerciseName) {
    Provider.of<WorkoutData>(context, listen: false).deleteExercise(
      workoutName,
      exerciseName,
    );
  }
}
