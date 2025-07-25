




// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// import 'dart:async';
// import 'package:intl/intl.dart';

// // Direct YouTube Player Screen - No Home Page Required
// class CustomYoutubePlayer extends StatefulWidget {
//   final videoUrl;
//   final String? name;

//   const CustomYoutubePlayer({
//     Key? key,
//     required this.videoUrl,
//     required this.name,
//   }) : super(key: key);

//   @override
//   _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
// }

// // Enhanced Player State Enum
// enum PlayerState { unknown, unstarted, ended, playing, paused, buffering, cued }

// class _CustomYoutubePlayerState extends State<CustomYoutubePlayer>
//     with TickerProviderStateMixin {
//   YoutubePlayerController? _controller;
//   bool _isPlayerReady = false;
//   String? _error;
//   bool _isLoading = true;
//   bool _isDisposed = false;

//   // Navigation control
//   bool _isNavigating = false;
//   bool _videoCompleted = false;

//   // Scrolling text animation controller
//   late AnimationController _scrollController;
//   late Animation<Offset> _scrollAnimation;

//   // Enhanced Control states
//   bool _isPlaying = false;
//   bool _isPaused = false;
//   bool _wasPlayingBeforeSeek = false;
//   PlayerState _currentPlayerState = PlayerState.unknown;
//   Duration _currentPosition = Duration.zero;
//   Duration _totalDuration = Duration.zero;

//   // Progressive seeking states
//   Timer? _seekTimer;
//   int _pendingSeekSeconds = 0;
//   Duration _targetSeekPosition = Duration.zero;
//   bool _isSeeking = false;

//   // Focus nodes for TV remote
//   final FocusNode _mainFocusNode = FocusNode();

//   // Date and time
//   late Timer _dateTimeTimer;
//   late Timer? _stateVerificationTimer;
//   String _currentDate = '';
//   String _currentTime = '';

//   // Video thumbnail URL
//   String? _thumbnailUrl;

//   // Variable to track if video has started playing at least once
//   bool _hasVideoStartedPlaying = false;

//   // Timer for delaying text color change
//   Timer? _textColorDelayTimer;

//   // Timer for checking video completion more reliably
//   Timer? _completionCheckTimer;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize date and time
//     _updateDateTime();
//     _startDateTimeTimer();

//     // Initialize scrolling animation
//     _initializeScrollAnimation();

//     // Set full screen immediately
//     _setFullScreenMode();

//     // Generate thumbnail URL
//     _generateThumbnailUrl();

//     // Start player initialization immediately
//     _initializePlayer();

//     // Start state verification timer
//     _startStateVerificationTimer();

//     // Start completion check timer
//     _startCompletionCheckTimer();

//     // Request focus on main node initially
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _mainFocusNode.requestFocus();
//     });
//   }

//   void _generateThumbnailUrl() {
//     String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
//     if (videoId != null && videoId.isNotEmpty) {
//       // High quality thumbnail URL
//       _thumbnailUrl = 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
//     }
//   }

//   void _updateDateTime() {
//     final now = DateTime.now();
//     _currentDate = DateFormat('MM/dd/yyyy').format(now);
//     _currentTime = DateFormat('HH:mm:ss').format(now);
//   }

//   void _startDateTimeTimer() {
//     _dateTimeTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (mounted && !_isDisposed) {
//         setState(() {
//           _updateDateTime();
//         });
//       }
//     });
//   }

//   void _initializeScrollAnimation() {
//     _scrollController = AnimationController(
//       duration: const Duration(seconds: 12),
//       vsync: this,
//     );

//     _scrollAnimation = Tween<Offset>(
//       begin: const Offset(1.0, 0.0),
//       end: const Offset(-1.0, 0.0),
//     ).animate(CurvedAnimation(
//       parent: _scrollController,
//       curve: Curves.linear,
//     ));

//     _scrollController.repeat();
//   }

//   void _setFullScreenMode() {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         systemNavigationBarColor: Colors.transparent,
//       ),
//     );
//   }

//   void _initializePlayer() {
//     if (_isDisposed) return;

//     try {
//       String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

//       if (videoId == null || videoId.isEmpty) {
//         if (mounted && !_isDisposed) {
//           setState(() {
//             _error = 'Invalid YouTube URL: ${widget.videoUrl}';
//             _isLoading = false;
//           });
//         }
//         return;
//       }

//       _controller = YoutubePlayerController(
//         initialVideoId: videoId,
//         flags: const YoutubePlayerFlags(
//           mute: false,
//           autoPlay: true,
//           disableDragSeek: false,
//           loop: false,
//           isLive: false,
//           forceHD: false,
//           enableCaption: false,
//           controlsVisibleAtStart: false,
//           hideControls: true,
//           hideThumbnail: false, // Show default thumbnail
//           // useHybridComposition: false,
//           useHybridComposition: true,
//         ),
//       );

//       _controller!.addListener(_listener);

//       Future.delayed(const Duration(milliseconds: 300), () {
//         if (mounted && _controller != null && !_isDisposed) {
//           _controller!.load(videoId);

//           Future.delayed(const Duration(milliseconds: 800), () {
//             if (mounted && _controller != null && !_isDisposed) {
//               _controller!.play();
//               if (mounted) {
//                 setState(() {
//                   _isLoading = false;
//                   _isPlayerReady = true;
//                   _isPlaying = true;
//                   _currentPlayerState = PlayerState.playing;
//                   // Start delay timer instead of immediately setting flag
//                   _startTextColorDelayTimer();
//                 });
//               }
//             }
//           });
//         }
//       });
//     } catch (e) {
//       if (mounted && !_isDisposed) {
//         setState(() {
//           _error = 'Player Error: $e';
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   // Enhanced Listener with Multiple State Checks
//   void _listener() {
//     if (_controller != null && mounted && !_isDisposed && !_isNavigating) {
//       final playerValue = _controller!.value;

//       // Get current states
//       final bool isReady = playerValue.isReady;
//       final bool isPlaying = playerValue.isPlaying;
//       final bool isBuffering = isReady &&
//           !isPlaying &&
//           _currentPosition == playerValue.position &&
//           playerValue.position.inSeconds > 0;
//       final Duration position = playerValue.position;
//       final Duration duration = playerValue.metaData.duration;

//       // Check for video end state first
//       if (duration.inSeconds > 0 && position.inSeconds > 0) {
//         // Check if video has reached the end (within 2 seconds of duration)
//         if (position.inSeconds >= (duration.inSeconds - 2)) {
//           print('Video ended - Position: ${position.inSeconds}, Duration: ${duration.inSeconds}');
//           _completeVideo();
//           return;
//         }
//       }

//       // Determine actual player state
//       PlayerState newPlayerState = _determinePlayerState(
//         isReady: isReady,
//         isPlaying: isPlaying,
//         isBuffering: isBuffering,
//         position: position,
//         duration: duration,
//       );

//       // Always sync with controller state for play/pause
//       bool shouldUpdateState = false;

//       if (newPlayerState != _currentPlayerState) {
//         shouldUpdateState = true;
//       }

//       if (isPlaying != _isPlaying) {
//         shouldUpdateState = true;
//       }

//       if (shouldUpdateState) {
//         if (mounted) {
//           setState(() {
//             _currentPlayerState = newPlayerState;
//             _isPlaying = isPlaying;
//             _isPaused = _determinePausedState(newPlayerState, isPlaying);
//             _currentPosition = position;
//             _totalDuration = duration;

//             // Update _hasVideoStartedPlaying when video actually starts playing
//             if (isPlaying && position.inSeconds > 0 && !_hasVideoStartedPlaying) {
//               _startTextColorDelayTimer();
//             }
//           });
//         }
//       } else {
//         // Update position and duration even if states haven't changed
//         if (mounted) {
//           setState(() {
//             _currentPosition = position;
//             _totalDuration = duration;

//             // Update _hasVideoStartedPlaying when video actually starts playing
//             if (isPlaying && position.inSeconds > 0 && !_hasVideoStartedPlaying) {
//               _startTextColorDelayTimer();
//             }
//           });
//         }
//       }

//       // Handle ready state
//       if (isReady && !_isPlayerReady) {
//         if (mounted) {
//           setState(() {
//             _isPlayerReady = true;
//             _isLoading = false;
//           });
//         }

//         // Auto-play after ready with small delay to ensure frame appears
//         Future.delayed(const Duration(milliseconds: 500), () {
//           if (_controller != null && !_isDisposed) {
//             _controller!.play();
//           }
//         });
//       }
//     }
//   }

//   // Start a timer to periodically check for video completion
//   void _startCompletionCheckTimer() {
//     _completionCheckTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (_isDisposed) {
//         timer.cancel();
//         return;
//       }

//       if (_controller != null && _isPlayerReady && mounted && !_videoCompleted) {
//         final playerValue = _controller!.value;
//         final position = playerValue.position;
//         final duration = playerValue.metaData.duration;

//         // More aggressive completion check
//         if (duration.inSeconds > 0 && position.inSeconds > 0) {
//           // Check if video is within 3 seconds of end or if it's actually ended
//           bool isNearEnd = position.inSeconds >= (duration.inSeconds - 3);
//           bool hasActuallyEnded = position.inSeconds >= duration.inSeconds;
//           bool isAtEnd = playerValue.position >= playerValue.metaData.duration;

//           if (isNearEnd || hasActuallyEnded || isAtEnd) {
//             print('Video completion detected - Position: ${position.inSeconds}, Duration: ${duration.inSeconds}');
//             _completeVideo();
//           }
//         }
//       }
//     });
//   }

//   // Enhanced State Determination Logic
//   PlayerState _determinePlayerState({
//     required bool isReady,
//     required bool isPlaying,
//     required bool isBuffering,
//     required Duration position,
//     required Duration duration,
//   }) {
//     if (!isReady) {
//       return PlayerState.unstarted;
//     }

//     if (isBuffering) {
//       return PlayerState.buffering;
//     }

//     if (duration.inSeconds > 0 &&
//         position.inSeconds >= duration.inSeconds - 1) {
//       return PlayerState.ended;
//     }

//     if (isPlaying) {
//       return PlayerState.playing;
//     }

//     // If ready but not playing and not buffering, it's paused
//     if (position.inSeconds > 0) {
//       return PlayerState.paused;
//     }

//     return PlayerState.cued;
//   }

//   // Accurate Pause State Detection
//   bool _determinePausedState(PlayerState playerState, bool isPlaying) {
//     return playerState == PlayerState.paused ||
//         (!isPlaying &&
//             _currentPosition.inSeconds > 0 &&
//             playerState != PlayerState.buffering &&
//             playerState != PlayerState.ended &&
//             playerState != PlayerState.unstarted &&
//             _isPlayerReady);
//   }

//   // Alternative Method: Direct Controller State Check
//   bool _getAccuratePauseState() {
//     if (_controller == null || !_isPlayerReady) return false;

//     final playerValue = _controller!.value;

//     // More reliable pause detection
//     bool controllerNotPlaying = !playerValue.isPlaying;
//     bool hasPosition = playerValue.position.inSeconds > 0;
//     bool isReady = playerValue.isReady;
//     bool notEnded = playerValue.position < playerValue.metaData.duration;

//     return controllerNotPlaying && hasPosition && isReady && notEnded;
//   }

//   // Periodic State Verification
//   void _startStateVerificationTimer() {
//     _stateVerificationTimer =
//         Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_isDisposed) {
//         timer.cancel();
//         return;
//       }

//       if (_controller != null && _isPlayerReady && mounted) {
//         final controllerPlaying = _controller!.value.isPlaying;
//         final controllerReady = _controller!.value.isReady;

//         // If there's a mismatch, correct it immediately
//         if (controllerPlaying != _isPlaying && controllerReady) {
//           setState(() {
//             _isPlaying = controllerPlaying;
//             _isPaused = !controllerPlaying &&
//                 _currentPosition.inSeconds > 0 &&
//                 controllerReady;

//             _currentPlayerState =
//                 controllerPlaying ? PlayerState.playing : PlayerState.paused;

//             // Update _hasVideoStartedPlaying when video actually starts playing
//             if (controllerPlaying && _currentPosition.inSeconds > 0 && !_hasVideoStartedPlaying) {
//               _startTextColorDelayTimer();
//             }
//           });
//         }
//       }
//     });
//   }

//   // Enhanced video completion method
//   void _completeVideo() {
//     if (_isNavigating || _videoCompleted || _isDisposed) return;

//     print('_completeVideo called - Starting navigation back');

//     _videoCompleted = true;
//     _isNavigating = true;

//     // Stop the player immediately
//     if (_controller != null) {
//       try {
//         _controller!.pause();
//         print('Video paused successfully');
//       } catch (e) {
//         print('Error pausing video: $e');
//       }
//     }

//     // Cancel all timers
//     _completionCheckTimer?.cancel();
//     _seekTimer?.cancel();
//     _stateVerificationTimer?.cancel();
//     _textColorDelayTimer?.cancel();

//     // Navigate back with a short delay to ensure cleanup
//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (mounted && !_isDisposed) {
//         print('Attempting to navigate back to source page');
//         try {
//           Navigator.of(context).pop();
//           print('Navigation completed successfully');
//         } catch (e) {
//           print('Error during navigation: $e');
//           // Try alternative navigation method
//           Navigator.pop(context);
//         }
//       }
//     });
//   }

//   // Enhanced Toggle Play/Pause with State Tracking
//   void _togglePlayPause() {
//     if (_controller != null && _isPlayerReady && !_isDisposed) {
//       final currentControllerState = _controller!.value.isPlaying;

//       if (currentControllerState) {
//         // Video is currently playing, so pause it
//         _controller!.pause();

//         // Immediately update state
//         setState(() {
//           _isPlaying = false;
//           _isPaused = true;
//           _currentPlayerState = PlayerState.paused;
//         });
//       } else {
//         // Video is not playing, so play it
//         _controller!.play();

//         // Immediately update state
//         setState(() {
//           _isPlaying = true;
//           _isPaused = false;
//           _currentPlayerState = PlayerState.playing;
//           // Mark that video has started playing when manually played with delay
//           if (_currentPosition.inSeconds > 0) {
//             _startTextColorDelayTimer();
//           }
//         });

//         // Additional verification after a short delay
//         Future.delayed(const Duration(milliseconds: 300), () {
//           if (_controller != null && mounted && !_isDisposed) {
//             final verifyPlaying = _controller!.value.isPlaying;

//             if (!verifyPlaying) {
//               // If still not playing, try again
//               _controller!.play();
//             }
//           }
//         });
//       }
//     }
//   }

//   // Enhanced Seeking with Play State Preservation
//   void _seekVideo(bool forward) {
//     if (_controller != null &&
//         _isPlayerReady &&
//         _totalDuration.inSeconds > 24 &&
//         !_isDisposed) {
//       // Remember playing state before seeking
//       _wasPlayingBeforeSeek = _isPlaying;

//       final adjustedEndTime = _totalDuration.inSeconds - 12;
//       final seekAmount = (adjustedEndTime / 200).round().clamp(5, 30);

//       _seekTimer?.cancel();

//       if (forward) {
//         _pendingSeekSeconds += seekAmount;
//       } else {
//         _pendingSeekSeconds -= seekAmount;
//       }

//       final currentSeconds = _currentPosition.inSeconds;
//       final targetSeconds =
//           (currentSeconds + _pendingSeekSeconds).clamp(0, adjustedEndTime);
//       _targetSeekPosition = Duration(seconds: targetSeconds);

//       if (mounted && !_isDisposed) {
//         setState(() {
//           _isSeeking = true;
//         });
//       }

//       _seekTimer = Timer(const Duration(milliseconds: 1000), () {
//         _executeSeek();
//       });
//     }
//   }

//   void _executeSeek() {
//     if (_controller != null &&
//         _isPlayerReady &&
//         !_isDisposed &&
//         _pendingSeekSeconds != 0) {
//       final adjustedEndTime = _totalDuration.inSeconds - 12;
//       final currentSeconds = _currentPosition.inSeconds;
//       final newPosition =
//           (currentSeconds + _pendingSeekSeconds).clamp(0, adjustedEndTime);

//       _controller!.seekTo(Duration(seconds: newPosition));

//       // Restore playing state after seek
//       Future.delayed(const Duration(milliseconds: 300), () {
//         if (_controller != null && !_isDisposed) {
//           if (_wasPlayingBeforeSeek) {
//             _controller!.play();
//             setState(() {
//               _isPlaying = true;
//               _isPaused = false;
//               _currentPlayerState = PlayerState.playing;
//             });
//           }
//         }
//       });

//       _pendingSeekSeconds = 0;
//       _targetSeekPosition = Duration.zero;

//       if (mounted && !_isDisposed) {
//         setState(() {
//           _isSeeking = false;
//         });
//       }
//     }
//   }

//   // Method to start the delay timer for text color change
//   void _startTextColorDelayTimer() {
//     // Cancel any existing timer
//     _textColorDelayTimer?.cancel();

//     // Start new timer with 2 second delay
//     _textColorDelayTimer = Timer(const Duration(seconds: 5), () {
//       if (mounted && !_isDisposed) {
//         setState(() {
//           _hasVideoStartedPlaying = true;
//         });
//       }
//     });
//   }

//   bool _handleKeyEvent(RawKeyEvent event) {
//     if (_isDisposed) return false;

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
//           if (!_isDisposed) {
//             Navigator.of(context).pop();
//           }
//           return true;
//         default:
//           break;
//       }
//     }
//     return false;
//   }

//   Future<bool> _onWillPop() async {
//     if (_isDisposed || _isNavigating) return true;

//     try {
//       _isNavigating = true;
//       _isDisposed = true;

//       _seekTimer?.cancel();
//       _dateTimeTimer?.cancel();
//       _stateVerificationTimer?.cancel();
//       _textColorDelayTimer?.cancel();
//       _completionCheckTimer?.cancel();
//       _scrollController.dispose();

//       if (_controller != null) {
//         try {
//           if (_controller!.value.isPlaying) {
//             _controller!.pause();
//           }
//           _controller!.dispose();
//           _controller = null;
//         } catch (e) {
//           // Handle dispose error silently
//         }
//       }

//       try {
//         await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//             overlays: SystemUiOverlay.values);
//         await SystemChrome.setPreferredOrientations([
//           DeviceOrientation.portraitUp,
//           DeviceOrientation.portraitDown,
//           DeviceOrientation.landscapeLeft,
//           DeviceOrientation.landscapeRight,
//         ]);
//       } catch (e) {
//         // Handle system UI error silently
//       }

//       return true;
//     } catch (e) {
//       return true;
//     }
//   }

//   @override
//   void dispose() {
//     try {
//       _isDisposed = true;
//       _seekTimer?.cancel();
//       _dateTimeTimer?.cancel();
//       _stateVerificationTimer?.cancel();
//       _textColorDelayTimer?.cancel();
//       _completionCheckTimer?.cancel();
//       _scrollController.dispose();

//       if (_mainFocusNode.hasListeners) {
//         _mainFocusNode.dispose();
//       }

//       if (_controller != null) {
//         try {
//           _controller!.pause();
//           _controller!.dispose();
//           _controller = null;
//         } catch (e) {
//           // Handle dispose error silently
//         }
//       }

//       try {
//         SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//             overlays: SystemUiOverlay.values);
//         SystemChrome.setPreferredOrientations([
//           DeviceOrientation.portraitUp,
//           DeviceOrientation.portraitDown,
//           DeviceOrientation.landscapeLeft,
//           DeviceOrientation.landscapeRight,
//         ]);
//       } catch (e) {
//         // Handle system UI error silently
//       }
//     } catch (e) {
//       // Handle any dispose error silently
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
//             child: Stack(
//               children: [
//                 // Full screen video player
//                 _buildVideoPlayer(),
//                 // Top/Bottom Black Bars with Progress Bar
//                 _buildTopBottomBlackBars(),
//                 // Date display below top bar
//                 _buildDateDisplay(),
//                 // Custom Loading Overlay - Only show when controller is null
//                 if (_controller == null) _buildCustomLoadingOverlay(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDateDisplay() {
//     return Positioned(
//       top: screenhgt * 0.07,
//       left: 0,
//       right: 0,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Left side - Date with minimal background
//           Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: screenwdt * 0.03,
//               vertical: screenhgt * 0.001,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.black,
//               borderRadius: BorderRadius.circular(5),
//             ),
//             child: Text(
//               _currentDate,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           // Right side - Time with minimal background
//           Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: screenwdt * 0.03,
//               vertical: screenhgt * 0.001,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.black,
//               borderRadius: BorderRadius.circular(5),
//             ),
//             child: Text(
//               _currentTime,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTopBottomBlackBars() {
//     return Stack(
//       children: [
//         // Top Black Bar with Scrolling Name
//         Positioned(
//           top: 0,
//           left: 0,
//           right: 0,
//           height: screenhgt * 0.08,
//           child: Container(
//             alignment: Alignment.center,
//             color: Colors.black,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(
//                   height: screenhgt * 0.03,
//                 ),
//                 Text(
//                   'YOU ARE WATCHING RIGHT NOW : ${(widget.name?.toUpperCase() ?? '')}',
//                   style: TextStyle(
//                     // Dynamic color: black initially, white when video starts playing
//                     color: _hasVideoStartedPlaying ? Colors.white : Colors.black,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ),

//         // Bottom Black Bar with Progress Bar
//         Positioned(
//           bottom: 0,
//           left: screenwdt * 0.7,
//           right: 0,
//           height: screenhgt * 0.1,
//           child: Container(
//             color: Colors.black,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 40),
//                   child: Column(
//                     children: [
//                       // Progress Bar
//                       Container(
//                         height: 6,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(3),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(3),
//                           child: Stack(
//                             children: [
//                               Container(
//                                 width: double.infinity,
//                                 height: 6,
//                                 color: Colors.white.withOpacity(0.3),
//                               ),
//                               if (_totalDuration.inSeconds > 0)
//                                 FractionallySizedBox(
//                                   widthFactor: _currentPosition.inSeconds /
//                                       (_totalDuration.inSeconds - 12)
//                                           .clamp(1, double.infinity),
//                                   child: Container(
//                                     height: 6,
//                                     color: Colors.red,
//                                   ),
//                                 ),
//                               if (_isSeeking && _totalDuration.inSeconds > 0)
//                                 FractionallySizedBox(
//                                   widthFactor: _targetSeekPosition.inSeconds /
//                                       (_totalDuration.inSeconds - 12)
//                                           .clamp(1, double.infinity),
//                                   child: Container(
//                                     height: 6,
//                                     color: Colors.yellow.withOpacity(0.8),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ),

//                       // Time Display
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             _isSeeking
//                                 ? _formatDuration(_targetSeekPosition)
//                                 : _formatDuration(_currentPosition),
//                             style: TextStyle(
//                               color: _isSeeking ? Colors.yellow : Colors.white,
//                               fontSize: 12,
//                               fontWeight: _isSeeking
//                                   ? FontWeight.bold
//                                   : FontWeight.normal,
//                             ),
//                           ),
//                           Text(
//                             _formatDuration(Duration(
//                                 seconds: (_totalDuration.inSeconds - 12)
//                                     .clamp(0, double.infinity)
//                                     .toInt())),
//                             style: const TextStyle(
//                                 color: Colors.white, fontSize: 12),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }





//   // Widget _buildVideoPlayer() {
//   //   if (_error != null) {
//   //     return Container(
//   //       color: Colors.black,
//   //       child: Center(
//   //         child: Column(
//   //           mainAxisAlignment: MainAxisAlignment.center,
//   //           children: [
//   //             const Icon(Icons.error, color: Colors.red, size: 48),
//   //             const SizedBox(height: 16),
//   //             Text(_error!, style: const TextStyle(color: Colors.white)),
//   //             const SizedBox(height: 16),
//   //             ElevatedButton(
//   //               onPressed: () {
//   //                 if (!_isDisposed && mounted) {
//   //                   setState(() {
//   //                     _isLoading = true;
//   //                     _error = null;
//   //                     _isPlayerReady = false;
//   //                     _isPlaying = false;
//   //                     _hasVideoStartedPlaying = false; // Reset when retrying
//   //                     _textColorDelayTimer?.cancel(); // Cancel any existing timer
//   //                   });
//   //                   _controller?.dispose();
//   //                   _initializePlayer();
//   //                 }
//   //               },
//   //               child: const Text('Retry'),
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //     );
//   //   }

//   //   // Use multiple conditions to determine if pause overlay should show
//   //   final bool shouldShowPauseOverlay = _isPlayerReady &&
//   //       !_isLoading &&
//   //       (_isPaused ||
//   //           _currentPlayerState == PlayerState.paused ||
//   //           _getAccuratePauseState());

//   //   return Container(
//   //     width: screenwdt,
//   //     height: screenhgt,
//   //     color: Colors.black,
//   //     child: Stack(
//   //       children: [
//   //         // YouTube Player with loading overlay on top of thumbnail
//   //         if (_controller != null)
//   //           LayoutBuilder(
//   //             builder: (context, constraints) {
//   //               return Stack(
//   //                 children: [
//   //                   YoutubePlayer(
//   //                     controller: _controller!,
//   //                     showVideoProgressIndicator: false,
//   //                     progressIndicatorColor: Colors.red,
//   //                     bufferIndicator:
//   //                         Container(), // Empty buffer indicator to remove loading
//   //                     // width: screenwdt,
//   //                     // aspectRatio: 16 / 9,
//   //                     // aspectRatio: constraints.maxWidth / constraints.maxHeight,
//   //                     aspectRatio: screenwdt / screenhgt,
//   //                     bottomActions: [], // Remove bottom controls
//   //                     topActions: [], // Remove top controls
//   //                     onReady: () {
//   //                       if (!_isPlayerReady && !_isDisposed) {
//   //                         if (mounted) {
//   //                           setState(() {
//   //                             _isPlayerReady = true;
//   //                             _isLoading = false;
//   //                           });
//   //                         }

//   //                         Future.delayed(const Duration(milliseconds: 500), () {
//   //                           if (!_isDisposed) {
//   //                             _mainFocusNode.requestFocus();
//   //                           }
//   //                         });

//   //                         Future.delayed(const Duration(milliseconds: 100), () {
//   //                           if (_controller != null && mounted && !_isDisposed) {
//   //                             _controller!.play();
//   //                           }
//   //                         });
//   //                       }
//   //                     },
//   //                     onEnded: (_) {
//   //                       print('onEnded callback triggered');
//   //                       if (_isDisposed || _isNavigating || _videoCompleted) return;
//   //                       _completeVideo();
//   //                     },
//   //                   ),
//   //                 ],
//   //               );
//   //             },
//   //           ),

//   //               // Loading indicator over thumbnail when video is loading
//   //               if (_isLoading || !_isPlayerReady)
//   //                 Positioned.fill(
//   //                   child: Container(
//   //                     color: Colors.black.withOpacity(0.7),
//   //                     child: const Center(
//   //                       child: Column(
//   //                         mainAxisAlignment: MainAxisAlignment.center,
//   //                         children: [
//   //                           CircularProgressIndicator(
//   //                             color: Colors.red,
//   //                             strokeWidth: 6,
//   //                           ),
//   //                           SizedBox(height: 20),
//   //                           Text(
//   //                             'Loading Video...',
//   //                             style: TextStyle(
//   //                               color: Colors.white,
//   //                               fontSize: 18,
//   //                               fontWeight: FontWeight.bold,
//   //                             ),
//   //                           ),
//   //                         ],
//   //                       ),
//   //                     ),
//   //                   ),
//   //                 ),
//   //             ],
//   //           ),

//   //         // // Show pause overlay with enhanced condition
//   //         // if (shouldShowPauseOverlay)
//   //         //   Positioned.fill(
//   //         //     child: Container(
//   //         //       color: Colors.black.withOpacity(0.9),
//   //         //       child: Image.asset(
//   //         //         'assets/playpauseImage.gif',
//   //         //         width: double.infinity,
//   //         //         height: double.infinity,
//   //         //         fit: BoxFit.cover,
//   //         //         errorBuilder: (context, error, stackTrace) {
//   //         //           return Container(
//   //         //             color: Colors.black,
//   //         //             child: const Center(
//   //         //               child: Column(
//   //         //                 mainAxisAlignment: MainAxisAlignment.center,
//   //         //                 children: [
//   //         //                   Icon(
//   //         //                     Icons.play_circle_filled,
//   //         //                     size: 120,
//   //         //                     color: Colors.white,
//   //         //                   ),
//   //         //                   SizedBox(height: 20),
//   //         //                   Text(
//   //         //                     'Press ENTER to play',
//   //         //                     style: TextStyle(
//   //         //                       color: Colors.white,
//   //         //                       fontSize: 20,
//   //         //                       fontWeight: FontWeight.bold,
//   //         //                     ),
//   //         //                   ),
//   //         //                 ],
//   //         //               ),
//   //         //             ),
//   //         //           );
//   //         //         },
//   //         //       ),
//   //         //     ),
//   //         //   ),
//   //       // ],
//   //     // ),
//   //   );
//   // }



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
//                       _isPlayerReady = false;
//                       _isPlaying = false;
//                       _hasVideoStartedPlaying = false;
//                       _textColorDelayTimer?.cancel();
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

//     // Different width options - Choose one:
    
//     // Option 1: 90% of screen width (10% kam)
//     // double videoWidthMultiplier = 0.90;
    
//     // Option 2: 95% of screen width (5% kam) - Recommended
//     double videoWidthMultiplier = 0.95;
    
//     // Option 3: 85% of screen width (15% kam) - More padding
//     // double videoWidthMultiplier = 0.85;
    
//     // Option 4: Fixed padding from sides (20 pixels each side)
//     // double effectiveVideoWidth = screenwdt - 40;
    
//     // Calculate video dimensions
//     double effectiveVideoWidth = screenwdt * videoWidthMultiplier;
//     double effectiveVideoHeight = effectiveVideoWidth * 9 / 16;

//     return Container(
//       width: screenwdt,
//       height: screenhgt,
//       color: Colors.black,
//       child: Stack(
//         children: [
//           // YouTube Player - Customizable Width
//           if (_controller != null)
//             Center(
//               child: Container(
//                 width: effectiveVideoWidth,
//                 height: effectiveVideoHeight,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12), // Rounded corners
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.3),
//                       blurRadius: 10,
//                       spreadRadius: 2,
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: YoutubePlayer(
//                     controller: _controller!,
//                     showVideoProgressIndicator: false,
//                     progressIndicatorColor: Colors.red,
//                     bufferIndicator: Container(),
//                     bottomActions: [],
//                     topActions: [],
//                     aspectRatio: 16 / 9,
                    
//                     onReady: () {
//                       if (!_isPlayerReady && !_isDisposed) {
//                         if (mounted) {
//                           setState(() {
//                             _isPlayerReady = true;
//                             _isLoading = false;
//                           });
//                         }

//                         Future.delayed(const Duration(milliseconds: 500), () {
//                           if (!_isDisposed) {
//                             _mainFocusNode.requestFocus();
//                           }
//                         });

//                         Future.delayed(const Duration(milliseconds: 100), () {
//                           if (_controller != null && mounted && !_isDisposed) {
//                             _controller!.play();
//                           }
//                         });
//                       }
//                     },
                    
//                     onEnded: (_) {
//                       print('onEnded callback triggered');
//                       if (_isDisposed || _isNavigating || _videoCompleted) return;
//                       _completeVideo();
//                     },
//                   ),
//                 ),
//               ),
//             ),

//           // Loading indicator
//           if (_isLoading || !_isPlayerReady)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black.withOpacity(0.7),
//                 child: const Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(
//                         color: Colors.red,
//                         strokeWidth: 6,
//                       ),
//                       SizedBox(height: 20),
//                       Text(
//                         'Loading Video...',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   // Simple loading overlay for when controller is null
//   Widget _buildCustomLoadingOverlay() {
//     return Positioned.fill(
//       child: Container(
//         width: screenwdt,
//         height: screenhgt,
//         color: Colors.black,
//         child: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(
//                 color: Colors.white,
//                 strokeWidth: 6,
//               ),
//               // SizedBox(height: 20),
//               // Text(
//               //   'Initializing Player...',
//               //   style: TextStyle(
//               //     color: Colors.white,
//               //     fontSize: 18,
//               //     fontWeight: FontWeight.bold,
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// class CustomYoutubePlayer extends StatefulWidget {
//   final String videoUrl;
//   final String? name;

//   const CustomYoutubePlayer({
//     Key? key,
//     required this.videoUrl,
//     required this.name,
//   }) : super(key: key);

//   @override
//   _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
// }

// enum PlayerState { unknown, unstarted, ended, playing, paused, buffering, cued }

// class _CustomYoutubePlayerState extends State<CustomYoutubePlayer>
//     with TickerProviderStateMixin {
//   VlcPlayerController? _vlcPlayerController;
//   bool _isLoading = true; // Initially loading state
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     // Auto-play the video when widget initializes
//     _playYouTubeVideo(widget.videoUrl);
//   }

//   Future<void> _playYouTubeVideo(String youtubeUrl) async {
//     if (youtubeUrl.isEmpty) {
//       _showError('Invalid YouTube URL');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     final yt = YoutubeExplode();

//     try {
//       // Parse video ID with proper error handling
//       final videoIdString = VideoId.parseVideoId(youtubeUrl);
//       if (videoIdString == null) {
//         throw Exception('Invalid YouTube URL format - could not extract video ID');
//       }
      
//       final videoId = VideoId(videoIdString);
      
//       print('Processing video ID: $videoIdString');

//       // Get video manifest
//       final manifest = await yt.videos.streamsClient.getManifest(videoId);
      
//       print('Available streams:');
//       print('Muxed streams: ${manifest.muxed.length}');
//       print('Video-only streams: ${manifest.videoOnly.length}');
//       print('Audio-only streams: ${manifest.audioOnly.length}');
      
//       // Strategy: Prioritize muxed streams with audio support
//       String? streamUrl;
      
//       if (manifest.muxed.isNotEmpty) {
//         // Sort muxed streams by quality and try to find one with good audio
//         final muxedStreams = manifest.muxed.toList();
        
//         // Print all available muxed streams
//         print('Available muxed streams:');
//         for (var stream in muxedStreams) {
//           print('Quality: ${stream.videoQualityLabel}, Container: ${stream.container}, Bitrate: ${stream.bitrate}');
//         }
        
//         // Try to find 360p or 480p streams first (they usually have audio)
//         var preferredStream = muxedStreams.where((s) => 
//           s.videoQualityLabel == '360p' || s.videoQualityLabel == '480p'
//         ).firstOrNull;
        
//         // If no preferred quality found, use the lowest quality available
//         if (preferredStream == null) {
//           preferredStream = muxedStreams.first; // Lowest quality for audio compatibility
//         }
        
//         streamUrl = preferredStream.url.toString();
//         print('Selected muxed stream: ${preferredStream.videoQualityLabel} - ${preferredStream.container}');
//       } 
//       // If no muxed streams, try adaptive streams (but warn about audio)
//       else if (manifest.videoOnly.isNotEmpty) {
//         print('No muxed streams available - trying video-only (audio may not work)');
        
//         // Try to get a medium quality video stream
//         final videoStreams = manifest.videoOnly.toList();
//         var selectedStream = videoStreams.where((s) => 
//           s.videoQualityLabel == '480p' || s.videoQualityLabel == '360p'
//         ).firstOrNull ?? videoStreams.first;
        
//         streamUrl = selectedStream.url.toString();
//         print('Using video-only stream: ${selectedStream.videoQualityLabel}');
        
//         // Show audio warning
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('⚠️ Audio not available - This video uses separate audio/video streams'),
//               backgroundColor: Colors.orange,
//               duration: Duration(seconds: 4),
//             ),
//           );
//         }
//       }
//       else {
//         throw Exception('No playable streams found for this video');
//       }
      
//       if (streamUrl == null || streamUrl.isEmpty) {
//         throw Exception('Could not extract valid stream URL');
//       }
      
//       print('Final stream URL: ${streamUrl.substring(0, 100)}...');

//       // Dispose previous controller safely
//       await _vlcPlayerController?.dispose();
      
//       // Create VLC controller with audio-optimized settings
//       _vlcPlayerController = VlcPlayerController.network(
//         streamUrl,
//         autoPlay: true,
//         hwAcc: HwAcc.auto,
//         options: VlcPlayerOptions(
//           advanced: VlcAdvancedOptions([
//             VlcAdvancedOptions.networkCaching(2000),
//           ]),
//           audio: VlcAudioOptions([
//             VlcAudioOptions.audioTimeStretch(true),
//           ]),
//           extras: [
//             '--audio-visual=none', // Disable audio visualization
//             '--no-video-title-show', // Don't show video title
//             '--network-caching=2000', // Network caching
//           ],
//         ),
//       );

//       // Add listener for player events
//       _vlcPlayerController?.addListener(_playerListener);

//       setState(() => _isLoading = false);
      
//     } catch (e) {
//       print('Error loading video: $e');
//       _showError('Failed to load video: ${e.toString()}');
//     } finally {
//       yt.close();
//     }
//   }

//   void _playerListener() {
//     if (_vlcPlayerController != null) {
//       // Handle player state changes here if needed
//       final isPlaying = _vlcPlayerController!.value.isPlaying;
//       final hasError = _vlcPlayerController!.value.hasError;
      
//       if (hasError) {
//         _showError('Video playback error occurred');
//       }
//     }
//   }

//   void _showError(String message) {
//     setState(() {
//       _isLoading = false;
//       _errorMessage = message;
//     });
    
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: Duration(seconds: 3),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _vlcPlayerController?.removeListener(_playerListener);
//     _vlcPlayerController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           children: [
//             // // Show video name if provided
//             // if (widget.name != null)
//             //   Container(
//             //     width: double.infinity,
//             //     padding: EdgeInsets.all(16),
//             //     child: Text(
//             //       widget.name!,
//             //       style: TextStyle(
//             //         fontSize: 18,
//             //         fontWeight: FontWeight.bold,
//             //       ),
//             //       textAlign: TextAlign.center,
//             //     ),
//             //   ),
            
//             // // Error Message
//             // if (_errorMessage != null)
//             //   Container(
//             //     width: double.infinity,
//             //     padding: EdgeInsets.all(12),
//             //     margin: EdgeInsets.only(bottom: 10),
//             //     decoration: BoxDecoration(
//             //       color: Colors.red.shade50,
//             //       border: Border.all(color: Colors.red.shade200),
//             //       borderRadius: BorderRadius.circular(8),
//             //     ),
//             //     child: Text(
//             //       _errorMessage!,
//             //       style: TextStyle(color: Colors.red.shade700),
//             //     ),
//             //   ),
            
//             // Video Player
//             Expanded(
//               child: _isLoading
//                   ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CircularProgressIndicator(color: Colors.red),
//                           SizedBox(height: 16),
//                           Text('Loading video...'),
//                         ],
//                       ),
//                     )
//                   : _vlcPlayerController != null && _errorMessage == null
//                       ? Container(
//                           decoration: BoxDecoration(
//                             color: Colors.black,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             child: VlcPlayer(
//                               controller: _vlcPlayerController!,
//                               aspectRatio: 16 / 9,
//                               placeholder: Center(
//                                 child: CircularProgressIndicator(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                         )
//                       : Container(
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade200,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.error_outline, size: 64, color: Colors.grey),
//                                 SizedBox(height: 16),
//                                 Text(
//                                   'Failed to load video',
//                                   style: TextStyle(color: Colors.grey.shade600),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




// import 'package:youtube_explode_dart/youtube_explode_dart.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:flutter/material.dart';

// class CustomYoutubePlayer extends StatefulWidget {
//   final String videoUrl;
//   final String? name;

//   const CustomYoutubePlayer({
//     Key? key,
//     required this.videoUrl,
//     required this.name,
//   }) : super(key: key);

//   @override
//   _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
// }

// enum PlayerState { unknown, unstarted, ended, playing, paused, buffering, cued }

// class _CustomYoutubePlayerState extends State<CustomYoutubePlayer>
//     with TickerProviderStateMixin {
//   VlcPlayerController? _videoController;
//   VlcPlayerController? _audioController;
//   final YoutubeExplode _youtubeExplode = YoutubeExplode();
  
//   bool _isPlaying = false;
//   bool _isInitialized = false;
//   bool _isInitializing = false;
//   Duration _currentPosition = Duration.zero;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _initializePlayers();
//   }

//   Future<void> _initializePlayers() async {
//     if (_isInitializing) return;
    
//     setState(() {
//       _isInitializing = true;
//       _errorMessage = null;
//     });

//     try {
//       var manifest = await _youtubeExplode.videos.streamsClient
//           .getManifest(widget.videoUrl);
      
//       // Get video-only stream (first available)
//       var videoOnlyStreams = manifest.videoOnly;
//       VideoOnlyStreamInfo? videoStream;
//       if (videoOnlyStreams.isNotEmpty) {
//         videoStream = videoOnlyStreams.first;
//       }
      
//       // Get audio-only stream (first available)
//       var audioOnlyStreams = manifest.audioOnly;
//       AudioOnlyStreamInfo? audioStream;
//       if (audioOnlyStreams.isNotEmpty) {
//         audioStream = audioOnlyStreams.first;
//       }
      
//       if (videoStream != null && audioStream != null) {
//         // Video player (muted)
//         _videoController = VlcPlayerController.network(
//           videoStream.url.toString(),
//           hwAcc: HwAcc.auto,
//           autoPlay: false,
//           options: VlcPlayerOptions(
//             audio: VlcAudioOptions([
//               '--no-audio',
//             ]),
//           ),
//         );
        
//         // Audio player (hidden)
//         _audioController = VlcPlayerController.network(
//           audioStream.url.toString(),
//           hwAcc: HwAcc.auto,
//           autoPlay: false,
//           options: VlcPlayerOptions(
//             video: VlcVideoOptions([
//               '--no-video',
//             ]),
//           ),
//         );
        
//         // Wait for controllers to be ready
//         await Future.delayed(Duration(seconds: 2));
        
//         // Check if controllers are actually initialized
//         if (_videoController != null && _audioController != null) {
//           // Try to initialize explicitly
//           try {
//             await _videoController!.initialize();
//             await _audioController!.initialize();
            
//             // Wait a bit more for VLC to be ready
//             await Future.delayed(Duration(seconds: 1));
            
//             setState(() {
//               _isInitialized = true;
//               _isInitializing = false;
//             });
            
//             // Start sync only after successful initialization
//             _setupSyncListeners();
//           } catch (initError) {
//             print('Controller initialization error: $initError');
//             setState(() {
//               _errorMessage = 'Failed to initialize video players';
//               _isInitializing = false;
//             });
//           }
//         }
//       } else {
//         setState(() {
//           _errorMessage = 'No video or audio streams found';
//           _isInitializing = false;
//         });
//       }
//     } catch (e) {
//       print('Error initializing players: $e');
//       setState(() {
//         _errorMessage = 'Error loading video: ${e.toString()}';
//         _isInitializing = false;
//       });
//     }
//   }

//   void _setupSyncListeners() {
//     // Only setup sync if properly initialized
//     if (!_isInitialized || _videoController == null || _audioController == null) {
//       return;
//     }

//     // Start sync after a longer delay to ensure controllers are ready
//     Future.delayed(Duration(seconds: 3), () {
//       if (mounted && _isInitialized && _videoController != null && _audioController != null) {
//         // Check every 2 seconds instead of every second
//         Stream.periodic(Duration(seconds: 2)).listen((_) async {
//           if (mounted && _isInitialized && _videoController != null && _audioController != null) {
//             try {
//               // Check if controllers are initialized before calling getPosition
//               if (_videoController!.value.isInitialized && _audioController!.value.isInitialized) {
//                 final videoPosition = await _videoController!.getPosition();
//                 final audioPosition = await _audioController!.getPosition();
                
//                 // If positions are out of sync by more than 1 second, sync them
//                 final diff = (videoPosition.inMilliseconds - audioPosition.inMilliseconds).abs();
//                 if (diff > 1000) {
//                   await _audioController!.seekTo(videoPosition);
//                 }
                
//                 if (mounted) {
//                   setState(() {
//                     _currentPosition = videoPosition;
//                   });
//                 }
//               }
//             } catch (e) {
//               // Don't log sync errors too frequently
//               // print('Sync error: $e');
//             }
//           }
//         });
//       }
//     });
//   }

//   Future<void> _playBoth() async {
//     if (!_isInitialized || _videoController == null || _audioController == null) {
//       return;
//     }

//     try {
//       // Check if controllers are initialized before playing
//       if (_videoController!.value.isInitialized && _audioController!.value.isInitialized) {
//         await Future.wait([
//           _videoController!.play(),
//           _audioController!.play(),
//         ]);
//         setState(() => _isPlaying = true);
//       }
//     } catch (e) {
//       print('Error playing: $e');
//     }
//   }

//   Future<void> _pauseBoth() async {
//     if (!_isInitialized || _videoController == null || _audioController == null) {
//       return;
//     }

//     try {
//       if (_videoController!.value.isInitialized && _audioController!.value.isInitialized) {
//         await Future.wait([
//           _videoController!.pause(),
//           _audioController!.pause(),
//         ]);
//         setState(() => _isPlaying = false);
//       }
//     } catch (e) {
//       print('Error pausing: $e');
//     }
//   }

//   Future<void> _seekBoth(Duration position) async {
//     if (!_isInitialized || _videoController == null || _audioController == null) {
//       return;
//     }

//     try {
//       if (_videoController!.value.isInitialized && _audioController!.value.isInitialized) {
//         await Future.wait([
//           _videoController!.seekTo(position),
//           _audioController!.seekTo(position),
//         ]);
//       }
//     } catch (e) {
//       print('Error seeking: $e');
//     }
//   }

//   Future<void> _stopBoth() async {
//     if (!_isInitialized || _videoController == null || _audioController == null) {
//       return;
//     }

//     try {
//       if (_videoController!.value.isInitialized && _audioController!.value.isInitialized) {
//         await Future.wait([
//           _videoController!.stop(),
//           _audioController!.stop(),
//         ]);
//         setState(() => _isPlaying = false);
//       }
//     } catch (e) {
//       print('Error stopping: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Show error if any
//     if (_errorMessage != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error, size: 48, color: Colors.red),
//             SizedBox(height: 16),
//             Text(
//               _errorMessage!,
//               style: TextStyle(color: Colors.red),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _errorMessage = null;
//                   _isInitialized = false;
//                   _isInitializing = false;
//                 });
//                 _initializePlayers();
//               },
//               child: Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     // Show loading if initializing or not initialized
//     if (_isInitializing || !_isInitialized) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text(_isInitializing ? 'Initializing video players...' : 'Loading YouTube video...'),
//           ],
//         ),
//       );
//     }

//     return Column(
//       children: [
//         // Video Info
//         if (widget.name != null)
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               widget.name!,
//               style: Theme.of(context).textTheme.titleMedium,
//               textAlign: TextAlign.center,
//             ),
//           ),
        
//         // Video player (visible)
//         Container(
//           height: 200,
//           decoration: BoxDecoration(
//             color: Colors.black,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: VlcPlayer(
//               controller: _videoController!,
//               aspectRatio: 16 / 9,
//               placeholder: const Center(
//                 child: Text(
//                   'Loading Video...',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//           ),
//         ),
        
//         // Audio player (hidden - केवल audio के लिए)
//         Container(
//           height: 0,
//           width: 0,
//           child: VlcPlayer(
//             controller: _audioController!,
//             aspectRatio: 1,
//           ),
//         ),
        
//         // Position indicator
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//           child: Text(
//             'Position: ${_formatDuration(_currentPosition)}',
//             style: Theme.of(context).textTheme.bodySmall,
//           ),
//         ),
        
//         // Controls
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               IconButton(
//                 onPressed: () => _seekBoth(Duration.zero),
//                 icon: const Icon(Icons.replay),
//                 tooltip: 'Restart',
//               ),
//               const SizedBox(width: 16),
//               IconButton(
//                 onPressed: _isPlaying ? _pauseBoth : _playBoth,
//                 icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
//                 iconSize: 32,
//                 tooltip: _isPlaying ? 'Pause' : 'Play',
//               ),
//               const SizedBox(width: 16),
//               IconButton(
//                 onPressed: _stopBoth,
//                 icon: const Icon(Icons.stop),
//                 tooltip: 'Stop',
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//   }

//   @override
//   void dispose() {
//     _videoController?.dispose();
//     _audioController?.dispose();
//     _youtubeExplode.close();
//     super.dispose();
//   }
// }



// class CustomYoutubePlayer extends StatefulWidget {
//   final String videoUrl;
//   final String name;
  
//   const CustomYoutubePlayer({
//     Key? key,
//     required this.videoUrl,
//     required this.name,
//   }) : super(key: key);

//   @override
//   _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
// }

// class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
//   VlcPlayerController? _controller;
//   final YoutubeExplode _youtubeExplode = YoutubeExplode();

//   @override
//   void initState() {
//     super.initState();
//     _initializePlayer();
//   }

//   Future<void> _initializePlayer() async {
//     try {
//       var manifest = await _youtubeExplode.videos.streamsClient
//           .getManifest(widget.videoUrl);
      
//       var audioStream = manifest.audioOnly.withHighestBitrate();
      
//       if (audioStream != null) {
//         _controller = VlcPlayerController.network(
//           audioStream.url.toString(),
//           hwAcc: HwAcc.full,
//           autoPlay: false,
//         );
//         setState(() {});
//       }
//     } catch (e) {
//       print('Error initializing player: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_controller == null) {
//       return Center(child: CircularProgressIndicator());
//     }

//     return Column(
//       children: [
//         Container(
//           height: 200,
//           child: VlcPlayer(
//             controller: _controller!,
//             aspectRatio: 16 / 9,
//             placeholder: Center(child: Text('Audio Player')),
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             IconButton(
//               onPressed: () => _controller!.play(),
//               icon: Icon(Icons.play_arrow),
//             ),
//             IconButton(
//               onPressed: () => _controller!.pause(),
//               icon: Icon(Icons.pause),
//             ),
//             IconButton(
//               onPressed: () => _controller!.stop(),
//               icon: Icon(Icons.stop),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     _youtubeExplode.close();
//     super.dispose();
//   }
// }




// #############################################################################
// ############################################################################



// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:youtube_explode_dart/youtube_explode_dart.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:flutter/material.dart';

// class CustomYoutubePlayer extends StatefulWidget {
//   final String videoUrl;
//   final String? name;

//   const CustomYoutubePlayer({
//     Key? key,
//     required this.videoUrl,
//     required this.name,
//   }) : super(key: key);

//   @override
//   _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
// }

// enum PlayerState { unknown, unstarted, ended, playing, paused, buffering, cued }

// class _CustomYoutubePlayerState extends State<CustomYoutubePlayer>
//     with TickerProviderStateMixin {
//   VlcPlayerController? _videoController;
//   VlcPlayerController? _audioController;
//   final YoutubeExplode _youtubeExplode = YoutubeExplode();
  
//   bool _isPlaying = false;
//   bool _isInitialized = false;
//   bool _isInitializing = false;
//   bool _controllersCreated = false;
//   Duration _currentPosition = Duration.zero;
//   String? _errorMessage;
//   String? _videoUrl;
//   String? _audioUrl;

//   @override
//   void initState() {
//     super.initState();
//     _loadStreamUrls();
//   }

//   Future<void> _loadStreamUrls() async {
//     if (_isInitializing) return;
    
//     if (!mounted) return;
    
//     setState(() {
//       _isInitializing = true;
//       _errorMessage = null;
//     });

//     try {
//       // Validate the video URL first
//       if (widget.videoUrl.isEmpty) {
//         throw Exception('Video URL is empty');
//       }

//       print('Loading streams for: ${widget.videoUrl}');
      
//       // Try to get manifest with better error handling
//       StreamManifest? manifest;
//       try {
//         manifest = await _youtubeExplode.videos.streamsClient
//             .getManifest(widget.videoUrl);
//       } catch (manifestError) {
//         print('Manifest error: $manifestError');
//         throw Exception('Failed to get video manifest: $manifestError');
//       }
      
//       if (manifest == null) {
//         throw Exception('Could not get video manifest - manifest is null');
//       }
      
//       print('Manifest loaded successfully');
      
//       // Get video-only streams with null safety
//       var videoOnlyStreams = manifest.videoOnly;
//       print('Found ${videoOnlyStreams?.length ?? 0} video-only streams');
      
//       VideoOnlyStreamInfo? videoStream;
//       if (videoOnlyStreams != null && videoOnlyStreams.isNotEmpty) {
//         videoStream = videoOnlyStreams.first;
//         print('Selected video stream: ${videoStream?.tag} - ${videoStream?.videoQuality}');
//       }
      
//       // Get audio-only streams with null safety
//       var audioOnlyStreams = manifest.audioOnly;
//       print('Found ${audioOnlyStreams?.length ?? 0} audio-only streams');
      
//       AudioOnlyStreamInfo? audioStream;
//       if (audioOnlyStreams != null && audioOnlyStreams.isNotEmpty) {
//         audioStream = audioOnlyStreams.first;
//         print('Selected audio stream: ${audioStream?.tag} - ${audioStream?.audioCodec}');
//       }
      
//       if (videoStream != null && audioStream != null) {
//         // Validate stream URLs with comprehensive null checks
//         String? videoUrl;
//         String? audioUrl;
        
//         try {
//           videoUrl = videoStream.url?.toString();
//           audioUrl = audioStream.url?.toString();
//         } catch (urlError) {
//           print('URL extraction error: $urlError');
//           throw Exception('Failed to extract stream URLs: $urlError');
//         }
        
//         if (videoUrl == null || videoUrl.isEmpty) {
//           throw Exception('Video stream URL is null or empty');
//         }
        
//         if (audioUrl == null || audioUrl.isEmpty) {
//           throw Exception('Audio stream URL is null or empty');
//         }

//         print('Video URL loaded: ${videoUrl.length > 50 ? videoUrl.substring(0, 50) + "..." : videoUrl}');
//         print('Audio URL loaded: ${audioUrl.length > 50 ? audioUrl.substring(0, 50) + "..." : audioUrl}');
        
//         // Store URLs and create controllers
//         _videoUrl = videoUrl;
//         _audioUrl = audioUrl;
        
//         if (mounted) {
//           setState(() {
//             _controllersCreated = true;
//             _isInitializing = false;
//           });
          
//           // Wait for the VLC widgets to be created and auto-initialized
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             Future.delayed(Duration(milliseconds: 3000), () {
//               if (mounted) {
//                 _waitForAutoInitialization();
//               }
//             });
//           });
//         }
//       } else {
//         String missingStreams = '';
//         if (videoStream == null) missingStreams += 'video ';
//         if (audioStream == null) missingStreams += 'audio ';
        
//         // Check if streams exist but are empty
//         if (videoOnlyStreams?.isEmpty == true) {
//           missingStreams += '(no video streams available) ';
//         }
//         if (audioOnlyStreams?.isEmpty == true) {
//           missingStreams += '(no audio streams available) ';
//         }
        
//         if (mounted) {
//           setState(() {
//             _errorMessage = 'No $missingStreams streams found for this video. This video might be restricted or unavailable.';
//             _isInitializing = false;
//           });
//         }
//       }
//     } catch (e) {
//       print('Error loading streams: $e');
//       print('Stack trace: ${StackTrace.current}');
      
//       String errorMessage = 'Error loading video: ${e.toString()}';
      
//       // Provide more specific error messages for common issues
//       if (e.toString().contains('VideoUnavailableException')) {
//         errorMessage = 'This video is unavailable or private';
//       } else if (e.toString().contains('VideoRequiresPurchaseException')) {
//         errorMessage = 'This video requires purchase';
//       } else if (e.toString().contains('SocketException')) {
//         errorMessage = 'Network error: Please check your internet connection';
//       } else if (e.toString().contains('TimeoutException')) {
//         errorMessage = 'Request timed out: Please try again';
//       }
      
//       if (mounted) {
//         setState(() {
//           _errorMessage = errorMessage;
//           _isInitializing = false;
//         });
//       }
//     }
//   }

//   void _createControllers() {
//     if (_videoUrl == null || _audioUrl == null) return;
    
//     try {
//       print('Creating controllers...');
      
//       // Create video controller with auto-initialization
//       _videoController = VlcPlayerController.network(
//         _videoUrl!,
//         hwAcc: HwAcc.auto,
//         autoPlay: false,
//         autoInitialize: true, // Let VLC handle initialization automatically
//         options: VlcPlayerOptions(
//           advanced: VlcAdvancedOptions([
//             VlcAdvancedOptions.networkCaching(2000),
//           ]),
//           audio: VlcAudioOptions([
//             '--no-audio',
//           ]),
//           // others: [
//           //   '--no-xlib',
//           // ],
//         ),
//       );
      
//       // Create audio controller with auto-initialization
//       _audioController = VlcPlayerController.network(
//         _audioUrl!,
//         hwAcc: HwAcc.auto,
//         autoPlay: false,
//         autoInitialize: true, // Let VLC handle initialization automatically
//         options: VlcPlayerOptions(
//           advanced: VlcAdvancedOptions([
//             VlcAdvancedOptions.networkCaching(2000),
//           ]),
//           video: VlcVideoOptions([
//             '--no-video',
//           ]),
//           // others: [
//           //   '--no-xlib',
//           // ],
//         ),
//       );

//       print('Controllers created successfully');
//     } catch (e) {
//       print('Error creating controllers: $e');
//       if (mounted) {
//         setState(() {
//           _errorMessage = 'Failed to create video players: $e';
//         });
//       }
//     }
//   }

//   Future<void> _waitForAutoInitialization() async {
//     if (!mounted || _videoController == null || _audioController == null) {
//       print('Cannot wait for initialization: widget not mounted or controllers null');
//       return;
//     }

//     try {
//       print('Waiting for auto-initialization of controllers...');
      
//       setState(() {
//         _isInitializing = true;
//         _errorMessage = null;
//       });

//       // Wait for auto-initialization to complete
//       int attempts = 0;
//       const maxAttempts = 30; // 30 seconds maximum wait
      
//       while (attempts < maxAttempts && mounted) {
//         final videoInitialized = _videoController?.value.isInitialized ?? false;
//         final audioInitialized = _audioController?.value.isInitialized ?? false;
        
//         print('Auto-initialization check $attempts: video=$videoInitialized, audio=$audioInitialized');
        
//         if (videoInitialized && audioInitialized) {
//           print('Both controllers auto-initialized successfully');
//           break;
//         }
        
//         await Future.delayed(Duration(seconds: 1));
//         attempts++;
//       }

//       if (mounted) {
//         // Final check
//         final videoInitialized = _videoController?.value.isInitialized ?? false;
//         final audioInitialized = _audioController?.value.isInitialized ?? false;
        
//         if (videoInitialized && audioInitialized) {
//           setState(() {
//             _isInitialized = true;
//             _isInitializing = false;
//           });

//           print('All controllers ready for playback');
//           _setupSyncListeners();
          
//           // Auto-play after initialization
//           Future.delayed(Duration(milliseconds: 1000), () {
//             if (mounted) {
//               print('Starting auto-play...');
//               _playBoth();
//             }
//           });
//         } else {
//           throw Exception('Controllers failed to auto-initialize: video=$videoInitialized, audio=$audioInitialized');
//         }
//       }

//     } catch (e) {
//       print('Auto-initialization wait error: $e');
//       if (mounted) {
//         setState(() {
//           _errorMessage = 'Failed to initialize video players: $e';
//           _isInitializing = false;
//           _isInitialized = false;
//         });
//       }
//     }
//   }

//   Future<void> _disposeControllers() async {
//     try {
//       if (_videoController != null) {
//         print('Disposing video controller...');
//         await _videoController?.dispose();
//         _videoController = null;
//         print('Video controller disposed');
//       }
//       if (_audioController != null) {
//         print('Disposing audio controller...');
//         await _audioController?.dispose();
//         _audioController = null;
//         print('Audio controller disposed');
//       }
//     } catch (e) {
//       print('Error disposing controllers: $e');
//       // Set to null anyway to prevent further issues
//       _videoController = null;
//       _audioController = null;
//     }
//   }

//   void _setupSyncListeners() {
//     // Only setup sync if properly initialized
//     if (!_isInitialized || _videoController == null || _audioController == null) {
//       return;
//     }

//     // Start sync after a longer delay to ensure controllers are ready
//     Future.delayed(Duration(seconds: 2), () {
//       if (mounted && _isInitialized && _videoController != null && _audioController != null) {
//         // Check every 2 seconds instead of every second
//         Stream.periodic(Duration(seconds: 2)).listen((_) async {
//           if (mounted && _isInitialized && _videoController != null && _audioController != null) {
//             try {
//               // Check if controllers are initialized before calling getPosition
//               final videoInitialized = _videoController?.value.isInitialized ?? false;
//               final audioInitialized = _audioController?.value.isInitialized ?? false;
              
//               if (videoInitialized && audioInitialized) {
//                 final videoPosition = await _videoController?.getPosition() ?? Duration.zero;
//                 final audioPosition = await _audioController?.getPosition() ?? Duration.zero;
                
//                 // If positions are out of sync by more than 1 second, sync them
//                 final diff = (videoPosition.inMilliseconds - audioPosition.inMilliseconds).abs();
//                 if (diff > 1000) {
//                   await _audioController?.seekTo(videoPosition);
//                 }
                
//                 if (mounted) {
//                   setState(() {
//                     _currentPosition = videoPosition;
//                   });
//                 }
//               }
//             } catch (e) {
//               // Don't log sync errors too frequently
//               // print('Sync error: $e');
//             }
//           }
//         });
//       }
//     });
//   }

//   Future<void> _playBoth() async {
//     if (!_isInitialized || _videoController == null || _audioController == null) {
//       print('Cannot play: not initialized or controllers are null');
//       return;
//     }

//     try {
//       // Check if controllers are initialized before playing
//       final videoInitialized = _videoController?.value.isInitialized ?? false;
//       final audioInitialized = _audioController?.value.isInitialized ?? false;
      
//       if (videoInitialized && audioInitialized) {
//         print('Playing both controllers...');
//         await Future.wait([
//           _videoController?.play() ?? Future.value(),
//           _audioController?.play() ?? Future.value(),
//         ]);
//         if (mounted) {
//           setState(() => _isPlaying = true);
//         }
//         print('Both controllers playing');
//       } else {
//         print('Controllers not ready: video=$videoInitialized, audio=$audioInitialized');
//       }
//     } catch (e) {
//       print('Error playing: $e');
//     }
//   }

//   Future<void> _pauseBoth() async {
//     if (!_isInitialized || _videoController == null || _audioController == null) {
//       print('Cannot pause: not initialized or controllers are null');
//       return;
//     }

//     try {
//       final videoInitialized = _videoController?.value.isInitialized ?? false;
//       final audioInitialized = _audioController?.value.isInitialized ?? false;
      
//       if (videoInitialized && audioInitialized) {
//         print('Pausing both controllers...');
//         await Future.wait([
//           _videoController?.pause() ?? Future.value(),
//           _audioController?.pause() ?? Future.value(),
//         ]);
//         if (mounted) {
//           setState(() => _isPlaying = false);
//         }
//         print('Both controllers paused');
//       }
//     } catch (e) {
//       print('Error pausing: $e');
//     }
//   }

//   Future<void> _seekBoth(Duration position) async {
//     if (!_isInitialized || _videoController == null || _audioController == null) {
//       print('Cannot seek: not initialized or controllers are null');
//       return;
//     }

//     try {
//       final videoInitialized = _videoController?.value.isInitialized ?? false;
//       final audioInitialized = _audioController?.value.isInitialized ?? false;
      
//       if (videoInitialized && audioInitialized) {
//         print('Seeking both controllers to ${position.inSeconds}s...');
//         await Future.wait([
//           _videoController?.seekTo(position) ?? Future.value(),
//           _audioController?.seekTo(position) ?? Future.value(),
//         ]);
//         print('Both controllers seeked');
//       }
//     } catch (e) {
//       print('Error seeking: $e');
//     }
//   }

//   Future<void> _stopBoth() async {
//     if (!_isInitialized || _videoController == null || _audioController == null) {
//       print('Cannot stop: not initialized or controllers are null');
//       return;
//     }

//     try {
//       final videoInitialized = _videoController?.value.isInitialized ?? false;
//       final audioInitialized = _audioController?.value.isInitialized ?? false;
      
//       if (videoInitialized && audioInitialized) {
//         print('Stopping both controllers...');
//         await Future.wait([
//           _videoController?.stop() ?? Future.value(),
//           _audioController?.stop() ?? Future.value(),
//         ]);
//         if (mounted) {
//           setState(() => _isPlaying = false);
//         }
//         print('Both controllers stopped');
//       }
//     } catch (e) {
//       print('Error stopping: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Show error if any
//     if (_errorMessage != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error, size: 48, color: Colors.red),
//             SizedBox(height: 16),
//             Text(
//               _errorMessage!,
//               style: TextStyle(color: Colors.red),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _errorMessage = null;
//                   _isInitialized = false;
//                   _isInitializing = false;
//                   _controllersCreated = false;
//                   _videoUrl = null;
//                   _audioUrl = null;
//                 });
//                 _disposeControllers().then((_) {
//                   _loadStreamUrls();
//                 });
//               },
//               child: Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     // Show loading if not ready
//     if (!_controllersCreated || (_isInitializing && !_isInitialized)) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text(!_controllersCreated 
//               ? 'Loading YouTube video streams...' 
//               : 'Initializing video players...'),
//           ],
//         ),
//       );
//     }

//     // Create controllers when URLs are ready but controllers don't exist yet
//     if (_controllersCreated && _videoController == null && _audioController == null) {
//       _createControllers();
//     }

//     return Column(
//       children: [
//         // Video Info
//         // if (widget.name != null)
//         //   Padding(
//         //     padding: const EdgeInsets.all(8.0),
//         //     child: Text(
//         //       widget.name!,
//         //       style: Theme.of(context).textTheme.titleMedium,
//         //       textAlign: TextAlign.center,
//         //     ),
//         //   ),
        
//         // Video player (visible)
//         Container(
//           height: screenhgt,
//           decoration: BoxDecoration(
//             color: Colors.black,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: _videoController != null ? VlcPlayer(
//               controller: _videoController!,
//               aspectRatio: 16 / 9,
//               placeholder: const Center(
//                 child: Text(
//                   'Loading Video...',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ) : Container(
//               color: Colors.black,
//               child: const Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//           ),
//         ),
        
//         // Audio player (hidden - केवल audio के लिए)
//         if (_audioController != null)
//           Offstage(
//             offstage: true,
//             child: Container(
//               height: 1,
//               width: 1,
//               child: VlcPlayer(
//                 controller: _audioController!,
//                 aspectRatio: 1,
//               ),
//             ),
//           ),
        
//         // // Position indicator
//         // Padding(
//         //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//         //   child: Text(
//         //     'Position: ${_formatDuration(_currentPosition)}',
//         //     style: Theme.of(context).textTheme.bodySmall,
//         //   ),
//         // ),
        
//         // // Controls
//         // Padding(
//         //   padding: const EdgeInsets.all(8.0),
//         //   child: Row(
//         //     mainAxisAlignment: MainAxisAlignment.center,
//         //     children: [
//         //       IconButton(
//         //         onPressed: _isInitialized ? () => _seekBoth(Duration.zero) : null,
//         //         icon: const Icon(Icons.replay),
//         //         tooltip: 'Restart',
//         //       ),
//         //       const SizedBox(width: 16),
//         //       IconButton(
//         //         onPressed: _isInitialized ? (_isPlaying ? _pauseBoth : _playBoth) : null,
//         //         icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
//         //         iconSize: 32,
//         //         tooltip: _isPlaying ? 'Pause' : 'Play',
//         //       ),
//         //       const SizedBox(width: 16),
//         //       IconButton(
//         //         onPressed: _isInitialized ? _stopBoth : null,
//         //         icon: const Icon(Icons.stop),
//         //         tooltip: 'Stop',
//         //       ),
//         //     ],
//         //   ),
//         // ),
//       ],
//     );
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//   }

//   @override
//   void dispose() async {
//     print('Disposing CustomYoutubePlayer...');
//     try {
//       await _disposeControllers();
//       _youtubeExplode.close();
//     } catch (e) {
//       print('Error in dispose: $e');
//     }
//     super.dispose();
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'dart:io';

// class CustomYoutubePlayer extends StatefulWidget {
//   final String videoUrl;
//   final String name;
  
//   CustomYoutubePlayer({required this.videoUrl, required this.name});

//   @override
//   _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
// }

// class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
//   late WebViewController controller;
//   bool isLoading = true;
//   bool hasError = false;
//   String errorMessage = '';
//   bool isMuted = true;
//   bool showUnmuteButton = false;
//   final FocusNode _focusNode = FocusNode();

//   String extractVideoId(String url) {
//     List<RegExp> patterns = [
//       RegExp(r"(?:youtube\.com\/watch\?v=)([a-zA-Z0-9_-]{11})"),
//       RegExp(r"(?:youtu\.be\/)([a-zA-Z0-9_-]{11})"),
//       RegExp(r"(?:youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})"),
//     ];
    
//     for (RegExp pattern in patterns) {
//       Match? match = pattern.firstMatch(url);
//       if (match != null && match.group(1) != null) {
//         return match.group(1)!;
//       }
//     }
    
//     if (url.length == 11 && RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(url)) {
//       return url;
//     }
    
//     return url;
//   }

//   @override
//   void initState() {
//     super.initState();
//     initializeWebView();
//     // Auto-focus for remote control
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusNode.requestFocus();
//     });
//   }

//   void _handleRemoteKey(RawKeyEvent event) {
//     if (event is RawKeyDownEvent) {
//       // Handle different arrow keys
//       if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
//           event.logicalKey == LogicalKeyboardKey.arrowDown ||
//           event.logicalKey == LogicalKeyboardKey.arrowLeft ||
//           event.logicalKey == LogicalKeyboardKey.arrowRight ||
//           event.logicalKey == LogicalKeyboardKey.select ||
//           event.logicalKey == LogicalKeyboardKey.enter) {
        
//         print('🎮 Remote key pressed: ${event.logicalKey}');
//         _unmuteVideo();
//       }
//     }
//   }

//   void _unmuteVideo() {
//     if (isMuted) {
//       // Enhanced JavaScript function to unmute and ensure video keeps playing
//       controller.runJavaScript('''
//         if (typeof player !== 'undefined' && player && isPlayerReady) {
//           try {
//             // First unmute the video
//             player.unMute();
            
//             // Ensure video is playing
//             var currentState = player.getPlayerState();
//             if (currentState !== 1) { // 1 = YT.PlayerState.PLAYING
//               player.playVideo();
//             }
            
//             // Set volume to reasonable level
//             player.setVolume(50);
            
//             console.log('🔊 Video unmuted and playing, state:', currentState);
//             isMuted = false;
            
//             // Notify Flutter
//             if (window.Flutter && window.Flutter.postMessage) {
//               window.Flutter.postMessage('videoUnmuted');
//             }
//           } catch (e) {
//             console.error('Error unmuting:', e);
//           }
//         }
//       ''');
      
//       setState(() {
//         isMuted = false;
//         showUnmuteButton = false;
//       });
      
//       // Show success message temporarily
//       Future.delayed(Duration(seconds: 2), () {
//         if (mounted) {
//           setState(() {
//             // Keep the state as unmuted
//           });
//         }
//       });
      
//       print('🔊 Video unmuted via remote');
//     }
//   }

//   void initializeWebView() {
//     try {
//       String videoId = extractVideoId(widget.videoUrl);
      
//       // HTML with aggressive autoplay
//       String htmlContent = '''
//       <!DOCTYPE html>
//       <html>
//       <head>
//           <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
//           <style>
//               * { 
//                   margin: 0; 
//                   padding: 0; 
//                   box-sizing: border-box;
//               }
//               html, body { 
//                   height: 100%; 
//                   background: #000; 
//                   overflow: hidden;
//               }
//               .container {
//                   position: relative;
//                   width: 100vw;
//                   height: 100vh;
//                   background: #000;
//               }
//               #player {
//                   width: 100%;
//                   height: 100%;
//                   background: #000;
//               }
//               .loading {
//                   position: absolute;
//                   top: 50%;
//                   left: 50%;
//                   transform: translate(-50%, -50%);
//                   color: white;
//                   text-align: center;
//               }
//           </style>
//       </head>
//       <body>
//           <div class="container">
//               <div id="loading" class="loading">
//                   <div>🎥 Starting autoplay...</div>
//               </div>
//               <div id="player"></div>
//           </div>

//           <script>
//               var player;
//               var isPlayerReady = false;
//               var isMuted = true;
              
//               // Load YouTube API
//               function loadYouTubeAPI() {
//                   var tag = document.createElement('script');
//                   tag.src = "https://www.youtube.com/iframe_api";
//                   var firstScriptTag = document.getElementsByTagName('script')[0];
//                   firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
//               }
              
//               // YouTube API ready callback
//               function onYouTubeIframeAPIReady() {
//                   console.log('YouTube API Ready - Initializing Player');
//                   createPlayer();
//               }
              
//               function createPlayer() {
//                   player = new YT.Player('player', {
//                       height: '100%',
//                       width: '100%',
//                       videoId: '$videoId',
//                       host: 'https://www.youtube-nocookie.com',
//                       playerVars: {
//                           'autoplay': 1,        // Enable autoplay
//                           'mute': 1,            // Muted autoplay (browsers allow this)
//                           'playsinline': 1,
//                           'controls': 1,
//                           'rel': 0,
//                           'modestbranding': 1,
//                           'iv_load_policy': 3,
//                           'fs': 1,
//                           'enablejsapi': 1,
//                           'start': 0,
//                           'loop': 0,
//                           'cc_load_policy': 0,
//                           'origin': window.location.origin,
//                           'widget_referrer': window.location.origin
//                       },
//                       events: {
//                           'onReady': onPlayerReady,
//                           'onStateChange': onPlayerStateChange,
//                           'onError': onPlayerError
//                       }
//                   });
//               }
              
//               function onPlayerReady(event) {
//                   console.log('✅ Player Ready - Starting Autoplay');
//                   isPlayerReady = true;
//                   document.getElementById('loading').style.display = 'none';
                  
//                   // Aggressive autoplay attempts
//                   setTimeout(() => {
//                       try {
//                           event.target.mute();  // Ensure muted
//                           event.target.playVideo();  // Force play
//                           console.log('🎬 Autoplay started (muted)');
//                           // Notify Flutter that video is ready and muted
//                           if (window.Flutter && window.Flutter.postMessage) {
//                               window.Flutter.postMessage('videoReady');
//                           }
//                       } catch (e) {
//                           console.log('Autoplay failed:', e);
//                           // Fallback: try again after short delay
//                           setTimeout(() => {
//                               event.target.playVideo();
//                           }, 500);
//                       }
//                   }, 100);
//               }
              
//               function onPlayerStateChange(event) {
//                   console.log('Player state:', event.data);
                  
//                   if (event.data == YT.PlayerState.PLAYING) {
//                       console.log('✅ Video is playing');
//                       // Notify Flutter that video is playing
//                       if (window.Flutter && window.Flutter.postMessage) {
//                           window.Flutter.postMessage('videoPlaying');
//                       }
//                   } else if (event.data == YT.PlayerState.PAUSED) {
//                       console.log('⏸️ Video paused');
//                       // Auto-resume if video was paused unexpectedly and we're unmuted
//                       if (!isMuted) {
//                           setTimeout(() => {
//                               if (player && player.getPlayerState() === YT.PlayerState.PAUSED) {
//                                   player.playVideo();
//                                   console.log('🔄 Auto-resumed paused video');
//                               }
//                           }, 500);
//                       }
//                   } else if (event.data == YT.PlayerState.BUFFERING) {
//                       console.log('⏳ Video buffering');
//                   } else if (event.data == YT.PlayerState.ENDED) {
//                       console.log('🏁 Video ended');
//                   }
//               }
              
//               function onPlayerError(event) {
//                   console.error('❌ Player error:', event.data);
//                   var errorMessage = '';
//                   var shouldRetry = false;
                  
//                   switch(event.data) {
//                       case 2:
//                           errorMessage = 'Invalid video ID';
//                           break;
//                       case 5:
//                           errorMessage = 'HTML5 player error';
//                           shouldRetry = true;
//                           break;
//                       case 100:
//                           errorMessage = 'Video not found or private';
//                           break;
//                       case 101:
//                       case 150:
//                           errorMessage = 'Embed restricted by video owner';
//                           shouldRetry = true;
//                           break;
//                       default:
//                           errorMessage = 'Unknown error: ' + event.data;
//                           shouldRetry = true;
//                   }
                  
//                   console.log('Error details:', errorMessage);
                  
//                   // Try to recover from embed restrictions
//                   if (shouldRetry && (event.data === 150 || event.data === 101)) {
//                       console.log('🔄 Attempting to bypass embed restrictions...');
                      
//                       // Try alternative embed parameters
//                       setTimeout(() => {
//                           if (player && typeof player.destroy === 'function') {
//                               player.destroy();
//                           }
                          
//                           // Recreate player with different parameters
//                           player = new YT.Player('player', {
//                               height: '100%',
//                               width: '100%',
//                               videoId: '$videoId',
//                               playerVars: {
//                                   'autoplay': 1,
//                                   'mute': 1,
//                                   'playsinline': 1,
//                                   'controls': 1,
//                                   'rel': 0,
//                                   'modestbranding': 1,
//                                   'iv_load_policy': 3,
//                                   'fs': 1,
//                                   'enablejsapi': 1,
//                                   'origin': window.location.origin,
//                                   'widget_referrer': window.location.origin,
//                                   'cc_load_policy': 0,
//                                   'hl': 'en',
//                                   'cc_lang_pref': 'en'
//                               },
//                               events: {
//                                   'onReady': onPlayerReady,
//                                   'onStateChange': onPlayerStateChange,
//                                   'onError': function(err) {
//                                       console.error('❌ Retry failed:', err.data);
//                                       document.getElementById('loading').innerHTML = 
//                                           '<div style="color: red;">Video embed restricted<br/>Error: ' + err.data + '</div>';
//                                   }
//                               }
//                           });
//                       }, 1000);
//                   } else {
//                       document.getElementById('loading').innerHTML = 
//                           '<div style="color: red;">Error: ' + errorMessage + '</div>';
//                   }
//               }
              
//               function unmuteVideo() {
//                   if (isPlayerReady && player) {
//                       try {
//                           // Unmute the video
//                           player.unMute();
                          
//                           // Ensure video continues playing
//                           var currentState = player.getPlayerState();
//                           if (currentState !== 1) { // 1 = YT.PlayerState.PLAYING
//                               player.playVideo();
//                           }
                          
//                           // Set volume to audible level
//                           player.setVolume(70);
                          
//                           isMuted = false;
//                           console.log('🔊 Video unmuted and playing, state:', currentState);
                          
//                           // Notify Flutter that video is unmuted
//                           if (window.Flutter && window.Flutter.postMessage) {
//                               window.Flutter.postMessage('videoUnmuted');
//                           }
//                       } catch (error) {
//                           console.error('Error in unmuteVideo:', error);
//                       }
//                   }
//               }
              
//               // Additional autoplay triggers
//               document.addEventListener('DOMContentLoaded', function() {
//                   loadYouTubeAPI();
//               });
              
//               // Visibility change handler (when user comes back to tab)
//               document.addEventListener('visibilitychange', function() {
//                   if (!document.hidden && isPlayerReady && player) {
//                       setTimeout(() => {
//                           var state = player.getPlayerState();
//                           if (state !== YT.PlayerState.PLAYING) {
//                               player.playVideo();
//                           }
//                       }, 200);
//                   }
//               });
              
//               // Start loading
//               if (document.readyState === 'loading') {
//                   document.addEventListener('DOMContentLoaded', loadYouTubeAPI);
//               } else {
//                   loadYouTubeAPI();
//               }
//           </script>
//       </body>
//       </html>
//       ''';
      
//       controller = WebViewController()
//         ..setJavaScriptMode(JavaScriptMode.unrestricted)
//         ..setBackgroundColor(Colors.black)
//         ..enableZoom(false);

//       // Add JavaScript channel for communication
//       controller.addJavaScriptChannel(
//         'Flutter',
//         onMessageReceived: (JavaScriptMessage message) {
//           print('Message from WebView: ${message.message}');
//           if (message.message == 'videoReady' || message.message == 'videoPlaying') {
//             setState(() {
//               showUnmuteButton = isMuted;
//             });
//           } else if (message.message == 'videoUnmuted') {
//             setState(() {
//               isMuted = false;
//               showUnmuteButton = false;
//             });
//           }
//         },
//       );

//       if (Platform.isAndroid) {
//         controller
//           ..setUserAgent('Mozilla/5.0 (Smart-TV; Linux; Tizen 6.0) AppleWebKit/537.36 (KHTML, like Gecko) 85.0.4183.87/6.0 TV Safari/537.36')
//           ..setNavigationDelegate(
//             NavigationDelegate(
//               onPageStarted: (String url) {
//                 print('📄 Starting autoplay page load');
//                 setState(() {
//                   isLoading = true;
//                   hasError = false;
//                 });
//               },
//               onPageFinished: (String url) {
//                 print('✅ Autoplay page loaded');
//                 setState(() {
//                   isLoading = false;
//                 });
                
//                 // Additional autoplay trigger after page load
//                 Future.delayed(Duration(milliseconds: 1500), () {
//                   controller.runJavaScript('''
//                     if (typeof player !== 'undefined' && player && player.playVideo) {
//                       player.mute();
//                       player.playVideo();
//                       console.log('🎬 Triggered autoplay after page load');
//                     }
//                   ''');
                  
//                   // Show unmute button after video starts
//                   setState(() {
//                     showUnmuteButton = true;
//                   });
//                 });
//               },
//               onWebResourceError: (WebResourceError error) {
//                 print('❌ Autoplay error: ${error.description}');
//                 setState(() {
//                   isLoading = false;
//                   hasError = true;
//                   errorMessage = error.description;
//                 });
//               },
//             ),
//           );
//       }

//       controller.loadHtmlString(htmlContent);
        
//     } catch (e) {
//       setState(() {
//         hasError = true;
//         errorMessage = 'Failed to initialize: $e';
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return RawKeyboardListener(
//       focusNode: _focusNode,
//       onKey: _handleRemoteKey,
//       autofocus: true,
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: Container(
//           color: Colors.black,
//           child: Stack(
//             children: [
//               if (!hasError) 
//                 WebViewWidget(controller: controller),
              
//               if (hasError)
//                 Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.error_outline, size: 64, color: Colors.red),
//                       SizedBox(height: 16),
//                       Text(
//                         'Autoplay Failed', 
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
//                       ),
//                       SizedBox(height: 8),
//                       Text(errorMessage, style: TextStyle(color: Colors.white70)),
//                       SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: initializeWebView,
//                         child: Text('Try Again'),
//                         style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                       ),
//                     ],
//                   ),
//                 ),
              
//               if (isLoading && !hasError)
//                 Container(
//                   color: Colors.black87,
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         CircularProgressIndicator(color: Colors.red),
//                         SizedBox(height: 16),
//                         Text('🎬 Preparing autoplay...', style: TextStyle(color: Colors.white)),
//                       ],
//                     ),
//                   ),
//                 ),
              
//               // Unmute Button Overlay
//               if (showUnmuteButton && isMuted)
//                 Positioned(
//                   top: 50,
//                   left: 0,
//                   right: 0,
//                   child: Center(
//                     child: Container(
//                       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.8),
//                         borderRadius: BorderRadius.circular(25),
//                         border: Border.all(color: Colors.red, width: 2),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.volume_off, color: Colors.red, size: 24),
//                           SizedBox(width: 8),
//                           Text(
//                             'Press any arrow key to unmute',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(width: 8),
//                           Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 20),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
              
//               // Success message when unmuted
//               if (!isMuted && !showUnmuteButton)
//                 Positioned(
//                   top: 50,
//                   left: 0,
//                   right: 0,
//                   child: Center(
//                     child: AnimatedContainer(
//                       duration: Duration(milliseconds: 300),
//                       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                       decoration: BoxDecoration(
//                         color: Colors.green.withOpacity(0.9),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.volume_up, color: Colors.white, size: 20),
//                           SizedBox(width: 8),
//                           Text(
//                             'Video Unmuted!',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _focusNode.dispose();
//     super.dispose();
//   }
// }




import 'package:mobi_tv_entertainment/main.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:flutter/material.dart';

class CustomYoutubePlayer extends StatefulWidget {
  final String videoUrl;
  final String? name;

  const CustomYoutubePlayer({
    Key? key,
    required this.videoUrl,
    required this.name,
  }) : super(key: key);

  @override
  _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
}

enum PlayerState { unknown, unstarted, ended, playing, paused, buffering, cued }

class _CustomYoutubePlayerState extends State<CustomYoutubePlayer>
    with TickerProviderStateMixin {
  VlcPlayerController? _videoController;
  VlcPlayerController? _audioController;
  final YoutubeExplode _youtubeExplode = YoutubeExplode();
  
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _controllersCreated = false;
  Duration _currentPosition = Duration.zero;
  String? _errorMessage;
  String? _videoUrl;
  String? _audioUrl;

  // Different TV User Agents for rotation
  final List<String> _tvUserAgents = [
    'Mozilla/5.0 (Smart TV; Linux; Tizen 6.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.31 Safari/537.36',
    'Mozilla/5.0 (SMART-TV; Linux; Tizen 5.5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.93 Safari/537.36',
    'Mozilla/5.0 (Web0S; Linux/SmartTV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36',
    'Mozilla/5.0 (Linux; Android 9; SHIELD Android TV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.164 Safari/537.36',
    'SmartTV/1.0 (Linux; Android TV 9)',
    'HbbTV/1.1.1 (;LG;42LM620S-ZA;04.25.05;0x00000001;)',
    'Mozilla/5.0 (Unknown; Linux armv7l) AppleWebKit/537.1+ (KHTML, like Gecko) Safari/537.1+ HbbTV/1.1.1 ( ;LG ;NetCast 4.0 ;04.00.00 ;1920x1080 ;)',
  ];

  int _currentUserAgentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadStreamUrls();
  }

  String _getCurrentUserAgent() {
    return _tvUserAgents[_currentUserAgentIndex % _tvUserAgents.length];
  }

  void _rotateUserAgent() {
    _currentUserAgentIndex = (_currentUserAgentIndex + 1) % _tvUserAgents.length;
    print('Rotating to user agent: ${_getCurrentUserAgent()}');
  }

  Future<void> _loadStreamUrls() async {
    if (_isInitializing) return;
    
    if (!mounted) return;
    
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      // Validate the video URL first
      if (widget.videoUrl.isEmpty) {
        throw Exception('Video URL is empty');
      }

      print('Loading streams for: ${widget.videoUrl}');
      print('Using user agent: ${_getCurrentUserAgent()}');
      
      // Try to get manifest with better error handling
      StreamManifest? manifest;
      try {
        manifest = await _youtubeExplode.videos.streamsClient
            .getManifest(widget.videoUrl);
      } catch (manifestError) {
        print('Manifest error: $manifestError');
        
        // Try with different user agent
        _rotateUserAgent();
        print('Retrying with different user agent...');
        
        try {
          manifest = await _youtubeExplode.videos.streamsClient
              .getManifest(widget.videoUrl);
        } catch (retryError) {
          throw Exception('Failed to get video manifest after retry: $retryError');
        }
      }
      
      if (manifest == null) {
        throw Exception('Could not get video manifest - manifest is null');
      }
      
      print('Manifest loaded successfully');
      
      // Get video-only streams with null safety
      var videoOnlyStreams = manifest.videoOnly;
      print('Found ${videoOnlyStreams?.length ?? 0} video-only streams');
      
      VideoOnlyStreamInfo? videoStream;
      if (videoOnlyStreams != null && videoOnlyStreams.isNotEmpty) {
        // Try to get best quality available - prefer HD quality
        videoStream = videoOnlyStreams.where((s) => s.videoQuality.name.contains('720p') || s.videoQuality.name.contains('hd720')).isNotEmpty
            ? videoOnlyStreams.where((s) => s.videoQuality.name.contains('720p') || s.videoQuality.name.contains('hd720')).first
            : videoOnlyStreams.first;
        print('Selected video stream: ${videoStream?.tag} - ${videoStream?.videoQuality.name}');
      }
      
      // Get audio-only streams with null safety
      var audioOnlyStreams = manifest.audioOnly;
      print('Found ${audioOnlyStreams?.length ?? 0} audio-only streams');
      
      AudioOnlyStreamInfo? audioStream;
      if (audioOnlyStreams != null && audioOnlyStreams.isNotEmpty) {
        // Get best audio quality
        audioStream = audioOnlyStreams.where((s) => s.bitrate.bitsPerSecond > 128000).isNotEmpty
            ? audioOnlyStreams.where((s) => s.bitrate.bitsPerSecond > 128000).first
            : audioOnlyStreams.first;
        print('Selected audio stream: ${audioStream?.tag} - ${audioStream?.audioCodec}');
      }
      
      if (videoStream != null && audioStream != null) {
        // Validate stream URLs with comprehensive null checks
        String? videoUrl;
        String? audioUrl;
        
        try {
          videoUrl = videoStream.url?.toString();
          audioUrl = audioStream.url?.toString();
        } catch (urlError) {
          print('URL extraction error: $urlError');
          throw Exception('Failed to extract stream URLs: $urlError');
        }
        
        if (videoUrl == null || videoUrl.isEmpty) {
          throw Exception('Video stream URL is null or empty');
        }
        
        if (audioUrl == null || audioUrl.isEmpty) {
          throw Exception('Audio stream URL is null or empty');
        }

        print('Video URL loaded: ${videoUrl.length > 50 ? videoUrl.substring(0, 50) + "..." : videoUrl}');
        print('Audio URL loaded: ${audioUrl.length > 50 ? audioUrl.substring(0, 50) + "..." : audioUrl}');
        
        // Store URLs and create controllers
        _videoUrl = videoUrl;
        _audioUrl = audioUrl;
        
        if (mounted) {
          setState(() {
            _controllersCreated = true;
            _isInitializing = false;
          });
          
          // Wait for the VLC widgets to be created and auto-initialized
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(Duration(milliseconds: 3000), () {
              if (mounted) {
                _waitForAutoInitialization();
              }
            });
          });
        }
      } else {
        String missingStreams = '';
        if (videoStream == null) missingStreams += 'video ';
        if (audioStream == null) missingStreams += 'audio ';
        
        // Check if streams exist but are empty
        if (videoOnlyStreams?.isEmpty == true) {
          missingStreams += '(no video streams available) ';
        }
        if (audioOnlyStreams?.isEmpty == true) {
          missingStreams += '(no audio streams available) ';
        }
        
        if (mounted) {
          setState(() {
            _errorMessage = 'No $missingStreams streams found for this video. This video might be restricted or unavailable.';
            _isInitializing = false;
          });
        }
      }
    } catch (e) {
      print('Error loading streams: $e');
      print('Stack trace: ${StackTrace.current}');
      
      String errorMessage = 'Error loading video: ${e.toString()}';
      
      // Provide more specific error messages for common issues
      if (e.toString().contains('VideoUnavailableException')) {
        errorMessage = 'This video is unavailable or private';
      } else if (e.toString().contains('VideoRequiresPurchaseException')) {
        errorMessage = 'This video requires purchase';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Network error: Please check your internet connection';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timed out: Please try again';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access forbidden: Video may be geo-restricted or blocked';
      }
      
      if (mounted) {
        setState(() {
          _errorMessage = errorMessage;
          _isInitializing = false;
        });
      }
    }
  }

  void _createControllers() {
    if (_videoUrl == null || _audioUrl == null) return;
    
    try {
      print('Creating controllers with TV user agent...');
      print('Current user agent: ${_getCurrentUserAgent()}');
      
      // Create video controller with enhanced options
      _videoController = VlcPlayerController.network(
        _videoUrl!,
        hwAcc: HwAcc.auto,
        autoPlay: false,
        autoInitialize: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.networkCaching(5000),
            VlcAdvancedOptions.liveCaching(5000),
            '--http-user-agent=${_getCurrentUserAgent()}',
            '--http-referrer=https://www.youtube.com/',
            '--http-reconnect',
            '--no-stats',
            '--intf=dummy',
            '--sout-keep',
            '--avcodec-hw=any',
          ]),
          audio: VlcAudioOptions([
            '--no-audio',
          ]),
          video: VlcVideoOptions([
            '--avcodec-hw=any',
          ]),
        ),
      );
      
      // Create audio controller with enhanced options
      _audioController = VlcPlayerController.network(
        _audioUrl!,
        hwAcc: HwAcc.auto,
        autoPlay: false,
        autoInitialize: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.networkCaching(5000),
            VlcAdvancedOptions.liveCaching(5000),
            '--http-user-agent=${_getCurrentUserAgent()}',
            '--http-referrer=https://www.youtube.com/',
            '--http-reconnect',
            '--no-stats',
            '--intf=dummy',
            '--sout-keep',
          ]),
          video: VlcVideoOptions([
            '--no-video',
          ]),
          audio: VlcAudioOptions([
            '--aout=any',
          ]),
        ),
      );

      print('Controllers created successfully with TV user agent');
    } catch (e) {
      print('Error creating controllers: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to create video players: $e';
        });
      }
    }
  }

  Future<void> _waitForAutoInitialization() async {
    if (!mounted || _videoController == null || _audioController == null) {
      print('Cannot wait for initialization: widget not mounted or controllers null');
      return;
    }

    try {
      print('Waiting for auto-initialization of controllers...');
      
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
      });

      // Wait for auto-initialization to complete
      int attempts = 0;
      const maxAttempts = 40; // 40 seconds maximum wait (increased for TV)
      
      while (attempts < maxAttempts && mounted) {
        final videoInitialized = _videoController?.value.isInitialized ?? false;
        final audioInitialized = _audioController?.value.isInitialized ?? false;
        
        print('Auto-initialization check $attempts: video=$videoInitialized, audio=$audioInitialized');
        
        if (videoInitialized && audioInitialized) {
          print('Both controllers auto-initialized successfully');
          break;
        }
        
        await Future.delayed(Duration(seconds: 1));
        attempts++;
      }

      if (mounted) {
        // Final check
        final videoInitialized = _videoController?.value.isInitialized ?? false;
        final audioInitialized = _audioController?.value.isInitialized ?? false;
        
        if (videoInitialized && audioInitialized) {
          setState(() {
            _isInitialized = true;
            _isInitializing = false;
          });

          print('All controllers ready for playback');
          _setupSyncListeners();
          
          // Auto-play after initialization
          Future.delayed(Duration(milliseconds: 1500), () {
            if (mounted) {
              print('Starting auto-play...');
              _playBoth();
            }
          });
        } else {
          throw Exception('Controllers failed to auto-initialize: video=$videoInitialized, audio=$audioInitialized');
        }
      }

    } catch (e) {
      print('Auto-initialization wait error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize video players: $e';
          _isInitializing = false;
          _isInitialized = false;
        });
      }
    }
  }

  Future<void> _disposeControllers() async {
    try {
      if (_videoController != null) {
        print('Disposing video controller...');
        await _videoController?.dispose();
        _videoController = null;
        print('Video controller disposed');
      }
      if (_audioController != null) {
        print('Disposing audio controller...');
        await _audioController?.dispose();
        _audioController = null;
        print('Audio controller disposed');
      }
    } catch (e) {
      print('Error disposing controllers: $e');
      // Set to null anyway to prevent further issues
      _videoController = null;
      _audioController = null;
    }
  }

  void _setupSyncListeners() {
    // Only setup sync if properly initialized
    if (!_isInitialized || _videoController == null || _audioController == null) {
      return;
    }

    // Start sync after a longer delay to ensure controllers are ready
    Future.delayed(Duration(seconds: 3), () {
      if (mounted && _isInitialized && _videoController != null && _audioController != null) {
        // Check every 2 seconds instead of every second
        Stream.periodic(Duration(seconds: 2)).listen((_) async {
          if (mounted && _isInitialized && _videoController != null && _audioController != null) {
            try {
              // Check if controllers are initialized before calling getPosition
              final videoInitialized = _videoController?.value.isInitialized ?? false;
              final audioInitialized = _audioController?.value.isInitialized ?? false;
              
              if (videoInitialized && audioInitialized) {
                final videoPosition = await _videoController?.getPosition() ?? Duration.zero;
                final audioPosition = await _audioController?.getPosition() ?? Duration.zero;
                
                // If positions are out of sync by more than 1 second, sync them
                final diff = (videoPosition.inMilliseconds - audioPosition.inMilliseconds).abs();
                if (diff > 1000) {
                  await _audioController?.seekTo(videoPosition);
                }
                
                if (mounted) {
                  setState(() {
                    _currentPosition = videoPosition;
                  });
                }
              }
            } catch (e) {
              // Don't log sync errors too frequently
              // print('Sync error: $e');
            }
          }
        });
      }
    });
  }

  Future<void> _playBoth() async {
    if (!_isInitialized || _videoController == null || _audioController == null) {
      print('Cannot play: not initialized or controllers are null');
      return;
    }

    try {
      // Check if controllers are initialized before playing
      final videoInitialized = _videoController?.value.isInitialized ?? false;
      final audioInitialized = _audioController?.value.isInitialized ?? false;
      
      if (videoInitialized && audioInitialized) {
        print('Playing both controllers...');
        await Future.wait([
          _videoController?.play() ?? Future.value(),
          _audioController?.play() ?? Future.value(),
        ]);
        if (mounted) {
          setState(() => _isPlaying = true);
        }
        print('Both controllers playing');
      } else {
        print('Controllers not ready: video=$videoInitialized, audio=$audioInitialized');
      }
    } catch (e) {
      print('Error playing: $e');
    }
  }

  Future<void> _pauseBoth() async {
    if (!_isInitialized || _videoController == null || _audioController == null) {
      print('Cannot pause: not initialized or controllers are null');
      return;
    }

    try {
      final videoInitialized = _videoController?.value.isInitialized ?? false;
      final audioInitialized = _audioController?.value.isInitialized ?? false;
      
      if (videoInitialized && audioInitialized) {
        print('Pausing both controllers...');
        await Future.wait([
          _videoController?.pause() ?? Future.value(),
          _audioController?.pause() ?? Future.value(),
        ]);
        if (mounted) {
          setState(() => _isPlaying = false);
        }
        print('Both controllers paused');
      }
    } catch (e) {
      print('Error pausing: $e');
    }
  }

  Future<void> _seekBoth(Duration position) async {
    if (!_isInitialized || _videoController == null || _audioController == null) {
      print('Cannot seek: not initialized or controllers are null');
      return;
    }

    try {
      final videoInitialized = _videoController?.value.isInitialized ?? false;
      final audioInitialized = _audioController?.value.isInitialized ?? false;
      
      if (videoInitialized && audioInitialized) {
        print('Seeking both controllers to ${position.inSeconds}s...');
        await Future.wait([
          _videoController?.seekTo(position) ?? Future.value(),
          _audioController?.seekTo(position) ?? Future.value(),
        ]);
        print('Both controllers seeked');
      }
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  Future<void> _stopBoth() async {
    if (!_isInitialized || _videoController == null || _audioController == null) {
      print('Cannot stop: not initialized or controllers are null');
      return;
    }

    try {
      final videoInitialized = _videoController?.value.isInitialized ?? false;
      final audioInitialized = _audioController?.value.isInitialized ?? false;
      
      if (videoInitialized && audioInitialized) {
        print('Stopping both controllers...');
        await Future.wait([
          _videoController?.stop() ?? Future.value(),
          _audioController?.stop() ?? Future.value(),
        ]);
        if (mounted) {
          setState(() => _isPlaying = false);
        }
        print('Both controllers stopped');
      }
    } catch (e) {
      print('Error stopping: $e');
    }
  }

  // Retry with different user agent
  Future<void> _retryWithDifferentUserAgent() async {
    _rotateUserAgent();
    setState(() {
      _errorMessage = null;
      _isInitialized = false;
      _isInitializing = false;
      _controllersCreated = false;
      _videoUrl = null;
      _audioUrl = null;
    });
    await _disposeControllers();
    _loadStreamUrls();
  }

  @override
  Widget build(BuildContext context) {
    // Show error if any
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                      _isInitialized = false;
                      _isInitializing = false;
                      _controllersCreated = false;
                      _videoUrl = null;
                      _audioUrl = null;
                    });
                    _disposeControllers().then((_) {
                      _loadStreamUrls();
                    });
                  },
                  child: Text('Retry'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _retryWithDifferentUserAgent,
                  child: Text('Try Different Agent'),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Current User Agent: ${_getCurrentUserAgent().substring(0, 30)}...',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Show loading if not ready
    if (!_controllersCreated || (_isInitializing && !_isInitialized)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(!_controllersCreated 
              ? 'Loading YouTube video streams...' 
              : 'Initializing video players...'),
            SizedBox(height: 8),
            Text(
              'Using: ${_getCurrentUserAgent().substring(0, 40)}...',
              style: TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Create controllers when URLs are ready but controllers don't exist yet
    if (_controllersCreated && _videoController == null && _audioController == null) {
      _createControllers();
    }

    return Column(
      children: [
        // Video Info
        // if (widget.name != null)
        //   Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: Text(
        //       widget.name!,
        //       style: Theme.of(context).textTheme.titleMedium,
        //       textAlign: TextAlign.center,
        //     ),
        //   ),
        
        // Video player (visible)
        Container(
          height: screenhgt,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _videoController != null ? VlcPlayer(
              controller: _videoController!,
              aspectRatio: 16 / 9,
              placeholder: const Center(
                child: Text(
                  'Loading Video...',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ) : Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
        
        // Audio player (hidden - केवल audio के लिए)
        if (_audioController != null)
          Offstage(
            offstage: true,
            child: Container(
              height: 1,
              width: 1,
              child: VlcPlayer(
                controller: _audioController!,
                aspectRatio: 1,
              ),
            ),
          ),
        
        // Debug info (remove in production)
        // Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Text(
        //     'User Agent: ${_getCurrentUserAgent()}',
        //     style: TextStyle(fontSize: 8, color: Colors.grey),
        //     textAlign: TextAlign.center,
        //   ),
        // ),
        
        // // Position indicator
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        //   child: Text(
        //     'Position: ${_formatDuration(_currentPosition)}',
        //     style: Theme.of(context).textTheme.bodySmall,
        //   ),
        // ),
        
        // // Controls
        // Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       IconButton(
        //         onPressed: _isInitialized ? () => _seekBoth(Duration.zero) : null,
        //         icon: const Icon(Icons.replay),
        //         tooltip: 'Restart',
        //       ),
        //       const SizedBox(width: 16),
        //       IconButton(
        //         onPressed: _isInitialized ? (_isPlaying ? _pauseBoth : _playBoth) : null,
        //         icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
        //         iconSize: 32,
        //         tooltip: _isPlaying ? 'Pause' : 'Play',
        //       ),
        //       const SizedBox(width: 16),
        //       IconButton(
        //         onPressed: _isInitialized ? _stopBoth : null,
        //         icon: const Icon(Icons.stop),
        //         tooltip: 'Stop',
        //       ),
        //       const SizedBox(width: 16),
        //       IconButton(
        //         onPressed: _retryWithDifferentUserAgent,
        //         icon: const Icon(Icons.refresh),
        //         tooltip: 'Try Different User Agent',
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() async {
    print('Disposing CustomYoutubePlayer...');
    try {
      await _disposeControllers();
      _youtubeExplode.close();
    } catch (e) {
      print('Error in dispose: $e');
    }
    super.dispose();
  }
}