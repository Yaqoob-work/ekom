





// import 'dart:async';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/device_info_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/components/services/history_service.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/custom_video_player.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/custom_youtube_player.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/youtube_webview_player.dart';
// import 'package:mobi_tv_entertainment/components/widgets/models/news_item_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as https;
// import 'dart:convert';
// import 'dart:math' as math;
// import 'dart:ui';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';

// // Professional Color Palette
// class ProfessionalColorsForHomePages {
//   static const primaryDark = Color(0xFF0A0E1A);
//   static const surfaceDark = Color(0xFF1A1D29);
//   static const cardDark = Color(0xFF2A2D3A);
//   static const accentBlue = Color(0xFF3B82F6);
//   static const accentPurple = Color(0xFF8B5CF6);
//   static const accentGreen = Color(0xFF10B981);
//   static const accentRed = Color(0xFFEF4444);
//   static const accentOrange = Color(0xFFF59E0B);
//   static const accentPink = Color(0xFFEC4899);
//   static const textPrimary = Color(0xFFFFFFFF);
//   static const textSecondary = Color(0xFFB3B3B3);
//   static const focusGlow = Color(0xFF60A5FA);

//   static List<Color> gradientColors = [
//     accentBlue,
//     accentPurple,
//     accentGreen,
//     accentRed,
//     accentOrange,
//     accentPink,
//   ];
// }

// // Professional Animation Durations
// class AnimationTiming {
//   static const Duration ultraFast = Duration(milliseconds: 150);
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
//   static const Duration slow = Duration(milliseconds: 600);
//   static const Duration focus = Duration(milliseconds: 300);
//   static const Duration scroll = Duration(milliseconds: 800);
// }

// class Movie {
//   final int id;
//   final String name;
//   final String updatedAt;
//   final String description;
//   final String genres;
//   final String releaseDate;
//   final int? runtime;
//   final String? poster;
//   final String? banner;
//   final String sourceType;
//   final String movieUrl;
//   final List<Network> networks;
//   final int status;
//   final int movieOrder;

//   Movie({
//     required this.id,
//     required this.name,
//     required this.updatedAt,
//     required this.description,
//     required this.genres,
//     required this.releaseDate,
//     this.runtime,
//     this.poster,
//     this.banner,
//     required this.sourceType,
//     required this.movieUrl,
//     required this.networks,
//     required this.status,
//     required this.movieOrder,
//   });

//   factory Movie.fromJson(Map<String, dynamic> json) {
//     return Movie(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       description: json['description'] ?? '',
//       genres: json['genres']?.toString() ?? '',
//       releaseDate: json['release_date'] ?? '',
//       runtime: json['runtime'],
//       poster: json['poster'],
//       banner: json['banner'],
//       sourceType: json['source_type'] ?? '',
//       movieUrl: json['movie_url'] ?? '',
//       networks: (json['networks'] as List?)
//               ?.map((network) => Network.fromJson(network))
//               .toList() ??
//           [],
//       status: json['status'] ?? 0,
//       movieOrder: json['movie_order'] ?? 0,
//     );
//   }
// }

// class Network {
//   final int id;
//   final String name;
//   final String logo;

//   Network({
//     required this.id,
//     required this.name,
//     required this.logo,
//   });

//   factory Network.fromJson(Map<String, dynamic> json) {
//     return Network(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       logo: json['logo'] ?? '',
//     );
//   }
// }

// // 🚀 Enhanced Movie Service with only List Caching (no full data)
// class MovieService {
//   static const String _cacheKeyMoviesList = 'cached_movies_list';
//   static const String _cacheKeyMoviesListTimestamp =
//       'cached_movies_list_timestamp';

//   static const String _cacheKeyAuthKey = 'result_auth_key';

//   // Cache duration (in milliseconds) - 1 hour
//   static const int _cacheDurationMs = 60 * 60 * 1000; // 1 hour

//   /// Get movies for list view (limited to 8 items)
//   static Future<List<Movie>> getMoviesForList(
//       {bool forceRefresh = false}) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       // Check if we should use cache for list
//       if (!forceRefresh && await _shouldUseCacheForList(prefs)) {
//         print('📦 Loading movies list from cache...');
//         final cachedMovies = await _getCachedMoviesList(prefs);
//         if (cachedMovies.isNotEmpty) {
//           print(
//               '✅ Successfully loaded ${cachedMovies.length} movies from list cache');
//           _loadFreshListDataInBackground();
//           return cachedMovies;
//         }
//       }

//       // Load fresh data for list
//       print('🌐 Loading fresh movies list from API...');
//       return await _fetchFreshMoviesList(prefs);
//     } catch (e) {
//       print('❌ Error in getMoviesForList: $e');

//       // Try to return cached data as fallback
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         final cachedMovies = await _getCachedMoviesList(prefs);
//         if (cachedMovies.isNotEmpty) {
//           print('🔄 Returning cached list data as fallback');
//           return cachedMovies;
//         }
//       } catch (cacheError) {
//         print('❌ List cache fallback also failed: $cacheError');
//       }

//       throw Exception('Failed to load movies list: $e');
//     }
//   }

//   /// Check if cached list data is still valid
//   static Future<bool> _shouldUseCacheForList(SharedPreferences prefs) async {
//     return await _shouldUseCache(prefs, _cacheKeyMoviesListTimestamp, 'list');
//   }

//   /// Generic cache validation method
//   static Future<bool> _shouldUseCache(
//       SharedPreferences prefs, String timestampKey, String type) async {
//     try {
//       final timestampStr = prefs.getString(timestampKey);
//       if (timestampStr == null) return false;

//       final cachedTimestamp = int.tryParse(timestampStr);
//       if (cachedTimestamp == null) return false;

//       final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
//       final cacheAge = currentTimestamp - cachedTimestamp;

//       final isValid = cacheAge < _cacheDurationMs;

//       if (isValid) {
//         final ageMinutes = (cacheAge / (1000 * 60)).round();
//         print('📦 $type cache is valid (${ageMinutes} minutes old)');
//       } else {
//         final ageMinutes = (cacheAge / (1000 * 60)).round();
//         print('⏰ $type cache expired (${ageMinutes} minutes old)');
//       }

//       return isValid;
//     } catch (e) {
//       print('❌ Error checking $type cache validity: $e');
//       return false;
//     }
//   }

//   /// Get movies list from cache with status filtering
//   static Future<List<Movie>> _getCachedMoviesList(
//       SharedPreferences prefs) async {
//     return await _getCachedMovies(prefs, _cacheKeyMoviesList, 'list');
//   }

//   /// Generic method to get cached movies with status filtering
//   static Future<List<Movie>> _getCachedMovies(
//       SharedPreferences prefs, String cacheKey, String type) async {
//     try {
//       final cachedData = prefs.getString(cacheKey);
//       if (cachedData == null || cachedData.isEmpty) {
//         print('📦 No cached $type data found');
//         return [];
//       }

//       final List<dynamic> jsonData = json.decode(cachedData);

//       final filteredJsonData = jsonData.where((movieJson) {
//         final status = movieJson['status'] ?? 0;
//         return status == 1;
//       }).toList();

//       final movies = filteredJsonData
//           .map((json) => Movie.fromJson(json as Map<String, dynamic>))
//           .toList();

//       print(
//           '📦 Successfully loaded ${movies.length} active movies from $type cache (filtered from ${jsonData.length} total)');
//       return movies;
//     } catch (e) {
//       print('❌ Error loading cached $type movies: $e');
//       return [];
//     }
//   }

//   /// Fetch fresh movies for list (limited to 8) with status filtering
//   static Future<List<Movie>> _fetchFreshMoviesList(
//       SharedPreferences prefs) async {
//     try {
//       String authKey = prefs.getString(_cacheKeyAuthKey) ?? '';

//       final response = await https.get(
//         Uri.parse(
//             'https://dashboard.cpplayers.com/api/v2/getAllMovies?records=50'),
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'domain': 'coretechinfo.com',
//         },
//       );

//       if (response.statusCode == 200) {
//         final dynamic responseBody = json.decode(response.body);

//         List<dynamic> jsonData;
//         if (responseBody is List) {
//           jsonData = responseBody;
//         } else if (responseBody is Map && responseBody['data'] != null) {
//           jsonData = responseBody['data'] as List;
//         } else {
//           throw Exception('Unexpected API response format');
//         }

//         final filteredJsonData = jsonData.where((movieJson) {
//           final status = movieJson['status'] ?? 0;
//           return status == 1;
//         }).toList();

//         final movies = filteredJsonData
//             .map((json) => Movie.fromJson(json as Map<String, dynamic>))
//             .toList();

//         // Sort movies by movie_order
//         movies.sort((a, b) => a.movieOrder.compareTo(b.movieOrder));

//         await _cacheMoviesList(prefs, filteredJsonData);

//         print(
//             '✅ Successfully loaded ${movies.length} active movies for list from API (filtered from ${jsonData.length} total)');
//         return movies;
//       } else {
//         throw Exception(
//             'API Error: ${response.statusCode} - ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('❌ Error fetching fresh movies list: $e');
//       rethrow;
//     }
//   }

//   /// Cache movies list data
//   static Future<void> _cacheMoviesList(
//       SharedPreferences prefs, List<dynamic> moviesData) async {
//     await _cacheMovies(prefs, moviesData, _cacheKeyMoviesList,
//         _cacheKeyMoviesListTimestamp, 'list');
//   }

//   /// Generic method to cache movies data
//   static Future<void> _cacheMovies(
//       SharedPreferences prefs,
//       List<dynamic> moviesData,
//       String dataKey,
//       String timestampKey,
//       String type) async {
//     try {
//       final jsonString = json.encode(moviesData);
//       final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

//       // Save movies data and timestamp
//       await Future.wait([
//         prefs.setString(dataKey, jsonString),
//         prefs.setString(timestampKey, currentTimestamp),
//       ]);

//       print('💾 Successfully cached ${moviesData.length} $type movies');
//     } catch (e) {
//       print('❌ Error caching $type movies: $e');
//     }
//   }

//   /// Load fresh list data in background
//   static void _loadFreshListDataInBackground() {
//     Future.delayed(const Duration(milliseconds: 500), () async {
//       try {
//         print('🔄 Loading fresh list data in background...');
//         final prefs = await SharedPreferences.getInstance();
//         await _fetchFreshMoviesList(prefs);
//         print('✅ Background list refresh completed');
//       } catch (e) {
//         print('⚠️ Background list refresh failed: $e');
//       }
//     });
//   }

//   /// Clear all cached data
//   static Future<void> clearCache() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await Future.wait([
//         prefs.remove(_cacheKeyMoviesList),
//         prefs.remove(_cacheKeyMoviesListTimestamp),
//       ]);
//       print('🗑️ All movie cache cleared successfully');
//     } catch (e) {
//       print('❌ Error clearing movie cache: $e');
//     }
//   }

//   /// Get cache info for debugging
//   static Future<Map<String, dynamic>> getCacheInfo() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       // List cache info
//       final listTimestampStr = prefs.getString(_cacheKeyMoviesListTimestamp);
//       final listCachedData = prefs.getString(_cacheKeyMoviesList);

//       final currentTimestamp = DateTime.now().millisecondsSinceEpoch;

//       Map<String, dynamic> listInfo = {'hasCachedData': false};

//       // Process list cache info
//       if (listTimestampStr != null && listCachedData != null) {
//         final listCachedTimestamp = int.tryParse(listTimestampStr) ?? 0;
//         final listCacheAge = currentTimestamp - listCachedTimestamp;
//         final listCacheAgeMinutes = (listCacheAge / (1000 * 60)).round();
//         final List<dynamic> listJsonData = json.decode(listCachedData);
//         final listCacheSizeKB = (listCachedData.length / 1024).round();

//         listInfo = {
//           'hasCachedData': true,
//           'cacheAge': listCacheAgeMinutes,
//           'cachedMoviesCount': listJsonData.length,
//           'cacheSize': listCacheSizeKB,
//           'isValid': listCacheAge < _cacheDurationMs,
//         };
//       }

//       return {
//         'listCache': listInfo,
//       };
//     } catch (e) {
//       print('❌ Error getting cache info: $e');
//       return {
//         'listCache': {'hasCachedData': false, 'error': e.toString()},
//       };
//     }
//   }

//   /// Force refresh list data (bypass cache)
//   static Future<List<Movie>> forceRefreshList() async {
//     print('🔄 Force refreshing movies list data...');
//     return await getMoviesForList(forceRefresh: true);
//   }

//   /// Backward compatibility method (uses list data)
//   static Future<List<Movie>> getAllMovies({bool forceRefresh = false}) async {
//     return await getMoviesForList(forceRefresh: forceRefresh);
//   }
// }

// // Professional Movies Horizontal List Widget
// class ProfessionalMoviesHorizontalList extends StatefulWidget {
//   final Function(bool)? onFocusChange;
//   final FocusNode focusNode;
//   final String displayTitle;
//   final int navigationIndex;

//   const ProfessionalMoviesHorizontalList({
//     Key? key,
//     this.onFocusChange,
//     required this.focusNode,
//     this.displayTitle = "RECENTLY ADDED",
//     required this.navigationIndex,
//   }) : super(key: key);

//   @override
//   _ProfessionalMoviesHorizontalListState createState() =>
//       _ProfessionalMoviesHorizontalListState();
// }

// class _ProfessionalMoviesHorizontalListState
//     extends State<ProfessionalMoviesHorizontalList>
//     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
//   @override
//   bool get wantKeepAlive => true;

//   List<Movie> displayMoviesList = [];
//   int totalMoviesCount = 0;

//   bool _isLoading = true;
//   String _errorMessage = '';
//   bool _isNavigating = false;

//   // Animation Controllers
//   late AnimationController _headerAnimationController;
//   late AnimationController _listAnimationController;
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<double> _listFadeAnimation;

//   // Focus management
//   Map<String, FocusNode> movieFocusNodes = {};
//   Color _currentAccentColor = ProfessionalColorsForHomePages.accentBlue;

//   final ScrollController _scrollController = ScrollController();
//   final int _maxItemsToShow = 50;
//     bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _setupFocusProvider();
//     _fetchDisplayMovies().then((_) {
//       _setupFocusProvider();
//     });
//     ;
//   }

//   void _setupFocusProvider() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         try {
//           final focusProvider =
//               Provider.of<FocusProvider>(context, listen: false);

//           // if (widget.navigationIndex == 0) {
//           //   // focusProvider.setLiveChannelsFocusNode(widget.focusNode);
//           //   focusProvider.registerFocusNode('liveChannelLanguage', widget.focusNode);
//           //   print('✅ Live focus node specially registered');
//           // }

//           // focusProvider.requestFocus('liveChannelLanguage');

//           // focusProvider.registerGenericChannelFocus(
//           //     widget.navigationIndex, _scrollController, widget.focusNode);

//           if (displayMoviesList.isNotEmpty) {
//             final firstMovieId = displayMoviesList[0].id.toString();
//             if (movieFocusNodes.containsKey(firstMovieId)) {
// focusProvider.registerFocusNode(
//   'manageMovies', movieFocusNodes[firstMovieId]!);
//               print(
//                   '✅ Movies first focus node registered for SubVod navigation');
//             }
//           }

//           print(
//               '✅ Generic focus registered for ${widget.displayTitle} (index: ${widget.navigationIndex})');
//         } catch (e) {
//           print('❌ Focus provider setup failed: $e');
//         }
//       }
//     });
//   }

//   void _initializeAnimations() {
//     _headerAnimationController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _listAnimationController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _headerSlideAnimation = Tween<Offset>(
//       begin: const Offset(0, -1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _headerAnimationController,
//       curve: Curves.easeOutCubic,
//     ));

//     _listFadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _listAnimationController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   Future<void> _fetchDisplayMovies() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       final fetchedMovies = await MovieService.getMoviesForList();

//       if (fetchedMovies.isNotEmpty) {
//         if (mounted) {
//           setState(() {
//             totalMoviesCount = fetchedMovies.length;
//             displayMoviesList = fetchedMovies.take(_maxItemsToShow).toList();
//             _initializeMovieFocusNodes();
//             _isLoading = false;
//           });

//           _headerAnimationController.forward();
//           _listAnimationController.forward();

//           // Debug cache info
//           _debugCacheInfo();
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             _errorMessage = 'No movies found';
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
//       print('❌ Error fetching movies: $e');
//     }
//   }

//   // Debug method to show cache information
//   Future<void> _debugCacheInfo() async {
//     try {
//       final cacheInfo = await MovieService.getCacheInfo();
//       print('📊 Cache Info: $cacheInfo');
//     } catch (e) {
//       print('❌ Error getting cache info: $e');
//     }
//   }

//   Future<void> _forceRefreshMovies() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       final fetchedMovies = await MovieService.forceRefreshList();

//       if (fetchedMovies.isNotEmpty) {
//         if (mounted) {
//           setState(() {
//             totalMoviesCount = fetchedMovies.length;
//             displayMoviesList = fetchedMovies.take(_maxItemsToShow).toList();
//             _initializeMovieFocusNodes();
//             _isLoading = false;
//           });

//           _headerAnimationController.forward();
//           _listAnimationController.forward();

//           // Show success message
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text('Movies refreshed successfully'),
//               backgroundColor: ProfessionalColorsForHomePages.accentGreen,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           );
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             _errorMessage = 'No movies found after refresh';
//             _isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = 'Refresh failed: Please check connection';
//           _isLoading = false;
//         });
//       }
//       print('❌ Error force refreshing movies: $e');
//     }
//   }

//   void _initializeMovieFocusNodes() {
//     for (var node in movieFocusNodes.values) {
//       try {
//         node.removeListener(() {});
//         node.dispose();
//       } catch (e) {}
//     }
//     movieFocusNodes.clear();

//     for (var movie in displayMoviesList) {
//       try {
//         String movieId = movie.id.toString();
//         movieFocusNodes[movieId] = FocusNode()
//           ..addListener(() {
//             if (mounted && movieFocusNodes[movieId]!.hasFocus) {
//               _scrollToFocusedItem(movieId);
//             }
//           });
//       } catch (e) {
//         // Silent error handling
//       }
//     }

//     _registerMoviesFocus();
//   }

//   void _registerMoviesFocus() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && displayMoviesList.isNotEmpty) {
//         try {
//           final focusProvider =
//               Provider.of<FocusProvider>(context, listen: false);

//           final firstMovieId = displayMoviesList[0].id.toString();
//           if (movieFocusNodes.containsKey(firstMovieId)) {
// focusProvider
//                 .registerFocusNode('manageMovies', movieFocusNodes[firstMovieId]!);
//             print('✅ Movies first banner focus registered for SubVod navigation');

//             // ❗️ BADLAV 2
//             // focusProvider.requestFocus('liveChannelLanguage');
//             // focusProvider.registerGenericChannelFocus(widget.navigationIndex,
//             //     _scrollController, movieFocusNodes[firstMovieId]!);
//           }
//         } catch (e) {
//           print('❌ Focus provider registration failed: $e');
//         }
//       }
//     });
//   }

//   // void _scrollToFocusedItem(String itemId) {
//   //   if (!mounted || !_scrollController.hasClients) return;

//   //   try {
//   //     int index = displayMoviesList
//   //         .indexWhere((movie) => movie.id.toString() == itemId);

//   //     double bannerwidth = bannerwdt;

//   //     if (index != -1) {
//   //       double scrollPosition = index * bannerwidth;
//   //       _scrollController.animateTo(
//   //         scrollPosition,
//   //         duration: const Duration(milliseconds: 500),
//   //         curve: Curves.easeOut,
//   //       );
//   //     }
//   //   } catch (e) {
//   //     // Silent fail
//   //   }
//   // }



//   // ✅ बेहतर स्क्रॉलिंग के लिए यह नया मेथड डालें
// void _scrollToFocusedItem(String itemId) {
//   if (!mounted || !_scrollController.hasClients) return;

//   try {
//     // स्क्रीन की चौड़ाई पता करें
//     final screenWidth = MediaQuery.of(context).size.width;

//     // फोकस्ड आइटम का इंडेक्स ढूंढें
//     int index = displayMoviesList.indexWhere((movie) => movie.id.toString() == itemId);
//     if (index == -1) return;

//     // एक आइटम की चौड़ाई (मान लें कि bannerwdt में मार्जिन शामिल है)
//     double itemWidth = bannerwdt + 10; 
    
//     // आइटम को स्क्रीन के बीच में लाने के लिए टारगेट पोजीशन की गणना करें
//     double targetScrollPosition = (index * itemWidth) ;

//     // यह सुनिश्चित करें कि स्क्रॉल पोजीशन 0 से कम या अधिकतम सीमा से ज़्यादा न हो
//     targetScrollPosition = targetScrollPosition.clamp(
//       0.0,
//       _scrollController.position.maxScrollExtent,
//     );

//     // स्मूथ एनीमेशन के साथ स्क्रॉल करें
//     _scrollController.animateTo(
//       targetScrollPosition,
//       duration: const Duration(milliseconds: 50), // ड्यूरेशन थोड़ा कम कर सकते हैं
//       curve: Curves.easeOutCubic, // यह कर्व ज़्यादा स्मूथ है
//     );
//   } catch (e) {
//     // अगर कोई एरर आए तो चुपचाप हैंडल करें
//     print('Error scrolling to item: $e');
//   }
// }

//   Future<void> _handleMovieTap(Movie movie) async {
//     if (_isNavigating) return;
//     _isNavigating = true;

//     try {
//       print('Updating user history for: ${movie.name}');
//       int? currentUserId = SessionManager.userId;
//       final int? parsedId = movie.id;

//       await HistoryService.updateUserHistory(
//         userId: currentUserId!,
//         contentType: 1,
//         eventId: parsedId!,
//         eventTitle: movie.name,
//         url: movie.movieUrl,
//         categoryId: 0,
//       );
//     } catch (e) {
//       print("History update failed, but proceeding to play. Error: $e");
//     }

//     bool dialogShown = false;

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
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.8),
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 50,
//                       height: 50,
//                       child: const CircularProgressIndicator(
//                         strokeWidth: 3,
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           ProfessionalColorsForHomePages.accentBlue,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Loading movie...',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     }

//     try {
//       if (dialogShown) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }

//       if (movie.sourceType == 'YoutubeLive') {
//         final deviceInfo = context.read<DeviceInfoProvider>();

//         if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
//           print('isAFTSS');

//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => YoutubeWebviewPlayer(
//                 videoUrl: movie.movieUrl,
//                 name: movie.name,
//               ),
//             ),
//           );
//         } else {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => CustomYoutubePlayer(
//                 videoData: VideoData(
//                   id: movie.movieUrl,
//                   title: movie.name,
//                   youtubeUrl: movie.movieUrl,
//                   thumbnail: movie.banner ?? movie.poster ?? '',
//                   description: movie.description ?? '',
//                 ),
//                 playlist: [
//                   VideoData(
//                     id: movie.movieUrl,
//                     title: movie.name,
//                     youtubeUrl: movie.movieUrl,
//                     thumbnail: movie.banner ?? movie.poster ?? '',
//                     description: movie.description ?? '',
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//       } else {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => VideoScreen(
//               videoUrl: movie.movieUrl,
//               bannerImageUrl: movie.banner ?? movie.poster ?? '',
//               channelList: [],
//               source: 'isRecentlyAdded',
//               videoId: movie.id,
//               name: movie.name,
//               liveStatus: false,
//               updatedAt: movie.updatedAt,
//             ),
//           ),
//         );
//       }
//       print('✅ Movie played successfully: ${movie.name}');
//     } catch (e) {
//       if (dialogShown) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }

//       String errorMessage = 'Something went wrong';
//       if (e.toString().contains('network') ||
//           e.toString().contains('connection')) {
//         errorMessage = 'Network error. Please check connection';
//       } else if (e.toString().contains('format') ||
//           e.toString().contains('codec')) {
//         errorMessage = 'Video format not supported';
//       } else if (e.toString().contains('not found') ||
//           e.toString().contains('404')) {
//         errorMessage = 'Movie not found or unavailable';
//       }

//     } finally {
//       _isNavigating = false;
//     }
//   }

//   // @override
//   // void dispose() {
//   //   _navigationLockTimer?.cancel();
//   //   _headerAnimationController.dispose();
//   //   _listAnimationController.dispose();
//   //   for (var entry in movieFocusNodes.entries) {
//   //     try {
//   //       entry.value.removeListener(() {});
//   //       entry.value.dispose();
//   //     } catch (e) {}
//   //   }
//   //   movieFocusNodes.clear();

//   //   try {
//   //     _scrollController.dispose();
//   //   } catch (e) {}

//   //   _isNavigating = false;
//   //   super.dispose();
//   // }


// // ❗️ फ़ाइल: movies_screen.dart
// // ❗️ _ProfessionalMoviesHorizontalListState -> dispose

//   @override
//   void dispose() {
//     _navigationLockTimer?.cancel();
//     _headerAnimationController.dispose();
//     _listAnimationController.dispose();

//     // ❗️❗️ FIX: सभी नोड्स को dispose करें ❗️❗️
//     for (var entry in movieFocusNodes.entries) {
//       try {
//         entry.value.removeListener(() {});
//         entry.value.dispose();
//       } catch (e) {}
//     }
//     movieFocusNodes.clear();

//     try {
//       _scrollController.dispose();
//     } catch (e) {}

//     _isNavigating = false;
//     super.dispose();
//   }


//   // @override
//   // void dispose() {
//   //   _navigationLockTimer?.cancel();
//   //   _headerAnimationController.dispose();
//   //   _listAnimationController.dispose();

//   //   // ❗️ BADLAV YAHAN: Sirf un nodes ko dispose karein jo provider mein register NAHI hue
//   //   String? firstMovieId;
//   //   if (displayMoviesList.isNotEmpty) {
//   //     firstMovieId = displayMoviesList[0].id.toString();
//   //   }

//   //   for (var entry in movieFocusNodes.entries) {
//   //     // Agar node register nahi hua hai (yaani first movie nahi hai), tabhi use yahan dispose karein
//   //     if (entry.key != firstMovieId) {
//   //       try {
//   //         entry.value.removeListener(() {});
//   //         entry.value.dispose();
//   //       } catch (e) {}
//   //     }
//   //   }
//   //   movieFocusNodes.clear();

//   //   try {
//   //     _scrollController.dispose();
//   //   } catch (e) {}

//   //   _isNavigating = false;
//   //   super.dispose();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Consumer<ColorProvider>(
//       builder: (context, colorProvider, child) {
//         final bgColor = colorProvider.isItemFocused
//             ? colorProvider.dominantColor.withOpacity(0.1)
//             : ProfessionalColorsForHomePages.primaryDark;

//         return Scaffold(
//           backgroundColor: Colors.transparent,
//           body: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   bgColor,
//                   bgColor.withOpacity(0.8),
//                   ProfessionalColorsForHomePages.primaryDark,
//                 ],
//               ),
//             ),
//             child: Column(
//               children: [
//                 SizedBox(height: screenHeight * 0.02),
//                 _buildProfessionalTitle(screenWidth),
//                 SizedBox(height: screenHeight * 0.01),
//                 Expanded(child: _buildBody(screenWidth, screenHeight)),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildMovieItem(
//       Movie movie, int index, double screenWidth, double screenHeight) {
//     String movieId = movie.id.toString();

//     // movieFocusNodes.putIfAbsent(
//     //   movieId,
//     //   () => FocusNode()
//     //     ..addListener(() {
//     //       if (mounted && movieFocusNodes[movieId]!.hasFocus) {
//     //         _scrollToFocusedItem(movieId);
//     //       }
//     //     }),
//     // );

//     if (!movieFocusNodes.containsKey(movieId)) {
//       return const SizedBox.shrink();
//     }

//     return Focus(
//       focusNode: movieFocusNodes[movieId],
//       onFocusChange: (hasFocus) async {
//         if (hasFocus && mounted) {
//           try {
//             Color dominantColor = ProfessionalColorsForHomePages.gradientColors[
//                 math.Random().nextInt(ProfessionalColorsForHomePages.gradientColors.length)];

//             setState(() {
//               _currentAccentColor = dominantColor;
//             });

//             context.read<ColorProvider>().updateColor(dominantColor, true);
//             widget.onFocusChange?.call(true);
//           } catch (e) {
//             print('Focus change handling failed: $e');
//           }
//         } else if (mounted) {
//           context.read<ColorProvider>().resetColor();
//           widget.onFocusChange?.call(false);
//         }
//       },
//       // onKey: (FocusNode node, RawKeyEvent event) {
//       //   if (event is RawKeyDownEvent) {
//       //     if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//       //       if (index < displayMoviesList.length - 1) { // No "View All" button
//       //         String nextMovieId = displayMoviesList[index + 1].id.toString();
//       //         FocusScope.of(context).requestFocus(movieFocusNodes[nextMovieId]);
//       //         return KeyEventResult.handled;
//       //       }
//       //     } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//       //       if (index > 0) {
//       //         String prevMovieId = displayMoviesList[index - 1].id.toString();
//       //         FocusScope.of(context).requestFocus(movieFocusNodes[prevMovieId]);
//       //       }
//       //       return KeyEventResult.handled;
//       //     } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//       //       context.read<ColorProvider>().resetColor();
//       //       FocusScope.of(context).unfocus();
//       //       Future.delayed(const Duration(milliseconds: 50), () {
//       //         if (mounted) {
//       //           context
//       //               .read<FocusProvider>()
//       //               .requestFirstHorizontalListNetworksFocus();
//       //         }
//       //       });
//       //       return KeyEventResult.handled;
//       //     } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//       //       context.read<ColorProvider>().resetColor();
//       //       FocusScope.of(context).unfocus();
//       //       Future.delayed(const Duration(milliseconds: 50), () {
//       //         if (mounted) {
//       //           Provider.of<FocusProvider>(context, listen: false)
//       //               .requestFirstWebseriesFocus();
//       //         }
//       //       });
//       //       return KeyEventResult.handled;
//       //     } else if (event.logicalKey == LogicalKeyboardKey.select) {
//       //       _handleMovieTap(movie);
//       //       return KeyEventResult.handled;
//       //     }
//       //   }
//       //   return KeyEventResult.ignored;
//       // },


//        onKey: (FocusNode node, RawKeyEvent event) {
//       if (event is RawKeyDownEvent) {
//         final key = event.logicalKey;

//         // --- हॉरिजॉन्टल मूवमेंट (लेफ्ट/राइट) के लिए थ्रॉटलिंग ---
//         if (key == LogicalKeyboardKey.arrowRight ||
//             key == LogicalKeyboardKey.arrowLeft) {
          
//           // 1. अगर नेविगेशन लॉक्ड है, तो कुछ न करें
//           if (_isNavigationLocked) return KeyEventResult.handled;

//           // 2. नेविगेशन को लॉक करें और 300ms का टाइमर शुरू करें
//           setState(() => _isNavigationLocked = true);
//           _navigationLockTimer = Timer(const Duration(milliseconds: 600), () {
//             if (mounted) setState(() => _isNavigationLocked = false);
//           });

//           // 3. अब फोकस बदलें
//           if (key == LogicalKeyboardKey.arrowRight) {
//             if (index < displayMoviesList.length - 1) {
//               String nextMovieId = displayMoviesList[index + 1].id.toString();
//               FocusScope.of(context).requestFocus(movieFocusNodes[nextMovieId]);
//             } else {
//               // अगर लिस्ट के अंत में हैं, तो लॉक तुरंत हटा दें
//               _navigationLockTimer?.cancel();
//               if (mounted) setState(() => _isNavigationLocked = false);
//             }
//           } else if (key == LogicalKeyboardKey.arrowLeft) {
//             if (index > 0) {
//               String prevMovieId = displayMoviesList[index - 1].id.toString();
//               FocusScope.of(context).requestFocus(movieFocusNodes[prevMovieId]);
//             } else {
//               // अगर लिस्ट की शुरुआत में हैं, तो लॉक तुरंत हटा दें
//               _navigationLockTimer?.cancel();
//               if (mounted) setState(() => _isNavigationLocked = false);
//             }
//           }
//           return KeyEventResult.handled;
//         }

//         // --- बाकी कीज़ (अप/डाउन/सेलेक्ट) को तुरंत हैंडल करें ---
//         if (key == LogicalKeyboardKey.arrowUp) {
//           context.read<ColorProvider>().resetColor();
//           FocusScope.of(context).unfocus();
//           Future.delayed(const Duration(milliseconds: 50), () {
//             if (mounted) {
// context
// .read<FocusProvider>()
// .requestFocus('subVod');
//             }
//           });
//           return KeyEventResult.handled;
//         } else if (key == LogicalKeyboardKey.arrowDown) {
//           context.read<ColorProvider>().resetColor();
//           FocusScope.of(context).unfocus();
//           Future.delayed(const Duration(milliseconds: 50), () {
//             if (mounted) {
//               // Provider.of<FocusProvider>(context, listen: false)
//               //     .requestFirstWebseriesFocus();
//                                 Provider.of<FocusProvider>(context, listen: false)
//                       .requestFocus('manageWebseries');
//             }
//           });
//           return KeyEventResult.handled;
//         } else if (key == LogicalKeyboardKey.select) {
//           _handleMovieTap(movie);
//           return KeyEventResult.handled;
//         }
//       }
//       return KeyEventResult.ignored;
//     },
//       child: GestureDetector(
//         onTap: () => _handleMovieTap(movie),
//         child: ProfessionalMovieCard(
//           movie: movie,
//           focusNode: movieFocusNodes[movieId]!,
//           onTap: () => _handleMovieTap(movie),
//           onColorChange: (color) {
//             setState(() {
//               _currentAccentColor = color;
//             });
//             context.read<ColorProvider>().updateColor(color, true);
//           },
//           index: index,
//           categoryTitle: widget.displayTitle,
//         ),
//       ),
//     );
//   }

//   Widget _buildMoviesList(double screenWidth, double screenHeight) {
//     return FadeTransition(
//       opacity: _listFadeAnimation,
//       child: Container(
//         height: screenHeight * 0.38,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           clipBehavior: Clip.none,
//           cacheExtent: 9999,
//           controller: _scrollController,
//           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
//           // cacheExtent: 1200,
//           itemCount: displayMoviesList.length, // No "View All" button
//           itemBuilder: (context, index) {
//             var movie = displayMoviesList[index];
//             return _buildMovieItem(movie, index, screenWidth, screenHeight);
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalTitle(double screenWidth) {
//     return SlideTransition(
//       position: _headerSlideAnimation,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             ShaderMask(
//               shaderCallback: (bounds) => const LinearGradient(
//                 colors: [
//                   ProfessionalColorsForHomePages.accentBlue,
//                   ProfessionalColorsForHomePages.accentPurple,
//                 ],
//               ).createShader(bounds),
//               child: Text(
//                 widget.displayTitle,
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 2.0,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBody(double screenWidth, double screenHeight) {
//     if (_isLoading) {
//       return ProfessionalLoadingIndicator(
//           message: 'Loading ${widget.displayTitle}...');
//     } else if (_errorMessage.isNotEmpty) {
//       return _buildErrorWidget();
//     } else if (displayMoviesList.isEmpty) {
//       return _buildEmptyWidget();
//     } else {
//       return _buildMoviesList(screenWidth, screenHeight);
//     }
//   }

//   Widget _buildErrorWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [
//                   ProfessionalColorsForHomePages.accentRed.withOpacity(0.2),
//                   ProfessionalColorsForHomePages.accentRed.withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.error_outline_rounded,
//               size: 40,
//               color: ProfessionalColorsForHomePages.accentRed,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Oops! Something went wrong',
//             style: TextStyle(
//               color: ProfessionalColorsForHomePages.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _errorMessage,
//             style: const TextStyle(
//               color: ProfessionalColorsForHomePages.textSecondary,
//               fontSize: 14,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: _fetchDisplayMovies,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: ProfessionalColorsForHomePages.accentBlue,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               'Try Again',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [
//                   ProfessionalColorsForHomePages.accentBlue.withOpacity(0.2),
//                   ProfessionalColorsForHomePages.accentBlue.withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.movie_outlined,
//               size: 40,
//               color: ProfessionalColorsForHomePages.accentBlue,
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'loading',
//             style: TextStyle(
//               color: ProfessionalColorsForHomePages.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             '',
//             style: TextStyle(
//               color: ProfessionalColorsForHomePages.textSecondary,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Professional Movie Card
// class ProfessionalMovieCard extends StatefulWidget {
//   final Movie movie;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final Function(Color) onColorChange;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalMovieCard({
//     Key? key,
//     required this.movie,
//     required this.focusNode,
//     required this.onTap,
//     required this.onColorChange,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalMovieCardState createState() => _ProfessionalMovieCardState();
// }

// class _ProfessionalMovieCardState extends State<ProfessionalMovieCard>
//     with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _glowController;
//   late AnimationController _shimmerController;

//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;
//   late Animation<double> _shimmerAnimation;

//   Color _dominantColor = ProfessionalColorsForHomePages.accentBlue;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();

//     _scaleController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _glowController = AnimationController(
//       duration: AnimationTiming.medium,
//       vsync: this,
//     );

//     _shimmerController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat();

//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.06,
//     ).animate(CurvedAnimation(
//       parent: _scaleController,
//       curve: Curves.easeOutCubic,
//     ));

//     _glowAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _glowController,
//       curve: Curves.easeInOut,
//     ));

//     _shimmerAnimation = Tween<double>(
//       begin: -1.0,
//       end: 2.0,
//     ).animate(CurvedAnimation(
//       parent: _shimmerController,
//       curve: Curves.easeInOut,
//     ));

//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     setState(() {
//       _isFocused = widget.focusNode.hasFocus;
//     });

//     if (_isFocused) {
//       _scaleController.forward();
//       _glowController.forward();
//       _generateDominantColor();
//       widget.onColorChange(_dominantColor);
//       HapticFeedback.lightImpact();
//     } else {
//       _scaleController.reverse();
//       _glowController.reverse();
//     }
//   }

//   void _generateDominantColor() {
//     final colors = ProfessionalColorsForHomePages.gradientColors;
//     _dominantColor = colors[math.Random().nextInt(colors.length)];
//   }

//   @override
//   void dispose() {
//     _scaleController.dispose();
//     _glowController.dispose();
//     _shimmerController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return AnimatedBuilder(
//       animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: Container(
//             width: bannerwdt,
//             margin: const EdgeInsets.symmetric(horizontal: 6),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 _buildProfessionalPoster(screenWidth, screenHeight),
//                 _buildProfessionalTitle(screenWidth),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProfessionalPoster(double screenWidth, double screenHeight) {
//     final posterHeight = _isFocused ? focussedBannerhgt : bannerhgt;

//     return Container(
//       height: posterHeight,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           if (_isFocused) ...[
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.4),
//               blurRadius: 25,
//               spreadRadius: 3,
//               offset: const Offset(0, 8),
//             ),
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.2),
//               blurRadius: 45,
//               spreadRadius: 6,
//               offset: const Offset(0, 15),
//             ),
//           ] else ...[
//             BoxShadow(
//               color: Colors.black.withOpacity(0.4),
//               blurRadius: 10,
//               spreadRadius: 2,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Stack(
//           children: [
//             _buildMovieImage(screenWidth, posterHeight),
//             if (_isFocused) _buildFocusBorder(),
//             if (_isFocused) _buildShimmerEffect(),
//             _buildGenreBadge(),
//             if (_isFocused) _buildHoverOverlay(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMovieImage(double screenWidth, double posterHeight) {
//     final String uniqueImageUrl =
//         "${widget.movie.banner}?v=${widget.movie.updatedAt}";
//     final String uniqueCacheKey =
//         "${widget.movie.id.toString()}_${widget.movie.updatedAt}";
//     return Container(
//       width: double.infinity,
//       height: posterHeight,
//       child: widget.movie.banner != null && widget.movie.banner!.isNotEmpty
//           ? CachedNetworkImage(
//               imageUrl: uniqueImageUrl,
//               fit: BoxFit.cover,
//               memCacheHeight: 300,
//               cacheKey: uniqueCacheKey,
//               placeholder: (context, url) =>
//                   _buildImagePlaceholder(posterHeight),
//               errorWidget: (context, url, error) =>
//                   _buildImagePlaceholder(posterHeight),
//             )
//           : _buildImagePlaceholder(posterHeight),
//     );
//   }

//   Widget _buildImagePlaceholder(double height) {
//     return Container(
//       height: height,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             ProfessionalColorsForHomePages.cardDark,
//             ProfessionalColorsForHomePages.surfaceDark,
//           ],
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.movie_outlined,
//             size: height * 0.25,
//             color: ProfessionalColorsForHomePages.textSecondary,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             widget.categoryTitle,
//             style: TextStyle(
//               color: ProfessionalColorsForHomePages.textSecondary,
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//             decoration: BoxDecoration(
//               color: ProfessionalColorsForHomePages.accentBlue.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Text(
//               'HD',
//               style: TextStyle(
//                 color: ProfessionalColorsForHomePages.accentBlue,
//                 fontSize: 8,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFocusBorder() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             width: 3,
//             color: _dominantColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildShimmerEffect() {
//     return AnimatedBuilder(
//       animation: _shimmerAnimation,
//       builder: (context, child) {
//         return Positioned.fill(
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               gradient: LinearGradient(
//                 begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
//                 end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
//                 colors: [
//                   Colors.transparent,
//                   _dominantColor.withOpacity(0.15),
//                   Colors.transparent,
//                 ],
//                 stops: [0.0, 0.5, 1.0],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildGenreBadge() {
//     String genre = 'HD';
//     Color badgeColor = ProfessionalColorsForHomePages.accentBlue;

//     if (widget.movie.genres.toLowerCase().contains('comedy')) {
//       genre = 'COMEDY';
//       badgeColor = ProfessionalColorsForHomePages.accentGreen;
//     } else if (widget.movie.genres.toLowerCase().contains('action')) {
//       genre = 'ACTION';
//       badgeColor = ProfessionalColorsForHomePages.accentRed;
//     } else if (widget.movie.genres.toLowerCase().contains('romantic')) {
//       genre = 'ROMANCE';
//       badgeColor = ProfessionalColorsForHomePages.accentPink;
//     } else if (widget.movie.genres.toLowerCase().contains('drama')) {
//       genre = 'DRAMA';
//       badgeColor = ProfessionalColorsForHomePages.accentPurple;
//     }

//     return Positioned(
//       top: 8,
//       right: 8,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//         decoration: BoxDecoration(
//           color: badgeColor.withOpacity(0.9),
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Text(
//           genre,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 8,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHoverOverlay() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.transparent,
//               _dominantColor.withOpacity(0.1),
//             ],
//           ),
//         ),
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.7),
//               borderRadius: BorderRadius.circular(25),
//             ),
//             child: const Icon(
//               Icons.play_arrow_rounded,
//               color: Colors.white,
//               size: 30,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalTitle(double screenWidth) {
//     final movieName = widget.movie.name.toUpperCase();

//     return Container(
//       width: screenWidth * 0.18,
//       child: AnimatedDefaultTextStyle(
//         duration: AnimationTiming.medium,
//         style: TextStyle(
//           fontSize: _isFocused ? 13 : 11,
//           fontWeight: FontWeight.w600,
//           color: _isFocused ? _dominantColor : ProfessionalColorsForHomePages.textPrimary,
//           letterSpacing: 0.5,
//           shadows: _isFocused
//               ? [
//                   Shadow(
//                     color: _dominantColor.withOpacity(0.6),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : [],
//         ),
//         child: Text(
//           movieName,
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }

// // Professional Loading Indicator
// class ProfessionalLoadingIndicator extends StatefulWidget {
//   final String message;

//   const ProfessionalLoadingIndicator({
//     Key? key,
//     this.message = 'Loading...',
//   }) : super(key: key);

//   @override
//   _ProfessionalLoadingIndicatorState createState() =>
//       _ProfessionalLoadingIndicatorState();
// }

// class _ProfessionalLoadingIndicatorState
//     extends State<ProfessionalLoadingIndicator> with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat();

//     _animation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_controller);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           AnimatedBuilder(
//             animation: _animation,
//             builder: (context, child) {
//               return Container(
//                 width: 70,
//                 height: 70,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: SweepGradient(
//                     colors: [
//                       ProfessionalColorsForHomePages.accentBlue,
//                       ProfessionalColorsForHomePages.accentPurple,
//                       ProfessionalColorsForHomePages.accentGreen,
//                       ProfessionalColorsForHomePages.accentBlue,
//                     ],
//                     stops: [0.0, 0.3, 0.7, 1.0],
//                     transform: GradientRotation(_animation.value * 2 * math.pi),
//                   ),
//                 ),
//                 child: Container(
//                   margin: const EdgeInsets.all(5),
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: ProfessionalColorsForHomePages.primaryDark,
//                   ),
//                   child: const Icon(
//                     Icons.movie_rounded,
//                     color: ProfessionalColorsForHomePages.textPrimary,
//                     size: 28,
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 24),
//           Text(
//             widget.message,
//             style: const TextStyle(
//               color: ProfessionalColorsForHomePages.textPrimary,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             width: 200,
//             height: 3,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(2),
//               color: ProfessionalColorsForHomePages.surfaceDark,
//             ),
//             child: AnimatedBuilder(
//               animation: _animation,
//               builder: (context, child) {
//                 return LinearProgressIndicator(
//                   value: _animation.value,
//                   backgroundColor: Colors.transparent,
//                   valueColor: const AlwaysStoppedAnimation<Color>(
//                     ProfessionalColorsForHomePages.accentBlue,
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Main Movies Screen
// class MoviesScreen extends StatefulWidget {
//   const MoviesScreen({super.key});
//   @override
//   _MoviesScreenState createState() => _MoviesScreenState();
// }

// class _MoviesScreenState extends State<MoviesScreen> {
//   final FocusNode _moviesFocusNode = FocusNode();

//   @override
//   void dispose() {
//     // _moviesFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColorsForHomePages.primaryDark,
//       body: SafeArea(
//         child: ProfessionalMoviesHorizontalList(
//           focusNode: _moviesFocusNode,
//           displayTitle: "RECENTLY ADDED",
//           navigationIndex: 3,
//           onFocusChange: (bool hasFocus) {
//             print('Movies section focus: $hasFocus');
//           },
//         ),
//       ),
//     );
//   }
// }







// import 'dart:async';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/device_info_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/components/services/history_service.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/custom_video_player.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/custom_youtube_player.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/youtube_webview_player.dart';
// import 'package:mobi_tv_entertainment/components/widgets/models/news_item_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as https;
// import 'dart:convert';
// import 'dart:math' as math;
// import 'dart:ui';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';

// // Professional Color Palette
// class ProfessionalColorsForHomePages {
//   static const primaryDark = Color(0xFF0A0E1A);
//   static const surfaceDark = Color(0xFF1A1D29);
//   static const cardDark = Color(0xFF2A2D3A);
//   static const accentBlue = Color(0xFF3B82F6);
//   static const accentPurple = Color(0xFF8B5CF6);
//   static const accentGreen = Color(0xFF10B981);
//   static const accentRed = Color(0xFFEF4444);
//   static const accentOrange = Color(0xFFF59E0B);
//   static const accentPink = Color(0xFFEC4899);
//   static const textPrimary = Color(0xFFFFFFFF);
//   static const textSecondary = Color(0xFFB3B3B3);
//   static const focusGlow = Color(0xFF60A5FA);

//   static List<Color> gradientColors = [
//     accentBlue,
//     accentPurple,
//     accentGreen,
//     accentRed,
//     accentOrange,
//     accentPink,
//   ];
// }

// // Professional Animation Durations
// class AnimationTiming {
//   static const Duration ultraFast = Duration(milliseconds: 150);
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
//   static const Duration slow = Duration(milliseconds: 600);
//   static const Duration focus = Duration(milliseconds: 300);
//   static const Duration scroll = Duration(milliseconds: 800);
// }

// class Movie {
//   final int id;
//   final String name;
//   final String updatedAt;
//   final String description;
//   final String genres;
//   final String releaseDate;
//   final int? runtime;
//   final String? poster;
//   final String? banner;
//   final String sourceType;
//   final String movieUrl;
//   final List<Network> networks;
//   final int status;
//   final int movieOrder;

//   Movie({
//     required this.id,
//     required this.name,
//     required this.updatedAt,
//     required this.description,
//     required this.genres,
//     required this.releaseDate,
//     this.runtime,
//     this.poster,
//     this.banner,
//     required this.sourceType,
//     required this.movieUrl,
//     required this.networks,
//     required this.status,
//     required this.movieOrder,
//   });

//   factory Movie.fromJson(Map<String, dynamic> json) {
//     return Movie(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       description: json['description'] ?? '',
//       genres: json['genres']?.toString() ?? '',
//       releaseDate: json['release_date'] ?? '',
//       runtime: json['runtime'],
//       poster: json['poster'],
//       banner: json['banner'],
//       sourceType: json['source_type'] ?? '',
//       movieUrl: json['movie_url'] ?? '',
//       networks: (json['networks'] as List?)
//               ?.map((network) => Network.fromJson(network))
//               .toList() ??
//           [],
//       status: json['status'] ?? 0,
//       movieOrder: json['movie_order'] ?? 0,
//     );
//   }
// }

// class Network {
//   final int id;
//   final String name;
//   final String logo;

//   Network({
//     required this.id,
//     required this.name,
//     required this.logo,
//   });

//   factory Network.fromJson(Map<String, dynamic> json) {
//     return Network(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       logo: json['logo'] ?? '',
//     );
//   }
// }

// // 🚀 Enhanced Movie Service
// class MovieService {
//   static const String _cacheKeyMoviesList = 'cached_movies_list';
//   static const String _cacheKeyMoviesListTimestamp =
//       'cached_movies_list_timestamp';

//   static const String _cacheKeyAuthKey = 'result_auth_key';

//   // Cache duration (in milliseconds) - 1 hour
//   static const int _cacheDurationMs = 60 * 60 * 1000; // 1 hour

//   /// Get movies for list view (limited to 8 items)
//   static Future<List<Movie>> getMoviesForList(
//       {bool forceRefresh = false}) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       // Check if we should use cache for list
//       if (!forceRefresh && await _shouldUseCacheForList(prefs)) {
//         print('📦 Loading movies list from cache...');
//         final cachedMovies = await _getCachedMoviesList(prefs);
//         if (cachedMovies.isNotEmpty) {
//           print(
//               '✅ Successfully loaded ${cachedMovies.length} movies from list cache');
//           _loadFreshListDataInBackground();
//           return cachedMovies;
//         }
//       }

//       // Load fresh data for list
//       print('🌐 Loading fresh movies list from API...');
//       return await _fetchFreshMoviesList(prefs);
//     } catch (e) {
//       print('❌ Error in getMoviesForList: $e');

//       // Try to return cached data as fallback
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         final cachedMovies = await _getCachedMoviesList(prefs);
//         if (cachedMovies.isNotEmpty) {
//           print('🔄 Returning cached list data as fallback');
//           return cachedMovies;
//         }
//       } catch (cacheError) {
//         print('❌ List cache fallback also failed: $cacheError');
//       }

//       throw Exception('Failed to load movies list: $e');
//     }
//   }

//   /// Check if cached list data is still valid
//   static Future<bool> _shouldUseCacheForList(SharedPreferences prefs) async {
//     return await _shouldUseCache(prefs, _cacheKeyMoviesListTimestamp, 'list');
//   }

//   /// Generic cache validation method
//   static Future<bool> _shouldUseCache(
//       SharedPreferences prefs, String timestampKey, String type) async {
//     try {
//       final timestampStr = prefs.getString(timestampKey);
//       if (timestampStr == null) return false;

//       final cachedTimestamp = int.tryParse(timestampStr);
//       if (cachedTimestamp == null) return false;

//       final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
//       final cacheAge = currentTimestamp - cachedTimestamp;

//       final isValid = cacheAge < _cacheDurationMs;

//       if (isValid) {
//         final ageMinutes = (cacheAge / (1000 * 60)).round();
//         print('📦 $type cache is valid (${ageMinutes} minutes old)');
//       } else {
//         final ageMinutes = (cacheAge / (1000 * 60)).round();
//         print('⏰ $type cache expired (${ageMinutes} minutes old)');
//       }

//       return isValid;
//     } catch (e) {
//       print('❌ Error checking $type cache validity: $e');
//       return false;
//     }
//   }

//   /// Get movies list from cache with status filtering
//   static Future<List<Movie>> _getCachedMoviesList(
//       SharedPreferences prefs) async {
//     return await _getCachedMovies(prefs, _cacheKeyMoviesList, 'list');
//   }

//   /// Generic method to get cached movies with status filtering
//   static Future<List<Movie>> _getCachedMovies(
//       SharedPreferences prefs, String cacheKey, String type) async {
//     try {
//       final cachedData = prefs.getString(cacheKey);
//       if (cachedData == null || cachedData.isEmpty) {
//         print('📦 No cached $type data found');
//         return [];
//       }

//       final List<dynamic> jsonData = json.decode(cachedData);

//       final filteredJsonData = jsonData.where((movieJson) {
//         final status = movieJson['status'] ?? 0;
//         return status == 1;
//       }).toList();

//       final movies = filteredJsonData
//           .map((json) => Movie.fromJson(json as Map<String, dynamic>))
//           .toList();

//       print(
//           '📦 Successfully loaded ${movies.length} active movies from $type cache (filtered from ${jsonData.length} total)');
//       return movies;
//     } catch (e) {
//       print('❌ Error loading cached $type movies: $e');
//       return [];
//     }
//   }

//   /// Fetch fresh movies for list (limited to 8) with status filtering
//   static Future<List<Movie>> _fetchFreshMoviesList(
//       SharedPreferences prefs) async {
//     try {
//             String authKey = SessionManager.authKey ;
//       var url = Uri.parse(SessionManager.baseUrl + 'getAllMovies?records=50');

//       final response = await https.get(url,
//         // Uri.parse(
//         //     'https://dashboard.cpplayers.com/api/v2/getAllMovies?records=50'),
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'domain': SessionManager.savedDomain ,
//         },
//       );

//       if (response.statusCode == 200) {
//         final dynamic responseBody = json.decode(response.body);

//         List<dynamic> jsonData;
//         if (responseBody is List) {
//           jsonData = responseBody;
//         } else if (responseBody is Map && responseBody['data'] != null) {
//           jsonData = responseBody['data'] as List;
//         } else {
//           throw Exception('Unexpected API response format');
//         }

//         final filteredJsonData = jsonData.where((movieJson) {
//           final status = movieJson['status'] ?? 0;
//           return status == 1;
//         }).toList();

//         final movies = filteredJsonData
//             .map((json) => Movie.fromJson(json as Map<String, dynamic>))
//             .toList();

//         // Sort movies by movie_order
//         movies.sort((a, b) => a.movieOrder.compareTo(b.movieOrder));

//         await _cacheMoviesList(prefs, filteredJsonData);

//         print(
//             '✅ Successfully loaded ${movies.length} active movies for list from API (filtered from ${jsonData.length} total)');
//         return movies;
//       } else {
//         throw Exception(
//             'API Error: ${response.statusCode} - ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('❌ Error fetching fresh movies list: $e');
//       rethrow;
//     }
//   }

//   /// Cache movies list data
//   static Future<void> _cacheMoviesList(
//       SharedPreferences prefs, List<dynamic> moviesData) async {
//     await _cacheMovies(prefs, moviesData, _cacheKeyMoviesList,
//         _cacheKeyMoviesListTimestamp, 'list');
//   }

//   /// Generic method to cache movies data
//   static Future<void> _cacheMovies(
//       SharedPreferences prefs,
//       List<dynamic> moviesData,
//       String dataKey,
//       String timestampKey,
//       String type) async {
//     try {
//       final jsonString = json.encode(moviesData);
//       final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

//       // Save movies data and timestamp
//       await Future.wait([
//         prefs.setString(dataKey, jsonString),
//         prefs.setString(timestampKey, currentTimestamp),
//       ]);

//       print('💾 Successfully cached ${moviesData.length} $type movies');
//     } catch (e) {
//       print('❌ Error caching $type movies: $e');
//     }
//   }

//   /// Load fresh list data in background
//   static void _loadFreshListDataInBackground() {
//     Future.delayed(const Duration(milliseconds: 500), () async {
//       try {
//         print('🔄 Loading fresh list data in background...');
//         final prefs = await SharedPreferences.getInstance();
//         await _fetchFreshMoviesList(prefs);
//         print('✅ Background list refresh completed');
//       } catch (e) {
//         print('⚠️ Background list refresh failed: $e');
//       }
//     });
//   }

//   /// Clear all cached data
//   static Future<void> clearCache() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await Future.wait([
//         prefs.remove(_cacheKeyMoviesList),
//         prefs.remove(_cacheKeyMoviesListTimestamp),
//       ]);
//       print('🗑️ All movie cache cleared successfully');
//     } catch (e) {
//       print('❌ Error clearing movie cache: $e');
//     }
//   }

//   /// Get cache info for debugging
//   static Future<Map<String, dynamic>> getCacheInfo() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       // List cache info
//       final listTimestampStr = prefs.getString(_cacheKeyMoviesListTimestamp);
//       final listCachedData = prefs.getString(_cacheKeyMoviesList);

//       final currentTimestamp = DateTime.now().millisecondsSinceEpoch;

//       Map<String, dynamic> listInfo = {'hasCachedData': false};

//       // Process list cache info
//       if (listTimestampStr != null && listCachedData != null) {
//         final listCachedTimestamp = int.tryParse(listTimestampStr) ?? 0;
//         final listCacheAge = currentTimestamp - listCachedTimestamp;
//         final listCacheAgeMinutes = (listCacheAge / (1000 * 60)).round();
//         final List<dynamic> listJsonData = json.decode(listCachedData);
//         final listCacheSizeKB = (listCachedData.length / 1024).round();

//         listInfo = {
//           'hasCachedData': true,
//           'cacheAge': listCacheAgeMinutes,
//           'cachedMoviesCount': listJsonData.length,
//           'cacheSize': listCacheSizeKB,
//           'isValid': listCacheAge < _cacheDurationMs,
//         };
//       }

//       return {
//         'listCache': listInfo,
//       };
//     } catch (e) {
//       print('❌ Error getting cache info: $e');
//       return {
//         'listCache': {'hasCachedData': false, 'error': e.toString()},
//       };
//     }
//   }

//   /// Force refresh list data (bypass cache)
//   static Future<List<Movie>> forceRefreshList() async {
//     print('🔄 Force refreshing movies list data...');
//     return await getMoviesForList(forceRefresh: true);
//   }

//   /// Backward compatibility method (uses list data)
//   static Future<List<Movie>> getAllMovies({bool forceRefresh = false}) async {
//     return await getMoviesForList(forceRefresh: forceRefresh);
//   }
// }

// // Professional Movies Horizontal List Widget
// class ProfessionalMoviesHorizontalList extends StatefulWidget {
//   final Function(bool)? onFocusChange;
//   final FocusNode focusNode;
//   final String displayTitle;
//   final int navigationIndex;

//   const ProfessionalMoviesHorizontalList({
//     Key? key,
//     this.onFocusChange,
//     required this.focusNode,
//     this.displayTitle = "RECENTLY ADDED",
//     required this.navigationIndex,
//   }) : super(key: key);

//   @override
//   _ProfessionalMoviesHorizontalListState createState() =>
//       _ProfessionalMoviesHorizontalListState();
// }

// class _ProfessionalMoviesHorizontalListState
//     extends State<ProfessionalMoviesHorizontalList>
//     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
//   @override
//   bool get wantKeepAlive => true;

//   List<Movie> displayMoviesList = [];
//   int totalMoviesCount = 0;

//   bool _isLoading = true;
//   String _errorMessage = '';
//   bool _isNavigating = false;

//   // Animation Controllers
//   late AnimationController _headerAnimationController;
//   late AnimationController _listAnimationController;
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<double> _listFadeAnimation;

//   // Focus management
//   Map<String, FocusNode> movieFocusNodes = {};
//   Color _currentAccentColor = ProfessionalColorsForHomePages.accentBlue;

//   final ScrollController _scrollController = ScrollController();
//   final int _maxItemsToShow = 50;
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;

//   @override
//   void initState() {
//     super.initState();
//     SecureUrlService.refreshSettings();
//     _initializeAnimations();
//     // _setupFocusProvider(); // Call *after* fetch
//     _fetchDisplayMovies().then((_) {
//       _setupFocusProvider();
//     });
//   }

//   void _setupFocusProvider() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         try {
//           final focusProvider =
//               Provider.of<FocusProvider>(context, listen: false);

//           if (displayMoviesList.isNotEmpty) {
//             final firstMovieId = displayMoviesList[0].id.toString();
//             if (movieFocusNodes.containsKey(firstMovieId)) {
//               focusProvider.registerFocusNode(
//                   'manageMovies', movieFocusNodes[firstMovieId]!);
//               print(
//                   '✅ Movies first focus node registered for SubVod navigation');
//             }
//           }
//           print(
//               '✅ Generic focus registered for ${widget.displayTitle} (index: ${widget.navigationIndex})');
//         } catch (e) {
//           print('❌ Focus provider setup failed: $e');
//         }
//       }
//     });
//   }

//   void _initializeAnimations() {
//     _headerAnimationController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _listAnimationController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _headerSlideAnimation = Tween<Offset>(
//       begin: const Offset(0, -1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _headerAnimationController,
//       curve: Curves.easeOutCubic,
//     ));

//     _listFadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _listAnimationController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   Future<void> _fetchDisplayMovies() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       final fetchedMovies = await MovieService.getMoviesForList();

//       if (fetchedMovies.isNotEmpty) {
//         if (mounted) {
//           setState(() {
//             totalMoviesCount = fetchedMovies.length;
//             displayMoviesList = fetchedMovies.take(_maxItemsToShow).toList();
//             _initializeMovieFocusNodes();
//             _isLoading = false;
//           });

//           _headerAnimationController.forward();
//           _listAnimationController.forward();

//           _debugCacheInfo();
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             _errorMessage = 'No movies found';
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
//       print('❌ Error fetching movies: $e');
//     }
//   }

//   // Debug method to show cache information
//   Future<void> _debugCacheInfo() async {
//     try {
//       final cacheInfo = await MovieService.getCacheInfo();
//       print('📊 Cache Info: $cacheInfo');
//     } catch (e) {
//       print('❌ Error getting cache info: $e');
//     }
//   }

//   Future<void> _forceRefreshMovies() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       final fetchedMovies = await MovieService.forceRefreshList();

//       if (fetchedMovies.isNotEmpty) {
//         if (mounted) {
//           setState(() {
//             totalMoviesCount = fetchedMovies.length;
//             displayMoviesList = fetchedMovies.take(_maxItemsToShow).toList();
//             _initializeMovieFocusNodes();
//             _isLoading = false;
//           });

//           _headerAnimationController.forward();
//           _listAnimationController.forward();

//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text('Movies refreshed successfully'),
//               backgroundColor: ProfessionalColorsForHomePages.accentGreen,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           );
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             _errorMessage = 'No movies found after refresh';
//             _isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = 'Refresh failed: Please check connection';
//           _isLoading = false;
//         });
//       }
//       print('❌ Error force refreshing movies: $e');
//     }
//   }

//   void _initializeMovieFocusNodes() {
//     // Purane nodes ko saaf karein (lekin unhe dispose na karein jo register ho sakte hain)
//     // Sahi logic 'dispose' method mein hai. Yahan hum bas naye nodes banayenge.
    
//     // Pehle purane nodes ko _state_ se hata dein
//     movieFocusNodes.clear();

//     for (var movie in displayMoviesList) {
//       try {
//         String movieId = movie.id.toString();
//         movieFocusNodes[movieId] = FocusNode()
//           ..addListener(() {
//             if (mounted && movieFocusNodes[movieId]!.hasFocus) {
//               _scrollToFocusedItem(movieId);
//             }
//           });
//       } catch (e) {
//         // Silent error handling
//       }
//     }

//     _registerMoviesFocus();
//   }

//   void _registerMoviesFocus() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && displayMoviesList.isNotEmpty) {
//         try {
//           final focusProvider =
//               Provider.of<FocusProvider>(context, listen: false);

//           final firstMovieId = displayMoviesList[0].id.toString();
//           if (movieFocusNodes.containsKey(firstMovieId)) {
//             focusProvider
//                 .registerFocusNode('manageMovies', movieFocusNodes[firstMovieId]!);
//             print('✅ Movies first banner focus registered for SubVod navigation');
//           }
//         } catch (e) {
//           print('❌ Focus provider registration failed: $e');
//         }
//       }
//     });
//   }

//   void _scrollToFocusedItem(String itemId) {
//     if (!mounted || !_scrollController.hasClients) return;

//     try {
//       final screenWidth = MediaQuery.of(context).size.width;
//       int index = displayMoviesList.indexWhere((movie) => movie.id.toString() == itemId);
//       if (index == -1) return;

//       double itemWidth = bannerwdt + 12; // item width + margin (6+6)
      
//       double targetScrollPosition = (index * itemWidth) ;

//       targetScrollPosition = targetScrollPosition.clamp(
//         0.0,
//         _scrollController.position.maxScrollExtent,
//       );

//       _scrollController.animateTo(
//         targetScrollPosition,
//         duration: AnimationTiming.scroll, // Use constant
//         curve: Curves.easeOutCubic, 
//       );
//     } catch (e) {
//       print('Error scrolling to item: $e');
//     }
//   }

//   Future<void> _handleMovieTap(Movie movie) async {
//     if (_isNavigating) return;
//     _isNavigating = true;

//     try {
//       print('Updating user history for: ${movie.name}');
//       int? currentUserId = SessionManager.userId;
//       final int? parsedId = movie.id;

//       await HistoryService.updateUserHistory(
//         userId: currentUserId!,
//         contentType: 1,
//         eventId: parsedId!,
//         eventTitle: movie.name,
//         url: movie.movieUrl,
//         categoryId: 0,
//       );
//     } catch (e) {
//       print("History update failed, but proceeding to play. Error: $e");
//     }

//     bool dialogShown = false;

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
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.8),
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 50,
//                       height: 50,
//                       child: const CircularProgressIndicator(
//                         strokeWidth: 3,
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           ProfessionalColorsForHomePages.accentBlue,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Loading movie...',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     }

//     try {
//       if (dialogShown) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }

//             String rawUrl = movie.movieUrl;
//       // String rawUrl = await SecureUrlService.getSecureUrl(rawUrl);

//       if (movie.sourceType == 'YoutubeLive') {
//         final deviceInfo = context.read<DeviceInfoProvider>();

//         if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
//           print('isAFTSS');

//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => YoutubeWebviewPlayer(
//                 videoUrl: rawUrl,
//                 name: movie.name,
//               ),
//             ),
//           );
//         } else {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => CustomYoutubePlayer(
//                 videoData: VideoData(
//                   id: rawUrl,
//                   title: movie.name,
//                   youtubeUrl: rawUrl,
//                   thumbnail: movie.banner ?? movie.poster ?? '',
//                   description: movie.description ?? '',
//                 ),
//                 playlist: [
//                   VideoData(
//                     id: rawUrl,
//                     title: movie.name,
//                     youtubeUrl: rawUrl,
//                     thumbnail: movie.banner ?? movie.poster ?? '',
//                     description: movie.description ?? '',
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//       } else {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => VideoScreen(
//               videoUrl: rawUrl,
//               bannerImageUrl: movie.banner ?? movie.poster ?? '',
//               channelList: [],
//               source: 'isRecentlyAdded',
//               videoId: movie.id,
//               name: movie.name,
//               liveStatus: false,
//               updatedAt: movie.updatedAt,
//             ),
//           ),
//         );
//       }
//       print('✅ Movie played successfully: ${movie.name}');
//     } catch (e) {
//       if (dialogShown) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }

//       String errorMessage = 'Something went wrong';
//       if (e.toString().contains('network') ||
//           e.toString().contains('connection')) {
//         errorMessage = 'Network error. Please check connection';
//       } else if (e.toString().contains('format') ||
//           e.toString().contains('codec')) {
//         errorMessage = 'Video format not supported';
//       } else if (e.toString().contains('not found') ||
//           e.toString().contains('404')) {
//         errorMessage = 'Movie not found or unavailable';
//       }
//     } finally {
//       _isNavigating = false;
//     }
//   }

//   // ✅ [UPDATED] Sahi dispose logic
//   @override
//   void dispose() {
//     _navigationLockTimer?.cancel();
//     _headerAnimationController.dispose();
//     _listAnimationController.dispose();

//     // Sirf un nodes ko dispose karein jo provider mein register NAHI hue
//     String? firstMovieId;
//     if (displayMoviesList.isNotEmpty) {
//       firstMovieId = displayMoviesList[0].id.toString();
//     }

//     for (var entry in movieFocusNodes.entries) {
//       // Agar node register nahi hua hai (yaani first movie nahi hai), tabhi use yahan dispose karein
//       if (entry.key != firstMovieId) {
//         try {
//           entry.value.removeListener(() {});
//           entry.value.dispose();
//         } catch (e) {}
//       }
//     }
//     movieFocusNodes.clear();

//     try {
//       _scrollController.dispose();
//     } catch (e) {}

//     _isNavigating = false;
//     super.dispose();
//   }


//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Consumer<ColorProvider>(
//       builder: (context, colorProvider, child) {
//         final bgColor = colorProvider.isItemFocused
//             ? colorProvider.dominantColor.withOpacity(0.1)
//             : ProfessionalColorsForHomePages.primaryDark;

//         return Scaffold(
//           backgroundColor: Colors.transparent,
//           body: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   // bgColor,
//                   // bgColor.withOpacity(0.8),
//                   // ProfessionalColorsForHomePages.primaryDark,
//                   Colors.white,
//                   Colors.white,
//                 ],
//               ),
//             ),
//             child: Column(
//               children: [
//                 SizedBox(height: screenHeight * 0.02),
//                 _buildProfessionalTitle(screenWidth),
//                 SizedBox(height: screenHeight * 0.01),
//                 Expanded(child: _buildBody(screenWidth, screenHeight)),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildMovieItem(
//       Movie movie, int index, double screenWidth, double screenHeight) {
//     String movieId = movie.id.toString();

//     if (!movieFocusNodes.containsKey(movieId)) {
//       return const SizedBox.shrink();
//     }

//     return Focus(
//       focusNode: movieFocusNodes[movieId],
//       onFocusChange: (hasFocus) async {
//         if (hasFocus && mounted) {
//           try {
//             // Color dominantColor = ProfessionalColorsForHomePages.gradientColors[
//             //     math.Random().nextInt(ProfessionalColorsForHomePages.gradientColors.length)];

//             Color dominantColor = ProfessionalColorsForHomePages.accentBlue;

//             setState(() {
//               _currentAccentColor = dominantColor;
//             });

//             context.read<ColorProvider>().updateColor(dominantColor, true);
//             widget.onFocusChange?.call(true);
//           } catch (e) {
//             print('Focus change handling failed: $e');
//           }
//         } else if (mounted) {
//           context.read<ColorProvider>().resetColor();
//           widget.onFocusChange?.call(false);
//         }
//       },
//     // ✅ ==========================================================
//     // ✅ [UPDATED] onKey LOGIC
//     // ✅ ==========================================================
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           final key = event.logicalKey;

//           // --- हॉरिजॉन्टल मूवमेंट (लेफ्ट/राइट) के लिए थ्रॉटलिंग ---
//           if (key == LogicalKeyboardKey.arrowRight ||
//               key == LogicalKeyboardKey.arrowLeft) {
            
//             if (_isNavigationLocked) return KeyEventResult.handled;

//             setState(() => _isNavigationLocked = true);
//             _navigationLockTimer = Timer(const Duration(milliseconds: 600), () {
//               if (mounted) setState(() => _isNavigationLocked = false);
//             });

//             if (key == LogicalKeyboardKey.arrowRight) {
//               if (index < displayMoviesList.length - 1) {
//                 String nextMovieId = displayMoviesList[index + 1].id.toString();
//                 FocusScope.of(context).requestFocus(movieFocusNodes[nextMovieId]);
//               } else {
//                 _navigationLockTimer?.cancel();
//                 if (mounted) setState(() => _isNavigationLocked = false);
//               }
//             } else if (key == LogicalKeyboardKey.arrowLeft) {
//               if (index > 0) {
//                 String prevMovieId = displayMoviesList[index - 1].id.toString();
//                 FocusScope.of(context).requestFocus(movieFocusNodes[prevMovieId]);
//               } else {
//                 _navigationLockTimer?.cancel();
//                 if (mounted) setState(() => _isNavigationLocked = false);
//               }
//             }
//             return KeyEventResult.handled;
//           }

//           // --- वर्टिकल मूवमेंट (अप/डाउन) ---
//           if (key == LogicalKeyboardKey.arrowUp) {
//             context.read<ColorProvider>().resetColor();
//             // Naya method call karein
//             context.read<FocusProvider>().focusPreviousRow();
//             return KeyEventResult.handled;

//           } else if (key == LogicalKeyboardKey.arrowDown) {
//             context.read<ColorProvider>().resetColor();
//             // Naya method call karein
//             context.read<FocusProvider>().focusNextRow();
//             return KeyEventResult.handled;

//           } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//             _handleMovieTap(movie);
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//     // ✅ ==========================================================
//     // ✅ END OF [UPDATED] onKey LOGIC
//     // ✅ ==========================================================
//       child: GestureDetector(
//         onTap: () => _handleMovieTap(movie),
//         child: ProfessionalMovieCard(
//           movie: movie,
//           focusNode: movieFocusNodes[movieId]!,
//           onTap: () => _handleMovieTap(movie),
//           onColorChange: (color) {
//             setState(() {
//               _currentAccentColor = color;
//             });
//             context.read<ColorProvider>().updateColor(color, true);
//           },
//           index: index,
//           categoryTitle: widget.displayTitle,
//         ),
//       ),
//     );
//   }

//   Widget _buildMoviesList(double screenWidth, double screenHeight) {
//     return FadeTransition(
//       opacity: _listFadeAnimation,
//       child: Container(
//         height: screenHeight * 0.38,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           clipBehavior: Clip.none,
//           cacheExtent: 9999,
//           controller: _scrollController,
//           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
//           itemCount: displayMoviesList.length, 
//           itemBuilder: (context, index) {
//             var movie = displayMoviesList[index];
//             return _buildMovieItem(movie, index, screenWidth, screenHeight);
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalTitle(double screenWidth) {
//     return SlideTransition(
//       position: _headerSlideAnimation,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             ShaderMask(
//               shaderCallback: (bounds) => const LinearGradient(
//                 colors: [
//                   ProfessionalColorsForHomePages.accentBlue,
//                   ProfessionalColorsForHomePages.accentPurple,
//                 ],
//               ).createShader(bounds),
//               child: Text(
//                 widget.displayTitle,
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 2.0,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBody(double screenWidth, double screenHeight) {
//     if (_isLoading) {
//       return ProfessionalLoadingIndicator(
//           message: 'Loading ${widget.displayTitle}...');
//     } else if (_errorMessage.isNotEmpty) {
//       return _buildErrorWidget();
//     } else if (displayMoviesList.isEmpty) {
//       return _buildEmptyWidget();
//     } else {
//       return _buildMoviesList(screenWidth, screenHeight);
//     }
//   }

//   Widget _buildErrorWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [
//                   ProfessionalColorsForHomePages.accentRed.withOpacity(0.2),
//                   ProfessionalColorsForHomePages.accentRed.withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.error_outline_rounded,
//               size: 40,
//               color: ProfessionalColorsForHomePages.accentRed,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Oops! Something went wrong',
//             style: TextStyle(
//               color: ProfessionalColorsForHomePages.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _errorMessage,
//             style: const TextStyle(
//               color: ProfessionalColorsForHomePages.textSecondary,
//               fontSize: 14,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: _fetchDisplayMovies,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: ProfessionalColorsForHomePages.accentBlue,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               'Try Again',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [
//                   ProfessionalColorsForHomePages.accentBlue.withOpacity(0.2),
//                   ProfessionalColorsForHomePages.accentBlue.withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.movie_outlined,
//               size: 40,
//               color: ProfessionalColorsForHomePages.accentBlue,
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'loading', // Yeh 'No Movies Found' hona chahiye
//             style: TextStyle(
//               color: ProfessionalColorsForHomePages.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             '', // Yahan 'Please check back later'
//             style: TextStyle(
//               color: ProfessionalColorsForHomePages.textSecondary,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ✅ ==========================================================
// // SUPPORTING WIDGETS (ProfessionalMovieCard, ProfessionalLoadingIndicator)
// // In widgets mein koi badlav nahi hai, isliye main inhein dobara paste nahi kar raha hoon.
// // ... (Aapka baaki ka code... ProfessionalMovieCard... ProfessionalLoadingIndicator... etc.)
// // ...
// // ...
// // ✅ ==========================================================


// // Professional Movie Card
// class ProfessionalMovieCard extends StatefulWidget {
//   final Movie movie;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final Function(Color) onColorChange;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalMovieCard({
//     Key? key,
//     required this.movie,
//     required this.focusNode,
//     required this.onTap,
//     required this.onColorChange,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalMovieCardState createState() => _ProfessionalMovieCardState();
// }

// class _ProfessionalMovieCardState extends State<ProfessionalMovieCard>
//     with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _glowController;
//   late AnimationController _shimmerController;

//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;
//   late Animation<double> _shimmerAnimation;

//   Color _dominantColor = ProfessionalColorsForHomePages.accentBlue;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();

//     _scaleController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _glowController = AnimationController(
//       duration: AnimationTiming.medium,
//       vsync: this,
//     );

//     _shimmerController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat();

//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.06,
//     ).animate(CurvedAnimation(
//       parent: _scaleController,
//       curve: Curves.easeOutCubic,
//     ));

//     _glowAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _glowController,
//       curve: Curves.easeInOut,
//     ));

//     _shimmerAnimation = Tween<double>(
//       begin: -1.0,
//       end: 2.0,
//     ).animate(CurvedAnimation(
//       parent: _shimmerController,
//       curve: Curves.easeInOut,
//     ));

//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     setState(() {
//       _isFocused = widget.focusNode.hasFocus;
//     });

//     if (_isFocused) {
//       _scaleController.forward();
//       _glowController.forward();
//       _generateDominantColor();
//       widget.onColorChange(_dominantColor);
//       HapticFeedback.lightImpact();
//     } else {
//       _scaleController.reverse();
//       _glowController.reverse();
//     }
//   }

//   void _generateDominantColor() {
//     // final colors = ProfessionalColorsForHomePages.gradientColors;
//     // _dominantColor = colors[math.Random().nextInt(colors.length)];
//     _dominantColor = ProfessionalColorsForHomePages.accentBlue;
//   }

//   @override
//   void dispose() {
//     _scaleController.dispose();
//     _glowController.dispose();
//     _shimmerController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return AnimatedBuilder(
//       animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: Container(
//             width: bannerwdt,
//             margin: const EdgeInsets.symmetric(horizontal: 6),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 _buildProfessionalPoster(screenWidth, screenHeight),
//                 _buildProfessionalTitle(screenWidth),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProfessionalPoster(double screenWidth, double screenHeight) {
//     final posterHeight = _isFocused ? focussedBannerhgt : bannerhgt;

//     return Container(
//       height: posterHeight,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           if (_isFocused) ...[
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.4),
//               blurRadius: 25,
//               spreadRadius: 3,
//               offset: const Offset(0, 8),
//             ),
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.2),
//               blurRadius: 45,
//               spreadRadius: 6,
//               offset: const Offset(0, 15),
//             ),
//           ] else ...[
//             BoxShadow(
//               color: Colors.black.withOpacity(0.4),
//               blurRadius: 10,
//               spreadRadius: 2,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Stack(
//           children: [
//             _buildMovieImage(screenWidth, posterHeight),
//             if (_isFocused) _buildFocusBorder(),
//             if (_isFocused) _buildShimmerEffect(),
//             _buildGenreBadge(),
//             if (_isFocused) _buildHoverOverlay(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMovieImage(double screenWidth, double posterHeight) {
//     final String uniqueImageUrl =
//         "${widget.movie.banner}?v=${widget.movie.updatedAt}";
//     final String uniqueCacheKey =
//         "${widget.movie.id.toString()}_${widget.movie.updatedAt}";
//     return Container(
//       width: double.infinity,
//       height: posterHeight,
//       child: widget.movie.banner != null && widget.movie.banner!.isNotEmpty
//           ? CachedNetworkImage(
//               imageUrl: uniqueImageUrl,
//               fit: BoxFit.cover,
//               memCacheHeight: 300,
//               cacheKey: uniqueCacheKey,
//               placeholder: (context, url) =>
//                   _buildImagePlaceholder(posterHeight),
//               errorWidget: (context, url, error) =>
//                   _buildImagePlaceholder(posterHeight),
//             )
//           : _buildImagePlaceholder(posterHeight),
//     );
//   }

//   Widget _buildImagePlaceholder(double height) {
//     return Container(
//       height: height,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             ProfessionalColorsForHomePages.cardDark,
//             ProfessionalColorsForHomePages.surfaceDark,
//           ],
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.movie_outlined,
//             size: height * 0.25,
//             color: ProfessionalColorsForHomePages.textSecondary,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             widget.categoryTitle,
//             style: TextStyle(
//               color: ProfessionalColorsForHomePages.textSecondary,
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//             decoration: BoxDecoration(
//               color: ProfessionalColorsForHomePages.accentBlue.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Text(
//               'HD',
//               style: TextStyle(
//                 color: ProfessionalColorsForHomePages.accentBlue,
//                 fontSize: 8,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFocusBorder() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             width: 3,
//             color: _dominantColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildShimmerEffect() {
//     return AnimatedBuilder(
//       animation: _shimmerAnimation,
//       builder: (context, child) {
//         return Positioned.fill(
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               gradient: LinearGradient(
//                 begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
//                 end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
//                 colors: [
//                   Colors.transparent,
//                   _dominantColor.withOpacity(0.15),
//                   Colors.transparent,
//                 ],
//                 stops: [0.0, 0.5, 1.0],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildGenreBadge() {
//     String genre = 'HD';
//     Color badgeColor = ProfessionalColorsForHomePages.accentBlue;

//     if (widget.movie.genres.toLowerCase().contains('comedy')) {
//       genre = 'COMEDY';
//       badgeColor = ProfessionalColorsForHomePages.accentGreen;
//     } else if (widget.movie.genres.toLowerCase().contains('action')) {
//       genre = 'ACTION';
//       badgeColor = ProfessionalColorsForHomePages.accentRed;
//     } else if (widget.movie.genres.toLowerCase().contains('romantic')) {
//       genre = 'ROMANCE';
//       badgeColor = ProfessionalColorsForHomePages.accentPink;
//     } else if (widget.movie.genres.toLowerCase().contains('drama')) {
//       genre = 'DRAMA';
//       badgeColor = ProfessionalColorsForHomePages.accentPurple;
//     }

//     return Positioned(
//       top: 8,
//       right: 8,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//         decoration: BoxDecoration(
//           color: badgeColor.withOpacity(0.9),
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Text(
//           genre,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 8,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHoverOverlay() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.transparent,
//               _dominantColor.withOpacity(0.1),
//             ],
//           ),
//         ),
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.7),
//               borderRadius: BorderRadius.circular(25),
//             ),
//             child: const Icon(
//               Icons.play_arrow_rounded,
//               color: Colors.white,
//               size: 30,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalTitle(double screenWidth) {
//     final movieName = widget.movie.name.toUpperCase();

//     return Container(
//       width: screenWidth * 0.18,
//       child: AnimatedDefaultTextStyle(
//         duration: AnimationTiming.medium,
//         style: TextStyle(
//           fontSize: _isFocused ? 13 : 11,
//           fontWeight: FontWeight.w600,
//           color: _isFocused ? _dominantColor : ProfessionalColorsForHomePages.primaryDark,
//           letterSpacing: 0.5,
//           shadows: _isFocused
//               ? [
//                   Shadow(
//                     color: _dominantColor.withOpacity(0.6),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : [],
//         ),
//         child: Text(
//           movieName,
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }

// // Professional Loading Indicator
// class ProfessionalLoadingIndicator extends StatefulWidget {
//   final String message;

//   const ProfessionalLoadingIndicator({
//     Key? key,
//     this.message = 'Loading...',
//   }) : super(key: key);

//   @override
//   _ProfessionalLoadingIndicatorState createState() =>
//       _ProfessionalLoadingIndicatorState();
// }

// class _ProfessionalLoadingIndicatorState
//     extends State<ProfessionalLoadingIndicator> with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat();

//     _animation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_controller);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           AnimatedBuilder(
//             animation: _animation,
//             builder: (context, child) {
//               return Container(
//                 width: 70,
//                 height: 70,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: SweepGradient(
//                     colors: [
//                       ProfessionalColorsForHomePages.accentBlue,
//                       ProfessionalColorsForHomePages.accentPurple,
//                       ProfessionalColorsForHomePages.accentGreen,
//                       ProfessionalColorsForHomePages.accentBlue,
//                     ],
//                     stops: [0.0, 0.3, 0.7, 1.0],
//                     transform: GradientRotation(_animation.value * 2 * math.pi),
//                   ),
//                 ),
//                 child: Container(
//                   margin: const EdgeInsets.all(5),
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: ProfessionalColorsForHomePages.primaryDark,
//                   ),
//                   child: const Icon(
//                     Icons.movie_rounded,
//                     color: ProfessionalColorsForHomePages.textPrimary,
//                     size: 28,
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 24),
//           Text(
//             widget.message,
//             style: const TextStyle(
//               color: ProfessionalColorsForHomePages.textPrimary,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             width: 200,
//             height: 3,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(2),
//               color: ProfessionalColorsForHomePages.surfaceDark,
//             ),
//             child: AnimatedBuilder(
//               animation: _animation,
//               builder: (context, child) {
//                 return LinearProgressIndicator(
//                   value: _animation.value,
//                   backgroundColor: Colors.transparent,
//                   valueColor: const AlwaysStoppedAnimation<Color>(
//                     ProfessionalColorsForHomePages.accentBlue,
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Main Movies Screen
// class MoviesScreen extends StatefulWidget {
//   const MoviesScreen({super.key});
//   @override
//   _MoviesScreenState createState() => _MoviesScreenState();
// }

// class _MoviesScreenState extends State<MoviesScreen> {
//   final FocusNode _moviesFocusNode = FocusNode();

//   @override
//   void dispose() {
//     _moviesFocusNode.dispose(); // Yeh node yahan dispose ho sakta hai
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColorsForHomePages.primaryDark,
//       body: SafeArea(
//         child: ProfessionalMoviesHorizontalList(
//           focusNode: _moviesFocusNode,
//           displayTitle: "RECENTLY ADDED",
//           navigationIndex: 3,
//           onFocusChange: (bool hasFocus) {
//             print('Movies section focus: $hasFocus');
//           },
//         ),
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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_loading_widget.dart';
import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_retry_widget.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';
import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/components/services/professional_colors_for_home_pages.dart';
// ✅ Import Smart Widgets (Ensure this file exists as created previously)
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ ==========================================================
// MODELS & HELPERS
// ==========================================================

class AnimationTiming {
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration scroll = Duration(milliseconds: 800);
}

class Movie {
  final int id;
  final String name;
  final String updatedAt;
  final String description;
  final String genres;
  final String releaseDate;
  final int? runtime;
  final String? poster;
  final String? banner;
  final String sourceType;
  final String movieUrl;
  final List<Network> networks;
  final int status;
  final int movieOrder;

  Movie({
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.description,
    required this.genres,
    required this.releaseDate,
    this.runtime,
    this.poster,
    this.banner,
    required this.sourceType,
    required this.movieUrl,
    required this.networks,
    required this.status,
    required this.movieOrder,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      description: json['description'] ?? '',
      genres: json['genres']?.toString() ?? '',
      releaseDate: json['release_date'] ?? '',
      runtime: json['runtime'],
      poster: json['poster'],
      banner: json['banner'],
      sourceType: json['source_type'] ?? '',
      movieUrl: json['movie_url'] ?? '',
      networks: (json['networks'] as List?)
              ?.map((network) => Network.fromJson(network))
              .toList() ??
          [],
      status: json['status'] ?? 0,
      movieOrder: json['movie_order'] ?? 0,
    );
  }
}

class Network {
  final int id;
  final String name;
  final String logo;

  Network({required this.id, required this.name, required this.logo});

  factory Network.fromJson(Map<String, dynamic> json) {
    return Network(id: json['id'] ?? 0, name: json['name'] ?? '', logo: json['logo'] ?? '');
  }
}

// Image Helpers
Widget displayImage(String imageUrl, {double? width, double? height, BoxFit fit = BoxFit.fill}) {
  if (imageUrl.isEmpty || imageUrl == 'localImage' || imageUrl.contains('localhost')) return _buildImgError(width, height);
  if (imageUrl.startsWith('data:image')) {
    try {
      Uint8List imageBytes = base64Decode(imageUrl.split(',').last);
      return Image.memory(imageBytes, fit: fit, width: width, height: height, errorBuilder: (c, e, s) => _buildImgError(width, height));
    } catch (e) { return _buildImgError(width, height); }
  } else if (imageUrl.startsWith('http')) {
    if (imageUrl.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(imageUrl, width: width, height: height, fit: fit, placeholderBuilder: (c) => _buildImgLoader(width, height));
    } else {
      return Image.network(imageUrl, width: width, height: height, fit: fit, headers: const {'User-Agent': 'Flutter App'}, loadingBuilder: (c, child, progress) => progress == null ? child : _buildImgLoader(width, height), errorBuilder: (c, e, s) => _buildImgError(width, height));
    }
  } else { return _buildImgError(width, height); }
}
Widget _buildImgLoader(double? width, double? height) => SizedBox(width: width, height: height, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))));
Widget _buildImgError(double? width, double? height) => Container(width: width, height: height, decoration: const BoxDecoration(gradient: LinearGradient(colors: [ProfessionalColorsForHomePages.accentGreen, ProfessionalColorsForHomePages.accentBlue])), child: const Icon(Icons.broken_image, color: Colors.white, size: 24));


// ✅ ==========================================================
// MOVIE SERVICE
// ==========================================================
class MovieService {
  static const String _cacheKeyMoviesList = 'cached_movies_list';
  static const String _cacheKeyMoviesListTimestamp = 'cached_movies_list_timestamp';
  static const int _cacheDurationMs = 60 * 60 * 1000; 

  static Future<List<Movie>> getMoviesForList({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!forceRefresh && await _shouldUseCache(prefs, _cacheKeyMoviesListTimestamp)) {
      final cachedMovies = await _getCachedMovies(prefs, _cacheKeyMoviesList);
      if (cachedMovies.isNotEmpty) {
        _loadFreshListDataInBackground();
        return cachedMovies;
      }
    }
    return await _fetchFreshMoviesList(prefs);
  }

  static Future<bool> _shouldUseCache(SharedPreferences prefs, String timestampKey) async {
    final timestampStr = prefs.getString(timestampKey);
    if (timestampStr == null) return false;
    final cachedTimestamp = int.tryParse(timestampStr);
    if (cachedTimestamp == null) return false;
    return DateTime.now().millisecondsSinceEpoch - cachedTimestamp < _cacheDurationMs;
  }

  static Future<List<Movie>> _getCachedMovies(SharedPreferences prefs, String cacheKey) async {
    final cachedData = prefs.getString(cacheKey);
    if (cachedData == null || cachedData.isEmpty) return [];
    try {
      final List<dynamic> jsonData = json.decode(cachedData);
      return jsonData.where((m) => (m['status'] ?? 0) == 1).map((json) => Movie.fromJson(json)).toList();
    } catch (e) { return []; }
  }

  static Future<List<Movie>> _fetchFreshMoviesList(SharedPreferences prefs) async {
    try {
      String authKey = SessionManager.authKey;
      var url = Uri.parse(SessionManager.baseUrl + 'getAllMovies?records=50');
      final response = await https.get(url, headers: {'auth-key': authKey, 'Content-Type': 'application/json', 'domain': SessionManager.savedDomain});

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);
        List<dynamic> jsonData = (responseBody is List) ? responseBody : (responseBody['data'] as List);
        
        final filteredData = jsonData.where((m) => (m['status'] ?? 0) == 1).toList();
        final movies = filteredData.map((json) => Movie.fromJson(json)).toList();
        movies.sort((a, b) => a.movieOrder.compareTo(b.movieOrder));
        
        await _cacheMovies(prefs, filteredData, _cacheKeyMoviesList, _cacheKeyMoviesListTimestamp);
        return movies;
      } else { throw Exception('API Error: ${response.statusCode}'); }
    } catch (e) { rethrow; }
  }

  static Future<void> _cacheMovies(SharedPreferences prefs, List<dynamic> data, String dataKey, String timeKey) async {
    await prefs.setString(dataKey, json.encode(data));
    await prefs.setString(timeKey, DateTime.now().millisecondsSinceEpoch.toString());
  }

  static void _loadFreshListDataInBackground() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      try { final prefs = await SharedPreferences.getInstance(); await _fetchFreshMoviesList(prefs); } catch (e) {}
    });
  }
}

// ✅ ==========================================================
// MAIN WIDGET: MoviesHorizontalList
// ==========================================================
class ProfessionalMoviesHorizontalList extends StatefulWidget {
  final Function(bool)? onFocusChange;
  final FocusNode focusNode;
  final String displayTitle;
  final int navigationIndex;

  const ProfessionalMoviesHorizontalList({
    Key? key,
    this.onFocusChange,
    required this.focusNode,
    this.displayTitle = "RECENTLY ADDED",
    required this.navigationIndex,
  }) : super(key: key);

  @override
  _ProfessionalMoviesHorizontalListState createState() => _ProfessionalMoviesHorizontalListState();
}
class _ProfessionalMoviesHorizontalListState
    extends State<ProfessionalMoviesHorizontalList>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  List<Movie> displayMoviesList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isNavigating = false;
  
  // ✅ Shadow State
  bool _isSectionFocused = false;

  // ✅ FIXED: Defined missing variable
  Color _currentAccentColor = ProfessionalColorsForHomePages.accentBlue;

  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;

  Map<String, FocusNode> movieFocusNodes = {};
  
  // ✅ Retry Focus Node
  final FocusNode _retryFocusNode = FocusNode();
  
  final ScrollController _scrollController = ScrollController();
  final int _maxItemsToShow = 50;
  bool _isNavigationLocked = false;
  Timer? _navigationLockTimer;

  @override
  void initState() {
    super.initState();
    SecureUrlService.refreshSettings();
    _initializeAnimations();
    _fetchDisplayMovies();
  }

  @override
  void dispose() {
    _navigationLockTimer?.cancel();
    _headerAnimationController.dispose();
    _listAnimationController.dispose();
    _retryFocusNode.dispose();
    _cleanupFocusNodes();
    _scrollController.dispose();
    _isNavigating = false;
    super.dispose();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(duration: AnimationTiming.slow, vsync: this);
    _listAnimationController = AnimationController(duration: AnimationTiming.slow, vsync: this);
    
    _headerSlideAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOutCubic));
    
    _listFadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _listAnimationController, curve: Curves.easeInOut));
  }

  Future<void> _fetchDisplayMovies() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      final fetchedMovies = await MovieService.getMoviesForList();
      if (fetchedMovies.isNotEmpty) {
        if (mounted) {
          setState(() {
            displayMoviesList = fetchedMovies.take(_maxItemsToShow).toList();
            _isLoading = false;
            _initializeMovieFocusNodes();
          });
          _headerAnimationController.forward();
          _listAnimationController.forward();
          _setupFocusProvider();
        }
      } else {
        if (mounted) setState(() { _errorMessage = 'No movies found'; _isLoading = false; });
        _setupFocusProvider();
      }
    } catch (e) {
      if (mounted) setState(() { _errorMessage = 'Network error'; _isLoading = false; });
      _setupFocusProvider();
    }
  }

  void _cleanupFocusNodes() {
    String? firstMovieId;
    if (displayMoviesList.isNotEmpty) firstMovieId = displayMoviesList[0].id.toString();
    for (var entry in movieFocusNodes.entries) {
      if (entry.key != firstMovieId) {
        try { entry.value.dispose(); } catch (e) {}
      }
    }
    movieFocusNodes.clear();
  }

  void _initializeMovieFocusNodes() {
    movieFocusNodes.clear();
    for (var movie in displayMoviesList) {
      try {
        String movieId = movie.id.toString();
        movieFocusNodes[movieId] = FocusNode()
          ..addListener(() {
            if (mounted && movieFocusNodes[movieId]!.hasFocus) {
              _scrollToFocusedItem(movieId);
            }
          });
      } catch (e) {}
    }
  }

  void _setupFocusProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final focusProvider = Provider.of<FocusProvider>(context, listen: false);
          
          if (displayMoviesList.isNotEmpty) {
            final firstMovieId = displayMoviesList[0].id.toString();
            if (movieFocusNodes.containsKey(firstMovieId)) {
              focusProvider.registerFocusNode('manageMovies', movieFocusNodes[firstMovieId]!);
            }
          } else if (_errorMessage.isNotEmpty) {
             focusProvider.registerFocusNode('manageMovies', _retryFocusNode);
          }
        } catch (e) {}
      }
    });
  }

  void _scrollToFocusedItem(String itemId) {
    if (!mounted || !_scrollController.hasClients) return;
    try {
      int index = displayMoviesList.indexWhere((movie) => movie.id.toString() == itemId);
      if (index == -1) return;
      double itemWidth = bannerwdt + 12;
      double targetScrollPosition = (index * itemWidth);
      targetScrollPosition = targetScrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent);
      _scrollController.animateTo(targetScrollPosition, duration: AnimationTiming.scroll, curve: Curves.easeOutCubic);
    } catch (e) {}
  }

  Future<void> _handleMovieTap(Movie movie) async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      int? currentUserId = SessionManager.userId;
      await HistoryService.updateUserHistory(userId: currentUserId!, contentType: 1, eventId: movie.id, eventTitle: movie.name, url: movie.movieUrl, categoryId: 0);
    } catch (e) {}

    if (mounted) showDialog(context: context, barrierDismissible: false, builder: (c) => Center(child: CircularProgressIndicator(color: ProfessionalColorsForHomePages.accentBlue)));

    try {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      String rawUrl = movie.movieUrl;
      
      if (mounted) {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(
          videoUrl: rawUrl,
          bannerImageUrl: movie.banner ?? movie.poster ?? '',
          channelList: [],
          source: 'isRecentlyAdded',
          videoId: movie.id,
          name: movie.name,
          liveStatus: false,
          updatedAt: movie.updatedAt,
        )));
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        if(mounted) _isNavigating = false;
      });
    }
  }

  // ✅ UPDATED ERROR WIDGET (Using Smart Widget)
  Widget _buildErrorWidget(double height) {
    return SizedBox(
      height: height,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: ProfessionalColorsForHomePages.cardDark.withOpacity(0.3), borderRadius: BorderRadius.circular(50), border: Border.all(color: ProfessionalColorsForHomePages.accentRed.withOpacity(0.3))),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 20, color: ProfessionalColorsForHomePages.accentRed),
              const SizedBox(width: 10),
              Flexible(child: Text("Connection Failed", style: const TextStyle(color: ProfessionalColorsForHomePages.textPrimary, fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 15),
              // ✅ Smart Retry Widget
              SmartRetryWidget(
                errorMessage: _errorMessage,
                onRetry: _fetchDisplayMovies,
                focusNode: _retryFocusNode,
                providerIdentifier: 'manageMovies',
                onFocusChange: (hasFocus) {
                   if(mounted) setState(() => _isSectionFocused = hasFocus);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(double screenWidth, double screenHeight) {
    double effectiveBannerHgt = bannerhgt ?? screenHeight * 0.2;
    double effectiveBannerWdt = bannerwdt ?? screenWidth * 0.18;

    if (_isLoading) {
      return SmartLoadingWidget(itemWidth: effectiveBannerWdt, itemHeight: effectiveBannerHgt);
    } else if (_errorMessage.isNotEmpty) {
      return _buildErrorWidget(effectiveBannerHgt);
    } else if (displayMoviesList.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildMoviesList(screenWidth, screenHeight);
    }
  }

  Widget _buildEmptyWidget() {
    return Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.movie_outlined, size: 24, color: Colors.grey), SizedBox(width: 10), Text("No Movies Found", style: TextStyle(color: Colors.white, fontSize: 12))]));
  }

  Widget _buildMoviesList(double screenWidth, double screenHeight) {
    return FadeTransition(
      opacity: _listFadeAnimation,
      child: SizedBox(
        height: (screenhgt ?? MediaQuery.of(context).size.height) * 0.38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          cacheExtent: 9999,
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
          itemCount: displayMoviesList.length,
          itemBuilder: (context, index) {
            var movie = displayMoviesList[index];
            return _buildMovieItem(movie, index, screenWidth, screenHeight);
          },
        ),
      ),
    );
  }

  Widget _buildMovieItem(Movie movie, int index, double screenWidth, double screenHeight) {
    String movieId = movie.id.toString();
    if (!movieFocusNodes.containsKey(movieId)) return const SizedBox.shrink();

    return Focus(
      focusNode: movieFocusNodes[movieId],
      onFocusChange: (hasFocus) async {
        if (mounted) setState(() => _isSectionFocused = hasFocus); // ✅ Shadow Update
        if (hasFocus && mounted) {
          try {
            Color dominantColor = ProfessionalColorsForHomePages.accentBlue;
            // ✅ Fixed: Now _currentAccentColor is defined
            setState(() { _currentAccentColor = dominantColor; });
            context.read<ColorProvider>().updateColor(dominantColor, true);
            widget.onFocusChange?.call(true);
          } catch (e) {}
        } else if (mounted) {
          context.read<ColorProvider>().resetColor();
          widget.onFocusChange?.call(false);
        }
      },
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.arrowLeft) {
            if (_isNavigationLocked) return KeyEventResult.handled;
            setState(() => _isNavigationLocked = true);
            _navigationLockTimer = Timer(const Duration(milliseconds: 600), () { if (mounted) setState(() => _isNavigationLocked = false); });
            if (key == LogicalKeyboardKey.arrowRight) {
              if (index < displayMoviesList.length - 1) { String nextId = displayMoviesList[index + 1].id.toString(); FocusScope.of(context).requestFocus(movieFocusNodes[nextId]); } 
              else { _navigationLockTimer?.cancel(); if (mounted) setState(() => _isNavigationLocked = false); }
            } else if (key == LogicalKeyboardKey.arrowLeft) {
              if (index > 0) { String prevId = displayMoviesList[index - 1].id.toString(); FocusScope.of(context).requestFocus(movieFocusNodes[prevId]); } 
              else { _navigationLockTimer?.cancel(); if (mounted) setState(() => _isNavigationLocked = false); }
            }
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.arrowUp) {
            context.read<ColorProvider>().resetColor();
            context.read<FocusProvider>().updateLastFocusedIdentifier('manageMovies');
            context.read<FocusProvider>().focusPreviousRow();
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowDown) {
            context.read<ColorProvider>().resetColor();
            context.read<FocusProvider>().updateLastFocusedIdentifier('manageMovies');
            context.read<FocusProvider>().focusNextRow();
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.select) {
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
          onColorChange: (color) {},
          index: index,
          categoryTitle: widget.displayTitle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double containerHeight = (screenhgt ?? screenHeight) * 0.38;

    return Consumer<ColorProvider>(
      builder: (context, colorProvider, child) {
        
        bool showShadow = _isSectionFocused;

        return Scaffold(
          backgroundColor: Colors.white,
          body: ClipRect(
            child: SizedBox(
              height: containerHeight,
              child: Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(height: (screenhgt ?? screenHeight) * 0.01),
                      _buildProfessionalTitle(screenWidth),
                      Expanded(child: _buildBody(screenWidth, screenHeight)),
                    ],
                  ),
                  
                  // ✅ SHADOW OVERLAY
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          gradient: showShadow
                              ? LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.8), // Top Shadow
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.8), // Bottom Shadow
                                  ],
                                  stops: const [0.0, 0.25, 0.75, 1.0],
                                )
                              : null,
                        ),
                      ),
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

  Widget _buildProfessionalTitle(double screenWidth) {
    // Check if widget.displayTitle is not null, otherwise provide a default
    // Or if movie name is needed, ensure movie list is not empty
    String titleText = widget.displayTitle;

    return SlideTransition(
      position: _headerSlideAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
        child: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  ProfessionalColorsForHomePages.accentBlue,
                  ProfessionalColorsForHomePages.accentPurple,
                ],
              ).createShader(bounds),
              child: Text(
                titleText,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
// ✅ Professional Movie Card (Unchanged)
class ProfessionalMovieCard extends StatefulWidget {
  final Movie movie;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final Function(Color) onColorChange;
  final int index;
  final String categoryTitle;

  const ProfessionalMovieCard({
    Key? key,
    required this.movie,
    required this.focusNode,
    required this.onTap,
    required this.onColorChange,
    required this.index,
    required this.categoryTitle,
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

  Color _dominantColor = ProfessionalColorsForHomePages.accentBlue;
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
      duration: const Duration(milliseconds: 1500),
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
    _dominantColor = ProfessionalColorsForHomePages.accentBlue;
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
            width: bannerwdt,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfessionalPoster(screenWidth, screenHeight),
                _buildProfessionalTitle(screenWidth),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfessionalPoster(double screenWidth, double screenHeight) {
    final posterHeight = _isFocused ? focussedBannerhgt : bannerhgt;

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
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: _dominantColor.withOpacity(0.2),
              blurRadius: 45,
              spreadRadius: 6,
              offset: const Offset(0, 15),
            ),
          ] else ...[
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
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
            _buildGenreBadge(),
            if (_isFocused) _buildHoverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieImage(double screenWidth, double posterHeight) {
    final String uniqueImageUrl = "${widget.movie.banner}?v=${widget.movie.updatedAt}";
    final String uniqueCacheKey = "${widget.movie.id.toString()}_${widget.movie.updatedAt}";
    return Container(
      width: double.infinity,
      height: posterHeight,
      child: widget.movie.banner != null && widget.movie.banner!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: uniqueImageUrl,
              fit: BoxFit.cover,
              memCacheHeight: 300,
              cacheKey: uniqueCacheKey,
              placeholder: (context, url) => _buildImagePlaceholder(posterHeight),
              errorWidget: (context, url, error) => _buildImagePlaceholder(posterHeight),
            )
          : _buildImagePlaceholder(posterHeight),
    );
  }

  Widget _buildImagePlaceholder(double height) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProfessionalColorsForHomePages.cardDark,
            ProfessionalColorsForHomePages.surfaceDark,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_outlined,
            size: height * 0.25,
            color: ProfessionalColorsForHomePages.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            widget.categoryTitle,
            style: TextStyle(
              color: ProfessionalColorsForHomePages.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: ProfessionalColorsForHomePages.accentBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'HD',
              style: TextStyle(
                color: ProfessionalColorsForHomePages.accentBlue,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
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
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenreBadge() {
    String genre = 'HD';
    Color badgeColor = ProfessionalColorsForHomePages.accentBlue;

    if (widget.movie.genres.toLowerCase().contains('comedy')) {
      genre = 'COMEDY';
      badgeColor = ProfessionalColorsForHomePages.accentGreen;
    } else if (widget.movie.genres.toLowerCase().contains('action')) {
      genre = 'ACTION';
      badgeColor = ProfessionalColorsForHomePages.accentRed;
    } else if (widget.movie.genres.toLowerCase().contains('romantic')) {
      genre = 'ROMANCE';
      badgeColor = ProfessionalColorsForHomePages.accentPink;
    } else if (widget.movie.genres.toLowerCase().contains('drama')) {
      genre = 'DRAMA';
      badgeColor = ProfessionalColorsForHomePages.accentPurple;
    }

    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          genre,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
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
    final movieName = widget.movie.name.toUpperCase();

    return Container(
      width: bannerwdt,
      child: AnimatedDefaultTextStyle(
        duration: AnimationTiming.medium,
        style: TextStyle(
          fontSize: _isFocused ? 13 : 11,
          fontWeight: FontWeight.w600,
          color: _isFocused ? _dominantColor : ProfessionalColorsForHomePages.primaryDark,
          letterSpacing: 0.5,
          shadows: _isFocused
              ? [
                  Shadow(
                    color: _dominantColor.withOpacity(0.6),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
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

// Wrapper class for Screen
class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});
  @override
  _MoviesScreenState createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final FocusNode _moviesFocusNode = FocusNode();

  @override
  void dispose() {
    _moviesFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ProfessionalMoviesHorizontalList(
          focusNode: _moviesFocusNode,
          displayTitle: "RECENTLY ADDED",
          navigationIndex: 3,
          onFocusChange: (bool hasFocus) {
            print('Movies section focus: $hasFocus');
          },
        ),
      ),
    );
  }
}