// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 0;

  @override
  Goal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Goal(
      id: fields[0] as String,
      title: fields[1] as String,
      subject: fields[2] as String,
      date: fields[3] as DateTime,
      type: fields[4] as GoalType,
      difficulty: fields[5] as Difficulty,
      isCompleted: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.subject)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.difficulty)
      ..writeByte(6)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalTypeAdapter extends TypeAdapter<GoalType> {
  @override
  final int typeId = 1;

  @override
  GoalType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalType.exam;
      case 1:
        return GoalType.test;
      case 2:
        return GoalType.assignment;
      case 3:
        return GoalType.presentation;
      case 4:
        return GoalType.project;
      case 5:
        return GoalType.paper;
      case 6:
        return GoalType.quiz;
      case 7:
        return GoalType.other;
      default:
        return GoalType.exam;
    }
  }

  @override
  void write(BinaryWriter writer, GoalType obj) {
    switch (obj) {
      case GoalType.exam:
        writer.writeByte(0);
        break;
      case GoalType.test:
        writer.writeByte(1);
        break;
      case GoalType.assignment:
        writer.writeByte(2);
        break;
      case GoalType.presentation:
        writer.writeByte(3);
        break;
      case GoalType.project:
        writer.writeByte(4);
        break;
      case GoalType.paper:
        writer.writeByte(5);
        break;
      case GoalType.quiz:
        writer.writeByte(6);
        break;
      case GoalType.other:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DifficultyAdapter extends TypeAdapter<Difficulty> {
  @override
  final int typeId = 2;

  @override
  Difficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Difficulty.easy;
      case 1:
        return Difficulty.medium;
      case 2:
        return Difficulty.hard;
      case 3:
        return Difficulty.veryHard;
      default:
        return Difficulty.easy;
    }
  }

  @override
  void write(BinaryWriter writer, Difficulty obj) {
    switch (obj) {
      case Difficulty.easy:
        writer.writeByte(0);
        break;
      case Difficulty.medium:
        writer.writeByte(1);
        break;
      case Difficulty.hard:
        writer.writeByte(2);
        break;
      case Difficulty.veryHard:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
