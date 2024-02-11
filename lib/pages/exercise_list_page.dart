import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/exercise_data.dart';
import 'package:workout/data/template_workout_data.dart';
import 'package:workout/models/exercise.dart';
import 'package:workout/models/template_workout.dart';
import 'package:workout/pages/exercise_page.dart';
import 'package:workout/widgets/exercise_list_page_tile.dart';
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
    List<String> exerciseNameList = getAllExerciseNames();

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
                    itemBuilder: (context, index) => ExerciseListPageTile(
                          exercise: value.exerciseList[index],
                          tileKey: Key(value.exerciseList[index].name),
                          onTilePressed: () => widget
                                  .isAddingExerciseToTemplateWorkout
                              ? showInputSetsDialog(
                                  context,
                                  widget.addToThisTemplateWorkout!,
                                  value.exerciseList.firstWhere((element) =>
                                      element.name == exerciseNameList[index]))
                              : goToExercisePage(exerciseNameList[index]),
                          onDismissed: (direction) {
                            Exercise deletedExercise =
                                value.exerciseList[index];
                            int deletedExerciseIndex = index;

                            deleteExercise(deletedExercise.name);
                            setState(() {
                              exerciseNameList = getAllExerciseNames();
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('${deletedExercise.name} deleted'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    undoDeleteExercise(
                                        deletedExercise, deletedExerciseIndex);
                                    setState(() {
                                      exerciseNameList = getAllExerciseNames();
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        )),
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
    print('Pressing tile');
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.grey[600]!,
            width: 0.5,
          ),
        ),
        elevation: 10,
        title: const Text(
          "Number of Sets",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: setsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Sets"),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              setsController.clear();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
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

              Navigator.of(context)
                ..pop()
                ..pop();
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void showExerciseDetailsDialog({String? exerciseName, BodyPart? bodyPart}) {
    exerciseNameController.text = exerciseName ?? '';
    selectedBodyPart = bodyPart;

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
        title: const Text(
          "New Exercise",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: exerciseNameController,
              decoration: const InputDecoration(hintText: "Exercise Name"),
              style: const TextStyle(color: Colors.white),
            ),
            DropdownButtonFormField<BodyPart>(
              value: selectedBodyPart,
              items: BodyPart.values
                  .map(
                    (element) => DropdownMenuItem<BodyPart>(
                      value: element,
                      child: Text(
                        formatBodyPart(element),
                        style: const TextStyle(color: Colors.white),
                      ),
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
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          MaterialButton(
            onPressed: () {
              saveNewExercise();
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void saveNewExercise() {
    String newExerciseName = exerciseNameController.text;

    if (exerciseNameController.text.isNotEmpty && selectedBodyPart != null) {
      Provider.of<ExerciseData>(context, listen: false)
          .addExerciseToExerciseList(newExerciseName, selectedBodyPart!);

      Navigator.pop(context);
      exerciseNameController.clear();

      setState(() {});
    } else if (exerciseNameController.text.isNotEmpty &&
        selectedBodyPart == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a body part.')));
    } else if (exerciseNameController.text.isEmpty &&
        selectedBodyPart != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please input an exercise name.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Please input an exercise name and select a body part.')));
    }
  }

  void cancelEdit() {
    Navigator.pop(context);
    exerciseNameController.clear();
  }

  void deleteExercise(String exerciseName) {
    Provider.of<ExerciseData>(context, listen: false)
        .deleteExerciseFromExerciseList(exerciseName);
  }

  void undoDeleteExercise(Exercise deletedExercise, int deletedExerciseIndex) {
    Provider.of<ExerciseData>(context, listen: false)
        .addExerciseToExerciseListAtIndex(
            deletedExercise, deletedExerciseIndex);
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
