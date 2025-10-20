import 'package:hive/hive.dart';

part 'content_item.g.dart'; // यह फाइल इस क्लास के लिए जेनरेट होगी

@HiveType(typeId: 1)
class ContentItem {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String genres;

  @HiveField(4)
  final String? releaseDate;

  @HiveField(5)
  final int? runtime;

  @HiveField(6)
  final String? poster;

  @HiveField(7)
  final String? banner;

  @HiveField(8)
  final String? sourceType;

  @HiveField(9)
  final int contentType;

  @HiveField(10)
  final int status;

  @HiveField(11)
  final List<NetworkData> networks;

  @HiveField(12)
  final String? movieUrl;

  @HiveField(13)
  final int? seriesOrder;

  @HiveField(14)
  final String? youtubeTrailer;

  @HiveField(15)
  final String updatedAt;

  ContentItem({
    required this.id,
    required this.name,
    required this.updatedAt,
    this.description,
    required this.genres,
    this.releaseDate,
    this.runtime,
    this.poster,
    this.banner,
    this.sourceType,
    required this.contentType,
    required this.status,
    required this.networks,
    this.movieUrl,
    this.seriesOrder,
    this.youtubeTrailer,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    List<NetworkData> networksList = [];
    if (json['networks'] != null && json['networks'] is List) {
      for (var network in json['networks']) {
        networksList.add(NetworkData.fromJson(network));
      }
    }

    return ContentItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      description: json['description'],
      genres: json['genres'] ?? '',
      releaseDate: json['release_date'],
      runtime: json['runtime'],
      poster: json['poster'],
      banner: json['banner'],
      sourceType: json['source_type'],
      contentType: json['content_type'] ?? 1,
      status: json['status'] ?? 0,
      networks: networksList,
      movieUrl: json['movie_url'],
      seriesOrder: json['series_order'],
      youtubeTrailer: json['youtube_trailer'],
    );
  }

  String? getPlayableUrl() {
    if (contentType == 1 && movieUrl != null && movieUrl!.isNotEmpty) {
      return movieUrl;
    }
    if (contentType == 2) {
      if (youtubeTrailer != null && youtubeTrailer!.isNotEmpty) {
        return youtubeTrailer;
      }
      return null;
    }
    return movieUrl;
  }

  String get contentTypeName {
    switch (contentType) {
      case 1:
        return 'Movie';
      case 2:
        return 'Web Series';
      default:
        return 'Unknown';
    }
  }
}

@HiveType(typeId: 2)
class NetworkData {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String logo;

  NetworkData({
    required this.id,
    required this.name,
    required this.logo,
  });
  
  factory NetworkData.fromJson(Map<String, dynamic> json) {
    return NetworkData(
      id: json['id'] ?? 0, 
      name: json['name'] ?? '', 
      logo: json['logo'] ?? '',
    );
  }
}