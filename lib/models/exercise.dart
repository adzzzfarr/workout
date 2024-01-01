import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 0, adapterName: 'ExerciseAdapter')
class Exercise extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double weight;

  @HiveField(2)
  final int sets;

  @HiveField(3)
  final int reps;

  @HiveField(4)
  bool isCompleted;

  Exercise({
    required this.name,
    required this.weight,
    required this.sets,
    required this.reps,
    this.isCompleted = false,
  });
}
