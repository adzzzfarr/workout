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
          onPressed: () => showExerciseDetailsDialog(
            exerciseName: null,
            sets: null,
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
            setsList: value
                .getIntendedWorkout(widget.workoutName)
                .exercises[index]
                .getSetsList(),
            isCompleted: value
                .getIntendedWorkout(widget.workoutName)
                .exercises[index]
                .isCompleted,
            onEditSet: (exerciseName, setNumber) => showSetDetailsDialog(
              exerciseName,
              setNumber,
              {
                setNumber: value
                    .getIntendedWorkout(widget.workoutName)
                    .exercises[index]
                    .setWeightReps[setNumber]
              },
            ),
            onCheckboxChanged: (val) => onCheckBoxChanged(
              widget.workoutName,
              value
                  .getIntendedWorkout(widget.workoutName)
                  .exercises[index]
                  .name,
            ),
            onTileLongPressed: (exerciseName) => showExerciseDetailsDialog(
              exerciseName: exerciseName,
              sets: value
                  .getIntendedWorkout(widget.workoutName)
                  .exercises[index]
                  .setWeightReps
                  .length,
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

  void showExerciseDetailsDialog({
    String? exerciseName,
    int? sets,
  }) {
    exerciseNameController.text = exerciseName ?? '';
    setsController.text = sets?.toString() ?? '';

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
              controller: setsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Sets"),
            ),
          ],
        ),
        actions: [
          MaterialButton(
            onPressed: cancelEdit,
            child: const Text('Cancel'),
          ),
          MaterialButton(
            onPressed: () {
              if (exerciseName == null) {
                saveNewExercise();
              } else {
                saveEditedExercise(exerciseName, sets!);
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
    int sets = int.parse(setsController.text);

    Provider.of<WorkoutData>(context, listen: false).addNewExercise(
      widget.workoutName,
      newExerciseName,
      sets,
    );

    Navigator.pop(context);
    exerciseNameController.clear();
    weightController.clear();
    setsController.clear();
    repsController.clear();
  }

  void cancelEdit() {
    Navigator.pop(context);
    exerciseNameController.clear();
    weightController.clear();
    setsController.clear();
    repsController.clear();
  }

  void saveEditedExercise(String originalExerciseName, int originalNoOfSets) {
    String editedExerciseName = exerciseNameController.text;
    int editedNoOfSets = int.parse(setsController.text);

    Provider.of<WorkoutData>(context, listen: false).editExercise(
      widget.workoutName,
      originalExerciseName,
      editedExerciseName,
      originalNoOfSets,
      editedNoOfSets,
    );

    Navigator.pop(context);
    exerciseNameController.clear();
    weightController.clear();
    setsController.clear();
    repsController.clear();
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

  void saveEditedSet(String exerciseName, int setNumber) {
    double weight = double.parse(weightController.text);
    int reps = int.parse(repsController.text);

    Provider.of<WorkoutData>(context, listen: false).editSet(
      widget.workoutName,
      exerciseName,
      setNumber,
      weight,
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
