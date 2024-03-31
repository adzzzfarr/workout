// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_workout.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TemplateWorkoutAdapter extends TypeAdapter<TemplateWorkout> {
  @override
  final int typeId = 1;

  @override
  TemplateWorkout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TemplateWorkout(
      name: fields[0] as String,
      exercises: (fields[1] as List).cast<Exercise>(),
      templateWorkoutId: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TemplateWorkout obj) {
    writer
      ..writeByte(3)
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
      other is TemplateWorkoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
