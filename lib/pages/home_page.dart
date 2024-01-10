import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/date_time.dart';
import 'package:workout/data/performed_workout_data.dart';
import 'package:workout/data/template_workout_data.dart';
import 'package:workout/pages/template_workout_page.dart';
import 'package:workout/pages/workout_history_page.dart';
import 'package:workout/widgets/heat_map.dart';

import '../models/template_workout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    Provider.of<TemplateWorkoutData>(context, listen: false)
        .initialiseTemplateWorkoutList();
    Provider.of<PerformedWorkoutData>(context, listen: false)
        .initialiseCompletedWorkoutList();
    Provider.of<PerformedWorkoutData>(context, listen: false).loadHeatMap();
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
          onPressed: createNewTemplateWorkout,
          child: const Icon(Icons.add),
        ),
        body: Builder(
          builder: (context) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    WorkoutHeatMap(
                      datasets: Provider.of<PerformedWorkoutData>(context)
                          .heatMapDataSet,
                    ),
                    MaterialButton(
                      onPressed: () => goToWorkoutHistoryPage(),
                      child: const Text('View Workout History'),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: value.getTemplateWorkoutList().length,
                itemBuilder: (context, index) => Builder(
                  builder: (context) => Dismissible(
                    key: Key(value.templateWorkoutList[index].name),
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
                    child: ListTile(
                      title: Text(value.getTemplateWorkoutList()[index].name),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: () => goToTemplateWorkoutPage(
                            value.getTemplateWorkoutList()[index].name),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void createNewTemplateWorkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Workout"),
        content: TextField(
          controller: newTemplateWorkoutNameController,
          decoration: const InputDecoration(hintText: 'Workout Name'),
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

  void goToWorkoutHistoryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WorkoutHistoryPage(),
      ),
    );
  }
}
