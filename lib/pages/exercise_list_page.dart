import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/exercise_data.dart';
import 'package:workout/data/template_workout_data.dart';
import 'package:workout/models/exercise.dart';
import 'package:workout/models/template_workout.dart';
import 'package:workout/pages/exercise_page.dart';
import 'package:workout/widgets/exercise_list_page_tile.dart';
import '../data/performed_workout_data.dart';

final setsFormKey = GlobalKey<FormState>();
final exerciseDetailsFormKey = GlobalKey<FormState>();

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final screenHeight = MediaQuery.of(context).size.height;

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
                          onTilePressed: () {
                            if (widget.isAddingExerciseToTemplateWorkout) {
                              final exerciseNamesInWorkout = widget
                                  .addToThisTemplateWorkout!.exercises
                                  .map((e) => e.name)
                                  .toList();

                              if (!exerciseNamesInWorkout
                                  .contains(exerciseNameList[index])) {
                                showInputSetsDialog(
                                    context,
                                    widget.addToThisTemplateWorkout!,
                                    value.exerciseList.firstWhere((element) =>
                                        element.name ==
                                        exerciseNameList[index]));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Exercise already in workout.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenHeight / 50,
                                      ),
                                    ),
                                    backgroundColor: colorScheme.primary,
                                    elevation: 10,
                                  ),
                                );
                              }
                            } else {
                              goToExercisePage(exerciseNameList[index]);
                            }
                          },
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
                                content: Text(
                                  '${deletedExercise.name} deleted',
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
        content: Form(
          key: setsFormKey,
          child: TextFormField(
            controller: setsController,
            validator: (value) => setsValidator(value),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Sets"),
            style: const TextStyle(color: Colors.white),
          ),
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
              setsFormKey.currentState!.validate();

              if (setsFormKey.currentState!.validate()) {
                Provider.of<TemplateWorkoutData>(context, listen: false)
                    .addExerciseToTemplateWorkout(
                  templateWorkout.name,
                  exercise.name,
                  exercise.bodyPart,
                  int.parse(setsController.text),
                );

                setsController.clear();

                Navigator.of(context)
                  ..pop()
                  ..pop();
              }
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
        content: Form(
          key: exerciseDetailsFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: exerciseNameController,
                decoration: const InputDecoration(hintText: "Exercise Name"),
                style: const TextStyle(color: Colors.white),
                validator: (value) => exerciseNameValidator(value),
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
                validator: (value) => bodyPartValidator(value),
                onChanged: (value) => setState(() {
                  selectedBodyPart = value;
                }),
                onSaved: (newValue) => setState(() {
                  selectedBodyPart = newValue;
                }),
              )
            ],
          ),
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
              exerciseDetailsFormKey.currentState!.validate();

              if (exerciseDetailsFormKey.currentState!.validate()) {
                saveNewExercise();
              }
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

    Provider.of<ExerciseData>(context, listen: false)
        .addExerciseToExerciseList(newExerciseName, selectedBodyPart!);

    Navigator.pop(context);

    setState(() {});
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

  String? setsValidator(String? inputSets) {
    if (inputSets == null || inputSets.isEmpty || int.parse(inputSets) < 1) {
      return 'At least 1 set must be performed.';
    }
    return null;
  }

  String? exerciseNameValidator(String? inputName) {
    final exerciseNames = Provider.of<ExerciseData>(context)
        .exerciseList
        .map((e) => e.name)
        .toList();

    if (inputName == null || inputName.isEmpty) {
      return 'Please enter an exercise name.';
    } else if (exerciseNames.contains(inputName)) {
      return 'Exercise already exists.';
    }
    return null;
  }

  String? bodyPartValidator(BodyPart? inputBodyPart) {
    if (inputBodyPart == null) {
      return 'Please select a body part.';
    }
    return null;
  }
}
