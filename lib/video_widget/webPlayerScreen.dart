// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class WebPlayerScreen extends StatefulWidget {
//   final String videoUrl;

//   const WebPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);

//   @override
//   State<WebPlayerScreen> createState() => _WebPlayerScreenState();
// }

// class _WebPlayerScreenState extends State<WebPlayerScreen> {
//   late final WebViewController _controller;

//   @override
//   void initState() {
//     super.initState();

//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(const Color(0x00000000))
//       ..loadRequest(Uri.parse(widget.videoUrl));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: const Text('new player'),
//       //   backgroundColor: Colors.black,
//       // ),
//       body: WebViewWidget(
//         controller: _controller,
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // फ़ुल-स्क्रीन के लिए यह ज़रूरी है
// import 'package:webview_flutter/webview_flutter.dart';

// // ऐप को चलाने के लिए main फंक्शन
// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Web Player Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         brightness: Brightness.dark,
//       ),
//       home: const HomePage(),
//     );
//   }
// }

// // होम पेज, जहाँ से हम वेब प्लेयर स्क्रीन पर जाएंगे
// class HomePage extends StatelessWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home Page'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const WebPlayerScreen(
//                   // ❗️ अपना काम करने वाला URL यहाँ डालें
//                   // यह एक सैंपल video.js URL है
//                   videoUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
//                 ),
//               ),
//             );
//           },
//           child: const Text('Open Web Player'),
//         ),
//       ),
//     );
//   }
// }

// // ===================================================================
// // फोकस को हैंडल करने वाला कस्टम बटन
// // ===================================================================
// class FocusableButton extends StatefulWidget {
//   final VoidCallback onPressed;
//   final Widget child;
//   final Color? backgroundColor;

//   const FocusableButton({
//     Key? key,
//     required this.onPressed,
//     required this.child,
//     this.backgroundColor,
//   }) : super(key: key);

//   @override
//   State<FocusableButton> createState() => _FocusableButtonState();
// }

// class _FocusableButtonState extends State<FocusableButton> {
//   final FocusNode _focusNode = FocusNode();
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     _focusNode.addListener(_onFocusChange);
//   }

//   void _onFocusChange() {
//     if (_focusNode.hasFocus != _isFocused) {
//       setState(() {
//         _isFocused = _focusNode.hasFocus;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _focusNode.removeListener(_onFocusChange);
//     _focusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Transform.scale(
//       scale: _isFocused ? 1.1 : 1.0,
//       child: ElevatedButton(
//         focusNode: _focusNode,
//         onPressed: widget.onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor:
//               _isFocused ? Colors.orangeAccent : widget.backgroundColor,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//             side: _isFocused
//                 ? const BorderSide(color: Colors.white, width: 2)
//                 : BorderSide.none,
//           ),
//         ),
//         child: widget.child,
//       ),
//     );
//   }
// }

// // ===================================================================
// // मुख्य वेब प्लेयर स्क्रीन
// // ===================================================================
// class WebPlayerScreen extends StatefulWidget {
//   final String videoUrl;

//   const WebPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);

//   @override
//   State<WebPlayerScreen> createState() => _WebPlayerScreenState();
// }

// class _WebPlayerScreenState extends State<WebPlayerScreen> {
//   late final WebViewController _controller;
//   bool _isPageFinished = false;
//   bool _isFlutterFullscreen = false; // फ़ुल-स्क्रीन स्टेट को ट्रैक करने के लिए

//   @override
//   void initState() {
//     super.initState();

//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(const Color(0x00000000))
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageFinished: (String url) {
//             _injectJavaScriptFunctions();
//             setState(() {
//               _isPageFinished = true;
//             });
//           },
//         ),
//       )
//       ..setOnConsoleMessage((JavaScriptConsoleMessage message) {
//         // WebView से आने वाले console.log मैसेज देखने के लिए
//         debugPrint('WebView Console: ${message.message}');
//       })
//       ..loadRequest(Uri.parse(widget.videoUrl));
//   }
  
//   // Flutter साइड से UI को फ़ुल-स्क्रीन करने का फंक्शन
//   void _toggleFlutterFullScreen() {
//     setState(() {
//       _isFlutterFullscreen = !_isFlutterFullscreen;
//       if (_isFlutterFullscreen) {
//         SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//       } else {
//         SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//       }
//     });
//   }

//   void _injectJavaScriptFunctions() {
//     _controller.runJavaScript('''
//       // इमेज दिखाने वाला फंक्शन
//       function showImageOverlay(imageUrl) {
//         var existingOverlay = document.getElementById('flutter_overlay_image');
//         if (existingOverlay) { existingOverlay.remove(); }
//         var video = document.querySelector('video');
//         if (video && video.parentElement) {
//           var overlayImage = document.createElement('img');
//           overlayImage.id = 'flutter_overlay_image';
//           overlayImage.src = imageUrl;
//           overlayImage.style.position = 'absolute';
//           overlayImage.style.top = '50%';
//           overlayImage.style.left = '50%';
//           overlayImage.style.transform = 'translate(-50%, -50%)';
//           overlayImage.style.width = '200px';
//           overlayImage.style.zIndex = '999';
//           video.parentElement.style.position = 'relative';
//           video.parentElement.appendChild(overlayImage);
//         }
//       }

//       // इमेज छिपाने वाला फंक्शन
//       function hideImageOverlay() {
//         var overlayImage = document.getElementById('flutter_overlay_image');
//         if (overlayImage) { overlayImage.remove(); }
//       }

//       // ==> बदला हुआ अनम्यूट फंक्शन (ज़्यादा भरोसेमंद)
//       function unmuteVideo() {
//         // सुनिश्चित करें कि आपके वेब पेज में वीडियो टैग का ID 'my-video-player' है।
//         var player = videojs.getPlayer('my-video-player');
//         if (player) {
//           player.muted(false);
//           console.log('Video.js player unmuted.');
//         } else {
//           // अगर video.js प्लेयर नहीं मिलता है तो फॉलबैक
//           var video = document.querySelector('video');
//           if (video) {
//             video.muted = false;
//             console.log('HTML5 video unmuted.');
//           } else {
//             console.log('Video element not found.');
//           }
//         }
//       }

//       // ==> नया फ़ुल-स्क्रीन फंक्शन
//       function toggleWebFullScreen() {
//         // यह video.js के डिफ़ॉल्ट फ़ुल-स्क्रीन बटन को ढूंढकर क्लिक करता है।
//         var fullScreenButton = document.querySelector('.vjs-fullscreen-control');
//         if (fullScreenButton) {
//           fullScreenButton.click();
//           console.log('Fullscreen button clicked.');
//         } else {
//           console.log('Fullscreen button not found.');
//         }
//       }
//     ''');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       // फ़ुल-स्क्रीन होने पर AppBar को छिपा दें
//       // appBar: _isFlutterFullscreen
//       //     ? null
//       //     : AppBar(
//       //         title: const Text('Web Player'),
//       //         backgroundColor: Colors.grey[900],
//       //       ),
//       body: SafeArea(
//         // फ़ुल-स्क्रीन में SafeArea को डिसेबल करें
//         top: !_isFlutterFullscreen,
//         bottom: !_isFlutterFullscreen,
//         child: Column(
//           children: [
//             Expanded(
//               child: WebViewWidget(
//                 controller: _controller,
//               ),
//             ),
//             // फ़ुल-स्क्रीन होने पर कंट्रोल बटन्स को छिपा दें
//             if (_isPageFinished && !_isFlutterFullscreen)
//               Container(
//                 padding: const EdgeInsets.all(12.0),
//                 color: Colors.grey[900],
//                 child: Wrap(
//                   alignment: WrapAlignment.center,
//                   spacing: 20.0,
//                   runSpacing: 12.0,
//                   children: [
//                     FocusableButton(
//                       onPressed: () {
//                         const imageUrl = 'https://picsum.photos/200/300';
//                         _controller
//                             .runJavaScript('showImageOverlay("$imageUrl");');
//                       },
//                       backgroundColor: Colors.blueAccent,
//                       child: const Text('Show Image'),
//                     ),
//                     FocusableButton(
//                       onPressed: () {
//                         _controller.runJavaScript('hideImageOverlay();');
//                       },
//                       backgroundColor: Colors.redAccent,
//                       child: const Text('Hide Image'),
//                     ),
//                     FocusableButton(
//                       onPressed: () {
//                         _controller.runJavaScript('unmuteVideo();');
//                       },
//                       backgroundColor: Colors.green,
//                       child: const Text('Unmute'),
//                     ),
//                     // ==> नया बटन: वेब प्लेयर को फ़ुल-स्क्रीन करने के लिए
//                     FocusableButton(
//                       onPressed: () {
//                         _controller.runJavaScript('toggleWebFullScreen();');
//                       },
//                       backgroundColor: Colors.purpleAccent,
//                       child: const Text('Web Fullscreen'),
//                     ),
//                     // ==> नया बटन: Flutter UI को फ़ुल-स्क्रीन करने के लिए
//                     FocusableButton(
//                       onPressed: _toggleFlutterFullScreen,
//                       backgroundColor: Colors.deepPurple,
//                       child: const Text('App Fullscreen'),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }