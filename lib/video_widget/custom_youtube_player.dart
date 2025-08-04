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







// // import 'package:flutter/material.dart';
// // import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// // import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// // class CustomYoutubePlayer extends StatefulWidget {
// //   final String videoUrl;
// //   final String? name;

// //   const CustomYoutubePlayer({
// //     Key? key,
// //     required this.videoUrl,
// //     required this.name,
// //   }) : super(key: key);

// //   @override
// //   _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
// // }

// // enum PlayerState { unknown, unstarted, ended, playing, paused, buffering, cued }

// // class _CustomYoutubePlayerState extends State<CustomYoutubePlayer>
// //     with TickerProviderStateMixin {
// //   VlcPlayerController? _vlcPlayerController;
// //   bool _isLoading = true; // Initially loading state
// //   String? _errorMessage;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // Auto-play the video when widget initializes
// //     _playYouTubeVideo(widget.videoUrl);
// //   }

// //   Future<void> _playYouTubeVideo(String youtubeUrl) async {
// //     if (youtubeUrl.isEmpty) {
// //       _showError('Invalid YouTube URL');
// //       return;
// //     }

// //     setState(() {
// //       _isLoading = true;
// //       _errorMessage = null;
// //     });

// //     final yt = YoutubeExplode();

// //     try {
// //       // Parse video ID with proper error handling
// //       final videoIdString = VideoId.parseVideoId(youtubeUrl);
// //       if (videoIdString == null) {
// //         throw Exception('Invalid YouTube URL format - could not extract video ID');
// //       }

// //       final videoId = VideoId(videoIdString);

// //       print('Processing video ID: $videoIdString');

// //       // Get video manifest
// //       final manifest = await yt.videos.streamsClient.getManifest(videoId);

// //       print('Available streams:');
// //       print('Muxed streams: ${manifest.muxed.length}');
// //       print('Video-only streams: ${manifest.videoOnly.length}');
// //       print('Audio-only streams: ${manifest.audioOnly.length}');

// //       // Strategy: Prioritize muxed streams with audio support
// //       String? streamUrl;

// //       if (manifest.muxed.isNotEmpty) {
// //         // Sort muxed streams by quality and try to find one with good audio
// //         final muxedStreams = manifest.muxed.toList();

// //         // Print all available muxed streams
// //         print('Available muxed streams:');
// //         for (var stream in muxedStreams) {
// //           print('Quality: ${stream.videoQualityLabel}, Container: ${stream.container}, Bitrate: ${stream.bitrate}');
// //         }

// //         // Try to find 360p or 480p streams first (they usually have audio)
// //         var preferredStream = muxedStreams.where((s) =>
// //           s.videoQualityLabel == '360p' || s.videoQualityLabel == '480p'
// //         ).firstOrNull;

// //         // If no preferred quality found, use the lowest quality available
// //         if (preferredStream == null) {
// //           preferredStream = muxedStreams.first; // Lowest quality for audio compatibility
// //         }

// //         streamUrl = preferredStream.url.toString();
// //         print('Selected muxed stream: ${preferredStream.videoQualityLabel} - ${preferredStream.container}');
// //       }
// //       // If no muxed streams, try adaptive streams (but warn about audio)
// //       else if (manifest.videoOnly.isNotEmpty) {
// //         print('No muxed streams available - trying video-only (audio may not work)');

// //         // Try to get a medium quality video stream
// //         final videoStreams = manifest.videoOnly.toList();
// //         var selectedStream = videoStreams.where((s) =>
// //           s.videoQualityLabel == '480p' || s.videoQualityLabel == '360p'
// //         ).firstOrNull ?? videoStreams.first;

// //         streamUrl = selectedStream.url.toString();
// //         print('Using video-only stream: ${selectedStream.videoQualityLabel}');

// //         // Show audio warning
// //         if (mounted) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(
// //               content: Text('⚠️ Audio not available - This video uses separate audio/video streams'),
// //               backgroundColor: Colors.orange,
// //               duration: Duration(seconds: 4),
// //             ),
// //           );
// //         }
// //       }
// //       else {
// //         throw Exception('No playable streams found for this video');
// //       }

// //       if (streamUrl == null || streamUrl.isEmpty) {
// //         throw Exception('Could not extract valid stream URL');
// //       }

// //       print('Final stream URL: ${streamUrl.substring(0, 100)}...');

// //       // Dispose previous controller safely
// //       await _vlcPlayerController?.dispose();

// //       // Create VLC controller with audio-optimized settings
// //       _vlcPlayerController = VlcPlayerController.network(
// //         streamUrl,
// //         autoPlay: true,
// //         hwAcc: HwAcc.auto,
// //         options: VlcPlayerOptions(
// //           advanced: VlcAdvancedOptions([
// //             VlcAdvancedOptions.networkCaching(2000),
// //           ]),
// //           audio: VlcAudioOptions([
// //             VlcAudioOptions.audioTimeStretch(true),
// //           ]),
// //           extras: [
// //             '--audio-visual=none', // Disable audio visualization
// //             '--no-video-name-show', // Don't show video title
// //             '--network-caching=2000', // Network caching
// //           ],
// //         ),
// //       );

// //       // Add listener for player events
// //       _vlcPlayerController?.addListener(_playerListener);

// //       setState(() => _isLoading = false);

// //     } catch (e) {
// //       print('Error loading video: $e');
// //       _showError('Failed to load video: ${e.toString()}');
// //     } finally {
// //       yt.close();
// //     }
// //   }

// //   void _playerListener() {
// //     if (_vlcPlayerController != null) {
// //       // Handle player state changes here if needed
// //       final isPlaying = _vlcPlayerController!.value.isPlaying;
// //       final hasError = _vlcPlayerController!.value.hasError;

// //       if (hasError) {
// //         _showError('Video playback error occurred');
// //       }
// //     }
// //   }

// //   void _showError(String message) {
// //     setState(() {
// //       _isLoading = false;
// //       _errorMessage = message;
// //     });

// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: Colors.red,
// //         duration: Duration(seconds: 3),
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _vlcPlayerController?.removeListener(_playerListener);
// //     _vlcPlayerController?.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Padding(
// //         padding: const EdgeInsets.all(12),
// //         child: Column(
// //           children: [
// //             // // Show video name if provided
// //             // if (widget.name != null)
// //             //   Container(
// //             //     width: double.infinity,
// //             //     padding: EdgeInsets.all(16),
// //             //     child: Text(
// //             //       widget.name!,
// //             //       style: TextStyle(
// //             //         fontSize: 18,
// //             //         fontWeight: FontWeight.bold,
// //             //       ),
// //             //       textAlign: TextAlign.center,
// //             //     ),
// //             //   ),

// //             // // Error Message
// //             // if (_errorMessage != null)
// //             //   Container(
// //             //     width: double.infinity,
// //             //     padding: EdgeInsets.all(12),
// //             //     margin: EdgeInsets.only(bottom: 10),
// //             //     decoration: BoxDecoration(
// //             //       color: Colors.red.shade50,
// //             //       border: Border.all(color: Colors.red.shade200),
// //             //       borderRadius: BorderRadius.circular(8),
// //             //     ),
// //             //     child: Text(
// //             //       _errorMessage!,
// //             //       style: TextStyle(color: Colors.red.shade700),
// //             //     ),
// //             //   ),

// //             // Video Player
// //             Expanded(
// //               child: _isLoading
// //                   ? Center(
// //                       child: Column(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: [
// //                           CircularProgressIndicator(color: Colors.red),
// //                           SizedBox(height: 16),
// //                           Text('Loading video...'),
// //                         ],
// //                       ),
// //                     )
// //                   : _vlcPlayerController != null && _errorMessage == null
// //                       ? Container(
// //                           decoration: BoxDecoration(
// //                             color: Colors.black,
// //                             borderRadius: BorderRadius.circular(8),
// //                           ),
// //                           child: ClipRRect(
// //                             borderRadius: BorderRadius.circular(8),
// //                             child: VlcPlayer(
// //                               controller: _vlcPlayerController!,
// //                               aspectRatio: 16 / 9,
// //                               placeholder: Center(
// //                                 child: CircularProgressIndicator(color: Colors.white),
// //                               ),
// //                             ),
// //                           ),
// //                         )
// //                       : Container(
// //                           decoration: BoxDecoration(
// //                             color: Colors.grey.shade200,
// //                             borderRadius: BorderRadius.circular(8),
// //                           ),
// //                           child: Center(
// //                             child: Column(
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Icon(Icons.error_outline, size: 64, color: Colors.grey),
// //                                 SizedBox(height: 16),
// //                                 Text(
// //                                   'Failed to load video',
// //                                   style: TextStyle(color: Colors.grey.shade600),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // import 'package:youtube_explode_dart/youtube_explode_dart.dart';
// // import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// // import 'package:flutter/material.dart';

// // class CustomYoutubePlayer extends StatefulWidget {
// //   final String videoUrl;
// //   final String? name;

// //   const CustomYoutubePlayer({
// //     Key? key,
// //     required this.videoUrl,
// //     required this.name,
// //   }) : super(key: key);

// //   @override
// //   _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
// // }

// // enum PlayerState { unknown, unstarted, ended, playing, paused, buffering, cued }

// // class _CustomYoutubePlayerState extends State<CustomYoutubePlayer>
// //     with TickerProviderStateMixin {
// //   VlcPlayerController? _videoController;
// //   VlcPlayerController? _audioController;
// //   final YoutubeExplode _youtubeExplode = YoutubeExplode();

// //   bool _isPlaying = false;
// //   bool _isInitialized = false;
// //   bool _isInitializing = false;
// //   Duration _currentPosition = Duration.zero;
// //   String? _errorMessage;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializePlayers();
// //   }

// //   Future<void> _initializePlayers() async {
// //     if (_isInitializing) return;

// //     setState(() {
// //       _isInitializing = true;
// //       _errorMessage = null;
// //     });

// //     try {
// //       var manifest = await _youtubeExplode.videos.streamsClient
// //           .getManifest(widget.videoUrl);

// //       // Get video-only stream (first available)
// //       var videoOnlyStreams = manifest.videoOnly;
// //       VideoOnlyStreamInfo? videoStream;
// //       if (videoOnlyStreams.isNotEmpty) {
// //         videoStream = videoOnlyStreams.first;
// //       }

// //       // Get audio-only stream (first available)
// //       var audioOnlyStreams = manifest.audioOnly;
// //       AudioOnlyStreamInfo? audioStream;
// //       if (audioOnlyStreams.isNotEmpty) {
// //         audioStream = audioOnlyStreams.first;
// //       }

// //       if (videoStream != null && audioStream != null) {
// //         // Video player (muted)
// //         _videoController = VlcPlayerController.network(
// //           videoStream.url.toString(),
// //           hwAcc: HwAcc.auto,
// //           autoPlay: false,
// //           options: VlcPlayerOptions(
// //             audio: VlcAudioOptions([
// //               '--no-audio',
// //             ]),
// //           ),
// //         );

// //         // Audio player (hidden)
// //         _audioController = VlcPlayerController.network(
// //           audioStream.url.toString(),
// //           hwAcc: HwAcc.auto,
// //           autoPlay: false,
// //           options: VlcPlayerOptions(
// //             video: VlcVideoOptions([
// //               '--no-video',
// //             ]),
// //           ),
// //         );

// //         // Wait for controllers to be ready
// //         await Future.delayed(Duration(seconds: 2));

// //         // Check if controllers are actually initialized
// //         if (_videoController != null && _audioController != null) {
// //           // Try to initialize explicitly
// //           try {
// //             await _videoController!.initialize();
// //             await _audioController!.initialize();

// //             // Wait a bit more for VLC to be ready
// //             await Future.delayed(Duration(seconds: 1));

// //             setState(() {
// //               _isInitialized = true;
// //               _isInitializing = false;
// //             });

// //             // Start sync only after successful initialization
// //             _setupSyncListeners();
// //           } catch (initError) {
// //             print('Controller initialization error: $initError');
// //             setState(() {
// //               _errorMessage = 'Failed to initialize video players';
// //               _isInitializing = false;
// //             });
// //           }
// //         }
// //       } else {
// //         setState(() {
// //           _errorMessage = 'No video or audio streams found';
// //           _isInitializing = false;
// //         });
// //       }
// //     } catch (e) {
// //       print('Error initializing players: $e');
// //       setState(() {
// //         _errorMessage = 'Error loading video: ${e.toString()}';
// //         _isInitializing = false;
// //       });
// //     }
// //   }

// //   void _setupSyncListeners() {
// //     // Only setup sync if properly initialized
// //     if (!_isInitialized || _videoController == null || _audioController == null) {
// //       return;
// //     }

// //     // Start sync after a longer delay to ensure controllers are ready
// //     Future.delayed(Duration(seconds: 3), () {
// //       if (mounted && _isInitialized && _videoController != null && _audioController != null) {
// //         // Check every 2 seconds instead of every second
// //         Stream.periodic(Duration(seconds: 2)).listen((_) async {
// //           if (mounted && _isInitialized && _videoController != null && _audioController != null) {
// //             try {
// //               // Check if controllers are initialized before calling getPosition
// //               if (_videoController!.value.isInitialized && _audioController!.value.isInitialized) {
// //                 final videoPosition = await _videoController!.getPosition();
// //                 final audioPosition = await _audioController!.getPosition();

// //                 // If positions are out of sync by more than 1 second, sync them
// //                 final diff = (videoPosition.inMilliseconds - audioPosition.inMilliseconds).abs();
// //                 if (diff > 1000) {
// //                   await _audioController!.seekTo(videoPosition);
// //                 }

// //                 if (mounted) {
// //                   setState(() {
// //                     _currentPosition = videoPosition;
// //                   });
// //                 }
// //               }
// //             } catch (e) {
// //               // Don't log sync errors too frequently
// //               // print('Sync error: $e');
// //             }
// //           }
// //         });
// //       }
// //     });
// //   }

// //   Future<void> _playBoth() async {
// //     if (!_isInitialized || _videoController == null || _audioController == null) {
// //       return;
// //     }

// //     try {
// //       // Check if controllers are initialized before playing
// //       if (_videoController!.value.isInitialized && _audioController!.value.isInitialized) {
// //         await Future.wait([
// //           _videoController!.play(),
// //           _audioController!.play(),
// //         ]);
// //         setState(() => _isPlaying = true);
// //       }
// //     } catch (e) {
// //       print('Error playing: $e');
// //     }
// //   }

// //   Future<void> _pauseBoth() async {
// //     if (!_isInitialized || _videoController == null || _audioController == null) {
// //       return;
// //     }

// //     try {
// //       if (_videoController!.value.isInitialized && _audioController!.value.isInitialized) {
// //         await Future.wait([
// //           _videoController!.pause(),
// //           _audioController!.pause(),
// //         ]);
// //         setState(() => _isPlaying = false);
// //       }
// //     } catch (e) {
// //       print('Error pausing: $e');
// //     }
// //   }

// //   Future<void> _seekBoth(Duration position) async {
// //     if (!_isInitialized || _videoController == null || _audioController == null) {
// //       return;
// //     }

// //     try {
// //       if (_videoController!.value.isInitialized && _audioController!.value.isInitialized) {
// //         await Future.wait([
// //           _videoController!.seekTo(position),
// //           _audioController!.seekTo(position),
// //         ]);
// //       }
// //     } catch (e) {
// //       print('Error seeking: $e');
// //     }
// //   }

// //   Future<void> _stopBoth() async {
// //     if (!_isInitialized || _videoController == null || _audioController == null) {
// //       return;
// //     }

// //     try {
// //       if (_videoController!.value.isInitialized && _audioController!.value.isInitialized) {
// //         await Future.wait([
// //           _videoController!.stop(),
// //           _audioController!.stop(),
// //         ]);
// //         setState(() => _isPlaying = false);
// //       }
// //     } catch (e) {
// //       print('Error stopping: $e');
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Show error if any
// //     if (_errorMessage != null) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(Icons.error, size: 48, color: Colors.red),
// //             SizedBox(height: 16),
// //             Text(
// //               _errorMessage!,
// //               style: TextStyle(color: Colors.red),
// //               textAlign: TextAlign.center,
// //             ),
// //             SizedBox(height: 16),
// //             ElevatedButton(
// //               onPressed: () {
// //                 setState(() {
// //                   _errorMessage = null;
// //                   _isInitialized = false;
// //                   _isInitializing = false;
// //                 });
// //                 _initializePlayers();
// //               },
// //               child: Text('Retry'),
// //             ),
// //           ],
// //         ),
// //       );
// //     }

// //     // Show loading if initializing or not initialized
// //     if (_isInitializing || !_isInitialized) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             CircularProgressIndicator(),
// //             SizedBox(height: 16),
// //             Text(_isInitializing ? 'Initializing video players...' : 'Loading YouTube video...'),
// //           ],
// //         ),
// //       );
// //     }

// //     return Column(
// //       children: [
// //         // Video Info
// //         if (widget.name != null)
// //           Padding(
// //             padding: const EdgeInsets.all(8.0),
// //             child: Text(
// //               widget.name!,
// //               style: Theme.of(context).textTheme.titleMedium,
// //               textAlign: TextAlign.center,
// //             ),
// //           ),

// //         // Video player (visible)
// //         Container(
// //           height: 200,
// //           decoration: BoxDecoration(
// //             color: Colors.black,
// //             borderRadius: BorderRadius.circular(8),
// //           ),
// //           child: ClipRRect(
// //             borderRadius: BorderRadius.circular(8),
// //             child: VlcPlayer(
// //               controller: _videoController!,
// //               aspectRatio: 16 / 9,
// //               placeholder: const Center(
// //                 child: Text(
// //                   'Loading Video...',
// //                   style: TextStyle(color: Colors.white),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),

// //         // Audio player (hidden - केवल audio के लिए)
// //         Container(
// //           height: 0,
// //           width: 0,
// //           child: VlcPlayer(
// //             controller: _audioController!,
// //             aspectRatio: 1,
// //           ),
// //         ),

// //         // Position indicator
// //         Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
// //           child: Text(
// //             'Position: ${_formatDuration(_currentPosition)}',
// //             style: Theme.of(context).textTheme.bodySmall,
// //           ),
// //         ),

// //         // Controls
// //         Padding(
// //           padding: const EdgeInsets.all(8.0),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               IconButton(
// //                 onPressed: () => _seekBoth(Duration.zero),
// //                 icon: const Icon(Icons.replay),
// //                 tooltip: 'Restart',
// //               ),
// //               const SizedBox(width: 16),
// //               IconButton(
// //                 onPressed: _isPlaying ? _pauseBoth : _playBoth,
// //                 icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
// //                 iconSize: 32,
// //                 tooltip: _isPlaying ? 'Pause' : 'Play',
// //               ),
// //               const SizedBox(width: 16),
// //               IconButton(
// //                 onPressed: _stopBoth,
// //                 icon: const Icon(Icons.stop),
// //                 tooltip: 'Stop',
// //               ),
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   String _formatDuration(Duration duration) {
// //     String twoDigits(int n) => n.toString().padLeft(2, "0");
// //     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
// //     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
// //     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
// //   }

// //   @override
// //   void dispose() {
// //     _videoController?.dispose();
// //     _audioController?.dispose();
// //     _youtubeExplode.close();
// //     super.dispose();
// //   }
// // }

// // class CustomYoutubePlayer extends StatefulWidget {
// //   final String videoUrl;
// //   final String name;

// //   const CustomYoutubePlayer({
// //     Key? key,
// //     required this.videoUrl,
// //     required this.name,
// //   }) : super(key: key);

// //   @override
// //   _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
// // }

// // class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
// //   VlcPlayerController? _controller;
// //   final YoutubeExplode _youtubeExplode = YoutubeExplode();

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializePlayer();
// //   }

// //   Future<void> _initializePlayer() async {
// //     try {
// //       var manifest = await _youtubeExplode.videos.streamsClient
// //           .getManifest(widget.videoUrl);

// //       var audioStream = manifest.audioOnly.withHighestBitrate();

// //       if (audioStream != null) {
// //         _controller = VlcPlayerController.network(
// //           audioStream.url.toString(),
// //           hwAcc: HwAcc.full,
// //           autoPlay: false,
// //         );
// //         setState(() {});
// //       }
// //     } catch (e) {
// //       print('Error initializing player: $e');
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     if (_controller == null) {
// //       return Center(child: CircularProgressIndicator());
// //     }

// //     return Column(
// //       children: [
// //         Container(
// //           height: 200,
// //           child: VlcPlayer(
// //             controller: _controller!,
// //             aspectRatio: 16 / 9,
// //             placeholder: Center(child: Text('Audio Player')),
// //           ),
// //         ),
// //         Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             IconButton(
// //               onPressed: () => _controller!.play(),
// //               icon: Icon(Icons.play_arrow),
// //             ),
// //             IconButton(
// //               onPressed: () => _controller!.pause(),
// //               icon: Icon(Icons.pause),
// //             ),
// //             IconButton(
// //               onPressed: () => _controller!.stop(),
// //               icon: Icon(Icons.stop),
// //             ),
// //           ],
// //         ),
// //       ],
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _controller?.dispose();
// //     _youtubeExplode.close();
// //     super.dispose();
// //   }
// // }

// // #############################################################################
// // ############################################################################

// // import 'package:mobi_tv_entertainment/main.dart';
// // import 'package:youtube_explode_dart/youtube_explode_dart.dart';
// // import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// // import 'package:flutter/material.dart';

// // class CustomYoutubePlayer extends StatefulWidget {
// //   final String videoUrl;
// //   final String? name;

// //   const CustomYoutubePlayer({
// //     Key? key,
// //     required this.videoUrl,
// //     required this.name,
// //   }) : super(key: key);

// //   @override
// //   _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
// // }

// // enum PlayerState { unknown, unstarted, ended, playing, paused, buffering, cued }

// // class _CustomYoutubePlayerState extends State<CustomYoutubePlayer>
// //     with TickerProviderStateMixin {
// //   VlcPlayerController? _videoController;
// //   VlcPlayerController? _audioController;
// //   final YoutubeExplode _youtubeExplode = YoutubeExplode();

// //   bool _isPlaying = false;
// //   bool _isInitialized = false;
// //   bool _isInitializing = false;
// //   bool _controllersCreated = false;
// //   Duration _currentPosition = Duration.zero;
// //   String? _errorMessage;
// //   String? _videoUrl;
// //   String? _audioUrl;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadStreamUrls();
// //   }

// //   Future<void> _loadStreamUrls() async {
// //     if (_isInitializing) return;

// //     if (!mounted) return;

// //     setState(() {
// //       _isInitializing = true;
// //       _errorMessage = null;
// //     });

// //     try {
// //       // Validate the video URL first
// //       if (widget.videoUrl.isEmpty) {
// //         throw Exception('Video URL is empty');
// //       }

// //       print('Loading streams for: ${widget.videoUrl}');

// //       // Try to get manifest with better error handling
// //       StreamManifest? manifest;
// //       try {
// //         manifest = await _youtubeExplode.videos.streamsClient
// //             .getManifest(widget.videoUrl);
// //       } catch (manifestError) {
// //         print('Manifest error: $manifestError');
// //         throw Exception('Failed to get video manifest: $manifestError');
// //       }

// //       if (manifest == null) {
// //         throw Exception('Could not get video manifest - manifest is null');
// //       }

// //       print('Manifest loaded successfully');

// //       // Get video-only streams with null safety
// //       var videoOnlyStreams = manifest.videoOnly;
// //       print('Found ${videoOnlyStreams?.length ?? 0} video-only streams');

// //       VideoOnlyStreamInfo? videoStream;
// //       if (videoOnlyStreams != null && videoOnlyStreams.isNotEmpty) {
// //         videoStream = videoOnlyStreams.first;
// //         print('Selected video stream: ${videoStream?.tag} - ${videoStream?.videoQuality}');
// //       }

// //       // Get audio-only streams with null safety
// //       var audioOnlyStreams = manifest.audioOnly;
// //       print('Found ${audioOnlyStreams?.length ?? 0} audio-only streams');

// //       AudioOnlyStreamInfo? audioStream;
// //       if (audioOnlyStreams != null && audioOnlyStreams.isNotEmpty) {
// //         audioStream = audioOnlyStreams.first;
// //         print('Selected audio stream: ${audioStream?.tag} - ${audioStream?.audioCodec}');
// //       }

// //       if (videoStream != null && audioStream != null) {
// //         // Validate stream URLs with comprehensive null checks
// //         String? videoUrl;
// //         String? audioUrl;

// //         try {
// //           videoUrl = videoStream.url?.toString();
// //           audioUrl = audioStream.url?.toString();
// //         } catch (urlError) {
// //           print('URL extraction error: $urlError');
// //           throw Exception('Failed to extract stream URLs: $urlError');
// //         }

// //         if (videoUrl == null || videoUrl.isEmpty) {
// //           throw Exception('Video stream URL is null or empty');
// //         }

// //         if (audioUrl == null || audioUrl.isEmpty) {
// //           throw Exception('Audio stream URL is null or empty');
// //         }

// //         print('Video URL loaded: ${videoUrl.length > 50 ? videoUrl.substring(0, 50) + "..." : videoUrl}');
// //         print('Audio URL loaded: ${audioUrl.length > 50 ? audioUrl.substring(0, 50) + "..." : audioUrl}');

// //         // Store URLs and create controllers
// //         _videoUrl = videoUrl;
// //         _audioUrl = audioUrl;

// //         if (mounted) {
// //           setState(() {
// //             _controllersCreated = true;
// //             _isInitializing = false;
// //           });

// //           // Wait for the VLC widgets to be created and auto-initialized
// //           WidgetsBinding.instance.addPostFrameCallback((_) {
// //             Future.delayed(Duration(milliseconds: 3000), () {
// //               if (mounted) {
// //                 _waitForAutoInitialization();
// //               }
// //             });
// //           });
// //         }
// //       } else {
// //         String missingStreams = '';
// //         if (videoStream == null) missingStreams += 'video ';
// //         if (audioStream == null) missingStreams += 'audio ';

// //         // Check if streams exist but are empty
// //         if (videoOnlyStreams?.isEmpty == true) {
// //           missingStreams += '(no video streams available) ';
// //         }
// //         if (audioOnlyStreams?.isEmpty == true) {
// //           missingStreams += '(no audio streams available) ';
// //         }

// //         if (mounted) {
// //           setState(() {
// //             _errorMessage = 'No $missingStreams streams found for this video. This video might be restricted or unavailable.';
// //             _isInitializing = false;
// //           });
// //         }
// //       }
// //     } catch (e) {
// //       print('Error loading streams: $e');
// //       print('Stack trace: ${StackTrace.current}');

// //       String errorMessage = 'Error loading video: ${e.toString()}';

// //       // Provide more specific error messages for common issues
// //       if (e.toString().contains('VideoUnavailableException')) {
// //         errorMessage = 'This video is unavailable or private';
// //       } else if (e.toString().contains('VideoRequiresPurchaseException')) {
// //         errorMessage = 'This video requires purchase';
// //       } else if (e.toString().contains('SocketException')) {
// //         errorMessage = 'Network error: Please check your internet connection';
// //       } else if (e.toString().contains('TimeoutException')) {
// //         errorMessage = 'Request timed out: Please try again';
// //       }

// //       if (mounted) {
// //         setState(() {
// //           _errorMessage = errorMessage;
// //           _isInitializing = false;
// //         });
// //       }
// //     }
// //   }

// //   void _createControllers() {
// //     if (_videoUrl == null || _audioUrl == null) return;

// //     try {
// //       print('Creating controllers...');

// //       // Create video controller with auto-initialization
// //       _videoController = VlcPlayerController.network(
// //         _videoUrl!,
// //         hwAcc: HwAcc.auto,
// //         autoPlay: false,
// //         autoInitialize: true, // Let VLC handle initialization automatically
// //         options: VlcPlayerOptions(
// //           advanced: VlcAdvancedOptions([
// //             VlcAdvancedOptions.networkCaching(2000),
// //           ]),
// //           audio: VlcAudioOptions([
// //             '--no-audio',
// //           ]),
// //           // others: [
// //           //   '--no-xlib',
// //           // ],
// //         ),
// //       );

// //       // Create audio controller with auto-initialization
// //       _audioController = VlcPlayerController.network(
// //         _audioUrl!,
// //         hwAcc: HwAcc.auto,
// //         autoPlay: false,
// //         autoInitialize: true, // Let VLC handle initialization automatically
// //         options: VlcPlayerOptions(
// //           advanced: VlcAdvancedOptions([
// //             VlcAdvancedOptions.networkCaching(2000),
// //           ]),
// //           video: VlcVideoOptions([
// //             '--no-video',
// //           ]),
// //           // others: [
// //           //   '--no-xlib',
// //           // ],
// //         ),
// //       );

// //       print('Controllers created successfully');
// //     } catch (e) {
// //       print('Error creating controllers: $e');
// //       if (mounted) {
// //         setState(() {
// //           _errorMessage = 'Failed to create video players: $e';
// //         });
// //       }
// //     }
// //   }

// //   Future<void> _waitForAutoInitialization() async {
// //     if (!mounted || _videoController == null || _audioController == null) {
// //       print('Cannot wait for initialization: widget not mounted or controllers null');
// //       return;
// //     }

// //     try {
// //       print('Waiting for auto-initialization of controllers...');

// //       setState(() {
// //         _isInitializing = true;
// //         _errorMessage = null;
// //       });

// //       // Wait for auto-initialization to complete
// //       int attempts = 0;
// //       const maxAttempts = 30; // 30 seconds maximum wait

// //       while (attempts < maxAttempts && mounted) {
// //         final videoInitialized = _videoController?.value.isInitialized ?? false;
// //         final audioInitialized = _audioController?.value.isInitialized ?? false;

// //         print('Auto-initialization check $attempts: video=$videoInitialized, audio=$audioInitialized');

// //         if (videoInitialized && audioInitialized) {
// //           print('Both controllers auto-initialized successfully');
// //           break;
// //         }

// //         await Future.delayed(Duration(seconds: 1));
// //         attempts++;
// //       }

// //       if (mounted) {
// //         // Final check
// //         final videoInitialized = _videoController?.value.isInitialized ?? false;
// //         final audioInitialized = _audioController?.value.isInitialized ?? false;

// //         if (videoInitialized && audioInitialized) {
// //           setState(() {
// //             _isInitialized = true;
// //             _isInitializing = false;
// //           });

// //           print('All controllers ready for playback');
// //           _setupSyncListeners();

// //           // Auto-play after initialization
// //           Future.delayed(Duration(milliseconds: 1000), () {
// //             if (mounted) {
// //               print('Starting auto-play...');
// //               _playBoth();
// //             }
// //           });
// //         } else {
// //           throw Exception('Controllers failed to auto-initialize: video=$videoInitialized, audio=$audioInitialized');
// //         }
// //       }

// //     } catch (e) {
// //       print('Auto-initialization wait error: $e');
// //       if (mounted) {
// //         setState(() {
// //           _errorMessage = 'Failed to initialize video players: $e';
// //           _isInitializing = false;
// //           _isInitialized = false;
// //         });
// //       }
// //     }
// //   }

// //   Future<void> _disposeControllers() async {
// //     try {
// //       if (_videoController != null) {
// //         print('Disposing video controller...');
// //         await _videoController?.dispose();
// //         _videoController = null;
// //         print('Video controller disposed');
// //       }
// //       if (_audioController != null) {
// //         print('Disposing audio controller...');
// //         await _audioController?.dispose();
// //         _audioController = null;
// //         print('Audio controller disposed');
// //       }
// //     } catch (e) {
// //       print('Error disposing controllers: $e');
// //       // Set to null anyway to prevent further issues
// //       _videoController = null;
// //       _audioController = null;
// //     }
// //   }

// //   void _setupSyncListeners() {
// //     // Only setup sync if properly initialized
// //     if (!_isInitialized || _videoController == null || _audioController == null) {
// //       return;
// //     }

// //     // Start sync after a longer delay to ensure controllers are ready
// //     Future.delayed(Duration(seconds: 2), () {
// //       if (mounted && _isInitialized && _videoController != null && _audioController != null) {
// //         // Check every 2 seconds instead of every second
// //         Stream.periodic(Duration(seconds: 2)).listen((_) async {
// //           if (mounted && _isInitialized && _videoController != null && _audioController != null) {
// //             try {
// //               // Check if controllers are initialized before calling getPosition
// //               final videoInitialized = _videoController?.value.isInitialized ?? false;
// //               final audioInitialized = _audioController?.value.isInitialized ?? false;

// //               if (videoInitialized && audioInitialized) {
// //                 final videoPosition = await _videoController?.getPosition() ?? Duration.zero;
// //                 final audioPosition = await _audioController?.getPosition() ?? Duration.zero;

// //                 // If positions are out of sync by more than 1 second, sync them
// //                 final diff = (videoPosition.inMilliseconds - audioPosition.inMilliseconds).abs();
// //                 if (diff > 1000) {
// //                   await _audioController?.seekTo(videoPosition);
// //                 }

// //                 if (mounted) {
// //                   setState(() {
// //                     _currentPosition = videoPosition;
// //                   });
// //                 }
// //               }
// //             } catch (e) {
// //               // Don't log sync errors too frequently
// //               // print('Sync error: $e');
// //             }
// //           }
// //         });
// //       }
// //     });
// //   }

// //   Future<void> _playBoth() async {
// //     if (!_isInitialized || _videoController == null || _audioController == null) {
// //       print('Cannot play: not initialized or controllers are null');
// //       return;
// //     }

// //     try {
// //       // Check if controllers are initialized before playing
// //       final videoInitialized = _videoController?.value.isInitialized ?? false;
// //       final audioInitialized = _audioController?.value.isInitialized ?? false;

// //       if (videoInitialized && audioInitialized) {
// //         print('Playing both controllers...');
// //         await Future.wait([
// //           _videoController?.play() ?? Future.value(),
// //           _audioController?.play() ?? Future.value(),
// //         ]);
// //         if (mounted) {
// //           setState(() => _isPlaying = true);
// //         }
// //         print('Both controllers playing');
// //       } else {
// //         print('Controllers not ready: video=$videoInitialized, audio=$audioInitialized');
// //       }
// //     } catch (e) {
// //       print('Error playing: $e');
// //     }
// //   }

// //   Future<void> _pauseBoth() async {
// //     if (!_isInitialized || _videoController == null || _audioController == null) {
// //       print('Cannot pause: not initialized or controllers are null');
// //       return;
// //     }

// //     try {
// //       final videoInitialized = _videoController?.value.isInitialized ?? false;
// //       final audioInitialized = _audioController?.value.isInitialized ?? false;

// //       if (videoInitialized && audioInitialized) {
// //         print('Pausing both controllers...');
// //         await Future.wait([
// //           _videoController?.pause() ?? Future.value(),
// //           _audioController?.pause() ?? Future.value(),
// //         ]);
// //         if (mounted) {
// //           setState(() => _isPlaying = false);
// //         }
// //         print('Both controllers paused');
// //       }
// //     } catch (e) {
// //       print('Error pausing: $e');
// //     }
// //   }

// //   Future<void> _seekBoth(Duration position) async {
// //     if (!_isInitialized || _videoController == null || _audioController == null) {
// //       print('Cannot seek: not initialized or controllers are null');
// //       return;
// //     }

// //     try {
// //       final videoInitialized = _videoController?.value.isInitialized ?? false;
// //       final audioInitialized = _audioController?.value.isInitialized ?? false;

// //       if (videoInitialized && audioInitialized) {
// //         print('Seeking both controllers to ${position.inSeconds}s...');
// //         await Future.wait([
// //           _videoController?.seekTo(position) ?? Future.value(),
// //           _audioController?.seekTo(position) ?? Future.value(),
// //         ]);
// //         print('Both controllers seeked');
// //       }
// //     } catch (e) {
// //       print('Error seeking: $e');
// //     }
// //   }

// //   Future<void> _stopBoth() async {
// //     if (!_isInitialized || _videoController == null || _audioController == null) {
// //       print('Cannot stop: not initialized or controllers are null');
// //       return;
// //     }

// //     try {
// //       final videoInitialized = _videoController?.value.isInitialized ?? false;
// //       final audioInitialized = _audioController?.value.isInitialized ?? false;

// //       if (videoInitialized && audioInitialized) {
// //         print('Stopping both controllers...');
// //         await Future.wait([
// //           _videoController?.stop() ?? Future.value(),
// //           _audioController?.stop() ?? Future.value(),
// //         ]);
// //         if (mounted) {
// //           setState(() => _isPlaying = false);
// //         }
// //         print('Both controllers stopped');
// //       }
// //     } catch (e) {
// //       print('Error stopping: $e');
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Show error if any
// //     if (_errorMessage != null) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(Icons.error, size: 48, color: Colors.red),
// //             SizedBox(height: 16),
// //             Text(
// //               _errorMessage!,
// //               style: TextStyle(color: Colors.red),
// //               textAlign: TextAlign.center,
// //             ),
// //             SizedBox(height: 16),
// //             ElevatedButton(
// //               onPressed: () {
// //                 setState(() {
// //                   _errorMessage = null;
// //                   _isInitialized = false;
// //                   _isInitializing = false;
// //                   _controllersCreated = false;
// //                   _videoUrl = null;
// //                   _audioUrl = null;
// //                 });
// //                 _disposeControllers().then((_) {
// //                   _loadStreamUrls();
// //                 });
// //               },
// //               child: Text('Retry'),
// //             ),
// //           ],
// //         ),
// //       );
// //     }

// //     // Show loading if not ready
// //     if (!_controllersCreated || (_isInitializing && !_isInitialized)) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             CircularProgressIndicator(),
// //             SizedBox(height: 16),
// //             Text(!_controllersCreated
// //               ? 'Loading YouTube video streams...'
// //               : 'Initializing video players...'),
// //           ],
// //         ),
// //       );
// //     }

// //     // Create controllers when URLs are ready but controllers don't exist yet
// //     if (_controllersCreated && _videoController == null && _audioController == null) {
// //       _createControllers();
// //     }

// //     return Column(
// //       children: [
// //         // Video Info
// //         // if (widget.name != null)
// //         //   Padding(
// //         //     padding: const EdgeInsets.all(8.0),
// //         //     child: Text(
// //         //       widget.name!,
// //         //       style: Theme.of(context).textTheme.titleMedium,
// //         //       textAlign: TextAlign.center,
// //         //     ),
// //         //   ),

// //         // Video player (visible)
// //         Container(
// //           height: screenhgt,
// //           decoration: BoxDecoration(
// //             color: Colors.black,
// //             borderRadius: BorderRadius.circular(8),
// //           ),
// //           child: ClipRRect(
// //             borderRadius: BorderRadius.circular(8),
// //             child: _videoController != null ? VlcPlayer(
// //               controller: _videoController!,
// //               aspectRatio: 16 / 9,
// //               placeholder: const Center(
// //                 child: Text(
// //                   'Loading Video...',
// //                   style: TextStyle(color: Colors.white),
// //                 ),
// //               ),
// //             ) : Container(
// //               color: Colors.black,
// //               child: const Center(
// //                 child: CircularProgressIndicator(),
// //               ),
// //             ),
// //           ),
// //         ),

// //         // Audio player (hidden - केवल audio के लिए)
// //         if (_audioController != null)
// //           Offstage(
// //             offstage: true,
// //             child: Container(
// //               height: 1,
// //               width: 1,
// //               child: VlcPlayer(
// //                 controller: _audioController!,
// //                 aspectRatio: 1,
// //               ),
// //             ),
// //           ),

// //         // // Position indicator
// //         // Padding(
// //         //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
// //         //   child: Text(
// //         //     'Position: ${_formatDuration(_currentPosition)}',
// //         //     style: Theme.of(context).textTheme.bodySmall,
// //         //   ),
// //         // ),

// //         // // Controls
// //         // Padding(
// //         //   padding: const EdgeInsets.all(8.0),
// //         //   child: Row(
// //         //     mainAxisAlignment: MainAxisAlignment.center,
// //         //     children: [
// //         //       IconButton(
// //         //         onPressed: _isInitialized ? () => _seekBoth(Duration.zero) : null,
// //         //         icon: const Icon(Icons.replay),
// //         //         tooltip: 'Restart',
// //         //       ),
// //         //       const SizedBox(width: 16),
// //         //       IconButton(
// //         //         onPressed: _isInitialized ? (_isPlaying ? _pauseBoth : _playBoth) : null,
// //         //         icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
// //         //         iconSize: 32,
// //         //         tooltip: _isPlaying ? 'Pause' : 'Play',
// //         //       ),
// //         //       const SizedBox(width: 16),
// //         //       IconButton(
// //         //         onPressed: _isInitialized ? _stopBoth : null,
// //         //         icon: const Icon(Icons.stop),
// //         //         tooltip: 'Stop',
// //         //       ),
// //         //     ],
// //         //   ),
// //         // ),
// //       ],
// //     );
// //   }

// //   String _formatDuration(Duration duration) {
// //     String twoDigits(int n) => n.toString().padLeft(2, "0");
// //     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
// //     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
// //     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
// //   }

// //   @override
// //   void dispose() async {
// //     print('Disposing CustomYoutubePlayer...');
// //     try {
// //       await _disposeControllers();
// //       _youtubeExplode.close();
// //     } catch (e) {
// //       print('Error in dispose: $e');
// //     }
// //     super.dispose();
// //   }
// // }

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:webview_flutter/webview_flutter.dart';
// // import 'dart:io';

// // class CustomYoutubePlayer extends StatefulWidget {
// //   final String videoUrl;
// //   final String name;

// //   CustomYoutubePlayer({required this.videoUrl, required this.name});

// //   @override
// //   _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
// // }

// // class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
// //   late WebViewController controller;
// //   bool isLoading = true;
// //   bool hasError = false;
// //   String errorMessage = '';
// //   bool isMuted = true;
// //   bool showUnmuteButton = false;
// //   final FocusNode _focusNode = FocusNode();

// //   String extractVideoId(String url) {
// //     List<RegExp> patterns = [
// //       RegExp(r"(?:youtube\.com\/watch\?v=)([a-zA-Z0-9_-]{11})"),
// //       RegExp(r"(?:youtu\.be\/)([a-zA-Z0-9_-]{11})"),
// //       RegExp(r"(?:youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})"),
// //     ];

// //     for (RegExp pattern in patterns) {
// //       Match? match = pattern.firstMatch(url);
// //       if (match != null && match.group(1) != null) {
// //         return match.group(1)!;
// //       }
// //     }

// //     if (url.length == 11 && RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(url)) {
// //       return url;
// //     }

// //     return url;
// //   }

// //   @override
// //   void initState() {
// //     super.initState();
// //     initializeWebView();
// //     // Auto-focus for remote control
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _focusNode.requestFocus();
// //     });
// //   }

// //   void _handleRemoteKey(RawKeyEvent event) {
// //     if (event is RawKeyDownEvent) {
// //       // Handle different arrow keys
// //       if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
// //           event.logicalKey == LogicalKeyboardKey.arrowDown ||
// //           event.logicalKey == LogicalKeyboardKey.arrowLeft ||
// //           event.logicalKey == LogicalKeyboardKey.arrowRight ||
// //           event.logicalKey == LogicalKeyboardKey.select ||
// //           event.logicalKey == LogicalKeyboardKey.enter) {

// //         print('🎮 Remote key pressed: ${event.logicalKey}');
// //         _unmuteVideo();
// //       }
// //     }
// //   }

// //   void _unmuteVideo() {
// //     if (isMuted) {
// //       // Enhanced JavaScript function to unmute and ensure video keeps playing
// //       controller.runJavaScript('''
// //         if (typeof player !== 'undefined' && player && isPlayerReady) {
// //           try {
// //             // First unmute the video
// //             player.unMute();

// //             // Ensure video is playing
// //             var currentState = player.getPlayerState();
// //             if (currentState !== 1) { // 1 = YT.PlayerState.PLAYING
// //               player.playVideo();
// //             }

// //             // Set volume to reasonable level
// //             player.setVolume(50);

// //             console.log('🔊 Video unmuted and playing, state:', currentState);
// //             isMuted = false;

// //             // Notify Flutter
// //             if (window.Flutter && window.Flutter.postMessage) {
// //               window.Flutter.postMessage('videoUnmuted');
// //             }
// //           } catch (e) {
// //             console.error('Error unmuting:', e);
// //           }
// //         }
// //       ''');

// //       setState(() {
// //         isMuted = false;
// //         showUnmuteButton = false;
// //       });

// //       // Show success message temporarily
// //       Future.delayed(Duration(seconds: 2), () {
// //         if (mounted) {
// //           setState(() {
// //             // Keep the state as unmuted
// //           });
// //         }
// //       });

// //       print('🔊 Video unmuted via remote');
// //     }
// //   }

// //   void initializeWebView() {
// //     try {
// //       String videoId = extractVideoId(widget.videoUrl);

// //       // HTML with aggressive autoplay
// //       String htmlContent = '''
// //       <!DOCTYPE html>
// //       <html>
// //       <head>
// //           <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
// //           <style>
// //               * {
// //                   margin: 0;
// //                   padding: 0;
// //                   box-sizing: border-box;
// //               }
// //               html, body {
// //                   height: 100%;
// //                   background: #000;
// //                   overflow: hidden;
// //               }
// //               .container {
// //                   position: relative;
// //                   width: 100vw;
// //                   height: 100vh;
// //                   background: #000;
// //               }
// //               #player {
// //                   width: 100%;
// //                   height: 100%;
// //                   background: #000;
// //               }
// //               .loading {
// //                   position: absolute;
// //                   top: 50%;
// //                   left: 50%;
// //                   transform: translate(-50%, -50%);
// //                   color: white;
// //                   text-align: center;
// //               }
// //           </style>
// //       </head>
// //       <body>
// //           <div class="container">
// //               <div id="loading" class="loading">
// //                   <div>🎥 Starting autoplay...</div>
// //               </div>
// //               <div id="player"></div>
// //           </div>

// //           <script>
// //               var player;
// //               var isPlayerReady = false;
// //               var isMuted = true;

// //               // Load YouTube API
// //               function loadYouTubeAPI() {
// //                   var tag = document.createElement('script');
// //                   tag.src = "https://www.youtube.com/iframe_api";
// //                   var firstScriptTag = document.getElementsByTagName('script')[0];
// //                   firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
// //               }

// //               // YouTube API ready callback
// //               function onYouTubeIframeAPIReady() {
// //                   console.log('YouTube API Ready - Initializing Player');
// //                   createPlayer();
// //               }

// //               function createPlayer() {
// //                   player = new YT.Player('player', {
// //                       height: '100%',
// //                       width: '100%',
// //                       videoId: '$videoId',
// //                       host: 'https://www.youtube-nocookie.com',
// //                       playerVars: {
// //                           'autoplay': 1,        // Enable autoplay
// //                           'mute': 1,            // Muted autoplay (browsers allow this)
// //                           'playsinline': 1,
// //                           'controls': 1,
// //                           'rel': 0,
// //                           'modestbranding': 1,
// //                           'iv_load_policy': 3,
// //                           'fs': 1,
// //                           'enablejsapi': 1,
// //                           'start': 0,
// //                           'loop': 0,
// //                           'cc_load_policy': 0,
// //                           'origin': window.location.origin,
// //                           'widget_referrer': window.location.origin
// //                       },
// //                       events: {
// //                           'onReady': onPlayerReady,
// //                           'onStateChange': onPlayerStateChange,
// //                           'onError': onPlayerError
// //                       }
// //                   });
// //               }

// //               function onPlayerReady(event) {
// //                   console.log('✅ Player Ready - Starting Autoplay');
// //                   isPlayerReady = true;
// //                   document.getElementById('loading').style.display = 'none';

// //                   // Aggressive autoplay attempts
// //                   setTimeout(() => {
// //                       try {
// //                           event.target.mute();  // Ensure muted
// //                           event.target.playVideo();  // Force play
// //                           console.log('🎬 Autoplay started (muted)');
// //                           // Notify Flutter that video is ready and muted
// //                           if (window.Flutter && window.Flutter.postMessage) {
// //                               window.Flutter.postMessage('videoReady');
// //                           }
// //                       } catch (e) {
// //                           console.log('Autoplay failed:', e);
// //                           // Fallback: try again after short delay
// //                           setTimeout(() => {
// //                               event.target.playVideo();
// //                           }, 500);
// //                       }
// //                   }, 100);
// //               }

// //               function onPlayerStateChange(event) {
// //                   console.log('Player state:', event.data);

// //                   if (event.data == YT.PlayerState.PLAYING) {
// //                       console.log('✅ Video is playing');
// //                       // Notify Flutter that video is playing
// //                       if (window.Flutter && window.Flutter.postMessage) {
// //                           window.Flutter.postMessage('videoPlaying');
// //                       }
// //                   } else if (event.data == YT.PlayerState.PAUSED) {
// //                       console.log('⏸️ Video paused');
// //                       // Auto-resume if video was paused unexpectedly and we're unmuted
// //                       if (!isMuted) {
// //                           setTimeout(() => {
// //                               if (player && player.getPlayerState() === YT.PlayerState.PAUSED) {
// //                                   player.playVideo();
// //                                   console.log('🔄 Auto-resumed paused video');
// //                               }
// //                           }, 500);
// //                       }
// //                   } else if (event.data == YT.PlayerState.BUFFERING) {
// //                       console.log('⏳ Video buffering');
// //                   } else if (event.data == YT.PlayerState.ENDED) {
// //                       console.log('🏁 Video ended');
// //                   }
// //               }

// //               function onPlayerError(event) {
// //                   console.error('❌ Player error:', event.data);
// //                   var errorMessage = '';
// //                   var shouldRetry = false;

// //                   switch(event.data) {
// //                       case 2:
// //                           errorMessage = 'Invalid video ID';
// //                           break;
// //                       case 5:
// //                           errorMessage = 'HTML5 player error';
// //                           shouldRetry = true;
// //                           break;
// //                       case 100:
// //                           errorMessage = 'Video not found or private';
// //                           break;
// //                       case 101:
// //                       case 150:
// //                           errorMessage = 'Embed restricted by video owner';
// //                           shouldRetry = true;
// //                           break;
// //                       default:
// //                           errorMessage = 'Unknown error: ' + event.data;
// //                           shouldRetry = true;
// //                   }

// //                   console.log('Error details:', errorMessage);

// //                   // Try to recover from embed restrictions
// //                   if (shouldRetry && (event.data === 150 || event.data === 101)) {
// //                       console.log('🔄 Attempting to bypass embed restrictions...');

// //                       // Try alternative embed parameters
// //                       setTimeout(() => {
// //                           if (player && typeof player.destroy === 'function') {
// //                               player.destroy();
// //                           }

// //                           // Recreate player with different parameters
// //                           player = new YT.Player('player', {
// //                               height: '100%',
// //                               width: '100%',
// //                               videoId: '$videoId',
// //                               playerVars: {
// //                                   'autoplay': 1,
// //                                   'mute': 1,
// //                                   'playsinline': 1,
// //                                   'controls': 1,
// //                                   'rel': 0,
// //                                   'modestbranding': 1,
// //                                   'iv_load_policy': 3,
// //                                   'fs': 1,
// //                                   'enablejsapi': 1,
// //                                   'origin': window.location.origin,
// //                                   'widget_referrer': window.location.origin,
// //                                   'cc_load_policy': 0,
// //                                   'hl': 'en',
// //                                   'cc_lang_pref': 'en'
// //                               },
// //                               events: {
// //                                   'onReady': onPlayerReady,
// //                                   'onStateChange': onPlayerStateChange,
// //                                   'onError': function(err) {
// //                                       console.error('❌ Retry failed:', err.data);
// //                                       document.getElementById('loading').innerHTML =
// //                                           '<div style="color: red;">Video embed restricted<br/>Error: ' + err.data + '</div>';
// //                                   }
// //                               }
// //                           });
// //                       }, 1000);
// //                   } else {
// //                       document.getElementById('loading').innerHTML =
// //                           '<div style="color: red;">Error: ' + errorMessage + '</div>';
// //                   }
// //               }

// //               function unmuteVideo() {
// //                   if (isPlayerReady && player) {
// //                       try {
// //                           // Unmute the video
// //                           player.unMute();

// //                           // Ensure video continues playing
// //                           var currentState = player.getPlayerState();
// //                           if (currentState !== 1) { // 1 = YT.PlayerState.PLAYING
// //                               player.playVideo();
// //                           }

// //                           // Set volume to audible level
// //                           player.setVolume(70);

// //                           isMuted = false;
// //                           console.log('🔊 Video unmuted and playing, state:', currentState);

// //                           // Notify Flutter that video is unmuted
// //                           if (window.Flutter && window.Flutter.postMessage) {
// //                               window.Flutter.postMessage('videoUnmuted');
// //                           }
// //                       } catch (error) {
// //                           console.error('Error in unmuteVideo:', error);
// //                       }
// //                   }
// //               }

// //               // Additional autoplay triggers
// //               document.addEventListener('DOMContentLoaded', function() {
// //                   loadYouTubeAPI();
// //               });

// //               // Visibility change handler (when user comes back to tab)
// //               document.addEventListener('visibilitychange', function() {
// //                   if (!document.hidden && isPlayerReady && player) {
// //                       setTimeout(() => {
// //                           var state = player.getPlayerState();
// //                           if (state !== YT.PlayerState.PLAYING) {
// //                               player.playVideo();
// //                           }
// //                       }, 200);
// //                   }
// //               });

// //               // Start loading
// //               if (document.readyState === 'loading') {
// //                   document.addEventListener('DOMContentLoaded', loadYouTubeAPI);
// //               } else {
// //                   loadYouTubeAPI();
// //               }
// //           </script>
// //       </body>
// //       </html>
// //       ''';

// //       controller = WebViewController()
// //         ..setJavaScriptMode(JavaScriptMode.unrestricted)
// //         ..setBackgroundColor(Colors.black)
// //         ..enableZoom(false);

// //       // Add JavaScript channel for communication
// //       controller.addJavaScriptChannel(
// //         'Flutter',
// //         onMessageReceived: (JavaScriptMessage message) {
// //           print('Message from WebView: ${message.message}');
// //           if (message.message == 'videoReady' || message.message == 'videoPlaying') {
// //             setState(() {
// //               showUnmuteButton = isMuted;
// //             });
// //           } else if (message.message == 'videoUnmuted') {
// //             setState(() {
// //               isMuted = false;
// //               showUnmuteButton = false;
// //             });
// //           }
// //         },
// //       );

// //       if (Platform.isAndroid) {
// //         controller
// //           ..setUserAgent('Mozilla/5.0 (Smart-TV; Linux; Tizen 6.0) AppleWebKit/537.36 (KHTML, like Gecko) 85.0.4183.87/6.0 TV Safari/537.36')
// //           ..setNavigationDelegate(
// //             NavigationDelegate(
// //               onPageStarted: (String url) {
// //                 print('📄 Starting autoplay page load');
// //                 setState(() {
// //                   isLoading = true;
// //                   hasError = false;
// //                 });
// //               },
// //               onPageFinished: (String url) {
// //                 print('✅ Autoplay page loaded');
// //                 setState(() {
// //                   isLoading = false;
// //                 });

// //                 // Additional autoplay trigger after page load
// //                 Future.delayed(Duration(milliseconds: 1500), () {
// //                   controller.runJavaScript('''
// //                     if (typeof player !== 'undefined' && player && player.playVideo) {
// //                       player.mute();
// //                       player.playVideo();
// //                       console.log('🎬 Triggered autoplay after page load');
// //                     }
// //                   ''');

// //                   // Show unmute button after video starts
// //                   setState(() {
// //                     showUnmuteButton = true;
// //                   });
// //                 });
// //               },
// //               onWebResourceError: (WebResourceError error) {
// //                 print('❌ Autoplay error: ${error.description}');
// //                 setState(() {
// //                   isLoading = false;
// //                   hasError = true;
// //                   errorMessage = error.description;
// //                 });
// //               },
// //             ),
// //           );
// //       }

// //       controller.loadHtmlString(htmlContent);

// //     } catch (e) {
// //       setState(() {
// //         hasError = true;
// //         errorMessage = 'Failed to initialize: $e';
// //         isLoading = false;
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return RawKeyboardListener(
// //       focusNode: _focusNode,
// //       onKey: _handleRemoteKey,
// //       autofocus: true,
// //       child: Scaffold(
// //         backgroundColor: Colors.black,
// //         body: Container(
// //           color: Colors.black,
// //           child: Stack(
// //             children: [
// //               if (!hasError)
// //                 WebViewWidget(controller: controller),

// //               if (hasError)
// //                 Center(
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(Icons.error_outline, size: 64, color: Colors.red),
// //                       SizedBox(height: 16),
// //                       Text(
// //                         'Autoplay Failed',
// //                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
// //                       ),
// //                       SizedBox(height: 8),
// //                       Text(errorMessage, style: TextStyle(color: Colors.white70)),
// //                       SizedBox(height: 16),
// //                       ElevatedButton(
// //                         onPressed: initializeWebView,
// //                         child: Text('Try Again'),
// //                         style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
// //                       ),
// //                     ],
// //                   ),
// //                 ),

// //               if (isLoading && !hasError)
// //                 Container(
// //                   color: Colors.black87,
// //                   child: Center(
// //                     child: Column(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         CircularProgressIndicator(color: Colors.red),
// //                         SizedBox(height: 16),
// //                         Text('🎬 Preparing autoplay...', style: TextStyle(color: Colors.white)),
// //                       ],
// //                     ),
// //                   ),
// //                 ),

// //               // Unmute Button Overlay
// //               if (showUnmuteButton && isMuted)
// //                 Positioned(
// //                   top: 50,
// //                   left: 0,
// //                   right: 0,
// //                   child: Center(
// //                     child: Container(
// //                       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
// //                       decoration: BoxDecoration(
// //                         color: Colors.black.withOpacity(0.8),
// //                         borderRadius: BorderRadius.circular(25),
// //                         border: Border.all(color: Colors.red, width: 2),
// //                       ),
// //                       child: Row(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: [
// //                           Icon(Icons.volume_off, color: Colors.red, size: 24),
// //                           SizedBox(width: 8),
// //                           Text(
// //                             'Press any arrow key to unmute',
// //                             style: TextStyle(
// //                               color: Colors.white,
// //                               fontSize: 16,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                           SizedBox(width: 8),
// //                           Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 20),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),

// //               // Success message when unmuted
// //               if (!isMuted && !showUnmuteButton)
// //                 Positioned(
// //                   top: 50,
// //                   left: 0,
// //                   right: 0,
// //                   child: Center(
// //                     child: AnimatedContainer(
// //                       duration: Duration(milliseconds: 300),
// //                       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
// //                       decoration: BoxDecoration(
// //                         color: Colors.green.withOpacity(0.9),
// //                         borderRadius: BorderRadius.circular(20),
// //                       ),
// //                       child: Row(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: [
// //                           Icon(Icons.volume_up, color: Colors.white, size: 20),
// //                           SizedBox(width: 8),
// //                           Text(
// //                             'Video Unmuted!',
// //                             style: TextStyle(
// //                               color: Colors.white,
// //                               fontSize: 14,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _focusNode.dispose();
// //     super.dispose();
// //   }
// // }

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

//   // Different TV User Agents for rotation
//   final List<String> _tvUserAgents = [
//     'Mozilla/5.0 (Smart TV; Linux; Tizen 6.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.31 Safari/537.36',
//     'Mozilla/5.0 (SMART-TV; Linux; Tizen 5.5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.93 Safari/537.36',
//     'Mozilla/5.0 (Web0S; Linux/SmartTV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36',
//     'Mozilla/5.0 (Linux; Android 9; SHIELD Android TV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.164 Safari/537.36',
//     'SmartTV/1.0 (Linux; Android TV 9)',
//     'HbbTV/1.1.1 (;LG;42LM620S-ZA;04.25.05;0x00000001;)',
//     'Mozilla/5.0 (Unknown; Linux armv7l) AppleWebKit/537.1+ (KHTML, like Gecko) Safari/537.1+ HbbTV/1.1.1 ( ;LG ;NetCast 4.0 ;04.00.00 ;1920x1080 ;)',
//   ];

//   int _currentUserAgentIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _loadStreamUrls();
//   }

//   String _getCurrentUserAgent() {
//     return _tvUserAgents[_currentUserAgentIndex % _tvUserAgents.length];
//   }

//   void _rotateUserAgent() {
//     _currentUserAgentIndex = (_currentUserAgentIndex + 1) % _tvUserAgents.length;
//     print('Rotating to user agent: ${_getCurrentUserAgent()}');
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
//       print('Using user agent: ${_getCurrentUserAgent()}');

//       // Try to get manifest with better error handling
//       StreamManifest? manifest;
//       try {
//         manifest = await _youtubeExplode.videos.streamsClient
//             .getManifest(widget.videoUrl);
//       } catch (manifestError) {
//         print('Manifest error: $manifestError');

//         // Try with different user agent
//         _rotateUserAgent();
//         print('Retrying with different user agent...');

//         try {
//           manifest = await _youtubeExplode.videos.streamsClient
//               .getManifest(widget.videoUrl);
//         } catch (retryError) {
//           throw Exception('Failed to get video manifest after retry: $retryError');
//         }
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
//         // Try to get best quality available - prefer HD quality
//         videoStream = videoOnlyStreams.where((s) => s.videoQuality.name.contains('720p') || s.videoQuality.name.contains('hd720')).isNotEmpty
//             ? videoOnlyStreams.where((s) => s.videoQuality.name.contains('720p') || s.videoQuality.name.contains('hd720')).first
//             : videoOnlyStreams.first;
//         print('Selected video stream: ${videoStream?.tag} - ${videoStream?.videoQuality.name}');
//       }

//       // Get audio-only streams with null safety
//       var audioOnlyStreams = manifest.audioOnly;
//       print('Found ${audioOnlyStreams?.length ?? 0} audio-only streams');

//       AudioOnlyStreamInfo? audioStream;
//       if (audioOnlyStreams != null && audioOnlyStreams.isNotEmpty) {
//         // Get best audio quality
//         audioStream = audioOnlyStreams.where((s) => s.bitrate.bitsPerSecond > 128000).isNotEmpty
//             ? audioOnlyStreams.where((s) => s.bitrate.bitsPerSecond > 128000).first
//             : audioOnlyStreams.first;
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
//       } else if (e.toString().contains('403')) {
//         errorMessage = 'Access forbidden: Video may be geo-restricted or blocked';
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
//       print('Creating controllers with TV user agent...');
//       print('Current user agent: ${_getCurrentUserAgent()}');

//       // Create video controller with enhanced options
//       _videoController = VlcPlayerController.network(
//         _videoUrl!,
//         hwAcc: HwAcc.auto,
//         autoPlay: false,
//         autoInitialize: true,
//         options: VlcPlayerOptions(
//           advanced: VlcAdvancedOptions([
//             VlcAdvancedOptions.networkCaching(5000),
//             VlcAdvancedOptions.liveCaching(5000),
//             '--http-user-agent=${_getCurrentUserAgent()}',
//             '--http-referrer=https://www.youtube.com/',
//             '--http-reconnect',
//             '--no-stats',
//             '--intf=dummy',
//             '--sout-keep',
//             '--avcodec-hw=any',
//           ]),
//           audio: VlcAudioOptions([
//             '--no-audio',
//           ]),
//           video: VlcVideoOptions([
//             '--avcodec-hw=any',
//           ]),
//         ),
//       );

//       // Create audio controller with enhanced options
//       _audioController = VlcPlayerController.network(
//         _audioUrl!,
//         hwAcc: HwAcc.auto,
//         autoPlay: false,
//         autoInitialize: true,
//         options: VlcPlayerOptions(
//           advanced: VlcAdvancedOptions([
//             VlcAdvancedOptions.networkCaching(5000),
//             VlcAdvancedOptions.liveCaching(5000),
//             '--http-user-agent=${_getCurrentUserAgent()}',
//             '--http-referrer=https://www.youtube.com/',
//             '--http-reconnect',
//             '--no-stats',
//             '--intf=dummy',
//             '--sout-keep',
//           ]),
//           video: VlcVideoOptions([
//             '--no-video',
//           ]),
//           audio: VlcAudioOptions([
//             '--aout=any',
//           ]),
//         ),
//       );

//       print('Controllers created successfully with TV user agent');
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
//       const maxAttempts = 20; // 40 seconds maximum wait (increased for TV)

//       while (attempts < maxAttempts && mounted) {
//         final videoInitialized = _videoController?.value.isInitialized ?? false;
//         final audioInitialized = _audioController?.value.isInitialized ?? false;

//         print('Auto-initialization check $attempts: video=$videoInitialized, audio=$audioInitialized');

//         if (videoInitialized && audioInitialized) {
//           print('Both controllers auto-initialized successfully');
//           break;
//         }

//         await Future.delayed(Duration(seconds: 2));
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
//           Future.delayed(Duration(milliseconds: 1500), () {
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
//     Future.delayed(Duration(seconds: 3), () {
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

//   // Retry with different user agent
//   Future<void> _retryWithDifferentUserAgent() async {
//     _rotateUserAgent();
//     setState(() {
//       _errorMessage = null;
//       _isInitialized = false;
//       _isInitializing = false;
//       _controllersCreated = false;
//       _videoUrl = null;
//       _audioUrl = null;
//     });
//     await _disposeControllers();
//     _loadStreamUrls();
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
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       _errorMessage = null;
//                       _isInitialized = false;
//                       _isInitializing = false;
//                       _controllersCreated = false;
//                       _videoUrl = null;
//                       _audioUrl = null;
//                     });
//                     _disposeControllers().then((_) {
//                       _loadStreamUrls();
//                     });
//                   },
//                   child: Text('Retry'),
//                 ),
//                 // SizedBox(width: 16),
//                 // ElevatedButton(
//                 //   onPressed: _retryWithDifferentUserAgent,
//                 //   child: Text('Try Different Agent'),
//                 // ),
//               ],
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Current User Agent: ${_getCurrentUserAgent().substring(0, 30)}...',
//               style: TextStyle(fontSize: 10, color: Colors.grey),
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
//             SizedBox(height: 8),
//             Text(
//               'Using: ${_getCurrentUserAgent().substring(0, 40)}...',
//               style: TextStyle(fontSize: 10, color: Colors.grey),
//               textAlign: TextAlign.center,
//             ),
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

//         // Debug info (remove in production)
//         // Padding(
//         //   padding: const EdgeInsets.all(8.0),
//         //   child: Text(
//         //     'User Agent: ${_getCurrentUserAgent()}',
//         //     style: TextStyle(fontSize: 8, color: Colors.grey),
//         //     textAlign: TextAlign.center,
//         //   ),
//         // ),

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
//         //       const SizedBox(width: 16),
//         //       IconButton(
//         //         onPressed: _retryWithDifferentUserAgent,
//         //         icon: const Icon(Icons.refresh),
//         //         tooltip: 'Try Different User Agent',
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

// ################ youtube most reliable code ###########

// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:youtube_explode_dart/youtube_explode_dart.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:keep_screen_on/keep_screen_on.dart';

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
//     with TickerProviderStateMixin, WidgetsBindingObserver {
//   VlcPlayerController? _playerController;
//   VlcPlayerController? _audioController;
//   final YoutubeExplode _youtubeExplode = YoutubeExplode();

//   bool _isPlaying = false;
//   bool _isInitialized = false;
//   bool _isInitializing = false;
//   bool _controllerCreated = false;
//   bool _useDualStream = false;
//   bool _isDisposed = false;
//   bool _isDisposing = false; // Add disposing flag
//   Duration _currentPosition = Duration.zero;
//   String? _errorMessage;
//   String? _videoStreamUrl;
//   String? _audioStreamUrl;

//   // Stream subscriptions for proper cleanup
//   StreamSubscription? _syncSubscription;
//   Timer? _initializationTimer;
//   Timer? _autoPlayTimer;

//   // Add completer for safe disposal
//   Completer<void>? _disposalCompleter;

//   // Enhanced TV User Agents with better success rates
//   final List<String> _tvUserAgents = [
//     // High success rate agents (real device signatures)
//     'Mozilla/5.0 (SMART-TV; Linux; Tizen 7.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36',
//     'Mozilla/5.0 (Web0S; Linux/SmartTV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 webOS/6.0',
//     'Mozilla/5.0 (Linux; Android 11; SHIELD Android TV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Safari/537.36',
//     'Mozilla/5.0 (X11; Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chromium/90.0.4430.225 Chrome/90.0.4430.225 Safari/537.36',

//     // Fallback mobile agents (often less blocked)
//     'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
//     'Mozilla/5.0 (iPad; CPU OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
//     'Mozilla/5.0 (Linux; Android 11; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Mobile Safari/537.36',

//     // Desktop agents as last resort
//     'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Safari/537.36',
//     'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Safari/537.36',
//   ];

//   int _currentUserAgentIndex = 0;
//   int _failedAttempts = 0;
//   final int _maxFailedAttempts = 3;
//   DateTime? _lastRequestTime;
//   final Duration _requestDelay = Duration(seconds: 2); // Rate limiting

//   @override
//   void initState() {
//     super.initState();
//     // Add lifecycle observer to handle app state changes
//     WidgetsBinding.instance.addObserver(this);
//     _loadStreamUrls();
//     KeepScreenOn.turnOn();
//   }

//   // Handle app lifecycle changes to prevent crashes
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);

//     switch (state) {
//       case AppLifecycleState.paused:
//       case AppLifecycleState.detached:
//         print('App paused/detached - stopping players safely');
//         _stopPlayersForBackground();
//         break;
//       case AppLifecycleState.resumed:
//         print('App resumed');
//         break;
//       default:
//         break;
//     }
//   }

//   // Stop players when app goes to background
//   void _stopPlayersForBackground() {
//     if (_isDisposed || _isDisposing) return;

//     try {
//       _playerController?.pause();
//       _audioController?.pause();
//       setState(() {
//         _isPlaying = false;
//       });
//     } catch (e) {
//       print('Error stopping players for background: $e');
//     }
//   }

//   // Override the back button behavior
//   Future<bool> _onWillPop() async {
//     print('Back button pressed - initiating safe disposal');

//     if (_isDisposing || _isDisposed) {
//       return true; // Allow navigation if already disposing
//     }

//     // Start safe disposal process
//     _startSafeDisposal();

//     // Allow immediate navigation without waiting for disposal
//     return true;
//   }

//   void _startSafeDisposal() {
//     if (_isDisposing || _isDisposed) return;

//     print('Starting safe disposal process...');
//     _isDisposing = true;

//     // Cancel all timers immediately
//     _cancelAllTimers();

//     // Stop all async operations
//     _syncSubscription?.cancel();

//     // Dispose controllers in background without blocking UI
//     _disposeControllersInBackground();
//   }

//   void _cancelAllTimers() {
//     try {
//       _initializationTimer?.cancel();
//       _initializationTimer = null;

//       _autoPlayTimer?.cancel();
//       _autoPlayTimer = null;

//       _syncSubscription?.cancel();
//       _syncSubscription = null;

//       print('All timers cancelled');
//     } catch (e) {
//       print('Error cancelling timers: $e');
//     }
//   }

//   void _disposeControllersInBackground() {
//     // Run disposal in background without affecting UI navigation
//     Future.microtask(() async {
//       try {
//         print('Background controller disposal started');

//         // First stop playback
//         if (_playerController != null) {
//           try {
//             await _playerController?.stop().timeout(Duration(seconds: 2));
//             print('Video controller stopped');
//           } catch (e) {
//             print('Video controller stop timeout/error: $e');
//           }
//         }

//         if (_audioController != null) {
//           try {
//             await _audioController?.stop().timeout(Duration(seconds: 2));
//             print('Audio controller stopped');
//           } catch (e) {
//             print('Audio controller stop timeout/error: $e');
//           }
//         }

//         // Small delay before disposal
//         await Future.delayed(Duration(milliseconds: 500));

//         // Then dispose with timeout
//         if (_playerController != null) {
//           try {
//             await _playerController?.dispose().timeout(Duration(seconds: 3));
//             print('Video controller disposed');
//           } catch (e) {
//             print('Video controller dispose timeout/error: $e');
//           }
//           _playerController = null;
//         }

//         if (_audioController != null) {
//           try {
//             await _audioController?.dispose().timeout(Duration(seconds: 3));
//             print('Audio controller disposed');
//           } catch (e) {
//             print('Audio controller dispose timeout/error: $e');
//           }
//           _audioController = null;
//         }

//         // Close YoutubeExplode
//         try {
//           _youtubeExplode.close();
//           print('YoutubeExplode closed');
//         } catch (e) {
//           print('Error closing YoutubeExplode: $e');
//         }

//         _isDisposed = true;
//         print('Background disposal completed');
//       } catch (e) {
//         print('Background disposal error: $e');
//         // Force cleanup even if there were errors
//         _playerController = null;
//         _audioController = null;
//         _isDisposed = true;
//       }
//     });
//   }

//   String _getCurrentUserAgent() {
//     return _tvUserAgents[_currentUserAgentIndex % _tvUserAgents.length];
//   }

//   void _rotateUserAgent() {
//     _currentUserAgentIndex =
//         (_currentUserAgentIndex + 1) % _tvUserAgents.length;
//     _failedAttempts++;

//     print(
//         'Rotating to user agent ${_currentUserAgentIndex + 1}/${_tvUserAgents.length}: ${_getCurrentUserAgent().substring(0, 60)}...');
//     print('Failed attempts so far: $_failedAttempts');

//     // If too many failures, add extra delay
//     if (_failedAttempts > _maxFailedAttempts) {
//       print('Too many failed attempts, adding extra delay...');
//     }
//   }

//   Future<void> _addRequestDelay() async {
//     if (_isDisposed || _isDisposing) return; // Check disposal

//     final now = DateTime.now();
//     if (_lastRequestTime != null) {
//       final timeSinceLastRequest = now.difference(_lastRequestTime!);
//       if (timeSinceLastRequest < _requestDelay) {
//         final delayNeeded = _requestDelay - timeSinceLastRequest;
//         print(
//             'Rate limiting: waiting ${delayNeeded.inMilliseconds}ms before next request');
//         await Future.delayed(delayNeeded);
//       }
//     }
//     _lastRequestTime = now;

//     // Extra delay if too many failures
//     if (_failedAttempts > _maxFailedAttempts) {
//       final extraDelay = Duration(seconds: _failedAttempts * 2);
//       print('Extra delay due to failures: ${extraDelay.inSeconds}s');
//       await Future.delayed(extraDelay);
//     }
//   }

//   Future<void> _loadStreamUrls() async {
//     if (_isInitializing || _isDisposed || _isDisposing) return;

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
//       print('Using user agent: ${_getCurrentUserAgent().substring(0, 60)}...');
//       print('Failed attempts so far: $_failedAttempts');

//       // Add rate limiting delay
//       await _addRequestDelay();

//       if (_isDisposed || _isDisposing || !mounted) return; // Check after delay

//       // Try to get manifest with enhanced error handling
//       StreamManifest? manifest;
//       int retryCount = 0;
//       const maxRetries = 3;

//       while (retryCount < maxRetries &&
//           manifest == null &&
//           !_isDisposed &&
//           !_isDisposing &&
//           mounted) {
//         try {
//           print('Attempt ${retryCount + 1}/$maxRetries to get manifest...');
//           manifest = await _youtubeExplode.videos.streamsClient
//               .getManifest(widget.videoUrl);

//           // Success! Reset failed attempts counter
//           _failedAttempts = 0;
//           print('✅ Manifest loaded successfully on attempt ${retryCount + 1}');
//           break;
//         } catch (manifestError) {
//           retryCount++;
//           print('❌ Manifest error on attempt $retryCount: $manifestError');

//           if (retryCount < maxRetries &&
//               !_isDisposed &&
//               !_isDisposing &&
//               mounted) {
//             // Try with different user agent
//             _rotateUserAgent();
//             print('🔄 Retrying with different user agent...');

//             // Add progressive delay between retries
//             await Future.delayed(Duration(seconds: retryCount * 2));

//             if (_isDisposed || _isDisposing || !mounted)
//               return; // Check after delay
//           } else {
//             throw Exception(
//                 'Failed to get video manifest after $maxRetries attempts: $manifestError');
//           }
//         }
//       }

//       if (_isDisposed || _isDisposing || !mounted) return; // Final check

//       if (manifest == null) {
//         throw Exception('Could not get video manifest after all retries');
//       }

//       // First try: Check for muxed streams (video + audio combined)
//       var muxedStreams = manifest.muxed;
//       print('Found ${muxedStreams?.length ?? 0} muxed streams');

//       if (muxedStreams != null && muxedStreams.isNotEmpty) {
//         print('Using muxed stream approach');
//         await _handleMuxedStreams(muxedStreams);
//         return;
//       }

//       // Second try: Use separate video and audio streams
//       print('No muxed streams, using separate video and audio streams...');

//       // Get best video stream
//       var videoOnlyStreams = manifest.videoOnly;
//       print('Found ${videoOnlyStreams?.length ?? 0} video-only streams');

//       VideoOnlyStreamInfo? bestVideoStream;
//       if (videoOnlyStreams != null && videoOnlyStreams.isNotEmpty) {
//         // Sort by quality and select best
//         var sortedVideoStreams = videoOnlyStreams.toList()
//           ..sort((a, b) =>
//               b.videoResolution.height.compareTo(a.videoResolution.height));

//         // Prefer 720p or below for better compatibility
//         bestVideoStream = sortedVideoStreams.firstWhere(
//           (stream) =>
//               stream.videoResolution.height <= 1080 &&
//               stream.videoResolution.height >= 720,
//           orElse: () => sortedVideoStreams.first,
//         );

//         // bestVideoStream = sortedVideoStreams.first;

//         print(
//             'Selected video stream: ${bestVideoStream.tag} - ${bestVideoStream.videoResolution.height}p');
//       }

//       // Get best audio stream with high quality preference
//       var audioOnlyStreams = manifest.audioOnly;
//       print('Found ${audioOnlyStreams?.length ?? 0} audio-only streams');

//       AudioOnlyStreamInfo? bestAudioStream;
//       if (audioOnlyStreams != null && audioOnlyStreams.isNotEmpty) {
//         // Get best audio quality - prefer high bitrate (>128kbps)
//         bestAudioStream = audioOnlyStreams
//                 .where((s) => s.bitrate.bitsPerSecond > 128000)
//                 .isNotEmpty
//             ? audioOnlyStreams
//                 .where((s) => s.bitrate.bitsPerSecond > 128000)
//                 .first
//             : audioOnlyStreams.first;

//         // AFTER (Always Best):
//         // var sortedAudioStreams = audioOnlyStreams.toList()
//         //   ..sort((a, b) =>
//         //       b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond));
//         // bestAudioStream = sortedAudioStreams.first;

//         print(
//             'Selected audio stream: ${bestAudioStream.tag} - ${bestAudioStream.audioCodec} - ${bestAudioStream.bitrate}');
//       }

//       if (bestVideoStream != null && bestAudioStream != null) {
//         // Store both URLs for dual stream approach
//         String videoUrl = bestVideoStream.url.toString();
//         String audioUrl = bestAudioStream.url.toString();

//         print(
//             'Video URL loaded: ${videoUrl.length > 50 ? videoUrl.substring(0, 50) + "..." : videoUrl}');
//         print(
//             'Audio URL loaded: ${audioUrl.length > 50 ? audioUrl.substring(0, 50) + "..." : audioUrl}');

//         _videoStreamUrl = videoUrl;
//         _audioStreamUrl = audioUrl;

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() {
//             _controllerCreated = true;
//             _isInitializing = false;
//           });

//           // Wait for the VLC widgets to be created and auto-initialized
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (!_isDisposed && !_isDisposing && mounted) {
//               _initializationTimer = Timer(Duration(milliseconds: 3000), () {
//                 if (mounted && !_isDisposed && !_isDisposing) {
//                   _waitForAutoInitialization();
//                 }
//               });
//             }
//           });
//         }
//       } else {
//         String missingStreams = '';
//         if (bestVideoStream == null) missingStreams += 'video ';
//         if (bestAudioStream == null) missingStreams += 'audio ';

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() {
//             _errorMessage =
//                 'No $missingStreams streams found for this video. This video might be restricted or unavailable.';
//             _isInitializing = false;
//           });
//         }
//       }
//     } catch (e) {
//       print('Error loading streams: $e');
//       print('Stack trace: ${StackTrace.current}');

//       if (_isDisposed || _isDisposing || !mounted)
//         return; // Don't set error if disposed

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
//       } else if (e.toString().contains('403') ||
//           e.toString().contains('Forbidden')) {
//         errorMessage =
//             'Access blocked: Trying different user agent... (${_getCurrentUserAgent().split(' ')[0]})';
//         // Auto-retry with different user agent for 403 errors
//         if (_failedAttempts < _tvUserAgents.length) {
//           Timer(Duration(seconds: 3), () {
//             if (mounted && !_isDisposed && !_isDisposing) {
//               _retryWithDifferentUserAgent();
//             }
//           });
//         }
//       } else if (e.toString().contains('429') ||
//           e.toString().contains('rate')) {
//         errorMessage = 'Rate limited: Please wait before trying again...';
//       }

//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage = errorMessage;
//           _isInitializing = false;
//         });
//       }
//     }
//   }

//   Future<void> _handleMuxedStreams(List<MuxedStreamInfo> muxedStreams) async {
//     if (_isDisposed || _isDisposing || !mounted) return;

//     MuxedStreamInfo? bestStream;

//     // Sort by quality and bitrate
//     var sortedStreams = muxedStreams.toList()
//       ..sort((a, b) {
//         // First priority: video quality
//         int qualityCompare =
//             b.videoResolution.height.compareTo(a.videoResolution.height);
//         if (qualityCompare != 0) return qualityCompare;

//         // Second priority: bitrate
//         return b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond);
//       });

//     // // Select best quality up to 720p for compatibility
//     // bestStream = sortedStreams.firstWhere(
//     //   (stream) => stream.videoResolution.height <= 720,
//     //   orElse: () => sortedStreams.first,
//     // );

//     bestStream = sortedStreams.first; // Always take the best available

//     String streamUrl = bestStream.url.toString();
//     print(
//         'Selected muxed stream: ${bestStream.tag} - ${bestStream.videoResolution.height}p - Bitrate: ${bestStream.bitrate}');

//     _videoStreamUrl = streamUrl;
//     // For muxed streams, we don't need separate audio
//     _audioStreamUrl = null;

//     if (mounted && !_isDisposed && !_isDisposing) {
//       setState(() {
//         _controllerCreated = true;
//         _isInitializing = false;
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!_isDisposed && !_isDisposing && mounted) {
//           _initializationTimer = Timer(Duration(milliseconds: 3000), () {
//             if (mounted && !_isDisposed && !_isDisposing) {
//               _waitForAutoInitialization();
//             }
//           });
//         }
//       });
//     }
//   }

//   void _createControllers() {
//     if (_videoStreamUrl == null || !mounted || _isDisposed || _isDisposing)
//       return;

//     try {
//       print('Creating controllers with TV user agent...');
//       print(
//           'Current user agent: ${_getCurrentUserAgent().substring(0, 60)}...');

//       // Create video controller
//       _playerController = VlcPlayerController.network(
//         _videoStreamUrl!,
//         hwAcc: HwAcc.auto,
//         autoPlay: false,
//         autoInitialize: true,
//         options: VlcPlayerOptions(
//           advanced: VlcAdvancedOptions([
//             VlcAdvancedOptions.networkCaching(5000),
//             VlcAdvancedOptions.liveCaching(5000),
//           ]),
//           audio: VlcAudioOptions([
//             '--aout=any',
//           ]),
//           video: VlcVideoOptions([
//             '--avcodec-hw=any',
//           ]),
//           http: VlcHttpOptions([
//             '--http-user-agent=${_getCurrentUserAgent()}',
//             '--http-referrer=https://www.youtube.com/',
//           ]),
//           subtitle: VlcSubtitleOptions([]),
//           rtp: VlcRtpOptions([]),
//         ),
//       );

//       print('Video controller created successfully');

//       // Create audio controller if we have separate audio URL
//       if (_audioStreamUrl != null && !_isDisposed && !_isDisposing) {
//         print('Creating separate audio controller for high quality audio...');
//         _audioController = VlcPlayerController.network(
//           _audioStreamUrl!,
//           hwAcc: HwAcc.auto,
//           autoPlay: false,
//           autoInitialize: true,
//           options: VlcPlayerOptions(
//             advanced: VlcAdvancedOptions([
//               VlcAdvancedOptions.networkCaching(5000),
//               VlcAdvancedOptions.liveCaching(5000),
//             ]),
//             audio: VlcAudioOptions([
//               '--aout=any',
//             ]),
//             video: VlcVideoOptions([
//               '--no-video', // Audio only
//             ]),
//             http: VlcHttpOptions([
//               '--http-user-agent=${_getCurrentUserAgent()}',
//               '--http-referrer=https://www.youtube.com/',
//             ]),
//             subtitle: VlcSubtitleOptions([]),
//             rtp: VlcRtpOptions([]),
//           ),
//         );
//         print('Audio controller created successfully');
//         _useDualStream = true;
//       }
//     } catch (e) {
//       print('Error creating controllers: $e');
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage = 'Failed to create video players: $e';
//         });
//       }
//     }
//   }

//   Future<void> _waitForAutoInitialization() async {
//     if (!mounted || _playerController == null || _isDisposed || _isDisposing) {
//       print(
//           'Cannot wait for initialization: widget not mounted or controller null');
//       return;
//     }

//     try {
//       print('Waiting for auto-initialization of controllers...');

//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _isInitializing = true;
//           _errorMessage = null;
//         });
//       }

//       // Wait for auto-initialization to complete
//       int attempts = 0;
//       const maxAttempts = 30;

//       while (attempts < maxAttempts &&
//           mounted &&
//           _playerController != null &&
//           !_isDisposed &&
//           !_isDisposing) {
//         final videoInitialized =
//             _playerController?.value.isInitialized ?? false;
//         final audioInitialized = _audioController?.value.isInitialized ??
//             true; // true if no audio controller

//         print(
//             'Auto-initialization check $attempts: video=$videoInitialized, audio=$audioInitialized');

//         if (videoInitialized && audioInitialized) {
//           print('Controllers auto-initialized successfully');
//           break;
//         }

//         await Future.delayed(Duration(seconds: 1));
//         attempts++;

//         // Check if widget is still mounted after delay
//         if (!mounted || _isDisposed || _isDisposing) {
//           print('Widget disposed during initialization, stopping...');
//           return;
//         }
//       }

//       if (mounted &&
//           _playerController != null &&
//           !_isDisposed &&
//           !_isDisposing) {
//         // Final check
//         final videoInitialized =
//             _playerController?.value.isInitialized ?? false;
//         final audioInitialized = _audioController?.value.isInitialized ?? true;

//         if (videoInitialized && audioInitialized) {
//           if (mounted && !_isDisposed && !_isDisposing) {
//             setState(() {
//               _isInitialized = true;
//               _isInitializing = false;
//             });
//           }

//           print(
//               'Controllers ready for playback (dual stream: $_useDualStream)');
//           _setupSyncListeners();

//           // Auto-play after initialization
//           _autoPlayTimer = Timer(Duration(milliseconds: 1500), () {
//             if (mounted && _isInitialized && !_isDisposed && !_isDisposing) {
//               print('Starting auto-play...');
//               _playBoth();
//             }
//           });
//         } else {
//           throw Exception('Controllers failed to auto-initialize');
//         }
//       }
//     } catch (e) {
//       print('Auto-initialization wait error: $e');
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage = 'Failed to initialize video players: $e';
//           _isInitializing = false;
//           _isInitialized = false;
//         });
//       }
//     }
//   }

//   void _setupSyncListeners() {
//     // Only setup sync if properly initialized
//     if (!_isInitialized ||
//         _playerController == null ||
//         !mounted ||
//         _isDisposed ||
//         _isDisposing) {
//       return;
//     }

//     // Cancel any existing subscription
//     _syncSubscription?.cancel();

//     // Start sync after a delay to ensure controllers are ready
//     Timer(Duration(seconds: 3), () {
//       if (mounted &&
//           _isInitialized &&
//           _playerController != null &&
//           !_isDisposed &&
//           !_isDisposing) {
//         // Check every 2 seconds for sync
//         _syncSubscription =
//             Stream.periodic(Duration(seconds: 2)).listen((_) async {
//           if (mounted &&
//               _isInitialized &&
//               _playerController != null &&
//               !_isDisposed &&
//               !_isDisposing) {
//             try {
//               // Check if controllers are initialized before calling getPosition
//               final videoInitialized =
//                   _playerController?.value.isInitialized ?? false;

//               if (videoInitialized) {
//                 final videoPosition =
//                     await _playerController?.getPosition() ?? Duration.zero;

//                 // If using dual stream, sync audio with video
//                 if (_useDualStream &&
//                     _audioController != null &&
//                     !_isDisposed &&
//                     !_isDisposing) {
//                   final audioInitialized =
//                       _audioController?.value.isInitialized ?? false;

//                   if (audioInitialized) {
//                     final audioPosition =
//                         await _audioController?.getPosition() ?? Duration.zero;

//                     // If positions are out of sync by more than 1 second, sync them
//                     final diff = (videoPosition.inMilliseconds -
//                             audioPosition.inMilliseconds)
//                         .abs();
//                     if (diff > 1000 && !_isDisposed && !_isDisposing) {
//                       await _audioController?.seekTo(videoPosition);
//                     }
//                   }
//                 }

//                 if (mounted && !_isDisposed && !_isDisposing) {
//                   setState(() {
//                     _currentPosition = videoPosition;
//                   });
//                 }
//               }
//             } catch (e) {
//               // Don't log sync errors too frequently
//             }
//           }
//         });
//       }
//     });
//   }

//   Future<void> _playBoth() async {
//     if (!_isInitialized ||
//         _playerController == null ||
//         _isDisposed ||
//         _isDisposing) {
//       print('Cannot play: not initialized or controllers are null');
//       return;
//     }

//     try {
//       // Check if controllers are initialized before playing
//       final videoInitialized = _playerController?.value.isInitialized ?? false;

//       if (videoInitialized && !_isDisposed && !_isDisposing) {
//         print('Playing video controller...');
//         await _playerController?.play();

//         // Play audio controller if using dual stream
//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing) {
//           final audioInitialized =
//               _audioController?.value.isInitialized ?? false;
//           if (audioInitialized) {
//             print('Playing audio controller...');
//             await _audioController?.play();
//           }
//         }

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() => _isPlaying = true);
//         }
//         print('Controllers playing (dual stream: $_useDualStream)');
//       } else {
//         print('Controllers not ready');
//       }
//     } catch (e) {
//       print('Error playing: $e');
//     }
//   }

//   Future<void> _pauseBoth() async {
//     if (!_isInitialized ||
//         _playerController == null ||
//         _isDisposed ||
//         _isDisposing) {
//       print('Cannot pause: not initialized or controllers are null');
//       return;
//     }

//     try {
//       final videoInitialized = _playerController?.value.isInitialized ?? false;

//       if (videoInitialized && !_isDisposed && !_isDisposing) {
//         print('Pausing video controller...');
//         await _playerController?.pause();

//         // Pause audio controller if using dual stream
//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing) {
//           final audioInitialized =
//               _audioController?.value.isInitialized ?? false;
//           if (audioInitialized) {
//             print('Pausing audio controller...');
//             await _audioController?.pause();
//           }
//         }

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() => _isPlaying = false);
//         }
//         print('Controllers paused (dual stream: $_useDualStream)');
//       }
//     } catch (e) {
//       print('Error pausing: $e');
//     }
//   }

//   Future<void> _seekBoth(Duration position) async {
//     if (!_isInitialized ||
//         _playerController == null ||
//         _isDisposed ||
//         _isDisposing) {
//       print('Cannot seek: not initialized or controllers are null');
//       return;
//     }

//     try {
//       final videoInitialized = _playerController?.value.isInitialized ?? false;

//       if (videoInitialized && !_isDisposed && !_isDisposing) {
//         print('Seeking video controller to ${position.inSeconds}s...');
//         await _playerController?.seekTo(position);

//         // Seek audio controller if using dual stream
//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing) {
//           final audioInitialized =
//               _audioController?.value.isInitialized ?? false;
//           if (audioInitialized) {
//             print('Seeking audio controller to ${position.inSeconds}s...');
//             await _audioController?.seekTo(position);
//           }
//         }

//         print('Controllers seeked (dual stream: $_useDualStream)');
//       }
//     } catch (e) {
//       print('Error seeking: $e');
//     }
//   }

//   Future<void> _stopBoth() async {
//     if (!_isInitialized ||
//         _playerController == null ||
//         _isDisposed ||
//         _isDisposing) {
//       print('Cannot stop: not initialized or controllers are null');
//       return;
//     }

//     try {
//       final videoInitialized = _playerController?.value.isInitialized ?? false;

//       if (videoInitialized && !_isDisposed && !_isDisposing) {
//         print('Stopping video controller...');
//         await _playerController?.stop();

//         // Stop audio controller if using dual stream
//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing) {
//           final audioInitialized =
//               _audioController?.value.isInitialized ?? false;
//           if (audioInitialized) {
//             print('Stopping audio controller...');
//             await _audioController?.stop();
//           }
//         }

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() => _isPlaying = false);
//         }
//         print('Controllers stopped (dual stream: $_useDualStream)');
//       }
//     } catch (e) {
//       print('Error stopping: $e');
//     }
//   }

//   // Enhanced retry with different user agent
//   Future<void> _retryWithDifferentUserAgent() async {
//     if (_failedAttempts >= _tvUserAgents.length ||
//         _isDisposed ||
//         _isDisposing) {
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage =
//               'All user agents failed. Video may be restricted or temporarily unavailable.';
//         });
//       }
//       return;
//     }

//     _rotateUserAgent();

//     if (mounted && !_isDisposed && !_isDisposing) {
//       setState(() {
//         _errorMessage = null;
//         _isInitialized = false;
//         _isInitializing = false;
//         _controllerCreated = false;
//         _useDualStream = false;
//         _videoStreamUrl = null;
//         _audioStreamUrl = null;
//       });
//     }

//     await _disposeControllersSync();

//     // Add delay before retry
//     await Future.delayed(Duration(seconds: 2));

//     if (mounted && !_isDisposed && !_isDisposing) {
//       _loadStreamUrls();
//     }
//   }

//   // Synchronous disposal for retries
//   Future<void> _disposeControllersSync() async {
//     print('Disposing controllers synchronously...');

//     // Cancel all timers first
//     _cancelAllTimers();

//     try {
//       if (_playerController != null) {
//         print('Disposing video controller...');
//         await _playerController?.stop().timeout(Duration(seconds: 2));
//         await _playerController?.dispose().timeout(Duration(seconds: 3));
//         _playerController = null;
//         print('Video controller disposed');
//       }
//       if (_audioController != null) {
//         print('Disposing audio controller...');
//         await _audioController?.stop().timeout(Duration(seconds: 2));
//         await _audioController?.dispose().timeout(Duration(seconds: 3));
//         _audioController = null;
//         print('Audio controller disposed');
//       }
//     } catch (e) {
//       print('Error disposing controllers: $e');
//       // Set to null anyway to prevent further issues
//       _playerController = null;
//       _audioController = null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Wrap the widget with WillPopScope to handle back button
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: _buildPlayerContent(),
//     );
//   }

//   Widget _buildPlayerContent() {
//     // Return empty container if disposed
//     if (_isDisposed || _isDisposing) {
//       return Container(
//         height: screenhgt,
//         color: Colors.black,
//         child: Center(
//           child: Text(
//             'Player disposed',
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       );
//     }

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
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: _isDisposing
//                       ? null
//                       : () {
//                           if (_isDisposed || _isDisposing) return;
//                           setState(() {
//                             _errorMessage = null;
//                             _isInitialized = false;
//                             _isInitializing = false;
//                             _controllerCreated = false;
//                             _useDualStream = false;
//                             _videoStreamUrl = null;
//                             _audioStreamUrl = null;
//                             _failedAttempts = 0; // Reset failed attempts
//                           });
//                           _disposeControllersSync().then((_) {
//                             if (!_isDisposed && !_isDisposing && mounted) {
//                               _loadStreamUrls();
//                             }
//                           });
//                         },
//                   child: Text('Retry'),
//                 ),
//                 SizedBox(width: 16),
//                 ElevatedButton(
//                   onPressed: (_isDisposed || _isDisposing)
//                       ? null
//                       : _retryWithDifferentUserAgent,
//                   child: Text('Try Different Agent'),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Agent ${_currentUserAgentIndex + 1}/${_tvUserAgents.length}: ${_getCurrentUserAgent().substring(0, 30)}...',
//               style: TextStyle(fontSize: 10, color: Colors.grey),
//             ),
//             if (_failedAttempts > 0)
//               Text(
//                 'Failed attempts: $_failedAttempts',
//                 style: TextStyle(fontSize: 10, color: Colors.orange),
//               ),
//           ],
//         ),
//       );
//     }

//     // Show loading if not ready
//     if (!_controllerCreated || (_isInitializing && !_isInitialized)) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text(!_controllerCreated
//                 ? 'Loading YouTube video streams...'
//                 : 'Initializing video players...'),
//             SizedBox(height: 8),
//             Text(
//               'Agent ${_currentUserAgentIndex + 1}/${_tvUserAgents.length}: ${_getCurrentUserAgent().substring(0, 40)}...',
//               style: TextStyle(fontSize: 10, color: Colors.grey),
//               textAlign: TextAlign.center,
//             ),
//             if (_failedAttempts > 0)
//               Padding(
//                 padding: const EdgeInsets.only(top: 4.0),
//                 child: Text(
//                   'Attempts: $_failedAttempts',
//                   style: TextStyle(fontSize: 10, color: Colors.orange),
//                 ),
//               ),
//           ],
//         ),
//       );
//     }

//     // Create controllers when URLs are ready but controllers don't exist yet
//     if (_controllerCreated &&
//         _playerController == null &&
//         !_isDisposed &&
//         !_isDisposing) {
//       _createControllers();
//     }

//     return Stack(
//       children: [
//         // Video player (main layer)
//         Container(
//           height: screenhgt,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             color: Colors.black,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: _playerController != null && !_isDisposed && !_isDisposing
//                 ? VlcPlayer(
//                     controller: _playerController!,
//                     aspectRatio: 16 / 9,
//                     placeholder: const Center(
//                       child: Text(
//                         'Loading Video...',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   )
//                 : Container(
//                     color: Colors.black,
//                     child: const Center(
//                       child: CircularProgressIndicator(),
//                     ),
//                   ),
//           ),
//         ),

//         // Audio player (hidden - केवल audio के लिए)
//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing)
//           Positioned(
//             top: -1000, // Screen के बाहर hide कर देते हैं
//             child: Container(
//               height: 1,
//               width: 1,
//               child: VlcPlayer(
//                 controller: _audioController!,
//                 aspectRatio: 1,
//               ),
//             ),
//           ),

//         // // Debug info - overlay के रूप में bottom पर
//         // if (_useDualStream && !_isDisposed && !_isDisposing)
//         //   Positioned(
//         //     bottom: 8,
//         //     left: 8,
//         //     child: Container(
//         //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         //       decoration: BoxDecoration(
//         //         color: Colors.black54,
//         //         borderRadius: BorderRadius.circular(4),
//         //       ),
//         //       child: Text(
//         //         'High Quality Audio Mode (Dual Stream)',
//         //         style: TextStyle(fontSize: 10, color: Colors.green),
//         //       ),
//         //     ),
//         //   ),
//       ],
//     );

//     // return Column(
//     //   children: [
//     //     // Video player (visible)
//     //     Container(
//     //       height: screenhgt,
//     //       decoration: BoxDecoration(
//     //         color: Colors.black,
//     //         borderRadius: BorderRadius.circular(8),
//     //       ),
//     //       child: ClipRRect(
//     //         borderRadius: BorderRadius.circular(8),
//     //         child: _playerController != null && !_isDisposed && !_isDisposing
//     //             ? VlcPlayer(
//     //                 controller: _playerController!,
//     //                 aspectRatio: 16 / 9,
//     //                 placeholder: const Center(
//     //                   child: Text(
//     //                     'Loading Video...',
//     //                     style: TextStyle(color: Colors.white),
//     //                   ),
//     //                 ),
//     //               )
//     //             : Container(
//     //                 color: Colors.black,
//     //                 child: const Center(
//     //                   child: CircularProgressIndicator(),
//     //                 ),
//     //               ),
//     //       ),
//     //     ),

//     //     // Audio player (hidden - केवल audio के लिए)
//     //     if (_useDualStream &&
//     //         _audioController != null &&
//     //         !_isDisposed &&
//     //         !_isDisposing)
//     //       Offstage(
//     //         offstage: true,
//     //         child: Container(
//     //           height: 1,
//     //           width: 1,
//     //           child: VlcPlayer(
//     //             controller: _audioController!,
//     //             aspectRatio: 1,
//     //           ),
//     //         ),
//     //       ),

//     //     // Debug info (can be removed in production)
//     //     if (_useDualStream && !_isDisposed && !_isDisposing)
//     //       Padding(
//     //         padding: const EdgeInsets.all(8.0),
//     //         child: Text(
//     //           'High Quality Audio Mode (Dual Stream)',
//     //           style: TextStyle(fontSize: 10, color: Colors.green),
//     //         ),
//     //       ),
//     //   ],
//     // );
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//   }

//   @override
//   void dispose() {
//     print('Disposing CustomYoutubePlayer - starting cleanup...');
//     KeepScreenOn.turnOn();
//     // Remove lifecycle observer
//     WidgetsBinding.instance.removeObserver(this);

//     // Mark as disposing to prevent any new operations
//     _isDisposing = true;

//     // Cancel all timers and subscriptions immediately
//     _cancelAllTimers();

//     // Start background disposal process
//     _disposeControllersInBackground();

//     // Call super.dispose() immediately to free up the widget
//     super.dispose();
//     print('Widget disposed successfully');
//   }
// }







// ###########################################

// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:youtube_explode_dart/youtube_explode_dart.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:keep_screen_on/keep_screen_on.dart';

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
//     with TickerProviderStateMixin, WidgetsBindingObserver {
//   VlcPlayerController? _playerController;
//   VlcPlayerController? _audioController;
//   final YoutubeExplode _youtubeExplode = YoutubeExplode();

//   bool _isPlaying = false;
//   bool _isInitialized = false;
//   bool _isInitializing = false;
//   bool _controllerCreated = false;
//   bool _useDualStream = false;
//   bool _isDisposed = false;
//   bool _isDisposing = false;
//   bool _hasNavigatedBack = false; // Add flag to prevent multiple navigations
//   bool _isNearEnd = false; // Track if we're near video end
//   int _endDetectionCount = 0; // Count how many times we detected near end
//   Duration _currentPosition = Duration.zero;
//   Duration _totalDuration = Duration.zero; // Add total duration tracking
//   Duration _lastKnownPosition = Duration.zero; // Track last known position
//   String? _errorMessage;
//   String? _videoStreamUrl;
//   String? _audioStreamUrl;

//   // Stream subscriptions for proper cleanup
//   StreamSubscription? _syncSubscription;
//   StreamSubscription? _positionTrackingSubscription; // Add position tracking listener
//   Timer? _initializationTimer;
//   Timer? _autoPlayTimer;

//   // Add completer for safe disposal
//   Completer<void>? _disposalCompleter;

//   // Enhanced TV User Agents with better success rates
//   final List<String> _tvUserAgents = [
//     // High success rate agents (real device signatures)
//     'Mozilla/5.0 (SMART-TV; Linux; Tizen 7.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36',
//     'Mozilla/5.0 (Web0S; Linux/SmartTV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 webOS/6.0',
//     'Mozilla/5.0 (Linux; Android 11; SHIELD Android TV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Safari/537.36',
//     'Mozilla/5.0 (X11; Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chromium/90.0.4430.225 Chrome/90.0.4430.225 Safari/537.36',

//     // Fallback mobile agents (often less blocked)
//     'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
//     'Mozilla/5.0 (iPad; CPU OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
//     'Mozilla/5.0 (Linux; Android 11; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Mobile Safari/537.36',

//     // Desktop agents as last resort
//     'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Safari/537.36',
//     'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Safari/537.36',
//   ];

//   int _currentUserAgentIndex = 0;
//   int _failedAttempts = 0;
//   final int _maxFailedAttempts = 3;
//   DateTime? _lastRequestTime;
//   final Duration _requestDelay = Duration(seconds: 2); // Rate limiting

//   @override
//   void initState() {
//     super.initState();
//     // Add lifecycle observer to handle app state changes
//     WidgetsBinding.instance.addObserver(this);
//     _loadStreamUrls();
//     KeepScreenOn.turnOn();
//   }

//   // Handle app lifecycle changes to prevent crashes
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);

//     switch (state) {
//       case AppLifecycleState.paused:
//       case AppLifecycleState.detached:
//         print('App paused/detached - stopping players safely');
//         _stopPlayersForBackground();
//         break;
//       case AppLifecycleState.resumed:
//         print('App resumed');
//         break;
//       default:
//         break;
//     }
//   }

//   // Stop players when app goes to background
//   void _stopPlayersForBackground() {
//     if (_isDisposed || _isDisposing) return;

//     try {
//       _playerController?.pause();
//       _audioController?.pause();
//       setState(() {
//         _isPlaying = false;
//       });
//     } catch (e) {
//       print('Error stopping players for background: $e');
//     }
//   }

//   // Override the back button behavior
//   Future<bool> _onWillPop() async {
//     print('Back button pressed - initiating safe disposal');

//     if (_isDisposing || _isDisposed) {
//       return true; // Allow navigation if already disposing
//     }

//     // Check if this would close the app
//     if (!Navigator.canPop(context)) {
//       print('⚠️ This is root page - preventing app close');
//       // Show dialog or just stay on page
//       _showExitDialog();
//       return false; // Prevent app close
//     }

//     // Start safe disposal process
//     _startSafeDisposal();

//     // Allow immediate navigation without waiting for disposal
//     return true;
//   }

//   // Show exit confirmation dialog
//   void _showExitDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Exit App?'),
//           content: Text('Do you want to exit the application?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close dialog
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close dialog
//                 // Force close app if needed
//                 // SystemNavigator.pop(); // Uncomment to allow app exit
//               },
//               child: Text('Exit'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _startSafeDisposal() {
//     if (_isDisposing || _isDisposed) return;

//     print('Starting safe disposal process...');
//     _isDisposing = true;

//     // Cancel all timers immediately
//     _cancelAllTimers();

//     // Stop all async operations
//     _syncSubscription?.cancel();
//     _positionTrackingSubscription?.cancel(); // Cancel position tracking listener

//     // Dispose controllers in background without blocking UI
//     _disposeControllersInBackground();
//   }

//   void _cancelAllTimers() {
//     try {
//       _initializationTimer?.cancel();
//       _initializationTimer = null;

//       _autoPlayTimer?.cancel();
//       _autoPlayTimer = null;

//       _syncSubscription?.cancel();
//       _syncSubscription = null;

//       _positionTrackingSubscription?.cancel(); // Cancel position tracking listener
//       _positionTrackingSubscription = null;

//       print('All timers and subscriptions cancelled');
//     } catch (e) {
//       print('Error cancelling timers: $e');
//     }
//   }

//   void _disposeControllersInBackground() {
//     // Run disposal in background without affecting UI navigation
//     Future.microtask(() async {
//       try {
//         print('Background controller disposal started');

//         // First stop playback
//         if (_playerController != null) {
//           try {
//             await _playerController?.stop().timeout(Duration(seconds: 2));
//             print('Video controller stopped');
//           } catch (e) {
//             print('Video controller stop timeout/error: $e');
//           }
//         }

//         if (_audioController != null) {
//           try {
//             await _audioController?.stop().timeout(Duration(seconds: 2));
//             print('Audio controller stopped');
//           } catch (e) {
//             print('Audio controller stop timeout/error: $e');
//           }
//         }

//         // Small delay before disposal
//         await Future.delayed(Duration(milliseconds: 500));

//         // Then dispose with timeout
//         if (_playerController != null) {
//           try {
//             await _playerController?.dispose().timeout(Duration(seconds: 3));
//             print('Video controller disposed');
//           } catch (e) {
//             print('Video controller dispose timeout/error: $e');
//           }
//           _playerController = null;
//         }

//         if (_audioController != null) {
//           try {
//             await _audioController?.dispose().timeout(Duration(seconds: 3));
//             print('Audio controller disposed');
//           } catch (e) {
//             print('Audio controller dispose timeout/error: $e');
//           }
//           _audioController = null;
//         }

//         // Close YoutubeExplode
//         try {
//           _youtubeExplode.close();
//           print('YoutubeExplode closed');
//         } catch (e) {
//           print('Error closing YoutubeExplode: $e');
//         }

//         _isDisposed = true;
//         print('Background disposal completed');
//       } catch (e) {
//         print('Background disposal error: $e');
//         // Force cleanup even if there were errors
//         _playerController = null;
//         _audioController = null;
//         _isDisposed = true;
//       }
//     });
//   }

//   // Add method to handle video completion
//   void _handleVideoCompletion() {
//     if (_hasNavigatedBack || _isDisposed || _isDisposing) {
//       print('🚫 Navigation already triggered or player disposed');
//       return;
//     }

//     print('🎬 Video completed - starting safe cleanup and navigation');
//     _hasNavigatedBack = true;

//     // Immediately stop position tracking
//     _positionTrackingSubscription?.cancel();
//     _syncSubscription?.cancel();

//     // Show completion status
//     if (mounted && !_isDisposed && !_isDisposing) {
//       setState(() {
//         _isPlaying = false;
//       });
//     }

//     // Start safe cleanup process before navigation
//     _performSafeCleanupAndNavigate();
//   }

//   // Perform safe cleanup before navigation
//   Future<void> _performSafeCleanupAndNavigate() async {
//     try {
//       print('🧹 Starting safe cleanup process...');

//       // Step 1: Stop both controllers gracefully
//       await _stopBothSafely();

//       // Step 2: Small delay to ensure stop completes
//       await Future.delayed(Duration(milliseconds: 300));

//       // Step 3: Pause controllers to ensure they're in stopped state
//       await _pauseBothSafely();

//       // Step 4: Another small delay
//       await Future.delayed(Duration(milliseconds: 200));

//       // Step 5: Mark as disposing to prevent further operations
//       _isDisposing = true;

//       // Step 6: Cancel all remaining subscriptions
//       _cancelAllTimers();

//       print('✅ Safe cleanup completed - now navigating');

//       // Step 7: Navigate back safely
//       _performSafeNavigation();

//     } catch (e) {
//       print('❌ Error during cleanup: $e');
//       // Even if cleanup fails, try to navigate
//       _performSafeNavigation();
//     }
//   }

//   // Safe stop method
//   Future<void> _stopBothSafely() async {
//     try {
//       if (_playerController != null && _playerController!.value.isInitialized) {
//         print('🛑 Stopping video controller safely...');
//         await _playerController!.stop().timeout(Duration(seconds: 2));
//       }

//       if (_useDualStream && _audioController != null && _audioController!.value.isInitialized) {
//         print('🛑 Stopping audio controller safely...');
//         await _audioController!.stop().timeout(Duration(seconds: 2));
//       }

//       print('✅ Controllers stopped successfully');
//     } catch (e) {
//       print('⚠️ Error stopping controllers (non-critical): $e');
//     }
//   }

//   // Safe pause method
//   Future<void> _pauseBothSafely() async {
//     try {
//       if (_playerController != null && _playerController!.value.isInitialized) {
//         await _playerController!.pause().timeout(Duration(seconds: 1));
//       }

//       if (_useDualStream && _audioController != null && _audioController!.value.isInitialized) {
//         await _audioController!.pause().timeout(Duration(seconds: 1));
//       }
//     } catch (e) {
//       print('⚠️ Error pausing controllers (non-critical): $e');
//     }
//   }

//   // Safe navigation method
//   void _performSafeNavigation() {
//     // Use a small delay to ensure UI is stable
//     Timer(Duration(milliseconds: 100), () {
//       if (!mounted) {
//         print('❌ Widget not mounted - cannot navigate');
//         return;
//       }

//       try {
//         // Check if we can safely pop
//         if (Navigator.canPop(context)) {
//           print('🔙 Navigating back to previous screen');
//           Navigator.pop(context);
//         } else {
//           print('⚠️ Cannot pop - using fallback navigation');
//           _fallbackNavigation();
//         }
//       } catch (e) {
//         print('❌ Navigation error: $e');
//         _fallbackNavigation();
//       }
//     });
//   }

//   // Fallback navigation method
//   void _fallbackNavigation() {
//     try {
//       // Option 1: Try to replace current route with home
//       print('🏠 Using fallback navigation');

//       // You can customize this route based on your app structure
//       Navigator.pushReplacementNamed(context, '/').catchError((e) {
//         print('❌ Fallback navigation failed: $e');
//         // If all navigation fails, just dispose and stay
//         _justDisposeAndStay();
//       });

//     } catch (e) {
//       print('❌ All navigation methods failed: $e');
//       _justDisposeAndStay();
//     }
//   }

//   // Last resort - just dispose and stay on page
//   void _justDisposeAndStay() {
//     print('🛑 All navigation failed - just disposing controllers and staying');

//     // Show a message to user
//     if (mounted) {
//       setState(() {
//         _errorMessage = 'Video completed. Please use back button to return.';
//         _isInitialized = false;
//         _controllerCreated = false;
//       });
//     }

//     // Dispose controllers in background
//     _disposeControllersInBackground();
//   }

//   // Add method to setup position tracking for video completion detection
//   void _setupPositionTracking() {
//     if (_playerController == null || _isDisposed || _isDisposing || !mounted) return;

//     // Cancel existing subscription
//     _positionTrackingSubscription?.cancel();

//     print('🎬 Setting up position tracking for auto-navigation...');

//     // Start position tracking immediately, but with a small delay
//     Timer(Duration(seconds: 1), () {
//       if (mounted &&
//           _isInitialized &&
//           _playerController != null &&
//           !_isDisposed &&
//           !_isDisposing) {

//         print('📍 Starting position tracking...');

//         // Track position every 500ms for more responsive detection
//         _positionTrackingSubscription =
//             Stream.periodic(Duration(milliseconds: 500)).listen((_) async {
//           if (mounted &&
//               _isInitialized &&
//               _playerController != null &&
//               !_isDisposed &&
//               !_isDisposing &&
//               !_hasNavigatedBack) {

//             await _checkVideoCompletion();
//           }
//         });
//       }
//     });
//   }

//   // Separate method for checking video completion
//   Future<void> _checkVideoCompletion() async {
//     try {
//       // Check if controller is initialized
//       final videoInitialized = _playerController?.value.isInitialized ?? false;
//       if (!videoInitialized) return;

//       // Get current position and duration
//       final currentPos = await _playerController?.getPosition() ?? Duration.zero;
//       final totalDur = await _playerController?.getDuration() ?? Duration.zero;

//       // Update state
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _currentPosition = currentPos;
//           _totalDuration = totalDur;
//         });
//       }

//       // Debug logging every 5 seconds
//        int logCounter = 0;
//       logCounter++;
//       if (logCounter % 10 == 0) { // Log every 5 seconds (500ms * 10)
//         print('🕐 Position: ${currentPos.inSeconds}s / ${totalDur.inSeconds}s | Playing: $_isPlaying');
//       }

//       // Validation checks
//       if (totalDur.inSeconds <= 10) {
//         // Video too short or duration not available yet
//         return;
//       }

//       if (currentPos.inSeconds <= 0) {
//         // Position not available yet
//         return;
//       }

//       // Calculate remaining time
//       final remainingSeconds = totalDur.inSeconds - currentPos.inSeconds;

//       // Multiple completion detection methods:

//       // Method 1: Within last 5 seconds
//       if (remainingSeconds <= 5 && remainingSeconds >= 0) {
//         _isNearEnd = true;
//         _endDetectionCount++;

//         print('🎯 Near end detected! Remaining: ${remainingSeconds}s (Count: $_endDetectionCount)');

//         // Trigger navigation if we've been near end for 2+ consecutive checks
//         if (_endDetectionCount >= 2) {
//           print('✅ Video completion confirmed - triggering navigation');
//           _handleVideoCompletion();
//           return;
//         }
//       } else if (remainingSeconds > 5) {
//         // Reset counters if we're not near end
//         _isNearEnd = false;
//         _endDetectionCount = 0;
//       }

//       // Method 2: Position not changing and we're near end
//       if (currentPos == _lastKnownPosition &&
//           _lastKnownPosition.inSeconds > 0 &&
//           remainingSeconds <= 10 &&
//           !_isPlaying) {

//         print('🛑 Video seems paused/ended at position: ${currentPos.inSeconds}s');
//         _handleVideoCompletion();
//         return;
//       }

//       // Method 3: Position >= 95% of total duration
//       final progressPercentage = (currentPos.inSeconds / totalDur.inSeconds) * 100;
//       if (progressPercentage >= 95.0) {
//         print('📊 95% progress reached (${progressPercentage.toStringAsFixed(1)}%) - triggering navigation');
//         _handleVideoCompletion();
//         return;
//       }

//       // Update last known position
//       _lastKnownPosition = currentPos;

//     } catch (e) {
//       // Log errors but don't spam
//        int errorCount = 0;
//       errorCount++;
//       if (errorCount % 20 == 1) { // Log every 20th error
//         print('⚠️ Position tracking error: $e');
//       }
//     }
//   }

//   String _getCurrentUserAgent() {
//     return _tvUserAgents[_currentUserAgentIndex % _tvUserAgents.length];
//   }

//   void _rotateUserAgent() {
//     _currentUserAgentIndex =
//         (_currentUserAgentIndex + 1) % _tvUserAgents.length;
//     _failedAttempts++;

//     print(
//         'Rotating to user agent ${_currentUserAgentIndex + 1}/${_tvUserAgents.length}: ${_getCurrentUserAgent().substring(0, 60)}...');
//     print('Failed attempts so far: $_failedAttempts');

//     // If too many failures, add extra delay
//     if (_failedAttempts > _maxFailedAttempts) {
//       print('Too many failed attempts, adding extra delay...');
//     }
//   }

//   Future<void> _addRequestDelay() async {
//     if (_isDisposed || _isDisposing) return; // Check disposal

//     final now = DateTime.now();
//     if (_lastRequestTime != null) {
//       final timeSinceLastRequest = now.difference(_lastRequestTime!);
//       if (timeSinceLastRequest < _requestDelay) {
//         final delayNeeded = _requestDelay - timeSinceLastRequest;
//         print(
//             'Rate limiting: waiting ${delayNeeded.inMilliseconds}ms before next request');
//         await Future.delayed(delayNeeded);
//       }
//     }
//     _lastRequestTime = now;

//     // Extra delay if too many failures
//     if (_failedAttempts > _maxFailedAttempts) {
//       final extraDelay = Duration(seconds: _failedAttempts * 2);
//       print('Extra delay due to failures: ${extraDelay.inSeconds}s');
//       await Future.delayed(extraDelay);
//     }
//   }

//   Future<void> _loadStreamUrls() async {
//     if (_isInitializing || _isDisposed || _isDisposing) return;

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
//       print('Using user agent: ${_getCurrentUserAgent().substring(0, 60)}...');
//       print('Failed attempts so far: $_failedAttempts');

//       // Add rate limiting delay
//       await _addRequestDelay();

//       if (_isDisposed || _isDisposing || !mounted) return; // Check after delay

//       // Try to get manifest with enhanced error handling
//       StreamManifest? manifest;
//       int retryCount = 0;
//       const maxRetries = 3;

//       while (retryCount < maxRetries &&
//           manifest == null &&
//           !_isDisposed &&
//           !_isDisposing &&
//           mounted) {
//         try {
//           print('Attempt ${retryCount + 1}/$maxRetries to get manifest...');
//           manifest = await _youtubeExplode.videos.streamsClient
//               .getManifest(widget.videoUrl);

//           // Success! Reset failed attempts counter
//           _failedAttempts = 0;
//           print('✅ Manifest loaded successfully on attempt ${retryCount + 1}');
//           break;
//         } catch (manifestError) {
//           retryCount++;
//           print('❌ Manifest error on attempt $retryCount: $manifestError');

//           if (retryCount < maxRetries &&
//               !_isDisposed &&
//               !_isDisposing &&
//               mounted) {
//             // Try with different user agent
//             _rotateUserAgent();
//             print('🔄 Retrying with different user agent...');

//             // Add progressive delay between retries
//             await Future.delayed(Duration(seconds: retryCount * 2));

//             if (_isDisposed || _isDisposing || !mounted)
//               return; // Check after delay
//           } else {
//             throw Exception(
//                 'Failed to get video manifest after $maxRetries attempts: $manifestError');
//           }
//         }
//       }

//       if (_isDisposed || _isDisposing || !mounted) return; // Final check

//       if (manifest == null) {
//         throw Exception('Could not get video manifest after all retries');
//       }

//       // First try: Check for muxed streams (video + audio combined)
//       var muxedStreams = manifest.muxed;
//       print('Found ${muxedStreams?.length ?? 0} muxed streams');

//       if (muxedStreams != null && muxedStreams.isNotEmpty) {
//         print('Using muxed stream approach');
//         await _handleMuxedStreams(muxedStreams);
//         return;
//       }

//       // Second try: Use separate video and audio streams
//       print('No muxed streams, using separate video and audio streams...');

//       // Get best video stream
//       var videoOnlyStreams = manifest.videoOnly;
//       print('Found ${videoOnlyStreams?.length ?? 0} video-only streams');

//       VideoOnlyStreamInfo? bestVideoStream;
//       if (videoOnlyStreams != null && videoOnlyStreams.isNotEmpty) {
//         // Sort by quality and select best
//         var sortedVideoStreams = videoOnlyStreams.toList()
//           ..sort((a, b) =>
//               b.videoResolution.height.compareTo(a.videoResolution.height));

//         bestVideoStream = sortedVideoStreams.first;

//         print(
//             'Selected video stream: ${bestVideoStream.tag} - ${bestVideoStream.videoResolution.height}p');
//       }

//       // Get best audio stream with high quality preference
//       var audioOnlyStreams = manifest.audioOnly;
//       print('Found ${audioOnlyStreams?.length ?? 0} audio-only streams');

//       AudioOnlyStreamInfo? bestAudioStream;
//       if (audioOnlyStreams != null && audioOnlyStreams.isNotEmpty) {
//         // AFTER (Always Best):
//         var sortedAudioStreams = audioOnlyStreams.toList()
//           ..sort((a, b) =>
//               b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond));
//         bestAudioStream = sortedAudioStreams.first;

//         print(
//             'Selected audio stream: ${bestAudioStream.tag} - ${bestAudioStream.audioCodec} - ${bestAudioStream.bitrate}');
//       }

//       if (bestVideoStream != null && bestAudioStream != null) {
//         // Store both URLs for dual stream approach
//         String videoUrl = bestVideoStream.url.toString();
//         String audioUrl = bestAudioStream.url.toString();

//         print(
//             'Video URL loaded: ${videoUrl.length > 50 ? videoUrl.substring(0, 50) + "..." : videoUrl}');
//         print(
//             'Audio URL loaded: ${audioUrl.length > 50 ? audioUrl.substring(0, 50) + "..." : audioUrl}');

//         _videoStreamUrl = videoUrl;
//         _audioStreamUrl = audioUrl;

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() {
//             _controllerCreated = true;
//             _isInitializing = false;
//           });

//           // Wait for the VLC widgets to be created and auto-initialized
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (!_isDisposed && !_isDisposing && mounted) {
//               _initializationTimer = Timer(Duration(milliseconds: 3000), () {
//                 if (mounted && !_isDisposed && !_isDisposing) {
//                   _waitForAutoInitialization();
//                 }
//               });
//             }
//           });
//         }
//       } else {
//         String missingStreams = '';
//         if (bestVideoStream == null) missingStreams += 'video ';
//         if (bestAudioStream == null) missingStreams += 'audio ';

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() {
//             _errorMessage =
//                 'No $missingStreams streams found for this video. This video might be restricted or unavailable.';
//             _isInitializing = false;
//           });
//         }
//       }
//     } catch (e) {
//       print('Error loading streams: $e');
//       print('Stack trace: ${StackTrace.current}');

//       if (_isDisposed || _isDisposing || !mounted)
//         return; // Don't set error if disposed

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
//       } else if (e.toString().contains('403') ||
//           e.toString().contains('Forbidden')) {
//         errorMessage =
//             'Access blocked: Trying different user agent... (${_getCurrentUserAgent().split(' ')[0]})';
//         // Auto-retry with different user agent for 403 errors
//         if (_failedAttempts < _tvUserAgents.length) {
//           Timer(Duration(seconds: 3), () {
//             if (mounted && !_isDisposed && !_isDisposing) {
//               _retryWithDifferentUserAgent();
//             }
//           });
//         }
//       } else if (e.toString().contains('429') ||
//           e.toString().contains('rate')) {
//         errorMessage = 'Rate limited: Please wait before trying again...';
//       }

//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage = errorMessage;
//           _isInitializing = false;
//         });
//       }
//     }
//   }

//   Future<void> _handleMuxedStreams(List<MuxedStreamInfo> muxedStreams) async {
//     if (_isDisposed || _isDisposing || !mounted) return;

//     MuxedStreamInfo? bestStream;

//     // Sort by quality and bitrate
//     var sortedStreams = muxedStreams.toList()
//       ..sort((a, b) {
//         // First priority: video quality
//         int qualityCompare =
//             b.videoResolution.height.compareTo(a.videoResolution.height);
//         if (qualityCompare != 0) return qualityCompare;

//         // Second priority: bitrate
//         return b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond);
//       });

//     bestStream = sortedStreams.first; // Always take the best available

//     String streamUrl = bestStream.url.toString();
//     print(
//         'Selected muxed stream: ${bestStream.tag} - ${bestStream.videoResolution.height}p - Bitrate: ${bestStream.bitrate}');

//     _videoStreamUrl = streamUrl;
//     // For muxed streams, we don't need separate audio
//     _audioStreamUrl = null;

//     if (mounted && !_isDisposed && !_isDisposing) {
//       setState(() {
//         _controllerCreated = true;
//         _isInitializing = false;
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!_isDisposed && !_isDisposing && mounted) {
//           _initializationTimer = Timer(Duration(milliseconds: 3000), () {
//             if (mounted && !_isDisposed && !_isDisposing) {
//               _waitForAutoInitialization();
//             }
//           });
//         }
//       });
//     }
//   }

//   void _createControllers() {
//     if (_videoStreamUrl == null || !mounted || _isDisposed || _isDisposing)
//       return;

//     try {
//       print('Creating controllers with TV user agent...');
//       print(
//           'Current user agent: ${_getCurrentUserAgent().substring(0, 60)}...');

//       // Create video controller
//       _playerController = VlcPlayerController.network(
//         _videoStreamUrl!,
//         hwAcc: HwAcc.auto,
//         autoPlay: false,
//         autoInitialize: true,
//         options: VlcPlayerOptions(
//           advanced: VlcAdvancedOptions([
//             VlcAdvancedOptions.networkCaching(5000),
//             VlcAdvancedOptions.liveCaching(5000),
//           ]),
//           audio: VlcAudioOptions([
//             '--aout=any',
//           ]),
//           video: VlcVideoOptions([
//             '--avcodec-hw=any',
//           ]),
//           http: VlcHttpOptions([
//             '--http-user-agent=${_getCurrentUserAgent()}',
//             '--http-referrer=https://www.youtube.com/',
//           ]),
//           subtitle: VlcSubtitleOptions([]),
//           rtp: VlcRtpOptions([]),
//         ),
//       );

//       print('Video controller created successfully');

//       // Create audio controller if we have separate audio URL
//       if (_audioStreamUrl != null && !_isDisposed && !_isDisposing) {
//         print('Creating separate audio controller for high quality audio...');
//         _audioController = VlcPlayerController.network(
//           _audioStreamUrl!,
//           hwAcc: HwAcc.auto,
//           autoPlay: false,
//           autoInitialize: true,
//           options: VlcPlayerOptions(
//             advanced: VlcAdvancedOptions([
//               VlcAdvancedOptions.networkCaching(5000),
//               VlcAdvancedOptions.liveCaching(5000),
//             ]),
//             audio: VlcAudioOptions([
//               '--aout=any',
//             ]),
//             video: VlcVideoOptions([
//               '--no-video', // Audio only
//             ]),
//             http: VlcHttpOptions([
//               '--http-user-agent=${_getCurrentUserAgent()}',
//               '--http-referrer=https://www.youtube.com/',
//             ]),
//             subtitle: VlcSubtitleOptions([]),
//             rtp: VlcRtpOptions([]),
//           ),
//         );
//         print('Audio controller created successfully');
//         _useDualStream = true;
//       }
//     } catch (e) {
//       print('Error creating controllers: $e');
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage = 'Failed to create video players: $e';
//         });
//       }
//     }
//   }

//   Future<void> _waitForAutoInitialization() async {
//     if (!mounted || _playerController == null || _isDisposed || _isDisposing) {
//       print(
//           'Cannot wait for initialization: widget not mounted or controller null');
//       return;
//     }

//     try {
//       print('Waiting for auto-initialization of controllers...');

//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _isInitializing = true;
//           _errorMessage = null;
//         });
//       }

//       // Wait for auto-initialization to complete
//       int attempts = 0;
//       const maxAttempts = 30;

//       while (attempts < maxAttempts &&
//           mounted &&
//           _playerController != null &&
//           !_isDisposed &&
//           !_isDisposing) {
//         final videoInitialized =
//             _playerController?.value.isInitialized ?? false;
//         final audioInitialized = _audioController?.value.isInitialized ??
//             true; // true if no audio controller

//         print(
//             'Auto-initialization check $attempts: video=$videoInitialized, audio=$audioInitialized');

//         if (videoInitialized && audioInitialized) {
//           print('Controllers auto-initialized successfully');
//           break;
//         }

//         await Future.delayed(Duration(seconds: 1));
//         attempts++;

//         // Check if widget is still mounted after delay
//         if (!mounted || _isDisposed || _isDisposing) {
//           print('Widget disposed during initialization, stopping...');
//           return;
//         }
//       }

//       if (mounted &&
//           _playerController != null &&
//           !_isDisposed &&
//           !_isDisposing) {
//         // Final check
//         final videoInitialized =
//             _playerController?.value.isInitialized ?? false;
//         final audioInitialized = _audioController?.value.isInitialized ?? true;

//         if (videoInitialized && audioInitialized) {
//           if (mounted && !_isDisposed && !_isDisposing) {
//             setState(() {
//               _isInitialized = true;
//               _isInitializing = false;
//             });
//           }

//           print(
//               'Controllers ready for playback (dual stream: $_useDualStream)');
//           _setupSyncListeners();
//           _setupPositionTracking(); // Setup position tracking for video completion

//           // Auto-play after initialization
//           _autoPlayTimer = Timer(Duration(milliseconds: 1500), () {
//             if (mounted && _isInitialized && !_isDisposed && !_isDisposing) {
//               print('Starting auto-play...');
//               _playBoth();
//             }
//           });
//         } else {
//           throw Exception('Controllers failed to auto-initialize');
//         }
//       }
//     } catch (e) {
//       print('Auto-initialization wait error: $e');
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage = 'Failed to initialize video players: $e';
//           _isInitializing = false;
//           _isInitialized = false;
//         });
//       }
//     }
//   }

//   void _setupSyncListeners() {
//     // Only setup sync if properly initialized
//     if (!_isInitialized ||
//         _playerController == null ||
//         !mounted ||
//         _isDisposed ||
//         _isDisposing) {
//       return;
//     }

//     // Cancel any existing subscription
//     _syncSubscription?.cancel();

//     // Start sync after a delay to ensure controllers are ready
//     Timer(Duration(seconds: 3), () {
//       if (mounted &&
//           _isInitialized &&
//           _playerController != null &&
//           !_isDisposed &&
//           !_isDisposing) {
//         // Check every 2 seconds for sync
//         _syncSubscription =
//             Stream.periodic(Duration(seconds: 2)).listen((_) async {
//           if (mounted &&
//               _isInitialized &&
//               _playerController != null &&
//               !_isDisposed &&
//               !_isDisposing) {
//             try {
//               // Check if controllers are initialized before calling getPosition
//               final videoInitialized =
//                   _playerController?.value.isInitialized ?? false;

//               if (videoInitialized) {
//                 final videoPosition =
//                     await _playerController?.getPosition() ?? Duration.zero;

//                 // If using dual stream, sync audio with video
//                 if (_useDualStream &&
//                     _audioController != null &&
//                     !_isDisposed &&
//                     !_isDisposing) {
//                   final audioInitialized =
//                       _audioController?.value.isInitialized ?? false;

//                   if (audioInitialized) {
//                     final audioPosition =
//                         await _audioController?.getPosition() ?? Duration.zero;

//                     // If positions are out of sync by more than 1 second, sync them
//                     final diff = (videoPosition.inMilliseconds -
//                             audioPosition.inMilliseconds)
//                         .abs();
//                     if (diff > 1000 && !_isDisposed && !_isDisposing) {
//                       await _audioController?.seekTo(videoPosition);
//                     }
//                   }
//                 }

//                 if (mounted && !_isDisposed && !_isDisposing) {
//                   setState(() {
//                     _currentPosition = videoPosition;
//                   });
//                 }
//               }
//             } catch (e) {
//               // Don't log sync errors too frequently
//             }
//           }
//         });
//       }
//     });
//   }

//   Future<void> _playBoth() async {
//     if (!_isInitialized ||
//         _playerController == null ||
//         _isDisposed ||
//         _isDisposing) {
//       print('Cannot play: not initialized or controllers are null');
//       return;
//     }

//     try {
//       // Check if controllers are initialized before playing
//       final videoInitialized = _playerController?.value.isInitialized ?? false;

//       if (videoInitialized && !_isDisposed && !_isDisposing) {
//         print('Playing video controller...');
//         await _playerController?.play();

//         // Play audio controller if using dual stream
//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing) {
//           final audioInitialized =
//               _audioController?.value.isInitialized ?? false;
//           if (audioInitialized) {
//             print('Playing audio controller...');
//             await _audioController?.play();
//           }
//         }

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() => _isPlaying = true);
//         }
//         print('Controllers playing (dual stream: $_useDualStream)');
//       } else {
//         print('Controllers not ready');
//       }
//     } catch (e) {
//       print('Error playing: $e');
//     }
//   }

//   Future<void> _pauseBoth() async {
//     if (!_isInitialized ||
//         _playerController == null ||
//         _isDisposed ||
//         _isDisposing) {
//       print('Cannot pause: not initialized or controllers are null');
//       return;
//     }

//     try {
//       final videoInitialized = _playerController?.value.isInitialized ?? false;

//       if (videoInitialized && !_isDisposed && !_isDisposing) {
//         print('Pausing video controller...');
//         await _playerController?.pause();

//         // Pause audio controller if using dual stream
//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing) {
//           final audioInitialized =
//               _audioController?.value.isInitialized ?? false;
//           if (audioInitialized) {
//             print('Pausing audio controller...');
//             await _audioController?.pause();
//           }
//         }

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() => _isPlaying = false);
//         }
//         print('Controllers paused (dual stream: $_useDualStream)');
//       }
//     } catch (e) {
//       print('Error pausing: $e');
//     }
//   }

//   Future<void> _seekBoth(Duration position) async {
//     if (!_isInitialized ||
//         _playerController == null ||
//         _isDisposed ||
//         _isDisposing) {
//       print('Cannot seek: not initialized or controllers are null');
//       return;
//     }

//     try {
//       final videoInitialized = _playerController?.value.isInitialized ?? false;

//       if (videoInitialized && !_isDisposed && !_isDisposing) {
//         print('Seeking video controller to ${position.inSeconds}s...');
//         await _playerController?.seekTo(position);

//         // Seek audio controller if using dual stream
//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing) {
//           final audioInitialized =
//               _audioController?.value.isInitialized ?? false;
//           if (audioInitialized) {
//             print('Seeking audio controller to ${position.inSeconds}s...');
//             await _audioController?.seekTo(position);
//           }
//         }

//         print('Controllers seeked (dual stream: $_useDualStream)');
//       }
//     } catch (e) {
//       print('Error seeking: $e');
//     }
//   }

//   Future<void> _stopBoth() async {
//     if (!_isInitialized ||
//         _playerController == null ||
//         _isDisposed ||
//         _isDisposing) {
//       print('Cannot stop: not initialized or controllers are null');
//       return;
//     }

//     try {
//       final videoInitialized = _playerController?.value.isInitialized ?? false;

//       if (videoInitialized && !_isDisposed && !_isDisposing) {
//         print('Stopping video controller...');
//         await _playerController?.stop();

//         // Stop audio controller if using dual stream
//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing) {
//           final audioInitialized =
//               _audioController?.value.isInitialized ?? false;
//           if (audioInitialized) {
//             print('Stopping audio controller...');
//             await _audioController?.stop();
//           }
//         }

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() => _isPlaying = false);
//         }
//         print('Controllers stopped (dual stream: $_useDualStream)');
//       }
//     } catch (e) {
//       print('Error stopping: $e');
//     }
//   }

//   // Enhanced retry with different user agent
//   Future<void> _retryWithDifferentUserAgent() async {
//     if (_failedAttempts >= _tvUserAgents.length ||
//         _isDisposed ||
//         _isDisposing) {
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage =
//               'All user agents failed. Video may be restricted or temporarily unavailable.';
//         });
//       }
//       return;
//     }

//     _rotateUserAgent();

//     if (mounted && !_isDisposed && !_isDisposing) {
//       setState(() {
//         _errorMessage = null;
//         _isInitialized = false;
//         _isInitializing = false;
//         _controllerCreated = false;
//         _useDualStream = false;
//         _videoStreamUrl = null;
//         _audioStreamUrl = null;
//         _hasNavigatedBack = false; // Reset navigation flag
//         _isNearEnd = false; // Reset end detection flags
//         _endDetectionCount = 0;
//       });
//     }

//     await _disposeControllersSync();

//     // Add delay before retry
//     await Future.delayed(Duration(seconds: 2));

//     if (mounted && !_isDisposed && !_isDisposing) {
//       _loadStreamUrls();
//     }
//   }

//   // Synchronous disposal for retries
//   Future<void> _disposeControllersSync() async {
//     print('Disposing controllers synchronously...');

//     // Cancel all timers first
//     _cancelAllTimers();

//     try {
//       if (_playerController != null) {
//         print('Disposing video controller...');
//         await _playerController?.stop().timeout(Duration(seconds: 2));
//         await _playerController?.dispose().timeout(Duration(seconds: 3));
//         _playerController = null;
//         print('Video controller disposed');
//       }
//       if (_audioController != null) {
//         print('Disposing audio controller...');
//         await _audioController?.stop().timeout(Duration(seconds: 2));
//         await _audioController?.dispose().timeout(Duration(seconds: 3));
//         _audioController = null;
//         print('Audio controller disposed');
//       }
//     } catch (e) {
//       print('Error disposing controllers: $e');
//       // Set to null anyway to prevent further issues
//       _playerController = null;
//       _audioController = null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Wrap the widget with WillPopScope to handle back button
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: _buildPlayerContent(),
//     );
//   }

//   Widget _buildPlayerContent() {
//     // Return empty container if disposed
//     if (_isDisposed || _isDisposing) {
//       return Container(
//         height: screenhgt,
//         color: Colors.black,
//         child: Center(
//           child: Text(
//             'Player disposed',
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       );
//     }

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
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: _isDisposing
//                       ? null
//                       : () {
//                           if (_isDisposed || _isDisposing) return;
//                           setState(() {
//                             _errorMessage = null;
//                             _isInitialized = false;
//                             _isInitializing = false;
//                             _controllerCreated = false;
//                             _useDualStream = false;
//                             _videoStreamUrl = null;
//                             _audioStreamUrl = null;
//                             _failedAttempts = 0; // Reset failed attempts
//                             _hasNavigatedBack = false; // Reset navigation flag
//             _isNearEnd = false; // Reset end detection flags
//             _endDetectionCount = 0;
//                           });
//                           _disposeControllersSync().then((_) {
//                             if (!_isDisposed && !_isDisposing && mounted) {
//                               _loadStreamUrls();
//                             }
//                           });
//                         },
//                   child: Text('Retry'),
//                 ),
//                 SizedBox(width: 16),
//                 ElevatedButton(
//                   onPressed: (_isDisposed || _isDisposing)
//                       ? null
//                       : _retryWithDifferentUserAgent,
//                   child: Text('Try Different Agent'),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Agent ${_currentUserAgentIndex + 1}/${_tvUserAgents.length}: ${_getCurrentUserAgent().substring(0, 30)}...',
//               style: TextStyle(fontSize: 10, color: Colors.grey),
//             ),
//             if (_failedAttempts > 0)
//               Text(
//                 'Failed attempts: $_failedAttempts',
//                 style: TextStyle(fontSize: 10, color: Colors.orange),
//               ),
//           ],
//         ),
//       );
//     }

//     // Show loading if not ready
//     if (!_controllerCreated || (_isInitializing && !_isInitialized)) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text(!_controllerCreated
//                 ? 'Loading YouTube video streams...'
//                 : 'Initializing video players...'),
//             SizedBox(height: 8),
//             Text(
//               'Agent ${_currentUserAgentIndex + 1}/${_tvUserAgents.length}: ${_getCurrentUserAgent().substring(0, 40)}...',
//               style: TextStyle(fontSize: 10, color: Colors.grey),
//               textAlign: TextAlign.center,
//             ),
//             if (_failedAttempts > 0)
//               Padding(
//                 padding: const EdgeInsets.only(top: 4.0),
//                 child: Text(
//                   'Attempts: $_failedAttempts',
//                   style: TextStyle(fontSize: 10, color: Colors.orange),
//                 ),
//               ),
//           ],
//         ),
//       );
//     }

//     // Create controllers when URLs are ready but controllers don't exist yet
//     if (_controllerCreated &&
//         _playerController == null &&
//         !_isDisposed &&
//         !_isDisposing) {
//       _createControllers();
//     }

//     return Stack(
//       children: [
//         // Video player (main layer)
//         Container(
//           height: screenhgt,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             color: Colors.black,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: _playerController != null && !_isDisposed && !_isDisposing
//                 ? VlcPlayer(
//                     controller: _playerController!,
//                     aspectRatio: 16 / 9,
//                     placeholder: const Center(
//                       child: Text(
//                         'Loading Video...',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   )
//                 : Container(
//                     color: Colors.black,
//                     child: const Center(
//                       child: CircularProgressIndicator(),
//                     ),
//                   ),
//           ),
//         ),

//         // Audio player (hidden - केवल audio के लिए)
//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing)
//           Positioned(
//             top: -1000, // Screen के बाहर hide कर देते हैं
//             child: Container(
//               height: 1,
//               width: 1,
//               child: VlcPlayer(
//                 controller: _audioController!,
//                 aspectRatio: 1,
//               ),
//             ),
//           ),

//         // Debug info with position and navigation status
//         if (_isInitialized && _totalDuration.inSeconds > 0)
//           Positioned(
//             top: 20,
//             left: 20,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.black54,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
//                     style: TextStyle(fontSize: 10, color: Colors.white),
//                   ),
//                   if (_isNearEnd)
//                     Text(
//                       'Near End (Count: $_endDetectionCount)',
//                       style: TextStyle(fontSize: 10, color: Colors.orange),
//                     ),
//                   if (_hasNavigatedBack)
//                     Text(
//                       'Cleanup in Progress...',
//                       style: TextStyle(fontSize: 10, color: Colors.green),
//                     ),
//                 ],
//               ),
//             ),
//           ),

//         // Video completion overlay when cleanup is in progress
//         if (_hasNavigatedBack && !_isDisposed && !_isDisposing)
//           Positioned.fill(
//             child: Container(
//               color: Colors.black54,
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(color: Colors.white),
//                     SizedBox(height: 16),
//                     Text(
//                       'Video Completed\nReturning to previous page...',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//         // Video completion indicator (optional - for debugging)
//         if (_hasNavigatedBack && !_isDisposed && !_isDisposing)
//           Positioned(
//             bottom: 20,
//             left: 20,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.green.withOpacity(0.8),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(
//                 'Video Completed - Navigating Back',
//                 style: TextStyle(fontSize: 10, color: Colors.white),
//               ),
//             ),
//           ),
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
//     print('Disposing CustomYoutubePlayer - starting cleanup...');
//     KeepScreenOn.turnOff(); // Turn off keep screen on when disposing
//     // Remove lifecycle observer
//     WidgetsBinding.instance.removeObserver(this);

//     // Mark as disposing to prevent any new operations
//     _isDisposing = true;

//     // Cancel all timers and subscriptions immediately
//     _cancelAllTimers();

//     // Start background disposal process
//     _disposeControllersInBackground();

//     // Call super.dispose() immediately to free up the widget
//     super.dispose();
//     print('Widget disposed successfully');
//   }
// }








// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:youtube_explode_dart/youtube_explode_dart.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:ui';
// import 'dart:async';
// import 'package:keep_screen_on/keep_screen_on.dart';

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
//     with TickerProviderStateMixin, WidgetsBindingObserver {
//   VlcPlayerController? _playerController;
//   VlcPlayerController? _audioController;
//   final YoutubeExplode _youtubeExplode = YoutubeExplode();

//   // Maximum allowed video resolution height (No 2K/4K/8K)
//   static const int MAX_VIDEO_HEIGHT = 1080;

//   bool _isPlaying = false;
//   bool _isInitialized = false;
//   bool _isInitializing = false;
//   bool _controllerCreated = false;
//   bool _useDualStream = false;
//   bool _isDisposed = false;
//   bool _isDisposing = false;
//   bool _showControls = false;
//   bool _isSeeking = false; // Add seeking state to prevent audio overlap
//   Duration _currentPosition = Duration.zero;
//   Duration _totalDuration = Duration.zero;
//   bool _earlyPauseTriggered = false;
//   String? _errorMessage;
//   String? _videoStreamUrl;
//   String? _audioStreamUrl;

//   // Control UI variables
//   Timer? _controlsTimer;
//   Timer? _seekTimer;
//   bool _isSeekingLeft = false;
//   bool _isSeekingRight = false;
//   final FocusNode _focusNode = FocusNode();

//   // Progressive seeking states (from YouTube player code)
//   Timer? _progressiveSeekTimer;
//   int _pendingSeekSeconds = 0;
//   Duration _targetSeekPosition = Duration.zero;
//   bool _isProgressiveSeeking = false;

//   // Stream subscriptions for proper cleanup
//   StreamSubscription? _syncSubscription;
//   StreamSubscription? _positionTrackingSubscription;
//   Timer? _initializationTimer;
//   Timer? _autoPlayTimer;
//   Timer? _seekDebounceTimer; // Add debounce timer for seeking

//   // Enhanced TV User Agents
//   final List<String> _tvUserAgents = [
//     'Mozilla/5.0 (SMART-TV; Linux; Tizen 7.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36',
//     'Mozilla/5.0 (Web0S; Linux/SmartTV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 webOS/6.0',
//     'Mozilla/5.0 (Linux; Android 11; SHIELD Android TV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Safari/537.36',
//     'Mozilla/5.0 (X11; Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chromium/90.0.4430.225 Chrome/90.0.4430.225 Safari/537.36',
//     'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
//     'Mozilla/5.0 (iPad; CPU OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
//     'Mozilla/5.0 (Linux; Android 11; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Mobile Safari/537.36',
//     'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Safari/537.36',
//     'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Safari/537.36',
//   ];

//   int _currentUserAgentIndex = 0;
//   int _failedAttempts = 0;
//   final int _maxFailedAttempts = 3;
//   DateTime? _lastRequestTime;
//   final Duration _requestDelay = Duration(seconds: 2);

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _loadStreamUrls();
//     KeepScreenOn.turnOn();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusNode.requestFocus();
//     });
//   }

//   // Enhanced keyboard handling with progressive seek (from YouTube player code)
//   void _handleKeyEvent(RawKeyEvent event) {
//     if (event is RawKeyDownEvent) {
//       switch (event.logicalKey) {
//         case LogicalKeyboardKey.select:
//         case LogicalKeyboardKey.space:
//         case LogicalKeyboardKey.enter:
//           _togglePlayPause();
//           break;
//         case LogicalKeyboardKey.arrowLeft:
//           // Use progressive seek instead of continuous
//           _seekVideoProgressive(false);
//           _showControlsTemporarily();
//           break;
//         case LogicalKeyboardKey.arrowRight:
//           // Use progressive seek instead of continuous
//           _seekVideoProgressive(true);
//           _showControlsTemporarily();
//           break;
//         case LogicalKeyboardKey.arrowUp:
//         case LogicalKeyboardKey.arrowDown:
//           _showControlsTemporarily();
//           break;
//       }
//     }
//     // Remove key up handling since we're not using continuous seek
//   }


// // 1. FIXED: _executeProgressiveSeek - Remove audio restart attempts
// void _executeProgressiveSeek(bool wasPlaying) async {
//   if (!_isInitialized || 
//       _playerController == null || 
//       _isDisposed || 
//       _isDisposing || 
//       _pendingSeekSeconds == 0) {
//     return;
//   }

//   final adjustedEndTime = _totalDuration.inSeconds - 12;
//   final currentSeconds = _currentPosition.inSeconds;
//   final newPosition = (currentSeconds + _pendingSeekSeconds)
//       .clamp(0, adjustedEndTime);

//   try {
//     print('🎯 Executing progressive seek to ${newPosition}s...');
    
//     // Ensure both players are paused before seeking
//     await _pauseBothImmediate();
    
//     // Wait a moment for pause to take effect
//     await Future.delayed(Duration(milliseconds: 100));
    
//     // Perform the actual seek
//     await _seekBothControllersOnly(Duration(seconds: newPosition));
    
//     // Wait for seek to complete and sync
//     await Future.delayed(Duration(milliseconds: 300));
    
//     // ALWAYS auto play after seek (NO RETRY ATTEMPTS)
//     print('▶️ Auto-playing after progressive seek...');
//     await _playBothAfterSeekSimple(); // Use simple version

//   } catch (e) {
//     print('❌ Progressive seek error: $e');
    
//     // Emergency recovery - SIMPLE attempt only
//     try {
//       print('🔄 Emergency recovery - simple auto play...');
//       await _playBothAfterSeekSimple();
//     } catch (recoveryError) {
//       print('❌ Recovery failed: $recoveryError');
//     }
//   } finally {
//     // Reset progressive seek state
//     _pendingSeekSeconds = 0;
//     _targetSeekPosition = Duration.zero;

//     if (mounted && !_isDisposed && !_isDisposing) {
//       setState(() {
//         _isProgressiveSeeking = false;
//       });
//     }
//   }
// }

// // 2. IMPROVED: Simple play method with initial sync
// Future<void> _playBothAfterSeekSimple() async {
//   try {
//     final videoInitialized = _playerController?.value.isInitialized ?? false;
    
//     if (videoInitialized && !_isDisposed && !_isDisposing) {
//       print('▶️ Starting video controller...');
//       await _playerController?.play();
      
//       if (_useDualStream && _audioController != null) {
//         final audioInitialized = _audioController?.value.isInitialized ?? false;
//         if (audioInitialized) {
//           // CRITICAL: Ensure audio is at same position as video before starting
//           final videoPos = await _playerController?.getPosition() ?? Duration.zero;
//           await _audioController?.seekTo(videoPos);
          
//           // Small delay for seek to complete
//           await Future.delayed(Duration(milliseconds: 100));
          
//           print('🎵 Starting audio controller with sync...');
//           await _audioController?.play();
          
//           // SINGLE verification after short delay (not continuous)
//           Timer(Duration(milliseconds: 300), () async {
//             if (_audioController != null && !_isDisposed && _isPlaying) {
//               final audioPlaying = _audioController?.value.isPlaying ?? false;
//               if (!audioPlaying) {
//                 print('🔄 Audio failed to start - ONE retry attempt');
//                 try {
//                   await _audioController?.play();
//                 } catch (e) {
//                   print('❌ Audio retry failed: $e');
//                 }
//               }
//             }
//           });
//         }
//       }
      
//       // Update state to reflect playing
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() => _isPlaying = true);
//       }
      
//       print('✅ Both players resumed after seek with sync');
//     }
//   } catch (e) {
//     print('❌ Error resuming after seek: $e');
//     throw e;
//   }
// }

// // 3. FIXED: Regular seek method - use simple play
// Future<void> _seekBothWithDebounce(Duration position) async {
//   if (!_isInitialized ||
//       _playerController == null ||
//       _isDisposed ||
//       _isDisposing ||
//       _isSeeking) {
//     return;
//   }

//   _isSeeking = true;
//   bool wasPlaying = _isPlaying;

//   try {
//     print('🎯 Regular seek to ${position.inSeconds}s (was playing: $wasPlaying)...');

//     // ALWAYS pause first to prevent audio issues
//     await _pauseBothImmediate();

//     // Wait for pause to take effect
//     await Future.delayed(Duration(milliseconds: 150));

//     // Perform the seek
//     await _seekBothControllersOnly(position);

//     // Wait for seek to complete
//     await Future.delayed(Duration(milliseconds: 200));

//     // ALWAYS auto play after seek - USE SIMPLE VERSION
//     print('▶️ Auto-playing after regular seek...');
//     await _playBothAfterSeekSimple();

//     print('✅ Regular seek completed - Video auto-playing');
    
//   } catch (e) {
//     print('❌ Error in regular seek: $e');

//     // Emergency recovery - SIMPLE attempt only
//     try {
//       print('🔄 Emergency recovery - simple auto play...');
//       await _playBothAfterSeekSimple();
//     } catch (recoveryError) {
//       print('❌ Emergency recovery failed: $recoveryError');
//     }
//   } finally {
//     // Reset seeking state after a delay
//     Timer(Duration(milliseconds: 400), () {
//       _isSeeking = false;
//     });
//   }
// }

// // 4. COMPLETELY FIXED: Update position with proper end detection
// Future<void> _updatePosition() async {
//   try {
//     final videoInitialized = _playerController?.value.isInitialized ?? false;
//     if (!videoInitialized) return;

//     final currentPos = await _playerController?.getPosition() ?? Duration.zero;
//     final totalDur = await _playerController?.getDuration() ?? Duration.zero;

//     // FIXED: Multiple end detection checks
//     if (totalDur.inSeconds > 10) { // Only for videos longer than 10 seconds
      
//       // Check if we're 6 seconds before end
//       if (!_earlyPauseTriggered && currentPos.inSeconds >= totalDur.inSeconds - 6) {
//         print('⏸️ Auto-pausing 6 seconds before end (${currentPos.inSeconds}/${totalDur.inSeconds})');
//         _earlyPauseTriggered = true;
        
//         // FORCE STOP both controllers immediately
//         try {
//           await _playerController?.pause();
//           if (_useDualStream && _audioController != null) {
//             await _audioController?.pause();
//             // Also stop audio completely to prevent repeat
//             await _audioController?.stop();
//           }
          
//           if (mounted && !_isDisposed && !_isDisposing) {
//             setState(() => _isPlaying = false);
//           }
          
//           print('✅ Both players stopped at 6 seconds before end');
//         } catch (e) {
//           print('❌ Error stopping players before end: $e');
//         }
        
//         return; // Don't update position after stopping
//       }
      
//       // Additional check - if we're at the very end
//       if (currentPos.inSeconds >= totalDur.inSeconds - 1) {
//         print('🛑 Video at end - force stopping');
//         try {
//           await _playerController?.stop();
//           if (_useDualStream && _audioController != null) {
//             await _audioController?.stop();
//           }
//           if (mounted && !_isDisposed && !_isDisposing) {
//             setState(() => _isPlaying = false);
//           }
//         } catch (e) {
//           print('❌ Error force stopping at end: $e');
//         }
//         return;
//       }
//     }

//     // Normal position update
//     if (mounted && !_isDisposed && !_isDisposing) {
//       setState(() {
//         _currentPosition = currentPos;
//         _totalDuration = totalDur;
//       });
//     }
//   } catch (e) {
//     print('Position update error: $e');
//   }
// }

// // 5. BALANCED: Sync listeners - Only essential sync, no repeat sounds
// void _setupSyncListeners() {
//   if (!_isInitialized ||
//       _playerController == null ||
//       !mounted ||
//       _isDisposed ||
//       _isDisposing) {
//     return;
//   }

//   _syncSubscription?.cancel();

//   Timer(Duration(seconds: 2), () {
//     if (mounted &&
//         _isInitialized &&
//         _playerController != null &&
//         !_isDisposed &&
//         !_isDisposing) {
//       _syncSubscription =
//           Stream.periodic(Duration(milliseconds: 1500)).listen((_) async { // Balanced frequency
//         if (mounted &&
//             _isInitialized &&
//             _playerController != null &&
//             !_isDisposed &&
//             !_isDisposing &&
//             !_isSeeking &&
//             !_isProgressiveSeeking &&
//             _isPlaying) { // Only sync when actually playing
//           try {
//             final videoInitialized =
//                 _playerController?.value.isInitialized ?? false;

//             if (videoInitialized) {
//               final videoPosition =
//                   await _playerController?.getPosition() ?? Duration.zero;

//               // ESSENTIAL AUDIO SYNC - Only when needed for lip sync
//               if (_useDualStream &&
//                   _audioController != null &&
//                   !_isDisposed &&
//                   !_isDisposing) {
//                 final audioInitialized =
//                     _audioController?.value.isInitialized ?? false;

//                 if (audioInitialized) {
//                   try {
//                     final audioPosition =
//                         await _audioController?.getPosition() ?? Duration.zero;
//                     final syncDiff = (videoPosition.inMilliseconds -
//                             audioPosition.inMilliseconds).abs();

//                     // CRITICAL: Only sync if there's significant delay (500ms+) for lip sync
//                     if (syncDiff > 500 && syncDiff < 5000) { // Between 0.5s and 5s difference
//                       print('🔄 Lip sync correction: ${syncDiff}ms difference');
                      
//                       // SMART SYNC: Only seek audio, don't restart playback
//                       await _audioController?.seekTo(videoPosition);
                      
//                       // Small delay then verify audio is still playing
//                       await Future.delayed(Duration(milliseconds: 100));
//                       final audioStillPlaying = _audioController?.value.isPlaying ?? false;
                      
//                       // ONLY restart if audio actually stopped (not just out of sync)
//                       if (!audioStillPlaying && _isPlaying) {
//                         print('🎵 Audio stopped after sync - restarting ONCE');
//                         await _audioController?.play();
//                       }
//                     }
                    
//                     // PREVENT AUDIO RESTART LOOPS
//                     else if (syncDiff > 5000) {
//                       print('⚠️ Major audio desync (${syncDiff}ms) - ignoring to prevent loops');
//                     }
//                   } catch (audioSyncError) {
//                     // Silent audio sync errors to prevent spam
//                   }
//                 }
//               }

//               // Always update position for UI
//               if (mounted && !_isDisposed && !_isDisposing) {
//                 setState(() {
//                   _currentPosition = videoPosition;
//                 });
//               }
//             }
//           } catch (e) {
//             // Silent all other errors
//           }
//         }
//       });
//     }
//   });
// }

// // 6. IMPROVED: Enhanced play method with initial sync
// Future<void> _playBoth() async {
//   if (!_isInitialized ||
//       _playerController == null ||
//       _isDisposed ||
//       _isDisposing) {
//     print('Cannot play: not initialized or controllers are null');
//     return;
//   }

//   _earlyPauseTriggered = false;

//   try {
//     final videoInitialized = _playerController?.value.isInitialized ?? false;

//     if (videoInitialized && !_isDisposed && !_isDisposing) {
//       print('▶️ Playing video controller...');
//       // Reset volume in case it was muted
//       await _playerController?.setVolume(100);
//       await _playerController?.play();

//       if (_useDualStream &&
//           _audioController != null &&
//           !_isDisposed &&
//           !_isDisposing) {
//         final audioInitialized =
//             _audioController?.value.isInitialized ?? false;
//         if (audioInitialized) {
//           print('🎵 Playing audio controller with sync...');
//           // Reset volume in case it was muted
//           await _audioController?.setVolume(100);
          
//           // IMPORTANT: Sync audio position with video before starting
//           final videoPos = await _playerController?.getPosition() ?? Duration.zero;
//           await _audioController?.seekTo(videoPos);
//           await Future.delayed(Duration(milliseconds: 50));
          
//           await _audioController?.play();

//           // SINGLE verification after start (not continuous loop)
//           Timer(Duration(milliseconds: 500), () async {
//             if (_audioController != null && !_isDisposed && _isPlaying) {
//               final audioPlaying = _audioController?.value.isPlaying ?? false;
//               if (!audioPlaying) {
//                 print('🔄 Audio verification - ONE restart attempt');
//                 try {
//                   await _audioController?.play();
//                 } catch (e) {
//                   print('❌ Audio restart failed: $e');
//                 }
//               }
//             }
//           });
//         }
//       }

//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() => _isPlaying = true);
//       }
//       print('✅ Controllers playing with lip sync (dual stream: $_useDualStream)');
//     } else {
//       print('❌ Controllers not ready');
//     }
//   } catch (e) {
//     print('❌ Error playing: $e');
//   }
// }

// // 7. ADDITIONAL: Add method to completely stop audio repeats
// Future<void> _forceStopAllAudio() async {
//   try {
//     print('🛑 Force stopping all audio to prevent repeats...');
    
//     if (_playerController != null) {
//       await _playerController?.pause();
//       // Also mute video audio
//       await _playerController?.setVolume(0);
//     }
    
//     if (_useDualStream && _audioController != null) {
//       await _audioController?.pause();
//       await _audioController?.stop();
//       await _audioController?.setVolume(0);
//     }
    
//     if (mounted && !_isDisposed && !_isDisposing) {
//       setState(() => _isPlaying = false);
//     }
    
//     print('✅ All audio stopped and muted');
//   } catch (e) {
//     print('❌ Error force stopping audio: $e');
//   }
// }








//   // Enhanced Progressive Seeking with ALWAYS auto play
// void _seekVideoProgressive(bool forward) {
//   if (!_isInitialized || 
//       _playerController == null || 
//       _totalDuration.inSeconds <= 24 || 
//       _isDisposed || 
//       _isDisposing) {
//     return;
//   }

//   // Calculate seek amount based on video duration (like YouTube code)
//   final adjustedEndTime = _totalDuration.inSeconds - 12;
//   final seekAmount = (adjustedEndTime / 200).round().clamp(5, 30);

//   // IMMEDIATELY pause both players when seeking starts
//   if (!_isProgressiveSeeking) {
//     print('🔄 Starting progressive seek - pausing players...');
//     _pauseBothImmediate(); // Pause immediately without delay
//   }

//   // Cancel existing timer
//   _progressiveSeekTimer?.cancel();

//   // Accumulate seek amount
//   if (forward) {
//     _pendingSeekSeconds += seekAmount;
//   } else {
//     _pendingSeekSeconds -= seekAmount;
//   }

//   // Calculate target position
//   final currentSeconds = _currentPosition.inSeconds;
//   final targetSeconds = (currentSeconds + _pendingSeekSeconds)
//       .clamp(0, adjustedEndTime);
//   _targetSeekPosition = Duration(seconds: targetSeconds);

//   // Update UI to show seeking state
//   if (mounted && !_isDisposed && !_isDisposing) {
//     setState(() {
//       _isProgressiveSeeking = true;
//     });
//   }

//   // Set timer to execute seek after delay (accumulates multiple presses)
//   // Note: Removed wasPlaying parameter since we always want to auto play
//   _progressiveSeekTimer = Timer(const Duration(milliseconds: 1000), () {
//     _executeProgressiveSeek(true); // Always pass true for auto play
//   });
// }








// // New method: Immediate pause without state checks
// Future<void> _pauseBothImmediate() async {
//   try {
//     final videoInitialized = _playerController?.value.isInitialized ?? false;
    
//     if (videoInitialized && !_isDisposed && !_isDisposing) {
//       await _playerController?.pause();
      
//       if (_useDualStream && _audioController != null) {
//         final audioInitialized = _audioController?.value.isInitialized ?? false;
//         if (audioInitialized) {
//           await _audioController?.pause();
//         }
//       }
      
//       // Update state to reflect pause
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() => _isPlaying = false);
//       }
      
//       print('⏸️ Both players paused immediately');
//     }
//   } catch (e) {
//     print('❌ Error in immediate pause: $e');
//   }
// }

// // New method: Only perform seek without play/pause logic
// Future<void> _seekBothControllersOnly(Duration position) async {
//   try {
//     // Seek video controller first
//     final videoInitialized = _playerController?.value.isInitialized ?? false;
//     if (videoInitialized) {
//       print('🎬 Seeking video controller to ${position.inSeconds}s...');
//       await _playerController?.seekTo(position);
//     }

//     // Seek audio controller with extra sync
//     if (_useDualStream && _audioController != null) {
//       final audioInitialized = _audioController?.value.isInitialized ?? false;
//       if (audioInitialized) {
//         print('🎵 Seeking audio controller to ${position.inSeconds}s...');
//         await _audioController?.seekTo(position);
        
//         // Additional audio sync attempt
//         await Future.delayed(Duration(milliseconds: 50));
//         await _audioController?.seekTo(position);
//       }
//     }

//     // Update position immediately
//     if (mounted && !_isDisposed && !_isDisposing) {
//       setState(() {
//         _currentPosition = position;
//       });
//     }
    
//     print('✅ Seek operation completed');
//   } catch (e) {
//     print('❌ Error in seek controllers: $e');
//     throw e; // Re-throw to handle in caller
//   }
// }

// // New method: Play both after seek with proper sync and GUARANTEED start
// Future<void> _playBothAfterSeek() async {
//   try {
//     final videoInitialized = _playerController?.value.isInitialized ?? false;
    
//     if (videoInitialized && !_isDisposed && !_isDisposing) {
//       print('▶️ Starting video controller...');
//       await _playerController?.play();
      
//       if (_useDualStream && _audioController != null) {
//         final audioInitialized = _audioController?.value.isInitialized ?? false;
//         if (audioInitialized) {
//           // Small delay for video to start first
//           await Future.delayed(Duration(milliseconds: 50));
          
//           print('🎵 Starting audio controller with sync...');
//           await _audioController?.play();
          
//           // Multiple verification attempts to ensure audio starts
//           int verificationAttempts = 0;
//           const maxVerificationAttempts = 3;
          
//           Timer.periodic(Duration(milliseconds: 200), (timer) async {
//             verificationAttempts++;
            
//             if (_audioController == null || _isDisposed || verificationAttempts > maxVerificationAttempts) {
//               timer.cancel();
//               return;
//             }
            
//             final audioPlaying = _audioController?.value.isPlaying ?? false;
//             final videoPlaying = _playerController?.value.isPlaying ?? false;
            
//             if (!audioPlaying && videoPlaying) {
//               print('🔄 Audio verification attempt $verificationAttempts - restarting audio...');
//               try {
//                 await _audioController?.play();
//               } catch (e) {
//                 print('❌ Audio restart attempt $verificationAttempts failed: $e');
//               }
//             } else if (audioPlaying) {
//               print('✅ Audio verified playing after seek (attempt $verificationAttempts)');
//               timer.cancel();
//             }
            
//             if (verificationAttempts >= maxVerificationAttempts) {
//               print('⚠️ Max audio verification attempts reached');
//               timer.cancel();
//             }
//           });
//         }
//       }
      
//       // Update state to reflect playing
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() => _isPlaying = true);
//       }
      
//       // Additional verification for video playback
//       Timer(Duration(milliseconds: 500), () async {
//         if (_playerController != null && !_isDisposed) {
//           final videoStillPlaying = _playerController?.value.isPlaying ?? false;
//           if (!videoStillPlaying) {
//             print('🔄 Video stopped unexpectedly, restarting...');
//             try {
//               await _playerController?.play();
//               if (mounted && !_isDisposed && !_isDisposing) {
//                 setState(() => _isPlaying = true);
//               }
//             } catch (e) {
//               print('❌ Video restart failed: $e');
//             }
//           } else {
//             print('✅ Video confirmed playing after seek');
//           }
//         }
//       });
      
//       print('✅ Both players resumed after seek - AUTO PLAY GUARANTEED');
//     }
//   } catch (e) {
//     print('❌ Error resuming after seek: $e');
    
//     // CRITICAL: Emergency auto-play attempt
//     try {
//       print('🚨 EMERGENCY AUTO-PLAY ATTEMPT...');
//       if (_playerController != null && !_isDisposed) {
//         await _playerController?.play();
//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() => _isPlaying = true);
//         }
//       }
//       if (_useDualStream && _audioController != null && !_isDisposed) {
//         await _audioController?.play();
//       }
//       print('🆘 Emergency auto-play completed');
//     } catch (emergencyError) {
//       print('💀 Emergency auto-play also failed: $emergencyError');
//     }
    
//     throw e; // Re-throw to handle in caller
//   }
// }






//   // // Enhanced Progressive Seeking (from YouTube player code)
//   // void _seekVideoProgressive(bool forward) {
//   //   if (!_isInitialized || 
//   //       _playerController == null || 
//   //       _totalDuration.inSeconds <= 24 || 
//   //       _isDisposed || 
//   //       _isDisposing) {
//   //     return;
//   //   }

//   //   // Calculate seek amount based on video duration (like YouTube code)
//   //   final adjustedEndTime = _totalDuration.inSeconds - 12;
//   //   final seekAmount = (adjustedEndTime / 200).round().clamp(5, 30);

//   //   // Cancel existing timer
//   //   _progressiveSeekTimer?.cancel();

//   //   // Accumulate seek amount
//   //   if (forward) {
//   //     _pendingSeekSeconds += seekAmount;
//   //   } else {
//   //     _pendingSeekSeconds -= seekAmount;
//   //   }

//   //   // Calculate target position
//   //   final currentSeconds = _currentPosition.inSeconds;
//   //   final targetSeconds = (currentSeconds + _pendingSeekSeconds)
//   //       .clamp(0, adjustedEndTime);
//   //   _targetSeekPosition = Duration(seconds: targetSeconds);

//   //   // Update UI to show seeking state
//   //   if (mounted && !_isDisposed && !_isDisposing) {
//   //     setState(() {
//   //       _isProgressiveSeeking = true;
//   //     });
//   //   }

//   //   // Set timer to execute seek after delay (accumulates multiple presses)
//   //   _progressiveSeekTimer = Timer(const Duration(milliseconds: 1000), () {
//   //     _executeProgressiveSeek();
//   //   });
//   // }

//   // void _executeProgressiveSeek() async {
//   //   if (!_isInitialized || 
//   //       _playerController == null || 
//   //       _isDisposed || 
//   //       _isDisposing || 
//   //       _pendingSeekSeconds == 0) {
//   //     return;
//   //   }

//   //   final adjustedEndTime = _totalDuration.inSeconds - 12;
//   //   final currentSeconds = _currentPosition.inSeconds;
//   //   final newPosition = (currentSeconds + _pendingSeekSeconds)
//   //       .clamp(0, adjustedEndTime);

//   //   try {
//   //     // Use existing VLC seek method
//   //     await _seekBothWithDebounce(Duration(seconds: newPosition));

//   //   } catch (e) {
//   //     print('Progressive seek error: $e');
//   //   } finally {
//   //     // Reset progressive seek state
//   //     _pendingSeekSeconds = 0;
//   //     _targetSeekPosition = Duration.zero;

//   //     if (mounted && !_isDisposed && !_isDisposing) {
//   //       setState(() {
//   //         _isProgressiveSeeking = false;
//   //       });
//   //     }
//   //   }
//   // }

//   void _showControlsTemporarily() {
//     setState(() {
//       _showControls = true;
//     });

//     _controlsTimer?.cancel();
//     _controlsTimer = Timer(Duration(seconds: 5), () {
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _showControls = false;
//         });
//       }
//     });
//   }

//   void _togglePlayPause() {
//     if (_isPlaying) {
//       _pauseBoth();
//     } else {
//       _playBoth();
//     }
//     _showControlsTemporarily();
//   }

//   // // Fixed seeking with debouncing to prevent audio overlap
//   // void _seekBackwardDebounced() {
//   //   if (_isSeeking || _isProgressiveSeeking) return;

//   //   _seekDebounceTimer?.cancel();
//   //   _seekDebounceTimer = Timer(Duration(milliseconds: 100), () {
//   //     final newPosition = _currentPosition - Duration(seconds: 10);
//   //     final targetPosition =
//   //         newPosition < Duration.zero ? Duration.zero : newPosition;
//   //     _seekBothWithDebounce(targetPosition);
//   //   });
//   // }

//   // void _seekForwardDebounced() {
//   //   if (_isSeeking || _isProgressiveSeeking) return;

//   //   _seekDebounceTimer?.cancel();
//   //   _seekDebounceTimer = Timer(Duration(milliseconds: 100), () {
//   //     final newPosition = _currentPosition + Duration(seconds: 10);
//   //     final targetPosition =
//   //         newPosition > _totalDuration ? _totalDuration : newPosition;
//   //     _seekBothWithDebounce(targetPosition);
//   //   });
//   // }

//   // // Fixed seek method with proper audio restoration
//   // Future<void> _seekBothWithDebounce(Duration position) async {
//   //   if (!_isInitialized ||
//   //       _playerController == null ||
//   //       _isDisposed ||
//   //       _isDisposing ||
//   //       _isSeeking) {
//   //     return;
//   //   }

//   //   _isSeeking = true;
//   //   bool wasPlaying = _isPlaying;
//   //   _earlyPauseTriggered = false;

//   //   try {
//   //     print(
//   //         '🎯 Seeking to ${position.inSeconds}s (was playing: $wasPlaying)...');

//   //     // Always pause first to prevent audio issues
//   //     await _playerController?.pause();
//   //     if (_useDualStream && _audioController != null) {
//   //       await _audioController?.pause();
//   //     }

//   //     // Wait for pause to take effect
//   //     await Future.delayed(Duration(milliseconds: 100));

//   //     // Seek video controller first
//   //     final videoInitialized = _playerController?.value.isInitialized ?? false;
//   //     if (videoInitialized) {
//   //       print('🎬 Seeking video controller...');
//   //       await _playerController?.seekTo(position);
//   //     }

//   //     // Seek audio controller with extra sync
//   //     if (_useDualStream && _audioController != null) {
//   //       final audioInitialized = _audioController?.value.isInitialized ?? false;
//   //       if (audioInitialized) {
//   //         print('🎵 Seeking audio controller...');
//   //         await _audioController?.seekTo(position);

//   //         // Additional audio sync attempt
//   //         await Future.delayed(Duration(milliseconds: 50));
//   //         await _audioController?.seekTo(position);
//   //       }
//   //     }

//   //     // Wait for seek to complete
//   //     await Future.delayed(Duration(milliseconds: 200));

//   //     // Force resume playback if it was playing before
//   //     if (wasPlaying) {
//   //       print('▶️ Resuming playback after seek...');

//   //       // Start video first
//   //       await _playerController?.play();

//   //       // Then start audio with slight delay for sync
//   //       if (_useDualStream && _audioController != null) {
//   //         await Future.delayed(Duration(milliseconds: 50));
//   //         await _audioController?.play();

//   //         // Verify audio is actually playing
//   //         Timer(Duration(milliseconds: 500), () async {
//   //           if (_audioController != null && wasPlaying && !_isDisposed) {
//   //             final audioPlaying = _audioController?.value.isPlaying ?? false;
//   //             if (!audioPlaying) {
//   //               print('🔄 Audio not playing, forcing restart...');
//   //               await _audioController?.play();
//   //             }
//   //           }
//   //         });
//   //       }

//   //       // Update playing state
//   //       if (mounted && !_isDisposed && !_isDisposing) {
//   //         setState(() {
//   //           _isPlaying = true;
//   //         });
//   //       }
//   //     }

//   //     // Update position immediately
//   //     if (mounted && !_isDisposed && !_isDisposing) {
//   //       setState(() {
//   //         _currentPosition = position;
//   //       });
//   //     }

//   //     print(
//   //         '✅ Seek completed - Audio should be ${wasPlaying ? "playing" : "paused"}');
//   //   } catch (e) {
//   //     print('❌ Error seeking: $e');

//   //     // Emergency audio recovery
//   //     if (wasPlaying && _useDualStream && _audioController != null) {
//   //       try {
//   //         await _audioController?.play();
//   //       } catch (recoveryError) {
//   //         print('❌ Audio recovery failed: $recoveryError');
//   //       }
//   //     }
//   //   } finally {
//   //     // Reset seeking state
//   //     Timer(Duration(milliseconds: 300), () {
//   //       _isSeeking = false;
//   //     });
//   //   }
//   // }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);

//     switch (state) {
//       case AppLifecycleState.paused:
//       case AppLifecycleState.detached:
//         print('App paused/detached - stopping players safely');
//         _stopPlayersForBackground();
//         break;
//       case AppLifecycleState.resumed:
//         print('App resumed');
//         break;
//       default:
//         break;
//     }
//   }

//   void _stopPlayersForBackground() {
//     if (_isDisposed || _isDisposing) return;

//     try {
//       _playerController?.pause();
//       _audioController?.pause();
//       setState(() {
//         _isPlaying = false;
//       });
//     } catch (e) {
//       print('Error stopping players for background: $e');
//     }
//   }

//   Future<bool> _onWillPop() async {
//     print('Back button pressed - initiating safe disposal');

//     if (_isDisposing || _isDisposed) {
//       return true;
//     }

//     if (!Navigator.canPop(context)) {
//       print('⚠️ This is root page - preventing app close');
//       _showExitDialog();
//       return false;
//     }

//     _startSafeDisposal();
//     return true;
//   }

//   void _showExitDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Exit App?'),
//           content: Text('Do you want to exit the application?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Exit'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _startSafeDisposal() {
//     if (_isDisposing || _isDisposed) return;

//     print('Starting safe disposal process...');
//     _isDisposing = true;

//     _cancelAllTimers();
//     _syncSubscription?.cancel();
//     _positionTrackingSubscription?.cancel();
//     _disposeControllersInBackground();
//   }

//   void _cancelAllTimers() {
//     try {
//       _initializationTimer?.cancel();
//       _initializationTimer = null;

//       _autoPlayTimer?.cancel();
//       _autoPlayTimer = null;

//       _syncSubscription?.cancel();
//       _syncSubscription = null;

//       _positionTrackingSubscription?.cancel();
//       _positionTrackingSubscription = null;

//       _controlsTimer?.cancel();
//       _controlsTimer = null;

//       _seekTimer?.cancel();
//       _seekTimer = null;

//       _seekDebounceTimer?.cancel();
//       _seekDebounceTimer = null;

//       _progressiveSeekTimer?.cancel(); // Cancel progressive seek timer
//       _progressiveSeekTimer = null;

//       print('All timers and subscriptions cancelled');
//     } catch (e) {
//       print('Error cancelling timers: $e');
//     }
//   }

//   void _disposeControllersInBackground() {
//     Future.microtask(() async {
//       try {
//         print('Background controller disposal started');

//         if (_playerController != null) {
//           try {
//             await _playerController?.stop().timeout(Duration(seconds: 2));
//             print('Video controller stopped');
//           } catch (e) {
//             print('Video controller stop timeout/error: $e');
//           }
//         }

//         if (_audioController != null) {
//           try {
//             await _audioController?.stop().timeout(Duration(seconds: 2));
//             print('Audio controller stopped');
//           } catch (e) {
//             print('Audio controller stop timeout/error: $e');
//           }
//         }

//         await Future.delayed(Duration(milliseconds: 500));

//         if (_playerController != null) {
//           try {
//             await _playerController?.dispose().timeout(Duration(seconds: 3));
//             print('Video controller disposed');
//           } catch (e) {
//             print('Video controller dispose timeout/error: $e');
//           }
//           _playerController = null;
//         }

//         if (_audioController != null) {
//           try {
//             await _audioController?.dispose().timeout(Duration(seconds: 3));
//             print('Audio controller disposed');
//           } catch (e) {
//             print('Audio controller dispose timeout/error: $e');
//           }
//           _audioController = null;
//         }

//         try {
//           _youtubeExplode.close();
//           print('YoutubeExplode closed');
//         } catch (e) {
//           print('Error closing YoutubeExplode: $e');
//         }

//         _isDisposed = true;
//         print('Background disposal completed');
//       } catch (e) {
//         print('Background disposal error: $e');
//         _playerController = null;
//         _audioController = null;
//         _isDisposed = true;
//       }
//     });
//   }

//   void _setupPositionTracking() {
//     if (_playerController == null || _isDisposed || _isDisposing || !mounted)
//       return;

//     _positionTrackingSubscription?.cancel();
//     print('🎬 Setting up position tracking...');

//     Timer(Duration(seconds: 1), () {
//       if (mounted &&
//           _isInitialized &&
//           _playerController != null &&
//           !_isDisposed &&
//           !_isDisposing) {
//         print('📍 Starting position tracking...');

//         _positionTrackingSubscription =
//             Stream.periodic(Duration(milliseconds: 1000)).listen((_) async {
//           if (mounted &&
//               _isInitialized &&
//               _playerController != null &&
//               !_isDisposed &&
//               !_isDisposing &&
//               !_isSeeking) {
//             // Don't update position while seeking

//             await _updatePosition();
//           }
//         });
//       }
//     });
//   }

//   // Future<void> _updatePosition() async {
//   //   try {
//   //     final videoInitialized = _playerController?.value.isInitialized ?? false;
//   //     if (!videoInitialized) return;

//   //     final currentPos =
//   //         await _playerController?.getPosition() ?? Duration.zero;
//   //     final totalDur = await _playerController?.getDuration() ?? Duration.zero;

//   //     // Check if we're 6 seconds before end and not already triggered
//   //     if (!_earlyPauseTriggered &&
//   //         totalDur.inSeconds > 6 &&
//   //         currentPos.inSeconds >= totalDur.inSeconds - 3) {
//   //       _earlyPauseTriggered = true;
//   //       _pauseBoth();
//   //       print('⏸️ Auto-paused 6 seconds before end');
//   //     }

//   //     if (mounted && !_isDisposed && !_isDisposing) {
//   //       setState(() {
//   //         _currentPosition = currentPos;
//   //         _totalDuration = totalDur;
//   //       });
//   //     }
//   //   } catch (e) {
//   //     print('Position update error: $e');
//   //   }
//   // }

//   String _getCurrentUserAgent() {
//     return _tvUserAgents[_currentUserAgentIndex % _tvUserAgents.length];
//   }

//   void _rotateUserAgent() {
//     _currentUserAgentIndex =
//         (_currentUserAgentIndex + 1) % _tvUserAgents.length;
//     _failedAttempts++;

//     print(
//         'Rotating to user agent ${_currentUserAgentIndex + 1}/${_tvUserAgents.length}: ${_getCurrentUserAgent().substring(0, 60)}...');
//     print('Failed attempts so far: $_failedAttempts');

//     if (_failedAttempts > _maxFailedAttempts) {
//       print('Too many failed attempts, adding extra delay...');
//     }
//   }

//   Future<void> _addRequestDelay() async {
//     if (_isDisposed || _isDisposing) return;

//     final now = DateTime.now();
//     if (_lastRequestTime != null) {
//       final timeSinceLastRequest = now.difference(_lastRequestTime!);
//       if (timeSinceLastRequest < _requestDelay) {
//         final delayNeeded = _requestDelay - timeSinceLastRequest;
//         print(
//             'Rate limiting: waiting ${delayNeeded.inMilliseconds}ms before next request');
//         await Future.delayed(delayNeeded);
//       }
//     }
//     _lastRequestTime = now;

//     if (_failedAttempts > _maxFailedAttempts) {
//       final extraDelay = Duration(seconds: _failedAttempts * 2);
//       print('Extra delay due to failures: ${extraDelay.inSeconds}s');
//       await Future.delayed(extraDelay);
//     }
//   }

//   // FIXED: Stream loading with strict 1080p limit
//   Future<void> _loadStreamUrls() async {
//     if (_isInitializing || _isDisposed || _isDisposing) return;

//     if (!mounted) return;

//     setState(() {
//       _earlyPauseTriggered = false;
//       _isInitializing = true;
//       _errorMessage = null;
//     });

//     try {
//       if (widget.videoUrl.isEmpty) {
//         throw Exception('Video URL is empty');
//       }

//       print('🎬 Loading streams for: ${widget.videoUrl}');
//       print('🚫 BLOCKING: 2K (1440p), 4K (2160p), 8K (4320p) quality');
//       print('✅ ALLOWING: Maximum ${MAX_VIDEO_HEIGHT}p quality');
//       print(
//           '🌐 Using user agent: ${_getCurrentUserAgent().substring(0, 60)}...');

//       await _addRequestDelay();

//       if (_isDisposed || _isDisposing || !mounted) return;

//       StreamManifest? manifest;
//       int retryCount = 0;
//       const maxRetries = 3;

//       while (retryCount < maxRetries &&
//           manifest == null &&
//           !_isDisposed &&
//           !_isDisposing &&
//           mounted) {
//         try {
//           print('🔄 Attempt ${retryCount + 1}/$maxRetries to get manifest...');
//           manifest = await _youtubeExplode.videos.streamsClient
//               .getManifest(widget.videoUrl);

//           _failedAttempts = 0;
//           print('✅ Manifest loaded successfully on attempt ${retryCount + 1}');
//           break;
//         } catch (manifestError) {
//           retryCount++;
//           print('❌ Manifest error on attempt $retryCount: $manifestError');

//           if (retryCount < maxRetries &&
//               !_isDisposed &&
//               !_isDisposing &&
//               mounted) {
//             _rotateUserAgent();
//             print('🔄 Retrying with different user agent...');
//             await Future.delayed(Duration(seconds: retryCount * 2));
//             if (_isDisposed || _isDisposing || !mounted) return;
//           } else {
//             throw Exception(
//                 'Failed to get video manifest after $maxRetries attempts: $manifestError');
//           }
//         }
//       }

//       if (_isDisposed || _isDisposing || !mounted) return;

//       if (manifest == null) {
//         throw Exception('Could not get video manifest after all retries');
//       }

//       // First try muxed streams with 1080p limit
//       var muxedStreams = manifest.muxed;
//       print('📺 Found ${muxedStreams?.length ?? 0} muxed streams');

//       if (muxedStreams != null && muxedStreams.isNotEmpty) {
//         // Debug: Print all available muxed streams with blocked indicator
//         print('🔍 Available muxed streams:');
//         for (var stream in muxedStreams) {
//           String blockedIndicator =
//               stream.videoResolution.height > MAX_VIDEO_HEIGHT
//                   ? ' 🚫 BLOCKED'
//                   : ' ✅ ALLOWED';
//           print(
//               '   - ${stream.tag}: ${stream.videoResolution.height}p${blockedIndicator}');
//         }

//         // STRICT Filter: Block 2K/4K/8K - Only allow up to 1080p
//         var filteredMuxedStreams = muxedStreams.where((stream) {
//           bool isAllowed = stream.videoResolution.height <= MAX_VIDEO_HEIGHT;
//           if (!isAllowed) {
//             print(
//                 '🚫 BLOCKING ${stream.tag}: ${stream.videoResolution.height}p (>${MAX_VIDEO_HEIGHT}p)');
//           }
//           return isAllowed;
//         }).toList();

//         print(
//             '📏 Filtered muxed streams (≤${MAX_VIDEO_HEIGHT}p): ${filteredMuxedStreams.length}');
//         print(
//             '🚫 Blocked high quality streams: ${muxedStreams.length - filteredMuxedStreams.length}');

//         if (filteredMuxedStreams.isNotEmpty) {
//           print('✅ Using filtered muxed stream approach');
//           await _handleFilteredMuxedStreams(filteredMuxedStreams);
//           return;
//         } else {
//           print(
//               '⚠️ No muxed streams found ≤${MAX_VIDEO_HEIGHT}p (All were 2K/4K/8K), trying separate streams...');
//         }
//       }

//       // Use separate video and audio streams with 1080p limit
//       print('🎥 Using separate video and audio streams approach...');

//       var videoOnlyStreams = manifest.videoOnly;
//       print('🎬 Found ${videoOnlyStreams?.length ?? 0} video-only streams');

//       VideoOnlyStreamInfo? bestVideoStream;
//       if (videoOnlyStreams != null && videoOnlyStreams.isNotEmpty) {
//         // Debug: Print all available video streams with blocked indicator
//         print('🔍 Available video-only streams:');
//         for (var stream in videoOnlyStreams) {
//           String blockedIndicator =
//               stream.videoResolution.height > MAX_VIDEO_HEIGHT
//                   ? ' 🚫 BLOCKED'
//                   : ' ✅ ALLOWED';
//           print(
//               '   - ${stream.tag}: ${stream.videoResolution.height}p${blockedIndicator}');
//         }

//         // STRICT Filter: Block 2K/4K/8K - Only allow up to 1080p
//         var filteredVideoStreams = videoOnlyStreams.where((stream) {
//           bool isAllowed = stream.videoResolution.height <= MAX_VIDEO_HEIGHT;
//           if (!isAllowed) {
//             print(
//                 '🚫 BLOCKING ${stream.tag}: ${stream.videoResolution.height}p (>${MAX_VIDEO_HEIGHT}p)');
//           }
//           return isAllowed;
//         }).toList();

//         print(
//             '📏 Filtered video streams (≤${MAX_VIDEO_HEIGHT}p): ${filteredVideoStreams.length}');
//         print(
//             '🚫 Blocked high quality streams: ${videoOnlyStreams.length - filteredVideoStreams.length}');

//         if (filteredVideoStreams.isNotEmpty) {
//           // Sort by quality (highest first within the limit)
//           filteredVideoStreams.sort((a, b) =>
//               b.videoResolution.height.compareTo(a.videoResolution.height));

//           bestVideoStream = filteredVideoStreams.first;
//           print(
//               '✅ Selected video stream: ${bestVideoStream.tag} - ${bestVideoStream.videoResolution.height}p');
//         } else {
//           // If no streams within limit, use the lowest available
//           var sortedVideoStreams = videoOnlyStreams.toList()
//             ..sort((a, b) =>
//                 a.videoResolution.height.compareTo(b.videoResolution.height));
//           bestVideoStream = sortedVideoStreams.first;
//           print(
//               '⚠️ No video streams ≤${MAX_VIDEO_HEIGHT}p found (All were 2K/4K/8K), using lowest available: ${bestVideoStream.videoResolution.height}p');
//         }
//       }

//       var audioOnlyStreams = manifest.audioOnly;
//       print('🎵 Found ${audioOnlyStreams?.length ?? 0} audio-only streams');

//       AudioOnlyStreamInfo? bestAudioStream;
//       if (audioOnlyStreams != null && audioOnlyStreams.isNotEmpty) {
//         var sortedAudioStreams = audioOnlyStreams.toList()
//           ..sort((a, b) =>
//               b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond));
//         bestAudioStream = sortedAudioStreams.first;
//         print(
//             '✅ Selected audio stream: ${bestAudioStream.tag} - ${bestAudioStream.audioCodec} - ${bestAudioStream.bitrate}');
//       }

//       if (bestVideoStream != null && bestAudioStream != null) {
//         String videoUrl = bestVideoStream.url.toString();
//         String audioUrl = bestAudioStream.url.toString();

//         print(
//             '🔗 Video URL loaded (${bestVideoStream.videoResolution.height}p)');
//         print('🔗 Audio URL loaded');

//         _videoStreamUrl = videoUrl;
//         _audioStreamUrl = audioUrl;

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() {
//             _controllerCreated = true;
//             _isInitializing = false;
//           });

//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (!_isDisposed && !_isDisposing && mounted) {
//               _initializationTimer = Timer(Duration(milliseconds: 3000), () {
//                 if (mounted && !_isDisposed && !_isDisposing) {
//                   _waitForAutoInitialization();
//                 }
//               });
//             }
//           });
//         }
//       } else {
//         String missingStreams = '';
//         if (bestVideoStream == null) missingStreams += 'video ';
//         if (bestAudioStream == null) missingStreams += 'audio ';

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() {
//             _errorMessage =
//                 'No $missingStreams streams found for this video. This video might be restricted or unavailable.';
//             _isInitializing = false;
//           });
//         }
//       }
//     } catch (e) {
//       print('❌ Error loading streams: $e');

//       if (_isDisposed || _isDisposing || !mounted) return;

//       String errorMessage = 'Error loading video: ${e.toString()}';

//       if (e.toString().contains('VideoUnavailableException')) {
//         errorMessage = 'This video is unavailable or private';
//       } else if (e.toString().contains('VideoRequiresPurchaseException')) {
//         errorMessage = 'This video requires purchase';
//       } else if (e.toString().contains('SocketException')) {
//         errorMessage = 'Network error: Please check your internet connection';
//       } else if (e.toString().contains('TimeoutException')) {
//         errorMessage = 'Request timed out: Please try again';
//       } else if (e.toString().contains('403') ||
//           e.toString().contains('Forbidden')) {
//         errorMessage = 'Access blocked: Trying different user agent...';
//         if (_failedAttempts < _tvUserAgents.length) {
//           Timer(Duration(seconds: 3), () {
//             if (mounted && !_isDisposed && !_isDisposing) {
//               _retryWithDifferentUserAgent();
//             }
//           });
//         }
//       } else if (e.toString().contains('429') ||
//           e.toString().contains('rate')) {
//         errorMessage = 'Rate limited: Please wait before trying again...';
//       }

//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage = errorMessage;
//           _isInitializing = false;
//         });
//       }
//     }
//   }

//   // Handle filtered muxed streams
//   Future<void> _handleFilteredMuxedStreams(
//       List<MuxedStreamInfo> filteredStreams) async {
//     if (_isDisposed || _isDisposing || !mounted) return;

//     // Sort by quality (highest first within the limit)
//     var sortedStreams = filteredStreams.toList()
//       ..sort((a, b) {
//         int qualityCompare =
//             b.videoResolution.height.compareTo(a.videoResolution.height);
//         if (qualityCompare != 0) return qualityCompare;
//         return b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond);
//       });

//     MuxedStreamInfo bestStream = sortedStreams.first;
//     String streamUrl = bestStream.url.toString();

//     print(
//         '✅ Selected muxed stream: ${bestStream.tag} - ${bestStream.videoResolution.height}p - Bitrate: ${bestStream.bitrate}');
//     print(
//         '🚫 CONFIRMED: No 2K/4K/8K quality - Maximum ${MAX_VIDEO_HEIGHT}p enforced');

//     _videoStreamUrl = streamUrl;
//     _audioStreamUrl = null;

//     if (mounted && !_isDisposed && !_isDisposing) {
//       setState(() {
//         _controllerCreated = true;
//         _isInitializing = false;
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!_isDisposed && !_isDisposing && mounted) {
//           _initializationTimer = Timer(Duration(milliseconds: 3000), () {
//             if (mounted && !_isDisposed && !_isDisposing) {
//               _waitForAutoInitialization();
//             }
//           });
//         }
//       });
//     }
//   }

//   void _createControllers() {
//     if (_videoStreamUrl == null || !mounted || _isDisposed || _isDisposing)
//       return;

//     try {
//       print('Creating controllers with TV user agent...');
//       print(
//           'Current user agent: ${_getCurrentUserAgent().substring(0, 60)}...');

//       _playerController = VlcPlayerController.network(
//         _videoStreamUrl!,
//         hwAcc: HwAcc.auto,
//         autoPlay: false,
//         autoInitialize: true,
//         options: VlcPlayerOptions(
//           advanced: VlcAdvancedOptions([
//             VlcAdvancedOptions.networkCaching(5000),
//             VlcAdvancedOptions.liveCaching(5000),
//           ]),
//           audio: VlcAudioOptions([
//             '--aout=any',
//           ]),
//           video: VlcVideoOptions([
//             '--avcodec-hw=any',
//           ]),
//           http: VlcHttpOptions([
//             '--http-user-agent=${_getCurrentUserAgent()}',
//             '--http-referrer=https://www.youtube.com/',
//           ]),
//           subtitle: VlcSubtitleOptions([]),
//           rtp: VlcRtpOptions([]),
//         ),
//       );

//       print('Video controller created successfully');

//       if (_audioStreamUrl != null && !_isDisposed && !_isDisposing) {
//         print('Creating separate audio controller for high quality audio...');
//         _audioController = VlcPlayerController.network(
//           _audioStreamUrl!,
//           hwAcc: HwAcc.auto,
//           autoPlay: false,
//           autoInitialize: true,
//           options: VlcPlayerOptions(
//             advanced: VlcAdvancedOptions([
//               VlcAdvancedOptions.networkCaching(5000),
//               VlcAdvancedOptions.liveCaching(5000),
//             ]),
//             audio: VlcAudioOptions([
//               '--aout=any',
//             ]),
//             video: VlcVideoOptions([
//               '--no-video',
//             ]),
//             http: VlcHttpOptions([
//               '--http-user-agent=${_getCurrentUserAgent()}',
//               '--http-referrer=https://www.youtube.com/',
//             ]),
//             subtitle: VlcSubtitleOptions([]),
//             rtp: VlcRtpOptions([]),
//           ),
//         );
//         print('Audio controller created successfully');
//         _useDualStream = true;
//       }
//     } catch (e) {
//       print('Error creating controllers: $e');
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage = 'Failed to create video players: $e';
//         });
//       }
//     }
//   }

//   Future<void> _waitForAutoInitialization() async {
//     if (!mounted || _playerController == null || _isDisposed || _isDisposing) {
//       print(
//           'Cannot wait for initialization: widget not mounted or controller null');
//       return;
//     }

//     try {
//       print('Waiting for auto-initialization of controllers...');

//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _isInitializing = true;
//           _errorMessage = null;
//         });
//       }

//       int attempts = 0;
//       const maxAttempts = 30;

//       while (attempts < maxAttempts &&
//           mounted &&
//           _playerController != null &&
//           !_isDisposed &&
//           !_isDisposing) {
//         final videoInitialized =
//             _playerController?.value.isInitialized ?? false;
//         final audioInitialized = _audioController?.value.isInitialized ?? true;

//         print(
//             'Auto-initialization check $attempts: video=$videoInitialized, audio=$audioInitialized');

//         if (videoInitialized && audioInitialized) {
//           print('Controllers auto-initialized successfully');
//           break;
//         }

//         await Future.delayed(Duration(seconds: 1));
//         attempts++;

//         if (!mounted || _isDisposed || _isDisposing) {
//           print('Widget disposed during initialization, stopping...');
//           return;
//         }
//       }

//       if (mounted &&
//           _playerController != null &&
//           !_isDisposed &&
//           !_isDisposing) {
//         final videoInitialized =
//             _playerController?.value.isInitialized ?? false;
//         final audioInitialized = _audioController?.value.isInitialized ?? true;

//         if (videoInitialized && audioInitialized) {
//           if (mounted && !_isDisposed && !_isDisposing) {
//             setState(() {
//               _isInitialized = true;
//               _isInitializing = false;
//             });
//           }

//           print(
//               'Controllers ready for playback (dual stream: $_useDualStream)');
//           _setupSyncListeners();
//           _setupPositionTracking();

//           _autoPlayTimer = Timer(Duration(milliseconds: 1500), () {
//             if (mounted && _isInitialized && !_isDisposed && !_isDisposing) {
//               print('Starting auto-play...');
//               _playBoth();
//             }
//           });
//         } else {
//           throw Exception('Controllers failed to auto-initialize');
//         }
//       }
//     } catch (e) {
//       print('Auto-initialization wait error: $e');
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage = 'Failed to initialize video players: $e';
//           _isInitializing = false;
//           _isInitialized = false;
//         });
//       }
//     }
//   }

//   // // Enhanced sync listeners with audio recovery
//   // void _setupSyncListeners() {
//   //   if (!_isInitialized ||
//   //       _playerController == null ||
//   //       !mounted ||
//   //       _isDisposed ||
//   //       _isDisposing) {
//   //     return;
//   //   }

//   //   _syncSubscription?.cancel();

//   //   Timer(Duration(seconds: 3), () {
//   //     if (mounted &&
//   //         _isInitialized &&
//   //         _playerController != null &&
//   //         !_isDisposed &&
//   //         !_isDisposing) {
//   //       _syncSubscription =
//   //           Stream.periodic(Duration(seconds: 1)).listen((_) async {
//   //         if (mounted &&
//   //             _isInitialized &&
//   //             _playerController != null &&
//   //             !_isDisposed &&
//   //             !_isDisposing &&
//   //             !_isSeeking) {
//   //           try {
//   //             final videoInitialized =
//   //                 _playerController?.value.isInitialized ?? false;
//   //             final videoPlaying = _playerController?.value.isPlaying ?? false;

//   //             if (videoInitialized) {
//   //               final videoPosition =
//   //                   await _playerController?.getPosition() ?? Duration.zero;

//   //               if (_useDualStream &&
//   //                   _audioController != null &&
//   //                   !_isDisposed &&
//   //                   !_isDisposing) {
//   //                 final audioInitialized =
//   //                     _audioController?.value.isInitialized ?? false;
//   //                 final audioPlaying =
//   //                     _audioController?.value.isPlaying ?? false;

//   //                 if (audioInitialized) {
//   //                   // Check if audio is out of sync with video
//   //                   final audioPosition =
//   //                       await _audioController?.getPosition() ?? Duration.zero;
//   //                   final diff = (videoPosition.inMilliseconds -
//   //                           audioPosition.inMilliseconds)
//   //                       .abs();

//   //                   if (diff > 1000 && !_isSeeking) {
//   //                     print(
//   //                         '🔄 Major audio sync correction: ${diff}ms difference');
//   //                     await _audioController?.seekTo(videoPosition);
//   //                   }

//   //                   // Critical: Check if video is playing but audio is not
//   //                   if (videoPlaying &&
//   //                       !audioPlaying &&
//   //                       _isPlaying &&
//   //                       !_isSeeking) {
//   //                     print(
//   //                         '🚨 Audio stopped but video playing - restarting audio...');
//   //                     await _audioController?.play();
//   //                   }

//   //                   // Also check reverse case
//   //                   if (!videoPlaying && audioPlaying && !_isPlaying) {
//   //                     print(
//   //                         '🚨 Video stopped but audio playing - stopping audio...');
//   //                     await _audioController?.pause();
//   //                   }
//   //                 }
//   //               }

//   //               // Update current position
//   //               if (mounted && !_isDisposed && !_isDisposing) {
//   //                 setState(() {
//   //                   _currentPosition = videoPosition;
//   //                 });
//   //               }
//   //             }
//   //           } catch (e) {
//   //             // Silent sync errors but log critical ones
//   //             if (e.toString().contains('audio')) {
//   //               print('⚠️ Audio sync error: $e');
//   //             }
//   //           }
//   //         }
//   //       });
//   //     }
//   //   });
//   // }

//   // // Enhanced play method with audio verification
//   // Future<void> _playBoth() async {
//   //   if (!_isInitialized ||
//   //       _playerController == null ||
//   //       _isDisposed ||
//   //       _isDisposing) {
//   //     print('Cannot play: not initialized or controllers are null');
//   //     return;
//   //   }

//   //   _earlyPauseTriggered = false;

//   //   try {
//   //     final videoInitialized = _playerController?.value.isInitialized ?? false;

//   //     if (videoInitialized && !_isDisposed && !_isDisposing) {
//   //       print('▶️ Playing video controller...');
//   //       await _playerController?.play();

//   //       if (_useDualStream &&
//   //           _audioController != null &&
//   //           !_isDisposed &&
//   //           !_isDisposing) {
//   //         final audioInitialized =
//   //             _audioController?.value.isInitialized ?? false;
//   //         if (audioInitialized) {
//   //           print('🎵 Playing audio controller...');
//   //           await _audioController?.play();

//   //           // Verify audio started playing after small delay
//   //           Timer(Duration(milliseconds: 300), () async {
//   //             if (_audioController != null && !_isDisposed && _isPlaying) {
//   //               final audioPlaying = _audioController?.value.isPlaying ?? false;
//   //               if (!audioPlaying) {
//   //                 print('🔄 Audio failed to start, retrying...');
//   //                 try {
//   //                   await _audioController?.play();
//   //                 } catch (e) {
//   //                   print('❌ Audio retry failed: $e');
//   //                 }
//   //               }
//   //             }
//   //           });
//   //         }
//   //       }

//   //       if (mounted && !_isDisposed && !_isDisposing) {
//   //         setState(() => _isPlaying = true);
//   //       }
//   //       print('✅ Controllers playing (dual stream: $_useDualStream)');
//   //     } else {
//   //       print('❌ Controllers not ready');
//   //     }
//   //   } catch (e) {
//   //     print('❌ Error playing: $e');
//   //   }
//   // }

//   Future<void> _pauseBoth() async {
//     if (!_isInitialized ||
//         _playerController == null ||
//         _isDisposed ||
//         _isDisposing) {
//       print('Cannot pause: not initialized or controllers are null');
//       return;
//     }

//     try {
//       final videoInitialized = _playerController?.value.isInitialized ?? false;

//       if (videoInitialized && !_isDisposed && !_isDisposing) {
//         print('Pausing video controller...');
//         await _playerController?.pause();

//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing) {
//           final audioInitialized =
//               _audioController?.value.isInitialized ?? false;
//           if (audioInitialized) {
//             print('Pausing audio controller...');
//             await _audioController?.pause();
//           }
//         }

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() => _isPlaying = false);
//         }
//         print('Controllers paused (dual stream: $_useDualStream)');
//       }
//     } catch (e) {
//       print('Error pausing: $e');
//     }
//   }

//   // Legacy seek method (replaced by _seekBothWithDebounce)
//   Future<void> _seekBoth(Duration position) async {
//     return _seekBothWithDebounce(position);
//   }

//   Future<void> _stopBoth() async {
//     if (!_isInitialized ||
//         _playerController == null ||
//         _isDisposed ||
//         _isDisposing) {
//       print('Cannot stop: not initialized or controllers are null');
//       return;
//     }

//     try {
//       final videoInitialized = _playerController?.value.isInitialized ?? false;

//       if (videoInitialized && !_isDisposed && !_isDisposing) {
//         print('Stopping video controller...');
//         await _playerController?.stop();

//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing) {
//           final audioInitialized =
//               _audioController?.value.isInitialized ?? false;
//           if (audioInitialized) {
//             print('Stopping audio controller...');
//             await _audioController?.stop();
//           }
//         }

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() => _isPlaying = false);
//         }
//         print('Controllers stopped (dual stream: $_useDualStream)');
//       }
//     } catch (e) {
//       print('Error stopping: $e');
//     }
//   }

//   Future<void> _retryWithDifferentUserAgent() async {
//     if (_failedAttempts >= _tvUserAgents.length ||
//         _isDisposed ||
//         _isDisposing) {
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage =
//               'All user agents failed. Video may be restricted or temporarily unavailable.';
//         });
//       }
//       return;
//     }

//     _rotateUserAgent();

//     if (mounted && !_isDisposed && !_isDisposing) {
//       setState(() {
//         _errorMessage = null;
//         _isInitialized = false;
//         _isInitializing = false;
//         _controllerCreated = false;
//         _useDualStream = false;
//         _videoStreamUrl = null;
//         _audioStreamUrl = null;
//       });
//     }

//     await _disposeControllersSync();
//     await Future.delayed(Duration(seconds: 2));

//     if (mounted && !_isDisposed && !_isDisposing) {
//       _loadStreamUrls();
//     }
//   }

//   Future<void> _disposeControllersSync() async {
//     print('Disposing controllers synchronously...');

//     _cancelAllTimers();

//     try {
//       if (_playerController != null) {
//         print('Disposing video controller...');
//         await _playerController?.stop().timeout(Duration(seconds: 2));
//         await _playerController?.dispose().timeout(Duration(seconds: 3));
//         _playerController = null;
//         print('Video controller disposed');
//       }
//       if (_audioController != null) {
//         print('Disposing audio controller...');
//         await _audioController?.stop().timeout(Duration(seconds: 2));
//         await _audioController?.dispose().timeout(Duration(seconds: 3));
//         _audioController = null;
//         print('Audio controller disposed');
//       }
//     } catch (e) {
//       print('Error disposing controllers: $e');
//       _playerController = null;
//       _audioController = null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: RawKeyboardListener(
//         focusNode: _focusNode,
//         onKey: _handleKeyEvent,
//         child: GestureDetector(
//           onTap: () {
//             _showControlsTemporarily();
//           },
//           child: _buildPlayerContent(),
//         ),
//       ),
//     );
//   }

//   Widget _buildPlayerContent() {
//     // Different width options - Choose one:
    
//     // Option 1: 90% of screen width (10% kam)
//     // double videoWidthMultiplier = 0.90;
    
//     // Option 2: 95% of screen width (5% kam) - Recommended
//     double videoWidthMultiplier = 0.98;
    
//     // Option 3: 85% of screen width (15% kam) - More padding
//     // double videoWidthMultiplier = 0.85;
    
//     // Option 4: Fixed padding from sides (20 pixels each side)
//     // double effectiveVideoWidth = screenwdt - 40;
    
//     // Calculate video dimensions
//     double effectiveVideoWidth = screenwdt * videoWidthMultiplier;
//     double effectiveVideoHeight = effectiveVideoWidth * 9 / 16;

//     if (_isDisposed || _isDisposing) {
//       return Container(
//         height: screenhgt,
//         color: Colors.black,
//         child: Center(
//           child: Text(
//             'Player disposed',
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       );
//     }

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
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: _isDisposing
//                       ? null
//                       : () {
//                           if (_isDisposed || _isDisposing) return;
//                           setState(() {
//                             _errorMessage = null;
//                             _isInitialized = false;
//                             _isInitializing = false;
//                             _controllerCreated = false;
//                             _useDualStream = false;
//                             _videoStreamUrl = null;
//                             _audioStreamUrl = null;
//                             _failedAttempts = 0;
//                           });
//                           _disposeControllersSync().then((_) {
//                             if (!_isDisposed && !_isDisposing && mounted) {
//                               _loadStreamUrls();
//                             }
//                           });
//                         },
//                   child: Text('Retry'),
//                 ),
//                 SizedBox(width: 16),
//                 ElevatedButton(
//                   onPressed: (_isDisposed || _isDisposing)
//                       ? null
//                       : _retryWithDifferentUserAgent,
//                   child: Text('Try Different Agent'),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Agent ${_currentUserAgentIndex + 1}/${_tvUserAgents.length}: ${_getCurrentUserAgent().substring(0, 30)}...',
//               style: TextStyle(fontSize: 10, color: Colors.grey),
//             ),
//             if (_failedAttempts > 0)
//               Text(
//                 'Failed attempts: $_failedAttempts',
//                 style: TextStyle(fontSize: 10, color: Colors.orange),
//               ),
//           ],
//         ),
//       );
//     }

//     if (!_controllerCreated || (_isInitializing && !_isInitialized) ) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text(!_controllerCreated
//                 ? 'Loading  video streams...'
//                 : 'Initializing video players...'),
//             SizedBox(height: 8),
//             Text(
//               'Agent ${_currentUserAgentIndex + 1}/${_tvUserAgents.length}: ${_getCurrentUserAgent().substring(0, 40)}...',
//               style: TextStyle(fontSize: 10, color: Colors.grey),
//               textAlign: TextAlign.center,
//             ),
//             if (_failedAttempts > 0)
//               Padding(
//                 padding: const EdgeInsets.only(top: 4.0),
//                 child: Text(
//                   'Attempts: $_failedAttempts',
//                   style: TextStyle(fontSize: 10, color: Colors.orange),
//                 ),
//               ),
//           ],
//         ),
//       );
//     }

//     if (_controllerCreated &&
//         _playerController == null &&
//         !_isDisposed &&
//         !_isDisposing) {
//       _createControllers();
//     }

//     return Stack(
//       children: [
//         // Video player (main layer) - Now with custom width
//         Center(
//           child: Container(
//             height: effectiveVideoHeight,
//             width: effectiveVideoWidth,
//             decoration: BoxDecoration(
//               color: Colors.black,
//               borderRadius: BorderRadius.circular(12), // Rounded corners
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 10,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: _playerController != null && !_isDisposed && !_isDisposing
//                   ? VlcPlayer(
//                       controller: _playerController!,
//                       aspectRatio: 16 / 9,
//                       placeholder: const Center(
//                         child: Text(
//                           'Loading Video...',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     )
//                   : Container(
//                       color: Colors.black,
//                       child: const Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                     ),
//             ),
//           ),
//         ),

//         // Audio player (hidden)
//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing)
//           Positioned(
//             top: -1000,
//             child: Container(
//               height: 1,
//               width: 1,
//               child: VlcPlayer(
//                 controller: _audioController!,
//                 aspectRatio: 1,
//               ),
//             ),
//           ),

//         // Controls overlay
//         if (_showControls && _isInitialized) _buildControlsOverlay(),

//         // Video title at top
//         if (_isInitialized)
//           Positioned(
//             top: 20,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.black54,
//                     Colors.transparent,
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 widget.name ?? '',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   shadows: [
//                     Shadow(
//                       offset: Offset(1, 1),
//                       blurRadius: 2,
//                       color: Colors.black87,
//                     ),
//                   ],
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),

//         // Always show progress bar at bottom - Enhanced with Progressive Seek
//         if (_isInitialized && _totalDuration.inSeconds > 0)
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: _buildProgressBarWithProgressive(),
//           ),
//       ],
//     );
//   }

//   Widget _buildControlsOverlay() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: RadialGradient(
//           center: Alignment.center,
//           radius: 1.0,
//           colors: [
//             Colors.black.withOpacity(0.3),
//             Colors.black.withOpacity(0.7),
//           ],
//         ),
//       ),
//       child: Center(
//         child: Container(
//           padding: EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.8),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: Colors.white24, width: 2),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black54,
//                 blurRadius: 20,
//                 spreadRadius: 5,
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Play/Pause button - centered and prominent
//               Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.red.withOpacity(0.2),
//                   border: Border.all(color: Colors.red, width: 2),
//                 ),
//                 child: IconButton(
//                   onPressed: _togglePlayPause,
//                   icon: Icon(
//                     _isPlaying ? Icons.pause : Icons.play_arrow,
//                     color: Colors.white,
//                     size: 48,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Enhanced Progress Bar with Progressive Seek Preview
//   Widget _buildProgressBarWithProgressive() {
//     final progress = _totalDuration.inMilliseconds > 0
//         ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
//         : 0.0;

//     // Calculate preview progress if progressively seeking
//     final previewProgress = _isProgressiveSeeking && _totalDuration.inMilliseconds > 0
//         ? _targetSeekPosition.inMilliseconds / _totalDuration.inMilliseconds
//         : null;

//     return Container(
//       height: 70,
//       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.transparent,
//             Colors.black.withOpacity(0.8),
//           ],
//         ),
//       ),
//       child: Column(
//         children: [
//           // Time indicators with progressive seeking status
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.black54,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   _isProgressiveSeeking
//                       ? _formatDuration(_targetSeekPosition)
//                       : _formatDuration(_currentPosition),
//                   style: TextStyle(
//                     color: _isProgressiveSeeking ? Colors.yellow : Colors.white,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     fontFeatures: [FontFeature.tabularFigures()],
//                   ),
//                 ),
//               ),
              
//               // Show seeking indicator
//               if (_isProgressiveSeeking || _isSeeking)
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: _isSeeking 
//                         ? Colors.orange.withOpacity(0.9)
//                         : Colors.yellow.withOpacity(0.9),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         _isSeeking ? Icons.sync : Icons.fast_forward,
//                         color: Colors.white,
//                         size: 16,
//                       ),
//                       SizedBox(width: 4),
//                       Text(
//                         _isSeeking ? 'Processing...' : 'Seeking...',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
                
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.black54,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   _formatDuration(_totalDuration),
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     fontFeatures: [FontFeature.tabularFigures()],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 8),
          
//           // Enhanced progress bar with preview
//           GestureDetector(
//             onTapDown: (details) {
//               if (_isSeeking || _isProgressiveSeeking) return;

//               final RenderBox box = context.findRenderObject() as RenderBox;
//               final localPosition = box.globalToLocal(details.globalPosition);
//               final width = box.size.width - 40;
//               final tapPosition = localPosition.dx - 20;

//               if (tapPosition >= 0 && tapPosition <= width) {
//                 final seekPercentage = tapPosition / width;
//                 final seekPosition = Duration(
//                   milliseconds: (_totalDuration.inMilliseconds * seekPercentage).round(),
//                 );
//                 _seekBothWithDebounce(seekPosition);
//                 _showControlsTemporarily();
//               }
//             },
//             child: Container(
//               height: 6,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(3),
//                 color: Colors.white.withOpacity(0.3),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 2,
//                     offset: Offset(0, 1),
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(3),
//                 child: Stack(
//                   children: [
//                     // Current progress
//                     LinearProgressIndicator(
//                       value: progress,
//                       backgroundColor: Colors.transparent,
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         _isSeeking ? Colors.orange : Colors.red,
//                       ),
//                     ),
                    
//                     // Preview progress for progressive seeking
//                     if (previewProgress != null)
//                       LinearProgressIndicator(
//                         value: previewProgress,
//                         backgroundColor: Colors.transparent,
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           Colors.yellow.withOpacity(0.8),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
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
//     print('Disposing CustomYoutubePlayer - starting cleanup...');
//     KeepScreenOn.turnOff();
//     WidgetsBinding.instance.removeObserver(this);

//     _focusNode.dispose();

//     _isDisposing = true;
//     _cancelAllTimers();
//     _disposeControllersInBackground();

//     super.dispose();
//     print('Widget disposed successfully');
//   }
// }










// import 'dart:math';

// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:youtube_explode_dart/youtube_explode_dart.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:ui';
// import 'dart:async';
// import 'dart:math' as math;
// import 'dart:convert';
// import 'dart:io';
// import 'package:keep_screen_on/keep_screen_on.dart';
// import 'package:crypto/crypto.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/foundation.dart';

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
//     with TickerProviderStateMixin, WidgetsBindingObserver {
//   VlcPlayerController? _playerController;
//   VlcPlayerController? _audioController;
//   final YoutubeExplode _youtubeExplode = YoutubeExplode();

//   // Maximum allowed video resolution height (No 2K/4K/8K)
//   static const int MAX_VIDEO_HEIGHT = 1080;

//   bool _isPlaying = false;
//   bool _isInitialized = false;
//   bool _isInitializing = false;
//   bool _controllerCreated = false;
//   bool _useDualStream = false;
//   bool _isDisposed = false;
//   bool _isDisposing = false;
//   bool _showControls = false;
//   bool _isSeeking = false;
//   Duration _currentPosition = Duration.zero;
//   Duration _totalDuration = Duration.zero;
//   bool _earlyPauseTriggered = false;
//   String? _errorMessage;
//   String? _videoStreamUrl;
//   String? _audioStreamUrl;

//   // Control UI variables
//   Timer? _controlsTimer;
//   Timer? _seekTimer;
//   bool _isSeekingLeft = false;
//   bool _isSeekingRight = false;
//   final FocusNode _focusNode = FocusNode();

//   // Progressive seeking states
//   Timer? _progressiveSeekTimer;
//   int _pendingSeekSeconds = 0;
//   Duration _targetSeekPosition = Duration.zero;
//   bool _isProgressiveSeeking = false;

//   // Stream subscriptions for proper cleanup
//   StreamSubscription? _syncSubscription;
//   StreamSubscription? _positionTrackingSubscription;
//   Timer? _initializationTimer;
//   Timer? _autoPlayTimer;
//   Timer? _seekDebounceTimer;

//   // === ENHANCED ANTI-BLOCKING SYSTEM ===
  
//   // Dynamic User Agent Pool - Platform-based rotation
//   final Map<String, List<String>> _userAgentsByPlatform = {
//     'smart_tv': [
//       'Mozilla/5.0 (SMART-TV; Linux; Tizen 7.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36',
//       'Mozilla/5.0 (Web0S; Linux/SmartTV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 webOS/6.0',
//       'Mozilla/5.0 (Linux; Android 11; SHIELD Android TV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Safari/537.36',
//       'Mozilla/5.0 (X11; Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chromium/90.0.4430.225 Chrome/90.0.4430.225 Safari/537.36',
//     ],
//     'mobile': [
//       'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
//       'Mozilla/5.0 (iPad; CPU OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
//       'Mozilla/5.0 (Linux; Android 11; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Mobile Safari/537.36',
//       'Mozilla/5.0 (Linux; Android 12; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Mobile Safari/537.36',
//     ],
//     'desktop': [
//       'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Safari/537.36',
//       'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Safari/537.36',
//       'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36',
//       'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:97.0) Gecko/20100101 Firefox/97.0',
//     ],
//   };

//   String _currentPlatform = 'smart_tv';
//   int _currentUserAgentIndex = 0;
//   final Random _random = Random();

//   // Dynamic Request Strategies
//   int _minDelayMs = 1000;
//   int _maxDelayMs = 5000;
  
//   // Geographic/Network Simulation
//   final List<String> _geoLocations = [
//     'US', 'CA', 'GB', 'DE', 'FR', 'AU', 'JP', 'IN', 'BR', 'MX', 'IT', 'ES', 'NL', 'SE'
//   ];
//   String _currentGeoLocation = 'US';
  
//   // Session Fingerprinting
//   String? _sessionId;
//   String? _deviceFingerprint;
//   int _requestCounter = 0;

//   // Enhanced Proxy/Tunnel Support
//   final List<Map<String, String>> _proxyConfigs = [
//     {'type': 'direct', 'priority': '1'},
//     {'type': 'cloudflare', 'priority': '2'},
//     {'type': 'cors-proxy', 'priority': '3'},
//   ];
//   int _currentProxyIndex = 0;

//   // Advanced Retry Mechanism
//   final Map<String, int> _userAgentFailCount = {};
//   final Map<String, DateTime> _userAgentCooldowns = {};
//   final Duration _cooldownDuration = Duration(minutes: 10);
  
//   // Request timing tracking
//   DateTime? _lastRequestTime;
//   final Duration _requestDelay = Duration(seconds: 2);
  
//   int _failedAttempts = 0;
//   final int _maxFailedAttempts = 5; // Increased from 3

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _initializeEnhancedSystem();
//     KeepScreenOn.turnOn();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusNode.requestFocus();
//     });
//   }

//   // === ENHANCED INITIALIZATION ===
  
//   Future<void> _initializeEnhancedSystem() async {
//     try {
//       // Generate unique session ID
//       _sessionId = _generateSessionId();
      
//       // Create device fingerprint
//       _deviceFingerprint = await _generateDeviceFingerprint();
      
//       // Randomize initial platform
//       final platforms = _userAgentsByPlatform.keys.toList();
//       _currentPlatform = platforms[_random.nextInt(platforms.length)];
      
//       // Randomize initial geo location
//       _currentGeoLocation = _geoLocations[_random.nextInt(_geoLocations.length)];
      
//       print('🚀 Enhanced Anti-Blocking System Initialized:');
//       print('   Session ID: $_sessionId');
//       print('   Device Fingerprint: ${_deviceFingerprint?.substring(0, 16)}...');
//       print('   Initial Platform: $_currentPlatform');
//       print('   Initial Geo: $_currentGeoLocation');
      
//       // Start enhanced stream loading
//       _loadStreamUrlsEnhanced();
//     } catch (e) {
//       print('❌ Enhanced system initialization error: $e');
//       // Fallback to basic system
//       _loadStreamUrls();
//     }
//   }

//   String _generateSessionId() {
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final random = _random.nextInt(999999);
//     final bytes = utf8.encode('$timestamp-$random-${widget.videoUrl}');
//     final digest = sha256.convert(bytes);
//     return digest.toString().substring(0, 16);
//   }

//   Future<String> _generateDeviceFingerprint() async {
//     try {
//       final deviceInfo = DeviceInfoPlugin();
//       String fingerprint = '';
      
//       if (kIsWeb) {
//         final webInfo = await deviceInfo.webBrowserInfo;
//         fingerprint = '${webInfo.browserName}-${webInfo.platform}-${webInfo.userAgent?.hashCode}';
//       } else if (Platform.isAndroid) {
//         final androidInfo = await deviceInfo.androidInfo;
//         fingerprint = '${androidInfo.model}-${androidInfo.version.release}-${androidInfo.id}';
//       } else if (Platform.isIOS) {
//         final iosInfo = await deviceInfo.iosInfo;
//         fingerprint = '${iosInfo.model}-${iosInfo.systemVersion}-${iosInfo.identifierForVendor}';
//       }
      
//       final bytes = utf8.encode(fingerprint);
//       final digest = md5.convert(bytes);
//       return digest.toString();
//     } catch (e) {
//       // Fallback fingerprint
//       final fallback = '${DateTime.now().millisecondsSinceEpoch}-${_random.nextInt(999999)}';
//       final bytes = utf8.encode(fallback);
//       final digest = md5.convert(bytes);
//       return digest.toString();
//     }
//   }

//   // === DYNAMIC USER AGENT MANAGEMENT ===
  
//   String _getCurrentUserAgentDynamic() {
//     final agents = _userAgentsByPlatform[_currentPlatform] ?? [];
//     if (agents.isEmpty) return _getDefaultUserAgent();
    
//     final agent = agents[_currentUserAgentIndex % agents.length];
    
//     // Add dynamic modifications to make each request unique
//     return _modifyUserAgentDynamically(agent);
//   }

//   String _modifyUserAgentDynamically(String baseAgent) {
//     // Strategy 1: Random Chrome version bumping
//     final chromeVersions = ['98.0.4758.102', '97.0.4692.99', '96.0.4664.110', '99.0.4844.74', '100.0.4896.75'];
//     final randomVersion = chromeVersions[_random.nextInt(chromeVersions.length)];
//     String modifiedAgent = baseAgent.replaceAll(RegExp(r'Chrome/[\d.]+'), 'Chrome/$randomVersion');
    
//     // Strategy 2: Add random WebKit version variations
//     final webkitVersions = ['537.36', '537.35', '537.34'];
//     final randomWebkit = webkitVersions[_random.nextInt(webkitVersions.length)];
//     modifiedAgent = modifiedAgent.replaceAll(RegExp(r'AppleWebKit/[\d.]+'), 'AppleWebKit/$randomWebkit');
    
//     // Strategy 3: Add session-specific suffix (subtle)
//     if (_sessionId != null && _random.nextBool()) {
//       final suffix = _sessionId!.substring(0, 4);
//       modifiedAgent = modifiedAgent.replaceAll('Safari/537.36', 'Safari/537.36.$suffix');
//     }
    
//     return modifiedAgent;
//   }

//   String _getDefaultUserAgent() {
//     return 'Mozilla/5.0 (Linux; Android 11; TV) AppleWebKit/537.36 Chrome/94.0.4606.71 Safari/537.36';
//   }

//   // === INTELLIGENT USER AGENT ROTATION ===
  
//   void _rotateUserAgentIntelligently() {
//     final currentAgent = _getCurrentUserAgentDynamic();
    
//     // Mark current user agent as failed
//     _userAgentFailCount[currentAgent] = (_userAgentFailCount[currentAgent] ?? 0) + 1;
    
//     // If this agent has failed too many times, put it on cooldown
//     if (_userAgentFailCount[currentAgent]! >= 3) {
//       _userAgentCooldowns[currentAgent] = DateTime.now();
//       print('🚫 User agent on cooldown: ${currentAgent.substring(0, 50)}...');
//     }
    
//     // Try to switch platform if current platform is having issues
//     if (_shouldSwitchPlatform()) {
//       _switchPlatform();
//     } else {
//       // Just rotate within current platform
//       _currentUserAgentIndex++;
//     }
    
//     // Remove expired cooldowns
//     _cleanupCooldowns();
    
//     _failedAttempts++;
//     print('🔄 Rotated to: ${_getCurrentUserAgentDynamic().substring(0, 60)}...');
//     print('📊 Current platform: $_currentPlatform, Index: $_currentUserAgentIndex');
//     print('Failed attempts so far: $_failedAttempts');
//   }

//   bool _shouldSwitchPlatform() {
//     final agents = _userAgentsByPlatform[_currentPlatform] ?? [];
//     int cooledDownCount = 0;
    
//     for (String agent in agents) {
//       if (_userAgentCooldowns.containsKey(agent)) {
//         cooledDownCount++;
//       }
//     }
    
//     // Switch platform if more than 50% of agents are on cooldown
//     return cooledDownCount > (agents.length * 0.5);
//   }

//   void _switchPlatform() {
//     final platforms = _userAgentsByPlatform.keys.toList();
    
//     // Find platform with least failures
//     String bestPlatform = _currentPlatform;
//     int leastFailures = 999;
    
//     for (String platform in platforms) {
//       final agents = _userAgentsByPlatform[platform] ?? [];
//       int failures = 0;
      
//       for (String agent in agents) {
//         failures += _userAgentFailCount[agent] ?? 0;
//       }
      
//       if (failures < leastFailures) {
//         leastFailures = failures;
//         bestPlatform = platform;
//       }
//     }
    
//     _currentPlatform = bestPlatform;
//     _currentUserAgentIndex = 0;
    
//     print('🔀 Switched to platform: $_currentPlatform');
//   }

//   void _cleanupCooldowns() {
//     final now = DateTime.now();
//     final keysToRemove = <String>[];
    
//     _userAgentCooldowns.forEach((agent, cooldownTime) {
//       if (now.difference(cooldownTime) > _cooldownDuration) {
//         keysToRemove.add(agent);
//       }
//     });
    
//     for (String key in keysToRemove) {
//       _userAgentCooldowns.remove(key);
//       _userAgentFailCount[key] = 0; // Reset fail count
//     }
//   }

//   // === DYNAMIC REQUEST TIMING ===
  
//   Future<void> _addIntelligentDelay() async {
//     _requestCounter++;
    
//     // Base delay with randomization
//     final baseDelay = _minDelayMs + _random.nextInt(_maxDelayMs - _minDelayMs);
    
//     // Add progressive delay based on failure count
//     final totalFailures = _userAgentFailCount.values.fold(0, (sum, count) => sum + count);
//     final progressiveDelay = totalFailures * 500; // 500ms per failure
    
//     // Add request counter based delay (simulate human behavior)
//     final counterDelay = (_requestCounter % 5) * 200; // Every 5th request gets extra delay
    
//     // Check if we need to wait based on last request time
//     final now = DateTime.now();
//     if (_lastRequestTime != null) {
//       final timeSinceLastRequest = now.difference(_lastRequestTime!);
//       if (timeSinceLastRequest < _requestDelay) {
//         final delayNeeded = _requestDelay - timeSinceLastRequest;
//         await Future.delayed(delayNeeded);
//       }
//     }
//     _lastRequestTime = now;

//     // Extra delay for multiple failures
//     if (_failedAttempts > _maxFailedAttempts) {
//       final extraDelay = Duration(seconds: _failedAttempts * 2);
//       print('Extra delay due to failures: ${extraDelay.inSeconds}s');
//       await Future.delayed(extraDelay);
//     }
    
//     final totalDelay = baseDelay + progressiveDelay + counterDelay;
    
//     print('⏱️ Intelligent delay: ${totalDelay}ms (base: $baseDelay, progressive: $progressiveDelay, counter: $counterDelay)');
    
//     await Future.delayed(Duration(milliseconds: totalDelay.round()));
//   }

//   // === ADVANCED HEADER GENERATION ===
  
//   Map<String, String> _generateDynamicHeaders() {
//     final headers = <String, String>{};
    
//     // Core headers
//     headers['User-Agent'] = _getCurrentUserAgentDynamic();
//     headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8';
//     headers['Accept-Language'] = _getRandomAcceptLanguage();
//     headers['Accept-Encoding'] = 'gzip, deflate, br';
//     headers['DNT'] = _random.nextBool() ? '1' : '0';
//     headers['Connection'] = 'keep-alive';
//     headers['Upgrade-Insecure-Requests'] = '1';
    
//     // Referrer strategies
//     final referrers = [
//       'https://www.youtube.com/',
//       'https://m.youtube.com/',
//       'https://youtube.com/watch',
//       'https://www.google.com/',
//       'https://google.com/',
//     ];
//     headers['Referer'] = referrers[_random.nextInt(referrers.length)];
    
//     // Geographic simulation
//     if (_random.nextBool()) {
//       headers['CF-IPCountry'] = _currentGeoLocation;
//     }
    
//     // Session continuity
//     if (_sessionId != null && _random.nextBool()) {
//       headers['X-Session-ID'] = _sessionId!;
//     }
    
//     // Cache control randomization
//     final cacheControls = ['no-cache', 'max-age=0', 'no-cache, no-store'];
//     headers['Cache-Control'] = cacheControls[_random.nextInt(cacheControls.length)];
    
//     return headers;
//   }

//   String _getRandomAcceptLanguage() {
//     final languages = [
//       'en-US,en;q=0.9',
//       'en-GB,en;q=0.9',
//       'en-US,en;q=0.8,hi;q=0.6',
//       'en,hi;q=0.9',
//       'en-US,en;q=0.9,de;q=0.8',
//       'en-US,en;q=0.9,fr;q=0.8',
//       'en,es;q=0.8',
//     ];
//     return languages[_random.nextInt(languages.length)];
//   }

//   // === ENHANCED STREAM LOADING ===
  
//   Future<void> _loadStreamUrlsEnhanced() async {
//     if (_isInitializing || _isDisposed || _isDisposing) return;

//     if (!mounted) return;

//     setState(() {
//       _earlyPauseTriggered = false;
//       _isInitializing = true;
//       _errorMessage = null;
//     });

//     try {
//       if (widget.videoUrl.isEmpty) {
//         throw Exception('Video URL is empty');
//       }

//       print('🎬 Enhanced stream loading initiated...');
//       print('🔄 Request #$_requestCounter');
//       print('🌍 Geo location: $_currentGeoLocation');
//       print('📱 Platform: $_currentPlatform');
//       print('🚫 BLOCKING: 2K (1440p), 4K (2160p), 8K (4320p) quality');
//       print('✅ ALLOWING: Maximum ${MAX_VIDEO_HEIGHT}p quality');
      
//       // Add intelligent delay
//       await _addIntelligentDelay();
      
//       if (_isDisposed || _isDisposing || !mounted) return;

//       // Generate dynamic headers for logging
//       final headers = _generateDynamicHeaders();
//       print('📋 Generated ${headers.length} dynamic headers');
//       print('🌐 Using user agent: ${_getCurrentUserAgentDynamic().substring(0, 60)}...');

//       // Try multiple strategies
//       StreamManifest? manifest;
//       int strategyIndex = 0;
//       final maxStrategies = 4; // Increased strategies

//       while (strategyIndex < maxStrategies && manifest == null && !_isDisposed && !_isDisposing && mounted) {
//         try {
//           print('🎯 Trying strategy ${strategyIndex + 1}/$maxStrategies...');
          
//           // Strategy-specific modifications
//           switch (strategyIndex) {
//             case 0:
//               // Direct approach with current settings
//               manifest = await _tryDirectManifest();
//               break;
//             case 1:
//               // Rotate user agent and geo location
//               _rotateUserAgentIntelligently();
//               _currentGeoLocation = _geoLocations[_random.nextInt(_geoLocations.length)];
//               print('🌍 Switched geo to: $_currentGeoLocation');
//               manifest = await _tryDirectManifest();
//               break;
//             case 2:
//               // Switch platform completely
//               _switchPlatform();
//               manifest = await _tryDirectManifest();
//               break;
//             case 3:
//               // Last resort: try with minimal delay and different approach
//               print('🚨 Last resort strategy...');
//               await Future.delayed(Duration(seconds: 5)); // Longer wait
//               _currentPlatform = 'desktop'; // Force desktop
//               _currentUserAgentIndex = 0;
//               manifest = await _tryDirectManifest();
//               break;
//           }

//           if (manifest != null) {
//             print('✅ Strategy ${strategyIndex + 1} succeeded!');
//             _failedAttempts = 0; // Reset on success
//             _adaptConfigurationBasedOnSuccess();
//             break;
//           }
//         } catch (e) {
//           print('❌ Strategy ${strategyIndex + 1} failed: $e');
//           await _handleStrategyError(e, strategyIndex);
//           strategyIndex++;
          
//           if (strategyIndex < maxStrategies) {
//             final waitTime = strategyIndex * 3; // Progressive wait
//             print('⏳ Waiting ${waitTime}s before next strategy...');
//             await Future.delayed(Duration(seconds: waitTime));
//           }
//         }
//       }

//       if (manifest != null) {
//         await _processManifestEnhanced(manifest);
//       } else {
//         throw Exception('All ${maxStrategies} strategies failed to obtain manifest');
//       }

//     } catch (e) {
//       await _handleLoadingError(e);
//     }
//   }

//   Future<StreamManifest?> _tryDirectManifest() async {
//     return await _youtubeExplode.videos.streamsClient.getManifest(widget.videoUrl);
//   }

//   Future<void> _handleStrategyError(dynamic error, int strategyIndex) async {
//     String errorType = _analyzeError(error);
    
//     print('🔍 Error analysis for strategy ${strategyIndex + 1}: $errorType');
    
//     switch (errorType) {
//       case 'rate_limit':
//         // Increase delays significantly
//         _minDelayMs = (_minDelayMs * 1.5).round();
//         _maxDelayMs = (_maxDelayMs * 1.5).round();
//         print('📈 Increased delays to $_minDelayMs-${_maxDelayMs}ms');
//         break;
//       case 'geo_block':
//         // Try different geo location
//         final oldGeo = _currentGeoLocation;
//         _currentGeoLocation = _geoLocations[_random.nextInt(_geoLocations.length)];
//         print('🌍 Changed geo from $oldGeo to $_currentGeoLocation');
//         break;
//       case 'user_agent_block':
//         // Force immediate platform switch
//         _switchPlatform();
//         break;
//       default:
//         _rotateUserAgentIntelligently();
//     }
//   }

//   Future<void> _processManifestEnhanced(StreamManifest manifest) async {
//     print('📊 Processing manifest with ${manifest.streams.length} total streams');
    
//     // Use existing filtering logic but with enhanced logging
//     var muxedStreams = manifest.muxed;
//     print('📺 Found ${muxedStreams?.length ?? 0} muxed streams');

//     if (muxedStreams != null && muxedStreams.isNotEmpty) {
//       // Debug: Print all available muxed streams with blocked indicator
//       print('🔍 Available muxed streams:');
//       for (var stream in muxedStreams) {
//         String blockedIndicator =
//             stream.videoResolution.height > MAX_VIDEO_HEIGHT
//                 ? ' 🚫 BLOCKED'
//                 : ' ✅ ALLOWED';
//         print(
//             '   - ${stream.tag}: ${stream.videoResolution.height}p${blockedIndicator}');
//       }

//       // STRICT Filter: Block 2K/4K/8K - Only allow up to 1080p
//       var filteredMuxedStreams = muxedStreams.where((stream) {
//         bool isAllowed = stream.videoResolution.height <= MAX_VIDEO_HEIGHT;
//         if (!isAllowed) {
//           print(
//               '🚫 BLOCKING ${stream.tag}: ${stream.videoResolution.height}p (>${MAX_VIDEO_HEIGHT}p)');
//         }
//         return isAllowed;
//       }).toList();

//       print(
//           '📏 Filtered muxed streams (≤${MAX_VIDEO_HEIGHT}p): ${filteredMuxedStreams.length}');
//       print(
//           '🚫 Blocked high quality streams: ${muxedStreams.length - filteredMuxedStreams.length}');

//       if (filteredMuxedStreams.isNotEmpty) {
//         print('✅ Using filtered muxed stream approach');
//         await _handleFilteredMuxedStreams(filteredMuxedStreams);
//         return;
//       } else {
//         print(
//             '⚠️ No muxed streams found ≤${MAX_VIDEO_HEIGHT}p (All were 2K/4K/8K), trying separate streams...');
//       }
//     }

//     // Use separate video and audio streams with 1080p limit
//     print('🎥 Using separate video and audio streams approach...');
//     await _handleSeparateStreams(manifest);
//   }

//   Future<void> _handleSeparateStreams(StreamManifest manifest) async {
//     var videoOnlyStreams = manifest.videoOnly;
//     print('🎬 Found ${videoOnlyStreams?.length ?? 0} video-only streams');

//     VideoOnlyStreamInfo? bestVideoStream;
//     if (videoOnlyStreams != null && videoOnlyStreams.isNotEmpty) {
//       // Debug: Print all available video streams with blocked indicator
//       print('🔍 Available video-only streams:');
//       for (var stream in videoOnlyStreams) {
//         String blockedIndicator =
//             stream.videoResolution.height > MAX_VIDEO_HEIGHT
//                 ? ' 🚫 BLOCKED'
//                 : ' ✅ ALLOWED';
//         print(
//             '   - ${stream.tag}: ${stream.videoResolution.height}p${blockedIndicator}');
//       }

//       // STRICT Filter: Block 2K/4K/8K - Only allow up to 1080p
//       var filteredVideoStreams = videoOnlyStreams.where((stream) {
//         bool isAllowed = stream.videoResolution.height <= MAX_VIDEO_HEIGHT;
//         if (!isAllowed) {
//           print(
//               '🚫 BLOCKING ${stream.tag}: ${stream.videoResolution.height}p (>${MAX_VIDEO_HEIGHT}p)');
//         }
//         return isAllowed;
//       }).toList();

//       print(
//           '📏 Filtered video streams (≤${MAX_VIDEO_HEIGHT}p): ${filteredVideoStreams.length}');
//       print(
//           '🚫 Blocked high quality streams: ${videoOnlyStreams.length - filteredVideoStreams.length}');

//       if (filteredVideoStreams.isNotEmpty) {
//         // Sort by quality (highest first within the limit)
//         filteredVideoStreams.sort((a, b) =>
//             b.videoResolution.height.compareTo(a.videoResolution.height));

//         bestVideoStream = filteredVideoStreams.first;
//         print(
//             '✅ Selected video stream: ${bestVideoStream.tag} - ${bestVideoStream.videoResolution.height}p');
//       } else {
//         // If no streams within limit, use the lowest available
//         var sortedVideoStreams = videoOnlyStreams.toList()
//           ..sort((a, b) =>
//               a.videoResolution.height.compareTo(b.videoResolution.height));
//         bestVideoStream = sortedVideoStreams.first;
//         print(
//             '⚠️ No video streams ≤${MAX_VIDEO_HEIGHT}p found (All were 2K/4K/8K), using lowest available: ${bestVideoStream.videoResolution.height}p');
//       }
//     }

//     var audioOnlyStreams = manifest.audioOnly;
//     print('🎵 Found ${audioOnlyStreams?.length ?? 0} audio-only streams');

//     AudioOnlyStreamInfo? bestAudioStream;
//     if (audioOnlyStreams != null && audioOnlyStreams.isNotEmpty) {
//       var sortedAudioStreams = audioOnlyStreams.toList()
//         ..sort((a, b) =>
//             b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond));
//       bestAudioStream = sortedAudioStreams.first;
//       print(
//           '✅ Selected audio stream: ${bestAudioStream.tag} - ${bestAudioStream.audioCodec} - ${bestAudioStream.bitrate}');
//     }

//     if (bestVideoStream != null && bestAudioStream != null) {
//       String videoUrl = bestVideoStream.url.toString();
//       String audioUrl = bestAudioStream.url.toString();

//       print(
//           '🔗 Video URL loaded (${bestVideoStream.videoResolution.height}p)');
//       print('🔗 Audio URL loaded');

//       _videoStreamUrl = videoUrl;
//       _audioStreamUrl = audioUrl;
      
//       await _finalizeStreamSetup();
//     } else {
//       String missingStreams = '';
//       if (bestVideoStream == null) missingStreams += 'video ';
//       if (bestAudioStream == null) missingStreams += 'audio ';

//       throw Exception('No $missingStreams streams found for this video. This video might be restricted or unavailable.');
//     }
//   }

//   // Handle filtered muxed streams
//   Future<void> _handleFilteredMuxedStreams(List<MuxedStreamInfo> filteredStreams) async {
//     if (_isDisposed || _isDisposing || !mounted) return;

//     // Sort by quality (highest first within the limit)
//     var sortedStreams = filteredStreams.toList()
//       ..sort((a, b) {
//         int qualityCompare =
//             b.videoResolution.height.compareTo(a.videoResolution.height);
//         if (qualityCompare != 0) return qualityCompare;
//         return b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond);
//       });

//     MuxedStreamInfo bestStream = sortedStreams.first;
//     String streamUrl = bestStream.url.toString();

//     print(
//         '✅ Selected muxed stream: ${bestStream.tag} - ${bestStream.videoResolution.height}p - Bitrate: ${bestStream.bitrate}');
//     print(
//         '🚫 CONFIRMED: No 2K/4K/8K quality - Maximum ${MAX_VIDEO_HEIGHT}p enforced');

//     _videoStreamUrl = streamUrl;
//     _audioStreamUrl = null;
    
//     await _finalizeStreamSetup();
//   }

//   Future<void> _finalizeStreamSetup() async {
//     if (mounted && !_isDisposed && !_isDisposing) {
//       setState(() {
//         _controllerCreated = true;
//         _isInitializing = false;
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!_isDisposed && !_isDisposing && mounted) {
//           _initializationTimer = Timer(Duration(milliseconds: 3000), () {
//             if (mounted && !_isDisposed && !_isDisposing) {
//               _waitForAutoInitialization();
//             }
//           });
//         }
//       });
//     }
//   }

//   String _analyzeError(dynamic error) {
//     final errorString = error.toString().toLowerCase();
    
//     if (errorString.contains('429') || errorString.contains('rate')) {
//       return 'rate_limit';
//     } else if (errorString.contains('403') || errorString.contains('forbidden')) {
//       return 'user_agent_block';
//     } else if (errorString.contains('geo') || errorString.contains('region')) {
//       return 'geo_block';
//     } else if (errorString.contains('timeout')) {
//       return 'timeout';
//     } else if (errorString.contains('unavailable') || errorString.contains('private')) {
//       return 'video_unavailable';
//     } else {
//       return 'unknown';
//     }
//   }

//   Future<void> _handleLoadingError(dynamic error) async {
//     print('❌ Enhanced loading error: $error');
    
//     // Intelligent error analysis
//     String errorType = _analyzeError(error);
    
//     switch (errorType) {
//       case 'rate_limit':
//         // Increase delays and try different platform
//         _minDelayMs = (_minDelayMs * 2).round();
//         _maxDelayMs = (_maxDelayMs * 2).round();
//         _switchPlatform();
//         break;
//       case 'geo_block':
//         // Switch geo location
//         _currentGeoLocation = _geoLocations[_random.nextInt(_geoLocations.length)];
//         break;
//       case 'user_agent_block':
//         // Force platform switch
//         _switchPlatform();
//         break;
//       case 'video_unavailable':
//         // Don't retry for unavailable videos
//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() {
//             _errorMessage = 'This video is unavailable, private, or has been removed';
//             _isInitializing = false;
//           });
//         }
//         return;
//       default:
//         // Generic handling
//         _rotateUserAgentIntelligently();
//     }
    
//     // Prepare retry message
//     String errorMessage = 'Enhanced retry in progress... (Error: $errorType)';
    
//     if (errorType == 'rate_limit') {
//       errorMessage = 'Rate limited: Trying different approach...';
//     } else if (errorType == 'geo_block') {
//       errorMessage = 'Geographic restriction: Switching location...';
//     } else if (errorType == 'user_agent_block') {
//       errorMessage = 'User agent blocked: Switching platform...';
//     }
    
//     if (_failedAttempts < _maxFailedAttempts) {
//       // Schedule retry
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage = errorMessage;
//           _isInitializing = false;
//         });
//       }
      
//       Timer(Duration(seconds: 5), () {
//         if (mounted && !_isDisposed && !_isDisposing) {
//           _retryWithEnhancedStrategy();
//         }
//       });
//     } else {
//       // Too many failures
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage = 'All enhanced strategies failed. Video may be restricted or temporarily unavailable. (Attempts: $_failedAttempts)';
//           _isInitializing = false;
//         });
//       }
//     }
//   }

//   Future<void> _retryWithEnhancedStrategy() async {
//     if (_failedAttempts >= _maxFailedAttempts || _isDisposed || _isDisposing) {
//       return;
//     }

//     print('🔄 Enhanced retry strategy triggered...');
    
//     // Reset state for retry
//     if (mounted && !_isDisposed && !_isDisposing) {
//       setState(() {
//         _errorMessage = null;
//         _isInitialized = false;
//         _isInitializing = false;
//         _controllerCreated = false;
//         _useDualStream = false;
//         _videoStreamUrl = null;
//         _audioStreamUrl = null;
//       });
//     }

//     await _disposeControllersSync();
//     await Future.delayed(Duration(seconds: 3));

//     if (mounted && !_isDisposed && !_isDisposing) {
//       _loadStreamUrlsEnhanced();
//     }
//   }

//   // === MONITORING AND ANALYTICS ===
  
//   void _logSuccessMetrics() {
//     print('📈 Success Metrics:');
//     print('   Platform: $_currentPlatform');
//     print('   Requests: $_requestCounter');
//     print('   Current delay range: $_minDelayMs-${_maxDelayMs}ms');
//     print('   Active cooldowns: ${_userAgentCooldowns.length}');
//     print('   Failed attempts: $_failedAttempts');
//   }

//   // === ADAPTIVE CONFIGURATION ===
  
//   void _adaptConfigurationBasedOnSuccess() {
//     // If we're having success, we can be more aggressive
//     if (_userAgentFailCount.values.every((count) => count < 2)) {
//       _minDelayMs = math.max(500, (_minDelayMs * 0.9).round());
//       _maxDelayMs = math.max(2000, (_maxDelayMs * 0.9).round());
//       print('✅ Reducing delays due to success pattern');
//     }
//     _logSuccessMetrics();
//   }

//   // === LEGACY FALLBACK METHOD ===
  
//   Future<void> _loadStreamUrls() async {
//     // This is the original method as fallback
//     if (_isInitializing || _isDisposed || _isDisposing) return;

//     if (!mounted) return;

//     setState(() {
//       _earlyPauseTriggered = false;
//       _isInitializing = true;
//       _errorMessage = null;
//     });

//     try {
//       if (widget.videoUrl.isEmpty) {
//         throw Exception('Video URL is empty');
//       }

//       print('🎬 Fallback: Loading streams for: ${widget.videoUrl}');
//       print('🚫 BLOCKING: 2K (1440p), 4K (2160p), 8K (4320p) quality');
//       print('✅ ALLOWING: Maximum ${MAX_VIDEO_HEIGHT}p quality');

//       await _addRequestDelay();

//       if (_isDisposed || _isDisposing || !mounted) return;

//       StreamManifest? manifest;
//       int retryCount = 0;
//       const maxRetries = 3;

//       while (retryCount < maxRetries &&
//           manifest == null &&
//           !_isDisposed &&
//           !_isDisposing &&
//           mounted) {
//         try {
//           print('🔄 Fallback attempt ${retryCount + 1}/$maxRetries to get manifest...');
//           manifest = await _youtubeExplode.videos.streamsClient
//               .getManifest(widget.videoUrl);

//           _failedAttempts = 0;
//           print('✅ Fallback manifest loaded successfully on attempt ${retryCount + 1}');
//           break;
//         } catch (manifestError) {
//           retryCount++;
//           print('❌ Fallback manifest error on attempt $retryCount: $manifestError');

//           if (retryCount < maxRetries &&
//               !_isDisposed &&
//               !_isDisposing &&
//               mounted) {
//             _rotateUserAgentLegacy();
//             print('🔄 Fallback retrying with different user agent...');
//             await Future.delayed(Duration(seconds: retryCount * 2));
//             if (_isDisposed || _isDisposing || !mounted) return;
//           } else {
//             throw Exception(
//                 'Fallback failed to get video manifest after $maxRetries attempts: $manifestError');
//           }
//         }
//       }

//       if (_isDisposed || _isDisposing || !mounted) return;

//       if (manifest == null) {
//         throw Exception('Fallback could not get video manifest after all retries');
//       }

//       // Process manifest using legacy method
//       await _processManifestLegacy(manifest);

//     } catch (e) {
//       print('❌ Fallback error loading streams: $e');
//       await _handleLegacyError(e);
//     }
//   }

//   void _rotateUserAgentLegacy() {
//     // Simple rotation for fallback
//     final allAgents = <String>[];
//     _userAgentsByPlatform.values.forEach((agents) => allAgents.addAll(agents));
    
//     _currentUserAgentIndex = (_currentUserAgentIndex + 1) % allAgents.length;
//     _failedAttempts++;

//     print('Fallback rotating to user agent ${_currentUserAgentIndex + 1}/${allAgents.length}');
//     print('Failed attempts so far: $_failedAttempts');
//   }

//   Future<void> _addRequestDelay() async {
//     if (_isDisposed || _isDisposing) return;

//     final now = DateTime.now();
//     if (_lastRequestTime != null) {
//       final timeSinceLastRequest = now.difference(_lastRequestTime!);
//       if (timeSinceLastRequest < _requestDelay) {
//         final delayNeeded = _requestDelay - timeSinceLastRequest;
//         print(
//             'Rate limiting: waiting ${delayNeeded.inMilliseconds}ms before next request');
//         await Future.delayed(delayNeeded);
//       }
//     }
//     _lastRequestTime = now;

//     if (_failedAttempts > _maxFailedAttempts) {
//       final extraDelay = Duration(seconds: _failedAttempts * 2);
//       print('Extra delay due to failures: ${extraDelay.inSeconds}s');
//       await Future.delayed(extraDelay);
//     }
//   }

//   Future<void> _processManifestLegacy(StreamManifest manifest) async {
//     // Use the original manifest processing logic
//     var muxedStreams = manifest.muxed;
//     print('📺 Found ${muxedStreams?.length ?? 0} muxed streams');

//     if (muxedStreams != null && muxedStreams.isNotEmpty) {
//       var filteredMuxedStreams = muxedStreams.where((stream) {
//         return stream.videoResolution.height <= MAX_VIDEO_HEIGHT;
//       }).toList();

//       if (filteredMuxedStreams.isNotEmpty) {
//         await _handleFilteredMuxedStreams(filteredMuxedStreams);
//         return;
//       }
//     }

//     await _handleSeparateStreams(manifest);
//   }

//   Future<void> _handleLegacyError(dynamic error) async {
//     String errorMessage = 'Error loading video: ${error.toString()}';

//     if (error.toString().contains('VideoUnavailableException')) {
//       errorMessage = 'This video is unavailable or private';
//     } else if (error.toString().contains('VideoRequiresPurchaseException')) {
//       errorMessage = 'This video requires purchase';
//     } else if (error.toString().contains('SocketException')) {
//       errorMessage = 'Network error: Please check your internet connection';
//     } else if (error.toString().contains('TimeoutException')) {
//       errorMessage = 'Request timed out: Please try again';
//     } else if (error.toString().contains('403') ||
//         error.toString().contains('Forbidden')) {
//       errorMessage = 'Access blocked: Trying different user agent...';
//       if (_failedAttempts < 10) {
//         Timer(Duration(seconds: 3), () {
//           if (mounted && !_isDisposed && !_isDisposing) {
//             _retryWithDifferentUserAgent();
//           }
//         });
//       }
//     } else if (error.toString().contains('429') ||
//         error.toString().contains('rate')) {
//       errorMessage = 'Rate limited: Please wait before trying again...';
//     }

//     if (mounted && !_isDisposed && !_isDisposing) {
//       setState(() {
//         _errorMessage = errorMessage;
//         _isInitializing = false;
//       });
//     }
//   }

//   // Enhanced keyboard handling with progressive seek
//   void _handleKeyEvent(RawKeyEvent event) {
//     if (event is RawKeyDownEvent) {
//       switch (event.logicalKey) {
//         case LogicalKeyboardKey.select:
//         case LogicalKeyboardKey.space:
//         case LogicalKeyboardKey.enter:
//           _togglePlayPause();
//           break;
//         case LogicalKeyboardKey.arrowLeft:
//           _seekVideoProgressive(false);
//           _showControlsTemporarily();
//           break;
//         case LogicalKeyboardKey.arrowRight:
//           _seekVideoProgressive(true);
//           _showControlsTemporarily();
//           break;
//         case LogicalKeyboardKey.arrowUp:
//         case LogicalKeyboardKey.arrowDown:
//           _showControlsTemporarily();
//           break;
//       }
//     }
//   }

//   // Enhanced Progressive Seeking
//   void _seekVideoProgressive(bool forward) {
//     if (!_isInitialized || 
//         _playerController == null || 
//         _totalDuration.inSeconds <= 24 || 
//         _isDisposed || 
//         _isDisposing) {
//       return;
//     }

//     // Calculate seek amount based on video duration
//     final adjustedEndTime = _totalDuration.inSeconds - 12;
//     final seekAmount = (adjustedEndTime / 200).round().clamp(5, 30);

//     // Cancel existing timer
//     _progressiveSeekTimer?.cancel();

//     // Accumulate seek amount
//     if (forward) {
//       _pendingSeekSeconds += seekAmount;
//     } else {
//       _pendingSeekSeconds -= seekAmount;
//     }

//     // Calculate target position
//     final currentSeconds = _currentPosition.inSeconds;
//     final targetSeconds = (currentSeconds + _pendingSeekSeconds)
//         .clamp(0, adjustedEndTime);
//     _targetSeekPosition = Duration(seconds: targetSeconds);

//     // Update UI to show seeking state
//     if (mounted && !_isDisposed && !_isDisposing) {
//       setState(() {
//         _isProgressiveSeeking = true;
//       });
//     }

//     // Set timer to execute seek after delay
//     _progressiveSeekTimer = Timer(const Duration(milliseconds: 1000), () {
//       _executeProgressiveSeek();
//     });
//   }

//   void _executeProgressiveSeek() async {
//     if (!_isInitialized || 
//         _playerController == null || 
//         _isDisposed || 
//         _isDisposing || 
//         _pendingSeekSeconds == 0) {
//       return;
//     }

//     final adjustedEndTime = _totalDuration.inSeconds - 12;
//     final currentSeconds = _currentPosition.inSeconds;
//     final newPosition = (currentSeconds + _pendingSeekSeconds)
//         .clamp(0, adjustedEndTime);

//     try {
//       await _seekBothWithDebounce(Duration(seconds: newPosition));
//     } catch (e) {
//       print('Progressive seek error: $e');
//     } finally {
//       // Reset progressive seek state
//       _pendingSeekSeconds = 0;
//       _targetSeekPosition = Duration.zero;

//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _isProgressiveSeeking = false;
//         });
//       }
//     }
//   }

//   void _showControlsTemporarily() {
//     setState(() {
//       _showControls = true;
//     });

//     _controlsTimer?.cancel();
//     _controlsTimer = Timer(Duration(seconds: 5), () {
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _showControls = false;
//         });
//       }
//     });
//   }

//   void _togglePlayPause() {
//     if (_isPlaying) {
//       _pauseBoth();
//     } else {
//       _playBoth();
//     }
//     _showControlsTemporarily();
//   }

//   // Fixed seeking with debouncing
//   void _seekBackwardDebounced() {
//     if (_isSeeking || _isProgressiveSeeking) return;

//     _seekDebounceTimer?.cancel();
//     _seekDebounceTimer = Timer(Duration(milliseconds: 100), () {
//       final newPosition = _currentPosition - Duration(seconds: 10);
//       final targetPosition =
//           newPosition < Duration.zero ? Duration.zero : newPosition;
//       _seekBothWithDebounce(targetPosition);
//     });
//   }

//   void _seekForwardDebounced() {
//     if (_isSeeking || _isProgressiveSeeking) return;

//     _seekDebounceTimer?.cancel();
//     _seekDebounceTimer = Timer(Duration(milliseconds: 100), () {
//       final newPosition = _currentPosition + Duration(seconds: 10);
//       final targetPosition =
//           newPosition > _totalDuration ? _totalDuration : newPosition;
//       _seekBothWithDebounce(targetPosition);
//     });
//   }

//   // Fixed seek method with proper audio restoration
//   Future<void> _seekBothWithDebounce(Duration position) async {
//     if (!_isInitialized ||
//         _playerController == null ||
//         _isDisposed ||
//         _isDisposing ||
//         _isSeeking) {
//       return;
//     }

//     _isSeeking = true;
//     bool wasPlaying = _isPlaying;
//     _earlyPauseTriggered = false;

//     try {
//       print(
//           '🎯 Seeking to ${position.inSeconds}s (was playing: $wasPlaying)...');

//       // Always pause first to prevent audio issues
//       await _playerController?.pause();
//       if (_useDualStream && _audioController != null) {
//         await _audioController?.pause();
//       }

//       // Wait for pause to take effect
//       await Future.delayed(Duration(milliseconds: 100));

//       // Seek video controller first
//       final videoInitialized = _playerController?.value.isInitialized ?? false;
//       if (videoInitialized) {
//         print('🎬 Seeking video controller...');
//         await _playerController?.seekTo(position);
//       }

//       // Seek audio controller with extra sync
//       if (_useDualStream && _audioController != null) {
//         final audioInitialized = _audioController?.value.isInitialized ?? false;
//         if (audioInitialized) {
//           print('🎵 Seeking audio controller...');
//           await _audioController?.seekTo(position);

//           // Additional audio sync attempt
//           await Future.delayed(Duration(milliseconds: 50));
//           await _audioController?.seekTo(position);
//         }
//       }

//       // Wait for seek to complete
//       await Future.delayed(Duration(milliseconds: 200));

//       // Force resume playback if it was playing before
//       if (wasPlaying) {
//         print('▶️ Resuming playback after seek...');

//         // Start video first
//         await _playerController?.play();

//         // Then start audio with slight delay for sync
//         if (_useDualStream && _audioController != null) {
//           await Future.delayed(Duration(milliseconds: 50));
//           await _audioController?.play();

//           // Verify audio is actually playing
//           Timer(Duration(milliseconds: 500), () async {
//             if (_audioController != null && wasPlaying && !_isDisposed) {
//               final audioPlaying = _audioController?.value.isPlaying ?? false;
//               if (!audioPlaying) {
//                 print('🔄 Audio not playing, forcing restart...');
//                 await _audioController?.play();
//               }
//             }
//           });
//         }

//         // Update playing state
//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() {
//             _isPlaying = true;
//           });
//         }
//       }

//       // Update position immediately
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _currentPosition = position;
//         });
//       }

//       print(
//           '✅ Seek completed - Audio should be ${wasPlaying ? "playing" : "paused"}');
//     } catch (e) {
//       print('❌ Error seeking: $e');

//       // Emergency audio recovery
//       if (wasPlaying && _useDualStream && _audioController != null) {
//         try {
//           await _audioController?.play();
//         } catch (recoveryError) {
//           print('❌ Audio recovery failed: $recoveryError');
//         }
//       }
//     } finally {
//       // Reset seeking state
//       Timer(Duration(milliseconds: 300), () {
//         _isSeeking = false;
//       });
//     }
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);

//     switch (state) {
//       case AppLifecycleState.paused:
//       case AppLifecycleState.detached:
//         print('App paused/detached - stopping players safely');
//         _stopPlayersForBackground();
//         break;
//       case AppLifecycleState.resumed:
//         print('App resumed');
//         break;
//       default:
//         break;
//     }
//   }

//   void _stopPlayersForBackground() {
//     if (_isDisposed || _isDisposing) return;

//     try {
//       _playerController?.pause();
//       _audioController?.pause();
//       setState(() {
//         _isPlaying = false;
//       });
//     } catch (e) {
//       print('Error stopping players for background: $e');
//     }
//   }

//   Future<bool> _onWillPop() async {
//     print('Back button pressed - initiating safe disposal');

//     if (_isDisposing || _isDisposed) {
//       return true;
//     }

//     if (!Navigator.canPop(context)) {
//       print('⚠️ This is root page - preventing app close');
//       _showExitDialog();
//       return false;
//     }

//     _startSafeDisposal();
//     return true;
//   }

//   void _showExitDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Exit App?'),
//           content: Text('Do you want to exit the application?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Exit'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _startSafeDisposal() {
//     if (_isDisposing || _isDisposed) return;

//     print('Starting safe disposal process...');
//     _isDisposing = true;

//     _cancelAllTimers();
//     _syncSubscription?.cancel();
//     _positionTrackingSubscription?.cancel();
//     _disposeControllersInBackground();
//   }

//   void _cancelAllTimers() {
//     try {
//       _initializationTimer?.cancel();
//       _initializationTimer = null;

//       _autoPlayTimer?.cancel();
//       _autoPlayTimer = null;

//       _syncSubscription?.cancel();
//       _syncSubscription = null;

//       _positionTrackingSubscription?.cancel();
//       _positionTrackingSubscription = null;

//       _controlsTimer?.cancel();
//       _controlsTimer = null;

//       _seekTimer?.cancel();
//       _seekTimer = null;

//       _seekDebounceTimer?.cancel();
//       _seekDebounceTimer = null;

//       _progressiveSeekTimer?.cancel();
//       _progressiveSeekTimer = null;

//       print('All timers and subscriptions cancelled');
//     } catch (e) {
//       print('Error cancelling timers: $e');
//     }
//   }

//   void _disposeControllersInBackground() {
//     Future.microtask(() async {
//       try {
//         print('Background controller disposal started');

//         if (_playerController != null) {
//           try {
//             await _playerController?.stop().timeout(Duration(seconds: 2));
//             print('Video controller stopped');
//           } catch (e) {
//             print('Video controller stop timeout/error: $e');
//           }
//         }

//         if (_audioController != null) {
//           try {
//             await _audioController?.stop().timeout(Duration(seconds: 2));
//             print('Audio controller stopped');
//           } catch (e) {
//             print('Audio controller stop timeout/error: $e');
//           }
//         }

//         await Future.delayed(Duration(milliseconds: 500));

//         if (_playerController != null) {
//           try {
//             await _playerController?.dispose().timeout(Duration(seconds: 3));
//             print('Video controller disposed');
//           } catch (e) {
//             print('Video controller dispose timeout/error: $e');
//           }
//           _playerController = null;
//         }

//         if (_audioController != null) {
//           try {
//             await _audioController?.dispose().timeout(Duration(seconds: 3));
//             print('Audio controller disposed');
//           } catch (e) {
//             print('Audio controller dispose timeout/error: $e');
//           }
//           _audioController = null;
//         }

//         try {
//           _youtubeExplode.close();
//           print('YoutubeExplode closed');
//         } catch (e) {
//           print('Error closing YoutubeExplode: $e');
//         }

//         _isDisposed = true;
//         print('Background disposal completed');
//       } catch (e) {
//         print('Background disposal error: $e');
//         _playerController = null;
//         _audioController = null;
//         _isDisposed = true;
//       }
//     });
//   }

//   void _setupPositionTracking() {
//     if (_playerController == null || _isDisposed || _isDisposing || !mounted)
//       return;

//     _positionTrackingSubscription?.cancel();
//     print('🎬 Setting up position tracking...');

//     Timer(Duration(seconds: 1), () {
//       if (mounted &&
//           _isInitialized &&
//           _playerController != null &&
//           !_isDisposed &&
//           !_isDisposing) {
//         print('📍 Starting position tracking...');

//         _positionTrackingSubscription =
//             Stream.periodic(Duration(milliseconds: 1000)).listen((_) async {
//           if (mounted &&
//               _isInitialized &&
//               _playerController != null &&
//               !_isDisposed &&
//               !_isDisposing &&
//               !_isSeeking) {
//             await _updatePosition();
//           }
//         });
//       }
//     });
//   }

//   Future<void> _updatePosition() async {
//     try {
//       final videoInitialized = _playerController?.value.isInitialized ?? false;
//       if (!videoInitialized) return;

//       final currentPos =
//           await _playerController?.getPosition() ?? Duration.zero;
//       final totalDur = await _playerController?.getDuration() ?? Duration.zero;

//       // Check if we're 3 seconds before end and not already triggered
//       if (!_earlyPauseTriggered &&
//           totalDur.inSeconds > 6 &&
//           currentPos.inSeconds >= totalDur.inSeconds - 3) {
//         _earlyPauseTriggered = true;
//         _pauseBoth();
//         print('⏸️ Auto-paused 3 seconds before end');
//       }

//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _currentPosition = currentPos;
//           _totalDuration = totalDur;
//         });
//       }
//     } catch (e) {
//       print('Position update error: $e');
//     }
//   }

//   void _createControllers() {
//     if (_videoStreamUrl == null || !mounted || _isDisposed || _isDisposing)
//       return;

//     try {
//       print('Creating controllers with enhanced user agent...');
//       print(
//           'Current user agent: ${_getCurrentUserAgentDynamic().substring(0, 60)}...');

//       _playerController = VlcPlayerController.network(
//         _videoStreamUrl!,
//         hwAcc: HwAcc.auto,
//         autoPlay: false,
//         autoInitialize: true,
//         options: VlcPlayerOptions(
//           advanced: VlcAdvancedOptions([
//             VlcAdvancedOptions.networkCaching(5000),
//             VlcAdvancedOptions.liveCaching(5000),
//           ]),
//           audio: VlcAudioOptions([
//             '--aout=any',
//           ]),
//           video: VlcVideoOptions([
//             '--avcodec-hw=any',
//           ]),
//           http: VlcHttpOptions([
//             '--http-user-agent=${_getCurrentUserAgentDynamic()}',
//             '--http-referrer=https://www.youtube.com/',
//           ]),
//           subtitle: VlcSubtitleOptions([]),
//           rtp: VlcRtpOptions([]),
//         ),
//       );

//       print('Video controller created successfully');

//       if (_audioStreamUrl != null && !_isDisposed && !_isDisposing) {
//         print('Creating separate audio controller for high quality audio...');
//         _audioController = VlcPlayerController.network(
//           _audioStreamUrl!,
//           hwAcc: HwAcc.auto,
//           autoPlay: false,
//           autoInitialize: true,
//           options: VlcPlayerOptions(
//             advanced: VlcAdvancedOptions([
//               VlcAdvancedOptions.networkCaching(5000),
//               VlcAdvancedOptions.liveCaching(5000),
//             ]),
//             audio: VlcAudioOptions([
//               '--aout=any',
//             ]),
//             video: VlcVideoOptions([
//               '--no-video',
//             ]),
//             http: VlcHttpOptions([
//               '--http-user-agent=${_getCurrentUserAgentDynamic()}',
//               '--http-referrer=https://www.youtube.com/',
//             ]),
//             subtitle: VlcSubtitleOptions([]),
//             rtp: VlcRtpOptions([]),
//           ),
//         );
//         print('Audio controller created successfully');
//         _useDualStream = true;
//       }
//     } catch (e) {
//       print('Error creating controllers: $e');
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage = 'Failed to create video players: $e';
//         });
//       }
//     }
//   }

//   Future<void> _waitForAutoInitialization() async {
//     if (!mounted || _playerController == null || _isDisposed || _isDisposing) {
//       print(
//           'Cannot wait for initialization: widget not mounted or controller null');
//       return;
//     }

//     try {
//       print('Waiting for auto-initialization of controllers...');

//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _isInitializing = true;
//           _errorMessage = null;
//         });
//       }

//       int attempts = 0;
//       const maxAttempts = 30;

//       while (attempts < maxAttempts &&
//           mounted &&
//           _playerController != null &&
//           !_isDisposed &&
//           !_isDisposing) {
//         final videoInitialized =
//             _playerController?.value.isInitialized ?? false;
//         final audioInitialized = _audioController?.value.isInitialized ?? true;

//         print(
//             'Auto-initialization check $attempts: video=$videoInitialized, audio=$audioInitialized');

//         if (videoInitialized && audioInitialized) {
//           print('Controllers auto-initialized successfully');
//           break;
//         }

//         await Future.delayed(Duration(seconds: 1));
//         attempts++;

//         if (!mounted || _isDisposed || _isDisposing) {
//           print('Widget disposed during initialization, stopping...');
//           return;
//         }
//       }

//       if (mounted &&
//           _playerController != null &&
//           !_isDisposed &&
//           !_isDisposing) {
//         final videoInitialized =
//             _playerController?.value.isInitialized ?? false;
//         final audioInitialized = _audioController?.value.isInitialized ?? true;

//         if (videoInitialized && audioInitialized) {
//           if (mounted && !_isDisposed && !_isDisposing) {
//             setState(() {
//               _isInitialized = true;
//               _isInitializing = false;
//             });
//           }

//           print(
//               'Controllers ready for playback (dual stream: $_useDualStream)');
//           _setupSyncListeners();
//           _setupPositionTracking();

//           _autoPlayTimer = Timer(Duration(milliseconds: 1500), () {
//             if (mounted && _isInitialized && !_isDisposed && !_isDisposing) {
//               print('Starting auto-play...');
//               _playBoth();
//             }
//           });
//         } else {
//           throw Exception('Controllers failed to auto-initialize');
//         }
//       }
//     } catch (e) {
//       print('Auto-initialization wait error: $e');
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage = 'Failed to initialize video players: $e';
//           _isInitializing = false;
//           _isInitialized = false;
//         });
//       }
//     }
//   }

//   // Enhanced sync listeners with audio recovery
//   void _setupSyncListeners() {
//     if (!_isInitialized ||
//         _playerController == null ||
//         !mounted ||
//         _isDisposed ||
//         _isDisposing) {
//       return;
//     }

//     _syncSubscription?.cancel();

//     Timer(Duration(seconds: 3), () {
//       if (mounted &&
//           _isInitialized &&
//           _playerController != null &&
//           !_isDisposed &&
//           !_isDisposing) {
//         _syncSubscription =
//             Stream.periodic(Duration(seconds: 1)).listen((_) async {
//           if (mounted &&
//               _isInitialized &&
//               _playerController != null &&
//               !_isDisposed &&
//               !_isDisposing &&
//               !_isSeeking) {
//             try {
//               final videoInitialized =
//                   _playerController?.value.isInitialized ?? false;
//               final videoPlaying = _playerController?.value.isPlaying ?? false;

//               if (videoInitialized) {
//                 final videoPosition =
//                     await _playerController?.getPosition() ?? Duration.zero;

//                 if (_useDualStream &&
//                     _audioController != null &&
//                     !_isDisposed &&
//                     !_isDisposing) {
//                   final audioInitialized =
//                       _audioController?.value.isInitialized ?? false;
//                   final audioPlaying =
//                       _audioController?.value.isPlaying ?? false;

//                   if (audioInitialized) {
//                     // Check if audio is out of sync with video
//                     final audioPosition =
//                         await _audioController?.getPosition() ?? Duration.zero;
//                     final diff = (videoPosition.inMilliseconds -
//                             audioPosition.inMilliseconds)
//                         .abs();

//                     if (diff > 1000 && !_isSeeking) {
//                       print(
//                           '🔄 Major audio sync correction: ${diff}ms difference');
//                       await _audioController?.seekTo(videoPosition);
//                     }

//                     // Critical: Check if video is playing but audio is not
//                     if (videoPlaying &&
//                         !audioPlaying &&
//                         _isPlaying &&
//                         !_isSeeking) {
//                       print(
//                           '🚨 Audio stopped but video playing - restarting audio...');
//                       await _audioController?.play();
//                     }

//                     // Also check reverse case
//                     if (!videoPlaying && audioPlaying && !_isPlaying) {
//                       print(
//                           '🚨 Video stopped but audio playing - stopping audio...');
//                       await _audioController?.pause();
//                     }
//                   }
//                 }

//                 // Update current position
//                 if (mounted && !_isDisposed && !_isDisposing) {
//                   setState(() {
//                     _currentPosition = videoPosition;
//                   });
//                 }
//               }
//             } catch (e) {
//               // Silent sync errors but log critical ones
//               if (e.toString().contains('audio')) {
//                 print('⚠️ Audio sync error: $e');
//               }
//             }
//           }
//         });
//       }
//     });
//   }

//   // Enhanced play method with audio verification
//   Future<void> _playBoth() async {
//     if (!_isInitialized ||
//         _playerController == null ||
//         _isDisposed ||
//         _isDisposing) {
//       print('Cannot play: not initialized or controllers are null');
//       return;
//     }

//     _earlyPauseTriggered = false;

//     try {
//       final videoInitialized = _playerController?.value.isInitialized ?? false;

//       if (videoInitialized && !_isDisposed && !_isDisposing) {
//         print('▶️ Playing video controller...');
//         await _playerController?.play();

//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing) {
//           final audioInitialized =
//               _audioController?.value.isInitialized ?? false;
//           if (audioInitialized) {
//             print('🎵 Playing audio controller...');
//             await _audioController?.play();

//             // Verify audio started playing after small delay
//             Timer(Duration(milliseconds: 300), () async {
//               if (_audioController != null && !_isDisposed && _isPlaying) {
//                 final audioPlaying = _audioController?.value.isPlaying ?? false;
//                 if (!audioPlaying) {
//                   print('🔄 Audio failed to start, retrying...');
//                   try {
//                     await _audioController?.play();
//                   } catch (e) {
//                     print('❌ Audio retry failed: $e');
//                   }
//                 }
//               }
//             });
//           }
//         }

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() => _isPlaying = true);
//         }
//         print('✅ Controllers playing (dual stream: $_useDualStream)');
//       } else {
//         print('❌ Controllers not ready');
//       }
//     } catch (e) {
//       print('❌ Error playing: $e');
//     }
//   }

//   Future<void> _pauseBoth() async {
//     if (!_isInitialized ||
//         _playerController == null ||
//         _isDisposed ||
//         _isDisposing) {
//       print('Cannot pause: not initialized or controllers are null');
//       return;
//     }

//     try {
//       final videoInitialized = _playerController?.value.isInitialized ?? false;

//       if (videoInitialized && !_isDisposed && !_isDisposing) {
//         print('Pausing video controller...');
//         await _playerController?.pause();

//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing) {
//           final audioInitialized =
//               _audioController?.value.isInitialized ?? false;
//           if (audioInitialized) {
//             print('Pausing audio controller...');
//             await _audioController?.pause();
//           }
//         }

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() => _isPlaying = false);
//         }
//         print('Controllers paused (dual stream: $_useDualStream)');
//       }
//     } catch (e) {
//       print('Error pausing: $e');
//     }
//   }

//   Future<void> _stopBoth() async {
//     if (!_isInitialized ||
//         _playerController == null ||
//         _isDisposed ||
//         _isDisposing) {
//       print('Cannot stop: not initialized or controllers are null');
//       return;
//     }

//     try {
//       final videoInitialized = _playerController?.value.isInitialized ?? false;

//       if (videoInitialized && !_isDisposed && !_isDisposing) {
//         print('Stopping video controller...');
//         await _playerController?.stop();

//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing) {
//           final audioInitialized =
//               _audioController?.value.isInitialized ?? false;
//           if (audioInitialized) {
//             print('Stopping audio controller...');
//             await _audioController?.stop();
//           }
//         }

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() => _isPlaying = false);
//         }
//         print('Controllers stopped (dual stream: $_useDualStream)');
//       }
//     } catch (e) {
//       print('Error stopping: $e');
//     }
//   }

//   Future<void> _retryWithDifferentUserAgent() async {
//     if (_failedAttempts >= 10 || _isDisposed || _isDisposing) {
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage =
//               'All user agents failed. Video may be restricted or temporarily unavailable.';
//         });
//       }
//       return;
//     }

//     print('🔄 Retrying with enhanced strategy...');
//     _rotateUserAgentIntelligently();

//     if (mounted && !_isDisposed && !_isDisposing) {
//       setState(() {
//         _errorMessage = null;
//         _isInitialized = false;
//         _isInitializing = false;
//         _controllerCreated = false;
//         _useDualStream = false;
//         _videoStreamUrl = null;
//         _audioStreamUrl = null;
//       });
//     }

//     await _disposeControllersSync();
//     await Future.delayed(Duration(seconds: 3));

//     if (mounted && !_isDisposed && !_isDisposing) {
//       // Try enhanced loading first, fallback to legacy if needed
//       if (_sessionId != null) {
//         _loadStreamUrlsEnhanced();
//       } else {
//         _loadStreamUrls();
//       }
//     }
//   }

//   Future<void> _disposeControllersSync() async {
//     print('Disposing controllers synchronously...');

//     _cancelAllTimers();

//     try {
//       if (_playerController != null) {
//         print('Disposing video controller...');
//         await _playerController?.stop().timeout(Duration(seconds: 2));
//         await _playerController?.dispose().timeout(Duration(seconds: 3));
//         _playerController = null;
//         print('Video controller disposed');
//       }
//       if (_audioController != null) {
//         print('Disposing audio controller...');
//         await _audioController?.stop().timeout(Duration(seconds: 2));
//         await _audioController?.dispose().timeout(Duration(seconds: 3));
//         _audioController = null;
//         print('Audio controller disposed');
//       }
//     } catch (e) {
//       print('Error disposing controllers: $e');
//       _playerController = null;
//       _audioController = null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: RawKeyboardListener(
//         focusNode: _focusNode,
//         onKey: _handleKeyEvent,
//         child: GestureDetector(
//           onTap: () {
//             _showControlsTemporarily();
//           },
//           child: _buildPlayerContent(),
//         ),
//       ),
//     );
//   }

//   Widget _buildPlayerContent() {
//     // Video width configuration - 95% of screen width recommended
//     double videoWidthMultiplier = 0.95;
    
//     // Calculate video dimensions
//     double effectiveVideoWidth = screenwdt * videoWidthMultiplier;
//     double effectiveVideoHeight = effectiveVideoWidth * 9 / 16;

//     if (_isDisposed || _isDisposing) {
//       return Container(
//         height: screenhgt,
//         color: Colors.black,
//         child: Center(
//           child: Text(
//             'Player disposed',
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       );
//     }

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
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: _isDisposing
//                       ? null
//                       : () {
//                           if (_isDisposed || _isDisposing) return;
//                           setState(() {
//                             _errorMessage = null;
//                             _isInitialized = false;
//                             _isInitializing = false;
//                             _controllerCreated = false;
//                             _useDualStream = false;
//                             _videoStreamUrl = null;
//                             _audioStreamUrl = null;
//                             _failedAttempts = 0;
//                           });
//                           _disposeControllersSync().then((_) {
//                             if (!_isDisposed && !_isDisposing && mounted) {
//                               if (_sessionId != null) {
//                                 _loadStreamUrlsEnhanced();
//                               } else {
//                                 _loadStreamUrls();
//                               }
//                             }
//                           });
//                         },
//                   child: Text('Retry'),
//                 ),
//                 SizedBox(width: 16),
//                 ElevatedButton(
//                   onPressed: (_isDisposed || _isDisposing)
//                       ? null
//                       : _retryWithDifferentUserAgent,
//                   child: Text('Enhanced Retry'),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Platform: $_currentPlatform | Agent ${_currentUserAgentIndex + 1} | Session: ${_sessionId?.substring(0, 8) ?? "N/A"}',
//               style: TextStyle(fontSize: 10, color: Colors.grey),
//             ),
//             if (_failedAttempts > 0)
//               Text(
//                 'Failed attempts: $_failedAttempts | Geo: $_currentGeoLocation',
//                 style: TextStyle(fontSize: 10, color: Colors.orange),
//               ),
//           ],
//         ),
//       );
//     }

//     if (!_controllerCreated || (_isInitializing && !_isInitialized)) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text(!_controllerCreated
//                 ? 'Loading enhanced video streams...'
//                 : 'Initializing video players...'),
//             SizedBox(height: 8),
//             Text(
//               'Platform: $_currentPlatform | Session: ${_sessionId?.substring(0, 8) ?? "N/A"}',
//               style: TextStyle(fontSize: 10, color: Colors.grey),
//               textAlign: TextAlign.center,
//             ),
//             Text(
//               'Geo: $_currentGeoLocation | Requests: $_requestCounter',
//               style: TextStyle(fontSize: 10, color: Colors.grey),
//               textAlign: TextAlign.center,
//             ),
//             if (_failedAttempts > 0)
//               Padding(
//                 padding: const EdgeInsets.only(top: 4.0),
//                 child: Text(
//                   'Attempts: $_failedAttempts',
//                   style: TextStyle(fontSize: 10, color: Colors.orange),
//                 ),
//               ),
//           ],
//         ),
//       );
//     }

//     if (_controllerCreated &&
//         _playerController == null &&
//         !_isDisposed &&
//         !_isDisposing) {
//       _createControllers();
//     }

//     return Stack(
//       children: [
//         // Video player (main layer) - Now with custom width
//         Center(
//           child: Container(
//             height: effectiveVideoHeight,
//             width: effectiveVideoWidth,
//             decoration: BoxDecoration(
//               color: Colors.black,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 10,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: _playerController != null && !_isDisposed && !_isDisposing
//                   ? VlcPlayer(
//                       controller: _playerController!,
//                       aspectRatio: 16 / 9,
//                       placeholder: const Center(
//                         child: Text(
//                           'Loading Video...',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     )
//                   : Container(
//                       color: Colors.black,
//                       child: const Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                     ),
//             ),
//           ),
//         ),

//         // Audio player (hidden)
//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing)
//           Positioned(
//             top: -1000,
//             child: Container(
//               height: 1,
//               width: 1,
//               child: VlcPlayer(
//                 controller: _audioController!,
//                 aspectRatio: 1,
//               ),
//             ),
//           ),

//         // Controls overlay
//         if (_showControls && _isInitialized) _buildControlsOverlay(),

//         // Video title at top
//         if (_isInitialized)
//           Positioned(
//             top: 20,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.black54,
//                     Colors.transparent,
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 widget.name ?? '',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   shadows: [
//                     Shadow(
//                       offset: Offset(1, 1),
//                       blurRadius: 2,
//                       color: Colors.black87,
//                     ),
//                   ],
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),

//         // Always show progress bar at bottom - Enhanced with Progressive Seek
//         if (_isInitialized && _totalDuration.inSeconds > 0)
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: _buildProgressBarWithProgressive(),
//           ),
//       ],
//     );
//   }

//   Widget _buildControlsOverlay() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: RadialGradient(
//           center: Alignment.center,
//           radius: 1.0,
//           colors: [
//             Colors.black.withOpacity(0.3),
//             Colors.black.withOpacity(0.7),
//           ],
//         ),
//       ),
//       child: Center(
//         child: Container(
//           padding: EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.8),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: Colors.white24, width: 2),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black54,
//                 blurRadius: 20,
//                 spreadRadius: 5,
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Play/Pause button - centered and prominent
//               Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.red.withOpacity(0.2),
//                   border: Border.all(color: Colors.red, width: 2),
//                 ),
//                 child: IconButton(
//                   onPressed: _togglePlayPause,
//                   icon: Icon(
//                     _isPlaying ? Icons.pause : Icons.play_arrow,
//                     color: Colors.white,
//                     size: 48,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Enhanced Progress Bar with Progressive Seek Preview
//   Widget _buildProgressBarWithProgressive() {
//     final progress = _totalDuration.inMilliseconds > 0
//         ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
//         : 0.0;

//     // Calculate preview progress if progressively seeking
//     final previewProgress = _isProgressiveSeeking && _totalDuration.inMilliseconds > 0
//         ? _targetSeekPosition.inMilliseconds / _totalDuration.inMilliseconds
//         : null;

//     return Container(
//       height: 70,
//       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.transparent,
//             Colors.black.withOpacity(0.8),
//           ],
//         ),
//       ),
//       child: Column(
//         children: [
//           // Time indicators with progressive seeking status
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.black54,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   _isProgressiveSeeking
//                       ? _formatDuration(_targetSeekPosition)
//                       : _formatDuration(_currentPosition),
//                   style: TextStyle(
//                     color: _isProgressiveSeeking ? Colors.yellow : Colors.white,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     fontFeatures: [FontFeature.tabularFigures()],
//                   ),
//                 ),
//               ),
              
//               // Show seeking indicator
//               if (_isProgressiveSeeking || _isSeeking)
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: _isSeeking 
//                         ? Colors.orange.withOpacity(0.9)
//                         : Colors.yellow.withOpacity(0.9),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         _isSeeking ? Icons.sync : Icons.fast_forward,
//                         color: Colors.white,
//                         size: 16,
//                       ),
//                       SizedBox(width: 4),
//                       Text(
//                         _isSeeking ? 'Processing...' : 'Seeking...',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
                
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.black54,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   _formatDuration(_totalDuration),
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     fontFeatures: [FontFeature.tabularFigures()],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 8),
          
//           // Enhanced progress bar with preview
//           GestureDetector(
//             onTapDown: (details) {
//               if (_isSeeking || _isProgressiveSeeking) return;

//               final RenderBox box = context.findRenderObject() as RenderBox;
//               final localPosition = box.globalToLocal(details.globalPosition);
//               final width = box.size.width - 40;
//               final tapPosition = localPosition.dx - 20;

//               if (tapPosition >= 0 && tapPosition <= width) {
//                 final seekPercentage = tapPosition / width;
//                 final seekPosition = Duration(
//                   milliseconds: (_totalDuration.inMilliseconds * seekPercentage).round(),
//                 );
//                 _seekBothWithDebounce(seekPosition);
//                 _showControlsTemporarily();
//               }
//             },
//             child: Container(
//               height: 6,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(3),
//                 color: Colors.white.withOpacity(0.3),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 2,
//                     offset: Offset(0, 1),
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(3),
//                 child: Stack(
//                   children: [
//                     // Current progress
//                     LinearProgressIndicator(
//                       value: progress,
//                       backgroundColor: Colors.transparent,
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         _isSeeking ? Colors.orange : Colors.red,
//                       ),
//                     ),
                    
//                     // Preview progress for progressive seeking
//                     if (previewProgress != null)
//                       LinearProgressIndicator(
//                         value: previewProgress,
//                         backgroundColor: Colors.transparent,
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           Colors.yellow.withOpacity(0.8),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
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
//     print('Disposing CustomYoutubePlayer - starting cleanup...');
//     KeepScreenOn.turnOff();
//     WidgetsBinding.instance.removeObserver(this);

//     _focusNode.dispose();

//     _isDisposing = true;
//     _cancelAllTimers();
//     _disposeControllersInBackground();

//     super.dispose();
//     print('Widget disposed successfully');
//   }
// }






// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:youtube_explode_dart/youtube_explode_dart.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:ui';
// import 'dart:async';
// import 'package:keep_screen_on/keep_screen_on.dart';

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
//     with TickerProviderStateMixin, WidgetsBindingObserver {
//   VlcPlayerController? _playerController;
//   VlcPlayerController? _audioController;
//   final YoutubeExplode _youtubeExplode = YoutubeExplode();

//   // Maximum allowed video resolution height (No 2K/4K/8K)
//   static const int MAX_VIDEO_HEIGHT = 1080;

//   bool _isPlaying = false;
//   bool _isInitialized = false;
//   bool _isInitializing = false;
//   bool _controllerCreated = false;
//   bool _useDualStream = false;
//   bool _isDisposed = false;
//   bool _isDisposing = false;
//   bool _showControls = false;
//   bool _isSeeking = false; // Add seeking state to prevent audio overlap
//   Duration _currentPosition = Duration.zero;
//   Duration _totalDuration = Duration.zero;
//   bool _earlyPauseTriggered = false;
//   String? _errorMessage;
//   String? _videoStreamUrl;
//   String? _audioStreamUrl;

//   // Control UI variables
//   Timer? _controlsTimer;
//   Timer? _seekTimer;
//   bool _isSeekingLeft = false;
//   bool _isSeekingRight = false;
//   final FocusNode _focusNode = FocusNode();

//   // Progressive seeking states (from YouTube player code)
//   Timer? _progressiveSeekTimer;
//   int _pendingSeekSeconds = 0;
//   Duration _targetSeekPosition = Duration.zero;
//   bool _isProgressiveSeeking = false;

//   // Stream subscriptions for proper cleanup
//   StreamSubscription? _syncSubscription;
//   StreamSubscription? _positionTrackingSubscription;
//   Timer? _initializationTimer;
//   Timer? _autoPlayTimer;
//   Timer? _seekDebounceTimer; // Add debounce timer for seeking

//   // Enhanced TV User Agents
//   final List<String> _tvUserAgents = [
//     'Mozilla/5.0 (SMART-TV; Linux; Tizen 7.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36',
//     'Mozilla/5.0 (Web0S; Linux/SmartTV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 webOS/6.0',
//     'Mozilla/5.0 (Linux; Android 11; SHIELD Android TV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Safari/537.36',
//     'Mozilla/5.0 (X11; Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chromium/90.0.4430.225 Chrome/90.0.4430.225 Safari/537.36',
//     'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
//     'Mozilla/5.0 (iPad; CPU OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
//     'Mozilla/5.0 (Linux; Android 11; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Mobile Safari/537.36',
//     'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Safari/537.36',
//     'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Safari/537.36',
//   ];

//   int _currentUserAgentIndex = 0;
//   int _failedAttempts = 0;
//   final int _maxFailedAttempts = 3;
//   DateTime? _lastRequestTime;
//   final Duration _requestDelay = Duration(seconds: 2);

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _loadStreamUrls();
//     KeepScreenOn.turnOn();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusNode.requestFocus();
//     });
//   }

//   // Enhanced keyboard handling with progressive seek (from YouTube player code)
//   void _handleKeyEvent(RawKeyEvent event) {
//     if (event is RawKeyDownEvent) {
//       switch (event.logicalKey) {
//         case LogicalKeyboardKey.select:
//         case LogicalKeyboardKey.space:
//         case LogicalKeyboardKey.enter:
//           _togglePlayPause();
//           break;
//         case LogicalKeyboardKey.arrowLeft:
//           // Use progressive seek instead of continuous
//           _seekVideoProgressive(false);
//           _showControlsTemporarily();
//           break;
//         case LogicalKeyboardKey.arrowRight:
//           // Use progressive seek instead of continuous
//           _seekVideoProgressive(true);
//           _showControlsTemporarily();
//           break;
//         case LogicalKeyboardKey.arrowUp:
//         case LogicalKeyboardKey.arrowDown:
//           _showControlsTemporarily();
//           break;
//       }
//     }
//     // Remove key up handling since we're not using continuous seek
//   }



//   // Enhanced Progressive Seeking with ALWAYS auto play
// void _seekVideoProgressive(bool forward) {
//   if (!_isInitialized || 
//       _playerController == null || 
//       _totalDuration.inSeconds <= 24 || 
//       _isDisposed || 
//       _isDisposing) {
//     return;
//   }

//   // Calculate seek amount based on video duration (like YouTube code)
//   final adjustedEndTime = _totalDuration.inSeconds - 12;
//   final seekAmount = (adjustedEndTime / 200).round().clamp(5, 30);

//   // IMMEDIATELY pause both players when seeking starts
//   if (!_isProgressiveSeeking) {
//     print('🔄 Starting progressive seek - pausing players...');
//     _pauseBothImmediate(); // Pause immediately without delay
//   }

//   // Cancel existing timer
//   _progressiveSeekTimer?.cancel();

//   // Accumulate seek amount
//   if (forward) {
//     _pendingSeekSeconds += seekAmount;
//   } else {
//     _pendingSeekSeconds -= seekAmount;
//   }

//   // Calculate target position
//   final currentSeconds = _currentPosition.inSeconds;
//   final targetSeconds = (currentSeconds + _pendingSeekSeconds)
//       .clamp(0, adjustedEndTime);
//   _targetSeekPosition = Duration(seconds: targetSeconds);

//   // Update UI to show seeking state
//   if (mounted && !_isDisposed && !_isDisposing) {
//     setState(() {
//       _isProgressiveSeeking = true;
//     });
//   }

//   // Set timer to execute seek after delay (accumulates multiple presses)
//   // Note: Removed wasPlaying parameter since we always want to auto play
//   _progressiveSeekTimer = Timer(const Duration(milliseconds: 1000), () {
//     _executeProgressiveSeek(true); // Always pass true for auto play
//   });
// }

// void _executeProgressiveSeek(bool wasPlaying) async {
//   if (!_isInitialized || 
//       _playerController == null || 
//       _isDisposed || 
//       _isDisposing || 
//       _pendingSeekSeconds == 0) {
//     return;
//   }

//   final adjustedEndTime = _totalDuration.inSeconds - 12;
//   final currentSeconds = _currentPosition.inSeconds;
//   final newPosition = (currentSeconds + _pendingSeekSeconds)
//       .clamp(0, adjustedEndTime);

//   try {
//     print('🎯 Executing progressive seek to ${newPosition}s...');
    
//     // Ensure both players are paused before seeking
//     await _pauseBothImmediate();
    
//     // Wait a moment for pause to take effect
//     await Future.delayed(Duration(milliseconds: 100));
    
//     // Perform the actual seek
//     await _seekBothControllersOnly(Duration(seconds: newPosition));
    
//     // Wait for seek to complete and sync
//     await Future.delayed(Duration(milliseconds: 300));
    
//     // ALWAYS auto play after seek (regardless of previous state)
//     print('▶️ Auto-playing after progressive seek...');
//     await _playBothAfterSeek();

//   } catch (e) {
//     print('❌ Progressive seek error: $e');
    
//     // Emergency recovery - ALWAYS try to play after seek
//     try {
//       print('🔄 Emergency recovery - forcing auto play...');
//       await _playBothAfterSeek();
//     } catch (recoveryError) {
//       print('❌ Recovery failed: $recoveryError');
//     }
//   } finally {
//     // Reset progressive seek state
//     _pendingSeekSeconds = 0;
//     _targetSeekPosition = Duration.zero;

//     if (mounted && !_isDisposed && !_isDisposing) {
//       setState(() {
//         _isProgressiveSeeking = false;
//       });
//     }
//   }
// }




// // New method: Immediate pause without state checks
// Future<void> _pauseBothImmediate() async {
//   try {
//     final videoInitialized = _playerController?.value.isInitialized ?? false;
    
//     if (videoInitialized && !_isDisposed && !_isDisposing) {
//       await _playerController?.pause();
      
//       if (_useDualStream && _audioController != null) {
//         final audioInitialized = _audioController?.value.isInitialized ?? false;
//         if (audioInitialized) {
//           await _audioController?.pause();
//         }
//       }
      
//       // Update state to reflect pause
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() => _isPlaying = false);
//       }
      
//       print('⏸️ Both players paused immediately');
//     }
//   } catch (e) {
//     print('❌ Error in immediate pause: $e');
//   }
// }

// // New method: Only perform seek without play/pause logic
// Future<void> _seekBothControllersOnly(Duration position) async {
//   try {
//     // Seek video controller first
//     final videoInitialized = _playerController?.value.isInitialized ?? false;
//     if (videoInitialized) {
//       print('🎬 Seeking video controller to ${position.inSeconds}s...');
//       await _playerController?.seekTo(position);
//     }

//     // Seek audio controller with extra sync
//     if (_useDualStream && _audioController != null) {
//       final audioInitialized = _audioController?.value.isInitialized ?? false;
//       if (audioInitialized) {
//         print('🎵 Seeking audio controller to ${position.inSeconds}s...');
//         await _audioController?.seekTo(position);
        
//         // Additional audio sync attempt
//         await Future.delayed(Duration(milliseconds: 50));
//         await _audioController?.seekTo(position);
//       }
//     }

//     // Update position immediately
//     if (mounted && !_isDisposed && !_isDisposing) {
//       setState(() {
//         _currentPosition = position;
//       });
//     }
    
//     print('✅ Seek operation completed');
//   } catch (e) {
//     print('❌ Error in seek controllers: $e');
//     throw e; // Re-throw to handle in caller
//   }
// }

// // New method: Play both after seek with proper sync and GUARANTEED start
// Future<void> _playBothAfterSeek() async {
//   try {
//     final videoInitialized = _playerController?.value.isInitialized ?? false;
    
//     if (videoInitialized && !_isDisposed && !_isDisposing) {
//       print('▶️ Starting video controller...');
//       await _playerController?.play();
      
//       if (_useDualStream && _audioController != null) {
//         final audioInitialized = _audioController?.value.isInitialized ?? false;
//         if (audioInitialized) {
//           // Small delay for video to start first
//           await Future.delayed(Duration(milliseconds: 50));
          
//           print('🎵 Starting audio controller with sync...');
//           await _audioController?.play();
          
//           // Multiple verification attempts to ensure audio starts
//           int verificationAttempts = 0;
//           const maxVerificationAttempts = 3;
          
//           Timer.periodic(Duration(milliseconds: 200), (timer) async {
//             verificationAttempts++;
            
//             if (_audioController == null || _isDisposed || verificationAttempts > maxVerificationAttempts) {
//               timer.cancel();
//               return;
//             }
            
//             final audioPlaying = _audioController?.value.isPlaying ?? false;
//             final videoPlaying = _playerController?.value.isPlaying ?? false;
            
//             if (!audioPlaying && videoPlaying) {
//               print('🔄 Audio verification attempt $verificationAttempts - restarting audio...');
//               try {
//                 await _audioController?.play();
//               } catch (e) {
//                 print('❌ Audio restart attempt $verificationAttempts failed: $e');
//               }
//             } else if (audioPlaying) {
//               print('✅ Audio verified playing after seek (attempt $verificationAttempts)');
//               timer.cancel();
//             }
            
//             if (verificationAttempts >= maxVerificationAttempts) {
//               print('⚠️ Max audio verification attempts reached');
//               timer.cancel();
//             }
//           });
//         }
//       }
      
//       // Update state to reflect playing
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() => _isPlaying = true);
//       }
      
//       // Additional verification for video playback
//       Timer(Duration(milliseconds: 500), () async {
//         if (_playerController != null && !_isDisposed) {
//           final videoStillPlaying = _playerController?.value.isPlaying ?? false;
//           if (!videoStillPlaying) {
//             print('🔄 Video stopped unexpectedly, restarting...');
//             try {
//               await _playerController?.play();
//               if (mounted && !_isDisposed && !_isDisposing) {
//                 setState(() => _isPlaying = true);
//               }
//             } catch (e) {
//               print('❌ Video restart failed: $e');
//             }
//           } else {
//             print('✅ Video confirmed playing after seek');
//           }
//         }
//       });
      
//       print('✅ Both players resumed after seek - AUTO PLAY GUARANTEED');
//     }
//   } catch (e) {
//     print('❌ Error resuming after seek: $e');
    
//     // CRITICAL: Emergency auto-play attempt
//     try {
//       print('🚨 EMERGENCY AUTO-PLAY ATTEMPT...');
//       if (_playerController != null && !_isDisposed) {
//         await _playerController?.play();
//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() => _isPlaying = true);
//         }
//       }
//       if (_useDualStream && _audioController != null && !_isDisposed) {
//         await _audioController?.play();
//       }
//       print('🆘 Emergency auto-play completed');
//     } catch (emergencyError) {
//       print('💀 Emergency auto-play also failed: $emergencyError');
//     }
    
//     throw e; // Re-throw to handle in caller
//   }
// }

// // Updated regular seek method with ALWAYS auto play
// Future<void> _seekBothWithDebounce(Duration position) async {
//   if (!_isInitialized ||
//       _playerController == null ||
//       _isDisposed ||
//       _isDisposing ||
//       _isSeeking) {
//     return;
//   }

//   _isSeeking = true;
//   bool wasPlaying = _isPlaying;

//   try {
//     print('🎯 Regular seek to ${position.inSeconds}s (was playing: $wasPlaying)...');

//     // ALWAYS pause first to prevent audio issues
//     await _pauseBothImmediate();

//     // Wait for pause to take effect
//     await Future.delayed(Duration(milliseconds: 150));

//     // Perform the seek
//     await _seekBothControllersOnly(position);

//     // Wait for seek to complete
//     await Future.delayed(Duration(milliseconds: 200));

//     // ALWAYS auto play after seek (regardless of previous state)
//     print('▶️ Auto-playing after regular seek...');
//     await _playBothAfterSeek();

//     print('✅ Regular seek completed - Video auto-playing');
    
//   } catch (e) {
//     print('❌ Error in regular seek: $e');

//     // Emergency recovery - ALWAYS try to play
//     try {
//       print('🔄 Emergency recovery - forcing auto play...');
//       await _playBothAfterSeek();
//     } catch (recoveryError) {
//       print('❌ Emergency recovery failed: $recoveryError');
//     }
//   } finally {
//     // Reset seeking state after a delay
//     Timer(Duration(milliseconds: 400), () {
//       _isSeeking = false;
//     });
//   }
// }



//   // // Enhanced Progressive Seeking (from YouTube player code)
//   // void _seekVideoProgressive(bool forward) {
//   //   if (!_isInitialized || 
//   //       _playerController == null || 
//   //       _totalDuration.inSeconds <= 24 || 
//   //       _isDisposed || 
//   //       _isDisposing) {
//   //     return;
//   //   }

//   //   // Calculate seek amount based on video duration (like YouTube code)
//   //   final adjustedEndTime = _totalDuration.inSeconds - 12;
//   //   final seekAmount = (adjustedEndTime / 200).round().clamp(5, 30);

//   //   // Cancel existing timer
//   //   _progressiveSeekTimer?.cancel();

//   //   // Accumulate seek amount
//   //   if (forward) {
//   //     _pendingSeekSeconds += seekAmount;
//   //   } else {
//   //     _pendingSeekSeconds -= seekAmount;
//   //   }

//   //   // Calculate target position
//   //   final currentSeconds = _currentPosition.inSeconds;
//   //   final targetSeconds = (currentSeconds + _pendingSeekSeconds)
//   //       .clamp(0, adjustedEndTime);
//   //   _targetSeekPosition = Duration(seconds: targetSeconds);

//   //   // Update UI to show seeking state
//   //   if (mounted && !_isDisposed && !_isDisposing) {
//   //     setState(() {
//   //       _isProgressiveSeeking = true;
//   //     });
//   //   }

//   //   // Set timer to execute seek after delay (accumulates multiple presses)
//   //   _progressiveSeekTimer = Timer(const Duration(milliseconds: 1000), () {
//   //     _executeProgressiveSeek();
//   //   });
//   // }

//   // void _executeProgressiveSeek() async {
//   //   if (!_isInitialized || 
//   //       _playerController == null || 
//   //       _isDisposed || 
//   //       _isDisposing || 
//   //       _pendingSeekSeconds == 0) {
//   //     return;
//   //   }

//   //   final adjustedEndTime = _totalDuration.inSeconds - 12;
//   //   final currentSeconds = _currentPosition.inSeconds;
//   //   final newPosition = (currentSeconds + _pendingSeekSeconds)
//   //       .clamp(0, adjustedEndTime);

//   //   try {
//   //     // Use existing VLC seek method
//   //     await _seekBothWithDebounce(Duration(seconds: newPosition));

//   //   } catch (e) {
//   //     print('Progressive seek error: $e');
//   //   } finally {
//   //     // Reset progressive seek state
//   //     _pendingSeekSeconds = 0;
//   //     _targetSeekPosition = Duration.zero;

//   //     if (mounted && !_isDisposed && !_isDisposing) {
//   //       setState(() {
//   //         _isProgressiveSeeking = false;
//   //       });
//   //     }
//   //   }
//   // }

//   void _showControlsTemporarily() {
//     setState(() {
//       _showControls = true;
//     });

//     _controlsTimer?.cancel();
//     _controlsTimer = Timer(Duration(seconds: 5), () {
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _showControls = false;
//         });
//       }
//     });
//   }

//   void _togglePlayPause() {
//     if (_isPlaying) {
//       _pauseBoth();
//     } else {
//       _playBoth();
//     }
//     _showControlsTemporarily();
//   }

//   // // Fixed seeking with debouncing to prevent audio overlap
//   // void _seekBackwardDebounced() {
//   //   if (_isSeeking || _isProgressiveSeeking) return;

//   //   _seekDebounceTimer?.cancel();
//   //   _seekDebounceTimer = Timer(Duration(milliseconds: 100), () {
//   //     final newPosition = _currentPosition - Duration(seconds: 10);
//   //     final targetPosition =
//   //         newPosition < Duration.zero ? Duration.zero : newPosition;
//   //     _seekBothWithDebounce(targetPosition);
//   //   });
//   // }

//   // void _seekForwardDebounced() {
//   //   if (_isSeeking || _isProgressiveSeeking) return;

//   //   _seekDebounceTimer?.cancel();
//   //   _seekDebounceTimer = Timer(Duration(milliseconds: 100), () {
//   //     final newPosition = _currentPosition + Duration(seconds: 10);
//   //     final targetPosition =
//   //         newPosition > _totalDuration ? _totalDuration : newPosition;
//   //     _seekBothWithDebounce(targetPosition);
//   //   });
//   // }

//   // // Fixed seek method with proper audio restoration
//   // Future<void> _seekBothWithDebounce(Duration position) async {
//   //   if (!_isInitialized ||
//   //       _playerController == null ||
//   //       _isDisposed ||
//   //       _isDisposing ||
//   //       _isSeeking) {
//   //     return;
//   //   }

//   //   _isSeeking = true;
//   //   bool wasPlaying = _isPlaying;
//   //   _earlyPauseTriggered = false;

//   //   try {
//   //     print(
//   //         '🎯 Seeking to ${position.inSeconds}s (was playing: $wasPlaying)...');

//   //     // Always pause first to prevent audio issues
//   //     await _playerController?.pause();
//   //     if (_useDualStream && _audioController != null) {
//   //       await _audioController?.pause();
//   //     }

//   //     // Wait for pause to take effect
//   //     await Future.delayed(Duration(milliseconds: 100));

//   //     // Seek video controller first
//   //     final videoInitialized = _playerController?.value.isInitialized ?? false;
//   //     if (videoInitialized) {
//   //       print('🎬 Seeking video controller...');
//   //       await _playerController?.seekTo(position);
//   //     }

//   //     // Seek audio controller with extra sync
//   //     if (_useDualStream && _audioController != null) {
//   //       final audioInitialized = _audioController?.value.isInitialized ?? false;
//   //       if (audioInitialized) {
//   //         print('🎵 Seeking audio controller...');
//   //         await _audioController?.seekTo(position);

//   //         // Additional audio sync attempt
//   //         await Future.delayed(Duration(milliseconds: 50));
//   //         await _audioController?.seekTo(position);
//   //       }
//   //     }

//   //     // Wait for seek to complete
//   //     await Future.delayed(Duration(milliseconds: 200));

//   //     // Force resume playback if it was playing before
//   //     if (wasPlaying) {
//   //       print('▶️ Resuming playback after seek...');

//   //       // Start video first
//   //       await _playerController?.play();

//   //       // Then start audio with slight delay for sync
//   //       if (_useDualStream && _audioController != null) {
//   //         await Future.delayed(Duration(milliseconds: 50));
//   //         await _audioController?.play();

//   //         // Verify audio is actually playing
//   //         Timer(Duration(milliseconds: 500), () async {
//   //           if (_audioController != null && wasPlaying && !_isDisposed) {
//   //             final audioPlaying = _audioController?.value.isPlaying ?? false;
//   //             if (!audioPlaying) {
//   //               print('🔄 Audio not playing, forcing restart...');
//   //               await _audioController?.play();
//   //             }
//   //           }
//   //         });
//   //       }

//   //       // Update playing state
//   //       if (mounted && !_isDisposed && !_isDisposing) {
//   //         setState(() {
//   //           _isPlaying = true;
//   //         });
//   //       }
//   //     }

//   //     // Update position immediately
//   //     if (mounted && !_isDisposed && !_isDisposing) {
//   //       setState(() {
//   //         _currentPosition = position;
//   //       });
//   //     }

//   //     print(
//   //         '✅ Seek completed - Audio should be ${wasPlaying ? "playing" : "paused"}');
//   //   } catch (e) {
//   //     print('❌ Error seeking: $e');

//   //     // Emergency audio recovery
//   //     if (wasPlaying && _useDualStream && _audioController != null) {
//   //       try {
//   //         await _audioController?.play();
//   //       } catch (recoveryError) {
//   //         print('❌ Audio recovery failed: $recoveryError');
//   //       }
//   //     }
//   //   } finally {
//   //     // Reset seeking state
//   //     Timer(Duration(milliseconds: 300), () {
//   //       _isSeeking = false;
//   //     });
//   //   }
//   // }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);

//     switch (state) {
//       case AppLifecycleState.paused:
//       case AppLifecycleState.detached:
//         print('App paused/detached - stopping players safely');
//         _stopPlayersForBackground();
//         break;
//       case AppLifecycleState.resumed:
//         print('App resumed');
//         break;
//       default:
//         break;
//     }
//   }

//   void _stopPlayersForBackground() {
//     if (_isDisposed || _isDisposing) return;

//     try {
//       _playerController?.pause();
//       _audioController?.pause();
//       setState(() {
//         _isPlaying = false;
//       });
//     } catch (e) {
//       print('Error stopping players for background: $e');
//     }
//   }

//   Future<bool> _onWillPop() async {
//     print('Back button pressed - initiating safe disposal');

//     if (_isDisposing || _isDisposed) {
//       return true;
//     }

//     if (!Navigator.canPop(context)) {
//       print('⚠️ This is root page - preventing app close');
//       _showExitDialog();
//       return false;
//     }

//     _startSafeDisposal();
//     return true;
//   }

//   void _showExitDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Exit App?'),
//           content: Text('Do you want to exit the application?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Exit'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _startSafeDisposal() {
//     if (_isDisposing || _isDisposed) return;

//     print('Starting safe disposal process...');
//     _isDisposing = true;

//     _cancelAllTimers();
//     _syncSubscription?.cancel();
//     _positionTrackingSubscription?.cancel();
//     _disposeControllersInBackground();
//   }

//   void _cancelAllTimers() {
//     try {
//       _initializationTimer?.cancel();
//       _initializationTimer = null;

//       _autoPlayTimer?.cancel();
//       _autoPlayTimer = null;

//       _syncSubscription?.cancel();
//       _syncSubscription = null;

//       _positionTrackingSubscription?.cancel();
//       _positionTrackingSubscription = null;

//       _controlsTimer?.cancel();
//       _controlsTimer = null;

//       _seekTimer?.cancel();
//       _seekTimer = null;

//       _seekDebounceTimer?.cancel();
//       _seekDebounceTimer = null;

//       _progressiveSeekTimer?.cancel(); // Cancel progressive seek timer
//       _progressiveSeekTimer = null;

//       print('All timers and subscriptions cancelled');
//     } catch (e) {
//       print('Error cancelling timers: $e');
//     }
//   }

//   void _disposeControllersInBackground() {
//     Future.microtask(() async {
//       try {
//         print('Background controller disposal started');

//         if (_playerController != null) {
//           try {
//             await _playerController?.stop().timeout(Duration(seconds: 2));
//             print('Video controller stopped');
//           } catch (e) {
//             print('Video controller stop timeout/error: $e');
//           }
//         }

//         if (_audioController != null) {
//           try {
//             await _audioController?.stop().timeout(Duration(seconds: 2));
//             print('Audio controller stopped');
//           } catch (e) {
//             print('Audio controller stop timeout/error: $e');
//           }
//         }

//         await Future.delayed(Duration(milliseconds: 500));

//         if (_playerController != null) {
//           try {
//             await _playerController?.dispose().timeout(Duration(seconds: 3));
//             print('Video controller disposed');
//           } catch (e) {
//             print('Video controller dispose timeout/error: $e');
//           }
//           _playerController = null;
//         }

//         if (_audioController != null) {
//           try {
//             await _audioController?.dispose().timeout(Duration(seconds: 3));
//             print('Audio controller disposed');
//           } catch (e) {
//             print('Audio controller dispose timeout/error: $e');
//           }
//           _audioController = null;
//         }

//         try {
//           _youtubeExplode.close();
//           print('YoutubeExplode closed');
//         } catch (e) {
//           print('Error closing YoutubeExplode: $e');
//         }

//         _isDisposed = true;
//         print('Background disposal completed');
//       } catch (e) {
//         print('Background disposal error: $e');
//         _playerController = null;
//         _audioController = null;
//         _isDisposed = true;
//       }
//     });
//   }

//   void _setupPositionTracking() {
//     if (_playerController == null || _isDisposed || _isDisposing || !mounted)
//       return;

//     _positionTrackingSubscription?.cancel();
//     print('🎬 Setting up position tracking...');

//     Timer(Duration(seconds: 1), () {
//       if (mounted &&
//           _isInitialized &&
//           _playerController != null &&
//           !_isDisposed &&
//           !_isDisposing) {
//         print('📍 Starting position tracking...');

//         _positionTrackingSubscription =
//             Stream.periodic(Duration(milliseconds: 1000)).listen((_) async {
//           if (mounted &&
//               _isInitialized &&
//               _playerController != null &&
//               !_isDisposed &&
//               !_isDisposing &&
//               !_isSeeking) {
//             // Don't update position while seeking

//             await _updatePosition();
//           }
//         });
//       }
//     });
//   }

//   Future<void> _updatePosition() async {
//     try {
//       final videoInitialized = _playerController?.value.isInitialized ?? false;
//       if (!videoInitialized) return;

//       final currentPos =
//           await _playerController?.getPosition() ?? Duration.zero;
//       final totalDur = await _playerController?.getDuration() ?? Duration.zero;

//       // Check if we're 6 seconds before end and not already triggered
//       if (!_earlyPauseTriggered &&
//           totalDur.inSeconds > 6 &&
//           currentPos.inSeconds >= totalDur.inSeconds - 3) {
//         _earlyPauseTriggered = true;
//         _pauseBoth();
//         print('⏸️ Auto-paused 6 seconds before end');
//       }

//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _currentPosition = currentPos;
//           _totalDuration = totalDur;
//         });
//       }
//     } catch (e) {
//       print('Position update error: $e');
//     }
//   }

//   String _getCurrentUserAgent() {
//     return _tvUserAgents[_currentUserAgentIndex % _tvUserAgents.length];
//   }

//   void _rotateUserAgent() {
//     _currentUserAgentIndex =
//         (_currentUserAgentIndex + 1) % _tvUserAgents.length;
//     _failedAttempts++;

//     print(
//         'Rotating to user agent ${_currentUserAgentIndex + 1}/${_tvUserAgents.length}: ${_getCurrentUserAgent().substring(0, 60)}...');
//     print('Failed attempts so far: $_failedAttempts');

//     if (_failedAttempts > _maxFailedAttempts) {
//       print('Too many failed attempts, adding extra delay...');
//     }
//   }

//   Future<void> _addRequestDelay() async {
//     if (_isDisposed || _isDisposing) return;

//     final now = DateTime.now();
//     if (_lastRequestTime != null) {
//       final timeSinceLastRequest = now.difference(_lastRequestTime!);
//       if (timeSinceLastRequest < _requestDelay) {
//         final delayNeeded = _requestDelay - timeSinceLastRequest;
//         print(
//             'Rate limiting: waiting ${delayNeeded.inMilliseconds}ms before next request');
//         await Future.delayed(delayNeeded);
//       }
//     }
//     _lastRequestTime = now;

//     if (_failedAttempts > _maxFailedAttempts) {
//       final extraDelay = Duration(seconds: _failedAttempts * 2);
//       print('Extra delay due to failures: ${extraDelay.inSeconds}s');
//       await Future.delayed(extraDelay);
//     }
//   }

//   // FIXED: Stream loading with strict 1080p limit
//   Future<void> _loadStreamUrls() async {
//     if (_isInitializing || _isDisposed || _isDisposing) return;

//     if (!mounted) return;

//     setState(() {
//       _earlyPauseTriggered = false;
//       _isInitializing = true;
//       _errorMessage = null;
//     });

//     try {
//       if (widget.videoUrl.isEmpty) {
//         throw Exception('Video URL is empty');
//       }

//       print('🎬 Loading streams for: ${widget.videoUrl}');
//       print('🚫 BLOCKING: 2K (1440p), 4K (2160p), 8K (4320p) quality');
//       print('✅ ALLOWING: Maximum ${MAX_VIDEO_HEIGHT}p quality');
//       print(
//           '🌐 Using user agent: ${_getCurrentUserAgent().substring(0, 60)}...');

//       await _addRequestDelay();

//       if (_isDisposed || _isDisposing || !mounted) return;

//       StreamManifest? manifest;
//       int retryCount = 0;
//       const maxRetries = 3;

//       while (retryCount < maxRetries &&
//           manifest == null &&
//           !_isDisposed &&
//           !_isDisposing &&
//           mounted) {
//         try {
//           print('🔄 Attempt ${retryCount + 1}/$maxRetries to get manifest...');
//           manifest = await _youtubeExplode.videos.streamsClient
//               .getManifest(widget.videoUrl);

//           _failedAttempts = 0;
//           print('✅ Manifest loaded successfully on attempt ${retryCount + 1}');
//           break;
//         } catch (manifestError) {
//           retryCount++;
//           print('❌ Manifest error on attempt $retryCount: $manifestError');

//           if (retryCount < maxRetries &&
//               !_isDisposed &&
//               !_isDisposing &&
//               mounted) {
//             _rotateUserAgent();
//             print('🔄 Retrying with different user agent...');
//             await Future.delayed(Duration(seconds: retryCount * 2));
//             if (_isDisposed || _isDisposing || !mounted) return;
//           } else {
//             throw Exception(
//                 'Failed to get video manifest after $maxRetries attempts: $manifestError');
//           }
//         }
//       }

//       if (_isDisposed || _isDisposing || !mounted) return;

//       if (manifest == null) {
//         throw Exception('Could not get video manifest after all retries');
//       }

//       // First try muxed streams with 1080p limit
//       var muxedStreams = manifest.muxed;
//       print('📺 Found ${muxedStreams?.length ?? 0} muxed streams');

//       if (muxedStreams != null && muxedStreams.isNotEmpty) {
//         // Debug: Print all available muxed streams with blocked indicator
//         print('🔍 Available muxed streams:');
//         for (var stream in muxedStreams) {
//           String blockedIndicator =
//               stream.videoResolution.height > MAX_VIDEO_HEIGHT
//                   ? ' 🚫 BLOCKED'
//                   : ' ✅ ALLOWED';
//           print(
//               '   - ${stream.tag}: ${stream.videoResolution.height}p${blockedIndicator}');
//         }

//         // STRICT Filter: Block 2K/4K/8K - Only allow up to 1080p
//         var filteredMuxedStreams = muxedStreams.where((stream) {
//           bool isAllowed = stream.videoResolution.height <= MAX_VIDEO_HEIGHT;
//           if (!isAllowed) {
//             print(
//                 '🚫 BLOCKING ${stream.tag}: ${stream.videoResolution.height}p (>${MAX_VIDEO_HEIGHT}p)');
//           }
//           return isAllowed;
//         }).toList();

//         print(
//             '📏 Filtered muxed streams (≤${MAX_VIDEO_HEIGHT}p): ${filteredMuxedStreams.length}');
//         print(
//             '🚫 Blocked high quality streams: ${muxedStreams.length - filteredMuxedStreams.length}');

//         if (filteredMuxedStreams.isNotEmpty) {
//           print('✅ Using filtered muxed stream approach');
//           await _handleFilteredMuxedStreams(filteredMuxedStreams);
//           return;
//         } else {
//           print(
//               '⚠️ No muxed streams found ≤${MAX_VIDEO_HEIGHT}p (All were 2K/4K/8K), trying separate streams...');
//         }
//       }

//       // Use separate video and audio streams with 1080p limit
//       print('🎥 Using separate video and audio streams approach...');

//       var videoOnlyStreams = manifest.videoOnly;
//       print('🎬 Found ${videoOnlyStreams?.length ?? 0} video-only streams');

//       VideoOnlyStreamInfo? bestVideoStream;
//       if (videoOnlyStreams != null && videoOnlyStreams.isNotEmpty) {
//         // Debug: Print all available video streams with blocked indicator
//         print('🔍 Available video-only streams:');
//         for (var stream in videoOnlyStreams) {
//           String blockedIndicator =
//               stream.videoResolution.height > MAX_VIDEO_HEIGHT
//                   ? ' 🚫 BLOCKED'
//                   : ' ✅ ALLOWED';
//           print(
//               '   - ${stream.tag}: ${stream.videoResolution.height}p${blockedIndicator}');
//         }

//         // STRICT Filter: Block 2K/4K/8K - Only allow up to 1080p
//         var filteredVideoStreams = videoOnlyStreams.where((stream) {
//           bool isAllowed = stream.videoResolution.height <= MAX_VIDEO_HEIGHT;
//           if (!isAllowed) {
//             print(
//                 '🚫 BLOCKING ${stream.tag}: ${stream.videoResolution.height}p (>${MAX_VIDEO_HEIGHT}p)');
//           }
//           return isAllowed;
//         }).toList();

//         print(
//             '📏 Filtered video streams (≤${MAX_VIDEO_HEIGHT}p): ${filteredVideoStreams.length}');
//         print(
//             '🚫 Blocked high quality streams: ${videoOnlyStreams.length - filteredVideoStreams.length}');

//         if (filteredVideoStreams.isNotEmpty) {
//           // Sort by quality (highest first within the limit)
//           filteredVideoStreams.sort((a, b) =>
//               b.videoResolution.height.compareTo(a.videoResolution.height));

//           bestVideoStream = filteredVideoStreams.first;
//           print(
//               '✅ Selected video stream: ${bestVideoStream.tag} - ${bestVideoStream.videoResolution.height}p');
//         } else {
//           // If no streams within limit, use the lowest available
//           var sortedVideoStreams = videoOnlyStreams.toList()
//             ..sort((a, b) =>
//                 a.videoResolution.height.compareTo(b.videoResolution.height));
//           bestVideoStream = sortedVideoStreams.first;
//           print(
//               '⚠️ No video streams ≤${MAX_VIDEO_HEIGHT}p found (All were 2K/4K/8K), using lowest available: ${bestVideoStream.videoResolution.height}p');
//         }
//       }

//       var audioOnlyStreams = manifest.audioOnly;
//       print('🎵 Found ${audioOnlyStreams?.length ?? 0} audio-only streams');

//       AudioOnlyStreamInfo? bestAudioStream;
//       if (audioOnlyStreams != null && audioOnlyStreams.isNotEmpty) {
//         var sortedAudioStreams = audioOnlyStreams.toList()
//           ..sort((a, b) =>
//               b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond));
//         bestAudioStream = sortedAudioStreams.first;
//         print(
//             '✅ Selected audio stream: ${bestAudioStream.tag} - ${bestAudioStream.audioCodec} - ${bestAudioStream.bitrate}');
//       }

//       if (bestVideoStream != null && bestAudioStream != null) {
//         String videoUrl = bestVideoStream.url.toString();
//         String audioUrl = bestAudioStream.url.toString();

//         print(
//             '🔗 Video URL loaded (${bestVideoStream.videoResolution.height}p)');
//         print('🔗 Audio URL loaded');

//         _videoStreamUrl = videoUrl;
//         _audioStreamUrl = audioUrl;

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() {
//             _controllerCreated = true;
//             _isInitializing = false;
//           });

//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (!_isDisposed && !_isDisposing && mounted) {
//               _initializationTimer = Timer(Duration(milliseconds: 3000), () {
//                 if (mounted && !_isDisposed && !_isDisposing) {
//                   _waitForAutoInitialization();
//                 }
//               });
//             }
//           });
//         }
//       } else {
//         String missingStreams = '';
//         if (bestVideoStream == null) missingStreams += 'video ';
//         if (bestAudioStream == null) missingStreams += 'audio ';

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() {
//             _errorMessage =
//                 'No $missingStreams streams found for this video. This video might be restricted or unavailable.';
//             _isInitializing = false;
//           });
//         }
//       }
//     } catch (e) {
//       print('❌ Error loading streams: $e');

//       if (_isDisposed || _isDisposing || !mounted) return;

//       String errorMessage = 'Error loading video: ${e.toString()}';

//       if (e.toString().contains('VideoUnavailableException')) {
//         errorMessage = 'This video is unavailable or private';
//       } else if (e.toString().contains('VideoRequiresPurchaseException')) {
//         errorMessage = 'This video requires purchase';
//       } else if (e.toString().contains('SocketException')) {
//         errorMessage = 'Network error: Please check your internet connection';
//       } else if (e.toString().contains('TimeoutException')) {
//         errorMessage = 'Request timed out: Please try again';
//       } else if (e.toString().contains('403') ||
//           e.toString().contains('Forbidden')) {
//         errorMessage = 'Access blocked: Trying different user agent...';
//         if (_failedAttempts < _tvUserAgents.length) {
//           Timer(Duration(seconds: 3), () {
//             if (mounted && !_isDisposed && !_isDisposing) {
//               _retryWithDifferentUserAgent();
//             }
//           });
//         }
//       } else if (e.toString().contains('429') ||
//           e.toString().contains('rate')) {
//         errorMessage = 'Rate limited: Please wait before trying again...';
//       }

//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage = errorMessage;
//           _isInitializing = false;
//         });
//       }
//     }
//   }

//   // Handle filtered muxed streams
//   Future<void> _handleFilteredMuxedStreams(
//       List<MuxedStreamInfo> filteredStreams) async {
//     if (_isDisposed || _isDisposing || !mounted) return;

//     // Sort by quality (highest first within the limit)
//     var sortedStreams = filteredStreams.toList()
//       ..sort((a, b) {
//         int qualityCompare =
//             b.videoResolution.height.compareTo(a.videoResolution.height);
//         if (qualityCompare != 0) return qualityCompare;
//         return b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond);
//       });

//     MuxedStreamInfo bestStream = sortedStreams.first;
//     String streamUrl = bestStream.url.toString();

//     print(
//         '✅ Selected muxed stream: ${bestStream.tag} - ${bestStream.videoResolution.height}p - Bitrate: ${bestStream.bitrate}');
//     print(
//         '🚫 CONFIRMED: No 2K/4K/8K quality - Maximum ${MAX_VIDEO_HEIGHT}p enforced');

//     _videoStreamUrl = streamUrl;
//     _audioStreamUrl = null;

//     if (mounted && !_isDisposed && !_isDisposing) {
//       setState(() {
//         _controllerCreated = true;
//         _isInitializing = false;
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!_isDisposed && !_isDisposing && mounted) {
//           _initializationTimer = Timer(Duration(milliseconds: 3000), () {
//             if (mounted && !_isDisposed && !_isDisposing) {
//               _waitForAutoInitialization();
//             }
//           });
//         }
//       });
//     }
//   }

//   void _createControllers() {
//     if (_videoStreamUrl == null || !mounted || _isDisposed || _isDisposing)
//       return;

//     try {
//       print('Creating controllers with TV user agent...');
//       print(
//           'Current user agent: ${_getCurrentUserAgent().substring(0, 60)}...');

//       _playerController = VlcPlayerController.network(
//         _videoStreamUrl!,
//         hwAcc: HwAcc.auto,
//         autoPlay: false,
//         autoInitialize: true,
//         options: VlcPlayerOptions(
//           advanced: VlcAdvancedOptions([
//             VlcAdvancedOptions.networkCaching(5000),
//             VlcAdvancedOptions.liveCaching(5000),
//           ]),
//           audio: VlcAudioOptions([
//             '--aout=any',
//           ]),
//           video: VlcVideoOptions([
//             '--avcodec-hw=any',
//           ]),
//           http: VlcHttpOptions([
//             '--http-user-agent=${_getCurrentUserAgent()}',
//             '--http-referrer=https://www.youtube.com/',
//           ]),
//           subtitle: VlcSubtitleOptions([]),
//           rtp: VlcRtpOptions([]),
//         ),
//       );

//       print('Video controller created successfully');

//       if (_audioStreamUrl != null && !_isDisposed && !_isDisposing) {
//         print('Creating separate audio controller for high quality audio...');
//         _audioController = VlcPlayerController.network(
//           _audioStreamUrl!,
//           hwAcc: HwAcc.auto,
//           autoPlay: false,
//           autoInitialize: true,
//           options: VlcPlayerOptions(
//             advanced: VlcAdvancedOptions([
//               VlcAdvancedOptions.networkCaching(5000),
//               VlcAdvancedOptions.liveCaching(5000),
//             ]),
//             audio: VlcAudioOptions([
//               '--aout=any',
//             ]),
//             video: VlcVideoOptions([
//               '--no-video',
//             ]),
//             http: VlcHttpOptions([
//               '--http-user-agent=${_getCurrentUserAgent()}',
//               '--http-referrer=https://www.youtube.com/',
//             ]),
//             subtitle: VlcSubtitleOptions([]),
//             rtp: VlcRtpOptions([]),
//           ),
//         );
//         print('Audio controller created successfully');
//         _useDualStream = true;
//       }
//     } catch (e) {
//       print('Error creating controllers: $e');
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage = 'Failed to create video players: $e';
//         });
//       }
//     }
//   }

//   Future<void> _waitForAutoInitialization() async {
//     if (!mounted || _playerController == null || _isDisposed || _isDisposing) {
//       print(
//           'Cannot wait for initialization: widget not mounted or controller null');
//       return;
//     }

//     try {
//       print('Waiting for auto-initialization of controllers...');

//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _isInitializing = true;
//           _errorMessage = null;
//         });
//       }

//       int attempts = 0;
//       const maxAttempts = 30;

//       while (attempts < maxAttempts &&
//           mounted &&
//           _playerController != null &&
//           !_isDisposed &&
//           !_isDisposing) {
//         final videoInitialized =
//             _playerController?.value.isInitialized ?? false;
//         final audioInitialized = _audioController?.value.isInitialized ?? true;

//         print(
//             'Auto-initialization check $attempts: video=$videoInitialized, audio=$audioInitialized');

//         if (videoInitialized && audioInitialized) {
//           print('Controllers auto-initialized successfully');
//           break;
//         }

//         await Future.delayed(Duration(seconds: 1));
//         attempts++;

//         if (!mounted || _isDisposed || _isDisposing) {
//           print('Widget disposed during initialization, stopping...');
//           return;
//         }
//       }

//       if (mounted &&
//           _playerController != null &&
//           !_isDisposed &&
//           !_isDisposing) {
//         final videoInitialized =
//             _playerController?.value.isInitialized ?? false;
//         final audioInitialized = _audioController?.value.isInitialized ?? true;

//         if (videoInitialized && audioInitialized) {
//           if (mounted && !_isDisposed && !_isDisposing) {
//             setState(() {
//               _isInitialized = true;
//               _isInitializing = false;
//             });
//           }

//           print(
//               'Controllers ready for playback (dual stream: $_useDualStream)');
//           _setupSyncListeners();
//           _setupPositionTracking();

//           _autoPlayTimer = Timer(Duration(milliseconds: 1500), () {
//             if (mounted && _isInitialized && !_isDisposed && !_isDisposing) {
//               print('Starting auto-play...');
//               _playBoth();
//             }
//           });
//         } else {
//           throw Exception('Controllers failed to auto-initialize');
//         }
//       }
//     } catch (e) {
//       print('Auto-initialization wait error: $e');
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage = 'Failed to initialize video players: $e';
//           _isInitializing = false;
//           _isInitialized = false;
//         });
//       }
//     }
//   }

//   // Enhanced sync listeners with audio recovery
//   void _setupSyncListeners() {
//     if (!_isInitialized ||
//         _playerController == null ||
//         !mounted ||
//         _isDisposed ||
//         _isDisposing) {
//       return;
//     }

//     _syncSubscription?.cancel();

//     Timer(Duration(seconds: 3), () {
//       if (mounted &&
//           _isInitialized &&
//           _playerController != null &&
//           !_isDisposed &&
//           !_isDisposing) {
//         _syncSubscription =
//             Stream.periodic(Duration(seconds: 1)).listen((_) async {
//           if (mounted &&
//               _isInitialized &&
//               _playerController != null &&
//               !_isDisposed &&
//               !_isDisposing &&
//               !_isSeeking) {
//             try {
//               final videoInitialized =
//                   _playerController?.value.isInitialized ?? false;
//               final videoPlaying = _playerController?.value.isPlaying ?? false;

//               if (videoInitialized) {
//                 final videoPosition =
//                     await _playerController?.getPosition() ?? Duration.zero;

//                 if (_useDualStream &&
//                     _audioController != null &&
//                     !_isDisposed &&
//                     !_isDisposing) {
//                   final audioInitialized =
//                       _audioController?.value.isInitialized ?? false;
//                   final audioPlaying =
//                       _audioController?.value.isPlaying ?? false;

//                   if (audioInitialized) {
//                     // Check if audio is out of sync with video
//                     final audioPosition =
//                         await _audioController?.getPosition() ?? Duration.zero;
//                     final diff = (videoPosition.inMilliseconds -
//                             audioPosition.inMilliseconds)
//                         .abs();

//                     if (diff > 1000 && !_isSeeking) {
//                       print(
//                           '🔄 Major audio sync correction: ${diff}ms difference');
//                       await _audioController?.seekTo(videoPosition);
//                     }

//                     // Critical: Check if video is playing but audio is not
//                     if (videoPlaying &&
//                         !audioPlaying &&
//                         _isPlaying &&
//                         !_isSeeking) {
//                       print(
//                           '🚨 Audio stopped but video playing - restarting audio...');
//                       await _audioController?.play();
//                     }

//                     // Also check reverse case
//                     if (!videoPlaying && audioPlaying && !_isPlaying) {
//                       print(
//                           '🚨 Video stopped but audio playing - stopping audio...');
//                       await _audioController?.pause();
//                     }
//                   }
//                 }

//                 // Update current position
//                 if (mounted && !_isDisposed && !_isDisposing) {
//                   setState(() {
//                     _currentPosition = videoPosition;
//                   });
//                 }
//               }
//             } catch (e) {
//               // Silent sync errors but log critical ones
//               if (e.toString().contains('audio')) {
//                 print('⚠️ Audio sync error: $e');
//               }
//             }
//           }
//         });
//       }
//     });
//   }

//   // Enhanced play method with audio verification
//   Future<void> _playBoth() async {
//     if (!_isInitialized ||
//         _playerController == null ||
//         _isDisposed ||
//         _isDisposing) {
//       print('Cannot play: not initialized or controllers are null');
//       return;
//     }

//     _earlyPauseTriggered = false;

//     try {
//       final videoInitialized = _playerController?.value.isInitialized ?? false;

//       if (videoInitialized && !_isDisposed && !_isDisposing) {
//         print('▶️ Playing video controller...');
//         await _playerController?.play();

//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing) {
//           final audioInitialized =
//               _audioController?.value.isInitialized ?? false;
//           if (audioInitialized) {
//             print('🎵 Playing audio controller...');
//             await _audioController?.play();

//             // Verify audio started playing after small delay
//             Timer(Duration(milliseconds: 300), () async {
//               if (_audioController != null && !_isDisposed && _isPlaying) {
//                 final audioPlaying = _audioController?.value.isPlaying ?? false;
//                 if (!audioPlaying) {
//                   print('🔄 Audio failed to start, retrying...');
//                   try {
//                     await _audioController?.play();
//                   } catch (e) {
//                     print('❌ Audio retry failed: $e');
//                   }
//                 }
//               }
//             });
//           }
//         }

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() => _isPlaying = true);
//         }
//         print('✅ Controllers playing (dual stream: $_useDualStream)');
//       } else {
//         print('❌ Controllers not ready');
//       }
//     } catch (e) {
//       print('❌ Error playing: $e');
//     }
//   }

//   Future<void> _pauseBoth() async {
//     if (!_isInitialized ||
//         _playerController == null ||
//         _isDisposed ||
//         _isDisposing) {
//       print('Cannot pause: not initialized or controllers are null');
//       return;
//     }

//     try {
//       final videoInitialized = _playerController?.value.isInitialized ?? false;

//       if (videoInitialized && !_isDisposed && !_isDisposing) {
//         print('Pausing video controller...');
//         await _playerController?.pause();

//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing) {
//           final audioInitialized =
//               _audioController?.value.isInitialized ?? false;
//           if (audioInitialized) {
//             print('Pausing audio controller...');
//             await _audioController?.pause();
//           }
//         }

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() => _isPlaying = false);
//         }
//         print('Controllers paused (dual stream: $_useDualStream)');
//       }
//     } catch (e) {
//       print('Error pausing: $e');
//     }
//   }

//   // Legacy seek method (replaced by _seekBothWithDebounce)
//   Future<void> _seekBoth(Duration position) async {
//     return _seekBothWithDebounce(position);
//   }

//   Future<void> _stopBoth() async {
//     if (!_isInitialized ||
//         _playerController == null ||
//         _isDisposed ||
//         _isDisposing) {
//       print('Cannot stop: not initialized or controllers are null');
//       return;
//     }

//     try {
//       final videoInitialized = _playerController?.value.isInitialized ?? false;

//       if (videoInitialized && !_isDisposed && !_isDisposing) {
//         print('Stopping video controller...');
//         await _playerController?.stop();

//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing) {
//           final audioInitialized =
//               _audioController?.value.isInitialized ?? false;
//           if (audioInitialized) {
//             print('Stopping audio controller...');
//             await _audioController?.stop();
//           }
//         }

//         if (mounted && !_isDisposed && !_isDisposing) {
//           setState(() => _isPlaying = false);
//         }
//         print('Controllers stopped (dual stream: $_useDualStream)');
//       }
//     } catch (e) {
//       print('Error stopping: $e');
//     }
//   }

//   Future<void> _retryWithDifferentUserAgent() async {
//     if (_failedAttempts >= _tvUserAgents.length ||
//         _isDisposed ||
//         _isDisposing) {
//       if (mounted && !_isDisposed && !_isDisposing) {
//         setState(() {
//           _errorMessage =
//               'All user agents failed. Video may be restricted or temporarily unavailable.';
//         });
//       }
//       return;
//     }

//     _rotateUserAgent();

//     if (mounted && !_isDisposed && !_isDisposing) {
//       setState(() {
//         _errorMessage = null;
//         _isInitialized = false;
//         _isInitializing = false;
//         _controllerCreated = false;
//         _useDualStream = false;
//         _videoStreamUrl = null;
//         _audioStreamUrl = null;
//       });
//     }

//     await _disposeControllersSync();
//     await Future.delayed(Duration(seconds: 2));

//     if (mounted && !_isDisposed && !_isDisposing) {
//       _loadStreamUrls();
//     }
//   }

//   Future<void> _disposeControllersSync() async {
//     print('Disposing controllers synchronously...');

//     _cancelAllTimers();

//     try {
//       if (_playerController != null) {
//         print('Disposing video controller...');
//         await _playerController?.stop().timeout(Duration(seconds: 2));
//         await _playerController?.dispose().timeout(Duration(seconds: 3));
//         _playerController = null;
//         print('Video controller disposed');
//       }
//       if (_audioController != null) {
//         print('Disposing audio controller...');
//         await _audioController?.stop().timeout(Duration(seconds: 2));
//         await _audioController?.dispose().timeout(Duration(seconds: 3));
//         _audioController = null;
//         print('Audio controller disposed');
//       }
//     } catch (e) {
//       print('Error disposing controllers: $e');
//       _playerController = null;
//       _audioController = null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: RawKeyboardListener(
//         focusNode: _focusNode,
//         onKey: _handleKeyEvent,
//         child: GestureDetector(
//           onTap: () {
//             _showControlsTemporarily();
//           },
//           child: _buildPlayerContent(),
//         ),
//       ),
//     );
//   }

//   Widget _buildPlayerContent() {
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

//     if (_isDisposed || _isDisposing) {
//       return Container(
//         height: screenhgt,
//         color: Colors.black,
//         child: Center(
//           child: Text(
//             'Player disposed',
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       );
//     }

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
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: _isDisposing
//                       ? null
//                       : () {
//                           if (_isDisposed || _isDisposing) return;
//                           setState(() {
//                             _errorMessage = null;
//                             _isInitialized = false;
//                             _isInitializing = false;
//                             _controllerCreated = false;
//                             _useDualStream = false;
//                             _videoStreamUrl = null;
//                             _audioStreamUrl = null;
//                             _failedAttempts = 0;
//                           });
//                           _disposeControllersSync().then((_) {
//                             if (!_isDisposed && !_isDisposing && mounted) {
//                               _loadStreamUrls();
//                             }
//                           });
//                         },
//                   child: Text('Retry'),
//                 ),
//                 SizedBox(width: 16),
//                 ElevatedButton(
//                   onPressed: (_isDisposed || _isDisposing)
//                       ? null
//                       : _retryWithDifferentUserAgent,
//                   child: Text('Try Different Agent'),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Agent ${_currentUserAgentIndex + 1}/${_tvUserAgents.length}: ${_getCurrentUserAgent().substring(0, 30)}...',
//               style: TextStyle(fontSize: 10, color: Colors.grey),
//             ),
//             if (_failedAttempts > 0)
//               Text(
//                 'Failed attempts: $_failedAttempts',
//                 style: TextStyle(fontSize: 10, color: Colors.orange),
//               ),
//           ],
//         ),
//       );
//     }

//     if (!_controllerCreated || (_isInitializing && !_isInitialized) ) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text(!_controllerCreated
//                 ? 'Loading  video streams...'
//                 : 'Initializing video players...'),
//             SizedBox(height: 8),
//             Text(
//               'Agent ${_currentUserAgentIndex + 1}/${_tvUserAgents.length}: ${_getCurrentUserAgent().substring(0, 40)}...',
//               style: TextStyle(fontSize: 10, color: Colors.grey),
//               textAlign: TextAlign.center,
//             ),
//             if (_failedAttempts > 0)
//               Padding(
//                 padding: const EdgeInsets.only(top: 4.0),
//                 child: Text(
//                   'Attempts: $_failedAttempts',
//                   style: TextStyle(fontSize: 10, color: Colors.orange),
//                 ),
//               ),
//           ],
//         ),
//       );
//     }

//     if (_controllerCreated &&
//         _playerController == null &&
//         !_isDisposed &&
//         !_isDisposing) {
//       _createControllers();
//     }

//     return Stack(
//       children: [
//         // Video player (main layer) - Now with custom width
//         Center(
//           child: Container(
//             height: effectiveVideoHeight,
//             width: effectiveVideoWidth,
//             decoration: BoxDecoration(
//               color: Colors.black,
//               borderRadius: BorderRadius.circular(12), // Rounded corners
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 10,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: _playerController != null && !_isDisposed && !_isDisposing
//                   ? VlcPlayer(
//                       controller: _playerController!,
//                       aspectRatio: 16 / 9,
//                       placeholder: const Center(
//                         child: Text(
//                           'Loading Video...',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     )
//                   : Container(
//                       color: Colors.black,
//                       child: const Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                     ),
//             ),
//           ),
//         ),

//         // Audio player (hidden)
//         if (_useDualStream &&
//             _audioController != null &&
//             !_isDisposed &&
//             !_isDisposing)
//           Positioned(
//             top: -1000,
//             child: Container(
//               height: 1,
//               width: 1,
//               child: VlcPlayer(
//                 controller: _audioController!,
//                 aspectRatio: 1,
//               ),
//             ),
//           ),

//         // Controls overlay
//         if (_showControls && _isInitialized) _buildControlsOverlay(),

//         // Video title at top
//         if (_isInitialized)
//           Positioned(
//             top: 20,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.black54,
//                     Colors.transparent,
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 widget.name ?? '',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   shadows: [
//                     Shadow(
//                       offset: Offset(1, 1),
//                       blurRadius: 2,
//                       color: Colors.black87,
//                     ),
//                   ],
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),

//         // Always show progress bar at bottom - Enhanced with Progressive Seek
//         if (_isInitialized && _totalDuration.inSeconds > 0)
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: _buildProgressBarWithProgressive(),
//           ),
//       ],
//     );
//   }

//   Widget _buildControlsOverlay() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: RadialGradient(
//           center: Alignment.center,
//           radius: 1.0,
//           colors: [
//             Colors.black.withOpacity(0.3),
//             Colors.black.withOpacity(0.7),
//           ],
//         ),
//       ),
//       child: Center(
//         child: Container(
//           padding: EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.8),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: Colors.white24, width: 2),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black54,
//                 blurRadius: 20,
//                 spreadRadius: 5,
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Play/Pause button - centered and prominent
//               Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.red.withOpacity(0.2),
//                   border: Border.all(color: Colors.red, width: 2),
//                 ),
//                 child: IconButton(
//                   onPressed: _togglePlayPause,
//                   icon: Icon(
//                     _isPlaying ? Icons.pause : Icons.play_arrow,
//                     color: Colors.white,
//                     size: 48,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Enhanced Progress Bar with Progressive Seek Preview
//   Widget _buildProgressBarWithProgressive() {
//     final progress = _totalDuration.inMilliseconds > 0
//         ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
//         : 0.0;

//     // Calculate preview progress if progressively seeking
//     final previewProgress = _isProgressiveSeeking && _totalDuration.inMilliseconds > 0
//         ? _targetSeekPosition.inMilliseconds / _totalDuration.inMilliseconds
//         : null;

//     return Container(
//       height: 70,
//       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.transparent,
//             Colors.black.withOpacity(0.8),
//           ],
//         ),
//       ),
//       child: Column(
//         children: [
//           // Time indicators with progressive seeking status
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.black54,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   _isProgressiveSeeking
//                       ? _formatDuration(_targetSeekPosition)
//                       : _formatDuration(_currentPosition),
//                   style: TextStyle(
//                     color: _isProgressiveSeeking ? Colors.yellow : Colors.white,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     fontFeatures: [FontFeature.tabularFigures()],
//                   ),
//                 ),
//               ),
              
//               // Show seeking indicator
//               if (_isProgressiveSeeking || _isSeeking)
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: _isSeeking 
//                         ? Colors.orange.withOpacity(0.9)
//                         : Colors.yellow.withOpacity(0.9),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         _isSeeking ? Icons.sync : Icons.fast_forward,
//                         color: Colors.white,
//                         size: 16,
//                       ),
//                       SizedBox(width: 4),
//                       Text(
//                         _isSeeking ? 'Processing...' : 'Seeking...',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
                
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.black54,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   _formatDuration(_totalDuration),
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     fontFeatures: [FontFeature.tabularFigures()],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 8),
          
//           // Enhanced progress bar with preview
//           GestureDetector(
//             onTapDown: (details) {
//               if (_isSeeking || _isProgressiveSeeking) return;

//               final RenderBox box = context.findRenderObject() as RenderBox;
//               final localPosition = box.globalToLocal(details.globalPosition);
//               final width = box.size.width - 40;
//               final tapPosition = localPosition.dx - 20;

//               if (tapPosition >= 0 && tapPosition <= width) {
//                 final seekPercentage = tapPosition / width;
//                 final seekPosition = Duration(
//                   milliseconds: (_totalDuration.inMilliseconds * seekPercentage).round(),
//                 );
//                 _seekBothWithDebounce(seekPosition);
//                 _showControlsTemporarily();
//               }
//             },
//             child: Container(
//               height: 6,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(3),
//                 color: Colors.white.withOpacity(0.3),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 2,
//                     offset: Offset(0, 1),
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(3),
//                 child: Stack(
//                   children: [
//                     // Current progress
//                     LinearProgressIndicator(
//                       value: progress,
//                       backgroundColor: Colors.transparent,
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         _isSeeking ? Colors.orange : Colors.red,
//                       ),
//                     ),
                    
//                     // Preview progress for progressive seeking
//                     if (previewProgress != null)
//                       LinearProgressIndicator(
//                         value: previewProgress,
//                         backgroundColor: Colors.transparent,
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           Colors.yellow.withOpacity(0.8),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
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
//     print('Disposing CustomYoutubePlayer - starting cleanup...');
//     KeepScreenOn.turnOff();
//     WidgetsBinding.instance.removeObserver(this);

//     _focusNode.dispose();

//     _isDisposing = true;
//     _cancelAllTimers();
//     _disposeControllersInBackground();

//     super.dispose();
//     print('Widget disposed successfully');
//   }
// }



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

//   // Quality control through YouTube Player flags only
//   // Note: youtube_player_flutter doesn't support runtime quality change
//   // Quality is controlled through YoutubePlayerFlags during initialization
//   void _logCurrentQuality() {
//     if (_controller != null && _isPlayerReady) {
//       try {
//         final playerValue = _controller!.value;
//         print('Video quality info - IsReady: ${playerValue.isReady}, IsPlaying: ${playerValue.isPlaying}');
//         print('Player initialized with forceHD: true (max 1080p)');
//       } catch (e) {
//         print('Quality info error: $e');
//       }
//     }
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
//           forceHD: true, // Force HD quality (maximum 1080p)
//           enableCaption: false,
//           controlsVisibleAtStart: false,
//           hideControls: true,
//           hideThumbnail: false,
//           useHybridComposition: true,
//         ),
//       );

//       _controller!.addListener(_listener);

//       Future.delayed(const Duration(milliseconds: 300), () {
//         if (mounted && _controller != null && !_isDisposed) {
//           _controller!.load(videoId);

//           // Log quality info after loading (for debugging)
//           Future.delayed(const Duration(milliseconds: 500), () {
//             if (mounted && _controller != null && !_isDisposed) {
//               // Log quality information
//               _logCurrentQuality();
//             }
//           });

//           Future.delayed(const Duration(milliseconds: 800), () {
//             if (mounted && _controller != null && !_isDisposed) {
//               _controller!.play();
              
//               // Log quality info after play starts
//               Future.delayed(const Duration(milliseconds: 1000), () {
//                 if (mounted && _controller != null && !_isDisposed) {
//                   _logCurrentQuality();
//                 }
//               });

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
//             // Log quality info after play
//             Future.delayed(const Duration(milliseconds: 500), () {
//               _logCurrentQuality();
//             });
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

//         // Log quality info after play
//         Future.delayed(const Duration(milliseconds: 500), () {
//           _logCurrentQuality();
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
//             // Log quality info after seek and play
//             Future.delayed(const Duration(milliseconds: 500), () {
//               _logCurrentQuality();
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

//     // Start new timer with 5 second delay
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
//                             // Log quality info after play
//                             Future.delayed(const Duration(milliseconds: 1000), () {
//                               _logCurrentQuality();
//                             });
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







import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:async';
import 'package:intl/intl.dart';

// Direct YouTube Player Screen - No Home Page Required
class CustomYoutubePlayer extends StatefulWidget {
  final videoUrl;
  final String? name;

  const CustomYoutubePlayer({
    Key? key,
    required this.videoUrl,
    required this.name,
  }) : super(key: key);

  @override
  _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
}

// Enhanced Player State Enum
enum PlayerState { unknown, unstarted, ended, playing, paused, buffering, cued }

class _CustomYoutubePlayerState extends State<CustomYoutubePlayer>
    with TickerProviderStateMixin {
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;
  String? _error;
  bool _isLoading = true;
  bool _isDisposed = false;

  // Navigation control
  bool _isNavigating = false;
  bool _videoCompleted = false;

  // Scrolling text animation controller
  late AnimationController _scrollController;
  late Animation<Offset> _scrollAnimation;

  // Enhanced Control states
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _wasPlayingBeforeSeek = false;
  PlayerState _currentPlayerState = PlayerState.unknown;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Progressive seeking states
  Timer? _seekTimer;
  int _pendingSeekSeconds = 0;
  Duration _targetSeekPosition = Duration.zero;
  bool _isSeeking = false;

  // Focus nodes for TV remote
  final FocusNode _mainFocusNode = FocusNode();

  // Date and time
  late Timer _dateTimeTimer;
  late Timer? _stateVerificationTimer;
  String _currentDate = '';
  String _currentTime = '';

  // Video thumbnail URL
  String? _thumbnailUrl;

  // Variable to track if video has started playing at least once
  bool _hasVideoStartedPlaying = false;

  // Timer for delaying text color change
  Timer? _textColorDelayTimer;

  // Timer for checking video completion more reliably
  Timer? _completionCheckTimer;

  @override
  void initState() {
    super.initState();

    // Initialize date and time
    _updateDateTime();
    _startDateTimeTimer();

    // Initialize scrolling animation
    _initializeScrollAnimation();

    // Set full screen immediately
    _setFullScreenMode();

    // Generate thumbnail URL
    _generateThumbnailUrl();

    // Start player initialization immediately
    _initializePlayer();

    // Start state verification timer
    _startStateVerificationTimer();

    // Start completion check timer
    _startCompletionCheckTimer();

    // Request focus on main node initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mainFocusNode.requestFocus();
    });
  }

  void _generateThumbnailUrl() {
    String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId != null && videoId.isNotEmpty) {
      // High quality thumbnail URL
      _thumbnailUrl = 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
    }
  }

  void _updateDateTime() {
    final now = DateTime.now();
    _currentDate = DateFormat('MM/dd/yyyy').format(now);
    _currentTime = DateFormat('HH:mm:ss').format(now);
  }

  void _startDateTimeTimer() {
    _dateTimeTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted && !_isDisposed) {
        setState(() {
          _updateDateTime();
        });
      }
    });
  }

  void _initializeScrollAnimation() {
    _scrollController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );

    _scrollAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _scrollController,
      curve: Curves.linear,
    ));

    _scrollController.repeat();
  }

  void _setFullScreenMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }

  // Quality control through YouTube Player flags only
  // Note: youtube_player_flutter doesn't support runtime quality change
  // Quality is controlled through YoutubePlayerFlags during initialization
  void _logCurrentQuality() {
    if (_controller != null && _isPlayerReady) {
      try {
        final playerValue = _controller!.value;
        print('Video quality info - IsReady: ${playerValue.isReady}, IsPlaying: ${playerValue.isPlaying}');
        print('Player initialized with forceHD: true (max 1080p)');
      } catch (e) {
        print('Quality info error: $e');
      }
    }
  }

  void _initializePlayer() {
    if (_isDisposed) return;

    try {
      String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

      if (videoId == null || videoId.isEmpty) {
        if (mounted && !_isDisposed) {
          setState(() {
            _error = 'Invalid YouTube URL: ${widget.videoUrl}';
            _isLoading = false;
          });
        }
        return;
      }

      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          mute: false,
          autoPlay: true,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false, 
          enableCaption: false,
          controlsVisibleAtStart: false,
          hideControls: true,
          hideThumbnail: false,
          useHybridComposition: false,
        ),
      );



      _controller!.addListener(_listener);

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _controller != null && !_isDisposed) {
          _controller!.load(videoId);

          // Log quality info after loading (for debugging)
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _controller != null && !_isDisposed) {
              // Log quality information
              _logCurrentQuality();
            }
          });

          
  //       // After video starts playing, you can try to improve quality
  // Future.delayed(Duration(seconds: 120), () {
  //   if (_controller != null && mounted) {
  //     // This doesn't guarantee HD but may help
  //     _controller!.play();
  //   }
  // });

          Future.delayed(const Duration(seconds: 120), () {
            if (mounted && _controller != null && !_isDisposed) {
              _controller!.play();
              
              // Log quality info after play starts
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted && _controller != null && !_isDisposed) {
                  _logCurrentQuality();
                }
              });

              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _isPlayerReady = true;
                  _isPlaying = true;
                  _currentPlayerState = PlayerState.playing;
                  // Start delay timer instead of immediately setting flag
                  _startTextColorDelayTimer();
                });
              }
            }
          });
        }
      });
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          _error = 'Player Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  // Enhanced Listener with Multiple State Checks
  void _listener() {
    if (_controller != null && mounted && !_isDisposed && !_isNavigating) {
      final playerValue = _controller!.value;

      // Get current states
      final bool isReady = playerValue.isReady;
      final bool isPlaying = playerValue.isPlaying;
      final bool isBuffering = isReady &&
          !isPlaying &&
          _currentPosition == playerValue.position &&
          playerValue.position.inSeconds > 0;
      final Duration position = playerValue.position;
      final Duration duration = playerValue.metaData.duration;

      // Check for video end state first
      if (duration.inSeconds > 0 && position.inSeconds > 0) {
        // Check if video has reached the end (within 2 seconds of duration)
        if (position.inSeconds >= (duration.inSeconds - 2)) {
          print('Video ended - Position: ${position.inSeconds}, Duration: ${duration.inSeconds}');
          _completeVideo();
          return;
        }
      }

      // Determine actual player state
      PlayerState newPlayerState = _determinePlayerState(
        isReady: isReady,
        isPlaying: isPlaying,
        isBuffering: isBuffering,
        position: position,
        duration: duration,
      );

      // Always sync with controller state for play/pause
      bool shouldUpdateState = false;

      if (newPlayerState != _currentPlayerState) {
        shouldUpdateState = true;
      }

      if (isPlaying != _isPlaying) {
        shouldUpdateState = true;
      }

      if (shouldUpdateState) {
        if (mounted) {
          setState(() {
            _currentPlayerState = newPlayerState;
            _isPlaying = isPlaying;
            _isPaused = _determinePausedState(newPlayerState, isPlaying);
            _currentPosition = position;
            _totalDuration = duration;

            // Update _hasVideoStartedPlaying when video actually starts playing
            if (isPlaying && position.inSeconds > 0 && !_hasVideoStartedPlaying) {
              _startTextColorDelayTimer();
            }
          });
        }
      } else {
        // Update position and duration even if states haven't changed
        if (mounted) {
          setState(() {
            _currentPosition = position;
            _totalDuration = duration;

            // Update _hasVideoStartedPlaying when video actually starts playing
            if (isPlaying && position.inSeconds > 0 && !_hasVideoStartedPlaying) {
              _startTextColorDelayTimer();
            }
          });
        }
      }

      // Handle ready state
      if (isReady && !_isPlayerReady) {
        if (mounted) {
          setState(() {
            _isPlayerReady = true;
            _isLoading = false;
          });
        }

        // Auto-play after ready with small delay to ensure frame appears
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_controller != null && !_isDisposed) {
            _controller!.play();
            // Log quality info after play
            Future.delayed(const Duration(milliseconds: 500), () {
              _logCurrentQuality();
            });
          }
        });
      }
    }
  }

  // Start a timer to periodically check for video completion
  void _startCompletionCheckTimer() {
    _completionCheckTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      if (_controller != null && _isPlayerReady && mounted && !_videoCompleted) {
        final playerValue = _controller!.value;
        final position = playerValue.position;
        final duration = playerValue.metaData.duration;

        // More aggressive completion check
        if (duration.inSeconds > 0 && position.inSeconds > 0) {
          // Check if video is within 3 seconds of end or if it's actually ended
          bool isNearEnd = position.inSeconds >= (duration.inSeconds - 3);
          bool hasActuallyEnded = position.inSeconds >= duration.inSeconds;
          bool isAtEnd = playerValue.position >= playerValue.metaData.duration;

          if (isNearEnd || hasActuallyEnded || isAtEnd) {
            print('Video completion detected - Position: ${position.inSeconds}, Duration: ${duration.inSeconds}');
            _completeVideo();
          }
        }
      }
    });
  }

  // Enhanced State Determination Logic
  PlayerState _determinePlayerState({
    required bool isReady,
    required bool isPlaying,
    required bool isBuffering,
    required Duration position,
    required Duration duration,
  }) {
    if (!isReady) {
      return PlayerState.unstarted;
    }

    if (isBuffering) {
      return PlayerState.buffering;
    }

    if (duration.inSeconds > 0 &&
        position.inSeconds >= duration.inSeconds - 1) {
      return PlayerState.ended;
    }

    if (isPlaying) {
      return PlayerState.playing;
    }

    // If ready but not playing and not buffering, it's paused
    if (position.inSeconds > 0) {
      return PlayerState.paused;
    }

    return PlayerState.cued;
  }

  // Accurate Pause State Detection
  bool _determinePausedState(PlayerState playerState, bool isPlaying) {
    return playerState == PlayerState.paused ||
        (!isPlaying &&
            _currentPosition.inSeconds > 0 &&
            playerState != PlayerState.buffering &&
            playerState != PlayerState.ended &&
            playerState != PlayerState.unstarted &&
            _isPlayerReady);
  }

  // Alternative Method: Direct Controller State Check
  bool _getAccuratePauseState() {
    if (_controller == null || !_isPlayerReady) return false;

    final playerValue = _controller!.value;

    // More reliable pause detection
    bool controllerNotPlaying = !playerValue.isPlaying;
    bool hasPosition = playerValue.position.inSeconds > 0;
    bool isReady = playerValue.isReady;
    bool notEnded = playerValue.position < playerValue.metaData.duration;

    return controllerNotPlaying && hasPosition && isReady && notEnded;
  }

  // Periodic State Verification
  void _startStateVerificationTimer() {
    _stateVerificationTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      if (_controller != null && _isPlayerReady && mounted) {
        final controllerPlaying = _controller!.value.isPlaying;
        final controllerReady = _controller!.value.isReady;

        // If there's a mismatch, correct it immediately
        if (controllerPlaying != _isPlaying && controllerReady) {
          setState(() {
            _isPlaying = controllerPlaying;
            _isPaused = !controllerPlaying &&
                _currentPosition.inSeconds > 0 &&
                controllerReady;

            _currentPlayerState =
                controllerPlaying ? PlayerState.playing : PlayerState.paused;

            // Update _hasVideoStartedPlaying when video actually starts playing
            if (controllerPlaying && _currentPosition.inSeconds > 0 && !_hasVideoStartedPlaying) {
              _startTextColorDelayTimer();
            }
          });
        }
      }
    });
  }

  // Enhanced video completion method
  void _completeVideo() {
    if (_isNavigating || _videoCompleted || _isDisposed) return;

    print('_completeVideo called - Starting navigation back');

    _videoCompleted = true;
    _isNavigating = true;

    // Stop the player immediately
    if (_controller != null) {
      try {
        _controller!.pause();
        print('Video paused successfully');
      } catch (e) {
        print('Error pausing video: $e');
      }
    }

    // Cancel all timers
    _completionCheckTimer?.cancel();
    _seekTimer?.cancel();
    _stateVerificationTimer?.cancel();
    _textColorDelayTimer?.cancel();

    // Navigate back with a short delay to ensure cleanup
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_isDisposed) {
        print('Attempting to navigate back to source page');
        try {
          Navigator.of(context).pop();
          print('Navigation completed successfully');
        } catch (e) {
          print('Error during navigation: $e');
          // Try alternative navigation method
          Navigator.pop(context);
        }
      }
    });
  }

  // Enhanced Toggle Play/Pause with State Tracking
  void _togglePlayPause() {
    if (_controller != null && _isPlayerReady && !_isDisposed) {
      final currentControllerState = _controller!.value.isPlaying;

      if (currentControllerState) {
        // Video is currently playing, so pause it
        _controller!.pause();

        // Immediately update state
        setState(() {
          _isPlaying = false;
          _isPaused = true;
          _currentPlayerState = PlayerState.paused;
        });
      } else {
        // Video is not playing, so play it
        _controller!.play();

        // Immediately update state
        setState(() {
          _isPlaying = true;
          _isPaused = false;
          _currentPlayerState = PlayerState.playing;
          // Mark that video has started playing when manually played with delay
          if (_currentPosition.inSeconds > 0) {
            _startTextColorDelayTimer();
          }
        });

        // Log quality info after play
        Future.delayed(const Duration(milliseconds: 500), () {
          _logCurrentQuality();
        });

        // Additional verification after a short delay
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_controller != null && mounted && !_isDisposed) {
            final verifyPlaying = _controller!.value.isPlaying;

            if (!verifyPlaying) {
              // If still not playing, try again
              _controller!.play();
            }
          }
        });
      }
    }
  }

  // Enhanced Seeking with Play State Preservation
  void _seekVideo(bool forward) {
    if (_controller != null &&
        _isPlayerReady &&
        _totalDuration.inSeconds > 24 &&
        !_isDisposed) {
      // Remember playing state before seeking
      _wasPlayingBeforeSeek = _isPlaying;

      final adjustedEndTime = _totalDuration.inSeconds - 12;
      final seekAmount = (adjustedEndTime / 200).round().clamp(5, 30);

      _seekTimer?.cancel();

      if (forward) {
        _pendingSeekSeconds += seekAmount;
      } else {
        _pendingSeekSeconds -= seekAmount;
      }

      final currentSeconds = _currentPosition.inSeconds;
      final targetSeconds =
          (currentSeconds + _pendingSeekSeconds).clamp(0, adjustedEndTime);
      _targetSeekPosition = Duration(seconds: targetSeconds);

      if (mounted && !_isDisposed) {
        setState(() {
          _isSeeking = true;
        });
      }

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
      final adjustedEndTime = _totalDuration.inSeconds - 12;
      final currentSeconds = _currentPosition.inSeconds;
      final newPosition =
          (currentSeconds + _pendingSeekSeconds).clamp(0, adjustedEndTime);

      _controller!.seekTo(Duration(seconds: newPosition));

      // Restore playing state after seek
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_controller != null && !_isDisposed) {
          if (_wasPlayingBeforeSeek) {
            _controller!.play();
            setState(() {
              _isPlaying = true;
              _isPaused = false;
              _currentPlayerState = PlayerState.playing;
            });
            // Log quality info after seek and play
            Future.delayed(const Duration(milliseconds: 500), () {
              _logCurrentQuality();
            });
          }
        }
      });

      _pendingSeekSeconds = 0;
      _targetSeekPosition = Duration.zero;

      if (mounted && !_isDisposed) {
        setState(() {
          _isSeeking = false;
        });
      }
    }
  }

  // Method to start the delay timer for text color change
  void _startTextColorDelayTimer() {
    // Cancel any existing timer
    _textColorDelayTimer?.cancel();

    // Start new timer with 5 second delay
    _textColorDelayTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_isDisposed) {
        setState(() {
          _hasVideoStartedPlaying = true;
        });
      }
    });
  }

  bool _handleKeyEvent(RawKeyEvent event) {
    if (_isDisposed) return false;

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

  Future<bool> _onWillPop() async {
    if (_isDisposed || _isNavigating) return true;

    try {
      _isNavigating = true;
      _isDisposed = true;

      _seekTimer?.cancel();
      _dateTimeTimer?.cancel();
      _stateVerificationTimer?.cancel();
      _textColorDelayTimer?.cancel();
      _completionCheckTimer?.cancel();
      _scrollController.dispose();

      if (_controller != null) {
        try {
          if (_controller!.value.isPlaying) {
            _controller!.pause();
          }
          _controller!.dispose();
          _controller = null;
        } catch (e) {
          // Handle dispose error silently
        }
      }

      try {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: SystemUiOverlay.values);
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } catch (e) {
        // Handle system UI error silently
      }

      return true;
    } catch (e) {
      return true;
    }
  }

  @override
  void dispose() {
    try {
      _isDisposed = true;
      _seekTimer?.cancel();
      _dateTimeTimer?.cancel();
      _stateVerificationTimer?.cancel();
      _textColorDelayTimer?.cancel();
      _completionCheckTimer?.cancel();
      _scrollController.dispose();

      if (_mainFocusNode.hasListeners) {
        _mainFocusNode.dispose();
      }

      if (_controller != null) {
        try {
          _controller!.pause();
          _controller!.dispose();
          _controller = null;
        } catch (e) {
          // Handle dispose error silently
        }
      }

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
        // Handle system UI error silently
      }
    } catch (e) {
      // Handle any dispose error silently
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
                // Full screen video player
                _buildVideoPlayer(),
                // Top/Bottom Black Bars with Progress Bar
                _buildTopBottomBlackBars(),
                // Date display below top bar
                _buildDateDisplay(),
                // Custom Loading Overlay - Only show when controller is null
                if (_controller == null) _buildCustomLoadingOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateDisplay() {
    return Positioned(
      top: screenhgt * 0.07,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Date with minimal background
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenwdt * 0.03,
              vertical: screenhgt * 0.001,
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              _currentDate,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Right side - Time with minimal background
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenwdt * 0.03,
              vertical: screenhgt * 0.001,
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              _currentTime,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBottomBlackBars() {
    return Stack(
      children: [
        // Top Black Bar with Scrolling Name
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: screenhgt * 0.1,
          child: Container(
            alignment: Alignment.center,
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: screenhgt * 0.03,
                ),
                Text(
                  'YOU ARE WATCHING RIGHT NOW : ${(widget.name?.toUpperCase() ?? '')}',
                  style: TextStyle(
                    // Dynamic color: black initially, white when video starts playing
                    color: _hasVideoStartedPlaying ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),

        // Bottom Black Bar with Progress Bar
        Positioned(
          bottom: 0,
          left: screenwdt * 0.7,
          right: 0,
          height: screenhgt * 0.12,
          child: Container(
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                              Container(
                                width: double.infinity,
                                height: 6,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              if (_totalDuration.inSeconds > 0)
                                FractionallySizedBox(
                                  widthFactor: _currentPosition.inSeconds /
                                      (_totalDuration.inSeconds - 12)
                                          .clamp(1, double.infinity),
                                  child: Container(
                                    height: 6,
                                    color: Colors.red,
                                  ),
                                ),
                              if (_isSeeking && _totalDuration.inSeconds > 0)
                                FractionallySizedBox(
                                  widthFactor: _targetSeekPosition.inSeconds /
                                      (_totalDuration.inSeconds - 12)
                                          .clamp(1, double.infinity),
                                  child: Container(
                                    height: 6,
                                    color: Colors.yellow.withOpacity(0.8),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

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
                              fontWeight: _isSeeking
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
                      _isPlayerReady = false;
                      _isPlaying = false;
                      _hasVideoStartedPlaying = false;
                      _textColorDelayTimer?.cancel();
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

    // Different width options - Choose one:

    // Option 1: 90% of screen width (10% kam)
    // double videoWidthMultiplier = 0.90;

    // Option 2: 95% of screen width (5% kam) - Recommended
    double videoWidthMultiplier = 0.98;

    // Option 3: 85% of screen width (15% kam) - More padding
    // double videoWidthMultiplier = 0.85;

    // Option 4: Fixed padding from sides (20 pixels each side)
    // double effectiveVideoWidth = screenwdt - 40;

    // Calculate video dimensions
    double effectiveVideoWidth = screenwdt * videoWidthMultiplier;
    double effectiveVideoHeight = effectiveVideoWidth * 9 / 16;

    return Center(
      child: Container(
        width: screenwdt,
        height: screenhgt,
        color: Colors.black,
        child: Stack(
          children: [
            // YouTube Player - Customizable Width
            if (_controller != null)
              Center(
                child: Container(
                  width: effectiveVideoWidth,
                  height: effectiveVideoHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: YoutubePlayer(
                      controller: _controller!,
                      showVideoProgressIndicator: false,
                      progressIndicatorColor: Colors.red,
                      bufferIndicator: Container(),
                      bottomActions: [],
                      topActions: [],
                      aspectRatio: 16 / 9,
      
                      onReady: () {
                        if (!_isPlayerReady && !_isDisposed) {
                          if (mounted) {
                            setState(() {
                              _isPlayerReady = true;
                              _isLoading = false;
                            });
                          }
      
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (!_isDisposed) {
                              _mainFocusNode.requestFocus();
                            }
                          });
      
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (_controller != null && mounted && !_isDisposed) {
                              _controller!.play();
                              // Log quality info after play
                              Future.delayed(const Duration(milliseconds: 1000), () {
                                _logCurrentQuality();
                              });
                            }
                          });
                        }
                      },
      
                      onEnded: (_) {
                        print('onEnded callback triggered');
                        if (_isDisposed || _isNavigating || _videoCompleted) return;
                        _completeVideo();
                      },
                    ),
                  ),
                ),
              ),
      
            // Loading indicator
            if (_isLoading || !_isPlayerReady)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.red,
                          strokeWidth: 6,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Loading Video...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Simple loading overlay for when controller is null
  Widget _buildCustomLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        width: screenwdt,
        height: screenhgt,
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 6,
              ),
              // SizedBox(height: 20),
              // Text(
              //   'Initializing Player...',
              //   style: TextStyle(
              //     color: Colors.white,
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}


