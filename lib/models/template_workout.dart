import 'package:hive/hive.dart';
import 'package:workout/models/exercise.dart';

part 'template_workout.g.dart';

@HiveType(typeId: 1, adapterName: 'TemplateWorkoutAdapter')
class TemplateWorkout extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<Exercise> exercises;

  TemplateWorkout({required this.name, required this.exercises});
}
