// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContentItemAdapter extends TypeAdapter<ContentItem> {
  @override
  final int typeId = 1;

  @override
  ContentItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContentItem(
      id: fields[0] as int,
      name: fields[1] as String,
      updatedAt: fields[15] as String,
      description: fields[2] as String?,
      genres: fields[3] as String,
      releaseDate: fields[4] as String?,
      runtime: fields[5] as int?,
      poster: fields[6] as String?,
      banner: fields[7] as String?,
      sourceType: fields[8] as String?,
      contentType: fields[9] as int,
      status: fields[10] as int,
      networks: (fields[11] as List).cast<NetworkData>(),
      movieUrl: fields[12] as String?,
      seriesOrder: fields[13] as int?,
      youtubeTrailer: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ContentItem obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.genres)
      ..writeByte(4)
      ..write(obj.releaseDate)
      ..writeByte(5)
      ..write(obj.runtime)
      ..writeByte(6)
      ..write(obj.poster)
      ..writeByte(7)
      ..write(obj.banner)
      ..writeByte(8)
      ..write(obj.sourceType)
      ..writeByte(9)
      ..write(obj.contentType)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.networks)
      ..writeByte(12)
      ..write(obj.movieUrl)
      ..writeByte(13)
      ..write(obj.seriesOrder)
      ..writeByte(14)
      ..write(obj.youtubeTrailer)
      ..writeByte(15)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NetworkDataAdapter extends TypeAdapter<NetworkData> {
  @override
  final int typeId = 2;

  @override
  NetworkData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NetworkData(
      id: fields[0] as int,
      name: fields[1] as String,
      logo: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NetworkData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.logo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
