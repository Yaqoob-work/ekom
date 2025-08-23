





import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
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
class CustomYoutubePlayer extends StatefulWidget {
  final VideoData videoData;
  final List<VideoData> playlist;

  const CustomYoutubePlayer({
    Key? key,
    required this.videoData,
    required this.playlist,
  }) : super(key: key);

  @override
  _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
}

class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
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
    KeepScreenOn.turnOn(); 
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
      // String? videoId = YoutubePlayer.convertUrlToId('Nq2wYlWFucg');
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
          // startAt: 10, // START FROM 10 SECONDS - SKIP FIRST 10 SECONDS
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
    KeepScreenOn.turnOff();

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



