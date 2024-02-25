import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/date_time.dart';
import 'package:workout/data/performed_workout_data.dart';
import 'package:workout/data/template_workout_data.dart';
import 'package:workout/models/exercise.dart';
import 'package:workout/models/performed_workout.dart';
import 'package:workout/models/template_workout.dart';
import 'package:workout/pages/exercise_list_page.dart';
import 'package:workout/pages/exercise_page.dart';
import 'package:workout/pages/performed_workout_page.dart';
import 'package:workout/widgets/template_workout_exercise_tile.dart';

final setNumberFormKey = GlobalKey<FormState>();

class TemplateWorkoutPage extends StatefulWidget {
  final String workoutName;

  const TemplateWorkoutPage({required this.workoutName, super.key});

  @override
  State<TemplateWorkoutPage> createState() => _TemplateWorkoutPageState();
}

class _TemplateWorkoutPageState extends State<TemplateWorkoutPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<TemplateWorkoutData>(context, listen: false)
        .initialiseTemplateWorkoutList();
  }

  final setsController = TextEditingController();
  BodyPart? selectedBodyPart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<TemplateWorkoutData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: Text(widget.workoutName),
          actions: [
            MaterialButton(
              onPressed: () => goToPerformedWorkoutPage(
                value.templateWorkoutList.firstWhere(
                    (element) => element.name == widget.workoutName),
              ),
              child: const Text('Start'),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => goToSelectExerciseScreen(),
          child: const Icon(Icons.add),
        ),
        body: Builder(
          builder: (context) => ListView.builder(
            itemCount: value.getNumberOfExercises(widget.workoutName),
            itemBuilder: (context, index) => Builder(
              builder: (context) => TemplateWorkoutExerciseTile(
                exercise: value
                    .getIntendedTemplateWorkout(widget.workoutName)
                    .exercises[index],
                tileKey: Key(value
                    .getIntendedTemplateWorkout(widget.workoutName)
                    .exercises[index]
                    .name),
                onTilePressed: () => goToExercisePage(value
                    .getIntendedTemplateWorkout(widget.workoutName)
                    .exercises[index]
                    .name),
                onEditPressed: (exerciseName) => showExerciseDetailsDialog(
                  exerciseName: exerciseName,
                  sets: value
                      .getIntendedTemplateWorkout(widget.workoutName)
                      .exercises[index]
                      .setWeightReps!
                      .length,
                ),
                onDismissed: (direction) {
                  Exercise deletedExercise = value
                      .getIntendedTemplateWorkout(widget.workoutName)
                      .exercises[index];
                  int deletedExerciseIndex = index;

                  deleteExercise(widget.workoutName, deletedExercise.name);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${deletedExercise.name} deleted.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenHeight / 50,
                        ),
                      ),
                      backgroundColor: colorScheme.error,
                      elevation: 10,
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: Colors.white,
                        onPressed: () => undoDeleteExercise(
                          widget.workoutName,
                          deletedExercise,
                          deletedExerciseIndex,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showExerciseDetailsDialog({String? exerciseName, int? sets}) {
    setsController.text = sets?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.grey[600]!,
            width: 0.5,
          ),
        ),
        elevation: 10,
        title: Text(
          exerciseName!,
          style: const TextStyle(color: Colors.white),
        ),
        content: Form(
          key: setNumberFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: setsController,
                validator: (value) => setNumberValidator(value),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                decoration: const InputDecoration(hintText: "Sets"),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: cancelEdit,
            child: const Text('Cancel'),
          ),
          MaterialButton(
            onPressed: () {
              setNumberFormKey.currentState!.validate();

              if (setNumberFormKey.currentState!.validate()) {
                saveEditedExercise(exerciseName, sets!);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void cancelEdit() {
    Navigator.pop(context);
    setsController.clear();
  }

  void saveEditedExercise(String exerciseName, int originalNoOfSets) {
    int editedNoOfSets = int.parse(setsController.text);

    Provider.of<TemplateWorkoutData>(context, listen: false)
        .editExerciseInTemplateWorkout(
      widget.workoutName,
      exerciseName,
      originalNoOfSets,
      editedNoOfSets,
    );

    Navigator.pop(context);
    setsController.clear();
  }

  void deleteExercise(String workoutName, String exerciseName) {
    Provider.of<TemplateWorkoutData>(context, listen: false)
        .deleteExerciseFromTemplateWorkout(
      workoutName,
      exerciseName,
    );
  }

  void undoDeleteExercise(
      String workoutName, Exercise deletedExercise, int deletedExerciseIndex) {
    Provider.of<TemplateWorkoutData>(context, listen: false)
        .addExerciseToTemplateWorkoutAtIndex(
            workoutName, deletedExercise, deletedExerciseIndex);
  }

  void goToPerformedWorkoutPage(TemplateWorkout templateWorkout) {
    PerformedWorkout performedWorkout = PerformedWorkout(
      name: templateWorkout.name,
      exercises: List.from(templateWorkout.exercises),
      date: createDateTimeObj(getTodayYYYYMMDD()),
      durationInSeconds: 0, // Change this
    );

    Provider.of<PerformedWorkoutData>(context, listen: false)
        .startPerformingWorkout(performedWorkout);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PerformedWorkoutPage(performedWorkout: performedWorkout),
      ),
    );
  }

  void goToSelectExerciseScreen() {
    final templateWorkoutList =
        Provider.of<TemplateWorkoutData>(context, listen: false)
            .templateWorkoutList;
    final currentTemplateWorkout = templateWorkoutList
        .firstWhere((element) => element.name == widget.workoutName);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseListPage(
            isAddingExerciseToTemplateWorkout: true,
            addToThisTemplateWorkout: currentTemplateWorkout),
      ),
    );
  }

  void goToExercisePage(String exerciseName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExercisePage(exerciseName: exerciseName),
      ),
    );
  }

  String? setNumberValidator(String? inputSetNumber) {
    if (inputSetNumber == null ||
        inputSetNumber.isEmpty ||
        int.parse(inputSetNumber) < 1) {
      return 'At least 1 set must be performed';
    }
    return null;
  }
}
