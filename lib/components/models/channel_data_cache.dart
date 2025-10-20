import 'package:hive/hive.dart';
import 'content_item.dart'; // ContentItem को इम्पोर्ट करें

part 'channel_data_cache.g.dart'; // यह फाइल इस क्लास के लिए जेनरेट होगी

@HiveType(typeId: 0)
class ChannelDataCache extends HiveObject {
  @HiveField(0)
  late List<String> genres;

  @HiveField(1)
  late List<ContentItem> content;

  @HiveField(2)
  late DateTime timestamp;

  ChannelDataCache({
    required this.genres,
    required this.content,
    required this.timestamp,
  });
}