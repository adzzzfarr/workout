import 'package:flutter/material.dart';
import 'package:workout/models/exercise.dart';

class ExerciseListPageTile extends StatelessWidget {
  final Exercise exercise;
  final Key tileKey;
  final void Function() onTilePressed;
  final void Function(DismissDirection direction) onDismissed;

  const ExerciseListPageTile({
    required this.exercise,
    required this.tileKey,
    required this.onTilePressed,
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
      child: Dismissible(
        key: tileKey,
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
            leading: Padding(
              padding: const EdgeInsets.only(top: 5, right: 3),
              child: ImageIcon(
                AssetImage(getIconPath(exercise.bodyPart)),
                size: screenHeight / 15,
              ),
            ),
            title: Text(
              exercise.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: screenHeight / 45,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              exercise.getFormattedBodyPart(exercise.bodyPart),
              style: TextStyle(
                color: Colors.white,
                fontSize: screenHeight / 55,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String getIconPath(BodyPart bodyPart) {
    switch (bodyPart) {
      case BodyPart.arms:
        return 'lib/assets/icons/arms.png';
      case BodyPart.shoulders:
        return 'lib/assets/icons/shoulders.png';
      case BodyPart.chest:
        return 'lib/assets/icons/chest.png';
      case BodyPart.back:
        return 'lib/assets/icons/back.png';
      case BodyPart.legs:
        return 'lib/assets/icons/legs.png';
      case BodyPart.core:
        return 'lib/assets/icons/core.png';
      case BodyPart.fullBody:
        return 'lib/assets/icons/full_body.png';
    }
  }
}
