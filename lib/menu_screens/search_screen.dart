// import 'dart:async';
// import 'dart:convert';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/sub_vod.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/webseries_screen/webseries_details_page.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/device_info_provider.dart';
// import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player.dart';
// import 'package:mobi_tv_entertainment/video_widget/youtube_webview_player.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../home_screen_pages/religious_channel/religious_channel_details_page.dart';
// import '../home_screen_pages/sports_category/tv_show_final_details_page.dart';
// import '../home_screen_pages/tv_show/tv_show_final_details_page.dart';
// import '../home_screen_pages/tv_show_pak/tv_show_final_details_page.dart';
// import '../main.dart';
// import '../provider/focus_provider.dart';
// import '../video_widget/socket_service.dart';
// import '../video_widget/video_screen.dart';
// import '../widgets/models/news_item_model.dart';
// import '../widgets/utils/color_service.dart';

// // Future<List<NewsItemModel>> fetchFromApi(String searchTerm) async {
// //   try {
// //     // Get auth key from AuthManager
// //     String authKey = AuthManager.authKey;

// //     if (authKey.isEmpty) {
// //       throw Exception('Authentication key is missing');
// //     }

// //     final response = await https.get(
// //       Uri.parse(
// //           'https://dashboard.cpplayers.com/api/v2/searchContent/${searchTerm}/0'),
// //       headers: {
// //         'auth-key': authKey,
// //         'Accept': 'application/json',
// //         'Content-Type': 'application/json',
// //         'domain': 'coretechinfo.com'
// //       },
// //     );

// //     if (response.statusCode == 200) {
// //       // Check if response is valid JSON
// //       String responseBody = response.body.trim();
// //       if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
// //         final dynamic responseData = json.decode(responseBody);

// //         // Handle both array and object responses
// //         List<dynamic> dataList;
// //         if (responseData is List) {
// //           dataList = responseData;
// //         } else if (responseData is Map && responseData['data'] is List) {
// //           dataList = responseData['data'];
// //         } else if (responseData is Map && responseData['results'] is List) {
// //           dataList = responseData['results'];
// //         } else {
// //           throw Exception('Unexpected response format');
// //         }

// //         // Log first item details for debugging
// //         if (dataList.isNotEmpty) {}

// //         // Apply filtering logic
// //         List<dynamic> filteredList;
// //         if (settings['tvenableAll'] == 0) {
// //           final enabledChannels =
// //               settings['channels']?.map((id) => id.toString()).toSet() ?? {};

// //           filteredList = dataList
// //               .where((channel) =>
// //                   channel['name'] != null &&
// //                   channel['name']
// //                       .toString()
// //                       .toLowerCase()
// //                       .contains(searchTerm.toLowerCase()) &&
// //                   enabledChannels.contains(channel['id'].toString()))
// //               .toList();
// //         } else {
// //           filteredList = dataList
// //               .where((channel) =>
// //                   channel['name'] != null &&
// //                   channel['name']
// //                       .toString()
// //                       .toLowerCase()
// //                       .contains(searchTerm.toLowerCase()))
// //               .toList();
// //         }

// //         // Convert to NewsItemModel and log
// //         List<NewsItemModel> newsItems = [];
// //         for (int i = 0; i < filteredList.length; i++) {
// //           try {
// //             // Fix the data types before parsing
// //             Map<String, dynamic> itemData =
// //                 Map<String, dynamic>.from(filteredList[i]);

// //             // Convert integer fields to strings if needed
// //             if (itemData['id'] != null) {
// //               itemData['id'] = itemData['id'].toString();
// //             }
// //             if (itemData['status'] != null) {
// //               itemData['status'] = itemData['status'].toString();
// //             }

// //             // Fix banner URL if it's relative
// //             if (itemData['banner'] != null &&
// //                 !itemData['banner'].toString().startsWith('http')) {
// //               String bannerPath = itemData['banner'].toString();
// //               // Add base URL for relative paths
// //               itemData['banner'] =
// //                   'https://dashboard.cpplayers.com/public/$bannerPath';
// //             }

// //             NewsItemModel item = NewsItemModel.fromJson(itemData);
// //             newsItems.add(item);
// //           } catch (e) {}
// //         }

// //         return newsItems;
// //       } else {
// //         throw Exception('Invalid response format');
// //       }
// //     } else if (response.statusCode == 401 || response.statusCode == 403) {
// //       throw Exception('Authentication failed. Please login again.');
// //     } else {
// //       throw Exception('Failed to load data from API: ${response.statusCode}');
// //     }
// //   } catch (e) {
// //     // If it's an authentication error, you might want to handle it specially
// //     if (e.toString().contains('Authentication')) {
// //       rethrow; // Re-throw auth errors so UI can handle them
// //     }

// //     return [];
// //   }
// // }

// import 'dart:convert'; // Make sure this import is at the top of your file
// import 'package:http/http.dart' as https;

// // ... (your other imports)

// Future<List<NewsItemModel>> fetchFromApi(String searchTerm) async {
//   try {
//     // Get auth key from AuthManager
//     String authKey = AuthManager.authKey;

//     if (authKey.isEmpty) {
//       throw Exception('Authentication key is missing');
//     }

//     // 1. API URL ko naye endpoint par change karein
//     final url = Uri.parse('https://dashboard.cpplayers.com/api/v2/getSearchCategoryList');

//     // 2. Request body banayein jismein keywords ho
//     final body = json.encode({
//       'keywords': searchTerm,
//     });

//     // 3. https.get ko https.post se replace karein aur body ko pass karein
//     final response = await https.post(
//       url,
//       headers: {
//         'auth-key': authKey,
//         'Accept': 'application/json',
//         'Content-Type': 'application/json', // Yeh POST request ke liye zaroori hai
//         'domain': 'coretechinfo.com'
//       },
//       body: body, // Body ko yahan add karein
//     );

//     if (response.statusCode == 200) {
//       // Check if response is valid JSON
//       String responseBody = response.body.trim();
//       if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
//         final dynamic responseData = json.decode(responseBody);

//         // Handle both array and object responses
//         List<dynamic> dataList;
//         if (responseData is List) {
//           dataList = responseData;
//         } else if (responseData is Map && responseData['data'] is List) {
//           dataList = responseData['data'];
//         } else if (responseData is Map && responseData['results'] is List) {
//           dataList = responseData['results'];
//         } else {
//           throw Exception('Unexpected response format');
//         }

//         // Log first item details for debugging
//         if (dataList.isNotEmpty) {}

//         // Apply filtering logic
//         List<dynamic> filteredList;
//         if (settings['tvenableAll'] == 0) {
//           final enabledChannels =
//               settings['channels']?.map((id) => id.toString()).toSet() ?? {};

//           filteredList = dataList
//               .where((channel) =>
//                   channel['name'] != null &&
//                   channel['name']
//                       .toString()
//                       .toLowerCase()
//                       .contains(searchTerm.toLowerCase()) &&
//                   enabledChannels.contains(channel['id'].toString()))
//               .toList();
//         } else {
//           filteredList = dataList
//               .where((channel) =>
//                   channel['name'] != null &&
//                   channel['name']
//                       .toString()
//                       .toLowerCase()
//                       .contains(searchTerm.toLowerCase()))
//               .toList();
//         }

//         // Convert to NewsItemModel and log
//         List<NewsItemModel> newsItems = [];
//         for (int i = 0; i < filteredList.length; i++) {
//           try {
//             // Fix the data types before parsing
//             Map<String, dynamic> itemData =
//                 Map<String, dynamic>.from(filteredList[i]);

//             // Convert integer fields to strings if needed
//             if (itemData['id'] != null) {
//               itemData['id'] = itemData['id'].toString();
//             }
//             if (itemData['status'] != null) {
//               itemData['status'] = itemData['status'].toString();
//             }

//             // Fix banner URL if it's relative
//             if (itemData['banner'] != null &&
//                 !itemData['banner'].toString().startsWith('http')) {
//               String bannerPath = itemData['banner'].toString();
//               // Add base URL for relative paths
//               itemData['banner'] =
//                   'https://dashboard.cpplayers.com/public/$bannerPath';
//             }

//             NewsItemModel item = NewsItemModel.fromJson(itemData);
//             newsItems.add(item);
//           } catch (e) {}
//         }

//         return newsItems;
//       } else {
//         throw Exception('Invalid response format');
//       }
//     } else if (response.statusCode == 401 || response.statusCode == 403) {
//       throw Exception('Authentication failed. Please login again.');
//     } else {
//       throw Exception('Failed to load data from API: ${response.statusCode}');
//     }
//   } catch (e) {
//     // If it's an authentication error, you might want to handle it specially
//     if (e.toString().contains('Authentication')) {
//       rethrow; // Re-throw auth errors so UI can handle them
//     }

//     return [];
//   }
// }

// Uint8List _getImageFromBase64String(String base64String) {
//   try {
//     // Split the base64 string to remove metadata if present
//     String cleanBase64 = base64String.split(',').last;

//     Uint8List result = base64Decode(cleanBase64);
//     return result;
//   } catch (e) {
//     rethrow;
//   }
// }

// Map<String, dynamic> settings = {};

// Future<void> fetchSettings() async {
//   try {
//     // Use auth key for settings API as well
//     String authKey = AuthManager.authKey;

//     final response = await https.get(
//       Uri.parse('https://dashboard.cpplayers.com/public/api/getSettings'),
//       headers: {
//         'auth-key': authKey,
//         'Accept': 'application/json',
//         'Content-Type': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       settings = json.decode(response.body);
//     } else {
//       // Fallback to old API if new one fails
//       final fallbackResponse = await https.get(
//         Uri.parse('https://api.ekomflix.com/android/getSettings'),
//         headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
//       );

//       if (fallbackResponse.statusCode == 200) {
//         settings = json.decode(fallbackResponse.body);
//       } else {
//         throw Exception('Failed to load settings from both APIs');
//       }
//     }
//   } catch (e) {
//     // Set default settings to prevent crashes
//     settings = {
//       'tvenableAll': 1,
//       'channels': [],
//     };
//   }
// }

// class SearchScreen extends StatefulWidget {
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   List<NewsItemModel> searchResults = [];
//   bool isLoading = false;
//   TextEditingController _searchController = TextEditingController();
//   int selectedIndex = -1;
//   final FocusNode _searchFieldFocusNode = FocusNode();
//   final FocusNode _searchIconFocusNode = FocusNode();
//   Timer? _debounce;
//   final List<FocusNode> _itemFocusNodes = [];
//   bool _isNavigating = false;
//   bool _showSearchField = false;
//   Color paletteColor = Colors.grey;
//   final PaletteColorService _paletteColorService = PaletteColorService();
//   final SocketService _socketService = SocketService();
//   final int _maxRetries = 3;
//   final int _retryDelay = 5;
//   bool _shouldContinueLoading = true;
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _searchFieldFocusNode.addListener(_onSearchFieldFocusChanged);
//     _searchIconFocusNode.addListener(_onSearchIconFocusChanged);
//     _socketService.initSocket();
//     checkServerStatus();

//     // Initialize settings
//     fetchSettings();

//     // Ensure auth key is available
//     // _ensureAuthKey();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context
//           .read<FocusProvider>()
//           .setSearchIconFocusNode(_searchIconFocusNode);
//     });
//   }

//   // Future<void> _ensureAuthKey() async {
//   //   await AuthManager.initialize();
//   //   if (!AuthManager.hasValidAuthKey) {
//   //     setState(() {
//   //       _errorMessage = 'Authentication required. Please login again.';
//   //     });
//   //   } else {}
//   // }

//   @override
//   void dispose() {
//     _searchFieldFocusNode.removeListener(_onSearchFieldFocusChanged);
//     _searchIconFocusNode.removeListener(_onSearchIconFocusChanged);
//     _searchFieldFocusNode.dispose();
//     _searchIconFocusNode.dispose();
//     _searchController.dispose();
//     _debounce?.cancel();
//     _itemFocusNodes.forEach((node) => node.dispose());
//     _socketService.dispose();
//     super.dispose();
//   }

//   Future<void> _updateChannelUrlIfNeeded(
//       List<NewsItemModel> result, int index) async {
//     if (result[index].streamType == 'YoutubeLive' ||
//         result[index].streamType == 'Youtube') {
//       for (int i = 0; i < _maxRetries; i++) {
//         if (!_shouldContinueLoading) break;
//         try {
//           String updatedUrl =
//               await _socketService.getUpdatedUrl(result[index].url);
//           setState(() {
//             result[index] =
//                 result[index].copyWith(url: updatedUrl, streamType: 'M3u8');
//           });
//           break;
//         } catch (e) {
//           if (i == _maxRetries - 1) rethrow;
//           await Future.delayed(Duration(seconds: _retryDelay));
//         }
//       }
//     }
//   }

//   Future<void> _onItemTap(BuildContext context, int index) async {
//     if (_isNavigating) return;
//     _isNavigating = true;
//     _showLoadingIndicator(context);

//     try {
//       // await _updateChannelUrlIfNeeded(searchResults, index);
//       if (_shouldContinueLoading) {
//         await _navigateToVideoScreen(context, searchResults, index);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Something Went Wrong')),
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
//             return Future.value(false);
//           },
//           child: Center(
//             child: SpinKitFadingCircle(
//               color: Colors.white,
//               size: 50.0,
//             ),
//           ),
//         );
//       },
//     );
//   }

// Future<void> _navigateToVideoScreen(
//     BuildContext context, List<NewsItemModel> channels, int index) async {
//   if (index < 0 || index >= channels.length) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Invalid channel index')),
//     );
//     return;
//   }

//   final channel = channels[index];
//   final int? parsedContentType = int.tryParse(channel.contentType);

//   // --- SOLUTION START ---
//   // Step 1: Pehle un content types ko handle karein jinhe details page chahiye.
//   // Inko video URL ki zaroorat nahi hai.
//   try {
//     if (parsedContentType == 2) { // WebSeries
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => WebSeriesDetailsPage(
//             id: int.tryParse(channel.id) ?? 0,
//             banner: channel.banner,
//             poster: channel.poster,
//             logo: channel.banner,
//             name: channel.name,
//           ),
//         ),
//       );
//       return; // Navigate hone ke baad function se bahar nikal jayein
//     } else if (parsedContentType == 4) { // TV Show
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => TvShowFinalDetailsPage(
//             id: int.tryParse(channel.id) ?? 0,
//             banner: channel.banner,
//             poster: channel.poster,
//             name: channel.name,
//           ),
//         ),
//       );
//       return; // Navigate hone ke baad function se bahar nikal jayein
//     } else if (parsedContentType == 5) { // TV Show Pak
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => TvShowPakFinalDetailsPage(
//             id: int.tryParse(channel.id) ?? 0,
//             banner: channel.banner,
//             poster: channel.poster,
//             name: channel.name,
//           ),
//         ),
//       );
//       return; // Navigate hone ke baad function se bahar nikal jayein
//     } else if (parsedContentType == 7) { // Religious Channel
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ReligiousChannelDetailsPage(
//             id: int.tryParse(channel.id) ?? 0,
//             banner: channel.banner,
//             poster: channel.poster,
//             name: channel.name,
//           ),
//         ),
//       );
//       return; // Navigate hone ke baad function se bahar nikal jayein
//     } else if (parsedContentType == 8) { // Tournament
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => TournamentFinalDetailsPage(
//             id: int.tryParse(channel.id) ?? 0,
//             banner: channel.banner,
//             poster: channel.poster,
//             name: channel.name,
//           ),
//         ),
//       );
//       return; // Navigate hone ke baad function se bahar nikal jayein
//     }
//   } catch (e) {
//     // Error handling zaroor karein
//     print('Navigation Error for Details Page: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Could not open details page.')),
//     );
//     return;
//   }
//   // --- SOLUTION END ---

//   // Step 2: Ab video URL aur streamType ki jaanch karein.
//   final String? videoUrl = channel.url;
//   final String? streamType = channel.streamType;

//   if (videoUrl == null || videoUrl.isEmpty || streamType == null) {
//     // Agar upar koi type match nahi hua aur yahan URL bhi nahi hai, to kuch na karein.
//     return;
//   }

//   // Step 3: Ab bache hue content types (jaise type 1) ko handle karein.
//   try {
//     if (parsedContentType == 1) { // Live Channel / Video
//       if (channel.sourceType == 'YoutubeLive' || channel.sourceType == 'youtube') {
//         final deviceInfo = context.read<DeviceInfoProvider>();
//         if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => YoutubeWebviewPlayer(
//                 videoUrl: channel.url,
//                 name: channel.name,
//               ),
//             ),
//           );
//         } else {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => CustomYoutubePlayer(
//                 videoData: VideoData(
//                   id: channel.id,
//                   title: channel.name,
//                   youtubeUrl: channel.url,
//                   thumbnail: channel.banner ?? channel.poster ?? '',
//                   description: channel.description ?? '',
//                 ),
//                 playlist: [
//                   VideoData(
//                     id: channel.id,
//                     title: channel.name,
//                     youtubeUrl: channel.url,
//                     thumbnail: channel.banner ?? channel.poster ?? '',
//                     description: channel.description ?? '',
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//       } else {
//         // Handle other stream types for contentType 1 if any (e.g., M3u8)
//         // await Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(...)));
//       }
//     }
//   } catch (e) {
//     print('Navigation Error for Video Player: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Could not play the video.')),
//     );
//   }
// }

//   void _dismissLoadingIndicator() {
//     if (Navigator.of(context).canPop()) {
//       Navigator.of(context).pop();
//     }
//   }

//   void checkServerStatus() {
//     int retryCount = 0;
//     Timer.periodic(Duration(seconds: 10), (timer) {
//       if (!_socketService.socket!.connected && retryCount < _maxRetries) {
//         retryCount++;
//         _socketService.initSocket();
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   void _onSearchFieldFocusChanged() {
//     setState(() {});
//   }

//   void _onSearchIconFocusChanged() {
//     setState(() {});
//   }

//   void _performSearch(String searchTerm) {
//     if (_debounce?.isActive ?? false) _debounce?.cancel();

//     if (searchTerm.trim().isEmpty) {
//       setState(() {
//         isLoading = false;
//         searchResults.clear();
//         _itemFocusNodes.clear();
//         _errorMessage = '';
//       });
//       return;
//     }

//     // // Check if auth key is available before searching
//     // if (!AuthManager.hasValidAuthKey) {
//     //   setState(() {
//     //     _errorMessage = 'Authentication required. Please login again.';
//     //     isLoading = false;
//     //     searchResults.clear();
//     //     _itemFocusNodes.clear();
//     //   });
//     //   return;
//     // }

//     _debounce = Timer(const Duration(milliseconds: 300), () async {
//       if (!mounted) return;
//       setState(() {
//         isLoading = true;
//         searchResults.clear();
//         _itemFocusNodes.clear();
//         _errorMessage = '';
//       });

//       try {
//         final api1Results = await fetchFromApi(searchTerm);
//         if (!mounted) return;
//         setState(() {
//           searchResults = api1Results;
//           _itemFocusNodes.addAll(
//               List.generate(searchResults.length, (index) => FocusNode()));
//           isLoading = false;
//         });

//         await _preloadImages(searchResults);

//         if (!mounted) return;
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (_itemFocusNodes.isNotEmpty &&
//               _itemFocusNodes[0].context != null &&
//               mounted) {
//             FocusScope.of(context).requestFocus(_itemFocusNodes[0]);
//           }
//         });
//       } catch (e) {
//         if (!mounted) return;
//         setState(() {
//           isLoading = false;
//           _errorMessage = e.toString().contains('Authentication')
//               ? 'Authentication failed. Please login again.'
//               : 'Search failed. Please try again.';
//         });
//       }
//     });
//   }

//   Future<void> _preloadImages(List<NewsItemModel> results) async {
//     for (int i = 0; i < results.length; i++) {
//       final result = results[i];
//       final imageUrl = result.banner;

//       if (imageUrl.isNotEmpty && !imageUrl.startsWith('data:image')) {
//         try {
//           await precacheImage(CachedNetworkImageProvider(imageUrl), context);
//         } catch (e) {}
//       } else if (imageUrl.startsWith('data:image')) {
//       } else {}
//     }
//   }

//   Future<void> _updatePaletteColor(String imageUrl, bool isFocused) async {
//     try {
//       Color color = await _paletteColorService.getSecondaryColor(imageUrl);
//       if (!mounted) return;

//       setState(() {
//         paletteColor = color;
//       });

//       // Update the provider with both color and focus state
//       Provider.of<ColorProvider>(context, listen: false)
//           .updateColor(color, isFocused);
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         paletteColor = Colors.grey;
//       });

//       // Update with grey color in case of error
//       Provider.of<ColorProvider>(context, listen: false)
//           .updateColor(Colors.grey, isFocused);
//     }
//   }

//   void _toggleSearchField() {
//     setState(() {
//       _showSearchField = !_showSearchField;
//       if (_showSearchField) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _searchFieldFocusNode.requestFocus();
//         });
//       } else {
//         _searchIconFocusNode.requestFocus();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//         canPop: false, // Back button se page pop nahi hoga
//         onPopInvoked: (didPop) {
//           if (!didPop) {
//             // Back button dabane par ye function call hoga
//             context.read<FocusProvider>().requestWatchNowFocus();
//           }
//         },
//         child:
//             Consumer<ColorProvider>(builder: (context, colorProvider, child) {
//           // Get background color based on provider state
//           Color backgroundColor = colorProvider.isItemFocused
//               ? colorProvider.dominantColor
//               : cardColor;
//           return Scaffold(
//             backgroundColor: backgroundColor,
//             body: Container(
//               color: Colors.black54,
//               child: Column(
//                 children: [
//                   _buildSearchBar(),
//                   Expanded(
//                     child: _errorMessage.isNotEmpty
//                         ? Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.error_outline,
//                                   color: Colors.red,
//                                   size: 60,
//                                 ),
//                                 SizedBox(height: 20),
//                                 Text(
//                                   _errorMessage,
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                                 if (_errorMessage.contains('Authentication'))
//                                   Padding(
//                                     padding: EdgeInsets.only(top: 20),
//                                     child: ElevatedButton(
//                                       onPressed: () {
//                                         Navigator.pushNamedAndRemoveUntil(
//                                           context,
//                                           '/login',
//                                           (route) => false,
//                                         );
//                                       },
//                                       child: Text('Go to Login'),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           )
//                         : isLoading
//                             ? Center(
//                                 child: SpinKitFadingCircle(
//                                   color: borderColor,
//                                   size: 50.0,
//                                 ),
//                               )
//                             : searchResults.isEmpty
//                                 ? Center(
//                                     child: Text(
//                                       'No results found',
//                                       style: TextStyle(color: Colors.white),
//                                     ),
//                                   )
//                                 : Padding(
//                                     padding: EdgeInsets.symmetric(
//                                         horizontal: screenwdt * 0.03),
//                                     child: GridView.builder(
//                                       gridDelegate:
//                                           const SliverGridDelegateWithFixedCrossAxisCount(
//                                         crossAxisCount: 5,
//                                       ),
//                                       itemCount: searchResults.length,
//                                       itemBuilder: (context, index) {
//                                         return GestureDetector(
//                                           onTap: () =>
//                                               _onItemTap(context, index),
//                                           child: _buildGridViewItem(
//                                               context, index),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }));
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       width: screenwdt * 0.93,
//       padding: EdgeInsets.only(top: screenhgt * 0.02),
//       height: screenhgt * 0.1,
//       child: Row(
//         children: [
//           if (!_showSearchField) Expanded(child: Text('')),
//           if (_showSearchField)
//             Expanded(
//               child: TextField(
//                 controller: _searchController,
//                 focusNode: _searchFieldFocusNode,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                     borderSide: BorderSide(color: Colors.grey, width: 4.0),
//                   ),
//                   labelText: 'Search By Name',
//                   labelStyle: TextStyle(color: Colors.white),
//                 ),
//                 style: TextStyle(color: Colors.white),
//                 textInputAction: TextInputAction.search,
//                 textAlignVertical: TextAlignVertical.center,
//                 onChanged: (value) {
//                   _performSearch(value);
//                 },
//                 onSubmitted: (value) {
//                   _performSearch(value);
//                   _toggleSearchField();
//                 },
//                 autofocus: true,
//               ),
//             ),
//           Focus(
//             focusNode: _searchIconFocusNode,
//             onKey: (node, event) {
//               if (event is RawKeyDownEvent &&
//                   event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                 context.read<FocusProvider>().requestSearchNavigationFocus();
//                 return KeyEventResult.handled;
//               } else if (event is RawKeyDownEvent &&
//                   event.logicalKey == LogicalKeyboardKey.select) {
//                 _toggleSearchField();
//                 return KeyEventResult.handled;
//               }
//               return KeyEventResult.ignored;
//             },
//             child: IconButton(
//               icon: Icon(
//                 Icons.search,
//                 color:
//                     _searchIconFocusNode.hasFocus ? borderColor : Colors.white,
//                 size: _searchIconFocusNode.hasFocus ? 35 : 30,
//               ),
//               onPressed: _toggleSearchField,
//               focusColor: Colors.transparent,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGridViewItem(BuildContext context, int index) {
//     final result = searchResults[index];
//     final status = result.status;
//     final bool isBase64 = result.banner.startsWith('data:image');
//     final colorProvider = Provider.of<ColorProvider>(context, listen: false);

//     return Focus(
//       focusNode: _itemFocusNodes[index],
//       onFocusChange: (hasFocus) async {
//         if (hasFocus) {
//           // Update palette color with focus state
//           await _updatePaletteColor(result.banner, true);
//         } else {
//           // Reset color when focus is lost
//           colorProvider.resetColor();
//         }

//         setState(() {
//           selectedIndex = hasFocus ? index : -1;
//         });
//       },
//       onKeyEvent: (FocusNode node, KeyEvent event) {
//         if (event is KeyDownEvent &&
//             event.logicalKey == LogicalKeyboardKey.select) {
//           _onItemTap(context, index);
//           return KeyEventResult.handled;
//         }
//         return KeyEventResult.ignored;
//       },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           AnimatedContainer(
//             width: screenwdt * 0.19,
//             height: screenhgt * 0.2,
//             duration: const Duration(milliseconds: 300),
//             decoration: BoxDecoration(
//               border: selectedIndex == index
//                   ? Border.all(
//                       color: paletteColor,
//                       width: 3.0,
//                     )
//                   : Border.all(
//                       color: Colors.transparent,
//                       width: 3.0,
//                     ),
//               boxShadow: selectedIndex == index
//                   ? [
//                       BoxShadow(
//                         color: paletteColor,
//                         blurRadius: 25,
//                         spreadRadius: 10,
//                       )
//                     ]
//                   : [],
//             ),
//             child: () {
//               if (status != '1') {
//                 return Container(
//                   width: screenwdt * 0.19,
//                   height: screenhgt * 0.2,
//                   color: Colors.grey[800],
//                   child: Center(
//                     child: Text(
//                       '',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.white, fontSize: 12),
//                     ),
//                   ),
//                 );
//               }

//               return ClipRRect(
//                 child: () {
//                   if (isBase64) {
//                     try {
//                       final imageBytes =
//                           _getImageFromBase64String(result.banner);
//                       return Image.memory(
//                         imageBytes,
//                         width: screenwdt * 0.19,
//                         height: screenhgt * 0.2,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Container(
//                             width: screenwdt * 0.19,
//                             height: screenhgt * 0.2,
//                             color: Colors.red[300],
//                             child: Center(
//                               child: Text(
//                                 'Base64\nError',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                     color: Colors.white, fontSize: 10),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     } catch (e) {
//                       return Container(
//                         width: screenwdt * 0.19,
//                         height: screenhgt * 0.2,
//                         color: Colors.red[300],
//                         child: Center(
//                           child: Text(
//                             'Base64\nDecode Error',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(color: Colors.white, fontSize: 10),
//                           ),
//                         ),
//                       );
//                     }
//                   } else {
//                     return CachedNetworkImage(
//                       imageUrl: result.banner,
//                       width: screenwdt * 0.19,
//                       height: screenhgt * 0.2,
//                       fit: BoxFit.cover,
//                       placeholder: (context, url) {
//                         return Container(
//                           width: screenwdt * 0.19,
//                           height: screenhgt * 0.2,
//                           color: Colors.grey[700],
//                           child: Center(
//                             child: CircularProgressIndicator(
//                               valueColor:
//                                   AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           ),
//                         );
//                       },
//                       errorWidget: (context, url, error) {
//                         return Image.asset(localImage);
//                         // Container(
//                         //   width: screenwdt * 0.19,
//                         //   height: screenhgt * 0.2,
//                         //   color: Colors.orange[300],
//                         //   child: Center(
//                         //     child: Column(
//                         //       mainAxisAlignment: MainAxisAlignment.center,
//                         //       children: [
//                         //         Icon(Icons.error, color: Colors.white, size: 20),
//                         //         Text(
//                         //           '',
//                         //           textAlign: TextAlign.center,
//                         //           style: TextStyle(color: Colors.white, fontSize: 10),
//                         //         ),
//                         //       ],
//                         //     ),
//                         //   ),
//                         // );
//                       },
//                     );
//                   }
//                 }(),
//               );
//             }(),
//           ),
//           Container(
//             width: MediaQuery.of(context).size.width * 0.15,
//             child: Text(
//               result.name.toUpperCase(),
//               style: TextStyle(
//                 fontSize: 15,
//                 color: selectedIndex == index ? paletteColor : Colors.white,
//               ),
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:convert';
// import 'dart:math' as math;
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/home_screen_pages/webseries_screen/webseries_details_page.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/device_info_provider.dart';
// import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player.dart';
// import 'package:mobi_tv_entertainment/video_widget/youtube_webview_player.dart';
// import 'package:provider/provider.dart';
// import '../home_screen_pages/religious_channel/religious_channel_details_page.dart';
// import '../home_screen_pages/sports_category/tv_show_final_details_page.dart';
// import '../home_screen_pages/tv_show/tv_show_final_details_page.dart';
// import '../home_screen_pages/tv_show_pak/tv_show_final_details_page.dart';
// import '../main.dart';
// import '../provider/focus_provider.dart';
// import '../video_widget/socket_service.dart';
// import '../widgets/models/news_item_model.dart';
// import '../widgets/utils/color_service.dart';

// // VOD Styling Classes
// class ProfessionalVODColors {
//   static const primaryDark = Color(0xFF0A0E1A);
//   static const surfaceDark = Color(0xFF1A1D29);
//   static const accentBlue = Color(0xFF3B82F6);
//   static const accentPurple = Color(0xFF8B5CF6);
//   static const accentGreen = Color(0xFF10B981);
//   static const accentRed = Color(0xFFEF4444);
// }

// class VODAnimationTiming {
//   static const Duration focus = Duration(milliseconds: 700);
// }

// // API and Helper Functions
// Future<List<NewsItemModel>> fetchFromApi(String searchTerm) async {
//   try {
//     String authKey = AuthManager.authKey;
//     if (authKey.isEmpty) {
//       throw Exception('Authentication key is missing');
//     }

//     final url = Uri.parse(
//         'https://dashboard.cpplayers.com/api/v2/getSearchCategoryList');
//     final body = json.encode({'keywords': searchTerm});

//     final response = await https.post(
//       url,
//       headers: {
//         'auth-key': authKey,
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
//             Map<String, dynamic> itemData =
//                 Map<String, dynamic>.from(itemDataRaw);
//             if (itemData['id'] != null)
//               itemData['id'] = itemData['id'].toString();
//             if (itemData['status'] != null)
//               itemData['status'] = itemData['status'].toString();

//             if (itemData['banner'] != null &&
//                 !itemData['banner'].toString().startsWith('http')) {
//               String bannerPath = itemData['banner'].toString();
//               itemData['banner'] =
//                   'https://dashboard.cpplayers.com/public/$bannerPath';
//             }
//             newsItems.add(NewsItemModel.fromJson(itemData));
//           } catch (e) {
//             // Skip item if parsing fails
//           }
//         }
//         return newsItems;
//       } else {
//         throw Exception('Invalid response format');
//       }
//     } else if (response.statusCode == 401 || response.statusCode == 403) {
//       throw Exception('Authentication failed. Please login again.');
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

// class _SearchScreenState extends State<SearchScreen> {
//   List<NewsItemModel> searchResults = [];
//   bool isLoading = false;
//   final TextEditingController _searchController = TextEditingController();
//   final FocusNode _searchFieldFocusNode = FocusNode();
//   final FocusNode _searchIconFocusNode = FocusNode();
//   Timer? _debounce;
//   final List<FocusNode> _itemFocusNodes = [];
//   bool _isNavigating = false;
//   bool _showSearchField = false;
//   final PaletteColorService _paletteColorService = PaletteColorService();
//   bool _shouldContinueLoading = true;
//   String _errorMessage = '';

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
//     _searchFieldFocusNode.dispose();
//     _searchIconFocusNode.dispose();
//     _searchController.dispose();
//     _debounce?.cancel();
//     _itemFocusNodes.forEach((node) => node.dispose());
//     super.dispose();
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
//         const SnackBar(content: Text('Something Went Wrong')),
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
//     if (index < 0 || index >= channels.length) return;

//     final channel = channels[index];
//     final int? parsedContentType = int.tryParse(channel.contentType);
//     final int channelId = int.tryParse(channel.id) ?? 0;

//     debugPrint(
//         'Navigating to: ${channel.name}, ContentType: ${channel.contentType}, ParsedType: $parsedContentType, URL: ${channel.url}');

//     try {
//       Widget? targetPage;
//       if (parsedContentType == 2) {
//         targetPage = WebSeriesDetailsPage(
//             id: channelId,
//             banner: channel.banner,
//             poster: channel.poster,
//             logo: channel.banner,
//             name: channel.name);
//       } else if (parsedContentType == 4) {
//         targetPage = TvShowFinalDetailsPage(
//             id: channelId,
//             banner: channel.banner,
//             poster: channel.poster,
//             name: channel.name);
//       } else if (parsedContentType == 5) {
//         targetPage = TvShowPakFinalDetailsPage(
//             id: channelId,
//             banner: channel.banner,
//             poster: channel.poster,
//             name: channel.name);
//       } else if (parsedContentType == 7) {
//         targetPage = ReligiousChannelDetailsPage(
//             id: channelId,
//             banner: channel.banner,
//             poster: channel.poster,
//             name: channel.name);
//       } else if (parsedContentType == 8) {
//         targetPage = TournamentFinalDetailsPage(
//             id: channelId,
//             banner: channel.banner,
//             poster: channel.poster,
//             name: channel.name);
//       }

//       if (targetPage != null) {
//         await Navigator.push(
//             context, MaterialPageRoute(builder: (context) => targetPage!));
//         return;
//       }

//       final String? videoUrl = channel.url;
//       if (videoUrl == null || videoUrl.isEmpty) {
//         debugPrint(
//             'Navigation failed: No target page for contentType $parsedContentType and video URL is null.');
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Cannot play this content.')));
//         return;
//       }

//       if (parsedContentType == 1) {
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
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => CustomYoutubePlayer(
//                           videoData: VideoData(
//                               // id: channel.id,
//                               id: channel.url,
//                               title: channel.name,
//                               youtubeUrl: channel.url,
//                               thumbnail: channel.banner ?? channel.poster ?? '',
//                               description: channel.description ?? ''),
//                           playlist: [
//                             VideoData(
//                                 // id: channel.id,
//                                 id: channel.url,
//                                 title: channel.name,
//                                 youtubeUrl: channel.url,
//                                 thumbnail:
//                                     channel.banner ?? channel.poster ?? '',
//                                 description: channel.description ?? '')
//                           ],
//                         )));
//           }
//         }
//       } else {
//         debugPrint(
//             'Navigation failed: Unhandled contentType $parsedContentType.');
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//             content: Text('This content type is not supported.')));
//       }
//     } catch (e) {
//       debugPrint('Navigation Error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Error opening content.')));
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

//   Future<void> _updatePaletteColor(String imageUrl, bool isFocused) async {
//     try {
//       Color color = await _paletteColorService.getSecondaryColor(imageUrl);
//       if (mounted) {
//         Provider.of<ColorProvider>(context, listen: false)
//             .updateColor(color, isFocused);
//       }
//     } catch (e) {
//       if (mounted) {
//         Provider.of<ColorProvider>(context, listen: false)
//             .updateColor(Colors.grey, isFocused);
//       }
//     }
//   }

//   void _toggleSearchField() {
//     setState(() {
//       _showSearchField = !_showSearchField;
//       if (_showSearchField) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _searchFieldFocusNode.requestFocus();
//         });
//       } else {
//         _searchIconFocusNode.requestFocus();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         if (!didPop) {
//           context.read<FocusProvider>().requestWatchNowFocus();
//         }
//       },
//       child: Consumer<ColorProvider>(builder: (context, colorProvider, child) {
//         final bgColor = colorProvider.isItemFocused
//             ? colorProvider.dominantColor.withOpacity(0.1)
//             : ProfessionalVODColors.primaryDark;

//         return Scaffold(
//           backgroundColor: Colors.transparent,
//           body: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [bgColor, ProfessionalVODColors.primaryDark],
//               ),
//             ),
//             child: Column(
//               children: [
//                 _buildSearchBar(),
//                 Expanded(child: _buildBody()),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
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
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 400),
//             width: _showSearchField ? screenwdt * 0.4 : 50,
//             child: Row(
//               children: [
//                 if (_showSearchField)
//                   Expanded(
//                     child: TextField(
//                       controller: _searchController,
//                       focusNode: _searchFieldFocusNode,
//                       decoration: InputDecoration(
//                         hintText: 'Search content...',
//                         hintStyle:
//                             TextStyle(color: Colors.white.withOpacity(0.5)),
//                         border: InputBorder.none,
//                         focusedBorder: InputBorder.none,
//                       ),
//                       style: const TextStyle(color: Colors.white, fontSize: 16),
//                       onChanged: _performSearch,
//                       onSubmitted: (value) {
//                         if (value.trim().isEmpty) _toggleSearchField();
//                       },
//                     ),
//                   ),
//                 Focus(
//                   focusNode: _searchIconFocusNode,
//                   onKey: (node, event) {
//                     if (event is RawKeyDownEvent) {
//                       if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                         context
//                             .read<FocusProvider>()
//                             .requestSearchNavigationFocus();
//                         return KeyEventResult.handled;
//                       }
//                       if (event.logicalKey == LogicalKeyboardKey.select ||
//                           event.logicalKey == LogicalKeyboardKey.enter) {
//                         _toggleSearchField();
//                         return KeyEventResult.handled;
//                       }
//                     }
//                     return KeyEventResult.ignored;
//                   },
//                   child: GestureDetector(
//                     onTap: _toggleSearchField,
//                     child: Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: _searchIconFocusNode.hasFocus
//                             ? ProfessionalVODColors.accentPurple
//                             : Colors.white.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       child: Icon(
//                         Icons.search,
//                         color: Colors.white,
//                         size: _searchIconFocusNode.hasFocus ? 28 : 24,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

// //   Widget _buildBody() {
// //     if (_errorMessage.isNotEmpty) {
// //       return Center(
// //         child: Text(_errorMessage, style: const TextStyle(color: Colors.white)),
// //       );
// //     }
// //     if (isLoading) {
// //       return const Center(
// //           child: SpinKitFadingCircle(color: Colors.white, size: 50.0));
// //     }
// //     if (searchResults.isEmpty && _searchController.text.isNotEmpty) {
// //       return const Center(
// //           child:
// //               Text('No results found', style: TextStyle(color: Colors.white)));
// //     }
// //     return Padding(
// //       padding: EdgeInsets.symmetric(
// //           horizontal: screenwdt * 0.05, vertical: screenhgt * 0.02),
// //       child: GridView.builder(
// //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //           crossAxisCount: 5,
// //           mainAxisSpacing: 20,
// //           crossAxisSpacing: 20,
// //           childAspectRatio: 0.9,
// //         ),
// //         itemCount: searchResults.length,
// //         itemBuilder: (context, index) {
// //           final item = searchResults[index];
// //           return ProfessionalSearchCard(
// //             searchItem: item,
// //             focusNode: _itemFocusNodes[index],
// //             onTap: () => _onItemTap(context, index),
// //             onFocusChange: (imageUrl, isFocused) {
// //               _updatePaletteColor(imageUrl, isFocused);
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }

//   Widget _buildBody() {
//     if (_errorMessage.isNotEmpty) {
//       return Center(
//         child: Text(_errorMessage, style: const TextStyle(color: Colors.white)),
//       );
//     }
//     if (isLoading) {
//       return const Center(
//           child: SpinKitFadingCircle(color: Colors.white, size: 50.0));
//     }
//     if (searchResults.isEmpty && _searchController.text.isNotEmpty) {
//       return const Center(
//           child:
//               Text('No results found', style: TextStyle(color: Colors.white)));
//     }
//     return Padding(
//       padding: EdgeInsets.symmetric(
//           horizontal: screenwdt * 0.05, vertical: screenhgt * 0.02),
//       child: GridView.builder(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 6, // Changed from 5 to 6
//           mainAxisSpacing: 20,
//           crossAxisSpacing: 20,
//           childAspectRatio: 1.3,
//         ),
//         itemCount: searchResults.length,
//         itemBuilder: (context, index) {
//           final item = searchResults[index];
//           return ProfessionalSearchCard(
//             searchItem: item,
//             focusNode: _itemFocusNodes[index],
//             onTap: () => _onItemTap(context, index),
//             onFocusChange: (imageUrl, isFocused) {
//               _updatePaletteColor(imageUrl, isFocused);
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class ProfessionalSearchCard extends StatefulWidget {
//   final NewsItemModel searchItem;
//   final FocusNode? focusNode;
//   final VoidCallback onTap;
//   final Function(String, bool) onFocusChange;

//   const ProfessionalSearchCard({
//     Key? key,
//     required this.searchItem,
//     this.focusNode,
//     required this.onTap,
//     required this.onFocusChange,
//   }) : super(key: key);

//   @override
//   _ProfessionalSearchCardState createState() => _ProfessionalSearchCardState();
// }

// class _ProfessionalSearchCardState extends State<ProfessionalSearchCard>
//     with TickerProviderStateMixin {
//   late AnimationController _hoverController;
//   late Animation<double> _scaleAnimation;
//   bool _isFocused = false;
//   late FocusNode _effectiveFocusNode;
//   Color _dominantColor = ProfessionalVODColors.accentPurple;

//   @override
//   void initState() {
//     super.initState();
//     _effectiveFocusNode = widget.focusNode ?? FocusNode();
//     _hoverController =
//         AnimationController(duration: VODAnimationTiming.focus, vsync: this);
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
//         CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic));
//     _effectiveFocusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     if (!mounted) return;
//     setState(() => _isFocused = _effectiveFocusNode.hasFocus);
//     widget.onFocusChange(widget.searchItem.banner, _isFocused);
//     if (_isFocused) {
//       _hoverController.forward();
//       HapticFeedback.lightImpact();
//     } else {
//       _hoverController.reverse();
//     }
//   }

//   @override
//   void dispose() {
//     _hoverController.dispose();
//     _effectiveFocusNode.removeListener(_handleFocusChange);
//     if (widget.focusNode == null) _effectiveFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorProvider = Provider.of<ColorProvider>(context);
//     if (_isFocused) _dominantColor = colorProvider.dominantColor;

//     return Focus(
//       focusNode: _effectiveFocusNode,
//       onKey: (node, event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.select ||
//               event.logicalKey == LogicalKeyboardKey.enter) {
//             widget.onTap();
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: widget.onTap,
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
//                           color: _dominantColor.withOpacity(0.4),
//                           blurRadius: 20,
//                           offset: const Offset(0, 8))
//                     else
//                       BoxShadow(
//                           color: Colors.black.withOpacity(0.3),
//                           blurRadius: 8,
//                           offset: const Offset(0, 4)),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       _buildSearchItemImage(),
//                       if (_isFocused) _buildFocusBorder(_dominantColor),
//                       _buildGradientOverlay(),
//                       _buildSearchItemInfo(),
//                       if (_isFocused) _buildPlayButton(_dominantColor),
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

//   Widget _buildSearchItemImage() {
//     String imageUrl = widget.searchItem.banner;
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
//         errorWidget: (context, url, error) => Image.asset(localImage),
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

//   Widget _buildSearchItemInfo() {
//     return Positioned(
//       bottom: 12,
//       left: 12,
//       right: 12,
//       child: Text(
//         widget.searchItem.name.toUpperCase(),
//         style: TextStyle(
//           color: _isFocused ? _dominantColor : Colors.white,
//           fontSize: _isFocused ? 13 : 12,
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

// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/home_screen_pages/webseries_screen/webseries_details_page.dart';
// // ✅ CHANGE: ColorProvider की अब ज़रूरत नहीं है, इसलिए इसे हटा दिया गया है।
// // import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/device_info_provider.dart';
// import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player.dart';
// import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/video_widget/youtube_webview_player.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../home_screen_pages/religious_channel/religious_channel_details_page.dart';
// import '../home_screen_pages/sports_category/tv_show_final_details_page.dart';
// import '../home_screen_pages/tv_show/tv_show_final_details_page.dart';
// import '../home_screen_pages/tv_show_pak/tv_show_final_details_page.dart';
// import '../main.dart';
// import '../provider/focus_provider.dart';
// import '../video_widget/socket_service.dart';
// // ✅ CHANGE: PaletteColorService की अब ज़रूरत नहीं है।
// // import '../widgets/utils/color_service.dart';

// // VOD Styling Classes
// class ProfessionalVODColors {
//   static const primaryDark = Color(0xFF0A0E1A);
//   static const surfaceDark = Color(0xFF1A1D29);
//   static const accentBlue = Color(0xFF3B82F6);
//   static const accentPurple = Color(0xFF8B5CF6);
//   static const accentGreen = Color(0xFF10B981);
//   static const accentRed = Color(0xFFEF4444);
// }

// // ... NewsItemModel and fetchFromApi functions remain the same ...
// // (Model and API function code is unchanged, so it is omitted for brevity but should be in your file)
// class NewsItemModel {
//   final String id;
//   final String name;
//   final String? description;
//   final String banner;
//   final String? poster;
//   final String url;
//   final String? contentType;
//   final String? sourceType;

//   NewsItemModel({
//     required this.id,
//     required this.name,
//     this.description,
//     required this.banner,
//     this.poster,
//     required this.url,
//     this.contentType,
//     this.sourceType,
//   });

//   factory NewsItemModel.fromJson(Map<String, dynamic> json) {
//     String bannerUrl = json['banner']?.toString() ??
//         json['channel_logo']?.toString() ??
//         json['channel_bg']?.toString() ??
//         json['logo']?.toString() ??
//         '';

//     if (bannerUrl.isNotEmpty && !bannerUrl.startsWith('http')) {
//       bannerUrl = 'https://dashboard.cpplayers.com/public/$bannerUrl';
//     }

//     return NewsItemModel(
//       id: json['id']?.toString() ?? '0',
//       name: json['name']?.toString() ?? json['channel_name']?.toString() ?? json['title']?.toString()?? '',
//       description: json['description']?.toString(),
//       banner: bannerUrl,
//       poster: json['poster']?.toString(),
//       url: json['movie_url']?.toString() ?? json['channel_link']?.toString() ?? '',
//       contentType: json['content_type']?.toString(),
//       sourceType: json['source_type']?.toString(),
//     );
//   }
// }
// Future<List<NewsItemModel>> fetchFromApi(String searchTerm) async {
//   try {
//     // String authKey = AuthManager.authKey;
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? authKey = prefs.getString('auth_key');
//     // if (authKey.isEmpty) {
//     //   throw Exception('Authentication key is missing');
//     // }

//     final url = Uri.parse(
//         'https://dashboard.cpplayers.com/api/v2/getSearchCategoryList');
//     final body = json.encode({'keywords': searchTerm});

//     final response = await https.post(
//       url,
//       headers: {
//         'auth-key': authKey??'',
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
//             newsItems.add(NewsItemModel.fromJson(itemDataRaw as Map<String, dynamic>));
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

// class _SearchScreenState extends State<SearchScreen> {
//   List<NewsItemModel> searchResults = [];
//   bool isLoading = false;
//   final TextEditingController _searchController = TextEditingController();
//   final FocusNode _searchFieldFocusNode = FocusNode();
//   final FocusNode _searchIconFocusNode = FocusNode();
//   Timer? _debounce;
//   List<FocusNode> _itemFocusNodes = [];
//   bool _isNavigating = false;
//   bool _showSearchField = false;
//   bool _shouldContinueLoading = true;
//   String _errorMessage = '';
//   bool _searchSubmittedWithEnter = false;

//   final FocusNode _gridFocusNode = FocusNode();
//   int _focusedIndex = 0;
//   static const int _itemsPerRow = 6;
//   final ScrollController _scrollController = ScrollController();

//   // ... initState and other methods remain the same ...
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
//     _searchFieldFocusNode.dispose();
//     _searchIconFocusNode.dispose();
//     _searchController.dispose();
//     _debounce?.cancel();
//     _itemFocusNodes.forEach((node) => node.dispose());
//     super.dispose();
//   }

//   Future<void> _onItemTap(BuildContext context, int index) async {
//     // This function remains unchanged
//      if (_isNavigating) return;
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
//     // This function remains unchanged
//         showDialog(
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
//     // This function remains unchanged
//         if (Navigator.of(context, rootNavigator: true).canPop()) {
//       Navigator.of(context, rootNavigator: true).pop();
//     }
//   }

//   Future<void> _navigateToVideoScreen(
//       BuildContext context, List<NewsItemModel> channels, int index) async {
//     // This function remains unchanged
//         if (index < 0 || index >= channels.length) return;

//     final channel = channels[index];
//     final int? parsedContentType = int.tryParse(channel.contentType ?? '');
//     final int channelId = int.tryParse(channel.id) ?? 0;

//     debugPrint(
//         'Navigating to: ${channel.name}, ContentType: ${channel.contentType}, ParsedType: $parsedContentType, URL: ${channel.url}');

//     try {
//       Widget? targetPage;
//       if (parsedContentType == 2) {
//         targetPage = WebSeriesDetailsPage(
//             id: channelId,
//             banner: channel.banner,
//             poster: channel.poster?? channel.banner?? '' ,
//             logo: channel.banner,
//             name: channel.name);
//       } else if (parsedContentType == 4) {
//         targetPage = TvShowFinalDetailsPage(
//             id: channelId,
//             banner: channel.banner,
//             poster: channel.poster?? channel.banner?? '' ,
//             name: channel.name);
//       } else if (parsedContentType == 5) {
//         targetPage = TvShowPakFinalDetailsPage(
//             id: channelId,
//             banner: channel.banner,
//             poster: channel.poster?? channel.banner?? '' ,
//             name: channel.name);
//       } else if (parsedContentType == 7) {
//         targetPage = ReligiousChannelDetailsPage(
//             id: channelId,
//             banner: channel.banner,
//             poster: channel.poster?? channel.banner?? '' ,
//             name: channel.name);
//       } else if (parsedContentType == 8) {
//         targetPage = TournamentFinalDetailsPage(
//             id: channelId,
//             banner: channel.banner,
//             poster: channel.poster?? channel.banner?? '' ,
//             name: channel.name);
//       }

//       if (targetPage != null) {
//         await Navigator.push(
//             context, MaterialPageRoute(builder: (context) => targetPage!));
//         return;
//       }

//       final String? videoUrl = channel.url;
//       if (videoUrl == null || videoUrl.isEmpty) {
//         debugPrint(
//             'Navigation failed: No destination page for contentType $parsedContentType and video URL is null.');
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Cannot play this content.')));
//         return;
//       }

//       if (parsedContentType == 1) {
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
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => CustomYoutubePlayer(
//                         videoData: VideoData(
//                             id: channel.url,
//                             title: channel.name,
//                             youtubeUrl: channel.url,
//                             thumbnail: channel.banner ?? channel.poster ?? '',
//                             description: channel.description ?? ''),
//                         playlist: [
//                           VideoData(
//                               id: channel.url,
//                               title: channel.name,
//                               youtubeUrl: channel.url,
//                               thumbnail:
//                                   channel.banner ?? channel.poster ?? '',
//                               description: channel.description ?? '')
//                         ],
//                         )));
//           }
//         }
//       } else {
//         debugPrint(
//             'Navigation failed: unhandled contentType $parsedContentType.');
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//             content: Text('This content type is not supported.')));
//       }

//       if(parsedContentType == 3){
//           await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => VideoScreen(
//             videoUrl: videoUrl,
//             startAtPosition: Duration.zero,
//             bannerImageUrl: channel.banner,
//             videoType: '',
//             channelList: [],
//             isLive: true,
//             isVOD: false,
//             isBannerSlider: false,
//             source: 'isSearchScreen',
//             isSearch: true,
//             videoId: int.tryParse(channel.id),
//             unUpdatedUrl: videoUrl,
//             name: channel.name,
//             liveStatus: true,
//           ),
//         ),
//       );
//       }
//     } catch (e) {
//       debugPrint('Navigation error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Error opening content.')));
//     }
//   }

//   void _performSearch(String searchTerm) {
//     // This function remains mostly unchanged
//         if (_debounce?.isActive ?? false) _debounce!.cancel();
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

//         // if ((_searchSubmittedWithEnter || _showSearchField) && searchResults.isNotEmpty) {
//         //   WidgetsBinding.instance.addPostFrameCallback((_) {
//         //     _gridFocusNode.requestFocus();
//         //     _updateAndScrollToFocus();
//         //     if (mounted) {
//         //       _searchSubmittedWithEnter = false;
//         //     }
//         //   });
//         // }
//               if (_searchSubmittedWithEnter && searchResults.isNotEmpty) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _gridFocusNode.requestFocus();
//           _updateAndScrollToFocus();
//           if (mounted) {
//             // Flag ko reset kar dein taaki agli bar type karne par focus na hate.
//             _searchSubmittedWithEnter = false;
//           }
//         });
//       }
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
//     // This function remains unchanged
//         if (event is! RawKeyDownEvent || searchResults.isEmpty) return;

//     final totalItems = searchResults.length;
//     int previousIndex = _focusedIndex;

//     if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//       // if (_focusedIndex >= _itemsPerRow) {
//       //   setState(() => _focusedIndex -= _itemsPerRow);
//       // } else {
//       //   _toggleSearchField();
//       // }
//           if (_focusedIndex >= _itemsPerRow) {
//       setState(() => _focusedIndex -= _itemsPerRow);
//     } else {
//       // ✅ CHANGE: Ab sirf icon par focus jayega, keyboard nahi khulega.
//       _searchIconFocusNode.requestFocus();
//     }
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//       if (_focusedIndex < totalItems - _itemsPerRow) {
//         setState(() => _focusedIndex =
//             (_focusedIndex + _itemsPerRow).clamp(0, totalItems - 1));
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
//     _itemFocusNodes[_focusedIndex].requestFocus();
//     // ✅ CHANGE: Color update wali line hata di gayi hai.
//     // _updatePaletteColor(searchResults[_focusedIndex].banner, true);
//     Scrollable.ensureVisible(
//       _itemFocusNodes[_focusedIndex].context!,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOutCubic,
//       alignment: 0.3,
//     );
//   }

//   void _toggleSearchField() {
//     // This function remains unchanged
//         setState(() {
//       _showSearchField = !_showSearchField;
//       if (_showSearchField) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _searchFieldFocusNode.requestFocus();
//         });
//       } else {
//         _searchIconFocusNode.requestFocus();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         if (didPop) return;
//         // ✅ CHANGE: Back button ka logic update kiya gaya hai.
//         if (_searchFieldFocusNode.hasFocus) {
//           _searchFieldFocusNode.unfocus();
//           // Optionally, also close the search bar and focus the icon
//           setState(() {
//             _showSearchField = false;
//             _searchIconFocusNode.requestFocus();
//           });
//         } else {
//           context.read<FocusProvider>().requestWatchNowFocus();
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: Container(
//           // ✅ CHANGE: Background ab hamesha fixed rahega.
//           color: ProfessionalVODColors.primaryDark,
//           child: Column(
//             children: [
//               _buildSearchBar(),
//               Expanded(child: _buildBody()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     // This widget remains unchanged
//     return Container(
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
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 400),
//             width: _showSearchField ? screenwdt * 0.4 : 50,
//             child: Row(
//               children: [
//                 if (_showSearchField)
//                   Expanded(
//                     child: TextField(
//                       controller: _searchController,
//                       focusNode: _searchFieldFocusNode,
//                       decoration: InputDecoration(
//                         hintText: 'Search content...',
//                         hintStyle:
//                             TextStyle(color: Colors.white.withOpacity(0.5)),
//                         border: InputBorder.none,
//                         focusedBorder: InputBorder.none,
//                       ),
//                       style: const TextStyle(color: Colors.white, fontSize: 16),
//                       onChanged: _performSearch,
//                       onSubmitted: (value) {
//                         if (value.trim().isNotEmpty) {
//                           _searchSubmittedWithEnter = true;
//                           _performSearch(value);
//                           _searchFieldFocusNode.unfocus();
//                           _gridFocusNode.requestFocus();
//                         } else {
//                           _toggleSearchField();
//                         }
//                       },
//                     ),
//                   ),
//                 Focus(
//                   focusNode: _searchIconFocusNode,
//                   onKey: (node, event) {
//                     if (event is RawKeyDownEvent) {
//                       if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                         context
//                             .read<FocusProvider>()
//                             .requestSearchNavigationFocus();
//                         return KeyEventResult.handled;
//                       }
//                       if (event.logicalKey == LogicalKeyboardKey.select ||
//                           event.logicalKey == LogicalKeyboardKey.enter) {
//                         _toggleSearchField();
//                         return KeyEventResult.handled;
//                       }
//                     }
//                     return KeyEventResult.ignored;
//                   },
//                   child: GestureDetector(
//                     onTap: _toggleSearchField,
//                     child: Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: _searchIconFocusNode.hasFocus
//                             ? ProfessionalVODColors.accentPurple
//                             : Colors.white.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       child: Icon(
//                         Icons.search,
//                         color: Colors.white,
//                         size: _searchIconFocusNode.hasFocus ? 28 : 24,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBody() {
//     // This widget remains unchanged
//     if (_errorMessage.isNotEmpty) {
//       return Center(
//         child: Text(_errorMessage, style: const TextStyle(color: Colors.white)),
//       );
//     }
//     if (isLoading) {
//       return const Center(
//           child: SpinKitFadingCircle(color: Colors.white, size: 50.0));
//     }
//     if (searchResults.isEmpty && _searchController.text.isNotEmpty) {
//       return const Center(
//           child:
//               Text('No results found', style: TextStyle(color: Colors.white)));
//     }

//     return RawKeyboardListener(
//       focusNode: _gridFocusNode,
//       onKey: _handleKeyNavigation,
//       child: Padding(
//         padding: EdgeInsets.symmetric(
//             horizontal: screenwdt * 0.05, vertical: screenhgt * 0.02),
//         child: GridView.builder(
//           controller: _scrollController,
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: _itemsPerRow,
//             mainAxisSpacing: 20,
//             crossAxisSpacing: 20,
//             childAspectRatio: 1.3,
//           ),
//           itemCount: searchResults.length,
//           itemBuilder: (context, index) {
//             final item = searchResults[index];
//             return OptimizedSearchCard(
//               searchItem: item,
//               focusNode: _itemFocusNodes[index],
//               isFocused: _focusedIndex == index,
//               onTap: () => _onItemTap(context, index),
//             );
//           },
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
//     // ✅ CHANGE: Focus color ab hamesha fixed rahega.
//     final dominantColor = ProfessionalVODColors.accentPurple;

//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         transform: isFocused ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
//         transformAlignment: Alignment.center,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             if (isFocused)
//               BoxShadow(
//                   color: dominantColor.withOpacity(0.4),
//                   blurRadius: 20,
//                   offset: const Offset(0, 8))
//             else
//               BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 4)),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(15),
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               _buildSearchItemImage(),
//               if (isFocused) _buildFocusBorder(dominantColor),
//               _buildGradientOverlay(),
//               _buildSearchItemInfo(dominantColor),
//               if (isFocused) _buildPlayButton(dominantColor),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Card ke baaki helper functions (_buildSearchItemImage, etc.) waise hi rahenge
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
//         errorWidget: (context, url, error) => Image.asset(localImage, fit: BoxFit.cover),
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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/home_screen_pages/webseries_screen/webseries_details_page.dart';
import 'package:mobi_tv_entertainment/provider/device_info_provider.dart';
import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player.dart';
import 'package:mobi_tv_entertainment/video_widget/live_video_screen.dart';
import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/video_widget/youtube_webview_player.dart';
import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home_screen_pages/religious_channel/religious_channel_details_page.dart';
import '../home_screen_pages/sports_category/tv_show_final_details_page.dart';
import '../home_screen_pages/tv_show/tv_show_final_details_page.dart';
import '../home_screen_pages/tv_show_pak/tv_show_final_details_page.dart';
import '../main.dart'; // Assuming bannerhgt, screenwdt, etc. are defined here
import '../provider/focus_provider.dart';
import '../video_widget/socket_service.dart';

class ProfessionalVODColors {
  static const primaryDark = Color(0xFF0A0E1A);
  static const surfaceDark = Color(0xFF1A1D29);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentPurple = Color(0xFF8B5CF6);
  static const accentGreen = Color(0xFF10B981);
  static const accentRed = Color(0xFFEF4444);
}

// class NewsItemModel {
//   final String id;
//   final String name;
//   final String? description;
//   final String banner;
//   final String? poster;
//   final String url;
//   final String? contentType;
//   final String? sourceType;

//   NewsItemModel({
//     required this.id,
//     required this.name,
//     this.description,
//     required this.banner,
//     this.poster,
//     required this.url,
//     this.contentType,
//     this.sourceType,
//   });

//   factory NewsItemModel.fromJson(Map<String, dynamic> json) {
//     String bannerUrl = json['banner']?.toString() ??
//         json['channel_logo']?.toString() ??
//         json['channel_bg']?.toString() ??
//         json['logo']?.toString() ??
//         json['thumbnail']?.toString() ??
//         '';

//     if (bannerUrl.isNotEmpty && !bannerUrl.startsWith('http')) {
//       bannerUrl = 'https://dashboard.cpplayers.com/public/$bannerUrl';
//     }

//     return NewsItemModel(
//       id: json['id']?.toString() ?? '0',
//       name: json['name']?.toString() ?? json['channel_name']?.toString() ?? json['title']?.toString() ?? '',
//       description: json['description']?.toString(),
//       banner: bannerUrl,
//       poster: json['poster']?.toString(),
//       url: json['movie_url']?.toString() ?? json['channel_link']?.toString() ?? '',
//       contentType: json['content_type']?.toString(),
//       sourceType: json['source_type']?.toString(),
//     );
//   }
// }

// Future<List<NewsItemModel>> fetchFromApi(String searchTerm) async {
//   try {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? authKey = prefs.getString('auth_key');

//     final url = Uri.parse('https://dashboard.cpplayers.com/api/v2/getSearchCategoryList');
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
//             newsItems.add(NewsItemModel.fromJson(itemDataRaw as Map<String, dynamic>));
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

Future<List<NewsItemModel>> fetchFromApi(String searchTerm) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authKey = prefs.getString('auth_key');

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
            // --- FIX: Only add items if their status is 1 ---
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

Uint8List _getImageFromBase64String(String base64String) {
  try {
    String cleanBase64 = base64String.split(',').last;
    return base64Decode(cleanBase64);
  } catch (e) {
    rethrow;
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  List<NewsItemModel> searchResults = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<FocusNode> _itemFocusNodes = [];
  bool _isNavigating = false;
  bool _shouldContinueLoading = true;
  String _errorMessage = '';

  // Keyboard and input related variables
  bool _showKeyboard = false;
  bool _isShiftEnabled = false;
  String _searchText = '';

  final FocusNode _gridFocusNode = FocusNode();
  final FocusNode _searchIconFocusNode = FocusNode();
  int _focusedIndex = 0;
  static const int _itemsPerRow = 6;
  final ScrollController _scrollController = ScrollController();

  // New GlobalKey to get the height of the search bar
  final GlobalKey _searchBarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _searchIconFocusNode.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<FocusProvider>()
          .setSearchIconFocusNode(_searchIconFocusNode);
    });
  }

  @override
  void dispose() {
    _gridFocusNode.dispose();
    _scrollController.dispose();
    _searchIconFocusNode.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    _itemFocusNodes.forEach((node) => node.dispose());
    super.dispose();
  }

  // Keyboard input handler similar to login screen
  void _onKeyPressed(String value) {
    setState(() {
      if (value == 'OK') {
        // Perform search when OK is pressed
        if (_searchText.trim().isNotEmpty) {
          _performSearch(_searchText);
          _showKeyboard = false;
          _gridFocusNode.requestFocus();
        }
        return;
      }

      if (value == 'SHIFT') {
        _isShiftEnabled = !_isShiftEnabled;
        return;
      }

      if (value == 'DEL') {
        if (_searchText.isNotEmpty) {
          _searchText = _searchText.substring(0, _searchText.length - 1);
          _searchController.text = _searchText;
          _performSearch(_searchText); // Real-time search
        }
      } else {
        _searchText += value;
        _searchController.text = _searchText;
        _performSearch(_searchText); // Real-time search
      }
    });
  }

  Future<void> _onItemTap(BuildContext context, int index) async {
    if (_isNavigating) return;
    _isNavigating = true;
    _showLoadingIndicator(context);

    try {
      if (_shouldContinueLoading) {
        await _navigateToVideoScreen(context, searchResults, index);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong')),
      );
    } finally {
      _isNavigating = false;
      _shouldContinueLoading = true;
      _dismissLoadingIndicator();
    }
  }

  void _showLoadingIndicator(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            _shouldContinueLoading = false;
            _dismissLoadingIndicator();
            return false;
          },
          child: const Center(
            child: SpinKitFadingCircle(color: Colors.white, size: 50.0),
          ),
        );
      },
    );
  }

  void _dismissLoadingIndicator() {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  // Future<void> _navigateToVideoScreen(
  //     BuildContext context, List<NewsItemModel> channels, int index) async {
  //   // if (index < 0 || index >= channels.length) return;

  //   final channel = channels[index];
  //   final int? parsedContentType = int.tryParse(channel.contentType ?? '');
  //   final int channelId = int.tryParse(channel.id) ?? 0;

  //   try {
  //     Widget? targetPage;
  //     if (parsedContentType == 2) {
  //       targetPage = WebSeriesDetailsPage(
  //           id: channelId,
  //           banner: channel.banner,
  //           poster: channel.poster ?? channel.banner ?? '',
  //           logo: channel.banner,
  //           name: channel.name, updatedAt: channel.updatedAt,);
  //     } else if (parsedContentType == 4) {
  //       targetPage = TvShowFinalDetailsPage(
  //           id: channelId,
  //           banner: channel.banner,
  //           poster: channel.poster ?? channel.banner ?? '',
  //           name: channel.name);
  //     } else if (parsedContentType == 5) {
  //       targetPage = TvShowPakFinalDetailsPage(
  //           id: channelId,
  //           banner: channel.banner,
  //           poster: channel.poster ?? channel.banner ?? '',
  //           name: channel.name, updatedAt: channel.updatedAt,);
  //     } else if (parsedContentType == 7) {
  //       targetPage = ReligiousChannelDetailsPage(
  //           id: channelId,
  //           banner: channel.banner,
  //           poster: channel.poster ?? channel.banner ?? '',
  //           name: channel.name, updatedAt: channel.updatedAt,);
  //     } else if (parsedContentType == 8) {
  //       targetPage = TournamentFinalDetailsPage(
  //           id: channelId,
  //           banner: channel.banner,
  //           poster: channel.poster ?? channel.banner ?? '',
  //           name: channel.name, updatedAt: channel.updatedAt,);
  //     }

  //     if (targetPage != null) {
  //       await Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => targetPage!));
  //       return;
  //     }

  //     final String? videoUrl = channel.url;
  //     if (videoUrl == null || videoUrl.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Cannot play this content.')));
  //       return;
  //     }

  //     if (parsedContentType == 1) {
  //       if (channel.sourceType == 'YoutubeLive' ||
  //           channel.sourceType == 'youtube') {
  //         final deviceInfo = context.read<DeviceInfoProvider>();
  //         if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
  //           await Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => YoutubeWebviewPlayer(
  //                 videoUrl: channel.url,
  //                 name: channel.name,
  //               ),
  //             ),
  //           );
  //         } else {
  //           await Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                   builder: (context) => CustomYoutubePlayer(
  //                       videoData: VideoData(
  //                           id: channel.url,
  //                           title: channel.name,
  //                           youtubeUrl: channel.url,
  //                           thumbnail: channel.banner ?? channel.poster ?? '',
  //                           description: channel.description ?? ''),
  //                       playlist: [
  //                         VideoData(
  //                             id: channel.url,
  //                             title: channel.name,
  //                             youtubeUrl: channel.url,
  //                             thumbnail:
  //                                 channel.banner ?? channel.poster ?? '',
  //                             description: channel.description ?? '')
  //                       ],
  //                   )));
  //         }
  //       }
  //     }

  //     if (parsedContentType == 3) {
  //       await Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => VideoScreen(
  //             videoUrl: videoUrl,
  //             startAtPosition: Duration.zero,
  //             bannerImageUrl: channel.banner,
  //             videoType: '',
  //             channelList: [],
  //             isLive: true,
  //             isVOD: false,
  //             isBannerSlider: false,
  //             source: 'isSearchScreen',
  //             isSearch: true,
  //             videoId: int.tryParse(channel.id),
  //             unUpdatedUrl: videoUrl,
  //             name: channel.name,
  //             liveStatus: true,
  //           ),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Error opening content.')));
  //   }
  // }

  Future<void> _navigateToVideoScreen(
      BuildContext context, List<NewsItemModel> channels, int index) async {
    if (index < 0 || index >= channels.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid channel index')),
      );
      return;
    }

    final channel = channels[index];
    final int? parsedContentType = int.tryParse(channel.contentType);

    // --- SOLUTION START ---
    // Step 1: Pehle un content types ko handle karein jinhe details page chahiye.
    // Inko video URL ki zaroorat nahi hai.
    try {
      if (parsedContentType == 2) {
        // WebSeries
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebSeriesDetailsPage(
              id: int.tryParse(channel.id) ?? 0,
              banner: channel.banner,
              poster: channel.poster,
              logo: channel.banner,
              name: channel.name,
              updatedAt: channel.updatedAt,
            ),
          ),
        );
        return; // Navigate hone ke baad function se bahar nikal jayein
      } else if (parsedContentType == 4) {
        // TV Show
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TvShowFinalDetailsPage(
              id: int.tryParse(channel.id) ?? 0,
              banner: channel.banner,
              poster: channel.poster,
              name: channel.name,
            ),
          ),
        );
        return; // Navigate hone ke baad function se bahar nikal jayein
      } else if (parsedContentType == 5) {
        // TV Show Pak
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TvShowPakFinalDetailsPage(
              id: int.tryParse(channel.id) ?? 0,
              banner: channel.banner,
              poster: channel.poster,
              name: channel.name,
              updatedAt: channel.updatedAt,
            ),
          ),
        );
        return; // Navigate hone ke baad function se bahar nikal jayein
      } else if (parsedContentType == 7) {
        // Religious Channel
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReligiousChannelDetailsPage(
              id: int.tryParse(channel.id) ?? 0,
              banner: channel.banner,
              poster: channel.poster,
              name: channel.name,
              updatedAt: channel.updatedAt,
            ),
          ),
        );
        return; // Navigate hone ke baad function se bahar nikal jayein
      } else if (parsedContentType == 8) {
        // Tournament
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TournamentFinalDetailsPage(
              id: int.tryParse(channel.id) ?? 0,
              banner: channel.banner,
              poster: channel.poster,
              name: channel.name,
              updatedAt: channel.updatedAt,
            ),
          ),
        );
        return; // Navigate hone ke baad function se bahar nikal jayein
      }
    } catch (e) {
      // Error handling zaroor karein
      print('Navigation Error for Details Page: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open details page.')),
      );
      return;
    }
    // --- SOLUTION END ---

    // Step 2: Ab video URL aur streamType ki jaanch karein.
    final String? videoUrl = channel.url;
    final String? streamType = channel.streamType;

    if (videoUrl == null || videoUrl.isEmpty || streamType == null) {
      // Agar upar koi type match nahi hua aur yahan URL bhi nahi hai, to kuch na karein.
      return;
    }

    try {
      if (parsedContentType == 3) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoScreen(
              videoUrl: videoUrl,
              // startAtPosition: Duration.zero,
              bannerImageUrl: channel.banner,
              // videoType: '',
              channelList: [],
              // isLive: true,
              // isVOD: false,
              // isBannerSlider: false,
              // source: 'isSearchScreen',
              // isSearch: true,
              videoId: int.tryParse(channel.id),
              // unUpdatedUrl: videoUrl,
              name: channel.name,
              liveStatus: true,
              updatedAt: channel.updatedAt,
              source: 'isSearch',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening content.')));
    }

    // Step 3: Ab bache hue content types (jaise type 1) ko handle karein.
    try {
      if (parsedContentType == 1) {
        // Live Channel / Video
        if (channel.sourceType == 'YoutubeLive' ||
            channel.sourceType == 'youtube') {
          final deviceInfo = context.read<DeviceInfoProvider>();
          if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => YoutubeWebviewPlayer(
                  videoUrl: channel.url,
                  name: channel.name,
                ),
              ),
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomYoutubePlayer(
                  videoData: VideoData(
                    id: channel.id,
                    title: channel.name,
                    youtubeUrl: channel.url,
                    thumbnail: channel.banner ?? channel.poster ?? '',
                    description: channel.description ?? '',
                  ),
                  playlist: [
                    VideoData(
                      id: channel.id,
                      title: channel.name,
                      youtubeUrl: channel.url,
                      thumbnail: channel.banner ?? channel.poster ?? '',
                      description: channel.description ?? '',
                    ),
                  ],
                ),
              ),
            );
          }
        } else {
          // Handle other stream types for contentType 1 if any (e.g., M3u8)
          // await Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(...)));
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LiveVideoScreen(
                videoUrl: channel.url,
                bannerImageUrl: channel.banner,
                channelList: [],
                // isLive: false,
                // isSearch: true,
                videoId: int.tryParse(channel.id),
                name: channel.name,
                liveStatus: false,
                updatedAt: channel.updatedAt,
                source: 'isSearch',
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Navigation Error for Video Player: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not play the video.')),
      );
    }
  }

  void _performSearch(String searchTerm) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (searchTerm.trim().isEmpty) {
      setState(() {
        isLoading = false;
        searchResults.clear();
        _itemFocusNodes.clear();
        _errorMessage = '';
        _focusedIndex = 0;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      setState(() {
        isLoading = true;
        searchResults.clear();
        _itemFocusNodes.forEach((node) => node.dispose());
        _itemFocusNodes.clear();
        _errorMessage = '';
        _focusedIndex = 0;
      });

      try {
        final results = await fetchFromApi(searchTerm);
        if (!mounted) return;
        setState(() {
          searchResults = results;
          _itemFocusNodes.addAll(
              List.generate(searchResults.length, (index) => FocusNode()));
          isLoading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          _errorMessage = e.toString();
        });
      }
    });
  }

  void _handleKeyNavigation(RawKeyEvent event) {
    if (event is! RawKeyDownEvent || searchResults.isEmpty) return;

    final totalItems = searchResults.length;
    int previousIndex = _focusedIndex;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_focusedIndex < _itemsPerRow) {
        _searchIconFocusNode.requestFocus();
        return;
      } else {
        final newIndex = _focusedIndex - _itemsPerRow;
        if (newIndex >= 0) {
          setState(() => _focusedIndex = newIndex);
        }
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      final newIndex = _focusedIndex + _itemsPerRow;
      if (newIndex < totalItems) {
        setState(() => _focusedIndex = newIndex);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (_focusedIndex > 0) {
        setState(() => _focusedIndex--);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (_focusedIndex < totalItems - 1) {
        setState(() => _focusedIndex++);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.select ||
        event.logicalKey == LogicalKeyboardKey.enter) {
      _onItemTap(context, _focusedIndex);
    }

    if (previousIndex != _focusedIndex) {
      _updateAndScrollToFocus();
      HapticFeedback.lightImpact();
    }
  }

  void _updateAndScrollToFocus() {
    if (!mounted || _focusedIndex >= _itemFocusNodes.length) return;

    final focusedNode = _itemFocusNodes[_focusedIndex];
    focusedNode.requestFocus();

    // Scroll command ko agle frame tak delay karein
    // Isse yeh sunishchit hoga ki widget ka context scroll ke liye taiyar hai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusedNode.context != null) {
        Scrollable.ensureVisible(
          focusedNode.context!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          alignment: 0.5, // Item ko center mein rakhega
        );
      }
    });
  }

  void _toggleKeyboard() {
    setState(() {
      _showKeyboard = !_showKeyboard;
      if (!_showKeyboard) {
        _searchIconFocusNode.requestFocus();
      }
    });
  }

  Widget _buildQwertyKeyboard() {
    final row1 = "1234567890".split('');
    final row2 = "qwertyuiop".split('');
    final row3 = "asdfghjkl".split('');
    final row4 = ["zxcvbnm", "DEL"]
        .expand((e) => e == "DEL" ? [e] : e.split(''))
        .toList();
    final row5 = ["SHIFT", " ", "OK"];

    return Container(
      color: ProfessionalVODColors.surfaceDark.withOpacity(0.95),
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildKeyboardRow(row1),
          _buildKeyboardRow(row2),
          _buildKeyboardRow(row3),
          _buildKeyboardRow(row4),
          _buildKeyboardRow(row5, isSpecialRow: true),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys, {bool isSpecialRow = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        double width = screenwdt * 0.07;
        if (key == ' ') width = screenwdt * 0.18;
        if (key == 'OK' || key == 'SHIFT' || key == 'DEL')
          width = screenwdt * 0.11;

        String displayKey = key;
        if (key != 'SHIFT' && key != 'DEL' && key != 'OK' && key.length == 1) {
          displayKey = _isShiftEnabled ? key.toUpperCase() : key.toLowerCase();
        }

        return _buildKey(displayKey, originalKey: key, width: width);
      }).toList(),
    );
  }

  Widget _buildKey(String label, {String? originalKey, double? width}) {
    final keyToProcess = originalKey ?? label;

    return Container(
      width: width ?? screenwdt * 0.18,
      height: screenhgt * 0.08,
      margin: const EdgeInsets.all(2),
      child: ElevatedButton(
        onPressed: () => _onKeyPressed(keyToProcess),
        style: ElevatedButton.styleFrom(
            backgroundColor: (keyToProcess == 'SHIFT' && _isShiftEnabled)
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.zero),
        child: Text(
          label,
          style: TextStyle(
            fontSize: nametextsz * 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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
            _searchIconFocusNode.requestFocus();
          });
        } else {
          context.read<FocusProvider>().requestWatchNowFocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          color: ProfessionalVODColors.primaryDark,
          child: Column(
            children: [
              Expanded(
                child: RawKeyboardListener(
                  focusNode: _gridFocusNode,
                  onKey: _handleKeyNavigation,
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildSearchBar(),
                      ),
                      _buildBodySliver(),
                    ],
                  ),
                ),
              ),
              if (_showKeyboard) _buildQwertyKeyboard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      key: _searchBarKey,
      padding: EdgeInsets.only(
        left: screenwdt * 0.05,
        right: screenwdt * 0.05,
        top: screenhgt * 0.04,
        bottom: screenhgt * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'SEARCH',
            style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.5),
          ),
          Row(
            children: [
              Container(
                width: screenwdt * 0.4,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _showKeyboard
                        ? ProfessionalVODColors.accentPurple
                        : Colors.white.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Text(
                  _searchText.isEmpty ? 'Search content...' : _searchText,
                  style: TextStyle(
                    color: _searchText.isEmpty ? Colors.white54 : Colors.white,
                    fontSize: nametextsz * 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 10),
              Focus(
                focusNode: _searchIconFocusNode,
                onKey: (node, event) {
                  if (event is RawKeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                      context
                          .read<FocusProvider>()
                          .requestSearchNavigationFocus();
                      return KeyEventResult.handled;
                    }
                    if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
                        searchResults.isNotEmpty) {
                      _gridFocusNode.requestFocus();
                      setState(() {
                        _focusedIndex = 0;
                      });
                      _updateAndScrollToFocus();
                      return KeyEventResult.handled;
                    }
                    if (event.logicalKey == LogicalKeyboardKey.select ||
                        event.logicalKey == LogicalKeyboardKey.enter) {
                      _toggleKeyboard();
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: GestureDetector(
                  onTap: _toggleKeyboard,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _searchIconFocusNode.hasFocus
                          ? ProfessionalVODColors.accentPurple
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      _showKeyboard ? Icons.keyboard_hide : Icons.search,
                      color: Colors.white,
                      size: _searchIconFocusNode.hasFocus ? 28 : 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBodySliver() {
    if (_errorMessage.isNotEmpty) {
      return SliverFillRemaining(
        child: Center(
          child:
              Text(_errorMessage, style: const TextStyle(color: Colors.white)),
        ),
      );
    }
    if (isLoading) {
      return const SliverFillRemaining(
        child:
            Center(child: SpinKitFadingCircle(color: Colors.white, size: 50.0)),
      );
    }
    if (searchResults.isEmpty && _searchText.isNotEmpty) {
      return const SliverFillRemaining(
        child: Center(
            child: Text('No results found',
                style: TextStyle(color: Colors.white))),
      );
    }
    if (searchResults.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(
          horizontal: screenwdt * 0.05, vertical: screenhgt * 0.02),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _itemsPerRow,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1.3,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = searchResults[index];
            return OptimizedSearchCard(
              searchItem: item,
              focusNode: _itemFocusNodes[index],
              isFocused: _focusedIndex == index,
              onTap: () => _onItemTap(context, index),
            );
          },
          childCount: searchResults.length,
        ),
      ),
    );
  }
}

class OptimizedSearchCard extends StatelessWidget {
  final NewsItemModel searchItem;
  final FocusNode focusNode;
  final bool isFocused;
  final VoidCallback onTap;

  const OptimizedSearchCard({
    Key? key,
    required this.searchItem,
    required this.focusNode,
    required this.isFocused,
    required this.onTap,
  }) : super(key: key);

  final String localImage = 'assets/placeholder.png';

  @override
  Widget build(BuildContext context) {
    final dominantColor = ProfessionalVODColors.accentPurple;

    // <<<<------ FIX: WRAP WITH FOCUS WIDGET ------>>>>
    return Focus(
      focusNode: focusNode,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          transform: isFocused
              ? (Matrix4.identity()..scale(1.05))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              if (isFocused)
                BoxShadow(
                    color: dominantColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8))
              else
                BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildSearchItemImage(),
                if (isFocused) _buildFocusBorder(dominantColor),
                _buildGradientOverlay(),
                _buildSearchItemInfo(dominantColor),
                if (isFocused) _buildPlayButton(dominantColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchItemImage() {
    String imageUrl = searchItem.banner;
    if (imageUrl.isEmpty) {
      return Image.asset(localImage, fit: BoxFit.cover);
    }

    if (imageUrl.startsWith('data:image')) {
      try {
        final imageBytes = _getImageFromBase64String(imageUrl);
        return Image.memory(imageBytes,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Image.asset(localImage));
      } catch (e) {
        return Image.asset(localImage);
      }
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            Container(color: ProfessionalVODColors.surfaceDark),
        errorWidget: (context, url, error) =>
            Image.asset(localImage, fit: BoxFit.cover),
      );
    }
  }

  Widget _buildFocusBorder(Color color) {
    return Positioned.fill(
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(width: 3, color: color))));
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.9)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchItemInfo(Color dominantColor) {
    return Positioned(
      bottom: 12,
      left: 12,
      right: 12,
      child: Text(
        searchItem.name.toUpperCase(),
        style: TextStyle(
          color: isFocused ? dominantColor : Colors.white,
          fontSize: isFocused ? 13 : 12,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4)
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildPlayButton(Color color) {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: color.withOpacity(0.9)),
        child:
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}
