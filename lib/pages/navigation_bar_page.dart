import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/template_workout_data.dart';
import 'package:workout/pages/dashboard_page.dart';
import 'package:workout/pages/exercise_list_page.dart';
import 'package:workout/pages/workout_history_page.dart';

import '../data/performed_workout_data.dart';

class NavigationBarPage extends StatefulWidget {
  const NavigationBarPage({super.key});

  @override
  State<NavigationBarPage> createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<TemplateWorkoutData>(context, listen: false)
        .initialiseTemplateWorkoutList();
    Provider.of<PerformedWorkoutData>(context, listen: false)
        .initialiseCompletedWorkoutList();
    Provider.of<PerformedWorkoutData>(context, listen: false).loadHeatMap();
  }

  final navigationKey = GlobalKey<CurvedNavigationBarState>();
  int selectedIndex = 1;

  final screens = const [
    WorkoutHistoryPage(),
    DashboardPage(),
    ExerciseListPage(isAddingExerciseToTemplateWorkout: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: navigationKey,
        index: selectedIndex,
        items: const [
          Icon(Icons.history_rounded),
          Icon(Icons.dashboard_rounded),
          Icon(Icons.fitness_center_rounded),
        ],
        height: 50,
        onTap: (index) => setState(() {
          selectedIndex = index;
        }),
      ),
      body: screens[selectedIndex],
    );
  }
}
