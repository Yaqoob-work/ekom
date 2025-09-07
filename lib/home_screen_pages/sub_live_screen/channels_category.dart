// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/video_widget/socket_service.dart';
// import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/sub_live_screen/items/more_channel_item.dart';
// import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player.dart';
// import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// import 'package:mobi_tv_entertainment/widgets/services/api_service.dart';
// import 'package:mobi_tv_entertainment/widgets/small_widgets/empty_state.dart';
// import 'package:mobi_tv_entertainment/widgets/small_widgets/error_message.dart';
// import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ChannelsCategory extends StatefulWidget {
//   @override
//   _ChannelsCategoryState createState() => _ChannelsCategoryState();
// }

// class _ChannelsCategoryState extends State<ChannelsCategory> {
//   // final List<NewsItemModel> _musicList = [];
//   List<NewsItemModel> _musicList = [];
//   final SocketService _socketService = SocketService();
//   final Map<String, List<NewsItemModel>> _groupedByGenre =
//       {}; // Group by genres
//   final ApiService _apiService = ApiService();
//   bool _isLoading = true;
//   String _errorMessage = '';
//   bool _isNavigating = false;
//   int _maxRetries = 3;
//   int _retryDelay = 5; // seconds
//   bool _isAttemptingReconnect =
//       false; // To avoid repeated reconnection attempts

//   @override
//   void initState() {
//     super.initState();
//     _socketService.initSocket();
//     checkServerStatus();
//     _loadCachedData();
//     _fetchDataInBackground();
//     _apiService.updateStream.listen((hasChanges) {
//       if (hasChanges) {
//         setState(() {
//           _isLoading = true;
//         });
//         _fetchDataInBackground();
//       }
//     });
//   }

//   void checkServerStatus() {
//     Timer.periodic(Duration(seconds: 10), (timer) {
//       // Check if the socket is connected, otherwise attempt to reconnect
//       if (!_socketService.socket!.connected && !_isAttemptingReconnect) {
//         _isAttemptingReconnect = true;
//         // print('YouTube server down, retrying...');
//         _socketService.initSocket(); // Re-establish the socket connection
//         _isAttemptingReconnect = false;
//       }
//     });
//   }

//   Future<void> _loadCachedData() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cachedEntertainment = prefs.getString('channels_category_data');

//       if (cachedEntertainment != null) {
//         final List<dynamic> cachedData = json.decode(cachedEntertainment);
//         setState(() {
//           _musicList.clear();
//           _musicList.addAll(
//               cachedData.map((item) => NewsItemModel.fromJson(item)).toList());
//           _groupByGenre(_musicList);
//           _isLoading = false;
//         });
//         print('Loaded cached data successfully');
//       } else {
//         print('No cached data found');
//         setState(() {
//           _isLoading = true;
//         });
//       }
//     } catch (e) {
//       print('Error loading cached data: $e');
//       setState(() {
//         _errorMessage = 'Error loading cached data';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchDataInBackground() async {
//     try {
//       await _apiService.fetchSettings();
//       await _apiService.fetchEntertainment();

//       final prefs = await SharedPreferences.getInstance();
//       final newEntertainmentData = json.encode(_apiService.allChannelList);

//       final cachedEntertainment = prefs.getString('channels_category_data');
//       if (cachedEntertainment != newEntertainmentData) {
//         prefs.setString('channels_category_data', newEntertainmentData);
//         setState(() {
//           _musicList.clear();
//           _musicList.addAll(_apiService.allChannelList);
//           _groupByGenre(_musicList);
//           _isLoading = false;
//         });
//         print('Fetched and updated data successfully');
//       }
//     } catch (e) {
//       print('Error fetching new data: $e');
//       setState(() {
//         _errorMessage = 'Failed to load data';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> fetchData() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       await _apiService.fetchSettings();
//       await _apiService.fetchEntertainment();

//       // Grouping by genres
//       setState(() {
//         _musicList.clear();
//         _musicList.addAll(_apiService.allChannelList); // Add fetched items

//         // Grouping items by their genres
//         _groupByGenre(_musicList);

//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Something Went Wrong';
//         _isLoading = false;
//       });
//     }
//   }

//   // Function to group items by genres
//   void _groupByGenre(List<NewsItemModel> items) {
//     _groupedByGenre.clear();
//     for (var item in items) {
//       final genres =
//           item.genres.split(','); // Split by comma if multiple genres exist
//       for (var genre in genres) {
//         genre = genre.trim();
//         if (genre.isNotEmpty) {
//           if (!_groupedByGenre.containsKey(genre)) {
//             _groupedByGenre[genre] = [];
//           }
//           _groupedByGenre[genre]?.add(item);
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: cardColor,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _buildBody(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return Center(child: LoadingIndicator());
//     } else if (_errorMessage.isNotEmpty) {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ErrorMessage(message: _errorMessage),
//           ElevatedButton(
//             onPressed: fetchData, // Retry fetching data on button press
//             child: Text('Retry'),
//           ),
//         ],
//       );
//     } else if (_groupedByGenre.isEmpty) {
//       return EmptyState(message: 'No items found');
//     } else {
//       return _buildGenreRows();
//     }
//   }

//   // Building genre rows with horizontal ListView for each genre
//   Widget _buildGenreRows() {
//     return Expanded(
//       child: ListView(
//         children: _groupedByGenre.keys.map((genre) {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: Text(
//                   genre.toUpperCase(),
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 200, // Height for each horizontal list
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: _groupedByGenre[genre]?.length ?? 0,
//                   itemBuilder: (context, index) {
//                     final item = _groupedByGenre[genre]?[index];
//                     return _buildNewsItem(item!);
//                   },
//                 ),
//               ),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildNewsItem(NewsItemModel item) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: MoreChannelItem(
//         key: Key(item.id),
//         item: item,
//         hideDescription: true,
//         onTap: () => _navigateToVideoScreen(item),
//         onEnterPress: _handleEnterPress,
//       ),
//     );
//   }

//   void _handleEnterPress(String itemId) {
//     final selectedItem = _musicList.firstWhere((item) => item.id == itemId);
//     _navigateToVideoScreen(selectedItem);
//   }

//   Future<void> _navigateToVideoScreen(NewsItemModel newsItem) async {
//     if (_isNavigating) return;
//     _isNavigating = true;

//     bool shouldPlayVideo = true;
//     bool shouldPop = true;

//     // Show loading indicator while video is loading
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return WillPopScope(
//           onWillPop: () async {
//             shouldPlayVideo = false;
//             shouldPop = false;
//             return true;
//           },
//           child: Center(child: LoadingIndicator()),
//         );
//       },
//     );

//     Timer(Duration(seconds: 10), () {
//       _isNavigating = false;
//     });

//     try {
//       String originalUrl = newsItem.url;

//       if (newsItem.streamType == 'YoutubeLive') {
//         // Retry fetching the updated URL if stream type is YouTube Live
//         // for (int i = 0; i < _maxRetries; i++) {
//         try {
//           // String updatedUrl =
//           //     await _socketService.getUpdatedUrl(newsItem.url);
//           newsItem = NewsItemModel(
//             id: newsItem.id,
//             videoId: '',
//             name: newsItem.name,
//             description: newsItem.description,
//             banner: newsItem.banner,
//             poster: newsItem.poster,
//             category: newsItem.category,
//             // url: updatedUrl,
//             url: originalUrl,
//             streamType: 'M3u8',
//             type: 'M3u8',
//             genres: newsItem.genres,
//             status: newsItem.status,
//             index: newsItem.index,
//             image: '',
//             unUpdatedUrl: '',
//           );
//           // break; // Exit loop when URL is successfully updated
//         } catch (e) {
//           // if (i == _maxRetries - 1) rethrow; // Rethrow error on last retry
//           // await Future.delayed(
//           //     Duration(seconds: _retryDelay)); // Delay before next retry
//         }
//         // }
//       }

//       if (shouldPop) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }

//       if (shouldPlayVideo) {
//         // Extract all genres of the clicked banner
//         final List<String> selectedGenres =
//             newsItem.genres.split(',').map((genre) => genre.trim()).toList();

//         // Filter the channel list based on the selected genres
//         final List<NewsItemModel> filteredChannelList =
//             _musicList.where((item) {
//           final List<String> itemGenres =
//               item.genres.split(',').map((genre) => genre.trim()).toList();
//           return selectedGenres.any((genre) => itemGenres.contains(genre));
//         }).toList();
//         bool liveStatus = true;

//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => VideoScreen(
//               videoUrl: newsItem.url,
//               bannerImageUrl: newsItem.banner,
//               startAtPosition: Duration.zero,
//               videoType: newsItem.streamType,
//               channelList: filteredChannelList,
//               isLive: true,
//               isVOD: false,
//               isBannerSlider: false,
//               source: 'isLiveScreen',
//               isSearch: false,
//               videoId: int.tryParse(newsItem.id),
//               unUpdatedUrl: originalUrl,
//               name: newsItem.name,
//               liveStatus: liveStatus,
//               // seasonId: null,
//               // isLastPlayedStored: false,
//             ),
//             //                                 builder: (context) => YouTubePlayerScreen(
//             //    videoData: VideoData(
//             //      id: newsItem.id,
//             //      title: newsItem.name,
//             //      youtubeUrl: newsItem.url,
//             //      thumbnail: newsItem.banner,
//             //      description:'',
//             //    ),
//             //    playlist: _musicList.map((m) => VideoData(
//             //      id: m.id,
//             //      title: m.name,
//             //      youtubeUrl: m.url,
//             //      thumbnail: m.banner,
//             //      description: m.description,
//             //    )).toList(),
//             // ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (shouldPop) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Something Went Wrong')),
//       );
//     } finally {
//       _isNavigating = false;
//     }
//   }

//   @override
//   void dispose() {
//     _socketService.dispose();
//     super.dispose();
//   }
// }






// // file: lib/home_screen_pages/channels_category.dart

// import 'dart:convert';
// import 'dart:ui';
// import 'dart:math' as math;
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // IMPORTANT: Make sure these import paths are correct for your project structure.
// import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player.dart';
// import 'package:mobi_tv_entertainment/provider/device_info_provider.dart';
// import 'package:mobi_tv_entertainment/video_widget/youtube_webview_player.dart';
// import '../../widgets/models/news_item_model.dart'; // Using the primary model

// // =======================================================================
// // PROFESSIONAL COLOR PALETTE
// // =======================================================================
// class ProfessionalColors {
//   static const primaryDark = Color(0xFF0A0E1A);
//   static const surfaceDark = Color(0xFF1A1D29);
//   static const cardDark = Color(0xFF2A2D3A);
//   static const accentBlue = Color(0xFF3B82F6);
//   static const accentGreen = Color(0xFF10B981);
//   static const accentRed = Color(0xFFEF4444);
//   static const textPrimary = Color(0xFFFFFFFF);
//   static const textSecondary = Color(0xFFB3B3B3);
// }

// // =======================================================================
// // GRID VIEW PAGE FOR "VIEW ALL"
// // =======================================================================
// class GenreAllChannelsPage extends StatefulWidget {
//   final String genreTitle;
//   final List<NewsItemModel> allChannels; // Changed to strong type

//   const GenreAllChannelsPage({
//     Key? key,
//     required this.genreTitle,
//     required this.allChannels,
//   }) : super(key: key);

//   @override
//   State<GenreAllChannelsPage> createState() => _GenreAllChannelsPageState();
// }

// class _GenreAllChannelsPageState extends State<GenreAllChannelsPage> {
//   final FocusNode _gridFocusNode = FocusNode();
//   int focusedIndex = 0;
//   bool _isVideoLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) _gridFocusNode.requestFocus();
//     });
//   }

//   @override
//   void dispose() {
//     _gridFocusNode.dispose();
//     super.dispose();
//   }

//   void _handleKeyNavigation(RawKeyEvent event) {
//     if (event is! RawKeyDownEvent || _isVideoLoading) return;
//     const itemsPerRow = 6; // Adjust based on your crossAxisCount
//     final totalItems = widget.allChannels.length;

//     if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//       if (focusedIndex > 0) setState(() => focusedIndex--);
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//       if (focusedIndex < totalItems - 1) setState(() => focusedIndex++);
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//       if (focusedIndex >= itemsPerRow) setState(() => focusedIndex -= itemsPerRow);
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//       if (focusedIndex < totalItems - itemsPerRow) {
//         setState(() => focusedIndex = math.min(focusedIndex + itemsPerRow, totalItems - 1));
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
//       _handleContentTap(widget.allChannels[focusedIndex]);
//       return;
//     }
//     HapticFeedback.lightImpact();
//   }

//   Future<void> _handleContentTap(NewsItemModel channel) async {
//     if (_isVideoLoading || !mounted) return;
//     setState(() => _isVideoLoading = true);
//     try {
//       if (channel.url.isEmpty) throw Exception('No video URL found');
//       if (channel.streamType == 'YoutubeLive') {
//         final deviceInfo = context.read<DeviceInfoProvider>();
//         if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
//           await Navigator.push(context, MaterialPageRoute(builder: (c) => YoutubeWebviewPlayer(videoUrl: channel.url, name: channel.name)));
//         } else {
//           await Navigator.push(context, MaterialPageRoute(builder: (c) => CustomYoutubePlayer(videoData: VideoData(id: channel.id.toString(), title: channel.name, youtubeUrl: channel.url, thumbnail: channel.banner, description: ''), playlist: [])));
//         }
//       } else {
//         await Navigator.push(context, MaterialPageRoute(builder: (c) => VideoScreen(
//               videoUrl: channel.url,
//               bannerImageUrl: channel.banner,
//               startAtPosition: Duration.zero,
//               videoType: channel.streamType ?? 'M3u8',
//               channelList: widget.allChannels, // Passing the full genre list
//               isLive: true,
//               isVOD: false,
//               isBannerSlider: false,
//               source: 'isLiveScreen',
//               isSearch: false,
//               videoId: int.tryParse(channel.id),
//               unUpdatedUrl: channel.url,
//               name: channel.name,
//               liveStatus: true,
//             )));
//       }
//     } catch (e) {
//       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: ProfessionalColors.accentRed));
//     } finally {
//       if (mounted) setState(() => _isVideoLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ... Your existing build method for GenreAllChannelsPage ...
//     // This part of the code is fine.
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [ProfessionalColors.primaryDark, ProfessionalColors.surfaceDark.withOpacity(0.8), ProfessionalColors.primaryDark],
//               ),
//             ),
//             child: Column(
//               children: [
//                 _buildGridAppBar(),
//                 Expanded(
//                   child: RawKeyboardListener(
//                     focusNode: _gridFocusNode,
//                     onKey: _handleKeyNavigation,
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: GridView.builder(
//                         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 6,
//                           childAspectRatio: 0.7,
//                           crossAxisSpacing: 20,
//                           mainAxisSpacing: 20,
//                         ),
//                         itemCount: widget.allChannels.length,
//                         itemBuilder: (context, index) {
//                           final channel = widget.allChannels[index];
//                           final isFocused = focusedIndex == index;
//                           return NewsItemModelCard(
//                             channel: channel,
//                             isFocused: isFocused,
//                             onTap: () => _handleContentTap(channel),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (_isVideoLoading)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black.withOpacity(0.7),
//                 child: const Center(child: ProfessionalLoadingIndicator(message: 'Starting Stream...')),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGridAppBar() {
//     // ... Your existing app bar code ...
//      return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//         child: Row(
//           children: [
//             Container(
//               decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
//               child: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28), onPressed: () => Navigator.pop(context)),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(widget.genreTitle.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
//                   const SizedBox(height: 4),
//                   Text('${widget.allChannels.length} Channels', style: const TextStyle(color: ProfessionalColors.textSecondary, fontSize: 14)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // =======================================================================
// // MAIN PAGE WIDGET: CHANNELS CATEGORY
// // =======================================================================
// class ChannelsCategory extends StatefulWidget {
//   const ChannelsCategory({Key? key}) : super(key: key);

//   @override
//   State<ChannelsCategory> createState() => _ChannelsCategoryState();
// }

// class _ChannelsCategoryState extends State<ChannelsCategory> with SingleTickerProviderStateMixin {
//   // ... Your existing state variables ...
//   List<String> availableGenres = [];
//   Map<String, List<NewsItemModel>> genreChannelMap = {};
//   bool isLoading = true;
//   bool _isVideoLoading = false;
//   String? errorMessage;
//   int focusedGenreIndex = 0;
//   int focusedItemIndex = 0;
//   final FocusNode _widgetFocusNode = FocusNode();
//   final ScrollController _verticalScrollController = ScrollController();
//   List<ScrollController> _horizontalScrollControllers = [];
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;
  
//   // All your existing methods like _fetchLiveTvData, _processChannelData, build, etc.
//   // remain the same. The logic here is sound. The key is what it passes
//   // to VideoScreen in _handleContentTap.

//   @override
//   void initState() {
//     super.initState();
//     _fadeController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
//     _fetchLiveTvData();
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _widgetFocusNode.dispose();
//     _verticalScrollController.dispose();
//     for (var controller in _horizontalScrollControllers) {
//       if (controller.hasClients) controller.dispose();
//     }
//     _horizontalScrollControllers.clear();
//     super.dispose();
//   }
  
//   Future<void> _fetchLiveTvData() async {
//     // ... same as before
//     if (!mounted) return;
//     setState(() { isLoading = true; errorMessage = null; });
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String authKey = prefs.getString('auth_key') ?? '';
//       if (authKey.isEmpty) throw Exception('Authentication key not found.');
//       final response = await http.post(
//         Uri.parse('https://acomtv.coretechinfo.com/api/v2/getAllLiveTV'),
//         headers: {'auth-key': authKey, 'domain': 'coretechinfo.com', 'Content-Type': 'application/json'},
//         body: json.encode({"genere": "", "languageId": ""}),
//       );
//       if (response.statusCode == 200) {
//         _processChannelData(json.decode(response.body));
//       } else {
//         throw Exception('Failed to load channels: Status Code ${response.statusCode}');
//       }
//     } catch (e) {
//       if (mounted) setState(() => errorMessage = "Failed to load data. Please check your connection.");
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   void _processChannelData(List<dynamic> channelData) {
//     // ... same as before
//       if (!mounted) return;
//     Map<String, List<NewsItemModel>> tempGenreMap = {};
//     channelData.sort((a, b) => (a['channel_name'] ?? '').toLowerCase().compareTo((b['channel_name'] ?? '').toLowerCase()));
//     for (var item in channelData) {
//       if (item['status'] != 1) continue;
//       NewsItemModel channel = NewsItemModel.fromJson(item);
//       List<String> itemGenres = channel.genres.split(',').map((g) => g.trim()).where((g) => g.isNotEmpty).toList();
//       if (itemGenres.isEmpty) {
//         itemGenres.add("General"); // Assign to General if no genre is specified
//       }
//       for (String genre in itemGenres) {
//         tempGenreMap.putIfAbsent(genre, () => []);
//         tempGenreMap[genre]?.add(channel);
//       }
//     }
//     setState(() {
//       availableGenres = tempGenreMap.keys.toList()..sort();
//       genreChannelMap = tempGenreMap;
//     });
//     _initializeAndScroll();
//   }
//     void _initializeAndScroll() {
//     if (!mounted) return;
//     _initializeScrollControllers();
//     _fadeController.forward(from: 0.0);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         _widgetFocusNode.requestFocus();
//         _scrollToFocusedGenre();
//       }
//     });
//   }
  
//   Future<void> _handleRefresh() async => await _fetchLiveTvData();

//   Future<void> _handleContentTap(NewsItemModel channel) async {
//     if (_isVideoLoading || !mounted) return;
//     setState(() => _isVideoLoading = true);
//     try {
//       if (channel.url.isEmpty) throw Exception('No video URL found');

//       if (channel.streamType == 'YoutubeLive') {
//         final deviceInfo = context.read<DeviceInfoProvider>();
//         if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
//           await Navigator.push(context, MaterialPageRoute(builder: (c) => YoutubeWebviewPlayer(videoUrl: channel.url, name: channel.name)));
//         } else {
//           await Navigator.push(context, MaterialPageRoute(builder: (c) => CustomYoutubePlayer(videoData: VideoData(id: channel.id.toString(), title: channel.name, youtubeUrl: channel.url, thumbnail: channel.banner, description: 'Live TV'), playlist: [])));
//         }
//       } else {
//         // THE SENDER LOGIC: Prepare and pass the related channels list to VideoScreen
//         final allChannels = genreChannelMap.values.expand((list) => list).toSet().toList();
//         final List<String> selectedGenres = channel.genres.split(',').map((genre) => genre.trim()).toList();
        
//         // This logic correctly creates a List<NewsItemModel>
//         final List<NewsItemModel> filteredChannelList = allChannels.where((item) {
//           final List<String> itemGenres = item.genres.split(',').map((genre) => genre.trim()).toList();
//           return selectedGenres.any((genre) => itemGenres.contains(genre));
//         }).toList();

//         await Navigator.push(context, MaterialPageRoute(builder: (c) => VideoScreen(
//               videoUrl: channel.url,
//               bannerImageUrl: channel.banner,
//               startAtPosition: Duration.zero,
//               videoType: channel.streamType ?? 'M3u8',
//               channelList: filteredChannelList, // Passing the correct model type
//               isLive: true,
//               isVOD: false,
//               isBannerSlider: false,
//               source: 'isLiveScreen',
//               isSearch: false,
//               videoId: int.tryParse(channel.id),
//               unUpdatedUrl: channel.url,
//               name: channel.name,
//               liveStatus: true,
//             )));
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text('Error: ${e.toString()}'),
//             backgroundColor: ProfessionalColors.accentRed));
//       }
//     } finally {
//       if (mounted) setState(() => _isVideoLoading = false);
//     }
//   }
//    void _handleKeyNavigation(RawKeyEvent event) {
//     if (event is! RawKeyDownEvent || genreChannelMap.isEmpty || _isVideoLoading) return;
//     final genres = availableGenres;
//     final currentGenreItems = genreChannelMap[genres[focusedGenreIndex]]!;
//     final hasMore = currentGenreItems.length > 10;
//     final displayCount = hasMore ? 11 : currentGenreItems.length;
//     if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//       if (focusedGenreIndex > 0) {
//         setState(() { focusedGenreIndex--; focusedItemIndex = 0; });
//         _scrollToFocusedGenre();
//         HapticFeedback.lightImpact();
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//       if (focusedGenreIndex < genres.length - 1) {
//         setState(() { focusedGenreIndex++; focusedItemIndex = 0; });
//         _scrollToFocusedGenre();
//         HapticFeedback.lightImpact();
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//       if (focusedItemIndex > 0) {
//         setState(() => focusedItemIndex--);
//         _scrollToFocusedItem();
//         HapticFeedback.lightImpact();
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//       if (focusedItemIndex < displayCount - 1) {
//         setState(() => focusedItemIndex++);
//         _scrollToFocusedItem();
//         HapticFeedback.lightImpact();
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
//       if (hasMore && focusedItemIndex == 10) { // Corresponds to the "View All" card
//         Navigator.push(context, MaterialPageRoute(builder: (context) => GenreAllChannelsPage(genreTitle: genres[focusedGenreIndex], allChannels: currentGenreItems)));
//       } else if (focusedItemIndex < (hasMore ? 10 : currentGenreItems.length)) {
//         _handleContentTap(currentGenreItems.take(10).toList()[focusedItemIndex]);
//       }
//     }
//   }
//     void _initializeScrollControllers() {
//     _horizontalScrollControllers.forEach((c) => c.dispose());
//     _horizontalScrollControllers = List.generate(availableGenres.length, (_) => ScrollController());
//   }

//   double _calculateGenreSectionHeight() => 250.0 + 24.0 + 16.0 + 32.0; // Height of SizedBox + margin + padding
  
//   void _scrollToFocusedGenre() {
//     if (!mounted || !_verticalScrollController.hasClients) return;
//     if (focusedGenreIndex < _horizontalScrollControllers.length) {
//       final hController = _horizontalScrollControllers[focusedGenreIndex];
//       if (hController.hasClients) hController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
//     }
//     double targetOffset = focusedGenreIndex * _calculateGenreSectionHeight();
//     _verticalScrollController.animateTo(math.min(targetOffset, _verticalScrollController.position.maxScrollExtent), duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
//   }

//   void _scrollToFocusedItem() {
//     if (!mounted || focusedGenreIndex >= _horizontalScrollControllers.length) return;
//     final controller = _horizontalScrollControllers[focusedGenreIndex];
//     if (controller.hasClients) {
//       double itemWidth = 160.0; // Width of the NewsItemModelCard
//       double margin = 20.0; // Right margin
//       double totalItemWidth = itemWidth + margin;
//       double targetOffset = focusedItemIndex * totalItemWidth;
//       double viewport = controller.position.viewportDimension;
//       double newOffset = targetOffset - (viewport / 2) + (totalItemWidth / 2);
//       newOffset = newOffset.clamp(0.0, controller.position.maxScrollExtent);
//       controller.animateTo(newOffset, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
//     }
//   }


//   // Keep the rest of your UI-building methods (_buildContent, _buildGenreSection, etc.)
//   // as they are correct.
//    @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [ProfessionalColors.primaryDark, ProfessionalColors.surfaceDark.withOpacity(0.8), ProfessionalColors.primaryDark],
//               ),
//             ),
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: Column(
//                 children: [
//                   SizedBox(height: MediaQuery.of(context).padding.top + 100),
//                   Expanded(
//                     child: RawKeyboardListener(
//                       focusNode: _widgetFocusNode,
//                       onKey: _handleKeyNavigation,
//                       autofocus: true,
//                       child: RefreshIndicator(
//                         onRefresh: _handleRefresh,
//                         color: ProfessionalColors.accentGreen,
//                         backgroundColor: ProfessionalColors.cardDark,
//                         child: _buildContent(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(top: 0, left: 0, right: 0, child: _buildProfessionalAppBar()),
//           if (isLoading)
//             Positioned.fill(
//               child: Container(
//                 color: ProfessionalColors.primaryDark.withOpacity(0.9),
//                 child: const Center(child: ProfessionalLoadingIndicator(message: 'Loading Live Channels...')),
//               ),
//             ),
//           if (_isVideoLoading)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black.withOpacity(0.7),
//                 child: const Center(child: ProfessionalLoadingIndicator(message: 'Starting Stream...')),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContent() {
//     if (errorMessage != null && genreChannelMap.isEmpty) return _buildErrorWidget();
//     if (genreChannelMap.isEmpty && !isLoading) return _buildEmptyWidget();
//     return ListView.builder(
//       controller: _verticalScrollController,
//       physics: const BouncingScrollPhysics(),
//       padding: const EdgeInsets.only(top: 20, bottom: 100),
//       itemCount: availableGenres.length,
//       itemBuilder: (context, index) {
//         final String genreName = availableGenres[index];
//         final List<NewsItemModel> channelList = genreChannelMap[genreName]!;
//         return _buildGenreSection(genreName, channelList, index);
//       },
//     );
//   }
//    Widget _buildErrorWidget() { return Center(child: Text(errorMessage ?? 'An unknown error occurred.', style: TextStyle(color: Colors.white70, fontSize: 16))); }
//   Widget _buildEmptyWidget() { return Center(child: Text('No Live TV Channels Found.', style: TextStyle(color: Colors.white70, fontSize: 16))); }
//     Widget _buildProfessionalAppBar() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [ProfessionalColors.primaryDark.withOpacity(0.98), ProfessionalColors.surfaceDark.withOpacity(0.95), Colors.transparent],
//         ),
//       ),
//       child: ClipRRect(
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//           child: Container(
//             padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 15, left: 40, right: 40, bottom: 15),
//             child: Row(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
//                   child: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24), onPressed: () => Navigator.pop(context)),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Live TV', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
//                       const SizedBox(height: 6),
//                       if (genreChannelMap.isNotEmpty)
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(colors: [ProfessionalColors.accentGreen.withOpacity(0.4), ProfessionalColors.accentBlue.withOpacity(0.3)]),
//                           borderRadius: BorderRadius.circular(15),
//                           border: Border.all(color: ProfessionalColors.accentGreen.withOpacity(0.6), width: 1),
//                         ),
//                         child: Text('${genreChannelMap.length} Genres • ${genreChannelMap.values.fold(0, (sum, list) => sum + list.length)} Channels', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGenreSection(String genre, List<NewsItemModel> channelList, int genreIndex) {
//     final isFocusedGenre = focusedGenreIndex == genreIndex;
//     final bool hasMore = channelList.length > 10;
//     final displayList = hasMore ? channelList.take(10).toList() : channelList;
//     final itemCount = hasMore ? displayList.length + 1 : displayList.length;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
//             child: Text(
//               genre.toUpperCase(),
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 letterSpacing: 1.2,
//                 color: isFocusedGenre ? ProfessionalColors.accentGreen : ProfessionalColors.textPrimary,
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           SizedBox(
//             height: 250, // Increased height to prevent clipping on focus scale
//             child: ListView.builder(
//               controller: genreIndex < _horizontalScrollControllers.length ? _horizontalScrollControllers[genreIndex] : null,
//               scrollDirection: Axis.horizontal,
//               clipBehavior: Clip.none, // Allows scaling effect to draw outside bounds
//               padding: const EdgeInsets.symmetric(horizontal: 40),
//               itemCount: itemCount,
//               itemBuilder: (context, index) {
//                 if (hasMore && index == displayList.length) {
//                   return _buildViewAllCard(
//                     isFocused: isFocusedGenre && focusedItemIndex == index,
//                     totalCount: channelList.length,
//                     onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => GenreAllChannelsPage(genreTitle: genre, allChannels: channelList))),
//                   );
//                 }
//                 return NewsItemModelCard(
//                   channel: displayList[index],
//                   isFocused: isFocusedGenre && focusedItemIndex == index,
//                   onTap: () => _handleContentTap(displayList[index]),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildViewAllCard({required bool isFocused, required int totalCount, required VoidCallback onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeInOut,
//         transform: isFocused ? (Matrix4.identity()..scale(1.1)) : Matrix4.identity(),
//         transformAlignment: Alignment.center,
//         margin: const EdgeInsets.only(right: 20),
//         child: Container(
//           width: 160,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(15),
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: isFocused ? [ProfessionalColors.accentGreen.withOpacity(0.3), ProfessionalColors.accentBlue.withOpacity(0.3)] : [ProfessionalColors.cardDark.withOpacity(0.8), ProfessionalColors.surfaceDark.withOpacity(0.6)],
//             ),
//             border: Border.all(color: isFocused ? ProfessionalColors.accentGreen : ProfessionalColors.cardDark.withOpacity(0.5), width: isFocused ? 2 : 1),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: isFocused ? ProfessionalColors.accentGreen.withOpacity(0.3) : ProfessionalColors.cardDark.withOpacity(0.5),
//                   border: Border.all(color: isFocused ? ProfessionalColors.accentGreen : ProfessionalColors.textSecondary.withOpacity(0.3), width: 2),
//                 ),
//                 child: Icon(Icons.grid_view_rounded, size: 25, color: isFocused ? ProfessionalColors.accentGreen : ProfessionalColors.textSecondary),
//               ),
//               const SizedBox(height: 12),
//               Text('VIEW ALL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: isFocused ? ProfessionalColors.accentGreen : ProfessionalColors.textPrimary)),
//               const SizedBox(height: 4),
//               Text('$totalCount items', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isFocused ? ProfessionalColors.accentGreen : ProfessionalColors.textSecondary)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

// }

// // Your other widgets like NewsItemModelCard and ProfessionalLoadingIndicator are fine.
// // ...
// class NewsItemModelCard extends StatelessWidget {
//   final NewsItemModel channel;
//   final bool isFocused;
//   final VoidCallback onTap;

//   const NewsItemModelCard({Key? key, required this.channel, required this.isFocused, required this.onTap}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeInOut,
//         transform: isFocused ? (Matrix4.identity()..scale(1.1)) : Matrix4.identity(),
//         transformAlignment: Alignment.center,
//         margin: const EdgeInsets.only(right: 20),
//         child: Container(
//           width: 160,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(15),
//             border: isFocused ? Border.all(color: ProfessionalColors.accentGreen, width: 3) : null,
//             boxShadow: [
//               if (isFocused) BoxShadow(color: ProfessionalColors.accentGreen.withOpacity(0.5), blurRadius: 20, spreadRadius: 2)
//               else BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 Container(
//                   color: ProfessionalColors.cardDark,
//                   child: CachedNetworkImage(
//                     imageUrl: channel.banner,
//                     fit: BoxFit.contain,
//                     memCacheWidth: 320,
//                     placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: ProfessionalColors.accentGreen)),
//                     errorWidget: (context, url, error) => const Icon(Icons.live_tv, color: Colors.white54, size: 50),
//                   ),
//                 ),
//                 Positioned.fill(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
//                         begin: Alignment.center,
//                         end: Alignment.bottomCenter,
//                         stops: const [0.5, 1.0],
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 10,
//                   left: 10,
//                   right: 10,
//                   child: Text(
//                     channel.name,
//                     maxLines: 2,
//                     textAlign: TextAlign.center,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(color: isFocused ? ProfessionalColors.accentGreen : Colors.white, fontWeight: FontWeight.bold, fontSize: 14, shadows: const [Shadow(blurRadius: 4, color: Colors.black, offset: Offset(0, 1))]),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// class ProfessionalLoadingIndicator extends StatefulWidget {
//   final String message;
//   const ProfessionalLoadingIndicator({Key? key, required this.message}) : super(key: key);
//   @override
//   _ProfessionalLoadingIndicatorState createState() => _ProfessionalLoadingIndicatorState();
// }

// class _ProfessionalLoadingIndicatorState extends State<ProfessionalLoadingIndicator> with TickerProviderStateMixin {
//   late AnimationController _spinController, _pulseController;
//   late Animation<double> _pulseAnimation;
//   @override
//   void initState() {
//     super.initState();
//     _spinController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)..repeat();
//     _pulseController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
//     _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
//     _pulseController.repeat(reverse: true);
//   }
//   @override
//   void dispose() {
//     _spinController.dispose();
//     _pulseController.dispose();
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     const primaryColor = ProfessionalColors.accentGreen;
//     const textColor = ProfessionalColors.textPrimary;
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ScaleTransition(
//             scale: _pulseAnimation,
//             child: Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: RadialGradient(colors: [primaryColor.withOpacity(0.3), primaryColor.withOpacity(0.1), Colors.transparent]),
//                 border: Border.all(color: primaryColor, width: 3),
//                 boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
//               ),
//               child: RotationTransition(
//                 turns: _spinController,
//                 child: Icon(Icons.live_tv_rounded, color: primaryColor, size: 32),
//               ),
//             ),
//           ),
//           const SizedBox(height: 32),
//           Text(widget.message, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.5), textAlign: TextAlign.center),
//         ],
//       ),
//     );
//   }
// }








import 'dart:convert';
import 'dart:ui';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/services/history_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// IMPORTANT: Make sure these import paths are correct for your project structure.
import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player.dart';
import 'package:mobi_tv_entertainment/provider/device_info_provider.dart';
import 'package:mobi_tv_entertainment/video_widget/youtube_webview_player.dart';
import '../../widgets/models/news_item_model.dart'; // Using the primary model

// =======================================================================
// PROFESSIONAL COLOR PALETTE
// =======================================================================
class ProfessionalColors {
  static const primaryDark = Color(0xFF0A0E1A);
  static const surfaceDark = Color(0xFF1A1D29);
  static const cardDark = Color(0xFF2A2D3A);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentGreen = Color(0xFF10B981);
  static const accentRed = Color(0xFFEF4444);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
}

// =======================================================================
// GRID VIEW PAGE FOR "VIEW ALL" (⭐️ UPDATED WITH SCROLLING ⭐️)
// =======================================================================
class GenreAllChannelsPage extends StatefulWidget {
  final String genreTitle;
  final List<NewsItemModel> allChannels;

  const GenreAllChannelsPage({
    Key? key,
    required this.genreTitle,
    required this.allChannels,
  }) : super(key: key);

  @override
  State<GenreAllChannelsPage> createState() => _GenreAllChannelsPageState();
}

class _GenreAllChannelsPageState extends State<GenreAllChannelsPage> {
  final FocusNode _gridFocusNode = FocusNode();
  int focusedIndex = 0;
  bool _isVideoLoading = false;

  // ⭐️ ADDED for scrolling and focus management
  final ScrollController _scrollController = ScrollController();
  late List<FocusNode> _itemFocusNodes;

  @override
  void initState() {
    super.initState();
    // ⭐️ INITIALIZE a FocusNode for each item in the grid
    _itemFocusNodes = List.generate(
      widget.allChannels.length,
      (index) => FocusNode(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _gridFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _gridFocusNode.dispose();
    _scrollController.dispose(); // ⭐️ DISPOSE the scroll controller
    // ⭐️ DISPOSE all the item focus nodes
    for (var node in _itemFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // ⭐️ ADDED to scroll the focused item into view
  void _scrollToFocusedItem() {
    if (focusedIndex < 0 || focusedIndex >= _itemFocusNodes.length) return;
    final focusNode = _itemFocusNodes[focusedIndex];
    focusNode.requestFocus();
    Scrollable.ensureVisible(
      focusNode.context!,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: 0.3, // Brings item towards the top 30% of the screen
    );
  }

  // ⭐️ REPLACED with logic to call the new scroll function
  void _handleKeyNavigation(RawKeyEvent event) {
    if (event is! RawKeyDownEvent || _isVideoLoading) return;

    const itemsPerRow = 6;
    final totalItems = widget.allChannels.length;
    int previousIndex = focusedIndex;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (focusedIndex > 0) focusedIndex--;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (focusedIndex < totalItems - 1) focusedIndex++;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (focusedIndex >= itemsPerRow) focusedIndex -= itemsPerRow;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (focusedIndex < totalItems - itemsPerRow) {
        focusedIndex = math.min(focusedIndex + itemsPerRow, totalItems - 1);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
      _handleContentTap(widget.allChannels[focusedIndex]);
      return;
    }

    if (previousIndex != focusedIndex) {
      setState(() {});
      _scrollToFocusedItem(); // ⭐️ CALL THE SCROLL FUNCTION
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _handleContentTap(NewsItemModel channel) async {
    if (_isVideoLoading || !mounted) return;
    setState(() => _isVideoLoading = true);

    try{
          print('Updating user history for: ${channel.name}');
      int? currentUserId = SessionManager.userId;
    final int? parsedContentType = int.tryParse(channel.contentType ?? '');
    final int? parsedId = int.tryParse(channel.id ?? '');

      await HistoryService.updateUserHistory(
        userId: currentUserId!, // 1. User ID
        contentType: parsedContentType!, // 2. Content Type (channel के लिए 4)
        eventId: parsedId!, // 3. Event ID (channel की ID)
        eventTitle: channel.name, // 4. Event Title (channel का नाम)
        url: channel.url, // 5. URL (channel का URL)
        categoryId: 0, // 6. Category ID (डिफ़ॉल्ट 1)
      );
    } catch (e) {
      print("History update failed, but proceeding to play. Error: $e");
    }


    try {
      if (channel.url.isEmpty) throw Exception('No video URL found');
      if (channel.streamType == 'YoutubeLive') {
        final deviceInfo = context.read<DeviceInfoProvider>();
        if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
          await Navigator.push(context, MaterialPageRoute(builder: (c) => YoutubeWebviewPlayer(videoUrl: channel.url, name: channel.name)));
        } else {
          await Navigator.push(context, MaterialPageRoute(builder: (c) => CustomYoutubePlayer(videoData: VideoData(id: channel.id.toString(), title: channel.name, youtubeUrl: channel.url, thumbnail: channel.banner, description: ''), playlist: [])));
        }
      } else {
        await Navigator.push(context, MaterialPageRoute(builder: (c) => VideoScreen(
              videoUrl: channel.url,
              bannerImageUrl: channel.banner,
              startAtPosition: Duration.zero,
              videoType: channel.streamType ?? 'M3u8',
              channelList: widget.allChannels,
              isLive: true,
              isVOD: false,
              isBannerSlider: false,
              source: 'isLiveScreen',
              isSearch: false,
              videoId: int.tryParse(channel.id),
              unUpdatedUrl: channel.url,
              name: channel.name,
              liveStatus: true,
            )));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: ProfessionalColors.accentRed));
    } finally {
      if (mounted) setState(() => _isVideoLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalColors.primaryDark,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [ProfessionalColors.primaryDark, ProfessionalColors.surfaceDark.withOpacity(0.8), ProfessionalColors.primaryDark],
              ),
            ),
            child: Column(
              children: [
                _buildGridAppBar(),
                Expanded(
                  child: RawKeyboardListener(
                    focusNode: _gridFocusNode,
                    onKey: _handleKeyNavigation,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: GridView.builder(
                        controller: _scrollController, // ⭐️ ATTACH the scroll controller
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          childAspectRatio: bannerwdt / bannerhgt,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: widget.allChannels.length,
                        itemBuilder: (context, index) {
                          final channel = widget.allChannels[index];
                          final isFocused = focusedIndex == index;
                          return Focus( // ⭐️ WRAP card with Focus widget
                            focusNode: _itemFocusNodes[index],
                            child: StyledChannelCard(
                              channel: channel,
                              isFocused: isFocused,
                              onTap: () => _handleContentTap(channel),
                              width: double.infinity,
                              height: double.infinity,
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
          if (_isVideoLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(child: ProfessionalLoadingIndicator(message: 'Starting Stream...')),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGridAppBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
              child: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28), onPressed: () => Navigator.pop(context)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.genreTitle.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  const SizedBox(height: 4),
                  Text('${widget.allChannels.length} Channels', style: const TextStyle(color: ProfessionalColors.textSecondary, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// MAIN PAGE WIDGET: CHANNELS CATEGORY (⭐️ FULLY REFACTORED ⭐️)
// =======================================================================
class ChannelsCategory extends StatefulWidget {
  const ChannelsCategory({Key? key}) : super(key: key);

  @override
  State<ChannelsCategory> createState() => _ChannelsCategoryState();
}

class _ChannelsCategoryState extends State<ChannelsCategory>
    with SingleTickerProviderStateMixin {
  List<String> availableGenres = [];
  Map<String, List<NewsItemModel>> genreChannelMap = {};
  bool isLoading = true;
  bool _isVideoLoading = false;
  String? errorMessage;

  // Focus management
  int focusedGenreIndex = 0;
  int focusedItemIndex = 0;
  final FocusNode _widgetFocusNode = FocusNode();

  // Scroll controllers
  final ScrollController _verticalScrollController = ScrollController();
  List<ScrollController> _horizontalScrollControllers = [];

  // Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _fetchLiveTvData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _widgetFocusNode.dispose();
    _verticalScrollController.dispose();
    for (var controller in _horizontalScrollControllers) {
      controller.dispose();
    }
    _horizontalScrollControllers.clear();
    super.dispose();
  }

  Future<void> _fetchLiveTvData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      String authKey = prefs.getString('auth_key') ?? '';
      if (authKey.isEmpty) throw Exception('Authentication key not found.');
      final response = await https.post(
        Uri.parse('https://acomtv.coretechinfo.com/api/v2/getAllLiveTV'),
        headers: {'auth-key': authKey, 'domain': 'coretechinfo.com', 'Content-Type': 'application/json'},
        body: json.encode({"genere": "", "languageId": ""}),
      );
      if (response.statusCode == 200) {
        _processChannelData(json.decode(response.body));
      } else {
        throw Exception('Failed to load channels: Status Code ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) setState(() => errorMessage = "Failed to load data. Please check your connection.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _processChannelData(List<dynamic> channelData) {
      if (!mounted) return;
    Map<String, List<NewsItemModel>> tempGenreMap = {};
    channelData.sort((a, b) =>
        (a['channel_name'] ?? '').toLowerCase().compareTo((b['channel_name'] ?? '').toLowerCase()));

    for (var item in channelData) {
      if (item['status'] != 1) continue;
      NewsItemModel channel = NewsItemModel.fromJson(item);
      List<String> itemGenres = channel.genres
          .split(',')
          .map((g) => g.trim())
          .where((g) => g.isNotEmpty)
          .toList();
      if (itemGenres.isEmpty) {
        itemGenres.add("General");
      }
      for (String genre in itemGenres) {
        tempGenreMap.putIfAbsent(genre, () => []);
        tempGenreMap[genre]?.add(channel);
      }
    }

    setState(() {
      availableGenres = tempGenreMap.keys.toList()..sort();
      genreChannelMap = tempGenreMap;
    });

    _initializeAndScroll();
  }

  void _initializeAndScroll() {
    if (!mounted) return;
    _initializeScrollControllers();
    _fadeController.forward(from: 0.0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _widgetFocusNode.requestFocus();
      }
    });
  }

  Future<void> _handleRefresh() async => await _fetchLiveTvData();

  Future<void> _handleContentTap(NewsItemModel channel) async {
    if (_isVideoLoading || !mounted) return;
    setState(() => _isVideoLoading = true);


    try{
          print('Updating user history for: ${channel.name}');
      int? currentUserId = SessionManager.userId;
    final int? parsedContentType = int.tryParse(channel.contentType ?? '');
    final int? parsedId = int.tryParse(channel.id ?? '');

      await HistoryService.updateUserHistory(
        userId: currentUserId!, // 1. User ID
        contentType: parsedContentType!, // 2. Content Type (channel के लिए 4)
        eventId: parsedId!, // 3. Event ID (channel की ID)
        eventTitle: channel.name, // 4. Event Title (channel का नाम)
        url: channel.url, // 5. URL (channel का URL)
        categoryId: 0, // 6. Category ID (डिफ़ॉल्ट 1)
      );
    } catch (e) {
      print("History update failed, but proceeding to play. Error: $e");
    }


    try {
      if (channel.url.isEmpty) throw Exception('No video URL found');

      if (channel.streamType == 'YoutubeLive') {
        final deviceInfo = context.read<DeviceInfoProvider>();
        if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
          await Navigator.push(context, MaterialPageRoute(builder: (c) => YoutubeWebviewPlayer(videoUrl: channel.url, name: channel.name)));
        } else {
          await Navigator.push(context, MaterialPageRoute(builder: (c) => CustomYoutubePlayer(videoData: VideoData(id: channel.id.toString(), title: channel.name, youtubeUrl: channel.url, thumbnail: channel.banner, description: 'Live TV'), playlist: [])));
        }
      } else {
        final allChannels = genreChannelMap.values.expand((list) => list).toSet().toList();
        final List<String> selectedGenres = channel.genres.split(',').map((genre) => genre.trim()).toList();

        final List<NewsItemModel> filteredChannelList = allChannels.where((item) {
          final List<String> itemGenres = item.genres.split(',').map((genre) => genre.trim()).toList();
          return selectedGenres.any((genre) => itemGenres.contains(genre));
        }).toList();

        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (c) => VideoScreen(
                    videoUrl: channel.url,
                    bannerImageUrl: channel.banner,
                    startAtPosition: Duration.zero,
                    videoType: channel.streamType ?? 'M3u8',
                    channelList: filteredChannelList,
                    isLive: true,
                    isVOD: false,
                    isBannerSlider: false,
                    source: 'isLiveScreen',
                    isSearch: false,
                    videoId: int.tryParse(channel.id),
                    unUpdatedUrl: channel.url,
                    name: channel.name,
                    liveStatus: true,
                  )));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: ProfessionalColors.accentRed));
      }
    } finally {
      if (mounted) setState(() => _isVideoLoading = false);
    }
  }
  
  // =======================================================================
  // ⭐️⭐️ NEW RELIABLE NAVIGATION AND SCROLLING LOGIC ⭐️⭐️
  // =======================================================================

  void _initializeScrollControllers() {
    _horizontalScrollControllers.forEach((c) => c.dispose());
    _horizontalScrollControllers = List.generate(availableGenres.length, (_) => ScrollController());
  }

  /// Calculates the total height of one genre row for vertical scrolling.
  double _calculateGenreSectionHeight() {
    double genreHeaderContainer = 56.0;
    double spaceBetweenHeaderAndContent = 16.0;
    double contentHeight = bannerhgt;
    double sectionBottomMargin = 24.0;

    return genreHeaderContainer +
        spaceBetweenHeaderAndContent +
        contentHeight +
        sectionBottomMargin;
  }

  /// Scrolls vertically to the currently focused genre row.
  void _scrollToFocusedGenre() {
    if (!mounted || !_verticalScrollController.hasClients) return;

    if (focusedGenreIndex < _horizontalScrollControllers.length) {
      final horizontalController = _horizontalScrollControllers[focusedGenreIndex];
      if (horizontalController.hasClients) {
        horizontalController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    double sectionHeight = _calculateGenreSectionHeight();
    double targetOffset = focusedGenreIndex * sectionHeight;
    double topPadding = 50.0;
    targetOffset = math.max(0, targetOffset - topPadding);

    double maxOffset = _verticalScrollController.position.maxScrollExtent;
    targetOffset = math.min(targetOffset, maxOffset);

    _verticalScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  /// Scrolls horizontally to the currently focused item within a genre row.
  void _scrollToFocusedItem() {
    if (!mounted || focusedGenreIndex >= _horizontalScrollControllers.length) return;

    final controller = _horizontalScrollControllers[focusedGenreIndex];
    if (controller.hasClients) {
      double itemWidthWithPadding = bannerwdt + 20.0;
      double targetOffset = focusedItemIndex * itemWidthWithPadding;

      targetOffset -= (controller.position.viewportDimension -(controller.position.viewportDimension )) ;
      
      targetOffset = targetOffset.clamp(
          controller.position.minScrollExtent,
          controller.position.maxScrollExtent
      );

      controller.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  // void _handleKeyNavigation(RawKeyEvent event) {
  //   if (event is! RawKeyDownEvent || genreChannelMap.isEmpty || _isVideoLoading) return;

  //   final genres = availableGenres;
  //   final currentGenreItems = genreChannelMap[genres[focusedGenreIndex]]!;
    
  //   if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
  //     if (focusedGenreIndex <= 0) return;
  //     setState(() {
  //       focusedGenreIndex--;
  //       focusedItemIndex = 0;
  //     });
  //     WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFocusedGenre());
  //     HapticFeedback.lightImpact();
  //   } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
  //     if (focusedGenreIndex >= genres.length - 1) return;
  //     setState(() {
  //       focusedGenreIndex++;
  //       focusedItemIndex = 0;
  //     });
  //     WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFocusedGenre());
  //     HapticFeedback.lightImpact();
  //   } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
  //     if (focusedItemIndex <= 0) return;
  //     setState(() {
  //       focusedItemIndex--;
  //     });
  //     _scrollToFocusedItem();
  //     HapticFeedback.lightImpact();
  //   } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
  //     final hasMore = currentGenreItems.length > 10;
  //     final displayCount = hasMore ? 11 : currentGenreItems.length;
  //     if (focusedItemIndex >= displayCount - 1) return;
  //     setState(() {
  //       focusedItemIndex++;
  //     });
  //     _scrollToFocusedItem();
  //     HapticFeedback.lightImpact();
  //   } else if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
  //       final hasMore = currentGenreItems.length > 10;
  //       if (hasMore && focusedItemIndex == 10) {
  //           Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                   builder: (context) => GenreAllChannelsPage(
  //                       genreTitle: genres[focusedGenreIndex],
  //                       allChannels: currentGenreItems,
  //                   ),
  //               ),
  //           );
  //       } else if (focusedItemIndex < currentGenreItems.length) {
  //           final displayList = currentGenreItems.take(10).toList();
  //           _handleContentTap(displayList[focusedItemIndex]);
  //       }
  //   }
  // }



  // =======================================================================
// ⭐️⭐️ UPDATED AND FINAL NAVIGATION LOGIC ⭐️⭐️
// =======================================================================
void _handleKeyNavigation(RawKeyEvent event) {
  if (event is! RawKeyDownEvent || genreChannelMap.isEmpty || _isVideoLoading) return;

  final genres = availableGenres;
  final currentGenreItems = genreChannelMap[genres[focusedGenreIndex]]!;
  
  if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
    if (focusedGenreIndex <= 0) return;
    setState(() {
      focusedGenreIndex--;
      focusedItemIndex = 0;
    });
    // Callback to scroll AND return focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _widgetFocusNode.requestFocus(); // ⭐️ FOCUS FIX: Return focus to the listener
      _scrollToFocusedGenre();
    });
    HapticFeedback.lightImpact();

  } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
    if (focusedGenreIndex >= genres.length - 1) return;
    setState(() {
      focusedGenreIndex++;
      focusedItemIndex = 0;
    });
    // Callback to scroll AND return focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _widgetFocusNode.requestFocus(); // ⭐️ FOCUS FIX: Return focus to the listener
      _scrollToFocusedGenre();
    });
    HapticFeedback.lightImpact();

  } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
    if (focusedItemIndex <= 0) return;
    setState(() {
      focusedItemIndex--;
    });
    _scrollToFocusedItem();
    HapticFeedback.lightImpact();

  } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
    final hasMore = currentGenreItems.length > 10;
    final displayCount = hasMore ? 11 : currentGenreItems.length;
    if (focusedItemIndex >= displayCount - 1) return;
    setState(() {
      focusedItemIndex++;
    });
    _scrollToFocusedItem();
    HapticFeedback.lightImpact();

  } else if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
      final hasMore = currentGenreItems.length > 10;
      if (hasMore && focusedItemIndex == 10) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GenreAllChannelsPage(
                      genreTitle: genres[focusedGenreIndex],
                      allChannels: currentGenreItems,
                  ),
              ),
          );
      } else if (focusedItemIndex < currentGenreItems.length) {
          final displayList = currentGenreItems.take(10).toList();
          _handleContentTap(displayList[focusedItemIndex]);
      }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalColors.primaryDark,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [ProfessionalColors.primaryDark, ProfessionalColors.surfaceDark.withOpacity(0.8), ProfessionalColors.primaryDark],
              ),
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 100),
                  Expanded(
                    child: RawKeyboardListener(
                      focusNode: _widgetFocusNode,
                      onKey: _handleKeyNavigation,
                      autofocus: true,
                      child: RefreshIndicator(
                        onRefresh: _handleRefresh,
                        color: ProfessionalColors.accentGreen,
                        backgroundColor: ProfessionalColors.cardDark,
                        child: _buildContent(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(top: 0, left: 0, right: 0, child: _buildProfessionalAppBar()),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: ProfessionalColors.primaryDark.withOpacity(0.9),
                child: const Center(child: ProfessionalLoadingIndicator(message: 'Loading Live Channels...')),
              ),
            ),
          if (_isVideoLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(child: ProfessionalLoadingIndicator(message: 'Starting Stream...')),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (errorMessage != null && genreChannelMap.isEmpty) return _buildErrorWidget();
    if (genreChannelMap.isEmpty && !isLoading) return _buildEmptyWidget();
    return ListView.builder(
      controller: _verticalScrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 20, bottom: 100),
      itemCount: availableGenres.length,
      itemBuilder: (context, index) {
        final String genreName = availableGenres[index];
        final List<NewsItemModel> channelList = genreChannelMap[genreName]!;
        return _buildGenreSection(genreName, channelList, index);
      },
    );
  }

  Widget _buildErrorWidget() {
    return Center(child: Text(errorMessage ?? 'An unknown error occurred.', style: TextStyle(color: Colors.white70, fontSize: 16)));
  }

  Widget _buildEmptyWidget() {
    return Center(child: Text('No Live TV Channels Found.', style: TextStyle(color: Colors.white70, fontSize: 16)));
  }

  Widget _buildProfessionalAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ProfessionalColors.primaryDark.withOpacity(0.98), ProfessionalColors.surfaceDark.withOpacity(0.95), Colors.transparent],
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 15, left: 40, right: 40, bottom: 15),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
                  child: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24), onPressed: () => Navigator.pop(context)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Live TV', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                      const SizedBox(height: 6),
                      if (genreChannelMap.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [ProfessionalColors.accentGreen.withOpacity(0.4), ProfessionalColors.accentBlue.withOpacity(0.3)]),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: ProfessionalColors.accentGreen.withOpacity(0.6), width: 1),
                          ),
                          child: Text('${genreChannelMap.length} Genres • ${genreChannelMap.values.fold(0, (sum, list) => sum + list.length)} Channels', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenreSection(
      String genre, List<NewsItemModel> channelList, int genreIndex) {
    final isFocusedGenre = focusedGenreIndex == genreIndex;
    final bool hasMore = channelList.length > 10;
    final displayList = hasMore ? channelList.take(10).toList() : channelList;
    final itemCount = hasMore ? displayList.length + 1 : displayList.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isFocusedGenre ? [
                  ProfessionalColors.accentGreen.withOpacity(0.3),
                  ProfessionalColors.accentBlue.withOpacity(0.2),
                ] : [
                  ProfessionalColors.cardDark.withOpacity(0.6),
                  ProfessionalColors.surfaceDark.withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isFocusedGenre ? ProfessionalColors.accentGreen.withOpacity(0.5) : ProfessionalColors.cardDark.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    genre.toUpperCase(),
                    style: TextStyle(
                      fontSize: isFocusedGenre ? 18 : 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: isFocusedGenre ? ProfessionalColors.accentGreen : ProfessionalColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isFocusedGenre ? ProfessionalColors.accentGreen.withOpacity(0.2) : ProfessionalColors.cardDark.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isFocusedGenre ? ProfessionalColors.accentGreen.withOpacity(0.4) : ProfessionalColors.textSecondary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${channelList.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isFocusedGenre ? ProfessionalColors.accentGreen : ProfessionalColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: bannerhgt,
            child: ListView.builder(
              controller: genreIndex < _horizontalScrollControllers.length
                  ? _horizontalScrollControllers[genreIndex]
                  : null,
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                EdgeInsets itemPadding = const EdgeInsets.only(right: 20);

                if (hasMore && index == displayList.length) {
                  return Padding(
                    padding: itemPadding,
                    child: _buildViewAllCard(
                        isFocused: isFocusedGenre && focusedItemIndex == index,
                        totalCount: channelList.length,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (c) => GenreAllChannelsPage(
                                    genreTitle: genre,
                                    allChannels: channelList)))),
                  );
                }
                return Padding(
                  padding: itemPadding,
                  child: StyledChannelCard(
                    channel: displayList[index],
                    isFocused: isFocusedGenre && focusedItemIndex == index,
                    onTap: () => _handleContentTap(displayList[index]),
                    width: bannerwdt,
                    height: bannerhgt,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllCard(
      {required bool isFocused,
      required int totalCount,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: bannerwdt,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isFocused ? [ProfessionalColors.accentGreen.withOpacity(0.3), ProfessionalColors.accentBlue.withOpacity(0.3)] : [ProfessionalColors.cardDark.withOpacity(0.8), ProfessionalColors.surfaceDark.withOpacity(0.6)],
          ),
          border: Border.all(color: isFocused ? ProfessionalColors.accentGreen : ProfessionalColors.cardDark.withOpacity(0.5), width: isFocused ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              // padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFocused ? ProfessionalColors.accentGreen.withOpacity(0.3) : ProfessionalColors.cardDark.withOpacity(0.5),
                border: Border.all(color: isFocused ? ProfessionalColors.accentGreen : ProfessionalColors.textSecondary.withOpacity(0.3), width: 2),
              ),
              child: Icon(Icons.grid_view_rounded, size: 25, color: isFocused ? ProfessionalColors.accentGreen : ProfessionalColors.textSecondary),
            ),
            const SizedBox(height: 2),
            Text('VIEW ALL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: isFocused ? ProfessionalColors.accentGreen : ProfessionalColors.textPrimary)),
            const SizedBox(height: 4),
            Text('$totalCount items', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isFocused ? ProfessionalColors.accentGreen : ProfessionalColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// UNIFIED AND REUSABLE CHANNEL CARD (UNCHANGED)
// =======================================================================
class StyledChannelCard extends StatelessWidget {
  final NewsItemModel channel;
  final bool isFocused;
  final VoidCallback onTap;
  final double width;
  final double height;

  const StyledChannelCard({
    Key? key,
    required this.channel,
    required this.isFocused,
    required this.onTap,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: isFocused ? Border.all(color: ProfessionalColors.accentGreen, width: 3) : null,
          boxShadow: [
            if (isFocused)
              BoxShadow(
                color: ProfessionalColors.accentGreen.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: ProfessionalColors.cardDark,
                child: CachedNetworkImage(
                  imageUrl: channel.banner,
                  fit: BoxFit.cover,
                  memCacheWidth: 480,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: ProfessionalColors.accentGreen)),
                  errorWidget: (context, url, error) => const Icon(Icons.live_tv, color: Colors.white54, size: 50),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  channel.name.toUpperCase(),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isFocused ? ProfessionalColors.accentGreen : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isFocused ? 15 : 14,
                    letterSpacing: 0.5,
                    shadows: const [Shadow(blurRadius: 4, color: Colors.black, offset: Offset(0, 2))],
                  ),
                ),
              ),
              if (isFocused)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ProfessionalColors.accentGreen.withOpacity(0.9),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 24,
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

// =======================================================================
// PROFESSIONAL LOADING INDICATOR (UNCHANGED)
// =======================================================================
class ProfessionalLoadingIndicator extends StatefulWidget {
  final String message;
  const ProfessionalLoadingIndicator({Key? key, required this.message}) : super(key: key);
  @override
  _ProfessionalLoadingIndicatorState createState() => _ProfessionalLoadingIndicatorState();
}

class _ProfessionalLoadingIndicatorState extends State<ProfessionalLoadingIndicator> with TickerProviderStateMixin {
  late AnimationController _spinController, _pulseController;
  late Animation<double> _pulseAnimation;
  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)..repeat();
    _pulseController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = ProfessionalColors.accentGreen;
    const textColor = ProfessionalColors.textPrimary;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [primaryColor.withOpacity(0.3), primaryColor.withOpacity(0.1), Colors.transparent]),
                border: Border.all(color: primaryColor, width: 3),
                boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
              ),
              child: RotationTransition(
                turns: _spinController,
                child: Icon(Icons.live_tv_rounded, color: primaryColor, size: 32),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(widget.message, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.5), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}