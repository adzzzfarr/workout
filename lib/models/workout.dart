import 'package:hive/hive.dart';
import 'package:workout/models/exercise.dart';

part 'workout.g.dart';

@HiveType(typeId: 1, adapterName: 'WorkoutAdapter')
class Workout extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<Exercise> exercises;

  Workout({required this.name, required this.exercises});
}
