// अपनी मॉडल फ़ाइल में यह जोड़ें (उदा. lib/models/horizontal_vod_model.dart)
import 'package:hive/hive.dart';

// यह लाइन जेनरेट होने वाली फ़ाइल के लिए है
part 'horizontal_vod_model.g.dart';

@HiveType(typeId: 3) // ✅ एक यूनिक typeId दें
class HorizontalVodModel {
 @HiveField(0)
 final int id;
 @HiveField(1)
 final String name;
 @HiveField(2)
 final String? description;
 @HiveField(3)
 final String? logo;
 @HiveField(4)
 final String? releaseDate;
 @HiveField(5)
 final String? genres;
 @HiveField(6)
 final String? rating;
 @HiveField(7)
 final String? language;
 @HiveField(8)
 final int status;
 @HiveField(9)
 final int networks_order;

 HorizontalVodModel({
 required this.id,
 required this.name,
 this.description,
 this.logo,
 this.releaseDate,
 this.genres,
 this.rating,
 this.language,
 required this.status,
 required this.networks_order,
 });

 // fromJson फैक्ट्री वैसी ही रहेगी, क्योंकि हमें API से डेटा पार्स करना है
 factory HorizontalVodModel.fromJson(Map<String, dynamic> json) {
 return HorizontalVodModel(
 id: json['id'] ?? 0,
 name: json['name'] ?? '',
 description: json['description'],
 logo: json['logo'],
 releaseDate: json['release_date'],
 genres: json['genres'],
 rating: json['rating'],
 language: json['language'],
 status: json['status'] ?? 0,
 networks_order: json['networks_order'] ?? 999,
 );
 }
}