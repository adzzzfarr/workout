class Exercise {
  final String name;
  final double weight;
  final int sets;
  final int reps;
  bool isCompleted;

  Exercise({
    required this.name,
    required this.weight,
    required this.sets,
    required this.reps,
    this.isCompleted = false,
  });
}
