import 'package:flutter/material.dart';

import '../models/exercise.dart';

class ExerciseTile extends StatelessWidget {
  final String workoutType;
  final Exercise exercise;
  /*
  final String exerciseName;
  final BodyPart bodyPart;
  final List<Map<String, dynamic>> setsList;
  final bool isCompleted;
  */
  final void Function(bool)? onCheckboxChanged;
  final void Function(String?)? onTilePressed;
  final void Function(String, int)? onEditSet;
  final void Function()? onDismissed;

  const ExerciseTile({
    required this.workoutType,
    required this.exercise,
    required this.onCheckboxChanged,
    required this.onTilePressed,
    required this.onEditSet,
    required this.onDismissed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (workoutType == 'template') {
      return Dismissible(
        key: Key(exercise.name),
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
        onDismissed: (direction) => onDismissed!(),
        child: ListTile(
          title: Text(exercise.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(exercise.getFormattedBodyPart(exercise.bodyPart)),
              Text('${exercise.getSetsList().length} Sets'),
            ],
          ),
          onTap: () => onTilePressed!(exercise.name),
        ),
      );
    } else if (workoutType == 'performed') {
      return ListTile(
        title: Text(exercise.name),
        tileColor: exercise.isCompleted ? Colors.green : null,
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var setEntry in exercise.getSetsList())
              Row(
                children: [
                  Text('Set ${setEntry['set'].toString()}: '),
                  Text(
                      '${setEntry['weight'].toString()} KG, ${setEntry['reps'].toString()} Reps'),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => onEditSet!(exercise.name, setEntry['set']),
                  ),
                ],
              ),
          ],
        ),
        trailing: Checkbox(
          value: exercise.isCompleted,
          onChanged: (value) => onCheckboxChanged!(value!),
        ),
      );
    } else if (workoutType == 'completed') {
      return ListTile(
        title: Text(exercise.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var setEntry in exercise.getSetsList())
              Row(
                children: [
                  Text('Set ${setEntry['set'].toString()}: '),
                  Text(
                      '${setEntry['weight'].toString()} KG, ${setEntry['reps'].toString()} Reps'),
                ],
              ),
          ],
        ),
      );
    }
    return const Scaffold(
      body: Text('Error'),
    );
  }
}
