// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'horizontal_vod_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HorizontalVodModelAdapter extends TypeAdapter<HorizontalVodModel> {
  @override
  final int typeId = 3;

  @override
  HorizontalVodModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HorizontalVodModel(
      id: fields[0] as int,
      name: fields[1] as String,
      description: fields[2] as String?,
      logo: fields[3] as String?,
      releaseDate: fields[4] as String?,
      genres: fields[5] as String?,
      rating: fields[6] as String?,
      language: fields[7] as String?,
      status: fields[8] as int,
      networks_order: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HorizontalVodModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.logo)
      ..writeByte(4)
      ..write(obj.releaseDate)
      ..writeByte(5)
      ..write(obj.genres)
      ..writeByte(6)
      ..write(obj.rating)
      ..writeByte(7)
      ..write(obj.language)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.networks_order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HorizontalVodModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
