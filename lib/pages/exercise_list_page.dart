import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final exerciseNameList = getAllUniqueExerciseNames();

    return Consumer<PerformedWorkoutData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Exercises'),
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
                            value.completedWorkoutList
                                .firstWhere((completedWorkout) {
                                  for (var exercise
                                      in completedWorkout.exercises) {
                                    if (exercise.name ==
                                        exerciseNameList[index]) {
                                      return true;
                                    }
                                  }
                                  return false;
                                })
                                .exercises
                                .firstWhere((exercise) =>
                                    exercise.name == exerciseNameList[index]))
                        : goToExercisePage(exerciseNameList[index]),
                    child: Text(exerciseNameList[index]),
                  ),
                ),
              )
            : const Text('No exercises found.'),
      ),
    );
  }

  List<String> getAllUniqueExerciseNames() {
    final completedWorkoutList =
        Provider.of<PerformedWorkoutData>(context).getCompletedWorkoutList();

    List<String> exerciseNameList = [];
    for (var workout in completedWorkoutList) {
      for (var exercise in workout.exercises) {
        if (!exerciseNameList.contains(exercise.name)) {
          exerciseNameList.add(exercise.name);
        }
      }
    }

    exerciseNameList.sort();
    return exerciseNameList;
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
    final setsController = TextEditingController();

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
                  .addNewExercise(
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
}
