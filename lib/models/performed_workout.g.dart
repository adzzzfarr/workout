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
      date: fields[3] as DateTime,
      durationInSeconds: fields[4] as int,
      isCompleted: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PerformedWorkout obj) {
    writer
      ..writeByte(5)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.durationInSeconds)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.exercises);
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
