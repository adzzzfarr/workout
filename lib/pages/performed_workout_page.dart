import 'dart:async';

import 'package:bottom_drawer/bottom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/performed_workout_data.dart';
import 'package:workout/models/performed_workout.dart';
import 'package:workout/pages/navigation_bar_page.dart';
import 'package:workout/widgets/exercise_tile.dart';

// TODO: Handle WillPopScope

class PerformedWorkoutPage extends StatefulWidget {
  final PerformedWorkout performedWorkout;

  const PerformedWorkoutPage({required this.performedWorkout, super.key});

  @override
  State<PerformedWorkoutPage> createState() => _PerformedWorkoutPageState();
}

class _PerformedWorkoutPageState extends State<PerformedWorkoutPage> {
  final weightController = TextEditingController();
  final setsController = TextEditingController();
  final repsController = TextEditingController();
  final bottomDrawerController = BottomDrawerController();

  Duration workoutDuration = const Duration(seconds: 0);
  Timer? workoutTimer;

  Duration restDuration = const Duration(seconds: 0);
  Timer? restTimer;
  bool isResting = false;

  @override
  void initState() {
    super.initState();
    startWorkoutTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PerformedWorkoutData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(widget.performedWorkout.name),
          actions: [
            MaterialButton(
              onPressed: () => finishWorkout(),
              child: const Text('Finish'),
            ),
          ],
        ),
        body: Builder(
          builder: (context) {
            return Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: displayWorkoutTimer(),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: value.getNumberOfExercisesInPerformedWorkout(
                            widget.performedWorkout.date,
                            widget.performedWorkout.name),
                        itemBuilder: (context, index) => Builder(
                          builder: (context) => ExerciseTile(
                            workoutType: 'performed',
                            exercise: value
                                .getIntendedPerformedWorkout(
                                    widget.performedWorkout.date,
                                    widget.performedWorkout.name)!
                                .exercises[index],
                            onEditSet: (exerciseName, setNumber) =>
                                showSetDetailsDialog(
                              exerciseName,
                              setNumber,
                              {
                                setNumber: value
                                    .getIntendedPerformedWorkout(
                                        widget.performedWorkout.date,
                                        widget.performedWorkout.name)!
                                    .exercises[index]
                                    .setWeightReps[setNumber]
                              },
                            ),
                            onCheckboxChanged: (value) {
                              setState(() {
                                widget.performedWorkout.exercises[index]
                                        .isCompleted =
                                    !widget.performedWorkout.exercises[index]
                                        .isCompleted;
                              });
                            },
                            onTilePressed: null,
                            onDismissed:
                                null, // Cannot delete exercises in a performed workout
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                buildBottomDrawer(context),
              ],
            );
          },
        ),
      ),
    );
  }

  void showSetDetailsDialog(
    String exerciseName,
    int setNumber,
    Map<int, dynamic> setDetails,
  ) {
    double? weight = setDetails[setNumber][0];
    int? reps = setDetails[setNumber][1];

    weightController.text = weight?.toString() ?? '';
    repsController.text = reps?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Set $setNumber Details',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              decoration: const InputDecoration(hintText: "Weight"),
            ),
            TextField(
              controller: repsController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: "Reps"),
            ),
          ],
        ),
        actions: [
          MaterialButton(
            onPressed: () => cancelEdit(),
            child: const Text('Cancel'),
          ),
          MaterialButton(
            onPressed: () {
              saveEditedSet(exerciseName, setNumber);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void cancelEdit() {
    Navigator.pop(context);
    weightController.clear();
    setsController.clear();
    repsController.clear();
  }

  void saveEditedSet(String exerciseName, int setNumber) {
    double weight = double.parse(weightController.text);
    int reps = int.parse(repsController.text);

    Provider.of<PerformedWorkoutData>(context, listen: false).editSet(
      widget.performedWorkout.date,
      widget.performedWorkout.name,
      exerciseName,
      setNumber,
      weight,
      reps,
    );

    Navigator.pop(context);
    weightController.clear();
    setsController.clear();
    repsController.clear();
  }

  void finishWorkout() {
    stopWorkoutTimer();
    Provider.of<PerformedWorkoutData>(context, listen: false).finishWorkout(
        widget.performedWorkout.date, widget.performedWorkout.name);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const NavigationBarPage(),
      ),
      (route) => false,
    );
  }

  Widget displayWorkoutTimer() {
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    final hours = twoDigits(workoutDuration.inHours);
    final minutes = twoDigits(workoutDuration.inMinutes.remainder(60));
    final seconds = twoDigits(workoutDuration.inSeconds.remainder(60));

    if (workoutDuration.inMinutes >= 60) {
      return Text('$hours:$minutes:$seconds');
    } else {
      return Text('$minutes:$seconds');
    }
  }

  void startWorkoutTimer() {
    workoutTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => increaseWorkoutDurationByOneSec(),
    );
  }

  void increaseWorkoutDurationByOneSec() {
    setState(() {
      final seconds = workoutDuration.inSeconds + 1;
      workoutDuration = Duration(seconds: seconds);
    });
  }

  void stopWorkoutTimer() {
    widget.performedWorkout.durationInSeconds = workoutDuration.inSeconds;
    workoutTimer?.cancel();
  }

  Widget buildBottomDrawer(BuildContext context) {
    return BottomDrawer(
      header: buildBottomDrawerHead(context),
      body: _buildBottomDrawerBody(context),
      headerHeight: 60,
      drawerHeight: 360,
      controller: bottomDrawerController,
    );
  }

  Widget buildBottomDrawerHead(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Column(
        children: const [
          Padding(
              padding: EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                top: 20.0,
              ),
              child: Text('Rest')),
          Spacer(),
          Divider(
            height: 1.0,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDrawerBody(BuildContext context) {
    if (!isResting) {
      return SizedBox(
        width: double.infinity,
        height: 360,
        child: SingleChildScrollView(
          child: Column(
            children: [displayRestTimeButtons()],
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        height: 360,
        child: Row(
          children: [
            displayRestTimer(),
            displayThirtySecondButtons(),
          ],
        ),
      );
    }
  }

  Widget displayRestTimer() {
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    final minutes = twoDigits(restDuration.inMinutes.remainder(60));
    final seconds = twoDigits(restDuration.inSeconds.remainder(60));

    return Text('$minutes:$seconds');
  }

  Widget displayRestTimeButtons() {
    return Row(
      children: [
        MaterialButton(
          onPressed: () => setState(() {
            restDuration = const Duration(minutes: 1);
            startRestTimer();
          }),
          child: const Text('1:00'),
        ),
        MaterialButton(
          onPressed: () => setState(() {
            restDuration = const Duration(minutes: 2);
            startRestTimer();
          }),
          child: const Text('2:00'),
        ),
        MaterialButton(
          onPressed: () => setState(() {
            restDuration = const Duration(minutes: 3);
            startRestTimer();
          }),
          child: const Text('3:00'),
        ),
        MaterialButton(
          onPressed: () => setState(() {
            restDuration = const Duration(minutes: 4);
            startRestTimer();
          }),
          child: const Text('4:00'),
        ),
      ],
    );
  }

  Widget displayThirtySecondButtons() {
    return Row(
      children: [
        MaterialButton(
          onPressed: () {
            setState(
              () {
                final seconds = restDuration.inSeconds + 30;
                restDuration = Duration(seconds: seconds);
              },
            );
          },
          child: const Text('+ 30s'),
        ),
        MaterialButton(
          onPressed: () {
            setState(
              () {
                int seconds = restDuration.inSeconds - 30;
                if (seconds < 0) {
                  seconds = 0;
                  isResting = false;
                }
                restDuration = Duration(seconds: seconds);
              },
            );
          },
          child: const Text('- 30s'),
        ),
      ],
    );
  }

  void startRestTimer() {
    restTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => decreaseRestDurationByOneSec(),
    );
    isResting = true;
  }

  void decreaseRestDurationByOneSec() {
    setState(() {
      final seconds = restDuration.inSeconds - 1;

      if (seconds < 0) {
        stopRestTimer();
      }

      restDuration = Duration(seconds: seconds);
    });
  }

  void stopRestTimer() {
    restDuration = const Duration(seconds: 0);
    restTimer?.cancel();
    isResting = false;
    bottomDrawerController.close();
  }
}
