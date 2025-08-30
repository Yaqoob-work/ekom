// // import 'package:cached_network_image/cached_network_image.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:mobi_tv_entertainment/home_screen_pages/webseries_screen/webseries_details_page.dart';
// // import 'package:mobi_tv_entertainment/main.dart';
// // import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// // import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// // import 'package:provider/provider.dart';
// // import 'dart:convert';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'dart:math' as math;
// // import 'dart:ui';

// // // ✅ Professional Color Palette (same as Movies)
// // class ProfessionalColors {
// //   static const primaryDark = Color(0xFF0A0E1A);
// //   static const surfaceDark = Color(0xFF1A1D29);
// //   static const cardDark = Color(0xFF2A2D3A);
// //   static const accentBlue = Color(0xFF3B82F6);
// //   static const accentPurple = Color(0xFF8B5CF6);
// //   static const accentGreen = Color(0xFF10B981);
// //   static const accentRed = Color(0xFFEF4444);
// //   static const accentOrange = Color(0xFFF59E0B);
// //   static const accentPink = Color(0xFFEC4899);
// //   static const textPrimary = Color(0xFFFFFFFF);
// //   static const textSecondary = Color(0xFFB3B3B3);
// //   static const focusGlow = Color(0xFF60A5FA);

// //   static List<Color> gradientColors = [
// //     accentBlue,
// //     accentPurple,
// //     accentGreen,
// //     accentRed,
// //     accentOrange,
// //     accentPink,
// //   ];
// // }

// // // ✅ Professional Animation Durations
// // class AnimationTiming {
// //   static const Duration ultraFast = Duration(milliseconds: 150);
// //   static const Duration fast = Duration(milliseconds: 250);
// //   static const Duration medium = Duration(milliseconds: 400);
// //   static const Duration slow = Duration(milliseconds: 600);
// //   static const Duration focus = Duration(milliseconds: 300);
// //   static const Duration scroll = Duration(milliseconds: 800);
// // }

// // // ✅ WebSeries Model (same structure)
// // class WebSeriesModel {
// //   final int id;
// //   final String name;
// //   final String? description;
// //   final String? poster;
// //   final String? banner;
// //   final String? releaseDate;
// //   final String? genres;

// //   WebSeriesModel({
// //     required this.id,
// //     required this.name,
// //     this.description,
// //     this.poster,
// //     this.banner,
// //     this.releaseDate,
// //     this.genres,
// //   });

// //   factory WebSeriesModel.fromJson(Map<String, dynamic> json) {
// //     return WebSeriesModel(
// //       id: json['id'] ?? 0,
// //       name: json['name'] ?? '',
// //       description: json['description'],
// //       poster: json['poster'],
// //       banner: json['banner'],
// //       releaseDate: json['release_date'],
// //       genres: json['genres'],
// //     );
// //   }
// // }

// // // 🚀 Enhanced WebSeries Service with Caching (Similar to TV Shows)
// // class WebSeriesService {
// //   // Cache keys
// //   static const String _cacheKeyWebSeries = 'cached_web_series';
// //   static const String _cacheKeyTimestamp = 'cached_web_series_timestamp';
// //   static const String _cacheKeyAuthKey = 'auth_key';

// //   // Cache duration (in milliseconds) - 1 hour
// //   static const int _cacheDurationMs = 60 * 60 * 1000; // 1 hour

// //   /// Main method to get all web series with caching
// //   static Future<List<WebSeriesModel>> getAllWebSeries({bool forceRefresh = false}) async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();

// //       // Check if we should use cache
// //       if (!forceRefresh && await _shouldUseCache(prefs)) {
// //         print('📦 Loading Web Series from cache...');
// //         final cachedWebSeries = await _getCachedWebSeries(prefs);
// //         if (cachedWebSeries.isNotEmpty) {
// //           print('✅ Successfully loaded ${cachedWebSeries.length} web series from cache');

// //           // Load fresh data in background (without waiting)
// //           _loadFreshDataInBackground();

// //           return cachedWebSeries;
// //         }
// //       }

// //       // Load fresh data if no cache or force refresh
// //       print('🌐 Loading fresh Web Series from API...');
// //       return await _fetchFreshWebSeries(prefs);

// //     } catch (e) {
// //       print('❌ Error in getAllWebSeries: $e');

// //       // Try to return cached data as fallback
// //       try {
// //         final prefs = await SharedPreferences.getInstance();
// //         final cachedWebSeries = await _getCachedWebSeries(prefs);
// //         if (cachedWebSeries.isNotEmpty) {
// //           print('🔄 Returning cached data as fallback');
// //           return cachedWebSeries;
// //         }
// //       } catch (cacheError) {
// //         print('❌ Cache fallback also failed: $cacheError');
// //       }

// //       throw Exception('Failed to load web series: $e');
// //     }
// //   }

// //   /// Check if cached data is still valid
// //   static Future<bool> _shouldUseCache(SharedPreferences prefs) async {
// //     try {
// //       final timestampStr = prefs.getString(_cacheKeyTimestamp);
// //       if (timestampStr == null) return false;

// //       final cachedTimestamp = int.tryParse(timestampStr);
// //       if (cachedTimestamp == null) return false;

// //       final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
// //       final cacheAge = currentTimestamp - cachedTimestamp;

// //       final isValid = cacheAge < _cacheDurationMs;

// //       if (isValid) {
// //         final ageMinutes = (cacheAge / (1000 * 60)).round();
// //         print('📦 WebSeries Cache is valid (${ageMinutes} minutes old)');
// //       } else {
// //         final ageMinutes = (cacheAge / (1000 * 60)).round();
// //         print('⏰ WebSeries Cache expired (${ageMinutes} minutes old)');
// //       }

// //       return isValid;
// //     } catch (e) {
// //       print('❌ Error checking WebSeries cache validity: $e');
// //       return false;
// //     }
// //   }

// //   /// Get web series from cache
// //   static Future<List<WebSeriesModel>> _getCachedWebSeries(SharedPreferences prefs) async {
// //     try {
// //       final cachedData = prefs.getString(_cacheKeyWebSeries);
// //       if (cachedData == null || cachedData.isEmpty) {
// //         print('📦 No cached WebSeries data found');
// //         return [];
// //       }

// //       final List<dynamic> jsonData = json.decode(cachedData);
// //       final webSeries = jsonData
// //           .map((json) => WebSeriesModel.fromJson(json as Map<String, dynamic>))
// //           .toList();

// //       print('📦 Successfully loaded ${webSeries.length} web series from cache');
// //       return webSeries;
// //     } catch (e) {
// //       print('❌ Error loading cached web series: $e');
// //       return [];
// //     }
// //   }

// //   /// Fetch fresh web series from API and cache them
// //   static Future<List<WebSeriesModel>> _fetchFreshWebSeries(SharedPreferences prefs) async {
// //     try {
// //       String authKey = prefs.getString(_cacheKeyAuthKey) ?? '';

// //       final response = await http.get(
// //         Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
// //         headers: {
// //           'auth-key': authKey,
// //           'Content-Type': 'application/json',
// //           'Accept': 'application/json',
// //         },
// //       ).timeout(
// //         const Duration(seconds: 30),
// //         onTimeout: () {
// //           throw Exception('Request timeout');
// //         },
// //       );

// //       if (response.statusCode == 200) {
// //         final List<dynamic> jsonData = json.decode(response.body);

// //         final webSeries = jsonData
// //             .map((json) => WebSeriesModel.fromJson(json as Map<String, dynamic>))
// //             .toList();

// //         // Cache the fresh data
// //         await _cacheWebSeries(prefs, jsonData);

// //         print('✅ Successfully loaded ${webSeries.length} fresh web series from API');
// //         return webSeries;

// //       } else {
// //         throw Exception('API Error: ${response.statusCode} - ${response.reasonPhrase}');
// //       }
// //     } catch (e) {
// //       print('❌ Error fetching fresh web series: $e');
// //       rethrow;
// //     }
// //   }

// //   /// Cache web series data
// //   static Future<void> _cacheWebSeries(SharedPreferences prefs, List<dynamic> webSeriesData) async {
// //     try {
// //       final jsonString = json.encode(webSeriesData);
// //       final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

// //       // Save web series data and timestamp
// //       await Future.wait([
// //         prefs.setString(_cacheKeyWebSeries, jsonString),
// //         prefs.setString(_cacheKeyTimestamp, currentTimestamp),
// //       ]);

// //       print('💾 Successfully cached ${webSeriesData.length} web series');
// //     } catch (e) {
// //       print('❌ Error caching web series: $e');
// //     }
// //   }

// //   /// Load fresh data in background without blocking UI
// //   static void _loadFreshDataInBackground() {
// //     Future.delayed(const Duration(milliseconds: 500), () async {
// //       try {
// //         print('🔄 Loading fresh web series data in background...');
// //         final prefs = await SharedPreferences.getInstance();
// //         await _fetchFreshWebSeries(prefs);
// //         print('✅ WebSeries background refresh completed');
// //       } catch (e) {
// //         print('⚠️ WebSeries background refresh failed: $e');
// //       }
// //     });
// //   }

// //   /// Clear all cached data
// //   static Future<void> clearCache() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       await Future.wait([
// //         prefs.remove(_cacheKeyWebSeries),
// //         prefs.remove(_cacheKeyTimestamp),
// //       ]);
// //       print('🗑️ WebSeries cache cleared successfully');
// //     } catch (e) {
// //       print('❌ Error clearing WebSeries cache: $e');
// //     }
// //   }

// //   /// Get cache info for debugging
// //   static Future<Map<String, dynamic>> getCacheInfo() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final timestampStr = prefs.getString(_cacheKeyTimestamp);
// //       final cachedData = prefs.getString(_cacheKeyWebSeries);

// //       if (timestampStr == null || cachedData == null) {
// //         return {
// //           'hasCachedData': false,
// //           'cacheAge': 0,
// //           'cachedWebSeriesCount': 0,
// //           'cacheSize': 0,
// //         };
// //       }

// //       final cachedTimestamp = int.tryParse(timestampStr) ?? 0;
// //       final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
// //       final cacheAge = currentTimestamp - cachedTimestamp;
// //       final cacheAgeMinutes = (cacheAge / (1000 * 60)).round();

// //       final List<dynamic> jsonData = json.decode(cachedData);
// //       final cacheSizeKB = (cachedData.length / 1024).round();

// //       return {
// //         'hasCachedData': true,
// //         'cacheAge': cacheAgeMinutes,
// //         'cachedWebSeriesCount': jsonData.length,
// //         'cacheSize': cacheSizeKB,
// //         'isValid': cacheAge < _cacheDurationMs,
// //       };
// //     } catch (e) {
// //       print('❌ Error getting WebSeries cache info: $e');
// //       return {
// //         'hasCachedData': false,
// //         'cacheAge': 0,
// //         'cachedWebSeriesCount': 0,
// //         'cacheSize': 0,
// //         'error': e.toString(),
// //       };
// //     }
// //   }

// //   /// Force refresh data (bypass cache)
// //   static Future<List<WebSeriesModel>> forceRefresh() async {
// //     print('🔄 Force refreshing WebSeries data...');
// //     return await getAllWebSeries(forceRefresh: true);
// //   }
// // }

// // // 🚀 Enhanced ProfessionalWebSeriesHorizontalList with Caching
// // class ProfessionalWebSeriesHorizontalList extends StatefulWidget {
// //   @override
// //   _ProfessionalWebSeriesHorizontalListState createState() =>
// //       _ProfessionalWebSeriesHorizontalListState();
// // }

// // class _ProfessionalWebSeriesHorizontalListState
// //     extends State<ProfessionalWebSeriesHorizontalList>
// //     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
// //   @override
// //   bool get wantKeepAlive => true;

// //   List<WebSeriesModel> webSeriesList = [];
// //   bool isLoading = true;
// //   int focusedIndex = -1;
// //   final int maxHorizontalItems = 7;
// //   Color _currentAccentColor = ProfessionalColors.accentPurple;

// //   // Animation Controllers
// //   late AnimationController _headerAnimationController;
// //   late AnimationController _listAnimationController;
// //   late Animation<Offset> _headerSlideAnimation;
// //   late Animation<double> _listFadeAnimation;

// //   Map<String, FocusNode> webseriesFocusNodes = {};
// //   FocusNode? _viewAllFocusNode;
// //   FocusNode? _firstWebSeriesFocusNode;
// //   bool _hasReceivedFocusFromMovies = false;

// //   late ScrollController _scrollController;
// //   final double _itemWidth = 156.0;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _scrollController = ScrollController();
// //     _initializeAnimations();
// //     _initializeFocusNodes();

// //     // 🚀 Use enhanced caching service
// //     fetchWebSeriesWithCache();
// //   }

// //   void _initializeAnimations() {
// //     _headerAnimationController = AnimationController(
// //       duration: AnimationTiming.slow,
// //       vsync: this,
// //     );

// //     _listAnimationController = AnimationController(
// //       duration: AnimationTiming.slow,
// //       vsync: this,
// //     );

// //     _headerSlideAnimation = Tween<Offset>(
// //       begin: const Offset(0, -1),
// //       end: Offset.zero,
// //     ).animate(CurvedAnimation(
// //       parent: _headerAnimationController,
// //       curve: Curves.easeOutCubic,
// //     ));

// //     _listFadeAnimation = Tween<double>(
// //       begin: 0.0,
// //       end: 1.0,
// //     ).animate(CurvedAnimation(
// //       parent: _listAnimationController,
// //       curve: Curves.easeInOut,
// //     ));
// //   }

// //   void _initializeFocusNodes() {
// //     _viewAllFocusNode = FocusNode();
// //     print('✅ WebSeries focus nodes initialized');
// //   }

// //   void _scrollToPosition(int index) {
// //     if (index < webSeriesList.length && index < maxHorizontalItems) {
// //       String webSeriesId = webSeriesList[index].id.toString();
// //       if (webseriesFocusNodes.containsKey(webSeriesId)) {
// //         final focusNode = webseriesFocusNodes[webSeriesId]!;

// //         Scrollable.ensureVisible(
// //           focusNode.context!,
// //           duration: AnimationTiming.scroll,
// //           curve: Curves.easeInOutCubic,
// //           alignment: 0.15,
// //           alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
// //         );

// //         print('🎯 Scrollable.ensureVisible for index $index: ${webSeriesList[index].name}');
// //       }
// //     }
// //     // else if (index == maxHorizontalItems && _viewAllFocusNode != null) {
// //     //   Scrollable.ensureVisible(
// //     //     _viewAllFocusNode!.context!,
// //     //     duration: AnimationTiming.scroll,
// //     //     curve: Curves.easeInOutCubic,
// //     //     alignment: 0.2,
// //     //     alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
// //     //   );

// //     //   print('🎯 Scrollable.ensureVisible for ViewAll button');
// //     // }
// //   }

// //   void _setupFocusProvider() {
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (mounted && webSeriesList.isNotEmpty) {
// //         try {
// //           final focusProvider = Provider.of<FocusProvider>(context, listen: false);

// //           final firstWebSeriesId = webSeriesList[0].id.toString();

// //           if (!webseriesFocusNodes.containsKey(firstWebSeriesId)) {
// //             webseriesFocusNodes[firstWebSeriesId] = FocusNode();
// //             print('✅ Created focus node for first webseries: $firstWebSeriesId');
// //           }

// //           _firstWebSeriesFocusNode = webseriesFocusNodes[firstWebSeriesId];

// //           _firstWebSeriesFocusNode!.addListener(() {
// //             if (_firstWebSeriesFocusNode!.hasFocus && !_hasReceivedFocusFromMovies) {
// //               _hasReceivedFocusFromMovies = true;
// //               setState(() {
// //                 focusedIndex = 0;
// //               });
// //               _scrollToPosition(0);
// //               print('✅ WebSeries received focus from movies and scrolled');
// //             }
// //           });

// //           focusProvider.setFirstManageWebseriesFocusNode(_firstWebSeriesFocusNode!);
// //           print('✅ WebSeries first focus node registered: ${webSeriesList[0].name}');

// //         } catch (e) {
// //           print('❌ WebSeries focus provider setup failed: $e');
// //         }
// //       }
// //     });
// //   }

// //   // 🚀 Enhanced fetch method with caching
// //   Future<void> fetchWebSeriesWithCache() async {
// //     if (!mounted) return;

// //     setState(() {
// //       isLoading = true;
// //     });

// //     try {
// //       // Use cached data first, then fresh data
// //       final fetchedWebSeries = await WebSeriesService.getAllWebSeries();

// //       if (fetchedWebSeries.isNotEmpty) {
// //         if (mounted) {
// //           setState(() {
// //             webSeriesList = fetchedWebSeries;
// //             isLoading = false;
// //           });

// //           _createFocusNodesForItems();
// //           _setupFocusProvider();

// //           // Start animations after data loads
// //           _headerAnimationController.forward();
// //           _listAnimationController.forward();

// //           // Debug cache info
// //           _debugCacheInfo();
// //         }
// //       } else {
// //         if (mounted) {
// //           setState(() {
// //             isLoading = false;
// //           });
// //         }
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         setState(() {
// //           isLoading = false;
// //         });
// //       }
// //       print('Error fetching WebSeries with cache: $e');
// //     }
// //   }

// //   // 🆕 Debug method to show cache information
// //   Future<void> _debugCacheInfo() async {
// //     try {
// //       final cacheInfo = await WebSeriesService.getCacheInfo();
// //       print('📊 WebSeries Cache Info: $cacheInfo');
// //     } catch (e) {
// //       print('❌ Error getting WebSeries cache info: $e');
// //     }
// //   }

// //   // 🆕 Force refresh web series
// //   Future<void> _forceRefreshWebSeries() async {
// //     if (!mounted) return;

// //     setState(() {
// //       isLoading = true;
// //     });

// //     try {
// //       // Force refresh bypasses cache
// //       final fetchedWebSeries = await WebSeriesService.forceRefresh();

// //       if (fetchedWebSeries.isNotEmpty) {
// //         if (mounted) {
// //           setState(() {
// //             webSeriesList = fetchedWebSeries;
// //             isLoading = false;
// //           });

// //           _createFocusNodesForItems();
// //           _setupFocusProvider();

// //           _headerAnimationController.forward();
// //           _listAnimationController.forward();

// //           // Show success message
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(
// //               content: const Text('Web Series refreshed successfully'),
// //               backgroundColor: ProfessionalColors.accentPurple,
// //               behavior: SnackBarBehavior.floating,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //             ),
// //           );
// //         }
// //       } else {
// //         if (mounted) {
// //           setState(() {
// //             isLoading = false;
// //           });
// //         }
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         setState(() {
// //           isLoading = false;
// //         });
// //       }
// //       print('❌ Error force refreshing web series: $e');
// //     }
// //   }

// //   void _createFocusNodesForItems() {
// //     for (var node in webseriesFocusNodes.values) {
// //       try {
// //         node.removeListener(() {});
// //         node.dispose();
// //       } catch (e) {}
// //     }
// //     webseriesFocusNodes.clear();

// //     for (int i = 0; i < webSeriesList.length && i < maxHorizontalItems; i++) {
// //       String webSeriesId = webSeriesList[i].id.toString();
// //       if (!webseriesFocusNodes.containsKey(webSeriesId)) {
// //         webseriesFocusNodes[webSeriesId] = FocusNode();

// //         webseriesFocusNodes[webSeriesId]!.addListener(() {
// //           if (mounted && webseriesFocusNodes[webSeriesId]!.hasFocus) {
// //             setState(() {
// //               focusedIndex = i;
// //               _hasReceivedFocusFromMovies = true;
// //             });
// //             _scrollToPosition(i);
// //             print('✅ WebSeries $i focused and scrolled: ${webSeriesList[i].name}');
// //           }
// //         });
// //       }
// //     }
// //     print('✅ Created ${webseriesFocusNodes.length} webseries focus nodes with auto-scroll');
// //   }

// //   void _navigateToWebSeriesDetails(WebSeriesModel webSeries) {
// //     print('🎬 Navigating to WebSeries Details: ${webSeries.name}');

// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) => WebSeriesDetailsPage(
// //           id: webSeries.id,
// //           banner: webSeries.banner ?? webSeries.poster ?? '',
// //           poster: webSeries.poster ?? webSeries.banner ?? '',
// //           name: webSeries.name,
// //         ),
// //       ),
// //     ).then((_) {
// //       print('🔙 Returned from WebSeries Details');
// //       Future.delayed(Duration(milliseconds: 300), () {
// //         if (mounted) {
// //           int currentIndex = webSeriesList.indexWhere((ws) => ws.id == webSeries.id);
// //           if (currentIndex != -1 && currentIndex < maxHorizontalItems) {
// //             String webSeriesId = webSeries.id.toString();
// //             if (webseriesFocusNodes.containsKey(webSeriesId)) {
// //               setState(() {
// //                 focusedIndex = currentIndex;
// //                 _hasReceivedFocusFromMovies = true;
// //               });
// //               webseriesFocusNodes[webSeriesId]!.requestFocus();
// //               _scrollToPosition(currentIndex);
// //               print('✅ Restored focus to ${webSeries.name}');
// //             }
// //           }
// //         }
// //       });
// //     });
// //   }

// //   void _navigateToGridPage() {
// //     print('🎬 Navigating to WebSeries Grid Page...');

// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) => ProfessionalWebSeriesGridPage(
// //           webSeriesList: webSeriesList,
// //           title: 'Web Series',
// //         ),
// //       ),
// //     ).then((_) {
// //       print('🔙 Returned from grid page');
// //       Future.delayed(Duration(milliseconds: 300), () {
// //         if (mounted && _viewAllFocusNode != null) {
// //           setState(() {
// //             focusedIndex = maxHorizontalItems;
// //             _hasReceivedFocusFromMovies = true;
// //           });
// //           _viewAllFocusNode!.requestFocus();
// //           _scrollToPosition(maxHorizontalItems);
// //           print('✅ Focused back to ViewAll button and scrolled');
// //         }
// //       });
// //     });
// //   }

// //   // @override
// //   // Widget build(BuildContext context) {
// //   //   super.build(context);
// //   //   final screenWidth = MediaQuery.of(context).size.width;
// //   //   final screenHeight = MediaQuery.of(context).size.height;

// //   //   return

// //   //    Scaffold(
// //   //     backgroundColor: Colors.transparent,
// //   //     body: Container(
// //   //       decoration: BoxDecoration(
// //   //         gradient: LinearGradient(
// //   //           begin: Alignment.topCenter,
// //   //           end: Alignment.bottomCenter,
// //   //           colors: [
// //   //             ProfessionalColors.primaryDark,
// //   //             ProfessionalColors.surfaceDark.withOpacity(0.5),
// //   //           ],
// //   //         ),
// //   //       ),
// //   //       child: Column(
// //   //         children: [
// //   //           SizedBox(height: screenHeight * 0.02),
// //   //           _buildProfessionalTitle(screenWidth),
// //   //           SizedBox(height: screenHeight * 0.01),
// //   //           Expanded(child: _buildBody(screenWidth, screenHeight)),
// //   //         ],
// //   //       ),
// //   //     ),
// //   //   );
// //   // }

// //   //   @override
// //   // void initState() {
// //   //   super.initState();
// //   //   _scrollController = ScrollController();
// //   //   _initializeAnimations();
// //   //   _initializeFocusNodes();

// //   //   fetchWebSeriesWithCache();
// //   // }

// //   // ... [Keep all existing methods until build method]

// //   @override
// //   Widget build(BuildContext context) {
// //     super.build(context);
// //     final screenWidth = MediaQuery.of(context).size.width;
// //     final screenHeight = MediaQuery.of(context).size.height;

// //     // ✅ ADD: Consumer to listen to color changes
// //     return Consumer<ColorProvider>(
// //       builder: (context, colorProvider, child) {
// //         final bgColor = colorProvider.isItemFocused
// //             ? colorProvider.dominantColor.withOpacity(0.1)
// //             : ProfessionalColors.primaryDark;

// //         return Scaffold(
// //           backgroundColor: Colors.transparent,
// //           body: Container(
// //             // ✅ ENHANCED: Dynamic background gradient based on focused item
// //             decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.topCenter,
// //                 end: Alignment.bottomCenter,
// //                 colors: [
// //                   bgColor,
// //                   // ProfessionalColors.primaryDark,
// //                   // ProfessionalColors.surfaceDark.withOpacity(0.5),

// //                      bgColor.withOpacity(0.8),
// //                 ProfessionalColors.primaryDark,
// //                 ],
// //               ),
// //             ),
// //             child: Column(
// //               children: [
// //                 SizedBox(height: screenHeight * 0.02),
// //                 _buildProfessionalTitle(screenWidth),
// //                 SizedBox(height: screenHeight * 0.01),
// //                 Expanded(child: _buildBody(screenWidth, screenHeight)),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   // 🚀 Enhanced Title with Cache Status and Refresh Button
// //   Widget _buildProfessionalTitle(double screenWidth) {
// //     return SlideTransition(
// //       position: _headerSlideAnimation,
// //       child: Container(
// //         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             ShaderMask(
// //               shaderCallback: (bounds) => const LinearGradient(
// //                 colors: [
// //                   ProfessionalColors.accentPurple,
// //                   ProfessionalColors.accentBlue,
// //                 ],
// //               ).createShader(bounds),
// //               child: Text(
// //                 'WEB SERIES',
// //                 style: TextStyle(
// //                   fontSize: 24,
// //                   color: Colors.white,
// //                   fontWeight: FontWeight.w700,
// //                   letterSpacing: 2.0,
// //                 ),
// //               ),
// //             ),
// //             Row(
// //               children: [
// //                 // // 🆕 Refresh Button
// //                 // GestureDetector(
// //                 //   onTap: isLoading ? null : _forceRefreshWebSeries,
// //                 //   child: Container(
// //                 //     padding: const EdgeInsets.all(8),
// //                 //     decoration: BoxDecoration(
// //                 //       color: ProfessionalColors.accentPurple.withOpacity(0.2),
// //                 //       borderRadius: BorderRadius.circular(8),
// //                 //       border: Border.all(
// //                 //         color: ProfessionalColors.accentPurple.withOpacity(0.3),
// //                 //         width: 1,
// //                 //       ),
// //                 //     ),
// //                 //     child: isLoading
// //                 //         ? SizedBox(
// //                 //             width: 16,
// //                 //             height: 16,
// //                 //             child: CircularProgressIndicator(
// //                 //               strokeWidth: 2,
// //                 //               valueColor: AlwaysStoppedAnimation<Color>(
// //                 //                 ProfessionalColors.accentPurple,
// //                 //               ),
// //                 //             ),
// //                 //           )
// //                 //         : Icon(
// //                 //             Icons.refresh,
// //                 //             size: 16,
// //                 //             color: ProfessionalColors.accentPurple,
// //                 //           ),
// //                 //   ),
// //                 // ),
// //                 // const SizedBox(width: 12),
// //                 // Web Series Count
// //                 if (webSeriesList.length > 0)
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //                     decoration: BoxDecoration(
// //                       gradient: LinearGradient(
// //                         colors: [
// //                           ProfessionalColors.accentPurple.withOpacity(0.2),
// //                           ProfessionalColors.accentBlue.withOpacity(0.2),
// //                         ],
// //                       ),
// //                       borderRadius: BorderRadius.circular(20),
// //                       border: Border.all(
// //                         color: ProfessionalColors.accentPurple.withOpacity(0.3),
// //                         width: 1,
// //                       ),
// //                     ),
// //                     child: Text(
// //                       '${webSeriesList.length} Series Available',
// //                       style: const TextStyle(
// //                         color: ProfessionalColors.textSecondary,
// //                         fontSize: 12,
// //                         fontWeight: FontWeight.w500,
// //                       ),
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildBody(double screenWidth, double screenHeight) {
// //     if (isLoading) {
// //       return ProfessionalWebSeriesLoadingIndicator(
// //           message: 'Loading Web Series...');
// //     } else if (webSeriesList.isEmpty) {
// //       return _buildEmptyWidget();
// //     } else {
// //       return _buildWebSeriesList(screenWidth, screenHeight);
// //     }
// //   }

// //   Widget _buildEmptyWidget() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Container(
// //             width: 80,
// //             height: 80,
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               gradient: LinearGradient(
// //                 colors: [
// //                   ProfessionalColors.accentPurple.withOpacity(0.2),
// //                   ProfessionalColors.accentPurple.withOpacity(0.1),
// //                 ],
// //               ),
// //             ),
// //             child: const Icon(
// //               Icons.tv_outlined,
// //               size: 40,
// //               color: ProfessionalColors.accentPurple,
// //             ),
// //           ),
// //           const SizedBox(height: 24),
// //           const Text(
// //             'No Web Series Found',
// //             style: TextStyle(
// //               color: ProfessionalColors.textPrimary,
// //               fontSize: 18,
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //           const SizedBox(height: 8),
// //           const Text(
// //             'Check back later for new episodes',
// //             style: TextStyle(
// //               color: ProfessionalColors.textSecondary,
// //               fontSize: 14,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildWebSeriesList(double screenWidth, double screenHeight) {
// //     bool showViewAll = webSeriesList.length > 7;

// //     return FadeTransition(
// //       opacity: _listFadeAnimation,
// //       child: Container(
// //         height: screenHeight * 0.38,
// //         child: ListView.builder(
// //           scrollDirection: Axis.horizontal,
// //           clipBehavior: Clip.none,
// //           controller: _scrollController,
// //           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
// //           cacheExtent: 1200,
// //           itemCount: showViewAll ? 8 : webSeriesList.length,
// //           itemBuilder: (context, index) {
// //             if (showViewAll && index == 7) {
// //               return Focus(
// //                 focusNode: _viewAllFocusNode,
// //                 onFocusChange: (hasFocus) {
// //                   if (hasFocus && mounted) {
// //                     Color viewAllColor = ProfessionalColors.gradientColors[
// //                         math.Random().nextInt(ProfessionalColors.gradientColors.length)];

// //                     setState(() {
// //                       _currentAccentColor = viewAllColor;
// //                     });
// //                   }
// //                 },
// //                 onKey: (FocusNode node, RawKeyEvent event) {
// //                   if (event is RawKeyDownEvent) {
// //                     if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
// //                       return KeyEventResult.handled;
// //                     } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
// //                       if (webSeriesList.isNotEmpty && webSeriesList.length > 6) {
// //                         String webSeriesId = webSeriesList[6].id.toString();
// //                         FocusScope.of(context).requestFocus(webseriesFocusNodes[webSeriesId]);
// //                         return KeyEventResult.handled;
// //                       }
// //                     } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
// //                       setState(() {
// //                         focusedIndex = -1;
// //                         _hasReceivedFocusFromMovies = false;
// //                       });
// //                       FocusScope.of(context).unfocus();
// //                       Future.delayed(const Duration(milliseconds: 100), () {
// //                         if (mounted) {
// //                           try {
// //                             Provider.of<FocusProvider>(context, listen: false)
// //                                 .requestFirstMoviesFocus();
// //                             print('✅ Navigating back to movies from webseries');
// //                           } catch (e) {
// //                             print('❌ Failed to navigate to movies: $e');
// //                           }
// //                         }
// //                       });
// //                       return KeyEventResult.handled;
// //                     } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
// //                       setState(() {
// //                         focusedIndex = -1;
// //                         _hasReceivedFocusFromMovies = false;
// //                       });
// //                       FocusScope.of(context).unfocus();
// //                       Future.delayed(const Duration(milliseconds: 100), () {
// //                         if (mounted) {
// //                           try {
// //                             Provider.of<FocusProvider>(context, listen: false)
// //                                 .requestFirstTVShowsFocus();
// //                             print('✅ Navigating to TV Shows from webseries ViewAll');
// //                           } catch (e) {
// //                             print('❌ Failed to navigate to TV Shows: $e');
// //                           }
// //                         }
// //                       });
// //                       return KeyEventResult.handled;
// //                     } else if (event.logicalKey == LogicalKeyboardKey.enter ||
// //                                event.logicalKey == LogicalKeyboardKey.select) {
// //                       print('🎬 ViewAll button pressed - Opening Grid Page...');
// //                       _navigateToGridPage();
// //                       return KeyEventResult.handled;
// //                     }
// //                   }
// //                   return KeyEventResult.ignored;
// //                 },
// //                 child: GestureDetector(
// //                   onTap: _navigateToGridPage,
// //                   child: ProfessionalWebSeriesViewAllButton(
// //                     focusNode: _viewAllFocusNode!,
// //                     onTap: _navigateToGridPage,
// //                     totalItems: webSeriesList.length,
// //                     itemType: 'WEB SERIES',
// //                   ),
// //                 ),
// //               );
// //             }

// //             var webSeries = webSeriesList[index];
// //             return _buildWebSeriesItem(webSeries, index, screenWidth, screenHeight);
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //     // ✅ ENHANCED: WebSeries item with color provider integration
// //   Widget _buildWebSeriesItem(WebSeriesModel webSeries, int index, double screenWidth, double screenHeight) {
// //     String webSeriesId = webSeries.id.toString();

// //     webseriesFocusNodes.putIfAbsent(
// //       webSeriesId,
// //       () => FocusNode()
// //         ..addListener(() {
// //           if (mounted && webseriesFocusNodes[webSeriesId]!.hasFocus) {
// //             _scrollToPosition(index);
// //           }
// //         }),
// //     );

// //     return Focus(
// //       focusNode: webseriesFocusNodes[webSeriesId],
// //       onFocusChange: (hasFocus) async {
// //         if (hasFocus && mounted) {
// //           try {
// //             Color dominantColor = ProfessionalColors.gradientColors[
// //                 math.Random().nextInt(ProfessionalColors.gradientColors.length)];

// //             setState(() {
// //               _currentAccentColor = dominantColor;
// //               focusedIndex = index;
// //               _hasReceivedFocusFromMovies = true;
// //             });

// //             // ✅ ADD: Update color provider
// //             context.read<ColorProvider>().updateColor(dominantColor, true);
// //           } catch (e) {
// //             print('Focus change handling failed: $e');
// //           }
// //         } else if (mounted) {
// //           // ✅ ADD: Reset color when focus lost
// //           context.read<ColorProvider>().resetColor();
// //         }
// //       },
// //       onKey: (FocusNode node, RawKeyEvent event) {
// //         if (event is RawKeyDownEvent) {
// //           if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
// //             if (index < webSeriesList.length - 1 && index != 6) {
// //               String nextWebSeriesId = webSeriesList[index + 1].id.toString();
// //               FocusScope.of(context).requestFocus(webseriesFocusNodes[nextWebSeriesId]);
// //               return KeyEventResult.handled;
// //             } else if (index == 6 && webSeriesList.length > 7) {
// //               FocusScope.of(context).requestFocus(_viewAllFocusNode);
// //               return KeyEventResult.handled;
// //             }
// //           } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
// //             if (index > 0) {
// //               String prevWebSeriesId = webSeriesList[index - 1].id.toString();
// //               FocusScope.of(context).requestFocus(webseriesFocusNodes[prevWebSeriesId]);
// //               return KeyEventResult.handled;
// //             }
// //           } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
// //             setState(() {
// //               focusedIndex = -1;
// //               _hasReceivedFocusFromMovies = false;
// //             });
// //             // ✅ ADD: Reset color when navigating away
// //             context.read<ColorProvider>().resetColor();
// //             FocusScope.of(context).unfocus();
// //             Future.delayed(const Duration(milliseconds: 100), () {
// //               if (mounted) {
// //                 try {
// //                   Provider.of<FocusProvider>(context, listen: false)
// //                       .requestFirstMoviesFocus();
// //                   print('✅ Navigating back to movies from webseries');
// //                 } catch (e) {
// //                   print('❌ Failed to navigate to movies: $e');
// //                 }
// //               }
// //             });
// //             return KeyEventResult.handled;
// //           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
// //             setState(() {
// //               focusedIndex = -1;
// //               _hasReceivedFocusFromMovies = false;
// //             });
// //             // ✅ ADD: Reset color when navigating away
// //             context.read<ColorProvider>().resetColor();
// //             FocusScope.of(context).unfocus();
// //             Future.delayed(const Duration(milliseconds: 100), () {
// //               if (mounted) {
// //                 try {
// //                   Provider.of<FocusProvider>(context, listen: false)
// //                       .requestFirstTVShowsFocus();
// //                   print('✅ Navigating to TV Shows from webseries');
// //                 } catch (e) {
// //                   print('❌ Failed to navigate to TV Shows: $e');
// //                 }
// //               }
// //             });
// //             return KeyEventResult.handled;
// //           } else if (event.logicalKey == LogicalKeyboardKey.enter ||
// //                      event.logicalKey == LogicalKeyboardKey.select) {
// //             print('🎬 Enter pressed on ${webSeries.name} - Opening Details Page...');
// //             _navigateToWebSeriesDetails(webSeries);
// //             return KeyEventResult.handled;
// //           }
// //         }
// //         return KeyEventResult.ignored;
// //       },
// //       child: GestureDetector(
// //         onTap: () => _navigateToWebSeriesDetails(webSeries),
// //         child: ProfessionalWebSeriesCard(
// //           webSeries: webSeries,
// //           focusNode: webseriesFocusNodes[webSeriesId]!,
// //           onTap: () => _navigateToWebSeriesDetails(webSeries),
// //           onColorChange: (color) {
// //             setState(() {
// //               _currentAccentColor = color;
// //             });
// //             // ✅ ADD: Update color provider when card changes color
// //             context.read<ColorProvider>().updateColor(color, true);
// //           },
// //           index: index,
// //           categoryTitle: 'WEB SERIES',
// //         ),
// //       ),
// //     );
// //   }

// //   // Widget _buildWebSeriesItem(WebSeriesModel webSeries, int index, double screenWidth, double screenHeight) {
// //   //   String webSeriesId = webSeries.id.toString();

// //   //   webseriesFocusNodes.putIfAbsent(
// //   //     webSeriesId,
// //   //     () => FocusNode()
// //   //       ..addListener(() {
// //   //         if (mounted && webseriesFocusNodes[webSeriesId]!.hasFocus) {
// //   //           _scrollToPosition(index);
// //   //         }
// //   //       }),
// //   //   );

// //   //   return Focus(
// //   //     focusNode: webseriesFocusNodes[webSeriesId],
// //   //     onFocusChange: (hasFocus) async {
// //   //       if (hasFocus && mounted) {
// //   //         try {
// //   //           Color dominantColor = ProfessionalColors.gradientColors[
// //   //               math.Random().nextInt(ProfessionalColors.gradientColors.length)];

// //   //           setState(() {
// //   //             _currentAccentColor = dominantColor;
// //   //             focusedIndex = index;
// //   //             _hasReceivedFocusFromMovies = true;
// //   //           });
// //   //         } catch (e) {
// //   //           print('Focus change handling failed: $e');
// //   //         }
// //   //       }
// //   //     },
// //   //     onKey: (FocusNode node, RawKeyEvent event) {
// //   //       if (event is RawKeyDownEvent) {
// //   //         if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
// //   //           if (index < webSeriesList.length - 1 && index != 6) {
// //   //             String nextWebSeriesId = webSeriesList[index + 1].id.toString();
// //   //             FocusScope.of(context).requestFocus(webseriesFocusNodes[nextWebSeriesId]);
// //   //             return KeyEventResult.handled;
// //   //           } else if (index == 6 && webSeriesList.length > 7) {
// //   //             FocusScope.of(context).requestFocus(_viewAllFocusNode);
// //   //             return KeyEventResult.handled;
// //   //           }
// //   //         } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
// //   //           if (index > 0) {
// //   //             String prevWebSeriesId = webSeriesList[index - 1].id.toString();
// //   //             FocusScope.of(context).requestFocus(webseriesFocusNodes[prevWebSeriesId]);
// //   //             return KeyEventResult.handled;
// //   //           }
// //   //         } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
// //   //           setState(() {
// //   //             focusedIndex = -1;
// //   //             _hasReceivedFocusFromMovies = false;
// //   //           });
// //   //           FocusScope.of(context).unfocus();
// //   //           Future.delayed(const Duration(milliseconds: 100), () {
// //   //             if (mounted) {
// //   //               try {
// //   //                 Provider.of<FocusProvider>(context, listen: false)
// //   //                     .requestFirstMoviesFocus();
// //   //                 print('✅ Navigating back to movies from webseries');
// //   //               } catch (e) {
// //   //                 print('❌ Failed to navigate to movies: $e');
// //   //               }
// //   //             }
// //   //           });
// //   //           return KeyEventResult.handled;
// //   //         } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
// //   //           setState(() {
// //   //             focusedIndex = -1;
// //   //             _hasReceivedFocusFromMovies = false;
// //   //           });
// //   //           FocusScope.of(context).unfocus();
// //   //           Future.delayed(const Duration(milliseconds: 100), () {
// //   //             if (mounted) {
// //   //               try {
// //   //                 Provider.of<FocusProvider>(context, listen: false)
// //   //                     .requestFirstTVShowsFocus();
// //   //                 print('✅ Navigating to TV Shows from webseries');
// //   //               } catch (e) {
// //   //                 print('❌ Failed to navigate to TV Shows: $e');
// //   //               }
// //   //             }
// //   //           });
// //   //           return KeyEventResult.handled;
// //   //         } else if (event.logicalKey == LogicalKeyboardKey.enter ||
// //   //                    event.logicalKey == LogicalKeyboardKey.select) {
// //   //           print('🎬 Enter pressed on ${webSeries.name} - Opening Details Page...');
// //   //           _navigateToWebSeriesDetails(webSeries);
// //   //           return KeyEventResult.handled;
// //   //         }
// //   //       }
// //   //       return KeyEventResult.ignored;
// //   //     },
// //   //     child: GestureDetector(
// //   //       onTap: () => _navigateToWebSeriesDetails(webSeries),
// //   //       child: ProfessionalWebSeriesCard(
// //   //         webSeries: webSeries,
// //   //         focusNode: webseriesFocusNodes[webSeriesId]!,
// //   //         onTap: () => _navigateToWebSeriesDetails(webSeries),
// //   //         onColorChange: (color) {
// //   //           setState(() {
// //   //             _currentAccentColor = color;
// //   //           });
// //   //         },
// //   //         index: index,
// //   //         categoryTitle: 'WEB SERIES',
// //   //       ),
// //   //     ),
// //   //   );
// //   // }

// //   @override
// //   void dispose() {
// //     _headerAnimationController.dispose();
// //     _listAnimationController.dispose();

// //     for (var entry in webseriesFocusNodes.entries) {
// //       try {
// //         entry.value.removeListener(() {});
// //         entry.value.dispose();
// //       } catch (e) {}
// //     }
// //     webseriesFocusNodes.clear();

// //     try {
// //       _viewAllFocusNode?.removeListener(() {});
// //       _viewAllFocusNode?.dispose();
// //     } catch (e) {}

// //     try {
// //       _scrollController.dispose();
// //     } catch (e) {}

// //     super.dispose();
// //   }
// // }

// // // 🚀 Enhanced Cache Management Utility Class
// // class CacheManager {
// //   /// Clear all app caches
// //   static Future<void> clearAllCaches() async {
// //     try {
// //       await Future.wait([
// //         WebSeriesService.clearCache(),
// //         // Add other service cache clears here
// //         // MoviesService.clearCache(),
// //         // TVShowsService.clearCache(),
// //       ]);
// //       print('🗑️ All caches cleared successfully');
// //     } catch (e) {
// //       print('❌ Error clearing all caches: $e');
// //     }
// //   }

// //   /// Get comprehensive cache info for all services
// //   static Future<Map<String, dynamic>> getAllCacheInfo() async {
// //     try {
// //       final webSeriesCacheInfo = await WebSeriesService.getCacheInfo();
// //       // Add other service cache info here
// //       // final moviesCacheInfo = await MoviesService.getCacheInfo();
// //       // final tvShowsCacheInfo = await TVShowsService.getCacheInfo();

// //       return {
// //         'webSeries': webSeriesCacheInfo,
// //         // 'movies': moviesCacheInfo,
// //         // 'tvShows': tvShowsCacheInfo,
// //         'totalCacheSize': _calculateTotalCacheSize([
// //           webSeriesCacheInfo,
// //           // moviesCacheInfo,
// //           // tvShowsCacheInfo,
// //         ]),
// //       };
// //     } catch (e) {
// //       print('❌ Error getting all cache info: $e');
// //       return {
// //         'error': e.toString(),
// //         'webSeries': {'hasCachedData': false},
// //       };
// //     }
// //   }

// //   static int _calculateTotalCacheSize(List<Map<String, dynamic>> cacheInfos) {
// //     int totalSize = 0;
// //     for (final info in cacheInfos) {
// //       if (info['cacheSize'] is int) {
// //         totalSize += info['cacheSize'] as int;
// //       }
// //     }
// //     return totalSize;
// //   }

// //   /// Force refresh all data
// //   static Future<void> forceRefreshAllData() async {
// //     try {
// //       await Future.wait([
// //         WebSeriesService.forceRefresh(),
// //         // Add other service force refreshes here
// //         // MoviesService.forceRefresh(),
// //         // TVShowsService.forceRefresh(),
// //       ]);
// //       print('🔄 All data force refreshed successfully');
// //     } catch (e) {
// //       print('❌ Error force refreshing all data: $e');
// //     }
// //   }
// // }

// // // ✅ Professional WebSeries Card (Movies style)
// // class ProfessionalWebSeriesCard extends StatefulWidget {
// //   final WebSeriesModel webSeries;
// //   final FocusNode focusNode;
// //   final VoidCallback onTap;
// //   final Function(Color) onColorChange;
// //   final int index;
// //   final String categoryTitle;

// //   const ProfessionalWebSeriesCard({
// //     Key? key,
// //     required this.webSeries,
// //     required this.focusNode,
// //     required this.onTap,
// //     required this.onColorChange,
// //     required this.index,
// //     required this.categoryTitle,
// //   }) : super(key: key);

// //   @override
// //   _ProfessionalWebSeriesCardState createState() => _ProfessionalWebSeriesCardState();
// // }

// // class _ProfessionalWebSeriesCardState extends State<ProfessionalWebSeriesCard>
// //     with TickerProviderStateMixin {
// //   late AnimationController _scaleController;
// //   late AnimationController _glowController;
// //   late AnimationController _shimmerController;

// //   late Animation<double> _scaleAnimation;
// //   late Animation<double> _glowAnimation;
// //   late Animation<double> _shimmerAnimation;

// //   Color _dominantColor = ProfessionalColors.accentBlue;
// //   bool _isFocused = false;

// //   @override
// //   void initState() {
// //     super.initState();

// //     _scaleController = AnimationController(
// //       duration: AnimationTiming.slow,
// //       vsync: this,
// //     );

// //     _glowController = AnimationController(
// //       duration: AnimationTiming.medium,
// //       vsync: this,
// //     );

// //     _shimmerController = AnimationController(
// //       duration: const Duration(milliseconds: 1500),
// //       vsync: this,
// //     )..repeat();

// //     _scaleAnimation = Tween<double>(
// //       begin: 1.0,
// //       end: 1.06,
// //     ).animate(CurvedAnimation(
// //       parent: _scaleController,
// //       curve: Curves.easeOutCubic,
// //     ));

// //     _glowAnimation = Tween<double>(
// //       begin: 0.0,
// //       end: 1.0,
// //     ).animate(CurvedAnimation(
// //       parent: _glowController,
// //       curve: Curves.easeInOut,
// //     ));

// //     _shimmerAnimation = Tween<double>(
// //       begin: -1.0,
// //       end: 2.0,
// //     ).animate(CurvedAnimation(
// //       parent: _shimmerController,
// //       curve: Curves.easeInOut,
// //     ));

// //     widget.focusNode.addListener(_handleFocusChange);
// //   }

// //   void _handleFocusChange() {
// //     setState(() {
// //       _isFocused = widget.focusNode.hasFocus;
// //     });

// //     if (_isFocused) {
// //       _scaleController.forward();
// //       _glowController.forward();
// //       _generateDominantColor();
// //       widget.onColorChange(_dominantColor);
// //       HapticFeedback.lightImpact();
// //     } else {
// //       _scaleController.reverse();
// //       _glowController.reverse();
// //     }
// //   }

// //   void _generateDominantColor() {
// //     final colors = ProfessionalColors.gradientColors;
// //     _dominantColor = colors[math.Random().nextInt(colors.length)];
// //   }

// //   @override
// //   void dispose() {
// //     _scaleController.dispose();
// //     _glowController.dispose();
// //     _shimmerController.dispose();
// //     widget.focusNode.removeListener(_handleFocusChange);
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final screenWidth = MediaQuery.of(context).size.width;
// //     final screenHeight = MediaQuery.of(context).size.height;

// //     return AnimatedBuilder(
// //       animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
// //       builder: (context, child) {
// //         return Transform.scale(
// //           scale: _scaleAnimation.value,
// //           child: Container(
// //             width: bannerwdt,
// //             margin: const EdgeInsets.symmetric(horizontal: 6),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.center,
// //               children: [
// //                 _buildProfessionalPoster(screenWidth, screenHeight),
// //                 _buildProfessionalTitle(screenWidth),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildProfessionalPoster(double screenWidth, double screenHeight) {
// //     final posterHeight = _isFocused ? focussedBannerhgt : bannerhgt;

// //     return Container(
// //       height: posterHeight,
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(12),
// //         boxShadow: [
// //           if (_isFocused) ...[
// //             BoxShadow(
// //               color: _dominantColor.withOpacity(0.4),
// //               blurRadius: 25,
// //               spreadRadius: 3,
// //               offset: const Offset(0, 8),
// //             ),
// //             BoxShadow(
// //               color: _dominantColor.withOpacity(0.2),
// //               blurRadius: 45,
// //               spreadRadius: 6,
// //               offset: const Offset(0, 15),
// //             ),
// //           ] else ...[
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.4),
// //               blurRadius: 10,
// //               spreadRadius: 2,
// //               offset: const Offset(0, 5),
// //             ),
// //           ],
// //         ],
// //       ),
// //       child: ClipRRect(
// //         borderRadius: BorderRadius.circular(12),
// //         child: Stack(
// //           children: [
// //             _buildWebSeriesImage(screenWidth, posterHeight),
// //             if (_isFocused) _buildFocusBorder(),
// //             if (_isFocused) _buildShimmerEffect(),
// //             _buildGenreBadge(),
// //             if (_isFocused) _buildHoverOverlay(),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildWebSeriesImage(double screenWidth, double posterHeight) {
// //     return Container(
// //       width: double.infinity,
// //       height: posterHeight,
// //       child: widget.webSeries.banner != null && widget.webSeries.banner!.isNotEmpty
// //           ? Image.network(
// //               widget.webSeries.banner!,
// //               fit: BoxFit.cover,
// //               loadingBuilder: (context, child, loadingProgress) {
// //                 if (loadingProgress == null) return child;
// //                 return _buildImagePlaceholder(posterHeight);
// //               },
// //               errorBuilder: (context, error, stackTrace) =>
// //                   _buildImagePlaceholder(posterHeight),
// //             )
// //           : _buildImagePlaceholder(posterHeight),
// //     );
// //   }

// //   Widget _buildImagePlaceholder(double height) {
// //     return Container(
// //       height: height,
// //       decoration: const BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //           colors: [
// //             ProfessionalColors.cardDark,
// //             ProfessionalColors.surfaceDark,
// //           ],
// //         ),
// //       ),
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(
// //             Icons.tv_outlined,
// //             size: height * 0.25,
// //             color: ProfessionalColors.textSecondary,
// //           ),
// //           const SizedBox(height: 8),
// //           Text(
// //             'WEB SERIES',
// //             style: TextStyle(
// //               color: ProfessionalColors.textSecondary,
// //               fontSize: 10,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //           const SizedBox(height: 4),
// //           Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //             decoration: BoxDecoration(
// //               color: ProfessionalColors.accentPurple.withOpacity(0.2),
// //               borderRadius: BorderRadius.circular(6),
// //             ),
// //             child: const Text(
// //               'HD',
// //               style: TextStyle(
// //                 color: ProfessionalColors.accentPurple,
// //                 fontSize: 8,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildFocusBorder() {
// //     return Positioned.fill(
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           border: Border.all(
// //             width: 3,
// //             color: _dominantColor,
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildShimmerEffect() {
// //     return AnimatedBuilder(
// //       animation: _shimmerAnimation,
// //       builder: (context, child) {
// //         return Positioned.fill(
// //           child: Container(
// //             decoration: BoxDecoration(
// //               borderRadius: BorderRadius.circular(12),
// //               gradient: LinearGradient(
// //                 begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
// //                 end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
// //                 colors: [
// //                   Colors.transparent,
// //                   _dominantColor.withOpacity(0.15),
// //                   Colors.transparent,
// //                 ],
// //                 stops: [0.0, 0.5, 1.0],
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildGenreBadge() {
// //     String genre = 'SERIES';
// //     Color badgeColor = ProfessionalColors.accentPurple;

// //     if (widget.webSeries.genres != null) {
// //       if (widget.webSeries.genres!.toLowerCase().contains('drama')) {
// //         genre = 'DRAMA';
// //         badgeColor = ProfessionalColors.accentPurple;
// //       } else if (widget.webSeries.genres!.toLowerCase().contains('thriller')) {
// //         genre = 'THRILLER';
// //         badgeColor = ProfessionalColors.accentRed;
// //       } else if (widget.webSeries.genres!.toLowerCase().contains('comedy')) {
// //         genre = 'COMEDY';
// //         badgeColor = ProfessionalColors.accentGreen;
// //       } else if (widget.webSeries.genres!.toLowerCase().contains('romance')) {
// //         genre = 'ROMANCE';
// //         badgeColor = ProfessionalColors.accentPink;
// //       }
// //     }

// //     return Positioned(
// //       top: 8,
// //       right: 8,
// //       child: Container(
// //         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
// //         decoration: BoxDecoration(
// //           color: badgeColor.withOpacity(0.9),
// //           borderRadius: BorderRadius.circular(6),
// //         ),
// //         child: Text(
// //           genre,
// //           style: const TextStyle(
// //             color: Colors.white,
// //             fontSize: 8,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildHoverOverlay() {
// //     return Positioned.fill(
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [
// //               Colors.transparent,
// //               _dominantColor.withOpacity(0.1),
// //             ],
// //           ),
// //         ),
// //         child: Center(
// //           child: Container(
// //             padding: const EdgeInsets.all(10),
// //             decoration: BoxDecoration(
// //               color: Colors.black.withOpacity(0.7),
// //               borderRadius: BorderRadius.circular(25),
// //             ),
// //             child: Icon(
// //               Icons.play_arrow_rounded,
// //               color: _dominantColor,
// //               size: 30,
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildProfessionalTitle(double screenWidth) {
// //     final webSeriesName = widget.webSeries.name.toUpperCase();

// //     return Container(
// //       width: bannerwdt,
// //       child: AnimatedDefaultTextStyle(
// //         duration: AnimationTiming.medium,
// //         style: TextStyle(
// //           fontSize: _isFocused ? 13 : 11,
// //           fontWeight: FontWeight.w600,
// //           color: _isFocused ? _dominantColor : ProfessionalColors.textPrimary,
// //           letterSpacing: 0.5,
// //           shadows: _isFocused
// //               ? [
// //                   Shadow(
// //                     color: _dominantColor.withOpacity(0.6),
// //                     blurRadius: 10,
// //                     offset: const Offset(0, 2),
// //                   ),
// //                 ]
// //               : [],
// //         ),
// //         child: Text(
// //           webSeriesName,
// //           textAlign: TextAlign.center,
// //           maxLines: 2,
// //           overflow: TextOverflow.ellipsis,
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // ✅ Professional View All Button (same as movies)
// // class ProfessionalWebSeriesViewAllButton extends StatefulWidget {
// //   final FocusNode focusNode;
// //   final VoidCallback onTap;
// //   final int totalItems;
// //   final String itemType;

// //   const ProfessionalWebSeriesViewAllButton({
// //     Key? key,
// //     required this.focusNode,
// //     required this.onTap,
// //     required this.totalItems,
// //     this.itemType = 'WEB SERIES',
// //   }) : super(key: key);

// //   @override
// //   _ProfessionalWebSeriesViewAllButtonState createState() =>
// //       _ProfessionalWebSeriesViewAllButtonState();
// // }

// // class _ProfessionalWebSeriesViewAllButtonState extends State<ProfessionalWebSeriesViewAllButton>
// //     with TickerProviderStateMixin {
// //   late AnimationController _pulseController;
// //   late AnimationController _rotateController;
// //   late Animation<double> _pulseAnimation;
// //   late Animation<double> _rotateAnimation;

// //   bool _isFocused = false;
// //   Color _currentColor = ProfessionalColors.accentPurple;

// //   @override
// //   void initState() {
// //     super.initState();

// //     _pulseController = AnimationController(
// //       duration: const Duration(milliseconds: 1200),
// //       vsync: this,
// //     )..repeat(reverse: true);

// //     _rotateController = AnimationController(
// //       duration: const Duration(milliseconds: 3000),
// //       vsync: this,
// //     )..repeat();

// //     _pulseAnimation = Tween<double>(
// //       begin: 0.85,
// //       end: 1.15,
// //     ).animate(CurvedAnimation(
// //       parent: _pulseController,
// //       curve: Curves.easeInOut,
// //     ));

// //     _rotateAnimation = Tween<double>(
// //       begin: 0.0,
// //       end: 1.0,
// //     ).animate(_rotateController);

// //     widget.focusNode.addListener(_handleFocusChange);
// //   }

// //   void _handleFocusChange() {
// //     setState(() {
// //       _isFocused = widget.focusNode.hasFocus;
// //       if (_isFocused) {
// //         _currentColor = ProfessionalColors.gradientColors[
// //             math.Random().nextInt(ProfessionalColors.gradientColors.length)];
// //         HapticFeedback.mediumImpact();
// //       }
// //     });
// //   }

// //   @override
// //   void dispose() {
// //     _pulseController.dispose();
// //     _rotateController.dispose();
// //     widget.focusNode.removeListener(_handleFocusChange);
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final screenWidth = MediaQuery.of(context).size.width;
// //     final screenHeight = MediaQuery.of(context).size.height;

// //     return Container(
// //       width: bannerwdt,
// //       margin: const EdgeInsets.symmetric(horizontal: 6),
// //       child: Column(
// //         children: [
// //           AnimatedBuilder(
// //             animation: _isFocused ? _pulseAnimation : _rotateAnimation,
// //             builder: (context, child) {
// //               return Transform.scale(
// //                 scale: _isFocused ? _pulseAnimation.value : 1.0,
// //                 child: Transform.rotate(
// //                   angle: _isFocused ? 0 : _rotateAnimation.value * 2 * math.pi,
// //                   child: Container(
// //                     height: _isFocused ? focussedBannerhgt : bannerhgt,
// //                     decoration: BoxDecoration(
// //                       borderRadius: BorderRadius.circular(12),
// //                       gradient: LinearGradient(
// //                         begin: Alignment.topLeft,
// //                         end: Alignment.bottomRight,
// //                         colors: _isFocused
// //                             ? [
// //                                 _currentColor,
// //                                 _currentColor.withOpacity(0.7),
// //                               ]
// //                             : [
// //                                 ProfessionalColors.cardDark,
// //                                 ProfessionalColors.surfaceDark,
// //                               ],
// //                       ),
// //                       boxShadow: [
// //                         if (_isFocused) ...[
// //                           BoxShadow(
// //                             color: _currentColor.withOpacity(0.4),
// //                             blurRadius: 25,
// //                             spreadRadius: 3,
// //                             offset: const Offset(0, 8),
// //                           ),
// //                         ] else ...[
// //                           BoxShadow(
// //                             color: Colors.black.withOpacity(0.4),
// //                             blurRadius: 10,
// //                             offset: const Offset(0, 5),
// //                           ),
// //                         ],
// //                       ],
// //                     ),
// //                     child: _buildViewAllContent(),
// //                   ),
// //                 ),
// //               );
// //             },
// //           ),
// //           _buildViewAllTitle(),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildViewAllContent() {
// //     return Container(
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(12),
// //         border: _isFocused
// //             ? Border.all(
// //                 color: Colors.white.withOpacity(0.3),
// //                 width: 2,
// //               )
// //             : null,
// //       ),
// //       child: ClipRRect(
// //         borderRadius: BorderRadius.circular(12),
// //         child: BackdropFilter(
// //           filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
// //           child: Container(
// //             decoration: BoxDecoration(
// //               color: Colors.white.withOpacity(0.1),
// //             ),
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Icon(
// //                   Icons.tv_rounded,
// //                   size: _isFocused ? 45 : 35,
// //                   color: Colors.white,
// //                 ),
// //                 Text(
// //                   'VIEW ALL',
// //                   style: TextStyle(
// //                     color: Colors.white,
// //                     fontSize: _isFocused ? 14 : 12,
// //                     fontWeight: FontWeight.bold,
// //                     letterSpacing: 1.2,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 6),
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
// //                   decoration: BoxDecoration(
// //                     color: Colors.white.withOpacity(0.25),
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                   child: Text(
// //                     '${widget.totalItems}',
// //                     style: const TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 11,
// //                       fontWeight: FontWeight.w700,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildViewAllTitle() {
// //     return AnimatedDefaultTextStyle(
// //       duration: AnimationTiming.medium,
// //       style: TextStyle(
// //         fontSize: _isFocused ? 13 : 11,
// //         fontWeight: FontWeight.w600,
// //         color: _isFocused ? _currentColor : ProfessionalColors.textPrimary,
// //         letterSpacing: 0.5,
// //         shadows: _isFocused
// //             ? [
// //                 Shadow(
// //                   color: _currentColor.withOpacity(0.6),
// //                   blurRadius: 10,
// //                   offset: const Offset(0, 2),
// //                 ),
// //               ]
// //             : [],
// //       ),
// //       child: Text(
// //         'ALL ${widget.itemType}',
// //         textAlign: TextAlign.center,
// //         maxLines: 1,
// //         overflow: TextOverflow.ellipsis,
// //       ),
// //     );
// //   }
// // }

// // // // ✅ Professional WebSeries Grid Page
// // // class ProfessionalWebSeriesGridPage extends StatefulWidget {
// // //   final List<WebSeriesModel> webSeriesList;
// // //   final String title;

// // //   const ProfessionalWebSeriesGridPage({
// // //     Key? key,
// // //     required this.webSeriesList,
// // //     this.title = 'All Web Series',
// // //   }) : super(key: key);

// // //   @override
// // //   _ProfessionalWebSeriesGridPageState createState() => _ProfessionalWebSeriesGridPageState();
// // // }

// // // class _ProfessionalWebSeriesGridPageState extends State<ProfessionalWebSeriesGridPage>
// // //     with TickerProviderStateMixin {
// // //   int gridFocusedIndex = 0;
// // //   final int columnsCount = 6;
// // //   Map<int, FocusNode> gridFocusNodes = {};
// // //   late ScrollController _scrollController;

// // //   // Animation Controllers
// // //   late AnimationController _fadeController;
// // //   late AnimationController _staggerController;
// // //   late Animation<double> _fadeAnimation;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _scrollController = ScrollController();
// // //     _createGridFocusNodes();
// // //     _initializeAnimations();
// // //     _startStaggeredAnimation();

// // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // //       _focusFirstGridItem();
// // //     });
// // //   }

// // //   void _initializeAnimations() {
// // //     _fadeController = AnimationController(
// // //       duration: const Duration(milliseconds: 600),
// // //       vsync: this,
// // //     );

// // //     _staggerController = AnimationController(
// // //       duration: const Duration(milliseconds: 1200),
// // //       vsync: this,
// // //     );

// // //     _fadeAnimation = Tween<double>(
// // //       begin: 0.0,
// // //       end: 1.0,
// // //     ).animate(CurvedAnimation(
// // //       parent: _fadeController,
// // //       curve: Curves.easeInOut,
// // //     ));
// // //   }

// // //   void _startStaggeredAnimation() {
// // //     _fadeController.forward();
// // //     _staggerController.forward();
// // //   }

// // //   void _createGridFocusNodes() {
// // //     for (int i = 0; i < widget.webSeriesList.length; i++) {
// // //       gridFocusNodes[i] = FocusNode();
// // //       gridFocusNodes[i]!.addListener(() {
// // //         if (gridFocusNodes[i]!.hasFocus) {
// // //           _ensureItemVisible(i);
// // //         }
// // //       });
// // //     }
// // //   }

// // //   void _focusFirstGridItem() {
// // //     if (gridFocusNodes.containsKey(0)) {
// // //       setState(() {
// // //         gridFocusedIndex = 0;
// // //       });
// // //       gridFocusNodes[0]!.requestFocus();
// // //     }
// // //   }

// // //   void _ensureItemVisible(int index) {
// // //     if (_scrollController.hasClients) {
// // //       final int row = index ~/ columnsCount;
// // //       final double itemHeight = 200.0;
// // //       final double targetOffset = row * itemHeight;

// // //       _scrollController.animateTo(
// // //         targetOffset,
// // //         duration: Duration(milliseconds: 300),
// // //         curve: Curves.easeInOut,
// // //       );
// // //     }
// // //   }

// // //   void _navigateGrid(LogicalKeyboardKey key) {
// // //     int newIndex = gridFocusedIndex;
// // //     final int totalItems = widget.webSeriesList.length;
// // //     final int currentRow = gridFocusedIndex ~/ columnsCount;
// // //     final int currentCol = gridFocusedIndex % columnsCount;

// // //     switch (key) {
// // //       case LogicalKeyboardKey.arrowRight:
// // //         if (gridFocusedIndex < totalItems - 1) {
// // //           newIndex = gridFocusedIndex + 1;
// // //         }
// // //         break;

// // //       case LogicalKeyboardKey.arrowLeft:
// // //         if (gridFocusedIndex > 0) {
// // //           newIndex = gridFocusedIndex - 1;
// // //         }
// // //         break;

// // //       case LogicalKeyboardKey.arrowDown:
// // //         final int nextRowIndex = (currentRow + 1) * columnsCount + currentCol;
// // //         if (nextRowIndex < totalItems) {
// // //           newIndex = nextRowIndex;
// // //         }
// // //         break;

// // //       case LogicalKeyboardKey.arrowUp:
// // //         if (currentRow > 0) {
// // //           final int prevRowIndex = (currentRow - 1) * columnsCount + currentCol;
// // //           newIndex = prevRowIndex;
// // //         }
// // //         break;
// // //     }

// // //     if (newIndex != gridFocusedIndex && newIndex >= 0 && newIndex < totalItems) {
// // //       setState(() {
// // //         gridFocusedIndex = newIndex;
// // //       });
// // //       gridFocusNodes[newIndex]!.requestFocus();
// // //     }
// // //   }

// // //   void _navigateToWebSeriesDetails(WebSeriesModel webSeries, int index) {
// // //     print('🎬 Grid: Navigating to WebSeries Details: ${webSeries.name}');

// // //     Navigator.push(
// // //       context,
// // //       MaterialPageRoute(
// // //         builder: (context) => WebSeriesDetailsPage(
// // //           id: webSeries.id,
// // //           banner: webSeries.banner ?? webSeries.poster ?? '',
// // //           poster: webSeries.poster ?? webSeries.banner ?? '',
// // //           name: webSeries.name,
// // //         ),
// // //       ),
// // //     ).then((_) {
// // //       print('🔙 Returned from WebSeries Details to Grid');
// // //       Future.delayed(Duration(milliseconds: 300), () {
// // //         if (mounted && gridFocusNodes.containsKey(index)) {
// // //           setState(() {
// // //             gridFocusedIndex = index;
// // //           });
// // //           gridFocusNodes[index]!.requestFocus();
// // //           print('✅ Restored grid focus to index $index');
// // //         }
// // //       });
// // //     });
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: ProfessionalColors.primaryDark,
// // //       body: Stack(
// // //         children: [
// // //           // Background Gradient
// // //           Container(
// // //             decoration: BoxDecoration(
// // //               gradient: LinearGradient(
// // //                 begin: Alignment.topCenter,
// // //                 end: Alignment.bottomCenter,
// // //                 colors: [
// // //                   ProfessionalColors.primaryDark,
// // //                   ProfessionalColors.surfaceDark.withOpacity(0.8),
// // //                   ProfessionalColors.primaryDark,
// // //                 ],
// // //               ),
// // //             ),
// // //           ),

// // //           // Main Content
// // //           FadeTransition(
// // //             opacity: _fadeAnimation,
// // //             child: Column(
// // //               children: [
// // //                 _buildProfessionalAppBar(),
// // //                 Expanded(
// // //                   child: _buildGridView(),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildProfessionalAppBar() {
// // //     return Container(
// // //       padding: EdgeInsets.only(
// // //         top: MediaQuery.of(context).padding.top + 10,
// // //         left: 40,
// // //         right: 40,
// // //         bottom: 20,
// // //       ),
// // //       decoration: BoxDecoration(
// // //         gradient: LinearGradient(
// // //           begin: Alignment.topCenter,
// // //           end: Alignment.bottomCenter,
// // //           colors: [
// // //             ProfessionalColors.surfaceDark.withOpacity(0.9),
// // //             ProfessionalColors.surfaceDark.withOpacity(0.7),
// // //             Colors.transparent,
// // //           ],
// // //         ),
// // //       ),
// // //       child: Row(
// // //         children: [
// // //                 const SizedBox(height: 10),

// // //           Container(
// // //             decoration: BoxDecoration(
// // //               shape: BoxShape.circle,
// // //               gradient: LinearGradient(
// // //                 colors: [
// // //                   ProfessionalColors.accentPurple.withOpacity(0.2),
// // //                   ProfessionalColors.accentBlue.withOpacity(0.2),
// // //                 ],
// // //               ),
// // //             ),
// // //             child: IconButton(
// // //               icon: const Icon(
// // //                 Icons.arrow_back_rounded,
// // //                 color: Colors.white,
// // //                 size: 24,
// // //               ),
// // //               onPressed: () => Navigator.pop(context),
// // //             ),
// // //           ),
// // //           const SizedBox(width: 16),
// // //           Expanded(
// // //             child: Row(
// // //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //               children: [
// // //                 ShaderMask(
// // //                   shaderCallback: (bounds) => const LinearGradient(
// // //                     colors: [
// // //                       ProfessionalColors.accentPurple,
// // //                       ProfessionalColors.accentBlue,
// // //                     ],
// // //                   ).createShader(bounds),
// // //                   child: Text(
// // //                     widget.title,
// // //                     style: TextStyle(
// // //                       color: Colors.white,
// // //                       fontSize: 24,
// // //                       fontWeight: FontWeight.w700,
// // //                       letterSpacing: 1.0,
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 4),
// // //                 Container(
// // //                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// // //                   decoration: BoxDecoration(
// // //                     gradient: LinearGradient(
// // //                       colors: [
// // //                         ProfessionalColors.accentPurple.withOpacity(0.2),
// // //                         ProfessionalColors.accentBlue.withOpacity(0.1),
// // //                       ],
// // //                     ),
// // //                     borderRadius: BorderRadius.circular(15),
// // //                     border: Border.all(
// // //                       color: ProfessionalColors.accentPurple.withOpacity(0.3),
// // //                       width: 1,
// // //                     ),
// // //                   ),
// // //                   child: Text(
// // //                     '${widget.webSeriesList.length} Web Series Available',
// // //                     style: const TextStyle(
// // //                       color: ProfessionalColors.accentPurple,
// // //                       fontSize: 12,
// // //                       fontWeight: FontWeight.w500,
// // //                     ),
// // //                   ),
// // //                 ),

// // //               ],
// // //             ),
// // //           ),
// // //                 const SizedBox(height: 10),

// // //         ],
// // //       ),

// // //     );
// // //   }

// // //   Widget _buildGridView() {
// // //     if (widget.webSeriesList.isEmpty) {
// // //       return Center(
// // //         child: Column(
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           children: [
// // //             Container(
// // //               width: 80,
// // //               height: 80,
// // //               decoration: BoxDecoration(
// // //                 shape: BoxShape.circle,
// // //                 gradient: LinearGradient(
// // //                   colors: [
// // //                     ProfessionalColors.accentPurple.withOpacity(0.2),
// // //                     ProfessionalColors.accentPurple.withOpacity(0.1),
// // //                   ],
// // //                 ),
// // //               ),
// // //               child: const Icon(
// // //                 Icons.tv_outlined,
// // //                 size: 40,
// // //                 color: ProfessionalColors.accentPurple,
// // //               ),
// // //             ),
// // //             const SizedBox(height: 24),
// // //             Text(
// // //               'No ${widget.title} Found',
// // //               style: TextStyle(
// // //                 color: ProfessionalColors.textPrimary,
// // //                 fontSize: 18,
// // //                 fontWeight: FontWeight.w600,
// // //               ),
// // //             ),
// // //             const SizedBox(height: 8),
// // //             const Text(
// // //               'Check back later for new episodes',
// // //               style: TextStyle(
// // //                 color: ProfessionalColors.textSecondary,
// // //                 fontSize: 14,
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       );
// // //     }

// // //     return Focus(
// // //       autofocus: true,
// // //       onKey: (node, event) {
// // //         if (event is RawKeyDownEvent) {
// // //           // if (event.logicalKey == LogicalKeyboardKey.escape ||
// // //           //     event.logicalKey == LogicalKeyboardKey.goBack) {
// // //           //   Navigator.pop(context);
// // //           //   return KeyEventResult.handled;
// // //           // } else
// // //            if ([
// // //             LogicalKeyboardKey.arrowUp,
// // //             LogicalKeyboardKey.arrowDown,
// // //             LogicalKeyboardKey.arrowLeft,
// // //             LogicalKeyboardKey.arrowRight,
// // //           ].contains(event.logicalKey)) {
// // //             _navigateGrid(event.logicalKey);
// // //             return KeyEventResult.handled;
// // //           } else if (event.logicalKey == LogicalKeyboardKey.enter ||
// // //                      event.logicalKey == LogicalKeyboardKey.select) {
// // //             if (gridFocusedIndex < widget.webSeriesList.length) {
// // //               _navigateToWebSeriesDetails(
// // //                 widget.webSeriesList[gridFocusedIndex],
// // //                 gridFocusedIndex,
// // //               );
// // //             }
// // //             return KeyEventResult.handled;
// // //           }
// // //         }
// // //         return KeyEventResult.ignored;
// // //       },
// // //       child: Padding(
// // //         padding: EdgeInsets.all(20),
// // //         child: GridView.builder(
// // //           controller: _scrollController,
// // //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// // //             // crossAxisCount: columnsCount,
// // //             crossAxisCount: columnsCount,
// // //             crossAxisSpacing: 15,
// // //             mainAxisSpacing: 15,
// // //             childAspectRatio: 1.5,
// // //           ),
// // //           itemCount: widget.webSeriesList.length,
// // //           itemBuilder: (context, index) {
// // //             return AnimatedBuilder(
// // //               animation: _staggerController,
// // //               builder: (context, child) {
// // //                 final delay = (index / widget.webSeriesList.length) * 0.5;
// // //                 final animationValue = Interval(
// // //                   delay,
// // //                   delay + 0.5,
// // //                   curve: Curves.easeOutCubic,
// // //                 ).transform(_staggerController.value);

// // //                 return Transform.translate(
// // //                   offset: Offset(0, 50 * (1 - animationValue)),
// // //                   child: Opacity(
// // //                     opacity: animationValue,
// // //                     child: ProfessionalGridWebSeriesCard(
// // //                       webSeries: widget.webSeriesList[index],
// // //                       focusNode: gridFocusNodes[index]!,
// // //                       onTap: () => _navigateToWebSeriesDetails(widget.webSeriesList[index], index),
// // //                       index: index,
// // //                       categoryTitle: widget.title,
// // //                     ),
// // //                   ),
// // //                 );
// // //               },
// // //             );
// // //           },
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _fadeController.dispose();
// // //     _staggerController.dispose();
// // //     _scrollController.dispose();
// // //     for (var node in gridFocusNodes.values) {
// // //       try {
// // //         node.dispose();
// // //       } catch (e) {}
// // //     }
// // //     super.dispose();
// // //   }
// // // }

// // // ✅ Professional Loading Indicator
// // class ProfessionalWebSeriesLoadingIndicator extends StatefulWidget {
// //   final String message;

// //   const ProfessionalWebSeriesLoadingIndicator({
// //     Key? key,
// //     this.message = 'Loading Web Series...',
// //   }) : super(key: key);

// //   @override
// //   _ProfessionalWebSeriesLoadingIndicatorState createState() =>
// //       _ProfessionalWebSeriesLoadingIndicatorState();
// // }

// // class _ProfessionalWebSeriesLoadingIndicatorState extends State<ProfessionalWebSeriesLoadingIndicator>
// //     with TickerProviderStateMixin {
// //   late AnimationController _controller;
// //   late Animation<double> _animation;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _controller = AnimationController(
// //       duration: const Duration(milliseconds: 1500),
// //       vsync: this,
// //     )..repeat();

// //     _animation = Tween<double>(
// //       begin: 0.0,
// //       end: 1.0,
// //     ).animate(_controller);
// //   }

// //   @override
// //   void dispose() {
// //     _controller.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           AnimatedBuilder(
// //             animation: _animation,
// //             builder: (context, child) {
// //               return Container(
// //                 width: 70,
// //                 height: 70,
// //                 decoration: BoxDecoration(
// //                   shape: BoxShape.circle,
// //                   gradient: SweepGradient(
// //                     colors: [
// //                       ProfessionalColors.accentPurple,
// //                       ProfessionalColors.accentBlue,
// //                       ProfessionalColors.accentPink,
// //                       ProfessionalColors.accentPurple,
// //                     ],
// //                     stops: [0.0, 0.3, 0.7, 1.0],
// //                     transform: GradientRotation(_animation.value * 2 * math.pi),
// //                   ),
// //                 ),
// //                 child: Container(
// //                   margin: const EdgeInsets.all(5),
// //                   decoration: const BoxDecoration(
// //                     shape: BoxShape.circle,
// //                     color: ProfessionalColors.primaryDark,
// //                   ),
// //                   child: const Icon(
// //                     Icons.tv_rounded,
// //                     color: ProfessionalColors.textPrimary,
// //                     size: 28,
// //                   ),
// //                 ),
// //               );
// //             },
// //           ),
// //           const SizedBox(height: 24),
// //           Text(
// //             widget.message,
// //             style: const TextStyle(
// //               color: ProfessionalColors.textPrimary,
// //               fontSize: 16,
// //               fontWeight: FontWeight.w500,
// //             ),
// //           ),
// //           const SizedBox(height: 12),
// //           Container(
// //             width: 200,
// //             height: 3,
// //             decoration: BoxDecoration(
// //               borderRadius: BorderRadius.circular(2),
// //               color: ProfessionalColors.surfaceDark,
// //             ),
// //             child: AnimatedBuilder(
// //               animation: _animation,
// //               builder: (context, child) {
// //                 return LinearProgressIndicator(
// //                   value: _animation.value,
// //                   backgroundColor: Colors.transparent,
// //                   valueColor: const AlwaysStoppedAnimation<Color>(
// //                     ProfessionalColors.accentPurple,
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // Enhanced WebSeries Grid Page - Following GenreNetworkWidget Pattern
// // class ProfessionalWebSeriesGridPage extends StatefulWidget {
// //   final List<WebSeriesModel> webSeriesList;
// //   final String title;

// //   const ProfessionalWebSeriesGridPage({
// //     Key? key,
// //     required this.webSeriesList,
// //     this.title = 'All Web Series',
// //   }) : super(key: key);

// //   @override
// //   _ProfessionalWebSeriesGridPageState createState() => _ProfessionalWebSeriesGridPageState();
// // }
// // class _ProfessionalWebSeriesGridPageState extends State<ProfessionalWebSeriesGridPage>
// //     with SingleTickerProviderStateMixin {

// //   // ✅ FIX 1: Har item ke liye FocusNode ki list banayein
// //   late List<FocusNode> _itemFocusNodes;

// //   // Focus and Navigation Management
// //   final FocusNode _widgetFocusNode = FocusNode();
// //   final ScrollController _scrollController = ScrollController();

// //   int focusedIndex = 0;
// //   bool _isVideoLoading = false;
// //   static const int _itemsPerRow = 6;
// //   static const double _gridMainAxisSpacing = 15.0;
// //   static const double _gridCrossAxisSpacing = 15.0;

// //   // Animation Controllers
// //   late AnimationController _fadeController;
// //   late Animation<double> _fadeAnimation;

// //   @override
// //   void initState() {
// //     super.initState();

// //     // ✅ FIX 2: List ko initialize karein
// //     _itemFocusNodes = List.generate(
// //       widget.webSeriesList.length,
// //       (index) => FocusNode(),
// //     );

// //     _initializeAnimations();
// //     _startAnimations();

// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (mounted && _itemFocusNodes.isNotEmpty) {
// //         // Parent par focus karein, phir pehle item par
// //         _widgetFocusNode.requestFocus();
// //         _itemFocusNodes[focusedIndex].requestFocus();
// //       }
// //     });
// //   }

// //   void _initializeAnimations() {
// //     _fadeController = AnimationController(
// //       duration: const Duration(milliseconds: 400),
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

// //   void _startAnimations() {
// //     _fadeController.forward();
// //   }

// //   @override
// //   void dispose() {
// //     _fadeController.dispose();
// //     _widgetFocusNode.dispose();
// //     _scrollController.dispose();

// //     // ✅ FIX 3: Sabhi FocusNodes ko dispose karein
// //     for (var node in _itemFocusNodes) {
// //       node.dispose();
// //     }

// //     super.dispose();
// //   }

// //   void _handleKeyNavigation(RawKeyEvent event) {
// //     if (event is! RawKeyDownEvent || _isVideoLoading) return;
// //     if (widget.webSeriesList.isEmpty) return;

// //     final totalItems = widget.webSeriesList.length;
// //     int previousIndex = focusedIndex;

// //     if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
// //       _moveUp();
// //     } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
// //       _moveDown(totalItems);
// //     } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
// //       _moveLeft();
// //     } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
// //       _moveRight(totalItems);
// //     } else if (event.logicalKey == LogicalKeyboardKey.select ||
// //                event.logicalKey == LogicalKeyboardKey.enter) {
// //       _handleSelectAction();
// //     }

// //     if (previousIndex != focusedIndex) {
// //       // ✅ FIX 4: Purane scroll function ki jagah naya function call karein
// //       _updateAndScrollToFocus();
// //       HapticFeedback.lightImpact();
// //     }
// //   }

// //   void _safeSetState(VoidCallback fn) {
// //     if (mounted) {
// //       setState(fn);
// //     }
// //   }

// //   void _moveUp() {
// //     if (focusedIndex >= _itemsPerRow) {
// //       _safeSetState(() => focusedIndex -= _itemsPerRow);
// //     }
// //   }

// //   void _moveDown(int totalItems) {
// //     final nextRowStartIndex = focusedIndex + _itemsPerRow;
// //     if (nextRowStartIndex < totalItems) {
// //       _safeSetState(() => focusedIndex = math.min(nextRowStartIndex, totalItems - 1));
// //     }
// //   }

// //   void _moveLeft() {
// //     if (focusedIndex % _itemsPerRow != 0) {
// //       _safeSetState(() => focusedIndex--);
// //     }
// //   }

// //   void _moveRight(int totalItems) {
// //     if (focusedIndex % _itemsPerRow != _itemsPerRow - 1 && focusedIndex < totalItems - 1) {
// //       _safeSetState(() => focusedIndex++);
// //     }
// //   }

// //   void _handleSelectAction() {
// //     if (focusedIndex < widget.webSeriesList.length) {
// //       _navigateToWebSeriesDetails(widget.webSeriesList[focusedIndex], focusedIndex);
// //     }
// //   }

// //   // ❌ Apna purana `_scrollToFocusedItem` function DELETE kar dein

// //   // ✅ FIX 5: Naya aur reliable scroll function ADD karein
// //   void _updateAndScrollToFocus() {
// //     if (!mounted || focusedIndex >= _itemFocusNodes.length) return;

// //     final focusNode = _itemFocusNodes[focusedIndex];
// //     focusNode.requestFocus();

// //     Scrollable.ensureVisible(
// //       focusNode.context!,
// //       duration: const Duration(milliseconds: 300),
// //       curve: Curves.easeInOutCubic,
// //       alignment: 0.5, // Item ko screen ke beech mein laane ki koshish karega
// //     );
// //   }

// //   void _navigateToWebSeriesDetails(WebSeriesModel webSeries, int index) {
// //     if (_isVideoLoading) return;

// //     _safeSetState(() {
// //       _isVideoLoading = true;
// //     });

// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) => WebSeriesDetailsPage(
// //           id: webSeries.id,
// //           banner: webSeries.banner ?? webSeries.poster ?? '',
// //           poster: webSeries.poster ?? webSeries.banner ?? '',
// //           name: webSeries.name,
// //         ),
// //       ),
// //     ).then((_) {
// //       if (mounted) {
// //         _safeSetState(() {
// //           _isVideoLoading = false;
// //         });

// //         Future.delayed(Duration(milliseconds: 300), () {
// //           if (mounted) {
// //             _safeSetState(() {
// //               focusedIndex = index;
// //             });
// //             _widgetFocusNode.requestFocus();
// //             _updateAndScrollToFocus(); // Use new method
// //           }
// //         });
// //       }
// //     }).catchError((error) {
// //       if (mounted) {
// //         _safeSetState(() {
// //           _isVideoLoading = false;
// //         });
// //       }
// //     });
// //   }

// //   Future<void> _handleRefresh() async {
// //     try {
// //       _safeSetState(() {
// //         focusedIndex = 0;
// //       });
// //       _updateAndScrollToFocus(); // Use new method
// //     } catch (e) {
// //       print('❌ Refresh error: $e');
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: ProfessionalColors.primaryDark,
// //       body: Container(
// //         decoration: BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [
// //               ProfessionalColors.primaryDark,
// //               ProfessionalColors.surfaceDark.withOpacity(0.8),
// //               ProfessionalColors.primaryDark,
// //             ],
// //           ),
// //         ),
// //         child: Stack(
// //           children: [
// //             Column(
// //               children: [
// //                 _buildProfessionalAppBar(),
// //                 Expanded(
// //                   child: FadeTransition(
// //                     opacity: _fadeAnimation,
// //                     child: RawKeyboardListener(
// //                       focusNode: _widgetFocusNode,
// //                       onKey: _handleKeyNavigation,
// //                       autofocus: true,
// //                       child: RefreshIndicator(
// //                         onRefresh: _handleRefresh,
// //                         color: ProfessionalColors.accentPurple,
// //                         backgroundColor: ProfessionalColors.cardDark,
// //                         child: _buildContent(),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             if (_isVideoLoading)
// //               Positioned.fill(
// //                 child: Container(
// //                   color: Colors.black.withOpacity(0.7),
// //                   child: const Center(
// //                     child: ProfessionalWebSeriesLoadingIndicator(
// //                       message: 'Loading Web Series...',
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildProfessionalAppBar() {
// //     // Is function mein koi badlav nahi
// //     return Container(
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.topCenter,
// //           end: Alignment.bottomCenter,
// //           colors: [
// //             ProfessionalColors.primaryDark.withOpacity(0.98),
// //             ProfessionalColors.surfaceDark.withOpacity(0.95),
// //             ProfessionalColors.surfaceDark.withOpacity(0.9),
// //             Colors.transparent,
// //           ],
// //         ),
// //         border: Border(
// //           bottom: BorderSide(
// //             color: ProfessionalColors.accentPurple.withOpacity(0.3),
// //             width: 1,
// //           ),
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.4),
// //             blurRadius: 15,
// //             offset: const Offset(0, 3),
// //           ),
// //         ],
// //       ),
// //       child: ClipRRect(
// //         child: BackdropFilter(
// //           filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
// //           child: Container(
// //             padding: EdgeInsets.only(
// //               top: MediaQuery.of(context).padding.top + 15,
// //               left: 40,
// //               right: 40,
// //               bottom: 15,
// //             ),
// //             child: Row(
// //               children: [
// //                 Container(
// //                   decoration: BoxDecoration(
// //                     shape: BoxShape.circle,
// //                     gradient: LinearGradient(
// //                       colors: [
// //                         ProfessionalColors.accentPurple.withOpacity(0.4),
// //                         ProfessionalColors.accentBlue.withOpacity(0.4),
// //                       ],
// //                     ),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: ProfessionalColors.accentPurple.withOpacity(0.4),
// //                         blurRadius: 10,
// //                         offset: const Offset(0, 3),
// //                       ),
// //                     ],
// //                   ),
// //                   child: IconButton(
// //                     icon: const Icon(
// //                       Icons.arrow_back_rounded,
// //                       color: Colors.white,
// //                       size: 24,
// //                     ),
// //                     onPressed: () => Navigator.pop(context),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 16),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       ShaderMask(
// //                         shaderCallback: (bounds) => const LinearGradient(
// //                           colors: [
// //                             ProfessionalColors.accentPurple,
// //                             ProfessionalColors.accentBlue,
// //                           ],
// //                         ).createShader(bounds),
// //                         child: Text(
// //                           widget.title.toUpperCase(),
// //                           style: TextStyle(
// //                             color: Colors.white,
// //                             fontSize: 24,
// //                             fontWeight: FontWeight.w700,
// //                             letterSpacing: 1.0,
// //                             shadows: [
// //                               Shadow(
// //                                 color: Colors.black.withOpacity(0.8),
// //                                 blurRadius: 6,
// //                                 offset: const Offset(0, 2),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 6),
// //                       Container(
// //                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //                         decoration: BoxDecoration(
// //                           gradient: LinearGradient(
// //                             colors: [
// //                               ProfessionalColors.accentPurple.withOpacity(0.4),
// //                               ProfessionalColors.accentBlue.withOpacity(0.3),
// //                             ],
// //                           ),
// //                           borderRadius: BorderRadius.circular(15),
// //                           border: Border.all(
// //                             color: ProfessionalColors.accentPurple.withOpacity(0.6),
// //                             width: 1,
// //                           ),
// //                         ),
// //                         child: Text(
// //                           '${widget.webSeriesList.length} Web Series Available',
// //                           style: const TextStyle(
// //                             color: Colors.white,
// //                             fontSize: 12,
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildContent() {
// //     if (widget.webSeriesList.isEmpty) {
// //       return _buildEmptyWidget();
// //     } else {
// //       return _buildGridView();
// //     }
// //   }

// //   Widget _buildEmptyWidget() {
// //     // Is function mein koi badlav nahi
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Container(
// //             width: 80,
// //             height: 80,
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               gradient: LinearGradient(
// //                 colors: [
// //                   ProfessionalColors.accentPurple.withOpacity(0.2),
// //                   ProfessionalColors.accentPurple.withOpacity(0.1),
// //                 ],
// //               ),
// //             ),
// //             child: const Icon(
// //               Icons.tv_outlined,
// //               size: 40,
// //               color: ProfessionalColors.accentPurple,
// //             ),
// //           ),
// //           const SizedBox(height: 24),
// //           Text(
// //             'No ${widget.title} Found',
// //             style: TextStyle(
// //               color: ProfessionalColors.textPrimary,
// //               fontSize: 18,
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //           const SizedBox(height: 8),
// //           const Text(
// //             'Pull down to refresh',
// //             style: TextStyle(
// //               color: ProfessionalColors.textSecondary,
// //               fontSize: 14,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildGridView() {
// //     return Padding(
// //       padding: EdgeInsets.all(20),
// //       child: GridView.builder(
// //         controller: _scrollController,
// //         physics: const AlwaysScrollableScrollPhysics(),
// //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //           crossAxisCount: _itemsPerRow,
// //           crossAxisSpacing: _gridCrossAxisSpacing,
// //           mainAxisSpacing: _gridMainAxisSpacing,
// //           childAspectRatio: 1.5,
// //         ),
// //         clipBehavior: Clip.none,
// //         itemCount: widget.webSeriesList.length,
// //         itemBuilder: (context, index) {
// //           // ✅ FIX 6: Card ko 'Focus' widget se wrap karein
// //           return Focus(
// //             focusNode: _itemFocusNodes[index],
// //             child: _buildWebSeriesGridItem(widget.webSeriesList[index], index),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildWebSeriesGridItem(WebSeriesModel webSeries, int index) {
// //     final isFocused = focusedIndex == index;
// //     return OptimizedWebSeriesGridCard(
// //       webSeries: webSeries,
// //       isFocused: isFocused,
// //       onTap: () => _navigateToWebSeriesDetails(webSeries, index),
// //       index: index,
// //       categoryTitle: widget.title,
// //     );
// //   }
// // }

// // // Optimized WebSeries Grid Card - Following the Content Card pattern
// // class OptimizedWebSeriesGridCard extends StatelessWidget {
// //   final WebSeriesModel webSeries;
// //   final bool isFocused;
// //   final VoidCallback onTap;
// //   final int index;
// //   final String categoryTitle;

// //   const OptimizedWebSeriesGridCard({
// //     Key? key,
// //     required this.webSeries,
// //     required this.isFocused,
// //     required this.onTap,
// //     required this.index,
// //     required this.categoryTitle,
// //   }) : super(key: key);

// //   Color _getDominantColor() {
// //     final colors = ProfessionalColors.gradientColors;
// //     return colors[math.Random(webSeries.id).nextInt(colors.length)];
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final dominantColor = _getDominantColor();

// //     return Container(
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(15),
// //         border: isFocused
// //             ? Border.all(
// //                 color: dominantColor,
// //                 width: 3,
// //               )
// //             : null,
// //         boxShadow: [
// //           if (isFocused) ...[
// //             BoxShadow(
// //               color: dominantColor.withOpacity(0.4),
// //               blurRadius: 20,
// //               spreadRadius: 2,
// //               offset: const Offset(0, 8),
// //             ),
// //             BoxShadow(
// //               color: dominantColor.withOpacity(0.2),
// //               blurRadius: 35,
// //               spreadRadius: 4,
// //               offset: const Offset(0, 12),
// //             ),
// //           ] else ...[
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.3),
// //               blurRadius: 8,
// //               spreadRadius: 1,
// //               offset: const Offset(0, 4),
// //             ),
// //           ],
// //         ],
// //       ),
// //       child: ClipRRect(
// //         borderRadius: BorderRadius.circular(15),
// //         child: Stack(
// //           children: [
// //             _buildWebSeriesImage(),
// //             _buildGradientOverlay(),
// //             _buildWebSeriesInfo(dominantColor),
// //             if (isFocused) _buildPlayButton(dominantColor),
// //             _buildGenreBadge(),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildWebSeriesImage() {
// //     return Container(
// //       width: double.infinity,
// //       height: double.infinity,
// //       child: _buildImageWidget(),
// //     );
// //   }

// //   Widget _buildImageWidget() {
// //     if (webSeries.banner != null && webSeries.banner!.isNotEmpty) {
// //       return CachedNetworkImage(
// //         imageUrl: webSeries.banner!,
// //         fit: BoxFit.cover,
// //         memCacheWidth: 300,
// //         memCacheHeight: 400,
// //         maxWidthDiskCache: 300,
// //         maxHeightDiskCache: 400,
// //         placeholder: (context, url) => _buildImagePlaceholder(),
// //         errorWidget: (context, url, error) => _buildPosterWidget(),
// //       );
// //     } else {
// //       return _buildPosterWidget();
// //     }
// //   }

// //   Widget _buildPosterWidget() {
// //     if (webSeries.poster != null && webSeries.poster!.isNotEmpty) {
// //       return CachedNetworkImage(
// //         imageUrl: webSeries.poster!,
// //         fit: BoxFit.cover,
// //         memCacheWidth: 300,
// //         memCacheHeight: 400,
// //         maxWidthDiskCache: 300,
// //         maxHeightDiskCache: 400,
// //         placeholder: (context, url) => _buildImagePlaceholder(),
// //         errorWidget: (context, url, error) => _buildImagePlaceholder(),
// //       );
// //     } else {
// //       return _buildImagePlaceholder();
// //     }
// //   }

// //   Widget _buildImagePlaceholder() {
// //     return Container(
// //       decoration: const BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //           colors: [
// //             ProfessionalColors.cardDark,
// //             ProfessionalColors.surfaceDark,
// //           ],
// //         ),
// //       ),
// //       child: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             const Icon(
// //               Icons.tv_outlined,
// //               size: 40,
// //               color: ProfessionalColors.textSecondary,
// //             ),
// //             const SizedBox(height: 8),
// //             Text(
// //               'WEB SERIES',
// //               style: TextStyle(
// //                 color: ProfessionalColors.textSecondary,
// //                 fontSize: 10,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             const SizedBox(height: 4),
// //             Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //               decoration: BoxDecoration(
// //                 color: ProfessionalColors.accentPurple.withOpacity(0.2),
// //                 borderRadius: BorderRadius.circular(6),
// //               ),
// //               child: const Text(
// //                 'HD',
// //                 style: TextStyle(
// //                   color: ProfessionalColors.accentPurple,
// //                   fontSize: 8,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildGradientOverlay() {
// //     return Positioned.fill(
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(15),
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [
// //               Colors.transparent,
// //               Colors.transparent,
// //               Colors.black.withOpacity(0.7),
// //               Colors.black.withOpacity(0.9),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildWebSeriesInfo(Color dominantColor) {
// //     return Positioned(
// //       bottom: 0,
// //       left: 0,
// //       right: 0,
// //       child: Padding(
// //         padding: const EdgeInsets.all(12),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Text(
// //               webSeries.name.toUpperCase(),
// //               style: TextStyle(
// //                 color: isFocused ? dominantColor : Colors.white,
// //                 fontSize: isFocused ? 13 : 12,
// //                 fontWeight: FontWeight.w600,
// //                 letterSpacing: 0.5,
// //                 shadows: [
// //                   Shadow(
// //                     color: Colors.black.withOpacity(0.8),
// //                     blurRadius: 4,
// //                     offset: const Offset(0, 1),
// //                   ),
// //                 ],
// //               ),
// //               maxLines: 2,
// //               overflow: TextOverflow.ellipsis,
// //             ),
// //             if (isFocused && webSeries.genres != null) ...[
// //               const SizedBox(height: 4),
// //               Container(
// //                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //                 decoration: BoxDecoration(
// //                   color: dominantColor.withOpacity(0.3),
// //                   borderRadius: BorderRadius.circular(8),
// //                   border: Border.all(
// //                     color: dominantColor.withOpacity(0.5),
// //                     width: 1,
// //                   ),
// //                 ),
// //                 child: Text(
// //                   webSeries.genres!.toUpperCase(),
// //                   style: TextStyle(
// //                     color: dominantColor,
// //                     fontSize: 8,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildPlayButton(Color dominantColor) {
// //     return Positioned(
// //       top: 12,
// //       right: 12,
// //       child: Container(
// //         width: 40,
// //         height: 40,
// //         decoration: BoxDecoration(
// //           shape: BoxShape.circle,
// //           color: dominantColor.withOpacity(0.9),
// //           boxShadow: [
// //             BoxShadow(
// //               color: dominantColor.withOpacity(0.4),
// //               blurRadius: 8,
// //               offset: const Offset(0, 2),
// //             ),
// //           ],
// //         ),
// //         child: const Icon(
// //           Icons.play_arrow_rounded,
// //           color: Colors.white,
// //           size: 24,
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildGenreBadge() {
// //     String genre = 'SERIES';
// //     Color badgeColor = ProfessionalColors.accentPurple;

// //     if (webSeries.genres != null) {
// //       if (webSeries.genres!.toLowerCase().contains('drama')) {
// //         genre = 'DRAMA';
// //         badgeColor = ProfessionalColors.accentPurple;
// //       } else if (webSeries.genres!.toLowerCase().contains('thriller')) {
// //         genre = 'THRILLER';
// //         badgeColor = ProfessionalColors.accentRed;
// //       } else if (webSeries.genres!.toLowerCase().contains('comedy')) {
// //         genre = 'COMEDY';
// //         badgeColor = ProfessionalColors.accentGreen;
// //       } else if (webSeries.genres!.toLowerCase().contains('romance')) {
// //         genre = 'ROMANCE';
// //         badgeColor = ProfessionalColors.accentPink;
// //       }
// //     }

// //     return Positioned(
// //       top: 8,
// //       left: 8,
// //       child: Container(
// //         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
// //         decoration: BoxDecoration(
// //           color: badgeColor.withOpacity(0.9),
// //           borderRadius: BorderRadius.circular(6),
// //         ),
// //         child: Text(
// //           genre,
// //           style: const TextStyle(
// //             color: Colors.white,
// //             fontSize: 8,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // ✅ Professional Grid WebSeries Card
// // class ProfessionalGridWebSeriesCard extends StatefulWidget {
// //   final WebSeriesModel webSeries;
// //   final FocusNode focusNode;
// //   final VoidCallback onTap;
// //   final int index;
// //   final String categoryTitle;

// //   const ProfessionalGridWebSeriesCard({
// //     Key? key,
// //     required this.webSeries,
// //     required this.focusNode,
// //     required this.onTap,
// //     required this.index,
// //     required this.categoryTitle,
// //   }) : super(key: key);

// //   @override
// //   _ProfessionalGridWebSeriesCardState createState() => _ProfessionalGridWebSeriesCardState();
// // }

// // class _ProfessionalGridWebSeriesCardState extends State<ProfessionalGridWebSeriesCard>
// //     with TickerProviderStateMixin {
// //   late AnimationController _hoverController;
// //   late AnimationController _glowController;
// //   late Animation<double> _scaleAnimation;
// //   late Animation<double> _glowAnimation;

// //   Color _dominantColor = ProfessionalColors.accentPurple;
// //   bool _isFocused = false;

// //   @override
// //   void initState() {
// //     super.initState();

// //     _hoverController = AnimationController(
// //       duration: AnimationTiming.slow,
// //       vsync: this,
// //     );

// //     _glowController = AnimationController(
// //       duration: AnimationTiming.medium,
// //       vsync: this,
// //     );

// //     _scaleAnimation = Tween<double>(
// //       begin: 1.0,
// //       end: 1.05,
// //     ).animate(CurvedAnimation(
// //       parent: _hoverController,
// //       curve: Curves.easeOutCubic,
// //     ));

// //     _glowAnimation = Tween<double>(
// //       begin: 0.0,
// //       end: 1.0,
// //     ).animate(CurvedAnimation(
// //       parent: _glowController,
// //       curve: Curves.easeInOut,
// //     ));

// //     widget.focusNode.addListener(_handleFocusChange);
// //   }

// //   void _handleFocusChange() {
// //     setState(() {
// //       _isFocused = widget.focusNode.hasFocus;
// //     });

// //     if (_isFocused) {
// //       _hoverController.forward();
// //       _glowController.forward();
// //       _generateDominantColor();
// //       HapticFeedback.lightImpact();
// //     } else {
// //       _hoverController.reverse();
// //       _glowController.reverse();
// //     }
// //   }

// //   void _generateDominantColor() {
// //     final colors = ProfessionalColors.gradientColors;
// //     _dominantColor = colors[math.Random().nextInt(colors.length)];
// //   }

// //   @override
// //   void dispose() {
// //     _hoverController.dispose();
// //     _glowController.dispose();
// //     widget.focusNode.removeListener(_handleFocusChange);
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Focus(
// //       focusNode: widget.focusNode,
// //       onKey: (node, event) {
// //         if (event is RawKeyDownEvent) {
// //           if (event.logicalKey == LogicalKeyboardKey.select ||
// //               event.logicalKey == LogicalKeyboardKey.enter) {
// //             widget.onTap();
// //             return KeyEventResult.handled;
// //           }
// //         }
// //         return KeyEventResult.ignored;
// //       },
// //       child: GestureDetector(
// //         onTap: widget.onTap,
// //         child: AnimatedBuilder(
// //           animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
// //           builder: (context, child) {
// //             return Transform.scale(
// //               scale: _scaleAnimation.value,
// //               child: Container(
// //                 decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.circular(15),
// //                   boxShadow: [
// //                     if (_isFocused) ...[
// //                       BoxShadow(
// //                         color: _dominantColor.withOpacity(0.4),
// //                         blurRadius: 20,
// //                         spreadRadius: 2,
// //                         offset: const Offset(0, 8),
// //                       ),
// //                       BoxShadow(
// //                         color: _dominantColor.withOpacity(0.2),
// //                         blurRadius: 35,
// //                         spreadRadius: 4,
// //                         offset: const Offset(0, 12),
// //                       ),
// //                     ] else ...[
// //                       BoxShadow(
// //                         color: Colors.black.withOpacity(0.3),
// //                         blurRadius: 8,
// //                         spreadRadius: 1,
// //                         offset: const Offset(0, 4),
// //                       ),
// //                     ],
// //                   ],
// //                 ),
// //                 child: ClipRRect(
// //                   borderRadius: BorderRadius.circular(15),
// //                   child: Stack(
// //                     children: [
// //                       _buildWebSeriesImage(),
// //                       if (_isFocused) _buildFocusBorder(),
// //                       _buildGradientOverlay(),
// //                       _buildWebSeriesInfo(),
// //                       if (_isFocused) _buildPlayButton(),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildWebSeriesImage() {
// //     return Container(
// //       width: double.infinity,
// //       height: double.infinity,
// //       child: widget.webSeries.banner != null && widget.webSeries.banner!.isNotEmpty
// //           ? Image.network(
// //               widget.webSeries.banner!,
// //               fit: BoxFit.cover,
// //               loadingBuilder: (context, child, loadingProgress) {
// //                 if (loadingProgress == null) return child;
// //                 return _buildImagePlaceholder();
// //               },
// //               errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
// //             )
// //           : _buildImagePlaceholder(),
// //     );
// //   }

// //   Widget _buildImagePlaceholder() {
// //     return Container(
// //       decoration: const BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //           colors: [
// //             ProfessionalColors.cardDark,
// //             ProfessionalColors.surfaceDark,
// //           ],
// //         ),
// //       ),
// //       child: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             const Icon(
// //               Icons.tv_outlined,
// //               size: 40,
// //               color: ProfessionalColors.textSecondary,
// //             ),
// //             const SizedBox(height: 8),
// //             Text(
// //               'WEB SERIES',
// //               style: TextStyle(
// //                 color: ProfessionalColors.textSecondary,
// //                 fontSize: 10,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             const SizedBox(height: 4),
// //             Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //               decoration: BoxDecoration(
// //                 color: ProfessionalColors.accentPurple.withOpacity(0.2),
// //                 borderRadius: BorderRadius.circular(6),
// //               ),
// //               child: const Text(
// //                 'HD',
// //                 style: TextStyle(
// //                   color: ProfessionalColors.accentPurple,
// //                   fontSize: 8,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildFocusBorder() {
// //     return Positioned.fill(
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(15),
// //           border: Border.all(
// //             width: 3,
// //             color: _dominantColor,
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildGradientOverlay() {
// //     return Positioned.fill(
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(15),
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [
// //               Colors.transparent,
// //               Colors.transparent,
// //               Colors.black.withOpacity(0.7),
// //               Colors.black.withOpacity(0.9),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildWebSeriesInfo() {
// //     final webSeriesName = widget.webSeries.name;

// //     return Positioned(
// //       bottom: 0,
// //       left: 0,
// //       right: 0,
// //       child: Padding(
// //         padding: const EdgeInsets.all(12),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Text(
// //               webSeriesName.toUpperCase(),
// //               style: TextStyle(
// //                 color: _isFocused ? _dominantColor : Colors.white,
// //                 fontSize: _isFocused ? 13 : 12,
// //                 fontWeight: FontWeight.w600,
// //                 letterSpacing: 0.5,
// //                 shadows: [
// //                   Shadow(
// //                     color: Colors.black.withOpacity(0.8),
// //                     blurRadius: 4,
// //                     offset: const Offset(0, 1),
// //                   ),
// //                 ],
// //               ),
// //               maxLines: 2,
// //               overflow: TextOverflow.ellipsis,
// //             ),
// //             if (_isFocused && widget.webSeries.genres != null) ...[
// //               const SizedBox(height: 4),
// //               Row(
// //                 children: [
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //                     decoration: BoxDecoration(
// //                       color: ProfessionalColors.accentPurple.withOpacity(0.3),
// //                       borderRadius: BorderRadius.circular(8),
// //                       border: Border.all(
// //                         color: ProfessionalColors.accentPurple.withOpacity(0.5),
// //                         width: 1,
// //                       ),
// //                     ),
// //                     child: Text(
// //                       widget.webSeries.genres!.toUpperCase(),
// //                       style: const TextStyle(
// //                         color: ProfessionalColors.accentPurple,
// //                         fontSize: 8,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 8),
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //                     decoration: BoxDecoration(
// //                       color: _dominantColor.withOpacity(0.2),
// //                       borderRadius: BorderRadius.circular(8),
// //                       border: Border.all(
// //                         color: _dominantColor.withOpacity(0.4),
// //                         width: 1,
// //                       ),
// //                     ),
// //                     child: Text(
// //                       'SERIES',
// //                       style: TextStyle(
// //                         color: _dominantColor,
// //                         fontSize: 8,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildPlayButton() {
// //     return Positioned(
// //       top: 12,
// //       right: 12,
// //       child: Container(
// //         width: 40,
// //         height: 40,
// //         decoration: BoxDecoration(
// //           shape: BoxShape.circle,
// //           color: _dominantColor.withOpacity(0.9),
// //           boxShadow: [
// //             BoxShadow(
// //               color: _dominantColor.withOpacity(0.4),
// //               blurRadius: 8,
// //               offset: const Offset(0, 2),
// //             ),
// //           ],
// //         ),
// //         child: const Icon(
// //           Icons.play_arrow_rounded,
// //           color: Colors.white,
// //           size: 24,
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobi_tv_entertainment/home_screen_pages/webseries_screen/webseries_details_page.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:provider/provider.dart';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:math' as math;
// import 'dart:ui';

// // ✅ Professional Color Palette (same as Movies)
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

// // ✅ Professional Animation Durations
// class AnimationTiming {
//   static const Duration ultraFast = Duration(milliseconds: 150);
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
//   static const Duration slow = Duration(milliseconds: 600);
//   static const Duration focus = Duration(milliseconds: 300);
//   static const Duration scroll = Duration(milliseconds: 800);
// }

// // ✅ WebSeries Model (same structure)
// class WebSeriesModel {
//   final int id;
//   final String name;
//   final String? description;
//   final String? poster;
//   final String? banner;
//   final String? releaseDate;
//   final String? genres;

//   WebSeriesModel({
//     required this.id,
//     required this.name,
//     this.description,
//     this.poster,
//     this.banner,
//     this.releaseDate,
//     this.genres,
//   });

//   factory WebSeriesModel.fromJson(Map<String, dynamic> json) {
//     return WebSeriesModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       description: json['description'],
//       poster: json['poster'],
//       banner: json['banner'],
//       releaseDate: json['release_date'],
//       genres: json['genres'],
//     );
//   }
// }

// // 🚀 Enhanced WebSeries Service with Caching (Similar to TV Shows)
// class WebSeriesService {
//   // Cache keys
//   static const String _cacheKeyWebSeries = 'cached_web_series';
//   static const String _cacheKeyTimestamp = 'cached_web_series_timestamp';
//   static const String _cacheKeyAuthKey = 'auth_key';

//   // Cache duration (in milliseconds) - 1 hour
//   static const int _cacheDurationMs = 60 * 60 * 1000; // 1 hour

//   /// Main method to get all web series with caching
//   static Future<List<WebSeriesModel>> getAllWebSeries({bool forceRefresh = false}) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       // Check if we should use cache
//       if (!forceRefresh && await _shouldUseCache(prefs)) {
//         print('📦 Loading Web Series from cache...');
//         final cachedWebSeries = await _getCachedWebSeries(prefs);
//         if (cachedWebSeries.isNotEmpty) {
//           print('✅ Successfully loaded ${cachedWebSeries.length} web series from cache');

//           // Load fresh data in background (without waiting)
//           _loadFreshDataInBackground();

//           return cachedWebSeries;
//         }
//       }

//       // Load fresh data if no cache or force refresh
//       print('🌐 Loading fresh Web Series from API...');
//       return await _fetchFreshWebSeries(prefs);

//     } catch (e) {
//       print('❌ Error in getAllWebSeries: $e');

//       // Try to return cached data as fallback
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         final cachedWebSeries = await _getCachedWebSeries(prefs);
//         if (cachedWebSeries.isNotEmpty) {
//           print('🔄 Returning cached data as fallback');
//           return cachedWebSeries;
//         }
//       } catch (cacheError) {
//         print('❌ Cache fallback also failed: $cacheError');
//       }

//       throw Exception('Failed to load web series: $e');
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
//         print('📦 WebSeries Cache is valid (${ageMinutes} minutes old)');
//       } else {
//         final ageMinutes = (cacheAge / (1000 * 60)).round();
//         print('⏰ WebSeries Cache expired (${ageMinutes} minutes old)');
//       }

//       return isValid;
//     } catch (e) {
//       print('❌ Error checking WebSeries cache validity: $e');
//       return false;
//     }
//   }

//   /// Get web series from cache
//   static Future<List<WebSeriesModel>> _getCachedWebSeries(SharedPreferences prefs) async {
//     try {
//       final cachedData = prefs.getString(_cacheKeyWebSeries);
//       if (cachedData == null || cachedData.isEmpty) {
//         print('📦 No cached WebSeries data found');
//         return [];
//       }

//       final List<dynamic> jsonData = json.decode(cachedData);
//       final webSeries = jsonData
//           .map((json) => WebSeriesModel.fromJson(json as Map<String, dynamic>))
//           .toList();

//       print('📦 Successfully loaded ${webSeries.length} web series from cache');
//       return webSeries;
//     } catch (e) {
//       print('❌ Error loading cached web series: $e');
//       return [];
//     }
//   }

//   /// Fetch fresh web series from API and cache them
//   static Future<List<WebSeriesModel>> _fetchFreshWebSeries(SharedPreferences prefs) async {
//     try {
//       String authKey = prefs.getString(_cacheKeyAuthKey) ?? '';

//       final response = await http.get(
//         Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       ).timeout(
//         const Duration(seconds: 30),
//         onTimeout: () {
//           throw Exception('Request timeout');
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);

//         final webSeries = jsonData
//             .map((json) => WebSeriesModel.fromJson(json as Map<String, dynamic>))
//             .toList();

//         // Cache the fresh data
//         await _cacheWebSeries(prefs, jsonData);

//         print('✅ Successfully loaded ${webSeries.length} fresh web series from API');
//         return webSeries;

//       } else {
//         throw Exception('API Error: ${response.statusCode} - ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('❌ Error fetching fresh web series: $e');
//       rethrow;
//     }
//   }

//   /// Cache web series data
//   static Future<void> _cacheWebSeries(SharedPreferences prefs, List<dynamic> webSeriesData) async {
//     try {
//       final jsonString = json.encode(webSeriesData);
//       final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

//       // Save web series data and timestamp
//       await Future.wait([
//         prefs.setString(_cacheKeyWebSeries, jsonString),
//         prefs.setString(_cacheKeyTimestamp, currentTimestamp),
//       ]);

//       print('💾 Successfully cached ${webSeriesData.length} web series');
//     } catch (e) {
//       print('❌ Error caching web series: $e');
//     }
//   }

//   /// Load fresh data in background without blocking UI
//   static void _loadFreshDataInBackground() {
//     Future.delayed(const Duration(milliseconds: 500), () async {
//       try {
//         print('🔄 Loading fresh web series data in background...');
//         final prefs = await SharedPreferences.getInstance();
//         await _fetchFreshWebSeries(prefs);
//         print('✅ WebSeries background refresh completed');
//       } catch (e) {
//         print('⚠️ WebSeries background refresh failed: $e');
//       }
//     });
//   }

//   /// Clear all cached data
//   static Future<void> clearCache() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await Future.wait([
//         prefs.remove(_cacheKeyWebSeries),
//         prefs.remove(_cacheKeyTimestamp),
//       ]);
//       print('🗑️ WebSeries cache cleared successfully');
//     } catch (e) {
//       print('❌ Error clearing WebSeries cache: $e');
//     }
//   }

//   /// Get cache info for debugging
//   static Future<Map<String, dynamic>> getCacheInfo() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final timestampStr = prefs.getString(_cacheKeyTimestamp);
//       final cachedData = prefs.getString(_cacheKeyWebSeries);

//       if (timestampStr == null || cachedData == null) {
//         return {
//           'hasCachedData': false,
//           'cacheAge': 0,
//           'cachedWebSeriesCount': 0,
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
//         'cachedWebSeriesCount': jsonData.length,
//         'cacheSize': cacheSizeKB,
//         'isValid': cacheAge < _cacheDurationMs,
//       };
//     } catch (e) {
//       print('❌ Error getting WebSeries cache info: $e');
//       return {
//         'hasCachedData': false,
//         'cacheAge': 0,
//         'cachedWebSeriesCount': 0,
//         'cacheSize': 0,
//         'error': e.toString(),
//       };
//     }
//   }

//   /// Force refresh data (bypass cache)
//   static Future<List<WebSeriesModel>> forceRefresh() async {
//     print('🔄 Force refreshing WebSeries data...');
//     return await getAllWebSeries(forceRefresh: true);
//   }
// }

// // 🚀 Enhanced ProfessionalWebSeriesHorizontalList with Caching
// class ProfessionalWebSeriesHorizontalList extends StatefulWidget {
//   @override
//   _ProfessionalWebSeriesHorizontalListState createState() =>
//       _ProfessionalWebSeriesHorizontalListState();
// }

// class _ProfessionalWebSeriesHorizontalListState
//     extends State<ProfessionalWebSeriesHorizontalList>
//     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
//   @override
//   bool get wantKeepAlive => true;

//   List<WebSeriesModel> webSeriesList = [];
//   bool isLoading = true;
//   int focusedIndex = -1;
//   final int maxHorizontalItems = 7;
//   Color _currentAccentColor = ProfessionalColors.accentPurple;

//   // Animation Controllers
//   late AnimationController _headerAnimationController;
//   late AnimationController _listAnimationController;
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<double> _listFadeAnimation;

//   Map<String, FocusNode> webseriesFocusNodes = {};
//   FocusNode? _viewAllFocusNode;
//   FocusNode? _firstWebSeriesFocusNode;
//   bool _hasReceivedFocusFromMovies = false;

//   late ScrollController _scrollController;
//   final double _itemWidth = 156.0;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _initializeAnimations();
//     _initializeFocusNodes();

//     // 🚀 Use enhanced caching service
//     fetchWebSeriesWithCache();
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

//   void _initializeFocusNodes() {
//     _viewAllFocusNode = FocusNode();
//     print('✅ WebSeries focus nodes initialized');
//   }

//   // ✅ UPDATED: Scrolling logic to match movies list
//   void _scrollToPosition(int index) {
//     if (!mounted || !_scrollController.hasClients) return;

//     try {
//       double bannerwidth = bannerwdt;

//       if (index != -1) {
//         // Simple scroll calculation from movies list
//         double scrollPosition = index * bannerwidth;

//         _scrollController.animateTo(
//           scrollPosition,
//           duration: const Duration(milliseconds: 500),
//           curve: Curves.easeOut,
//         );
//       }
//     } catch (e) {
//       // Silent fail
//       print('Error scrolling in webseries: $e');
//     }
//   }

//   void _setupFocusProvider() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && webSeriesList.isNotEmpty) {
//         try {
//           final focusProvider = Provider.of<FocusProvider>(context, listen: false);

//           final firstWebSeriesId = webSeriesList[0].id.toString();

//           if (!webseriesFocusNodes.containsKey(firstWebSeriesId)) {
//             webseriesFocusNodes[firstWebSeriesId] = FocusNode();
//             print('✅ Created focus node for first webseries: $firstWebSeriesId');
//           }

//           _firstWebSeriesFocusNode = webseriesFocusNodes[firstWebSeriesId];

//           _firstWebSeriesFocusNode!.addListener(() {
//             if (_firstWebSeriesFocusNode!.hasFocus && !_hasReceivedFocusFromMovies) {
//               _hasReceivedFocusFromMovies = true;
//               setState(() {
//                 focusedIndex = 0;
//               });
//               _scrollToPosition(0);
//               print('✅ WebSeries received focus from movies and scrolled');
//             }
//           });

//           focusProvider.setFirstManageWebseriesFocusNode(_firstWebSeriesFocusNode!);
//           print('✅ WebSeries first focus node registered: ${webSeriesList[0].name}');

//         } catch (e) {
//           print('❌ WebSeries focus provider setup failed: $e');
//         }
//       }
//     });
//   }

//   // 🚀 Enhanced fetch method with caching
//   Future<void> fetchWebSeriesWithCache() async {
//     if (!mounted) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       // Use cached data first, then fresh data
//       final fetchedWebSeries = await WebSeriesService.getAllWebSeries();

//       if (fetchedWebSeries.isNotEmpty) {
//         if (mounted) {
//           setState(() {
//             webSeriesList = fetchedWebSeries;
//             isLoading = false;
//           });

//           _createFocusNodesForItems();
//           _setupFocusProvider();

//           // Start animations after data loads
//           _headerAnimationController.forward();
//           _listAnimationController.forward();

//           // Debug cache info
//           _debugCacheInfo();
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//       print('Error fetching WebSeries with cache: $e');
//     }
//   }

//   // 🆕 Debug method to show cache information
//   Future<void> _debugCacheInfo() async {
//     try {
//       final cacheInfo = await WebSeriesService.getCacheInfo();
//       print('📊 WebSeries Cache Info: $cacheInfo');
//     } catch (e) {
//       print('❌ Error getting WebSeries cache info: $e');
//     }
//   }

//   // 🆕 Force refresh web series
//   Future<void> _forceRefreshWebSeries() async {
//     if (!mounted) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       // Force refresh bypasses cache
//       final fetchedWebSeries = await WebSeriesService.forceRefresh();

//       if (fetchedWebSeries.isNotEmpty) {
//         if (mounted) {
//           setState(() {
//             webSeriesList = fetchedWebSeries;
//             isLoading = false;
//           });

//           _createFocusNodesForItems();
//           _setupFocusProvider();

//           _headerAnimationController.forward();
//           _listAnimationController.forward();

//           // Show success message
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text('Web Series refreshed successfully'),
//               backgroundColor: ProfessionalColors.accentPurple,
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
//             isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//       print('❌ Error force refreshing web series: $e');
//     }
//   }

//   void _createFocusNodesForItems() {
//     for (var node in webseriesFocusNodes.values) {
//       try {
//         node.removeListener(() {});
//         node.dispose();
//       } catch (e) {}
//     }
//     webseriesFocusNodes.clear();

//     for (int i = 0; i < webSeriesList.length && i < maxHorizontalItems; i++) {
//       String webSeriesId = webSeriesList[i].id.toString();
//       if (!webseriesFocusNodes.containsKey(webSeriesId)) {
//         webseriesFocusNodes[webSeriesId] = FocusNode();

//         webseriesFocusNodes[webSeriesId]!.addListener(() {
//           if (mounted && webseriesFocusNodes[webSeriesId]!.hasFocus) {
//             setState(() {
//               focusedIndex = i;
//               _hasReceivedFocusFromMovies = true;
//             });
//             _scrollToPosition(i);
//             print('✅ WebSeries $i focused and scrolled: ${webSeriesList[i].name}');
//           }
//         });
//       }
//     }
//     print('✅ Created ${webseriesFocusNodes.length} webseries focus nodes with auto-scroll');
//   }

//   void _navigateToWebSeriesDetails(WebSeriesModel webSeries) {
//     print('🎬 Navigating to WebSeries Details: ${webSeries.name}');

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => WebSeriesDetailsPage(
//           id: webSeries.id,
//           banner: webSeries.banner ?? webSeries.poster ?? '',
//           poster: webSeries.poster ?? webSeries.banner ?? '',
//           name: webSeries.name,
//         ),
//       ),
//     ).then((_) {
//       print('🔙 Returned from WebSeries Details');
//       Future.delayed(Duration(milliseconds: 300), () {
//         if (mounted) {
//           int currentIndex = webSeriesList.indexWhere((ws) => ws.id == webSeries.id);
//           if (currentIndex != -1 && currentIndex < maxHorizontalItems) {
//             String webSeriesId = webSeries.id.toString();
//             if (webseriesFocusNodes.containsKey(webSeriesId)) {
//               setState(() {
//                 focusedIndex = currentIndex;
//                 _hasReceivedFocusFromMovies = true;
//               });
//               webseriesFocusNodes[webSeriesId]!.requestFocus();
//               _scrollToPosition(currentIndex);
//               print('✅ Restored focus to ${webSeries.name}');
//             }
//           }
//         }
//       });
//     });
//   }

//   void _navigateToGridPage() {
//     print('🎬 Navigating to WebSeries Grid Page...');

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProfessionalWebSeriesGridPage(
//           webSeriesList: webSeriesList,
//           title: 'Web Series',
//         ),
//       ),
//     ).then((_) {
//       print('🔙 Returned from grid page');
//       Future.delayed(Duration(milliseconds: 300), () {
//         if (mounted && _viewAllFocusNode != null) {
//           setState(() {
//             focusedIndex = maxHorizontalItems;
//             _hasReceivedFocusFromMovies = true;
//           });
//           _viewAllFocusNode!.requestFocus();
//           _scrollToPosition(maxHorizontalItems);
//           print('✅ Focused back to ViewAll button and scrolled');
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     // ✅ ADD: Consumer to listen to color changes
//     return Consumer<ColorProvider>(
//       builder: (context, colorProvider, child) {
//         final bgColor = colorProvider.isItemFocused
//             ? colorProvider.dominantColor.withOpacity(0.1)
//             : ProfessionalColors.primaryDark;

//         return Scaffold(
//           backgroundColor: Colors.transparent,
//           body: Container(
//             // ✅ ENHANCED: Dynamic background gradient based on focused item
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   bgColor,
//                   // ProfessionalColors.primaryDark,
//                   // ProfessionalColors.surfaceDark.withOpacity(0.5),

//                       bgColor.withOpacity(0.8),
//                   ProfessionalColors.primaryDark,
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
//                   ProfessionalColors.accentPurple,
//                   ProfessionalColors.accentBlue,
//                 ],
//               ).createShader(bounds),
//               child: Text(
//                 'WEB SERIES',
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
//                 // // 🆕 Refresh Button
//                 // GestureDetector(
//                 //   onTap: isLoading ? null : _forceRefreshWebSeries,
//                 //   child: Container(
//                 //     padding: const EdgeInsets.all(8),
//                 //     decoration: BoxDecoration(
//                 //       color: ProfessionalColors.accentPurple.withOpacity(0.2),
//                 //       borderRadius: BorderRadius.circular(8),
//                 //       border: Border.all(
//                 //         color: ProfessionalColors.accentPurple.withOpacity(0.3),
//                 //         width: 1,
//                 //       ),
//                 //     ),
//                 //     child: isLoading
//                 //         ? SizedBox(
//                 //             width: 16,
//                 //             height: 16,
//                 //             child: CircularProgressIndicator(
//                 //               strokeWidth: 2,
//                 //               valueColor: AlwaysStoppedAnimation<Color>(
//                 //                 ProfessionalColors.accentPurple,
//                 //               ),
//                 //             ),
//                 //           )
//                 //         : Icon(
//                 //             Icons.refresh,
//                 //             size: 16,
//                 //             color: ProfessionalColors.accentPurple,
//                 //           ),
//                 //   ),
//                 // ),
//                 // const SizedBox(width: 12),
//                 // Web Series Count
//                 if (webSeriesList.length > 0)
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           ProfessionalColors.accentPurple.withOpacity(0.2),
//                           ProfessionalColors.accentBlue.withOpacity(0.2),
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: ProfessionalColors.accentPurple.withOpacity(0.3),
//                         width: 1,
//                       ),
//                     ),
//                     child: Text(
//                       '${webSeriesList.length} Series Available',
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

//   Widget _buildBody(double screenWidth, double screenHeight) {
//     if (isLoading) {
//       return ProfessionalWebSeriesLoadingIndicator(
//           message: 'Loading Web Series...');
//     } else if (webSeriesList.isEmpty) {
//       return _buildEmptyWidget();
//     } else {
//       return _buildWebSeriesList(screenWidth, screenHeight);
//     }
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
//                   ProfessionalColors.accentPurple.withOpacity(0.2),
//                   ProfessionalColors.accentPurple.withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.tv_outlined,
//               size: 40,
//               color: ProfessionalColors.accentPurple,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'No Web Series Found',
//             style: TextStyle(
//               color: ProfessionalColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Check back later for new episodes',
//             style: TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWebSeriesList(double screenWidth, double screenHeight) {
//     bool showViewAll = webSeriesList.length > 7;

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
//           itemCount: showViewAll ? 8 : webSeriesList.length,
//           itemBuilder: (context, index) {
//             if (showViewAll && index == 7) {
//               return Focus(
//                 focusNode: _viewAllFocusNode,
//                 onFocusChange: (hasFocus) {
//                   if (hasFocus && mounted) {
//                     Color viewAllColor = ProfessionalColors.gradientColors[
//                         math.Random().nextInt(ProfessionalColors.gradientColors.length)];

//                     setState(() {
//                       _currentAccentColor = viewAllColor;
//                     });
//                   }
//                 },
//                 onKey: (FocusNode node, RawKeyEvent event) {
//                   if (event is RawKeyDownEvent) {
//                     if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//                       if (webSeriesList.isNotEmpty && webSeriesList.length > 6) {
//                         String webSeriesId = webSeriesList[6].id.toString();
//                         FocusScope.of(context).requestFocus(webseriesFocusNodes[webSeriesId]);
//                         return KeyEventResult.handled;
//                       }
//                     } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                       setState(() {
//                         focusedIndex = -1;
//                         _hasReceivedFocusFromMovies = false;
//                       });
//                       FocusScope.of(context).unfocus();
//                       Future.delayed(const Duration(milliseconds: 100), () {
//                         if (mounted) {
//                           try {
//                             Provider.of<FocusProvider>(context, listen: false)
//                                 .requestFirstMoviesFocus();
//                             print('✅ Navigating back to movies from webseries');
//                           } catch (e) {
//                             print('❌ Failed to navigate to movies: $e');
//                           }
//                         }
//                       });
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//                       setState(() {
//                         focusedIndex = -1;
//                         _hasReceivedFocusFromMovies = false;
//                       });
//                       FocusScope.of(context).unfocus();
//                       Future.delayed(const Duration(milliseconds: 100), () {
//                         if (mounted) {
//                           try {
//                             Provider.of<FocusProvider>(context, listen: false)
//                                 .requestFirstTVShowsFocus();
//                             print('✅ Navigating to TV Shows from webseries ViewAll');
//                           } catch (e) {
//                             print('❌ Failed to navigate to TV Shows: $e');
//                           }
//                         }
//                       });
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//                         event.logicalKey == LogicalKeyboardKey.select) {
//                       print('🎬 ViewAll button pressed - Opening Grid Page...');
//                       _navigateToGridPage();
//                       return KeyEventResult.handled;
//                     }
//                   }
//                   return KeyEventResult.ignored;
//                 },
//                 child: GestureDetector(
//                   onTap: _navigateToGridPage,
//                   child: ProfessionalWebSeriesViewAllButton(
//                     focusNode: _viewAllFocusNode!,
//                     onTap: _navigateToGridPage,
//                     totalItems: webSeriesList.length,
//                     itemType: 'WEB SERIES',
//                   ),
//                 ),
//               );
//             }

//             var webSeries = webSeriesList[index];
//             return _buildWebSeriesItem(webSeries, index, screenWidth, screenHeight);
//           },
//         ),
//       ),
//     );
//   }

//     // ✅ ENHANCED: WebSeries item with color provider integration
//   Widget _buildWebSeriesItem(WebSeriesModel webSeries, int index, double screenWidth, double screenHeight) {
//     String webSeriesId = webSeries.id.toString();

//     webseriesFocusNodes.putIfAbsent(
//       webSeriesId,
//       () => FocusNode()
//         ..addListener(() {
//           if (mounted && webseriesFocusNodes[webSeriesId]!.hasFocus) {
//             _scrollToPosition(index);
//           }
//         }),
//     );

//     return Focus(
//       focusNode: webseriesFocusNodes[webSeriesId],
//       onFocusChange: (hasFocus) async {
//         if (hasFocus && mounted) {
//           try {
//             Color dominantColor = ProfessionalColors.gradientColors[
//                 math.Random().nextInt(ProfessionalColors.gradientColors.length)];

//             setState(() {
//               _currentAccentColor = dominantColor;
//               focusedIndex = index;
//               _hasReceivedFocusFromMovies = true;
//             });

//             // ✅ ADD: Update color provider
//             context.read<ColorProvider>().updateColor(dominantColor, true);
//           } catch (e) {
//             print('Focus change handling failed: $e');
//           }
//         } else if (mounted) {
//           // ✅ ADD: Reset color when focus lost
//           context.read<ColorProvider>().resetColor();
//         }
//       },
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//             if (index < webSeriesList.length - 1 && index != 6) {
//               String nextWebSeriesId = webSeriesList[index + 1].id.toString();
//               FocusScope.of(context).requestFocus(webseriesFocusNodes[nextWebSeriesId]);
//               return KeyEventResult.handled;
//             } else if (index == 6 && webSeriesList.length > 7) {
//               FocusScope.of(context).requestFocus(_viewAllFocusNode);
//               return KeyEventResult.handled;
//             }
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//             if (index > 0) {
//               String prevWebSeriesId = webSeriesList[index - 1].id.toString();
//               FocusScope.of(context).requestFocus(webseriesFocusNodes[prevWebSeriesId]);
//               return KeyEventResult.handled;
//             }
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//             setState(() {
//               focusedIndex = -1;
//               _hasReceivedFocusFromMovies = false;
//             });
//             // ✅ ADD: Reset color when navigating away
//             context.read<ColorProvider>().resetColor();
//             FocusScope.of(context).unfocus();
//             Future.delayed(const Duration(milliseconds: 100), () {
//               if (mounted) {
//                 try {
//                   Provider.of<FocusProvider>(context, listen: false)
//                       .requestFirstMoviesFocus();
//                   print('✅ Navigating back to movies from webseries');
//                 } catch (e) {
//                   print('❌ Failed to navigate to movies: $e');
//                 }
//               }
//             });
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//             setState(() {
//               focusedIndex = -1;
//               _hasReceivedFocusFromMovies = false;
//             });
//             // ✅ ADD: Reset color when navigating away
//             context.read<ColorProvider>().resetColor();
//             FocusScope.of(context).unfocus();
//             Future.delayed(const Duration(milliseconds: 100), () {
//               if (mounted) {
//                 try {
//                   Provider.of<FocusProvider>(context, listen: false)
//                       .requestFirstTVShowsFocus();
//                   print('✅ Navigating to TV Shows from webseries');
//                 } catch (e) {
//                   print('❌ Failed to navigate to TV Shows: $e');
//                 }
//               }
//             });
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//               event.logicalKey == LogicalKeyboardKey.select) {
//             print('🎬 Enter pressed on ${webSeries.name} - Opening Details Page...');
//             _navigateToWebSeriesDetails(webSeries);
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: () => _navigateToWebSeriesDetails(webSeries),
//         child: ProfessionalWebSeriesCard(
//           webSeries: webSeries,
//           focusNode: webseriesFocusNodes[webSeriesId]!,
//           onTap: () => _navigateToWebSeriesDetails(webSeries),
//           onColorChange: (color) {
//             setState(() {
//               _currentAccentColor = color;
//             });
//             // ✅ ADD: Update color provider when card changes color
//             context.read<ColorProvider>().updateColor(color, true);
//           },
//           index: index,
//           categoryTitle: 'WEB SERIES',
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _headerAnimationController.dispose();
//     _listAnimationController.dispose();

//     for (var entry in webseriesFocusNodes.entries) {
//       try {
//         entry.value.removeListener(() {});
//         entry.value.dispose();
//       } catch (e) {}
//     }
//     webseriesFocusNodes.clear();

//     try {
//       _viewAllFocusNode?.removeListener(() {});
//       _viewAllFocusNode?.dispose();
//     } catch (e) {}

//     try {
//       _scrollController.dispose();
//     } catch (e) {}

//     super.dispose();
//   }
// }

// // 🚀 Enhanced Cache Management Utility Class
// class CacheManager {
//   /// Clear all app caches
//   static Future<void> clearAllCaches() async {
//     try {
//       await Future.wait([
//         WebSeriesService.clearCache(),
//         // Add other service cache clears here
//         // MoviesService.clearCache(),
//         // TVShowsService.clearCache(),
//       ]);
//       print('🗑️ All caches cleared successfully');
//     } catch (e) {
//       print('❌ Error clearing all caches: $e');
//     }
//   }

//   /// Get comprehensive cache info for all services
//   static Future<Map<String, dynamic>> getAllCacheInfo() async {
//     try {
//       final webSeriesCacheInfo = await WebSeriesService.getCacheInfo();
//       // Add other service cache info here
//       // final moviesCacheInfo = await MoviesService.getCacheInfo();
//       // final tvShowsCacheInfo = await TVShowsService.getCacheInfo();

//       return {
//         'webSeries': webSeriesCacheInfo,
//         // 'movies': moviesCacheInfo,
//         // 'tvShows': tvShowsCacheInfo,
//         'totalCacheSize': _calculateTotalCacheSize([
//           webSeriesCacheInfo,
//           // moviesCacheInfo,
//           // tvShowsCacheInfo,
//         ]),
//       };
//     } catch (e) {
//       print('❌ Error getting all cache info: $e');
//       return {
//         'error': e.toString(),
//         'webSeries': {'hasCachedData': false},
//       };
//     }
//   }

//   static int _calculateTotalCacheSize(List<Map<String, dynamic>> cacheInfos) {
//     int totalSize = 0;
//     for (final info in cacheInfos) {
//       if (info['cacheSize'] is int) {
//         totalSize += info['cacheSize'] as int;
//       }
//     }
//     return totalSize;
//   }

//   /// Force refresh all data
//   static Future<void> forceRefreshAllData() async {
//     try {
//       await Future.wait([
//         WebSeriesService.forceRefresh(),
//         // Add other service force refreshes here
//         // MoviesService.forceRefresh(),
//         // TVShowsService.forceRefresh(),
//       ]);
//       print('🔄 All data force refreshed successfully');
//     } catch (e) {
//       print('❌ Error force refreshing all data: $e');
//     }
//   }
// }

// // ✅ Professional WebSeries Card (Movies style)
// class ProfessionalWebSeriesCard extends StatefulWidget {
//   final WebSeriesModel webSeries;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final Function(Color) onColorChange;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalWebSeriesCard({
//     Key? key,
//     required this.webSeries,
//     required this.focusNode,
//     required this.onTap,
//     required this.onColorChange,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalWebSeriesCardState createState() => _ProfessionalWebSeriesCardState();
// }

// class _ProfessionalWebSeriesCardState extends State<ProfessionalWebSeriesCard>
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
//             _buildWebSeriesImage(screenWidth, posterHeight),
//             if (_isFocused) _buildFocusBorder(),
//             if (_isFocused) _buildShimmerEffect(),
//             _buildGenreBadge(),
//             if (_isFocused) _buildHoverOverlay(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWebSeriesImage(double screenWidth, double posterHeight) {
//     return Container(
//       width: double.infinity,
//       height: posterHeight,
//       child: widget.webSeries.banner != null && widget.webSeries.banner!.isNotEmpty
//           ? Image.network(
//               widget.webSeries.banner!,
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
//             Icons.tv_outlined,
//             size: height * 0.25,
//             color: ProfessionalColors.textSecondary,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'WEB SERIES',
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
//               color: ProfessionalColors.accentPurple.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Text(
//               'HD',
//               style: TextStyle(
//                 color: ProfessionalColors.accentPurple,
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
//     String genre = 'SERIES';
//     Color badgeColor = ProfessionalColors.accentPurple;

//     if (widget.webSeries.genres != null) {
//       if (widget.webSeries.genres!.toLowerCase().contains('drama')) {
//         genre = 'DRAMA';
//         badgeColor = ProfessionalColors.accentPurple;
//       } else if (widget.webSeries.genres!.toLowerCase().contains('thriller')) {
//         genre = 'THRILLER';
//         badgeColor = ProfessionalColors.accentRed;
//       } else if (widget.webSeries.genres!.toLowerCase().contains('comedy')) {
//         genre = 'COMEDY';
//         badgeColor = ProfessionalColors.accentGreen;
//       } else if (widget.webSeries.genres!.toLowerCase().contains('romance')) {
//         genre = 'ROMANCE';
//         badgeColor = ProfessionalColors.accentPink;
//       }
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
//             child: Icon(
//               Icons.play_arrow_rounded,
//               color: _dominantColor,
//               size: 30,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalTitle(double screenWidth) {
//     final webSeriesName = widget.webSeries.name.toUpperCase();

//     return Container(
//       width: bannerwdt,
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
//           webSeriesName,
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }

// // ✅ Professional View All Button (same as movies)
// class ProfessionalWebSeriesViewAllButton extends StatefulWidget {
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int totalItems;
//   final String itemType;

//   const ProfessionalWebSeriesViewAllButton({
//     Key? key,
//     required this.focusNode,
//     required this.onTap,
//     required this.totalItems,
//     this.itemType = 'WEB SERIES',
//   }) : super(key: key);

//   @override
//   _ProfessionalWebSeriesViewAllButtonState createState() =>
//       _ProfessionalWebSeriesViewAllButtonState();
// }

// class _ProfessionalWebSeriesViewAllButtonState extends State<ProfessionalWebSeriesViewAllButton>
//     with TickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late AnimationController _rotateController;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _rotateAnimation;

//   bool _isFocused = false;
//   Color _currentColor = ProfessionalColors.accentPurple;

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
//       width: bannerwdt,
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
//                     height: _isFocused ? focussedBannerhgt : bannerhgt,
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
//                   Icons.tv_rounded,
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
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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

// // ✅ Professional Loading Indicator
// class ProfessionalWebSeriesLoadingIndicator extends StatefulWidget {
//   final String message;

//   const ProfessionalWebSeriesLoadingIndicator({
//     Key? key,
//     this.message = 'Loading Web Series...',
//   }) : super(key: key);

//   @override
//   _ProfessionalWebSeriesLoadingIndicatorState createState() =>
//       _ProfessionalWebSeriesLoadingIndicatorState();
// }

// class _ProfessionalWebSeriesLoadingIndicatorState extends State<ProfessionalWebSeriesLoadingIndicator>
//     with TickerProviderStateMixin {
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
//                       ProfessionalColors.accentPurple,
//                       ProfessionalColors.accentBlue,
//                       ProfessionalColors.accentPink,
//                       ProfessionalColors.accentPurple,
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
//                     Icons.tv_rounded,
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
//                     ProfessionalColors.accentPurple,
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

// // Enhanced WebSeries Grid Page - Following GenreNetworkWidget Pattern
// class ProfessionalWebSeriesGridPage extends StatefulWidget {
//   final List<WebSeriesModel> webSeriesList;
//   final String title;

//   const ProfessionalWebSeriesGridPage({
//     Key? key,
//     required this.webSeriesList,
//     this.title = 'All Web Series',
//   }) : super(key: key);

//   @override
//   _ProfessionalWebSeriesGridPageState createState() => _ProfessionalWebSeriesGridPageState();
// }
// class _ProfessionalWebSeriesGridPageState extends State<ProfessionalWebSeriesGridPage>
//     with SingleTickerProviderStateMixin {

//   // ✅ FIX 1: Har item ke liye FocusNode ki list banayein
//   late List<FocusNode> _itemFocusNodes;

//   // Focus and Navigation Management
//   final FocusNode _widgetFocusNode = FocusNode();
//   final ScrollController _scrollController = ScrollController();

//   int focusedIndex = 0;
//   bool _isVideoLoading = false;
//   static const int _itemsPerRow = 6;
//   static const double _gridMainAxisSpacing = 15.0;
//   static const double _gridCrossAxisSpacing = 15.0;

//   // Animation Controllers
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();

//     // ✅ FIX 2: List ko initialize karein
//     _itemFocusNodes = List.generate(
//       widget.webSeriesList.length,
//       (index) => FocusNode(),
//     );

//     _initializeAnimations();
//     _startAnimations();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && _itemFocusNodes.isNotEmpty) {
//         // Parent par focus karein, phir pehle item par
//         _widgetFocusNode.requestFocus();
//         _itemFocusNodes[focusedIndex].requestFocus();
//       }
//     });
//   }

//   void _initializeAnimations() {
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 400),
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

//   void _startAnimations() {
//     _fadeController.forward();
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _widgetFocusNode.dispose();
//     _scrollController.dispose();

//     // ✅ FIX 3: Sabhi FocusNodes ko dispose karein
//     for (var node in _itemFocusNodes) {
//       node.dispose();
//     }

//     super.dispose();
//   }

//   void _handleKeyNavigation(RawKeyEvent event) {
//     if (event is! RawKeyDownEvent || _isVideoLoading) return;
//     if (widget.webSeriesList.isEmpty) return;

//     final totalItems = widget.webSeriesList.length;
//     int previousIndex = focusedIndex;

//     if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//       _moveUp();
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//       _moveDown(totalItems);
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//       _moveLeft();
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//       _moveRight(totalItems);
//     } else if (event.logicalKey == LogicalKeyboardKey.select ||
//                event.logicalKey == LogicalKeyboardKey.enter) {
//       _handleSelectAction();
//     }

//     if (previousIndex != focusedIndex) {
//       // ✅ FIX 4: Purane scroll function ki jagah naya function call karein
//       _updateAndScrollToFocus();
//       HapticFeedback.lightImpact();
//     }
//   }

//   void _safeSetState(VoidCallback fn) {
//     if (mounted) {
//       setState(fn);
//     }
//   }

//   void _moveUp() {
//     if (focusedIndex >= _itemsPerRow) {
//       _safeSetState(() => focusedIndex -= _itemsPerRow);
//     }
//   }

//   void _moveDown(int totalItems) {
//     final nextRowStartIndex = focusedIndex + _itemsPerRow;
//     if (nextRowStartIndex < totalItems) {
//       _safeSetState(() => focusedIndex = math.min(nextRowStartIndex, totalItems - 1));
//     }
//   }

//   void _moveLeft() {
//     if (focusedIndex % _itemsPerRow != 0) {
//       _safeSetState(() => focusedIndex--);
//     }
//   }

//   void _moveRight(int totalItems) {
//     if (focusedIndex % _itemsPerRow != _itemsPerRow - 1 && focusedIndex < totalItems - 1) {
//       _safeSetState(() => focusedIndex++);
//     }
//   }

//   void _handleSelectAction() {
//     if (focusedIndex < widget.webSeriesList.length) {
//       _navigateToWebSeriesDetails(widget.webSeriesList[focusedIndex], focusedIndex);
//     }
//   }

//   // ❌ Apna purana `_scrollToFocusedItem` function DELETE kar dein

//   // ✅ FIX 5: Naya aur reliable scroll function ADD karein
//   void _updateAndScrollToFocus() {
//     if (!mounted || focusedIndex >= _itemFocusNodes.length) return;

//     final focusNode = _itemFocusNodes[focusedIndex];
//     focusNode.requestFocus();

//     Scrollable.ensureVisible(
//       focusNode.context!,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOutCubic,
//       alignment: 0.5, // Item ko screen ke beech mein laane ki koshish karega
//     );
//   }

//   void _navigateToWebSeriesDetails(WebSeriesModel webSeries, int index) {
//     if (_isVideoLoading) return;

//     _safeSetState(() {
//       _isVideoLoading = true;
//     });

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => WebSeriesDetailsPage(
//           id: webSeries.id,
//           banner: webSeries.banner ?? webSeries.poster ?? '',
//           poster: webSeries.poster ?? webSeries.banner ?? '',
//           name: webSeries.name,
//         ),
//       ),
//     ).then((_) {
//       if (mounted) {
//         _safeSetState(() {
//           _isVideoLoading = false;
//         });

//         Future.delayed(Duration(milliseconds: 300), () {
//           if (mounted) {
//             _safeSetState(() {
//               focusedIndex = index;
//             });
//             _widgetFocusNode.requestFocus();
//             _updateAndScrollToFocus(); // Use new method
//           }
//         });
//       }
//     }).catchError((error) {
//       if (mounted) {
//         _safeSetState(() {
//           _isVideoLoading = false;
//         });
//       }
//     });
//   }

//   Future<void> _handleRefresh() async {
//     try {
//       _safeSetState(() {
//         focusedIndex = 0;
//       });
//       _updateAndScrollToFocus(); // Use new method
//     } catch (e) {
//       print('❌ Refresh error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Container(
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
//             Column(
//               children: [
//                 _buildProfessionalAppBar(),
//                 Expanded(
//                   child: FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: RawKeyboardListener(
//                       focusNode: _widgetFocusNode,
//                       onKey: _handleKeyNavigation,
//                       autofocus: true,
//                       child: RefreshIndicator(
//                         onRefresh: _handleRefresh,
//                         color: ProfessionalColors.accentPurple,
//                         backgroundColor: ProfessionalColors.cardDark,
//                         child: _buildContent(),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             if (_isVideoLoading)
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black.withOpacity(0.7),
//                   child: const Center(
//                     child: ProfessionalWebSeriesLoadingIndicator(
//                       message: 'Loading Web Series...',
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalAppBar() {
//     // Is function mein koi badlav nahi
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             ProfessionalColors.primaryDark.withOpacity(0.98),
//             ProfessionalColors.surfaceDark.withOpacity(0.95),
//             ProfessionalColors.surfaceDark.withOpacity(0.9),
//             Colors.transparent,
//           ],
//         ),
//         border: Border(
//           bottom: BorderSide(
//             color: ProfessionalColors.accentPurple.withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.4),
//             blurRadius: 15,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
//           child: Container(
//             padding: EdgeInsets.only(
//               top: MediaQuery.of(context).padding.top + 15,
//               left: 40,
//               right: 40,
//               bottom: 15,
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: LinearGradient(
//                       colors: [
//                         ProfessionalColors.accentPurple.withOpacity(0.4),
//                         ProfessionalColors.accentBlue.withOpacity(0.4),
//                       ],
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: ProfessionalColors.accentPurple.withOpacity(0.4),
//                         blurRadius: 10,
//                         offset: const Offset(0, 3),
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
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ShaderMask(
//                         shaderCallback: (bounds) => const LinearGradient(
//                           colors: [
//                             ProfessionalColors.accentPurple,
//                             ProfessionalColors.accentBlue,
//                           ],
//                         ).createShader(bounds),
//                         child: Text(
//                           widget.title.toUpperCase(),
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 24,
//                             fontWeight: FontWeight.w700,
//                             letterSpacing: 1.0,
//                             shadows: [
//                               Shadow(
//                                 color: Colors.black.withOpacity(0.8),
//                                 blurRadius: 6,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               ProfessionalColors.accentPurple.withOpacity(0.4),
//                               ProfessionalColors.accentBlue.withOpacity(0.3),
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(15),
//                           border: Border.all(
//                             color: ProfessionalColors.accentPurple.withOpacity(0.6),
//                             width: 1,
//                           ),
//                         ),
//                         child: Text(
//                           '${widget.webSeriesList.length} Web Series Available',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
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

//   Widget _buildContent() {
//     if (widget.webSeriesList.isEmpty) {
//       return _buildEmptyWidget();
//     } else {
//       return _buildGridView();
//     }
//   }

//   Widget _buildEmptyWidget() {
//     // Is function mein koi badlav nahi
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
//                   ProfessionalColors.accentPurple.withOpacity(0.2),
//                   ProfessionalColors.accentPurple.withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.tv_outlined,
//               size: 40,
//               color: ProfessionalColors.accentPurple,
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'No ${widget.title} Found',
//             style: TextStyle(
//               color: ProfessionalColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Pull down to refresh',
//             style: TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGridView() {
//     return Padding(
//       padding: EdgeInsets.all(20),
//       child: GridView.builder(
//         controller: _scrollController,
//         physics: const AlwaysScrollableScrollPhysics(),
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: _itemsPerRow,
//           crossAxisSpacing: _gridCrossAxisSpacing,
//           mainAxisSpacing: _gridMainAxisSpacing,
//           childAspectRatio: 1.5,
//         ),
//         clipBehavior: Clip.none,
//         itemCount: widget.webSeriesList.length,
//         itemBuilder: (context, index) {
//           // ✅ FIX 6: Card ko 'Focus' widget se wrap karein
//           return Focus(
//             focusNode: _itemFocusNodes[index],
//             child: _buildWebSeriesGridItem(widget.webSeriesList[index], index),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildWebSeriesGridItem(WebSeriesModel webSeries, int index) {
//     final isFocused = focusedIndex == index;
//     return OptimizedWebSeriesGridCard(
//       webSeries: webSeries,
//       isFocused: isFocused,
//       onTap: () => _navigateToWebSeriesDetails(webSeries, index),
//       index: index,
//       categoryTitle: widget.title,
//     );
//   }
// }

// // Optimized WebSeries Grid Card - Following the Content Card pattern
// class OptimizedWebSeriesGridCard extends StatelessWidget {
//   final WebSeriesModel webSeries;
//   final bool isFocused;
//   final VoidCallback onTap;
//   final int index;
//   final String categoryTitle;

//   const OptimizedWebSeriesGridCard({
//     Key? key,
//     required this.webSeries,
//     required this.isFocused,
//     required this.onTap,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   Color _getDominantColor() {
//     final colors = ProfessionalColors.gradientColors;
//     return colors[math.Random(webSeries.id).nextInt(colors.length)];
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dominantColor = _getDominantColor();

//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         border: isFocused
//             ? Border.all(
//                 color: dominantColor,
//                 width: 3,
//               )
//             : null,
//         boxShadow: [
//           if (isFocused) ...[
//             BoxShadow(
//               color: dominantColor.withOpacity(0.4),
//               blurRadius: 20,
//               spreadRadius: 2,
//               offset: const Offset(0, 8),
//             ),
//             BoxShadow(
//               color: dominantColor.withOpacity(0.2),
//               blurRadius: 35,
//               spreadRadius: 4,
//               offset: const Offset(0, 12),
//             ),
//           ] else ...[
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 8,
//               spreadRadius: 1,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(15),
//         child: Stack(
//           children: [
//             _buildWebSeriesImage(),
//             _buildGradientOverlay(),
//             _buildWebSeriesInfo(dominantColor),
//             if (isFocused) _buildPlayButton(dominantColor),
//             _buildGenreBadge(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWebSeriesImage() {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       child: _buildImageWidget(),
//     );
//   }

//   Widget _buildImageWidget() {
//     if (webSeries.banner != null && webSeries.banner!.isNotEmpty) {
//       return CachedNetworkImage(
//         imageUrl: webSeries.banner!,
//         fit: BoxFit.cover,
//         memCacheWidth: 300,
//         memCacheHeight: 400,
//         maxWidthDiskCache: 300,
//         maxHeightDiskCache: 400,
//         placeholder: (context, url) => _buildImagePlaceholder(),
//         errorWidget: (context, url, error) => _buildPosterWidget(),
//       );
//     } else {
//       return _buildPosterWidget();
//     }
//   }

//   Widget _buildPosterWidget() {
//     if (webSeries.poster != null && webSeries.poster!.isNotEmpty) {
//       return CachedNetworkImage(
//         imageUrl: webSeries.poster!,
//         fit: BoxFit.cover,
//         memCacheWidth: 300,
//         memCacheHeight: 400,
//         maxWidthDiskCache: 300,
//         maxHeightDiskCache: 400,
//         placeholder: (context, url) => _buildImagePlaceholder(),
//         errorWidget: (context, url, error) => _buildImagePlaceholder(),
//       );
//     } else {
//       return _buildImagePlaceholder();
//     }
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
//               Icons.tv_outlined,
//               size: 40,
//               color: ProfessionalColors.textSecondary,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'WEB SERIES',
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
//                 color: ProfessionalColors.accentPurple.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: const Text(
//                 'HD',
//                 style: TextStyle(
//                   color: ProfessionalColors.accentPurple,
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

//   Widget _buildWebSeriesInfo(Color dominantColor) {
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
//               webSeries.name.toUpperCase(),
//               style: TextStyle(
//                 color: isFocused ? dominantColor : Colors.white,
//                 fontSize: isFocused ? 13 : 12,
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
//             if (isFocused && webSeries.genres != null) ...[
//               const SizedBox(height: 4),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: dominantColor.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: dominantColor.withOpacity(0.5),
//                     width: 1,
//                   ),
//                 ),
//                 child: Text(
//                   webSeries.genres!.toUpperCase(),
//                   style: TextStyle(
//                     color: dominantColor,
//                     fontSize: 8,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPlayButton(Color dominantColor) {
//     return Positioned(
//       top: 12,
//       right: 12,
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: dominantColor.withOpacity(0.9),
//           boxShadow: [
//             BoxShadow(
//               color: dominantColor.withOpacity(0.4),
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

//   Widget _buildGenreBadge() {
//     String genre = 'SERIES';
//     Color badgeColor = ProfessionalColors.accentPurple;

//     if (webSeries.genres != null) {
//       if (webSeries.genres!.toLowerCase().contains('drama')) {
//         genre = 'DRAMA';
//         badgeColor = ProfessionalColors.accentPurple;
//       } else if (webSeries.genres!.toLowerCase().contains('thriller')) {
//         genre = 'THRILLER';
//         badgeColor = ProfessionalColors.accentRed;
//       } else if (webSeries.genres!.toLowerCase().contains('comedy')) {
//         genre = 'COMEDY';
//         badgeColor = ProfessionalColors.accentGreen;
//       } else if (webSeries.genres!.toLowerCase().contains('romance')) {
//         genre = 'ROMANCE';
//         badgeColor = ProfessionalColors.accentPink;
//       }
//     }

//     return Positioned(
//       top: 8,
//       left: 8,
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
// }

// // ✅ Professional Grid WebSeries Card
// class ProfessionalGridWebSeriesCard extends StatefulWidget {
//   final WebSeriesModel webSeries;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalGridWebSeriesCard({
//     Key? key,
//     required this.webSeries,
//     required this.focusNode,
//     required this.onTap,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalGridWebSeriesCardState createState() => _ProfessionalGridWebSeriesCardState();
// }

// class _ProfessionalGridWebSeriesCardState extends State<ProfessionalGridWebSeriesCard>
//     with TickerProviderStateMixin {
//   late AnimationController _hoverController;
//   late AnimationController _glowController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;

//   Color _dominantColor = ProfessionalColors.accentPurple;
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
//                       _buildWebSeriesImage(),
//                       if (_isFocused) _buildFocusBorder(),
//                       _buildGradientOverlay(),
//                       _buildWebSeriesInfo(),
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

//   Widget _buildWebSeriesImage() {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       child: widget.webSeries.banner != null && widget.webSeries.banner!.isNotEmpty
//           ? Image.network(
//               widget.webSeries.banner!,
//               fit: BoxFit.cover,
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return _buildImagePlaceholder();
//               },
//               errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
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
//               Icons.tv_outlined,
//               size: 40,
//               color: ProfessionalColors.textSecondary,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'WEB SERIES',
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
//                 color: ProfessionalColors.accentPurple.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: const Text(
//                 'HD',
//                 style: TextStyle(
//                   color: ProfessionalColors.accentPurple,
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

//   Widget _buildWebSeriesInfo() {
//     final webSeriesName = widget.webSeries.name;

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
//               webSeriesName.toUpperCase(),
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
//             if (_isFocused && widget.webSeries.genres != null) ...[
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: ProfessionalColors.accentPurple.withOpacity(0.3),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: ProfessionalColors.accentPurple.withOpacity(0.5),
//                         width: 1,
//                       ),
//                     ),
//                     child: Text(
//                       widget.webSeries.genres!.toUpperCase(),
//                       style: const TextStyle(
//                         color: ProfessionalColors.accentPurple,
//                         fontSize: 8,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: _dominantColor.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: _dominantColor.withOpacity(0.4),
//                         width: 1,
//                       ),
//                     ),
//                     child: Text(
//                       'SERIES',
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






// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobi_tv_entertainment/home_screen_pages/webseries_screen/webseries_details_page.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:provider/provider.dart';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:math' as math;
// import 'dart:ui';

// /*
//   Ye code istemal karne se pehle, ye dependencies aapke pubspec.yaml file mein honi chahiye:
  
//   dependencies:
//     flutter:
//       sdk: flutter
//     provider: ^6.0.0
//     http: ^1.0.0
//     shared_preferences: ^2.0.0
//     cached_network_image: ^3.2.0
// */

// // ✅ Professional Color Palette
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

// // ✅ Professional Animation Durations
// class AnimationTiming {
//   static const Duration ultraFast = Duration(milliseconds: 150);
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
//   static const Duration slow = Duration(milliseconds: 600);
//   static const Duration focus = Duration(milliseconds: 300);
//   static const Duration scroll = Duration(milliseconds: 800);
// }

// // ✅ WebSeries Model
// class WebSeriesModel {
//   final int id;
//   final String name;
//   final String? description;
//   final String? poster;
//   final String? banner;
//   final String? releaseDate;
//   final String? genres;

//   WebSeriesModel({
//     required this.id,
//     required this.name,
//     this.description,
//     this.poster,
//     this.banner,
//     this.releaseDate,
//     this.genres,
//   });

//   factory WebSeriesModel.fromJson(Map<String, dynamic> json) {
//     return WebSeriesModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       description: json['description'],
//       poster: json['poster'],
//       banner: json['banner'],
//       releaseDate: json['release_date'],
//       genres: json['genres'],
//     );
//   }
// }

// // 🚀 Enhanced WebSeries Service with Caching
// class WebSeriesService {
//   static const String _cacheKeyWebSeries = 'cached_web_series';
//   static const String _cacheKeyTimestamp = 'cached_web_series_timestamp';
//   static const String _cacheKeyAuthKey = 'auth_key';
//   static const int _cacheDurationMs = 60 * 60 * 1000; // 1 hour

//   static Future<List<WebSeriesModel>> getAllWebSeries(
//       {bool forceRefresh = false}) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       if (!forceRefresh && await _shouldUseCache(prefs)) {
//         print('📦 Loading Web Series from cache...');
//         final cachedWebSeries = await _getCachedWebSeries(prefs);
//         if (cachedWebSeries.isNotEmpty) {
//           _loadFreshDataInBackground();
//           return cachedWebSeries;
//         }
//       }
//       print('🌐 Loading fresh Web Series from API...');
//       return await _fetchFreshWebSeries(prefs);
//     } catch (e) {
//       print('❌ Error in getAllWebSeries: $e');
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         final cachedWebSeries = await _getCachedWebSeries(prefs);
//         if (cachedWebSeries.isNotEmpty) {
//           print('🔄 Returning cached data as fallback');
//           return cachedWebSeries;
//         }
//       } catch (cacheError) {
//         print('❌ Cache fallback also failed: $cacheError');
//       }
//       throw Exception('Failed to load web series: $e');
//     }
//   }

//   static Future<bool> _shouldUseCache(SharedPreferences prefs) async {
//     try {
//       final timestampStr = prefs.getString(_cacheKeyTimestamp);
//       if (timestampStr == null) return false;
//       final cachedTimestamp = int.tryParse(timestampStr);
//       if (cachedTimestamp == null) return false;
//       final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
//       return (currentTimestamp - cachedTimestamp) < _cacheDurationMs;
//     } catch (e) {
//       print('❌ Error checking WebSeries cache validity: $e');
//       return false;
//     }
//   }

//   static Future<List<WebSeriesModel>> _getCachedWebSeries(
//       SharedPreferences prefs) async {
//     try {
//       final cachedData = prefs.getString(_cacheKeyWebSeries);
//       if (cachedData == null || cachedData.isEmpty) return [];
//       final List<dynamic> jsonData = json.decode(cachedData);
//       return jsonData
//           .map((json) => WebSeriesModel.fromJson(json as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       print('❌ Error loading cached web series: $e');
//       return [];
//     }
//   }

//   static Future<List<WebSeriesModel>> _fetchFreshWebSeries(
//       SharedPreferences prefs) async {
//     try {
//       String authKey = prefs.getString(_cacheKeyAuthKey) ?? '';
//       final response = await http.get(
//         Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       ).timeout(const Duration(seconds: 30));

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         await _cacheWebSeries(prefs, jsonData);
//         return jsonData
//             .map(
//                 (json) => WebSeriesModel.fromJson(json as Map<String, dynamic>))
//             .toList();
//       } else {
//         throw Exception(
//             'API Error: ${response.statusCode} - ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('❌ Error fetching fresh web series: $e');
//       rethrow;
//     }
//   }

//   static Future<void> _cacheWebSeries(
//       SharedPreferences prefs, List<dynamic> webSeriesData) async {
//     try {
//       final jsonString = json.encode(webSeriesData);
//       final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();
//       await Future.wait([
//         prefs.setString(_cacheKeyWebSeries, jsonString),
//         prefs.setString(_cacheKeyTimestamp, currentTimestamp),
//       ]);
//       print('💾 Successfully cached ${webSeriesData.length} web series');
//     } catch (e) {
//       print('❌ Error caching web series: $e');
//     }
//   }

//   static void _loadFreshDataInBackground() {
//     Future.delayed(const Duration(milliseconds: 500), () async {
//       try {
//         print('🔄 Loading fresh web series data in background...');
//         final prefs = await SharedPreferences.getInstance();
//         await _fetchFreshWebSeries(prefs);
//         print('✅ WebSeries background refresh completed');
//       } catch (e) {
//         print('⚠️ WebSeries background refresh failed: $e');
//       }
//     });
//   }

//   static Future<List<WebSeriesModel>> forceRefresh() async {
//     print('🔄 Force refreshing WebSeries data...');
//     return await getAllWebSeries(forceRefresh: true);
//   }
// }

// // 🚀 Enhanced ProfessionalWebSeriesHorizontalList
// class ProfessionalWebSeriesHorizontalList extends StatefulWidget {
//   @override
//   _ProfessionalWebSeriesHorizontalListState createState() =>
//       _ProfessionalWebSeriesHorizontalListState();
// }

// class _ProfessionalWebSeriesHorizontalListState
//     extends State<ProfessionalWebSeriesHorizontalList>
//     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
//   @override
//   bool get wantKeepAlive => true;

//   List<WebSeriesModel> webSeriesList = [];
//   bool isLoading = true;
//   int focusedIndex = -1;
//   final int maxHorizontalItems = 7;

//   late AnimationController _headerAnimationController;
//   late AnimationController _listAnimationController;
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<double> _listFadeAnimation;

//   Map<String, FocusNode> webseriesFocusNodes = {};
//   FocusNode? _viewAllFocusNode;
//   FocusNode? _firstWebSeriesFocusNode;
//   bool _hasReceivedFocusFromMovies = false;

//   late ScrollController _scrollController;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _initializeAnimations();
//     _initializeFocusNodes();
//     fetchWebSeriesWithCache();
//   }

//   @override
//   void dispose() {
//     _headerAnimationController.dispose();
//     _listAnimationController.dispose();
//     for (var node in webseriesFocusNodes.values) {
//       node.dispose();
//     }
//     webseriesFocusNodes.clear();
//     _viewAllFocusNode?.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _initializeAnimations() {
//     _headerAnimationController =
//         AnimationController(duration: AnimationTiming.slow, vsync: this);
//     _listAnimationController =
//         AnimationController(duration: AnimationTiming.slow, vsync: this);
//     _headerSlideAnimation =
//         Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
//             CurvedAnimation(
//                 parent: _headerAnimationController,
//                 curve: Curves.easeOutCubic));
//     _listFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(
//             parent: _listAnimationController, curve: Curves.easeInOut));
//   }

//   void _initializeFocusNodes() {
//     _viewAllFocusNode = FocusNode();
//   }

//   void _scrollToPosition(int index) {
//     if (!mounted || !_scrollController.hasClients) return;
//     try {
//       double bannerwidth = bannerwdt;
//       double scrollPosition = index * bannerwidth;
//       _scrollController.animateTo(
//         scrollPosition,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeOut,
//       );
//     } catch (e) {
//       print('Error scrolling in webseries: $e');
//     }
//   }

//   void _setupFocusProvider() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && webSeriesList.isNotEmpty) {
//         final focusProvider =
//             Provider.of<FocusProvider>(context, listen: false);
//         final firstWebSeriesId = webSeriesList[0].id.toString();
//         webseriesFocusNodes.putIfAbsent(firstWebSeriesId, () => FocusNode());
//         _firstWebSeriesFocusNode = webseriesFocusNodes[firstWebSeriesId];
//         _firstWebSeriesFocusNode?.addListener(() {
//           if (_firstWebSeriesFocusNode!.hasFocus &&
//               !_hasReceivedFocusFromMovies) {
//             _hasReceivedFocusFromMovies = true;
//             setState(() => focusedIndex = 0);
//             _scrollToPosition(0);
//           }
//         });
//         focusProvider
//             .setFirstManageWebseriesFocusNode(_firstWebSeriesFocusNode!);
//       }
//     });
//   }

//   Future<void> fetchWebSeriesWithCache() async {
//     if (!mounted) return;
//     setState(() => isLoading = true);
//     try {
//       final fetchedWebSeries = await WebSeriesService.getAllWebSeries();
//       if (mounted) {
//         setState(() {
//           webSeriesList = fetchedWebSeries;
//           isLoading = false;
//         });
//         _createFocusNodesForItems();
//         _setupFocusProvider();
//         _headerAnimationController.forward();
//         _listAnimationController.forward();
//       }
//     } catch (e) {
//       if (mounted) setState(() => isLoading = false);
//       print('Error fetching WebSeries with cache: $e');
//     }
//   }

//   void _createFocusNodesForItems() {
//     for (var node in webseriesFocusNodes.values) {
//       node.dispose();
//     }
//     webseriesFocusNodes.clear();
//     for (int i = 0; i < webSeriesList.length && i < maxHorizontalItems; i++) {
//       String webSeriesId = webSeriesList[i].id.toString();
//       webseriesFocusNodes[webSeriesId] = FocusNode();
//       webseriesFocusNodes[webSeriesId]!.addListener(() {
//         if (mounted && webseriesFocusNodes[webSeriesId]!.hasFocus) {
//           setState(() {
//             focusedIndex = i;
//             _hasReceivedFocusFromMovies = true;
//           });
//           _scrollToPosition(i);
//         }
//       });
//     }
//   }

//   void _navigateToWebSeriesDetails(WebSeriesModel webSeries) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => WebSeriesDetailsPage(
//           id: webSeries.id,
//           banner: webSeries.banner ?? webSeries.poster ?? '',
//           poster: webSeries.poster ?? webSeries.banner ?? '',
//           name: webSeries.name,
//         ),
//       ),
//     ).then((_) {
//       Future.delayed(const Duration(milliseconds: 300), () {
//         if (mounted) {
//           int currentIndex =
//               webSeriesList.indexWhere((ws) => ws.id == webSeries.id);
//           if (currentIndex != -1 && currentIndex < maxHorizontalItems) {
//             String webSeriesId = webSeries.id.toString();
//             if (webseriesFocusNodes.containsKey(webSeriesId)) {
//               setState(() {
//                 focusedIndex = currentIndex;
//                 _hasReceivedFocusFromMovies = true;
//               });
//               webseriesFocusNodes[webSeriesId]!.requestFocus();
//               _scrollToPosition(currentIndex);
//             }
//           }
//         }
//       });
//     });
//   }

//   void _navigateToGridPage() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProfessionalWebSeriesGridPage(
//           webSeriesList: webSeriesList,
//           title: 'All Web Series',
//         ),
//       ),
//     ).then((_) {
//       Future.delayed(const Duration(milliseconds: 300), () {
//         if (mounted && _viewAllFocusNode != null) {
//           setState(() {
//             focusedIndex = maxHorizontalItems;
//             _hasReceivedFocusFromMovies = true;
//           });
//           _viewAllFocusNode!.requestFocus();
//           _scrollToPosition(maxHorizontalItems);
//         }
//       });
//     });
//   }

//   // BUILD METHOD and WIDGETS
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Consumer<ColorProvider>(
//       builder: (context, colorProvider, child) {
//         final bgColor = colorProvider.isItemFocused
//             ? colorProvider.dominantColor.withOpacity(0.1)
//             : ProfessionalColors.primaryDark;
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
//                   ProfessionalColors.primaryDark,
//                 ],
//               ),
//             ),
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),
//                 _buildProfessionalTitle(),
//                 const SizedBox(height: 10),
//                 Expanded(child: _buildBody()),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProfessionalTitle() {
//     return SlideTransition(
//       position: _headerSlideAnimation,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 25.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             ShaderMask(
//               shaderCallback: (bounds) => const LinearGradient(
//                 colors: [
//                   ProfessionalColors.accentPurple,
//                   ProfessionalColors.accentBlue
//                 ],
//               ).createShader(bounds),
//               child: const Text(
//                 'WEB SERIES',
//                 style: TextStyle(
//                     fontSize: 24,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w700,
//                     letterSpacing: 2.0),
//               ),
//             ),
//             if (webSeriesList.isNotEmpty)
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(colors: [
//                     ProfessionalColors.accentPurple.withOpacity(0.2),
//                     ProfessionalColors.accentBlue.withOpacity(0.2),
//                   ]),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                       color: ProfessionalColors.accentPurple.withOpacity(0.3),
//                       width: 1),
//                 ),
//                 child: Text(
//                   '${webSeriesList.length} Series Available',
//                   style: const TextStyle(
//                       color: ProfessionalColors.textSecondary,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBody() {
//     if (isLoading) {
//       return const ProfessionalWebSeriesLoadingIndicator(
//           message: 'Loading Web Series...');
//     } else if (webSeriesList.isEmpty) {
//       return _buildEmptyWidget();
//     } else {
//       return _buildWebSeriesList();
//     }
//   }

//   Widget _buildEmptyWidget() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.tv_off_outlined,
//               size: 50, color: ProfessionalColors.textSecondary),
//           SizedBox(height: 16),
//           Text(
//             'No Web Series Found',
//             style: TextStyle(
//                 color: ProfessionalColors.textPrimary,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'Please check back later.',
//             style: TextStyle(
//                 color: ProfessionalColors.textSecondary, fontSize: 14),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWebSeriesList() {
//     bool showViewAll = webSeriesList.length > 7;
//     return FadeTransition(
//       opacity: _listFadeAnimation,
//       child: SizedBox(
//         height: 300,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           clipBehavior: Clip.none,
//           controller: _scrollController,
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           itemCount: showViewAll ? 8 : webSeriesList.length,
//           itemBuilder: (context, index) {
//             if (showViewAll && index == 7) {
//               return _buildViewAllButton();
//             }
//             var webSeries = webSeriesList[index];
//             return _buildWebSeriesItem(webSeries, index);
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildViewAllButton() {
//     return Focus(
//       focusNode: _viewAllFocusNode,
//       onKey: (node, event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//             FocusScope.of(context).requestFocus(
//                 webseriesFocusNodes[webSeriesList[6].id.toString()]);
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//             Provider.of<FocusProvider>(context, listen: false)
//                 .requestFirstMoviesFocus();
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//             Provider.of<FocusProvider>(context, listen: false)
//                 .requestFirstTVShowsFocus();
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.select ||
//               event.logicalKey == LogicalKeyboardKey.enter) {
//             _navigateToGridPage();
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: _navigateToGridPage,
//         child: ProfessionalWebSeriesViewAllButton(
//           focusNode: _viewAllFocusNode!,
//           onTap: _navigateToGridPage,
//           totalItems: webSeriesList.length,
//         ),
//       ),
//     );
//   }

//   Widget _buildWebSeriesItem(WebSeriesModel webSeries, int index) {
//     String webSeriesId = webSeries.id.toString();
//     FocusNode? focusNode = webseriesFocusNodes[webSeriesId];

//     if (focusNode == null) return const SizedBox.shrink();

//     return Focus(
//       focusNode: focusNode,
//       onFocusChange: (hasFocus) {
//         if (hasFocus) {
//           Color dominantColor = ProfessionalColors.gradientColors[
//               math.Random().nextInt(ProfessionalColors.gradientColors.length)];
//           context.read<ColorProvider>().updateColor(dominantColor, true);
//         } else {
//           context.read<ColorProvider>().resetColor();
//         }
//       },
//       onKey: (node, event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//             if (index < 6 && index < webSeriesList.length - 1) {
//               FocusScope.of(context).requestFocus(
//                   webseriesFocusNodes[webSeriesList[index + 1].id.toString()]);
//             } else if (index == 6 && webSeriesList.length > 7) {
//               FocusScope.of(context).requestFocus(_viewAllFocusNode);
//             }
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//             if (index > 0) {
//               FocusScope.of(context).requestFocus(
//                   webseriesFocusNodes[webSeriesList[index - 1].id.toString()]);
//             }
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//             Provider.of<FocusProvider>(context, listen: false)
//                 .requestFirstMoviesFocus();
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//             Provider.of<FocusProvider>(context, listen: false)
//                 .requestFirstTVShowsFocus();
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.select ||
//               event.logicalKey == LogicalKeyboardKey.enter) {
//             _navigateToWebSeriesDetails(webSeries);
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: () => _navigateToWebSeriesDetails(webSeries),
//         child: ProfessionalWebSeriesCard(
//           webSeries: webSeries,
//           focusNode: focusNode,
//           onTap: () => _navigateToWebSeriesDetails(webSeries),
//         ),
//       ),
//     );
//   }
// }

// // =========================================================================
// // GRID PAGE (CRASH FIX IMPLEMENTED)
// // =========================================================================
// class ProfessionalWebSeriesGridPage extends StatefulWidget {
//   final List<WebSeriesModel> webSeriesList;
//   final String title;

//   const ProfessionalWebSeriesGridPage({
//     Key? key,
//     required this.webSeriesList,
//     this.title = 'All Web Series',
//   }) : super(key: key);

//   @override
//   _ProfessionalWebSeriesGridPageState createState() =>
//       _ProfessionalWebSeriesGridPageState();
// }

// class _ProfessionalWebSeriesGridPageState
//     extends State<ProfessionalWebSeriesGridPage>
//     with SingleTickerProviderStateMixin {
//   // ✅ FIX 1: Har item ke liye FocusNode ki list banayi gayi hai
//   late List<FocusNode> _itemFocusNodes;

//   final FocusNode _widgetFocusNode = FocusNode();
//   final ScrollController _scrollController = ScrollController();

//   int focusedIndex = 0;
//   bool _isVideoLoading = false;
//   static const int _itemsPerRow = 6;

//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();

//     // ✅ FIX 2: List ko initialize kiya gaya hai
//     _itemFocusNodes = List.generate(
//       widget.webSeriesList.length,
//       (index) => FocusNode(),
//     );

//     _initializeAnimations();
//     _startAnimations();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && _itemFocusNodes.isNotEmpty) {
//         // _widgetFocusNode.requestFocus();
//         _itemFocusNodes[focusedIndex].requestFocus();
//       }
//     });
//   }

//   void _initializeAnimations() {
//     _fadeController = AnimationController(
//         duration: const Duration(milliseconds: 400), vsync: this);
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
//   }

//   void _startAnimations() {
//     _fadeController.forward();
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _widgetFocusNode.dispose();
//     _scrollController.dispose();

//     // ✅ FIX 3: Sabhi FocusNodes ko theek se dispose kiya gaya hai
//     for (var node in _itemFocusNodes) {
//       node.dispose();
//     }

//     super.dispose();
//   }

//   void _handleKeyNavigation(RawKeyEvent event) {
//     if (event is! RawKeyDownEvent ||
//         _isVideoLoading ||
//         widget.webSeriesList.isEmpty) return;

//     final totalItems = widget.webSeriesList.length;
//     int previousIndex = focusedIndex;

//     if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//       if (focusedIndex >= _itemsPerRow) {
//         setState(() => focusedIndex -= _itemsPerRow);
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//       final nextRowStartIndex = focusedIndex + _itemsPerRow;
//       if (nextRowStartIndex < totalItems) {
//         setState(
//             () => focusedIndex = math.min(nextRowStartIndex, totalItems - 1));
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//       if (focusedIndex % _itemsPerRow != 0) {
//         setState(() => focusedIndex--);
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//       if (focusedIndex % _itemsPerRow != _itemsPerRow - 1 &&
//           focusedIndex < totalItems - 1) {
//         setState(() => focusedIndex++);
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.select ||
//         event.logicalKey == LogicalKeyboardKey.enter) {
//       _navigateToWebSeriesDetails(
//           widget.webSeriesList[focusedIndex], focusedIndex);
//     }

//     if (previousIndex != focusedIndex) {
//       // ✅ FIX 4: Naya aur reliable scroll function call kiya ja raha hai
//       _updateAndScrollToFocus();
//       HapticFeedback.lightImpact();
//     }
//   }

//   void _safeSetState(VoidCallback fn) {
//     if (mounted) {
//       setState(fn);
//     }
//   }

//   // ✅ FIX 5: Yeh naya, reliable scroll function hai jo crash hone se bachata hai
//   void _updateAndScrollToFocus() {
//     if (!mounted || focusedIndex >= _itemFocusNodes.length) return;

//     final focusNode = _itemFocusNodes[focusedIndex];
//     focusNode.requestFocus();

//     Scrollable.ensureVisible(
//       focusNode.context!,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOutCubic,
//       alignment: 0.3, // Item ko screen ke thoda upar rakhega
//     );
//   }

//   void _navigateToWebSeriesDetails(WebSeriesModel webSeries, int index) {
//     if (_isVideoLoading) return;

//     _safeSetState(() => _isVideoLoading = true);

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => WebSeriesDetailsPage(
//           id: webSeries.id,
//           banner: webSeries.banner ?? webSeries.poster ?? '',
//           poster: webSeries.poster ?? '',
//           name: webSeries.name,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Container(
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
//             Column(
//               children: [
//                 _buildProfessionalAppBar(),
//                 Expanded(
//                   child: FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: RawKeyboardListener(
//                       focusNode: _widgetFocusNode,
//                       onKey: _handleKeyNavigation,
//                       // autofocus: true,
//                       child: _buildContent(),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             if (_isVideoLoading)
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black.withOpacity(0.7),
//                   child: const Center(
//                     child: ProfessionalWebSeriesLoadingIndicator(
//                         message: 'Loading Details...'),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalAppBar() {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border(
//             bottom: BorderSide(
//                 color: ProfessionalColors.accentPurple.withOpacity(0.3),
//                 width: 1)),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.4),
//               blurRadius: 15,
//               offset: const Offset(0, 3))
//         ],
//       ),
//       child: ClipRRect(
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
//           child: Container(
//             padding: EdgeInsets.only(
//               top: MediaQuery.of(context).padding.top + 15,
//               left: 40,
//               right: 40,
//               bottom: 15,
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: LinearGradient(colors: [
//                       ProfessionalColors.accentPurple.withOpacity(0.4),
//                       ProfessionalColors.accentBlue.withOpacity(0.4),
//                     ]),
//                   ),
//                   child: IconButton(
//                     icon: const Icon(Icons.arrow_back_rounded,
//                         color: Colors.white, size: 24),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ShaderMask(
//                         shaderCallback: (bounds) => const LinearGradient(
//                           colors: [
//                             ProfessionalColors.accentPurple,
//                             ProfessionalColors.accentBlue
//                           ],
//                         ).createShader(bounds),
//                         child: Text(
//                           widget.title.toUpperCase(),
//                           style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 24,
//                               fontWeight: FontWeight.w700,
//                               letterSpacing: 1.0),
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(colors: [
//                             ProfessionalColors.accentPurple.withOpacity(0.4),
//                             ProfessionalColors.accentBlue.withOpacity(0.3),
//                           ]),
//                           borderRadius: BorderRadius.circular(15),
//                           border: Border.all(
//                               color: ProfessionalColors.accentPurple
//                                   .withOpacity(0.6),
//                               width: 1),
//                         ),
//                         child: Text(
//                           '${widget.webSeriesList.length} Web Series Available',
//                           style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600),
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

//   Widget _buildContent() {
//     if (widget.webSeriesList.isEmpty) {
//       return _buildEmptyWidget();
//     } else {
//       return _buildGridView();
//     }
//   }

//   Widget _buildEmptyWidget() {
//     return const Center(
//       child: Text(
//         'No Web Series Found',
//         style: TextStyle(color: ProfessionalColors.textSecondary, fontSize: 18),
//       ),
//     );
//   }

//   Widget _buildGridView() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: GridView.builder(
//         controller: _scrollController,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: _itemsPerRow,
//           crossAxisSpacing: 15.0,
//           mainAxisSpacing: 15.0,
//           childAspectRatio: 1.5,
//         ),
//         clipBehavior: Clip.none,
//         itemCount: widget.webSeriesList.length,
//         itemBuilder: (context, index) {
//           // ✅ FIX 6: Card ko 'Focus' widget se wrap kiya gaya hai
//           return Focus(
//             focusNode: _itemFocusNodes[index],
//             child: OptimizedWebSeriesGridCard(
//               webSeries: widget.webSeriesList[index],
//               isFocused: focusedIndex == index,
//               onTap: () => _navigateToWebSeriesDetails(
//                   widget.webSeriesList[index], index),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // =========================================================================
// // SUPPORTING WIDGETS (CARDS, BUTTONS, INDICATORS)
// // =========================================================================

// class ProfessionalWebSeriesCard extends StatefulWidget {
//   final WebSeriesModel webSeries;
//   final FocusNode focusNode;
//   final VoidCallback onTap;

//   const ProfessionalWebSeriesCard({
//     Key? key,
//     required this.webSeries,
//     required this.focusNode,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   _ProfessionalWebSeriesCardState createState() =>
//       _ProfessionalWebSeriesCardState();
// }

// class _ProfessionalWebSeriesCardState extends State<ProfessionalWebSeriesCard>
//     with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late Animation<double> _scaleAnimation;
//   Color _dominantColor = ProfessionalColors.accentBlue;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     _scaleController =
//         AnimationController(duration: AnimationTiming.slow, vsync: this);
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
//         CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));
//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     if (!mounted) return;
//     setState(() => _isFocused = widget.focusNode.hasFocus);
//     if (_isFocused) {
//       _scaleController.forward();
//       _dominantColor = ProfessionalColors.gradientColors[
//           math.Random().nextInt(ProfessionalColors.gradientColors.length)];
//       HapticFeedback.lightImpact();
//     } else {
//       _scaleController.reverse();
//     }
//   }

//   @override
//   void dispose() {
//     widget.focusNode.removeListener(_handleFocusChange);
//     _scaleController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _scaleAnimation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: Container(
//             width: bannerwdt,
//             margin: const EdgeInsets.symmetric(horizontal: 6),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 _buildProfessionalPoster(),
//                 _buildProfessionalTitle(),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProfessionalPoster() {
//     final posterHeight = _isFocused ? focussedBannerhgt : bannerhgt;
//     return Container(
//       height: posterHeight,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         border: _isFocused ? Border.all(color: _dominantColor, width: 3) : null,
//         boxShadow: [
//           if (_isFocused)
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.4),
//               blurRadius: 25,
//               spreadRadius: 3,
//               offset: const Offset(0, 8),
//             ),
//           BoxShadow(
//             color: Colors.black.withOpacity(0.4),
//             blurRadius: 10,
//             spreadRadius: 2,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Stack(
//           children: [
//             _buildWebSeriesImage(posterHeight),
//             if (_isFocused) _buildHoverOverlay(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWebSeriesImage(double posterHeight) {
//     return SizedBox(
//       width: double.infinity,
//       height: posterHeight,
//       child: widget.webSeries.banner != null &&
//               widget.webSeries.banner!.isNotEmpty
//           ? CachedNetworkImage(
//               imageUrl: widget.webSeries.banner!,
//               fit: BoxFit.cover,
//               placeholder: (context, url) => _buildImagePlaceholder(),
//               errorWidget: (context, url, error) => _buildImagePlaceholder(),
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
//           colors: [ProfessionalColors.cardDark, ProfessionalColors.surfaceDark],
//         ),
//       ),
//       child: const Center(
//         child: Icon(Icons.tv_outlined,
//             size: 40, color: ProfessionalColors.textSecondary),
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
//             colors: [Colors.transparent, _dominantColor.withOpacity(0.1)],
//           ),
//         ),
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.7),
//               borderRadius: BorderRadius.circular(25),
//             ),
//             child:
//                 Icon(Icons.play_arrow_rounded, color: _dominantColor, size: 30),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalTitle() {
//     return SizedBox(
//       width: bannerwdt,
//       child: AnimatedDefaultTextStyle(
//         duration: AnimationTiming.medium,
//         style: TextStyle(
//           fontSize: _isFocused ? 13 : 11,
//           fontWeight: FontWeight.w600,
//           color: _isFocused ? _dominantColor : ProfessionalColors.textPrimary,
//           letterSpacing: 0.5,
//         ),
//         child: Text(
//           widget.webSeries.name.toUpperCase(),
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }

// class OptimizedWebSeriesGridCard extends StatelessWidget {
//   final WebSeriesModel webSeries;
//   final bool isFocused;
//   final VoidCallback onTap;

//   const OptimizedWebSeriesGridCard({
//     Key? key,
//     required this.webSeries,
//     required this.isFocused,
//     required this.onTap,
//   }) : super(key: key);

//   Color _getDominantColor() {
//     final colors = ProfessionalColors.gradientColors;
//     return colors[math.Random(webSeries.id).nextInt(colors.length)];
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dominantColor = _getDominantColor();
//     return AnimatedContainer(
//       duration: AnimationTiming.fast,
//       transform:
//           isFocused ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
//       transformAlignment: Alignment.center,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         border: isFocused ? Border.all(color: dominantColor, width: 3) : null,
//         boxShadow: [
//           if (isFocused)
//             BoxShadow(
//               color: dominantColor.withOpacity(0.4),
//               blurRadius: 20,
//               spreadRadius: 2,
//               offset: const Offset(0, 8),
//             ),
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 8,
//             spreadRadius: 1,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             _buildWebSeriesImage(),
//             _buildGradientOverlay(),
//             _buildWebSeriesInfo(dominantColor),
//             if (isFocused) _buildPlayButton(dominantColor),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWebSeriesImage() {
//     final imageUrl = webSeries.banner ?? webSeries.poster;
//     return imageUrl != null && imageUrl.isNotEmpty
//         ? CachedNetworkImage(
//             imageUrl: imageUrl,
//             fit: BoxFit.cover,
//             placeholder: (context, url) => _buildImagePlaceholder(),
//             errorWidget: (context, url, error) => _buildImagePlaceholder(),
//           )
//         : _buildImagePlaceholder();
//   }

//   Widget _buildImagePlaceholder() {
//     return Container(
//       color: ProfessionalColors.cardDark,
//       child: const Center(
//         child: Icon(Icons.tv_outlined,
//             size: 40, color: ProfessionalColors.textSecondary),
//       ),
//     );
//   }

//   Widget _buildGradientOverlay() {
//     return const Positioned.fill(
//       child: DecoratedBox(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.transparent, Colors.black54, Colors.black87],
//             stops: [0.4, 0.7, 1.0],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildWebSeriesInfo(Color dominantColor) {
//     return Positioned(
//       bottom: 12,
//       left: 12,
//       right: 12,
//       child: Text(
//         webSeries.name.toUpperCase(),
//         style: TextStyle(
//           color: isFocused ? dominantColor : Colors.white,
//           fontSize: isFocused ? 13 : 12,
//           fontWeight: FontWeight.w600,
//           letterSpacing: 0.5,
//           shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
//         ),
//         maxLines: 2,
//         overflow: TextOverflow.ellipsis,
//       ),
//     );
//   }

//   Widget _buildPlayButton(Color dominantColor) {
//     return Positioned(
//       top: 12,
//       right: 12,
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: dominantColor.withOpacity(0.9),
//         ),
//         child:
//             const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
//       ),
//     );
//   }
// }

// class ProfessionalWebSeriesViewAllButton extends StatefulWidget {
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int totalItems;

//   const ProfessionalWebSeriesViewAllButton({
//     Key? key,
//     required this.focusNode,
//     required this.onTap,
//     required this.totalItems,
//   }) : super(key: key);

//   @override
//   _ProfessionalWebSeriesViewAllButtonState createState() =>
//       _ProfessionalWebSeriesViewAllButtonState();
// }

// class _ProfessionalWebSeriesViewAllButtonState
//     extends State<ProfessionalWebSeriesViewAllButton> {
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     if (mounted) setState(() => _isFocused = widget.focusNode.hasFocus);
//   }

//   @override
//   void dispose() {
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: bannerwdt,
//       margin: const EdgeInsets.symmetric(horizontal: 6),
//       child: Column(
//         children: [
//           AnimatedContainer(
//             duration: AnimationTiming.fast,
//             height: _isFocused ? focussedBannerhgt : bannerhgt,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               border: _isFocused
//                   ? Border.all(color: ProfessionalColors.accentPurple, width: 3)
//                   : null,
//               gradient: const LinearGradient(
//                 colors: [
//                   ProfessionalColors.cardDark,
//                   ProfessionalColors.surfaceDark
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.grid_view_rounded,
//                     size: 35,
//                     color: _isFocused
//                         ? ProfessionalColors.accentPurple
//                         : Colors.white),
//                 const SizedBox(height: 8),
//                 Text('VIEW ALL',
//                     style: TextStyle(
//                         color: _isFocused
//                             ? ProfessionalColors.accentPurple
//                             : Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14)),
//                 const SizedBox(height: 6),
//                 Text('${widget.totalItems}',
//                     style: const TextStyle(
//                         color: ProfessionalColors.textSecondary, fontSize: 12)),
//               ],
//             ),
//           ),
//           AnimatedDefaultTextStyle(
//             duration: AnimationTiming.medium,
//             style: TextStyle(
//               fontSize: _isFocused ? 13 : 11,
//               fontWeight: FontWeight.w600,
//               color: _isFocused
//                   ? ProfessionalColors.accentPurple
//                   : ProfessionalColors.textPrimary,
//             ),
//             child: const Text('ALL SERIES', textAlign: TextAlign.center),
//           )
//         ],
//       ),
//     );
//   }
// }

// class ProfessionalWebSeriesLoadingIndicator extends StatelessWidget {
//   final String message;
//   const ProfessionalWebSeriesLoadingIndicator({Key? key, required this.message})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const CircularProgressIndicator(
//               color: ProfessionalColors.accentPurple),
//           const SizedBox(height: 20),
//           Text(
//             message,
//             style: const TextStyle(
//                 color: ProfessionalColors.textPrimary, fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }
// }





import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobi_tv_entertainment/home_screen_pages/webseries_screen/webseries_details_page.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'dart:ui';

/*
  Ye code istemal karne se pehle, ye dependencies aapke pubspec.yaml file mein honi chahiye:
 
  dependencies:
    flutter:
      sdk: flutter
    provider: ^6.0.0
    http: ^1.0.0
    shared_preferences: ^2.0.0
    cached_network_image: ^3.2.0
*/

// ✅ Professional Color Palette
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

// ✅ Professional Animation Durations
class AnimationTiming {
  static const Duration ultraFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration focus = Duration(milliseconds: 300);
  static const Duration scroll = Duration(milliseconds: 800);
}

// ✅ WebSeries Model (series_order ke saath)
class WebSeriesModel {
  final int id;
  final String name;
  final String? description;
  final String? poster;
  final String? banner;
  final String? releaseDate;
  final String? genres;
  final int seriesOrder; // ✅ FIX: series_order add kiya gaya

  WebSeriesModel({
    required this.id,
    required this.name,
    this.description,
    this.poster,
    this.banner,
    this.releaseDate,
    this.genres,
    required this.seriesOrder, // ✅ FIX: series_order add kiya gaya
  });

  factory WebSeriesModel.fromJson(Map<String, dynamic> json) {
    return WebSeriesModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      poster: json['poster'],
      banner: json['banner'],
      releaseDate: json['release_date'],
      genres: json['genres'],
      seriesOrder: json['series_order'] ?? 9999, // ✅ FIX: series_order parse kiya gaya
    );
  }
}

// 🚀 Enhanced WebSeries Service with Caching and Sorting
class WebSeriesService {
  static const String _cacheKeyWebSeries = 'cached_web_series';
  static const String _cacheKeyTimestamp = 'cached_web_series_timestamp';
  static const String _cacheKeyAuthKey = 'auth_key';
  static const int _cacheDurationMs = 60 * 60 * 1000; // 1 hour

  static Future<List<WebSeriesModel>> getAllWebSeries(
      {bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!forceRefresh && await _shouldUseCache(prefs)) {
        print('📦 Loading Web Series from cache...');
        final cachedWebSeries = await _getCachedWebSeries(prefs);
        if (cachedWebSeries.isNotEmpty) {
          _loadFreshDataInBackground();
          return cachedWebSeries;
        }
      }
      print('🌐 Loading fresh Web Series from API...');
      return await _fetchFreshWebSeries(prefs);
    } catch (e) {
      print('❌ Error in getAllWebSeries: $e');
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedWebSeries = await _getCachedWebSeries(prefs);
        if (cachedWebSeries.isNotEmpty) {
          print('🔄 Returning cached data as fallback');
          return cachedWebSeries;
        }
      } catch (cacheError) {
        print('❌ Cache fallback also failed: $cacheError');
      }
      throw Exception('Failed to load web series: $e');
    }
  }

  static Future<bool> _shouldUseCache(SharedPreferences prefs) async {
    try {
      final timestampStr = prefs.getString(_cacheKeyTimestamp);
      if (timestampStr == null) return false;
      final cachedTimestamp = int.tryParse(timestampStr);
      if (cachedTimestamp == null) return false;
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      return (currentTimestamp - cachedTimestamp) < _cacheDurationMs;
    } catch (e) {
      print('❌ Error checking WebSeries cache validity: $e');
      return false;
    }
  }

  static Future<List<WebSeriesModel>> _getCachedWebSeries(
      SharedPreferences prefs) async {
    try {
      final cachedData = prefs.getString(_cacheKeyWebSeries);
      if (cachedData == null || cachedData.isEmpty) return [];
      final List<dynamic> jsonData = json.decode(cachedData);
      List<WebSeriesModel> webSeries = jsonData
          .map((json) => WebSeriesModel.fromJson(json as Map<String, dynamic>))
          .toList();
      // ✅ FIX: Cache se load karte waqt bhi sort karein
      webSeries.sort((a, b) => a.seriesOrder.compareTo(b.seriesOrder));
      return webSeries;
    } catch (e) {
      print('❌ Error loading cached web series: $e');
      return [];
    }
  }

  static Future<List<WebSeriesModel>> _fetchFreshWebSeries(
      SharedPreferences prefs) async {
    try {
      String authKey = prefs.getString(_cacheKeyAuthKey) ?? '';
      final response = await http.get(
        Uri.parse('https://acomtv.coretechinfo.com/api/v2/getAllWebSeries'),
        headers: {
          'auth-key': authKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'domain': 'coretechinfo.com'
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        await _cacheWebSeries(prefs, jsonData);
        List<WebSeriesModel> webSeries = jsonData
            .map(
                (json) => WebSeriesModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // ✅ FIX: API se fetch karne ke baad data ko series_order se sort kiya gaya
        webSeries.sort((a, b) => a.seriesOrder.compareTo(b.seriesOrder));
        
        return webSeries;
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ Error fetching fresh web series: $e');
      rethrow;
    }
  }

  static Future<void> _cacheWebSeries(
      SharedPreferences prefs, List<dynamic> webSeriesData) async {
    try {
      final jsonString = json.encode(webSeriesData);
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();
      await Future.wait([
        prefs.setString(_cacheKeyWebSeries, jsonString),
        prefs.setString(_cacheKeyTimestamp, currentTimestamp),
      ]);
      print('💾 Successfully cached ${webSeriesData.length} web series');
    } catch (e) {
      print('❌ Error caching web series: $e');
    }
  }

  static void _loadFreshDataInBackground() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        print('🔄 Loading fresh web series data in background...');
        final prefs = await SharedPreferences.getInstance();
        await _fetchFreshWebSeries(prefs);
        print('✅ WebSeries background refresh completed');
      } catch (e) {
        print('⚠️ WebSeries background refresh failed: $e');
      }
    });
  }

  static Future<List<WebSeriesModel>> forceRefresh() async {
    print('🔄 Force refreshing WebSeries data...');
    return await getAllWebSeries(forceRefresh: true);
  }
}

// 🚀 Enhanced ProfessionalWebSeriesHorizontalList
class ProfessionalWebSeriesHorizontalList extends StatefulWidget {
  @override
  _ProfessionalWebSeriesHorizontalListState createState() =>
      _ProfessionalWebSeriesHorizontalListState();
}

class _ProfessionalWebSeriesHorizontalListState
    extends State<ProfessionalWebSeriesHorizontalList>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  List<WebSeriesModel> webSeriesList = [];
  bool isLoading = true;
  int focusedIndex = -1;
  final int maxHorizontalItems = 7;

  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;

  Map<String, FocusNode> webseriesFocusNodes = {};
  FocusNode? _viewAllFocusNode;
  FocusNode? _firstWebSeriesFocusNode;
  bool _hasReceivedFocusFromMovies = false;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeAnimations();
    _initializeFocusNodes();
    fetchWebSeriesWithCache();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _listAnimationController.dispose();
    for (var node in webseriesFocusNodes.values) {
      node.dispose();
    }
    webseriesFocusNodes.clear();
    _viewAllFocusNode?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _headerAnimationController =
        AnimationController(duration: AnimationTiming.slow, vsync: this);
    _listAnimationController =
        AnimationController(duration: AnimationTiming.slow, vsync: this);
    _headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _headerAnimationController,
                curve: Curves.easeOutCubic));
    _listFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _listAnimationController, curve: Curves.easeInOut));
  }

  void _initializeFocusNodes() {
    _viewAllFocusNode = FocusNode();
  }

  void _scrollToPosition(int index) {
    if (!mounted || !_scrollController.hasClients) return;
    try {
      double bannerwidth = bannerwdt;
      double scrollPosition = index * bannerwidth;
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    } catch (e) {
      print('Error scrolling in webseries: $e');
    }
  }

  void _setupFocusProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && webSeriesList.isNotEmpty) {
        final focusProvider =
            Provider.of<FocusProvider>(context, listen: false);
        final firstWebSeriesId = webSeriesList[0].id.toString();
        webseriesFocusNodes.putIfAbsent(firstWebSeriesId, () => FocusNode());
        _firstWebSeriesFocusNode = webseriesFocusNodes[firstWebSeriesId];
        _firstWebSeriesFocusNode?.addListener(() {
          if (_firstWebSeriesFocusNode!.hasFocus &&
              !_hasReceivedFocusFromMovies) {
            _hasReceivedFocusFromMovies = true;
            setState(() => focusedIndex = 0);
            _scrollToPosition(0);
          }
        });
        focusProvider
            .setFirstManageWebseriesFocusNode(_firstWebSeriesFocusNode!);
      }
    });
  }

  Future<void> fetchWebSeriesWithCache() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final fetchedWebSeries = await WebSeriesService.getAllWebSeries();
      if (mounted) {
        setState(() {
          webSeriesList = fetchedWebSeries;
          isLoading = false;
        });
        _createFocusNodesForItems();
        _setupFocusProvider();
        _headerAnimationController.forward();
        _listAnimationController.forward();
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      print('Error fetching WebSeries with cache: $e');
    }
  }

  void _createFocusNodesForItems() {
    for (var node in webseriesFocusNodes.values) {
      node.dispose();
    }
    webseriesFocusNodes.clear();
    for (int i = 0; i < webSeriesList.length && i < maxHorizontalItems; i++) {
      String webSeriesId = webSeriesList[i].id.toString();
      webseriesFocusNodes[webSeriesId] = FocusNode();
      webseriesFocusNodes[webSeriesId]!.addListener(() {
        if (mounted && webseriesFocusNodes[webSeriesId]!.hasFocus) {
          setState(() {
            focusedIndex = i;
            _hasReceivedFocusFromMovies = true;
          });
          _scrollToPosition(i);
        }
      });
    }
  }

  void _navigateToWebSeriesDetails(WebSeriesModel webSeries) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebSeriesDetailsPage(
          id: webSeries.id,
          banner: webSeries.banner ?? webSeries.poster ?? '',
          poster: webSeries.poster ?? webSeries.banner ?? '',
          logo: webSeries.poster ?? webSeries.banner ?? '',
          name: webSeries.name,
        ),
      ),
    ).then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          int currentIndex =
              webSeriesList.indexWhere((ws) => ws.id == webSeries.id);
          if (currentIndex != -1 && currentIndex < maxHorizontalItems) {
            String webSeriesId = webSeries.id.toString();
            if (webseriesFocusNodes.containsKey(webSeriesId)) {
              setState(() {
                focusedIndex = currentIndex;
                _hasReceivedFocusFromMovies = true;
              });
              webseriesFocusNodes[webSeriesId]!.requestFocus();
              _scrollToPosition(currentIndex);
            }
          }
        }
      });
    });
  }

  void _navigateToGridPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessionalWebSeriesGridPage(
          webSeriesList: webSeriesList,
          title: 'All Web Series',
        ),
      ),
    ).then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _viewAllFocusNode != null) {
          setState(() {
            focusedIndex = maxHorizontalItems;
            _hasReceivedFocusFromMovies = true;
          });
          _viewAllFocusNode!.requestFocus();
          _scrollToPosition(maxHorizontalItems);
        }
      });
    });
  }

  // BUILD METHOD and WIDGETS
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ColorProvider>(
      builder: (context, colorProvider, child) {
        final bgColor = colorProvider.isItemFocused
            ? colorProvider.dominantColor.withOpacity(0.1)
            : ProfessionalColors.primaryDark;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bgColor,
                  bgColor.withOpacity(0.8),
                  ProfessionalColors.primaryDark,
                ],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildProfessionalTitle(),
                const SizedBox(height: 10),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfessionalTitle() {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  ProfessionalColors.accentPurple,
                  ProfessionalColors.accentBlue
                ],
              ).createShader(bounds),
              child: const Text(
                'WEB SERIES',
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0),
              ),
            ),
            if (webSeriesList.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    ProfessionalColors.accentPurple.withOpacity(0.2),
                    ProfessionalColors.accentBlue.withOpacity(0.2),
                  ]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: ProfessionalColors.accentPurple.withOpacity(0.3),
                      width: 1),
                ),
                child: Text(
                  '${webSeriesList.length} Series Available',
                  style: const TextStyle(
                      color: ProfessionalColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const ProfessionalWebSeriesLoadingIndicator(
          message: 'Loading Web Series...');
    } else if (webSeriesList.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildWebSeriesList();
    }
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.tv_off_outlined,
              size: 50, color: ProfessionalColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'No Web Series Found',
            style: TextStyle(
                color: ProfessionalColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Please check back later.',
            style: TextStyle(
                color: ProfessionalColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildWebSeriesList() {
    bool showViewAll = webSeriesList.length > 7;
    return FadeTransition(
      opacity: _listFadeAnimation,
      child: SizedBox(
        height: 300,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: showViewAll ? 8 : webSeriesList.length,
          itemBuilder: (context, index) {
            if (showViewAll && index == 7) {
              return _buildViewAllButton();
            }
            var webSeries = webSeriesList[index];
            return _buildWebSeriesItem(webSeries, index);
          },
        ),
      ),
    );
  }

  Widget _buildViewAllButton() {
    return Focus(
      focusNode: _viewAllFocusNode,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            FocusScope.of(context).requestFocus(
                webseriesFocusNodes[webSeriesList[6].id.toString()]);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            Provider.of<FocusProvider>(context, listen: false)
                .requestFirstMoviesFocus();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            Provider.of<FocusProvider>(context, listen: false)
                .requestFirstTVShowsFocus();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            _navigateToGridPage();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: _navigateToGridPage,
        child: ProfessionalWebSeriesViewAllButton(
          focusNode: _viewAllFocusNode!,
          onTap: _navigateToGridPage,
          totalItems: webSeriesList.length,
        ),
      ),
    );
  }

  Widget _buildWebSeriesItem(WebSeriesModel webSeries, int index) {
    String webSeriesId = webSeries.id.toString();
    FocusNode? focusNode = webseriesFocusNodes[webSeriesId];

    if (focusNode == null) return const SizedBox.shrink();

    return Focus(
      focusNode: focusNode,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          Color dominantColor = ProfessionalColors.gradientColors[
              math.Random().nextInt(ProfessionalColors.gradientColors.length)];
          context.read<ColorProvider>().updateColor(dominantColor, true);
        } else {
          context.read<ColorProvider>().resetColor();
        }
      },
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (index < 6 && index < webSeriesList.length - 1) {
              FocusScope.of(context).requestFocus(
                  webseriesFocusNodes[webSeriesList[index + 1].id.toString()]);
            } else if (index == 6 && webSeriesList.length > 7) {
              FocusScope.of(context).requestFocus(_viewAllFocusNode);
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (index > 0) {
              FocusScope.of(context).requestFocus(
                  webseriesFocusNodes[webSeriesList[index - 1].id.toString()]);
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            Provider.of<FocusProvider>(context, listen: false)
                .requestFirstMoviesFocus();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            Provider.of<FocusProvider>(context, listen: false)
                .requestFirstTVShowsFocus();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            _navigateToWebSeriesDetails(webSeries);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _navigateToWebSeriesDetails(webSeries),
        child: ProfessionalWebSeriesCard(
          webSeries: webSeries,
          focusNode: focusNode,
          onTap: () => _navigateToWebSeriesDetails(webSeries),
        ),
      ),
    );
  }
}

// // =========================================================================
// // GRID PAGE - CRASH FIX AND PERFORMANCE OPTIMIZATION
// // =========================================================================
// class ProfessionalWebSeriesGridPage extends StatefulWidget {
//   final List<WebSeriesModel> webSeriesList;
//   final String title;

//   const ProfessionalWebSeriesGridPage({
//     Key? key,
//     required this.webSeriesList,
//     this.title = 'All Web Series',
//   }) : super(key: key);

//   @override
//   _ProfessionalWebSeriesGridPageState createState() =>
//       _ProfessionalWebSeriesGridPageState();
// }

// class _ProfessionalWebSeriesGridPageState
//     extends State<ProfessionalWebSeriesGridPage>
//     with SingleTickerProviderStateMixin {
//   // ✅ FIX: _itemFocusNodes ko late se initialize kiya jayega.
//   // Isse humein crash se bachne mein madad milegi.
//   late List<FocusNode> _itemFocusNodes;
//   final FocusNode _widgetFocusNode = FocusNode();
//   final ScrollController _scrollController = ScrollController();

//   int focusedIndex = 0;
//   bool _isVideoLoading = false;
//   static const int _itemsPerRow = 6;

//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();

//     // ✅ FIX: Ab hum saare focus nodes ek saath nahi banayenge.
//     _itemFocusNodes = List.generate(
//       widget.webSeriesList.length,
//       (index) => FocusNode(),
//     );

//     _initializeAnimations();
//     _startAnimations();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && _itemFocusNodes.isNotEmpty) {
//         _itemFocusNodes[focusedIndex].requestFocus();
//       }
//     });
//   }

//   void _initializeAnimations() {
//     _fadeController = AnimationController(
//         duration: const Duration(milliseconds: 400), vsync: this);
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
//   }

//   void _startAnimations() {
//     _fadeController.forward();
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _widgetFocusNode.dispose();
//     _scrollController.dispose();

//     for (var node in _itemFocusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }

//   void _handleKeyNavigation(RawKeyEvent event) {
//     if (event is! RawKeyDownEvent ||
//         _isVideoLoading ||
//         widget.webSeriesList.isEmpty) return;

//     final totalItems = widget.webSeriesList.length;
//     int previousIndex = focusedIndex;

//     if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//       if (focusedIndex >= _itemsPerRow) {
//         setState(() => focusedIndex -= _itemsPerRow);
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//       if (focusedIndex < totalItems - _itemsPerRow) {
//         setState(
//             () => focusedIndex = math.min(focusedIndex + _itemsPerRow, totalItems - 1));
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//       if (focusedIndex % _itemsPerRow != 0) {
//         setState(() => focusedIndex--);
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//       if (focusedIndex % _itemsPerRow != _itemsPerRow - 1 &&
//           focusedIndex < totalItems - 1) {
//         setState(() => focusedIndex++);
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.select ||
//         event.logicalKey == LogicalKeyboardKey.enter) {
//       _navigateToWebSeriesDetails(
//           widget.webSeriesList[focusedIndex], focusedIndex);
//     }

//     if (previousIndex != focusedIndex) {
//       _updateAndScrollToFocus();
//       HapticFeedback.lightImpact();
//     }
//   }

//   void _safeSetState(VoidCallback fn) {
//     if (mounted) {
//       setState(fn);
//     }
//   }

//   void _updateAndScrollToFocus() {
//     if (!mounted || focusedIndex >= _itemFocusNodes.length) return;

//     final focusNode = _itemFocusNodes[focusedIndex];
//     focusNode.requestFocus();

//     // Ensure the widget is visible on screen
//     Scrollable.ensureVisible(
//       focusNode.context!,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOutCubic,
//       alignment: 0.3,
//     );
//   }

//   Future<void> _navigateToWebSeriesDetails(WebSeriesModel webSeries, int index) async {
//     if (_isVideoLoading) return;

//     _safeSetState(() => _isVideoLoading = true);

//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => WebSeriesDetailsPage(
//           id: webSeries.id,
//           banner: webSeries.banner ?? webSeries.poster ?? '',
//           poster: webSeries.poster ?? '',
//           name: webSeries.name,
//         ),
//       ),
//     );

//     if (mounted) {
//       _safeSetState(() {
//         _isVideoLoading = false;
//         focusedIndex = index;
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           _updateAndScrollToFocus();
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Container(
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
//             Column(
//               children: [
//                 _buildProfessionalAppBar(),
//                 Expanded(
//                   child: FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: RawKeyboardListener(
//                       focusNode: _widgetFocusNode,
//                       onKey: _handleKeyNavigation,
//                       autofocus: false, 
//                       child: _buildContent(),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             if (_isVideoLoading)
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black.withOpacity(0.7),
//                   child: const Center(
//                     child: ProfessionalWebSeriesLoadingIndicator(
//                         message: 'Loading Details...'),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalAppBar() {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border(
//             bottom: BorderSide(
//                 color: ProfessionalColors.accentPurple.withOpacity(0.3),
//                 width: 1)),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.4),
//               blurRadius: 15,
//               offset: const Offset(0, 3))
//         ],
//       ),
//       child: ClipRRect(
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
//           child: Container(
//             padding: EdgeInsets.only(
//               top: MediaQuery.of(context).padding.top + 15,
//               left: 40,
//               right: 40,
//               bottom: 15,
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: LinearGradient(colors: [
//                       ProfessionalColors.accentPurple.withOpacity(0.4),
//                       ProfessionalColors.accentBlue.withOpacity(0.4),
//                     ]),
//                   ),
//                   child: IconButton(
//                     icon: const Icon(Icons.arrow_back_rounded,
//                         color: Colors.white, size: 24),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ShaderMask(
//                         shaderCallback: (bounds) => const LinearGradient(
//                           colors: [
//                             ProfessionalColors.accentPurple,
//                             ProfessionalColors.accentBlue
//                           ],
//                         ).createShader(bounds),
//                         child: Text(
//                           widget.title.toUpperCase(),
//                           style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 24,
//                               fontWeight: FontWeight.w700,
//                               letterSpacing: 1.0),
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(colors: [
//                             ProfessionalColors.accentPurple.withOpacity(0.4),
//                             ProfessionalColors.accentBlue.withOpacity(0.3),
//                           ]),
//                           borderRadius: BorderRadius.circular(15),
//                           border: Border.all(
//                               color: ProfessionalColors.accentPurple
//                                   .withOpacity(0.6),
//                               width: 1),
//                         ),
//                         child: Text(
//                           '${widget.webSeriesList.length} Web Series Available',
//                           style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600),
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

//   Widget _buildContent() {
//     if (widget.webSeriesList.isEmpty) {
//       return const Center(
//         child: Text(
//           'No Web Series Found',
//           style: TextStyle(color: ProfessionalColors.textSecondary, fontSize: 18),
//         ),
//       );
//     } else {
//       return _buildGridView();
//     }
//   }

//   Widget _buildGridView() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: GridView.builder(
//         controller: _scrollController,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: _itemsPerRow,
//           crossAxisSpacing: 15.0,
//           mainAxisSpacing: 15.0,
//           childAspectRatio: 1.5,
//         ),
//         clipBehavior: Clip.none,
//         itemCount: widget.webSeriesList.length,
//         itemBuilder: (context, index) {
//           return Focus(
//             focusNode: _itemFocusNodes[index],
//             child: OptimizedWebSeriesGridCard(
//               webSeries: widget.webSeriesList[index],
//               isFocused: focusedIndex == index,
//               onTap: () => _navigateToWebSeriesDetails(
//                   widget.webSeriesList[index], index),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }




// ... (Your existing code for imports, models, services, etc.)

// =========================================================================
// GRID PAGE - CRASH FIX AND PERFORMANCE OPTIMIZATION
// =========================================================================
class ProfessionalWebSeriesGridPage extends StatefulWidget {
  final List<WebSeriesModel> webSeriesList;
  final String title;

  const ProfessionalWebSeriesGridPage({
    Key? key,
    required this.webSeriesList,
    this.title = 'All Web Series',
  }) : super(key: key);

  @override
  _ProfessionalWebSeriesGridPageState createState() =>
      _ProfessionalWebSeriesGridPageState();
}

class _ProfessionalWebSeriesGridPageState
    extends State<ProfessionalWebSeriesGridPage>
    with SingleTickerProviderStateMixin {
  late List<FocusNode> _itemFocusNodes;
  final FocusNode _widgetFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  int focusedIndex = 0;
  bool _isVideoLoading = false;
  static const int _itemsPerRow = 6;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    print("GridPage initState: webSeriesList length = ${widget.webSeriesList.length}");
    _initializeAnimations();
    _startAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ FIX: Initialize focus nodes here to ensure widget.webSeriesList is available
    _itemFocusNodes = List.generate(
      widget.webSeriesList.length,
      (index) => FocusNode(),
    );
    print("GridPage didChangeDependencies: _itemFocusNodes length = ${_itemFocusNodes.length}");


    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _itemFocusNodes.isNotEmpty) {
        _itemFocusNodes[focusedIndex].requestFocus();
      }
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
  }

  void _startAnimations() {
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _widgetFocusNode.dispose();
    _scrollController.dispose();

    for (var node in _itemFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleKeyNavigation(RawKeyEvent event) {
    if (event is! RawKeyDownEvent ||
        _isVideoLoading ||
        widget.webSeriesList.isEmpty) return;

    final totalItems = widget.webSeriesList.length;
    int previousIndex = focusedIndex;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (focusedIndex >= _itemsPerRow) {
        setState(() => focusedIndex -= _itemsPerRow);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (focusedIndex < totalItems - _itemsPerRow) {
        setState(
            () => focusedIndex = math.min(focusedIndex + _itemsPerRow, totalItems - 1));
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (focusedIndex % _itemsPerRow != 0) {
        setState(() => focusedIndex--);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (focusedIndex % _itemsPerRow != _itemsPerRow - 1 &&
          focusedIndex < totalItems - 1) {
        setState(() => focusedIndex++);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.select ||
        event.logicalKey == LogicalKeyboardKey.enter) {
      _navigateToWebSeriesDetails(
          widget.webSeriesList[focusedIndex], focusedIndex);
    }

    if (previousIndex != focusedIndex) {
      _updateAndScrollToFocus();
      HapticFeedback.lightImpact();
    }
  }

  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  void _updateAndScrollToFocus() {
    if (!mounted || focusedIndex >= _itemFocusNodes.length) return;

    final focusNode = _itemFocusNodes[focusedIndex];
    focusNode.requestFocus();

    // Ensure the widget is visible on screen
    Scrollable.ensureVisible(
      focusNode.context!,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      alignment: 0.3,
    );
  }

  Future<void> _navigateToWebSeriesDetails(WebSeriesModel webSeries, int index) async {
    if (_isVideoLoading) return;

    _safeSetState(() => _isVideoLoading = true);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebSeriesDetailsPage(
          id: webSeries.id,
          banner: webSeries.banner ?? webSeries.poster ?? '',
          poster: webSeries.poster ?? webSeries.banner ?? '',
          logo: webSeries.poster ?? webSeries.banner ?? '',
          name: webSeries.name,
        ),
      ),
    );

    if (mounted) {
      _safeSetState(() {
        _isVideoLoading = false;
        focusedIndex = index;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateAndScrollToFocus();
        }
      });
    }
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
            Column(
              children: [
                _buildProfessionalAppBar(),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: RawKeyboardListener(
                      focusNode: _widgetFocusNode,
                      onKey: _handleKeyNavigation,
                      autofocus: true,
                      child: _buildContent(),
                    ),
                  ),
                ),
              ],
            ),
            if (_isVideoLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: const Center(
                    child: ProfessionalWebSeriesLoadingIndicator(
                        message: 'Loading Details...'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalAppBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: ProfessionalColors.accentPurple.withOpacity(0.3),
                width: 1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 3))
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 15,
              left: 40,
              right: 40,
              bottom: 15,
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [
                      ProfessionalColors.accentPurple.withOpacity(0.4),
                      ProfessionalColors.accentBlue.withOpacity(0.4),
                    ]),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            ProfessionalColors.accentPurple,
                            ProfessionalColors.accentBlue
                          ],
                        ).createShader(bounds),
                        child: Text(
                          widget.title.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            ProfessionalColors.accentPurple.withOpacity(0.4),
                            ProfessionalColors.accentBlue.withOpacity(0.3),
                          ]),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: ProfessionalColors.accentPurple
                                  .withOpacity(0.6),
                              width: 1),
                        ),
                        child: Text(
                          '${widget.webSeriesList.length} Web Series Available',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
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

  Widget _buildContent() {
    if (widget.webSeriesList.isEmpty) {
      return const Center(
        child: Text(
          'No Web Series Found',
          style: TextStyle(color: ProfessionalColors.textSecondary, fontSize: 18),
        ),
      );
    } else {
      return _buildGridView();
    }
  }

  Widget _buildGridView() {
    print("Building GridView with ${_itemFocusNodes.length} focus nodes and ${widget.webSeriesList.length} items.");
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _itemsPerRow,
          crossAxisSpacing: 15.0,
          mainAxisSpacing: 15.0,
          childAspectRatio: 1.5,
        ),
        clipBehavior: Clip.none,
        itemCount: widget.webSeriesList.length,
        itemBuilder: (context, index) {
          if (index >= _itemFocusNodes.length) {
            // Safety check
            print("Error: Index $index is out of bounds for _itemFocusNodes with length ${_itemFocusNodes.length}");
            return const SizedBox.shrink();
          }
          return Focus(
            focusNode: _itemFocusNodes[index],
            child: OptimizedWebSeriesGridCard(
              webSeries: widget.webSeriesList[index],
              isFocused: focusedIndex == index,
              onTap: () => _navigateToWebSeriesDetails(
                  widget.webSeriesList[index], index),
            ),
          );
        },
      ),
    );
  }
}

// ... (Rest of your code for supporting widgets)


// =========================================================================
// SUPPORTING WIDGETS (CARDS, BUTTONS, INDICATORS)
// =========================================================================

class ProfessionalWebSeriesCard extends StatefulWidget {
  final WebSeriesModel webSeries;
  final FocusNode focusNode;
  final VoidCallback onTap;

  const ProfessionalWebSeriesCard({
    Key? key,
    required this.webSeries,
    required this.focusNode,
    required this.onTap,
  }) : super(key: key);

  @override
  _ProfessionalWebSeriesCardState createState() =>
      _ProfessionalWebSeriesCardState();
}

class _ProfessionalWebSeriesCardState extends State<ProfessionalWebSeriesCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  Color _dominantColor = ProfessionalColors.accentBlue;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _scaleController =
        AnimationController(duration: AnimationTiming.slow, vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));
    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!mounted) return;
    setState(() => _isFocused = widget.focusNode.hasFocus);
    if (_isFocused) {
      _scaleController.forward();
      _dominantColor = ProfessionalColors.gradientColors[
          math.Random().nextInt(ProfessionalColors.gradientColors.length)];
      HapticFeedback.lightImpact();
    } else {
      _scaleController.reverse();
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: bannerwdt,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfessionalPoster(),
                _buildProfessionalTitle(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfessionalPoster() {
    final posterHeight = _isFocused ? focussedBannerhgt : bannerhgt;
    return Container(
      height: posterHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: _isFocused ? Border.all(color: _dominantColor, width: 3) : null,
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: _dominantColor.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 3,
              offset: const Offset(0, 8),
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            _buildWebSeriesImage(posterHeight),
            if (_isFocused) _buildHoverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildWebSeriesImage(double posterHeight) {
    return SizedBox(
      width: double.infinity,
      height: posterHeight,
      child: widget.webSeries.banner != null &&
              widget.webSeries.banner!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: widget.webSeries.banner!,
              fit: BoxFit.cover,
              memCacheHeight: 300,
              placeholder: (context, url) => _buildImagePlaceholder(),
              errorWidget: (context, url, error) => _buildImagePlaceholder(),
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
          colors: [ProfessionalColors.cardDark, ProfessionalColors.surfaceDark],
        ),
      ),
      child: const Center(
        child: Icon(Icons.tv_outlined,
            size: 40, color: ProfessionalColors.textSecondary),
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
            colors: [Colors.transparent, _dominantColor.withOpacity(0.1)],
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(25),
            ),
            child:
                Icon(Icons.play_arrow_rounded, color: _dominantColor, size: 30),
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalTitle() {
    return SizedBox(
      width: bannerwdt,
      child: AnimatedDefaultTextStyle(
        duration: AnimationTiming.medium,
        style: TextStyle(
          fontSize: _isFocused ? 13 : 11,
          fontWeight: FontWeight.w600,
          color: _isFocused ? _dominantColor : ProfessionalColors.textPrimary,
          letterSpacing: 0.5,
        ),
        child: Text(
          widget.webSeries.name.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class OptimizedWebSeriesGridCard extends StatelessWidget {
  final WebSeriesModel webSeries;
  final bool isFocused;
  final VoidCallback onTap;

  const OptimizedWebSeriesGridCard({
    Key? key,
    required this.webSeries,
    required this.isFocused,
    required this.onTap,
  }) : super(key: key);

  Color _getDominantColor() {
    final colors = ProfessionalColors.gradientColors;
    return colors[math.Random(webSeries.id).nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    final dominantColor = _getDominantColor();
    return AnimatedContainer(
      duration: AnimationTiming.fast,
      transform:
          isFocused ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: isFocused ? Border.all(color: dominantColor, width: 3) : null,
        boxShadow: [
          if (isFocused)
            BoxShadow(
              color: dominantColor.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
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
            _buildWebSeriesImage(),
            _buildGradientOverlay(),
            _buildWebSeriesInfo(dominantColor),
            if (isFocused) _buildPlayButton(dominantColor),
          ],
        ),
      ),
    );
  }

  Widget _buildWebSeriesImage() {
    final imageUrl = webSeries.banner ?? webSeries.poster;
    return imageUrl != null && imageUrl.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            memCacheHeight: 300,
            placeholder: (context, url) => _buildImagePlaceholder(),
            errorWidget: (context, url, error) => _buildImagePlaceholder(),
          )
        : _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: ProfessionalColors.cardDark,
      child: const Center(
        child: Icon(Icons.tv_outlined,
            size: 40, color: ProfessionalColors.textSecondary),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black54, Colors.black87],
            stops: [0.4, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildWebSeriesInfo(Color dominantColor) {
    return Positioned(
      bottom: 12,
      left: 12,
      right: 12,
      child: Text(
        webSeries.name.toUpperCase(),
        style: TextStyle(
          color: isFocused ? dominantColor : Colors.white,
          fontSize: isFocused ? 13 : 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildPlayButton(Color dominantColor) {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: dominantColor.withOpacity(0.9),
        ),
        child:
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}

class ProfessionalWebSeriesViewAllButton extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int totalItems;

  const ProfessionalWebSeriesViewAllButton({
    Key? key,
    required this.focusNode,
    required this.onTap,
    required this.totalItems,
  }) : super(key: key);

  @override
  _ProfessionalWebSeriesViewAllButtonState createState() =>
      _ProfessionalWebSeriesViewAllButtonState();
}

class _ProfessionalWebSeriesViewAllButtonState
    extends State<ProfessionalWebSeriesViewAllButton> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: bannerwdt,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          AnimatedContainer(
            duration: AnimationTiming.fast,
            height: _isFocused ? focussedBannerhgt : bannerhgt,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: _isFocused
                  ? Border.all(color: ProfessionalColors.accentPurple, width: 3)
                  : null,
              gradient: const LinearGradient(
                colors: [
                  ProfessionalColors.cardDark,
                  ProfessionalColors.surfaceDark
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.grid_view_rounded,
                    size: 35,
                    color: _isFocused
                        ? ProfessionalColors.accentPurple
                        : Colors.white),
                const SizedBox(height: 8),
                Text('VIEW ALL',
                    style: TextStyle(
                        color: _isFocused
                            ? ProfessionalColors.accentPurple
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 6),
                Text('${widget.totalItems}',
                    style: const TextStyle(
                        color: ProfessionalColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: AnimationTiming.medium,
            style: TextStyle(
              fontSize: _isFocused ? 13 : 11,
              fontWeight: FontWeight.w600,
              color: _isFocused
                  ? ProfessionalColors.accentPurple
                  : ProfessionalColors.textPrimary,
            ),
            child: const Text('ALL SERIES', textAlign: TextAlign.center),
          )
        ],
      ),
    );
  }
}

class ProfessionalWebSeriesLoadingIndicator extends StatelessWidget {
  final String message;
  const ProfessionalWebSeriesLoadingIndicator({Key? key, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
              color: ProfessionalColors.accentPurple),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
                color: ProfessionalColors.textPrimary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}