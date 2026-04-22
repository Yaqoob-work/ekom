// // import 'package:flutter/material.dart';
// // import 'package:flutter_vlc_player/flutter_vlc_player.dart';

// // class VideoScreen extends StatefulWidget {
// //   final String videoUrl;
// //   final String name;
// //   final bool liveStatus;
// //   final String updatedAt;
// //   final List<dynamic> channelList;
// //   final String bannerImageUrl;
// //   final int? videoId;
// //   final String source;

// //   VideoScreen({
// //     required this.videoUrl,
// //     required this.updatedAt,
// //     required this.channelList,
// //     required this.bannerImageUrl,
// //     required this.videoId,
// //     required this.source,
// //     required this.name,
// //     required this.liveStatus,
// //   });

// //   @override
// //   _VideoScreenState createState() => _VideoScreenState();
// // }

// // class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
// //   late VlcPlayerController _videoPlayerController;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // Controller initialize karein
// //     _videoPlayerController = VlcPlayerController.network(
// //       widget.videoUrl,
// //       hwAcc: HwAcc.full, // Hardware acceleration for better performance
// //       autoPlay: true,    // Video load hote hi play shuru ho jayega
// //       options: VlcPlayerOptions(),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     // Memory leak rokne ke liye controller dispose karna zaroori hai
// //     _videoPlayerController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       // appBar: AppBar(title: const Text("VLC Player Demo")),
// //       body: Center(
// //         child: VlcPlayer(
// //           controller: _videoPlayerController,
// //           aspectRatio: 16 / 9, // Video ka size maintain karne ke liye
// //           placeholder: const Center(
// //             child: CircularProgressIndicator(), // Buffering ke waqt loader dikhega
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // import 'package:flutter/material.dart';
// // import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
// // import 'package:video_player/video_player.dart';

// // class VideoScreen extends StatefulWidget {
// //   final String videoUrl;
// //   final String name;
// //   final bool liveStatus;
// //   final String updatedAt;
// //   final List<dynamic> channelList;
// //   final String bannerImageUrl;
// //   final int? videoId;
// //   final String source;

// //   VideoScreen({
// //     required this.videoUrl,
// //     required this.updatedAt,
// //     required this.channelList,
// //     required this.bannerImageUrl,
// //     required this.videoId,
// //     required this.source,
// //     required this.name,
// //     required this.liveStatus,
// //   });

// //   @override
// //   _VideoScreenState createState() => _VideoScreenState();
// // }

// // class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
// //   // CHANGE 1: 'late' hataya aur '?' lagaya taaki ye shuru mein null reh sake
// //   VideoPlayerController? _controller;
// //   bool _isError = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initPlayerWithSecureUrl();
// //   }

// // Future<void> _initPlayerWithSecureUrl() async {
// //   try {
// //     // String secureUrl = await SecureUrlService.getSecureUrl(
// //     //     '',
// //     //     expirySeconds: 6;

// //     // print('DEBUG: Generated URL: $secureUrl'); // Check if this URL works in a browser

// //     if (!mounted) return;

// //     // final controller = VideoPlayerController.networkUrl(
// //     //   Uri.parse('https://dashboard.cpplayers.com/api/video/play/FRpCb9WhFXIeHpFFtNO79947oThNFJ5zxrRbHwkY54KwM84YPDcDTQnhhusKhORc'),
// //     //   // Uncomment these if your server requires them to prevent 403 Forbidden errors
// //     //   /* httpHeaders: {
// //     //     'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36...',
// //     //   },
// //     //   */
// //     // );

// //     // CHANGE 2: Naya controller banaya
// //       final controller = VideoPlayerController.networkUrl(
// //         Uri.parse('https://dashboard.cpplayers.com/api/video/play/J3yuPm5bSxkXCIeksC6oaeetNqS2B9IGGcGcyaYWM1iQDXAY4EP0EMaXzNWfwwkg'),
// //         // 👇 Add these headers to fix the 403 Error
// //         httpHeaders: {
// //           'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
// //           'Referer': 'https://dashboard.cpplayers.com/', // Important: Tells the server you are coming from their site
// //         },
// //       );

// //     // --- ADD THIS LISTENER HERE ---
// //     controller.addListener(() {
// //       // This prints errors that happen during playback/buffering
// //       if (controller.value.hasError) {
// //         print("🔴 VIDEO ERROR: ${controller.value.errorDescription}");
// //       }

// //       // Optional: Print buffering status to see if it's stuck loading
// //       if (controller.value.isBuffering) {
// //         print("🟡 Video is Buffering...");
// //       }
// //     });
// //     // -----------------------------

// //     await controller.initialize();

// //     if (mounted) {
// //       setState(() {
// //         _controller = controller;
// //         _controller!.play();
// //       });
// //     }
// //   } catch (e, stackTrace) {
// //     // Print the full stack trace to see exactly where it failed
// //     print("🔴 Initialization Exception: $e");
// //     print("Stack Trace: $stackTrace");

// //     if (mounted) {
// //       setState(() {
// //         _isError = true;
// //       });
// //     }
// //   }
// // }

// //   @override
// //   void dispose() {
// //     // CHANGE 4: Null check ke sath dispose karein
// //     _controller?.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("Flutter Video Player")),
// //       body: Center(
// //         child: _isError
// //             ? const Text("Video Play Error", style: TextStyle(color: Colors.red))
// //             // CHANGE 5: Check karein ki controller null to nahi hai
// //             : (_controller != null && _controller!.value.isInitialized)
// //                 ? AspectRatio(
// //                     aspectRatio: _controller!.value.aspectRatio,
// //                     child: Stack(
// //                       alignment: Alignment.bottomCenter,
// //                       children: [
// //                         VideoPlayer(_controller!),
// //                         _buildControls(),
// //                       ],
// //                     ),
// //                   )
// //                 : const CircularProgressIndicator(), // Jab tak null hai, loader dikhega
// //       ),
// //     );
// //   }

// //   Widget _buildControls() {
// //     // Safety check
// //     if (_controller == null) return const SizedBox.shrink();

// //     return Container(
// //       color: Colors.black45,
// //       height: 50,
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           IconButton(
// //             icon: Icon(
// //               _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
// //               color: Colors.white,
// //             ),
// //             onPressed: () {
// //               setState(() {
// //                 _controller!.value.isPlaying
// //                     ? _controller!.pause()
// //                     : _controller!.play();
// //               });
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // import 'dart:async';
// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:cached_network_image/cached_network_image.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// // import 'package:keep_screen_on/keep_screen_on.dart';
// // import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
// // import 'package:mobi_tv_entertainment/components/widgets/small_widgets/rainbow_page.dart';
// // import 'package:mobi_tv_entertainment/main.dart';

// // class GlobalVariables {
// //   static String unUpdatedUrl = '';
// //   static Duration position = Duration.zero;
// //   static Duration duration = Duration.zero;
// //   static String banner = '';
// //   static String name = '';
// //   static bool liveStatus = false;
// // }

// // class RefreshPageEvent {
// //   final String pageId;
// //   RefreshPageEvent(this.pageId);
// // }

// // class VideoScreen extends StatefulWidget {
// //   final String videoUrl;
// //   final String name;
// //   final bool liveStatus;
// //   final String updatedAt;
// //   final List<dynamic> channelList;
// //   final String bannerImageUrl;
// //   final int? videoId;
// //   final String source;

// //   VideoScreen({
// //     required this.videoUrl,
// //     required this.updatedAt,
// //     required this.channelList,
// //     required this.bannerImageUrl,
// //     required this.videoId,
// //     required this.source,
// //     required this.name,
// //     required this.liveStatus,
// //   });

// //   @override
// //   _VideoScreenState createState() => _VideoScreenState();
// // }

// // class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
// //   VlcPlayerController? _controller;
// //   bool _controlsVisible = true;
// //   late Timer _hideControlsTimer;
// //   bool _isBuffering = false;
// //   bool _isVideoInitialized = false;
// //   int _focusedIndex = 0;
// //   List<FocusNode> focusNodes = [];
// //   final ScrollController _scrollController = ScrollController();
// //   final FocusNode playPauseButtonFocusNode = FocusNode();

// //   bool _loadingVisible = false;
// //   Duration _lastKnownPosition = Duration.zero;
// //   Timer? _networkCheckTimer;
// //   bool _wasDisconnected = false;
// //   String? _currentModifiedUrl;

// //   bool _isAttemptingResume = false;
// //   DateTime _lastPlayingTime = DateTime.now();
// //   Duration _lastPositionCheck = Duration.zero;
// //   int _stallCounter = 0;
// //   bool _hasStartedPlaying = false;

// //   bool _isScrubbing = false;

// //   Map<String, Uint8List> _bannerCache = {};

// //   // 🆕 केवल disposal के लिए flag
// //   bool _isDisposing = false;

// //   Uint8List _getCachedImage(String base64String) {
// //     try {
// //       if (!_bannerCache.containsKey(base64String)) {
// //         _bannerCache[base64String] = base64Decode(base64String.split(',').last);
// //       }
// //       return _bannerCache[base64String]!;
// //     } catch (e) {
// //       print('Error procesando imagen: $e');
// //       return Uint8List.fromList([0, 0, 0, 0]);
// //     }
// //   }

// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addObserver(this);
// //     KeepScreenOn.turnOn();

// //     _focusedIndex = widget.channelList.indexWhere(
// //       (channel) => channel.id.toString() == widget.videoId.toString(),
// //     );
// //     _focusedIndex = (_focusedIndex >= 0) ? _focusedIndex : 0;

// //     focusNodes = List.generate(
// //       widget.channelList.length,
// //       (index) => FocusNode(),
// //     );

// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _focusAndScrollToInitialItem();
// //     });
// //     // _initializeVLCController(widget.videoUrl);
// //     _initPlayerWithSecureUrl();
// //     _startHideControlsTimer();
// //     _startNetworkMonitor();
// //     _startPositionUpdater();
// //   }

// //   // 🆕 Safe disposal method
// //   Future<void> _safeDispose() async {
// //     if (_isDisposing) return;

// //     _isDisposing = true;
// //     print("🔄 Safe disposal started...");

// //     // Cancel all timers
// //     _hideControlsTimer.cancel();
// //     _networkCheckTimer?.cancel();
// //     _seekTimer?.cancel();

// //     // Dispose focus nodes
// //     focusNodes.forEach((node) => node.dispose());
// //     playPauseButtonFocusNode.dispose();
// //     _scrollController.dispose();

// //     // Dispose VLC controller safely
// //     try {
// //       if (_controller != null) {
// //         _controller?.removeListener(_vlcListener);
// //         await _controller?.stop();
// //         await _controller?.dispose();
// //         _controller = null;
// //         print("✅ VLC Controller safely disposed");
// //       }
// //     } catch (e) {
// //       print("⚠️ Warning during VLC controller disposal: $e");
// //     }

// //     KeepScreenOn.turnOff();
// //     WidgetsBinding.instance.removeObserver(this);

// //     print("✅ Safe disposal completed");
// //   }

// //   @override
// //   void dispose() {
// //     print("🗑️ VideoScreen dispose called");
// //     _safeDispose();
// //     super.dispose();
// //   }

// //   // 🆕 Improved back button handler
// //   Future<bool> _onWillPop() async {
// //     print("🔙 Back button pressed");

// //     if (_isDisposing) {
// //       return false;
// //     }

// //     setState(() {
// //       _loadingVisible = true;
// //     });

// //     // Safe disposal और फिर navigate
// //     await _safeDispose();

// //     return true;
// //   }

// //   void _focusAndScrollToInitialItem() {
// //     if (_focusedIndex < 0 || _focusedIndex >= focusNodes.length || !mounted) {
// //       return;
// //     }

// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (!_scrollController.hasClients) return;

// //       final double itemHeight = (screenhgt * 0.18) + 16.0;
// //       final double targetOffset = (itemHeight * _focusedIndex) - 40.0;
// //       final double clampedOffset = targetOffset.clamp(
// //         _scrollController.position.minScrollExtent,
// //         _scrollController.position.maxScrollExtent,
// //       );
// //       _scrollController.jumpTo(clampedOffset);

// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         if (!mounted) return;
// //         if (widget.liveStatus == false) {
// //           FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
// //         } else if (widget.channelList.isNotEmpty &&
// //             _focusedIndex < focusNodes.length) {
// //           FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
// //         } else {
// //           FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
// //         }
// //       });
// //     });
// //   }

// //   void _changeFocusAndScroll(int newIndex) {
// //     if (newIndex < 0 || newIndex >= widget.channelList.length) {
// //       return;
// //     }

// //     setState(() {
// //       _focusedIndex = newIndex;
// //     });

// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (!_scrollController.hasClients || !mounted) return;

// //       final double itemHeight = (screenhgt * 0.18) + 16.0;
// //       final double targetOffset = (itemHeight * _focusedIndex) - 40.0;
// //       final double clampedOffset = targetOffset.clamp(
// //         _scrollController.position.minScrollExtent,
// //         _scrollController.position.maxScrollExtent,
// //       );
// //       _scrollController.jumpTo(clampedOffset);

// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         if (mounted) {
// //           FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
// //         }
// //       });
// //     });
// //   }

// //   Future<void> _initPlayerWithSecureUrl() async {
// //     try {
// //       // 1. Pehle URL ko secure (resolve) karein
// //       String secureUrl = await SecureUrlService.getSecureUrl(widget.videoUrl,
// //           expirySeconds: 10);
// //       print('secureUrlinitializing : $secureUrl');
// //       if (!mounted) return;

// //       // 2. Ab secure URL ko initialize function mein bhejein
// //       // Yeh function andar jaakar _buildVlcUrl call karega aur caching jod dega
// //       _initializeVLCController(secureUrl);
// //     } catch (e) {
// //       print("Secure URL error: $e");
// //       // Fallback: Agar secure fail ho to original try karein
// //       await _initializeVLCController(widget.videoUrl);
// //     }
// //   }

// //   void _handleKeyEvent(RawKeyEvent event) {
// //     if (event is RawKeyDownEvent) {
// //       _resetHideControlsTimer();

// //       switch (event.logicalKey) {
// //         case LogicalKeyboardKey.arrowUp:
// //           if (playPauseButtonFocusNode.hasFocus) {
// //             if (widget.liveStatus == false && widget.channelList.isNotEmpty) {
// //               FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
// //             }
// //           } else if (_focusedIndex > 0) {
// //             _changeFocusAndScroll(_focusedIndex - 1);
// //           }
// //           break;

// //         case LogicalKeyboardKey.arrowDown:
// //           if (_focusedIndex < widget.channelList.length - 1) {
// //             _changeFocusAndScroll(_focusedIndex + 1);
// //           } else if (_focusedIndex < widget.channelList.length) {
// //             FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
// //           }
// //           break;

// //         case LogicalKeyboardKey.arrowRight:
// //           if (widget.liveStatus == false) {
// //             _seekForward();
// //           }
// //           if (focusNodes.any((node) => node.hasFocus)) {
// //             FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
// //           }
// //           break;

// //         case LogicalKeyboardKey.arrowLeft:
// //           if (widget.liveStatus == false) {
// //             _seekBackward();
// //           }
// //           if (playPauseButtonFocusNode.hasFocus &&
// //               widget.channelList.isNotEmpty) {
// //             FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
// //           }
// //           break;

// //         case LogicalKeyboardKey.select:
// //         case LogicalKeyboardKey.enter:
// //           if (widget.liveStatus == false) {
// //             _togglePlayPause();
// //           } else {
// //             if (playPauseButtonFocusNode.hasFocus ||
// //                 widget.channelList.isEmpty) {
// //               _togglePlayPause();
// //             } else {
// //               _onItemTap(_focusedIndex);
// //             }
// //           }
// //           break;
// //       }
// //     }
// //   }

// //   Future<void> _attemptResumeLiveStream() async {
// //     if (!mounted ||
// //         _isAttemptingResume ||
// //         _controller == null ||
// //         widget.liveStatus == false) {
// //       return;
// //     }

// //     setState(() {
// //       _isAttemptingResume = true;
// //       _loadingVisible = true;
// //     });
// //     print("⚠️ Detectado atasco en Live stream. Intentando resumir...");

// //     try {
// //       final urlToResume = _buildVlcUrl(_currentModifiedUrl ?? widget.videoUrl);
// //       await _retryPlayback(urlToResume, 3);

// //       _lastPlayingTime = DateTime.now();
// //       _stallCounter = 0;
// //       _lastPositionCheck = Duration.zero;
// //       print("✅ Intento de resumen finalizado.");
// //     } catch (e) {
// //       print("❌ Error durante el resumen del live stream: $e");
// //     } finally {
// //       if (mounted) {
// //         setState(() {
// //           _isAttemptingResume = false;
// //         });
// //       }
// //     }
// //   }

// //   void _vlcListener() {
// //     if (!mounted || _controller == null || !_controller!.value.isInitialized)
// //       return;

// //     final VlcPlayerValue value = _controller!.value;
// //     final bool isBuffering = value.isBuffering;
// //     final PlayingState playingState = value.playingState;

// //     if (widget.liveStatus == true && !_isAttemptingResume) {
// //       if (playingState == PlayingState.playing) {
// //         _lastPlayingTime = DateTime.now();
// //         if (!_hasStartedPlaying) {
// //           _hasStartedPlaying = true;
// //         }
// //       } else if (playingState == PlayingState.buffering && _hasStartedPlaying) {
// //         final stalledDuration = DateTime.now().difference(_lastPlayingTime);
// //         if (stalledDuration > Duration(seconds: 8)) {
// //           print(
// //               "⚠️ Atasco (Listener): Buffering por ${stalledDuration.inSeconds} seg.");
// //           _attemptResumeLiveStream();
// //           _lastPlayingTime = DateTime.now();
// //         }
// //       } else if (playingState == PlayingState.error) {
// //         print("⚠️ Atasco (Listener): Player en estado de error.");
// //         _attemptResumeLiveStream();
// //         _lastPlayingTime = DateTime.now();
// //       } else if ((playingState == PlayingState.stopped ||
// //               playingState == PlayingState.ended) &&
// //           _hasStartedPlaying) {
// //         final stalledDuration = DateTime.now().difference(_lastPlayingTime);
// //         if (stalledDuration > Duration(seconds: 5)) {
// //           print("⚠️ Atasco (Listener): Player parado inesperadamente.");
// //           _attemptResumeLiveStream();
// //           _lastPlayingTime = DateTime.now();
// //         }
// //       } else if (playingState == PlayingState.paused) {
// //         _lastPlayingTime = DateTime.now();
// //       }
// //     }

// //     if (mounted) {
// //       setState(() {
// //         _isBuffering = isBuffering;

// //         if (playingState == PlayingState.playing && !isBuffering) {
// //           _loadingVisible = false;
// //         } else if (playingState == PlayingState.buffering ||
// //             playingState == PlayingState.initializing) {
// //           _loadingVisible = true;
// //         }

// //         if (_isAttemptingResume) {
// //           _loadingVisible = true;
// //         }
// //       });
// //     }
// //   }

// //   void _startPositionUpdater() {
// //     Timer.periodic(Duration(seconds: 2), (_) {
// //       if (!mounted ||
// //           _controller == null ||
// //           !_controller!.value.isInitialized) {
// //         return;
// //       }

// //       final VlcPlayerValue value = _controller!.value;
// //       final Duration currentPosition = value.position;

// //       if (mounted && !_isScrubbing) {
// //         setState(() {
// //           _lastKnownPosition = currentPosition;
// //         });
// //       }

// //       if (widget.liveStatus == true &&
// //           !_isAttemptingResume &&
// //           _hasStartedPlaying) {
// //         if (value.playingState == PlayingState.playing) {
// //           if (_lastPositionCheck != Duration.zero &&
// //               currentPosition == _lastPositionCheck) {
// //             _stallCounter++;
// //             print(
// //                 "⚠️ Posición atascada (Fotograma Congelado). Contador: $_stallCounter");
// //           } else {
// //             _stallCounter = 0;
// //           }

// //           if (_stallCounter >= 3) {
// //             print("🔴 ATASCADO (Fotograma Congelado). Intentando resumen...");
// //             _attemptResumeLiveStream();
// //             _stallCounter = 0;
// //           }
// //         } else {
// //           _stallCounter = 0;
// //         }
// //         _lastPositionCheck = currentPosition;
// //       }
// //     });
// //   }

// //   void _scrollToFocusedItem() {
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (_focusedIndex < 0 ||
// //           !_scrollController.hasClients ||
// //           _focusedIndex >= focusNodes.length) {
// //         return;
// //       }
// //       final context = focusNodes[_focusedIndex].context;
// //       if (context == null) return;

// //       Scrollable.ensureVisible(
// //         context,
// //         duration: const Duration(milliseconds: 300),
// //         curve: Curves.easeInOut,
// //         alignment: 0.01,
// //       );
// //     });
// //   }

// //   void _startNetworkMonitor() {
// //     _networkCheckTimer = Timer.periodic(Duration(seconds: 5), (_) async {
// //       bool isConnected = await _isInternetAvailable();
// //       if (!isConnected && !_wasDisconnected) {
// //         _wasDisconnected = true;
// //         print("Red desconectada");
// //       } else if (isConnected && _wasDisconnected) {
// //         _wasDisconnected = false;
// //         print("Red reconectada. Intentando resumir video...");
// //         if (_controller?.value.isInitialized ?? false) {
// //           _onNetworkReconnected();
// //         }
// //       }
// //     });
// //   }

// //   // Future<void> _onNetworkReconnected() async {
// //   //   if (_controller == null || _currentModifiedUrl == null) return;

// //   //   final fullUrl = _buildVlcUrl(_currentModifiedUrl!);
// //   //   print("Reconectando a: $fullUrl");

// //   //   try {
// //   //     if (widget.liveStatus == true) {
// //   //       await _retryPlayback(fullUrl, 3);
// //   //     } else {
// //   //       await _retryPlayback(fullUrl, 3);
// //   //       if (_lastKnownPosition != Duration.zero) {
// //   //         _seekToPosition(_lastKnownPosition);
// //   //       }
// //   //       await _controller!.play();
// //   //     }
// //   //   } catch (e) {
// //   //     print("Error durante reconexión: $e");
// //   //   }
// //   // }

// //   Future<void> _onNetworkReconnected() async {
// //     if (_controller == null || _currentModifiedUrl == null) return;

// //     final fullUrl = _buildVlcUrl(_currentModifiedUrl!);
// //     print("Reconectando a: $fullUrl");

// //     try {
// //       if (widget.liveStatus == true) {
// //         // --- Lógica de Live Stream (sin cambios) ---
// //         print("Reconexión Live Stream: Reiniciando stream...");
// //         await _retryPlayback(fullUrl, 3);
// //       } else {
// //         // --- 🆕 Lógica MEJORADA para VOD (video no-en-vivo) ---
// //         print("Reconexión VOD: Intentando resumir desde $_lastKnownPosition");

// //         // setState(() { _loadingVisible = true; }); // Opcional: mostrar loading

// //         try {
// //           // Plan A: Intentar "desatascar" el player sin recargar.
// //           // Esto es mucho más rápido y fluido para el usuario.

// //           // Pausar primero para asegurar el estado
// //           await _controller!.pause();
// //           await Future.delayed(const Duration(milliseconds: 100));

// //           if (_lastKnownPosition != Duration.zero) {
// //             // _seekToPosition ya incluye el comando de play() al final.
// //             // Esto forzará al player a re-bufferizar desde ese punto.
// //             await _seekToPosition(_lastKnownPosition);
// //           } else {
// //             // Si no hay posición guardada, solo darle play
// //             await _controller!.play();
// //           }
// //           print("✅ VOD Resumido (Plan A) tras reconexión.");
// //         } catch (e) {
// //           // Plan B: Si el Plan A falla (el controller está muy roto),
// //           // recurrir al método de recarga completa como último recurso.
// //           print("⚠️ Plan A falló. Recurriendo a Plan B (Recarga). Error: $e");

// //           await _retryPlayback(fullUrl, 3);

// //           // Esperar un momento a que el video se cargue después de 'setMedia'
// //           await Future.delayed(const Duration(seconds: 2));

// //           if (_lastKnownPosition != Duration.zero) {
// //             await _seekToPosition(_lastKnownPosition);
// //           }
// //           print("✅ VOD Resumido (Plan B) tras reconexión.");
// //         }
// //       }
// //     } catch (e) {
// //       print("❌ Error crítico durante reconexión: $e");
// //     }
// //     // finally {
// //     //   if (mounted) setState(() { _loadingVisible = false; }); // Opcional
// //     // }
// //   }

// //   Future<bool> _isInternetAvailable() async {
// //     try {
// //       final result = await InternetAddress.lookup('google.com');
// //       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
// //     } catch (_) {
// //       return false;
// //     }
// //   }

// //   String _buildVlcUrl(String baseUrl) {
// //     final String networkCaching = "network-caching=60000";
// //     final String liveCaching = "live-caching=60000";
// //     final String fileCaching = "file-caching=20000";
// //     final String rtspTcp = "rtsp-tcp";

// //     if (widget.liveStatus == true) {
// //       return '$baseUrl?$networkCaching&$liveCaching&$fileCaching&$rtspTcp';
// //     } else {
// //       return '$baseUrl?$networkCaching&$fileCaching&$rtspTcp';
// //     }
// //   }

// //   bool _isSeeking = false;
// //   Future<void> _seekToPosition(Duration position) async {
// //     if (_isSeeking || _controller == null) return;
// //     _isSeeking = true;
// //     try {
// //       print("Buscando posición: $position");
// //       await _controller!.seekTo(position);
// //       await _controller!.play();
// //     } catch (e) {
// //       print("Error durante seek: $e");
// //     } finally {
// //       await Future.delayed(Duration(milliseconds: 500));
// //       _isSeeking = false;
// //     }
// //   }

// //   Future<void> _initializeVLCController(String baseUrl) async {
// //     if (_isDisposing || !mounted) return;

// //   // 1. Clear previous state immediately
// //   setState(() {
// //     _isVideoInitialized = false;
// //     _loadingVisible = true;
// //   });

// //   // 2. Cleanup old controller synchronously if possible
// //   final oldController = _controller;
// //   _controller = null;
// //   await oldController?.dispose();

// //   // 3. Setup new instance
// //   try {
// //     // setState(() {
// //     //   _loadingVisible = true;
// //     // });

// //     _currentModifiedUrl = baseUrl;
// //     final String fullVlcUrl = _buildVlcUrl(baseUrl);
// //     // final String fullVlcUrl = baseUrl;
// //     print('fullVlcUrl: $fullVlcUrl');
// //     _lastPlayingTime = DateTime.now();
// //     _lastPositionCheck = Duration.zero;
// //     _stallCounter = 0;
// //     _hasStartedPlaying = false;

// //     print("Inicializando con URL: $fullVlcUrl");

// //     _controller = VlcPlayerController.network(
// //       fullVlcUrl,
// //       hwAcc: HwAcc.auto,
// //       options: VlcPlayerOptions(
// //         video: VlcVideoOptions([
// //           VlcVideoOptions.dropLateFrames(true),
// //           VlcVideoOptions.skipFrames(true),
// //         ]),
// //       ),
// //     );

// //     await _retryPlayback(fullVlcUrl, 3);
// //     _controller!.addListener(_vlcListener);

// //     setState(() {
// //       _isVideoInitialized = true;
// //     });
// //     } catch (e) {
// //      // Handle failure
// //   }
// //   }

// //   Future<void> _retryPlayback(String url, int retries) async {
// //     for (int i = 0; i < retries; i++) {
// //       if (!mounted || _controller == null) return;
// //       try {
// //         print("Intento ${i + 1}/$retries: Deteniendo player...");
// //         await _controller!.stop();
// //         print("Asignando media: $url");
// //         await _controller!.setMediaFromNetwork(url);
// //         await _controller!.play();
// //         print("Comando Play enviado.");
// //         return;
// //       } catch (e) {
// //         print("Reintento ${i + 1} fallido: $e");
// //         if (i < retries - 1) {
// //           await Future.delayed(Duration(seconds: 1));
// //         }
// //       }
// //     }
// //     print("Todos los reintentos fallaron para: $url");
// //   }

// //   Future<void> _onItemTap(int index) async {
// //     setState(() {
// //       _loadingVisible = true;
// //       _focusedIndex = index;
// //     });

// //     var selectedChannel = widget.channelList[index];

// //     String secureUrl = await SecureUrlService.getSecureUrl(
// //         selectedChannel.url.toString(),
// //         expirySeconds: 10);

// //     _currentModifiedUrl = secureUrl;
// //     final String fullVlcUrl = _buildVlcUrl(secureUrl);
// //     print("secure+cached URL: $fullVlcUrl");

// //     _lastPlayingTime = DateTime.now();
// //     _lastPositionCheck = Duration.zero;
// //     _stallCounter = 0;
// //     _hasStartedPlaying = false;

// //     try {
// //       if (_controller != null && _controller!.value.isInitialized) {
// //         await _retryPlayback(fullVlcUrl, 3);
// //         _controller!.addListener(_vlcListener);
// //       } else {
// //         throw Exception("VLC Controller no inicializado");
// //       }
// //       _scrollToFocusedItem();
// //       _resetHideControlsTimer();
// //     } catch (e) {
// //       print("Error cambiando de canal: $e");
// //     }
// //   }

// //   void _togglePlayPause() {
// //     if (_controller != null && _controller!.value.isInitialized) {
// //       _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
// //       _lastPlayingTime = DateTime.now();
// //       _stallCounter = 0;
// //     }
// //     FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
// //     _resetHideControlsTimer();
// //   }

// //   void _resetHideControlsTimer() {
// //     _hideControlsTimer.cancel();
// //     if (!_controlsVisible) {
// //       setState(() {
// //         _controlsVisible = true;
// //       });
// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         if (!mounted) return;
// //         if (widget.liveStatus == false || widget.channelList.isEmpty) {
// //           FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
// //         } else {
// //           FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
// //           _scrollToFocusedItem();
// //         }
// //       });
// //     }
// //     _startHideControlsTimer();
// //   }

// //   void _startHideControlsTimer() {
// //     _hideControlsTimer = Timer(Duration(seconds: 10), () {
// //       if (mounted) {
// //         setState(() {
// //           _controlsVisible = false;
// //         });
// //       }
// //     });
// //   }

// //   int _accumulatedSeekForward = 0;
// //   int _accumulatedSeekBackward = 0;
// //   Timer? _seekTimer;
// //   Duration _previewPosition = Duration.zero;
// //   final int _seekDuration = 5;
// //   final int _seekDelay = 800;

// //   void _seekForward() {
// //     if (_controller == null ||
// //         !_controller!.value.isInitialized ||
// //         _controller!.value.duration <= Duration.zero) return;

// //     _accumulatedSeekForward += _seekDuration;
// //     final newPosition = _controller!.value.position +
// //         Duration(seconds: _accumulatedSeekForward);

// //     setState(() {
// //       _previewPosition = newPosition > _controller!.value.duration
// //           ? _controller!.value.duration
// //           : newPosition;
// //     });

// //     _seekTimer?.cancel();
// //     _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
// //       _seekToPosition(_previewPosition).then((_) {
// //         setState(() {
// //           _accumulatedSeekForward = 0;
// //         });
// //       });
// //     });
// //   }

// //   void _seekBackward() {
// //     if (_controller == null ||
// //         !_controller!.value.isInitialized ||
// //         _controller!.value.duration <= Duration.zero) return;

// //     _accumulatedSeekBackward += _seekDuration;
// //     final newPosition = _controller!.value.position -
// //         Duration(seconds: _accumulatedSeekBackward);

// //     setState(() {
// //       _previewPosition =
// //           newPosition > Duration.zero ? newPosition : Duration.zero;
// //     });

// //     _seekTimer?.cancel();
// //     _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
// //       _seekToPosition(_previewPosition).then((_) {
// //         setState(() {
// //           _accumulatedSeekBackward = 0;
// //         });
// //       });
// //     });
// //   }

// //   String _formatDuration(Duration duration) {
// //     if (duration.isNegative) {
// //       duration = Duration.zero;
// //     }
// //     String twoDigits(int n) => n.toString().padLeft(2, '0');
// //     final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
// //     final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
// //     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
// //   }

// //   void _onScrubStart(DragStartDetails details, BoxConstraints constraints) {
// //     if (_controller == null || _controller!.value.duration <= Duration.zero)
// //       return;

// //     _resetHideControlsTimer();
// //     setState(() {
// //       _isScrubbing = true;
// //       _accumulatedSeekForward = 1;
// //       final double progress =
// //           (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
// //       _previewPosition = _controller!.value.duration * progress;
// //     });
// //   }

// //   void _onScrubUpdate(DragUpdateDetails details, BoxConstraints constraints) {
// //     if (!_isScrubbing ||
// //         _controller == null ||
// //         _controller!.value.duration <= Duration.zero) return;

// //     _resetHideControlsTimer();
// //     final double progress =
// //         (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
// //     final newPosition = _controller!.value.duration * progress;
// //     setState(() {
// //       _previewPosition = newPosition;
// //     });
// //   }

// //   void _onScrubEnd(DragEndDetails details) {
// //     if (!_isScrubbing) return;

// //     _seekToPosition(_previewPosition).then((_) {
// //       setState(() {
// //         _accumulatedSeekForward = 0;
// //       });
// //     });
// //     _resetHideControlsTimer();
// //     setState(() {
// //       _isScrubbing = false;
// //     });
// //   }

// //   Widget _buildVideoPlayer() {
// //     if (!_isVideoInitialized || _controller == null) {
// //       return Center(child: CircularProgressIndicator());
// //     }
// //     return LayoutBuilder(
// //       builder: (context, constraints) {
// //         final screenWidth = constraints.maxWidth;
// //         final screenHeight = constraints.maxHeight;
// //         final videoWidth = _controller!.value.size?.width ?? screenWidth;
// //         final videoHeight = _controller!.value.size?.height ?? screenHeight;
// //         final videoRatio = videoWidth / videoHeight;
// //         final screenRatio = screenWidth / screenHeight;

// //         double scaleX = 1.0;
// //         double scaleY = 1.0;

// //         if (videoRatio < screenRatio) {
// //           scaleX = screenRatio / videoRatio;
// //         } else {
// //           scaleY = videoRatio / screenRatio;
// //         }

// //         return Container(
// //           width: screenWidth,
// //           height: screenHeight,
// //           color: Colors.black,
// //           child: Center(
// //             child: Transform.scale(
// //               scaleX: scaleX,
// //               scaleY: scaleY,
// //               child: VlcPlayer(
// //                 key: ValueKey(_currentModifiedUrl ?? widget.videoUrl),
// //                 controller: _controller!,
// //                 placeholder: Center(child: CircularProgressIndicator()),
// //                 aspectRatio: 16 / 9,
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return WillPopScope(
// //       onWillPop: _onWillPop, // 🆕 Improved back button handler
// //       child: Scaffold(
// //         backgroundColor: Colors.black,
// //         body: SizedBox(
// //           width: screenwdt,
// //           height: screenhgt,
// //           child: Focus(
// //             autofocus: true,
// //             onKey: (node, event) {
// //               if (event is RawKeyDownEvent) {
// //                 _handleKeyEvent(event);
// //                 return KeyEventResult.handled;
// //               }
// //               return KeyEventResult.ignored;
// //             },
// //             child: GestureDetector(
// //               onTap: _resetHideControlsTimer,
// //               child: Stack(
// //                 children: [
// //                   if (_isVideoInitialized && _controller != null)
// //                     _buildVideoPlayer(),
// //                   if (_loadingVisible ||
// //                       !_isVideoInitialized ||
// //                       _isAttemptingResume ||
// //                       (_isBuffering && !_loadingVisible))
// //                     Container(
// //                       color: _loadingVisible || !_isVideoInitialized
// //                           ? Colors.black54
// //                           : Colors.transparent,
// //                       child: Center(
// //                         child: RainbowPage(
// //                           backgroundColor:
// //                               _loadingVisible || !_isVideoInitialized
// //                                   ? Colors.black
// //                                   : Colors.transparent,
// //                         ),
// //                       ),
// //                     ),
// //                   if (_controlsVisible && widget.channelList.isNotEmpty)
// //                     _buildChannelList(),
// //                   _buildControls(),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildChannelList() {
// //     return Positioned(
// //       top: MediaQuery.of(context).size.height * 0.02,
// //       bottom: MediaQuery.of(context).size.height * 0.1,
// //       left: 0,
// //       right: MediaQuery.of(context).size.width * 0.78,
// //       child: ListView.builder(
// //         controller: _scrollController,
// //         itemCount: widget.channelList.length,
// //         itemBuilder: (context, index) {
// //           final channel = widget.channelList[index];
// //           final String channelId = channel.id?.toString() ?? '';
// //           final bool isBase64 =
// //               channel.banner?.startsWith('data:image') ?? false;
// //           final bool isFocused = _focusedIndex == index;

// //           return Padding(
// //             padding:
// //                 const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
// //             child: Focus(
// //               focusNode: focusNodes[index],
// //               onFocusChange: (hasFocus) {
// //                 if (hasFocus) {
// //                   print("✅ FOCO GANADO: Canal en índice $index");
// //                   _scrollToFocusedItem();
// //                 }
// //               },
// //               child: GestureDetector(
// //                 onTap: () {
// //                   _onItemTap(index);
// //                   _resetHideControlsTimer();
// //                 },
// //                 child: Container(
// //                   width: screenwdt * 0.3,
// //                   height: screenhgt * 0.18,
// //                   decoration: BoxDecoration(
// //                     border: Border.all(
// //                       color: isFocused && !playPauseButtonFocusNode.hasFocus
// //                           ? const Color.fromARGB(211, 155, 40, 248)
// //                           : Colors.transparent,
// //                       width: 5.0,
// //                     ),
// //                     borderRadius: BorderRadius.circular(10),
// //                     color: isFocused ? Colors.black26 : Colors.transparent,
// //                   ),
// //                   child: ClipRRect(
// //                     borderRadius: BorderRadius.circular(6),
// //                     child: Stack(
// //                       children: [
// //                         Positioned.fill(
// //                           child: Opacity(
// //                             opacity: 0.6,
// //                             child: isBase64
// //                                 ? Image.memory(
// //                                     _bannerCache[channelId] ??
// //                                         _getCachedImage(
// //                                             channel.banner ?? localImage),
// //                                     fit: BoxFit.cover,
// //                                     errorBuilder: (context, e, s) =>
// //                                         Image.asset('assets/placeholder.png'),
// //                                   )
// //                                 : CachedNetworkImage(
// //                                     imageUrl: channel.banner ?? localImage,
// //                                     fit: BoxFit.cover,
// //                                     errorWidget: (context, url, error) =>
// //                                         Image.asset('assets/placeholder.png'),
// //                                   ),
// //                           ),
// //                         ),
// //                         if (isFocused)
// //                           Positioned.fill(
// //                             child: Container(
// //                               decoration: BoxDecoration(
// //                                 gradient: LinearGradient(
// //                                   begin: Alignment.topCenter,
// //                                   end: Alignment.bottomCenter,
// //                                   colors: [
// //                                     Colors.transparent,
// //                                     Colors.black.withOpacity(0.9),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         if (isFocused)
// //                           Positioned(
// //                             left: 8,
// //                             bottom: 8,
// //                             child: Text(
// //                               channel.name ?? '',
// //                               style: TextStyle(
// //                                 color: Colors.white,
// //                                 fontSize: 16,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                           ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildControls() {
// //     final Duration currentPosition = _accumulatedSeekForward > 0 ||
// //             _accumulatedSeekBackward > 0 ||
// //             _isScrubbing
// //         ? _previewPosition
// //         : _controller?.value.position ?? Duration.zero;
// //     final Duration totalDuration = _controller?.value.duration ?? Duration.zero;

// //     return Positioned(
// //       bottom: 0,
// //       left: 0,
// //       right: 0,
// //       child: Opacity(
// //         opacity: _controlsVisible ? 1 : 0.0,
// //         child: IgnorePointer(
// //           ignoring: !_controlsVisible,
// //           child: Container(
// //             color: Colors.black54,
// //             padding: const EdgeInsets.symmetric(vertical: 4.0),
// //             child: Row(
// //               crossAxisAlignment: CrossAxisAlignment.center,
// //               children: [
// //                 SizedBox(width: screenwdt * 0.03),
// //                 Container(
// //                   color: playPauseButtonFocusNode.hasFocus
// //                       ? const Color.fromARGB(200, 16, 62, 99)
// //                       : Colors.transparent,
// //                   child: Focus(
// //                     focusNode: playPauseButtonFocusNode,
// //                     onFocusChange: (hasFocus) {
// //                       if (hasFocus) print("✅ FOCO GANADO: Botón Play/Pause");
// //                       setState(() {});
// //                     },
// //                     child: IconButton(
// //                       icon: Image.asset(
// //                         (_controller?.value.isPlaying ?? false)
// //                             ? 'assets/pause.png'
// //                             : 'assets/play.png',
// //                         width: 35,
// //                         height: 35,
// //                       ),
// //                       onPressed: _togglePlayPause,
// //                     ),
// //                   ),
// //                 ),
// //                 if (widget.liveStatus == false)
// //                   Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 12.0),
// //                     child: Text(
// //                       _formatDuration(currentPosition),
// //                       style: const TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ),
// //                 Expanded(
// //                   flex: 10,
// //                   child: LayoutBuilder(
// //                     builder: (context, constraints) {
// //                       return GestureDetector(
// //                         onHorizontalDragStart: (widget.liveStatus == false)
// //                             ? (details) => _onScrubStart(details, constraints)
// //                             : null,
// //                         onHorizontalDragUpdate: (widget.liveStatus == false)
// //                             ? (details) => _onScrubUpdate(details, constraints)
// //                             : null,
// //                         onHorizontalDragEnd: (widget.liveStatus == false)
// //                             ? (details) => _onScrubEnd(details)
// //                             : null,
// //                         child: Container(
// //                           color: Colors.transparent,
// //                           child: _buildBeautifulProgressBar(
// //                               currentPosition, totalDuration),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ),
// //                 if (widget.liveStatus == false)
// //                   Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 12.0),
// //                     child: Text(
// //                       _formatDuration(totalDuration),
// //                       style: const TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ),
// //                 if (widget.liveStatus == true)
// //                   Expanded(
// //                     flex: 1,
// //                     child: Row(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: const [
// //                         Icon(Icons.circle, color: Colors.red, size: 15),
// //                         SizedBox(width: 5),
// //                         Text(
// //                           'Live',
// //                           style: TextStyle(
// //                             color: Colors.red,
// //                             fontSize: 20,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 SizedBox(width: screenwdt * 0.03),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildBeautifulProgressBar(
// //       Duration displayPosition, Duration totalDuration) {
// //     final totalDurationMs = totalDuration.inMilliseconds.toDouble();

// //     if (totalDurationMs <= 0 || widget.liveStatus == true) {
// //       return Container(
// //         padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
// //         child: Container(
// //             height: 8,
// //             decoration: BoxDecoration(
// //                 color: Colors.grey[800],
// //                 borderRadius: BorderRadius.circular(4))),
// //       );
// //     }

// //     double playedProgress =
// //         (displayPosition.inMilliseconds / totalDurationMs).clamp(0.0, 1.0);

// //     double bufferedProgress = (playedProgress + 0.005).clamp(0.0, 1.0);

// //     return Container(
// //       padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
// //       child: Container(
// //         height: 8,
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(4),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.3),
// //               blurRadius: 4,
// //               offset: Offset(0, 2),
// //             ),
// //           ],
// //         ),
// //         child: ClipRRect(
// //           borderRadius: BorderRadius.circular(4),
// //           child: Stack(
// //             children: [
// //               Container(
// //                 width: double.infinity,
// //                 decoration: BoxDecoration(
// //                   gradient: LinearGradient(
// //                     colors: [Colors.grey[800]!, Colors.grey[700]!],
// //                   ),
// //                 ),
// //               ),
// //               FractionallySizedBox(
// //                 widthFactor: bufferedProgress,
// //                 child: Container(
// //                   decoration: BoxDecoration(
// //                     gradient: LinearGradient(
// //                       colors: [Colors.grey[600]!, Colors.grey[500]!],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               FractionallySizedBox(
// //                 widthFactor: playedProgress,
// //                 child: Container(
// //                   decoration: BoxDecoration(
// //                     gradient: LinearGradient(
// //                       colors: [
// //                         Color(0xFF9B28F8),
// //                         Color(0xFFE62B1E),
// //                         Color(0xFFFF6B35),
// //                       ],
// //                       stops: [0.0, 0.7, 1.0],
// //                     ),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Color(0xFF9B28F8).withOpacity(0.6),
// //                         blurRadius: 8,
// //                         spreadRadius: 1,
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:keep_screen_on/keep_screen_on.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
// import 'package:mobi_tv_entertainment/components/widgets/small_widgets/rainbow_page.dart';
// import 'package:mobi_tv_entertainment/main.dart';

// class GlobalVariables {
//   static String unUpdatedUrl = '';
//   static Duration position = Duration.zero;
//   static Duration duration = Duration.zero;
//   static String banner = '';
//   static String name = '';
//   static bool liveStatus = false;
// }

// class RefreshPageEvent {
//   final String pageId;
//   RefreshPageEvent(this.pageId);
// }

// class VideoScreen extends StatefulWidget {
//   final String videoUrl;
//   final String name;
//   final bool liveStatus;
//   final String updatedAt;
//   final List<dynamic> channelList;
//   final String bannerImageUrl;
//   final int? videoId;
//   final String source;

//   VideoScreen({
//     required this.videoUrl,
//     required this.updatedAt,
//     required this.channelList,
//     required this.bannerImageUrl,
//     required this.videoId,
//     required this.source,
//     required this.name,
//     required this.liveStatus,
//   });

//   @override
//   _VideoScreenState createState() => _VideoScreenState();
// }

// class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
//   VlcPlayerController? _controller;
//   bool _controlsVisible = true;
//   late Timer _hideControlsTimer;
//   bool _isBuffering = false;
//   bool _isVideoInitialized = false;
//   int _focusedIndex = 0;
//   List<FocusNode> focusNodes = [];
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode playPauseButtonFocusNode = FocusNode();

//   bool _loadingVisible = false;
//   Duration _lastKnownPosition = Duration.zero;
//   Timer? _networkCheckTimer;
//   bool _wasDisconnected = false;
//   String? _currentModifiedUrl;

//   bool _isAttemptingResume = false;
//   DateTime _lastPlayingTime = DateTime.now();
//   Duration _lastPositionCheck = Duration.zero;
//   int _stallCounter = 0;
//   bool _hasStartedPlaying = false;

//   bool _isScrubbing = false;
//   bool _isUserPaused = false; // Tracks if the user clicked the pause button

//   Map<String, Uint8List> _bannerCache = {};

//   // 🆕 केवल disposal के लिए flag
//   bool _isDisposing = false;

//   Uint8List _getCachedImage(String base64String) {
//     try {
//       if (!_bannerCache.containsKey(base64String)) {
//         _bannerCache[base64String] = base64Decode(base64String.split(',').last);
//       }
//       return _bannerCache[base64String]!;
//     } catch (e) {
//       print('Error procesando imagen: $e');
//       return Uint8List.fromList([0, 0, 0, 0]);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     KeepScreenOn.turnOn();

//     _focusedIndex = widget.channelList.indexWhere(
//       (channel) => channel.id.toString() == widget.videoId.toString(),
//     );
//     _focusedIndex = (_focusedIndex >= 0) ? _focusedIndex : 0;

//     focusNodes = List.generate(
//       widget.channelList.length,
//       (index) => FocusNode(),
//     );

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusAndScrollToInitialItem();
//     });
//     // _initializeVLCController(widget.videoUrl);
//     _initPlayerWithSecureUrl();
//     _startHideControlsTimer();
//     _startNetworkMonitor();
//     _startPositionUpdater();
//   }

//   // Updated VideoScreen State with stability fixes and English logging

//   // 1. Improved Controller Initialization
//   Future<void> _initializeVLCController(String baseUrl) async {
//     if (_isDisposing || !mounted) return;

//     print("--- Initializing Video Player ---");

//     setState(() {
//       _isVideoInitialized = false;
//       _loadingVisible = true;
//     });

//     // CRITICAL: Clean up existing controller before creating a new one
//     try {
//       if (_controller != null) {
//         _controller!.removeListener(_vlcListener);
//         await _controller!.stop();
//         await _controller!.dispose();
//         _controller = null;
//         print("Cleanup: Previous controller disposed successfully.");
//       }
//     } catch (e) {
//       print("Cleanup Warning: Error disposing old controller: $e");
//     }

//     try {
//       _currentModifiedUrl = baseUrl;
//       final String fullVlcUrl = _buildVlcUrl(baseUrl);

//       _lastPlayingTime = DateTime.now();
//       _lastPositionCheck = Duration.zero;
//       _stallCounter = 0;
//       _hasStartedPlaying = false;

//       print("Source: $fullVlcUrl");

//       _controller = VlcPlayerController.network(
//         fullVlcUrl,
//         hwAcc: HwAcc.auto,
//         options: VlcPlayerOptions(
//           video: VlcVideoOptions([
//             VlcVideoOptions.dropLateFrames(true),
//             VlcVideoOptions.skipFrames(true),
//           ]),
//         ),
//       );

//       // Wait for initialization before adding listener
//       await _retryPlayback(fullVlcUrl, 3);

//       if (_controller != null && mounted) {
//         _controller!.addListener(_vlcListener);
//         setState(() {
//           _isVideoInitialized = true;
//         });
//         print("Status: Video Initialized successfully.");
//       }
//     } catch (e) {
//       print("Error: Initialization failed: $e");
//       if (mounted) setState(() => _loadingVisible = false);
//     }
//   }

//   // 2. Updated Playback Retry Logic
//   Future<void> _retryPlayback(String url, int retries) async {
//     for (int i = 0; i < retries; i++) {
//       if (!mounted || _controller == null) return;
//       try {
//         print("Playback Attempt ${i + 1}/$retries");
//         await _controller!.setMediaFromNetwork(url);
//         await _controller!.play();
//         return;
//       } catch (e) {
//         print("Playback Attempt ${i + 1} failed: $e");
//         if (i < retries - 1) {
//           await Future.delayed(const Duration(seconds: 1));
//         }
//       }
//     }
//   }

//   // 3. Robust Item Tap (Channel Change)
//   Future<void> _onItemTap(int index) async {
//     if (!mounted || _isDisposing) return;

//     setState(() {
//       _loadingVisible = true;
//       _focusedIndex = index;
//     });

//     try {
//       var selectedChannel = widget.channelList[index];
//       print("Switching to Channel: ${selectedChannel.name}");

//       String secureUrl = await SecureUrlService.getSecureUrl(
//           selectedChannel.url.toString(),
//           expirySeconds: 10);

//       // Re-initialize to ensure a fresh player state for the new stream
//       await _initializeVLCController(secureUrl);

//       _scrollToFocusedItem();
//       _resetHideControlsTimer();
//     } catch (e) {
//       print("Error: Failed to switch channel: $e");
//       if (mounted) setState(() => _loadingVisible = false);
//     }
//   }

//   // 4. English Logging for Monitor & Network
//   void _startNetworkMonitor() {
//     _networkCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
//       bool isConnected = await _isInternetAvailable();
//       if (!isConnected && !_wasDisconnected) {
//         _wasDisconnected = true;
//         print("Network: Connection lost.");
//       } else if (isConnected && _wasDisconnected) {
//         _wasDisconnected = false;
//         print("Network: Connection restored. Resuming playback...");
//         if (_controller?.value.isInitialized ?? false) {
//           _onNetworkReconnected();
//         }
//       }
//     });
//   }

//   // Future<void> _attemptResumeLiveStream() async {
//   //   if (!mounted || _isAttemptingResume || _controller == null || widget.liveStatus == false) {
//   //     return;
//   //   }

//   //   setState(() {
//   //     _isAttemptingResume = true;
//   //     _loadingVisible = true;
//   //   });

//   //   print("Stability: Live stream stall detected. Attempting recovery...");

//   //   try {
//   //     final urlToResume = _buildVlcUrl(_currentModifiedUrl ?? widget.videoUrl);
//   //     await _retryPlayback(urlToResume, 4);
//   //     _lastPlayingTime = DateTime.now();
//   //     _stallCounter = 0;
//   //     print("Stability: Recovery process finished.");
//   //   } catch (e) {
//   //     print("Error: Recovery failed: $e");
//   //   } finally {
//   //     if (mounted) {
//   //       setState(() => _isAttemptingResume = false);
//   //     }
//   //   }
//   // }

//   Future<void> _attemptResumeLiveStream() async {
//   if (!mounted || _isAttemptingResume || _controller == null || widget.liveStatus == false) {
//     return;
//   }

//   setState(() {
//     _isAttemptingResume = true;
//     _loadingVisible = true;
//   });

//   print("Stability: Live stream stall detected. Attempting recovery with NEW TOKEN...");

//   try {
//     // ✅ FIX: Regenerate the secure URL (Refresh Token)
//     // If the old token expired after 1 hour, this gets a fresh one.
//     String newSecureUrl = widget.videoUrl;
//     try {
//        newSecureUrl = await SecureUrlService.getSecureUrl(
//           widget.videoUrl,
//           expirySeconds: 10
//        );
//     } catch(e) {
//        print("Token refresh failed, using original: $e");
//     }

//     // Update the current modified URL reference
//     _currentModifiedUrl = newSecureUrl;

//     final urlToResume = _buildVlcUrl(newSecureUrl);

//     // Use a slightly more aggressive retry since we know we are stalled
//     await _retryPlayback(urlToResume, 4);

//     _lastPlayingTime = DateTime.now();
//     _stallCounter = 0;

//     // Ensure we are not in user-paused state after auto-resume
//     _isUserPaused = false;

//     print("Stability: Recovery process finished.");
//   } catch (e) {
//     print("Error: Recovery failed: $e");
//   } finally {
//     if (mounted) {
//       setState(() => _isAttemptingResume = false);
//     }
//   }
// }

//   // 🆕 Safe disposal method
//   Future<void> _safeDispose() async {
//     if (_isDisposing) return;

//     _isDisposing = true;
//     print("🔄 Safe disposal started...");

//     // Cancel all timers
//     _hideControlsTimer.cancel();
//     _networkCheckTimer?.cancel();
//     _seekTimer?.cancel();

//     // Dispose focus nodes
//     focusNodes.forEach((node) => node.dispose());
//     playPauseButtonFocusNode.dispose();
//     _scrollController.dispose();

//     // Dispose VLC controller safely
//     try {
//       if (_controller != null) {
//         _controller?.removeListener(_vlcListener);
//         await _controller?.stop();
//         await _controller?.dispose();
//         _controller = null;
//         print("✅ VLC Controller safely disposed");
//       }
//     } catch (e) {
//       print("⚠️ Warning during VLC controller disposal: $e");
//     }

//     KeepScreenOn.turnOff();
//     WidgetsBinding.instance.removeObserver(this);

//     print("✅ Safe disposal completed");
//   }

//   // @override
//   // void dispose() {
//   //   print("🗑️ VideoScreen dispose called");
//   //   _safeDispose();
//   //   super.dispose();
//   // }

//   @override
//   void dispose() {
//     print("🗑️ VideoScreen dispose called");
//     _isDisposing = true;

//     // 1. Cancel all timers
//     _hideControlsTimer.cancel();
//     _networkCheckTimer?.cancel();
//     _seekTimer?.cancel();

//     // 2. Dispose UI Focus Nodes & Controllers safely
//     for (var node in focusNodes) {
//       node.dispose();
//     }
//     playPauseButtonFocusNode.dispose();
//     _scrollController.dispose();

//     // 3. Dispose VLC Controller
//     if (_controller != null) {
//       _controller!.removeListener(_vlcListener);
//       _controller!.dispose();
//       _controller = null;
//     }

//     KeepScreenOn.turnOff();
//     WidgetsBinding.instance.removeObserver(this);

//     super.dispose();
//   }

//   // // 🆕 Improved back button handler
//   // Future<bool> _onWillPop() async {
//   //   print("🔙 Back button pressed");

//   //   if (_isDisposing) {
//   //     return false;
//   //   }

//   //   setState(() {
//   //     _loadingVisible = true;
//   //   });

//   //   // Safe disposal और फिर navigate
//   //   await _safeDispose();

//   //   return true;
//   // }

//   Future<bool> _onWillPop() async {
//     print("🔙 Back button pressed");

//     if (_isDisposing) {
//       return false;
//     }

//     // Stop the video player immediately so audio doesn't keep playing
//     // but DO NOT dispose FocusNodes or ScrollControllers here.
//     if (_controller != null) {
//       await _controller!.stop();
//     }

//     return true; // Let Flutter pop the screen naturally
//   }

// void _scrollToFocusedItem() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_focusedIndex < 0 ||
//           !_scrollController.hasClients ||
//           _focusedIndex >= focusNodes.length) {
//         return;
//       }

//       final itemContext = focusNodes[_focusedIndex].context;
//       if (itemContext == null) return;

//       // alignment: 0.5 is the property that perfectly centers the item
//       Scrollable.ensureVisible(
//         itemContext,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         alignment: 0.5,
//       );
//     });
//   }

//   void _changeFocusAndScroll(int newIndex) {
//     if (newIndex < 0 || newIndex >= widget.channelList.length) return;

//     setState(() {
//       _focusedIndex = newIndex;
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollToFocusedItem(); // Call the new centering method

//       if (mounted) {
//         FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//       }
//     });
//   }

//   void _focusAndScrollToInitialItem() {
//     if (_focusedIndex < 0 || _focusedIndex >= focusNodes.length || !mounted) return;

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollToFocusedItem(); // Call the new centering method

//       if (widget.liveStatus == false) {
//         FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//       } else if (widget.channelList.isNotEmpty) {
//         FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//       } else {
//         FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//       }
//     });
//   }

//   // void _scrollToTopSmoothly(int index) {
//   //   if (!_scrollController.hasClients || !mounted) return;

//   //   // Calculate exact item height: Container height (0.12) + vertical padding (8 top + 8 bottom = 16)
//   //   final double itemHeight = (screenhgt * 0.12) + 8.0;

//   //   // Exact target offset to place the item at the very top
//   //   final double targetOffset = itemHeight * index;

//   //   final double clampedOffset = targetOffset.clamp(
//   //     _scrollController.position.minScrollExtent,
//   //     _scrollController.position.maxScrollExtent,
//   //   );

//   //   _scrollController.animateTo(
//   //     clampedOffset,
//   //     duration: const Duration(milliseconds: 300),
//   //     curve: Curves.easeInOut,
//   //   );
//   // }

//   // void _focusAndScrollToInitialItem() {
//   //   if (_focusedIndex < 0 || _focusedIndex >= focusNodes.length || !mounted) return;

//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     _scrollToTopSmoothly(_focusedIndex);

//   //     if (widget.liveStatus == false) {
//   //       FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//   //     } else if (widget.channelList.isNotEmpty) {
//   //       FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//   //     } else {
//   //       FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//   //     }
//   //   });
//   // }

//   // void _changeFocusAndScroll(int newIndex) {
//   //   if (newIndex < 0 || newIndex >= widget.channelList.length) return;

//   //   setState(() {
//   //     _focusedIndex = newIndex;
//   //   });

//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     _scrollToTopSmoothly(_focusedIndex);

//   //     if (mounted) {
//   //       FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//   //     }
//   //   });
//   // }

//   // // Update this to simply call our new smooth scroll function
//   // void _scrollToFocusedItem() {
//   //    _scrollToTopSmoothly(_focusedIndex);
//   // }

//   // void _focusAndScrollToInitialItem() {
//   //   if (_focusedIndex < 0 || _focusedIndex >= focusNodes.length || !mounted) {
//   //     return;
//   //   }

//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     if (!_scrollController.hasClients) return;

//   //     final double itemHeight = (screenhgt * 0.18) + 16.0;
//   //     final double targetOffset = (itemHeight * _focusedIndex) - 40.0;
//   //     final double clampedOffset = targetOffset.clamp(
//   //       _scrollController.position.minScrollExtent,
//   //       _scrollController.position.maxScrollExtent,
//   //     );
//   //     _scrollController.jumpTo(clampedOffset);

//   //     WidgetsBinding.instance.addPostFrameCallback((_) {
//   //       if (!mounted) return;
//   //       if (widget.liveStatus == false) {
//   //         FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//   //       } else if (widget.channelList.isNotEmpty &&
//   //           _focusedIndex < focusNodes.length) {
//   //         FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//   //       } else {
//   //         FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//   //       }
//   //     });
//   //   });
//   // }

//   // void _changeFocusAndScroll(int newIndex) {
//   //   if (newIndex < 0 || newIndex >= widget.channelList.length) {
//   //     return;
//   //   }

//   //   setState(() {
//   //     _focusedIndex = newIndex;
//   //   });

//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     if (!_scrollController.hasClients || !mounted) return;

//   //     final double itemHeight = (screenhgt * 0.18) + 16.0;
//   //     final double targetOffset = (itemHeight * _focusedIndex) - 40.0;
//   //     final double clampedOffset = targetOffset.clamp(
//   //       _scrollController.position.minScrollExtent,
//   //       _scrollController.position.maxScrollExtent,
//   //     );
//   //     _scrollController.jumpTo(clampedOffset);

//   //     WidgetsBinding.instance.addPostFrameCallback((_) {
//   //       if (mounted) {
//   //         FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//   //       }
//   //     });
//   //   });
//   // }

//   Future<void> _initPlayerWithSecureUrl() async {
//     try {
//       // 1. Pehle URL ko secure (resolve) karein
//       String secureUrl = await SecureUrlService.getSecureUrl(widget.videoUrl,
//           expirySeconds: 10);
//       print('secureUrlinitializing : $secureUrl');
//       if (!mounted) return;

//       // 2. Ab secure URL ko initialize function mein bhejein
//       // Yeh function andar jaakar _buildVlcUrl call karega aur caching jod dega
//       _initializeVLCController(secureUrl);
//     } catch (e) {
//       print("Secure URL error: $e");
//       // Fallback: Agar secure fail ho to original try karein
//       await _initializeVLCController(widget.videoUrl);
//     }
//   }

//   void _handleKeyEvent(RawKeyEvent event) {
//     if (event is RawKeyDownEvent) {
//       _resetHideControlsTimer();

//       switch (event.logicalKey) {
//         case LogicalKeyboardKey.arrowUp:
//           if (playPauseButtonFocusNode.hasFocus) {
//             if (widget.liveStatus == false && widget.channelList.isNotEmpty) {
//               FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//             }
//           } else if (_focusedIndex > 0) {
//             _changeFocusAndScroll(_focusedIndex - 1);
//           }
//           break;

//         case LogicalKeyboardKey.arrowDown:
//           if (_focusedIndex < widget.channelList.length - 1) {
//             _changeFocusAndScroll(_focusedIndex + 1);
//           }
//           // else if (_focusedIndex < widget.channelList.length) {
//           //   FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//           // }
//           break;

//         case LogicalKeyboardKey.arrowRight:
//           if (widget.liveStatus == false) {
//             _seekForward();
//           }
//           if (focusNodes.any((node) => node.hasFocus)) {
//             FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//           }
//           break;

//         case LogicalKeyboardKey.arrowLeft:
//           if (widget.liveStatus == false) {
//             _seekBackward();
//           }
//           if (playPauseButtonFocusNode.hasFocus &&
//               widget.channelList.isNotEmpty) {
//             FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//           }
//           break;

//         case LogicalKeyboardKey.select:
//         case LogicalKeyboardKey.enter:
//           if (widget.liveStatus == false) {
//             _togglePlayPause();
//           } else {
//             if (playPauseButtonFocusNode.hasFocus ||
//                 widget.channelList.isEmpty) {
//               _togglePlayPause();
//             } else {
//               _onItemTap(_focusedIndex);
//             }
//           }
//           break;
//       }
//     }
//   }

//   // Future<void> _attemptResumeLiveStream() async {
//   //   if (!mounted ||
//   //       _isAttemptingResume ||
//   //       _controller == null ||
//   //       widget.liveStatus == false) {
//   //     return;
//   //   }

//   //   setState(() {
//   //     _isAttemptingResume = true;
//   //     _loadingVisible = true;
//   //   });
//   //   print("⚠️ Detectado atasco en Live stream. Intentando resumir...");

//   //   try {
//   //     final urlToResume = _buildVlcUrl(_currentModifiedUrl ?? widget.videoUrl);
//   //     await _retryPlayback(urlToResume, 4);

//   //     _lastPlayingTime = DateTime.now();
//   //     _stallCounter = 0;
//   //     _lastPositionCheck = Duration.zero;
//   //     print("✅ Intento de resumen finalizado.");
//   //   } catch (e) {
//   //     print("❌ Error durante el resumen del live stream: $e");
//   //   } finally {
//   //     if (mounted) {
//   //       setState(() {
//   //         _isAttemptingResume = false;
//   //       });
//   //     }
//   //   }
//   // }

//   void _vlcListener() {
//     if (!mounted || _controller == null || !_controller!.value.isInitialized)
//       return;

//     final VlcPlayerValue value = _controller!.value;
//     final bool isBuffering = value.isBuffering;
//     final PlayingState playingState = value.playingState;

//     if (widget.liveStatus == true && !_isAttemptingResume) {
//       if (playingState == PlayingState.playing) {
//         _lastPlayingTime = DateTime.now();
//         if (!_hasStartedPlaying) {
//           _hasStartedPlaying = true;
//         }
//       } else if (playingState == PlayingState.buffering && _hasStartedPlaying) {
//         final stalledDuration = DateTime.now().difference(_lastPlayingTime);
//         if (stalledDuration > Duration(seconds: 8)) {
//           print(
//               "⚠️ Atasco (Listener): Buffering por ${stalledDuration.inSeconds} seg.");
//           _attemptResumeLiveStream();
//           _lastPlayingTime = DateTime.now();
//         }
//       } else if (playingState == PlayingState.error) {
//         print("⚠️ Atasco (Listener): Player en estado de error.");
//         _attemptResumeLiveStream();
//         _lastPlayingTime = DateTime.now();
//       } else if ((playingState == PlayingState.stopped ||
//               playingState == PlayingState.ended) &&
//           _hasStartedPlaying) {
//         final stalledDuration = DateTime.now().difference(_lastPlayingTime);
//         if (stalledDuration > Duration(seconds: 5)) {
//           print("⚠️ Atasco (Listener): Player parado inesperadamente.");
//           _attemptResumeLiveStream();
//           _lastPlayingTime = DateTime.now();
//         }
//       }
//       // else if (playingState == PlayingState.paused) {
//       //   _lastPlayingTime = DateTime.now();
//       // }
//       // Inside _vlcListener...

// } else if (playingState == PlayingState.paused) {
//   // ✅ FIX: Only reset timer if the USER paused it.
//   if (_isUserPaused) {
//     _lastPlayingTime = DateTime.now();
//   } else {
//     // If user didn't pause, but state is Paused, it's a NETWORK CRASH.
//     // Treat it like buffering/error.
//     final stalledDuration = DateTime.now().difference(_lastPlayingTime);
//     if (stalledDuration > Duration(seconds: 5)) {
//       print("⚠️ Auto-Pause detected (Network issue). Force restarting...");
//       _attemptResumeLiveStream();
//       _lastPlayingTime = DateTime.now();
//     }
//   }
// }

//     if (mounted) {
//       setState(() {
//         _isBuffering = isBuffering;

//         if (playingState == PlayingState.playing && !isBuffering) {
//           _loadingVisible = false;
//         } else if (playingState == PlayingState.buffering ||
//             playingState == PlayingState.initializing) {
//           _loadingVisible = true;
//         }

//         if (_isAttemptingResume) {
//           _loadingVisible = true;
//         }
//       });
//     }
//   }

//   void _startPositionUpdater() {
//     Timer.periodic(Duration(seconds: 2), (_) {
//       if (!mounted ||
//           _controller == null ||
//           !_controller!.value.isInitialized) {
//         return;
//       }

//       final VlcPlayerValue value = _controller!.value;
//       final Duration currentPosition = value.position;

//       if (mounted && !_isScrubbing) {
//         setState(() {
//           _lastKnownPosition = currentPosition;
//         });
//       }

//       if (widget.liveStatus == true &&
//           !_isAttemptingResume &&
//           _hasStartedPlaying) {
//         if (value.playingState == PlayingState.playing) {
//           if (_lastPositionCheck != Duration.zero &&
//               currentPosition == _lastPositionCheck) {
//             _stallCounter++;
//             print(
//                 "⚠️ Posición atascada (Fotograma Congelado). Contador: $_stallCounter");
//           } else {
//             _stallCounter = 0;
//           }

//           if (_stallCounter >= 3) {
//             print("🔴 ATASCADO (Fotograma Congelado). Intentando resumen...");
//             _attemptResumeLiveStream();
//             _stallCounter = 0;
//           }
//         } else {
//           _stallCounter = 0;
//         }
//         _lastPositionCheck = currentPosition;
//       }
//     });
//   }

//   // void _scrollToFocusedItem() {
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     if (_focusedIndex < 0 ||
//   //         !_scrollController.hasClients ||
//   //         _focusedIndex >= focusNodes.length) {
//   //       return;
//   //     }
//   //     final context = focusNodes[_focusedIndex].context;
//   //     if (context == null) return;

//   //     Scrollable.ensureVisible(
//   //       context,
//   //       duration: const Duration(milliseconds: 300),
//   //       curve: Curves.easeInOut,
//   //       alignment: 0.01,
//   //     );
//   //   });
//   // }

//   // void _startNetworkMonitor() {
//   //   _networkCheckTimer = Timer.periodic(Duration(seconds: 5), (_) async {
//   //     bool isConnected = await _isInternetAvailable();
//   //     if (!isConnected && !_wasDisconnected) {
//   //       _wasDisconnected = true;
//   //       print("Red desconectada");
//   //     } else if (isConnected && _wasDisconnected) {
//   //       _wasDisconnected = false;
//   //       print("Red reconectada. Intentando resumir video...");
//   //       if (_controller?.value.isInitialized ?? false) {
//   //         _onNetworkReconnected();
//   //       }
//   //     }
//   //   });
//   // }

//   // Future<void> _onNetworkReconnected() async {
//   //   if (_controller == null || _currentModifiedUrl == null) return;

//   //   final fullUrl = _buildVlcUrl(_currentModifiedUrl!);
//   //   print("Reconectando a: $fullUrl");

//   //   try {
//   //     if (widget.liveStatus == true) {
//   //       await _retryPlayback(fullUrl, 3);
//   //     } else {
//   //       await _retryPlayback(fullUrl, 3);
//   //       if (_lastKnownPosition != Duration.zero) {
//   //         _seekToPosition(_lastKnownPosition);
//   //       }
//   //       await _controller!.play();
//   //     }
//   //   } catch (e) {
//   //     print("Error durante reconexión: $e");
//   //   }
//   // }

//   Future<void> _onNetworkReconnected() async {
//     if (_controller == null || _currentModifiedUrl == null) return;

//     final fullUrl = _buildVlcUrl(_currentModifiedUrl!);
//     print("Reconectando a: $fullUrl");

//     try {
//       if (widget.liveStatus == true) {
//         // --- Lógica de Live Stream (sin cambios) ---
//         print("Reconexión Live Stream: Reiniciando stream...");
//         await _retryPlayback(fullUrl, 4);
//       } else {
//         // --- 🆕 Lógica MEJORADA para VOD (video no-en-vivo) ---
//         print("Reconexión VOD: Intentando resumir desde $_lastKnownPosition");

//         // setState(() { _loadingVisible = true; }); // Opcional: mostrar loading

//         try {
//           // Plan A: Intentar "desatascar" el player sin recargar.
//           // Esto es mucho más rápido y fluido para el usuario.

//           // Pausar primero para asegurar el estado
//           await _controller!.pause();
//           await Future.delayed(const Duration(milliseconds: 100));

//           if (_lastKnownPosition != Duration.zero) {
//             // _seekToPosition ya incluye el comando de play() al final.
//             // Esto forzará al player a re-bufferizar desde ese punto.
//             await _seekToPosition(_lastKnownPosition);
//           } else {
//             // Si no hay posición guardada, solo darle play
//             await _controller!.play();
//           }
//           print("✅ VOD Resumido (Plan A) tras reconexión.");
//         } catch (e) {
//           // Plan B: Si el Plan A falla (el controller está muy roto),
//           // recurrir al método de recarga completa como último recurso.
//           print("⚠️ Plan A falló. Recurriendo a Plan B (Recarga). Error: $e");

//           await _retryPlayback(fullUrl, 4);

//           // Esperar un momento a que el video se cargue después de 'setMedia'
//           await Future.delayed(const Duration(seconds: 2));

//           if (_lastKnownPosition != Duration.zero) {
//             await _seekToPosition(_lastKnownPosition);
//           }
//           print("✅ VOD Resumido (Plan B) tras reconexión.");
//         }
//       }
//     } catch (e) {
//       print("❌ Error crítico durante reconexión: $e");
//     }
//     // finally {
//     //   if (mounted) setState(() { _loadingVisible = false; }); // Opcional
//     // }
//   }

//   Future<bool> _isInternetAvailable() async {
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } catch (_) {
//       return false;
//     }
//   }

//   String _buildVlcUrl(String baseUrl) {
//     final String networkCaching = "network-caching=60000";
//     final String liveCaching = "live-caching=30000";
//     final String fileCaching = "file-caching=20000";
//     final String rtspTcp = "rtsp-tcp";

//     if (widget.liveStatus == true) {
//       return '$baseUrl?$networkCaching&$liveCaching&$fileCaching&$rtspTcp';
//     } else {
//       return '$baseUrl?$networkCaching&$fileCaching&$rtspTcp';
//     }
//   }

//   bool _isSeeking = false;
//   Future<void> _seekToPosition(Duration position) async {
//     if (_isSeeking || _controller == null) return;
//     _isSeeking = true;
//     try {
//       print("Buscando posición: $position");
//       await _controller!.seekTo(position);
//       await _controller!.play();
//     } catch (e) {
//       print("Error durante seek: $e");
//     } finally {
//       await Future.delayed(Duration(milliseconds: 500));
//       _isSeeking = false;
//     }
//   }

//   // Future<void> _initializeVLCController(String baseUrl) async {
//   //   if (_isDisposing || !mounted) return;

//   // // 1. Clear previous state immediately
//   // setState(() {
//   //   _isVideoInitialized = false;
//   //   _loadingVisible = true;
//   // });

//   // // 2. Cleanup old controller synchronously if possible
//   // final oldController = _controller;
//   // _controller = null;
//   // await oldController?.dispose();

//   // // 3. Setup new instance
//   // try {
//   //   // setState(() {
//   //   //   _loadingVisible = true;
//   //   // });

//   //   _currentModifiedUrl = baseUrl;
//   //   final String fullVlcUrl = _buildVlcUrl(baseUrl);
//   //   // final String fullVlcUrl = baseUrl;
//   //   print('fullVlcUrl: $fullVlcUrl');
//   //   _lastPlayingTime = DateTime.now();
//   //   _lastPositionCheck = Duration.zero;
//   //   _stallCounter = 0;
//   //   _hasStartedPlaying = false;

//   //   print("Inicializando con URL: $fullVlcUrl");

//   //   _controller = VlcPlayerController.network(
//   //     fullVlcUrl,
//   //     hwAcc: HwAcc.auto,
//   //     options: VlcPlayerOptions(
//   //       video: VlcVideoOptions([
//   //         VlcVideoOptions.dropLateFrames(true),
//   //         VlcVideoOptions.skipFrames(true),
//   //       ]),
//   //     ),
//   //   );

//   //   await _retryPlayback(fullVlcUrl, 4);
//   //   _controller!.addListener(_vlcListener);

//   //   setState(() {
//   //     _isVideoInitialized = true;
//   //   });
//   //   } catch (e) {
//   //    // Handle failure
//   // }
//   // }

//   // Future<void> _retryPlayback(String url, int retries) async {
//   //   for (int i = 0; i < retries; i++) {
//   //     if (!mounted || _controller == null) return;
//   //     try {
//   //       print("Intento ${i + 1}/$retries: Deteniendo player...");
//   //       await _controller!.stop();
//   //       print("Asignando media: $url");
//   //       await _controller!.setMediaFromNetwork(url);
//   //       await _controller!.play();
//   //       print("Comando Play enviado.");
//   //       return;
//   //     } catch (e) {
//   //       print("Reintento ${i + 1} fallido: $e");
//   //       if (i < retries - 1) {
//   //         await Future.delayed(Duration(seconds: 1));
//   //       }
//   //     }
//   //   }
//   //   print("Todos los reintentos fallaron para: $url");
//   // }

//   // Future<void> _onItemTap(int index) async {
//   //   setState(() {
//   //     _loadingVisible = true;
//   //     _focusedIndex = index;
//   //   });

//   //   var selectedChannel = widget.channelList[index];

//   //   String secureUrl = await SecureUrlService.getSecureUrl(
//   //       selectedChannel.url.toString(),
//   //       expirySeconds: 10);

//   //   _currentModifiedUrl = secureUrl;
//   //   final String fullVlcUrl = _buildVlcUrl(secureUrl);
//   //   print("secure+cached URL: $fullVlcUrl");

//   //   _lastPlayingTime = DateTime.now();
//   //   _lastPositionCheck = Duration.zero;
//   //   _stallCounter = 0;
//   //   _hasStartedPlaying = false;

//   //   try {
//   //     if (_controller != null && _controller!.value.isInitialized) {
//   //       await _retryPlayback(fullVlcUrl, 3);
//   //       _controller!.addListener(_vlcListener);
//   //     } else {
//   //       throw Exception("VLC Controller no inicializado");
//   //     }
//   //     _scrollToFocusedItem();
//   //     _resetHideControlsTimer();
//   //   } catch (e) {
//   //     print("Error cambiando de canal: $e");
//   //   }
//   // }

//   // void _togglePlayPause() {
//   //   if (_controller != null && _controller!.value.isInitialized) {
//   //     _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
//   //     _lastPlayingTime = DateTime.now();
//   //     _stallCounter = 0;
//   //   }
//   //   FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//   //   _resetHideControlsTimer();
//   // }

//   void _togglePlayPause() {
//   if (_controller != null && _controller!.value.isInitialized) {
//     if (_controller!.value.isPlaying) {
//       _controller!.pause();
//       setState(() {
//          _isUserPaused = true; // User specifically asked to pause
//       });
//     } else {
//       _controller!.play();
//       setState(() {
//          _isUserPaused = false; // User wants to play
//       });
//       _lastPlayingTime = DateTime.now();
//       _stallCounter = 0;
//     }
//   }
//   FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//   _resetHideControlsTimer();
// }

//   void _resetHideControlsTimer() {
//     _hideControlsTimer.cancel();
//     if (!_controlsVisible) {
//       setState(() {
//         _controlsVisible = true;
//       });
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!mounted) return;
//         if (widget.liveStatus == false || widget.channelList.isEmpty) {
//           FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//         } else {
//           FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//           _scrollToFocusedItem();
//         }
//       });
//     }
//     _startHideControlsTimer();
//   }

//   void _startHideControlsTimer() {
//     _hideControlsTimer = Timer(Duration(seconds: 10), () {
//       if (mounted) {
//         setState(() {
//           _controlsVisible = false;
//         });
//       }
//     });
//   }

//   int _accumulatedSeekForward = 0;
//   int _accumulatedSeekBackward = 0;
//   Timer? _seekTimer;
//   Duration _previewPosition = Duration.zero;
//   final int _seekDuration = 8;
//   final int _seekDelay = 800;

//   void _seekForward() {
//     if (_controller == null ||
//         !_controller!.value.isInitialized ||
//         _controller!.value.duration <= Duration.zero) return;

//     _accumulatedSeekForward += _seekDuration;
//     final newPosition = _controller!.value.position +
//         Duration(seconds: _accumulatedSeekForward);

//     setState(() {
//       _previewPosition = newPosition > _controller!.value.duration
//           ? _controller!.value.duration
//           : newPosition;
//     });

//     _seekTimer?.cancel();
//     _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
//       _seekToPosition(_previewPosition).then((_) {
//         setState(() {
//           _accumulatedSeekForward = 0;
//         });
//       });
//     });
//   }

//   void _seekBackward() {
//     if (_controller == null ||
//         !_controller!.value.isInitialized ||
//         _controller!.value.duration <= Duration.zero) return;

//     _accumulatedSeekBackward += _seekDuration;
//     final newPosition = _controller!.value.position -
//         Duration(seconds: _accumulatedSeekBackward);

//     setState(() {
//       _previewPosition =
//           newPosition > Duration.zero ? newPosition : Duration.zero;
//     });

//     _seekTimer?.cancel();
//     _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
//       _seekToPosition(_previewPosition).then((_) {
//         setState(() {
//           _accumulatedSeekBackward = 0;
//         });
//       });
//     });
//   }

//   String _formatDuration(Duration duration) {
//     if (duration.isNegative) {
//       duration = Duration.zero;
//     }
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//   }

//   void _onScrubStart(DragStartDetails details, BoxConstraints constraints) {
//     if (_controller == null || _controller!.value.duration <= Duration.zero)
//       return;

//     _resetHideControlsTimer();
//     setState(() {
//       _isScrubbing = true;
//       _accumulatedSeekForward = 1;
//       final double progress =
//           (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
//       _previewPosition = _controller!.value.duration * progress;
//     });
//   }

//   void _onScrubUpdate(DragUpdateDetails details, BoxConstraints constraints) {
//     if (!_isScrubbing ||
//         _controller == null ||
//         _controller!.value.duration <= Duration.zero) return;

//     _resetHideControlsTimer();
//     final double progress =
//         (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
//     final newPosition = _controller!.value.duration * progress;
//     setState(() {
//       _previewPosition = newPosition;
//     });
//   }

//   void _onScrubEnd(DragEndDetails details) {
//     if (!_isScrubbing) return;

//     _seekToPosition(_previewPosition).then((_) {
//       setState(() {
//         _accumulatedSeekForward = 0;
//       });
//     });
//     _resetHideControlsTimer();
//     setState(() {
//       _isScrubbing = false;
//     });
//   }

// Widget _buildTopTitle() {
//     return Positioned(
//       // Top se safe distance
//       top: MediaQuery.of(context).padding.top + 10,
//       left: 20, // Sides par breathing space
//       right: 20,
//       child: IgnorePointer(
//         child: AnimatedOpacity(
//           opacity: _controlsVisible ? 1.0 : 0.0,
//           duration: const Duration(milliseconds: 300),
//           child: Center(
//             child: Text(
//               widget.name,
//               // Pure white background par readability ke liye multi-shadows
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 32, // TV ke liye bold aur bada text
//                 fontWeight: FontWeight.bold,
//                 shadows: [
//                   // Shadow 1: Dark soft drop shadow (bada drop)
//                   Shadow(
//                     color: Colors.black,
//                     blurRadius: 15.0,
//                     offset: Offset(0.0, 5.0),
//                   ),
//                   // Shadow 2: Tight shadow to create outline (bottom-right)
//                   Shadow(
//                     color: Colors.black54,
//                     blurRadius: 2.0,
//                     offset: Offset(1.5, 1.5),
//                   ),
//                   // Shadow 3: Tight shadow to create outline (top-left)
//                   Shadow(
//                     color: Colors.black54,
//                     blurRadius: 2.0,
//                     offset: Offset(-1.5, -1.5),
//                   ),
//                 ],
//               ),
//               textAlign: TextAlign.center,
//               maxLines: 2, // Bahut lamba naam ho toh newline par aaye
//               overflow: TextOverflow.ellipsis, // Text cut na ho
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildVideoPlayer() {
//     if (!_isVideoInitialized || _controller == null) {
//       return Center(child: CircularProgressIndicator());
//     }
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final screenWidth = constraints.maxWidth;
//         final screenHeight = constraints.maxHeight;
//         final videoWidth = _controller!.value.size.width ?? screenWidth;
//         final videoHeight = _controller!.value.size.height ?? screenHeight;
//         final videoRatio = videoWidth / videoHeight;
//         final screenRatio = screenWidth / screenHeight;

//         double scaleX = 1.0;
//         double scaleY = 1.0;

//         if (videoRatio < screenRatio) {
//           scaleX = screenRatio / videoRatio;
//         } else {
//           scaleY = videoRatio / screenRatio;
//         }

//         return Container(
//           width: screenWidth,
//           height: screenHeight,
//           color: Colors.black,
//           child: Center(
//             child: Transform.scale(
//               scaleX: scaleX,
//               scaleY: scaleY,
//               child: VlcPlayer(
//                 key: ValueKey(_currentModifiedUrl ?? widget.videoUrl),
//                 controller: _controller!,
//                 placeholder: Center(child: CircularProgressIndicator()),
//                 aspectRatio: 16 / 9,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return
//     // WillPopScope(
//     //   onWillPop: _onWillPop, // 🆕 Improved back button handler
//     //   child:

//       // Replace WillPopScope with:
// PopScope(
//   canPop: false,
//   onPopInvoked: (didPop) async {
//     if (didPop) return;
//     bool shouldPop = await _onWillPop();
//     if (shouldPop && mounted) {
//       Navigator.of(context).pop();
//     }
//   },
//   child:

//       Scaffold(
//         backgroundColor: Colors.black,
//         body: SizedBox(
//           width: screenwdt,
//           height: screenhgt,
//           child: Focus(
//             autofocus: true,
//             onKey: (node, event) {
//               if (event is RawKeyDownEvent) {
//                 _handleKeyEvent(event);
//                 return KeyEventResult.handled;
//               }
//               return KeyEventResult.ignored;
//             },

//             child: GestureDetector(
//               onTap: _resetHideControlsTimer,
//               child: Stack(
//                 children: [
//                   if (_isVideoInitialized && _controller != null)
//                     _buildVideoPlayer(),
//                   if (_loadingVisible ||
//                       !_isVideoInitialized ||
//                       _isAttemptingResume ||
//                       (_isBuffering && !_loadingVisible))
//                     Container(
//                       color: _loadingVisible || !_isVideoInitialized
//                           ? Colors.black54
//                           : Colors.transparent,
//                       child: Center(
//                         child: RainbowPage(
//                           backgroundColor:
//                               _loadingVisible || !_isVideoInitialized
//                                   ? Colors.black
//                                   : Colors.transparent,
//                         ),
//                       ),
//                     ),
//                   if (_controlsVisible && widget.channelList.isNotEmpty)
//                     _buildChannelList(),
//                     _buildTopTitle(),
//                   _buildControls(),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildChannelList() {
//     return Positioned(
//       top: MediaQuery.of(context).size.height * 0.02,
//       bottom: MediaQuery.of(context).size.height * 0.1,
//       left: screenwdt * 0.01,
//       right: MediaQuery.of(context).size.width * 0.85,
//       child: ListView.builder(
//         controller: _scrollController,
//         itemCount: widget.channelList.length,
//         itemBuilder: (context, index) {
//           final channel = widget.channelList[index];
//           final String channelId = channel.id?.toString() ?? '';
//           final bool isBase64 =
//               channel.banner?.startsWith('data:image') ?? false;
//           final bool isFocused = _focusedIndex == index;

//           return Padding(
//             padding:
//                 const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//             child: Focus(
//               focusNode: focusNodes[index],
//               onFocusChange: (hasFocus) {
//                 if (hasFocus) {
//                   print("✅ FOCO GANADO: Canal en índice $index");
//                   _scrollToFocusedItem();
//                 }
//               },
//               child: GestureDetector(
//                 onTap: () {
//                   _onItemTap(index);
//                   _resetHideControlsTimer();
//                 },
//                 child: Container(
//                   width: screenwdt * 0.3,
//                   height: screenhgt * 0.12,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: isFocused && !playPauseButtonFocusNode.hasFocus
//                           ? const Color.fromARGB(211, 155, 40, 248)
//                           : Colors.transparent,
//                       width: 5.0,
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                     color: isFocused ? Colors.black26 : Colors.transparent,
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(6),
//                     child: Stack(
//                       children: [
//                         Positioned.fill(
//                           child: Opacity(
//                             opacity: 0.6,
//                             child: isBase64
//                                 ? Image.memory(
//                                     _bannerCache[channelId] ??
//                                         _getCachedImage(
//                                             channel.banner ?? localImage),
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, e, s) =>
//                                         Image.asset('assets/placeholder.png'),
//                                   )
//                                 : CachedNetworkImage(
//                                     imageUrl: channel.banner ?? localImage,
//                                     fit: BoxFit.cover,
//                                     errorWidget: (context, url, error) =>
//                                         Image.asset('assets/placeholder.png'),
//                                   ),
//                           ),
//                         ),
//                         if (isFocused)
//                           Positioned.fill(
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                   colors: [
//                                     Colors.transparent,
//                                     Colors.black.withOpacity(0.9),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         if (isFocused)
//                           Positioned(
//                             left: 8,
//                             bottom: 8,
//                             child: Text(
//                               channel.name ?? '',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildControls() {
//     final Duration currentPosition = _accumulatedSeekForward > 0 ||
//             _accumulatedSeekBackward > 0 ||
//             _isScrubbing
//         ? _previewPosition
//         : _controller?.value.position ?? Duration.zero;
//     final Duration totalDuration = _controller?.value.duration ?? Duration.zero;

//     return Positioned(
//       bottom: 0,
//       left: 0,
//       right: 0,
//       child: Opacity(
//         opacity: _controlsVisible ? 1 : 0.0,
//         child: IgnorePointer(
//           ignoring: !_controlsVisible,
//           child: Container(
//             color: Colors.black54,
//             padding: const EdgeInsets.symmetric(vertical: 4.0),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(width: screenwdt * 0.03),
//                 Container(
//                   color: playPauseButtonFocusNode.hasFocus
//                       ? const Color.fromARGB(200, 16, 62, 99)
//                       : Colors.transparent,
//                   child: Focus(
//                     focusNode: playPauseButtonFocusNode,
//                     onFocusChange: (hasFocus) {
//                       if (hasFocus) print("✅ FOCO GANADO: Botón Play/Pause");
//                       setState(() {});
//                     },
//                     child: IconButton(
//                       icon: Image.asset(
//                         (_controller?.value.isPlaying ?? false)
//                             ? 'assets/pause.png'
//                             : 'assets/play.png',
//                         width: 35,
//                         height: 35,
//                       ),
//                       onPressed: _togglePlayPause,
//                     ),
//                   ),
//                 ),
//                 if (widget.liveStatus == false)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                     child: Text(
//                       _formatDuration(currentPosition),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 Expanded(
//                   flex: 10,
//                   child: LayoutBuilder(
//                     builder: (context, constraints) {
//                       return GestureDetector(
//                         onHorizontalDragStart: (widget.liveStatus == false)
//                             ? (details) => _onScrubStart(details, constraints)
//                             : null,
//                         onHorizontalDragUpdate: (widget.liveStatus == false)
//                             ? (details) => _onScrubUpdate(details, constraints)
//                             : null,
//                         onHorizontalDragEnd: (widget.liveStatus == false)
//                             ? (details) => _onScrubEnd(details)
//                             : null,
//                         child: Container(
//                           color: Colors.transparent,
//                           child: _buildBeautifulProgressBar(
//                               currentPosition, totalDuration),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 if (widget.liveStatus == false)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                     child: Text(
//                       _formatDuration(totalDuration),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 if (widget.liveStatus == true)
//                   Expanded(
//                     flex: 1,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const [
//                         Icon(Icons.circle, color: Colors.red, size: 15),
//                         SizedBox(width: 5),
//                         Text(
//                           'Live',
//                           style: TextStyle(
//                             color: Colors.red,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 SizedBox(width: screenwdt * 0.03),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBeautifulProgressBar(
//       Duration displayPosition, Duration totalDuration) {
//     final totalDurationMs = totalDuration.inMilliseconds.toDouble();

//     if (totalDurationMs <= 0 || widget.liveStatus == true) {
//       return Container(
//         padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//         child: Container(
//             height: 8,
//             decoration: BoxDecoration(
//                 color: Colors.grey[800],
//                 borderRadius: BorderRadius.circular(4))),
//       );
//     }

//     double playedProgress =
//         (displayPosition.inMilliseconds / totalDurationMs).clamp(0.0, 1.0);

//     double bufferedProgress = (playedProgress + 0.005).clamp(0.0, 1.0);

//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//       child: Container(
//         height: 8,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(4),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 4,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(4),
//           child: Stack(
//             children: [
//               Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.grey[800]!, Colors.grey[700]!],
//                   ),
//                 ),
//               ),
//               FractionallySizedBox(
//                 widthFactor: bufferedProgress,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.grey[600]!, Colors.grey[500]!],
//                     ),
//                   ),
//                 ),
//               ),
//               FractionallySizedBox(
//                 widthFactor: playedProgress,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Color(0xFF9B28F8),
//                         Color(0xFFE62B1E),
//                         Color(0xFFFF6B35),
//                       ],
//                       stops: [0.0, 0.7, 1.0],
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Color(0xFF9B28F8).withOpacity(0.6),
//                         blurRadius: 8,
//                         spreadRadius: 1,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:keep_screen_on/keep_screen_on.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
// import 'package:mobi_tv_entertainment/components/widgets/small_widgets/rainbow_page.dart';
// import 'package:mobi_tv_entertainment/main.dart';

// class GlobalVariables {
//   static String unUpdatedUrl = '';
//   static Duration position = Duration.zero;
//   static Duration duration = Duration.zero;
//   static String banner = '';
//   static String name = '';
//   static bool liveStatus = false;
// }

// class RefreshPageEvent {
//   final String pageId;
//   RefreshPageEvent(this.pageId);
// }

// class VideoScreen extends StatefulWidget {
//   final String videoUrl;
//   final String name;
//   final bool liveStatus;
//   final String updatedAt;
//   final List<dynamic> channelList;
//   final String bannerImageUrl;
//   final int? videoId;
//   final String source;

//   VideoScreen({
//     required this.videoUrl,
//     required this.updatedAt,
//     required this.channelList,
//     required this.bannerImageUrl,
//     required this.videoId,
//     required this.source,
//     required this.name,
//     required this.liveStatus,
//   });

//   @override
//   _VideoScreenState createState() => _VideoScreenState();
// }

// class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
//   VlcPlayerController? _controller;
//   bool _controlsVisible = true;
//   late Timer _hideControlsTimer;
//   bool _isBuffering = false;
//   bool _isVideoInitialized = false;
//   int _focusedIndex = 0;
//   List<FocusNode> focusNodes = [];
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode playPauseButtonFocusNode = FocusNode();

//   bool _loadingVisible = false;
//   Duration _lastKnownPosition = Duration.zero;
//   Timer? _networkCheckTimer;
//   bool _wasDisconnected = false;
//   String? _currentModifiedUrl;

//   bool _isAttemptingResume = false;
//   DateTime _lastPlayingTime = DateTime.now();
//   Duration _lastPositionCheck = Duration.zero;
//   int _stallCounter = 0;
//   bool _hasStartedPlaying = false;

//   bool _isScrubbing = false;
//   bool _isUserPaused = false;

//   Map<String, Uint8List> _bannerCache = {};

//   bool _isDisposing = false;

//   Uint8List _getCachedImage(String base64String) {
//     try {
//       if (!_bannerCache.containsKey(base64String)) {
//         _bannerCache[base64String] = base64Decode(base64String.split(',').last);
//       }
//       return _bannerCache[base64String]!;
//     } catch (e) {
//       print('Error procesando imagen: $e');
//       return Uint8List.fromList([0, 0, 0, 0]);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     KeepScreenOn.turnOn();

//     _focusedIndex = widget.channelList.indexWhere(
//       (channel) => channel.id.toString() == widget.videoId.toString(),
//     );
//     _focusedIndex = (_focusedIndex >= 0) ? _focusedIndex : 0;

//     focusNodes = List.generate(
//       widget.channelList.length,
//       (index) => FocusNode(),
//     );

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusAndScrollToInitialItem();
//     });

//     _initPlayerWithSecureUrl();
//     _startHideControlsTimer();
//     _startNetworkMonitor();
//     _startPositionUpdater();
//   }

//   Future<void> _initializeVLCController(String baseUrl) async {
//     if (_isDisposing || !mounted) return;

//     print("--- Initializing Video Player ---");

//     setState(() {
//       _isVideoInitialized = false;
//       _loadingVisible = true;
//     });

//     try {
//       if (_controller != null) {
//         _controller!.removeListener(_vlcListener);
//         await _controller!.stop();
//         await _controller!.dispose();
//         _controller = null;
//         print("Cleanup: Previous controller disposed successfully.");
//       }
//     } catch (e) {
//       print("Cleanup Warning: Error disposing old controller: $e");
//     }

//     try {
//       _currentModifiedUrl = baseUrl;
//       final String fullVlcUrl = _buildVlcUrl(baseUrl);

//       _lastPlayingTime = DateTime.now();
//       _lastPositionCheck = Duration.zero;
//       _stallCounter = 0;
//       _hasStartedPlaying = false;

//       print("Source: $fullVlcUrl");

//       _controller = VlcPlayerController.network(
//         fullVlcUrl,
//         hwAcc: HwAcc.auto,
//         options: VlcPlayerOptions(
//           video: VlcVideoOptions([
//             VlcVideoOptions.dropLateFrames(true),
//             VlcVideoOptions.skipFrames(true),
//           ]),
//         ),
//       );

//       await _retryPlayback(fullVlcUrl, 3);

//       if (_controller != null && mounted) {
//         _controller!.addListener(_vlcListener);
//         setState(() {
//           _isVideoInitialized = true;
//         });
//         print("Status: Video Initialized successfully.");
//       }
//     } catch (e) {
//       print("Error: Initialization failed: $e");
//       if (mounted) setState(() => _loadingVisible = false);
//     }
//   }

//   Future<void> _retryPlayback(String url, int retries) async {
//     for (int i = 0; i < retries; i++) {
//       if (!mounted || _controller == null) return;
//       try {
//         print("Playback Attempt ${i + 1}/$retries");
//         await _controller!.setMediaFromNetwork(url);
//         await _controller!.play();
//         return;
//       } catch (e) {
//         print("Playback Attempt ${i + 1} failed: $e");
//         if (i < retries - 1) {
//           await Future.delayed(const Duration(seconds: 1));
//         }
//       }
//     }
//   }

//   Future<void> _onItemTap(int index) async {
//     if (!mounted || _isDisposing) return;

//     setState(() {
//       _loadingVisible = true;
//       _focusedIndex = index;
//     });

//     try {
//       var selectedChannel = widget.channelList[index];
//       print("Switching to Channel: ${selectedChannel.name}");

//       String secureUrl = await SecureUrlService.getSecureUrl(
//           selectedChannel.url.toString(),
//           expirySeconds: 10);

//       await _initializeVLCController(secureUrl);

//       _scrollToFocusedItem();
//       _resetHideControlsTimer();
//     } catch (e) {
//       print("Error: Failed to switch channel: $e");
//       if (mounted) setState(() => _loadingVisible = false);
//     }
//   }

//   void _startNetworkMonitor() {
//     _networkCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
//       bool isConnected = await _isInternetAvailable();
//       if (!isConnected && !_wasDisconnected) {
//         _wasDisconnected = true;
//         print("Network: Connection lost.");
//       } else if (isConnected && _wasDisconnected) {
//         _wasDisconnected = false;
//         print("Network: Connection restored. Resuming playback...");
//         if (_controller?.value.isInitialized ?? false) {
//           _onNetworkReconnected();
//         }
//       }
//     });
//   }

//   Future<void> _attemptResumeLiveStream() async {
//     if (!mounted || _isAttemptingResume || _controller == null || widget.liveStatus == false) {
//       return;
//     }

//     setState(() {
//       _isAttemptingResume = true;
//       _loadingVisible = true;
//     });

//     print("Stability: Live stream stall detected. Attempting recovery with NEW TOKEN...");

//     try {
//       String newSecureUrl = widget.videoUrl;
//       try {
//          newSecureUrl = await SecureUrlService.getSecureUrl(
//             widget.videoUrl,
//             expirySeconds: 10
//          );
//       } catch(e) {
//          print("Token refresh failed, using original: $e");
//       }

//       _currentModifiedUrl = newSecureUrl;

//       final urlToResume = _buildVlcUrl(newSecureUrl);

//       await _retryPlayback(urlToResume, 4);

//       _lastPlayingTime = DateTime.now();
//       _stallCounter = 0;

//       _isUserPaused = false;

//       print("Stability: Recovery process finished.");
//     } catch (e) {
//       print("Error: Recovery failed: $e");
//     } finally {
//       if (mounted) {
//         setState(() => _isAttemptingResume = false);
//       }
//     }
//   }

//   Future<void> _safeDispose() async {
//     if (_isDisposing) return;

//     _isDisposing = true;
//     print("🔄 Safe disposal started...");

//     _hideControlsTimer.cancel();
//     _networkCheckTimer?.cancel();
//     _seekTimer?.cancel();

//     focusNodes.forEach((node) => node.dispose());
//     playPauseButtonFocusNode.dispose();
//     _scrollController.dispose();

//     try {
//       if (_controller != null) {
//         _controller?.removeListener(_vlcListener);
//         await _controller?.stop();
//         await _controller?.dispose();
//         _controller = null;
//         print("✅ VLC Controller safely disposed");
//       }
//     } catch (e) {
//       print("⚠️ Warning during VLC controller disposal: $e");
//     }

//     KeepScreenOn.turnOff();
//     WidgetsBinding.instance.removeObserver(this);

//     print("✅ Safe disposal completed");
//   }

//   @override
//   void dispose() {
//     print("🗑️ VideoScreen dispose called");
//     _safeDispose();
//     super.dispose();
//   }

//   // Future<bool> _onWillPop() async {
//   //   print("🔙 Back button pressed");

//   //   if (_isDisposing) {
//   //     return false;
//   //   }

//   //   setState(() {
//   //     _loadingVisible = true;
//   //   });

//   //    _safeDispose();

//   //   return true;
//   // }

//   Future<bool> _onWillPop() async {
//     print("🚨 SYSTEM BACK BUTTON DETECTED 🚨");

//     // We call this, but we don't care if it finishes or fails
//     _safeDispose();

//     // Force Flutter to remove this screen immediately
//     if (mounted) {
//       Navigator.of(context).pop();
//     }

//     return true;
//   }

//   void _focusAndScrollToInitialItem() {
//     if (_focusedIndex < 0 || _focusedIndex >= focusNodes.length || !mounted) {
//       return;
//     }

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!_scrollController.hasClients) return;

//       final double itemHeight = (screenhgt * 0.108) + 16.0;
//       final double viewportHeight = MediaQuery.of(context).size.height * 0.88;
//       final double targetOffset = (itemHeight * _focusedIndex) - (viewportHeight / 2) + (itemHeight / 2);

//       final double clampedOffset = targetOffset.clamp(
//         _scrollController.position.minScrollExtent,
//         _scrollController.position.maxScrollExtent,
//       );
//       _scrollController.jumpTo(clampedOffset);

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!mounted) return;
//         if (widget.liveStatus == false) {
//           FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//         } else if (widget.channelList.isNotEmpty &&
//             _focusedIndex < focusNodes.length) {
//           FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//         } else {
//           FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//         }
//       });
//     });
//   }

//   void _changeFocusAndScroll(int newIndex) {
//     if (newIndex < 0 || newIndex >= widget.channelList.length) {
//       return;
//     }

//     setState(() {
//       _focusedIndex = newIndex;
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!_scrollController.hasClients || !mounted) return;

//       final double itemHeight = (screenhgt * 0.108) + 16.0;
//       final double viewportHeight = MediaQuery.of(context).size.height * 0.88;
//       final double targetOffset = (itemHeight * _focusedIndex) - (viewportHeight / 2) + (itemHeight / 2);

//       final double clampedOffset = targetOffset.clamp(
//         _scrollController.position.minScrollExtent,
//         _scrollController.position.maxScrollExtent,
//       );
//       _scrollController.jumpTo(clampedOffset);

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//         }
//       });
//     });
//   }

//   Future<void> _initPlayerWithSecureUrl() async {
//     try {
//       String secureUrl = await SecureUrlService.getSecureUrl(widget.videoUrl,
//           expirySeconds: 10);
//       print('secureUrlinitializing : $secureUrl');
//       if (!mounted) return;

//       _initializeVLCController(secureUrl);
//     } catch (e) {
//       print("Secure URL error: $e");
//       await _initializeVLCController(widget.videoUrl);
//     }
//   }

//   // void _handleKeyEvent(RawKeyEvent event) {
//   //   if (event is RawKeyDownEvent) {
//   //     _resetHideControlsTimer();

//   //     switch (event.logicalKey) {
//   //       case LogicalKeyboardKey.arrowUp:
//   //         if (playPauseButtonFocusNode.hasFocus) {
//   //           if (widget.liveStatus == false && widget.channelList.isNotEmpty) {
//   //             FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//   //           }
//   //         } else if (_focusedIndex > 0) {
//   //           _changeFocusAndScroll(_focusedIndex - 1);
//   //         }
//   //         break;

//   //       case LogicalKeyboardKey.arrowDown:
//   //         if (_focusedIndex < widget.channelList.length - 1) {
//   //           _changeFocusAndScroll(_focusedIndex + 1);
//   //         } else if (_focusedIndex < widget.channelList.length) {
//   //           FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//   //         }
//   //         break;

//   //       case LogicalKeyboardKey.arrowRight:
//   //         if (widget.liveStatus == false) {
//   //           _seekForward();
//   //         }
//   //         if (focusNodes.any((node) => node.hasFocus)) {
//   //           FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//   //         }
//   //         break;

//   //       case LogicalKeyboardKey.arrowLeft:
//   //         if (widget.liveStatus == false) {
//   //           _seekBackward();
//   //         }
//   //         if (playPauseButtonFocusNode.hasFocus &&
//   //             widget.channelList.isNotEmpty) {
//   //           FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//   //         }
//   //         break;

//   //       case LogicalKeyboardKey.select:
//   //       case LogicalKeyboardKey.enter:
//   //         if (widget.liveStatus == false) {
//   //           _togglePlayPause();
//   //         } else {
//   //           if (playPauseButtonFocusNode.hasFocus ||
//   //               widget.channelList.isEmpty) {
//   //             _togglePlayPause();
//   //           } else {
//   //             _onItemTap(_focusedIndex);
//   //           }
//   //         }
//   //         break;
//   //     }
//   //   }
//   // }

// bool _handleKeyEvent(RawKeyEvent event) {
//   print("📺 REMOTE KEY PRESSED: ${event.logicalKey.keyLabel} (ID: ${event.logicalKey.keyId})");
//     if (event is RawKeyDownEvent) {
//       _resetHideControlsTimer();

//       switch (event.logicalKey) {
//         // --- ADD THESE 3 CASES FOR THE TV BACK BUTTON ---
//         case LogicalKeyboardKey.escape:
//         // case LogicalKeyboardKey.goBack:
//         case LogicalKeyboardKey.browserBack:
//           print("🔙 TV Remote Back Button explicitly caught!");
//           _safeDispose();
//           Navigator.maybePop(context);
//           return true;
//         // ------------------------------------------------

//         case LogicalKeyboardKey.arrowUp:
//           if (playPauseButtonFocusNode.hasFocus) {
//             if (widget.liveStatus == false && widget.channelList.isNotEmpty) {
//               FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//             }
//           } else
//           if (_focusedIndex > 0) {
//             _changeFocusAndScroll(_focusedIndex - 1);
//           }
//           return true;

//         case LogicalKeyboardKey.arrowDown:
//           if (_focusedIndex < widget.channelList.length - 1) {
//             _changeFocusAndScroll(_focusedIndex + 1);
//           }
//           // else if (_focusedIndex < widget.channelList.length) {
//           //   FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//           // }
//           return true;

//         case LogicalKeyboardKey.arrowRight:
//           if (widget.liveStatus == false) {
//             _seekForward();
//           }
//           // if (focusNodes.any((node) => node.hasFocus)) {
//           //   FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//           // }
//           return true;

//         case LogicalKeyboardKey.arrowLeft:
//           if (widget.liveStatus == false) {
//             _seekBackward();
//           }
//           if (playPauseButtonFocusNode.hasFocus &&
//               widget.channelList.isNotEmpty) {
//             FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//           }
//           return true;

//         case LogicalKeyboardKey.select:
//         case LogicalKeyboardKey.enter:
//           if (widget.liveStatus == false) {
//             _togglePlayPause();
//           } else {
//             if (playPauseButtonFocusNode.hasFocus ||
//                 widget.channelList.isEmpty) {
//               _togglePlayPause();
//             } else {
//               _onItemTap(_focusedIndex);
//             }
//           }
//           return true;

//         default:
//           return false;
//       }
//     }
//     return false;
//   }

//   void _vlcListener() {
//     if (!mounted || _controller == null || !_controller!.value.isInitialized)
//       return;

//     final VlcPlayerValue value = _controller!.value;
//     final bool isBuffering = value.isBuffering;
//     final PlayingState playingState = value.playingState;

//     if (widget.liveStatus == true && !_isAttemptingResume) {
//       if (playingState == PlayingState.playing) {
//         _lastPlayingTime = DateTime.now();
//         if (!_hasStartedPlaying) {
//           _hasStartedPlaying = true;
//         }
//       } else if (playingState == PlayingState.buffering && _hasStartedPlaying) {
//         final stalledDuration = DateTime.now().difference(_lastPlayingTime);
//         if (stalledDuration > Duration(seconds: 8)) {
//           print(
//               "⚠️ Atasco (Listener): Buffering por ${stalledDuration.inSeconds} seg.");
//           _attemptResumeLiveStream();
//           _lastPlayingTime = DateTime.now();
//         }
//       } else if (playingState == PlayingState.error) {
//         print("⚠️ Atasco (Listener): Player en estado de error.");
//         _attemptResumeLiveStream();
//         _lastPlayingTime = DateTime.now();
//       } else if ((playingState == PlayingState.stopped ||
//               playingState == PlayingState.ended) &&
//           _hasStartedPlaying) {
//         final stalledDuration = DateTime.now().difference(_lastPlayingTime);
//         if (stalledDuration > Duration(seconds: 5)) {
//           print("⚠️ Atasco (Listener): Player parado inesperadamente.");
//           _attemptResumeLiveStream();
//           _lastPlayingTime = DateTime.now();
//         }
//       }
//     } else if (playingState == PlayingState.paused) {
//       if (_isUserPaused) {
//         _lastPlayingTime = DateTime.now();
//       } else {
//         final stalledDuration = DateTime.now().difference(_lastPlayingTime);
//         if (stalledDuration > Duration(seconds: 5)) {
//           print("⚠️ Auto-Pause detected (Network issue). Force restarting...");
//           _attemptResumeLiveStream();
//           _lastPlayingTime = DateTime.now();
//         }
//       }
//     }

//     if (mounted) {
//       setState(() {
//         _isBuffering = isBuffering;

//         if (playingState == PlayingState.playing && !isBuffering) {
//           _loadingVisible = false;
//         } else if (playingState == PlayingState.buffering ||
//             playingState == PlayingState.initializing) {
//           _loadingVisible = true;
//         }

//         if (_isAttemptingResume) {
//           _loadingVisible = true;
//         }
//       });
//     }
//   }

//   void _startPositionUpdater() {
//     Timer.periodic(Duration(seconds: 2), (_) {
//       if (!mounted ||
//           _controller == null ||
//           !_controller!.value.isInitialized) {
//         return;
//       }

//       final VlcPlayerValue value = _controller!.value;
//       final Duration currentPosition = value.position;

//       if (mounted && !_isScrubbing) {
//         setState(() {
//           _lastKnownPosition = currentPosition;
//         });
//       }

//       if (widget.liveStatus == true &&
//           !_isAttemptingResume &&
//           _hasStartedPlaying) {
//         if (value.playingState == PlayingState.playing) {
//           if (_lastPositionCheck != Duration.zero &&
//               currentPosition == _lastPositionCheck) {
//             _stallCounter++;
//             print(
//                 "⚠️ Posición atascada (Fotograma Congelado). Contador: $_stallCounter");
//           } else {
//             _stallCounter = 0;
//           }

//           if (_stallCounter >= 3) {
//             print("🔴 ATASCADO (Fotograma Congelado). Intentando resumen...");
//             _attemptResumeLiveStream();
//             _stallCounter = 0;
//           }
//         } else {
//           _stallCounter = 0;
//         }
//         _lastPositionCheck = currentPosition;
//       }
//     });
//   }

//   void _scrollToFocusedItem() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_focusedIndex < 0 ||
//           !_scrollController.hasClients ||
//           _focusedIndex >= focusNodes.length) {
//         return;
//       }
//       final context = focusNodes[_focusedIndex].context;
//       if (context == null) return;

//       Scrollable.ensureVisible(
//         context,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         alignment: 0.5,
//       );
//     });
//   }

//   Future<void> _onNetworkReconnected() async {
//     if (_controller == null || _currentModifiedUrl == null) return;

//     final fullUrl = _buildVlcUrl(_currentModifiedUrl!);
//     print("Reconectando a: $fullUrl");

//     try {
//       if (widget.liveStatus == true) {
//         print("Reconexión Live Stream: Reiniciando stream...");
//         await _retryPlayback(fullUrl, 4);
//       } else {
//         print("Reconexión VOD: Intentando resumir desde $_lastKnownPosition");

//         try {
//           await _controller!.pause();
//           await Future.delayed(const Duration(milliseconds: 100));

//           if (_lastKnownPosition != Duration.zero) {
//             await _seekToPosition(_lastKnownPosition);
//           } else {
//             await _controller!.play();
//           }
//           print("✅ VOD Resumido (Plan A) tras reconexión.");
//         } catch (e) {
//           print("⚠️ Plan A falló. Recurriendo a Plan B (Recarga). Error: $e");

//           await _retryPlayback(fullUrl, 4);

//           await Future.delayed(const Duration(seconds: 2));

//           if (_lastKnownPosition != Duration.zero) {
//             await _seekToPosition(_lastKnownPosition);
//           }
//           print("✅ VOD Resumido (Plan B) tras reconexión.");
//         }
//       }
//     } catch (e) {
//       print("❌ Error crítico durante reconexión: $e");
//     }
//   }

//   Future<bool> _isInternetAvailable() async {
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } catch (_) {
//       return false;
//     }
//   }

//   String _buildVlcUrl(String baseUrl) {
//     final String networkCaching = "network-caching=60000";
//     final String liveCaching = "live-caching=30000";
//     final String fileCaching = "file-caching=20000";
//     final String rtspTcp = "rtsp-tcp";

//     if (widget.liveStatus == true) {
//       return '$baseUrl?$networkCaching&$liveCaching&$fileCaching&$rtspTcp';
//     } else {
//       return '$baseUrl?$networkCaching&$fileCaching&$rtspTcp';
//     }
//   }

//   bool _isSeeking = false;
//   Future<void> _seekToPosition(Duration position) async {
//     if (_isSeeking || _controller == null) return;
//     _isSeeking = true;
//     try {
//       print("Buscando posición: $position");
//       await _controller!.seekTo(position);
//       await _controller!.play();
//     } catch (e) {
//       print("Error durante seek: $e");
//     } finally {
//       await Future.delayed(Duration(milliseconds: 500));
//       _isSeeking = false;
//     }
//   }

//   void _togglePlayPause() {
//     if (_controller != null && _controller!.value.isInitialized) {
//       if (_controller!.value.isPlaying) {
//         _controller!.pause();
//         setState(() {
//            _isUserPaused = true;
//         });
//       } else {
//         _controller!.play();
//         setState(() {
//            _isUserPaused = false;
//         });
//         _lastPlayingTime = DateTime.now();
//         _stallCounter = 0;
//       }
//     }
//     FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//     _resetHideControlsTimer();
//   }

//   void _resetHideControlsTimer() {
//     _hideControlsTimer.cancel();
//     if (!_controlsVisible) {
//       setState(() {
//         _controlsVisible = true;
//       });
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!mounted) return;
//         if (widget.liveStatus == false || widget.channelList.isEmpty) {
//           FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//         } else {
//           FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//           _scrollToFocusedItem();
//         }
//       });
//     }
//     _startHideControlsTimer();
//   }

//   void _startHideControlsTimer() {
//     _hideControlsTimer = Timer(Duration(seconds: 10), () {
//       if (mounted) {
//         setState(() {
//           _controlsVisible = false;
//         });
//       }
//     });
//   }

//   int _accumulatedSeekForward = 0;
//   int _accumulatedSeekBackward = 0;
//   Timer? _seekTimer;
//   Duration _previewPosition = Duration.zero;
//   final int _seekDuration = 5;
//   final int _seekDelay = 800;

//   void _seekForward() {
//     if (_controller == null ||
//         !_controller!.value.isInitialized ||
//         _controller!.value.duration <= Duration.zero) return;

//     _accumulatedSeekForward += _seekDuration;
//     final newPosition = _controller!.value.position +
//         Duration(seconds: _accumulatedSeekForward);

//     setState(() {
//       _previewPosition = newPosition > _controller!.value.duration
//           ? _controller!.value.duration
//           : newPosition;
//     });

//     _seekTimer?.cancel();
//     _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
//       _seekToPosition(_previewPosition).then((_) {
//         setState(() {
//           _accumulatedSeekForward = 0;
//         });
//       });
//     });
//   }

//   void _seekBackward() {
//     if (_controller == null ||
//         !_controller!.value.isInitialized ||
//         _controller!.value.duration <= Duration.zero) return;

//     _accumulatedSeekBackward += _seekDuration;
//     final newPosition = _controller!.value.position -
//         Duration(seconds: _accumulatedSeekBackward);

//     setState(() {
//       _previewPosition =
//           newPosition > Duration.zero ? newPosition : Duration.zero;
//     });

//     _seekTimer?.cancel();
//     _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
//       _seekToPosition(_previewPosition).then((_) {
//         setState(() {
//           _accumulatedSeekBackward = 0;
//         });
//       });
//     });
//   }

//   String _formatDuration(Duration duration) {
//     if (duration.isNegative) {
//       duration = Duration.zero;
//     }
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//   }

//   void _onScrubStart(DragStartDetails details, BoxConstraints constraints) {
//     if (_controller == null || _controller!.value.duration <= Duration.zero)
//       return;

//     _resetHideControlsTimer();
//     setState(() {
//       _isScrubbing = true;
//       _accumulatedSeekForward = 1;
//       final double progress =
//           (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
//       _previewPosition = _controller!.value.duration * progress;
//     });
//   }

//   void _onScrubUpdate(DragUpdateDetails details, BoxConstraints constraints) {
//     if (!_isScrubbing ||
//         _controller == null ||
//         _controller!.value.duration <= Duration.zero) return;

//     _resetHideControlsTimer();
//     final double progress =
//         (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
//     final newPosition = _controller!.value.duration * progress;
//     setState(() {
//       _previewPosition = newPosition;
//     });
//   }

//   void _onScrubEnd(DragEndDetails details) {
//     if (!_isScrubbing) return;

//     _seekToPosition(_previewPosition).then((_) {
//       setState(() {
//         _accumulatedSeekForward = 0;
//       });
//     });
//     _resetHideControlsTimer();
//     setState(() {
//       _isScrubbing = false;
//     });
//   }

//   // Widget _buildVideoPlayer() {
//   //   if (!_isVideoInitialized || _controller == null) {
//   //     return Center(child: CircularProgressIndicator());
//   //   }
//   //   return LayoutBuilder(
//   //     builder: (context, constraints) {
//   //       final screenWidth = constraints.maxWidth;
//   //       final screenHeight = constraints.maxHeight;
//   //       final videoWidth = _controller!.value.size.width ?? screenWidth;
//   //       final videoHeight = _controller!.value.size.height ?? screenHeight;
//   //       final videoRatio = videoWidth / videoHeight;
//   //       final screenRatio = screenWidth / screenHeight;

//   //       double scaleX = 1.0;
//   //       double scaleY = 1.0;

//   //       if (videoRatio < screenRatio) {
//   //         scaleX = screenRatio / videoRatio;
//   //       } else {
//   //         scaleY = videoRatio / screenRatio;
//   //       }

//   //       return Container(
//   //         width: screenWidth,
//   //         height: screenHeight,
//   //         color: Colors.black,
//   //         child: Center(
//   //           child: Transform.scale(
//   //             scaleX: scaleX,
//   //             scaleY: scaleY,
//   //             child: VlcPlayer(
//   //               key: ValueKey(_currentModifiedUrl ?? widget.videoUrl),
//   //               controller: _controller!,
//   //               placeholder: Center(child: CircularProgressIndicator()),
//   //               aspectRatio: 16 / 9,
//   //             ),
//   //           ),
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }

//   Widget _buildVideoPlayer() {
//     if (!_isVideoInitialized || _controller == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final screenWidth = constraints.maxWidth;
//         final screenHeight = constraints.maxHeight;

//         // 1. Safe fallbacks for initial loading
//         double videoWidth = _controller!.value.size.width;
//         double videoHeight = _controller!.value.size.height;

//         if (videoWidth <= 0 || videoHeight <= 0) {
//           videoWidth = 16.0;
//           videoHeight = 9.0;
//         }

//         final videoRatio = videoWidth / videoHeight;
//         final screenRatio = screenWidth / screenHeight;

//         double scaleX = 1.0;
//         double scaleY = 1.0;

//         // 2. Original calculation to fill the screen
//         if (videoRatio < screenRatio) {
//           scaleX = screenRatio / videoRatio;
//         } else {
//           scaleY = videoRatio / screenRatio;
//         }

//         // 3. THE FIX: Clamp the maximum scale.
//         // This prevents the 3x zoom on weirdly sized 10% videos.
//         // It allows up to a 35% zoom to fill small black bars, but stops it from going out of bounds.
//         const double maxScaleLimit = 1.35;

//         if (scaleX > maxScaleLimit) {
//           scaleX = maxScaleLimit;
//         }
//         if (scaleY > maxScaleLimit) {
//           scaleY = maxScaleLimit;
//         }

//         return Container(
//           width: screenWidth,
//           height: screenHeight,
//           color: Colors.black,
//           child: Center(
//             child: Transform.scale(
//               scaleX: scaleX,
//               scaleY: scaleY,
//               child: VlcPlayer(
//                 key: ValueKey(_currentModifiedUrl ?? widget.videoUrl),
//                 controller: _controller!,
//                 placeholder: const Center(child: CircularProgressIndicator()),
//                 // 4. THE FIX: Use the actual video ratio instead of hardcoding 16/9
//                 aspectRatio: videoRatio,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: SizedBox(
//           width: screenwdt,
//           height: screenhgt,
//           child:
//           // Focus(
//           //   autofocus: true,
//           //   onKey: (node, event) {
//           //     if (event is RawKeyDownEvent) {
//           //       _handleKeyEvent(event);
//           //       return KeyEventResult.handled;
//           //     }
//           //     return KeyEventResult.ignored;
//           //   },
//           Focus(
//   autofocus: true,
//   onKey: (node, event) {
//     if (event is RawKeyDownEvent) {
//       // Check if our code handled the key
//       bool isHandled = _handleKeyEvent(event);
//       // If we didn't handle it (like the back button), return ignored!
//       return isHandled ? KeyEventResult.handled : KeyEventResult.ignored;
//     }
//     return KeyEventResult.ignored;
//   },
//             child: GestureDetector(
//               onTap: _resetHideControlsTimer,
//               child: Stack(
//                 children: [
//                   if (_isVideoInitialized && _controller != null)
//                     _buildVideoPlayer(),
//                   if (_loadingVisible ||
//                       !_isVideoInitialized ||
//                       _isAttemptingResume ||
//                       (_isBuffering && !_loadingVisible))
//                     Container(
//                       color: _loadingVisible || !_isVideoInitialized
//                           ? Colors.black54
//                           : Colors.transparent,
//                       child: Center(
//                         child: RainbowPage(
//                           backgroundColor:
//                               _loadingVisible || !_isVideoInitialized
//                                   ? Colors.black
//                                   : Colors.transparent,
//                         ),
//                       ),
//                     ),

// if (_controlsVisible)
//   Positioned(
//     top: MediaQuery.of(context).size.height * 0.05,
//     left: 0,
//     right: 0,
//     child: Center(
//       child: ShaderMask(
//         shaderCallback: (bounds) {
//           return const LinearGradient(
//             colors: [
//               Color(0xFF9B28F8), // Purple
//               Color(0xFFE62B1E), // Red
//               Color.fromARGB(255, 53, 255, 53), // Orange
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
//         },
//         child: Text(
//           widget.channelList.isNotEmpty
//               ? (widget.channelList[_focusedIndex].name ?? widget.name)
//               : widget.name,
//           style: const TextStyle(
//             color: Colors.white, // Must be white for ShaderMask to work properly
//             fontSize: 34,
//             fontWeight: FontWeight.w900, // Maximum boldness for gradient
//             letterSpacing: 1.2,
//             shadows: [
//               // Multiple shadows create a glowing effect
//               Shadow(
//                 offset: Offset(0, 4),
//                 blurRadius: 10.0,
//                 color: Colors.black87,
//               ),
//               Shadow(
//                 offset: Offset(0, 0),
//                 blurRadius: 20.0,
//                 color: Colors.black54,
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   ),

//                   if (_controlsVisible && widget.channelList.isNotEmpty)
//                     _buildChannelList(),
//                   _buildControls(),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildChannelList() {
//     return Positioned(
//       top: MediaQuery.of(context).size.height * 0.02,
//       bottom: MediaQuery.of(context).size.height * 0.1,
//       left: screenwdt * 0.02,
//       right: MediaQuery.of(context).size.width * 0.82,
//       child: ListView.builder(
//         controller: _scrollController,
//         itemCount: widget.channelList.length,
//         itemBuilder: (context, index) {
//           final channel = widget.channelList[index];
//           final String channelId = channel.id?.toString() ?? '';
//           final bool isBase64 =
//               channel.banner?.startsWith('data:image') ?? false;
//           final bool isFocused = _focusedIndex == index;

//           return Padding(
//             padding:
//                 const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//             child: Focus(
//               focusNode: focusNodes[index],
//               onFocusChange: (hasFocus) {
//                 if (hasFocus) {
//                   print("✅ FOCO GANADO: Canal en índice $index");
//                   _scrollToFocusedItem();
//                 }
//               },
//               child: GestureDetector(
//                 onTap: () {
//                   _onItemTap(index);
//                   _resetHideControlsTimer();
//                 },
//                 child: Container(
//                   width: screenwdt * 0.18,
//                   height: screenhgt * 0.108,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: isFocused && !playPauseButtonFocusNode.hasFocus
//                           ? const Color.fromARGB(211, 155, 40, 248)
//                           : Colors.transparent,
//                       width: 5.0,
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                     color: isFocused ? Colors.black26 : Colors.transparent,
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(6),
//                     child: Stack(
//                       children: [
//                         Positioned.fill(
//                           child: Opacity(
//                             opacity: 0.6,
//                             child: isBase64
//                                 ? Image.memory(
//                                     _bannerCache[channelId] ??
//                                         _getCachedImage(
//                                             channel.banner ?? localImage),
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, e, s) =>
//                                         Image.asset('assets/placeholder.png'),
//                                   )
//                                 : CachedNetworkImage(
//                                     imageUrl: channel.banner ?? localImage,
//                                     fit: BoxFit.cover,
//                                     errorWidget: (context, url, error) =>
//                                         Image.asset('assets/placeholder.png'),
//                                   ),
//                           ),
//                         ),
//                         if (isFocused)
//                           Positioned.fill(
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                   colors: [
//                                     Colors.transparent,
//                                     Colors.black.withOpacity(0.9),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
// if (isFocused)
//                           Positioned(
//                             left: 8,
//                             bottom: 8,
//                             right: 8, // Added to constrain the maximum width
//                             child: FittedBox(
//                               fit: BoxFit.scaleDown, // Shrinks the text if it overflows
//                               alignment: Alignment.centerLeft, // Keeps the text aligned to the left
//                               child: Text(
//                                 channel.name ?? '',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14, // This acts as the maximum font size
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 maxLines: 1, // Enforces a single line
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildControls() {
//     final Duration currentPosition = _accumulatedSeekForward > 0 ||
//             _accumulatedSeekBackward > 0 ||
//             _isScrubbing
//         ? _previewPosition
//         : _controller?.value.position ?? Duration.zero;
//     final Duration totalDuration = _controller?.value.duration ?? Duration.zero;

//     return Positioned(
//       bottom: 0,
//       left: 0,
//       right: 0,
//       child: Opacity(
//         opacity: _controlsVisible ? 1 : 0.0,
//         child: IgnorePointer(
//           ignoring: !_controlsVisible,
//           child: Container(
//             color: Colors.black54,
//             padding: const EdgeInsets.symmetric(vertical: 4.0),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(width: screenwdt * 0.03),
//                 Container(
//                   color: playPauseButtonFocusNode.hasFocus
//                       ? const Color.fromARGB(200, 16, 62, 99)
//                       : Colors.transparent,
//                   child: Focus(
//                     focusNode: playPauseButtonFocusNode,
//                     onFocusChange: (hasFocus) {
//                       if (hasFocus) print("✅ FOCO GANADO: Botón Play/Pause");
//                       setState(() {});
//                     },
//                     child: IconButton(
//                       icon: Image.asset(
//                         (_controller?.value.isPlaying ?? false)
//                             ? 'assets/pause.png'
//                             : 'assets/play.png',
//                         width: 35,
//                         height: 35,
//                       ),
//                       onPressed: _togglePlayPause,
//                     ),
//                   ),
//                 ),
//                 if (widget.liveStatus == false)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                     child: Text(
//                       _formatDuration(currentPosition),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 Expanded(
//                   flex: 10,
//                   child: LayoutBuilder(
//                     builder: (context, constraints) {
//                       return GestureDetector(
//                         onHorizontalDragStart: (widget.liveStatus == false)
//                             ? (details) => _onScrubStart(details, constraints)
//                             : null,
//                         onHorizontalDragUpdate: (widget.liveStatus == false)
//                             ? (details) => _onScrubUpdate(details, constraints)
//                             : null,
//                         onHorizontalDragEnd: (widget.liveStatus == false)
//                             ? (details) => _onScrubEnd(details)
//                             : null,
//                         child: Container(
//                           color: Colors.transparent,
//                           child: _buildBeautifulProgressBar(
//                               currentPosition, totalDuration),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 if (widget.liveStatus == false)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                     child: Text(
//                       _formatDuration(totalDuration),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 if (widget.liveStatus == true)
//                   Expanded(
//                     flex: 1,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const [
//                         Icon(Icons.circle, color: Colors.red, size: 15),
//                         SizedBox(width: 5),
//                         Text(
//                           'Live',
//                           style: TextStyle(
//                             color: Colors.red,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 SizedBox(width: screenwdt * 0.03),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBeautifulProgressBar(
//       Duration displayPosition, Duration totalDuration) {
//     final totalDurationMs = totalDuration.inMilliseconds.toDouble();

//     if (totalDurationMs <= 0 || widget.liveStatus == true) {
//       return Container(
//         padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//         child: Container(
//             height: 8,
//             decoration: BoxDecoration(
//                 color: Colors.grey[800],
//                 borderRadius: BorderRadius.circular(4))),
//       );
//     }

//     double playedProgress =
//         (displayPosition.inMilliseconds / totalDurationMs).clamp(0.0, 1.0);

//     double bufferedProgress = (playedProgress + 0.005).clamp(0.0, 1.0);

//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//       child: Container(
//         height: 8,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(4),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 4,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(4),
//           child: Stack(
//             children: [
//               Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.grey[800]!, Colors.grey[700]!],
//                   ),
//                 ),
//               ),
//               FractionallySizedBox(
//                 widthFactor: bufferedProgress,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.grey[600]!, Colors.grey[500]!],
//                     ),
//                   ),
//                 ),
//               ),
//               FractionallySizedBox(
//                 widthFactor: playedProgress,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Color(0xFF9B28F8),
//                         Color(0xFFE62B1E),
//                         Color(0xFFFF6B35),
//                       ],
//                       stops: [0.0, 0.7, 1.0],
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Color(0xFF9B28F8).withOpacity(0.6),
//                         blurRadius: 8,
//                         spreadRadius: 1,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:keep_screen_on/keep_screen_on.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
// import 'package:mobi_tv_entertainment/components/widgets/small_widgets/rainbow_page.dart';
// import 'package:mobi_tv_entertainment/main.dart';

// class GlobalVariables {
//   static String unUpdatedUrl = '';
//   static Duration position = Duration.zero;
//   static Duration duration = Duration.zero;
//   static String banner = '';
//   static String name = '';
//   static bool liveStatus = false;
// }

// class RefreshPageEvent {
//   final String pageId;
//   RefreshPageEvent(this.pageId);
// }

// class VideoScreen extends StatefulWidget {
//   final String videoUrl;
//   final String name;
//   final bool liveStatus;
//   final String updatedAt;
//   final List<dynamic> channelList;
//   final String bannerImageUrl;
//   final int? videoId;
//   final String source;

//   VideoScreen({
//     required this.videoUrl,
//     required this.updatedAt,
//     required this.channelList,
//     required this.bannerImageUrl,
//     required this.videoId,
//     required this.source,
//     required this.name,
//     required this.liveStatus,
//   });

//   @override
//   _VideoScreenState createState() => _VideoScreenState();
// }

// class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
//   VlcPlayerController? _controller;
//   bool _controlsVisible = true;
//   late Timer _hideControlsTimer;
//   bool _isBuffering = false;
//   bool _isVideoInitialized = false;
//   int _focusedIndex = 0;
//   List<FocusNode> focusNodes = [];
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode playPauseButtonFocusNode = FocusNode();

//   // --- SUBTITLE VARIABLES ---
//   final FocusNode subtitleButtonFocusNode = FocusNode();
//   Map<int, String> _spuTracks = {};
//   int _currentSpuTrack = -1;
//   bool _hasFetchedSubtitles = false;
//   // --------------------------

//   bool _loadingVisible = false;
//   Duration _lastKnownPosition = Duration.zero;
//   Timer? _networkCheckTimer;
//   bool _wasDisconnected = false;
//   String? _currentModifiedUrl;

//   bool _isAttemptingResume = false;
//   DateTime _lastPlayingTime = DateTime.now();
//   Duration _lastPositionCheck = Duration.zero;
//   int _stallCounter = 0;
//   bool _hasStartedPlaying = false;

//   bool _isScrubbing = false;
//   bool _isUserPaused = false;

//   Map<String, Uint8List> _bannerCache = {};

//   bool _isDisposing = false;

//   Uint8List _getCachedImage(String base64String) {
//     try {
//       if (!_bannerCache.containsKey(base64String)) {
//         _bannerCache[base64String] = base64Decode(base64String.split(',').last);
//       }
//       return _bannerCache[base64String]!;
//     } catch (e) {
//       print('Error processing image: $e');
//       return Uint8List.fromList([0, 0, 0, 0]);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     KeepScreenOn.turnOn();

//     _focusedIndex = widget.channelList.indexWhere(
//       (channel) => channel.id.toString() == widget.videoId.toString(),
//     );
//     _focusedIndex = (_focusedIndex >= 0) ? _focusedIndex : 0;

//     focusNodes = List.generate(
//       widget.channelList.length,
//       (index) => FocusNode(),
//     );

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusAndScrollToInitialItem();
//     });

//     _initPlayerWithSecureUrl();
//     _startHideControlsTimer();
//     _startNetworkMonitor();
//     _startPositionUpdater();
//   }

//   Future<void> _initializeVLCController(String baseUrl) async {
//     if (_isDisposing || !mounted) return;

//     print("--- Initializing Video Player ---");

//     setState(() {
//       _isVideoInitialized = false;
//       _loadingVisible = true;
//     });

//     try {
//       if (_controller != null) {
//         _controller!.removeListener(_vlcListener);
//         await _controller!.stop();
//         await _controller!.dispose();
//         _controller = null;
//         print("Cleanup: Previous controller disposed successfully.");
//       }
//     } catch (e) {
//       print("Cleanup Warning: Error disposing old controller: $e");
//     }

//     try {
//       _currentModifiedUrl = baseUrl;
//       final String fullVlcUrl = _buildVlcUrl(baseUrl);

//       _lastPlayingTime = DateTime.now();
//       _lastPositionCheck = Duration.zero;
//       _stallCounter = 0;
//       _hasStartedPlaying = false;
//       _hasFetchedSubtitles = false;

//       print("Source: $fullVlcUrl");

//       _controller = VlcPlayerController.network(
//         fullVlcUrl,
//         hwAcc: HwAcc.auto,
//         options: VlcPlayerOptions(
//           video: VlcVideoOptions([
//             VlcVideoOptions.dropLateFrames(true),
//             VlcVideoOptions.skipFrames(true),
//           ]),
//         ),
//       );

//       await _retryPlayback(fullVlcUrl, 3);

//       if (_controller != null && mounted) {
//         _controller!.addListener(_vlcListener);
//         setState(() {
//           _isVideoInitialized = true;
//         });
//         print("Status: Video Initialized successfully.");
//       }
//     } catch (e) {
//       print("Error: Initialization failed: $e");
//       if (mounted) setState(() => _loadingVisible = false);
//     }
//   }

//   Future<void> _retryPlayback(String url, int retries) async {
//     for (int i = 0; i < retries; i++) {
//       if (!mounted || _controller == null) return;
//       try {
//         print("Playback Attempt ${i + 1}/$retries");
//         await _controller!.setMediaFromNetwork(url);
//         await _controller!.play();
//         return;
//       } catch (e) {
//         print("Playback Attempt ${i + 1} failed: $e");
//         if (i < retries - 1) {
//           await Future.delayed(const Duration(seconds: 1));
//         }
//       }
//     }
//   }

//   Future<void> _onItemTap(int index) async {
//     if (!mounted || _isDisposing) return;

//     setState(() {
//       _loadingVisible = true;
//       _focusedIndex = index;
//     });

//     try {
//       var selectedChannel = widget.channelList[index];
//       print("Switching to Channel: ${selectedChannel.name}");

//       String secureUrl = await SecureUrlService.getSecureUrl(
//           selectedChannel.url.toString(),
//           expirySeconds: 10);

//       await _initializeVLCController(secureUrl);

//       _scrollToFocusedItem();
//       _resetHideControlsTimer();
//     } catch (e) {
//       print("Error: Failed to switch channel: $e");
//       if (mounted) setState(() => _loadingVisible = false);
//     }
//   }

//   void _startNetworkMonitor() {
//     _networkCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
//       bool isConnected = await _isInternetAvailable();
//       if (!isConnected && !_wasDisconnected) {
//         _wasDisconnected = true;
//         print("Network: Connection lost.");
//       } else if (isConnected && _wasDisconnected) {
//         _wasDisconnected = false;
//         print("Network: Connection restored. Resuming playback...");
//         if (_controller?.value.isInitialized ?? false) {
//           _onNetworkReconnected();
//         }
//       }
//     });
//   }

//   Future<void> _attemptResumeLiveStream() async {
//     if (!mounted || _isAttemptingResume || _controller == null || widget.liveStatus == false) {
//       return;
//     }

//     setState(() {
//       _isAttemptingResume = true;
//       _loadingVisible = true;
//     });

//     print("Stability: Live stream stall detected. Attempting recovery with NEW TOKEN...");

//     try {
//       String newSecureUrl = widget.videoUrl;
//       try {
//          newSecureUrl = await SecureUrlService.getSecureUrl(
//             widget.videoUrl,
//             expirySeconds: 10
//          );
//       } catch(e) {
//          print("Token refresh failed, using original: $e");
//       }

//       _currentModifiedUrl = newSecureUrl;

//       final urlToResume = _buildVlcUrl(newSecureUrl);

//       await _retryPlayback(urlToResume, 4);

//       _lastPlayingTime = DateTime.now();
//       _stallCounter = 0;

//       _isUserPaused = false;

//       print("Stability: Recovery process finished.");
//     } catch (e) {
//       print("Error: Recovery failed: $e");
//     } finally {
//       if (mounted) {
//         setState(() => _isAttemptingResume = false);
//       }
//     }
//   }

//   Future<void> _safeDispose() async {
//     if (_isDisposing) return;

//     _isDisposing = true;
//     print("🔄 Safe disposal started...");

//     _hideControlsTimer.cancel();
//     _networkCheckTimer?.cancel();
//     _seekTimer?.cancel();

//     focusNodes.forEach((node) => node.dispose());
//     playPauseButtonFocusNode.dispose();
//     subtitleButtonFocusNode.dispose();
//     _scrollController.dispose();

//     try {
//       if (_controller != null) {
//         _controller?.removeListener(_vlcListener);
//         await _controller?.stop();
//         await _controller?.dispose();
//         _controller = null;
//         print("✅ VLC Controller safely disposed");
//       }
//     } catch (e) {
//       print("⚠️ Warning during VLC controller disposal: $e");
//     }

//     KeepScreenOn.turnOff();
//     WidgetsBinding.instance.removeObserver(this);

//     print("✅ Safe disposal completed");
//   }

//   @override
//   void dispose() {
//     print("🗑️ VideoScreen dispose called");
//     _safeDispose();
//     super.dispose();
//   }

//   Future<bool> _onWillPop() async {
//     print("🚨 SYSTEM BACK BUTTON DETECTED 🚨");

//     _safeDispose();

//     if (mounted) {
//       Navigator.of(context).pop();
//     }

//     return true;
//   }

//   void _focusAndScrollToInitialItem() {
//     if (_focusedIndex < 0 || _focusedIndex >= focusNodes.length || !mounted) {
//       return;
//     }

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!_scrollController.hasClients) return;

//       final double itemHeight = (screenhgt * 0.108) + 16.0;
//       final double viewportHeight = MediaQuery.of(context).size.height * 0.88;
//       final double targetOffset = (itemHeight * _focusedIndex) - (viewportHeight / 2) + (itemHeight / 2);

//       final double clampedOffset = targetOffset.clamp(
//         _scrollController.position.minScrollExtent,
//         _scrollController.position.maxScrollExtent,
//       );
//       _scrollController.jumpTo(clampedOffset);

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!mounted) return;
//         if (widget.liveStatus == false) {
//           FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//         } else if (widget.channelList.isNotEmpty &&
//             _focusedIndex < focusNodes.length) {
//           FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//         } else {
//           FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//         }
//       });
//     });
//   }

//   void _changeFocusAndScroll(int newIndex) {
//     if (newIndex < 0 || newIndex >= widget.channelList.length) {
//       return;
//     }

//     setState(() {
//       _focusedIndex = newIndex;
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!_scrollController.hasClients || !mounted) return;

//       final double itemHeight = (screenhgt * 0.108) + 16.0;
//       final double viewportHeight = MediaQuery.of(context).size.height * 0.88;
//       final double targetOffset = (itemHeight * _focusedIndex) - (viewportHeight / 2) + (itemHeight / 2);

//       final double clampedOffset = targetOffset.clamp(
//         _scrollController.position.minScrollExtent,
//         _scrollController.position.maxScrollExtent,
//       );
//       _scrollController.jumpTo(clampedOffset);

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//         }
//       });
//     });
//   }

//   Future<void> _initPlayerWithSecureUrl() async {
//     try {
//       String secureUrl = await SecureUrlService.getSecureUrl(widget.videoUrl,
//           expirySeconds: 10);
//       print('Initializing secureUrl: $secureUrl');
//       if (!mounted) return;

//       _initializeVLCController(secureUrl);
//     } catch (e) {
//       print("Secure URL error: $e");
//       await _initializeVLCController(widget.videoUrl);
//     }
//   }

//   bool _handleKeyEvent(RawKeyEvent event) {
//     print("📺 REMOTE KEY PRESSED: ${event.logicalKey.keyLabel} (ID: ${event.logicalKey.keyId})");
//     if (event is RawKeyDownEvent) {
//       _resetHideControlsTimer();

//       switch (event.logicalKey) {
//         case LogicalKeyboardKey.escape:
//         case LogicalKeyboardKey.browserBack:
//           print("🔙 TV Remote Back Button explicitly caught!");
//           _safeDispose();
//           Navigator.maybePop(context);
//           return true;

//         case LogicalKeyboardKey.arrowUp:
//           if (subtitleButtonFocusNode.hasFocus) {
//             FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//             return true;
//           }
//           if (playPauseButtonFocusNode.hasFocus) {
//             if (widget.liveStatus == false && widget.channelList.isNotEmpty) {
//               FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//             }
//           } else if (_focusedIndex > 0) {
//             _changeFocusAndScroll(_focusedIndex - 1);
//           }
//           return true;

//         case LogicalKeyboardKey.arrowDown:
//           if (playPauseButtonFocusNode.hasFocus && widget.liveStatus == false) {
//             FocusScope.of(context).requestFocus(subtitleButtonFocusNode);
//             return true;
//           }
//           if (_focusedIndex < widget.channelList.length - 1) {
//             _changeFocusAndScroll(_focusedIndex + 1);
//           }
//           return true;

//         case LogicalKeyboardKey.arrowRight:
//           if (widget.liveStatus == false) {
//             _seekForward();
//           }
//           return true;

//         case LogicalKeyboardKey.arrowLeft:
//           if (widget.liveStatus == false) {
//             _seekBackward();
//           }
//           if (playPauseButtonFocusNode.hasFocus &&
//               widget.channelList.isNotEmpty) {
//             FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//           }
//           return true;

//         case LogicalKeyboardKey.select:
//         case LogicalKeyboardKey.enter:
//           if (subtitleButtonFocusNode.hasFocus) {
//             _showSubtitleMenu();
//             return true;
//           }
//           if (widget.liveStatus == false) {
//             _togglePlayPause();
//           } else {
//             if (playPauseButtonFocusNode.hasFocus ||
//                 widget.channelList.isEmpty) {
//               _togglePlayPause();
//             } else {
//               _onItemTap(_focusedIndex);
//             }
//           }
//           return true;

//         default:
//           return false;
//       }
//     }
//     return false;
//   }

//   Future<void> _fetchSubtitles() async {
//     if (_controller != null && _controller!.value.isInitialized) {
//       final tracks = await _controller!.getSpuTracks();
//       final current = await _controller!.getSpuTrack() ?? -1;
//       if (mounted) {
//         setState(() {
//           _spuTracks = tracks;
//           _currentSpuTrack = current;
//           _hasFetchedSubtitles = true;
//         });
//       }
//     }
//   }

//   void _vlcListener() {
//     if (!mounted || _controller == null || !_controller!.value.isInitialized)
//       return;

//     final VlcPlayerValue value = _controller!.value;
//     final bool isBuffering = value.isBuffering;
//     final PlayingState playingState = value.playingState;

//     if (widget.liveStatus == true && !_isAttemptingResume) {
//       if (playingState == PlayingState.playing) {
//         _lastPlayingTime = DateTime.now();
//         if (!_hasStartedPlaying) {
//           _hasStartedPlaying = true;
//         }
//         if (!_hasFetchedSubtitles) {
//           _fetchSubtitles();
//         }
//       } else if (playingState == PlayingState.buffering && _hasStartedPlaying) {
//         final stalledDuration = DateTime.now().difference(_lastPlayingTime);
//         if (stalledDuration > Duration(seconds: 8)) {
//           print(
//               "⚠️ Stall (Listener): Buffering for ${stalledDuration.inSeconds} sec.");
//           _attemptResumeLiveStream();
//           _lastPlayingTime = DateTime.now();
//         }
//       } else if (playingState == PlayingState.error) {
//         print("⚠️ Stall (Listener): Player in error state.");
//         _attemptResumeLiveStream();
//         _lastPlayingTime = DateTime.now();
//       } else if ((playingState == PlayingState.stopped ||
//               playingState == PlayingState.ended) &&
//           _hasStartedPlaying) {
//         final stalledDuration = DateTime.now().difference(_lastPlayingTime);
//         if (stalledDuration > Duration(seconds: 5)) {
//           print("⚠️ Stall (Listener): Player stopped unexpectedly.");
//           _attemptResumeLiveStream();
//           _lastPlayingTime = DateTime.now();
//         }
//       }
//     } else if (playingState == PlayingState.paused) {
//       if (_isUserPaused) {
//         _lastPlayingTime = DateTime.now();
//       } else {
//         final stalledDuration = DateTime.now().difference(_lastPlayingTime);
//         if (stalledDuration > Duration(seconds: 5)) {
//           print("⚠️ Auto-Pause detected (Network issue). Force restarting...");
//           _attemptResumeLiveStream();
//           _lastPlayingTime = DateTime.now();
//         }
//       }
//     } else if (playingState == PlayingState.playing && widget.liveStatus == false) {
//       if (!_hasFetchedSubtitles) {
//         _fetchSubtitles();
//       }
//     }

//     if (mounted) {
//       setState(() {
//         _isBuffering = isBuffering;

//         if (playingState == PlayingState.playing && !isBuffering) {
//           _loadingVisible = false;
//         } else if (playingState == PlayingState.buffering ||
//             playingState == PlayingState.initializing) {
//           _loadingVisible = true;
//         }

//         if (_isAttemptingResume) {
//           _loadingVisible = true;
//         }
//       });
//     }
//   }

//   void _startPositionUpdater() {
//     Timer.periodic(Duration(seconds: 2), (_) {
//       if (!mounted ||
//           _controller == null ||
//           !_controller!.value.isInitialized) {
//         return;
//       }

//       final VlcPlayerValue value = _controller!.value;
//       final Duration currentPosition = value.position;

//       if (mounted && !_isScrubbing) {
//         setState(() {
//           _lastKnownPosition = currentPosition;
//         });
//       }

//       if (widget.liveStatus == true &&
//           !_isAttemptingResume &&
//           _hasStartedPlaying) {
//         if (value.playingState == PlayingState.playing) {
//           if (_lastPositionCheck != Duration.zero &&
//               currentPosition == _lastPositionCheck) {
//             _stallCounter++;
//             print(
//                 "⚠️ Position stuck (Frozen Frame). Counter: $_stallCounter");
//           } else {
//             _stallCounter = 0;
//           }

//           if (_stallCounter >= 3) {
//             print("🔴 STUCK (Frozen Frame). Attempting resume...");
//             _attemptResumeLiveStream();
//             _stallCounter = 0;
//           }
//         } else {
//           _stallCounter = 0;
//         }
//         _lastPositionCheck = currentPosition;
//       }
//     });
//   }

//   void _scrollToFocusedItem() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_focusedIndex < 0 ||
//           !_scrollController.hasClients ||
//           _focusedIndex >= focusNodes.length) {
//         return;
//       }
//       final context = focusNodes[_focusedIndex].context;
//       if (context == null) return;

//       Scrollable.ensureVisible(
//         context,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         alignment: 0.5,
//       );
//     });
//   }

//   Future<void> _onNetworkReconnected() async {
//     if (_controller == null || _currentModifiedUrl == null) return;

//     final fullUrl = _buildVlcUrl(_currentModifiedUrl!);
//     print("Reconnecting to: $fullUrl");

//     try {
//       if (widget.liveStatus == true) {
//         print("Live Stream Reconnection: Restarting stream...");
//         await _retryPlayback(fullUrl, 4);
//       } else {
//         print("VOD Reconnection: Attempting to resume from $_lastKnownPosition");

//         try {
//           await _controller!.pause();
//           await Future.delayed(const Duration(milliseconds: 100));

//           if (_lastKnownPosition != Duration.zero) {
//             await _seekToPosition(_lastKnownPosition);
//           } else {
//             await _controller!.play();
//           }
//           print("✅ VOD Resumed (Plan A) after reconnection.");
//         } catch (e) {
//           print("⚠️ Plan A failed. Falling back to Plan B (Reload). Error: $e");

//           await _retryPlayback(fullUrl, 4);

//           await Future.delayed(const Duration(seconds: 2));

//           if (_lastKnownPosition != Duration.zero) {
//             await _seekToPosition(_lastKnownPosition);
//           }
//           print("✅ VOD Resumed (Plan B) after reconnection.");
//         }
//       }
//     } catch (e) {
//       print("❌ Critical error during reconnection: $e");
//     }
//   }

//   Future<bool> _isInternetAvailable() async {
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } catch (_) {
//       return false;
//     }
//   }

//   String _buildVlcUrl(String baseUrl) {
//     final String networkCaching = "network-caching=60000";
//     final String liveCaching = "live-caching=30000";
//     final String fileCaching = "file-caching=20000";
//     final String rtspTcp = "rtsp-tcp";

//     if (widget.liveStatus == true) {
//       return '$baseUrl?$networkCaching&$liveCaching&$fileCaching&$rtspTcp';
//     } else {
//       return '$baseUrl?$networkCaching&$fileCaching&$rtspTcp';
//     }
//   }

//   bool _isSeeking = false;
//   Future<void> _seekToPosition(Duration position) async {
//     if (_isSeeking || _controller == null) return;
//     _isSeeking = true;
//     try {
//       print("Seeking to position: $position");
//       await _controller!.seekTo(position);
//       await _controller!.play();
//     } catch (e) {
//       print("Error during seek: $e");
//     } finally {
//       await Future.delayed(Duration(milliseconds: 500));
//       _isSeeking = false;
//     }
//   }

//   void _togglePlayPause() {
//     if (_controller != null && _controller!.value.isInitialized) {
//       if (_controller!.value.isPlaying) {
//         _controller!.pause();
//         setState(() {
//            _isUserPaused = true;
//         });
//       } else {
//         _controller!.play();
//         setState(() {
//            _isUserPaused = false;
//         });
//         _lastPlayingTime = DateTime.now();
//         _stallCounter = 0;
//       }
//     }
//     FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//     _resetHideControlsTimer();
//   }

//   void _resetHideControlsTimer() {
//     _hideControlsTimer.cancel();
//     if (!_controlsVisible) {
//       setState(() {
//         _controlsVisible = true;
//       });
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!mounted) return;
//         if (widget.liveStatus == false || widget.channelList.isEmpty) {
//           FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//         } else {
//           FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//           _scrollToFocusedItem();
//         }
//       });
//     }
//     _startHideControlsTimer();
//   }

//   void _startHideControlsTimer() {
//     _hideControlsTimer = Timer(Duration(seconds: 10), () {
//       if (mounted) {
//         setState(() {
//           _controlsVisible = false;
//         });
//       }
//     });
//   }

//   int _accumulatedSeekForward = 0;
//   int _accumulatedSeekBackward = 0;
//   Timer? _seekTimer;
//   Duration _previewPosition = Duration.zero;
//   final int _seekDuration = 5;
//   final int _seekDelay = 800;

//   void _seekForward() {
//     if (_controller == null ||
//         !_controller!.value.isInitialized ||
//         _controller!.value.duration <= Duration.zero) return;

//     _accumulatedSeekForward += _seekDuration;
//     final newPosition = _controller!.value.position +
//         Duration(seconds: _accumulatedSeekForward);

//     setState(() {
//       _previewPosition = newPosition > _controller!.value.duration
//           ? _controller!.value.duration
//           : newPosition;
//     });

//     _seekTimer?.cancel();
//     _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
//       _seekToPosition(_previewPosition).then((_) {
//         setState(() {
//           _accumulatedSeekForward = 0;
//         });
//       });
//     });
//   }

//   void _seekBackward() {
//     if (_controller == null ||
//         !_controller!.value.isInitialized ||
//         _controller!.value.duration <= Duration.zero) return;

//     _accumulatedSeekBackward += _seekDuration;
//     final newPosition = _controller!.value.position -
//         Duration(seconds: _accumulatedSeekBackward);

//     setState(() {
//       _previewPosition =
//           newPosition > Duration.zero ? newPosition : Duration.zero;
//     });

//     _seekTimer?.cancel();
//     _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
//       _seekToPosition(_previewPosition).then((_) {
//         setState(() {
//           _accumulatedSeekBackward = 0;
//         });
//       });
//     });
//   }

//   String _formatDuration(Duration duration) {
//     if (duration.isNegative) {
//       duration = Duration.zero;
//     }
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//   }

//   void _onScrubStart(DragStartDetails details, BoxConstraints constraints) {
//     if (_controller == null || _controller!.value.duration <= Duration.zero)
//       return;

//     _resetHideControlsTimer();
//     setState(() {
//       _isScrubbing = true;
//       _accumulatedSeekForward = 1;
//       final double progress =
//           (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
//       _previewPosition = _controller!.value.duration * progress;
//     });
//   }

//   void _onScrubUpdate(DragUpdateDetails details, BoxConstraints constraints) {
//     if (!_isScrubbing ||
//         _controller == null ||
//         _controller!.value.duration <= Duration.zero) return;

//     _resetHideControlsTimer();
//     final double progress =
//         (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
//     final newPosition = _controller!.value.duration * progress;
//     setState(() {
//       _previewPosition = newPosition;
//     });
//   }

//   void _onScrubEnd(DragEndDetails details) {
//     if (!_isScrubbing) return;

//     _seekToPosition(_previewPosition).then((_) {
//       setState(() {
//         _accumulatedSeekForward = 0;
//       });
//     });
//     _resetHideControlsTimer();
//     setState(() {
//       _isScrubbing = false;
//     });
//   }

//   void _showSubtitleMenu() {
//     _hideControlsTimer.cancel();

//     showDialog(
//       context: context,
//       builder: (context) {
//         final size = MediaQuery.of(context).size;
//         int focusedIndex = _spuTracks.keys.toList().indexOf(_currentSpuTrack) + 1;
//         if (_currentSpuTrack == -1) focusedIndex = 0;

//         final ScrollController dialogScrollController = ScrollController();
//         final List<MapEntry<int, String>> tracksList = _spuTracks.entries.toList();

//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return Align(
//               alignment: Alignment.bottomLeft,
//               child: Padding(
//                 padding: EdgeInsets.only(left: size.width * 0.03, bottom: size.height * 0.18),
//                 child: Material(
//                   color: Colors.transparent,
//                   child: Container(
//                     width: screenwdt * 0.35,
//                     height: size.height * 0.4,
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.9),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.white24, width: 1),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.5),
//                           blurRadius: 10,
//                           offset: const Offset(0, 4),
//                         ),
//                       ]
//                     ),
//                     child: Column(
//                       children: [
//                         const Padding(
//                           padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text(
//                               "Select Subtitle",
//                               style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
//                             ),
//                           ),
//                         ),
//                         const Divider(color: Colors.white24, height: 1),
//                         Expanded(
//                           child: _spuTracks.isEmpty
//                               ? const Padding(
//                                   padding: EdgeInsets.all(16.0),
//                                   child: Text("No subtitles available", style: TextStyle(color: Colors.white70)),
//                                 )
//                               : ListView.builder(
//                                   controller: dialogScrollController,
//                                   padding: EdgeInsets.zero,
//                                   itemCount: tracksList.length + 1,
//                                   itemBuilder: (context, index) {
//                                     final isOffOption = index == 0;
//                                     final trackId = isOffOption ? -1 : tracksList[index - 1].key;
//                                     final trackName = isOffOption ? "Off" : tracksList[index - 1].value;

//                                     final isSelected = _currentSpuTrack == trackId;
//                                     final isFocused = focusedIndex == index;

//                                     return Focus(
//                                       autofocus: isSelected,
//                                       onFocusChange: (hasFocus) {
//                                         if (hasFocus) {
//                                           setDialogState(() => focusedIndex = index);

//                                           // Mathematical scrolling to keep focused item visible
//                                           const double itemHeight = 48.0;
//                                           final double viewportHeight = (size.height * 0.4) - 48.0;
//                                           final double targetOffset = (itemHeight * index) - (viewportHeight / 2) + (itemHeight / 2);

//                                           final maxScroll = dialogScrollController.position.maxScrollExtent;
//                                           final double clampedOffset = targetOffset.clamp(0.0, maxScroll > 0 ? maxScroll : 0.0);

//                                           dialogScrollController.animateTo(
//                                             clampedOffset,
//                                             duration: const Duration(milliseconds: 200),
//                                             curve: Curves.easeInOut
//                                           );
//                                         }
//                                       },
//                                       onKey: (node, event) {
//                                         if (event is RawKeyDownEvent && (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
//                                           _controller?.setSpuTrack(trackId);
//                                           setState(() { _currentSpuTrack = trackId; });
//                                           Navigator.pop(context);
//                                           return KeyEventResult.handled;
//                                         }
//                                         return KeyEventResult.ignored;
//                                       },
//                                       child: GestureDetector(
//                                         onTap: () {
//                                           _controller?.setSpuTrack(trackId);
//                                           setState(() { _currentSpuTrack = trackId; });
//                                           Navigator.pop(context);
//                                         },
//                                         child: Container(
//                                           color: isFocused
//                                               ? Colors.purple.withOpacity(0.8)
//                                               : Colors.transparent,
//                                           height: 48.0,
//                                           child: Padding(
//                                             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                                             child: Row(
//                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                               children: [
//                                                 Text(trackName, style: const TextStyle(color: Colors.white, fontSize: 14)),
//                                                 if (isSelected) const Icon(Icons.check, color: Colors.white, size: 20),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }
//         );
//       }
//     ).then((_) {
//       FocusScope.of(context).requestFocus(subtitleButtonFocusNode);
//       _resetHideControlsTimer();
//     });
//   }

// //   String _getFormattedName(dynamic channel) {
// //   // Aapke API JSON mein 'channel_number' key hai
// //   String? cNo = channel.channelNumber?.toString();
// //   String name = channel.name ?? "";

// //   if (cNo != null && cNo.isNotEmpty) {
// //     return "$cNo. $name";
// //   }
// //   return name;
// // }

// // VideoScreen.dart ke andar helper method:

// String _getFormattedName(dynamic channel) {
//   // Check if it's NewsItemModel and has the number
//   String name = channel.name ?? "";

//   // Try-catch ya direct access agar aapne model update kar diya hai
//   String? cNo;
//   try {
//     cNo = channel.channelNumber?.toString();
//   } catch (e) {
//     cNo = null;
//   }

//   if (cNo != null && cNo.isNotEmpty) {
//     return "$cNo. $name";
//   }
//   return name;
// }

//   Widget _buildVideoPlayer() {
//     if (!_isVideoInitialized || _controller == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final screenWidth = constraints.maxWidth;
//         final screenHeight = constraints.maxHeight;

//         double videoWidth = _controller!.value.size.width;
//         double videoHeight = _controller!.value.size.height;

//         if (videoWidth <= 0 || videoHeight <= 0) {
//           videoWidth = 16.0;
//           videoHeight = 9.0;
//         }

//         final videoRatio = videoWidth / videoHeight;
//         final screenRatio = screenWidth / screenHeight;

//         double scaleX = 1.0;
//         double scaleY = 1.0;

//         if (videoRatio < screenRatio) {
//           scaleX = screenRatio / videoRatio;
//         } else {
//           scaleY = videoRatio / screenRatio;
//         }

//         const double maxScaleLimit = 1.35;

//         if (scaleX > maxScaleLimit) {
//           scaleX = maxScaleLimit;
//         }
//         if (scaleY > maxScaleLimit) {
//           scaleY = maxScaleLimit;
//         }

//         return Container(
//           width: screenWidth,
//           height: screenHeight,
//           color: Colors.black,
//           child: Center(
//             child: Transform.scale(
//               scaleX: scaleX,
//               scaleY: scaleY,
//               child: VlcPlayer(
//                 key: ValueKey(_currentModifiedUrl ?? widget.videoUrl),
//                 controller: _controller!,
//                 placeholder: const Center(child: CircularProgressIndicator()),
//                 aspectRatio: videoRatio,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: SizedBox(
//           width: screenwdt,
//           height: screenhgt,
//           child: Focus(
//             onKey: (node, event) {
//               if (event is RawKeyDownEvent) {
//                 bool isHandled = _handleKeyEvent(event);
//                 return isHandled ? KeyEventResult.handled : KeyEventResult.ignored;
//               }
//               return KeyEventResult.ignored;
//             },
//             child: GestureDetector(
//               onTap: _resetHideControlsTimer,
//               child: Stack(
//                 children: [
//                   if (_isVideoInitialized && _controller != null)
//                     _buildVideoPlayer(),
//                   if (_loadingVisible ||
//                       !_isVideoInitialized ||
//                       _isAttemptingResume ||
//                       (_isBuffering && !_loadingVisible))
//                     Container(
//                       color: _loadingVisible || !_isVideoInitialized
//                           ? Colors.black54
//                           : Colors.transparent,
//                       child: Center(
//                         child: RainbowPage(
//                           backgroundColor:
//                               _loadingVisible || !_isVideoInitialized
//                                   ? Colors.black
//                                   : Colors.transparent,
//                         ),
//                       ),
//                     ),
//                   if (_controlsVisible)
//                     Positioned(
//                       top: MediaQuery.of(context).size.height * 0.05,
//                       left: 0,
//                       right: 0,
//                       child: Center(
//                         child: ShaderMask(
//                           shaderCallback: (bounds) {
//                             return const LinearGradient(
//                               colors: [
//                                 Color(0xFF9B28F8),
//                                 Color(0xFFE62B1E),
//                                 Color.fromARGB(255, 53, 255, 53),
//                               ],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
//                           },
//                           child: Text(
//                             // widget.channelList.isNotEmpty
//                             //     ? (widget.channelList[_focusedIndex].name ?? widget.name)
//                             //     : widget.name,
//                             widget.channelList.isNotEmpty
//       // 🔥 UPDATE: Yahan formatted name dikhayein
//       ? _getFormattedName(widget.channelList[_focusedIndex])
//       : widget.name,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 34,
//                               fontWeight: FontWeight.w900,
//                               letterSpacing: 1.2,
//                               shadows: [
//                                 Shadow(
//                                   offset: Offset(0, 4),
//                                   blurRadius: 10.0,
//                                   color: Colors.black87,
//                                 ),
//                                 Shadow(
//                                   offset: Offset(0, 0),
//                                   blurRadius: 20.0,
//                                   color: Colors.black54,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   if (_controlsVisible && widget.channelList.isNotEmpty)
//                     _buildChannelList(),
//                   _buildControls(),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildChannelList() {
//     return Positioned(
//       top: MediaQuery.of(context).size.height * 0.02,
//       bottom: MediaQuery.of(context).size.height * 0.1,
//       left: screenwdt * 0.02,
//       right: MediaQuery.of(context).size.width * 0.82,
//       child: ListView.builder(
//         controller: _scrollController,
//         itemCount: widget.channelList.length,
//         itemBuilder: (context, index) {
//           final channel = widget.channelList[index];
//           final String channelId = channel.id?.toString() ?? '';
//           final bool isBase64 =
//               channel.banner?.startsWith('data:image') ?? false;
//           final bool isFocused = _focusedIndex == index;

//           return Padding(
//             padding:
//                 const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//             child: Focus(
//               focusNode: focusNodes[index],
//               autofocus: widget.liveStatus == true && isFocused,
//               onFocusChange: (hasFocus) {
//                 if (hasFocus) {
//                   print("✅ FOCUS GAINED: Channel at index $index");
//                   _scrollToFocusedItem();
//                 }
//               },
//               child: GestureDetector(
//                 onTap: () {
//                   _onItemTap(index);
//                   _resetHideControlsTimer();
//                 },
//                 child: Container(
//                   width: screenwdt * 0.18,
//                   height: screenhgt * 0.108,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: isFocused && !playPauseButtonFocusNode.hasFocus && !subtitleButtonFocusNode.hasFocus
//                           ? const Color.fromARGB(211, 155, 40, 248)
//                           : Colors.transparent,
//                       width: 5.0,
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                     color: isFocused ? Colors.black26 : Colors.transparent,
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(6),
//                     child: Stack(
//                       children: [
//                         Positioned.fill(
//                           child: Opacity(
//                             opacity: 0.6,
//                             child: isBase64
//                                 ? Image.memory(
//                                     _bannerCache[channelId] ??
//                                         _getCachedImage(
//                                             channel.banner ?? localImage),
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, e, s) =>
//                                         Image.asset('assets/placeholder.png'),
//                                   )
//                                 : CachedNetworkImage(
//                                     imageUrl: channel.banner ?? localImage,
//                                     fit: BoxFit.cover,
//                                     errorWidget: (context, url, error) =>
//                                         Image.asset('assets/placeholder.png'),
//                                   ),
//                           ),
//                         ),
//                         if (isFocused)
//                           Positioned.fill(
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                   colors: [
//                                     Colors.transparent,
//                                     Colors.black.withOpacity(0.9),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         if (isFocused)
//                           Positioned(
//                             left: 8,
//                             bottom: 8,
//                             right: 8,
//                             child: FittedBox(
//                               fit: BoxFit.scaleDown,
//                               alignment: Alignment.centerLeft,
//                               child: Text(
//                                 // channel.name ?? '',
//                                 _getFormattedName(channel),
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 maxLines: 1,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildControls() {
//     final Duration currentPosition = _accumulatedSeekForward > 0 ||
//             _accumulatedSeekBackward > 0 ||
//             _isScrubbing
//         ? _previewPosition
//         : _controller?.value.position ?? Duration.zero;
//     final Duration totalDuration = _controller?.value.duration ?? Duration.zero;

//     return Positioned(
//       bottom: 0,
//       left: 0,
//       right: 0,
//       child: Opacity(
//         opacity: _controlsVisible ? 1 : 0.0,
//         child: IgnorePointer(
//           ignoring: !_controlsVisible,
//           child: Container(
//             color: Colors.black54,
//             padding: const EdgeInsets.symmetric(vertical: 8.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SizedBox(width: screenwdt * 0.03),
//                     Container(
//                       color: playPauseButtonFocusNode.hasFocus
//                           ? const Color.fromARGB(200, 16, 62, 99)
//                           : Colors.transparent,
//                       child: Focus(
//                         focusNode: playPauseButtonFocusNode,
//                         autofocus: widget.liveStatus == false,
//                         onFocusChange: (hasFocus) {
//                           if (hasFocus) print("✅ FOCUS GAINED: Play/Pause Button");
//                           setState(() {});
//                         },
//                         child: IconButton(
//                           icon: Image.asset(
//                             (_controller?.value.isPlaying ?? false)
//                                 ? 'assets/pause.png'
//                                 : 'assets/play.png',
//                             width: 35,
//                             height: 35,
//                           ),
//                           onPressed: _togglePlayPause,
//                         ),
//                       ),
//                     ),
//                     if (widget.liveStatus == false)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                         child: Text(
//                           _formatDuration(currentPosition),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     Expanded(
//                       flex: 10,
//                       child: LayoutBuilder(
//                         builder: (context, constraints) {
//                           return GestureDetector(
//                             onHorizontalDragStart: (widget.liveStatus == false)
//                                 ? (details) => _onScrubStart(details, constraints)
//                                 : null,
//                             onHorizontalDragUpdate: (widget.liveStatus == false)
//                                 ? (details) => _onScrubUpdate(details, constraints)
//                                 : null,
//                             onHorizontalDragEnd: (widget.liveStatus == false)
//                                 ? (details) => _onScrubEnd(details)
//                                 : null,
//                             child: Container(
//                               color: Colors.transparent,
//                               child: _buildBeautifulProgressBar(
//                                   currentPosition, totalDuration),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     if (widget.liveStatus == false)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                         child: Text(
//                           _formatDuration(totalDuration),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     if (widget.liveStatus == true)
//                       Expanded(
//                         flex: 1,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: const [
//                             Icon(Icons.circle, color: Colors.red, size: 15),
//                             SizedBox(width: 5),
//                             Text(
//                               'Live',
//                               style: TextStyle(
//                                 color: Colors.red,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     SizedBox(width: screenwdt * 0.03),
//                   ],
//                 ),
//                 if (widget.liveStatus == false)
//                   Padding(
//                     padding: EdgeInsets.only(left: screenwdt * 0.03, top: 4.0),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: subtitleButtonFocusNode.hasFocus
//                             ? const Color.fromARGB(200, 16, 62, 99)
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(6),
//                         border: Border.all(
//                           color: subtitleButtonFocusNode.hasFocus ? Colors.purple : Colors.transparent,
//                           width: 2,
//                         ),
//                       ),
//                       child: Focus(
//                         focusNode: subtitleButtonFocusNode,
//                         onFocusChange: (hasFocus) {
//                           setState(() {});
//                         },
//                         child: InkWell(
//                           onTap: _showSubtitleMenu,
//                           child: const Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.subtitles, color: Colors.white, size: 22),
//                                 SizedBox(width: 8),
//                                 Text(
//                                   "Subtitles",
//                                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
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

//   Widget _buildBeautifulProgressBar(
//       Duration displayPosition, Duration totalDuration) {
//     final totalDurationMs = totalDuration.inMilliseconds.toDouble();

//     if (totalDurationMs <= 0 || widget.liveStatus == true) {
//       return Container(
//         padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//         child: Container(
//             height: 8,
//             decoration: BoxDecoration(
//                 color: Colors.grey[800],
//                 borderRadius: BorderRadius.circular(4))),
//       );
//     }

//     double playedProgress =
//         (displayPosition.inMilliseconds / totalDurationMs).clamp(0.0, 1.0);

//     double bufferedProgress = (playedProgress + 0.005).clamp(0.0, 1.0);

//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//       child: Container(
//         height: 8,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(4),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(4),
//           child: Stack(
//             children: [
//               Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.grey[800]!, Colors.grey[700]!],
//                   ),
//                 ),
//               ),
//               FractionallySizedBox(
//                 widthFactor: bufferedProgress,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.grey[600]!, Colors.grey[500]!],
//                     ),
//                   ),
//                 ),
//               ),
//               FractionallySizedBox(
//                 widthFactor: playedProgress,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [
//                         Color(0xFF9B28F8),
//                         Color(0xFFE62B1E),
//                         Color(0xFFFF6B35),
//                       ],
//                       stops: [0.0, 0.7, 1.0],
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFF9B28F8).withOpacity(0.6),
//                         blurRadius: 8,
//                         spreadRadius: 1,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }





// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:keep_screen_on/keep_screen_on.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
// import 'package:mobi_tv_entertainment/components/widgets/small_widgets/rainbow_page.dart';
// import 'package:mobi_tv_entertainment/main.dart';

// // class GlobalVariables {
// //   static String unUpdatedUrl = '';
// //   static Duration position = Duration.zero;
// //   static Duration duration = Duration.zero;
// //   static String banner = '';
// //   static String name = '';
// //   static bool liveStatus = false;
// // }

// // class RefreshPageEvent {
// //   final String pageId;
// //   RefreshPageEvent(this.pageId);
// // }

// class VideoScreen extends StatefulWidget {
//   final String videoUrl;
//   final String name;
//   final bool liveStatus;
//   final String updatedAt;
//   final List<dynamic> channelList;
//   final String bannerImageUrl;
//   final int? videoId;
//   final String source;

//   VideoScreen({
//     required this.videoUrl,
//     required this.updatedAt,
//     required this.channelList,
//     required this.bannerImageUrl,
//     required this.videoId,
//     required this.source,
//     required this.name,
//     required this.liveStatus,
//   });

//   @override
//   _VideoScreenState createState() => _VideoScreenState();
// }

// class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
//   VlcPlayerController? _controller;
//   bool _controlsVisible = true;
//   Timer? _hideControlsTimer;
//   bool _isBuffering = false;
//   bool _isVideoInitialized = false;
//   int _focusedIndex = 0;
//   List<FocusNode> focusNodes = [];
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode playPauseButtonFocusNode = FocusNode();

//   // --- SUBTITLE VARIABLES ---
//   final FocusNode subtitleButtonFocusNode = FocusNode();
//   Map<int, String> _spuTracks = {};
//   int _currentSpuTrack = -1;
//   bool _hasFetchedSubtitles = false;
//   // --------------------------

//   bool _loadingVisible = false;
//   Duration _lastKnownPosition = Duration.zero;
//   Timer? _networkCheckTimer;
//   bool _wasDisconnected = false;
//   String? _currentModifiedUrl;

//   bool _isAttemptingResume = false;
//   DateTime _lastPlayingTime = DateTime.now();
//   Duration _lastPositionCheck = Duration.zero;
//   int _stallCounter = 0;
//   bool _hasStartedPlaying = false;

//   bool _isScrubbing = false;
//   bool _isUserPaused = false;

//   Map<String, Uint8List> _bannerCache = {};

//   bool _isDisposing = false;

//   Uint8List _getCachedImage(String base64String) {
//     try {
//       if (!_bannerCache.containsKey(base64String)) {
//         if (_bannerCache.length >= 50) {
//           _bannerCache.remove(_bannerCache.keys.first);
//         }
//         _bannerCache[base64String] = base64Decode(base64String.split(',').last);
//       }
//       return _bannerCache[base64String]!;
//     } catch (e) {
//       print('Error processing image: $e');
//       return Uint8List.fromList([0, 0, 0, 0]);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     KeepScreenOn.turnOn();

//     _focusedIndex = widget.channelList.indexWhere(
//       (channel) => channel.id.toString() == widget.videoId.toString(),
//     );
//     _focusedIndex = (_focusedIndex >= 0) ? _focusedIndex : 0;

//     focusNodes = List.generate(
//       widget.channelList.length,
//       (index) => FocusNode(),
//     );

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusAndScrollToInitialItem();
//     });

//     _initPlayerWithSecureUrl();
//     _startHideControlsTimer();
//     _startNetworkMonitor();
//     _startPositionUpdater();
//   }

//   @override
// void didChangeAppLifecycleState(AppLifecycleState state) {
//   if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
//     _controller?.pause(); // Background mein video pause karein taaki crash na ho
//   } else if (state == AppLifecycleState.resumed) {
//     if (!_isUserPaused) _controller?.play();
//   }
// }

//   Future<void> _initializeVLCController(String baseUrl) async {
//     if (_isDisposing || !mounted) return;

//     print("--- Initializing Video Player ---");

//     setState(() {
//       _isVideoInitialized = false;
//       _loadingVisible = true;
//     });

//     try {
//       if (_controller != null) {
//         _controller!.removeListener(_vlcListener);
//         await _controller!.stop();
//         await _controller!.dispose();
//         _controller = null;
//         print("Cleanup: Previous controller disposed successfully.");
//       }
//     } catch (e) {
//       print("Cleanup Warning: Error disposing old controller: $e");
//     }

//     try {
//       _currentModifiedUrl = baseUrl;
//       final String fullVlcUrl = _buildVlcUrl(baseUrl);

//       _lastPlayingTime = DateTime.now();
//       _lastPositionCheck = Duration.zero;
//       _stallCounter = 0;
//       _hasStartedPlaying = false;
//       _hasFetchedSubtitles = false;

//       print("Source: $fullVlcUrl");

//       _controller = VlcPlayerController.network(
//         fullVlcUrl,
//         hwAcc: HwAcc.auto,
//         options: VlcPlayerOptions(
//           video: VlcVideoOptions([
//             VlcVideoOptions.dropLateFrames(true),
//             VlcVideoOptions.skipFrames(true),
//           ]),
//         ),
//       );

//       await _retryPlayback(fullVlcUrl, 3);

//       if (_controller != null && mounted) {
//         _controller!.addListener(_vlcListener);
//         setState(() {
//           _isVideoInitialized = true;
//         });
//         print("Status: Video Initialized successfully.");
//       }
//     } catch (e) {
//       print("Error: Initialization failed: $e");
//       if (mounted) setState(() => _loadingVisible = false);
//     }
//   }

//   Future<void> _retryPlayback(String url, int retries) async {
//     for (int i = 0; i < retries; i++) {
//       if (!mounted || _controller == null) return;
//       try {
//         print("Playback Attempt ${i + 1}/$retries");
//         await _controller!.setMediaFromNetwork(url);
//         await _controller!.play();
//         return;
//       } catch (e) {
//         print("Playback Attempt ${i + 1} failed: $e");
//         if (i < retries - 1) {
//           await Future.delayed(const Duration(seconds: 1));
//         }
//       }
//     }
//   }

//   Future<void> _onItemTap(int index) async {
//     if (!mounted || _isDisposing) return;

//     setState(() {
//       _loadingVisible = true;
//       _focusedIndex = index;
//     });

//     try {
//       var selectedChannel = widget.channelList[index];
//       print("Switching to Channel: ${selectedChannel.name}");

//       String secureUrl = await SecureUrlService.getSecureUrl(
//           selectedChannel.url.toString(),
//           expirySeconds: 10);

//       if (!mounted || _isDisposing) return;

//       await _initializeVLCController(secureUrl);

//       _scrollToFocusedItem();
//       _resetHideControlsTimer();
//     } catch (e) {
//       print("Error: Failed to switch channel: $e");
//       if (mounted) setState(() => _loadingVisible = false);
//     }
//   }

//   void _startNetworkMonitor() {
//     _networkCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
//       bool isConnected = await _isInternetAvailable();
//       if (!isConnected && !_wasDisconnected) {
//         _wasDisconnected = true;
//         print("Network: Connection lost.");
//       } else if (isConnected && _wasDisconnected) {
//         _wasDisconnected = false;
//         print("Network: Connection restored. Resuming playback...");
//         if (_controller?.value.isInitialized ?? false) {
//           _onNetworkReconnected();
//         }
//       }
//     });
//   }

//   Future<void> _attemptResumeLiveStream() async {
//     if (!mounted || _isAttemptingResume || _controller == null || widget.liveStatus == false) {
//       return;
//     }

//     setState(() {
//       _isAttemptingResume = true;
//       _loadingVisible = true;
//     });

//     print("Stability: Live stream stall detected. Attempting recovery with NEW TOKEN...");

//     try {
//       String newSecureUrl = widget.videoUrl;
//       try {
//          newSecureUrl = await SecureUrlService.getSecureUrl(
//             widget.videoUrl,
//             expirySeconds: 10
//          );
//       } catch(e) {
//          print("Token refresh failed, using original: $e");
//       }

//       _currentModifiedUrl = newSecureUrl;

//       final urlToResume = _buildVlcUrl(newSecureUrl);

//       await _retryPlayback(urlToResume, 4);

//       _lastPlayingTime = DateTime.now();
//       _stallCounter = 0;

//       _isUserPaused = false;

//       print("Stability: Recovery process finished.");
//     } catch (e) {
//       print("Error: Recovery failed: $e");
//     } finally {
//       if (mounted) {
//         setState(() => _isAttemptingResume = false);
//       }
//     }
//   }

//   Future<void> _safeDispose() async {
//     if (_isDisposing) return;

//     _isDisposing = true;
//     print("🔄 Safe disposal started...");

//     _hideControlsTimer?.cancel();
//     _networkCheckTimer?.cancel();
//     _seekTimer?.cancel();

//     focusNodes.forEach((node) => node.dispose());
//     playPauseButtonFocusNode.dispose();
//     subtitleButtonFocusNode.dispose();
//     _scrollController.dispose();

//     try {
//       if (_controller != null) {
//         _controller?.removeListener(_vlcListener);
//         await _controller?.stop();
//         await _controller?.dispose();
//         _controller = null;
//         print("✅ VLC Controller safely disposed");
//       }
//     } catch (e) {
//       print("⚠️ Warning during VLC controller disposal: $e");
//     }

//     KeepScreenOn.turnOff();
//     WidgetsBinding.instance.removeObserver(this);

//     print("✅ Safe disposal completed");
//   }

//   @override
//   void dispose() {
//     print("🗑️ VideoScreen dispose called");
//     _safeDispose();
//     super.dispose();
//   }

//   Future<bool> _onWillPop() async {
//     print("🚨 SYSTEM BACK BUTTON DETECTED 🚨");

//     _safeDispose();

//     if (mounted) {
//       Navigator.of(context).pop();
//     }

//     return true;
//   }

//   void _focusAndScrollToInitialItem() {
//     if (!mounted || focusNodes.isEmpty || _focusedIndex < 0 || _focusedIndex >= focusNodes.length) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//          if (mounted) FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//       });
//       return;
//     }

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!_scrollController.hasClients) return;

//       final double itemHeight = (screenhgt * 0.108) + 16.0;
//       final double viewportHeight = MediaQuery.of(context).size.height * 0.88;
//       final double targetOffset = (itemHeight * _focusedIndex) - (viewportHeight / 2) + (itemHeight / 2);

//       final double clampedOffset = targetOffset.clamp(
//         _scrollController.position.minScrollExtent,
//         _scrollController.position.maxScrollExtent,
//       );
//       _scrollController.jumpTo(clampedOffset);

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!mounted) return;
//         if (widget.liveStatus == false) {
//           FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//         } else if (widget.channelList.isNotEmpty &&
//             _focusedIndex < focusNodes.length) {
//           FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//         } else {
//           FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//         }
//       });
//     });
//   }

//   void _changeFocusAndScroll(int newIndex) {
//     if (newIndex < 0 || newIndex >= widget.channelList.length) {
//       return;
//     }

//     setState(() {
//       _focusedIndex = newIndex;
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!_scrollController.hasClients || !mounted) return;

//       final double itemHeight = (screenhgt * 0.108) + 16.0;
//       final double viewportHeight = MediaQuery.of(context).size.height * 0.88;
//       final double targetOffset = (itemHeight * _focusedIndex) - (viewportHeight / 2) + (itemHeight / 2);

//       final double clampedOffset = targetOffset.clamp(
//         _scrollController.position.minScrollExtent,
//         _scrollController.position.maxScrollExtent,
//       );
//       _scrollController.jumpTo(clampedOffset);

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//         }
//       });
//     });
//   }

//   Future<void> _initPlayerWithSecureUrl() async {
//     try {
//       String secureUrl = await SecureUrlService.getSecureUrl(widget.videoUrl,
//           expirySeconds: 10);
//       print('Initializing secureUrl: $secureUrl');
//       if (!mounted) return;

//       _initializeVLCController(secureUrl);
//     } catch (e) {
//       print("Secure URL error: $e");
//       await _initializeVLCController(widget.videoUrl);
//     }
//   }

//   bool _handleKeyEvent(RawKeyEvent event) {
//     print("📺 REMOTE KEY PRESSED: ${event.logicalKey.keyLabel} (ID: ${event.logicalKey.keyId})");
//     if (event is RawKeyDownEvent) {
//       _resetHideControlsTimer();

//       switch (event.logicalKey) {
//         case LogicalKeyboardKey.escape:
//         case LogicalKeyboardKey.browserBack:
//           print("🔙 TV Remote Back Button explicitly caught!");
//           _safeDispose();
//           Navigator.maybePop(context);
//           return true;

//         case LogicalKeyboardKey.arrowUp:
//           if (subtitleButtonFocusNode.hasFocus) {
//             FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//             return true;
//           }
//           if (playPauseButtonFocusNode.hasFocus) {
//             if (widget.liveStatus == false && widget.channelList.isNotEmpty) {
//               FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//             }
//           } else if (_focusedIndex > 0) {
//             _changeFocusAndScroll(_focusedIndex - 1);
//           }
//           return true;

//         case LogicalKeyboardKey.arrowDown:
//           if (playPauseButtonFocusNode.hasFocus && widget.liveStatus == false) {
//             FocusScope.of(context).requestFocus(subtitleButtonFocusNode);
//             return true;
//           }
//           if (_focusedIndex < widget.channelList.length - 1) {
//             _changeFocusAndScroll(_focusedIndex + 1);
//           }
//           return true;

//         case LogicalKeyboardKey.arrowRight:
//           if (widget.liveStatus == false) {
//             _seekForward();
//           }
//           return true;

//         case LogicalKeyboardKey.arrowLeft:
//           if (widget.liveStatus == false) {
//             _seekBackward();
//           }
//           if (playPauseButtonFocusNode.hasFocus &&
//               widget.channelList.isNotEmpty) {
//             FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//           }
//           return true;

//         case LogicalKeyboardKey.select:
//         case LogicalKeyboardKey.enter:
//           if (subtitleButtonFocusNode.hasFocus) {
//             _showSubtitleMenu();
//             return true;
//           }
//           if (widget.liveStatus == false) {
//             _togglePlayPause();
//           } else {
//             if (playPauseButtonFocusNode.hasFocus ||
//                 widget.channelList.isEmpty) {
//               _togglePlayPause();
//             } else {
//               _onItemTap(_focusedIndex);
//             }
//           }
//           return true;

//         default:
//           return false;
//       }
//     }
//     return false;
//   }

//   Future<void> _fetchSubtitles() async {
//     if (_controller != null && _controller!.value.isInitialized) {
//       final tracks = await _controller!.getSpuTracks();
//       final current = await _controller!.getSpuTrack() ?? -1;
//       if (mounted) {
//         setState(() {
//           _spuTracks = tracks;
//           _currentSpuTrack = current;
//           _hasFetchedSubtitles = true;
//         });
//       }
//     }
//   }

//   void _vlcListener() {
//     if (!mounted || _controller == null || !_controller!.value.isInitialized)
//       return;

//     final VlcPlayerValue value = _controller!.value;
//     final bool isBuffering = value.isBuffering;
//     final PlayingState playingState = value.playingState;

//     if (widget.liveStatus == true && !_isAttemptingResume) {
//       if (playingState == PlayingState.playing) {
//         _lastPlayingTime = DateTime.now();
//         if (!_hasStartedPlaying) {
//           _hasStartedPlaying = true;
//         }
//         if (!_hasFetchedSubtitles) {
//           _fetchSubtitles();
//         }
//       } else if (playingState == PlayingState.buffering && _hasStartedPlaying) {
//         final stalledDuration = DateTime.now().difference(_lastPlayingTime);
//         if (stalledDuration > Duration(seconds: 8)) {
//           print(
//               "⚠️ Stall (Listener): Buffering for ${stalledDuration.inSeconds} sec.");
//           _attemptResumeLiveStream();
//           _lastPlayingTime = DateTime.now();
//         }
//       } else if (playingState == PlayingState.error) {
//         print("⚠️ Stall (Listener): Player in error state.");
//         _attemptResumeLiveStream();
//         _lastPlayingTime = DateTime.now();
//       } else if ((playingState == PlayingState.stopped ||
//               playingState == PlayingState.ended) &&
//           _hasStartedPlaying) {
//         final stalledDuration = DateTime.now().difference(_lastPlayingTime);
//         if (stalledDuration > Duration(seconds: 5)) {
//           print("⚠️ Stall (Listener): Player stopped unexpectedly.");
//           _attemptResumeLiveStream();
//           _lastPlayingTime = DateTime.now();
//         }
//       }
//     } else if (playingState == PlayingState.paused) {
//       if (_isUserPaused) {
//         _lastPlayingTime = DateTime.now();
//       } else {
//         final stalledDuration = DateTime.now().difference(_lastPlayingTime);
//         if (stalledDuration > Duration(seconds: 5)) {
//           print("⚠️ Auto-Pause detected (Network issue). Force restarting...");
//           _attemptResumeLiveStream();
//           _lastPlayingTime = DateTime.now();
//         }
//       }
//     } else if (playingState == PlayingState.playing && widget.liveStatus == false) {
//       if (!_hasFetchedSubtitles) {
//         _fetchSubtitles();
//       }
//     }

//     if (mounted) {
//       setState(() {
//         _isBuffering = isBuffering;

//         if (playingState == PlayingState.playing && !isBuffering) {
//           _loadingVisible = false;
//         } else if (playingState == PlayingState.buffering ||
//             playingState == PlayingState.initializing) {
//           _loadingVisible = true;
//         }

//         if (_isAttemptingResume) {
//           _loadingVisible = true;
//         }
//       });
//     }
//   }

//   void _startPositionUpdater() {
//     Timer.periodic(Duration(seconds: 2), (_) {
//       if (!mounted ||
//           _controller == null ||
//           !_controller!.value.isInitialized) {
//         return;
//       }

//       final VlcPlayerValue value = _controller!.value;
//       final Duration currentPosition = value.position;

//       if (mounted && !_isScrubbing) {
//         setState(() {
//           _lastKnownPosition = currentPosition;
//         });
//       }

//       if (widget.liveStatus == true &&
//           !_isAttemptingResume &&
//           _hasStartedPlaying) {
//         if (value.playingState == PlayingState.playing) {
//           if (_lastPositionCheck != Duration.zero &&
//               currentPosition == _lastPositionCheck) {
//             _stallCounter++;
//             print(
//                 "⚠️ Position stuck (Frozen Frame). Counter: $_stallCounter");
//           } else {
//             _stallCounter = 0;
//           }

//           if (_stallCounter >= 3) {
//             print("🔴 STUCK (Frozen Frame). Attempting resume...");
//             _attemptResumeLiveStream();
//             _stallCounter = 0;
//           }
//         } else {
//           _stallCounter = 0;
//         }
//         _lastPositionCheck = currentPosition;
//       }
//     });
//   }

//   void _scrollToFocusedItem() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_focusedIndex < 0 ||
//           !_scrollController.hasClients ||
//           _focusedIndex >= focusNodes.length) {
//         return;
//       }
//       final context = focusNodes[_focusedIndex].context;
//       if (context == null) return;

//       Scrollable.ensureVisible(
//         context,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         alignment: 0.5,
//       );
//     });
//   }

//   Future<void> _onNetworkReconnected() async {
//     if (_controller == null || _currentModifiedUrl == null) return;

//     final fullUrl = _buildVlcUrl(_currentModifiedUrl!);
//     print("Reconnecting to: $fullUrl");

//     try {
//       if (widget.liveStatus == true) {
//         print("Live Stream Reconnection: Restarting stream...");
//         await _retryPlayback(fullUrl, 4);
//       } else {
//         print("VOD Reconnection: Attempting to resume from $_lastKnownPosition");

//         try {
//           await _controller!.pause();
//           await Future.delayed(const Duration(milliseconds: 100));

//           if (_lastKnownPosition != Duration.zero) {
//             await _seekToPosition(_lastKnownPosition);
//           } else {
//             await _controller!.play();
//           }
//           print("✅ VOD Resumed (Plan A) after reconnection.");
//         } catch (e) {
//           print("⚠️ Plan A failed. Falling back to Plan B (Reload). Error: $e");

//           await _retryPlayback(fullUrl, 4);

//           await Future.delayed(const Duration(seconds: 2));

//           if (_lastKnownPosition != Duration.zero) {
//             await _seekToPosition(_lastKnownPosition);
//           }
//           print("✅ VOD Resumed (Plan B) after reconnection.");
//         }
//       }
//     } catch (e) {
//       print("❌ Critical error during reconnection: $e");
//     }
//   }

//   Future<bool> _isInternetAvailable() async {
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } catch (_) {
//       return false;
//     }
//   }

//   String _buildVlcUrl(String baseUrl) {
//     final String networkCaching = "network-caching=60000";
//     final String liveCaching = "live-caching=30000";
//     final String fileCaching = "file-caching=20000";
//     final String rtspTcp = "rtsp-tcp";

//     if (widget.liveStatus == true) {
//       return '$baseUrl?$networkCaching&$liveCaching&$fileCaching&$rtspTcp';
//     } else {
//       return '$baseUrl?$networkCaching&$fileCaching&$rtspTcp';
//     }
//   }

//   bool _isSeeking = false;
//   Future<void> _seekToPosition(Duration position) async {
//     if (_isSeeking || _controller == null) return;
//     _isSeeking = true;
//     try {
//       print("Seeking to position: $position");
//       await _controller!.seekTo(position);
//       await _controller!.play();
//     } catch (e) {
//       print("Error during seek: $e");
//     } finally {
//       await Future.delayed(Duration(milliseconds: 500));
//       _isSeeking = false;
//     }
//   }

//   void _togglePlayPause() {
//     if (_controller == null || !_controller!.value.isInitialized) return;

//     try {
//       if (_controller!.value.isPlaying) {
//         _controller!.pause();
//         setState(() {
//            _isUserPaused = true;
//         });
//       } else {
//         _controller!.play();
//         setState(() {
//            _isUserPaused = false;
//         });
//         _lastPlayingTime = DateTime.now();
//         _stallCounter = 0;
//       }
//     } catch (e) {
//       print("Playback toggle error: $e");
//     }

//     FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//     _resetHideControlsTimer();
//   }

//   void _resetHideControlsTimer() {
//     _hideControlsTimer?.cancel();
//     if (!_controlsVisible) {
//       setState(() {
//         _controlsVisible = true;
//       });
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!mounted) return;
//         if (widget.liveStatus == false || widget.channelList.isEmpty) {
//           FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//         } else {
//           FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//           _scrollToFocusedItem();
//         }
//       });
//     }
//     _startHideControlsTimer();
//   }

//   void _startHideControlsTimer() {
//     _hideControlsTimer = Timer(Duration(seconds: 10), () {
//       if (mounted) {
//         setState(() {
//           _controlsVisible = false;
//         });
//       }
//     });
//   }

//   int _accumulatedSeekForward = 0;
//   int _accumulatedSeekBackward = 0;
//   Timer? _seekTimer;
//   Duration _previewPosition = Duration.zero;
//   final int _seekDuration = 5;
//   final int _seekDelay = 800;

//   void _seekForward() {
//     if (_controller == null ||
//         !_controller!.value.isInitialized ||
//         _controller!.value.duration <= Duration.zero) return;

//     _accumulatedSeekForward += _seekDuration;
//     final newPosition = _controller!.value.position +
//         Duration(seconds: _accumulatedSeekForward);

//     setState(() {
//       _previewPosition = newPosition > _controller!.value.duration
//           ? _controller!.value.duration
//           : newPosition;
//     });

//     _seekTimer?.cancel();
//     _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
//       _seekToPosition(_previewPosition).then((_) {
//         setState(() {
//           _accumulatedSeekForward = 0;
//         });
//       });
//     });
//   }

//   void _seekBackward() {
//     if (_controller == null ||
//         !_controller!.value.isInitialized ||
//         _controller!.value.duration <= Duration.zero) return;

//     _accumulatedSeekBackward += _seekDuration;
//     final newPosition = _controller!.value.position -
//         Duration(seconds: _accumulatedSeekBackward);

//     setState(() {
//       _previewPosition =
//           newPosition > Duration.zero ? newPosition : Duration.zero;
//     });

//     _seekTimer?.cancel();
//     _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
//       _seekToPosition(_previewPosition).then((_) {
//         setState(() {
//           _accumulatedSeekBackward = 0;
//         });
//       });
//     });
//   }

//   String _formatDuration(Duration duration) {
//     if (duration.isNegative) {
//       duration = Duration.zero;
//     }
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//   }

//   void _onScrubStart(DragStartDetails details, BoxConstraints constraints) {
//     if (_controller == null || _controller!.value.duration <= Duration.zero)
//       return;

//     _resetHideControlsTimer();
//     setState(() {
//       _isScrubbing = true;
//       _accumulatedSeekForward = 1;
//       final double progress =
//           (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
//       _previewPosition = _controller!.value.duration * progress;
//     });
//   }

//   void _onScrubUpdate(DragUpdateDetails details, BoxConstraints constraints) {
//     if (!_isScrubbing ||
//         _controller == null ||
//         _controller!.value.duration <= Duration.zero) return;

//     _resetHideControlsTimer();
//     final double progress =
//         (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
//     final newPosition = _controller!.value.duration * progress;
//     setState(() {
//       _previewPosition = newPosition;
//     });
//   }

//   void _onScrubEnd(DragEndDetails details) {
//     if (!_isScrubbing) return;

//     _seekToPosition(_previewPosition).then((_) {
//       setState(() {
//         _accumulatedSeekForward = 0;
//       });
//     });
//     _resetHideControlsTimer();
//     setState(() {
//       _isScrubbing = false;
//     });
//   }

//   void _showSubtitleMenu() {
//     _hideControlsTimer?.cancel();

//     showDialog(
//       context: context,
//       builder: (context) {
//         final size = MediaQuery.of(context).size;
//         int focusedIndex = _spuTracks.keys.toList().indexOf(_currentSpuTrack) + 1;
//         if (_currentSpuTrack == -1) focusedIndex = 0;

//         final ScrollController dialogScrollController = ScrollController();
//         final List<MapEntry<int, String>> tracksList = _spuTracks.entries.toList();

//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return Align(
//               alignment: Alignment.bottomLeft,
//               child: Padding(
//                 padding: EdgeInsets.only(left: size.width * 0.03, bottom: size.height * 0.18),
//                 child: Material(
//                   color: Colors.transparent,
//                   child: Container(
//                     width: screenwdt * 0.35,
//                     height: size.height * 0.4,
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.9),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.white24, width: 1),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.5),
//                           blurRadius: 10,
//                           offset: const Offset(0, 4),
//                         ),
//                       ]
//                     ),
//                     child: Column(
//                       children: [
//                         const Padding(
//                           padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text(
//                               "Select Subtitle",
//                               style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
//                             ),
//                           ),
//                         ),
//                         const Divider(color: Colors.white24, height: 1),
//                         Expanded(
//                           child: _spuTracks.isEmpty
//                               ? const Padding(
//                                   padding: EdgeInsets.all(16.0),
//                                   child: Text("No subtitles available", style: TextStyle(color: Colors.white70)),
//                                 )
//                               : ListView.builder(
//                                   controller: dialogScrollController,
//                                   padding: EdgeInsets.zero,
//                                   itemCount: tracksList.length + 1,
//                                   itemBuilder: (context, index) {
//                                     final isOffOption = index == 0;
//                                     final trackId = isOffOption ? -1 : tracksList[index - 1].key;
//                                     final trackName = isOffOption ? "Off" : tracksList[index - 1].value;

//                                     final isSelected = _currentSpuTrack == trackId;
//                                     final isFocused = focusedIndex == index;

//                                     return Focus(
//                                       autofocus: isSelected,
//                                       onFocusChange: (hasFocus) {
//                                         if (hasFocus) {
//                                           setDialogState(() => focusedIndex = index);

//                                           const double itemHeight = 48.0;
//                                           final double viewportHeight = (size.height * 0.4) - 48.0;
//                                           final double targetOffset = (itemHeight * index) - (viewportHeight / 2) + (itemHeight / 2);

//                                           final maxScroll = dialogScrollController.position.maxScrollExtent;
//                                           final double clampedOffset = targetOffset.clamp(0.0, maxScroll > 0 ? maxScroll : 0.0);

//                                           dialogScrollController.animateTo(
//                                             clampedOffset,
//                                             duration: const Duration(milliseconds: 200),
//                                             curve: Curves.easeInOut
//                                           );
//                                         }
//                                       },
//                                       onKey: (node, event) {
//                                         if (event is RawKeyDownEvent && (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
//                                           _controller?.setSpuTrack(trackId);
//                                           setState(() { _currentSpuTrack = trackId; });
//                                           Navigator.pop(context);
//                                           return KeyEventResult.handled;
//                                         }
//                                         return KeyEventResult.ignored;
//                                       },
//                                       child: GestureDetector(
//                                         onTap: () {
//                                           _controller?.setSpuTrack(trackId);
//                                           setState(() { _currentSpuTrack = trackId; });
//                                           Navigator.pop(context);
//                                         },
//                                         child: Container(
//                                           color: isFocused
//                                               ? Colors.purple.withOpacity(0.8)
//                                               : Colors.transparent,
//                                           height: 48.0,
//                                           child: Padding(
//                                             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                                             child: Row(
//                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                               children: [
//                                                 Text(trackName, style: const TextStyle(color: Colors.white, fontSize: 14)),
//                                                 if (isSelected) const Icon(Icons.check, color: Colors.white, size: 20),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }
//         );
//       }
//     ).then((_) {
//       FocusScope.of(context).requestFocus(subtitleButtonFocusNode);
//       _resetHideControlsTimer();
//     });
//   }

//   // --- FULLY ROBUST CHANNEL NUMBER PARSER ---
//   String _getFormattedName(dynamic channel) {
//     String name = "";
//     try {
//       name = channel.name?.toString() ?? "";
//     } catch (_) {
//       try {
//         name = channel['name']?.toString() ?? "";
//       } catch (_) {}
//     }

//     String? cNo;

//     try {
//       cNo = channel.channel_number?.toString();
//     } catch (_) {
//       try {
//         cNo = channel.channelNumber?.toString();
//       } catch (_) {
//         try {
//           cNo = channel['channel_number']?.toString() ?? channel['channelNumber']?.toString();
//         } catch (_) {
//           cNo = null;
//         }
//       }
//     }

//     if (cNo != null && cNo.trim().isNotEmpty && cNo != "null") {
//       return "${cNo.trim()}. $name";
//     }

//     return name;
//   }
//   // ------------------------------------------

//   Widget _buildVideoPlayer() {
//     if (!_isVideoInitialized || _controller == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final screenWidth = constraints.maxWidth;
//         final screenHeight = constraints.maxHeight;

//         double videoWidth = _controller!.value.size.width;
//         double videoHeight = _controller!.value.size.height;

//         if (videoWidth <= 0 || videoHeight <= 0) {
//           videoWidth = 16.0;
//           videoHeight = 9.0;
//         }

//         final videoRatio = videoWidth / videoHeight;
//         final screenRatio = screenWidth / screenHeight;

//         double scaleX = 1.0;
//         double scaleY = 1.0;

//         if (videoRatio < screenRatio) {
//           scaleX = screenRatio / videoRatio;
//         } else {
//           scaleY = videoRatio / screenRatio;
//         }

//         const double maxScaleLimit = 1.35;

//         if (scaleX > maxScaleLimit) {
//           scaleX = maxScaleLimit;
//         }
//         if (scaleY > maxScaleLimit) {
//           scaleY = maxScaleLimit;
//         }

//         return Container(
//           width: screenWidth,
//           height: screenHeight,
//           color: Colors.black,
//           child: Center(
//             child: Transform.scale(
//               scaleX: scaleX,
//               scaleY: scaleY,
//               child: VlcPlayer(
//                 key: ValueKey(_currentModifiedUrl ?? widget.videoUrl),
//                 controller: _controller!,
//                 placeholder: const Center(child: CircularProgressIndicator()),
//                 aspectRatio: videoRatio,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: SizedBox(
//           width: screenwdt,
//           height: screenhgt,
//           child: Focus(
//             onKey: (node, event) {
//               if (event is RawKeyDownEvent) {
//                 bool isHandled = _handleKeyEvent(event);
//                 return isHandled ? KeyEventResult.handled : KeyEventResult.ignored;
//               }
//               return KeyEventResult.ignored;
//             },
//             child: GestureDetector(
//               onTap: _resetHideControlsTimer,
//               child: Stack(
//                 children: [
//                   if (_isVideoInitialized && _controller != null)
//                     _buildVideoPlayer(),
//                   if (_loadingVisible ||
//                       !_isVideoInitialized ||
//                       _isAttemptingResume ||
//                       (_isBuffering && !_loadingVisible))
//                     Container(
//                       color: _loadingVisible || !_isVideoInitialized
//                           ? Colors.black54
//                           : Colors.transparent,
//                       child: Center(
//                         child: RainbowPage(
//                           backgroundColor:
//                               _loadingVisible || !_isVideoInitialized
//                                   ? Colors.black
//                                   : Colors.transparent,
//                         ),
//                       ),
//                     ),
//                   if (_controlsVisible)
//                     Positioned(
//                       top: MediaQuery.of(context).size.height * 0.05,
//                       left: 0,
//                       right: 0,
//                       child: Center(
//                         child: ShaderMask(
//                           shaderCallback: (bounds) {
//                             return const LinearGradient(
//                               colors: [
//                                 Color(0xFF9B28F8),
//                                 Color(0xFFE62B1E),
//                                 Color.fromARGB(255, 53, 255, 53),
//                               ],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
//                           },
//                           child: Text(
//                             (widget.channelList.isNotEmpty && _focusedIndex >= 0 && _focusedIndex < widget.channelList.length)
//                               ? _getFormattedName(widget.channelList[_focusedIndex])
//                               : widget.name,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 34,
//                               fontWeight: FontWeight.w900,
//                               letterSpacing: 1.2,
//                               shadows: [
//                                 Shadow(
//                                   offset: Offset(0, 4),
//                                   blurRadius: 10.0,
//                                   color: Colors.black87,
//                                 ),
//                                 Shadow(
//                                   offset: Offset(0, 0),
//                                   blurRadius: 20.0,
//                                   color: Colors.black54,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   if (_controlsVisible && widget.channelList.isNotEmpty)
//                     _buildChannelList(),
//                   _buildControls(),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildChannelList() {
//     return Positioned(
//       top: MediaQuery.of(context).size.height * 0.02,
//       bottom: MediaQuery.of(context).size.height * 0.1,
//       left: screenwdt * 0.02,
//       right: MediaQuery.of(context).size.width * 0.82,
//       child: ListView.builder(
//         controller: _scrollController,
//         itemCount: widget.channelList.length,
//         itemBuilder: (context, index) {
//           final channel = widget.channelList[index];
//           final String channelId = channel.id?.toString() ?? '';
//           final bool isBase64 =
//               channel.banner?.startsWith('data:image') ?? false;
//           final bool isFocused = _focusedIndex == index;

//           return Padding(
//             padding:
//                 const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//             child: Focus(
//               focusNode: focusNodes[index],
//               autofocus: widget.liveStatus == true && isFocused,
//               onFocusChange: (hasFocus) {
//                 if (hasFocus) {
//                   print("✅ FOCUS GAINED: Channel at index $index");
//                   _scrollToFocusedItem();
//                 }
//               },
//               child: GestureDetector(
//                 onTap: () {
//                   _onItemTap(index);
//                   _resetHideControlsTimer();
//                 },
//                 child: Container(
//                   width: screenwdt * 0.18,
//                   height: screenhgt * 0.108,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: isFocused && !playPauseButtonFocusNode.hasFocus && !subtitleButtonFocusNode.hasFocus
//                           ? const Color.fromARGB(211, 155, 40, 248)
//                           : Colors.transparent,
//                       width: 5.0,
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                     color: isFocused ? Colors.black26 : Colors.transparent,
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(6),
//                     child: Stack(
//                       children: [
//                         Positioned.fill(
//                           child: Opacity(
//                             opacity: 0.6,
//                             child: isBase64
//                                 ? Image.memory(
//                                     _bannerCache[channelId] ??
//                                         _getCachedImage(
//                                             channel.banner ?? localImage),
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, e, s) =>
//                                         Image.asset('assets/placeholder.png'),
//                                   )
//                                 : CachedNetworkImage(
//                                     imageUrl: channel.banner ?? localImage,
//                                     fit: BoxFit.cover,
//                                     errorWidget: (context, url, error) =>
//                                         Image.asset('assets/placeholder.png'),
//                                   ),
//                           ),
//                         ),
//                         if (isFocused)
//                           Positioned.fill(
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                   colors: [
//                                     Colors.transparent,
//                                     Colors.black.withOpacity(0.9),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         if (isFocused)
//                           Positioned(
//                             left: 8,
//                             bottom: 8,
//                             right: 8,
//                             child: FittedBox(
//                               fit: BoxFit.scaleDown,
//                               alignment: Alignment.centerLeft,
//                               child: Text(
//                                 _getFormattedName(channel),
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 maxLines: 1,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildControls() {
//     final Duration currentPosition = _accumulatedSeekForward > 0 ||
//             _accumulatedSeekBackward > 0 ||
//             _isScrubbing
//         ? _previewPosition
//         : _controller?.value.position ?? Duration.zero;
//     final Duration totalDuration = _controller?.value.duration ?? Duration.zero;

//     return Positioned(
//       bottom: 0,
//       left: 0,
//       right: 0,
//       child: Opacity(
//         opacity: _controlsVisible ? 1 : 0.0,
//         child: IgnorePointer(
//           ignoring: !_controlsVisible,
//           child: Container(
//             color: Colors.black54,
//             padding: const EdgeInsets.symmetric(vertical: 8.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SizedBox(width: screenwdt * 0.03),
//                     Container(
//                       color: playPauseButtonFocusNode.hasFocus
//                           ? const Color.fromARGB(200, 16, 62, 99)
//                           : Colors.transparent,
//                       child: Focus(
//                         focusNode: playPauseButtonFocusNode,
//                         autofocus: widget.liveStatus == false,
//                         onFocusChange: (hasFocus) {
//                           if (hasFocus) print("✅ FOCUS GAINED: Play/Pause Button");
//                           setState(() {});
//                         },
//                         child: IconButton(
//                           icon: Image.asset(
//                             (_controller?.value.isPlaying ?? false)
//                                 ? 'assets/pause.png'
//                                 : 'assets/play.png',
//                             width: 35,
//                             height: 35,
//                           ),
//                           onPressed: _togglePlayPause,
//                         ),
//                       ),
//                     ),
//                     if (widget.liveStatus == false)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                         child: Text(
//                           _formatDuration(currentPosition),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     Expanded(
//                       flex: 10,
//                       child: LayoutBuilder(
//                         builder: (context, constraints) {
//                           return GestureDetector(
//                             onHorizontalDragStart: (widget.liveStatus == false)
//                                 ? (details) => _onScrubStart(details, constraints)
//                                 : null,
//                             onHorizontalDragUpdate: (widget.liveStatus == false)
//                                 ? (details) => _onScrubUpdate(details, constraints)
//                                 : null,
//                             onHorizontalDragEnd: (widget.liveStatus == false)
//                                 ? (details) => _onScrubEnd(details)
//                                 : null,
//                             child: Container(
//                               color: Colors.transparent,
//                               child: _buildBeautifulProgressBar(
//                                   currentPosition, totalDuration),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     if (widget.liveStatus == false)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                         child: Text(
//                           _formatDuration(totalDuration),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     if (widget.liveStatus == true)
//                       Expanded(
//                         flex: 1,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: const [
//                             Icon(Icons.circle, color: Colors.red, size: 15),
//                             SizedBox(width: 5),
//                             Text(
//                               'Live',
//                               style: TextStyle(
//                                 color: Colors.red,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     SizedBox(width: screenwdt * 0.03),
//                   ],
//                 ),
//                 if (widget.liveStatus == false)
//                   Padding(
//                     padding: EdgeInsets.only(left: screenwdt * 0.03, top: 4.0),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: subtitleButtonFocusNode.hasFocus
//                             ? const Color.fromARGB(200, 16, 62, 99)
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(6),
//                         border: Border.all(
//                           color: subtitleButtonFocusNode.hasFocus ? Colors.purple : Colors.transparent,
//                           width: 2,
//                         ),
//                       ),
//                       child: Focus(
//                         focusNode: subtitleButtonFocusNode,
//                         onFocusChange: (hasFocus) {
//                           setState(() {});
//                         },
//                         child: InkWell(
//                           onTap: _showSubtitleMenu,
//                           child: const Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.subtitles, color: Colors.white, size: 22),
//                                 SizedBox(width: 8),
//                                 Text(
//                                   "Subtitles",
//                                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
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

//   Widget _buildBeautifulProgressBar(
//       Duration displayPosition, Duration totalDuration) {
//     final totalDurationMs = totalDuration.inMilliseconds.toDouble();

//     if (totalDurationMs <= 0 || widget.liveStatus == true) {
//       return Container(
//         padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//         child: Container(
//             height: 8,
//             decoration: BoxDecoration(
//                 color: Colors.grey[800],
//                 borderRadius: BorderRadius.circular(4))),
//       );
//     }

//     double playedProgress =
//         (displayPosition.inMilliseconds / totalDurationMs).clamp(0.0, 1.0);

//     double bufferedProgress = (playedProgress + 0.005).clamp(0.0, 1.0);

//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//       child: Container(
//         height: 8,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(4),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(4),
//           child: Stack(
//             children: [
//               Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.grey[800]!, Colors.grey[700]!],
//                   ),
//                 ),
//               ),
//               FractionallySizedBox(
//                 widthFactor: bufferedProgress,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.grey[600]!, Colors.grey[500]!],
//                     ),
//                   ),
//                 ),
//               ),
//               FractionallySizedBox(
//                 widthFactor: playedProgress,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [
//                         Color(0xFF9B28F8),
//                         Color(0xFFE62B1E),
//                         Color(0xFFFF6B35),
//                       ],
//                       stops: [0.0, 0.7, 1.0],
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFF9B28F8).withOpacity(0.6),
//                         blurRadius: 8,
//                         spreadRadius: 1,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }






// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:keep_screen_on/keep_screen_on.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
// import 'package:mobi_tv_entertainment/components/widgets/small_widgets/rainbow_page.dart';

// class VideoScreen extends StatefulWidget {
//   final String videoUrl;
//   final String name;
//   final bool liveStatus;
//   final String updatedAt;
//   final List<dynamic> channelList;
//   final String bannerImageUrl;
//   final int? videoId;
//   final String source;
//   final String streamType;

//   VideoScreen({
//     required this.videoUrl,
//     required this.updatedAt,
//     required this.channelList,
//     required this.bannerImageUrl,
//     required this.videoId,
//     required this.source,
//     required this.streamType,
//     required this.name,
//     required this.liveStatus,
//   });

//   @override
//   _VideoScreenState createState() => _VideoScreenState();
// }

// class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
//   // --- Hybrid Player Controllers ---
//   InAppWebViewController? webViewController;
//   VlcPlayerController? vlcController;
//   String activePlayer = 'NONE';

//   // --- High-Frequency Update Notifiers (Prevents Lag) ---
//   final ValueNotifier<Duration> _currentPosition = ValueNotifier(Duration.zero);
//   final ValueNotifier<Duration> _totalDuration = ValueNotifier(Duration.zero);
//   final ValueNotifier<Duration> _previewPosition = ValueNotifier(Duration.zero);
//   Timer? _keyRepeatTimer;
//   DateTime _lastKeyRepeatTime = DateTime.now();
//   final FocusNode _mainFocusNode = FocusNode();

//   // --- UI State Variables ---
//   bool _isVideoInitialized = false;
//   bool _isPlaying = false;
//   bool _isBuffering = true;
//   bool _loadingVisible = true;
//   bool _controlsVisible = true;
//   String? _currentModifiedUrl;
//   bool _isSeeking = false;

//   // --- Focus Variables ---
//   Timer? _hideControlsTimer;
//   int _focusedIndex = 0;
//   List<FocusNode> focusNodes = [];
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode playPauseButtonFocusNode = FocusNode();
//   final FocusNode subtitleButtonFocusNode = FocusNode();

//   // --- Seek Variables ---
//   bool _isScrubbing = false;
//   int _accumulatedSeekForward = 0;
//   int _accumulatedSeekBackward = 0;
//   Timer? _seekTimer;
//   Duration _baseSeekPosition = Duration.zero;
//   final int _seekDuration = 5;
//   final int _seekDelay = 800;

//   // --- Subtitle Variables ---
//   Map<int, String> _spuTracks = {};
//   int _currentSpuTrack = -1;
//   bool _hasFetchedSubtitles = false;

//   // --- Network & Stall Recovery Variables ---
//   Timer? _networkCheckTimer;
//   bool _wasDisconnected = false;
//   bool _isAttemptingResume = false;
//   DateTime _lastPlayingTime = DateTime.now();
//   Duration _lastPositionCheck = Duration.zero;
//   int _stallCounter = 0;
//   bool _hasStartedPlaying = false;
//   bool _isUserPaused = false;

//   Map<String, Uint8List> _bannerCache = {};
//   bool _isDisposing = false;
//   final String localImage = "";

//   final InAppWebViewSettings settings = InAppWebViewSettings(
//     userAgent:
//         "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
//     allowsInlineMediaPlayback: true,
//     mediaPlaybackRequiresUserGesture: false,
//     javaScriptEnabled: true,
//     useHybridComposition: false,
//     transparentBackground: true,
//     hardwareAcceleration: true,
//     supportZoom: false,
//     displayZoomControls: false,
//     builtInZoomControls: false,
//     disableHorizontalScroll: true,
//     disableVerticalScroll: true,
//   );

//   Uint8List _getCachedImage(String base64String) {
//     try {
//       if (!_bannerCache.containsKey(base64String)) {
//         if (_bannerCache.length >= 50) {
//           _bannerCache.remove(_bannerCache.keys.first);
//         }
//         _bannerCache[base64String] = base64Decode(base64String.split(',').last);
//       }
//       return _bannerCache[base64String]!;
//     } catch (e) {
//       return Uint8List.fromList([0, 0, 0, 0]);
//     }
//   }


  

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     KeepScreenOn.turnOn();

//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

//     _focusedIndex = widget.channelList.indexWhere(
//       (channel) => channel.id.toString() == widget.videoId.toString(),
//     );
//     _focusedIndex = (_focusedIndex >= 0) ? _focusedIndex : 0;

//     focusNodes = List.generate(
//       widget.channelList.length,
//       (index) => FocusNode(),
//     );

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       _focusAndScrollToInitialItem();
//       String initialTarget =
//           (widget.streamType.trim().toLowerCase() == 'custom') ? 'WEB' : 'VLC';

//       String secureUrl = widget.videoUrl;
//       try {
//         secureUrl = await SecureUrlService.getSecureUrl(widget.videoUrl,
//             expirySeconds: 10);
//       } catch (e) {}

//       await _switchPlayerSafely(initialTarget, secureUrl);
//     });

//     _startHideControlsTimer();
//     _startNetworkMonitor();
//     _startPositionUpdater();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.inactive ||
//         state == AppLifecycleState.paused) {
//       if (activePlayer == 'VLC') vlcController?.pause();
//       if (activePlayer == 'WEB')
//         webViewController?.evaluateJavascript(
//             source: "document.getElementById('video').pause();");
//     } else if (state == AppLifecycleState.resumed) {
//       if (!_isUserPaused) {
//         if (activePlayer == 'VLC') vlcController?.play();
//         if (activePlayer == 'WEB')
//           webViewController?.evaluateJavascript(
//               source: "document.getElementById('video').play();");
//       }
//     }
//   }

//   void _startNetworkMonitor() {
//     _networkCheckTimer?.cancel();
//     _networkCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
//       if (_isDisposing) return;
//       bool isConnected = await _isInternetAvailable();
//       if (!isConnected && !_wasDisconnected) {
//         _wasDisconnected = true;
//       } else if (isConnected && _wasDisconnected) {
//         _wasDisconnected = false;
//         _onNetworkReconnected();
//       }
//     });
//   }

//   Future<bool> _isInternetAvailable() async {
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } catch (_) {
//       return false;
//     }
//   }

//   Future<void> _onNetworkReconnected() async {
//     if (_currentModifiedUrl == null || _isDisposing) return;
//     try {
//       if (widget.liveStatus == true) {
//         await _attemptResumeLiveStream();
//       } else {
//         if (activePlayer == 'VLC' && vlcController != null) {
//           await vlcController!.play();
//         } else if (activePlayer == 'WEB' && webViewController != null) {
//           await webViewController!.evaluateJavascript(
//               source: "document.getElementById('video').play();");
//         }
//       }
//     } catch (e) {
//       print("Critical error during reconnection: $e");
//     }
//   }

//   Future<void> _attemptResumeLiveStream() async {
//     if (!mounted ||
//         _isAttemptingResume ||
//         widget.liveStatus == false ||
//         _currentModifiedUrl == null ||
//         _isDisposing) {
//       return;
//     }

//     setState(() {
//       _isAttemptingResume = true;
//       _loadingVisible = true;
//     });

//     try {
//       String newSecureUrl = widget.videoUrl;
//       try {
//         newSecureUrl = await SecureUrlService.getSecureUrl(widget.videoUrl,
//             expirySeconds: 10);
//       } catch (e) {}

//       await _switchPlayerSafely(activePlayer, newSecureUrl);

//       _lastPlayingTime = DateTime.now();
//       _stallCounter = 0;
//       _isUserPaused = false;
//     } catch (e) {
//       print("Error: Recovery failed: $e");
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isAttemptingResume = false;
//         });
//       }
//     }
//   }

//   void _startPositionUpdater() {
//     Timer.periodic(const Duration(seconds: 2), (_) {
//       if (!mounted || _isScrubbing || _isAttemptingResume || _isDisposing)
//         return;

//       if (widget.liveStatus == true && _hasStartedPlaying && !_isUserPaused) {
//         if (_lastPositionCheck != Duration.zero &&
//             _currentPosition.value == _lastPositionCheck) {
//           _stallCounter++;
//         } else {
//           _stallCounter = 0;
//         }

//         if (_stallCounter >= 3) {
//           _attemptResumeLiveStream();
//           _stallCounter = 0;
//         }
//         _lastPositionCheck = _currentPosition.value;
//       }
//     });
//   }

//   String _buildVlcUrl(String baseUrl) {
//     final String networkCaching = "network-caching=300";
//     final String liveCaching = "live-caching=300";
//     final String fileCaching = "file-caching=200";
//     final String rtspTcp = "rtsp-tcp";
//     return widget.liveStatus == true
//         ? '$baseUrl?$networkCaching&$liveCaching&$fileCaching&$rtspTcp'
//         : '$baseUrl?$networkCaching&$fileCaching&$rtspTcp';
//   }

//   Future<void> _initVlcPlayer(String baseUrl) async {
//     if (_isDisposing) return;

//     if (vlcController != null) {
//       vlcController!.removeListener(_vlcListener);
//       await vlcController!.stop();
//       await vlcController!.dispose();
//       vlcController = null;
//     }

//     _lastPlayingTime = DateTime.now();
//     _stallCounter = 0;
//     _hasStartedPlaying = false;
//     _hasFetchedSubtitles = false;

//     vlcController = VlcPlayerController.network(
//       _buildVlcUrl(baseUrl),
//       hwAcc: HwAcc.auto,
//       autoPlay: true,
//       options: VlcPlayerOptions(
//         http: VlcHttpOptions([
//           ':http-user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
//         ]),
//         video: VlcVideoOptions([
//           VlcVideoOptions.dropLateFrames(true),
//           VlcVideoOptions.skipFrames(true),
//         ]),
//       ),
//     );
//     vlcController!.addListener(_vlcListener);
//     if (mounted) setState(() {});
//   }

//   Future<void> _fetchSubtitles() async {
//     if (vlcController != null && vlcController!.value.isInitialized) {
//       final tracks = await vlcController!.getSpuTracks();
//       final current = await vlcController!.getSpuTrack() ?? -1;
//       if (mounted) {
//         setState(() {
//           _spuTracks = tracks;
//           _currentSpuTrack = current;
//           _hasFetchedSubtitles = true;
//         });
//       }
//     }
//   }

//   void _vlcListener() {
//     if (!mounted || vlcController == null || _isDisposing) return;
//     final value = vlcController!.value;
//     final PlayingState playingState = value.playingState;

//     if (widget.liveStatus == true && !_isAttemptingResume) {
//       if (playingState == PlayingState.playing) {
//         _lastPlayingTime = DateTime.now();
//         if (!_hasStartedPlaying) _hasStartedPlaying = true;
//         if (!_hasFetchedSubtitles) _fetchSubtitles();
//       } else if (playingState == PlayingState.buffering && _hasStartedPlaying) {
//         if (DateTime.now().difference(_lastPlayingTime) >
//             const Duration(seconds: 8)) _attemptResumeLiveStream();
//       } else if (playingState == PlayingState.error) {
//         _attemptResumeLiveStream();
//       } else if ((playingState == PlayingState.stopped ||
//               playingState == PlayingState.ended) &&
//           _hasStartedPlaying) {
//         if (DateTime.now().difference(_lastPlayingTime) >
//             const Duration(seconds: 5)) _attemptResumeLiveStream();
//       }
//     } else if (playingState == PlayingState.paused) {
//       if (_isUserPaused) {
//         _lastPlayingTime = DateTime.now();
//       } else {
//         if (DateTime.now().difference(_lastPlayingTime) >
//             const Duration(seconds: 5)) _attemptResumeLiveStream();
//       }
//     } else if (playingState == PlayingState.playing &&
//         widget.liveStatus == false) {
//       if (!_hasFetchedSubtitles) _fetchSubtitles();
//     }

//     _currentPosition.value = value.position;
//     _totalDuration.value = value.duration;

//     bool needsRebuild = false;
//     if (_isPlaying != value.isPlaying) {
//       _isPlaying = value.isPlaying;
//       needsRebuild = true;
//     }
//     if (_isBuffering != value.isBuffering) {
//       _isBuffering = value.isBuffering;
//       needsRebuild = true;
//     }
//     if (!_isVideoInitialized && value.isInitialized) {
//       _isVideoInitialized = true;
//       needsRebuild = true;
//     }

//     bool newLoadingVisible = _isBuffering ||
//         playingState == PlayingState.initializing ||
//         _isAttemptingResume;
//     if (_isPlaying && !_isBuffering) newLoadingVisible = false;

//     if (_loadingVisible != newLoadingVisible) {
//       _loadingVisible = newLoadingVisible;
//       needsRebuild = true;
//     }

//     if (needsRebuild && mounted) setState(() {});
//   }

//   Future<void> _switchPlayerSafely(
//       String targetPlayerType, String secureUrl) async {
//     if (_isDisposing) return;

//     setState(() {
//       _loadingVisible = true;
//       _isVideoInitialized = false;
//     });

//     if (activePlayer == 'VLC' && vlcController != null) {
//       vlcController!.removeListener(_vlcListener);
//       await vlcController!.stop();
//       await vlcController!.dispose();
//       vlcController = null;
//     }
//     webViewController = null;

//     setState(() {
//       activePlayer = 'NONE';
//     });
//     await Future.delayed(const Duration(milliseconds: 600));
//     if (_isDisposing) return;

//     _currentModifiedUrl = secureUrl;
//     setState(() {
//       activePlayer = targetPlayerType;
//     });

//     if (targetPlayerType == 'WEB') {
//       if (webViewController != null) {
//         await webViewController!.evaluateJavascript(
//             source: "loadNewVideo('$_currentModifiedUrl');");
//       }
//     } else if (targetPlayerType == 'VLC') {
//       await _initVlcPlayer(_currentModifiedUrl!);
//     }
//   }

//   Future<void> _onItemTap(int index) async {
//     if (!mounted || _isDisposing) return;
//     setState(() {
//       _focusedIndex = index;
//     });

//     var selectedChannel = widget.channelList[index];
//     String typeFromData = widget.streamType;

//     if (selectedChannel is Map) {
//       typeFromData = selectedChannel['stream_type']?.toString() ??
//           selectedChannel['streamType']?.toString() ??
//           widget.streamType;
//     } else {
//       try {
//         typeFromData = selectedChannel.stream_type?.toString() ?? typeFromData;
//       } catch (_) {
//         try {
//           typeFromData = selectedChannel.streamType?.toString() ?? typeFromData;
//         } catch (_) {}
//       }
//     }

//     String targetPlayer =
//         (typeFromData.trim().toLowerCase() == 'custom') ? 'WEB' : 'VLC';
//     String rawUrl = "";

//     if (selectedChannel is Map) {
//       rawUrl = selectedChannel['url']?.toString() ?? "";
//     } else {
//       try {
//         rawUrl = selectedChannel.url?.toString() ?? "";
//       } catch (_) {}
//     }

//     if (rawUrl.isEmpty) return;

//     String secureUrl = rawUrl;
//     try {
//       secureUrl =
//           await SecureUrlService.getSecureUrl(rawUrl, expirySeconds: 10);
//     } catch (e) {}

//     if (_isDisposing) return;
//     await _switchPlayerSafely(targetPlayer, secureUrl);

//     _scrollToFocusedItem();
//     _resetHideControlsTimer();
//   }

//   bool _handleKeyEvent(KeyEvent event) {
//     if (_isDisposing) return false;

//     if (event is KeyDownEvent ||
//         event is RawKeyDownEvent ||
//         event is KeyRepeatEvent) {
//       // If controls are hidden, wake up the UI and do nothing else.
//       if (!_controlsVisible) {
//         _resetHideControlsTimer();
//         return true;
//       }

//       _resetHideControlsTimer();

//       switch (event.logicalKey) {
//         case LogicalKeyboardKey.escape:
//         case LogicalKeyboardKey.browserBack:
//           return false;

//         case LogicalKeyboardKey.arrowUp:
//           if (event is KeyRepeatEvent) {
//             // 300ms throttle
//             final now = DateTime.now();
//             if (now.difference(_lastKeyRepeatTime).inMilliseconds < 300)
//               return true;
//             _lastKeyRepeatTime = now;

//             // Sirf channel list par ho tab repeat kaam kare
//             if (!playPauseButtonFocusNode.hasFocus &&
//                 !subtitleButtonFocusNode.hasFocus) {
//               if (_focusedIndex > 0) _changeFocusAndScroll(_focusedIndex - 1);
//             }
//             return true;
//           }
//           // Normal single press
//           if (subtitleButtonFocusNode.hasFocus) {
//             FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//           } else if (playPauseButtonFocusNode.hasFocus) {
//             if (widget.liveStatus == false && widget.channelList.isNotEmpty) {
//               FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//             }
//           } else if (_focusedIndex > 0) {
//             _changeFocusAndScroll(_focusedIndex - 1);
//           }
//           return true;

//         case LogicalKeyboardKey.arrowDown:
//           if (event is KeyRepeatEvent) {
//             // 300ms throttle
//             final now = DateTime.now();
//             if (now.difference(_lastKeyRepeatTime).inMilliseconds < 300)
//               return true;
//             _lastKeyRepeatTime = now;

//             // Sirf channel list par ho tab repeat kaam kare
//             if (!playPauseButtonFocusNode.hasFocus &&
//                 !subtitleButtonFocusNode.hasFocus) {
//               if (_focusedIndex < widget.channelList.length - 1) {
//                 _changeFocusAndScroll(_focusedIndex + 1);
//               }
//             }
//             return true;
//           }
//           // Normal single press
//           if (playPauseButtonFocusNode.hasFocus &&
//               widget.liveStatus == false &&
//               activePlayer == 'VLC') {
//             FocusScope.of(context).requestFocus(subtitleButtonFocusNode);
//           } else if (_focusedIndex < widget.channelList.length - 1) {
//             _changeFocusAndScroll(_focusedIndex + 1);
//           }
//           return true;

//         case LogicalKeyboardKey.arrowRight:
//           if (widget.liveStatus == false) _seekForward();
//           return true;

//         case LogicalKeyboardKey.arrowLeft:
//           if (widget.liveStatus == false) _seekBackward();
//           if (playPauseButtonFocusNode.hasFocus &&
//               widget.channelList.isNotEmpty) {
//             FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//           }
//           return true;

//         case LogicalKeyboardKey.select:
//         case LogicalKeyboardKey.enter:
//         case LogicalKeyboardKey.mediaPlayPause:
//           if (event is KeyRepeatEvent) return true;
//           if (subtitleButtonFocusNode.hasFocus) {
//             _showSubtitleMenu();
//             return true;
//           }
//           if (widget.liveStatus == false) {
//             _togglePlayPause();
//           } else {
//             if (playPauseButtonFocusNode.hasFocus ||
//                 widget.channelList.isEmpty) {
//               _togglePlayPause();
//             } else {
//               _onItemTap(_focusedIndex);
//             }
//           }
//           return true;

//         default:
//           return false;
//       }
//     }
//     return false;
//   }

//   void _togglePlayPause() {
//     if (_isDisposing) return;
//     if (activePlayer == 'WEB' && webViewController != null) {
//       webViewController!.evaluateJavascript(source: """
//         var v = document.getElementById('video');
//         if (v.paused) { v.play(); } else { v.pause(); }
//       """);
//       setState(() {
//         _isPlaying = !_isPlaying;
//         _isUserPaused = !_isPlaying;
//       });
//       _lastPlayingTime = DateTime.now();
//     } else if (activePlayer == 'VLC' && vlcController != null) {
//       if (vlcController!.value.isPlaying) {
//         vlcController!.pause();
//         setState(() {
//           _isUserPaused = true;
//           _isPlaying = false;
//         });
//       } else {
//         vlcController!.play();
//         setState(() {
//           _isUserPaused = false;
//           _isPlaying = true;
//         });
//         _lastPlayingTime = DateTime.now();
//         _stallCounter = 0;
//       }
//     }
//     FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//     _resetHideControlsTimer();
//   }

//   Future<void> _seekToPosition(Duration position) async {
//     if (_isSeeking || _isDisposing) return;
//     _isSeeking = true;
//     try {
//       if (activePlayer == 'WEB' && webViewController != null) {
//         double seconds = position.inMilliseconds / 1000.0;
//         await webViewController!.evaluateJavascript(
//             source:
//                 "document.getElementById('video').currentTime = $seconds; document.getElementById('video').play();");
//       } else if (activePlayer == 'VLC' && vlcController != null) {
//         await vlcController!.seekTo(position);
//         await vlcController!
//             .play(); // Ensures video plays after seeking like the old code
//       }
//     } catch (e) {
//       print("Error during seek: $e");
//     } finally {
//       await Future.delayed(const Duration(milliseconds: 500));
//       _isSeeking = false;
//     }
//   }

//   void _seekForward() {
//     if (_totalDuration.value <= Duration.zero || _isDisposing) return;

//     _accumulatedSeekForward += _seekDuration;
//     final newPosition =
//         _currentPosition.value + Duration(seconds: _accumulatedSeekForward);

//     setState(() {
//       _previewPosition.value = newPosition > _totalDuration.value
//           ? _totalDuration.value
//           : newPosition;
//     });

//     _seekTimer?.cancel();
//     _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
//       if (_isDisposing) return;
//       _seekToPosition(_previewPosition.value).then((_) {
//         if (mounted && !_isDisposing) {
//           setState(() {
//             _accumulatedSeekForward = 0;
//           });
//         }
//       });
//     });
//   }

//   void _seekBackward() {
//     if (_totalDuration.value <= Duration.zero || _isDisposing) return;

//     _accumulatedSeekBackward += _seekDuration;
//     final newPosition =
//         _currentPosition.value - Duration(seconds: _accumulatedSeekBackward);

//     setState(() {
//       _previewPosition.value =
//           newPosition > Duration.zero ? newPosition : Duration.zero;
//     });

//     _seekTimer?.cancel();
//     _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
//       if (_isDisposing) return;
//       _seekToPosition(_previewPosition.value).then((_) {
//         if (mounted && !_isDisposing) {
//           setState(() {
//             _accumulatedSeekBackward = 0;
//           });
//         }
//       });
//     });
//   }

//   void _onScrubStart(DragStartDetails details, BoxConstraints constraints) {
//     if (_totalDuration.value <= Duration.zero || _isDisposing) return;
//     _resetHideControlsTimer();
//     setState(() {
//       _isScrubbing = true;
//       _accumulatedSeekForward =
//           1; // Mimics old code behavior to force UI update
//     });
//     final double progress =
//         (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
//     _previewPosition.value = _totalDuration.value * progress;
//   }

//   void _onScrubUpdate(DragUpdateDetails details, BoxConstraints constraints) {
//     if (!_isScrubbing || _totalDuration.value <= Duration.zero || _isDisposing)
//       return;
//     _resetHideControlsTimer();
//     final double progress =
//         (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
//     _previewPosition.value = _totalDuration.value * progress;
//   }

//   void _onScrubEnd(DragEndDetails details) {
//     if (!_isScrubbing || _isDisposing) return;
//     _seekToPosition(_previewPosition.value).then((_) {
//       if (mounted && !_isDisposing) {
//         setState(() {
//           _accumulatedSeekForward = 0;
//           _isScrubbing = false;
//         });
//       }
//     });
//     _resetHideControlsTimer();
//   }

//   void _showSubtitleMenu() {
//     _hideControlsTimer?.cancel();

//     showDialog(
//         context: context,
//         builder: (context) {
//           final size = MediaQuery.of(context).size;
//           int focusedIndex =
//               _spuTracks.keys.toList().indexOf(_currentSpuTrack) + 1;
//           if (_currentSpuTrack == -1) focusedIndex = 0;

//           final ScrollController dialogScrollController = ScrollController();
//           final List<MapEntry<int, String>> tracksList =
//               _spuTracks.entries.toList();

//           return StatefulBuilder(builder: (context, setDialogState) {
//             return Align(
//               alignment: Alignment.bottomLeft,
//               child: Padding(
//                 padding: EdgeInsets.only(
//                     left: size.width * 0.03, bottom: size.height * 0.18),
//                 child: Material(
//                   color: Colors.transparent,
//                   child: Container(
//                     width: size.width * 0.35,
//                     height: size.height * 0.4,
//                     decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.9),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.white24, width: 1),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.5),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           ),
//                         ]),
//                     child: Column(
//                       children: [
//                         const Padding(
//                           padding: EdgeInsets.symmetric(
//                               vertical: 12.0, horizontal: 16.0),
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text("Select Subtitle",
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16)),
//                           ),
//                         ),
//                         const Divider(color: Colors.white24, height: 1),
//                         Expanded(
//                           child: _spuTracks.isEmpty
//                               ? const Padding(
//                                   padding: EdgeInsets.all(16.0),
//                                   child: Text("No subtitles available",
//                                       style: TextStyle(color: Colors.white70)),
//                                 )
//                               : ListView.builder(
//                                   controller: dialogScrollController,
//                                   padding: EdgeInsets.zero,
//                                   itemCount: tracksList.length + 1,
//                                   itemBuilder: (context, index) {
//                                     final isOffOption = index == 0;
//                                     final trackId = isOffOption
//                                         ? -1
//                                         : tracksList[index - 1].key;
//                                     final trackName = isOffOption
//                                         ? "Off"
//                                         : tracksList[index - 1].value;

//                                     final isSelected =
//                                         _currentSpuTrack == trackId;
//                                     final isFocused = focusedIndex == index;

//                                     return Focus(
//                                       autofocus: isSelected,
//                                       onFocusChange: (hasFocus) {
//                                         if (hasFocus) {
//                                           setDialogState(
//                                               () => focusedIndex = index);

//                                           const double itemHeight = 48.0;
//                                           final double viewportHeight =
//                                               (size.height * 0.4) - 48.0;
//                                           final double targetOffset =
//                                               (itemHeight * index) -
//                                                   (viewportHeight / 2) +
//                                                   (itemHeight / 2);

//                                           final maxScroll =
//                                               dialogScrollController
//                                                   .position.maxScrollExtent;
//                                           final double clampedOffset =
//                                               targetOffset.clamp(
//                                                   0.0,
//                                                   maxScroll > 0
//                                                       ? maxScroll
//                                                       : 0.0);

//                                           dialogScrollController.animateTo(
//                                               clampedOffset,
//                                               duration: const Duration(
//                                                   milliseconds: 200),
//                                               curve: Curves.easeInOut);
//                                         }
//                                       },
//                                       onKey: (node, event) {
//                                         if (event is RawKeyDownEvent &&
//                                             (event.logicalKey ==
//                                                     LogicalKeyboardKey.select ||
//                                                 event.logicalKey ==
//                                                     LogicalKeyboardKey.enter)) {
//                                           vlcController?.setSpuTrack(trackId);
//                                           setState(() {
//                                             _currentSpuTrack = trackId;
//                                           });
//                                           Navigator.pop(context);
//                                           return KeyEventResult.handled;
//                                         }
//                                         return KeyEventResult.ignored;
//                                       },
//                                       child: GestureDetector(
//                                         onTap: () {
//                                           vlcController?.setSpuTrack(trackId);
//                                           setState(() {
//                                             _currentSpuTrack = trackId;
//                                           });
//                                           Navigator.pop(context);
//                                         },
//                                         child: Container(
//                                           color: isFocused
//                                               ? Colors.purple.withOpacity(0.8)
//                                               : Colors.transparent,
//                                           height: 48.0,
//                                           child: Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 16.0),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 Text(trackName,
//                                                     style: const TextStyle(
//                                                         color: Colors.white,
//                                                         fontSize: 14)),
//                                                 if (isSelected)
//                                                   const Icon(Icons.check,
//                                                       color: Colors.white,
//                                                       size: 20),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           });
//         }).then((_) {
//       FocusScope.of(context).requestFocus(subtitleButtonFocusNode);
//       _resetHideControlsTimer();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double screenwdt = MediaQuery.of(context).size.width;
//     final double screenhgt = MediaQuery.of(context).size.height;
//     final double bottomBarHeight = screenhgt * 0.15;
//     final double topTitleHeight = screenhgt * 0.10;
//     final double leftPanelWidth = screenwdt * 0.15;

//     // --- NEW: Extra margin to reduce video height when controls are visible ---
//     final double extraVerticalMargin =
//         1.0; // Isko kam/zyada karke video ki height set kar sakte hain

//     final bool hasChannels = widget.channelList.isNotEmpty;

//     // Smooth bounds calculation
//     final double offsetLeft =
//         (_controlsVisible && hasChannels) ? leftPanelWidth : 0.0;
//     final double offsetRight = _controlsVisible ? 16.0 : 0.0;
//     // Yahan offsetTop aur offsetBottom mein extraVerticalMargin add kiya gaya hai
//     final double offsetTop =
//         _controlsVisible ? (topTitleHeight + extraVerticalMargin) : 0.0;
//     final double offsetBottom =
//         _controlsVisible ? (bottomBarHeight + extraVerticalMargin) : 0.0;

//     final double targetVideoWidth = screenwdt - offsetLeft - offsetRight;
//     final double targetVideoHeight = screenhgt - offsetTop - offsetBottom;

//     return PopScope(
//       canPop: true,
//       onPopInvokedWithResult: (bool didPop, dynamic result) {
//         if (didPop) _safeDispose();
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: Focus(
//           focusNode: _mainFocusNode,
//           autofocus: true,
//           onKeyEvent: (node, event) {
//             bool isHandled = _handleKeyEvent(event);
//             return isHandled ? KeyEventResult.handled : KeyEventResult.ignored;
//           },
//           child: GestureDetector(
//             onTap: _resetHideControlsTimer,
//             child: Stack(
//               children: [
//                 // 1. VIDEO LAYER (Smooth CSS Transform for WEB, AnimatedPositioned for VLC)
//                 Positioned.fill(
//                   child: Stack(
//                     children: [
//                       // WEB PLAYER (Always Full Screen, CSS handles resizing smoothly)
//                       if (activePlayer == 'WEB')
//                         ExcludeFocus(
//                           // Zaroori hai taaki TV remote ka focus webview na churaye
//                           child: Container(
//                             color: Colors.black,
//                             width: screenwdt,
//                             height: screenhgt,
//                             child: InAppWebView(
//                               key: const ValueKey('WEB_Player'),
//                               initialData: InAppWebViewInitialData(
//                                 data: _getHtmlString(),
//                                 mimeType: "text/html",
//                                 encoding: "utf-8",
//                               ),
//                               initialSettings: settings,
//                               onWebViewCreated: (controller) {
//                                 webViewController = controller;
//                                 controller.addJavaScriptHandler(
//                                     handlerName: 'videoState',
//                                     callback: (args) {
//                                       if (!mounted ||
//                                           _isDisposing ||
//                                           args.isEmpty) return;
//                                       var state = args[0];

//                                       _currentPosition.value = Duration(
//                                           milliseconds:
//                                               state['position'].toInt());
//                                       _totalDuration.value = Duration(
//                                           milliseconds:
//                                               state['duration'].toInt());

//                                       bool newIsPlaying = state['isPlaying'];
//                                       bool newIsBuffering =
//                                           state['isBuffering'];
//                                       bool needsRebuild = false;

//                                       if (!_isVideoInitialized) {
//                                         _isVideoInitialized = true;
//                                         needsRebuild = true;
//                                       }
//                                       if (_isPlaying != newIsPlaying) {
//                                         _isPlaying = newIsPlaying;
//                                         needsRebuild = true;
//                                       }
//                                       if (_isBuffering != newIsBuffering) {
//                                         _isBuffering = newIsBuffering;
//                                         needsRebuild = true;
//                                       }

//                                       bool newLoadingVisible = newIsBuffering;
//                                       if (newIsPlaying && !newIsBuffering) {
//                                         newLoadingVisible = false;
//                                         _lastPlayingTime = DateTime.now();
//                                       }

//                                       if (_loadingVisible !=
//                                           newLoadingVisible) {
//                                         _loadingVisible = newLoadingVisible;
//                                         needsRebuild = true;
//                                       }

//                                       if (needsRebuild && mounted)
//                                         setState(() {});
//                                     });
//                               },
//                             ),
//                           ),
//                         ),

//                       //   // VLC PLAYER (Flutter ka AnimatedPositioned use karega)
//                       //   if (activePlayer == 'VLC' && vlcController != null)
//                       //     AnimatedPositioned(
//                       //       duration: const Duration(milliseconds: 300),
//                       //       curve: Curves.easeInOut,
//                       //       left: offsetLeft,
//                       //       top: offsetTop,
//                       //       width: targetVideoWidth,
//                       //       height: targetVideoHeight,
//                       //       child: Container(
//                       //         decoration: BoxDecoration(
//                       //           color: Colors.black,
//                       //           borderRadius: BorderRadius.circular(_controlsVisible ? 12.0 : 0.0),
//                       //           boxShadow: _controlsVisible
//                       //               ? [const BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5)]
//                       //               : [],
//                       //         ),
//                       //         child: ClipRRect(
//                       //           borderRadius: BorderRadius.circular(_controlsVisible ? 12.0 : 0.0),
//                       //           child: LayoutBuilder(
//                       //             builder: (context, constraints) {
//                       //               final screenWidth = constraints.maxWidth;
//                       //               final screenHeight = constraints.maxHeight;

//                       //               double videoWidth = vlcController!.value.size.width;
//                       //               double videoHeight = vlcController!.value.size.height;

//                       //               if (videoWidth <= 0 || videoHeight <= 0) {
//                       //                 videoWidth = 16.0;
//                       //                 videoHeight = 9.0;
//                       //               }

//                       //               final videoRatio = videoWidth / videoHeight;
//                       //               final screenRatio = screenWidth > 0 && screenHeight > 0
//                       //                   ? screenWidth / screenHeight
//                       //                   : 16 / 9;

//                       //               double scaleXInner = 1.0;
//                       //               double scaleYInner = 1.0;

//                       //               if (videoRatio < screenRatio) {
//                       //                 scaleXInner = screenRatio / videoRatio;
//                       //               } else {
//                       //                 scaleYInner = videoRatio / screenRatio;
//                       //               }

//                       //               const double maxScaleLimit = 1.35;
//                       //               if (scaleXInner > maxScaleLimit) scaleXInner = maxScaleLimit;
//                       //               if (scaleYInner > maxScaleLimit) scaleYInner = maxScaleLimit;

//                       //               return Container(
//                       //                 width: screenWidth,
//                       //                 height: screenHeight,
//                       //                 color: Colors.black,
//                       //                 child: Center(
//                       //                   child: Transform.scale(
//                       //                     scaleX: scaleXInner,
//                       //                     scaleY: scaleYInner,
//                       //                     child: VlcPlayer(
//                       //                       key: const ValueKey('VLC_PLAYER'),
//                       //                       controller: vlcController!,
//                       //                       aspectRatio: videoRatio,
//                       //                       placeholder: const Center(
//                       //                           child: CircularProgressIndicator(color: Colors.red)),
//                       //                     ),
//                       //                   ),
//                       //                 ),
//                       //               );
//                       //             },
//                       //           )
//                       //         ),
//                       //       ),
//                       //     ),

//                       // VLC PLAYER (Aapke scaleXInner/scaleYInner logic ke sath)
//                       if (activePlayer == 'VLC' && vlcController != null)
//                         AnimatedPositioned(
//                           duration: const Duration(milliseconds: 300),
//                           curve: Curves.easeInOut,
//                           left: offsetLeft,
//                           top: offsetTop,
//                           // FIX: width aur height ki jagah right aur bottom use kiya hai
//                           right: offsetRight,
//                           bottom: offsetBottom,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.black,
//                               borderRadius: BorderRadius.circular(
//                                   _controlsVisible ? 12.0 : 0.0),
//                               boxShadow: _controlsVisible
//                                   ? [
//                                       const BoxShadow(
//                                           color: Colors.black54,
//                                           blurRadius: 20,
//                                           spreadRadius: 5)
//                                     ]
//                                   : [],
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(
//                                   _controlsVisible ? 12.0 : 0.0),
//                               child: LayoutBuilder(
//                                 builder: (context, constraints) {
//                                   final screenWidth = constraints.maxWidth;
//                                   final screenHeight = constraints.maxHeight;

//                                   double videoWidth =
//                                       vlcController!.value.size.width;
//                                   double videoHeight =
//                                       vlcController!.value.size.height;

//                                   if (videoWidth <= 0 || videoHeight <= 0) {
//                                     videoWidth = 16.0;
//                                     videoHeight = 9.0;
//                                   }

//                                   final videoRatio = videoWidth / videoHeight;
//                                   final screenRatio =
//                                       screenWidth > 0 && screenHeight > 0
//                                           ? screenWidth / screenHeight
//                                           : 16 / 9;

//                                   double scaleXInner = 1.0;
//                                   double scaleYInner = 1.0;

//                                   if (videoRatio < screenRatio) {
//                                     scaleXInner = screenRatio / videoRatio;
//                                   } else {
//                                     scaleYInner = videoRatio / screenRatio;
//                                   }

//                                   const double maxScaleLimit = 1.35;
//                                   if (scaleXInner > maxScaleLimit)
//                                     scaleXInner = maxScaleLimit;
//                                   if (scaleYInner > maxScaleLimit)
//                                     scaleYInner = maxScaleLimit;

//                                   return Container(
//                                     width: screenWidth,
//                                     height: screenHeight,
//                                     color: Colors.black,
//                                     child: Center(
//                                       child: Transform.scale(
//                                         scaleX: scaleXInner,
//                                         scaleY: scaleYInner,
//                                         alignment: Alignment
//                                             .center, // Center se scale hoga
//                                         child: VlcPlayer(
//                                           key: const ValueKey('VLC_PLAYER'),
//                                           controller: vlcController!,
//                                           aspectRatio: videoRatio,
//                                           placeholder: const Center(
//                                             // child:
//                                                 // CircularProgressIndicator(color: Colors.red),
//                       child: RainbowPage(
//                         backgroundColor: 
//                         // _loadingVisible || !_isVideoInitialized
//                         //     ? Colors.black
//                         //     :
//                              Colors.transparent,
//                       ),

                                               
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),

//                 // // 2. LOADING LAYER
//                 // if (_loadingVisible ||
//                 //     !_isVideoInitialized ||
//                 //     _isAttemptingResume)
//                 //   Container(
//                 //     color: Colors.black54,
//                 //     child: const Center(
//                 //       child:
//                 //           SpinKitFadingCircle(color: Colors.red, size: 50.0),
                         
//                 //     ),
//                 //   ),


//                 // 2. LOADING LAYER
//                 if (_loadingVisible ||
//                     !_isVideoInitialized ||
//                     _isAttemptingResume ||
//                     (_isBuffering && !_loadingVisible))
//                   Container(
//                     color: _loadingVisible || !_isVideoInitialized
//                         ? Colors.black54
//                         : Colors.transparent,
//                     child: Center(
//                       child: RainbowPage(
//                         backgroundColor: _loadingVisible || !_isVideoInitialized
//                             ? Colors.black
//                             : Colors.transparent,
//                       ),
//                     ),
//                   ),

//                 // 3. TITLE LAYER
//                 if (_controlsVisible)
//                   Positioned(
//                     top: 0,
//                     left: widget.channelList.isNotEmpty ? leftPanelWidth : 0.0,
//                     right: 0,
//                     height: topTitleHeight,
//                     child: Container(
//                       color: Colors.black.withOpacity(0.5),
//                       padding: const EdgeInsets.only(top: 8.0),
//                       alignment: Alignment.topCenter,
//                       child: ShaderMask(
//                         shaderCallback: (bounds) {
//                           return const LinearGradient(
//                             colors: [
//                               Color(0xFF9B28F8),
//                               Color(0xFFE62B1E),
//                               Color.fromARGB(255, 53, 255, 53)
//                             ],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ).createShader(
//                               Rect.fromLTWH(0, 0, bounds.width, bounds.height));
//                         },
//                         child: Text(
//                           (widget.channelList.isNotEmpty &&
//                                   _focusedIndex >= 0 &&
//                                   _focusedIndex < widget.channelList.length)
//                               ? _getFormattedName(
//                                   widget.channelList[_focusedIndex])
//                               : widget.name,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1.0,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                   ),

//                 // 4. CHANNEL LIST
//                 if (_controlsVisible && widget.channelList.isNotEmpty)
//                   Positioned(
//                     left: 0,
//                     top: 0,
//                     bottom: 0,
//                     width: leftPanelWidth,
//                     child: Container(
//                       color: Colors.black.withOpacity(0.85),
//                       padding: const EdgeInsets.only(
//                           top: 20, bottom: 20, left: 10, right: 10),
//                       child: ListView.builder(
//                         controller: _scrollController,
//                         itemCount: widget.channelList.length,
//                         itemBuilder: (context, index) {
//                           final channel = widget.channelList[index];
//                           final String channelId = channel.id?.toString() ?? '';
//                           final bool isBase64 =
//                               channel.banner?.startsWith('data:image') ?? false;
//                           final bool isFocused = _focusedIndex == index;

//                           return Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8.0),
//                             child: Focus(
//                               focusNode: focusNodes[index],
//                               autofocus: widget.liveStatus == true && isFocused,
//                               onFocusChange: (hasFocus) {
//                                 if (hasFocus) _scrollToFocusedItem();
//                               },
//                               child: GestureDetector(
//                                 onTap: () => _onItemTap(index),
//                                 child: Container(
//                                   height: screenhgt * 0.108,
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color: isFocused &&
//                                               !playPauseButtonFocusNode
//                                                   .hasFocus &&
//                                               !subtitleButtonFocusNode.hasFocus
//                                           ? const Color.fromARGB(
//                                               211, 155, 40, 248)
//                                           : Colors.transparent,
//                                       width: 4.0,
//                                     ),
//                                     borderRadius: BorderRadius.circular(8),
//                                     color: isFocused
//                                         ? Colors.white24
//                                         : Colors.transparent,
//                                   ),
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(4),
//                                     child: Stack(
//                                       children: [
//                                         Positioned.fill(
//                                           child: Opacity(
//                                             opacity: 0.8,
//                                             child: isBase64
//                                                 ? Image.memory(
//                                                     _bannerCache[channelId] ??
//                                                         _getCachedImage(
//                                                             channel.banner ??
//                                                                 localImage),
//                                                     fit: BoxFit.cover)
//                                                 : CachedNetworkImage(
//                                                     imageUrl: channel.banner ??
//                                                         localImage,
//                                                     fit: BoxFit.cover,
//                                                     errorWidget: (context, url,
//                                                             error) =>
//                                                         const Icon(Icons.error,
//                                                             color:
//                                                                 Colors.white),
//                                                   ),
//                                           ),
//                                         ),
//                                         if (isFocused)
//                                           Positioned(
//                                             left: 8,
//                                             bottom: 8,
//                                             right: 8,
//                                             child: FittedBox(
//                                               fit: BoxFit.scaleDown,
//                                               alignment: Alignment.centerLeft,
//                                               child: Text(
//                                                 _getFormattedName(channel),
//                                                 style: const TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: 14,
//                                                     fontWeight:
//                                                         FontWeight.bold),
//                                               ),
//                                             ),
//                                           ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),

//                 // 5. BOTTOM CONTROLS
//                 if (_controlsVisible)
//                   _buildControls(screenwdt, bottomBarHeight, leftPanelWidth),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildControls(
//       double screenwdt, double bottomBarHeight, double leftPanelWidth) {
//     return Positioned(
//       bottom: 0,
//       left: widget.channelList.isNotEmpty ? leftPanelWidth : 0.0,
//       right: 0,
//       height: bottomBarHeight,
//       child: Container(
//         color: Colors.black.withOpacity(0.8),
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // --- UPAR WALI ROW (Play/Pause, Time, Progress Bar, Live Indicator) ---
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // 1. Play / Pause Button
//                 Container(
//                   color: playPauseButtonFocusNode.hasFocus
//                       ? const Color.fromARGB(200, 16, 62, 99)
//                       : Colors.transparent,
//                   child: Focus(
//                     focusNode: playPauseButtonFocusNode,
//                     autofocus: widget.liveStatus == false,
//                     onFocusChange: (hasFocus) => setState(() {}),
//                     child: GestureDetector(
//                       onTap: _togglePlayPause,
//                       child: Container(
//                         width: 24,
//                         height: 24,
//                         color: Colors.transparent,
//                         child: ClipRect(
//                           child: Transform.scale(
//                             scale: 1.5,
//                             child: Image.asset(
//                               _isPlaying
//                                   ? 'assets/pause.png'
//                                   : 'assets/play.png',
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) =>
//                                   Icon(
//                                 _isPlaying ? Icons.pause : Icons.play_arrow,
//                                 color: Colors.white,
//                                 size: 24,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 if (widget.liveStatus == false)

//                   // 2. Current Time
//                   Padding(
//                     padding: const EdgeInsets.only(left: 12.0, right: 8.0),
//                     child: ListenableBuilder(
//                         listenable: Listenable.merge(
//                             [_currentPosition, _previewPosition]),
//                         builder: (context, child) {
//                           final Duration displayPosition =
//                               _accumulatedSeekForward > 0 ||
//                                       _accumulatedSeekBackward > 0 ||
//                                       _isScrubbing
//                                   ? _previewPosition.value
//                                   : _currentPosition.value;
//                           return Text(
//                             _formatDuration(displayPosition),
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold),
//                           );
//                         }),
//                   ),

//                 // 3. Progress Bar
//                 Expanded(
//                   child: LayoutBuilder(
//                     builder: (context, constraints) {
//                       return GestureDetector(
//                         onHorizontalDragStart: (details) =>
//                             _onScrubStart(details, constraints),
//                         onHorizontalDragUpdate: (details) =>
//                             _onScrubUpdate(details, constraints),
//                         onHorizontalDragEnd: (details) => _onScrubEnd(details),
//                         child: Container(
//                           height: 30,
//                           color: Colors.transparent,
//                           child: Center(
//                             child: ListenableBuilder(
//                                 listenable: Listenable.merge([
//                                   _currentPosition,
//                                   _previewPosition,
//                                   _totalDuration
//                                 ]),
//                                 builder: (context, child) {
//                                   final Duration displayPosition =
//                                       _accumulatedSeekForward > 0 ||
//                                               _accumulatedSeekBackward > 0 ||
//                                               _isScrubbing
//                                           ? _previewPosition.value
//                                           : _currentPosition.value;
//                                   return _buildBeautifulProgressBar(
//                                       displayPosition, _totalDuration.value);
//                                 }),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 if (widget.liveStatus == false)
//                   // 4. Total Time
//                   Padding(
//                     padding: const EdgeInsets.only(left: 8.0, right: 12.0),
//                     child: ValueListenableBuilder<Duration>(
//                         valueListenable: _totalDuration,
//                         builder: (context, totalDuration, child) {
//                           return Text(
//                             _formatDuration(totalDuration),
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold),
//                           );
//                         }),
//                   ),

//                 // 5. Live Indicator
//                 if (widget.liveStatus == true)
//                   Padding(
//                     padding: const EdgeInsets.only(left: 8.0),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: const [
//                         Icon(Icons.circle, color: Colors.red, size: 15),
//                         SizedBox(width: 5),
//                         Text('Live',
//                             style: TextStyle(
//                                 color: Colors.red,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                   ),
//               ],
//             ),

//             // --- NEECHE WALI ROW (Sirf Subtitles) ---
//             if (widget.liveStatus == false && activePlayer == 'VLC') ...[
//               const SizedBox(height: 10),
//               Container(
//                 decoration: BoxDecoration(
//                   color: subtitleButtonFocusNode.hasFocus
//                       ? const Color.fromARGB(200, 16, 62, 99)
//                       : Colors.transparent,
//                   borderRadius: BorderRadius.circular(6),
//                   border: Border.all(
//                       color: subtitleButtonFocusNode.hasFocus
//                           ? Colors.purple
//                           : Colors.transparent,
//                       width: 2),
//                 ),
//                 child: Focus(
//                   focusNode: subtitleButtonFocusNode,
//                   onFocusChange: (hasFocus) => setState(() {}),
//                   child: InkWell(
//                     onTap: _showSubtitleMenu,
//                     child: const Padding(
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.subtitles, color: Colors.white, size: 18),
//                           SizedBox(width: 4),
//                           Text("Subtitles",
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 14)),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBeautifulProgressBar(
//       Duration displayPosition, Duration totalDuration) {
//     final totalDurationMs = totalDuration.inMilliseconds.toDouble();

//     if (totalDurationMs <= 0 || widget.liveStatus == true) {
//       return Container(
//         padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//         child: Container(
//             height: 8,
//             decoration: BoxDecoration(
//                 color: Colors.grey[800],
//                 borderRadius: BorderRadius.circular(4))),
//       );
//     }

//     double playedProgress =
//         (displayPosition.inMilliseconds / totalDurationMs).clamp(0.0, 1.0);
//     double bufferedProgress = (playedProgress + 0.005).clamp(0.0, 1.0);

//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//       child: Container(
//         height: 8,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(4),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(4),
//           child: Stack(
//             children: [
//               Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.grey[800]!, Colors.grey[700]!],
//                   ),
//                 ),
//               ),
//               FractionallySizedBox(
//                 widthFactor: bufferedProgress,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.grey[600]!, Colors.grey[500]!],
//                     ),
//                   ),
//                 ),
//               ),
//               FractionallySizedBox(
//                 widthFactor: playedProgress,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [
//                         Color(0xFF9B28F8),
//                         Color(0xFFE62B1E),
//                         Color(0xFFFF6B35),
//                       ],
//                       stops: [0.0, 0.7, 1.0],
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFF9B28F8).withOpacity(0.6),
//                         blurRadius: 8,
//                         spreadRadius: 1,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // String _getHtmlString() {
//   //   return """
//   //   <!DOCTYPE html>
//   //   <html>
//   //   <head>
//   //     <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
//   //     <style>
//   //       * { margin: 0; padding: 0; box-sizing: border-box; }
//   //       body {
//   //         background: #000;
//   //         width: 100vw;
//   //         height: 100vh;
//   //         overflow: hidden;
//   //         -webkit-tap-highlight-color: transparent;
//   //       }
//   //       #wrapper {
//   //         position: absolute;
//   //         /* Default Full Screen */
//   //         top: 0px; left: 0px; right: 0px; bottom: 0px;
//   //         /* Yeh transition width aur height dono ko smooth karegi */
//   //         transition: top 0.3s ease, left 0.3s ease, right 0.3s ease, bottom 0.3s ease;
//   //       }
//   //       video {
//   //         width: 100%; height: 100%;
//   //         object-fit: contain; 
//   //         background: transparent;
//   //         outline: none; border: none;
//   //       }
//   //       video::-webkit-media-controls { display: none !important; }
//   //       video::-webkit-media-controls-enclosure { display: none !important; }
//   //     </style>
//   //     <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
//   //   </head>
//   //   <body>
//   //     <div id="wrapper">
//   //       <video id="video" autoplay playsinline></video>
//   //     </div>
//   //     <script>
//   //       var video = document.getElementById('video');
//   //       var wrapper = document.getElementById('wrapper');
//   //       var hls;

//   //       // Flutter yahan se margin/padding set karega
//   //       function setVideoBounds(left, top, right, bottom) {
//   //          wrapper.style.left = left + "px";
//   //          wrapper.style.top = top + "px";
//   //          wrapper.style.right = right + "px";
//   //          wrapper.style.bottom = bottom + "px";
//   //       }

//   //       function sendState() {
//   //         var state = { position: video.currentTime * 1000, duration: video.duration ? video.duration * 1000 : 0, isPlaying: !video.paused, isBuffering: video.readyState < 3 };
//   //         window.flutter_inappwebview.callHandler('videoState', state);
//   //       }
//   //       video.addEventListener('timeupdate', sendState);
//   //       video.addEventListener('play', sendState);
//   //       video.addEventListener('pause', sendState);
//   //       video.addEventListener('waiting', sendState);
//   //       video.addEventListener('playing', sendState);

//   //       function loadNewVideo(src) {
//   //         if (Hls.isSupported()) {
//   //           if (hls) hls.destroy();
//   //           hls = new Hls();
//   //           hls.loadSource(src);
//   //           hls.attachMedia(video);
//   //           hls.on(Hls.Events.MANIFEST_PARSED, function() {
//   //             if (hls.levels && hls.levels.length > 0) { hls.currentLevel = hls.levels.length - 1; }
//   //             video.play().catch(function(e) { console.log(e); });
//   //           });
//   //         } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
//   //           video.src = src;
//   //           video.addEventListener('loadedmetadata', function() { video.play(); });
//   //         }
//   //       }
//   //       loadNewVideo('${_currentModifiedUrl ?? widget.videoUrl}');
//   //     </script>
//   //   </body>
//   //   </html>
//   // """;
//   // }



//   String _getHtmlString() {
//     return """
//     <!DOCTYPE html>
//     <html>
//     <head>
//       <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
//       <style>
//         * { margin: 0; padding: 0; box-sizing: border-box; }
//         body {
//           background: #000;
//           width: 100vw;
//           height: 100vh;
//           overflow: hidden;
//           -webkit-tap-highlight-color: transparent;
//         }
//         #wrapper {
//           position: absolute;
//           top: 0px; left: 0px; right: 0px; bottom: 0px;
//           transition: top 0.3s ease, left 0.3s ease, right 0.3s ease, bottom 0.3s ease;
//         }
//         video {
//           width: 100%; height: 100%;
//           object-fit: contain; 
//           background: transparent;
//           outline: none; border: none;
//         }
//         video::-webkit-media-controls { display: none !important; }
//         video::-webkit-media-controls-enclosure { display: none !important; }
//       </style>
//       <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
//     </head>
//     <body>
//       <div id="wrapper">
//         <video id="video" autoplay playsinline></video>
//       </div>
//       <script>
//         var video = document.getElementById('video');
//         var wrapper = document.getElementById('wrapper');
//         var hls;

//         function setVideoBounds(left, top, right, bottom) {
//            wrapper.style.left = left + "px";
//            wrapper.style.top = top + "px";
//            wrapper.style.right = right + "px";
//            wrapper.style.bottom = bottom + "px";
//         }

//         function sendState() {
//           var state = { position: video.currentTime * 1000, duration: video.duration ? video.duration * 1000 : 0, isPlaying: !video.paused, isBuffering: video.readyState < 3 };
//           window.flutter_inappwebview.callHandler('videoState', state);
//         }

//         // --- UPDATED EVENT LISTENERS FOR PERFECT RAINBOW SYNC ---
//         video.addEventListener('timeupdate', sendState);
//         video.addEventListener('play', sendState);
//         video.addEventListener('pause', sendState);
//         video.addEventListener('waiting', sendState);
//         video.addEventListener('playing', sendState);
//         video.addEventListener('loadstart', sendState);
//         video.addEventListener('loadeddata', sendState);
//         video.addEventListener('stalled', sendState);
//         video.addEventListener('canplay', sendState);
//         // --------------------------------------------------------

//         function loadNewVideo(src) {
//           if (Hls.isSupported()) {
//             if (hls) hls.destroy();
//             hls = new Hls();
//             hls.loadSource(src);
//             hls.attachMedia(video);
//             hls.on(Hls.Events.MANIFEST_PARSED, function() {
//               if (hls.levels && hls.levels.length > 0) { hls.currentLevel = hls.levels.length - 1; }
//               video.play().catch(function(e) { console.log(e); });
//             });
//           } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
//             video.src = src;
//             video.addEventListener('loadedmetadata', function() { video.play(); });
//           }
//         }
//         loadNewVideo('${_currentModifiedUrl ?? widget.videoUrl}');
//       </script>
//     </body>
//     </html>
//   """;
//   }

//   void _focusAndScrollToInitialItem() {
//     if (_isDisposing) return;
//     if (!mounted ||
//         focusNodes.isEmpty ||
//         _focusedIndex < 0 ||
//         _focusedIndex >= focusNodes.length) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!mounted || _isDisposing) return;
//         FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//       });
//       return;
//     }
//     _scrollToFocusedItem();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted || _isDisposing) return;
//       if (widget.liveStatus == false) {
//         FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//       } else {
//         FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//       }
//     });
//   }

//   void _changeFocusAndScroll(int newIndex) {
//     if (newIndex < 0 || newIndex >= widget.channelList.length || _isDisposing)
//       return;
//     setState(() {
//       _focusedIndex = newIndex;
//     });
//     _scrollToFocusedItem();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted || _isDisposing) return;
//       FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//     });
//   }

//   void _scrollToFocusedItem() {
//     if (_isDisposing) return;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted ||
//           _isDisposing ||
//           _focusedIndex < 0 ||
//           !_scrollController.hasClients ||
//           _focusedIndex >= focusNodes.length) return;
//       final screenhgt = MediaQuery.of(context).size.height;
//       final double itemHeight = (screenhgt * 0.108) + 16.0;
//       final double viewportHeight = screenhgt * 0.88;
//       final double targetOffset = (itemHeight * _focusedIndex) -
//           (viewportHeight / 2) +
//           (itemHeight / 2);
//       final double clampedOffset = targetOffset.clamp(
//           _scrollController.position.minScrollExtent,
//           _scrollController.position.maxScrollExtent);
//       _scrollController.jumpTo(clampedOffset);
//     });
//   }

//   void _resetHideControlsTimer() {
//     _hideControlsTimer?.cancel();
//     if (_isDisposing) return;

//     if (!_controlsVisible) {
//       setState(() {
//         _controlsVisible = true;
//       });

//       // Screen ke exact margins nikalna
//       final double screenwdt = MediaQuery.of(context).size.width;
//       final double screenhgt = MediaQuery.of(context).size.height;

//       final double leftPanelWidth = screenwdt * 0.15;
//       final double topTitleHeight = screenhgt * 0.10;
//       final double bottomBarHeight = screenhgt * 0.15;

//       // --- HEIGHT REDUCTION KE LIYE EXTRA MARGIN ---
//       final double extraVerticalMargin =
//           1.0; // Yahan se height kam/zyada karein

//       final double offsetLeft =
//           widget.channelList.isNotEmpty ? leftPanelWidth : 0.0;
//       final double offsetTop = topTitleHeight + extraVerticalMargin;
//       final double offsetBottom = bottomBarHeight + extraVerticalMargin;
//       final double offsetRight = 16.0;

//       // JavaScript function ko exact boundaries bhejna
//       if (activePlayer == 'WEB') {
//         webViewController?.evaluateJavascript(
//             source:
//                 "if(typeof setVideoBounds === 'function') setVideoBounds($offsetLeft, $offsetTop, $offsetRight, $offsetBottom);");
//       }

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!mounted || _isDisposing) return;
//         if (widget.liveStatus == false || widget.channelList.isEmpty) {
//           FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//         } else {
//           FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//           _scrollToFocusedItem();
//         }
//       });
//     }
//     _startHideControlsTimer();
//   }

//   void _startHideControlsTimer() {
//     _hideControlsTimer?.cancel();
//     if (_isDisposing) return;
//     _hideControlsTimer = Timer(const Duration(seconds: 10), () {
//       if (mounted && !_isDisposing) {
//         setState(() {
//           _controlsVisible = false;
//         });

//         // Controls gayab, toh margins wapas ZERO kar do (Full Screen)
//         if (activePlayer == 'WEB') {
//           webViewController?.evaluateJavascript(
//               source:
//                   "if(typeof setVideoBounds === 'function') setVideoBounds(0, 0, 0, 0);");
//         }

//         FocusScope.of(context).requestFocus(_mainFocusNode);
//       }
//     });
//   }

//   String _formatDuration(Duration duration) {
//     if (duration.isNegative) duration = Duration.zero;
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//   }

//   String _getFormattedName(dynamic channel) {
//     String name = "";
//     try {
//       name = channel.name?.toString() ?? "";
//     } catch (_) {
//       try {
//         name = channel['name']?.toString() ?? "";
//       } catch (_) {}
//     }
//     String? cNo;
//     try {
//       cNo = channel.channel_number?.toString();
//     } catch (_) {
//       try {
//         cNo = channel.channelNumber?.toString();
//       } catch (_) {
//         try {
//           cNo = channel['channel_number']?.toString() ??
//               channel['channelNumber']?.toString();
//         } catch (_) {
//           cNo = null;
//         }
//       }
//     }
//     if (cNo != null && cNo.trim().isNotEmpty && cNo != "null")
//       return "${cNo.trim()}. $name";
//     return name;
//   }

//   void _safeDispose() {
//     if (_isDisposing) return;
//     _isDisposing = true;
//     _hideControlsTimer?.cancel();
//     _seekTimer?.cancel();
//     _networkCheckTimer?.cancel();
//     _keyRepeatTimer?.cancel();

//     if (vlcController != null) {
//       vlcController!.removeListener(_vlcListener);
//       vlcController!.stop();
//     }
//     KeepScreenOn.turnOff();
//   }

//   @override
//   void dispose() {
//     _safeDispose();
//     _mainFocusNode.dispose();
//     _currentPosition.dispose();
//     _totalDuration.dispose();
//     _previewPosition.dispose();

//     for (var node in focusNodes) {
//       node.dispose();
//     }
//     playPauseButtonFocusNode.dispose();
//     subtitleButtonFocusNode.dispose();
//     _scrollController.dispose();
//     vlcController?.dispose();

//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
// }







// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:keep_screen_on/keep_screen_on.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
// import 'package:mobi_tv_entertainment/components/widgets/small_widgets/rainbow_page.dart';

// class GlobalVariables {
//   static String unUpdatedUrl = '';
//   static Duration position = Duration.zero;
//   static Duration duration = Duration.zero;
  
//   static String banner = '';
//   static String name = '';
//   static bool liveStatus = false;
// }

// class RefreshPageEvent {
//   final String pageId;
//   RefreshPageEvent(this.pageId);
// }

// class VideoScreen extends StatefulWidget {
//   final String videoUrl;
//   final String name;
//   final bool liveStatus;
//   final String updatedAt;
//   final List<dynamic> channelList;
//   final String bannerImageUrl;
//   final int? videoId;
//   final String source;
//   final String streamType;

//   VideoScreen({
//     required this.videoUrl,
//     required this.updatedAt,
//     required this.channelList,
//     required this.bannerImageUrl,
//     required this.videoId,
//     required this.source,
//     required this.streamType,
//     required this.name,
//     required this.liveStatus,
//   });

//   @override
//   _VideoScreenState createState() => _VideoScreenState();
// }

// class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
//   InAppWebViewController? webViewController;
//   VlcPlayerController? vlcController;
//   String activePlayer = 'NONE';

//   final ValueNotifier<Duration> _currentPosition = ValueNotifier(Duration.zero);
//   final ValueNotifier<Duration> _totalDuration = ValueNotifier(Duration.zero);
//   final ValueNotifier<Duration> _previewPosition = ValueNotifier(Duration.zero);
//   Timer? _keyRepeatTimer;
//   DateTime _lastKeyRepeatTime = DateTime.now();
//   final FocusNode _mainFocusNode = FocusNode();

//   bool _isVideoInitialized = false;
//   bool _isPlaying = false;
//   bool _isBuffering = true;
//   bool _loadingVisible = true;
//   bool _controlsVisible = true;
//   String? _currentModifiedUrl;
//   bool _isSeeking = false;

//   Timer? _hideControlsTimer;
//   int _focusedIndex = 0;
//   List<FocusNode> focusNodes = [];
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode playPauseButtonFocusNode = FocusNode();
//   final FocusNode subtitleButtonFocusNode = FocusNode();

//   bool _isScrubbing = false;
//   int _accumulatedSeekForward = 0;
//   int _accumulatedSeekBackward = 0;
//   Timer? _seekTimer;
//   final int _seekDuration = 5;
//   final int _seekDelay = 800;

//   Map<int, String> _spuTracks = {};
//   int _currentSpuTrack = -1;
//   bool _hasFetchedSubtitles = false;

//   Timer? _networkCheckTimer;
//   bool _wasDisconnected = false;
//   bool _isAttemptingResume = false;
//   DateTime _lastPlayingTime = DateTime.now();
//   Duration _lastPositionCheck = Duration.zero;
//   int _stallCounter = 0;
//   bool _hasStartedPlaying = false;
//   bool _isUserPaused = false;

//   Map<String, Uint8List> _bannerCache = {};
//   bool _isDisposing = false;
//   final String localImage = "";

//   final InAppWebViewSettings settings = InAppWebViewSettings(
//     userAgent:
//         "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
//     allowsInlineMediaPlayback: true,
//     mediaPlaybackRequiresUserGesture: false,
//     javaScriptEnabled: true,
//     useHybridComposition: false,
//     transparentBackground: true,
//     hardwareAcceleration: true,
//     supportZoom: false,
//     displayZoomControls: false,
//     builtInZoomControls: false,
//     disableHorizontalScroll: true,
//     disableVerticalScroll: true,
//   );

//   Future<String> _getSecureUrlSafe(String rawUrl) async {
//     try {
//       return await SecureUrlService.getSecureUrl(rawUrl, expirySeconds: 10);
//     } catch (e) {
//       print("Secure URL fetch failed, falling back to raw URL: $e");
//       return rawUrl;
//     }
//   }

//   Uint8List _getCachedImage(String base64String) {
//     try {
//       if (!_bannerCache.containsKey(base64String)) {
//         if (_bannerCache.length >= 50) {
//           _bannerCache.remove(_bannerCache.keys.first);
//         }
//         _bannerCache[base64String] = base64Decode(base64String.split(',').last);
//       }
//       return _bannerCache[base64String]!;
//     } catch (e) {
//       return Uint8List.fromList([0, 0, 0, 0]);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     KeepScreenOn.turnOn();

//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

//     _focusedIndex = widget.channelList.indexWhere(
//       (channel) => channel.id.toString() == widget.videoId.toString(),
//     );
//     _focusedIndex = (_focusedIndex >= 0) ? _focusedIndex : 0;

//     focusNodes = List.generate(
//       widget.channelList.length,
//       (index) => FocusNode(),
//     );

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       _focusAndScrollToInitialItem();
//       String initialTarget =
//           (widget.streamType.trim().toLowerCase() == 'custom') ? 'WEB' : 'VLC';

//       String secureUrl = await _getSecureUrlSafe(widget.videoUrl);
//       await _switchPlayerSafely(initialTarget, secureUrl);
//     });

//     _startHideControlsTimer();
//     _startNetworkMonitor();
//     _startPositionUpdater();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.inactive ||
//         state == AppLifecycleState.paused) {
//       if (activePlayer == 'VLC') vlcController?.pause();
//       if (activePlayer == 'WEB')
//         webViewController?.evaluateJavascript(
//             source: "document.getElementById('video').pause();");
//     } else if (state == AppLifecycleState.resumed) {
//       if (!_isUserPaused) {
//         if (activePlayer == 'VLC') vlcController?.play();
//         if (activePlayer == 'WEB')
//           webViewController?.evaluateJavascript(
//               source: "document.getElementById('video').play();");
//       }
//     }
//   }

//   void _startNetworkMonitor() {
//     _networkCheckTimer?.cancel();
//     _networkCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
//       if (_isDisposing) return;
//       bool isConnected = await _isInternetAvailable();
//       if (!isConnected && !_wasDisconnected) {
//         _wasDisconnected = true;
//       } else if (isConnected && _wasDisconnected) {
//         _wasDisconnected = false;
//         _onNetworkReconnected();
//       }
//     });
//   }

//   Future<bool> _isInternetAvailable() async {
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } catch (_) {
//       return false;
//     }
//   }

//   Future<void> _onNetworkReconnected() async {
//     if (_currentModifiedUrl == null || _isDisposing) return;
//     try {
//       if (widget.liveStatus == true) {
//         await _attemptResumeLiveStream();
//       } else {
//         if (activePlayer == 'VLC' && vlcController != null) {
//           await vlcController!.play();
//         } else if (activePlayer == 'WEB' && webViewController != null) {
//           await webViewController!.evaluateJavascript(
//               source: "document.getElementById('video').play();");
//         }
//       }
//     } catch (e) {
//       print("Critical error during reconnection: $e");
//     }
//   }

//   Future<void> _attemptResumeLiveStream() async {
//     if (!mounted ||
//         _isAttemptingResume ||
//         widget.liveStatus == false ||
//         _currentModifiedUrl == null ||
//         _isDisposing) {
//       return;
//     }

//     setState(() {
//       _isAttemptingResume = true;
//       _loadingVisible = true;
//     });

//     try {
//       String newSecureUrl = await _getSecureUrlSafe(widget.videoUrl);

//       await _switchPlayerSafely(activePlayer, newSecureUrl);

//       _lastPlayingTime = DateTime.now();
//       _stallCounter = 0;
//       _isUserPaused = false;
//     } catch (e) {
//       print("Error: Recovery failed: $e");
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isAttemptingResume = false;
//         });
//       }
//     }
//   }

//   void _startPositionUpdater() {
//     Timer.periodic(const Duration(seconds: 2), (_) {
//       if (!mounted || _isScrubbing || _isAttemptingResume || _isDisposing)
//         return;

//       if (widget.liveStatus == true && _hasStartedPlaying && !_isUserPaused) {
//         if (_lastPositionCheck != Duration.zero &&
//             _currentPosition.value == _lastPositionCheck) {
//           _stallCounter++;
//         } else {
//           _stallCounter = 0;
//         }

//         // Fast Original Logic (approx 6 seconds stall detection)
//         if (_stallCounter >= 3) {
//           _attemptResumeLiveStream();
//           _stallCounter = 0;
//         }
//         _lastPositionCheck = _currentPosition.value;
//       }
//     });
//   }

//   String _buildVlcUrl(String baseUrl) {
//     final String networkCaching = "network-caching=60000";
//     final String liveCaching = "live-caching=30000";
//     final String fileCaching = "file-caching=20000";
//     final String rtspTcp = "rtsp-tcp";
//     return widget.liveStatus == true
//         ? '$baseUrl?$networkCaching&$liveCaching&$fileCaching&$rtspTcp'
//         : '$baseUrl?$networkCaching&$fileCaching&$rtspTcp';
//   }

//   Future<void> _initVlcPlayer(String baseUrl) async {
//     if (_isDisposing) return;

//     if (vlcController != null) {
//       vlcController!.removeListener(_vlcListener);
//       await vlcController!.stop();
//       await vlcController!.dispose();
//       vlcController = null;
//     }

//     _lastPlayingTime = DateTime.now();
//     _stallCounter = 0;
//     _hasStartedPlaying = false;
//     _hasFetchedSubtitles = false;

//     vlcController = VlcPlayerController.network(
//       _buildVlcUrl(baseUrl),
//       hwAcc: HwAcc.auto,
//       autoPlay: true,
//       options: VlcPlayerOptions(
//         http: VlcHttpOptions([
//           ':http-user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
//         ]),
//         video: VlcVideoOptions([
//           VlcVideoOptions.dropLateFrames(true),
//           VlcVideoOptions.skipFrames(true),
//         ]),
//       ),
//     );
//     vlcController!.addListener(_vlcListener);
//     if (mounted) setState(() {});
//   }

//   Future<void> _fetchSubtitles() async {
//     // VLC को वीडियो के अंदर से सबटाइटल ट्रैक ढूँढने के लिए 2 सेकंड का समय दें
//     await Future.delayed(const Duration(seconds: 2));
    
//     if (vlcController != null && vlcController!.value.isInitialized) {
//       // वीडियो से सारे सबटाइटल ट्रैक्स निकालें
//       final tracks = await vlcController!.getSpuTracks();
//       // अभी कौन सा सबटाइटल चल रहा है, उसकी ID निकालें
//       final current = await vlcController!.getSpuTrack() ?? -1;
      
//       print("📝 [DEBUG-SUBTITLES] Total Subtitle Tracks Found: ${tracks.length}");
      
//       if (tracks.isEmpty) {
//         print("⚠️ [DEBUG-SUBTITLES] इस वीडियो में कोई इनबिल्ट सबटाइटल नहीं है!");
//       } else {
//         print("✅ [DEBUG-SUBTITLES] Available Subtitles: $tracks");
        
//         if (current == -1) {
//           print("🔴 [DEBUG-SUBTITLES] सबटाइटल मौजूद हैं, लेकिन अभी OFF हैं (ID: $current).");
//         } else {
//           print("🟢 [DEBUG-SUBTITLES] सबटाइटल ON हैं! Currently Active ID: $current");
//         }
//       }

//       if (mounted) {
//         setState(() {
//           _spuTracks = tracks;
//           _currentSpuTrack = current;
//           _hasFetchedSubtitles = true;
//         });
//       }
//     }
//   }

//   void _vlcListener() {
//     if (!mounted || vlcController == null || _isDisposing) return;
//     final value = vlcController!.value;
//     final PlayingState playingState = value.playingState;

//     if (widget.liveStatus == true && !_isAttemptingResume) {
//       if (playingState == PlayingState.playing) {
//         _lastPlayingTime = DateTime.now();
//         if (!_hasStartedPlaying) _hasStartedPlaying = true;
//         if (!_hasFetchedSubtitles) _fetchSubtitles();
//       } else if (playingState == PlayingState.buffering && _hasStartedPlaying) {
//         if (DateTime.now().difference(_lastPlayingTime) > const Duration(seconds: 8)) {
//           _attemptResumeLiveStream();
//         }
//       } else if (playingState == PlayingState.error) {
//         _attemptResumeLiveStream();
//       } else if ((playingState == PlayingState.stopped || playingState == PlayingState.ended) && _hasStartedPlaying) {
//         if (DateTime.now().difference(_lastPlayingTime) > const Duration(seconds: 5)) {
//           _attemptResumeLiveStream();
//         }
//       }
//     } else if (playingState == PlayingState.paused) {
//       if (_isUserPaused) {
//         _lastPlayingTime = DateTime.now();
//       } else {
//         if (DateTime.now().difference(_lastPlayingTime) > const Duration(seconds: 5)) {
//           if (widget.liveStatus == true) {
//              _attemptResumeLiveStream();
//           } else {
//              _onNetworkReconnected(); 
//           }
//           _lastPlayingTime = DateTime.now();
//         }
//       }
//     } else if (playingState == PlayingState.playing && widget.liveStatus == false) {
//       if (!_hasFetchedSubtitles) _fetchSubtitles();
//     }

//     _currentPosition.value = value.position;
//     _totalDuration.value = value.duration;

//     bool needsRebuild = false;
//     if (_isPlaying != value.isPlaying) {
//       _isPlaying = value.isPlaying;
//       needsRebuild = true;
//     }
//     if (_isBuffering != value.isBuffering) {
//       _isBuffering = value.isBuffering;
//       needsRebuild = true;
//     }
//     if (!_isVideoInitialized && value.isInitialized) {
//       _isVideoInitialized = true;
//       needsRebuild = true;
//     }

//     bool newLoadingVisible = _isBuffering ||
//         playingState == PlayingState.initializing ||
//         _isAttemptingResume;
//     if (_isPlaying && !_isBuffering) newLoadingVisible = false;

//     if (_loadingVisible != newLoadingVisible) {
//       _loadingVisible = newLoadingVisible;
//       needsRebuild = true;
//     }

//     if (needsRebuild && mounted) setState(() {});
//   }

//   Future<void> _switchPlayerSafely(String targetPlayerType, String secureUrl) async {
//     if (_isDisposing) return;

//     setState(() {
//       _loadingVisible = true;
//       _isVideoInitialized = false;
//     });

//     if (activePlayer == 'VLC' && vlcController != null) {
//       vlcController!.removeListener(_vlcListener);
//       await vlcController!.stop();
//       await vlcController!.dispose();
//       vlcController = null;
//     }
//     webViewController = null;

//     setState(() {
//       activePlayer = 'NONE';
//     });
//     await Future.delayed(const Duration(milliseconds: 600));
//     if (_isDisposing) return;

//     _currentModifiedUrl = secureUrl;
//     setState(() {
//       activePlayer = targetPlayerType;
//     });

//     if (targetPlayerType == 'WEB') {
//       if (webViewController != null) {
//         await webViewController!.evaluateJavascript(
//             source: "loadNewVideo('$_currentModifiedUrl');");
//       }
//     } else if (targetPlayerType == 'VLC') {
//       await _initVlcPlayer(_currentModifiedUrl!);
//     }
//   }

//   Future<void> _onItemTap(int index) async {
//     if (!mounted || _isDisposing) return;
//     setState(() {
//       _focusedIndex = index;
//     });

//     var selectedChannel = widget.channelList[index];
//     String typeFromData = widget.streamType;

//     if (selectedChannel is Map) {
//       typeFromData = selectedChannel['stream_type']?.toString() ??
//           selectedChannel['streamType']?.toString() ??
//           widget.streamType;
//     } else {
//       try {
//         typeFromData = selectedChannel.stream_type?.toString() ?? typeFromData;
//       } catch (_) {
//         try {
//           typeFromData = selectedChannel.streamType?.toString() ?? typeFromData;
//         } catch (_) {}
//       }
//     }

//     String targetPlayer =
//         (typeFromData.trim().toLowerCase() == 'custom') ? 'WEB' : 'VLC';
//     String rawUrl = "";

//     if (selectedChannel is Map) {
//       rawUrl = selectedChannel['url']?.toString() ?? "";
//     } else {
//       try {
//         rawUrl = selectedChannel.url?.toString() ?? "";
//       } catch (_) {}
//     }

//     if (rawUrl.isEmpty) return;

//     String secureUrl = await _getSecureUrlSafe(rawUrl);

//     if (_isDisposing) return;
//     await _switchPlayerSafely(targetPlayer, secureUrl);

//     _scrollToFocusedItem();
//     _resetHideControlsTimer();
//   }

//   bool _handleKeyEvent(KeyEvent event) {
//     if (_isDisposing) return false;

//     if (event is KeyDownEvent ||
//         event is RawKeyDownEvent ||
//         event is KeyRepeatEvent) {
//       if (!_controlsVisible) {
//         _resetHideControlsTimer();
//         return true;
//       }

//       _resetHideControlsTimer();

//       switch (event.logicalKey) {
//         case LogicalKeyboardKey.escape:
//         case LogicalKeyboardKey.browserBack:
//           return false;

//         case LogicalKeyboardKey.arrowUp:
//           if (event is KeyRepeatEvent) {
//             final now = DateTime.now();
//             if (now.difference(_lastKeyRepeatTime).inMilliseconds < 300)
//               return true;
//             _lastKeyRepeatTime = now;

//             if (!playPauseButtonFocusNode.hasFocus &&
//                 !subtitleButtonFocusNode.hasFocus) {
//               if (_focusedIndex > 0) _changeFocusAndScroll(_focusedIndex - 1);
//             }
//             return true;
//           }
//           if (subtitleButtonFocusNode.hasFocus) {
//             FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//           } else if (playPauseButtonFocusNode.hasFocus) {
//             if (widget.liveStatus == false && widget.channelList.isNotEmpty) {
//               FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//             }
//           } else if (_focusedIndex > 0) {
//             _changeFocusAndScroll(_focusedIndex - 1);
//           }
//           return true;

//         case LogicalKeyboardKey.arrowDown:
//           if (event is KeyRepeatEvent) {
//             final now = DateTime.now();
//             if (now.difference(_lastKeyRepeatTime).inMilliseconds < 300)
//               return true;
//             _lastKeyRepeatTime = now;

//             if (!playPauseButtonFocusNode.hasFocus &&
//                 !subtitleButtonFocusNode.hasFocus) {
//               if (_focusedIndex < widget.channelList.length - 1) {
//                 _changeFocusAndScroll(_focusedIndex + 1);
//               }
//             }
//             return true;
//           }
//           // Focus Subtitles only if it's VOD
//           if (playPauseButtonFocusNode.hasFocus &&
//               widget.liveStatus == false &&
//               activePlayer == 'VLC') {
//             FocusScope.of(context).requestFocus(subtitleButtonFocusNode);
//           } else if (_focusedIndex < widget.channelList.length - 1) {
//             _changeFocusAndScroll(_focusedIndex + 1);
//           }
//           return true;

//         case LogicalKeyboardKey.arrowRight:
//           if (widget.liveStatus == false) _seekForward();
//           return true;

//         case LogicalKeyboardKey.arrowLeft:
//           if (widget.liveStatus == false) _seekBackward();
//           if (playPauseButtonFocusNode.hasFocus &&
//               widget.channelList.isNotEmpty) {
//             FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//           }
//           return true;

//         case LogicalKeyboardKey.select:
//         case LogicalKeyboardKey.enter:
//         case LogicalKeyboardKey.mediaPlayPause:
//           if (event is KeyRepeatEvent) return true;
//           if (subtitleButtonFocusNode.hasFocus) {
//             _showSubtitleMenu();
//             return true;
//           }
//           if (widget.liveStatus == false) {
//             _togglePlayPause();
//           } else {
//             if (playPauseButtonFocusNode.hasFocus ||
//                 widget.channelList.isEmpty) {
//               _togglePlayPause();
//             } else {
//               _onItemTap(_focusedIndex);
//             }
//           }
//           return true;

//         default:
//           return false;
//       }
//     }
//     return false;
//   }

//   void _togglePlayPause() {
//     if (_isDisposing) return;
//     if (activePlayer == 'WEB' && webViewController != null) {
//       webViewController!.evaluateJavascript(source: """
//         var v = document.getElementById('video');
//         if (v.paused) { v.play(); } else { v.pause(); }
//       """);
//       setState(() {
//         _isPlaying = !_isPlaying;
//         _isUserPaused = !_isPlaying;
//       });
//       _lastPlayingTime = DateTime.now();
//     } else if (activePlayer == 'VLC' && vlcController != null) {
//       if (vlcController!.value.isPlaying) {
//         vlcController!.pause();
//         setState(() {
//           _isUserPaused = true;
//           _isPlaying = false;
//         });
//       } else {
//         vlcController!.play();
//         setState(() {
//           _isUserPaused = false;
//           _isPlaying = true;
//         });
//         _lastPlayingTime = DateTime.now();
//         _stallCounter = 0;
//       }
//     }
//     FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//     _resetHideControlsTimer();
//   }

//   Future<void> _seekToPosition(Duration position) async {
//     if (_isSeeking || _isDisposing) return;
//     _isSeeking = true;
//     try {
//       if (activePlayer == 'WEB' && webViewController != null) {
//         double seconds = position.inMilliseconds / 1000.0;
//         await webViewController!.evaluateJavascript(
//             source:
//                 "document.getElementById('video').currentTime = $seconds; document.getElementById('video').play();");
//       } else if (activePlayer == 'VLC' && vlcController != null) {
//         await vlcController!.seekTo(position);
//         await vlcController!.play();
//       }
//     } catch (e) {
//       print("Error during seek: $e");
//     } finally {
//       await Future.delayed(const Duration(milliseconds: 500));
//       _isSeeking = false;
//     }
//   }

//   void _seekForward() {
//     if (_totalDuration.value <= Duration.zero || _isDisposing) return;

//     _accumulatedSeekForward += _seekDuration;
//     final newPosition =
//         _currentPosition.value + Duration(seconds: _accumulatedSeekForward);

//     setState(() {
//       _previewPosition.value = newPosition > _totalDuration.value
//           ? _totalDuration.value
//           : newPosition;
//     });

//     _seekTimer?.cancel();
//     _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
//       if (_isDisposing) return;
//       _seekToPosition(_previewPosition.value).then((_) {
//         if (mounted && !_isDisposing) {
//           setState(() {
//             _accumulatedSeekForward = 0;
//           });
//         }
//       });
//     });
//   }

//   void _seekBackward() {
//     if (_totalDuration.value <= Duration.zero || _isDisposing) return;

//     _accumulatedSeekBackward += _seekDuration;
//     final newPosition =
//         _currentPosition.value - Duration(seconds: _accumulatedSeekBackward);

//     setState(() {
//       _previewPosition.value =
//           newPosition > Duration.zero ? newPosition : Duration.zero;
//     });

//     _seekTimer?.cancel();
//     _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
//       if (_isDisposing) return;
//       _seekToPosition(_previewPosition.value).then((_) {
//         if (mounted && !_isDisposing) {
//           setState(() {
//             _accumulatedSeekBackward = 0;
//           });
//         }
//       });
//     });
//   }

//   void _onScrubStart(DragStartDetails details, BoxConstraints constraints) {
//     if (_totalDuration.value <= Duration.zero || _isDisposing) return;
//     _resetHideControlsTimer();
//     setState(() {
//       _isScrubbing = true;
//       _accumulatedSeekForward = 1;
//     });
//     final double progress =
//         (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
//     _previewPosition.value = _totalDuration.value * progress;
//   }

//   void _onScrubUpdate(DragUpdateDetails details, BoxConstraints constraints) {
//     if (!_isScrubbing || _totalDuration.value <= Duration.zero || _isDisposing)
//       return;
//     _resetHideControlsTimer();
//     final double progress =
//         (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
//     _previewPosition.value = _totalDuration.value * progress;
//   }

//   void _onScrubEnd(DragEndDetails details) {
//     if (!_isScrubbing || _isDisposing) return;
//     _seekToPosition(_previewPosition.value).then((_) {
//       if (mounted && !_isDisposing) {
//         setState(() {
//           _accumulatedSeekForward = 0;
//           _isScrubbing = false;
//         });
//       }
//     });
//     _resetHideControlsTimer();
//   }

//   void _showSubtitleMenu() {
//     _hideControlsTimer?.cancel();

//     showDialog(
//         context: context,
//         builder: (context) {
//           final size = MediaQuery.of(context).size;
//           int focusedIndex =
//               _spuTracks.keys.toList().indexOf(_currentSpuTrack) + 1;
//           if (_currentSpuTrack == -1) focusedIndex = 0;

//           final ScrollController dialogScrollController = ScrollController();
//           final List<MapEntry<int, String>> tracksList =
//               _spuTracks.entries.toList();

//           return StatefulBuilder(builder: (context, setDialogState) {
//             return Align(
//               alignment: Alignment.bottomLeft,
//               child: Padding(
//                 padding: EdgeInsets.only(
//                     left: size.width * 0.03, bottom: size.height * 0.18),
//                 child: Material(
//                   color: Colors.transparent,
//                   child: Container(
//                     width: size.width * 0.35,
//                     height: size.height * 0.4,
//                     decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.9),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.white24, width: 1),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.5),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           ),
//                         ]),
//                     child: Column(
//                       children: [
//                         const Padding(
//                           padding: EdgeInsets.symmetric(
//                               vertical: 12.0, horizontal: 16.0),
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text("Select Subtitle",
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16)),
//                           ),
//                         ),
//                         const Divider(color: Colors.white24, height: 1),
//                         Expanded(
//                           child: _spuTracks.isEmpty
//                               ? const Padding(
//                                   padding: EdgeInsets.all(16.0),
//                                   child: Text("No subtitles available",
//                                       style: TextStyle(color: Colors.white70)),
//                                 )
//                               : ListView.builder(
//                                   controller: dialogScrollController,
//                                   padding: EdgeInsets.zero,
//                                   itemCount: tracksList.length + 1,
//                                   itemBuilder: (context, index) {
//                                     final isOffOption = index == 0;
//                                     final trackId = isOffOption
//                                         ? -1
//                                         : tracksList[index - 1].key;
//                                     final trackName = isOffOption
//                                         ? "Off"
//                                         : tracksList[index - 1].value;

//                                     final isSelected =
//                                         _currentSpuTrack == trackId;
//                                     final isFocused = focusedIndex == index;

//                                     return Focus(
//                                       autofocus: isSelected,
//                                       onFocusChange: (hasFocus) {
//                                         if (hasFocus) {
//                                           setDialogState(
//                                               () => focusedIndex = index);

//                                           const double itemHeight = 48.0;
//                                           final double viewportHeight =
//                                               (size.height * 0.4) - 48.0;
//                                           final double targetOffset =
//                                               (itemHeight * index) -
//                                                   (viewportHeight / 2) +
//                                                   (itemHeight / 2);

//                                           final maxScroll =
//                                               dialogScrollController
//                                                   .position.maxScrollExtent;
//                                           final double clampedOffset =
//                                               targetOffset.clamp(
//                                                   0.0,
//                                                   maxScroll > 0
//                                                       ? maxScroll
//                                                       : 0.0);

//                                           dialogScrollController.animateTo(
//                                               clampedOffset,
//                                               duration: const Duration(
//                                                   milliseconds: 200),
//                                               curve: Curves.easeInOut);
//                                         }
//                                       },
//                                       onKey: (node, event) {
//                                         if (event is RawKeyDownEvent &&
//                                             (event.logicalKey ==
//                                                     LogicalKeyboardKey.select ||
//                                                 event.logicalKey ==
//                                                     LogicalKeyboardKey.enter)) {
//                                           vlcController?.setSpuTrack(trackId);
//                                           setState(() {
//                                             _currentSpuTrack = trackId;
//                                           });
//                                           Navigator.pop(context);
//                                           return KeyEventResult.handled;
//                                         }
//                                         return KeyEventResult.ignored;
//                                       },
//                                       child: GestureDetector(
//                                         onTap: () {
//                                           vlcController?.setSpuTrack(trackId);
//                                           setState(() {
//                                             _currentSpuTrack = trackId;
//                                           });
//                                           Navigator.pop(context);
//                                         },
//                                         child: Container(
//                                           color: isFocused
//                                               ? Colors.purple.withOpacity(0.8)
//                                               : Colors.transparent,
//                                           height: 48.0,
//                                           child: Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 16.0),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 Text(trackName,
//                                                     style: const TextStyle(
//                                                         color: Colors.white,
//                                                         fontSize: 14)),
//                                                 if (isSelected)
//                                                   const Icon(Icons.check,
//                                                       color: Colors.white,
//                                                       size: 20),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           });
//         }).then((_) {
//       FocusScope.of(context).requestFocus(subtitleButtonFocusNode);
//       _resetHideControlsTimer();
//     });
//   }

//   void _focusAndScrollToInitialItem() {
//     if (_isDisposing) return;
//     if (!mounted ||
//         focusNodes.isEmpty ||
//         _focusedIndex < 0 ||
//         _focusedIndex >= focusNodes.length) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!mounted || _isDisposing) return;
//         FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//       });
//       return;
//     }
//     _scrollToFocusedItem();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted || _isDisposing) return;
//       if (widget.liveStatus == false) {
//         FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//       } else {
//         FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//       }
//     });
//   }

//   void _changeFocusAndScroll(int newIndex) {
//     if (newIndex < 0 || newIndex >= widget.channelList.length || _isDisposing)
//       return;
//     setState(() {
//       _focusedIndex = newIndex;
//     });
//     _scrollToFocusedItem();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted || _isDisposing) return;
//       FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//     });
//   }

//   void _scrollToFocusedItem() {
//     if (_isDisposing) return;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted ||
//           _isDisposing ||
//           _focusedIndex < 0 ||
//           !_scrollController.hasClients ||
//           _focusedIndex >= focusNodes.length) return;
//       final screenhgt = MediaQuery.of(context).size.height;
//       final double itemHeight = (screenhgt * 0.18) + 16.0;
//       final double targetOffset = (itemHeight * _focusedIndex) - 40.0;
//       final double clampedOffset = targetOffset.clamp(
//           _scrollController.position.minScrollExtent,
//           _scrollController.position.maxScrollExtent);
//       _scrollController.jumpTo(clampedOffset);
//     });
//   }

//   void _resetHideControlsTimer() {
//     _hideControlsTimer?.cancel();
//     if (_isDisposing) return;

//     if (!_controlsVisible) {
//       setState(() {
//         _controlsVisible = true;
//       });

//       final double screenwdt = MediaQuery.of(context).size.width;
//       final double screenhgt = MediaQuery.of(context).size.height;

//       final double leftPanelWidth = screenwdt * 0.22;
//       final double topTitleHeight = screenhgt * 0.10;
//       final double bottomBarHeight = screenhgt * 0.15;
//       final double extraVerticalMargin = 1.0; 

//       final double offsetLeft =
//           widget.channelList.isNotEmpty ? leftPanelWidth : 0.0;
//       final double offsetTop = topTitleHeight + extraVerticalMargin;
//       final double offsetBottom = bottomBarHeight + extraVerticalMargin;
//       final double offsetRight = 16.0;

//       if (activePlayer == 'WEB') {
//         webViewController?.evaluateJavascript(
//             source:
//                 "if(typeof setVideoBounds === 'function') setVideoBounds($offsetLeft, $offsetTop, $offsetRight, $offsetBottom);");
//       }

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!mounted || _isDisposing) return;
//         if (widget.liveStatus == false || widget.channelList.isEmpty) {
//           FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//         } else {
//           FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//           _scrollToFocusedItem();
//         }
//       });
//     }
//     _startHideControlsTimer();
//   }

//   void _startHideControlsTimer() {
//     _hideControlsTimer?.cancel();
//     if (_isDisposing) return;
//     _hideControlsTimer = Timer(const Duration(seconds: 10), () {
//       if (mounted && !_isDisposing) {
//         setState(() {
//           _controlsVisible = false;
//         });

//         if (activePlayer == 'WEB') {
//           webViewController?.evaluateJavascript(
//               source:
//                   "if(typeof setVideoBounds === 'function') setVideoBounds(0, 0, 0, 0);");
//         }

//         FocusScope.of(context).requestFocus(_mainFocusNode);
//       }
//     });
//   }

//   String _formatDuration(Duration duration) {
//     if (duration.isNegative) duration = Duration.zero;
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//   }

//   String _getFormattedName(dynamic channel) {
//     String name = "";
//     try {
//       name = channel.name?.toString() ?? "";
//     } catch (_) {
//       try {
//         name = channel['name']?.toString() ?? "";
//       } catch (_) {}
//     }
//     String? cNo;
//     try {
//       cNo = channel.channel_number?.toString();
//     } catch (_) {
//       try {
//         cNo = channel.channelNumber?.toString();
//       } catch (_) {
//         try {
//           cNo = channel['channel_number']?.toString() ??
//               channel['channelNumber']?.toString();
//         } catch (_) {
//           cNo = null;
//         }
//       }
//     }
//     if (cNo != null && cNo.trim().isNotEmpty && cNo != "null")
//       return "${cNo.trim()}. $name";
//     return name;
//   }

//   void _safeDispose() {
//     if (_isDisposing) return;
//     _isDisposing = true;

//     _hideControlsTimer?.cancel();
//     _networkCheckTimer?.cancel();
//     _seekTimer?.cancel();

//     focusNodes.forEach((node) => node.dispose());
//     playPauseButtonFocusNode.dispose();
//     subtitleButtonFocusNode.dispose();
//     _scrollController.dispose();

//     try {
//       if (vlcController != null) {
//         vlcController?.removeListener(_vlcListener);
//         vlcController?.stop();
//         vlcController?.dispose();
//         vlcController = null;
//       }
//     } catch (e) {
//       print("Warning during VLC controller disposal: $e");
//     }

//     KeepScreenOn.turnOff();
//     WidgetsBinding.instance.removeObserver(this);
//   }

//   @override
//   void dispose() {
//     _safeDispose();
//     _mainFocusNode.dispose();
//     _currentPosition.dispose();
//     _totalDuration.dispose();
//     _previewPosition.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double screenwdt = MediaQuery.of(context).size.width;
//     final double screenhgt = MediaQuery.of(context).size.height;
//     final double bottomBarHeight = screenhgt * 0.15;
//     final double topTitleHeight = screenhgt * 0.10;
//     final double leftPanelWidth = screenwdt * 0.22; 
//     final double extraVerticalMargin = 1.0; 

//     final bool hasChannels = widget.channelList.isNotEmpty;

//     final double offsetLeft =
//         (_controlsVisible && hasChannels) ? leftPanelWidth : 0.0;
//     final double offsetRight = _controlsVisible ? 16.0 : 0.0;
//     final double offsetTop =
//         _controlsVisible ? topTitleHeight : 0.0;
//     final double offsetBottom =
//         _controlsVisible ? bottomBarHeight : 0.0;

//     return PopScope(
//       canPop: true,
//       onPopInvokedWithResult: (bool didPop, dynamic result) {
//         if (didPop) _safeDispose();
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: Focus(
//           focusNode: _mainFocusNode,
//           autofocus: true,
//           onKeyEvent: (node, event) {
//             bool isHandled = _handleKeyEvent(event);
//             return isHandled ? KeyEventResult.handled : KeyEventResult.ignored;
//           },
//           child: GestureDetector(
//             onTap: _resetHideControlsTimer,
//             child: Stack(
//               children: [
//                 Positioned.fill(
//                   child: Stack(
//                     children: [
//                       if (activePlayer == 'WEB')
//                         ExcludeFocus(
//                           child: Container(
//                             color: Colors.black,
//                             width: screenwdt,
//                             height: screenhgt,
//                             child: InAppWebView(
//                               key: const ValueKey('WEB_Player'),
//                               initialData: InAppWebViewInitialData(
//                                 data: _getHtmlString(),
//                                 mimeType: "text/html",
//                                 encoding: "utf-8",
//                               ),
//                               initialSettings: settings,
//                               onWebViewCreated: (controller) {
//                                 webViewController = controller;
//                                 controller.addJavaScriptHandler(
//                                     handlerName: 'videoState',
//                                     callback: (args) {
//                                       if (!mounted ||
//                                           _isDisposing ||
//                                           args.isEmpty) return;
//                                       var state = args[0];

//                                       _currentPosition.value = Duration(
//                                           milliseconds:
//                                               state['position'].toInt());
//                                       _totalDuration.value = Duration(
//                                           milliseconds:
//                                               state['duration'].toInt());

//                                       bool newIsPlaying = state['isPlaying'];
//                                       bool newIsBuffering =
//                                           state['isBuffering'];
//                                       bool needsRebuild = false;

//                                       if (!_isVideoInitialized) {
//                                         _isVideoInitialized = true;
//                                         needsRebuild = true;
//                                       }
//                                       if (_isPlaying != newIsPlaying) {
//                                         _isPlaying = newIsPlaying;
//                                         needsRebuild = true;
//                                       }
//                                       if (_isBuffering != newIsBuffering) {
//                                         _isBuffering = newIsBuffering;
//                                         needsRebuild = true;
//                                       }

//                                       bool newLoadingVisible = newIsBuffering;
//                                       if (newIsPlaying && !newIsBuffering) {
//                                         newLoadingVisible = false;
//                                         _lastPlayingTime = DateTime.now();
//                                       }

//                                       if (_loadingVisible !=
//                                           newLoadingVisible) {
//                                         _loadingVisible = newLoadingVisible;
//                                         needsRebuild = true;
//                                       }

//                                       if (needsRebuild && mounted)
//                                         setState(() {});
//                                     });
//                               },
//                             ),
//                           ),
//                         ),

//                       if (activePlayer == 'VLC' && vlcController != null)
//                         AnimatedPositioned(
//                           duration: const Duration(milliseconds: 300),
//                           curve: Curves.easeInOut,
//                           left: offsetLeft,
//                           top: offsetTop,
//                           right: offsetRight,
//                           bottom: offsetBottom,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.black,
//                               borderRadius: BorderRadius.circular(
//                                   _controlsVisible ? 12.0 : 0.0),
//                               boxShadow: _controlsVisible
//                                   ? [
//                                       const BoxShadow(
//                                           color: Colors.black54,
//                                           blurRadius: 20,
//                                           spreadRadius: 5)
//                                     ]
//                                   : [],
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(
//                                   _controlsVisible ? 12.0 : 0.0),
//                               child: LayoutBuilder(
//                                 builder: (context, constraints) {
//                                   final screenWidth = constraints.maxWidth;
//                                   final screenHeight = constraints.maxHeight;

//                                   double videoWidth =
//                                       vlcController!.value.size.width;
//                                   double videoHeight =
//                                       vlcController!.value.size.height;

//                                   if (videoWidth <= 0 || videoHeight <= 0) {
//                                     videoWidth = 16.0;
//                                     videoHeight = 9.0;
//                                   }

//                                   final videoRatio = videoWidth / videoHeight;
//                                   final screenRatio =
//                                       screenWidth > 0 && screenHeight > 0
//                                           ? screenWidth / screenHeight
//                                           : 16 / 9;

//                                   double scaleXInner = 1.0;
//                                   double scaleYInner = 1.0;

//                                   if (videoRatio < screenRatio) {
//                                     scaleXInner = screenRatio / videoRatio;
//                                   } else {
//                                     scaleYInner = videoRatio / screenRatio;
//                                   }

//                                   const double maxScaleLimit = 1.35;
//                                   if (scaleXInner > maxScaleLimit)
//                                     scaleXInner = maxScaleLimit;
//                                   if (scaleYInner > maxScaleLimit)
//                                     scaleYInner = maxScaleLimit;

//                                   return Container(
//                                     width: screenWidth,
//                                     height: screenHeight,
//                                     color: Colors.black,
//                                     child: Center(
//                                       child: Transform.scale(
//                                         scaleX: scaleXInner,
//                                         scaleY: scaleYInner,
//                                         alignment: Alignment.center,
//                                         child: VlcPlayer(
//                                           key: const ValueKey('VLC_PLAYER'),
//                                           controller: vlcController!,
//                                           aspectRatio: videoRatio,
//                                           placeholder: const Center(
//                                             child: RainbowPage(
//                                               backgroundColor: Colors.transparent,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),

//                 if (_loadingVisible ||
//                     !_isVideoInitialized ||
//                     _isAttemptingResume ||
//                     (_isBuffering && !_loadingVisible))
//                   Container(
//                     color: _loadingVisible || !_isVideoInitialized
//                         ? Colors.black54
//                         : Colors.transparent,
//                     child: Center(
//                       child: RainbowPage(
//                         backgroundColor: _loadingVisible || !_isVideoInitialized
//                             ? Colors.black
//                             : Colors.transparent,
//                       ),
//                     ),
//                   ),

//                 if (_controlsVisible)
//                   Positioned(
//                     top: 0,
//                     left: widget.channelList.isNotEmpty ? leftPanelWidth : 0.0,
//                     right: 0,
//                     height: topTitleHeight,
//                     child: Container(
//                       color: Colors.black.withOpacity(0.5),
//                       padding: const EdgeInsets.only(top: 8.0),
//                       alignment: Alignment.topCenter,
//                       child: ShaderMask(
//                         shaderCallback: (bounds) {
//                           return const LinearGradient(
//                             colors: [
//                               Color(0xFF9B28F8),
//                               Color(0xFFE62B1E),
//                               Color.fromARGB(255, 53, 255, 53)
//                             ],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ).createShader(
//                               Rect.fromLTWH(0, 0, bounds.width, bounds.height));
//                         },
//                         child: Text(
//                           (widget.channelList.isNotEmpty &&
//                                   _focusedIndex >= 0 &&
//                                   _focusedIndex < widget.channelList.length)
//                               ? _getFormattedName(
//                                   widget.channelList[_focusedIndex])
//                               : widget.name,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1.0,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                   ),

//                 if (_controlsVisible && widget.channelList.isNotEmpty)
//                   _buildChannelList(screenwdt, screenhgt, leftPanelWidth),

//                 if (_controlsVisible)
//                   _buildControls(screenwdt, bottomBarHeight, leftPanelWidth),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildChannelList(double screenwdt, double screenhgt, double leftPanelWidth) {
//     return Positioned(
//       top: screenhgt * 0.02,
//       bottom: screenhgt * 0.1,
//       left: 0, 
//       width: leftPanelWidth, 
//       child: Container(
//         color: Colors.black.withOpacity(0.85), 
//         child: ListView.builder(
//           controller: _scrollController,
//           itemCount: widget.channelList.length,
//           itemBuilder: (context, index) {
//             final channel = widget.channelList[index];
//             final String channelId = channel.id?.toString() ?? '';
//             final bool isBase64 =
//                 channel.banner?.startsWith('data:image') ?? false;
//             final bool isFocused = _focusedIndex == index;

//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//               child: Focus(
//                 focusNode: focusNodes[index],
//                 autofocus: widget.liveStatus == true && isFocused,
//                 onFocusChange: (hasFocus) {
//                   if (hasFocus) {
//                     _scrollToFocusedItem();
//                   }
//                 },
//                 child: GestureDetector(
//                   onTap: () {
//                     _onItemTap(index);
//                     _resetHideControlsTimer();
//                   },
//                   child: Container(
//                     width: screenwdt * 0.3, 
//                     height: screenhgt * 0.18, 
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: isFocused && !playPauseButtonFocusNode.hasFocus && !subtitleButtonFocusNode.hasFocus
//                             ? const Color.fromARGB(211, 155, 40, 248)
//                             : Colors.transparent,
//                         width: 5.0,
//                       ),
//                       borderRadius: BorderRadius.circular(10),
//                       color: isFocused ? Colors.black26 : Colors.transparent,
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(6),
//                       child: Stack(
//                         children: [
//                           Positioned.fill(
//                             child: Opacity(
//                               opacity: 0.6,
//                               child: isBase64
//                                   ? Image.memory(
//                                       _bannerCache[channelId] ??
//                                           _getCachedImage(
//                                               channel.banner ?? localImage),
//                                       fit: BoxFit.cover,
//                                       errorBuilder: (context, e, s) =>
//                                           Image.asset('assets/placeholder.png'),
//                                     )
//                                   : CachedNetworkImage(
//                                       imageUrl: channel.banner ?? localImage,
//                                       fit: BoxFit.cover,
//                                       errorWidget: (context, url, error) =>
//                                           Image.asset('assets/placeholder.png'),
//                                     ),
//                             ),
//                           ),
//                           if (isFocused)
//                             Positioned.fill(
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     begin: Alignment.topCenter,
//                                     end: Alignment.bottomCenter,
//                                     colors: [
//                                       Colors.transparent,
//                                       Colors.black.withOpacity(0.9),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           if (isFocused)
//                             Positioned(
//                               left: 8,
//                               bottom: 8,
//                               right: 8,
//                               child: FittedBox(
//                                 fit: BoxFit.scaleDown,
//                                 alignment: Alignment.centerLeft,
//                                 child: Text(
//                                   _getFormattedName(channel),
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildControls(
//       double screenwdt, double bottomBarHeight, double leftPanelWidth) {
//     final Duration currentPosition =
//         _accumulatedSeekForward > 0 || _accumulatedSeekBackward > 0 || _isScrubbing
//             ? _previewPosition.value
//             : _currentPosition.value;
//     final Duration totalDuration = _totalDuration.value;

//     return Positioned(
//       bottom: 0,
//       left: widget.channelList.isNotEmpty ? leftPanelWidth : 0.0,
//       right: 0,
//       height: bottomBarHeight,
//       child: Opacity(
//         opacity: _controlsVisible ? 1 : 0.0,
//         child: IgnorePointer(
//           ignoring: !_controlsVisible,
//           child: Container(
//             color: Colors.black54,
//             padding: const EdgeInsets.symmetric(vertical: 4.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SizedBox(width: screenwdt * 0.03),
//                     Container(
//                       color: playPauseButtonFocusNode.hasFocus
//                           ? const Color.fromARGB(200, 16, 62, 99)
//                           : Colors.transparent,
//                       child: Focus(
//                         focusNode: playPauseButtonFocusNode,
//                         onFocusChange: (hasFocus) => setState(() {}),
//                         child: InkWell(
//                           onTap: _togglePlayPause,
//                           child: Container(
//                             width: 28, 
//                             height: 28,
//                             child: ClipRect(
//                               child: Transform.scale(
//                                 scale: 1.25, 
//                                 child: Image.asset(
//                                   (_isPlaying)
//                                       ? 'assets/pause.png'
//                                       : 'assets/play.png',
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     if (widget.liveStatus == false)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                         child: ListenableBuilder(
//                             listenable: Listenable.merge(
//                                 [_currentPosition, _previewPosition]),
//                             builder: (context, child) {
//                               final Duration displayPosition =
//                                   _accumulatedSeekForward > 0 ||
//                                           _accumulatedSeekBackward > 0 ||
//                                           _isScrubbing
//                                       ? _previewPosition.value
//                                       : _currentPosition.value;
//                               return Text(
//                                 _formatDuration(displayPosition),
//                                 style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold),
//                               );
//                             }),
//                       ),
//                     Expanded(
//                       child: LayoutBuilder(
//                         builder: (context, constraints) {
//                           return GestureDetector(
//                             onHorizontalDragStart: (details) =>
//                                 _onScrubStart(details, constraints),
//                             onHorizontalDragUpdate: (details) =>
//                                 _onScrubUpdate(details, constraints),
//                             onHorizontalDragEnd: (details) => _onScrubEnd(details),
//                             child: Container(
//                               height: 30,
//                               color: Colors.transparent,
//                               child: Center(
//                                 child: ListenableBuilder(
//                                     listenable: Listenable.merge([
//                                       _currentPosition,
//                                       _previewPosition,
//                                       _totalDuration
//                                     ]),
//                                     builder: (context, child) {
//                                       final Duration displayPosition =
//                                           _accumulatedSeekForward > 0 ||
//                                                   _accumulatedSeekBackward > 0 ||
//                                                   _isScrubbing
//                                               ? _previewPosition.value
//                                               : _currentPosition.value;
//                                       return _buildBeautifulProgressBar(
//                                           displayPosition, _totalDuration.value);
//                                     }),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     if (widget.liveStatus == false)
//                       Padding(
//                         padding: const EdgeInsets.only(left: 8.0, right: 12.0),
//                         child: ValueListenableBuilder<Duration>(
//                             valueListenable: _totalDuration,
//                             builder: (context, totalDuration, child) {
//                               return Text(
//                                 _formatDuration(totalDuration),
//                                 style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold),
//                               );
//                             }),
//                       ),
//                     if (widget.liveStatus == true)
//                       Padding(
//                         padding: const EdgeInsets.only(left: 8.0),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: const [
//                             Icon(Icons.circle, color: Colors.red, size: 15),
//                             SizedBox(width: 5),
//                             Text('Live',
//                                 style: TextStyle(
//                                     color: Colors.red,
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold)),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),

//                 if (widget.liveStatus == false && activePlayer == 'VLC') ...[
//                   const SizedBox(height: 4), 
//                   Padding(
//                     padding:  EdgeInsets.only(left: screenwdt * 0.02),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: subtitleButtonFocusNode.hasFocus
//                             ? const Color.fromARGB(200, 16, 62, 99)
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(6),
//                         border: Border.all(
//                             color: subtitleButtonFocusNode.hasFocus
//                                 ? Colors.purple
//                                 : Colors.transparent,
//                             width: 2),
//                       ),
//                       child: Focus(
//                         focusNode: subtitleButtonFocusNode,
//                         onFocusChange: (hasFocus) => setState(() {}),
//                         child: InkWell(
//                           onTap: _showSubtitleMenu,
//                           child: const Padding(
//                             padding:
//                                 EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.subtitles, color: Colors.white, size: 18),
//                                 SizedBox(width: 4),
//                                 Text("Subtitles",
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 14)),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBeautifulProgressBar(
//       Duration displayPosition, Duration totalDuration) {
//     final totalDurationMs = totalDuration.inMilliseconds.toDouble();

//     if (totalDurationMs <= 0 || widget.liveStatus == true) {
//       return Container(
//         padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//         child: Container(
//             height: 8,
//             decoration: BoxDecoration(
//                 color: Colors.grey[800],
//                 borderRadius: BorderRadius.circular(4))),
//       );
//     }

//     double playedProgress =
//         (displayPosition.inMilliseconds / totalDurationMs).clamp(0.0, 1.0);
//     double bufferedProgress = (playedProgress + 0.005).clamp(0.0, 1.0); 

//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//       child: Container(
//         height: 8,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(4),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 4,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(4),
//           child: Stack(
//             children: [
//               Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.grey[800]!, Colors.grey[700]!],
//                   ),
//                 ),
//               ),
//               FractionallySizedBox(
//                 widthFactor: bufferedProgress,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.grey[600]!, Colors.grey[500]!],
//                     ),
//                   ),
//                 ),
//               ),
//               FractionallySizedBox(
//                 widthFactor: playedProgress,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Color(0xFF9B28F8),
//                         Color(0xFFE62B1E),
//                         Color(0xFFFF6B35),
//                       ],
//                       stops: [0.0, 0.7, 1.0],
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Color(0xFF9B28F8).withOpacity(0.6),
//                         blurRadius: 8,
//                         spreadRadius: 1,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _getHtmlString() {
//     return """
//     <!DOCTYPE html>
//     <html>
//     <head>
//       <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
//       <style>
//         * { margin: 0; padding: 0; box-sizing: border-box; }
//         body {
//           background: #000;
//           width: 100vw;
//           height: 100vh;
//           overflow: hidden;
//           -webkit-tap-highlight-color: transparent;
//         }
//         #wrapper {
//           position: absolute;
//           top: 0px; left: 0px; right: 0px; bottom: 0px;
//           transition: top 0.3s ease, left 0.3s ease, right 0.3s ease, bottom 0.3s ease;
//         }
//         video {
//           width: 100%; height: 100%;
//           object-fit: contain; 
//           background: transparent;
//           outline: none; border: none;
//         }
//         video::-webkit-media-controls { display: none !important; }
//         video::-webkit-media-controls-enclosure { display: none !important; }
//       </style>
//       <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
//     </head>
//     <body>
//       <div id="wrapper">
//         <video id="video" autoplay playsinline></video>
//       </div>
//       <script>
//         var video = document.getElementById('video');
//         var wrapper = document.getElementById('wrapper');
//         var hls;

//         function setVideoBounds(left, top, right, bottom) {
//            wrapper.style.left = left + "px";
//            wrapper.style.top = top + "px";
//            wrapper.style.right = right + "px";
//            wrapper.style.bottom = bottom + "px";
//         }

//         function sendState() {
//           var state = { position: video.currentTime * 1000, duration: video.duration ? video.duration * 1000 : 0, isPlaying: !video.paused, isBuffering: video.readyState < 3 };
//           window.flutter_inappwebview.callHandler('videoState', state);
//         }

//         video.addEventListener('timeupdate', sendState);
//         video.addEventListener('play', sendState);
//         video.addEventListener('pause', sendState);
//         video.addEventListener('waiting', sendState);
//         video.addEventListener('playing', sendState);
//         video.addEventListener('loadstart', sendState);
//         video.addEventListener('loadeddata', sendState);
//         video.addEventListener('stalled', sendState);
//         video.addEventListener('canplay', sendState);

//         function loadNewVideo(src) {
//           if (Hls.isSupported()) {
//             if (hls) hls.destroy();
//             hls = new Hls();
//             hls.loadSource(src);
//             hls.attachMedia(video);
//             hls.on(Hls.Events.MANIFEST_PARSED, function() {
//               if (hls.levels && hls.levels.length > 0) { hls.currentLevel = hls.levels.length - 1; }
//               video.play().catch(function(e) { console.log(e); });
//             });
//           } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
//             video.src = src;
//             video.addEventListener('loadedmetadata', function() { video.play(); });
//           }
//         }
//         loadNewVideo('${_currentModifiedUrl ?? widget.videoUrl}');
//       </script>
//     </body>
//     </html>
//   """;
//   }
// }






// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:keep_screen_on/keep_screen_on.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
// import 'package:mobi_tv_entertainment/components/widgets/small_widgets/rainbow_page.dart';

// class VideoScreen extends StatefulWidget {
//   final String videoUrl;
//   final String name;
//   final bool liveStatus;
//   final String updatedAt;
//   final List<dynamic> channelList;
//   final String bannerImageUrl;
//   final int? videoId;
//   final String source;
//   final String streamType;

//   VideoScreen({
//     required this.videoUrl,
//     required this.updatedAt,
//     required this.channelList,
//     required this.bannerImageUrl,
//     required this.videoId,
//     required this.source,
//     required this.streamType,
//     required this.name,
//     required this.liveStatus,
//   });

//   @override
//   _VideoScreenState createState() => _VideoScreenState();
// }

// class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
//   // --- Hybrid Player Controllers ---
//   InAppWebViewController? webViewController;
//   VlcPlayerController? vlcController;
//   String activePlayer = 'NONE';

//   // --- High-Frequency Update Notifiers (Prevents Lag) ---
//   final ValueNotifier<Duration> _currentPosition = ValueNotifier(Duration.zero);
//   final ValueNotifier<Duration> _totalDuration = ValueNotifier(Duration.zero);
//   final ValueNotifier<Duration> _previewPosition = ValueNotifier(Duration.zero);
//   Timer? _keyRepeatTimer;
//   DateTime _lastKeyRepeatTime = DateTime.now();
//   final FocusNode _mainFocusNode = FocusNode();

//   // --- UI State Variables ---
//   bool _isVideoInitialized = false;
//   bool _isPlaying = false;
//   bool _isBuffering = true;
//   bool _loadingVisible = true;
//   bool _controlsVisible = true;
//   String? _currentModifiedUrl;
//   bool _isSeeking = false;

//   // --- Focus Variables ---
//   Timer? _hideControlsTimer;
//   int _focusedIndex = 0;
//   List<FocusNode> focusNodes = [];
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode playPauseButtonFocusNode = FocusNode();
//   final FocusNode subtitleButtonFocusNode = FocusNode();

//   // --- Seek Variables ---
//   bool _isScrubbing = false;
//   int _accumulatedSeekForward = 0;
//   int _accumulatedSeekBackward = 0;
//   Timer? _seekTimer;
//   Duration _baseSeekPosition = Duration.zero;
//   final int _seekDuration = 5;
//   final int _seekDelay = 800;

//   // --- Subtitle Variables ---
//   Map<int, String> _spuTracks = {};
//   int _currentSpuTrack = -1;
//   bool _hasFetchedSubtitles = false;

//   // --- Network & Stall Recovery Variables ---
//   Timer? _networkCheckTimer;
//   bool _wasDisconnected = false;
//   bool _isAttemptingResume = false;
//   DateTime _lastPlayingTime = DateTime.now();
//   Duration _lastPositionCheck = Duration.zero;
//   int _stallCounter = 0;
//   bool _hasStartedPlaying = false;
//   bool _isUserPaused = false;

//   Map<String, Uint8List> _bannerCache = {};
//   bool _isDisposing = false;
//   final String localImage = "";

//   final InAppWebViewSettings settings = InAppWebViewSettings(
//     userAgent:
//         "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
//     allowsInlineMediaPlayback: true,
//     mediaPlaybackRequiresUserGesture: false,
//     javaScriptEnabled: true,
//     useHybridComposition: false,
//     transparentBackground: true,
//     hardwareAcceleration: true,
//     supportZoom: false,
//     displayZoomControls: false,
//     builtInZoomControls: false,
//     disableHorizontalScroll: true,
//     disableVerticalScroll: true,
//   );

//   Uint8List _getCachedImage(String base64String) {
//     try {
//       if (!_bannerCache.containsKey(base64String)) {
//         if (_bannerCache.length >= 50) {
//           _bannerCache.remove(_bannerCache.keys.first);
//         }
//         _bannerCache[base64String] = base64Decode(base64String.split(',').last);
//       }
//       return _bannerCache[base64String]!;
//     } catch (e) {
//       return Uint8List.fromList([0, 0, 0, 0]);
//     }
//   }

//   Future<String> _getSecureUrlSafe(String rawUrl) async {
//     try {
//       return await SecureUrlService.getSecureUrl(rawUrl, expirySeconds: 10);
//     } catch (e) {
//       print("Secure URL fetch failed, falling back to raw URL: $e");
//       return rawUrl;
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     KeepScreenOn.turnOn();

//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

//     _focusedIndex = widget.channelList.indexWhere(
//       (channel) => channel.id.toString() == widget.videoId.toString(),
//     );
//     _focusedIndex = (_focusedIndex >= 0) ? _focusedIndex : 0;

//     focusNodes = List.generate(
//       widget.channelList.length,
//       (index) => FocusNode(),
//     );

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       _focusAndScrollToInitialItem();
//       String initialTarget =
//           (widget.streamType.trim().toLowerCase() == 'custom') ? 'WEB' : 'VLC';

//       String secureUrl = await _getSecureUrlSafe(widget.videoUrl);

//       await _switchPlayerSafely(initialTarget, secureUrl);
//     });

//     _startHideControlsTimer();
//     _startNetworkMonitor();
//     _startPositionUpdater();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.inactive ||
//         state == AppLifecycleState.paused) {
//       if (activePlayer == 'VLC') vlcController?.pause();
//       if (activePlayer == 'WEB')
//         webViewController?.evaluateJavascript(
//             source: "document.getElementById('video').pause();");
//     } else if (state == AppLifecycleState.resumed) {
//       if (!_isUserPaused) {
//         if (activePlayer == 'VLC') vlcController?.play();
//         if (activePlayer == 'WEB')
//           webViewController?.evaluateJavascript(
//               source: "document.getElementById('video').play();");
//       }
//     }
//   }

//   void _startNetworkMonitor() {
//     _networkCheckTimer?.cancel();
//     _networkCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
//       if (_isDisposing) return;
//       bool isConnected = await _isInternetAvailable();
//       if (!isConnected && !_wasDisconnected) {
//         _wasDisconnected = true;
//       } else if (isConnected && _wasDisconnected) {
//         _wasDisconnected = false;
//         _onNetworkReconnected();
//       }
//     });
//   }

//   Future<bool> _isInternetAvailable() async {
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } catch (_) {
//       return false;
//     }
//   }

//   Future<void> _onNetworkReconnected() async {
//     if (_currentModifiedUrl == null || _isDisposing) return;
//     try {
//       if (widget.liveStatus == true) {
//         await _attemptResumeLiveStream();
//       } else {
//         if (activePlayer == 'VLC' && vlcController != null) {
//           await vlcController!.play();
//         } else if (activePlayer == 'WEB' && webViewController != null) {
//           await webViewController!.evaluateJavascript(
//               source: "document.getElementById('video').play();");
//         }
//       }
//     } catch (e) {
//       print("Critical error during reconnection: $e");
//     }
//   }

//   Future<void> _attemptResumeLiveStream() async {
//     if (!mounted ||
//         _isAttemptingResume ||
//         widget.liveStatus == false ||
//         _currentModifiedUrl == null ||
//         _isDisposing) {
//       return;
//     }

//     setState(() {
//       _isAttemptingResume = true;
//       _loadingVisible = true;
//     });

//     try {
//       String newSecureUrl = await _getSecureUrlSafe(widget.videoUrl);

//       await _switchPlayerSafely(activePlayer, newSecureUrl);

//       _lastPlayingTime = DateTime.now();
//       _stallCounter = 0;
//       _isUserPaused = false;
//     } catch (e) {
//       print("Error: Recovery failed: $e");
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isAttemptingResume = false;
//         });
//       }
//     }
//   }

//   void _startPositionUpdater() {
//     Timer.periodic(const Duration(seconds: 2), (_) {
//       if (!mounted || _isScrubbing || _isAttemptingResume || _isDisposing)
//         return;

//       if (widget.liveStatus == true && _hasStartedPlaying && !_isUserPaused) {
//         if (_lastPositionCheck != Duration.zero &&
//             _currentPosition.value == _lastPositionCheck) {
//           _stallCounter++;
//         } else {
//           _stallCounter = 0;
//         }

//         if (_stallCounter >= 3) {
//           _attemptResumeLiveStream();
//           _stallCounter = 0;
//         }
//         _lastPositionCheck = _currentPosition.value;
//       }
//     });
//   }

//   String _buildVlcUrl(String baseUrl) {
//     final String networkCaching = "network-caching=300";
//     final String liveCaching = "live-caching=300";
//     final String fileCaching = "file-caching=200";
//     final String rtspTcp = "rtsp-tcp";
//     return widget.liveStatus == true
//         ? '$baseUrl?$networkCaching&$liveCaching&$fileCaching&$rtspTcp'
//         : '$baseUrl?$networkCaching&$fileCaching&$rtspTcp';
//   }

//   Future<void> _initVlcPlayer(String baseUrl) async {
//     if (_isDisposing) return;

//     if (vlcController != null) {
//       vlcController!.removeListener(_vlcListener);
//       await vlcController!.stop();
//       await vlcController!.dispose();
//       vlcController = null;
//     }

//     _lastPlayingTime = DateTime.now();
//     _stallCounter = 0;
//     _hasStartedPlaying = false;
//     _hasFetchedSubtitles = false;

//     vlcController = VlcPlayerController.network(
//       _buildVlcUrl(baseUrl),
//       hwAcc: HwAcc.auto,
//       autoPlay: true,
//       options: VlcPlayerOptions(
//         http: VlcHttpOptions([
//           ':http-user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
//         ]),
//         video: VlcVideoOptions([
//           VlcVideoOptions.dropLateFrames(true),
//           VlcVideoOptions.skipFrames(true),
//         ]),
//       ),
//     );
//     vlcController!.addListener(_vlcListener);
//     if (mounted) setState(() {});
//   }

//   Future<void> _fetchSubtitles() async {
//     await Future.delayed(const Duration(seconds: 2));
//     if (vlcController != null && vlcController!.value.isInitialized) {
//       final tracks = await vlcController!.getSpuTracks();
//       final current = await vlcController!.getSpuTrack() ?? -1;
//       if (mounted) {
//         setState(() {
//           _spuTracks = tracks;
//           _currentSpuTrack = current;
//           _hasFetchedSubtitles = true;
//         });
//       }
//     }
//   }

//   void _vlcListener() {
//     if (!mounted || vlcController == null || _isDisposing) return;
//     final value = vlcController!.value;
//     final PlayingState playingState = value.playingState;

//     if (widget.liveStatus == true && !_isAttemptingResume) {
//       if (playingState == PlayingState.playing) {
//         _lastPlayingTime = DateTime.now();
//         if (!_hasStartedPlaying) _hasStartedPlaying = true;
//         if (!_hasFetchedSubtitles) _fetchSubtitles();
//       } else if (playingState == PlayingState.buffering && _hasStartedPlaying) {
//         if (DateTime.now().difference(_lastPlayingTime) >
//             const Duration(seconds: 8)) _attemptResumeLiveStream();
//       } else if (playingState == PlayingState.error) {
//         _attemptResumeLiveStream();
//       } else if ((playingState == PlayingState.stopped ||
//               playingState == PlayingState.ended) &&
//           _hasStartedPlaying) {
//         if (DateTime.now().difference(_lastPlayingTime) >
//             const Duration(seconds: 5)) _attemptResumeLiveStream();
//       }
//     } else if (playingState == PlayingState.paused) {
//       if (_isUserPaused) {
//         _lastPlayingTime = DateTime.now();
//       } else {
//         if (DateTime.now().difference(_lastPlayingTime) >
//             const Duration(seconds: 5)) {
//           if (widget.liveStatus == true) {
//             _attemptResumeLiveStream();
//           } else {
//             _onNetworkReconnected();
//           }
//           _lastPlayingTime = DateTime.now();
//         }
//       }
//     } else if (playingState == PlayingState.playing &&
//         widget.liveStatus == false) {
//       if (!_hasFetchedSubtitles) _fetchSubtitles();
//     }

//     _currentPosition.value = value.position;
//     _totalDuration.value = value.duration;

//     bool needsRebuild = false;
//     if (_isPlaying != value.isPlaying) {
//       _isPlaying = value.isPlaying;
//       needsRebuild = true;
//     }
//     if (_isBuffering != value.isBuffering) {
//       _isBuffering = value.isBuffering;
//       needsRebuild = true;
//     }
//     if (!_isVideoInitialized && value.isInitialized) {
//       _isVideoInitialized = true;
//       needsRebuild = true;
//     }

//     bool newLoadingVisible = _isBuffering ||
//         playingState == PlayingState.initializing ||
//         _isAttemptingResume;
//     if (_isPlaying && !_isBuffering) newLoadingVisible = false;

//     if (_loadingVisible != newLoadingVisible) {
//       _loadingVisible = newLoadingVisible;
//       needsRebuild = true;
//     }

//     if (needsRebuild && mounted) setState(() {});
//   }

//   Future<void> _switchPlayerSafely(
//       String targetPlayerType, String secureUrl) async {
//     if (_isDisposing) return;

//     setState(() {
//       _loadingVisible = true;
//       _isVideoInitialized = false;
//     });

//     if (activePlayer == 'VLC' && vlcController != null) {
//       vlcController!.removeListener(_vlcListener);
//       await vlcController!.stop();
//       await vlcController!.dispose();
//       vlcController = null;
//     }
//     webViewController = null;

//     setState(() {
//       activePlayer = 'NONE';
//     });
//     await Future.delayed(const Duration(milliseconds: 600));
//     if (_isDisposing) return;

//     _currentModifiedUrl = secureUrl;
//     setState(() {
//       activePlayer = targetPlayerType;
//     });

//     if (targetPlayerType == 'WEB') {
//       if (webViewController != null) {
//         await webViewController!.evaluateJavascript(
//             source: "loadNewVideo('$_currentModifiedUrl');");
//       }
//     } else if (targetPlayerType == 'VLC') {
//       await _initVlcPlayer(_currentModifiedUrl!);
//     }
//   }

//   Future<void> _onItemTap(int index) async {
//     if (!mounted || _isDisposing) return;
//     setState(() {
//       _focusedIndex = index;
//     });

//     var selectedChannel = widget.channelList[index];
//     String typeFromData = widget.streamType;

//     if (selectedChannel is Map) {
//       typeFromData = selectedChannel['stream_type']?.toString() ??
//           selectedChannel['streamType']?.toString() ??
//           widget.streamType;
//     } else {
//       try {
//         typeFromData = selectedChannel.stream_type?.toString() ?? typeFromData;
//       } catch (_) {
//         try {
//           typeFromData = selectedChannel.streamType?.toString() ?? typeFromData;
//         } catch (_) {}
//       }
//     }

//     String targetPlayer =
//         (typeFromData.trim().toLowerCase() == 'custom') ? 'WEB' : 'VLC';
//     String rawUrl = "";

//     if (selectedChannel is Map) {
//       rawUrl = selectedChannel['url']?.toString() ?? "";
//     } else {
//       try {
//         rawUrl = selectedChannel.url?.toString() ?? "";
//       } catch (_) {}
//     }

//     if (rawUrl.isEmpty) return;

//     String secureUrl = await _getSecureUrlSafe(rawUrl);

//     if (_isDisposing) return;
//     await _switchPlayerSafely(targetPlayer, secureUrl);

//     _scrollToFocusedItem();
//     _resetHideControlsTimer();
//   }

//   bool _handleKeyEvent(KeyEvent event) {
//     if (_isDisposing) return false;

//     if (event is KeyDownEvent ||
//         event is RawKeyDownEvent ||
//         event is KeyRepeatEvent) {
//       // If controls are hidden, wake up the UI and do nothing else.
//       if (!_controlsVisible) {
//         _resetHideControlsTimer();
//         return true;
//       }

//       _resetHideControlsTimer();

//       switch (event.logicalKey) {
//         case LogicalKeyboardKey.escape:
//         case LogicalKeyboardKey.browserBack:
//           return false;

//         case LogicalKeyboardKey.arrowUp:
//           if (event is KeyRepeatEvent) {
//             // 300ms throttle
//             final now = DateTime.now();
//             if (now.difference(_lastKeyRepeatTime).inMilliseconds < 300)
//               return true;
//             _lastKeyRepeatTime = now;

//             // Sirf channel list par ho tab repeat kaam kare
//             if (!playPauseButtonFocusNode.hasFocus &&
//                 !subtitleButtonFocusNode.hasFocus) {
//               if (_focusedIndex > 0) _changeFocusAndScroll(_focusedIndex - 1);
//             }
//             return true;
//           }
//           // Normal single press
//           if (subtitleButtonFocusNode.hasFocus) {
//             FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//           } else if (playPauseButtonFocusNode.hasFocus) {
//             if (widget.liveStatus == false && widget.channelList.isNotEmpty) {
//               FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//             }
//           } else if (_focusedIndex > 0) {
//             _changeFocusAndScroll(_focusedIndex - 1);
//           }
//           return true;

//         case LogicalKeyboardKey.arrowDown:
//           if (event is KeyRepeatEvent) {
//             // 300ms throttle
//             final now = DateTime.now();
//             if (now.difference(_lastKeyRepeatTime).inMilliseconds < 300)
//               return true;
//             _lastKeyRepeatTime = now;

//             // Sirf channel list par ho tab repeat kaam kare
//             if (!playPauseButtonFocusNode.hasFocus &&
//                 !subtitleButtonFocusNode.hasFocus) {
//               if (_focusedIndex < widget.channelList.length - 1) {
//                 _changeFocusAndScroll(_focusedIndex + 1);
//               }
//             }
//             return true;
//           }
//           // Normal single press
//           if (playPauseButtonFocusNode.hasFocus &&
//               widget.liveStatus == false &&
//               activePlayer == 'VLC') {
//             FocusScope.of(context).requestFocus(subtitleButtonFocusNode);
//           } else if (_focusedIndex < widget.channelList.length - 1) {
//             _changeFocusAndScroll(_focusedIndex + 1);
//           }
//           return true;

//         case LogicalKeyboardKey.arrowRight:
//           if (widget.liveStatus == false) _seekForward();
//           return true;

//         case LogicalKeyboardKey.arrowLeft:
//           if (widget.liveStatus == false) _seekBackward();
//           if (playPauseButtonFocusNode.hasFocus &&
//               widget.channelList.isNotEmpty) {
//             FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//           }
//           return true;

//         case LogicalKeyboardKey.select:
//         case LogicalKeyboardKey.enter:
//         case LogicalKeyboardKey.mediaPlayPause:
//           if (event is KeyRepeatEvent) return true;
//           if (subtitleButtonFocusNode.hasFocus) {
//             _showSubtitleMenu();
//             return true;
//           }
//           if (widget.liveStatus == false) {
//             _togglePlayPause();
//           } else {
//             if (playPauseButtonFocusNode.hasFocus ||
//                 widget.channelList.isEmpty) {
//               _togglePlayPause();
//             } else {
//               _onItemTap(_focusedIndex);
//             }
//           }
//           return true;

//         default:
//           return false;
//       }
//     }
//     return false;
//   }

//   void _togglePlayPause() {
//     if (_isDisposing) return;
//     if (activePlayer == 'WEB' && webViewController != null) {
//       webViewController!.evaluateJavascript(source: """
//         var v = document.getElementById('video');
//         if (v.paused) { v.play(); } else { v.pause(); }
//       """);
//       setState(() {
//         _isPlaying = !_isPlaying;
//         _isUserPaused = !_isPlaying;
//       });
//       _lastPlayingTime = DateTime.now();
//     } else if (activePlayer == 'VLC' && vlcController != null) {
//       if (vlcController!.value.isPlaying) {
//         vlcController!.pause();
//         setState(() {
//           _isUserPaused = true;
//           _isPlaying = false;
//         });
//       } else {
//         vlcController!.play();
//         setState(() {
//           _isUserPaused = false;
//           _isPlaying = true;
//         });
//         _lastPlayingTime = DateTime.now();
//         _stallCounter = 0;
//       }
//     }
//     FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//     _resetHideControlsTimer();
//   }

//   Future<void> _seekToPosition(Duration position) async {
//     if (_isSeeking || _isDisposing) return;
//     _isSeeking = true;
//     try {
//       if (activePlayer == 'WEB' && webViewController != null) {
//         double seconds = position.inMilliseconds / 1000.0;
//         await webViewController!.evaluateJavascript(
//             source:
//                 "document.getElementById('video').currentTime = $seconds; document.getElementById('video').play();");
//       } else if (activePlayer == 'VLC' && vlcController != null) {
//         await vlcController!.seekTo(position);
//         await vlcController!
//             .play(); // Ensures video plays after seeking like the old code
//       }
//     } catch (e) {
//       print("Error during seek: $e");
//     } finally {
//       await Future.delayed(const Duration(milliseconds: 500));
//       _isSeeking = false;
//     }
//   }

//   void _seekForward() {
//     if (_totalDuration.value <= Duration.zero || _isDisposing) return;

//     _accumulatedSeekForward += _seekDuration;
//     final newPosition =
//         _currentPosition.value + Duration(seconds: _accumulatedSeekForward);

//     setState(() {
//       _previewPosition.value = newPosition > _totalDuration.value
//           ? _totalDuration.value
//           : newPosition;
//     });

//     _seekTimer?.cancel();
//     _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
//       if (_isDisposing) return;
//       _seekToPosition(_previewPosition.value).then((_) {
//         if (mounted && !_isDisposing) {
//           setState(() {
//             _accumulatedSeekForward = 0;
//           });
//         }
//       });
//     });
//   }

//   void _seekBackward() {
//     if (_totalDuration.value <= Duration.zero || _isDisposing) return;

//     _accumulatedSeekBackward += _seekDuration;
//     final newPosition =
//         _currentPosition.value - Duration(seconds: _accumulatedSeekBackward);

//     setState(() {
//       _previewPosition.value =
//           newPosition > Duration.zero ? newPosition : Duration.zero;
//     });

//     _seekTimer?.cancel();
//     _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
//       if (_isDisposing) return;
//       _seekToPosition(_previewPosition.value).then((_) {
//         if (mounted && !_isDisposing) {
//           setState(() {
//             _accumulatedSeekBackward = 0;
//           });
//         }
//       });
//     });
//   }

//   void _onScrubStart(DragStartDetails details, BoxConstraints constraints) {
//     if (_totalDuration.value <= Duration.zero || _isDisposing) return;
//     _resetHideControlsTimer();
//     setState(() {
//       _isScrubbing = true;
//       _accumulatedSeekForward =
//           1; // Mimics old code behavior to force UI update
//     });
//     final double progress =
//         (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
//     _previewPosition.value = _totalDuration.value * progress;
//   }

//   void _onScrubUpdate(DragUpdateDetails details, BoxConstraints constraints) {
//     if (!_isScrubbing || _totalDuration.value <= Duration.zero || _isDisposing)
//       return;
//     _resetHideControlsTimer();
//     final double progress =
//         (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
//     _previewPosition.value = _totalDuration.value * progress;
//   }

//   void _onScrubEnd(DragEndDetails details) {
//     if (!_isScrubbing || _isDisposing) return;
//     _seekToPosition(_previewPosition.value).then((_) {
//       if (mounted && !_isDisposing) {
//         setState(() {
//           _accumulatedSeekForward = 0;
//           _isScrubbing = false;
//         });
//       }
//     });
//     _resetHideControlsTimer();
//   }

//   void _showSubtitleMenu() {
//     _hideControlsTimer?.cancel();

//     showDialog(
//         context: context,
//         builder: (context) {
//           final size = MediaQuery.of(context).size;
//           int focusedIndex =
//               _spuTracks.keys.toList().indexOf(_currentSpuTrack) + 1;
//           if (_currentSpuTrack == -1) focusedIndex = 0;

//           final ScrollController dialogScrollController = ScrollController();
//           final List<MapEntry<int, String>> tracksList =
//               _spuTracks.entries.toList();

//           return StatefulBuilder(builder: (context, setDialogState) {
//             return Align(
//               alignment: Alignment.bottomLeft,
//               child: Padding(
//                 padding: EdgeInsets.only(
//                     left: size.width * 0.03, bottom: size.height * 0.18),
//                 child: Material(
//                   color: Colors.transparent,
//                   child: Container(
//                     width: size.width * 0.35,
//                     height: size.height * 0.4,
//                     decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.9),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.white24, width: 1),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.5),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           ),
//                         ]),
//                     child: Column(
//                       children: [
//                         const Padding(
//                           padding: EdgeInsets.symmetric(
//                               vertical: 12.0, horizontal: 16.0),
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text("Select Subtitle",
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16)),
//                           ),
//                         ),
//                         const Divider(color: Colors.white24, height: 1),
//                         Expanded(
//                           child: _spuTracks.isEmpty
//                               ? const Padding(
//                                   padding: EdgeInsets.all(16.0),
//                                   child: Text("No subtitles available",
//                                       style: TextStyle(color: Colors.white70)),
//                                 )
//                               : ListView.builder(
//                                   controller: dialogScrollController,
//                                   padding: EdgeInsets.zero,
//                                   itemCount: tracksList.length + 1,
//                                   itemBuilder: (context, index) {
//                                     final isOffOption = index == 0;
//                                     final trackId = isOffOption
//                                         ? -1
//                                         : tracksList[index - 1].key;
//                                     final trackName = isOffOption
//                                         ? "Off"
//                                         : tracksList[index - 1].value;

//                                     final isSelected =
//                                         _currentSpuTrack == trackId;
//                                     final isFocused = focusedIndex == index;

//                                     return Focus(
//                                       autofocus: isSelected,
//                                       onFocusChange: (hasFocus) {
//                                         if (hasFocus) {
//                                           setDialogState(
//                                               () => focusedIndex = index);

//                                           const double itemHeight = 48.0;
//                                           final double viewportHeight =
//                                               (size.height * 0.4) - 48.0;
//                                           final double targetOffset =
//                                               (itemHeight * index) -
//                                                   (viewportHeight / 2) +
//                                                   (itemHeight / 2);

//                                           final maxScroll =
//                                               dialogScrollController
//                                                   .position.maxScrollExtent;
//                                           final double clampedOffset =
//                                               targetOffset.clamp(
//                                                   0.0,
//                                                   maxScroll > 0
//                                                       ? maxScroll
//                                                       : 0.0);

//                                           dialogScrollController.animateTo(
//                                               clampedOffset,
//                                               duration: const Duration(
//                                                   milliseconds: 200),
//                                               curve: Curves.easeInOut);
//                                         }
//                                       },
//                                       onKey: (node, event) {
//                                         if (event is RawKeyDownEvent &&
//                                             (event.logicalKey ==
//                                                     LogicalKeyboardKey.select ||
//                                                 event.logicalKey ==
//                                                     LogicalKeyboardKey.enter)) {
//                                           vlcController?.setSpuTrack(trackId);
//                                           setState(() {
//                                             _currentSpuTrack = trackId;
//                                           });
//                                           Navigator.pop(context);
//                                           return KeyEventResult.handled;
//                                         }
//                                         return KeyEventResult.ignored;
//                                       },
//                                       child: GestureDetector(
//                                         onTap: () {
//                                           vlcController?.setSpuTrack(trackId);
//                                           setState(() {
//                                             _currentSpuTrack = trackId;
//                                           });
//                                           Navigator.pop(context);
//                                         },
//                                         child: Container(
//                                           color: isFocused
//                                               ? Colors.purple.withOpacity(0.8)
//                                               : Colors.transparent,
//                                           height: 48.0,
//                                           child: Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 16.0),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 Text(trackName,
//                                                     style: const TextStyle(
//                                                         color: Colors.white,
//                                                         fontSize: 14)),
//                                                 if (isSelected)
//                                                   const Icon(Icons.check,
//                                                       color: Colors.white,
//                                                       size: 20),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           });
//         }).then((_) {
//       FocusScope.of(context).requestFocus(subtitleButtonFocusNode);
//       _resetHideControlsTimer();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double screenwdt = MediaQuery.of(context).size.width;
//     final double screenhgt = MediaQuery.of(context).size.height;
//     final double bottomBarHeight = screenhgt * 0.15;
//     final double topTitleHeight = screenhgt * 0.10;
//     final double leftPanelWidth = screenwdt * 0.15;

//     // --- NEW: Extra margin to reduce video height when controls are visible ---
//     final double extraVerticalMargin =
//         1.0; // Isko kam/zyada karke video ki height set kar sakte hain

//     final bool hasChannels = widget.channelList.isNotEmpty;

//     // Smooth bounds calculation
//     final double offsetLeft =
//         (_controlsVisible && hasChannels) ? leftPanelWidth : 0.0;
//     final double offsetRight = _controlsVisible ? 16.0 : 0.0;
//     // Yahan offsetTop aur offsetBottom mein extraVerticalMargin add kiya gaya hai
//     final double offsetTop =
//         _controlsVisible ? (topTitleHeight + extraVerticalMargin) : 0.0;
//     final double offsetBottom =
//         _controlsVisible ? (bottomBarHeight + extraVerticalMargin) : 0.0;

//     final double targetVideoWidth = screenwdt - offsetLeft - offsetRight;
//     final double targetVideoHeight = screenhgt - offsetTop - offsetBottom;

//     return PopScope(
//       canPop: true,
//       onPopInvokedWithResult: (bool didPop, dynamic result) {
//         if (didPop) _safeDispose();
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: Focus(
//           focusNode: _mainFocusNode,
//           autofocus: true,
//           onKeyEvent: (node, event) {
//             bool isHandled = _handleKeyEvent(event);
//             return isHandled ? KeyEventResult.handled : KeyEventResult.ignored;
//           },
//           child: GestureDetector(
//             onTap: _resetHideControlsTimer,
//             child: Stack(
//               children: [
//                 // 1. VIDEO LAYER (Smooth CSS Transform for WEB, AnimatedPositioned for VLC)
//                 Positioned.fill(
//                   child: Stack(
//                     children: [
//                       // WEB PLAYER (Always Full Screen, CSS handles resizing smoothly)
//                       if (activePlayer == 'WEB')
//                         ExcludeFocus(
//                           // Zaroori hai taaki TV remote ka focus webview na churaye
//                           child: Container(
//                             color: Colors.black,
//                             width: screenwdt,
//                             height: screenhgt,
//                             child: InAppWebView(
//                               key: const ValueKey('WEB_Player'),
//                               initialData: InAppWebViewInitialData(
//                                 data: _getHtmlString(),
//                                 mimeType: "text/html",
//                                 encoding: "utf-8",
//                               ),
//                               initialSettings: settings,
//                               onWebViewCreated: (controller) {
//                                 webViewController = controller;
//                                 controller.addJavaScriptHandler(
//                                     handlerName: 'videoState',
//                                     callback: (args) {
//                                       if (!mounted ||
//                                           _isDisposing ||
//                                           args.isEmpty) return;
//                                       var state = args[0];

//                                       _currentPosition.value = Duration(
//                                           milliseconds:
//                                               state['position'].toInt());
//                                       _totalDuration.value = Duration(
//                                           milliseconds:
//                                               state['duration'].toInt());

//                                       bool newIsPlaying = state['isPlaying'];
//                                       bool newIsBuffering =
//                                           state['isBuffering'];
//                                       bool needsRebuild = false;

//                                       if (!_isVideoInitialized) {
//                                         _isVideoInitialized = true;
//                                         needsRebuild = true;
//                                       }
//                                       if (_isPlaying != newIsPlaying) {
//                                         _isPlaying = newIsPlaying;
//                                         needsRebuild = true;
//                                       }
//                                       if (_isBuffering != newIsBuffering) {
//                                         _isBuffering = newIsBuffering;
//                                         needsRebuild = true;
//                                       }

//                                       bool newLoadingVisible = newIsBuffering;
//                                       if (newIsPlaying && !newIsBuffering) {
//                                         newLoadingVisible = false;
//                                         _lastPlayingTime = DateTime.now();
//                                       }

//                                       if (_loadingVisible !=
//                                           newLoadingVisible) {
//                                         _loadingVisible = newLoadingVisible;
//                                         needsRebuild = true;
//                                       }

//                                       if (needsRebuild && mounted)
//                                         setState(() {});
//                                     });
//                               },
//                             ),
//                           ),
//                         ),

//                       // VLC PLAYER (Aapke scaleXInner/scaleYInner logic ke sath)
//                       if (activePlayer == 'VLC' && vlcController != null)
//                         AnimatedPositioned(
//                           duration: const Duration(milliseconds: 300),
//                           curve: Curves.easeInOut,
//                           left: offsetLeft,
//                           top: offsetTop,
//                           // FIX: width aur height ki jagah right aur bottom use kiya hai
//                           right: offsetRight,
//                           bottom: offsetBottom,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.black,
//                               borderRadius: BorderRadius.circular(
//                                   _controlsVisible ? 12.0 : 0.0),
//                               boxShadow: _controlsVisible
//                                   ? [
//                                       const BoxShadow(
//                                           color: Colors.black54,
//                                           blurRadius: 20,
//                                           spreadRadius: 5)
//                                     ]
//                                   : [],
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(
//                                   _controlsVisible ? 12.0 : 0.0),
//                               child: LayoutBuilder(
//                                 builder: (context, constraints) {
//                                   final screenWidth = constraints.maxWidth;
//                                   final screenHeight = constraints.maxHeight;

//                                   double videoWidth =
//                                       vlcController!.value.size.width;
//                                   double videoHeight =
//                                       vlcController!.value.size.height;

//                                   if (videoWidth <= 0 || videoHeight <= 0) {
//                                     videoWidth = 16.0;
//                                     videoHeight = 9.0;
//                                   }

//                                   final videoRatio = videoWidth / videoHeight;
//                                   final screenRatio =
//                                       screenWidth > 0 && screenHeight > 0
//                                           ? screenWidth / screenHeight
//                                           : 16 / 9;

//                                   double scaleXInner = 1.0;
//                                   double scaleYInner = 1.0;

//                                   if (videoRatio < screenRatio) {
//                                     scaleXInner = screenRatio / videoRatio;
//                                   } else {
//                                     scaleYInner = videoRatio / screenRatio;
//                                   }

//                                   const double maxScaleLimit = 1.35;
//                                   if (scaleXInner > maxScaleLimit)
//                                     scaleXInner = maxScaleLimit;
//                                   if (scaleYInner > maxScaleLimit)
//                                     scaleYInner = maxScaleLimit;

//                                   return Container(
//                                     width: screenWidth,
//                                     height: screenHeight,
//                                     color: Colors.black,
//                                     child: Center(
//                                       child: Transform.scale(
//                                         scaleX: scaleXInner,
//                                         scaleY: scaleYInner,
//                                         alignment: Alignment
//                                             .center, // Center se scale hoga
//                                         child: VlcPlayer(
//                                           key: const ValueKey('VLC_PLAYER'),
//                                           controller: vlcController!,
//                                           aspectRatio: videoRatio,
//                                           placeholder: const Center(
//                                             // child:
//                                                 // CircularProgressIndicator(color: Colors.red),
//                       child: RainbowPage(
//                         backgroundColor: 
//                         // _loadingVisible || !_isVideoInitialized
//                         //     ? Colors.black
//                         //     :
//                              Colors.transparent,
//                       ),

                                              
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),

//                 // 2. LOADING LAYER
//                 if (_loadingVisible ||
//                     !_isVideoInitialized ||
//                     _isAttemptingResume ||
//                     (_isBuffering && !_loadingVisible))
//                   Container(
//                     color: _loadingVisible || !_isVideoInitialized
//                         ? Colors.black54
//                         : Colors.transparent,
//                     child: Center(
//                       child: RainbowPage(
//                         backgroundColor: _loadingVisible || !_isVideoInitialized
//                             ? Colors.black
//                             : Colors.transparent,
//                       ),
//                     ),
//                   ),

//                 // 3. TITLE LAYER
//                 if (_controlsVisible)
//                   Positioned(
//                     top: 0,
//                     left: widget.channelList.isNotEmpty ? leftPanelWidth : 0.0,
//                     right: 0,
//                     height: topTitleHeight,
//                     child: Container(
//                       color: Colors.black.withOpacity(0.5),
//                       padding: const EdgeInsets.only(top: 8.0),
//                       alignment: Alignment.topCenter,
//                       child: ShaderMask(
//                         shaderCallback: (bounds) {
//                           return const LinearGradient(
//                             colors: [
//                               Color(0xFF9B28F8),
//                               Color(0xFFE62B1E),
//                               Color.fromARGB(255, 53, 255, 53)
//                             ],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ).createShader(
//                               Rect.fromLTWH(0, 0, bounds.width, bounds.height));
//                         },
//                         child: Text(
//                           (widget.channelList.isNotEmpty &&
//                                   _focusedIndex >= 0 &&
//                                   _focusedIndex < widget.channelList.length)
//                               ? _getFormattedName(
//                                   widget.channelList[_focusedIndex])
//                               : widget.name,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1.0,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                   ),

//                 // 4. CHANNEL LIST
//                 if (_controlsVisible && widget.channelList.isNotEmpty)
//                   Positioned(
//                     left: 0,
//                     top: 0,
//                     bottom: 0,
//                     width: leftPanelWidth,
//                     child: Container(
//                       color: Colors.black.withOpacity(0.85),
//                       padding: const EdgeInsets.only(
//                           top: 20, bottom: 20, left: 10, right: 10),
//                       child: ListView.builder(
//                         controller: _scrollController,
//                         itemCount: widget.channelList.length,
//                         itemBuilder: (context, index) {
//                           final channel = widget.channelList[index];
//                           final String channelId = channel.id?.toString() ?? '';
//                           final bool isBase64 =
//                               channel.banner?.startsWith('data:image') ?? false;
//                           final bool isFocused = _focusedIndex == index;

//                           return Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8.0),
//                             child: Focus(
//                               focusNode: focusNodes[index],
//                               autofocus: widget.liveStatus == true && isFocused,
//                               onFocusChange: (hasFocus) {
//                                 if (hasFocus) _scrollToFocusedItem();
//                               },
//                               child: GestureDetector(
//                                 onTap: () => _onItemTap(index),
//                                 child: Container(
//                                   height: screenhgt * 0.108,
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color: isFocused &&
//                                               !playPauseButtonFocusNode
//                                                   .hasFocus &&
//                                               !subtitleButtonFocusNode.hasFocus
//                                           ? const Color.fromARGB(
//                                               211, 155, 40, 248)
//                                           : Colors.transparent,
//                                       width: 4.0,
//                                     ),
//                                     borderRadius: BorderRadius.circular(8),
//                                     color: isFocused
//                                         ? Colors.white24
//                                         : Colors.transparent,
//                                   ),
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(4),
//                                     child: Stack(
//                                       children: [
//                                         Positioned.fill(
//                                           child: Opacity(
//                                             opacity: 0.8,
//                                             child: isBase64
//                                                 ? Image.memory(
//                                                     _bannerCache[channelId] ??
//                                                         _getCachedImage(
//                                                             channel.banner ??
//                                                                 localImage),
//                                                     fit: BoxFit.fill)
//                                                 : CachedNetworkImage(
//                                                     imageUrl: channel.banner ??
//                                                         localImage,
//                                                     fit: BoxFit.fill,
//                                                     errorWidget: (context, url,
//                                                             error) =>
//                                                         const Icon(Icons.error,
//                                                             color:
//                                                                 Colors.white),
//                                                   ),
//                                           ),
//                                         ),
//                                         if (isFocused)
//                                           Positioned(
//                                             left: 8,
//                                             bottom: 8,
//                                             right: 8,
//                                             child: FittedBox(
//                                               fit: BoxFit.scaleDown,
//                                               alignment: Alignment.centerLeft,
//                                               child: Text(
//                                                 _getFormattedName(channel),
//                                                 style: const TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: 14,
//                                                     fontWeight:
//                                                         FontWeight.bold),
//                                               ),
//                                             ),
//                                           ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),

//                 // 5. BOTTOM CONTROLS
//                 if (_controlsVisible)
//                   _buildControls(screenwdt, bottomBarHeight, leftPanelWidth),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildControls(
//       double screenwdt, double bottomBarHeight, double leftPanelWidth) {
//     return Positioned(
//       bottom: 0,
//       left: widget.channelList.isNotEmpty ? leftPanelWidth : 0.0,
//       right: 0,
//       height: bottomBarHeight,
//       child: Container(
//         color: Colors.black.withOpacity(0.8),
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // --- UPAR WALI ROW (Play/Pause, Time, Progress Bar, Live Indicator) ---
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // 1. Play / Pause Button
//                 Container(
//                   color: playPauseButtonFocusNode.hasFocus
//                       ? const Color.fromARGB(200, 16, 62, 99)
//                       : Colors.transparent,
//                   child: Focus(
//                     focusNode: playPauseButtonFocusNode,
//                     autofocus: widget.liveStatus == false,
//                     onFocusChange: (hasFocus) => setState(() {}),
//                     child: GestureDetector(
//                       onTap: _togglePlayPause,
//                       child: Container(
//                         width: 24,
//                         height: 24,
//                         color: Colors.transparent,
//                         child: ClipRect(
//                           child: Transform.scale(
//                             scale: 1.5,
//                             child: Image.asset(
//                               _isPlaying
//                                   ? 'assets/pause.png'
//                                   : 'assets/play.png',
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) =>
//                                   Icon(
//                                 _isPlaying ? Icons.pause : Icons.play_arrow,
//                                 color: Colors.white,
//                                 size: 24,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 if (widget.liveStatus == false)

//                   // 2. Current Time
//                   Padding(
//                     padding: const EdgeInsets.only(left: 12.0, right: 8.0),
//                     child: ListenableBuilder(
//                         listenable: Listenable.merge(
//                             [_currentPosition, _previewPosition]),
//                         builder: (context, child) {
//                           final Duration displayPosition =
//                               _accumulatedSeekForward > 0 ||
//                                       _accumulatedSeekBackward > 0 ||
//                                       _isScrubbing
//                                   ? _previewPosition.value
//                                   : _currentPosition.value;
//                           return Text(
//                             _formatDuration(displayPosition),
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold),
//                           );
//                         }),
//                   ),

//                 // 3. Progress Bar
//                 Expanded(
//                   child: LayoutBuilder(
//                     builder: (context, constraints) {
//                       return GestureDetector(
//                         onHorizontalDragStart: (details) =>
//                             _onScrubStart(details, constraints),
//                         onHorizontalDragUpdate: (details) =>
//                             _onScrubUpdate(details, constraints),
//                         onHorizontalDragEnd: (details) => _onScrubEnd(details),
//                         child: Container(
//                           height: 30,
//                           color: Colors.transparent,
//                           child: Center(
//                             child: ListenableBuilder(
//                                 listenable: Listenable.merge([
//                                   _currentPosition,
//                                   _previewPosition,
//                                   _totalDuration
//                                 ]),
//                                 builder: (context, child) {
//                                   final Duration displayPosition =
//                                       _accumulatedSeekForward > 0 ||
//                                               _accumulatedSeekBackward > 0 ||
//                                               _isScrubbing
//                                           ? _previewPosition.value
//                                           : _currentPosition.value;
//                                   return _buildBeautifulProgressBar(
//                                       displayPosition, _totalDuration.value);
//                                 }),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 if (widget.liveStatus == false)
//                   // 4. Total Time
//                   Padding(
//                     padding: const EdgeInsets.only(left: 8.0, right: 12.0),
//                     child: ValueListenableBuilder<Duration>(
//                         valueListenable: _totalDuration,
//                         builder: (context, totalDuration, child) {
//                           return Text(
//                             _formatDuration(totalDuration),
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold),
//                           );
//                         }),
//                   ),

//                 // 5. Live Indicator
//                 if (widget.liveStatus == true)
//                   Padding(
//                     padding: const EdgeInsets.only(left: 8.0),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: const [
//                         Icon(Icons.circle, color: Colors.red, size: 15),
//                         SizedBox(width: 5),
//                         Text('Live',
//                             style: TextStyle(
//                                 color: Colors.red,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                   ),
//               ],
//             ),

//             // --- NEECHE WALI ROW (Sirf Subtitles) ---
//             if (widget.liveStatus == false && activePlayer == 'VLC') ...[
//               const SizedBox(height: 10),
//               Container(
//                 decoration: BoxDecoration(
//                   color: subtitleButtonFocusNode.hasFocus
//                       ? const Color.fromARGB(200, 16, 62, 99)
//                       : Colors.transparent,
//                   borderRadius: BorderRadius.circular(6),
//                   border: Border.all(
//                       color: subtitleButtonFocusNode.hasFocus
//                           ? Colors.purple
//                           : Colors.transparent,
//                       width: 2),
//                 ),
//                 child: Focus(
//                   focusNode: subtitleButtonFocusNode,
//                   onFocusChange: (hasFocus) => setState(() {}),
//                   child: InkWell(
//                     onTap: _showSubtitleMenu,
//                     child: const Padding(
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.subtitles, color: Colors.white, size: 18),
//                           SizedBox(width: 4),
//                           Text("Subtitles",
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 14)),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBeautifulProgressBar(
//       Duration displayPosition, Duration totalDuration) {
//     final totalDurationMs = totalDuration.inMilliseconds.toDouble();

//     if (totalDurationMs <= 0 || widget.liveStatus == true) {
//       return Container(
//         padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//         child: Container(
//             height: 8,
//             decoration: BoxDecoration(
//                 color: Colors.grey[800],
//                 borderRadius: BorderRadius.circular(4))),
//       );
//     }

//     double playedProgress =
//         (displayPosition.inMilliseconds / totalDurationMs).clamp(0.0, 1.0);
//     double bufferedProgress = (playedProgress + 0.005).clamp(0.0, 1.0);

//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//       child: Container(
//         height: 8,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(4),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(4),
//           child: Stack(
//             children: [
//               Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.grey[800]!, Colors.grey[700]!],
//                   ),
//                 ),
//               ),
//               FractionallySizedBox(
//                 widthFactor: bufferedProgress,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.grey[600]!, Colors.grey[500]!],
//                     ),
//                   ),
//                 ),
//               ),
//               FractionallySizedBox(
//                 widthFactor: playedProgress,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [
//                         Color(0xFF9B28F8),
//                         Color(0xFFE62B1E),
//                         Color(0xFFFF6B35),
//                       ],
//                       stops: [0.0, 0.7, 1.0],
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFF9B28F8).withOpacity(0.6),
//                         blurRadius: 8,
//                         spreadRadius: 1,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _getHtmlString() {
//     return """
//     <!DOCTYPE html>
//     <html>
//     <head>
//       <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
//       <style>
//         * { margin: 0; padding: 0; box-sizing: border-box; }
//         body {
//           background: #000;
//           width: 100vw;
//           height: 100vh;
//           overflow: hidden;
//           -webkit-tap-highlight-color: transparent;
//         }
//         #wrapper {
//           position: absolute;
//           top: 0px; left: 0px; right: 0px; bottom: 0px;
//           transition: top 0.3s ease, left 0.3s ease, right 0.3s ease, bottom 0.3s ease;
//         }
//         video {
//           width: 100%; height: 100%;
//           object-fit: contain; 
//           background: transparent;
//           outline: none; border: none;
//         }
//         video::-webkit-media-controls { display: none !important; }
//         video::-webkit-media-controls-enclosure { display: none !important; }
//       </style>
//       <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
//     </head>
//     <body>
//       <div id="wrapper">
//         <video id="video" autoplay playsinline></video>
//       </div>
//       <script>
//         var video = document.getElementById('video');
//         var wrapper = document.getElementById('wrapper');
//         var hls;

//         function setVideoBounds(left, top, right, bottom) {
//            wrapper.style.left = left + "px";
//            wrapper.style.top = top + "px";
//            wrapper.style.right = right + "px";
//            wrapper.style.bottom = bottom + "px";
//         }

//         function sendState() {
//           var state = { position: video.currentTime * 1000, duration: video.duration ? video.duration * 1000 : 0, isPlaying: !video.paused, isBuffering: video.readyState < 3 };
//           window.flutter_inappwebview.callHandler('videoState', state);
//         }

//         // --- UPDATED EVENT LISTENERS FOR PERFECT RAINBOW SYNC ---
//         video.addEventListener('timeupdate', sendState);
//         video.addEventListener('play', sendState);
//         video.addEventListener('pause', sendState);
//         video.addEventListener('waiting', sendState);
//         video.addEventListener('playing', sendState);
//         video.addEventListener('loadstart', sendState);
//         video.addEventListener('loadeddata', sendState);
//         video.addEventListener('stalled', sendState);
//         video.addEventListener('canplay', sendState);
//         // --------------------------------------------------------

//         function loadNewVideo(src) {
//           if (Hls.isSupported()) {
//             if (hls) hls.destroy();
//             hls = new Hls();
//             hls.loadSource(src);
//             hls.attachMedia(video);
//             hls.on(Hls.Events.MANIFEST_PARSED, function() {
//               if (hls.levels && hls.levels.length > 0) { hls.currentLevel = hls.levels.length - 1; }
//               video.play().catch(function(e) { console.log(e); });
//             });
//           } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
//             video.src = src;
//             video.addEventListener('loadedmetadata', function() { video.play(); });
//           }
//         }
//         loadNewVideo('${_currentModifiedUrl ?? widget.videoUrl}');
//       </script>
//     </body>
//     </html>
//   """;
//   }

//   void _focusAndScrollToInitialItem() {
//     if (_isDisposing) return;
//     if (!mounted ||
//         focusNodes.isEmpty ||
//         _focusedIndex < 0 ||
//         _focusedIndex >= focusNodes.length) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!mounted || _isDisposing) return;
//         FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//       });
//       return;
//     }
//     _scrollToFocusedItem();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted || _isDisposing) return;
//       if (widget.liveStatus == false) {
//         FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//       } else {
//         FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//       }
//     });
//   }

//   void _changeFocusAndScroll(int newIndex) {
//     if (newIndex < 0 || newIndex >= widget.channelList.length || _isDisposing)
//       return;
//     setState(() {
//       _focusedIndex = newIndex;
//     });
//     _scrollToFocusedItem();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted || _isDisposing) return;
//       FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//     });
//   }

//   void _scrollToFocusedItem() {
//     if (_isDisposing) return;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted ||
//           _isDisposing ||
//           _focusedIndex < 0 ||
//           !_scrollController.hasClients ||
//           _focusedIndex >= focusNodes.length) return;
//       final screenhgt = MediaQuery.of(context).size.height;
//       final double itemHeight = (screenhgt * 0.108) + 16.0;
//       final double viewportHeight = screenhgt * 0.88;
//       final double targetOffset = (itemHeight * _focusedIndex) -
//           (viewportHeight / 2) +
//           (itemHeight / 2);
//       final double clampedOffset = targetOffset.clamp(
//           _scrollController.position.minScrollExtent,
//           _scrollController.position.maxScrollExtent);
//       _scrollController.jumpTo(clampedOffset);
//     });
//   }

//   void _resetHideControlsTimer() {
//     _hideControlsTimer?.cancel();
//     if (_isDisposing) return;

//     if (!_controlsVisible) {
//       setState(() {
//         _controlsVisible = true;
//       });

//       // Screen ke exact margins nikalna
//       final double screenwdt = MediaQuery.of(context).size.width;
//       final double screenhgt = MediaQuery.of(context).size.height;

//       final double leftPanelWidth = screenwdt * 0.15;
//       final double topTitleHeight = screenhgt * 0.10;
//       final double bottomBarHeight = screenhgt * 0.15;

//       // --- HEIGHT REDUCTION KE LIYE EXTRA MARGIN ---
//       final double extraVerticalMargin =
//           1.0; // Yahan se height kam/zyada karein

//       final double offsetLeft =
//           widget.channelList.isNotEmpty ? leftPanelWidth : 0.0;
//       final double offsetTop = topTitleHeight + extraVerticalMargin;
//       final double offsetBottom = bottomBarHeight + extraVerticalMargin;
//       final double offsetRight = 16.0;

//       // JavaScript function ko exact boundaries bhejna
//       if (activePlayer == 'WEB') {
//         webViewController?.evaluateJavascript(
//             source:
//                 "if(typeof setVideoBounds === 'function') setVideoBounds($offsetLeft, $offsetTop, $offsetRight, $offsetBottom);");
//       }

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!mounted || _isDisposing) return;
//         if (widget.liveStatus == false || widget.channelList.isEmpty) {
//           FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//         } else {
//           FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//           _scrollToFocusedItem();
//         }
//       });
//     }
//     _startHideControlsTimer();
//   }

//   void _startHideControlsTimer() {
//     _hideControlsTimer?.cancel();
//     if (_isDisposing) return;
//     _hideControlsTimer = Timer(const Duration(seconds: 10), () {
//       if (mounted && !_isDisposing) {
//         setState(() {
//           _controlsVisible = false;
//         });

//         // Controls gayab, toh margins wapas ZERO kar do (Full Screen)
//         if (activePlayer == 'WEB') {
//           webViewController?.evaluateJavascript(
//               source:
//                   "if(typeof setVideoBounds === 'function') setVideoBounds(0, 0, 0, 0);");
//         }

//         FocusScope.of(context).requestFocus(_mainFocusNode);
//       }
//     });
//   }

//   String _formatDuration(Duration duration) {
//     if (duration.isNegative) duration = Duration.zero;
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//   }

//   String _getFormattedName(dynamic channel) {
//     String name = "";
//     try {
//       name = channel.name?.toString() ?? "";
//     } catch (_) {
//       try {
//         name = channel['name']?.toString() ?? "";
//       } catch (_) {}
//     }
//     String? cNo;
//     try {
//       cNo = channel.channel_number?.toString();
//     } catch (_) {
//       try {
//         cNo = channel.channelNumber?.toString();
//       } catch (_) {
//         try {
//           cNo = channel['channel_number']?.toString() ??
//               channel['channelNumber']?.toString();
//         } catch (_) {
//           cNo = null;
//         }
//       }
//     }
//     if (cNo != null && cNo.trim().isNotEmpty && cNo != "null")
//       return "${cNo.trim()}. $name";
//     return name;
//   }

//   void _safeDispose() {
//     if (_isDisposing) return;
//     _isDisposing = true;
//     _hideControlsTimer?.cancel();
//     _seekTimer?.cancel();
//     _networkCheckTimer?.cancel();
//     _keyRepeatTimer?.cancel();

//     if (vlcController != null) {
//       vlcController!.removeListener(_vlcListener);
//       vlcController!.stop();
//     }
//     KeepScreenOn.turnOff();
//   }

//   @override
//   void dispose() {
//     _safeDispose();
//     _mainFocusNode.dispose();
//     _currentPosition.dispose();
//     _totalDuration.dispose();
//     _previewPosition.dispose();

//     for (var node in focusNodes) {
//       node.dispose();
//     }
//     playPauseButtonFocusNode.dispose();
//     subtitleButtonFocusNode.dispose();
//     _scrollController.dispose();
//     vlcController?.dispose();

//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
// }




import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
import 'package:mobi_tv_entertainment/components/widgets/small_widgets/rainbow_page.dart';

class VideoScreen extends StatefulWidget {
  final String videoUrl;
  final String name;
  final bool liveStatus;
  final String updatedAt;
  final List<dynamic> channelList;
  final String bannerImageUrl;
  final int? videoId;
  final String source;
  final String streamType;

  VideoScreen({
    required this.videoUrl,
    required this.updatedAt,
    required this.channelList,
    required this.bannerImageUrl,
    required this.videoId,
    required this.source,
    required this.streamType,
    required this.name,
    required this.liveStatus,
  });

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
  // --- Hybrid Player Controllers ---
  InAppWebViewController? webViewController;
  VlcPlayerController? vlcController;
  String activePlayer = 'NONE';

  // --- High-Frequency Update Notifiers (Prevents Lag) ---
  final ValueNotifier<Duration> _currentPosition = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> _totalDuration = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> _previewPosition = ValueNotifier(Duration.zero);
  Timer? _keyRepeatTimer;
  DateTime _lastKeyRepeatTime = DateTime.now();
  final FocusNode _mainFocusNode = FocusNode();

  // --- UI State Variables ---
  bool _isVideoInitialized = false;
  bool _isPlaying = false;
  bool _isBuffering = true;
  bool _loadingVisible = true;
  bool _controlsVisible = true;
  String? _currentModifiedUrl;
  bool _isSeeking = false;

  // --- Focus Variables ---
  Timer? _hideControlsTimer;
  int _focusedIndex = 0;
  List<FocusNode> focusNodes = [];
  final ScrollController _scrollController = ScrollController();
  final FocusNode playPauseButtonFocusNode = FocusNode();
  final FocusNode subtitleButtonFocusNode = FocusNode();

  // --- Seek Variables ---
  bool _isScrubbing = false;
  int _accumulatedSeekForward = 0;
  int _accumulatedSeekBackward = 0;
  Timer? _seekTimer;
  Duration _baseSeekPosition = Duration.zero;
  final int _seekDuration = 5;
  final int _seekDelay = 800;

  // --- Subtitle Variables ---
  Map<int, String> _spuTracks = {};
  int _currentSpuTrack = -1;
  bool _hasFetchedSubtitles = false;

  // --- Network & Stall Recovery Variables ---
  Timer? _networkCheckTimer;
  bool _wasDisconnected = false;
  bool _isAttemptingResume = false;
  DateTime _lastPlayingTime = DateTime.now();
  Duration _lastPositionCheck = Duration.zero;
  int _stallCounter = 0;
  bool _hasStartedPlaying = false;
  bool _isUserPaused = false;

  Map<String, Uint8List> _bannerCache = {};
  bool _isDisposing = false;
  final String localImage = "";

  final InAppWebViewSettings settings = InAppWebViewSettings(
    userAgent:
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    allowsInlineMediaPlayback: true,
    mediaPlaybackRequiresUserGesture: false,
    javaScriptEnabled: true,
    useHybridComposition: false,
    transparentBackground: true,
    hardwareAcceleration: true,
    supportZoom: false,
    displayZoomControls: false,
    builtInZoomControls: false,
    disableHorizontalScroll: true,
    disableVerticalScroll: true,
  );

  Uint8List _getCachedImage(String base64String) {
    try {
      if (!_bannerCache.containsKey(base64String)) {
        if (_bannerCache.length >= 50) {
          _bannerCache.remove(_bannerCache.keys.first);
        }
        _bannerCache[base64String] = base64Decode(base64String.split(',').last);
      }
      return _bannerCache[base64String]!;
    } catch (e) {
      return Uint8List.fromList([0, 0, 0, 0]);
    }
  }

  Future<String> _getSecureUrlSafe(String rawUrl) async {
    try {
      return await SecureUrlService.getSecureUrl(rawUrl, expirySeconds: 10);
    } catch (e) {
      print("Secure URL fetch failed, falling back to raw URL: $e");
      return rawUrl;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    KeepScreenOn.turnOn();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _focusedIndex = widget.channelList.indexWhere(
      (channel) => channel.id.toString() == widget.videoId.toString(),
    );
    _focusedIndex = (_focusedIndex >= 0) ? _focusedIndex : 0;

    focusNodes = List.generate(
      widget.channelList.length,
      (index) => FocusNode(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _focusAndScrollToInitialItem();
      String initialTarget =
          (widget.streamType.trim().toLowerCase() == 'custom') ? 'WEB' : 'VLC';

      String secureUrl = await _getSecureUrlSafe(widget.videoUrl);

      await _switchPlayerSafely(initialTarget, secureUrl);
    });

    _startHideControlsTimer();
    _startNetworkMonitor();
    _startPositionUpdater();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (activePlayer == 'VLC') vlcController?.pause();
      if (activePlayer == 'WEB')
        webViewController?.evaluateJavascript(
            source: "document.getElementById('video').pause();");
    } else if (state == AppLifecycleState.resumed) {
      if (!_isUserPaused) {
        if (activePlayer == 'VLC') vlcController?.play();
        if (activePlayer == 'WEB')
          webViewController?.evaluateJavascript(
              source: "document.getElementById('video').play();");
      }
    }
  }

  void _startNetworkMonitor() {
    _networkCheckTimer?.cancel();
    _networkCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_isDisposing) return;
      bool isConnected = await _isInternetAvailable();
      if (!isConnected && !_wasDisconnected) {
        _wasDisconnected = true;
      } else if (isConnected && _wasDisconnected) {
        _wasDisconnected = false;
        _onNetworkReconnected();
      }
    });
  }

  Future<bool> _isInternetAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _onNetworkReconnected() async {
    if (_currentModifiedUrl == null || _isDisposing) return;
    try {
      if (widget.liveStatus == true) {
        await _attemptResumeLiveStream();
      } else {
        if (activePlayer == 'VLC' && vlcController != null) {
          await vlcController!.play();
        } else if (activePlayer == 'WEB' && webViewController != null) {
          await webViewController!.evaluateJavascript(
              source: "document.getElementById('video').play();");
        }
      }
    } catch (e) {
      print("Critical error during reconnection: $e");
    }
  }

  Future<void> _attemptResumeLiveStream() async {
    if (!mounted ||
        _isAttemptingResume ||
        widget.liveStatus == false ||
        _currentModifiedUrl == null ||
        _isDisposing) {
      return;
    }

    setState(() {
      _isAttemptingResume = true;
      _loadingVisible = true;
    });

    try {
      String newSecureUrl = await _getSecureUrlSafe(widget.videoUrl);

      await _switchPlayerSafely(activePlayer, newSecureUrl);

      _lastPlayingTime = DateTime.now();
      _stallCounter = 0;
      _isUserPaused = false;
    } catch (e) {
      print("Error: Recovery failed: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isAttemptingResume = false;
        });
      }
    }
  }

  // void _startPositionUpdater() {
  //   Timer.periodic(const Duration(seconds: 2), (_) {
  //     if (!mounted || _isScrubbing || _isAttemptingResume || _isDisposing)
  //       return;

  //     if (widget.liveStatus == true && _hasStartedPlaying && !_isUserPaused) {
  //       if (_lastPositionCheck != Duration.zero &&
  //           _currentPosition.value == _lastPositionCheck) {
  //         _stallCounter++;
  //       } else {
  //         _stallCounter = 0;
  //       }

  //       if (_stallCounter >= 3) {
  //         _attemptResumeLiveStream();
  //         _stallCounter = 0;
  //       }
  //       _lastPositionCheck = _currentPosition.value;
  //     }
  //   });
  // }



  void _startPositionUpdater() {
    Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || _isScrubbing || _isAttemptingResume || _isDisposing)
        return;

      if (widget.liveStatus == true && _hasStartedPlaying && !_isUserPaused) {
        if (_lastPositionCheck != Duration.zero &&
            _currentPosition.value == _lastPositionCheck) {
          _stallCounter++;
        } else {
          _stallCounter = 0;
        }

        // Wait a bit longer before a full reconnect, but try a quick pause/play to resync AV
        if (_stallCounter == 2 && activePlayer == 'VLC' && vlcController != null) {
          vlcController!.pause().then((_) => vlcController!.play());
        }

        if (_stallCounter >= 4) { // Increased to 4 to give the larger buffer time to work
          _attemptResumeLiveStream();
          _stallCounter = 0;
        }
        _lastPositionCheck = _currentPosition.value;
      }
    });
  }

  String _buildVlcUrl(String baseUrl) {
    final String networkCaching = "network-caching=1000";
    final String liveCaching = "live-caching=1000";
    final String fileCaching = "file-caching=500";
    final String rtspTcp = "rtsp-tcp";
    return widget.liveStatus == true
        ? '$baseUrl?$networkCaching&$liveCaching&$fileCaching&$rtspTcp'
        : '$baseUrl?$networkCaching&$fileCaching&$rtspTcp';
  }

  // Future<void> _initVlcPlayer(String baseUrl) async {
  //   if (_isDisposing) return;

  //   if (vlcController != null) {
  //     vlcController!.removeListener(_vlcListener);
  //     await vlcController!.stop();
  //     await vlcController!.dispose();
  //     vlcController = null;
  //   }

  //   _lastPlayingTime = DateTime.now();
  //   _stallCounter = 0;
  //   _hasStartedPlaying = false;
  //   _hasFetchedSubtitles = false;

  //   vlcController = VlcPlayerController.network(
  //     _buildVlcUrl(baseUrl),
  //     hwAcc: HwAcc.auto,
  //     autoPlay: true,
  //     options: VlcPlayerOptions(
  //       http: VlcHttpOptions([
  //         ':http-user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
  //       ]),
  //       video: VlcVideoOptions([
  //         VlcVideoOptions.dropLateFrames(true),
  //         VlcVideoOptions.skipFrames(true),
  //       ]),
  //     ),
  //   );
  //   vlcController!.addListener(_vlcListener);
  //   if (mounted) setState(() {});
  // }



  Future<void> _initVlcPlayer(String baseUrl) async {
    if (_isDisposing) return;

    if (vlcController != null) {
      vlcController!.removeListener(_vlcListener);
      await vlcController!.stop();
      await vlcController!.dispose();
      vlcController = null;
    }

    _lastPlayingTime = DateTime.now();
    _stallCounter = 0;
    _hasStartedPlaying = false;
    _hasFetchedSubtitles = false;

    vlcController = VlcPlayerController.network(
      _buildVlcUrl(baseUrl),
      hwAcc: HwAcc.auto ,
      autoPlay: true,
      options: VlcPlayerOptions(
        http: VlcHttpOptions([
          ':http-user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
        ]),
        video: VlcVideoOptions([
          VlcVideoOptions.dropLateFrames(true),
          VlcVideoOptions.skipFrames(true),
        ]),
        audio: VlcAudioOptions([
          // Corrected method name
          VlcAudioOptions.audioTimeStretch(true), 
        ]),
        advanced: VlcAdvancedOptions([
          // Disabling input clock sync (0) helps prevent jerky playback on live network streams
          VlcAdvancedOptions.clockJitter(0),
          VlcAdvancedOptions.clockSynchronization(0), 
        ]),
      ),
    );
    
    vlcController!.addListener(_vlcListener);
    if (mounted) setState(() {});
  }

  Future<void> _fetchSubtitles() async {
    await Future.delayed(const Duration(seconds: 2));
    if (vlcController != null && vlcController!.value.isInitialized) {
      final tracks = await vlcController!.getSpuTracks();
      final current = await vlcController!.getSpuTrack() ?? -1;
      if (mounted) {
        setState(() {
          _spuTracks = tracks;
          _currentSpuTrack = current;
          _hasFetchedSubtitles = true;
        });
      }
    }
  }

  void _vlcListener() {
    if (!mounted || vlcController == null || _isDisposing) return;
    final value = vlcController!.value;
    final PlayingState playingState = value.playingState;

    if (widget.liveStatus == true && !_isAttemptingResume) {
      if (playingState == PlayingState.playing) {
        _lastPlayingTime = DateTime.now();
        if (!_hasStartedPlaying) _hasStartedPlaying = true;
        if (!_hasFetchedSubtitles) _fetchSubtitles();
      } else if (playingState == PlayingState.buffering && _hasStartedPlaying) {
        if (DateTime.now().difference(_lastPlayingTime) >
            const Duration(seconds: 8)) _attemptResumeLiveStream();
      } else if (playingState == PlayingState.error) {
        _attemptResumeLiveStream();
      } else if ((playingState == PlayingState.stopped ||
              playingState == PlayingState.ended) &&
          _hasStartedPlaying) {
        if (DateTime.now().difference(_lastPlayingTime) >
            const Duration(seconds: 5)) _attemptResumeLiveStream();
      }
    } else if (playingState == PlayingState.paused) {
      if (_isUserPaused) {
        _lastPlayingTime = DateTime.now();
      } else {
        if (DateTime.now().difference(_lastPlayingTime) >
            const Duration(seconds: 5)) {
          if (widget.liveStatus == true) {
            _attemptResumeLiveStream();
          } else {
            _onNetworkReconnected();
          }
          _lastPlayingTime = DateTime.now();
        }
      }
    } else if (playingState == PlayingState.playing &&
        widget.liveStatus == false) {
      if (!_hasFetchedSubtitles) _fetchSubtitles();
    }

    _currentPosition.value = value.position;
    _totalDuration.value = value.duration;

    bool needsRebuild = false;
    if (_isPlaying != value.isPlaying) {
      _isPlaying = value.isPlaying;
      needsRebuild = true;
    }
    if (_isBuffering != value.isBuffering) {
      _isBuffering = value.isBuffering;
      needsRebuild = true;
    }
    if (!_isVideoInitialized && value.isInitialized) {
      _isVideoInitialized = true;
      needsRebuild = true;
    }

    bool newLoadingVisible = _isBuffering ||
        playingState == PlayingState.initializing ||
        _isAttemptingResume;
    if (_isPlaying && !_isBuffering) newLoadingVisible = false;

    if (_loadingVisible != newLoadingVisible) {
      _loadingVisible = newLoadingVisible;
      needsRebuild = true;
    }

    if (needsRebuild && mounted) setState(() {});
  }

  Future<void> _switchPlayerSafely(
      String targetPlayerType, String secureUrl) async {
    if (_isDisposing) return;

    setState(() {
      _loadingVisible = true;
      _isVideoInitialized = false;
    });

    if (activePlayer == 'VLC' && vlcController != null) {
      vlcController!.removeListener(_vlcListener);
      await vlcController!.stop();
      await vlcController!.dispose();
      vlcController = null;
    }
    webViewController = null;

    setState(() {
      activePlayer = 'NONE';
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (_isDisposing) return;

    _currentModifiedUrl = secureUrl;
    setState(() {
      activePlayer = targetPlayerType;
    });

    if (targetPlayerType == 'WEB') {
      if (webViewController != null) {
        await webViewController!.evaluateJavascript(
            source: "loadNewVideo('$_currentModifiedUrl');");
      }
    } else if (targetPlayerType == 'VLC') {
      await _initVlcPlayer(_currentModifiedUrl!);
    }
  }

  Future<void> _onItemTap(int index) async {
    if (!mounted || _isDisposing) return;
    setState(() {
      _focusedIndex = index;
    });

    var selectedChannel = widget.channelList[index];
    String typeFromData = widget.streamType;

    if (selectedChannel is Map) {
      typeFromData = selectedChannel['stream_type']?.toString() ??
          selectedChannel['streamType']?.toString() ??
          widget.streamType;
    } else {
      try {
        typeFromData = selectedChannel.stream_type?.toString() ?? typeFromData;
      } catch (_) {
        try {
          typeFromData = selectedChannel.streamType?.toString() ?? typeFromData;
        } catch (_) {}
      }
    }

    String targetPlayer =
        (typeFromData.trim().toLowerCase() == 'custom') ? 'WEB' : 'VLC';
    String rawUrl = "";

    if (selectedChannel is Map) {
      rawUrl = selectedChannel['url']?.toString() ?? "";
    } else {
      try {
        rawUrl = selectedChannel.url?.toString() ?? "";
      } catch (_) {}
    }

    if (rawUrl.isEmpty) return;

    String secureUrl = await _getSecureUrlSafe(rawUrl);

    if (_isDisposing) return;
    await _switchPlayerSafely(targetPlayer, secureUrl);

    _scrollToFocusedItem();
    _resetHideControlsTimer();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (_isDisposing) return false;

    if (event is KeyDownEvent ||
        event is RawKeyDownEvent ||
        event is KeyRepeatEvent) {
      if (!_controlsVisible) {
        _resetHideControlsTimer();
        return true;
      }

      _resetHideControlsTimer();

      switch (event.logicalKey) {
        case LogicalKeyboardKey.escape:
        case LogicalKeyboardKey.browserBack:
          return false;

        case LogicalKeyboardKey.arrowUp:
          if (event is KeyRepeatEvent) {
            final now = DateTime.now();
            if (now.difference(_lastKeyRepeatTime).inMilliseconds < 300)
              return true;
            _lastKeyRepeatTime = now;

            if (!playPauseButtonFocusNode.hasFocus &&
                !subtitleButtonFocusNode.hasFocus) {
              if (_focusedIndex > 0) _changeFocusAndScroll(_focusedIndex - 1);
            }
            return true;
          }
          if (subtitleButtonFocusNode.hasFocus) {
            FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
          } else if (playPauseButtonFocusNode.hasFocus) {
            if (widget.liveStatus == false && widget.channelList.isNotEmpty) {
              FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
            }
          } else if (_focusedIndex > 0) {
            _changeFocusAndScroll(_focusedIndex - 1);
          }
          return true;

        case LogicalKeyboardKey.arrowDown:
          if (event is KeyRepeatEvent) {
            final now = DateTime.now();
            if (now.difference(_lastKeyRepeatTime).inMilliseconds < 300)
              return true;
            _lastKeyRepeatTime = now;

            if (!playPauseButtonFocusNode.hasFocus &&
                !subtitleButtonFocusNode.hasFocus) {
              if (_focusedIndex < widget.channelList.length - 1) {
                _changeFocusAndScroll(_focusedIndex + 1);
              }
            }
            return true;
          }
          if (playPauseButtonFocusNode.hasFocus &&
              widget.liveStatus == false &&
              activePlayer == 'VLC') {
            FocusScope.of(context).requestFocus(subtitleButtonFocusNode);
          } else if (_focusedIndex < widget.channelList.length - 1) {
            _changeFocusAndScroll(_focusedIndex + 1);
          }
          return true;

        case LogicalKeyboardKey.arrowRight:
          if (widget.liveStatus == false) _seekForward();
          return true;

        case LogicalKeyboardKey.arrowLeft:
          if (widget.liveStatus == false) _seekBackward();
          if (playPauseButtonFocusNode.hasFocus &&
              widget.channelList.isNotEmpty) {
            FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
          }
          return true;

        case LogicalKeyboardKey.select:
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.mediaPlayPause:
          if (event is KeyRepeatEvent) return true;
          if (subtitleButtonFocusNode.hasFocus) {
            _showSubtitleMenu();
            return true;
          }
          if (widget.liveStatus == false) {
            _togglePlayPause();
          } else {
            if (playPauseButtonFocusNode.hasFocus ||
                widget.channelList.isEmpty) {
              _togglePlayPause();
            } else {
              _onItemTap(_focusedIndex);
            }
          }
          return true;

        default:
          return false;
      }
    }
    return false;
  }

  void _togglePlayPause() {
    if (_isDisposing) return;
    if (activePlayer == 'WEB' && webViewController != null) {
      webViewController!.evaluateJavascript(source: """
        var v = document.getElementById('video');
        if (v.paused) { v.play(); } else { v.pause(); }
      """);
      setState(() {
        _isPlaying = !_isPlaying;
        _isUserPaused = !_isPlaying;
      });
      _lastPlayingTime = DateTime.now();
    } else if (activePlayer == 'VLC' && vlcController != null) {
      if (vlcController!.value.isPlaying) {
        vlcController!.pause();
        setState(() {
          _isUserPaused = true;
          _isPlaying = false;
        });
      } else {
        vlcController!.play();
        setState(() {
          _isUserPaused = false;
          _isPlaying = true;
        });
        _lastPlayingTime = DateTime.now();
        _stallCounter = 0;
      }
    }
    FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
    _resetHideControlsTimer();
  }

  Future<void> _seekToPosition(Duration position) async {
    if (_isSeeking || _isDisposing) return;
    _isSeeking = true;
    try {
      if (activePlayer == 'WEB' && webViewController != null) {
        double seconds = position.inMilliseconds / 1000.0;
        await webViewController!.evaluateJavascript(
            source:
                "document.getElementById('video').currentTime = $seconds; document.getElementById('video').play();");
      } else if (activePlayer == 'VLC' && vlcController != null) {
        await vlcController!.seekTo(position);
        await vlcController!.play(); 
      }
    } catch (e) {
      print("Error during seek: $e");
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      _isSeeking = false;
    }
  }

  void _seekForward() {
    if (_totalDuration.value <= Duration.zero || _isDisposing) return;

    _accumulatedSeekForward += _seekDuration;
    final newPosition =
        _currentPosition.value + Duration(seconds: _accumulatedSeekForward);

    setState(() {
      _previewPosition.value = newPosition > _totalDuration.value
          ? _totalDuration.value
          : newPosition;
    });

    _seekTimer?.cancel();
    _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
      if (_isDisposing) return;
      _seekToPosition(_previewPosition.value).then((_) {
        if (mounted && !_isDisposing) {
          setState(() {
            _accumulatedSeekForward = 0;
          });
        }
      });
    });
  }

  void _seekBackward() {
    if (_totalDuration.value <= Duration.zero || _isDisposing) return;

    _accumulatedSeekBackward += _seekDuration;
    final newPosition =
        _currentPosition.value - Duration(seconds: _accumulatedSeekBackward);

    setState(() {
      _previewPosition.value =
          newPosition > Duration.zero ? newPosition : Duration.zero;
    });

    _seekTimer?.cancel();
    _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
      if (_isDisposing) return;
      _seekToPosition(_previewPosition.value).then((_) {
        if (mounted && !_isDisposing) {
          setState(() {
            _accumulatedSeekBackward = 0;
          });
        }
      });
    });
  }

  void _onScrubStart(DragStartDetails details, BoxConstraints constraints) {
    if (_totalDuration.value <= Duration.zero || _isDisposing) return;
    _resetHideControlsTimer();
    setState(() {
      _isScrubbing = true;
      _accumulatedSeekForward = 1; 
    });
    final double progress =
        (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
    _previewPosition.value = _totalDuration.value * progress;
  }

  void _onScrubUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (!_isScrubbing || _totalDuration.value <= Duration.zero || _isDisposing)
      return;
    _resetHideControlsTimer();
    final double progress =
        (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
    _previewPosition.value = _totalDuration.value * progress;
  }

  void _onScrubEnd(DragEndDetails details) {
    if (!_isScrubbing || _isDisposing) return;
    _seekToPosition(_previewPosition.value).then((_) {
      if (mounted && !_isDisposing) {
        setState(() {
          _accumulatedSeekForward = 0;
          _isScrubbing = false;
        });
      }
    });
    _resetHideControlsTimer();
  }

  void _showSubtitleMenu() {
    _hideControlsTimer?.cancel();

    showDialog(
        context: context,
        builder: (context) {
          final size = MediaQuery.of(context).size;
          int focusedIndex =
              _spuTracks.keys.toList().indexOf(_currentSpuTrack) + 1;
          if (_currentSpuTrack == -1) focusedIndex = 0;

          final ScrollController dialogScrollController = ScrollController();
          final List<MapEntry<int, String>> tracksList =
              _spuTracks.entries.toList();

          return StatefulBuilder(builder: (context, setDialogState) {
            return Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.only(
                    left: size.width * 0.03, bottom: size.height * 0.18),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: size.width * 0.35,
                    height: size.height * 0.4,
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Select Subtitle",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ),
                        ),
                        const Divider(color: Colors.white24, height: 1),
                        Expanded(
                          child: _spuTracks.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text("No subtitles available",
                                      style: TextStyle(color: Colors.white70)),
                                )
                              : ListView.builder(
                                  controller: dialogScrollController,
                                  padding: EdgeInsets.zero,
                                  itemCount: tracksList.length + 1,
                                  itemBuilder: (context, index) {
                                    final isOffOption = index == 0;
                                    final trackId = isOffOption
                                        ? -1
                                        : tracksList[index - 1].key;
                                    final trackName = isOffOption
                                        ? "Off"
                                        : tracksList[index - 1].value;

                                    final isSelected =
                                        _currentSpuTrack == trackId;
                                    final isFocused = focusedIndex == index;

                                    return Focus(
                                      autofocus: isSelected,
                                      onFocusChange: (hasFocus) {
                                        if (hasFocus) {
                                          setDialogState(
                                              () => focusedIndex = index);

                                          const double itemHeight = 48.0;
                                          final double viewportHeight =
                                              (size.height * 0.4) - 48.0;
                                          final double targetOffset =
                                              (itemHeight * index) -
                                                  (viewportHeight / 2) +
                                                  (itemHeight / 2);

                                          final maxScroll =
                                              dialogScrollController
                                                  .position.maxScrollExtent;
                                          final double clampedOffset =
                                              targetOffset.clamp(
                                                  0.0,
                                                  maxScroll > 0
                                                      ? maxScroll
                                                      : 0.0);

                                          dialogScrollController.animateTo(
                                              clampedOffset,
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              curve: Curves.easeInOut);
                                        }
                                      },
                                      onKey: (node, event) {
                                        if (event is RawKeyDownEvent &&
                                            (event.logicalKey ==
                                                    LogicalKeyboardKey.select ||
                                                event.logicalKey ==
                                                    LogicalKeyboardKey.enter)) {
                                          vlcController?.setSpuTrack(trackId);
                                          setState(() {
                                            _currentSpuTrack = trackId;
                                          });
                                          Navigator.pop(context);
                                          return KeyEventResult.handled;
                                        }
                                        return KeyEventResult.ignored;
                                      },
                                      child: GestureDetector(
                                        onTap: () {
                                          vlcController?.setSpuTrack(trackId);
                                          setState(() {
                                            _currentSpuTrack = trackId;
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          color: isFocused
                                              ? Colors.purple.withOpacity(0.8)
                                              : Colors.transparent,
                                          height: 48.0,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(trackName,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14)),
                                                if (isSelected)
                                                  const Icon(Icons.check,
                                                      color: Colors.white,
                                                      size: 20),
                                              ],
                                            ),
                                          ),
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
              ),
            );
          });
        }).then((_) {
      FocusScope.of(context).requestFocus(subtitleButtonFocusNode);
      _resetHideControlsTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenwdt = MediaQuery.of(context).size.width;
    final double screenhgt = MediaQuery.of(context).size.height;
    final double bottomBarHeight = screenhgt * 0.15;
    final double topTitleHeight = screenhgt * 0.10;
    final double leftPanelWidth = screenwdt * 0.15;

    // Calculate dynamic smooth scale factor based on controls visibility
    final double targetScale = (_controlsVisible && widget.channelList.isNotEmpty) ? 0.7 : 1.0;


    // 1. Bounds Calculate karein (Yeh UI layout ke liye perfect jagah banayega)
final double offsetLeft = (_controlsVisible && widget.channelList.isNotEmpty) ? leftPanelWidth : 0.0;
final double offsetRight = _controlsVisible ? 16.0 : 0.0;
final double offsetTop = _controlsVisible ? topTitleHeight : 0.0;
final double offsetBottom = _controlsVisible ? bottomBarHeight : 0.0;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) _safeDispose();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Focus(
          focusNode: _mainFocusNode,
          autofocus: true,
          onKeyEvent: (node, event) {
            bool isHandled = _handleKeyEvent(event);
            return isHandled ? KeyEventResult.handled : KeyEventResult.ignored;
          },
          child: GestureDetector(
            onTap: _resetHideControlsTimer,
            child: Stack(
              children: [
                // 1. VIDEO LAYER (Always centered and scales perfectly)
                Positioned.fill(
                  child: Stack(
                    children: [
                      // // WEB PLAYER
                      // if (activePlayer == 'WEB')
                      //   ExcludeFocus(
                      //     child: Container(
                      //       color: Colors.black,
                      //       width: screenwdt,
                      //       height: screenhgt,
                      //       child: InAppWebView(
                      //         key: const ValueKey('WEB_Player'),
                      //         initialData: InAppWebViewInitialData(
                      //           data: _getHtmlString(),
                      //           mimeType: "text/html",
                      //           encoding: "utf-8",
                      //         ),
                      //         initialSettings: settings,
                      //         onWebViewCreated: (controller) {
                      //           webViewController = controller;
                      //           controller.addJavaScriptHandler(
                      //               handlerName: 'videoState',
                      //               callback: (args) {
                      //                 if (!mounted ||
                      //                     _isDisposing ||
                      //                     args.isEmpty) return;
                      //                 var state = args[0];

                      //                 _currentPosition.value = Duration(
                      //                     milliseconds:
                      //                         state['position'].toInt());
                      //                 _totalDuration.value = Duration(
                      //                     milliseconds:
                      //                         state['duration'].toInt());

                      //                 bool newIsPlaying = state['isPlaying'];
                      //                 bool newIsBuffering =
                      //                     state['isBuffering'];
                      //                 bool needsRebuild = false;

                      //                 if (!_isVideoInitialized) {
                      //                   _isVideoInitialized = true;
                      //                   needsRebuild = true;
                      //                 }
                      //                 if (_isPlaying != newIsPlaying) {
                      //                   _isPlaying = newIsPlaying;
                      //                   needsRebuild = true;
                      //                 }
                      //                 if (_isBuffering != newIsBuffering) {
                      //                   _isBuffering = newIsBuffering;
                      //                   needsRebuild = true;
                      //                 }

                      //                 bool newLoadingVisible = newIsBuffering;
                      //                 if (newIsPlaying && !newIsBuffering) {
                      //                   newLoadingVisible = false;
                      //                   _lastPlayingTime = DateTime.now();
                      //                 }

                      //                 if (_loadingVisible !=
                      //                     newLoadingVisible) {
                      //                   _loadingVisible = newLoadingVisible;
                      //                   needsRebuild = true;
                      //                 }

                      //                 if (needsRebuild && mounted)
                      //                   setState(() {});
                      //               });
                      //         },
                      //       ),
                      //     ),
                      //   ),

// WEB PLAYER
if (activePlayer == 'WEB')
  ExcludeFocus(
    child: Container(
      color: Colors.black,
      width: screenwdt,
      height: screenhgt,
      child: InAppWebView(
        key: const ValueKey('WEB_Player'),
        initialData: InAppWebViewInitialData(
          data: _getHtmlString(),
          mimeType: "text/html",
          encoding: "utf-8",
        ),
        initialSettings: settings,
        onWebViewCreated: (controller) {
          webViewController = controller;
          controller.addJavaScriptHandler(
              handlerName: 'videoState',
              callback: (args) {
                if (!mounted || _isDisposing || args.isEmpty) return;
                var state = args[0];

                _currentPosition.value = Duration(milliseconds: state['position'].toInt());
                _totalDuration.value = Duration(milliseconds: state['duration'].toInt());

                bool newIsPlaying = state['isPlaying'];
                bool newIsBuffering = state['isBuffering'];
                bool needsRebuild = false;

                if (!_isVideoInitialized) {
                  _isVideoInitialized = true;
                  needsRebuild = true;
                }
                if (_isPlaying != newIsPlaying) {
                  _isPlaying = newIsPlaying;
                  needsRebuild = true;
                }
                if (_isBuffering != newIsBuffering) {
                  _isBuffering = newIsBuffering;
                  needsRebuild = true;
                }

                bool newLoadingVisible = newIsBuffering;
                if (newIsPlaying && !newIsBuffering) {
                  newLoadingVisible = false;
                  _lastPlayingTime = DateTime.now();
                }

                if (_loadingVisible != newLoadingVisible) {
                  _loadingVisible = newLoadingVisible;
                  needsRebuild = true;
                }

                if (needsRebuild && mounted) setState(() {});
              });
        },
      ),
    ),
  ),

                      // // VLC PLAYER 
                      // if (activePlayer == 'VLC' && vlcController != null)
                      //   AnimatedScale(
                      //     scale: targetScale,
                      //     duration: const Duration(milliseconds: 300),
                      //     curve: Curves.easeInOut,
                      //     child: Container(
                      //       width: screenwdt,
                      //       height: screenhgt,
                      //       decoration: BoxDecoration(
                      //         color: Colors.black,
                      //         borderRadius: BorderRadius.circular(
                      //             _controlsVisible ? 24.0 : 0.0),
                      //         boxShadow: _controlsVisible
                      //             ? [
                      //                 const BoxShadow(
                      //                     color: Colors.black54,
                      //                     blurRadius: 20,
                      //                     spreadRadius: 5)
                      //               ]
                      //             : [],
                      //       ),
                      //       child: ClipRRect(
                      //         borderRadius: BorderRadius.circular(
                      //             _controlsVisible ? 24.0 : 0.0),
                      //         child: LayoutBuilder(
                      //           builder: (context, constraints) {
                      //             final screenWidth = constraints.maxWidth;
                      //             final screenHeight = constraints.maxHeight;

                      //             double videoWidth =
                      //                 vlcController!.value.size.width;
                      //             double videoHeight =
                      //                 vlcController!.value.size.height;

                      //             if (videoWidth <= 0 || videoHeight <= 0) {
                      //               videoWidth = 16.0;
                      //               videoHeight = 9.0;
                      //             }

                      //             final videoRatio = videoWidth / videoHeight;
                      //             final screenRatio =
                      //                 screenWidth > 0 && screenHeight > 0
                      //                     ? screenWidth / screenHeight
                      //                     : 16 / 9;

                      //             double scaleXInner = 1.0;
                      //             double scaleYInner = 1.0;

                      //             if (videoRatio < screenRatio) {
                      //               scaleXInner = screenRatio / videoRatio;
                      //             } else {
                      //               scaleYInner = videoRatio / screenRatio;
                      //             }

                      //             const double maxScaleLimit = 1.35;
                      //             if (scaleXInner > maxScaleLimit)
                      //               scaleXInner = maxScaleLimit;
                      //             if (scaleYInner > maxScaleLimit)
                      //               scaleYInner = maxScaleLimit;

                      //             return Container(
                      //               width: screenWidth,
                      //               height: screenHeight,
                      //               color: Colors.black,
                      //               child: Center(
                      //                 child: Transform.scale(
                      //                   scaleX: scaleXInner,
                      //                   scaleY: scaleYInner,
                      //                   alignment: Alignment.center, 
                      //                   child: VlcPlayer(
                      //                     key: const ValueKey('VLC_PLAYER'),
                      //                     controller: vlcController!,
                      //                     aspectRatio: videoRatio,
                      //                     placeholder: const Center(
                      //                       child: RainbowPage(
                      //                         backgroundColor: Colors.transparent,
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             );
                      //           },
                      //         ),
                      //       ),
                      //     ),
                      //   ),



                      
                      if (activePlayer == 'VLC' && vlcController != null)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          left: offsetLeft,
                          top: offsetTop,
                          right: offsetRight,
                          bottom: offsetBottom,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(
                                  _controlsVisible ? 12.0 : 0.0),
                              boxShadow: _controlsVisible
                                  ? [
                                      const BoxShadow(
                                          color: Colors.black54,
                                          blurRadius: 20,
                                          spreadRadius: 5)
                                    ]
                                  : [],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  _controlsVisible ? 12.0 : 0.0),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final screenWidth = constraints.maxWidth;
                                  final screenHeight = constraints.maxHeight;

                                  double videoWidth =
                                      vlcController!.value.size.width;
                                  double videoHeight =
                                      vlcController!.value.size.height;

                                  if (videoWidth <= 0 || videoHeight <= 0) {
                                    videoWidth = 16.0;
                                    videoHeight = 9.0;
                                  }

                                  final videoRatio = videoWidth / videoHeight;
                                  final screenRatio =
                                      screenWidth > 0 && screenHeight > 0
                                          ? screenWidth / screenHeight
                                          : 16 / 9;

                                  double scaleXInner = 1.0;
                                  double scaleYInner = 1.0;

                                  if (videoRatio < screenRatio) {
                                    scaleXInner = screenRatio / videoRatio;
                                  } else {
                                    scaleYInner = videoRatio / screenRatio;
                                  }

                                  const double maxScaleLimit = 1.35;
                                  if (scaleXInner > maxScaleLimit)
                                    scaleXInner = maxScaleLimit;
                                  if (scaleYInner > maxScaleLimit)
                                    scaleYInner = maxScaleLimit;

                                  return Container(
                                    width: screenWidth,
                                    height: screenHeight,
                                    color: Colors.black,
                                    child: Center(
                                      child: Transform.scale(
                                        scaleX: scaleXInner,
                                        scaleY: scaleYInner,
                                        alignment: Alignment.center,
                                        child: VlcPlayer(
                                          key: const ValueKey('VLC_PLAYER'),
                                          controller: vlcController!,
                                          aspectRatio: videoRatio,
                                          placeholder: const Center(
                                            child: RainbowPage(
                                              backgroundColor: Colors.transparent,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // 2. LOADING LAYER
                if (_loadingVisible ||
                    !_isVideoInitialized ||
                    _isAttemptingResume ||
                    (_isBuffering && !_loadingVisible))
                  Container(
                    color: _loadingVisible || !_isVideoInitialized
                        ? Colors.black54
                        : Colors.transparent,
                    child: Center(
                      child: RainbowPage(
                        backgroundColor: _loadingVisible || !_isVideoInitialized
                            ? Colors.black
                            : Colors.transparent,
                      ),
                    ),
                  ),

                // 3. TITLE LAYER
                if (_controlsVisible)
                  Positioned(
                    top: 10,
                    left: widget.channelList.isNotEmpty ? leftPanelWidth : 0.0,
                    right: 0,
                    height: topTitleHeight,
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      padding: const EdgeInsets.only(top: 8.0),
                      alignment: Alignment.topCenter,
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [
                              Color(0xFF9B28F8),
                              Color(0xFFE62B1E),
                              Color.fromARGB(255, 53, 255, 53)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height));
                        },
                        child: Text(
                          (widget.channelList.isNotEmpty &&
                                  _focusedIndex >= 0 &&
                                  _focusedIndex < widget.channelList.length)
                              ? _getFormattedName(
                                  widget.channelList[_focusedIndex])
                              : widget.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                // 4. CHANNEL LIST
                if (_controlsVisible && widget.channelList.isNotEmpty)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: leftPanelWidth,
                    child: Container(
                      color: Colors.black.withOpacity(0.85),
                      padding: const EdgeInsets.only(
                          top: 20, bottom: 20, left: 20, right: 10),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: widget.channelList.length,
                        itemBuilder: (context, index) {
                          final channel = widget.channelList[index];
                          final String channelId = channel.id?.toString() ?? '';
                          final bool isBase64 =
                              channel.banner?.startsWith('data:image') ?? false;
                          final bool isFocused = _focusedIndex == index;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Focus(
                              focusNode: focusNodes[index],
                              autofocus: widget.liveStatus == true && isFocused,
                              onFocusChange: (hasFocus) {
                                if (hasFocus) _scrollToFocusedItem();
                              },
                              child: GestureDetector(
                                onTap: () => _onItemTap(index),
                                child: Container(
                                  height: screenhgt * 0.108,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isFocused &&
                                              !playPauseButtonFocusNode
                                                  .hasFocus &&
                                              !subtitleButtonFocusNode.hasFocus
                                          ? const Color.fromARGB(
                                              211, 155, 40, 248)
                                          : Colors.transparent,
                                      width: 4.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: isFocused
                                        ? Colors.white24
                                        : Colors.transparent,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Opacity(
                                            opacity: 0.8,
                                            child: isBase64
                                                ? Image.memory(
                                                    _bannerCache[channelId] ??
                                                        _getCachedImage(
                                                            channel.banner ??
                                                                localImage),
                                                    fit: BoxFit.cover)
                                                : CachedNetworkImage(
                                                    imageUrl: channel.banner ??
                                                        localImage,
                                                    fit: BoxFit.cover,
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        const Icon(Icons.error,
                                                            color:
                                                                Colors.white),
                                                  ),
                                          ),
                                        ),
                                        if (isFocused)
                                          Positioned(
                                            left: 8,
                                            bottom: 8,
                                            right: 8,
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                _getFormattedName(channel),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // 5. BOTTOM CONTROLS
                if (_controlsVisible)
                  _buildControls(screenwdt, bottomBarHeight, leftPanelWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls(
      double screenwdt, double bottomBarHeight, double leftPanelWidth) {
    return Positioned(
      bottom: 10,
      left: widget.channelList.isNotEmpty ? leftPanelWidth : 0.0,
      right: 0,
      height: bottomBarHeight,
      child: Container(
        color: Colors.black.withOpacity(0.8),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- UPAR WALI ROW (Play/Pause, Time, Progress Bar, Live Indicator) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Play / Pause Button
                Container(
                  color: playPauseButtonFocusNode.hasFocus
                      ? const Color.fromARGB(200, 16, 62, 99)
                      : Colors.transparent,
                  child: Focus(
                    focusNode: playPauseButtonFocusNode,
                    autofocus: widget.liveStatus == false,
                    onFocusChange: (hasFocus) => setState(() {}),
                    child: GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        width: 24,
                        height: 24,
                        color: Colors.transparent,
                        child: ClipRect(
                          child: Transform.scale(
                            scale: 1.5,
                            child: Image.asset(
                              _isPlaying
                                  ? 'assets/pause.png'
                                  : 'assets/play.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                if (widget.liveStatus == false)

                  // 2. Current Time
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                    child: ListenableBuilder(
                        listenable: Listenable.merge(
                            [_currentPosition, _previewPosition]),
                        builder: (context, child) {
                          final Duration displayPosition =
                              _accumulatedSeekForward > 0 ||
                                      _accumulatedSeekBackward > 0 ||
                                      _isScrubbing
                                  ? _previewPosition.value
                                  : _currentPosition.value;
                          return Text(
                            _formatDuration(displayPosition),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          );
                        }),
                  ),

                // 3. Progress Bar
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onHorizontalDragStart: (details) =>
                            _onScrubStart(details, constraints),
                        onHorizontalDragUpdate: (details) =>
                            _onScrubUpdate(details, constraints),
                        onHorizontalDragEnd: (details) => _onScrubEnd(details),
                        child: Container(
                          height: 30,
                          color: Colors.transparent,
                          child: Center(
                            child: ListenableBuilder(
                                listenable: Listenable.merge([
                                  _currentPosition,
                                  _previewPosition,
                                  _totalDuration
                                ]),
                                builder: (context, child) {
                                  final Duration displayPosition =
                                      _accumulatedSeekForward > 0 ||
                                              _accumulatedSeekBackward > 0 ||
                                              _isScrubbing
                                          ? _previewPosition.value
                                          : _currentPosition.value;
                                  return _buildBeautifulProgressBar(
                                      displayPosition, _totalDuration.value);
                                }),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (widget.liveStatus == false)
                  // 4. Total Time
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 12.0),
                    child: ValueListenableBuilder<Duration>(
                        valueListenable: _totalDuration,
                        builder: (context, totalDuration, child) {
                          return Text(
                            _formatDuration(totalDuration),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          );
                        }),
                  ),

                // 5. Live Indicator
                if (widget.liveStatus == true)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.circle, color: Colors.red, size: 15),
                        SizedBox(width: 5),
                        Text('Live',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                   
              ],
            ),

            // --- NEECHE WALI ROW (Sirf Subtitles) ---
            if (widget.liveStatus == false && activePlayer == 'VLC') ...[
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: subtitleButtonFocusNode.hasFocus
                      ? const Color.fromARGB(200, 16, 62, 99)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: subtitleButtonFocusNode.hasFocus
                          ? Colors.purple
                          : Colors.transparent,
                      width: 2),
                ),
                child: Focus(
                  focusNode: subtitleButtonFocusNode,
                  onFocusChange: (hasFocus) => setState(() {}),
                  child: InkWell(
                    onTap: _showSubtitleMenu,
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.subtitles, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          Text("Subtitles",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBeautifulProgressBar(
      Duration displayPosition, Duration totalDuration) {
    final totalDurationMs = totalDuration.inMilliseconds.toDouble();

    if (totalDurationMs <= 0 || widget.liveStatus == true) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Container(
            height: 8,
            decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4))),
      );
    }

    double playedProgress =
        (displayPosition.inMilliseconds / totalDurationMs).clamp(0.0, 1.0);
    double bufferedProgress = (playedProgress + 0.005).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey[800]!, Colors.grey[700]!],
                  ),
                ),
              ),
              FractionallySizedBox(
                widthFactor: bufferedProgress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[600]!, Colors.grey[500]!],
                    ),
                  ),
                ),
              ),
              FractionallySizedBox(
                widthFactor: playedProgress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF9B28F8),
                        Color(0xFFE62B1E),
                        Color(0xFFFF6B35),
                      ],
                      stops: [0.0, 0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9B28F8).withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // String _getHtmlString() {
  //   final double initialScale = (_controlsVisible && widget.channelList.isNotEmpty) ? 0.7 : 1.0;
  //   final int initialRadius = _controlsVisible ? 24 : 0;
    
  //   return """
  //   <!DOCTYPE html>
  //   <html>
  //   <head>
  //     <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  //     <style>
  //       * { margin: 0; padding: 0; box-sizing: border-box; }
  //       body {
  //         background: #000;
  //         width: 100vw;
  //         height: 100vh;
  //         overflow: hidden;
  //         -webkit-tap-highlight-color: transparent;
  //       }
  //       #wrapper {
  //         position: absolute;
  //         top: 0px; left: 0px; right: 0px; bottom: 0px;
  //         transform: scale($initialScale);
  //         border-radius: ${initialRadius}px;
  //         transition: transform 0.3s ease, border-radius 0.3s ease;
  //         transform-origin: center center;
  //         overflow: hidden;
  //         background: #000;
  //       }
  //       video {
  //         width: 100%; height: 100%;
  //         object-fit: contain; 
  //         background: transparent;
  //         outline: none; border: none;
  //       }
  //       video::-webkit-media-controls { display: none !important; }
  //       video::-webkit-media-controls-enclosure { display: none !important; }
  //     </style>
  //     <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
  //   </head>
  //   <body>
  //     <div id="wrapper">
  //       <video id="video" autoplay playsinline></video>
  //     </div>
  //     <script>
  //       var video = document.getElementById('video');
  //       var wrapper = document.getElementById('wrapper');
  //       var hls;

  //       function setVideoScale(scale, radius) {
  //          wrapper.style.transform = "scale(" + scale + ")";
  //          wrapper.style.borderRadius = radius + "px";
  //       }

  //       function sendState() {
  //         var state = { position: video.currentTime * 1000, duration: video.duration ? video.duration * 1000 : 0, isPlaying: !video.paused, isBuffering: video.readyState < 3 };
  //         window.flutter_inappwebview.callHandler('videoState', state);
  //       }

  //       video.addEventListener('timeupdate', sendState);
  //       video.addEventListener('play', sendState);
  //       video.addEventListener('pause', sendState);
  //       video.addEventListener('waiting', sendState);
  //       video.addEventListener('playing', sendState);
  //       video.addEventListener('loadstart', sendState);
  //       video.addEventListener('loadeddata', sendState);
  //       video.addEventListener('stalled', sendState);
  //       video.addEventListener('canplay', sendState);

  //       function loadNewVideo(src) {
  //         if (Hls.isSupported()) {
  //           if (hls) hls.destroy();
  //           hls = new Hls();
  //           hls.loadSource(src);
  //           hls.attachMedia(video);
  //           hls.on(Hls.Events.MANIFEST_PARSED, function() {
  //             if (hls.levels && hls.levels.length > 0) { hls.currentLevel = hls.levels.length - 1; }
  //             video.play().catch(function(e) { console.log(e); });
  //           });
  //         } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
  //           video.src = src;
  //           video.addEventListener('loadedmetadata', function() { video.play(); });
  //         }
  //       }
  //       loadNewVideo('${_currentModifiedUrl ?? widget.videoUrl}');
  //     </script>
  //   </body>
  //   </html>
  // """;
  // }



  void _updateWebBounds(bool showControls) {
    if (activePlayer != 'WEB' || webViewController == null) return;
    
    // Screen ka size nikalein
    final double screenwdt = MediaQuery.of(context).size.width;
    final double screenhgt = MediaQuery.of(context).size.height;

    // Panels ka size nikalein
    final double leftPanelWidth = screenwdt * 0.15;
    final double topTitleHeight = screenhgt * 0.10;
    final double bottomBarHeight = screenhgt * 0.15;

    // JS ko bhejne ke liye bounds calculate karein
    final double offsetLeft = (showControls && widget.channelList.isNotEmpty) ? leftPanelWidth : 0.0;
    final double offsetTop = showControls ? topTitleHeight : 0.0;
    final double offsetBottom = showControls ? bottomBarHeight : 0.0;
    final double offsetRight = showControls ? 16.0 : 0.0;
    final int radius = showControls ? 24 : 0;

    webViewController?.evaluateJavascript(
        source: "if(typeof window.setVideoBounds === 'function') window.setVideoBounds($offsetLeft, $offsetTop, $offsetRight, $offsetBottom, $radius);");
  }



  String _getHtmlString() {
    return """
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
          background: #000;
          width: 100vw;
          height: 100vh;
          overflow: hidden;
          -webkit-tap-highlight-color: transparent;
        }
        #wrapper {
          position: absolute;
          top: 0px; left: 0px; right: 0px; bottom: 0px; /* Full screen by default */
          transition: top 0.3s ease, left 0.3s ease, right 0.3s ease, bottom 0.3s ease, border-radius 0.3s ease, box-shadow 0.3s ease;
          overflow: hidden;
          background: #000;
        }
        video {
          width: 100%; height: 100%; /* Ye ensure karega video bahar na nikle */
          object-fit: contain; 
          background: transparent;
          outline: none; border: none;
        }
        video::-webkit-media-controls { display: none !important; }
        video::-webkit-media-controls-enclosure { display: none !important; }
      </style>
      <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
    </head>
    <body>
      <div id="wrapper">
        <video id="video" autoplay playsinline></video>
      </div>
      <script>
        var video = document.getElementById('video');
        var wrapper = document.getElementById('wrapper');
        var hls;

        // JS Function jo Flutter call karega
        window.setVideoBounds = function(l, t, r, b, rad) {
           wrapper.style.left = l + "px";
           wrapper.style.top = t + "px";
           wrapper.style.right = r + "px";
           wrapper.style.bottom = b + "px";
           wrapper.style.borderRadius = rad + "px";
           
           if(l === 0 && t === 0) {
               wrapper.style.boxShadow = "none";
           } else {
               wrapper.style.boxShadow = "0px 0px 20px 5px rgba(0,0,0,0.5)";
           }
        };

        function sendState() {
          var state = { position: video.currentTime * 1000, duration: video.duration ? video.duration * 1000 : 0, isPlaying: !video.paused, isBuffering: video.readyState < 3 };
          window.flutter_inappwebview.callHandler('videoState', state);
        }

        video.addEventListener('timeupdate', sendState);
        video.addEventListener('play', sendState);
        video.addEventListener('pause', sendState);
        video.addEventListener('waiting', sendState);
        video.addEventListener('playing', sendState);
        video.addEventListener('loadstart', sendState);
        video.addEventListener('loadeddata', sendState);
        video.addEventListener('stalled', sendState);
        video.addEventListener('canplay', sendState);

        function loadNewVideo(src) {
          if (Hls.isSupported()) {
            if (hls) hls.destroy();
            hls = new Hls();
            hls.loadSource(src);
            hls.attachMedia(video);
            hls.on(Hls.Events.MANIFEST_PARSED, function() {
              if (hls.levels && hls.levels.length > 0) { hls.currentLevel = hls.levels.length - 1; }
              video.play().catch(function(e) { console.log(e); });
            });
          } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
            video.src = src;
            video.addEventListener('loadedmetadata', function() { video.play(); });
          }
        }
        loadNewVideo('${_currentModifiedUrl ?? widget.videoUrl}');
      </script>
    </body>
    </html>
    """;
  }

  void _focusAndScrollToInitialItem() {
    if (_isDisposing) return;
    if (!mounted ||
        focusNodes.isEmpty ||
        _focusedIndex < 0 ||
        _focusedIndex >= focusNodes.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _isDisposing) return;
        FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
      });
      return;
    }
    _scrollToFocusedItem();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposing) return;
      if (widget.liveStatus == false) {
        FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
      } else {
        FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
      }
    });
  }

  void _changeFocusAndScroll(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.channelList.length || _isDisposing)
      return;
    setState(() {
      _focusedIndex = newIndex;
    });
    _scrollToFocusedItem();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposing) return;
      FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
    });
  }

  void _scrollToFocusedItem() {
    if (_isDisposing) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _isDisposing ||
          _focusedIndex < 0 ||
          !_scrollController.hasClients ||
          _focusedIndex >= focusNodes.length) return;
      final screenhgt = MediaQuery.of(context).size.height;
      final double itemHeight = (screenhgt * 0.108) + 16.0;
      final double viewportHeight = screenhgt * 0.88;
      final double targetOffset = (itemHeight * _focusedIndex) -
          (viewportHeight / 2) +
          (itemHeight / 2);
      final double clampedOffset = targetOffset.clamp(
          _scrollController.position.minScrollExtent,
          _scrollController.position.maxScrollExtent);
      _scrollController.jumpTo(clampedOffset);
    });
  }

  // void _resetHideControlsTimer() {
  //   _hideControlsTimer?.cancel();
  //   if (_isDisposing) return;

  //   if (!_controlsVisible) {
  //     setState(() {
  //       _controlsVisible = true;
  //     });

  //     // if (activePlayer == 'WEB') {
  //     //   webViewController?.evaluateJavascript(
  //     //       source: "if(typeof setVideoScale === 'function') setVideoScale(0.7, 24);");
  //     // }

  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (!mounted || _isDisposing) return;
  //       if (widget.liveStatus == false || widget.channelList.isEmpty) {
  //         FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
  //       } else {
  //         FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
  //         _scrollToFocusedItem();
  //       }
  //     });
  //   }
  //   _startHideControlsTimer();
  // }

void _resetHideControlsTimer() {
    _hideControlsTimer?.cancel();
    if (_isDisposing) return;

    if (!_controlsVisible) {
      setState(() {
        _controlsVisible = true;
      });

      // --- ADD THIS HERE ---
      _updateWebBounds(true);
      // ---------------------

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _isDisposing) return;
        if (widget.liveStatus == false || widget.channelList.isEmpty) {
          FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
        } else {
          FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
          _scrollToFocusedItem();
        }
      });
    }
    _startHideControlsTimer();
  }

  // void _startHideControlsTimer() {
  //   _hideControlsTimer?.cancel();
  //   if (_isDisposing) return;
  //   _hideControlsTimer = Timer(const Duration(seconds: 10), () {
  //     if (mounted && !_isDisposing) {
  //       setState(() {
  //         _controlsVisible = false;
  //       });

  //       // if (activePlayer == 'WEB') {
  //       //   webViewController?.evaluateJavascript(
  //       //       source: "if(typeof setVideoScale === 'function') setVideoScale(1.0, 0);");
  //       // }

  //       FocusScope.of(context).requestFocus(_mainFocusNode);
  //     }
  //   });
  // }



void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    if (_isDisposing) return;
    _hideControlsTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && !_isDisposing) {
        setState(() {
          _controlsVisible = false;
        });

        // --- ADD THIS HERE ---
        _updateWebBounds(false);
        // ---------------------

        FocusScope.of(context).requestFocus(_mainFocusNode);
      }
    });
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) duration = Duration.zero;
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String _getFormattedName(dynamic channel) {
    String name = "";
    try {
      name = channel.name?.toString() ?? "";
    } catch (_) {
      try {
        name = channel['name']?.toString() ?? "";
      } catch (_) {}
    }
    String? cNo;
    try {
      cNo = channel.channel_number?.toString();
    } catch (_) {
      try {
        cNo = channel.channelNumber?.toString();
      } catch (_) {
        try {
          cNo = channel['channel_number']?.toString() ??
              channel['channelNumber']?.toString();
        } catch (_) {
          cNo = null;
        }
      }
    }
    if (cNo != null && cNo.trim().isNotEmpty && cNo != "null")
      return "${cNo.trim()} $name";
    return name;
  }

  void _safeDispose() {
    if (_isDisposing) return;
    _isDisposing = true;
    _hideControlsTimer?.cancel();
    _seekTimer?.cancel();
    _networkCheckTimer?.cancel();
    _keyRepeatTimer?.cancel();

    if (vlcController != null) {
      vlcController!.removeListener(_vlcListener);
      vlcController!.stop();
    }
    KeepScreenOn.turnOff();
  }

  @override
  void dispose() {
    _safeDispose();
    _mainFocusNode.dispose();
    _currentPosition.dispose();
    _totalDuration.dispose();
    _previewPosition.dispose();

    for (var node in focusNodes) {
      node.dispose();
    }
    playPauseButtonFocusNode.dispose();
    subtitleButtonFocusNode.dispose();
    _scrollController.dispose();
    vlcController?.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}


