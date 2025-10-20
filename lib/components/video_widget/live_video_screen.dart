// import 'dart:async';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // Keyboard events ke liye zaroori
// import 'package:keep_screen_on/keep_screen_on.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';

// class LiveVideoScreen extends StatefulWidget {
//   final String videoUrl;
//   final String name;
//   final bool liveStatus;
//   final String updatedAt;
//   final List<dynamic> channelList;
//   final String bannerImageUrl;
//   final int? videoId;
//   final String source;

//   LiveVideoScreen({
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
//   _LiveVideoScreenState createState() => _LiveVideoScreenState();
// }

// class _LiveVideoScreenState extends State<LiveVideoScreen> {
//   // MediaKit Player aur Controller
//   late final Player player;
//   late final VideoController controller;

//   // UI aur State Management ke liye variables (purane code se)
//   final FocusNode _mainFocusNode = FocusNode();
//   final ScrollController _scrollController = ScrollController();
//   late List<FocusNode> _channelFocusNodes;
//   late int _focusedIndex;
//   bool _controlsVisible = true;
//   Timer? _hideControlsTimer;

//   // Channel ka naam state mein store karein taaki badalne par UI update ho
//   late String _currentChannelName;

//   @override
//   void initState() {
//     super.initState();

//     // 1. Player aur Controller initialize karein
//     // player = Player();
//       // 1. Player aur Controller initialize karein (YAHAN BADLAV KAREIN)
//   player = Player(
//     configuration: PlayerConfiguration(
//       // Buffer size badhayein. Default se zyada rakhein.
//       // 10 seconds ka buffer kaafi smooth experience de sakta hai.
//       bufferSize: 8 * 1024 * 1024,
//     ),
//   );
//     controller = VideoController(player);
//     player.open(Media(widget.videoUrl), play: true);

//     _currentChannelName = widget.name;
//     KeepScreenOn.turnOn();

//     // 2. Channel list ke liye initial setup
//     _setupChannelList();

//     // 3. Controls ko 5 second baad hide karne ka timer shuru karein
//     _startHideControlsTimer();

//     // 4. Screen par focus set karein taaki remote/keyboard kaam kare
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       FocusScope.of(context).requestFocus(_mainFocusNode);
//       _focusAndScrollToInitialItem();
//     });
//   }

//   void _setupChannelList() {
//     // Shuruaat mein kon sa channel selected hai, uska index pata karein
//     _focusedIndex = widget.channelList.indexWhere(
//       (channel) => channel.id.toString() == widget.videoId.toString(),
//     );
//     // Agar channel nahi milta hai to 0 set karein
//     if (_focusedIndex == -1) {
//       _focusedIndex = 0;
//     }

//     // Har channel ke liye ek FocusNode banayein
//     _channelFocusNodes = List.generate(
//       widget.channelList.length,
//       (index) => FocusNode(),
//     );
//   }

//   @override
//   void dispose() {
//     // Sab kuch aache se dispose karein taaki memory leak na ho
//     player.dispose();
//     _mainFocusNode.dispose();
//     _scrollController.dispose();
//     _channelFocusNodes.forEach((node) => node.dispose());
//     _hideControlsTimer?.cancel();
//     KeepScreenOn.turnOff();
//     super.dispose();
//   }

//   // KEY ACTION: Channel badalne wala function
//   void _switchChannel(int index) {
//     if (index < 0 || index >= widget.channelList.length) return;

//     final channel = widget.channelList[index];

//     setState(() {
//       _focusedIndex = index;
//       _currentChannelName = channel.name; // Channel ka naam update karein
//     });

//     // media_kit player mein naya URL chalaayein
//     player.open(Media(channel.url), play: true);
//     _resetHideControlsTimer();
//   }

//   // --- Controls ko Show/Hide karne wale Functions ---

//   void _toggleControlsVisibility() {
//     setState(() {
//       _controlsVisible = !_controlsVisible;
//     });
//     // Agar controls dikh rahe hain, to unhe hide karne ke liye timer reset karein
//     if (_controlsVisible) {
//       _resetHideControlsTimer();
//     }
//   }

//   void _startHideControlsTimer() {
//     _hideControlsTimer = Timer(const Duration(seconds: 5), () {
//       if (mounted) {
//         setState(() {
//           _controlsVisible = false;
//         });
//       }
//     });
//   }

//   void _resetHideControlsTimer() {
//     _hideControlsTimer?.cancel();
//     // Controls ko visible karein agar wo hidden hain
//     if (!_controlsVisible && mounted) {
//       setState(() {
//         _controlsVisible = true;
//       });
//     }
//     _startHideControlsTimer();
//   }

//   // --- Remote/Keyboard Navigation ke Functions ---

//   void _handleKeyEvent(RawKeyEvent event) {
//     if (event is RawKeyDownEvent) {
//       // Koi bhi button dabne par controls dikhayein
//       _resetHideControlsTimer();

//       // Upar/Neeche jaane ke liye
//       if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//         if (_focusedIndex > 0) {
//           _changeFocusAndScroll(_focusedIndex - 1);
//         }
//       } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//         if (_focusedIndex < widget.channelList.length - 1) {
//           _changeFocusAndScroll(_focusedIndex + 1);
//         }
//       }
//       // Channel select karne ke liye
//       else if (event.logicalKey == LogicalKeyboardKey.select ||
//           event.logicalKey == LogicalKeyboardKey.enter) {
//         // Agar VOD hai to Play/Pause karein, agar Live hai to channel switch karein
//         // if (widget.liveStatus == false) {
//         //  player.playOrPause();
//         // } else {
//         _switchChannel(_focusedIndex);
//         // }
//       }
//       // // VOD ko aage/peeche karne ke liye
//       // else if (widget.liveStatus == false) {
//       //   if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//       //       player.seek(player.state.position - const Duration(seconds: 10));
//       //   } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//       //       player.seek(player.state.position + const Duration(seconds: 10));
//       //   }
//       // }
//     }
//   }

//   void _changeFocusAndScroll(int newIndex) {
//     setState(() {
//       _focusedIndex = newIndex;
//     });
//     FocusScope.of(context).requestFocus(_channelFocusNodes[newIndex]);
//     _scrollToFocusedItem();
//   }

//   // Shuruaat mein sahi item par focus aur scroll karne ke liye
//   void _focusAndScrollToInitialItem() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted || _focusedIndex >= _channelFocusNodes.length) return;
//       // Pehle scroll karein
//       final itemHeight = (MediaQuery.of(context).size.height * 0.14) + 8.0;
//       final targetOffset =
//           (_focusedIndex * itemHeight) - itemHeight; // Thoda upar rakhein
//       _scrollController.jumpTo(
//           targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent));
//       // Fir focus karein
//       FocusScope.of(context).requestFocus(_channelFocusNodes[_focusedIndex]);
//     });
//   }

//   // Scroll karke focused item ko screen par laane ke liye
//   void _scrollToFocusedItem() {
//     if (_focusedIndex < 0 || !_scrollController.hasClients) return;

//     // Ek item ki anumanit height
//     final double itemHeight =
//         (MediaQuery.of(context).size.height * 0.13) + 8.0;

//     // Target position jahan tak scroll karna hai
//     final double targetOffset = itemHeight * _focusedIndex;

//     _scrollController.animateTo(
//       targetOffset,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       // Focus widget remote/keyboard ke input ko sunne ke liye
//       body: RawKeyboardListener(
//         focusNode: _mainFocusNode,
//         onKey: _handleKeyEvent,
//         child: GestureDetector(
//           onTap:
//               _toggleControlsVisibility, // Screen par tap karne se controls show/hide honge
//           child: Stack(
//             children: [
//               // 1. Video Player (background mein)
//               Center(
//                 child: SizedBox(
//                   width: MediaQuery.of(context).size.width,
//                   height: MediaQuery.of(context).size.height,
//                   child: Video(
//                     controller: controller,
//                     // Hum custom controls bana rahe hain, isliye yahan null rakhein
//                     controls: null,
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//               ),

//               // Buffering Indicator
//               StreamBuilder<bool>(
//                 stream: player.stream.buffering,
//                 builder: (context, snapshot) {
//                   final isBuffering = snapshot.data ?? false;
//                   return isBuffering
//                       ? const Center(child: CircularProgressIndicator())
//                       : const SizedBox.shrink();
//                 },
//               ),

//               // 2. Channel List (agar controls visible hain)
//               if (widget.channelList.isNotEmpty) _buildChannelList(),

//               // 3. Niche ka Control Bar (agar controls visible hain)
//               if (_controlsVisible) _buildControlsOverlay(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // UI WIDGET: Channel List banane ke liye
//   Widget _buildChannelList() {
//     final screenHeight = MediaQuery.of(context).size.height;
//     return Positioned(
//       top: screenHeight * 0.03,
//       left: 20,
//       bottom: screenHeight * 0.1,
//       width: MediaQuery.of(context).size.width * 0.17, // List ki chaudai
//       child: Opacity(
//         opacity: _controlsVisible ? 1 : 0.001,
//         child: Container(
//           color: Colors.black.withOpacity(0.5),
//           child: ListView.builder(
//             controller: _scrollController,
//             itemCount: widget.channelList.length,
//             itemBuilder: (context, index) {
//               final channel = widget.channelList[index];
//               final bool isFocused = _focusedIndex == index;

//               return Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
//                 child: GestureDetector(
//                   onTap: () => _switchChannel(index),
//                   child: Focus(
//                     focusNode: _channelFocusNodes[index],
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       height: screenHeight * 0.14,
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: isFocused
//                               ? Colors.deepPurpleAccent
//                               : Colors.transparent,
//                           width: 4.0,
//                         ),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(4),
//                         child: Stack(
//                           fit: StackFit.expand,
//                           children: [
//                             Opacity(
//                               opacity: 0.4,
//                               child: CachedNetworkImage(
//                                 imageUrl: channel.banner ?? '',
//                                 fit: BoxFit.cover,
//                                 errorWidget: (context, url, error) => Container(
//                                   color: Colors.grey[800],
//                                   child: Icon(Icons.tv, color: Colors.white54),
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   colors: [
//                                     Colors.transparent,
//                                     Colors.black.withOpacity(0.8)
//                                   ],
//                                   begin: Alignment.center,
//                                   end: Alignment.bottomCenter,
//                                 ),
//                               ),
//                             ),
//                             Positioned(
//                               bottom: 8,
//                               left: 8,
//                               right: 8,
//                               child: Text(
//                                 channel.name,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                   shadows: [
//                                     Shadow(blurRadius: 2, color: Colors.black)
//                                   ],
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   // UI WIDGET: Niche wala control bar (Progress, Time, Channel Name)
//   Widget _buildControlsOverlay() {
//     return Positioned(
//       bottom: 0,
//       left: 20,
//       right: 20,
//       child: Opacity(
//         opacity: _controlsVisible ? 1 : 0.001,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//           color: Colors.black.withOpacity(0.6),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // // Channel ka Naam
//               // Text(
//               //   _currentChannelName,
//               //   style: const TextStyle(
//               //     color: Colors.white,
//               //     fontSize: 24,
//               //     fontWeight: FontWeight.bold,
//               //   ),
//               // ),
//               // const SizedBox(height: 8),
//               // Progress Bar aur Time (sirf VOD ke liye)
//               // if (!widget.liveStatus)
//               StreamBuilder<Duration>(
//                 stream: player.stream.position,
//                 builder: (context, positionSnapshot) {
//                   return StreamBuilder<Duration>(
//                     stream: player.stream.duration,
//                     builder: (context, durationSnapshot) {
//                       final position = positionSnapshot.data ?? Duration.zero;
//                       final duration = durationSnapshot.data ?? Duration.zero;
//                       double progress = 0.0;
//                       if (duration.inMilliseconds > 0) {
//                         progress =
//                             position.inMilliseconds / duration.inMilliseconds;
//                       }

//                       return Row(
//                         children: [
//                           Text(_formatDuration(position),
//                               style: const TextStyle(color: Colors.white)),
//                           Expanded(
//                             child: Slider(
//                               value: progress.clamp(0.0, 1.0),
//                               onChanged: (value) {
//                                 final seekPos = duration * value;
//                                 player.seek(seekPos);
//                               },
//                             ),
//                           ),

//                           // Text(_formatDuration(duration), style: const TextStyle(color: Colors.white)),
//                           Text("LIVE",
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold))
//                         ],
//                       );
//                     },
//                   );
//                 },
//               ),
//               // Live Indicator
//               //  if (widget.liveStatus)
//               //     Row(
//               //       children: const [
//               //         Icon(Icons.circle, color: Colors.red, size: 14),
//               //         SizedBox(width: 8),
//               //         Text("LIVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
//               //       ],
//               //     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper function: Duration ko format karne ke liye
//   String _formatDuration(Duration d) {
//     if (d.inHours > 0) {
//       return d.toString().split('.').first.padLeft(8, "0");
//     }
//     return d.toString().split('.').first.padLeft(5, "0");
//   }
// }
