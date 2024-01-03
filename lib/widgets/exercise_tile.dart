import 'package:flutter/material.dart';

class ExerciseTile extends StatelessWidget {
  final String exerciseName;
  final List<Map<String, dynamic>> setsList;
  final bool isCompleted;
  final void Function(bool) onCheckboxChanged;
  final void Function(String?) onTileLongPressed;
  final void Function(String, int) onEditSet;
  final void Function() onDismissed;

  const ExerciseTile({
    required this.exerciseName,
    required this.setsList,
    required this.isCompleted,
    required this.onCheckboxChanged,
    required this.onTileLongPressed,
    required this.onEditSet,
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var setEntry in setsList)
              Row(
                children: [
                  Text('Set ${setEntry['set'].toString()}: '),
                  Text(
                      '${setEntry['weight'].toString()} KG, ${setEntry['reps'].toString()} Reps'),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => onEditSet(exerciseName, setEntry['set']),
                  ),
                ],
              ),
          ],
        ),
        trailing: Checkbox(
          value: isCompleted,
          onChanged: (value) => onCheckboxChanged(value!),
        ),
        onLongPress: () => onTileLongPressed(exerciseName),
      ),
    );
  }
}
