




// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/video_widget/custom_video_player.dart';
// import 'package:mobi_tv_entertainment/video_widget/device_detector_firestick.dart';
// import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player.dart';

// import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:math' as math;
// import 'dart:ui';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';

// bool isYoutubeUrl(String? url) {
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

// // Professional Color Palette (same as GenericLiveChannels)
// class ProfessionalColors {
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

// // Movie Model
// class Movie {
//   final int id;
//   final String name;
//   final String description;
//   final String genres;
//   final String releaseDate;
//   final int? runtime;
//   final String? poster;
//   final String? banner;
//   final String sourceType;
//   final String movieUrl;
//   final List<Network> networks;

//   Movie({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.genres,
//     required this.releaseDate,
//     this.runtime,
//     this.poster,
//     this.banner,
//     required this.sourceType,
//     required this.movieUrl,
//     required this.networks,
//   });

//   factory Movie.fromJson(Map<String, dynamic> json) {
//     return Movie(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
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

// // 🚀 Enhanced Movie Service with Caching
// class MovieService {
//   // Cache keys
//   static const String _cacheKeyMovies = 'cached_movies';
//   static const String _cacheKeyTimestamp = 'cached_movies_timestamp';
//   static const String _cacheKeyAuthKey = 'auth_key';

//   // Cache duration (in milliseconds) - 1 hour
//   static const int _cacheDurationMs = 60 * 60 * 1000; // 1 hour

//   /// Main method to get all movies with caching
//   static Future<List<Movie>> getAllMovies({bool forceRefresh = false}) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       // Check if we should use cache
//       if (!forceRefresh && await _shouldUseCache(prefs)) {
//         print('📦 Loading movies from cache...');
//         final cachedMovies = await _getCachedMovies(prefs);
//         if (cachedMovies.isNotEmpty) {
//           print(
//               '✅ Successfully loaded ${cachedMovies.length} movies from cache');

//           // Load fresh data in background (without waiting)
//           _loadFreshDataInBackground();

//           return cachedMovies;
//         }
//       }

//       // Load fresh data if no cache or force refresh
//       print('🌐 Loading fresh movies from API...');
//       return await _fetchFreshMovies(prefs);
//     } catch (e) {
//       print('❌ Error in getAllMovies: $e');

//       // Try to return cached data as fallback
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         final cachedMovies = await _getCachedMovies(prefs);
//         if (cachedMovies.isNotEmpty) {
//           print('🔄 Returning cached data as fallback');
//           return cachedMovies;
//         }
//       } catch (cacheError) {
//         print('❌ Cache fallback also failed: $cacheError');
//       }

//       throw Exception('Failed to load movies: $e');
//     }
//   }

//   /// Check if cached data is still valid
//   static Future<bool> _shouldUseCache(SharedPreferences prefs) async {
//     try {
//       final timestampStr = prefs.getString(_cacheKeyTimestamp);
//       if (timestampStr == null) return false;

//       final cachedTimestamp = int.tryParse(timestampStr);
//       if (cachedTimestamp == null) return false;

//       final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
//       final cacheAge = currentTimestamp - cachedTimestamp;

//       final isValid = cacheAge < _cacheDurationMs;

//       if (isValid) {
//         final ageMinutes = (cacheAge / (1000 * 60)).round();
//         print('📦 Cache is valid (${ageMinutes} minutes old)');
//       } else {
//         final ageMinutes = (cacheAge / (1000 * 60)).round();
//         print('⏰ Cache expired (${ageMinutes} minutes old)');
//       }

//       return isValid;
//     } catch (e) {
//       print('❌ Error checking cache validity: $e');
//       return false;
//     }
//   }

//   /// Get movies from cache
//   static Future<List<Movie>> _getCachedMovies(SharedPreferences prefs) async {
//     try {
//       final cachedData = prefs.getString(_cacheKeyMovies);
//       if (cachedData == null || cachedData.isEmpty) {
//         print('📦 No cached data found');
//         return [];
//       }

//       final List<dynamic> jsonData = json.decode(cachedData);
//       final movies = jsonData
//           .map((json) => Movie.fromJson(json as Map<String, dynamic>))
//           .toList();

//       print('📦 Successfully loaded ${movies.length} movies from cache');
//       return movies;
//     } catch (e) {
//       print('❌ Error loading cached movies: $e');
//       return [];
//     }
//   }

//   /// Fetch fresh movies from API and cache them
//   static Future<List<Movie>> _fetchFreshMovies(SharedPreferences prefs) async {
//     try {
//       String authKey = prefs.getString(_cacheKeyAuthKey) ?? '';

//       final response = await http.get(
//         Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllMovies?records=8'),
//         headers: {'auth-key': authKey},
//       ).timeout(
//         const Duration(seconds: 30),
//         onTimeout: () {
//           throw Exception('Request timeout');
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

//         final movies = jsonData
//             .map((json) => Movie.fromJson(json as Map<String, dynamic>))
//             .toList();

//         // Cache the fresh data
//         await _cacheMovies(prefs, jsonData);

//         print('✅ Successfully loaded ${movies.length} fresh movies from API');
//         return movies;
//       } else {
//         throw Exception(
//             'API Error: ${response.statusCode} - ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('❌ Error fetching fresh movies: $e');
//       rethrow;
//     }
//   }

//   /// Cache movies data
//   static Future<void> _cacheMovies(
//       SharedPreferences prefs, List<dynamic> moviesData) async {
//     try {
//       final jsonString = json.encode(moviesData);
//       final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

//       // Save movies data and timestamp
//       await Future.wait([
//         prefs.setString(_cacheKeyMovies, jsonString),
//         prefs.setString(_cacheKeyTimestamp, currentTimestamp),
//       ]);

//       print('💾 Successfully cached ${moviesData.length} movies');
//     } catch (e) {
//       print('❌ Error caching movies: $e');
//     }
//   }

//   /// Load fresh data in background without blocking UI
//   static void _loadFreshDataInBackground() {
//     Future.delayed(const Duration(milliseconds: 500), () async {
//       try {
//         print('🔄 Loading fresh data in background...');
//         final prefs = await SharedPreferences.getInstance();
//         await _fetchFreshMovies(prefs);
//         print('✅ Background refresh completed');
//       } catch (e) {
//         print('⚠️ Background refresh failed: $e');
//       }
//     });
//   }

//   /// Clear all cached data
//   static Future<void> clearCache() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await Future.wait([
//         prefs.remove(_cacheKeyMovies),
//         prefs.remove(_cacheKeyTimestamp),
//       ]);
//       print('🗑️ Cache cleared successfully');
//     } catch (e) {
//       print('❌ Error clearing cache: $e');
//     }
//   }

//   /// Get cache info for debugging
//   static Future<Map<String, dynamic>> getCacheInfo() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final timestampStr = prefs.getString(_cacheKeyTimestamp);
//       final cachedData = prefs.getString(_cacheKeyMovies);

//       if (timestampStr == null || cachedData == null) {
//         return {
//           'hasCachedData': false,
//           'cacheAge': 0,
//           'cachedMoviesCount': 0,
//           'cacheSize': 0,
//         };
//       }

//       final cachedTimestamp = int.tryParse(timestampStr) ?? 0;
//       final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
//       final cacheAge = currentTimestamp - cachedTimestamp;
//       final cacheAgeMinutes = (cacheAge / (1000 * 60)).round();

//       final List<dynamic> jsonData = json.decode(cachedData);
//       final cacheSizeKB = (cachedData.length / 1024).round();

//       return {
//         'hasCachedData': true,
//         'cacheAge': cacheAgeMinutes,
//         'cachedMoviesCount': jsonData.length,
//         'cacheSize': cacheSizeKB,
//         'isValid': cacheAge < _cacheDurationMs,
//       };
//     } catch (e) {
//       print('❌ Error getting cache info: $e');
//       return {
//         'hasCachedData': false,
//         'cacheAge': 0,
//         'cachedMoviesCount': 0,
//         'cacheSize': 0,
//         'error': e.toString(),
//       };
//     }
//   }

//   /// Force refresh data (bypass cache)
//   static Future<List<Movie>> forceRefresh() async {
//     print('🔄 Force refreshing movies data...');
//     return await getAllMovies(forceRefresh: true);
//   }
// }

// // // API Service
// // class MovieService {
// //   static Future<List<Movie>> getAllMovies() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       String authKey = prefs.getString('auth_key') ?? '';

// //       final response = await http.get(
// //         Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllMovies'),
// //         headers: {'auth-key': authKey},
// //       );

// //       if (response.statusCode == 200) {
// //         final dynamic responseBody = json.decode(response.body);

// //         List<dynamic> jsonData;
// //         if (responseBody is List) {
// //           jsonData = responseBody;
// //         } else if (responseBody is Map && responseBody['data'] != null) {
// //           jsonData = responseBody['data'] as List;
// //         } else {
// //           throw Exception('Unexpected API response format');
// //         }

// //         return jsonData
// //             .map((json) => Movie.fromJson(json as Map<String, dynamic>))
// //             .toList();
// //       } else {
// //         throw Exception('Failed to load movies: ${response.statusCode}');
// //       }
// //     } catch (e) {
// //       print('Error loading movies: $e');
// //       throw Exception('Failed to load movies: $e');
// //     }
// //   }
// // }

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
//   List<Movie> fullMoviesList = [];
//   int totalMoviesCount = 0;

//   bool _isLoading = true;
//   String _errorMessage = '';
//   bool _isNavigating = false;
//   bool _isLoadingFullList = false;

//   // Animation Controllers
//   late AnimationController _headerAnimationController;
//   late AnimationController _listAnimationController;
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<double> _listFadeAnimation;

//   // Focus management
//   Map<String, FocusNode> movieFocusNodes = {};
//   FocusNode? _viewAllFocusNode;
//   Color _currentAccentColor = ProfessionalColors.accentBlue;

//   final ScrollController _scrollController = ScrollController();
//   final int _maxItemsToShow = 7;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _initializeViewAllFocusNode();
//     _setupFocusProvider();
//     _fetchDisplayMovies();
//   }

//   void _setupFocusProvider() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         try {
//           final focusProvider =
//               Provider.of<FocusProvider>(context, listen: false);

//           // ✅ Special handling for Live page (index 0)
//           if (widget.navigationIndex == 0) {
//             focusProvider.setLiveChannelsFocusNode(widget.focusNode);
//             print('✅ Live focus node specially registered');
//           }

//           // ✅ MOVIES: Register with navigation index for all pages
//           focusProvider.registerGenericChannelFocus(
//               widget.navigationIndex, _scrollController, widget.focusNode);

//           // ✅ MOVIES: Register first movie focus node for SubVod navigation
//           if (displayMoviesList.isNotEmpty) {
//             final firstMovieId = displayMoviesList[0].id.toString();
//             if (movieFocusNodes.containsKey(firstMovieId)) {
//               focusProvider.setFirstManageMoviesFocusNode(
//                   movieFocusNodes[firstMovieId]!);
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

//   void _initializeViewAllFocusNode() {
//     _viewAllFocusNode = FocusNode()
//       ..addListener(() {
//         if (mounted && _viewAllFocusNode!.hasFocus) {
//           setState(() {
//             _currentAccentColor = ProfessionalColors.gradientColors[
//                 math.Random()
//                     .nextInt(ProfessionalColors.gradientColors.length)];
//           });
//         }
//       });
//   }

//   // 🚀 Updated _fetchDisplayMovies method with caching
//   Future<void> _fetchDisplayMovies() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       // 🚀 Enhanced: Use cached data first, then fresh data
//       final fetchedMovies = await MovieService.getAllMovies();

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

//   // Future<void> _fetchDisplayMovies() async {
//   //   if (!mounted) return;

//   //   setState(() {
//   //     _isLoading = true;
//   //     _errorMessage = '';
//   //   });

//   //   try {
//   //     final fetchedMovies = await MovieService.getAllMovies();

//   //     if (fetchedMovies.isNotEmpty) {
//   //       if (mounted) {
//   //         setState(() {
//   //           totalMoviesCount = fetchedMovies.length;
//   //           displayMoviesList = fetchedMovies.take(_maxItemsToShow).toList();
//   //           _initializeMovieFocusNodes();
//   //           _isLoading = false;
//   //         });

//   //         _headerAnimationController.forward();
//   //         _listAnimationController.forward();
//   //       }
//   //     } else {
//   //       if (mounted) {
//   //         setState(() {
//   //           _errorMessage = 'No movies found';
//   //           _isLoading = false;
//   //         });
//   //       }
//   //     }
//   //   } catch (e) {
//   //     if (mounted) {
//   //       setState(() {
//   //         _errorMessage = 'Network error: Please check connection';
//   //         _isLoading = false;
//   //       });
//   //     }
//   //   }
//   // }

//   // 🚀 Updated _fetchFullMoviesList method with cache
//   Future<void> _fetchFullMoviesList() async {
//     if (!mounted || _isLoadingFullList || fullMoviesList.isNotEmpty) return;

//     setState(() {
//       _isLoadingFullList = true;
//     });

//     try {
//       // Use cached data for full list as well
//       final fetchedMovies = await MovieService.getAllMovies();

//       if (mounted) {
//         setState(() {
//           fullMoviesList = fetchedMovies;
//           _isLoadingFullList = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoadingFullList = false;
//         });
//       }
//       print('❌ Error fetching full movies list: $e');
//     }
//   }

//   // Future<void> _fetchFullMoviesList() async {
//   //   if (!mounted || _isLoadingFullList || fullMoviesList.isNotEmpty) return;

//   //   setState(() {
//   //     _isLoadingFullList = true;
//   //   });

//   //   try {
//   //     final fetchedMovies = await MovieService.getAllMovies();

//   //     if (mounted) {
//   //       setState(() {
//   //         fullMoviesList = fetchedMovies;
//   //         _isLoadingFullList = false;
//   //       });
//   //     }
//   //   } catch (e) {
//   //     if (mounted) {
//   //       setState(() {
//   //         _isLoadingFullList = false;
//   //       });
//   //     }
//   //   }
//   // }

//   // 🆕 Debug method to show cache information
//   Future<void> _debugCacheInfo() async {
//     try {
//       final cacheInfo = await MovieService.getCacheInfo();
//       print('📊 Cache Info: $cacheInfo');
//     } catch (e) {
//       print('❌ Error getting cache info: $e');
//     }
//   }

// // 🆕 Add this method to force refresh movies
//   Future<void> _forceRefreshMovies() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       // Force refresh bypasses cache
//       final fetchedMovies = await MovieService.forceRefresh();

//       if (fetchedMovies.isNotEmpty) {
//         if (mounted) {
//           setState(() {
//             totalMoviesCount = fetchedMovies.length;
//             displayMoviesList = fetchedMovies.take(_maxItemsToShow).toList();
//             fullMoviesList = []; // Clear full list to force re-fetch
//             _initializeMovieFocusNodes();
//             _isLoading = false;
//           });

//           _headerAnimationController.forward();
//           _listAnimationController.forward();

//           // Show success message
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text('Movies refreshed successfully'),
//               backgroundColor: ProfessionalColors.accentGreen,
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
//     // Clear existing focus nodes
//     for (var node in movieFocusNodes.values) {
//       try {
//         node.removeListener(() {});
//         node.dispose();
//       } catch (e) {}
//     }
//     movieFocusNodes.clear();

//     // Create focus nodes for display movies
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

//           // Register first movie with focus provider
//           final firstMovieId = displayMoviesList[0].id.toString();
//           if (movieFocusNodes.containsKey(firstMovieId)) {
//             // ✅ MOVIES: Register first movie focus node for SubVod arrow down navigation
//             focusProvider
//                 .setFirstManageMoviesFocusNode(movieFocusNodes[firstMovieId]!);
//             print(
//                 '✅ Movies first banner focus registered for SubVod navigation');

//             focusProvider.registerGenericChannelFocus(widget.navigationIndex,
//                 _scrollController, movieFocusNodes[firstMovieId]!);
//           }

//           // Register ViewAll focus node
//           if (_viewAllFocusNode != null) {
//             focusProvider.registerViewAllFocusNode(
//                 widget.navigationIndex, _viewAllFocusNode!);
//           }
//         } catch (e) {
//           print('❌ Focus provider registration failed: $e');
//         }
//       }
//     });
//   }

//   // void _scrollToFocusedItem(String itemId) {
//   //   if (!mounted) return;

//   //   try {
//   //     final focusNode = movieFocusNodes[itemId];
//   //     if (focusNode != null &&
//   //         focusNode.hasFocus &&
//   //         focusNode.context != null) {
//   //       Scrollable.ensureVisible(
//   //         focusNode.context!,
//   //         alignment: 0.05,
//   //         duration: AnimationTiming.scroll,
//   //         curve: Curves.easeInOutCubic,
//   //       );
//   //     }
//   //   } catch (e) {}
//   // }


// // Option 1: Ultra Simple Version
// void _scrollToFocusedItem(String itemId) {
//   if (!mounted || !_scrollController.hasClients) return;

//   try {
//     // Find focused item index
//     int index = displayMoviesList.indexWhere((movie) => movie.id.toString() == itemId);
    
//     if (index != -1) {
//       // Simple scroll calculation
//       double scrollPosition = index * 180.0; // Adjust 180 to your item width
      
//       _scrollController.animateTo(
//         scrollPosition,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeOut,
//       );
//     }
//   } catch (e) {
//     // Silent fail
//   }
// }
  

//   Future<void> _handleMovieTap(Movie movie) async {
//     if (_isNavigating) return;
//     _isNavigating = true;

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
//                           ProfessionalColors.accentBlue,
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

//       // Add this helper method in ProfessionalMoviesHorizontalList
//       List<NewsItemModel> _convertMoviesToNewsItems(List<Movie> movies) {
//         return movies
//             .map((movie) => NewsItemModel(
//                   id: movie.id.toString(),
//                   name: movie.name,
//                   banner: movie.banner ?? movie.poster ?? '',
//                   url: movie.movieUrl,
//                   unUpdatedUrl: movie.movieUrl,
//                   contentType: '1', // Movie type
//                   streamType: movie.sourceType,
//                   liveStatus: false,
//                   poster: movie.poster ?? movie.banner ?? '',
//                   image: movie.banner ?? movie.poster ?? '',
//                   // Other required fields...
//                 ))
//             .toList();
//       }

// // // In _handleMovieTap method
// // await Navigator.push(
// //   context,
// //   MaterialPageRoute(
// //     builder: (context) => VideoScreen(
// //       videoUrl: movie.movieUrl,
// //       bannerImageUrl: movie.banner ?? movie.poster ?? '',
// //       startAtPosition: Duration.zero,
// //       videoType: movie.sourceType,
// //       channelList: _convertMoviesToNewsItems(displayMoviesList), // ✅ Convert and send
// //       isLive: false,
// //       isVOD: true,
// //       isBannerSlider: false,
// //       source: 'isMovieScreen',
// //       isSearch: false,
// //       videoId: movie.id,
// //       unUpdatedUrl: movie.movieUrl,
// //       name: movie.name,
// //       seasonId: null,
// //       isLastPlayedStored: true,
// //       liveStatus: false,
// //     ),
// //   ),
// // );
//       if (isYoutubeUrl(movie.movieUrl)) {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => CustomYoutubePlayer(
//               videoUrl: movie.movieUrl,
//               name: movie.name,
//             ),
//           ),
//         );

//         // // ✅ VIDEO PLAYING - Navigate to VideoScreen with proper parameters
//         // await Navigator.push(
//         //   context,
//         //   MaterialPageRoute(
//         //     builder: (context) => VideoScreen(
//         //       videoUrl: movie.movieUrl,
//         //       bannerImageUrl: movie.banner ?? movie.poster ?? '',
//         //       startAtPosition: Duration.zero,
//         //       videoType: movie.sourceType,
//         //       channelList: [], // Empty for movies
//         //       isLive: false,
//         //       isVOD: true,
//         //       isBannerSlider: false,
//         //       source: 'moviesScreen',
//         //       isSearch: false,
//         //       videoId: movie.id,
//         //       unUpdatedUrl: movie.movieUrl,
//         //       name: movie.name,
//         //       seasonId: null,
//         //       isLastPlayedStored: true,
//         //       liveStatus: false,
//         //       // // Additional movie-specific parameters
//         //       // description: movie.description,
//         //       // genres: movie.genres,
//         //       // releaseDate: movie.releaseDate,
//         //       // runtime: movie.runtime,
//         //     ),
//         //   ),
//         // );
//       } else {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => CustomVideoPlayer(
//               videoUrl: movie.movieUrl,
//             ),
//           ),
//         );
//       }
//       print('✅ Movie played successfully: ${movie.name}');
//     } catch (e) {
//       if (dialogShown) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }

//       // ✅ Better error handling with specific error messages
//       String errorMessage = 'Something went wrong';
//       if (e.toString().contains('network') ||
//           e.toString().contains('connection')) {
//         errorMessage = 'Network error. Please check your connection';
//       } else if (e.toString().contains('format') ||
//           e.toString().contains('codec')) {
//         errorMessage = 'Video format not supported';
//       } else if (e.toString().contains('not found') ||
//           e.toString().contains('404')) {
//         errorMessage = 'Movie not found or unavailable';
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(errorMessage),
//           backgroundColor: ProfessionalColors.accentRed,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           action: SnackBarAction(
//             label: 'Retry',
//             textColor: Colors.white,
//             onPressed: () => _handleMovieTap(movie),
//           ),
//         ),
//       );
//     } finally {
//       _isNavigating = false;
//     }
//   }

//   void _navigateToMoviesGrid() async {
//     if (!_isNavigating && mounted) {
//       if (fullMoviesList.isEmpty) {
//         await _fetchFullMoviesList();
//       }

//       if (mounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ProfessionalMoviesGridView(
//               moviesList: fullMoviesList.isNotEmpty
//                   ? fullMoviesList
//                   : displayMoviesList,
//               categoryTitle: widget.displayTitle,
//             ),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _headerAnimationController.dispose();
//     _listAnimationController.dispose();

//     for (var entry in movieFocusNodes.entries) {
//       try {
//         entry.value.removeListener(() {});
//         entry.value.dispose();
//       } catch (e) {}
//     }
//     movieFocusNodes.clear();

//     try {
//       _viewAllFocusNode?.removeListener(() {});
//       _viewAllFocusNode?.dispose();
//     } catch (e) {}

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

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               ProfessionalColors.primaryDark,
//               ProfessionalColors.surfaceDark.withOpacity(0.5),
//             ],
//           ),
//         ),
//         child: Column(
//           children: [
//             SizedBox(height: screenHeight * 0.02),
//             _buildProfessionalTitle(screenWidth),
//             SizedBox(height: screenHeight * 0.01),
//             Expanded(child: _buildBody(screenWidth, screenHeight)),
//           ],
//         ),
//       ),
//     );
//   }

//   // 🚀 Enhanced Title with Cache Status and Refresh Button
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
//                   ProfessionalColors.accentBlue,
//                   ProfessionalColors.accentPurple,
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
            
//             Row(
//               children: [
//                 // 🆕 Refresh Button
//                 // GestureDetector(
//                 //   onTap: _isLoading ? null : _forceRefreshMovies,
//                 //   child: Container(
//                 //     padding: const EdgeInsets.all(8),
//                 //     decoration: BoxDecoration(
//                 //       color: ProfessionalColors.accentBlue.withOpacity(0.2),
//                 //       borderRadius: BorderRadius.circular(8),
//                 //       border: Border.all(
//                 //         color: ProfessionalColors.accentBlue.withOpacity(0.3),
//                 //         width: 1,
//                 //       ),
//                 //     ),
//                 //     child: _isLoading
//                 //         ? SizedBox(
//                 //             width: 16,
//                 //             height: 16,
//                 //             child: CircularProgressIndicator(
//                 //               strokeWidth: 2,
//                 //               valueColor: AlwaysStoppedAnimation<Color>(
//                 //                 ProfessionalColors.accentBlue,
//                 //               ),
//                 //             ),
//                 //           )
//                 //         : Icon(
//                 //             Icons.refresh,
//                 //             size: 16,
//                 //             color: ProfessionalColors.accentBlue,
//                 //           ),
//                 //   ),
//                 // ),
//                 // const SizedBox(width: 12),
//                 // Movies Count
//                 if (totalMoviesCount > 0)
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           ProfessionalColors.accentBlue.withOpacity(0.2),
//                           ProfessionalColors.accentPurple.withOpacity(0.2),
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: ProfessionalColors.accentBlue.withOpacity(0.3),
//                         width: 1,
//                       ),
//                     ),
//                     child: Text(
//                       '${totalMoviesCount} Movies Available',
//                       style: const TextStyle(
//                         color: ProfessionalColors.textSecondary,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget _buildProfessionalTitle(double screenWidth) {
//   //   return SlideTransition(
//   //     position: _headerSlideAnimation,
//   //     child: Container(
//   //       padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
//   //       child: Row(
//   //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //         children: [
//   //           ShaderMask(
//   //             shaderCallback: (bounds) => const LinearGradient(
//   //               colors: [
//   //                 ProfessionalColors.accentBlue,
//   //                 ProfessionalColors.accentPurple,
//   //               ],
//   //             ).createShader(bounds),
//   //             child: Text(
//   //               widget.displayTitle,
//   //               style: TextStyle(
//   //                 fontSize: 24,
//   //                 color: Colors.white,
//   //                 fontWeight: FontWeight.w700,
//   //                 letterSpacing: 2.0,
//   //               ),
//   //             ),
//   //           ),
//   //           if (totalMoviesCount > 0)
//   //             Container(
//   //               padding:
//   //                   const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//   //               decoration: BoxDecoration(
//   //                 gradient: LinearGradient(
//   //                   colors: [
//   //                     ProfessionalColors.accentBlue.withOpacity(0.2),
//   //                     ProfessionalColors.accentPurple.withOpacity(0.2),
//   //                   ],
//   //                 ),
//   //                 borderRadius: BorderRadius.circular(20),
//   //                 border: Border.all(
//   //                   color: ProfessionalColors.accentBlue.withOpacity(0.3),
//   //                   width: 1,
//   //                 ),
//   //               ),
//   //               child: Text(
//   //                 '${totalMoviesCount} Movies Available',
//   //                 style: const TextStyle(
//   //                   color: ProfessionalColors.textSecondary,
//   //                   fontSize: 12,
//   //                   fontWeight: FontWeight.w500,
//   //                 ),
//   //               ),
//   //             ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

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
//                   ProfessionalColors.accentRed.withOpacity(0.2),
//                   ProfessionalColors.accentRed.withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.error_outline_rounded,
//               size: 40,
//               color: ProfessionalColors.accentRed,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Oops! Something went wrong',
//             style: TextStyle(
//               color: ProfessionalColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _errorMessage,
//             style: const TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 14,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: _fetchDisplayMovies,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: ProfessionalColors.accentBlue,
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
//                   ProfessionalColors.accentBlue.withOpacity(0.2),
//                   ProfessionalColors.accentBlue.withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.movie_outlined,
//               size: 40,
//               color: ProfessionalColors.accentBlue,
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'No ${widget.displayTitle} Found',
//             style: TextStyle(
//               color: ProfessionalColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Check back later for new content',
//             style: TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMoviesList(double screenWidth, double screenHeight) {
//     bool showViewAll = totalMoviesCount > 7;

//     return FadeTransition(
//       opacity: _listFadeAnimation,
//       child: Container(
//         height: screenHeight * 0.38,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           clipBehavior: Clip.none,
//           controller: _scrollController,
//           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
//           cacheExtent: 1200,
//           itemCount: showViewAll ? 8 : displayMoviesList.length,
//           itemBuilder: (context, index) {
//             if (showViewAll && index == 7) {
//               return Focus(
//                 focusNode: _viewAllFocusNode,
//                 onFocusChange: (hasFocus) {
//                   if (hasFocus && mounted) {
//                     Color viewAllColor = ProfessionalColors.gradientColors[
//                         math.Random()
//                             .nextInt(ProfessionalColors.gradientColors.length)];

//                     setState(() {
//                       _currentAccentColor = viewAllColor;
//                     });
//                   }
//                 },
//                 onKey: (FocusNode node, RawKeyEvent event) {
//                   if (event is RawKeyDownEvent) {
//                     if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey ==
//                         LogicalKeyboardKey.arrowLeft) {
//                       if (displayMoviesList.isNotEmpty &&
//                           displayMoviesList.length > 6) {
//                         String movieId = displayMoviesList[6].id.toString();
//                         FocusScope.of(context)
//                             .requestFocus(movieFocusNodes[movieId]);
//                         return KeyEventResult.handled;
//                       }
//                     } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                       FocusScope.of(context).unfocus();
//                       Future.delayed(const Duration(milliseconds: 50), () {
//                         if (mounted) {
//                           // context.read<FocusProvider>().requestSubVodFocus();
//                           // context.read<FocusProvider>().requestFirstSubVodFocus();
//                           context
//                               .read<FocusProvider>()
//                               .requestFirstHorizontalListNetworksFocus();
//                         }
//                       });
//                       // Navigate to navigation button
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey ==
//                         LogicalKeyboardKey.arrowDown) {
//                       FocusScope.of(context).unfocus();
//                       Future.delayed(const Duration(milliseconds: 50), () {
//                         if (mounted) {
//                           Provider.of<FocusProvider>(context, listen: false)
//                               .requestFirstWebseriesFocus();
//                         }
//                       });
//                       // Navigate to next section
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey == LogicalKeyboardKey.select) {
//                       _navigateToMoviesGrid();
//                       return KeyEventResult.handled;
//                     }
//                   }
//                   return KeyEventResult.ignored;
//                 },
//                 child: GestureDetector(
//                   onTap: _navigateToMoviesGrid,
//                   child: ProfessionalViewAllButton(
//                     focusNode: _viewAllFocusNode!,
//                     onTap: _navigateToMoviesGrid,
//                     totalItems: totalMoviesCount,
//                     itemType: 'MOVIES',
//                   ),
//                 ),
//               );
//             }

//             var movie = displayMoviesList[index];
//             return _buildMovieItem(movie, index, screenWidth, screenHeight);
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildMovieItem(
//       Movie movie, int index, double screenWidth, double screenHeight) {
//     String movieId = movie.id.toString();

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
//             Color dominantColor = ProfessionalColors.gradientColors[
//                 math.Random()
//                     .nextInt(ProfessionalColors.gradientColors.length)];

//             setState(() {
//               _currentAccentColor = dominantColor;
//             });

//             widget.onFocusChange?.call(true);
//           } catch (e) {
//             print('Focus change handling failed: $e');
//           }
//         } else if (mounted) {
//           widget.onFocusChange?.call(false);
//         }
//       },
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//             if (index < displayMoviesList.length - 1 && index != 6) {
//               String nextMovieId = displayMoviesList[index + 1].id.toString();
//               FocusScope.of(context).requestFocus(movieFocusNodes[nextMovieId]);
//               return KeyEventResult.handled;
//             } else if (index == 6 && totalMoviesCount > 7) {
//               FocusScope.of(context).requestFocus(_viewAllFocusNode);
//               return KeyEventResult.handled;
//             }
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//             if (index > 0) {
//               String prevMovieId = displayMoviesList[index - 1].id.toString();
//               FocusScope.of(context).requestFocus(movieFocusNodes[prevMovieId]);
//               return KeyEventResult.handled;
//             }
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//             FocusScope.of(context).unfocus();
//             Future.delayed(const Duration(milliseconds: 50), () {
//               if (mounted) {
//                 // context.read<FocusProvider>().requestSubVodFocus();
//                 // context.read<FocusProvider>().requestFirstSubVodFocus();
//                 context
//                     .read<FocusProvider>()
//                     .requestFirstHorizontalListNetworksFocus();
//               }
//             });
//             // Navigate to navigation button
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//             FocusScope.of(context).unfocus();
//             Future.delayed(const Duration(milliseconds: 50), () {
//               if (mounted) {
//                 Provider.of<FocusProvider>(context, listen: false)
//                     .requestFirstWebseriesFocus();
//               }
//             });
//             // Navigate to next section
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.select) {
//             _handleMovieTap(movie);
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
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
//           },
//           index: index,
//           categoryTitle: widget.displayTitle,
//         ),
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

//   Color _dominantColor = ProfessionalColors.accentBlue;
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
//     final colors = ProfessionalColors.gradientColors;
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
//     return Container(
//       width: double.infinity,
//       height: posterHeight,
//       child: widget.movie.banner != null && widget.movie.banner!.isNotEmpty
//           ? Image.network(
//               widget.movie.banner!,
//               fit: BoxFit.cover,
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return _buildImagePlaceholder(posterHeight);
//               },
//               errorBuilder: (context, error, stackTrace) =>
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
//             ProfessionalColors.cardDark,
//             ProfessionalColors.surfaceDark,
//           ],
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.movie_outlined,
//             size: height * 0.25,
//             color: ProfessionalColors.textSecondary,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             widget.categoryTitle,
//             style: TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//             decoration: BoxDecoration(
//               color: ProfessionalColors.accentBlue.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Text(
//               'HD',
//               style: TextStyle(
//                 color: ProfessionalColors.accentBlue,
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
//     Color badgeColor = ProfessionalColors.accentBlue;

//     if (widget.movie.genres.toLowerCase().contains('comedy')) {
//       genre = 'COMEDY';
//       badgeColor = ProfessionalColors.accentGreen;
//     } else if (widget.movie.genres.toLowerCase().contains('action')) {
//       genre = 'ACTION';
//       badgeColor = ProfessionalColors.accentRed;
//     } else if (widget.movie.genres.toLowerCase().contains('romantic')) {
//       genre = 'ROMANCE';
//       badgeColor = ProfessionalColors.accentPink;
//     } else if (widget.movie.genres.toLowerCase().contains('drama')) {
//       genre = 'DRAMA';
//       badgeColor = ProfessionalColors.accentPurple;
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
//           color: _isFocused ? _dominantColor : ProfessionalColors.textPrimary,
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

// // Professional View All Button
// class ProfessionalViewAllButton extends StatefulWidget {
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int totalItems;
//   final String itemType;

//   const ProfessionalViewAllButton({
//     Key? key,
//     required this.focusNode,
//     required this.onTap,
//     required this.totalItems,
//     this.itemType = 'ITEMS',
//   }) : super(key: key);

//   @override
//   _ProfessionalViewAllButtonState createState() =>
//       _ProfessionalViewAllButtonState();
// }

// class _ProfessionalViewAllButtonState extends State<ProfessionalViewAllButton>
//     with TickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late AnimationController _rotateController;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _rotateAnimation;

//   bool _isFocused = false;
//   Color _currentColor = ProfessionalColors.accentBlue;

//   @override
//   void initState() {
//     super.initState();

//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     )..repeat(reverse: true);

//     _rotateController = AnimationController(
//       duration: const Duration(milliseconds: 3000),
//       vsync: this,
//     )..repeat();

//     _pulseAnimation = Tween<double>(
//       begin: 0.85,
//       end: 1.15,
//     ).animate(CurvedAnimation(
//       parent: _pulseController,
//       curve: Curves.easeInOut,
//     ));

//     _rotateAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_rotateController);

//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     setState(() {
//       _isFocused = widget.focusNode.hasFocus;
//       if (_isFocused) {
//         _currentColor = ProfessionalColors.gradientColors[
//             math.Random().nextInt(ProfessionalColors.gradientColors.length)];
//         HapticFeedback.mediumImpact();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _rotateController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Container(
//       width: screenWidth * 0.19,
//       margin: const EdgeInsets.symmetric(horizontal: 6),
//       child: Column(
//         children: [
//           AnimatedBuilder(
//             animation: _isFocused ? _pulseAnimation : _rotateAnimation,
//             builder: (context, child) {
//               return Transform.scale(
//                 scale: _isFocused ? _pulseAnimation.value : 1.0,
//                 child: Transform.rotate(
//                   angle: _isFocused ? 0 : _rotateAnimation.value * 2 * math.pi,
//                   child: Container(
//                     height:
//                         _isFocused ? focussedBannerhgt : bannerhgt,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: _isFocused
//                             ? [
//                                 _currentColor,
//                                 _currentColor.withOpacity(0.7),
//                               ]
//                             : [
//                                 ProfessionalColors.cardDark,
//                                 ProfessionalColors.surfaceDark,
//                               ],
//                       ),
//                       boxShadow: [
//                         if (_isFocused) ...[
//                           BoxShadow(
//                             color: _currentColor.withOpacity(0.4),
//                             blurRadius: 25,
//                             spreadRadius: 3,
//                             offset: const Offset(0, 8),
//                           ),
//                         ] else ...[
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.4),
//                             blurRadius: 10,
//                             offset: const Offset(0, 5),
//                           ),
//                         ],
//                       ],
//                     ),
//                     child: _buildViewAllContent(),
//                   ),
//                 ),
//               );
//             },
//           ),
//           _buildViewAllTitle(),
//         ],
//       ),
//     );
//   }

//   Widget _buildViewAllContent() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         border: _isFocused
//             ? Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 2,
//               )
//             : null,
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.1),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   Icons.grid_view_rounded,
//                   size: _isFocused ? 45 : 35,
//                   color: Colors.white,
//                 ),
//                 Text(
//                   'VIEW ALL',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: _isFocused ? 14 : 12,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.25),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     '${widget.totalItems}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 11,
//                       fontWeight: FontWeight.w700,
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

//   Widget _buildViewAllTitle() {
//     return AnimatedDefaultTextStyle(
//       duration: AnimationTiming.medium,
//       style: TextStyle(
//         fontSize: _isFocused ? 13 : 11,
//         fontWeight: FontWeight.w600,
//         color: _isFocused ? _currentColor : ProfessionalColors.textPrimary,
//         letterSpacing: 0.5,
//         shadows: _isFocused
//             ? [
//                 Shadow(
//                   color: _currentColor.withOpacity(0.6),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ]
//             : [],
//       ),
//       child: Text(
//         'ALL ${widget.itemType}',
//         textAlign: TextAlign.center,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
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
//                       ProfessionalColors.accentBlue,
//                       ProfessionalColors.accentPurple,
//                       ProfessionalColors.accentGreen,
//                       ProfessionalColors.accentBlue,
//                     ],
//                     stops: [0.0, 0.3, 0.7, 1.0],
//                     transform: GradientRotation(_animation.value * 2 * math.pi),
//                   ),
//                 ),
//                 child: Container(
//                   margin: const EdgeInsets.all(5),
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: ProfessionalColors.primaryDark,
//                   ),
//                   child: const Icon(
//                     Icons.movie_rounded,
//                     color: ProfessionalColors.textPrimary,
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
//               color: ProfessionalColors.textPrimary,
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
//               color: ProfessionalColors.surfaceDark,
//             ),
//             child: AnimatedBuilder(
//               animation: _animation,
//               builder: (context, child) {
//                 return LinearProgressIndicator(
//                   value: _animation.value,
//                   backgroundColor: Colors.transparent,
//                   valueColor: const AlwaysStoppedAnimation<Color>(
//                     ProfessionalColors.accentBlue,
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







// // // Professional Movies Grid View
// // class ProfessionalMoviesGridView extends StatefulWidget {
// //   final List<Movie> moviesList;
// //   final String categoryTitle;

// //   const ProfessionalMoviesGridView({
// //     Key? key,
// //     required this.moviesList,
// //     required this.categoryTitle,
// //   }) : super(key: key);

// //   @override
// //   _ProfessionalMoviesGridViewState createState() =>
// //       _ProfessionalMoviesGridViewState();
// // }

// // class _ProfessionalMoviesGridViewState extends State<ProfessionalMoviesGridView>
// //     with TickerProviderStateMixin {
// //   late Map<String, FocusNode> _movieFocusNodes;
// //   bool _isLoading = false;

// //   // Animation Controllers
// //   late AnimationController _fadeController;
// //   late AnimationController _staggerController;
// //   late Animation<double> _fadeAnimation;

// //   @override
// //   void initState() {
// //     super.initState();

// //     _movieFocusNodes = {
// //       for (var movie in widget.moviesList) movie.id.toString(): FocusNode()
// //     };

// //     // Set up focus for the first movie
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (widget.moviesList.isNotEmpty) {
// //         final firstMovieId = widget.moviesList[0].id.toString();
// //         if (_movieFocusNodes.containsKey(firstMovieId)) {
// //           FocusScope.of(context).requestFocus(_movieFocusNodes[firstMovieId]);
// //         }
// //       }
// //     });

// //     _initializeAnimations();
// //     _startStaggeredAnimation();
// //   }

// //   void _initializeAnimations() {
// //     _fadeController = AnimationController(
// //       duration: const Duration(milliseconds: 600),
// //       vsync: this,
// //     );

// //     _staggerController = AnimationController(
// //       duration: const Duration(milliseconds: 1200),
// //       vsync: this,
// //     );

// //     _fadeAnimation = Tween<double>(
// //       begin: 0.0,
// //       end: 1.0,
// //     ).animate(CurvedAnimation(
// //       parent: _fadeController,
// //       curve: Curves.easeInOut,
// //     ));
// //   }

// //   void _startStaggeredAnimation() {
// //     _fadeController.forward();
// //     _staggerController.forward();
// //   }

// //   Future<void> _handleGridMovieTap(Movie movie) async {
// //     if (_isLoading || !mounted) return;

// //     setState(() {
// //       _isLoading = true;
// //     });

// //     bool dialogShown = false;
// //     try {
// //       if (mounted) {
// //         dialogShown = true;
// //         showDialog(
// //           context: context,
// //           barrierDismissible: false,
// //           builder: (BuildContext context) {
// //             return WillPopScope(
// //               onWillPop: () async {
// //                 setState(() {
// //                   _isLoading = false;
// //                 });
// //                 return true;
// //               },
// //               child: Center(
// //                 child: Container(
// //                   padding: const EdgeInsets.all(24),
// //                   decoration: BoxDecoration(
// //                     color: Colors.black.withOpacity(0.85),
// //                     borderRadius: BorderRadius.circular(20),
// //                     border: Border.all(
// //                       color: ProfessionalColors.accentBlue.withOpacity(0.3),
// //                       width: 1,
// //                     ),
// //                   ),
// //                   child: Column(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       Container(
// //                         width: 60,
// //                         height: 60,
// //                         child: const CircularProgressIndicator(
// //                           strokeWidth: 4,
// //                           valueColor: AlwaysStoppedAnimation<Color>(
// //                             ProfessionalColors.accentBlue,
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 20),
// //                       const Text(
// //                         'Loading Movie...',
// //                         style: TextStyle(
// //                           color: Colors.white,
// //                           fontSize: 18,
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 8),
// //                       const Text(
// //                         'Please wait',
// //                         style: TextStyle(
// //                           color: ProfessionalColors.textSecondary,
// //                           fontSize: 14,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             );
// //           },
// //         );
// //       }

// //       if (mounted) {
// //         if (dialogShown) {
// //           Navigator.of(context, rootNavigator: true).pop();
// //         }

// // // ProfessionalMoviesGridView class में helper method add करें
// //         List<NewsItemModel> _convertMoviesToNewsItems(List<Movie> movies) {
// //           return movies
// //               .map((movie) => NewsItemModel(
// //                     id: movie.id.toString(),
// //                     contentId: movie.id.toString(),
// //                     name: movie.name,
// //                     banner: movie.banner ?? movie.poster ?? '',
// //                     image: movie.poster ?? '',
// //                     url: movie.movieUrl,
// //                     unUpdatedUrl: movie.movieUrl,
// //                     contentType: '1', // Movie type
// //                     streamType: movie.sourceType,
// //                     liveStatus: false,
// //                     videoId: movie.id.toString(),
// //                     poster: movie.poster ?? movie.banner ?? '',
// //                     // Add other required fields as needed
// //                   ))
// //               .toList();
// //         }

// // // _handleGridMovieTap में use करें
// //         if (isYoutubeUrl(movie.movieUrl)) {
// //           await Navigator.push(
// //             context,
// //             MaterialPageRoute(
// //               // builder: (context) => VideoScreen(
// //               //   videoUrl: movie.movieUrl,
// //               //   bannerImageUrl: movie.banner ?? movie.poster ?? '',
// //               //   startAtPosition: Duration.zero,
// //               //   videoType: movie.sourceType,
// //               //   channelList: _convertMoviesToNewsItems(widget.moviesList), // ✅ Convert and send
// //               //   isLive: false,
// //               //   isVOD: true,
// //               //   isBannerSlider: false,
// //               //   source: 'isMovieScreen',
// //               //   isSearch: false,
// //               //   videoId: movie.id,
// //               //   unUpdatedUrl: movie.movieUrl,
// //               //   name: movie.name,
// //               //   seasonId: null,
// //               //   isLastPlayedStored: true,
// //               //   liveStatus: false,
// //               // ),
// //               builder: (context) => CustomYoutubePlayer(
// //                 videoUrl: movie.movieUrl,
// //                 name: movie.name,
// //               ),
// //             ),
// //           );
// //         } else {
// //           await Navigator.push(
// //             context,
// //             MaterialPageRoute(
// //               // builder: (context) => VideoScreen(
// //               //   videoUrl: movie.movieUrl,
// //               //   bannerImageUrl: movie.banner ?? movie.poster ?? '',
// //               //   startAtPosition: Duration.zero,
// //               //   videoType: movie.sourceType,
// //               //   channelList: _convertMoviesToNewsItems(widget.moviesList), // ✅ Convert and send
// //               //   isLive: false,
// //               //   isVOD: true,
// //               //   isBannerSlider: false,
// //               //   source: 'isMovieScreen',
// //               //   isSearch: false,
// //               //   videoId: movie.id,
// //               //   unUpdatedUrl: movie.movieUrl,
// //               //   name: movie.name,
// //               //   seasonId: null,
// //               //   isLastPlayedStored: true,
// //               //   liveStatus: false,
// //               // ),
// //               builder: (context) => CustomVideoPlayer(
// //                 videoUrl: movie.movieUrl,
// //               ),
// //             ),
// //           );
// //         }
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         if (dialogShown) {
// //           Navigator.of(context, rootNavigator: true).pop();
// //         }

// //         // ✅ Enhanced error handling for grid view
// //         String errorMessage = 'Error loading movie';
// //         if (e.toString().contains('network') ||
// //             e.toString().contains('connection')) {
// //           errorMessage = 'Network error. Please check your connection';
// //         } else if (e.toString().contains('format') ||
// //             e.toString().contains('codec')) {
// //           errorMessage = 'Video format not supported';
// //         } else if (e.toString().contains('not found') ||
// //             e.toString().contains('404')) {
// //           errorMessage = 'Movie not found or unavailable';
// //         }

// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text(errorMessage),
// //             backgroundColor: ProfessionalColors.accentRed,
// //             behavior: SnackBarBehavior.floating,
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(10),
// //             ),
// //             action: SnackBarAction(
// //               label: 'Retry',
// //               textColor: Colors.white,
// //               onPressed: () => _handleGridMovieTap(movie),
// //             ),
// //           ),
// //         );
// //       }
// //     } finally {
// //       if (mounted) {
// //         setState(() {
// //           _isLoading = false;
// //         });
// //       }
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _fadeController.dispose();
// //     _staggerController.dispose();
// //     for (var node in _movieFocusNodes.values) {
// //       try {
// //         node.dispose();
// //       } catch (e) {}
// //     }
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: ProfessionalColors.primaryDark,
// //       body: Stack(
// //         children: [
// //           // Background Gradient
// //           Container(
// //             decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.topCenter,
// //                 end: Alignment.bottomCenter,
// //                 colors: [
// //                   ProfessionalColors.primaryDark,
// //                   ProfessionalColors.surfaceDark.withOpacity(0.8),
// //                   ProfessionalColors.primaryDark,
// //                 ],
// //               ),
// //             ),
// //           ),

// //           // Main Content
// //           FadeTransition(
// //             opacity: _fadeAnimation,
// //             child: Column(
// //               children: [
// //                 _buildProfessionalAppBar(),
// //                 Expanded(
// //                   child: _buildMoviesGrid(),
// //                 ),
// //               ],
// //             ),
// //           ),

// //           // Loading Overlay
// //           if (_isLoading)
// //             Container(
// //               color: Colors.black.withOpacity(0.7),
// //               child: const Center(
// //                 child:
// //                     ProfessionalLoadingIndicator(message: 'Loading Movie...'),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildProfessionalAppBar() {
// //     return Container(
// //       padding: EdgeInsets.only(
// //         top: MediaQuery.of(context).padding.top + 10,
// //         left: 20,
// //         right: 20,
// //         bottom: 20,
// //       ),
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.topCenter,
// //           end: Alignment.bottomCenter,
// //           colors: [
// //             ProfessionalColors.surfaceDark.withOpacity(0.9),
// //             ProfessionalColors.surfaceDark.withOpacity(0.7),
// //             Colors.transparent,
// //           ],
// //         ),
// //       ),
// //       child: Row(
// //         children: [
// //           Container(
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               gradient: LinearGradient(
// //                 colors: [
// //                   ProfessionalColors.accentBlue.withOpacity(0.2),
// //                   ProfessionalColors.accentPurple.withOpacity(0.2),
// //                 ],
// //               ),
// //             ),
// //             child: IconButton(
// //               icon: const Icon(
// //                 Icons.arrow_back_rounded,
// //                 color: Colors.white,
// //                 size: 24,
// //               ),
// //               onPressed: () => Navigator.pop(context),
// //             ),
// //           ),
// //           const SizedBox(width: 16),
// //           Expanded(
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 ShaderMask(
// //                   shaderCallback: (bounds) => const LinearGradient(
// //                     colors: [
// //                       ProfessionalColors.accentBlue,
// //                       ProfessionalColors.accentPurple,
// //                     ],
// //                   ).createShader(bounds),
// //                   child: Text(
// //                     widget.categoryTitle,
// //                     style: TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 24,
// //                       fontWeight: FontWeight.w700,
// //                       letterSpacing: 1.0,
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 4),
// //                 Container(
// //                   padding:
// //                       const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// //                   decoration: BoxDecoration(
// //                     gradient: LinearGradient(
// //                       colors: [
// //                         ProfessionalColors.accentBlue.withOpacity(0.2),
// //                         ProfessionalColors.accentPurple.withOpacity(0.1),
// //                       ],
// //                     ),
// //                     borderRadius: BorderRadius.circular(15),
// //                     border: Border.all(
// //                       color: ProfessionalColors.accentBlue.withOpacity(0.3),
// //                       width: 1,
// //                     ),
// //                   ),
// //                   child: Text(
// //                     '${widget.moviesList.length} Movies Available',
// //                     style: const TextStyle(
// //                       color: ProfessionalColors.accentBlue,
// //                       fontSize: 12,
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildMoviesGrid() {
// //     if (widget.moviesList.isEmpty) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Container(
// //               width: 80,
// //               height: 80,
// //               decoration: BoxDecoration(
// //                 shape: BoxShape.circle,
// //                 gradient: LinearGradient(
// //                   colors: [
// //                     ProfessionalColors.accentBlue.withOpacity(0.2),
// //                     ProfessionalColors.accentBlue.withOpacity(0.1),
// //                   ],
// //                 ),
// //               ),
// //               child: const Icon(
// //                 Icons.movie_outlined,
// //                 size: 40,
// //                 color: ProfessionalColors.accentBlue,
// //               ),
// //             ),
// //             const SizedBox(height: 24),
// //             Text(
// //               'No ${widget.categoryTitle} Found',
// //               style: TextStyle(
// //                 color: ProfessionalColors.textPrimary,
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.w600,
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             const Text(
// //               'Check back later for new content',
// //               style: TextStyle(
// //                 color: ProfessionalColors.textSecondary,
// //                 fontSize: 14,
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     }

// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 20),
// //       child: GridView.builder(
// //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //           crossAxisCount: 6,
// //           mainAxisSpacing: 16,
// //           crossAxisSpacing: 16,
// //           childAspectRatio: 1.5,
// //         ),
// //         itemCount: widget.moviesList.length,
// //         clipBehavior: Clip.none,
// //         itemBuilder: (context, index) {
// //           final movie = widget.moviesList[index];
// //           String movieId = movie.id.toString();

// //           return AnimatedBuilder(
// //             animation: _staggerController,
// //             builder: (context, child) {
// //               final delay = (index / widget.moviesList.length) * 0.5;
// //               final animationValue = Interval(
// //                 delay,
// //                 delay + 0.5,
// //                 curve: Curves.easeOutCubic,
// //               ).transform(_staggerController.value);

// //               return Transform.translate(
// //                 offset: Offset(0, 50 * (1 - animationValue)),
// //                 child: Opacity(
// //                   opacity: animationValue,
// //                   child: ProfessionalGridMovieCard(
// //                     movie: movie,
// //                     focusNode: _movieFocusNodes[movieId]!,
// //                     onTap: () => _handleGridMovieTap(movie),
// //                     index: index,
// //                     categoryTitle: widget.categoryTitle,
// //                   ),
// //                 ),
// //               );
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }

// // ✅ COMPLETE: Professional Movies Grid View with VOD Style Scrolling
// class ProfessionalMoviesGridView extends StatefulWidget {
//   final List<Movie> moviesList;
//   final String categoryTitle;

//   const ProfessionalMoviesGridView({
//     Key? key,
//     required this.moviesList,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalMoviesGridViewState createState() =>
//       _ProfessionalMoviesGridViewState();
// }

// class _ProfessionalMoviesGridViewState extends State<ProfessionalMoviesGridView>
//     with TickerProviderStateMixin {
  
//   // ✅ Focus Management with Scrolling
//   Map<String, FocusNode> _movieFocusNodes = {};
//   bool _isLoading = false;
//   int gridFocusedIndex = 0;
//   final int columnsCount = 6;
//   late ScrollController _scrollController;

//   // Animation Controllers
//   late AnimationController _fadeController;
//   late AnimationController _staggerController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
    
//     // ✅ Initialize ScrollController
//     _scrollController = ScrollController();

//     // ✅ Initialize focus nodes with scroll listeners
//     _initializeMovieFocusNodes();

//     // Set up focus for the first movie
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusFirstGridItem();
//     });

//     _initializeAnimations();
//     _startStaggeredAnimation();
//   }

//   // ✅ Initialize focus nodes with scroll functionality (same as VOD)
//   void _initializeMovieFocusNodes() {
//     // Safely dispose existing nodes first
//     for (var entry in _movieFocusNodes.entries) {
//       try {
//         entry.value.removeListener(() {});
//         entry.value.dispose();
//       } catch (e) {
//         print('⚠️ Error disposing movie focus node ${entry.key}: $e');
//       }
//     }

//     _movieFocusNodes.clear();

//     // Create focus nodes for all movies with String keys
//     for (int i = 0; i < widget.moviesList.length; i++) {
//       String movieId = widget.moviesList[i].id.toString();
//       _movieFocusNodes[movieId] = FocusNode()
//         ..addListener(() {
//           if (mounted && _movieFocusNodes[movieId]!.hasFocus) {
//             setState(() {
//               gridFocusedIndex = i;
//             });
//             _scrollToFocusedItem(movieId);
//           }
//         });
//     }

//     print('✅ Created ${_movieFocusNodes.length} movie grid focus nodes');
//   }

//   // ✅ Focus first grid item (same as VOD)
//   void _focusFirstGridItem() {
//     if (widget.moviesList.isNotEmpty && _movieFocusNodes.isNotEmpty) {
//       final firstMovieId = widget.moviesList[0].id.toString();
//       if (_movieFocusNodes.containsKey(firstMovieId)) {
//         try {
//           setState(() {
//             gridFocusedIndex = 0;
//           });
//           FocusScope.of(context).requestFocus(_movieFocusNodes[firstMovieId]);
//           print('✅ Focus set to first movie grid item: $firstMovieId');
//         } catch (e) {
//           print('⚠️ Error setting initial movie grid focus: $e');
//         }
//       }
//     }
//   }

//   // ✅ Scroll to focused item (exactly like VOD)
//   void _scrollToFocusedItem(String itemId) {
//     if (!mounted) return;

//     try {
//       final focusNode = _movieFocusNodes[itemId];
//       if (focusNode != null &&
//           focusNode.hasFocus &&
//           focusNode.context != null) {
//         Scrollable.ensureVisible(
//           focusNode.context!,
//           alignment: 0.1, // Keep focused item visible
//           duration: AnimationTiming.scroll,
//           curve: Curves.easeInOutCubic,
//         );
//       }
//     } catch (e) {
//       print('⚠️ Error scrolling to focused movie item: $e');
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

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   void _startStaggeredAnimation() {
//     _fadeController.forward();
//     _staggerController.forward();
//   }

//   // ✅ Enhanced Grid Navigation (same as VOD)
//   void _navigateGrid(LogicalKeyboardKey key) {
//     if (_isLoading) return;

//     int newIndex = gridFocusedIndex;
//     final int totalItems = widget.moviesList.length;
//     final int currentRow = gridFocusedIndex ~/ columnsCount;
//     final int currentCol = gridFocusedIndex % columnsCount;

//     switch (key) {
//       case LogicalKeyboardKey.arrowRight:
//         if (gridFocusedIndex < totalItems - 1) {
//           newIndex = gridFocusedIndex + 1;
//         }
//         break;

//       case LogicalKeyboardKey.arrowLeft:
//         if (gridFocusedIndex > 0) {
//           newIndex = gridFocusedIndex - 1;
//         }
//         break;

//       case LogicalKeyboardKey.arrowDown:
//         final int nextRowIndex = (currentRow + 1) * columnsCount + currentCol;
//         if (nextRowIndex < totalItems) {
//           newIndex = nextRowIndex;
//         } else {
//           final int lastRowStartIndex = ((totalItems - 1) ~/ columnsCount) * columnsCount;
//           final int targetIndex = lastRowStartIndex + currentCol;
//           if (targetIndex < totalItems) {
//             newIndex = targetIndex;
//           } else {
//             newIndex = totalItems - 1;
//           }
//         }
//         break;

//       case LogicalKeyboardKey.arrowUp:
//         if (currentRow > 0) {
//           final int prevRowIndex = (currentRow - 1) * columnsCount + currentCol;
//           newIndex = prevRowIndex;
//         }
//         break;
//     }

//     if (newIndex != gridFocusedIndex && newIndex >= 0 && newIndex < totalItems) {
//       final newMovieId = widget.moviesList[newIndex].id.toString();
//       if (_movieFocusNodes.containsKey(newMovieId)) {
//         setState(() {
//           gridFocusedIndex = newIndex;
//         });
//         FocusScope.of(context).requestFocus(_movieFocusNodes[newMovieId]);
//         HapticFeedback.lightImpact();
//         print('🎯 Navigated to movie grid item $newIndex');
//       }
//     }
//   }

//   Future<void> _handleGridMovieTap(Movie movie) async {
//     if (_isLoading || !mounted) return;

//     setState(() {
//       _isLoading = true;
//     });

//     bool dialogShown = false;
//     try {
//       if (mounted) {
//         dialogShown = true;
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (BuildContext context) {
//             return WillPopScope(
//               onWillPop: () async {
//                 setState(() {
//                   _isLoading = false;
//                 });
//                 return true;
//               },
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.85),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                       color: ProfessionalColors.accentBlue.withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 60,
//                         height: 60,
//                         child: const CircularProgressIndicator(
//                           strokeWidth: 4,
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             ProfessionalColors.accentBlue,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         'Loading Movie...',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Please wait',
//                         style: TextStyle(
//                           color: ProfessionalColors.textSecondary,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       }

//       if (mounted) {
//         if (dialogShown) {
//           Navigator.of(context, rootNavigator: true).pop();
//         }

//         List<NewsItemModel> _convertMoviesToNewsItems(List<Movie> movies) {
//           return movies
//               .map((movie) => NewsItemModel(
//                     id: movie.id.toString(),
//                     contentId: movie.id.toString(),
//                     name: movie.name,
//                     banner: movie.banner ?? movie.poster ?? '',
//                     image: movie.poster ?? '',
//                     url: movie.movieUrl,
//                     unUpdatedUrl: movie.movieUrl,
//                     contentType: '1',
//                     streamType: movie.sourceType,
//                     liveStatus: false,
//                     videoId: movie.id.toString(),
//                     poster: movie.poster ?? movie.banner ?? '',
//                   ))
//               .toList();
//         }

//         if (isYoutubeUrl(movie.movieUrl)) {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => CustomYoutubePlayer(
//                 videoUrl: movie.movieUrl,
//                 name: movie.name,
//               ),
//             ),
//           );
//         } else {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => CustomVideoPlayer(
//                 videoUrl: movie.movieUrl,
//               ),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         if (dialogShown) {
//           Navigator.of(context, rootNavigator: true).pop();
//         }

//         String errorMessage = 'Error loading movie';
//         if (e.toString().contains('network') ||
//             e.toString().contains('connection')) {
//           errorMessage = 'Network error. Please check your connection';
//         } else if (e.toString().contains('format') ||
//             e.toString().contains('codec')) {
//           errorMessage = 'Video format not supported';
//         } else if (e.toString().contains('not found') ||
//             e.toString().contains('404')) {
//           errorMessage = 'Movie not found or unavailable';
//         }

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(errorMessage),
//             backgroundColor: ProfessionalColors.accentRed,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             action: SnackBarAction(
//               label: 'Retry',
//               textColor: Colors.white,
//               onPressed: () => _handleGridMovieTap(movie),
//             ),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
        
//         // ✅ Restore focus to the same item after returning
//         Future.delayed(const Duration(milliseconds: 300), () {
//           if (mounted) {
//             final movieIndex = widget.moviesList.indexWhere((m) => m.id == movie.id);
//             if (movieIndex != -1) {
//               final movieId = movie.id.toString();
//               if (_movieFocusNodes.containsKey(movieId)) {
//                 setState(() {
//                   gridFocusedIndex = movieIndex;
//                 });
//                 FocusScope.of(context).requestFocus(_movieFocusNodes[movieId]);
//                 print('✅ Restored movie grid focus to ${movie.name}');
//               }
//             }
//           }
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _staggerController.dispose();
//     _scrollController.dispose(); // ✅ Dispose ScrollController
    
//     // ✅ Safely dispose all focus nodes
//     for (var entry in _movieFocusNodes.entries) {
//       try {
//         entry.value.removeListener(() {});
//         entry.value.dispose();
//         print('✅ Disposed movie grid focus node: ${entry.key}');
//       } catch (e) {
//         print('⚠️ Error disposing movie grid focus node ${entry.key}: $e');
//       }
//     }
//     _movieFocusNodes.clear();
    
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Container(
//         // ✅ Background Gradient like VOD
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               ProfessionalColors.primaryDark,
//               ProfessionalColors.surfaceDark.withOpacity(0.8),
//               ProfessionalColors.primaryDark,
//             ],
//           ),
//         ),
//         child: Stack(
//           children: [
//             // ✅ Main Content with proper padding for AppBar
//             FadeTransition(
//               opacity: _fadeAnimation,
//               child: Column(
//                 children: [
//                   // ✅ AppBar height placeholder to push content down
//                   SizedBox(
//                     height: MediaQuery.of(context).padding.top + 80, // AppBar total height
//                   ),
//                   Expanded(
//                     child: _buildMoviesGrid(),
//                   ),
//                 ],
//               ),
//             ),

//             // ✅ AppBar positioned on top with proper z-index (VOD Style)
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: _buildProfessionalAppBar(),
//             ),

//             // ✅ Loading Overlay - Always on top
//             if (_isLoading)
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black.withOpacity(0.7),
//                   child: const Center(
//                     child: ProfessionalLoadingIndicator(message: 'Loading Movie...'),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ Professional AppBar with VOD Style
//   Widget _buildProfessionalAppBar() {
//     return Container(
//       // ✅ Enhanced AppBar with proper z-index and blur effect
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             ProfessionalColors.primaryDark.withOpacity(0.95), // More opaque
//             ProfessionalColors.surfaceDark.withOpacity(0.9),
//             ProfessionalColors.surfaceDark.withOpacity(0.8),
//             Colors.transparent,
//           ],
//         ),
//         // ✅ Add bottom border for better separation
//         border: Border(
//           bottom: BorderSide(
//             color: ProfessionalColors.accentBlue.withOpacity(0.2), // Movies theme color
//             width: 1,
//           ),
//         ),
//         // ✅ Add subtle shadow
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         child: BackdropFilter(
//           // ✅ Add blur effect for modern look
//           filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
//           child: Container(
//             padding: EdgeInsets.only(
//               top: MediaQuery.of(context).padding.top + 20,
//               left: 40,
//               right: 40,
//               bottom: 5, // Add bottom padding
//             ),
//             child: Row(
//               children: [
//                 // ✅ Back Button with Movies theme colors
//                 Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: LinearGradient(
//                       colors: [
//                         ProfessionalColors.accentBlue.withOpacity(0.3), // Movies theme
//                         ProfessionalColors.accentPurple.withOpacity(0.3),
//                       ],
//                     ),
//                     // ✅ Add elevation to back button
//                     boxShadow: [
//                       BoxShadow(
//                         color: ProfessionalColors.accentBlue.withOpacity(0.3),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: IconButton(
//                     icon: const Icon(
//                       Icons.arrow_back_rounded,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // ✅ Title with Movies theme colors and better shadow
//                       ShaderMask(
//                         shaderCallback: (bounds) => const LinearGradient(
//                           colors: [
//                             ProfessionalColors.accentBlue, // Movies theme
//                             ProfessionalColors.accentPurple,
//                           ],
//                         ).createShader(bounds),
//                         child: Text(
//                           widget.categoryTitle,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 24,
//                             fontWeight: FontWeight.w700,
//                             letterSpacing: 1.0,
//                             shadows: [
//                               Shadow(
//                                 color: Colors.black.withOpacity(0.5),
//                                 blurRadius: 4,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       // ✅ Count badge with Movies theme colors and elevation
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               ProfessionalColors.accentBlue.withOpacity(0.3), // Movies theme
//                               ProfessionalColors.accentPurple.withOpacity(0.2),
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(15),
//                           border: Border.all(
//                             color: ProfessionalColors.accentBlue.withOpacity(0.4),
//                             width: 1,
//                           ),
//                           // ✅ Add elevation to count badge
//                           boxShadow: [
//                             BoxShadow(
//                               color: ProfessionalColors.accentBlue.withOpacity(0.2),
//                               blurRadius: 6,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Text(
//                           '${widget.moviesList.length} Movies Available',
//                           style: const TextStyle(
//                             color: ProfessionalColors.accentBlue, // Movies theme
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             shadows: [
//                               Shadow(
//                                 color: Colors.black54,
//                                 blurRadius: 2,
//                                 offset: Offset(0, 1),
//                               ),
//                             ],
//                           ),
//                         ),
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

//   Widget _buildMoviesGrid() {
//     if (widget.moviesList.isEmpty) {
//       return Center(
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
//                     ProfessionalColors.accentBlue.withOpacity(0.2),
//                     ProfessionalColors.accentBlue.withOpacity(0.1),
//                   ],
//                 ),
//               ),
//               child: const Icon(
//                 Icons.movie_outlined,
//                 size: 40,
//                 color: ProfessionalColors.accentBlue,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'No ${widget.categoryTitle} Found',
//               style: TextStyle(
//                 color: ProfessionalColors.textPrimary,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Check back later for new content',
//               style: TextStyle(
//                 color: ProfessionalColors.textSecondary,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return Focus(
//       autofocus: true,
//       onKey: (node, event) {
//         if (event is RawKeyDownEvent && !_isLoading) {
//           if ([
//             LogicalKeyboardKey.arrowUp,
//             LogicalKeyboardKey.arrowDown,
//             LogicalKeyboardKey.arrowLeft,
//             LogicalKeyboardKey.arrowRight,
//           ].contains(event.logicalKey)) {
//             _navigateGrid(event.logicalKey);
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//                      event.logicalKey == LogicalKeyboardKey.select) {
//             if (gridFocusedIndex < widget.moviesList.length) {
//               _handleGridMovieTap(widget.moviesList[gridFocusedIndex]);
//             }
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: GridView.builder(
//           controller: _scrollController, // ✅ Added ScrollController
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 6,
//             mainAxisSpacing: 16,
//             crossAxisSpacing: 16,
//             childAspectRatio: 1.5,
//           ),
//           itemCount: widget.moviesList.length,
//           clipBehavior: Clip.none, // ✅ Allow shadows to be visible
//           itemBuilder: (context, index) {
//             final movie = widget.moviesList[index];
//             String movieId = movie.id.toString();

//             // ✅ Safe check for focus node existence
//             if (!_movieFocusNodes.containsKey(movieId)) {
//               print('⚠️ Movie grid focus node not found for Movie: $movieId');
//               return const SizedBox.shrink();
//             }

//             return AnimatedBuilder(
//               animation: _staggerController,
//               builder: (context, child) {
//                 final delay = (index / widget.moviesList.length) * 0.5;
//                 final animationValue = Interval(
//                   delay,
//                   delay + 0.5,
//                   curve: Curves.easeOutCubic,
//                 ).transform(_staggerController.value);

//                 return Transform.translate(
//                   offset: Offset(0, 50 * (1 - animationValue)),
//                   child: Opacity(
//                     opacity: animationValue,
//                     child: ProfessionalGridMovieCard(
//                       movie: movie,
//                       focusNode: _movieFocusNodes[movieId]!,
//                       onTap: () => _handleGridMovieTap(movie),
//                       index: index,
//                       categoryTitle: widget.categoryTitle,
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }


// //   Widget _buildMoviesGrid() {
// //     if (widget.moviesList.isEmpty) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Container(
// //               width: 80,
// //               height: 80,
// //               decoration: BoxDecoration(
// //                 shape: BoxShape.circle,
// //                 gradient: LinearGradient(
// //                   colors: [
// //                     ProfessionalColors.accentBlue.withOpacity(0.2),
// //                     ProfessionalColors.accentBlue.withOpacity(0.1),
// //                   ],
// //                 ),
// //               ),
// //               child: const Icon(
// //                 Icons.movie_outlined,
// //                 size: 40,
// //                 color: ProfessionalColors.accentBlue,
// //               ),
// //             ),
// //             const SizedBox(height: 24),
// //             Text(
// //               'No ${widget.categoryTitle} Found',
// //               style: TextStyle(
// //                 color: ProfessionalColors.textPrimary,
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.w600,
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             const Text(
// //               'Check back later for new content',
// //               style: TextStyle(
// //                 color: ProfessionalColors.textSecondary,
// //                 fontSize: 14,
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     }

// //     return Focus(
// //       autofocus: true,
// //       onKey: (node, event) {
// //         if (event is RawKeyDownEvent && !_isLoading) {
// //           if ([
// //             LogicalKeyboardKey.arrowUp,
// //             LogicalKeyboardKey.arrowDown,
// //             LogicalKeyboardKey.arrowLeft,
// //             LogicalKeyboardKey.arrowRight,
// //           ].contains(event.logicalKey)) {
// //             _navigateGrid(event.logicalKey);
// //             return KeyEventResult.handled;
// //           } else if (event.logicalKey == LogicalKeyboardKey.enter ||
// //                      event.logicalKey == LogicalKeyboardKey.select) {
// //             if (gridFocusedIndex < widget.moviesList.length) {
// //               _handleGridMovieTap(widget.moviesList[gridFocusedIndex]);
// //             }
// //             return KeyEventResult.handled;
// //           }
// //         }
// //         return KeyEventResult.ignored;
// //       },
// //       child: Padding(
// //         padding: const EdgeInsets.all(20),
// //         child: GridView.builder(
// //           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //             crossAxisCount: 6,
// //             mainAxisSpacing: 16,
// //             crossAxisSpacing: 16,
// //             childAspectRatio: 1.5,
// //           ),
// //           itemCount: widget.moviesList.length,
// //           clipBehavior: Clip.none, // ✅ Allow shadows to be visible
// //           itemBuilder: (context, index) {
// //             final movie = widget.moviesList[index];
// //             String movieId = movie.id.toString();

// //             // ✅ Safe check for focus node existence
// //             if (!_movieFocusNodes.containsKey(movieId)) {
// //               print('⚠️ Grid focus node not found for Movie: $movieId');
// //               return const SizedBox.shrink();
// //             }

// //             return AnimatedBuilder(
// //               animation: _staggerController,
// //               builder: (context, child) {
// //                 final delay = (index / widget.moviesList.length) * 0.5;
// //                 final animationValue = Interval(
// //                   delay,
// //                   delay + 0.5,
// //                   curve: Curves.easeOutCubic,
// //                 ).transform(_staggerController.value);

// //                 return Transform.translate(
// //                   offset: Offset(0, 50 * (1 - animationValue)),
// //                   child: Opacity(
// //                     opacity: animationValue,
// //                     child: ProfessionalGridMovieCard(
// //                       movie: movie,
// //                       focusNode: _movieFocusNodes[movieId]!,
// //                       onTap: () => _handleGridMovieTap(movie),
// //                       index: index,
// //                       categoryTitle: widget.categoryTitle,
// //                     ),
// //                   ),
// //                 );
// //               },
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }
// // }



// // Professional Grid Movie Card
// class ProfessionalGridMovieCard extends StatefulWidget {
//   final Movie movie;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalGridMovieCard({
//     Key? key,
//     required this.movie,
//     required this.focusNode,
//     required this.onTap,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalGridMovieCardState createState() =>
//       _ProfessionalGridMovieCardState();
// }

// class _ProfessionalGridMovieCardState extends State<ProfessionalGridMovieCard>
//     with TickerProviderStateMixin {
//   late AnimationController _hoverController;
//   late AnimationController _glowController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;

//   Color _dominantColor = ProfessionalColors.accentBlue;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();

//     _hoverController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _glowController = AnimationController(
//       duration: AnimationTiming.medium,
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.05,
//     ).animate(CurvedAnimation(
//       parent: _hoverController,
//       curve: Curves.easeOutCubic,
//     ));

//     _glowAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _glowController,
//       curve: Curves.easeInOut,
//     ));

//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     setState(() {
//       _isFocused = widget.focusNode.hasFocus;
//     });

//     if (_isFocused) {
//       _hoverController.forward();
//       _glowController.forward();
//       _generateDominantColor();
//       HapticFeedback.lightImpact();
//     } else {
//       _hoverController.reverse();
//       _glowController.reverse();
//     }
//   }

//   void _generateDominantColor() {
//     final colors = ProfessionalColors.gradientColors;
//     _dominantColor = colors[math.Random().nextInt(colors.length)];
//   }

//   @override
//   void dispose() {
//     _hoverController.dispose();
//     _glowController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Focus(
//       focusNode: widget.focusNode,
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
//           animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
//           builder: (context, child) {
//             return Transform.scale(
//               scale: _scaleAnimation.value,
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: [
//                     if (_isFocused) ...[
//                       BoxShadow(
//                         color: _dominantColor.withOpacity(0.4),
//                         blurRadius: 20,
//                         spreadRadius: 2,
//                         offset: const Offset(0, 8),
//                       ),
//                       BoxShadow(
//                         color: _dominantColor.withOpacity(0.2),
//                         blurRadius: 35,
//                         spreadRadius: 4,
//                         offset: const Offset(0, 12),
//                       ),
//                     ] else ...[
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.3),
//                         blurRadius: 8,
//                         spreadRadius: 1,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: Stack(
//                     children: [
//                       _buildMovieImage(),
//                       if (_isFocused) _buildFocusBorder(),
//                       _buildGradientOverlay(),
//                       _buildMovieInfo(),
//                       if (_isFocused) _buildPlayButton(),
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

//   Widget _buildMovieImage() {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       child: widget.movie.banner != null && widget.movie.banner!.isNotEmpty
//           ? Image.network(
//               widget.movie.banner!,
//               fit: BoxFit.cover,
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return _buildImagePlaceholder();
//               },
//               errorBuilder: (context, error, stackTrace) =>
//                   _buildImagePlaceholder(),
//             )
//           : _buildImagePlaceholder(),
//     );
//   }

//   Widget _buildImagePlaceholder() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             ProfessionalColors.cardDark,
//             ProfessionalColors.surfaceDark,
//           ],
//         ),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.movie_outlined,
//               size: 40,
//               color: ProfessionalColors.textSecondary,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               widget.categoryTitle,
//               style: TextStyle(
//                 color: ProfessionalColors.textSecondary,
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//               decoration: BoxDecoration(
//                 color: ProfessionalColors.accentBlue.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: const Text(
//                 'HD',
//                 style: TextStyle(
//                   color: ProfessionalColors.accentBlue,
//                   fontSize: 8,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFocusBorder() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(
//             width: 3,
//             color: _dominantColor,
//           ),
//         ),
//       ),
//     );
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
//               Colors.transparent,
//               Colors.black.withOpacity(0.7),
//               Colors.black.withOpacity(0.9),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMovieInfo() {
//     final movieName = widget.movie.name;

//     return Positioned(
//       bottom: 0,
//       left: 0,
//       right: 0,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               movieName.toUpperCase(),
//               style: TextStyle(
//                 color: _isFocused ? _dominantColor : Colors.white,
//                 fontSize: _isFocused ? 13 : 12,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 0.5,
//                 shadows: [
//                   Shadow(
//                     color: Colors.black.withOpacity(0.8),
//                     blurRadius: 4,
//                     offset: const Offset(0, 1),
//                   ),
//                 ],
//               ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             if (_isFocused) ...[
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   if (widget.movie.runtime != null)
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: ProfessionalColors.accentGreen.withOpacity(0.3),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color:
//                               ProfessionalColors.accentGreen.withOpacity(0.5),
//                           width: 1,
//                         ),
//                       ),
//                       child: Text(
//                         '${widget.movie.runtime}m',
//                         style: const TextStyle(
//                           color: ProfessionalColors.accentGreen,
//                           fontSize: 8,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   const SizedBox(width: 8),
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: _dominantColor.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: _dominantColor.withOpacity(0.4),
//                         width: 1,
//                       ),
//                     ),
//                     child: Text(
//                       'HD',
//                       style: TextStyle(
//                         color: _dominantColor,
//                         fontSize: 8,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPlayButton() {
//     return Positioned(
//       top: 12,
//       right: 12,
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: _dominantColor.withOpacity(0.9),
//           boxShadow: [
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.4),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: const Icon(
//           Icons.play_arrow_rounded,
//           color: Colors.white,
//           size: 24,
//         ),
//       ),
//     );
//   }
// }

// // Main Movies Screen
// class MoviesScreen extends StatefulWidget {
//   @override
//   _MoviesScreenState createState() => _MoviesScreenState();
// }

// class _MoviesScreenState extends State<MoviesScreen> {
//   final FocusNode _moviesFocusNode = FocusNode();

//   @override
//   void dispose() {
//     _moviesFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: SafeArea(
//         child: ProfessionalMoviesHorizontalList(
//           focusNode: _moviesFocusNode,
//           displayTitle: "RECENTLY ADDED",
//           navigationIndex: 3, // Adjust based on your navigation structure
//           onFocusChange: (bool hasFocus) {
//             // Handle focus change if needed
//             print('Movies section focus: $hasFocus');
//           },
//         ),
//       ),
//     );
//   }
// }





import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/video_widget/custom_video_player.dart';
import 'package:mobi_tv_entertainment/video_widget/device_detector_firestick.dart';
import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player.dart';

import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

bool isYoutubeUrl(String? url) {
  if (url == null || url.isEmpty) {
    return false;
  }

  url = url.toLowerCase().trim();

  // First check if it's a YouTube ID (exactly 11 characters)
  bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url);
  if (isYoutubeId) {
    return true;
  }

  // Then check for regular YouTube URLs
  bool isYoutubeUrl = url.contains('youtube.com') ||
      url.contains('youtu.be') ||
      url.contains('youtube.com/shorts/');
  if (isYoutubeUrl) {
    return true;
  }

  return false;
}

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

// Movie Model
class Movie {
  final int id;
  final String name;
  final String description;
  final String genres;
  final String releaseDate;
  final int? runtime;
  final String? poster;
  final String? banner;
  final String sourceType;
  final String movieUrl;
  final List<Network> networks;
  final int status; // 🆕 Add status field

  Movie({
    required this.id,
    required this.name,
    required this.description,
    required this.genres,
    required this.releaseDate,
    this.runtime,
    this.poster,
    this.banner,
    required this.sourceType,
    required this.movieUrl,
    required this.networks,
    required this.status, // 🆕 Add status parameter
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
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
      status: json['status'] ?? 0, // 🆕 Add status from JSON
    );
  }
}

class Network {
  final int id;
  final String name;
  final String logo;

  Network({
    required this.id,
    required this.name,
    required this.logo,
  });

  factory Network.fromJson(Map<String, dynamic> json) {
    return Network(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
    );
  }
}

// 🚀 Enhanced Movie Service with Separate Caching for List and Full Data
class MovieService {
  // Cache keys for list view (limited 8 items)
  static const String _cacheKeyMoviesList = 'cached_movies_list';
  static const String _cacheKeyMoviesListTimestamp = 'cached_movies_list_timestamp';
  
  // Cache keys for full data (all movies)
  static const String _cacheKeyMoviesFull = 'cached_movies_full';
  static const String _cacheKeyMoviesFullTimestamp = 'cached_movies_full_timestamp';
  
  static const String _cacheKeyAuthKey = 'auth_key';

  // Cache duration (in milliseconds) - 1 hour
  static const int _cacheDurationMs = 60 * 60 * 1000; // 1 hour

  /// 🆕 Get movies for list view (limited to 8 items)
  static Future<List<Movie>> getMoviesForList({bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if we should use cache for list
      if (!forceRefresh && await _shouldUseCacheForList(prefs)) {
        print('📦 Loading movies list from cache...');
        final cachedMovies = await _getCachedMoviesList(prefs);
        if (cachedMovies.isNotEmpty) {
          print('✅ Successfully loaded ${cachedMovies.length} movies from list cache');
          _loadFreshListDataInBackground();
          return cachedMovies;
        }
      }

      // Load fresh data for list
      print('🌐 Loading fresh movies list from API...');
      return await _fetchFreshMoviesList(prefs);
    } catch (e) {
      print('❌ Error in getMoviesForList: $e');

      // Try to return cached data as fallback
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedMovies = await _getCachedMoviesList(prefs);
        if (cachedMovies.isNotEmpty) {
          print('🔄 Returning cached list data as fallback');
          return cachedMovies;
        }
      } catch (cacheError) {
        print('❌ List cache fallback also failed: $cacheError');
      }

      throw Exception('Failed to load movies list: $e');
    }
  }

  /// 🆕 Get all movies for grid view (full dataset)
  static Future<List<Movie>> getAllMoviesForGrid({bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if we should use cache for full data
      if (!forceRefresh && await _shouldUseCacheForFull(prefs)) {
        print('📦 Loading full movies from cache...');
        final cachedMovies = await _getCachedMoviesFull(prefs);
        if (cachedMovies.isNotEmpty) {
          print('✅ Successfully loaded ${cachedMovies.length} movies from full cache');
          _loadFreshFullDataInBackground();
          return cachedMovies;
        }
      }

      // Load fresh full data
      print('🌐 Loading fresh full movies from API...');
      return await _fetchFreshMoviesFull(prefs);
    } catch (e) {
      print('❌ Error in getAllMoviesForGrid: $e');

      // Try to return cached data as fallback
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedMovies = await _getCachedMoviesFull(prefs);
        if (cachedMovies.isNotEmpty) {
          print('🔄 Returning cached full data as fallback');
          return cachedMovies;
        }
      } catch (cacheError) {
        print('❌ Full cache fallback also failed: $cacheError');
      }

      throw Exception('Failed to load full movies: $e');
    }
  }

  /// Check if cached list data is still valid
  static Future<bool> _shouldUseCacheForList(SharedPreferences prefs) async {
    return await _shouldUseCache(prefs, _cacheKeyMoviesListTimestamp, 'list');
  }

  /// Check if cached full data is still valid
  static Future<bool> _shouldUseCacheForFull(SharedPreferences prefs) async {
    return await _shouldUseCache(prefs, _cacheKeyMoviesFullTimestamp, 'full');
  }

  /// Generic cache validation method
  static Future<bool> _shouldUseCache(SharedPreferences prefs, String timestampKey, String type) async {
    try {
      final timestampStr = prefs.getString(timestampKey);
      if (timestampStr == null) return false;

      final cachedTimestamp = int.tryParse(timestampStr);
      if (cachedTimestamp == null) return false;

      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      final cacheAge = currentTimestamp - cachedTimestamp;

      final isValid = cacheAge < _cacheDurationMs;

      if (isValid) {
        final ageMinutes = (cacheAge / (1000 * 60)).round();
        print('📦 $type cache is valid (${ageMinutes} minutes old)');
      } else {
        final ageMinutes = (cacheAge / (1000 * 60)).round();
        print('⏰ $type cache expired (${ageMinutes} minutes old)');
      }

      return isValid;
    } catch (e) {
      print('❌ Error checking $type cache validity: $e');
      return false;
    }
  }

  /// Get movies list from cache with status filtering
  static Future<List<Movie>> _getCachedMoviesList(SharedPreferences prefs) async {
    return await _getCachedMovies(prefs, _cacheKeyMoviesList, 'list');
  }

  /// Get full movies from cache with status filtering
  static Future<List<Movie>> _getCachedMoviesFull(SharedPreferences prefs) async {
    return await _getCachedMovies(prefs, _cacheKeyMoviesFull, 'full');
  }

  /// Generic method to get cached movies with status filtering
  static Future<List<Movie>> _getCachedMovies(SharedPreferences prefs, String cacheKey, String type) async {
    try {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData == null || cachedData.isEmpty) {
        print('📦 No cached $type data found');
        return [];
      }

      final List<dynamic> jsonData = json.decode(cachedData);
      
      // 🆕 Filter cached movies with status = 1 only
      final filteredJsonData = jsonData.where((movieJson) {
        final status = movieJson['status'] ?? 0;
        return status == 1;
      }).toList();

      final movies = filteredJsonData
          .map((json) => Movie.fromJson(json as Map<String, dynamic>))
          .toList();

      print('📦 Successfully loaded ${movies.length} active movies from $type cache (filtered from ${jsonData.length} total)');
      return movies;
    } catch (e) {
      print('❌ Error loading cached $type movies: $e');
      return [];
    }
  }

  /// Fetch fresh movies for list (limited to 8) with status filtering
  static Future<List<Movie>> _fetchFreshMoviesList(SharedPreferences prefs) async {
    try {
      String authKey = prefs.getString(_cacheKeyAuthKey) ?? '';

      final response = await http.get(
        Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllMovies?records=8'),
        headers: {'auth-key': authKey},
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);

        List<dynamic> jsonData;
        if (responseBody is List) {
          jsonData = responseBody;
        } else if (responseBody is Map && responseBody['data'] != null) {
          jsonData = responseBody['data'] as List;
        } else {
          throw Exception('Unexpected API response format');
        }

        // 🆕 Filter movies with status = 1 only
        final filteredJsonData = jsonData.where((movieJson) {
          final status = movieJson['status'] ?? 0;
          return status == 1;
        }).toList();

        final movies = filteredJsonData
            .map((json) => Movie.fromJson(json as Map<String, dynamic>))
            .toList();

        // Cache the filtered data
        await _cacheMoviesList(prefs, filteredJsonData);

        print('✅ Successfully loaded ${movies.length} active movies for list from API (filtered from ${jsonData.length} total)');
        return movies;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ Error fetching fresh movies list: $e');
      rethrow;
    }
  }

  /// 🆕 Fetch fresh movies for grid (full dataset - no limit) with status filtering
  static Future<List<Movie>> _fetchFreshMoviesFull(SharedPreferences prefs) async {
    try {
      String authKey = prefs.getString(_cacheKeyAuthKey) ?? '';

      final response = await http.get(
        Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllMovies'), // No records parameter for full data
        headers: {'auth-key': authKey},
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);

        List<dynamic> jsonData;
        if (responseBody is List) {
          jsonData = responseBody;
        } else if (responseBody is Map && responseBody['data'] != null) {
          jsonData = responseBody['data'] as List;
        } else {
          throw Exception('Unexpected API response format');
        }

        // 🆕 Filter movies with status = 1 only
        final filteredJsonData = jsonData.where((movieJson) {
          final status = movieJson['status'] ?? 0;
          return status == 1;
        }).toList();

        final movies = filteredJsonData
            .map((json) => Movie.fromJson(json as Map<String, dynamic>))
            .toList();

        // Cache the filtered full data
        await _cacheMoviesFull(prefs, filteredJsonData);

        print('✅ Successfully loaded ${movies.length} active movies for grid from API (filtered from ${jsonData.length} total)');
        return movies;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ Error fetching fresh movies full: $e');
      rethrow;
    }
  }

  /// Cache movies list data
  static Future<void> _cacheMoviesList(SharedPreferences prefs, List<dynamic> moviesData) async {
    await _cacheMovies(prefs, moviesData, _cacheKeyMoviesList, _cacheKeyMoviesListTimestamp, 'list');
  }

  /// Cache movies full data
  static Future<void> _cacheMoviesFull(SharedPreferences prefs, List<dynamic> moviesData) async {
    await _cacheMovies(prefs, moviesData, _cacheKeyMoviesFull, _cacheKeyMoviesFullTimestamp, 'full');
  }

  /// Generic method to cache movies data
  static Future<void> _cacheMovies(
      SharedPreferences prefs, 
      List<dynamic> moviesData, 
      String dataKey, 
      String timestampKey, 
      String type) async {
    try {
      final jsonString = json.encode(moviesData);
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Save movies data and timestamp
      await Future.wait([
        prefs.setString(dataKey, jsonString),
        prefs.setString(timestampKey, currentTimestamp),
      ]);

      print('💾 Successfully cached ${moviesData.length} $type movies');
    } catch (e) {
      print('❌ Error caching $type movies: $e');
    }
  }

  /// Load fresh list data in background
  static void _loadFreshListDataInBackground() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        print('🔄 Loading fresh list data in background...');
        final prefs = await SharedPreferences.getInstance();
        await _fetchFreshMoviesList(prefs);
        print('✅ Background list refresh completed');
      } catch (e) {
        print('⚠️ Background list refresh failed: $e');
      }
    });
  }

  /// Load fresh full data in background
  static void _loadFreshFullDataInBackground() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        print('🔄 Loading fresh full data in background...');
        final prefs = await SharedPreferences.getInstance();
        await _fetchFreshMoviesFull(prefs);
        print('✅ Background full refresh completed');
      } catch (e) {
        print('⚠️ Background full refresh failed: $e');
      }
    });
  }

  /// Clear all cached data
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_cacheKeyMoviesList),
        prefs.remove(_cacheKeyMoviesListTimestamp),
        prefs.remove(_cacheKeyMoviesFull),
        prefs.remove(_cacheKeyMoviesFullTimestamp),
      ]);
      print('🗑️ All movie cache cleared successfully');
    } catch (e) {
      print('❌ Error clearing movie cache: $e');
    }
  }

  /// Get cache info for debugging
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // List cache info
      final listTimestampStr = prefs.getString(_cacheKeyMoviesListTimestamp);
      final listCachedData = prefs.getString(_cacheKeyMoviesList);
      
      // Full cache info
      final fullTimestampStr = prefs.getString(_cacheKeyMoviesFullTimestamp);
      final fullCachedData = prefs.getString(_cacheKeyMoviesFull);
      
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;

      Map<String, dynamic> listInfo = {'hasCachedData': false};
      Map<String, dynamic> fullInfo = {'hasCachedData': false};

      // Process list cache info
      if (listTimestampStr != null && listCachedData != null) {
        final listCachedTimestamp = int.tryParse(listTimestampStr) ?? 0;
        final listCacheAge = currentTimestamp - listCachedTimestamp;
        final listCacheAgeMinutes = (listCacheAge / (1000 * 60)).round();
        final List<dynamic> listJsonData = json.decode(listCachedData);
        final listCacheSizeKB = (listCachedData.length / 1024).round();

        listInfo = {
          'hasCachedData': true,
          'cacheAge': listCacheAgeMinutes,
          'cachedMoviesCount': listJsonData.length,
          'cacheSize': listCacheSizeKB,
          'isValid': listCacheAge < _cacheDurationMs,
        };
      }

      // Process full cache info
      if (fullTimestampStr != null && fullCachedData != null) {
        final fullCachedTimestamp = int.tryParse(fullTimestampStr) ?? 0;
        final fullCacheAge = currentTimestamp - fullCachedTimestamp;
        final fullCacheAgeMinutes = (fullCacheAge / (1000 * 60)).round();
        final List<dynamic> fullJsonData = json.decode(fullCachedData);
        final fullCacheSizeKB = (fullCachedData.length / 1024).round();

        fullInfo = {
          'hasCachedData': true,
          'cacheAge': fullCacheAgeMinutes,
          'cachedMoviesCount': fullJsonData.length,
          'cacheSize': fullCacheSizeKB,
          'isValid': fullCacheAge < _cacheDurationMs,
        };
      }

      return {
        'listCache': listInfo,
        'fullCache': fullInfo,
      };
    } catch (e) {
      print('❌ Error getting cache info: $e');
      return {
        'listCache': {'hasCachedData': false, 'error': e.toString()},
        'fullCache': {'hasCachedData': false, 'error': e.toString()},
      };
    }
  }

  /// 🆕 Force refresh list data (bypass cache)
  static Future<List<Movie>> forceRefreshList() async {
    print('🔄 Force refreshing movies list data...');
    return await getMoviesForList(forceRefresh: true);
  }

  /// 🆕 Force refresh full data (bypass cache)
  static Future<List<Movie>> forceRefreshFull() async {
    print('🔄 Force refreshing movies full data...');
    return await getAllMoviesForGrid(forceRefresh: true);
  }

  /// Backward compatibility method (uses list data)
  static Future<List<Movie>> getAllMovies({bool forceRefresh = false}) async {
    return await getMoviesForList(forceRefresh: forceRefresh);
  }
}

// Professional Movies Horizontal List Widget
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
  _ProfessionalMoviesHorizontalListState createState() =>
      _ProfessionalMoviesHorizontalListState();
}

class _ProfessionalMoviesHorizontalListState
    extends State<ProfessionalMoviesHorizontalList>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  List<Movie> displayMoviesList = [];
  // 🆕 Remove fullMoviesList from list page - not needed here
  int totalMoviesCount = 0;

  bool _isLoading = true;
  String _errorMessage = '';
  bool _isNavigating = false;
  // 🆕 Remove _isLoadingFullList - not needed on list page

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;

  // Focus management
  Map<String, FocusNode> movieFocusNodes = {};
  FocusNode? _viewAllFocusNode;
  Color _currentAccentColor = ProfessionalColors.accentBlue;

  final ScrollController _scrollController = ScrollController();
  final int _maxItemsToShow = 7;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeViewAllFocusNode();
    _setupFocusProvider();
    _fetchDisplayMovies();
  }

  void _setupFocusProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final focusProvider =
              Provider.of<FocusProvider>(context, listen: false);

          if (widget.navigationIndex == 0) {
            focusProvider.setLiveChannelsFocusNode(widget.focusNode);
            print('✅ Live focus node specially registered');
          }

          focusProvider.registerGenericChannelFocus(
              widget.navigationIndex, _scrollController, widget.focusNode);

          if (displayMoviesList.isNotEmpty) {
            final firstMovieId = displayMoviesList[0].id.toString();
            if (movieFocusNodes.containsKey(firstMovieId)) {
              focusProvider.setFirstManageMoviesFocusNode(
                  movieFocusNodes[firstMovieId]!);
              print('✅ Movies first focus node registered for SubVod navigation');
            }
          }

          print('✅ Generic focus registered for ${widget.displayTitle} (index: ${widget.navigationIndex})');
        } catch (e) {
          print('❌ Focus provider setup failed: $e');
        }
      }
    });
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
      begin: const Offset(0, -1),
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

  // 🚀 Updated _fetchDisplayMovies method to use list-specific API (no full data fetch)
  Future<void> _fetchDisplayMovies() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 🆕 Only fetch list data (8 movies) - NO full data fetching here
      final fetchedMovies = await MovieService.getMoviesForList();

      if (fetchedMovies.isNotEmpty) {
        if (mounted) {
          setState(() {
            totalMoviesCount = fetchedMovies.length;
            displayMoviesList = fetchedMovies.take(_maxItemsToShow).toList();
            _initializeMovieFocusNodes();
            _isLoading = false;
          });

          _headerAnimationController.forward();
          _listAnimationController.forward();

          // Debug cache info
          _debugCacheInfo();
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'No movies found';
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
      print('❌ Error fetching movies: $e');
    }
  }

  // // 🆕 Updated _fetchFullMoviesList method to use full API
  // Future<void> _fetchFullMoviesList() async {
  //   if (!mounted || _isLoadingFullList || fullMoviesList.isNotEmpty) return;

  //   setState(() {
  //     _isLoadingFullList = true;
  //   });

  //   try {
  //     // 🆕 Use full data method for grid
  //     final fetchedMovies = await MovieService.getAllMoviesForGrid();

  //     if (mounted) {
  //       setState(() {
  //         fullMoviesList = fetchedMovies;
  //         _isLoadingFullList = false;
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         _isLoadingFullList = false;
  //       });
  //     }
  //     print('❌ Error fetching full movies list: $e');
  //   }
  // }

  // Debug method to show cache information
  Future<void> _debugCacheInfo() async {
    try {
      final cacheInfo = await MovieService.getCacheInfo();
      print('📊 Cache Info: $cacheInfo');
    } catch (e) {
      print('❌ Error getting cache info: $e');
    }
  }

  // 🆕 Updated force refresh method to use list-specific API only
  Future<void> _forceRefreshMovies() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 🆕 Force refresh only list data - NO full data here
      final fetchedMovies = await MovieService.forceRefreshList();

      if (fetchedMovies.isNotEmpty) {
        if (mounted) {
          setState(() {
            totalMoviesCount = fetchedMovies.length;
            displayMoviesList = fetchedMovies.take(_maxItemsToShow).toList();
            _initializeMovieFocusNodes();
            _isLoading = false;
          });

          _headerAnimationController.forward();
          _listAnimationController.forward();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Movies refreshed successfully'),
              backgroundColor: ProfessionalColors.accentGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'No movies found after refresh';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Refresh failed: Please check connection';
          _isLoading = false;
        });
      }
      print('❌ Error force refreshing movies: $e');
    }
  }

  void _initializeMovieFocusNodes() {
    // Clear existing focus nodes
    for (var node in movieFocusNodes.values) {
      try {
        node.removeListener(() {});
        node.dispose();
      } catch (e) {}
    }
    movieFocusNodes.clear();

    // Create focus nodes for display movies
    for (var movie in displayMoviesList) {
      try {
        String movieId = movie.id.toString();
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
      if (mounted && displayMoviesList.isNotEmpty) {
        try {
          final focusProvider =
              Provider.of<FocusProvider>(context, listen: false);

          // Register first movie with focus provider
          final firstMovieId = displayMoviesList[0].id.toString();
          if (movieFocusNodes.containsKey(firstMovieId)) {
            // ✅ MOVIES: Register first movie focus node for SubVod arrow down navigation
            focusProvider
                .setFirstManageMoviesFocusNode(movieFocusNodes[firstMovieId]!);
            print(
                '✅ Movies first banner focus registered for SubVod navigation');

            focusProvider.registerGenericChannelFocus(widget.navigationIndex,
                _scrollController, movieFocusNodes[firstMovieId]!);
          }

          // Register ViewAll focus node
          if (_viewAllFocusNode != null) {
            focusProvider.registerViewAllFocusNode(
                widget.navigationIndex, _viewAllFocusNode!);
          }
        } catch (e) {
          print('❌ Focus provider registration failed: $e');
        }
      }
    });
  }

// Option 1: Ultra Simple Version
void _scrollToFocusedItem(String itemId) {
  if (!mounted || !_scrollController.hasClients) return;

  try {
    // Find focused item index
    int index = displayMoviesList.indexWhere((movie) => movie.id.toString() == itemId);
    
    if (index != -1) {
      // Simple scroll calculation
      double scrollPosition = index * 180.0; // Adjust 180 to your item width
      
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  } catch (e) {
    // Silent fail
  }
}
  

  Future<void> _handleMovieTap(Movie movie) async {
    if (_isNavigating) return;
    _isNavigating = true;

    bool dialogShown = false;

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
                padding: const EdgeInsets.all(20),
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
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ProfessionalColors.accentBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Loading movie...',
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

    try {
      if (dialogShown) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Add this helper method in ProfessionalMoviesHorizontalList
      List<NewsItemModel> _convertMoviesToNewsItems(List<Movie> movies) {
        return movies
            .map((movie) => NewsItemModel(
                  id: movie.id.toString(),
                  name: movie.name,
                  banner: movie.banner ?? movie.poster ?? '',
                  url: movie.movieUrl,
                  unUpdatedUrl: movie.movieUrl,
                  contentType: '1', // Movie type
                  streamType: movie.sourceType,
                  liveStatus: false,
                  poster: movie.poster ?? movie.banner ?? '',
                  image: movie.banner ?? movie.poster ?? '',
                  // Other required fields...
                ))
            .toList();
      }

      if (isYoutubeUrl(movie.movieUrl)) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomYoutubePlayer(
              videoUrl: movie.movieUrl,
              name: movie.name,
            ),
          ),
        );
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomVideoPlayer(
              videoUrl: movie.movieUrl,
            ),
          ),
        );
      }
      print('✅ Movie played successfully: ${movie.name}');
    } catch (e) {
      if (dialogShown) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // ✅ Better error handling with specific error messages
      String errorMessage = 'Something went wrong';
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your connection';
      } else if (e.toString().contains('format') ||
          e.toString().contains('codec')) {
        errorMessage = 'Video format not supported';
      } else if (e.toString().contains('not found') ||
          e.toString().contains('404')) {
        errorMessage = 'Movie not found or unavailable';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: ProfessionalColors.accentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _handleMovieTap(movie),
          ),
        ),
      );
    } finally {
      _isNavigating = false;
    }
  }

  void _navigateToMoviesGrid() async {
    if (!_isNavigating && mounted) {
      _isNavigating = true;
      
      // 🆕 Don't pre-fetch here, let grid page handle full data loading
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfessionalMoviesGridView(
              // moviesList: displayMoviesList, // 🆕 Pass only display list
              categoryTitle: widget.displayTitle,
            ),
          ),
        ).then((_) {
          // Reset navigation flag when returning
          _isNavigating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _listAnimationController.dispose();

    for (var entry in movieFocusNodes.entries) {
      try {
        entry.value.removeListener(() {});
        entry.value.dispose();
      } catch (e) {}
    }
    movieFocusNodes.clear();

    try {
      _viewAllFocusNode?.removeListener(() {});
      _viewAllFocusNode?.dispose();
    } catch (e) {}

    try {
      _scrollController.dispose();
    } catch (e) {}

    _isNavigating = false;
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ✅ ADD: Consumer to listen to color changes
    return Consumer<ColorProvider>(
      builder: (context, colorProvider, child) {
        final bgColor = colorProvider.isItemFocused
            ? colorProvider.dominantColor.withOpacity(0.1)
            : ProfessionalColors.primaryDark;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            // ✅ ENHANCED: Dynamic background gradient based on focused item
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bgColor,
                  // ProfessionalColors.primaryDark,
                  // ProfessionalColors.surfaceDark.withOpacity(0.5),

                  bgColor.withOpacity(0.8),
                ProfessionalColors.primaryDark,
                ],
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.02),
                _buildProfessionalTitle(screenWidth),
                SizedBox(height: screenHeight * 0.01),
                Expanded(child: _buildBody(screenWidth, screenHeight)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ ENHANCED: Movie item with color provider integration
  Widget _buildMovieItem(Movie movie, int index, double screenWidth, double screenHeight) {
    String movieId = movie.id.toString();

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
            Color dominantColor = ProfessionalColors.gradientColors[
                math.Random()
                    .nextInt(ProfessionalColors.gradientColors.length)];

            setState(() {
              _currentAccentColor = dominantColor;
            });

            // ✅ ADD: Update color provider
            context.read<ColorProvider>().updateColor(dominantColor, true);
            widget.onFocusChange?.call(true);
          } catch (e) {
            print('Focus change handling failed: $e');
          }
        } else if (mounted) {
          // ✅ ADD: Reset color when focus lost
          context.read<ColorProvider>().resetColor();
          widget.onFocusChange?.call(false);
        }
      },
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (index < displayMoviesList.length - 1 && index != 6) {
              String nextMovieId = displayMoviesList[index + 1].id.toString();
              FocusScope.of(context).requestFocus(movieFocusNodes[nextMovieId]);
              return KeyEventResult.handled;
            } else if (index == 6 && totalMoviesCount > 7) {
              FocusScope.of(context).requestFocus(_viewAllFocusNode);
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (index > 0) {
              String prevMovieId = displayMoviesList[index - 1].id.toString();
              FocusScope.of(context).requestFocus(movieFocusNodes[prevMovieId]);
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // ✅ ADD: Reset color when navigating away
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                context
                    .read<FocusProvider>()
                    .requestFirstHorizontalListNetworksFocus();
              }
            });
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // ✅ ADD: Reset color when navigating away
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                Provider.of<FocusProvider>(context, listen: false)
                    .requestFirstWebseriesFocus();
              }
            });
            return KeyEventResult.handled;
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
            // ✅ ADD: Update color provider when card changes color
            context.read<ColorProvider>().updateColor(color, true);
          },
          index: index,
          categoryTitle: widget.displayTitle,
        ),
      ),
    );
  }

  // ✅ Enhanced ViewAll focus handling with ColorProvider
  Widget _buildMoviesList(double screenWidth, double screenHeight) {
    bool showViewAll = totalMoviesCount > 7;

    return FadeTransition(
      opacity: _listFadeAnimation,
      child: Container(
        height: screenHeight * 0.38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
          cacheExtent: 1200,
          itemCount: showViewAll ? 8 : displayMoviesList.length,
          itemBuilder: (context, index) {
            if (showViewAll && index == 7) {
              return Focus(
                focusNode: _viewAllFocusNode,
                onFocusChange: (hasFocus) {
                  if (hasFocus && mounted) {
                    Color viewAllColor = ProfessionalColors.gradientColors[
                        math.Random()
                            .nextInt(ProfessionalColors.gradientColors.length)];

                    setState(() {
                      _currentAccentColor = viewAllColor;
                    });

                    // ✅ ADD: Update color provider for ViewAll button
                    context.read<ColorProvider>().updateColor(viewAllColor, true);
                  } else if (mounted) {
                    // ✅ ADD: Reset color when ViewAll loses focus
                    context.read<ColorProvider>().resetColor();
                  }
                },
                onKey: (FocusNode node, RawKeyEvent event) {
                  if (event is RawKeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                      return KeyEventResult.handled;
                    } else if (event.logicalKey ==
                        LogicalKeyboardKey.arrowLeft) {
                      if (displayMoviesList.isNotEmpty &&
                          displayMoviesList.length > 6) {
                        String movieId = displayMoviesList[6].id.toString();
                        FocusScope.of(context)
                            .requestFocus(movieFocusNodes[movieId]);
                        return KeyEventResult.handled;
                      }
                    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                      // ✅ ADD: Reset color when navigating away from ViewAll
                      context.read<ColorProvider>().resetColor();
                      FocusScope.of(context).unfocus();
                      Future.delayed(const Duration(milliseconds: 50), () {
                        if (mounted) {
                          context
                              .read<FocusProvider>()
                              .requestFirstHorizontalListNetworksFocus();
                        }
                      });
                      return KeyEventResult.handled;
                    } else if (event.logicalKey ==
                        LogicalKeyboardKey.arrowDown) {
                      // ✅ ADD: Reset color when navigating away from ViewAll
                      context.read<ColorProvider>().resetColor();
                      FocusScope.of(context).unfocus();
                      Future.delayed(const Duration(milliseconds: 50), () {
                        if (mounted) {
                          Provider.of<FocusProvider>(context, listen: false)
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
                  child: ProfessionalViewAllButton(
                    focusNode: _viewAllFocusNode!,
                    onTap: _navigateToMoviesGrid,
                    totalItems: totalMoviesCount,
                    itemType: 'MOVIES',
                  ),
                ),
              );
            }

            var movie = displayMoviesList[index];
            return _buildMovieItem(movie, index, screenWidth, screenHeight);
          },
        ),
      ),
    );
  }



  // @override
  // Widget build(BuildContext context) {
  //   super.build(context);
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   final screenHeight = MediaQuery.of(context).size.height;

  //   return Scaffold(
  //     backgroundColor: Colors.transparent,
  //     body: Container(
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           begin: Alignment.topCenter,
  //           end: Alignment.bottomCenter,
  //           colors: [
  //             ProfessionalColors.primaryDark,
  //             ProfessionalColors.surfaceDark.withOpacity(0.5),
  //           ],
  //         ),
  //       ),
  //       child: Column(
  //         children: [
  //           SizedBox(height: screenHeight * 0.02),
  //           _buildProfessionalTitle(screenWidth),
  //           SizedBox(height: screenHeight * 0.01),
  //           Expanded(child: _buildBody(screenWidth, screenHeight)),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // 🚀 Enhanced Title with Cache Status and Refresh Button
  Widget _buildProfessionalTitle(double screenWidth) {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  ProfessionalColors.accentBlue,
                  ProfessionalColors.accentPurple,
                ],
              ).createShader(bounds),
              child: Text(
                widget.displayTitle,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            
            Row(
              children: [
                // Movies Count
                if (totalMoviesCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      '${totalMoviesCount} Movies Available',
                      style: const TextStyle(
                        color: ProfessionalColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(double screenWidth, double screenHeight) {
    if (_isLoading) {
      return ProfessionalLoadingIndicator(
          message: 'Loading ${widget.displayTitle}...');
    } else if (_errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    } else if (displayMoviesList.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildMoviesList(screenWidth, screenHeight);
    }
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
                  ProfessionalColors.accentRed.withOpacity(0.2),
                  ProfessionalColors.accentRed.withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: ProfessionalColors.accentRed,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Oops! Something went wrong',
            style: TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: const TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchDisplayMovies,
            style: ElevatedButton.styleFrom(
              backgroundColor: ProfessionalColors.accentBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
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
            child: const Icon(
              Icons.movie_outlined,
              size: 40,
              color: ProfessionalColors.accentBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No ${widget.displayTitle} Found',
            style: TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for new content',
            style: TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

//   Widget _buildMoviesList(double screenWidth, double screenHeight) {
//     bool showViewAll = totalMoviesCount > 7;

//     return FadeTransition(
//       opacity: _listFadeAnimation,
//       child: Container(
//         height: screenHeight * 0.38,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           clipBehavior: Clip.none,
//           controller: _scrollController,
//           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
//           cacheExtent: 1200,
//           itemCount: showViewAll ? 8 : displayMoviesList.length,
//           itemBuilder: (context, index) {
//             if (showViewAll && index == 7) {
//               return Focus(
//                 focusNode: _viewAllFocusNode,
//                 onFocusChange: (hasFocus) {
//                   if (hasFocus && mounted) {
//                     Color viewAllColor = ProfessionalColors.gradientColors[
//                         math.Random()
//                             .nextInt(ProfessionalColors.gradientColors.length)];

//                     setState(() {
//                       _currentAccentColor = viewAllColor;
//                     });
//                   }
//                 },
//                 onKey: (FocusNode node, RawKeyEvent event) {
//                   if (event is RawKeyDownEvent) {
//                     if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey ==
//                         LogicalKeyboardKey.arrowLeft) {
//                       if (displayMoviesList.isNotEmpty &&
//                           displayMoviesList.length > 6) {
//                         String movieId = displayMoviesList[6].id.toString();
//                         FocusScope.of(context)
//                             .requestFocus(movieFocusNodes[movieId]);
//                         return KeyEventResult.handled;
//                       }
//                     } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                       FocusScope.of(context).unfocus();
//                       Future.delayed(const Duration(milliseconds: 50), () {
//                         if (mounted) {
//                           context
//                               .read<FocusProvider>()
//                               .requestFirstHorizontalListNetworksFocus();
//                         }
//                       });
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey ==
//                         LogicalKeyboardKey.arrowDown) {
//                       FocusScope.of(context).unfocus();
//                       Future.delayed(const Duration(milliseconds: 50), () {
//                         if (mounted) {
//                           Provider.of<FocusProvider>(context, listen: false)
//                               .requestFirstWebseriesFocus();
//                         }
//                       });
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey == LogicalKeyboardKey.select) {
//                       _navigateToMoviesGrid();
//                       return KeyEventResult.handled;
//                     }
//                   }
//                   return KeyEventResult.ignored;
//                 },
//                 child: GestureDetector(
//                   onTap: _navigateToMoviesGrid,
//                   child: ProfessionalViewAllButton(
//                     focusNode: _viewAllFocusNode!,
//                     onTap: _navigateToMoviesGrid,
//                     totalItems: totalMoviesCount,
//                     itemType: 'MOVIES',
//                   ),
//                 ),
//               );
//             }

//             var movie = displayMoviesList[index];
//             return _buildMovieItem(movie, index, screenWidth, screenHeight);
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildMovieItem(
//       Movie movie, int index, double screenWidth, double screenHeight) {
//     String movieId = movie.id.toString();

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
//             Color dominantColor = ProfessionalColors.gradientColors[
//                 math.Random()
//                     .nextInt(ProfessionalColors.gradientColors.length)];

//             setState(() {
//               _currentAccentColor = dominantColor;
//             });

//             widget.onFocusChange?.call(true);
//           } catch (e) {
//             print('Focus change handling failed: $e');
//           }
//         } else if (mounted) {
//           widget.onFocusChange?.call(false);
//         }
//       },
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//             if (index < displayMoviesList.length - 1 && index != 6) {
//               String nextMovieId = displayMoviesList[index + 1].id.toString();
//               FocusScope.of(context).requestFocus(movieFocusNodes[nextMovieId]);
//               return KeyEventResult.handled;
//             } else if (index == 6 && totalMoviesCount > 7) {
//               FocusScope.of(context).requestFocus(_viewAllFocusNode);
//               return KeyEventResult.handled;
//             }
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//             if (index > 0) {
//               String prevMovieId = displayMoviesList[index - 1].id.toString();
//               FocusScope.of(context).requestFocus(movieFocusNodes[prevMovieId]);
//               return KeyEventResult.handled;
//             }
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//             FocusScope.of(context).unfocus();
//             Future.delayed(const Duration(milliseconds: 50), () {
//               if (mounted) {
//                 context
//                     .read<FocusProvider>()
//                     .requestFirstHorizontalListNetworksFocus();
//               }
//             });
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//             FocusScope.of(context).unfocus();
//             Future.delayed(const Duration(milliseconds: 50), () {
//               if (mounted) {
//                 Provider.of<FocusProvider>(context, listen: false)
//                     .requestFirstWebseriesFocus();
//               }
//             });
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.select) {
//             _handleMovieTap(movie);
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
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
//           },
//           index: index,
//           categoryTitle: widget.displayTitle,
//         ),
//       ),
//     );
//   }
}

// Professional Movie Card
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
    return Container(
      width: double.infinity,
      height: posterHeight,
      child: widget.movie.banner != null && widget.movie.banner!.isNotEmpty
          ? Image.network(
              widget.movie.banner!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildImagePlaceholder(posterHeight);
              },
              errorBuilder: (context, error, stackTrace) =>
                  _buildImagePlaceholder(posterHeight),
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
          const SizedBox(height: 8),
          Text(
            widget.categoryTitle,
            style: TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: ProfessionalColors.accentBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'HD',
              style: TextStyle(
                color: ProfessionalColors.accentBlue,
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
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenreBadge() {
    String genre = 'HD';
    Color badgeColor = ProfessionalColors.accentBlue;

    if (widget.movie.genres.toLowerCase().contains('comedy')) {
      genre = 'COMEDY';
      badgeColor = ProfessionalColors.accentGreen;
    } else if (widget.movie.genres.toLowerCase().contains('action')) {
      genre = 'ACTION';
      badgeColor = ProfessionalColors.accentRed;
    } else if (widget.movie.genres.toLowerCase().contains('romantic')) {
      genre = 'ROMANCE';
      badgeColor = ProfessionalColors.accentPink;
    } else if (widget.movie.genres.toLowerCase().contains('drama')) {
      genre = 'DRAMA';
      badgeColor = ProfessionalColors.accentPurple;
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

// Professional View All Button
class ProfessionalViewAllButton extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int totalItems;
  final String itemType;

  const ProfessionalViewAllButton({
    Key? key,
    required this.focusNode,
    required this.onTap,
    required this.totalItems,
    this.itemType = 'ITEMS',
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
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 3000),
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
      margin: const EdgeInsets.symmetric(horizontal: 6),
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
                        _isFocused ? focussedBannerhgt : bannerhgt,
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
                            offset: const Offset(0, 8),
                          ),
                        ] else ...[
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
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
                Text(
                  'VIEW ALL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _isFocused ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.totalItems}',
                    style: const TextStyle(
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
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Text(
        'ALL ${widget.itemType}',
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// Professional Loading Indicator
class ProfessionalLoadingIndicator extends StatefulWidget {
  final String message;

  const ProfessionalLoadingIndicator({
    Key? key,
    this.message = 'Loading...',
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
      duration: const Duration(milliseconds: 1500),
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
                  margin: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: ProfessionalColors.primaryDark,
                  ),
                  child: const Icon(
                    Icons.movie_rounded,
                    color: ProfessionalColors.textPrimary,
                    size: 28,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            widget.message,
            style: const TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
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
                  valueColor: const AlwaysStoppedAnimation<Color>(
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


class ProfessionalMoviesGridView extends StatefulWidget {
  final String categoryTitle; // ✅ Sirf title chahiye
  
  const ProfessionalMoviesGridView({
    Key? key,
    required this.categoryTitle, // ✅ No moviesList parameter
  }) : super(key: key);
// }

// // ✅ COMPLETE: Professional Movies Grid View with Full API Integration
// class ProfessionalMoviesGridView extends StatefulWidget {
//   final List<Movie> moviesList;
//   final String categoryTitle;

//   const ProfessionalMoviesGridView({
//     Key? key,
//     required this.moviesList,
//     required this.categoryTitle,
//   }) : super(key: key);

  @override
  _ProfessionalMoviesGridViewState createState() =>
      _ProfessionalMoviesGridViewState();
}

class _ProfessionalMoviesGridViewState extends State<ProfessionalMoviesGridView>
    with TickerProviderStateMixin {
  
  // ✅ Focus Management with Scrolling
  Map<String, FocusNode> _movieFocusNodes = {};
  bool _isLoading = false;
  bool _isLoadingMoreMovies = false; // 🆕 For loading full dataset
  int gridFocusedIndex = 0;
  final int columnsCount = 6;
  late ScrollController _scrollController;
  
  // 🆕 Full movies list for grid
  List<Movie> _fullMoviesList = [];
  String _errorMessage = ''; // <-- Added to fix undefined name error

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // ✅ Initialize ScrollController
    _scrollController = ScrollController();
    
    // 🆕 Initialize with passed movies and load full dataset
    // _fullMoviesList = List.from(widget.moviesList);
    _loadFullMoviesDataset();

    // ✅ Initialize focus nodes with scroll listeners
    _initializeMovieFocusNodes();

    // Set up focus for the first movie
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusFirstGridItem();
    });

    _initializeAnimations();
    _startStaggeredAnimation();
  }



  // 🆕 Grid page khud se data fetch karta hai
Future<void> _loadMoviesDataset() async {
  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  // ✅ Complete independent API call
  final fullMovies = await MovieService.getAllMoviesForGrid();
  
  setState(() {
    _fullMoviesList = fullMovies;
    _isLoading = false;
  });
}

  // 🆕 Load full movies dataset for grid
  Future<void> _loadFullMoviesDataset() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingMoreMovies = true;
    });

    try {
      print('🔄 Loading full movies dataset for grid...');
      // 🆕 Use the full API endpoint
      final fullMovies = await MovieService.getAllMoviesForGrid();
      
      if (mounted && fullMovies.isNotEmpty) {
        setState(() {
          _fullMoviesList = fullMovies;
          _isLoadingMoreMovies = false;
        });
        
        // 🆕 Reinitialize focus nodes with full dataset AFTER setState
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          _initializeMovieFocusNodes();
          
          // 🆕 Focus first item after initialization
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _focusFirstGridItem();
            }
          });
        }
        
        print('✅ Loaded ${fullMovies.length} movies for grid');
      } else {
        setState(() {
          _isLoadingMoreMovies = false;
        });
      }
    } catch (e) {
      print('❌ Error loading full movies dataset: $e');
      if (mounted) {
        setState(() {
          _isLoadingMoreMovies = false;
        });
      }
    }
  }

  // ✅ Initialize focus nodes with scroll functionality
  void _initializeMovieFocusNodes() {
    // Safely dispose existing nodes first
    for (var entry in _movieFocusNodes.entries) {
      try {
        entry.value.removeListener(() {});
        entry.value.dispose();
      } catch (e) {
        print('⚠️ Error disposing movie focus node ${entry.key}: $e');
      }
    }

    _movieFocusNodes.clear();

    // Create focus nodes for all movies in full dataset
    for (int i = 0; i < _fullMoviesList.length; i++) {
      String movieId = _fullMoviesList[i].id.toString();
      _movieFocusNodes[movieId] = FocusNode()
        ..addListener(() {
          if (mounted && _movieFocusNodes[movieId]!.hasFocus) {
            setState(() {
              gridFocusedIndex = i;
            });
            _scrollToFocusedItem(movieId);
          }
        });
    }

    print('✅ Created ${_movieFocusNodes.length} movie grid focus nodes');
  }

  // ✅ Focus first grid item - Enhanced with better error handling
  void _focusFirstGridItem() {
    if (_fullMoviesList.isEmpty) {
      print('⚠️ Cannot focus first item: movies list is empty');
      return;
    }
    
    if (_movieFocusNodes.isEmpty) {
      print('⚠️ Cannot focus first item: focus nodes not initialized');
      return;
    }

    final firstMovieId = _fullMoviesList[0].id.toString();
    if (_movieFocusNodes.containsKey(firstMovieId)) {
      try {
        setState(() {
          gridFocusedIndex = 0;
        });
        
        // 🆕 Add a small delay to ensure widget is fully rendered
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && _movieFocusNodes.containsKey(firstMovieId)) {
            FocusScope.of(context).requestFocus(_movieFocusNodes[firstMovieId]);
            print('✅ Focus set to first movie grid item: $firstMovieId');
          }
        });
      } catch (e) {
        print('⚠️ Error setting initial movie grid focus: $e');
      }
    } else {
      print('⚠️ First movie focus node not found: $firstMovieId');
    }
  }

  // ✅ Scroll to focused item
  void _scrollToFocusedItem(String itemId) {
    if (!mounted) return;

    try {
      final focusNode = _movieFocusNodes[itemId];
      if (focusNode != null &&
          focusNode.hasFocus &&
          focusNode.context != null) {
        Scrollable.ensureVisible(
          focusNode.context!,
          alignment: 0.1, // Keep focused item visible
          duration: AnimationTiming.scroll,
          curve: Curves.linear,
        );
      }
    } catch (e) {
      print('⚠️ Error scrolling to focused movie item: $e');
    }
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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

  // ✅ Enhanced Grid Navigation
  void _navigateGrid(LogicalKeyboardKey key) {
    if (_isLoading || _fullMoviesList.isEmpty) return; // 🆕 Check if data is available

    int newIndex = gridFocusedIndex;
    final int totalItems = _fullMoviesList.length;
    final int currentRow = gridFocusedIndex ~/ columnsCount;
    final int currentCol = gridFocusedIndex % columnsCount;

    switch (key) {
      case LogicalKeyboardKey.arrowRight:
        if (gridFocusedIndex < totalItems - 1) {
          newIndex = gridFocusedIndex + 1;
        }
        break;

      case LogicalKeyboardKey.arrowLeft:
        if (gridFocusedIndex > 0) {
          newIndex = gridFocusedIndex - 1;
        }
        break;

      case LogicalKeyboardKey.arrowDown:
        final int nextRowIndex = (currentRow + 1) * columnsCount + currentCol;
        if (nextRowIndex < totalItems) {
          newIndex = nextRowIndex;
        } else {
          final int lastRowStartIndex = ((totalItems - 1) ~/ columnsCount) * columnsCount;
          final int targetIndex = lastRowStartIndex + currentCol;
          if (targetIndex < totalItems) {
            newIndex = targetIndex;
          } else {
            newIndex = totalItems - 1;
          }
        }
        break;

      case LogicalKeyboardKey.arrowUp:
        if (currentRow > 0) {
          final int prevRowIndex = (currentRow - 1) * columnsCount + currentCol;
          newIndex = prevRowIndex;
        }
        break;
    }

    if (newIndex != gridFocusedIndex && newIndex >= 0 && newIndex < totalItems) {
      final newMovieId = _fullMoviesList[newIndex].id.toString();
      if (_movieFocusNodes.containsKey(newMovieId)) {
        setState(() {
          gridFocusedIndex = newIndex;
        });
        FocusScope.of(context).requestFocus(_movieFocusNodes[newMovieId]);
        HapticFeedback.lightImpact();
        print('🎯 Navigated to movie grid item $newIndex');
      }
    }
  }

  Future<void> _handleGridMovieTap(Movie movie) async {
    if (_isLoading || !mounted) return; // 🆕 Check main loading state

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
                  padding: const EdgeInsets.all(24),
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
                        child: const CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ProfessionalColors.accentBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Loading Movie...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
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

      if (mounted) {
        if (dialogShown) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (isYoutubeUrl(movie.movieUrl)) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomYoutubePlayer(
                videoUrl: movie.movieUrl,
                name: movie.name,
              ),
            ),
          );
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomVideoPlayer(
                videoUrl: movie.movieUrl,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        if (dialogShown) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        String errorMessage = 'Error loading movie';
        if (e.toString().contains('network') ||
            e.toString().contains('connection')) {
          errorMessage = 'Network error. Please check your connection';
        } else if (e.toString().contains('format') ||
            e.toString().contains('codec')) {
          errorMessage = 'Video format not supported';
        } else if (e.toString().contains('not found') ||
            e.toString().contains('404')) {
          errorMessage = 'Movie not found or unavailable';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: ProfessionalColors.accentRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _handleGridMovieTap(movie),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // ✅ Restore focus to the same item after returning
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            final movieIndex = _fullMoviesList.indexWhere((m) => m.id == movie.id);
            if (movieIndex != -1) {
              final movieId = movie.id.toString();
              if (_movieFocusNodes.containsKey(movieId)) {
                setState(() {
                  gridFocusedIndex = movieIndex;
                });
                FocusScope.of(context).requestFocus(_movieFocusNodes[movieId]);
                print('✅ Restored movie grid focus to ${movie.name}');
              }
            }
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _staggerController.dispose();
    _scrollController.dispose();
    
    // ✅ Safely dispose all focus nodes
    for (var entry in _movieFocusNodes.entries) {
      try {
        entry.value.removeListener(() {});
        entry.value.dispose();
        print('✅ Disposed movie grid focus node: ${entry.key}');
      } catch (e) {
        print('⚠️ Error disposing movie grid focus node ${entry.key}: $e');
      }
    }
    _movieFocusNodes.clear();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalColors.primaryDark,
      body: Container(
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
        child: Stack(
          children: [
            // ✅ Main Content with proper padding for AppBar
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // ✅ AppBar height placeholder to push content down
                  SizedBox(
                    height: MediaQuery.of(context).padding.top + 80,
                  ),
                  Expanded(
                    child: _buildMoviesGrid(),
                  ),
                ],
              ),
            ),

            // ✅ AppBar positioned on top with proper z-index
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildProfessionalAppBar(),
            ),

            // ✅ Loading More Indicator (removed - not needed anymore)

            // ✅ Loading Overlay - Always on top  
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: const Center(
                    child: ProfessionalLoadingIndicator(message: 'Loading Movie...'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ✅ Professional AppBar with Movies Theme
  Widget _buildProfessionalAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ProfessionalColors.primaryDark.withOpacity(0.95),
            ProfessionalColors.surfaceDark.withOpacity(0.9),
            ProfessionalColors.surfaceDark.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: ProfessionalColors.accentBlue.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 40,
              right: 40,
              bottom: 5,
            ),
            child: Row(
              children: [
                // ✅ Back Button with Movies theme colors
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        ProfessionalColors.accentBlue.withOpacity(0.3),
                        ProfessionalColors.accentPurple.withOpacity(0.3),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ProfessionalColors.accentBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ✅ Title with Movies theme colors
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            ProfessionalColors.accentBlue,
                            ProfessionalColors.accentPurple,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          widget.categoryTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // ✅ Count badge with dynamic count from full dataset
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ProfessionalColors.accentBlue.withOpacity(0.3),
                              ProfessionalColors.accentPurple.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: ProfessionalColors.accentBlue.withOpacity(0.4),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ProfessionalColors.accentBlue.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${_fullMoviesList.length} Movies Available',
                          style: const TextStyle(
                            color: ProfessionalColors.accentBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildMoviesGrid() {
    // 🆕 Show loading indicator while fetching data
    if (_isLoading) {
      return const Center(
        child: ProfessionalLoadingIndicator(message: 'Loading Movies...'),
      );
    }
    
    // 🆕 Show error state if loading failed
    if (_errorMessage.isNotEmpty) {
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
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: ProfessionalColors.accentRed,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Failed to Load Movies',
              style: TextStyle(
                color: ProfessionalColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: const TextStyle(
                color: ProfessionalColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadFullMoviesDataset,
              style: ElevatedButton.styleFrom(
                backgroundColor: ProfessionalColors.accentBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }
    
    // 🆕 Show empty state if no movies found
    if (_fullMoviesList.isEmpty) {
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
              child: const Icon(
                Icons.movie_outlined,
                size: 40,
                color: ProfessionalColors.accentBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No ${widget.categoryTitle} Found',
              style: TextStyle(
                color: ProfessionalColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back later for new content',
              style: TextStyle(
                color: ProfessionalColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Focus(
      autofocus: true,
      onKey: (node, event) {
        if (event is RawKeyDownEvent && !_isLoading) { // 🆕 Only check main loading
          if ([
            LogicalKeyboardKey.arrowUp,
            LogicalKeyboardKey.arrowDown,
            LogicalKeyboardKey.arrowLeft,
            LogicalKeyboardKey.arrowRight,
          ].contains(event.logicalKey)) {
            _navigateGrid(event.logicalKey);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.enter ||
                     event.logicalKey == LogicalKeyboardKey.select) {
            if (gridFocusedIndex < _fullMoviesList.length) {
              _handleGridMovieTap(_fullMoviesList[gridFocusedIndex]);
            }
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          controller: _scrollController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: _fullMoviesList.length,
          clipBehavior: Clip.none,
          itemBuilder: (context, index) {
            final movie = _fullMoviesList[index];
            String movieId = movie.id.toString();

            // ✅ Safe check for focus node existence
            if (!_movieFocusNodes.containsKey(movieId)) {
              print('⚠️ Movie grid focus node not found for Movie: $movieId');
              return const SizedBox.shrink();
            }

            return AnimatedBuilder(
              animation: _staggerController,
              builder: (context, child) {
                final delay = (index / _fullMoviesList.length) * 0.5;
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
                      categoryTitle: widget.categoryTitle,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Professional Grid Movie Card
class ProfessionalGridMovieCard extends StatefulWidget {
  final Movie movie;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int index;
  final String categoryTitle;

  const ProfessionalGridMovieCard({
    Key? key,
    required this.movie,
    required this.focusNode,
    required this.onTap,
    required this.index,
    required this.categoryTitle,
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
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: _dominantColor.withOpacity(0.2),
                        blurRadius: 35,
                        spreadRadius: 4,
                        offset: const Offset(0, 12),
                      ),
                    ] else ...[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
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
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: widget.movie.banner != null && widget.movie.banner!.isNotEmpty
          ? Image.network(
              widget.movie.banner!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildImagePlaceholder();
              },
              errorBuilder: (context, error, stackTrace) =>
                  _buildImagePlaceholder(),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
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
            const Icon(
              Icons.movie_outlined,
              size: 40,
              color: ProfessionalColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              widget.categoryTitle,
              style: TextStyle(
                color: ProfessionalColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: ProfessionalColors.accentBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'HD',
                style: TextStyle(
                  color: ProfessionalColors.accentBlue,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
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
    final movieName = widget.movie.name;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (_isFocused) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (widget.movie.runtime != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ProfessionalColors.accentGreen.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              ProfessionalColors.accentGreen.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${widget.movie.runtime}m',
                        style: const TextStyle(
                          color: ProfessionalColors.accentGreen,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _dominantColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _dominantColor.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'HD',
                      style: TextStyle(
                        color: _dominantColor,
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
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

// Main Movies Screen
class MoviesScreen extends StatefulWidget {
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
      backgroundColor: ProfessionalColors.primaryDark,
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