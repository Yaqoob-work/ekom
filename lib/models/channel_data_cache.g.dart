// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_data_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChannelDataCacheAdapter extends TypeAdapter<ChannelDataCache> {
  @override
  final int typeId = 0;

  @override
  ChannelDataCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChannelDataCache(
      genres: (fields[0] as List).cast<String>(),
      content: (fields[1] as List).cast<ContentItem>(),
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ChannelDataCache obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.genres)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChannelDataCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
