






// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/webseries_details_page.dart';
// import 'package:mobi_tv_entertainment/components/provider/device_info_provider.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/custom_youtube_player.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/live_video_screen.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/youtube_webview_player.dart';
// import 'package:mobi_tv_entertainment/components/widgets/models/news_item_model.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../home_screen_pages/religious_channel/religious_channel_details_page.dart';
// import '../home_screen_pages/sports_category/tv_show_final_details_page.dart';
// import '../home_screen_pages/tv_show/tv_show_final_details_page.dart';
// import '../home_screen_pages/tv_show_pak/tv_show_final_details_page.dart';
// import '../../main.dart'; // Assuming bannerhgt, screenwdt, etc. are defined here
// import '../provider/focus_provider.dart';

// class ProfessionalVODColors {
//   static const primaryDark = Color(0xFF0A0E1A);
//   static const surfaceDark = Color(0xFF1A1D29);
//   static const accentBlue = Color(0xFF3B82F6);
//   static const accentPurple = Color(0xFF8B5CF6);
//   static const accentGreen = Color(0xFF10B981);
//   static const accentRed = Color(0xFFEF4444);
// }

// // class NewsItemModel {
// //   final String id;
// //   final String name;
// //   final String? description;
// //   final String banner;
// //   final String? poster;
// //   final String url;
// //   final String? contentType;
// //   final String? sourceType;

// //   NewsItemModel({
// //     required this.id,
// //     required this.name,
// //     this.description,
// //     required this.banner,
// //     this.poster,
// //     required this.url,
// //     this.contentType,
// //     this.sourceType,
// //   });

// //   factory NewsItemModel.fromJson(Map<String, dynamic> json) {
// //     String bannerUrl = json['banner']?.toString() ??
// //         json['channel_logo']?.toString() ??
// //         json['channel_bg']?.toString() ??
// //         json['logo']?.toString() ??
// //         json['thumbnail']?.toString() ??
// //         '';

// //     if (bannerUrl.isNotEmpty && !bannerUrl.startsWith('http')) {
// //       bannerUrl = 'https://dashboard.cpplayers.com/public/$bannerUrl';
// //     }

// //     return NewsItemModel(
// //       id: json['id']?.toString() ?? '0',
// //       name: json['name']?.toString() ?? json['channel_name']?.toString() ?? json['title']?.toString() ?? '',
// //       description: json['description']?.toString(),
// //       banner: bannerUrl,
// //       poster: json['poster']?.toString(),
// //       url: json['movie_url']?.toString() ?? json['channel_link']?.toString() ?? '',
// //       contentType: json['content_type']?.toString(),
// //       sourceType: json['source_type']?.toString(),
// //     );
// //   }
// // }

// // Future<List<NewsItemModel>> fetchFromApi(String searchTerm) async {
// //   try {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     String? authKey = prefs.getString('result_auth_key');

// //     final url = Uri.parse('https://dashboard.cpplayers.com/api/v2/getSearchCategoryList');
// //     final body = json.encode({'keywords': searchTerm});

// //     final response = await https.post(
// //       url,
// //       headers: {
// //         'auth-key': authKey ?? '',
// //         'Accept': 'application/json',
// //         'Content-Type': 'application/json',
// //         'domain': 'coretechinfo.com'
// //       },
// //       body: body,
// //     );

// //     if (response.statusCode == 200) {
// //       String responseBody = response.body.trim();
// //       if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
// //         final dynamic responseData = json.decode(responseBody);
// //         List<dynamic> dataList;

// //         if (responseData is List) {
// //           dataList = responseData;
// //         } else if (responseData is Map && responseData['data'] is List) {
// //           dataList = responseData['data'];
// //         } else {
// //           throw Exception('Unexpected response format');
// //         }

// //         List<NewsItemModel> newsItems = [];
// //         for (var itemDataRaw in dataList) {
// //           try {
// //             newsItems.add(NewsItemModel.fromJson(itemDataRaw as Map<String, dynamic>));
// //           } catch (e) {
// //             debugPrint('Error parsing item: $e');
// //           }
// //         }
// //         return newsItems;
// //       } else {
// //         throw Exception('Invalid response format');
// //       }
// //     } else if (response.statusCode == 401 || response.statusCode == 403) {
// //       throw Exception('Authentication failed. Please log in again.');
// //     } else {
// //       throw Exception('Failed to load data from API: ${response.statusCode}');
// //     }
// //   } catch (e) {
// //     if (e.toString().contains('Authentication')) {
// //       rethrow;
// //     }
// //     return [];
// //   }
// // }

// Future<List<NewsItemModel>> fetchFromApi(String searchTerm) async {
//   try {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? authKey = prefs.getString('result_auth_key');

//     final url = Uri.parse(
//         'https://dashboard.cpplayers.com/api/v2/getSearchCategoryList');
//     final body = json.encode({'keywords': searchTerm});

//     final response = await https.post(
//       url,
//       headers: {
//         'auth-key': authKey ?? '',
//         'Accept': 'application/json',
//         'Content-Type': 'application/json',
//         'domain': 'coretechinfo.com'
//       },
//       body: body,
//     );

//     if (response.statusCode == 200) {
//       String responseBody = response.body.trim();
//       if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
//         final dynamic responseData = json.decode(responseBody);
//         List<dynamic> dataList;

//         if (responseData is List) {
//           dataList = responseData;
//         } else if (responseData is Map && responseData['data'] is List) {
//           dataList = responseData['data'];
//         } else {
//           throw Exception('Unexpected response format');
//         }

//         List<NewsItemModel> newsItems = [];
//         for (var itemDataRaw in dataList) {
//           try {
//             // --- FIX: Only add items if their status is 1 ---
//             if (itemDataRaw is Map<String, dynamic> &&
//                 itemDataRaw['status']?.toString() == '1') {
//               newsItems.add(NewsItemModel.fromJson(itemDataRaw));
//             }
//           } catch (e) {
//             debugPrint('Error parsing item: $e');
//           }
//         }
//         return newsItems;
//       } else {
//         throw Exception('Invalid response format');
//       }
//     } else if (response.statusCode == 401 || response.statusCode == 403) {
//       throw Exception('Authentication failed. Please log in again.');
//     } else {
//       throw Exception('Failed to load data from API: ${response.statusCode}');
//     }
//   } catch (e) {
//     if (e.toString().contains('Authentication')) {
//       rethrow;
//     }
//     return [];
//   }
// }

// Uint8List _getImageFromBase64String(String base64String) {
//   try {
//     String cleanBase64 = base64String.split(',').last;
//     return base64Decode(cleanBase64);
//   } catch (e) {
//     rethrow;
//   }
// }

// class SearchScreen extends StatefulWidget {
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen>
//     with TickerProviderStateMixin {
//   List<NewsItemModel> searchResults = [];
//   bool isLoading = false;
//   final TextEditingController _searchController = TextEditingController();
//   Timer? _debounce;
//   List<FocusNode> _itemFocusNodes = [];
//   bool _isNavigating = false;
//   bool _shouldContinueLoading = true;
//   String _errorMessage = '';

//   // Keyboard and input related variables
//   bool _showKeyboard = false;
//   bool _isShiftEnabled = false;
//   String _searchText = '';

//   final FocusNode _gridFocusNode = FocusNode();
//   final FocusNode _searchIconFocusNode = FocusNode();
//   int _focusedIndex = 0;
//   static const int _itemsPerRow = 6;
//   final ScrollController _scrollController = ScrollController();

//   // New GlobalKey to get the height of the search bar
//   final GlobalKey _searchBarKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     _searchIconFocusNode.addListener(() => setState(() {}));
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context
//           .read<FocusProvider>()
//           .setSearchIconFocusNode(_searchIconFocusNode);
//     });
//   }

//   @override
//   void dispose() {
//     _gridFocusNode.dispose();
//     _scrollController.dispose();
//     _searchIconFocusNode.dispose();
//     _searchController.dispose();
//     _debounce?.cancel();
//     _itemFocusNodes.forEach((node) => node.dispose());
//     super.dispose();
//   }

//   // Keyboard input handler similar to login screen
//   void _onKeyPressed(String value) {
//     setState(() {
//       if (value == 'OK') {
//         // Perform search when OK is pressed
//         if (_searchText.trim().isNotEmpty) {
//           _performSearch(_searchText);
//           _showKeyboard = false;
//           _gridFocusNode.requestFocus();
//         }
//         return;
//       }

//       if (value == 'SHIFT') {
//         _isShiftEnabled = !_isShiftEnabled;
//         return;
//       }

//       if (value == 'DEL') {
//         if (_searchText.isNotEmpty) {
//           _searchText = _searchText.substring(0, _searchText.length - 1);
//           _searchController.text = _searchText;
//           _performSearch(_searchText); // Real-time search
//         }
//       } else {
//         _searchText += value;
//         _searchController.text = _searchText;
//         _performSearch(_searchText); // Real-time search
//       }
//     });
//   }

//   Future<void> _onItemTap(BuildContext context, int index) async {
//     if (_isNavigating) return;
//     _isNavigating = true;
//     _showLoadingIndicator(context);

//     try {
//       if (_shouldContinueLoading) {
//         await _navigateToVideoScreen(context, searchResults, index);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Something went wrong')),
//       );
//     } finally {
//       _isNavigating = false;
//       _shouldContinueLoading = true;
//       _dismissLoadingIndicator();
//     }
//   }

//   void _showLoadingIndicator(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return WillPopScope(
//           onWillPop: () async {
//             _shouldContinueLoading = false;
//             _dismissLoadingIndicator();
//             return false;
//           },
//           child: const Center(
//             child: SpinKitFadingCircle(color: Colors.white, size: 50.0),
//           ),
//         );
//       },
//     );
//   }

//   void _dismissLoadingIndicator() {
//     if (Navigator.of(context, rootNavigator: true).canPop()) {
//       Navigator.of(context, rootNavigator: true).pop();
//     }
//   }


//   Future<void> _navigateToVideoScreen(
//       BuildContext context, List<NewsItemModel> channels, int index) async {
//     if (index < 0 || index >= channels.length) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Invalid channel index')),
//       );
//       return;
//     }

//     final channel = channels[index];
//     final int? parsedContentType = int.tryParse(channel.contentType);

//     // --- SOLUTION START ---
//     // Step 1: Pehle un content types ko handle karein jinhe details page chahiye.
//     // Inko video URL ki zaroorat nahi hai.
//     try {
//       if (parsedContentType == 2) {
//         // WebSeries
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => WebSeriesDetailsPage(
//               id: int.tryParse(channel.id) ?? 0,
//               banner: channel.banner,
//               poster: channel.poster,
//               logo: channel.banner,
//               name: channel.name,
//               updatedAt: channel.updatedAt,
//             ),
//           ),
//         );
//         return; // Navigate hone ke baad function se bahar nikal jayein
//       } else if (parsedContentType == 4) {
//         // TV Show
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => TvShowFinalDetailsPage(
//               id: int.tryParse(channel.id) ?? 0,
//               banner: channel.banner,
//               poster: channel.poster,
//               name: channel.name,
//             ),
//           ),
//         );
//         return; // Navigate hone ke baad function se bahar nikal jayein
//       } else if (parsedContentType == 5) {
//         // TV Show Pak
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => TvShowPakFinalDetailsPage(
//               id: int.tryParse(channel.id) ?? 0,
//               banner: channel.banner,
//               poster: channel.poster,
//               name: channel.name,
//               updatedAt: channel.updatedAt,
//             ),
//           ),
//         );
//         return; // Navigate hone ke baad function se bahar nikal jayein
//       } else if (parsedContentType == 7) {
//         // Religious Channel
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ReligiousChannelDetailsPage(
//               id: int.tryParse(channel.id) ?? 0,
//               banner: channel.banner,
//               poster: channel.poster,
//               name: channel.name,
//               updatedAt: channel.updatedAt,
//             ),
//           ),
//         );
//         return; // Navigate hone ke baad function se bahar nikal jayein
//       } else if (parsedContentType == 8) {
//         // Tournament
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => TournamentFinalDetailsPage(
//               id: int.tryParse(channel.id) ?? 0,
//               banner: channel.banner,
//               poster: channel.poster,
//               name: channel.name,
//               updatedAt: channel.updatedAt,
//             ),
//           ),
//         );
//         return; // Navigate hone ke baad function se bahar nikal jayein
//       }
//     } catch (e) {
//       // Error handling zaroor karein
//       print('Navigation Error for Details Page: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Could not open details page.')),
//       );
//       return;
//     }
//     // --- SOLUTION END ---

//     // Step 2: Ab video URL aur streamType ki jaanch karein.
//     final String? videoUrl = channel.url;
//     final String? streamType = channel.streamType;

//     if (videoUrl == null || videoUrl.isEmpty || streamType == null) {
//       // Agar upar koi type match nahi hua aur yahan URL bhi nahi hai, to kuch na karein.
//       return;
//     }

//     try {
//       if (parsedContentType == 3) {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => LiveVideoScreen(
//               videoUrl: videoUrl,
//               // startAtPosition: Duration.zero,
//               bannerImageUrl: channel.banner,
//               // videoType: '',
//               channelList: [],
//               // isLive: true,
//               // isVOD: false,
//               // isBannerSlider: false,
//               // source: 'isSearchScreen',
//               // isSearch: true,
//               videoId: int.tryParse(channel.id),
//               // unUpdatedUrl: videoUrl,
//               name: channel.name,
//               liveStatus: true,
//               updatedAt: channel.updatedAt,
//               source: 'isSearch',
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Error opening content.')));
//     }

//     // Step 3: Ab bache hue content types (jaise type 1) ko handle karein.
//     try {
//       if (parsedContentType == 1) {
//         // Live Channel / Video
//         if (channel.sourceType == 'YoutubeLive' ||
//             channel.sourceType == 'youtube') {
//           final deviceInfo = context.read<DeviceInfoProvider>();
//           if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => YoutubeWebviewPlayer(
//                   videoUrl: channel.url,
//                   name: channel.name,
//                 ),
//               ),
//             );
//           } else {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => CustomYoutubePlayer(
//                   videoData: VideoData(
//                     id: channel.id,
//                     title: channel.name,
//                     youtubeUrl: channel.url,
//                     thumbnail: channel.banner ?? channel.poster ?? '',
//                     description: channel.description ?? '',
//                   ),
//                   playlist: [
//                     VideoData(
//                       id: channel.id,
//                       title: channel.name,
//                       youtubeUrl: channel.url,
//                       thumbnail: channel.banner ?? channel.poster ?? '',
//                       description: channel.description ?? '',
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//         } else {
//           // Handle other stream types for contentType 1 if any (e.g., M3u8)
//           // await Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(...)));
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => VideoScreen(
//                 videoUrl: channel.url,
//                 bannerImageUrl: channel.banner,
//                 channelList: [],
//                 // isLive: false,
//                 // isSearch: true,
//                 videoId: int.tryParse(channel.id),
//                 name: channel.name,
//                 liveStatus: false,
//                 updatedAt: channel.updatedAt,
//                 source: 'isSearch',
//               ),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       print('Navigation Error for Video Player: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Could not play the video.')),
//       );
//     }
//   }

//   void _performSearch(String searchTerm) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     if (searchTerm.trim().isEmpty) {
//       setState(() {
//         isLoading = false;
//         searchResults.clear();
//         _itemFocusNodes.clear();
//         _errorMessage = '';
//         _focusedIndex = 0;
//       });
//       return;
//     }

//     _debounce = Timer(const Duration(milliseconds: 300), () async {
//       if (!mounted) return;
//       setState(() {
//         isLoading = true;
//         searchResults.clear();
//         _itemFocusNodes.forEach((node) => node.dispose());
//         _itemFocusNodes.clear();
//         _errorMessage = '';
//         _focusedIndex = 0;
//       });

//       try {
//         final results = await fetchFromApi(searchTerm);
//         if (!mounted) return;
//         setState(() {
//           searchResults = results;
//           _itemFocusNodes.addAll(
//               List.generate(searchResults.length, (index) => FocusNode()));
//           isLoading = false;
//         });
//       } catch (e) {
//         if (!mounted) return;
//         setState(() {
//           isLoading = false;
//           _errorMessage = e.toString();
//         });
//       }
//     });
//   }

//   void _handleKeyNavigation(RawKeyEvent event) {
//     if (event is! RawKeyDownEvent || searchResults.isEmpty) return;

//     final totalItems = searchResults.length;
//     int previousIndex = _focusedIndex;

//     if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//       if (_focusedIndex < _itemsPerRow) {
//         _searchIconFocusNode.requestFocus();
//         return;
//       } else {
//         final newIndex = _focusedIndex - _itemsPerRow;
//         if (newIndex >= 0) {
//           setState(() => _focusedIndex = newIndex);
//         }
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//       final newIndex = _focusedIndex + _itemsPerRow;
//       if (newIndex < totalItems) {
//         setState(() => _focusedIndex = newIndex);
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//       if (_focusedIndex > 0) {
//         setState(() => _focusedIndex--);
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//       if (_focusedIndex < totalItems - 1) {
//         setState(() => _focusedIndex++);
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.select ||
//         event.logicalKey == LogicalKeyboardKey.enter) {
//       _onItemTap(context, _focusedIndex);
//     }

//     if (previousIndex != _focusedIndex) {
//       _updateAndScrollToFocus();
//       HapticFeedback.lightImpact();
//     }
//   }

//   void _updateAndScrollToFocus() {
//     if (!mounted || _focusedIndex >= _itemFocusNodes.length) return;

//     final focusedNode = _itemFocusNodes[_focusedIndex];
//     focusedNode.requestFocus();

//     // Scroll command ko agle frame tak delay karein
//     // Isse yeh sunishchit hoga ki widget ka context scroll ke liye taiyar hai
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (focusedNode.context != null) {
//         Scrollable.ensureVisible(
//           focusedNode.context!,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOutCubic,
//           alignment: 0.5, // Item ko center mein rakhega
//         );
//       }
//     });
//   }

//   void _toggleKeyboard() {
//     setState(() {
//       _showKeyboard = !_showKeyboard;
//       if (!_showKeyboard) {
//         _searchIconFocusNode.requestFocus();
//       }
//     });
//   }

//   Widget _buildQwertyKeyboard() {
//     final row1 = "1234567890".split('');
//     final row2 = "qwertyuiop".split('');
//     final row3 = "asdfghjkl".split('');
//     final row4 = ["zxcvbnm", "DEL"]
//         .expand((e) => e == "DEL" ? [e] : e.split(''))
//         .toList();
//     final row5 = ["SHIFT", " ", "OK"];

//     return Container(
//       color: ProfessionalVODColors.surfaceDark.withOpacity(0.95),
//       padding: EdgeInsets.all(20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildKeyboardRow(row1),
//           _buildKeyboardRow(row2),
//           _buildKeyboardRow(row3),
//           _buildKeyboardRow(row4),
//           _buildKeyboardRow(row5, isSpecialRow: true),
//         ],
//       ),
//     );
//   }

//   Widget _buildKeyboardRow(List<String> keys, {bool isSpecialRow = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: keys.map((key) {
//         double width = screenwdt * 0.07;
//         if (key == ' ') width = screenwdt * 0.18;
//         if (key == 'OK' || key == 'SHIFT' || key == 'DEL')
//           width = screenwdt * 0.11;

//         String displayKey = key;
//         if (key != 'SHIFT' && key != 'DEL' && key != 'OK' && key.length == 1) {
//           displayKey = _isShiftEnabled ? key.toUpperCase() : key.toLowerCase();
//         }

//         return _buildKey(displayKey, originalKey: key, width: width);
//       }).toList(),
//     );
//   }

//   Widget _buildKey(String label, {String? originalKey, double? width}) {
//     final keyToProcess = originalKey ?? label;

//     return Container(
//       width: width ?? screenwdt * 0.18,
//       height: screenhgt * 0.08,
//       margin: const EdgeInsets.all(2),
//       child: ElevatedButton(
//         onPressed: () => _onKeyPressed(keyToProcess),
//         style: ElevatedButton.styleFrom(
//             backgroundColor: (keyToProcess == 'SHIFT' && _isShiftEnabled)
//                 ? Colors.white.withOpacity(0.3)
//                 : Colors.white.withOpacity(0.1),
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//             padding: EdgeInsets.zero),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: nametextsz * 1.5,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         if (didPop) return;
//         if (_showKeyboard) {
//           setState(() {
//             _showKeyboard = false;
//             _searchIconFocusNode.requestFocus();
//           });
//         } else {
//           context.read<FocusProvider>().requestWatchNowFocus();
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: Padding(
//                             padding:  EdgeInsets.symmetric(horizontal: screenwdt * 0.0, vertical: screenhgt * 0.0001),

//           child: Container(
//             color: ProfessionalVODColors.primaryDark,
//             child: Column(
//               children: [
//                 Expanded(
//                   child: RawKeyboardListener(
//                     focusNode: _gridFocusNode,
//                     onKey: _handleKeyNavigation,
//                     child: CustomScrollView(
//                       controller: _scrollController,
//                       slivers: [
//                         SliverToBoxAdapter(
//                           child: _buildSearchBar(),
//                         ),
//                         _buildBodySliver(),
//                       ],
//                     ),
//                   ),
//                 ),
//                 if (_showKeyboard) _buildQwertyKeyboard(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       key: _searchBarKey,
//       padding: EdgeInsets.only(
//         left: screenwdt * 0.05,
//         right: screenwdt * 0.05,
//         top: screenhgt * 0.04,
//         bottom: screenhgt * 0.02,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           const Text(
//             'SEARCH',
//             style: TextStyle(
//                 fontSize: 24,
//                 color: Colors.white,
//                 fontWeight: FontWeight.w800,
//                 letterSpacing: 2.5),
//           ),
//           Row(
//             children: [
//               Container(
//                 width: screenwdt * 0.4,
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.05),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                     color: _showKeyboard
//                         ? ProfessionalVODColors.accentPurple
//                         : Colors.white.withOpacity(0.2),
//                     width: 2,
//                   ),
//                 ),
//                 child: Text(
//                   _searchText.isEmpty ? 'Search content...' : _searchText,
//                   style: TextStyle(
//                     color: _searchText.isEmpty ? Colors.white54 : Colors.white,
//                     fontSize: nametextsz * 1.2,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               SizedBox(width: 10),
//               Focus(
//                 focusNode: _searchIconFocusNode,
//                 onKey: (node, event) {
//                   if (event is RawKeyDownEvent) {
//                     if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                       context
//                           .read<FocusProvider>()
//                           .requestSearchNavigationFocus();
//                       return KeyEventResult.handled;
//                     }
//                     if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
//                         searchResults.isNotEmpty) {
//                       _gridFocusNode.requestFocus();
//                       setState(() {
//                         _focusedIndex = 0;
//                       });
//                       _updateAndScrollToFocus();
//                       return KeyEventResult.handled;
//                     }
//                     if (event.logicalKey == LogicalKeyboardKey.select ||
//                         event.logicalKey == LogicalKeyboardKey.enter) {
//                       _toggleKeyboard();
//                       return KeyEventResult.handled;
//                     }
//                   }
//                   return KeyEventResult.ignored;
//                 },
//                 child: GestureDetector(
//                   onTap: _toggleKeyboard,
//                   child: Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: _searchIconFocusNode.hasFocus
//                           ? ProfessionalVODColors.accentPurple
//                           : Colors.white.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     child: Icon(
//                       _showKeyboard ? Icons.keyboard_hide : Icons.search,
//                       color: Colors.white,
//                       size: _searchIconFocusNode.hasFocus ? 28 : 24,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBodySliver() {
//     if (_errorMessage.isNotEmpty) {
//       return SliverFillRemaining(
//         child: Center(
//           child:
//               Text(_errorMessage, style: const TextStyle(color: Colors.white)),
//         ),
//       );
//     }
//     if (isLoading) {
//       return const SliverFillRemaining(
//         child:
//             Center(child: SpinKitFadingCircle(color: Colors.white, size: 50.0)),
//       );
//     }
//     if (searchResults.isEmpty && _searchText.isNotEmpty) {
//       return const SliverFillRemaining(
//         child: Center(
//             child: Text('No results found',
//                 style: TextStyle(color: Colors.white))),
//       );
//     }
//     if (searchResults.isEmpty) {
//       return const SliverToBoxAdapter(child: SizedBox.shrink());
//     }

//     return SliverPadding(
//       padding: EdgeInsets.symmetric(
//           horizontal: screenwdt * 0.05, vertical: screenhgt * 0.02),
//       sliver: SliverGrid(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: _itemsPerRow,
//           mainAxisSpacing: 20,
//           crossAxisSpacing: 20,
//           childAspectRatio: 1.3,
//         ),
//         delegate: SliverChildBuilderDelegate(
//           (context, index) {
//             final item = searchResults[index];
//             return OptimizedSearchCard(
//               searchItem: item,
//               focusNode: _itemFocusNodes[index],
//               isFocused: _focusedIndex == index,
//               onTap: () => _onItemTap(context, index),
//             );
//           },
//           childCount: searchResults.length,
//         ),
//       ),
//     );
//   }
// }

// class OptimizedSearchCard extends StatelessWidget {
//   final NewsItemModel searchItem;
//   final FocusNode focusNode;
//   final bool isFocused;
//   final VoidCallback onTap;

//   const OptimizedSearchCard({
//     Key? key,
//     required this.searchItem,
//     required this.focusNode,
//     required this.isFocused,
//     required this.onTap,
//   }) : super(key: key);

//   final String localImage = 'assets/placeholder.png';

//   @override
//   Widget build(BuildContext context) {
//     final dominantColor = ProfessionalVODColors.accentPurple;

//     // <<<<------ FIX: WRAP WITH FOCUS WIDGET ------>>>>
//     return Focus(
//       focusNode: focusNode,
//       child: GestureDetector(
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 250),
//           transform: isFocused
//               ? (Matrix4.identity()..scale(1.05))
//               : Matrix4.identity(),
//           transformAlignment: Alignment.center,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(15),
//             boxShadow: [
//               if (isFocused)
//                 BoxShadow(
//                     color: dominantColor.withOpacity(0.4),
//                     blurRadius: 20,
//                     offset: const Offset(0, 8))
//               else
//                 BoxShadow(
//                     color: Colors.black.withOpacity(0.3),
//                     blurRadius: 8,
//                     offset: const Offset(0, 4)),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(15),
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 _buildSearchItemImage(),
//                 if (isFocused) _buildFocusBorder(dominantColor),
//                 _buildGradientOverlay(),
//                 _buildSearchItemInfo(dominantColor),
//                 if (isFocused) _buildPlayButton(dominantColor),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchItemImage() {
//     String imageUrl = searchItem.banner;
//     if (imageUrl.isEmpty) {
//       return Image.asset(localImage, fit: BoxFit.cover);
//     }

//     if (imageUrl.startsWith('data:image')) {
//       try {
//         final imageBytes = _getImageFromBase64String(imageUrl);
//         return Image.memory(imageBytes,
//             fit: BoxFit.cover,
//             errorBuilder: (c, e, s) => Image.asset(localImage));
//       } catch (e) {
//         return Image.asset(localImage);
//       }
//     } else {
//       return CachedNetworkImage(
//         imageUrl: imageUrl,
//         fit: BoxFit.cover,
//         placeholder: (context, url) =>
//             Container(color: ProfessionalVODColors.surfaceDark),
//         errorWidget: (context, url, error) =>
//             Image.asset(localImage, fit: BoxFit.cover),
//       );
//     }
//   }

//   Widget _buildFocusBorder(Color color) {
//     return Positioned.fill(
//         child: Container(
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(15),
//                 border: Border.all(width: 3, color: color))));
//   }

//   Widget _buildGradientOverlay() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.transparent,
//               Colors.black.withOpacity(0.7),
//               Colors.black.withOpacity(0.9)
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchItemInfo(Color dominantColor) {
//     return Positioned(
//       bottom: 12,
//       left: 12,
//       right: 12,
//       child: Text(
//         searchItem.name.toUpperCase(),
//         style: TextStyle(
//           color: isFocused ? dominantColor : Colors.white,
//           fontSize: isFocused ? 13 : 12,
//           fontWeight: FontWeight.w600,
//           shadows: [
//             Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4)
//           ],
//         ),
//         maxLines: 2,
//         overflow: TextOverflow.ellipsis,
//       ),
//     );
//   }

//   Widget _buildPlayButton(Color color) {
//     return Positioned(
//       top: 12,
//       right: 12,
//       child: Container(
//         width: 35,
//         height: 35,
//         decoration: BoxDecoration(
//             shape: BoxShape.circle, color: color.withOpacity(0.9)),
//         child:
//             const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
//       ),
//     );
//   }
// }








import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https; // Renamed to 'https'
import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/webseries_details_page.dart';
import 'package:mobi_tv_entertainment/components/provider/device_info_provider.dart';
// InternalFocusProvider import (jaisa example mein tha)
import 'package:mobi_tv_entertainment/components/provider/internal_focus_provider.dart';
import 'package:mobi_tv_entertainment/components/video_widget/custom_youtube_player.dart';
import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/components/video_widget/youtube_webview_player.dart';
import 'package:mobi_tv_entertainment/components/widgets/models/news_item_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import '../home_screen_pages/religious_channel/religious_channel_details_page.dart';
import '../home_screen_pages/sports_category/tv_show_final_details_page.dart';
import '../home_screen_pages/tv_show/tv_show_final_details_page.dart';
import '../home_screen_pages/tv_show_pak/tv_show_final_details_page.dart';
import '../../main.dart'; // Assuming bannerhgt, screenwdt, etc. are defined here
import '../provider/focus_provider.dart'; // Ye provider bhi zaroori hai
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Loading indicator ke liye

//==============================================================================
// SECTION 1: COMMON CLASSES, MODELS, AND CONSTANTS
//==============================================================================

class ProfessionalColors {
  static const primaryDark = Color(0xFF0A0E1A);
  static const surfaceDark = Color(0xFF1A1D29);
  static const cardDark = Color(0xFF2A2D3A);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentPurple = Color(0xFF8B5CF6);
  static const accentPink = Color(0xFFEC4899);
  static const accentOrange = Color(0xFFF59E0B);
  static const accentRed = Color(0xFFEF4444);
  static const accentGreen = Color(0xFF10B981);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
}

class AnimationTiming {
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
}

// Focus colors list
final List<Color> _focusColors = [
  ProfessionalColors.accentBlue,
  ProfessionalColors.accentPurple,
  ProfessionalColors.accentGreen,
  ProfessionalColors.accentOrange,
  ProfessionalColors.accentPink,
  ProfessionalColors.accentRed
];

//==============================================================================
// SECTION 2: API AND DATA
//==============================================================================

Future<List<NewsItemModel>> fetchFromApi(String searchTerm) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authKey = prefs.getString('result_auth_key');

    final url = Uri.parse(
        'https://dashboard.cpplayers.com/api/v2/getSearchCategoryList');
    final body = json.encode({'keywords': searchTerm});

    final response = await https.post(
      url,
      headers: {
        'auth-key': authKey ?? '',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'domain': 'coretechinfo.com'
      },
      body: body,
    );

    if (response.statusCode == 200) {
      String responseBody = response.body.trim();
      if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
        final dynamic responseData = json.decode(responseBody);
        List<dynamic> dataList;

        if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map && responseData['data'] is List) {
          dataList = responseData['data'];
        } else {
          throw Exception('Unexpected response format');
        }

        List<NewsItemModel> newsItems = [];
        for (var itemDataRaw in dataList) {
          try {
            if (itemDataRaw is Map<String, dynamic> &&
                itemDataRaw['status']?.toString() == '1') {
              newsItems.add(NewsItemModel.fromJson(itemDataRaw));
            }
          } catch (e) {
            debugPrint('Error parsing item: $e');
          }
        }
        return newsItems;
      } else {
        throw Exception('Invalid response format');
      }
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Authentication failed. Please log in again.');
    } else {
      throw Exception('Failed to load data from API: ${response.statusCode}');
    }
  } catch (e) {
    if (e.toString().contains('Authentication')) {
      rethrow;
    }
    return [];
  }
}

//==============================================================================
// SECTION 3: MAIN PAGE WIDGET AND STATE
//==============================================================================

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  // Data State
  List<NewsItemModel> _searchResultItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSearchLoading = false;
  bool _isNavigationLocked = false;
  Timer? _navigationLockTimer;

  // UI and Animation State
  bool _isVideoLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Focus and Scroll Controllers
  final FocusNode _widgetFocusNode = FocusNode();
  final ScrollController _resultScrollController = ScrollController();
  late FocusNode _searchTriggerFocusNode;
  List<FocusNode> _resultFocusNodes = [];
  List<FocusNode> _keyboardFocusNodes = [];
  int _focusedResultIndex = -1;

  // Search State
  bool _isSearching = true;
  bool _showKeyboard = false;
  String _searchText = '';
  Timer? _debounce;

  // Keyboard State
  int _focusedKeyRow = 0;
  int _focusedKeyCol = 0;
  
  // BADLAAV: Naya Keyboard Layout
  final List<List<String>> _keyboardLayout = [
    "1234567890".split(''), // Row 0 (10 keys)
    "qwertyuiop".split(''), // Row 1 (10 keys)
    ["a", "s", "d", "f", "g", "h", "j", "k", "l", "DEL"], // Row 2 (10 keys) - DEL yahaan aa gaya
    ["OK","z", "x", "c", "v", "b", "n", "m", "OK"], // Row 3 (8 keys) - OK yahaan aa gaya
    [" "], // Row 4 (1 key) - Spacebar akela
  ];

  // Background Animation
  late AnimationController _backgroundController;
  List<Particle> _particles = [];
  final math.Random _random = math.Random();
  int _targetParticleCount = 50; // Dynamic particle count

  @override
  void initState() {
    super.initState();
    _searchTriggerFocusNode = FocusNode();
    _initializeAnimations();
    _initializeFocusNodes();
    _startAnimations();

    // Background animation ko initialize karein
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30), // Animation ki speed
      vsync: this,
    )..repeat(); // Hamesha chalta rahega

    _backgroundController.addListener(() {
      _updateParticles();
      setState(() {});
    });

    // Particles ko pehli baar banayein
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeParticles();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set initial focus on the Search Trigger button
      if (mounted) {
        Provider.of<InternalFocusProvider>(context, listen: false)
            .updateName("Search");
        _searchTriggerFocusNode.requestFocus();
      }
      // Set node for side menu navigation
      context
          .read<FocusProvider>()
          .registerFocusNode('searchIcon', _searchTriggerFocusNode);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _backgroundController.dispose();
    _widgetFocusNode.dispose();
    _resultScrollController.dispose();
    _debounce?.cancel();
    _navigationLockTimer?.cancel();
    _disposeFocusNodes(_resultFocusNodes);
    _disposeFocusNodes(_keyboardFocusNodes);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_showKeyboard) {
          setState(() {
            _showKeyboard = false;
            _focusedKeyRow = 0;
            _focusedKeyCol = 0;
            _targetParticleCount = 50; // Particles kam karein
            _initializeParticles();
          });
          _searchTriggerFocusNode.requestFocus();
        } else {
          // Navigate back to the main app focus (e.g., side menu)
          // context.read<FocusProvider>().requestFocus('watchNow');
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: ProfessionalColors.primaryDark,
        body: Focus(
          focusNode: _widgetFocusNode,
          autofocus: true,
          onKey: _onKeyHandler,
          child: Center(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildBackground(), // Animated background poori screen par
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : _errorMessage != null
                        ? _buildErrorWidget()
                        : _buildPageContent(),
                if (_isVideoLoading && _errorMessage == null)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.8),
                      child: const Center(
                        child:
                            SpinKitFadingCircle(color: Colors.white, size: 50.0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //=================================================
  // SECTION 3.1: KEYBOARD AND FOCUS NAVIGATION
  //=================================================

  KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return KeyEventResult.ignored;

    bool searchTriggerHasFocus = _searchTriggerFocusNode.hasFocus;
    bool resultHasFocus = _resultFocusNodes.any((n) => n.hasFocus);
    bool keyboardHasFocus = _keyboardFocusNodes.any((n) => n.hasFocus);
    final LogicalKeyboardKey key = event.logicalKey;

    if (key == LogicalKeyboardKey.goBack) {
      if (_showKeyboard) {
        setState(() {
          _showKeyboard = false;
          _focusedKeyRow = 0;
          _focusedKeyCol = 0;
          _targetParticleCount = 50; // Particles kam karein
          _initializeParticles();
        });
        _searchTriggerFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored; // Allow navigator to pop
    }

    if (keyboardHasFocus && _showKeyboard) {
      return _navigateKeyboard(key);
    }

    if (searchTriggerHasFocus) return _navigateFromSearchTrigger(key);
    if (resultHasFocus) return _navigateResults(key);

    return KeyEventResult.ignored;
  }

  KeyEventResult _navigateFromSearchTrigger(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      setState(() {
        _showKeyboard = true;
        _targetParticleCount = 80; // Particles badhayein
        _initializeParticles();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _keyboardFocusNodes.isNotEmpty) {
          _keyboardFocusNodes[0].requestFocus();
        }
      });
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown && _resultFocusNodes.isNotEmpty) {
      _focusFirstResultItemWithScroll();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      // Handle navigation to side menu
      context.read<FocusProvider>().requestFocus('searchNavigation');
      return KeyEventResult.handled;
    }
    return KeyEventResult.handled;
  }

  // KeyEventResult _navigateResults(LogicalKeyboardKey key) {
  //   if (_isNavigationLocked) return KeyEventResult.handled;
  //   if (_focusedResultIndex < 0 || _resultFocusNodes.isEmpty) {
  //     return KeyEventResult.ignored;
  //   }

  //   setState(() => _isNavigationLocked = true);
  //   _navigationLockTimer = Timer(const Duration(milliseconds: 100), () {
  //     if (mounted) setState(() => _isNavigationLocked = false);
  //   });

  //   int newIndex = _focusedResultIndex;
  //   final currentList = _searchResultItems;

  //   if (key == LogicalKeyboardKey.arrowUp) {
  //     _searchTriggerFocusNode.requestFocus();
  //     setState(() => _focusedResultIndex = -1);
  //     Provider.of<InternalFocusProvider>(context, listen: false)
  //         .updateName("Search");
  //     _isNavigationLocked = false;
  //     _navigationLockTimer?.cancel();
  //     return KeyEventResult.handled;
  //   } else if (key == LogicalKeyboardKey.arrowLeft) {
  //     if (newIndex > 0) newIndex--;
  //   } else if (key == LogicalKeyboardKey.arrowRight) {
  //     if (newIndex < currentList.length - 1) newIndex++;
  //   } else if (key == LogicalKeyboardKey.select ||
  //       key == LogicalKeyboardKey.enter) {
  //     _isNavigationLocked = false;
  //     _navigationLockTimer?.cancel();
  //     _playContent(currentList[_focusedResultIndex]);
  //     return KeyEventResult.handled;
  //   }

  //   if (newIndex != _focusedResultIndex) {
  //     setState(() => _focusedResultIndex = newIndex);
  //     if (newIndex < _resultFocusNodes.length) {
  //       _resultFocusNodes[newIndex].requestFocus();
  //       _updateAndScrollToFocus(_resultFocusNodes, newIndex,
  //           _resultScrollController, (screenwdt / 7) + 12);
  //     }
  //   } else {
  //     _navigationLockTimer?.cancel();
  //     if (mounted) setState(() => _isNavigationLocked = false);
  //   }

  //   return KeyEventResult.handled;
  // }



  KeyEventResult _navigateResults(LogicalKeyboardKey key) {
    if (_isNavigationLocked) return KeyEventResult.handled;
    if (_focusedResultIndex < 0 || _resultFocusNodes.isEmpty) {
      return KeyEventResult.ignored;
    }

    setState(() => _isNavigationLocked = true);
    _navigationLockTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isNavigationLocked = false);
    });

    int newIndex = _focusedResultIndex;
    final currentList = _searchResultItems;

    if (key == LogicalKeyboardKey.arrowUp) {
      
      // === BADLAAV START ===
      if (_showKeyboard) {
        // Keyboard khula hai, focus spacebar par le jaayein
        int spacebarRow = 4;
        int spacebarCol = 0;
        int spacebarFocusIndex = _getFocusNodeIndexForKey(spacebarRow, spacebarCol);

        if (spacebarFocusIndex < _keyboardFocusNodes.length) {
          _keyboardFocusNodes[spacebarFocusIndex].requestFocus();
          setState(() {
            _focusedKeyRow = spacebarRow;
            _focusedKeyCol = spacebarCol;
            _focusedResultIndex = -1; // Result se focus hat gaya
          });
        }
      } else {
        // Keyboard band hai, purana logic (focus search bar par le jaayein)
        _searchTriggerFocusNode.requestFocus();
        setState(() => _focusedResultIndex = -1);
        Provider.of<InternalFocusProvider>(context, listen: false)
            .updateName("Search");
      }
      // === BADLAAV END ===

      _isNavigationLocked = false;
      _navigationLockTimer?.cancel();
      return KeyEventResult.handled;

    } else if (key == LogicalKeyboardKey.arrowLeft) {
      if (newIndex > 0) newIndex--;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      if (newIndex < currentList.length - 1) newIndex++;
    } else if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter) {
      _isNavigationLocked = false;
      _navigationLockTimer?.cancel();
      _playContent(currentList[_focusedResultIndex]);
      return KeyEventResult.handled;
    }

    if (newIndex != _focusedResultIndex) {
      setState(() => _focusedResultIndex = newIndex);
      if (newIndex < _resultFocusNodes.length) {
        _resultFocusNodes[newIndex].requestFocus();
        _updateAndScrollToFocus(_resultFocusNodes, newIndex,
            _resultScrollController, (screenwdt / 7) + 12);
      }
    } else {
      _navigationLockTimer?.cancel();
      if (mounted) setState(() => _isNavigationLocked = false);
    }

    return KeyEventResult.handled;
  }

  // // BADLAAV: Naya navigation logic (spacebar se down)
  // KeyEventResult _navigateKeyboard(LogicalKeyboardKey key) {
  //   // Spacebar se neeche results par jaana
  //   if (_focusedKeyRow == 4 && // Spacebar row
  //       _focusedKeyCol == 0 && // Spacebar key
  //       key == LogicalKeyboardKey.arrowDown &&
  //       _resultFocusNodes.isNotEmpty) {
      
  //     _focusFirstResultItemWithScroll();
  //     return KeyEventResult.handled;
  //   }
    
  //   int newRow = _focusedKeyRow;
  //   int newCol = _focusedKeyCol;
  //   if (key == LogicalKeyboardKey.arrowUp) {
  //     if (newRow > 0) {
  //       newRow--;
  //       // Nayi row mein column ko adjust karein taaki out of bounds na ho
  //       newCol = math.min(newCol, _keyboardLayout[newRow].length - 1);
  //     }
  //   } else if (key == LogicalKeyboardKey.arrowDown) {
  //     if (newRow < _keyboardLayout.length - 1) {
  //       newRow++;
  //       newCol = math.min(newCol, _keyboardLayout[newRow].length - 1);
  //     }
  //   } else if (key == LogicalKeyboardKey.arrowLeft) {
  //     if (newCol > 0) newCol--;
  //   } else if (key == LogicalKeyboardKey.arrowRight) {
  //     if (newCol < _keyboardLayout[newRow].length - 1) newCol++;
  //   } else if (key == LogicalKeyboardKey.select ||
  //       key == LogicalKeyboardKey.enter) {
  //     final keyValue = _keyboardLayout[newRow][newCol];
  //     _onKeyPressed(keyValue);
  //     return KeyEventResult.handled;
  //   }

  //   if (newRow != _focusedKeyRow || newCol != _focusedKeyCol) {
  //     setState(() {
  //       _focusedKeyRow = newRow;
  //       _focusedKeyCol = newCol;
  //     });
  //     final focusIndex = _getFocusNodeIndexForKey(newRow, newCol);
  //     if (focusIndex >= 0 && focusIndex < _keyboardFocusNodes.length) {
  //       _keyboardFocusNodes[focusIndex].requestFocus();
  //     }
  //   }
  //   return KeyEventResult.handled;
  // }



  KeyEventResult _navigateKeyboard(LogicalKeyboardKey key) {
    
    // === BADLAAV START ===
    // Naya rule: Agar first row par hain aur up dabayein, toh search input par jaayein
    if (_focusedKeyRow == 0 && key == LogicalKeyboardKey.arrowUp) {
      _searchTriggerFocusNode.requestFocus();
      // Keyboard focus ko reset karein
      setState(() {
        _focusedKeyRow = 0; 
        _focusedKeyCol = 0;
      });
      return KeyEventResult.handled;
    }
    // === BADLAAV END ===

    // Purana rule: Spacebar se neeche results par jaana
    if (_focusedKeyRow == 4 && // Spacebar row
        _focusedKeyCol == 0 && // Spacebar key
        key == LogicalKeyboardKey.arrowDown &&
        _resultFocusNodes.isNotEmpty) {
      
      _focusFirstResultItemWithScroll();
      return KeyEventResult.handled;
    }
    
    int newRow = _focusedKeyRow;
    int newCol = _focusedKeyCol;
    if (key == LogicalKeyboardKey.arrowUp) {
      if (newRow > 0) {
        newRow--;
        // Nayi row mein column ko adjust karein taaki out of bounds na ho
        newCol = math.min(newCol, _keyboardLayout[newRow].length - 1);
      }
    } else if (key == LogicalKeyboardKey.arrowDown) {
      if (newRow < _keyboardLayout.length - 1) {
        newRow++;
        newCol = math.min(newCol, _keyboardLayout[newRow].length - 1);
      }
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      if (newCol > 0) newCol--;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      if (newCol < _keyboardLayout[newRow].length - 1) newCol++;
    } else if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter) {
      final keyValue = _keyboardLayout[newRow][newCol];
      _onKeyPressed(keyValue);
      return KeyEventResult.handled;
    }

    if (newRow != _focusedKeyRow || newCol != _focusedKeyCol) {
      setState(() {
        _focusedKeyRow = newRow;
        _focusedKeyCol = newCol;
      });
      final focusIndex = _getFocusNodeIndexForKey(newRow, newCol);
      if (focusIndex >= 0 && focusIndex < _keyboardFocusNodes.length) {
        _keyboardFocusNodes[focusIndex].requestFocus();
      }
    }
    return KeyEventResult.handled;
  }

  //=================================================
  // SECTION 3.2: STATE MANAGEMENT & UI LOGIC
  //=================================================

  void _performSearch(String searchTerm) {
    _debounce?.cancel(); // Purana timer cancel karein

    if (searchTerm.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _isSearchLoading = false;
        _searchResultItems.clear();
        _rebuildResultFocusNodes();
      });
      return;
    }

    // Naya 3-second debounce timer
    _debounce = Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;

      setState(() {
        _isSearchLoading = true;
        _isSearching = true;
        _searchResultItems.clear(); // Nayi search se pehle clear karein
      });

      try {
        final results = await fetchFromApi(searchTerm);
        if (!mounted) return;
        setState(() {
          _searchResultItems = results;
          _isSearchLoading = false;
          _rebuildResultFocusNodes();
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isSearchLoading = false;
          _errorMessage = e.toString();
        });
      }
    });
  }

  void _onKeyPressed(String value) {
    setState(() {
      if (value == 'OK') {
        _showKeyboard = false;
        _targetParticleCount = 50; // Particles kam karein
        _initializeParticles();
        
        // Agar debounce timer chal raha hai, to use cancel karke search ko force karein
        if (_debounce?.isActive ?? false) {
          _debounce?.cancel();
          _forceSearch(_searchText); // Ek naya function jo turant search karega
        }

        if (_resultFocusNodes.isNotEmpty) {
          _focusFirstResultItemWithScroll();
        } else {
          _searchTriggerFocusNode.requestFocus();
        }
        return;
      }
      if (value == 'DEL') {
        if (_searchText.isNotEmpty) {
          _searchText = _searchText.substring(0, _searchText.length - 1);
        }
      } else if (value == ' ') {
        _searchText += ' ';
      } else {
        _searchText += value;
      }
      _performSearch(_searchText); // 3-second debounce ke saath search karega
    });
  }

  // Naya helper function jo 'OK' dabane par turant search karta hai
  void _forceSearch(String searchTerm) async {
    if (searchTerm.trim().isEmpty) return;
    if (!mounted) return;
    
    setState(() {
      _isSearchLoading = true;
      _isSearching = true;
      _searchResultItems.clear();
    });

    try {
      final results = await fetchFromApi(searchTerm);
      if (!mounted) return;
      setState(() {
        _searchResultItems = results;
        _isSearchLoading = false;
        _rebuildResultFocusNodes();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearchLoading = false;
        _errorMessage = e.toString();
      });
    }
  }


  Future<void> _playContent(NewsItemModel content) async {
    if (_isVideoLoading || !mounted) return;
    setState(() => _isVideoLoading = true);

    try {
      final int? parsedContentType = int.tryParse(content.contentType ?? '');

      // Step 1: Handle content types that need a details page first.
      try {
        if (parsedContentType == 2) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebSeriesDetailsPage(
                id: int.tryParse(content.id) ?? 0,
                banner: content.banner,
                poster: content.poster,
                logo: content.banner, // Assuming banner is used as logo
                name: content.name,
                updatedAt: content.updatedAt,
              ),
            ),
          );
        } else if (parsedContentType == 4) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TvShowFinalDetailsPage(
                id: int.tryParse(content.id) ?? 0,
                banner: content.banner,
                poster: content.poster,
                name: content.name,
              ),
            ),
          );
        } else if (parsedContentType == 5) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TvShowPakFinalDetailsPage(
                id: int.tryParse(content.id) ?? 0,
                banner: content.banner,
                poster: content.poster,
                name: content.name,
                updatedAt: content.updatedAt,
              ),
            ),
          );
        } else if (parsedContentType == 7) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReligiousChannelDetailsPage(
                id: int.tryParse(content.id) ?? 0,
                banner: content.banner,
                poster: content.poster,
                name: content.name,
                updatedAt: content.updatedAt,
              ),
            ),
          );
        } else if (parsedContentType == 8) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TournamentFinalDetailsPage(
                id: int.tryParse(content.id) ?? 0,
                banner: content.banner,
                poster: content.poster,
                name: content.name,
                updatedAt: content.updatedAt,
              ),
            ),
          );
        }
      } catch (e) {
        print('Navigation Error for Details Page: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open details page.')),
          );
        }
      }

      // Step 2: Check for video URL
      final String? videoUrl = content.url;
      if (videoUrl == null || videoUrl.isEmpty) {
        if (parsedContentType != 2 &&
            parsedContentType != 4 &&
            parsedContentType != 5 &&
            parsedContentType != 7 &&
            parsedContentType != 8) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No playable content found.')),
          );
        }
        return;
      }

      // Step 3: Handle direct video playback
      if (parsedContentType == 3) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoScreen(
              videoUrl: videoUrl,
              bannerImageUrl: content.banner,
              channelList: [],
              videoId: int.tryParse(content.id),
              name: content.name,
              liveStatus: true,
              updatedAt: content.updatedAt,
              source: 'isSearch',
            ),
          ),
        );
      } else if (parsedContentType == 1) {
        if (content.sourceType == 'YoutubeLive' ||
            content.sourceType == 'youtube') {
          final deviceInfo = context.read<DeviceInfoProvider>();
          if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => YoutubeWebviewPlayer(
                        videoUrl: content.url, name: content.name)));
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomYoutubePlayer(
                  videoData: VideoData(
                    id: content.id.toString(),
                    title: content.name,
                    youtubeUrl: content.url,
                    thumbnail: content.banner ?? content.poster ?? '',
                    description: content.description ?? '',
                  ),
                  playlist: [
                    VideoData(
                      id: content.id.toString(),
                      title: content.name,
                      youtubeUrl: content.url,
                      thumbnail: content.banner ?? content.poster ?? '',
                      description: content.description ?? '',
                    ),
                  ],
                ),
              ),
            );
          }
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoScreen(
                videoUrl: content.url,
                bannerImageUrl: content.banner,
                channelList: [],
                videoId: int.tryParse(content.id),
                name: content.name,
                liveStatus: false, // It's VOD
                updatedAt: content.updatedAt,
                source: 'isSearch',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error playing content: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isVideoLoading = false);
      }
    }
  }

  //=================================================
  // SECTION 3.3: INITIALIZATION AND CLEANUP
  //=================================================

  void _initializeAnimations() {
    _fadeController =
        AnimationController(duration: AnimationTiming.medium, vsync: this);
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
  }

  void _startAnimations() {
    _fadeController.forward();
  }

  void _initializeFocusNodes() {
    _rebuildResultFocusNodes();
    _rebuildKeyboardFocusNodes();
  }

  void _rebuildResultFocusNodes() {
    _disposeFocusNodes(_resultFocusNodes);
    final currentList = _searchResultItems;
    _resultFocusNodes = List.generate(
        currentList.length, (i) => FocusNode(debugLabel: 'Result-$i'));
  }

  void _rebuildKeyboardFocusNodes() {
    _disposeFocusNodes(_keyboardFocusNodes);
    int totalKeys = _keyboardLayout.fold(0, (prev, row) => prev + row.length);
    _keyboardFocusNodes = List.generate(
        totalKeys, (index) => FocusNode(debugLabel: 'Key-$index'));
  }

  int _getFocusNodeIndexForKey(int row, int col) {
    int index = 0;
    for (int r = 0; r < row; r++) {
      index += _keyboardLayout[r].length;
    }
    return index + col;
  }

  void _disposeFocusNodes(List<FocusNode> nodes) {
    for (var node in nodes) {
      node.dispose();
    }
  }

  void _updateAndScrollToFocus(List<FocusNode> nodes, int index,
      ScrollController controller, double itemWidth) {
    if (!mounted ||
        index < 0 ||
        index >= nodes.length ||
        !controller.hasClients) return;
    double screenWidth = MediaQuery.of(context).size.width;
    double scrollPosition =
        (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
    controller.animateTo(
      scrollPosition.clamp(0.0, controller.position.maxScrollExtent),
      duration: AnimationTiming.fast,
      curve: Curves.easeInOut,
    );
  }

  void _focusFirstResultItemWithScroll() {
    if (_resultFocusNodes.isEmpty) return;
    if (_resultScrollController.hasClients) {
      _resultScrollController.animateTo(0.0,
          duration: AnimationTiming.fast, curve: Curves.easeInOut);
    }
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted && _resultFocusNodes.isNotEmpty) {
        setState(() => _focusedResultIndex = 0);
        _resultFocusNodes[0].requestFocus();
      }
    });
  }

  //=================================================
  // SECTION 3.4: WIDGET BUILDER METHODS
  //=================================================

  Widget _buildPageContent() {
    return Column(
      children: [
        SizedBox(height: screenhgt * 0.02),
        _buildBeautifulAppBar(),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildContentBody(),
          ),
        ),
      ],
    );
  }

  Widget _buildContentBody() {
    return Column(
      children: [
        Expanded(
          child: _showKeyboard
              ? _buildSearchUI() // Keyboard ab yahaan dikhega
              : SizedBox.shrink(), // Keyboard band hone par khali jagah
        ),
        SizedBox(height: screenhgt * 0.02),
        _buildResultsList(), // Results list apni fixed height par neeche rahegi
      ],
    );
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Purana Gradient (Base layer)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ProfessionalColors.primaryDark,
                ProfessionalColors.surfaceDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Naya Animated Particle Layer
        CustomPaint(
          painter: ParticlePainter(particles: _particles),
        ),

        // Purana Overlay Gradient (Top layer)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ProfessionalColors.primaryDark.withOpacity(0.2),
                ProfessionalColors.primaryDark.withOpacity(0.4),
                ProfessionalColors.primaryDark.withOpacity(0.6),
                ProfessionalColors.primaryDark.withOpacity(0.9),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.5, 0.7, 0.9],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBeautifulAppBar() {
    bool searchBarHasFocus = _searchTriggerFocusNode.hasFocus;
    final focusedName = context.watch<InternalFocusProvider>().focusedItemName;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(
            top: screenhgt * 0.02,
            bottom: 8.0, // Text clipping fix
            left: screenwdt * 0.03,
            right: 20,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // (Child 1): Focused Name (aadhe space mein)
              Expanded(
                flex: 1, // 50% space
                child: Text(
                  searchBarHasFocus ? "Search" : focusedName,
                  style: TextStyle(
                    color: searchBarHasFocus
                        ? Colors.white
                        : ProfessionalColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 20), // Spacer

              // (Child 2): Search Input Box (aadhe space mein)
              Expanded(
                flex: 1, // 50% space
                child: Focus(
                  focusNode: _searchTriggerFocusNode,
                  onFocusChange: (hasFocus) {
                    if (hasFocus) {
                      Provider.of<InternalFocusProvider>(context, listen: false)
                          .updateName("Search");
                    }
                    setState(() {}); // Rebuild to show focus highlight
                  },
                  child: GestureDetector(
                    onTap: () {
                      _searchTriggerFocusNode.requestFocus();
                      setState(() {
                         _showKeyboard = true;
                         _targetParticleCount = 80; // Particles badhayein
                         _initializeParticles();
                      });
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _keyboardFocusNodes.isNotEmpty) {
                          _keyboardFocusNodes[0].requestFocus();
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: AnimationTiming.fast,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: searchBarHasFocus
                            ? ProfessionalColors.accentPurple.withOpacity(0.3)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _showKeyboard
                              ? ProfessionalColors.accentPurple
                              : searchBarHasFocus
                                  ? Colors.white
                                  : ProfessionalColors.textSecondary
                                      .withOpacity(0.5),
                          width: searchBarHasFocus ? 3 : 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search,
                              color: searchBarHasFocus
                                  ? Colors.white
                                  : ProfessionalColors.textSecondary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _searchText.isEmpty
                                  ? 'Search...'
                                  : _searchText,
                              style: TextStyle(
                                color: _searchText.isEmpty
                                    ? Colors.white54
                                    : Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    final currentList = _searchResultItems;
    final double fixedListHeight = (bannerhgt * 1.1) + 40.0;

    if (_isSearchLoading) {
      return SizedBox(
        height: fixedListHeight,
        child: const Center(
            child: SpinKitFadingCircle(color: Colors.white, size: 50.0)),
      );
    }

    if (currentList.isEmpty) {
      return SizedBox(
        height: fixedListHeight,
        child: Center(
          child: Text(
            _searchText.isNotEmpty
                ? "No results found for '$_searchText'"
                : 'Start typing to see results.',
            style: const TextStyle(
                color: ProfessionalColors.textSecondary, fontSize: 16),
          ),
        ),
      );
    }
    return SizedBox(
      height: fixedListHeight,
      child: Padding(
        padding: const EdgeInsets.only(top: 1.0),
        child: ListView.builder(
          clipBehavior: Clip.none,
          controller: _resultScrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          itemCount: currentList.length,
          itemBuilder: (context, index) {
            final item = currentList[index];
            return InkWell(
              focusNode: _resultFocusNodes[index],
              onTap: () => _playContent(item),
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  setState(() => _focusedResultIndex = index);
                  Provider.of<InternalFocusProvider>(context, listen: false)
                      .updateName(item.name);
                  _updateAndScrollToFocus(_resultFocusNodes, index,
                      _resultScrollController, (screenwdt / 7) + 12);
                }
              },
              child: SearchItemCard(
                item: item,
                isFocused: _focusedResultIndex == index,
                onTap: () => _playContent(item),
                cardHeight: bannerhgt * 1.1,
                uniqueIndex: index,
                focusColors: _focusColors,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildQwertyKeyboard(),
      ],
    );
  }

  Widget _buildQwertyKeyboard() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int rowIndex = 0; rowIndex < _keyboardLayout.length; rowIndex++)
            _buildKeyboardRow(_keyboardLayout[rowIndex], rowIndex),
        ],
      ),
    );
  }

  // BADLAAV: Naya keyboard build logic
  Widget _buildKeyboardRow(List<String> keys, int rowIndex) {
    int startIndex = 0;
    for (int i = 0; i < rowIndex; i++) {
      startIndex += _keyboardLayout[i].length;
    }

    // Naya width logic
    final double margin = 4.0;
    // 10 key-waali row ke hisaab se base width
    final double baseKeyWidth = screenwdt * 0.07; // Thoda chhota base
    // 10 keys aur unke margins ke hisaab se poori keyboard ki width
    final double totalKeyboardWidth = (baseKeyWidth * 10) + (margin * 2 * 10);
    // DEL aur OK ke liye special width
    final double specialKeyWidth = baseKeyWidth * 1.8; // Thoda extra chauda

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.asMap().entries.map((entry) {
        final colIndex = entry.key;
        final key = entry.value;
        final focusIndex = startIndex + colIndex;
        final isFocused =
            _focusedKeyRow == rowIndex && _focusedKeyCol == colIndex;
        double width;

        // Nayi width conditions
        if (key == ' ') {
          width = totalKeyboardWidth - (margin * 2); // Poori width
        } else if (key == 'OK' || key == 'DEL') {
          width = specialKeyWidth;
        } else {
          width = baseKeyWidth;
        }

        return Container(
          width: width,
          height: screenhgt * 0.065,
          margin: EdgeInsets.all(margin),
          child: Focus(
            focusNode: _keyboardFocusNodes[focusIndex],
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                setState(() {
                  _focusedKeyRow = rowIndex;
                  _focusedKeyCol = colIndex;
                });
              }
            },
            child: ElevatedButton(
              onPressed: () => _onKeyPressed(key),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFocused
                    ? ProfessionalColors.accentPurple
                    : Colors.white.withOpacity(0.1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: isFocused
                      ? const BorderSide(color: Colors.white, width: 3)
                      : BorderSide.none,
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                key,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, color: Colors.white, size: 50),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An unknown error occurred.',
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _searchText = "";
              });
              _performSearch("");
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: ProfessionalColors.accentBlue,
            ),
          ),
        ],
      ),
    );
  }

  //=================================================
  // SECTION 3.5: BACKGROUND ANIMATION LOGIC
  //=================================================

  void _initializeParticles() {
    if (screenwdt == 0 || screenhgt == 0) return;

    final List<Color> baseColors = [
      ProfessionalColors.accentBlue,
      ProfessionalColors.accentPurple,
      ProfessionalColors.accentGreen,
      ProfessionalColors.accentOrange,
      ProfessionalColors.accentRed,
      ProfessionalColors.accentPink,
      Colors.cyan,
      Colors.amber,
    ];

    _particles = List.generate(_targetParticleCount, (index) { // Dynamic count
      final Color randomBaseColor = baseColors[_random.nextInt(baseColors.length)];
      
      final List<Color> particleGradient = [
        randomBaseColor.withOpacity(_random.nextDouble() * 0.3 + 0.2), 
        randomBaseColor.withOpacity(_random.nextDouble() * 0.6 + 0.4),
      ];

      return Particle(
        position: Offset(
          _random.nextDouble() * screenwdt,
          _random.nextDouble() * screenhgt,
        ),
        color: randomBaseColor.withOpacity(0.7), 
        radius: _random.nextDouble() * 2 + 1, 
        speed: _random.nextDouble() * 0.3 + 0.2,
        angle: _random.nextDouble() * 2 * math.pi,
        gradientColors: particleGradient,
        glowRadius: _random.nextDouble() * 5 + 3,
      );
    });
  }

  void _updateParticles() {
    if (screenwdt == 0 || screenhgt == 0) return;

    for (var p in _particles) {
      double newX = p.position.dx + math.cos(p.angle) * p.speed;
      double newY = p.position.dy + math.sin(p.angle) * p.speed;

      if (newX < 0) {
        newX = screenwdt;
      } else if (newX > screenwdt) {
        newX = 0;
      }

      if (newY < 0) {
        newY = screenhgt;
      } else if (newY > screenhgt) {
        newY = 0;
      }

      p.position = Offset(newX, newY);
    }
  }
}

//==============================================================================
// SECTION 4: REUSABLE UI COMPONENTS
//==============================================================================

class SearchItemCard extends StatelessWidget {
  final NewsItemModel item;
  final bool isFocused;
  final VoidCallback onTap;
  final double cardHeight;
  final int uniqueIndex;
  final List<Color> focusColors;

  const SearchItemCard({
    super.key,
    required this.item,
    required this.isFocused,
    required this.onTap,
    required this.cardHeight,
    required this.uniqueIndex,
    required this.focusColors,
  });

  @override
  Widget build(BuildContext context) {
    final focusColor = focusColors[uniqueIndex % focusColors.length];

    return Container(
      width: screenwdt / 7,
      margin: const EdgeInsets.only(right: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: cardHeight,
            child: AnimatedContainer(
              duration: AnimationTiming.fast,
              transform: isFocused
                  ? (Matrix4.identity()..scale(1.05))
                  : Matrix4.identity(),
              transformAlignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: isFocused
                      ? Border.all(color: focusColor, width: 3)
                      : Border.all(color: Colors.transparent, width: 3),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                              color: focusColor.withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 1)
                        ]
                      : []),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildItemImage(),
                    if (isFocused)
                      Positioned(
                          left: 5,
                          top: 5,
                          child: Container(
                              color: Colors.black.withOpacity(0.4),
                              child: Icon(Icons.play_circle_filled_outlined,
                                  color: focusColor, size: 40))),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2.0, left: 2.0, right: 2.0),
            child: Text(item.name,
                style: TextStyle(
                    color: isFocused
                        ? focusColor
                        : ProfessionalColors.textSecondary,
                    fontSize: 14,
                    fontWeight:
                        isFocused ? FontWeight.bold : FontWeight.normal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildItemImage() {
    final imageUrl = item.banner.isNotEmpty ? item.banner : item.poster;

    return imageUrl != null && imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildImagePlaceholder();
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder();
            },
          )
        : _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      // Is opacity se background animation dikhega
      color: ProfessionalColors.cardDark.withOpacity(0.8), 
      child: Center(
        child: Icon(
          Icons.movie_creation_outlined,
          size: 50,
          color: ProfessionalColors.textSecondary.withOpacity(0.5),
        ),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}

//==============================================================================
// SECTION 5: BACKGROUND ANIMATION CLASSES
//==============================================================================

/// Ek single particle (dot) ka data model
class Particle {
  Offset position;
  Color color; // Main color for the dot
  double radius;
  double speed;
  double angle; // Direction in radians
  List<Color> gradientColors;
  double glowRadius;

  Particle({
    required this.position,
    required this.color,
    required this.radius,
    required this.speed,
    required this.angle,
    required this.gradientColors,
    required this.glowRadius,
  });
}

/// Custom Painter jo sabhi particles aur unke connections ko draw karta hai
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Paint _paint;
  final Paint _linePaint;
  final double maxConnectionDistance = 150.0;

  ParticlePainter({required this.particles})
      : _paint = Paint(),
        _linePaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    // Pehle connections draw karein
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final p1 = particles[i];
        final p2 = particles[j];

        final distance = (p1.position - p2.position).distance;

        if (distance < maxConnectionDistance) {
          final double opacity = 1.0 - (distance / maxConnectionDistance);

          // Lines ke liye Gradient Paint
          _linePaint.shader = LinearGradient(
            colors: [
              p1.gradientColors[0].withOpacity(opacity * 0.5),
              p2.gradientColors[1].withOpacity(opacity * 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromPoints(p1.position, p2.position));

          _linePaint.strokeWidth = 0.5 + (1.5 * (1 - (distance / maxConnectionDistance)));
          canvas.drawLine(p1.position, p2.position, _linePaint);
        }
      }
    }

    // Ab particles (dots) ko lines ke upar draw karein
    for (var p in particles) {
      // Glow effect ke liye RadialGradient
      _paint.shader = RadialGradient(
        colors: p.gradientColors,
        stops: const [0.0, 1.0],
        center: Alignment.center,
        radius: 1.0,
      ).createShader(
        Rect.fromCircle(center: p.position, radius: p.radius + p.glowRadius),
      );

      // Glow circle draw karein (main dot ke neeche)
      canvas.drawCircle(p.position, p.radius + p.glowRadius, _paint);

      // Main dot draw karein (glow ke upar)
      _paint.shader = null; // Shader reset
      _paint.color = p.color; // Main dot ka solid color
      canvas.drawCircle(p.position, p.radius, _paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}