import 'package:flutter/material.dart';

class ExerciseTile extends StatelessWidget {
  final String exerciseName;
  final double weight;
  final int sets;
  final int reps;
  final bool isCompleted;
  final void Function(bool) onCheckboxChanged;
  final void Function(String?) onTilePressed;
  final void Function() onDismissed;

  const ExerciseTile({
    required this.exerciseName,
    required this.weight,
    required this.sets,
    required this.reps,
    required this.isCompleted,
    required this.onCheckboxChanged,
    required this.onTilePressed,
    required this.onDismissed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(exerciseName),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Icon(
            Icons.edit,
            color: Colors.white,
          ),
        ),
      ),
      onDismissed: (direction) => onDismissed(),
      child: ListTile(
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
        onTap: () => onTilePressed(exerciseName),
      ),
    );
  }
}
