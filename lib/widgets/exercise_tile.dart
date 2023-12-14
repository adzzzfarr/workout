import 'package:flutter/material.dart';

class ExerciseTile extends StatelessWidget {
  final String exerciseName;
  final double weight;
  final int sets;
  final int reps;
  final bool isCompleted;
  final void Function(bool) onCheckboxChanged;

  const ExerciseTile({
    required this.exerciseName,
    required this.weight,
    required this.sets,
    required this.reps,
    required this.isCompleted,
    required this.onCheckboxChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(exerciseName),
      subtitle: Row(
        children: [
          Chip(
            label: Text(
              "${weight.toString()} KG",
            ),
          ),
          Chip(
            label: Text(
              "${sets.toString()} Sets",
            ),
          ),
          Chip(
            label: Text(
              "${reps.toString()} Reps",
            ),
          ),
        ],
      ),
      trailing: Checkbox(
        value: isCompleted,
        onChanged: (value) => onCheckboxChanged(value!),
      ),
    );
  }
}
