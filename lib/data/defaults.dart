import '../models/exercise.dart';
import '../models/template_workout.dart';
import 'package:uuid/uuid.dart';

List<TemplateWorkout> defaultTemplateWorkoutList = [
  // default workout templates
  TemplateWorkout(
    name: "Upper Body",
    exercises: [
      Exercise(
        name: "Bench Press (Barbell)",
        setWeightReps: {
          '1': [10.0, 10],
          '2': [9.0, 9],
          '3': [8.0, 8],
        },
        setsCompletion: {
          '1': false,
          '2': false,
          '3': false,
        },
        bodyPart: BodyPart.chest,
        exerciseId: const Uuid().v4(),
      ),
    ],
    templateWorkoutId: const Uuid().v4(),
  ),
  TemplateWorkout(
    name: "Lower Body",
    exercises: [
      Exercise(
        name: "Squat (Barbell)",
        setWeightReps: {
          '1': [10.0, 10],
          '2': [9.0, 9],
          '3': [8.0, 8],
        },
        setsCompletion: {
          '1': false,
          '2': false,
          '3': false,
        },
        bodyPart: BodyPart.legs,
        exerciseId: const Uuid().v4(),
      ),
    ],
    templateWorkoutId: const Uuid().v4(),
  ),
];

// set data can be null as this is just for display in ExerciseListPage. Actual set data for a particular instance is stored in the PerformedWorkout containing it.
List<Exercise> defaultExerciseList = [
  Exercise(
    name: "Bench Press (Barbell)",
    setWeightReps: null,
    setsCompletion: null,
    bodyPart: BodyPart.chest,
    exerciseId: const Uuid().v4(),
  ),
  Exercise(
    name: "Bench Press (Dumbbell)",
    setWeightReps: null,
    setsCompletion: null,
    bodyPart: BodyPart.chest,
    exerciseId: const Uuid().v4(),
  ),
  Exercise(
    name: "Bent-over Row (Barbell)",
    setWeightReps: null,
    setsCompletion: null,
    bodyPart: BodyPart.back,
    exerciseId: const Uuid().v4(),
  ),
  Exercise(
    name: "Face Pull (Cable)",
    setWeightReps: null,
    setsCompletion: null,
    bodyPart: BodyPart.shoulders,
    exerciseId: const Uuid().v4(),
  ),
  Exercise(
    name: "High Row (Plate-loaded)",
    setWeightReps: null,
    setsCompletion: null,
    bodyPart: BodyPart.back,
    exerciseId: const Uuid().v4(),
  ),
  Exercise(
    name: "Incline Bench Press (Barbell)",
    setWeightReps: null,
    setsCompletion: null,
    bodyPart: BodyPart.chest,
    exerciseId: const Uuid().v4(),
  ),
  Exercise(
    name: "Incline Bench Press (Smith Machine)",
    setWeightReps: null,
    setsCompletion: null,
    bodyPart: BodyPart.chest,
    exerciseId: const Uuid().v4(),
  ),
  Exercise(
    name: "Leg Press (Machine)",
    setWeightReps: null,
    setsCompletion: null,
    bodyPart: BodyPart.legs,
    exerciseId: const Uuid().v4(),
  ),
  Exercise(
    name: "Pendulum Squat (Plate-loaded)",
    setWeightReps: null,
    setsCompletion: null,
    bodyPart: BodyPart.legs,
    exerciseId: const Uuid().v4(),
  ),
  Exercise(
    name: "Squat (Barbell)",
    setWeightReps: null,
    setsCompletion: null,
    bodyPart: BodyPart.legs,
    exerciseId: const Uuid().v4(),
  ),
];
