

// import 'package:flutter/material.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';

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
//   late VlcPlayerController _videoPlayerController;

//   @override
//   void initState() {
//     super.initState();
//     // Controller initialize karein
//     _videoPlayerController = VlcPlayerController.network(
//       widget.videoUrl,
//       hwAcc: HwAcc.full, // Hardware acceleration for better performance
//       autoPlay: true,    // Video load hote hi play shuru ho jayega
//       options: VlcPlayerOptions(),
//     );
//   }

//   @override
//   void dispose() {
//     // Memory leak rokne ke liye controller dispose karna zaroori hai
//     _videoPlayerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(title: const Text("VLC Player Demo")),
//       body: Center(
//         child: VlcPlayer(
//           controller: _videoPlayerController,
//           aspectRatio: 16 / 9, // Video ka size maintain karne ke liye
//           placeholder: const Center(
//             child: CircularProgressIndicator(), // Buffering ke waqt loader dikhega
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
// import 'package:video_player/video_player.dart';

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
//   // CHANGE 1: 'late' hataya aur '?' lagaya taaki ye shuru mein null reh sake
//   VideoPlayerController? _controller;
//   bool _isError = false;

//   @override
//   void initState() {
//     super.initState();
//     _initPlayerWithSecureUrl();
//   }

// Future<void> _initPlayerWithSecureUrl() async {
//   try {
//     // String secureUrl = await SecureUrlService.getSecureUrl(
//     //     '',
//     //     expirySeconds: 6;

//     // print('DEBUG: Generated URL: $secureUrl'); // Check if this URL works in a browser

//     if (!mounted) return;

//     // final controller = VideoPlayerController.networkUrl(
//     //   Uri.parse('https://dashboard.cpplayers.com/api/video/play/FRpCb9WhFXIeHpFFtNO79947oThNFJ5zxrRbHwkY54KwM84YPDcDTQnhhusKhORc'),
//     //   // Uncomment these if your server requires them to prevent 403 Forbidden errors
//     //   /* httpHeaders: {
//     //     'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36...',
//     //   },
//     //   */
//     // );

//     // CHANGE 2: Naya controller banaya
//       final controller = VideoPlayerController.networkUrl(
//         Uri.parse('https://dashboard.cpplayers.com/api/video/play/J3yuPm5bSxkXCIeksC6oaeetNqS2B9IGGcGcyaYWM1iQDXAY4EP0EMaXzNWfwwkg'),
//         // 👇 Add these headers to fix the 403 Error
//         httpHeaders: {
//           'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
//           'Referer': 'https://dashboard.cpplayers.com/', // Important: Tells the server you are coming from their site
//         },
//       );

//     // --- ADD THIS LISTENER HERE ---
//     controller.addListener(() {
//       // This prints errors that happen during playback/buffering
//       if (controller.value.hasError) {
//         print("🔴 VIDEO ERROR: ${controller.value.errorDescription}");
//       }

//       // Optional: Print buffering status to see if it's stuck loading
//       if (controller.value.isBuffering) {
//         print("🟡 Video is Buffering...");
//       }
//     });
//     // -----------------------------

//     await controller.initialize();

//     if (mounted) {
//       setState(() {
//         _controller = controller;
//         _controller!.play();
//       });
//     }
//   } catch (e, stackTrace) {
//     // Print the full stack trace to see exactly where it failed
//     print("🔴 Initialization Exception: $e");
//     print("Stack Trace: $stackTrace");

//     if (mounted) {
//       setState(() {
//         _isError = true;
//       });
//     }
//   }
// }

//   @override
//   void dispose() {
//     // CHANGE 4: Null check ke sath dispose karein
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Flutter Video Player")),
//       body: Center(
//         child: _isError
//             ? const Text("Video Play Error", style: TextStyle(color: Colors.red))
//             // CHANGE 5: Check karein ki controller null to nahi hai
//             : (_controller != null && _controller!.value.isInitialized)
//                 ? AspectRatio(
//                     aspectRatio: _controller!.value.aspectRatio,
//                     child: Stack(
//                       alignment: Alignment.bottomCenter,
//                       children: [
//                         VideoPlayer(_controller!),
//                         _buildControls(),
//                       ],
//                     ),
//                   )
//                 : const CircularProgressIndicator(), // Jab tak null hai, loader dikhega
//       ),
//     );
//   }

//   Widget _buildControls() {
//     // Safety check
//     if (_controller == null) return const SizedBox.shrink();

//     return Container(
//       color: Colors.black45,
//       height: 50,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           IconButton(
//             icon: Icon(
//               _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
//               color: Colors.white,
//             ),
//             onPressed: () {
//               setState(() {
//                 _controller!.value.isPlaying
//                     ? _controller!.pause()
//                     : _controller!.play();
//               });
//             },
//           ),
//         ],
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

//   @override
//   void dispose() {
//     print("🗑️ VideoScreen dispose called");
//     _safeDispose();
//     super.dispose();
//   }

//   // 🆕 Improved back button handler
//   Future<bool> _onWillPop() async {
//     print("🔙 Back button pressed");

//     if (_isDisposing) {
//       return false;
//     }

//     setState(() {
//       _loadingVisible = true;
//     });

//     // Safe disposal और फिर navigate
//     await _safeDispose();

//     return true;
//   }

//   void _focusAndScrollToInitialItem() {
//     if (_focusedIndex < 0 || _focusedIndex >= focusNodes.length || !mounted) {
//       return;
//     }

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!_scrollController.hasClients) return;

//       final double itemHeight = (screenhgt * 0.18) + 16.0;
//       final double targetOffset = (itemHeight * _focusedIndex) - 40.0;
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

//       final double itemHeight = (screenhgt * 0.18) + 16.0;
//       final double targetOffset = (itemHeight * _focusedIndex) - 40.0;
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
//           } else if (_focusedIndex < widget.channelList.length) {
//             FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//           }
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

//   Future<void> _attemptResumeLiveStream() async {
//     if (!mounted ||
//         _isAttemptingResume ||
//         _controller == null ||
//         widget.liveStatus == false) {
//       return;
//     }

//     setState(() {
//       _isAttemptingResume = true;
//       _loadingVisible = true;
//     });
//     print("⚠️ Detectado atasco en Live stream. Intentando resumir...");

//     try {
//       final urlToResume = _buildVlcUrl(_currentModifiedUrl ?? widget.videoUrl);
//       await _retryPlayback(urlToResume, 3);

//       _lastPlayingTime = DateTime.now();
//       _stallCounter = 0;
//       _lastPositionCheck = Duration.zero;
//       print("✅ Intento de resumen finalizado.");
//     } catch (e) {
//       print("❌ Error durante el resumen del live stream: $e");
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isAttemptingResume = false;
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
//       } else if (playingState == PlayingState.paused) {
//         _lastPlayingTime = DateTime.now();
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
//         alignment: 0.01,
//       );
//     });
//   }

//   void _startNetworkMonitor() {
//     _networkCheckTimer = Timer.periodic(Duration(seconds: 5), (_) async {
//       bool isConnected = await _isInternetAvailable();
//       if (!isConnected && !_wasDisconnected) {
//         _wasDisconnected = true;
//         print("Red desconectada");
//       } else if (isConnected && _wasDisconnected) {
//         _wasDisconnected = false;
//         print("Red reconectada. Intentando resumir video...");
//         if (_controller?.value.isInitialized ?? false) {
//           _onNetworkReconnected();
//         }
//       }
//     });
//   }

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
//         await _retryPlayback(fullUrl, 3);
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

//           await _retryPlayback(fullUrl, 3);

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
//     final String liveCaching = "live-caching=60000";
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

//   Future<void> _initializeVLCController(String baseUrl) async {
//     if (_isDisposing || !mounted) return;

//   // 1. Clear previous state immediately
//   setState(() {
//     _isVideoInitialized = false;
//     _loadingVisible = true;
//   });

//   // 2. Cleanup old controller synchronously if possible
//   final oldController = _controller;
//   _controller = null; 
//   await oldController?.dispose();

//   // 3. Setup new instance
//   try {
//     // setState(() {
//     //   _loadingVisible = true;
//     // });

//     _currentModifiedUrl = baseUrl;
//     final String fullVlcUrl = _buildVlcUrl(baseUrl);
//     // final String fullVlcUrl = baseUrl;
//     print('fullVlcUrl: $fullVlcUrl');
//     _lastPlayingTime = DateTime.now();
//     _lastPositionCheck = Duration.zero;
//     _stallCounter = 0;
//     _hasStartedPlaying = false;

//     print("Inicializando con URL: $fullVlcUrl");

//     _controller = VlcPlayerController.network(
//       fullVlcUrl,
//       hwAcc: HwAcc.auto,
//       options: VlcPlayerOptions(
//         video: VlcVideoOptions([
//           VlcVideoOptions.dropLateFrames(true),
//           VlcVideoOptions.skipFrames(true),
//         ]),
//       ),
//     );

//     await _retryPlayback(fullVlcUrl, 3);
//     _controller!.addListener(_vlcListener);

//     setState(() {
//       _isVideoInitialized = true;
//     });
//     } catch (e) {
//      // Handle failure
//   }
//   }

//   Future<void> _retryPlayback(String url, int retries) async {
//     for (int i = 0; i < retries; i++) {
//       if (!mounted || _controller == null) return;
//       try {
//         print("Intento ${i + 1}/$retries: Deteniendo player...");
//         await _controller!.stop();
//         print("Asignando media: $url");
//         await _controller!.setMediaFromNetwork(url);
//         await _controller!.play();
//         print("Comando Play enviado.");
//         return;
//       } catch (e) {
//         print("Reintento ${i + 1} fallido: $e");
//         if (i < retries - 1) {
//           await Future.delayed(Duration(seconds: 1));
//         }
//       }
//     }
//     print("Todos los reintentos fallaron para: $url");
//   }

//   Future<void> _onItemTap(int index) async {
//     setState(() {
//       _loadingVisible = true;
//       _focusedIndex = index;
//     });

//     var selectedChannel = widget.channelList[index];

//     String secureUrl = await SecureUrlService.getSecureUrl(
//         selectedChannel.url.toString(),
//         expirySeconds: 10);

//     _currentModifiedUrl = secureUrl;
//     final String fullVlcUrl = _buildVlcUrl(secureUrl);
//     print("secure+cached URL: $fullVlcUrl");

//     _lastPlayingTime = DateTime.now();
//     _lastPositionCheck = Duration.zero;
//     _stallCounter = 0;
//     _hasStartedPlaying = false;

//     try {
//       if (_controller != null && _controller!.value.isInitialized) {
//         await _retryPlayback(fullVlcUrl, 3);
//         _controller!.addListener(_vlcListener);
//       } else {
//         throw Exception("VLC Controller no inicializado");
//       }
//       _scrollToFocusedItem();
//       _resetHideControlsTimer();
//     } catch (e) {
//       print("Error cambiando de canal: $e");
//     }
//   }

//   void _togglePlayPause() {
//     if (_controller != null && _controller!.value.isInitialized) {
//       _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
//       _lastPlayingTime = DateTime.now();
//       _stallCounter = 0;
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

//   Widget _buildVideoPlayer() {
//     if (!_isVideoInitialized || _controller == null) {
//       return Center(child: CircularProgressIndicator());
//     }
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final screenWidth = constraints.maxWidth;
//         final screenHeight = constraints.maxHeight;
//         final videoWidth = _controller!.value.size?.width ?? screenWidth;
//         final videoHeight = _controller!.value.size?.height ?? screenHeight;
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
//     return WillPopScope(
//       onWillPop: _onWillPop, // 🆕 Improved back button handler
//       child: Scaffold(
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
//       left: 0,
//       right: MediaQuery.of(context).size.width * 0.78,
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
//                   width: screenwdt * 0.3,
//                   height: screenhgt * 0.18,
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




import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
import 'package:mobi_tv_entertainment/components/widgets/small_widgets/rainbow_page.dart';
import 'package:mobi_tv_entertainment/main.dart';

class GlobalVariables {
  static String unUpdatedUrl = '';
  static Duration position = Duration.zero;
  static Duration duration = Duration.zero;
  static String banner = '';
  static String name = '';
  static bool liveStatus = false;
}

class RefreshPageEvent {
  final String pageId;
  RefreshPageEvent(this.pageId);
}

class VideoScreen extends StatefulWidget {
  final String videoUrl;
  final String name;
  final bool liveStatus;
  final String updatedAt;
  final List<dynamic> channelList;
  final String bannerImageUrl;
  final int? videoId;
  final String source;

  VideoScreen({
    required this.videoUrl,
    required this.updatedAt,
    required this.channelList,
    required this.bannerImageUrl,
    required this.videoId,
    required this.source,
    required this.name,
    required this.liveStatus,
  });

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
  VlcPlayerController? _controller;
  bool _controlsVisible = true;
  late Timer _hideControlsTimer;
  bool _isBuffering = false;
  bool _isVideoInitialized = false;
  int _focusedIndex = 0;
  List<FocusNode> focusNodes = [];
  final ScrollController _scrollController = ScrollController();
  final FocusNode playPauseButtonFocusNode = FocusNode();

  bool _loadingVisible = false;
  Duration _lastKnownPosition = Duration.zero;
  Timer? _networkCheckTimer;
  bool _wasDisconnected = false;
  String? _currentModifiedUrl;

  bool _isAttemptingResume = false;
  DateTime _lastPlayingTime = DateTime.now();
  Duration _lastPositionCheck = Duration.zero;
  int _stallCounter = 0;
  bool _hasStartedPlaying = false;

  bool _isScrubbing = false;
  bool _isUserPaused = false; // Tracks if the user clicked the pause button

  Map<String, Uint8List> _bannerCache = {};

  // 🆕 केवल disposal के लिए flag
  bool _isDisposing = false;

  Uint8List _getCachedImage(String base64String) {
    try {
      if (!_bannerCache.containsKey(base64String)) {
        _bannerCache[base64String] = base64Decode(base64String.split(',').last);
      }
      return _bannerCache[base64String]!;
    } catch (e) {
      print('Error procesando imagen: $e');
      return Uint8List.fromList([0, 0, 0, 0]);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    KeepScreenOn.turnOn();

    _focusedIndex = widget.channelList.indexWhere(
      (channel) => channel.id.toString() == widget.videoId.toString(),
    );
    _focusedIndex = (_focusedIndex >= 0) ? _focusedIndex : 0;

    focusNodes = List.generate(
      widget.channelList.length,
      (index) => FocusNode(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusAndScrollToInitialItem();
    });
    // _initializeVLCController(widget.videoUrl);
    _initPlayerWithSecureUrl();
    _startHideControlsTimer();
    _startNetworkMonitor();
    _startPositionUpdater();
  }



  // Updated VideoScreen State with stability fixes and English logging

  // 1. Improved Controller Initialization
  Future<void> _initializeVLCController(String baseUrl) async {
    if (_isDisposing || !mounted) return;

    print("--- Initializing Video Player ---");
    
    setState(() {
      _isVideoInitialized = false;
      _loadingVisible = true;
    });

    // CRITICAL: Clean up existing controller before creating a new one
    try {
      if (_controller != null) {
        _controller!.removeListener(_vlcListener);
        await _controller!.stop();
        await _controller!.dispose();
        _controller = null;
        print("Cleanup: Previous controller disposed successfully.");
      }
    } catch (e) {
      print("Cleanup Warning: Error disposing old controller: $e");
    }

    try {
      _currentModifiedUrl = baseUrl;
      final String fullVlcUrl = _buildVlcUrl(baseUrl);
      
      _lastPlayingTime = DateTime.now();
      _lastPositionCheck = Duration.zero;
      _stallCounter = 0;
      _hasStartedPlaying = false;

      print("Source: $fullVlcUrl");

      _controller = VlcPlayerController.network(
        fullVlcUrl,
        hwAcc: HwAcc.auto,
        options: VlcPlayerOptions(
          video: VlcVideoOptions([
            VlcVideoOptions.dropLateFrames(true),
            VlcVideoOptions.skipFrames(true),
          ]),
        ),
      );

      // Wait for initialization before adding listener
      await _retryPlayback(fullVlcUrl, 3);
      
      if (_controller != null && mounted) {
        _controller!.addListener(_vlcListener);
        setState(() {
          _isVideoInitialized = true;
        });
        print("Status: Video Initialized successfully.");
      }
    } catch (e) {
      print("Error: Initialization failed: $e");
      if (mounted) setState(() => _loadingVisible = false);
    }
  }

  // 2. Updated Playback Retry Logic
  Future<void> _retryPlayback(String url, int retries) async {
    for (int i = 0; i < retries; i++) {
      if (!mounted || _controller == null) return;
      try {
        print("Playback Attempt ${i + 1}/$retries");
        await _controller!.setMediaFromNetwork(url);
        await _controller!.play();
        return; 
      } catch (e) {
        print("Playback Attempt ${i + 1} failed: $e");
        if (i < retries - 1) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }
  }

  // 3. Robust Item Tap (Channel Change)
  Future<void> _onItemTap(int index) async {
    if (!mounted || _isDisposing) return;

    setState(() {
      _loadingVisible = true;
      _focusedIndex = index;
    });

    try {
      var selectedChannel = widget.channelList[index];
      print("Switching to Channel: ${selectedChannel.name}");

      String secureUrl = await SecureUrlService.getSecureUrl(
          selectedChannel.url.toString(),
          expirySeconds: 10);

      // Re-initialize to ensure a fresh player state for the new stream
      await _initializeVLCController(secureUrl);
      
      _scrollToFocusedItem();
      _resetHideControlsTimer();
    } catch (e) {
      print("Error: Failed to switch channel: $e");
      if (mounted) setState(() => _loadingVisible = false);
    }
  }

  // 4. English Logging for Monitor & Network
  void _startNetworkMonitor() {
    _networkCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      bool isConnected = await _isInternetAvailable();
      if (!isConnected && !_wasDisconnected) {
        _wasDisconnected = true;
        print("Network: Connection lost.");
      } else if (isConnected && _wasDisconnected) {
        _wasDisconnected = false;
        print("Network: Connection restored. Resuming playback...");
        if (_controller?.value.isInitialized ?? false) {
          _onNetworkReconnected();
        }
      }
    });
  }

  // Future<void> _attemptResumeLiveStream() async {
  //   if (!mounted || _isAttemptingResume || _controller == null || widget.liveStatus == false) {
  //     return;
  //   }

  //   setState(() {
  //     _isAttemptingResume = true;
  //     _loadingVisible = true;
  //   });
    
  //   print("Stability: Live stream stall detected. Attempting recovery...");

  //   try {
  //     final urlToResume = _buildVlcUrl(_currentModifiedUrl ?? widget.videoUrl);
  //     await _retryPlayback(urlToResume, 4);
  //     _lastPlayingTime = DateTime.now();
  //     _stallCounter = 0;
  //     print("Stability: Recovery process finished.");
  //   } catch (e) {
  //     print("Error: Recovery failed: $e");
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isAttemptingResume = false);
  //     }
  //   }
  // }



  Future<void> _attemptResumeLiveStream() async {
  if (!mounted || _isAttemptingResume || _controller == null || widget.liveStatus == false) {
    return;
  }

  setState(() {
    _isAttemptingResume = true;
    _loadingVisible = true;
  });

  print("Stability: Live stream stall detected. Attempting recovery with NEW TOKEN...");

  try {
    // ✅ FIX: Regenerate the secure URL (Refresh Token)
    // If the old token expired after 1 hour, this gets a fresh one.
    String newSecureUrl = widget.videoUrl; 
    try {
       newSecureUrl = await SecureUrlService.getSecureUrl(
          widget.videoUrl, 
          expirySeconds: 10
       );
    } catch(e) {
       print("Token refresh failed, using original: $e");
    }

    // Update the current modified URL reference
    _currentModifiedUrl = newSecureUrl;
    
    final urlToResume = _buildVlcUrl(newSecureUrl);
    
    // Use a slightly more aggressive retry since we know we are stalled
    await _retryPlayback(urlToResume, 4);

    _lastPlayingTime = DateTime.now();
    _stallCounter = 0;
    
    // Ensure we are not in user-paused state after auto-resume
    _isUserPaused = false; 

    print("Stability: Recovery process finished.");
  } catch (e) {
    print("Error: Recovery failed: $e");
  } finally {
    if (mounted) {
      setState(() => _isAttemptingResume = false);
    }
  }
}

  // 🆕 Safe disposal method
  Future<void> _safeDispose() async {
    if (_isDisposing) return;

    _isDisposing = true;
    print("🔄 Safe disposal started...");

    // Cancel all timers
    _hideControlsTimer.cancel();
    _networkCheckTimer?.cancel();
    _seekTimer?.cancel();

    // Dispose focus nodes
    focusNodes.forEach((node) => node.dispose());
    playPauseButtonFocusNode.dispose();
    _scrollController.dispose();

    // Dispose VLC controller safely
    try {
      if (_controller != null) {
        _controller?.removeListener(_vlcListener);
        await _controller?.stop();
        await _controller?.dispose();
        _controller = null;
        print("✅ VLC Controller safely disposed");
      }
    } catch (e) {
      print("⚠️ Warning during VLC controller disposal: $e");
    }

    KeepScreenOn.turnOff();
    WidgetsBinding.instance.removeObserver(this);

    print("✅ Safe disposal completed");
  }

  @override
  void dispose() {
    print("🗑️ VideoScreen dispose called");
    _safeDispose();
    super.dispose();
  }

  // 🆕 Improved back button handler
  Future<bool> _onWillPop() async {
    print("🔙 Back button pressed");

    if (_isDisposing) {
      return false;
    }

    setState(() {
      _loadingVisible = true;
    });

    // Safe disposal और फिर navigate
    await _safeDispose();

    return true;
  }

  void _focusAndScrollToInitialItem() {
    if (_focusedIndex < 0 || _focusedIndex >= focusNodes.length || !mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      final double itemHeight = (screenhgt * 0.18) + 16.0;
      final double targetOffset = (itemHeight * _focusedIndex) - 40.0;
      final double clampedOffset = targetOffset.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.jumpTo(clampedOffset);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.liveStatus == false) {
          FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
        } else if (widget.channelList.isNotEmpty &&
            _focusedIndex < focusNodes.length) {
          FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
        } else {
          FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
        }
      });
    });
  }

  void _changeFocusAndScroll(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.channelList.length) {
      return;
    }

    setState(() {
      _focusedIndex = newIndex;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients || !mounted) return;

      final double itemHeight = (screenhgt * 0.18) + 16.0;
      final double targetOffset = (itemHeight * _focusedIndex) - 40.0;
      final double clampedOffset = targetOffset.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.jumpTo(clampedOffset);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
        }
      });
    });
  }

  Future<void> _initPlayerWithSecureUrl() async {
    try {
      // 1. Pehle URL ko secure (resolve) karein
      String secureUrl = await SecureUrlService.getSecureUrl(widget.videoUrl,
          expirySeconds: 10);
      print('secureUrlinitializing : $secureUrl');
      if (!mounted) return;

      // 2. Ab secure URL ko initialize function mein bhejein
      // Yeh function andar jaakar _buildVlcUrl call karega aur caching jod dega
      _initializeVLCController(secureUrl);
    } catch (e) {
      print("Secure URL error: $e");
      // Fallback: Agar secure fail ho to original try karein
      await _initializeVLCController(widget.videoUrl);
    }
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      _resetHideControlsTimer();

      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          if (playPauseButtonFocusNode.hasFocus) {
            if (widget.liveStatus == false && widget.channelList.isNotEmpty) {
              FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
            }
          } else if (_focusedIndex > 0) {
            _changeFocusAndScroll(_focusedIndex - 1);
          }
          break;

        case LogicalKeyboardKey.arrowDown:
          if (_focusedIndex < widget.channelList.length - 1) {
            _changeFocusAndScroll(_focusedIndex + 1);
          } else if (_focusedIndex < widget.channelList.length) {
            FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
          }
          break;

        case LogicalKeyboardKey.arrowRight:
          if (widget.liveStatus == false) {
            _seekForward();
          }
          if (focusNodes.any((node) => node.hasFocus)) {
            FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
          }
          break;

        case LogicalKeyboardKey.arrowLeft:
          if (widget.liveStatus == false) {
            _seekBackward();
          }
          if (playPauseButtonFocusNode.hasFocus &&
              widget.channelList.isNotEmpty) {
            FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
          }
          break;

        case LogicalKeyboardKey.select:
        case LogicalKeyboardKey.enter:
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
          break;
      }
    }
  }

  // Future<void> _attemptResumeLiveStream() async {
  //   if (!mounted ||
  //       _isAttemptingResume ||
  //       _controller == null ||
  //       widget.liveStatus == false) {
  //     return;
  //   }

  //   setState(() {
  //     _isAttemptingResume = true;
  //     _loadingVisible = true;
  //   });
  //   print("⚠️ Detectado atasco en Live stream. Intentando resumir...");

  //   try {
  //     final urlToResume = _buildVlcUrl(_currentModifiedUrl ?? widget.videoUrl);
  //     await _retryPlayback(urlToResume, 4);

  //     _lastPlayingTime = DateTime.now();
  //     _stallCounter = 0;
  //     _lastPositionCheck = Duration.zero;
  //     print("✅ Intento de resumen finalizado.");
  //   } catch (e) {
  //     print("❌ Error durante el resumen del live stream: $e");
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isAttemptingResume = false;
  //       });
  //     }
  //   }
  // }

  void _vlcListener() {
    if (!mounted || _controller == null || !_controller!.value.isInitialized)
      return;

    final VlcPlayerValue value = _controller!.value;
    final bool isBuffering = value.isBuffering;
    final PlayingState playingState = value.playingState;

    if (widget.liveStatus == true && !_isAttemptingResume) {
      if (playingState == PlayingState.playing) {
        _lastPlayingTime = DateTime.now();
        if (!_hasStartedPlaying) {
          _hasStartedPlaying = true;
        }
      } else if (playingState == PlayingState.buffering && _hasStartedPlaying) {
        final stalledDuration = DateTime.now().difference(_lastPlayingTime);
        if (stalledDuration > Duration(seconds: 8)) {
          print(
              "⚠️ Atasco (Listener): Buffering por ${stalledDuration.inSeconds} seg.");
          _attemptResumeLiveStream();
          _lastPlayingTime = DateTime.now();
        }
      } else if (playingState == PlayingState.error) {
        print("⚠️ Atasco (Listener): Player en estado de error.");
        _attemptResumeLiveStream();
        _lastPlayingTime = DateTime.now();
      } else if ((playingState == PlayingState.stopped ||
              playingState == PlayingState.ended) &&
          _hasStartedPlaying) {
        final stalledDuration = DateTime.now().difference(_lastPlayingTime);
        if (stalledDuration > Duration(seconds: 5)) {
          print("⚠️ Atasco (Listener): Player parado inesperadamente.");
          _attemptResumeLiveStream();
          _lastPlayingTime = DateTime.now();
        }
      } 
      // else if (playingState == PlayingState.paused) {
      //   _lastPlayingTime = DateTime.now();
      // }
      // Inside _vlcListener...

} else if (playingState == PlayingState.paused) {
  // ✅ FIX: Only reset timer if the USER paused it.
  if (_isUserPaused) {
    _lastPlayingTime = DateTime.now();
  } else {
    // If user didn't pause, but state is Paused, it's a NETWORK CRASH.
    // Treat it like buffering/error.
    final stalledDuration = DateTime.now().difference(_lastPlayingTime);
    if (stalledDuration > Duration(seconds: 5)) {
      print("⚠️ Auto-Pause detected (Network issue). Force restarting...");
      _attemptResumeLiveStream();
      _lastPlayingTime = DateTime.now();
    }
  }
}
    

    if (mounted) {
      setState(() {
        _isBuffering = isBuffering;

        if (playingState == PlayingState.playing && !isBuffering) {
          _loadingVisible = false;
        } else if (playingState == PlayingState.buffering ||
            playingState == PlayingState.initializing) {
          _loadingVisible = true;
        }

        if (_isAttemptingResume) {
          _loadingVisible = true;
        }
      });
    }
  }

  void _startPositionUpdater() {
    Timer.periodic(Duration(seconds: 2), (_) {
      if (!mounted ||
          _controller == null ||
          !_controller!.value.isInitialized) {
        return;
      }

      final VlcPlayerValue value = _controller!.value;
      final Duration currentPosition = value.position;

      if (mounted && !_isScrubbing) {
        setState(() {
          _lastKnownPosition = currentPosition;
        });
      }

      if (widget.liveStatus == true &&
          !_isAttemptingResume &&
          _hasStartedPlaying) {
        if (value.playingState == PlayingState.playing) {
          if (_lastPositionCheck != Duration.zero &&
              currentPosition == _lastPositionCheck) {
            _stallCounter++;
            print(
                "⚠️ Posición atascada (Fotograma Congelado). Contador: $_stallCounter");
          } else {
            _stallCounter = 0;
          }

          if (_stallCounter >= 3) {
            print("🔴 ATASCADO (Fotograma Congelado). Intentando resumen...");
            _attemptResumeLiveStream();
            _stallCounter = 0;
          }
        } else {
          _stallCounter = 0;
        }
        _lastPositionCheck = currentPosition;
      }
    });
  }

  void _scrollToFocusedItem() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusedIndex < 0 ||
          !_scrollController.hasClients ||
          _focusedIndex >= focusNodes.length) {
        return;
      }
      final context = focusNodes[_focusedIndex].context;
      if (context == null) return;

      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.01,
      );
    });
  }

  // void _startNetworkMonitor() {
  //   _networkCheckTimer = Timer.periodic(Duration(seconds: 5), (_) async {
  //     bool isConnected = await _isInternetAvailable();
  //     if (!isConnected && !_wasDisconnected) {
  //       _wasDisconnected = true;
  //       print("Red desconectada");
  //     } else if (isConnected && _wasDisconnected) {
  //       _wasDisconnected = false;
  //       print("Red reconectada. Intentando resumir video...");
  //       if (_controller?.value.isInitialized ?? false) {
  //         _onNetworkReconnected();
  //       }
  //     }
  //   });
  // }

  // Future<void> _onNetworkReconnected() async {
  //   if (_controller == null || _currentModifiedUrl == null) return;

  //   final fullUrl = _buildVlcUrl(_currentModifiedUrl!);
  //   print("Reconectando a: $fullUrl");

  //   try {
  //     if (widget.liveStatus == true) {
  //       await _retryPlayback(fullUrl, 3);
  //     } else {
  //       await _retryPlayback(fullUrl, 3);
  //       if (_lastKnownPosition != Duration.zero) {
  //         _seekToPosition(_lastKnownPosition);
  //       }
  //       await _controller!.play();
  //     }
  //   } catch (e) {
  //     print("Error durante reconexión: $e");
  //   }
  // }

  Future<void> _onNetworkReconnected() async {
    if (_controller == null || _currentModifiedUrl == null) return;

    final fullUrl = _buildVlcUrl(_currentModifiedUrl!);
    print("Reconectando a: $fullUrl");

    try {
      if (widget.liveStatus == true) {
        // --- Lógica de Live Stream (sin cambios) ---
        print("Reconexión Live Stream: Reiniciando stream...");
        await _retryPlayback(fullUrl, 4);
      } else {
        // --- 🆕 Lógica MEJORADA para VOD (video no-en-vivo) ---
        print("Reconexión VOD: Intentando resumir desde $_lastKnownPosition");

        // setState(() { _loadingVisible = true; }); // Opcional: mostrar loading

        try {
          // Plan A: Intentar "desatascar" el player sin recargar.
          // Esto es mucho más rápido y fluido para el usuario.

          // Pausar primero para asegurar el estado
          await _controller!.pause();
          await Future.delayed(const Duration(milliseconds: 100));

          if (_lastKnownPosition != Duration.zero) {
            // _seekToPosition ya incluye el comando de play() al final.
            // Esto forzará al player a re-bufferizar desde ese punto.
            await _seekToPosition(_lastKnownPosition);
          } else {
            // Si no hay posición guardada, solo darle play
            await _controller!.play();
          }
          print("✅ VOD Resumido (Plan A) tras reconexión.");
        } catch (e) {
          // Plan B: Si el Plan A falla (el controller está muy roto),
          // recurrir al método de recarga completa como último recurso.
          print("⚠️ Plan A falló. Recurriendo a Plan B (Recarga). Error: $e");

          await _retryPlayback(fullUrl, 4);

          // Esperar un momento a que el video se cargue después de 'setMedia'
          await Future.delayed(const Duration(seconds: 2));

          if (_lastKnownPosition != Duration.zero) {
            await _seekToPosition(_lastKnownPosition);
          }
          print("✅ VOD Resumido (Plan B) tras reconexión.");
        }
      }
    } catch (e) {
      print("❌ Error crítico durante reconexión: $e");
    }
    // finally {
    //   if (mounted) setState(() { _loadingVisible = false; }); // Opcional
    // }
  }

  Future<bool> _isInternetAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  String _buildVlcUrl(String baseUrl) {
    final String networkCaching = "network-caching=60000";
    final String liveCaching = "live-caching=30000";
    final String fileCaching = "file-caching=20000";
    final String rtspTcp = "rtsp-tcp";

    if (widget.liveStatus == true) {
      return '$baseUrl?$networkCaching&$liveCaching&$fileCaching&$rtspTcp';
    } else {
      return '$baseUrl?$networkCaching&$fileCaching&$rtspTcp';
    }
  }

  bool _isSeeking = false;
  Future<void> _seekToPosition(Duration position) async {
    if (_isSeeking || _controller == null) return;
    _isSeeking = true;
    try {
      print("Buscando posición: $position");
      await _controller!.seekTo(position);
      await _controller!.play();
    } catch (e) {
      print("Error durante seek: $e");
    } finally {
      await Future.delayed(Duration(milliseconds: 500));
      _isSeeking = false;
    }
  }

  // Future<void> _initializeVLCController(String baseUrl) async {
  //   if (_isDisposing || !mounted) return;

  // // 1. Clear previous state immediately
  // setState(() {
  //   _isVideoInitialized = false;
  //   _loadingVisible = true;
  // });

  // // 2. Cleanup old controller synchronously if possible
  // final oldController = _controller;
  // _controller = null; 
  // await oldController?.dispose();

  // // 3. Setup new instance
  // try {
  //   // setState(() {
  //   //   _loadingVisible = true;
  //   // });

  //   _currentModifiedUrl = baseUrl;
  //   final String fullVlcUrl = _buildVlcUrl(baseUrl);
  //   // final String fullVlcUrl = baseUrl;
  //   print('fullVlcUrl: $fullVlcUrl');
  //   _lastPlayingTime = DateTime.now();
  //   _lastPositionCheck = Duration.zero;
  //   _stallCounter = 0;
  //   _hasStartedPlaying = false;

  //   print("Inicializando con URL: $fullVlcUrl");

  //   _controller = VlcPlayerController.network(
  //     fullVlcUrl,
  //     hwAcc: HwAcc.auto,
  //     options: VlcPlayerOptions(
  //       video: VlcVideoOptions([
  //         VlcVideoOptions.dropLateFrames(true),
  //         VlcVideoOptions.skipFrames(true),
  //       ]),
  //     ),
  //   );

  //   await _retryPlayback(fullVlcUrl, 4);
  //   _controller!.addListener(_vlcListener);

  //   setState(() {
  //     _isVideoInitialized = true;
  //   });
  //   } catch (e) {
  //    // Handle failure
  // }
  // }

  // Future<void> _retryPlayback(String url, int retries) async {
  //   for (int i = 0; i < retries; i++) {
  //     if (!mounted || _controller == null) return;
  //     try {
  //       print("Intento ${i + 1}/$retries: Deteniendo player...");
  //       await _controller!.stop();
  //       print("Asignando media: $url");
  //       await _controller!.setMediaFromNetwork(url);
  //       await _controller!.play();
  //       print("Comando Play enviado.");
  //       return;
  //     } catch (e) {
  //       print("Reintento ${i + 1} fallido: $e");
  //       if (i < retries - 1) {
  //         await Future.delayed(Duration(seconds: 1));
  //       }
  //     }
  //   }
  //   print("Todos los reintentos fallaron para: $url");
  // }

  // Future<void> _onItemTap(int index) async {
  //   setState(() {
  //     _loadingVisible = true;
  //     _focusedIndex = index;
  //   });

  //   var selectedChannel = widget.channelList[index];

  //   String secureUrl = await SecureUrlService.getSecureUrl(
  //       selectedChannel.url.toString(),
  //       expirySeconds: 10);

  //   _currentModifiedUrl = secureUrl;
  //   final String fullVlcUrl = _buildVlcUrl(secureUrl);
  //   print("secure+cached URL: $fullVlcUrl");

  //   _lastPlayingTime = DateTime.now();
  //   _lastPositionCheck = Duration.zero;
  //   _stallCounter = 0;
  //   _hasStartedPlaying = false;

  //   try {
  //     if (_controller != null && _controller!.value.isInitialized) {
  //       await _retryPlayback(fullVlcUrl, 3);
  //       _controller!.addListener(_vlcListener);
  //     } else {
  //       throw Exception("VLC Controller no inicializado");
  //     }
  //     _scrollToFocusedItem();
  //     _resetHideControlsTimer();
  //   } catch (e) {
  //     print("Error cambiando de canal: $e");
  //   }
  // }

  // void _togglePlayPause() {
  //   if (_controller != null && _controller!.value.isInitialized) {
  //     _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
  //     _lastPlayingTime = DateTime.now();
  //     _stallCounter = 0;
  //   }
  //   FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
  //   _resetHideControlsTimer();
  // }


  void _togglePlayPause() {
  if (_controller != null && _controller!.value.isInitialized) {
    if (_controller!.value.isPlaying) {
      _controller!.pause();
      setState(() {
         _isUserPaused = true; // User specifically asked to pause
      });
    } else {
      _controller!.play();
      setState(() {
         _isUserPaused = false; // User wants to play
      });
      _lastPlayingTime = DateTime.now();
      _stallCounter = 0;
    }
  }
  FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
  _resetHideControlsTimer();
}

  void _resetHideControlsTimer() {
    _hideControlsTimer.cancel();
    if (!_controlsVisible) {
      setState(() {
        _controlsVisible = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
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

  void _startHideControlsTimer() {
    _hideControlsTimer = Timer(Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  int _accumulatedSeekForward = 0;
  int _accumulatedSeekBackward = 0;
  Timer? _seekTimer;
  Duration _previewPosition = Duration.zero;
  final int _seekDuration = 5;
  final int _seekDelay = 800;

  void _seekForward() {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _controller!.value.duration <= Duration.zero) return;

    _accumulatedSeekForward += _seekDuration;
    final newPosition = _controller!.value.position +
        Duration(seconds: _accumulatedSeekForward);

    setState(() {
      _previewPosition = newPosition > _controller!.value.duration
          ? _controller!.value.duration
          : newPosition;
    });

    _seekTimer?.cancel();
    _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
      _seekToPosition(_previewPosition).then((_) {
        setState(() {
          _accumulatedSeekForward = 0;
        });
      });
    });
  }

  void _seekBackward() {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _controller!.value.duration <= Duration.zero) return;

    _accumulatedSeekBackward += _seekDuration;
    final newPosition = _controller!.value.position -
        Duration(seconds: _accumulatedSeekBackward);

    setState(() {
      _previewPosition =
          newPosition > Duration.zero ? newPosition : Duration.zero;
    });

    _seekTimer?.cancel();
    _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
      _seekToPosition(_previewPosition).then((_) {
        setState(() {
          _accumulatedSeekBackward = 0;
        });
      });
    });
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      duration = Duration.zero;
    }
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _onScrubStart(DragStartDetails details, BoxConstraints constraints) {
    if (_controller == null || _controller!.value.duration <= Duration.zero)
      return;

    _resetHideControlsTimer();
    setState(() {
      _isScrubbing = true;
      _accumulatedSeekForward = 1;
      final double progress =
          (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
      _previewPosition = _controller!.value.duration * progress;
    });
  }

  void _onScrubUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (!_isScrubbing ||
        _controller == null ||
        _controller!.value.duration <= Duration.zero) return;

    _resetHideControlsTimer();
    final double progress =
        (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
    final newPosition = _controller!.value.duration * progress;
    setState(() {
      _previewPosition = newPosition;
    });
  }

  void _onScrubEnd(DragEndDetails details) {
    if (!_isScrubbing) return;

    _seekToPosition(_previewPosition).then((_) {
      setState(() {
        _accumulatedSeekForward = 0;
      });
    });
    _resetHideControlsTimer();
    setState(() {
      _isScrubbing = false;
    });
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized || _controller == null) {
      return Center(child: CircularProgressIndicator());
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final videoWidth = _controller!.value.size.width ?? screenWidth;
        final videoHeight = _controller!.value.size.height ?? screenHeight;
        final videoRatio = videoWidth / videoHeight;
        final screenRatio = screenWidth / screenHeight;

        double scaleX = 1.0;
        double scaleY = 1.0;

        if (videoRatio < screenRatio) {
          scaleX = screenRatio / videoRatio;
        } else {
          scaleY = videoRatio / screenRatio;
        }

        return Container(
          width: screenWidth,
          height: screenHeight,
          color: Colors.black,
          child: Center(
            child: Transform.scale(
              scaleX: scaleX,
              scaleY: scaleY,
              child: VlcPlayer(
                key: ValueKey(_currentModifiedUrl ?? widget.videoUrl),
                controller: _controller!,
                placeholder: Center(child: CircularProgressIndicator()),
                aspectRatio: 16 / 9,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // 🆕 Improved back button handler
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox(
          width: screenwdt,
          height: screenhgt,
          child: Focus(
            autofocus: true,
            onKey: (node, event) {
              if (event is RawKeyDownEvent) {
                _handleKeyEvent(event);
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: GestureDetector(
              onTap: _resetHideControlsTimer,
              child: Stack(
                children: [
                  if (_isVideoInitialized && _controller != null)
                    _buildVideoPlayer(),
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
                          backgroundColor:
                              _loadingVisible || !_isVideoInitialized
                                  ? Colors.black
                                  : Colors.transparent,
                        ),
                      ),
                    ),
                  if (_controlsVisible && widget.channelList.isNotEmpty)
                    _buildChannelList(),
                  _buildControls(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChannelList() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.02,
      bottom: MediaQuery.of(context).size.height * 0.1,
      left: 0,
      right: MediaQuery.of(context).size.width * 0.78,
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
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Focus(
              focusNode: focusNodes[index],
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  print("✅ FOCO GANADO: Canal en índice $index");
                  _scrollToFocusedItem();
                }
              },
              child: GestureDetector(
                onTap: () {
                  _onItemTap(index);
                  _resetHideControlsTimer();
                },
                child: Container(
                  width: screenwdt * 0.3,
                  height: screenhgt * 0.18,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isFocused && !playPauseButtonFocusNode.hasFocus
                          ? const Color.fromARGB(211, 155, 40, 248)
                          : Colors.transparent,
                      width: 5.0,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: isFocused ? Colors.black26 : Colors.transparent,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.6,
                            child: isBase64
                                ? Image.memory(
                                    _bannerCache[channelId] ??
                                        _getCachedImage(
                                            channel.banner ?? localImage),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, e, s) =>
                                        Image.asset('assets/placeholder.png'),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: channel.banner ?? localImage,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        Image.asset('assets/placeholder.png'),
                                  ),
                          ),
                        ),
                        if (isFocused)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.9),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (isFocused)
                          Positioned(
                            left: 8,
                            bottom: 8,
                            child: Text(
                              channel.name ?? '',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildControls() {
    final Duration currentPosition = _accumulatedSeekForward > 0 ||
            _accumulatedSeekBackward > 0 ||
            _isScrubbing
        ? _previewPosition
        : _controller?.value.position ?? Duration.zero;
    final Duration totalDuration = _controller?.value.duration ?? Duration.zero;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: _controlsVisible ? 1 : 0.0,
        child: IgnorePointer(
          ignoring: !_controlsVisible,
          child: Container(
            color: Colors.black54,
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: screenwdt * 0.03),
                Container(
                  color: playPauseButtonFocusNode.hasFocus
                      ? const Color.fromARGB(200, 16, 62, 99)
                      : Colors.transparent,
                  child: Focus(
                    focusNode: playPauseButtonFocusNode,
                    onFocusChange: (hasFocus) {
                      if (hasFocus) print("✅ FOCO GANADO: Botón Play/Pause");
                      setState(() {});
                    },
                    child: IconButton(
                      icon: Image.asset(
                        (_controller?.value.isPlaying ?? false)
                            ? 'assets/pause.png'
                            : 'assets/play.png',
                        width: 35,
                        height: 35,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                  ),
                ),
                if (widget.liveStatus == false)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      _formatDuration(currentPosition),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Expanded(
                  flex: 10,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onHorizontalDragStart: (widget.liveStatus == false)
                            ? (details) => _onScrubStart(details, constraints)
                            : null,
                        onHorizontalDragUpdate: (widget.liveStatus == false)
                            ? (details) => _onScrubUpdate(details, constraints)
                            : null,
                        onHorizontalDragEnd: (widget.liveStatus == false)
                            ? (details) => _onScrubEnd(details)
                            : null,
                        child: Container(
                          color: Colors.transparent,
                          child: _buildBeautifulProgressBar(
                              currentPosition, totalDuration),
                        ),
                      );
                    },
                  ),
                ),
                if (widget.liveStatus == false)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      _formatDuration(totalDuration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (widget.liveStatus == true)
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.circle, color: Colors.red, size: 15),
                        SizedBox(width: 5),
                        Text(
                          'Live',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(width: screenwdt * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBeautifulProgressBar(
      Duration displayPosition, Duration totalDuration) {
    final totalDurationMs = totalDuration.inMilliseconds.toDouble();

    if (totalDurationMs <= 0 || widget.liveStatus == true) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
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
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(0, 2),
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
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF9B28F8),
                        Color(0xFFE62B1E),
                        Color(0xFFFF6B35),
                      ],
                      stops: [0.0, 0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF9B28F8).withOpacity(0.6),
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
}



