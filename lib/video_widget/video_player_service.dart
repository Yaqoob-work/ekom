// lib/video_player_service.dart

// import 'package:media_kit/media_kit.dart';

// class VideoPlayerService {
//   // यह प्लेयर इंस्टेंस पूरी ऐप में शेयर किया जाएगा।
//   static final Player player = Player();
// }



import 'package:media_kit/media_kit.dart';

class VideoPlayerService {
  // ✅ Player configuration with the correct parameter name
  static final Player player = Player(
    configuration: const PlayerConfiguration(
      // The correct parameter is 'vo' (Video Output)
      // Set to 'gpu' to enable hardware acceleration
      vo: 'gpu',
      bufferSize: 15 * 1024 * 1024,
    ),
  );
}