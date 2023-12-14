import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/workout_data.dart';
import 'package:workout/pages/workout_page.dart';
import 'package:workout/widgets/heat_map.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    Provider.of<WorkoutData>(context, listen: false).initialiseWorkoutList();
  }

  final newWorkoutNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(
      builder: (context, value, child) => Scaffold(
          appBar: AppBar(
            title: const Text('Workout Tracker'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: createNewWorkout,
            child: const Icon(Icons.add),
          ),
          body: ListView(
            children: [
              WorkoutHeatMap(
                datasets: value.heatMapDataSet,
                startDateYYYYMMDD: value.getStartDate(),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: value.getWorkoutList().length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(value.getWorkoutList()[index].name),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () =>
                        goToWorkoutPage(value.getWorkoutList()[index].name),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  void createNewWorkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Workout"),
        content: TextField(
          controller: newWorkoutNameController,
          decoration: const InputDecoration(hintText: 'Workout Name'),
        ),
        actions: [
          MaterialButton(
            onPressed: cancelNewWorkout,
            child: const Text('Cancel'),
          ),
          MaterialButton(
            onPressed: saveNewWorkout,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void saveNewWorkout() {
    String newWorkoutName = newWorkoutNameController.text;

    Provider.of<WorkoutData>(context, listen: false).addWorkout(newWorkoutName);

    Navigator.pop(context);
    newWorkoutNameController.clear();
  }

  void cancelNewWorkout() {
    Navigator.pop(context);
    newWorkoutNameController.clear();
  }

  void goToWorkoutPage(String workoutName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutPage(workoutName: workoutName),
      ),
    );
  }
}
