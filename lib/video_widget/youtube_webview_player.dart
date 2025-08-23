// // Enhanced WebView Player with Complete TV Remote Control
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:flutter/services.dart';

// class YoutubeWebviewPlayer extends StatefulWidget {
//   final String youtubeId;
//   final bool enableRepeat;
  
//   const YoutubeWebviewPlayer({
//     Key? key, 
//     required this.youtubeId,
//     this.enableRepeat = false,
//   }) : super(key: key);

//   @override
//   _YoutubeWebviewPlayerState createState() => _YoutubeWebviewPlayerState();
// }

// class _YoutubeWebviewPlayerState extends State<YoutubeWebviewPlayer> {
//   late final WebViewController controller;
//   bool isMuted = false;
//   double volume = 0.5;

//   @override
//   void initState() {
//     super.initState();
//     _initializePlayer();
//   }

//   void _initializePlayer() {
//     String customHtml = _buildEnhancedPlayerHtml();
    
//     controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(NavigationDelegate(
//         onPageFinished: (String url) {
//           _setupRemoteControls();
//           if (widget.enableRepeat) {
//             _injectRepeatScript();
//           }
//         },
//       ))
//       ..loadHtmlString(customHtml);
//   }

//   String _buildEnhancedPlayerHtml() {
//     return '''
//     <!DOCTYPE html>
//     <html>
//     <head>
//         <meta name="viewport" content="width=device-width, initial-scale=1.0">
//         <style>
//             body { 
//                 margin: 0; 
//                 padding: 0; 
//                 background: #000; 
//                 font-family: Arial, sans-serif;
//             }
            
//             #video-container { 
//                 width: 100vw; 
//                 height: 100vh; 
//                 display: flex;
//                 align-items: center;
//                 justify-content: center;
//                 position: relative;
//             }
            
//             iframe { 
//                 width: 100%; 
//                 height: 100%; 
//                 border: none;
//             }
            
//             #remote-info {
//                 position: absolute;
//                 top: 20px;
//                 right: 20px;
//                 background: rgba(0,0,0,0.8);
//                 color: white;
//                 padding: 10px;
//                 border-radius: 5px;
//                 font-size: 12px;
//                 z-index: 1000;
//                 display: block;
//             }
            
//             #volume-indicator {
//                 position: absolute;
//                 bottom: 20px;
//                 left: 20px;
//                 background: rgba(0,0,0,0.8);
//                 color: white;
//                 padding: 10px;
//                 border-radius: 5px;
//                 font-size: 14px;
//                 z-index: 1000;
//                 display: none;
//             }
//         </style>
//     </head>
//     <body>
//         <div id="video-container">
//             <div id="remote-info">
//                 TV Remote Controls:<br>
//                 🔇 M = Mute/Unmute<br>
//                 🔊 ↑/↓ = Volume<br>
//                 ⏯️ Space = Play/Pause<br>
//                 ⏪ ← = -10s<br>
//                 ⏩ → = +10s<br>
//                 🔀 R = Repeat Toggle
//             </div>
            
//             <div id="volume-indicator">
//                 Volume: <span id="volume-level">50</span>%
//                 <span id="mute-status"></span>
//             </div>
            
//             <iframe 
//                 id="video-iframe"
//                 src="https://demo.coretechinfo.com/videojs.youtube-8.11.8-manbir-2/demo/player.php?youtubeId=${widget.youtubeId}" 
//                 allowfullscreen>
//             </iframe>
//         </div>
        
//         <script>
//             let currentVolume = 50;
//             let isMuted = false;
//             let repeatEnabled = ${widget.enableRepeat};
            
//             const volumeIndicator = document.getElementById('volume-indicator');
//             const volumeLevel = document.getElementById('volume-level');
//             const muteStatus = document.getElementById('mute-status');
//             const iframe = document.getElementById('video-iframe');
            
//             // Show volume indicator temporarily
//             function showVolumeIndicator() {
//                 volumeIndicator.style.display = 'block';
//                 setTimeout(() => {
//                     volumeIndicator.style.display = 'none';
//                 }, 2000);
//             }
            
//             // Update volume display
//             function updateVolumeDisplay() {
//                 volumeLevel.textContent = currentVolume;
//                 muteStatus.textContent = isMuted ? ' (MUTED)' : '';
//                 showVolumeIndicator();
//             }
            
//             // Send commands to iframe
//             function sendPlayerCommand(command, value = null) {
//                 try {
//                     iframe.contentWindow.postMessage({
//                         type: 'playerCommand',
//                         command: command,
//                         value: value
//                     }, '*');
//                 } catch (e) {
//                     console.log('Cross-origin message failed:', e);
//                 }
//             }
            
//             // TV Remote Key Handler - Always enabled
//             document.addEventListener('keydown', function(event) {
//                 console.log('Key pressed:', event.key, event.keyCode);
                
//                 switch(event.key.toLowerCase()) {
//                     case 'm': // Mute/Unmute
//                         isMuted = !isMuted;
//                         sendPlayerCommand('mute', isMuted);
//                         updateVolumeDisplay();
//                         event.preventDefault();
//                         break;
                        
//                     case 'arrowup': // Volume Up
//                         if (currentVolume < 100) {
//                             currentVolume = Math.min(100, currentVolume + 10);
//                             sendPlayerCommand('volume', currentVolume / 100);
//                             updateVolumeDisplay();
//                         }
//                         event.preventDefault();
//                         break;
                        
//                     case 'arrowdown': // Volume Down
//                         if (currentVolume > 0) {
//                             currentVolume = Math.max(0, currentVolume - 10);
//                             sendPlayerCommand('volume', currentVolume / 100);
//                             updateVolumeDisplay();
//                         }
//                         event.preventDefault();
//                         break;
                        
//                     case ' ': // Play/Pause
//                     case 'enter':
//                         sendPlayerCommand('playPause');
//                         event.preventDefault();
//                         break;
                        
//                     case 'arrowleft': // Seek backward
//                         sendPlayerCommand('seek', -10);
//                         event.preventDefault();
//                         break;
                        
//                     case 'arrowright': // Seek forward
//                         sendPlayerCommand('seek', 10);
//                         event.preventDefault();
//                         break;
                        
//                     case 'r': // Toggle repeat
//                         repeatEnabled = !repeatEnabled;
//                         sendPlayerCommand('repeat', repeatEnabled);
//                         event.preventDefault();
//                         break;
                        
//                     case 'f': // Fullscreen
//                         sendPlayerCommand('fullscreen');
//                         event.preventDefault();
//                         break;
//                 }
//             });
            
//             // Listen for player state updates
//             window.addEventListener('message', function(event) {
//                 if (event.data.type === 'playerState') {
//                     // Handle player state changes
//                     console.log('Player state:', event.data);
//                 }
                
//                 if (event.data.type === 'videoEnded' && repeatEnabled) {
//                     // Restart video
//                     iframe.src = iframe.src;
//                 }
//             });
            
//             // Initialize player communication
//             iframe.onload = function() {
//                 setTimeout(() => {
//                     sendPlayerCommand('init', {
//                         volume: currentVolume / 100,
//                         muted: isMuted,
//                         repeat: repeatEnabled
//                     });
//                 }, 1000);
//             };
//         </script>
//     </body>
//     </html>
//     ''';
//   }

//   void _setupRemoteControls() {
//     controller.runJavaScript('''
//       // Enhanced player control integration
//       setTimeout(function() {
//         // Try to access video.js player if available
//         if (typeof player !== 'undefined') {
//           console.log('Video.js player found');
          
//           // Listen for video events
//           player.on('ended', function() {
//             window.parent.postMessage({
//               type: 'videoEnded'
//             }, '*');
//           });
          
//           player.on('volumechange', function() {
//             window.parent.postMessage({
//               type: 'playerState',
//               volume: player.volume(),
//               muted: player.muted()
//             }, '*');
//           });
          
//           // Handle remote commands
//           window.addEventListener('message', function(event) {
//             if (event.data.type === 'playerCommand') {
//               const cmd = event.data.command;
//               const value = event.data.value;
              
//               switch(cmd) {
//                 case 'mute':
//                   player.muted(value);
//                   break;
//                 case 'volume':
//                   player.volume(value);
//                   player.muted(false); // Unmute when changing volume
//                   break;
//                 case 'playPause':
//                   if (player.paused()) {
//                     player.play();
//                   } else {
//                     player.pause();
//                   }
//                   break;
//                 case 'seek':
//                   player.currentTime(player.currentTime() + value);
//                   break;
//                 case 'repeat':
//                   // Store repeat state for handling
//                   player.repeat = value;
//                   break;
//                 case 'fullscreen':
//                   if (player.isFullscreen()) {
//                     player.exitFullscreen();
//                   } else {
//                     player.requestFullscreen();
//                   }
//                   break;
//                 case 'init':
//                   player.volume(value.volume);
//                   player.muted(value.muted);
//                   break;
//               }
//             }
//           });
//         }
//       }, 2000);
//     ''');
//   }

//   void _injectRepeatScript() {
//     controller.runJavaScript('''
//       // Repeat functionality
//       function setupRepeat() {
//         if (typeof player !== 'undefined') {
//           player.on('ended', function() {
//             if (player.repeat) {
//               player.currentTime(0);
//               player.play();
//             }
//           });
//         }
//       }
//       setTimeout(setupRepeat, 2500);
//     ''');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: RawKeyboardListener(
//         focusNode: FocusNode()..requestFocus(),
//         autofocus: true,
//         onKey: (RawKeyEvent event) {
//           if (event is RawKeyDownEvent) {
//             // Handle Flutter-level key events for additional control
//             switch (event.logicalKey) {
//               case LogicalKeyboardKey.arrowUp:
//                 _adjustVolume(10);
//                 break;
//               case LogicalKeyboardKey.arrowDown:
//                 _adjustVolume(-10);
//                 break;
//               case LogicalKeyboardKey.keyM:
//                 _toggleMute();
//                 break;
//             }
//           }
//         },
//         child: SafeArea(
//           child: WebViewWidget(controller: controller),
//         ),
//       ),
//     );
//   }

//   void _adjustVolume(int delta) {
//     setState(() {
//       volume = (volume + delta / 100).clamp(0.0, 1.0);
//     });
    
//     controller.runJavaScript('''
//       if (typeof player !== 'undefined') {
//         player.volume($volume);
//         if ($volume > 0) player.muted(false);
//       }
//     ''');
//   }

//   void _toggleMute() {
//     setState(() {
//       isMuted = !isMuted;
//     });
    
//     controller.runJavaScript('''
//       if (typeof player !== 'undefined') {
//         player.muted($isMuted);
//       }
//     ''');
//   }
// }

// // Usage Example Widget
// class RemoteControlDemo extends StatefulWidget {
//   @override
//   _RemoteControlDemoState createState() => _RemoteControlDemoState();
// }

// class _RemoteControlDemoState extends State<RemoteControlDemo> {
//   String selectedVideoId = '_j-kg-V7PgI';
//   bool enableRepeat = false;

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'TV Remote YouTube Player',
//       theme: ThemeData.dark(),
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('TV Remote Control YouTube Player'),
//           backgroundColor: Colors.black87,
//           actions: [
//             IconButton(
//               icon: Icon(enableRepeat ? Icons.repeat : Icons.repeat_outlined),
//               onPressed: () {
//                 setState(() {
//                   enableRepeat = !enableRepeat;
//                 });
//               },
//               tooltip: 'Toggle Repeat',
//             ),
//           ],
//         ),
//         body: Column(
//           children: [
//             // Control Status
//             Container(
//               padding: EdgeInsets.all(16),
//               color: Colors.grey[900],
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Column(
//                     children: [
//                       Icon(
//                         Icons.settings_remote,
//                         color: Colors.green,
//                       ),
//                       Text(
//                         'Remote: ALWAYS ON',
//                         style: TextStyle(
//                           color: Colors.green,
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     children: [
//                       Icon(
//                         enableRepeat ? Icons.repeat : Icons.repeat_outlined,
//                         color: enableRepeat ? Colors.blue : Colors.grey,
//                       ),
//                       Text(
//                         'Repeat: ${enableRepeat ? "ON" : "OFF"}',
//                         style: TextStyle(
//                           color: enableRepeat ? Colors.blue : Colors.grey,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
            
//             // Video Player
//             Expanded(
//               child: YoutubeWebviewPlayer(
//                 youtubeId: selectedVideoId,
//                 enableRepeat: enableRepeat,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }











import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:mobi_tv_entertainment/main.dart'; // Ensure this path is correct

/// A separate widget to handle the date and time updates to prevent flickering.
class DateTimeWidget extends StatefulWidget {
  const DateTimeWidget({Key? key}) : super(key: key);

  @override
  _DateTimeWidgetState createState() => _DateTimeWidgetState();
}

class _DateTimeWidgetState extends State<DateTimeWidget> {
  late Timer _dateTimeTimer;
  String _currentDate = '';
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _startDateTimeTimer();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    _currentDate = DateFormat('MM/dd/yyyy').format(now);
    _currentTime = DateFormat('HH:mm:ss').format(now);
  }

  void _startDateTimeTimer() {
    _dateTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateDateTime();
        });
      }
    });
  }

  @override
  void dispose() {
    _dateTimeTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: screenhgt * 0.07,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.03),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(5)),
              child: Text(_currentDate, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(5)),
              child: Text(_currentTime, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

/// The main YouTube player widget with all features.
class YoutubeWebviewPlayer extends StatefulWidget {
  final String videoUrl;
  final String? name;

  const YoutubeWebviewPlayer({
    Key? key,
    required this.videoUrl,
    required this.name,
  }) : super(key: key);

  @override
  _YoutubeWebviewPlayerState createState() => _YoutubeWebviewPlayerState();
}

class _YoutubeWebviewPlayerState extends State<YoutubeWebviewPlayer> with WidgetsBindingObserver {
  InAppWebViewController? _webViewController;
  String? _videoId;
  bool _isPageLoading = true;
  final FocusNode _focusNode = FocusNode();

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  final List<ContentBlocker> adBlockers = [
    ContentBlocker(trigger: ContentBlockerTrigger(urlFilter: ".*doubleclick\\.net/.*"), action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK)),
    ContentBlocker(trigger: ContentBlockerTrigger(urlFilter: ".*googlesyndication\\.com/.*"), action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK)),
    ContentBlocker(trigger: ContentBlockerTrigger(urlFilter: ".*googleadservices\\.com/.*"), action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK)),
    ContentBlocker(trigger: ContentBlockerTrigger(urlFilter: ".*google-analytics\\.com/.*"), action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK)),
    ContentBlocker(trigger: ContentBlockerTrigger(urlFilter: ".*adservice\\.google\\.com/.*"), action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK)),
    ContentBlocker(trigger: ContentBlockerTrigger(urlFilter: ".*youtube\\.com/api/stats/ads.*"), action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK)),
    ContentBlocker(trigger: ContentBlockerTrigger(urlFilter: ".*youtube\\.com/get_ad_break.*"), action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK)),
    ContentBlocker(trigger: ContentBlockerTrigger(urlFilter: ".*youtube\\.com/pagead/.*"), action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK)),
    ContentBlocker(trigger: ContentBlockerTrigger(urlFilter: ".*googlevideo\\.com/videoplayback.*adformat.*"), action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK)),
    ContentBlocker(trigger: ContentBlockerTrigger(urlFilter: ".*googlevideo\\.com/videoplayback.*ctier.*"), action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK)),
    ContentBlocker(trigger: ContentBlockerTrigger(urlFilter: ".*youtube\\.com/ptracking.*"), action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK)),
    ContentBlocker(trigger: ContentBlockerTrigger(urlFilter: ".*youtube\\.com/api/stats/qoe.*"), action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK)),
    ContentBlocker(trigger: ContentBlockerTrigger(urlFilter: ".*youtube\\.com/ad_data.*"), action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK)),
    ContentBlocker(trigger: ContentBlockerTrigger(urlFilter: ".*youtube\\.com/api/stats/atr.*"), action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK)),
    ContentBlocker(trigger: ContentBlockerTrigger(urlFilter: ".*stats\\.g\\.doubleclick\\.net/.*"), action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK)),
  ];

  String? _extractVideoId(String url) {
    if (url.length == 11 && !url.contains('/') && !url.contains('?')) {
      return url; // It's already an ID
    }
    RegExp regExp = RegExp(
      r'.*(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    return (match != null && match.group(1)!.length == 11) ? match.group(1) : null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _videoId = _extractVideoId(widget.videoUrl);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _webViewController?.resumeTimers();
        _webViewController?.evaluateJavascript(source: "if(player && player.playVideo) { player.playVideo(); }");
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _webViewController?.evaluateJavascript(source: "if(player && player.pauseVideo) { player.pauseVideo(); }");
        _webViewController?.pauseTimers();
        break;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final String livePlayerUrl = "https://yaqoob-work.github.io/my-player/player.html";

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.mediaPlayPause) {
            _webViewController?.evaluateJavascript(source: "togglePlayPause();");
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.mediaFastForward) {
            _webViewController?.evaluateJavascript(source: "seek(30);");
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.mediaRewind) {
            _webViewController?.evaluateJavascript(source: "seek(-30);");
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _videoId == null
            ? const Center(child: Text('Invalid YouTube URL', style: TextStyle(color: Colors.white, fontSize: 18)))
            : Stack(
                children: [
                  // Video Player Container (100% height)
                  Positioned.fill(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: InAppWebView(
                          initialSettings: InAppWebViewSettings(
                            contentBlockers: adBlockers,
                            useHybridComposition: false,
                            userAgent: "Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.106 Mobile Safari/537.36",
                            allowsInlineMediaPlayback: true,
                            mediaPlaybackRequiresUserGesture: false,
                            forceDark: ForceDark.OFF,
                          ),
                          onWebViewCreated: (controller) {
                            _webViewController = controller;
                            controller.addJavaScriptHandler(
                              handlerName: 'timeUpdate',
                              callback: (args) {
                                if (args.length == 2 && args[0] is num && args[1] is num) {
                                  if (mounted) {
                                    setState(() {
                                      _currentPosition = Duration(seconds: (args[0] as num).toInt());
                                      _totalDuration = Duration(seconds: (args[1] as num).toInt());
                                    });
                                  }
                                }
                              },
                            );
                            final urlToLoad = WebUri("$livePlayerUrl?id=$_videoId");
                            _webViewController?.loadUrl(urlRequest: URLRequest(url: urlToLoad));
                          },
                          onLoadStop: (controller, url) {
                            setState(() => _isPageLoading = false);
                            _focusNode.requestFocus();
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  _buildTopBar(),
                  const DateTimeWidget(),
                  _buildProgressBar(),
                  if (_isPageLoading)
                    const Center(child: CircularProgressIndicator(color: Colors.red)),
                ],
              ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(top: 8.0),
        height: screenhgt * 0.1,
        color: Colors.black,
        alignment: Alignment.center,
        child: Text(
          widget.name?.toUpperCase() ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    double progress = (_totalDuration.inSeconds == 0) ? 0 : _currentPosition.inSeconds / _totalDuration.inSeconds;
    if (progress > 1.0) progress = 1.0;
    if (progress < 0) progress = 0;

    return Positioned(
      bottom: 0,
      left: screenwdt * 0.7,
      right: 0,
      height: screenhgt * 0.12,
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
              minHeight: 6,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_currentPosition),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  _formatDuration(_totalDuration),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}






