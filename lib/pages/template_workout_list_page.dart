import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/template_workout_data.dart';
import 'package:workout/pages/template_workout_page.dart';
import 'package:workout/widgets/template_workout_card.dart';

import '../models/template_workout.dart';

class TemplateWorkoutListPage extends StatefulWidget {
  const TemplateWorkoutListPage({super.key});

  @override
  State<TemplateWorkoutListPage> createState() =>
      _TemplateWorkoutListPageState();
}

class _TemplateWorkoutListPageState extends State<TemplateWorkoutListPage> {
  @override
  void initState() {
    super.initState();

    Provider.of<TemplateWorkoutData>(context, listen: false)
        .initialiseTemplateWorkoutList();
  }

  final newTemplateWorkoutNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateWorkoutData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Workout Tracker'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => createNewTemplateWorkout(context),
          child: const Icon(Icons.add),
        ),
        body: Builder(
          builder: (context) => ListView(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: value.templateWorkoutList.length,
                itemBuilder: (context, index) => Builder(
                  builder: (context) => TemplateWorkoutCard(
                    name: value.templateWorkoutList[index].name,
                    noOfExercises:
                        value.templateWorkoutList[index].exercises.length,
                    cardKey: Key(value.templateWorkoutList[index]
                        .name), //TODO: Make sure user cannot add a workout that has the same name
                    onPressed: () => goToTemplateWorkoutPage(
                        value.templateWorkoutList[index].name),
                    onDismissed: (direction) {
                      TemplateWorkout deletedWorkout =
                          value.templateWorkoutList[index];
                      int deletedWorkoutIndex = index;

                      deleteTemplateWorkout(deletedWorkout.name);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${deletedWorkout.name} deleted.'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () => undoDeleteTemplateWorkout(
                                deletedWorkout, deletedWorkoutIndex),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void createNewTemplateWorkout(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
          "New Workout",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        content: SizedBox(
          height: screenHeight / 15,
          width: screenWidth - 50,
          child: TextField(
            controller: newTemplateWorkoutNameController,
            decoration: const InputDecoration(hintText: 'Workout Name'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: cancelNewWorkout,
            child: const Text('Cancel'),
          ),
          MaterialButton(
            onPressed: saveNewTemplateWorkout,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void saveNewTemplateWorkout() {
    String newWorkoutName = newTemplateWorkoutNameController.text;

    Provider.of<TemplateWorkoutData>(context, listen: false)
        .addWorkout(newWorkoutName);

    Navigator.pop(context);
    newTemplateWorkoutNameController.clear();
  }

  void cancelNewWorkout() {
    Navigator.pop(context);
    newTemplateWorkoutNameController.clear();
  }

  void deleteTemplateWorkout(String workoutName) {
    Provider.of<TemplateWorkoutData>(context, listen: false)
        .deleteWorkout(workoutName);
  }

  void undoDeleteTemplateWorkout(
      TemplateWorkout deletedWorkout, int deletedWorkoutIndex) {
    Provider.of<TemplateWorkoutData>(context, listen: false)
        .addWorkoutAtIndex(deletedWorkout, deletedWorkoutIndex);
  }

  void goToTemplateWorkoutPage(String workoutName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateWorkoutPage(workoutName: workoutName),
      ),
    );
  }
}
