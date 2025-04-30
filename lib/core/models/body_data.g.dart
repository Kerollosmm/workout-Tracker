// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BodyDataAdapter extends TypeAdapter<BodyData> {
  @override
  final int typeId = 5;

  @override
  BodyData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BodyData(
      weight: fields[0] as double,
      height: fields[1] as double,
      date: fields[2] as DateTime,
      note: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BodyData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.weight)
      ..writeByte(1)
      ..write(obj.height)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
