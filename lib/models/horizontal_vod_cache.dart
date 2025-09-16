import 'package:hive/hive.dart';
import 'horizontal_vod_model.dart'; // HorizontalVodModel को इम्पोर्ट करें

part 'horizontal_vod_cache.g.dart';

@HiveType(typeId: 4) // ✅ एक और यूनिक typeId
class HorizontalVodCache extends HiveObject {
 @HiveField(0)
 late List<HorizontalVodModel> vods;

 @HiveField(1)
 late DateTime timestamp;

 HorizontalVodCache({
 required this.vods,
 required this.timestamp,
 });
}