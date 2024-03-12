import 'package:flutter/material.dart';

import '../models/exercise.dart';

class PerformedWorkoutExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final void Function(String exerciseName, int setNumber) onEditSet;
  final void Function(bool boolValue, int setNumber) onCheckboxChanged;

  const PerformedWorkoutExerciseTile({
    required this.exercise,
    required this.onEditSet,
    required this.onCheckboxChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      color: HSLColor.fromColor(colorScheme.background)
          .withLightness(0.2)
          .toColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.grey[600]!,
          width: 0.5,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.only(
          top: screenHeight / 75,
          bottom: screenHeight / 200,
          left: screenWidth / 20,
          right: screenWidth / 50,
        ),
        title: Text(
          exercise.name,
          style: TextStyle(color: Colors.white, fontSize: screenHeight / 47.5),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var setEntry in exercise.getSetsList())
              setWeightRepsTile(context, setEntry['set'], setEntry['weight'],
                  setEntry['reps'])
          ],
        ),
      ),
    );
  }

  Widget setWeightRepsTile(
    BuildContext context,
    int setNumber,
    double weight,
    int reps,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                'Set ${setNumber.toString()}: ',
                style: TextStyle(
                  color: exercise.setsCompletion![setNumber]!
                      ? Colors.green
                      : Colors.white,
                  fontSize: screenHeight / 52.5,
                ),
              ),
              Text(
                '${weight.toString()} KG, ${reps.toString()} Reps',
                style: TextStyle(
                  color: exercise.setsCompletion![setNumber]!
                      ? Colors.green
                      : Colors.white,
                  fontSize: screenHeight / 52.5,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, size: screenHeight / 37.5),
                onPressed: () => onEditSet(exercise.name, setNumber),
              ),
            ],
          ),
        ),
        Checkbox(
          activeColor: Colors.green,
          value: exercise.setsCompletion![setNumber]!,
          onChanged: (value) => onCheckboxChanged(value!, setNumber),
        ),
      ],
    );
  }
}
