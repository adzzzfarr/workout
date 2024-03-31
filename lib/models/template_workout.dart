import 'package:hive/hive.dart';
import 'package:workout/models/exercise.dart';

part 'template_workout.g.dart';

@HiveType(typeId: 1, adapterName: 'TemplateWorkoutAdapter')
class TemplateWorkout extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<Exercise> exercises;

  @HiveField(2)
  final String templateWorkoutId;

  TemplateWorkout({
    required this.name,
    required this.exercises,
    required this.templateWorkoutId,
  });

  Map<String, dynamic> toJson() {
    // Keys are the names of each exercise, Values are the json map of each exercise
    final Map<String, dynamic> exercisesMap = {};

    for (var exercise in exercises) {
      final exerciseJson = exercise.toJson();
      exercisesMap[exercise.name] = exerciseJson;
    }

    return {
      'templateWorkoutName': name,
      'exercises': exercisesMap,
      'templateWorkoutId': templateWorkoutId,
    };
  }
}
