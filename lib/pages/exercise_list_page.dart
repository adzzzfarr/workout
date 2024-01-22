import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/exercise_data.dart';
import 'package:workout/data/template_workout_data.dart';
import 'package:workout/models/exercise.dart';
import 'package:workout/models/template_workout.dart';
import 'package:workout/pages/exercise_page.dart';
import 'package:workout/pages/template_workout_page.dart';
import '../data/performed_workout_data.dart';

class ExerciseListPage extends StatefulWidget {
  final bool isAddingExerciseToTemplateWorkout;
  final TemplateWorkout? addToThisTemplateWorkout;

  const ExerciseListPage({
    this.addToThisTemplateWorkout,
    required this.isAddingExerciseToTemplateWorkout,
    super.key,
  });

  @override
  State<ExerciseListPage> createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends State<ExerciseListPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<PerformedWorkoutData>(context, listen: false)
        .initialiseCompletedWorkoutList();
    Provider.of<ExerciseData>(context, listen: false).initialiseExerciseList();
    Provider.of<ExerciseData>(context, listen: false)
        .initialiseExerciseInstances();
  }

  final exerciseNameController = TextEditingController();
  BodyPart? selectedBodyPart;
  final setsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final exerciseNameList = getAllExerciseNames();

    return Consumer<ExerciseData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Exercises'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showExerciseDetailsDialog(),
          child: const Icon(Icons.add),
        ),
        body: exerciseNameList.isNotEmpty
            ? Builder(
                builder: (context) => ListView.builder(
                  itemCount: exerciseNameList.length,
                  itemBuilder: (context, index) => MaterialButton(
                    onPressed: () => widget.isAddingExerciseToTemplateWorkout
                        ? showInputSetsDialog(
                            context,
                            widget.addToThisTemplateWorkout!,
                            value.exerciseList.firstWhere((element) =>
                                element.name == exerciseNameList[index]))
                        : goToExercisePage(exerciseNameList[index]),
                    child: Text(exerciseNameList[index]),
                  ),
                ),
              )
            : const Text('No exercises found.'),
      ),
    );
  }

  List<String> getAllExerciseNames() {
    final exerciseList =
        Provider.of<ExerciseData>(context, listen: false).exerciseList;

    final exerciseNames = exerciseList.map((e) => e.name).toList();
    return exerciseNames;
  }

  void goToExercisePage(String exerciseName) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExercisePage(exerciseName: exerciseName),
        ));
  }

  void showInputSetsDialog(BuildContext context,
      TemplateWorkout templateWorkout, Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Number of Sets"),
        content: TextField(
          controller: setsController,
          keyboardType: TextInputType.number,
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              setsController.clear();
            },
            child: const Text('Cancel'),
          ),
          MaterialButton(
            onPressed: () {
              Provider.of<TemplateWorkoutData>(context, listen: false)
                  .addExerciseToTemplateWorkout(
                templateWorkout.name,
                exercise.name,
                exercise.bodyPart,
                int.parse(setsController.text),
              );

              // TODO: This removes the back button; try and see how to make it so that the back button brings back to TemplateWorkoutListPage
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TemplateWorkoutPage(
                          workoutName: templateWorkout.name)),
                  (route) => false);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void showExerciseDetailsDialog(
      {String? exerciseName, int? sets, BodyPart? bodyPart}) {
    exerciseNameController.text = exerciseName ?? '';
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

    if (selectedBodyPart != null) {
      Provider.of<ExerciseData>(context, listen: false)
          .addExerciseToExerciseList(newExerciseName, selectedBodyPart!);

      Navigator.pop(context);
      exerciseNameController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a body part.')));
    }
  }

  void cancelEdit() {
    Navigator.pop(context);
    exerciseNameController.clear();
  }

  void saveEditedExercise(String exerciseName) {
    String editedExerciseName = exerciseNameController.text;

    Provider.of<ExerciseData>(context, listen: false)
        .editExerciseInExerciseList(
            exerciseName, editedExerciseName, selectedBodyPart!);

    Navigator.pop(context);
    exerciseNameController.clear();
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
    }
  }
}
