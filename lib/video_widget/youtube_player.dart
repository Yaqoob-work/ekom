// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
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
//   YoutubePlayerController? _introController;
//   late VideoData currentVideo;
//   int currentIndex = 0;
//   bool _isPlayerReady = false;
//   bool _isIntroPlayerReady = false;
//   String? _error;
//   bool _isLoading = true;
//   bool _isDisposed = false;

//   // Intro video control
//   bool _showIntroVideo = true;
//   bool _introCompleted = false;
//   final String _introVideoId = 'Z5duvxjIF7U'; // Fixed intro video ID
//    Duration _pendingSeekPosition = Duration.zero;

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
//   bool _isProgressFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     currentVideo = widget.videoData;
//     currentIndex = widget.playlist.indexOf(widget.videoData);

//     print('📱 App started - Quick setup mode with intro');

//     // Set full screen immediately
//     _setFullScreenMode();

//     // Start both players initialization
//     _initializeIntroPlayer();
//     _initializeMainPlayer();

//     // Auto-hide controls timer
//     _startHideControlsTimer();
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

//   void _initializeIntroPlayer() {
//     if (_isDisposed) return;

//     try {
//       print('🎬 Initializing intro player: $_introVideoId');

//       _introController = YoutubePlayerController(
//         initialVideoId: _introVideoId,
//         flags: const YoutubePlayerFlags(
//           mute: false,
//           autoPlay: true,
//           disableDragSeek: true,
//           loop: false,
//           isLive: false,
//           forceHD: false,
//           enableCaption: false,
//           controlsVisibleAtStart: false,
//           hideControls: true,
//           startAt: 0,
//           hideThumbnail: false,
//           useHybridComposition: false,
//         ),
//       );

//       _introController!.addListener(_introListener);

//       Future.delayed(const Duration(milliseconds: 300), () {
//         if (mounted && _introController != null && !_isDisposed) {
//           print('🎯 Loading intro video');
//           _introController!.load(_introVideoId);

//           Future.delayed(const Duration(milliseconds: 800), () {
//             if (mounted && _introController != null && !_isDisposed) {
//               print('🎬 Starting intro video');
//               _introController!.play();
//               if (mounted) {
//                 setState(() {
//                   _isIntroPlayerReady = true;
//                 });
//               }
//             }
//           });
//         }
//       });

//     } catch (e) {
//       print('❌ Intro Error: $e');
//       // If intro fails, skip to main video
//       _skipToMainVideo();
//     }
//   }

//   void _initializeMainPlayer() {
//     if (_isDisposed) return;

//     try {
//       String? videoId = YoutubePlayer.convertUrlToId(currentVideo.youtubeUrl);

//       print('🔧 TV Mode: Initializing main player for: $videoId');

//       if (videoId == null || videoId.isEmpty) {
//         if (mounted && !_isDisposed) {
//           setState(() {
//             _error = 'Invalid YouTube URL: ${currentVideo.youtubeUrl}';
//             _isLoading = false;
//           });
//         }
//         return;
//       }

//       // Main video controller - muted initially
//       _controller = YoutubePlayerController(
//         initialVideoId: videoId,
//         flags: const YoutubePlayerFlags(
//           mute: true, // Muted initially
//           autoPlay: false, // Don't auto play main video
//           disableDragSeek: false,
//           loop: false,
//           isLive: false,
//           forceHD: false,
//           enableCaption: false,
//           controlsVisibleAtStart: false,
//           hideControls: true,
//           startAt: 0,
//           hideThumbnail: true,
//           useHybridComposition: false,
//         ),
//       );

//       _controller!.addListener(_listener);

//       // Load main video but don't play until intro finishes
//       Future.delayed(const Duration(milliseconds: 500), () {
//         if (mounted && _controller != null && !_isDisposed) {
//           print('🎯 Loading main video (will not auto-play)');
//           _controller!.load(videoId);

//           if (mounted) {
//             setState(() {
//               _isPlayerReady = true;
//               _isLoading = false;
//             });
//           }
//         }
//       });

//     } catch (e) {
//       print('❌ Main Video Error: $e');
//       if (mounted && !_isDisposed) {
//         setState(() {
//           _error = 'Main Video Error: $e';
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _introListener() {
//     if (_introController != null && mounted && !_isDisposed && !_introCompleted) {
//       // Check if intro video ended
//       if (_introController!.value.playerState == PlayerState.ended) {
//         print('🏁 Intro video completed, switching to main video');
//         _skipToMainVideo();
//       }

//       // Also check by position - sometimes ended state doesn't trigger properly
//       final introPosition = _introController!.value.position;
//       final introDuration = _introController!.value.metaData.duration;
//       if (introDuration.inSeconds > 0 &&
//           introPosition.inSeconds >= introDuration.inSeconds - 1) {
//         print('🏁 Intro video near end by position, switching to main video');
//         _skipToMainVideo();
//       }
//     }
//   }

//   void _skipToMainVideo() {
//   if (_isDisposed || _introCompleted) return;

//   print('🔄 Switching from intro to main video');

//   // Get intro duration before disposing
//   Duration introDuration = Duration.zero;
//   if (_introController != null) {
//     introDuration = _introController!.value.position;
//     print('📍 Intro was at position: ${introDuration.inSeconds} seconds');

//     // Pause and dispose intro controller first
//     try {
//       _introController!.pause();
//       _introController!.dispose();
//     } catch (e) {
//       print('Error disposing intro controller: $e');
//     }
//     _introController = null;
//   }

//   // Update state to show main video
//   if (mounted) {
//     setState(() {
//       _showIntroVideo = false;
//       _introCompleted = true;
//     });
//   }

//   // Configure main video
//   if (_controller != null && _isPlayerReady) {
//     try {
//       // Unmute main video
//       _controller!.unMute();

//       // 🎯 NEW: Skip main video by intro duration
//       if (introDuration.inSeconds > 0) {
//         print('⏭️ Skipping main video by ${introDuration.inSeconds} seconds');
//         _controller!.seekTo(introDuration);
//       }

//       // Start playing main video from skipped position
//       _controller!.play();

//       // Set focus to play button after a delay
//       Future.delayed(const Duration(milliseconds: 1000), () {
//         if (!_isDisposed && mounted) {
//           _playPauseFocusNode.requestFocus();
//         }
//       });

//     } catch (e) {
//       print('Error configuring main video: $e');
//     }
//   } else {
//     print('⚠️ Main controller not ready yet, will seek when ready');
//     // Store the seek position for when controller becomes ready
//     _pendingSeekPosition = introDuration;
//   }
// }

//   // void _skipToMainVideo() {
//   //   if (_isDisposed || _introCompleted) return;

//   //   print('🔄 Switching from intro to main video');

//   //   // Get intro duration before disposing
//   //   Duration introDuration = Duration.zero;
//   //   if (_introController != null) {
//   //     introDuration = _introController!.value.position;
//   //     print('📍 Intro was at position: ${introDuration.inSeconds} seconds');

//   //     // Pause and dispose intro controller first
//   //     try {
//   //       _introController!.pause();
//   //       _introController!.dispose();
//   //     } catch (e) {
//   //       print('Error disposing intro controller: $e');
//   //     }
//   //     _introController = null;
//   //   }

//   //   // Update state to show main video
//   //   if (mounted) {
//   //     setState(() {
//   //       _showIntroVideo = false;
//   //       _introCompleted = true;
//   //     });
//   //   }

//   //   // Configure main video
//   //   if (_controller != null && _isPlayerReady) {
//   //     try {
//   //       // Unmute main video
//   //       _controller!.unMute();

//   //       // Start playing main video
//   //       _controller!.play();

//   //       // Set focus to play button after a delay
//   //       Future.delayed(const Duration(milliseconds: 1000), () {
//   //         if (!_isDisposed && mounted) {
//   //           _playPauseFocusNode.requestFocus();
//   //         }
//   //       });

//   //     } catch (e) {
//   //       print('Error configuring main video: $e');
//   //     }
//   //   } else {
//   //     print('⚠️ Main controller not ready yet, will unmute when ready');
//   //   }
//   // }

//   void _listener() {
//   if (_controller != null && mounted && !_isDisposed) {
//     if (_controller!.value.isReady && !_isPlayerReady) {
//       print('📡 Main Controller ready detected');
//       if (mounted) {
//         setState(() {
//           _isPlayerReady = true;
//         });
//       }

//       // If intro is already completed, unmute and play main video
//       if (_introCompleted) {
//         print('🔊 Unmuting main video as intro already completed');
//         _controller!.unMute();

//         // 🎯 NEW: Apply pending seek if exists
//         if (_pendingSeekPosition.inSeconds > 0) {
//           print('⏭️ Applying pending seek: ${_pendingSeekPosition.inSeconds} seconds');
//           _controller!.seekTo(_pendingSeekPosition);
//           _pendingSeekPosition = Duration.zero; // Clear after use
//         }

//         _controller!.play();
//       }
//     }

//     // Update position and duration only if main video is visible
//     if (mounted && !_showIntroVideo) {
//       setState(() {
//         _currentPosition = _controller!.value.position;
//         _totalDuration = _controller!.value.metaData.duration;
//         _isPlaying = _controller!.value.isPlaying;
//       });
//     }
//   }
// }

//   // void _listener() {
//   //   if (_controller != null && mounted && !_isDisposed) {
//   //     if (_controller!.value.isReady && !_isPlayerReady) {
//   //       print('📡 Main Controller ready detected');
//   //       if (mounted) {
//   //         setState(() {
//   //           _isPlayerReady = true;
//   //         });
//   //       }

//   //       // If intro is already completed, unmute and play main video
//   //       if (_introCompleted) {
//   //         print('🔊 Unmuting main video as intro already completed');
//   //         _controller!.unMute();
//   //         _controller!.play();
//   //       }
//   //     }

//   //     // Update position and duration only if main video is visible
//   //     if (mounted && !_showIntroVideo) {
//   //       setState(() {
//   //         _currentPosition = _controller!.value.position;
//   //         _totalDuration = _controller!.value.metaData.duration;
//   //         _isPlaying = _controller!.value.isPlaying;
//   //       });
//   //     }
//   //   }
//   // }

//   void _startHideControlsTimer() {
//     if (_isDisposed) return;

//     _hideControlsTimer?.cancel();
//     _hideControlsTimer = Timer(const Duration(seconds: 4), () {
//       if (mounted && _showControls && !_isDisposed) {
//         setState(() {
//           _showControls = false;
//         });
//       }
//     });
//   }

//   void _showControlsTemporarily() {
//     if (_isDisposed) return;

//     if (mounted) {
//       setState(() {
//         _showControls = true;
//       });
//     }
//     _startHideControlsTimer();
//   }

//   void _togglePlayPause() {
//     // Only allow control after intro is completed
//     if (!_introCompleted || _controller == null || !_isPlayerReady || _isDisposed) {
//       return;
//     }

//     if (_isPlaying) {
//       _controller!.pause();
//       print('⏸️ Video paused');
//     } else {
//       _controller!.play();
//       print('▶️ Video playing');
//     }
//     _showControlsTemporarily();
//   }

//   void _seekVideo(bool forward) {
//     // Only allow seeking after intro is completed
//     if (!_introCompleted || _controller == null || !_isPlayerReady || _totalDuration.inSeconds <= 0 || _isDisposed) {
//       return;
//     }

//     final seekAmount = (_totalDuration.inSeconds / 100).round().clamp(5, 30);

//     _seekTimer?.cancel();

//     if (forward) {
//       _pendingSeekSeconds += seekAmount;
//       print('⏩ Adding forward seek: +${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
//     } else {
//       _pendingSeekSeconds -= seekAmount;
//       print('⏪ Adding backward seek: -${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
//     }

//     final currentSeconds = _currentPosition.inSeconds;
//     final targetSeconds = (currentSeconds + _pendingSeekSeconds).clamp(0, _totalDuration.inSeconds);
//     _targetSeekPosition = Duration(seconds: targetSeconds);

//     if (mounted && !_isDisposed) {
//       setState(() {
//         _isSeeking = true;
//       });
//     }

//     _seekTimer = Timer(const Duration(milliseconds: 1000), () {
//       _executeSeek();
//     });

//     _showControlsTemporarily();
//   }

//   void _executeSeek() {
//     if (_controller != null && _isPlayerReady && !_isDisposed && _pendingSeekSeconds != 0 && _introCompleted) {
//       final currentSeconds = _currentPosition.inSeconds;
//       final newPosition = (currentSeconds + _pendingSeekSeconds).clamp(0, _totalDuration.inSeconds);

//       print('🎯 Executing accumulated seek: ${_pendingSeekSeconds}s to position ${newPosition}s');

//       _controller!.seekTo(Duration(seconds: newPosition));

//       _pendingSeekSeconds = 0;
//       _targetSeekPosition = Duration.zero;

//       if (mounted && !_isDisposed) {
//         setState(() {
//           _isSeeking = false;
//         });
//       }
//     }
//   }

//   bool _handleKeyEvent(RawKeyEvent event) {
//     if (_isDisposed) return false;

//     if (event is RawKeyDownEvent) {
//       switch (event.logicalKey) {
//         case LogicalKeyboardKey.select:
//         case LogicalKeyboardKey.enter:
//         case LogicalKeyboardKey.space:
//           if (_showIntroVideo) {
//             // Skip intro on any key press
//             _skipToMainVideo();
//             return true;
//           } else if (_playPauseFocusNode.hasFocus) {
//             _togglePlayPause();
//             return true;
//           } else if (_progressFocusNode.hasFocus) {
//             _togglePlayPause();
//             return true;
//           }
//           break;
//         case LogicalKeyboardKey.arrowLeft:
//           if (!_showIntroVideo && _progressFocusNode.hasFocus) {
//             _seekVideo(false);
//             return true;
//           }
//           break;
//         case LogicalKeyboardKey.arrowRight:
//           if (!_showIntroVideo && _progressFocusNode.hasFocus) {
//             _seekVideo(true);
//             return true;
//           }
//           break;
//         case LogicalKeyboardKey.arrowUp:
//         case LogicalKeyboardKey.arrowDown:
//           if (!_showIntroVideo) {
//             if (_playPauseFocusNode.hasFocus) {
//               _progressFocusNode.requestFocus();
//               _showControlsTemporarily();
//               return true;
//             } else if (_progressFocusNode.hasFocus) {
//               _playPauseFocusNode.requestFocus();
//               _showControlsTemporarily();
//               return true;
//             }
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
//           _showIntroVideo = true;
//           _introCompleted = false;
//         });
//       }

//       // Dispose current controllers
//       _controller?.dispose();
//       _introController?.dispose();

//       // Re-initialize for next video
//       _initializeIntroPlayer();
//       _initializeMainPlayer();
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
//           _showIntroVideo = true;
//           _introCompleted = false;
//         });
//       }

//       // Dispose current controllers
//       _controller?.dispose();
//       _introController?.dispose();

//       // Re-initialize for previous video
//       _initializeIntroPlayer();
//       _initializeMainPlayer();
//     } else {
//       _showError('First video in playlist');
//     }
//   }

//   Future<bool> _onWillPop() async {
//     if (_isDisposed) return true;

//     try {
//       print('🔙 Back button pressed - cleaning up...');

//       _isDisposed = true;

//       _hideControlsTimer?.cancel();
//       _seekTimer?.cancel();

//       // Dispose both controllers
//       if (_controller != null) {
//         try {
//           if (_controller!.value.isPlaying) {
//             _controller!.pause();
//           }
//           _controller!.dispose();
//           _controller = null;
//         } catch (e) {
//           print('Error disposing main controller: $e');
//         }
//       }

//       if (_introController != null) {
//         try {
//           if (_introController!.value.isPlaying) {
//             _introController!.pause();
//           }
//           _introController!.dispose();
//           _introController = null;
//         } catch (e) {
//           print('Error disposing intro controller: $e');
//         }
//       }

//       try {
//         await SystemChrome.setEnabledSystemUIMode(
//           SystemUiMode.manual,
//           overlays: SystemUiOverlay.values
//         );

//         await SystemChrome.setPreferredOrientations([
//           DeviceOrientation.portraitUp,
//           DeviceOrientation.portraitDown,
//           DeviceOrientation.landscapeLeft,
//           DeviceOrientation.landscapeRight,
//         ]);
//       } catch (e) {
//         print('Error restoring system UI: $e');
//       }

//       return true;

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
//     _introController?.pause();
//     super.deactivate();
//   }

//   @override
//   void dispose() {
//     print('🗑️ Disposing YouTube player screen...');

//     try {
//       _isDisposed = true;

//       _hideControlsTimer?.cancel();
//       _seekTimer?.cancel();

//       if (_playPauseFocusNode.hasListeners) {
//         _playPauseFocusNode.dispose();
//       }
//       if (_progressFocusNode.hasListeners) {
//         _progressFocusNode.dispose();
//       }

//       if (_controller != null) {
//         try {
//           _controller!.pause();
//           _controller!.dispose();
//           _controller = null;
//         } catch (e) {
//           print('Error disposing main controller in dispose: $e');
//         }
//       }

//       if (_introController != null) {
//         try {
//           _introController!.pause();
//           _introController!.dispose();
//           _introController = null;
//         } catch (e) {
//           print('Error disposing intro controller in dispose: $e');
//         }
//       }

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
//     if (_isDisposed) {
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     return RawKeyboardListener(
//       focusNode: FocusNode(),
//       autofocus: true,
//       onKey: _handleKeyEvent,
//       child: WillPopScope(
//         onWillPop: _onWillPop,
//         child: Scaffold(
//           body: GestureDetector(
//             onTap: () {
//               if (_showIntroVideo) {
//                 _skipToMainVideo();
//               } else {
//                 _showControlsTemporarily();
//               }
//             },
//             behavior: HitTestBehavior.opaque,
//             child: Stack(
//               children: [
//                 // Main video player (background layer)
//                 Positioned.fill(
//                   child: Container(
//                     color: Colors.black,
//                     child: _buildMainVideoPlayer(),
//                   ),
//                 ),

//                 // Intro video player (foreground overlay during intro)
//                 if (_showIntroVideo)
//                   Positioned.fill(
//                     child: Container(
//                       color: Colors.black, // Solid background
//                       child: _buildIntroVideoPlayer(),
//                     ),
//                   ),

//                 // Custom Controls Overlay (only show after intro)
//                 if (_showControls && !_showIntroVideo) _buildControlsOverlay(),

//                 // Skip intro button
//                 if (_showIntroVideo && _isIntroPlayerReady)
//                   Positioned(
//                     bottom: 30,
//                     right: 30,
//                     child: GestureDetector(
//                       onTap: _skipToMainVideo,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.7),
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(color: Colors.white.withOpacity(0.5)),
//                         ),
//                         child: const Text(
//                           'Skip Intro →',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                 // Invisible back area
//                 Positioned(
//                   top: 0,
//                   left: 0,
//                   width: 100,
//                   height: 100,
//                   child: GestureDetector(
//                     onTap: () {
//                       if (!_isDisposed) {
//                         Navigator.of(context).pop();
//                       }
//                     },
//                     child: Container(
//                       color: Colors.transparent,
//                       child: const SizedBox.expand(),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildIntroVideoPlayer() {
//     if (_introController == null) {
//       return Container(
//         color: Colors.black,
//         child: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(color: Colors.red),
//               SizedBox(height: 20),
//               Text(
//                 'Loading Intro...',
//                 style: TextStyle(color: Colors.white, fontSize: 18)
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return YoutubePlayer(
//       controller: _introController!,
//       showVideoProgressIndicator: false,
//       progressIndicatorColor: Colors.red,
//       width: double.infinity,
//       aspectRatio: 16 / 9,
//       bufferIndicator: Container(
//         color: Colors.black,
//         child: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(color: Colors.red),
//               SizedBox(height: 10),
//               Text('Loading Intro...', style: TextStyle(color: Colors.white)),
//             ],
//           ),
//         ),
//       ),
//       onReady: () {
//         print('🎬 Intro Player Ready');
//         if (!_isIntroPlayerReady && !_isDisposed) {
//           if (mounted) {
//             setState(() => _isIntroPlayerReady = true);
//           }

//           Future.delayed(const Duration(milliseconds: 100), () {
//             if (_introController != null && mounted && !_isDisposed) {
//               _introController!.play();
//               print('🎬 Intro video started');
//             }
//           });
//         }
//       },
//       onEnded: (_) {
//         if (!_isDisposed && !_introCompleted) {
//           _skipToMainVideo();
//         }
//       },
//     );
//   }

//   Widget _buildMainVideoPlayer() {
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
//                     _initializeMainPlayer();
//                   }
//                 },
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (_controller == null) {
//       return Container(
//         color: Colors.black,
//         child: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(color: Colors.red),
//               SizedBox(height: 20),
//               Text(
//                 'Loading Main Video...',
//                 style: TextStyle(color: Colors.white, fontSize: 18)
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return YoutubePlayer(
//       controller: _controller!,
//       showVideoProgressIndicator: false,
//       progressIndicatorColor: Colors.red,
//       width: double.infinity,
//       aspectRatio: 16 / 9,
//       bufferIndicator: Container(
//         color: Colors.black,
//         child: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(color: Colors.red),
//               SizedBox(height: 10),
//               Text('Buffering Main Video...', style: TextStyle(color: Colors.white)),
//             ],
//           ),
//         ),
//       ),
//       onReady: () {
//         print('📺 Main TV Player Ready');
//         if (!_isPlayerReady && !_isDisposed) {
//           if (mounted) {
//             setState(() => _isPlayerReady = true);
//           }

//           // If intro already completed, focus and play
//           if (_introCompleted) {
//             Future.delayed(const Duration(milliseconds: 500), () {
//               if (!_isDisposed && mounted) {
//                 _controller!.unMute();
//                 _controller!.play();
//                 _playPauseFocusNode.requestFocus();
//               }
//             });
//           }
//         }
//       },
//       onEnded: (_) {
//         if (_isDisposed) return;

//         if (widget.playlist.length == 1 || currentIndex >= widget.playlist.length - 1) {
//           print('🏠 Video ended - returning to home page');
//           Future.delayed(const Duration(milliseconds: 500), () {
//             if (mounted && !_isDisposed) {
//               Navigator.of(context).pop();
//             }
//           });
//         } else {
//           _playNextVideo();
//         }
//       },
//     );
//   }

//   Widget _buildControlsOverlay() {
//     return Container(
//       color: Colors.black.withOpacity(0.3),
//       child: Column(
//         children: [
//           // Top area - playlist info
//           if (widget.playlist.length > 1)
//             Container(
//               padding: const EdgeInsets.all(16),
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.6),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Text(
//                     '${currentIndex + 1}/${widget.playlist.length}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//           const Spacer(),

//           // Bottom Progress Bar with Play/Pause Button
//           Container(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 // Progress Bar with Play/Pause Button
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     // Progress Bar Section
//                     Expanded(
//                       child: Column(
//                         children: [
//                           // Progress Bar
//                           Focus(
//                             focusNode: _progressFocusNode,
//                             onFocusChange: (focused) {
//                               if (mounted && !_isDisposed) {
//                                 setState(() {
//                                   _isProgressFocused = focused;
//                                 });
//                                 if (focused) _showControlsTemporarily();
//                               }
//                             },
//                             onKey: (node, event) {
//                               if (event is RawKeyDownEvent) {
//                                 if (event.logicalKey == LogicalKeyboardKey.escape) {
//                                   _playPauseFocusNode.requestFocus();
//                                   return KeyEventResult.handled;
//                                 }
//                               }
//                               return KeyEventResult.ignored;
//                             },
//                             child: Builder(
//                               builder: (context) {
//                                 final isFocused = Focus.of(context).hasFocus;
//                                 return Container(
//                                   height: 8,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(4),
//                                     border: isFocused ? Border.all(color: Colors.white, width: 2) : null,
//                                   ),
//                                   child: Stack(
//                                     children: [
//                                       // Main progress bar
//                                       LinearProgressIndicator(
//                                         value: _totalDuration.inSeconds > 0
//                                             ? _currentPosition.inSeconds / _totalDuration.inSeconds
//                                             : 0.0,
//                                         backgroundColor: Colors.white.withOpacity(0.3),
//                                         valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
//                                       ),

//                                       // Seeking preview indicator
//                                       if (_isSeeking && _totalDuration.inSeconds > 0)
//                                         LinearProgressIndicator(
//                                           value: _targetSeekPosition.inSeconds / _totalDuration.inSeconds,
//                                           backgroundColor: Colors.transparent,
//                                           valueColor: AlwaysStoppedAnimation<Color>(
//                                             Colors.yellow.withOpacity(0.8)
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),

//                           const SizedBox(height: 8),

//                           // Time indicators and help text
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 _isSeeking
//                                     ? _formatDuration(_targetSeekPosition)
//                                     : _formatDuration(_currentPosition),
//                                 style: TextStyle(
//                                   color: _isSeeking ? Colors.yellow : Colors.white,
//                                   fontSize: 14,
//                                   fontWeight: _isSeeking ? FontWeight.bold : FontWeight.normal,
//                                 ),
//                               ),
//                               if (_isProgressFocused)
//                                 Column(
//                                   children: [
//                                     const Text(
//                                       '← → Seek | ↑↓ Navigate',
//                                       style: TextStyle(color: Colors.white70, fontSize: 12),
//                                     ),
//                                     if (_isSeeking)
//                                       Text(
//                                         '${_pendingSeekSeconds > 0 ? "+" : ""}${_pendingSeekSeconds}s',
//                                         style: const TextStyle(color: Colors.yellow, fontSize: 12, fontWeight: FontWeight.bold),
//                                       ),
//                                   ],
//                                 ),
//                               Text(
//                                 _formatDuration(_totalDuration),
//                                 style: const TextStyle(color: Colors.white, fontSize: 14),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(width: 16),

//                     // Play/Pause Button
//                     Focus(
//                       focusNode: _playPauseFocusNode,
//                       autofocus: true,
//                       onFocusChange: (focused) {
//                         if (focused && !_isDisposed) _showControlsTemporarily();
//                       },
//                       child: Builder(
//                         builder: (context) {
//                           final isFocused = Focus.of(context).hasFocus;
//                           return GestureDetector(
//                             onTap: _togglePlayPause,
//                             child: Container(
//                               width: 60,
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 color: Colors.black.withOpacity(0.7),
//                                 borderRadius: BorderRadius.circular(30),
//                                 border: isFocused ? Border.all(color: Colors.white, width: 3) : null,
//                               ),
//                               child: Icon(
//                                 _isPlaying ? Icons.pause : Icons.play_arrow,
//                                 color: Colors.white,
//                                 size: 36,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }








// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
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

//   // Splash screen control
//   bool _showSplashScreen = true;
//   Timer? _splashTimer;
//   Timer? _splashUpdateTimer; // For updating countdown display
//   DateTime? _splashStartTime; // Track when splash started

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

//   // Focus nodes for TV remote - FIXED: Always keep them active
//   final FocusNode _playPauseFocusNode = FocusNode();
//   final FocusNode _progressFocusNode = FocusNode();
//   final FocusNode _mainFocusNode = FocusNode(); // Main invisible focus node
//   bool _isProgressFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     currentVideo = widget.videoData;
//     currentIndex = widget.playlist.indexOf(widget.videoData);

//     print('📱 App started - Quick setup mode');

//     // Set full screen immediately
//     _setFullScreenMode();

//     // Start player initialization immediately
//     _initializePlayer();

//     // Start 25 second splash timer
//     _startSplashTimer();

//     // FIXED: Request focus on main node initially
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _mainFocusNode.requestFocus();
//       // Show controls initially for testing (will be hidden during splash)
//       if (!_showSplashScreen) {
//         _showControlsTemporarily();
//       }
//     });
//   }



//   void _startSplashTimer() {
//   _splashStartTime = DateTime.now(); // Record start time
//   print('🎬 Splash screen started - will hide after exactly 25 seconds');

//   // Timer to update countdown display every second
//   _splashUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//     if (mounted && _showSplashScreen && !_isDisposed) {
//       setState(() {
//         // This will trigger rebuild and update countdown
//       });
//       print('⏰ Splash countdown: ${_getRemainingSeconds()} seconds remaining');
//     } else {
//       timer.cancel();
//     }
//   });

//   // Main timer - EXACTLY 25 seconds
//   _splashTimer = Timer(const Duration(seconds: 25), () {
//     if (mounted && !_isDisposed && _showSplashScreen) {
//       print('🎬 EXACTLY 25 seconds complete - removing splash and enabling sound');
//       _splashUpdateTimer?.cancel();
//       setState(() {
//         _showSplashScreen = false;
//       });

//       // // Enable sound after splash screen - video continues seamlessly
//       // if (_controller != null && _isPlayerReady) {
//       //   _controller!.unMute();
//       //   print('🔊 Sound enabled - video continues playing from current position');
//       // }

//       // Show controls automatically after splash
//       Future.delayed(const Duration(milliseconds: 500), () {
//         if (mounted && !_isDisposed) {
//           _showControlsTemporarily();
//           print('🎮 Controls are now available');
//         }
//       });
//     }
//   });
// }


//   // void _startSplashTimer() {
//   //   _splashStartTime = DateTime.now(); // Record start time
//   //   print('🎬 Splash screen started - will hide after exactly 25 seconds');

//   //   // Timer to update countdown display every second
//   //   _splashUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//   //     if (mounted && _showSplashScreen && !_isDisposed) {
//   //       setState(() {
//   //         // This will trigger rebuild and update countdown
//   //       });
//   //       print('⏰ Splash countdown: ${_getRemainingSeconds()} seconds remaining');
//   //     } else {
//   //       timer.cancel();
//   //     }
//   //   });

//   //   // Main timer - EXACTLY 25 seconds
//   //   _splashTimer = Timer(const Duration(seconds: 25), () {
//   //     if (mounted && !_isDisposed && _showSplashScreen) {
//   //       print('🎬 EXACTLY 25 seconds complete - removing splash and enabling sound');

//   //       // Cancel update timer
//   //       _splashUpdateTimer?.cancel();

//   //       setState(() {
//   //         _showSplashScreen = false;
//   //       });

//   //       // Enable sound after splash screen - video continues seamlessly
//   //       if (_controller != null && _isPlayerReady) {
//   //         _controller!.unMute();
//   //         print('🔊 Sound enabled - video continues playing from current position');
//   //       }

//   //       // Show controls automatically after splash
//   //       Future.delayed(const Duration(milliseconds: 500), () {
//   //         if (mounted && !_isDisposed) {
//   //           _showControlsTemporarily();
//   //           print('🎮 Controls are now available');
//   //         }
//   //       });
//   //     }
//   //   });
//   // }

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

//       // TV-specific controller configuration - MUTED initially
//       _controller = YoutubePlayerController(
//         initialVideoId: videoId,
//         flags: const YoutubePlayerFlags(
//           mute: false, // Start muted during splash screen
//           autoPlay: true,
//           disableDragSeek: false,
//           loop: false,
//           isLive: false,
//           forceHD: false,
//           enableCaption: false,
//           controlsVisibleAtStart: false,
//           hideControls: false,
//           startAt: 0,
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
//               print('🎬 TV: First play attempt (muted)');
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
//         print('📡 Controller ready detected');
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
//           _isPlaying = _controller!.value.isPlaying;
//         });
//       }
//     }
//   }

//   void _startHideControlsTimer() {
//     if (_isDisposed || _showSplashScreen) return; // Don't start timer during splash

//     _hideControlsTimer?.cancel();
//     _hideControlsTimer = Timer(const Duration(seconds: 15), () { // Increased to 5 seconds
//       if (mounted && _showControls && !_isDisposed && !_showSplashScreen) {
//         setState(() {
//           _showControls = false;
//         });
//         // FIXED: When controls hide, focus goes back to main invisible node
//         _mainFocusNode.requestFocus();
//       }
//     });
//   }

//   void _showControlsTemporarily() {
//     if (_isDisposed || _showSplashScreen) return; // Don't show controls during splash

//     if (mounted) {
//       setState(() {
//         _showControls = true;
//       });
//     }

//     // FIXED: When controls show, focus on play/pause button
//     _playPauseFocusNode.requestFocus();
//     _startHideControlsTimer();
//   }

//   void _togglePlayPause() {
//     if (_controller != null && _isPlayerReady && !_isDisposed) {
//       if (_isPlaying) {
//         _controller!.pause();
//         print('⏸️ Video paused');
//       } else {
//         _controller!.play();
//         print('▶️ Video playing');
//       }
//     }
//     _showControlsTemporarily();
//   }

//   void _seekVideo(bool forward) {
//     if (_controller != null && _isPlayerReady && _totalDuration.inSeconds > 0 && !_isDisposed) {
//       final seekAmount = (_totalDuration.inSeconds / 100).round().clamp(5, 30); // 5-30 seconds

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

//       // Calculate target position for preview
//       final currentSeconds = _currentPosition.inSeconds;
//       final targetSeconds = (currentSeconds + _pendingSeekSeconds).clamp(0, _totalDuration.inSeconds);
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
//       final currentSeconds = _currentPosition.inSeconds;
//       final newPosition = (currentSeconds + _pendingSeekSeconds).clamp(0, _totalDuration.inSeconds);

//       print('🎯 Executing accumulated seek: ${_pendingSeekSeconds}s to position ${newPosition}s');

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

//   // FIXED: Handle keyboard events for TV remote - COMPLETELY BLOCK during splash screen
//   bool _handleKeyEvent(RawKeyEvent event) {
//     if (_isDisposed) return false;

//     // COMPLETELY BLOCK all key events during splash screen except back/escape
//     if (_showSplashScreen) {
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
//             // Block ALL other keys during splash - no video control allowed
//             print('🚫 Key blocked during splash screen: ${event.logicalKey}');
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
//         });
//       }
//       _controller?.dispose();
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
//         });
//       }
//       _controller?.dispose();
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
//     super.deactivate();
//   }

//   @override
//   void dispose() {
//     print('🗑️ Disposing YouTube player screen...');

//     try {
//       // Mark as disposed
//       _isDisposed = true;

//       // Cancel timers
//       _hideControlsTimer?.cancel();
//       _seekTimer?.cancel();
//       _splashTimer?.cancel();
//       _splashUpdateTimer?.cancel();

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
//       focusNode: _mainFocusNode, // FIXED: Use main focus node
//       autofocus: true,
//       onKey: _handleKeyEvent,
//       child: WillPopScope(
//         onWillPop: _onWillPop,
//         child: Scaffold(
//           body: GestureDetector(
//             onTap: _showSplashScreen ? null : _showControlsTemporarily, // Disable tap during splash
//             behavior: HitTestBehavior.opaque,
//             child: Stack(
//               children: [
//                 // Full screen video player (always present and playing in background)
//                 _buildVideoPlayer(),

//                 // Splash Screen Overlay - COMPLETELY COVERS video for 25 seconds
//                 if (_showSplashScreen)
//                   _buildSplashScreen(),

//                 // Custom Controls Overlay - Only show if splash is completely gone
//                 if (!_showSplashScreen)
//                   _buildControlsOverlay(),

//                 // Invisible back area - Only active when splash is not showing
//                 if (!_showSplashScreen)
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

//   Widget _buildSplashScreen() {
//     return Positioned.fill(
//       child: Container(
//         width: double.infinity,
//         height: double.infinity,
//         color: Colors.black, // Solid black background to completely hide video
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Yahan aap apni image add kar sakte hain
//               // Example:
//               Image.asset(
//                 'assets/videosplace.webp',
//                 width: screenwdt,
//                 height: screenhgt,
//               ),

//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper methods for splash countdown
//   double _getSplashProgress() {
//     if (_splashStartTime == null) return 0.0;

//     final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
//     final progress = elapsed / 25.0; // 25 seconds total
//     return progress.clamp(0.0, 1.0);
//   }

//   int _getRemainingSeconds() {
//     if (_splashStartTime == null) return 25;

//     final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
//     final remaining = 25 - elapsed;
//     return remaining.clamp(0, 25);
//   }

//   Widget _buildControlsOverlay() {
//     return Positioned.fill(
//       child: Stack(
//         children: [
//           // FIXED: Visible controls overlay
//           if (_showControls)
//             Container(
//               color: Colors.black.withOpacity(0.3),
//               child: Column(
//                 children: [
//                   // Top area - playlist info
//                   if (widget.playlist.length > 1)
//                     SafeArea(
//                       child: Container(
//                         padding: const EdgeInsets.all(16),
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

//                                 // Time indicators and help text
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
//                                       _formatDuration(_totalDuration),
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

//           // FIXED: Invisible overlay for focus management when controls are hidden
//           if (!_showControls)
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
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
//         color: Colors.transparent,
//         child: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(color: Colors.red),
//               SizedBox(height: 20),
//               Text(
//                 '',
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

//             // TV video surface activation - Start playing immediately but muted
//             Future.delayed(const Duration(milliseconds: 100), () {
//               if (_controller != null && mounted && !_isDisposed) {
//                 _controller!.play();
//                 print('🎬 TV: Video started playing (muted during splash)');
//               }
//             });
//           }
//         },
//         onEnded: (_) {
//           if (_isDisposed) return;

//           // // Single video या last video complete होने पर base page पर जाओ
//           // if (widget.playlist.length == 1 || currentIndex >= widget.playlist.length - 1) {
//           //   print('🏠 Video ended - returning to home page');
//           //   Future.delayed(const Duration(milliseconds: 500), () {
//           //     if (mounted && !_isDisposed) {
//           //       Navigator.of(context).pop();
//           //     }
//           //   });
//           // } else {
//           //   // Playlist में next video play करो
//           //   _playNextVideo();
//           // }
//         },
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
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

// class _YouTubePlayerScreenState extends State<YouTubePlayerScreen>
//     with TickerProviderStateMixin {
//   YoutubePlayerController? _controller;
//   late VideoData currentVideo;
//   int currentIndex = 0;
//   bool _isPlayerReady = false;
//   String? _error;
//   bool _isLoading = true;
//   bool _isDisposed = false;

//   // FADE ANIMATION CONTROLLERS
//   late AnimationController _startFadeController;
//   late AnimationController _endFadeController;
//   late Animation<double> _startFadeAnimation;
//   late Animation<double> _endFadeAnimation;
  
//   // Timers for fade effects
//   Timer? _startFadeTimer;
//   Timer? _endFadeTimer;
//   bool _isStartFadeActive = true; // Start with black overlay
//   bool _isEndFadeActive = false;
//   bool _fadeCompletionBlocked = false; // New flag to prevent early fade completion

//   // Control states
//   bool _showControls = false;
//   bool _isPlaying = false;
//   Duration _currentPosition = Duration.zero;
//   Duration _totalDuration = Duration.zero;
//   Timer? _hideControlsTimer;

//   // Progress bar display control
//   bool _showProgressBar = false;
//   Timer? _progressBarTimer;

//   // Progressive seeking states
//   Timer? _seekTimer;
//   int _pendingSeekSeconds = 0;
//   Duration _targetSeekPosition = Duration.zero;
//   bool _isSeeking = false;

//   // Buffering states
//   bool _isBuffering = false;
//   Timer? _bufferingTimer;
//   double _bufferProgress = 0.0;

//   // Focus nodes for TV remote
//   final FocusNode _playPauseFocusNode = FocusNode();
//   final FocusNode _progressFocusNode = FocusNode();
//   final FocusNode _mainFocusNode = FocusNode();
//   bool _isProgressFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     currentVideo = widget.videoData;
//     currentIndex = widget.playlist.indexOf(widget.videoData);

//     // Initialize fade animation controllers
//     _initializeFadeAnimations();

//     print('📱 App started - Video with fade transitions');

//     // Set full screen immediately
//     _setFullScreenMode();

//     // Start player initialization immediately
//     _initializePlayer();

//     // Start fade effects
//     _startInitialFadeEffect();

//     // Request focus on main node initially
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _mainFocusNode.requestFocus();
//     });
//   }

//   void _initializeFadeAnimations() {
//     // Start fade animation (30 seconds from black to transparent)
//     _startFadeController = AnimationController(
//       duration: const Duration(seconds: 30), // Full 30 seconds
//       vsync: this,
//     );
//     _startFadeAnimation = Tween<double>(
//       begin: 1.0, // Fully opaque (black)
//       end: 0.0,   // Fully transparent
//     ).animate(CurvedAnimation(
//       parent: _startFadeController,
//       curve: Curves.easeInOut,
//     ));

//     // End fade animation (15 seconds from transparent to black)
//     _endFadeController = AnimationController(
//       duration: const Duration(seconds: 25),
//       vsync: this,
//     );
//     _endFadeAnimation = Tween<double>(
//       begin: 0.0, // Fully transparent
//       end: 1.0,   // Fully opaque (black)
//     ).animate(CurvedAnimation(
//       parent: _endFadeController,
//       curve: Curves.easeInOut,
//     ));

//     // Listen to animation changes
//     _startFadeAnimation.addListener(() {
//       if (mounted && !_isDisposed) {
//         setState(() {});
//       }
//     });

//     _endFadeAnimation.addListener(() {
//       if (mounted && !_isDisposed) {
//         setState(() {});
//       }
//     });

//     // Listen for animation completion - ONLY after full 30 seconds
//     _startFadeController.addStatusListener((status) {
//       if (status == AnimationStatus.completed && !_fadeCompletionBlocked) {
//         print('🎬 Start fade complete after FULL 30 seconds - enabling sound and controls');
//         _isStartFadeActive = false;
        
//         // Enable sound after start fade
//         if (_controller != null && _isPlayerReady) {
//           _controller!.unMute();
//           print('🔊 Sound enabled - video continues playing');
//         }

//         // Show controls after fade completes
//         Future.delayed(const Duration(milliseconds: 500), () {
//           if (mounted && !_isDisposed && !_isStartFadeActive && !_isEndFadeActive) {
//             print('🎮 Start fade finished - showing controls');
//             setState(() {
//               _showControls = true;
//               _showProgressBar = false;
//             });
//             _playPauseFocusNode.requestFocus();
//             _startHideControlsTimer();
//           }
//         });
//       }
//     });
//   }

//   void _startInitialFadeEffect() {
//     print('🎬 Starting initial fade from black to transparent (FULL 30 seconds - no early cancellation)');
//     _isStartFadeActive = true;
//     _fadeCompletionBlocked = false;
    
//     // Start the fade animation
//     _startFadeController.forward();
    
//     // Set a timer to ensure minimum 30 seconds
//     _startFadeTimer = Timer(const Duration(seconds: 30), () {
//       print('🎬 30 second minimum timer completed');
//       _fadeCompletionBlocked = false;
//     });
//   }

//   void _checkForEndFadeEffect() {
//     if (_totalDuration.inSeconds > 0 && _currentPosition.inSeconds > 0) {
//       final remainingSeconds = _totalDuration.inSeconds - _currentPosition.inSeconds;

//       // Start end fade in last 15 seconds
//       if (remainingSeconds <= 15 && !_isEndFadeActive && !_isStartFadeActive) {
//         print('🎬 Last 15 seconds - starting end fade to black');
//         setState(() {
//           _isEndFadeActive = true;
//           _showControls = false;
//           _showProgressBar = false;
//         });
//         _endFadeController.forward();
//       }
//       // Reset end fade if we seek back (not in last 15 seconds anymore)
//       else if (remainingSeconds > 15 && _isEndFadeActive) {
//         print('🎬 Not in last 15 seconds anymore - resetting end fade');
//         setState(() {
//           _isEndFadeActive = false;
//         });
//         _endFadeController.reset();
//       }
//     }
//   }

//   void _startBuffering() {
//     if (_isBuffering || _isDisposed) return;
    
//     print('📡 Starting buffering animation');
//     setState(() {
//       _isBuffering = true;
//       _bufferProgress = 0.0;
//     });

//     _bufferingTimer?.cancel();
//     _bufferingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
//       if (!mounted || _isDisposed) {
//         timer.cancel();
//         return;
//       }

//       setState(() {
//         _bufferProgress += 0.02; // Increase by 2% every 100ms
//         if (_bufferProgress >= 1.0) {
//           _bufferProgress = 0.0; // Reset for continuous animation
//         }
//       });
//     });

//     // Auto-stop buffering after maximum 10 seconds if not stopped manually
//     Timer(const Duration(seconds: 10), () {
//       _stopBuffering();
//     });
//   }

//   void _stopBuffering() {
//     if (!_isBuffering || _isDisposed) return;
    
//     print('📡 Stopping buffering animation');
//     _bufferingTimer?.cancel();
//     if (mounted) {
//       setState(() {
//         _isBuffering = false;
//         _bufferProgress = 0.0;
//       });
//     }
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

//       // Start buffering animation
//       _startBuffering();

//       _controller = YoutubePlayerController(
//         initialVideoId: videoId,
//         flags: const YoutubePlayerFlags(
//           mute: true, // Start muted during initial fade
//           autoPlay: true,
//           disableDragSeek: false,
//           loop: false,
//           isLive: false,
//           forceHD: false,
//           enableCaption: false,
//           controlsVisibleAtStart: true,
//           hideControls: false,
//           startAt: 0,
//           hideThumbnail: false,
//           useHybridComposition: false,
//           showLiveFullscreenButton: false,
//         ),
//       );

//       _controller!.addListener(_listener);

//       if (mounted && _controller != null && !_isDisposed) {
//         print('🎯 TV: Loading video immediately');
//         _controller!.load(videoId);
        
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//             _isPlayerReady = true;
//             _isPlaying = true;
//           });
//         }

//         Future.delayed(const Duration(milliseconds: 500), () {
//           if (mounted && _controller != null && !_isDisposed) {
//             print('🎬 TV: Starting video play (muted initially)');
//             _controller!.play();
//             // Stop buffering when video starts playing
//             _stopBuffering();
//           }
//         });
//       }
//     } catch (e) {
//       print('❌ TV Error: $e');
//       _stopBuffering();
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
//       final playerState = _controller!.value;
      
//       // Handle buffering states
//       if (playerState.playerState == PlayerState.buffering && !_isBuffering) {
//         _startBuffering();
//       } else if (playerState.playerState != PlayerState.buffering && _isBuffering) {
//         _stopBuffering();
//       }
      
//       if (_controller!.value.isReady && !_isPlayerReady) {
//         print('📡 Controller ready detected');
//         _controller!.play();
//         _stopBuffering(); // Stop buffering when ready
//         if (mounted) {
//           setState(() {
//             _isPlayerReady = true;
//             _isPlaying = true;
//           });
//         }
//       }

//       if (mounted) {
//         setState(() {
//           _currentPosition = _controller!.value.position;
//           _totalDuration = _controller!.value.metaData.duration;
//           _isPlaying = _controller!.value.isPlaying;
//         });

//         // Check for end fade effect
//         _checkForEndFadeEffect();
//       }
//     }
//   }

//   void _showProgressBarTemporarily() {
//     // BLOCK progress bar during fade effects - NO EARLY CANCELLATION
//     if (_isDisposed || _isStartFadeActive || _isEndFadeActive) {
//       print('📊 Cannot show progress bar - fade active or disposed (NO EARLY CANCELLATION)');
//       return;
//     }

//     print('📊 Showing progress bar for 10 seconds');

//     _progressBarTimer?.cancel();

//     if (mounted) {
//       setState(() {
//         _showProgressBar = true;
//         _showControls = false;
//       });
//     }

//     _progressBarTimer = Timer(const Duration(seconds: 10), () {
//       if (mounted && !_isDisposed && !_isStartFadeActive && !_isEndFadeActive) {
//         print('📊 Hiding progress bar after 10 seconds');
//         setState(() {
//           _showProgressBar = false;
//         });
//       }
//     });
//   }

//   void _startHideControlsTimer() {
//     if (_isDisposed || _isStartFadeActive || _isEndFadeActive) return;

//     _hideControlsTimer?.cancel();
//     _hideControlsTimer = Timer(const Duration(seconds: 8), () {
//       if (mounted &&
//           _showControls &&
//           !_isDisposed &&
//           !_isStartFadeActive &&
//           !_isEndFadeActive) {
//         print('🎮 Hiding controls after timeout');
//         setState(() {
//           _showControls = false;
//         });
//         _mainFocusNode.requestFocus();
//       }
//     });
//   }

//   void _showControlsTemporarily() {
//     // BLOCK controls during fade effects - NO EARLY CANCELLATION
//     if (_isDisposed || _isStartFadeActive || _isEndFadeActive) {
//       print('🎮 Cannot show controls - fade active or disposed (NO EARLY CANCELLATION)');
//       return;
//     }

//     print('🎮 Showing controls temporarily');

//     _hideControlsTimer?.cancel();
//     _progressBarTimer?.cancel();

//     if (mounted) {
//       setState(() {
//         _showControls = true;
//         _showProgressBar = false;
//       });
//     }

//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (!_isDisposed && mounted) {
//         _playPauseFocusNode.requestFocus();
//         print('🎮 Focus set to play/pause button');
//       }
//     });

//     _startHideControlsTimer();
//   }

//   void _togglePlayPause() {
//     if (_controller != null && _isPlayerReady && !_isDisposed) {
//       if (_isPlaying) {
//         _controller!.pause();
//         print('⏸️ Video paused');
//       } else {
//         _controller!.play();
//         print('▶️ Video playing');
//       }
//     }
//     _showProgressBarTemporarily();
//   }

//   void _seekVideo(bool forward) {
//     if (_controller != null &&
//         _isPlayerReady &&
//         _totalDuration.inSeconds > 0 &&
//         !_isDisposed) {
//       final seekAmount = (_totalDuration.inSeconds / 100).round().clamp(5, 30);

//       _seekTimer?.cancel();

//       if (forward) {
//         _pendingSeekSeconds += seekAmount;
//       } else {
//         _pendingSeekSeconds -= seekAmount;
//       }

//       final currentSeconds = _currentPosition.inSeconds;
//       final targetSeconds = (currentSeconds + _pendingSeekSeconds)
//           .clamp(0, _totalDuration.inSeconds);
//       _targetSeekPosition = Duration(seconds: targetSeconds);

//       if (mounted && !_isDisposed) {
//         setState(() {
//           _isSeeking = true;
//         });
//       }

//       _seekTimer = Timer(const Duration(milliseconds: 1000), () {
//         _executeSeek();
//       });

//       _showProgressBarTemporarily();
//     }
//   }

//   void _executeSeek() {
//     if (_controller != null &&
//         _isPlayerReady &&
//         !_isDisposed &&
//         _pendingSeekSeconds != 0) {
//       final currentSeconds = _currentPosition.inSeconds;
//       final newPosition = (currentSeconds + _pendingSeekSeconds)
//           .clamp(0, _totalDuration.inSeconds);

//       print('🎯 Executing accumulated seek: ${_pendingSeekSeconds}s to position ${newPosition}s');

//       _controller!.seekTo(Duration(seconds: newPosition));

//       _pendingSeekSeconds = 0;
//       _targetSeekPosition = Duration.zero;

//       if (mounted && !_isDisposed) {
//         setState(() {
//           _isSeeking = false;
//         });
//       }
//     }
//   }

//   bool _handleKeyEvent(RawKeyEvent event) {
//     if (_isDisposed) return false;

//     print('🎮 Key event: ${event.logicalKey} - Start fade: $_isStartFadeActive, End fade: $_isEndFadeActive');

//     // STRICT BLOCKING during fade effects except back/escape - NO EARLY CANCELLATION
//     if (_isStartFadeActive || _isEndFadeActive) {
//       if (event is RawKeyDownEvent) {
//         switch (event.logicalKey) {
//           case LogicalKeyboardKey.escape:
//           case LogicalKeyboardKey.backspace:
//             print('🔙 Back pressed during fade - exiting');
//             if (!_isDisposed) {
//               Navigator.of(context).pop();
//             }
//             return true;
//           default:
//             print('🚫 Key STRICTLY blocked during fade: ${event.logicalKey} (NO EARLY CANCELLATION)');
//             return true; // Block ALL other keys during fade
//         }
//       }
//       return true;
//     }

//     // Normal key handling when no fade is active
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
//           if (!_showControls && !_showProgressBar) {
//             _showControlsTemporarily();
//           } else if (_showControls) {
//             if (_playPauseFocusNode.hasFocus) {
//               _progressFocusNode.requestFocus();
//             } else if (_progressFocusNode.hasFocus) {
//               _playPauseFocusNode.requestFocus();
//             } else {
//               _playPauseFocusNode.requestFocus();
//             }
//             _showControlsTemporarily();
//           } else if (_showProgressBar) {
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
//           if (!_showControls && !_showProgressBar) {
//             _showProgressBarTemporarily();
//           } else if (_showProgressBar) {
//             _showControlsTemporarily();
//           }
//           return true;
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
//           _isStartFadeActive = true;
//           _isEndFadeActive = false;
//           _showProgressBar = false;
//           _showControls = false;
//           _fadeCompletionBlocked = false; // Reset blocking flag
//         });
//       }
      
//       // Reset animations
//       _startFadeController.reset();
//       _endFadeController.reset();
      
//       _controller?.dispose();
//       _initializePlayer();
//       _startInitialFadeEffect();
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
//           _isStartFadeActive = true;
//           _isEndFadeActive = false;
//           _showProgressBar = false;
//           _showControls = false;
//           _fadeCompletionBlocked = false; // Reset blocking flag
//         });
//       }
      
//       // Reset animations
//       _startFadeController.reset();
//       _endFadeController.reset();
      
//       _controller?.dispose();
//       _initializePlayer();
//       _startInitialFadeEffect();
//     } else {
//       _showError('First video in playlist');
//     }
//   }

//   Future<bool> _onWillPop() async {
//     if (_isDisposed) return true;

//     try {
//       print('🔙 Back button pressed - cleaning up...');
//       _isDisposed = true;

//       // Cancel all timers
//       _hideControlsTimer?.cancel();
//       _startFadeTimer?.cancel();
//       _endFadeTimer?.cancel();
//       _seekTimer?.cancel();
//       _progressBarTimer?.cancel();
//       _bufferingTimer?.cancel();

//       // Dispose animation controllers
//       _startFadeController.dispose();
//       _endFadeController.dispose();

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
//         print('Error restoring system UI: $e');
//       }

//       return true;
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
//     _startFadeTimer?.cancel();
//     _endFadeTimer?.cancel();
//     _progressBarTimer?.cancel();
//     _bufferingTimer?.cancel();
//     super.deactivate();
//   }

//   @override
//   void dispose() {
//     print('🗑️ Disposing YouTube player screen...');

//     try {
//       _isDisposed = true;

//       // Cancel timers
//       _hideControlsTimer?.cancel();
//       _seekTimer?.cancel();
//       _startFadeTimer?.cancel();
//       _endFadeTimer?.cancel();
//       _progressBarTimer?.cancel();
//       _bufferingTimer?.cancel();

//       // Dispose animation controllers
//       _startFadeController.dispose();
//       _endFadeController.dispose();

//       // Dispose focus nodes
//       _mainFocusNode.dispose();
//       _playPauseFocusNode.dispose();
//       _progressFocusNode.dispose();

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
//             onTap: (_isStartFadeActive || _isEndFadeActive)
//                 ? null
//                 : () {
//                     print('🎮 Screen tapped - Current state: Controls=$_showControls, Progress=$_showProgressBar');
//                     if (!_showControls && !_showProgressBar) {
//                       print('🎮 Showing controls on tap');
//                       // _showControlsTemporarily();
//                     } else if (_showControls) {
//                       print('🎮 Hiding controls on tap');
//                       setState(() {
//                         _showControls = false;
//                       });
//                     } else if (_showProgressBar) {
//                       print('🎮 Switching from progress to controls');
//                       // _showControlsTemporarily();
//                     }
//                   },
//             behavior: HitTestBehavior.opaque,
//             child: Stack(
//               children: [
//                 // FIRST: Full screen video player (bottom layer)
//                 Positioned.fill(
//                   child: _buildVideoPlayer(),
//                 ),

//                 // SECOND: Buffering overlay (shows during buffering)
//                 if (_isBuffering)
//                   Positioned.fill(
//                     child: Container(
//                       color: Colors.black.withOpacity(0.3),
//                       child: Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               width: 80,
//                               height: 80,
//                               padding: const EdgeInsets.all(20),
//                               decoration: BoxDecoration(
//                                 color: Colors.black.withOpacity(0.7),
//                                 borderRadius: BorderRadius.circular(40),
//                               ),
//                               child: CircularProgressIndicator(
//                                 color: Colors.red,
//                                 strokeWidth: 3,
//                                 value: _bufferProgress,
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                               decoration: BoxDecoration(
//                                 color: Colors.black.withOpacity(0.7),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: const Text(
//                                 'Buffering...',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                 // THIRD: FADE OVERLAYS (top layer)
//                 // Start fade overlay (black to transparent) - FULL 30 SECONDS
//                 if (_isStartFadeActive)
//                   Positioned.fill(
//                     child: AnimatedBuilder(
//                       animation: _startFadeAnimation,
//                       builder: (context, child) {
//                         return Container(
//                           width: double.infinity,
//                           height: double.infinity,
//                           color: Colors.black.withOpacity(_startFadeAnimation.value),
//                           child: _startFadeAnimation.value > 0.5
//                               ? const Center(
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       CircularProgressIndicator(
//                                         color: Colors.red,
//                                         strokeWidth: 3,
//                                       ),
//                                       SizedBox(height: 20),
//                                       Text(
//                                         'Loading Video...',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               : null,
//                         );
//                       },
//                     ),
//                   ),

//                 // End fade overlay (transparent to black)
//                 if (_isEndFadeActive)
//                   Positioned.fill(
//                     child: AnimatedBuilder(
//                       animation: _endFadeAnimation,
//                       builder: (context, child) {
//                         return Container(
//                           width: double.infinity,
//                           height: double.infinity,
//                           color: Colors.black.withOpacity(_endFadeAnimation.value),
//                         );
//                       },
//                     ),
//                   ),

//                 // DEBUG: Show current states (remove in production)
//                 if (!_isStartFadeActive && !_isEndFadeActive && !_isBuffering)
//                   Positioned(
//                     top: 20,
//                     right: 20,
//                     child: Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.7),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         'Controls: $_showControls\nProgress: $_showProgressBar\nReady: $_isPlayerReady\nPlaying: $_isPlaying\nStart Fade: $_isStartFadeActive\nEnd Fade: $_isEndFadeActive\nBuffering: $_isBuffering',
//                         style: const TextStyle(color: Colors.yellow, fontSize: 12),
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
//               Text('Loading for TV Display...', style: TextStyle(color: Colors.white, fontSize: 18)),
//             ],
//           ),
//         ),
//       );
//     }

//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       color: Colors.black,
//       child: FittedBox(
//         fit: BoxFit.cover,
//         child: SizedBox(
//           width: screenwdt,
//           height: screenhgt,
//           child: YoutubePlayer(
//             controller: _controller!,
//             showVideoProgressIndicator: true,
//             progressIndicatorColor: Colors.green,
//             width: screenwdt,
//             aspectRatio: 16 / 9,
//             bufferIndicator: Container(
//               color: Colors.black,
//               child: const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(color: Colors.red),
//                     SizedBox(height: 10),
//                     Text('Buffering...', style: TextStyle(color: Colors.white)),
//                   ],
//                 ),
//               ),
//             ),
//             onReady: () {
//               print('📺 TV Player Ready - Video surface initialized');
//               if (!_isPlayerReady && !_isDisposed) {
//                 if (mounted) {
//                   setState(() {
//                     _isPlayerReady = true;
//                     _isPlaying = true;
//                   });
//                 }

//                 Future.delayed(const Duration(milliseconds: 300), () {
//                   if (!_isDisposed) {
//                     _mainFocusNode.requestFocus();
//                     print('🎬 TV: Video ready - playing now');
//                     _controller?.play();
//                     _stopBuffering(); // Stop buffering when ready
//                   }
//                 });
//               }
//             },
//             onEnded: (_) {
//               if (_isDisposed) return;

//               if (widget.playlist.length == 1 || currentIndex >= widget.playlist.length - 1) {
//                 print('🏠 Video ended - returning to home page');
//                 Future.delayed(const Duration(milliseconds: 500), () {
//                   if (mounted && !_isDisposed) {
//                     Navigator.of(context).pop();
//                   }
//                 });
//               } else {
//                 _playNextVideo();
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
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

//   @override
//   void initState() {
//     super.initState();
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
//     print('🎬 Black splash screen started - will fade to transparent over 30 seconds');

//     // Reset splash opacity to fully black
//     _splashOpacity = 1.0;

//     // Animation timer - updates every 100ms for smooth fade
//     _fadeAnimationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
//       if (mounted && _showSplashScreen && !_isDisposed && _splashStartTime != null) {
//         final elapsed = DateTime.now().difference(_splashStartTime!).inMilliseconds;
//         final totalDuration = 30000; // 30 seconds in milliseconds
        
//         // Calculate fade progress (1.0 to 0.0 over 30 seconds)
//         final progress = (elapsed / totalDuration).clamp(0.0, 1.0);
//         final newOpacity = 1.0 - progress; // Start black (1.0), end transparent (0.0)
        
//         if (mounted) {
//           setState(() {
//             _splashOpacity = newOpacity.clamp(0.0, 1.0);
//           });
//         }
        
//         // Stop when fully transparent after FULL 30 seconds
//         if (elapsed >= 30000) {
//           timer.cancel();
//           print('🎬 30 seconds complete - splash screen removed');
//           if (mounted) {
//             setState(() {
//               _showSplashScreen = false;
//               _splashOpacity = 0.0;
//             });
//           }
          
//           // Show controls when splash is gone
//           Future.delayed(const Duration(milliseconds: 500), () {
//             if (mounted && !_isDisposed) {
//               _showControlsTemporarily();
//               print('🎮 Controls are now available after 30 seconds');
//             }
//           });
//         }
//       } else {
//         timer.cancel();
//       }
//     });

//     // Timer to update countdown display every second
//     _splashUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (mounted && _showSplashScreen && !_isDisposed) {
//         final remaining = _getRemainingSeconds();
//         print('⏰ Splash fade progress: ${remaining} seconds remaining');
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
//           startAt: 10, // START FROM 10 SECONDS - SKIP FIRST 10 SECONDS
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
//         print('📡 Controller ready detected - seeking to 10 seconds');
        
//         // Ensure video starts from 10 seconds
//         _controller!.seekTo(const Duration(seconds: 10));
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
//           _isPlaying = _controller!.value.isPlaying;
//         });
//       }

//       // Check if video reached end minus 10 seconds - STOP 10 SECONDS BEFORE ACTUAL END
//       if (_totalDuration.inSeconds > 20 && _currentPosition.inSeconds > 10) { // Only if video is longer than 20 seconds and started
//         final adjustedEndTime = _totalDuration.inSeconds - 10; // End 10 seconds before actual end
//         final remainingSeconds = adjustedEndTime - _currentPosition.inSeconds;
        
//         // Show end splash when 30 seconds remain from adjusted end time
//         if (remainingSeconds <= 30 && !_showEndSplashScreen) {
//           print('🎬 30 seconds remaining (adjusted for 10s cut) - starting end splash');
//           _startEndSplashTimer();
//         }
        
//         // Stop video when reaching adjusted end time (10 seconds before actual end)
//         if (_currentPosition.inSeconds >= adjustedEndTime) {
//           print('🛑 Video reached cut point - stopping 10 seconds before actual end');
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
//       } else {
//         _controller!.play();
//         print('▶️ Video playing');
//       }
//     }
//     _showControlsTemporarily();
//   }

//   void _seekVideo(bool forward) {
//     if (_controller != null && _isPlayerReady && _totalDuration.inSeconds > 20 && !_isDisposed) {
//       final adjustedEndTime = _totalDuration.inSeconds - 10; // Don't allow seeking beyond cut point
//       final seekAmount = (adjustedEndTime / 100).round().clamp(5, 30); // 5-30 seconds

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

//       // Calculate target position for preview - RESPECT CUT BOUNDARIES
//       final currentSeconds = _currentPosition.inSeconds;
//       final targetSeconds = (currentSeconds + _pendingSeekSeconds).clamp(10, adjustedEndTime); // Between 10s and end-10s
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
//       final adjustedEndTime = _totalDuration.inSeconds - 10; // Don't seek beyond cut point
//       final currentSeconds = _currentPosition.inSeconds;
//       final newPosition = (currentSeconds + _pendingSeekSeconds).clamp(10, adjustedEndTime); // Respect cut boundaries

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

//   // Start end splash screen when 30 seconds remain - WITH STRONG FADE ANIMATION
//   void _startEndSplashTimer() {
//     if (_showEndSplashScreen || _isDisposed) return; // Prevent multiple triggers
    
//     _endSplashStartTime = DateTime.now();
//     print('🎬 End splash started - will fade from transparent to black over 30 seconds');

//     // Reset end splash opacity to transparent
//     _endSplashOpacity = 0.0;

//     setState(() {
//       _showEndSplashScreen = true;
//     });

//     // Cancel any existing fade timer
//     _fadeAnimationTimer?.cancel();

//     // Animation timer for end splash - updates every 50ms for VERY smooth fade
//     _fadeAnimationTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
//       if (mounted && _showEndSplashScreen && !_isDisposed && _endSplashStartTime != null) {
//         final elapsed = DateTime.now().difference(_endSplashStartTime!).inMilliseconds;
//         final totalDuration = 30000; // 30 seconds in milliseconds
        
//         // Calculate fade progress (0.0 to 1.0 over 30 seconds)
//         final progress = (elapsed / totalDuration).clamp(0.0, 1.0);
//         final newOpacity = progress; // Start transparent (0.0), end black (1.0)
        
//         if (mounted) {
//           setState(() {
//             _endSplashOpacity = newOpacity.clamp(0.0, 1.0);
//           });
//         }
        
//         if (elapsed >= 30000) {
//           timer.cancel();
//           print('🎬 End splash fully black - ready for navigation');
//         }
//       } else {
//         timer.cancel();
//       }
//     });

//     print('⏰ End splash fade animation started - transparent to black over 30 seconds');
//   }

//   // Helper method to check if controls should be blocked (only first 15 seconds)
//   bool _shouldBlockControls() {
//     if (_showSplashScreen && _splashStartTime != null) {
//       final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
//       return elapsed < 15; // Block only for first 15 seconds
//     }
//     if (_showEndSplashScreen && _endSplashStartTime != null) {
//       final elapsed = DateTime.now().difference(_endSplashStartTime!).inSeconds;
//       return elapsed < 15; // Block only for first 15 seconds of end splash
//     }
//     return false;
//   }

//   // BLOCK controls only for first 15 seconds of each splash
//   bool _handleKeyEvent(RawKeyEvent event) {
//     if (_isDisposed) return false;

//     // BLOCK key events only during first 15 seconds of splash screens
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
//             // Block other keys only for 15 seconds
//             print('🚫 Key blocked during first 15 seconds of splash: ${event.logicalKey}');
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
//           _showEndSplashScreen = false; // Reset end splash
//           _splashOpacity = 1.0; // Reset opacity
//           _endSplashOpacity = 0.0; // Reset end opacity
//         });
//       }
//       _controller?.dispose();
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
//           _showEndSplashScreen = false; // Reset end splash
//           _splashOpacity = 1.0; // Reset opacity
//           _endSplashOpacity = 0.0; // Reset end opacity
//         });
//       }
//       _controller?.dispose();
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
//       _endSplashTimer?.cancel();
//       _fadeAnimationTimer?.cancel();

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
//     _fadeAnimationTimer?.cancel();
//     super.deactivate();
//   }

//   @override
//   void dispose() {
//     print('🗑️ Disposing YouTube player screen...');

//     try {
//       // Mark as disposed
//       _isDisposed = true;

//       // Cancel timers
//       _hideControlsTimer?.cancel();
//       _seekTimer?.cancel();
//       _splashTimer?.cancel();
//       _splashUpdateTimer?.cancel();
//       _endSplashTimer?.cancel();
//       _fadeAnimationTimer?.cancel();

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
//             onTap: _shouldBlockControls() ? null : _showControlsTemporarily, // Disable tap only during first 15 seconds
//             behavior: HitTestBehavior.opaque,
//             child: Stack(
//               children: [
//                 // Full screen video player (always present and playing in background)
//                 _buildVideoPlayer(),

//                 // Animated Black Splash Screen Overlay - FADES over 30 seconds at start
//                 if (_showSplashScreen)
//                   _buildBlackSplashScreen(),

//                 // Animated End Black Splash Screen Overlay - FADES over 30 seconds before end
//                 if (_showEndSplashScreen)
//                   _buildBlackSplashScreen(),

//                 // Custom Controls Overlay - Show after 15 seconds even during splash
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

//   // ANIMATED Black splash screen - FADES FROM BLACK TO TRANSPARENT or TRANSPARENT TO BLACK
//   Widget _buildBlackSplashScreen() {
//     return Positioned.fill(
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 100), // Smooth animation
//         width: double.infinity,
//         height: double.infinity,
//         color: Colors.black.withOpacity(_showSplashScreen ? _splashOpacity : _endSplashOpacity),
//         // Animated opacity:
//         // Start splash: 1.0 (black) → 0.0 (transparent) over 30 seconds
//         // End splash: 0.0 (transparent) → 1.0 (black) over 30 seconds
//       ),
//     );
//   }

//   // Helper methods for splash countdown
//   double _getSplashProgress() {
//     if (_splashStartTime == null) return 0.0;

//     final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
//     final progress = elapsed / 30.0; // 30 seconds total
//     return progress.clamp(0.0, 1.0);
//   }

//   int _getRemainingSeconds() {
//     if (_splashStartTime == null) return 30;

//     final elapsed = DateTime.now().difference(_splashStartTime!).inSeconds;
//     final remaining = 30 - elapsed;
//     return remaining.clamp(0, 30);
//   }

//   Widget _buildControlsOverlay() {
//     return Positioned.fill(
//       child: Stack(
//         children: [
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
//                         padding: const EdgeInsets.all(16),
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

//                                 // Time indicators and help text - ADJUSTED FOR CUT VIDEO
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       _isSeeking
//                                           ? _formatDuration(Duration(seconds: (_targetSeekPosition.inSeconds - 10).clamp(0, double.infinity).toInt()))
//                                           : _formatDuration(Duration(seconds: (_currentPosition.inSeconds - 10).clamp(0, double.infinity).toInt())),
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
//                                       _formatDuration(Duration(seconds: (_totalDuration.inSeconds - 20).clamp(0, double.infinity).toInt())), // Show adjusted total duration
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

//             // TV video surface activation - Start playing from 10 seconds with sound
//             Future.delayed(const Duration(milliseconds: 100), () {
//               if (_controller != null && mounted && !_isDisposed) {
//                 // Double ensure we start from 10 seconds
//                 _controller!.seekTo(const Duration(seconds: 10));
//                 _controller!.play();
//                 print('🎬 TV: Video started playing from 10 seconds (with sound during black splash)');
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






import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:async';

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

// Direct YouTube Player Screen - No Home Page Required
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
  YoutubePlayerController? _controller;
  late VideoData currentVideo;
  int currentIndex = 0;
  bool _isPlayerReady = false;
  String? _error;
  bool _isLoading = true;
  bool _isDisposed = false; // Track disposal state

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

  // Control states
  bool _showControls = true;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Timer? _hideControlsTimer;

  // Progressive seeking states
  Timer? _seekTimer;
  int _pendingSeekSeconds = 0;
  Duration _targetSeekPosition = Duration.zero;
  bool _isSeeking = false;

  // Focus nodes for TV remote
  final FocusNode _playPauseFocusNode = FocusNode();
  final FocusNode _progressFocusNode = FocusNode();
  final FocusNode _mainFocusNode = FocusNode(); // Main invisible focus node
  bool _isProgressFocused = false;

  // PAUSE CONTAINER STATES
  Timer? _pauseContainerTimer;
  bool _showPauseBlackBars = false; // Changed from _showPauseContainer to _showPauseBlackBars

  @override
  void initState() {
    super.initState();
    currentVideo = widget.videoData;
    currentIndex = widget.playlist.indexOf(widget.videoData);

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
      // Show controls initially for testing (will be hidden during splash)
      if (!_showSplashScreen) {
        _showControlsTemporarily();
      }
    });
  }

  void _startSplashTimer() {
    _splashStartTime = DateTime.now(); // Record start time
    print('🎬 Top/Bottom black bars started - will remove after exactly 12 seconds');

    // Simple timer - EXACTLY 12 seconds, no fade
    _splashTimer = Timer(const Duration(seconds: 12), () {
      if (mounted && !_isDisposed && _showSplashScreen) {
        print('🎬 12 seconds complete - removing top/bottom black bars');
        
        setState(() {
          _showSplashScreen = false;
        });
        
        // Show controls when splash is gone
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !_isDisposed) {
            _showControlsTemporarily();
            print('🎮 Controls are now available after 12 seconds');
          }
        });
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
      String? videoId = YoutubePlayer.convertUrlToId(currentVideo.youtubeUrl);

      print('🔧 TV Mode: Initializing player for: $videoId');

      if (videoId == null || videoId.isEmpty) {
        if (mounted && !_isDisposed) {
          setState(() {
            _error = 'Invalid YouTube URL: ${currentVideo.youtubeUrl}';
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

  void _listener() {
    if (_controller != null && mounted && !_isDisposed) {
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
          
          // PAUSE CONTAINER LOGIC
          bool newIsPlaying = _controller!.value.isPlaying;
          
          // Agar pause se play hua hai
          if (!_isPlaying && newIsPlaying) {
            print('▶️ Video resumed - starting 5 second pause black bars timer');
            _showPauseBlackBars = true; // Immediately show black bars
            
            // 5 second timer to hide pause black bars
            _pauseContainerTimer?.cancel();
            _pauseContainerTimer = Timer(const Duration(seconds: 5), () {
              if (mounted && !_isDisposed) {
                setState(() {
                  _showPauseBlackBars = false;
                });
                print('⏰ 5 seconds completed - hiding pause black bars');
              }
            });
          }
          // Agar play se pause hua hai
          else if (_isPlaying && !newIsPlaying) {
            print('⏸️ Video paused - showing pause black bars');
            _showPauseBlackBars = true;
            _pauseContainerTimer?.cancel(); // Cancel any existing timer
          }
          
          _isPlaying = newIsPlaying;
        });
      }

      // Check if video reached end minus 12 seconds - STOP 12 SECONDS BEFORE ACTUAL END
      if (_totalDuration.inSeconds > 24 && _currentPosition.inSeconds > 0) { // Only if video is longer than 24 seconds
        final adjustedEndTime = _totalDuration.inSeconds - 12; // End 12 seconds before actual end
        
        // Stop video when reaching adjusted end time (12 seconds before actual end)
        if (_currentPosition.inSeconds >= adjustedEndTime) {
          print('🛑 Video reached cut point - stopping 12 seconds before actual end');
          _controller!.pause();
          
          // Navigate back after brief pause
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted && !_isDisposed) {
              Navigator.of(context).pop();
            }
          });
        }
      }
    }
  }

  void _startHideControlsTimer() {
    // Controls hide timer works normally - only splash blocks controls, not this timer
    if (_isDisposed) return;

    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _showControls && !_isDisposed) {
        setState(() {
          _showControls = false;
        });
        // When controls hide, focus goes back to main invisible node
        _mainFocusNode.requestFocus();
      }
    });
  }

  void _showControlsTemporarily() {
    // Controls show normally - splash blocking is handled in key events
    if (_isDisposed) return;

    if (mounted) {
      setState(() {
        _showControls = true;
      });
    }

    // When controls show, focus on play/pause button
    _playPauseFocusNode.requestFocus();
    _startHideControlsTimer();
  }

  void _togglePlayPause() {
    if (_controller != null && _isPlayerReady && !_isDisposed) {
      if (_isPlaying) {
        _controller!.pause();
        print('⏸️ Video paused');
        // Pause container will show via listener
      } else {
        _controller!.play();
        print('▶️ Video playing - 5 second timer will start via listener');
        // Timer will start via listener when play state changes
      }
    }
    _showControlsTemporarily();
  }

  void _seekVideo(bool forward) {
    if (_controller != null && _isPlayerReady && _totalDuration.inSeconds > 24 && !_isDisposed) {
      final adjustedEndTime = _totalDuration.inSeconds - 12; // Don't allow seeking beyond cut point
      final seekAmount = (adjustedEndTime / 200).round().clamp(5, 30); // 5-30 seconds

      // Cancel previous seek timer
      _seekTimer?.cancel();

      // Calculate new pending seek
      if (forward) {
        _pendingSeekSeconds += seekAmount;
        print('⏩ Adding forward seek: +${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
      } else {
        _pendingSeekSeconds -= seekAmount;
        print('⏪ Adding backward seek: -${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
      }

      // Calculate target position for preview - RESPECT END CUT BOUNDARY
      final currentSeconds = _currentPosition.inSeconds;
      final targetSeconds = (currentSeconds + _pendingSeekSeconds).clamp(0, adjustedEndTime); // 0 to end-12s
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

      _showControlsTemporarily();
    }
  }

  void _executeSeek() {
    if (_controller != null && _isPlayerReady && !_isDisposed && _pendingSeekSeconds != 0) {
      final adjustedEndTime = _totalDuration.inSeconds - 12; // Don't seek beyond cut point
      final currentSeconds = _currentPosition.inSeconds;
      final newPosition = (currentSeconds + _pendingSeekSeconds).clamp(0, adjustedEndTime); // Respect end cut boundary

      print('🎯 Executing accumulated seek: ${_pendingSeekSeconds}s to position ${newPosition}s (within cut boundaries)');

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
    if (_showEndSplashScreen || _isDisposed) return; // Prevent multiple triggers
    
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

  // BLOCK controls only for first 8 seconds of splash
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
            print('🚫 Key blocked during first 8 seconds of splash: ${event.logicalKey}');
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

        case LogicalKeyboardKey.arrowUp:
        case LogicalKeyboardKey.arrowDown:
          if (!_showControls) {
            _showControlsTemporarily();
          } else {
            if (_playPauseFocusNode.hasFocus) {
              _progressFocusNode.requestFocus();
            } else if (_progressFocusNode.hasFocus) {
              _playPauseFocusNode.requestFocus();
            } else {
              _playPauseFocusNode.requestFocus();
            }
            _showControlsTemporarily();
          }
          return true;

        case LogicalKeyboardKey.escape:
        case LogicalKeyboardKey.backspace:
          if (!_isDisposed) {
            Navigator.of(context).pop();
          }
          return true;

        default:
          if (!_showControls) {
            _showControlsTemporarily();
            return true;
          }
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

  void _playNextVideo() {
    if (_isDisposed) return;

    if (currentIndex < widget.playlist.length - 1) {
      if (mounted) {
        setState(() {
          currentIndex++;
          currentVideo = widget.playlist[currentIndex];
          _isLoading = true;
          _error = null;
          _showSplashScreen = true; // Show splash for next video
          _showPauseBlackBars = false; // Reset pause black bars
          _splashOpacity = 1.0; // Reset opacity
        });
      }
      _controller?.dispose();
      _pauseContainerTimer?.cancel(); // Cancel pause timer
      _initializePlayer();
      _startSplashTimer(); // Start splash timer for next video
    } else {
      _showError('Playlist complete, returning to home');
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && !_isDisposed) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  void _playPreviousVideo() {
    if (_isDisposed) return;

    if (currentIndex > 0) {
      if (mounted) {
        setState(() {
          currentIndex--;
          currentVideo = widget.playlist[currentIndex];
          _isLoading = true;
          _error = null;
          _showSplashScreen = true; // Show splash for previous video
          _showPauseBlackBars = false; // Reset pause black bars
          _splashOpacity = 1.0; // Reset opacity
        });
      }
      _controller?.dispose();
      _pauseContainerTimer?.cancel(); // Cancel pause timer
      _initializePlayer();
      _startSplashTimer(); // Start splash timer for previous video
    } else {
      _showError('First video in playlist');
    }
  }

  // Handle back button press - TV Remote ke liye
  Future<bool> _onWillPop() async {
    if (_isDisposed) return true;

    try {
      print('🔙 Back button pressed - cleaning up...');

      // Mark as disposed first
      _isDisposed = true;

      // Cancel all timers
      _hideControlsTimer?.cancel();
      _splashTimer?.cancel();
      _splashUpdateTimer?.cancel();
      _seekTimer?.cancel();
      _pauseContainerTimer?.cancel(); // Cancel pause timer

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
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values
        );

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
    _pauseContainerTimer?.cancel(); // Cancel pause timer
    super.deactivate();
  }

  @override
  void dispose() {
    print('🗑️ Disposing YouTube player screen...');

    try {
      // Mark as disposed
      _isDisposed = true;

      // Cancel timers
      _hideControlsTimer?.cancel();
      _seekTimer?.cancel();
      _splashTimer?.cancel();
      _splashUpdateTimer?.cancel();
      _pauseContainerTimer?.cancel(); // Cancel pause timer

      // Dispose focus nodes
      if (_mainFocusNode.hasListeners) {
        _mainFocusNode.dispose();
      }
      if (_playPauseFocusNode.hasListeners) {
        _playPauseFocusNode.dispose();
      }
      if (_progressFocusNode.hasListeners) {
        _progressFocusNode.dispose();
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
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values
        );

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
            onTap: _shouldBlockControls() ? null : _showControlsTemporarily, // Disable tap only during first 8 seconds
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                // Full screen video player (always present and playing in background)
                _buildVideoPlayer(),

                // Top/Bottom Black Bars - Show for 12 seconds with video playing in center
                if (_showSplashScreen)
                  _buildTopBottomBlackBars(),

                // Pause Black Bars - Show when paused and 5 seconds after resume
                if (_showPauseBlackBars && _isPlayerReady)
                  _buildPauseBlackBars(),

                // Custom Controls Overlay - Show after 8 seconds even during splash
                if (!_shouldBlockControls())
                  _buildControlsOverlay(),

                // Invisible back area - Active when controls are not blocked
                if (!_shouldBlockControls())
                  Positioned(
                    top: 0,
                    left: 0,
                    width: screenwdt,
                    height: screenhgt,
                    child: GestureDetector(
                      onTap: () {
                        if (!_isDisposed) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Pause Black Bars - Same as start splash bars but for pause state
  Widget _buildPauseBlackBars() {
    return Stack(
      children: [
        // Top Black Bar - screenhgt/6 height (plain black, no text)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: screenhgt / 6,
          child: Container(
            color: Colors.black,
          ),
        ),
        // Bottom Black Bar - screenhgt/6 height
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: screenhgt / 6,
          child: Container(
            color: Colors.black,
          ),
        ),
      ],
    );
  }
  // Top and Bottom Black Bars - Video plays in center (Start Splash)
  Widget _buildTopBottomBlackBars() {
    return Stack(
      children: [
        // Top Black Bar - screenhgt/6 height
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: screenhgt / 6,
          child: Container(
            color: Colors.black,
          ),
        ),
        // Bottom Black Bar - screenhgt/6 height
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: screenhgt / 6,
          child: Container(
            color: Colors.black,
          ),
        ),
      ],
    );
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

  Widget _buildControlsOverlay() {
    return Positioned.fill(
      child: Stack(
        children: [
          // PAUSE BLACK BARS replaced with main pause black bars functionality moved above

          // Visible controls overlay
          if (_showControls)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Column(
                children: [
                  // Top area - playlist info
                  if (widget.playlist.length > 1)
                    SafeArea(
                      child: Container(
                        padding: EdgeInsets.only(
                          top: (_showPauseBlackBars || _showSplashScreen) ? (screenhgt / 6) + 16 : 16, // Space for both pause and splash bars
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${currentIndex + 1}/${widget.playlist.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Bottom Progress Bar with Play/Pause Button
                  SafeArea(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Progress Bar Section
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Progress Bar
                                Focus(
                                  focusNode: _progressFocusNode,
                                  onFocusChange: (focused) {
                                    if (mounted && !_isDisposed) {
                                      setState(() {
                                        _isProgressFocused = focused;
                                      });
                                      if (focused) _showControlsTemporarily();
                                    }
                                  },
                                  child: Builder(
                                    builder: (context) {
                                      final isFocused = Focus.of(context).hasFocus;
                                      return Container(
                                        height: 8,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          border: isFocused ? Border.all(color: Colors.white, width: 2) : null,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: Stack(
                                            children: [
                                              // Background
                                              Container(
                                                width: double.infinity,
                                                height: 8,
                                                color: Colors.white.withOpacity(0.3),
                                              ),
                                              // Main progress bar
                                              if (_totalDuration.inSeconds > 0)
                                                FractionallySizedBox(
                                                  widthFactor: _currentPosition.inSeconds / _totalDuration.inSeconds,
                                                  child: Container(
                                                    height: 8,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              // Seeking preview indicator
                                              if (_isSeeking && _totalDuration.inSeconds > 0)
                                                FractionallySizedBox(
                                                  widthFactor: _targetSeekPosition.inSeconds / _totalDuration.inSeconds,
                                                  child: Container(
                                                    height: 8,
                                                    color: Colors.yellow.withOpacity(0.8),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Time indicators and help text - ADJUSTED FOR END CUT
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _isSeeking
                                          ? _formatDuration(_targetSeekPosition)
                                          : _formatDuration(_currentPosition),
                                      style: TextStyle(
                                        color: _isSeeking ? Colors.yellow : Colors.white,
                                        fontSize: 14,
                                        fontWeight: _isSeeking ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    if (_isProgressFocused)
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            '← → Seek | ↑↓ Navigate',
                                            style: TextStyle(color: Colors.white70, fontSize: 12),
                                          ),
                                          if (_isSeeking)
                                            Text(
                                              '${_pendingSeekSeconds > 0 ? "+" : ""}${_pendingSeekSeconds}s',
                                              style: const TextStyle(color: Colors.yellow, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                        ],
                                      ),
                                    Text(
                                      _formatDuration(Duration(seconds: (_totalDuration.inSeconds - 12).clamp(0, double.infinity).toInt())), // Show adjusted total duration (minus 12s)
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 20),

                          // Play/Pause Button
                          Focus(
                            focusNode: _playPauseFocusNode,
                            onFocusChange: (focused) {
                              if (focused && !_isDisposed) _showControlsTemporarily();
                            },
                            child: Builder(
                              builder: (context) {
                                final isFocused = Focus.of(context).hasFocus;
                                return GestureDetector(
                                  onTap: _togglePlayPause,
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(35),
                                      border: isFocused ? Border.all(color: Colors.white, width: 3) : null,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _isPlaying ? Icons.pause : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Invisible overlay for focus management when controls are hidden
          if (!_showControls)
            Positioned.fill(
              child: GestureDetector(
                onTap: _showControlsTemporarily,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
        ],
      ),
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
              Text(
                'Loading for TV Display...',
                style: TextStyle(color: Colors.white, fontSize: 18)
              ),
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

            // Focus on main node when ready, controls will show when needed
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
                print('🎬 TV: Video started playing from beginning (with sound during black bars)');
              }
            });
          }
        },
        onEnded: (_) {
          if (_isDisposed) return;

          print('🎬 Video ended - navigating back to source page');
          
          // Navigate back to source page immediately
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && !_isDisposed) {
              Navigator.of(context).pop(); // Always go back to source page
            }
          });
        },
      ),
    );
  }
}