// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudySessionAdapter extends TypeAdapter<StudySession> {
  @override
  final int typeId = 3;

  @override
  StudySession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudySession(
      id: fields[0] as String,
      goalId: fields[1] as String,
      date: fields[2] as DateTime,
      duration: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, StudySession obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.goalId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudySessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
