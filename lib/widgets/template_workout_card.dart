import 'package:flutter/material.dart';

class TemplateWorkoutCard extends StatelessWidget {
  final String name;
  final int noOfExercises;
  final Key cardKey;
  final void Function() onPressed;
  final void Function(DismissDirection) onDismissed;

  const TemplateWorkoutCard(
      {required this.name,
      required this.noOfExercises,
      required this.cardKey,
      required this.onPressed,
      required this.onDismissed,
      super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => onPressed(),
      child: Padding(
        padding: EdgeInsets.only(
            top: screenHeight / 300,
            left: screenWidth / 80,
            right: screenWidth / 80),
        child: Dismissible(
          key: cardKey,
          onDismissed: (direction) => onDismissed(direction),
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
                name,
                style:
                    TextStyle(color: Colors.white, fontSize: screenHeight / 45),
              ),
              subtitle: Text(
                noOfExercises > 1 || noOfExercises == 0
                    ? '${noOfExercises.toString()} Exercises'
                    : '${noOfExercises.toString()} Exercise',
                style:
                    TextStyle(color: Colors.white, fontSize: screenHeight / 55),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ),
        ),
      ),
    );
  }
}
