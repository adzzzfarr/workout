import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/exercise_data.dart';
import 'package:workout/data/performed_workout_data.dart';
import 'package:workout/data/template_workout_data.dart';
import 'package:workout/widgets/body_parts_chart.dart';
import 'package:workout/pages/template_workout_list_page.dart';
import 'package:workout/widgets/common_button.dart';
import 'package:workout/widgets/completed_workouts_chart.dart';
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
    print(Provider.of<PerformedWorkoutData>(context, listen: false)
        .completedWorkoutDates);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<TemplateWorkoutData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
        ),
        body: Builder(
          builder: (context) => ListView(
            children: [
              Column(
                children: [
                  SizedBox(height: screenHeight / 60),
                  CommonButton(
                    height: screenHeight / 15,
                    width: screenWidth - 30,
                    text: 'Start Workout',
                    onPressed: () => goToTemplateWorkoutsListPage(),
                  ),
                  SizedBox(height: screenHeight / 60),
                  SizedBox(
                      height: screenHeight / 2.5,
                      width: screenWidth - 30,
                      child: const CompletedWorkoutsChart()),
                  SizedBox(height: screenHeight / 70),
                  SizedBox(
                    height: screenHeight / 2.7,
                    width: screenWidth - 30,
                    child: const BodyPartsChart(),
                  ),
                  WorkoutHeatMap(
                    datasets: Provider.of<PerformedWorkoutData>(context)
                        .heatMapDataSet,
                  ),
                ],
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
