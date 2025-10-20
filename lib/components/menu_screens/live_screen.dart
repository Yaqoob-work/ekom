// // import 'dart:async';
// // import 'dart:convert';
// // import 'package:mobi_tv_entertainment/main.dart';
// // import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// //
// // import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// // import 'package:mobi_tv_entertainment/home_screen_pages/sub_live_screen/items/live_grid_item.dart';
// // import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// // import 'package:mobi_tv_entertainment/widgets/services/api_service.dart';
// // import 'package:mobi_tv_entertainment/widgets/small_widgets/empty_state.dart';
// // import 'package:mobi_tv_entertainment/widgets/small_widgets/error_message.dart';
// // import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart';
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../home_screen_pages/sub_live_screen/sub_live_screen.dart';

// // class LiveScreen extends StatefulWidget {
// //   @override
// //   _LiveScreenState createState() => _LiveScreenState();
// // }

// // class _LiveScreenState extends State<LiveScreen> {
// //   List<NewsItemModel> _musicList = [];

// //   final SocketService _socketService = SocketService();
// //   final ApiService _apiService = ApiService();
// //   // final FocusNode firstItemFocusNode = FocusNode();
// //   bool _isLoading = true;
// //   String _errorMessage = '';
// //   bool _isNavigating = false;
// //   int _maxRetries = 3;
// //   int _retryDelay = 5; // seconds
// //   Timer? _timer;

// //   // Track current focus position
// //   int _currentRow = 0;
// //   int _currentCol = 0;
// //   final int _crossAxisCount = 5;
// //   final List<List<FocusNode>> _focusNodes = [];
// //   final ScrollController _scrollController = ScrollController();

// //   @override
// //   void initState() {
// //     super.initState();
// //     _socketService.initSocket();
// //     checkServerStatus();
// //     _loadCachedDataAndFetchLive();

// //     _apiService.updateStream.listen((hasChanges) {
// //       if (hasChanges) {
// //         _loadCachedDataAndFetchLive();
// //       }
// //     });
// //   }

// //   @override
// //   void dispose() {
// //     _scrollController.dispose();
// //     for (var row in _focusNodes) {
// //       for (var node in row) {
// //         node.dispose();
// //       }
// //     }
// //     _socketService.dispose();
// //     _timer?.cancel();
// //     super.dispose();
// //   }

// //   final List<GlobalKey> _itemKeys = [];

// //   void _initializeKeys() {
// //     _itemKeys.clear();
// //     for (var i = 0; i < _musicList.length; i++) {
// //       _itemKeys.add(GlobalKey());
// //     }
// //     print('Initialized ${_itemKeys.length} keys');
// //   }

// //   void _initializeFocusNodes() {
// //     _initializeKeys(); // Initialize keys for all items
// //     _focusNodes.clear();
// //     final rowCount = (_musicList.length / _crossAxisCount).ceil();

// //     for (int i = 0; i < rowCount; i++) {
// //       List<FocusNode> row = [];
// //       for (int j = 0; j < _crossAxisCount; j++) {
// //         if (i * _crossAxisCount + j < _musicList.length) {
// //           row.add(FocusNode());
// //           final identifier = 'item_${i}_${j}';
// //           context.read<FocusProvider>().registerElementKey(
// //                 identifier,
// //                 _itemKeys[i * _crossAxisCount + j],
// //               );
// //         }
// //       }
// //       _focusNodes.add(row);
// //     }

// //     if (_focusNodes.isNotEmpty && _focusNodes[0].isNotEmpty) {
// //       context.read<FocusProvider>().setLiveScreenFocusNode(_focusNodes[0][0]);
// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         _focusNodes[0][0].requestFocus();
// //       });
// //     }
// //   }

// //   Widget _buildNewsList() {
// //     return Padding(
// //       padding: const EdgeInsets.all(8.0),
// //       child: LayoutBuilder(
// //         builder: (context, constraints) {
// //           // Calculate item height based on aspect ratio
// //           final itemWidth = constraints.maxWidth / _crossAxisCount;
// //           final itemHeight = itemWidth * 0.00001; // 16:9 aspect ratio

// //           // Add extra padding for focus effect
// //           final focusPadding =
// //               itemHeight * 0.0; // 15% of item height for focus effect

// //           return Container(
// //             // Add padding at top and bottom to prevent cutoff
// //             padding: EdgeInsets.only(top: focusPadding, bottom: focusPadding),
// //             child: GridView.builder(
// //               controller: _scrollController,
// //               physics: const AlwaysScrollableScrollPhysics(),
// //               clipBehavior: Clip.none, // Allow items to overflow their bounds
// //               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //                 crossAxisCount: _crossAxisCount,
// //                 // mainAxisSpacing: 20.0, // Increased spacing between rows
// //                 // crossAxisSpacing: 10.0,
// //                 // childAspectRatio: 16/9,
// //                 // childAspectRatio: 1.2,
// //               ),
// //               itemCount: _musicList.length,
// //               itemBuilder: (context, index) {
// //                 final row = index ~/ _crossAxisCount;
// //                 final col = index % _crossAxisCount;
// //                 return LiveGridItem(
// //                   key: _itemKeys[row * _crossAxisCount + col],
// //                   item: _musicList[index],
// //                   hideDescription: true,
// //                   onTap: () => _navigateToVideoScreen(_musicList[index]),
// //                   onEnterPress: _handleEnterPress,
// //                   focusNode: _focusNodes[row][col],
// //                   onUpPress: () => _handleUpPress(row, col),
// //                   onDownPress: () => _handleDownPress(row, col),

// //                   onLeftPress: () =>
// //                       _handleLeftPress(row, col), // Add Left Navigation
// //                   onRightPress: () =>
// //                       _handleRightPress(row, col), // Add Right Navigation
// //                 );
// //               },
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   void _handleLeftPress(int row, int col) {
// //     if (col > 0) {
// //       // Ensure it's not the first column
// //       _focusNodes[row][col - 1].requestFocus();
// //       setState(() {
// //         _currentCol = col - 1;
// //       });
// //     }
// //   }

// //   void _handleRightPress(int row, int col) {
// //     if (col < _crossAxisCount - 1 && col + 1 < _focusNodes[row].length) {
// //       // Ensure it's not the last column
// //       _focusNodes[row][col + 1].requestFocus();
// //       setState(() {
// //         _currentCol = col + 1;
// //       });
// //     }
// //   }

// // // Update the scroll method to handle scrolling properly
// //   void _scrollToFocusedItem(int row, int col) {
// //     final itemIndex = row * _crossAxisCount + col;
// //     final viewportHeight = _scrollController.position.viewportDimension;
// //     final itemHeight =
// //         viewportHeight / (_crossAxisCount / 2); // Approximate height

// //     final targetOffset = (itemIndex ~/ _crossAxisCount) * itemHeight;

// //     if (_scrollController.hasClients) {
// //       _scrollController.animateTo(
// //         targetOffset,
// //         duration: const Duration(seconds: 1),
// //         curve: Curves.easeInOut,
// //       );
// //     }
// //   }

// // // Update the focus handlers to include scrolling
// //   void _handleUpPress(int row, int col) {
// //     if (row == 0) {
// //       context.read<FocusProvider>().requestLiveTvFocus();
// //     } else if (row > 0 && _focusNodes[row - 1].length > col) {
// //       _scrollToFocusedItem(row - 1, col);
// //       _focusNodes[row - 1][col].requestFocus();
// //       setState(() {
// //         _currentRow = row - 1;
// //         _currentCol = col;
// //       });
// //     }
// //   }

// //   void _handleDownPress(int row, int col) {
// //     if (row < _focusNodes.length - 1 && _focusNodes[row + 1].length > col) {
// //       _scrollToFocusedItem(row + 1, col);
// //       _focusNodes[row + 1][col].requestFocus();
// //       setState(() {
// //         _currentRow = row + 1;
// //         _currentCol = col;
// //       });
// //     }
// //   }

// //   Future<void> _loadCachedDataAndFetchLive() async {
// //     setState(() {
// //       _isLoading = true;
// //       _errorMessage = '';
// //     });

// //     try {
// //       // Step 1: Load cached data
// //       final cachedDataAvailable = await _loadCachedLiveData();

// //       // Step 2: Fetch live data immediately if no cache is available
// //       if (!cachedDataAvailable) {
// //         await _fetchLiveDataInBackground();
// //       }
// //     } catch (e) {
// //       setState(() {
// //         _errorMessage = 'Failed to load live data';
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   Future<bool> _loadCachedLiveData() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final cachedLive = prefs.getString('live_list');

// //       if (cachedLive != null) {
// //         final List<dynamic> cachedData = json.decode(cachedLive);
// //         setState(() {
// //           _musicList =
// //               cachedData.map((item) => NewsItemModel.fromJson(item)).toList();
// //           _isLoading = false; // Show cached data immediately
// //         });

// //         _initializeFocusNodes();
// //         return true; // Cache was found and loaded
// //       }
// //     } catch (e) {
// //       print('Error loading cached live data: $e');
// //     }
// //     return false; // No cache found
// //   }

// //   Future<void> _fetchLiveDataInBackground() async {
// //     try {
// //       // Fetch new live data
// //       final newLiveList = await _apiService.fetchMusicData();

// //       final prefs = await SharedPreferences.getInstance();
// //       final cachedLive = prefs.getString('live_list');

// //       if (cachedLive != json.encode(newLiveList)) {
// //         // Update cache if the live data is different
// //         prefs.setString('live_list', json.encode(newLiveList));

// //         // Update UI with new data
// //         setState(() {
// //           _musicList = newLiveList;
// //         });
// //       }

// //       _initializeFocusNodes();

// //       setState(() {
// //         _isLoading =
// //             false; // Stop the loading indicator after live data is fetched
// //       });
// //     } catch (e) {
// //       setState(() {
// //         _errorMessage = 'Error fetching live data';
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   void checkServerStatus() {
// //     Timer.periodic(Duration(seconds: 10), (timer) {
// //       // Check if the socket is connected, otherwise attempt to reconnect
// //       if (!_socketService.socket!.connected) {
// //         // print('YouTube server down, retrying...');
// //         _socketService.initSocket(); // Re-establish the socket connection
// //       }
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: cardColor,
// //       body: Padding(
// //         padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.04),
// //         child: _buildBody(),
// //       ),
// //     );
// //   }

// //   Widget _buildBody() {
// //     if (_isLoading) {
// //       return LoadingIndicator();
// //     } else if (_errorMessage.isNotEmpty) {
// //       return Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           ErrorMessage(message: _errorMessage),
// //           ElevatedButton(
// //             onPressed:
// //                 _loadCachedDataAndFetchLive, // Retry fetching data on button press
// //             child: Text('Retry'),
// //           ),
// //         ],
// //       );
// //     } else if (_musicList.isEmpty) {
// //       return EmptyState(message: 'Something Went Wrong');
// //     } else {
// //       return _buildNewsList();
// //     }
// //   }

// //   void _handleEnterPress(String itemId) {
// //     final selectedItem = _musicList.firstWhere((item) => item.id == itemId);
// //     _navigateToVideoScreen(selectedItem);
// //   }

// //   Future<void> _navigateToVideoScreen(NewsItemModel newsItem) async {
// //     if (_isNavigating) return;
// //     _isNavigating = true;

// //     bool shouldPlayVideo = true;
// //     bool shouldPop = true;

// //     // Show loading indicator while video is loading
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (BuildContext context) {
// //         return WillPopScope(
// //           onWillPop: () async {
// //             shouldPlayVideo = false;
// //             shouldPop = false;
// //             return true;
// //           },
// //           child: LoadingIndicator(),
// //         );
// //       },
// //     );

// //     Timer(Duration(seconds: 10), () {
// //       _isNavigating = false;
// //     });

// //     try {
// //       String originalUrl = newsItem.url;
// //       if (newsItem.streamType == 'YoutubeLive') {
// //         // Retry fetching the updated URL if stream type is YouTube Live
// //         for (int i = 0; i < _maxRetries; i++) {
// //           try {
// //             String updatedUrl =
// //                 await _socketService.getUpdatedUrl(newsItem.url);
// //             newsItem = NewsItemModel(
// //               id: newsItem.id,
// //               videoId: '',
// //               name: newsItem.name,
// //               description: newsItem.description,
// //               banner: newsItem.banner,
// //               poster: newsItem.poster,
// //               category: newsItem.category,
// //               url: updatedUrl,
// //               streamType: 'M3u8',
// //               type: 'M3u8',
// //               genres: newsItem.genres,
// //               status: newsItem.status,
// //               index: newsItem.index,
// //               image: '',
// //               unUpdatedUrl: '',
// //             );
// //             break; // Exit loop when URL is successfully updated
// //           } catch (e) {
// //             if (i == _maxRetries - 1) rethrow; // Rethrow error on last retry
// //             await Future.delayed(
// //                 Duration(seconds: _retryDelay)); // Delay before next retry
// //           }
// //         }
// //       }

// //       if (shouldPop) {
// //         Navigator.of(context, rootNavigator: true).pop();
// //       }

// //       bool liveStatus = true;

// //       if (shouldPlayVideo) {
// //         await Navigator.push(
// //           context,
// //           MaterialPageRoute(
// //             builder: (context) => VideoScreen(
// //               videoUrl: newsItem.url,
// //               bannerImageUrl: newsItem.banner,
// //               startAtPosition: Duration.zero,
// //               videoType: newsItem.streamType,
// //               channelList: _musicList,
// //               isLive: true,
// //               isVOD: false,
// //               isBannerSlider: false,
// //               source: 'isLiveScreen',
// //               isSearch: false,
// //               videoId: int.tryParse(newsItem.id),
// //               unUpdatedUrl: originalUrl,
// //               name: newsItem.name,
// //               liveStatus: liveStatus,
// //               // seasonId: null,
// //               // isLastPlayedStored: false,
// //             ),
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       if (shouldPop) {
// //         Navigator.of(context, rootNavigator: true).pop();
// //       }
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Something Went Wrong')),
// //       );
// //     } finally {
// //       _isNavigating = false;
// //     }
// //   }

// //   // @override
// //   // void dispose() {
// //   //   _socketService.dispose();
// //   //   firstItemFocusNode.dispose();
// //   //   _timer?.cancel();
// //   //   super.dispose();
// //   // }
// // }

// import 'dart:async';
// import 'dart:convert';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/video_widget/live_video_screen.dart';
// import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:math' as math;

// // // Placeholder for NewsItemModel
// // class NewsItemModel {
// //   String id;
// //   String videoId;
// //   String name;
// //   String description;
// //   String banner;
// //   String poster;
// //   String category;
// //   String url;
// //   String streamType;
// //   String type;
// //   String genres;
// //   String status;
// //   String index;
// //   String image;
// //   // String unUpdatedUrl;
// //   String updatedAt;

// //   NewsItemModel({
// //     required this.id,
// //     required this.videoId,
// //     required this.name,
// //     required this.description,
// //     required this.banner,
// //     required this.poster,
// //     required this.category,
// //     required this.url,
// //     required this.streamType,
// //     required this.type,
// //     required this.genres,
// //     required this.status,
// //     required this.index,
// //     required this.image,
// //     // required this.unUpdatedUrl,
// //     required this.updatedAt,
// //   });
// // }

// // Professional Color Palette
// class ProfessionalColors {
//   static const primaryDark = Color(0xFF0A0E1A);
//   static const surfaceDark = Color(0xFF1A1D29);
//   static const cardDark = Color(0xFF2A2D3A);
//   static const accentBlue = Color(0xFF3B82F6);
//   static const accentPurple = Color(0xFF8B5CF6);
//   static const accentGreen = Color(0xFF10B981);
//   static const accentRed = Color(0xFFEF4444);
//   static const textPrimary = Color(0xFFFFFFFF);
//   static const textSecondary = Color(0xFFB3B3B3);
//   static List<Color> gradientColors = [
//     accentBlue,
//     accentPurple,
//     accentGreen,
//   ];
// }

// // Professional Animation Durations
// class AnimationTiming {
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
//   static const Duration slow = Duration(milliseconds: 600);
//   static const Duration scroll = Duration(milliseconds: 800);
// }

// // NewsChannel Model
// class NewsChannel {
//   final int id;
//   final int channelNumber;
//   final String name;
//   final String updatedAt;
//   final String? description;
//   final String banner;
//   final String url;
//   final String streamType;
//   final String genres;
//   final int status;

//   NewsChannel({
//     required this.id,
//     required this.channelNumber,
//     required this.name,
//     required this.updatedAt,
//     this.description,
//     required this.banner,
//     required this.url,
//     required this.streamType,
//     required this.genres,
//     required this.status,
//   });

//   factory NewsChannel.fromJson(Map<String, dynamic> json) {
//     return NewsChannel(
//       id: json['id'] ?? 0,
//       channelNumber: json['channel_number'] ?? 0,
//       name: json['name'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       description: json['description'],
//       banner: json['banner'] ?? '',
//       url: json['url'] ?? '',
//       streamType: json['stream_type'] ?? '',
//       genres: json['genres'] ?? '',
//       status: json['status'] ?? 0,
//     );
//   }
// }

// // --- MAIN WIDGET FOR THE NEW PAGE ---

// class LiveScreen extends StatefulWidget {
//   const LiveScreen({Key? key}) : super(key: key);

//   @override
//   _LiveScreenState createState() => _LiveScreenState();
// }

// class _LiveScreenState extends State<LiveScreen> with TickerProviderStateMixin {
//   // State Management
//   List<NewsChannel> _activeChannels = [];
//   bool _isLoading = true;
//   String _errorMessage = '';

//   // Focus and Scroll Management
//   final Map<String, FocusNode> _channelFocusNodes = {};
//   int _gridFocusedIndex = 0;
//   final int _columnsCount = 6;
//   late final ScrollController _scrollController;

//   // Grid dimensions for scroll calculations
//   static const double _gridSpacing = 25.0;
//   static const double _gridAspectRatio = 1.4;

//   // Animation
//   late final AnimationController _fadeController;
//   late final AnimationController _staggerController;
//   late final Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _initializeAnimations();
//     _fetchData();
//   }

//   void _initializeChannelFocusNodes() {
//     _channelFocusNodes.clear();
//     for (int i = 0; i < _activeChannels.length; i++) {
//       String channelId = _activeChannels[i].id.toString();
//       _channelFocusNodes[channelId] = FocusNode()
//         ..addListener(() {
//           if (mounted && _channelFocusNodes[channelId]!.hasFocus) {
//             if (_gridFocusedIndex != i) {
//               setState(() => _gridFocusedIndex = i);
//             }
//             _scrollToFocusedItem();
//           }
//         });
//     }

//     // ADD THIS: Register the first focus node with FocusProvider
//     if (_activeChannels.isNotEmpty) {
//       final firstChannelId = _activeChannels[0].id.toString();
//       final firstFocusNode = _channelFocusNodes[firstChannelId];
//       if (firstFocusNode != null) {
//         context.read<FocusProvider>().setLiveScreenFocusNode(firstFocusNode);
//       }
//     }
//   }

//   void _focusFirstGridItem() {
//     if (_activeChannels.isNotEmpty && mounted) {
//       final firstChannelId = _activeChannels[0].id.toString();
//       final firstFocusNode = _channelFocusNodes[firstChannelId];

//       print('Focusing first item. FocusNode null: ${firstFocusNode == null}');

//       if (firstFocusNode != null) {
//         // Use a slight delay to ensure the widget is fully built
//         Future.delayed(const Duration(milliseconds: 150), () {
//           if (mounted) {
//             setState(() => _gridFocusedIndex = 0);
//             FocusScope.of(context).requestFocus(firstFocusNode);

//             // ALSO UPDATE: Update the FocusProvider with the current focus node
//             context
//                 .read<FocusProvider>()
//                 .setLiveScreenFocusNode(firstFocusNode);
//           }
//         });
//       }
//     }
//   }

//   void _initializeAnimations() {
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//     _staggerController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _fadeController.dispose();
//     _staggerController.dispose();
//     for (var node in _channelFocusNodes.values) {
//       node.dispose();
//     }
//     super.dispose();
//   }

//   /// Fetches all channels, combines them, and filters for active ones.
//   Future<void> _fetchData() async {
//     if (!mounted) return;
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final authKey = prefs.getString('result_auth_key') ?? '';
//       final response = await http.get(
//         Uri.parse(
//             'https://dashboard.cpplayers.com/public/api/getFeaturedLiveTV'),
//         headers: {'auth-key': authKey},
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         final List<NewsChannel> allChannels = [];

//         data.forEach((category, channelsData) {
//           if (channelsData is List) {
//             allChannels.addAll(
//               channelsData.map((item) => NewsChannel.fromJson(item)).toList(),
//             );
//           }
//         });

//         if (mounted) {
//           setState(() {
//             _activeChannels =
//                 allChannels.where((ch) => ch.status == 1).toList();
//             _isLoading = false;
//           });

//           if (_activeChannels.isNotEmpty) {
//             _initializeChannelFocusNodes();
//             _fadeController.forward();
//             _staggerController.forward();

//             // Ensure focus is set after animations start
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               if (mounted) {
//                 _focusFirstGridItem();
//               }
//             });
//           }
//         }
//       } else {
//         throw Exception('Failed to load channels: ${response.statusCode}');
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = 'Network Error. Please check your connection.';
//         });
//       }
//     }
//   }

//   // void _initializeChannelFocusNodes() {
//   //   _channelFocusNodes.clear();
//   //   for (int i = 0; i < _activeChannels.length; i++) {
//   //     String channelId = _activeChannels[i].id.toString();
//   //     _channelFocusNodes[channelId] = FocusNode()
//   //       ..addListener(() {
//   //         if (mounted && _channelFocusNodes[channelId]!.hasFocus) {
//   //           if (_gridFocusedIndex != i) {
//   //             setState(() => _gridFocusedIndex = i);
//   //           }
//   //           _scrollToFocusedItem();
//   //         }
//   //       });
//   //   }
//   // }

//   // void _focusFirstGridItem() {
//   //   if (_activeChannels.isNotEmpty && mounted) {
//   //     final firstChannelId = _activeChannels[0].id.toString();
//   //     final firstFocusNode = _channelFocusNodes[firstChannelId];

//   //     print('Focusing first item. FocusNode null: ${firstFocusNode == null}');

//   //     if (firstFocusNode != null) {
//   //       // Use a slight delay to ensure the widget is fully built
//   //       Future.delayed(const Duration(milliseconds: 150), () {
//   //         if (mounted) {
//   //           setState(() => _gridFocusedIndex = 0);
//   //           FocusScope.of(context).requestFocus(firstFocusNode);
//   //         }
//   //       });
//   //     }
//   //   }
//   // }

//   void _scrollToFocusedItem() {
//     if (!mounted || _activeChannels.isEmpty) return;

//     // Calculate current row of focused item
//     final currentRow = _gridFocusedIndex ~/ _columnsCount;

//     // Calculate item dimensions dynamically
//     final screenWidth =
//         MediaQuery.of(context).size.width - (40.0 * 2); // Subtract padding
//     final availableWidth = screenWidth - ((_columnsCount - 1) * _gridSpacing);
//     final itemWidth = availableWidth / _columnsCount;
//     final itemHeight = itemWidth / _gridAspectRatio;
//     final rowHeight = itemHeight + _gridSpacing;

//     // Get current scroll position and viewport height
//     final currentScrollOffset = _scrollController.offset;
//     final viewportHeight = _scrollController.position.viewportDimension;

//     // Calculate how many complete rows are visible
//     final visibleRows = (viewportHeight / rowHeight).floor();
//     final firstVisibleRow = (currentScrollOffset / rowHeight).floor();
//     final lastVisibleRow = firstVisibleRow + visibleRows - 1;

//     print(
//         'Scroll Debug - Current Row: $currentRow, First Visible: $firstVisibleRow, Last Visible: $lastVisibleRow');

//     // Determine if we need to scroll
//     double? targetScrollOffset;

//     if (currentRow < firstVisibleRow) {
//       // Focused item is above visible area - scroll up to show this row at top
//       targetScrollOffset = currentRow * rowHeight;
//       print('Scrolling UP to offset: $targetScrollOffset');
//     } else if (currentRow > lastVisibleRow) {
//       // Focused item is below visible area - scroll down to show this row at bottom
//       targetScrollOffset = (currentRow - visibleRows + 1) * rowHeight;
//       print('Scrolling DOWN to offset: $targetScrollOffset');
//     }

//     // Animate to target position if scrolling is needed
//     if (targetScrollOffset != null) {
//       final clampedOffset = targetScrollOffset.clamp(
//         _scrollController.position.minScrollExtent,
//         _scrollController.position.maxScrollExtent,
//       );

//       _scrollController.animateTo(
//         clampedOffset,
//         duration: AnimationTiming.scroll,
//         curve: Curves.easeInOutCubic,
//       );
//     }
//   }

//   // /// Enhanced grid navigation with better bounds checking
//   // void _navigateGrid(LogicalKeyboardKey key) {
//   //   if (_isLoading || _activeChannels.isEmpty) return;

//   //   print('Navigate: ${key.debugName}, Current Index: $_gridFocusedIndex');

//   //   int newIndex = _gridFocusedIndex;
//   //   final totalItems = _activeChannels.length;
//   //   final currentRow = _gridFocusedIndex ~/ _columnsCount;
//   //   final currentCol = _gridFocusedIndex % _columnsCount;

//   //   switch (key) {
//   //     case LogicalKeyboardKey.arrowRight:
//   //       if (_gridFocusedIndex < totalItems - 1) {
//   //         newIndex = _gridFocusedIndex + 1;
//   //       }
//   //       break;

//   //     case LogicalKeyboardKey.arrowLeft:
//   //       if (_gridFocusedIndex > 0) {
//   //         newIndex = _gridFocusedIndex - 1;
//   //       }
//   //       break;

//   //     case LogicalKeyboardKey.arrowDown:
//   //       final nextRowIndex = (currentRow + 1) * _columnsCount + currentCol;
//   //       if (nextRowIndex < totalItems) {
//   //         newIndex = nextRowIndex;
//   //       }
//   //       break;

//   //     case LogicalKeyboardKey.arrowUp:
//   //       if (currentRow > 0) {
//   //         newIndex = (currentRow - 1) * _columnsCount + currentCol;
//   //       }
//   //       break;
//   //   }

//   //   if (newIndex != _gridFocusedIndex && newIndex >= 0 && newIndex < totalItems) {
//   //     print('Moving from $_gridFocusedIndex to $newIndex');

//   //     final newChannelId = _activeChannels[newIndex].id.toString();
//   //     final newFocusNode = _channelFocusNodes[newChannelId];

//   //     if (newFocusNode != null && mounted) {
//   //       setState(() => _gridFocusedIndex = newIndex);
//   //       FocusScope.of(context).requestFocus(newFocusNode);
//   //     }
//   //   }
//   // }

//   /// Enhanced grid navigation with menu focus support
//   void _navigateGrid(LogicalKeyboardKey key) {
//     if (_isLoading || _activeChannels.isEmpty) return;

//     print('Navigate: ${key.debugName}, Current Index: $_gridFocusedIndex');

//     int newIndex = _gridFocusedIndex;
//     final totalItems = _activeChannels.length;
//     final currentRow = _gridFocusedIndex ~/ _columnsCount;
//     final currentCol = _gridFocusedIndex % _columnsCount;

//     switch (key) {
//       case LogicalKeyboardKey.arrowRight:
//         if (_gridFocusedIndex < totalItems - 1) {
//           newIndex = _gridFocusedIndex + 1;
//         }
//         break;

//       case LogicalKeyboardKey.arrowLeft:
//         if (_gridFocusedIndex > 0) {
//           newIndex = _gridFocusedIndex - 1;
//         }
//         break;

//       case LogicalKeyboardKey.arrowDown:
//         final nextRowIndex = (currentRow + 1) * _columnsCount + currentCol;
//         if (nextRowIndex < totalItems) {
//           newIndex = nextRowIndex;
//         }
//         break;

//       case LogicalKeyboardKey.arrowUp:
//         // NEW LOGIC: If in first row, move focus to menu
//         if (currentRow == 0) {
//           // Move focus to menu/previous screen
//           _requestMenuFocus();
//           return; // Exit early, don't process grid navigation
//         } else if (currentRow > 0) {
//           newIndex = (currentRow - 1) * _columnsCount + currentCol;
//         }
//         break;
//     }

//     if (newIndex != _gridFocusedIndex &&
//         newIndex >= 0 &&
//         newIndex < totalItems) {
//       print('Moving from $_gridFocusedIndex to $newIndex');

//       final newChannelId = _activeChannels[newIndex].id.toString();
//       final newFocusNode = _channelFocusNodes[newChannelId];

//       if (newFocusNode != null && mounted) {
//         setState(() => _gridFocusedIndex = newIndex);
//         FocusScope.of(context).requestFocus(newFocusNode);
//       }
//     }
//   }

//   /// Moves focus to menu/previous screen
//   void _requestMenuFocus() {
//     // Option 1: If you have FocusProvider, uncomment this line:
//     context.read<FocusProvider>().requestLiveTvFocus();

//     // Option 2: If you want to navigate back to previous screen:
//     // Navigator.of(context).pop();

//     // Option 3: If you have a specific menu focus node, request focus on it:
//     // menuFocusNode.requestFocus();

//     // Option 4: For now, just print debug info (replace with your actual implementation)
//     print('Requesting menu focus - implement your menu focus logic here');

//     // Provide haptic feedback
//     HapticFeedback.lightImpact();
//   }

//   /// Handles channel selection and navigates to the video player.
//   Future<void> _handleChannelTap(NewsChannel channel) async {
//     // Convert current channel and the full active list to NewsItemModel
//     final currentIndex = _activeChannels.indexOf(channel);
//     final allItems = _activeChannels
//         .map((ch) => NewsItemModel(
//               id: ch.id.toString(),
//               name: ch.name,
//               banner: ch.banner,
//               updatedAt: ch.updatedAt,
//               url: ch.url,
//               streamType: ch.streamType,
//               genres: ch.genres,
//               status: ch.status.toString(),
//               index: _activeChannels.indexOf(ch).toString(),
//               // Fill other fields as needed
//               videoId: '', description: ch.description ?? '', poster: ch.banner,
//               category: ch.genres,
//               type: ch.streamType, image: ch.banner,
//               unUpdatedUrl: ch.url,
//             ))
//         .toList();

//     if (!mounted) return;

//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => LiveVideoScreen(
//           videoUrl: channel.url,
//           bannerImageUrl: channel.banner,
//           name: channel.name,
//           channelList: allItems,
//           // channelList: [],
//           liveStatus: true,
//           // --- Pass other required parameters ---
//           // startAtPosition: Duration.zero,
//           // videoType: channel.streamType,
//           // isLive: true,
//           // isVOD: false,
//           // isBannerSlider: false,
//           // source: 'isLiveScreen',
//           // isSearch: false,
//           videoId: channel.id,
//           updatedAt: channel.updatedAt,
//           source: 'isLiveMeenu',
//           // unUpdatedUrl: channel.url,
//         ),
//       ),
//     );

//     // Restore focus after returning from the video screen
//     Future.delayed(const Duration(milliseconds: 300), () {
//       if (mounted && currentIndex < _activeChannels.length) {
//         final channelId = _activeChannels[currentIndex].id.toString();
//         final focusNode = _channelFocusNodes[channelId];
//         if (focusNode != null) {
//           setState(() => _gridFocusedIndex = currentIndex);
//           FocusScope.of(context).requestFocus(focusNode);
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Stack(
//         children: [
//           // Main Content
//           FadeTransition(
//             opacity: _fadeAnimation,
//             child: Column(
//               children: [
//                 SizedBox(
//                     height: MediaQuery.of(context).padding.top +
//                         80), // AppBar Placeholder
//                 Expanded(child: _buildBody()),
//               ],
//             ),
//           ),
//           // AppBar on Top
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: _buildProfessionalAppBar(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return const ProfessionalLoadingIndicator(
//           message: 'Loading All Channels...');
//     }
//     if (_errorMessage.isNotEmpty) {
//       return _buildErrorWidget();
//     }
//     if (_activeChannels.isEmpty) {
//       return _buildEmptyWidget();
//     }
//     return _buildChannelsGrid();
//   }

//   Widget _buildProfessionalAppBar() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             ProfessionalColors.primaryDark.withOpacity(0.95),
//             ProfessionalColors.surfaceDark.withOpacity(0.8),
//             Colors.transparent,
//           ],
//         ),
//       ),
//       child: ClipRRect(
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//           child: Padding(
//             padding: EdgeInsets.only(
//               top: MediaQuery.of(context).padding.top + 20,
//               left: 40,
//               right: 40,
//               bottom: 20,
//             ),
//             child: Row(
//               children: [
//                 ShaderMask(
//                   shaderCallback: (bounds) => const LinearGradient(
//                     colors: [
//                       ProfessionalColors.accentGreen,
//                       ProfessionalColors.accentBlue,
//                     ],
//                   ).createShader(bounds),
//                   child: const Text(
//                     'ALL LIVE CHANNELS',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 1.5,
//                     ),
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: ProfessionalColors.accentGreen.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(15),
//                     border: Border.all(
//                       color: ProfessionalColors.accentGreen.withOpacity(0.4),
//                     ),
//                   ),
//                   child: Text(
//                     '${_activeChannels.length} Channels Available',
//                     style: const TextStyle(
//                       color: ProfessionalColors.accentGreen,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildChannelsGrid() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
//       child: Focus(
//         autofocus: true, // Keep this for initial focus
//         onKey: (node, event) {
//           if (event is RawKeyDownEvent) {
//             if ([
//               LogicalKeyboardKey.arrowUp,
//               LogicalKeyboardKey.arrowDown,
//               LogicalKeyboardKey.arrowLeft,
//               LogicalKeyboardKey.arrowRight
//             ].contains(event.logicalKey)) {
//               _navigateGrid(event.logicalKey);
//               return KeyEventResult.handled;
//             }
//             if (event.logicalKey == LogicalKeyboardKey.select ||
//                 event.logicalKey == LogicalKeyboardKey.enter) {
//               _handleChannelTap(_activeChannels[_gridFocusedIndex]);
//               return KeyEventResult.handled;
//             }
//           }
//           return KeyEventResult.ignored;
//         },
//         child: GridView.builder(
//           controller: _scrollController,
//           clipBehavior: Clip.none,
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 6,
//             mainAxisSpacing: _gridSpacing,
//             crossAxisSpacing: _gridSpacing,
//             childAspectRatio: _gridAspectRatio,
//           ),
//           itemCount: _activeChannels.length,
//           itemBuilder: (context, index) {
//             final channel = _activeChannels[index];
//             final channelId = channel.id.toString();
//             final delay = (index / _activeChannels.length) * 0.5;
//             final animationValue = Interval(
//               delay,
//               (delay + 0.5).clamp(0.0, 1.0),
//               curve: Curves.easeOutCubic,
//             ).transform(_staggerController.value);

//             return Transform.translate(
//               offset: Offset(0, 50 * (1 - animationValue)),
//               child: Opacity(
//                 opacity: animationValue,
//                 child: ProfessionalGridChannelCard(
//                   channel: channel,
//                   focusNode: _channelFocusNodes[channelId]!,
//                   onTap: () => _handleChannelTap(channel),
//                   index: index,
//                   categoryTitle: channel.genres,
//                   isFocused: index == _gridFocusedIndex, // Pass focus state
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.error_outline,
//               color: ProfessionalColors.accentRed, size: 50),
//           const SizedBox(height: 16),
//           const Text('Oops! Something Went Wrong',
//               style: TextStyle(color: Colors.white, fontSize: 18)),
//           const SizedBox(height: 8),
//           Text(_errorMessage,
//               style: const TextStyle(color: Colors.white70, fontSize: 14)),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: _fetchData,
//             child: const Text('Try Again'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyWidget() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.tv_off_outlined,
//               color: ProfessionalColors.textSecondary, size: 50),
//           SizedBox(height: 16),
//           Text('No Live Channels Found',
//               style: TextStyle(color: Colors.white, fontSize: 18)),
//           SizedBox(height: 8),
//           Text('Please check back later for new content.',
//               style: TextStyle(color: Colors.white70, fontSize: 14)),
//         ],
//       ),
//     );
//   }
// }

// // --- UPDATED HELPER WIDGETS ---

// class ProfessionalGridChannelCard extends StatefulWidget {
//   final NewsChannel channel;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int index;
//   final String categoryTitle;
//   final bool isFocused; // Added this parameter

//   const ProfessionalGridChannelCard({
//     Key? key,
//     required this.channel,
//     required this.focusNode,
//     required this.onTap,
//     required this.index,
//     required this.categoryTitle,
//     required this.isFocused, // Added this
//   }) : super(key: key);

//   @override
//   _ProfessionalGridChannelCardState createState() =>
//       _ProfessionalGridChannelCardState();
// }

// class _ProfessionalGridChannelCardState
//     extends State<ProfessionalGridChannelCard> with TickerProviderStateMixin {
//   late AnimationController _hoverController;
//   late Animation<double> _scaleAnimation;
//   Color _dominantColor = ProfessionalColors.accentBlue;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     _hoverController =
//         AnimationController(duration: AnimationTiming.fast, vsync: this);
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
//       CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
//     );
//     widget.focusNode.addListener(_handleFocusChange);
//     _isFocused = widget.isFocused; // Initialize with the passed value

//     // Set initial animation state
//     if (_isFocused) {
//       _hoverController.forward();
//       _dominantColor = ProfessionalColors.gradientColors[
//           widget.index % ProfessionalColors.gradientColors.length];
//     }
//   }

//   @override
//   void didUpdateWidget(ProfessionalGridChannelCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.isFocused != oldWidget.isFocused) {
//       setState(() => _isFocused = widget.isFocused);
//       if (_isFocused) {
//         _hoverController.forward();
//         _dominantColor = ProfessionalColors.gradientColors[
//             widget.index % ProfessionalColors.gradientColors.length];
//       } else {
//         _hoverController.reverse();
//       }
//     }
//   }

//   void _handleFocusChange() {
//     if (!mounted) return;
//     final hasFocus = widget.focusNode.hasFocus;
//     if (hasFocus != _isFocused) {
//       setState(() => _isFocused = hasFocus);
//       if (_isFocused) {
//         _hoverController.forward();
//         _dominantColor = ProfessionalColors.gradientColors[
//             widget.index % ProfessionalColors.gradientColors.length];
//         HapticFeedback.lightImpact();
//       } else {
//         _hoverController.reverse();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _hoverController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Focus(
//         focusNode: widget.focusNode,
//         child: AnimatedBuilder(
//           animation: _scaleAnimation,
//           builder: (context, child) {
//             return Transform.scale(
//               scale: _scaleAnimation.value,
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: [
//                     if (_isFocused)
//                       BoxShadow(
//                         color: _dominantColor.withOpacity(0.5),
//                         blurRadius: 25,
//                         spreadRadius: 2,
//                       )
//                     else
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.4),
//                         blurRadius: 10,
//                         offset: const Offset(0, 5),
//                       ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       _buildChannelImage(),
//                       _buildGradientOverlay(),
//                       if (_isFocused) _buildFocusBorder(),
//                       _buildChannelInfo(),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildChannelImage() {
//     return widget.channel.banner.isNotEmpty
//         ? Image.network(
//             widget.channel.banner,
//             fit: BoxFit.cover,
//             errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
//             loadingBuilder: (_, child, progress) =>
//                 progress == null ? child : _buildImagePlaceholder(),
//           )
//         : _buildImagePlaceholder();
//   }

//   Widget _buildImagePlaceholder() {
//     return Container(
//       color: ProfessionalColors.cardDark,
//       child: const Icon(Icons.tv,
//           color: ProfessionalColors.textSecondary, size: 40),
//     );
//   }

//   Widget _buildFocusBorder() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(width: 3, color: _dominantColor),
//       ),
//     );
//   }

//   Widget _buildGradientOverlay() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.transparent,
//             Colors.black.withOpacity(0.8),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildChannelInfo() {
//     return Positioned(
//       bottom: 12,
//       left: 12,
//       right: 12,
//       child: Text(
//         widget.channel.name.toUpperCase(),
//         style: TextStyle(
//           color: _isFocused ? _dominantColor : Colors.white,
//           fontSize: 13,
//           fontWeight: FontWeight.w600,
//           shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
//         ),
//         maxLines: 2,
//         overflow: TextOverflow.ellipsis,
//       ),
//     );
//   }
// }

// class ProfessionalLoadingIndicator extends StatelessWidget {
//   final String message;
//   const ProfessionalLoadingIndicator({Key? key, this.message = 'Loading...'})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const SizedBox(
//             width: 60,
//             height: 60,
//             child: CircularProgressIndicator(
//               strokeWidth: 4,
//               valueColor:
//                   AlwaysStoppedAnimation<Color>(ProfessionalColors.accentBlue),
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             message,
//             style: const TextStyle(color: Colors.white, fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }
// }
