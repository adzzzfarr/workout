import 'package:hive/hive.dart';
part 'exercise.g.dart';

@HiveType(typeId: 0, adapterName: 'ExerciseAdapter')
class Exercise extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final Map<String, List<dynamic>>? setWeightReps;
  // '1': [10.0, 10] => Set 1 was performed with 10.0kg for 10 reps

  @HiveField(2)
  final Map<String, bool>? setsCompletion;
  // '1': true => Set 1 is completed

  @HiveField(3)
  final BodyPart bodyPart;

  @HiveField(4)
  final String exerciseId;

  Exercise({
    required this.name,
    required this.setWeightReps,
    required this.setsCompletion,
    required this.bodyPart,
    required this.exerciseId,
  });

  List<Map<String, dynamic>> getSetsList() {
    return setWeightReps!.entries
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
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': name,
      'setWeightReps': setWeightReps,
      'setsCompletion': setsCompletion,
      'bodyPart': getFormattedBodyPart(bodyPart),
      'exerciseId': exerciseId,
    };
  }
}

@HiveType(typeId: 3, adapterName: 'BodyPartAdapter')
enum BodyPart {
  @HiveField(0)
  arms,
  @HiveField(1)
  shoulders,
  @HiveField(2)
  chest,
  @HiveField(3)
  back,
  @HiveField(4)
  legs,
  @HiveField(5)
  core,
  @HiveField(6)
  fullBody,
}
