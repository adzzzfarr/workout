import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/date_time.dart';
import 'package:workout/data/performed_workout_data.dart';
import 'package:workout/data/template_workout_data.dart';
import 'package:workout/models/exercise.dart';
import 'package:workout/models/performed_workout.dart';
import 'package:workout/models/template_workout.dart';
import 'package:workout/pages/exercise_list_page.dart';
import 'package:workout/pages/performed_workout_page.dart';
import 'package:workout/widgets/exercise_tile.dart';

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

  final exerciseNameController = TextEditingController();
  final setsController = TextEditingController();
  BodyPart? selectedBodyPart;

  @override
  Widget build(BuildContext context) {
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
              builder: (context) => ExerciseTile(
                workoutType: 'template',
                exercise: value
                    .getIntendedTemplateWorkout(widget.workoutName)
                    .exercises[index],
                onCheckboxChanged: null,
                onEditSet: null,
                onTilePressed: (exerciseName) => showExerciseDetailsDialog(
                    exerciseName: exerciseName,
                    sets: value
                        .getIntendedTemplateWorkout(widget.workoutName)
                        .exercises[index]
                        .setWeightReps
                        .length,
                    bodyPart: value
                        .getIntendedTemplateWorkout(widget.workoutName)
                        .exercises[index]
                        .bodyPart),
                onDismissed: () {
                  Exercise deletedExercise = value
                      .getIntendedTemplateWorkout(widget.workoutName)
                      .exercises[index];
                  int deletedExerciseIndex = index;

                  deleteExercise(widget.workoutName, deletedExercise.name);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${deletedExercise.name} deleted.'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () => undoDeleteExericse(
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

  void showExerciseDetailsDialog(
      {String? exerciseName, int? sets, BodyPart? bodyPart}) {
    exerciseNameController.text = exerciseName ?? '';
    setsController.text = sets?.toString() ?? '';
    selectedBodyPart = bodyPart;

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
            DropdownButtonFormField<BodyPart>(
              value: selectedBodyPart,
              items: BodyPart.values
                  .map(
                    (element) => DropdownMenuItem<BodyPart>(
                      value: element,
                      child: Text(formatBodyPart(element)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() {
                selectedBodyPart = value;
              }),
              onSaved: (newValue) => setState(() {
                selectedBodyPart = newValue;
              }),
            )
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

    if (selectedBodyPart != null) {
      Provider.of<TemplateWorkoutData>(context, listen: false).addNewExercise(
        widget.workoutName,
        newExerciseName,
        selectedBodyPart!,
        sets,
      );

      Navigator.pop(context);
      exerciseNameController.clear();
      setsController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a body part.')));
    }
  }

  void cancelEdit() {
    Navigator.pop(context);
    exerciseNameController.clear();
    setsController.clear();
  }

  void saveEditedExercise(String originalExerciseName, int originalNoOfSets) {
    String editedExerciseName = exerciseNameController.text;
    int editedNoOfSets = int.parse(setsController.text);

    Provider.of<TemplateWorkoutData>(context, listen: false).editExercise(
      widget.workoutName,
      originalExerciseName,
      editedExerciseName,
      originalNoOfSets,
      editedNoOfSets,
      selectedBodyPart!,
    );

    Navigator.pop(context);
    exerciseNameController.clear();
    setsController.clear();
  }

  void deleteExercise(String workoutName, String exerciseName) {
    Provider.of<TemplateWorkoutData>(context, listen: false).deleteExercise(
      workoutName,
      exerciseName,
    );
  }

  void undoDeleteExericse(String workoutName, Exercise deletedExerciseName,
      int deletedExerciseIndex) {
    Provider.of<TemplateWorkoutData>(context, listen: false).addExerciseAtIndex(
        workoutName, deletedExerciseName, deletedExerciseIndex);
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

  String formatBodyPart(BodyPart bodyPart) {
    switch (bodyPart) {
      case BodyPart.arms:
        return 'Arms';
      case BodyPart.shoulders:
        return 'Shoulders';
      case BodyPart.chest:
        return 'Chest';
      case BodyPart.back:
        return 'Back';
      case BodyPart.legs:
        return 'Legs';
      case BodyPart.core:
        return 'Core';
      case BodyPart.fullBody:
        return 'Full Body';
      case BodyPart.cardio:
        return 'Cardio';
    }
  }
}
