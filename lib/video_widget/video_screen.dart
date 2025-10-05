// import 'dart:async';
// import 'dart:convert';
// import 'dart:math' as math;
// import 'dart:io';
// import 'dart:math';
// import 'package:http/http.dart' as https;
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:keep_screen_on/keep_screen_on.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart';
// import 'package:mobi_tv_entertainment/widgets/small_widgets/rainbow_page.dart';
// import 'package:mobi_tv_entertainment/widgets/small_widgets/rainbow_spinner.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../menu_screens/search_screen.dart';
// import '../widgets/models/news_item_model.dart';
// // First create an EventBus class (create a new file event_bus.dart)
// // import 'package:event_bus/event_bus.dart';

// // class GlobalEventBus {
// //   static final EventBus eventBus = EventBus();
// // }

// class GlobalVariables {
//   static String unUpdatedUrl = '';
//   static Duration position = Duration.zero;
//   static Duration duration = Duration.zero;
//   static String banner = '';
//   static String name = '';
//   static bool liveStatus = false;
// }

// // Create an event class
// class RefreshPageEvent {
//   final String pageId; // To identify which page to refresh
//   RefreshPageEvent(this.pageId);
// }

// class VideoScreen extends StatefulWidget {
//   final String videoUrl;
//   final String name;
//   final bool liveStatus;
//   final String updatedAt;
//   final List<dynamic> channelList;
//   final String bannerImageUrl;
//   // final Duration startAtPosition;
//   // final bool liveStatus;
//   // final bool isVOD;
//   // final bool isSearch;
//   // final bool? isHomeCategory;
//   // final bool isBannerSlider;
//   // final String videoType;
//   final int? videoId;
//   final String source;
//   // final Duration? totalDuration;

//   VideoScreen({
//  required this.videoUrl,
//  required this.updatedAt,
//  required this.channelList,
//  required this.bannerImageUrl,
//  // required this.startAtPosition,
//  // required this.videoType,
//  // required this.liveStatus,
//  // required this.isVOD,
//  // required this.isSearch,
//  // this.isHomeCategory,
//  // required this.isBannerSlider,
//  required this.videoId,
//  required this.source,
//  required this.name,
//  required this.liveStatus,
//  // this.totalDuration
//   });

//   @override
//   _VideoScreenState createState() => _VideoScreenState();
// }

// class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
//   // final SocketService _socketService = SocketService();

//   VlcPlayerController? _controller;
//   bool _controlsVisible = true;
//   late Timer _hideControlsTimer;
//   Duration _totalDuration = Duration.zero;
//   Duration _currentPosition = Duration.zero;
//   bool _isBuffering = false;
//   bool _isConnected = true;
//   bool _isVideoInitialized = false;
//   Timer? _connectivityCheckTimer;
//   int _focusedIndex = 0;
//   // bool _isPlayPauseFocused = false;
//   bool _isFocused = false;
//   List<FocusNode> focusNodes = [];
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _channelListFocusNode = FocusNode();
//   // final FocusNode screenFocusNode = FocusNode();
//   final FocusNode playPauseButtonFocusNode = FocusNode();

//   double _progress = 0.0;
//   double _currentVolume = 0.00; // Initialize with default volume (50%)
//   double _bufferedProgress = 0.0;
//   bool _isVolumeIndicatorVisible = false;
//   // Timer? _volumeIndicatorTimer;
//   static const platform = MethodChannel('com.example.volume');
//   bool _loadingVisible = false;
//   Duration _lastKnownPosition = Duration.zero;
//   bool _wasPlayingBeforeDisconnection = false;
//   int _maxRetries = 3;
//   int _retryDelay = 5; // seconds
//   Timer? _networkCheckTimer;
//   bool _wasDisconnected = false;
//   String? _currentModifiedUrl; // To store the current modified URL
//   bool _isDisposing = false;
//   bool _isDisposed = false;
//   final Completer<void> _cleanupCompleter = Completer<void>();

//   // Uint8List _getImageFromBase64String(String base64String) {
//   //   // Split the base64 string to remove metadata if present
//   //   return base64Decode(base64String.split(',').last);
//   // }

//   Map<String, Uint8List> _imageCache = {};

//   // Uint8List _getCachedImage(String base64String) {
//   //   if (!_imageCache.containsKey(base64String)) {
//   //  _imageCache[base64String] = base64Decode(base64String.split(',').last);
//   //   }
//   //   return _imageCache[base64String]!;
//   // }

//   @override
//   void initState() {
//  super.initState();
//  WidgetsBinding.instance.addObserver(this);
//  _scrollController.addListener(_scrollListener);
//  _previewPosition = _controller?.value.position ?? Duration.zero;
//  KeepScreenOn.turnOn();

//  // // Match channel by ID as strings
//  // if (widget.isBannerSlider) {
//  //   _focusedIndex = widget.channelList.indexWhere(
//  //  (channel) => channel.contentId.toString() == widget.videoId.toString(),
//  //   );
//  // } else
//  if (widget.liveStatus == false || widget.liveStatus == true) {
//    _focusedIndex = widget.channelList.indexWhere(
//   (channel) => channel.id.toString() == widget.videoId.toString(),
//    );
//  } else {
//    _focusedIndex = widget.channelList.indexWhere(
//   (channel) => channel.url == widget.videoUrl,
//    );
//  }
//  // Default to 0 if no match is found
//  _focusedIndex = (_focusedIndex >= 0) ? _focusedIndex : 0;

//  // print('Initial focused index: $_focusedIndex');
//  // Initialize focus nodes
//  focusNodes = List.generate(
//    widget.channelList.length,
//    (index) => FocusNode(),
//  );
//  // Set initial focus
//  WidgetsBinding.instance.addPostFrameCallback((_) {
//    // _setInitialFocus();
//    if (widget.liveStatus == false) {
//   FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//    }
//    _focusAndScrollToInitialItem();
//  });
//  _initializeVLCController(_focusedIndex);
//  _startHideControlsTimer();
//  _startNetworkMonitor();
//  _startPositionUpdater();
//   }

//   // 🎯 This is the new, corrected function to set initial focus and scroll.
// // It replaces your old _setInitialFocus method.
//   void _focusAndScrollToInitialItem() {
//  // Ensure we have a valid index and the scroll controller is ready.
//  if (_focusedIndex < 0 || _focusedIndex >= focusNodes.length || !mounted) {
//    return;
//  }

//  // Use a post-frame callback to ensure the layout is complete before we do anything.
//  WidgetsBinding.instance.addPostFrameCallback((_) {
//    if (!_scrollController.hasClients) return;

//    // --- STEP 1: SCROLL INTO VIEW ---
//    // Define the approximate height of each item in your list.
//    // This is based on: Container height (screenhgt * 0.18) + vertical padding (8.0 * 2)
//    final double itemHeight = (screenhgt * 0.18) + 16.0;

//    // Calculate the target scroll offset to bring the item into view.
//    // We subtract a bit to ensure it's not right at the edge.
//    final double targetOffset = (itemHeight * _focusedIndex) - 40.0;

//    // Clamp the value to be within the valid scroll range.
//    final double clampedOffset = targetOffset.clamp(
//   _scrollController.position.minScrollExtent,
//   _scrollController.position.maxScrollExtent,
//    );

//    // Use jumpTo to instantly move the list. This forces the widget to be built.
//    _scrollController.jumpTo(clampedOffset);

//    // --- STEP 2: REQUEST FOCUS ---
//    // We need to wait for the next frame for the widget to be built after the jump.
//    // A second post-frame callback is a reliable way to do this.
//    WidgetsBinding.instance.addPostFrameCallback((_) {
//   if (widget.liveStatus == false) {
//  FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//   } else if (widget.channelList.isNotEmpty) {
//  if (mounted && _focusedIndex < focusNodes.length) {
//    print(
//  "✅ Scrolling complete. Requesting focus for index: $_focusedIndex");
//    FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//  }
//   } else {
//  FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//   }
//    });
//  });
//   }

//   // This is a new helper function to manage focus change during navigation.
// // यह नेविगेशन के दौरान फोकस बदलने को मैनेज करने के लिए एक नया हेल्पर फंक्शन है।
//   void _changeFocusAndScroll(int newIndex) {
//  // Check for valid index range
//  if (newIndex < 0 || newIndex >= widget.channelList.length) {
//    return;
//  }

//  setState(() {
//    _focusedIndex = newIndex;
//  });

//  // Use a post-frame callback to ensure setState has completed.
//  WidgetsBinding.instance.addPostFrameCallback((_) {
//    if (!_scrollController.hasClients || !mounted) return;

//    // --- STEP 1: SCROLL (Jump) to the new item's position ---
//    // This ensures the widget for the new item is built by the ListView.builder.
//    // यह सुनिश्चित करता है कि नए आइटम के लिए विजेट ListView.builder द्वारा बनाया गया है।
//    final double itemHeight =
//  (screenhgt * 0.18) + 16.0; // Same calculation as before
//    final double targetOffset = (itemHeight * _focusedIndex) - 40.0;
//    final double clampedOffset = targetOffset.clamp(
//   _scrollController.position.minScrollExtent,
//   _scrollController.position.maxScrollExtent,
//    );
//    _scrollController.jumpTo(clampedOffset);

//    // --- STEP 2: FOCUS on the new item ---
//    // After jumping, wait for the next frame, then request focus.
//    // The widget now exists and can receive focus.
//    // जंप करने के बाद, अगले फ्रेम का इंतजार करें, फिर फोकस का अनुरोध करें।
//    WidgetsBinding.instance.addPostFrameCallback((_) {
//   if (mounted) {
//  FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//  // Your existing onFocusChange will then call _scrollToFocusedItem
//  // to fine-tune the scroll animation.
//   }
//    });
//  });
//   }

// // Replace your old _handleKeyEvent with this one.
//   void _handleKeyEvent(RawKeyEvent event) {
//  if (event is RawKeyDownEvent) {
//    _resetHideControlsTimer();

//    switch (event.logicalKey) {
//   case LogicalKeyboardKey.arrowUp:
//  _resetHideControlsTimer();
//  if (playPauseButtonFocusNode.hasFocus) {
//    Future.delayed(Duration(milliseconds: 50), () {
//   if (widget.liveStatus == false) {
//  // Focus the last focused item in the list
//  FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//   }
//    });
//  } else if (_focusedIndex > 0) {
//    // *** USE THE NEW HELPER FUNCTION ***
//    _changeFocusAndScroll(_focusedIndex - 1);
//  }
//  break;

//   case LogicalKeyboardKey.arrowDown:
//  _resetHideControlsTimer();
//  if (_focusedIndex < widget.channelList.length - 1) {
//    // *** USE THE NEW HELPER FUNCTION ***
//    _changeFocusAndScroll(_focusedIndex + 1);
//  } else if (_focusedIndex < widget.channelList.length) {
//    Future.delayed(Duration(milliseconds: 50), () {
//   FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//    });
//  }
//  break;

//   case LogicalKeyboardKey.arrowRight:
//  _resetHideControlsTimer();
//  if (widget.liveStatus == false) {
//    _seekForward();
//  } else {
//    FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//  }
//  if (focusNodes.any((node) => node.hasFocus)) {
//    Future.delayed(Duration(milliseconds: 50), () {
//   FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//    });
//  } else if (playPauseButtonFocusNode.hasFocus) {
//    if (widget.liveStatus == false) {
//   _seekForward();
//    }
//  }
//  break;

//   case LogicalKeyboardKey.arrowLeft:
//  _resetHideControlsTimer();
//  if (widget.liveStatus == false) {
//    _seekBackward();
//  }
//  if (playPauseButtonFocusNode.hasFocus) {
//    if (widget.liveStatus == false) {
//   _seekBackward();
//    } else {
//   FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//    }
//  } else if (focusNodes.any((node) => node.hasFocus)) {
//    // This part is likely not needed, but kept for consistency
//    Future.delayed(Duration(milliseconds: 50), () {
//   FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//    });
//  }
//  break;

//   case LogicalKeyboardKey.select:
//   case LogicalKeyboardKey.enter:
//  _resetHideControlsTimer();

//  // 🎯 MAIN CHANGE: Check if the video is NOT live
//  // 🎯 मुख्य बदलाव: जांचें कि वीडियो लाइव नहीं है
//  if (widget.liveStatus == false) {
//    // If it's a VOD, the enter key should ALWAYS toggle play/pause,
//    // regardless of what is focused.
//    // अगर यह VOD है, तो एंटर की को हमेशा प्ले/पॉज़ करना चाहिए,
//    // भले ही फोकस कहीं भी हो।
//    _togglePlayPause();
//  } else {
//    // This is the original logic for LIVE streams.
//    // If a channel is focused, switch to it. If play/pause is focused, use it.
//    // यह LIVE स्ट्रीम के लिए मूल लॉजिक है।
//    if (playPauseButtonFocusNode.hasFocus ||
//  widget.channelList.isEmpty) {
//   _togglePlayPause();
//    } else {
//   _onItemTap(_focusedIndex);
//    }
//  }
//  break;
//    }
//  }
//   }

//   void _vlcListener() {
//  if (!mounted || _controller == null || !_controller!.value.isInitialized)
//    return;

//  // isBuffering या loadingVisible की स्थिति को अपडेट करें
//  final isBuffering = _controller!.value.isBuffering;
//  final isPlaying = _controller!.value.isPlaying;
//  if (mounted) {
//    setState(() {
//   _isBuffering = isBuffering;
//   // if (!isPlaying && isBuffering) {
//   //   _loadingVisible = true;
//   // } else {
//   //   _loadingVisible = false;
//   // }
//   if (isPlaying && !isBuffering) {
//  _loadingVisible = false;
//   }
//   // if (_controller!.value.position >= Duration(seconds: 3)) {
//   //   _loadingVisible = false;
//   // }
//    });
//  }
//   }

// // // अपने पुराने dispose() मेथड को इस नए और सुरक्षित मेथड से बदलें
// //   @override
// //   void dispose() {
// //  // स्क्रीन को ऑन रखने वाली सुविधा बंद करें
// //  KeepScreenOn.turnOff();

// //  // सभी Dart ऑब्जेक्ट्स को पहले डिस्पोज़ करें
// //  _connectivityCheckTimer?.cancel();
// //  _hideControlsTimer.cancel();
// //  // _volumeIndicatorTimer?.cancel();
// //  _networkCheckTimer?.cancel();
// //  _scrollController.dispose();
// //  // screenFocusNode.dispose();
// //  _channelListFocusNode.dispose();
// //  focusNodes.forEach((node) => node.dispose());
// //  playPauseButtonFocusNode.dispose();

// //  // <-- यहाँ मुख्य बदलाव है
// //  // VLC कंट्रोलर को अंत में डिस्पोज़ करें, बिना async/await के
// //  // यह "fire and forget" जैसा है, जो नेटिव क्रैश को रोक सकता है
// //  // _controller?.removeListener(_vlcListener);
// //  // _controller?.stop();
// //  // _controller?.dispose();

// //  if (_controller != null) {
// //    _controller!.removeListener(_vlcListener);
// //    _controller!.stop();
// //    _controller!.dispose();
// //    print("VLC Controller disposed."); // Debugging के लिए
// //  }

// //  super.dispose();
// //   }

// // VideoScreen dispose method

// @override
// void dispose() {
//   print("🗑️ VideoScreen dispose method called.");

//   // स्क्रीन को ऑन रखने वाली सुविधा बंद करें
//   KeepScreenOn.turnOff();

//   // सभी Dart ऑब्जेक्ट्स को पहले डिस्पोज़ करें
//   _connectivityCheckTimer?.cancel();
//   _hideControlsTimer.cancel();
//   _networkCheckTimer?.cancel();
//   _scrollController.dispose();
//   _channelListFocusNode.dispose();
//   focusNodes.forEach((node) => node.dispose());
//   playPauseButtonFocusNode.dispose();

//   // VLC कंट्रोलर को अंत में डिस्पोज़ करें
//   // async/await की यहाँ ज़रूरत नहीं है, क्योंकि dispose() एक sync मेथड है
//   try {
//  _controller?.removeListener(_vlcListener);
//  _controller?.stop();
//  _controller?.dispose();
//  print("✅ VLC Controller disposed from dispose().");
//   } catch (e) {
//  print("❌ Error disposing controller in dispose(): $e");
//   }

//   super.dispose();
// }

//   void _scrollListener() {
//  // if (_scrollController.position.pixels ==
//  //  _scrollController.position.maxScrollExtent) {
//  //   // _fetchData();
//  // }
//  if (_scrollController.position.pixels ==
//   _scrollController.position.maxScrollExtent) {
//    // _fetchData();
//  }
//   }

//   void _scrollToFocusedItem() {
//  WidgetsBinding.instance.addPostFrameCallback((_) {
//    if (_focusedIndex < 0 || !_scrollController.hasClients) {
//   print('Invalid focused index or no scroll controller available.');
//   return;
//    }

//    // Fetch the context of the focused node
//    final context = focusNodes[_focusedIndex].context;
//    if (context == null) {
//   print('Focus node context is null for index $_focusedIndex.');
//   return;
//    }

//    // Calculate the offset to align the focused item at the top of the viewport
//    final RenderObject? renderObject = context.findRenderObject();
//    if (renderObject != null) {
//   final double itemOffset =
//    renderObject.getTransformTo(null).getTranslation().y;

//   final double viewportOffset = _scrollController.offset +
//    itemOffset -
//    40; // 10px padding for spacing

//   // Ensure the target offset is within scroll bounds
//   final double maxScrollExtent =
//    _scrollController.position.maxScrollExtent;
//   final double minScrollExtent =
//    _scrollController.position.minScrollExtent;

//   final double safeOffset = viewportOffset.clamp(
//  minScrollExtent,
//  maxScrollExtent,
//   );

//   // Animate to the computed position
//   _scrollController.animateTo(
//  safeOffset,
//  duration: const Duration(milliseconds: 300),
//  curve: Curves.easeInOut,
//   );
//    } else {
//   print('RenderObject for index $_focusedIndex is null.');
//    }
//  });
//   }

//   // Add this to your existing Map
//   Map<String, Uint8List> _bannerCache = {};

//   // Add this method to store banners in SharedPreferences
//   Future<void> _storeBannersLocally() async {
//  try {
//    final prefs = await SharedPreferences.getInstance();
//    String storageKey =
//  'channel_banners_${widget.videoId ?? ''}_${widget.updatedAt}';

//    Map<String, String> bannerMap = {};

//    // Store each banner
//    for (var channel in widget.channelList) {
//   if (channel.banner != null && channel.banner!.isNotEmpty) {
//  String bannerId =
//   channel.id?.toString() ?? channel.contentId?.toString() ?? '';
//  if (bannerId.isNotEmpty) {
//    // If it's already a base64 string
//    if (channel.banner!.startsWith('data:image')) {
//   bannerMap[bannerId] = channel.banner!;
//    } else {
//   // If it's a URL, we'll store it as is
//   bannerMap[bannerId] = channel.banner!;
//    }
//  }
//   }
//    }

//    // Store the banner map as JSON
//    await prefs.setString(storageKey, jsonEncode(bannerMap));

//    // Store timestamp
//    await prefs.setInt(
//  '${storageKey}_timestamp', DateTime.now().millisecondsSinceEpoch);

//    print('Banners stored successfully');
//  } catch (e) {
//    print('Error storing banners: $e');
//  }
//   }

//   // Add this method to load banners from SharedPreferences
//   Future<void> _loadStoredBanners() async {
//  try {
//    final prefs = await SharedPreferences.getInstance();
//    String storageKey =
//  'channel_banners_${widget.videoId ?? ''}_${widget.updatedAt}';

//    // Check cache age
//    final timestamp = prefs.getInt('${storageKey}_timestamp');
//    if (timestamp != null) {
//   // Cache expires after 24 hours
//   if (DateTime.now().millisecondsSinceEpoch - timestamp > 86400000) {
//  await prefs.remove(storageKey);
//  await prefs.remove('${storageKey}_timestamp');
//  return;
//   }
//    }

//    String? storedData = prefs.getString(storageKey);
//    if (storedData != null) {
//   Map<String, dynamic> bannerMap = jsonDecode(storedData);

//   // Load into memory cache
//   bannerMap.forEach((id, bannerData) {
//  if (bannerData.startsWith('data:image')) {
//    _bannerCache[id] = _getCachedImage(bannerData);
//  }
//   });

//   print('Banners loaded successfully');
//    }
//  } catch (e) {
//    print('Error loading banners: $e');
//  }
//   }

//   // Modify your existing _getCachedImage method
//   Uint8List _getCachedImage(String base64String) {
//  try {
//    if (!_bannerCache.containsKey(base64String)) {
//   _bannerCache[base64String] = base64Decode(base64String.split(',').last);
//    }
//    return _bannerCache[base64String]!;
//  } catch (e) {
//    print('Error processing image: $e');
//    // Return a 1x1 transparent pixel as fallback
//    return Uint8List.fromList([0, 0, 0, 0]);
//  }
//   }

//   void _setInitialFocus() {
//  if (widget.channelList.isEmpty) {
//    print('Channel list is empty, focusing on Play/Pause button');
//    FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//    return;
//  }

//  WidgetsBinding.instance.addPostFrameCallback((_) {
//    print('Setting initial focus to index: $_focusedIndex');
//    FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//    _scrollToFocusedItem();
//  });
//   }

//   Future<void> _onNetworkReconnected() async {
//  if (_controller != null) {
//    try {
//   print("Attempting to resume playback...");

//   // Check if the network is stable
//   bool isConnected = await _isInternetAvailable();
//   if (!isConnected) {
//  print("Network is not stable yet. Delaying reconnection attempt.");
//  return;
//   }

//   // Fallback: Ensure modifiedUrl is available
//   if (_currentModifiedUrl == null || _currentModifiedUrl!.isEmpty) {
//  var selectedChannel = widget.channelList[_focusedIndex];
//  _currentModifiedUrl =
//   '${selectedChannel.url}?network-caching=2000&live-caching=1000&rtsp-tcp';
//   }

//   // Log the URL for debugging
//   print("Resuming playback with URL: $_currentModifiedUrl");
//   // Handle playback based on content type (Live or VOD)
//   if (_controller!.value.isInitialized) {
//  if (widget.liveStatus == true) {
//    // Restart live playback
//    await _retryPlayback(_currentModifiedUrl!, 3);
//    // await _controller!.setMediaFromNetwork(_currentModifiedUrl!);
//    // await _controller!.play();
//  } else {
//    // Resume VOD playback from the last known position
//    // await _controller!.setMediaFromNetwork(_currentModifiedUrl!);
//    await _retryPlayback(_currentModifiedUrl!, 3);
//    // if (_lastKnownPosition != Duration.zero) {
//    //   await _controller!.seekTo(_lastKnownPosition);
//    // }
//    await _controller!.play();
//  }
//   }
//    } catch (e) {
//   print("Error during reconnection: $e");
//   ScaffoldMessenger.of(context).showSnackBar(
//  SnackBar(content: Text("Error resuming playback: ${e.toString()}")),
//   );
//    }
//  } else {
//    print("Controller is null, cannot reconnect.");
//  }
//   }

//   void _startNetworkMonitor() {
//  _networkCheckTimer = Timer.periodic(Duration(seconds: 5), (_) async {
//    bool isConnected = await _isInternetAvailable();
//    if (!isConnected && !_wasDisconnected) {
//   _wasDisconnected = true;
//   print("Network disconnected");
//    } else if (isConnected && _wasDisconnected) {
//   _wasDisconnected = false;
//   print("Network reconnected. Attempting to resume video...");

//   // Attempt reconnection only once
//   if (_controller?.value.isInitialized ?? false) {
//  _onNetworkReconnected();
//   }
//    }
//  });
//   }

//   Future<bool> _isInternetAvailable() async {
//  try {
//    final result = await InternetAddress.lookup('google.com');
//    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//  } catch (_) {
//    return false;
//  }
//   }

//   void _startPositionUpdater() {
//  Timer.periodic(Duration(seconds: 1), (_) {
//    if (mounted && _controller?.value.isInitialized == true) {
//   setState(() {
//  _lastKnownPosition = _controller!.value.position;
//  if (_controller!.value.duration > Duration.zero) {
//    _progress = _lastKnownPosition.inMilliseconds /
//  _controller!.value.duration.inMilliseconds;
//  }
//   });
//    }
//  });
//   }

//   bool urlUpdating = false;

//   String extractApiEndpoint(String url) {
//  try {
//    Uri uri = Uri.parse(url);
//    // Get the scheme, host, and path to form the API endpoint
//    String apiEndpoint = '${uri.scheme}://${uri.host}${uri.path}';
//    return apiEndpoint;
//  } catch (e) {
//    print("Error parsing URL: $e");
//    return '';
//  }
//   }

//   void printLastPlayedPositions() {
//  for (int i = 0; i < widget.channelList.length; i++) {
//    final video = widget.channelList[i];
//    // final positionkagf = video.startAtPosition ??
//    Duration.zero; // Safely handle null values
//    // print('Video $i: PositionprintLastPlayed - ${positionkagf}');
//  }
//   }

//   void printAllStartAtPositions() {
//  for (int i = 0; i < widget.channelList.length; i++) {
//    var channel = widget.channelList[i];
//    print("Index: $i");
//    print("Channel Name: ${channel.name}");
//    print("Channel ID: ${channel.id}");
//    // print("StartAtPositions: ${widget.startAtPosition}");
//    print("---------------------------");
//  }
//   }

//   // @override
//   // void didChangeDependencies() {
//   //   super.didChangeDependencies();
//   //   if (_isVideoInitialized && !_controller!.value.isPlaying) {
//   //  _controller!.play();
//   //   }
//   // }

//   bool _isSeeking = false; // Flag to track seek state

//   Future<void> _seekToPosition(Duration position) async {
//  if (_isSeeking) return; // Skip if a seek operation is already in progress

//  _isSeeking = true;
//  try {
//    print("Seeking to position: $position");
//    await _controller!.seekTo(position); // Perform the seek operation
//    await _controller!.play(); // Start playback from the new position
//  } catch (e) {
//    print("Error during seek: $e");
//  } finally {
//    // Add a small delay to ensure the operation completes before resetting the flag
//    await Future.delayed(Duration(milliseconds: 500));
//    _isSeeking = false;
//  }
//   }

//   Future<void> _initializeVLCController(int index) async {
//  printAllStartAtPositions();

//  setState(() {
//    _loadingVisible = true;
//  });

//  // पुरानी लाइन
// // String modifiedUrl = '${widget.videoUrl}?network-caching=5000&live-caching=1000&rtsp-tcp';

// // नई और बेहतर लाइन
//  String modifiedUrl;
//  if (widget.liveStatus == true) {
//    // Live के लिए ज्यादा बफर रखें
//    modifiedUrl =
//  '${widget.videoUrl}?network-caching=5000&live-caching=500&rtsp-tcp';
//  } else {
//    // VOD के लिए कम बफर रखें ताकि seek तेज हो
//    modifiedUrl = '${widget.videoUrl}?network-caching=1500&rtsp-tcp';
//  }

//  // Initialize the controller
//  _controller = VlcPlayerController.network(
//    modifiedUrl,
//    hwAcc: HwAcc.full,
//    // autoPlay: true,
//    options: VlcPlayerOptions(
//   video: VlcVideoOptions([
//  VlcVideoOptions.dropLateFrames(true),
//  VlcVideoOptions.skipFrames(true),
//   ]),
//    ),
//  );

//  // _controller!.initialize();

//  // Retry playback in case of failures
//  // await _retryPlayback(modifiedUrl, 5);

//  // Start playback after initialization
//  if (_controller!.value.isInitialized) {
//    // _controller!.play();
//  } else {
//    print("Controller failed to initialize.");
//  }

//  _controller!.addListener(_vlcListener);

//  setState(() {
//    _isVideoInitialized = true;
//  });
//   }

//   Future<void> _retryPlayback(String url, int retries) async {
//  for (int i = 0; i < retries; i++) {
//    if (!mounted || !_controller!.value.isInitialized) return;

//    try {
//   await _controller!.setMediaFromNetwork(url);
//   // Add position seeking after successful playback start

//   // await _controller!.play();

//   _controller!.addListener(() async {});

//   return; // Exit on success
//    } catch (e) {
//   print("Retry ${i + 1} failed: $e");
//   await Future.delayed(Duration(seconds: 1));
//    }
//  }
//  print("All retries failed for URL: $url");
//   }

//   bool isOnItemTapUsed = false;
//   Future<void> _onItemTap(int index) async {
//  setState(() {
//    isOnItemTapUsed = true;
//    _loadingVisible = true;
//  });
//  var selectedChannel = widget.channelList[index];
//  String updatedUrl = selectedChannel.url;

//  // setState(() {
//  //   _loadingVisible = true;
//  // });

//  try {
//    String apiEndpoint1 = extractApiEndpoint(updatedUrl);
//    print("API Endpoint onitemtap1: $apiEndpoint1");

//    String _currentModifiedUrl =
//  '${updatedUrl}?network-caching=5000&live-caching=5000&rtsp-tcp';

//    if (_controller != null && _controller!.value.isInitialized) {
//   _controller!.initialize();

//   await _retryPlayback(_currentModifiedUrl, 5);

//   _controller!.addListener(_vlcListener);

//   setState(() {
//  _focusedIndex = index;
//   });
//    } else {
//   throw Exception("VLC Controller is not initialized");
//    }

//    setState(() {
//   _focusedIndex = index;
//   _currentModifiedUrl = _currentModifiedUrl;
//    });

//    _scrollToFocusedItem();
//    _resetHideControlsTimer();
//    // Add listener for VLC state changes
//    // _controller!.addListener(() {
//    //   final currentState = _controller!.value.playingState;

//    //   if (currentState == PlayingState.playing ) {
//    //  // Update visibility state
//    //  setState(() {

//    //  });
//    //   }
//    // });
//  } catch (e) {
//    print("Error switching channel: $e");
//    // ScaffoldMessenger.of(context).showSnackBar(
//    //   SnackBar(content: Text("Failed to switch channel: ${e.toString()}")),
//    // );
//  } finally {
//    setState(() {
//   // _loadingVisible = false;
//   Timer(Duration(seconds: 5), () {
//  setState(() {
//    _loadingVisible = false;
//  });
//   });
//    });
//  }
//   }

//   void _playNext() {
//  if (_focusedIndex < widget.channelList.length - 1) {
//    _onItemTap(_focusedIndex + 1);
//    // Future.delayed(Duration(milliseconds: 50), () {
//    //   FocusScope.of(context).requestFocus(nextButtonFocusNode);
//    // });
//  }
//   }

//   void _playPrevious() {
//  if (_focusedIndex > 0) {
//    _onItemTap(_focusedIndex - 1);
//    // Future.delayed(Duration(milliseconds: 50), () {
//    //   FocusScope.of(context).requestFocus(prevButtonFocusNode);
//    // });
//  }
//   }

//   void _togglePlayPause() {
//  if (_controller != null && _controller!.value.isInitialized) {
//    if (_controller!.value.isPlaying) {
//   _controller!.pause();
//    } else {
//   _controller!.play();
//    }
//  }

//  Future.delayed(Duration(milliseconds: 50), () {
//    FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//  });
//  _resetHideControlsTimer();
//   }

//   // Replace your entire old _resetHideControlsTimer with this new one.
// // यह आपके पुराने _resetHideControlsTimer को पूरी तरह से बदल देगा।
//   void _resetHideControlsTimer() {
//  // First, always cancel the existing timer.
//  _hideControlsTimer.cancel();

//  // If controls are already visible, we just need to restart the timer.
//  if (_controlsVisible) {
//    _startHideControlsTimer();
//    return; // Exit early
//  }

//  // --- This is the main logic for when controls are hidden ---

//  // Step 1: Make controls visible by scheduling a rebuild.
//  // स्टेप 1: रीबिल्ड शेड्यूल करके कंट्रोल्स को विज़िबल बनाएं।
//  setState(() {
//    _controlsVisible = true;
//  });

//  // Step 2: After the rebuild, scroll to the correct item and then focus.
//  // स्टेप 2: रीबिल्ड के बाद, सही आइटम पर स्क्रॉल करें और फिर फोकस करें।
//  WidgetsBinding.instance.addPostFrameCallback((_) {
//    if (!mounted) return;

//    if (widget.channelList.isEmpty) {
//   // If there's no list, just focus the play/pause button.
//   FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//    } else {
//   // --- The "Scroll First, Then Focus" Logic ---
//   if (_scrollController.hasClients) {
//  // Calculate the position of the currently focused item.
//  final double itemHeight = (screenhgt * 0.18) + 16.0;
//  final double targetOffset = (itemHeight * _focusedIndex) - 40.0;
//  final double clampedOffset = targetOffset.clamp(
//    _scrollController.position.minScrollExtent,
//    _scrollController.position.maxScrollExtent,
//  );

//  // JUMP the scrollbar to that position. This forces the widget to be built.
//  _scrollController.jumpTo(clampedOffset);

//  // In the VERY NEXT frame, request focus now that the widget exists.
//  WidgetsBinding.instance.addPostFrameCallback((_) {
//    if (mounted) {
//   FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//    }
//  });
//   }
//    }
//  });

//  // Step 3: Finally, start the timer to hide the controls again after a delay.
//  // स्टेप 3: अंत में, कंट्रोल्स को फिर से छिपाने के लिए टाइमर शुरू करें।
//  _startHideControlsTimer();
//   }

//   // void _resetHideControlsTimer() {
//   //   // Set initial focus and scroll
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //  if (widget.channelList.isEmpty) {
//   //    FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//   //  } else {
//   //    FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//   //    _scrollToFocusedItem();
//   //  }
//   //   });
//   //   _hideControlsTimer.cancel();
//   //   setState(() {
//   //  _controlsVisible = true;
//   //   });
//   //   _startHideControlsTimer();
//   // }

//   void _startHideControlsTimer() {
//  _hideControlsTimer = Timer(Duration(seconds: 10), () {
//    setState(() {
//   _controlsVisible = false;
//    });
//  });
//   }

//   int _accumulatedSeekForward = 0;
//   int _accumulatedSeekBackward = 0;
//   Timer? _seekTimer;
//   Duration _previewPosition = Duration.zero;
//   final _seekDuration = 30; // seconds
//   final _seekDelay = 800; // milliseconds

//   void _seekForward() {
//  // if (_controller == null || !_controller!.value.isInitialized) return;
//  if (_controller == null ||
//   !_controller!.value.isInitialized ||
//   _controller!.value.duration <= Duration.zero) return;

//  _accumulatedSeekForward += _seekDuration;
//  final newPosition = _controller!.value.position +
//   Duration(seconds: _accumulatedSeekForward);

//  setState(() {
//    _previewPosition = newPosition > _controller!.value.duration
//  ? _controller!.value.duration
//  : newPosition;
//  });

//  _seekTimer?.cancel();
//  _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
//    // सीधे seekTo कॉल करने की बजाय _seekToPosition को कॉल करें
//    _seekToPosition(_previewPosition).then((_) {
//   setState(() {
//  _accumulatedSeekForward = 0;
//   });
//    });
//  });
//   }

// // इसी तरह _seekBackward को भी बदलें
//   void _seekBackward() {
//  // if (_controller == null || !_controller!.value.isInitialized) return;
//  if (_controller == null ||
//   !_controller!.value.isInitialized ||
//   _controller!.value.duration <= Duration.zero) return;

//  _accumulatedSeekBackward += _seekDuration;
//  final newPosition = _controller!.value.position -
//   Duration(seconds: _accumulatedSeekBackward);

//  setState(() {
//    _previewPosition =
//  newPosition > Duration.zero ? newPosition : Duration.zero;
//  });

//  _seekTimer?.cancel();
//  _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
//    _seekToPosition(_previewPosition).then((_) {
//   setState(() {
//  _accumulatedSeekBackward = 0;
//   });
//    });
//  });
//   }

// // void _seekForward() {
// //   if (_controller == null || !_controller!.value.isInitialized) return;

// //   setState(() {
// //  // Accumulate seek duration
// //  _accumulatedSeekForward += _seekDuration;
// //  // Update preview position instantly
// //  _previewPosition = _controller!.value.position + Duration(seconds: _accumulatedSeekForward);
// //  // Ensure preview position does not exceed video duration
// //  if (_previewPosition > _controller!.value.duration) {
// //    _previewPosition = _controller!.value.duration;
// //  }
// //   });

// //   // Reset and start timer to execute seek after delay
// //   _seekTimer?.cancel();
// //   _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
// //  if (_controller != null) {
// //    _controller!.seekTo(_previewPosition);
// //    setState(() {
// //   _accumulatedSeekForward = 0; // Reset accumulator after seek
// //    });
// //  }

// //  // // Update focus to forward button
// //  // Future.delayed(Duration(milliseconds: 50), () {
// //  //   FocusScope.of(context).requestFocus(forwardButtonFocusNode);
// //  // });
// //   });
// // }

// // void _seekBackward() {
// //   if (_controller == null || !_controller!.value.isInitialized) return;

// //   setState(() {
// //  // Accumulate seek duration
// //  _accumulatedSeekBackward += _seekDuration;
// //  // Update preview position instantly
// //  final newPosition = _controller!.value.position - Duration(seconds: _accumulatedSeekBackward);
// //  // Ensure preview position does not go below zero
// //  _previewPosition = newPosition > Duration.zero ? newPosition : Duration.zero;
// //   });

// //   // Reset and start timer to execute seek after delay
// //   _seekTimer?.cancel();
// //   _seekTimer = Timer(Duration(milliseconds: _seekDelay), () {
// //  if (_controller != null) {
// //    _controller!.seekTo(_previewPosition);
// //    setState(() {
// //   _accumulatedSeekBackward = 0; // Reset accumulator after seek
// //    });
// //  }

// //  // // Update focus to backward button
// //  // Future.delayed(Duration(milliseconds: 50), () {
// //  //   FocusScope.of(context).requestFocus(backwardButtonFocusNode);
// //  // });
// //   });
// // }

//   // void _handleKeyEvent(RawKeyEvent event) {
//   //   if (event is RawKeyDownEvent) {
//   //  _resetHideControlsTimer();

//   //  switch (event.logicalKey) {
//   //    case LogicalKeyboardKey.arrowUp:
//   //   _resetHideControlsTimer();
//   //   if (playPauseButtonFocusNode.hasFocus) {
//   //  Future.delayed(Duration(milliseconds: 50), () {
//   //    if (widget.liveStatus == false) {
//   //   FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//   //   // _scrollToFocusedItem();
//   //   _scrollListener();
//   //    }
//   //  });
//   //   } else if (_focusedIndex > 0) {
//   //  if (widget.channelList.isEmpty) return;
//   //  setState(() {
//   //    _focusedIndex--;
//   //    FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//   //    // _scrollToFocusedItem();
//   //    _scrollListener();
//   //  });
//   //   }
//   //   break;

//   //    case LogicalKeyboardKey.arrowDown:
//   //   _resetHideControlsTimer();
//   //   if (_focusedIndex < widget.channelList.length - 1) {
//   //  setState(() {
//   //    _focusedIndex++;
//   //    FocusScope.of(context).requestFocus(focusNodes[_focusedIndex]);
//   //    // _scrollToFocusedItem();
//   //    _scrollListener();
//   //  });
//   //   } else if (_focusedIndex < widget.channelList.length) {
//   //  Future.delayed(Duration(milliseconds: 50), () {
//   //    FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//   //  });
//   //   }
//   //   break;

//   //    case LogicalKeyboardKey.arrowRight:
//   //   _resetHideControlsTimer();

//   //   if (focusNodes.any((node) => node.hasFocus)) {
//   //  Future.delayed(Duration(milliseconds: 50), () {
//   //    FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//   //  });
//   //   } else if (playPauseButtonFocusNode.hasFocus) {
//   //  if (widget.liveStatus == false) {
//   //    _seekForward();
//   //  }
//   //   }
//   //   break;

//   //    case LogicalKeyboardKey.arrowLeft:
//   //   _resetHideControlsTimer();

//   //   if (playPauseButtonFocusNode.hasFocus) {
//   //  if (widget.liveStatus == false) {
//   //    _seekBackward();
//   //  }
//   //   } else if (focusNodes.any((node) => node.hasFocus)) {
//   //  Future.delayed(Duration(milliseconds: 50), () {
//   //    FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//   //  });
//   //   }
//   //   break;

//   //    case LogicalKeyboardKey.select:
//   //    case LogicalKeyboardKey.enter:
//   //   _resetHideControlsTimer();
//   //   if (playPauseButtonFocusNode.hasFocus) {
//   //  _togglePlayPause();
//   //  FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//   //   } else {
//   //  // if (widget.liveStatus) {
//   //  _onItemTap(_focusedIndex);
//   //  // } else {
//   //  // FocusScope.of(context).requestFocus(playPauseButtonFocusNode);
//   //  // }
//   //   }
//   //   break;
//   //  }
//   //   }
//   // }

//   // String _formatDuration(Duration duration) {
//   //   // Function to convert single digit to double digit string (e.g., 5 -> "05")
//   //   String twoDigits(int n) => n.toString().padLeft(2, '0');

//   //   // Get hours string only if hours > 0
//   //   String hours =
//   //    duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : '';

//   //   // Get minutes (00-59)
//   //   String minutes = twoDigits(duration.inMinutes.remainder(60));

//   //   // Get seconds (00-59)
//   //   String seconds = twoDigits(duration.inSeconds.remainder(60));

//   //   // Combine everything into final time string
//   //   return '$hours$minutes:$seconds';
//   // }

//   String _formatDuration(Duration duration) {
//  // Handles potential null or negative durations gracefully.
//  if (duration.isNegative) {
//    duration = Duration.zero;
//  }

//  // Function to pad a single digit with a leading zero (e.g., 5 -> "05").
//  String twoDigits(int n) => n.toString().padLeft(2, '0');

//  // Extracts minutes and seconds, ensuring they are within the 0-59 range.
//  final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//  final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

//  // If the duration is an hour or more, format as HH:MM:SS.
//  // if (duration.inHours > 0) {
//  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//  // }
//  // Otherwise, format as MM:SS.
//  // else {
//  //   return "$twoDigitMinutes:$twoDigitSeconds";
//  // }
//   }

//   Widget _buildVideoPlayer() {
//  if (!_isVideoInitialized || _controller == null) {
//    return Center(child: CircularProgressIndicator());
//  }

//  return LayoutBuilder(
//    builder: (context, constraints) {
//   // Get screen dimensions
//   final screenWidth = constraints.maxWidth;
//   final screenHeight = constraints.maxHeight;

//   // Get video dimensions
//   final videoWidth = _controller!.value.size?.width ?? screenWidth;
//   final videoHeight = _controller!.value.size?.height ?? screenHeight;

//   // Calculate aspect ratios
//   final videoRatio = videoWidth / videoHeight;
//   final screenRatio = screenWidth / screenHeight;

//   // Default scale factors
//   double scaleX = 1.0;
//   double scaleY = 1.0;

//   // Calculate optimal scaling
//   if (videoRatio < screenRatio) {
//  // Video is too narrow, scale width while maintaining aspect ratio
//  scaleX = (screenRatio / videoRatio).clamp(1.0, 1.35);
//  // Adjust height if width scaling is too aggressive
//  if (scaleX > 1.2) {
//    scaleY = (1.0 / (scaleX - 1.0)).clamp(0.85, 1.0);
//  }
//   } else {
//  // Video is too wide, scale height while maintaining aspect ratio
//  scaleY = (videoRatio / screenRatio).clamp(0.85, 1.0);
//  scaleX = scaleX.clamp(1.0, 1.35); // Limit horizontal scaling
//   }

//   return Container(
//  width: screenWidth,
//  height: screenHeight,
//  color: Colors.black,
//  child: Center(
//    child: Transform(
//   transform: Matrix4.identity()..scale(scaleX, scaleY, 1.0),
//   alignment: Alignment.center,
//   child: VlcPlayer(
//  controller: _controller!,
//  placeholder: Center(child: CircularProgressIndicator()),
//  aspectRatio: 16 / 9,
//   ),
//    ),
//  ),
//   );
//    },
//  );
//   }

//   // <-- ये दो नए मेथड्स अपने क्लास में कहीं भी जोड़ें

//   void _startSafeDisposal() {
//  if (_isDisposing || _isDisposed) return;

//  print('Starting safe disposal for VideoScreen...');
//  setState(() {
//    _isDisposing = true;
//  });

//  // सभी टाइमर्स को रद्द करें
//  _connectivityCheckTimer?.cancel();
//  _hideControlsTimer.cancel();
//  // _volumeIndicatorTimer?.cancel();
//  _networkCheckTimer?.cancel();

//  // कंट्रोलर को बैकग्राउंड में डिस्पोज़ करें
//  _disposeControllerInBackground();
//   }

//   // void _disposeControllerInBackground() {
//   //   // Future.microtask यह सुनिश्चित करता है कि यह काम UI थ्रेड को ब्लॉक किए बिना हो
//   //   Future.microtask(() async {
//   //  print('Background controller disposal started...');
//   //  try {
//   //    if (_controller != null) {
//   //   _controller?.removeListener(_vlcListener);
//   //   // टाइमआउट के साथ स्टॉप और डिस्पोज़ करें ताकि ऐप अटके नहीं
//   //   await _controller?.stop().timeout(const Duration(seconds: 2));
//   //   await _controller?.dispose().timeout(const Duration(seconds: 2));
//   //   print('VLC Controller disposed successfully in background.');
//   //    }
//   //  } catch (e) {
//   //    print('Error during background controller disposal: $e');
//   //  } finally {
//   //    // सुनिश्चित करें कि नियंत्रक को अंत में null पर सेट किया गया है
//   //    _controller = null;
//   //    _isDisposed = true;
//   //  }
//   //   });
//   // }

//   void _disposeControllerInBackground() {
//  Future.microtask(() async {
//    print('Background controller disposal started...');
//    try {
//   if (_controller != null) {
//  _controller?.removeListener(_vlcListener);
//  await _controller?.stop().timeout(const Duration(seconds: 2));
//  await _controller?.dispose().timeout(const Duration(seconds: 2));
//  print('VLC Controller disposed successfully in background.');
//   }
//    } catch (e) {
//   print('Error during background controller disposal: $e');
//    } finally {
//   _controller = null;
//   _isDisposed = true;

//   // <-- ⭐ मुख्य बदलाव: क्लीनअप पूरा होने का सिग्नल भेजें
//   if (!_cleanupCompleter.isCompleted) {
//  _cleanupCompleter.complete();
//   }
//    }
//  });
//   }

//   @override
//   Widget build(BuildContext context) {
//  return
//   // WillPopScope(
//   //  onWillPop: () async {
//   //    // अगर पहले से डिस्पोज़ हो रहा है तो कुछ न करें
//   //    if (_isDisposing || _isDisposed) {
//   //   return true;
//   //    }

//   //    // सुरक्षित डिस्पोज़ल प्रक्रिया शुरू करें
//   //    _startSafeDisposal();

//   //    // Flutter को तुरंत स्क्रीन बंद करने की अनुमति दें
//   //    return true;
//   //  },
//   // WillPopScope(
//    // // onWillPop को async बनाएं और नया लॉजिक लागू करें
//    // onWillPop: () async {
//    //   // अगर क्लीनअप पहले से चल रहा है, तो यूजर को दोबारा बैक दबाने से रोकें
//    //   if (_isDisposing) {
//    //  print("Cleanup already in progress. Ignoring back press.");
//    //  return false;
//    //   }

//    //   print("Back button pressed. Starting safe disposal...");
//    //   // सुरक्षित डिस्पोजल प्रक्रिया शुरू करें
//    //   _startSafeDisposal();

//    //   // (वैकल्पिक) यूजर को फीडबैक देने के लिए एक लोडिंग इंडिकेटर दिखाएं
//    //   setState(() {
//    //  _loadingVisible = true; // या एक नया bool `_isCleaningUp` बनाएं
//    //   });

//    //   // क्लीनअप पूरा होने तक यहीं रुकें
//    //   // The await here is the key. It pauses execution.
//    //   await _cleanupCompleter.future;

//    //   print("Cleanup complete. Allowing navigation back.");
//    //   // जब क्लीनअप पूरा हो जाए, तो Flutter को स्क्रीन पॉप करने की अनुमति दें
//    //   return true;
//    // },
//    WillPopScope(
//  onWillPop: () async {
//    print("🔙 Back button pressed. Starting safe disposal...");

//    // 1. यूजर को फीडबैक देने के लिए लोडिंग इंडिकेटर दिखाएं
//    setState(() {
//   _loadingVisible = true;
//    });

//    // 2. प्लेयर को सुरक्षित रूप से डिस्पोज़ करें
//    // try-catch ब्लॉक का उपयोग करें ताकि कोई एरर आने पर ऐप क्रैश न हो
//    try {
//   if (_controller != null && _controller!.value.isInitialized) {
//  await _controller?.stop();
//  await _controller?.dispose();
//  print("✅ VLC Controller disposed successfully.");
//   }
//    } catch (e) {
//   print("❌ Error during manual dispose: $e");
//    }

//    // 3. सभी टाइमर और लिसनर्स को रद्द करें
//    _hideControlsTimer.cancel();
//    _networkCheckTimer?.cancel();
//    _connectivityCheckTimer?.cancel();
//    KeepScreenOn.turnOff();

//    // 4. Flutter को स्क्रीन पॉप करने की अनुमति दें
//    // 'true' लौटने का मतलब है कि अब पीछे जाना सुरक्षित है
//    return true;
//  },
//    child: Scaffold(
//   backgroundColor: Colors.black,
//   body: Padding(
//  padding: const EdgeInsets.all(1.0),
//  child: SizedBox(
//    width: screenwdt,
//    height: screenhgt,
//    child: Focus(
//   // focusNode: screenFocusNode,
//   onKey: (node, event) {
//  if (event is RawKeyDownEvent) {
//    _handleKeyEvent(event);
//    return KeyEventResult.handled;
//  }
//  return KeyEventResult.ignored;
//   },
//   child: GestureDetector(
//  onTap: _resetHideControlsTimer,
//  child: Stack(
//    children: [
//   // Video Player - यहाँ नया implementation जोड़ा गया है
//   if (_isVideoInitialized && _controller != null)
//  _buildVideoPlayer(), // नया _buildVideoPlayer method का उपयोग

//   // Loading Indicator
//   if (_loadingVisible || !_isVideoInitialized)
//  Container(
//    color: Colors.black54,
//    child: Center(
//  child: RainbowPage(
//   backgroundColor:
//    Colors.black, // हल्का नीला बैकग्राउंड
//    )),
//  ),
//   // Loading Indicator
//   if (_isBuffering)
//  Container(
//    color: Colors.transparent,
//    child: Center(
//  child: RainbowPage(
//   backgroundColor:
//    Colors.transparent, // हल्का नीला बैकग्राउंड
//    )),
//  ),

//   // Channel List
//   if (_controlsVisible && !widget.channelList.isEmpty)
//  _buildChannelList(),

//   // Controls
//   // if (_controlsVisible)
//   _buildControls(),
//    ],
//  ),
//   ),
//    ),
//  ),
//   ),
//    ));
//   }

//   Widget _buildChannelList() {
//  return Positioned(
//    top: MediaQuery.of(context).size.height * 0.02,
//    bottom: MediaQuery.of(context).size.height * 0.1,
//    left: MediaQuery.of(context).size.width * 0.0,
//    right: MediaQuery.of(context).size.width * 0.78,
//    child: Container(
//   // height: MediaQuery.of(context).size.height * 0.75,
//   // color: Colors.black.withOpacity(0.3),
//   child: ListView.builder(
//  controller: _scrollController,
//  itemCount: widget.channelList.length,
//  itemBuilder: (context, index) {
//    final channel = widget.channelList[index];
//    // Handle different channel ID formats
//    // final String channelId = widget.isBannerSlider
//    //  ? (channel['contentId']?.toString() ?? channel.contentId?.toString() ?? '')
//    //  : (channel['id']?.toString() ?? channel.id?.toString() ?? '');

//    final String channelId =
//  // widget.isBannerSlider
//  //  ? (channel.contentId?.toString() ??
//  //   channel.contentId?.toString() ??
//  //   '')
//  //  :
//  (channel.id?.toString() ?? channel.id?.toString() ?? '');
//    // Handle banner for both map and object access
//    final String? banner = channel is Map
//  ? channel['banner']?.toString()
//  : channel.banner?.toString();
//    final bool isBase64 =
//  channel.banner?.startsWith('data:image') ?? false;

//    return Padding(
//   padding:
//    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//   child: Focus(
//  focusNode: focusNodes[index],
//  onFocusChange: (hasFocus) {
//    if (hasFocus) {
//   print("✅ FOCUS GAINED: Channel list item at index $index");
//   // When an item gains focus, ensure it's visible.
//   _scrollToFocusedItem();
//    }
//  },
//  child: GestureDetector(
//    onTap: () {
//   _onItemTap(index);
//   _resetHideControlsTimer();
//    },
//    child: Container(
//   width: screenwdt * 0.3,
//   height: screenhgt * 0.18,
//   decoration: BoxDecoration(
//  border: Border.all(
//    color: playPauseButtonFocusNode.hasFocus
//  ? Colors.transparent
//  : _focusedIndex == index
//   ? const Color.fromARGB(211, 155, 40, 248)
//   : Colors.transparent,
//    width: 5.0,
//  ),
//  borderRadius: BorderRadius.circular(10),
//  color: _focusedIndex == index
//   ? Colors.black26
//   : Colors.transparent,
//   ),
//   child: ClipRRect(
//  borderRadius: BorderRadius.circular(6),
//  child: Stack(
//    children: [
//   Positioned.fill(
//  child: Opacity(
//    opacity: 0.6,
//    child: isBase64
//  ?
//  // Image.memory(
//  //  _getImageFromBase64String(
//  //   channel.banner ?? ''),
//  //  fit: BoxFit.cover,
//  //  errorBuilder:
//  //   (context, error, stackTrace) =>
//  //    Container(color: Colors.grey[800]),
//  //   )
//  // Image.memory(
//  //  _getCachedImage(
//  //   channel.banner ?? localImage),
//  //  fit: BoxFit.cover,
//  //  errorBuilder:
//  //   (context, error, stackTrace) =>
//  //    localImage,
//  //   )
//  // :
//  Image.memory(
//   _bannerCache[channelId] ??
//    _getCachedImage(
//  channel.banner ?? localImage),
//   fit: BoxFit.cover,
//   errorBuilder: (context, error,
//  stackTrace) =>
//    Image.asset('assets/placeholder.png'),
//    )
//  : CachedNetworkImage(
//   imageUrl: channel.banner ?? localImage,
//   fit: BoxFit.cover,
//   // errorWidget: (context, url, error) =>
//   //  localImage,
//    ),
//  ),
//   ),
//   if (_focusedIndex == index)
//  Positioned.fill(
//    child: Container(
//   decoration: BoxDecoration(
//  gradient: LinearGradient(
//    begin: Alignment.topCenter,
//    end: Alignment.bottomCenter,
//    colors: [
//   Colors.transparent,
//   Colors.black.withOpacity(0.9),
//    ],
//  ),
//   ),
//    ),
//  ),
//   if (_focusedIndex == index)
//  Positioned(
//    left: 8,
//    bottom: 8,
//    child: Text(
//   channel.name ?? '',
//   style: TextStyle(
//  color: Colors.white,
//  fontSize: 16,
//  fontWeight: FontWeight.bold,
//   ),
//    ),
//  ),
//    ],
//  ),
//   ),
//    ),
//  ),
//   ),
//    );
//  },
//   ),
//    ),
//  );
//   }

//   Widget _buildControls() {
//  // Determine the current position to display.
//  // During seek, it shows the preview position; otherwise, it shows the actual playback position.
//  final Duration currentPosition =
//   _accumulatedSeekForward > 0 || _accumulatedSeekBackward > 0
//    ? _previewPosition
//    : _controller?.value.position ?? Duration.zero;

//  // Get the total duration of the video.
//  final Duration totalDuration = _controller?.value.duration ?? Duration.zero;

//  return Positioned(
//    bottom: 0,
//    left: 0,
//    right: 0,
//    child: Column(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: [
//  Opacity(
//    opacity: _controlsVisible ? 1 : 0.01,
//    child: Container(
//   color: Colors.black54,
//   padding: const EdgeInsets.symmetric(vertical: 4.0),
//   child: Row(
//  mainAxisAlignment: MainAxisAlignment.start,
//  crossAxisAlignment: CrossAxisAlignment.center,
//  children: [
//    SizedBox(width: screenwdt * 0.03), // Left padding

//    // Play/Pause Button
//    Container(
//   color: playPauseButtonFocusNode.hasFocus
//    ? const Color.fromARGB(200, 16, 62, 99)
//    : Colors.transparent,
//   child: Center(
//  child: Focus(
//    focusNode: playPauseButtonFocusNode,
//    onFocusChange: (hasFocus) {
//   if (hasFocus) {
//  print("✅ FOCUS GAINED: Play/Pause button");
//   }
//   setState(() {}); // Rebuild to update color
//    },
//    // onFocusChange: (hasFocus) {
//    //   setState(() {});
//    // },
//    child: IconButton(
//   icon: Image.asset(
//  (_controller?.value.isPlaying ?? false)
//   ? 'assets/pause.png' // Pause icon
//   : 'assets/play.png', // Play icon
//  width: 35,
//  height: 35,
//   ),
//   onPressed: _togglePlayPause,
//    ),
//  ),
//   ),
//    ),

//    // NEW: Display Current Position (only for VOD)
//    if (widget.liveStatus == false)
//   Padding(
//  padding: const EdgeInsets.symmetric(horizontal: 12.0),
//  child: Text(
//    _formatDuration(
//  currentPosition), // Shows live seek position
//    style: const TextStyle(
//   color: Colors.white,
//   fontSize: 18,
//   fontWeight: FontWeight.bold,
//    ),
//  ),
//   ),

//    // Progress Bar
//    Expanded(
//   flex: 10,
//   child: Center(
//  child: Focus(
//    onFocusChange: (hasFocus) {
//   setState(() {});
//    },
//    child: Container(
//  color: Colors.transparent,
//  child: _buildBeautifulProgressBar1()),
//  ),
//   ),
//    ),

//    // NEW: Display Total Duration (only for VOD)
//    if (widget.liveStatus == false)
//   Padding(
//  padding: const EdgeInsets.symmetric(horizontal: 12.0),
//  child: Text(
//    _formatDuration(totalDuration),
//    style: const TextStyle(
//   color: Colors.white,
//   fontSize: 18,
//   fontWeight: FontWeight.bold,
//    ),
//  ),
//   ),

//    // "Live" indicator (only for Live streams)
//    if (widget.liveStatus == true)
//   Expanded(
//  flex: 1, // Give it some space
//  child: Center(
//    child: Row(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: const [
//  Icon(Icons.circle, color: Colors.red, size: 15),
//  SizedBox(width: 5),
//  Text(
//    'Live',
//    style: TextStyle(
//   color: Colors.red,
//   fontSize: 20,
//   fontWeight: FontWeight.bold,
//    ),
//  ),
//   ],
//    ),
//  ),
//   ),
//    SizedBox(width: screenwdt * 0.03), // Right padding
//  ],
//   ),
//    ),
//  ),
//   ],
//    ),
//  );
//   }

// // Option 1: Gradient Progress Bar with Glow Effect
//   Widget _buildBeautifulProgressBar1() {
//  final totalDurationMs =
//   _controller?.value.duration.inMilliseconds.toDouble() ?? 1.0;

//  if (totalDurationMs <= 0) {
//    return Container(
//  height: 8,
//  decoration: BoxDecoration(
//   color: Colors.grey[800], borderRadius: BorderRadius.circular(4)));
//  }

//  final Duration displayPosition =
//   _accumulatedSeekForward > 0 || _accumulatedSeekBackward > 0
//    ? _previewPosition
//    : _controller?.value.position ?? Duration.zero;

//  double playedProgress =
//   (displayPosition.inMilliseconds / totalDurationMs).clamp(0.0, 1.0);
//  double bufferedProgress = (playedProgress + 0.005).clamp(0.0, 1.0);

//  return Container(
//    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//    child: Container(
//   height: 8,
//   decoration: BoxDecoration(
//  borderRadius: BorderRadius.circular(4),
//  boxShadow: [
//    BoxShadow(
//   color: Colors.black.withOpacity(0.3),
//   blurRadius: 4,
//   offset: Offset(0, 2),
//    ),
//  ],
//   ),
//   child: ClipRRect(
//  borderRadius: BorderRadius.circular(4),
//  child: Stack(
//    children: [
//   // Background
//   Container(
//  width: double.infinity,
//  decoration: BoxDecoration(
//    gradient: LinearGradient(
//   colors: [Colors.grey[800]!, Colors.grey[700]!],
//    ),
//  ),
//   ),
//   // Buffered progress
//   FractionallySizedBox(
//  widthFactor: bufferedProgress,
//  child: Container(
//    decoration: BoxDecoration(
//   gradient: LinearGradient(
//  colors: [Colors.grey[600]!, Colors.grey[500]!],
//   ),
//    ),
//  ),
//   ),
//   // Played progress with gradient
//   FractionallySizedBox(
//  widthFactor: playedProgress,
//  child: Container(
//    decoration: BoxDecoration(
//   gradient: LinearGradient(
//  colors: [
//    Color(0xFF9B28F8), // Purple
//    Color(0xFFE62B1E), // Red
//    Color(0xFFFF6B35), // Orange
//  ],
//  stops: [0.0, 0.7, 1.0],
//   ),
//   boxShadow: [
//  BoxShadow(
//    color: Color(0xFF9B28F8).withOpacity(0.6),
//    blurRadius: 8,
//    spreadRadius: 1,
//  ),
//   ],
//    ),
//  ),
//   ),
//    ],
//  ),
//   ),
//    ),
//  );
//   }

// // Option 2: Modern Rounded Progress with Thumb
//   Widget _buildBeautifulProgressBar2() {
//  final totalDurationMs =
//   _controller?.value.duration.inMilliseconds.toDouble() ?? 1.0;

//  if (totalDurationMs <= 0) {
//    return Container(
//  height: 8,
//  decoration: BoxDecoration(
//   color: Colors.grey[800], borderRadius: BorderRadius.circular(4)));
//  }

//  final Duration displayPosition =
//   _accumulatedSeekForward > 0 || _accumulatedSeekBackward > 0
//    ? _previewPosition
//    : _controller?.value.position ?? Duration.zero;

//  double playedProgress =
//   (displayPosition.inMilliseconds / totalDurationMs).clamp(0.0, 1.0);

//  return Container(
//    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
//    child: LayoutBuilder(
//   builder: (context, constraints) {
//  double progressWidth = constraints.maxWidth * playedProgress;

//  return Container(
//    height: 6,
//    decoration: BoxDecoration(
//   borderRadius: BorderRadius.circular(3),
//   color: Colors.white.withOpacity(0.2),
//    ),
//    child: Stack(
//   children: [
//  // Progress track
//  Container(
//    width: progressWidth,
//    decoration: BoxDecoration(
//   borderRadius: BorderRadius.circular(3),
//   gradient: LinearGradient(
//  colors: [
//    Color(0xFF00C9FF),
//    Color(0xFF92FE9D),
//  ],
//   ),
//    ),
//  ),
//  // Thumb/Handle
//  if (playedProgress > 0)
//    Positioned(
//   left: progressWidth - 8,
//   top: -4,
//   child: Container(
//  width: 16,
//  height: 16,
//  decoration: BoxDecoration(
//    shape: BoxShape.circle,
//    gradient: RadialGradient(
//   colors: [
//  Colors.white,
//  Color(0xFF00C9FF),
//   ],
//    ),
//    boxShadow: [
//   BoxShadow(
//  color: Color(0xFF00C9FF).withOpacity(0.5),
//  blurRadius: 8,
//  spreadRadius: 2,
//   ),
//    ],
//  ),
//   ),
//    ),
//   ],
//    ),
//  );
//   },
//    ),
//  );
//   }

// // Option 3: Neon Style Progress Bar
//   Widget _buildBeautifulProgressBar3() {
//  final totalDurationMs =
//   _controller?.value.duration.inMilliseconds.toDouble() ?? 1.0;

//  if (totalDurationMs <= 0) {
//    return Container(
//  height: 8,
//  decoration: BoxDecoration(
//   color: Colors.grey[800], borderRadius: BorderRadius.circular(4)));
//  }

//  final Duration displayPosition =
//   _accumulatedSeekForward > 0 || _accumulatedSeekBackward > 0
//    ? _previewPosition
//    : _controller?.value.position ?? Duration.zero;

//  double playedProgress =
//   (displayPosition.inMilliseconds / totalDurationMs).clamp(0.0, 1.0);
//  double bufferedProgress = (playedProgress + 0.03).clamp(0.0, 1.0);

//  return Container(
//    padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
//    child: Container(
//   height: 4,
//   decoration: BoxDecoration(
//  borderRadius: BorderRadius.circular(2),
//  color: Colors.black.withOpacity(0.8),
//  border: Border.all(
//    color: Colors.cyan.withOpacity(0.3),
//    width: 0.5,
//  ),
//   ),
//   child: ClipRRect(
//  borderRadius: BorderRadius.circular(2),
//  child: Stack(
//    children: [
//   // Buffered (subtle glow)
//   FractionallySizedBox(
//  widthFactor: bufferedProgress,
//  child: Container(
//    decoration: BoxDecoration(
//   color: Colors.cyan.withOpacity(0.2),
//   boxShadow: [
//  BoxShadow(
//    color: Colors.cyan.withOpacity(0.1),
//    blurRadius: 4,
//    spreadRadius: 1,
//  ),
//   ],
//    ),
//  ),
//   ),
//   // Played (neon effect)
//   FractionallySizedBox(
//  widthFactor: playedProgress,
//  child: Container(
//    decoration: BoxDecoration(
//   gradient: LinearGradient(
//  colors: [
//    Color(0xFF00FFFF), // Cyan
//    Color(0xFF1E90FF), // Blue
//    Color(0xFF9B59B6), // Purple
//  ],
//   ),
//   boxShadow: [
//  BoxShadow(
//    color: Color(0xFF00FFFF).withOpacity(0.8),
//    blurRadius: 12,
//    spreadRadius: 2,
//  ),
//  BoxShadow(
//    color: Color(0xFF1E90FF).withOpacity(0.6),
//    blurRadius: 6,
//    spreadRadius: 1,
//  ),
//   ],
//    ),
//  ),
//   ),
//    ],
//  ),
//   ),
//    ),
//  );
//   }

// // Option 4: Glass Morphism Style
//   Widget _buildBeautifulProgressBar4() {
//  final totalDurationMs =
//   _controller?.value.duration.inMilliseconds.toDouble() ?? 1.0;

//  if (totalDurationMs <= 0) {
//    return Container(
//  height: 8,
//  decoration: BoxDecoration(
//   color: Colors.grey[800], borderRadius: BorderRadius.circular(4)));
//  }

//  final Duration displayPosition =
//   _accumulatedSeekForward > 0 || _accumulatedSeekBackward > 0
//    ? _previewPosition
//    : _controller?.value.position ?? Duration.zero;

//  double playedProgress =
//   (displayPosition.inMilliseconds / totalDurationMs).clamp(0.0, 1.0);

//  return Container(
//    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
//    child: Container(
//   height: 10,
//   decoration: BoxDecoration(
//  borderRadius: BorderRadius.circular(5),
//  color: Colors.white.withOpacity(0.1),
//  border: Border.all(
//    color: Colors.white.withOpacity(0.2),
//    width: 1,
//  ),
//  boxShadow: [
//    BoxShadow(
//   color: Colors.black.withOpacity(0.1),
//   blurRadius: 10,
//   offset: Offset(0, 4),
//    ),
//  ],
//   ),
//   child: ClipRRect(
//  borderRadius: BorderRadius.circular(5),
//  child: Stack(
//    children: [
//   // Background blur effect
//   Container(
//  width: double.infinity,
//  decoration: BoxDecoration(
//    gradient: LinearGradient(
//   colors: [
//  Colors.white.withOpacity(0.05),
//  Colors.white.withOpacity(0.1),
//   ],
//    ),
//  ),
//   ),
//   // Progress
//   FractionallySizedBox(
//  widthFactor: playedProgress,
//  child: Container(
//    decoration: BoxDecoration(
//   gradient: LinearGradient(
//  colors: [
//    Colors.white.withOpacity(0.8),
//    Colors.white.withOpacity(0.6),
//  ],
//   ),
//   boxShadow: [
//  BoxShadow(
//    color: Colors.white.withOpacity(0.3),
//    blurRadius: 10,
//    spreadRadius: 2,
//  ),
//   ],
//    ),
//  ),
//   ),
//    ],
//  ),
//   ),
//    ),
//  );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:keep_screen_on/keep_screen_on.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';
// import 'video_player_service.dart'; // <-- 1. नई सर्विस को इम्पोर्ट करें

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
//  required this.videoUrl,
//  required this.updatedAt,
//  required this.channelList,
//  required this.bannerImageUrl,
//  required this.videoId,
//  required this.source,
//  required this.name,
//  required this.liveStatus,
//   });

//   @override
//   _VideoScreenState createState() => _VideoScreenState();
// }

// class _VideoScreenState extends State<VideoScreen> {
//   // --- ✅ बदलाव 1: प्लेयर को सीधे सर्विस से प्राप्त करें ---
//   late final Player player = VideoPlayerService.player;
//   late final VideoController controller;
//   final FocusNode _focusNode = FocusNode();

//   // ... (बाकी के वेरिएबल्स वैसे ही रहेंगे) ...
//   bool _controlsVisible = true;
//   Timer? _hideControlsTimer;
//   Timer? _continuousSeekTimer;
//   int _seekDirection = 0;

//   @override
//   void initState() {
//  super.initState();
//  // player = Player();  // <-- 2. इस लाइन को हटा दें
//  controller = VideoController(player);

//  // यह सुनिश्चित करेगा कि पिछला वीडियो बंद हो जाए और नया शुरू हो
//  player.open(Media(widget.videoUrl), play: true);

//  KeepScreenOn.turnOn();
//  WidgetsBinding.instance.addPostFrameCallback((_) {
//    FocusScope.of(context).requestFocus(_focusNode);
//  });
//  _startHideControlsTimer();
//   }

//   @override
//   void dispose() {
//  _hideControlsTimer?.cancel();
//  _continuousSeekTimer?.cancel();

//  // --- ✅ बदलाव 2: प्लेयर को dispose न करें, बस रोक दें ---
//  // player.dispose(); // <-- 3. इस लाइन को हटा दें! यह बहुत महत्वपूर्ण है।
//  player.stop(); // बेहतर प्रैक्टिस: स्क्रीन से बाहर जाने पर वीडियो को रोक दें।

//  _focusNode.dispose();
//  KeepScreenOn.turnOff();
//  super.dispose();
//   }

//   // ... (बाकी का सारा कोड _handleKeyEvent, build, आदि वैसा ही रहेगा) ...

//   // --- Controls Visibility Logic ---
//   void _resetHideControlsTimer() {
//  if (!_controlsVisible) {
//    setState(() {
//   _controlsVisible = true;
//    });
//  }
//  _hideControlsTimer?.cancel();
//  _startHideControlsTimer();
//   }

//   void _startHideControlsTimer() {
//  _hideControlsTimer = Timer(const Duration(seconds: 5), () {
//    if (mounted) {
//   setState(() {
//  _controlsVisible = false;
//   });
//    }
//  });
//   }

//   // --- Continuous Seeking Logic ---
//   void _startContinuousSeek(bool forward) {
//  if (widget.liveStatus) return;

//  final direction = forward ? 1 : -1;
//  if (_seekDirection == direction) return;

//  _seekDirection = direction;
//  _performSeekStep();

//  _continuousSeekTimer?.cancel();
//  _continuousSeekTimer =
//   Timer.periodic(const Duration(milliseconds: 100), (timer) {
//    _performSeekStep();
//  });
//   }

//   void _performSeekStep() {
//  final currentPosition = player.state.position;
//  final totalDuration = player.state.duration;
//  final seekAmount = Duration(seconds: 30); // You might want to make this smaller for faster feedback

//  var newPosition = currentPosition + (seekAmount * _seekDirection);

//  if (newPosition < Duration.zero) newPosition = Duration.zero;
//  if (newPosition > totalDuration) newPosition = totalDuration;

//  player.seek(newPosition);
//   }

//   void _stopContinuousSeek() {
//  _continuousSeekTimer?.cancel();
//  _seekDirection = 0;
//   }

//   // --- Keyboard Event Handler ---
//   KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
//  _resetHideControlsTimer();

//  if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
//   event.logicalKey == LogicalKeyboardKey.arrowRight) {
//    if (event is KeyDownEvent) {
//   _startContinuousSeek(event.logicalKey == LogicalKeyboardKey.arrowRight);
//    } else if (event is KeyUpEvent) {
//   _stopContinuousSeek();
//    }
//    return KeyEventResult.handled;
//  }

//  if (event is KeyDownEvent) {
//    _stopContinuousSeek();
//  }

//  if (event is KeyDownEvent &&
//   (event.logicalKey == LogicalKeyboardKey.select ||
//    event.logicalKey == LogicalKeyboardKey.enter)) {
//    player.playOrPause();
//    return KeyEventResult.handled;
//  }

//  return KeyEventResult.ignored;
//   }

//   // --- Helper to format Duration ---
//   String _formatDuration(Duration duration) {
//  String twoDigits(int n) => n.toString().padLeft(2, '0');
//  final hours = duration.inHours;
//  final minutes = duration.inMinutes.remainder(60);
//  final seconds = duration.inSeconds.remainder(60);
//  return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
//   }

//   // --- Main Build Method ---
//   @override
//   Widget build(BuildContext context) {
//  return Focus(
//    focusNode: _focusNode,
//    autofocus: true,
//    onKeyEvent: _handleKeyEvent,
//    child: GestureDetector(
//   onTap: _resetHideControlsTimer,
//   child: Scaffold(
//  backgroundColor: Colors.black,
//  body: Center(
//    child: SizedBox(
//   width: MediaQuery.of(context).size.width,
//   height: MediaQuery.of(context).size.width * 9.0 / 16.0,
//   child: Stack(
//  alignment: Alignment.bottomCenter,
//  children: [
//    Video(
//   controller: controller,
//   fit: BoxFit.contain,
//    ),
//    AnimatedOpacity(
//   opacity: _controlsVisible ? 1.0 : 0.0,
//   duration: const Duration(milliseconds: 300),
//   child: _buildCustomControls(),
//    ),
//  ],
//   ),
//    ),
//  ),
//   ),
//    ),
//  );
//   }

//   // --- UI Helper Widgets ---
//   Widget _buildCustomControls() {
//  return IgnorePointer(
//    child: Container(
//   color: Colors.black.withOpacity(0.5),
//   padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//   child: StreamBuilder<Duration>(
//  stream: player.stream.position,
//  builder: (context, snapshot) {
//    final Duration position = snapshot.data ?? Duration.zero;
//    final Duration duration = player.state.duration;
//    final displayPosition = position;

//    return Row(
//   children: [
//  const SizedBox(width: 16),
//  if (widget.liveStatus)
//    Row(
//   children: const [
//  Icon(Icons.circle, color: Colors.red, size: 14),
//  SizedBox(width: 6),
//  Text(
//    'Live',
//    style: TextStyle(
//  color: Colors.red,
//  fontWeight: FontWeight.bold,
//  fontSize: 16),
//  ),
//   ],
//    )
//  else
//    Text(
//   _formatDuration(displayPosition),
//   style: const TextStyle(color: Colors.white, fontSize: 16),
//    ),
//  const SizedBox(width: 16),
//  Expanded(
//    child: _buildBeautifulProgressBar(displayPosition, duration),
//  ),
//  const SizedBox(width: 16),
//  if (!widget.liveStatus)
//    Text(
//   _formatDuration(duration),
//   style: const TextStyle(color: Colors.white, fontSize: 16),
//    ),
//  const SizedBox(width: 16),
//   ],
//    );
//  },
//   ),
//    ),
//  );
//   }

//   Widget _buildBeautifulProgressBar(Duration position, Duration duration) {
//  if (duration.inMilliseconds <= 0) {
//    return Container(
//  height: 8,
//  decoration: BoxDecoration(
//   color: Colors.grey[800], borderRadius: BorderRadius.circular(4)));
//  }
//  double progress =
//   (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
//  return Container(
//    height: 8,
//    decoration: BoxDecoration(
//   borderRadius: BorderRadius.circular(4),
//   boxShadow: [
//  BoxShadow(
//    color: Colors.black.withOpacity(0.3),
//    blurRadius: 4,
//    offset: Offset(0, 2),
//  ),
//   ],
//    ),
//    child: ClipRRect(
//   borderRadius: BorderRadius.circular(4),
//   child: Stack(
//  children: [
//    Container(
//   width: double.infinity,
//   decoration: BoxDecoration(
//  gradient: LinearGradient(
//    colors: [Colors.grey[800]!, Colors.grey[700]!],
//  ),
//   ),
//    ),
//    FractionallySizedBox(
//   widthFactor: progress,
//   child: Container(
//  decoration: BoxDecoration(
//    gradient: const LinearGradient(
//   colors: [
//  Color(0xFF9B28F8), // Purple
//  Color(0xFFE62B1E), // Red
//  Color(0xFFFF6B35), // Orange
//   ],
//   stops: [0.0, 0.7, 1.0],
//    ),
//    boxShadow: [
//   BoxShadow(
//  color: const Color(0xFF9B28F8).withOpacity(0.6),
//  blurRadius: 8,
//  spreadRadius: 1,
//   ),
//    ],
//  ),
//   ),
//    ),
//  ],
//   ),
//    ),
//  );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:keep_screen_on/keep_screen_on.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';
// import 'video_player_service.dart'; // Make sure this path is correct

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
//  required this.videoUrl,
//  required this.updatedAt,
//  required this.channelList,
//  required this.bannerImageUrl,
//  required this.videoId,
//  required this.source,
//  required this.name,
//  required this.liveStatus,
//   });

//   @override
//   _VideoScreenState createState() => _VideoScreenState();
// }

// class _VideoScreenState extends State<VideoScreen> {
//   late final Player player = VideoPlayerService.player;
//   late final VideoController controller;
//   final FocusNode _focusNode = FocusNode();

//   bool _controlsVisible = true;
//   Timer? _hideControlsTimer;

//   // --- 🔽 Continuous Seeking Variables 🔽 ---
//   Timer? _continuousSeekTimer;
//   int _seekDirection = 0; // 0 = रुका हुआ, 1 = आगे, -1 = पीछे
//   // --- 🔼 End of Seeking Variables 🔼 ---

//   @override
//   void initState() {
//  super.initState();
//  controller = VideoController(player);
//  player.open(Media(widget.videoUrl), play: true);

//  KeepScreenOn.turnOn();
//  WidgetsBinding.instance.addPostFrameCallback((_) {
//    FocusScope.of(context).requestFocus(_focusNode);
//  });
//  _startHideControlsTimer();
//   }

//   @override
//   void dispose() {
//  _hideControlsTimer?.cancel();
//  _continuousSeekTimer?.cancel(); // सीक टाइमर को भी कैंसिल करें
//  player.stop();
//  _focusNode.dispose();
//  KeepScreenOn.turnOff();
//  super.dispose();
//   }

//   void _resetHideControlsTimer() {
//  if (!_controlsVisible) {
//    setState(() {
//   _controlsVisible = true;
//    });
//  }
//  _hideControlsTimer?.cancel();
//  _startHideControlsTimer();
//   }

//   void _startHideControlsTimer() {
//  _hideControlsTimer = Timer(const Duration(seconds: 5), () {
//    if (mounted) {
//   setState(() {
//  _controlsVisible = false;
//   });
//    }
//  });
//   }

//   // --- ⚙️ NEW Continuous "Press and Hold" Seeking Logic ⚙️ ---
//   void _startContinuousSeek(bool forward) {
//  if (widget.liveStatus || _seekDirection != 0) return;

//  _seekDirection = forward ? 1 : -1;
//  _continuousSeekTimer?.cancel(); // पुराना टाइमर हटाएं

//  // हर 200 मिलीसेकंड में वीडियो को 5 सेकंड आगे या पीछे करें
//  _continuousSeekTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
//    final currentPosition = player.state.position;
//    final totalDuration = player.state.duration;
//    final seekAmount = Duration(seconds: 30) * _seekDirection;

//    var newPosition = currentPosition + seekAmount;

//    if (newPosition < Duration.zero) newPosition = Duration.zero;
//    if (newPosition > totalDuration) newPosition = totalDuration;

//    player.seek(newPosition);
//  });
//   }

//   void _stopContinuousSeek() {
//  _continuousSeekTimer?.cancel();
//  _seekDirection = 0;
//   }
//   // --- End of Seeking Logic ---

//   // --- ⚙️ UPDATED Keyboard Event Handler ⚙️ ---
//   KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
//  _resetHideControlsTimer();

//  // --- सीकिंग के लिए विशेष हैंडलिंग ---
//  if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
//   event.logicalKey == LogicalKeyboardKey.arrowRight) {

//    if (event is KeyDownEvent) {
//   // जब बटन दबे तो सीकिंग शुरू करें
//   _startContinuousSeek(event.logicalKey == LogicalKeyboardKey.arrowRight);
//    } else if (event is KeyUpEvent) {
//   // जब बटन छूटे तो सीकिंग रोक दें
//   _stopContinuousSeek();
//    }
//    return KeyEventResult.handled;
//  }

//  // अगर सीकिंग के अलावा कोई और बटन दबे, तो भी सीकिंग रोक दें
//  if (event is KeyDownEvent) {
//    _stopContinuousSeek();
//  }

//  // --- प्ले/पॉज़ के लिए हैंडलिंग ---
//  if (event is KeyDownEvent &&
//   (event.logicalKey == LogicalKeyboardKey.select ||
//    event.logicalKey == LogicalKeyboardKey.enter)) {
//    player.playOrPause();
//    return KeyEventResult.handled;
//  }
//  return KeyEventResult.ignored;
//   }

//   String _formatDuration(Duration duration) {
//  String twoDigits(int n) => n.toString().padLeft(2, '0');
//  final hours = duration.inHours;
//  final minutes = duration.inMinutes.remainder(60);
//  final seconds = duration.inSeconds.remainder(60);
//  return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
//   }

//   @override
//   Widget build(BuildContext context) {
//  return Focus(
//    focusNode: _focusNode,
//    autofocus: true,
//    onKeyEvent: _handleKeyEvent,
//    child: GestureDetector(
//   onTap: _resetHideControlsTimer,
//   child: Scaffold(
//  backgroundColor: Colors.black,
//  body: Center(
//    child: SizedBox(
//   width: MediaQuery.of(context).size.width,
//   height: MediaQuery.of(context).size.width * 9.0 / 16.0,
//   child: Stack(
//  alignment: Alignment.bottomCenter,
//  children: [
//    Video(
//   controller: controller,
//   fit: BoxFit.contain,
//    ),
//    AnimatedOpacity(
//   opacity: _controlsVisible ? 1.0 : 0.0,
//   duration: const Duration(milliseconds: 300),
//   child: _buildCustomControls(),
//    ),
//  ],
//   ),
//    ),
//  ),
//   ),
//    ),
//  );
//   }

//   Widget _buildCustomControls() {
//  return IgnorePointer(
//    child: Container(
//   color: Colors.black.withOpacity(0.5),
//   padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//   child: StreamBuilder<Duration>(
//  stream: player.stream.position,
//  builder: (context, snapshot) {
//    final position = snapshot.data ?? player.state.position;
//    final duration = player.state.duration;

//    return Row(
//   children: [
//  const SizedBox(width: 16),
//  if (widget.liveStatus)
//    Row(
//   children: const [
//  Icon(Icons.circle, color: Colors.red, size: 14),
//  SizedBox(width: 6),
//  Text(
//    'Live',
//    style: TextStyle(
//  color: Colors.red,
//  fontWeight: FontWeight.bold,
//  fontSize: 16),
//  ),
//   ],
//    )
//  else
//    Text(
//   _formatDuration(position),
//   style: const TextStyle(color: Colors.white, fontSize: 16),
//    ),
//  const SizedBox(width: 16),
//  Expanded(
//    child: _buildBeautifulProgressBar(position, duration),
//  ),
//  const SizedBox(width: 16),
//  if (!widget.liveStatus)
//    Text(
//   _formatDuration(duration),
//   style: const TextStyle(color: Colors.white, fontSize: 16),
//    ),
//  const SizedBox(width: 16),
//   ],
//    );
//  },
//   ),
//    ),
//  );
//   }

//   Widget _buildBeautifulProgressBar(Duration position, Duration duration) {
//  if (duration.inMilliseconds <= 0) {
//    return Container(
//  height: 8,
//  decoration: BoxDecoration(
//   color: Colors.grey[800], borderRadius: BorderRadius.circular(4)));
//  }
//  double progress =
//   (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
//  return Container(
//    height: 8,
//    decoration: BoxDecoration(
//   borderRadius: BorderRadius.circular(4),
//   boxShadow: [
//  BoxShadow(
//    color: Colors.black.withOpacity(0.3),
//    blurRadius: 4,
//    offset: Offset(0, 2),
//  ),
//   ],
//    ),
//    child: ClipRRect(
//   borderRadius: BorderRadius.circular(4),
//   child: Stack(
//  children: [
//    Container(
//   width: double.infinity,
//   decoration: BoxDecoration(
//  gradient: LinearGradient(
//    colors: [Colors.grey[800]!, Colors.grey[700]!],
//  ),
//   ),
//    ),
//    FractionallySizedBox(
//   widthFactor: progress,
//   child: Container(
//  decoration: BoxDecoration(
//    gradient: const LinearGradient(
//   colors: [
//  Color(0xFF9B28F8), // Purple
//  Color(0xFFE62B1E), // Red
//  Color(0xFFFF6B35), // Orange
//   ],
//   stops: [0.0, 0.7, 1.0],
//    ),
//    boxShadow: [
//   BoxShadow(
//  color: const Color(0xFF9B28F8).withOpacity(0.6),
//  blurRadius: 8,
//  spreadRadius: 1,
//   ),
//    ],
//  ),
//   ),
//    ),
//  ],
//   ),
//    ),
//  );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:keep_screen_on/keep_screen_on.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';
// import 'video_player_service.dart'; // Make sure this path is correct

// class VideoScreen extends StatefulWidget {
//   final String videoUrl;
//   final String name;
//   final bool liveStatus;
//   // ... other properties you might have
//   final String updatedAt;
//   final List<dynamic> channelList;
//   final String bannerImageUrl;
//   final int? videoId;
//   final String source;

//   VideoScreen({
//  required this.videoUrl,
//  required this.name,
//  required this.liveStatus,
//  required this.updatedAt,
//  required this.channelList,
//  required this.bannerImageUrl,
//  required this.videoId,
//  required this.source,
//   });

//   @override
//   _VideoScreenState createState() => _VideoScreenState();
// }

// class _VideoScreenState extends State<VideoScreen> {
//   late final Player player = VideoPlayerService.player;
//   late final VideoController controller;
//   final FocusNode _focusNode = FocusNode();

//   bool _controlsVisible = true;
//   Timer? _hideControlsTimer;

//   // --- "Seek on Release" Variables ---
//   Timer? _seekAccumulatorTimer;
//   Duration _accumulatedSeekDuration = Duration.zero;
//   int _seekDirection = 0; // 0 = stopped, 1 = forward, -1 = backward
//   bool _isPreviewingSeek = false;
//   Duration _previewPosition = Duration.zero;

//   @override
//   void initState() {
//  super.initState();
//  controller = VideoController(player);
//  player.open(Media(widget.videoUrl), play: true);

//  KeepScreenOn.turnOn();
//  WidgetsBinding.instance.addPostFrameCallback((_) {
//    FocusScope.of(context).requestFocus(_focusNode);
//  });
//  _startHideControlsTimer();
//   }

//   @override
//   void dispose() {
//  _hideControlsTimer?.cancel();
//  _seekAccumulatorTimer?.cancel();
//  player.stop();
//  _focusNode.dispose();
//  KeepScreenOn.turnOff();
//  super.dispose();
//   }

//   void _resetHideControlsTimer() {
//  if (!_controlsVisible) {
//    setState(() {
//   _controlsVisible = true;
//    });
//  }
//  _hideControlsTimer?.cancel();
//  _startHideControlsTimer();
//   }

//   void _startHideControlsTimer() {
//  _hideControlsTimer = Timer(const Duration(seconds: 5), () {
//    if (mounted) {
//   setState(() {
//  _controlsVisible = false;
//   });
//    }
//  });
//   }

//   KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
//  if (_isPreviewingSeek) {
//    _resetHideControlsTimer();
//  }

//  final isSeekingKey = event.logicalKey == LogicalKeyboardKey.arrowLeft ||
//   event.logicalKey == LogicalKeyboardKey.arrowRight;

//  if (isSeekingKey) {
//    if (event is KeyDownEvent) {
//   if (_seekDirection == 0) {
//  _seekDirection =
//  (event.logicalKey == LogicalKeyboardKey.arrowRight) ? 1 : -1;
//  _startAccumulatingSeek();
//   }
//    } else if (event is KeyUpEvent) {
//   _stopAndExecuteSeek();
//    }
//    return KeyEventResult.handled;
//  }

//  final isUpDownKey = event.logicalKey == LogicalKeyboardKey.arrowUp ||
//   event.logicalKey == LogicalKeyboardKey.arrowDown;

//  if (event is KeyDownEvent && isUpDownKey) {
//    _resetHideControlsTimer();
//    return KeyEventResult.handled;
//  }

//  if (event is KeyDownEvent &&
//   (event.logicalKey == LogicalKeyboardKey.select ||
//    event.logicalKey == LogicalKeyboardKey.enter)) {
//    player.playOrPause();
//    _resetHideControlsTimer();
//    return KeyEventResult.handled;
//  }

//  return KeyEventResult.ignored;
//   }

//   void _startAccumulatingSeek() {
//  if (widget.liveStatus) return;

//  const seekSpeedFactor = Duration(seconds: 30);
//  const timerInterval = Duration(milliseconds: 100);

//  _seekAccumulatorTimer?.cancel();
//  _seekAccumulatorTimer = Timer.periodic(timerInterval, (timer) {
//    final currentPosition = player.state.position;
//    final totalDuration = player.state.duration;

//    setState(() {
//   _accumulatedSeekDuration += seekSpeedFactor;
//   _isPreviewingSeek = true;

//   _previewPosition =
//    currentPosition + (_accumulatedSeekDuration * _seekDirection);

//   if (_previewPosition < Duration.zero) _previewPosition = Duration.zero;
//   if (_previewPosition > totalDuration) _previewPosition = totalDuration;
//    });
//  });
//   }

//   void _stopAndExecuteSeek() {
//  _seekAccumulatorTimer?.cancel();

//  if (_accumulatedSeekDuration > Duration.zero) {
//    player.seek(_previewPosition);
//  }

//  setState(() {
//    _isPreviewingSeek = false;
//    _accumulatedSeekDuration = Duration.zero;
//    _seekDirection = 0;
//  });
//  _resetHideControlsTimer();
//   }

//   String _formatDuration(Duration duration) {
//  String twoDigits(int n) => n.toString().padLeft(2, '0');
//  final hours = duration.inHours;
//  final minutes = duration.inMinutes.remainder(60);
//  final seconds = duration.inSeconds.remainder(60);
//  return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
//   }

//   @override
//   Widget build(BuildContext context) {
//  return Focus(
//    focusNode: _focusNode,
//    autofocus: true,
//    onKeyEvent: _handleKeyEvent,
//    child: GestureDetector(
//   onTap: _resetHideControlsTimer,
//   child: Scaffold(
//  backgroundColor: Colors.black,
//  body: Center(
//    child: SizedBox(
//   width: MediaQuery.of(context).size.width,
//   height: MediaQuery.of(context).size.width * 9.0 / 16.0,
//   child: Stack(
//  alignment: Alignment.bottomCenter,
//  children: [
//    Video(
//   controller: controller,
//   fit: BoxFit.contain,
//    ),
//    StreamBuilder<bool>(
//   stream: player.stream.buffering,
//   builder: (context, snapshot) {
//  return snapshot.data == true
//   ? const Center(child: CircularProgressIndicator())
//   : const SizedBox.shrink();
//   },
//    ),
//    AnimatedOpacity(
//   opacity: _controlsVisible ? 1.0 : 0.0,
//   duration: const Duration(milliseconds: 300),
//   child: _buildCustomControls(),
//    ),
//    if (_isPreviewingSeek) _buildSeekPreviewOverlay(),
//  ],
//   ),
//    ),
//  ),
//   ),
//    ),
//  );
//   }

//   Widget _buildCustomControls() {
//  return IgnorePointer(
//    child: Container(
//   color: Colors.black.withOpacity(0.5),
//   padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//   child: StreamBuilder<Duration>(
//  stream: player.stream.position,
//  builder: (context, snapshot) {
//    final position = snapshot.data ?? player.state.position;
//    final duration = player.state.duration;

//    return Row(
//   children: [
//  if (widget.liveStatus)
//    Row(
//   children: const [
//  Icon(Icons.circle, color: Colors.red, size: 14),
//  SizedBox(width: 6),
//  Text('Live',
//   style: TextStyle(
//    color: Colors.red,
//    fontWeight: FontWeight.bold,
//    fontSize: 16)),
//   ],
//    )
//  else
//    Text(_formatDuration(position),
//  style: const TextStyle(color: Colors.white, fontSize: 16)),
//  const SizedBox(width: 16),
//  Expanded(
//    child: _buildBeautifulProgressBar(position, duration),
//  ),
//  const SizedBox(width: 16),
//  if (!widget.liveStatus)
//    Text(_formatDuration(duration),
//  style: const TextStyle(color: Colors.white, fontSize: 16)),
//   ],
//    );
//  },
//   ),
//    ),
//  );
//   }

//   Widget _buildBeautifulProgressBar(Duration position, Duration duration) {
//  if (duration.inMilliseconds <= 0) {
//    return Container(
//  height: 8,
//  decoration: BoxDecoration(
//   color: Colors.grey[800], borderRadius: BorderRadius.circular(4)));
//  }
//  double progress =
//  (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
//  return Container(
//    height: 8,
//    child: ClipRRect(
//   borderRadius: BorderRadius.circular(4),
//   child: LinearProgressIndicator(
//  value: progress,
//  backgroundColor: Colors.grey[800],
//  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
//   ),
//    ),
//  );
//   }

//   // --- 🔽 YEH WIDGET BADLEIN 🔽 ---
//   Widget _buildSeekPreviewOverlay() {
//  final duration = player.state.duration;
//  final previewTimeText = _formatDuration(_previewPosition);
//  final totalTimeText = _formatDuration(duration);

//  // Positioned.fill ki jagah isey use karein taaki ye sirf neeche dikhe
//  return Positioned(
//    left: 0,
//    right: 0,
//    bottom: 0,
//    child: Container(
//   // Ek halka sa background de dein taaki video par text saaf dikhe
//   color: Colors.black,
//   padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // Thodi padding
//   child: Column(
//  // mainAxisAlignment.end ki zaroorat nahi
//  children: [
//    Row(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: [
//  Text(
//    previewTimeText,
//    style: const TextStyle(
//  color: Colors.white,
//  fontSize: 28,
//  fontWeight: FontWeight.bold),
//  ),
//  Text(
//    " / $totalTimeText",
//    style: TextStyle(
//  color: Colors.white.withOpacity(0.7), fontSize: 28),
//  ),
//   ],
//    ),
//    const SizedBox(height: 16),
//    _buildPreviewProgressBar(
//  player.state.position, _previewPosition, duration),
//  ],
//   ),
//    ),
//  );
//   }
//   // --- 🔼 BADLAV YAHAN KHATAM HOTA HAI 🔼 ---

//   Widget _buildPreviewProgressBar(
//    Duration current, Duration preview, Duration total) {
//  if (total.inMilliseconds <= 0) return const SizedBox(height: 8);

//  double currentProgress =
//  (current.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
//  double previewProgress =
//  (preview.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);

//  const double circleDiameter = 16.0;
//  const double circleRadius = circleDiameter / 2;

//  return LayoutBuilder(
//    builder: (context, constraints) {
//   final double progressBarWidth = constraints.maxWidth;

//   return SizedBox(
//  height: circleDiameter,
//  child: Stack(
//    alignment: Alignment.centerLeft,
//    children: [
//   Container(
//  height: 8,
//  decoration: BoxDecoration(
//    color: Colors.grey[800],
//    borderRadius: BorderRadius.circular(4),
//  ),
//   ),
//   FractionallySizedBox(
//  widthFactor: previewProgress,
//  child: Container(
//    height: 8,
//    decoration: BoxDecoration(
//   color: Colors.white.withOpacity(0.4),
//   borderRadius: BorderRadius.circular(4),
//    ),
//  ),
//   ),
//   FractionallySizedBox(
//  widthFactor: currentProgress,
//  child: Container(
//    height: 8,
//    decoration: BoxDecoration(
//   color: Colors.red,
//   borderRadius: BorderRadius.circular(4),
//    ),
//  ),
//   ),
//   Positioned(
//  left: (previewProgress * progressBarWidth) - circleRadius,
//  child: Container(
//    width: circleDiameter,
//    height: circleDiameter,
//    decoration: BoxDecoration(
//   shape: BoxShape.circle,
//   color: Colors.red,
//   border: Border.all(color: Colors.white, width: 2.0),
//    ),
//  ),
//   ),
//    ],
//  ),
//   );
//    },
//  );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:keep_screen_on/keep_screen_on.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';

// class VideoScreen extends StatefulWidget {
//   final String videoUrl;
//   final String name;
//   final bool liveStatus;
//   final String updatedAt;
//   final List<dynamic> channelList;
//   final String bannerImageUrl;
//   final int? videoId;
//   final String source;

//   const VideoScreen({
//  super.key,
//  required this.videoUrl,
//  required this.name,
//  required this.liveStatus,
//  required this.updatedAt,
//  required this.channelList,
//  required this.bannerImageUrl,
//  required this.videoId,
//  required this.source,
//   });

//   @override
//   State<VideoScreen> createState() => _VideoScreenState();
// }

// class _VideoScreenState extends State<VideoScreen> {
//   late final Player player;
//   late final VideoController controller;

//   final FocusNode _focusNode = FocusNode();

//   bool _controlsVisible = true;
//   Timer? _hideControlsTimer;

//   // --- State variables for "Seek on Release" feature ---
//   Timer? _seekTimer;
//   Duration _accumulatedSeek = Duration.zero;
//   Duration _seekStartPosition = Duration.zero;
//   int _seekDirection = 0; // 0=none, 1=forward, -1=backward

//   // Use a ValueNotifier to update ONLY the seek preview UI, preventing full screen rebuilds.
//   final ValueNotifier<Duration?> _seekPreviewNotifier = ValueNotifier(null);

//   @override
//   void initState() {
//  super.initState();

//  player = Player(
//    configuration: const PlayerConfiguration(
//   vo: 'gpu',
//   bufferSize: 15 * 1024 * 1024, // 15 MB buffer
//   logLevel: MPVLogLevel.warn,
//    ),
//  );
//  controller = VideoController(player);

//  player.open(Media(widget.videoUrl), play: true);

//  KeepScreenOn.turnOn();
//  WidgetsBinding.instance.addPostFrameCallback((_) {
//    FocusScope.of(context).requestFocus(_focusNode);
//  });
//  _startHideControlsTimer();
//   }

//   @override
//   void dispose() {
//  _hideControlsTimer?.cancel();
//  _seekTimer?.cancel();
//  _seekPreviewNotifier.dispose();
//  player.dispose(); // This is crucial to free up resources.
//  _focusNode.dispose();
//  KeepScreenOn.turnOff();
//  super.dispose();
//   }

//   void _resetHideControlsTimer() {
//  if (!_controlsVisible) {
//    setState(() {
//   _controlsVisible = true;
//    });
//  }
//  _hideControlsTimer?.cancel();
//  _startHideControlsTimer();
//   }

//   void _startHideControlsTimer() {
//  _hideControlsTimer = Timer(const Duration(seconds: 5), () {
//    if (mounted && _seekPreviewNotifier.value == null) {
//   setState(() {
//  _controlsVisible = false;
//   });
//    }
//  });
//   }

//   KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
//  // Any key press should show the controls
//  _resetHideControlsTimer();

//  final isSeekingKey = event.logicalKey == LogicalKeyboardKey.arrowLeft ||
//   event.logicalKey == LogicalKeyboardKey.arrowRight;
//  final isPlayPauseKey = event.logicalKey == LogicalKeyboardKey.select ||
//   event.logicalKey == LogicalKeyboardKey.enter;
//  final isVolumeKey = event.logicalKey == LogicalKeyboardKey.arrowUp ||
//   event.logicalKey == LogicalKeyboardKey.arrowDown;

//  if (event is KeyDownEvent) {
//    if (isSeekingKey) {
//   if (_seekDirection == 0) { // Start seeking only if not already seeking
//  _seekDirection = (event.logicalKey == LogicalKeyboardKey.arrowRight) ? 1 : -1;
//  _startAccumulatingSeek();
//   }
//   return KeyEventResult.handled;
//    }
//    if (isPlayPauseKey) {
//   player.playOrPause();
//   return KeyEventResult.handled;
//    }
//    if(isVolumeKey) {
//   // Placeholder for volume control logic
//   return KeyEventResult.handled;
//    }
//  }

//  if (event is KeyUpEvent) {
//    if (isSeekingKey) {
//   _stopAndExecuteSeek();
//   return KeyEventResult.handled;
//    }
//  }

//  return KeyEventResult.ignored;
//   }

//   void _startAccumulatingSeek() {
//  if (widget.liveStatus) return;

//  _seekTimer?.cancel();
//  _accumulatedSeek = Duration.zero;
//  _seekStartPosition = player.state.position; // Latch the start position

//  // This timer updates the seek preview without calling setState()
//  _seekTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
//    // To achieve 30 seconds of seek per 1 second of hold,
//    // we add 3 seconds of seek every 100ms.
//    _accumulatedSeek += const Duration(seconds: 3);

//    final totalDuration = player.state.duration;
//    var newPosition = _seekStartPosition + (_accumulatedSeek * _seekDirection);

//    // Clamp the preview position within video bounds
//    if (newPosition < Duration.zero) newPosition = Duration.zero;
//    if (newPosition > totalDuration) newPosition = totalDuration;

//    _seekPreviewNotifier.value = newPosition;
//  });
//   }

//   void _stopAndExecuteSeek() {
//  _seekTimer?.cancel();

//  // Use the final preview position to perform the seek
//  if (_seekPreviewNotifier.value != null) {
//    player.seek(_seekPreviewNotifier.value!);
//  }

//  // Reset all seek-related state
//  _seekPreviewNotifier.value = null;
//  _accumulatedSeek = Duration.zero;
//  _seekDirection = 0;

//  _resetHideControlsTimer();
//   }

//   String _formatDuration(Duration duration) {
//  String twoDigits(int n) => n.toString().padLeft(2, '0');
//  final hours = duration.inHours;
//  final minutes = duration.inMinutes.remainder(60);
//  final seconds = duration.inSeconds.remainder(60);
//  if (hours > 0) {
//    return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
//  }
//  return "${twoDigits(minutes)}:${twoDigits(seconds)}";
//   }

//   @override
//   Widget build(BuildContext context) {
//  return Focus(
//    focusNode: _focusNode,
//    autofocus: true,
//    onKeyEvent: _handleKeyEvent,
//    child: GestureDetector(
//   onTap: _resetHideControlsTimer,
//   child: Scaffold(
//  backgroundColor: Colors.black,
//  body: Center(
//    child: AspectRatio(
//   aspectRatio: 16.0 / 9.0,
//   child: Stack(
//  alignment: Alignment.bottomCenter,
//  children: [
//    Video(
//   controller: controller,
//   fit: BoxFit.contain,
//    ),
//    // Listen for errors and display a message
//    StreamBuilder<String>(
//   stream: player.stream.error,
//   builder: (context, snapshot) {
//  if (snapshot.hasData) {
//    return Center(
//   child: Card(
//  color: Colors.black87,
//  child: Padding(
//    padding: const EdgeInsets.all(16.0),
//    child: Text(
//   'Error: Could not play video.\n(${snapshot.data})',
//   textAlign: TextAlign.center,
//   style: const TextStyle(color: Colors.white, fontSize: 16),
//    ),
//  ),
//   ),
//    );
//  }
//  return const SizedBox.shrink();
//   },
//    ),
//    // Buffering indicator
//    StreamBuilder<bool>(
//   stream: player.stream.buffering,
//   builder: (context, snapshot) {
//  return (snapshot.data ?? false)
//   ? const Center(child: CircularProgressIndicator())
//   : const SizedBox.shrink();
//   },
//    ),
//    // Unified playback controls with integrated seek preview
//    ValueListenableBuilder<Duration?>(
//   valueListenable: _seekPreviewNotifier,
//   builder: (context, seekPreview, child) {
//  return AnimatedOpacity(
//    // Show if controls are meant to be visible OR if actively seeking
//    opacity: _controlsVisible || seekPreview != null ? 1.0 : 0.0,
//    duration: const Duration(milliseconds: 300),
//    child: _buildCustomControls(),
//  );
//   },
//    ),
//  ],
//   ),
//    ),
//  ),
//   ),
//    ),
//  );
//   }

//   Widget _buildCustomControls() {
//  return ValueListenableBuilder<Duration?>(
//   valueListenable: _seekPreviewNotifier,
//   builder: (context, previewPosition, child) {
//  final isSeeking = previewPosition != null;
//  return IgnorePointer(
//    child: Container(
//   color: Colors.black.withOpacity(0.5),
//   padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//   child: StreamBuilder<Duration>(
//  stream: player.stream.position,
//  builder: (context, snapshot) {
//    final position = snapshot.data ?? player.state.position;
//    final duration = player.state.duration;

//    // When seeking, show the preview time. Otherwise, show current time.
//    final displayPosition = isSeeking ? previewPosition! : position;

//    return Row(
//   children: [
//  if (widget.liveStatus)
//    Row(
//   children: const [
//  Icon(Icons.circle, color: Colors.red, size: 14),
//  SizedBox(width: 6),
//  Text('Live',
//   style: TextStyle(
//    color: Colors.red,
//    fontWeight: FontWeight.bold,
//    fontSize: 16)),
//   ],
//    )
//  else
//    Text(_formatDuration(displayPosition),
//  style:
//   const TextStyle(color: Colors.white, fontSize: 16)),
//  const SizedBox(width: 16),
//  Expanded(
//    child: _buildBeautifulProgressBar(
//   position: position,
//   duration: duration,
//   previewPosition: previewPosition,
//    ),
//  ),
//  const SizedBox(width: 16),
//  if (!widget.liveStatus)
//    Text(_formatDuration(duration),
//  style: const TextStyle(
//   color: Colors.white, fontSize: 16)),
//   ],
//    );
//  },
//   ),
//    ),
//  );
//   });
//   }

//   Widget _buildBeautifulProgressBar({
//  required Duration position,
//  required Duration duration,
//  Duration? previewPosition,
//   }) {
//  if (duration.inMilliseconds <= 0) {
//    return Container(
//  height: 16, // Consistent height
//  alignment: Alignment.centerLeft,
//  child: Container(
//   height: 8,
//   decoration: BoxDecoration(
//    color: Colors.grey[800],
//    borderRadius: BorderRadius.circular(4))));
//  }

//  double currentProgress =
//   (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
//  double previewProgress = ((previewPosition?.inMilliseconds ?? 0) /
//    duration.inMilliseconds)
//   .clamp(0.0, 1.0);

//  const double circleDiameter = 16.0;

//  return LayoutBuilder(builder: (context, constraints) {
//    final double progressBarWidth = constraints.maxWidth;
//    return SizedBox(
//   height: circleDiameter,
//   child: Stack(
//  alignment: Alignment.centerLeft,
//  children: [
//    // Base track
//    Container(
//   height: 8,
//   decoration: BoxDecoration(
//  color: Colors.grey[800],
//  borderRadius: BorderRadius.circular(4),
//   ),
//    ),
//    // Preview progress (only shown when seeking)
//    if (previewPosition != null)
//   FractionallySizedBox(
//  widthFactor: previewProgress,
//  child: Container(
//    height: 8,
//    decoration: BoxDecoration(
//   color: Colors.white.withOpacity(0.4),
//   borderRadius: BorderRadius.circular(4),
//    ),
//  ),
//   ),
//    // Current played progress
//    FractionallySizedBox(
//   widthFactor: currentProgress,
//   child: Container(
//  height: 8,
//  decoration: BoxDecoration(
//    color: Colors.red,
//    borderRadius: BorderRadius.circular(4),
//  ),
//   ),
//    ),
//    // Thumb at the preview position (only shown when seeking)
//    if (previewPosition != null)
//   Positioned(
//  left: (previewProgress * progressBarWidth)
//   .clamp(0, progressBarWidth - circleDiameter),
//  child: Container(
//    width: circleDiameter,
//    height: circleDiameter,
//    decoration: BoxDecoration(
//   shape: BoxShape.circle,
//   color: Colors.red,
//   border: Border.all(color: Colors.white, width: 2.0),
//    ),
//  ),
//   ),
//  ],
//   ),
//    );
//  });
//   }
// }





import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoScreen extends StatefulWidget {
  final String videoUrl;
  final String name;
  final bool liveStatus;
  final String updatedAt;
  final List<dynamic> channelList;
  final String bannerImageUrl;
  final int? videoId;
  final String source;

  const VideoScreen({
    super.key,
    required this.videoUrl,
    required this.name,
    required this.liveStatus,
    required this.updatedAt,
    required this.channelList,
    required this.bannerImageUrl,
    required this.videoId,
    required this.source,
  });

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late final Player player;
  late final VideoController controller;

  final FocusNode _focusNode = FocusNode();

  bool _controlsVisible = true;
  Timer? _hideControlsTimer;

  // --- State variables for "Seek on Release" feature ---
  Timer? _seekTimer;
  Duration _accumulatedSeek = Duration.zero;
  Duration _seekStartPosition = Duration.zero;
  int _seekDirection = 0; // 0=none, 1=forward, -1=backward

  // Use a ValueNotifier to update ONLY the seek preview UI, preventing full screen rebuilds.
  final ValueNotifier<Duration?> _seekPreviewNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();

    player = Player(
      configuration: PlayerConfiguration(
        vo: 'gpu',
        bufferSize: 15 * 1024 * 1024, // 15 MB buffer
        logLevel: MPVLogLevel.warn,
      ),
    );
    controller = VideoController(player);

    player.open(Media(widget.videoUrl), play: true);

    KeepScreenOn.turnOn();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _seekTimer?.cancel();
    _seekPreviewNotifier.dispose();
    player.dispose(); // This is crucial to free up resources.
    _focusNode.dispose();
    KeepScreenOn.turnOff();
    super.dispose();
  }

  void _resetHideControlsTimer() {
    if (!_controlsVisible) {
      setState(() {
        _controlsVisible = true;
      });
    }
    _hideControlsTimer?.cancel();
    _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _seekPreviewNotifier.value == null) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    // Any key press should show the controls
    _resetHideControlsTimer();

    final isSeekingKey = event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowRight;
    final isPlayPauseKey = event.logicalKey == LogicalKeyboardKey.select ||
        event.logicalKey == LogicalKeyboardKey.enter;
    final isVolumeKey = event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.arrowDown;

    if (event is KeyDownEvent) {
      if (isSeekingKey) {
        if (_seekDirection == 0) { // Start seeking only if not already seeking
          _seekDirection = (event.logicalKey == LogicalKeyboardKey.arrowRight) ? 1 : -1;
          _startAccumulatingSeek();
        }
        return KeyEventResult.handled;
      }
      if (isPlayPauseKey) {
        player.playOrPause();
        return KeyEventResult.handled;
      }
      if(isVolumeKey) {
        // Placeholder for volume control logic
        return KeyEventResult.handled;
      }
    }

    if (event is KeyUpEvent) {
      if (isSeekingKey) {
        _stopAndExecuteSeek();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  void _startAccumulatingSeek() {
    if (widget.liveStatus) return;

    _seekTimer?.cancel();
    _accumulatedSeek = Duration.zero;
    _seekStartPosition = player.state.position; // Latch the start position

    // This timer updates the seek preview without calling setState()
    _seekTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // To achieve 30 seconds of seek per 1 second of hold,
      // we add 3 seconds of seek every 100ms.
      _accumulatedSeek += const Duration(seconds: 15);

      final totalDuration = player.state.duration;
      var newPosition = _seekStartPosition + (_accumulatedSeek * _seekDirection);

      // Clamp the preview position within video bounds
      if (newPosition < Duration.zero) newPosition = Duration.zero;
      if (newPosition > totalDuration) newPosition = totalDuration;

      _seekPreviewNotifier.value = newPosition;
    });
  }

  void _stopAndExecuteSeek() {
    _seekTimer?.cancel();

    // Use the final preview position to perform the seek
    if (_seekPreviewNotifier.value != null) {
      player.seek(_seekPreviewNotifier.value!);
    }

    // Reset all seek-related state
    _seekPreviewNotifier.value = null;
    _accumulatedSeek = Duration.zero;
    _seekDirection = 0;

    _resetHideControlsTimer();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
      return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  @override
  Widget build(BuildContext context) {
    // PopScope ko yahan add kiya gaya hai taaki back navigation ko handle kar sakein
    return PopScope(
      canPop: false, // Default back action ko rokta hai
      onPopInvoked: (didPop) async {
        // Agar pop ho chuka hai toh kuch na karein
        if (didPop) return;

        // Player ko surakshit roop se dispose karein
        await player.dispose();

        // Agar widget abhi bhi screen par hai, toh pop karein
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: GestureDetector(
          onTap: _resetHideControlsTimer,
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: AspectRatio(
                aspectRatio: 16.0 / 9.0,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
  Video(
    controller: controller,
    fit: BoxFit.contain,
  ),
  // // Listen for errors and display a message
  // StreamBuilder<String>(
  //   stream: player.stream.error,
  //   builder: (context, snapshot) {
  //     if (snapshot.hasData) {
  //       return Center(
  //         child: Card(
  //           color: Colors.black87,
  //           child: Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Text(
  //               'Error: Could not play video.\n(${snapshot.data})',
  //               textAlign: TextAlign.center,
  //               style: const TextStyle(color: Colors.white, fontSize: 16),
  //             ),
  //           ),
  //         ),
  //       );
  //     }
  //     return const SizedBox.shrink();
  //   },
  // ),
  // Buffering indicator
  StreamBuilder<bool>(
    stream: player.stream.buffering,
    builder: (context, snapshot) {
      return (snapshot.data ?? false)
          ? const Center(child: CircularProgressIndicator())
          : const SizedBox.shrink();
    },
  ),
  // Unified playback controls with integrated seek preview
  ValueListenableBuilder<Duration?>(
    valueListenable: _seekPreviewNotifier,
    builder: (context, seekPreview, child) {
      return AnimatedOpacity(
        // Show if controls are meant to be visible OR if actively seeking
        opacity: _controlsVisible || seekPreview != null ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: _buildCustomControls(),
      );
    },
  ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildCustomControls() {
  //   return ValueListenableBuilder<Duration?>(
  //       valueListenable: _seekPreviewNotifier,
  //       builder: (context, previewPosition, child) {
  //         final isSeeking = previewPosition != null;
  //         return IgnorePointer(
  //           child: Container(
  //             color: Colors.black.withOpacity(0.5),
  //             padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  //             child: StreamBuilder<Duration>(
  //               stream: player.stream.position,
  //               builder: (context, snapshot) {
  //                 final position = snapshot.data ?? player.state.position;
  //                 final duration = player.state.duration;

  //                 // When seeking, show the preview time. Otherwise, show current time.
  //                 final displayPosition = isSeeking ? previewPosition! : position;

  //                 return Row(
  // children: [
  //   if (widget.liveStatus)
  //     Row(
  //       children: const [
  //         Icon(Icons.circle, color: Colors.red, size: 14),
  //         SizedBox(width: 6),
  //         Text('Live',
  //             style: TextStyle(
  //                 color: Colors.red,
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 16)),
  //       ],
  //     )
  //   else
  //     Text(_formatDuration(displayPosition),
  //         style:
  //             const TextStyle(color: Colors.white, fontSize: 16)),
  //   const SizedBox(width: 16),
  //   Expanded(
  //     child: _buildBeautifulProgressBar(
  //       position: position,
  //       duration: duration,
  //       previewPosition: previewPosition,
  //     ),
  //   ),
  //   const SizedBox(width: 16),
  //   if (!widget.liveStatus)
  //     Text(_formatDuration(duration),
  //         style: const TextStyle(
  //             color: Colors.white, fontSize: 16)),
  // ],
  //                 );
  //               },
  //             ),
  //           ),
  //         );
  //       });
  // }




  Widget _buildCustomControls() {
  return ValueListenableBuilder<Duration?>(
      valueListenable: _seekPreviewNotifier,
      builder: (context, previewPosition, child) {
        final isSeeking = previewPosition != null;
        return IgnorePointer(
          child: Container(
            color: Colors.black.withOpacity(0.5),
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: StreamBuilder<Duration>(
              stream: player.stream.position,
              builder: (context, snapshot) {
                final position = snapshot.data ?? player.state.position;
                final duration = player.state.duration;
                final displayPosition = isSeeking ? previewPosition! : position;

                return Row(
                  children: [
                    // LEFT SIDE - Position/Live
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0), // LEFT PADDING
                      child: widget.liveStatus
                          ? Row(
                              children: const [
                                Icon(Icons.circle, color: Colors.red, size: 14),
                                SizedBox(width: 6),
                                Text('Live',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ],
                            )
                          : Text(_formatDuration(displayPosition),
                              style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                    const SizedBox(width: 16),
                    
                    // MIDDLE - Progress Bar
                    Expanded(
                      child: _buildBeautifulProgressBar(
                        position: position,
                        duration: duration,
                        previewPosition: previewPosition,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // RIGHT SIDE - Duration
                    if (!widget.liveStatus)
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0), // RIGHT PADDING
                        child: Text(_formatDuration(duration),
                            style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      });
}

  // Widget _buildBeautifulProgressBar({
  //   required Duration position,
  //   required Duration duration,
  //   Duration? previewPosition,
  // }) {
  //   if (duration.inMilliseconds <= 0) {
  //     return Container(
  //         height: 16, // Consistent height
  //         alignment: Alignment.centerLeft,
  //         child: Container(
  //             height: 8,
  //             decoration: BoxDecoration(
  //                 color: Colors.grey[800],
  //                 borderRadius: BorderRadius.circular(4))));
  //   }

  //   double currentProgress =
  //       (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  //   double previewProgress = ((previewPosition?.inMilliseconds ?? 0) /
  //           duration.inMilliseconds)
  //       .clamp(0.0, 1.0);

  //   const double circleDiameter = 16.0;

  //   return LayoutBuilder(builder: (context, constraints) {
  //     final double progressBarWidth = constraints.maxWidth;
  //     return SizedBox(
  //       height: circleDiameter,
  //       child: Stack(
  //         alignment: Alignment.centerLeft,
  //         children: [
  //           // Base track
  //           Container(
  //             height: 8,
  //             decoration: BoxDecoration(
  //               color: Colors.grey[800],
  //               borderRadius: BorderRadius.circular(4),
  //             ),
  //           ),
  //           // Preview progress (only shown when seeking)
  //           if (previewPosition != null)
  //             FractionallySizedBox(
  //               widthFactor: previewProgress,
  //               child: Container(
  //                 height: 8,
  //                 decoration: BoxDecoration(
  // color: Colors.white.withOpacity(0.4),
  // borderRadius: BorderRadius.circular(4),
  //                 ),
  //               ),
  //             ),
  //           // Current played progress
  //           FractionallySizedBox(
  //             widthFactor: currentProgress,
  //             child: Container(
  //               height: 8,
  //               decoration: BoxDecoration(
  //                 color: Colors.red,
  //                 borderRadius: BorderRadius.circular(4),
  //               ),
  //             ),
  //           ),
  //           // Thumb at the preview position (only shown when seeking)
  //           if (previewPosition != null)
  //             Positioned(
  //               left: (previewProgress * progressBarWidth)
  // .clamp(0, progressBarWidth - circleDiameter),
  //               child: Container(
  //                 width: circleDiameter,
  //                 height: circleDiameter,
  //                 decoration: BoxDecoration(
  // shape: BoxShape.circle,
  // color: Colors.red,
  // border: Border.all(color: Colors.white, width: 2.0),
  //                 ),
  //               ),
  //             ),
  //         ],
  //       ),
  //     );
  //   });
  // }

Widget _buildBeautifulProgressBar({
  required Duration position,
  required Duration duration,
  Duration? previewPosition,
}) {
  if (duration.inMilliseconds <= 0) {
    return Container(
      height: 24,
      alignment: Alignment.center,
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  double currentProgress =
      (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  double previewProgress = ((previewPosition?.inMilliseconds ?? 0) /
          duration.inMilliseconds)
      .clamp(0.0, 1.0);

  final bool isSeeking = previewPosition != null;
  const double thumbSize = 16.0;

  return LayoutBuilder(
    builder: (context, constraints) {
      final double barWidth = constraints.maxWidth;
    
    return SizedBox(
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background track
          Container(
            height: isSeeking ? 8 : 5,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          
          // Buffered/Preview layer (subtle hint)
          if (isSeeking)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 8,
                width: previewProgress * barWidth,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.yellow.withOpacity(0.2),
                      Colors.orange.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          
          // Main progress - VIBRANT!
          Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: isSeeking ? 8 : 5,
              width: currentProgress * barWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: const [
                    Color(0xFFFF1744), // Bright red
                    Color(0xFFFF5252), // Lighter red
                    Color(0xFFFF6E40), // Orange-red
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF1744).withOpacity(0.6),
                    blurRadius: isSeeking ? 12 : 6,
                    spreadRadius: isSeeking ? 2 : 0,
                  ),
                ],
              ),
            ),
          ),
          
          // Pulsing glow at playhead
          if (isSeeking)
            Positioned(
              left: (currentProgress * barWidth).clamp(0.0, barWidth),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.red.withOpacity(0.4),
                      Colors.red.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          
          // Current position thumb
          if (isSeeking)
            Positioned(
              left: (currentProgress * barWidth - thumbSize / 2)
                  .clamp(0.0, barWidth - thumbSize),
              child: Container(
                width: thumbSize,
                height: thumbSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Colors.white,
                      Color(0xFFFAFAFA),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          
          // Preview position thumb - THE STAR! ⭐
          if (previewPosition != null)
            Positioned(
              left: (previewProgress * barWidth - thumbSize / 2)
                  .clamp(0.0, barWidth - thumbSize),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: thumbSize + 4,
                      height: thumbSize + 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [
                            Color(0xFFFFEB3B), // Yellow center
                            Color(0xFFFF9800), // Orange
                            Color(0xFFFF5722), // Red-orange edge
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFEB3B).withOpacity(0.6),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.8),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          
          // Time preview tooltip
          if (previewPosition != null)
            Positioned(
              left: (previewProgress * barWidth - 40)
                  .clamp(10.0, barWidth - 90),
              top: -35,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1E1E1E),
                      Color(0xFF2C2C2C),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Text(
                  _formatDuration(previewPosition),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  },
  );
}
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:video_player/video_player.dart';
// import 'package:chewie/chewie.dart';
// import 'dart:async';

// class VideoScreen extends StatefulWidget {
//   final String videoUrl;
//   final String name;
//   final bool liveStatus;
//   final String updatedAt;
//   final List<dynamic> channelList;
//   final String bannerImageUrl;
//   final int? videoId;
//   final String source;

//   const VideoScreen({
//     super.key,
//     required this.videoUrl,
//     required this.name,
//     required this.liveStatus,
//     required this.updatedAt,
//     required this.channelList,
//     required this.bannerImageUrl,
//     required this.videoId,
//     required this.source,
//   });

//   @override
//   State<VideoScreen> createState() => _VideoScreenState();
// }

// class _VideoScreenState extends State<VideoScreen> {
//   late VideoPlayerController _videoPlayerController;
//   ChewieController? _chewieController;
//   bool isInitialized = false;
//   String? errorMessage;

//   // Progress bar controls
//   bool showProgressBar = true;
//   Timer? _hideTimer;
//   final FocusNode _focusNode = FocusNode();

//   // Seek controls
//   Timer? _seekTimer;
//   int _seekAmount = 0; // seconds
//   bool _isSeekingForward = false;
//   bool _isSeekingBackward = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializePlayer();
//     _startHideTimer();
//   }

//   void _startHideTimer() {
//     _hideTimer?.cancel();
//     setState(() {
//       showProgressBar = true;
//     });

//     _hideTimer = Timer(Duration(seconds: 5), () {
//       if (mounted) {
//         setState(() {
//           showProgressBar = false;
//         });
//       }
//     });
//   }

//   Future<void> _initializePlayer() async {
//     try {
//       _videoPlayerController = VideoPlayerController.networkUrl(
//         Uri.parse(widget.videoUrl),
//       );

//       await _videoPlayerController.initialize();

//       _chewieController = ChewieController(
//         videoPlayerController: _videoPlayerController,
//         autoPlay: true,
//         looping: false,
//         aspectRatio: 16 / 9,
//         showControls: false, // Custom controls ke liye disable karein
//         allowFullScreen: false,
//         allowMuting: true,
//         materialProgressColors: ChewieProgressColors(
//           playedColor: Colors.blue,
//           handleColor: Colors.blueAccent,
//           backgroundColor: Colors.grey,
//           bufferedColor: Colors.lightBlue,
//         ),
//         placeholder: Container(
//           color: Colors.black,
//           child: Center(
//             child: CircularProgressIndicator(color: Colors.white),
//           ),
//         ),
//       );

//       if (mounted) {
//         setState(() {
//           isInitialized = true;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           errorMessage = 'Failed to load video: $e';
//         });
//       }
//       print('Video Player Error: $e');
//     }
//   }

//   void _handleKeyEvent(KeyEvent event) {
//     _startHideTimer(); // Koi bhi button press karne par timer restart karein

//     if (event is KeyDownEvent) {
//       if (event.logicalKey == LogicalKeyboardKey.select ||
//           event.logicalKey == LogicalKeyboardKey.enter ||
//           event.logicalKey == LogicalKeyboardKey.space) {
//         // Play/Pause toggle
//         if (_videoPlayerController.value.isPlaying) {
//           _videoPlayerController.pause();
//         } else {
//           _videoPlayerController.play();
//         }
//         setState(() {});
//       }
//       else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//         // Forward seek start
//         if (!_isSeekingForward) {
//           _isSeekingForward = true;
//           _seekAmount = 0;
//           _startSeekTimer(true);
//         }
//       }
//       else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//         // Backward seek start
//         if (!_isSeekingBackward) {
//           _isSeekingBackward = true;
//           _seekAmount = 0;
//           _startSeekTimer(false);
//         }
//       }
//       else if (event.logicalKey == LogicalKeyboardKey.goBack ||
//                event.logicalKey == LogicalKeyboardKey.escape) {
//         // Back button press par video screen se bahar jaayein
//         Navigator.pop(context);
//       }
//     }
//     else if (event is KeyUpEvent) {
//       // Button release hone par final seek perform karein
//       if (event.logicalKey == LogicalKeyboardKey.arrowRight && _isSeekingForward) {
//         _performFinalSeek();
//       }
//       else if (event.logicalKey == LogicalKeyboardKey.arrowLeft && _isSeekingBackward) {
//         _performFinalSeek();
//       }
//     }
//   }

//   void _startSeekTimer(bool forward) {
//     _seekTimer?.cancel();

//     // Pehla seek 5 seconds ka
//     _seekAmount = 15;
//     setState(() {});

//     // Har 200ms mein 2 seconds add karein
//     _seekTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
//       if (mounted) {
//         setState(() {
//           _seekAmount += 15;
//           // // Maximum 60 seconds tak seek allow karein
//           // if (_seekAmount > 60) {
//           //   _seekAmount = 60;
//           // }
//         });
//       }
//     });
//   }

//   void _performFinalSeek() {
//     _seekTimer?.cancel();

//     if (_seekAmount > 0) {
//       final currentPosition = _videoPlayerController.value.position;
//       final duration = _videoPlayerController.value.duration;
//       Duration newPosition;

//       if (_isSeekingForward) {
//         newPosition = currentPosition + Duration(seconds: _seekAmount);
//         if (newPosition > duration) {
//           newPosition = duration;
//         }
//       } else {
//         newPosition = currentPosition - Duration(seconds: _seekAmount);
//         if (newPosition < Duration.zero) {
//           newPosition = Duration.zero;
//         }
//       }

//       _videoPlayerController.seekTo(newPosition);
//     }

//     // Reset seek state
//     setState(() {
//       _seekAmount = 0;
//       _isSeekingForward = false;
//       _isSeekingBackward = false;
//     });
//   }

//   @override
//   void dispose() {
//     _hideTimer?.cancel();
//     _seekTimer?.cancel();
//     _videoPlayerController.dispose();
//     _chewieController?.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final hours = twoDigits(duration.inHours);
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));

//     // if (duration.inHours > 0) {
//       return '$hours:$minutes:$seconds';
//     // }
//     // return '$minutes:$seconds';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return KeyboardListener(
//       focusNode: _focusNode,
//       autofocus: true,
//       onKeyEvent: _handleKeyEvent,
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: Stack(
//           children: [
//             // Video Player
//             Center(
//               child: Container(
//                 width: MediaQuery.of(context).size.width,
//                 height: MediaQuery.of(context).size.height,
//                 color: Colors.black,
//                 child: _buildVideoPlayer(),
//               ),
//             ),

//             // Custom Progress Bar Overlay
//             if (showProgressBar && isInitialized)
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: _buildCustomProgressBar(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildVideoPlayer() {
//     if (errorMessage != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 60, color: Colors.red),
//             SizedBox(height: 10),
//             Text(
//               'Failed to load video',
//               style: TextStyle(color: Colors.white, fontSize: 18),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   errorMessage = null;
//                 });
//                 _initializePlayer();
//               },
//               child: Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (!isInitialized || _chewieController == null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(color: Colors.white),
//             SizedBox(height: 10),
//             Text(
//               'Loading video...',
//               style: TextStyle(color: Colors.white, fontSize: 16),
//             ),
//           ],
//         ),
//       );
//     }

//     return Chewie(controller: _chewieController!);
//   }

//   Widget _buildCustomProgressBar() {
//     return AnimatedOpacity(
//       opacity: showProgressBar ? 1.0 : 0.0,
//       duration: Duration(milliseconds: 300),
//       child: Container(
//         margin: EdgeInsets.all(20),
//         padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Colors.black.withOpacity(0.85),
//               Colors.black.withOpacity(0.75),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.5),
//               blurRadius: 20,
//               spreadRadius: 5,
//             ),
//           ],
//           border: Border.all(
//             color: Colors.white.withOpacity(0.1),
//             width: 1,
//           ),
//         ),
//         child: StreamBuilder(
//           stream: Stream.periodic(Duration(milliseconds: 100)),
//           builder: (context, snapshot) {
//             final position = _videoPlayerController.value.position;
//             final duration = _videoPlayerController.value.duration;

//             // Agar seek ho raha hai to preview position calculate karein
//             Duration displayPosition = position;
//             if (_seekAmount > 0) {
//               if (_isSeekingForward) {
//                 displayPosition = position + Duration(seconds: _seekAmount);
//                 if (displayPosition > duration) {
//                   displayPosition = duration;
//                 }
//               } else if (_isSeekingBackward) {
//                 displayPosition = position - Duration(seconds: _seekAmount);
//                 if (displayPosition < Duration.zero) {
//                   displayPosition = Duration.zero;
//                 }
//               }
//             }

//             final progress = duration.inMilliseconds > 0
//                 ? position.inMilliseconds / duration.inMilliseconds
//                 : 0.0;

//             final previewProgress = duration.inMilliseconds > 0
//                 ? displayPosition.inMilliseconds / duration.inMilliseconds
//                 : 0.0;

//             return Row(
//               children: [
//                 // Play/Pause Icon with glow effect
//                 Container(
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.blue.withOpacity(0.3),
//                         Colors.blue.withOpacity(0.1),
//                       ],
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.withOpacity(0.3),
//                         blurRadius: 12,
//                         spreadRadius: 2,
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     _videoPlayerController.value.isPlaying
//                         ? Icons.pause_rounded
//                         : Icons.play_arrow_rounded,
//                     color: Colors.white,
//                     size: 32,
//                   ),
//                 ),

//                 SizedBox(width: 20),

//                 // Current/Preview Time with styling
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: _seekAmount > 0
//                         ? Colors.orange.withOpacity(0.2)
//                         : Colors.white.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                     border: _seekAmount > 0
//                         ? Border.all(color: Colors.orange.withOpacity(0.5), width: 1)
//                         : null,
//                   ),
//                   child: Text(
//                     _formatDuration(displayPosition),
//                     style: TextStyle(
//                       color: _seekAmount > 0 ? Colors.orange : Colors.white,
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ),

//                 SizedBox(width: 16),

//                 // Progress Bar with enhanced styling and preview
//                 Expanded(
//                   child: Container(
//                     height: 8,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(4),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.blue.withOpacity(0.2),
//                           blurRadius: 8,
//                         ),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(4),
//                       child: Stack(
//                         children: [
//                           // Background
//                           Container(
//                             color: Colors.white.withOpacity(0.15),
//                           ),
//                           // Current Progress
//                           FractionallySizedBox(
//                             widthFactor: progress,
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   colors: [
//                                     Color(0xFF2196F3),
//                                     Color(0xFF64B5F6),
//                                   ],
//                                 ),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.blue.withOpacity(0.5),
//                                     blurRadius: 8,
//                                     spreadRadius: 1,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           // Preview Progress (agar seek ho raha hai)
//                           if (_seekAmount > 0)
//                             FractionallySizedBox(
//                               widthFactor: previewProgress,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: [
//                                       Colors.orange.withOpacity(0.6),
//                                       Colors.orange.withOpacity(0.8),
//                                     ],
//                                   ),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.orange.withOpacity(0.6),
//                                       blurRadius: 10,
//                                       spreadRadius: 2,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//                 SizedBox(width: 16),

//                 // Total Duration with styling
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     _formatDuration(duration),
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ),

//                 // Buffering indicator with animation
//                 if (_videoPlayerController.value.isBuffering)
//                   Padding(
//                     padding: EdgeInsets.only(left: 20),
//                     child: Container(
//                       padding: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient: LinearGradient(
//                           colors: [
//                             Colors.orange.withOpacity(0.3),
//                             Colors.orange.withOpacity(0.1),
//                           ],
//                         ),
//                       ),
//                       child: SizedBox(
//                         width: 24,
//                         height: 24,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 3,
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }







