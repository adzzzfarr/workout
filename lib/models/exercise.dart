import 'package:hive/hive.dart';

part 'exercise.g.dart';

enum BodyPart {
  arms,
  shoulders,
  chest,
  back,
  legs,
  core,
  fullBody,
  cardio,
}

@HiveType(typeId: 0, adapterName: 'ExerciseAdapter')
class Exercise extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final Map<int, List<dynamic>> setWeightReps;
  // 1: [10.0, 10] => Set 1 was performed with 10.0kg for 10 reps

  @HiveField(2)
  final BodyPart bodyPart;

  @HiveField(3)
  bool isCompleted;

  Exercise({
    required this.name,
    required this.setWeightReps,
    required this.bodyPart,
    this.isCompleted = false,
  });

  List<Map<String, dynamic>> getSetsList() {
    return setWeightReps.entries
        .map((entry) => {
              'set': entry.key,
              'weight': entry.value[0],
              'reps': entry.value[1],
            })
        .toList();
  }

  String getFormattedBodyPart(BodyPart bodyPart) {
    switch (bodyPart) {
      case BodyPart.arms:
        return 'Arms';
      case BodyPart.shoulders:
        return 'Shoulders';
      case BodyPart.chest:
        return 'Chest';
      case BodyPart.back:
        return 'Back';
      case BodyPart.legs:
        return 'Legs';
      case BodyPart.core:
        return 'Core';
      case BodyPart.fullBody:
        return 'Full Body';
      case BodyPart.cardio:
        return 'Cardio';
    }
  }
}
