






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
//   final int _seekDuration = 10;
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
//   // 🟢 NEW CODE: Error tracking variables
//   int _errorRetryCount = 0;
//   bool _hasPlaybackError = false;

//   // 🟢 NEW CODE: Anti-crash cooldown and setState throttle trackers
//   DateTime _lastRecoveryAttempt =
//       DateTime.now().subtract(const Duration(seconds: 15));
//   DateTime _lastSetStateTime = DateTime.now();

//   Map<String, Uint8List> _bannerCache = {};
//   bool _isDisposing = false;
//   final String localImage = "";
//   bool _isAppInBackground = false;

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
//         if (_bannerCache.length >= 15) {
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

//   // @override
//   // void didChangeAppLifecycleState(AppLifecycleState state) {
//   //   if (state == AppLifecycleState.inactive ||
//   //       state == AppLifecycleState.paused) {
//   //     if (activePlayer == 'VLC') vlcController?.pause();
//   //     if (activePlayer == 'WEB')
//   //       webViewController?.evaluateJavascript(
//   //           source: "document.getElementById('video').pause();");
//   //   } else if (state == AppLifecycleState.resumed) {
//   //     if (!_isUserPaused) {
//   //       if (activePlayer == 'VLC') vlcController?.play();
//   //       if (activePlayer == 'WEB')
//   //         webViewController?.evaluateJavascript(
//   //             source: "document.getElementById('video').play();");
//   //     }
//   //   }
//   // }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.inactive ||
//         state == AppLifecycleState.paused ||
//         state == AppLifecycleState.detached) {
//       _isAppInBackground = true; // 🟢 Stop watchdogs from running
//       if (activePlayer == 'VLC') vlcController?.pause();
//       if (activePlayer == 'WEB') {
//         webViewController?.evaluateJavascript(
//             source: "document.getElementById('video').pause();");
//       }
//     } else if (state == AppLifecycleState.resumed) {
//       _isAppInBackground = false; // 🟢 Allow watchdogs to run again
//       if (!_isUserPaused) {
//         if (activePlayer == 'VLC') vlcController?.play();
//         if (activePlayer == 'WEB') {
//           webViewController?.evaluateJavascript(
//               source: "document.getElementById('video').play();");
//         }
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
//     // 🟢 FIX: Added `_isAppInBackground` check
//     if (_currentModifiedUrl == null || _isDisposing || _isAppInBackground)
//       return;
//     // if (_currentModifiedUrl == null || _isDisposing) return;
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

//     // 🟢 UPDATED CODE: Prevent aggressive looping to stop freezes
//     if (DateTime.now().difference(_lastRecoveryAttempt).inSeconds < 10) {
//       print("Recovery is on cooldown to prevent app crash. Skipping...");
//       return;
//     }
//     _lastRecoveryAttempt = DateTime.now();

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

//   // void _startPositionUpdater() {
//   //   Timer.periodic(const Duration(seconds: 2), (_) {
//   //     if (!mounted || _isScrubbing || _isAttemptingResume || _isDisposing)
//   //       return;

//   //     if (widget.liveStatus == true && _hasStartedPlaying && !_isUserPaused) {
//   //       if (_lastPositionCheck != Duration.zero &&
//   //           _currentPosition.value == _lastPositionCheck) {
//   //         _stallCounter++;
//   //       } else {
//   //         _stallCounter = 0;
//   //       }

//   //       if (_stallCounter >= 3) {
//   //         _attemptResumeLiveStream();
//   //         _stallCounter = 0;
//   //       }
//   //       _lastPositionCheck = _currentPosition.value;
//   //     }
//   //   });
//   // }

//   // void _startPositionUpdater() {
//   //   Timer.periodic(const Duration(seconds: 2), (_) {
//   //     if (!mounted || _isScrubbing || _isAttemptingResume || _isDisposing)
//   //       return;

//   //     if (widget.liveStatus == true && _hasStartedPlaying && !_isUserPaused) {
//   //       if (_lastPositionCheck != Duration.zero &&
//   //           _currentPosition.value == _lastPositionCheck) {
//   //         _stallCounter++;
//   //       } else {
//   //         _stallCounter = 0;
//   //       }

//   //       // 🟢 UPDATED CODE: Removed contradictory native pause/play queue to stop crash
//   //       // if (_stallCounter == 2 && activePlayer == 'VLC' && vlcController != null) {
//   //       //   vlcController!.pause().then((_) => vlcController!.play());
//   //       // }

//   //       if (_stallCounter >= 4) { // Increased to 4 to give the larger buffer time to work
//   //         _attemptResumeLiveStream();
//   //         _stallCounter = 0;
//   //       }
//   //       _lastPositionCheck = _currentPosition.value;
//   //     }
//   //   });
//   // }

//   void _startPositionUpdater() {
//     Timer.periodic(const Duration(seconds: 2), (_) {
//       // 🟢 FIX: Added `_isAppInBackground` so the watchdog sleeps in the background
//       if (!mounted ||
//           _isScrubbing ||
//           _isAttemptingResume ||
//           _isDisposing ||
//           _isAppInBackground) {
//         return;
//       }
//       // if (!mounted || _isScrubbing || _isAttemptingResume || _isDisposing)
//       //   return;

//       // 🟢 FAST WATCHDOG: Dynamic timeout based on content type
//       if (_loadingVisible && !_isUserPaused) {
//         // 7 seconds for Live TV, 12 seconds for VOD
//         int timeoutSeconds = widget.liveStatus == true ? 7 : 12;

//         if (DateTime.now().difference(_lastPlayingTime) >
//             Duration(seconds: timeoutSeconds)) {
//           print(
//               "Watchdog triggered: Stuck in loading for ${timeoutSeconds}s. Forcing recovery...");
//           if (_errorRetryCount < 3) {
//             _errorRetryCount++;
//             _attemptResumeLiveStream();
//           } else {
//             // Stop infinite loading and show the Error/Retry UI after 3 failed attempts
//             setState(() {
//               _loadingVisible = false;
//               _hasPlaybackError = true;
//             });
//           }
//           // Reset the timer to prevent spamming retries
//           _lastPlayingTime = DateTime.now();
//           return;
//         }
//       }

//       if (widget.liveStatus == true && _hasStartedPlaying && !_isUserPaused) {
//         if (_lastPositionCheck != Duration.zero &&
//             _currentPosition.value == _lastPositionCheck) {
//           _stallCounter++;
//         } else {
//           _stallCounter = 0;

//           // 🟢 If the video is actively moving forward, force hide the loader
//           if (_loadingVisible && _hasStartedPlaying) {
//             setState(() {
//               _loadingVisible = false;
//             });
//           }
//         }

//         // Wait for ~8 seconds of continuous stalling before a native restart
//         if (_stallCounter >= 4) {
//           _attemptResumeLiveStream();
//           _stallCounter = 0;
//         }
//         _lastPositionCheck = _currentPosition.value;
//       }
//     });
//   }

//   // String _buildVlcUrl(String baseUrl) {
//   //   final String networkCaching = "network-caching=3000";
//   //   final String liveCaching = "live-caching=1000";
//   //   final String fileCaching = "file-caching=500";
//   //   final String rtspTcp = "rtsp-tcp";
//   //   return widget.liveStatus == true
//   //       ? '$baseUrl?$networkCaching&$liveCaching&$fileCaching&$rtspTcp'
//   //       : '$baseUrl?$networkCaching&$fileCaching&$rtspTcp';
//   // }

//   String _buildVlcUrl(String baseUrl) {
//     // 🟢 FIX: Increased buffer for TV and fixed URL parameter corruption
//     final String networkCaching = "network-caching=6000";
//     final String liveCaching = "live-caching=6000";
//     final String fileCaching = "file-caching=1500";
//     final String rtspTcp = "rtsp-tcp";

//     final String params = widget.liveStatus == true
//         ? '$networkCaching&$liveCaching&$fileCaching&$rtspTcp'
//         : '$networkCaching&$fileCaching&$rtspTcp';

//     // If URL already has a '?', append with '&'. Otherwise, use '?'
//     return baseUrl.contains('?') ? '$baseUrl&$params' : '$baseUrl?$params';
//   }

//   // Future<void> _initVlcPlayer(String baseUrl) async {
//   //   if (_isDisposing) return;

//   //   if (vlcController != null) {
//   //     vlcController!.removeListener(_vlcListener);
//   //     await vlcController!.stop();
//   //     await vlcController!.dispose();
//   //     vlcController = null;
//   //   }

//   //   _lastPlayingTime = DateTime.now();
//   //   _stallCounter = 0;
//   //   _hasStartedPlaying = false;
//   //   _hasFetchedSubtitles = false;

//   //   vlcController = VlcPlayerController.network(
//   //     _buildVlcUrl(baseUrl),
//   //     hwAcc: HwAcc.auto,
//   //     autoPlay: true,
//   //     options: VlcPlayerOptions(
//   //       http: VlcHttpOptions([
//   //         ':http-user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
//   //       ]),
//   //       video: VlcVideoOptions([
//   //         VlcVideoOptions.dropLateFrames(true),
//   //         VlcVideoOptions.skipFrames(true),
//   //       ]),
//   //     ),
//   //   );
//   //   vlcController!.addListener(_vlcListener);
//   //   if (mounted) setState(() {});
//   // }

// //   Future<void> _initVlcPlayer(String baseUrl) async {
// //     if (_isDisposing) return;

// //     if (vlcController != null) {
// //       vlcController!.removeListener(_vlcListener);
// //       await vlcController!.stop();
// //       await vlcController!.dispose();
// //       vlcController = null;
// //     }

// //     _lastPlayingTime = DateTime.now();
// //     _stallCounter = 0;
// //     _hasStartedPlaying = false;
// //     _hasFetchedSubtitles = false;

// //     vlcController = VlcPlayerController.network(
// //       _buildVlcUrl(baseUrl),
// //       hwAcc: HwAcc.auto ,
// //       autoPlay: true,
// //       options: VlcPlayerOptions(
// //         http: VlcHttpOptions([
// //           ':http-user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
// //         ]),
// //         video: VlcVideoOptions([
// //           VlcVideoOptions.dropLateFrames(true),
// //           VlcVideoOptions.skipFrames(true),
// //         ]),
// //         audio: VlcAudioOptions([
// //           // Corrected method name
// //           VlcAudioOptions.audioTimeStretch(true),
// //         ]),
// //         advanced: VlcAdvancedOptions([
// //           // Disabling input clock sync (0) helps prevent jerky playback on live network streams
// //           VlcAdvancedOptions.clockJitter(0),
// //           VlcAdvancedOptions.clockSynchronization(0),
// //         ]),
// //       ),
// //     );

// //     vlcController!.addListener(_vlcListener);
// //     if (mounted) setState(() {});
// //   }

// // Future<void> _initVlcPlayer(String baseUrl) async {
// //     if (_isDisposing) return;

// //     if (vlcController != null) {
// //       vlcController!.removeListener(_vlcListener);
// //       await vlcController!.stop();
// //       await vlcController!.dispose();
// //       vlcController = null;
// //     }

// //     _lastPlayingTime = DateTime.now();
// //     _stallCounter = 0;
// //     _hasStartedPlaying = false;
// //     _hasFetchedSubtitles = false;

// //     // 🟢 NEW CODE: Reset error state before initializing
// //     if (mounted) {
// //       setState(() {
// //         _hasPlaybackError = false;
// //       });
// //     }

// //     // 🟢 NEW CODE: Wrapped in try-catch to prevent initialization crashes
// //     try {
// //       vlcController = VlcPlayerController.network(
// //         _buildVlcUrl(baseUrl),
// //         hwAcc: HwAcc.auto ,
// //         autoPlay: true,
// //         options: VlcPlayerOptions(
// //           http: VlcHttpOptions([
// //             ':http-user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
// //           ]),
// //           video: VlcVideoOptions([
// //             VlcVideoOptions.dropLateFrames(true),
// //             VlcVideoOptions.skipFrames(true),
// //           ]),
// //           audio: VlcAudioOptions([
// //             VlcAudioOptions.audioTimeStretch(true),
// //           ]),
// //           advanced: VlcAdvancedOptions([
// //             VlcAdvancedOptions.clockJitter(0),
// //             VlcAdvancedOptions.clockSynchronization(0),
// //           ]),
// //         ),
// //       );

// //       vlcController!.addListener(_vlcListener);
// //       if (mounted) setState(() {});
// //     } catch (e) {
// //       print("Failed to initialize VLC Player: $e");
// //       if (mounted) {
// //          setState(() {
// //            _hasPlaybackError = true;
// //            _loadingVisible = false;
// //          });
// //       }
// //     }
// //   }

// // Future<void> _initVlcPlayer(String baseUrl) async {
// //     if (_isDisposing) return;

// //     // 🟢 FIX: Safe teardown of the old player before creating a new one
// //     if (vlcController != null) {
// //       final oldController = vlcController;
// //       vlcController = null;
// //       oldController!.removeListener(_vlcListener);
// //       Future.microtask(() async {
// //         try {
// //           await oldController.stop();
// //           await oldController.dispose();
// //         } catch (_) {}
// //       });
// //     }

// //     _lastPlayingTime = DateTime.now();
// //     _stallCounter = 0;
// //     _hasStartedPlaying = false;
// //     _hasFetchedSubtitles = false;

// //     if (mounted) {
// //       setState(() {
// //         _hasPlaybackError = false;
// //       });
// //     }

// //     try {
// //       vlcController = VlcPlayerController.network(
// //         _buildVlcUrl(baseUrl),
// //         hwAcc: HwAcc.full, // 🟢 FIX: Force Full Hardware Decoding for TVs
// //         autoPlay: true,
// //         options: VlcPlayerOptions(
// //           http: VlcHttpOptions([
// //             ':http-user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
// //             ':http-reconnect=true', // 🟢 FIX: Tell VLC to auto-reconnect broken pipes
// //           ]),
// //           video: VlcVideoOptions([
// //             VlcVideoOptions.dropLateFrames(true),
// //             VlcVideoOptions.skipFrames(true),
// //           ]),
// //           audio: VlcAudioOptions([
// //             VlcAudioOptions.audioTimeStretch(true),
// //           ]),
// //           advanced: VlcAdvancedOptions([
// //             VlcAdvancedOptions.networkCaching(2000), // Enforce caching at the engine level
// //             VlcAdvancedOptions.liveCaching(2000),
// //             VlcAdvancedOptions.clockJitter(0),
// //             VlcAdvancedOptions.clockSynchronization(0),
// //           ]),
// //         ),
// //       );

// //       vlcController!.addListener(_vlcListener);
// //       if (mounted) setState(() {});
// //     } catch (e) {
// //       print("Failed to initialize VLC Player: $e");
// //       if (mounted) {
// //          setState(() {
// //            _hasPlaybackError = true;
// //            _loadingVisible = false;
// //          });
// //       }
// //     }
// //   }

//   Future<void> _initVlcPlayer(String baseUrl) async {
//     if (_isDisposing) return;

//     // 🟢 FIX 4: Safe teardown of the old player before creating a new one
//     if (vlcController != null) {
//       final oldController = vlcController;
//       vlcController = null;

//       try {
//         oldController!.removeListener(_vlcListener);
//       } catch (_) {}

//       Future.delayed(const Duration(milliseconds: 100), () async {
//         try {
//           await oldController?.stop().timeout(const Duration(seconds: 2));
//         } catch (_) {}
//         try {
//           await oldController?.dispose().timeout(const Duration(seconds: 2));
//         } catch (_) {}
//       });
//     }

//     _lastPlayingTime = DateTime.now();
//     _stallCounter = 0;
//     _hasStartedPlaying = false;
//     _hasFetchedSubtitles = false;

//     if (mounted) {
//       setState(() {
//         _hasPlaybackError = false;
//       });
//     }

//     try {
//       vlcController = VlcPlayerController.network(
//         _buildVlcUrl(baseUrl),
//         hwAcc: HwAcc.auto, // 🟢 Force Full Hardware Decoding for TVs
//         autoPlay: true,
//         options: VlcPlayerOptions(
//           http: VlcHttpOptions([
//             ':http-user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
//             ':http-reconnect=true', // 🟢 Tell VLC to auto-reconnect broken pipes
//           ]),
//           video: VlcVideoOptions([
//             VlcVideoOptions.dropLateFrames(true),
//             VlcVideoOptions.skipFrames(true),
//           ]),
//           audio: VlcAudioOptions([
//             VlcAudioOptions.audioTimeStretch(true),
//           ]),
//           advanced: VlcAdvancedOptions([
//             VlcAdvancedOptions.networkCaching(
//                 6000), // Enforce caching at the engine level
//             VlcAdvancedOptions.liveCaching(2000),
//             VlcAdvancedOptions.clockJitter(0),
//             VlcAdvancedOptions.clockSynchronization(0),
//           ]),
//         ),
//       );

//       vlcController!.addListener(_vlcListener);
//       if (mounted) setState(() {});
//     } catch (e) {
//       print("Failed to initialize VLC Player: $e");
//       if (mounted) {
//         setState(() {
//           _hasPlaybackError = true;
//           _loadingVisible = false;
//         });
//       }
//     }
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

// //   void _vlcListener() {
// //     if (!mounted || vlcController == null || _isDisposing) return;
// //     final value = vlcController!.value;
// //     final PlayingState playingState = value.playingState;

// //     if (widget.liveStatus == true && !_isAttemptingResume) {
// //       if (playingState == PlayingState.playing) {
// //         _lastPlayingTime = DateTime.now();
// //         if (!_hasStartedPlaying) _hasStartedPlaying = true;
// //         if (!_hasFetchedSubtitles) _fetchSubtitles();
// //       } else if (playingState == PlayingState.buffering && _hasStartedPlaying) {
// //         if (DateTime.now().difference(_lastPlayingTime) >
// //             const Duration(seconds: 8)) _attemptResumeLiveStream();
// //       }
// //       else if (playingState == PlayingState.error) {
// //         _attemptResumeLiveStream();
// //       }
// //       else if ((playingState == PlayingState.stopped ||
// //               playingState == PlayingState.ended) &&
// //           _hasStartedPlaying) {
// //         if (DateTime.now().difference(_lastPlayingTime) >
// //             const Duration(seconds: 5)) _attemptResumeLiveStream();
// //       }
// //     } else if (playingState == PlayingState.paused) {
// //       if (_isUserPaused) {
// //         _lastPlayingTime = DateTime.now();
// //       } else {
// //         if (DateTime.now().difference(_lastPlayingTime) >
// //             const Duration(seconds: 5)) {
// //           if (widget.liveStatus == true) {
// //             _attemptResumeLiveStream();
// //           } else {
// //             _onNetworkReconnected();
// //           }
// //           _lastPlayingTime = DateTime.now();
// //         }
// //       }
// //     } else if (playingState == PlayingState.playing &&
// //         widget.liveStatus == false) {
// //       if (!_hasFetchedSubtitles) _fetchSubtitles();
// //     }

// //     _currentPosition.value = value.position;
// //     _totalDuration.value = value.duration;

// //     bool needsRebuild = false;
// //     if (_isPlaying != value.isPlaying) {
// //       _isPlaying = value.isPlaying;
// //       needsRebuild = true;
// //     }
// //     if (_isBuffering != value.isBuffering) {
// //       _isBuffering = value.isBuffering;
// //       needsRebuild = true;
// //     }
// //     if (!_isVideoInitialized && value.isInitialized) {
// //       _isVideoInitialized = true;
// //       needsRebuild = true;
// //     }

// //     bool newLoadingVisible = _isBuffering ||
// //         playingState == PlayingState.initializing ||
// //         _isAttemptingResume;
// //     if (_isPlaying && !_isBuffering) newLoadingVisible = false;

// //     if (_loadingVisible != newLoadingVisible) {
// //       _loadingVisible = newLoadingVisible;
// //       needsRebuild = true;
// //     }

// //     if (needsRebuild && mounted) setState(() {});
// //   }

// // void _vlcListener() {
// //     if (!mounted || vlcController == null || _isDisposing) return;
// //     final value = vlcController!.value;
// //     final PlayingState playingState = value.playingState;

// //     if (widget.liveStatus == true && !_isAttemptingResume) {
// //       if (playingState == PlayingState.playing) {
// //         _lastPlayingTime = DateTime.now();
// //         if (!_hasStartedPlaying) _hasStartedPlaying = true;
// //         if (!_hasFetchedSubtitles) _fetchSubtitles();
// //         // 🟢 FIX: Video successfully chal gaya, to error counter reset kar do
// //         if (_errorRetryCount > 0 || _hasPlaybackError) {
// //           setState(() {
// //             _errorRetryCount = 0;
// //             _hasPlaybackError = false;
// //           });
// //         }
// //       } else if (playingState == PlayingState.buffering && _hasStartedPlaying) {
// //         if (DateTime.now().difference(_lastPlayingTime) >
// //             const Duration(seconds: 8)) _attemptResumeLiveStream();
// //       } else if (playingState == PlayingState.error) {
// //         // 🟢 NEW CODE: Retry limit and memory delay to stop the crash loop
// //         if (_errorRetryCount < 3) {
// //           _errorRetryCount++;
// //           print("VLC Playback Error. Retrying $_errorRetryCount/3 in 3 seconds...");

// //           Future.delayed(const Duration(seconds: 3), () {
// //             if (mounted && !_isDisposing) _attemptResumeLiveStream();
// //           });
// //         } else {
// //           if (mounted) {
// //             setState(() {
// //               _isAttemptingResume = false;
// //               _loadingVisible = false;
// //               _hasPlaybackError = true;
// //             });
// //           }
// //         }
// //       } else if ((playingState == PlayingState.stopped ||
// //               playingState == PlayingState.ended) &&
// //           _hasStartedPlaying) {
// //         if (DateTime.now().difference(_lastPlayingTime) >
// //             const Duration(seconds: 5)) _attemptResumeLiveStream();
// //       }
// //     } else if (playingState == PlayingState.paused) {
// //       if (_isUserPaused) {
// //         _lastPlayingTime = DateTime.now();
// //       } else {
// //         if (DateTime.now().difference(_lastPlayingTime) >
// //             const Duration(seconds: 5)) {
// //           if (widget.liveStatus == true) {
// //             _attemptResumeLiveStream();
// //           } else {
// //             _onNetworkReconnected();
// //           }
// //           _lastPlayingTime = DateTime.now();
// //         }
// //       }
// //     } else if (playingState == PlayingState.playing &&
// //         widget.liveStatus == false) {
// //       if (!_hasFetchedSubtitles) _fetchSubtitles();
// //     }

// //     _currentPosition.value = value.position;
// //     _totalDuration.value = value.duration;

// //     bool needsRebuild = false;
// //     if (_isPlaying != value.isPlaying) {
// //       _isPlaying = value.isPlaying;
// //       needsRebuild = true;
// //     }
// //     if (_isBuffering != value.isBuffering) {
// //       _isBuffering = value.isBuffering;
// //       needsRebuild = true;
// //     }
// //     if (!_isVideoInitialized && value.isInitialized) {
// //       _isVideoInitialized = true;
// //       needsRebuild = true;
// //     }

// //     bool newLoadingVisible = _isBuffering ||
// //         playingState == PlayingState.initializing ||
// //         _isAttemptingResume;
// //     if (_isPlaying && !_isBuffering) newLoadingVisible = false;

// //     if (_loadingVisible != newLoadingVisible) {
// //       _loadingVisible = newLoadingVisible;
// //       needsRebuild = true;
// //     }

// //     // 🟢 UPDATED CODE: Throttle setState to prevent UI freeze from micro-stutters
// //     if (needsRebuild && mounted) {
// //       final now = DateTime.now();
// //       if (now.difference(_lastSetStateTime).inMilliseconds > 200) {
// //         setState(() {});
// //         _lastSetStateTime = now;
// //       }
// //     }
// //   }
// void _vlcListener() {
//     if (!mounted || vlcController == null || _isDisposing) return;
    
//     final value = vlcController!.value;
//     final PlayingState playingState = value.playingState;

//     // Update position values without triggering a UI rebuild
//     _currentPosition.value = value.position;
//     _totalDuration.value = value.duration;

//     if (widget.liveStatus == true && !_isAttemptingResume) {
//       if (playingState == PlayingState.playing) {
//         _lastPlayingTime = DateTime.now();
//         if (!_hasStartedPlaying) _hasStartedPlaying = true;
        
//         if (_errorRetryCount > 0 || _hasPlaybackError) {
//           setState(() {
//             _errorRetryCount = 0;
//             _hasPlaybackError = false;
//           });
//         }
//       } else if (playingState == PlayingState.buffering && _hasStartedPlaying) {
//         if (DateTime.now().difference(_lastPlayingTime) > const Duration(seconds: 8)) {
//           _attemptResumeLiveStream();
//         }
//       } else if (playingState == PlayingState.error) {
//         if (_errorRetryCount < 3) {
//           _errorRetryCount++;
//           Future.delayed(const Duration(seconds: 3), () {
//             if (mounted && !_isDisposing) _attemptResumeLiveStream();
//           });
//         } else {
//           if (mounted && !_hasPlaybackError) { // Only rebuild if state actually changes
//             setState(() {
//               _isAttemptingResume = false;
//               _loadingVisible = false;
//               _hasPlaybackError = true;
//             });
//           }
//         }
//       } else if ((playingState == PlayingState.stopped || playingState == PlayingState.ended) && _hasStartedPlaying) {
//         if (DateTime.now().difference(_lastPlayingTime) > const Duration(seconds: 5)) {
//           _attemptResumeLiveStream();
//         }
//       }
//     } else if (playingState == PlayingState.paused) {
//        if (_isUserPaused) {
//          _lastPlayingTime = DateTime.now();
//        }
//     } else if (playingState == PlayingState.playing && widget.liveStatus == false) {
//       if (!_hasFetchedSubtitles) _fetchSubtitles();
//     }

//     // 🟢 FIX: Strict State Management to prevent Memory Fragmentation
//     bool newIsPlaying = value.isPlaying;
//     bool newIsBuffering = value.isBuffering;
//     bool newIsVideoInitialized = value.isInitialized;
    
//     bool newLoadingVisible = newIsBuffering || playingState == PlayingState.initializing || _isAttemptingResume;
//     if (playingState == PlayingState.playing) {
//       newLoadingVisible = false;
//     }

//     bool needsRebuild = false;

//     if (_isPlaying != newIsPlaying) {
//       _isPlaying = newIsPlaying;
//       needsRebuild = true;
//     }
//     if (_isBuffering != newIsBuffering) {
//       _isBuffering = newIsBuffering;
//       needsRebuild = true;
//     }
//     if (!_isVideoInitialized && newIsVideoInitialized) {
//       _isVideoInitialized = true;
//       needsRebuild = true;
//     }
//     if (_loadingVisible != newLoadingVisible) {
//       _loadingVisible = newLoadingVisible;
//       needsRebuild = true;
//     }

//     // Only rebuild if a major visual state changed, NOT on every frame tick
//     if (needsRebuild && mounted) {
//       final now = DateTime.now();
//       if (now.difference(_lastSetStateTime).inMilliseconds > 250) {
//         setState(() {});
//         _lastSetStateTime = now;
//       }
//     }
//   }

// //   Future<void> _switchPlayerSafely(
// //       String targetPlayerType, String secureUrl) async {
// //     if (_isDisposing) return;

// //     setState(() {
// //       _loadingVisible = true;
// //       _isVideoInitialized = false;
// //     });

// //     if (activePlayer == 'VLC' && vlcController != null) {
// //       vlcController!.removeListener(_vlcListener);
// //       await vlcController!.stop();
// //       await vlcController!.dispose();
// //       vlcController = null;
// //     }
// //     webViewController = null;

// //     setState(() {
// //       activePlayer = 'NONE';
// //     });
// //     await Future.delayed(const Duration(milliseconds: 600));
// //     if (_isDisposing) return;

// //     _currentModifiedUrl = secureUrl;
// //     setState(() {
// //       activePlayer = targetPlayerType;
// //     });

// //     if (targetPlayerType == 'WEB') {
// //       if (webViewController != null) {
// //         await webViewController!.evaluateJavascript(
// //             source: "loadNewVideo('$_currentModifiedUrl');");
// //       }
// //     } else if (targetPlayerType == 'VLC') {
// //       await _initVlcPlayer(_currentModifiedUrl!);
// //     }
// //   }

// // Future<void> _switchPlayerSafely(
// //       String targetPlayerType, String secureUrl) async {
// //     if (_isDisposing) return;

// //     setState(() {
// //       _loadingVisible = true;
// //       _isVideoInitialized = false;
// //       // 🟢 NEW CODE: Reset error trackers when channel changes
// //       // _errorRetryCount = 0;
// //       _hasPlaybackError = false;
// //     });

// //     // 🟢 UPDATED CODE: Detach controller immediately and handle native disposal safely in background
// //     if (activePlayer == 'VLC' && vlcController != null) {
// //       final oldController = vlcController;
// //       vlcController = null;

// //       oldController!.removeListener(_vlcListener);

// //       Future.microtask(() async {
// //         try {
// //           await oldController.stop();
// //           await oldController.dispose();
// //         } catch (e) {
// //           print("Handled VLC disposal error: $e");
// //         }
// //       });
// //     }
// //     webViewController = null;

// //     setState(() {
// //       activePlayer = 'NONE';
// //     });
// //     await Future.delayed(const Duration(milliseconds: 600));
// //     if (_isDisposing) return;

// //     _currentModifiedUrl = secureUrl;
// //     setState(() {
// //       activePlayer = targetPlayerType;
// //     });

// //     if (targetPlayerType == 'WEB') {
// //       if (webViewController != null) {
// //         await webViewController!.evaluateJavascript(
// //             source: "loadNewVideo('$_currentModifiedUrl');");
// //       }
// //     } else if (targetPlayerType == 'VLC') {
// //       await _initVlcPlayer(_currentModifiedUrl!);
// //     }
// //   }

//   Future<void> _switchPlayerSafely(
//       String targetPlayerType, String secureUrl) async {
//     if (_isDisposing) return;

//     setState(() {
//       _loadingVisible = true;
//       _isVideoInitialized = false;
//       _hasPlaybackError = false;
//     });

//     // 🟢 FIX 3: Safe channel switching with timeouts
//     if (activePlayer == 'VLC' && vlcController != null) {
//       final oldController = vlcController;
//       vlcController = null;

//       try {
//         oldController!.removeListener(_vlcListener);
//       } catch (_) {}

//       Future.delayed(const Duration(milliseconds: 100), () async {
//         try {
//           await oldController?.stop().timeout(const Duration(seconds: 2));
//         } catch (e) {
//           print("Handled VLC stop error during switch: $e");
//         }
//         try {
//           await oldController?.dispose().timeout(const Duration(seconds: 2));
//         } catch (e) {
//           print("Handled VLC dispose error during switch: $e");
//         }
//       });
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
//       _errorRetryCount = 0;
//       _hasPlaybackError = false;
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

//   @override
//   Widget build(BuildContext context) {
//     final double screenwdt = MediaQuery.of(context).size.width;
//     final double screenhgt = MediaQuery.of(context).size.height;
//     final double bottomBarHeight = screenhgt * 0.15;
//     final double topTitleHeight = screenhgt * 0.10;
//     final double leftPanelWidth = screenwdt * 0.13;

//     // Calculate dynamic smooth scale factor based on controls visibility
//     final double targetScale =
//         (_controlsVisible && widget.channelList.isNotEmpty) ? 0.8 : 1.0;

// //      // 1. Bounds Calculate karein (Yeh UI layout ke liye perfect jagah banayega)
// // final double offsetLeft = (_controlsVisible && widget.channelList.isNotEmpty) ? leftPanelWidth : 0.0;
// // final double offsetRight = _controlsVisible ? 16.0 : 0.0;
// // final double offsetTop = _controlsVisible ? topTitleHeight : 0.0;
// // final double offsetBottom = _controlsVisible ? bottomBarHeight : 0.0;

// // // Yeh calculate karega ki video left se kitna shift hoga
// // final double offsetLeft = (_controlsVisible && widget.channelList.isNotEmpty) ? leftPanelWidth : 0.0;

// // // Right ko hamesha fixed rakhein (0.0 ya small padding agar edge se satana hai)
// // const double fixedRight = 0.0;

// // // Top aur Bottom wahi rahenge jo aapne banaye hain
// // final double offsetTop = _controlsVisible ? topTitleHeight : 0.0;
// // final double offsetBottom = _controlsVisible ? bottomBarHeight : 0.0;

// // // Check if the current video is a Live stream or VOD
// // final bool isLive = widget.liveStatus == true;

// // // Apply offsets ONLY for Live TV. If it is VOD, offsets stay 0.0 (fullscreen).
// // final double offsetLeft = (isLive && _controlsVisible && widget.channelList.isNotEmpty) ? leftPanelWidth : 0.0;
// // const double fixedRight = 0.0;
// // final double offsetTop = (isLive && _controlsVisible) ? topTitleHeight : 0.0;
// // final double offsetBottom = (isLive && _controlsVisible) ? bottomBarHeight : 0.0;

// // Check if the current video is a Live stream or VOD
//     final bool isLive = widget.liveStatus == true;

// // Force all offsets to 0.0 so the video stays full screen and UI overlays on top
//     final double offsetLeft = 0.0;
//     const double fixedRight = 0.0;
//     final double offsetTop = 0.0;
//     final double offsetBottom = 0.0;

//     // return PopScope(
//     //   canPop: true,
//     //   onPopInvokedWithResult: (bool didPop, dynamic result) {
//     //     if (didPop) _safeDispose();
//     //   },
//     return PopScope(
//       canPop: false, // Prevent immediate pop to avoid native crashes
//       onPopInvokedWithResult: (bool didPop, dynamic result) async {
//         if (didPop) return;

//         // 1. Lock the disposal state immediately
//         _isDisposing = true;
//         _hideControlsTimer?.cancel();
//         _networkCheckTimer?.cancel();
//         _seekTimer?.cancel();

//         // 2. Force VLC to stop synchronously BEFORE the screen unmounts
//         if (activePlayer == 'VLC' && vlcController != null) {
//           try {
//             vlcController!.removeListener(_vlcListener);
//             await vlcController!.stop(); 
//           } catch (e) {
//             print("VLC stop error during pop: $e");
//           }
//         } 
//         // 3. Kill WebView audio
//         else if (activePlayer == 'WEB' && webViewController != null) {
//           try {
//             await webViewController!.evaluateJavascript(
//                 source: "var v = document.getElementById('video'); if(v) { v.pause(); v.removeAttribute('src'); v.load(); }");
//           } catch (_) {}
//         }

//         // 4. Now that native engines are quiet, close the screen safely
//         if (mounted) {
//           Navigator.of(context).pop();
//         }
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
//                 // 1. VIDEO LAYER (Always centered and scales perfectly)
//                 Positioned.fill(
//                   child: Stack(
//                     children: [
//                       // // WEB PLAYER
//                       // if (activePlayer == 'WEB')
//                       //   ExcludeFocus(
//                       //     child: Container(
//                       //       color: Colors.black,
//                       //       width: screenwdt,
//                       //       height: screenhgt,
//                       //       child: InAppWebView(
//                       //         key: const ValueKey('WEB_Player'),
//                       //         initialData: InAppWebViewInitialData(
//                       //           data: _getHtmlString(),
//                       //           mimeType: "text/html",
//                       //           encoding: "utf-8",
//                       //         ),
//                       //         initialSettings: settings,
//                       //         onWebViewCreated: (controller) {
//                       //           webViewController = controller;
//                       //           controller.addJavaScriptHandler(
//                       //               handlerName: 'videoState',
//                       //               callback: (args) {
//                       //                 if (!mounted ||
//                       //                     _isDisposing ||
//                       //                     args.isEmpty) return;
//                       //                 var state = args[0];

//                       //                 _currentPosition.value = Duration(
//                       //                     milliseconds:
//                       //                         state['position'].toInt());
//                       //                 _totalDuration.value = Duration(
//                       //                     milliseconds:
//                       //                         state['duration'].toInt());

//                       //                 bool newIsPlaying = state['isPlaying'];
//                       //                 bool newIsBuffering =
//                       //                     state['isBuffering'];
//                       //                 bool needsRebuild = false;

//                       //                 if (!_isVideoInitialized) {
//                       //                   _isVideoInitialized = true;
//                       //                   needsRebuild = true;
//                       //                 }
//                       //                 if (_isPlaying != newIsPlaying) {
//                       //                   _isPlaying = newIsPlaying;
//                       //                   needsRebuild = true;
//                       //                 }
//                       //                 if (_isBuffering != newIsBuffering) {
//                       //                   _isBuffering = newIsBuffering;
//                       //                   needsRebuild = true;
//                       //                 }

//                       //                 bool newLoadingVisible = newIsBuffering;
//                       //                 if (newIsPlaying && !newIsBuffering) {
//                       //                   newLoadingVisible = false;
//                       //                   _lastPlayingTime = DateTime.now();
//                       //                 }

//                       //                 if (_loadingVisible !=
//                       //                     newLoadingVisible) {
//                       //                   _loadingVisible = newLoadingVisible;
//                       //                   needsRebuild = true;
//                       //                 }

//                       //                 if (needsRebuild && mounted)
//                       //                   setState(() {});
//                       //               });
//                       //         },
//                       //       ),
//                       //     ),
//                       //   ),

// // WEB PLAYER
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

//                       // // VLC PLAYER
//                       // if (activePlayer == 'VLC' && vlcController != null)
//                       //   AnimatedScale(
//                       //     scale: targetScale,
//                       //     duration: const Duration(milliseconds: 300),
//                       //     curve: Curves.easeInOut,
//                       //     child: Container(
//                       //       width: screenwdt,
//                       //       height: screenhgt,
//                       //       decoration: BoxDecoration(
//                       //         color: Colors.black,
//                       //         borderRadius: BorderRadius.circular(
//                       //             _controlsVisible ? 24.0 : 0.0),
//                       //         boxShadow: _controlsVisible
//                       //             ? [
//                       //                 const BoxShadow(
//                       //                     color: Colors.black54,
//                       //                     blurRadius: 20,
//                       //                     spreadRadius: 5)
//                       //               ]
//                       //             : [],
//                       //       ),
//                       //       child: ClipRRect(
//                       //         borderRadius: BorderRadius.circular(
//                       //             _controlsVisible ? 24.0 : 0.0),
//                       //         child: LayoutBuilder(
//                       //           builder: (context, constraints) {
//                       //             final screenWidth = constraints.maxWidth;
//                       //             final screenHeight = constraints.maxHeight;

//                       //             double videoWidth =
//                       //                 vlcController!.value.size.width;
//                       //             double videoHeight =
//                       //                 vlcController!.value.size.height;

//                       //             if (videoWidth <= 0 || videoHeight <= 0) {
//                       //               videoWidth = 16.0;
//                       //               videoHeight = 9.0;
//                       //             }

//                       //             final videoRatio = videoWidth / videoHeight;
//                       //             final screenRatio =
//                       //                 screenWidth > 0 && screenHeight > 0
//                       //                     ? screenWidth / screenHeight
//                       //                     : 16 / 9;

//                       //             double scaleXInner = 1.0;
//                       //             double scaleYInner = 1.0;

//                       //             if (videoRatio < screenRatio) {
//                       //               scaleXInner = screenRatio / videoRatio;
//                       //             } else {
//                       //               scaleYInner = videoRatio / screenRatio;
//                       //             }

//                       //             const double maxScaleLimit = 1.35;
//                       //             if (scaleXInner > maxScaleLimit)
//                       //               scaleXInner = maxScaleLimit;
//                       //             if (scaleYInner > maxScaleLimit)
//                       //               scaleYInner = maxScaleLimit;

//                       //             return Container(
//                       //               width: screenWidth,
//                       //               height: screenHeight,
//                       //               color: Colors.black,
//                       //               child: Center(
//                       //                 child: Transform.scale(
//                       //                   scaleX: scaleXInner,
//                       //                   scaleY: scaleYInner,
//                       //                   alignment: Alignment.center,
//                       //                   child: VlcPlayer(
//                       //                     key: const ValueKey('VLC_PLAYER'),
//                       //                     controller: vlcController!,
//                       //                     aspectRatio: videoRatio,
//                       //                     placeholder: const Center(
//                       //                       child: RainbowPage(
//                       //                         backgroundColor: Colors.transparent,
//                       //                       ),
//                       //                     ),
//                       //                   ),
//                       //                 ),
//                       //               ),
//                       //             );
//                       //           },
//                       //         ),
//                       //       ),
//                       //     ),
//                       //   ),

// //                        if (activePlayer == 'VLC' && vlcController != null)
// //                          AnimatedPositioned(
// //                            duration: const Duration(milliseconds: 3),
// //                            curve: Curves.linear,
// //                            left: offsetLeft,
// //                            top: offsetTop,
// //                            right: fixedRight,
// //                            bottom: offsetBottom,
// //                            child: Container(
// //                              decoration: BoxDecoration(
// //                                color: Colors.black,
// //                                borderRadius: BorderRadius.circular(
// //                                  //   _controlsVisible
// //                                  (isLive && _controlsVisible)
// //                                    ? 8.0 : 0.0),
// //                                boxShadow:
// //                              //   _controlsVisible
// //  (isLive && _controlsVisible)
// //                                    ? [
// //                                        const BoxShadow(
// //                                            color: Colors.black54,
// //                                            blurRadius: 20,
// //                                            spreadRadius: 5)
// //                                      ]
// //                                    : [],
// //                              ),
// //                              child: ClipRRect(
// //                                borderRadius: BorderRadius.circular(
// //                                    _controlsVisible ? 8.0 : 0.0),
// //                                child: LayoutBuilder(
// //                                  builder: (context, constraints) {
// //                                    final screenWidth = constraints.maxWidth;
// //                                    final screenHeight = constraints.maxHeight;

// //                                    double videoWidth =
// //                                        vlcController!.value.size.width;
// //                                    double videoHeight =
// //                                        vlcController!.value.size.height;

// //                                    if (videoWidth <= 0 || videoHeight <= 0) {
// //                                      videoWidth = 16.0;
// //                                      videoHeight = 9.0;
// //                                    }

// //                                    final videoRatio = videoWidth / videoHeight;
// //                                    final screenRatio =
// //                                        screenWidth > 0 && screenHeight > 0
// //                                            ? screenWidth / screenHeight
// //                                            : 16 / 9;

// //                                    double scaleXInner = 1.0;
// //                                    double scaleYInner = 1.0;

// //                                    if (videoRatio < screenRatio) {
// //                                      scaleXInner = screenRatio / videoRatio;
// //                                    } else {
// //                                      scaleYInner = videoRatio / screenRatio;
// //                                    }

// //                                    const double maxScaleLimit = 1.35;
// //                                    if (scaleXInner > maxScaleLimit)
// //                                      scaleXInner = maxScaleLimit;
// //                                    if (scaleYInner > maxScaleLimit)
// //                                      scaleYInner = maxScaleLimit;

// //                                    return Container(
// //                                      width: screenWidth,
// //                                      height: screenHeight,
// //                                      color: Colors.black,
// //                                      child: Center(
// //                                        child: Transform.scale(
// //                                          scaleX: scaleXInner,
// //                                          scaleY: scaleYInner,
// //                                          // alignment: Alignment.center ,
// //                                          child: VlcPlayer(
// //                                            key: const ValueKey('VLC_PLAYER'),
// //                                            controller: vlcController!,
// //                                            aspectRatio: videoRatio,
// //                                            placeholder: const Center(
// //                                              child: RainbowPage(
// //                                                backgroundColor: Colors.transparent,
// //                                              ),
// //                                            ),
// //                                          ),
// //                                        ),
// //                                      ),
// //                                    );
// //                                  },
// //                                ),
// //                              ),
// //                            ),
// //                          ),

//                       if (activePlayer == 'VLC' && vlcController != null)
//                         AnimatedPositioned(
//                           duration: const Duration(milliseconds: 3),
//                           curve: Curves.linear,
//                           left: offsetLeft,
//                           top: offsetTop,
//                           right: fixedRight,
//                           bottom: offsetBottom,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.black,
//                               // Keep border radius at 0.0 for full screen
//                               borderRadius: BorderRadius.circular(0.0),
//                               // Remove the shadow
//                               boxShadow: [],
//                             ),
//                             child: ClipRRect(
//                               // Keep border radius at 0.0
//                               borderRadius: BorderRadius.circular(0.0),
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
//                                         child: VlcPlayer(
//                                           key: const ValueKey('VLC_PLAYER'),
//                                           controller: vlcController!,
//                                           aspectRatio: videoRatio,
//                                           placeholder: const Center(
//                                             child: RainbowPage(
//                                               backgroundColor:
//                                                   Colors.transparent,
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

//                 // 🟢 3. NAYA ERROR LAYER YAHAN ADD KAREIN
//                 if (_hasPlaybackError && !_loadingVisible)
//                   Container(
//                     color: Colors.black87,
//                     child: Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(Icons.error_outline,
//                               color: Colors.white70, size: 50),
//                           const SizedBox(height: 10),
//                           const Text("Stream Disconnected",
//                               style: TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold)),
//                           const SizedBox(height: 15),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   const Color(0xFF9B28F8), // Same purple theme
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 24, vertical: 12),
//                             ),
//                             // User remote se Enter dabayega to yehi channel dubara load hoga fresh token ke sath
//                             onPressed: () => _onItemTap(_focusedIndex),
//                             child: const Text("Retry",
//                                 style: TextStyle(
//                                     color: Colors.white, fontSize: 16)),
//                           )
//                         ],
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
//                       padding: EdgeInsets.only(top: screenhgt * 0.03),
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
//                       color: Colors.black.withOpacity(0.5),
//                       padding: const EdgeInsets.only(
//                           top: 20, bottom: 20, left: 20, right: 10),
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
//                 const SizedBox(width: 10),
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
//                 SizedBox(width: 10),
//               ],
//             ),

//             // --- NEECHE WALI ROW (Sirf Subtitles) ---
//             if (widget.liveStatus == false && activePlayer == 'VLC') ...[
//               const SizedBox(height: 1),
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
//             SizedBox(height: 10)
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
//   //   final double initialScale = (_controlsVisible && widget.channelList.isNotEmpty) ? 0.7 : 1.0;
//   //   final int initialRadius = _controlsVisible ? 24 : 0;

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
//   //         top: 0px; left: 0px; right: 0px; bottom: 0px;
//   //         transform: scale($initialScale);
//   //         border-radius: ${initialRadius}px;
//   //         transition: transform 0.3s ease, border-radius 0.3s ease;
//   //         transform-origin: center center;
//   //         overflow: hidden;
//   //         background: #000;
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

//   //       function setVideoScale(scale, radius) {
//   //          wrapper.style.transform = "scale(" + scale + ")";
//   //          wrapper.style.borderRadius = radius + "px";
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
//   //       video.addEventListener('loadstart', sendState);
//   //       video.addEventListener('loadeddata', sendState);
//   //       video.addEventListener('stalled', sendState);
//   //       video.addEventListener('canplay', sendState);

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

// //   void _updateWebBounds(bool showControls) {
// //     if (activePlayer != 'WEB' || webViewController == null) return;

// //     // Screen ka size nikalein
// //     final double screenwdt = MediaQuery.of(context).size.width;
// //     final double screenhgt = MediaQuery.of(context).size.height;

// //     // Panels ka size nikalein
// //     final double leftPanelWidth = screenwdt * 0.15;
// //     final double topTitleHeight = screenhgt * 0.10;
// //     final double bottomBarHeight = screenhgt * 0.15;

// //     // JS ko bhejne ke liye bounds calculate karein
// //     final double offsetLeft = (showControls && widget.channelList.isNotEmpty) ? leftPanelWidth : 0.0;
// //     final double offsetTop = showControls ? topTitleHeight : 0.0;
// //     final double offsetBottom = showControls ? bottomBarHeight : 0.0;
// //     final double offsetRight = showControls ? 16.0 : 0.0;
// //     final int radius = showControls ? 24 : 0;

// //     webViewController?.evaluateJavascript(
// //         source: "if(typeof window.setVideoBounds === 'function') window.setVideoBounds($offsetLeft, $offsetTop, $offsetRight, $offsetBottom, $radius);");
// //   }

// // void _updateWebBounds(bool showControls) {
// //   if (activePlayer != 'WEB' || webViewController == null) return;

// //   final double screenwdt = MediaQuery.of(context).size.width;
// //   final double screenhgt = MediaQuery.of(context).size.height;

// //   final double leftPanelWidth = screenwdt * 0.15;
// //   final double topTitleHeight = screenhgt * 0.10;
// //   final double bottomBarHeight = screenhgt * 0.15;

// //   // Logic: Left shift hoga par Right hamesha 0 rahega
// //   final double offsetLeft = (showControls && widget.channelList.isNotEmpty) ? leftPanelWidth : 0.0;
// //   final double offsetTop = showControls ? topTitleHeight : 0.0;
// //   final double offsetBottom = showControls ? bottomBarHeight : 0.0;

// //   // Isko 0.0 rakhein hamesha right alignment ke liye
// //   final double offsetRight = 0.0;

// //   final int radius = showControls ? 24 : 0;

// //   webViewController?.evaluateJavascript(
// //       source: "if(typeof window.setVideoBounds === 'function') window.setVideoBounds($offsetLeft, $offsetTop, $offsetRight, $offsetBottom, $radius);");
// // }

//   void _updateWebBounds(bool showControls) {
//     if (activePlayer != 'WEB' || webViewController == null) return;

//     final double screenwdt = MediaQuery.of(context).size.width;
//     final double screenhgt = MediaQuery.of(context).size.height;

//     final double leftPanelWidth = screenwdt * 0.13;
//     final double topTitleHeight = screenhgt * 0.10;
//     final double bottomBarHeight = screenhgt * 0.15;

//     final bool isLive = widget.liveStatus == true;

//     // Logic: Left, Top, and Bottom shift only happens if it is Live TV
//     final double offsetLeft =
//         (isLive && showControls && widget.channelList.isNotEmpty)
//             ? leftPanelWidth
//             : 0.0;
//     final double offsetTop = (isLive && showControls) ? topTitleHeight : 0.0;
//     final double offsetBottom =
//         (isLive && showControls) ? bottomBarHeight : 0.0;

//     // Right is always 0.0
//     final double offsetRight = 0.0;

//     // Only apply radius if it is Live TV
//     final int radius = (isLive && showControls) ? 24 : 0;

//     webViewController?.evaluateJavascript(
//         source:
//             "if(typeof window.setVideoBounds === 'function') window.setVideoBounds($offsetLeft, $offsetTop, $offsetRight, $offsetBottom, $radius);");
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
//           top: 0px; left: 0px; right: 0px; bottom: 0px; /* Full screen by default */
//           transition: top 0.03s ease, left 0.03s ease, right 0.03s ease, bottom 0.03s ease, border-radius 0.03s ease, box-shadow 0.03s ease;
//           overflow: hidden;
//           background: #000;
//         }
//         video {
//           width: 100%; height: 100%; /* Ye ensure karega video bahar na nikle */
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

//         // JS Function jo Flutter call karega
//         window.setVideoBounds = function(l, t, r, b, rad) {
//            wrapper.style.left = l + "px";
//            wrapper.style.top = t + "px";
//            wrapper.style.right = r + "px";
//            wrapper.style.bottom = b + "px";
//            wrapper.style.borderRadius = rad + "px";
           
//            if(l === 0 && t === 0) {
//                wrapper.style.boxShadow = "none";
//            } else {
//                wrapper.style.boxShadow = "0px 0px 20px 5px rgba(0,0,0,0.5)";
//            }
//         };

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
//     """;
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

//   // void _resetHideControlsTimer() {
//   //   _hideControlsTimer?.cancel();
//   //   if (_isDisposing) return;

//   //   if (!_controlsVisible) {
//   //     setState(() {
//   //       _controlsVisible = true;
//   //     });

//   //     // if (activePlayer == 'WEB') {
//   //     //   webViewController?.evaluateJavascript(
//   //     //       source: "if(typeof setVideoScale === 'function') setVideoScale(0.7, 24);");
//   //     // }

//   //     WidgetsBinding.instance.addPostFrameCallback((_) {
//   //       if (!mounted || _isDisposing) return;
//   //       if (widget.liveStatus == false || widget.channelList.isEmpty) {
//   //         FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//   //       } else {
//   //         FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//   //         _scrollToFocusedItem();
//   //       }
//   //     });
//   //   }
//   //   _startHideControlsTimer();
//   // }

//   void _resetHideControlsTimer() {
//     _hideControlsTimer?.cancel();
//     if (_isDisposing) return;

//     if (!_controlsVisible) {
//       setState(() {
//         _controlsVisible = true;
//       });

//       // --- ADD THIS HERE ---
//       _updateWebBounds(true);
//       // ---------------------

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

//   // void _startHideControlsTimer() {
//   //   _hideControlsTimer?.cancel();
//   //   if (_isDisposing) return;
//   //   _hideControlsTimer = Timer(const Duration(seconds: 10), () {
//   //     if (mounted && !_isDisposing) {
//   //       setState(() {
//   //         _controlsVisible = false;
//   //       });

//   //       // if (activePlayer == 'WEB') {
//   //       //   webViewController?.evaluateJavascript(
//   //       //       source: "if(typeof setVideoScale === 'function') setVideoScale(1.0, 0);");
//   //       // }

//   //       FocusScope.of(context).requestFocus(_mainFocusNode);
//   //     }
//   //   });
//   // }

//   void _startHideControlsTimer() {
//     _hideControlsTimer?.cancel();
//     if (_isDisposing) return;
//     _hideControlsTimer = Timer(const Duration(seconds: 10), () {
//       if (mounted && !_isDisposing) {
//         setState(() {
//           _controlsVisible = false;
//         });

//         // --- ADD THIS HERE ---
//         _updateWebBounds(false);
//         // ---------------------

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
//       return "${cNo.trim()} $name";
//     return name;
//   }

//   // void _safeDispose() {
//   //   if (_isDisposing) return;
//   //   _isDisposing = true;
//   //   _hideControlsTimer?.cancel();
//   //   _seekTimer?.cancel();
//   //   _networkCheckTimer?.cancel();
//   //   _keyRepeatTimer?.cancel();

//   //   if (vlcController != null) {
//   //     vlcController!.removeListener(_vlcListener);
//   //     vlcController!.stop();
//   //   }
//   //   KeepScreenOn.turnOff();
//   // }

// // void _safeDispose() {
// //     if (_isDisposing) return;
// //     _isDisposing = true;
// //     _hideControlsTimer?.cancel();
// //     _seekTimer?.cancel();
// //     _networkCheckTimer?.cancel();
// //     _keyRepeatTimer?.cancel();

// //     // 🟢 FIX: Detach immediately and dispose asynchronously
// //     if (vlcController != null) {
// //       final oldController = vlcController;
// //       vlcController = null; // Unlink from UI instantly
// //       oldController!.removeListener(_vlcListener);

// //       // Send the heavy disposal process to a background thread
// //       Future.microtask(() async {
// //         try {
// //           await oldController.stop();
// //           await oldController.dispose();
// //         } catch (e) {
// //           print("Background VLC dispose handled safely: $e");
// //         }
// //       });
// //     }
// //     KeepScreenOn.turnOff();
// //   }

//   void _safeDispose() {
//     if (_isDisposing) return;
//     _isDisposing = true;
//     _hideControlsTimer?.cancel();
//     _seekTimer?.cancel();
//     _networkCheckTimer?.cancel();
//     _keyRepeatTimer?.cancel();

//     // 🟢 FIX 1: Detach immediately and dispose with a hard TIMEOUT
//     if (vlcController != null) {
//       final oldController = vlcController;
//       vlcController = null; // Unlink from UI instantly

//       try {
//         oldController!.removeListener(_vlcListener);
//       } catch (_) {}

//       // Use Future.delayed instead of microtask to allow the screen to pop smoothly first
//       Future.delayed(const Duration(milliseconds: 300), () async {
//         try {
//           // CRITICAL: Add a timeout. If native VLC is frozen, this prevents the app from crashing.
//           await oldController?.stop().timeout(const Duration(seconds: 2));
//         } catch (e) {
//           print("VLC stop timed out or failed: $e");
//         }

//         try {
//           await oldController?.dispose().timeout(const Duration(seconds: 2));
//         } catch (e) {
//           print("VLC dispose timed out or failed: $e");
//         }
//       });
//     }

//     // 🟢 FIX 2: Clean up the WebView DOM to prevent background audio/memory leaks
//     if (webViewController != null) {
//       try {
//         webViewController!.evaluateJavascript(
//             source:
//                 "var v = document.getElementById('video'); if(v) { v.pause(); v.removeAttribute('src'); v.load(); }");
//       } catch (_) {}
//     }

//     KeepScreenOn.turnOff();
//   }

//   // @override
//   // void dispose() {
//   //   _safeDispose();
//   //   _mainFocusNode.dispose();
//   //   _currentPosition.dispose();
//   //   _totalDuration.dispose();
//   //   _previewPosition.dispose();

//   //   for (var node in focusNodes) {
//   //     node.dispose();
//   //   }
//   //   playPauseButtonFocusNode.dispose();
//   //   subtitleButtonFocusNode.dispose();
//   //   _scrollController.dispose();
//   //   vlcController?.dispose();

//   //   SystemChrome.setPreferredOrientations([
//   //     DeviceOrientation.portraitUp,
//   //     DeviceOrientation.landscapeLeft,
//   //     DeviceOrientation.landscapeRight,
//   //   ]);
//   //   WidgetsBinding.instance.removeObserver(this);
//   //   super.dispose();
//   // }

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

//     // 🟢 FIX: Do not call vlcController?.dispose() here, _safeDispose handles it asynchronously!

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
//   final int _seekDuration = 10;
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
//   // 🟢 NEW CODE: Error tracking variables
//   int _errorRetryCount = 0;
//   bool _hasPlaybackError = false;

//   // 🟢 NEW CODE: Anti-crash cooldown and setState throttle trackers
//   DateTime _lastRecoveryAttempt =
//       DateTime.now().subtract(const Duration(seconds: 15));
//   DateTime _lastSetStateTime = DateTime.now();
//   DateTime _lastPositionUpdateTime = DateTime.now(); // 🟢 FIX: Added for UI thread optimization

//   Map<String, Uint8List> _bannerCache = {};
//   bool _isDisposing = false;
//   final String localImage = "";
//   bool _isAppInBackground = false;

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
//         if (_bannerCache.length >= 15) {
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

//   // @override
//   // void didChangeAppLifecycleState(AppLifecycleState state) {
//   //   if (state == AppLifecycleState.inactive ||
//   //       state == AppLifecycleState.paused) {
//   //     if (activePlayer == 'VLC') vlcController?.pause();
//   //     if (activePlayer == 'WEB')
//   //       webViewController?.evaluateJavascript(
//   //           source: "document.getElementById('video').pause();");
//   //   } else if (state == AppLifecycleState.resumed) {
//   //     if (!_isUserPaused) {
//   //       if (activePlayer == 'VLC') vlcController?.play();
//   //       if (activePlayer == 'WEB')
//   //         webViewController?.evaluateJavascript(
//   //             source: "document.getElementById('video').play();");
//   //     }
//   //   }
//   // }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.inactive ||
//         state == AppLifecycleState.paused ||
//         state == AppLifecycleState.detached) {
//       _isAppInBackground = true; // 🟢 Stop watchdogs from running
//       if (activePlayer == 'VLC') vlcController?.pause();
//       if (activePlayer == 'WEB') {
//         webViewController?.evaluateJavascript(
//             source: "document.getElementById('video').pause();");
//       }
//     } else if (state == AppLifecycleState.resumed) {
//       _isAppInBackground = false; // 🟢 Allow watchdogs to run again
//       if (!_isUserPaused) {
//         if (activePlayer == 'VLC') vlcController?.play();
//         if (activePlayer == 'WEB') {
//           webViewController?.evaluateJavascript(
//               source: "document.getElementById('video').play();");
//         }
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
//     // 🟢 FIX: Added `_isAppInBackground` check
//     if (_currentModifiedUrl == null || _isDisposing || _isAppInBackground)
//       return;
//     // if (_currentModifiedUrl == null || _isDisposing) return;
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



//   // Future<void> _attemptResumeLiveStream() async {
//   //   if (!mounted ||
//   //       _isAttemptingResume ||
//   //       widget.liveStatus == false ||
//   //       _currentModifiedUrl == null ||
//   //       _isDisposing) {
//   //     return;
//   //   }

//   //   // 🟢 UPDATED CODE: Prevent aggressive looping to stop freezes
//   //   if (DateTime.now().difference(_lastRecoveryAttempt).inSeconds < 10) {
//   //     print("Recovery is on cooldown to prevent app crash. Skipping...");
//   //     return;
//   //   }
//   //   _lastRecoveryAttempt = DateTime.now();

//   //   setState(() {
//   //     _isAttemptingResume = true;
//   //     _loadingVisible = true;
//   //   });

//   //   try {
//   //     String newSecureUrl = await _getSecureUrlSafe(widget.videoUrl);

//   //     await _switchPlayerSafely(activePlayer, newSecureUrl);

//   //     _lastPlayingTime = DateTime.now();
//   //     _stallCounter = 0;
//   //     _isUserPaused = false;
//   //   } catch (e) {
//   //     print("Error: Recovery failed: $e");
//   //   } finally {
//   //     if (mounted) {
//   //       setState(() {
//   //         _isAttemptingResume = false;
//   //       });
//   //     }
//   //   }
//   // }



//   // Future<void> _attemptResumeLiveStream() async {
//   //   if (!mounted ||
//   //       _isAttemptingResume ||
//   //       widget.liveStatus == false ||
//   //       _currentModifiedUrl == null ||
//   //       _isDisposing) {
//   //     return;
//   //   }

//   //   // 🟢 FIX: Lowered cooldown from 10s to 3s so it doesn't block the _vlcListener's error retry loop
//   //   if (DateTime.now().difference(_lastRecoveryAttempt).inSeconds < 3) {
//   //     print("Recovery is on cooldown. Skipping...");
//   //     return;
//   //   }
//   //   _lastRecoveryAttempt = DateTime.now();

//   //   setState(() {
//   //     _isAttemptingResume = true;
//   //     _loadingVisible = true;
//   //   });

//   //   try {
//   //     String newSecureUrl = await _getSecureUrlSafe(widget.videoUrl);
//   //     await _switchPlayerSafely(activePlayer, newSecureUrl);

//   //     _lastPlayingTime = DateTime.now();
//   //     _stallCounter = 0;
//   //     _isUserPaused = false;
//   //   } catch (e) {
//   //     print("Error: Recovery failed: $e");
//   //   } finally {
//   //     if (mounted) {
//   //       setState(() {
//   //         _isAttemptingResume = false;
//   //       });
//   //     }
//   //   }
//   // }


// Future<void> _attemptResumeLiveStream() async {
//     if (!mounted ||
//         _isAttemptingResume ||
//         widget.liveStatus == false ||
//         _currentModifiedUrl == null ||
//         _isDisposing) {
//       return;
//     }

//     // 🟢 FIX: Lowered cooldown from 10s to 3s so it doesn't block the _vlcListener's error retry loop
//     if (DateTime.now().difference(_lastRecoveryAttempt).inSeconds < 3) {
//       print("Recovery is on cooldown. Skipping...");
//       return;
//     }
//     _lastRecoveryAttempt = DateTime.now();

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


//   // void _startPositionUpdater() {
//   //   Timer.periodic(const Duration(seconds: 2), (_) {
//   //     if (!mounted || _isScrubbing || _isAttemptingResume || _isDisposing)
//   //       return;

//   //     if (widget.liveStatus == true && _hasStartedPlaying && !_isUserPaused) {
//   //       if (_lastPositionCheck != Duration.zero &&
//   //           _currentPosition.value == _lastPositionCheck) {
//   //         _stallCounter++;
//   //       } else {
//   //         _stallCounter = 0;
//   //       }

//   //       if (_stallCounter >= 3) {
//   //         _attemptResumeLiveStream();
//   //         _stallCounter = 0;
//   //       }
//   //       _lastPositionCheck = _currentPosition.value;
//   //     }
//   //   });
//   // }

//   // void _startPositionUpdater() {
//   //   Timer.periodic(const Duration(seconds: 2), (_) {
//   //     if (!mounted || _isScrubbing || _isAttemptingResume || _isDisposing)
//   //       return;

//   //     if (widget.liveStatus == true && _hasStartedPlaying && !_isUserPaused) {
//   //       if (_lastPositionCheck != Duration.zero &&
//   //           _currentPosition.value == _lastPositionCheck) {
//   //         _stallCounter++;
//   //       } else {
//   //         _stallCounter = 0;
//   //       }

//   //       // 🟢 UPDATED CODE: Removed contradictory native pause/play queue to stop crash
//   //       // if (_stallCounter == 2 && activePlayer == 'VLC' && vlcController != null) {
//   //       //   vlcController!.pause().then((_) => vlcController!.play());
//   //       // }

//   //       if (_stallCounter >= 4) { // Increased to 4 to give the larger buffer time to work
//   //         _attemptResumeLiveStream();
//   //         _stallCounter = 0;
//   //       }
//   //       _lastPositionCheck = _currentPosition.value;
//   //     }
//   //   });
//   // }

//   // void _startPositionUpdater() {
//   //   Timer.periodic(const Duration(seconds: 2), (_) {
//   //     // 🟢 FIX: Added `_isAppInBackground` so the watchdog sleeps in the background
//   //     if (!mounted ||
//   //         _isScrubbing ||
//   //         _isAttemptingResume ||
//   //         _isDisposing ||
//   //         _isAppInBackground) {
//   //       return;
//   //     }
//   //     // if (!mounted || _isScrubbing || _isAttemptingResume || _isDisposing)
//   //     //   return;

//   //     // 🟢 FAST WATCHDOG: Dynamic timeout based on content type
//   //     if (_loadingVisible && !_isUserPaused) {
//   //       // 7 seconds for Live TV, 12 seconds for VOD
//   //       int timeoutSeconds = widget.liveStatus == true ? 7 : 12;

//   //       if (DateTime.now().difference(_lastPlayingTime) >
//   //           Duration(seconds: timeoutSeconds)) {
//   //         print(
//   //             "Watchdog triggered: Stuck in loading for ${timeoutSeconds}s. Forcing recovery...");
//   //         if (_errorRetryCount < 3) {
//   //           _errorRetryCount++;
//   //           _attemptResumeLiveStream();
//   //         } else {
//   //           // Stop infinite loading and show the Error/Retry UI after 3 failed attempts
//   //           setState(() {
//   //             _loadingVisible = false;
//   //             _hasPlaybackError = true;
//   //           });
//   //         }
//   //         // Reset the timer to prevent spamming retries
//   //         _lastPlayingTime = DateTime.now();
//   //         return;
//   //       }
//   //     }

//   //     if (widget.liveStatus == true && _hasStartedPlaying && !_isUserPaused) {
//   //       if (_lastPositionCheck != Duration.zero &&
//   //           _currentPosition.value == _lastPositionCheck) {
//   //         _stallCounter++;
//   //       } else {
//   //         _stallCounter = 0;

//   //         // 🟢 If the video is actively moving forward, force hide the loader
//   //         if (_loadingVisible && _hasStartedPlaying) {
//   //           setState(() {
//   //             _loadingVisible = false;
//   //           });
//   //         }
//   //       }

//   //       // Wait for ~8 seconds of continuous stalling before a native restart
//   //       if (_stallCounter >= 4) {
//   //         _attemptResumeLiveStream();
//   //         _stallCounter = 0;
//   //       }
//   //       _lastPositionCheck = _currentPosition.value;
//   //     }
//   //   });
//   // }



//   void _startPositionUpdater() {
//     Timer.periodic(const Duration(seconds: 2), (_) {
//       if (!mounted ||
//           _isScrubbing ||
//           _isAttemptingResume ||
//           _isDisposing ||
//           _isAppInBackground) {
//         return;
//       }

//       if (_loadingVisible && !_isUserPaused) {
//         int timeoutSeconds = widget.liveStatus == true ? 7 : 12;

//         if (DateTime.now().difference(_lastPlayingTime) > Duration(seconds: timeoutSeconds)) {
//           print("Watchdog triggered: Stuck in loading for ${timeoutSeconds}s. Forcing recovery...");
//           if (_errorRetryCount < 3) {
//             _errorRetryCount++;
//             _attemptResumeLiveStream();
//           } else {
//             setState(() {
//               _loadingVisible = false;
//               _hasPlaybackError = true;
//             });
//           }
//           _lastPlayingTime = DateTime.now();
//           return;
//         }
//       }

//       if (widget.liveStatus == true && _hasStartedPlaying && !_isUserPaused) {
//         // 🟢 FIX: Removed the `_lastPositionCheck != Duration.zero` block. 
//         // If a live stream is stuck at 0:00, it needs to be treated as a stall.
//         if (_currentPosition.value == _lastPositionCheck) {
//           _stallCounter++;
//         } else {
//           _stallCounter = 0;

//           if (_loadingVisible && _hasStartedPlaying) {
//             setState(() {
//               _loadingVisible = false;
//             });
//           }
//         }

//         if (_stallCounter >= 4) {
//           print("Watchdog triggered: Video frame frozen. Forcing recovery...");
//           _attemptResumeLiveStream();
//           _stallCounter = 0;
//         }
//         _lastPositionCheck = _currentPosition.value;
//       }
//     });
//   }

//   // String _buildVlcUrl(String baseUrl) {
//   //   final String networkCaching = "network-caching=3000";
//   //   final String liveCaching = "live-caching=1000";
//   //   final String fileCaching = "file-caching=500";
//   //   final String rtspTcp = "rtsp-tcp";
//   //   return widget.liveStatus == true
//   //       ? '$baseUrl?$networkCaching&$liveCaching&$fileCaching&$rtspTcp'
//   //       : '$baseUrl?$networkCaching&$fileCaching&$rtspTcp';
//   // }

//   String _buildVlcUrl(String baseUrl) {
//     // 🟢 FIX: Lowered buffer for TV to prevent RAM exhaustion (OOM crashes)
//     final String networkCaching = "network-caching=3000";
//     final String liveCaching = "live-caching=3000";
//     final String fileCaching = "file-caching=1500";
//     final String rtspTcp = "rtsp-tcp";

//     final String params = widget.liveStatus == true
//         ? '$networkCaching&$liveCaching&$fileCaching&$rtspTcp'
//         : '$networkCaching&$fileCaching&$rtspTcp';

//     // If URL already has a '?', append with '&'. Otherwise, use '?'
//     return baseUrl.contains('?') ? '$baseUrl&$params' : '$baseUrl?$params';
//   }

//   // Future<void> _initVlcPlayer(String baseUrl) async {
//   //   if (_isDisposing) return;

//   //   if (vlcController != null) {
//   //     vlcController!.removeListener(_vlcListener);
//   //     await vlcController!.stop();
//   //     await vlcController!.dispose();
//   //     vlcController = null;
//   //   }

//   //   _lastPlayingTime = DateTime.now();
//   //   _stallCounter = 0;
//   //   _hasStartedPlaying = false;
//   //   _hasFetchedSubtitles = false;

//   //   vlcController = VlcPlayerController.network(
//   //     _buildVlcUrl(baseUrl),
//   //     hwAcc: HwAcc.auto,
//   //     autoPlay: true,
//   //     options: VlcPlayerOptions(
//   //       http: VlcHttpOptions([
//   //         ':http-user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
//   //       ]),
//   //       video: VlcVideoOptions([
//   //         VlcVideoOptions.dropLateFrames(true),
//   //         VlcVideoOptions.skipFrames(true),
//   //       ]),
//   //     ),
//   //   );
//   //   vlcController!.addListener(_vlcListener);
//   //   if (mounted) setState(() {});
//   // }

// //   Future<void> _initVlcPlayer(String baseUrl) async {
// //     if (_isDisposing) return;

// //     if (vlcController != null) {
// //       vlcController!.removeListener(_vlcListener);
// //       await vlcController!.stop();
// //       await vlcController!.dispose();
// //       vlcController = null;
// //     }

// //     _lastPlayingTime = DateTime.now();
// //     _stallCounter = 0;
// //     _hasStartedPlaying = false;
// //     _hasFetchedSubtitles = false;

// //     vlcController = VlcPlayerController.network(
// //       _buildVlcUrl(baseUrl),
// //       hwAcc: HwAcc.auto ,
// //       autoPlay: true,
// //       options: VlcPlayerOptions(
// //         http: VlcHttpOptions([
// //           ':http-user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
// //         ]),
// //         video: VlcVideoOptions([
// //           VlcVideoOptions.dropLateFrames(true),
// //           VlcVideoOptions.skipFrames(true),
// //         ]),
// //         audio: VlcAudioOptions([
// //           // Corrected method name
// //           VlcAudioOptions.audioTimeStretch(true),
// //         ]),
// //         advanced: VlcAdvancedOptions([
// //           // Disabling input clock sync (0) helps prevent jerky playback on live network streams
// //           VlcAdvancedOptions.clockJitter(0),
// //           VlcAdvancedOptions.clockSynchronization(0),
// //         ]),
// //       ),
// //     );

// //     vlcController!.addListener(_vlcListener);
// //     if (mounted) setState(() {});
// //   }

// // Future<void> _initVlcPlayer(String baseUrl) async {
// //     if (_isDisposing) return;

// //     if (vlcController != null) {
// //       vlcController!.removeListener(_vlcListener);
// //       await vlcController!.stop();
// //       await vlcController!.dispose();
// //       vlcController = null;
// //     }

// //     _lastPlayingTime = DateTime.now();
// //     _stallCounter = 0;
// //     _hasStartedPlaying = false;
// //     _hasFetchedSubtitles = false;

// //     // 🟢 NEW CODE: Reset error state before initializing
// //     if (mounted) {
// //       setState(() {
// //         _hasPlaybackError = false;
// //       });
// //     }

// //     // 🟢 NEW CODE: Wrapped in try-catch to prevent initialization crashes
// //     try {
// //       vlcController = VlcPlayerController.network(
// //         _buildVlcUrl(baseUrl),
// //         hwAcc: HwAcc.auto ,
// //         autoPlay: true,
// //         options: VlcPlayerOptions(
// //           http: VlcHttpOptions([
// //             ':http-user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
// //           ]),
// //           video: VlcVideoOptions([
// //             VlcVideoOptions.dropLateFrames(true),
// //             VlcVideoOptions.skipFrames(true),
// //           ]),
// //           audio: VlcAudioOptions([
// //             VlcAudioOptions.audioTimeStretch(true),
// //           ]),
// //           advanced: VlcAdvancedOptions([
// //             VlcAdvancedOptions.clockJitter(0),
// //             VlcAdvancedOptions.clockSynchronization(0),
// //           ]),
// //         ),
// //       );

// //       vlcController!.addListener(_vlcListener);
// //       if (mounted) setState(() {});
// //     } catch (e) {
// //       print("Failed to initialize VLC Player: $e");
// //       if (mounted) {
// //          setState(() {
// //            _hasPlaybackError = true;
// //            _loadingVisible = false;
// //          });
// //       }
// //     }
// //   }

// // Future<void> _initVlcPlayer(String baseUrl) async {
// //     if (_isDisposing) return;

// //     // 🟢 FIX: Safe teardown of the old player before creating a new one
// //     if (vlcController != null) {
// //       final oldController = vlcController;
// //       vlcController = null;
// //       oldController!.removeListener(_vlcListener);
// //       Future.microtask(() async {
// //         try {
// //           await oldController.stop();
// //           await oldController.dispose();
// //         } catch (_) {}
// //       });
// //     }

// //     _lastPlayingTime = DateTime.now();
// //     _stallCounter = 0;
// //     _hasStartedPlaying = false;
// //     _hasFetchedSubtitles = false;

// //     if (mounted) {
// //       setState(() {
// //         _hasPlaybackError = false;
// //       });
// //     }

// //     try {
// //       vlcController = VlcPlayerController.network(
// //         _buildVlcUrl(baseUrl),
// //         hwAcc: HwAcc.full, // 🟢 FIX: Force Full Hardware Decoding for TVs
// //         autoPlay: true,
// //         options: VlcPlayerOptions(
// //           http: VlcHttpOptions([
// //             ':http-user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
// //             ':http-reconnect=true', // 🟢 FIX: Tell VLC to auto-reconnect broken pipes
// //           ]),
// //           video: VlcVideoOptions([
// //             VlcVideoOptions.dropLateFrames(true),
// //             VlcVideoOptions.skipFrames(true),
// //           ]),
// //           audio: VlcAudioOptions([
// //             VlcAudioOptions.audioTimeStretch(true),
// //           ]),
// //           advanced: VlcAdvancedOptions([
// //             VlcAdvancedOptions.networkCaching(2000), // Enforce caching at the engine level
// //             VlcAdvancedOptions.liveCaching(2000),
// //             VlcAdvancedOptions.clockJitter(0),
// //             VlcAdvancedOptions.clockSynchronization(0),
// //           ]),
// //         ),
// //       );

// //       vlcController!.addListener(_vlcListener);
// //       if (mounted) setState(() {});
// //     } catch (e) {
// //       print("Failed to initialize VLC Player: $e");
// //       if (mounted) {
// //          setState(() {
// //            _hasPlaybackError = true;
// //            _loadingVisible = false;
// //          });
// //       }
// //     }
// //   }

//   Future<void> _initVlcPlayer(String baseUrl) async {
//     if (_isDisposing) return;

//     // 🟢 FIX 4: Safe teardown of the old player before creating a new one
//     if (vlcController != null) {
//       final oldController = vlcController;
//       vlcController = null;

//       try {
//         oldController!.removeListener(_vlcListener);
//       } catch (_) {}

//       Future.delayed(const Duration(milliseconds: 100), () async {
//         try {
//           await oldController?.stop().timeout(const Duration(seconds: 2));
//         } catch (_) {}
//         try {
//           await oldController?.dispose().timeout(const Duration(seconds: 2));
//         } catch (_) {}
//       });
//     }

//     _lastPlayingTime = DateTime.now();
//     _stallCounter = 0;
//     _hasStartedPlaying = false;
//     _hasFetchedSubtitles = false;

//     if (mounted) {
//       setState(() {
//         _hasPlaybackError = false;
//       });
//     }

//     try {
//       bool isMkv = baseUrl.toLowerCase().contains('.mkv');
//       vlcController = VlcPlayerController.network(
//         _buildVlcUrl(baseUrl),
//         // 🟢 FIX: Disabled Hardware Acceleration completely to bypass MediaCodec GPU memory leaks on TV devices
//         // hwAcc: HwAcc.disabled, 
//         hwAcc: isMkv ? HwAcc.auto : HwAcc.auto,
//         autoPlay: true,
//         options: VlcPlayerOptions(
//           http: VlcHttpOptions([
//             ':http-user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
//             ':http-reconnect=true', // 🟢 Tell VLC to auto-reconnect broken pipes
//           ]),
//           video: VlcVideoOptions([
//             VlcVideoOptions.dropLateFrames(true),
//             VlcVideoOptions.skipFrames(true),
//           ]),
//           audio: VlcAudioOptions([
//             VlcAudioOptions.audioTimeStretch(true),
//           ]),
//           advanced: VlcAdvancedOptions([
//             VlcAdvancedOptions.networkCaching(
//                 isMkv ? 8000 : 5000), // 🟢 FIX: Lowered to 3000 to prevent OOM
//             VlcAdvancedOptions.liveCaching(isMkv ? 8000 : 5000),
//             VlcAdvancedOptions.clockJitter(0),
//             VlcAdvancedOptions.clockSynchronization(0),
//           ]),
//         ),
//       );

//       vlcController!.addListener(_vlcListener);
//       if (mounted) setState(() {});
//     } catch (e) {
//       print("Failed to initialize VLC Player: $e");
//       if (mounted) {
//         setState(() {
//           _hasPlaybackError = true;
//           _loadingVisible = false;
//         });
//       }
//     }
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

// //   void _vlcListener() {
// //     if (!mounted || vlcController == null || _isDisposing) return;
// //     final value = vlcController!.value;
// //     final PlayingState playingState = value.playingState;

// //     if (widget.liveStatus == true && !_isAttemptingResume) {
// //       if (playingState == PlayingState.playing) {
// //         _lastPlayingTime = DateTime.now();
// //         if (!_hasStartedPlaying) _hasStartedPlaying = true;
// //         if (!_hasFetchedSubtitles) _fetchSubtitles();
// //       } else if (playingState == PlayingState.buffering && _hasStartedPlaying) {
// //         if (DateTime.now().difference(_lastPlayingTime) >
// //             const Duration(seconds: 8)) _attemptResumeLiveStream();
// //       }
// //       else if (playingState == PlayingState.error) {
// //         _attemptResumeLiveStream();
// //       }
// //       else if ((playingState == PlayingState.stopped ||
// //               playingState == PlayingState.ended) &&
// //           _hasStartedPlaying) {
// //         if (DateTime.now().difference(_lastPlayingTime) >
// //             const Duration(seconds: 5)) _attemptResumeLiveStream();
// //       }
// //     } else if (playingState == PlayingState.paused) {
// //       if (_isUserPaused) {
// //         _lastPlayingTime = DateTime.now();
// //       } else {
// //         if (DateTime.now().difference(_lastPlayingTime) >
// //             const Duration(seconds: 5)) {
// //           if (widget.liveStatus == true) {
// //             _attemptResumeLiveStream();
// //           } else {
// //             _onNetworkReconnected();
// //           }
// //           _lastPlayingTime = DateTime.now();
// //         }
// //       }
// //     } else if (playingState == PlayingState.playing &&
// //         widget.liveStatus == false) {
// //       if (!_hasFetchedSubtitles) _fetchSubtitles();
// //     }

// //     _currentPosition.value = value.position;
// //     _totalDuration.value = value.duration;

// //     bool needsRebuild = false;
// //     if (_isPlaying != value.isPlaying) {
// //       _isPlaying = value.isPlaying;
// //       needsRebuild = true;
// //     }
// //     if (_isBuffering != value.isBuffering) {
// //       _isBuffering = value.isBuffering;
// //       needsRebuild = true;
// //     }
// //     if (!_isVideoInitialized && value.isInitialized) {
// //       _isVideoInitialized = true;
// //       needsRebuild = true;
// //     }

// //     bool newLoadingVisible = _isBuffering ||
// //         playingState == PlayingState.initializing ||
// //         _isAttemptingResume;
// //     if (_isPlaying && !_isBuffering) newLoadingVisible = false;

// //     if (_loadingVisible != newLoadingVisible) {
// //       _loadingVisible = newLoadingVisible;
// //       needsRebuild = true;
// //     }

// //     if (needsRebuild && mounted) setState(() {});
// //   }

// // void _vlcListener() {
// //     if (!mounted || vlcController == null || _isDisposing) return;
// //     final value = vlcController!.value;
// //     final PlayingState playingState = value.playingState;

// //     if (widget.liveStatus == true && !_isAttemptingResume) {
// //       if (playingState == PlayingState.playing) {
// //         _lastPlayingTime = DateTime.now();
// //         if (!_hasStartedPlaying) _hasStartedPlaying = true;
// //         if (!_hasFetchedSubtitles) _fetchSubtitles();
// //         // 🟢 FIX: Video successfully chal gaya, to error counter reset kar do
// //         if (_errorRetryCount > 0 || _hasPlaybackError) {
// //           setState(() {
// //             _errorRetryCount = 0;
// //             _hasPlaybackError = false;
// //           });
// //         }
// //       } else if (playingState == PlayingState.buffering && _hasStartedPlaying) {
// //         if (DateTime.now().difference(_lastPlayingTime) >
// //             const Duration(seconds: 8)) _attemptResumeLiveStream();
// //       } else if (playingState == PlayingState.error) {
// //         // 🟢 NEW CODE: Retry limit and memory delay to stop the crash loop
// //         if (_errorRetryCount < 3) {
// //           _errorRetryCount++;
// //           print("VLC Playback Error. Retrying $_errorRetryCount/3 in 3 seconds...");

// //           Future.delayed(const Duration(seconds: 3), () {
// //             if (mounted && !_isDisposing) _attemptResumeLiveStream();
// //           });
// //         } else {
// //           if (mounted) {
// //             setState(() {
// //               _isAttemptingResume = false;
// //               _loadingVisible = false;
// //               _hasPlaybackError = true;
// //             });
// //           }
// //         }
// //       } else if ((playingState == PlayingState.stopped ||
// //               playingState == PlayingState.ended) &&
// //           _hasStartedPlaying) {
// //         if (DateTime.now().difference(_lastPlayingTime) >
// //             const Duration(seconds: 5)) _attemptResumeLiveStream();
// //       }
// //     } else if (playingState == PlayingState.paused) {
// //       if (_isUserPaused) {
// //         _lastPlayingTime = DateTime.now();
// //       } else {
// //         if (DateTime.now().difference(_lastPlayingTime) >
// //             const Duration(seconds: 5)) {
// //           if (widget.liveStatus == true) {
// //             _attemptResumeLiveStream();
// //           } else {
// //             _onNetworkReconnected();
// //           }
// //           _lastPlayingTime = DateTime.now();
// //         }
// //       }
// //     } else if (playingState == PlayingState.playing &&
// //         widget.liveStatus == false) {
// //       if (!_hasFetchedSubtitles) _fetchSubtitles();
// //     }

// //     _currentPosition.value = value.position;
// //     _totalDuration.value = value.duration;

// //     bool needsRebuild = false;
// //     if (_isPlaying != value.isPlaying) {
// //       _isPlaying = value.isPlaying;
// //       needsRebuild = true;
// //     }
// //     if (_isBuffering != value.isBuffering) {
// //       _isBuffering = value.isBuffering;
// //       needsRebuild = true;
// //     }
// //     if (!_isVideoInitialized && value.isInitialized) {
// //       _isVideoInitialized = true;
// //       needsRebuild = true;
// //     }

// //     bool newLoadingVisible = _isBuffering ||
// //         playingState == PlayingState.initializing ||
// //         _isAttemptingResume;
// //     if (_isPlaying && !_isBuffering) newLoadingVisible = false;

// //     if (_loadingVisible != newLoadingVisible) {
// //       _loadingVisible = newLoadingVisible;
// //       needsRebuild = true;
// //     }

// //     // 🟢 UPDATED CODE: Throttle setState to prevent UI freeze from micro-stutters
// //     if (needsRebuild && mounted) {
// //       final now = DateTime.now();
// //       if (now.difference(_lastSetStateTime).inMilliseconds > 200) {
// //         setState(() {});
// //         _lastSetStateTime = now;
// //       }
// //     }
// //   }
// void _vlcListener() {
//     if (!mounted || vlcController == null || _isDisposing) return;
    
//     final value = vlcController!.value;
//     final PlayingState playingState = value.playingState;
//     final now = DateTime.now();

//     // 🟢 FIX: Update position ValueNotifiers only 4 times a second (250ms throttle) to stop GC memory thrashing
//     if (now.difference(_lastPositionUpdateTime).inMilliseconds > 250) {
//       _currentPosition.value = value.position;
//       _totalDuration.value = value.duration;
//       _lastPositionUpdateTime = now;
//     }

//     if (widget.liveStatus == true && !_isAttemptingResume) {
//       if (playingState == PlayingState.playing) {
//         _lastPlayingTime = DateTime.now();
//         if (!_hasStartedPlaying) _hasStartedPlaying = true;
        
//         if (_errorRetryCount > 0 || _hasPlaybackError) {
//           setState(() {
//             _errorRetryCount = 0;
//             _hasPlaybackError = false;
//           });
//         }
//       } else if (playingState == PlayingState.buffering && _hasStartedPlaying) {
//         if (DateTime.now().difference(_lastPlayingTime) > const Duration(seconds: 8)) {
//           _attemptResumeLiveStream();
//         }
//       } else if (playingState == PlayingState.error) {
//         if (_errorRetryCount < 3) {
//           _errorRetryCount++;
//           Future.delayed(const Duration(seconds: 3), () {
//             if (mounted && !_isDisposing) _attemptResumeLiveStream();
//           });
//         } else {
//           if (mounted && !_hasPlaybackError) { // Only rebuild if state actually changes
//             setState(() {
//               _isAttemptingResume = false;
//               _loadingVisible = false;
//               _hasPlaybackError = true;
//             });
//           }
//         }
//       } else if ((playingState == PlayingState.stopped || playingState == PlayingState.ended) && _hasStartedPlaying) {
//         if (DateTime.now().difference(_lastPlayingTime) > const Duration(seconds: 5)) {
//           _attemptResumeLiveStream();
//         }
//       }
//     } else if (playingState == PlayingState.paused) {
//        if (_isUserPaused) {
//          _lastPlayingTime = DateTime.now();
//        }
//     } else if (playingState == PlayingState.playing && widget.liveStatus == false) {
//       if (!_hasFetchedSubtitles) _fetchSubtitles();
//     }

//     // 🟢 FIX: Strict State Management to prevent Memory Fragmentation
//     bool newIsPlaying = value.isPlaying;
//     bool newIsBuffering = value.isBuffering;
//     bool newIsVideoInitialized = value.isInitialized;
    
//     bool newLoadingVisible = newIsBuffering || playingState == PlayingState.initializing || _isAttemptingResume;
//     if (playingState == PlayingState.playing) {
//       newLoadingVisible = false;
//     }

//     bool needsRebuild = false;

//     if (_isPlaying != newIsPlaying) {
//       _isPlaying = newIsPlaying;
//       needsRebuild = true;
//     }
//     if (_isBuffering != newIsBuffering) {
//       _isBuffering = newIsBuffering;
//       needsRebuild = true;
//     }
//     if (!_isVideoInitialized && newIsVideoInitialized) {
//       _isVideoInitialized = true;
//       needsRebuild = true;
//     }
//     if (_loadingVisible != newLoadingVisible) {
//       _loadingVisible = newLoadingVisible;
//       needsRebuild = true;
//     }

//     // Only rebuild if a major visual state changed, NOT on every frame tick
//     if (needsRebuild && mounted) {
//       if (now.difference(_lastSetStateTime).inMilliseconds > 250) {
//         setState(() {});
//         _lastSetStateTime = now;
//       }
//     }
//   }

// //   Future<void> _switchPlayerSafely(
// //       String targetPlayerType, String secureUrl) async {
// //     if (_isDisposing) return;

// //     setState(() {
// //       _loadingVisible = true;
// //       _isVideoInitialized = false;
// //     });

// //     if (activePlayer == 'VLC' && vlcController != null) {
// //       vlcController!.removeListener(_vlcListener);
// //       await vlcController!.stop();
// //       await vlcController!.dispose();
// //       vlcController = null;
// //     }
// //     webViewController = null;

// //     setState(() {
// //       activePlayer = 'NONE';
// //     });
// //     await Future.delayed(const Duration(milliseconds: 600));
// //     if (_isDisposing) return;

// //     _currentModifiedUrl = secureUrl;
// //     setState(() {
// //       activePlayer = targetPlayerType;
// //     });

// //     if (targetPlayerType == 'WEB') {
// //       if (webViewController != null) {
// //         await webViewController!.evaluateJavascript(
// //             source: "loadNewVideo('$_currentModifiedUrl');");
// //       }
// //     } else if (targetPlayerType == 'VLC') {
// //       await _initVlcPlayer(_currentModifiedUrl!);
// //     }
// //   }

// // Future<void> _switchPlayerSafely(
// //       String targetPlayerType, String secureUrl) async {
// //     if (_isDisposing) return;

// //     setState(() {
// //       _loadingVisible = true;
// //       _isVideoInitialized = false;
// //       // 🟢 NEW CODE: Reset error trackers when channel changes
// //       // _errorRetryCount = 0;
// //       _hasPlaybackError = false;
// //     });

// //     // 🟢 UPDATED CODE: Detach controller immediately and handle native disposal safely in background
// //     if (activePlayer == 'VLC' && vlcController != null) {
// //       final oldController = vlcController;
// //       vlcController = null;

// //       oldController!.removeListener(_vlcListener);

// //       Future.microtask(() async {
// //         try {
// //           await oldController.stop();
// //           await oldController.dispose();
// //         } catch (e) {
// //           print("Handled VLC disposal error: $e");
// //         }
// //       });
// //     }
// //     webViewController = null;

// //     setState(() {
// //       activePlayer = 'NONE';
// //     });
// //     await Future.delayed(const Duration(milliseconds: 600));
// //     if (_isDisposing) return;

// //     _currentModifiedUrl = secureUrl;
// //     setState(() {
// //       activePlayer = targetPlayerType;
// //     });

// //     if (targetPlayerType == 'WEB') {
// //       if (webViewController != null) {
// //         await webViewController!.evaluateJavascript(
// //             source: "loadNewVideo('$_currentModifiedUrl');");
// //       }
// //     } else if (targetPlayerType == 'VLC') {
// //       await _initVlcPlayer(_currentModifiedUrl!);
// //     }
// //   }

//   Future<void> _switchPlayerSafely(
//       String targetPlayerType, String secureUrl) async {
//     if (_isDisposing) return;

//     // 🟢 FIX: Clear ghost timers before switching channels to prevent C++ thread crashes
//     _seekTimer?.cancel();
//     _networkCheckTimer?.cancel();

//     setState(() {
//       _loadingVisible = true;
//       _isVideoInitialized = false;
//       _hasPlaybackError = false;
      
//       // 🟢 FIX: Temporarily remove InAppWebView completely from Widget Tree to kill background zombie process
//       if (targetPlayerType != 'WEB') {
//         activePlayer = 'NONE';
//       }
//     });

//     // 🟢 FIX 3: Safe channel switching with timeouts
//     if (activePlayer == 'VLC' && vlcController != null) {
//       final oldController = vlcController;
//       vlcController = null;

//       try {
//         oldController!.removeListener(_vlcListener);
//       } catch (_) {}

//       Future.delayed(const Duration(milliseconds: 100), () async {
//         try {
//           await oldController?.stop().timeout(const Duration(seconds: 2));
//         } catch (e) {
//           print("Handled VLC stop error during switch: $e");
//         }
//         try {
//           await oldController?.dispose().timeout(const Duration(seconds: 2));
//         } catch (e) {
//           print("Handled VLC dispose error during switch: $e");
//         }
//       });
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
//       _errorRetryCount = 0;
//       _hasPlaybackError = false;
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

//   // Future<void> _seekToPosition(Duration position) async {
//   //   if (_isSeeking || _isDisposing) return;
//   //   _isSeeking = true;
//   //   try {
//   //     if (activePlayer == 'WEB' && webViewController != null) {
//   //       double seconds = position.inMilliseconds / 1000.0;
//   //       await webViewController!.evaluateJavascript(
//   //           source:
//   //               "document.getElementById('video').currentTime = $seconds; document.getElementById('video').play();");
//   //     } else if (activePlayer == 'VLC' && vlcController != null) {
//   //       await vlcController!.seekTo(position);
//   //       await vlcController!.play();
//   //     }
//   //   } catch (e) {
//   //     print("Error during seek: $e");
//   //   } finally {
//   //     await Future.delayed(const Duration(milliseconds: 500));
//   //     _isSeeking = false;
//   //   }
//   // }



//   Future<void> _seekToPosition(Duration position) async {
//     if (_isSeeking || _isDisposing) return;
//     _isSeeking = true;

//     // 🟢 NEW: Seek karte waqt loader dikhayein taaki freeze jaisa na lage
//     setState(() {
//       _loadingVisible = true;
//     });

//     try {
//       if (activePlayer == 'WEB' && webViewController != null) {
//         double seconds = position.inMilliseconds / 1000.0;
//         await webViewController!.evaluateJavascript(
//             source:
//                 "document.getElementById('video').currentTime = $seconds; document.getElementById('video').play();");
//       } else if (activePlayer == 'VLC' && vlcController != null) {
        
//         // 🟢 TV HACK: Current playing state check karein
//         bool wasPlaying = vlcController!.value.isPlaying;
        
//         // 1. Agar video chal raha hai, toh seek se pehle PAUSE karein (audio aage na bhaage)
//         if (wasPlaying) {
//           await vlcController!.pause();
//         }
        
//         // 2. Seek command bhejein
//         await vlcController!.seekTo(position);
        
//         // 3. Hardware Decoder ko purane frames flush karne ka thoda time dein (300ms)
//         await Future.delayed(const Duration(milliseconds: 400));
        
//         // 4. Sab load hone ke baad PLAY karein
//         if (wasPlaying) {
//           await vlcController!.play();
//         }
//       }
//     } catch (e) {
//       print("Error during seek: $e");
//     } finally {
//       // Seek complete hone ke baad loader hata dein
//       await Future.delayed(const Duration(milliseconds: 500));
//       if (mounted) {
//         setState(() {
//           _isSeeking = false;
//           _loadingVisible = false;
//         });
//       }
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

//   @override
//   Widget build(BuildContext context) {
//     final double screenwdt = MediaQuery.of(context).size.width;
//     final double screenhgt = MediaQuery.of(context).size.height;
//     final double bottomBarHeight = screenhgt * 0.15;
//     final double topTitleHeight = screenhgt * 0.10;
//     final double leftPanelWidth = screenwdt * 0.13;

//     // Calculate dynamic smooth scale factor based on controls visibility
//     final double targetScale =
//         (_controlsVisible && widget.channelList.isNotEmpty) ? 0.8 : 1.0;

// //      // 1. Bounds Calculate karein (Yeh UI layout ke liye perfect jagah banayega)
// // final double offsetLeft = (_controlsVisible && widget.channelList.isNotEmpty) ? leftPanelWidth : 0.0;
// // final double offsetRight = _controlsVisible ? 16.0 : 0.0;
// // final double offsetTop = _controlsVisible ? topTitleHeight : 0.0;
// // final double offsetBottom = _controlsVisible ? bottomBarHeight : 0.0;

// // // Yeh calculate karega ki video left se kitna shift hoga
// // final double offsetLeft = (_controlsVisible && widget.channelList.isNotEmpty) ? leftPanelWidth : 0.0;

// // // Right ko hamesha fixed rakhein (0.0 ya small padding agar edge se satana hai)
// // const double fixedRight = 0.0;

// // // Top aur Bottom wahi rahenge jo aapne banaye hain
// // final double offsetTop = _controlsVisible ? topTitleHeight : 0.0;
// // final double offsetBottom = _controlsVisible ? bottomBarHeight : 0.0;

// // // Check if the current video is a Live stream or VOD
// // final bool isLive = widget.liveStatus == true;

// // // Apply offsets ONLY for Live TV. If it is VOD, offsets stay 0.0 (fullscreen).
// // final double offsetLeft = (isLive && _controlsVisible && widget.channelList.isNotEmpty) ? leftPanelWidth : 0.0;
// // const double fixedRight = 0.0;
// // final double offsetTop = (isLive && _controlsVisible) ? topTitleHeight : 0.0;
// // final double offsetBottom = (isLive && _controlsVisible) ? bottomBarHeight : 0.0;

// // Check if the current video is a Live stream or VOD
//     final bool isLive = widget.liveStatus == true;

// // Force all offsets to 0.0 so the video stays full screen and UI overlays on top
//     final double offsetLeft = 0.0;
//     const double fixedRight = 0.0;
//     final double offsetTop = 0.0;
//     final double offsetBottom = 0.0;

//     // return PopScope(
//     //   canPop: true,
//     //   onPopInvokedWithResult: (bool didPop, dynamic result) {
//     //     if (didPop) _safeDispose();
//     //   },
//     return PopScope(
//       canPop: false, // Prevent immediate pop to avoid native crashes
//       onPopInvokedWithResult: (bool didPop, dynamic result) async {
//         if (didPop) return;

//         // 1. Lock the disposal state immediately
//         _isDisposing = true;
//         _hideControlsTimer?.cancel();
//         _networkCheckTimer?.cancel();
//         _seekTimer?.cancel();

//         // 2. Force VLC to stop synchronously BEFORE the screen unmounts
//         if (activePlayer == 'VLC' && vlcController != null) {
//           try {
//             vlcController!.removeListener(_vlcListener);
//             await vlcController!.stop(); 
//           } catch (e) {
//             print("VLC stop error during pop: $e");
//           }
//         } 
//         // 3. Kill WebView audio
//         else if (activePlayer == 'WEB' && webViewController != null) {
//           try {
//             await webViewController!.evaluateJavascript(
//                 source: "var v = document.getElementById('video'); if(v) { v.pause(); v.removeAttribute('src'); v.load(); }");
//           } catch (_) {}
//         }

//         // 4. Now that native engines are quiet, close the screen safely
//         if (mounted) {
//           Navigator.of(context).pop();
//         }
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
//                 // 1. VIDEO LAYER (Always centered and scales perfectly)
//                 Positioned.fill(
//                   child: Stack(
//                     children: [
//                       // // WEB PLAYER
//                       // if (activePlayer == 'WEB')
//                       //   ExcludeFocus(
//                       //     child: Container(
//                       //       color: Colors.black,
//                       //       width: screenwdt,
//                       //       height: screenhgt,
//                       //       child: InAppWebView(
//                       //         key: const ValueKey('WEB_Player'),
//                       //         initialData: InAppWebViewInitialData(
//                       //           data: _getHtmlString(),
//                       //           mimeType: "text/html",
//                       //           encoding: "utf-8",
//                       //         ),
//                       //         initialSettings: settings,
//                       //         onWebViewCreated: (controller) {
//                       //           webViewController = controller;
//                       //           controller.addJavaScriptHandler(
//                       //               handlerName: 'videoState',
//                       //               callback: (args) {
//                       //                 if (!mounted ||
//                       //                     _isDisposing ||
//                       //                     args.isEmpty) return;
//                       //                 var state = args[0];

//                       //                 _currentPosition.value = Duration(
//                       //                     milliseconds:
//                       //                         state['position'].toInt());
//                       //                 _totalDuration.value = Duration(
//                       //                     milliseconds:
//                       //                         state['duration'].toInt());

//                       //                 bool newIsPlaying = state['isPlaying'];
//                       //                 bool newIsBuffering =
//                       //                     state['isBuffering'];
//                       //                 bool needsRebuild = false;

//                       //                 if (!_isVideoInitialized) {
//                       //                   _isVideoInitialized = true;
//                       //                   needsRebuild = true;
//                       //                 }
//                       //                 if (_isPlaying != newIsPlaying) {
//                       //                   _isPlaying = newIsPlaying;
//                       //                   needsRebuild = true;
//                       //                 }
//                       //                 if (_isBuffering != newIsBuffering) {
//                       //                   _isBuffering = newIsBuffering;
//                       //                   needsRebuild = true;
//                       //                 }

//                       //                 bool newLoadingVisible = newIsBuffering;
//                       //                 if (newIsPlaying && !newIsBuffering) {
//                       //                   newLoadingVisible = false;
//                       //                   _lastPlayingTime = DateTime.now();
//                       //                 }

//                       //                 if (_loadingVisible !=
//                       //                     newLoadingVisible) {
//                       //                   _loadingVisible = newLoadingVisible;
//                       //                   needsRebuild = true;
//                       //                 }

//                       //                 if (needsRebuild && mounted)
//                       //                   setState(() {});
//                       //               });
//                       //         },
//                       //       ),
//                       //     ),
//                       //   ),

// // WEB PLAYER
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

//                       // // VLC PLAYER
//                       // if (activePlayer == 'VLC' && vlcController != null)
//                       //   AnimatedScale(
//                       //     scale: targetScale,
//                       //     duration: const Duration(milliseconds: 300),
//                       //     curve: Curves.easeInOut,
//                       //     child: Container(
//                       //       width: screenwdt,
//                       //       height: screenhgt,
//                       //       decoration: BoxDecoration(
//                       //         color: Colors.black,
//                       //         borderRadius: BorderRadius.circular(
//                       //             _controlsVisible ? 24.0 : 0.0),
//                       //         boxShadow: _controlsVisible
//                       //             ? [
//                       //                 const BoxShadow(
//                       //                     color: Colors.black54,
//                       //                     blurRadius: 20,
//                       //                     spreadRadius: 5)
//                       //               ]
//                       //             : [],
//                       //       ),
//                       //       child: ClipRRect(
//                       //         borderRadius: BorderRadius.circular(
//                       //             _controlsVisible ? 24.0 : 0.0),
//                       //         child: LayoutBuilder(
//                       //           builder: (context, constraints) {
//                       //             final screenWidth = constraints.maxWidth;
//                       //             final screenHeight = constraints.maxHeight;

//                       //             double videoWidth =
//                       //                 vlcController!.value.size.width;
//                       //             double videoHeight =
//                       //                 vlcController!.value.size.height;

//                       //             if (videoWidth <= 0 || videoHeight <= 0) {
//                       //               videoWidth = 16.0;
//                       //               videoHeight = 9.0;
//                       //             }

//                       //             final videoRatio = videoWidth / videoHeight;
//                       //             final screenRatio =
//                       //                 screenWidth > 0 && screenHeight > 0
//                       //                     ? screenWidth / screenHeight
//                       //                     : 16 / 9;

//                       //             double scaleXInner = 1.0;
//                       //             double scaleYInner = 1.0;

//                       //             if (videoRatio < screenRatio) {
//                       //               scaleXInner = screenRatio / videoRatio;
//                       //             } else {
//                       //               scaleYInner = videoRatio / screenRatio;
//                       //             }

//                       //             const double maxScaleLimit = 1.35;
//                       //             if (scaleXInner > maxScaleLimit)
//                       //               scaleXInner = maxScaleLimit;
//                       //             if (scaleYInner > maxScaleLimit)
//                       //               scaleYInner = maxScaleLimit;

//                       //             return Container(
//                       //               width: screenWidth,
//                       //               height: screenHeight,
//                       //               color: Colors.black,
//                       //               child: Center(
//                       //                 child: Transform.scale(
//                       //                   scaleX: scaleXInner,
//                       //                   scaleY: scaleYInner,
//                       //                   alignment: Alignment.center,
//                       //                   child: VlcPlayer(
//                       //                     key: const ValueKey('VLC_PLAYER'),
//                       //                     controller: vlcController!,
//                       //                     aspectRatio: videoRatio,
//                       //                     placeholder: const Center(
//                       //                       child: RainbowPage(
//                       //                         backgroundColor: Colors.transparent,
//                       //                       ),
//                       //                     ),
//                       //                   ),
//                       //                 ),
//                       //               ),
//                       //             );
//                       //           },
//                       //         ),
//                       //       ),
//                       //     ),
//                       //   ),

// //                         if (activePlayer == 'VLC' && vlcController != null)
// //                           AnimatedPositioned(
// //                             duration: const Duration(milliseconds: 3),
// //                             curve: Curves.linear,
// //                             left: offsetLeft,
// //                             top: offsetTop,
// //                             right: fixedRight,
// //                             bottom: offsetBottom,
// //                             child: Container(
// //                               decoration: BoxDecoration(
// //                                 color: Colors.black,
// //                                 borderRadius: BorderRadius.circular(
// //                                   //   _controlsVisible
// //                                   (isLive && _controlsVisible)
// //                                     ? 8.0 : 0.0),
// //                                 boxShadow:
// //                               //   _controlsVisible
// //   (isLive && _controlsVisible)
// //                                     ? [
// //                                         const BoxShadow(
// //                                             color: Colors.black54,
// //                                             blurRadius: 20,
// //                                             spreadRadius: 5)
// //                                       ]
// //                                     : [],
// //                               ),
// //                               child: ClipRRect(
// //                                 borderRadius: BorderRadius.circular(
// //                                     _controlsVisible ? 8.0 : 0.0),
// //                                 child: LayoutBuilder(
// //                                   builder: (context, constraints) {
// //                                     final screenWidth = constraints.maxWidth;
// //                                     final screenHeight = constraints.maxHeight;

// //                                     double videoWidth =
// //                                         vlcController!.value.size.width;
// //                                     double videoHeight =
// //                                         vlcController!.value.size.height;

// //                                     if (videoWidth <= 0 || videoHeight <= 0) {
// //                                       videoWidth = 16.0;
// //                                       videoHeight = 9.0;
// //                                     }

// //                                     final videoRatio = videoWidth / videoHeight;
// //                                     final screenRatio =
// //                                         screenWidth > 0 && screenHeight > 0
// //                                             ? screenWidth / screenHeight
// //                                             : 16 / 9;

// //                                     double scaleXInner = 1.0;
// //                                     double scaleYInner = 1.0;

// //                                     if (videoRatio < screenRatio) {
// //                                       scaleXInner = screenRatio / videoRatio;
// //                                     } else {
// //                                       scaleYInner = videoRatio / screenRatio;
// //                                     }

// //                                     const double maxScaleLimit = 1.35;
// //                                     if (scaleXInner > maxScaleLimit)
// //                                       scaleXInner = maxScaleLimit;
// //                                     if (scaleYInner > maxScaleLimit)
// //                                       scaleYInner = maxScaleLimit;

// //                                     return Container(
// //                                       width: screenWidth,
// //                                       height: screenHeight,
// //                                       color: Colors.black,
// //                                       child: Center(
// //                                         child: Transform.scale(
// //                                           scaleX: scaleXInner,
// //                                           scaleY: scaleYInner,
// //                                           // alignment: Alignment.center ,
// //                                           child: VlcPlayer(
// //                                             key: const ValueKey('VLC_PLAYER'),
// //                                             controller: vlcController!,
// //                                             aspectRatio: videoRatio,
// //                                             placeholder: const Center(
// //                                               child: RainbowPage(
// //                                                 backgroundColor: Colors.transparent,
// //                                               ),
// //                                             ),
// //                                           ),
// //                                         ),
// //                                       ),
// //                                     );
// //                                   },
// //                                 ),
// //                               ),
// //                             ),
// //                           ),

//                       if (activePlayer == 'VLC' && vlcController != null)
//                         AnimatedPositioned(
//                           duration: const Duration(milliseconds: 3),
//                           curve: Curves.linear,
//                           left: offsetLeft,
//                           top: offsetTop,
//                           right: fixedRight,
//                           bottom: offsetBottom,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.black,
//                               // Keep border radius at 0.0 for full screen
//                               borderRadius: BorderRadius.circular(0.0),
//                               // Remove the shadow
//                               boxShadow: [],
//                             ),
//                             child: ClipRRect(
//                               // Keep border radius at 0.0
//                               borderRadius: BorderRadius.circular(0.0),
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
//                                         child: VlcPlayer(
//                                           key: const ValueKey('VLC_PLAYER'),
//                                           controller: vlcController!,
//                                           aspectRatio: videoRatio,
//                                           placeholder: const Center(
//                                             child: RainbowPage(
//                                               backgroundColor:
//                                                   Colors.transparent,
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

//                 // 🟢 3. NAYA ERROR LAYER YAHAN ADD KAREIN
//                 if (_hasPlaybackError && !_loadingVisible)
//                   Container(
//                     color: Colors.black87,
//                     child: Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(Icons.error_outline,
//                               color: Colors.white70, size: 50),
//                           const SizedBox(height: 10),
//                           const Text("Stream Disconnected",
//                               style: TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold)),
//                           const SizedBox(height: 15),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   const Color(0xFF9B28F8), // Same purple theme
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 24, vertical: 12),
//                             ),
//                             // User remote se Enter dabayega to yehi channel dubara load hoga fresh token ke sath
//                             onPressed: () => _onItemTap(_focusedIndex),
//                             child: const Text("Retry",
//                                 style: TextStyle(
//                                     color: Colors.white, fontSize: 16)),
//                           )
//                         ],
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
//                       padding: EdgeInsets.only(top: screenhgt * 0.03),
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
//                       color: Colors.black.withOpacity(0.5),
//                       padding: const EdgeInsets.only(
//                           top: 20, bottom: 20, left: 20, right: 10),
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
//                 const SizedBox(width: 10),
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
//                 SizedBox(width: 10),
//               ],
//             ),

//             // --- NEECHE WALI ROW (Sirf Subtitles) ---
//             if (widget.liveStatus == false && activePlayer == 'VLC') ...[
//               const SizedBox(height: 1),
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
//             SizedBox(height: 10)
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
//   //   final double initialScale = (_controlsVisible && widget.channelList.isNotEmpty) ? 0.7 : 1.0;
//   //   final int initialRadius = _controlsVisible ? 24 : 0;

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
//   //         top: 0px; left: 0px; right: 0px; bottom: 0px;
//   //         transform: scale($initialScale);
//   //         border-radius: ${initialRadius}px;
//   //         transition: transform 0.3s ease, border-radius 0.3s ease;
//   //         transform-origin: center center;
//   //         overflow: hidden;
//   //         background: #000;
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

//   //       function setVideoScale(scale, radius) {
//   //          wrapper.style.transform = "scale(" + scale + ")";
//   //          wrapper.style.borderRadius = radius + "px";
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
//   //       video.addEventListener('loadstart', sendState);
//   //       video.addEventListener('loadeddata', sendState);
//   //       video.addEventListener('stalled', sendState);
//   //       video.addEventListener('canplay', sendState);

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

// //   void _updateWebBounds(bool showControls) {
// //     if (activePlayer != 'WEB' || webViewController == null) return;

// //     // Screen ka size nikalein
// //     final double screenwdt = MediaQuery.of(context).size.width;
// //     final double screenhgt = MediaQuery.of(context).size.height;

// //     // Panels ka size nikalein
// //     final double leftPanelWidth = screenwdt * 0.15;
// //     final double topTitleHeight = screenhgt * 0.10;
// //     final double bottomBarHeight = screenhgt * 0.15;

// //     // JS ko bhejne ke liye bounds calculate karein
// //     final double offsetLeft = (showControls && widget.channelList.isNotEmpty) ? leftPanelWidth : 0.0;
// //     final double offsetTop = showControls ? topTitleHeight : 0.0;
// //     final double offsetBottom = showControls ? bottomBarHeight : 0.0;
// //     final double offsetRight = showControls ? 16.0 : 0.0;
// //     final int radius = showControls ? 24 : 0;

// //     webViewController?.evaluateJavascript(
// //         source: "if(typeof window.setVideoBounds === 'function') window.setVideoBounds($offsetLeft, $offsetTop, $offsetRight, $offsetBottom, $radius);");
// //   }

// // void _updateWebBounds(bool showControls) {
// //   if (activePlayer != 'WEB' || webViewController == null) return;

// //   final double screenwdt = MediaQuery.of(context).size.width;
// //   final double screenhgt = MediaQuery.of(context).size.height;

// //   final double leftPanelWidth = screenwdt * 0.15;
// //   final double topTitleHeight = screenhgt * 0.10;
// //   final double bottomBarHeight = screenhgt * 0.15;

// //   // Logic: Left shift hoga par Right hamesha 0 rahega
// //   final double offsetLeft = (showControls && widget.channelList.isNotEmpty) ? leftPanelWidth : 0.0;
// //   final double offsetTop = showControls ? topTitleHeight : 0.0;
// //   final double offsetBottom = showControls ? bottomBarHeight : 0.0;

// //   // Isko 0.0 rakhein hamesha right alignment ke liye
// //   final double offsetRight = 0.0;

// //   final int radius = showControls ? 24 : 0;

// //   webViewController?.evaluateJavascript(
// //       source: "if(typeof window.setVideoBounds === 'function') window.setVideoBounds($offsetLeft, $offsetTop, $offsetRight, $offsetBottom, $radius);");
// // }

//   void _updateWebBounds(bool showControls) {
//     if (activePlayer != 'WEB' || webViewController == null) return;

//     final double screenwdt = MediaQuery.of(context).size.width;
//     final double screenhgt = MediaQuery.of(context).size.height;

//     final double leftPanelWidth = screenwdt * 0.13;
//     final double topTitleHeight = screenhgt * 0.10;
//     final double bottomBarHeight = screenhgt * 0.15;

//     final bool isLive = widget.liveStatus == true;

//     // Logic: Left, Top, and Bottom shift only happens if it is Live TV
//     final double offsetLeft =
//         (isLive && showControls && widget.channelList.isNotEmpty)
//             ? leftPanelWidth
//             : 0.0;
//     final double offsetTop = (isLive && showControls) ? topTitleHeight : 0.0;
//     final double offsetBottom =
//         (isLive && showControls) ? bottomBarHeight : 0.0;

//     // Right is always 0.0
//     final double offsetRight = 0.0;

//     // Only apply radius if it is Live TV
//     final int radius = (isLive && showControls) ? 24 : 0;

//     webViewController?.evaluateJavascript(
//         source:
//             "if(typeof window.setVideoBounds === 'function') window.setVideoBounds($offsetLeft, $offsetTop, $offsetRight, $offsetBottom, $radius);");
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
//           top: 0px; left: 0px; right: 0px; bottom: 0px; /* Full screen by default */
//           transition: top 0.03s ease, left 0.03s ease, right 0.03s ease, bottom 0.03s ease, border-radius 0.03s ease, box-shadow 0.03s ease;
//           overflow: hidden;
//           background: #000;
//         }
//         video {
//           width: 100%; height: 100%; /* Ye ensure karega video bahar na nikle */
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

//         // JS Function jo Flutter call karega
//         window.setVideoBounds = function(l, t, r, b, rad) {
//            wrapper.style.left = l + "px";
//            wrapper.style.top = t + "px";
//            wrapper.style.right = r + "px";
//            wrapper.style.bottom = b + "px";
//            wrapper.style.borderRadius = rad + "px";
           
//            if(l === 0 && t === 0) {
//                wrapper.style.boxShadow = "none";
//            } else {
//                wrapper.style.boxShadow = "0px 0px 20px 5px rgba(0,0,0,0.5)";
//            }
//         };

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
//     """;
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

//   // void _resetHideControlsTimer() {
//   //   _hideControlsTimer?.cancel();
//   //   if (_isDisposing) return;

//   //   if (!_controlsVisible) {
//   //     setState(() {
//   //       _controlsVisible = true;
//   //     });

//   //     // if (activePlayer == 'WEB') {
//   //     //   webViewController?.evaluateJavascript(
//   //     //       source: "if(typeof setVideoScale === 'function') setVideoScale(0.7, 24);");
//   //     // }

//   //     WidgetsBinding.instance.addPostFrameCallback((_) {
//   //       if (!mounted || _isDisposing) return;
//   //       if (widget.liveStatus == false || widget.channelList.isEmpty) {
//   //         FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//   //       } else {
//   //         FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//   //         _scrollToFocusedItem();
//   //       }
//   //     });
//   //   }
//   //   _startHideControlsTimer();
//   // }

//   void _resetHideControlsTimer() {
//     _hideControlsTimer?.cancel();
//     if (_isDisposing) return;

//     if (!_controlsVisible) {
//       setState(() {
//         _controlsVisible = true;
//       });

//       // --- ADD THIS HERE ---
//       _updateWebBounds(true);
//       // ---------------------

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

//   // void _startHideControlsTimer() {
//   //   _hideControlsTimer?.cancel();
//   //   if (_isDisposing) return;
//   //   _hideControlsTimer = Timer(const Duration(seconds: 10), () {
//   //     if (mounted && !_isDisposing) {
//   //       setState(() {
//   //         _controlsVisible = false;
//   //       });

//   //       // if (activePlayer == 'WEB') {
//   //       //   webViewController?.evaluateJavascript(
//   //       //       source: "if(typeof setVideoScale === 'function') setVideoScale(1.0, 0);");
//   //       // }

//   //       FocusScope.of(context).requestFocus(_mainFocusNode);
//   //     }
//   //   });
//   // }

//   void _startHideControlsTimer() {
//     _hideControlsTimer?.cancel();
//     if (_isDisposing) return;
//     _hideControlsTimer = Timer(const Duration(seconds: 10), () {
//       if (mounted && !_isDisposing) {
//         setState(() {
//           _controlsVisible = false;
//         });

//         // --- ADD THIS HERE ---
//         _updateWebBounds(false);
//         // ---------------------

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
//       return "${cNo.trim()} $name";
//     return name;
//   }

//   // void _safeDispose() {
//   //   if (_isDisposing) return;
//   //   _isDisposing = true;
//   //   _hideControlsTimer?.cancel();
//   //   _seekTimer?.cancel();
//   //   _networkCheckTimer?.cancel();
//   //   _keyRepeatTimer?.cancel();

//   //   if (vlcController != null) {
//   //     vlcController!.removeListener(_vlcListener);
//   //     vlcController!.stop();
//   //   }
//   //   KeepScreenOn.turnOff();
//   // }

// // void _safeDispose() {
// //      if (_isDisposing) return;
// //      _isDisposing = true;
// //      _hideControlsTimer?.cancel();
// //      _seekTimer?.cancel();
// //      _networkCheckTimer?.cancel();
// //      _keyRepeatTimer?.cancel();

// //      // 🟢 FIX: Detach immediately and dispose asynchronously
// //      if (vlcController != null) {
// //        final oldController = vlcController;
// //        vlcController = null; // Unlink from UI instantly
// //        oldController!.removeListener(_vlcListener);

// //        // Send the heavy disposal process to a background thread
// //        Future.microtask(() async {
// //          try {
// //            await oldController.stop();
// //            await oldController.dispose();
// //          } catch (e) {
// //            print("Background VLC dispose handled safely: $e");
// //          }
// //        });
// //      }
// //      KeepScreenOn.turnOff();
// //    }

//   void _safeDispose() {
//     if (_isDisposing) return;
//     _isDisposing = true;
//     _hideControlsTimer?.cancel();
//     _seekTimer?.cancel();
//     _networkCheckTimer?.cancel();
//     _keyRepeatTimer?.cancel();

//     // 🟢 FIX 1: Detach immediately and dispose with a hard TIMEOUT
//     if (vlcController != null) {
//       final oldController = vlcController;
//       vlcController = null; // Unlink from UI instantly

//       try {
//         oldController!.removeListener(_vlcListener);
//       } catch (_) {}

//       // Use Future.delayed instead of microtask to allow the screen to pop smoothly first
//       Future.delayed(const Duration(milliseconds: 300), () async {
//         try {
//           // CRITICAL: Add a timeout. If native VLC is frozen, this prevents the app from crashing.
//           await oldController?.stop().timeout(const Duration(seconds: 2));
//         } catch (e) {
//           print("VLC stop timed out or failed: $e");
//         }

//         try {
//           await oldController?.dispose().timeout(const Duration(seconds: 2));
//         } catch (e) {
//           print("VLC dispose timed out or failed: $e");
//         }
//       });
//     }

//     // 🟢 FIX 2: Clean up the WebView DOM to prevent background audio/memory leaks
//     if (webViewController != null) {
//       try {
//         webViewController!.evaluateJavascript(
//             source:
//                 "var v = document.getElementById('video'); if(v) { v.pause(); v.removeAttribute('src'); v.load(); }");
//       } catch (_) {}
//     }

//     KeepScreenOn.turnOff();
//   }

//   // @override
//   // void dispose() {
//   //   _safeDispose();
//   //   _mainFocusNode.dispose();
//   //   _currentPosition.dispose();
//   //   _totalDuration.dispose();
//   //   _previewPosition.dispose();

//   //   for (var node in focusNodes) {
//   //     node.dispose();
//   //   }
//   //   playPauseButtonFocusNode.dispose();
//   //   subtitleButtonFocusNode.dispose();
//   //   _scrollController.dispose();
//   //   vlcController?.dispose();

//   //   SystemChrome.setPreferredOrientations([
//   //     DeviceOrientation.portraitUp,
//   //     DeviceOrientation.landscapeLeft,
//   //     DeviceOrientation.landscapeRight,
//   //   ]);
//   //   WidgetsBinding.instance.removeObserver(this);
//   //   super.dispose();
//   // }

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

//     // 🟢 FIX: Do not call vlcController?.dispose() here, _safeDispose handles it asynchronously!

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
//   final int _seekDuration = 10;
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
  
//   // 🟢 Error tracking variables
//   int _errorRetryCount = 0;
//   bool _hasPlaybackError = false;

//   // 🟢 Anti-crash cooldown and setState throttle trackers
//   DateTime _lastRecoveryAttempt =
//       DateTime.now().subtract(const Duration(seconds: 15));
//   DateTime _lastSetStateTime = DateTime.now();
//   DateTime _lastPositionUpdateTime = DateTime.now(); 

//   Map<String, Uint8List> _bannerCache = {};
//   bool _isDisposing = false;
//   final String localImage = "";
//   bool _isAppInBackground = false;

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
//         if (_bannerCache.length >= 15) {
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
//         state == AppLifecycleState.paused ||
//         state == AppLifecycleState.detached) {
//       _isAppInBackground = true; // 🟢 Stop watchdogs from running
//       if (activePlayer == 'VLC') vlcController?.pause();
//       if (activePlayer == 'WEB') {
//         webViewController?.evaluateJavascript(
//             source: "document.getElementById('video').pause();");
//       }
//     } else if (state == AppLifecycleState.resumed) {
//       _isAppInBackground = false; // 🟢 Allow watchdogs to run again
//       if (!_isUserPaused) {
//         if (activePlayer == 'VLC') vlcController?.play();
//         if (activePlayer == 'WEB') {
//           webViewController?.evaluateJavascript(
//               source: "document.getElementById('video').play();");
//         }
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
//     if (_currentModifiedUrl == null || _isDisposing || _isAppInBackground)
//       return;
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

//     if (DateTime.now().difference(_lastRecoveryAttempt).inSeconds < 3) {
//       print("Recovery is on cooldown. Skipping...");
//       return;
//     }
//     _lastRecoveryAttempt = DateTime.now();

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
//       if (!mounted ||
//           _isScrubbing ||
//           _isAttemptingResume ||
//           _isDisposing ||
//           _isAppInBackground) {
//         return;
//       }

//       if (_loadingVisible && !_isUserPaused) {
//         int timeoutSeconds = widget.liveStatus == true ? 7 : 12;

//         if (DateTime.now().difference(_lastPlayingTime) > Duration(seconds: timeoutSeconds)) {
//           print("Watchdog triggered: Stuck in loading for ${timeoutSeconds}s. Forcing recovery...");
//           if (_errorRetryCount < 3) {
//             _errorRetryCount++;
//             _attemptResumeLiveStream();
//           } else {
//             setState(() {
//               _loadingVisible = false;
//               _hasPlaybackError = true;
//             });
//           }
//           _lastPlayingTime = DateTime.now();
//           return;
//         }
//       }

//       if (widget.liveStatus == true && _hasStartedPlaying && !_isUserPaused) {
//         if (_currentPosition.value == _lastPositionCheck) {
//           _stallCounter++;
//         } else {
//           _stallCounter = 0;

//           if (_loadingVisible && _hasStartedPlaying) {
//             setState(() {
//               _loadingVisible = false;
//             });
//           }
//         }

//         if (_stallCounter >= 4) {
//           print("Watchdog triggered: Video frame frozen. Forcing recovery...");
//           _attemptResumeLiveStream();
//           _stallCounter = 0;
//         }
//         _lastPositionCheck = _currentPosition.value;
//       }
//     });
//   }

//   // String _buildVlcUrl(String baseUrl) {
//   //   final String networkCaching = "network-caching=3000";
//   //   final String liveCaching = "live-caching=3000";
//   //   final String fileCaching = "file-caching=1500";
//   //   final String rtspTcp = "rtsp-tcp";

//   //   final String params = widget.liveStatus == true
//   //       ? '$networkCaching&$liveCaching&$fileCaching&$rtspTcp'
//   //       : '$networkCaching&$fileCaching&$rtspTcp';

//   //   return baseUrl.contains('?') ? '$baseUrl&$params' : '$baseUrl?$params';
//   // }



//   String _buildVlcUrl(String baseUrl) {
//     // We removed the hardcoded caching params here because they conflict 
//     // with the VlcAdvancedOptions we set in the controller below.
//     final String rtspTcp = "rtsp-tcp";
//     return baseUrl.contains('?') ? '$baseUrl&$rtspTcp' : '$baseUrl?$rtspTcp';
//   }

//   Future<void> _initVlcPlayer(String baseUrl) async {
//     if (_isDisposing) return;

//     if (vlcController != null) {
//       final oldController = vlcController;
//       vlcController = null;

//       try {
//         oldController!.removeListener(_vlcListener);
//       } catch (_) {}

//       Future.delayed(const Duration(milliseconds: 100), () async {
//         try {
//           await oldController?.stop().timeout(const Duration(seconds: 2));
//         } catch (_) {}
//         try {
//           await oldController?.dispose().timeout(const Duration(seconds: 2));
//         } catch (_) {}
//       });
//     }

//     _lastPlayingTime = DateTime.now();
//     _stallCounter = 0;
//     _hasStartedPlaying = false;
//     _hasFetchedSubtitles = false;

//     if (mounted) {
//       setState(() {
//         _hasPlaybackError = false;
//       });
//     }

//     try {
//       bool isMkv = baseUrl.toLowerCase().contains('.mkv');
//       vlcController = VlcPlayerController.network(
//         _buildVlcUrl(baseUrl),
//         hwAcc: isMkv ? HwAcc.auto : HwAcc.auto,
//         autoPlay: true,
//         options: VlcPlayerOptions(
//           http: VlcHttpOptions([
//             ':http-user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
//             ':http-reconnect=true', 
//           ]),
//           video: VlcVideoOptions([
//             VlcVideoOptions.dropLateFrames(true),
//             VlcVideoOptions.skipFrames(true),
//           ]),
//           audio: VlcAudioOptions([
//             VlcAudioOptions.audioTimeStretch(true),
//           ]),
//           advanced: VlcAdvancedOptions([
//             // 🟢 CRITICAL FIX: Ensure caching does not exceed RAM limits on Android TV
//             VlcAdvancedOptions.networkCaching(2000), 
//             VlcAdvancedOptions.liveCaching(2000),
//             VlcAdvancedOptions.clockJitter(0),
//             VlcAdvancedOptions.clockSynchronization(0),
//           ]),
//         ),
//       );

//       vlcController!.addListener(_vlcListener);
//       if (mounted) setState(() {});
//     } catch (e) {
//       print("Failed to initialize VLC Player: $e");
//       if (mounted) {
//         setState(() {
//           _hasPlaybackError = true;
//           _loadingVisible = false;
//         });
//       }
//     }
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
//     final now = DateTime.now();

//     if (now.difference(_lastPositionUpdateTime).inMilliseconds > 250) {
//       _currentPosition.value = value.position;
//       _totalDuration.value = value.duration;
//       _lastPositionUpdateTime = now;
//     }

//     if (widget.liveStatus == true && !_isAttemptingResume) {
//       if (playingState == PlayingState.playing) {
//         _lastPlayingTime = DateTime.now();
//         if (!_hasStartedPlaying) _hasStartedPlaying = true;
        
//         if (_errorRetryCount > 0 || _hasPlaybackError) {
//           setState(() {
//             _errorRetryCount = 0;
//             _hasPlaybackError = false;
//           });
//         }
//       } else if (playingState == PlayingState.buffering && _hasStartedPlaying) {
//         if (DateTime.now().difference(_lastPlayingTime) > const Duration(seconds: 8)) {
//           _attemptResumeLiveStream();
//         }
//       } else if (playingState == PlayingState.error) {
//         if (_errorRetryCount < 3) {
//           _errorRetryCount++;
//           Future.delayed(const Duration(seconds: 3), () {
//             if (mounted && !_isDisposing) _attemptResumeLiveStream();
//           });
//         } else {
//           if (mounted && !_hasPlaybackError) { 
//             setState(() {
//               _isAttemptingResume = false;
//               _loadingVisible = false;
//               _hasPlaybackError = true;
//             });
//           }
//         }
//       } else if ((playingState == PlayingState.stopped || playingState == PlayingState.ended) && _hasStartedPlaying) {
//         if (DateTime.now().difference(_lastPlayingTime) > const Duration(seconds: 5)) {
//           _attemptResumeLiveStream();
//         }
//       }
//     } else if (playingState == PlayingState.paused) {
//        if (_isUserPaused) {
//          _lastPlayingTime = DateTime.now();
//        }
//     } else if (playingState == PlayingState.playing && widget.liveStatus == false) {
//       if (!_hasFetchedSubtitles) _fetchSubtitles();
//     }

//     bool newIsPlaying = value.isPlaying;
//     bool newIsBuffering = value.isBuffering;
//     bool newIsVideoInitialized = value.isInitialized;
    
//     bool newLoadingVisible = newIsBuffering || playingState == PlayingState.initializing || _isAttemptingResume;
//     if (playingState == PlayingState.playing) {
//       newLoadingVisible = false;
//     }

//     bool needsRebuild = false;

//     if (_isPlaying != newIsPlaying) {
//       _isPlaying = newIsPlaying;
//       needsRebuild = true;
//     }
//     if (_isBuffering != newIsBuffering) {
//       _isBuffering = newIsBuffering;
//       needsRebuild = true;
//     }
//     if (!_isVideoInitialized && newIsVideoInitialized) {
//       _isVideoInitialized = true;
//       needsRebuild = true;
//     }
//     if (_loadingVisible != newLoadingVisible) {
//       _loadingVisible = newLoadingVisible;
//       needsRebuild = true;
//     }

//     if (needsRebuild && mounted) {
//       if (now.difference(_lastSetStateTime).inMilliseconds > 250) {
//         setState(() {});
//         _lastSetStateTime = now;
//       }
//     }
//   }

//   Future<void> _switchPlayerSafely(
//       String targetPlayerType, String secureUrl) async {
//     if (_isDisposing) return;

//     _seekTimer?.cancel();
//     _networkCheckTimer?.cancel();

//     setState(() {
//       _loadingVisible = true;
//       _isVideoInitialized = false;
//       _hasPlaybackError = false;
      
//       if (targetPlayerType != 'WEB') {
//         activePlayer = 'NONE';
//       }
//     });

//     if (activePlayer == 'VLC' && vlcController != null) {
//       final oldController = vlcController;
//       vlcController = null;

//       try {
//         oldController!.removeListener(_vlcListener);
//       } catch (_) {}

//       Future.delayed(const Duration(milliseconds: 100), () async {
//         try {
//           await oldController?.stop().timeout(const Duration(seconds: 2));
//         } catch (e) {
//           print("Handled VLC stop error during switch: $e");
//         }
//         try {
//           await oldController?.dispose().timeout(const Duration(seconds: 2));
//         } catch (e) {
//           print("Handled VLC dispose error during switch: $e");
//         }
//       });
//     }
//     webViewController = null;

//     setState(() {
//       activePlayer = 'NONE';
//     });

//     // 🟢 CRITICAL FIX: Wait 1.5s for hardware decoders to flush old video before launching new one
//     await Future.delayed(const Duration(milliseconds: 1500));
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
//       _errorRetryCount = 0;
//       _hasPlaybackError = false;
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

//     setState(() {
//       _loadingVisible = true;
//     });

//     try {
//       if (activePlayer == 'WEB' && webViewController != null) {
//         double seconds = position.inMilliseconds / 1000.0;
//         await webViewController!.evaluateJavascript(
//             source:
//                 "document.getElementById('video').currentTime = $seconds; document.getElementById('video').play();");
//       } else if (activePlayer == 'VLC' && vlcController != null) {
        
//         bool wasPlaying = vlcController!.value.isPlaying;
        
//         if (wasPlaying) {
//           await vlcController!.pause();
//         }
        
//         await vlcController!.seekTo(position);
        
//         await Future.delayed(const Duration(milliseconds: 400));
        
//         if (wasPlaying) {
//           await vlcController!.play();
//         }
//       }
//     } catch (e) {
//       print("Error during seek: $e");
//     } finally {
//       await Future.delayed(const Duration(milliseconds: 500));
//       if (mounted) {
//         setState(() {
//           _isSeeking = false;
//           _loadingVisible = false;
//         });
//       }
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

//   @override
//   Widget build(BuildContext context) {
//     final double screenwdt = MediaQuery.of(context).size.width;
//     final double screenhgt = MediaQuery.of(context).size.height;
//     final double bottomBarHeight = screenhgt * 0.15;
//     final double topTitleHeight = screenhgt * 0.10;
//     final double leftPanelWidth = screenwdt * 0.13;

//     final double targetScale =
//         (_controlsVisible && widget.channelList.isNotEmpty) ? 0.8 : 1.0;

//     final bool isLive = widget.liveStatus == true;

//     final double offsetLeft = 0.0;
//     const double fixedRight = 0.0;
//     final double offsetTop = 0.0;
//     final double offsetBottom = 0.0;

//     return PopScope(
//       canPop: false, 
//       onPopInvokedWithResult: (bool didPop, dynamic result) async {
//         if (didPop) return;

//         _isDisposing = true;
//         _hideControlsTimer?.cancel();
//         _networkCheckTimer?.cancel();
//         _seekTimer?.cancel();

//         if (activePlayer == 'VLC' && vlcController != null) {
//           try {
//             vlcController!.removeListener(_vlcListener);
//             await vlcController!.stop(); 
//           } catch (e) {
//             print("VLC stop error during pop: $e");
//           }
//         } 
//         else if (activePlayer == 'WEB' && webViewController != null) {
//           try {
//             await webViewController!.evaluateJavascript(
//                 source: "var v = document.getElementById('video'); if(v) { v.pause(); v.removeAttribute('src'); v.load(); }");
//           } catch (_) {}
//         }

//         if (mounted) {
//           Navigator.of(context).pop();
//         }
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
//                 // 1. VIDEO LAYER 
//                 Positioned.fill(
//                   child: Stack(
//                     children: [
//                       // WEB PLAYER
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
//                           duration: const Duration(milliseconds: 3),
//                           curve: Curves.linear,
//                           left: offsetLeft,
//                           top: offsetTop,
//                           right: fixedRight,
//                           bottom: offsetBottom,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.black,
//                               borderRadius: BorderRadius.circular(0.0),
//                               boxShadow: [],
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(0.0),
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
//                                         child: VlcPlayer(
//                                           key: const ValueKey('VLC_PLAYER'),
//                                           controller: vlcController!,
//                                           aspectRatio: videoRatio,
//                                           placeholder: const Center(
//                                             child: RainbowPage(
//                                               backgroundColor:
//                                                   Colors.transparent,
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

//                 // 3. ERROR LAYER
//                 if (_hasPlaybackError && !_loadingVisible)
//                   Container(
//                     color: Colors.black87,
//                     child: Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(Icons.error_outline,
//                               color: Colors.white70, size: 50),
//                           const SizedBox(height: 10),
//                           const Text("Stream Disconnected",
//                               style: TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold)),
//                           const SizedBox(height: 15),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   const Color(0xFF9B28F8), 
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 24, vertical: 12),
//                             ),
//                             onPressed: () => _onItemTap(_focusedIndex),
//                             child: const Text("Retry",
//                                 style: TextStyle(
//                                     color: Colors.white, fontSize: 16)),
//                           )
//                         ],
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
//                       padding: EdgeInsets.only(top: screenhgt * 0.03),
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
//                       color: Colors.black.withOpacity(0.5),
//                       padding: const EdgeInsets.only(
//                           top: 20, bottom: 20, left: 20, right: 10),
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
//                 const SizedBox(width: 10),
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
//                 SizedBox(width: 10),
//               ],
//             ),

//             // --- NEECHE WALI ROW (Sirf Subtitles) ---
//             if (widget.liveStatus == false && activePlayer == 'VLC') ...[
//               const SizedBox(height: 1),
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
//             SizedBox(height: 10)
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

//   void _updateWebBounds(bool showControls) {
//     if (activePlayer != 'WEB' || webViewController == null) return;

//     final double screenwdt = MediaQuery.of(context).size.width;
//     final double screenhgt = MediaQuery.of(context).size.height;

//     final double leftPanelWidth = screenwdt * 0.13;
//     final double topTitleHeight = screenhgt * 0.10;
//     final double bottomBarHeight = screenhgt * 0.15;

//     final bool isLive = widget.liveStatus == true;

//     final double offsetLeft =
//         (isLive && showControls && widget.channelList.isNotEmpty)
//             ? leftPanelWidth
//             : 0.0;
//     final double offsetTop = (isLive && showControls) ? topTitleHeight : 0.0;
//     final double offsetBottom =
//         (isLive && showControls) ? bottomBarHeight : 0.0;

//     final double offsetRight = 0.0;

//     final int radius = (isLive && showControls) ? 24 : 0;

//     webViewController?.evaluateJavascript(
//         source:
//             "if(typeof window.setVideoBounds === 'function') window.setVideoBounds($offsetLeft, $offsetTop, $offsetRight, $offsetBottom, $radius);");
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
//           top: 0px; left: 0px; right: 0px; bottom: 0px; /* Full screen by default */
//           transition: top 0.03s ease, left 0.03s ease, right 0.03s ease, bottom 0.03s ease, border-radius 0.03s ease, box-shadow 0.03s ease;
//           overflow: hidden;
//           background: #000;
//         }
//         video {
//           width: 100%; height: 100%; /* Ye ensure karega video bahar na nikle */
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

//         window.setVideoBounds = function(l, t, r, b, rad) {
//            wrapper.style.left = l + "px";
//            wrapper.style.top = t + "px";
//            wrapper.style.right = r + "px";
//            wrapper.style.bottom = b + "px";
//            wrapper.style.borderRadius = rad + "px";
           
//            if(l === 0 && t === 0) {
//                wrapper.style.boxShadow = "none";
//            } else {
//                wrapper.style.boxShadow = "0px 0px 20px 5px rgba(0,0,0,0.5)";
//            }
//         };

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
//     """;
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

//       _updateWebBounds(true);

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

//         _updateWebBounds(false);

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
//       return "${cNo.trim()} $name";
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
//       final oldController = vlcController;
//       vlcController = null; 

//       try {
//         oldController!.removeListener(_vlcListener);
//       } catch (_) {}

//       Future.delayed(const Duration(milliseconds: 300), () async {
//         try {
//           await oldController?.stop().timeout(const Duration(seconds: 2));
//         } catch (e) {
//           print("VLC stop timed out or failed: $e");
//         }

//         try {
//           await oldController?.dispose().timeout(const Duration(seconds: 2));
//         } catch (e) {
//           print("VLC dispose timed out or failed: $e");
//         }
//       });
//     }

//     if (webViewController != null) {
//       try {
//         webViewController!.evaluateJavascript(
//             source:
//                 "var v = document.getElementById('video'); if(v) { v.pause(); v.removeAttribute('src'); v.load(); }");
//       } catch (_) {}
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
//   final FocusNode audioButtonFocusNode = FocusNode(); // 🟢 NEW: Language focus node

//   // --- Seek Variables ---
//   bool _isScrubbing = false;
//   int _accumulatedSeekForward = 0;
//   int _accumulatedSeekBackward = 0;
//   Timer? _seekTimer;
//   Duration _baseSeekPosition = Duration.zero;
//   final int _seekDuration = 10;
//   final int _seekDelay = 800;

//   // --- Track Selection Variables (Subtitles & Audio) ---
//   Map<int, String> _spuTracks = {};
//   int _currentSpuTrack = -1;
//   Map<int, String> _audioTracks = {}; // 🟢 NEW: Audio Tracks Map
//   int _currentAudioTrack = -1; // 🟢 NEW: Current Audio Track ID
//   bool _hasFetchedTracks = false; // 🟢 Consolidated fetch flag

//   // --- Network & Stall Recovery Variables ---
//   Timer? _networkCheckTimer;
//   bool _wasDisconnected = false;
//   bool _isAttemptingResume = false;
//   DateTime _lastPlayingTime = DateTime.now();
//   Duration _lastPositionCheck = Duration.zero;
//   int _stallCounter = 0;
//   bool _hasStartedPlaying = false;
//   bool _isUserPaused = false;
  
//   // 🟢 Error tracking variables
//   int _errorRetryCount = 0;
//   bool _hasPlaybackError = false;

//   // 🟢 Anti-crash cooldown and setState throttle trackers
//   DateTime _lastRecoveryAttempt =
//       DateTime.now().subtract(const Duration(seconds: 15));
//   DateTime _lastSetStateTime = DateTime.now();
//   DateTime _lastPositionUpdateTime = DateTime.now(); 

//   Map<String, Uint8List> _bannerCache = {};
//   bool _isDisposing = false;
//   final String localImage = "";
//   bool _isAppInBackground = false;

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
//         if (_bannerCache.length >= 15) {
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
//         state == AppLifecycleState.paused ||
//         state == AppLifecycleState.detached) {
//       _isAppInBackground = true;
//       if (activePlayer == 'VLC') vlcController?.pause();
//       if (activePlayer == 'WEB') {
//         webViewController?.evaluateJavascript(
//             source: "document.getElementById('video').pause();");
//       }
//     } else if (state == AppLifecycleState.resumed) {
//       _isAppInBackground = false;
//       if (!_isUserPaused) {
//         if (activePlayer == 'VLC') vlcController?.play();
//         if (activePlayer == 'WEB') {
//           webViewController?.evaluateJavascript(
//               source: "document.getElementById('video').play();");
//         }
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
//     if (_currentModifiedUrl == null || _isDisposing || _isAppInBackground)
//       return;
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

//     if (DateTime.now().difference(_lastRecoveryAttempt).inSeconds < 3) {
//       print("Recovery is on cooldown. Skipping...");
//       return;
//     }
//     _lastRecoveryAttempt = DateTime.now();

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
//       if (!mounted ||
//           _isScrubbing ||
//           _isAttemptingResume ||
//           _isDisposing ||
//           _isAppInBackground) {
//         return;
//       }

//       if (_loadingVisible && !_isUserPaused) {
//         int timeoutSeconds = widget.liveStatus == true ? 7 : 12;

//         if (DateTime.now().difference(_lastPlayingTime) > Duration(seconds: timeoutSeconds)) {
//           print("Watchdog triggered: Stuck in loading for ${timeoutSeconds}s. Forcing recovery...");
//           if (_errorRetryCount < 3) {
//             _errorRetryCount++;
//             _attemptResumeLiveStream();
//           } else {
//             setState(() {
//               _loadingVisible = false;
//               _hasPlaybackError = true;
//             });
//           }
//           _lastPlayingTime = DateTime.now();
//           return;
//         }
//       }

//       if (widget.liveStatus == true && _hasStartedPlaying && !_isUserPaused) {
//         if (_currentPosition.value == _lastPositionCheck) {
//           _stallCounter++;
//         } else {
//           _stallCounter = 0;

//           if (_loadingVisible && _hasStartedPlaying) {
//             setState(() {
//               _loadingVisible = false;
//             });
//           }
//         }

//         if (_stallCounter >= 4) {
//           print("Watchdog triggered: Video frame frozen. Forcing recovery...");
//           _attemptResumeLiveStream();
//           _stallCounter = 0;
//         }
//         _lastPositionCheck = _currentPosition.value;
//       }
//     });
//   }

//   String _buildVlcUrl(String baseUrl) {
//     final String rtspTcp = "rtsp-tcp";
//     return baseUrl.contains('?') ? '$baseUrl&$rtspTcp' : '$baseUrl?$rtspTcp';
//   }

//   Future<void> _initVlcPlayer(String baseUrl) async {
//     if (_isDisposing) return;

//     if (vlcController != null) {
//       final oldController = vlcController;
//       vlcController = null;

//       try {
//         oldController!.removeListener(_vlcListener);
//       } catch (_) {}

//       Future.delayed(const Duration(milliseconds: 100), () async {
//         try {
//           await oldController?.stop().timeout(const Duration(seconds: 2));
//         } catch (_) {}
//         try {
//           await oldController?.dispose().timeout(const Duration(seconds: 2));
//         } catch (_) {}
//       });
//     }

//     _lastPlayingTime = DateTime.now();
//     _stallCounter = 0;
//     _hasStartedPlaying = false;
//     _hasFetchedTracks = false;

//     if (mounted) {
//       setState(() {
//         _hasPlaybackError = false;
//       });
//     }

//     try {
//       bool isMkv = baseUrl.toLowerCase().contains('.mkv');
//       vlcController = VlcPlayerController.network(
//         _buildVlcUrl(baseUrl),
//         hwAcc: isMkv ? HwAcc.auto : HwAcc.auto,
//         autoPlay: true,
//         options: VlcPlayerOptions(
//           http: VlcHttpOptions([
//             ':http-user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
//             ':http-reconnect=true', 
//           ]),
//           video: VlcVideoOptions([
//             VlcVideoOptions.dropLateFrames(true),
//             VlcVideoOptions.skipFrames(true),
//           ]),
//           audio: VlcAudioOptions([
//             VlcAudioOptions.audioTimeStretch(true),
//           ]),
//           advanced: VlcAdvancedOptions([
//             VlcAdvancedOptions.networkCaching(2000), 
//             VlcAdvancedOptions.liveCaching(2000),
//             VlcAdvancedOptions.clockJitter(0),
//             VlcAdvancedOptions.clockSynchronization(0),
//           ]),
//         ),
//       );

//       vlcController!.addListener(_vlcListener);
//       if (mounted) setState(() {});
//     } catch (e) {
//       print("Failed to initialize VLC Player: $e");
//       if (mounted) {
//         setState(() {
//           _hasPlaybackError = true;
//           _loadingVisible = false;
//         });
//       }
//     }
//   }

//   // 🟢 NEW: Fetches both Audio and Subtitle tracks together
//   Future<void> _fetchTracks() async {
//     await Future.delayed(const Duration(seconds: 2));
//     if (vlcController != null && vlcController!.value.isInitialized) {
//       final spuTracks = await vlcController!.getSpuTracks();
//       final currentSpu = await vlcController!.getSpuTrack() ?? -1;

//       final audioTracks = await vlcController!.getAudioTracks();
//       final currentAudio = await vlcController!.getAudioTrack() ?? -1;

//       if (mounted) {
//         setState(() {
//           _spuTracks = spuTracks;
//           _currentSpuTrack = currentSpu;
//           _audioTracks = audioTracks;
//           _currentAudioTrack = currentAudio;
//           _hasFetchedTracks = true;
//         });
//       }
//     }
//   }

//   void _vlcListener() {
//     if (!mounted || vlcController == null || _isDisposing) return;
    
//     final value = vlcController!.value;
//     final PlayingState playingState = value.playingState;
//     final now = DateTime.now();

//     if (now.difference(_lastPositionUpdateTime).inMilliseconds > 250) {
//       _currentPosition.value = value.position;
//       _totalDuration.value = value.duration;
//       _lastPositionUpdateTime = now;
//     }

//     if (widget.liveStatus == true && !_isAttemptingResume) {
//       if (playingState == PlayingState.playing) {
//         _lastPlayingTime = DateTime.now();
//         if (!_hasStartedPlaying) _hasStartedPlaying = true;
        
//         if (_errorRetryCount > 0 || _hasPlaybackError) {
//           setState(() {
//             _errorRetryCount = 0;
//             _hasPlaybackError = false;
//           });
//         }
//       } else if (playingState == PlayingState.buffering && _hasStartedPlaying) {
//         if (DateTime.now().difference(_lastPlayingTime) > const Duration(seconds: 8)) {
//           _attemptResumeLiveStream();
//         }
//       } else if (playingState == PlayingState.error) {
//         if (_errorRetryCount < 3) {
//           _errorRetryCount++;
//           Future.delayed(const Duration(seconds: 3), () {
//             if (mounted && !_isDisposing) _attemptResumeLiveStream();
//           });
//         } else {
//           if (mounted && !_hasPlaybackError) { 
//             setState(() {
//               _isAttemptingResume = false;
//               _loadingVisible = false;
//               _hasPlaybackError = true;
//             });
//           }
//         }
//       } else if ((playingState == PlayingState.stopped || playingState == PlayingState.ended) && _hasStartedPlaying) {
//         if (DateTime.now().difference(_lastPlayingTime) > const Duration(seconds: 5)) {
//           _attemptResumeLiveStream();
//         }
//       }
//     } else if (playingState == PlayingState.paused) {
//        if (_isUserPaused) {
//          _lastPlayingTime = DateTime.now();
//        }
//     } else if (playingState == PlayingState.playing && widget.liveStatus == false) {
//       // 🟢 Update condition to use _hasFetchedTracks
//       if (!_hasFetchedTracks) _fetchTracks();
//     }

//     bool newIsPlaying = value.isPlaying;
//     bool newIsBuffering = value.isBuffering;
//     bool newIsVideoInitialized = value.isInitialized;
    
//     bool newLoadingVisible = newIsBuffering || playingState == PlayingState.initializing || _isAttemptingResume;
//     if (playingState == PlayingState.playing) {
//       newLoadingVisible = false;
//     }

//     bool needsRebuild = false;

//     if (_isPlaying != newIsPlaying) {
//       _isPlaying = newIsPlaying;
//       needsRebuild = true;
//     }
//     if (_isBuffering != newIsBuffering) {
//       _isBuffering = newIsBuffering;
//       needsRebuild = true;
//     }
//     if (!_isVideoInitialized && newIsVideoInitialized) {
//       _isVideoInitialized = true;
//       needsRebuild = true;
//     }
//     if (_loadingVisible != newLoadingVisible) {
//       _loadingVisible = newLoadingVisible;
//       needsRebuild = true;
//     }

//     if (needsRebuild && mounted) {
//       if (now.difference(_lastSetStateTime).inMilliseconds > 250) {
//         setState(() {});
//         _lastSetStateTime = now;
//       }
//     }
//   }

//   Future<void> _switchPlayerSafely(
//       String targetPlayerType, String secureUrl) async {
//     if (_isDisposing) return;

//     _seekTimer?.cancel();
//     _networkCheckTimer?.cancel();

//     setState(() {
//       _loadingVisible = true;
//       _isVideoInitialized = false;
//       _hasPlaybackError = false;
      
//       if (targetPlayerType != 'WEB') {
//         activePlayer = 'NONE';
//       }
//     });

//     if (activePlayer == 'VLC' && vlcController != null) {
//       final oldController = vlcController;
//       vlcController = null;

//       try {
//         oldController!.removeListener(_vlcListener);
//       } catch (_) {}

//       Future.delayed(const Duration(milliseconds: 100), () async {
//         try {
//           await oldController?.stop().timeout(const Duration(seconds: 2));
//         } catch (e) {
//           print("Handled VLC stop error during switch: $e");
//         }
//         try {
//           await oldController?.dispose().timeout(const Duration(seconds: 2));
//         } catch (e) {
//           print("Handled VLC dispose error during switch: $e");
//         }
//       });
//     }
//     webViewController = null;

//     setState(() {
//       activePlayer = 'NONE';
//     });

//     await Future.delayed(const Duration(milliseconds: 1500));
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
//       _errorRetryCount = 0;
//       _hasPlaybackError = false;
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
//                 !subtitleButtonFocusNode.hasFocus &&
//                 !audioButtonFocusNode.hasFocus) {
//               if (_focusedIndex > 0) _changeFocusAndScroll(_focusedIndex - 1);
//             }
//             return true;
//           }
//           // 🟢 Modified Up arrow handling for new row logic
//           if (subtitleButtonFocusNode.hasFocus || audioButtonFocusNode.hasFocus) {
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
//                 !subtitleButtonFocusNode.hasFocus &&
//                 !audioButtonFocusNode.hasFocus) {
//               if (_focusedIndex < widget.channelList.length - 1) {
//                 _changeFocusAndScroll(_focusedIndex + 1);
//               }
//             }
//             return true;
//           }
//           // 🟢 Modified Down arrow handling to focus language button first
//           if (playPauseButtonFocusNode.hasFocus &&
//               widget.liveStatus == false &&
//               activePlayer == 'VLC') {
//             FocusScope.of(context).requestFocus(audioButtonFocusNode);
//           } else if (_focusedIndex < widget.channelList.length - 1 && !subtitleButtonFocusNode.hasFocus && !audioButtonFocusNode.hasFocus) {
//             _changeFocusAndScroll(_focusedIndex + 1);
//           }
//           return true;

//         case LogicalKeyboardKey.arrowRight:
//           // 🟢 Audio button -> Subtitle button
//           if (audioButtonFocusNode.hasFocus) {
//             FocusScope.of(context).requestFocus(subtitleButtonFocusNode);
//             return true;
//           }
//           if (widget.liveStatus == false && !subtitleButtonFocusNode.hasFocus && !audioButtonFocusNode.hasFocus) {
//             _seekForward();
//           }
//           return true;

//         case LogicalKeyboardKey.arrowLeft:
//           // 🟢 Subtitle button -> Audio button
//           if (subtitleButtonFocusNode.hasFocus) {
//             FocusScope.of(context).requestFocus(audioButtonFocusNode);
//             return true;
//           }
//           if (widget.liveStatus == false && !audioButtonFocusNode.hasFocus && !subtitleButtonFocusNode.hasFocus) {
//             _seekBackward();
//           }
//           if (playPauseButtonFocusNode.hasFocus &&
//               widget.channelList.isNotEmpty) {
//             FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//           }
//           return true;

//         case LogicalKeyboardKey.select:
//         case LogicalKeyboardKey.enter:
//         case LogicalKeyboardKey.mediaPlayPause:
//           if (event is KeyRepeatEvent) return true;
//           // 🟢 Handle actions for both Subtitle and Audio button presses
//           if (subtitleButtonFocusNode.hasFocus) {
//             _showSubtitleMenu();
//             return true;
//           }
//           if (audioButtonFocusNode.hasFocus) {
//             _showAudioMenu();
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

//     setState(() {
//       _loadingVisible = true;
//     });

//     try {
//       if (activePlayer == 'WEB' && webViewController != null) {
//         double seconds = position.inMilliseconds / 1000.0;
//         await webViewController!.evaluateJavascript(
//             source:
//                 "document.getElementById('video').currentTime = $seconds; document.getElementById('video').play();");
//       } else if (activePlayer == 'VLC' && vlcController != null) {
        
//         bool wasPlaying = vlcController!.value.isPlaying;
        
//         if (wasPlaying) {
//           await vlcController!.pause();
//         }
        
//         await vlcController!.seekTo(position);
        
//         await Future.delayed(const Duration(milliseconds: 400));
        
//         if (wasPlaying) {
//           await vlcController!.play();
//         }
//       }
//     } catch (e) {
//       print("Error during seek: $e");
//     } finally {
//       await Future.delayed(const Duration(milliseconds: 500));
//       if (mounted) {
//         setState(() {
//           _isSeeking = false;
//           _loadingVisible = false;
//         });
//       }
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

//   // 🟢 NEW: Audio / Language Menu Logic
//   void _showAudioMenu() {
//     _hideControlsTimer?.cancel();

//     showDialog(
//         context: context,
//         builder: (context) {
//           final size = MediaQuery.of(context).size;
          
//           final List<MapEntry<int, String>> tracksList = _audioTracks.entries.toList();
          
//           int focusedIndex = tracksList.indexWhere((entry) => entry.key == _currentAudioTrack);
//           if (focusedIndex == -1) focusedIndex = 0;

//           final ScrollController dialogScrollController = ScrollController();

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
//                             child: Text("Select Audio/Language",
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16)),
//                           ),
//                         ),
//                         const Divider(color: Colors.white24, height: 1),
//                         Expanded(
//                           child: _audioTracks.isEmpty
//                               ? const Padding(
//                                   padding: EdgeInsets.all(16.0),
//                                   child: Text("No audio tracks available",
//                                       style: TextStyle(color: Colors.white70)),
//                                 )
//                               : ListView.builder(
//                                   controller: dialogScrollController,
//                                   padding: EdgeInsets.zero,
//                                   itemCount: tracksList.length,
//                                   itemBuilder: (context, index) {
//                                     final trackId = tracksList[index].key;
//                                     final trackName = tracksList[index].value;

//                                     final isSelected = _currentAudioTrack == trackId;
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
//                                           vlcController?.setAudioTrack(trackId);
//                                           setState(() {
//                                             _currentAudioTrack = trackId;
//                                           });
//                                           Navigator.pop(context);
//                                           return KeyEventResult.handled;
//                                         }
//                                         return KeyEventResult.ignored;
//                                       },
//                                       child: GestureDetector(
//                                         onTap: () {
//                                           vlcController?.setAudioTrack(trackId);
//                                           setState(() {
//                                             _currentAudioTrack = trackId;
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
//       FocusScope.of(context).requestFocus(audioButtonFocusNode);
//       _resetHideControlsTimer();
//     });
//   }

//   // --- Subtitle Menu Logic ---
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
//     final double leftPanelWidth = screenwdt * 0.13;

//     final double targetScale =
//         (_controlsVisible && widget.channelList.isNotEmpty) ? 0.8 : 1.0;

//     final bool isLive = widget.liveStatus == true;

//     final double offsetLeft = 0.0;
//     const double fixedRight = 0.0;
//     final double offsetTop = 0.0;
//     final double offsetBottom = 0.0;

//     return PopScope(
//       canPop: false, 
//       onPopInvokedWithResult: (bool didPop, dynamic result) async {
//         if (didPop) return;

//         _isDisposing = true;
//         _hideControlsTimer?.cancel();
//         _networkCheckTimer?.cancel();
//         _seekTimer?.cancel();

//         if (activePlayer == 'VLC' && vlcController != null) {
//           try {
//             vlcController!.removeListener(_vlcListener);
//             await vlcController!.stop(); 
//           } catch (e) {
//             print("VLC stop error during pop: $e");
//           }
//         } 
//         else if (activePlayer == 'WEB' && webViewController != null) {
//           try {
//             await webViewController!.evaluateJavascript(
//                 source: "var v = document.getElementById('video'); if(v) { v.pause(); v.removeAttribute('src'); v.load(); }");
//           } catch (_) {}
//         }

//         if (mounted) {
//           Navigator.of(context).pop();
//         }
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
//                 // 1. VIDEO LAYER 
//                 Positioned.fill(
//                   child: Stack(
//                     children: [
//                       // WEB PLAYER
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
//                           duration: const Duration(milliseconds: 3),
//                           curve: Curves.linear,
//                           left: offsetLeft,
//                           top: offsetTop,
//                           right: fixedRight,
//                           bottom: offsetBottom,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.black,
//                               borderRadius: BorderRadius.circular(0.0),
//                               boxShadow: [],
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(0.0),
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
//                                         child: VlcPlayer(
//                                           key: const ValueKey('VLC_PLAYER'),
//                                           controller: vlcController!,
//                                           aspectRatio: videoRatio,
//                                           placeholder: const Center(
//                                             child: RainbowPage(
//                                               backgroundColor:
//                                                   Colors.transparent,
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

//                 // 3. ERROR LAYER
//                 if (_hasPlaybackError && !_loadingVisible)
//                   Container(
//                     color: Colors.black87,
//                     child: Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(Icons.error_outline,
//                               color: Colors.white70, size: 50),
//                           const SizedBox(height: 10),
//                           const Text("Stream Disconnected",
//                               style: TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold)),
//                           const SizedBox(height: 15),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   const Color(0xFF9B28F8), 
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 24, vertical: 12),
//                             ),
//                             onPressed: () => _onItemTap(_focusedIndex),
//                             child: const Text("Retry",
//                                 style: TextStyle(
//                                     color: Colors.white, fontSize: 16)),
//                           )
//                         ],
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
//                       padding: EdgeInsets.only(top: screenhgt * 0.03),
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
//                       color: Colors.black.withOpacity(0.5),
//                       padding: const EdgeInsets.only(
//                           top: 20, bottom: 20, left: 20, right: 10),
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
//                                               !subtitleButtonFocusNode.hasFocus &&
//                                               !audioButtonFocusNode.hasFocus
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
//                 const SizedBox(width: 10),
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
//                             scale: 1.2,
//                             child: Image.asset(
//                               _isPlaying
//                                   ? 'assets/pause.png'
//                                   : 'assets/play.png',
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) =>
//                                   Icon(
//                                 _isPlaying ? Icons.pause : Icons.play_arrow,
//                                 color: Colors.white,
//                                 size: 20,
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
//                 SizedBox(width: 10),
//               ],
//             ),

//             // --- NEECHE WALI ROW (Language aur Subtitles) ---
//             if (widget.liveStatus == false && activePlayer == 'VLC') ...[
//               const SizedBox(height: 1),
//               Row(
//                 children: [
//                   // 🟢 NEW: Language/Audio Button
//                   Container(
//                     decoration: BoxDecoration(
//                       color: audioButtonFocusNode.hasFocus
//                           ? const Color.fromARGB(200, 16, 62, 99)
//                           : Colors.transparent,
//                       borderRadius: BorderRadius.circular(6),
//                       border: Border.all(
//                           color: audioButtonFocusNode.hasFocus
//                               ? Colors.purple
//                               : Colors.transparent,
//                           width: 2),
//                     ),
//                     child: Focus(
//                       focusNode: audioButtonFocusNode,
//                       onFocusChange: (hasFocus) => setState(() {}),
//                       child: InkWell(
//                         onTap: _showAudioMenu,
//                         child: const Padding(
//                           padding:
//                               EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(Icons.audiotrack, color: Colors.white, size: 18),
//                               SizedBox(width: 4),
//                               Text("Language",
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 14)),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 15), // Gap between Language and Subtitle
                  
//                   // 🟢 EXISTING: Subtitle Button
//                   Container(
//                     decoration: BoxDecoration(
//                       color: subtitleButtonFocusNode.hasFocus
//                           ? const Color.fromARGB(200, 16, 62, 99)
//                           : Colors.transparent,
//                       borderRadius: BorderRadius.circular(6),
//                       border: Border.all(
//                           color: subtitleButtonFocusNode.hasFocus
//                               ? Colors.purple
//                               : Colors.transparent,
//                           width: 2),
//                     ),
//                     child: Focus(
//                       focusNode: subtitleButtonFocusNode,
//                       onFocusChange: (hasFocus) => setState(() {}),
//                       child: InkWell(
//                         onTap: _showSubtitleMenu,
//                         child: const Padding(
//                           padding:
//                               EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(Icons.subtitles, color: Colors.white, size: 18),
//                               SizedBox(width: 4),
//                               Text("Subtitles",
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 14)),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//             SizedBox(height: 10)
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

//   void _updateWebBounds(bool showControls) {
//     if (activePlayer != 'WEB' || webViewController == null) return;

//     final double screenwdt = MediaQuery.of(context).size.width;
//     final double screenhgt = MediaQuery.of(context).size.height;

//     final double leftPanelWidth = screenwdt * 0.13;
//     final double topTitleHeight = screenhgt * 0.10;
//     final double bottomBarHeight = screenhgt * 0.15;

//     final bool isLive = widget.liveStatus == true;

//     final double offsetLeft =
//         (isLive && showControls && widget.channelList.isNotEmpty)
//             ? leftPanelWidth
//             : 0.0;
//     final double offsetTop = (isLive && showControls) ? topTitleHeight : 0.0;
//     final double offsetBottom =
//         (isLive && showControls) ? bottomBarHeight : 0.0;

//     final double offsetRight = 0.0;

//     final int radius = (isLive && showControls) ? 24 : 0;

//     webViewController?.evaluateJavascript(
//         source:
//             "if(typeof window.setVideoBounds === 'function') window.setVideoBounds($offsetLeft, $offsetTop, $offsetRight, $offsetBottom, $radius);");
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
//           top: 0px; left: 0px; right: 0px; bottom: 0px; /* Full screen by default */
//           transition: top 0.03s ease, left 0.03s ease, right 0.03s ease, bottom 0.03s ease, border-radius 0.03s ease, box-shadow 0.03s ease;
//           overflow: hidden;
//           background: #000;
//         }
//         video {
//           width: 100%; height: 100%; /* Ye ensure karega video bahar na nikle */
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

//         window.setVideoBounds = function(l, t, r, b, rad) {
//            wrapper.style.left = l + "px";
//            wrapper.style.top = t + "px";
//            wrapper.style.right = r + "px";
//            wrapper.style.bottom = b + "px";
//            wrapper.style.borderRadius = rad + "px";
           
//            if(l === 0 && t === 0) {
//                wrapper.style.boxShadow = "none";
//            } else {
//                wrapper.style.boxShadow = "0px 0px 20px 5px rgba(0,0,0,0.5)";
//            }
//         };

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
//     """;
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

//       _updateWebBounds(true);

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

//         _updateWebBounds(false);

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
//       return "${cNo.trim()} $name";
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
//       final oldController = vlcController;
//       vlcController = null; 

//       try {
//         oldController!.removeListener(_vlcListener);
//       } catch (_) {}

//       Future.delayed(const Duration(milliseconds: 300), () async {
//         try {
//           await oldController?.stop().timeout(const Duration(seconds: 2));
//         } catch (e) {
//           print("VLC stop timed out or failed: $e");
//         }

//         try {
//           await oldController?.dispose().timeout(const Duration(seconds: 2));
//         } catch (e) {
//           print("VLC dispose timed out or failed: $e");
//         }
//       });
//     }

//     if (webViewController != null) {
//       try {
//         webViewController!.evaluateJavascript(
//             source:
//                 "var v = document.getElementById('video'); if(v) { v.pause(); v.removeAttribute('src'); v.load(); }");
//       } catch (_) {}
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
//     audioButtonFocusNode.dispose(); // 🟢 NEW
//     _scrollController.dispose();

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
  final FocusNode audioButtonFocusNode = FocusNode(); // 🟢 NEW: Language focus node

  // --- Seek Variables ---
  bool _isScrubbing = false;
  int _accumulatedSeekForward = 0;
  int _accumulatedSeekBackward = 0;
  Timer? _seekTimer;
  Duration _baseSeekPosition = Duration.zero;
  final int _seekDuration = 10;
  final int _seekDelay = 800;

  // --- Track Selection Variables (Subtitles & Audio) ---
  Map<int, String> _spuTracks = {};
  int _currentSpuTrack = -1;
  Map<int, String> _audioTracks = {}; // 🟢 NEW: Audio Tracks Map
  int _currentAudioTrack = -1; // 🟢 NEW: Current Audio Track ID
  bool _hasFetchedTracks = false; // 🟢 Consolidated fetch flag

  // --- Network & Stall Recovery Variables ---
  Timer? _networkCheckTimer;
  bool _wasDisconnected = false;
  bool _isAttemptingResume = false;
  DateTime _lastPlayingTime = DateTime.now();
  Duration _lastPositionCheck = Duration.zero;
  int _stallCounter = 0;
  bool _hasStartedPlaying = false;
  bool _isUserPaused = false;
  
  // 🟢 Error tracking variables
  int _errorRetryCount = 0;
  bool _hasPlaybackError = false;

  // 🟢 Anti-crash cooldown and setState throttle trackers
  DateTime _lastRecoveryAttempt =
      DateTime.now().subtract(const Duration(seconds: 15));
  DateTime _lastSetStateTime = DateTime.now();
  DateTime _lastPositionUpdateTime = DateTime.now(); 

  Map<String, Uint8List> _bannerCache = {};
  bool _isDisposing = false;
  final String localImage = "";
  bool _isAppInBackground = false;

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
        if (_bannerCache.length >= 15) {
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

  // --- NATIVE CRASH PREVENTION: HTTP PRE-CHECK ---
  Future<bool> _checkStreamValidity(String url) async {
    if (url.toLowerCase().startsWith('rtsp') || url.toLowerCase().startsWith('rtmp')) {
      return true;
    }

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4); // Fast timeout prevents UI freeze
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set(
          'User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36');

      final response = await request.close().timeout(const Duration(seconds: 5));
      
      if (response.statusCode >= 400 && response.statusCode != 403) {
        print("Stream check failed with status code: ${response.statusCode}");
        return false;
      }
      return true;
    } catch (e) {
      print("Stream is totally dead (timeout/refused): $e");
      return false; 
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
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _isAppInBackground = true;
      if (activePlayer == 'VLC') vlcController?.pause();
      if (activePlayer == 'WEB') {
        webViewController?.evaluateJavascript(
            source: "document.getElementById('video').pause();");
      }
    } else if (state == AppLifecycleState.resumed) {
      _isAppInBackground = false;
      if (!_isUserPaused) {
        if (activePlayer == 'VLC') vlcController?.play();
        if (activePlayer == 'WEB') {
          webViewController?.evaluateJavascript(
              source: "document.getElementById('video').play();");
        }
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
    if (_currentModifiedUrl == null || _isDisposing || _isAppInBackground)
      return;
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

    if (DateTime.now().difference(_lastRecoveryAttempt).inSeconds < 3) {
      print("Recovery is on cooldown. Skipping...");
      return;
    }
    _lastRecoveryAttempt = DateTime.now();

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

  void _startPositionUpdater() {
    Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted ||
          _isScrubbing ||
          _isAttemptingResume ||
          _isDisposing ||
          _isAppInBackground) {
        return;
      }

      if (_loadingVisible && !_isUserPaused) {
        int timeoutSeconds = widget.liveStatus == true ? 7 : 12;

        if (DateTime.now().difference(_lastPlayingTime) > Duration(seconds: timeoutSeconds)) {
          print("Watchdog triggered: Stuck in loading for ${timeoutSeconds}s. Forcing recovery...");
          if (_errorRetryCount < 3) {
            _errorRetryCount++;
            _attemptResumeLiveStream();
          } else {
            setState(() {
              _loadingVisible = false;
              _hasPlaybackError = true;
            });
          }
          _lastPlayingTime = DateTime.now();
          return;
        }
      }

      if (widget.liveStatus == true && _hasStartedPlaying && !_isUserPaused) {
        if (_currentPosition.value == _lastPositionCheck) {
          _stallCounter++;
        } else {
          _stallCounter = 0;

          if (_loadingVisible && _hasStartedPlaying) {
            setState(() {
              _loadingVisible = false;
            });
          }
        }

        if (_stallCounter >= 4) {
          print("Watchdog triggered: Video frame frozen. Forcing recovery...");
          _attemptResumeLiveStream();
          _stallCounter = 0;
        }
        _lastPositionCheck = _currentPosition.value;
      }
    });
  }

  String _buildVlcUrl(String baseUrl) {
    final String rtspTcp = "rtsp-tcp";
    return baseUrl.contains('?') ? '$baseUrl&$rtspTcp' : '$baseUrl?$rtspTcp';
  }

  Future<void> _initVlcPlayer(String baseUrl) async {
    if (_isDisposing) return;

    if (vlcController != null) {
      final oldController = vlcController;
      vlcController = null;

      try {
        oldController!.removeListener(_vlcListener);
      } catch (_) {}

      Future.delayed(const Duration(milliseconds: 100), () async {
        try {
          await oldController?.dispose().timeout(const Duration(seconds: 2));
        } catch (_) {}
      });
    }

    _lastPlayingTime = DateTime.now();
    _stallCounter = 0;
    _hasStartedPlaying = false;
    _hasFetchedTracks = false;

    if (mounted) {
      setState(() {
        _hasPlaybackError = false;
        _loadingVisible = true;
      });
    }

    // 🟢 CRITICAL: Check if the link is actually alive before feeding it to LibVLC
    bool isAlive = await _checkStreamValidity(baseUrl);
    
    if (!isAlive) {
      if (mounted) {
        setState(() {
          _hasPlaybackError = true;
          _loadingVisible = false;
        });
      }
      return; // Abort VLC initialization completely
    }

    try {
      bool isMkv = baseUrl.toLowerCase().contains('.mkv');
      vlcController = VlcPlayerController.network(
        _buildVlcUrl(baseUrl),
        hwAcc: isMkv ? HwAcc.auto : HwAcc.auto,
        autoPlay: true,
        options: VlcPlayerOptions(
          http: VlcHttpOptions([
            ':http-user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
            ':http-reconnect=true', 
          ]),
          video: VlcVideoOptions([
            VlcVideoOptions.dropLateFrames(true),
            VlcVideoOptions.skipFrames(true),
          ]),
          audio: VlcAudioOptions([
            VlcAudioOptions.audioTimeStretch(true),
          ]),
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.networkCaching(2000), 
            VlcAdvancedOptions.liveCaching(2000),
            VlcAdvancedOptions.clockJitter(0),
            VlcAdvancedOptions.clockSynchronization(0),
          ]),
        ),
      );

      vlcController!.addListener(_vlcListener);
      if (mounted) setState(() {});
    } catch (e) {
      print("Failed to initialize VLC Player: $e");
      if (mounted) {
        setState(() {
          _hasPlaybackError = true;
          _loadingVisible = false;
        });
      }
    }
  }

  // 🟢 NEW: Fetches both Audio and Subtitle tracks together
  Future<void> _fetchTracks() async {
    await Future.delayed(const Duration(seconds: 2));
    if (vlcController != null && vlcController!.value.isInitialized) {
      final spuTracks = await vlcController!.getSpuTracks();
      final currentSpu = await vlcController!.getSpuTrack() ?? -1;

      final audioTracks = await vlcController!.getAudioTracks();
      final currentAudio = await vlcController!.getAudioTrack() ?? -1;

      if (mounted) {
        setState(() {
          _spuTracks = spuTracks;
          _currentSpuTrack = currentSpu;
          _audioTracks = audioTracks;
          _currentAudioTrack = currentAudio;
          _hasFetchedTracks = true;
        });
      }
    }
  }

  void _vlcListener() {
    if (!mounted || vlcController == null || _isDisposing) return;
    
    final value = vlcController!.value;
    final PlayingState playingState = value.playingState;
    final now = DateTime.now();

    if (now.difference(_lastPositionUpdateTime).inMilliseconds > 250) {
      _currentPosition.value = value.position;
      _totalDuration.value = value.duration;
      _lastPositionUpdateTime = now;
    }

    if (widget.liveStatus == true && !_isAttemptingResume) {
      if (playingState == PlayingState.playing) {
        _lastPlayingTime = DateTime.now();
        if (!_hasStartedPlaying) _hasStartedPlaying = true;
        
        if (_errorRetryCount > 0 || _hasPlaybackError) {
          setState(() {
            _errorRetryCount = 0;
            _hasPlaybackError = false;
          });
        }
      } else if (playingState == PlayingState.buffering && _hasStartedPlaying) {
        if (DateTime.now().difference(_lastPlayingTime) > const Duration(seconds: 8)) {
          _attemptResumeLiveStream();
        }
      } else if (playingState == PlayingState.error) {
        if (_errorRetryCount < 3) {
          _errorRetryCount++;
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted && !_isDisposing) _attemptResumeLiveStream();
          });
        } else {
          if (mounted && !_hasPlaybackError) { 
            setState(() {
              _isAttemptingResume = false;
              _loadingVisible = false;
              _hasPlaybackError = true;
            });
            // CRITICAL FIX: DO NOT call vlcController?.stop() here. 
            // It causes a fatal native crash when the player is already in an error state.
          }
        }
      } else if ((playingState == PlayingState.stopped || playingState == PlayingState.ended) && _hasStartedPlaying) {
        if (DateTime.now().difference(_lastPlayingTime) > const Duration(seconds: 5)) {
          _attemptResumeLiveStream();
        }
      }
    } else if (playingState == PlayingState.paused) {
       if (_isUserPaused) {
         _lastPlayingTime = DateTime.now();
       }
    } else if (playingState == PlayingState.playing && widget.liveStatus == false) {
      if (!_hasFetchedTracks) _fetchTracks();
    }

    bool newIsPlaying = value.isPlaying;
    bool newIsBuffering = value.isBuffering;
    bool newIsVideoInitialized = value.isInitialized;
    
    bool newLoadingVisible = newIsBuffering || playingState == PlayingState.initializing || _isAttemptingResume;
    if (playingState == PlayingState.playing) {
      newLoadingVisible = false;
    }

    bool needsRebuild = false;

    if (_isPlaying != newIsPlaying) {
      _isPlaying = newIsPlaying;
      needsRebuild = true;
    }
    if (_isBuffering != newIsBuffering) {
      _isBuffering = newIsBuffering;
      needsRebuild = true;
    }
    if (!_isVideoInitialized && newIsVideoInitialized) {
      _isVideoInitialized = true;
      needsRebuild = true;
    }
    if (_loadingVisible != newLoadingVisible) {
      _loadingVisible = newLoadingVisible;
      needsRebuild = true;
    }

    if (needsRebuild && mounted) {
      if (now.difference(_lastSetStateTime).inMilliseconds > 250) {
        setState(() {});
        _lastSetStateTime = now;
      }
    }
  }

  Future<void> _switchPlayerSafely(
      String targetPlayerType, String secureUrl) async {
    if (_isDisposing) return;

    _seekTimer?.cancel();
    _networkCheckTimer?.cancel();

    setState(() {
      _loadingVisible = true;
      _isVideoInitialized = false;
      _hasPlaybackError = false;
      
      if (targetPlayerType != 'WEB') {
        activePlayer = 'NONE';
      }
    });

    if (activePlayer == 'VLC' && vlcController != null) {
      final oldController = vlcController;
      vlcController = null;

      try {
        oldController!.removeListener(_vlcListener);
      } catch (_) {}

      Future.delayed(const Duration(milliseconds: 100), () async {
        try {
          await oldController?.dispose().timeout(const Duration(seconds: 2));
        } catch (e) {
          print("Handled VLC dispose error during switch: $e");
        }
      });
    }
    webViewController = null;

    setState(() {
      activePlayer = 'NONE';
    });

    await Future.delayed(const Duration(milliseconds: 1500));
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
      _errorRetryCount = 0;
      _hasPlaybackError = false;
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
                !subtitleButtonFocusNode.hasFocus &&
                !audioButtonFocusNode.hasFocus) {
              if (_focusedIndex > 0) _changeFocusAndScroll(_focusedIndex - 1);
            }
            return true;
          }
          if (subtitleButtonFocusNode.hasFocus || audioButtonFocusNode.hasFocus) {
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
                !subtitleButtonFocusNode.hasFocus &&
                !audioButtonFocusNode.hasFocus) {
              if (_focusedIndex < widget.channelList.length - 1) {
                _changeFocusAndScroll(_focusedIndex + 1);
              }
            }
            return true;
          }
          if (playPauseButtonFocusNode.hasFocus &&
              widget.liveStatus == false &&
              activePlayer == 'VLC') {
            FocusScope.of(context).requestFocus(audioButtonFocusNode);
          } else if (_focusedIndex < widget.channelList.length - 1 && !subtitleButtonFocusNode.hasFocus && !audioButtonFocusNode.hasFocus) {
            _changeFocusAndScroll(_focusedIndex + 1);
          }
          return true;

        case LogicalKeyboardKey.arrowRight:
          if (audioButtonFocusNode.hasFocus) {
            FocusScope.of(context).requestFocus(subtitleButtonFocusNode);
            return true;
          }
          if (widget.liveStatus == false && !subtitleButtonFocusNode.hasFocus && !audioButtonFocusNode.hasFocus) {
            _seekForward();
          }
          return true;

        case LogicalKeyboardKey.arrowLeft:
          if (subtitleButtonFocusNode.hasFocus) {
            FocusScope.of(context).requestFocus(audioButtonFocusNode);
            return true;
          }
          if (widget.liveStatus == false && !audioButtonFocusNode.hasFocus && !subtitleButtonFocusNode.hasFocus) {
            _seekBackward();
          }
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
          if (audioButtonFocusNode.hasFocus) {
            _showAudioMenu();
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
    try {
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
    } catch (e) {
      print("Ignored play/pause error on dead stream: $e");
    }
    FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
    _resetHideControlsTimer();
  }

  Future<void> _seekToPosition(Duration position) async {
    if (_isSeeking || _isDisposing) return;
    _isSeeking = true;

    setState(() {
      _loadingVisible = true;
    });

    try {
      if (activePlayer == 'WEB' && webViewController != null) {
        double seconds = position.inMilliseconds / 1000.0;
        await webViewController!.evaluateJavascript(
            source:
                "document.getElementById('video').currentTime = $seconds; document.getElementById('video').play();");
      } else if (activePlayer == 'VLC' && vlcController != null) {
        
        bool wasPlaying = vlcController!.value.isPlaying;
        
        if (wasPlaying) {
          await vlcController!.pause();
        }
        
        await vlcController!.seekTo(position);
        
        await Future.delayed(const Duration(milliseconds: 400));
        
        if (wasPlaying) {
          await vlcController!.play();
        }
      }
    } catch (e) {
      print("Ignored seek error on dead stream: $e");
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _isSeeking = false;
          _loadingVisible = false;
        });
      }
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

  void _showAudioMenu() {
    _hideControlsTimer?.cancel();

    showDialog(
        context: context,
        builder: (context) {
          final size = MediaQuery.of(context).size;
          
          final List<MapEntry<int, String>> tracksList = _audioTracks.entries.toList();
          
          int focusedIndex = tracksList.indexWhere((entry) => entry.key == _currentAudioTrack);
          if (focusedIndex == -1) focusedIndex = 0;

          final ScrollController dialogScrollController = ScrollController();

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
                            child: Text("Select Audio/Language",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ),
                        ),
                        const Divider(color: Colors.white24, height: 1),
                        Expanded(
                          child: _audioTracks.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text("No audio tracks available",
                                      style: TextStyle(color: Colors.white70)),
                                )
                              : ListView.builder(
                                  controller: dialogScrollController,
                                  padding: EdgeInsets.zero,
                                  itemCount: tracksList.length,
                                  itemBuilder: (context, index) {
                                    final trackId = tracksList[index].key;
                                    final trackName = tracksList[index].value;

                                    final isSelected = _currentAudioTrack == trackId;
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
                                          vlcController?.setAudioTrack(trackId);
                                          setState(() {
                                            _currentAudioTrack = trackId;
                                          });
                                          Navigator.pop(context);
                                          return KeyEventResult.handled;
                                        }
                                        return KeyEventResult.ignored;
                                      },
                                      child: GestureDetector(
                                        onTap: () {
                                          vlcController?.setAudioTrack(trackId);
                                          setState(() {
                                            _currentAudioTrack = trackId;
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
      FocusScope.of(context).requestFocus(audioButtonFocusNode);
      _resetHideControlsTimer();
    });
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
    final double leftPanelWidth = screenwdt * 0.13;

    final double targetScale =
        (_controlsVisible && widget.channelList.isNotEmpty) ? 0.8 : 1.0;

    final bool isLive = widget.liveStatus == true;

    final double offsetLeft = 0.0;
    const double fixedRight = 0.0;
    final double offsetTop = 0.0;
    final double offsetBottom = 0.0;

    return PopScope(
      canPop: false, 
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        _isDisposing = true;
        _hideControlsTimer?.cancel();
        _networkCheckTimer?.cancel();
        _seekTimer?.cancel();

        if (activePlayer == 'VLC' && vlcController != null) {
          try {
            vlcController!.removeListener(_vlcListener);
            // Removed stop() to prevent native SIGSEGV on back button
          } catch (e) {
            print("VLC error during pop: $e");
          }
        } 
        else if (activePlayer == 'WEB' && webViewController != null) {
          try {
            await webViewController!.evaluateJavascript(
                source: "var v = document.getElementById('video'); if(v) { v.pause(); v.removeAttribute('src'); v.load(); }");
          } catch (_) {}
        }

        if (mounted) {
          Navigator.of(context).pop();
        }
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
                // 1. VIDEO LAYER 
                Positioned.fill(
                  child: Stack(
                    children: [
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
                                      if (!mounted ||
                                          _isDisposing ||
                                          args.isEmpty) return;
                                      var state = args[0];

                                      _currentPosition.value = Duration(
                                          milliseconds:
                                              state['position'].toInt());
                                      _totalDuration.value = Duration(
                                          milliseconds:
                                              state['duration'].toInt());

                                      bool newIsPlaying = state['isPlaying'];
                                      bool newIsBuffering =
                                          state['isBuffering'];
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

                                      if (_loadingVisible !=
                                          newLoadingVisible) {
                                        _loadingVisible = newLoadingVisible;
                                        needsRebuild = true;
                                      }

                                      if (needsRebuild && mounted)
                                        setState(() {});
                                    });
                              },
                            ),
                          ),
                        ),

                      if (activePlayer == 'VLC' && vlcController != null)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 3),
                          curve: Curves.linear,
                          left: offsetLeft,
                          top: offsetTop,
                          right: fixedRight,
                          bottom: offsetBottom,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(0.0),
                              boxShadow: [],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(0.0),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final screenWidth = constraints.maxWidth;
                                  final screenHeight = constraints.maxHeight;

                                  double videoWidth = 16.0;
                                  double videoHeight = 9.0;

                                  try {
                                    if (vlcController != null && vlcController!.value.isInitialized) {
                                      videoWidth = vlcController!.value.size.width;
                                      videoHeight = vlcController!.value.size.height;
                                    }
                                  } catch (_) {}

                                  if (videoWidth <= 0 || videoHeight <= 0 || videoWidth.isNaN || videoHeight.isNaN) {
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
                                        child: VlcPlayer(
                                          key: const ValueKey('VLC_PLAYER'),
                                          controller: vlcController!,
                                          aspectRatio: videoRatio,
                                          placeholder: const Center(
                                            child: RainbowPage(
                                              backgroundColor:
                                                  Colors.transparent,
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

                // 3. ERROR LAYER
                if (_hasPlaybackError && !_loadingVisible)
                  Container(
                    color: Colors.black87,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.white70, size: 50),
                          const SizedBox(height: 10),
                          const Text("Stream Disconnected",
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF9B28F8), 
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            onPressed: () => _onItemTap(_focusedIndex),
                            child: const Text("Retry",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          )
                        ],
                      ),
                    ),
                  ),

                // 3. TITLE LAYER
                if (_controlsVisible)
                  Positioned(
                    top: 0,
                    left: widget.channelList.isNotEmpty ? leftPanelWidth : 0.0,
                    right: 0,
                    height: topTitleHeight,
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      padding: EdgeInsets.only(top: screenhgt * 0.03),
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
                      color: Colors.black.withOpacity(0.5),
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
                                              !subtitleButtonFocusNode.hasFocus &&
                                              !audioButtonFocusNode.hasFocus
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
                                                    fit: BoxFit.fill)
                                                : CachedNetworkImage(
                                                    imageUrl: channel.banner ??
                                                        localImage,
                                                    fit: BoxFit.fill,
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
      bottom: 0,
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
                const SizedBox(width: 10),
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
                            scale: 1.2,
                            child: Image.asset(
                              _isPlaying
                                  ? 'assets/pause.png'
                                  : 'assets/play.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 20,
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

            // --- NEECHE WALI ROW (Language aur Subtitles) ---
            if (widget.liveStatus == false && activePlayer == 'VLC') ...[
              const SizedBox(height: 1),
              Row(
                children: [
                  // 🟢 NEW: Language/Audio Button
                  Container(
                    decoration: BoxDecoration(
                      color: audioButtonFocusNode.hasFocus
                          ? const Color.fromARGB(200, 16, 62, 99)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: audioButtonFocusNode.hasFocus
                              ? Colors.purple
                              : Colors.transparent,
                          width: 2),
                    ),
                    child: Focus(
                      focusNode: audioButtonFocusNode,
                      onFocusChange: (hasFocus) => setState(() {}),
                      child: InkWell(
                        onTap: _showAudioMenu,
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.audiotrack, color: Colors.white, size: 18),
                              SizedBox(width: 4),
                              Text("Language",
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
                  const SizedBox(width: 15), // Gap between Language and Subtitle
                  
                  // 🟢 EXISTING: Subtitle Button
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
              ),
            ],
            SizedBox(height: 10)
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

  void _updateWebBounds(bool showControls) {
    if (activePlayer != 'WEB' || webViewController == null) return;

    final double screenwdt = MediaQuery.of(context).size.width;
    final double screenhgt = MediaQuery.of(context).size.height;

    final double leftPanelWidth = screenwdt * 0.13;
    final double topTitleHeight = screenhgt * 0.10;
    final double bottomBarHeight = screenhgt * 0.15;

    final bool isLive = widget.liveStatus == true;

    final double offsetLeft =
        (isLive && showControls && widget.channelList.isNotEmpty)
            ? leftPanelWidth
            : 0.0;
    final double offsetTop = (isLive && showControls) ? topTitleHeight : 0.0;
    final double offsetBottom =
        (isLive && showControls) ? bottomBarHeight : 0.0;

    final double offsetRight = 0.0;

    final int radius = (isLive && showControls) ? 24 : 0;

    webViewController?.evaluateJavascript(
        source:
            "if(typeof window.setVideoBounds === 'function') window.setVideoBounds($offsetLeft, $offsetTop, $offsetRight, $offsetBottom, $radius);");
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
          transition: top 0.03s ease, left 0.03s ease, right 0.03s ease, bottom 0.03s ease, border-radius 0.03s ease, box-shadow 0.03s ease;
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

  void _resetHideControlsTimer() {
    _hideControlsTimer?.cancel();
    if (_isDisposing) return;

    if (!_controlsVisible) {
      setState(() {
        _controlsVisible = true;
      });

      _updateWebBounds(true);

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

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    if (_isDisposing) return;
    _hideControlsTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && !_isDisposing) {
        setState(() {
          _controlsVisible = false;
        });

        _updateWebBounds(false);

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
      final oldController = vlcController;
      vlcController = null; 

      try {
        oldController!.removeListener(_vlcListener);
      } catch (_) {}

      Future.delayed(const Duration(milliseconds: 200), () async {
        try {
          await oldController?.dispose().timeout(const Duration(seconds: 2));
        } catch (e) {
          print("VLC dispose safely handled on exit: $e");
        }
      });
    }

    if (webViewController != null) {
      try {
        webViewController!.evaluateJavascript(
            source:
                "var v = document.getElementById('video'); if(v) { v.pause(); v.removeAttribute('src'); v.load(); }");
      } catch (_) {}
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
    audioButtonFocusNode.dispose(); // 🟢 NEW
    _scrollController.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}







