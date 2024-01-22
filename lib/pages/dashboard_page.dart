import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/exercise_data.dart';
import 'package:workout/data/performed_workout_data.dart';
import 'package:workout/data/template_workout_data.dart';
import 'package:workout/models/exercise.dart';
import 'package:workout/pages/template_workout_list_page.dart';
import 'package:workout/widgets/heat_map.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<PerformedWorkoutData>(context, listen: false)
        .initialiseCompletedWorkoutList(); // For HeatMap
    Provider.of<ExerciseData>(context, listen: false)
        .initialiseExerciseInstances(); // For Pie Chart
    Provider.of<PerformedWorkoutData>(context, listen: false).loadHeatMap();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateWorkoutData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Workout Tracker'),
        ),
        body: Builder(
          builder: (context) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    MaterialButton(
                        child: const Text('Start A Workout'),
                        onPressed: () => goToTemplateWorkoutsListPage()),
                    WorkoutHeatMap(
                      datasets: Provider.of<PerformedWorkoutData>(context)
                          .heatMapDataSet,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void goToTemplateWorkoutsListPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TemplateWorkoutListPage(),
      ),
    );
  }
}
