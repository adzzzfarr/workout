import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 0, adapterName: 'ExerciseAdapter')
class Exercise extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final Map<int, List<dynamic>> setWeightReps;
  // 1: [10.0, 10] => Set 1 was performed with 10.0kg for 10 reps

  @HiveField(2)
  bool isCompleted;

  Exercise({
    required this.name,
    required this.setWeightReps,
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
}
