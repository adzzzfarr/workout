import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:workout/pages/dashboard_page.dart';
import 'package:workout/pages/template_workouts_list_page.dart';
import 'package:workout/pages/workout_history_page.dart';

class NavigationBarPage extends StatefulWidget {
  const NavigationBarPage({super.key});

  @override
  State<NavigationBarPage> createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  final navigationKey = GlobalKey<CurvedNavigationBarState>();
  int selectedIndex = 1;

  final screens = const [
    WorkoutHistoryPage(),
    DashboardPage(),
    TemplateWorkoutsListPage(),
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
