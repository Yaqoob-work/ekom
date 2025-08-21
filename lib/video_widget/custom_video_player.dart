import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class CustomVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final List<String>? playlist;
  final int initialIndex;
  
  const CustomVideoPlayer({
    Key? key,
    required this.videoUrl,
    this.playlist,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _controller;
  Timer? _timer;
  double _currentPosition = 0.0;
  double _totalDuration = 1.0;
  bool _isPlaying = false;
  bool _isInitialized = false;
  int _currentVideoIndex = 0;
  List<String> _videoUrls = [];
  
  // Enhanced seeking state management
  Timer? _seekTimer;
  Timer? _seekIndicatorTimer;
  int _pendingSeekSeconds = 0;
  Duration _targetSeekPosition = Duration.zero;
  bool _isSeeking = false;
  bool _isActuallySeekingVideo = false;
  bool _showSeekingIndicator = false;
  double _lastKnownPosition = 0.0;
  
  final FocusNode _mainFocusNode = FocusNode();
  bool _videoCompleted = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    KeepScreenOn.turnOn();
    _currentVideoIndex = widget.initialIndex;
    _videoUrls = widget.playlist ?? [widget.videoUrl];
    _initializePlayer();
    _setFullScreen();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mainFocusNode.requestFocus();
    });
  }

  void _setFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _initializePlayer() async {
    String currentVideoUrl = _videoUrls[_currentVideoIndex];
    
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(currentVideoUrl));
      
      await _controller.initialize();
      
      setState(() {
        _isInitialized = true;
        _totalDuration = _controller.value.duration.inSeconds.toDouble();
      });

      _controller.addListener(_playerListener);
      _controller.play();
      _startProgressTimer();
      
      print('✅ Video initialized successfully');
    } catch (error) {
      print('❌ Error initializing video: $error');
      // Handle initialization error
    }
  }

  void _playerListener() {
    if (_controller.value.isInitialized) {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
        _totalDuration = _controller.value.duration.inSeconds.toDouble();
      });
      
      // Video end cut logic (same as YouTube player)
      if (_totalDuration > 30 && 
          _controller.value.position.inSeconds > 0 && 
          !_videoCompleted && 
          !_isNavigating) {
        
        final adjustedEndTime = _totalDuration.toInt() - 15;
        
        if (_controller.value.position.inSeconds >= adjustedEndTime) {
          print('🛑 Video reached cut point (15s before end) - completing video');
          _completeVideo();
        }
      }
    }
  }

  void _completeVideo() {
    if (_isNavigating || _videoCompleted) return;

    print('🎬 Video completing - 15 seconds before actual end');
    _videoCompleted = true;
    _isNavigating = true;

    if (_controller.value.isPlaying) {
      _controller.pause();
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _playNextVideo();
      }
    });
  }

  void _resetVideoStates() {
    _isNavigating = false;
    _videoCompleted = false;
    _currentPosition = 0.0;
    _isSeeking = false;
    _isActuallySeekingVideo = false;
    _showSeekingIndicator = false;
    _pendingSeekSeconds = 0;
    _targetSeekPosition = Duration.zero;
  }

  void _startProgressTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_controller.value.isInitialized) {
        final newPosition = _controller.value.position.inSeconds.toDouble();
        
        // If we're seeking, check if we've reached the target position
        if (_isActuallySeekingVideo && _targetSeekPosition != Duration.zero) {
          final targetPos = _targetSeekPosition.inSeconds.toDouble();
          final tolerance = 1.5; // 1.5 second tolerance
          
          if ((newPosition - targetPos).abs() <= tolerance) {
            // We've reached target position, reset all seeking states
            print('✅ Reached target position: ${newPosition}s (target was: ${targetPos}s)');
            setState(() {
              _currentPosition = newPosition;
              _lastKnownPosition = newPosition;
              _isActuallySeekingVideo = false;
              _isSeeking = false;
            });
            _pendingSeekSeconds = 0;
            _targetSeekPosition = Duration.zero;
          }
        } else if (!_isSeeking && !_isActuallySeekingVideo) {
          // Normal position update when not seeking at all
          setState(() {
            _currentPosition = newPosition;
            _lastKnownPosition = newPosition;
          });
        }
      }
    });
  }

  // Enhanced seeking with smooth progress bar
  void _seekVideo(bool forward) {
    if (_controller.value.isInitialized && _totalDuration > 30) {
      final adjustedEndTime = _totalDuration.toInt() - 15;
      final seekAmount = (adjustedEndTime / 200).round().clamp(5, 30);

      // Store current position before seeking starts (only if not already seeking)
      if (!_isSeeking && !_isActuallySeekingVideo) {
        _lastKnownPosition = _currentPosition;
      }

      _seekTimer?.cancel();

      // Calculate new pending seek
      if (forward) {
        _pendingSeekSeconds += seekAmount;
        print('⏩ Adding forward seek: +${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
      } else {
        _pendingSeekSeconds -= seekAmount;
        print('⏪ Adding backward seek: -${seekAmount}s (total pending: ${_pendingSeekSeconds}s)');
      }

      // Calculate target position - RESPECT END CUT BOUNDARY
      final targetSeconds = (_lastKnownPosition.toInt() + _pendingSeekSeconds)
          .clamp(0, adjustedEndTime);
      _targetSeekPosition = Duration(seconds: targetSeconds);

      // Show seeking state and indicator
      setState(() {
        _isSeeking = true;
        _showSeekingIndicator = true;
      });

      print('🎯 Target seek position: ${targetSeconds}s');

      // Set timer to execute actual seek
      _seekTimer = Timer(const Duration(milliseconds: 1000), () {
        _executeSeek();
      });

      // Set timer to hide seeking indicator after 3 seconds
      _seekIndicatorTimer?.cancel();
      _seekIndicatorTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showSeekingIndicator = false;
          });
        }
      });
    }
  }

  void _executeSeek() {
    if (_controller.value.isInitialized && _pendingSeekSeconds != 0) {
      final targetSeconds = _targetSeekPosition.inSeconds;

      print('🎯 Executing accumulated seek to: ${targetSeconds}s');

      // Set flag to prevent position updates during seeking
      setState(() {
        _isActuallySeekingVideo = true;
        _currentPosition = targetSeconds.toDouble(); // Set target position
      });

      // Execute the actual video seek
      try {
        _controller.seekTo(Duration(seconds: targetSeconds));
        print('⏳ Seek command sent, waiting for video to reach target position...');
        // Don't reset states here - let the timer check when we actually reach the position
      } catch (error) {
        print('❌ Seek error: $error');
        // Reset on error
        setState(() {
          _isActuallySeekingVideo = false;
          _isSeeking = false;
        });
        _pendingSeekSeconds = 0;
        _targetSeekPosition = Duration.zero;
      }
    }
  }

  bool _handleKeyEvent(RawKeyEvent event) {
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
          Navigator.of(context).pop();
          return true;

        default:
          break;
      }
    }
    return false;
  }

  void _togglePlayPause() {
    if (_controller.value.isInitialized) {
      if (_isPlaying) {
        _controller.pause();
        print('⏸️ Video paused');
      } else {
        _controller.play();
        print('▶️ Video playing');
      }
    }
  }

  void _playNextVideo() {
    if (_currentVideoIndex < _videoUrls.length - 1) {
      setState(() {
        _currentVideoIndex++;
      });
      _resetVideoStates();
      _changeVideo(_videoUrls[_currentVideoIndex]);
    } else {
      print('📱 Playlist complete - exiting player');
      Navigator.of(context).pop();
    }
  }

  void _playPreviousVideo() {
    if (_currentVideoIndex > 0) {
      setState(() {
        _currentVideoIndex--;
      });
      _resetVideoStates();
      _changeVideo(_videoUrls[_currentVideoIndex]);
    }
  }

  void _changeVideo(String videoUrl) async {
    try {
      await _controller.dispose();
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _controller.initialize();
      
      setState(() {
        _currentPosition = 0.0;
        _totalDuration = _controller.value.duration.inSeconds.toDouble();
        _isInitialized = true;
      });
      
      _controller.addListener(_playerListener);
      _controller.play();
    } catch (error) {
      print('❌ Error changing video: $error');
    }
  }

  String _formatDuration(double seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double get _adjustedTotalDuration {
    if (_totalDuration > 30) {
      return _totalDuration - 15;
    }
    return _totalDuration;
  }

  // Get display position for progress bar
  double get _displayPosition {
    if (_isSeeking || _isActuallySeekingVideo) {
      return _targetSeekPosition.inSeconds.toDouble();
    }
    return _currentPosition;
  }


    Widget _buildVideoPlayer() {
    if ( _controller == null) {
      return Center(child: CircularProgressIndicator());
    }

    // video_player needs a different approach to aspect ratio handling
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen dimensions
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Calculate aspect ratio from the controller
        // final videoAspectRatio = _controller!.value.aspectRatio;

        // Use AspectRatio widget to maintain correct proportions
        return Container(
          width: screenWidth,
          height: screenHeight,
          color: Colors.black,
          child: Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoPlayer(_controller),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return RawKeyboardListener(
      focusNode: _mainFocusNode,
      autofocus: true,
      onKey: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Full Screen Video Player
            if (_isInitialized)
              // SizedBox.expand(
              //   child: FittedBox(
              //     fit: BoxFit.cover,
              //     child: SizedBox(
              //       width: screenwdt,
              //       height:screenhgt,
              //       child: VideoPlayer(_controller),
              //     ),
              //   ),
              // )
              _buildVideoPlayer()
            else
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.red,
                ),
              ),

            // // Top black bar
            // Positioned(
            //   top: 0,
            //   left: 0,
            //   right: 0,
            //   child: Container(
            //     color: Colors.black,
            //     height: screenHeight * 0.1,
            //   ),
            // ),

            // // Bottom Progress Bar - ENHANCED
            // Positioned(
            //   bottom: 0,
            //   left: 0,
            //   right: 0,
            //   child: Container(
            //     color: Colors.black,
            //     height: screenHeight * 0.1,
            //     child: Row(
            //       children: [
            //         // Current time display
            //         Padding(
            //           padding: const EdgeInsets.only(left: 16.0),
            //           child: Text(
            //             _formatDuration(_displayPosition),
            //             style: TextStyle(
            //               color: _isSeeking ? Colors.yellow : Colors.white,
            //               fontSize: 12,
            //               fontWeight: _isSeeking ? FontWeight.bold : FontWeight.normal,
            //             ),
            //           ),
            //         ),
                    
            //         // Enhanced Progress slider
            //         Expanded(
            //           child: Padding(
            //             padding: const EdgeInsets.symmetric(horizontal: 12.0),
            //             child: SliderTheme(
            //               data: SliderTheme.of(context).copyWith(
            //                 activeTrackColor: (_isSeeking || _isActuallySeekingVideo) ? Colors.yellow : Colors.red,
            //                 inactiveTrackColor: Colors.white.withOpacity(0.3),
            //                 thumbColor: (_isSeeking || _isActuallySeekingVideo) ? Colors.yellow : Colors.red,
            //                 thumbShape: RoundSliderThumbShape(
            //                   enabledThumbRadius: (_isSeeking || _isActuallySeekingVideo) ? 8.0 : 6.0,
            //                 ),
            //                 trackHeight: (_isSeeking || _isActuallySeekingVideo) ? 4.0 : 3.0,
            //                 overlayShape: const RoundSliderOverlayShape(
            //                   overlayRadius: 12.0,
            //                 ),
            //               ),
            //               child: Slider(
            //                 value: _displayPosition.clamp(0.0, _adjustedTotalDuration),
            //                 max: _adjustedTotalDuration,
            //                 onChanged: (value) {
            //                   if (!(_isSeeking || _isActuallySeekingVideo)) { // Only allow manual seeking when not in any seeking state
            //                     final adjustedEndTime = _totalDuration - 15;
            //                     final clampedValue = value.clamp(0.0, adjustedEndTime);
            //                     setState(() {
            //                       _isActuallySeekingVideo = true;
            //                       _currentPosition = clampedValue;
            //                     });
            //                     _controller.seekTo(Duration(seconds: clampedValue.toInt()));
            //                     // Don't use timer for manual seeking - reset immediately after seek completes
            //                     Future.delayed(const Duration(milliseconds: 200), () {
            //                       if (mounted) {
            //                         setState(() {
            //                           _isActuallySeekingVideo = false;
            //                         });
            //                       }
            //                     });
            //                   }
            //                 },
            //               ),
            //             ),
            //           ),
            //         ),
                    
            //         // Total duration display
            //         Padding(
            //           padding: const EdgeInsets.only(right: 16.0),
            //           child: Text(
            //             _formatDuration(_adjustedTotalDuration),
            //             style: const TextStyle(color: Colors.white, fontSize: 12),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            // // Enhanced seeking indicator - Show for 3 seconds
            // if (_showSeekingIndicator)
            //   Positioned(
            //     top: screenHeight * 0.4,
            //     left: 0,
            //     right: 0,
            //     child: Center(
            //       child: Container(
            //         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            //         decoration: BoxDecoration(
            //           color: Colors.black.withOpacity(0.9),
            //           borderRadius: BorderRadius.circular(25),
            //           border: Border.all(color: Colors.yellow, width: 2),
            //         ),
            //         child: Column(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             Text(
            //               '${_pendingSeekSeconds > 0 ? "⏩ +" : "⏪ "}${_pendingSeekSeconds}s',
            //               style: const TextStyle(
            //                 color: Colors.yellow,
            //                 fontSize: 20,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //             const SizedBox(height: 4),
            //             Text(
            //               _formatDuration(_targetSeekPosition.inSeconds.toDouble()),
            //               style: const TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 14,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _seekTimer?.cancel();
    _seekIndicatorTimer?.cancel();
    _controller.dispose();
    _mainFocusNode.dispose();
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    KeepScreenOn.turnOff();
    super.dispose();
  }
}