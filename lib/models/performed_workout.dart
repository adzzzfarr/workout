import 'package:hive/hive.dart';
import 'exercise.dart';
import 'template_workout.dart';

part 'performed_workout.g.dart';

@HiveType(typeId: 2, adapterName: 'PerformedWorkoutAdapter')
class PerformedWorkout extends TemplateWorkout {
  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final int duration;

  @HiveField(5)
  final bool isCompleted;

  PerformedWorkout({
    required String name,
    required List<Exercise> exercises,
    required this.date,
    required this.duration,
    this.isCompleted = false,
  }) : super(
          name: name,
          exercises: exercises,
        );
}

/*
EXPLANATION 

If you have an existing TemplateWorkout instance with the fields' values set as
name1 and exerciseList1, and you want to create a corresponding PerformedWorkout 
instance with the same values, you can do so in the constructor of 
PerformedWorkout. You would pass the values from the TemplateWorkout instance 
to the constructor of PerformedWorkout:

class PerformedWorkout extends TemplateWorkout {
  PerformedWorkout({required String name, required List<Exercise> exercises})
      : super(name: name, exercises: exercises);
}

Now, when you instantiate a PerformedWorkout:

TemplateWorkout templateWorkout = TemplateWorkout(
                                    name: 'name1', 
                                    exercises: [/*...*/],
                                  );

PerformedWorkout performedWorkout = PerformedWorkout(
  name: templateWorkout.name,
  exercises: List.from(templateWorkout.exercises),
);

This way, the PerformedWorkout instance will have the same name and exercises 
values as the original TemplateWorkout. Note that I used 
List.from(templateWorkout.exercises) to create a new list with the same elements. 
This helps avoid any unintended shared references between 
the TemplateWorkout and PerformedWorkout instances.

*/
