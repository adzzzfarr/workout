// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 0;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercise(
      name: fields[0] as String,
      setWeightReps: (fields[1] as Map?)?.map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List).cast<dynamic>())),
      setsCompletion: (fields[2] as Map?)?.cast<String, bool>(),
      bodyPart: fields[3] as BodyPart,
      exerciseId: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.setWeightReps)
      ..writeByte(2)
      ..write(obj.setsCompletion)
      ..writeByte(3)
      ..write(obj.bodyPart)
      ..writeByte(4)
      ..write(obj.exerciseId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BodyPartAdapter extends TypeAdapter<BodyPart> {
  @override
  final int typeId = 3;

  @override
  BodyPart read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BodyPart.arms;
      case 1:
        return BodyPart.shoulders;
      case 2:
        return BodyPart.chest;
      case 3:
        return BodyPart.back;
      case 4:
        return BodyPart.legs;
      case 5:
        return BodyPart.core;
      case 6:
        return BodyPart.fullBody;
      default:
        return BodyPart.arms;
    }
  }

  @override
  void write(BinaryWriter writer, BodyPart obj) {
    switch (obj) {
      case BodyPart.arms:
        writer.writeByte(0);
        break;
      case BodyPart.shoulders:
        writer.writeByte(1);
        break;
      case BodyPart.chest:
        writer.writeByte(2);
        break;
      case BodyPart.back:
        writer.writeByte(3);
        break;
      case BodyPart.legs:
        writer.writeByte(4);
        break;
      case BodyPart.core:
        writer.writeByte(5);
        break;
      case BodyPart.fullBody:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyPartAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
