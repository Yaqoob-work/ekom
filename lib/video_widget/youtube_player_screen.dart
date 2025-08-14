
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:keep_screen_on/keep_screen_on.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// import 'dart:async';

// // Video Model
// class VideoData {
//   final String id;
//   final String title;
//   final String youtubeUrl;
//   final String thumbnail;
//   final String description;

//   VideoData({
//     required this.id,
//     required this.title,
//     required this.youtubeUrl,
//     this.thumbnail = '',
//     this.description = '',
//   });
// }

// // Direct YouTube Player Screen - No Home Page Required
// class YouTubePlayerScreen extends StatefulWidget {
//   final VideoData videoData;
//   final List<VideoData> playlist;

//   const YouTubePlayerScreen({
//     Key? key,
//     required this.videoData,
//     required this.playlist,
//   }) : super(key: key);

//   @override
//   _YouTubePlayerScreenState createState() => _YouTubePlayerScreenState();
// }

// class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
//   YoutubePlayerController? _controller;
//   late VideoData currentVideo;
//   int currentIndex = 0;
//   bool _isPlayerReady = false;
//   String? _error;
//   bool _isLoading = true;
//   bool _isDisposed = false; // Track disposal state

//   // Splash screen control with fade animation
//   bool _showSplashScreen = true;
//   Timer? _splashTimer;
//   Timer? _splashUpdateTimer;
//   DateTime? _splashStartTime;
  
//   // End splash screen control with fade animation
//   bool _showEndSplashScreen = false;
//   Timer? _endSplashTimer;
//   DateTime? _endSplashStartTime;
  
//   // Animation controllers for fade effects
//   double _splashOpacity = 1.0; // Start fully black (opacity = 1.0)
//   double _endSplashOpacity = 0.0; // End starts transparent (opacity = 0.0)
//   Timer? _fadeAnimationTimer;

//   // Control states
//   bool _showControls = true;
//   bool _isPlaying = false;
//   Duration _currentPosition = Duration.zero;
//   Duration _totalDuration = Duration.zero;
//   Timer? _hideControlsTimer;

//   // Progressive seeking states
//   Timer? _seekTimer;
//   int _pendingSeekSeconds = 0;
//   Duration _targetSeekPosition = Duration.zero;
//   bool _isSeeking = false;

//   // Focus nodes for TV remote
//   final FocusNode _playPauseFocusNode = FocusNode();
//   final FocusNode _progressFocusNode = FocusNode();
//   final FocusNode _mainFocusNode = FocusNode(); // Main invisible focus node
//   bool _isProgressFocused = false;

//   // PAUSE CONTAINER STATES
//   Timer? _pauseContainerTimer;
//   bool _showPauseBlackBars = false; // Changed from _showPauseContainer to _showPauseBlackBars

//   @override
//   void initState() {
//     super.initState();
//     KeepScreenOn.turnOn(); 
//     currentVideo = widget.videoData;
//     currentIndex = widget.playlist.indexOf(widget.videoData);

//     print('📱 App started - Quick setup mode');

//     // Set full screen immediately
//     _setFullScreenMode();

//     // Start player initialization immediately
//     _initializePlayer();

//     // Start 30 second fade splash timer
//     _startSplashTimer();

//     // Request focus on main node initially
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _mainFocusNode.requestFocus();
//       // Show controls initially for testing (will be hidden during splash)
//       if (!_showSplashScreen) {
//         _showControlsTemporarily();
//       }
//     });
//   }

//   void _startSplashTimer() {
//     _splashStartTime = DateTime.now(); // Record start time
//     print('🎬 Top/Bottom black bars started - will remove after exactly 12 seconds');

//     // Simple timer - EXACTLY 12 seconds, no fade
//     _splashTimer = Timer(const Duration(seconds: 12), () {
//       if (mounted && !_isDisposed && _showSplashScreen) {
//         print('🎬 12 seconds complete - removing top/bottom black bars');
        
//         setState(() {
//           _showSplashScreen = false;
//         });
        
//         // Show controls when splash is gone
//         Future.delayed(const Duration(milliseconds: 500), () {
//           if (mounted && !_isDisposed) {
//             _showControlsTemporarily();
//             print('🎮 Controls are now available after 12 seconds');
//           }
//         });
//       }
//     });

//     // Timer to update countdown display every second
//     _splashUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (mounted && _showSplashScreen && !_isDisposed) {
//         final remaining = _getRemainingSeconds();
//         print('⏰ Top/Bottom black bars: ${remaining} seconds remaining');
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   void _setFullScreenMode() {
//     // TV ke liye optimized settings
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

//     // TV landscape orientation
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);

//     // TV ke liye additional settings
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         systemNavigationBarColor: Colors.transparent,
//       ),
//     );
//   }

//   void _initializePlayer() {
//     if (_isDisposed) return; // Don't initialize if disposed

//     try {
//       String? videoId = YoutubePlayer.convertUrlToId(currentVideo.youtubeUrl);

//       print('🔧 TV Mode: Initializing player for: $videoId');

//       if (videoId == null || videoId.isEmpty) {
//         if (mounted && !_isDisposed) {
//           setState(() {
//             _error = 'Invalid YouTube URL: ${currentVideo.youtubeUrl}';
//             _isLoading = false;
//           });
//         }
//         return;
//       }

//       // TV-specific controller configuration - NO MUTING + START FROM 10 SECONDS
//       _controller = YoutubePlayerController(
//         initialVideoId: videoId,
//         flags: const YoutubePlayerFlags(
//           mute: false, // NO MUTING - sound stays on
//           autoPlay: true,
//           disableDragSeek: false,
//           loop: false,
//           isLive: false,
//           forceHD: false,
//           enableCaption: false,
//           controlsVisibleAtStart: false,
//           hideControls: true,
//           // startAt: 10, // START FROM 10 SECONDS - SKIP FIRST 10 SECONDS
//           hideThumbnail: false,
//           useHybridComposition: false,
//         ),
//       );

//       _controller!.addListener(_listener);

//       // TV ke liye manual load aur play
//       Future.delayed(const Duration(milliseconds: 300), () {
//         if (mounted && _controller != null && !_isDisposed) {
//           print('🎯 TV: Loading video manually');
//           _controller!.load(videoId);

//           // Multiple play attempts for TV
//           Future.delayed(const Duration(milliseconds: 800), () {
//             if (mounted && _controller != null && !_isDisposed) {
//               print('🎬 TV: First play attempt (with sound)');
//               _controller!.play();
//               if (mounted) {
//                 setState(() {
//                   _isLoading = false;
//                   _isPlayerReady = true;
//                   _isPlaying = true;
//                 });
//               }
//             }
//           });
//         }
//       });

//     } catch (e) {
//       print('❌ TV Error: $e');
//       if (mounted && !_isDisposed) {
//         setState(() {
//           _error = 'TV Error: $e';
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _listener() {
//     if (_controller != null && mounted && !_isDisposed) {
//       if (_controller!.value.isReady && !_isPlayerReady) {
//         print('📡 Controller ready detected - starting from beginning');
        
//         // Ensure video starts from beginning
//         _controller!.play();
        
//         if (mounted) {
//           setState(() {
//             _isPlayerReady = true;
//             _isPlaying = true;
//           });
//         }
//       }

//       // Update position and duration
//       if (mounted) {
//         setState(() {
//           _currentPosition = _controller!.value.position;
//           _totalDuration = _controller!.value.metaData.duration;
          
//           // PAUSE CONTAINER LOGIC
//           bool newIsPlaying = _controller!.value.isPlaying;
          
//           // Agar pause se play hua hai
//           if (!_isPlaying && newIsPlaying) {
//             print('▶️ Video resumed - starting 5 second pause black bars timer');
//             _showPauseBlackBars = true; // Immediately show black bars
            
//             // 5 second timer to hide pause black bars
//             _pauseContainerTimer?.cancel();
//             _pauseContainerTimer = Timer(const Duration(seconds: 5), () {
//               if (mounted && !_isDisposed) {
//                 setState(() {
//                   _showPauseBlackBars = false;
//                 });
//                 print('⏰ 5 seconds completed - hiding pause black bars');
//               }
//             });
//           }
//           // Agar play se pause hua hai
//           else if (_isPlaying && !newIsPlaying) {
//             print('⏸️ Video paused - showing pause black bars');
//             _showPauseBlackBars = true;
//             _pauseContainerTimer?.cancel(); // Cancel any existing timer
//           }
          
//           _isPlaying = newIsPlaying;
//         });
//       }

//       // Check if video reached end minus 12 seconds - STOP 12 SECONDS BEFORE ACTUAL END
//       if (_totalDuration.inSeconds > 24 && _currentPosition.inSeconds > 0) { // Only if video is longer than 24 seconds
//         final adjustedEndTime = _totalDuration.inSeconds - 12; // End 12 seconds before actual end
        
//         // Stop video when reaching adjusted end time (12 seconds before actual end)
//         if (_currentPosition.inSeconds >= adjustedEndTime) {
//           print('🛑 Video reached cut point - stopping 12 seconds before actual end');
//           _controller!.pause();
          
//           // Navigate back after brief pause
//           Future.delayed(const Duration(milliseconds: 1000), () {
//             if (mounted && !_isDisposed) {
//               Navigator.of(context).pop();
//             }
//           });
//         }
//       }
//     }
//   }

//   void _startHideControlsTimer() {
//     // Controls hide timer works normally - only splash blocks controls, not this timer
//     if (_isDisposed) return;

//     _hideControlsTimer?.cancel();
//     _hideControlsTimer = Timer(const Duration(seconds: 5), () {
//       if (mounted && _showControls && !_isDisposed) {
//         setState(() {
//           _showControls = false;
//         });
//         // When controls hide, focus goes back to main invisible node
//         _mainFocusNode.requestFocus();
//       }
//     });
//   }

//   void _showControlsTemporarily() {
//     // Controls show normally - splash blocking is handled in key events
//     if (_isDisposed) return;

//     if (mounted) {
//       setState(() {
//         _showControls = true;
//       });
//     }

//     // When controls show, focus on play/pause button
//     _playPauseFocusNode.requestFocus();
//     _startHideControlsTimer();
//   }

//   void _togglePlayPause() {
//     if (_controller != null && _isPlayerReady && !_isDisposed) {
//       if (_isPlaying) {
//         _controller!.pause();
//         print('⏸️ Video paused');
//         // Pause container will show via listener
//       } else {
//         _controller!.play();
//         print('▶️ Video playing - 5 second timer will start via listener');
//         // Timer will start via listener when play state changes
//       }
//     }
//     _showControlsTemporarily();
//   }

//   void _seekVideo(bool forward) {
//     if (_controller != null && _isPlayerReady && _totalDuration.inSeconds > 24 && !_isDisposed) {
//       final adjustedEndTime = _totalDuration.inSeconds - 12; // Don't allow seeking beyond cut point
//       final seekAmount = (adjustedEndTime / 200).round().clamp(5, 30); // 5-30 seconds

//       // Cancel previous seek timer
//       _seekTimer?.cancel();

//       // Calculate new pending seek
//       if (forward) {
//         _pendingSeekSeconds += seekAmount;
//         print('⏩ Adding forward seek: +${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
//       } else {
//         _pendingSeekSeconds -= seekAmount;
//         print('⏪ Adding backward seek: -${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
//       }

//       // Calculate target position for preview - RESPECT END CUT BOUNDARY
//       final currentSeconds = _currentPosition.inSeconds;
//       final targetSeconds = (currentSeconds + _pendingSeekSeconds).clamp(0, adjustedEndTime); // 0 to end-12s
//       _targetSeekPosition = Duration(seconds: targetSeconds);

//       // Show seeking state
//       if (mounted && !_isDisposed) {
//         setState(() {
//           _isSeeking = true;
//         });
//       }

//       // Set timer to execute seek after 1 second of no input
//       _seekTimer = Timer(const Duration(milliseconds: 1000), () {
//         _executeSeek();
//       });

//       _showControlsTemporarily();
//     }
//   }

//   void _executeSeek() {
//     if (_controller != null && _isPlayerReady && !_isDisposed && _pendingSeekSeconds != 0) {
//       final adjustedEndTime = _totalDuration.inSeconds - 12; // Don't seek beyond cut point
//       final currentSeconds = _currentPosition.inSeconds;
//       final newPosition = (currentSeconds + _pendingSeekSeconds).clamp(0, adjustedEndTime); // Respect end cut boundary

//       print('🎯 Executing accumulated seek: ${_pendingSeekSeconds}s to position ${newPosition}s (within cut boundaries)');

//       // Execute the seek
//       _controller!.seekTo(Duration(seconds: newPosition));

//       // Reset seeking state
//       _pendingSeekSeconds = 0;
//       _targetSeekPosition = Duration.zero;

//       if (mounted && !_isDisposed) {
//         setState(() {
//           _isSeeking = false;
//         });
//       }
//     }
//   }

//   // Start end splash screen when 30 seconds remain - SOLID BLACK
//   void _startEndSplashTimer() {
//     if (_showEndSplashScreen || _isDisposed) return; // Prevent multiple triggers
    
//     _endSplashStartTime = DateTime.now();
//     print('🎬 End solid black splash started - will show for 30 seconds');

//     setState(() {
//       _showEndSplashScreen = true;
//     });

//     // Simple timer for end splash - 30 seconds solid black
//     _endSplashTimer = Timer(const Duration(seconds: 30), () {
//       if (mounted && !_isDisposed) {
//         print('🎬 End splash complete - ready for navigation');
        
//         setState(() {
//           _showEndSplashScreen = false;
//         });
//       }
//     });

//     print('⏰ End solid black splash started - will cover video completely');
//   }

//   // Helper method to check if controls should be blocked (only first 8 seconds)
//   bool _shouldBlockControls() {
//     if (_showSplashScreen && _splashStartTime != null) {
//       final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
//       return elapsed < 8; // Block only for first 8 seconds
//     }
//     return false;
//   }

//   // BLOCK controls only for first 8 seconds of splash
//   bool _handleKeyEvent(RawKeyEvent event) {
//     if (_isDisposed) return false;

//     // BLOCK key events only during first 8 seconds of splash screen
//     if (_shouldBlockControls()) {
//       if (event is RawKeyDownEvent) {
//         switch (event.logicalKey) {
//           case LogicalKeyboardKey.escape:
//           case LogicalKeyboardKey.backspace:
//             // Allow back navigation during splash
//             print('🔙 Back pressed during splash - exiting');
//             if (!_isDisposed) {
//               Navigator.of(context).pop();
//             }
//             return true;
//           default:
//             // Block other keys only for 8 seconds
//             print('🚫 Key blocked during first 8 seconds of splash: ${event.logicalKey}');
//             return true;
//         }
//       }
//       return true;
//     }

//     // Normal key handling after splash is gone
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

//         case LogicalKeyboardKey.arrowUp:
//         case LogicalKeyboardKey.arrowDown:
//           if (!_showControls) {
//             _showControlsTemporarily();
//           } else {
//             if (_playPauseFocusNode.hasFocus) {
//               _progressFocusNode.requestFocus();
//             } else if (_progressFocusNode.hasFocus) {
//               _playPauseFocusNode.requestFocus();
//             } else {
//               _playPauseFocusNode.requestFocus();
//             }
//             _showControlsTemporarily();
//           }
//           return true;

//         case LogicalKeyboardKey.escape:
//         case LogicalKeyboardKey.backspace:
//           if (!_isDisposed) {
//             Navigator.of(context).pop();
//           }
//           return true;

//         default:
//           if (!_showControls) {
//             _showControlsTemporarily();
//             return true;
//           }
//           break;
//       }
//     }
//     return false;
//   }

//   void _showError(String message) {
//     if (mounted && !_isDisposed) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   void _playNextVideo() {
//     if (_isDisposed) return;

//     if (currentIndex < widget.playlist.length - 1) {
//       if (mounted) {
//         setState(() {
//           currentIndex++;
//           currentVideo = widget.playlist[currentIndex];
//           _isLoading = true;
//           _error = null;
//           _showSplashScreen = true; // Show splash for next video
//           _showPauseBlackBars = false; // Reset pause black bars
//           _splashOpacity = 1.0; // Reset opacity
//         });
//       }
//       _controller?.dispose();
//       _pauseContainerTimer?.cancel(); // Cancel pause timer
//       _initializePlayer();
//       _startSplashTimer(); // Start splash timer for next video
//     } else {
//       _showError('Playlist complete, returning to home');
//       Future.delayed(const Duration(seconds: 1), () {
//         if (mounted && !_isDisposed) {
//           Navigator.of(context).pop();
//         }
//       });
//     }
//   }

//   void _playPreviousVideo() {
//     if (_isDisposed) return;

//     if (currentIndex > 0) {
//       if (mounted) {
//         setState(() {
//           currentIndex--;
//           currentVideo = widget.playlist[currentIndex];
//           _isLoading = true;
//           _error = null;
//           _showSplashScreen = true; // Show splash for previous video
//           _showPauseBlackBars = false; // Reset pause black bars
//           _splashOpacity = 1.0; // Reset opacity
//         });
//       }
//       _controller?.dispose();
//       _pauseContainerTimer?.cancel(); // Cancel pause timer
//       _initializePlayer();
//       _startSplashTimer(); // Start splash timer for previous video
//     } else {
//       _showError('First video in playlist');
//     }
//   }

//   // Handle back button press - TV Remote ke liye
//   Future<bool> _onWillPop() async {
//     if (_isDisposed) return true;

//     try {
//       print('🔙 Back button pressed - cleaning up...');

//       // Mark as disposed first
//       _isDisposed = true;

//       // Cancel all timers
//       _hideControlsTimer?.cancel();
//       _splashTimer?.cancel();
//       _splashUpdateTimer?.cancel();
//       _seekTimer?.cancel();
//       _pauseContainerTimer?.cancel(); // Cancel pause timer

//       // Pause and dispose controller
//       if (_controller != null) {
//         try {
//           if (_controller!.value.isPlaying) {
//             _controller!.pause();
//           }
//           _controller!.dispose();
//           _controller = null;
//         } catch (e) {
//           print('Error disposing controller: $e');
//         }
//       }

//       // Restore system UI in a try-catch
//       try {
//         await SystemChrome.setEnabledSystemUIMode(
//           SystemUiMode.manual,
//           overlays: SystemUiOverlay.values
//         );

//         // Reset orientation to allow all orientations
//         await SystemChrome.setPreferredOrientations([
//           DeviceOrientation.portraitUp,
//           DeviceOrientation.portraitDown,
//           DeviceOrientation.landscapeLeft,
//           DeviceOrientation.landscapeRight,
//         ]);
//       } catch (e) {
//         print('Error restoring system UI: $e');
//       }

//       return true; // Allow back navigation

//     } catch (e) {
//       print('Error in _onWillPop: $e');
//       return true;
//     }
//   }

//   @override
//   void deactivate() {
//     print('🔄 Screen deactivating...');
//     _isDisposed = true;
//     _controller?.pause();
//     _splashTimer?.cancel();
//     _pauseContainerTimer?.cancel(); // Cancel pause timer
//     super.deactivate();
//   }

//   @override
//   void dispose() {
//     print('🗑️ Disposing YouTube player screen...');
//     KeepScreenOn.turnOff();

//     try {
//       // Mark as disposed
//       _isDisposed = true;

//       // Cancel timers
//       _hideControlsTimer?.cancel();
//       _seekTimer?.cancel();
//       _splashTimer?.cancel();
//       _splashUpdateTimer?.cancel();
//       _pauseContainerTimer?.cancel(); // Cancel pause timer

//       // Dispose focus nodes
//       if (_mainFocusNode.hasListeners) {
//         _mainFocusNode.dispose();
//       }
//       if (_playPauseFocusNode.hasListeners) {
//         _playPauseFocusNode.dispose();
//       }
//       if (_progressFocusNode.hasListeners) {
//         _progressFocusNode.dispose();
//       }

//       // Dispose controller
//       if (_controller != null) {
//         try {
//           _controller!.pause();
//           _controller!.dispose();
//           _controller = null;
//         } catch (e) {
//           print('Error disposing controller in dispose: $e');
//         }
//       }

//       // Restore system UI
//       try {
//         SystemChrome.setEnabledSystemUIMode(
//           SystemUiMode.manual,
//           overlays: SystemUiOverlay.values
//         );

//         SystemChrome.setPreferredOrientations([
//           DeviceOrientation.portraitUp,
//           DeviceOrientation.portraitDown,
//           DeviceOrientation.landscapeLeft,
//           DeviceOrientation.landscapeRight,
//         ]);
//       } catch (e) {
//         print('Error restoring system UI in dispose: $e');
//       }

//     } catch (e) {
//       print('Error in dispose: $e');
//     }

//     super.dispose();
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Don't render if disposed
//     if (_isDisposed) {
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     return RawKeyboardListener(
//       focusNode: _mainFocusNode,
//       autofocus: true,
//       onKey: _handleKeyEvent,
//       child: WillPopScope(
//         onWillPop: _onWillPop,
//         child: Scaffold(
//           body: GestureDetector(
//             onTap: _shouldBlockControls() ? null : _showControlsTemporarily, // Disable tap only during first 8 seconds
//             behavior: HitTestBehavior.opaque,
//             child: Stack(
//               children: [
//                 // Full screen video player (always present and playing in background)
//                 _buildVideoPlayer(),

//                 // Top/Bottom Black Bars - Show for 12 seconds with video playing in center
//                 if (_showSplashScreen)
//                   _buildTopBottomBlackBars(),

//                 // Pause Black Bars - Show when paused and 5 seconds after resume
//                 if (_showPauseBlackBars && _isPlayerReady)
//                   _buildPauseBlackBars(),

//                 // Custom Controls Overlay - Show after 8 seconds even during splash
//                 if (!_shouldBlockControls())
//                   _buildControlsOverlay(),

//                 // Invisible back area - Active when controls are not blocked
//                 if (!_shouldBlockControls())
//                   Positioned(
//                     top: 0,
//                     left: 0,
//                     width: screenwdt,
//                     height: screenhgt,
//                     child: GestureDetector(
//                       onTap: () {
//                         if (!_isDisposed) {
//                           Navigator.of(context).pop();
//                         }
//                       },
//                       child: Container(
//                         color: Colors.transparent,
//                         child: const SizedBox.expand(),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Pause Black Bars - Same as start splash bars but for pause state
//   Widget _buildPauseBlackBars() {
//     return Stack(
//       children: [
//         // Top Black Bar - screenhgt/6 height (plain black, no text)
//         Positioned(
//           top: 0,
//           left: 0,
//           right: 0,
//           height: screenhgt / 6,
//           child: Container(
//             color: Colors.black,
//           ),
//         ),
//         // Bottom Black Bar - screenhgt/6 height
//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           height: screenhgt / 6,
//           child: Container(
//             color: Colors.black,
//           ),
//         ),
//       ],
//     );
//   }
//   // Top and Bottom Black Bars - Video plays in center (Start Splash)
//   Widget _buildTopBottomBlackBars() {
//     return Stack(
//       children: [
//         // Top Black Bar - screenhgt/6 height
//         Positioned(
//           top: 0,
//           left: 0,
//           right: 0,
//           height: screenhgt / 6,
//           child: Container(
//             color: Colors.black,
//           ),
//         ),
//         // Bottom Black Bar - screenhgt/6 height
//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           height: screenhgt / 6,
//           child: Container(
//             color: Colors.black,
//           ),
//         ),
//       ],
//     );
//   }

//   // Helper methods for splash countdown
//   double _getSplashProgress() {
//     if (_splashStartTime == null) return 0.0;

//     final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
//     final progress = elapsed / 12.0; // 12 seconds total
//     return progress.clamp(0.0, 1.0);
//   }

//   int _getRemainingSeconds() {
//     if (_splashStartTime == null) return 12;

//     final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
//     final remaining = 12 - elapsed;
//     return remaining.clamp(0, 12);
//   }

//   Widget _buildControlsOverlay() {
//     return Positioned.fill(
//       child: Stack(
//         children: [
//           // PAUSE BLACK BARS replaced with main pause black bars functionality moved above

//           // Visible controls overlay
//           if (_showControls)
//             Container(
//               color: Colors.black.withOpacity(0.3),
//               child: Column(
//                 children: [
//                   // Top area - playlist info
//                   if (widget.playlist.length > 1)
//                     SafeArea(
//                       child: Container(
//                         padding: EdgeInsets.only(
//                           top: (_showPauseBlackBars || _showSplashScreen) ? (screenhgt / 6) + 16 : 16, // Space for both pause and splash bars
//                           left: 16,
//                           right: 16,
//                           bottom: 16,
//                         ),
//                         child: Center(
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.6),
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Text(
//                               '${currentIndex + 1}/${widget.playlist.length}',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),

//                   const Spacer(),

//                   // Bottom Progress Bar with Play/Pause Button
//                   SafeArea(
//                     child: Container(
//                       padding: const EdgeInsets.all(20),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           // Progress Bar Section
//                           Expanded(
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 // Progress Bar
//                                 Focus(
//                                   focusNode: _progressFocusNode,
//                                   onFocusChange: (focused) {
//                                     if (mounted && !_isDisposed) {
//                                       setState(() {
//                                         _isProgressFocused = focused;
//                                       });
//                                       if (focused) _showControlsTemporarily();
//                                     }
//                                   },
//                                   child: Builder(
//                                     builder: (context) {
//                                       final isFocused = Focus.of(context).hasFocus;
//                                       return Container(
//                                         height: 8,
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(4),
//                                           border: isFocused ? Border.all(color: Colors.white, width: 2) : null,
//                                         ),
//                                         child: ClipRRect(
//                                           borderRadius: BorderRadius.circular(4),
//                                           child: Stack(
//                                             children: [
//                                               // Background
//                                               Container(
//                                                 width: double.infinity,
//                                                 height: 8,
//                                                 color: Colors.white.withOpacity(0.3),
//                                               ),
//                                               // Main progress bar
//                                               if (_totalDuration.inSeconds > 0)
//                                                 FractionallySizedBox(
//                                                   widthFactor: _currentPosition.inSeconds / _totalDuration.inSeconds,
//                                                   child: Container(
//                                                     height: 8,
//                                                     color: Colors.red,
//                                                   ),
//                                                 ),
//                                               // Seeking preview indicator
//                                               if (_isSeeking && _totalDuration.inSeconds > 0)
//                                                 FractionallySizedBox(
//                                                   widthFactor: _targetSeekPosition.inSeconds / _totalDuration.inSeconds,
//                                                   child: Container(
//                                                     height: 8,
//                                                     color: Colors.yellow.withOpacity(0.8),
//                                                   ),
//                                                 ),
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),

//                                 const SizedBox(height: 8),

//                                 // Time indicators and help text - ADJUSTED FOR END CUT
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       _isSeeking
//                                           ? _formatDuration(_targetSeekPosition)
//                                           : _formatDuration(_currentPosition),
//                                       style: TextStyle(
//                                         color: _isSeeking ? Colors.yellow : Colors.white,
//                                         fontSize: 14,
//                                         fontWeight: _isSeeking ? FontWeight.bold : FontWeight.normal,
//                                       ),
//                                     ),
//                                     if (_isProgressFocused)
//                                       Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           const Text(
//                                             '← → Seek | ↑↓ Navigate',
//                                             style: TextStyle(color: Colors.white70, fontSize: 12),
//                                           ),
//                                           if (_isSeeking)
//                                             Text(
//                                               '${_pendingSeekSeconds > 0 ? "+" : ""}${_pendingSeekSeconds}s',
//                                               style: const TextStyle(color: Colors.yellow, fontSize: 12, fontWeight: FontWeight.bold),
//                                             ),
//                                         ],
//                                       ),
//                                     Text(
//                                       _formatDuration(Duration(seconds: (_totalDuration.inSeconds - 12).clamp(0, double.infinity).toInt())), // Show adjusted total duration (minus 12s)
//                                       style: const TextStyle(color: Colors.white, fontSize: 14),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),

//                           const SizedBox(width: 20),

//                           // Play/Pause Button
//                           Focus(
//                             focusNode: _playPauseFocusNode,
//                             onFocusChange: (focused) {
//                               if (focused && !_isDisposed) _showControlsTemporarily();
//                             },
//                             child: Builder(
//                               builder: (context) {
//                                 final isFocused = Focus.of(context).hasFocus;
//                                 return GestureDetector(
//                                   onTap: _togglePlayPause,
//                                   child: Container(
//                                     width: 70,
//                                     height: 70,
//                                     decoration: BoxDecoration(
//                                       color: Colors.red.withOpacity(0.8),
//                                       borderRadius: BorderRadius.circular(35),
//                                       border: isFocused ? Border.all(color: Colors.white, width: 3) : null,
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.3),
//                                           blurRadius: 8,
//                                           offset: const Offset(0, 2),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Icon(
//                                       _isPlaying ? Icons.pause : Icons.play_arrow,
//                                       color: Colors.white,
//                                       size: 40,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//           // Invisible overlay for focus management when controls are hidden
//           if (!_showControls)
//             Positioned.fill(
//               child: GestureDetector(
//                 onTap: _showControlsTemporarily,
//                 behavior: HitTestBehavior.opaque,
//                 child: Container(
//                   color: Colors.transparent,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildVideoPlayer() {
//     if (_error != null) {
//       return Container(
//         color: Colors.black,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error, color: Colors.red, size: 48),
//               const SizedBox(height: 16),
//               Text(_error!, style: const TextStyle(color: Colors.white)),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   if (!_isDisposed && mounted) {
//                     setState(() {
//                       _isLoading = true;
//                       _error = null;
//                     });
//                     _controller?.dispose();
//                     _initializePlayer();
//                   }
//                 },
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (_controller == null || _isLoading) {
//       return Container(
//         color: Colors.black,
//         child: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(color: Colors.red),
//               SizedBox(height: 20),
//               Text(
//                 'Loading for TV Display...',
//                 style: TextStyle(color: Colors.white, fontSize: 18)
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       color: Colors.black,
//       child: YoutubePlayer(
//         controller: _controller!,
//         showVideoProgressIndicator: false,
//         progressIndicatorColor: Colors.red,
//         width: double.infinity,
//         aspectRatio: 16 / 9,
//         bufferIndicator: Container(
//           color: Colors.black,
//           child: const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(color: Colors.red),
//                 SizedBox(height: 10),
//                 Text('Buffering...', style: TextStyle(color: Colors.white)),
//               ],
//             ),
//           ),
//         ),
//         onReady: () {
//           print('📺 TV Player Ready - forcing video surface');
//           if (!_isPlayerReady && !_isDisposed) {
//             if (mounted) {
//               setState(() => _isPlayerReady = true);
//             }

//             // Focus on main node when ready, controls will show when needed
//             Future.delayed(const Duration(milliseconds: 500), () {
//               if (!_isDisposed) {
//                 _mainFocusNode.requestFocus();
//               }
//             });

//             // TV video surface activation - Start playing from beginning with sound
//             Future.delayed(const Duration(milliseconds: 100), () {
//               if (_controller != null && mounted && !_isDisposed) {
//                 // Start from beginning
//                 _controller!.play();
//                 print('🎬 TV: Video started playing from beginning (with sound during black bars)');
//               }
//             });
//           }
//         },
//         onEnded: (_) {
//           if (_isDisposed) return;

//           print('🎬 Video ended - navigating back to source page');
          
//           // Navigate back to source page immediately
//           Future.delayed(const Duration(milliseconds: 500), () {
//             if (mounted && !_isDisposed) {
//               Navigator.of(context).pop(); // Always go back to source page
//             }
//           });
//         },
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// // Video Model
// class VideoData {

//   final String id;
//   final String title;
//   final String youtubeUrl;
//   final String thumbnail;
//   final String description;

//   VideoData({
//     required this.id,
//     required this.title,
//     required this.youtubeUrl,
//     this.thumbnail = '',
//     this.description = '',
//   });
// }

// class YouTubePlayerScreen extends StatefulWidget {
//   final VideoData videoData;
//   final List<VideoData> playlist;

//   const YouTubePlayerScreen({
//     Key? key,
//     required this.videoData,
//     required this.playlist,
//   }) : super(key: key);

//   @override
//   _YouTubePlayerScreenState createState() => _YouTubePlayerScreenState();
// }

// class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
//   late WebViewController _controller;
//   String? videoId;

//   @override
//   void initState() {
//     super.initState();
//     // Extract video ID from YouTube URL
//     videoId = extractVideoId(widget.videoData.id);
    
//     if (videoId != null) {
//       _controller = WebViewController()
//         ..setJavaScriptMode(JavaScriptMode.unrestricted)
//         ..loadHtmlString(_generateHTML5Player());
//     }
//   }



//   // Function to extract video ID from YouTube URL
//   String? extractVideoId(String url) {
//     RegExp regExp = RegExp(
//       r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/|youtube\.com\/v\/|m\.youtube\.com\/watch\?v=)([a-zA-Z0-9_-]{11})',
//       caseSensitive: false,
//     );
//     Match? match = regExp.firstMatch(url);
//     return match?.group(1);
//   }

//   String _generateHTML5Player() {
//     return '''
// <!DOCTYPE html>
// <html>
// <head>
//     <meta charset="utf-8">
//     <meta name="viewport" content="width=device-width, initial-scale=1.0">
//     <style>
//         body {
//             margin: 0;
//             padding: 0;
//             background: #000;
//             display: flex;
//             justify-content: center;
//             align-items: center;
//             height: 100vh;
//         }
//         #player {
//             width: 100%;
//             height: 100%;
//         }
//         .error {
//             color: white;
//             text-align: center;
//             font-family: Arial, sans-serif;
//             padding: 20px;
//         }
//         .debug-info {
//             position: absolute;
//             top: 10px;
//             left: 10px;
//             background: rgba(255,255,255,0.8);
//             padding: 10px;
//             font-size: 12px;
//             border-radius: 4px;
//             z-index: 1000;
//         }
//     </style>
// </head>
// <body>
//     <div class="debug-info">
//         Video ID: $videoId<br>
//         Status: <span id="status">Loading...</span>
//     </div>
//     <div id="player"></div>
    
//     <script>
//         document.getElementById('status').innerText = 'Loading YouTube API...';
        
//         var tag = document.createElement('script');
//         tag.src = 'https://www.youtube.com/iframe_api';
//         var firstScriptTag = document.getElementsByTagName('script')[0];
//         firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

//         var player;
//         function onYouTubeIframeAPIReady() {
//             document.getElementById('status').innerText = 'API Ready, Creating Player...';
            
//             player = new YT.Player('player', {
//                 height: '100%',
//                 width: '100%',
//                 videoId: '$videoId',
//                 host: 'https://www.youtube-nocookie.com',  // Use privacy-enhanced mode
//                 playerVars: {
//                     'playsinline': 1,
//                     'controls': 1,
//                     'rel': 0,
//                     'showinfo': 0,
//                     'modestbranding': 1,
//                     'autoplay': 0,
//                     'fs': 1,
//                     'cc_load_policy': 0,
//                     'iv_load_policy': 3,
//                     'origin': window.location.origin
//                 },
//                 events: {
//                     'onReady': onPlayerReady,
//                     'onStateChange': onPlayerStateChange,
//                     'onError': onPlayerError
//                 }
//             });
//         }

//         function onPlayerReady(event) {
//             console.log('Player ready');
//             document.getElementById('status').innerText = 'Player Ready!';
//             setTimeout(() => {
//                 document.querySelector('.debug-info').style.display = 'none';
//             }, 3000);
//         }

//         function onPlayerStateChange(event) {
//             if (event.data == YT.PlayerState.PLAYING) {
//                 console.log('Video playing');
//                 document.getElementById('status').innerText = 'Playing';
//             } else if (event.data == YT.PlayerState.PAUSED) {
//                 console.log('Video paused');
//                 document.getElementById('status').innerText = 'Paused';
//             } else if (event.data == YT.PlayerState.ENDED) {
//                 console.log('Video ended');
//                 document.getElementById('status').innerText = 'Ended';
//             } else if (event.data == YT.PlayerState.BUFFERING) {
//                 document.getElementById('status').innerText = 'Buffering';
//             }
//         }

//         function onPlayerError(event) {
//             console.error('Player error:', event.data);
//             let errorMessage = '';
//             switch(event.data) {
//                 case 2:
//                     errorMessage = 'Invalid video ID';
//                     break;
//                 case 5:
//                     errorMessage = 'HTML5 player error';
//                     break;
//                 case 100:
//                     errorMessage = 'Video not found or private';
//                     break;
//                 case 101:
//                 case 150:
//                     errorMessage = 'Video unavailable (embedding disabled)';
//                     break;
//                 default:
//                     errorMessage = 'Unknown error: ' + event.data;
//             }
            
//             document.getElementById('player').innerHTML = 
//                 '<div class="error">' +
//                 '<h2>Video Unavailable</h2>' +
//                 '<p>' + errorMessage + '</p>' +
//                 '<p>Video ID: $videoId</p>' +
//                 '<p>Error Code: ' + event.data + '</p>' +
//                 '</div>';
//             document.getElementById('status').innerText = 'Error: ' + event.data;
//         }

//         // Functions that can be called from Flutter
//         function playVideo() {
//             if (player && player.playVideo) {
//                 player.playVideo();
//             }
//         }

//         function pauseVideo() {
//             if (player && player.pauseVideo) {
//                 player.pauseVideo();
//             }
//         }

//         function seekTo(seconds) {
//             if (player && player.seekTo) {
//                 player.seekTo(seconds, true);
//             }
//         }

//         function getCurrentTime() {
//             if (player && player.getCurrentTime) {
//                 return player.getCurrentTime();
//             }
//             return 0;
//         }

//         function getDuration() {
//             if (player && player.getDuration) {
//                 return player.getDuration();
//             }
//             return 0;
//         }
//     </script>
// </body>
// </html>
//     ''';
//   }

//   void _playVideo() {
//     _controller.runJavaScript('playVideo()');
//   }

//   void _pauseVideo() {
//     _controller.runJavaScript('pauseVideo()');
//   }

//   void _seekVideo(int seconds) {
//     _controller.runJavaScript('seekTo($seconds)');
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Check if video ID was successfully extracted
//     if (videoId == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text('YouTube Player'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.error, size: 64, color: Colors.red),
//               SizedBox(height: 16),
//               Text(
//                 'Invalid YouTube URL',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'URL: ${widget.videoData.id}',
//                 style: TextStyle(color: Colors.grey),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('Go Back'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.videoData.title.isNotEmpty 
//             ? widget.videoData.title 
//             : 'YouTube Player'),
//         backgroundColor: Colors.red,
//         foregroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           // Video Player
//           Container(
//             height: 220,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: Colors.black,
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: WebViewWidget(controller: _controller),
//           ),
          
//           // Video Info
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.videoData.title,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 if (widget.videoData.description.isNotEmpty) ...[
//                   SizedBox(height: 8),
//                   Text(
//                     widget.videoData.description,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade600,
//                     ),
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//                 SizedBox(height: 16),
//                 Text(
//                   'Video ID: $videoId',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                     fontFamily: 'monospace',
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           // Control Buttons
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: _playVideo,
//                   icon: Icon(Icons.play_arrow),
//                   label: Text('Play'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: _pauseVideo,
//                   icon: Icon(Icons.pause),
//                   label: Text('Pause'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () => _seekVideo(30),
//                   icon: Icon(Icons.fast_forward),
//                   label: Text('Skip 30s'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           // Playlist section (if you want to show other videos)
//           if (widget.playlist.length > 1) ...[
//             SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Text(
//                 'Playlist (${widget.playlist.length} videos)',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: widget.playlist.length,
//                 itemBuilder: (context, index) {
//                   final video = widget.playlist[index];
//                   final isCurrentVideo = video.id == widget.videoData.id;
                  
//                   return ListTile(
//                     leading: Icon(
//                       isCurrentVideo ? Icons.play_circle_filled : Icons.play_circle_outline,
//                       color: isCurrentVideo ? Colors.red : Colors.grey,
//                     ),
//                     title: Text(
//                       video.title,
//                       style: TextStyle(
//                         fontWeight: isCurrentVideo ? FontWeight.bold : FontWeight.normal,
//                         color: isCurrentVideo ? Colors.red : Colors.black,
//                       ),
//                     ),
//                     subtitle: Text('ID: ${extractVideoId(video.youtubeUrl) ?? "Invalid"}'),
//                     onTap: isCurrentVideo ? null : () {
//                       // Navigate to new video
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => YouTubePlayerScreen(
//                             videoData: video,
//                             playlist: widget.playlist,
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Video Model
class VideoData {
  final String id;
  final String title;
  final String youtubeUrl;
  final String thumbnail;
  final String description;

  VideoData({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    this.thumbnail = '',
    this.description = '',
  });
}

class YouTubePlayerScreen extends StatefulWidget {
  final VideoData videoData;
  final List<VideoData> playlist;

  const YouTubePlayerScreen({
    Key? key,
    required this.videoData,
    required this.playlist,
  }) : super(key: key);

  @override
  _YouTubePlayerScreenState createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
  late WebViewController _controller;
  String? videoId;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Extract video ID from YouTube URL
    // videoId = extractVideoId(widget.videoData.id);
    
    if (videoId != null) {
      _initializeController();
    } else {
      setState(() {
        errorMessage = 'Invalid YouTube URL format';
        isLoading = false;
      });
    }
  }

  void _initializeController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('Web resource error: ${error.description}');
            setState(() {
              errorMessage = 'Failed to load video: ${error.description}';
              isLoading = false;
            });
          },
        ),
      )
      ..loadHtmlString(_generateHTML5Player());
  }

  // // Function to extract video ID from YouTube URL
  // String? extractVideoId(String url) {
  //   // More comprehensive regex patterns
  //   List<RegExp> patterns = [
  //     RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})'),
  //     RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})'),
  //     RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]{11})'),
  //     RegExp(r'youtube\.com/v/([a-zA-Z0-9_-]{11})'),
  //     RegExp(r'm\.youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})'),
  //   ];

  //   for (RegExp pattern in patterns) {
  //     Match? match = pattern.firstMatch(url);
  //     if (match != null) {
  //       return match.group(1);
  //     }
  //   }
  //   return null;
  // }

  String _generateHTML5Player() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            background: #000;
            overflow: hidden;
            font-family: Arial, sans-serif;
        }
        #player-container {
            position: relative;
            width: 100vw;
            height: 100vh;
            background: #000;
        }
        #player {
            width: 100%;
            height: 100%;
        }
        .loading {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: white;
            text-align: center;
            z-index: 10;
        }
        .error {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: white;
            text-align: center;
            padding: 20px;
            background: rgba(255,0,0,0.1);
            border-radius: 8px;
            max-width: 300px;
        }
        .spinner {
            border: 2px solid #333;
            border-top: 2px solid #fff;
            border-radius: 50%;
            width: 30px;
            height: 30px;
            animation: spin 1s linear infinite;
            margin: 0 auto 10px;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div id="player-container">
        <div id="loading" class="loading">
            <div class="spinner"></div>
            <p>Loading YouTube Player...</p>
        </div>
        <div id="player"></div>
    </div>
    
    <script>
        console.log('Starting YouTube Player initialization...');
        console.log('Video ID: $videoId');
        
        // Load YouTube IFrame API
        var tag = document.createElement('script');
        tag.src = 'https://www.youtube.com/iframe_api';
        var firstScriptTag = document.getElementsByTagName('script')[0];
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

        var player;
        var isPlayerReady = false;
        
        // This function creates an <iframe> (and YouTube player) after the API code downloads.
        function onYouTubeIframeAPIReady() {
            console.log('YouTube API Ready');
            
            try {
                player = new YT.Player('player', {
                    height: '100%',
                    width: '100%',
                    videoId: '$videoId',
                    host: 'https://www.youtube.com',
                    playerVars: {
                        'playsinline': 1,
                        'controls': 1,
                        'rel': 0,
                        'showinfo': 0,
                        'modestbranding': 1,
                        'autoplay': 0,
                        'fs': 1,
                        'cc_load_policy': 0,
                        'iv_load_policy': 3,
                        'disablekb': 0,
                        'enablejsapi': 1,
                        'origin': window.location.protocol + '//' + window.location.hostname
                    },
                    events: {
                        'onReady': onPlayerReady,
                        'onStateChange': onPlayerStateChange,
                        'onError': onPlayerError
                    }
                });
            } catch (error) {
                console.error('Error creating player:', error);
                showError('Failed to create player: ' + error.message);
            }
        }

        function onPlayerReady(event) {
            console.log('Player is ready');
            isPlayerReady = true;
            document.getElementById('loading').style.display = 'none';
            
            // Optional: Auto-play video (remove if not needed)
            // event.target.playVideo();
        }

        function onPlayerStateChange(event) {
            console.log('Player state changed:', event.data);
            
            switch(event.data) {
                case YT.PlayerState.UNSTARTED:
                    console.log('Video unstarted');
                    break;
                case YT.PlayerState.ENDED:
                    console.log('Video ended');
                    break;
                case YT.PlayerState.PLAYING:
                    console.log('Video playing');
                    break;
                case YT.PlayerState.PAUSED:
                    console.log('Video paused');
                    break;
                case YT.PlayerState.BUFFERING:
                    console.log('Video buffering');
                    break;
                case YT.PlayerState.CUED:
                    console.log('Video cued');
                    break;
            }
        }

        function onPlayerError(event) {
            console.error('YouTube Player Error:', event.data);
            
            let errorMessage = 'Video playback error occurred.';
            let errorDetails = '';
            
            switch(event.data) {
                case 2:
                    errorMessage = 'Invalid video parameter';
                    errorDetails = 'The video ID may be incorrect or malformed.';
                    break;
                case 5:
                    errorMessage = 'HTML5 player error';
                    errorDetails = 'The video cannot be played in HTML5 player.';
                    break;
                case 100:
                    errorMessage = 'Video not found';
                    errorDetails = 'The video has been removed or is private.';
                    break;
                case 101:
                    errorMessage = 'Embedding not allowed';
                    errorDetails = 'The video owner has restricted embedding.';
                    break;
                case 150:
                    errorMessage = 'Embedding not allowed';
                    errorDetails = 'Same as 101. Video embedding is restricted.';
                    break;
                default:
                    errorDetails = 'Error code: ' + event.data;
            }
            
            showError(errorMessage + '<br><small>' + errorDetails + '</small>');
        }
        
        function showError(message) {
            document.getElementById('loading').style.display = 'none';
            document.getElementById('player').innerHTML = 
                '<div class="error">' +
                '<h3>⚠️ Cannot Play Video</h3>' +
                '<p>' + message + '</p>' +
                '<p style="margin-top: 10px; font-size: 12px; opacity: 0.7;">Video ID: $videoId</p>' +
                '</div>';
        }

        // Functions that can be called from Flutter
        function playVideo() {
            if (isPlayerReady && player && player.playVideo) {
                try {
                    player.playVideo();
                    return true;
                } catch (error) {
                    console.error('Error playing video:', error);
                    return false;
                }
            }
            return false;
        }

        function pauseVideo() {
            if (isPlayerReady && player && player.pauseVideo) {
                try {
                    player.pauseVideo();
                    return true;
                } catch (error) {
                    console.error('Error pausing video:', error);
                    return false;
                }
            }
            return false;
        }

        function seekTo(seconds) {
            if (isPlayerReady && player && player.seekTo) {
                try {
                    player.seekTo(seconds, true);
                    return true;
                } catch (error) {
                    console.error('Error seeking video:', error);
                    return false;
                }
            }
            return false;
        }

        function getCurrentTime() {
            if (isPlayerReady && player && player.getCurrentTime) {
                try {
                    return player.getCurrentTime();
                } catch (error) {
                    console.error('Error getting current time:', error);
                    return 0;
                }
            }
            return 0;
        }

        function getDuration() {
            if (isPlayerReady && player && player.getDuration) {
                try {
                    return player.getDuration();
                } catch (error) {
                    console.error('Error getting duration:', error);
                    return 0;
                }
            }
            return 0;
        }

        // Handle page visibility changes
        document.addEventListener('visibilitychange', function() {
            if (document.hidden && isPlayerReady && player && player.pauseVideo) {
                player.pauseVideo();
            }
        });
        
        // Timeout for loading
        setTimeout(function() {
            if (!isPlayerReady) {
                console.warn('Player failed to load within 10 seconds');
                showError('Player is taking too long to load.<br>Please check your internet connection.');
            }
        }, 10000);
        
    </script>
</body>
</html>
    ''';
  }

  void _playVideo() async {
    try {
      await _controller.runJavaScript('playVideo()');
    } catch (e) {
      print('Error playing video: $e');
    }
  }

  void _pauseVideo() async {
    try {
      await _controller.runJavaScript('pauseVideo()');
    } catch (e) {
      print('Error pausing video: $e');
    }
  }

  void _seekVideo(int seconds) async {
    try {
      await _controller.runJavaScript('seekTo($seconds)');
    } catch (e) {
      print('Error seeking video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.videoData.title.isNotEmpty 
            ? widget.videoData.title 
            : 'YouTube Player'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Video Player Container
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.grey.shade300, width: 0.5),
            ),
            child: Stack(
              children: [
                if (videoId != null && errorMessage == null)
                  WebViewWidget(controller: _controller),
                
                // Error Display
                if (errorMessage != null)
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 32),
                          SizedBox(height: 8),
                          Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Loading Indicator
                if (isLoading && errorMessage == null)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Loading video...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Video Info Section
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.videoData.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  // Description
                  if (widget.videoData.description.isNotEmpty) ...[
                    SizedBox(height: 12),
                    Text(
                      widget.videoData.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                  
                  SizedBox(height: 16),
                  
                  // Video Details
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Video Details',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Video ID: ${videoId ?? "Invalid"}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          'URL: ${widget.videoData.id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Control Buttons
                  if (videoId != null && errorMessage == null) ...[
                    Text(
                      'Player Controls',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _playVideo,
                          icon: Icon(Icons.play_arrow, size: 18),
                          label: Text('Play'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pauseVideo,
                          icon: Icon(Icons.pause, size: 18),
                          label: Text('Pause'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _seekVideo(30),
                          icon: Icon(Icons.fast_forward, size: 18),
                          label: Text('Skip 30s'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                  
                  // Playlist section
                  if (widget.playlist.length > 1) ...[
                    Text(
                      'Playlist (${widget.playlist.length} videos)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    ...widget.playlist.map((video) {
                      final isCurrentVideo = video.id == widget.videoData.id;
                      // final videoIdFromUrl = extractVideoId(video.youtubeUrl);
                      // final videoIdFromUrl = video.youtubeUrl;
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isCurrentVideo ? Colors.red.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCurrentVideo ? Colors.red.shade200 : Colors.grey.shade200,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isCurrentVideo ? Colors.red : Colors.grey.shade300,
                            child: Icon(
                              isCurrentVideo ? Icons.play_circle_filled : Icons.play_circle_outline,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            video.title,
                            style: TextStyle(
                              fontWeight: isCurrentVideo ? FontWeight.w600 : FontWeight.normal,
                              color: isCurrentVideo ? Colors.red.shade700 : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'ID: ${widget.videoData.id ?? "Invalid"}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          onTap: isCurrentVideo ? null : () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => YouTubePlayerScreen(
                                  videoData: video,
                                  playlist: widget.playlist,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}