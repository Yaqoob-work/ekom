// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:mobi_tv_entertainment/main.dart';
// // // import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// // // import 'dart:async';

// // // // // Video Model
// // // // class VideoData {
// // // //   // final String id;
// // // //   // final String title;
// // // //   final String videoUrl;
// // // //   // final String thumbnail;
// // // //   // final String description;

// // // //   VideoData({
// // // //     // required this.id,
// // // //     // required this.title,
// // // //     required this.videoUrl,
// // // //     // this.thumbnail = '',
// // // //     // this.description = '',
// // // //   });
// // // // }

// // // // Direct YouTube Player Screen - No Home Page Required
// // // class CustomYouTubePlayer extends StatefulWidget {
// // //   // final VideoData videoData;
// // //   // final List<VideoData> playlist;
// // //   final String videoUrl;

// // //   const CustomYouTubePlayer({
// // //     Key? key,
// // //     // required this.videoData,
// // //     // required this.playlist,
// // //     required this.videoUrl,
// // //   }) : super(key: key);

// // //   @override
// // //   _CustomYouTubePlayerState createState() => _CustomYouTubePlayerState();
// // // }

// // // class _CustomYouTubePlayerState extends State<CustomYouTubePlayer> {
// // //   YoutubePlayerController? _controller;
// // //   // late VideoData currentVideo;
// // //   int currentIndex = 0;
// // //   bool _isPlayerReady = false;
// // //   String? _error;
// // //   bool _isLoading = true;
// // //   bool _isDisposed = false; // Track disposal state

// // //   // Navigation control - FIXED
// // //   bool _isNavigating = false; // Prevent double navigation
// // //   bool _videoCompleted = false; // Track video completion

// // //   // Splash screen control with fade animation
// // //   bool _showSplashScreen = true;
// // //   Timer? _splashTimer;
// // //   Timer? _splashUpdateTimer;
// // //   DateTime? _splashStartTime;

// // //   // End splash screen control with fade animation
// // //   bool _showEndSplashScreen = false;

// // //   // Animation controllers for fade effects
// // //   double _splashOpacity = 1.0; // Start fully black (opacity = 1.0)
// // //   double _endSplashOpacity = 0.0; // End starts transparent (opacity = 0.0)
// // //   Timer? _fadeAnimationTimer;

// // //   // Control states
// // //   bool _showControls = true;
// // //   bool _isPlaying = false;
// // //   Duration _currentPosition = Duration.zero;
// // //   Duration _totalDuration = Duration.zero;
// // //   Timer? _hideControlsTimer;

// // //   // Progressive seeking states
// // //   Timer? _seekTimer;
// // //   int _pendingSeekSeconds = 0;
// // //   Duration _targetSeekPosition = Duration.zero;
// // //   bool _isSeeking = false;

// // //   // Focus nodes for TV remote
// // //   final FocusNode _playPauseFocusNode = FocusNode();
// // //   final FocusNode _progressFocusNode = FocusNode();
// // //   final FocusNode _mainFocusNode = FocusNode(); // Main invisible focus node
// // //   bool _isProgressFocused = false;

// // //   // REMOVED: All pause container/black bar states and timers

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     // currentVideo = widget.videoUrl;
// // //     // currentIndex = widget.playlist.indexOf(widget.videoUrl);

// // //     print('📱 App started - Quick setup mode');

// // //     // Set full screen immediately
// // //     _setFullScreenMode();

// // //     // Start player initialization immediately
// // //     _initializePlayer();

// // //     // Start 30 second fade splash timer
// // //     _startSplashTimer();

// // //     // Request focus on main node initially
// // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // //       _mainFocusNode.requestFocus();
// // //       // Show controls initially for testing (will be hidden during splash)
// // //       if (!_showSplashScreen) {
// // //         _showControlsTemporarily();
// // //       }
// // //     });
// // //   }

// // //   void _startSplashTimer() {
// // //     _splashStartTime = DateTime.now(); // Record start time
// // //     print(
// // //         '🎬 Top/Bottom black bars started - will remove after exactly 12 seconds');

// // //     // Simple timer - EXACTLY 12 seconds, no fade
// // //     _splashTimer = Timer(const Duration(seconds: 12), () {
// // //       if (mounted && !_isDisposed && _showSplashScreen) {
// // //         print('🎬 12 seconds complete - removing top/bottom black bars');

// // //         setState(() {
// // //           _showSplashScreen = false;
// // //         });

// // //         // Show controls when splash is gone
// // //         Future.delayed(const Duration(milliseconds: 500), () {
// // //           if (mounted && !_isDisposed) {
// // //             _showControlsTemporarily();
// // //             print('🎮 Controls are now available after 12 seconds');
// // //           }
// // //         });
// // //       }
// // //     });

// // //     // Timer to update countdown display every second
// // //     _splashUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
// // //       if (mounted && _showSplashScreen && !_isDisposed) {
// // //         final remaining = _getRemainingSeconds();
// // //         print('⏰ Top/Bottom black bars: ${remaining} seconds remaining');
// // //       } else {
// // //         timer.cancel();
// // //       }
// // //     });
// // //   }

// // //   void _setFullScreenMode() {
// // //     // TV ke liye optimized settings
// // //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

// // //     // TV landscape orientation
// // //     SystemChrome.setPreferredOrientations([
// // //       DeviceOrientation.landscapeLeft,
// // //       DeviceOrientation.landscapeRight,
// // //     ]);

// // //     // TV ke liye additional settings
// // //     SystemChrome.setSystemUIOverlayStyle(
// // //       const SystemUiOverlayStyle(
// // //         statusBarColor: Colors.transparent,
// // //         systemNavigationBarColor: Colors.transparent,
// // //       ),
// // //     );
// // //   }

// // //   void _initializePlayer() {
// // //     if (_isDisposed) return; // Don't initialize if disposed

// // //     try {
// // //       // String? videoId = YoutubePlayer.convertUrlToId(currentVideo.videoUrl);

// // //       // print('🔧 TV Mode: Initializing player for: $videoId');

// // //       // if (videoId == null || videoId.isEmpty) {
// // //       //   if (mounted && !_isDisposed) {
// // //       //     setState(() {
// // //       //       _error = 'Invalid YouTube URL: ${currentVideo.videoUrl}';
// // //       //       _isLoading = false;
// // //       //     });
// // //       //   }
// // //       //   return;
// // //       // }

// // //       // TV-specific controller configuration - NO MUTING + START FROM 10 SECONDS
// // //       _controller = YoutubePlayerController(
// // //         initialVideoId: widget.videoUrl,
// // //         flags: const YoutubePlayerFlags(
// // //           mute: false, // NO MUTING - sound stays on
// // //           autoPlay: true,
// // //           disableDragSeek: false,
// // //           loop: false,
// // //           isLive: false,
// // //           forceHD: false,
// // //           enableCaption: false,
// // //           controlsVisibleAtStart: false,
// // //           hideControls: true,
// // //           startAt: 10, // START FROM 10 SECONDS - SKIP FIRST 10 SECONDS
// // //           hideThumbnail: false,
// // //           useHybridComposition: false,
// // //         ),
// // //       );

// // //       _controller!.addListener(_listener);

// // //       // TV ke liye manual load aur play
// // //       Future.delayed(const Duration(milliseconds: 300), () {
// // //         if (mounted && _controller != null && !_isDisposed) {
// // //           print('🎯 TV: Loading video manually');
// // //           _controller!.load(widget.videoUrl);

// // //           // Multiple play attempts for TV
// // //           Future.delayed(const Duration(milliseconds: 800), () {
// // //             if (mounted && _controller != null && !_isDisposed) {
// // //               print('🎬 TV: First play attempt (with sound)');
// // //               _controller!.play();
// // //               if (mounted) {
// // //                 setState(() {
// // //                   _isLoading = false;
// // //                   _isPlayerReady = true;
// // //                   _isPlaying = true;
// // //                 });
// // //               }
// // //             }
// // //           });
// // //         }
// // //       });
// // //     } catch (e) {
// // //       print('❌ TV Error: $e');
// // //       if (mounted && !_isDisposed) {
// // //         setState(() {
// // //           _error = 'TV Error: $e';
// // //           _isLoading = false;
// // //         });
// // //       }
// // //     }
// // //   }

// // //   // FIXED: Single navigation trigger
// // //   void _listener() {
// // //     if (_controller != null && mounted && !_isDisposed && !_isNavigating) {
// // //       if (_controller!.value.isReady && !_isPlayerReady) {
// // //         print('📡 Controller ready detected - starting from beginning');

// // //         // Ensure video starts from beginning
// // //         _controller!.play();

// // //         if (mounted) {
// // //           setState(() {
// // //             _isPlayerReady = true;
// // //             _isPlaying = true;
// // //           });
// // //         }
// // //       }

// // //       // Update position and duration
// // //       if (mounted) {
// // //         setState(() {
// // //           _currentPosition = _controller!.value.position;
// // //           _totalDuration = _controller!.value.metaData.duration;

// // //           // REMOVED: All pause container logic
// // //           bool newIsPlaying = _controller!.value.isPlaying;
// // //           _isPlaying = newIsPlaying;
// // //         });
// // //       }

// // //       // FIXED: Single navigation trigger with proper checks
// // //       if (_totalDuration.inSeconds > 24 &&
// // //           _currentPosition.inSeconds > 0 &&
// // //           !_videoCompleted) {
// // //         final adjustedEndTime = _totalDuration.inSeconds - 12;

// // //         if (_currentPosition.inSeconds >= adjustedEndTime) {
// // //           print('🛑 Video reached cut point - completing video');
// // //           _completeVideo(); // Single method for video completion
// // //         }
// // //       }
// // //     }
// // //   }

// // //   // NEW: Single method to handle video completion
// // //   void _completeVideo() {
// // //     if (_isNavigating || _videoCompleted || _isDisposed) return;

// // //     print('🎬 Video completing - single navigation trigger');

// // //     // Mark as completed to prevent multiple triggers
// // //     _videoCompleted = true;
// // //     _isNavigating = true;

// // //     // Pause the video
// // //     if (_controller != null) {
// // //       _controller!.pause();
// // //     }

// // //     // Single navigation with cleanup
// // //     Future.delayed(const Duration(milliseconds: 800), () {
// // //       if (mounted && !_isDisposed) {
// // //         print('🔙 Navigating back to source page');
// // //         Navigator.of(context).pop();
// // //       }
// // //     });
// // //   }

// // //   // NEW: Reset states for new video
// // //   void _resetVideoStates() {
// // //     _isNavigating = false;
// // //     _videoCompleted = false;
// // //     _isPlayerReady = false;
// // //     _isPlaying = false;
// // //   }

// // //   void _startHideControlsTimer() {
// // //     // Controls hide timer works normally - only splash blocks controls, not this timer
// // //     if (_isDisposed) return;

// // //     _hideControlsTimer?.cancel();
// // //     _hideControlsTimer = Timer(const Duration(seconds: 5), () {
// // //       if (mounted && _showControls && !_isDisposed) {
// // //         setState(() {
// // //           _showControls = false;
// // //         });
// // //         // When controls hide, focus goes back to main invisible node
// // //         _mainFocusNode.requestFocus();
// // //       }
// // //     });
// // //   }

// // //   void _showControlsTemporarily() {
// // //     // Controls show normally - splash blocking is handled in key events
// // //     if (_isDisposed) return;

// // //     if (mounted) {
// // //       setState(() {
// // //         _showControls = true;
// // //       });
// // //     }

// // //     // When controls show, focus on play/pause button
// // //     _playPauseFocusNode.requestFocus();
// // //     _startHideControlsTimer();
// // //   }

// // //   void _togglePlayPause() {
// // //     if (_controller != null && _isPlayerReady && !_isDisposed) {
// // //       if (_isPlaying) {
// // //         _controller!.pause();
// // //         print('⏸️ Video paused');
// // //         // REMOVED: Pause container logic
// // //       } else {
// // //         _controller!.play();
// // //         print('▶️ Video playing');
// // //         // REMOVED: Pause container timer logic
// // //       }
// // //     }
// // //     _showControlsTemporarily();
// // //   }

// // //   void _seekVideo(bool forward) {
// // //     if (_controller != null &&
// // //         _isPlayerReady &&
// // //         _totalDuration.inSeconds > 24 &&
// // //         !_isDisposed) {
// // //       final adjustedEndTime =
// // //           _totalDuration.inSeconds - 12; // Don't allow seeking beyond cut point
// // //       final seekAmount =
// // //           (adjustedEndTime / 200).round().clamp(5, 30); // 5-30 seconds

// // //       // Cancel previous seek timer
// // //       _seekTimer?.cancel();

// // //       // Calculate new pending seek
// // //       if (forward) {
// // //         _pendingSeekSeconds += seekAmount;
// // //         print(
// // //             '⏩ Adding forward seek: +${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
// // //       } else {
// // //         _pendingSeekSeconds -= seekAmount;
// // //         print(
// // //             '⏪ Adding backward seek: -${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
// // //       }

// // //       // Calculate target position for preview - RESPECT END CUT BOUNDARY
// // //       final currentSeconds = _currentPosition.inSeconds;
// // //       final targetSeconds = (currentSeconds + _pendingSeekSeconds)
// // //           .clamp(0, adjustedEndTime); // 0 to end-12s
// // //       _targetSeekPosition = Duration(seconds: targetSeconds);

// // //       // Show seeking state
// // //       if (mounted && !_isDisposed) {
// // //         setState(() {
// // //           _isSeeking = true;
// // //         });
// // //       }

// // //       // Set timer to execute seek after 1 second of no input
// // //       _seekTimer = Timer(const Duration(milliseconds: 1000), () {
// // //         _executeSeek();
// // //       });

// // //       _showControlsTemporarily();
// // //     }
// // //   }

// // //   void _executeSeek() {
// // //     if (_controller != null &&
// // //         _isPlayerReady &&
// // //         !_isDisposed &&
// // //         _pendingSeekSeconds != 0) {
// // //       final adjustedEndTime =
// // //           _totalDuration.inSeconds - 12; // Don't seek beyond cut point
// // //       final currentSeconds = _currentPosition.inSeconds;
// // //       final newPosition = (currentSeconds + _pendingSeekSeconds)
// // //           .clamp(0, adjustedEndTime); // Respect end cut boundary

// // //       print(
// // //           '🎯 Executing accumulated seek: ${_pendingSeekSeconds}s to position ${newPosition}s (within cut boundaries)');

// // //       // Execute the seek
// // //       _controller!.seekTo(Duration(seconds: newPosition));

// // //       // Reset seeking state
// // //       _pendingSeekSeconds = 0;
// // //       _targetSeekPosition = Duration.zero;

// // //       if (mounted && !_isDisposed) {
// // //         setState(() {
// // //           _isSeeking = false;
// // //         });
// // //       }
// // //     }
// // //   }

// // //   // Start end splash screen when 30 seconds remain - SOLID BLACK
// // //   void _startEndSplashTimer() {
// // //     if (_showEndSplashScreen || _isDisposed)
// // //       return; // Prevent multiple triggers

// // //     print('🎬 End solid black splash started - will show for 30 seconds');

// // //     setState(() {
// // //       _showEndSplashScreen = true;
// // //     });

// // //     // Simple timer for end splash - 30 seconds solid black
// // //       if (mounted && !_isDisposed) {
// // //         print('🎬 End splash complete - ready for navigation');

// // //         setState(() {
// // //           _showEndSplashScreen = false;
// // //         });
// // //       }
// // //     });

// // //     print('⏰ End solid black splash started - will cover video completely');
// // //   }

// // //   // Helper method to check if controls should be blocked (only first 8 seconds)
// // //   bool _shouldBlockControls() {
// // //     if (_showSplashScreen && _splashStartTime != null) {
// // //       final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
// // //       return elapsed < 8; // Block only for first 8 seconds
// // //     }
// // //     return false;
// // //   }

// // //   // BLOCK controls only for first 8 seconds of splash
// // //   bool _handleKeyEvent(RawKeyEvent event) {
// // //     if (_isDisposed) return false;

// // //     // BLOCK key events only during first 8 seconds of splash screen
// // //     if (_shouldBlockControls()) {
// // //       if (event is RawKeyDownEvent) {
// // //         switch (event.logicalKey) {
// // //           case LogicalKeyboardKey.escape:
// // //           case LogicalKeyboardKey.backspace:
// // //             // Allow back navigation during splash
// // //             print('🔙 Back pressed during splash - exiting');
// // //             if (!_isDisposed) {
// // //               Navigator.of(context).pop();
// // //             }
// // //             return true;
// // //           default:
// // //             // Block other keys only for 8 seconds
// // //             print(
// // //                 '🚫 Key blocked during first 8 seconds of splash: ${event.logicalKey}');
// // //             return true;
// // //         }
// // //       }
// // //       return true;
// // //     }

// // //     // Normal key handling after splash is gone
// // //     if (event is RawKeyDownEvent) {
// // //       switch (event.logicalKey) {
// // //         case LogicalKeyboardKey.select:
// // //         case LogicalKeyboardKey.enter:
// // //         case LogicalKeyboardKey.space:
// // //           _togglePlayPause();
// // //           return true;

// // //         case LogicalKeyboardKey.arrowLeft:
// // //           _seekVideo(false);
// // //           return true;

// // //         case LogicalKeyboardKey.arrowRight:
// // //           _seekVideo(true);
// // //           return true;

// // //         case LogicalKeyboardKey.arrowUp:
// // //         case LogicalKeyboardKey.arrowDown:
// // //           if (!_showControls) {
// // //             _showControlsTemporarily();
// // //           } else {
// // //             if (_playPauseFocusNode.hasFocus) {
// // //               _progressFocusNode.requestFocus();
// // //             } else if (_progressFocusNode.hasFocus) {
// // //               _playPauseFocusNode.requestFocus();
// // //             } else {
// // //               _playPauseFocusNode.requestFocus();
// // //             }
// // //             _showControlsTemporarily();
// // //           }
// // //           return true;

// // //         case LogicalKeyboardKey.escape:
// // //         case LogicalKeyboardKey.backspace:
// // //           if (!_isDisposed) {
// // //             Navigator.of(context).pop();
// // //           }
// // //           return true;

// // //         default:
// // //           if (!_showControls) {
// // //             _showControlsTemporarily();
// // //             return true;
// // //           }
// // //           break;
// // //       }
// // //     }
// // //     return false;
// // //   }

// // //   void _showError(String message) {
// // //     if (mounted && !_isDisposed) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(
// // //           content: Text(message),
// // //           backgroundColor: Colors.red,
// // //           duration: const Duration(seconds: 3),
// // //         ),
// // //       );
// // //     }
// // //   }

// // //   // // UPDATED: Reset states when changing videos
// // //   // void _playNextVideo() {
// // //   //   if (_isDisposed) return;

// // //   //   if (currentIndex < widget.playlist.length - 1) {
// // //   //     if (mounted) {
// // //   //       setState(() {
// // //   //         currentIndex++;
// // //   //         currentVideo = widget.playlist[currentIndex];
// // //   //         _isLoading = true;
// // //   //         _error = null;
// // //   //         _showSplashScreen = true; // Show splash for next video
// // //   //         _splashOpacity = 1.0; // Reset opacity
// // //   //       });
// // //   //     }
// // //   //     _controller?.dispose();
// // //   //     _resetVideoStates(); // Reset navigation states
// // //   //     _initializePlayer();
// // //   //     _startSplashTimer(); // Start splash timer for next video
// // //   //   } else {
// // //   //     _showError('Playlist complete, returning to home');
// // //   //     _completeVideo(); // Use single completion method
// // //   //   }
// // //   // }

// // //   // // UPDATED: Reset states when changing videos
// // //   // void _playPreviousVideo() {
// // //   //   if (_isDisposed) return;

// // //   //   if (currentIndex > 0) {
// // //   //     if (mounted) {
// // //   //       setState(() {
// // //   //         currentIndex--;
// // //   //         currentVideo = widget.playlist[currentIndex];
// // //   //         _isLoading = true;
// // //   //         _error = null;
// // //   //         _showSplashScreen = true; // Show splash for previous video
// // //   //         _splashOpacity = 1.0; // Reset opacity
// // //   //       });
// // //   //     }
// // //   //     _controller?.dispose();
// // //   //     _resetVideoStates(); // Reset navigation states
// // //   //     _initializePlayer();
// // //   //     _startSplashTimer(); // Start splash timer for previous video
// // //   //   } else {
// // //   //     _showError('First video in playlist');
// // //   //   }
// // //   // }

// // //   // FIXED: Handle back button press - TV Remote ke liye
// // //   Future<bool> _onWillPop() async {
// // //     if (_isDisposed || _isNavigating) return true;

// // //     try {
// // //       print('🔙 Back button pressed - cleaning up...');

// // //       // Mark as navigating to prevent other triggers
// // //       _isNavigating = true;
// // //       _isDisposed = true;

// // //       // Cancel all timers
// // //       _hideControlsTimer?.cancel();
// // //       _splashTimer?.cancel();
// // //       _splashUpdateTimer?.cancel();
// // //       _seekTimer?.cancel();
// // //       // REMOVED: _pauseContainerTimer?.cancel();

// // //       // Pause and dispose controller
// // //       if (_controller != null) {
// // //         try {
// // //           if (_controller!.value.isPlaying) {
// // //             _controller!.pause();
// // //           }
// // //           _controller!.dispose();
// // //           _controller = null;
// // //         } catch (e) {
// // //           print('Error disposing controller: $e');
// // //         }
// // //       }

// // //       // Restore system UI in a try-catch
// // //       try {
// // //         await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
// // //             overlays: SystemUiOverlay.values);

// // //         // Reset orientation to allow all orientations
// // //         await SystemChrome.setPreferredOrientations([
// // //           DeviceOrientation.portraitUp,
// // //           DeviceOrientation.portraitDown,
// // //           DeviceOrientation.landscapeLeft,
// // //           DeviceOrientation.landscapeRight,
// // //         ]);
// // //       } catch (e) {
// // //         print('Error restoring system UI: $e');
// // //       }

// // //       return true; // Allow back navigation
// // //     } catch (e) {
// // //       print('Error in _onWillPop: $e');
// // //       return true;
// // //     }
// // //   }

// // //   @override
// // //   void deactivate() {
// // //     print('🔄 Screen deactivating...');
// // //     _isDisposed = true;
// // //     _controller?.pause();
// // //     _splashTimer?.cancel();
// // //     // REMOVED: _pauseContainerTimer?.cancel();
// // //     super.deactivate();
// // //   }

// // //   @override
// // //   void dispose() {
// // //     print('🗑️ Disposing YouTube player screen...');

// // //     try {
// // //       // Mark as disposed
// // //       _isDisposed = true;

// // //       // Cancel timers
// // //       _hideControlsTimer?.cancel();
// // //       _seekTimer?.cancel();
// // //       _splashTimer?.cancel();
// // //       _splashUpdateTimer?.cancel();
// // //       // REMOVED: _pauseContainerTimer?.cancel();

// // //       // Dispose focus nodes
// // //       if (_mainFocusNode.hasListeners) {
// // //         _mainFocusNode.dispose();
// // //       }
// // //       if (_playPauseFocusNode.hasListeners) {
// // //         _playPauseFocusNode.dispose();
// // //       }
// // //       if (_progressFocusNode.hasListeners) {
// // //         _progressFocusNode.dispose();
// // //       }

// // //       // Dispose controller
// // //       if (_controller != null) {
// // //         try {
// // //           _controller!.pause();
// // //           _controller!.dispose();
// // //           _controller = null;
// // //         } catch (e) {
// // //           print('Error disposing controller in dispose: $e');
// // //         }
// // //       }

// // //       // Restore system UI
// // //       try {
// // //         SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
// // //             overlays: SystemUiOverlay.values);

// // //         SystemChrome.setPreferredOrientations([
// // //           DeviceOrientation.portraitUp,
// // //           DeviceOrientation.portraitDown,
// // //           DeviceOrientation.landscapeLeft,
// // //           DeviceOrientation.landscapeRight,
// // //         ]);
// // //       } catch (e) {
// // //         print('Error restoring system UI in dispose: $e');
// // //       }
// // //     } catch (e) {
// // //       print('Error in dispose: $e');
// // //     }

// // //     super.dispose();
// // //   }

// // //   String _formatDuration(Duration duration) {
// // //     String twoDigits(int n) => n.toString().padLeft(2, '0');
// // //     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
// // //     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
// // //     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     // Don't render if disposed
// // //     if (_isDisposed) {
// // //       return const Scaffold(
// // //         body: Center(
// // //           child: CircularProgressIndicator(),
// // //         ),
// // //       );
// // //     }

// // //     return RawKeyboardListener(
// // //       focusNode: _mainFocusNode,
// // //       autofocus: true,
// // //       onKey: _handleKeyEvent,
// // //       child: WillPopScope(
// // //         onWillPop: _onWillPop,
// // //         child: Scaffold(
// // //           body: GestureDetector(
// // //             onTap: _shouldBlockControls()
// // //                 ? null
// // //                 : _showControlsTemporarily, // Disable tap only during first 8 seconds
// // //             behavior: HitTestBehavior.opaque,
// // //             child: Stack(
// // //               children: [
// // //                 // Full screen video player (always present and playing in background)
// // //                 _buildVideoPlayer(),

// // //                 // Top/Bottom Black Bars - Show for 12 seconds with video playing in center
// // //                 if (_showSplashScreen) _buildTopBottomBlackBars(),

// // //                 // REMOVED: Pause Black Bars functionality completely

// // //                 // Custom Controls Overlay - Show after 8 seconds even during splash
// // //                 if (!_shouldBlockControls()) _buildControlsOverlay(),

// // //                 // Invisible back area - Active when controls are not blocked
// // //                 if (!_shouldBlockControls())
// // //                   Positioned(
// // //                     top: 0,
// // //                     left: 0,
// // //                     width: screenwdt,
// // //                     height: screenhgt,
// // //                     child: GestureDetector(
// // //                       onTap: () {
// // //                         if (!_isDisposed) {
// // //                           Navigator.of(context).pop();
// // //                         }
// // //                       },
// // //                       child: Container(
// // //                         color: Colors.transparent,
// // //                         child: const SizedBox.expand(),
// // //                       ),
// // //                     ),
// // //                   ),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // REMOVED: _buildPauseBlackBars() method completely

// // //   // Top and Bottom Black Bars - Video plays in center (Start Splash)
// // //   Widget _buildTopBottomBlackBars() {
// // //     return Stack(
// // //       children: [
// // //         // Top Black Bar - screenhgt/6 height
// // //         Positioned(
// // //           top: 0,
// // //           left: 0,
// // //           right: 0,
// // //           height: screenhgt / 6,
// // //           child: Container(
// // //             color: Colors.black,
// // //           ),
// // //         ),
// // //         // Bottom Black Bar - screenhgt/6 height
// // //         Positioned(
// // //           bottom: 0,
// // //           left: 0,
// // //           right: 0,
// // //           height: screenhgt / 6,
// // //           child: Container(
// // //             color: Colors.black,
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   // Helper methods for splash countdown
// // //   double _getSplashProgress() {
// // //     if (_splashStartTime == null) return 0.0;

// // //     final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
// // //     final progress = elapsed / 12.0; // 12 seconds total
// // //     return progress.clamp(0.0, 1.0);
// // //   }

// // //   int _getRemainingSeconds() {
// // //     if (_splashStartTime == null) return 12;

// // //     final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
// // //     final remaining = 12 - elapsed;
// // //     return remaining.clamp(0, 12);
// // //   }

// // //   Widget _buildControlsOverlay() {
// // //     return Positioned.fill(
// // //       child: Stack(
// // //         children: [
// // //           // REMOVED: All pause container/black bar logic

// // //           // Visible controls overlay
// // //           if (_showControls)
// // //             Container(
// // //               color: Colors.black.withOpacity(0.3),
// // //               child: Column(
// // //                 children: [
// // //                   // Top area - playlist info
// // //                   // if (widget.playlist.length > 1)
// // //                   //   SafeArea(
// // //                   //     child: Container(
// // //                   //       padding: EdgeInsets.only(
// // //                   //         top: _showSplashScreen
// // //                   //             ? (screenhgt / 6) + 16
// // //                   //             : 16, // Space only for splash bars
// // //                   //         left: 16,
// // //                   //         right: 16,
// // //                   //         bottom: 16,
// // //                   //       ),
// // //                   //       child: Center(
// // //                   //         child: Container(
// // //                   //           padding: const EdgeInsets.symmetric(
// // //                   //               horizontal: 12, vertical: 6),
// // //                   //           decoration: BoxDecoration(
// // //                   //             color: Colors.black.withOpacity(0.6),
// // //                   //             borderRadius: BorderRadius.circular(16),
// // //                   //           ),
// // //                   //           child: Text(
// // //                   //             '${currentIndex + 1}/${widget.playlist.length}',
// // //                   //             style: const TextStyle(
// // //                   //               color: Colors.white,
// // //                   //               fontSize: 16,
// // //                   //               fontWeight: FontWeight.w500,
// // //                   //             ),
// // //                   //           ),
// // //                   //         ),
// // //                   //       ),
// // //                   //     ),
// // //                   //   ),

// // //                   // const Spacer(),

// // //                   // Bottom Progress Bar with Play/Pause Button
// // //                   SafeArea(
// // //                     child: Container(
// // //                       padding: const EdgeInsets.all(20),
// // //                       child: Row(
// // //                         crossAxisAlignment: CrossAxisAlignment.center,
// // //                         children: [
// // //                           // Progress Bar Section
// // //                           Expanded(
// // //                             child: Column(
// // //                               mainAxisSize: MainAxisSize.min,
// // //                               children: [
// // //                                 // Progress Bar
// // //                                 Focus(
// // //                                   focusNode: _progressFocusNode,
// // //                                   onFocusChange: (focused) {
// // //                                     if (mounted && !_isDisposed) {
// // //                                       setState(() {
// // //                                         _isProgressFocused = focused;
// // //                                       });
// // //                                       if (focused) _showControlsTemporarily();
// // //                                     }
// // //                                   },
// // //                                   child: Builder(
// // //                                     builder: (context) {
// // //                                       final isFocused =
// // //                                           Focus.of(context).hasFocus;
// // //                                       return Container(
// // //                                         height: 8,
// // //                                         decoration: BoxDecoration(
// // //                                           borderRadius:
// // //                                               BorderRadius.circular(4),
// // //                                           border: isFocused
// // //                                               ? Border.all(
// // //                                                   color: Colors.white, width: 2)
// // //                                               : null,
// // //                                         ),
// // //                                         child: ClipRRect(
// // //                                           borderRadius:
// // //                                               BorderRadius.circular(4),
// // //                                           child: Stack(
// // //                                             children: [
// // //                                               // Background
// // //                                               Container(
// // //                                                 width: double.infinity,
// // //                                                 height: 8,
// // //                                                 color: Colors.white
// // //                                                     .withOpacity(0.3),
// // //                                               ),
// // //                                               // Main progress bar
// // //                                               if (_totalDuration.inSeconds > 0)
// // //                                                 FractionallySizedBox(
// // //                                                   widthFactor: _currentPosition
// // //                                                           .inSeconds /
// // //                                                       _totalDuration.inSeconds,
// // //                                                   child: Container(
// // //                                                     height: 8,
// // //                                                     color: Colors.red,
// // //                                                   ),
// // //                                                 ),
// // //                                               // Seeking preview indicator
// // //                                               if (_isSeeking &&
// // //                                                   _totalDuration.inSeconds > 0)
// // //                                                 FractionallySizedBox(
// // //                                                   widthFactor:
// // //                                                       _targetSeekPosition
// // //                                                               .inSeconds /
// // //                                                           _totalDuration
// // //                                                               .inSeconds,
// // //                                                   child: Container(
// // //                                                     height: 8,
// // //                                                     color: Colors.yellow
// // //                                                         .withOpacity(0.8),
// // //                                                   ),
// // //                                                 ),
// // //                                             ],
// // //                                           ),
// // //                                         ),
// // //                                       );
// // //                                     },
// // //                                   ),
// // //                                 ),

// // //                                 const SizedBox(height: 8),

// // //                                 // Time indicators and help text - ADJUSTED FOR END CUT
// // //                                 Row(
// // //                                   mainAxisAlignment:
// // //                                       MainAxisAlignment.spaceBetween,
// // //                                   children: [
// // //                                     Text(
// // //                                       _isSeeking
// // //                                           ? _formatDuration(_targetSeekPosition)
// // //                                           : _formatDuration(_currentPosition),
// // //                                       style: TextStyle(
// // //                                         color: _isSeeking
// // //                                             ? Colors.yellow
// // //                                             : Colors.white,
// // //                                         fontSize: 14,
// // //                                         fontWeight: _isSeeking
// // //                                             ? FontWeight.bold
// // //                                             : FontWeight.normal,
// // //                                       ),
// // //                                     ),
// // //                                     if (_isProgressFocused)
// // //                                       Column(
// // //                                         mainAxisSize: MainAxisSize.min,
// // //                                         children: [
// // //                                           const Text(
// // //                                             '← → Seek | ↑↓ Navigate',
// // //                                             style: TextStyle(
// // //                                                 color: Colors.white70,
// // //                                                 fontSize: 12),
// // //                                           ),
// // //                                           if (_isSeeking)
// // //                                             Text(
// // //                                               '${_pendingSeekSeconds > 0 ? "+" : ""}${_pendingSeekSeconds}s',
// // //                                               style: const TextStyle(
// // //                                                   color: Colors.yellow,
// // //                                                   fontSize: 12,
// // //                                                   fontWeight: FontWeight.bold),
// // //                                             ),
// // //                                         ],
// // //                                       ),
// // //                                     Text(
// // //                                       _formatDuration(Duration(
// // //                                           seconds: (_totalDuration.inSeconds -
// // //                                                   12)
// // //                                               .clamp(0, double.infinity)
// // //                                               .toInt())), // Show adjusted total duration (minus 12s)
// // //                                       style: const TextStyle(
// // //                                           color: Colors.white, fontSize: 14),
// // //                                     ),
// // //                                   ],
// // //                                 ),
// // //                               ],
// // //                             ),
// // //                           ),

// // //                           const SizedBox(width: 20),

// // //                           // Play/Pause Button
// // //                           Focus(
// // //                             focusNode: _playPauseFocusNode,
// // //                             onFocusChange: (focused) {
// // //                               if (focused && !_isDisposed)
// // //                                 _showControlsTemporarily();
// // //                             },
// // //                             child: Builder(
// // //                               builder: (context) {
// // //                                 final isFocused = Focus.of(context).hasFocus;
// // //                                 return GestureDetector(
// // //                                   onTap: _togglePlayPause,
// // //                                   child: Container(
// // //                                     width: 70,
// // //                                     height: 70,
// // //                                     decoration: BoxDecoration(
// // //                                       color: Colors.red.withOpacity(0.8),
// // //                                       borderRadius: BorderRadius.circular(35),
// // //                                       border: isFocused
// // //                                           ? Border.all(
// // //                                               color: Colors.white, width: 3)
// // //                                           : null,
// // //                                       boxShadow: [
// // //                                         BoxShadow(
// // //                                           color: Colors.black.withOpacity(0.3),
// // //                                           blurRadius: 8,
// // //                                           offset: const Offset(0, 2),
// // //                                         ),
// // //                                       ],
// // //                                     ),
// // //                                     child: Icon(
// // //                                       _isPlaying
// // //                                           ? Icons.pause
// // //                                           : Icons.play_arrow,
// // //                                       color: Colors.white,
// // //                                       size: 40,
// // //                                     ),
// // //                                   ),
// // //                                 );
// // //                               },
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),

// // //           // Invisible overlay for focus management when controls are hidden
// // //           if (!_showControls)
// // //             Positioned.fill(
// // //               child: GestureDetector(
// // //                 onTap: _showControlsTemporarily,
// // //                 behavior: HitTestBehavior.opaque,
// // //                 child: Container(
// // //                   color: Colors.transparent,
// // //                 ),
// // //               ),
// // //             ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildVideoPlayer() {
// // //     if (_error != null) {
// // //       return Container(
// // //         color: Colors.black,
// // //         child: Center(
// // //           child: Column(
// // //             mainAxisAlignment: MainAxisAlignment.center,
// // //             children: [
// // //               const Icon(Icons.error, color: Colors.red, size: 48),
// // //               const SizedBox(height: 16),
// // //               Text(_error!, style: const TextStyle(color: Colors.white)),
// // //               const SizedBox(height: 16),
// // //               ElevatedButton(
// // //                 onPressed: () {
// // //                   if (!_isDisposed && mounted) {
// // //                     setState(() {
// // //                       _isLoading = true;
// // //                       _error = null;
// // //                     });
// // //                     _controller?.dispose();
// // //                     _initializePlayer();
// // //                   }
// // //                 },
// // //                 child: const Text('Retry'),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       );
// // //     }

// // //     if (_controller == null || _isLoading) {
// // //       return Container(
// // //         color: Colors.black,
// // //         child: const Center(
// // //           child: Column(
// // //             mainAxisAlignment: MainAxisAlignment.center,
// // //             children: [
// // //               CircularProgressIndicator(color: Colors.red),
// // //               SizedBox(height: 20),
// // //               Text('Loading for TV Display...',
// // //                   style: TextStyle(color: Colors.white, fontSize: 18)),
// // //             ],
// // //           ),
// // //         ),
// // //       );
// // //     }

// // //     return Container(
// // //       width: double.infinity,
// // //       height: double.infinity,
// // //       color: Colors.black,
// // //       child: YoutubePlayer(
// // //         controller: _controller!,
// // //         showVideoProgressIndicator: false,
// // //         progressIndicatorColor: Colors.red,
// // //         width: double.infinity,
// // //         aspectRatio: 16 / 9,
// // //         bufferIndicator: Container(
// // //           color: Colors.black,
// // //           child: const Center(
// // //             child: Column(
// // //               mainAxisAlignment: MainAxisAlignment.center,
// // //               children: [
// // //                 CircularProgressIndicator(color: Colors.red),
// // //                 SizedBox(height: 10),
// // //                 Text('Buffering...', style: TextStyle(color: Colors.white)),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //         onReady: () {
// // //           print('📺 TV Player Ready - forcing video surface');
// // //           if (!_isPlayerReady && !_isDisposed) {
// // //             if (mounted) {
// // //               setState(() => _isPlayerReady = true);
// // //             }

// // //             // Focus on main node when ready, controls will show when needed
// // //             Future.delayed(const Duration(milliseconds: 500), () {
// // //               if (!_isDisposed) {
// // //                 _mainFocusNode.requestFocus();
// // //               }
// // //             });

// // //             // TV video surface activation - Start playing from beginning with sound
// // //             Future.delayed(const Duration(milliseconds: 100), () {
// // //               if (_controller != null && mounted && !_isDisposed) {
// // //                 // Start from beginning
// // //                 _controller!.play();
// // //                 print(
// // //                     '🎬 TV: Video started playing from beginning (with sound during black bars)');
// // //               }
// // //             });
// // //           }
// // //         },
// // //         onEnded: (_) {
// // //           if (_isDisposed || _isNavigating || _videoCompleted) return;

// // //           print('🎬 Video ended naturally - using completion handler');
// // //           _completeVideo(); // Use same completion method
// // //         },
// // //       ),
// // //     );
// // //   }
// // // }

// // // import 'package:mobi_tv_entertainment/main.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// // // import 'dart:async';

// // // class CustomYoutubePlayer extends StatefulWidget {
// // //   final String videoUrl;
// // //   final List<String>? playlist;
// // //   final int initialIndex;

// // //   const CustomYoutubePlayer({
// // //     Key? key,
// // //     required this.videoUrl,
// // //     this.playlist,
// // //     this.initialIndex = 0,
// // //   }) : super(key: key);

// // //   @override
// // //   State<CustomYoutubePlayer> createState() => _CustomYoutubePlayerState();
// // // }

// // // class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
// // //   late YoutubePlayerController _controller;
// // //   Timer? _timer;
// // //   double _currentPosition = 0.0;
// // //   double _totalDuration = 1.0;
// // //   bool _isPlaying = false;
// // //   int _currentVideoIndex = 0;
// // //   List<String> _videoUrls = [];
// // //   bool _isPlayerReady = false;
// // //   bool _isLoading = true;
// // //   String? _error;

// // //   // Enhanced seeking state management
// // //   Timer? _seekTimer;
// // //   Timer? _seekIndicatorTimer;
// // //   int _pendingSeekSeconds = 0;
// // //   Duration _targetSeekPosition = Duration.zero;
// // //   bool _isSeeking = false;
// // //   bool _isActuallySeekingVideo = false;
// // //   bool _showSeekingIndicator = false;
// // //   double _lastKnownPosition = 0.0;

// // //   final FocusNode _mainFocusNode = FocusNode();
// // //   bool _videoCompleted = false;
// // //   bool _isNavigating = false;
// // //   bool _isDisposed = false;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _currentVideoIndex = widget.initialIndex;
// // //     _videoUrls = widget.playlist ?? [widget.videoUrl];
// // //     _setFullScreen();
// // //     _initializePlayer();

// // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // //       _mainFocusNode.requestFocus();
// // //     });
// // //   }

// // //   void _setFullScreen() {
// // //     // TV के लिए optimized full screen
// // //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
// // //     SystemChrome.setPreferredOrientations([
// // //       DeviceOrientation.landscapeLeft,
// // //       DeviceOrientation.landscapeRight,
// // //     ]);

// // //     // Additional TV settings
// // //     SystemChrome.setSystemUIOverlayStyle(
// // //       const SystemUiOverlayStyle(
// // //         statusBarColor: Colors.transparent,
// // //         systemNavigationBarColor: Colors.transparent,
// // //       ),
// // //     );
// // //   }

// // //   void _initializePlayer() {
// // //     if (_isDisposed) return;

// // //     try {
// // //       String currentVideoUrl = _videoUrls[_currentVideoIndex];
// // //       String? videoId = YoutubePlayer.convertUrlToId(currentVideoUrl);

// // //       print('🔧 TV Mode: Initializing player for: $videoId');

// // //       if (videoId == null || videoId.isEmpty) {
// // //         setState(() {
// // //           _error = 'Invalid YouTube URL: $currentVideoUrl';
// // //           _isLoading = false;
// // //         });
// // //         return;
// // //       }

// // //       // TV-specific controller configuration - FIXED FLAGS
// // //       _controller = YoutubePlayerController(
// // //         initialVideoId: videoId,
// // //         flags: const YoutubePlayerFlags(
// // //           mute: false,                    // Sound ON
// // //           autoPlay: true,                 // Auto play
// // //           disableDragSeek: false,         // Allow seeking
// // //           loop: false,                    // No loop
// // //           isLive: false,                  // Not live
// // //           forceHD: false,                 // Don't force HD (better compatibility)
// // //           enableCaption: false,           // No captions
// // //           controlsVisibleAtStart: false,  // Hide YouTube controls
// // //           hideControls: true,             // Hide YouTube controls completely
// // //           hideThumbnail: true,            // Hide thumbnail
// // //           useHybridComposition: false,    // CRITICAL: FALSE for TV compatibility
// // //           startAt: 0,                     // Start from beginning
// // //         ),
// // //       );

// // //       _controller.addListener(_playerListener);

// // //       // TV के लिए manual load और play sequence
// // //       Future.delayed(const Duration(milliseconds: 500), () {
// // //         if (mounted && !_isDisposed) {
// // //           print('🎯 TV: Loading video manually');
// // //           _controller.load(videoId);

// // //           // Multiple play attempts for TV compatibility
// // //           Future.delayed(const Duration(milliseconds: 1000), () {
// // //             if (mounted && !_isDisposed) {
// // //               print('🎬 TV: First play attempt');
// // //               _controller.play();

// // //               setState(() {
// // //                 _isLoading = false;
// // //                 _isPlayerReady = true;
// // //                 _isPlaying = true;
// // //               });

// // //               print('🎯 Player ready state set to true, starting progress timer');

// // //               // Start progress timer after player is ready
// // //               _startProgressTimer();
// // //             }
// // //           });

// // //           // Backup play attempt
// // //           Future.delayed(const Duration(milliseconds: 2000), () {
// // //             if (mounted && !_isDisposed && !_controller.value.isPlaying) {
// // //               print('🎬 TV: Backup play attempt');
// // //               _controller.play();
// // //             }
// // //           });
// // //         }
// // //       });

// // //     } catch (e) {
// // //       print('❌ TV Error: $e');
// // //       if (mounted && !_isDisposed) {
// // //         setState(() {
// // //           _error = 'TV Error: $e';
// // //           _isLoading = false;
// // //         });
// // //       }
// // //     }
// // //   }

// // //   void _playerListener() {
// // //     if (_isDisposed) return;

// // //     print('📡 Player listener called - isReady: ${_controller.value.isReady}, _isPlayerReady: $_isPlayerReady');

// // //     if (_controller.value.isReady && !_isPlayerReady) {
// // //       print('📡 Controller ready detected - setting player ready to true');

// // //       // Ensure video starts playing
// // //       if (!_controller.value.isPlaying) {
// // //         _controller.play();
// // //       }

// // //       setState(() {
// // //         _isPlayerReady = true;
// // //         _isPlaying = _controller.value.isPlaying;
// // //       });
// // //     }

// // //     // Update position and duration
// // //     if (mounted && !_isDisposed) {
// // //       setState(() {
// // //         _isPlaying = _controller.value.isPlaying;
// // //         _totalDuration = _controller.metadata.duration.inSeconds.toDouble();
// // //       });

// // //       // Video end cut logic
// // //       if (_totalDuration > 30 &&
// // //           _controller.value.position.inSeconds > 0 &&
// // //           !_videoCompleted &&
// // //           !_isNavigating) {

// // //         final adjustedEndTime = _totalDuration.toInt() - 15;

// // //         if (_controller.value.position.inSeconds >= adjustedEndTime) {
// // //           print('🛑 Video reached cut point (15s before end) - completing video');
// // //           _completeVideo();
// // //         }
// // //       }
// // //     }
// // //   }

// // //   void _completeVideo() {
// // //     if (_isNavigating || _videoCompleted || _isDisposed) return;

// // //     print('🎬 Video completing - 15 seconds before actual end');
// // //     _videoCompleted = true;
// // //     _isNavigating = true;

// // //     if (_controller.value.isPlaying) {
// // //       _controller.pause();
// // //     }

// // //     Future.delayed(const Duration(milliseconds: 500), () {
// // //       if (mounted && !_isDisposed) {
// // //         _playNextVideo();
// // //       }
// // //     });
// // //   }

// // //   void _resetVideoStates() {
// // //     _isNavigating = false;
// // //     _videoCompleted = false;
// // //     _currentPosition = 0.0;
// // //     _isSeeking = false;
// // //     _isActuallySeekingVideo = false;
// // //     _showSeekingIndicator = false;
// // //     _pendingSeekSeconds = 0;
// // //     _targetSeekPosition = Duration.zero;
// // //     _isPlayerReady = false;
// // //   }

// // //   void _startProgressTimer() {
// // //     _timer?.cancel(); // Cancel existing timer
// // //     _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
// // //       if (_isDisposed) {
// // //         timer.cancel();
// // //         return;
// // //       }

// // //       if (_controller.value.isReady) {
// // //         final newPosition = _controller.value.position.inSeconds.toDouble();

// // //         // If we're seeking, check if we've reached the target position
// // //         if (_isActuallySeekingVideo && _targetSeekPosition != Duration.zero) {
// // //           final targetPos = _targetSeekPosition.inSeconds.toDouble();
// // //           final tolerance = 1.5; // 1.5 second tolerance

// // //           if ((newPosition - targetPos).abs() <= tolerance) {
// // //             // We've reached target position, reset all seeking states
// // //             print('✅ Reached target position: ${newPosition}s (target was: ${targetPos}s)');
// // //             setState(() {
// // //               _currentPosition = newPosition;
// // //               _lastKnownPosition = newPosition;
// // //               _isActuallySeekingVideo = false;
// // //               _isSeeking = false;
// // //             });
// // //             _pendingSeekSeconds = 0;
// // //             _targetSeekPosition = Duration.zero;
// // //           }
// // //         } else if (!_isSeeking && !_isActuallySeekingVideo) {
// // //           // Normal position update when not seeking at all
// // //           setState(() {
// // //             _currentPosition = newPosition;
// // //             _lastKnownPosition = newPosition;
// // //           });
// // //         }
// // //       }
// // //     });
// // //   }

// // //   // Enhanced seeking with smooth progress bar
// // //   void _seekVideo(bool forward) {
// // //     if (_controller.value.isReady && _totalDuration > 30) {
// // //       final adjustedEndTime = _totalDuration.toInt() - 15;
// // //       final seekAmount = (adjustedEndTime / 200).round().clamp(5, 30);

// // //       // Store current position before seeking starts (only if not already seeking)
// // //       if (!_isSeeking && !_isActuallySeekingVideo) {
// // //         _lastKnownPosition = _currentPosition;
// // //       }

// // //       _seekTimer?.cancel();

// // //       // Calculate new pending seek
// // //       if (forward) {
// // //         _pendingSeekSeconds += seekAmount;
// // //         print('⏩ Adding forward seek: +${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
// // //       } else {
// // //         _pendingSeekSeconds -= seekAmount;
// // //         print('⏪ Adding backward seek: -${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
// // //       }

// // //       // Calculate target position - RESPECT END CUT BOUNDARY
// // //       final targetSeconds = (_lastKnownPosition.toInt() + _pendingSeekSeconds)
// // //           .clamp(0, adjustedEndTime);
// // //       _targetSeekPosition = Duration(seconds: targetSeconds);

// // //       // Show seeking state and indicator
// // //       setState(() {
// // //         _isSeeking = true;
// // //         _showSeekingIndicator = true;
// // //       });

// // //       print('🎯 Target seek position: ${targetSeconds}s');

// // //       // Set timer to execute actual seek
// // //       _seekTimer = Timer(const Duration(milliseconds: 1000), () {
// // //         _executeSeek();
// // //       });

// // //       // Set timer to hide seeking indicator after 3 seconds
// // //       _seekIndicatorTimer?.cancel();
// // //       _seekIndicatorTimer = Timer(const Duration(seconds: 3), () {
// // //         if (mounted && !_isDisposed) {
// // //           setState(() {
// // //             _showSeekingIndicator = false;
// // //           });
// // //         }
// // //       });
// // //     }
// // //   }

// // //   void _executeSeek() {
// // //     if (_controller.value.isReady && _pendingSeekSeconds != 0 && !_isDisposed) {
// // //       final targetSeconds = _targetSeekPosition.inSeconds;

// // //       print('🎯 Executing accumulated seek to: ${targetSeconds}s');

// // //       // Set flag to prevent position updates during seeking
// // //       setState(() {
// // //         _isActuallySeekingVideo = true;
// // //         _currentPosition = targetSeconds.toDouble(); // Set target position
// // //       });

// // //       // Execute the actual video seek
// // //       try {
// // //         _controller.seekTo(Duration(seconds: targetSeconds));
// // //         print('⏳ Seek command sent, waiting for video to reach target position...');
// // //         // Don't reset states here - let the timer check when we actually reach the position
// // //       } catch (error) {
// // //         print('❌ Seek error: $error');
// // //         // Reset on error
// // //         setState(() {
// // //           _isActuallySeekingVideo = false;
// // //           _isSeeking = false;
// // //         });
// // //         _pendingSeekSeconds = 0;
// // //         _targetSeekPosition = Duration.zero;
// // //       }
// // //     }
// // //   }

// // //   bool _handleKeyEvent(RawKeyEvent event) {
// // //     if (_isDisposed) return false;

// // //     if (event is RawKeyDownEvent) {
// // //       switch (event.logicalKey) {
// // //         case LogicalKeyboardKey.select:
// // //         case LogicalKeyboardKey.enter:
// // //         case LogicalKeyboardKey.space:
// // //           _togglePlayPause();
// // //           return true;

// // //         case LogicalKeyboardKey.arrowLeft:
// // //           _seekVideo(false);
// // //           return true;

// // //         case LogicalKeyboardKey.arrowRight:
// // //           _seekVideo(true);
// // //           return true;

// // //         case LogicalKeyboardKey.escape:
// // //         case LogicalKeyboardKey.backspace:
// // //           if (!_isDisposed) {
// // //             Navigator.of(context).pop();
// // //           }
// // //           return true;

// // //         default:
// // //           break;
// // //       }
// // //     }
// // //     return false;
// // //   }

// // //   void _togglePlayPause() {
// // //     if (_controller.value.isReady && !_isDisposed) {
// // //       if (_isPlaying) {
// // //         _controller.pause();
// // //         print('⏸️ Video paused');
// // //       } else {
// // //         _controller.play();
// // //         print('▶️ Video playing');
// // //       }
// // //     }
// // //   }

// // //   void _playNextVideo() {
// // //     if (_isDisposed) return;

// // //     if (_currentVideoIndex < _videoUrls.length - 1) {
// // //       setState(() {
// // //         _currentVideoIndex++;
// // //         _isLoading = true;
// // //         _error = null;
// // //       });
// // //       _resetVideoStates();
// // //       _controller.dispose();
// // //       _initializePlayer();
// // //     } else {
// // //       print('📱 Playlist complete - exiting player');
// // //       if (!_isDisposed) {
// // //         Navigator.of(context).pop();
// // //       }
// // //     }
// // //   }

// // //   void _playPreviousVideo() {
// // //     if (_isDisposed) return;

// // //     if (_currentVideoIndex > 0) {
// // //       setState(() {
// // //         _currentVideoIndex--;
// // //         _isLoading = true;
// // //         _error = null;
// // //       });
// // //       _resetVideoStates();
// // //       _controller.dispose();
// // //       _initializePlayer();
// // //     }
// // //   }

// // //   String _formatDuration(double seconds) {
// // //     int minutes = (seconds / 60).floor();
// // //     int remainingSeconds = (seconds % 60).floor();
// // //     return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
// // //   }

// // //   double get _adjustedTotalDuration {
// // //     if (_totalDuration > 30) {
// // //       return _totalDuration - 15;
// // //     }
// // //     return _totalDuration;
// // //   }

// // //   // Get display position for progress bar
// // //   double get _displayPosition {
// // //     if (_isSeeking || _isActuallySeekingVideo) {
// // //       return _targetSeekPosition.inSeconds.toDouble();
// // //     }
// // //     return _currentPosition;
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     if (_isDisposed) {
// // //       return const Scaffold(
// // //         body: Center(child: CircularProgressIndicator()),
// // //       );
// // //     }

// // //     return RawKeyboardListener(
// // //       focusNode: _mainFocusNode,
// // //       autofocus: true,
// // //       onKey: _handleKeyEvent,
// // //       child: WillPopScope(
// // //         onWillPop: () async {
// // //           _isDisposed = true;
// // //           return true;
// // //         },
// // //         child: Scaffold(
// // //           backgroundColor: Colors.black,
// // //           body: Stack(
// // //             children: [
// // //               // YouTube Player - Full Screen Background
// // //               if (!_isLoading && _error == null)
// // //                 SizedBox.expand(
// // //                   child: YoutubePlayer(
// // //                     controller: _controller,
// // //                     showVideoProgressIndicator: false,
// // //                     progressIndicatorColor: Colors.transparent,
// // //                     aspectRatio: 16 / 9,
// // //                     width: double.infinity,
// // //                     bufferIndicator: Container(
// // //                       color: Colors.black,
// // //                       child: const Center(
// // //                         child: Column(
// // //                           mainAxisAlignment: MainAxisAlignment.center,
// // //                           children: [
// // //                             CircularProgressIndicator(color: Colors.red),
// // //                             SizedBox(height: 10),
// // //                             Text('Buffering...', style: TextStyle(color: Colors.white)),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     onReady: () {
// // //                       print('📺 TV Player Ready - forcing play');
// // //                       if (!_isPlayerReady && !_isDisposed) {
// // //                         setState(() => _isPlayerReady = true);

// // //                         // Force play for TV
// // //                         Future.delayed(const Duration(milliseconds: 200), () {
// // //                           if (!_isDisposed) {
// // //                             _controller.play();
// // //                             print('🎬 TV: Video forced to play on ready');
// // //                           }
// // //                         });
// // //                       }
// // //                     },
// // //                     onEnded: (data) {
// // //                       print('Video ended naturally, playing next...');
// // //                       if (!_videoCompleted && !_isNavigating && !_isDisposed) {
// // //                         _completeVideo();
// // //                       }
// // //                     },
// // //                   ),
// // //                 ),

// // //               // Error State - Full overlay
// // //               if (_error != null)
// // //                 Container(
// // //                   color: Colors.black,
// // //                   child: Center(
// // //                     child: Column(
// // //                       mainAxisAlignment: MainAxisAlignment.center,
// // //                       children: [
// // //                         const Icon(Icons.error, color: Colors.red, size: 48),
// // //                         const SizedBox(height: 16),
// // //                         Text(_error!, style: const TextStyle(color: Colors.white)),
// // //                         const SizedBox(height: 16),
// // //                         ElevatedButton(
// // //                           onPressed: () {
// // //                             setState(() {
// // //                               _isLoading = true;
// // //                               _error = null;
// // //                             });
// // //                             _controller.dispose();
// // //                             _initializePlayer();
// // //                           },
// // //                           child: const Text('Retry'),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                 ),

// // //               // Loading State - Full overlay
// // //               if (_isLoading && _error == null)
// // //                 Container(
// // //                   color: Colors.black,
// // //                   child: const Center(
// // //                     child: Column(
// // //                       mainAxisAlignment: MainAxisAlignment.center,
// // //                       children: [
// // //                         CircularProgressIndicator(color: Colors.red),
// // //                         SizedBox(height: 20),
// // //                         Text('Loading for TV Display...',
// // //                             style: TextStyle(color: Colors.white, fontSize: 18)),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                 ),

// // //               // Invisible overlay to ensure overlay widgets render on top
// // //               if (!_isLoading && _error == null)
// // //                 IgnorePointer(
// // //                   child: Container(
// // //                     width: double.infinity,
// // //                     height: double.infinity,
// // //                     color: Colors.transparent,
// // //                   ),
// // //                 ),

// // //               // Top Video Info Overlay - Now guaranteed to be on top
// // //               if (!_isLoading && _error == null)
// // //                 Positioned(
// // //                   top: 20,
// // //                   left: 20,
// // //                   right: 20,
// // //                   child: IgnorePointer(
// // //                     ignoring: !_showSeekingIndicator,
// // //                     child: AnimatedOpacity(
// // //                       opacity: _showSeekingIndicator ? 1.0 : 0.0,
// // //                       duration: const Duration(milliseconds: 300),
// // //                       child: Container(
// // //                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // //                         decoration: BoxDecoration(
// // //                           color: Colors.black.withOpacity(0.8),
// // //                           borderRadius: BorderRadius.circular(20),
// // //                           border: Border.all(color: Colors.white.withOpacity(0.3)),
// // //                         ),
// // //                         child: Row(
// // //                           mainAxisAlignment: MainAxisAlignment.center,
// // //                           children: [
// // //                             Text(
// // //                               'Video ${_currentVideoIndex + 1} of ${_videoUrls.length}',
// // //                               style: const TextStyle(
// // //                                 color: Colors.white,
// // //                                 fontSize: 14,
// // //                                 fontWeight: FontWeight.w500,
// // //                               ),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),

// // //               // FORCED Progress Bar Overlay - Using RepaintBoundary for guaranteed top layer
// // //               if (!_isLoading && _error == null)
// // //                 Positioned(
// // //                   bottom: 0,
// // //                   left: 0,
// // //                   right: 0,
// // //                   child: RepaintBoundary(
// // //                     child: Container(
// // //                       decoration: BoxDecoration(
// // //                         gradient: LinearGradient(
// // //                           begin: Alignment.topCenter,
// // //                           end: Alignment.bottomCenter,
// // //                           colors: [
// // //                             Colors.transparent,
// // //                             Colors.black.withOpacity(0.4),
// // //                             Colors.black.withOpacity(0.95),
// // //                           ],
// // //                         ),
// // //                         boxShadow: [
// // //                           BoxShadow(
// // //                             color: Colors.black.withOpacity(0.9),
// // //                             blurRadius: 25,
// // //                             offset: const Offset(0, -15),
// // //                             spreadRadius: 5,
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       padding: const EdgeInsets.only(bottom: 25, left: 25, right: 25, top: 50),
// // //                       child: RepaintBoundary(
// // //                         child: Row(
// // //                           children: [
// // //                             // Current time with stronger styling
// // //                             Container(
// // //                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// // //                               decoration: BoxDecoration(
// // //                                 color: Colors.black.withOpacity(0.9),
// // //                                 borderRadius: BorderRadius.circular(15),
// // //                                 border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
// // //                                 boxShadow: [
// // //                                   BoxShadow(
// // //                                     color: Colors.black.withOpacity(0.7),
// // //                                     blurRadius: 8,
// // //                                     offset: const Offset(0, 2),
// // //                                   ),
// // //                                 ],
// // //                               ),
// // //                               child: Text(
// // //                                 _formatDuration(_displayPosition),
// // //                                 style: TextStyle(
// // //                                   color: _isSeeking ? Colors.yellow : Colors.white,
// // //                                   fontSize: 16,
// // //                                   fontWeight: FontWeight.bold,
// // //                                   shadows: [
// // //                                     Shadow(
// // //                                       color: Colors.black.withOpacity(0.8),
// // //                                       blurRadius: 4,
// // //                                       offset: const Offset(1, 1),
// // //                                     ),
// // //                                   ],
// // //                                 ),
// // //                               ),
// // //                             ),

// // //                             const SizedBox(width: 15),

// // //                             // Enhanced Progress slider with stronger visibility
// // //                             Expanded(
// // //                               child: RepaintBoundary(
// // //                                 child: SliderTheme(
// // //                                   data: SliderTheme.of(context).copyWith(
// // //                                     activeTrackColor: (_isSeeking || _isActuallySeekingVideo) ? Colors.yellow : Colors.red,
// // //                                     inactiveTrackColor: Colors.white.withOpacity(0.6),
// // //                                     thumbColor: (_isSeeking || _isActuallySeekingVideo) ? Colors.yellow : Colors.red,
// // //                                     thumbShape: RoundSliderThumbShape(
// // //                                       enabledThumbRadius: (_isSeeking || _isActuallySeekingVideo) ? 12.0 : 10.0,
// // //                                     ),
// // //                                     trackHeight: (_isSeeking || _isActuallySeekingVideo) ? 6.0 : 5.0,
// // //                                     overlayShape: const RoundSliderOverlayShape(
// // //                                       overlayRadius: 18.0,
// // //                                     ),
// // //                                   ),
// // //                                   child: Container(
// // //                                     decoration: BoxDecoration(
// // //                                       boxShadow: [
// // //                                         BoxShadow(
// // //                                           color: Colors.black.withOpacity(0.6),
// // //                                           blurRadius: 6,
// // //                                           offset: const Offset(0, 2),
// // //                                         ),
// // //                                       ],
// // //                                     ),
// // //                                     child: Slider(
// // //                                       value: (_totalDuration <= 0) ? 0.0 : _displayPosition.clamp(0.0, _adjustedTotalDuration),
// // //                                       max: (_totalDuration <= 0) ? 1.0 : _adjustedTotalDuration,
// // //                                       onChanged: (_totalDuration <= 0) ? null : (value) {
// // //                                         if (!(_isSeeking || _isActuallySeekingVideo)) {
// // //                                           final adjustedEndTime = _totalDuration - 15;
// // //                                           final clampedValue = value.clamp(0.0, adjustedEndTime);
// // //                                           setState(() {
// // //                                             _isActuallySeekingVideo = true;
// // //                                             _currentPosition = clampedValue;
// // //                                           });
// // //                                           _controller.seekTo(Duration(seconds: clampedValue.toInt()));
// // //                                           Future.delayed(const Duration(milliseconds: 200), () {
// // //                                             if (mounted && !_isDisposed) {
// // //                                               setState(() {
// // //                                                 _isActuallySeekingVideo = false;
// // //                                               });
// // //                                             }
// // //                                           });
// // //                                         }
// // //                                       },
// // //                                     ),
// // //                                   ),
// // //                                 ),
// // //                               ),
// // //                             ),

// // //                             const SizedBox(width: 15),

// // //                             // Total duration with stronger styling
// // //                             Container(
// // //                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// // //                               decoration: BoxDecoration(
// // //                                 color: Colors.black.withOpacity(0.9),
// // //                                 borderRadius: BorderRadius.circular(15),
// // //                                 border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
// // //                                 boxShadow: [
// // //                                   BoxShadow(
// // //                                     color: Colors.black.withOpacity(0.7),
// // //                                     blurRadius: 8,
// // //                                     offset: const Offset(0, 2),
// // //                                   ),
// // //                                 ],
// // //                               ),
// // //                               child: Text(
// // //                                 _formatDuration(_adjustedTotalDuration),
// // //                                 style: const TextStyle(
// // //                                   color: Colors.white,
// // //                                   fontSize: 16,
// // //                                   fontWeight: FontWeight.bold,
// // //                                   shadows: [
// // //                                     Shadow(
// // //                                       color: Colors.black,
// // //                                       blurRadius: 4,
// // //                                       offset: Offset(1, 1),
// // //                                     ),
// // //                                   ],
// // //                                 ),
// // //                               ),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),

// // //               // Enhanced seeking indicator - Guaranteed top layer
// // //               if (_showSeekingIndicator)
// // //                 Positioned(
// // //                   top: screenhgt * 0.4,
// // //                   left: 0,
// // //                   right: 0,
// // //                   child: Center(
// // //                     child: RepaintBoundary(
// // //                       child: Container(
// // //                         padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
// // //                         decoration: BoxDecoration(
// // //                           color: Colors.black.withOpacity(0.95),
// // //                           borderRadius: BorderRadius.circular(30),
// // //                           border: Border.all(color: Colors.yellow, width: 3),
// // //                           boxShadow: [
// // //                             BoxShadow(
// // //                               color: Colors.black.withOpacity(0.8),
// // //                               blurRadius: 20,
// // //                               offset: const Offset(0, 5),
// // //                               spreadRadius: 3,
// // //                             ),
// // //                           ],
// // //                         ),
// // //                         child: Column(
// // //                           mainAxisSize: MainAxisSize.min,
// // //                           children: [
// // //                             Text(
// // //                               '${_pendingSeekSeconds > 0 ? "⏩ +" : "⏪ "}${_pendingSeekSeconds}s',
// // //                               style: const TextStyle(
// // //                                 color: Colors.yellow,
// // //                                 fontSize: 24,
// // //                                 fontWeight: FontWeight.bold,
// // //                                 shadows: [
// // //                                   Shadow(
// // //                                     color: Colors.black,
// // //                                     blurRadius: 6,
// // //                                     offset: Offset(2, 2),
// // //                                   ),
// // //                                 ],
// // //                               ),
// // //                             ),
// // //                             const SizedBox(height: 6),
// // //                             Text(
// // //                               _formatDuration(_targetSeekPosition.inSeconds.toDouble()),
// // //                               style: const TextStyle(
// // //                                 color: Colors.white,
// // //                                 fontSize: 16,
// // //                                 fontWeight: FontWeight.w600,
// // //                                 shadows: [
// // //                                   Shadow(
// // //                                     color: Colors.black,
// // //                                     blurRadius: 4,
// // //                                     offset: Offset(1, 1),
// // //                                   ),
// // //                                 ],
// // //                               ),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   void dispose() {
// // //     print('🗑️ Disposing YouTube player...');

// // //     _isDisposed = true;

// // //     // Cancel all timers
// // //     _timer?.cancel();
// // //     _seekTimer?.cancel();
// // //     _seekIndicatorTimer?.cancel();

// // //     // Dispose controller
// // //     try {
// // //       if (_controller.value.isPlaying) {
// // //         _controller.pause();
// // //       }
// // //       _controller.dispose();
// // //     } catch (e) {
// // //       print('Error disposing controller: $e');
// // //     }

// // //     // Dispose focus node
// // //     _mainFocusNode.dispose();

// // //     // Restore system UI
// // //     try {
// // //       SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
// // //       SystemChrome.setPreferredOrientations([
// // //         DeviceOrientation.portraitUp,
// // //         DeviceOrientation.portraitDown,
// // //         DeviceOrientation.landscapeLeft,
// // //         DeviceOrientation.landscapeRight,
// // //       ]);
// // //     } catch (e) {
// // //       print('Error restoring system UI: $e');
// // //     }

// // //     super.dispose();
// // //   }
// // // }

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:keep_screen_on/keep_screen_on.dart';
// // import 'package:mobi_tv_entertainment/main.dart';
// // import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// // import 'dart:async';

// // // Direct YouTube Player Screen - No Home Page Required
// // class CustomYoutubePlayer extends StatefulWidget {
// //   final String videoUrl;

// //   const CustomYoutubePlayer({
// //     Key? key,
// //     required this.videoUrl,
// //   }) : super(key: key);

// //   @override
// //   _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
// // }

// // class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
// //   YoutubePlayerController? _controller;
// //   int currentIndex = 0;
// //   bool _isPlayerReady = false;
// //   String? _error;
// //   bool _isLoading = true;
// //   bool _isDisposed = false; // Track disposal state

// //   // Navigation control - FIXED
// //   bool _isNavigating = false; // Prevent double navigation
// //   bool _videoCompleted = false; // Track video completion

// //   // Splash screen control with fade animation
// //   bool _showSplashScreen = true;
// //   Timer? _splashTimer;
// //   Timer? _splashUpdateTimer;
// //   DateTime? _splashStartTime;

// //   // End splash screen control with fade animation
// //   bool _showEndSplashScreen = false;
// //   Timer? _endSplashTimer;
// //   DateTime? _endSplashStartTime;

// //   // Animation controllers for fade effects
// //   double _splashOpacity = 1.0; // Start fully black (opacity = 1.0)
// //   double _endSplashOpacity = 0.0; // End starts transparent (opacity = 0.0)
// //   Timer? _fadeAnimationTimer;

// //   // Control states
// //   bool _showControls = true;
// //   bool _isPlaying = false;
// //   Duration _currentPosition = Duration.zero;
// //   Duration _totalDuration = Duration.zero;
// //   Timer? _hideControlsTimer;

// //   // Progressive seeking states
// //   Timer? _seekTimer;
// //   int _pendingSeekSeconds = 0;
// //   Duration _targetSeekPosition = Duration.zero;
// //   bool _isSeeking = false;

// //   // Focus nodes for TV remote
// //   final FocusNode _playPauseFocusNode = FocusNode();
// //   final FocusNode _progressFocusNode = FocusNode();
// //   final FocusNode _mainFocusNode = FocusNode(); // Main invisible focus node
// //   bool _isProgressFocused = false;

// //   // REMOVED: All pause container/black bar states and timers

// //   @override
// //   void initState() {
// //     super.initState();
// //     KeepScreenOn.turnOn();

// //     print('📱 App started - Quick setup mode');

// //     // Set full screen immediately
// //     _setFullScreenMode();

// //     // Start player initialization immediately
// //     _initializePlayer();

// //     // Start 30 second fade splash timer
// //     _startSplashTimer();

// //     // Request focus on main node initially
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _mainFocusNode.requestFocus();
// //       // Show controls initially for testing (will be hidden during splash)
// //       if (!_showSplashScreen) {
// //         _showControlsTemporarily();
// //       }
// //     });
// //   }

// //   void _startSplashTimer() {
// //     _splashStartTime = DateTime.now(); // Record start time
// //     print(
// //         '🎬 Top/Bottom black bars started - will remove after exactly 12 seconds');

// //     // Simple timer - EXACTLY 12 seconds, no fade
// //     _splashTimer = Timer(const Duration(seconds: 12), () {
// //       if (mounted && !_isDisposed && _showSplashScreen) {
// //         print('🎬 12 seconds complete - removing top/bottom black bars');

// //         // setState(() {
// //         //   _showSplashScreen = false;
// //         // });

// //         // Show controls when splash is gone
// //         Future.delayed(const Duration(milliseconds: 500), () {
// //           if (mounted && !_isDisposed) {
// //             _showControlsTemporarily();
// //             print('🎮 Controls are now available after 12 seconds');
// //           }
// //         });
// //       }
// //     });

// //     // Timer to update countdown display every second
// //     _splashUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
// //       if (mounted && _showSplashScreen && !_isDisposed) {
// //         final remaining = _getRemainingSeconds();
// //         print('⏰ Top/Bottom black bars: ${remaining} seconds remaining');
// //       } else {
// //         timer.cancel();
// //       }
// //     });
// //   }

// //   void _setFullScreenMode() {
// //     // TV ke liye optimized settings
// //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

// //     // TV landscape orientation
// //     SystemChrome.setPreferredOrientations([
// //       DeviceOrientation.landscapeLeft,
// //       DeviceOrientation.landscapeRight,
// //     ]);

// //     // TV ke liye additional settings
// //     SystemChrome.setSystemUIOverlayStyle(
// //       const SystemUiOverlayStyle(
// //         statusBarColor: Colors.transparent,
// //         systemNavigationBarColor: Colors.transparent,
// //       ),
// //     );
// //   }

// //   void _initializePlayer() {
// //     if (_isDisposed) return; // Don't initialize if disposed

// //     try {
// //       String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

// //       print('🔧 TV Mode: Initializing player for: $videoId');

// //       if (videoId == null || videoId.isEmpty) {
// //         if (mounted && !_isDisposed) {
// //           setState(() {
// //             _error = 'Invalid YouTube URL: ${widget.videoUrl}';
// //             _isLoading = false;
// //           });
// //         }
// //         return;
// //       }

// //       // TV-specific controller configuration - NO MUTING + START FROM 10 SECONDS
// //       _controller = YoutubePlayerController(
// //         initialVideoId: videoId,
// //         flags: const YoutubePlayerFlags(
// //           mute: false, // NO MUTING - sound stays on
// //           autoPlay: true,
// //           disableDragSeek: false,
// //           loop: false,
// //           isLive: false,
// //           forceHD: true,
// //           enableCaption: false,
// //           controlsVisibleAtStart: true,
// //           hideControls: true,
// //           startAt: 10, // START FROM 10 SECONDS - SKIP FIRST 10 SECONDS
// //           hideThumbnail: false,
// //           useHybridComposition: false,
// //         ),
// //       );

// //       _controller!.addListener(_listener);

// //       // TV ke liye manual load aur play
// //       Future.delayed(const Duration(milliseconds: 300), () {
// //         if (mounted && _controller != null && !_isDisposed) {
// //           print('🎯 TV: Loading video manually');
// //           _controller!.load(videoId);

// //           // Multiple play attempts for TV
// //           Future.delayed(const Duration(milliseconds: 800), () {
// //             if (mounted && _controller != null && !_isDisposed) {
// //               print('🎬 TV: First play attempt (with sound)');
// //               _controller!.play();
// //               if (mounted) {
// //                 setState(() {
// //                   _isLoading = false;
// //                   _isPlayerReady = true;
// //                   _isPlaying = true;
// //                 });
// //               }
// //             }
// //           });
// //         }
// //       });
// //     } catch (e) {
// //       print('❌ TV Error: $e');
// //       if (mounted && !_isDisposed) {
// //         setState(() {
// //           _error = 'TV Error: $e';
// //           _isLoading = false;
// //         });
// //       }
// //     }
// //   }

// //   // FIXED: Single navigation trigger
// //   void _listener() {
// //     if (_controller != null && mounted && !_isDisposed && !_isNavigating) {
// //       if (_controller!.value.isReady && !_isPlayerReady) {
// //         print('📡 Controller ready detected - starting from beginning');

// //         // Ensure video starts from beginning
// //         _controller!.play();

// //         if (mounted) {
// //           setState(() {
// //             _isPlayerReady = true;
// //             _isPlaying = true;
// //           });
// //         }
// //       }

// //       // Update position and duration
// //       if (mounted) {
// //         setState(() {
// //           _currentPosition = _controller!.value.position;
// //           _totalDuration = _controller!.value.metaData.duration;

// //           // REMOVED: All pause container logic
// //           bool newIsPlaying = _controller!.value.isPlaying;
// //           _isPlaying = newIsPlaying;
// //         });
// //       }

// //       // FIXED: Single navigation trigger with proper checks
// //       if (_totalDuration.inSeconds > 24 &&
// //           _currentPosition.inSeconds > 0 &&
// //           !_videoCompleted) {
// //         final adjustedEndTime = _totalDuration.inSeconds - 12;

// //         if (_currentPosition.inSeconds >= adjustedEndTime) {
// //           print('🛑 Video reached cut point - completing video');
// //           _completeVideo(); // Single method for video completion
// //         }
// //       }
// //     }
// //   }

// //   // NEW: Single method to handle video completion
// //   void _completeVideo() {
// //     if (_isNavigating || _videoCompleted || _isDisposed) return;

// //     print('🎬 Video completing - single navigation trigger');

// //     // Mark as completed to prevent multiple triggers
// //     _videoCompleted = true;
// //     _isNavigating = true;

// //     // Pause the video
// //     if (_controller != null) {
// //       _controller!.pause();
// //     }

// //     // Single navigation with cleanup
// //     Future.delayed(const Duration(milliseconds: 800), () {
// //       if (mounted && !_isDisposed) {
// //         print('🔙 Navigating back to source page');
// //         Navigator.of(context).pop();
// //       }
// //     });
// //   }

// //   // NEW: Reset states for new video
// //   void _resetVideoStates() {
// //     _isNavigating = false;
// //     _videoCompleted = false;
// //     _isPlayerReady = false;
// //     _isPlaying = false;
// //   }

// //   void _startHideControlsTimer() {
// //     // Controls hide timer works normally - only splash blocks controls, not this timer
// //     if (_isDisposed) return;

// //     _hideControlsTimer?.cancel();
// //     _hideControlsTimer = Timer(const Duration(seconds: 5), () {
// //       if (mounted && _showControls && !_isDisposed) {
// //         setState(() {
// //           _showControls = false;
// //         });
// //         // When controls hide, focus goes back to main invisible node
// //         _mainFocusNode.requestFocus();
// //       }
// //     });
// //   }

// //   void _showControlsTemporarily() {
// //     // Controls show normally - splash blocking is handled in key events
// //     if (_isDisposed) return;

// //     if (mounted) {
// //       setState(() {
// //         _showControls = true;
// //       });
// //     }

// //     // When controls show, focus on play/pause button
// //     _playPauseFocusNode.requestFocus();
// //     _startHideControlsTimer();
// //   }

// //   void _togglePlayPause() {
// //     if (_controller != null && _isPlayerReady && !_isDisposed) {
// //       if (_isPlaying) {
// //         _controller!.pause();
// //         print('⏸️ Video paused');
// //         // REMOVED: Pause container logic
// //       } else {
// //         _controller!.play();
// //         print('▶️ Video playing');
// //         // REMOVED: Pause container timer logic
// //       }
// //     }
// //     _showControlsTemporarily();
// //   }

// //   void _seekVideo(bool forward) {
// //     if (_controller != null &&
// //         _isPlayerReady &&
// //         _totalDuration.inSeconds > 24 &&
// //         !_isDisposed) {
// //       final adjustedEndTime =
// //           _totalDuration.inSeconds - 12; // Don't allow seeking beyond cut point
// //       final seekAmount =
// //           (adjustedEndTime / 200).round().clamp(5, 30); // 5-30 seconds

// //       // Cancel previous seek timer
// //       _seekTimer?.cancel();

// //       // Calculate new pending seek
// //       if (forward) {
// //         _pendingSeekSeconds += seekAmount;
// //         print(
// //             '⏩ Adding forward seek: +${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
// //       } else {
// //         _pendingSeekSeconds -= seekAmount;
// //         print(
// //             '⏪ Adding backward seek: -${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
// //       }

// //       // Calculate target position for preview - RESPECT END CUT BOUNDARY
// //       final currentSeconds = _currentPosition.inSeconds;
// //       final targetSeconds = (currentSeconds + _pendingSeekSeconds)
// //           .clamp(0, adjustedEndTime); // 0 to end-12s
// //       _targetSeekPosition = Duration(seconds: targetSeconds);

// //       // Show seeking state
// //       if (mounted && !_isDisposed) {
// //         setState(() {
// //           _isSeeking = true;
// //         });
// //       }

// //       // Set timer to execute seek after 1 second of no input
// //       _seekTimer = Timer(const Duration(milliseconds: 1000), () {
// //         _executeSeek();
// //       });

// //       _showControlsTemporarily();
// //     }
// //   }

// //   void _executeSeek() {
// //     if (_controller != null &&
// //         _isPlayerReady &&
// //         !_isDisposed &&
// //         _pendingSeekSeconds != 0) {
// //       final adjustedEndTime =
// //           _totalDuration.inSeconds - 12; // Don't seek beyond cut point
// //       final currentSeconds = _currentPosition.inSeconds;
// //       final newPosition = (currentSeconds + _pendingSeekSeconds)
// //           .clamp(0, adjustedEndTime); // Respect end cut boundary

// //       print(
// //           '🎯 Executing accumulated seek: ${_pendingSeekSeconds}s to position ${newPosition}s (within cut boundaries)');

// //       // Execute the seek
// //       _controller!.seekTo(Duration(seconds: newPosition));

// //       // Reset seeking state
// //       _pendingSeekSeconds = 0;
// //       _targetSeekPosition = Duration.zero;

// //       if (mounted && !_isDisposed) {
// //         setState(() {
// //           _isSeeking = false;
// //         });
// //       }
// //     }
// //   }

// //   // Start end splash screen when 30 seconds remain - SOLID BLACK
// //   void _startEndSplashTimer() {
// //     if (_showEndSplashScreen || _isDisposed)
// //       return; // Prevent multiple triggers

// //     _endSplashStartTime = DateTime.now();
// //     print('🎬 End solid black splash started - will show for 30 seconds');

// //     setState(() {
// //       _showEndSplashScreen = true;
// //     });

// //     // Simple timer for end splash - 30 seconds solid black
// //     _endSplashTimer = Timer(const Duration(seconds: 30), () {
// //       if (mounted && !_isDisposed) {
// //         print('🎬 End splash complete - ready for navigation');

// //         setState(() {
// //           _showEndSplashScreen = false;
// //         });
// //       }
// //     });

// //     print('⏰ End solid black splash started - will cover video completely');
// //   }

// //   // // Helper method to check if controls should be blocked (only first 8 seconds)
// //   // bool _shouldBlockControls() {
// //   //   if (_showSplashScreen && _splashStartTime != null) {
// //   //     final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
// //   //     return elapsed < 8; // Block only for first 8 seconds
// //   //   }
// //   //   return false;
// //   // }

// //   // BLOCK controls only for first 8 seconds of splash
// //   bool _handleKeyEvent(RawKeyEvent event) {
// //     if (_isDisposed) return false;

// //     // // BLOCK key events only during first 8 seconds of splash screen
// //     // if (_shouldBlockControls()) {
// //     //   if (event is RawKeyDownEvent) {
// //     //     switch (event.logicalKey) {
// //     //       case LogicalKeyboardKey.escape:
// //     //       case LogicalKeyboardKey.backspace:
// //     //         // Allow back navigation during splash
// //     //         print('🔙 Back pressed during splash - exiting');
// //     //         if (!_isDisposed) {
// //     //           Navigator.of(context).pop();
// //     //         }
// //     //         return true;
// //     //       default:
// //     //         // Block other keys only for 8 seconds
// //     //         print(
// //     //             '🚫 Key blocked during first 8 seconds of splash: ${event.logicalKey}');
// //     //         return true;
// //     //     }
// //     //   }
// //     //   return true;
// //     // }

// //     // Normal key handling after splash is gone
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

// //         case LogicalKeyboardKey.arrowUp:
// //         case LogicalKeyboardKey.arrowDown:
// //           if (!_showControls) {
// //             _showControlsTemporarily();
// //           } else {
// //             if (_playPauseFocusNode.hasFocus) {
// //               _progressFocusNode.requestFocus();
// //             } else if (_progressFocusNode.hasFocus) {
// //               _playPauseFocusNode.requestFocus();
// //             } else {
// //               _playPauseFocusNode.requestFocus();
// //             }
// //             _showControlsTemporarily();
// //           }
// //           return true;

// //         case LogicalKeyboardKey.escape:
// //         case LogicalKeyboardKey.backspace:
// //           if (!_isDisposed) {
// //             Navigator.of(context).pop();
// //           }
// //           return true;

// //         default:
// //           if (!_showControls) {
// //             _showControlsTemporarily();
// //             return true;
// //           }
// //           break;
// //       }
// //     }
// //     return false;
// //   }

// //   void _showError(String message) {
// //     if (mounted && !_isDisposed) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(message),
// //           backgroundColor: Colors.red,
// //           duration: const Duration(seconds: 3),
// //         ),
// //       );
// //     }
// //   }

// //   // FIXED: Handle back button press - TV Remote ke liye
// //   Future<bool> _onWillPop() async {
// //     if (_isDisposed || _isNavigating) return true;

// //     try {
// //       print('🔙 Back button pressed - cleaning up...');

// //       // Mark as navigating to prevent other triggers
// //       _isNavigating = true;
// //       _isDisposed = true;

// //       // Cancel all timers
// //       _hideControlsTimer?.cancel();
// //       _splashTimer?.cancel();
// //       _splashUpdateTimer?.cancel();
// //       _seekTimer?.cancel();
// //       // REMOVED: _pauseContainerTimer?.cancel();

// //       // Pause and dispose controller
// //       if (_controller != null) {
// //         try {
// //           if (_controller!.value.isPlaying) {
// //             _controller!.pause();
// //           }
// //           _controller!.dispose();
// //           _controller = null;
// //         } catch (e) {
// //           print('Error disposing controller: $e');
// //         }
// //       }

// //       // Restore system UI in a try-catch
// //       try {
// //         await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
// //             overlays: SystemUiOverlay.values);

// //         // Reset orientation to allow all orientations
// //         await SystemChrome.setPreferredOrientations([
// //           DeviceOrientation.portraitUp,
// //           DeviceOrientation.portraitDown,
// //           DeviceOrientation.landscapeLeft,
// //           DeviceOrientation.landscapeRight,
// //         ]);
// //       } catch (e) {
// //         print('Error restoring system UI: $e');
// //       }

// //       return true; // Allow back navigation
// //     } catch (e) {
// //       print('Error in _onWillPop: $e');
// //       return true;
// //     }
// //   }

// //   @override
// //   void deactivate() {
// //     print('🔄 Screen deactivating...');
// //     _isDisposed = true;
// //     _controller?.pause();
// //     _splashTimer?.cancel();
// //     // REMOVED: _pauseContainerTimer?.cancel();
// //     super.deactivate();
// //   }

// //   @override
// //   void dispose() {
// //     print('🗑️ Disposing YouTube player screen...');

// //     try {
// //       // Mark as disposed
// //       _isDisposed = true;

// //       // Cancel timers
// //       _hideControlsTimer?.cancel();
// //       _seekTimer?.cancel();
// //       _splashTimer?.cancel();
// //       _splashUpdateTimer?.cancel();
// //       // REMOVED: _pauseContainerTimer?.cancel();

// //       // Dispose focus nodes
// //       if (_mainFocusNode.hasListeners) {
// //         _mainFocusNode.dispose();
// //       }
// //       if (_playPauseFocusNode.hasListeners) {
// //         _playPauseFocusNode.dispose();
// //       }
// //       if (_progressFocusNode.hasListeners) {
// //         _progressFocusNode.dispose();
// //       }

// //       // Dispose controller
// //       if (_controller != null) {
// //         try {
// //           _controller!.pause();
// //           _controller!.dispose();
// //           _controller = null;
// //         } catch (e) {
// //           print('Error disposing controller in dispose: $e');
// //         }
// //       }

// //       // Restore system UI
// //       try {
// //         SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
// //             overlays: SystemUiOverlay.values);

// //         SystemChrome.setPreferredOrientations([
// //           DeviceOrientation.portraitUp,
// //           DeviceOrientation.portraitDown,
// //           DeviceOrientation.landscapeLeft,
// //           DeviceOrientation.landscapeRight,
// //         ]);
// //       } catch (e) {
// //         print('Error restoring system UI in dispose: $e');
// //       }
// //     } catch (e) {
// //       print('Error in dispose: $e');
// //     }
// // KeepScreenOn.turnOff();
// //     super.dispose();
// //   }

// //   String _formatDuration(Duration duration) {
// //     String twoDigits(int n) => n.toString().padLeft(2, '0');
// //     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
// //     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
// //     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Don't render if disposed
// //     if (_isDisposed) {
// //       return const Scaffold(
// //         body: Center(
// //           child: CircularProgressIndicator(),
// //         ),
// //       );
// //     }

// //     return RawKeyboardListener(
// //       focusNode: _mainFocusNode,
// //       autofocus: true,
// //       onKey: _handleKeyEvent,
// //       child: WillPopScope(
// //         onWillPop: _onWillPop,
// //         child: Scaffold(
// //           body: GestureDetector(
// //             onTap: _showControlsTemporarily, // Disable tap only during first 8 seconds
// //             behavior: HitTestBehavior.opaque,
// //             child: Stack(
// //               children: [
// //                 // Full screen video player (always present and playing in background)
// //                 _buildVideoPlayer(),

// //                 // Top/Bottom Black Bars - Show for 12 seconds with video playing in center
// //                 // if (_showSplashScreen)
// //                 // _buildTopBottomBlackBars(),

// //                 // REMOVED: Pause Black Bars functionality completely

// //                 // Custom Controls Overlay - Show after 8 seconds even during splash
// //                 //  _buildControlsOverlay(),

// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // REMOVED: _buildPauseBlackBars() method completely

// //   // Top and Bottom Black Bars - Video plays in center (Start Splash)

// //   Widget _buildTopBottomBlackBars() {
// //     return Stack(
// //       children: [
// //         // Top Black Bar - screenhgt/6 height
// //         Positioned(
// //           top: 0,
// //           left: 0,
// //           right: 0,
// //           height: screenhgt / 7,
// //           child: Container(
// //             color: Colors.black,
// //           ),
// //         ),
// //         // Bottom Black Bar - screenhgt/6 height
// //         Positioned(
// //           bottom: 0,
// //           left: 0,
// //           right: 0,
// //           height: screenhgt / 7,
// //           child: Container(
// //             color: Colors.black,
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   // Helper methods for splash countdown
// //   double _getSplashProgress() {
// //     if (_splashStartTime == null) return 0.0;

// //     final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
// //     final progress = elapsed / 12.0; // 12 seconds total
// //     return progress.clamp(0.0, 1.0);
// //   }

// //   int _getRemainingSeconds() {
// //     if (_splashStartTime == null) return 12;

// //     final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
// //     final remaining = 12 - elapsed;
// //     return remaining.clamp(0, 12);
// //   }

// //   Widget _buildVideoPlayer() {
// //     if (_error != null) {
// //       return Container(
// //         color: Colors.black,
// //         child: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               const Icon(Icons.error, color: Colors.red, size: 48),
// //               const SizedBox(height: 16),
// //               Text(_error!, style: const TextStyle(color: Colors.white)),
// //               const SizedBox(height: 16),
// //               ElevatedButton(
// //                 onPressed: () {
// //                   if (!_isDisposed && mounted) {
// //                     setState(() {
// //                       _isLoading = true;
// //                       _error = null;
// //                     });
// //                     _controller?.dispose();
// //                     _initializePlayer();
// //                   }
// //                 },
// //                 child: const Text('Retry'),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }

// //     if (_controller == null || _isLoading) {
// //       return Container(
// //         color: Colors.black,
// //         child: const Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               CircularProgressIndicator(color: Colors.red),
// //               SizedBox(height: 20),
// //               Text('Loading...',
// //                   style: TextStyle(color: Colors.white, fontSize: 18)),
// //             ],
// //           ),
// //         ),
// //       );
// //     }

// //     return Container(
// //       width: double.infinity,
// //       height: double.infinity,
// //       color: Colors.black,
// //       child: Stack(
// //         children: [
// //           YoutubePlayer(
// //             controller: _controller!,
// //             showVideoProgressIndicator: false,
// //             progressIndicatorColor: Colors.red,
// //             width: double.infinity,
// //             aspectRatio: 16 / 9,
// //             bufferIndicator: Container(
// //               color: Colors.black,
// //               child: const Center(
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     CircularProgressIndicator(color: Colors.red),
// //                     SizedBox(height: 10),
// //                     Text('Buffering...', style: TextStyle(color: Colors.white)),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //             onReady: () {
// //               print('📺 TV Player Ready - forcing video surface');
// //               if (!_isPlayerReady && !_isDisposed) {
// //                 if (mounted) {
// //                   setState(() => _isPlayerReady = true);
// //                 }

// //                 // Focus on main node when ready, controls will show when needed
// //                 Future.delayed(const Duration(milliseconds: 500), () {
// //                   if (!_isDisposed) {
// //                     _mainFocusNode.requestFocus();
// //                   }
// //                 });

// //                 // TV video surface activation - Start playing from beginning with sound
// //                 Future.delayed(const Duration(milliseconds: 100), () {
// //                   if (_controller != null && mounted && !_isDisposed) {
// //                     // Start from beginning
// //                     _controller!.play();
// //                     print(
// //                         '🎬 TV: Video started playing from beginning (with sound during black bars)');
// //                   }
// //                 });
// //               }
// //             },
// //             onEnded: (_) {
// //               if (_isDisposed || _isNavigating || _videoCompleted) return;

// //               print('🎬 Video ended naturally - using completion handler');
// //               _completeVideo(); // Use same completion method
// //             },
// //           ),

// //         ],
// //       ),
// //     );
// //   }
// // }

// // // // // SOLUTION: Native Video Player with YouTube URL Extraction
// // // // // Add these dependencies to pubspec.yaml:
// // // // /*
// // // // dependencies:
// // // //   video_player: ^2.7.2
// // // //   youtube_explode_dart: ^1.12.4
// // // //   http: ^0.13.6
// // // // */

// // // // // FIXED: Native Video Player with proper YouTube URL Extraction
// // // // // Add these dependencies to pubspec.yaml:
// // // // /*
// // // // dependencies:
// // // //   video_player: ^2.7.2
// // // //   youtube_explode_dart: ^1.12.4
// // // //   http: ^0.13.6
// // // // */

// // // // // FIXED: Native Video Player with proper YouTube URL Extraction
// // // // // Add these dependencies to pubspec.yaml:
// // // // /*
// // // // dependencies:
// // // //   video_player: ^2.7.2
// // // //   youtube_explode_dart: ^1.12.4
// // // //   http: ^0.13.6
// // // // */

// // // import 'package:mobi_tv_entertainment/main.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// // // import 'dart:async';

// // // class CustomYoutubePlayer extends StatefulWidget {
// // //   final String videoUrl;

// // //   const CustomYoutubePlayer({
// // //     Key? key,
// // //     required this.videoUrl,
// // //   }) : super(key: key);

// // //   @override
// // //   State<CustomYoutubePlayer> createState() => _CustomYoutubePlayerState();
// // // }

// // // class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
// // //   late YoutubePlayerController _controller;
// // //   Timer? _timer;
// // //   double _currentPosition = 0.0;
// // //   double _totalDuration = 1.0;
// // //   bool _isPlaying = false;
// // //   int _currentVideoIndex = 0;
// // //   List<String> _videoUrls = [];
// // //   bool _isPlayerReady = false;
// // //   bool _isLoading = true;
// // //   String? _error;

// // //   // Enhanced seeking state management
// // //   Timer? _seekTimer;
// // //   Timer? _seekIndicatorTimer;
// // //   int _pendingSeekSeconds = 0;
// // //   Duration _targetSeekPosition = Duration.zero;
// // //   bool _isSeeking = false;
// // //   bool _isActuallySeekingVideo = false;
// // //   bool _showSeekingIndicator = false;
// // //   double _lastKnownPosition = 0.0;

// // //   final FocusNode _mainFocusNode = FocusNode();
// // //   bool _videoCompleted = false;
// // //   bool _isNavigating = false;
// // //   bool _isDisposed = false;

// // //   @override
// // //   void initState() {
// // //     super.initState();

// // //     _setFullScreen();
// // //     _initializePlayer();

// // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // //       _mainFocusNode.requestFocus();
// // //     });
// // //   }

// // //   void _setFullScreen() {
// // //     // TV के लिए optimized full screen
// // //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
// // //     SystemChrome.setPreferredOrientations([
// // //       DeviceOrientation.landscapeLeft,
// // //       DeviceOrientation.landscapeRight,
// // //     ]);

// // //     // Additional TV settings
// // //     SystemChrome.setSystemUIOverlayStyle(
// // //       const SystemUiOverlayStyle(
// // //         statusBarColor: Colors.transparent,
// // //         systemNavigationBarColor: Colors.transparent,
// // //       ),
// // //     );
// // //   }

// // //   void _initializePlayer() {
// // //     if (_isDisposed) return;

// // //     try {
// // //       String currentVideoUrl = _videoUrls[_currentVideoIndex];
// // //       String? videoId = YoutubePlayer.convertUrlToId(currentVideoUrl);

// // //       print('🔧 TV Mode: Initializing player for: $videoId');

// // //       if (videoId == null || videoId.isEmpty) {
// // //         setState(() {
// // //           _error = 'Invalid YouTube URL: $currentVideoUrl';
// // //           _isLoading = false;
// // //         });
// // //         return;
// // //       }

// // //       // TV-specific controller configuration - FIXED FLAGS
// // //       _controller = YoutubePlayerController(
// // //         initialVideoId: videoId,
// // //         flags: const YoutubePlayerFlags(
// // //           mute: false,                    // Sound ON
// // //           autoPlay: true,                 // Auto play
// // //           disableDragSeek: false,         // Allow seeking
// // //           loop: false,                    // No loop
// // //           isLive: false,                  // Not live
// // //           forceHD: false,                 // Don't force HD (better compatibility)
// // //           enableCaption: false,           // No captions
// // //           controlsVisibleAtStart: false,  // Hide YouTube controls
// // //           hideControls: true,             // Hide YouTube controls completely
// // //           hideThumbnail: true,            // Hide thumbnail
// // //           useHybridComposition: false,    // CRITICAL: FALSE for TV compatibility
// // //           startAt: 0,                     // Start from beginning
// // //         ),
// // //       );

// // //       _controller.addListener(_playerListener);

// // //       // TV के लिए manual load और play sequence
// // //       Future.delayed(const Duration(milliseconds: 500), () {
// // //         if (mounted && !_isDisposed) {
// // //           print('🎯 TV: Loading video manually');
// // //           _controller.load(videoId);

// // //           // Multiple play attempts for TV compatibility
// // //           Future.delayed(const Duration(milliseconds: 1000), () {
// // //             if (mounted && !_isDisposed) {
// // //               print('🎬 TV: First play attempt');
// // //               _controller.play();

// // //               setState(() {
// // //                 _isLoading = false;
// // //                 _isPlayerReady = true;
// // //                 _isPlaying = true;
// // //               });

// // //               // Start progress timer after player is ready
// // //               _startProgressTimer();
// // //             }
// // //           });

// // //           // Backup play attempt
// // //           Future.delayed(const Duration(milliseconds: 2000), () {
// // //             if (mounted && !_isDisposed && !_controller.value.isPlaying) {
// // //               print('🎬 TV: Backup play attempt');
// // //               _controller.play();
// // //             }
// // //           });
// // //         }
// // //       });

// // //     } catch (e) {
// // //       print('❌ TV Error: $e');
// // //       if (mounted && !_isDisposed) {
// // //         setState(() {
// // //           _error = 'TV Error: $e';
// // //           _isLoading = false;
// // //         });
// // //       }
// // //     }
// // //   }

// // //   void _playerListener() {
// // //     if (_isDisposed) return;

// // //     if (_controller.value.isReady && !_isPlayerReady) {
// // //       print('📡 Controller ready detected');

// // //       // Ensure video starts playing
// // //       if (!_controller.value.isPlaying) {
// // //         _controller.play();
// // //       }

// // //       setState(() {
// // //         _isPlayerReady = true;
// // //         _isPlaying = _controller.value.isPlaying;
// // //       });
// // //     }

// // //     // Update position and duration
// // //     if (mounted && !_isDisposed) {
// // //       setState(() {
// // //         _isPlaying = _controller.value.isPlaying;
// // //         _totalDuration = _controller.metadata.duration.inSeconds.toDouble();
// // //       });

// // //       // Video end cut logic
// // //       if (_totalDuration > 30 &&
// // //           _controller.value.position.inSeconds > 0 &&
// // //           !_videoCompleted &&
// // //           !_isNavigating) {

// // //         final adjustedEndTime = _totalDuration.toInt() - 15;

// // //         if (_controller.value.position.inSeconds >= adjustedEndTime) {
// // //           print('🛑 Video reached cut point (15s before end) - completing video');
// // //           _completeVideo();
// // //         }
// // //       }
// // //     }
// // //   }

// // //   void _completeVideo() {
// // //     if (_isNavigating || _videoCompleted || _isDisposed) return;

// // //     print('🎬 Video completing - 15 seconds before actual end');
// // //     _videoCompleted = true;
// // //     _isNavigating = true;

// // //     if (_controller.value.isPlaying) {
// // //       _controller.pause();
// // //     }

// // //     Future.delayed(const Duration(milliseconds: 500), () {
// // //       if (mounted && !_isDisposed) {
// // //         _playNextVideo();
// // //       }
// // //     });
// // //   }

// // //   void _resetVideoStates() {
// // //     _isNavigating = false;
// // //     _videoCompleted = false;
// // //     _currentPosition = 0.0;
// // //     _isSeeking = false;
// // //     _isActuallySeekingVideo = false;
// // //     _showSeekingIndicator = false;
// // //     _pendingSeekSeconds = 0;
// // //     _targetSeekPosition = Duration.zero;
// // //     _isPlayerReady = false;
// // //   }

// // //   void _startProgressTimer() {
// // //     _timer?.cancel(); // Cancel existing timer
// // //     _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
// // //       if (_isDisposed) {
// // //         timer.cancel();
// // //         return;
// // //       }

// // //       if (_controller.value.isReady) {
// // //         final newPosition = _controller.value.position.inSeconds.toDouble();

// // //         // If we're seeking, check if we've reached the target position
// // //         if (_isActuallySeekingVideo && _targetSeekPosition != Duration.zero) {
// // //           final targetPos = _targetSeekPosition.inSeconds.toDouble();
// // //           final tolerance = 1.5; // 1.5 second tolerance

// // //           if ((newPosition - targetPos).abs() <= tolerance) {
// // //             // We've reached target position, reset all seeking states
// // //             print('✅ Reached target position: ${newPosition}s (target was: ${targetPos}s)');
// // //             setState(() {
// // //               _currentPosition = newPosition;
// // //               _lastKnownPosition = newPosition;
// // //               _isActuallySeekingVideo = false;
// // //               _isSeeking = false;
// // //             });
// // //             _pendingSeekSeconds = 0;
// // //             _targetSeekPosition = Duration.zero;
// // //           }
// // //         } else if (!_isSeeking && !_isActuallySeekingVideo) {
// // //           // Normal position update when not seeking at all
// // //           setState(() {
// // //             _currentPosition = newPosition;
// // //             _lastKnownPosition = newPosition;
// // //           });
// // //         }
// // //       }
// // //     });
// // //   }

// // //   // Enhanced seeking with smooth progress bar
// // //   void _seekVideo(bool forward) {
// // //     if (_controller.value.isReady && _totalDuration > 30) {
// // //       final adjustedEndTime = _totalDuration.toInt() - 15;
// // //       final seekAmount = (adjustedEndTime / 200).round().clamp(5, 30);

// // //       // Store current position before seeking starts (only if not already seeking)
// // //       if (!_isSeeking && !_isActuallySeekingVideo) {
// // //         _lastKnownPosition = _currentPosition;
// // //       }

// // //       _seekTimer?.cancel();

// // //       // Calculate new pending seek
// // //       if (forward) {
// // //         _pendingSeekSeconds += seekAmount;
// // //         print('⏩ Adding forward seek: +${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
// // //       } else {
// // //         _pendingSeekSeconds -= seekAmount;
// // //         print('⏪ Adding backward seek: -${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
// // //       }

// // //       // Calculate target position - RESPECT END CUT BOUNDARY
// // //       final targetSeconds = (_lastKnownPosition.toInt() + _pendingSeekSeconds)
// // //           .clamp(0, adjustedEndTime);
// // //       _targetSeekPosition = Duration(seconds: targetSeconds);

// // //       // Show seeking state and indicator
// // //       setState(() {
// // //         _isSeeking = true;
// // //         _showSeekingIndicator = true;
// // //       });

// // //       print('🎯 Target seek position: ${targetSeconds}s');

// // //       // Set timer to execute actual seek
// // //       _seekTimer = Timer(const Duration(milliseconds: 1000), () {
// // //         _executeSeek();
// // //       });

// // //       // Set timer to hide seeking indicator after 3 seconds
// // //       _seekIndicatorTimer?.cancel();
// // //       _seekIndicatorTimer = Timer(const Duration(seconds: 3), () {
// // //         if (mounted && !_isDisposed) {
// // //           setState(() {
// // //             _showSeekingIndicator = false;
// // //           });
// // //         }
// // //       });
// // //     }
// // //   }

// // //   void _executeSeek() {
// // //     if (_controller.value.isReady && _pendingSeekSeconds != 0 && !_isDisposed) {
// // //       final targetSeconds = _targetSeekPosition.inSeconds;

// // //       print('🎯 Executing accumulated seek to: ${targetSeconds}s');

// // //       // Set flag to prevent position updates during seeking
// // //       setState(() {
// // //         _isActuallySeekingVideo = true;
// // //         _currentPosition = targetSeconds.toDouble(); // Set target position
// // //       });

// // //       // Execute the actual video seek
// // //       try {
// // //         _controller.seekTo(Duration(seconds: targetSeconds));
// // //         print('⏳ Seek command sent, waiting for video to reach target position...');
// // //         // Don't reset states here - let the timer check when we actually reach the position
// // //       } catch (error) {
// // //         print('❌ Seek error: $error');
// // //         // Reset on error
// // //         setState(() {
// // //           _isActuallySeekingVideo = false;
// // //           _isSeeking = false;
// // //         });
// // //         _pendingSeekSeconds = 0;
// // //         _targetSeekPosition = Duration.zero;
// // //       }
// // //     }
// // //   }

// // //   bool _handleKeyEvent(RawKeyEvent event) {
// // //     if (_isDisposed) return false;

// // //     if (event is RawKeyDownEvent) {
// // //       switch (event.logicalKey) {
// // //         case LogicalKeyboardKey.select:
// // //         case LogicalKeyboardKey.enter:
// // //         case LogicalKeyboardKey.space:
// // //           _togglePlayPause();
// // //           return true;

// // //         case LogicalKeyboardKey.arrowLeft:
// // //           _seekVideo(false);
// // //           return true;

// // //         case LogicalKeyboardKey.arrowRight:
// // //           _seekVideo(true);
// // //           return true;

// // //         case LogicalKeyboardKey.escape:
// // //         case LogicalKeyboardKey.backspace:
// // //           if (!_isDisposed) {
// // //             Navigator.of(context).pop();
// // //           }
// // //           return true;

// // //         default:
// // //           break;
// // //       }
// // //     }
// // //     return false;
// // //   }

// // //   void _togglePlayPause() {
// // //     if (_controller.value.isReady && !_isDisposed) {
// // //       if (_isPlaying) {
// // //         _controller.pause();
// // //         print('⏸️ Video paused');
// // //       } else {
// // //         _controller.play();
// // //         print('▶️ Video playing');
// // //       }
// // //     }
// // //   }

// // //   void _playNextVideo() {
// // //     if (_isDisposed) return;

// // //     if (_currentVideoIndex < _videoUrls.length - 1) {
// // //       setState(() {
// // //         _currentVideoIndex++;
// // //         _isLoading = true;
// // //         _error = null;
// // //       });
// // //       _resetVideoStates();
// // //       _controller.dispose();
// // //       _initializePlayer();
// // //     } else {
// // //       print('📱 Playlist complete - exiting player');
// // //       if (!_isDisposed) {
// // //         Navigator.of(context).pop();
// // //       }
// // //     }
// // //   }

// // //   void _playPreviousVideo() {
// // //     if (_isDisposed) return;

// // //     if (_currentVideoIndex > 0) {
// // //       setState(() {
// // //         _currentVideoIndex--;
// // //         _isLoading = true;
// // //         _error = null;
// // //       });
// // //       _resetVideoStates();
// // //       _controller.dispose();
// // //       _initializePlayer();
// // //     }
// // //   }

// // //   String _formatDuration(double seconds) {
// // //     int minutes = (seconds / 60).floor();
// // //     int remainingSeconds = (seconds % 60).floor();
// // //     return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
// // //   }

// // //   double get _adjustedTotalDuration {
// // //     if (_totalDuration > 30) {
// // //       return _totalDuration - 15;
// // //     }
// // //     return _totalDuration;
// // //   }

// // //   // Get display position for progress bar
// // //   double get _displayPosition {
// // //     if (_isSeeking || _isActuallySeekingVideo) {
// // //       return _targetSeekPosition.inSeconds.toDouble();
// // //     }
// // //     return _currentPosition;
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     if (_isDisposed) {
// // //       return const Scaffold(
// // //         body: Center(child: CircularProgressIndicator()),
// // //       );
// // //     }

// // //     return RawKeyboardListener(
// // //       focusNode: _mainFocusNode,
// // //       autofocus: true,
// // //       onKey: _handleKeyEvent,
// // //       child: WillPopScope(
// // //         onWillPop: () async {
// // //           _isDisposed = true;
// // //           return true;
// // //         },
// // //         child: Scaffold(
// // //           backgroundColor: Colors.black,
// // //           body: Stack(
// // //             children: [
// // //               // Error State
// // //               if (_error != null)
// // //                 Center(
// // //                   child: Column(
// // //                     mainAxisAlignment: MainAxisAlignment.center,
// // //                     children: [
// // //                       const Icon(Icons.error, color: Colors.red, size: 48),
// // //                       const SizedBox(height: 16),
// // //                       Text(_error!, style: const TextStyle(color: Colors.white)),
// // //                       const SizedBox(height: 16),
// // //                       ElevatedButton(
// // //                         onPressed: () {
// // //                           setState(() {
// // //                             _isLoading = true;
// // //                             _error = null;
// // //                           });
// // //                           _controller.dispose();
// // //                           _initializePlayer();
// // //                         },
// // //                         child: const Text('Retry'),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),

// // //               // Loading State
// // //               if (_isLoading && _error == null)
// // //                 const Center(
// // //                   child: Column(
// // //                     mainAxisAlignment: MainAxisAlignment.center,
// // //                     children: [
// // //                       CircularProgressIndicator(color: Colors.red),
// // //                       SizedBox(height: 20),
// // //                       Text('Loading for TV Display...',
// // //                           style: TextStyle(color: Colors.white, fontSize: 18)),
// // //                     ],
// // //                   ),
// // //                 ),

// // //               // YouTube Player - TV Compatible
// // //               if (!_isLoading && _error == null)
// // //                 SizedBox.expand(
// // //                   child: YoutubePlayer(
// // //                     controller: _controller,
// // //                     showVideoProgressIndicator: false,
// // //                     progressIndicatorColor: Colors.transparent,
// // //                     aspectRatio: 16 / 9,
// // //                     width: double.infinity,
// // //                     bufferIndicator: Container(
// // //                       color: Colors.black,
// // //                       child: const Center(
// // //                         child: Column(
// // //                           mainAxisAlignment: MainAxisAlignment.center,
// // //                           children: [
// // //                             CircularProgressIndicator(color: Colors.red),
// // //                             SizedBox(height: 10),
// // //                             Text('Buffering...', style: TextStyle(color: Colors.white)),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     onReady: () {
// // //                       print('📺 TV Player Ready - forcing play');
// // //                       if (!_isPlayerReady && !_isDisposed) {
// // //                         setState(() => _isPlayerReady = true);

// // //                         // Force play for TV
// // //                         Future.delayed(const Duration(milliseconds: 200), () {
// // //                           if (!_isDisposed) {
// // //                             _controller.play();
// // //                             print('🎬 TV: Video forced to play on ready');
// // //                           }
// // //                         });
// // //                       }
// // //                     },
// // //                     onEnded: (data) {
// // //                       print('Video ended naturally, playing next...');
// // //                       if (!_videoCompleted && !_isNavigating && !_isDisposed) {
// // //                         _completeVideo();
// // //                       }
// // //                     },
// // //                   ),
// // //                 ),

// // //               // Top black bar (only when video is playing)
// // //               if (!_isLoading && _error == null)
// // //                 Positioned(
// // //                   top: 0,
// // //                   left: 0,
// // //                   right: 0,
// // //                   child: Container(
// // //                     color: Colors.black,
// // //                     height: screenhgt * 0.1,
// // //                   ),
// // //                 ),

// // //               // Bottom Progress Bar
// // //               if (!_isLoading && _error == null)
// // //                 Positioned(
// // //                   bottom: 0,
// // //                   left: 0,
// // //                   right: 0,
// // //                   child: Container(
// // //                     color: Colors.black,
// // //                     height: screenhgt * 0.1,
// // //                     child: Row(
// // //                       children: [
// // //                         // Current time display
// // //                         Padding(
// // //                           padding: const EdgeInsets.only(left: 16.0),
// // //                           child: Text(
// // //                             _formatDuration(_displayPosition),
// // //                             style: TextStyle(
// // //                               color: _isSeeking ? Colors.yellow : Colors.white,
// // //                               fontSize: 12,
// // //                               fontWeight: _isSeeking ? FontWeight.bold : FontWeight.normal,
// // //                             ),
// // //                           ),
// // //                         ),

// // //                         // Enhanced Progress slider
// // //                         Expanded(
// // //                           child: Padding(
// // //                             padding: const EdgeInsets.symmetric(horizontal: 12.0),
// // //                             child: SliderTheme(
// // //                               data: SliderTheme.of(context).copyWith(
// // //                                 activeTrackColor: (_isSeeking || _isActuallySeekingVideo) ? Colors.yellow : Colors.red,
// // //                                 inactiveTrackColor: Colors.white.withOpacity(0.3),
// // //                                 thumbColor: (_isSeeking || _isActuallySeekingVideo) ? Colors.yellow : Colors.red,
// // //                                 thumbShape: RoundSliderThumbShape(
// // //                                   enabledThumbRadius: (_isSeeking || _isActuallySeekingVideo) ? 8.0 : 6.0,
// // //                                 ),
// // //                                 trackHeight: (_isSeeking || _isActuallySeekingVideo) ? 4.0 : 3.0,
// // //                                 overlayShape: const RoundSliderOverlayShape(
// // //                                   overlayRadius: 12.0,
// // //                                 ),
// // //                               ),
// // //                               child: Slider(
// // //                                 value: _displayPosition.clamp(0.0, _adjustedTotalDuration),
// // //                                 max: _adjustedTotalDuration,
// // //                                 onChanged: (value) {
// // //                                   if (!(_isSeeking || _isActuallySeekingVideo)) {
// // //                                     final adjustedEndTime = _totalDuration - 15;
// // //                                     final clampedValue = value.clamp(0.0, adjustedEndTime);
// // //                                     setState(() {
// // //                                       _isActuallySeekingVideo = true;
// // //                                       _currentPosition = clampedValue;
// // //                                     });
// // //                                     _controller.seekTo(Duration(seconds: clampedValue.toInt()));
// // //                                     Future.delayed(const Duration(milliseconds: 200), () {
// // //                                       if (mounted && !_isDisposed) {
// // //                                         setState(() {
// // //                                           _isActuallySeekingVideo = false;
// // //                                         });
// // //                                       }
// // //                                     });
// // //                                   }
// // //                                 },
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ),

// // //                         // Total duration display
// // //                         Padding(
// // //                           padding: const EdgeInsets.only(right: 16.0),
// // //                           child: Text(
// // //                             _formatDuration(_adjustedTotalDuration),
// // //                             style: const TextStyle(color: Colors.white, fontSize: 12),
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                 ),

// // //               // Enhanced seeking indicator
// // //               if (_showSeekingIndicator)
// // //                 Positioned(
// // //                   top: screenhgt * 0.4,
// // //                   left: 0,
// // //                   right: 0,
// // //                   child: Center(
// // //                     child: Container(
// // //                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
// // //                       decoration: BoxDecoration(
// // //                         color: Colors.black.withOpacity(0.9),
// // //                         borderRadius: BorderRadius.circular(25),
// // //                         border: Border.all(color: Colors.yellow, width: 2),
// // //                       ),
// // //                       child: Column(
// // //                         mainAxisSize: MainAxisSize.min,
// // //                         children: [
// // //                           Text(
// // //                             '${_pendingSeekSeconds > 0 ? "⏩ +" : "⏪ "}${_pendingSeekSeconds}s',
// // //                             style: const TextStyle(
// // //                               color: Colors.yellow,
// // //                               fontSize: 20,
// // //                               fontWeight: FontWeight.bold,
// // //                             ),
// // //                           ),
// // //                           const SizedBox(height: 4),
// // //                           Text(
// // //                             _formatDuration(_targetSeekPosition.inSeconds.toDouble()),
// // //                             style: const TextStyle(
// // //                               color: Colors.white,
// // //                               fontSize: 14,
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   void dispose() {
// // //     print('🗑️ Disposing YouTube player...');

// // //     _isDisposed = true;

// // //     // Cancel all timers
// // //     _timer?.cancel();
// // //     _seekTimer?.cancel();
// // //     _seekIndicatorTimer?.cancel();

// // //     // Dispose controller
// // //     try {
// // //       if (_controller.value.isPlaying) {
// // //         _controller.pause();
// // //       }
// // //       _controller.dispose();
// // //     } catch (e) {
// // //       print('Error disposing controller: $e');
// // //     }

// // //     // Dispose focus node
// // //     _mainFocusNode.dispose();

// // //     // Restore system UI
// // //     try {
// // //       SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
// // //       SystemChrome.setPreferredOrientations([
// // //         DeviceOrientation.portraitUp,
// // //         DeviceOrientation.portraitDown,
// // //         DeviceOrientation.landscapeLeft,
// // //         DeviceOrientation.landscapeRight,
// // //       ]);
// // //     } catch (e) {
// // //       print('Error restoring system UI: $e');
// // //     }

// // //     super.dispose();
// // //   }
// // // }

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:keep_screen_on/keep_screen_on.dart';
// // import 'package:mobi_tv_entertainment/main.dart';
// // import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// // import 'dart:async';

// // // Direct YouTube Player Screen - No Home Page Required
// // class CustomYoutubePlayer extends StatefulWidget {
// //   final String videoUrl;

// //   const CustomYoutubePlayer({
// //     Key? key,
// //     required this.videoUrl,
// //   }) : super(key: key);

// //   @override
// //   _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
// // }

// // class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
// //   YoutubePlayerController? _controller;
// //   int currentIndex = 0;
// //   bool _isPlayerReady = false;
// //   String? _error;
// //   bool _isLoading = true;
// //   bool _isDisposed = false; // Track disposal state

// //   // Navigation control - FIXED
// //   bool _isNavigating = false; // Prevent double navigation
// //   bool _videoCompleted = false; // Track video completion

// //   // Splash screen control with fade animation
// //   bool _showSplashScreen = true;
// //   Timer? _splashTimer;
// //   Timer? _splashUpdateTimer;
// //   DateTime? _splashStartTime;

// //   // End splash screen control with fade animation
// //   bool _showEndSplashScreen = false;
// //   Timer? _endSplashTimer;
// //   DateTime? _endSplashStartTime;

// //   // Animation controllers for fade effects
// //   double _splashOpacity = 1.0; // Start fully black (opacity = 1.0)
// //   double _endSplashOpacity = 0.0; // End starts transparent (opacity = 0.0)
// //   Timer? _fadeAnimationTimer;

// //   // Control states
// //   bool _showControls = true;
// //   bool _isPlaying = false;
// //   Duration _currentPosition = Duration.zero;
// //   Duration _totalDuration = Duration.zero;
// //   Timer? _hideControlsTimer;

// //   // Progressive seeking states
// //   Timer? _seekTimer;
// //   int _pendingSeekSeconds = 0;
// //   Duration _targetSeekPosition = Duration.zero;
// //   bool _isSeeking = false;

// //   // Focus nodes for TV remote
// //   final FocusNode _playPauseFocusNode = FocusNode();
// //   final FocusNode _progressFocusNode = FocusNode();
// //   final FocusNode _mainFocusNode = FocusNode(); // Main invisible focus node
// //   bool _isProgressFocused = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     KeepScreenOn.turnOn();

// //     print('📱 App started - Quick setup mode');

// //     // Set full screen immediately
// //     _setFullScreenMode();

// //     // Start player initialization immediately
// //     _initializePlayer();

// //     // Start 30 second fade splash timer
// //     _startSplashTimer();

// //     // Request focus on main node initially
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _mainFocusNode.requestFocus();
// //       // Show controls initially for testing (will be hidden during splash)
// //       if (!_showSplashScreen) {
// //         _showControlsTemporarily();
// //       }
// //     });
// //   }

// //   void _startSplashTimer() {
// //     _splashStartTime = DateTime.now(); // Record start time
// //     print(
// //         '🎬 Top/Bottom black bars started - will remove after exactly 12 seconds');

// //     // Simple timer - EXACTLY 12 seconds, no fade
// //     _splashTimer = Timer(const Duration(seconds: 12), () {
// //       if (mounted && !_isDisposed && _showSplashScreen) {
// //         print('🎬 12 seconds complete - removing top/bottom black bars');

// //         setState(() {
// //           _showSplashScreen = false;
// //         });

// //         // Show controls when splash is gone
// //         Future.delayed(const Duration(milliseconds: 500), () {
// //           if (mounted && !_isDisposed) {
// //             _showControlsTemporarily();
// //             print('🎮 Controls are now available after 12 seconds');
// //           }
// //         });
// //       }
// //     });

// //     // Timer to update countdown display every second
// //     _splashUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
// //       if (mounted && _showSplashScreen && !_isDisposed) {
// //         final remaining = _getRemainingSeconds();
// //         print('⏰ Top/Bottom black bars: ${remaining} seconds remaining');
// //       } else {
// //         timer.cancel();
// //       }
// //     });
// //   }

// //   void _setFullScreenMode() {
// //     // TV ke liye optimized settings
// //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

// //     // TV landscape orientation
// //     SystemChrome.setPreferredOrientations([
// //       DeviceOrientation.landscapeLeft,
// //       DeviceOrientation.landscapeRight,
// //     ]);

// //     // TV ke liye additional settings
// //     SystemChrome.setSystemUIOverlayStyle(
// //       const SystemUiOverlayStyle(
// //         statusBarColor: Colors.transparent,
// //         systemNavigationBarColor: Colors.transparent,
// //       ),
// //     );
// //   }

// //   void _initializePlayer() {
// //     if (_isDisposed) return; // Don't initialize if disposed

// //     try {
// //       String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

// //       print('🔧 TV Mode: Initializing player for: $videoId');

// //       if (videoId == null || videoId.isEmpty) {
// //         if (mounted && !_isDisposed) {
// //           setState(() {
// //             _error = 'Invalid YouTube URL: ${widget.videoUrl}';
// //             _isLoading = false;
// //           });
// //         }
// //         return;
// //       }

// //       // TV-specific controller configuration - NO MUTING + START FROM 10 SECONDS
// //       _controller = YoutubePlayerController(
// //         initialVideoId: videoId,
// //         flags: const YoutubePlayerFlags(
// //           mute: false, // NO MUTING - sound stays on
// //           autoPlay: true,
// //           disableDragSeek: false,
// //           loop: false,
// //           isLive: false,
// //           forceHD: true,
// //           enableCaption: false,
// //           controlsVisibleAtStart: true,
// //           hideControls: true,
// //           startAt: 10, // START FROM 10 SECONDS - SKIP FIRST 10 SECONDS
// //           hideThumbnail: false,
// //           useHybridComposition: false,
// //         ),
// //       );

// //       _controller!.addListener(_listener);

// //       // TV ke liye manual load aur play
// //       Future.delayed(const Duration(milliseconds: 300), () {
// //         if (mounted && _controller != null && !_isDisposed) {
// //           print('🎯 TV: Loading video manually');
// //           _controller!.load(videoId);

// //           // Multiple play attempts for TV
// //           Future.delayed(const Duration(milliseconds: 800), () {
// //             if (mounted && _controller != null && !_isDisposed) {
// //               print('🎬 TV: First play attempt (with sound)');
// //               _controller!.play();
// //               if (mounted) {
// //                 setState(() {
// //                   _isLoading = false;
// //                   _isPlayerReady = true;
// //                   _isPlaying = true;
// //                 });
// //               }
// //             }
// //           });
// //         }
// //       });
// //     } catch (e) {
// //       print('❌ TV Error: $e');
// //       if (mounted && !_isDisposed) {
// //         setState(() {
// //           _error = 'TV Error: $e';
// //           _isLoading = false;
// //         });
// //       }
// //     }
// //   }

// //   // FIXED: Single navigation trigger
// //   void _listener() {
// //     if (_controller != null && mounted && !_isDisposed && !_isNavigating) {
// //       if (_controller!.value.isReady && !_isPlayerReady) {
// //         print('📡 Controller ready detected - starting from beginning');

// //         // Ensure video starts from beginning
// //         _controller!.play();

// //         if (mounted) {
// //           setState(() {
// //             _isPlayerReady = true;
// //             _isPlaying = true;
// //           });
// //         }
// //       }

// //       // Update position and duration
// //       if (mounted) {
// //         setState(() {
// //           _currentPosition = _controller!.value.position;
// //           _totalDuration = _controller!.value.metaData.duration;

// //           bool newIsPlaying = _controller!.value.isPlaying;
// //           _isPlaying = newIsPlaying;
// //         });
// //       }

// //       // FIXED: Single navigation trigger with proper checks
// //       if (_totalDuration.inSeconds > 24 &&
// //           _currentPosition.inSeconds > 0 &&
// //           !_videoCompleted) {
// //         final adjustedEndTime = _totalDuration.inSeconds - 12;

// //         if (_currentPosition.inSeconds >= adjustedEndTime) {
// //           print('🛑 Video reached cut point - completing video');
// //           _completeVideo(); // Single method for video completion
// //         }
// //       }
// //     }
// //   }

// //   // NEW: Single method to handle video completion
// //   void _completeVideo() {
// //     if (_isNavigating || _videoCompleted || _isDisposed) return;

// //     print('🎬 Video completing - single navigation trigger');

// //     // Mark as completed to prevent multiple triggers
// //     _videoCompleted = true;
// //     _isNavigating = true;

// //     // Pause the video
// //     if (_controller != null) {
// //       _controller!.pause();
// //     }

// //     // Single navigation with cleanup
// //     Future.delayed(const Duration(milliseconds: 800), () {
// //       if (mounted && !_isDisposed) {
// //         print('🔙 Navigating back to source page');
// //         Navigator.of(context).pop();
// //       }
// //     });
// //   }

// //   // NEW: Reset states for new video
// //   void _resetVideoStates() {
// //     _isNavigating = false;
// //     _videoCompleted = false;
// //     _isPlayerReady = false;
// //     _isPlaying = false;
// //   }

// //   void _startHideControlsTimer() {
// //     // Controls hide timer works normally - only splash blocks controls, not this timer
// //     if (_isDisposed) return;

// //     _hideControlsTimer?.cancel();
// //     _hideControlsTimer = Timer(const Duration(seconds: 5), () {
// //       if (mounted && _showControls && !_isDisposed) {
// //         setState(() {
// //           _showControls = false;
// //         });
// //         // When controls hide, focus goes back to main invisible node
// //         _mainFocusNode.requestFocus();
// //       }
// //     });
// //   }

// //   void _showControlsTemporarily() {
// //     // Controls show normally - splash blocking is handled in key events
// //     if (_isDisposed) return;

// //     if (mounted) {
// //       setState(() {
// //         _showControls = true;
// //       });
// //     }

// //     // When controls show, focus on play/pause button
// //     _playPauseFocusNode.requestFocus();
// //     _startHideControlsTimer();
// //   }

// //   void _togglePlayPause() {
// //     if (_controller != null && _isPlayerReady && !_isDisposed) {
// //       if (_isPlaying) {
// //         _controller!.pause();
// //         print('⏸️ Video paused');
// //       } else {
// //         _controller!.play();
// //         print('▶️ Video playing');
// //       }
// //     }
// //     _showControlsTemporarily();
// //   }

// //   void _seekVideo(bool forward) {
// //     if (_controller == null || !_isPlayerReady || _isDisposed) {
// //       print('❌ Cannot seek - controller not ready');
// //       return;
// //     }

// //     if (_totalDuration.inSeconds <= 24) {
// //       print('❌ Cannot seek - video too short');
// //       return;
// //     }

// //     final adjustedEndTime = _totalDuration.inSeconds - 12;
// //     final seekAmount = (adjustedEndTime / 200).round().clamp(5, 30);

// //     // Cancel previous seek timer
// //     _seekTimer?.cancel();

// //     // Update pending seek
// //     if (forward) {
// //       _pendingSeekSeconds += seekAmount;
// //       print('⏩ Adding forward seek: +${seekAmount}s (total: ${_pendingSeekSeconds}s)');
// //     } else {
// //       _pendingSeekSeconds -= seekAmount;
// //       print('⏪ Adding backward seek: -${seekAmount}s (total: ${_pendingSeekSeconds}s)');
// //     }

// //     // Calculate target position
// //     final currentSeconds = _currentPosition.inSeconds;
// //     final targetSeconds = (currentSeconds + _pendingSeekSeconds).clamp(0, adjustedEndTime);
// //     _targetSeekPosition = Duration(seconds: targetSeconds);

// //     // Update UI
// //     if (mounted && !_isDisposed) {
// //       setState(() {
// //         _isSeeking = true;
// //       });
// //     }

// //     // Execute seek after 1 second
// //     _seekTimer = Timer(const Duration(milliseconds: 1000), () {
// //       _executeSeek();
// //     });

// //     // Show controls
// //     _showControlsTemporarily();
// //   }

// //   void _executeSeek() {
// //     if (_controller == null || !_isPlayerReady || _isDisposed || _pendingSeekSeconds == 0) {
// //       return;
// //     }

// //     final adjustedEndTime = _totalDuration.inSeconds - 12;
// //     final currentSeconds = _currentPosition.inSeconds;
// //     final newPosition = (currentSeconds + _pendingSeekSeconds).clamp(0, adjustedEndTime);

// //     print('🎯 Executing seek to: ${newPosition}s');

// //     try {
// //       _controller!.seekTo(Duration(seconds: newPosition));
// //       print('✅ Seek executed successfully');
// //     } catch (e) {
// //       print('❌ Seek error: $e');
// //     }

// //     // Reset seeking state
// //     _pendingSeekSeconds = 0;
// //     _targetSeekPosition = Duration.zero;

// //     if (mounted && !_isDisposed) {
// //       setState(() {
// //         _isSeeking = false;
// //       });
// //     }
// //   }

// //   // BLOCK controls only for first 8 seconds of splash
// //   bool _handleKeyEvent(RawKeyEvent event) {
// //     if (_isDisposed) return false;

// //     // BLOCK key events only during first 8 seconds of splash screen
// //     if (_showSplashScreen && _splashStartTime != null) {
// //       final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
// //       if (elapsed < 8) {
// //         if (event is RawKeyDownEvent) {
// //           switch (event.logicalKey) {
// //             case LogicalKeyboardKey.escape:
// //             case LogicalKeyboardKey.backspace:
// //               // Allow back navigation during splash
// //               print('🔙 Back pressed during splash - exiting');
// //               if (!_isDisposed) {
// //                 Navigator.of(context).pop();
// //               }
// //               return true;
// //             default:
// //               // Block other keys only for 8 seconds
// //               print('🚫 Key blocked during first 8 seconds of splash: ${event.logicalKey}');
// //               return true;
// //           }
// //         }
// //         return true;
// //       }
// //     }

// //     // Normal key handling after splash is gone or after 8 seconds
// //     if (event is RawKeyDownEvent) {
// //       switch (event.logicalKey) {
// //         case LogicalKeyboardKey.select:
// //         case LogicalKeyboardKey.enter:
// //         case LogicalKeyboardKey.space:
// //           _togglePlayPause();
// //           return true;

// //         case LogicalKeyboardKey.arrowLeft:
// //           print('⏪ Left arrow pressed - seeking backward');
// //           _seekVideo(false);
// //           return true;

// //         case LogicalKeyboardKey.arrowRight:
// //           print('⏩ Right arrow pressed - seeking forward');
// //           _seekVideo(true);
// //           return true;

// //         case LogicalKeyboardKey.arrowUp:
// //         case LogicalKeyboardKey.arrowDown:
// //           if (!_showControls) {
// //             _showControlsTemporarily();
// //           } else {
// //             if (_playPauseFocusNode.hasFocus) {
// //               _progressFocusNode.requestFocus();
// //             } else if (_progressFocusNode.hasFocus) {
// //               _playPauseFocusNode.requestFocus();
// //             } else {
// //               _playPauseFocusNode.requestFocus();
// //             }
// //             _showControlsTemporarily();
// //           }
// //           return true;

// //         case LogicalKeyboardKey.escape:
// //         case LogicalKeyboardKey.backspace:
// //           if (!_isDisposed) {
// //             Navigator.of(context).pop();
// //           }
// //           return true;

// //         default:
// //           if (!_showControls) {
// //             _showControlsTemporarily();
// //             return true;
// //           }
// //           break;
// //       }
// //     }
// //     return false;
// //   }

// //   void _showError(String message) {
// //     if (mounted && !_isDisposed) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(message),
// //           backgroundColor: Colors.red,
// //           duration: const Duration(seconds: 3),
// //         ),
// //       );
// //     }
// //   }

// //   // FIXED: Handle back button press - TV Remote ke liye
// //   Future<bool> _onWillPop() async {
// //     if (_isDisposed || _isNavigating) return true;

// //     try {
// //       print('🔙 Back button pressed - cleaning up...');

// //       // Mark as navigating to prevent other triggers
// //       _isNavigating = true;
// //       _isDisposed = true;

// //       // Cancel all timers
// //       _hideControlsTimer?.cancel();
// //       _splashTimer?.cancel();
// //       _splashUpdateTimer?.cancel();
// //       _seekTimer?.cancel();

// //       // Pause and dispose controller
// //       if (_controller != null) {
// //         try {
// //           if (_controller!.value.isPlaying) {
// //             _controller!.pause();
// //           }
// //           _controller!.dispose();
// //           _controller = null;
// //         } catch (e) {
// //           print('Error disposing controller: $e');
// //         }
// //       }

// //       // Restore system UI in a try-catch
// //       try {
// //         await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
// //             overlays: SystemUiOverlay.values);

// //         // Reset orientation to allow all orientations
// //         await SystemChrome.setPreferredOrientations([
// //           DeviceOrientation.portraitUp,
// //           DeviceOrientation.portraitDown,
// //           DeviceOrientation.landscapeLeft,
// //           DeviceOrientation.landscapeRight,
// //         ]);
// //       } catch (e) {
// //         print('Error restoring system UI: $e');
// //       }

// //       return true; // Allow back navigation
// //     } catch (e) {
// //       print('Error in _onWillPop: $e');
// //       return true;
// //     }
// //   }

// //   @override
// //   void deactivate() {
// //     print('🔄 Screen deactivating...');
// //     _isDisposed = true;
// //     _controller?.pause();
// //     _splashTimer?.cancel();
// //     super.deactivate();
// //   }

// //   @override
// //   void dispose() {
// //     print('🗑️ Disposing YouTube player screen...');

// //     try {
// //       // Mark as disposed
// //       _isDisposed = true;

// //       // Cancel timers
// //       _hideControlsTimer?.cancel();
// //       _seekTimer?.cancel();
// //       _splashTimer?.cancel();
// //       _splashUpdateTimer?.cancel();

// //       // Dispose focus nodes
// //       if (_mainFocusNode.hasListeners) {
// //         _mainFocusNode.dispose();
// //       }
// //       if (_playPauseFocusNode.hasListeners) {
// //         _playPauseFocusNode.dispose();
// //       }
// //       if (_progressFocusNode.hasListeners) {
// //         _progressFocusNode.dispose();
// //       }

// //       // Dispose controller
// //       if (_controller != null) {
// //         try {
// //           _controller!.pause();
// //           _controller!.dispose();
// //           _controller = null;
// //         } catch (e) {
// //           print('Error disposing controller in dispose: $e');
// //         }
// //       }

// //       // Restore system UI
// //       try {
// //         SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
// //             overlays: SystemUiOverlay.values);

// //         SystemChrome.setPreferredOrientations([
// //           DeviceOrientation.portraitUp,
// //           DeviceOrientation.portraitDown,
// //           DeviceOrientation.landscapeLeft,
// //           DeviceOrientation.landscapeRight,
// //         ]);
// //       } catch (e) {
// //         print('Error restoring system UI in dispose: $e');
// //       }
// //     } catch (e) {
// //       print('Error in dispose: $e');
// //     }
// //     KeepScreenOn.turnOff();
// //     super.dispose();
// //   }

// //   String _formatDuration(Duration duration) {
// //     String twoDigits(int n) => n.toString().padLeft(2, '0');
// //     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
// //     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
// //     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
// //   }

// //   // Helper methods for splash countdown
// //   double _getSplashProgress() {
// //     if (_splashStartTime == null) return 0.0;

// //     final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
// //     final progress = elapsed / 12.0; // 12 seconds total
// //     return progress.clamp(0.0, 1.0);
// //   }

// //   int _getRemainingSeconds() {
// //     if (_splashStartTime == null) return 12;

// //     final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
// //     final remaining = 12 - elapsed;
// //     return remaining.clamp(0, 12);
// //   }

// //   // Controls overlay with proper seek functionality
// //   Widget _buildControlsOverlay() {
// //     // Controls को splash के दौरान भी show करें (8 seconds बाद)
// //     bool shouldShowControls = _showControls && _isPlayerReady;

// //     // Splash के दौरान भी controls show करें अगर 8 seconds हो गए हैं
// //     if (_showSplashScreen && _splashStartTime != null) {
// //       final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
// //       if (elapsed >= 8) {
// //         shouldShowControls = _showControls;
// //       } else {
// //         shouldShowControls = false;
// //       }
// //     }

// //     return AnimatedOpacity(
// //       opacity: shouldShowControls ? 1.0 : 0.0,
// //       duration: const Duration(milliseconds: 300),
// //       child: Container(
// //         color: Colors.black26,
// //         child: Column(
// //           children: [
// //             // Top bar with title
// //             Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
// //               decoration: BoxDecoration(
// //                 gradient: LinearGradient(
// //                   begin: Alignment.topCenter,
// //                   end: Alignment.bottomCenter,
// //                   colors: [
// //                     Colors.black.withOpacity(0.8),
// //                     Colors.transparent,
// //                   ],
// //                 ),
// //               ),
// //               child: Row(
// //                 children: [
// //                   const Icon(Icons.play_circle_outline, color: Colors.white, size: 24),
// //                   const SizedBox(width: 10),
// //                   const Text(
// //                     'Now Playing',
// //                     style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
// //                   ),
// //                 ],
// //               ),
// //             ),

// //             const Spacer(),

// //             // Bottom controls
// //             Container(
// //               padding: const EdgeInsets.all(20),
// //               decoration: BoxDecoration(
// //                 gradient: LinearGradient(
// //                   begin: Alignment.topCenter,
// //                   end: Alignment.bottomCenter,
// //                   colors: [
// //                     Colors.transparent,
// //                     Colors.black.withOpacity(0.8),
// //                   ],
// //                 ),
// //               ),
// //               child: Column(
// //                 children: [
// //                   // Progress bar
// //                   Focus(
// //                     focusNode: _progressFocusNode,
// //                     onFocusChange: (hasFocus) {
// //                       setState(() {
// //                         _isProgressFocused = hasFocus;
// //                       });
// //                     },
// //                     child: Container(
// //                       padding: const EdgeInsets.symmetric(vertical: 10),
// //                       decoration: BoxDecoration(
// //                         border: _isProgressFocused
// //                             ? Border.all(color: Colors.red, width: 2)
// //                             : null,
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       child: Column(
// //                         children: [
// //                           // Time display
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               Text(
// //                                 _formatDuration(_isSeeking ? _targetSeekPosition : _currentPosition),
// //                                 style: const TextStyle(color: Colors.white, fontSize: 16),
// //                               ),
// //                               Text(
// //                                 _formatDuration(_totalDuration),
// //                                 style: const TextStyle(color: Colors.white, fontSize: 16),
// //                               ),
// //                             ],
// //                           ),
// //                           const SizedBox(height: 8),
// //                           // Progress bar
// //                           Container(
// //                             height: 4,
// //                             decoration: BoxDecoration(
// //                               color: Colors.white.withOpacity(0.3),
// //                               borderRadius: BorderRadius.circular(2),
// //                             ),
// //                             child: Stack(
// //                               children: [
// //                                 // Main progress
// //                                 FractionallySizedBox(
// //                                   widthFactor: _totalDuration.inSeconds > 0
// //                                       ? (_isSeeking ? _targetSeekPosition : _currentPosition).inSeconds / _totalDuration.inSeconds
// //                                       : 0.0,
// //                                   child: Container(
// //                                     decoration: BoxDecoration(
// //                                       color: _isSeeking ? Colors.yellow : Colors.red,
// //                                       borderRadius: BorderRadius.circular(2),
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                           if (_isSeeking)
// //                             Padding(
// //                               padding: const EdgeInsets.only(top: 4),
// //                               child: Text(
// //                                 _pendingSeekSeconds > 0 ? '+${_pendingSeekSeconds}s' : '${_pendingSeekSeconds}s',
// //                                 style: const TextStyle(color: Colors.yellow, fontSize: 12),
// //                               ),
// //                             ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),

// //                   const SizedBox(height: 20),

// //                   // Control buttons
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       // Seek backward
// //                       _buildControlButton(
// //                         icon: Icons.replay_10,
// //                         onPressed: () => _seekVideo(false),
// //                         focusNode: null,
// //                       ),

// //                       const SizedBox(width: 20),

// //                       // Play/Pause
// //                       Focus(
// //                         focusNode: _playPauseFocusNode,
// //                         child: _buildControlButton(
// //                           icon: _isPlaying ? Icons.pause : Icons.play_arrow,
// //                           onPressed: _togglePlayPause,
// //                           focusNode: _playPauseFocusNode,
// //                           isMain: true,
// //                         ),
// //                       ),

// //                       const SizedBox(width: 20),

// //                       // Seek forward
// //                       _buildControlButton(
// //                         icon: Icons.forward_10,
// //                         onPressed: () => _seekVideo(true),
// //                         focusNode: null,
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildControlButton({
// //     required IconData icon,
// //     required VoidCallback onPressed,
// //     required FocusNode? focusNode,
// //     bool isMain = false,
// //   }) {
// //     return Container(
// //       width: isMain ? 60 : 50,
// //       height: isMain ? 60 : 50,
// //       decoration: BoxDecoration(
// //         color: Colors.black.withOpacity(0.6),
// //         borderRadius: BorderRadius.circular(isMain ? 30 : 25),
// //         border: focusNode?.hasFocus == true
// //             ? Border.all(color: Colors.red, width: 2)
// //             : null,
// //       ),
// //       child: IconButton(
// //         icon: Icon(icon, color: Colors.white, size: isMain ? 28 : 24),
// //         onPressed: onPressed,
// //       ),
// //     );
// //   }

// //   // Top and Bottom Black Bars - Video plays in center (Start Splash)
// //   Widget _buildTopBottomBlackBars() {
// //     return Stack(
// //       children: [
// //         // Top Black Bar - screenhgt/7 height
// //         Positioned(
// //           top: 0,
// //           left: 0,
// //           right: 0,
// //           height: screenhgt / 7,
// //           child: Container(
// //             color: Colors.black,
// //           ),
// //         ),
// //         // Bottom Black Bar - screenhgt/7 height
// //         Positioned(
// //           bottom: 0,
// //           left: 0,
// //           right: 0,
// //           height: screenhgt / 7,
// //           child: Container(
// //             color: Colors.black,
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildVideoPlayer() {
// //     if (_error != null) {
// //       return Container(
// //         color: Colors.black,
// //         child: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               const Icon(Icons.error, color: Colors.red, size: 48),
// //               const SizedBox(height: 16),
// //               Text(_error!, style: const TextStyle(color: Colors.white)),
// //               const SizedBox(height: 16),
// //               ElevatedButton(
// //                 onPressed: () {
// //                   if (!_isDisposed && mounted) {
// //                     setState(() {
// //                       _isLoading = true;
// //                       _error = null;
// //                     });
// //                     _controller?.dispose();
// //                     _initializePlayer();
// //                   }
// //                 },
// //                 child: const Text('Retry'),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }

// //     if (_controller == null || _isLoading) {
// //       return Container(
// //         color: Colors.black,
// //         child: const Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               CircularProgressIndicator(color: Colors.red),
// //               SizedBox(height: 20),
// //               Text('Loading...',
// //                   style: TextStyle(color: Colors.white, fontSize: 18)),
// //             ],
// //           ),
// //         ),
// //       );
// //     }

// //     return Container(
// //       width: double.infinity,
// //       height: double.infinity,
// //       color: Colors.black,
// //       child: Stack(
// //         children: [
// //           YoutubePlayer(
// //             controller: _controller!,
// //             showVideoProgressIndicator: false,
// //             progressIndicatorColor: Colors.red,
// //             width: double.infinity,
// //             aspectRatio: 16 / 9,
// //             bufferIndicator: Container(
// //               color: Colors.black,
// //               child: const Center(
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     CircularProgressIndicator(color: Colors.red),
// //                     SizedBox(height: 10),
// //                     Text('Buffering...', style: TextStyle(color: Colors.white)),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //             onReady: () {
// //               print('📺 TV Player Ready - forcing video surface');
// //               if (!_isPlayerReady && !_isDisposed) {
// //                 if (mounted) {
// //                   setState(() => _isPlayerReady = true);
// //                 }

// //                 // Focus on main node when ready, controls will show when needed
// //                 Future.delayed(const Duration(milliseconds: 500), () {
// //                   if (!_isDisposed) {
// //                     _mainFocusNode.requestFocus();
// //                   }
// //                 });

// //                 // TV video surface activation - Start playing from beginning with sound
// //                 Future.delayed(const Duration(milliseconds: 100), () {
// //                   if (_controller != null && mounted && !_isDisposed) {
// //                     // Start from beginning
// //                     _controller!.play();
// //                     print(
// //                         '🎬 TV: Video started playing from beginning (with sound during black bars)');
// //                   }
// //                 });
// //               }
// //             },
// //             onEnded: (_) {
// //               if (_isDisposed || _isNavigating || _videoCompleted) return;

// //               print('🎬 Video ended naturally - using completion handler');
// //               _completeVideo(); // Use same completion method
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Don't render if disposed
// //     if (_isDisposed) {
// //       return const Scaffold(
// //         body: Center(
// //           child: CircularProgressIndicator(),
// //         ),
// //       );
// //     }

// //     return RawKeyboardListener(
// //       focusNode: _mainFocusNode,
// //       autofocus: true,
// //       onKey: _handleKeyEvent,
// //       child: WillPopScope(
// //         onWillPop: _onWillPop,
// //         child: Scaffold(
// //           body: GestureDetector(
// //             onTap: _showControlsTemporarily,
// //             behavior: HitTestBehavior.opaque,
// //             child: Stack(
// //               children: [
// //                 // Full screen video player (always present and playing in background)
// //                 _buildVideoPlayer(),

// //                 // Top/Bottom Black Bars - Show for 12 seconds with video playing in center
// //                 if (_showSplashScreen) _buildTopBottomBlackBars(),

// //                 // Custom Controls Overlay - Show after 8 seconds even during splash
// //                 _buildControlsOverlay(),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }






// // import 'dart:io';

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:mobi_tv_entertainment/main.dart';
// // import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// // import 'dart:async';
// // import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// // // Direct YouTube Player Screen - No Home Page Required
// // class CustomYoutubePlayer extends StatefulWidget {
// //   final videoUrl;

// //   const CustomYoutubePlayer({
// //     Key? key,
// //     required this.videoUrl,
// //   }) : super(key: key);

// //   @override
// //   _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
// // }

// // class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
// //   YoutubePlayerController? _controller;
// //   int currentIndex = 0;
// //   bool _isPlayerReady = false;
// //   String? _error;
// //   bool _isLoading = true;
// //   bool _isDisposed = false; // Track disposal state

// //   // Navigation control - FIXED
// //   bool _isNavigating = false; // Prevent double navigation
// //   bool _videoCompleted = false; // Track video completion

// //   // Splash screen control with fade animation
// //   bool _showSplashScreen = true;
// //   Timer? _splashTimer;
// //   Timer? _splashUpdateTimer;
// //   DateTime? _splashStartTime;

// //   // End splash screen control with fade animation
// //   bool _showEndSplashScreen = false;
// //   Timer? _endSplashTimer;
// //   DateTime? _endSplashStartTime;

// //   // Animation controllers for fade effects
// //   double _splashOpacity = 1.0; // Start fully black (opacity = 1.0)
// //   double _endSplashOpacity = 0.0; // End starts transparent (opacity = 0.0)
// //   Timer? _fadeAnimationTimer;

// //   // Control states - KEPT MINIMAL FOR PROGRESS BAR
// //   bool _isPlaying = false;
// //   Duration _currentPosition = Duration.zero;
// //   Duration _totalDuration = Duration.zero;

// //   // Progressive seeking states
// //   Timer? _seekTimer;
// //   int _pendingSeekSeconds = 0;
// //   Duration _targetSeekPosition = Duration.zero;
// //   bool _isSeeking = false;

// //   // Focus nodes for TV remote - MINIMAL
// //   final FocusNode _mainFocusNode = FocusNode(); // Main invisible focus node

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeInAppWebView();

// //     print('📱 App started - Quick setup mode');

// //     // Set full screen immediately
// //     _setFullScreenMode();

// //     // Start player initialization immediately
// //     _initializePlayer();

// //     // Start 30 second fade splash timer
// //     _startSplashTimer();

// //     // Request focus on main node initially
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _mainFocusNode.requestFocus();
// //     });
// //   }

// //   void _initializeInAppWebView() async {
// //     try {
// //       if (Platform.isAndroid) {
// //         await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(
// //             true);
// //       }
// //     } catch (e) {
// //       print('InAppWebView initialization error: $e');
// //     }
// //   }

// //   void _startSplashTimer() {
// //     _splashStartTime = DateTime.now(); // Record start time
// //     print(
// //         '🎬 Top/Bottom black bars started - will remove after exactly 12 seconds');

// //     // Simple timer - EXACTLY 12 seconds, no fade
// //     _splashTimer = Timer(const Duration(seconds: 12), () {
// //       if (mounted && !_isDisposed && _showSplashScreen) {
// //         print('🎬 12 seconds complete - removing top/bottom black bars');

// //         setState(() {
// //           _showSplashScreen = false;
// //         });

// //         print('🎮 Video now playing full screen after 12 seconds');
// //       }
// //     });

// //     // Timer to update countdown display every second
// //     _splashUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
// //       if (mounted && _showSplashScreen && !_isDisposed) {
// //         final remaining = _getRemainingSeconds();
// //         print('⏰ Top/Bottom black bars: ${remaining} seconds remaining');
// //       } else {
// //         timer.cancel();
// //       }
// //     });
// //   }

// //   void _setFullScreenMode() {
// //     // TV ke liye optimized settings
// //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

// //     // TV landscape orientation
// //     SystemChrome.setPreferredOrientations([
// //       DeviceOrientation.landscapeLeft,
// //       DeviceOrientation.landscapeRight,
// //     ]);

// //     // TV ke liye additional settings
// //     SystemChrome.setSystemUIOverlayStyle(
// //       const SystemUiOverlayStyle(
// //         statusBarColor: Colors.transparent,
// //         systemNavigationBarColor: Colors.transparent,
// //       ),
// //     );
// //   }

// //   void _initializePlayer() {
// //     if (_isDisposed) return; // Don't initialize if disposed

// //     try {
// //       String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

// //       print('🔧 TV Mode: Initializing player for: $videoId');

// //       if (videoId == null || videoId.isEmpty) {
// //         if (mounted && !_isDisposed) {
// //           setState(() {
// //             _error = 'Invalid YouTube URL: ${widget.videoUrl}';
// //             _isLoading = false;
// //           });
// //         }
// //         return;
// //       }

// //       // TV-specific controller configuration - NO MUTING + START FROM 10 SECONDS
// //       _controller = YoutubePlayerController(
// //         initialVideoId: videoId,
// //         flags: const YoutubePlayerFlags(
// //           mute: false, // NO MUTING - sound stays on
// //           autoPlay: true,
// //           disableDragSeek: false,
// //           loop: false,
// //           isLive: false,
// //           forceHD: false,
// //           enableCaption: false,
// //           controlsVisibleAtStart: false,
// //           hideControls: true,
// //           startAt: 10, // START FROM 10 SECONDS - SKIP FIRST 10 SECONDS
// //           hideThumbnail: false,
// //           useHybridComposition: false,
// //         ),
// //       );

// //       _controller!.addListener(_listener);

// //       // TV ke liye manual load aur play
// //       Future.delayed(const Duration(milliseconds: 300), () {
// //         if (mounted && _controller != null && !_isDisposed) {
// //           print('🎯 TV: Loading video manually');
// //           _controller!.load(videoId);

// //           // Multiple play attempts for TV
// //           Future.delayed(const Duration(milliseconds: 800), () {
// //             if (mounted && _controller != null && !_isDisposed) {
// //               print('🎬 TV: First play attempt (with sound)');
// //               _controller!.play();
// //               if (mounted) {
// //                 setState(() {
// //                   _isLoading = false;
// //                   _isPlayerReady = true;
// //                   _isPlaying = true;
// //                 });
// //               }
// //             }
// //           });
// //         }
// //       });
// //     } catch (e) {
// //       print('❌ TV Error: $e');
// //       if (mounted && !_isDisposed) {
// //         setState(() {
// //           _error = 'TV Error: $e';
// //           _isLoading = false;
// //         });
// //       }
// //     }
// //   }

// //   // FIXED: Single navigation trigger
// //   void _listener() {
// //     if (_controller != null && mounted && !_isDisposed && !_isNavigating) {
// //       if (_controller!.value.isReady && !_isPlayerReady) {
// //         print('📡 Controller ready detected - starting from beginning');

// //         // Ensure video starts from beginning
// //         _controller!.play();

// //         if (mounted) {
// //           setState(() {
// //             _isPlayerReady = true;
// //             _isPlaying = true;
// //           });
// //         }
// //       }

// //       // Update position and duration
// //       if (mounted) {
// //         setState(() {
// //           _currentPosition = _controller!.value.position;
// //           _totalDuration = _controller!.value.metaData.duration;

// //           bool newIsPlaying = _controller!.value.isPlaying;
// //           _isPlaying = newIsPlaying;
// //         });
// //       }

// //       // FIXED: Single navigation trigger with proper checks
// //       if (_totalDuration.inSeconds > 24 &&
// //           _currentPosition.inSeconds > 0 &&
// //           !_videoCompleted) {
// //         final adjustedEndTime = _totalDuration.inSeconds - 12;

// //         if (_currentPosition.inSeconds >= adjustedEndTime) {
// //           print('🛑 Video reached cut point - completing video');
// //           _completeVideo(); // Single method for video completion
// //         }
// //       }
// //     }
// //   }

// //   // NEW: Single method to handle video completion
// //   void _completeVideo() {
// //     if (_isNavigating || _videoCompleted || _isDisposed) return;

// //     print('🎬 Video completing - single navigation trigger');

// //     // Mark as completed to prevent multiple triggers
// //     _videoCompleted = true;
// //     _isNavigating = true;

// //     // Pause the video
// //     if (_controller != null) {
// //       _controller!.pause();
// //     }

// //     // Single navigation with cleanup
// //     Future.delayed(const Duration(milliseconds: 800), () {
// //       if (mounted && !_isDisposed) {
// //         print('🔙 Navigating back to source page');
// //         Navigator.of(context).pop();
// //       }
// //     });
// //   }

// //   // NEW: Reset states for new video
// //   void _resetVideoStates() {
// //     _isNavigating = false;
// //     _videoCompleted = false;
// //     _isPlayerReady = false;
// //     _isPlaying = false;
// //   }

// //   void _togglePlayPause() {
// //     if (_controller != null && _isPlayerReady && !_isDisposed) {
// //       if (_isPlaying) {
// //         _controller!.pause();
// //         print('⏸️ Video paused');
// //       } else {
// //         _controller!.play();
// //         print('▶️ Video playing');
// //       }
// //     }
// //   }

// //   void _seekVideo(bool forward) {
// //     if (_controller != null &&
// //         _isPlayerReady &&
// //         _totalDuration.inSeconds > 24 &&
// //         !_isDisposed) {
// //       final adjustedEndTime =
// //           _totalDuration.inSeconds - 12; // Don't allow seeking beyond cut point
// //       final seekAmount =
// //           (adjustedEndTime / 200).round().clamp(5, 30); // 5-30 seconds

// //       // Cancel previous seek timer
// //       _seekTimer?.cancel();

// //       // Calculate new pending seek
// //       if (forward) {
// //         _pendingSeekSeconds += seekAmount;
// //         print(
// //             '⏩ Adding forward seek: +${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
// //       } else {
// //         _pendingSeekSeconds -= seekAmount;
// //         print(
// //             '⏪ Adding backward seek: -${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
// //       }

// //       // Calculate target position for preview - RESPECT END CUT BOUNDARY
// //       final currentSeconds = _currentPosition.inSeconds;
// //       final targetSeconds = (currentSeconds + _pendingSeekSeconds)
// //           .clamp(0, adjustedEndTime); // 0 to end-12s
// //       _targetSeekPosition = Duration(seconds: targetSeconds);

// //       // Show seeking state
// //       if (mounted && !_isDisposed) {
// //         setState(() {
// //           _isSeeking = true;
// //         });
// //       }

// //       // Set timer to execute seek after 1 second of no input
// //       _seekTimer = Timer(const Duration(milliseconds: 1000), () {
// //         _executeSeek();
// //       });
// //     }
// //   }

// //   void _executeSeek() {
// //     if (_controller != null &&
// //         _isPlayerReady &&
// //         !_isDisposed &&
// //         _pendingSeekSeconds != 0) {
// //       final adjustedEndTime =
// //           _totalDuration.inSeconds - 12; // Don't seek beyond cut point
// //       final currentSeconds = _currentPosition.inSeconds;
// //       final newPosition = (currentSeconds + _pendingSeekSeconds)
// //           .clamp(0, adjustedEndTime); // Respect end cut boundary

// //       print(
// //           '🎯 Executing accumulated seek: ${_pendingSeekSeconds}s to position ${newPosition}s (within cut boundaries)');

// //       // Execute the seek
// //       _controller!.seekTo(Duration(seconds: newPosition));

// //       // Reset seeking state
// //       _pendingSeekSeconds = 0;
// //       _targetSeekPosition = Duration.zero;

// //       if (mounted && !_isDisposed) {
// //         setState(() {
// //           _isSeeking = false;
// //         });
// //       }
// //     }
// //   }

// //   // Start end splash screen when 30 seconds remain - SOLID BLACK
// //   void _startEndSplashTimer() {
// //     if (_showEndSplashScreen || _isDisposed)
// //       return; // Prevent multiple triggers

// //     _endSplashStartTime = DateTime.now();
// //     print('🎬 End solid black splash started - will show for 30 seconds');

// //     setState(() {
// //       _showEndSplashScreen = true;
// //     });

// //     // Simple timer for end splash - 30 seconds solid black
// //     _endSplashTimer = Timer(const Duration(seconds: 30), () {
// //       if (mounted && !_isDisposed) {
// //         print('🎬 End splash complete - ready for navigation');

// //         setState(() {
// //           _showEndSplashScreen = false;
// //         });
// //       }
// //     });

// //     print('⏰ End solid black splash started - will cover video completely');
// //   }

// //   // Helper method to check if controls should be blocked (only first 8 seconds)
// //   bool _shouldBlockControls() {
// //     if (_showSplashScreen && _splashStartTime != null) {
// //       final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
// //       return elapsed < 8; // Block only for first 8 seconds
// //     }
// //     return false;
// //   }

// //   // Helper methods for splash countdown
// //   double _getSplashProgress() {
// //     if (_splashStartTime == null) return 0.0;

// //     final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
// //     final progress = elapsed / 12.0; // 12 seconds total
// //     return progress.clamp(0.0, 1.0);
// //   }

// //   int _getRemainingSeconds() {
// //     if (_splashStartTime == null) return 12;

// //     final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
// //     final remaining = 12 - elapsed;
// //     return remaining.clamp(0, 12);
// //   }

// //   // SIMPLIFIED key event handling - only basic controls
// //   bool _handleKeyEvent(RawKeyEvent event) {
// //     if (_isDisposed) return false;

// //     // BLOCK key events only during first 8 seconds of splash screen
// //     if (_shouldBlockControls()) {
// //       if (event is RawKeyDownEvent) {
// //         switch (event.logicalKey) {
// //           case LogicalKeyboardKey.escape:
// //           case LogicalKeyboardKey.backspace:
// //             // Allow back navigation during splash
// //             print('🔙 Back pressed during splash - exiting');
// //             if (!_isDisposed) {
// //               Navigator.of(context).pop();
// //             }
// //             return true;
// //           default:
// //             // Block other keys only for 8 seconds
// //             print(
// //                 '🚫 Key blocked during first 8 seconds of splash: ${event.logicalKey}');
// //             return true;
// //         }
// //       }
// //       return true;
// //     }

// //     // Normal key handling after splash is gone
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
// //           if (!_isDisposed) {
// //             Navigator.of(context).pop();
// //           }
// //           return true;

// //         default:
// //           break;
// //       }
// //     }
// //     return false;
// //   }

// //   void _showError(String message) {
// //     if (mounted && !_isDisposed) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(message),
// //           backgroundColor: Colors.red,
// //           duration: const Duration(seconds: 3),
// //         ),
// //       );
// //     }
// //   }

// //   // FIXED: Handle back button press - TV Remote ke liye
// //   Future<bool> _onWillPop() async {
// //     if (_isDisposed || _isNavigating) return true;

// //     try {
// //       print('🔙 Back button pressed - cleaning up...');

// //       // Mark as navigating to prevent other triggers
// //       _isNavigating = true;
// //       _isDisposed = true;

// //       // Cancel all timers
// //       _splashTimer?.cancel();
// //       _splashUpdateTimer?.cancel();
// //       _seekTimer?.cancel();

// //       // Pause and dispose controller
// //       if (_controller != null) {
// //         try {
// //           if (_controller!.value.isPlaying) {
// //             _controller!.pause();
// //           }
// //           _controller!.dispose();
// //           _controller = null;
// //         } catch (e) {
// //           print('Error disposing controller: $e');
// //         }
// //       }

// //       // Restore system UI in a try-catch
// //       try {
// //         await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
// //             overlays: SystemUiOverlay.values);

// //         // Reset orientation to allow all orientations
// //         await SystemChrome.setPreferredOrientations([
// //           DeviceOrientation.portraitUp,
// //           DeviceOrientation.portraitDown,
// //           DeviceOrientation.landscapeLeft,
// //           DeviceOrientation.landscapeRight,
// //         ]);
// //       } catch (e) {
// //         print('Error restoring system UI: $e');
// //       }

// //       return true; // Allow back navigation
// //     } catch (e) {
// //       print('Error in _onWillPop: $e');
// //       return true;
// //     }
// //   }

// //   @override
// //   void deactivate() {
// //     print('🔄 Screen deactivating...');
// //     _isDisposed = true;
// //     _controller?.pause();
// //     _splashTimer?.cancel();
// //     super.deactivate();
// //   }

// //   @override
// //   void dispose() {
// //     print('🗑️ Disposing YouTube player screen...');

// //     try {
// //       // Mark as disposed
// //       _isDisposed = true;

// //       // Cancel timers
// //       _seekTimer?.cancel();
// //       _splashTimer?.cancel();
// //       _splashUpdateTimer?.cancel();

// //       // Dispose focus nodes
// //       if (_mainFocusNode.hasListeners) {
// //         _mainFocusNode.dispose();
// //       }

// //       // Dispose controller
// //       if (_controller != null) {
// //         try {
// //           _controller!.pause();
// //           _controller!.dispose();
// //           _controller = null;
// //         } catch (e) {
// //           print('Error disposing controller in dispose: $e');
// //         }
// //       }

// //       // Restore system UI
// //       try {
// //         SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
// //             overlays: SystemUiOverlay.values);

// //         SystemChrome.setPreferredOrientations([
// //           DeviceOrientation.portraitUp,
// //           DeviceOrientation.portraitDown,
// //           DeviceOrientation.landscapeLeft,
// //           DeviceOrientation.landscapeRight,
// //         ]);
// //       } catch (e) {
// //         print('Error restoring system UI in dispose: $e');
// //       }
// //     } catch (e) {
// //       print('Error in dispose: $e');
// //     }

// //     super.dispose();
// //   }

// //   String _formatDuration(Duration duration) {
// //     String twoDigits(int n) => n.toString().padLeft(2, '0');
// //     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
// //     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
// //     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Don't render if disposed
// //     if (_isDisposed) {
// //       return const Scaffold(
// //         body: Center(
// //           child: CircularProgressIndicator(),
// //         ),
// //       );
// //     }

// //     return RawKeyboardListener(
// //       focusNode: _mainFocusNode,
// //       autofocus: true,
// //       onKey: _handleKeyEvent,
// //       child: WillPopScope(
// //         onWillPop: _onWillPop,
// //         child: Scaffold(
// //           body: GestureDetector(
// //             child: Stack(
// //               children: [
// //                 // Full screen video player (always present and playing in background)
// //                 _buildVideoPlayer(),

// //                 // Top/Bottom Black Bars with Progress Bar - Always visible
// //                 _buildTopBottomBlackBars(),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // Top and Bottom Black Bars with Progress Bar - Video plays in center (Start Splash)
// //   Widget _buildTopBottomBlackBars() {
// //     return Stack(
// //       children: [
// //         // Top Black Bar - screenhgt/12 height
// //         Positioned(
// //           top: 0,
// //           left: 0,
// //           right: 0,
// //           height: screenhgt / 12,
// //           child: Container(
// //             color: Colors.black,
// //           ),
// //         ),
        
// //         // Bottom Black Bar with Progress Bar - screenhgt/10 height
// //         Positioned(
// //           bottom: 0,
// //           left: 0,
// //           right: 0,
// //           height: screenhgt / 10,
// //           child: Container(
// //             color: Colors.black,
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 // Progress Bar Container
// //                 Container(
// //                   margin: const EdgeInsets.symmetric(horizontal: 40),
// //                   child: Column(
// //                     children: [
// //                       // Progress Bar
// //                       Container(
// //                         height: 6,
// //                         decoration: BoxDecoration(
// //                           borderRadius: BorderRadius.circular(3),
// //                         ),
// //                         child: ClipRRect(
// //                           borderRadius: BorderRadius.circular(3),
// //                           child: Stack(
// //                             children: [
// //                               // Background
// //                               Container(
// //                                 width: double.infinity,
// //                                 height: 6,
// //                                 color: Colors.white.withOpacity(0.3),
// //                               ),
// //                               // Progress indicator
// //                               if (_totalDuration.inSeconds > 0)
// //                                 FractionallySizedBox(
// //                                   widthFactor: _currentPosition.inSeconds / 
// //                                       (_totalDuration.inSeconds - 12).clamp(1, double.infinity),
// //                                   child: Container(
// //                                     height: 6,
// //                                     color: Colors.red,
// //                                   ),
// //                                 ),
// //                               // Seeking preview (if seeking)
// //                               if (_isSeeking && _totalDuration.inSeconds > 0)
// //                                 FractionallySizedBox(
// //                                   widthFactor: _targetSeekPosition.inSeconds / 
// //                                       (_totalDuration.inSeconds - 12).clamp(1, double.infinity),
// //                                   child: Container(
// //                                     height: 6,
// //                                     color: Colors.yellow.withOpacity(0.8),
// //                                   ),
// //                                 ),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
                      
// //                       const SizedBox(height: 8),
                      
// //                       // Time Display
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Text(
// //                             _isSeeking
// //                                 ? _formatDuration(_targetSeekPosition)
// //                                 : _formatDuration(_currentPosition),
// //                             style: TextStyle(
// //                               color: _isSeeking ? Colors.yellow : Colors.white,
// //                               fontSize: 12,
// //                               fontWeight: _isSeeking ? FontWeight.bold : FontWeight.normal,
// //                             ),
// //                           ),
// //                           Text(
// //                             _formatDuration(Duration(
// //                                 seconds: (_totalDuration.inSeconds - 12)
// //                                     .clamp(0, double.infinity)
// //                                     .toInt())),
// //                             style: const TextStyle(
// //                                 color: Colors.white, fontSize: 12),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildVideoPlayer() {
// //     if (_error != null) {
// //       return Container(
// //         color: Colors.black,
// //         child: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               const Icon(Icons.error, color: Colors.red, size: 48),
// //               const SizedBox(height: 16),
// //               Text(_error!, style: const TextStyle(color: Colors.white)),
// //               const SizedBox(height: 16),
// //               ElevatedButton(
// //                 onPressed: () {
// //                   if (!_isDisposed && mounted) {
// //                     setState(() {
// //                       _isLoading = true;
// //                       _error = null;
// //                     });
// //                     _controller?.dispose();
// //                     _initializePlayer();
// //                   }
// //                 },
// //                 child: const Text('Retry'),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }

// //     if (_controller == null || _isLoading) {
// //       return Container(
// //         color: Colors.black,
// //         child: const Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               CircularProgressIndicator(color: Colors.red),
// //               SizedBox(height: 20),
// //               Text('Loading for TV Display...',
// //                   style: TextStyle(color: Colors.white, fontSize: 18)),
// //             ],
// //           ),
// //         ),
// //       );
// //     }

// //     return Container(
// //       width: double.infinity,
// //       height: double.infinity,
// //       color: Colors.black,
// //       child: YoutubePlayer(
// //         controller: _controller!,
// //         showVideoProgressIndicator: false,
// //         progressIndicatorColor: Colors.red,
// //         width: double.infinity,
// //         aspectRatio: 16 / 9,
// //         bufferIndicator: Container(
// //           color: Colors.black,
// //           child: const Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 CircularProgressIndicator(color: Colors.red),
// //                 SizedBox(height: 10),
// //                 Text('Buffering...', style: TextStyle(color: Colors.white)),
// //               ],
// //             ),
// //           ),
// //         ),
// //         onReady: () {
// //           print('📺 TV Player Ready - forcing video surface');
// //           if (!_isPlayerReady && !_isDisposed) {
// //             if (mounted) {
// //               setState(() => _isPlayerReady = true);
// //             }

// //             // Focus on main node when ready
// //             Future.delayed(const Duration(milliseconds: 500), () {
// //               if (!_isDisposed) {
// //                 _mainFocusNode.requestFocus();
// //               }
// //             });

// //             // TV video surface activation - Start playing from beginning with sound
// //             Future.delayed(const Duration(milliseconds: 100), () {
// //               if (_controller != null && mounted && !_isDisposed) {
// //                 // Start from beginning
// //                 _controller!.play();
// //                 print(
// //                     '🎬 TV: Video started playing from beginning (with sound during black bars)');
// //               }
// //             });
// //           }
// //         },
// //         onEnded: (_) {
// //           if (_isDisposed || _isNavigating || _videoCompleted) return;

// //           print('🎬 Video ended naturally - using completion handler');
// //           _completeVideo(); // Use same completion method
// //         },
// //       ),
// //     );
// //   }
// // }

// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// // // import 'dart:async';

// // // // Direct YouTube Player Screen - No Home Page Required
// // // class CustomYoutubePlayer extends StatefulWidget {
// // //   final videoUrl;

// // //   const CustomYoutubePlayer({
// // //     Key? key,
// // //     required this.videoUrl,
// // //   }) : super(key: key);

// // //   @override
// // //   _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
// // // }

// // // class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
// // //   YoutubePlayerController? _controller;
// // //   int currentIndex = 0;
// // //   bool _isPlayerReady = false;
// // //   String? _error;
// // //   bool _isLoading = true;
// // //   bool _isDisposed = false; // Track disposal state

// // //   // Navigation control - FIXED
// // //   bool _isNavigating = false; // Prevent double navigation
// // //   bool _videoCompleted = false; // Track video completion

// // //   // Splash screen control with fade animation
// // //   bool _showSplashScreen = true;
// // //   Timer? _splashTimer;
// // //   Timer? _splashUpdateTimer;
// // //   DateTime? _splashStartTime;

// // //   // End splash screen control with fade animation
// // //   bool _showEndSplashScreen = false;
// // //   Timer? _endSplashTimer;
// // //   DateTime? _endSplashStartTime;

// // //   // Animation controllers for fade effects
// // //   double _splashOpacity = 1.0; // Start fully black (opacity = 1.0)
// // //   double _endSplashOpacity = 0.0; // End starts transparent (opacity = 0.0)
// // //   Timer? _fadeAnimationTimer;

// // //   // Control states
// // //   bool _showControls = true;
// // //   bool _isPlaying = false;
// // //   Duration _currentPosition = Duration.zero;
// // //   Duration _totalDuration = Duration.zero;
// // //   Timer? _hideControlsTimer;

// // //   // Progressive seeking states
// // //   Timer? _seekTimer;
// // //   int _pendingSeekSeconds = 0;
// // //   Duration _targetSeekPosition = Duration.zero;
// // //   bool _isSeeking = false;

// // //   // Focus nodes for TV remote
// // //   final FocusNode _playPauseFocusNode = FocusNode();
// // //   final FocusNode _progressFocusNode = FocusNode();
// // //   final FocusNode _mainFocusNode = FocusNode(); // Main invisible focus node
// // //   bool _isProgressFocused = false;

// // //   @override
// // //   void initState() {
// // //     super.initState();

// // //     print('📱 App started - Quick setup mode');

// // //     // Set full screen immediately
// // //     _setFullScreenMode();

// // //     // Start player initialization immediately
// // //     _initializePlayer();

// // //     // Start 12 second fade splash timer
// // //     _startSplashTimer();

// // //     // Request focus on main node initially
// // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // //       _mainFocusNode.requestFocus();
// // //       // Show controls initially for testing (will be hidden during splash)
// // //       if (!_showSplashScreen) {
// // //         _showControlsTemporarily();
// // //       }
// // //     });
// // //   }

// // //   void _startSplashTimer() {
// // //     _splashStartTime = DateTime.now(); // Record start time
// // //     print(
// // //         '🎬 Top/Bottom black bars started - will remove after exactly 12 seconds');

// // //     // Simple timer - EXACTLY 12 seconds, no fade
// // //     _splashTimer = Timer(const Duration(seconds: 12), () {
// // //       if (mounted && !_isDisposed && _showSplashScreen) {
// // //         print('🎬 12 seconds complete - removing top/bottom black bars');

// // //         setState(() {
// // //           _showSplashScreen = false;
// // //         });

// // //         // Show controls when splash is gone
// // //         Future.delayed(const Duration(milliseconds: 500), () {
// // //           if (mounted && !_isDisposed) {
// // //             _showControlsTemporarily();
// // //             print('🎮 Controls are now available after 12 seconds');
// // //           }
// // //         });
// // //       }
// // //     });

// // //     // Timer to update countdown display every second
// // //     _splashUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
// // //       if (mounted && _showSplashScreen && !_isDisposed) {
// // //         final remaining = _getRemainingSeconds();
// // //         print('⏰ Top/Bottom black bars: ${remaining} seconds remaining');
// // //       } else {
// // //         timer.cancel();
// // //       }
// // //     });
// // //   }

// // //   void _setFullScreenMode() {
// // //     // TV ke liye optimized settings
// // //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

// // //     // TV landscape orientation
// // //     SystemChrome.setPreferredOrientations([
// // //       DeviceOrientation.landscapeLeft,
// // //       DeviceOrientation.landscapeRight,
// // //     ]);

// // //     // TV ke liye additional settings
// // //     SystemChrome.setSystemUIOverlayStyle(
// // //       const SystemUiOverlayStyle(
// // //         statusBarColor: Colors.transparent,
// // //         systemNavigationBarColor: Colors.transparent,
// // //       ),
// // //     );
// // //   }

// // //   void _initializePlayer() {
// // //     if (_isDisposed) return; // Don't initialize if disposed

// // //     try {
// // //       String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

// // //       print('🔧 TV Mode: Initializing player for: $videoId');

// // //       if (videoId == null || videoId.isEmpty) {
// // //         if (mounted && !_isDisposed) {
// // //           setState(() {
// // //             _error = 'Invalid YouTube URL: ${widget.videoUrl}';
// // //             _isLoading = false;
// // //           });
// // //         }
// // //         return;
// // //       }

// // //       // TV-specific controller configuration - FIXED OVERLAY ISSUE
// // //       _controller = YoutubePlayerController(
// // //         initialVideoId: videoId,
// // //         flags: const YoutubePlayerFlags(
// // //           mute: false, // NO MUTING - sound stays on
// // //           autoPlay: true,
// // //           disableDragSeek: false,
// // //           loop: false,
// // //           isLive: false,
// // //           forceHD: false,
// // //           enableCaption: false,
// // //           controlsVisibleAtStart: false, // HIDE YouTube default controls
// // //           hideControls: true, // IMPORTANT: Hide default controls completely
// // //           startAt: 10, // START FROM 10 SECONDS - SKIP FIRST 10 SECONDS
// // //           hideThumbnail: false,
// // //           useHybridComposition: true, // CRITICAL: Enable for proper overlay rendering
// // //         ),
// // //       );

// // //       _controller!.addListener(_listener);

// // //       // TV ke liye manual load aur play
// // //       Future.delayed(const Duration(milliseconds: 300), () {
// // //         if (mounted && _controller != null && !_isDisposed) {
// // //           print('🎯 TV: Loading video manually');
// // //           _controller!.load(videoId);

// // //           // Multiple play attempts for TV
// // //           Future.delayed(const Duration(milliseconds: 800), () {
// // //             if (mounted && _controller != null && !_isDisposed) {
// // //               print('🎬 TV: First play attempt (with sound)');
// // //               _controller!.play();
// // //               if (mounted) {
// // //                 setState(() {
// // //                   _isLoading = false;
// // //                   _isPlayerReady = true;
// // //                   _isPlaying = true;
// // //                 });
// // //               }
// // //             }
// // //           });
// // //         }
// // //       });
// // //     } catch (e) {
// // //       print('❌ TV Error: $e');
// // //       if (mounted && !_isDisposed) {
// // //         setState(() {
// // //           _error = 'TV Error: $e';
// // //           _isLoading = false;
// // //         });
// // //       }
// // //     }
// // //   }

// // //   // FIXED: Single navigation trigger
// // //   void _listener() {
// // //     if (_controller != null && mounted && !_isDisposed && !_isNavigating) {
// // //       if (_controller!.value.isReady && !_isPlayerReady) {
// // //         print('📡 Controller ready detected - starting from beginning');

// // //         // Ensure video starts from beginning
// // //         _controller!.play();

// // //         if (mounted) {
// // //           setState(() {
// // //             _isPlayerReady = true;
// // //             _isPlaying = true;
// // //           });
// // //         }
// // //       }

// // //       // Update position and duration
// // //       if (mounted) {
// // //         setState(() {
// // //           _currentPosition = _controller!.value.position;
// // //           _totalDuration = _controller!.value.metaData.duration;

// // //           bool newIsPlaying = _controller!.value.isPlaying;
// // //           _isPlaying = newIsPlaying;
// // //         });
// // //       }

// // //       // FIXED: Single navigation trigger with proper checks
// // //       if (_totalDuration.inSeconds > 24 &&
// // //           _currentPosition.inSeconds > 0 &&
// // //           !_videoCompleted) {
// // //         final adjustedEndTime = _totalDuration.inSeconds - 12;

// // //         if (_currentPosition.inSeconds >= adjustedEndTime) {
// // //           print('🛑 Video reached cut point - completing video');
// // //           _completeVideo(); // Single method for video completion
// // //         }
// // //       }
// // //     }
// // //   }

// // //   // NEW: Single method to handle video completion
// // //   void _completeVideo() {
// // //     if (_isNavigating || _videoCompleted || _isDisposed) return;

// // //     print('🎬 Video completing - single navigation trigger');

// // //     // Mark as completed to prevent multiple triggers
// // //     _videoCompleted = true;
// // //     _isNavigating = true;

// // //     // Pause the video
// // //     if (_controller != null) {
// // //       _controller!.pause();
// // //     }

// // //     // Single navigation with cleanup
// // //     Future.delayed(const Duration(milliseconds: 800), () {
// // //       if (mounted && !_isDisposed) {
// // //         print('🔙 Navigating back to source page');
// // //         Navigator.of(context).pop();
// // //       }
// // //     });
// // //   }

// // //   // NEW: Reset states for new video
// // //   void _resetVideoStates() {
// // //     _isNavigating = false;
// // //     _videoCompleted = false;
// // //     _isPlayerReady = false;
// // //     _isPlaying = false;
// // //   }

// // //   void _startHideControlsTimer() {
// // //     // Controls hide timer works normally - only splash blocks controls, not this timer
// // //     if (_isDisposed) return;

// // //     _hideControlsTimer?.cancel();
// // //     _hideControlsTimer = Timer(const Duration(seconds: 5), () {
// // //       if (mounted && _showControls && !_isDisposed) {
// // //         setState(() {
// // //           _showControls = false;
// // //         });
// // //         // When controls hide, focus goes back to main invisible node
// // //         _mainFocusNode.requestFocus();
// // //       }
// // //     });
// // //   }

// // //   void _showControlsTemporarily() {
// // //     // Controls show normally - splash blocking is handled in key events
// // //     if (_isDisposed) return;

// // //     if (mounted) {
// // //       setState(() {
// // //         _showControls = true;
// // //       });
// // //     }

// // //     // When controls show, focus on play/pause button
// // //     _playPauseFocusNode.requestFocus();
// // //     _startHideControlsTimer();
// // //   }

// // //   void _togglePlayPause() {
// // //     if (_controller != null && _isPlayerReady && !_isDisposed) {
// // //       if (_isPlaying) {
// // //         _controller!.pause();
// // //         print('⏸️ Video paused');
// // //       } else {
// // //         _controller!.play();
// // //         print('▶️ Video playing');
// // //       }
// // //     }
// // //     _showControlsTemporarily();
// // //   }

// // //   void _seekVideo(bool forward) {
// // //     if (_controller != null &&
// // //         _isPlayerReady &&
// // //         _totalDuration.inSeconds > 24 &&
// // //         !_isDisposed) {
// // //       final adjustedEndTime =
// // //           _totalDuration.inSeconds - 12; // Don't allow seeking beyond cut point
// // //       final seekAmount =
// // //           (adjustedEndTime / 200).round().clamp(5, 30); // 5-30 seconds

// // //       // Cancel previous seek timer
// // //       _seekTimer?.cancel();

// // //       // Calculate new pending seek
// // //       if (forward) {
// // //         _pendingSeekSeconds += seekAmount;
// // //         print(
// // //             '⏩ Adding forward seek: +${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
// // //       } else {
// // //         _pendingSeekSeconds -= seekAmount;
// // //         print(
// // //             '⏪ Adding backward seek: -${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
// // //       }

// // //       // Calculate target position for preview - RESPECT END CUT BOUNDARY
// // //       final currentSeconds = _currentPosition.inSeconds;
// // //       final targetSeconds = (currentSeconds + _pendingSeekSeconds)
// // //           .clamp(0, adjustedEndTime); // 0 to end-12s
// // //       _targetSeekPosition = Duration(seconds: targetSeconds);

// // //       // Show seeking state
// // //       if (mounted && !_isDisposed) {
// // //         setState(() {
// // //           _isSeeking = true;
// // //         });
// // //       }

// // //       // Set timer to execute seek after 1 second of no input
// // //       _seekTimer = Timer(const Duration(milliseconds: 1000), () {
// // //         _executeSeek();
// // //       });

// // //       _showControlsTemporarily();
// // //     }
// // //   }

// // //   void _executeSeek() {
// // //     if (_controller != null &&
// // //         _isPlayerReady &&
// // //         !_isDisposed &&
// // //         _pendingSeekSeconds != 0) {
// // //       final adjustedEndTime =
// // //           _totalDuration.inSeconds - 12; // Don't seek beyond cut point
// // //       final currentSeconds = _currentPosition.inSeconds;
// // //       final newPosition = (currentSeconds + _pendingSeekSeconds)
// // //           .clamp(0, adjustedEndTime); // Respect end cut boundary

// // //       print(
// // //           '🎯 Executing accumulated seek: ${_pendingSeekSeconds}s to position ${newPosition}s (within cut boundaries)');

// // //       // Execute the seek
// // //       _controller!.seekTo(Duration(seconds: newPosition));

// // //       // Reset seeking state
// // //       _pendingSeekSeconds = 0;
// // //       _targetSeekPosition = Duration.zero;

// // //       if (mounted && !_isDisposed) {
// // //         setState(() {
// // //           _isSeeking = false;
// // //         });
// // //       }
// // //     }
// // //   }

// // //   // Helper method to check if controls should be blocked (only first 8 seconds)
// // //   bool _shouldBlockControls() {
// // //     if (_showSplashScreen && _splashStartTime != null) {
// // //       final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
// // //       return elapsed < 8; // Block only for first 8 seconds
// // //     }
// // //     return false;
// // //   }

// // //   // BLOCK controls only for first 8 seconds of splash
// // //   bool _handleKeyEvent(RawKeyEvent event) {
// // //     if (_isDisposed) return false;

// // //     // BLOCK key events only during first 8 seconds of splash screen
// // //     if (_shouldBlockControls()) {
// // //       if (event is RawKeyDownEvent) {
// // //         switch (event.logicalKey) {
// // //           case LogicalKeyboardKey.escape:
// // //           case LogicalKeyboardKey.backspace:
// // //             // Allow back navigation during splash
// // //             print('🔙 Back pressed during splash - exiting');
// // //             if (!_isDisposed) {
// // //               Navigator.of(context).pop();
// // //             }
// // //             return true;
// // //           default:
// // //             // Block other keys only for 8 seconds
// // //             print(
// // //                 '🚫 Key blocked during first 8 seconds of splash: ${event.logicalKey}');
// // //             return true;
// // //         }
// // //       }
// // //       return true;
// // //     }

// // //     // Normal key handling after splash is gone
// // //     if (event is RawKeyDownEvent) {
// // //       switch (event.logicalKey) {
// // //         case LogicalKeyboardKey.select:
// // //         case LogicalKeyboardKey.enter:
// // //         case LogicalKeyboardKey.space:
// // //           _togglePlayPause();
// // //           return true;

// // //         case LogicalKeyboardKey.arrowLeft:
// // //           _seekVideo(false);
// // //           return true;

// // //         case LogicalKeyboardKey.arrowRight:
// // //           _seekVideo(true);
// // //           return true;

// // //         case LogicalKeyboardKey.arrowUp:
// // //         case LogicalKeyboardKey.arrowDown:
// // //           if (!_showControls) {
// // //             _showControlsTemporarily();
// // //           } else {
// // //             if (_playPauseFocusNode.hasFocus) {
// // //               _progressFocusNode.requestFocus();
// // //             } else if (_progressFocusNode.hasFocus) {
// // //               _playPauseFocusNode.requestFocus();
// // //             } else {
// // //               _playPauseFocusNode.requestFocus();
// // //             }
// // //             _showControlsTemporarily();
// // //           }
// // //           return true;

// // //         case LogicalKeyboardKey.escape:
// // //         case LogicalKeyboardKey.backspace:
// // //           if (!_isDisposed) {
// // //             Navigator.of(context).pop();
// // //           }
// // //           return true;

// // //         default:
// // //           if (!_showControls) {
// // //             _showControlsTemporarily();
// // //             return true;
// // //           }
// // //           break;
// // //       }
// // //     }
// // //     return false;
// // //   }

// // //   void _showError(String message) {
// // //     if (mounted && !_isDisposed) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(
// // //           content: Text(message),
// // //           backgroundColor: Colors.red,
// // //           duration: const Duration(seconds: 3),
// // //         ),
// // //       );
// // //     }
// // //   }

// // //   // FIXED: Handle back button press - TV Remote ke liye
// // //   Future<bool> _onWillPop() async {
// // //     if (_isDisposed || _isNavigating) return true;

// // //     try {
// // //       print('🔙 Back button pressed - cleaning up...');

// // //       // Mark as navigating to prevent other triggers
// // //       _isNavigating = true;
// // //       _isDisposed = true;

// // //       // Cancel all timers
// // //       _hideControlsTimer?.cancel();
// // //       _splashTimer?.cancel();
// // //       _splashUpdateTimer?.cancel();
// // //       _seekTimer?.cancel();

// // //       // Pause and dispose controller
// // //       if (_controller != null) {
// // //         try {
// // //           if (_controller!.value.isPlaying) {
// // //             _controller!.pause();
// // //           }
// // //           _controller!.dispose();
// // //           _controller = null;
// // //         } catch (e) {
// // //           print('Error disposing controller: $e');
// // //         }
// // //       }

// // //       // Restore system UI in a try-catch
// // //       try {
// // //         await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
// // //             overlays: SystemUiOverlay.values);

// // //         // Reset orientation to allow all orientations
// // //         await SystemChrome.setPreferredOrientations([
// // //           DeviceOrientation.portraitUp,
// // //           DeviceOrientation.portraitDown,
// // //           DeviceOrientation.landscapeLeft,
// // //           DeviceOrientation.landscapeRight,
// // //         ]);
// // //       } catch (e) {
// // //         print('Error restoring system UI: $e');
// // //       }

// // //       return true; // Allow back navigation
// // //     } catch (e) {
// // //       print('Error in _onWillPop: $e');
// // //       return true;
// // //     }
// // //   }

// // //   @override
// // //   void deactivate() {
// // //     print('🔄 Screen deactivating...');
// // //     _isDisposed = true;
// // //     _controller?.pause();
// // //     _splashTimer?.cancel();
// // //     super.deactivate();
// // //   }

// // //   @override
// // //   void dispose() {
// // //     print('🗑️ Disposing YouTube player screen...');

// // //     try {
// // //       // Mark as disposed
// // //       _isDisposed = true;

// // //       // Cancel timers
// // //       _hideControlsTimer?.cancel();
// // //       _seekTimer?.cancel();
// // //       _splashTimer?.cancel();
// // //       _splashUpdateTimer?.cancel();

// // //       // Dispose focus nodes
// // //       if (_mainFocusNode.hasListeners) {
// // //         _mainFocusNode.dispose();
// // //       }
// // //       if (_playPauseFocusNode.hasListeners) {
// // //         _playPauseFocusNode.dispose();
// // //       }
// // //       if (_progressFocusNode.hasListeners) {
// // //         _progressFocusNode.dispose();
// // //       }

// // //       // Dispose controller
// // //       if (_controller != null) {
// // //         try {
// // //           _controller!.pause();
// // //           _controller!.dispose();
// // //           _controller = null;
// // //         } catch (e) {
// // //           print('Error disposing controller in dispose: $e');
// // //         }
// // //       }

// // //       // Restore system UI
// // //       try {
// // //         SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
// // //             overlays: SystemUiOverlay.values);

// // //         SystemChrome.setPreferredOrientations([
// // //           DeviceOrientation.portraitUp,
// // //           DeviceOrientation.portraitDown,
// // //           DeviceOrientation.landscapeLeft,
// // //           DeviceOrientation.landscapeRight,
// // //         ]);
// // //       } catch (e) {
// // //         print('Error restoring system UI in dispose: $e');
// // //       }
// // //     } catch (e) {
// // //       print('Error in dispose: $e');
// // //     }

// // //     super.dispose();
// // //   }

// // //   String _formatDuration(Duration duration) {
// // //     String twoDigits(int n) => n.toString().padLeft(2, '0');
// // //     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
// // //     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
// // //     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
// // //   }

// // //   // Helper methods for splash countdown
// // //   double _getSplashProgress() {
// // //     if (_splashStartTime == null) return 0.0;

// // //     final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
// // //     final progress = elapsed / 12.0; // 12 seconds total
// // //     return progress.clamp(0.0, 1.0);
// // //   }

// // //   int _getRemainingSeconds() {
// // //     if (_splashStartTime == null) return 12;

// // //     final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
// // //     final remaining = 12 - elapsed;
// // //     return remaining.clamp(0, 12);
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     // Don't render if disposed
// // //     if (_isDisposed) {
// // //       return const Scaffold(
// // //         backgroundColor: Colors.black,
// // //         body: Center(
// // //           child: CircularProgressIndicator(color: Colors.red),
// // //         ),
// // //       );
// // //     }

// // //     return RawKeyboardListener(
// // //       focusNode: _mainFocusNode,
// // //       autofocus: true,
// // //       onKey: _handleKeyEvent,
// // //       child: WillPopScope(
// // //         onWillPop: _onWillPop,
// // //         child: Scaffold(
// // //           backgroundColor: Colors.black, // Set black background
// // //           body: GestureDetector(
// // //             onTap: _shouldBlockControls()
// // //                 ? null
// // //                 : _showControlsTemporarily, // Disable tap only during first 8 seconds
// // //             behavior: HitTestBehavior.translucent, // CHANGED: Use translucent
// // //             child: Stack(
// // //               children: [
// // //                 // 1. BOTTOM LAYER: Full screen video player
// // //                 Positioned.fill(
// // //                   child: _buildVideoPlayer(),
// // //                 ),

// // //                 // 2. MIDDLE LAYER: Top/Bottom Black Bars
// // //                 if (_showSplashScreen)
// // //                   Positioned.fill(
// // //                     child: _buildTopBottomBlackBars(),
// // //                   ),

// // //                 // 3. TOP LAYER: Custom Controls Overlay
// // //                 Positioned.fill(
// // //                   child: _buildControlsOverlay(),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // FIXED: Video Player with proper configuration
// // //   Widget _buildVideoPlayer() {
// // //     if (_error != null) {
// // //       return Container(
// // //         color: Colors.black,
// // //         child: Center(
// // //           child: Column(
// // //             mainAxisAlignment: MainAxisAlignment.center,
// // //             children: [
// // //               const Icon(Icons.error, color: Colors.red, size: 48),
// // //               const SizedBox(height: 16),
// // //               Text(_error!, style: const TextStyle(color: Colors.white)),
// // //               const SizedBox(height: 16),
// // //               ElevatedButton(
// // //                 onPressed: () {
// // //                   if (!_isDisposed && mounted) {
// // //                     setState(() {
// // //                       _isLoading = true;
// // //                       _error = null;
// // //                     });
// // //                     _controller?.dispose();
// // //                     _initializePlayer();
// // //                   }
// // //                 },
// // //                 child: const Text('Retry'),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       );
// // //     }

// // //     if (_controller == null || _isLoading) {
// // //       return Container(
// // //         color: Colors.black,
// // //         child: const Center(
// // //           child: Column(
// // //             mainAxisAlignment: MainAxisAlignment.center,
// // //             children: [
// // //               CircularProgressIndicator(color: Colors.red),
// // //               SizedBox(height: 20),
// // //               Text('Loading for TV Display...',
// // //                   style: TextStyle(color: Colors.white, fontSize: 18)),
// // //             ],
// // //           ),
// // //         ),
// // //       );
// // //     }

// // //     return Container(
// // //       width: double.infinity,
// // //       height: double.infinity,
// // //       color: Colors.black,
// // //       child: YoutubePlayer(
// // //         controller: _controller!,
// // //         showVideoProgressIndicator: false, // HIDE default progress indicator
// // //         progressIndicatorColor: Colors.transparent, // Make transparent
// // //         width: double.infinity,
// // //         aspectRatio: 16 / 9,
        
// // //         // REMOVE default actions for clean overlay
// // //         topActions: const [], // Remove top actions
// // //         bottomActions: const [], // Remove bottom actions
        
// // //         bufferIndicator: Container(
// // //           color: Colors.black,
// // //           child: const Center(
// // //             child: Column(
// // //               mainAxisAlignment: MainAxisAlignment.center,
// // //               children: [
// // //                 CircularProgressIndicator(color: Colors.red),
// // //                 SizedBox(height: 10),
// // //                 Text('Buffering...', style: TextStyle(color: Colors.white)),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //         onReady: () {
// // //           print('📺 TV Player Ready - forcing video surface');
// // //           if (!_isPlayerReady && !_isDisposed) {
// // //             if (mounted) {
// // //               setState(() => _isPlayerReady = true);
// // //             }

// // //             // Focus on main node when ready, controls will show when needed
// // //             Future.delayed(const Duration(milliseconds: 500), () {
// // //               if (!_isDisposed) {
// // //                 _mainFocusNode.requestFocus();
// // //               }
// // //             });

// // //             // TV video surface activation - Start playing from beginning with sound
// // //             Future.delayed(const Duration(milliseconds: 100), () {
// // //               if (_controller != null && mounted && !_isDisposed) {
// // //                 // Start from beginning
// // //                 _controller!.play();
// // //                 print(
// // //                     '🎬 TV: Video started playing from beginning (with sound during black bars)');
// // //               }
// // //             });
// // //           }
// // //         },
// // //         onEnded: (_) {
// // //           if (_isDisposed || _isNavigating || _videoCompleted) return;

// // //           print('🎬 Video ended naturally - using completion handler');
// // //           _completeVideo(); // Use same completion method
// // //         },
// // //       ),
// // //     );
// // //   }

// // //   // FIXED: Top and Bottom Black Bars with proper structure
// // //   Widget _buildTopBottomBlackBars() {
// // //     final screenHeight = MediaQuery.of(context).size.height;
// // //     final barHeight = screenHeight / 7;

// // //     return Container(
// // //       width: double.infinity,
// // //       height: double.infinity,
// // //       color: Colors.transparent,
// // //       child: Column(
// // //         children: [
// // //           // Top Black Bar
// // //           Container(
// // //             width: double.infinity,
// // //             height: barHeight,
// // //             color: Colors.black,
// // //           ),
          
// // //           // Middle area (video visible - transparent)
// // //           Expanded(
// // //             child: Container(
// // //               color: Colors.transparent,
// // //             ),
// // //           ),
          
// // //           // Bottom Black Bar
// // //           Container(
// // //             width: double.infinity,
// // //             height: barHeight,
// // //             color: Colors.black,
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // COMPLETELY REWRITTEN: Controls Overlay with proper layering
// // //   Widget _buildControlsOverlay() {
// // //     return Container(
// // //       width: double.infinity,
// // //       height: double.infinity,
// // //       color: Colors.transparent, // Transparent background
// // //       child: Stack(
// // //         children: [
// // //           // Semi-transparent background when controls are visible
// // //           if (_showControls)
// // //             Container(
// // //               width: double.infinity,
// // //               height: double.infinity,
// // //               color: Colors.black.withOpacity(0.3),
// // //             ),

// // //           // Actual Controls UI
// // //           if (_showControls && !_shouldBlockControls())
// // //             Positioned(
// // //               bottom: 30,
// // //               left: 20,
// // //               right: 20,
// // //               child: Container(
// // //                 padding: const EdgeInsets.all(20),
// // //                 decoration: BoxDecoration(
// // //                   color: Colors.black.withOpacity(0.8),
// // //                   borderRadius: BorderRadius.circular(15),
// // //                   border: Border.all(color: Colors.white.withOpacity(0.2)),
// // //                 ),
// // //                 child: Row(
// // //                   crossAxisAlignment: CrossAxisAlignment.center,
// // //                   children: [
// // //                     // Progress Bar Section
// // //                     Expanded(
// // //                       child: Column(
// // //                         mainAxisSize: MainAxisSize.min,
// // //                         children: [
// // //                           // Custom Progress Bar
// // //                           Focus(
// // //                             focusNode: _progressFocusNode,
// // //                             onFocusChange: (focused) {
// // //                               if (mounted && !_isDisposed) {
// // //                                 setState(() {
// // //                                   _isProgressFocused = focused;
// // //                                 });
// // //                                 if (focused) _showControlsTemporarily();
// // //                               }
// // //                             },
// // //                             child: Builder(
// // //                               builder: (context) {
// // //                                 final isFocused = Focus.of(context).hasFocus;
// // //                                 return Container(
// // //                                   height: 8,
// // //                                   decoration: BoxDecoration(
// // //                                     borderRadius: BorderRadius.circular(4),
// // //                                     border: isFocused
// // //                                         ? Border.all(color: Colors.white, width: 2)
// // //                                         : null,
// // //                                     color: Colors.white.withOpacity(0.3),
// // //                                   ),
// // //                                   child: ClipRRect(
// // //                                     borderRadius: BorderRadius.circular(4),
// // //                                     child: Stack(
// // //                                       children: [
// // //                                         // Main progress bar
// // //                                         if (_totalDuration.inSeconds > 0)
// // //                                           FractionallySizedBox(
// // //                                             alignment: Alignment.centerLeft,
// // //                                             widthFactor: _currentPosition.inSeconds /
// // //                                                 _totalDuration.inSeconds,
// // //                                             child: Container(
// // //                                               height: 8,
// // //                                               decoration: BoxDecoration(
// // //                                                 borderRadius: BorderRadius.circular(4),
// // //                                                 color: Colors.red,
// // //                                               ),
// // //                                             ),
// // //                                           ),
// // //                                         // Seeking preview indicator
// // //                                         if (_isSeeking && _totalDuration.inSeconds > 0)
// // //                                           FractionallySizedBox(
// // //                                             alignment: Alignment.centerLeft,
// // //                                             widthFactor: _targetSeekPosition.inSeconds /
// // //                                                 _totalDuration.inSeconds,
// // //                                             child: Container(
// // //                                               height: 8,
// // //                                               decoration: BoxDecoration(
// // //                                                 borderRadius: BorderRadius.circular(4),
// // //                                                 color: Colors.yellow.withOpacity(0.8),
// // //                                               ),
// // //                                             ),
// // //                                           ),
// // //                                       ],
// // //                                     ),
// // //                                   ),
// // //                                 );
// // //                               },
// // //                             ),
// // //                           ),

// // //                           const SizedBox(height: 12),

// // //                           // Time indicators and help text
// // //                           Row(
// // //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                             children: [
// // //                               Text(
// // //                                 _isSeeking
// // //                                     ? _formatDuration(_targetSeekPosition)
// // //                                     : _formatDuration(_currentPosition),
// // //                                 style: TextStyle(
// // //                                   color: _isSeeking ? Colors.yellow : Colors.white,
// // //                                   fontSize: 14,
// // //                                   fontWeight: _isSeeking ? FontWeight.bold : FontWeight.normal,
// // //                                 ),
// // //                               ),
// // //                               if (_isProgressFocused)
// // //                                 Column(
// // //                                   mainAxisSize: MainAxisSize.min,
// // //                                   children: [
// // //                                     const Text(
// // //                                       '← → Seek | ↑↓ Navigate',
// // //                                       style: TextStyle(
// // //                                         color: Colors.white70,
// // //                                         fontSize: 12,
// // //                                       ),
// // //                                     ),
// // //                                     if (_isSeeking)
// // //                                       Text(
// // //                                         '${_pendingSeekSeconds > 0 ? "+" : ""}${_pendingSeekSeconds}s',
// // //                                         style: const TextStyle(
// // //                                           color: Colors.yellow,
// // //                                           fontSize: 12,
// // //                                           fontWeight: FontWeight.bold,
// // //                                         ),
// // //                                       ),
// // //                                   ],
// // //                                 ),
// // //                               Text(
// // //                                 _formatDuration(Duration(
// // //                                   seconds: (_totalDuration.inSeconds - 12)
// // //                                       .clamp(0, double.infinity)
// // //                                       .toInt(),
// // //                                 )), // Show adjusted total duration (minus 12s)
// // //                                 style: const TextStyle(
// // //                                   color: Colors.white,
// // //                                   fontSize: 14,
// // //                                 ),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ),

// // //                     const SizedBox(width: 20),

// // //                     // Play/Pause Button
// // //                     Focus(
// // //                       focusNode: _playPauseFocusNode,
// // //                       onFocusChange: (focused) {
// // //                         if (focused && !_isDisposed) _showControlsTemporarily();
// // //                       },
// // //                       child: Builder(
// // //                         builder: (context) {
// // //                           final isFocused = Focus.of(context).hasFocus;
// // //                           return GestureDetector(
// // //                             onTap: _togglePlayPause,
// // //                             child: Container(
// // //                               width: 70,
// // //                               height: 70,
// // //                               decoration: BoxDecoration(
// // //                                 color: Colors.red.withOpacity(0.9),
// // //                                 borderRadius: BorderRadius.circular(35),
// // //                                 border: isFocused
// // //                                     ? Border.all(color: Colors.white, width: 3)
// // //                                     : Border.all(color: Colors.white.withOpacity(0.3), width: 1),
// // //                                 boxShadow: [
// // //                                   BoxShadow(
// // //                                     color: Colors.black.withOpacity(0.4),
// // //                                     blurRadius: 10,
// // //                                     offset: const Offset(0, 4),
// // //                                   ),
// // //                                 ],
// // //                               ),
// // //                               child: Icon(
// // //                                 _isPlaying ? Icons.pause : Icons.play_arrow,
// // //                                 color: Colors.white,
// // //                                 size: 40,
// // //                               ),
// // //                             ),
// // //                           );
// // //                         },
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),

// // //           // Tap area for showing controls when hidden
// // //           if (!_showControls && !_shouldBlockControls())
// // //             GestureDetector(
// // //               onTap: _showControlsTemporarily,
// // //               behavior: HitTestBehavior.translucent,
// // //               child: Container(
// // //                 width: double.infinity,
// // //                 height: double.infinity,
// // //                 color: Colors.transparent,
// // //               ),
// // //             ),

// // //           // Debug info in development mode (optional)
// // //           if (_showSplashScreen)
// // //             Positioned(
// // //               top: 50,
// // //               left: 20,
// // //               child: Container(
// // //                 padding: const EdgeInsets.all(8),
// // //                 decoration: BoxDecoration(
// // //                   color: Colors.black.withOpacity(0.7),
// // //                   borderRadius: BorderRadius.circular(8),
// // //                 ),
// // //                 child: Text(
// // //                   'Loading: ${_getRemainingSeconds()}s remaining',
// // //                   style: const TextStyle(
// // //                     color: Colors.white,
// // //                     fontSize: 12,
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }









// // import 'package:flutter/material.dart';
// // import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// // import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// // class CustomYoutubePlayer extends StatefulWidget {
// //   final String videoUrl;
  
// //   const CustomYoutubePlayer({
// //     Key? key,
// //     required this.videoUrl,
// //   }) : super(key: key);

// //   @override
// //   State<CustomYoutubePlayer> createState() => _CustomYoutubePlayerState();
// // }

// // class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
// //   VlcPlayerController? _controller;
// //   bool _isLoading = true;
// //   String? _error;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadVideo();
// //   }

// //   Future<void> _loadVideo() async {
// //     try {
// //       setState(() {
// //         _isLoading = true;
// //         _error = null;
// //       });

// //       // Get video stream URL
// //       final youtube = YoutubeExplode();
// //       final manifest = await youtube.videos.streamsClient.getManifest('1HrXwe6s4W8');
      
// //       // Get best muxed stream (video + audio)
// //       final muxedStreams = manifest.muxed;
// //       if (muxedStreams.isEmpty) {
// //         throw Exception('No muxed streams available');
// //       }
      
// //       final streamInfo = muxedStreams.withHighestBitrate();
// //       final streamUrl = streamInfo.url.toString();
      
// //       print('Stream URL: $streamUrl');
      
// //       // Dispose existing controller if any
// //       if (_controller != null) {
// //         await _controller!.dispose();
// //         _controller = null;
// //       }
      
// //       // Add delay before creating controller
// //       await Future.delayed(Duration(milliseconds: 500));
      
// //       // Create VLC controller
// //       _controller = VlcPlayerController.network(
// //         streamUrl,
// //         hwAcc: HwAcc.disabled,
// //         autoPlay: false, // Manual play control
// //         options: VlcPlayerOptions(),
// //       );
      
// //       // Initialize player with timeout
// //       await _controller!.initialize().timeout(
// //         Duration(seconds: 10),
// //         onTimeout: () {
// //           throw Exception('Player initialization timeout');
// //         },
// //       );
      
// //       // Wait a bit more then start playing
// //       await Future.delayed(Duration(milliseconds: 1000));
      
// //       if (_controller != null && mounted) {
// //         await _controller!.play();
// //       }
      
// //       setState(() {
// //         _isLoading = false;
// //       });
      
// //       youtube.close();
      
// //     } catch (e) {
// //       print('Error: $e');
// //       setState(() {
// //         _isLoading = false;
// //         _error = e.toString();
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Simple YouTube Player'),
// //         backgroundColor: Colors.red,
// //       ),
// //       body: _buildBody(),
// //     );
// //   }

// //   Widget _buildBody() {
// //     if (_isLoading) {
// //       return Center(
// //         child: CircularProgressIndicator(),
// //       );
// //     }
    
// //     if (_error != null) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(Icons.error, size: 64, color: Colors.red),
// //             SizedBox(height: 16),
// //             Text(
// //               'Error loading video',
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //             SizedBox(height: 8),
// //             Padding(
// //               padding: EdgeInsets.all(16),
// //               child: Text(
// //                 _error!,
// //                 textAlign: TextAlign.center,
// //                 style: TextStyle(color: Colors.red),
// //               ),
// //             ),
// //             ElevatedButton(
// //               onPressed: _loadVideo,
// //               child: Text('Retry'),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: Colors.red,
// //                 foregroundColor: Colors.white,
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     }
    
// //     if (_controller == null) {
// //       return Center(child: Text('No video'));
// //     }
    
// //     return Column(
// //       children: [
// //         Expanded(
// //           child: VlcPlayer(
// //             controller: _controller!,
// //             aspectRatio: 16 / 9,
// //             placeholder: Center(
// //               child: CircularProgressIndicator(),
// //             ),
// //           ),
// //         ),
// //         Container(
// //           padding: EdgeInsets.all(16),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //             children: [
// //               IconButton(
// //                 onPressed: _controller != null ? () => _controller!.play() : null,
// //                 icon: Icon(Icons.play_arrow),
// //                 iconSize: 32,
// //                 color: _controller != null ? Colors.green : Colors.grey,
// //               ),
// //               IconButton(
// //                 onPressed: _controller != null ? () => _controller!.pause() : null,
// //                 icon: Icon(Icons.pause),
// //                 iconSize: 32,
// //                 color: _controller != null ? Colors.orange : Colors.grey,
// //               ),
// //               IconButton(
// //                 onPressed: _controller != null ? () => _controller!.stop() : null,
// //                 icon: Icon(Icons.stop),
// //                 iconSize: 32,
// //                 color: _controller != null ? Colors.red : Colors.grey,
// //               ),
// //               IconButton(
// //                 onPressed: _loadVideo,
// //                 icon: Icon(Icons.refresh),
// //                 iconSize: 32,
// //                 color: Colors.blue,
// //               ),
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _controller?.dispose();
// //     super.dispose();
// //   }
// // }


// // // // Ultra Simple Version - बिना किसी complexity के
// // // class UltraSimplePlayer extends StatefulWidget {
// // //   final String videoUrl;
  
// // //   const UltraSimplePlayer({Key? key, required this.videoUrl}) : super(key: key);

// // //   @override
// // //   State<UltraSimplePlayer> createState() => _UltraSimplePlayerState();
// // // }

// // // class _UltraSimplePlayerState extends State<UltraSimplePlayer> {
// // //   VlcPlayerController? controller;
// // //   bool loading = true;
// // //   String? error;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     loadVideo();
// // //   }

// // //   loadVideo() async {
// // //     try {
// // //       setState(() => loading = true);
      
// // //       final youtube = YoutubeExplode();
// // //       final manifest = await youtube.videos.streamsClient.getManifest(widget.videoUrl);
// // //       final streams = manifest.muxed;
      
// // //       if (streams.isEmpty) {
// // //         throw 'No streams found';
// // //       }
      
// // //       final url = streams.first.url.toString();
      
// // //       controller = VlcPlayerController.network(url, autoPlay: true);
// // //       await controller?.initialize();
      
// // //       if (mounted) setState(() => loading = false);
// // //       youtube.close();
      
// // //     } catch (e) {
// // //       if (mounted) setState(() {
// // //         loading = false;
// // //         error = e.toString();
// // //       });
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: Text('Ultra Simple Player')),
// // //       body: loading 
// // //         ? Center(child: CircularProgressIndicator())
// // //         : error != null
// // //           ? Center(child: Text('Error: $error'))
// // //           : controller != null
// // //             ? VlcPlayer(controller: controller!, aspectRatio: 16/9,)
// // //             : Center(child: Text('No video')),
// // //     );
// // //   }

// // //   @override
// // //   void dispose() {
// // //     controller?.dispose();
// // //     super.dispose();
// // //   }
// // // }








// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:youtube_player_iframe/youtube_player_iframe.dart';
// import 'dart:async';

// class CustomYoutubePlayer extends StatefulWidget {
//   final String videoUrl;
//   final String name;

//   const CustomYoutubePlayer({
//     Key? key,
//     required this.videoUrl,
//     required this.name,
//   }) : super(key: key);

//   @override
//   State<CustomYoutubePlayer> createState() => _CustomYoutubePlayerState();
// }

// class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
//   late YoutubePlayerController _controller;
//   bool _isPlayerReady = false;
//   bool _isPlaying = false;
//   Duration _currentPosition = Duration.zero;
//   Duration _totalDuration = Duration.zero;
//   bool _showControls = true;
//   Timer? _positionTimer;
//   Timer? _hideControlsTimer;
//   final FocusNode _focusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     _initializePlayer();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusNode.requestFocus();
//     });
//   }

//   void _initializePlayer() {
//     String videoId = YoutubePlayerController.convertUrlToId(widget.videoUrl) ?? '';

//     _controller = YoutubePlayerController(
//       params: const YoutubePlayerParams(
//         showControls: false,
//         mute: false,
//         showFullscreenButton: false,
//         loop: false,
//         enableCaption: true,
//         captionLanguage: 'hi',
//         strictRelatedVideos: true,
//       ),
//     );

//     _controller.loadVideoById(videoId: videoId);

//     _controller.listen((event) {
//       if (mounted) {
//         setState(() {
//           _isPlaying = event.playerState == PlayerState.playing;
//           _isPlayerReady = event.playerState != PlayerState.unknown &&
//               event.playerState != PlayerState.buffering;
//         });
//       }
//     });

//     _startPositionTimer();
//   }

//   void _startPositionTimer() {
//     _positionTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
//       if (_isPlayerReady && mounted) {
//         try {
//           final position = await _controller.currentTime;
//           final duration = await _controller.duration;

//           if (mounted && duration > 0) {
//             setState(() {
//               _currentPosition = Duration(seconds: position.toInt());
//               _totalDuration = Duration(seconds: duration.toInt());
//             });
//           }
//         } catch (_) {}
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _hideControlsTimer?.cancel();
//     _positionTimer?.cancel();
//     _focusNode.dispose();
//     _controller.close();
//     super.dispose();
//   }

//   void _handleRawKeyEvent(RawKeyEvent event) {
//     if (event is RawKeyDownEvent) {
//       final key = event.logicalKey;
//       print("Pressed: ${key.debugName}");

//       if ([LogicalKeyboardKey.arrowLeft, LogicalKeyboardKey.arrowRight].contains(key)) {
//         if (key == LogicalKeyboardKey.arrowLeft) _seekBackward();
//         if (key == LogicalKeyboardKey.arrowRight) _seekForward();
//       } else if ([LogicalKeyboardKey.enter, LogicalKeyboardKey.select, LogicalKeyboardKey.space].contains(key)) {
//         _togglePlayPause();
//       } else if (key == LogicalKeyboardKey.arrowUp) {
//         _increaseVolume();
//       } else if (key == LogicalKeyboardKey.arrowDown) {
//         _decreaseVolume();
//       } else if ([LogicalKeyboardKey.goBack, LogicalKeyboardKey.escape].contains(key)) {
//         Navigator.of(context).pop();
//       }
//       _showControlsTemporarily();
//     }
//   }

//   void _seekBackward() async {
//     if (!_isPlayerReady) return;

//     try {
//       _positionTimer?.cancel();
//       final currentTime = await _controller.currentTime;
//       final newTime = (currentTime - 10).clamp(0.0, double.infinity);

//       setState(() {
//         _currentPosition = Duration(seconds: newTime.toInt());
//       });

//       await _controller.seekTo(seconds: newTime);
//       await Future.delayed(const Duration(milliseconds: 1500));
//       _startPositionTimer();
//     } catch (_) {
//       _startPositionTimer();
//     }
//   }

//   void _seekForward() async {
//     if (!_isPlayerReady) return;

//     try {
//       _positionTimer?.cancel();
//       final currentTime = await _controller.currentTime;
//       final duration = await _controller.duration;
//       final newTime = (currentTime + 10).clamp(0.0, duration);

//       setState(() {
//         _currentPosition = Duration(seconds: newTime.toInt());
//       });

//       await _controller.seekTo(seconds: newTime);
//       await Future.delayed(const Duration(milliseconds: 1500));
//       _startPositionTimer();
//     } catch (_) {
//       _startPositionTimer();
//     }
//   }

//   void _togglePlayPause() async {
//     if (!_isPlayerReady) return;

//     final state = await _controller.playerState;
//     if (state == PlayerState.playing) {
//       await _controller.pauseVideo();
//     } else {
//       await _controller.playVideo();
//     }
//   }

//   void _increaseVolume() {
//     print('↑ Volume up (not implemented)');
//   }

//   void _decreaseVolume() {
//     print('↓ Volume down (not implemented)');
//   }

//   void _showControlsTemporarily() {
//     _hideControlsTimer?.cancel();
//     setState(() => _showControls = true);
//     _hideControlsTimer = Timer(const Duration(seconds: 4), () {
//       if (mounted) setState(() => _showControls = false);
//     });
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final h = duration.inHours;
//     final m = duration.inMinutes.remainder(60);
//     final s = duration.inSeconds.remainder(60);
//     return h > 0 ? "$h:${twoDigits(m)}:${twoDigits(s)}" : "${twoDigits(m)}:${twoDigits(s)}";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: RawKeyboardListener(
//         focusNode: _focusNode,
//         autofocus: true,
//         onKey: _handleRawKeyEvent,
//         child: GestureDetector(
//           onTap: () {
//             _focusNode.requestFocus();
//             _showControlsTemporarily();
//           },
//           child: Stack(
//             children: [
//               Center(
//                 child: AspectRatio(
//                   aspectRatio: 16 / 9,
//                   child: YoutubePlayer(
//                     controller: _controller,
//                     aspectRatio: 16 / 9,
//                   ),
//                 ),
//               ),
//               if (_showControls)
//                 AnimatedOpacity(
//                   opacity: _showControls ? 1.0 : 0.0,
//                   duration: const Duration(milliseconds: 300),
//                   child: Container(
//                     color: Colors.black.withOpacity(0.5),
//                     child: Column(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(16),
//                           child: Row(
//                             children: [
//                               IconButton(
//                                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//                                 onPressed: () => Navigator.of(context).pop(),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Text(
//                                   'YouTube Player - ${_isPlayerReady ? "Ready" : "Loading"}',
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const Spacer(),
//                         Container(
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             children: [
//                               Row(
//                                 children: [
//                                   Text(_formatDuration(_currentPosition), style: const TextStyle(color: Colors.white)),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                     child: LinearProgressIndicator(
//                                       value: _totalDuration.inMilliseconds > 0
//                                           ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
//                                           : 0.0,
//                                       backgroundColor: Colors.white.withOpacity(0.3),
//                                       valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Text(_formatDuration(_totalDuration), style: const TextStyle(color: Colors.white)),
//                                 ],
//                               ),
//                               const SizedBox(height: 16),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   IconButton(
//                                     icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
//                                     onPressed: _seekBackward,
//                                   ),
//                                   const SizedBox(width: 24),
//                                   IconButton(
//                                     icon: Icon(
//                                       _isPlaying ? Icons.pause : Icons.play_arrow,
//                                       color: Colors.white,
//                                       size: 40,
//                                     ),
//                                     onPressed: _togglePlayPause,
//                                   ),
//                                   const SizedBox(width: 24),
//                                   IconButton(
//                                     icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
//                                     onPressed: _seekForward,
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               if (!_isPlayerReady)
//                 const Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(color: Colors.red),
//                       SizedBox(height: 16),
//                       Text('Loading video...', style: TextStyle(color: Colors.white, fontSize: 16)),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }






import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:async';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// Direct YouTube Player Screen - No Home Page Required
class CustomYoutubePlayer extends StatefulWidget {
  final videoUrl;
  final String? name; // ADD NAME PARAMETER

  const CustomYoutubePlayer({
    Key? key,
    required this.videoUrl,
    required this.name, // Optional name parameter
  }) : super(key: key);

  @override
  _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
}

class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
  YoutubePlayerController? _controller;
  int currentIndex = 0;
  bool _isPlayerReady = false;
  String? _error;
  bool _isLoading = true;
  bool _isDisposed = false; // Track disposal state

  // Navigation control - FIXED
  bool _isNavigating = false; // Prevent double navigation
  bool _videoCompleted = false; // Track video completion

  // Splash screen control with fade animation
  bool _showSplashScreen = true;
  Timer? _splashTimer;
  Timer? _splashUpdateTimer;
  DateTime? _splashStartTime;

  // End splash screen control with fade animation
  bool _showEndSplashScreen = false;
  Timer? _endSplashTimer;
  DateTime? _endSplashStartTime;

  // Animation controllers for fade effects
  double _splashOpacity = 1.0; // Start fully black (opacity = 1.0)
  double _endSplashOpacity = 0.0; // End starts transparent (opacity = 0.0)
  Timer? _fadeAnimationTimer;

  // Control states - KEPT MINIMAL FOR PROGRESS BAR
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Progressive seeking states
  Timer? _seekTimer;
  int _pendingSeekSeconds = 0;
  Duration _targetSeekPosition = Duration.zero;
  bool _isSeeking = false;

  // Focus nodes for TV remote - MINIMAL
  final FocusNode _mainFocusNode = FocusNode(); // Main invisible focus node

  @override
  void initState() {
    super.initState();
    // _initializeInAppWebView();

    print('📱 App started - Quick setup mode');

    // Set full screen immediately
    _setFullScreenMode();

    // Start player initialization immediately
    _initializePlayer();

    // Start 30 second fade splash timer
    _startSplashTimer();

    // Request focus on main node initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mainFocusNode.requestFocus();
    });
  }

  // void _initializeInAppWebView() async {
  //   try {
  //     if (Platform.isAndroid) {
  //       await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(
  //           true);
  //     }
  //   } catch (e) {
  //     print('InAppWebView initialization error: $e');
  //   }
  // }

  void _startSplashTimer() {
    _splashStartTime = DateTime.now(); // Record start time
    print(
        '🎬 Top/Bottom black bars started - will remove after exactly 12 seconds');

    // Simple timer - EXACTLY 12 seconds, no fade
    _splashTimer = Timer(const Duration(seconds: 12), () {
      if (mounted && !_isDisposed && _showSplashScreen) {
        print('🎬 12 seconds complete - removing top/bottom black bars');

        setState(() {
          _showSplashScreen = false;
        });

        print('🎮 Video now playing full screen after 12 seconds');
      }
    });

    // Timer to update countdown display every second
    _splashUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _showSplashScreen && !_isDisposed) {
        final remaining = _getRemainingSeconds();
        print('⏰ Top/Bottom black bars: ${remaining} seconds remaining');
      } else {
        timer.cancel();
      }
    });
  }

  void _setFullScreenMode() {
    // TV ke liye optimized settings
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // TV landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // TV ke liye additional settings
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }

  void _initializePlayer() {
    if (_isDisposed) return; // Don't initialize if disposed

    try {
      String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

      print('🔧 TV Mode: Initializing player for: $videoId');

      if (videoId == null || videoId.isEmpty) {
        if (mounted && !_isDisposed) {
          setState(() {
            _error = 'Invalid YouTube URL: ${widget.videoUrl}';
            _isLoading = false;
          });
        }
        return;
      }

      // TV-specific controller configuration - NO MUTING + START FROM 10 SECONDS
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          mute: false, // NO MUTING - sound stays on
          autoPlay: true,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: false,
          controlsVisibleAtStart: false,
          hideControls: true,
          startAt: 10, // START FROM 10 SECONDS - SKIP FIRST 10 SECONDS
          hideThumbnail: false,
          useHybridComposition: false,
        ),
      );

      _controller!.addListener(_listener);

      // TV ke liye manual load aur play
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _controller != null && !_isDisposed) {
          print('🎯 TV: Loading video manually');
          _controller!.load(videoId);

          // Multiple play attempts for TV
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted && _controller != null && !_isDisposed) {
              print('🎬 TV: First play attempt (with sound)');
              _controller!.play();
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _isPlayerReady = true;
                  _isPlaying = true;
                });
              }
            }
          });
        }
      });
    } catch (e) {
      print('❌ TV Error: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _error = 'TV Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  // FIXED: Single navigation trigger
  void _listener() {
    if (_controller != null && mounted && !_isDisposed && !_isNavigating) {
      if (_controller!.value.isReady && !_isPlayerReady) {
        print('📡 Controller ready detected - starting from beginning');

        // Ensure video starts from beginning
        _controller!.play();

        if (mounted) {
          setState(() {
            _isPlayerReady = true;
            _isPlaying = true;
          });
        }
      }

      // Update position and duration
      if (mounted) {
        setState(() {
          _currentPosition = _controller!.value.position;
          _totalDuration = _controller!.value.metaData.duration;

          bool newIsPlaying = _controller!.value.isPlaying;
          _isPlaying = newIsPlaying;
        });
      }

      // FIXED: Single navigation trigger with proper checks
      if (_totalDuration.inSeconds > 24 &&
          _currentPosition.inSeconds > 0 &&
          !_videoCompleted) {
        final adjustedEndTime = _totalDuration.inSeconds - 12;

        if (_currentPosition.inSeconds >= adjustedEndTime) {
          print('🛑 Video reached cut point - completing video');
          _completeVideo(); // Single method for video completion
        }
      }
    }
  }

  // NEW: Single method to handle video completion
  void _completeVideo() {
    if (_isNavigating || _videoCompleted || _isDisposed) return;

    print('🎬 Video completing - single navigation trigger');

    // Mark as completed to prevent multiple triggers
    _videoCompleted = true;
    _isNavigating = true;

    // Pause the video
    if (_controller != null) {
      _controller!.pause();
    }

    // Single navigation with cleanup
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && !_isDisposed) {
        print('🔙 Navigating back to source page');
        Navigator.of(context).pop();
      }
    });
  }

  // NEW: Reset states for new video
  void _resetVideoStates() {
    _isNavigating = false;
    _videoCompleted = false;
    _isPlayerReady = false;
    _isPlaying = false;
  }

  void _togglePlayPause() {
    if (_controller != null && _isPlayerReady && !_isDisposed) {
      if (_isPlaying) {
        _controller!.pause();
        print('⏸️ Video paused');
      } else {
        _controller!.play();
        print('▶️ Video playing');
      }
    }
  }

  void _seekVideo(bool forward) {
    if (_controller != null &&
        _isPlayerReady &&
        _totalDuration.inSeconds > 24 &&
        !_isDisposed) {
      final adjustedEndTime =
          _totalDuration.inSeconds - 12; // Don't allow seeking beyond cut point
      final seekAmount =
          (adjustedEndTime / 200).round().clamp(5, 30); // 5-30 seconds

      // Cancel previous seek timer
      _seekTimer?.cancel();

      // Calculate new pending seek
      if (forward) {
        _pendingSeekSeconds += seekAmount;
        print(
            '⏩ Adding forward seek: +${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
      } else {
        _pendingSeekSeconds -= seekAmount;
        print(
            '⏪ Adding backward seek: -${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
      }

      // Calculate target position for preview - RESPECT END CUT BOUNDARY
      final currentSeconds = _currentPosition.inSeconds;
      final targetSeconds = (currentSeconds + _pendingSeekSeconds)
          .clamp(0, adjustedEndTime); // 0 to end-12s
      _targetSeekPosition = Duration(seconds: targetSeconds);

      // Show seeking state
      if (mounted && !_isDisposed) {
        setState(() {
          _isSeeking = true;
        });
      }

      // Set timer to execute seek after 1 second of no input
      _seekTimer = Timer(const Duration(milliseconds: 1000), () {
        _executeSeek();
      });
    }
  }

  void _executeSeek() {
    if (_controller != null &&
        _isPlayerReady &&
        !_isDisposed &&
        _pendingSeekSeconds != 0) {
      final adjustedEndTime =
          _totalDuration.inSeconds - 12; // Don't seek beyond cut point
      final currentSeconds = _currentPosition.inSeconds;
      final newPosition = (currentSeconds + _pendingSeekSeconds)
          .clamp(0, adjustedEndTime); // Respect end cut boundary

      print(
          '🎯 Executing accumulated seek: ${_pendingSeekSeconds}s to position ${newPosition}s (within cut boundaries)');

      // Execute the seek
      _controller!.seekTo(Duration(seconds: newPosition));

      // Reset seeking state
      _pendingSeekSeconds = 0;
      _targetSeekPosition = Duration.zero;

      if (mounted && !_isDisposed) {
        setState(() {
          _isSeeking = false;
        });
      }
    }
  }

  // Start end splash screen when 30 seconds remain - SOLID BLACK
  void _startEndSplashTimer() {
    if (_showEndSplashScreen || _isDisposed)
      return; // Prevent multiple triggers

    _endSplashStartTime = DateTime.now();
    print('🎬 End solid black splash started - will show for 30 seconds');

    setState(() {
      _showEndSplashScreen = true;
    });

    // Simple timer for end splash - 30 seconds solid black
    _endSplashTimer = Timer(const Duration(seconds: 30), () {
      if (mounted && !_isDisposed) {
        print('🎬 End splash complete - ready for navigation');

        setState(() {
          _showEndSplashScreen = false;
        });
      }
    });

    print('⏰ End solid black splash started - will cover video completely');
  }

  // Helper method to check if controls should be blocked (only first 8 seconds)
  bool _shouldBlockControls() {
    if (_showSplashScreen && _splashStartTime != null) {
      final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
      return elapsed < 8; // Block only for first 8 seconds
    }
    return false;
  }

  // Helper methods for splash countdown
  double _getSplashProgress() {
    if (_splashStartTime == null) return 0.0;

    final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
    final progress = elapsed / 12.0; // 12 seconds total
    return progress.clamp(0.0, 1.0);
  }

  int _getRemainingSeconds() {
    if (_splashStartTime == null) return 12;

    final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
    final remaining = 12 - elapsed;
    return remaining.clamp(0, 12);
  }

  // SIMPLIFIED key event handling - only basic controls
  bool _handleKeyEvent(RawKeyEvent event) {
    if (_isDisposed) return false;

    // BLOCK key events only during first 8 seconds of splash screen
    if (_shouldBlockControls()) {
      if (event is RawKeyDownEvent) {
        switch (event.logicalKey) {
          case LogicalKeyboardKey.escape:
          case LogicalKeyboardKey.backspace:
            // Allow back navigation during splash
            print('🔙 Back pressed during splash - exiting');
            if (!_isDisposed) {
              Navigator.of(context).pop();
            }
            return true;
          default:
            // Block other keys only for 8 seconds
            print(
                '🚫 Key blocked during first 8 seconds of splash: ${event.logicalKey}');
            return true;
        }
      }
      return true;
    }

    // Normal key handling after splash is gone
    if (event is RawKeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.select:
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.space:
          _togglePlayPause();
          return true;

        case LogicalKeyboardKey.arrowLeft:
          _seekVideo(false);
          return true;

        case LogicalKeyboardKey.arrowRight:
          _seekVideo(true);
          return true;

        case LogicalKeyboardKey.escape:
        case LogicalKeyboardKey.backspace:
          if (!_isDisposed) {
            Navigator.of(context).pop();
          }
          return true;

        default:
          break;
      }
    }
    return false;
  }

  void _showError(String message) {
    if (mounted && !_isDisposed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // FIXED: Handle back button press - TV Remote ke liye
  Future<bool> _onWillPop() async {
    if (_isDisposed || _isNavigating) return true;

    try {
      print('🔙 Back button pressed - cleaning up...');

      // Mark as navigating to prevent other triggers
      _isNavigating = true;
      _isDisposed = true;

      // Cancel all timers
      _splashTimer?.cancel();
      _splashUpdateTimer?.cancel();
      _seekTimer?.cancel();

      // Pause and dispose controller
      if (_controller != null) {
        try {
          if (_controller!.value.isPlaying) {
            _controller!.pause();
          }
          _controller!.dispose();
          _controller = null;
        } catch (e) {
          print('Error disposing controller: $e');
        }
      }

      // Restore system UI in a try-catch
      try {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: SystemUiOverlay.values);

        // Reset orientation to allow all orientations
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } catch (e) {
        print('Error restoring system UI: $e');
      }

      return true; // Allow back navigation
    } catch (e) {
      print('Error in _onWillPop: $e');
      return true;
    }
  }

  @override
  void deactivate() {
    print('🔄 Screen deactivating...');
    _isDisposed = true;
    _controller?.pause();
    _splashTimer?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    print('🗑️ Disposing YouTube player screen...');

    try {
      // Mark as disposed
      _isDisposed = true;

      // Cancel timers
      _seekTimer?.cancel();
      _splashTimer?.cancel();
      _splashUpdateTimer?.cancel();

      // Dispose focus nodes
      if (_mainFocusNode.hasListeners) {
        _mainFocusNode.dispose();
      }

      // Dispose controller
      if (_controller != null) {
        try {
          _controller!.pause();
          _controller!.dispose();
          _controller = null;
        } catch (e) {
          print('Error disposing controller in dispose: $e');
        }
      }

      // Restore system UI
      try {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: SystemUiOverlay.values);

        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } catch (e) {
        print('Error restoring system UI in dispose: $e');
      }
    } catch (e) {
      print('Error in dispose: $e');
    }

    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    // Don't render if disposed
    if (_isDisposed) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return RawKeyboardListener(
      focusNode: _mainFocusNode,
      autofocus: true,
      onKey: _handleKeyEvent,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          body: GestureDetector(
            child: Stack(
              children: [
                // Full screen video player (always present and playing in background)
                _buildVideoPlayer(),

                // Top/Bottom Black Bars with Progress Bar - Always visible
                _buildTopBottomBlackBars(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Top and Bottom Black Bars with Progress Bar and Name - Video plays in center (Start Splash)
  Widget _buildTopBottomBlackBars() {
    return Stack(
      children: [
        // Top Black Bar with Name - screenhgt/10 height
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: screenhgt / 8.3,
          child: Container(
            color: Colors.black54,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Name Display
                Container(
                  // margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    widget.name ?? '', // Display name or default text
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Bottom Black Bar with Progress Bar - screenhgt/10 height
        Positioned(
          bottom: 0,
          left: screenwdt *0.65,
          right: 0,
          height: screenhgt / 8.3,
          child: Container(
            color: Colors.black54,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Progress Bar Container
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      // Progress Bar
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Stack(
                            children: [
                              // Background
                              Container(
                                width: double.infinity,
                                height: 6,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              // Progress indicator
                              if (_totalDuration.inSeconds > 0)
                                FractionallySizedBox(
                                  widthFactor: _currentPosition.inSeconds / 
                                      (_totalDuration.inSeconds - 12).clamp(1, double.infinity),
                                  child: Container(
                                    height: 6,
                                    color: Colors.red,
                                  ),
                                ),
                              // Seeking preview (if seeking)
                              if (_isSeeking && _totalDuration.inSeconds > 0)
                                FractionallySizedBox(
                                  widthFactor: _targetSeekPosition.inSeconds / 
                                      (_totalDuration.inSeconds - 12).clamp(1, double.infinity),
                                  child: Container(
                                    height: 6,
                                    color: Colors.yellow.withOpacity(0.8),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      // const SizedBox(height: 8),
                      
                      // Time Display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isSeeking
                                ? _formatDuration(_targetSeekPosition)
                                : _formatDuration(_currentPosition),
                            style: TextStyle(
                              color: _isSeeking ? Colors.yellow : Colors.white,
                              fontSize: 12,
                              fontWeight: _isSeeking ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          Text(
                            _formatDuration(Duration(
                                seconds: (_totalDuration.inSeconds - 12)
                                    .clamp(0, double.infinity)
                                    .toInt())),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    if (_error != null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (!_isDisposed && mounted) {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                    });
                    _controller?.dispose();
                    _initializePlayer();
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller == null || _isLoading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.red),
              SizedBox(height: 20),
              Text('Loading for TV Display...',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: false,
        progressIndicatorColor: Colors.red,
        width: double.infinity,
        aspectRatio: 16 / 9,
        bufferIndicator: Container(
          color: Colors.black,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.red),
                SizedBox(height: 10),
                Text('Buffering...', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
        onReady: () {
          print('📺 TV Player Ready - forcing video surface');
          if (!_isPlayerReady && !_isDisposed) {
            if (mounted) {
              setState(() => _isPlayerReady = true);
            }

            // Focus on main node when ready
            Future.delayed(const Duration(milliseconds: 500), () {
              if (!_isDisposed) {
                _mainFocusNode.requestFocus();
              }
            });

            // TV video surface activation - Start playing from beginning with sound
            Future.delayed(const Duration(milliseconds: 100), () {
              if (_controller != null && mounted && !_isDisposed) {
                // Start from beginning
                _controller!.play();
                print(
                    '🎬 TV: Video started playing from beginning (with sound during black bars)');
              }
            });
          }
        },
        onEnded: (_) {
          if (_isDisposed || _isNavigating || _videoCompleted) return;

          print('🎬 Video ended naturally - using completion handler');
          _completeVideo(); // Use same completion method
        },
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// class CustomYoutubePlayer extends StatefulWidget {
//   final String videoUrl;
//   final String name;
  
//   const CustomYoutubePlayer({
//     Key? key,
//     required this.videoUrl,
//     required this.name,
//   }) : super(key: key);

//   @override
//   State<CustomYoutubePlayer> createState() => _CustomYoutubePlayerState();
// }

// class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
//   late YoutubePlayerController _controller;
//   bool _isPlayerReady = false;

//   @override
//   void initState() {
//     super.initState();
    
//     // YouTube URL se video ID extract karna
//     final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    
//     if (videoId != null) {
//       _controller = YoutubePlayerController(
//         initialVideoId: videoId,
//         flags: const YoutubePlayerFlags(
//           mute: false,
//           autoPlay: true,
//           disableDragSeek: false,
//           loop: false,
//           isLive: false,
//           // forceFullscreen: false,
//           enableCaption: true,
//         ),
//       );
//     } else {
//       // Invalid URL ke case mein default video ID
//       _controller = YoutubePlayerController(
//         initialVideoId: 'dQw4w9WgXcQ', // Default video
//         flags: const YoutubePlayerFlags(
//           mute: false,
//           autoPlay: false,
//         ),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('YouTube Player'),
//         backgroundColor: Colors.red,
//         foregroundColor: Colors.white,
//       ),
//       body: videoId == null
//           ? _buildErrorWidget()
//           : Column(
//               children: [
//                 YoutubePlayer(
//                   controller: _controller,
//                   showVideoProgressIndicator: true,
//                   progressIndicatorColor: Colors.red,
//                   onReady: () {
//                     _isPlayerReady = true;
//                   },
//                   onEnded: (data) {
//                     // Video end hone par kya karna hai
//                     showDialog(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                         title: const Text('Video Ended'),
//                         content: const Text('Video playback completed!'),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: const Text('OK'),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 _buildVideoInfo(),
//                 const SizedBox(height: 20),
//                 _buildControlButtons(),
//               ],
//             ),
//     );
//   }

//   Widget _buildErrorWidget() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.error_outline,
//             size: 64,
//             color: Colors.red,
//           ),
//           SizedBox(height: 16),
//           Text(
//             'Invalid YouTube URL',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'Please provide a valid YouTube video URL',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildVideoInfo() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Video URL:',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             widget.videoUrl,
//             style: const TextStyle(
//               fontSize: 12,
//               color: Colors.blue,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildControlButtons() {
//     return Wrap(
//       spacing: 10,
//       children: [
//         ElevatedButton.icon(
//           onPressed: () {
//             _controller.play();
//           },
//           icon: const Icon(Icons.play_arrow),
//           label: const Text('Play'),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.green,
//             foregroundColor: Colors.white,
//           ),
//         ),
//         ElevatedButton.icon(
//           onPressed: () {
//             _controller.pause();
//           },
//           icon: const Icon(Icons.pause),
//           label: const Text('Pause'),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.orange,
//             foregroundColor: Colors.white,
//           ),
//         ),
//         ElevatedButton.icon(
//           onPressed: () {
//             _controller.seekTo(const Duration(seconds: 0));
//           },
//           icon: const Icon(Icons.replay),
//           label: const Text('Restart'),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.blue,
//             foregroundColor: Colors.white,
//           ),
//         ),
//       ],
//     );
//   }
// }
