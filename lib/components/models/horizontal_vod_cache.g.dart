// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'horizontal_vod_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HorizontalVodCacheAdapter extends TypeAdapter<HorizontalVodCache> {
  @override
  final int typeId = 4;

  @override
  HorizontalVodCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HorizontalVodCache(
      vods: (fields[0] as List).cast<HorizontalVodModel>(),
      timestamp: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HorizontalVodCache obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.vods)
      ..writeByte(1)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HorizontalVodCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
