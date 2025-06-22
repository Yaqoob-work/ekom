// import 'dart:async';
// import 'dart:convert';
// import 'dart:math' as math;
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:mobi_tv_entertainment/widgets/utils/color_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../video_widget/socket_service.dart';
// import '../sub_vod_screen/sub_vod.dart';
// import 'focussable_manage_movies_widget.dart';

// // Enhanced Network Helper
// class NetworkHelper {
//   static final http.Client _client = http.Client();
//   static const int _maxConcurrentRequests = 3;
//   static int _activeRequests = 0;
//   static DateTime? _lastRequestTime;
//   static const Duration _requestCooldown = Duration(milliseconds: 500);

//   static Future<http.Response> getWithRetry(
//     String url, {
//     Map<String, String>? headers,
//     int timeout = 10,
//     int retries = 2,
//   }) async {
//     // Rate limiting
//     final now = DateTime.now();
//     if (_lastRequestTime != null &&
//         now.difference(_lastRequestTime!) < _requestCooldown) {
//       await Future.delayed(_requestCooldown);
//     }
//     _lastRequestTime = now;

//     // Limit concurrent requests
//     while (_activeRequests >= _maxConcurrentRequests) {
//       await Future.delayed(Duration(milliseconds: 100));
//     }

//     _activeRequests++;
//     try {
//       for (int i = 0; i < retries; i++) {
//         try {
//           final response = await _client
//               .get(
//                 Uri.parse(url),
//                 headers: headers,
//               )
//               .timeout(Duration(seconds: timeout));

//           if (response.statusCode == 200) {
//             return response;
//           }
//         } catch (e) {
//           if (i == retries - 1) rethrow;
//           await Future.delayed(Duration(seconds: 1 * (i + 1)));
//         }
//       }
//       throw Exception('Failed after $retries attempts');
//     } finally {
//       _activeRequests--;
//     }
//   }

//   static void dispose() {
//     _client.close();
//   }
// }

// // Enhanced Cache Manager
// class CacheManager {
//   static const String moviesKey = 'movies_list';
//   static const String lastUpdateKey = 'movies_last_update';
//   static const int maxCacheAgeHours = 6;

//   static Future<void> saveMovies(List<dynamic> movies) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(moviesKey, json.encode(movies));
//       await prefs.setInt(lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
//     } catch (e) {
//     }
//   }

//   static Future<List<dynamic>?> getCachedMovies() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cachedData = prefs.getString(moviesKey);
//       if (cachedData != null && !await isCacheExpired()) {
//         return json.decode(cachedData);
//       }
//     } catch (e) {
//     }
//     return null;
//   }

//   static Future<bool> isCacheExpired() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final lastUpdate = prefs.getInt(lastUpdateKey);
//       if (lastUpdate == null) return true;

//       final now = DateTime.now().millisecondsSinceEpoch;
//       final maxAge = maxCacheAgeHours * 60 * 60 * 1000;

//       return (now - lastUpdate) > maxAge;
//     } catch (e) {
//       return true;
//     }
//   }
// }

// // YouTube URL checker
// // bool isYoutubeUrl(String? url) {
// //   if (url == null || url.isEmpty) return false;

// //   url = url.toLowerCase().trim();
// //   bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url);
// //   if (isYoutubeId) return true;

// //   return url.contains('youtube.com') ||
// //       url.contains('youtu.be') ||
// //       url.contains('youtube.com/shorts/');
// // }

// // Enhanced YouTube URL checker with better debugging
// bool isYoutubeUrl(String? url) {
//   if (url == null || url.isEmpty) {
//     return false;
//   }

//   url = url.toLowerCase().trim();

//   // Check for YouTube ID pattern (11 characters)
//   bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url);
//   if (isYoutubeId) {
//     return true;
//   }

//   // Check for various YouTube URL patterns
//   bool isYouTubeUrl = url.contains('youtube.com') ||
//       url.contains('youtu.be') ||
//       url.contains('youtube.com/shorts/') ||
//       url.contains('www.youtube.com') ||
//       url.contains('m.youtube.com');

//   return isYouTubeUrl;
// }

// class Movies extends StatefulWidget {
//   final Function(bool)? onFocusChange;
//   final FocusNode focusNode;

//   const Movies({Key? key, this.onFocusChange, required this.focusNode})
//       : super(key: key);

//   @override
//   _MoviesState createState() => _MoviesState();
// }

// class _MoviesState extends State<Movies> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   // Core data
//   List<dynamic> moviesList = [];
//   bool _isLoading = true;
//   String _errorMessage = '';
//   bool _isNavigating = false;

//   // Services and controllers
//   final PaletteColorService _paletteColorService = PaletteColorService();
//   final ScrollController _scrollController = ScrollController();
//   late SocketService _socketService;

//   // Focus management
//   Map<String, FocusNode> movieFocusNodes = {};
//   FocusNode? _viewAllFocusNode;
//   Color _viewAllColor = Colors.grey;

//   // Performance optimizations
//   Timer? _timer;
//   Timer? _backgroundFetchTimer;
//   DateTime? _lastFetchTime;
//   static const Duration _fetchCooldown = Duration(minutes: 3);

//   // Memory management
//   static const int _maxCacheSize = 30;
//   Map<String, Widget> _imageCache = {};
//   Map<String, Uint8List?> _decodedImages = {};

//   @override
//   void initState() {
//     super.initState();

//     // ✅ Socket service को properly initialize करें
//     _socketService = SocketService();
//     _socketService.initSocket(); // यह line add करें

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         Provider.of<FocusProvider>(context, listen: false)
//             .setMoviesScrollController(_scrollController);
//       }
//     });

//     _initializeViewAllFocusNode();
//     _loadCachedDataAndFetchMovies();

//     // Setup periodic background refresh
//     _backgroundFetchTimer = Timer.periodic(
//         Duration(minutes: 10), (_) => _fetchMoviesInBackground());
//   }

//   // @override
//   // void initState() {
//   //   super.initState();

//   //   _socketService = SocketService();

//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     if (mounted) {
//   //       Provider.of<FocusProvider>(context, listen: false)
//   //           .setMoviesScrollController(_scrollController);
//   //     }
//   //   });

//   //   _initializeViewAllFocusNode();
//   //   _loadCachedDataAndFetchMovies();

//   //   // Setup periodic background refresh
//   //   _backgroundFetchTimer = Timer.periodic(
//   //       Duration(minutes: 10), (_) => _fetchMoviesInBackground());
//   // }

//   // Movie data logging के लिए helper function
//   void debugMovieData(Map<String, dynamic> movie) {
//   }

//   void _initializeViewAllFocusNode() {
//     _viewAllFocusNode = FocusNode()
//       ..addListener(() {
//         if (mounted && _viewAllFocusNode!.hasFocus) {
//           setState(() {
//             _viewAllColor =
//                 Colors.primaries[Random().nextInt(Colors.primaries.length)];
//           });
//         }
//       });
//   }

//   // Enhanced sorting with null safety
//   void _sortMoviesData(List<dynamic> data) {
//     if (data.isEmpty) return;

//     try {
//       data.sort((a, b) {
//         final aIndex = a['index'];
//         final bIndex = b['index'];

//         if (aIndex == null && bIndex == null) return 0;
//         if (aIndex == null) return 1;
//         if (bIndex == null) return -1;

//         int aVal = 0;
//         int bVal = 0;

//         if (aIndex is num) {
//           aVal = aIndex.toInt();
//         } else if (aIndex is String) {
//           aVal = int.tryParse(aIndex) ?? 0;
//         }

//         if (bIndex is num) {
//           bVal = bIndex.toInt();
//         } else if (bIndex is String) {
//           bVal = int.tryParse(bIndex) ?? 0;
//         }

//         return aVal.compareTo(bVal);
//       });
//     } catch (e) {
//     }
//   }

//   // Optimized background fetch with cooldown
//   Future<void> _fetchMoviesInBackground() async {
//     if (!mounted) return;

//     final now = DateTime.now();
//     if (_lastFetchTime != null &&
//         now.difference(_lastFetchTime!) < _fetchCooldown) {
//       return;
//     }
//     _lastFetchTime = now;

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String authKey = AuthManager.authKey;
//       if (authKey.isEmpty) {
//         authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
//       }

//       final response = await NetworkHelper.getWithRetry(
//         'https://acomtv.coretechinfo.com/public/api/getAllMovies',
//         headers: {'auth-key': authKey},
//         // timeout: 8,
//       );

//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);
//         _sortMoviesData(data);

//         final cachedMovies = prefs.getString('movies_list');
//         final String newMoviesJson = json.encode(data);

//         if (cachedMovies != newMoviesJson) {
//           await CacheManager.saveMovies(data);

//           if (mounted) {
//             setState(() {
//               moviesList = data;
//               _initializeMovieFocusNodes();
//             });
//           }
//         }
//       }
//     } catch (e) {
//     }
//   }

//   // Main fetch with improved error handling
//   Future<void> _fetchMovies() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String authKey = AuthManager.authKey;
//       if (authKey.isEmpty) {
//         authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
//       }

//       final response = await NetworkHelper.getWithRetry(
//         'https://acomtv.coretechinfo.com/public/api/getAllMovies',
//         headers: {'auth-key': authKey},
//         // timeout: 10,
//       );

//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);
//         _sortMoviesData(data);

//         await CacheManager.saveMovies(data);

//         if (mounted) {
//           setState(() {
//             moviesList = data;
//             _initializeMovieFocusNodes();
//             _isLoading = false;
//           });
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             _errorMessage = 'Failed to load movies (${response.statusCode})';
//             _isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = 'Network error: Please check connection';
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   // Safe NewsItemModel conversion
//   List<NewsItemModel> _convertToNewsItemModels(List<dynamic> movies) {
//     return movies.map((m) {
//       try {
//         Map<String, dynamic> movie = m as Map<String, dynamic>;
//         return NewsItemModel(
//           id: movie.safeString('id'),
//           name: movie.safeString('name'),
//           banner: movie.safeString('banner'),
//           poster: movie.safeString('poster'),
//           description: movie.safeString('description'),
//           url: movie.safeString('url'),
//           streamType: movie.safeString('streamType'),
//           type: movie.safeString('type'),
//           genres: movie.safeString('genres'),
//           status: movie.safeString('status'),
//           videoId: movie.safeString('videoId'),
//           index: movie.safeString('index'),
//           image: '',
//           unUpdatedUrl: '',
//         );
//       } catch (e) {
//         return NewsItemModel(
//           id: '',
//           name: 'Unknown',
//           banner: '',
//           poster: '',
//           description: '',
//           url: '',
//           streamType: '',
//           type: '',
//           genres: '',
//           status: '',
//           videoId: '',
//           index: '',
//           image: '',
//           unUpdatedUrl: '',
//         );
//       }
//     }).toList();
//   }

// // ✅ FIXED: Updated _handleMovieTap method for Movies class (_MoviesState)

// Future<void> _handleMovieTap(dynamic movie) async {
//   if (_isNavigating || !mounted) return;

//   _isNavigating = true;
//   bool dialogShown = false;
//   Timer? timeoutTimer;

//   try {
//     // Add movie data debugging
//     debugMovieData(movie);

//     if (mounted) {
//       dialogShown = true;
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return WillPopScope(
//             onWillPop: () async {
//               _isNavigating = false;
//               return true;
//             },
//             child: Center(
//               child: Container(
//                 padding: EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.black54,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     CircularProgressIndicator(color: Colors.white),
//                     SizedBox(height: 10),
//                     Text(
//                       'Preparing video...',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     }

//     timeoutTimer = Timer(Duration(seconds: 20), () {
//       if (mounted && _isNavigating) {
//         _isNavigating = false;
//         if (dialogShown) {
//           Navigator.of(context, rootNavigator: true).pop();
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Request timeout. Please check your connection.'),
//             backgroundColor: Colors.orange,
//           ),
//         );
//       }
//     });

//     // Get movie URL from current movie object
//     Map<String, dynamic> movieMap = movie as Map<String, dynamic>;
//     String movieId = movieMap.safeString('id');
//     String originalUrl = movieMap.safeString('movie_url');
//     String updatedUrl = movieMap.safeString('movie_url');


//     // Validate original URL
//     if (originalUrl.isEmpty) {
//       throw Exception('Video URL is not available');
//     }

//     // YouTube URL processing
//     if (isYoutubeUrl(updatedUrl)) {
//       try {
//         for (int attempt = 1; attempt <= 3; attempt++) {
//           try {
//           final  PlayUrl = await _socketService.getUpdatedUrl(updatedUrl);

//             if (PlayUrl != null && PlayUrl.isNotEmpty) {
//               updatedUrl = PlayUrl;
//               print('🔗 Updated URL: $updatedUrl');
//               break;
//             }
//           } catch (e) {
//             print('❌ YouTube URL update attempt $attempt failed: $e');
//             if (attempt == 3) {
//               print('⚠️ Using original URL as fallback');
//               // updatedUrl = originalUrl;
//             } else {
//               await Future.delayed(Duration(seconds: 1));
//             }
//           }
//         }
//       } catch (e) {
//         print('❌ YouTube URL processing failed: $e');
//         // updatedUrl = originalUrl;
//       }
//     }

//     // Fetch fresh movies data
//     List<NewsItemModel> freshMovies = await Future.any([
//       _fetchFreshMoviesData(),
//       Future.delayed(Duration(seconds: 12), () => <NewsItemModel>[]),
//     ]);

//     if (freshMovies.isEmpty) {
//       freshMovies = _convertToNewsItemModels(moviesList);
//     }

//     timeoutTimer.cancel();

//     if (mounted && _isNavigating) {
//       if (dialogShown) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }

//       // Final validation
//       if (updatedUrl.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Video URL is not available'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       print('🔗 Final video URL: $updatedUrl');

//       // Navigate to VideoScreen
//       try {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => VideoScreen(
//               channelList: freshMovies,
//               source: 'isMovieScreen',
//               name: movieMap.safeString('name'),
//               videoUrl: updatedUrl,
//               unUpdatedUrl: originalUrl,
//               bannerImageUrl: movieMap.safeString('banner'),
//               startAtPosition: Duration.zero,
//               videoType: '',
//               isLive: false,
//               isVOD: true,
//               isLastPlayedStored: false,
//               isSearch: false,
//               isBannerSlider: false,
//               videoId: int.tryParse(movieId),
//               seasonId: 0,
//               liveStatus: false,
//             ),
//           ),
//         );
//         print('📱 Returned from VideoScreen');
//       } catch (e) {
//         print('❌ Navigation error: $e');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Failed to open video player'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   } catch (e) {
//     timeoutTimer?.cancel();
//     print('❌ Movie tap error: $e');
//     if (mounted) {
//       if (dialogShown) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   } finally {
//     _isNavigating = false;
//     timeoutTimer?.cancel();
//     print('🏁 Movie tap completed\n');
//   }
// }

// // ✅ YouTube URL checker method - ADD THIS TO BOTH CLASSES

// // For Movies class (_MoviesState) - Add this method:
// bool _isYoutubeUrl(String? url) {
//   if (url == null || url.isEmpty) {
//     return false;
//   }

//   url = url.toLowerCase().trim();

//   // First check if it's a YouTube ID (exactly 11 characters)
//   bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url);
//   if (isYoutubeId) {
//     return true;
//   }

//   // Then check for regular YouTube URLs
//   bool isYoutubeUrl = url.contains('youtube.com') ||
//       url.contains('youtu.be') ||
//       url.contains('youtube.com/shorts/');
//   if (isYoutubeUrl) {
//     return true;
//   }

//   return false;
// }

// // ✅ IMPLEMENTATION INSTRUCTIONS:

// /*
// FOR MOVIES CLASS (_MoviesState):
// 1. Replace existing _handleMovieTap method
// 2. Add _isYoutubeUrl method inside _MoviesState class
// 3. Make sure these methods exist (should already be there):
//    - _fetchFreshMoviesData()
//    - _convertToNewsItemModels()
//    - debugMovieData()
//    - moviesList variable

// FOR MOVIESGRIDVIEW CLASS (_MoviesGridViewState):
// 1. Replace existing _handleGridMovieTap method
// 2. Add _isYoutubeUrl method inside _MoviesGridViewState class
// 3. Make sure these methods exist (should already be there):
//    - _fetchFreshMoviesForGrid()
//    - widget.moviesList access

// BOTH CLASSES NEED:
// - _socketService properly initialized
// - SafeTypeConversion extension
// - Required imports
// */

//   // Optimized fresh data fetch
//   Future<List<NewsItemModel>> _fetchFreshMoviesData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String authKey = AuthManager.authKey;
//       if (authKey.isEmpty) {
//         authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
//       }

//       final response = await NetworkHelper.getWithRetry(
//         'https://acomtv.coretechinfo.com/public/api/getAllMovies',
//         headers: {'auth-key': authKey},
//       );

//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);
//         _sortMoviesData(data);
//         return _convertToNewsItemModels(data);
//       }
//     } catch (e) {
//       print('Fresh data fetch error: $e');
//     }
//     return [];
//   }

//   // Enhanced image building with memory management
//   Widget _buildOptimizedImage(String imageUrl, String movieId,
//       {required double width, required double height}) {
//     if (_imageCache.containsKey(movieId)) {
//       return _imageCache[movieId]!;
//     }

//     Widget imageWidget;
//     final maxWidth = math.min(width * 2, 600).toInt();
//     final maxHeight = math.min(height * 2, 400).toInt();

//     if (imageUrl.isEmpty) {
//       imageWidget = _buildErrorWidget(width, height, 'No Image');
//     } else if (imageUrl.startsWith('data:image/')) {
//       imageWidget = _buildBase64Image(imageUrl, movieId, maxWidth, maxHeight);
//     } else if (imageUrl.startsWith('http://') ||
//         imageUrl.startsWith('https://')) {
//       imageWidget = _buildNetworkImage(imageUrl, maxWidth, maxHeight);
//     } else {
//       imageWidget = _buildErrorWidget(width, height, 'Invalid URL');
//     }

//     _addToImageCache(movieId, imageWidget);
//     return imageWidget;
//   }

//   Widget _buildBase64Image(
//       String imageUrl, String movieId, int maxWidth, int maxHeight) {
//     if (_decodedImages.containsKey(movieId)) {
//       final bytes = _decodedImages[movieId];
//       if (bytes != null) {
//         return Image.memory(
//           bytes,
//           width: maxWidth.toDouble(),
//           height: maxHeight.toDouble(),
//           fit: BoxFit.cover,
//           cacheWidth: maxWidth,
//           cacheHeight: maxHeight,
//           gaplessPlayback: true,
//           errorBuilder: (context, error, stackTrace) {
//             return _buildErrorWidget(
//                 maxWidth.toDouble(), maxHeight.toDouble(), 'Display Error');
//           },
//         );
//       } else {
//         return _buildErrorWidget(
//             maxWidth.toDouble(), maxHeight.toDouble(), 'Decode Failed');
//       }
//     }

//     try {
//       if (!imageUrl.contains(',')) {
//         _decodedImages[movieId] = null;
//         return _buildErrorWidget(
//             maxWidth.toDouble(), maxHeight.toDouble(), 'Invalid Format');
//       }

//       final String base64String = imageUrl.split(',')[1];
//       if (base64String.isEmpty) {
//         _decodedImages[movieId] = null;
//         return _buildErrorWidget(
//             maxWidth.toDouble(), maxHeight.toDouble(), 'Empty Data');
//       }

//       final Uint8List bytes = base64Decode(base64String);

//       if (bytes.length > 2 * 1024 * 1024) {
//         _decodedImages[movieId] = null;
//         return _buildErrorWidget(
//             maxWidth.toDouble(), maxHeight.toDouble(), 'Image Too Large');
//       }

//       _decodedImages[movieId] = bytes;

//       return Image.memory(
//         bytes,
//         width: maxWidth.toDouble(),
//         height: maxHeight.toDouble(),
//         fit: BoxFit.cover,
//         cacheWidth: maxWidth,
//         cacheHeight: maxHeight,
//         gaplessPlayback: true,
//         errorBuilder: (context, error, stackTrace) {
//           _decodedImages[movieId] = null;
//           return _buildErrorWidget(
//               maxWidth.toDouble(), maxHeight.toDouble(), 'Display Error');
//         },
//       );
//     } catch (e) {
//       _decodedImages[movieId] = null;
//       return _buildErrorWidget(
//           maxWidth.toDouble(), maxHeight.toDouble(), 'Decode Error');
//     }
//   }

//   Widget _buildNetworkImage(String imageUrl, int maxWidth, int maxHeight) {
//     return CachedNetworkImage(
//       imageUrl: imageUrl,
//       width: maxWidth.toDouble(),
//       height: maxHeight.toDouble(),
//       fit: BoxFit.cover,
//       memCacheWidth: maxWidth,
//       memCacheHeight: maxHeight,
//       maxWidthDiskCache: maxWidth,
//       maxHeightDiskCache: maxHeight,
//       placeholder: (context, url) => Container(
//         width: maxWidth.toDouble(),
//         height: maxHeight.toDouble(),
//         color: Colors.grey[800],
//         child: Center(
//           child: SizedBox(
//             width: 20,
//             height: 20,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
//             ),
//           ),
//         ),
//       ),
//       errorWidget: (context, url, error) => _buildErrorWidget(
//           maxWidth.toDouble(), maxHeight.toDouble(), 'Network Error'),
//     );
//   }

//   Widget _buildErrorWidget(double width, double height, String errorType) {
//     return Container(
//       width: width,
//       height: height,
//       color: Colors.grey[800],
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.broken_image,
//             color: Colors.white54,
//             size: math.min(width, height) * 0.3,
//           ),
//           if (errorType.isNotEmpty) ...[
//             SizedBox(height: 4),
//             Text(
//               errorType,
//               style: TextStyle(
//                 color: Colors.white54,
//                 fontSize: 8,
//               ),
//               textAlign: TextAlign.center,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   void _addToImageCache(String key, Widget widget) {
//     if (_imageCache.length >= _maxCacheSize) {
//       final keysToRemove = _imageCache.keys.take(_maxCacheSize ~/ 2).toList();
//       for (final keyToRemove in keysToRemove) {
//         _imageCache.remove(keyToRemove);
//         _decodedImages.remove(keyToRemove);
//       }
//     }
//     _imageCache[key] = widget;
//   }

//   void _clearImageCache() {
//     _imageCache.clear();
//     _decodedImages.clear();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _backgroundFetchTimer?.cancel();

//     _clearImageCache();

//     for (var entry in movieFocusNodes.entries) {
//       try {
//         entry.value.removeListener(() {});
//         entry.value.dispose();
//       } catch (e) {
//         print('Focus node dispose error: $e');
//       }
//     }
//     movieFocusNodes.clear();

//     try {
//       _viewAllFocusNode?.removeListener(() {});
//       _viewAllFocusNode?.dispose();
//     } catch (e) {
//       print('ViewAll focus node dispose error: $e');
//     }

//     try {
//       _scrollController.dispose();
//     } catch (e) {
//       print('ScrollController dispose error: $e');
//     }

//     _isNavigating = false;

//     super.dispose();
//   }

//   void _initializeMovieFocusNodes() {
//     _clearImageCache();

//     for (var node in movieFocusNodes.values) {
//       try {
//         node.removeListener(() {});
//         node.dispose();
//       } catch (e) {
//         print('Focus node cleanup error: $e');
//       }
//     }
//     movieFocusNodes.clear();

//     for (var movie in moviesList) {
//       try {
//         String movieId = movie['id'].toString();
//         movieFocusNodes[movieId] = FocusNode()
//           ..addListener(() {
//             if (mounted && movieFocusNodes[movieId]!.hasFocus) {
//               _scrollToFocusedItem(movieId);
//             }
//           });
//       } catch (e) {
//         // print('Focus node creation error: $e');
//       }
//     }
//     _registerMoviesFocus();
//   }

//   void _registerMoviesFocus() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && moviesList.isNotEmpty) {
//         try {
//           final focusProvider = context.read<FocusProvider>();
//           final firstMovieId = moviesList[0]['id'].toString();

//           if (movieFocusNodes.containsKey(firstMovieId)) {
//             focusProvider
//                 .setFirstManageMoviesFocusNode(movieFocusNodes[firstMovieId]!);
//           }
//         } catch (e) {
//           print('Focus registration error: $e');
//         }
//       }
//     });
//   }

//   Future<void> _loadCachedDataAndFetchMovies() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       final cachedMovies = await CacheManager.getCachedMovies();

//       if (cachedMovies != null && mounted) {
//         setState(() {
//           moviesList = cachedMovies;
//           _initializeMovieFocusNodes();
//           _isLoading = false;
//         });

//         _fetchMoviesInBackground();
//       } else {
//         await _fetchMovies();
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = 'Failed to load movies';
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _scrollToFocusedItem(String itemId) {
//     if (!mounted) return;

//     try {
//       final focusNode = movieFocusNodes[itemId];
//       if (focusNode != null &&
//           focusNode.hasFocus &&
//           focusNode.context != null) {
//         Scrollable.ensureVisible(
//           focusNode.context!,
//           alignment: 0.02,
//           duration: Duration(milliseconds: 800),
//           curve: Curves.linear,
//         );
//       }
//     } catch (e) {
//       print('Scroll error: $e');
//     }
//   }

//   Widget _buildMoviePoster(dynamic movie) {
//     String movieId = movie['id'].toString();
//     bool isFocused = movieFocusNodes[movieId]?.hasFocus ?? false;
//     Color dominantColor = context.watch<ColorProvider>().dominantColor;

//     final String imageUrl =
//         movie['banner']?.toString() ?? movie['poster']?.toString() ?? '';

//     return AnimatedContainer(
//       padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.002),
//       curve: Curves.easeInOut,
//       width: MediaQuery.of(context).size.width * 0.19,
//       height: isFocused
//           ? MediaQuery.of(context).size.height * 0.26
//           : MediaQuery.of(context).size.height * 0.20,
//       duration: const Duration(milliseconds: 800),
//       decoration: BoxDecoration(
//         border: Border.all(
//           color: isFocused ? dominantColor : Colors.transparent,
//           width: 5.0,
//         ),
//         boxShadow: isFocused
//             ? [
//                 BoxShadow(
//                   color: dominantColor.withOpacity(0.6),
//                   blurRadius: 20.0,
//                   spreadRadius: 4.0,
//                   offset: Offset(0, 3),
//                 ),

//               ]
//             : [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 6.0,
//                   spreadRadius: 1.0,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(4),
//         child: _buildOptimizedImage(
//           imageUrl,
//           movieId,
//           width: MediaQuery.of(context).size.width * 0.19,
//           height: isFocused
//               ? MediaQuery.of(context).size.height * 0.26
//               : MediaQuery.of(context).size.height * 0.20,
//         ),
//       ),
//     );
//   }

//   Widget _buildMovieTitle(dynamic movie) {
//     String movieId = movie['id'].toString();
//     bool isFocused = movieFocusNodes[movieId]?.hasFocus ?? false;
//     Color dominantColor = context.watch<ColorProvider>().dominantColor;

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 0),
//       curve: Curves.easeInOut,
//       width: MediaQuery.of(context).size.width * 0.15,
//       child: AnimatedDefaultTextStyle(
//         duration: const Duration(milliseconds: 0),
//         curve: Curves.easeInOut,
//         style: TextStyle(
//           fontSize: isFocused ? nametextsz * 1.0 : nametextsz,
//           fontWeight: FontWeight.bold,
//           color: isFocused ? dominantColor : Colors.white,
//           shadows: isFocused
//               ? [
//                   Shadow(
//                     color: dominantColor.withOpacity(0.4),
//                     blurRadius: 6.0,
//                     offset: Offset(0, 1),
//                   ),
//                 ]
//               : [],
//         ),
//         child: Text(
//           movie['name']?.toString()?.toUpperCase() ?? 'UNKNOWN',
//           textAlign: TextAlign.center,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }

//   Widget _buildViewAllItem() {
//     bool isFocused = _viewAllFocusNode?.hasFocus ?? false;

//     return Focus(
//       focusNode: _viewAllFocusNode,
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//             if (moviesList.isNotEmpty && moviesList.length > 6) {
//               String movieId = moviesList[6]['id'].toString();
//               FocusScope.of(context).requestFocus(movieFocusNodes[movieId]);
//               return KeyEventResult.handled;
//             }
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//             context.read<FocusProvider>().requestSubVodFocus();
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//             FocusScope.of(context).unfocus();
//             Future.delayed(const Duration(milliseconds: 50), () {
//               if (mounted) {
//                 context.read<FocusProvider>().requestFirstWebseriesFocus();
//               }
//             });
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.select) {
//             _navigateToMoviesGrid();
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: _navigateToMoviesGrid,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             AnimatedContainer(
//               duration: Duration(milliseconds: 500),
//               curve: Curves.easeInOut,
//               width: MediaQuery.of(context).size.width * 0.19,
//               height: isFocused
//                   ? MediaQuery.of(context).size.height * 0.26
//                   : MediaQuery.of(context).size.height * 0.20,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(6.0),
//                 color: Colors.grey[800],
//                 border: Border.all(
//                   color: isFocused ? _viewAllColor : Colors.transparent,
//                   width: isFocused ? 3.0 : 0.0,
//                 ),
//                 boxShadow: isFocused
//                     ? [
//                         BoxShadow(
//                           color: _viewAllColor.withOpacity(0.5),
//                           blurRadius: 20.0,
//                           spreadRadius: 4.0,
//                           offset: Offset(0, 3),
//                         ),
//                       ]
//                     : [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.3),
//                           blurRadius: 6.0,
//                           spreadRadius: 0.5,
//                           offset: Offset(0, 2),
//                         ),
//                       ],
//               ),
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     AnimatedDefaultTextStyle(
//                       duration: const Duration(milliseconds: 500),
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: isFocused ? 15 : 14,
//                         shadows: isFocused
//                             ? [
//                                 Shadow(
//                                   color: _viewAllColor.withOpacity(0.4),
//                                   blurRadius: 6.0,
//                                   offset: Offset(0, 1),
//                                 ),
//                               ]
//                             : [],
//                       ),
//                       child: Text('View All'),
//                     ),
//                     SizedBox(height: 4),
//                     AnimatedDefaultTextStyle(
//                       duration: const Duration(milliseconds: 500),
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: isFocused ? 16 : 15,
//                         shadows: isFocused
//                             ? [
//                                 Shadow(
//                                   color: _viewAllColor.withOpacity(0.4),
//                                   blurRadius: 6.0,
//                                   offset: Offset(0, 1),
//                                 ),
//                               ]
//                             : [],
//                       ),
//                       child: Text('MOVIES'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 8),
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 0),
//               curve: Curves.easeInOut,
//               width: MediaQuery.of(context).size.width * 0.15,
//               child: AnimatedDefaultTextStyle(
//                 duration: const Duration(milliseconds: 0),
//                 style: TextStyle(
//                   color: isFocused ? _viewAllColor : Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: isFocused ? nametextsz * 1.05 : nametextsz,
//                   shadows: isFocused
//                       ? [
//                           Shadow(
//                             color: _viewAllColor.withOpacity(0.4),
//                             blurRadius: 6.0,
//                             offset: Offset(0, 1),
//                           ),
//                         ]
//                       : [],
//                 ),
//                 child: Text(
//                   'MOVIES',
//                   textAlign: TextAlign.center,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Column(
//         children: [
//           SizedBox(height: screenhgt * 0.03),
//           _buildTitle(),
//           Expanded(child: _buildBody()),
//         ],
//       ),
//     );
//   }

//   Widget _buildTitle() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.02),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'MOVIES',
//             style: TextStyle(
//               fontSize: Headingtextsz,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(color: Colors.white),
//             SizedBox(height: 16),
//             Text(
//               'Loading Movies...',
//               style: TextStyle(color: Colors.white),
//             ),
//           ],
//         ),
//       );
//     } else if (_errorMessage.isNotEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, color: Colors.white, size: 48),
//             SizedBox(height: 16),
//             Text(
//               _errorMessage,
//               style: TextStyle(color: Colors.white),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _fetchMovies,
//               child: Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     } else if (moviesList.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.movie_outlined, color: Colors.white, size: 48),
//             SizedBox(height: 16),
//             Text(
//               'No movies found',
//               style: TextStyle(color: Colors.white),
//             ),
//           ],
//         ),
//       );
//     } else {
//       return _buildMoviesList();
//     }
//   }

//   Widget _buildMoviesList() {
//     bool showViewAll = moviesList.length > 7;

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.35,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         clipBehavior: Clip.none,
//         controller: _scrollController,
//         padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.02),
//         cacheExtent: 1000,
//         itemCount: showViewAll ? 8 : moviesList.length,
//         itemBuilder: (context, index) {
//           if (showViewAll && index == 7) {
//             return Padding(
//               padding: EdgeInsets.only(right: screenwdt * 0.02),
//               child: _buildViewAllItem(),
//             );
//           }

//           var movie = moviesList[index];
//           return Padding(
//             padding: EdgeInsets.only(right: screenwdt * 0.0),
//             child: _buildMovieItem(movie, index),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildMovieItem(dynamic movie, int index) {
//     String movieId = movie['id'].toString();

//     movieFocusNodes.putIfAbsent(
//       movieId,
//       () => FocusNode()
//         ..addListener(() {
//           if (mounted && movieFocusNodes[movieId]!.hasFocus) {
//             _scrollToFocusedItem(movieId);
//           }
//         }),
//     );

//     return Focus(
//       focusNode: movieFocusNodes[movieId],
//       onFocusChange: (hasFocus) async {
//         if (hasFocus && mounted) {
//           try {
//             Color dominantColor = await _paletteColorService.getSecondaryColor(
//               movie['poster']?.toString() ?? '',
//               fallbackColor: Colors.grey,
//             );
//             if (mounted) {
//               context.read<ColorProvider>().updateColor(dominantColor, true);
//             }
//           } catch (e) {
//             if (mounted) {
//               context.read<ColorProvider>().updateColor(Colors.grey, true);
//             }
//           }
//         } else if (mounted) {
//           context.read<ColorProvider>().resetColor();
//         }
//       },
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//             if (index < moviesList.length - 1 && index != 6) {
//               String nextMovieId = moviesList[index + 1]['id'].toString();
//               FocusScope.of(context).requestFocus(movieFocusNodes[nextMovieId]);
//               return KeyEventResult.handled;
//             } else if (index == 6 && moviesList.length > 7) {
//               FocusScope.of(context).requestFocus(_viewAllFocusNode);
//               return KeyEventResult.handled;
//             }
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//             if (index > 0) {
//               String prevMovieId = moviesList[index - 1]['id'].toString();
//               FocusScope.of(context).requestFocus(movieFocusNodes[prevMovieId]);
//               return KeyEventResult.handled;
//             }
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//             context.read<FocusProvider>().requestSubVodFocus();
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//             FocusScope.of(context).unfocus();
//             Future.delayed(const Duration(milliseconds: 50), () {
//               if (mounted) {
//                 Provider.of<FocusProvider>(context, listen: false)
//                     .requestFirstWebseriesFocus();
//               }
//             });
//             return KeyEventResult.ignored;
//           } else if (event.logicalKey == LogicalKeyboardKey.select) {
//             _handleMovieTap(movie);
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: () => _handleMovieTap(movie),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _buildMoviePoster(movie),
//             SizedBox(height: 8),
//             _buildMovieTitle(movie),
//           ],
//         ),
//       ),
//     );
//   }

//   void _navigateToMoviesGrid() {
//     if (!_isNavigating && mounted) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => MoviesGridView(moviesList: moviesList),
//         ),
//       );
//     }
//   }
// }

// // Enhanced Grid View Class
// class MoviesGridView extends StatefulWidget {
//   final List<dynamic> moviesList;

//   const MoviesGridView({Key? key, required this.moviesList}) : super(key: key);

//   @override
//   _MoviesGridViewState createState() => _MoviesGridViewState();
// }

// class _MoviesGridViewState extends State<MoviesGridView> {
//   late Map<String, FocusNode> _movieFocusNodes;
//   bool _isLoading = false;
//   late SocketService _socketService;

//   @override
//   void initState() {
//     super.initState();

//     // ✅ Socket service initialize करें
//     _socketService = SocketService();
//     _socketService.initSocket(); // यह line add करें

//     _movieFocusNodes = {
//       for (var movie in widget.moviesList) movie['id'].toString(): FocusNode()
//     };
//   }

// // ✅ _MoviesGridViewState class में Line 747 को replace करें:

// // Replace the _handleGridMovieTap method in MoviesGridView class:

// // For MoviesGridView class (_MoviesGridViewState) - Add this method too:
// bool _isYoutubeUrl(String? url) {
//   if (url == null || url.isEmpty) {
//     return false;
//   }

//   url = url.toLowerCase().trim();

//   // First check if it's a YouTube ID (exactly 11 characters)
//   bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url);
//   if (isYoutubeId) {
//     return true;
//   }

//   // Then check for regular YouTube URLs
//   bool isYoutubeUrl = url.contains('youtube.com') ||
//       url.contains('youtu.be') ||
//       url.contains('youtube.com/shorts/');
//   if (isYoutubeUrl) {
//     return true;
//   }

//   return false;
// }

// Future<void> _handleGridMovieTap(dynamic movie) async {
//   if (_isLoading || !mounted) return;

//   setState(() {
//     _isLoading = true;
//   });

//   bool dialogShown = false;
//   try {
//     if (mounted) {
//       dialogShown = true;
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return WillPopScope(
//             onWillPop: () async {
//               setState(() {
//                 _isLoading = false;
//               });
//               return true;
//             },
//             child: Center(
//               child: Container(
//                 padding: EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.black54,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     CircularProgressIndicator(color: Colors.white),
//                     SizedBox(height: 10),
//                     Text(
//                       'Loading Movie...',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     }

//     // Get movie URL from current movie object
//     Map<String, dynamic> movieMap = movie as Map<String, dynamic>;
//     String movieId = movieMap.safeString('id');
//     String originalUrl = movieMap.safeString('movie_url');
//     String updatedUrl = movieMap.safeString('movie_url');

//     print('🎬 Grid - Movie ID: $movieId');
//     print('🎬 Grid - Movie Name: ${movieMap.safeString('name')}');
//     print('🔗 Grid - Original URL: $originalUrl');

//     // Validate original URL
//     if (originalUrl.isEmpty) {
//       throw Exception('Video URL is not available');
//     }

//     // YouTube URL processing
//     if (isYoutubeUrl(updatedUrl)) {
//       print('🎵 Grid - Processing YouTube URL: $updatedUrl');
//       try {
//       final  playUrl = await Future.any([
//           _socketService.getUpdatedUrl(updatedUrl),
//           // Future.delayed(Duration(seconds: 10), () => originalUrl),
//         ]);
//         print('✅ Grid - Updated  URL: $playUrl');
//         if (playUrl.isNotEmpty) {
//           updatedUrl = playUrl;
//         } else {
//           throw Exception('Failed to fetch  URL');
//         }
//       } catch (e) {
//         print('❌ Grid -  URL update failed: $e');
//         updatedUrl = originalUrl;
//       }
//     }

//     // Fetch fresh movies data
//     List<NewsItemModel> freshMovies = await Future.any([
//       _fetchFreshMoviesForGrid(),
//       Future.delayed(Duration(seconds: 10), () => <NewsItemModel>[]),
//     ]);

//     if (freshMovies.isEmpty) {
//       freshMovies = widget.moviesList.map((m) {
//         try {
//           Map<String, dynamic> movieData = m as Map<String, dynamic>;
//           return NewsItemModel(
//             id: movieData.safeString('id'),
//             name: movieData.safeString('name'),
//             banner: movieData.safeString('banner'),
//             poster: movieData.safeString('poster'),
//             description: movieData.safeString('description'),
//             url: movieData.safeString('url'),
//             streamType: movieData.safeString('streamType'),
//             type: movieData.safeString('type'),
//             genres: movieData.safeString('genres'),
//             status: movieData.safeString('status'),
//             videoId: movieData.safeString('videoId'),
//             index: movieData.safeString('index'),
//             image: '',
//             unUpdatedUrl: '',
//           );
//         } catch (e) {
//           return NewsItemModel(
//             id: '', name: 'Unknown', banner: '', poster: '', description: '',
//             url: '', streamType: '', type: '', genres: '', status: '',
//             videoId: '', index: '', image: '', unUpdatedUrl: '',
//           );
//         }
//       }).toList();
//     }

//     if (mounted) {
//       if (dialogShown) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }

//       // Final validation
//       if (updatedUrl.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Video URL is not available'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       print('🔗 Grid - Final video URL: $updatedUrl');

//       // Navigate to VideoScreen
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => VideoScreen(
//             channelList: freshMovies,
//             source: 'isMovieScreen',
//             name: movieMap.safeString('name'),
//             videoUrl: updatedUrl,
//             unUpdatedUrl: originalUrl,
//             bannerImageUrl: movieMap.safeString('banner'),
//             startAtPosition: Duration.zero,
//             videoType: '',
//             isLive: false,
//             isVOD: true,
//             isLastPlayedStored: false,
//             isSearch: false,
//             isBannerSlider: false,
//             videoId: int.tryParse(movieId),
//             seasonId: 0,
//             liveStatus: false,
//           ),
//         ),
//       );
//     }
//   } catch (e) {
//     print('❌ Grid movie tap error: $e');
//     if (mounted) {
//       if (dialogShown) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   } finally {
//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
// }

//   @override
//   void dispose() {
//     for (var node in _movieFocusNodes.values) {
//       try {
//         node.dispose();
//       } catch (e) {
//         print('Grid focus node dispose error: $e');
//       }
//     }
//     super.dispose();
//   }

//   Future<List<NewsItemModel>> _fetchFreshMoviesForGrid() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String authKey = AuthManager.authKey;
//       if (authKey.isEmpty) {
//         authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
//       }

//       final response = await NetworkHelper.getWithRetry(
//         'https://acomtv.coretechinfo.com/public/api/getAllMovies',
//         headers: {'auth-key': authKey},
//         // timeout: 8,
//       );

//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);

//         if (data.isNotEmpty) {
//           data.sort((a, b) {
//             final aIndex = a['index'];
//             final bIndex = b['index'];

//             if (aIndex == null && bIndex == null) return 0;
//             if (aIndex == null) return 1;
//             if (bIndex == null) return -1;

//             int aVal = 0;
//             int bVal = 0;

//             if (aIndex is num) {
//               aVal = aIndex.toInt();
//             } else if (aIndex is String) {
//               aVal = int.tryParse(aIndex) ?? 0;
//             }

//             if (bIndex is num) {
//               bVal = bIndex.toInt();
//             } else if (bIndex is String) {
//               bVal = int.tryParse(bIndex) ?? 0;
//             }

//             return aVal.compareTo(bVal);
//           });
//         }

//         return data.map((m) {
//           try {
//             Map<String, dynamic> movie = m as Map<String, dynamic>;
//             return NewsItemModel(
//               id: movie.safeString('id'),
//               name: movie.safeString('name'),
//               banner: movie.safeString('banner'),
//               poster: movie.safeString('poster'),
//               description: movie.safeString('description'),
//               url: movie.safeString('url'),
//               streamType: movie.safeString('streamType'),
//               type: movie.safeString('type'),
//               genres: movie.safeString('genres'),
//               status: movie.safeString('status'),
//               videoId: movie.safeString('videoId'),
//               index: movie.safeString('index'),
//               image: '',
//               unUpdatedUrl: '',
//             );
//           } catch (e) {
//             print('Model conversion error: $e');
//             return NewsItemModel(
//               id: '',
//               name: 'Unknown',
//               banner: '',
//               poster: '',
//               description: '',
//               url: '',
//               streamType: '',
//               type: '',
//               genres: '',
//               status: '',
//               videoId: '',
//               index: '',
//               image: '',
//               unUpdatedUrl: '',
//             );
//           }
//         }).toList();
//       }
//     } catch (e) {
//       print('Grid fresh data fetch error: $e');
//     }
//     return [];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'All Movies (${widget.moviesList.length})',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: GridView.builder(
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 5,

//                 // mainAxisSpacing: 12,
//                 // crossAxisSpacing: 12,
//                 // childAspectRatio: 0.7,
//               ),
//               itemCount: widget.moviesList.length,
//               clipBehavior: Clip.none,
//               itemBuilder: (context, index) {
//                 final movie = widget.moviesList[index];
//                 String movieId = movie['id'].toString();

//                 return FocusableMoviesWidget(
//                   imageUrl: movie['banner']?.toString() ?? '',
//                   name: movie['name']?.toString() ?? '',
//                   focusNode: _movieFocusNodes[movieId]!,
//                   movieData: movie,
//                   source: 'isMovieScreen',
//                   onTap: () => _handleGridMovieTap(movie),
//                   fetchPaletteColor: (url) =>
//                       PaletteColorService().getSecondaryColor(url),
//                 );
//               },
//             ),
//           ),
//           if (_isLoading)
//             Container(
//               color: Colors.black.withOpacity(0.7),
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       'Loading Movie...',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// // Enhanced Safe Type Conversion Extension
// extension SafeTypeConversion on Map<String, dynamic> {
//   String safeString(String key, [String defaultValue = '']) {
//     try {
//       final value = this[key];
//       if (value == null) return defaultValue;
//       return value.toString();
//     } catch (e) {
//       return defaultValue;
//     }
//   }

//   int safeInt(String key, [int defaultValue = 0]) {
//     try {
//       final value = this[key];
//       if (value == null) return defaultValue;
//       if (value is int) return value;
//       if (value is String) {
//         return int.tryParse(value) ?? defaultValue;
//       }
//       if (value is double) {
//         return value.toInt();
//       }
//       return defaultValue;
//     } catch (e) {
//       return defaultValue;
//     }
//   }

//   double safeDouble(String key, [double defaultValue = 0.0]) {
//     try {
//       final value = this[key];
//       if (value == null) return defaultValue;
//       if (value is double) return value;
//       if (value is int) return value.toDouble();
//       if (value is String) {
//         return double.tryParse(value) ?? defaultValue;
//       }
//       return defaultValue;
//     } catch (e) {
//       return defaultValue;
//     }
//   }

//   bool safeBool(String key, [bool defaultValue = false]) {
//     try {
//       final value = this[key];
//       if (value == null) return defaultValue;
//       if (value is bool) return value;
//       if (value is String) {
//         return value.toLowerCase() == 'true';
//       }
//       if (value is int) {
//         return value == 1;
//       }
//       return defaultValue;
//     } catch (e) {
//       return defaultValue;
//     }
//   }
// }












import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobi_tv_entertainment/widgets/utils/color_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../video_widget/socket_service.dart';
import '../sub_vod_screen/sub_vod.dart';
import 'focussable_manage_movies_widget.dart';

import 'package:flutter/material.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:better_player/better_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Professional Color Palette
class ProfessionalColors {
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
  static const focusGlow = Color(0xFF60A5FA);

  static List<Color> gradientColors = [
    accentBlue,
    accentPurple,
    accentGreen,
    accentRed,
    accentOrange,
    accentPink,
  ];
}

// Professional Animation Durations
class AnimationTiming {
  static const Duration ultraFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration focus = Duration(milliseconds: 300);
  static const Duration scroll = Duration(milliseconds: 800);
}

// Enhanced Network Helper (keeping your existing one)
class NetworkHelper {
  static final http.Client _client = http.Client();
  static const int _maxConcurrentRequests = 3;
  static int _activeRequests = 0;
  static DateTime? _lastRequestTime;
  static const Duration _requestCooldown = Duration(milliseconds: 500);

  static Future<http.Response> getWithRetry(
    String url, {
    Map<String, String>? headers,
    int timeout = 10,
    int retries = 2,
  }) async {
    final now = DateTime.now();
    if (_lastRequestTime != null &&
        now.difference(_lastRequestTime!) < _requestCooldown) {
      await Future.delayed(_requestCooldown);
    }
    _lastRequestTime = now;

    while (_activeRequests >= _maxConcurrentRequests) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    _activeRequests++;
    try {
      for (int i = 0; i < retries; i++) {
        try {
          final response = await _client
              .get(Uri.parse(url), headers: headers)
              .timeout(Duration(seconds: timeout));

          if (response.statusCode == 200) {
            return response;
          }
        } catch (e) {
          if (i == retries - 1) rethrow;
          await Future.delayed(Duration(seconds: 1 * (i + 1)));
        }
      }
      throw Exception('Failed after $retries attempts');
    } finally {
      _activeRequests--;
    }
  }

  static void dispose() {
    _client.close();
  }
}

// Enhanced Cache Manager (keeping your existing one)
class CacheManager {
  static const String moviesKey = 'movies_list';
  static const String lastUpdateKey = 'movies_last_update';
  static const int maxCacheAgeHours = 6;

  static Future<void> saveMovies(List<dynamic> movies) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(moviesKey, json.encode(movies));
      await prefs.setInt(lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
    }
  }

  static Future<List<dynamic>?> getCachedMovies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(moviesKey);
      if (cachedData != null && !await isCacheExpired()) {
        return json.decode(cachedData);
      }
    } catch (e) {
    }
    return null;
  }

  static Future<bool> isCacheExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdate = prefs.getInt(lastUpdateKey);
      if (lastUpdate == null) return true;

      final now = DateTime.now().millisecondsSinceEpoch;
      final maxAge = maxCacheAgeHours * 60 * 60 * 1000;

      return (now - lastUpdate) > maxAge;
    } catch (e) {
      return true;
    }
  }
}

// Enhanced YouTube URL checker
bool isYoutubeUrl(String? url) {
  if (url == null || url.isEmpty) {
    return false;
  }

  url = url.toLowerCase().trim();

  bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url);
  if (isYoutubeId) {
    return true;
  }

  bool isYouTubeUrl = url.contains('youtube.com') ||
      url.contains('youtu.be') ||
      url.contains('youtube.com/shorts/') ||
      url.contains('www.youtube.com') ||
      url.contains('m.youtube.com');

  return isYouTubeUrl;
}

// Professional Movie Card Widget
class ProfessionalMovieCard extends StatefulWidget {
  final dynamic movie;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final Function(Color) onColorChange;
  final int index;

  const ProfessionalMovieCard({
    Key? key,
    required this.movie,
    required this.focusNode,
    required this.onTap,
    required this.onColorChange,
    required this.index,
  }) : super(key: key);

  @override
  _ProfessionalMovieCardState createState() => _ProfessionalMovieCardState();
}

class _ProfessionalMovieCardState extends State<ProfessionalMovieCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;

  Color _dominantColor = ProfessionalColors.accentBlue;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: AnimationTiming.slow,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: AnimationTiming.medium,
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.06,
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
      widget.onColorChange(_dominantColor);
      HapticFeedback.lightImpact();
    } else {
      _scaleController.reverse();
      _glowController.reverse();
    }
  }

  void _generateDominantColor() {
    final colors = ProfessionalColors.gradientColors;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: screenWidth * 0.19,
            margin: EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfessionalPoster(screenWidth, screenHeight),
                // SizedBox(height: 10),
                _buildProfessionalTitle(screenWidth),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfessionalPoster(double screenWidth, double screenHeight) {
    final posterHeight = _isFocused ? screenHeight * 0.28 : screenHeight * 0.22;

    return Container(
      height: posterHeight,
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
            _buildMovieImage(screenWidth, posterHeight),
            if (_isFocused) _buildFocusBorder(),
            if (_isFocused) _buildShimmerEffect(),
            _buildQualityBadge(),
            if (_isFocused) _buildHoverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieImage(double screenWidth, double posterHeight) {
    final imageUrl = widget.movie['banner']?.toString() ??
        widget.movie['poster']?.toString() ??
        '';

    return Container(
      width: double.infinity,
      height: posterHeight,
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  _buildImagePlaceholder(posterHeight),
              errorWidget: (context, url, error) =>
                  _buildImagePlaceholder(posterHeight),
            )
          : _buildImagePlaceholder(posterHeight),
    );
  }

  Widget _buildImagePlaceholder(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProfessionalColors.cardDark,
            ProfessionalColors.surfaceDark,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_outlined,
            size: height * 0.25,
            color: ProfessionalColors.textSecondary,
          ),
          SizedBox(height: 8),
          Text(
            'No Image',
            style: TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
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

  Widget _buildQualityBadge() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'HD',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
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

  Widget _buildProfessionalTitle(double screenWidth) {
    final movieName =
        widget.movie['name']?.toString()?.toUpperCase() ?? 'UNKNOWN';

    return Container(
      width: screenWidth * 0.18,
      child: AnimatedDefaultTextStyle(
        duration: AnimationTiming.medium,
        style: TextStyle(
          fontSize: _isFocused ? 13 : 11,
          fontWeight: FontWeight.w600,
          color: _isFocused ? _dominantColor : ProfessionalColors.textPrimary,
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
          movieName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// Professional View All Button
class ProfessionalViewAllButton extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int totalMovies;

  const ProfessionalViewAllButton({
    Key? key,
    required this.focusNode,
    required this.onTap,
    required this.totalMovies,
  }) : super(key: key);

  @override
  _ProfessionalViewAllButtonState createState() =>
      _ProfessionalViewAllButtonState();
}

class _ProfessionalViewAllButtonState extends State<ProfessionalViewAllButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  bool _isFocused = false;
  Color _currentColor = ProfessionalColors.accentBlue;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotateController);

    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
      if (_isFocused) {
        _currentColor = ProfessionalColors.gradientColors[
            math.Random().nextInt(ProfessionalColors.gradientColors.length)];
        HapticFeedback.mediumImpact();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.19,
      margin: EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _isFocused ? _pulseAnimation : _rotateAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isFocused ? _pulseAnimation.value : 1.0,
                child: Transform.rotate(
                  angle: _isFocused ? 0 : _rotateAnimation.value * 2 * math.pi,
                  child: Container(
                    height:
                        _isFocused ? screenHeight * 0.28 : screenHeight * 0.22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isFocused
                            ? [
                                _currentColor,
                                _currentColor.withOpacity(0.7),
                              ]
                            : [
                                ProfessionalColors.cardDark,
                                ProfessionalColors.surfaceDark,
                              ],
                      ),
                      boxShadow: [
                        if (_isFocused) ...[
                          BoxShadow(
                            color: _currentColor.withOpacity(0.4),
                            blurRadius: 25,
                            spreadRadius: 3,
                            offset: Offset(0, 8),
                          ),
                        ] else ...[
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ],
                    ),
                    child: _buildViewAllContent(),
                  ),
                ),
              );
            },
          ),
          // SizedBox(height: 10),
          _buildViewAllTitle(),
        ],
      ),
    );
  }

  Widget _buildViewAllContent() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: _isFocused
            ? Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.grid_view_rounded,
                  size: _isFocused ? 45 : 35,
                  color: Colors.white,
                ),
                // SizedBox(height: 8),
                Text(
                  'VIEW ALL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _isFocused ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.totalMovies}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
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

  Widget _buildViewAllTitle() {
    return AnimatedDefaultTextStyle(
      duration: AnimationTiming.medium,
      style: TextStyle(
        fontSize: _isFocused ? 13 : 11,
        fontWeight: FontWeight.w600,
        color: _isFocused ? _currentColor : ProfessionalColors.textPrimary,
        letterSpacing: 0.5,
        shadows: _isFocused
            ? [
                Shadow(
                  color: _currentColor.withOpacity(0.6),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Text(
        'ALL MOVIES',
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// Enhanced Loading Indicator
class ProfessionalLoadingIndicator extends StatefulWidget {
  final String message;

  const ProfessionalLoadingIndicator({
    Key? key,
    this.message = 'Loading Movies...',
  }) : super(key: key);

  @override
  _ProfessionalLoadingIndicatorState createState() =>
      _ProfessionalLoadingIndicatorState();
}

class _ProfessionalLoadingIndicatorState
    extends State<ProfessionalLoadingIndicator> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      ProfessionalColors.accentBlue,
                      ProfessionalColors.accentPurple,
                      ProfessionalColors.accentGreen,
                      ProfessionalColors.accentBlue,
                    ],
                    stops: [0.0, 0.3, 0.7, 1.0],
                    transform: GradientRotation(_animation.value * 2 * math.pi),
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ProfessionalColors.primaryDark,
                  ),
                  child: Icon(
                    Icons.movie_rounded,
                    color: ProfessionalColors.textPrimary,
                    size: 28,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24),
          Text(
            widget.message,
            style: TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          Container(
            width: 200,
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: ProfessionalColors.surfaceDark,
            ),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _animation.value,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ProfessionalColors.accentBlue,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Main Enhanced Movies Screen
class Movies extends StatefulWidget {
  final Function(bool)? onFocusChange;
  final FocusNode focusNode;

  const Movies({Key? key, this.onFocusChange, required this.focusNode})
      : super(key: key);

  @override
  _MoviesState createState() => _MoviesState();
}

class _MoviesState extends State<Movies>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  // Core data
  List<dynamic> moviesList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isNavigating = false;

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;

  // Services and controllers
  final PaletteColorService _paletteColorService = PaletteColorService();
  final ScrollController _scrollController = ScrollController();
  late SocketService _socketService;

  // Focus management
  Map<String, FocusNode> movieFocusNodes = {};
  FocusNode? _viewAllFocusNode;
  Color _currentAccentColor = ProfessionalColors.accentBlue;

  // Performance optimizations
  Timer? _timer;
  Timer? _backgroundFetchTimer;
  DateTime? _lastFetchTime;
  static const Duration _fetchCooldown = Duration(minutes: 3);

  @override
  void initState() {
    super.initState();

    _initializeAnimations();
    _initializeServices();
    _initializeViewAllFocusNode();
    _loadCachedDataAndFetchMovies();

    _backgroundFetchTimer = Timer.periodic(
        Duration(minutes: 10), (_) => _fetchMoviesInBackground());
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: AnimationTiming.slow,
      vsync: this,
    );

    _listAnimationController = AnimationController(
      duration: AnimationTiming.slow,
      vsync: this,
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _listFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeServices() {
    _socketService = SocketService();
    _socketService.initSocket();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<FocusProvider>(context, listen: false)
            .setMoviesScrollController(_scrollController);
      }
    });
  }

  void _initializeViewAllFocusNode() {
    _viewAllFocusNode = FocusNode()
      ..addListener(() {
        if (mounted && _viewAllFocusNode!.hasFocus) {
          setState(() {
            _currentAccentColor = ProfessionalColors.gradientColors[
                math.Random()
                    .nextInt(ProfessionalColors.gradientColors.length)];
          });
        }
      });
  }

  void debugMovieData(Map<String, dynamic> movie) {
  }

  void _sortMoviesData(List<dynamic> data) {
    if (data.isEmpty) return;

    try {
      data.sort((a, b) {
        final aIndex = a['index'];
        final bIndex = b['index'];

        if (aIndex == null && bIndex == null) return 0;
        if (aIndex == null) return 1;
        if (bIndex == null) return -1;

        int aVal = 0;
        int bVal = 0;

        if (aIndex is num) {
          aVal = aIndex.toInt();
        } else if (aIndex is String) {
          aVal = int.tryParse(aIndex) ?? 0;
        }

        if (bIndex is num) {
          bVal = bIndex.toInt();
        } else if (bIndex is String) {
          bVal = int.tryParse(bIndex) ?? 0;
        }

        return aVal.compareTo(bVal);
      });
    } catch (e) {
    }
  }

  Future<void> _fetchMoviesInBackground() async {
    if (!mounted) return;

    final now = DateTime.now();
    if (_lastFetchTime != null &&
        now.difference(_lastFetchTime!) < _fetchCooldown) {
      return;
    }
    _lastFetchTime = now;

    try {
      final prefs = await SharedPreferences.getInstance();
      String authKey = AuthManager.authKey;
      if (authKey.isEmpty) {
        authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
      }

      final response = await NetworkHelper.getWithRetry(
        'https://acomtv.coretechinfo.com/public/api/getAllMovies',
        headers: {'auth-key': authKey},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _sortMoviesData(data);

        final cachedMovies = prefs.getString('movies_list');
        final String newMoviesJson = json.encode(data);

        if (cachedMovies != newMoviesJson) {
          await CacheManager.saveMovies(data);

          if (mounted) {
            setState(() {
              moviesList = data;
              _initializeMovieFocusNodes();
            });
          }
        }
      }
    } catch (e) {
    }
  }

  Future<void> _fetchMovies() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String authKey = AuthManager.authKey;
      if (authKey.isEmpty) {
        authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
      }

      final response = await NetworkHelper.getWithRetry(
        'https://acomtv.coretechinfo.com/public/api/getAllMovies',
        headers: {'auth-key': authKey},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _sortMoviesData(data);

        await CacheManager.saveMovies(data);

        if (mounted) {
          setState(() {
            moviesList = data;
            _initializeMovieFocusNodes();
            _isLoading = false;
          });

          // Start animations after data loads
          _headerAnimationController.forward();
          _listAnimationController.forward();
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to load movies (${response.statusCode})';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Network error: Please check connection';
          _isLoading = false;
        });
      }
    }
  }

  List<NewsItemModel> _convertToNewsItemModels(List<dynamic> movies) {
    return movies.map((m) {
      try {
        Map<String, dynamic> movie = m as Map<String, dynamic>;
        return NewsItemModel(
          id: movie.safeString('id'),
          name: movie.safeString('name'),
          banner: movie.safeString('banner'),
          poster: movie.safeString('poster'),
          description: movie.safeString('description'),
          url: movie.safeString('url'),
          streamType: movie.safeString('streamType'),
          type: movie.safeString('type'),
          genres: movie.safeString('genres'),
          status: movie.safeString('status'),
          videoId: movie.safeString('videoId'),
          index: movie.safeString('index'),
          image: '',
          unUpdatedUrl: '',
        );
      } catch (e) {
        return NewsItemModel(
          id: '',
          name: 'Unknown',
          banner: '',
          poster: '',
          description: '',
          url: '',
          streamType: '',
          type: '',
          genres: '',
          status: '',
          videoId: '',
          index: '',
          image: '',
          unUpdatedUrl: '',
        );
      }
    }).toList();
  }

  Future<void> _handleMovieTap(dynamic movie) async {
    if (_isNavigating || !mounted) return;

    _isNavigating = true;
    bool dialogShown = false;
    Timer? timeoutTimer;

    try {
      debugMovieData(movie);

      if (mounted) {
        dialogShown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async {
                _isNavigating = false;
                return true;
              },
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ProfessionalColors.accentBlue,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Preparing video...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }

      timeoutTimer = Timer(Duration(seconds: 20), () {
        if (mounted && _isNavigating) {
          _isNavigating = false;
          if (dialogShown) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Request timeout. Please check your connection.'),
              backgroundColor: ProfessionalColors.accentRed,
            ),
          );
        }
      });

      Map<String, dynamic> movieMap = movie as Map<String, dynamic>;
      String movieId = movieMap.safeString('id');
      String originalUrl = movieMap.safeString('movie_url');
      String updatedUrl = movieMap.safeString('movie_url');


      if (originalUrl.isEmpty) {
        throw Exception('Video URL is not available');
      }

      // if (isYoutubeUrl(updatedUrl)) {
      //   try {
      //     for (int attempt = 1; attempt <= 3; attempt++) {
      //       try {
      //         final playUrl = await _socketService.getUpdatedUrl(updatedUrl);

      //         if (playUrl != null && playUrl.isNotEmpty) {
      //           updatedUrl = playUrl;
      //           break;
      //         }
      //       } catch (e) {
      //         if (attempt == 3) {
      //         } else {
      //           await Future.delayed(Duration(seconds: 1));
      //         }
      //       }
      //     }
      //   } catch (e) {
      //   }
      // }

      List<NewsItemModel> freshMovies = await Future.any([
        _fetchFreshMoviesData(),
        Future.delayed(Duration(seconds: 12), () => <NewsItemModel>[]),
      ]);

      if (freshMovies.isEmpty) {
        freshMovies = _convertToNewsItemModels(moviesList);
      }

      timeoutTimer.cancel();

      if (mounted && _isNavigating) {
        if (dialogShown) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (updatedUrl.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Video URL is not available'),
              backgroundColor: ProfessionalColors.accentRed,
            ),
          );
          return;
        }


        try {
          await Navigator.push(
            context,
            MaterialPageRoute(
              // builder: (context) => VideoScreen(
              //   channelList: freshMovies,
              //   source: 'isMovieScreen',
              //   name: movieMap.safeString('name'),
              //   videoUrl: updatedUrl,
              //   unUpdatedUrl: originalUrl,
              //   bannerImageUrl: movieMap.safeString('banner'),
              //   startAtPosition: Duration.zero,
              //   videoType: '',
              //   isLive: false,
              //   isVOD: true,
              //   isLastPlayedStored: false,
              //   isSearch: false,
              //   isBannerSlider: false,
              //   videoId: int.tryParse(movieId),
              //   seasonId: 0,
              //   liveStatus: false,
              // ),
              builder: (context) => FullscreenYouTubePlayer(
                youtubeId: originalUrl, // pass the video ID here
              ),
            ),
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to open video player'),
                backgroundColor: ProfessionalColors.accentRed,
              ),
            );
          }
        }
      }
    } catch (e) {
      timeoutTimer?.cancel();
      if (mounted) {
        if (dialogShown) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: ProfessionalColors.accentRed,
          ),
        );
      }
    } finally {
      _isNavigating = false;
      timeoutTimer?.cancel();
    }
  }

  bool _isYoutubeUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }

    url = url.toLowerCase().trim();

    // bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}).hasMatch(url);
    bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url);
    if (isYoutubeId) {
      return true;
    }

    bool isYoutubeUrl = url.contains('youtube.com') ||
        url.contains('youtu.be') ||
        url.contains('youtube.com/shorts/');
    if (isYoutubeUrl) {
      return true;
    }

    return false;
  }

  Future<List<NewsItemModel>> _fetchFreshMoviesData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String authKey = AuthManager.authKey;
      if (authKey.isEmpty) {
        authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
      }

      final response = await NetworkHelper.getWithRetry(
        'https://acomtv.coretechinfo.com/public/api/getAllMovies',
        headers: {'auth-key': authKey},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _sortMoviesData(data);
        return _convertToNewsItemModels(data);
      }
    } catch (e) {
    }
    return [];
  }

  @override
  void dispose() {
    _timer?.cancel();
    _backgroundFetchTimer?.cancel();
    _headerAnimationController.dispose();
    _listAnimationController.dispose();

    for (var entry in movieFocusNodes.entries) {
      try {
        entry.value.removeListener(() {});
        entry.value.dispose();
      } catch (e) {
      }
    }
    movieFocusNodes.clear();

    try {
      _viewAllFocusNode?.removeListener(() {});
      _viewAllFocusNode?.dispose();
    } catch (e) {
    }

    try {
      _scrollController.dispose();
    } catch (e) {
    }

    _isNavigating = false;
    super.dispose();
  }

  void _initializeMovieFocusNodes() {
    for (var node in movieFocusNodes.values) {
      try {
        node.removeListener(() {});
        node.dispose();
      } catch (e) {
      }
    }
    movieFocusNodes.clear();

    for (var movie in moviesList) {
      try {
        String movieId = movie['id'].toString();
        movieFocusNodes[movieId] = FocusNode()
          ..addListener(() {
            if (mounted && movieFocusNodes[movieId]!.hasFocus) {
              _scrollToFocusedItem(movieId);
            }
          });
      } catch (e) {
        // Silent error handling
      }
    }
    _registerMoviesFocus();
  }

  void _registerMoviesFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && moviesList.isNotEmpty) {
        try {
          final focusProvider = context.read<FocusProvider>();
          final firstMovieId = moviesList[0]['id'].toString();

          if (movieFocusNodes.containsKey(firstMovieId)) {
            focusProvider
                .setFirstManageMoviesFocusNode(movieFocusNodes[firstMovieId]!);
          }
        } catch (e) {
        }
      }
    });
  }

  Future<void> _loadCachedDataAndFetchMovies() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final cachedMovies = await CacheManager.getCachedMovies();

      if (cachedMovies != null && mounted) {
        setState(() {
          moviesList = cachedMovies;
          _initializeMovieFocusNodes();
          _isLoading = false;
        });

        _headerAnimationController.forward();
        _listAnimationController.forward();
        _fetchMoviesInBackground();
      } else {
        await _fetchMovies();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load movies';
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToFocusedItem(String itemId) {
    if (!mounted) return;

    try {
      final focusNode = movieFocusNodes[itemId];
      if (focusNode != null &&
          focusNode.hasFocus &&
          focusNode.context != null) {
        Scrollable.ensureVisible(
          focusNode.context!,
          alignment: 0.02,
          duration: AnimationTiming.scroll,
          curve: Curves.easeInOutCubic,
        );
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          SizedBox(height: screenhgt * 0.02),
          _buildProfessionalTitle(),
          SizedBox(height: screenhgt * 0.01),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildProfessionalTitle() {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.025),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  ProfessionalColors.accentBlue,
                  ProfessionalColors.accentPurple,
                ],
              ).createShader(bounds),
              child: Text(
                'MOVIES',
                style: TextStyle(
                  fontSize: Headingtextsz,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            if (moviesList.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ProfessionalColors.accentBlue.withOpacity(0.2),
                      ProfessionalColors.accentPurple.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ProfessionalColors.accentBlue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${moviesList.length} Movies',
                  style: TextStyle(
                    color: ProfessionalColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ProfessionalLoadingIndicator(message: 'Loading Movies...');
    } else if (_errorMessage.isNotEmpty) {
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
                    ProfessionalColors.accentRed.withOpacity(0.2),
                    ProfessionalColors.accentRed.withOpacity(0.1),
                  ],
                ),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: ProfessionalColors.accentRed,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                color: ProfessionalColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                color: ProfessionalColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchMovies,
              style: ElevatedButton.styleFrom(
                backgroundColor: ProfessionalColors.accentBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    } else if (moviesList.isEmpty) {
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
                    ProfessionalColors.accentBlue.withOpacity(0.2),
                    ProfessionalColors.accentBlue.withOpacity(0.1),
                  ],
                ),
              ),
              child: Icon(
                Icons.movie_outlined,
                size: 40,
                color: ProfessionalColors.accentBlue,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No movies found',
              style: TextStyle(
                color: ProfessionalColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Check back later for new content',
              style: TextStyle(
                color: ProfessionalColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    } else {
      return _buildMoviesList();
    }
  }

  Widget _buildMoviesList() {
    bool showViewAll = moviesList.length > 7;

    return FadeTransition(
      opacity: _listFadeAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.025),
          cacheExtent: 1200,
          itemCount: showViewAll ? 8 : moviesList.length,
          itemBuilder: (context, index) {
            if (showViewAll && index == 7) {
              return Focus(
                focusNode: _viewAllFocusNode,
                onKey: (FocusNode node, RawKeyEvent event) {
                  if (event is RawKeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                      return KeyEventResult.handled;
                    } else if (event.logicalKey ==
                        LogicalKeyboardKey.arrowLeft) {
                      if (moviesList.isNotEmpty && moviesList.length > 6) {
                        String movieId = moviesList[6]['id'].toString();
                        FocusScope.of(context)
                            .requestFocus(movieFocusNodes[movieId]);
                        return KeyEventResult.handled;
                      }
                    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                      context.read<FocusProvider>().requestSubVodFocus();
                      return KeyEventResult.handled;
                    } else if (event.logicalKey ==
                        LogicalKeyboardKey.arrowDown) {
                      FocusScope.of(context).unfocus();
                      Future.delayed(const Duration(milliseconds: 50), () {
                        if (mounted) {
                          context
                              .read<FocusProvider>()
                              .requestFirstWebseriesFocus();
                        }
                      });
                      return KeyEventResult.handled;
                    } else if (event.logicalKey == LogicalKeyboardKey.select) {
                      _navigateToMoviesGrid();
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: GestureDetector(
                  onTap: _navigateToMoviesGrid,
                  child: AdvancedProfessionalViewAllButton(
                    focusNode: _viewAllFocusNode!,
                    onTap: _navigateToMoviesGrid,
                    totalMovies: moviesList.length,
                  ),
                ),
              );
            }

            var movie = moviesList[index];
            return _buildMovieItem(movie, index);
          },
        ),
      ),
    );
  }

  Widget _buildMovieItem(dynamic movie, int index) {
    String movieId = movie['id'].toString();

    movieFocusNodes.putIfAbsent(
      movieId,
      () => FocusNode()
        ..addListener(() {
          if (mounted && movieFocusNodes[movieId]!.hasFocus) {
            _scrollToFocusedItem(movieId);
          }
        }),
    );

    return Focus(
      focusNode: movieFocusNodes[movieId],
      onFocusChange: (hasFocus) async {
        if (hasFocus && mounted) {
          try {
            Color dominantColor = await _paletteColorService.getSecondaryColor(
              movie['poster']?.toString() ?? '',
              fallbackColor: ProfessionalColors.accentBlue,
            );
            if (mounted) {
              context.read<ColorProvider>().updateColor(dominantColor, true);
            }
          } catch (e) {
            if (mounted) {
              context
                  .read<ColorProvider>()
                  .updateColor(ProfessionalColors.accentBlue, true);
            }
          }
        } else if (mounted) {
          context.read<ColorProvider>().resetColor();
        }
      },
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (index < moviesList.length - 1 && index != 6) {
              String nextMovieId = moviesList[index + 1]['id'].toString();
              FocusScope.of(context).requestFocus(movieFocusNodes[nextMovieId]);
              return KeyEventResult.handled;
            } else if (index == 6 && moviesList.length > 7) {
              FocusScope.of(context).requestFocus(_viewAllFocusNode);
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (index > 0) {
              String prevMovieId = moviesList[index - 1]['id'].toString();
              FocusScope.of(context).requestFocus(movieFocusNodes[prevMovieId]);
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            context.read<FocusProvider>().requestSubVodFocus();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                Provider.of<FocusProvider>(context, listen: false)
                    .requestFirstWebseriesFocus();
              }
            });
            return KeyEventResult.ignored;
          } else if (event.logicalKey == LogicalKeyboardKey.select) {
            _handleMovieTap(movie);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _handleMovieTap(movie),
        child: ProfessionalMovieCard(
          movie: movie,
          focusNode: movieFocusNodes[movieId]!,
          onTap: () => _handleMovieTap(movie),
          onColorChange: (color) {
            setState(() {
              _currentAccentColor = color;
            });
          },
          index: index,
        ),
      ),
    );
  }

  void _navigateToMoviesGrid() {
    if (!_isNavigating && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ProfessionalMoviesGridView(moviesList: moviesList),
        ),
      );
    }
  }
}

// 🎨 Advanced Professional View All Button - UI के साथ perfectly match

class AdvancedProfessionalViewAllButton extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int totalMovies;

  const AdvancedProfessionalViewAllButton({
    Key? key,
    required this.focusNode,
    required this.onTap,
    required this.totalMovies,
  }) : super(key: key);

  @override
  _AdvancedProfessionalViewAllButtonState createState() =>
      _AdvancedProfessionalViewAllButtonState();
}

class _AdvancedProfessionalViewAllButtonState
    extends State<AdvancedProfessionalViewAllButton>
    with TickerProviderStateMixin {
  // Multiple Animation Controllers for complex effects
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;
  late AnimationController _breathingController;
  late AnimationController _particleController;

  // Animations
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _particleAnimation;

  // State
  bool _isFocused = false;
  Color _currentColor = ProfessionalColors.accentBlue;
  List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    widget.focusNode.addListener(_handleFocusChange);
  }

  void _initializeAnimations() {
    // Scale Animation - Same as movie cards
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 700), // Match movie cards
      vsync: this,
    );

    // Glow Animation
    _glowController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    // Shimmer Animation
    _shimmerController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    // Breathing Animation (subtle pulse when not focused)
    _breathingController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    // Particle Animation
    _particleController = AnimationController(
      duration: Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    // Animation Definitions
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.04, // Same as movie cards
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

    _breathingAnimation = Tween<double>(
      begin: 0.95,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);
  }

  void _generateParticles() {
    _particles = List.generate(
        8,
        (index) => Particle(
              initialX: math.Random().nextDouble(),
              initialY: math.Random().nextDouble(),
              size: math.Random().nextDouble() * 3 + 1,
              speed: math.Random().nextDouble() * 0.5 + 0.3,
              color: ProfessionalColors.gradientColors[math.Random()
                      .nextInt(ProfessionalColors.gradientColors.length)]
                  .withOpacity(0.6),
            ));
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
      if (_isFocused) {
        _currentColor = ProfessionalColors.gradientColors[
            math.Random().nextInt(ProfessionalColors.gradientColors.length)];
        HapticFeedback.mediumImpact();
      }
    });

    if (_isFocused) {
      _scaleController.forward();
      _glowController.forward();
      _shimmerController.repeat();
    } else {
      _scaleController.reverse();
      _glowController.reverse();
      _shimmerController.stop();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    _breathingController.dispose();
    _particleController.dispose();
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.24,
      margin: EdgeInsets.symmetric(horizontal: 6), // Same as movie cards
      child: Column(
        children: [
          _buildAdvancedViewAllCard(screenWidth, screenHeight),
          SizedBox(height: 10), // Same spacing as movie cards
          _buildAdvancedTitle(),
        ],
      ),
    );
  }

  Widget _buildAdvancedViewAllCard(double screenWidth, double screenHeight) {
    // Same height logic as movie cards
    final cardHeight = _isFocused
        ? screenHeight * 0.25 // Match movie card focused height
        : screenHeight * 0.22; // Match movie card normal height

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _glowAnimation,
        _breathingAnimation,
        _particleAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _isFocused ? _scaleAnimation.value : _breathingAnimation.value,
          child: Container(
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), // Same as movie cards
              boxShadow: [
                if (_isFocused) ...[
                  // Same shadow pattern as movie cards
                  BoxShadow(
                    color: _currentColor.withOpacity(0.4),
                    blurRadius: 25,
                    spreadRadius: 3,
                    offset: Offset(0, 8),
                  ),
                  BoxShadow(
                    color: _currentColor.withOpacity(0.2),
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
                  _buildMovieStyleBackground(),
                  if (_isFocused) _buildFocusBorder(),
                  if (_isFocused) _buildShimmerEffect(),
                  _buildFloatingParticles(),
                  _buildCenterContent(),
                  _buildQualityBadge(), // Same as movie cards
                  if (_isFocused) _buildHoverOverlay(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMovieStyleBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isFocused
              ? [
                  _currentColor.withOpacity(0.8),
                  _currentColor.withOpacity(0.6),
                  ProfessionalColors.cardDark.withOpacity(0.9),
                ]
              : [
                  ProfessionalColors.cardDark,
                  ProfessionalColors.surfaceDark,
                  ProfessionalColors.cardDark.withOpacity(0.8),
                ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.1),
              Colors.black.withOpacity(0.3),
            ],
          ),
        ),
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
            color: _currentColor,
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
                  _currentColor.withOpacity(0.15),
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

  Widget _buildFloatingParticles() {
    if (!_isFocused) return SizedBox.shrink();

    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return Stack(
          children: _particles.map((particle) {
            final progress = (_particleAnimation.value + particle.speed) % 1.0;
            final x = (particle.initialX + progress * 0.3) % 1.0;
            final y = (particle.initialY + progress * 0.5) % 1.0;

            return Positioned(
              left: x * screenwdt * 0.19,
              top: y * (MediaQuery.of(context).size.height * 0.25),
              child: Container(
                width: particle.size,
                height: particle.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: particle.color,
                  boxShadow: [
                    BoxShadow(
                      color: particle.color,
                      blurRadius: particle.size,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCenterContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main Icon with rotation effect
          AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _isFocused ? _particleAnimation.value * 0.5 : 0,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(_isFocused ? 0.2 : 0.1),
                    border: Border.all(
                      color: Colors.white.withOpacity(_isFocused ? 0.4 : 0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.grid_view_rounded,
                    size: _isFocused ? 35 : 30,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),

          // SizedBox(height: 12),

          // Text with typewriter effect
          Text(
            'VIEW ALL',
            style: TextStyle(
              color: Colors.white,
              fontSize: _isFocused ? 14 : 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: _isFocused
                      ? _currentColor.withOpacity(0.6)
                      : Colors.black.withOpacity(0.5),
                  blurRadius: _isFocused ? 8 : 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),

          // SizedBox(height: 6),

          // Movie count badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isFocused
                    ? [
                        _currentColor.withOpacity(0.3),
                        _currentColor.withOpacity(0.1),
                      ]
                    : [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.1),
                      ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _isFocused
                    ? _currentColor.withOpacity(0.5)
                    : Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '${widget.totalMovies}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityBadge() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'ALL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
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
              _currentColor.withOpacity(0.1),
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
              Icons.explore_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedTitle() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.18, // Same as movie cards
      child: AnimatedDefaultTextStyle(
        duration: Duration(milliseconds: 250), // Same timing as movie cards
        style: TextStyle(
          fontSize: _isFocused ? 13 : 11, // Same sizes as movie cards
          fontWeight: FontWeight.w600,
          color: _isFocused ? _currentColor : ProfessionalColors.textPrimary,
          letterSpacing: 0.5,
          shadows: _isFocused
              ? [
                  Shadow(
                    color: _currentColor.withOpacity(0.6),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          'ALL MOVIES',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// Particle class for floating effects
class Particle {
  final double initialX;
  final double initialY;
  final double size;
  final double speed;
  final Color color;

  Particle({
    required this.initialX,
    required this.initialY,
    required this.size,
    required this.speed,
    required this.color,
  });
}

// 🔄 USAGE: Original ProfessionalViewAllButton को replace करें
// Old code में यहाँ change करें:

/*
// REMOVE OLD:
ProfessionalViewAllButton(
  focusNode: _viewAllFocusNode!,
  onTap: _navigateToMoviesGrid,
  totalMovies: moviesList.length,
)

// ADD NEW:
AdvancedProfessionalViewAllButton(
  focusNode: _viewAllFocusNode!,
  onTap: _navigateToMoviesGrid,
  totalMovies: moviesList.length,
)
*/

// Enhanced Professional Movies Grid View
class ProfessionalMoviesGridView extends StatefulWidget {
  final List<dynamic> moviesList;

  const ProfessionalMoviesGridView({Key? key, required this.moviesList})
      : super(key: key);

  @override
  _ProfessionalMoviesGridViewState createState() =>
      _ProfessionalMoviesGridViewState();
}

class _ProfessionalMoviesGridViewState extends State<ProfessionalMoviesGridView>
    with TickerProviderStateMixin {
  late Map<String, FocusNode> _movieFocusNodes;
  bool _isLoading = false;
  late SocketService _socketService;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _socketService = SocketService();
    _socketService.initSocket();

    _movieFocusNodes = {
      for (var movie in widget.moviesList) movie['id'].toString(): FocusNode()
    };

    // Set up focus for the first movie
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.moviesList.isNotEmpty) {
        final firstMovieId = widget.moviesList[0]['id'].toString();
        if (_movieFocusNodes.containsKey(firstMovieId)) {
          FocusScope.of(context).requestFocus(_movieFocusNodes[firstMovieId]);
        }
      }
    });

    _initializeAnimations();
    _startStaggeredAnimation();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _startStaggeredAnimation() {
    _fadeController.forward();
    _staggerController.forward();
  }

  bool _isYoutubeUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }

    url = url.toLowerCase().trim();

    bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url);
    if (isYoutubeId) {
      return true;
    }

    bool isYoutubeUrl = url.contains('youtube.com') ||
        url.contains('youtu.be') ||
        url.contains('youtube.com/shorts/');
    if (isYoutubeUrl) {
      return true;
    }

    return false;
  }

  Future<void> _handleGridMovieTap(dynamic movie) async {
    if (_isLoading || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    bool dialogShown = false;
    try {
      if (mounted) {
        dialogShown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async {
                setState(() {
                  _isLoading = false;
                });
                return true;
              },
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ProfessionalColors.accentBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ProfessionalColors.accentBlue,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Loading Movie...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please wait',
                        style: TextStyle(
                          color: ProfessionalColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }

      Map<String, dynamic> movieMap = movie as Map<String, dynamic>;
      String movieId = movieMap.safeString('id');
      String originalUrl = movieMap.safeString('movie_url');
      String updatedUrl = movieMap.safeString('movie_url');


      if (originalUrl.isEmpty) {
        throw Exception('Video URL is not available');
      }

      if (isYoutubeUrl(updatedUrl)) {
        try {
          // final playUrl = await Future.any([
          //   _socketService.getUpdatedUrl(updatedUrl),
          //   Future.delayed(Duration(seconds: 15), () => ''),
          // ]);
          final playUrl = await _socketService.getUpdatedUrl(updatedUrl);
          if (playUrl.isNotEmpty) {
            updatedUrl = playUrl;
          } else {
            throw Exception('Failed to fetch updated URL');
          }
        } catch (e) {
          updatedUrl = originalUrl;
        }
      }

      List<NewsItemModel> freshMovies = await Future.any([
        _fetchFreshMoviesForGrid(),
        Future.delayed(Duration(seconds: 10), () => <NewsItemModel>[]),
      ]);

      if (freshMovies.isEmpty) {
        freshMovies = widget.moviesList.map((m) {
          try {
            Map<String, dynamic> movieData = m as Map<String, dynamic>;
            return NewsItemModel(
              id: movieData.safeString('id'),
              name: movieData.safeString('name'),
              banner: movieData.safeString('banner'),
              poster: movieData.safeString('poster'),
              description: movieData.safeString('description'),
              url: movieData.safeString('url'),
              streamType: movieData.safeString('streamType'),
              type: movieData.safeString('type'),
              genres: movieData.safeString('genres'),
              status: movieData.safeString('status'),
              videoId: movieData.safeString('videoId'),
              index: movieData.safeString('index'),
              image: '',
              unUpdatedUrl: '',
            );
          } catch (e) {
            return NewsItemModel(
              id: '',
              name: 'Unknown',
              banner: '',
              poster: '',
              description: '',
              url: '',
              streamType: '',
              type: '',
              genres: '',
              status: '',
              videoId: '',
              index: '',
              image: '',
              unUpdatedUrl: '',
            );
          }
        }).toList();
      }

      if (mounted) {
        if (dialogShown) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (updatedUrl.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Video URL is not available'),
              backgroundColor: ProfessionalColors.accentRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          return;
        }


        await Navigator.push(
          context,
          MaterialPageRoute(
            // builder: (context) => VideoScreen(
            //   channelList: freshMovies,
            //   source: 'isMovieScreen',
            //   name: movieMap.safeString('name'),
            //   videoUrl: updatedUrl,
            //   unUpdatedUrl: originalUrl,
            //   bannerImageUrl: movieMap.safeString('banner'),
            //   startAtPosition: Duration.zero,
            //   videoType: '',
            //   isLive: false,
            //   isVOD: true,
            //   isLastPlayedStored: false,
            //   isSearch: false,
            //   isBannerSlider: false,
            //   videoId: int.tryParse(movieId),
            //   seasonId: 0,
            //   liveStatus: false,
            // ),
            //           builder: (context) => BetterPlayerExample (
            // videoUrl: updatedUrl,
            // videoTitle: movieMap.safeString('name'),
            // ),
                      builder: (context) => FullscreenYouTubePlayer(
                youtubeId: originalUrl, // pass the video ID here
              ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        if (dialogShown) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading movie'),
            backgroundColor: ProfessionalColors.accentRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _staggerController.dispose();
    for (var node in _movieFocusNodes.values) {
      try {
        node.dispose();
      } catch (e) {
      }
    }
    super.dispose();
  }

  Future<List<NewsItemModel>> _fetchFreshMoviesForGrid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String authKey = AuthManager.authKey;
      if (authKey.isEmpty) {
        authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
      }

      final response = await NetworkHelper.getWithRetry(
        'https://acomtv.coretechinfo.com/public/api/getAllMovies',
        headers: {'auth-key': authKey},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          data.sort((a, b) {
            final aIndex = a['index'];
            final bIndex = b['index'];

            if (aIndex == null && bIndex == null) return 0;
            if (aIndex == null) return 1;
            if (bIndex == null) return -1;

            int aVal = 0;
            int bVal = 0;

            if (aIndex is num) {
              aVal = aIndex.toInt();
            } else if (aIndex is String) {
              aVal = int.tryParse(aIndex) ?? 0;
            }

            if (bIndex is num) {
              bVal = bIndex.toInt();
            } else if (bIndex is String) {
              bVal = int.tryParse(bIndex) ?? 0;
            }

            return aVal.compareTo(bVal);
          });
        }

        return data.map((m) {
          try {
            Map<String, dynamic> movie = m as Map<String, dynamic>;
            return NewsItemModel(
              id: movie.safeString('id'),
              name: movie.safeString('name'),
              banner: movie.safeString('banner'),
              poster: movie.safeString('poster'),
              description: movie.safeString('description'),
              url: movie.safeString('url'),
              streamType: movie.safeString('streamType'),
              type: movie.safeString('type'),
              genres: movie.safeString('genres'),
              status: movie.safeString('status'),
              videoId: movie.safeString('videoId'),
              index: movie.safeString('index'),
              image: '',
              unUpdatedUrl: '',
            );
          } catch (e) {
            return NewsItemModel(
              id: '',
              name: 'Unknown',
              banner: '',
              poster: '',
              description: '',
              url: '',
              streamType: '',
              type: '',
              genres: '',
              status: '',
              videoId: '',
              index: '',
              image: '',
              unUpdatedUrl: '',
            );
          }
        }).toList();
      }
    } catch (e) {
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalColors.primaryDark,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ProfessionalColors.primaryDark,
                  ProfessionalColors.surfaceDark.withOpacity(0.8),
                  ProfessionalColors.primaryDark,
                ],
              ),
            ),
          ),

          // Main Content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildProfessionalAppBar(),
                Expanded(
                  child: _buildMoviesGrid(),
                ),
              ],
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child:
                    ProfessionalLoadingIndicator(message: 'Loading Movie...'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfessionalAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ProfessionalColors.surfaceDark.withOpacity(0.9),
            ProfessionalColors.surfaceDark.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ProfessionalColors.accentBlue.withOpacity(0.2),
                  ProfessionalColors.accentPurple.withOpacity(0.2),
                ],
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      ProfessionalColors.accentBlue,
                      ProfessionalColors.accentPurple,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'All Movies',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ProfessionalColors.accentBlue.withOpacity(0.2),
                        ProfessionalColors.accentPurple.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: ProfessionalColors.accentBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${widget.moviesList.length} Movies Available',
                    style: TextStyle(
                      color: ProfessionalColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoviesGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.68,
        ),
        itemCount: widget.moviesList.length,
        clipBehavior: Clip.none,
        itemBuilder: (context, index) {
          final movie = widget.moviesList[index];
          String movieId = movie['id'].toString();

          return AnimatedBuilder(
            animation: _staggerController,
            builder: (context, child) {
              final delay = (index / widget.moviesList.length) * 0.5;
              final animationValue = Interval(
                delay,
                delay + 0.5,
                curve: Curves.easeOutCubic,
              ).transform(_staggerController.value);

              return Transform.translate(
                offset: Offset(0, 50 * (1 - animationValue)),
                child: Opacity(
                  opacity: animationValue,
                  child: ProfessionalGridMovieCard(
                    movie: movie,
                    focusNode: _movieFocusNodes[movieId]!,
                    onTap: () => _handleGridMovieTap(movie),
                    index: index,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Professional Grid Movie Card
class ProfessionalGridMovieCard extends StatefulWidget {
  final dynamic movie;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int index;

  const ProfessionalGridMovieCard({
    Key? key,
    required this.movie,
    required this.focusNode,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  @override
  _ProfessionalGridMovieCardState createState() =>
      _ProfessionalGridMovieCardState();
}

class _ProfessionalGridMovieCardState extends State<ProfessionalGridMovieCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  Color _dominantColor = ProfessionalColors.accentBlue;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: AnimationTiming.slow,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: AnimationTiming.medium,
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

    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
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
    final colors = ProfessionalColors.gradientColors;
    _dominantColor = colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _glowController.dispose();
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onKey: (node, event) {
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
                      _buildMovieImage(),
                      if (_isFocused) _buildFocusBorder(),
                      _buildGradientOverlay(),
                      _buildMovieInfo(),
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

  Widget _buildMovieImage() {
    final imageUrl = widget.movie['banner']?.toString() ??
        widget.movie['poster']?.toString() ??
        '';

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildImagePlaceholder(),
              errorWidget: (context, url, error) => _buildImagePlaceholder(),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProfessionalColors.cardDark,
            ProfessionalColors.surfaceDark,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 40,
              color: ProfessionalColors.textSecondary,
            ),
            SizedBox(height: 8),
            Text(
              'No Image',
              style: TextStyle(
                color: ProfessionalColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
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

  Widget _buildMovieInfo() {
    final movieName = widget.movie['name']?.toString() ?? 'Unknown';

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
              movieName.toUpperCase(),
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _dominantColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _dominantColor.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  'HD',
                  style: TextStyle(
                    color: _dominantColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

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

// Safe Type Conversion Extension (keeping your existing one)
extension SafeTypeConversion on Map<String, dynamic> {
  String safeString(String key, [String defaultValue = '']) {
    try {
      final value = this[key];
      if (value == null) return defaultValue;
      return value.toString();
    } catch (e) {
      return defaultValue;
    }
  }

  int safeInt(String key, [int defaultValue = 0]) {
    try {
      final value = this[key];
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? defaultValue;
      }
      if (value is double) {
        return value.toInt();
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  double safeDouble(String key, [double defaultValue = 0.0]) {
    try {
      final value = this[key];
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  bool safeBool(String key, [bool defaultValue = false]) {
    try {
      final value = this[key];
      if (value == null) return defaultValue;
      if (value is bool) return value;
      if (value is String) {
        return value.toLowerCase() == 'true';
      }
      if (value is int) {
        return value == 1;
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }
}

class FullscreenYouTubePlayer extends StatefulWidget {
  final String youtubeId;

  const FullscreenYouTubePlayer({required this.youtubeId});

  @override
  _FullscreenYouTubePlayerState createState() =>
      _FullscreenYouTubePlayerState();
}

class _FullscreenYouTubePlayerState extends State<FullscreenYouTubePlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        hideControls: true, // Hide all controls
        disableDragSeek: true, // Disable seeking by dragging
        loop: false,
        enableCaption: false,
        isLive: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: false, // Hide progress indicator
          progressColors: const ProgressBarColors(
            playedColor: Colors.transparent,
            handleColor: Colors.transparent,
            bufferedColor: Colors.transparent,
            backgroundColor: Colors.transparent,
          ),
          onReady: () {
            // Enter fullscreen immediately when player is ready
            _controller.toggleFullScreenMode();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
