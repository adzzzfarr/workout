// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performed_workout.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PerformedWorkoutAdapter extends TypeAdapter<PerformedWorkout> {
  @override
  final int typeId = 2;

  @override
  PerformedWorkout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PerformedWorkout(
      name: fields[0] as String,
      exercises: (fields[1] as List).cast<Exercise>(),
      templateWorkoutId: fields[2] as String,
      date: fields[3] as DateTime,
      durationInSeconds: fields[4] as int,
      completedWorkoutId: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PerformedWorkout obj) {
    writer
      ..writeByte(6)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.durationInSeconds)
      ..writeByte(5)
      ..write(obj.completedWorkoutId)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.exercises)
      ..writeByte(2)
      ..write(obj.templateWorkoutId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PerformedWorkoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
