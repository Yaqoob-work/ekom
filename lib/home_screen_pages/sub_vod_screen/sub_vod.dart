// // import 'dart:async';
// // import 'dart:convert';
// // import 'package:cached_network_image/cached_network_image.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/services.dart';
// // import 'package:mobi_tv_entertainment/main.dart';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as https;
// // import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// // import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// // import 'package:provider/provider.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../../video_widget/socket_service.dart';
// // import '../../video_widget/video_screen.dart';
// // import '../../widgets/models/news_item_model.dart';
// // import '../../widgets/small_widgets/loading_indicator.dart';
// // import '../../widgets/utils/color_service.dart';
// // import 'focussable_subvod_widget.dart';
// // import 'package:flutter_svg/flutter_svg.dart';

// // // API Service class for consistent header management
// // class ApiService {
// //   static Future<Map<String, String>> getHeaders() async {
// //     await AuthManager.initialize();
// //     String authKey = AuthManager.authKey;

// //     if (authKey.isEmpty) {
// //       throw Exception('Auth key not found. Please login again.');
// //     }

// //     return {
// //       'auth-key': authKey, // Updated header name
// //       'Accept': 'application/json',
// //       'Content-Type': 'application/json',
// //     };
// //   }

// //   static String get baseUrl => 'https://acomtv.coretechinfo.com/public/api/';
// // }

// // // Helper function to safely parse integers from dynamic values
// // int safeParseInt(dynamic value, {int defaultValue = 0}) {
// //   if (value == null) return defaultValue;

// //   if (value is int) {
// //     return value;
// //   } else if (value is String) {
// //     return int.tryParse(value) ?? defaultValue;
// //   } else if (value is double) {
// //     return value.toInt();
// //   }

// //   return defaultValue;
// // }

// // // Helper function to safely parse strings
// // String safeParseString(dynamic value, {String defaultValue = ''}) {
// //   if (value == null) return defaultValue;
// //   return value.toString();
// // }

// // // Updated NetworkApi model with proper int handling
// // class NetworkApi {
// //   final int id; // Now properly int
// //   final String name;
// //   final String logo;
// //   final int networksOrder; // Changed to int

// //   NetworkApi({
// //     required this.id,
// //     required this.name,
// //     required this.logo,
// //     required this.networksOrder,
// //   });

// //   factory NetworkApi.fromJson(Map<String, dynamic> json) {
// //     return NetworkApi(
// //       id: safeParseInt(json['id']), // Safe int parsing
// //       name: safeParseString(json['name'], defaultValue: 'No Name'),
// //       logo: safeParseString(json['logo'], defaultValue: 'localImage'),
// //       networksOrder: safeParseInt(json['networks_order']), // Now int
// //     );
// //   }

// //   // Override equality for listEquals comparison
// //   @override
// //   bool operator ==(Object other) {
// //     if (identical(this, other)) return true;
// //     return other is NetworkApi &&
// //         other.id == id &&
// //         other.name == name &&
// //         other.logo == logo &&
// //         other.networksOrder == networksOrder;
// //   }

// //   @override
// //   int get hashCode =>
// //       id.hashCode ^ name.hashCode ^ logo.hashCode ^ networksOrder.hashCode;
// // }

// // // Updated MovieDetailsApi model with proper int handling
// // class MovieDetailsApi {
// //   final int id; // Now properly int
// //   final String name;
// //   final String banner;
// //   final String poster;
// //   final String genres;
// //   final int status; // Changed from String to int

// //   MovieDetailsApi({
// //     required this.id,
// //     required this.name,
// //     required this.banner,
// //     required this.poster,
// //     required this.genres,
// //     required this.status,
// //   });

// //   factory MovieDetailsApi.fromJson(Map<String, dynamic> json) {
// //     return MovieDetailsApi(
// //       id: safeParseInt(json['id']), // Safe int parsing
// //       name: safeParseString(json['name'], defaultValue: 'No Name'),
// //       banner: safeParseString(json['banner'], defaultValue: 'localImage'),
// //       poster: safeParseString(json['poster'], defaultValue: 'localImage'),
// //       genres: safeParseString(json['genres'], defaultValue: 'Unknown'),
// //       status: safeParseInt(json['status']), // Now int instead of string
// //     );
// //   }

// //   // Helper method to check if movie is active
// //   bool get isActive => status == 1;

// //   // Override equality for comparison
// //   @override
// //   bool operator ==(Object other) {
// //     if (identical(this, other)) return true;
// //     return other is MovieDetailsApi &&
// //         other.id == id &&
// //         other.name == name &&
// //         other.banner == banner &&
// //         other.poster == poster &&
// //         other.genres == genres &&
// //         other.status == status;
// //   }

// //   @override
// //   int get hashCode =>
// //       id.hashCode ^
// //       name.hashCode ^
// //       banner.hashCode ^
// //       poster.hashCode ^
// //       genres.hashCode ^
// //       status.hashCode;
// // }

// // // Updated fetch functions with proper error handling

// // Future<MovieDetailsApi> fetchMovieDetails(
// //     BuildContext context, int contentId) async {
// //   final prefs = await SharedPreferences.getInstance();
// //   final cachedMovieDetails = prefs.getString('movie_details_$contentId');

// //   // Step 1: Return cached data immediately if available
// //   if (cachedMovieDetails != null) {
// //     try {
// //       final Map<String, dynamic> body = json.decode(cachedMovieDetails);
// //       return MovieDetailsApi.fromJson(body);
// //     } catch (e) {
// //       // Clear corrupted cache
// //       prefs.remove('movie_details_$contentId');
// //     }
// //   }

// //   // Step 2: Fetch API data if no cache is available
// //   try {
// //     final headers = await ApiService.getHeaders();

// //     final response = await https.get(
// //       Uri.parse('${ApiService.baseUrl}getMovieDetails/$contentId'),
// //       headers: headers,
// //     );

// //     if (response.statusCode == 200) {
// //       final Map<String, dynamic> body = json.decode(response.body);
// //       final movieDetails = MovieDetailsApi.fromJson(body);

// //       // Step 3: Cache the fetched data
// //       prefs.setString('movie_details_$contentId', response.body);

// //       return movieDetails;
// //     } else if (response.statusCode == 401 || response.statusCode == 403) {
// //       throw Exception('Something went wrong');
// //     } else {
// //       throw Exception('Something went wrong');
// //     }
// //   } catch (e) {
// //     rethrow;
// //   }
// // }

// // Future<List<NetworkApi>> fetchNetworks(BuildContext context) async {
// //   final prefs = await SharedPreferences.getInstance();
// //   final cachedNetworks = prefs.getString('networks');

// //   List<NetworkApi> networks = [];
// //   List<NetworkApi> apiNetworks = [];

// //   // Step 1: Use cached data for fast UI rendering
// //   if (cachedNetworks != null) {
// //     try {
// //       List<dynamic> cachedBody = json.decode(cachedNetworks);
// //       networks =
// //           cachedBody.map((dynamic item) => NetworkApi.fromJson(item)).toList();
// //     } catch (e) {
// //       prefs.remove('networks');
// //     }
// //   }

// //   // Step 2: Fetch API data in the background
// //   try {
// //     final headers = await ApiService.getHeaders();

// //     final response = await https.get(
// //       Uri.parse('${ApiService.baseUrl}getNetworks'),
// //       headers: headers,
// //     );

// //     if (response.statusCode == 200) {
// //       List<dynamic> body = json.decode(response.body);
// //       apiNetworks =
// //           body.map((dynamic item) => NetworkApi.fromJson(item)).toList();

// //       // Step 3: Compare cached data with API data
// //       if (!listEquals(networks, apiNetworks)) {
// //         prefs.setString('networks', response.body);
// //         return apiNetworks;
// //       } else {}
// //     } else if (response.statusCode == 401 || response.statusCode == 403) {
// //       throw Exception('Authentication failed. Please login again.');
// //     } else {
// //       throw Exception('Something went wrong');
// //     }
// //   } catch (e) {
// //     if (networks.isEmpty) {
// //       rethrow; // Only throw if no cached data available
// //     }
// //   }

// //   return networks;
// // }

// // Future<List<NewsItemModel>> fetchContent(
// //     BuildContext context, int networkId) async {
// //   final prefs = await SharedPreferences.getInstance();
// //   final cachedContent = prefs.getString('content_$networkId');

// //   List<NewsItemModel> content = [];

// //   // Step 1: Use cached data for fast UI rendering
// //   if (cachedContent != null) {
// //     try {
// //       List<dynamic> cachedBody = json.decode(cachedContent);
// //       content = cachedBody
// //           .map((dynamic item) => NewsItemModel.fromJson(item))
// //           .toList();
// //       content.sort(
// //           (a, b) => safeParseInt(a.index).compareTo(safeParseInt(b.index)));
// //     } catch (e) {
// //       prefs.remove('content_$networkId');
// //     }
// //   }

// //   // Step 2: Fetch API data in the background and compare with cache
// //   try {
// //     final headers = await ApiService.getHeaders();

// //     final response = await https.get(
// //       Uri.parse('${ApiService.baseUrl}getAllContentsOfNetwork/$networkId'),
// //       headers: headers,
// //     );

// //     if (response.statusCode == 200) {
// //       List<dynamic> body = json.decode(response.body);
// //       List<NewsItemModel> apiContent =
// //           body.map((dynamic item) => NewsItemModel.fromJson(item)).toList();

// //       // Sorting API data
// //       apiContent.sort(
// //           (a, b) => safeParseInt(a.index).compareTo(safeParseInt(b.index)));

// //       // Step 3: Compare cached data with API data
// //       if (!listEquals(content, apiContent)) {
// //         prefs.setString('content_$networkId', json.encode(body));
// //         return apiContent;
// //       } else {}
// //     } else if (response.statusCode == 401 || response.statusCode == 403) {
// //       throw Exception('Something went wrong');
// //     } else {
// //       throw Exception('Something went wrong');
// //     }
// //   } catch (e) {
// //     if (content.isEmpty) {
// //       rethrow; // Only throw if no cached data available
// //     }
// //   }

// //   return content;
// // }

// // // Alternative simpler version if you want source_url and type
// // Future<Map<String, dynamic>> fetchMoviePlayLink(int movieId) async {

// //   final prefs = await SharedPreferences.getInstance();
// //   final cacheKey = 'movie_source_data_$movieId';
// //   final cachedSourceData = prefs.getString(cacheKey);

// //   // Check cache first
// //   if (cachedSourceData != null) {
// //     try {
// //       final Map<String, dynamic> cachedData = json.decode(cachedSourceData);
// //       return cachedData;
// //     } catch (e) {
// //       prefs.remove(cacheKey);
// //     }
// //   }

// //   try {
// //     final headers = await ApiService.getHeaders();
// //     final apiUrl = '${ApiService.baseUrl}getMoviePlayLinks/$movieId/0';

// //     final response = await https.get(
// //       Uri.parse(apiUrl),
// //       headers: headers,
// //     );

// //     if (response.statusCode == 200) {
// //       final List<dynamic> body = json.decode(response.body);

// //       if (body.isNotEmpty) {
// //         // Search for matching ID
// //         for (var item in body) {
// //           final Map<String, dynamic> itemMap = item as Map<String, dynamic>;
// //           final int itemId = safeParseInt(itemMap['id']);

// //           if (itemId == movieId) {
// //             String sourceUrl = safeParseString(itemMap['source_url']);
// //             int type = safeParseInt(itemMap['type']);
// //             int linkType = safeParseInt(itemMap['link_type']);

// //             // Handle YouTube IDs

// //             final sourceData = {
// //               'source_url': sourceUrl,
// //               'type': type,
// //               'link_type': linkType,
// //               'id': itemId,
// //               'name': safeParseString(itemMap['name']),
// //               'quality': safeParseString(itemMap['quality']),
// //             };

// //             // Cache the source data
// //             prefs.setString(cacheKey, json.encode(sourceData));
// //             return sourceData;
// //           }
// //         }

// //         // If no exact match, use first item
// //         final Map<String, dynamic> firstItem =
// //             body.first as Map<String, dynamic>;
// //         String sourceUrl = safeParseString(firstItem['source_url']);
// //         int type = safeParseInt(firstItem['type']);
// //         int linkType = safeParseInt(firstItem['link_type']);

// //         // if (sourceUrl.length == 11 && !sourceUrl.contains('http')) {
// //         //   sourceUrl = 'https://www.youtube.com/watch?v=$sourceUrl';
// //         // }

// //         final sourceData = {
// //           'source_url': sourceUrl,
// //           'type': type,
// //           'link_type': linkType,
// //           'id': safeParseInt(firstItem['id']),
// //           'name': safeParseString(firstItem['name']),
// //           'quality': safeParseString(firstItem['quality']),
// //         };

// //         prefs.setString(cacheKey, json.encode(sourceData));
// //         return sourceData;
// //       }
// //     }

// //     throw Exception('No valid source URL found');
// //   } catch (e) {
// //     rethrow;
// //   }
// // }

// // // Updated utility functions
// // Future<Color> fetchPaletteColor(String imageUrl) async {
// //   try {
// //     return await PaletteColorService().getSecondaryColor(imageUrl);
// //   } catch (e) {
// //     return Colors.grey; // Fallback color
// //   }
// // }

// // // Updated displayImage function with SVG support and better error handling
// // Widget displayImage(
// //   String imageUrl, {
// //   double? width,
// //   double? height,
// //   BoxFit fit = BoxFit.fill,
// // }) {
// //   if (imageUrl.isEmpty || imageUrl == 'localImage') {
// //     return Image.asset(localImage);
// //   }

// //   // Handle localhost URLs - replace with fallback
// //   if (imageUrl.contains('localhost')) {
// //     return Image.asset(localImage);
// //   }

// //   if (imageUrl.startsWith('data:image')) {
// //     // Handle base64-encoded images
// //     try {
// //       Uint8List imageBytes = _getImageFromBase64String(imageUrl);
// //       return Image.memory(
// //         imageBytes,
// //         fit: fit,
// //         width: width,
// //         height: height,
// //         errorBuilder: (context, error, stackTrace) {
// //           return _buildErrorWidget(width, height);
// //         },
// //       );
// //     } catch (e) {
// //       return _buildErrorWidget(width, height);
// //     }
// //   } else if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
// //     // Check if it's an SVG image
// //     if (imageUrl.toLowerCase().endsWith('.svg')) {
// //       return SvgPicture.network(
// //         imageUrl,
// //         width: width,
// //         height: height,
// //         fit: fit,
// //         placeholderBuilder: (context) {
// //           return _buildLoadingWidget(width, height);
// //         },
// //       );
// //     } else {
// //       // Handle regular URL images (PNG, JPG, etc.)
// //       return CachedNetworkImage(
// //         imageUrl: imageUrl,
// //         placeholder: (context, url) {
// //           return _buildLoadingWidget(width, height);
// //         },
// //         errorWidget: (context, url, error) {
// //           return _buildErrorWidget(width, height);
// //         },
// //         fit: fit,
// //         width: width,
// //         height: height,
// //         // Add timeout
// //         httpHeaders: {
// //           'User-Agent': 'Flutter App',
// //         },
// //       );
// //     }
// //   } else {
// //     // Fallback for invalid image data
// //     return _buildErrorWidget(width, height);
// //   }
// // }

// // // Helper widget for loading state
// // Widget _buildLoadingWidget(double? width, double? height) {
// //   return Container(
// //     width: width,
// //     height: height,
// //     child: Center(
// //       child: CircularProgressIndicator(
// //         strokeWidth: 2,
// //         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
// //       ),
// //     ),
// //   );
// // }

// // // Helper widget for error state
// // Widget _buildErrorWidget(double? width, double? height) {
// //   return Image.asset(localImage);
// // }

// // // Helper function to decode base64 images
// // Uint8List _getImageFromBase64String(String base64String) {
// //   return base64Decode(base64String.split(',').last);
// // }

// // // Error handling helper for authentication errors
// // class AuthErrorHandler {
// //   static void handleAuthError(BuildContext context, dynamic error) {
// //     if (error.toString().contains('Authentication failed') ||
// //         error.toString().contains('Auth key not found')) {
// //       // Clear auth data
// //       AuthManager.clearAuthKey();

// //       // Navigate to login screen
// //       Navigator.pushAndRemoveUntil(
// //         context,
// //         MaterialPageRoute(builder: (context) => LoginScreen()),
// //         (route) => false,
// //       );

// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('Session expired. Please login again.'),
// //           backgroundColor: Colors.red,
// //           duration: Duration(seconds: 3),
// //         ),
// //       );
// //     }
// //   }
// // }

// // // Updated SubVod widget with proper error handling
// // class SubVod extends StatefulWidget {
// //   final Function(bool)? onFocusChange;

// //   const SubVod({Key? key, this.onFocusChange, required FocusNode focusNode})
// //       : super(key: key);

// //   @override
// //   _SubVodState createState() => _SubVodState();
// // }

// // class _SubVodState extends State<SubVod> {
// //   List<NetworkApi> _networks = [];
// //   bool _isLoading = true;
// //   bool _cacheLoaded = false;
// //   String _errorMessage = '';
// //   late FocusNode firstSubVodFocusNode;

// //   @override
// //   void initState() {
// //     super.initState();

// //     firstSubVodFocusNode = FocusNode()
// //       ..onKey = (node, event) {
// //         if (event is RawKeyDownEvent) {
// //           if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
// //             context.read<FocusProvider>().requestMusicItemFocus(context);
// //             return KeyEventResult.handled;
// //           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
// //             context
// //                 .read<FocusProvider>()
// //                 .requestFirstMoviesFocus(); // Added missing parentheses
// //             return KeyEventResult.handled;
// //           }
// //         }
// //         return KeyEventResult.ignored;
// //       };

// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       context
// //           .read<FocusProvider>()
// //           .setFirstSubVodFocusNode(firstSubVodFocusNode);
// //     });

// //     _initializeData();
// //   }

// //   Future<void> _initializeData() async {
// //     // Load cached data first
// //     await _loadCachedNetworks();

// //     // Then fetch fresh data
// //     await _fetchNetworksInBackground();

// //     // Ensure loading is turned off even if both methods fail
// //     if (mounted && _isLoading) {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   Future<void> _loadCachedNetworks() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final cachedNetworks = prefs.getString('networks');

// //       if (cachedNetworks != null && cachedNetworks.isNotEmpty) {
// //         List<dynamic> cachedBody = json.decode(cachedNetworks);
// //         List<NetworkApi> networks = cachedBody
// //             .map((dynamic item) => NetworkApi.fromJson(item))
// //             .toList();

// //         if (mounted) {
// //           setState(() {
// //             _networks = networks;
// //             _isLoading = false;
// //             _cacheLoaded = true;
// //             _errorMessage = '';
// //           });
// //         }
// //       } else {}
// //     } catch (e) {
// //       if (mounted) {
// //         setState(() {
// //           _errorMessage = 'Error loading cached data: $e';
// //         });
// //       }
// //     }
// //   }

// //   Future<void> _fetchNetworksInBackground() async {
// //     try {
// //       final fetchedNetworks = await fetchNetworks(context);

// //       if (!mounted) return;

// //       // Update UI if data is different or if we don't have cached data
// //       if (!listEquals(_networks, fetchedNetworks) || !_cacheLoaded) {
// //         setState(() {
// //           _networks = fetchedNetworks;
// //           _isLoading = false;
// //           _errorMessage = '';
// //         });
// //       } else {
// //         setState(() {
// //           _isLoading = false;
// //         });
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         setState(() {
// //           _isLoading = false;
// //           if (!_cacheLoaded || _networks.isEmpty) {
// //             _errorMessage = 'Something went wrong';
// //           }
// //         });
// //       }

// //       // Handle authentication errors
// //       AuthErrorHandler.handleAuthError(context, e);
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
// //       Color backgroundColor = colorProvider.isItemFocused
// //           ? colorProvider.dominantColor.withOpacity(0.3)
// //           : Colors.black87;

// //       return Scaffold(
// //         backgroundColor: Colors.transparent,
// //         body: _buildBody(),
// //       );
// //     });
// //   }

// //   Widget _buildBody() {
// //     if (_isLoading) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             LoadingIndicator(),
// //             SizedBox(height: 20),
// //             Text(
// //               'Loading Networks...',
// //               style: TextStyle(color: Colors.white, fontSize: 16),
// //             ),
// //           ],
// //         ),
// //       );
// //     }

// //     if (_errorMessage.isNotEmpty && _networks.isEmpty) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(Icons.error_outline, color: Colors.red, size: 48),
// //             SizedBox(height: 16),
// //             Text(
// //               'Error Loading Networks',
// //               style: TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.bold),
// //             ),
// //             SizedBox(height: 8),
// //             Padding(
// //               padding: EdgeInsets.symmetric(horizontal: 40),
// //               child: Text(
// //                 _errorMessage,
// //                 textAlign: TextAlign.center,
// //                 style: TextStyle(color: Colors.white70, fontSize: 14),
// //               ),
// //             ),
// //             SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: () {
// //                 setState(() {
// //                   _isLoading = true;
// //                   _errorMessage = '';
// //                 });
// //                 _fetchNetworksInBackground();
// //               },
// //               child: Text('Retry'),
// //             ),
// //           ],
// //         ),
// //       );
// //     }

// //     if (_networks.isEmpty) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(Icons.tv_off, color: Colors.grey, size: 48),
// //             SizedBox(height: 16),
// //             Text(
// //               'No Networks Available',
// //               style: TextStyle(color: Colors.white, fontSize: 18),
// //             ),
// //             SizedBox(height: 8),
// //             Text(
// //               'Something went wrong',
// //               style: TextStyle(color: Colors.white70, fontSize: 14),
// //             ),
// //             SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: () {
// //                 setState(() {
// //                   _isLoading = true;
// //                   _errorMessage = '';
// //                 });
// //                 _fetchNetworksInBackground();
// //               },
// //               child: Text('Refresh'),
// //             ),
// //           ],
// //         ),
// //       );
// //     }

// //     return _buildNetworksList();
// //   }

// //   Widget _buildNetworksList() {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Consumer<ColorProvider>(builder: (context, colorProvider, child) {
// //           return Padding(
// //             padding: const EdgeInsets.all(8.0),
// //             child: Text(
// //               'Contents',
// //               style: TextStyle(
// //                 fontSize: Headingtextsz,
// //                 fontWeight: FontWeight.bold,
// //                 color: Colors.white,
// //               ),
// //             ),
// //           );
// //         }),
// //         Expanded(
// //           child: ListView.builder(
// //             scrollDirection: Axis.horizontal,
// //             itemCount: _networks.length,
// //             itemBuilder: (context, index) {
// //               final network = _networks[index];
// //               final isFirst = index == 0;

// //               final focusNode = isFirst ? firstSubVodFocusNode : FocusNode()
// //                 ..onKey = (node, event) {
// //                   if (event is RawKeyDownEvent) {
// //                     if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
// //                       context
// //                           .read<FocusProvider>()
// //                           .requestMusicItemFocus(context);
// //                       return KeyEventResult.handled;
// //                     } else if (event.logicalKey ==
// //                         LogicalKeyboardKey.arrowDown) {
// //                       context.read<FocusProvider>().requestFirstMoviesFocus();
// //                       return KeyEventResult.handled;
// //                     }
// //                   }
// //                   return KeyEventResult.ignored;
// //                 };

// //               return FocussableSubvodWidget(
// //                 imageUrl: network.logo,
// //                 name: network.name,
// //                 focusNode: focusNode,
// //                 onTap: () async {
// //                   Navigator.push(
// //                     context,
// //                     MaterialPageRoute(
// //                       builder: (context) =>
// //                           ContentScreen(networkId: network.id),
// //                     ),
// //                   );
// //                 },
// //                 fetchPaletteColor: fetchPaletteColor,
// //               );
// //             },
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     firstSubVodFocusNode.dispose();
// //     super.dispose();
// //   }
// // }

// // // Updated VOD widget
// // class VOD extends StatefulWidget {
// //   @override
// //   _VODState createState() => _VODState();
// // }

// // class _VODState extends State<VOD> {
// //   List<NetworkApi> _networks = [];
// //   bool _isLoading = true;
// //   bool _cacheLoaded = false;
// //   Map<int, FocusNode> firstRowFocusNodes = {};

// //   @override
// //   void initState() {
// //     super.initState();

// //     // Initialize focus nodes for first row items
// //     for (int i = 0; i < 5; i++) {
// //       final focusNode = FocusNode();
// //       firstRowFocusNodes[i] = focusNode;

// //       focusNode.onKey = (node, event) {
// //         if (event is RawKeyDownEvent) {
// //           switch (event.logicalKey) {
// //             case LogicalKeyboardKey.arrowUp:
// //               context.read<FocusProvider>().requestVodMenuFocus();
// //               return KeyEventResult.handled;
// //             case LogicalKeyboardKey.arrowLeft:
// //               if (i > 0) {
// //                 firstRowFocusNodes[i - 1]?.requestFocus();
// //                 return KeyEventResult.handled;
// //               }
// //               return KeyEventResult.ignored;
// //             case LogicalKeyboardKey.arrowRight:
// //               if (i < 4 && i < _networks.length - 1) {
// //                 firstRowFocusNodes[i + 1]?.requestFocus();
// //                 return KeyEventResult.handled;
// //               }
// //               return KeyEventResult.ignored;
// //             case LogicalKeyboardKey.arrowDown:
// //               if (_networks.length > 5) {
// //                 FocusScope.of(context).nextFocus();
// //                 return KeyEventResult.handled;
// //               }
// //               return KeyEventResult.ignored;
// //           }
// //         }
// //         return KeyEventResult.ignored;
// //       };
// //     }

// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (firstRowFocusNodes.containsKey(0)) {
// //         context
// //             .read<FocusProvider>()
// //             .setFirstVodBannerFocusNode(firstRowFocusNodes[0]!);
// //         firstRowFocusNodes[0]?.requestFocus();
// //       }
// //     });

// //     _loadCachedNetworks();
// //     _fetchNetworksInBackground();
// //   }

// //   Future<void> _loadCachedNetworks() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final cachedNetworks = prefs.getString('networks');

// //     if (cachedNetworks != null) {
// //       try {
// //         List<dynamic> cachedBody = json.decode(cachedNetworks);
// //         setState(() {
// //           _networks = cachedBody
// //               .map((dynamic item) => NetworkApi.fromJson(item))
// //               .toList();
// //           _isLoading = false;
// //           _cacheLoaded = true;
// //         });
// //       } catch (e) {}
// //     }
// //   }

// //   Future<void> _fetchNetworksInBackground() async {
// //     try {
// //       final fetchedNetworks = await fetchNetworks(context);

// //       if (!listEquals(_networks, fetchedNetworks)) {
// //         setState(() {
// //           _networks = fetchedNetworks;
// //         });
// //       }
// //     } catch (e) {
// //       AuthErrorHandler.handleAuthError(context, e);

// //       if (!_cacheLoaded) {
// //         setState(() {
// //           _isLoading = false;
// //         });
// //       }
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return PopScope(
// //       canPop: false,
// //       onPopInvoked: (didPop) {
// //         if (!didPop) {
// //           context.read<FocusProvider>().requestWatchNowFocus();
// //         }
// //       },
// //       child: Consumer<ColorProvider>(builder: (context, colorProvider, child) {
// //         Color backgroundColor = colorProvider.isItemFocused
// //             ? colorProvider.dominantColor
// //             : cardColor;

// //         return Scaffold(
// //           backgroundColor: backgroundColor,
// //           body: _isLoading
// //               ? Center(child: LoadingIndicator())
// //               : _networks.isNotEmpty
// //                   ? Container(
// //                       color: Colors.black54, child: _buildNetworksList())
// //                   : Center(
// //                       child: Text('No Networks Available',
// //                           style: TextStyle(color: Colors.white, fontSize: 18))),
// //         );
// //       }),
// //     );
// //   }

// //   Widget _buildNetworksList() {
// //     return GridView.builder(
// //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //         crossAxisCount: 5,
// //         childAspectRatio: 0.8,
// //       ),
// //       itemCount: _networks.length,
// //       itemBuilder: (context, index) {
// //         final network = _networks[index];
// //         final isFirstRow = index < 5;

// //         return FocussableSubvodWidget(
// //           focusNode: isFirstRow ? firstRowFocusNodes[index] : null,
// //           imageUrl: network.logo,
// //           name: network.name,
// //           onTap: () async {
// //             Navigator.push(
// //               context,
// //               MaterialPageRoute(
// //                 builder: (context) => ContentScreen(networkId: network.id),
// //               ),
// //             );
// //           },
// //           fetchPaletteColor: fetchPaletteColor,
// //         );
// //       },
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     firstRowFocusNodes.values.forEach((node) => node.dispose());
// //     super.dispose();
// //   }
// // }

// // // Updated ContentScreen widget
// // class ContentScreen extends StatefulWidget {
// //   final int networkId;

// //   ContentScreen({required this.networkId});

// //   @override
// //   _ContentScreenState createState() => _ContentScreenState();
// // }

// // // Updated ContentScreen with better debug logging
// // class _ContentScreenState extends State<ContentScreen> {
// //   List<NewsItemModel> _content = [];
// //   bool _isLoading = true;
// //   bool _cacheLoaded = false;
// //   String _errorMessage = '';
// //   FocusNode firstItemFocusNode = FocusNode();

// //   @override
// //   void initState() {
// //     super.initState();

// //     _initializeContent();

// //     Future.delayed(Duration(milliseconds: 50), () async {
// //       firstItemFocusNode.requestFocus();
// //     });
// //   }

// //   Future<void> _initializeContent() async {
// //     // Load cached data first
// //     await _loadCachedContent();

// //     // Then fetch fresh data
// //     await _fetchContentInBackground();

// //     // Ensure loading is turned off even if both methods fail
// //     if (mounted && _isLoading) {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   Future<void> _loadCachedContent() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final cachedContent = prefs.getString('content_${widget.networkId}');

// //       if (cachedContent != null && cachedContent.isNotEmpty) {
// //         List<dynamic> cachedBody = json.decode(cachedContent);
// //         List<NewsItemModel> content = cachedBody
// //             .map((dynamic item) => NewsItemModel.fromJson(item))
// //             .toList();

// //         if (mounted) {
// //           setState(() {
// //             _content = content;
// //             _isLoading = false;
// //             _cacheLoaded = true;
// //             _errorMessage = '';
// //           });
// //         }

// //         // Debug: Print first few items
// //         for (int i = 0; i < (_content.length > 2 ? 2 : _content.length); i++) {
// //           final item = _content[i];
// //         }
// //       } else {}
// //     } catch (e) {
// //       if (mounted) {
// //         setState(() {
// //           _errorMessage = 'Error loading cached data: $e';
// //         });
// //       }
// //     }
// //   }

// //   Future<void> _fetchContentInBackground() async {
// //     try {
// //       final fetchedContent = await fetchContent(context, widget.networkId);

// //       if (!mounted) return;

// //       // Debug: Print API response details
// //       for (int i = 0;
// //           i < (fetchedContent.length > 2 ? 2 : fetchedContent.length);
// //           i++) {
// //         final item = fetchedContent[i];
// //       }

// //       // Update UI if data is different or if we don't have cached data
// //       if (!listEquals(_content, fetchedContent) || !_cacheLoaded) {
// //         setState(() {
// //           _content = fetchedContent;
// //           _isLoading = false;
// //           _errorMessage = '';
// //         });
// //       } else {
// //         setState(() {
// //           _isLoading = false;
// //         });
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         setState(() {
// //           _isLoading = false;
// //           if (!_cacheLoaded || _content.isEmpty) {
// //             _errorMessage = 'Something went wrong';
// //           }
// //         });
// //       }

// //       // Handle authentication errors
// //       AuthErrorHandler.handleAuthError(context, e);
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
// //       Color backgroundColor = colorProvider.isItemFocused
// //           ? colorProvider.dominantColor.withOpacity(0.3)
// //           : Colors.black87;

// //       return Scaffold(
// //         backgroundColor: backgroundColor,
// //         body: _buildBody(),
// //       );
// //     });
// //   }

// //   Widget _buildBody() {
// //     if (_isLoading) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             CircularProgressIndicator(),
// //             SizedBox(height: 20),
// //             Text(
// //               'Loading Content...',
// //               style: TextStyle(color: Colors.white, fontSize: 16),
// //             ),
// //           ],
// //         ),
// //       );
// //     }

// //     if (_errorMessage.isNotEmpty && _content.isEmpty) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(Icons.error_outline, color: Colors.red, size: 48),
// //             SizedBox(height: 16),
// //             Text(
// //               'Error Loading Content',
// //               style: TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.bold),
// //             ),
// //             SizedBox(height: 8),
// //             Padding(
// //               padding: EdgeInsets.symmetric(horizontal: 40),
// //               child: Text(
// //                 _errorMessage,
// //                 textAlign: TextAlign.center,
// //                 style: TextStyle(color: Colors.white70, fontSize: 14),
// //               ),
// //             ),
// //             SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: () {
// //                 setState(() {
// //                   _isLoading = true;
// //                   _errorMessage = '';
// //                 });
// //                 _fetchContentInBackground();
// //               },
// //               child: Text('Retry'),
// //             ),
// //           ],
// //         ),
// //       );
// //     }

// //     if (_content.isEmpty) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(Icons.movie_outlined, color: Colors.grey, size: 48),
// //             SizedBox(height: 16),
// //             Text(
// //               'No Content Available',
// //               style: TextStyle(color: Colors.white, fontSize: 18),
// //             ),
// //             SizedBox(height: 8),
// //             Text(
// //               'This network has no content to display',
// //               style: TextStyle(color: Colors.white70, fontSize: 14),
// //             ),
// //             SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: () {
// //                 setState(() {
// //                   _isLoading = true;
// //                   _errorMessage = '';
// //                 });
// //                 _fetchContentInBackground();
// //               },
// //               child: Text('Refresh'),
// //             ),
// //           ],
// //         ),
// //       );
// //     }

// //     return _buildContentGrid();
// //   }

// //   Widget _buildContentGrid() {
// //     // Sort content by index
// //     _content
// //         .sort((a, b) => safeParseInt(a.index).compareTo(safeParseInt(b.index)));

// //     return Padding(
// //       padding: EdgeInsets.symmetric(
// //           horizontal: screenwdt * 0.03, vertical: screenhgt * 0.01),
// //       child: GridView.builder(
// //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //             crossAxisCount: 5, childAspectRatio: 0.8),
// //         itemCount: _content.length,
// //         itemBuilder: (context, index) {
// //           final contentItem = _content[index];

// //           // Debug print for each item being built

// //           // Choose the best image URL (prefer poster over banner)
// //           String imageUrl = '';
// //           if (contentItem.poster.isNotEmpty &&
// //               contentItem.poster != 'localImage') {
// //             imageUrl = contentItem.poster;
// //           } else if (contentItem.banner.isNotEmpty &&
// //               contentItem.banner != 'localImage') {
// //             imageUrl = contentItem.banner;
// //           } else if (contentItem.image.isNotEmpty &&
// //               contentItem.image != 'localImage') {
// //             imageUrl = contentItem.image;
// //           } else if (contentItem.thumbnail_high.isNotEmpty &&
// //               contentItem.thumbnail_high != 'localImage') {
// //             imageUrl = contentItem.thumbnail_high;
// //           } else {
// //             imageUrl = 'localImage';
// //           }

// //           return FocussableSubvodWidget(
// //             focusNode: index == 0 ? firstItemFocusNode : null,
// //             imageUrl: imageUrl,
// //             name: contentItem.name,
// //             onTap: () async {
// //               int contentId = int.tryParse(contentItem.id) ?? 0;

// //               Navigator.push(
// //                 context,
// //                 MaterialPageRoute(
// //                   builder: (context) => DetailsPage(
// //                     id: contentId,
// //                     channelList: _content,
// //                     source: 'isContentScreenViaDetailsPageChannelList',
// //                     banner: contentItem.banner,
// //                     name: contentItem.name,
// //                   ),
// //                 ),
// //               );
// //             },
// //             fetchPaletteColor: fetchPaletteColor,
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     firstItemFocusNode.dispose();
// //     super.dispose();
// //   }
// // }

// // // Updated DetailsPage widget with proper int handling
// // class DetailsPage extends StatefulWidget {
// //   final int id;
// //   final List<NewsItemModel> channelList;
// //   final String source;
// //   final String banner;
// //   final String name;

// //   DetailsPage({
// //     required this.id,
// //     required this.channelList,
// //     required this.source,
// //     required this.banner,
// //     required this.name,
// //   });

// //   @override
// //   _DetailsPageState createState() => _DetailsPageState();
// // }

// // class _DetailsPageState extends State<DetailsPage> {
// //   final SocketService _socketService = SocketService();
// //   MovieDetailsApi? _movieDetails;
// //   final int _maxRetries = 3;
// //   final int _retryDelay = 5; // seconds
// //   bool _shouldContinueLoading = true;
// //   bool _isLoading = false;
// //   bool _isVideoPlaying = false;
// //   Timer? _timer;
// //   bool _isReturningFromVideo = false;
// //   FocusNode firstItemFocusNode = FocusNode();
// //   Color headingColor = Colors.grey;

// //   @override
// //   void initState() {
// //     super.initState();

// //     _socketService.initSocket();
// //     checkServerStatus();

// //     Future.delayed(Duration(milliseconds: 100), () async {
// //       await _loadCachedAndFetchMovieDetails(widget.id);
// //       if (_movieDetails != null) {
// //         _fetchAndSetHeadingColor(_movieDetails!.banner);
// //       }
// //       firstItemFocusNode.requestFocus();
// //     });
// //   }

// //   @override
// //   void dispose() {
// //     _socketService.dispose();
// //     _timer?.cancel();
// //     firstItemFocusNode.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _fetchAndSetHeadingColor(String bannerUrl) async {
// //     try {
// //       Color paletteColor = await fetchPaletteColor(bannerUrl);
// //       setState(() {
// //         headingColor = paletteColor;
// //       });
// //     } catch (e) {}
// //   }

// //   Future<void> _loadCachedAndFetchMovieDetails(int contentId) async {
// //     setState(() {
// //       _isLoading = true;
// //     });

// //     try {
// //       final movieDetails = await fetchMovieDetails(context, contentId);

// //       if (!mounted) return;

// //       setState(() {
// //         _movieDetails = movieDetails;
// //         _isLoading = false;
// //       });

// //       // Fetch updated heading color when details are loaded
// //       if (movieDetails.banner.isNotEmpty) {
// //         _fetchAndSetHeadingColor(movieDetails.banner);
// //       }
// //     } catch (e) {
// //       AuthErrorHandler.handleAuthError(context, e);

// //       if (mounted) {
// //         setState(() {
// //           _isLoading = false;
// //           _movieDetails = null;
// //         });
// //       }
// //     }
// //   }

// //   void checkServerStatus() {
// //     Timer.periodic(Duration(seconds: 10), (timer) {
// //       if (!_socketService.socket.connected) {
// //         _socketService.initSocket();
// //       }
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.black87,
// //       body: _isLoading
// //           ? Center(child: LoadingIndicator())
// //           : _isReturningFromVideo
// //               ? Center(
// //                   child: Text(
// //                     '',
// //                     style: TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 20,
// //                         fontWeight: FontWeight.bold),
// //                   ),
// //                 )
// //               : _movieDetails != null
// //                   ? _buildMovieDetailsUI(context, _movieDetails!)
// //                   : Center(
// //                       child: Text(
// //                         '...',
// //                         style: TextStyle(color: Colors.white, fontSize: 18),
// //                       ),
// //                     ),
// //     );
// //   }

// //   Widget _buildMovieDetailsUI(
// //       BuildContext context, MovieDetailsApi movieDetails) {
// //     return Container(
// //       child: Stack(
// //         children: [
// //           // Only show banner if status is active (1)
// //           if (movieDetails.isActive)
// //             displayImage(
// //               movieDetails.banner ?? localImage,
// //               width: screenwdt,
// //               height: screenhgt,
// //             ),
// //           Padding(
// //             padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.03),
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 SizedBox(height: screenhgt * 0.05),
// //                 Container(
// //                   child: Text(
// //                     movieDetails.name,
// //                     style: TextStyle(
// //                       color: headingColor,
// //                       fontSize: Headingtextsz * 1.5,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //                 Spacer(),
// //                 // Status info
// //                 if (!movieDetails.isActive)
// //                   Container(
// //                     padding: EdgeInsets.all(10),
// //                     decoration: BoxDecoration(
// //                       color: Colors.red.withOpacity(0.7),
// //                       borderRadius: BorderRadius.circular(5),
// //                     ),
// //                     child: Text(
// //                       'Content not available (Status: ${movieDetails.status})',
// //                       style: TextStyle(color: Colors.white, fontSize: 16),
// //                     ),
// //                   ),
// //                 Expanded(
// //                   child: ListView.builder(
// //                     scrollDirection: Axis.horizontal,
// //                     itemCount: 1,
// //                     itemBuilder: (context, index) {
// //                       return FocussableSubvodWidget(
// //                         focusNode: firstItemFocusNode,
// //                         imageUrl: movieDetails.poster ?? localImage,
// //                         name: '',
// //                         onTap: () => movieDetails.isActive
// //                             ? _playVideo(movieDetails)
// //                             : _showInactiveContentMessage(),
// //                         fetchPaletteColor: fetchPaletteColor,
// //                       );
// //                     },
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           )
// //         ],
// //       ),
// //     );
// //   }

// //     bool isYoutubeUrl(String? url) {
// //     if (url == null || url.isEmpty) {
// //       return false;
// //     }

// //     url = url.toLowerCase().trim();

// //     // First check if it's a YouTube ID (exactly 11 characters)
// //     bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url);
// //     if (isYoutubeId) {
// //       return true;
// //     }

// //     // Then check for regular YouTube URLs
// //     bool isYoutubeUrl = url.contains('youtube.com') ||
// //         url.contains('youtu.be') ||
// //         url.contains('youtube.com/shorts/');
// //     if (isYoutubeUrl) {
// //       return true;
// //     }

// //     return false;
// //   }

// //   String formatUrl(String url, {Map<String, String>? params}) {
// //     if (url.isEmpty) {
// //       throw Exception("Empty URL provided");
// //     }

// //     // // Handle YouTube ID by converting to full URL if needed
// //     // if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url)) {
// //     //   url = "https://www.youtube.com/watch?v=$url";
// //     // }

// //     // Remove any existing query parameters
// //     // url = url.split('?')[0];

// //     // Add new query parameters
// //     // if (params != null && params.isNotEmpty) {
// //     //   url += '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&');
// //     // }

// //     return url;
// //   }

// //   void _showInactiveContentMessage() {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text('This content is currently not available'),
// //         backgroundColor: Colors.red,
// //       ),
// //     );
// //   }

// //   Future<void> _playVideo(MovieDetailsApi movieDetails) async {

// //     if (_isVideoPlaying) {
// //       return;
// //     }

// //     setState(() {
// //       _isLoading = true;
// //       _isVideoPlaying = true;
// //     });

// //     _shouldContinueLoading = true;

// //     try {
// //       // Step 1: Fetch movie play link
// //       Map<String, dynamic> playLinkData = await fetchMoviePlayLink(widget.id);
// //       String originalUrl = playLinkData['source_url'] ?? '';

// //       // Step 2: Get original URL
// //       String updatedUrl = playLinkData['source_url'] ?? '';

// //       if (originalUrl.isEmpty) {
// //         throw Exception('Original URL is empty');
// //       }

// //       // Step 3: Update URL using socket service

// //             if (isYoutubeUrl(updatedUrl)) {
// //         updatedUrl = await _socketService.getUpdatedUrl(updatedUrl);
// //       }

// //       // updatedUrl = await _socketService.getUpdatedUrl(originalUrl);

// //       if (updatedUrl.isEmpty) {
// //         throw Exception('Updated URL is empty');
// //       }

// //       // Step 4: URL validation
// //       bool isValidUrl = Uri.tryParse(updatedUrl) != null;

// //       if (updatedUrl.startsWith('http://') ||
// //           updatedUrl.startsWith('https://')) {
// //       } else {
// //       }

// //       // Step 5: Navigation check

// //       if (!_shouldContinueLoading) {
// //         return;
// //       }

// //       if (!mounted) {
// //         return;
// //       }

// //       // Step 6: Navigate to VideoScreen

// //       bool liveStatus = false;

// //       if (_shouldContinueLoading) {
// //         await Navigator.push(
// //           context,
// //           MaterialPageRoute(
// //             builder: (context) {
// //               return VideoScreen(
// //                 videoUrl: updatedUrl,
// //                 videoId: widget.id,
// //                 channelList: widget.channelList,
// //                 videoType: '',
// //                 bannerImageUrl: widget.banner,
// //                 startAtPosition: Duration.zero,
// //                 isLive: false,
// //                 isVOD: true,
// //                 isBannerSlider: false,
// //                 source: widget.source,
// //                 isSearch: false,
// //                 unUpdatedUrl: originalUrl,
// //                 name: widget.name,
// //                 seasonId: null,
// //                 isLastPlayedStored: false,
// //                 liveStatus: liveStatus,
// //               );
// //             },
// //           ),
// //         );
// //       }

// //       // Update UI after returning
// //       setState(() {
// //         _isLoading = false;
// //         _isReturningFromVideo = true;
// //       });

// //       setState(() {
// //         _isReturningFromVideo = false;
// //       });
// //     } catch (e, stackTrace) {

// //       _handleVideoError(context);
// //       AuthErrorHandler.handleAuthError(context, e);
// //     } finally {
// //       setState(() {
// //         _isLoading = false;
// //         _isVideoPlaying = false;
// //       });
// //     }
// //   }

// //   void _handleVideoError(BuildContext context) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text('Something Went Wrong', style: TextStyle(fontSize: 20)),
// //         backgroundColor: Colors.red,
// //         duration: Duration(seconds: 3),
// //       ),
// //     );
// //   }
// // }

// import 'dart:async';
// import 'dart:convert';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../video_widget/socket_service.dart';
// import '../../video_widget/video_screen.dart';
// import '../../widgets/models/news_item_model.dart';
// import '../../widgets/small_widgets/loading_indicator.dart';
// import '../../widgets/utils/color_service.dart';
// import 'focussable_subvod_widget.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// // API Service class for consistent header management
// class ApiService {
//   static Future<Map<String, String>> getHeaders() async {
//     await AuthManager.initialize();
//     String authKey = AuthManager.authKey;

//     if (authKey.isEmpty) {
//       throw Exception('Auth key not found. Please login again.');
//     }

//     return {
//       'auth-key': authKey, // Updated header name
//       'Accept': 'application/json',
//       'Content-Type': 'application/json',
//     };
//   }

//   static String get baseUrl => 'https://acomtv.coretechinfo.com/public/api/';
// }

// // Helper function to safely parse integers from dynamic values
// int safeParseInt(dynamic value, {int defaultValue = 0}) {
//   if (value == null) return defaultValue;

//   if (value is int) {
//     return value;
//   } else if (value is String) {
//     return int.tryParse(value) ?? defaultValue;
//   } else if (value is double) {
//     return value.toInt();
//   }

//   return defaultValue;
// }

// // Helper function to safely parse strings
// String safeParseString(dynamic value, {String defaultValue = ''}) {
//   if (value == null) return defaultValue;
//   return value.toString();
// }

// // Updated NetworkApi model with proper int handling
// class NetworkApi {
//   final int id; // Now properly int
//   final String name;
//   final String logo;
//   final int networksOrder; // Changed to int

//   NetworkApi({
//     required this.id,
//     required this.name,
//     required this.logo,
//     required this.networksOrder,
//   });

//   factory NetworkApi.fromJson(Map<String, dynamic> json) {
//     return NetworkApi(
//       id: safeParseInt(json['id']), // Safe int parsing
//       name: safeParseString(json['name'], defaultValue: 'No Name'),
//       logo: safeParseString(json['logo'], defaultValue: 'localImage'),
//       networksOrder: safeParseInt(json['networks_order']), // Now int
//     );
//   }

//   // Override equality for listEquals comparison
//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is NetworkApi &&
//         other.id == id &&
//         other.name == name &&
//         other.logo == logo &&
//         other.networksOrder == networksOrder;
//   }

//   @override
//   int get hashCode =>
//       id.hashCode ^ name.hashCode ^ logo.hashCode ^ networksOrder.hashCode;
// }

// // Updated MovieDetailsApi model with proper int handling
// class MovieDetailsApi {
//   final int id; // Now properly int
//   final String name;
//   final String banner;
//   final String poster;
//   final String genres;
//   final int status; // Changed from String to int

//   MovieDetailsApi({
//     required this.id,
//     required this.name,
//     required this.banner,
//     required this.poster,
//     required this.genres,
//     required this.status,
//   });

//   factory MovieDetailsApi.fromJson(Map<String, dynamic> json) {
//     return MovieDetailsApi(
//       id: safeParseInt(json['id']), // Safe int parsing
//       name: safeParseString(json['name'], defaultValue: 'No Name'),
//       banner: safeParseString(json['banner'], defaultValue: 'localImage'),
//       poster: safeParseString(json['poster'], defaultValue: 'localImage'),
//       genres: safeParseString(json['genres'], defaultValue: 'Unknown'),
//       status: safeParseInt(json['status']), // Now int instead of string
//     );
//   }

//   // Helper method to check if movie is active
//   bool get isActive => status == 1;

//   // Override equality for comparison
//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is MovieDetailsApi &&
//         other.id == id &&
//         other.name == name &&
//         other.banner == banner &&
//         other.poster == poster &&
//         other.genres == genres &&
//         other.status == status;
//   }

//   @override
//   int get hashCode =>
//       id.hashCode ^
//       name.hashCode ^
//       banner.hashCode ^
//       poster.hashCode ^
//       genres.hashCode ^
//       status.hashCode;
// }

// // Updated fetch functions with proper error handling

// Future<MovieDetailsApi> fetchMovieDetails(
//     BuildContext context, int contentId) async {
//   final prefs = await SharedPreferences.getInstance();
//   final cachedMovieDetails = prefs.getString('movie_details_$contentId');

//   // Step 1: Return cached data immediately if available
//   if (cachedMovieDetails != null) {
//     try {
//       final Map<String, dynamic> body = json.decode(cachedMovieDetails);
//       return MovieDetailsApi.fromJson(body);
//     } catch (e) {
//       // Clear corrupted cache
//       prefs.remove('movie_details_$contentId');
//     }
//   }

//   // Step 2: Fetch API data if no cache is available
//   try {
//     final headers = await ApiService.getHeaders();

//     final response = await https.get(
//       Uri.parse('${ApiService.baseUrl}getMovieDetails/$contentId'),
//       headers: headers,
//     );

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> body = json.decode(response.body);
//       final movieDetails = MovieDetailsApi.fromJson(body);

//       // Step 3: Cache the fetched data
//       prefs.setString('movie_details_$contentId', response.body);

//       return movieDetails;
//     } else if (response.statusCode == 401 || response.statusCode == 403) {
//       throw Exception('Something went wrong');
//     } else {
//       throw Exception('Something went wrong');
//     }
//   } catch (e) {
//     rethrow;
//   }
// }

// Future<List<NetworkApi>> fetchNetworks(BuildContext context) async {
//   final prefs = await SharedPreferences.getInstance();
//   final cachedNetworks = prefs.getString('networks');

//   List<NetworkApi> networks = [];
//   List<NetworkApi> apiNetworks = [];

//   // Step 1: Use cached data for fast UI rendering
//   if (cachedNetworks != null) {
//     try {
//       List<dynamic> cachedBody = json.decode(cachedNetworks);
//       networks =
//           cachedBody.map((dynamic item) => NetworkApi.fromJson(item)).toList();
//     } catch (e) {
//       prefs.remove('networks');
//     }
//   }

//   // Step 2: Fetch API data in the background
//   try {
//     final headers = await ApiService.getHeaders();

//     final response = await https.get(
//       Uri.parse('${ApiService.baseUrl}getNetworks'),
//       headers: headers,
//     );

//     if (response.statusCode == 200) {
//       List<dynamic> body = json.decode(response.body);
//       apiNetworks =
//           body.map((dynamic item) => NetworkApi.fromJson(item)).toList();

//       // Step 3: Compare cached data with API data
//       if (!listEquals(networks, apiNetworks)) {
//         prefs.setString('networks', response.body);
//         return apiNetworks;
//       } else {}
//     } else if (response.statusCode == 401 || response.statusCode == 403) {
//       throw Exception('Authentication failed. Please login again.');
//     } else {
//       throw Exception('Something went wrong');
//     }
//   } catch (e) {
//     if (networks.isEmpty) {
//       rethrow; // Only throw if no cached data available
//     }
//   }

//   return networks;
// }

// Future<List<NewsItemModel>> fetchContent(
//     BuildContext context, int networkId) async {
//   final prefs = await SharedPreferences.getInstance();
//   final cachedContent = prefs.getString('content_$networkId');

//   List<NewsItemModel> content = [];

//   // Step 1: Use cached data for fast UI rendering
//   if (cachedContent != null) {
//     try {
//       List<dynamic> cachedBody = json.decode(cachedContent);
//       content = cachedBody
//           .map((dynamic item) => NewsItemModel.fromJson(item))
//           .toList();
//       content.sort(
//           (a, b) => safeParseInt(a.index).compareTo(safeParseInt(b.index)));
//     } catch (e) {
//       prefs.remove('content_$networkId');
//     }
//   }

//   // Step 2: Fetch API data in the background and compare with cache
//   try {
//     final headers = await ApiService.getHeaders();

//     final response = await https.get(
//       Uri.parse('${ApiService.baseUrl}getAllContentsOfNetwork/$networkId'),
//       headers: headers,
//     );

//     if (response.statusCode == 200) {
//       List<dynamic> body = json.decode(response.body);
//       List<NewsItemModel> apiContent =
//           body.map((dynamic item) => NewsItemModel.fromJson(item)).toList();

//       // Sorting API data
//       apiContent.sort(
//           (a, b) => safeParseInt(a.index).compareTo(safeParseInt(b.index)));

//       // Step 3: Compare cached data with API data
//       if (!listEquals(content, apiContent)) {
//         prefs.setString('content_$networkId', json.encode(body));
//         return apiContent;
//       } else {}
//     } else if (response.statusCode == 401 || response.statusCode == 403) {
//       throw Exception('Something went wrong');
//     } else {
//       throw Exception('Something went wrong');
//     }
//   } catch (e) {
//     if (content.isEmpty) {
//       rethrow; // Only throw if no cached data available
//     }
//   }

//   return content;
// }

// // Alternative simpler version if you want source_url and type
// Future<Map<String, dynamic>> fetchMoviePlayLink(int movieId) async {

//   final prefs = await SharedPreferences.getInstance();
//   final cacheKey = 'movie_source_data_$movieId';
//   final cachedSourceData = prefs.getString(cacheKey);

//   // Check cache first
//   if (cachedSourceData != null) {
//     try {
//       final Map<String, dynamic> cachedData = json.decode(cachedSourceData);
//       return cachedData;
//     } catch (e) {
//       prefs.remove(cacheKey);
//     }
//   }

//   try {
//     final headers = await ApiService.getHeaders();
//     final apiUrl = '${ApiService.baseUrl}getMoviePlayLinks/$movieId/0';

//     final response = await https.get(
//       Uri.parse(apiUrl),
//       headers: headers,
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> body = json.decode(response.body);

//       if (body.isNotEmpty) {
//         // Search for matching ID
//         for (var item in body) {
//           final Map<String, dynamic> itemMap = item as Map<String, dynamic>;
//           final int itemId = safeParseInt(itemMap['id']);

//           if (itemId == movieId) {
//             String sourceUrl = safeParseString(itemMap['source_url']);
//             int type = safeParseInt(itemMap['type']);
//             int linkType = safeParseInt(itemMap['link_type']);

//             // Handle YouTube IDs

//             final sourceData = {
//               'source_url': sourceUrl,
//               'type': type,
//               'link_type': linkType,
//               'id': itemId,
//               'name': safeParseString(itemMap['name']),
//               'quality': safeParseString(itemMap['quality']),
//             };

//             // Cache the source data
//             prefs.setString(cacheKey, json.encode(sourceData));
//             return sourceData;
//           }
//         }

//         // If no exact match, use first item
//         final Map<String, dynamic> firstItem =
//             body.first as Map<String, dynamic>;
//         String sourceUrl = safeParseString(firstItem['source_url']);
//         int type = safeParseInt(firstItem['type']);
//         int linkType = safeParseInt(firstItem['link_type']);

//         // if (sourceUrl.length == 11 && !sourceUrl.contains('http')) {
//         //   sourceUrl = 'https://www.youtube.com/watch?v=$sourceUrl';
//         // }

//         final sourceData = {
//           'source_url': sourceUrl,
//           'type': type,
//           'link_type': linkType,
//           'id': safeParseInt(firstItem['id']),
//           'name': safeParseString(firstItem['name']),
//           'quality': safeParseString(firstItem['quality']),
//         };

//         prefs.setString(cacheKey, json.encode(sourceData));
//         return sourceData;
//       }
//     }

//     throw Exception('No valid source URL found');
//   } catch (e) {
//     rethrow;
//   }
// }

// // Updated utility functions
// Future<Color> fetchPaletteColor(String imageUrl) async {
//   try {
//     return await PaletteColorService().getSecondaryColor(imageUrl);
//   } catch (e) {
//     return Colors.grey; // Fallback color
//   }
// }

// // Updated displayImage function with SVG support and better error handling
// Widget displayImage(
//   String imageUrl, {
//   double? width,
//   double? height,
//   BoxFit fit = BoxFit.fill,
// }) {
//   if (imageUrl.isEmpty || imageUrl == 'localImage') {
//     return Image.asset(localImage);
//   }

//   // Handle localhost URLs - replace with fallback
//   if (imageUrl.contains('localhost')) {
//     return Image.asset(localImage);
//   }

//   if (imageUrl.startsWith('data:image')) {
//     // Handle base64-encoded images
//     try {
//       Uint8List imageBytes = _getImageFromBase64String(imageUrl);
//       return Image.memory(
//         imageBytes,
//         fit: fit,
//         width: width,
//         height: height,
//         errorBuilder: (context, error, stackTrace) {
//           return _buildErrorWidget(width, height);
//         },
//       );
//     } catch (e) {
//       return _buildErrorWidget(width, height);
//     }
//   } else if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
//     // Check if it's an SVG image
//     if (imageUrl.toLowerCase().endsWith('.svg')) {
//       return SvgPicture.network(
//         imageUrl,
//         width: width,
//         height: height,
//         fit: fit,
//         placeholderBuilder: (context) {
//           return _buildLoadingWidget(width, height);
//         },
//       );
//     } else {
//       // Handle regular URL images (PNG, JPG, etc.)
//       return CachedNetworkImage(
//         imageUrl: imageUrl,
//         placeholder: (context, url) {
//           return _buildLoadingWidget(width, height);
//         },
//         errorWidget: (context, url, error) {
//           return _buildErrorWidget(width, height);
//         },
//         fit: fit,
//         width: width,
//         height: height,
//         // Add timeout
//         httpHeaders: {
//           'User-Agent': 'Flutter App',
//         },
//       );
//     }
//   } else {
//     // Fallback for invalid image data
//     return _buildErrorWidget(width, height);
//   }
// }

// // Helper widget for loading state
// Widget _buildLoadingWidget(double? width, double? height) {
//   return Container(
//     width: width,
//     height: height,
//     child: Center(
//       child: CircularProgressIndicator(
//         strokeWidth: 2,
//         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//       ),
//     ),
//   );
// }

// // Helper widget for error state
// Widget _buildErrorWidget(double? width, double? height) {
//   return Image.asset(localImage);
// }

// // Helper function to decode base64 images
// Uint8List _getImageFromBase64String(String base64String) {
//   return base64Decode(base64String.split(',').last);
// }

// // Error handling helper for authentication errors
// class AuthErrorHandler {
//   static void handleAuthError(BuildContext context, dynamic error) {
//     if (error.toString().contains('Authentication failed') ||
//         error.toString().contains('Auth key not found')) {
//       // Clear auth data
//       AuthManager.clearAuthKey();

//       // Navigate to login screen
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => LoginScreen()),
//         (route) => false,
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Session expired. Please login again.'),
//           backgroundColor: Colors.red,
//           duration: Duration(seconds: 3),
//         ),
//       );
//     }
//   }
// }

// // Updated SubVod widget with proper error handling
// class SubVod extends StatefulWidget {
//   final Function(bool)? onFocusChange;

//   const SubVod({Key? key, this.onFocusChange, required FocusNode focusNode})
//       : super(key: key);

//   @override
//   _SubVodState createState() => _SubVodState();
// }

// class _SubVodState extends State<SubVod> {
//   List<NetworkApi> _networks = [];
//   bool _isLoading = true;
//   bool _cacheLoaded = false;
//   String _errorMessage = '';
//   late FocusNode firstSubVodFocusNode;

//   @override
//   void initState() {
//     super.initState();

//     firstSubVodFocusNode = FocusNode()
//       ..onKey = (node, event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//             context.read<FocusProvider>().requestMusicItemFocus(context);
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//             context
//                 .read<FocusProvider>()
//                 // .requestManageMoviesFocus(); // Added missing parentheses
//                 .requestFirstMoviesFocus();
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       };

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context
//           .read<FocusProvider>()
//           .setFirstSubVodFocusNode(firstSubVodFocusNode);
//     });

//     _initializeData();
//   }

//   Future<void> _initializeData() async {
//     // Load cached data first
//     await _loadCachedNetworks();

//     // Then fetch fresh data
//     await _fetchNetworksInBackground();

//     // Ensure loading is turned off even if both methods fail
//     if (mounted && _isLoading) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _loadCachedNetworks() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cachedNetworks = prefs.getString('networks');

//       if (cachedNetworks != null && cachedNetworks.isNotEmpty) {
//         List<dynamic> cachedBody = json.decode(cachedNetworks);
//         List<NetworkApi> networks = cachedBody
//             .map((dynamic item) => NetworkApi.fromJson(item))
//             .toList();

//         if (mounted) {
//           setState(() {
//             _networks = networks;
//             _isLoading = false;
//             _cacheLoaded = true;
//             _errorMessage = '';
//           });
//         }
//       } else {}
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = 'Error loading cached data: $e';
//         });
//       }
//     }
//   }

//   Future<void> _fetchNetworksInBackground() async {
//     try {
//       final fetchedNetworks = await fetchNetworks(context);

//       if (!mounted) return;

//       // Update UI if data is different or if we don't have cached data
//       if (!listEquals(_networks, fetchedNetworks) || !_cacheLoaded) {
//         setState(() {
//           _networks = fetchedNetworks;
//           _isLoading = false;
//           _errorMessage = '';
//         });
//       } else {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           if (!_cacheLoaded || _networks.isEmpty) {
//             _errorMessage = 'Something went wrong';
//           }
//         });
//       }

//       // Handle authentication errors
//       AuthErrorHandler.handleAuthError(context, e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
//       Color backgroundColor = colorProvider.isItemFocused
//           ? colorProvider.dominantColor.withOpacity(0.3)
//           : Colors.black87;

//       return Scaffold(
//         backgroundColor: Colors.transparent,
//         body: _buildBody(),
//       );
//     });
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             LoadingIndicator(),
//             SizedBox(height: 20),
//             Text(
//               'Loading Networks...',
//               style: TextStyle(color: Colors.white, fontSize: 16),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_errorMessage.isNotEmpty && _networks.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, color: Colors.red, size: 48),
//             SizedBox(height: 16),
//             Text(
//               'Error Loading Networks',
//               style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 40),
//               child: Text(
//                 _errorMessage,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.white70, fontSize: 14),
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _isLoading = true;
//                   _errorMessage = '';
//                 });
//                 _fetchNetworksInBackground();
//               },
//               child: Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_networks.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.tv_off, color: Colors.grey, size: 48),
//             SizedBox(height: 16),
//             Text(
//               'No Networks Available',
//               style: TextStyle(color: Colors.white, fontSize: 18),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Something went wrong',
//               style: TextStyle(color: Colors.white70, fontSize: 14),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _isLoading = true;
//                   _errorMessage = '';
//                 });
//                 _fetchNetworksInBackground();
//               },
//               child: Text('Refresh'),
//             ),
//           ],
//         ),
//       );
//     }

//     return _buildNetworksList();
//   }

//   Widget _buildNetworksList() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Consumer<ColorProvider>(builder: (context, colorProvider, child) {
//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               'Contents',
//               style: TextStyle(
//                 fontSize: Headingtextsz,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           );
//         }),
//         Expanded(
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: _networks.length,
//             itemBuilder: (context, index) {
//               final network = _networks[index];
//               final isFirst = index == 0;

//               final focusNode = isFirst ? firstSubVodFocusNode : FocusNode()
//                 ..onKey = (node, event) {
//                   if (event is RawKeyDownEvent) {
//                     if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                       context
//                           .read<FocusProvider>()
//                           .requestMusicItemFocus(context);
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey ==
//                         LogicalKeyboardKey.arrowDown) {
//                       context.read<FocusProvider>().requestFirstMoviesFocus();
//                       return KeyEventResult.handled;
//                     }
//                   }
//                   return KeyEventResult.ignored;
//                 };

//               return FocussableSubvodWidget(
//                 imageUrl: network.logo,
//                 name: network.name,
//                 focusNode: focusNode,
//                 onTap: () async {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           ContentScreen(networkId: network.id),
//                     ),
//                   );
//                 },
//                 fetchPaletteColor: fetchPaletteColor,
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     firstSubVodFocusNode.dispose();
//     super.dispose();
//   }
// }

// // Updated VOD widget
// class VOD extends StatefulWidget {
//   @override
//   _VODState createState() => _VODState();
// }

// class _VODState extends State<VOD> {
//   List<NetworkApi> _networks = [];
//   bool _isLoading = true;
//   bool _cacheLoaded = false;
//   Map<int, FocusNode> firstRowFocusNodes = {};

//   @override
//   void initState() {
//     super.initState();

//     // Initialize focus nodes for first row items
//     for (int i = 0; i < 5; i++) {
//       final focusNode = FocusNode();
//       firstRowFocusNodes[i] = focusNode;

//       focusNode.onKey = (node, event) {
//         if (event is RawKeyDownEvent) {
//           switch (event.logicalKey) {
//             case LogicalKeyboardKey.arrowUp:
//               context.read<FocusProvider>().requestVodMenuFocus();
//               return KeyEventResult.handled;
//             case LogicalKeyboardKey.arrowLeft:
//               if (i > 0) {
//                 firstRowFocusNodes[i - 1]?.requestFocus();
//                 return KeyEventResult.handled;
//               }
//               return KeyEventResult.ignored;
//             case LogicalKeyboardKey.arrowRight:
//               if (i < 4 && i < _networks.length - 1) {
//                 firstRowFocusNodes[i + 1]?.requestFocus();
//                 return KeyEventResult.handled;
//               }
//               return KeyEventResult.ignored;
//             case LogicalKeyboardKey.arrowDown:
//               if (_networks.length > 5) {
//                 FocusScope.of(context).nextFocus();
//                 return KeyEventResult.handled;
//               }
//               return KeyEventResult.ignored;
//           }
//         }
//         return KeyEventResult.ignored;
//       };
//     }

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (firstRowFocusNodes.containsKey(0)) {
//         context
//             .read<FocusProvider>()
//             .setFirstVodBannerFocusNode(firstRowFocusNodes[0]!);
//         firstRowFocusNodes[0]?.requestFocus();
//       }
//     });

//     _loadCachedNetworks();
//     _fetchNetworksInBackground();
//   }

//   Future<void> _loadCachedNetworks() async {
//     final prefs = await SharedPreferences.getInstance();
//     final cachedNetworks = prefs.getString('networks');

//     if (cachedNetworks != null) {
//       try {
//         List<dynamic> cachedBody = json.decode(cachedNetworks);
//         setState(() {
//           _networks = cachedBody
//               .map((dynamic item) => NetworkApi.fromJson(item))
//               .toList();
//           _isLoading = false;
//           _cacheLoaded = true;
//         });
//       } catch (e) {}
//     }
//   }

//   Future<void> _fetchNetworksInBackground() async {
//     try {
//       final fetchedNetworks = await fetchNetworks(context);

//       if (!listEquals(_networks, fetchedNetworks)) {
//         setState(() {
//           _networks = fetchedNetworks;
//         });
//       }
//     } catch (e) {
//       AuthErrorHandler.handleAuthError(context, e);

//       if (!_cacheLoaded) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
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
//         Color backgroundColor = colorProvider.isItemFocused
//             ? colorProvider.dominantColor
//             : cardColor;

//         return Scaffold(
//           backgroundColor: backgroundColor,
//           body: _isLoading
//               ? Center(child: LoadingIndicator())
//               : _networks.isNotEmpty
//                   ? Container(
//                       color: Colors.black54, child: _buildNetworksList())
//                   : Center(
//                       child: Text('No Networks Available',
//                           style: TextStyle(color: Colors.white, fontSize: 18))),
//         );
//       }),
//     );
//   }

//   Widget _buildNetworksList() {
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 5,
//         // childAspectRatio: 0.8,
//       ),
//       itemCount: _networks.length,
//       itemBuilder: (context, index) {
//         final network = _networks[index];
//         final isFirstRow = index < 5;

//         return FocussableSubvodWidget(
//           focusNode: isFirstRow ? firstRowFocusNodes[index] : null,
//           imageUrl: network.logo,
//           name: network.name,
//           onTap: () async {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => ContentScreen(networkId: network.id),
//               ),
//             );
//           },
//           fetchPaletteColor: fetchPaletteColor,
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     firstRowFocusNodes.values.forEach((node) => node.dispose());
//     super.dispose();
//   }
// }

// // Updated Movie model for getAllMovies API
// class MovieItem {
//   final int id;
//   final String name;
//   final String description;
//   final String genres;
//   final String releaseDate;
//   final int? runtime;
//   final String sourceType;
//   final String? youtubeTrailer;
//   final String movieUrl;
//   final String? poster;
//   final String? banner;
//   final int status;
//   final int contentType;
//   final List<NetworkInfo> networks;

//   MovieItem({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.genres,
//     required this.releaseDate,
//     this.runtime,
//     required this.sourceType,
//     this.youtubeTrailer,
//     required this.movieUrl,
//     this.poster,
//     this.banner,
//     required this.status,
//     required this.contentType,
//     required this.networks,
//   });

//   factory MovieItem.fromJson(Map<String, dynamic> json) {
//     var networksFromJson = json['networks'] as List? ?? [];
//     List<NetworkInfo> networksList = networksFromJson
//         .map((networkJson) => NetworkInfo.fromJson(networkJson))
//         .toList();

//     return MovieItem(
//       id: safeParseInt(json['id']),
//       name: safeParseString(json['name'], defaultValue: 'No Name'),
//       description: safeParseString(json['description'], defaultValue: ''),
//       genres: safeParseString(json['genres'], defaultValue: 'Unknown'),
//       releaseDate: safeParseString(json['release_date'], defaultValue: ''),
//       runtime: json['runtime'] != null ? safeParseInt(json['runtime']) : null,
//       sourceType: safeParseString(json['source_type'], defaultValue: ''),
//       youtubeTrailer: json['youtube_trailer'],
//       movieUrl: safeParseString(json['movie_url'], defaultValue: ''),
//       poster: json['poster'],
//       banner: json['banner'],
//       status: safeParseInt(json['status']),
//       contentType: safeParseInt(json['content_type']),
//       networks: networksList,
//     );
//   }

//   // Helper method to check if movie is active
//   bool get isActive => status == 1;

//   // Get best image URL
//   String get bestImageUrl {
//     if (poster != null && poster!.isNotEmpty && poster != 'localImage') {
//       return poster!;
//     } else if (banner != null && banner!.isNotEmpty && banner != 'localImage') {
//       return banner!;
//     } else {
//       return 'localImage';
//     }
//   }

//   // Get banner URL for video screen
//   String get bannerUrl {
//     if (banner != null && banner!.isNotEmpty && banner != 'localImage') {
//       return banner!;
//     } else if (poster != null && poster!.isNotEmpty && poster != 'localImage') {
//       return poster!;
//     } else {
//       return 'localImage';
//     }
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is MovieItem &&
//         other.id == id &&
//         other.name == name &&
//         other.movieUrl == movieUrl &&
//         other.status == status;
//   }

//   @override
//   int get hashCode =>
//       id.hashCode ^ name.hashCode ^ movieUrl.hashCode ^ status.hashCode;
// }

// class NetworkInfo {
//   final int id;
//   final String name;
//   final String logo;

//   NetworkInfo({
//     required this.id,
//     required this.name,
//     required this.logo,
//   });

//   factory NetworkInfo.fromJson(Map<String, dynamic> json) {
//     return NetworkInfo(
//       id: safeParseInt(json['id']),
//       name: safeParseString(json['name'], defaultValue: 'Unknown Network'),
//       logo: safeParseString(json['logo'], defaultValue: 'localImage'),
//     );
//   }
// }

// // Updated fetch function for movies
// Future<List<MovieItem>> fetchAllMovies(BuildContext context) async {
//   final prefs = await SharedPreferences.getInstance();
//   final cachedMovies = prefs.getString('all_movies');

//   List<MovieItem> movies = [];
//   List<MovieItem> apiMovies = [];

//   // Step 1: Use cached data for fast UI rendering
//   if (cachedMovies != null) {
//     try {
//       List<dynamic> cachedBody = json.decode(cachedMovies);
//       movies =
//           cachedBody.map((dynamic item) => MovieItem.fromJson(item)).toList();
//     } catch (e) {
//       prefs.remove('all_movies');
//     }
//   }

//   // Step 2: Fetch API data in the background
//   try {
//     final headers = await ApiService.getHeaders();

//     final response = await https.get(
//       Uri.parse('${ApiService.baseUrl}getAllMovies'),
//       headers: headers,
//     );

//     if (response.statusCode == 200) {
//       List<dynamic> body = json.decode(response.body);
//       apiMovies = body.map((dynamic item) => MovieItem.fromJson(item)).toList();

//       // Step 3: Compare cached data with API data
//       if (!listEquals(movies, apiMovies)) {
//         prefs.setString('all_movies', response.body);
//         return apiMovies;
//       }
//     } else if (response.statusCode == 401 || response.statusCode == 403) {
//       throw Exception('Authentication failed. Please login again.');
//     } else {
//       throw Exception('Something went wrong');
//     }
//   } catch (e) {
//     if (movies.isEmpty) {
//       rethrow; // Only throw if no cached data available
//     }
//   }

//   return movies;
// }

// // Filter movies by network ID
// List<MovieItem> filterMoviesByNetwork(List<MovieItem> movies, int networkId) {
//   return movies.where((movie) {
//     return movie.networks.any((network) => network.id == networkId) &&
//         movie.isActive;
//   }).toList();
// }

// // Modified fetchAllMovies function to get movie URL by content ID
// Future<String?> fetchMovieUrlByContentId(
//     BuildContext context, int contentId) async {

//   final prefs = await SharedPreferences.getInstance();
//   final cacheKey = 'movie_url_$contentId';
//   final cachedUrl = prefs.getString(cacheKey);

//   // Check cache first
//   if (cachedUrl != null && cachedUrl.isNotEmpty) {
//     return cachedUrl;
//   }

//   try {
//     final headers = await ApiService.getHeaders();

//     final response = await https.get(
//       Uri.parse('${ApiService.baseUrl}getAllMovies'),
//       headers: headers,
//     );

//     if (response.statusCode == 200) {
//       List<dynamic> body = json.decode(response.body);


//       // Search for movie with matching content ID
//       for (var movieJson in body) {
//         final MovieItem movie = MovieItem.fromJson(movieJson);

//             '🎬 Checking Movie ID: ${movie.id}, Status: ${movie.status}, URL: ${movie.movieUrl}');

//         // Match content ID with movie ID
//         if (movie.id == contentId &&
//             movie.isActive &&
//             movie.movieUrl.isNotEmpty) {

//           // Cache the result
//           prefs.setString(cacheKey, movie.movieUrl);
//           return movie.movieUrl;
//         }
//       }

//       return null;
//     } else if (response.statusCode == 401 || response.statusCode == 403) {
//       throw Exception('Authentication failed. Please login again.');
//     } else {
//       throw Exception('Failed to fetch movies: ${response.statusCode}');
//     }
//   } catch (e) {
//     rethrow;
//   }
// }

// // Create a content ID to movie URL mapping
// Future<Map<int, String>> createContentToMovieUrlMap(
//     BuildContext context, List<int> contentIds) async {

//   Map<int, String> urlMap = {};

//   try {
//     final headers = await ApiService.getHeaders();

//     final response = await https.get(
//       Uri.parse('${ApiService.baseUrl}getAllMovies'),
//       headers: headers,
//     );

//     if (response.statusCode == 200) {
//       List<dynamic> body = json.decode(response.body);

//       for (var movieJson in body) {
//         final MovieItem movie = MovieItem.fromJson(movieJson);

//         // If this movie ID matches any of our content IDs
//         if (contentIds.contains(movie.id) &&
//             movie.isActive &&
//             movie.movieUrl.isNotEmpty) {
//           urlMap[movie.id] = movie.movieUrl;
//         }
//       }

//       return urlMap;
//     } else {
//       throw Exception('Failed to fetch movies: ${response.statusCode}');
//     }
//   } catch (e) {
//     return urlMap; // Return empty map on error
//   }
// }

// // Modified ContentScreen with enhanced loading states
// class ContentScreen extends StatefulWidget {
//   final int networkId;

//   ContentScreen({required this.networkId});

//   @override
//   _ContentScreenState createState() => _ContentScreenState();
// }

// class _ContentScreenState extends State<ContentScreen> {
//   List<NewsItemModel> _content = [];
//   Map<int, String> _contentToMovieUrlMap = {};
//   bool _isLoading = true;
//   bool _isVideoLoading = false; // New loading state for video preparation
//   String _loadingMovieName = ''; // Track which movie is loading
//   String _errorMessage = '';
//   FocusNode firstItemFocusNode = FocusNode();
//   bool _isVideoPlaying = false;
//   final SocketService _socketService = SocketService();

//   @override
//   void initState() {
//     super.initState();
//     _socketService.initSocket();
//     _loadData();

//     Future.delayed(Duration(milliseconds: 50), () {
//       firstItemFocusNode.requestFocus();
//     });
//   }

//   Future<void> _loadData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {

//       // Step 1: Load content first
//       _content = await fetchContent(context, widget.networkId);

//       // Step 2: Extract content IDs
//       List<int> contentIds = _content
//           .map((item) => int.tryParse(item.id) ?? 0)
//           .where((id) => id > 0)
//           .toList();


//       // Step 3: Create content ID to movie URL mapping
//       _contentToMovieUrlMap =
//           await createContentToMovieUrlMap(context, contentIds);

//           '🗺️ URL mapping created with ${_contentToMovieUrlMap.length} entries');

//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = '';
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = 'Error loading data: $e';
//         });
//       }
//       AuthErrorHandler.handleAuthError(context, e);
//     }
//   }

//   // Get movie URL for content ID with fallback to content URL
//   String _getVideoUrl(NewsItemModel contentItem) {
//     int contentId = int.tryParse(contentItem.id) ?? 0;


//     // Try to get movie URL first
//     if (_contentToMovieUrlMap.containsKey(contentId)) {
//       String movieUrl = _contentToMovieUrlMap[contentId]!;
//       return movieUrl;
//     }

//     // Fallback to content URL
//     return contentItem.url;
//   }

//   bool _isYouTubeUrl(String url) {
//     if (url.isEmpty) return false;
//     return RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url) ||
//         url.contains('youtube.com') ||
//         url.contains('youtu.be');
//   }

//   Future<void> _playVideo(NewsItemModel contentItem) async {
//     if (_isVideoPlaying || _isVideoLoading) return;

//     // Start loading state
//     setState(() {
//       _isVideoLoading = true;
//       _loadingMovieName = contentItem.name;
//       _isVideoPlaying = true;
//     });

//     try {
//       int contentId = int.tryParse(contentItem.id) ?? 0;


//       // Get the best available URL (movie URL preferred)
//       String? originalUrl = await fetchMovieUrlByContentId(context, contentId);
//       String? updatedUrl = await fetchMovieUrlByContentId(context, contentId);

//       // Determine URL source for tracking
//       String urlSource =
//           _contentToMovieUrlMap.containsKey(contentId) ? 'movie' : 'content';

//       // Process YouTube URLs through socket service
//       if (_isYouTubeUrl(updatedUrl ?? '')) {
//         final playUrl = await _socketService.getUpdatedUrl(updatedUrl ?? '');
//         if (playUrl.isNotEmpty) {
//           updatedUrl = playUrl;
//         } else {
//         }
//       }


//       // Navigate to video screen
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => VideoScreen(
//             channelList: _content,
//             source: 'isContentScreen',
//             name: contentItem.name,
//             videoUrl: updatedUrl ?? '',
//             unUpdatedUrl: originalUrl ?? contentItem.url,
//             bannerImageUrl: contentItem.banner,
//             startAtPosition: Duration.zero,
//             videoType: '',
//             isLive: false,
//             isVOD: true,
//             isLastPlayedStored: false,
//             isSearch: false,
//             isBannerSlider: false,
//             videoId: contentId,
//             seasonId: 0,
//             liveStatus: false,
//           ),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error playing video: ${e.toString()}'),
//           backgroundColor: Colors.red,
//           duration: Duration(seconds: 3),
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isVideoLoading = false;
//           _isVideoPlaying = false;
//           _loadingMovieName = '';
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
//       return Scaffold(
//         backgroundColor: Colors.black87,
//         body: Stack(
//           children: [
//             _buildBody(),
//             // Video loading overlay
//             if (_isVideoLoading)
//               Container(
//                 color: Colors.black.withOpacity(0.8),
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       LoadingIndicator(),
//                       SizedBox(height: 20),
//                       // Text(
//                       //   'Loading Video...',
//                       //   style: TextStyle(
//                       //     color: Colors.white,
//                       //     fontSize: 18,
//                       //     fontWeight: FontWeight.bold,
//                       //   ),
//                       // ),
//                       SizedBox(height: 10),
//                       Text(
//                         _loadingMovieName,
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontSize: 14,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       SizedBox(height: 20),
//                       // Optional: Add a cancel button
//                       // ElevatedButton(
//                       //   onPressed: () {
//                       //     setState(() {
//                       //       _isVideoLoading = false;
//                       //       _isVideoPlaying = false;
//                       //       _loadingMovieName = '';
//                       //     });
//                       //   },
//                       //   style: ElevatedButton.styleFrom(
//                       //     backgroundColor: Colors.red,
//                       //   ),
//                       //   child: Text('Cancel'),
//                       // ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 20),
//             Text('Loading content and movies...',
//                 style: TextStyle(color: Colors.white)),
//           ],
//         ),
//       );
//     }

//     if (_errorMessage.isNotEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, color: Colors.red, size: 48),
//             SizedBox(height: 16),
//             Text(_errorMessage, style: TextStyle(color: Colors.red)),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _loadData,
//               child: Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_content.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.movie_outlined, color: Colors.grey, size: 48),
//             SizedBox(height: 16),
//             Text('No content available', style: TextStyle(color: Colors.white)),
//             SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: _loadData,
//               child: Text('Refresh'),
//             ),
//           ],
//         ),
//       );
//     }

//     return _buildContentGrid();
//   }

//   Widget _buildContentGrid() {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Show mapping status
//           Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               'Content: ${_content.length} | Movie URLs: ${_contentToMovieUrlMap.length}',
//               style: TextStyle(color: Colors.white, fontSize: 12),
//             ),
//           ),
//           SizedBox(height: 16),

//           Expanded(
//             child: GridView.builder(
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 5,
//                 childAspectRatio: 0.8,
//               ),
//               itemCount: _content.length,
//               itemBuilder: (context, index) {
//                 final contentItem = _content[index];
//                 int contentId = int.tryParse(contentItem.id) ?? 0;
//                 bool hasMovieUrl = _contentToMovieUrlMap.containsKey(contentId);

//                 String imageUrl = contentItem.poster.isNotEmpty &&
//                         contentItem.poster != 'localImage'
//                     ? contentItem.poster
//                     : contentItem.banner.isNotEmpty &&
//                             contentItem.banner != 'localImage'
//                         ? contentItem.banner
//                         : 'localImage';

//                 return Stack(
//                   children: [
//                     // Add opacity when video is loading
//                     Opacity(
//                       opacity: _isVideoLoading ? 0.5 : 1.0,
//                       child: FocussableSubvodWidget(
//                         focusNode: index == 0 ? firstItemFocusNode : null,
//                         imageUrl: imageUrl,
//                         name: contentItem.name,
//                         onTap: _isVideoLoading
//                             ? () {}
//                             : () => _playVideo(contentItem),
//                         fetchPaletteColor: fetchPaletteColor,
//                       ),
//                     ),

//                     // URL source indicator
//                     Positioned(
//                       top: 8,
//                       right: 8,
//                       child: Container(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: hasMovieUrl ? Colors.green : Colors.orange,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(
//                           hasMovieUrl ? 'M' : 'C',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 10,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),

//                     // Individual item loading indicator
//                     if (_isVideoLoading &&
//                         _loadingMovieName == contentItem.name)
//                       Positioned.fill(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.7),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 SizedBox(
//                                   width: 30,
//                                   height: 30,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 3,
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                         Colors.white),
//                                   ),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   'Loading...',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     firstItemFocusNode.dispose();
//     _socketService.dispose();
//     super.dispose();
//   }
// }

// // // Updated ContentScreen widget
// // class ContentScreen extends StatefulWidget {
// //   final int networkId;

// //   ContentScreen({required this.networkId});

// //   @override
// //   _ContentScreenState createState() => _ContentScreenState();
// // }

// // // Updated ContentScreen with better debug logging
// // class _ContentScreenState extends State<ContentScreen> {
// //   List<NewsItemModel> _content = [];
// //   bool _isLoading = true;
// //   bool _cacheLoaded = false;
// //   String _errorMessage = '';
// //   FocusNode firstItemFocusNode = FocusNode();
// //   bool _isVideoPlaying = false;
// //   final SocketService _socketService = SocketService();

// //   @override
// //   void initState() {
// //     super.initState();
// //     _socketService.initSocket();
// //     _initializeContent();

// //     Future.delayed(Duration(milliseconds: 50), () async {
// //       firstItemFocusNode.requestFocus();
// //     });
// //   }

// //   Future<void> _initializeContent() async {
// //     // Load cached data first
// //     await _loadCachedContent();

// //     // Then fetch fresh data
// //     await _fetchContentInBackground();

// //     // Ensure loading is turned off even if both methods fail
// //     if (mounted && _isLoading) {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   Future<void> _loadCachedContent() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final cachedContent = prefs.getString('content_${widget.networkId}');

// //       if (cachedContent != null && cachedContent.isNotEmpty) {
// //         List<dynamic> cachedBody = json.decode(cachedContent);
// //         List<NewsItemModel> content = cachedBody
// //             .map((dynamic item) => NewsItemModel.fromJson(item))
// //             .toList();

// //         if (mounted) {
// //           setState(() {
// //             _content = content;
// //             _isLoading = false;
// //             _cacheLoaded = true;
// //             _errorMessage = '';
// //           });
// //         }

// //         // Debug: Print first few items
// //         for (int i = 0; i < (_content.length > 2 ? 2 : _content.length); i++) {
// //           final item = _content[i];
// //         }
// //       } else {}
// //     } catch (e) {
// //       if (mounted) {
// //         setState(() {
// //           _errorMessage = 'Error loading cached data: $e';
// //         });
// //       }
// //     }
// //   }

// //   Future<void> _fetchContentInBackground() async {
// //     try {
// //       final fetchedContent = await fetchContent(context, widget.networkId);

// //       if (!mounted) return;

// //       // Debug: Print API response details
// //       for (int i = 0;
// //           i < (fetchedContent.length > 2 ? 2 : fetchedContent.length);
// //           i++) {
// //         final item = fetchedContent[i];
// //       }

// //       // Update UI if data is different or if we don't have cached data
// //       if (!listEquals(_content, fetchedContent) || !_cacheLoaded) {
// //         setState(() {
// //           _content = fetchedContent;
// //           _isLoading = false;
// //           _errorMessage = '';
// //         });
// //       } else {
// //         setState(() {
// //           _isLoading = false;
// //         });
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         setState(() {
// //           _isLoading = false;
// //           if (!_cacheLoaded || _content.isEmpty) {
// //             _errorMessage = 'Something went wrong';
// //           }
// //         });
// //       }

// //       // Handle authentication errors
// //       AuthErrorHandler.handleAuthError(context, e);
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
// //       Color backgroundColor = colorProvider.isItemFocused
// //           ? colorProvider.dominantColor.withOpacity(0.3)
// //           : Colors.black87;

// //       return Scaffold(
// //         backgroundColor: backgroundColor,
// //         body: _buildBody(),
// //       );
// //     });
// //   }

// //   bool isYoutubeUrl(String? url) {
// //     if (url == null || url.isEmpty) {
// //       return false;
// //     }

// //     url = url.toLowerCase().trim();

// //     // First check if it's a YouTube ID (exactly 11 characters)
// //     bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url);
// //     if (isYoutubeId) {
// //       return true;
// //     }

// //     // Then check for regular YouTube URLs
// //     bool isYoutubeUrl = url.contains('youtube.com') ||
// //         url.contains('youtu.be') ||
// //         url.contains('youtube.com/shorts/');
// //     if (isYoutubeUrl) {
// //       return true;
// //     }

// //     return false;
// //   }

// //   Widget _buildBody() {
// //     if (_isLoading) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             CircularProgressIndicator(),
// //             SizedBox(height: 20),
// //             Text(
// //               'Loading Content...',
// //               style: TextStyle(color: Colors.white, fontSize: 16),
// //             ),
// //           ],
// //         ),
// //       );
// //     }

// //     if (_errorMessage.isNotEmpty && _content.isEmpty) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(Icons.error_outline, color: Colors.red, size: 48),
// //             SizedBox(height: 16),
// //             Text(
// //               'Error Loading Content',
// //               style: TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.bold),
// //             ),
// //             SizedBox(height: 8),
// //             Padding(
// //               padding: EdgeInsets.symmetric(horizontal: 40),
// //               child: Text(
// //                 _errorMessage,
// //                 textAlign: TextAlign.center,
// //                 style: TextStyle(color: Colors.white70, fontSize: 14),
// //               ),
// //             ),
// //             SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: () {
// //                 setState(() {
// //                   _isLoading = true;
// //                   _errorMessage = '';
// //                 });
// //                 _fetchContentInBackground();
// //               },
// //               child: Text('Retry'),
// //             ),
// //           ],
// //         ),
// //       );
// //     }

// //     if (_content.isEmpty) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(Icons.movie_outlined, color: Colors.grey, size: 48),
// //             SizedBox(height: 16),
// //             Text(
// //               'No Content Available',
// //               style: TextStyle(color: Colors.white, fontSize: 18),
// //             ),
// //             SizedBox(height: 8),
// //             Text(
// //               'This network has no content to display',
// //               style: TextStyle(color: Colors.white70, fontSize: 14),
// //             ),
// //             SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: () {
// //                 setState(() {
// //                   _isLoading = true;
// //                   _errorMessage = '';
// //                 });
// //                 _fetchContentInBackground();
// //               },
// //               child: Text('Refresh'),
// //             ),
// //           ],
// //         ),
// //       );
// //     }

// //     return _buildContentGrid();
// //   }

// //   Widget _buildContentGrid() {
// //     // Sort content by index
// //     _content
// //         .sort((a, b) => safeParseInt(a.index).compareTo(safeParseInt(b.index)));

// //     return Padding(
// //       padding: EdgeInsets.symmetric(
// //           horizontal: screenwdt * 0.03, vertical: screenhgt * 0.01),
// //       child: GridView.builder(
// //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //             crossAxisCount: 5, childAspectRatio: 1),
// //         itemCount: _content.length,
// //         itemBuilder: (context, index) {
// //           final contentItem = _content[index];

// //           // Debug print for each item being built

// //           // Choose the best image URL (prefer poster over banner)
// //           String imageUrl = '';
// //           if (contentItem.poster.isNotEmpty &&
// //               contentItem.poster != 'localImage') {
// //             imageUrl = contentItem.poster;
// //           } else if (contentItem.banner.isNotEmpty &&
// //               contentItem.banner != 'localImage') {
// //             imageUrl = contentItem.banner;
// //           } else if (contentItem.image.isNotEmpty &&
// //               contentItem.image != 'localImage') {
// //             imageUrl = contentItem.image;
// //           } else if (contentItem.thumbnail_high.isNotEmpty &&
// //               contentItem.thumbnail_high != 'localImage') {
// //             imageUrl = contentItem.thumbnail_high;
// //           } else {
// //             imageUrl = 'localImage';
// //           }

// //           return FocussableSubvodWidget(
// //             focusNode: index == 0 ? firstItemFocusNode : null,
// //             imageUrl: imageUrl,
// //             name: contentItem.name,
// //             onTap: () async {
// //               if (_isVideoPlaying) {
// //                 return;
// //               }

// //               setState(() {
// //                 // _isLoading = true;
// //                 _isVideoPlaying = true;
// //               });
// //               int contentId = int.tryParse(contentItem.id) ?? 0;
// //               String originalUrl = contentItem.url;
// //               String updatedUrl = contentItem.url;

// //               if (isYoutubeUrl(updatedUrl)) {
// //                 updatedUrl = await _socketService.getUpdatedUrl(updatedUrl);
// //               }

// //               Navigator.push(
// //                 context,
// //                 MaterialPageRoute(
// //                   builder: (context) => VideoScreen(
// //                     // id: contentId,
// //                     // channelList: _content,
// //                     // source: 'isContentScreenViaDetailsPageChannelList',
// //                     // banner: contentItem.banner,
// //                     // name: contentItem.name,
// //                     channelList: _content,
// //                     source: 'isMovieScreen',
// //                     name: contentItem.name,
// //                     videoUrl: updatedUrl,
// //                     unUpdatedUrl: originalUrl,
// //                     bannerImageUrl: contentItem.banner,
// //                     startAtPosition: Duration.zero,
// //                     videoType: '',
// //                     isLive: false,
// //                     isVOD: false,
// //                     isLastPlayedStored: false,
// //                     isSearch: false,
// //                     isBannerSlider: false,
// //                     videoId: null,
// //                     seasonId: 0,
// //                     liveStatus: false,
// //                   )
// //                 ),
// //               );
// //               setState(() {
// //                 _isLoading = false;
// //                 _isVideoPlaying = false;
// //               });
// //             },
// //             fetchPaletteColor: fetchPaletteColor,
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     firstItemFocusNode.dispose();
// //     super.dispose();
// //   }
// // }

// // Updated DetailsPage widget with proper int handling
// class DetailsPage extends StatefulWidget {
//   final int id;
//   final List<NewsItemModel> channelList;
//   final String source;
//   final String banner;
//   final String name;

//   DetailsPage({
//     required this.id,
//     required this.channelList,
//     required this.source,
//     required this.banner,
//     required this.name,
//   });

//   @override
//   _DetailsPageState createState() => _DetailsPageState();
// }

// class _DetailsPageState extends State<DetailsPage> {
//   final SocketService _socketService = SocketService();
//   MovieDetailsApi? _movieDetails;
//   final int _maxRetries = 3;
//   final int _retryDelay = 5; // seconds
//   bool _shouldContinueLoading = true;
//   bool _isLoading = false;
//   bool _isVideoPlaying = false;
//   Timer? _timer;
//   bool _isReturningFromVideo = false;
//   FocusNode firstItemFocusNode = FocusNode();
//   Color headingColor = Colors.grey;

//   @override
//   void initState() {
//     super.initState();

//     _socketService.initSocket();
//     checkServerStatus();

//     Future.delayed(Duration(milliseconds: 100), () async {
//       await _loadCachedAndFetchMovieDetails(widget.id);
//       if (_movieDetails != null) {
//         _fetchAndSetHeadingColor(_movieDetails!.banner);
//       }
//       firstItemFocusNode.requestFocus();
//     });
//   }

//   @override
//   void dispose() {
//     _socketService.dispose();
//     _timer?.cancel();
//     firstItemFocusNode.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchAndSetHeadingColor(String bannerUrl) async {
//     try {
//       Color paletteColor = await fetchPaletteColor(bannerUrl);
//       setState(() {
//         headingColor = paletteColor;
//       });
//     } catch (e) {}
//   }

//   Future<void> _loadCachedAndFetchMovieDetails(int contentId) async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final movieDetails = await fetchMovieDetails(context, contentId);

//       if (!mounted) return;

//       setState(() {
//         _movieDetails = movieDetails;
//         _isLoading = false;
//       });

//       // Fetch updated heading color when details are loaded
//       if (movieDetails.banner.isNotEmpty) {
//         _fetchAndSetHeadingColor(movieDetails.banner);
//       }
//     } catch (e) {
//       AuthErrorHandler.handleAuthError(context, e);

//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _movieDetails = null;
//         });
//       }
//     }
//   }

//   void checkServerStatus() {
//     Timer.periodic(Duration(seconds: 10), (timer) {
//       if (!_socketService.socket!.connected) {
//         _socketService.initSocket();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black87,
//       body: _isLoading
//           ? Center(child: LoadingIndicator())
//           : _isReturningFromVideo
//               ? Center(
//                   child: Text(
//                     '',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 )
//               : _movieDetails != null
//                   ? _buildMovieDetailsUI(context, _movieDetails!)
//                   : Center(
//                       child: Text(
//                         '...',
//                         style: TextStyle(color: Colors.white, fontSize: 18),
//                       ),
//                     ),
//     );
//   }

//   Widget _buildMovieDetailsUI(
//       BuildContext context, MovieDetailsApi movieDetails) {
//     return Container(
//       child: Stack(
//         children: [
//           // Only show banner if status is active (1)
//           if (movieDetails.isActive)
//             displayImage(
//               movieDetails.banner ?? localImage,
//               width: screenwdt,
//               height: screenhgt,
//             ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.03),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 SizedBox(height: screenhgt * 0.05),
//                 Container(
//                   child: Text(
//                     movieDetails.name,
//                     style: TextStyle(
//                       color: headingColor,
//                       fontSize: Headingtextsz * 1.5,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Spacer(),
//                 // Status info
//                 if (!movieDetails.isActive)
//                   Container(
//                     padding: EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.red.withOpacity(0.7),
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                     child: Text(
//                       'Content not available (Status: ${movieDetails.status})',
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ),
//                 Expanded(
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: 1,
//                     itemBuilder: (context, index) {
//                       return FocussableSubvodWidget(
//                         focusNode: firstItemFocusNode,
//                         imageUrl: movieDetails.poster ?? localImage,
//                         name: '',
//                         onTap: () => movieDetails.isActive
//                             ? _playVideo(movieDetails)
//                             : _showInactiveContentMessage(),
//                         fetchPaletteColor: fetchPaletteColor,
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   bool isYoutubeUrl(String? url) {
//     if (url == null || url.isEmpty) {
//       return false;
//     }

//     url = url.toLowerCase().trim();

//     // First check if it's a YouTube ID (exactly 11 characters)
//     bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url);
//     if (isYoutubeId) {
//       return true;
//     }

//     // Then check for regular YouTube URLs
//     bool isYoutubeUrl = url.contains('youtube.com') ||
//         url.contains('youtu.be') ||
//         url.contains('youtube.com/shorts/');
//     if (isYoutubeUrl) {
//       return true;
//     }

//     return false;
//   }

//   String formatUrl(String url, {Map<String, String>? params}) {
//     if (url.isEmpty) {
//       throw Exception("Empty URL provided");
//     }

//     // // Handle YouTube ID by converting to full URL if needed
//     // if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url)) {
//     //   url = "https://www.youtube.com/watch?v=$url";
//     // }

//     // Remove any existing query parameters
//     // url = url.split('?')[0];

//     // Add new query parameters
//     // if (params != null && params.isNotEmpty) {
//     //   url += '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&');
//     // }

//     return url;
//   }

//   void _showInactiveContentMessage() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('This content is currently not available'),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   Future<void> _playVideo(MovieDetailsApi movieDetails) async {

//     if (_isVideoPlaying) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _isVideoPlaying = true;
//     });

//     _shouldContinueLoading = true;

//     try {
//       // Step 1: Fetch movie play link
//       Map<String, dynamic> playLinkData = await fetchMoviePlayLink(widget.id);
//       String originalUrl = playLinkData['source_url'] ?? '';

//       // Step 2: Get original URL
//       String updatedUrl = playLinkData['source_url'] ?? '';

//       if (originalUrl.isEmpty) {
//         throw Exception('Original URL is empty');
//       }

//       // Step 3: Update URL using socket service

//       if (isYoutubeUrl(updatedUrl)) {
//         updatedUrl = await _socketService.getUpdatedUrl(updatedUrl);
//       }

//       // updatedUrl = await _socketService.getUpdatedUrl(originalUrl);

//       if (updatedUrl.isEmpty) {
//         throw Exception('Updated URL is empty');
//       }

//       // Step 4: URL validation
//       bool isValidUrl = Uri.tryParse(updatedUrl) != null;

//       if (updatedUrl.startsWith('http://') ||
//           updatedUrl.startsWith('https://')) {
//       } else {
//       }

//       // Step 5: Navigation check

//       if (!_shouldContinueLoading) {
//         return;
//       }

//       if (!mounted) {
//         return;
//       }

//       // Step 6: Navigate to VideoScreen

//       bool liveStatus = false;

//       if (_shouldContinueLoading) {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) {
//               return VideoScreen(
//                 videoUrl: updatedUrl,
//                 videoId: widget.id,
//                 channelList: widget.channelList,
//                 videoType: '',
//                 bannerImageUrl: widget.banner,
//                 startAtPosition: Duration.zero,
//                 isLive: false,
//                 isVOD: true,
//                 isBannerSlider: false,
//                 source: widget.source,
//                 isSearch: false,
//                 unUpdatedUrl: originalUrl,
//                 name: widget.name,
//                 seasonId: null,
//                 isLastPlayedStored: false,
//                 liveStatus: liveStatus,
//               );
//             },
//           ),
//         );
//       }

//       // Update UI after returning
//       setState(() {
//         _isLoading = false;
//         _isReturningFromVideo = true;
//       });

//       setState(() {
//         _isReturningFromVideo = false;
//       });
//     } catch (e, stackTrace) {

//       _handleVideoError(context);
//       AuthErrorHandler.handleAuthError(context, e);
//     } finally {
//       setState(() {
//         _isLoading = false;
//         _isVideoPlaying = false;
//       });
//     }
//   }

//   void _handleVideoError(BuildContext context) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Something Went Wrong', style: TextStyle(fontSize: 20)),
//         backgroundColor: Colors.red,
//         duration: Duration(seconds: 3),
//       ),
//     );
//   }
// }






import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'dart:math' as math;
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/video_widget/youtube_player.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../video_widget/socket_service.dart';
import '../../video_widget/video_screen.dart';
import '../../widgets/models/news_item_model.dart';
import '../../widgets/small_widgets/loading_indicator.dart';
import '../../widgets/utils/color_service.dart';
import 'focussable_subvod_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

// API Service class for consistent header management
class ApiService {
  static Future<Map<String, String>> getHeaders() async {
    await AuthManager.initialize();
    String authKey = AuthManager.authKey;

    if (authKey.isEmpty) {
      throw Exception('Auth key not found. Please login again.');
    }

    return {
      'auth-key': authKey, // Updated header name
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  static String get baseUrl => 'https://acomtv.coretechinfo.com/public/api/';
}

// Helper function to safely parse integers from dynamic values
int safeParseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;

  if (value is int) {
    return value;
  } else if (value is String) {
    return int.tryParse(value) ?? defaultValue;
  } else if (value is double) {
    return value.toInt();
  }

  return defaultValue;
}

// Helper function to safely parse strings
String safeParseString(dynamic value, {String defaultValue = ''}) {
  if (value == null) return defaultValue;
  return value.toString();
}

// Updated NetworkApi model with proper int handling
class NetworkApi {
  final int id; // Now properly int
  final String name;
  final String logo;
  final int networksOrder; // Changed to int

  NetworkApi({
    required this.id,
    required this.name,
    required this.logo,
    required this.networksOrder,
  });

  factory NetworkApi.fromJson(Map<String, dynamic> json) {
    return NetworkApi(
      id: safeParseInt(json['id']), // Safe int parsing
      name: safeParseString(json['name'], defaultValue: 'No Name'),
      logo: safeParseString(json['logo'], defaultValue: 'localImage'),
      networksOrder: safeParseInt(json['networks_order']), // Now int
    );
  }

  // Override equality for listEquals comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NetworkApi &&
        other.id == id &&
        other.name == name &&
        other.logo == logo &&
        other.networksOrder == networksOrder;
  }

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ logo.hashCode ^ networksOrder.hashCode;
}

// Updated MovieDetailsApi model with proper int handling
class MovieDetailsApi {
  final int id; // Now properly int
  final String name;
  final String banner;
  final String poster;
  final String genres;
  final int status; // Changed from String to int

  MovieDetailsApi({
    required this.id,
    required this.name,
    required this.banner,
    required this.poster,
    required this.genres,
    required this.status,
  });

  factory MovieDetailsApi.fromJson(Map<String, dynamic> json) {
    return MovieDetailsApi(
      id: safeParseInt(json['id']), // Safe int parsing
      name: safeParseString(json['name'], defaultValue: 'No Name'),
      banner: safeParseString(json['banner'], defaultValue: 'localImage'),
      poster: safeParseString(json['poster'], defaultValue: 'localImage'),
      genres: safeParseString(json['genres'], defaultValue: 'Unknown'),
      status: safeParseInt(json['status']), // Now int instead of string
    );
  }

  // Helper method to check if movie is active
  bool get isActive => status == 1;

  // Override equality for comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MovieDetailsApi &&
        other.id == id &&
        other.name == name &&
        other.banner == banner &&
        other.poster == poster &&
        other.genres == genres &&
        other.status == status;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      banner.hashCode ^
      poster.hashCode ^
      genres.hashCode ^
      status.hashCode;
}

// Updated fetch functions with proper error handling

Future<MovieDetailsApi> fetchMovieDetails(
    BuildContext context, int contentId) async {
  final prefs = await SharedPreferences.getInstance();
  final cachedMovieDetails = prefs.getString('movie_details_$contentId');

  // Step 1: Return cached data immediately if available
  if (cachedMovieDetails != null) {
    try {
      final Map<String, dynamic> body = json.decode(cachedMovieDetails);
      return MovieDetailsApi.fromJson(body);
    } catch (e) {
      // Clear corrupted cache
      prefs.remove('movie_details_$contentId');
    }
  }

  // Step 2: Fetch API data if no cache is available
  try {
    final headers = await ApiService.getHeaders();

    final response = await https.get(
      Uri.parse('${ApiService.baseUrl}getMovieDetails/$contentId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final movieDetails = MovieDetailsApi.fromJson(body);

      // Step 3: Cache the fetched data
      prefs.setString('movie_details_$contentId', response.body);

      return movieDetails;
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Something went wrong');
    } else {
      throw Exception('Something went wrong');
    }
  } catch (e) {
    rethrow;
  }
}

Future<List<NetworkApi>> fetchNetworks(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final cachedNetworks = prefs.getString('networks');

  List<NetworkApi> networks = [];
  List<NetworkApi> apiNetworks = [];

  // Step 1: Use cached data for fast UI rendering
  if (cachedNetworks != null) {
    try {
      List<dynamic> cachedBody = json.decode(cachedNetworks);
      networks =
          cachedBody.map((dynamic item) => NetworkApi.fromJson(item)).toList();
    } catch (e) {
      prefs.remove('networks');
    }
  }

  // Step 2: Fetch API data in the background
  try {
    final headers = await ApiService.getHeaders();

    final response = await https.get(
      Uri.parse('${ApiService.baseUrl}getNetworks'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      apiNetworks =
          body.map((dynamic item) => NetworkApi.fromJson(item)).toList();

      // Step 3: Compare cached data with API data
      if (!listEquals(networks, apiNetworks)) {
        prefs.setString('networks', response.body);
        return apiNetworks;
      } else {}
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('Something went wrong');
    }
  } catch (e) {
    if (networks.isEmpty) {
      rethrow; // Only throw if no cached data available
    }
  }

  return networks;
}

Future<List<NewsItemModel>> fetchContent(
    BuildContext context, int networkId) async {
  final prefs = await SharedPreferences.getInstance();
  final cachedContent = prefs.getString('content_$networkId');

  List<NewsItemModel> content = [];

  // Step 1: Use cached data for fast UI rendering
  if (cachedContent != null) {
    try {
      List<dynamic> cachedBody = json.decode(cachedContent);
      content = cachedBody
          .map((dynamic item) => NewsItemModel.fromJson(item))
          .toList();
      content.sort(
          (a, b) => safeParseInt(a.index).compareTo(safeParseInt(b.index)));
    } catch (e) {
      prefs.remove('content_$networkId');
    }
  }

  // Step 2: Fetch API data in the background and compare with cache
  try {
    final headers = await ApiService.getHeaders();

    final response = await https.get(
      Uri.parse('${ApiService.baseUrl}getAllContentsOfNetwork/$networkId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<NewsItemModel> apiContent =
          body.map((dynamic item) => NewsItemModel.fromJson(item)).toList();

      // Sorting API data
      apiContent.sort(
          (a, b) => safeParseInt(a.index).compareTo(safeParseInt(b.index)));

      // Step 3: Compare cached data with API data
      if (!listEquals(content, apiContent)) {
        prefs.setString('content_$networkId', json.encode(body));
        return apiContent;
      } else {}
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Something went wrong');
    } else {
      throw Exception('Something went wrong');
    }
  } catch (e) {
    if (content.isEmpty) {
      rethrow; // Only throw if no cached data available
    }
  }

  return content;
}

// Alternative simpler version if you want source_url and type
Future<Map<String, dynamic>> fetchMoviePlayLink(int movieId) async {

  final prefs = await SharedPreferences.getInstance();
  final cacheKey = 'movie_source_data_$movieId';
  final cachedSourceData = prefs.getString(cacheKey);

  // Check cache first
  if (cachedSourceData != null) {
    try {
      final Map<String, dynamic> cachedData = json.decode(cachedSourceData);
      return cachedData;
    } catch (e) {
      prefs.remove(cacheKey);
    }
  }

  try {
    final headers = await ApiService.getHeaders();
    final apiUrl = '${ApiService.baseUrl}getMoviePlayLinks/$movieId/0';

    final response = await https.get(
      Uri.parse(apiUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);

      if (body.isNotEmpty) {
        // Search for matching ID
        for (var item in body) {
          final Map<String, dynamic> itemMap = item as Map<String, dynamic>;
          final int itemId = safeParseInt(itemMap['id']);

          if (itemId == movieId) {
            String sourceUrl = safeParseString(itemMap['source_url']);
            int type = safeParseInt(itemMap['type']);
            int linkType = safeParseInt(itemMap['link_type']);

            // Handle YouTube IDs

            final sourceData = {
              'source_url': sourceUrl,
              'type': type,
              'link_type': linkType,
              'id': itemId,
              'name': safeParseString(itemMap['name']),
              'quality': safeParseString(itemMap['quality']),
            };

            // Cache the source data
            prefs.setString(cacheKey, json.encode(sourceData));
            return sourceData;
          }
        }

        // If no exact match, use first item
        final Map<String, dynamic> firstItem =
            body.first as Map<String, dynamic>;
        String sourceUrl = safeParseString(firstItem['source_url']);
        int type = safeParseInt(firstItem['type']);
        int linkType = safeParseInt(firstItem['link_type']);

        // if (sourceUrl.length == 11 && !sourceUrl.contains('http')) {
        //   sourceUrl = 'https://www.youtube.com/watch?v=$sourceUrl';
        // }

        final sourceData = {
          'source_url': sourceUrl,
          'type': type,
          'link_type': linkType,
          'id': safeParseInt(firstItem['id']),
          'name': safeParseString(firstItem['name']),
          'quality': safeParseString(firstItem['quality']),
        };

        prefs.setString(cacheKey, json.encode(sourceData));
        return sourceData;
      }
    }

    throw Exception('No valid source URL found');
  } catch (e) {
    rethrow;
  }
}

// Updated utility functions
Future<Color> fetchPaletteColor(String imageUrl) async {
  try {
    return await PaletteColorService().getSecondaryColor(imageUrl);
  } catch (e) {
    return Colors.grey; // Fallback color
  }
}

// Updated displayImage function with SVG support and better error handling
Widget displayImage(
  String imageUrl, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.fill,
}) {
  if (imageUrl.isEmpty || imageUrl == 'localImage') {
    return Image.asset(localImage);
  }

  // Handle localhost URLs - replace with fallback
  if (imageUrl.contains('localhost')) {
    return Image.asset(localImage);
  }

  if (imageUrl.startsWith('data:image')) {
    // Handle base64-encoded images
    try {
      Uint8List imageBytes = _getImageFromBase64String(imageUrl);
      return Image.memory(
        imageBytes,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget(width, height);
        },
      );
    } catch (e) {
      return _buildErrorWidget(width, height);
    }
  } else if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
    // Check if it's an SVG image
    if (imageUrl.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (context) {
          return _buildLoadingWidget(width, height);
        },
      );
    } else {
      // Handle regular URL images (PNG, JPG, etc.)
      return CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (context, url) {
          return _buildLoadingWidget(width, height);
        },
        errorWidget: (context, url, error) {
          return _buildErrorWidget(width, height);
        },
        fit: fit,
        width: width,
        height: height,
        // Add timeout
        httpHeaders: {
          'User-Agent': 'Flutter App',
        },
      );
    }
  } else {
    // Fallback for invalid image data
    return _buildErrorWidget(width, height);
  }
}

// Helper widget for loading state
Widget _buildLoadingWidget(double? width, double? height) {
  return Container(
    width: width,
    height: height,
    child: Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    ),
  );
}

// Helper widget for error state
Widget _buildErrorWidget(double? width, double? height) {
  return Image.asset(localImage);
}

// Helper function to decode base64 images
Uint8List _getImageFromBase64String(String base64String) {
  return base64Decode(base64String.split(',').last);
}

// Error handling helper for authentication errors
class AuthErrorHandler {
  static void handleAuthError(BuildContext context, dynamic error) {
    if (error.toString().contains('Authentication failed') ||
        error.toString().contains('Auth key not found')) {
      // Clear auth data
      AuthManager.clearAuthKey();

      // Navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session expired. Please login again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

// 🎨 PROFESSIONAL SUBVOD & VOD UI - WEBSERIES STYLE

// ================================
// 1. PROFESSIONAL COLORS & ANIMATIONS
// ================================

class ProfessionalVODColors {
  static const primaryDark = Color(0xFF0A0E1A);
  static const surfaceDark = Color(0xFF1A1D29);
  static const cardDark = Color(0xFF2A2D3A);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentPurple = Color(0xFF8B5CF6);
  static const accentGreen = Color(0xFF10B981);
  static const accentRed = Color(0xFFEF4444);
  static const accentOrange = Color(0xFFF59E0B);
  static const accentPink = Color(0xFFEC4899);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);

  static List<Color> gradientColors = [
    accentBlue,
    accentPurple,
    accentGreen,
    accentRed,
    accentOrange,
    accentPink,
  ];
}

class VODAnimationTiming {
  static const Duration ultraFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration focus = Duration(milliseconds: 700);
  static const Duration scroll = Duration(milliseconds: 800);
}

// Fixed SubVod with proper focus navigation and enter key handling

class SubVod extends StatefulWidget {
  final Function(bool)? onFocusChange;

  const SubVod({Key? key, this.onFocusChange, required FocusNode focusNode}) : super(key: key);

  @override
  _SubVodState createState() => _SubVodState();
}

class _SubVodState extends State<SubVod> with TickerProviderStateMixin {
  List<NetworkApi> _networks = [];
  bool _isLoading = true;
  bool _cacheLoaded = false;
  String _errorMessage = '';
  
  // 🎯 FOCUS NODES - Create separate focus nodes for each network item
  List<FocusNode> networkFocusNodes = [];
  int currentFocusIndex = 0;

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _networkAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _networkFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _initializeAnimations();

    // Load data first, then setup focus nodes
    // _initializeData();
    _initializeDataWithFallback();
  }


  // ADD this new method:
Future<void> _initializeDataWithFallback() async {
  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  try {
    await _loadCachedNetworks();
    
    if (_networks.isEmpty) {
      await _fetchNetworksDirectly();
    } else {
      await _fetchNetworksInBackground();
    }

    _headerAnimationController.forward();
    _networkAnimationController.forward();
  } catch (e) {
    setState(() {
      _errorMessage = 'Failed to load networks: $e';
      _isLoading = false;
    });
  }
}



// ADD this new method:
Future<void> _fetchNetworksDirectly() async {
  try {
    
    final headers = await ApiService.getHeaders();
    final response = await https.get(
      Uri.parse('${ApiService.baseUrl}getNetworks'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<NetworkApi> apiNetworks = body
          .map((dynamic item) => NetworkApi.fromJson(item))
          .toList();


      if (mounted) {
        setState(() {
          _networks = apiNetworks;
          _isLoading = false;
          _errorMessage = '';
          _cacheLoaded = true;
        });

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('networks', response.body);

        _setupFocusNodes();
      }
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('API error: ${response.statusCode}');
    }
  } catch (e) {
    rethrow;
  }
}

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: VODAnimationTiming.slow,
      vsync: this,
    );

    _networkAnimationController = AnimationController(
      duration: VODAnimationTiming.slow,
      vsync: this,
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _networkFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _networkAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  // 🎯 SETUP FOCUS NODES - Create focus nodes for each network
  void _setupFocusNodes() {
    // Dispose existing focus nodes
    for (var node in networkFocusNodes) {
      node.dispose();
    }
    networkFocusNodes.clear();

    // Create new focus nodes for each network
    for (int i = 0; i < _networks.length; i++) {
      final focusNode = FocusNode();
      
      // 🎯 KEY HANDLING - Handle arrow keys and enter key
      focusNode.onKey = (node, event) {
        if (event is RawKeyDownEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowUp:
              context.read<FocusProvider>().requestMusicItemFocus(context);
              return KeyEventResult.handled;
              
            case LogicalKeyboardKey.arrowDown:
              context.read<FocusProvider>().requestFirstMoviesFocus();
              return KeyEventResult.handled;
              
            case LogicalKeyboardKey.arrowLeft:
              if (i > 0) {
                currentFocusIndex = i - 1;
                networkFocusNodes[i - 1].requestFocus();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
              
            case LogicalKeyboardKey.arrowRight:
              if (i < _networks.length - 1) {
                currentFocusIndex = i + 1;
                networkFocusNodes[i + 1].requestFocus();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
              
            // 🎯 ENTER KEY HANDLING - Navigate to ContentScreen
            case LogicalKeyboardKey.select:
            case LogicalKeyboardKey.enter:
              _navigateToNetwork(_networks[i]);
              return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      };

      // 🎯 FOCUS CHANGE LISTENER
      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          currentFocusIndex = i;
          if (widget.onFocusChange != null) {
            widget.onFocusChange!(true);
          }
        }
      });

      networkFocusNodes.add(focusNode);
    }

    // 🎯 REGISTER FIRST FOCUS NODE with FocusProvider
    if (networkFocusNodes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<FocusProvider>().setFirstSubVodFocusNode(networkFocusNodes[0]);
          context.read<FocusProvider>().setSubVodContext(context);
          
          // Auto-focus first item
          Future.delayed(Duration(milliseconds: 100), () {
            if (mounted && networkFocusNodes.isNotEmpty) {
              context.read<FocusProvider>().setFirstSubVodFocusNode(networkFocusNodes[0]);
          context.read<FocusProvider>().setSubVodContext(context);
              // networkFocusNodes[0].requestFocus();
            }
          });
        }
      });
    }
  }

  // 🎯 NAVIGATION FUNCTION - Navigate to ContentScreen
  void _navigateToNetwork(NetworkApi network) async {
    
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContentScreen(networkId: network.id),
        ),
      );
      
      // Re-focus when returning
      if (mounted && currentFocusIndex < networkFocusNodes.length) {
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) {
            networkFocusNodes[currentFocusIndex].requestFocus();
          }
        });
      }
    } catch (e) {
    }
  }

  Future<void> _initializeData() async {
    // Load cached data first
    await _loadCachedNetworks();

    // Then fetch fresh data
    await _fetchNetworksInBackground();

    // Ensure loading is turned off even if both methods fail
    if (mounted && _isLoading) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCachedNetworks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedNetworks = prefs.getString('networks');

      if (cachedNetworks != null && cachedNetworks.isNotEmpty) {
        List<dynamic> cachedBody = json.decode(cachedNetworks);
        List<NetworkApi> networks = cachedBody
            .map((dynamic item) => NetworkApi.fromJson(item))
            .toList();

        if (mounted) {
          setState(() {
            _networks = networks;
            _isLoading = false;
            _cacheLoaded = true;
            _errorMessage = '';
          });

          // 🎯 SETUP FOCUS NODES after data is loaded
          _setupFocusNodes();

          // Start animations
          _headerAnimationController.forward();
          _networkAnimationController.forward();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading cached data: $e';
        });
      }
    }
  }

  Future<void> _fetchNetworksInBackground() async {
    try {
      final fetchedNetworks = await fetchNetworks(context);

      if (!mounted) return;

      // Update UI if data is different or if we don't have cached data
      if (!listEquals(_networks, fetchedNetworks) || !_cacheLoaded) {
        setState(() {
          _networks = fetchedNetworks;
          _isLoading = false;
          _errorMessage = '';
        });

        // 🎯 SETUP FOCUS NODES with new data
        _setupFocusNodes();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (!_cacheLoaded || _networks.isEmpty) {
            _errorMessage = 'Something went wrong';
          }
        });
      }

      // Handle authentication errors
      AuthErrorHandler.handleAuthError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
      final bgColor = colorProvider.isItemFocused
          ? colorProvider.dominantColor.withOpacity(0.1)
          : ProfessionalVODColors.primaryDark;

      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                bgColor,
                ProfessionalVODColors.primaryDark,
                ProfessionalVODColors.surfaceDark.withOpacity(0.5),
              ],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: screenhgt * 0.02),
              _buildSimpleHeader(),
              SizedBox(height: screenhgt * 0.02),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSimpleHeader() {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.025),
        child: Row(
          children: [
            // Simple accent line
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ProfessionalVODColors.accentBlue,
                    ProfessionalVODColors.accentPurple,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 12),

            // Simple title text
            Expanded(
              child: Text(
                'CONTENTS',
                style: TextStyle(
                  color: ProfessionalVODColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: 1.0,
                ),
              ),
            ),

            // Simple count badge
            if (_networks.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ProfessionalVODColors.accentBlue.withOpacity(0.2),
                      ProfessionalVODColors.accentPurple.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ProfessionalVODColors.accentBlue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_tree_rounded,
                      size: 14,
                      color: ProfessionalVODColors.textSecondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '${_networks.length} Networks',
                      style: TextStyle(
                        color: ProfessionalVODColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildProfessionalLoadingIndicator();
    }

    if (_errorMessage.isNotEmpty && _networks.isEmpty) {
      return _buildErrorWidget();
    }

    if (_networks.isEmpty) {
      return _buildNoNetworksWidget();
    }

    return _buildNetworksList();
  }

  Widget _buildProfessionalLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  ProfessionalVODColors.accentBlue,
                  ProfessionalVODColors.accentPurple,
                  ProfessionalVODColors.accentGreen,
                  ProfessionalVODColors.accentBlue,
                ],
              ),
            ),
            child: Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ProfessionalVODColors.primaryDark,
              ),
              child: Icon(
                Icons.play_circle_filled_rounded,
                color: ProfessionalVODColors.textPrimary,
                size: 28,
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Loading Networks...',
            style: TextStyle(
              color: ProfessionalVODColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ProfessionalVODColors.accentRed.withOpacity(0.2),
                  ProfessionalVODColors.accentRed.withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(
              Icons.error_outline,
              size: 40,
              color: ProfessionalVODColors.accentRed,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Error Loading Networks',
            style: TextStyle(
              color: ProfessionalVODColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ProfessionalVODColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = '';
              });
              // _fetchNetworksInBackground();
              _initializeDataWithFallback();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ProfessionalVODColors.accentBlue,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoNetworksWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Container(
          //   width: 80,
          //   height: 80,
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     gradient: LinearGradient(
          //       colors: [
          //         ProfessionalVODColors.accentPurple.withOpacity(0.2),
          //         ProfessionalVODColors.accentPurple.withOpacity(0.1),
          //       ],
          //     ),
          //   ),
          //   child: Icon(
          //     Icons.tv_off,
          //     size: 40,
          //     color: ProfessionalVODColors.accentPurple,
          //   ),
          // ),
          // SizedBox(height: 24),
          Text(
            '',
            style: TextStyle(
              color: ProfessionalVODColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '',
            style: TextStyle(
              color: ProfessionalVODColors.textSecondary,
              fontSize: 14,
            ),
          ),
          // SizedBox(height: 20),
          // ElevatedButton(
          //   onPressed: () {
          //     setState(() {
          //       _isLoading = true;
          //       _errorMessage = '';
          //     });
          //     _fetchNetworksInBackground();
          //   },
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: ProfessionalVODColors.accentBlue,
          //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          //   ),
          //   child: Text('Refresh'),
          // ),
        ],
      ),
    );
  }

  // 🎯 FIXED NETWORKS LIST - Use proper focus nodes and pass onTap function
  Widget _buildNetworksList() {
    return FadeTransition(
      opacity: _networkFadeAnimation,
      child: Container(
        height: screenhgt * 0.25,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.025),
          itemCount: _networks.length,
          itemBuilder: (context, index) {
            final network = _networks[index];

            // 🎯 USE PROPER FOCUS NODE for each item
            final focusNode = index < networkFocusNodes.length 
                ? networkFocusNodes[index] 
                : FocusNode();

            return ProfessionalNetworkCard(
              network: network,
              focusNode: focusNode,
              onTap: () => _navigateToNetwork(network), // 🎯 PROPER NAVIGATION
              index: index,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _networkAnimationController.dispose();
    
    // 🎯 DISPOSE ALL FOCUS NODES
    for (var node in networkFocusNodes) {
      node.dispose();
    }
    networkFocusNodes.clear();
    
    super.dispose();
  }
}

// 🎯 FIXED ProfessionalNetworkCard - Handle enter key properly
class ProfessionalNetworkCard extends StatefulWidget {
  final NetworkApi network;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int index;

  const ProfessionalNetworkCard({
    Key? key,
    required this.network,
    required this.focusNode,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  @override
  _ProfessionalNetworkCardState createState() =>
      _ProfessionalNetworkCardState();
}

class _ProfessionalNetworkCardState extends State<ProfessionalNetworkCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;

  Color _dominantColor = ProfessionalVODColors.accentBlue;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: VODAnimationTiming.focus,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: VODAnimationTiming.medium,
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });

    if (_isFocused) {
      _scaleController.forward();
      _glowController.forward();
      _generateDominantColor();
      HapticFeedback.lightImpact();
    } else {
      _scaleController.reverse();
      _glowController.reverse();
    }
  }

  void _generateDominantColor() {
    final colors = ProfessionalVODColors.gradientColors;
    _dominantColor = colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: screenwdt * 0.18,
            margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Column(
              children: [
                // 🎯 WRAP WITH FOCUS AND GESTURE DETECTOR
                Focus(
                  focusNode: widget.focusNode,
                  onKey: (FocusNode node, RawKeyEvent event) {
                    if (event is RawKeyDownEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.select ||
                          event.logicalKey == LogicalKeyboardKey.enter) {
                        widget.onTap();
                        return KeyEventResult.handled;
                      }
                    }
                    return KeyEventResult.ignored;
                  },
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: _buildNetworkPoster(),
                  ),
                ),
                SizedBox(height: 10),
                _buildNetworkTitle(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNetworkPoster() {
    return Container(
      height: screenhgt * 0.15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (_isFocused) ...[
            BoxShadow(
              color: _dominantColor.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 3,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: _dominantColor.withOpacity(0.2),
              blurRadius: 45,
              spreadRadius: 6,
              offset: Offset(0, 15),
            ),
          ] else ...[
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 5),
            ),
          ],
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            _buildNetworkImage(),
            if (_isFocused) _buildFocusBorder(),
            if (_isFocused) _buildShimmerEffect(),
            _buildNetworkBadge(),
            if (_isFocused) _buildHoverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: displayImage(
        widget.network.logo,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildFocusBorder() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 3,
            color: _dominantColor,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
                end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
                colors: [
                  Colors.transparent,
                  _dominantColor.withOpacity(0.15),
                  Colors.transparent,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNetworkBadge() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ProfessionalVODColors.accentGreen,
              ),
            ),
            SizedBox(width: 4),
            Text(
              '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoverOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              _dominantColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkTitle() {
    final networkName = widget.network.name.toUpperCase();

    return Container(
      width: screenwdt * 0.16,
      child: AnimatedDefaultTextStyle(
        duration: VODAnimationTiming.medium,
        style: TextStyle(
          fontSize: _isFocused ? 13 : 11,
          fontWeight: FontWeight.w600,
          color:
              _isFocused ? _dominantColor : ProfessionalVODColors.textPrimary,
          letterSpacing: 0.5,
          shadows: _isFocused
              ? [
                  Shadow(
                    color: _dominantColor.withOpacity(0.6),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          networkName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ================================
// FOCUSPROVIDER में बस यह method होना चाहिए:
// ================================

/*
class FocusProvider extends ChangeNotifier {
  FocusNode? _firstSubVodFocusNode;
  
  // Set focus node
  void setFirstSubVodFocusNode(FocusNode node) {
    _firstSubVodFocusNode = node;
  }
  
  // Request focus method जो down arrow पर call होगा
  void requestFirstSubVodFocus() {
    if (_firstSubVodFocusNode != null) {
      _firstSubVodFocusNode!.requestFocus();
    } else {
    }
  }
  
  // Other existing methods...
  void requestMusicItemFocus(BuildContext context) {
    // Your existing music focus logic
  }
  
  void requestFirstMoviesFocus() {
    // Your existing movies focus logic  
  }
}
*/

// Updated Movie model for getAllMovies API
class MovieItem {
  final int id;
  final String name;
  final String description;
  final String genres;
  final String releaseDate;
  final int? runtime;
  final String sourceType;
  final String? youtubeTrailer;
  final String movieUrl;
  final String? poster;
  final String? banner;
  final int status;
  final int contentType;
  final List<NetworkInfo> networks;

  MovieItem({
    required this.id,
    required this.name,
    required this.description,
    required this.genres,
    required this.releaseDate,
    this.runtime,
    required this.sourceType,
    this.youtubeTrailer,
    required this.movieUrl,
    this.poster,
    this.banner,
    required this.status,
    required this.contentType,
    required this.networks,
  });

  factory MovieItem.fromJson(Map<String, dynamic> json) {
    var networksFromJson = json['networks'] as List? ?? [];
    List<NetworkInfo> networksList = networksFromJson
        .map((networkJson) => NetworkInfo.fromJson(networkJson))
        .toList();

    return MovieItem(
      id: safeParseInt(json['id']),
      name: safeParseString(json['name'], defaultValue: 'No Name'),
      description: safeParseString(json['description'], defaultValue: ''),
      genres: safeParseString(json['genres'], defaultValue: 'Unknown'),
      releaseDate: safeParseString(json['release_date'], defaultValue: ''),
      runtime: json['runtime'] != null ? safeParseInt(json['runtime']) : null,
      sourceType: safeParseString(json['source_type'], defaultValue: ''),
      youtubeTrailer: json['youtube_trailer'],
      movieUrl: safeParseString(json['movie_url'], defaultValue: ''),
      poster: json['poster'],
      banner: json['banner'],
      status: safeParseInt(json['status']),
      contentType: safeParseInt(json['content_type']),
      networks: networksList,
    );
  }

  // Helper method to check if movie is active
  bool get isActive => status == 1;

  // Get best image URL
  String get bestImageUrl {
    if (poster != null && poster!.isNotEmpty && poster != 'localImage') {
      return poster!;
    } else if (banner != null && banner!.isNotEmpty && banner != 'localImage') {
      return banner!;
    } else {
      return 'localImage';
    }
  }

  // Get banner URL for video screen
  String get bannerUrl {
    if (banner != null && banner!.isNotEmpty && banner != 'localImage') {
      return banner!;
    } else if (poster != null && poster!.isNotEmpty && poster != 'localImage') {
      return poster!;
    } else {
      return 'localImage';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MovieItem &&
        other.id == id &&
        other.name == name &&
        other.movieUrl == movieUrl &&
        other.status == status;
  }

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ movieUrl.hashCode ^ status.hashCode;
}

class NetworkInfo {
  final int id;
  final String name;
  final String logo;

  NetworkInfo({
    required this.id,
    required this.name,
    required this.logo,
  });

  factory NetworkInfo.fromJson(Map<String, dynamic> json) {
    return NetworkInfo(
      id: safeParseInt(json['id']),
      name: safeParseString(json['name'], defaultValue: 'Unknown Network'),
      logo: safeParseString(json['logo'], defaultValue: 'localImage'),
    );
  }
}

// Updated fetch function for movies
Future<List<MovieItem>> fetchAllMovies(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final cachedMovies = prefs.getString('all_movies');

  List<MovieItem> movies = [];
  List<MovieItem> apiMovies = [];

  // Step 1: Use cached data for fast UI rendering
  if (cachedMovies != null) {
    try {
      List<dynamic> cachedBody = json.decode(cachedMovies);
      movies =
          cachedBody.map((dynamic item) => MovieItem.fromJson(item)).toList();
    } catch (e) {
      prefs.remove('all_movies');
    }
  }

  // Step 2: Fetch API data in the background
  try {
    final headers = await ApiService.getHeaders();

    final response = await https.get(
      Uri.parse('${ApiService.baseUrl}getAllMovies'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      apiMovies = body.map((dynamic item) => MovieItem.fromJson(item)).toList();

      // Step 3: Compare cached data with API data
      if (!listEquals(movies, apiMovies)) {
        prefs.setString('all_movies', response.body);
        return apiMovies;
      }
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('Something went wrong');
    }
  } catch (e) {
    if (movies.isEmpty) {
      rethrow; // Only throw if no cached data available
    }
  }

  return movies;
}

// Filter movies by network ID
List<MovieItem> filterMoviesByNetwork(List<MovieItem> movies, int networkId) {
  return movies.where((movie) {
    return movie.networks.any((network) => network.id == networkId) &&
        movie.isActive;
  }).toList();
}

// Modified fetchAllMovies function to get movie URL by content ID
Future<String?> fetchMovieUrlByContentId(
    BuildContext context, int contentId) async {

  final prefs = await SharedPreferences.getInstance();
  final cacheKey = 'movie_url_$contentId';
  final cachedUrl = prefs.getString(cacheKey);

  // Check cache first
  if (cachedUrl != null && cachedUrl.isNotEmpty) {
    return cachedUrl;
  }

  try {
    final headers = await ApiService.getHeaders();

    final response = await https.get(
      Uri.parse('${ApiService.baseUrl}getAllMovies'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);


      // Search for movie with matching content ID
      for (var movieJson in body) {
        final MovieItem movie = MovieItem.fromJson(movieJson);


        // Match content ID with movie ID
        if (movie.id == contentId &&
            movie.isActive &&
            movie.movieUrl.isNotEmpty) {

          // Cache the result
          prefs.setString(cacheKey, movie.movieUrl);
          return movie.movieUrl;
        }
      }

      return null;
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('Failed to fetch movies: ${response.statusCode}');
    }
  } catch (e) {
    rethrow;
  }
}

// Create a content ID to movie URL mapping
Future<Map<int, String>> createContentToMovieUrlMap(
    BuildContext context, List<int> contentIds) async {

  Map<int, String> urlMap = {};

  try {
    final headers = await ApiService.getHeaders();

    final response = await https.get(
      Uri.parse('${ApiService.baseUrl}getAllMovies'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);

      for (var movieJson in body) {
        final MovieItem movie = MovieItem.fromJson(movieJson);

        // If this movie ID matches any of our content IDs
        if (contentIds.contains(movie.id) &&
            movie.isActive &&
            movie.movieUrl.isNotEmpty) {
          urlMap[movie.id] = movie.movieUrl;
        }
      }

      return urlMap;
    } else {
      throw Exception('Failed to fetch movies: ${response.statusCode}');
    }
  } catch (e) {
    return urlMap; // Return empty map on error
  }
}



class VOD extends StatefulWidget {
  @override
  _VODState createState() => _VODState();
}

class _VODState extends State<VOD> with TickerProviderStateMixin {
  List<NetworkApi> _networks = [];
  bool _isLoading = true;
  bool _cacheLoaded = false;
  Map<int, FocusNode> firstRowFocusNodes = {};

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _gridAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _gridFadeAnimation;

  @override
  void initState() {
    super.initState();

    _initializeAnimations();

    // Initialize focus nodes for first row items
    for (int i = 0; i < 5; i++) {
      final focusNode = FocusNode();
      firstRowFocusNodes[i] = focusNode;

      focusNode.onKey = (node, event) {
        if (event is RawKeyDownEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowUp:
              context.read<FocusProvider>().requestVodMenuFocus();
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowLeft:
              if (i > 0) {
                firstRowFocusNodes[i - 1]?.requestFocus();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            case LogicalKeyboardKey.arrowRight:
              if (i < 4 && i < _networks.length - 1) {
                firstRowFocusNodes[i + 1]?.requestFocus();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            case LogicalKeyboardKey.arrowDown:
              if (_networks.length > 5) {
                FocusScope.of(context).nextFocus();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
          }
        }
        return KeyEventResult.ignored;
      };
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (firstRowFocusNodes.containsKey(0)) {
        context
            .read<FocusProvider>()
            .setFirstVodBannerFocusNode(firstRowFocusNodes[0]!);
        firstRowFocusNodes[0]?.requestFocus();
      }
    });

    _loadCachedNetworks();
    _fetchNetworksInBackground();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: VODAnimationTiming.slow,
      vsync: this,
    );

    _gridAnimationController = AnimationController(
      duration: VODAnimationTiming.slow,
      vsync: this,
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _gridFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gridAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadCachedNetworks() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedNetworks = prefs.getString('networks');

    if (cachedNetworks != null) {
      try {
        List<dynamic> cachedBody = json.decode(cachedNetworks);
        setState(() {
          _networks = cachedBody
              .map((dynamic item) => NetworkApi.fromJson(item))
              .toList();
          _isLoading = false;
          _cacheLoaded = true;
        });

        // Start animations
        _headerAnimationController.forward();
        _gridAnimationController.forward();
      } catch (e) {}
    }
  }

  Future<void> _fetchNetworksInBackground() async {
    try {
      final fetchedNetworks = await fetchNetworks(context);

      if (!listEquals(_networks, fetchedNetworks)) {
        setState(() {
          _networks = fetchedNetworks;
        });
      }
    } catch (e) {
      AuthErrorHandler.handleAuthError(context, e);

      if (!_cacheLoaded) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.read<FocusProvider>().requestWatchNowFocus();
        }
      },
      child: Consumer<ColorProvider>(builder: (context, colorProvider, child) {
        final bgColor = colorProvider.isItemFocused
            ? colorProvider.dominantColor.withOpacity(0.1)
            : ProfessionalVODColors.primaryDark;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bgColor,
                  ProfessionalVODColors.primaryDark,
                  ProfessionalVODColors.surfaceDark.withOpacity(0.5),
                ],
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: screenhgt * 0.02),
                _buildProfessionalVODHeader(),
                SizedBox(height: screenhgt * 0.02),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfessionalVODHeader() {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.025),
        child: Column(
          children: [
            // Main Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Side - Title with Icon
                Row(
                  children: [
                    // Animated Icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ProfessionalVODColors.accentPurple,
                            ProfessionalVODColors.accentPink,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: ProfessionalVODColors.accentPurple
                                .withOpacity(0.3),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.dashboard_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),

                    // Title Text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              ProfessionalVODColors.accentPurple,
                              ProfessionalVODColors.accentPink,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'VIDEO ON DEMAND',
                            style: TextStyle(
                              fontSize: Headingtextsz + 2,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Browse All Network Content',
                          style: TextStyle(
                            color: ProfessionalVODColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Right Side - Grid Stats
                if (_networks.isNotEmpty)
                  Row(
                    children: [
                      // Grid View Badge
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ProfessionalVODColors.accentGreen
                                  .withOpacity(0.3),
                              ProfessionalVODColors.accentBlue.withOpacity(0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: ProfessionalVODColors.accentGreen
                                .withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.grid_view_rounded,
                              size: 16,
                              color: ProfessionalVODColors.accentGreen,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'GRID VIEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 12),

                      // Networks Count
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ProfessionalVODColors.accentPurple
                                  .withOpacity(0.3),
                              ProfessionalVODColors.accentPink.withOpacity(0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: ProfessionalVODColors.accentPurple
                                .withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.account_tree_rounded,
                              size: 16,
                              color: ProfessionalVODColors.accentPurple,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '${_networks.length} NETWORKS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            SizedBox(height: 16),

            // Enhanced Grid Stats Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    ProfessionalVODColors.surfaceDark.withOpacity(0.6),
                    ProfessionalVODColors.cardDark.withOpacity(0.8),
                    ProfessionalVODColors.surfaceDark.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: ProfessionalVODColors.accentPurple.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildVODStatItem(
                    icon: Icons.view_module_rounded,
                    label: 'LAYOUT',
                    value: '5x∞',
                    color: ProfessionalVODColors.accentBlue,
                  ),
                  _buildVODDivider(),
                  _buildVODStatItem(
                    icon: Icons.visibility_rounded,
                    label: 'BROWSING',
                    value: 'EASY',
                    color: ProfessionalVODColors.accentGreen,
                  ),
                  _buildVODDivider(),
                  _buildVODStatItem(
                    icon: Icons.search_rounded,
                    label: 'DISCOVERY',
                    value: 'SMART',
                    color: ProfessionalVODColors.accentOrange,
                  ),
                  _buildVODDivider(),
                  _buildVODStatItem(
                    icon: Icons.favorite_rounded,
                    label: 'FAVORITES',
                    value: 'SAVE',
                    color: ProfessionalVODColors.accentPink,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVODStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: ProfessionalVODColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildVODDivider() {
    return Container(
      height: 30,
      width: 1,
      color: ProfessionalVODColors.accentPurple.withOpacity(0.3),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildProfessionalVODLoadingIndicator();
    } else if (_networks.isNotEmpty) {
      return _buildNetworksList();
    } else {
      return _buildNoNetworksMessage();
    }
  }

  Widget _buildProfessionalVODLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  ProfessionalVODColors.accentPurple,
                  ProfessionalVODColors.accentPink,
                  ProfessionalVODColors.accentBlue,
                  ProfessionalVODColors.accentPurple,
                ],
              ),
            ),
            child: Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ProfessionalVODColors.primaryDark,
              ),
              child: Icon(
                Icons.dashboard_rounded,
                color: ProfessionalVODColors.textPrimary,
                size: 28,
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Loading VOD Content...',
            style: TextStyle(
              color: ProfessionalVODColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoNetworksMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ProfessionalVODColors.accentPurple.withOpacity(0.2),
                  ProfessionalVODColors.accentPurple.withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(
              Icons.tv_off,
              size: 40,
              color: ProfessionalVODColors.accentPurple,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Networks Available',
            style: TextStyle(
              color: ProfessionalVODColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Check your connection and try again',
            style: TextStyle(
              color: ProfessionalVODColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworksList() {
    return FadeTransition(
      opacity: _gridFadeAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.025),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: _networks.length,
          itemBuilder: (context, index) {
            final network = _networks[index];
            final isFirstRow = index < 5;

            return ProfessionalVODGridCard(
              network: network,
              focusNode: isFirstRow ? firstRowFocusNodes[index] : null,
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContentScreen(networkId: network.id),
                  ),
                );
              },
              index: index,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _gridAnimationController.dispose();
    firstRowFocusNodes.values.forEach((node) => node.dispose());
    super.dispose();
  }
}

// ================================
// 5. PROFESSIONAL VOD GRID CARD
// ================================

class ProfessionalVODGridCard extends StatefulWidget {
  final NetworkApi network;
  final FocusNode? focusNode;
  final VoidCallback onTap;
  final int index;

  const ProfessionalVODGridCard({
    Key? key,
    required this.network,
    this.focusNode,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  @override
  _ProfessionalVODGridCardState createState() =>
      _ProfessionalVODGridCardState();
}

class _ProfessionalVODGridCardState extends State<ProfessionalVODGridCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  Color _dominantColor = ProfessionalVODColors.accentPurple;
  bool _isFocused = false;
  late FocusNode _effectiveFocusNode;

  @override
  void initState() {
    super.initState();

    _effectiveFocusNode = widget.focusNode ?? FocusNode();

    _hoverController = AnimationController(
      duration: VODAnimationTiming.focus,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: VODAnimationTiming.medium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _effectiveFocusNode.hasFocus;
    });

    if (_isFocused) {
      _hoverController.forward();
      _glowController.forward();
      _generateDominantColor();
      HapticFeedback.lightImpact();
    } else {
      _hoverController.reverse();
      _glowController.reverse();
    }
  }

  void _generateDominantColor() {
    final colors = ProfessionalVODColors.gradientColors;
    _dominantColor = colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _glowController.dispose();
    _effectiveFocusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _effectiveFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _effectiveFocusNode,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    if (_isFocused) ...[
                      BoxShadow(
                        color: _dominantColor.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: Offset(0, 8),
                      ),
                      BoxShadow(
                        color: _dominantColor.withOpacity(0.2),
                        blurRadius: 35,
                        spreadRadius: 4,
                        offset: Offset(0, 12),
                      ),
                    ] else ...[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      _buildNetworkImage(),
                      if (_isFocused) _buildFocusBorder(),
                      _buildGradientOverlay(),
                      _buildNetworkInfo(),
                      if (_isFocused) _buildPlayButton(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNetworkImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: displayImage(
        widget.network.logo,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildFocusBorder() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 3,
            color: _dominantColor,
          ),
        ),
      ),
    );
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
              Colors.transparent,
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkInfo() {
    final networkName = widget.network.name;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              networkName.toUpperCase(),
              style: TextStyle(
                color: _isFocused ? _dominantColor : Colors.white,
                fontSize: _isFocused ? 13 : 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (_isFocused) ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _dominantColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _dominantColor.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ProfessionalVODColors.accentGreen,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: _dominantColor,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'HD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

// 🎨 PROFESSIONAL SUBVOD & VOD UI PART 3 - FINAL CODE

// ================================
// CONTINUED FROM PART 2 - VOD GRID CARD COMPLETION
// ================================

  Widget _buildPlayButton() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _dominantColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: _dominantColor.withOpacity(0.4),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

// ================================
// 6. PROFESSIONAL CONTENT SCREEN
// ================================

class ContentScreen extends StatefulWidget {
  final int networkId;

  ContentScreen({required this.networkId});

  @override
  _ContentScreenState createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen>
    with TickerProviderStateMixin {
  List<NewsItemModel> _content = [];
  Map<int, String> _contentToMovieUrlMap = {};
  bool _isLoading = true;
  bool _isVideoLoading = false;
  String _loadingMovieName = '';
  String _errorMessage = '';
  FocusNode firstItemFocusNode = FocusNode();
  bool _isVideoPlaying = false;
  final SocketService _socketService = SocketService();

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _gridAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _gridFadeAnimation;

  @override
  void initState() {
    super.initState();

    _initializeAnimations();
    _socketService.initSocket();
    _loadData();

    Future.delayed(Duration(milliseconds: 50), () {
      firstItemFocusNode.requestFocus();
    });
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: VODAnimationTiming.slow,
      vsync: this,
    );

    _gridAnimationController = AnimationController(
      duration: VODAnimationTiming.slow,
      vsync: this,
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _gridFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gridAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {

      // Step 1: Load content first
      _content = await fetchContent(context, widget.networkId);

      // Step 2: Extract content IDs
      List<int> contentIds = _content
          .map((item) => int.tryParse(item.id) ?? 0)
          .where((id) => id > 0)
          .toList();


      // Step 3: Create content ID to movie URL mapping
      _contentToMovieUrlMap =
          await createContentToMovieUrlMap(context, contentIds);


      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '';
        });

        // Start animations
        _headerAnimationController.forward();
        _gridAnimationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading data: $e';
        });
      }
      AuthErrorHandler.handleAuthError(context, e);
    }
  }

  String _getVideoUrl(NewsItemModel contentItem) {
    int contentId = int.tryParse(contentItem.id) ?? 0;


    if (_contentToMovieUrlMap.containsKey(contentId)) {
      String movieUrl = _contentToMovieUrlMap[contentId]!;
      return movieUrl;
    }

    return contentItem.url;
  }

  bool _isYouTubeUrl(String url) {
    if (url.isEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url) ||
        url.contains('youtube.com') ||
        url.contains('youtu.be');
  }

  Future<void> _playVideo(NewsItemModel contentItem) async {
    if (_isVideoPlaying || _isVideoLoading) return;

    setState(() {
      _isVideoLoading = true;
      _loadingMovieName = contentItem.name;
      _isVideoPlaying = true;
    });

    try {
      int contentId = int.tryParse(contentItem.id) ?? 0;


      String? originalUrl = await fetchMovieUrlByContentId(context, contentId);
      String? updatedUrl = await fetchMovieUrlByContentId(context, contentId);

      String urlSource =
          _contentToMovieUrlMap.containsKey(contentId) ? 'movie' : 'content';

      // if (_isYouTubeUrl(updatedUrl ?? '')) {
      //   final playUrl = await _socketService.getUpdatedUrl(updatedUrl ?? '');
      //   if (playUrl.isNotEmpty) {
      //     updatedUrl = playUrl;
      //   } else {
      //   }
      // }


      await Navigator.push(
        context,
        MaterialPageRoute(
          // builder: (context) => VideoScreen(
          //   channelList: _content,
          //   source: 'isContentScreen',
          //   name: contentItem.name,
          //   videoUrl: updatedUrl ?? '',
          //   unUpdatedUrl: originalUrl ?? contentItem.url,
          //   bannerImageUrl: contentItem.banner,
          //   startAtPosition: Duration.zero,
          //   videoType: '',
          //   isLive: false,
          //   isVOD: true,
          //   isLastPlayedStored: false,
          //   isSearch: false,
          //   isBannerSlider: false,
          //   videoId: contentId,
          //   seasonId: 0,
          //   liveStatus: false,
          // ),

                builder: (context) => YouTubePlayerScreen(
                 videoData: VideoData(
                   id: contentItem.id,
                   title: contentItem.name,
                   youtubeUrl: originalUrl??'',
                   thumbnail: contentItem.banner,
                  //  description:'',
                 ),
                 playlist: _content.map((m) => VideoData(
                   id: m.id,
                   title: m.name,
                   youtubeUrl: m.url,
                   thumbnail: m.banner,
                  //  description: m.description,
                 )).toList(),
              ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error playing video: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
          _isVideoPlaying = false;
          _loadingMovieName = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
      final bgColor = colorProvider.isItemFocused
          ? colorProvider.dominantColor.withOpacity(0.1)
          : ProfessionalVODColors.primaryDark;

      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                bgColor,
                ProfessionalVODColors.primaryDark,
                ProfessionalVODColors.surfaceDark.withOpacity(0.5),
              ],
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: screenhgt * 0.02),
                  _buildProfessionalContentHeader(),
                  SizedBox(height: screenhgt * 0.02),
                  Expanded(child: _buildBody()),
                ],
              ),
              // Video loading overlay
              if (_isVideoLoading) _buildVideoLoadingOverlay(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildProfessionalContentHeader() {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.025),
        child: Column(
          children: [
            // Main Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Side - Back Button + Title
                Row(
                  children: [
                    // Back Button
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ProfessionalVODColors.accentBlue.withOpacity(0.3),
                            ProfessionalVODColors.accentPurple.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color:
                              ProfessionalVODColors.accentBlue.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: 16),

                    // Title Text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              ProfessionalVODColors.accentBlue,
                              ProfessionalVODColors.accentPurple,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'NETWORK CONTENT',
                            style: TextStyle(
                              fontSize: Headingtextsz,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Browse Available Movies & Shows',
                          style: TextStyle(
                            color: ProfessionalVODColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Right Side - Content Stats
                if (_content.isNotEmpty)
                  Row(
                    children: [
                      // Movie URLs Badge
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ProfessionalVODColors.accentGreen
                                  .withOpacity(0.3),
                              ProfessionalVODColors.accentBlue.withOpacity(0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: ProfessionalVODColors.accentGreen
                                .withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.movie_rounded,
                              size: 14,
                              color: ProfessionalVODColors.accentGreen,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '${_contentToMovieUrlMap.length} MOVIES',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 8),

                      // Total Content Badge
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ProfessionalVODColors.accentPurple
                                  .withOpacity(0.3),
                              ProfessionalVODColors.accentPink.withOpacity(0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: ProfessionalVODColors.accentPurple
                                .withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.library_books_rounded,
                              size: 14,
                              color: ProfessionalVODColors.accentPurple,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '${_content.length} TOTAL',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    ProfessionalVODColors.accentBlue,
                    ProfessionalVODColors.accentPurple,
                    ProfessionalVODColors.accentGreen,
                    ProfessionalVODColors.accentBlue,
                  ],
                ),
              ),
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ProfessionalVODColors.primaryDark,
                ),
                child: Icon(
                  Icons.play_circle_filled_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Loading Video...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              _loadingMovieName,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingIndicator();
    } else if (_errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    } else if (_content.isEmpty) {
      return _buildNoContentWidget();
    } else {
      return _buildContentGrid();
    }
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  ProfessionalVODColors.accentBlue,
                  ProfessionalVODColors.accentPurple,
                  ProfessionalVODColors.accentGreen,
                  ProfessionalVODColors.accentBlue,
                ],
              ),
            ),
            child: Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ProfessionalVODColors.primaryDark,
              ),
              child: Icon(
                Icons.movie_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Loading content and movies...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ProfessionalVODColors.accentRed.withOpacity(0.2),
                  ProfessionalVODColors.accentRed.withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(
              Icons.error_outline,
              size: 40,
              color: ProfessionalVODColors.accentRed,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Error Loading Content',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage,
            style: TextStyle(
              color: ProfessionalVODColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: ProfessionalVODColors.accentBlue,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoContentWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ProfessionalVODColors.accentPurple.withOpacity(0.2),
                  ProfessionalVODColors.accentPurple.withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(
              Icons.movie_outlined,
              size: 40,
              color: ProfessionalVODColors.accentPurple,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Content Available',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This network has no content to display',
            style: TextStyle(
              color: ProfessionalVODColors.textSecondary,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: ProfessionalVODColors.accentBlue,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildContentGrid() {
    return FadeTransition(
      opacity: _gridFadeAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.025),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 0.8,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: _content.length,
          itemBuilder: (context, index) {
            final contentItem = _content[index];
            int contentId = int.tryParse(contentItem.id) ?? 0;
            bool hasMovieUrl = _contentToMovieUrlMap.containsKey(contentId);

            String imageUrl = contentItem.poster.isNotEmpty &&
                    contentItem.poster != 'localImage'
                ? contentItem.poster
                : contentItem.banner.isNotEmpty &&
                        contentItem.banner != 'localImage'
                    ? contentItem.banner
                    : 'localImage';

            return Stack(
              children: [
                Opacity(
                  opacity: _isVideoLoading ? 0.5 : 1.0,
                  child: ProfessionalContentCard(
                    contentItem: contentItem,
                    focusNode: index == 0 ? firstItemFocusNode : null,
                    onTap:
                        _isVideoLoading ? () {} : () => _playVideo(contentItem),
                    hasMovieUrl: hasMovieUrl,
                    index: index,
                  ),
                ),

                // Individual item loading indicator
                if (_isVideoLoading && _loadingMovieName == contentItem.name)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Loading...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _gridAnimationController.dispose();
    firstItemFocusNode.dispose();
    _socketService.dispose();
    super.dispose();
  }
}

// ================================
// 7. PROFESSIONAL CONTENT CARD
// ================================

class ProfessionalContentCard extends StatefulWidget {
  final NewsItemModel contentItem;
  final FocusNode? focusNode;
  final VoidCallback onTap;
  final bool hasMovieUrl;
  final int index;

  const ProfessionalContentCard({
    Key? key,
    required this.contentItem,
    this.focusNode,
    required this.onTap,
    required this.hasMovieUrl,
    required this.index,
  }) : super(key: key);

  @override
  _ProfessionalContentCardState createState() =>
      _ProfessionalContentCardState();
}

class _ProfessionalContentCardState extends State<ProfessionalContentCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  Color _dominantColor = ProfessionalVODColors.accentBlue;
  bool _isFocused = false;
  late FocusNode _effectiveFocusNode;

  @override
  void initState() {
    super.initState();

    _effectiveFocusNode = widget.focusNode ?? FocusNode();

    _hoverController = AnimationController(
      duration: VODAnimationTiming.focus,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: VODAnimationTiming.medium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _effectiveFocusNode.hasFocus;
    });

    if (_isFocused) {
      _hoverController.forward();
      _glowController.forward();
      _generateDominantColor();
      HapticFeedback.lightImpact();
    } else {
      _hoverController.reverse();
      _glowController.reverse();
    }
  }

  void _generateDominantColor() {
    final colors = ProfessionalVODColors.gradientColors;
    _dominantColor = colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _glowController.dispose();
    _effectiveFocusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _effectiveFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _effectiveFocusNode,
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            widget.onTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    if (_isFocused) ...[
                      BoxShadow(
                        color: _dominantColor.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: Offset(0, 8),
                      ),
                      BoxShadow(
                        color: _dominantColor.withOpacity(0.2),
                        blurRadius: 35,
                        spreadRadius: 4,
                        offset: Offset(0, 12),
                      ),
                    ] else ...[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      _buildContentImage(),
                      if (_isFocused) _buildFocusBorder(),
                      _buildGradientOverlay(),
                      _buildContentInfo(),
                      _buildSourceIndicator(),
                      if (_isFocused) _buildPlayButton(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContentImage() {
    String imageUrl = widget.contentItem.poster.isNotEmpty &&
            widget.contentItem.poster != 'localImage'
        ? widget.contentItem.poster
        : widget.contentItem.banner.isNotEmpty &&
                widget.contentItem.banner != 'localImage'
            ? widget.contentItem.banner
            : 'localImage';

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: displayImage(
        imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  // 🎨 PROFESSIONAL SUBVOD & VOD UI PART 4 - FINAL COMPLETE CODE

// ================================
// CONTINUED FROM PART 3 - CONTENT CARD COMPLETION
// ================================

  Widget _buildFocusBorder() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 3,
            color: _dominantColor,
          ),
        ),
      ),
    );
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
              Colors.transparent,
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentInfo() {
    final contentName = widget.contentItem.name;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              contentName.toUpperCase(),
              style: TextStyle(
                color: _isFocused ? _dominantColor : Colors.white,
                fontSize: _isFocused ? 13 : 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (_isFocused) ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.hasMovieUrl
                          ? ProfessionalVODColors.accentGreen.withOpacity(0.2)
                          : ProfessionalVODColors.accentOrange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.hasMovieUrl
                            ? ProfessionalVODColors.accentGreen.withOpacity(0.4)
                            : ProfessionalVODColors.accentOrange
                                .withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.hasMovieUrl
                              ? Icons.movie_rounded
                              : Icons.tv_rounded,
                          color: widget.hasMovieUrl
                              ? ProfessionalVODColors.accentGreen
                              : ProfessionalVODColors.accentOrange,
                          size: 8,
                        ),
                        SizedBox(width: 2),
                        Text(
                          widget.hasMovieUrl ? 'MOVIE' : 'CONTENT',
                          style: TextStyle(
                            color: widget.hasMovieUrl
                                ? ProfessionalVODColors.accentGreen
                                : ProfessionalVODColors.accentOrange,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'HD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSourceIndicator() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: widget.hasMovieUrl
              ? ProfessionalVODColors.accentGreen.withOpacity(0.9)
              : ProfessionalVODColors.accentOrange.withOpacity(0.9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          widget.hasMovieUrl ? 'HD' : '',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _dominantColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: _dominantColor.withOpacity(0.4),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}




// // ================================
// // 8. PROFESSIONAL DETAILS PAGE
// // ================================

// class DetailsPage extends StatefulWidget {
//   final int id;
//   final List<NewsItemModel> channelList;
//   final String source;
//   final String banner;
//   final String name;

//   DetailsPage({
//     required this.id,
//     required this.channelList,
//     required this.source,
//     required this.banner,
//     required this.name,
//   });

//   @override
//   _DetailsPageState createState() => _DetailsPageState();
// }

// class _DetailsPageState extends State<DetailsPage>
//     with TickerProviderStateMixin {
//   final SocketService _socketService = SocketService();
//   MovieDetailsApi? _movieDetails;
//   bool _isLoading = false;
//   bool _isVideoPlaying = false;
//   Timer? _timer;
//   bool _isReturningFromVideo = false;
//   FocusNode firstItemFocusNode = FocusNode();
//   Color headingColor = ProfessionalVODColors.accentBlue;

//   // Animation Controllers
//   late AnimationController _backgroundAnimationController;
//   late AnimationController _contentAnimationController;
//   late Animation<double> _backgroundFadeAnimation;
//   late Animation<Offset> _contentSlideAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _initializeAnimations();
//     _socketService.initSocket();
//     checkServerStatus();

//     Future.delayed(Duration(milliseconds: 100), () async {
//       await _loadCachedAndFetchMovieDetails(widget.id);
//       if (_movieDetails != null) {
//         _fetchAndSetHeadingColor(_movieDetails!.banner);
//       }
//       firstItemFocusNode.requestFocus();
//     });
//   }

//   void _initializeAnimations() {
//     _backgroundAnimationController = AnimationController(
//       duration: VODAnimationTiming.slow,
//       vsync: this,
//     );

//     _contentAnimationController = AnimationController(
//       duration: VODAnimationTiming.slow,
//       vsync: this,
//     );

//     _backgroundFadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _backgroundAnimationController,
//       curve: Curves.easeInOut,
//     ));

//     _contentSlideAnimation = Tween<Offset>(
//       begin: Offset(0, 1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _contentAnimationController,
//       curve: Curves.easeOutCubic,
//     ));
//   }

//   @override
//   void dispose() {
//     _backgroundAnimationController.dispose();
//     _contentAnimationController.dispose();
//     _socketService.dispose();
//     _timer?.cancel();
//     firstItemFocusNode.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchAndSetHeadingColor(String bannerUrl) async {
//     try {
//       Color paletteColor = await fetchPaletteColor(bannerUrl);
//       setState(() {
//         headingColor = paletteColor;
//       });
//     } catch (e) {
//       setState(() {
//         headingColor = ProfessionalVODColors.accentBlue;
//       });
//     }
//   }

//   Future<void> _loadCachedAndFetchMovieDetails(int contentId) async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final movieDetails = await fetchMovieDetails(context, contentId);

//       if (!mounted) return;

//       setState(() {
//         _movieDetails = movieDetails;
//         _isLoading = false;
//       });

//       // Start animations
//       _backgroundAnimationController.forward();
//       _contentAnimationController.forward();

//       if (movieDetails.banner.isNotEmpty) {
//         _fetchAndSetHeadingColor(movieDetails.banner);
//       }
//     } catch (e) {
//       AuthErrorHandler.handleAuthError(context, e);

//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _movieDetails = null;
//         });
//       }
//     }
//   }

//   void checkServerStatus() {
//     Timer.periodic(Duration(seconds: 10), (timer) {
//       if (!_socketService.socket!.connected) {
//         _socketService.initSocket();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalVODColors.primaryDark,
//       body: _isLoading
//           ? _buildProfessionalLoadingIndicator()
//           : _isReturningFromVideo
//               ? _buildReturningIndicator()
//               : _movieDetails != null
//                   ? _buildMovieDetailsUI(context, _movieDetails!)
//                   : _buildErrorIndicator(),
//     );
//   }

//   Widget _buildProfessionalLoadingIndicator() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             ProfessionalVODColors.primaryDark,
//             ProfessionalVODColors.surfaceDark,
//           ],
//         ),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: SweepGradient(
//                   colors: [
//                     ProfessionalVODColors.accentBlue,
//                     ProfessionalVODColors.accentPurple,
//                     ProfessionalVODColors.accentGreen,
//                     ProfessionalVODColors.accentBlue,
//                   ],
//                 ),
//               ),
//               child: Container(
//                 margin: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: ProfessionalVODColors.primaryDark,
//                 ),
//                 child: Icon(
//                   Icons.movie_rounded,
//                   color: Colors.white,
//                   size: 32,
//                 ),
//               ),
//             ),
//             SizedBox(height: 24),
//             Text(
//               'Loading Movie Details...',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildReturningIndicator() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             ProfessionalVODColors.primaryDark,
//             ProfessionalVODColors.surfaceDark,
//           ],
//         ),
//       ),
//       child: Center(
//         child: Text(
//           '',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorIndicator() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             ProfessionalVODColors.primaryDark,
//             ProfessionalVODColors.surfaceDark,
//           ],
//         ),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: LinearGradient(
//                   colors: [
//                     ProfessionalVODColors.accentRed.withOpacity(0.2),
//                     ProfessionalVODColors.accentRed.withOpacity(0.1),
//                   ],
//                 ),
//               ),
//               child: Icon(
//                 Icons.error_outline,
//                 size: 40,
//                 color: ProfessionalVODColors.accentRed,
//               ),
//             ),
//             SizedBox(height: 24),
//             Text(
//               'Failed to Load Details',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMovieDetailsUI(
//       BuildContext context, MovieDetailsApi movieDetails) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             ProfessionalVODColors.primaryDark,
//             ProfessionalVODColors.surfaceDark.withOpacity(0.8),
//             ProfessionalVODColors.primaryDark,
//           ],
//         ),
//       ),
//       child: Stack(
//         children: [
//           // Background Image with Fade Animation
//           if (movieDetails.isActive)
//             FadeTransition(
//               opacity: _backgroundFadeAnimation,
//               child: Container(
//                 width: double.infinity,
//                 height: double.infinity,
//                 child: displayImage(
//                   movieDetails.banner ?? localImage,
//                   width: screenwdt,
//                   height: screenhgt,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),

//           // Gradient Overlay
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Colors.transparent,
//                   Colors.black.withOpacity(0.3),
//                   Colors.black.withOpacity(0.7),
//                   Colors.black.withOpacity(0.9),
//                 ],
//               ),
//             ),
//           ),

//           // Content with Slide Animation
//           SlideTransition(
//             position: _contentSlideAnimation,
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.03),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   SizedBox(height: screenhgt * 0.05),

//                   // Enhanced Title Section
//                   Container(
//                     padding: EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           headingColor.withOpacity(0.1),
//                           Colors.transparent,
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: headingColor.withOpacity(0.3),
//                         width: 1,
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         ShaderMask(
//                           shaderCallback: (bounds) => LinearGradient(
//                             colors: [
//                               headingColor,
//                               headingColor.withOpacity(0.8),
//                             ],
//                           ).createShader(bounds),
//                           child: Text(
//                             movieDetails.name,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: Headingtextsz * 1.5,
//                               fontWeight: FontWeight.w800,
//                               letterSpacing: 1.0,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         Container(
//                           padding:
//                               EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 headingColor.withOpacity(0.3),
//                                 headingColor.withOpacity(0.1),
//                               ],
//                             ),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             movieDetails.genres,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               letterSpacing: 0.5,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   Spacer(),

//                   // Status Info
//                   if (!movieDetails.isActive)
//                     Container(
//                       padding: EdgeInsets.all(15),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             ProfessionalVODColors.accentRed.withOpacity(0.8),
//                             ProfessionalVODColors.accentRed.withOpacity(0.6),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(15),
//                         border: Border.all(
//                           color: ProfessionalVODColors.accentRed,
//                           width: 1,
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.block_rounded,
//                             color: Colors.white,
//                             size: 20,
//                           ),
//                           SizedBox(width: 10),
//                           Text(
//                             'Content Not Available (Status: ${movieDetails.status})',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                   // Play Button Section
//                   Expanded(
//                     child: Center(
//                       child: Container(
//                         width: screenwdt * 0.2,
//                         child: ProfessionalContentCard(
//                           contentItem: NewsItemModel(
//                             id: widget.id.toString(),
//                             name: movieDetails.name,
//                             poster: movieDetails.poster ?? '',
//                             banner: movieDetails.banner ?? '',
//                             description: '',
//                             category: '',
//                             index: '',
//                             url: '',
//                             videoId: '',
//                             streamType: '',
//                             type: '',
//                             genres: movieDetails.genres,
//                             status: '',
//                             image: '',
//                             unUpdatedUrl: '',
//                           ),
//                           focusNode: firstItemFocusNode,
//                           onTap: () => movieDetails.isActive
//                               ? _playVideo(movieDetails)
//                               : _showInactiveContentMessage(),
//                           hasMovieUrl: true,
//                           index: 0,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   bool isYoutubeUrl(String? url) {
//     if (url == null || url.isEmpty) {
//       return false;
//     }

//     url = url.toLowerCase().trim();

//     bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url);
//     if (isYoutubeId) {
//       return true;
//     }

//     bool isYoutubeUrl = url.contains('youtube.com') ||
//         url.contains('youtu.be') ||
//         url.contains('youtube.com/shorts/');
//     if (isYoutubeUrl) {
//       return true;
//     }

//     return false;
//   }

//   void _showInactiveContentMessage() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.block_rounded, color: Colors.white),
//             SizedBox(width: 10),
//             Text('This content is currently not available'),
//           ],
//         ),
//         backgroundColor: ProfessionalVODColors.accentRed,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }

//   Future<void> _playVideo(MovieDetailsApi movieDetails) async {

//     if (_isVideoPlaying) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _isVideoPlaying = true;
//     });


//     try {
//       Map<String, dynamic> playLinkData = await fetchMoviePlayLink(widget.id);
//       String originalUrl = playLinkData['source_url'] ?? '';

//       String updatedUrl = playLinkData['source_url'] ?? '';

//       if (originalUrl.isEmpty) {
//         throw Exception('Original URL is empty');
//       }


//       if (isYoutubeUrl(updatedUrl)) {
//         updatedUrl = await _socketService.getUpdatedUrl(updatedUrl);
//       }

//       if (updatedUrl.isEmpty) {
//         throw Exception('Updated URL is empty');
//       }

//       bool isValidUrl = Uri.tryParse(updatedUrl) != null;

//       if (updatedUrl.startsWith('http://') ||
//           updatedUrl.startsWith('https://')) {
//       } else {
//       }


//       if (!mounted) {
//         return;
//       }


//       bool liveStatus = false;

//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) {
//             return VideoScreen(
//               videoUrl: updatedUrl,
//               videoId: widget.id,
//               channelList: widget.channelList,
//               videoType: '',
//               bannerImageUrl: widget.banner,
//               startAtPosition: Duration.zero,
//               isLive: false,
//               isVOD: true,
//               isBannerSlider: false,
//               source: widget.source,
//               isSearch: false,
//               unUpdatedUrl: originalUrl,
//               name: widget.name,
//               seasonId: null,
//               isLastPlayedStored: false,
//               liveStatus: liveStatus,
//             );
//           },
//         ),
//       );

//       setState(() {
//         _isLoading = false;
//         _isReturningFromVideo = true;
//       });

//       setState(() {
//         _isReturningFromVideo = false;
//       });
//     } catch (e, stackTrace) {

//       _handleVideoError(context);
//       AuthErrorHandler.handleAuthError(context, e);
//     } finally {
//       setState(() {
//         _isLoading = false;
//         _isVideoPlaying = false;
//       });
//     }
//   }

//   void _handleVideoError(BuildContext context) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.error_outline, color: Colors.white),
//             SizedBox(width: 10),
//             Text('Something Went Wrong', style: TextStyle(fontSize: 16)),
//           ],
//         ),
//         backgroundColor: ProfessionalVODColors.accentRed,
//         duration: Duration(seconds: 3),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }
// }

// // ================================
// // 9. USAGE INSTRUCTIONS
// // ================================

// /*
// 🎯 COMPLETE IMPLEMENTATION GUIDE:

// 1. ✅ REPLACE SubVod Widget:
//    - Copy the new SubVod class
//    - Professional header with animations
//    - Enhanced network cards with shimmer effects

// 2. ✅ REPLACE VOD Widget:
//    - Copy the new VOD class  
//    - Grid layout with professional styling
//    - Animated loading and error states

// 3. ✅ REPLACE ContentScreen Widget:
//    - Copy the new ContentScreen class
//    - Professional content grid
//    - Enhanced video loading overlay
//    - Movie/Content source indicators

// 4. ✅ REPLACE DetailsPage Widget:
//    - Copy the new DetailsPage class
//    - Professional movie details UI
//    - Enhanced background animations
//    - Better error handling

// 5. ✅ ADD Professional Colors & Animations:
//    - Copy ProfessionalVODColors class
//    - Copy VODAnimationTiming class

// 🎨 KEY FEATURES ADDED:

// ✅ Professional color scheme matching WebSeries
// ✅ Smooth animations (700ms duration)
// ✅ Enhanced shadows and glow effects  
// ✅ Professional loading indicators
// ✅ Shimmer effects on focus
// ✅ Enhanced headers with stats
// ✅ Better error handling
// ✅ Improved focus management
// ✅ Source indicators (M for Movie, C for Content)
// ✅ Blue/Purple gradient theme for VOD

// 📱 RESULT:
// Your SubVod, VOD, ContentScreen, and DetailsPage will now have:
// - Same professional design as WebSeries
// - Consistent animations and effects
// - Enhanced user experience
// - Better visual feedback
// - Modern UI elements

// 🚀 All features from WebSeries are now available for VOD pages:
// - Same animation timing (700ms)
// - Same scale effects (1.04x-1.05x)
// - Same shadow patterns
// - Same shimmer effects
// - Same professional loading
// - Same focus management
// - Enhanced content browsing experience

// Copy all the code parts and replace your existing widgets!
// */