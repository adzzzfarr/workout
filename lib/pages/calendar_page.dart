import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/pages/completed_workout_page.dart';
import 'package:workout/widgets/heat_map_calendar.dart';
import '../data/performed_workout_data.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<PerformedWorkoutData>(context, listen: false)
        .initialiseCompletedWorkoutList();
    Provider.of<PerformedWorkoutData>(context, listen: false).loadHeatMap();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<PerformedWorkoutData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(),
        body: Builder(
          builder: (context) => Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: screenHeight / 80,
                  bottom: screenHeight / 80,
                ),
                child: Text(
                  'Workout Calendar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenHeight / 30,
                  ),
                ),
              ),
              WorkoutHeatMapCalendar(
                datasets: value.heatMapDataSet,
                onBlockTapped: (dateTime) =>
                    goToCompletedExercisePage(dateTime),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void goToCompletedExercisePage(DateTime dateTime) {
    final completedWorkouts =
        Provider.of<PerformedWorkoutData>(context, listen: false)
            .completedWorkoutList;

    final intendedWorkoutIndex =
        completedWorkouts.indexWhere((element) => element.date == dateTime);

    if (intendedWorkoutIndex != -1) {
      final intendedWorkout = completedWorkouts[intendedWorkoutIndex];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CompletedWorkoutPage(completedWorkout: intendedWorkout),
        ),
      );
    }
  }
}
