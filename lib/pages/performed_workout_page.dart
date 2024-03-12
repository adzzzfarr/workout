import 'dart:async';

import 'package:bottom_drawer/bottom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout/data/exercise_data.dart';
import 'package:workout/data/performed_workout_data.dart';
import 'package:workout/data/template_workout_data.dart';
import 'package:workout/models/performed_workout.dart';
import 'package:workout/pages/exercise_list_page.dart';
import 'package:workout/pages/navigation_bar_page.dart';
import 'package:workout/widgets/common_button.dart';

import 'package:workout/widgets/performed_workout_exercise_tile.dart';

import '../models/exercise.dart';

final setDetailsFormKey = GlobalKey<FormState>();

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
    for (var exercise in widget.performedWorkout.exercises) {
      for (var setNumber in exercise.setsCompletion!.keys) {
        exercise.setsCompletion![setNumber] = false;
      }
    }
    startWorkoutTimer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<PerformedWorkoutData>(
      builder: (context, value, child) => WillPopScope(
        onWillPop: () => showConfirmCancelWorkoutDialog(),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(widget.performedWorkout.name),
            actions: [
              IconButton(
                onPressed: () => allExercisesCompleted(widget.performedWorkout)
                    ? finishWorkout()
                    : ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please mark all sets as completed.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenHeight / 50,
                            ),
                          ),
                          backgroundColor: colorScheme.primary,
                          elevation: 10,
                        ),
                      ),
                icon: const Icon(Icons.done_all),
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
                        child: displayWorkoutTimer(context),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount:
                              value.getNumberOfExercisesInPerformedWorkout(
                                  widget.performedWorkout.date,
                                  widget.performedWorkout.name),
                          itemBuilder: (context, index) => Builder(
                            builder: (context) => PerformedWorkoutExerciseTile(
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
                                      .setWeightReps![setNumber]
                                },
                              ),
                              onCheckboxChanged: (val, setNumber) {
                                setDataIsValid(
                                  value
                                      .getIntendedPerformedWorkout(
                                          widget.performedWorkout.date,
                                          widget.performedWorkout.name)!
                                      .exercises[index]
                                      .name,
                                  setNumber,
                                )
                                    ? setState(
                                        () => toggleSetCompletion(
                                          value
                                              .getIntendedPerformedWorkout(
                                                  widget.performedWorkout.date,
                                                  widget.performedWorkout.name)!
                                              .exercises[index]
                                              .name,
                                          setNumber,
                                        ),
                                      )
                                    : ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Perform at least one rep.',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: screenHeight / 50,
                                            ),
                                          ),
                                          backgroundColor: colorScheme.primary,
                                          elevation: 10,
                                        ),
                                      );
                              },
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
      ),
    );
  }

  Future<bool> showConfirmCancelWorkoutDialog() async {
    return await showDialog(
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
          "Cancel Workout?",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Don't pop
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Pop
            child: const Text('Yes'),
          ),
        ],
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.grey[600]!,
            width: 0.5,
          ),
        ),
        elevation: 10,
        title: Text(
          'Edit Set $setNumber Details',
          style: const TextStyle(color: Colors.white),
        ),
        content: Form(
          key: setDetailsFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: weightController,
                validator: (value) => weightValidator(value),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: "Weight"),
                style: const TextStyle(color: Colors.white),
              ),
              TextFormField(
                controller: repsController,
                validator: (value) => repsValidator(value),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                decoration: const InputDecoration(hintText: "Reps"),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () => cancelEdit(),
            child: const Text('Cancel'),
          ),
          MaterialButton(
            onPressed: () {
              setDetailsFormKey.currentState!.validate();

              if (setDetailsFormKey.currentState!.validate()) {
                saveEditedSet(exerciseName, setNumber);
              }
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

    if (weight >= 0 && reps > 0) {
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
  }

  void toggleSetCompletion(String exerciseName, int setNumber) {
    Provider.of<PerformedWorkoutData>(context, listen: false)
        .toggleSetCompletion(widget.performedWorkout.date,
            widget.performedWorkout.name, exerciseName, setNumber);
  }

  bool setDataIsValid(String exerciseName, int setNumber) {
    return Provider.of<PerformedWorkoutData>(context, listen: false)
        .ensureValidSetData(widget.performedWorkout.date,
            widget.performedWorkout.name, exerciseName, setNumber);
  }

  void finishWorkout() {
    stopWorkoutTimer();
    Provider.of<PerformedWorkoutData>(context, listen: false).finishWorkout(
        widget.performedWorkout.date, widget.performedWorkout.name);

    Provider.of<TemplateWorkoutData>(context, listen: false)
        .updateTemplateWorkout(widget.performedWorkout);
    Provider.of<ExerciseData>(context, listen: false)
        .updateExerciseInstances(widget.performedWorkout);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const NavigationBarPage(),
      ),
      (route) => false,
    );
  }

  Widget displayWorkoutTimer(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    String twoDigits(int number) => number.toString().padLeft(2, '0');
    final hours = twoDigits(workoutDuration.inHours);
    final minutes = twoDigits(workoutDuration.inMinutes.remainder(60));
    final seconds = twoDigits(workoutDuration.inSeconds.remainder(60));

    if (workoutDuration.inMinutes >= 60) {
      return Text(
        '$hours:$minutes:$seconds',
        style: TextStyle(
          color: Colors.white,
          fontSize: screenHeight / 45,
        ),
      );
    } else {
      return Text(
        '$minutes:$seconds',
        style: TextStyle(
          color: Colors.white,
          fontSize: screenHeight / 45,
        ),
      );
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final screenHeight = MediaQuery.of(context).size.height;

    return BottomDrawer(
      color: isResting
          ? colorScheme.primary
          : HSLColor.fromColor(colorScheme.background)
              .withLightness(0.3)
              .toColor(),
      cornerRadius: 60,
      header: buildBottomDrawerHead(context),
      body: buildBottomDrawerBody(context),
      headerHeight: screenHeight / 10,
      drawerHeight: screenHeight / 5,
      controller: bottomDrawerController,
    );
  }

  Widget buildBottomDrawerHead(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          isResting
              ? Text(
                  'Resting',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenHeight / 40,
                  ),
                )
              : Text(
                  'Rest',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenHeight / 40,
                  ),
                ),
        ],
      ),
    );
  }

  Widget buildBottomDrawerBody(BuildContext context) {
    if (!isResting) {
      return Column(
        children: [
          const Divider(
            thickness: 1,
            color: Colors.grey,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [displayRestTimeButtons(context)],
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          const Divider(
            thickness: 1,
            color: Colors.white,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                displaySubtract30sButton(context),
                displayRestTimer(context),
                displayAdd30sButton(context),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget displayRestTimeButtons(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CommonButton(
          height: screenHeight / 27.5,
          width: screenWidth / 5,
          text: '1:00',
          onPressed: () => setState(() {
            restDuration = const Duration(minutes: 1);
            startRestTimer();
          }),
        ),
        CommonButton(
          height: screenHeight / 27.5,
          width: screenWidth / 5,
          text: '2:00',
          onPressed: () => setState(() {
            restDuration = const Duration(minutes: 2);
            startRestTimer();
          }),
        ),
        CommonButton(
          height: screenHeight / 27.5,
          width: screenWidth / 5,
          text: '3:00',
          onPressed: () => setState(() {
            restDuration = const Duration(minutes: 3);
            startRestTimer();
          }),
        ),
        CommonButton(
          height: screenHeight / 27.5,
          width: screenWidth / 5,
          text: '4:00',
          onPressed: () => setState(() {
            restDuration = const Duration(minutes: 4);
            startRestTimer();
          }),
        ),
      ],
    );
  }

  Widget displayRestTimer(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    String twoDigits(int number) => number.toString().padLeft(2, '0');
    final minutes = twoDigits(restDuration.inMinutes.remainder(60));
    final seconds = twoDigits(restDuration.inSeconds.remainder(60));

    return Text(
      '$minutes:$seconds',
      style: TextStyle(
        fontSize: screenHeight / 20,
        color: Colors.white,
        letterSpacing: screenWidth / 55,
      ),
    );
  }

  Widget displayAdd30sButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CommonButton(
      height: 30,
      width: 90,
      color: colorScheme.secondary,
      text: '+30s',
      onPressed: () => setState(
        () {
          final seconds = restDuration.inSeconds + 30;
          restDuration = Duration(seconds: seconds);
        },
      ),
    );
  }

  Widget displaySubtract30sButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CommonButton(
      height: 30,
      width: 90,
      color: colorScheme.secondary,
      text: '-30s',
      onPressed: () => setState(
        () => setState(
          () {
            int seconds = restDuration.inSeconds - 30;
            if (seconds < 0) {
              seconds = 0;
              isResting = false;
            }
            restDuration = Duration(seconds: seconds);
          },
        ),
      ),
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

  bool allExercisesCompleted(PerformedWorkout performedWorkout) {
    for (var exercise in performedWorkout.exercises) {
      for (var setNumber in exercise.setsCompletion!.keys) {
        if (exercise.setsCompletion![setNumber] == false) {
          return false;
        }
      }
    }
    return true;
  }

  String? weightValidator(String? weight) {
    print(weight);
    if (weight == null || weight.isEmpty || double.parse(weight) < 0) {
      return 'Please input a valid weight.';
    }
    return null;
  }

  String? repsValidator(String? reps) {
    print(reps);
    if (reps == null || reps.isEmpty || int.parse(reps) < 1) {
      return 'At least 1 rep must be performed.';
    }
    return null;
  }
}
