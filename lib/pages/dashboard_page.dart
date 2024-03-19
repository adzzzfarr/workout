import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/exercise_data.dart';
import 'package:workout/data/performed_workout_data.dart';
import 'package:workout/data/template_workout_data.dart';
import 'package:workout/firebase/firebase_auth_service.dart';
import 'package:workout/pages/calendar_page.dart';
import 'package:workout/pages/login_page.dart';
import 'package:workout/widgets/body_parts_chart.dart';
import 'package:workout/pages/template_workout_list_page.dart';
import 'package:workout/widgets/common_button.dart';
import 'package:workout/widgets/completed_workouts_chart.dart';
import 'package:workout/widgets/heat_map_calendar.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<TemplateWorkoutData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
                onPressed: () => showConfirmSignOutDialog(),
                icon: const Icon(Icons.logout))
          ],
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
                    child: CompletedWorkoutsChart(
                      onTapped: () => goToCalendarPage(),
                    ),
                  ),
                  SizedBox(height: screenHeight / 70),
                  SizedBox(
                    height: screenHeight / 2.7,
                    width: screenWidth - 30,
                    child: const BodyPartsChart(),
                  ),
                  SizedBox(height: screenHeight / 70),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showConfirmSignOutDialog() {
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
          "Sign Out?",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Don't pop
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => signOut(), // Pop
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void signOut() {
    FirebaseAuthService().signOut();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LogInPage()),
        (route) => false);
  }

  void goToTemplateWorkoutsListPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TemplateWorkoutListPage(),
      ),
    );
  }

  void goToCalendarPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalendarPage(),
      ),
    );
  }
}
