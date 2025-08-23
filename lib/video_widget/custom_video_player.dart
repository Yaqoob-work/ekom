// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:keep_screen_on/keep_screen_on.dart';
// // import 'package:mobi_tv_entertainment/main.dart';
// // import 'package:video_player/video_player.dart';
// // import 'dart:async';

// // class CustomVideoPlayer extends StatefulWidget {
// //   final String videoUrl;
// //   final List<String>? playlist;
// //   final int initialIndex;
  
// //   const CustomVideoPlayer({
// //     Key? key,
// //     required this.videoUrl,
// //     this.playlist,
// //     this.initialIndex = 0,
// //   }) : super(key: key);

// //   @override
// //   State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
// // }

// // class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
// //   late VideoPlayerController _controller;
// //   Timer? _timer;
// //   double _currentPosition = 0.0;
// //   double _totalDuration = 1.0;
// //   bool _isPlaying = false;
// //   bool _isInitialized = false;
// //   int _currentVideoIndex = 0;
// //   List<String> _videoUrls = [];
  
// //   // Enhanced seeking state management
// //   Timer? _seekTimer;
// //   Timer? _seekIndicatorTimer;
// //   int _pendingSeekSeconds = 0;
// //   Duration _targetSeekPosition = Duration.zero;
// //   bool _isSeeking = false;
// //   bool _isActuallySeekingVideo = false;
// //   bool _showSeekingIndicator = false;
// //   double _lastKnownPosition = 0.0;
  
// //   final FocusNode _mainFocusNode = FocusNode();
// //   bool _videoCompleted = false;
// //   bool _isNavigating = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     KeepScreenOn.turnOn();
// //     _currentVideoIndex = widget.initialIndex;
// //     _videoUrls = widget.playlist ?? [widget.videoUrl];
// //     _initializePlayer();
// //     _setFullScreen();
    
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _mainFocusNode.requestFocus();
// //     });
// //   }

// //   void _setFullScreen() {
// //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
// //     SystemChrome.setPreferredOrientations([
// //       DeviceOrientation.landscapeLeft,
// //       DeviceOrientation.landscapeRight,
// //     ]);
// //   }

// //   void _initializePlayer() async {
// //     String currentVideoUrl = _videoUrls[_currentVideoIndex];
    
// //     try {
// //       _controller = VideoPlayerController.networkUrl(Uri.parse(currentVideoUrl));
      
// //       await _controller.initialize();
      
// //       setState(() {
// //         _isInitialized = true;
// //         _totalDuration = _controller.value.duration.inSeconds.toDouble();
// //       });

// //       _controller.addListener(_playerListener);
// //       _controller.play();
// //       _startProgressTimer();
      
// //       print('✅ Video initialized successfully');
// //     } catch (error) {
// //       print('❌ Error initializing video: $error');
// //       // Handle initialization error
// //     }
// //   }

// //   void _playerListener() {
// //     if (_controller.value.isInitialized) {
// //       setState(() {
// //         _isPlaying = _controller.value.isPlaying;
// //         _totalDuration = _controller.value.duration.inSeconds.toDouble();
// //       });
      
// //       // Video end cut logic (same as YouTube player)
// //       if (_totalDuration > 30 && 
// //           _controller.value.position.inSeconds > 0 && 
// //           !_videoCompleted && 
// //           !_isNavigating) {
        
// //         final adjustedEndTime = _totalDuration.toInt() - 15;
        
// //         if (_controller.value.position.inSeconds >= adjustedEndTime) {
// //           print('🛑 Video reached cut point (15s before end) - completing video');
// //           _completeVideo();
// //         }
// //       }
// //     }
// //   }

// //   void _completeVideo() {
// //     if (_isNavigating || _videoCompleted) return;

// //     print('🎬 Video completing - 15 seconds before actual end');
// //     _videoCompleted = true;
// //     _isNavigating = true;

// //     if (_controller.value.isPlaying) {
// //       _controller.pause();
// //     }

// //     Future.delayed(const Duration(milliseconds: 500), () {
// //       if (mounted) {
// //         _playNextVideo();
// //       }
// //     });
// //   }

// //   void _resetVideoStates() {
// //     _isNavigating = false;
// //     _videoCompleted = false;
// //     _currentPosition = 0.0;
// //     _isSeeking = false;
// //     _isActuallySeekingVideo = false;
// //     _showSeekingIndicator = false;
// //     _pendingSeekSeconds = 0;
// //     _targetSeekPosition = Duration.zero;
// //   }

// //   void _startProgressTimer() {
// //     _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
// //       if (_controller.value.isInitialized) {
// //         final newPosition = _controller.value.position.inSeconds.toDouble();
        
// //         // If we're seeking, check if we've reached the target position
// //         if (_isActuallySeekingVideo && _targetSeekPosition != Duration.zero) {
// //           final targetPos = _targetSeekPosition.inSeconds.toDouble();
// //           final tolerance = 1.5; // 1.5 second tolerance
          
// //           if ((newPosition - targetPos).abs() <= tolerance) {
// //             // We've reached target position, reset all seeking states
// //             print('✅ Reached target position: ${newPosition}s (target was: ${targetPos}s)');
// //             setState(() {
// //               _currentPosition = newPosition;
// //               _lastKnownPosition = newPosition;
// //               _isActuallySeekingVideo = false;
// //               _isSeeking = false;
// //             });
// //             _pendingSeekSeconds = 0;
// //             _targetSeekPosition = Duration.zero;
// //           }
// //         } else if (!_isSeeking && !_isActuallySeekingVideo) {
// //           // Normal position update when not seeking at all
// //           setState(() {
// //             _currentPosition = newPosition;
// //             _lastKnownPosition = newPosition;
// //           });
// //         }
// //       }
// //     });
// //   }

// //   // Enhanced seeking with smooth progress bar
// //   void _seekVideo(bool forward) {
// //     if (_controller.value.isInitialized && _totalDuration > 30) {
// //       final adjustedEndTime = _totalDuration.toInt() - 15;
// //       final seekAmount = (adjustedEndTime / 200).round().clamp(5, 30);

// //       // Store current position before seeking starts (only if not already seeking)
// //       if (!_isSeeking && !_isActuallySeekingVideo) {
// //         _lastKnownPosition = _currentPosition;
// //       }

// //       _seekTimer?.cancel();

// //       // Calculate new pending seek
// //       if (forward) {
// //         _pendingSeekSeconds += seekAmount;
// //         print('⏩ Adding forward seek: +${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
// //       } else {
// //         _pendingSeekSeconds -= seekAmount;
// //         print('⏪ Adding backward seek: -${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
// //       }

// //       // Calculate target position - RESPECT END CUT BOUNDARY
// //       final targetSeconds = (_lastKnownPosition.toInt() + _pendingSeekSeconds)
// //           .clamp(0, adjustedEndTime);
// //       _targetSeekPosition = Duration(seconds: targetSeconds);

// //       // Show seeking state and indicator
// //       setState(() {
// //         _isSeeking = true;
// //         _showSeekingIndicator = true;
// //       });

// //       print('🎯 Target seek position: ${targetSeconds}s');

// //       // Set timer to execute actual seek
// //       _seekTimer = Timer(const Duration(milliseconds: 1000), () {
// //         _executeSeek();
// //       });

// //       // Set timer to hide seeking indicator after 3 seconds
// //       _seekIndicatorTimer?.cancel();
// //       _seekIndicatorTimer = Timer(const Duration(seconds: 3), () {
// //         if (mounted) {
// //           setState(() {
// //             _showSeekingIndicator = false;
// //           });
// //         }
// //       });
// //     }
// //   }

// //   void _executeSeek() {
// //     if (_controller.value.isInitialized && _pendingSeekSeconds != 0) {
// //       final targetSeconds = _targetSeekPosition.inSeconds;

// //       print('🎯 Executing accumulated seek to: ${targetSeconds}s');

// //       // Set flag to prevent position updates during seeking
// //       setState(() {
// //         _isActuallySeekingVideo = true;
// //         _currentPosition = targetSeconds.toDouble(); // Set target position
// //       });

// //       // Execute the actual video seek
// //       try {
// //         _controller.seekTo(Duration(seconds: targetSeconds));
// //         print('⏳ Seek command sent, waiting for video to reach target position...');
// //         // Don't reset states here - let the timer check when we actually reach the position
// //       } catch (error) {
// //         print('❌ Seek error: $error');
// //         // Reset on error
// //         setState(() {
// //           _isActuallySeekingVideo = false;
// //           _isSeeking = false;
// //         });
// //         _pendingSeekSeconds = 0;
// //         _targetSeekPosition = Duration.zero;
// //       }
// //     }
// //   }

// //   bool _handleKeyEvent(RawKeyEvent event) {
// //     if (event is RawKeyDownEvent) {
// //       switch (event.logicalKey) {
// //         case LogicalKeyboardKey.select:
// //         case LogicalKeyboardKey.enter:
// //         case LogicalKeyboardKey.space:
// //           _togglePlayPause();
// //           return true;

// //         case LogicalKeyboardKey.arrowLeft:
// //           _seekVideo(false);
// //           return true;

// //         case LogicalKeyboardKey.arrowRight:
// //           _seekVideo(true);
// //           return true;

// //         case LogicalKeyboardKey.escape:
// //         case LogicalKeyboardKey.backspace:
// //           Navigator.of(context).pop();
// //           return true;

// //         default:
// //           break;
// //       }
// //     }
// //     return false;
// //   }

// //   void _togglePlayPause() {
// //     if (_controller.value.isInitialized) {
// //       if (_isPlaying) {
// //         _controller.pause();
// //         print('⏸️ Video paused');
// //       } else {
// //         _controller.play();
// //         print('▶️ Video playing');
// //       }
// //     }
// //   }

// //   void _playNextVideo() {
// //     if (_currentVideoIndex < _videoUrls.length - 1) {
// //       setState(() {
// //         _currentVideoIndex++;
// //       });
// //       _resetVideoStates();
// //       _changeVideo(_videoUrls[_currentVideoIndex]);
// //     } else {
// //       print('📱 Playlist complete - exiting player');
// //       Navigator.of(context).pop();
// //     }
// //   }

// //   void _playPreviousVideo() {
// //     if (_currentVideoIndex > 0) {
// //       setState(() {
// //         _currentVideoIndex--;
// //       });
// //       _resetVideoStates();
// //       _changeVideo(_videoUrls[_currentVideoIndex]);
// //     }
// //   }

// //   void _changeVideo(String videoUrl) async {
// //     try {
// //       await _controller.dispose();
// //       _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
// //       await _controller.initialize();
      
// //       setState(() {
// //         _currentPosition = 0.0;
// //         _totalDuration = _controller.value.duration.inSeconds.toDouble();
// //         _isInitialized = true;
// //       });
      
// //       _controller.addListener(_playerListener);
// //       _controller.play();
// //     } catch (error) {
// //       print('❌ Error changing video: $error');
// //     }
// //   }

// //   String _formatDuration(double seconds) {
// //     int minutes = (seconds / 60).floor();
// //     int remainingSeconds = (seconds % 60).floor();
// //     return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
// //   }

// //   double get _adjustedTotalDuration {
// //     if (_totalDuration > 30) {
// //       return _totalDuration - 15;
// //     }
// //     return _totalDuration;
// //   }

// //   // Get display position for progress bar
// //   double get _displayPosition {
// //     if (_isSeeking || _isActuallySeekingVideo) {
// //       return _targetSeekPosition.inSeconds.toDouble();
// //     }
// //     return _currentPosition;
// //   }


// //   //   Widget _buildVideoPlayer() {
// //   //   if ( _controller == null) {
// //   //     return Center(child: CircularProgressIndicator());
// //   //   }

// //   //   // video_player needs a different approach to aspect ratio handling
// //   //   return LayoutBuilder(
// //   //     builder: (context, constraints) {
// //   //       // Get screen dimensions
// //   //       final screenWidth = constraints.maxWidth;
// //   //       final screenHeight = constraints.maxHeight;

// //   //       // Calculate aspect ratio from the controller
// //   //       // final videoAspectRatio = _controller!.value.aspectRatio;

// //   //       // Use AspectRatio widget to maintain correct proportions
// //   //       return Container(
// //   //         width: screenWidth,
// //   //         height: screenHeight,
// //   //         color: Colors.black,
// //   //         child: Center(
// //   //           child: AspectRatio(
// //   //             aspectRatio: 16 / 9,
// //   //             child: VideoPlayer(_controller),
// //   //           ),
// //   //         ),
// //   //       );
// //   //     },
// //   //   );
// //   // }



// // //   Widget _buildVideoPlayer() {
// // //   if (!_isInitialized) { // पहले चेक करें कि कंट्रोलर इनिशियलाइज़ है या नहीं
// // //     return const Center(child: CircularProgressIndicator());
// // //   }

// // //   return SizedBox.expand( // विजेट को पेरेंट के पूरे साइज में फैलाता है
// // //     child: FittedBox(
// // //       // BoxFit.cover वीडियो को पूरी स्क्रीन पर फैलाएगा।
// // //       // यह ऑरिजिनल एस्पेक्ट रेशियो बनाए रखेगा और जरूरत पड़ने पर वीडियो को थोड़ा क्रॉप कर सकता है।
// // //       fit: BoxFit.cover, 
// // //       child: SizedBox(
// // //         // वीडियो प्लेयर को उसका ऑरिजिनल साइज देना जरूरी है ताकि FittedBox सही से काम करे
// // //         width: _controller.value.size.width,
// // //         height: _controller.value.size.height,
// // //         child: VideoPlayer(_controller),
// // //       ),
// // //     ),
// // //   );
// // // }



// // // Widget _buildVideoPlayer() {
// // //   if (!_isInitialized) {
// // //     return const Center(child: CircularProgressIndicator());
// // //   }

// // //   return Container(
// // //     width: double.infinity,
// // //     height: double.infinity,
// // //     color: Colors.black,
// // //     child: Center(
// // //       child: AspectRatio(
// // //         aspectRatio: _controller.value.aspectRatio,
// // //         child: VideoPlayer(_controller),
// // //       ),
// // //     ),
// // //   );
// // // }



// // // // Alternative approach for true full-screen (may crop some content):
// // // Widget _buildVideoPlayer() {
// // //   if (!_isInitialized) {
// // //     return const Center(child: CircularProgressIndicator());
// // //   }

// // //   return SizedBox.expand(
// // //     child: FittedBox(
// // //       fit: BoxFit.cover, // This will fill entire screen, may crop video
// // //       child: SizedBox(
// // //         width: _controller.value.size.width,
// // //         height: _controller.value.size.height,
// // //         child: VideoPlayer(_controller),
// // //       ),
// // //     ),
// // //   );
// // // }




// // // Best approach - respects video aspect ratio while maximizing screen usage:
// // Widget _buildVideoPlayer() {
// //   if (!_isInitialized) {
// //     return const Center(child: CircularProgressIndicator());
// //   }

// //   return Container(
// //     width: double.infinity,
// //     height: double.infinity,
// //     color: Colors.black,
// //     child: FittedBox(
// //       fit: BoxFit.contain, // Maintains aspect ratio, fills as much as possible
// //       child: SizedBox(
// //         width: _controller.value.size.width,
// //         height: _controller.value.size.height,
// //         child: VideoPlayer(_controller),
// //       ),
// //     ),
// //   );
// // }

// //   @override
// //   Widget build(BuildContext context) {
// //     final screenHeight = MediaQuery.of(context).size.height;
    
// //     return RawKeyboardListener(
// //       focusNode: _mainFocusNode,
// //       autofocus: true,
// //       onKey: _handleKeyEvent,
// //       child: Scaffold(
// //         backgroundColor: Colors.black,
// //         body: Stack(
// //           children: [
// //             // Full Screen Video Player
// //             if (_isInitialized)
// //               // SizedBox.expand(
// //               //   child: FittedBox(
// //               //     fit: BoxFit.cover,
// //               //     child: SizedBox(
// //               //       width: screenwdt,
// //               //       height:screenhgt,
// //               //       child: VideoPlayer(_controller),
// //               //     ),
// //               //   ),
// //               // )
// //               _buildVideoPlayer()
// //             else
// //               const Center(
// //                 child: CircularProgressIndicator(
// //                   color: Colors.red,
// //                 ),
// //               ),

// //             // // Top black bar
// //             // Positioned(
// //             //   top: 0,
// //             //   left: 0,
// //             //   right: 0,
// //             //   child: Container(
// //             //     color: Colors.black,
// //             //     height: screenHeight * 0.1,
// //             //   ),
// //             // ),

// //             // // Bottom Progress Bar - ENHANCED
// //             // Positioned(
// //             //   bottom: 0,
// //             //   left: 0,
// //             //   right: 0,
// //             //   child: Container(
// //             //     color: Colors.black,
// //             //     height: screenHeight * 0.1,
// //             //     child: Row(
// //             //       children: [
// //             //         // Current time display
// //             //         Padding(
// //             //           padding: const EdgeInsets.only(left: 16.0),
// //             //           child: Text(
// //             //             _formatDuration(_displayPosition),
// //             //             style: TextStyle(
// //             //               color: _isSeeking ? Colors.yellow : Colors.white,
// //             //               fontSize: 12,
// //             //               fontWeight: _isSeeking ? FontWeight.bold : FontWeight.normal,
// //             //             ),
// //             //           ),
// //             //         ),
                    
// //             //         // Enhanced Progress slider
// //             //         Expanded(
// //             //           child: Padding(
// //             //             padding: const EdgeInsets.symmetric(horizontal: 12.0),
// //             //             child: SliderTheme(
// //             //               data: SliderTheme.of(context).copyWith(
// //             //                 activeTrackColor: (_isSeeking || _isActuallySeekingVideo) ? Colors.yellow : Colors.red,
// //             //                 inactiveTrackColor: Colors.white.withOpacity(0.3),
// //             //                 thumbColor: (_isSeeking || _isActuallySeekingVideo) ? Colors.yellow : Colors.red,
// //             //                 thumbShape: RoundSliderThumbShape(
// //             //                   enabledThumbRadius: (_isSeeking || _isActuallySeekingVideo) ? 8.0 : 6.0,
// //             //                 ),
// //             //                 trackHeight: (_isSeeking || _isActuallySeekingVideo) ? 4.0 : 3.0,
// //             //                 overlayShape: const RoundSliderOverlayShape(
// //             //                   overlayRadius: 12.0,
// //             //                 ),
// //             //               ),
// //             //               child: Slider(
// //             //                 value: _displayPosition.clamp(0.0, _adjustedTotalDuration),
// //             //                 max: _adjustedTotalDuration,
// //             //                 onChanged: (value) {
// //             //                   if (!(_isSeeking || _isActuallySeekingVideo)) { // Only allow manual seeking when not in any seeking state
// //             //                     final adjustedEndTime = _totalDuration - 15;
// //             //                     final clampedValue = value.clamp(0.0, adjustedEndTime);
// //             //                     setState(() {
// //             //                       _isActuallySeekingVideo = true;
// //             //                       _currentPosition = clampedValue;
// //             //                     });
// //             //                     _controller.seekTo(Duration(seconds: clampedValue.toInt()));
// //             //                     // Don't use timer for manual seeking - reset immediately after seek completes
// //             //                     Future.delayed(const Duration(milliseconds: 200), () {
// //             //                       if (mounted) {
// //             //                         setState(() {
// //             //                           _isActuallySeekingVideo = false;
// //             //                         });
// //             //                       }
// //             //                     });
// //             //                   }
// //             //                 },
// //             //               ),
// //             //             ),
// //             //           ),
// //             //         ),
                    
// //             //         // Total duration display
// //             //         Padding(
// //             //           padding: const EdgeInsets.only(right: 16.0),
// //             //           child: Text(
// //             //             _formatDuration(_adjustedTotalDuration),
// //             //             style: const TextStyle(color: Colors.white, fontSize: 12),
// //             //           ),
// //             //         ),
// //             //       ],
// //             //     ),
// //             //   ),
// //             // ),

// //             // // Enhanced seeking indicator - Show for 3 seconds
// //             // if (_showSeekingIndicator)
// //             //   Positioned(
// //             //     top: screenHeight * 0.4,
// //             //     left: 0,
// //             //     right: 0,
// //             //     child: Center(
// //             //       child: Container(
// //             //         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
// //             //         decoration: BoxDecoration(
// //             //           color: Colors.black.withOpacity(0.9),
// //             //           borderRadius: BorderRadius.circular(25),
// //             //           border: Border.all(color: Colors.yellow, width: 2),
// //             //         ),
// //             //         child: Column(
// //             //           mainAxisSize: MainAxisSize.min,
// //             //           children: [
// //             //             Text(
// //             //               '${_pendingSeekSeconds > 0 ? "⏩ +" : "⏪ "}${_pendingSeekSeconds}s',
// //             //               style: const TextStyle(
// //             //                 color: Colors.yellow,
// //             //                 fontSize: 20,
// //             //                 fontWeight: FontWeight.bold,
// //             //               ),
// //             //             ),
// //             //             const SizedBox(height: 4),
// //             //             Text(
// //             //               _formatDuration(_targetSeekPosition.inSeconds.toDouble()),
// //             //               style: const TextStyle(
// //             //                 color: Colors.white,
// //             //                 fontSize: 14,
// //             //               ),
// //             //             ),
// //             //           ],
// //             //         ),
// //             //       ),
// //             //     ),
// //             //   ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _timer?.cancel();
// //     _seekTimer?.cancel();
// //     _seekIndicatorTimer?.cancel();
// //     _controller.dispose();
// //     _mainFocusNode.dispose();
    
// //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
// //     SystemChrome.setPreferredOrientations([
// //       DeviceOrientation.portraitUp,
// //       DeviceOrientation.portraitDown,
// //       DeviceOrientation.landscapeLeft,
// //       DeviceOrientation.landscapeRight,
// //     ]);
// //     KeepScreenOn.turnOff();
// //     super.dispose();
// //   }
// // }




// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:chewie/chewie.dart';
// import 'package:video_player/video_player.dart';
// import 'package:keep_screen_on/keep_screen_on.dart';
// import 'dart:async';

// class CustomVideoPlayer extends StatefulWidget {
//   final String videoUrl;
//   final List<String>? playlist;
//   final int initialIndex;
  
//   const CustomVideoPlayer({
//     Key? key,
//     required this.videoUrl,
//     this.playlist,
//     this.initialIndex = 0,
//   }) : super(key: key);

//   @override
//   State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
// }

// class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
//   late VideoPlayerController _videoPlayerController;
//   ChewieController? _chewieController;
//   Timer? _timer;
//   int _currentVideoIndex = 0;
//   List<String> _videoUrls = [];
//   bool _isInitialized = false;
//   bool _videoCompleted = false;
//   bool _isNavigating = false;
  
//   // Seeking state management
//   Timer? _seekTimer;
//   Timer? _seekIndicatorTimer;
//   int _pendingSeekSeconds = 0;
//   Duration _targetSeekPosition = Duration.zero;
//   bool _isSeeking = false;
//   bool _showSeekingIndicator = false;
//   double _lastKnownPosition = 0.0;
  
//   final FocusNode _mainFocusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     KeepScreenOn.turnOn();
//     _currentVideoIndex = widget.initialIndex;
//     _videoUrls = widget.playlist ?? [widget.videoUrl];
//     _initializePlayer();
//     _setFullScreen();
    
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _mainFocusNode.requestFocus();
//     });
//   }

//   void _setFullScreen() {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//   }

//   void _initializePlayer() async {
//     String currentVideoUrl = _videoUrls[_currentVideoIndex];
    
//     try {
//       _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(currentVideoUrl));
//       await _videoPlayerController.initialize();
      
//       _chewieController = ChewieController(
//         videoPlayerController: _videoPlayerController,
//         autoPlay: true,
//         looping: false,
//         fullScreenByDefault: true,
//         allowFullScreen: true,
//         allowMuting: true,
//         allowPlaybackSpeedChanging: false,
//         showControls: true,
//         showControlsOnInitialize: false,
//         controlsSafeAreaMinimum: const EdgeInsets.all(12.0),
//         hideControlsTimer: const Duration(seconds: 3),
        
//         // Custom colors
//         materialProgressColors: ChewieProgressColors(
//           playedColor: Colors.red,
//           handleColor: Colors.red,
//           backgroundColor: Colors.white.withOpacity(0.3),
//           bufferedColor: Colors.white.withOpacity(0.5),
//         ),
        
//         // Additional options
//         optionsTranslation: OptionsTranslation(
//           playbackSpeedButtonText: 'Playback speed',
//           subtitlesButtonText: 'Subtitles',
//           cancelButtonText: 'Cancel',
//         ),
        
//         // Custom aspect ratio
//         aspectRatio: 16/9,
        
//         // Error builder
//         errorBuilder: (context, errorMessage) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.error, color: Colors.red, size: 60),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Error playing video: $errorMessage',
//                   style: const TextStyle(color: Colors.white),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           );
//         },
//       );

//       _videoPlayerController.addListener(_playerListener);
//       _startProgressTimer();
      
//       setState(() {
//         _isInitialized = true;
//       });
      
//       print('✅ Chewie video initialized successfully');
//     } catch (error) {
//       print('❌ Error initializing Chewie video: $error');
//     }
//   }

//   void _playerListener() {
//     if (_videoPlayerController.value.isInitialized) {
//       final duration = _videoPlayerController.value.duration.inSeconds.toDouble();
//       final position = _videoPlayerController.value.position.inSeconds.toDouble();
      
//       // Video end cut logic (15 seconds before end)
//       if (duration > 30 && 
//           position > 0 && 
//           !_videoCompleted && 
//           !_isNavigating) {
        
//         final adjustedEndTime = duration - 15;
        
//         if (position >= adjustedEndTime) {
//           print('🛑 Video reached cut point (15s before end)');
//           _completeVideo();
//         }
//       }
//     }
//   }

//   void _completeVideo() {
//     if (_isNavigating || _videoCompleted) return;

//     print('🎬 Video completing - 15 seconds before actual end');
//     _videoCompleted = true;
//     _isNavigating = true;

//     if (_videoPlayerController.value.isPlaying) {
//       _videoPlayerController.pause();
//     }

//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (mounted) {
//         _playNextVideo();
//       }
//     });
//   }

//   void _resetVideoStates() {
//     _isNavigating = false;
//     _videoCompleted = false;
//     _isSeeking = false;
//     _showSeekingIndicator = false;
//     _pendingSeekSeconds = 0;
//     _targetSeekPosition = Duration.zero;
//   }

//   void _startProgressTimer() {
//     _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
//       if (_videoPlayerController.value.isInitialized && !_isSeeking) {
//         _lastKnownPosition = _videoPlayerController.value.position.inSeconds.toDouble();
//       }
//     });
//   }

//   // Enhanced seeking functionality
//   void _seekVideo(bool forward) {
//     if (_videoPlayerController.value.isInitialized) {
//       final duration = _videoPlayerController.value.duration.inSeconds.toDouble();
//       if (duration <= 30) return;
      
//       final adjustedEndTime = duration - 15;
//       final seekAmount = (adjustedEndTime / 200).round().clamp(5, 30);

//       _seekTimer?.cancel();

//       if (forward) {
//         _pendingSeekSeconds += seekAmount;
//       } else {
//         _pendingSeekSeconds -= seekAmount;
//       }

//       final targetSeconds = (_lastKnownPosition.toInt() + _pendingSeekSeconds)
//           .clamp(0, adjustedEndTime.toInt());
//       _targetSeekPosition = Duration(seconds: targetSeconds);

//       setState(() {
//         _isSeeking = true;
//         _showSeekingIndicator = true;
//       });

//       print('🎯 Target seek position: ${targetSeconds}s');

//       _seekTimer = Timer(const Duration(milliseconds: 800), () {
//         _executeSeek();
//       });

//       _seekIndicatorTimer?.cancel();
//       _seekIndicatorTimer = Timer(const Duration(seconds: 2), () {
//         if (mounted) {
//           setState(() {
//             _showSeekingIndicator = false;
//           });
//         }
//       });
//     }
//   }

//   void _executeSeek() {
//     if (_videoPlayerController.value.isInitialized && _pendingSeekSeconds != 0) {
//       final targetSeconds = _targetSeekPosition.inSeconds;
      
//       print('🎯 Executing seek to: ${targetSeconds}s');
      
//       try {
//         _videoPlayerController.seekTo(Duration(seconds: targetSeconds));
//         Future.delayed(const Duration(milliseconds: 500), () {
//           if (mounted) {
//             setState(() {
//               _isSeeking = false;
//             });
//             _pendingSeekSeconds = 0;
//             _targetSeekPosition = Duration.zero;
//           }
//         });
//       } catch (error) {
//         print('❌ Seek error: $error');
//         setState(() {
//           _isSeeking = false;
//         });
//         _pendingSeekSeconds = 0;
//         _targetSeekPosition = Duration.zero;
//       }
//     }
//   }

//   bool _handleKeyEvent(RawKeyEvent event) {
//     if (event is RawKeyDownEvent) {
//       switch (event.logicalKey) {
//         case LogicalKeyboardKey.select:
//         case LogicalKeyboardKey.enter:
//         case LogicalKeyboardKey.space:
//           _togglePlayPause();
//           return true;

//         case LogicalKeyboardKey.arrowLeft:
//           _seekVideo(false);
//           return true;

//         case LogicalKeyboardKey.arrowRight:
//           _seekVideo(true);
//           return true;

//         case LogicalKeyboardKey.escape:
//         case LogicalKeyboardKey.backspace:
//           Navigator.of(context).pop();
//           return true;

//         case LogicalKeyboardKey.arrowUp:
//           if (_currentVideoIndex > 0) {
//             _playPreviousVideo();
//           }
//           return true;

//         case LogicalKeyboardKey.arrowDown:
//           if (_currentVideoIndex < _videoUrls.length - 1) {
//             _playNextVideo();
//           }
//           return true;

//         default:
//           break;
//       }
//     }
//     return false;
//   }

//   void _togglePlayPause() {
//     if (_videoPlayerController.value.isInitialized) {
//       if (_videoPlayerController.value.isPlaying) {
//         _videoPlayerController.pause();
//         print('⏸️ Video paused');
//       } else {
//         _videoPlayerController.play();
//         print('▶️ Video playing');
//       }
//     }
//   }

//   void _playNextVideo() {
//     if (_currentVideoIndex < _videoUrls.length - 1) {
//       setState(() {
//         _currentVideoIndex++;
//       });
//       _resetVideoStates();
//       _changeVideo(_videoUrls[_currentVideoIndex]);
//     } else {
//       print('📱 Playlist complete - exiting player');
//       Navigator.of(context).pop();
//     }
//   }

//   void _playPreviousVideo() {
//     if (_currentVideoIndex > 0) {
//       setState(() {
//         _currentVideoIndex--;
//       });
//       _resetVideoStates();
//       _changeVideo(_videoUrls[_currentVideoIndex]);
//     }
//   }

//   void _changeVideo(String videoUrl) async {
//     try {
//       // Dispose current controllers
//       _chewieController?.dispose();
//       await _videoPlayerController.dispose();
      
//       // Initialize new video
//       _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
//       await _videoPlayerController.initialize();
      
//       _chewieController = ChewieController(
//         videoPlayerController: _videoPlayerController,
//         autoPlay: true,
//         looping: false,
//         fullScreenByDefault: true,
//         allowFullScreen: true,
//         allowMuting: true,
//         showControls: true,
//         showControlsOnInitialize: false,
//         controlsSafeAreaMinimum: const EdgeInsets.all(12.0),
//         hideControlsTimer: const Duration(seconds: 3),
//         materialProgressColors: ChewieProgressColors(
//           playedColor: Colors.red,
//           handleColor: Colors.red,
//           backgroundColor: Colors.white.withOpacity(0.3),
//           bufferedColor: Colors.white.withOpacity(0.5),
//         ),
//         aspectRatio: 16/9,
//       );
      
//       _videoPlayerController.addListener(_playerListener);
      
//       setState(() {
//         _isInitialized = true;
//       });
      
//       print('✅ Video changed successfully');
//     } catch (error) {
//       print('❌ Error changing video: $error');
//     }
//   }

//   String _formatDuration(double seconds) {
//     int minutes = (seconds / 60).floor();
//     int remainingSeconds = (seconds % 60).floor();
//     return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
    
//     return RawKeyboardListener(
//       focusNode: _mainFocusNode,
//       autofocus: true,
//       onKey: _handleKeyEvent,
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: Stack(
//           children: [
//             // Chewie Video Player
//             if (_isInitialized && _chewieController != null)
//               Center(
//                 child: Chewie(
//                   controller: _chewieController!,
//                 ),
//               )
//             else
//               const Center(
//                 child: CircularProgressIndicator(
//                   color: Colors.red,
//                 ),
//               ),

//             // Enhanced seeking indicator
//             if (_showSeekingIndicator)
//               Positioned(
//                 top: screenHeight * 0.4,
//                 left: 0,
//                 right: 0,
//                 child: Center(
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.9),
//                       borderRadius: BorderRadius.circular(25),
//                       border: Border.all(color: Colors.yellow, width: 2),
//                     ),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           '${_pendingSeekSeconds > 0 ? "⏩ +" : "⏪ "}${_pendingSeekSeconds}s',
//                           style: const TextStyle(
//                             color: Colors.yellow,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           _formatDuration(_targetSeekPosition.inSeconds.toDouble()),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//             // Playlist info overlay
//             if (_videoUrls.length > 1)
//               Positioned(
//                 top: 20,
//                 right: 20,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.7),
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Text(
//                     '${_currentVideoIndex + 1}/${_videoUrls.length}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),

//             // Control hints overlay (show for first 5 seconds)
//             // You can add this if needed
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _seekTimer?.cancel();
//     _seekIndicatorTimer?.cancel();
//     _chewieController?.dispose();
//     _videoPlayerController.dispose();
//     _mainFocusNode.dispose();
    
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//     KeepScreenOn.turnOff();
//     super.dispose();
//   }
// }

// // Usage example:
// // CustomVideoPlayer(
// //   videoUrl: 'https://example.com/video.mp4',
// //   playlist: [
// //     'https://example.com/video1.mp4',
// //     'https://example.com/video2.mp4',
// //     'https://example.com/video3.mp4',
// //   ],
// //   initialIndex: 0,
// // )







import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:keep_screen_on/keep_screen_on.dart';

/// Un reproductor de video simple y de pantalla completa.
///
/// Este widget solo requiere una [videoUrl] para reproducir un video.
/// Controla la reproducción con las teclas de flecha (adelantar/retroceder) y
/// la tecla Enter (reproducir/pausar).
class CustomVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const CustomVideoPlayer({super.key, required this.videoUrl});

  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> with WidgetsBindingObserver {
  VlcPlayerController? _controller;
  bool _controlsVisible = true;
  late Timer _hideControlsTimer;
  bool _isBuffering = false;
  bool _isVideoInitialized = false;
  final FocusNode screenFocusNode = FocusNode();
      bool _isDisposing = false;
  bool _isDisposed = false;
  
  // Para la barra de progreso
  double _progress = 0.0;

  // Para la funcionalidad de búsqueda (adelantar/retroceder)
  int _accumulatedSeekForward = 0;
  int _accumulatedSeekBackward = 0;
  Timer? _seekTimer;
  Duration _previewPosition = Duration.zero;
  final int _seekDuration = 10; // segundos
  final int _seekDelay = 1000; // milisegundos

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    KeepScreenOn.turnOn(); // Mantiene la pantalla encendida

    // Inicializa el reproductor de video
    _initializeVLCController();

    // Inicia un temporizador para ocultar los controles después de un tiempo
    _startHideControlsTimer();
    
    // Solicita el foco para poder recibir eventos del teclado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(screenFocusNode);
    });
  }
  
  /// Listener para los cambios de estado del reproductor VLC
  void _vlcListener() {
    if (!mounted || _controller == null || !_controller!.value.isInitialized) return;

    final isBuffering = _controller!.value.isBuffering;
    final position = _controller!.value.position;
    final duration = _controller!.value.duration;

    if (mounted) {
      setState(() {
        _isBuffering = isBuffering;
        if (duration > Duration.zero) {
           _progress = position.inMilliseconds / duration.inMilliseconds;
        }
      });
    }
  }

  /// Inicializa el controlador VLC con la URL del video proporcionada
  Future<void> _initializeVLCController() async {
    setState(() {
      _isBuffering = true;
    });

    // Añade opciones de caché a la URL para un mejor rendimiento
    String modifiedUrl = '${widget.videoUrl}?network-caching=5000&live-caching=500&rtsp-tcp';

    _controller = VlcPlayerController.network(
      modifiedUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        video: VlcVideoOptions([
          VlcVideoOptions.dropLateFrames(true),
          VlcVideoOptions.skipFrames(true),
        ]),
      ),
    );

    // await _controller!.initialize();
    // _controller!.addListener(_vlcListener);

    // setState(() {
    //   _isVideoInitialized = true;
    //   _isBuffering = false;
    // });


      try {
     _controller!.initialize();
     await _retryPlayback(modifiedUrl, 5);
      if (_controller!.value.isInitialized) {
    _controller!.play();
  } else {
    print("Controller failed to initialize.");
  }

    _controller!.addListener(_vlcListener);


    if (mounted) {
      setState(() {
        _isVideoInitialized = true;
        _isBuffering = false;
      });
    }
  } catch (e) {
    // This will catch the actual error and print it
    print("Error initializing VLC controller: $e");
    
    if (mounted) {
      // You can optionally show an error message on the screen
      setState(() {
        _isBuffering = false;
        // You could add an error flag here to show a message in the UI
      });
    }
  }
  }



  
  Future<void> _retryPlayback(String url, int retries) async {
    for (int i = 0; i < retries; i++) {
      if (!mounted || !_controller!.value.isInitialized) return;

      try {
        await _controller!.setMediaFromNetwork(url);
        // Add position seeking after successful playback start

        // await _controller!.play();

        _controller!.addListener(() async {

        });

        return; // Exit on success
      } catch (e) {
        print("Retry ${i + 1} failed: $e");
        await Future.delayed(Duration(seconds: 1));
      }
    }
    print("All retries failed for URL: $url");
  }


  // @override
  // void dispose() {
  //   WidgetsBinding.instance.removeObserver(this);
  //   KeepScreenOn.turnOff();
    
  //   _hideControlsTimer.cancel();
  //   _seekTimer?.cancel();
  //   screenFocusNode.dispose();
    
  //   _controller?.removeListener(_vlcListener);
  //   _controller?.stop();
  //   _controller?.dispose();
    
  //   super.dispose();
  // }


  // आपके dispose() method को इससे replace करें:
@override
void dispose() {
  // Screen को ऑन रखने वाली सुविधा बंद करें
  KeepScreenOn.turnOff();
  
  // सभी Dart objects को पहले dispose करें
  _hideControlsTimer.cancel();
  _seekTimer?.cancel();
  screenFocusNode.dispose();
  
  // VLC controller को अंत में dispose करें, बिना async/await के
  _controller?.removeListener(_vlcListener);
  _controller?.stop();
  _controller?.dispose();
  
  WidgetsBinding.instance.removeObserver(this);
  super.dispose();
}

  /// Temporizador para ocultar automáticamente los controles después de 5 segundos de inactividad
  void _startHideControlsTimer() {
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  /// Reinicia el temporizador y muestra los controles
  void _resetHideControlsTimer() {
    _hideControlsTimer.cancel();
    if (mounted && !_controlsVisible) {
      setState(() {
        _controlsVisible = true;
      });
    }
    _startHideControlsTimer();
  }
  
  /// Alterna entre los estados de reproducción y pausa
  void _togglePlayPause() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
    _resetHideControlsTimer();
  }

  /// Lógica para adelantar el video
  void _seekForward() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    _resetHideControlsTimer();

    setState(() {
      _accumulatedSeekForward += _seekDuration;
      _previewPosition = _controller!.value.position + Duration(seconds: _accumulatedSeekForward);
      if (_previewPosition > _controller!.value.duration) {
        _previewPosition = _controller!.value.duration;
      }
    });

    _seekTimer?.cancel();
    _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
      if (_controller != null) {
        _controller!.seekTo(_previewPosition);
        setState(() {
          _accumulatedSeekForward = 0;
        });
      }
    });
  }

  /// Lógica para retroceder el video
  void _seekBackward() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    _resetHideControlsTimer();

    setState(() {
      _accumulatedSeekBackward += _seekDuration;
      final newPosition = _controller!.value.position - Duration(seconds: _accumulatedSeekBackward);
      _previewPosition = newPosition > Duration.zero ? newPosition : Duration.zero;
    });

    _seekTimer?.cancel();
    _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
      if (_controller != null) {
        _controller!.seekTo(_previewPosition);
        setState(() {
          _accumulatedSeekBackward = 0;
        });
      }
    });
  }

  /// Maneja las entradas del teclado para el control remoto
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      _resetHideControlsTimer(); // Muestra los controles con cualquier pulsación

      switch (event.logicalKey) {

        case LogicalKeyboardKey.escape:
        case LogicalKeyboardKey.backspace:
        case LogicalKeyboardKey.goBack:
        if (_isDisposing || _isDisposed) return;
        _startSafeDisposal();
        Navigator.of(context).pop();
        break;

        case LogicalKeyboardKey.select:
        case LogicalKeyboardKey.enter:
          _togglePlayPause();
          break;
        case LogicalKeyboardKey.arrowRight:
          _seekForward();
          break;
        case LogicalKeyboardKey.arrowLeft:
          _seekBackward();
          break;
      }
    }
  }

  /// Formatea una [Duration] a un string legible (ej. 01:23:45 o 23:45)
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : '';
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours$minutes:$seconds';
  }



// आपके CustomVideoPlayer class में ये methods add करें:

void _startSafeDisposal() {
  if (_isDisposing || _isDisposed) return;
  
  print('Starting safe disposal for CustomVideoPlayer...');
  setState(() {
    _isDisposing = true;
  });

  // सभी टाइमर्स को रद्द करें
  _hideControlsTimer.cancel();
  _seekTimer?.cancel();
  
  // कंट्रोलर को बैकग्राउंड में डिस्पोज़ करें
  _disposeControllerInBackground();
}

void _disposeControllerInBackground() {
  // Future.microtask यह सुनिश्चित करता है कि यह काम UI थ्रेड को ब्लॉक किए बिना हो
  Future.microtask(() async {
    print('Background controller disposal started...');
    try {
      if (_controller != null) {
        _controller?.removeListener(_vlcListener);
        // टाइमआउट के साथ स्टॉप और डिस्पोज़ करें ताकि ऐप अटके नहीं
        await _controller?.stop().timeout(const Duration(seconds: 2));
        await _controller?.dispose().timeout(const Duration(seconds: 2));
        print('VLC Controller disposed successfully in background.');
      }
    } catch (e) {
      print('Error during background controller disposal: $e');
    } finally {
      // सुनिश्चित करें कि नियंत्रक को अंत में null पर सेट किया गया है
      _controller = null; 
      _isDisposed = true;
    }
  });
}



  @override
  Widget build(BuildContext context) {
    return
        WillPopScope(
    onWillPop: () async {
      // अगर पहले से डिस्पोज़ हो रहा है तो कुछ न करें
      if (_isDisposing || _isDisposed) {
        return true; 
      }
      
      // सुरक्षित डिस्पोज़ल प्रक्रिया शुरू करें
      _startSafeDisposal();
      
      // Flutter को तुरंत स्क्रीन बंद करने की अनुमति दें
      return true;
    },
    child:
     Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        focusNode: screenFocusNode,
        autofocus: true,
        onKey: (node, event) {
          _handleKeyEvent(event);
          return KeyEventResult.handled;
        },
        child: GestureDetector(
          onTap: _resetHideControlsTimer,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Widget del reproductor de video
              if (_isVideoInitialized && _controller != null)
                Center(
                  child: VlcPlayer(
                    controller: _controller!,
                    aspectRatio: 16 / 9,
                    placeholder: const Center(child: CircularProgressIndicator()),
                  ),
                ),

              // Indicador de carga/buffering
              if (_isBuffering || !_isVideoInitialized)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),

              // Superposición de controles
              AnimatedOpacity(
                opacity: _controlsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: AbsorbPointer(
                  absorbing: !_controlsVisible,
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    child: Stack(
                      children: [
                        // Botón de Play/Pause centrado
                        Center(
                           child: IconButton(
                            icon: Icon(
                              _controller?.value.isPlaying ?? false
                                ? Icons.pause_circle_outline
                                : Icons.play_circle_outline,
                              color: Colors.white,
                              size: 64,
                            ),
                            onPressed: _togglePlayPause,
                          ),
                        ),
                        // Controles inferiores (Barra de progreso y tiempo)
                        _buildBottomControls(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  /// Construye la barra de control inferior con el progreso y el tiempo
  Widget _buildBottomControls() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           LinearProgressIndicator(
             value: _progress.isNaN ? 0.0 : _progress,
             backgroundColor: Colors.white.withOpacity(0.3),
             valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                _formatDuration(_controller?.value.position ?? Duration.zero),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const Spacer(),
              Text(
                _formatDuration(_controller?.value.duration ?? Duration.zero),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}