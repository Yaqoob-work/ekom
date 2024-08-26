import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:video_player/video_player.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class VideoMovieScreen extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;
  final List<dynamic> channelList;

  VideoMovieScreen(
      {required this.videoUrl,
      required this.videoTitle,
      required this.channelList,
      required String videoBanner,
      required Null Function(bool focused) onFabFocusChanged,
      required String genres,
      required String videoType,
      required String url,
      required String type});

  @override
  _VideoMovieScreenState createState() => _VideoMovieScreenState();
}

class _VideoMovieScreenState extends State<VideoMovieScreen>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _controlsVisible = true;
  late Timer _hideControlsTimer;
  Duration _totalDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  bool _isBuffering = false;
  Duration _lastKnownPosition = Duration.zero;
  bool _wasPlayingBeforeDisconnection = false;
  bool _isConnected = true;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final FocusNode screenFocusNode = FocusNode();
  final FocusNode playPauseFocusNode = FocusNode();
  final FocusNode rewindFocusNode = FocusNode();
  final FocusNode forwardFocusNode = FocusNode();
  final FocusNode backFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
    KeepScreenOn.turnOn();
    _startHideControlsTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(screenFocusNode);
    });

    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      print("Connectivity changed: $result");
      _updateConnectionStatus(result);
    });
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    try {
      await _controller.initialize();
      setState(() {
        _totalDuration = _controller.value.duration;
      });
      _controller.play();
      _startPositionUpdater();
      _controller.addListener(_videoListener);
    } catch (error) {
      print('Net error: $error');
      _handleNetworkError();
    }
  }

  void _handleNetworkError() {
    _wasPlayingBeforeDisconnection = _controller.value.isPlaying;
    _lastKnownPosition = _controller.value.position;
    _controller.pause();
    Future.delayed(Duration(seconds: 5), () {
      if (!_controller.value.isPlaying) {
        _reinitializeVideo();
      }
    });
  }

  Future<void> _reinitializeVideo() async {
    final currentPosition = _lastKnownPosition;
    await _controller.dispose();
    
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    try {
      await _controller.initialize();
      await _controller.seekTo(currentPosition);
      setState(() {
        _totalDuration = _controller.value.duration;
        _currentPosition = currentPosition;
      });
      if (_wasPlayingBeforeDisconnection) {
        _controller.play();
      }
      _controller.addListener(_videoListener);
    } catch (error) {
      print('Error reinitializing video: $error');
      _handleNetworkError();
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    bool wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;

    if (!wasConnected && _isConnected) {
      if (!_controller.value.isPlaying && !_controller.value.isBuffering && _controller.value.isInitialized) {
        _controller.play();
      }
    } else if (wasConnected && !_isConnected) {
      if (_controller.value.isPlaying) {
        _controller.pause();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_controller.value.isPlaying) {
      _controller.pause();
    }
    _controller.removeListener(_videoListener);
    _controller.dispose();
    _hideControlsTimer.cancel();
    screenFocusNode.dispose();
    playPauseFocusNode.dispose();
    rewindFocusNode.dispose();
    forwardFocusNode.dispose();
    backFocusNode.dispose();
    _connectivitySubscription.cancel();
    KeepScreenOn.turnOff();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lastKnownPosition = _controller.value.position;
      _controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      _controller.seekTo(_lastKnownPosition);
      _controller.play();
    }
  }

  void _videoListener() {
    setState(() {
      _isBuffering = _controller.value.isBuffering;
      if (!_isBuffering) {
        _lastKnownPosition = _controller.value.position;
      }
    });

    if (!_isBuffering && _controller.value.isInitialized && !_controller.value.isPlaying) {
      Future.delayed(Duration(seconds: 2), () {
        if (!_controller.value.isPlaying) {
          _controller.play();
        }
      });
    }

    if (_controller.value.hasError) {
      print('Video error: ${_controller.value.errorDescription}');
      _handleNetworkError();
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer = Timer(Duration(seconds: 10), () {
      setState(() {
        _controlsVisible = false;
      });
    });
  }

  void _resetHideControlsTimer() {
    _hideControlsTimer.cancel();
    setState(() {
      _controlsVisible = true;
    });
    _startHideControlsTimer();
  }

  void _startPositionUpdater() {
    Timer.periodic(Duration(seconds: 1), (_) {
      if (_controller.value.isInitialized) {
        setState(() {
          _currentPosition = _controller.value.position;
        });
      }
    });
  }

  void _onRewind() {
    _controller.seekTo(_controller.value.position - Duration(minutes: 1));
    _resetHideControlsTimer();
  }

  void _onForward() {
    _controller.seekTo(_controller.value.position + Duration(minutes: 1));
    _resetHideControlsTimer();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    _resetHideControlsTimer();
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        focusNode: screenFocusNode,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.mediaPlayPause) {
              _togglePlayPause();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _onRewind();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _onForward();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
                event.logicalKey == LogicalKeyboardKey.arrowDown) {
              _resetHideControlsTimer();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.escape) {
              _navigateBack();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: _resetHideControlsTimer,
          child: Stack(
            children: [
              Center(
                child: _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: 16 / 9,
                        child: VideoPlayer(_controller),
                      )
                    : CircularProgressIndicator(),
              ),
              if (_controlsVisible)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                                color: Colors.black.withOpacity(0.5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: IconButton(
                                    icon: Icon(
                                      _controller.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: highlightColor,
                                    ),
                                    onPressed: _togglePlayPause,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Text(
                                    _formatDuration(_currentPosition),
                                    style: TextStyle(
                                        color: highlightColor, fontSize: 20),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: Center(
                                  child: VideoProgressIndicator(
                                    _controller,
                                    allowScrubbing: true,
                                    colors: VideoProgressColors(
                                        playedColor: borderColor,
                                        bufferedColor: Colors.green,
                                        backgroundColor: Colors.yellow),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Text(
                                    _formatDuration(_totalDuration),
                                    style: TextStyle(
                                        color: highlightColor, fontSize: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}