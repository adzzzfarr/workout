import 'package:flutter/material.dart';
import 'package:workout/models/exercise.dart';

class TemplateWorkoutExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final Key tileKey;
  final void Function() onTilePressed;
  final void Function(String exerciseName) onEditPressed;
  final void Function(DismissDirection) onDismissed;

  const TemplateWorkoutExerciseTile({
    required this.exercise,
    required this.tileKey,
    required this.onTilePressed,
    required this.onEditPressed,
    required this.onDismissed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => onTilePressed(),
      child: Padding(
        padding: EdgeInsets.only(
            top: screenHeight / 300,
            left: screenWidth / 80,
            right: screenWidth / 80),
        child: Dismissible(
          key: tileKey,
          onDismissed: (direction) => onDismissed(direction),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(
                  top: screenHeight / 300,
                  left: screenWidth / 80,
                  right: screenWidth / 80),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
            ),
          ),
          child: Card(
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
                bottom: screenHeight / 75,
                left: screenWidth / 20,
                right: screenWidth / 30,
              ),
              title: Text(
                exercise.name,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: screenHeight / 50,
                    fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.getFormattedBodyPart(exercise.bodyPart),
                    style: TextStyle(
                        color: Colors.white, fontSize: screenHeight / 60),
                  ),
                  Text(
                    exercise.getSetsList().length > 1
                        ? '${exercise.getSetsList().length} Sets'
                        : '${exercise.getSetsList().length} Set',
                    style: TextStyle(
                        color: Colors.white, fontSize: screenHeight / 60),
                  ),
                ],
              ),
              trailing: IconButton(
                alignment: Alignment.centerRight,
                onPressed: () => onEditPressed(exercise.name),
                icon: const Icon(
                  Icons.edit,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
