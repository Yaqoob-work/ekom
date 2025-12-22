// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sports_category/sports_category_second_page.dart';
// import 'dart:math' as math;
// // import 'package:mobi_tv_entertainment/home_screen_pages/sports/sports_category_second_page.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
// import 'package:provider/provider.dart';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:ui';

// // ✅ Professional Color Palette (same as WebSeries)
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

// // ✅ Sports Category Model (UPDATED with thumbnail)
// class SportsCategoryModel {
//   final int id;
//   final int sportsCatOrder;
//   final String title;
//   final int status;
//   final String? createdAt;
//   final String? updatedAt;
//   final String? deletedAt;
//   final String? thumbnail; // 👈 UPDATED

//   SportsCategoryModel({
//     required this.id,
//     required this.sportsCatOrder,
//     required this.title,
//     required this.status,
//     this.createdAt,
//     this.updatedAt,
//     this.deletedAt,
//     this.thumbnail, // 👈 UPDATED
//   });

//   factory SportsCategoryModel.fromJson(Map<String, dynamic> json) {
//     return SportsCategoryModel(
//       id: json['id'] ?? 0,
//       sportsCatOrder: json['sports_cat_order'] ?? 0,
//       title: json['title'] ?? '',
//       status: json['status'] ?? 0,
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//       deletedAt: json['deleted_at'],
//       thumbnail: json['thumbnail'], // 👈 UPDATED
//     );
//   }
// }

// // 🚀 Enhanced Sports Categories Service with Caching
// class SportsCategoriesService {
//   // Cache keys
//   static const String _cacheKeySportsCategories = 'cached_sports_categories';
//   static const String _cacheKeyTimestamp = 'cached_sports_categories_timestamp';
//   static const String _cacheKeyAuthKey = 'result_auth_key';

//   // Cache duration (in milliseconds) - 1 hour
//   static const int _cacheDurationMs = 60 * 60 * 1000; // 1 hour

//   /// Main method to get all sports categories with caching
//   static Future<List<SportsCategoryModel>> getAllSportsCategories(
//       {bool forceRefresh = false}) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       // Check if we should use cache
//       if (!forceRefresh && await _shouldUseCache(prefs)) {
//         print('📦 Loading Sports Categories from cache...');
//         final cachedCategories = await _getCachedSportsCategories(prefs);
//         if (cachedCategories.isNotEmpty) {
//           print(
//               '✅ Successfully loaded ${cachedCategories.length} sports categories from cache');

//           // Load fresh data in background (without waiting)
//           _loadFreshDataInBackground();

//           return cachedCategories;
//         }
//       }

//       // Load fresh data if no cache or force refresh
//       print('🌐 Loading fresh Sports Categories from API...');
//       return await _fetchFreshSportsCategories(prefs);
//     } catch (e) {
//       print('❌ Error in getAllSportsCategories: $e');

//       // Try to return cached data as fallback
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         final cachedCategories = await _getCachedSportsCategories(prefs);
//         if (cachedCategories.isNotEmpty) {
//           print('🔄 Returning cached data as fallback');
//           return cachedCategories;
//         }
//       } catch (cacheError) {
//         print('❌ Cache fallback also failed: $cacheError');
//       }

//       throw Exception('Failed to load sports categories: $e');
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
//         print(
//             '📦 Sports Categories Cache is valid (${ageMinutes} minutes old)');
//       } else {
//         final ageMinutes = (cacheAge / (1000 * 60)).round();
//         print('⏰ Sports Categories Cache expired (${ageMinutes} minutes old)');
//       }

//       return isValid;
//     } catch (e) {
//       print('❌ Error checking Sports Categories cache validity: $e');
//       return false;
//     }
//   }

//   /// Get sports categories from cache
//   static Future<List<SportsCategoryModel>> _getCachedSportsCategories(
//       SharedPreferences prefs) async {
//     try {
//       final cachedData = prefs.getString(_cacheKeySportsCategories);
//       if (cachedData == null || cachedData.isEmpty) {
//         print('📦 No cached Sports Categories data found');
//         return [];
//       }

//       final List<dynamic> jsonData = json.decode(cachedData);
//       final categories = jsonData
//           .map((json) =>
//               SportsCategoryModel.fromJson(json as Map<String, dynamic>))
//           .where((category) => category.status == 1) // Filter active categories
//           .toList();

//       // Sort by sports_cat_order
//       categories.sort((a, b) => a.sportsCatOrder.compareTo(b.sportsCatOrder));

//       print(
//           '📦 Successfully loaded ${categories.length} sports categories from cache');
//       return categories;
//     } catch (e) {
//       print('❌ Error loading cached sports categories: $e');
//       return [];
//     }
//   }

//   /// Fetch fresh sports categories from API and cache them
//   static Future<List<SportsCategoryModel>> _fetchFreshSportsCategories(
//       SharedPreferences prefs) async {
//     try {
//       String authKey = prefs.getString(_cacheKeyAuthKey) ?? '';

//       final response = await https.get(
//         Uri.parse(
//             'https://dashboard.cpplayers.com/public/api/v2/getsportCategories'),
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'domain': 'coretechinfo.com',
//         },
//       ).timeout(
//         const Duration(seconds: 30),
//         onTimeout: () {
//           throw Exception('Request timeout');
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);

//         final allCategories = jsonData
//             .map((json) =>
//                 SportsCategoryModel.fromJson(json as Map<String, dynamic>))
//             .toList();

//         // Filter only active categories (status = 1)
//         final activeCategories =
//             allCategories.where((category) => category.status == 1).toList();

//         // Sort by sports_cat_order
//         activeCategories
//             .sort((a, b) => a.sportsCatOrder.compareTo(b.sportsCatOrder));

//         // Cache the fresh data (save all categories, but return only active ones)
//         await _cacheSportsCategories(prefs, jsonData);

//         print(
//             '✅ Successfully loaded ${activeCategories.length} active sports categories from API (from ${allCategories.length} total)');
//         return activeCategories;
//       } else {
//         throw Exception(
//             'API Error: ${response.statusCode} - ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('❌ Error fetching fresh sports categories: $e');
//       rethrow;
//     }
//   }

//   /// Cache sports categories data
//   static Future<void> _cacheSportsCategories(
//       SharedPreferences prefs, List<dynamic> categoriesData) async {
//     try {
//       final jsonString = json.encode(categoriesData);
//       final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

//       // Save categories data and timestamp
//       await Future.wait([
//         prefs.setString(_cacheKeySportsCategories, jsonString),
//         prefs.setString(_cacheKeyTimestamp, currentTimestamp),
//       ]);

//       print(
//           '💾 Successfully cached ${categoriesData.length} sports categories');
//     } catch (e) {
//       print('❌ Error caching sports categories: $e');
//     }
//   }

//   /// Load fresh data in background without blocking UI
//   static void _loadFreshDataInBackground() {
//     Future.delayed(const Duration(milliseconds: 500), () async {
//       try {
//         print('🔄 Loading fresh sports categories data in background...');
//         final prefs = await SharedPreferences.getInstance();
//         await _fetchFreshSportsCategories(prefs);
//         print('✅ Sports Categories background refresh completed');
//       } catch (e) {
//         print('⚠️ Sports Categories background refresh failed: $e');
//       }
//     });
//   }

//   /// Clear all cached data
//   static Future<void> clearCache() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await Future.wait([
//         prefs.remove(_cacheKeySportsCategories),
//         prefs.remove(_cacheKeyTimestamp),
//       ]);
//       print('🗑️ Sports Categories cache cleared successfully');
//     } catch (e) {
//       print('❌ Error clearing Sports Categories cache: $e');
//     }
//   }

//   /// Get cache info for debugging
//   static Future<Map<String, dynamic>> getCacheInfo() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final timestampStr = prefs.getString(_cacheKeyTimestamp);
//       final cachedData = prefs.getString(_cacheKeySportsCategories);

//       if (timestampStr == null || cachedData == null) {
//         return {
//           'hasCachedData': false,
//           'cacheAge': 0,
//           'cachedCategoriesCount': 0,
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
//         'cachedCategoriesCount': jsonData.length,
//         'cacheSize': cacheSizeKB,
//         'isValid': cacheAge < _cacheDurationMs,
//       };
//     } catch (e) {
//       print('❌ Error getting Sports Categories cache info: $e');
//       return {
//         'hasCachedData': false,
//         'cacheAge': 0,
//         'cachedCategoriesCount': 0,
//         'cacheSize': 0,
//         'error': e.toString(),
//       };
//     }
//   }

//   /// Force refresh data (bypass cache)
//   static Future<List<SportsCategoryModel>> forceRefresh() async {
//     print('🔄 Force refreshing Sports Categories data...');
//     return await getAllSportsCategories(forceRefresh: true);
//   }
// }

// // // 🚀 Enhanced SportsCategory with Caching
// // class SportsCategory extends StatefulWidget {
// //   @override
// //   _SportsCategoryState createState() =>
// //       _SportsCategoryState();
// // }

// // AFTER (Correct)
// class SportsCategory extends StatefulWidget {
//   const SportsCategory({super.key}); // <-- ADD THIS LINE

//   @override
//   _SportsCategoryState createState() => _SportsCategoryState();
// }

// class _SportsCategoryState extends State<SportsCategory>
//     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
//   @override
//   bool get wantKeepAlive => true;

//   List<SportsCategoryModel> categoriesList = [];
//   bool isLoading = true;
//   int focusedIndex = -1;
//   final int maxHorizontalItems = 7;
//   Color _currentAccentColor = ProfessionalColors.accentOrange;

//   // Animation Controllers
//   late AnimationController _headerAnimationController;
//   late AnimationController _listAnimationController;
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<double> _listFadeAnimation;

//   Map<String, FocusNode> categoriesFocusNodes = {};
//   FocusNode? _viewAllFocusNode;
//   FocusNode? _firstCategoryFocusNode;
//   bool _hasReceivedFocusFromTVShows = false;

//   late ScrollController _scrollController;
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _initializeAnimations();
//     _initializeFocusNodes();

//     // 🚀 Use enhanced caching service
//     fetchSportsCategoriesWithCache();
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
//     print('✅ Sports Categories focus nodes initialized');
//   }

//   // void _scrollToPosition(int index) {
//   //   if (index < categoriesList.length && index < maxHorizontalItems) {
//   //     String categoryId = categoriesList[index].id.toString();
//   //     if (categoriesFocusNodes.containsKey(categoryId)) {
//   //       final focusNode = categoriesFocusNodes[categoryId]!;

//   //       Scrollable.ensureVisible(
//   //         focusNode.context!,
//   //         duration: AnimationTiming.scroll,
//   //         curve: Curves.easeInOutCubic,
//   //         alignment: 0.03,
//   //         alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
//   //       );

//   //       print('🎯 Scrollable.ensureVisible for index $index: ${categoriesList[index].title}');
//   //     }
//   //   } else if (index == maxHorizontalItems && _viewAllFocusNode != null) {
//   //     Scrollable.ensureVisible(
//   //       _viewAllFocusNode!.context!,
//   //       duration: AnimationTiming.scroll,
//   //       curve: Curves.easeInOutCubic,
//   //       alignment: 0.2,
//   //       alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
//   //     );

//   //     print('🎯 Scrollable.ensureVisible for ViewAll button');
//   //   }
//   // }

//   // ✅ PASTE THIS NEW CODE
//   void _scrollToPosition(int index) {
//     if (!mounted || !_scrollController.hasClients) return;

//     try {
//       // This assumes 'bannerwdt' is available, just like in your TV show file.
//       // It's likely defined in your main.dart file.
//       double bannerwidth = bannerwdt;

//       if (index != -1) {
//         // Simple and direct scroll calculation
//         double scrollPosition = index * bannerwidth;

//         _scrollController.animateTo(
//           scrollPosition,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     } catch (e) {
//       // Silent fail is okay, but a print helps with debugging.
//       print('Error scrolling in sports category: $e');
//     }
//   }

//   void _setupCategoriesFocusProvider() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && categoriesList.isNotEmpty) {
//         try {
//           final focusProvider =
//               Provider.of<FocusProvider>(context, listen: false);

//           final firstCategoryId = categoriesList[0].id.toString();

//           if (!categoriesFocusNodes.containsKey(firstCategoryId)) {
//             categoriesFocusNodes[firstCategoryId] = FocusNode();
//             print(
//                 '✅ Created focus node for first sports category: $firstCategoryId');
//           }

//           _firstCategoryFocusNode = categoriesFocusNodes[firstCategoryId];

//           _firstCategoryFocusNode!.addListener(() {
//             if (_firstCategoryFocusNode!.hasFocus &&
//                 !_hasReceivedFocusFromTVShows) {
//               _hasReceivedFocusFromTVShows = true;
//               setState(() {
//                 focusedIndex = 0;
//               });
//               _scrollToPosition(0);
//               print(
//                   '✅ Sports Categories received focus from TV shows and scrolled');
//             }
//           });

//           focusProvider.registerFocusNode(
//               'sportsCategory', _firstCategoryFocusNode!);
//           print(
//               '✅ Sports Categories first focus node registered: ${categoriesList[0].title}');
//         } catch (e) {
//           print('❌ Sports Categories focus provider setup failed: $e');
//         }
//       }
//     });
//   }

//   // 🚀 Enhanced fetch method with caching
//   Future<void> fetchSportsCategoriesWithCache() async {
//     if (!mounted) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       // Use cached data first, then fresh data
//       final fetchedCategories =
//           await SportsCategoriesService.getAllSportsCategories();

//       if (fetchedCategories.isNotEmpty) {
//         if (mounted) {
//           setState(() {
//             categoriesList = fetchedCategories;
//             isLoading = false;
//           });

//           _createFocusNodesForItems();
//           _setupCategoriesFocusProvider();

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
//       print('Error fetching Sports Categories with cache: $e');
//     }
//   }

//   // 🆕 Debug method to show cache information
//   Future<void> _debugCacheInfo() async {
//     try {
//       final cacheInfo = await SportsCategoriesService.getCacheInfo();
//       print('📊 Sports Categories Cache Info: $cacheInfo');
//     } catch (e) {
//       print('❌ Error getting Sports Categories cache info: $e');
//     }
//   }

//   // 🆕 Force refresh sports categories
//   Future<void> _forceRefreshCategories() async {
//     if (!mounted) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       // Force refresh bypasses cache
//       final fetchedCategories = await SportsCategoriesService.forceRefresh();

//       if (fetchedCategories.isNotEmpty) {
//         if (mounted) {
//           setState(() {
//             categoriesList = fetchedCategories;
//             isLoading = false;
//           });

//           _createFocusNodesForItems();
//           _setupCategoriesFocusProvider();

//           _headerAnimationController.forward();
//           _listAnimationController.forward();

//           // Show success message
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text('Sports Categories refreshed successfully'),
//               backgroundColor: ProfessionalColors.accentOrange,
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
//       print('❌ Error force refreshing sports categories: $e');
//     }
//   }

//   void _createFocusNodesForItems() {
//     for (var node in categoriesFocusNodes.values) {
//       try {
//         node.removeListener(() {});
//         node.dispose();
//       } catch (e) {}
//     }
//     categoriesFocusNodes.clear();

//     for (int i = 0; i < categoriesList.length && i < maxHorizontalItems; i++) {
//       String categoryId = categoriesList[i].id.toString();
//       if (!categoriesFocusNodes.containsKey(categoryId)) {
//         categoriesFocusNodes[categoryId] = FocusNode();

//         categoriesFocusNodes[categoryId]!.addListener(() {
//           if (mounted && categoriesFocusNodes[categoryId]!.hasFocus) {
//             setState(() {
//               focusedIndex = i;
//               _hasReceivedFocusFromTVShows = true;
//             });
//             _scrollToPosition(i);
//             print(
//                 '✅ Sports Category $i focused and scrolled: ${categoriesList[i].title}');
//           }
//         });
//       }
//     }
//     print(
//         '✅ Created ${categoriesFocusNodes.length} sports category focus nodes with auto-scroll');
//   }

//   void _navigateToSportsCategoryDetails(SportsCategoryModel category) {
//     print('🏆 Navigating to Sports Category Details: ${category.title}');

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SportsCategorySecondPage(
//           // categoryId: category.id,
//           // categoryTitle: category.title,
//           tvChannelId: category.id,
//           channelName: category.title,
//           channelLogo: category.thumbnail,
//         ),
//       ),
//     ).then((_) {
//       print('🔙 Returned from Sports Category Details');
//       Future.delayed(Duration(milliseconds: 300), () {
//         if (mounted) {
//           int currentIndex =
//               categoriesList.indexWhere((cat) => cat.id == category.id);
//           if (currentIndex != -1 && currentIndex < maxHorizontalItems) {
//             String categoryId = category.id.toString();
//             if (categoriesFocusNodes.containsKey(categoryId)) {
//               setState(() {
//                 focusedIndex = currentIndex;
//                 _hasReceivedFocusFromTVShows = true;
//               });
//               categoriesFocusNodes[categoryId]!.requestFocus();
//               _scrollToPosition(currentIndex);
//               print('✅ Restored focus to ${category.title}');
//             }
//           }
//         }
//       });
//     });
//   }

//   void _navigateToGridPage() {
//     print('🏆 Navigating to Sports Categories Grid Page...');

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProfessionalSportsCategoriesGridPage(
//           categoriesList: categoriesList,
//           title: 'Sports Categories',
//         ),
//       ),
//     ).then((_) {
//       print('🔙 Returned from grid page');
//       Future.delayed(Duration(milliseconds: 300), () {
//         if (mounted && _viewAllFocusNode != null) {
//           setState(() {
//             focusedIndex = maxHorizontalItems;
//             _hasReceivedFocusFromTVShows = true;
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
//                   bgColor.withOpacity(0.8),
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

//   // ✅ ENHANCED: Sports Category item with color provider integration
//   Widget _buildSportsCategoryItem(SportsCategoryModel category, int index,
//       double screenWidth, double screenHeight) {
//     String categoryId = category.id.toString();

//     categoriesFocusNodes.putIfAbsent(
//       categoryId,
//       () => FocusNode()
//         ..addListener(() {
//           if (mounted && categoriesFocusNodes[categoryId]!.hasFocus) {
//             _scrollToPosition(index);
//           }
//         }),
//     );

//     return Focus(
//       focusNode: categoriesFocusNodes[categoryId],
//       onFocusChange: (hasFocus) async {
//         if (hasFocus && mounted) {
//           try {
//             Color dominantColor = ProfessionalColors.gradientColors[
//                 math.Random()
//                     .nextInt(ProfessionalColors.gradientColors.length)];

//             setState(() {
//               _currentAccentColor = dominantColor;
//               focusedIndex = index;
//               _hasReceivedFocusFromTVShows = true;
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
//       // onKey: (FocusNode node, RawKeyEvent event) {
//       //   if (event is RawKeyDownEvent) {
//       //     if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//       //       if (index < categoriesList.length - 1 && index != 6) {
//       //         String nextCategoryId = categoriesList[index + 1].id.toString();
//       //         FocusScope.of(context)
//       //             .requestFocus(categoriesFocusNodes[nextCategoryId]);
//       //         return KeyEventResult.handled;
//       //       } else if (index == 6 && categoriesList.length > 7) {
//       //         FocusScope.of(context).requestFocus(_viewAllFocusNode);
//       //         return KeyEventResult.handled;
//       //       }
//       //     } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//       //       if (index > 0) {
//       //         String prevCategoryId = categoriesList[index - 1].id.toString();
//       //         FocusScope.of(context)
//       //             .requestFocus(categoriesFocusNodes[prevCategoryId]);
//       //       }
//       //       return KeyEventResult.handled;
//       //     } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//       //       setState(() {
//       //         focusedIndex = -1;
//       //         _hasReceivedFocusFromTVShows = false;
//       //       });
//       //       // ✅ ADD: Reset color when navigating away
//       //       context.read<ColorProvider>().resetColor();
//       //       FocusScope.of(context).unfocus();
//       //       Future.delayed(const Duration(milliseconds: 100), () {
//       //         if (mounted) {
//       //           try {
//       //             Provider.of<FocusProvider>(context, listen: false)
//       //                 .requestFirstTVShowsFocus();
//       //             print('✅ Navigating back to TV shows from sports categories');
//       //           } catch (e) {
//       //             print('❌ Failed to navigate to TV shows: $e');
//       //           }
//       //         }
//       //       });
//       //       return KeyEventResult.handled;
//       //     } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//       //       setState(() {
//       //         focusedIndex = -1;
//       //         _hasReceivedFocusFromTVShows = false;
//       //       });
//       //       // ✅ ADD: Reset color when navigating away
//       //       context.read<ColorProvider>().resetColor();
//       //       FocusScope.of(context).unfocus();
//       //       Future.delayed(const Duration(milliseconds: 100), () {
//       //         if (mounted) {
//       //           try {
//       //             Provider.of<FocusProvider>(context, listen: false)
//       //                 .requestFirstReligiousChannelFocus();
//       //             // Navigate to next section
//       //             print('✅ Navigating down from sports categories');
//       //           } catch (e) {
//       //             print('❌ Failed to navigate down: $e');
//       //           }
//       //         }
//       //       });
//       //       return KeyEventResult.handled;
//       //     } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//       //         event.logicalKey == LogicalKeyboardKey.select) {
//       //       print(
//       //           '🏆 Enter pressed on ${category.title} - Opening Details Page...');
//       //       _navigateToSportsCategoryDetails(category);
//       //       return KeyEventResult.handled;
//       //     }
//       //   }
//       //   return KeyEventResult.ignored;
//       // },
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           final key = event.logicalKey;

//           // --- हॉरिजॉन्टल मूवमेंट (लेफ्ट/राइट) के लिए थ्रॉटलिंग ---
//           if (key == LogicalKeyboardKey.arrowRight ||
//               key == LogicalKeyboardKey.arrowLeft) {
//             // 1. अगर नेविगेशन लॉक्ड है, तो कुछ न करें
//             if (_isNavigationLocked) return KeyEventResult.handled;

//             // 2. नेविगेशन को लॉक करें और 300ms का टाइमर शुरू करें
//             setState(() => _isNavigationLocked = true);
//             _navigationLockTimer = Timer(const Duration(milliseconds: 300), () {
//               if (mounted) setState(() => _isNavigationLocked = false);
//             });

//             // 3. अब फोकस बदलें
//             if (key == LogicalKeyboardKey.arrowRight) {
//               // "View All" बटन सहित राइट नेविगेशन का लॉजिक
//               if (index < maxHorizontalItems - 1 &&
//                   index < categoriesList.length - 1) {
//                 String nextCategoryId = categoriesList[index + 1].id.toString();
//                 FocusScope.of(context)
//                     .requestFocus(categoriesFocusNodes[nextCategoryId]);
//               } else if (index == maxHorizontalItems - 1 &&
//                   categoriesList.length > maxHorizontalItems) {
//                 FocusScope.of(context).requestFocus(_viewAllFocusNode);
//               } else {
//                 _navigationLockTimer?.cancel();
//                 if (mounted) setState(() => _isNavigationLocked = false);
//               }
//             } else if (key == LogicalKeyboardKey.arrowLeft) {
//               if (index > 0) {
//                 String prevCategoryId = categoriesList[index - 1].id.toString();
//                 FocusScope.of(context)
//                     .requestFocus(categoriesFocusNodes[prevCategoryId]);
//               } else {
//                 _navigationLockTimer?.cancel();
//                 if (mounted) setState(() => _isNavigationLocked = false);
//               }
//             }
//             return KeyEventResult.handled;
//           }

//           // --- बाकी कीज़ (अप/डाउन/सेलेक्ट) को तुरंत हैंडल करें ---
//           if (key == LogicalKeyboardKey.arrowUp) {
//             setState(() {
//               focusedIndex = -1;
//               _hasReceivedFocusFromTVShows = false;
//             });
//             context.read<ColorProvider>().resetColor();
//             FocusScope.of(context).unfocus();
//             Future.delayed(const Duration(milliseconds: 100), () {
//               if (mounted) {
//                 try {
//                   Provider.of<FocusProvider>(context, listen: false)
//                       .requestFocus('tvShows');
//                 } catch (e) {
//                   print('❌ Failed to navigate to TV shows: $e');
//                 }
//               }
//             });
//             return KeyEventResult.handled;
//           } else if (key == LogicalKeyboardKey.arrowDown) {
//             setState(() {
//               focusedIndex = -1;
//               _hasReceivedFocusFromTVShows = false;
//             });
//             context.read<ColorProvider>().resetColor();
//             FocusScope.of(context).unfocus();
//             Future.delayed(const Duration(milliseconds: 100), () {
//               if (mounted) {
//                 try {
//                   Provider.of<FocusProvider>(context, listen: false)
//                       .requestFocus('religiousChannels');
//                 } catch (e) {
//                   print('❌ Failed to navigate down: $e');
//                 }
//               }
//             });
//             return KeyEventResult.handled;
//           } else if (key == LogicalKeyboardKey.enter ||
//               key == LogicalKeyboardKey.select) {
//             _navigateToSportsCategoryDetails(category);
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: () => _navigateToSportsCategoryDetails(category),
//         child: ProfessionalSportsCategoryCard(
//           category: category,
//           focusNode: categoriesFocusNodes[categoryId]!,
//           onTap: () => _navigateToSportsCategoryDetails(category),
//           onColorChange: (color) {
//             setState(() {
//               _currentAccentColor = color;
//             });
//             // ✅ ADD: Update color provider when card changes color
//             context.read<ColorProvider>().updateColor(color, true);
//           },
//           index: index,
//           categoryTitle: 'SPORTS',
//         ),
//       ),
//     );
//   }

//   // ✅ Enhanced ViewAll focus handling with ColorProvider
//   Widget _buildCategoriesList(double screenWidth, double screenHeight) {
//     bool showViewAll = categoriesList.length > 7;

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
//           itemCount: showViewAll ? 8 : categoriesList.length,
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

//                     // ✅ ADD: Update color provider for ViewAll button
//                     context
//                         .read<ColorProvider>()
//                         .updateColor(viewAllColor, true);
//                   } else if (mounted) {
//                     // ✅ ADD: Reset color when ViewAll loses focus
//                     context.read<ColorProvider>().resetColor();
//                   }
//                 },
//                 onKey: (FocusNode node, RawKeyEvent event) {
//                   if (event is RawKeyDownEvent) {
//                     if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey ==
//                         LogicalKeyboardKey.arrowLeft) {
//                       if (categoriesList.isNotEmpty &&
//                           categoriesList.length > 6) {
//                         String categoryId = categoriesList[6].id.toString();
//                         FocusScope.of(context)
//                             .requestFocus(categoriesFocusNodes[categoryId]);
//                         return KeyEventResult.handled;
//                       }
//                     } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                       setState(() {
//                         focusedIndex = -1;
//                         _hasReceivedFocusFromTVShows = false;
//                       });
//                       // ✅ ADD: Reset color when navigating away from ViewAll
//                       context.read<ColorProvider>().resetColor();
//                       FocusScope.of(context).unfocus();
//                       Future.delayed(const Duration(milliseconds: 100), () {
//                         if (mounted) {
//                           try {
//                             Provider.of<FocusProvider>(context, listen: false)
//                                 .requestFocus('tvShows');
//                             print(
//                                 '✅ Navigating back to TV shows from Sports Categories ViewAll');
//                           } catch (e) {
//                             print('❌ Failed to navigate to TV shows: $e');
//                           }
//                         }
//                       });
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey ==
//                         LogicalKeyboardKey.arrowDown) {
//                       setState(() {
//                         focusedIndex = -1;
//                         _hasReceivedFocusFromTVShows = false;
//                       });
//                       // ✅ ADD: Reset color when navigating away from ViewAll
//                       context.read<ColorProvider>().resetColor();
//                       FocusScope.of(context).unfocus();
//                       Future.delayed(const Duration(milliseconds: 100), () {
//                         if (mounted) {
//                           try {
//                             Provider.of<FocusProvider>(context, listen: false)
//                                 .requestFocus('religiousChannels');
//                             // Navigate to next section after Sports Categories
//                             print(
//                                 '✅ Navigating down from Sports Categories ViewAll');
//                           } catch (e) {
//                             print('❌ Failed to navigate down: $e');
//                           }
//                         }
//                       });
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//                         event.logicalKey == LogicalKeyboardKey.select) {
//                       print('🏆 ViewAll button pressed - Opening Grid Page...');
//                       _navigateToGridPage();
//                       return KeyEventResult.handled;
//                     }
//                   }
//                   return KeyEventResult.ignored;
//                 },
//                 child: GestureDetector(
//                   onTap: _navigateToGridPage,
//                   child: ProfessionalSportsCategoryViewAllButton(
//                     focusNode: _viewAllFocusNode!,
//                     onTap: _navigateToGridPage,
//                     totalItems: categoriesList.length,
//                     itemType: 'SPORTS',
//                   ),
//                 ),
//               );
//             }

//             var category = categoriesList[index];
//             return _buildSportsCategoryItem(
//                 category, index, screenWidth, screenHeight);
//           },
//         ),
//       ),
//     );
//   }

//   // 🚀 Enhanced Title with Cache Status and Count
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
//                   ProfessionalColors.accentOrange,
//                   ProfessionalColors.accentRed,
//                 ],
//               ).createShader(bounds),
//               child: Text(
//                 'SPORTS',
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 2.0,
//                 ),
//               ),
//             ),
//             // Row(
//             //   children: [
//             //     // Sports Categories Count
//             //     if (categoriesList.length > 0)
//             //       Container(
//             //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             //         decoration: BoxDecoration(
//             //           gradient: LinearGradient(
//             //             colors: [
//             //               ProfessionalColors.accentOrange.withOpacity(0.2),
//             //               ProfessionalColors.accentRed.withOpacity(0.2),
//             //             ],
//             //           ),
//             //           borderRadius: BorderRadius.circular(20),
//             //           border: Border.all(
//             //             color: ProfessionalColors.accentOrange.withOpacity(0.3),
//             //             width: 1,
//             //           ),
//             //         ),
//             //         child: Text(
//             //           '${categoriesList.length} Categories Available',
//             //           style: const TextStyle(
//             //             color: ProfessionalColors.textSecondary,
//             //             fontSize: 12,
//             //             fontWeight: FontWeight.w500,
//             //           ),
//             //         ),
//             //       ),
//             //   ],
//             // ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBody(double screenWidth, double screenHeight) {
//     if (isLoading) {
//       return ProfessionalSportsCategoryLoadingIndicator(
//           message: 'Loading Sports Categories...');
//     } else if (categoriesList.isEmpty) {
//       return _buildEmptyWidget();
//     } else {
//       return _buildCategoriesList(screenWidth, screenHeight);
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
//                   ProfessionalColors.accentOrange.withOpacity(0.2),
//                   ProfessionalColors.accentOrange.withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.sports_outlined,
//               size: 40,
//               color: ProfessionalColors.accentOrange,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'No Sports Categories Found',
//             style: TextStyle(
//               color: ProfessionalColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Check back later for new categories',
//             style: TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

// //   @override
// //   void dispose() {
// //     _navigationLockTimer?.cancel();
// //     _headerAnimationController.dispose();
// //     _listAnimationController.dispose();

// //     for (var entry in categoriesFocusNodes.entries) {
// //       try {
// //         entry.value.removeListener(() {});
// //         entry.value.dispose();
// //       } catch (e) {}
// //     }
// //     categoriesFocusNodes.clear();

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

//   @override
//   void dispose() {
//     _navigationLockTimer?.cancel();
//     _headerAnimationController.dispose();
//     _listAnimationController.dispose();

//     // ❗️ BADLAV YAHAN: Sirf un nodes ko dispose karein jo provider mein register NAHI hue
//     String? firstCategoryId;
//     if (categoriesList.isNotEmpty) {
//       firstCategoryId = categoriesList[0].id.toString();
//     }

//     for (var entry in categoriesFocusNodes.entries) {
//       // Agar node register nahi hua hai (yaani first category nahi hai), tabhi use yahan dispose karein
//       if (entry.key != firstCategoryId) {
//         try {
//           entry.value.removeListener(() {});
//           entry.value.dispose();
//         } catch (e) {}
//       }
//     }
//     categoriesFocusNodes.clear();

//     try {
//       // ViewAll node provider mein register nahi hota, isliye use dispose karna theek hai
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
// class SportsCacheManager {
//   /// Clear all sports caches
//   static Future<void> clearAllCaches() async {
//     try {
//       await Future.wait([
//         SportsCategoriesService.clearCache(),
//         // Add other sports service cache clears here
//         // SportsEventsService.clearCache(),
//         // SportsTeamsService.clearCache(),
//       ]);
//       print('🗑️ All sports caches cleared successfully');
//     } catch (e) {
//       print('❌ Error clearing all sports caches: $e');
//     }
//   }

//   /// Get comprehensive cache info for all sports services
//   static Future<Map<String, dynamic>> getAllCacheInfo() async {
//     try {
//       final categoriesCacheInfo = await SportsCategoriesService.getCacheInfo();
//       // Add other service cache info here
//       // final eventsCacheInfo = await SportsEventsService.getCacheInfo();
//       // final teamsCacheInfo = await SportsTeamsService.getCacheInfo();

//       return {
//         'sportsCategories': categoriesCacheInfo,
//         // 'sportsEvents': eventsCacheInfo,
//         // 'sportsTeams': teamsCacheInfo,
//         'totalCacheSize': _calculateTotalCacheSize([
//           categoriesCacheInfo,
//           // eventsCacheInfo,
//           // teamsCacheInfo,
//         ]),
//       };
//     } catch (e) {
//       print('❌ Error getting all sports cache info: $e');
//       return {
//         'error': e.toString(),
//         'sportsCategories': {'hasCachedData': false},
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

//   /// Force refresh all sports data
//   static Future<void> forceRefreshAllData() async {
//     try {
//       await Future.wait([
//         SportsCategoriesService.forceRefresh(),
//         // Add other service force refreshes here
//         // SportsEventsService.forceRefresh(),
//         // SportsTeamsService.forceRefresh(),
//       ]);
//       print('🔄 All sports data force refreshed successfully');
//     } catch (e) {
//       print('❌ Error force refreshing all sports data: $e');
//     }
//   }
// }

// // ✅ Professional Sports Category Card
// class ProfessionalSportsCategoryCard extends StatefulWidget {
//   final SportsCategoryModel category;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final Function(Color) onColorChange;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalSportsCategoryCard({
//     Key? key,
//     required this.category,
//     required this.focusNode,
//     required this.onTap,
//     required this.onColorChange,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalSportsCategoryCardState createState() =>
//       _ProfessionalSportsCategoryCardState();
// }

// class _ProfessionalSportsCategoryCardState
//     extends State<ProfessionalSportsCategoryCard>
//     with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _glowController;
//   late AnimationController _shimmerController;

//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;
//   late Animation<double> _shimmerAnimation;

//   Color _dominantColor = ProfessionalColors.accentOrange;
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
//             _buildSportsCategoryImage(screenWidth, posterHeight),
//             if (_isFocused) _buildFocusBorder(),
//             if (_isFocused) _buildShimmerEffect(),
//             _buildCategoryBadge(),
//             if (_isFocused) _buildHoverOverlay(),
//           ],
//         ),
//       ),
//     );
//   }

//   // 👈 THIS METHOD IS UPDATED TO SHOW IMAGES
//   Widget _buildSportsCategoryImage(double screenWidth, double posterHeight) {
//     // Check if the thumbnail URL is valid and not empty
//     if (widget.category.thumbnail != null &&
//         widget.category.thumbnail!.isNotEmpty) {
//       return Image.network(
//         widget.category.thumbnail!,
//         width: double.infinity,
//         height: posterHeight,
//         fit: BoxFit.cover,
//         // Optional: Show a loading animation
//         loadingBuilder: (BuildContext context, Widget child,
//             ImageChunkEvent? loadingProgress) {
//           if (loadingProgress == null) return child;
//           return Center(
//             child: CircularProgressIndicator(
//               value: loadingProgress.expectedTotalBytes != null
//                   ? loadingProgress.cumulativeBytesLoaded /
//                       loadingProgress.expectedTotalBytes!
//                   : null,
//               strokeWidth: 2,
//               color: _dominantColor,
//             ),
//           );
//         },
//         // Optional: Show a placeholder if the image fails to load
//         errorBuilder:
//             (BuildContext context, Object exception, StackTrace? stackTrace) {
//           print('❌ Error loading image: ${widget.category.thumbnail}');
//           // Fallback to the original placeholder icon on error
//           return _buildImagePlaceholder(posterHeight);
//         },
//       );
//     } else {
//       // If no thumbnail URL is provided, show the original placeholder
//       return _buildImagePlaceholder(posterHeight);
//     }
//   }

//   Widget _buildImagePlaceholder(double height) {
//     IconData sportIcon = _getSportIcon(widget.category.title);
//     Color sportColor = _getSportColor(widget.category.title);

//     return Container(
//       height: height,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             sportColor.withOpacity(0.2),
//             ProfessionalColors.cardDark,
//             ProfessionalColors.surfaceDark,
//           ],
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             sportIcon,
//             size: height * 0.25,
//             color: sportColor,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             widget.category.title.toUpperCase(),
//             style: TextStyle(
//               color: sportColor,
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 4),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//             decoration: BoxDecoration(
//               color: sportColor.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Text(
//               'CATEGORY',
//               style: TextStyle(
//                 color: sportColor,
//                 fontSize: 8,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   IconData _getSportIcon(String categoryTitle) {
//     switch (categoryTitle.toLowerCase()) {
//       case 'cricket':
//         return Icons.sports_cricket;
//       case 'football':
//         return Icons.sports_soccer;
//       case 'basketball':
//         return Icons.sports_basketball;
//       case 'tennis':
//         return Icons.sports_tennis;
//       case 'baseball':
//         return Icons.sports_baseball;
//       case 'golf':
//         return Icons.sports_golf;
//       case 'volleyball':
//         return Icons.sports_volleyball;
//       case 'hockey':
//         return Icons.sports_hockey;
//       default:
//         return Icons.sports;
//     }
//   }

//   Color _getSportColor(String categoryTitle) {
//     switch (categoryTitle.toLowerCase()) {
//       case 'cricket':
//         return ProfessionalColors.accentGreen;
//       case 'football':
//         return ProfessionalColors.accentOrange;
//       case 'basketball':
//         return ProfessionalColors.accentRed;
//       case 'tennis':
//         return ProfessionalColors.accentBlue;
//       case 'baseball':
//         return ProfessionalColors.accentPurple;
//       case 'golf':
//         return ProfessionalColors.accentGreen;
//       case 'volleyball':
//         return ProfessionalColors.accentPink;
//       case 'hockey':
//         return ProfessionalColors.accentBlue;
//       default:
//         return ProfessionalColors.accentOrange;
//     }
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

//   Widget _buildCategoryBadge() {
//     return Positioned(
//       top: 8,
//       right: 8,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//         decoration: BoxDecoration(
//           color: ProfessionalColors.accentOrange.withOpacity(0.9),
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Text(
//           'SPORTS',
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
//     final categoryName = widget.category.title.toUpperCase();

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
//           categoryName,
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }

// // ✅ Professional View All Button for Sports
// class ProfessionalSportsCategoryViewAllButton extends StatefulWidget {
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int totalItems;
//   final String itemType;

//   const ProfessionalSportsCategoryViewAllButton({
//     Key? key,
//     required this.focusNode,
//     required this.onTap,
//     required this.totalItems,
//     this.itemType = 'SPORTS',
//   }) : super(key: key);

//   @override
//   _ProfessionalSportsCategoryViewAllButtonState createState() =>
//       _ProfessionalSportsCategoryViewAllButtonState();
// }

// class _ProfessionalSportsCategoryViewAllButtonState
//     extends State<ProfessionalSportsCategoryViewAllButton>
//     with TickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late AnimationController _rotateController;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _rotateAnimation;

//   bool _isFocused = false;
//   Color _currentColor = ProfessionalColors.accentOrange;

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
//                   Icons.sports_rounded,
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

// // ✅ Professional Loading Indicator
// class ProfessionalSportsCategoryLoadingIndicator extends StatefulWidget {
//   final String message;

//   const ProfessionalSportsCategoryLoadingIndicator({
//     Key? key,
//     this.message = 'Loading Sports Categories...',
//   }) : super(key: key);

//   @override
//   _ProfessionalSportsCategoryLoadingIndicatorState createState() =>
//       _ProfessionalSportsCategoryLoadingIndicatorState();
// }

// class _ProfessionalSportsCategoryLoadingIndicatorState
//     extends State<ProfessionalSportsCategoryLoadingIndicator>
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
//                       ProfessionalColors.accentOrange,
//                       ProfessionalColors.accentRed,
//                       ProfessionalColors.accentBlue,
//                       ProfessionalColors.accentOrange,
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
//                     Icons.sports_rounded,
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
//                     ProfessionalColors.accentOrange,
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

// // ✅ Professional Sports Categories Grid Page
// class ProfessionalSportsCategoriesGridPage extends StatefulWidget {
//   final List<SportsCategoryModel> categoriesList;
//   final String title;

//   const ProfessionalSportsCategoriesGridPage({
//     Key? key,
//     required this.categoriesList,
//     this.title = 'All Sports Categories',
//   }) : super(key: key);

//   @override
//   _ProfessionalSportsCategoriesGridPageState createState() =>
//       _ProfessionalSportsCategoriesGridPageState();
// }

// class _ProfessionalSportsCategoriesGridPageState
//     extends State<ProfessionalSportsCategoriesGridPage>
//     with TickerProviderStateMixin {
//   int gridFocusedIndex = 0;
//   final int columnsCount = 5;
//   Map<int, FocusNode> gridFocusNodes = {};
//   late ScrollController _scrollController;

//   // Animation Controllers
//   late AnimationController _fadeController;
//   late AnimationController _staggerController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _createGridFocusNodes();
//     _initializeAnimations();
//     _startStaggeredAnimation();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusFirstGridItem();
//     });
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

//   void _createGridFocusNodes() {
//     for (int i = 0; i < widget.categoriesList.length; i++) {
//       gridFocusNodes[i] = FocusNode();
//       gridFocusNodes[i]!.addListener(() {
//         if (gridFocusNodes[i]!.hasFocus) {
//           _ensureItemVisible(i);
//         }
//       });
//     }
//   }

//   void _focusFirstGridItem() {
//     if (gridFocusNodes.containsKey(0)) {
//       setState(() {
//         gridFocusedIndex = 0;
//       });
//       gridFocusNodes[0]!.requestFocus();
//     }
//   }

//   void _ensureItemVisible(int index) {
//     if (_scrollController.hasClients) {
//       final int row = index ~/ columnsCount;
//       final double itemHeight = 200.0;
//       final double targetOffset = row * itemHeight;

//       _scrollController.animateTo(
//         targetOffset,
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   void _navigateGrid(LogicalKeyboardKey key) {
//     int newIndex = gridFocusedIndex;
//     final int totalItems = widget.categoriesList.length;
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
//         }
//         break;

//       case LogicalKeyboardKey.arrowUp:
//         if (currentRow > 0) {
//           final int prevRowIndex = (currentRow - 1) * columnsCount + currentCol;
//           newIndex = prevRowIndex;
//         }
//         break;
//     }

//     if (newIndex != gridFocusedIndex &&
//         newIndex >= 0 &&
//         newIndex < totalItems) {
//       setState(() {
//         gridFocusedIndex = newIndex;
//       });
//       gridFocusNodes[newIndex]!.requestFocus();
//     }
//   }

//   void _navigateToSportsCategoryDetails(
//       SportsCategoryModel category, int index) {
//     print('🏆 Grid: Navigating to Sports Category Details: ${category.title}');

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SportsCategorySecondPage(
//           tvChannelId: category.id,
//           channelName: category.title,
//           channelLogo: category.thumbnail,
//         ),
//       ),
//     ).then((_) {
//       print('🔙 Returned from Sports Category Details to Grid');
//       Future.delayed(Duration(milliseconds: 300), () {
//         if (mounted && gridFocusNodes.containsKey(index)) {
//           setState(() {
//             gridFocusedIndex = index;
//           });
//           gridFocusNodes[index]!.requestFocus();
//           print('✅ Restored grid focus to index $index');
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Stack(
//         children: [
//           // Background Gradient
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   ProfessionalColors.primaryDark,
//                   ProfessionalColors.surfaceDark.withOpacity(0.8),
//                   ProfessionalColors.primaryDark,
//                 ],
//               ),
//             ),
//           ),

//           // Main Content
//           FadeTransition(
//             opacity: _fadeAnimation,
//             child: Column(
//               children: [
//                 _buildProfessionalAppBar(),
//                 Expanded(
//                   child: _buildGridView(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfessionalAppBar() {
//     return Container(
//       padding: EdgeInsets.only(
//         top: MediaQuery.of(context).padding.top + 10,
//         left: 20,
//         right: 20,
//         bottom: 20,
//       ),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             ProfessionalColors.surfaceDark.withOpacity(0.9),
//             ProfessionalColors.surfaceDark.withOpacity(0.7),
//             Colors.transparent,
//           ],
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [
//                   ProfessionalColors.accentOrange.withOpacity(0.2),
//                   ProfessionalColors.accentRed.withOpacity(0.2),
//                 ],
//               ),
//             ),
//             child: IconButton(
//               icon: const Icon(
//                 Icons.arrow_back_rounded,
//                 color: Colors.white,
//                 size: 24,
//               ),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ShaderMask(
//                   shaderCallback: (bounds) => const LinearGradient(
//                     colors: [
//                       ProfessionalColors.accentOrange,
//                       ProfessionalColors.accentRed,
//                     ],
//                   ).createShader(bounds),
//                   child: Text(
//                     widget.title,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 1.0,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 // Container(
//                 //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                 //   decoration: BoxDecoration(
//                 //     gradient: LinearGradient(
//                 //       colors: [
//                 //         ProfessionalColors.accentOrange.withOpacity(0.2),
//                 //         ProfessionalColors.accentRed.withOpacity(0.1),
//                 //       ],
//                 //     ),
//                 //     borderRadius: BorderRadius.circular(15),
//                 //     border: Border.all(
//                 //       color: ProfessionalColors.accentOrange.withOpacity(0.3),
//                 //       width: 1,
//                 //     ),
//                 //   ),
//                 //   child: Text(
//                 //     '${widget.categoriesList.length} Categories Available',
//                 //     style: const TextStyle(
//                 //       color: ProfessionalColors.accentOrange,
//                 //       fontSize: 12,
//                 //       fontWeight: FontWeight.w500,
//                 //     ),
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGridView() {
//     if (widget.categoriesList.isEmpty) {
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
//                     ProfessionalColors.accentOrange.withOpacity(0.2),
//                     ProfessionalColors.accentOrange.withOpacity(0.1),
//                   ],
//                 ),
//               ),
//               child: const Icon(
//                 Icons.sports_outlined,
//                 size: 40,
//                 color: ProfessionalColors.accentOrange,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'No ${widget.title} Found',
//               style: TextStyle(
//                 color: ProfessionalColors.textPrimary,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Check back later for new categories',
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
//         if (event is RawKeyDownEvent) {
//           if ([
//             LogicalKeyboardKey.arrowUp,
//             LogicalKeyboardKey.arrowDown,
//             LogicalKeyboardKey.arrowLeft,
//             LogicalKeyboardKey.arrowRight,
//           ].contains(event.logicalKey)) {
//             _navigateGrid(event.logicalKey);
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//               event.logicalKey == LogicalKeyboardKey.select) {
//             if (gridFocusedIndex < widget.categoriesList.length) {
//               _navigateToSportsCategoryDetails(
//                 widget.categoriesList[gridFocusedIndex],
//                 gridFocusedIndex,
//               );
//             }
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: Padding(
//         padding: EdgeInsets.all(20),
//         child: GridView.builder(
//           controller: _scrollController,
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 6,
//             crossAxisSpacing: 15,
//             mainAxisSpacing: 15,
//             childAspectRatio: 1.5,
//           ),
//           itemCount: widget.categoriesList.length,
//           itemBuilder: (context, index) {
//             return AnimatedBuilder(
//               animation: _staggerController,
//               builder: (context, child) {
//                 final delay = (index / widget.categoriesList.length) * 0.5;
//                 final animationValue = Interval(
//                   delay,
//                   delay + 0.5,
//                   curve: Curves.easeOutCubic,
//                 ).transform(_staggerController.value);

//                 return Transform.translate(
//                   offset: Offset(0, 50 * (1 - animationValue)),
//                   child: Opacity(
//                     opacity: animationValue,
//                     child: ProfessionalGridSportsCategoryCard(
//                       category: widget.categoriesList[index],
//                       focusNode: gridFocusNodes[index]!,
//                       onTap: () => _navigateToSportsCategoryDetails(
//                           widget.categoriesList[index], index),
//                       index: index,
//                       categoryTitle: widget.title,
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

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _staggerController.dispose();
//     _scrollController.dispose();
//     for (var node in gridFocusNodes.values) {
//       try {
//         node.dispose();
//       } catch (e) {}
//     }
//     super.dispose();
//   }
// }

// // ✅ Professional Grid Sports Category Card
// class ProfessionalGridSportsCategoryCard extends StatefulWidget {
//   final SportsCategoryModel category;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalGridSportsCategoryCard({
//     Key? key,
//     required this.category,
//     required this.focusNode,
//     required this.onTap,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalGridSportsCategoryCardState createState() =>
//       _ProfessionalGridSportsCategoryCardState();
// }

// class _ProfessionalGridSportsCategoryCardState
//     extends State<ProfessionalGridSportsCategoryCard>
//     with TickerProviderStateMixin {
//   late AnimationController _hoverController;
//   late AnimationController _glowController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;

//   Color _dominantColor = ProfessionalColors.accentOrange;
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
//                       _buildCategoryImage(),
//                       if (_isFocused) _buildFocusBorder(),
//                       _buildGradientOverlay(),
//                       _buildCategoryInfo(),
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

//   // 👈 THIS METHOD IS UPDATED TO SHOW IMAGES
//   Widget _buildCategoryImage() {
//     // Define the original placeholder as a fallback
//     IconData sportIcon = _getSportIcon(widget.category.title);
//     Color sportColor = _getSportColor(widget.category.title);
//     Widget placeholder = Container(
//       width: double.infinity,
//       height: double.infinity,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             sportColor.withOpacity(0.2),
//             ProfessionalColors.cardDark,
//             ProfessionalColors.surfaceDark,
//           ],
//         ),
//       ),
//       child: Center(child: Icon(sportIcon, size: 60, color: sportColor)),
//     );

//     // Check if the thumbnail URL is valid
//     if (widget.category.thumbnail != null &&
//         widget.category.thumbnail!.isNotEmpty) {
//       return Image.network(
//         widget.category.thumbnail!,
//         width: double.infinity,
//         height: double.infinity,
//         fit: BoxFit.cover,
//         // Optional: Show a loading animation
//         loadingBuilder: (BuildContext context, Widget child,
//             ImageChunkEvent? loadingProgress) {
//           if (loadingProgress == null) return child;
//           return Center(
//             child: CircularProgressIndicator(
//               value: loadingProgress.expectedTotalBytes != null
//                   ? loadingProgress.cumulativeBytesLoaded /
//                       loadingProgress.expectedTotalBytes!
//                   : null,
//               strokeWidth: 2,
//               color: _dominantColor,
//             ),
//           );
//         },
//         // Optional: Show the placeholder if the image fails to load
//         errorBuilder:
//             (BuildContext context, Object exception, StackTrace? stackTrace) {
//           print('❌ Error loading grid image: ${widget.category.thumbnail}');
//           return placeholder;
//         },
//       );
//     } else {
//       // If no thumbnail URL is provided, show the placeholder
//       return placeholder;
//     }
//   }

//   IconData _getSportIcon(String categoryTitle) {
//     switch (categoryTitle.toLowerCase()) {
//       case 'cricket':
//         return Icons.sports_cricket;
//       case 'football':
//         return Icons.sports_soccer;
//       case 'basketball':
//         return Icons.sports_basketball;
//       case 'tennis':
//         return Icons.sports_tennis;
//       case 'baseball':
//         return Icons.sports_baseball;
//       case 'golf':
//         return Icons.sports_golf;
//       case 'volleyball':
//         return Icons.sports_volleyball;
//       case 'hockey':
//         return Icons.sports_hockey;
//       default:
//         return Icons.sports;
//     }
//   }

//   Color _getSportColor(String categoryTitle) {
//     switch (categoryTitle.toLowerCase()) {
//       case 'cricket':
//         return ProfessionalColors.accentGreen;
//       case 'football':
//         return ProfessionalColors.accentOrange;
//       case 'basketball':
//         return ProfessionalColors.accentRed;
//       case 'tennis':
//         return ProfessionalColors.accentBlue;
//       case 'baseball':
//         return ProfessionalColors.accentPurple;
//       case 'golf':
//         return ProfessionalColors.accentGreen;
//       case 'volleyball':
//         return ProfessionalColors.accentPink;
//       case 'hockey':
//         return ProfessionalColors.accentBlue;
//       default:
//         return ProfessionalColors.accentOrange;
//     }
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

//   Widget _buildCategoryInfo() {
//     final categoryName = widget.category.title;

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
//               categoryName.toUpperCase(),
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
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: _dominantColor.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: _dominantColor.withOpacity(0.4),
//                     width: 1,
//                   ),
//                 ),
//                 child: Text(
//                   'SPORTS CATEGORY',
//                   style: TextStyle(
//                     color: _dominantColor,
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

// // ✅ Placeholder for Sports Category Details Page
// class SportsCategoryDetailsPage extends StatelessWidget {
//   final int categoryId;
//   final String categoryTitle;

//   const SportsCategoryDetailsPage({
//     Key? key,
//     required this.categoryId,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       appBar: AppBar(
//         backgroundColor: ProfessionalColors.surfaceDark,
//         title: Text(
//           categoryTitle,
//           style: const TextStyle(color: Colors.white),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.sports_rounded,
//               size: 80,
//               color: ProfessionalColors.accentOrange,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Sports Category Details',
//               style: const TextStyle(
//                 color: ProfessionalColors.textPrimary,
//                 fontSize: 24,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               categoryTitle,
//               style: const TextStyle(
//                 color: ProfessionalColors.accentOrange,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Category ID: $categoryId',
//               style: const TextStyle(
//                 color: ProfessionalColors.textSecondary,
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 40),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     ProfessionalColors.accentOrange.withOpacity(0.2),
//                     ProfessionalColors.accentRed.withOpacity(0.2),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: ProfessionalColors.accentOrange.withOpacity(0.3),
//                   width: 1,
//                 ),
//               ),
//               child: const Text(
//                 'Sports content will be loaded here',
//                 style: TextStyle(
//                   color: ProfessionalColors.textSecondary,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }






// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sports_category/sports_category_second_page.dart';
// import 'dart:math' as math;
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
// import 'package:provider/provider.dart';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:ui';

// // ✅ Professional Color Palette (same as WebSeries)
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

// // ✅ Sports Category Model (UPDATED with thumbnail)
// class SportsCategoryModel {
//   final int id;
//   final int sportsCatOrder;
//   final String title;
//   final int status;
//   final String? createdAt;
//   final String? updatedAt;
//   final String? deletedAt;
//   final String? thumbnail; // 👈 UPDATED

//   SportsCategoryModel({
//     required this.id,
//     required this.sportsCatOrder,
//     required this.title,
//     required this.status,
//     this.createdAt,
//     this.updatedAt,
//     this.deletedAt,
//     this.thumbnail, // 👈 UPDATED
//   });

//   factory SportsCategoryModel.fromJson(Map<String, dynamic> json) {
//     return SportsCategoryModel(
//       id: json['id'] ?? 0,
//       sportsCatOrder: json['sports_cat_order'] ?? 0,
//       title: json['title'] ?? '',
//       status: json['status'] ?? 0,
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//       deletedAt: json['deleted_at'],
//       thumbnail: json['thumbnail'], // 👈 UPDATED
//     );
//   }
// }

// // 🚀 Enhanced Sports Categories Service with Caching
// class SportsCategoriesService {
//   // Cache keys
//   static const String _cacheKeySportsCategories = 'cached_sports_categories';
//   static const String _cacheKeyTimestamp = 'cached_sports_categories_timestamp';
//   static const String _cacheKeyAuthKey = 'result_auth_key';

//   // Cache duration (in milliseconds) - 1 hour
//   static const int _cacheDurationMs = 60 * 60 * 1000; // 1 hour

//   /// Main method to get all sports categories with caching
//   static Future<List<SportsCategoryModel>> getAllSportsCategories(
//       {bool forceRefresh = false}) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       // Check if we should use cache
//       if (!forceRefresh && await _shouldUseCache(prefs)) {
//         print('📦 Loading Sports Categories from cache...');
//         final cachedCategories = await _getCachedSportsCategories(prefs);
//         if (cachedCategories.isNotEmpty) {
//           print(
//               '✅ Successfully loaded ${cachedCategories.length} sports categories from cache');

//           // Load fresh data in background (without waiting)
//           _loadFreshDataInBackground();

//           return cachedCategories;
//         }
//       }

//       // Load fresh data if no cache or force refresh
//       print('🌐 Loading fresh Sports Categories from API...');
//       return await _fetchFreshSportsCategories(prefs);
//     } catch (e) {
//       print('❌ Error in getAllSportsCategories: $e');

//       // Try to return cached data as fallback
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         final cachedCategories = await _getCachedSportsCategories(prefs);
//         if (cachedCategories.isNotEmpty) {
//           print('🔄 Returning cached data as fallback');
//           return cachedCategories;
//         }
//       } catch (cacheError) {
//         print('❌ Cache fallback also failed: $cacheError');
//       }

//       throw Exception('Failed to load sports categories: $e');
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
//         print(
//             '📦 Sports Categories Cache is valid (${ageMinutes} minutes old)');
//       } else {
//         final ageMinutes = (cacheAge / (1000 * 60)).round();
//         print('⏰ Sports Categories Cache expired (${ageMinutes} minutes old)');
//       }

//       return isValid;
//     } catch (e) {
//       print('❌ Error checking Sports Categories cache validity: $e');
//       return false;
//     }
//   }

//   /// Get sports categories from cache
//   static Future<List<SportsCategoryModel>> _getCachedSportsCategories(
//       SharedPreferences prefs) async {
//     try {
//       final cachedData = prefs.getString(_cacheKeySportsCategories);
//       if (cachedData == null || cachedData.isEmpty) {
//         print('📦 No cached Sports Categories data found');
//         return [];
//       }

//       final List<dynamic> jsonData = json.decode(cachedData);
//       final categories = jsonData
//           .map((json) =>
//               SportsCategoryModel.fromJson(json as Map<String, dynamic>))
//           .where((category) => category.status == 1) // Filter active categories
//           .toList();

//       // Sort by sports_cat_order
//       categories.sort((a, b) => a.sportsCatOrder.compareTo(b.sportsCatOrder));

//       print(
//           '📦 Successfully loaded ${categories.length} sports categories from cache');
//       return categories;
//     } catch (e) {
//       print('❌ Error loading cached sports categories: $e');
//       return [];
//     }
//   }

//   /// Fetch fresh sports categories from API and cache them
//   static Future<List<SportsCategoryModel>> _fetchFreshSportsCategories(
//       SharedPreferences prefs) async {
//     try {
//       String authKey = SessionManager.authKey ;
//       var url = Uri.parse(SessionManager.baseUrl + 'getsportCategories');

//       final response = await https.get(url,
//         // Uri.parse(
//         //     'https://dashboard.cpplayers.com/public/api/v2/getsportCategories'),
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'domain': SessionManager.savedDomain,
//         },
//       ).timeout(
//         const Duration(seconds: 30),
//         onTimeout: () {
//           throw Exception('Request timeout');
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);

//         final allCategories = jsonData
//             .map((json) =>
//                 SportsCategoryModel.fromJson(json as Map<String, dynamic>))
//             .toList();

//         // Filter only active categories (status = 1)
//         final activeCategories =
//             allCategories.where((category) => category.status == 1).toList();

//         // Sort by sports_cat_order
//         activeCategories
//             .sort((a, b) => a.sportsCatOrder.compareTo(b.sportsCatOrder));

//         // Cache the fresh data (save all categories, but return only active ones)
//         await _cacheSportsCategories(prefs, jsonData);

//         print(
//             '✅ Successfully loaded ${activeCategories.length} active sports categories from API (from ${allCategories.length} total)');
//         return activeCategories;
//       } else {
//         throw Exception(
//             'API Error: ${response.statusCode} - ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('❌ Error fetching fresh sports categories: $e');
//       rethrow;
//     }
//   }

//   /// Cache sports categories data
//   static Future<void> _cacheSportsCategories(
//       SharedPreferences prefs, List<dynamic> categoriesData) async {
//     try {
//       final jsonString = json.encode(categoriesData);
//       final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

//       // Save categories data and timestamp
//       await Future.wait([
//         prefs.setString(_cacheKeySportsCategories, jsonString),
//         prefs.setString(_cacheKeyTimestamp, currentTimestamp),
//       ]);

//       print(
//           '💾 Successfully cached ${categoriesData.length} sports categories');
//     } catch (e) {
//       print('❌ Error caching sports categories: $e');
//     }
//   }

//   /// Load fresh data in background without blocking UI
//   static void _loadFreshDataInBackground() {
//     Future.delayed(const Duration(milliseconds: 500), () async {
//       try {
//         print('🔄 Loading fresh sports categories data in background...');
//         final prefs = await SharedPreferences.getInstance();
//         await _fetchFreshSportsCategories(prefs);
//         print('✅ Sports Categories background refresh completed');
//       } catch (e) {
//         print('⚠️ Sports Categories background refresh failed: $e');
//       }
//     });
//   }

//   /// Clear all cached data
//   static Future<void> clearCache() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await Future.wait([
//         prefs.remove(_cacheKeySportsCategories),
//         prefs.remove(_cacheKeyTimestamp),
//       ]);
//       print('🗑️ Sports Categories cache cleared successfully');
//     } catch (e) {
//       print('❌ Error clearing Sports Categories cache: $e');
//     }
//   }

//   /// Get cache info for debugging
//   static Future<Map<String, dynamic>> getCacheInfo() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final timestampStr = prefs.getString(_cacheKeyTimestamp);
//       final cachedData = prefs.getString(_cacheKeySportsCategories);

//       if (timestampStr == null || cachedData == null) {
//         return {
//           'hasCachedData': false,
//           'cacheAge': 0,
//           'cachedCategoriesCount': 0,
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
//         'cachedCategoriesCount': jsonData.length,
//         'cacheSize': cacheSizeKB,
//         'isValid': cacheAge < _cacheDurationMs,
//       };
//     } catch (e) {
//       print('❌ Error getting Sports Categories cache info: $e');
//       return {
//         'hasCachedData': false,
//         'cacheAge': 0,
//         'cachedCategoriesCount': 0,
//         'cacheSize': 0,
//         'error': e.toString(),
//       };
//     }
//   }

//   /// Force refresh data (bypass cache)
//   static Future<List<SportsCategoryModel>> forceRefresh() async {
//     print('🔄 Force refreshing Sports Categories data...');
//     return await getAllSportsCategories(forceRefresh: true);
//   }
// }


// class SportsCategory extends StatefulWidget {
//   const SportsCategory({super.key}); // <-- Make sure constructor is here

//   @override
//   _SportsCategoryState createState() => _SportsCategoryState();
// }

// class _SportsCategoryState extends State<SportsCategory>
//     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
//   @override
//   bool get wantKeepAlive => true;

//   List<SportsCategoryModel> categoriesList = [];
//   bool isLoading = true;
//   int focusedIndex = -1;
//   final int maxHorizontalItems = 7;
//   Color _currentAccentColor = ProfessionalColors.accentOrange;

//   // Animation Controllers
//   late AnimationController _headerAnimationController;
//   late AnimationController _listAnimationController;
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<double> _listFadeAnimation;

//   Map<String, FocusNode> categoriesFocusNodes = {};
//   FocusNode? _viewAllFocusNode;
//   FocusNode? _firstCategoryFocusNode; // Provider mein register karne ke liye
//   bool _hasReceivedFocusFromTVShows = false;

//   late ScrollController _scrollController;
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _initializeAnimations();
//     _initializeFocusNodes();
//     fetchSportsCategoriesWithCache();
//   }

//   // ✅ ==========================================================
//   // ✅ [UPDATED] Sahi dispose logic
//   // ✅ ==========================================================
//   @override
//   void dispose() {
//     _navigationLockTimer?.cancel();
//     _headerAnimationController.dispose();
//     _listAnimationController.dispose();

//     // Sirf un nodes ko dispose karein jo provider mein register NAHI hue
//     String? firstCategoryId;
//     if (categoriesList.isNotEmpty) {
//       firstCategoryId = categoriesList[0].id.toString();
//     }

//     for (var entry in categoriesFocusNodes.entries) {
//       // Agar node register nahi hua hai (yaani first category nahi hai), tabhi use yahan dispose karein
//       if (entry.key != firstCategoryId) {
//         try {
//           entry.value.removeListener(() {});
//           entry.value.dispose();
//         } catch (e) {}
//       }
//     }
//     // Pehle item ka node provider mein dispose hoga.

//     categoriesFocusNodes.clear();
//     // ViewAll node provider mein register nahi hota, isliye use dispose karna theek hai
//     _viewAllFocusNode?.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//   // ✅ ==========================================================
//   // ✅ END OF [UPDATED] dispose logic
//   // ✅ ==========================================================


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
//     print('✅ Sports Categories focus nodes initialized');
//   }

//   // Scrolling logic
//   void _scrollToPosition(int index) {
//      if (!mounted || !_scrollController.hasClients) return;
//     try {
//       double itemWidth = bannerwdt + 12; // Card width + horizontal margin (6+6)
//       double targetPosition = index * itemWidth;

//       targetPosition =
//           targetPosition.clamp(0.0, _scrollController.position.maxScrollExtent);

//       _scrollController.animateTo(
//         targetPosition,
//         duration: const Duration(milliseconds: 350), // Snappier scroll
//         curve: Curves.easeOutCubic,
//       );
//     } catch (e) {
//       print('Error scrolling in sports category: $e');
//     }
//   }


//   // // Yeh function ab seedha _firstCategoryFocusNode ko register karta hai
//   // void _setupCategoriesFocusProvider() {
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     if (mounted && categoriesList.isNotEmpty) {
//   //       try {
//   //         final focusProvider =
//   //             Provider.of<FocusProvider>(context, listen: false);

//   //         final firstCategoryId = categoriesList[0].id.toString();
//   //         _firstCategoryFocusNode = categoriesFocusNodes[firstCategoryId];

//   //         if (_firstCategoryFocusNode != null) {
//   //           // Node ko provider mein 'sportsCategory' ID se register karein
//   //           focusProvider.registerFocusNode(
//   //               'sportsCategory', _firstCategoryFocusNode!);
//   //           print(
//   //               '✅ Sports Categories first focus node registered: ${categoriesList[0].title}');

//   //           // Listener yahin add karein
//   //           _firstCategoryFocusNode!.addListener(() {
//   //             if (_firstCategoryFocusNode!.hasFocus &&
//   //                 !_hasReceivedFocusFromTVShows) {
//   //               _hasReceivedFocusFromTVShows = true;
//   //               setState(() {
//   //                 focusedIndex = 0;
//   //               });
//   //               _scrollToPosition(0);
//   //               print(
//   //                   '✅ Sports Categories received focus from TV shows and scrolled');
//   //             }
//   //           });
//   //         }
//   //       } catch (e) {
//   //         print('❌ Sports Categories focus provider setup failed: $e');
//   //       }
//   //     }
//   //   });
//   // }



//   // Yeh function ab seedha _firstCategoryFocusNode ko register karta hai
//   void _setupCategoriesFocusProvider() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && categoriesList.isNotEmpty) {
//         try {
//           final focusProvider =
//               Provider.of<FocusProvider>(context, listen: false);

//           final firstCategoryId = categoriesList[0].id.toString();
//           _firstCategoryFocusNode = categoriesFocusNodes[firstCategoryId];

//           if (_firstCategoryFocusNode != null) {
//             // Node ko provider mein 'sportsCategory' ID se register karein
//             focusProvider.registerFocusNode(
//                 'sports', _firstCategoryFocusNode!);
//             print(
//                 '✅ Sports Categories first focus node registered: ${categoriesList[0].title}');

//             // Listener yahin add karein
//             _firstCategoryFocusNode!.addListener(() {
              
//               // ✅ ==========================================================
//               // ✅ [FIXED] Listener logic
//               // ✅ ==========================================================
//               // Check karein ki widget mounted hai aur node ko focus mila hai
//               if (mounted && _firstCategoryFocusNode!.hasFocus) {
                
//                 // _hasReceivedFocusFromTVShows flag ko sirf tab set karein jab 
//                 // focus pehli baar row mein aa raha hai.
//                 if (!_hasReceivedFocusFromTVShows) {
//                   _hasReceivedFocusFromTVShows = true;
//                 }
                
//                 // State update aur scroll logic ko hamesha run karein
//                 // jab bhi yeh node focus mein aaye.
//                 setState(() => focusedIndex = 0);
//                 _scrollToPosition(0);
//                 print('✅ Sports Categories (first item) received focus and scrolled');
//               }
//               // ✅ ==========================================================
//               // ✅ END OF [FIXED] listener logic
//               // ✅ ==========================================================

//             });
//           }
//         } catch (e) {
//           print('❌ Sports Categories focus provider setup failed: $e');
//         }
//       }
//     });
//   }

//   // 🚀 Enhanced fetch method with caching
//   Future<void> fetchSportsCategoriesWithCache() async {
//     if (!mounted) return;
//     setState(() { isLoading = true; });
//     try {
//       final fetchedCategories =
//           await SportsCategoriesService.getAllSportsCategories();
//       if (fetchedCategories.isNotEmpty) {
//         if (mounted) {
//           setState(() {
//             categoriesList = fetchedCategories;
//             isLoading = false;
//           });
//           _createFocusNodesForItems(); // Focus nodes banayein
//           _setupCategoriesFocusProvider(); // *Uske baad* provider ko setup karein
//           _headerAnimationController.forward();
//           _listAnimationController.forward();
//           _debugCacheInfo();
//         }
//       } else {
//         if (mounted) { setState(() { isLoading = false; }); }
//       }
//     } catch (e) {
//       if (mounted) { setState(() { isLoading = false; }); }
//       print('Error fetching Sports Categories with cache: $e');
//     }
//   }

//   // 🆕 Debug method to show cache information
//   Future<void> _debugCacheInfo() async {
//     try {
//       final cacheInfo = await SportsCategoriesService.getCacheInfo();
//       print('📊 Sports Categories Cache Info: $cacheInfo');
//     } catch (e) {
//       print('❌ Error getting Sports Categories cache info: $e');
//     }
//   }

//   // 🆕 Force refresh sports categories
//   Future<void> _forceRefreshCategories() async {
//     if (!mounted) return;
//     setState(() { isLoading = true; });
//     try {
//       final fetchedCategories = await SportsCategoriesService.forceRefresh();
//       if (fetchedCategories.isNotEmpty) {
//         if (mounted) {
//           setState(() {
//             categoriesList = fetchedCategories;
//             isLoading = false;
//           });
//           _createFocusNodesForItems();
//           _setupCategoriesFocusProvider();
//           _headerAnimationController.forward();
//           _listAnimationController.forward();
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text('Sports Categories refreshed successfully'),
//               backgroundColor: ProfessionalColors.accentOrange,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(10), ),
//             ),
//           );
//         }
//       } else {
//         if (mounted) { setState(() { isLoading = false; }); }
//       }
//     } catch (e) {
//       if (mounted) { setState(() { isLoading = false; }); }
//       print('❌ Error force refreshing sports categories: $e');
//     }
//   }

//   void _createFocusNodesForItems() {
//      // Purane nodes ko saaf karein (naye dispose logic ke hisaab se)
//     categoriesFocusNodes.clear();

//     for (int i = 0; i < categoriesList.length && i < maxHorizontalItems; i++) {
//       String categoryId = categoriesList[i].id.toString();
//       categoriesFocusNodes[categoryId] = FocusNode(); // Naya node banayein

//       // Pehle node ke alawa baaki nodes ke liye listener yahin add karein
//       // (Pehle node ka listener _setupCategoriesFocusProvider mein add hoga)
//       if (i > 0) {
//         categoriesFocusNodes[categoryId]!.addListener(() {
//           if (mounted && categoriesFocusNodes[categoryId]!.hasFocus) {
//             setState(() {
//               focusedIndex = i;
//               _hasReceivedFocusFromTVShows = true;
//             });
//             _scrollToPosition(i);
//             print(
//                 '✅ Sports Category $i focused and scrolled: ${categoriesList[i].title}');
//           }
//         });
//       }
//     }
//     print(
//         '✅ Created ${categoriesFocusNodes.length} sports category focus nodes with auto-scroll');
//   }


//   void _navigateToSportsCategoryDetails(SportsCategoryModel category) {
//     print('🏆 Navigating to Sports Category Details: ${category.title}');

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SportsCategorySecondPage(
//           tvChannelId: category.id,
//           channelName: category.title,
//           channelLogo: category.thumbnail,
//         ),
//       ),
//     ).then((_) {
//       print('🔙 Returned from Sports Category Details');
//       Future.delayed(Duration(milliseconds: 300), () {
//         if (mounted) {
//           int currentIndex =
//               categoriesList.indexWhere((cat) => cat.id == category.id);
//           if (currentIndex != -1 && currentIndex < maxHorizontalItems) {
//             String categoryId = category.id.toString();
//             if (categoriesFocusNodes.containsKey(categoryId)) {
//               setState(() {
//                 focusedIndex = currentIndex;
//                 _hasReceivedFocusFromTVShows = true;
//               });
//               categoriesFocusNodes[categoryId]!.requestFocus();
//               _scrollToPosition(currentIndex);
//               print('✅ Restored focus to ${category.title}');
//             }
//           }
//         }
//       });
//     });
//   }

//   void _navigateToGridPage() {
//     print('🏆 Navigating to Sports Categories Grid Page...');

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProfessionalSportsCategoriesGridPage(
//           categoriesList: categoriesList,
//           title: 'Sports Categories',
//         ),
//       ),
//     ).then((_) {
//       print('🔙 Returned from grid page');
//       Future.delayed(Duration(milliseconds: 300), () {
//         if (mounted && _viewAllFocusNode != null) {
//           setState(() {
//             focusedIndex = maxHorizontalItems;
//             _hasReceivedFocusFromTVShows = true;
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

//   Widget _buildSportsCategoryItem(SportsCategoryModel category, int index,
//       double screenWidth, double screenHeight) {
//     String categoryId = category.id.toString();
//     FocusNode? focusNode = categoriesFocusNodes[categoryId];

//      if (focusNode == null) return const SizedBox.shrink();

//     return Focus(
//       focusNode: focusNode,
//       onFocusChange: (hasFocus) async {
//          if (!mounted) return; // Add mount check
//         if (hasFocus) {
//           try {
//             Color dominantColor = ProfessionalColors.gradientColors[
//                 math.Random()
//                     .nextInt(ProfessionalColors.gradientColors.length)];

//             setState(() {
//               _currentAccentColor = dominantColor;
//               focusedIndex = index;
//               _hasReceivedFocusFromTVShows = true;
//             });
//             context.read<ColorProvider>().updateColor(dominantColor, true);
//           } catch (e) { print('Focus change handling failed: $e'); }
//         } else {
//           context.read<ColorProvider>().resetColor();
//         }
//       },
//     // ✅ ==========================================================
//     // ✅ [UPDATED] Item onKey LOGIC
//     // ✅ ==========================================================
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           final key = event.logicalKey;

//           // --- हॉरिजॉन्टल मूवमेंट (लेफ्ट/राइट) के लिए थ्रॉटलिंग ---
//           if (key == LogicalKeyboardKey.arrowRight ||
//               key == LogicalKeyboardKey.arrowLeft) {
//             if (_isNavigationLocked) return KeyEventResult.handled;

//             setState(() => _isNavigationLocked = true);
//             _navigationLockTimer = Timer(const Duration(milliseconds: 600), () { // Consistent duration
//               if (mounted) setState(() => _isNavigationLocked = false);
//             });

//             if (key == LogicalKeyboardKey.arrowRight) {
//               // Same View All logic as before
//               if (index < maxHorizontalItems - 1 && index < categoriesList.length - 1) {
//                 String nextCategoryId = categoriesList[index + 1].id.toString();
//                  if (categoriesFocusNodes.containsKey(nextCategoryId)) {
//                   FocusScope.of(context).requestFocus(categoriesFocusNodes[nextCategoryId]);
//                  } else { // Fallback if node not ready (rare case)
//                    _navigationLockTimer?.cancel();
//                    if (mounted) setState(() => _isNavigationLocked = false);
//                  }
//               } else if (index == maxHorizontalItems - 1 && categoriesList.length > maxHorizontalItems) {
//                  if (_viewAllFocusNode != null) {
//                    FocusScope.of(context).requestFocus(_viewAllFocusNode);
//                  } else {
//                    _navigationLockTimer?.cancel();
//                    if (mounted) setState(() => _isNavigationLocked = false);
//                  }
//               } else {
//                 _navigationLockTimer?.cancel();
//                 if (mounted) setState(() => _isNavigationLocked = false);
//               }
//             } else if (key == LogicalKeyboardKey.arrowLeft) {
//               if (index > 0) {
//                 String prevCategoryId = categoriesList[index - 1].id.toString();
//                 if (categoriesFocusNodes.containsKey(prevCategoryId)) {
//                     FocusScope.of(context).requestFocus(categoriesFocusNodes[prevCategoryId]);
//                 } else {
//                    _navigationLockTimer?.cancel();
//                    if (mounted) setState(() => _isNavigationLocked = false);
//                 }
//               } else {
//                 _navigationLockTimer?.cancel();
//                 if (mounted) setState(() => _isNavigationLocked = false);
//               }
//             }
//             return KeyEventResult.handled;
//           }

//           // --- वर्टिकल मूवमेंट (अप/डाउन) ---
//           if (key == LogicalKeyboardKey.arrowUp) {
//             // ✅ CHANGED: Use focusPreviousRow
//             setState(() {
//               focusedIndex = -1;
//               _hasReceivedFocusFromTVShows = false;
//             });
//             context.read<ColorProvider>().resetColor();
//             FocusScope.of(context).unfocus(); // Unfocus current item
//             context.read<FocusProvider>().focusPreviousRow(); // Ask provider
//             return KeyEventResult.handled;
//           } 
          
//           else if (key == LogicalKeyboardKey.arrowDown) {
//             // ✅ CHANGED: Use focusNextRow
//              setState(() {
//               focusedIndex = -1;
//               _hasReceivedFocusFromTVShows = false;
//             });
//             context.read<ColorProvider>().resetColor();
//             FocusScope.of(context).unfocus(); // Unfocus current item
//             context.read<FocusProvider>().focusNextRow(); // Ask provider
//             return KeyEventResult.handled;
//           } 
          
//           else if (key == LogicalKeyboardKey.enter ||
//               key == LogicalKeyboardKey.select) {
//             _navigateToSportsCategoryDetails(category);
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//     // ✅ ==========================================================
//     // ✅ END OF [UPDATED] onKey LOGIC
//     // ✅ ==========================================================
//       child: GestureDetector(
//         onTap: () => _navigateToSportsCategoryDetails(category),
//         child: ProfessionalSportsCategoryCard(
//           category: category,
//           focusNode: focusNode,
//           onTap: () => _navigateToSportsCategoryDetails(category),
//           onColorChange: (color) {
//              if (!mounted) return; // Add mount check
//             setState(() { _currentAccentColor = color; });
//             context.read<ColorProvider>().updateColor(color, true);
//           },
//           index: index,
//           categoryTitle: 'SPORTS',
//         ),
//       ),
//     );
//   }


//   Widget _buildCategoriesList(double screenWidth, double screenHeight) {
//     bool showViewAll = categoriesList.length > maxHorizontalItems;
//     int itemCount = math.min(categoriesList.length, maxHorizontalItems);

//     return FadeTransition(
//       opacity: _listFadeAnimation,
//       child: Container(
//         height: screenHeight * 0.38,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           clipBehavior: Clip.none,
//           controller: _scrollController,
//           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
//           cacheExtent: 9999, // Increased cache extent
//           itemCount: showViewAll ? itemCount + 1 : itemCount, // +1 for View All
//           itemBuilder: (context, index) {
//             if (showViewAll && index == itemCount) {
//               return _buildViewAllButton(); // Show View All button at the end
//             }
//             var category = categoriesList[index];
//             return _buildSportsCategoryItem(
//                 category, index, screenWidth, screenHeight);
//           },
//         ),
//       ),
//     );
//   }

//   // View All Button Widget (Copied from WebSeries, adapted for Sports)
//   Widget _buildViewAllButton() {
//      if (_viewAllFocusNode == null) return const SizedBox.shrink(); // Safety check

//     return Focus(
//       focusNode: _viewAllFocusNode,
//       onFocusChange: (hasFocus) {
//          if (!mounted) return; // Add mount check
//         if (hasFocus) {
//           Color viewAllColor = ProfessionalColors.gradientColors[
//               math.Random()
//                   .nextInt(ProfessionalColors.gradientColors.length)];
//           setState(() { _currentAccentColor = viewAllColor; });
//           context.read<ColorProvider>().updateColor(viewAllColor, true);
//            _scrollToPosition(maxHorizontalItems); // Scroll View All into view
//         } else {
//           context.read<ColorProvider>().resetColor();
//         }
//       },
//     // ✅ ==========================================================
//     // ✅ [UPDATED] ViewAll onKey LOGIC
//     // ✅ ==========================================================
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//            final key = event.logicalKey;

//           if (key == LogicalKeyboardKey.arrowRight) {
//              // Cannot move right from View All
//             return KeyEventResult.handled;
//           } else if (key == LogicalKeyboardKey.arrowLeft) {
//              // Move focus to the last actual category item
//              if (categoriesList.isNotEmpty && categoriesList.length >= maxHorizontalItems) {
//                String categoryId = categoriesList[maxHorizontalItems - 1].id.toString();
//                if (categoriesFocusNodes.containsKey(categoryId)) {
//                   FocusScope.of(context).requestFocus(categoriesFocusNodes[categoryId]);
//                   return KeyEventResult.handled;
//                }
//              }
//           }
          
//           else if (key == LogicalKeyboardKey.arrowUp) {
//             // ✅ CHANGED: Use focusPreviousRow
//             setState(() {
//               focusedIndex = -1; // Reset index when moving vertically
//               _hasReceivedFocusFromTVShows = false;
//             });
//             context.read<ColorProvider>().resetColor();
//             FocusScope.of(context).unfocus();
//             context.read<FocusProvider>().focusPreviousRow();
//             return KeyEventResult.handled;
//           } 
          
//           else if (key == LogicalKeyboardKey.arrowDown) {
//             // ✅ CHANGED: Use focusNextRow
//              setState(() {
//               focusedIndex = -1; // Reset index when moving vertically
//               _hasReceivedFocusFromTVShows = false;
//             });
//             context.read<ColorProvider>().resetColor();
//             FocusScope.of(context).unfocus();
//             context.read<FocusProvider>().focusNextRow();
//             return KeyEventResult.handled;
//           } 
          
//           else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.select) {
//             _navigateToGridPage();
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//     // ✅ ==========================================================
//     // ✅ END OF [UPDATED] onKey LOGIC
//     // ✅ ==========================================================
//       child: GestureDetector(
//         onTap: _navigateToGridPage,
//         child: ProfessionalSportsCategoryViewAllButton(
//           focusNode: _viewAllFocusNode!,
//           onTap: _navigateToGridPage,
//           totalItems: categoriesList.length,
//           itemType: 'SPORTS', // Specific type
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
//                   ProfessionalColors.accentOrange,
//                   ProfessionalColors.accentRed,
//                 ],
//               ).createShader(bounds),
//               child: Text(
//                 'SPORTS',
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 2.0,
//                 ),
//               ),
//             ),
//             // Refresh button can be added here
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBody(double screenWidth, double screenHeight) {
//     if (isLoading) {
//       return ProfessionalSportsCategoryLoadingIndicator(
//           message: 'Loading Sports Categories...');
//     } else if (categoriesList.isEmpty) {
//       return _buildEmptyWidget();
//     } else {
//       return _buildCategoriesList(screenWidth, screenHeight);
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
//                   ProfessionalColors.accentOrange.withOpacity(0.2),
//                   ProfessionalColors.accentOrange.withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.sports_outlined,
//               size: 40,
//               color: ProfessionalColors.accentOrange,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'No Sports Categories Found',
//             style: TextStyle(
//               color: ProfessionalColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Check back later for new categories',
//             style: TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// // ==========================================================
// // SUPPORTING WIDGETS (Inmein koi change nahi hai)
// // ==========================================================
// // (ProfessionalSportsCategoryCard, ProfessionalSportsCategoryViewAllButton, ProfessionalSportsCategoryLoadingIndicator, etc.)
// // ... (Your existing supporting widget code remains the same) ...

// // ✅ Professional Sports Category Card
// class ProfessionalSportsCategoryCard extends StatefulWidget {
//   final SportsCategoryModel category;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final Function(Color) onColorChange;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalSportsCategoryCard({
//     Key? key,
//     required this.category,
//     required this.focusNode,
//     required this.onTap,
//     required this.onColorChange,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalSportsCategoryCardState createState() =>
//       _ProfessionalSportsCategoryCardState();
// }

// class _ProfessionalSportsCategoryCardState
//     extends State<ProfessionalSportsCategoryCard>
//     with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _glowController;
//   late AnimationController _shimmerController;

//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;
//   late Animation<double> _shimmerAnimation;

//   Color _dominantColor = ProfessionalColors.accentOrange;
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
//      if (!mounted) return; // Add mount check
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
//     widget.focusNode.removeListener(_handleFocusChange); // Remove listener first
//     _scaleController.dispose();
//     _glowController.dispose();
//     _shimmerController.dispose();
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
//             _buildSportsCategoryImage(screenWidth, posterHeight),
//             if (_isFocused) _buildFocusBorder(),
//             if (_isFocused) _buildShimmerEffect(),
//             _buildCategoryBadge(),
//             if (_isFocused) _buildHoverOverlay(),
//           ],
//         ),
//       ),
//     );
//   }

//   // 👈 THIS METHOD IS UPDATED TO SHOW IMAGES
//   Widget _buildSportsCategoryImage(double screenWidth, double posterHeight) {
//     // Check if the thumbnail URL is valid and not empty
//     if (widget.category.thumbnail != null &&
//         widget.category.thumbnail!.isNotEmpty) {
//       return Image.network(
//         widget.category.thumbnail!,
//         width: double.infinity,
//         height: posterHeight,
//         fit: BoxFit.cover,
//         // Optional: Show a loading animation
//         loadingBuilder: (BuildContext context, Widget child,
//             ImageChunkEvent? loadingProgress) {
//           if (loadingProgress == null) return child;
//           return Center(
//             child: CircularProgressIndicator(
//               value: loadingProgress.expectedTotalBytes != null
//                   ? loadingProgress.cumulativeBytesLoaded /
//                       loadingProgress.expectedTotalBytes!
//                   : null,
//               strokeWidth: 2,
//               color: _dominantColor,
//             ),
//           );
//         },
//         // Optional: Show a placeholder if the image fails to load
//         errorBuilder:
//             (BuildContext context, Object exception, StackTrace? stackTrace) {
//           print('❌ Error loading image: ${widget.category.thumbnail}');
//           // Fallback to the original placeholder icon on error
//           return _buildImagePlaceholder(posterHeight);
//         },
//       );
//     } else {
//       // If no thumbnail URL is provided, show the original placeholder
//       return _buildImagePlaceholder(posterHeight);
//     }
//   }

//   Widget _buildImagePlaceholder(double height) {
//     IconData sportIcon = _getSportIcon(widget.category.title);
//     Color sportColor = _getSportColor(widget.category.title);

//     return Container(
//       height: height,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             sportColor.withOpacity(0.2),
//             ProfessionalColors.cardDark,
//             ProfessionalColors.surfaceDark,
//           ],
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             sportIcon,
//             size: height * 0.25,
//             color: sportColor,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             widget.category.title.toUpperCase(),
//             style: TextStyle(
//               color: sportColor,
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 4),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//             decoration: BoxDecoration(
//               color: sportColor.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Text(
//               'CATEGORY',
//               style: TextStyle(
//                 color: sportColor,
//                 fontSize: 8,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   IconData _getSportIcon(String categoryTitle) {
//     switch (categoryTitle.toLowerCase()) {
//       case 'cricket':
//         return Icons.sports_cricket;
//       case 'football':
//         return Icons.sports_soccer;
//       case 'basketball':
//         return Icons.sports_basketball;
//       case 'tennis':
//         return Icons.sports_tennis;
//       case 'baseball':
//         return Icons.sports_baseball;
//       case 'golf':
//         return Icons.sports_golf;
//       case 'volleyball':
//         return Icons.sports_volleyball;
//       case 'hockey':
//         return Icons.sports_hockey;
//       default:
//         return Icons.sports;
//     }
//   }

//   Color _getSportColor(String categoryTitle) {
//     switch (categoryTitle.toLowerCase()) {
//       case 'cricket':
//         return ProfessionalColors.accentGreen;
//       case 'football':
//         return ProfessionalColors.accentOrange;
//       case 'basketball':
//         return ProfessionalColors.accentRed;
//       case 'tennis':
//         return ProfessionalColors.accentBlue;
//       case 'baseball':
//         return ProfessionalColors.accentPurple;
//       case 'golf':
//         return ProfessionalColors.accentGreen;
//       case 'volleyball':
//         return ProfessionalColors.accentPink;
//       case 'hockey':
//         return ProfessionalColors.accentBlue;
//       default:
//         return ProfessionalColors.accentOrange;
//     }
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

//   Widget _buildCategoryBadge() {
//     return Positioned(
//       top: 8,
//       right: 8,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//         decoration: BoxDecoration(
//           color: ProfessionalColors.accentOrange.withOpacity(0.9),
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Text(
//           'SPORTS',
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
//     final categoryName = widget.category.title.toUpperCase();

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
//           categoryName,
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }

// // ✅ Professional View All Button for Sports
// class ProfessionalSportsCategoryViewAllButton extends StatefulWidget {
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int totalItems;
//   final String itemType;

//   const ProfessionalSportsCategoryViewAllButton({
//     Key? key,
//     required this.focusNode,
//     required this.onTap,
//     required this.totalItems,
//     this.itemType = 'SPORTS',
//   }) : super(key: key);

//   @override
//   _ProfessionalSportsCategoryViewAllButtonState createState() =>
//       _ProfessionalSportsCategoryViewAllButtonState();
// }

// class _ProfessionalSportsCategoryViewAllButtonState
//     extends State<ProfessionalSportsCategoryViewAllButton>
//     with TickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late AnimationController _rotateController;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _rotateAnimation;

//   bool _isFocused = false;
//   Color _currentColor = ProfessionalColors.accentOrange;

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
//      if (!mounted) return; // Add mount check
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
//     widget.focusNode.removeListener(_handleFocusChange); // Remove listener first
//     _pulseController.dispose();
//     _rotateController.dispose();
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
//                   Icons.sports_rounded,
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

// // ✅ Professional Loading Indicator
// class ProfessionalSportsCategoryLoadingIndicator extends StatefulWidget {
//   final String message;

//   const ProfessionalSportsCategoryLoadingIndicator({
//     Key? key,
//     this.message = 'Loading Sports Categories...',
//   }) : super(key: key);

//   @override
//   _ProfessionalSportsCategoryLoadingIndicatorState createState() =>
//       _ProfessionalSportsCategoryLoadingIndicatorState();
// }

// class _ProfessionalSportsCategoryLoadingIndicatorState
//     extends State<ProfessionalSportsCategoryLoadingIndicator>
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
//                       ProfessionalColors.accentOrange,
//                       ProfessionalColors.accentRed,
//                       ProfessionalColors.accentBlue,
//                       ProfessionalColors.accentOrange,
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
//                     Icons.sports_rounded,
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
//                     ProfessionalColors.accentOrange,
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

// // ✅ Professional Sports Categories Grid Page
// class ProfessionalSportsCategoriesGridPage extends StatefulWidget {
//   final List<SportsCategoryModel> categoriesList;
//   final String title;

//   const ProfessionalSportsCategoriesGridPage({
//     Key? key,
//     required this.categoriesList,
//     this.title = 'All Sports Categories',
//   }) : super(key: key);

//   @override
//   _ProfessionalSportsCategoriesGridPageState createState() =>
//       _ProfessionalSportsCategoriesGridPageState();
// }

// class _ProfessionalSportsCategoriesGridPageState
//     extends State<ProfessionalSportsCategoriesGridPage>
//     with TickerProviderStateMixin {
//   int gridFocusedIndex = 0;
//   final int columnsCount = 5;
//   Map<int, FocusNode> gridFocusNodes = {};
//   late ScrollController _scrollController;

//   // Animation Controllers
//   late AnimationController _fadeController;
//   late AnimationController _staggerController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _createGridFocusNodes();
//     _initializeAnimations();
//     _startStaggeredAnimation();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusFirstGridItem();
//     });
//   }

//    @override
//   void dispose() {
//     _fadeController.dispose();
//     _staggerController.dispose();
//     _scrollController.dispose();
//     for (var node in gridFocusNodes.values) {
//       try {
//         node.removeListener(() {}); // Remove listener before disposing
//         node.dispose();
//       } catch (e) {}
//     }
//     gridFocusNodes.clear(); // Clear the map after disposing nodes
//     super.dispose();
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

//   void _createGridFocusNodes() {
//     for (int i = 0; i < widget.categoriesList.length; i++) {
//       gridFocusNodes[i] = FocusNode();
//       gridFocusNodes[i]!.addListener(() {
//         if (!mounted) return; // Add mount check
//         if (gridFocusNodes[i]!.hasFocus) {
//           setState(() => gridFocusedIndex = i); // Update focused index on focus change
//           _ensureItemVisible(i);
//         }
//       });
//     }
//   }

//   void _focusFirstGridItem() {
//     if (gridFocusNodes.containsKey(0)) {
//        if (!mounted) return; // Add mount check before setState
//       setState(() {
//         gridFocusedIndex = 0;
//       });
//       gridFocusNodes[0]!.requestFocus();
//     }
//   }

//   void _ensureItemVisible(int index) {
//     if (_scrollController.hasClients) {
//       final int row = index ~/ columnsCount;
//       final double itemHeight = 200.0; // Estimate or calculate item height
//       final double targetOffset = row * itemHeight;

//       _scrollController.animateTo(
//         targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent), // Clamp the value
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }


//   void _navigateGrid(LogicalKeyboardKey key) {
//     int newIndex = gridFocusedIndex;
//     final int totalItems = widget.categoriesList.length;
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
//          // Ensure the next index exists
//         if (nextRowIndex < totalItems) {
//             newIndex = nextRowIndex;
//         } else {
//              // Try to go to the last item if moving down from the last partially filled row
//              newIndex = totalItems - 1;
//         }
//         break;

//       case LogicalKeyboardKey.arrowUp:
//         if (currentRow > 0) {
//           final int prevRowIndex = (currentRow - 1) * columnsCount + currentCol;
//            // The previous row index will always be valid if currentRow > 0
//           newIndex = prevRowIndex;
//         }
//         break;
//       default: // Added default case to handle other keys if necessary
//           break;
//     }

//     if (newIndex != gridFocusedIndex &&
//         newIndex >= 0 &&
//         newIndex < totalItems) {
//       if (!mounted) return; // Add mount check before setState
//       setState(() {
//         gridFocusedIndex = newIndex;
//       });
//       if (gridFocusNodes.containsKey(newIndex)) { // Check if node exists
//           gridFocusNodes[newIndex]!.requestFocus();
//       }
//     }
//   }


//   void _navigateToSportsCategoryDetails(
//       SportsCategoryModel category, int index) {
//     print('🏆 Grid: Navigating to Sports Category Details: ${category.title}');

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SportsCategorySecondPage(
//           tvChannelId: category.id,
//           channelName: category.title,
//           channelLogo: category.thumbnail,
//         ),
//       ),
//     ).then((_) {
//       print('🔙 Returned from Sports Category Details to Grid');
//       Future.delayed(Duration(milliseconds: 300), () {
//          if (!mounted) return; // Add mount check
//         if (gridFocusNodes.containsKey(index)) {
//           setState(() {
//             gridFocusedIndex = index;
//           });
//           gridFocusNodes[index]!.requestFocus();
//           print('✅ Restored grid focus to index $index');
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Stack(
//         children: [
//           // Background Gradient
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   ProfessionalColors.primaryDark,
//                   ProfessionalColors.surfaceDark.withOpacity(0.8),
//                   ProfessionalColors.primaryDark,
//                 ],
//               ),
//             ),
//           ),

//           // Main Content
//           FadeTransition(
//             opacity: _fadeAnimation,
//             child: Column(
//               children: [
//                 _buildProfessionalAppBar(),
//                 Expanded(
//                   child: _buildGridView(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfessionalAppBar() {
//     return Container(
//       padding: EdgeInsets.only(
//         top: MediaQuery.of(context).padding.top + 10,
//         left: 20,
//         right: 20,
//         bottom: 20,
//       ),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             ProfessionalColors.surfaceDark.withOpacity(0.9),
//             ProfessionalColors.surfaceDark.withOpacity(0.7),
//             Colors.transparent,
//           ],
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [
//                   ProfessionalColors.accentOrange.withOpacity(0.2),
//                   ProfessionalColors.accentRed.withOpacity(0.2),
//                 ],
//               ),
//             ),
//             child: IconButton(
//               icon: const Icon(
//                 Icons.arrow_back_rounded,
//                 color: Colors.white,
//                 size: 24,
//               ),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ShaderMask(
//                   shaderCallback: (bounds) => const LinearGradient(
//                     colors: [
//                       ProfessionalColors.accentOrange,
//                       ProfessionalColors.accentRed,
//                     ],
//                   ).createShader(bounds),
//                   child: Text(
//                     widget.title,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 1.0,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 // Count can be added here if needed
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGridView() {
//     if (widget.categoriesList.isEmpty) {
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
//                     ProfessionalColors.accentOrange.withOpacity(0.2),
//                     ProfessionalColors.accentOrange.withOpacity(0.1),
//                   ],
//                 ),
//               ),
//               child: const Icon(
//                 Icons.sports_outlined,
//                 size: 40,
//                 color: ProfessionalColors.accentOrange,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'No ${widget.title} Found',
//               style: TextStyle(
//                 color: ProfessionalColors.textPrimary,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Check back later for new categories',
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
//       autofocus: true, // Autofocus the grid itself
//       onKey: (node, event) {
//         if (event is RawKeyDownEvent) {
//           if ([
//             LogicalKeyboardKey.arrowUp,
//             LogicalKeyboardKey.arrowDown,
//             LogicalKeyboardKey.arrowLeft,
//             LogicalKeyboardKey.arrowRight,
//           ].contains(event.logicalKey)) {
//             _navigateGrid(event.logicalKey);
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//               event.logicalKey == LogicalKeyboardKey.select) {
//              // Ensure focused index is valid before navigating
//             if (gridFocusedIndex >= 0 && gridFocusedIndex < widget.categoriesList.length) {
//               _navigateToSportsCategoryDetails(
//                 widget.categoriesList[gridFocusedIndex],
//                 gridFocusedIndex,
//               );
//             }
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: Padding(
//         padding: EdgeInsets.all(20),
//         child: GridView.builder(
//           controller: _scrollController,
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 6, // Adjusted for typical TV screens
//             crossAxisSpacing: 15,
//             mainAxisSpacing: 15,
//             childAspectRatio: 1.5, // Aspect ratio might need adjustment
//           ),
//           itemCount: widget.categoriesList.length,
//           itemBuilder: (context, index) {
//             // Check if focus node exists before building the card
//              if (!gridFocusNodes.containsKey(index)) {
//                  return const SizedBox.shrink(); // Or a placeholder
//              }
//             return AnimatedBuilder(
//               animation: _staggerController,
//               builder: (context, child) {
//                 // Stagger animation calculation
//                 final delay = (index / widget.categoriesList.length) * 0.5;
//                  // Ensure delay + 0.5 does not exceed 1.0
//                  final endInterval = (delay + 0.5).clamp(0.0, 1.0);
//                  final startInterval = delay.clamp(0.0, endInterval); // Ensure start <= end

//                 final animationValue = Interval(
//                    startInterval,
//                    endInterval, // Use clamped end interval
//                   curve: Curves.easeOutCubic,
//                 ).transform(_staggerController.value);

//                 return Transform.translate(
//                   offset: Offset(0, 50 * (1 - animationValue)),
//                   child: Opacity(
//                     opacity: animationValue,
//                     child: ProfessionalGridSportsCategoryCard(
//                       category: widget.categoriesList[index],
//                       focusNode: gridFocusNodes[index]!,
//                       onTap: () => _navigateToSportsCategoryDetails(
//                           widget.categoriesList[index], index),
//                       index: index,
//                       categoryTitle: widget.title,
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

// // ✅ Professional Grid Sports Category Card
// class ProfessionalGridSportsCategoryCard extends StatefulWidget {
//   final SportsCategoryModel category;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalGridSportsCategoryCard({
//     Key? key,
//     required this.category,
//     required this.focusNode,
//     required this.onTap,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalGridSportsCategoryCardState createState() =>
//       _ProfessionalGridSportsCategoryCardState();
// }

// class _ProfessionalGridSportsCategoryCardState
//     extends State<ProfessionalGridSportsCategoryCard>
//     with TickerProviderStateMixin {
//   late AnimationController _hoverController;
//   late AnimationController _glowController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;

//   Color _dominantColor = ProfessionalColors.accentOrange;
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

//    @override
//   void dispose() {
//     widget.focusNode.removeListener(_handleFocusChange); // Remove listener first
//     _hoverController.dispose();
//     _glowController.dispose();
//     super.dispose();
//   }


//   void _handleFocusChange() {
//      if (!mounted) return; // Add mount check
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
//   Widget build(BuildContext context) {
//     return Focus( // Wrap with Focus widget to handle Enter/Select key
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
//                       _buildCategoryImage(),
//                       if (_isFocused) _buildFocusBorder(),
//                       _buildGradientOverlay(),
//                       _buildCategoryInfo(),
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

//   // 👈 THIS METHOD IS UPDATED TO SHOW IMAGES
//   Widget _buildCategoryImage() {
//     // Define the original placeholder as a fallback
//     IconData sportIcon = _getSportIcon(widget.category.title);
//     Color sportColor = _getSportColor(widget.category.title);
//     Widget placeholder = Container(
//       width: double.infinity,
//       height: double.infinity,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             sportColor.withOpacity(0.2),
//             ProfessionalColors.cardDark,
//             ProfessionalColors.surfaceDark,
//           ],
//         ),
//       ),
//       child: Center(child: Icon(sportIcon, size: 60, color: sportColor)),
//     );

//     // Check if the thumbnail URL is valid
//     if (widget.category.thumbnail != null &&
//         widget.category.thumbnail!.isNotEmpty) {
//       return Image.network(
//         widget.category.thumbnail!,
//         width: double.infinity,
//         height: double.infinity,
//         fit: BoxFit.cover,
//         // Optional: Show a loading animation
//         loadingBuilder: (BuildContext context, Widget child,
//             ImageChunkEvent? loadingProgress) {
//           if (loadingProgress == null) return child;
//           return Center(
//             child: CircularProgressIndicator(
//               value: loadingProgress.expectedTotalBytes != null
//                   ? loadingProgress.cumulativeBytesLoaded /
//                       loadingProgress.expectedTotalBytes!
//                   : null,
//               strokeWidth: 2,
//               color: _dominantColor,
//             ),
//           );
//         },
//         // Optional: Show the placeholder if the image fails to load
//         errorBuilder:
//             (BuildContext context, Object exception, StackTrace? stackTrace) {
//           print('❌ Error loading grid image: ${widget.category.thumbnail}');
//           return placeholder;
//         },
//       );
//     } else {
//       // If no thumbnail URL is provided, show the placeholder
//       return placeholder;
//     }
//   }

//   IconData _getSportIcon(String categoryTitle) {
//     switch (categoryTitle.toLowerCase()) {
//       case 'cricket':
//         return Icons.sports_cricket;
//       case 'football':
//         return Icons.sports_soccer;
//       case 'basketball':
//         return Icons.sports_basketball;
//       case 'tennis':
//         return Icons.sports_tennis;
//       case 'baseball':
//         return Icons.sports_baseball;
//       case 'golf':
//         return Icons.sports_golf;
//       case 'volleyball':
//         return Icons.sports_volleyball;
//       case 'hockey':
//         return Icons.sports_hockey;
//       default:
//         return Icons.sports;
//     }
//   }

//   Color _getSportColor(String categoryTitle) {
//     switch (categoryTitle.toLowerCase()) {
//       case 'cricket':
//         return ProfessionalColors.accentGreen;
//       case 'football':
//         return ProfessionalColors.accentOrange;
//       case 'basketball':
//         return ProfessionalColors.accentRed;
//       case 'tennis':
//         return ProfessionalColors.accentBlue;
//       case 'baseball':
//         return ProfessionalColors.accentPurple;
//       case 'golf':
//         return ProfessionalColors.accentGreen;
//       case 'volleyball':
//         return ProfessionalColors.accentPink;
//       case 'hockey':
//         return ProfessionalColors.accentBlue;
//       default:
//         return ProfessionalColors.accentOrange;
//     }
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

//   Widget _buildCategoryInfo() {
//     final categoryName = widget.category.title;

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
//               categoryName.toUpperCase(),
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
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: _dominantColor.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: _dominantColor.withOpacity(0.4),
//                     width: 1,
//                   ),
//                 ),
//                 child: Text(
//                   'SPORTS CATEGORY',
//                   style: TextStyle(
//                     color: _dominantColor,
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

// // ✅ Placeholder for Sports Category Details Page
// class SportsCategoryDetailsPage extends StatelessWidget {
//   final int categoryId;
//   final String categoryTitle;

//   const SportsCategoryDetailsPage({
//     Key? key,
//     required this.categoryId,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       appBar: AppBar(
//         backgroundColor: ProfessionalColors.surfaceDark,
//         title: Text(
//           categoryTitle,
//           style: const TextStyle(color: Colors.white),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.sports_rounded,
//               size: 80,
//               color: ProfessionalColors.accentOrange,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Sports Category Details',
//               style: const TextStyle(
//                 color: ProfessionalColors.textPrimary,
//                 fontSize: 24,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               categoryTitle,
//               style: const TextStyle(
//                 color: ProfessionalColors.accentOrange,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Category ID: $categoryId',
//               style: const TextStyle(
//                 color: ProfessionalColors.textSecondary,
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 40),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     ProfessionalColors.accentOrange.withOpacity(0.2),
//                     ProfessionalColors.accentRed.withOpacity(0.2),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: ProfessionalColors.accentOrange.withOpacity(0.3),
//                   width: 1,
//                 ),
//               ),
//               child: const Text(
//                 'Sports content will be loaded here',
//                 style: TextStyle(
//                   color: ProfessionalColors.textSecondary,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }








import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/home_screen_pages/religious_channel/religious_channel_slider_screen.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/sports_category/sports_slider_screen.dart';
// ✅ [UPDATED IMPORT] Ensure this path exists for your Sports Slider
import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/tv_show_second_page.dart'; 
import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/tv_show_slider_screen.dart'; 
import 'dart:math' as math;
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:ui';

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
    accentBlue, // ✅ Changed priority for Sports theme
    accentGreen,
    accentRed,
    accentOrange,
    accentPurple,
    accentPink,
  ];
}

// ✅ Animation Durations
class AnimationTiming {
  static const Duration ultraFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration focus = Duration(milliseconds: 300);
  static const Duration scroll = Duration(milliseconds: 800);
}

// ✅ ==========================================================
// ✅ [RENAMED] Sports Network Model
// ✅ ==========================================================
class SportsNetworkModel {
  final int id;
  final String name;
  final String? logo;
  final int status;

  SportsNetworkModel({
    required this.id,
    required this.name,
    this.logo,
    required this.status,
  });

  factory SportsNetworkModel.fromJson(Map<String, dynamic> json) {
    return SportsNetworkModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logo: json['logo'],
      status: json['status'] ?? 0,
    );
  }
}

// ✅ ==========================================================
// ✅ [RENAMED & MODIFIED] SportsNetworkService
// ✅ ==========================================================
class SportsNetworkService {
  
  /// Main method to get all Sports Networks (Direct API Call)
  static Future<List<SportsNetworkModel>> getAllSportsNetworks() async {
    try {
      print('⚽ Loading Fresh Sports Networks from API...'); 
      return await _fetchSportsNetworksFromApi();
    } catch (e) {
      print('❌ Error in getAllSportsNetworks: $e');
      throw Exception('Failed to load sports networks: $e');
    }
  }

  /// Fetch data from API
  static Future<List<SportsNetworkModel>> _fetchSportsNetworksFromApi() async {
    try {
      String authKey = SessionManager.authKey;
      var url = Uri.parse(SessionManager.baseUrl + 'getNetworks');

      final response = await https
          .post(url,
            headers: {
              'auth-key': authKey,
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'domain': SessionManager.savedDomain,
            },
            // ✅ [IMPORTANT] Changed "data_for" to "sportschannels"
            body: json.encode({"network_id": "", "data_for": "sports"}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        final allNetworks = jsonData
            .map((json) =>
                SportsNetworkModel.fromJson(json as Map<String, dynamic>))
            .toList();

        final activeNetworks =
            allNetworks.where((network) => network.status == 1).toList();

        print(
            '✅ Successfully loaded ${activeNetworks.length} active Sports networks');
        return activeNetworks;
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ Error fetching sports networks: $e');
      rethrow;
    }
  }
}

// ✅ ==========================================================
// ✅ [RENAMED] Main Widget: ManageSports
// ✅ ==========================================================
class ManageSports extends StatefulWidget {
  const ManageSports({super.key});
  @override
  _ManageSportsState createState() => _ManageSportsState();
}

class _ManageSportsState extends State<ManageSports>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  // ✅ [RENAMED] State variables
  List<SportsNetworkModel> _fullSportsList = [];
  List<SportsNetworkModel> _displayedSportsList = [];
  bool _showViewAll = false;
  bool isLoading = true;
  int focusedIndex = -1;
  Color _currentAccentColor = ProfessionalColors.accentBlue;

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;

  // ✅ [RENAMED] Focus variables
  Map<String, FocusNode> sportsFocusNodes = {};
  FocusNode? _firstSportsFocusNode;
  late FocusNode _viewAllFocusNode;
  bool _hasReceivedFocus = false;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _viewAllFocusNode = FocusNode();
    _initializeAnimations();
    _initializeFocusListeners();
    fetchSportsNetworks(); // ✅ Direct Fetch
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _listAnimationController.dispose();

    _viewAllFocusNode.removeListener(_onViewAllFocusChange);
    _viewAllFocusNode.dispose();

    // Dispose logic
    String? firstNetworkId;
    if (_fullSportsList.isNotEmpty) {
      firstNetworkId = _fullSportsList[0].id.toString();
    }

    for (var entry in sportsFocusNodes.entries) {
      if (entry.key != firstNetworkId) {
        try {
          entry.value.removeListener(() {});
          entry.value.dispose();
        } catch (e) {}
      }
    }
    sportsFocusNodes.clear();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _headerAnimationController =
        AnimationController(duration: AnimationTiming.slow, vsync: this);
    _listAnimationController =
        AnimationController(duration: AnimationTiming.slow, vsync: this);

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _headerAnimationController, curve: Curves.easeOutCubic));

    _listFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _listAnimationController, curve: Curves.easeInOut));
  }

  void _initializeFocusListeners() {
    _viewAllFocusNode.addListener(_onViewAllFocusChange);
  }

  void _onViewAllFocusChange() {
    if (mounted && _viewAllFocusNode.hasFocus) {
      setState(() {
        focusedIndex = _displayedSportsList.length; 
      });
      _scrollToPosition(focusedIndex);
    }
  }

  void _scrollToPosition(int index) {
    if (!mounted || !_scrollController.hasClients) return;
    try {
      double itemWidth = bannerwdt + 12;
      double targetPosition = index * itemWidth;
      targetPosition =
          targetPosition.clamp(0.0, _scrollController.position.maxScrollExtent);

      _scrollController.animateTo(
        targetPosition,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } catch (e) {
      print('Error scrolling in sports list: $e');
    }
  }

  // ✅ [RENAMED & UPDATED KEY]
  void _setupSportsFocusProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _displayedSportsList.isNotEmpty) {
        try {
          final focusProvider =
              Provider.of<FocusProvider>(context, listen: false);
          final firstNetworkId = _displayedSportsList[0].id.toString();
          _firstSportsFocusNode =
              sportsFocusNodes[firstNetworkId];

          if (_firstSportsFocusNode != null) {
            // ✅ [UPDATED KEY] 'sportsChannels'
            focusProvider.registerFocusNode(
                'sports', _firstSportsFocusNode!);
            
            _firstSportsFocusNode!.addListener(() {
              if (mounted && _firstSportsFocusNode!.hasFocus) {
                if (!_hasReceivedFocus) {
                  _hasReceivedFocus = true;
                }
                setState(() => focusedIndex = 0);
                _scrollToPosition(0);
              }
            });
          }
        } catch (e) {
          print('❌ Sports focus provider setup failed: $e');
        }
      }
    });
  }

  // ✅ [RENAMED] Fetch Logic
  Future<void> fetchSportsNetworks() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      // ✅ Calling the new Service
      final fetchedNetworks = await SportsNetworkService.getAllSportsNetworks();

      if (mounted) {
        _fullSportsList = fetchedNetworks;
        
        if (_fullSportsList.length > 10) {
          _displayedSportsList = _fullSportsList.sublist(0, 10);
        } else {
          _displayedSportsList = _fullSportsList;
        }
        _showViewAll = _fullSportsList.isNotEmpty;

        setState(() {
          isLoading = false;
        });

        if (_fullSportsList.isNotEmpty) {
          _createFocusNodesForItems();
          _setupSportsFocusProvider(); 
          _headerAnimationController.forward();
          _listAnimationController.forward();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error fetching Sports Networks: $e');
    }
  }

  void _createFocusNodesForItems() {
    sportsFocusNodes.clear();

    for (int i = 0; i < _displayedSportsList.length; i++) {
      String networkId = _displayedSportsList[i].id.toString();
      sportsFocusNodes[networkId] = FocusNode();

      if (i > 0) {
        sportsFocusNodes[networkId]!.addListener(() {
          if (mounted && sportsFocusNodes[networkId]!.hasFocus) {
            setState(() {
              focusedIndex = i;
              _hasReceivedFocus = true;
            });
            _scrollToPosition(i);
          }
        });
      }
    }
  }

  // ✅ [RENAMED] Navigation
  void _navigateToSportsDetails(SportsNetworkModel network) async {
    print('🎬 Navigating to Sports Details: ${network.name}');

    try {
      int? currentUserId = SessionManager.userId;
      await HistoryService.updateUserHistory(
        userId: currentUserId!,
        contentType: 4, 
        eventId: network.id,
        eventTitle: network.name,
        url: '',
        categoryId: 0, 
      );
    } catch (e) {
      print("History update failed: $e");
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        // ✅ Reusing the same details page structure
        builder: (context) => TVShowDetailsPage(
          tvChannelId: network.id,
          channelName: network.name,
          channelLogo: network.logo,
        ),
      ),
    );
  }

  void _navigateToGridPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        // ✅ Pointing to Sports Slider
        builder: (context) => SportsSliderScreen(
          initialNetworkId: null, 
        ),
      ),
    );
  }

  void _navigateToGridPageWithNetwork(SportsNetworkModel network) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // ✅ Pointing to Sports Slider
        builder: (context) => SportsSliderScreen (
          initialNetworkId: network.id, 
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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

  Widget _buildSportsItem(SportsNetworkModel network, int index,
      double screenWidth, double screenHeight) {
    String networkId = network.id.toString();
    FocusNode? focusNode = sportsFocusNodes[networkId];

    if (focusNode == null) return const SizedBox.shrink();

    return Focus(
      focusNode: focusNode,
      onFocusChange: (hasFocus) async {
        if (!mounted) return;
        if (hasFocus) {
          try {
            Color dominantColor = ProfessionalColors.gradientColors[
                math.Random().nextInt(ProfessionalColors.gradientColors.length)];
            setState(() {
              _currentAccentColor = dominantColor;
              focusedIndex = index;
              _hasReceivedFocus = true;
            });
            context.read<ColorProvider>().updateColor(dominantColor, true);
            _scrollToPosition(index);
          } catch (e) {
            print('Focus change handling failed: $e');
          }
        } else {
          bool isAnyItemFocused =
              sportsFocusNodes.values.any((node) => node.hasFocus);
          if (!mounted) return;
          if (!isAnyItemFocused && !_viewAllFocusNode.hasFocus) {
            context.read<ColorProvider>().resetColor();
          }
        }
      },
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          final key = event.logicalKey;

          if (key == LogicalKeyboardKey.arrowRight) {
            if (index < _displayedSportsList.length - 1) {
              String nextNetworkId =
                  _displayedSportsList[index + 1].id.toString();
              FocusScope.of(context)
                  .requestFocus(sportsFocusNodes[nextNetworkId]);
            } else if (_showViewAll) {
              FocusScope.of(context).requestFocus(_viewAllFocusNode);
            }
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowLeft) {
            if (index > 0) {
              String prevNetworkId =
                  _displayedSportsList[index - 1].id.toString();
              FocusScope.of(context)
                  .requestFocus(sportsFocusNodes[prevNetworkId]);
            }
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowUp) {
            setState(() {
              focusedIndex = -1;
              _hasReceivedFocus = false;
            });
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                 context.read<FocusProvider>().focusPreviousRow();
              }
            });
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowDown) {
            setState(() {
              focusedIndex = -1;
              _hasReceivedFocus = false;
            });
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                 context.read<FocusProvider>().focusNextRow();
              }
            });
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.enter ||
              key == LogicalKeyboardKey.select) {
            _navigateToGridPageWithNetwork(network);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _navigateToGridPageWithNetwork(network),
        child: ProfessionalSportsCard(
          network: network,
          focusNode: focusNode,
          onTap: () => _navigateToGridPageWithNetwork(network),
          onColorChange: (color) {
            if (!mounted) return;
            setState(() {
              _currentAccentColor = color;
            });
            context.read<ColorProvider>().updateColor(color, true);
          },
        ),
      ),
    );
  }

  Widget _buildViewAllButton(double screenWidth, double screenHeight) {
    return Focus(
      focusNode: _viewAllFocusNode,
      onFocusChange: (hasFocus) {
        if (!mounted) return;
        if (hasFocus) {
          setState(() {
            focusedIndex = _displayedSportsList.length;
            _hasReceivedFocus = true;
          });
          context
              .read<ColorProvider>()
              .updateColor(ProfessionalColors.accentBlue, true);
          _scrollToPosition(focusedIndex);
        } else {
          bool isAnyItemFocused =
              sportsFocusNodes.values.any((node) => node.hasFocus);
          if (!mounted) return;
          if (!isAnyItemFocused) {
            context.read<ColorProvider>().resetColor();
          }
        }
      },
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          final key = event.logicalKey;

          if (key == LogicalKeyboardKey.arrowLeft) {
            if (_displayedSportsList.isNotEmpty) {
              String prevNetworkId =
                  _displayedSportsList.last.id.toString();
              FocusScope.of(context)
                  .requestFocus(sportsFocusNodes[prevNetworkId]);
            }
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowUp) {
             setState(() {
              focusedIndex = -1;
              _hasReceivedFocus = false;
            });
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                 context.read<FocusProvider>().focusPreviousRow();
              }
            });
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowDown) {
             setState(() {
              focusedIndex = -1;
              _hasReceivedFocus = false;
            });
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                 context.read<FocusProvider>().focusNextRow();
              }
            });
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.enter ||
              key == LogicalKeyboardKey.select) {
            _navigateToGridPage();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: _navigateToGridPage,
        child: ProfessionalSportsViewAllButton(
          focusNode: _viewAllFocusNode,
          onTap: _navigateToGridPage,
        ),
      ),
    );
  }

  Widget _buildSportsList(double screenWidth, double screenHeight) {
    return FadeTransition(
      opacity: _listFadeAnimation,
      child: Container(
        height: screenHeight * 0.38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
          cacheExtent: 9999,
          itemCount:
              _displayedSportsList.length + (_showViewAll ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _displayedSportsList.length) {
              var network = _displayedSportsList[index];
              return _buildSportsItem(
                  network, index, screenWidth, screenHeight);
            } else {
              return _buildViewAllButton(screenWidth, screenHeight);
            }
          },
        ),
      ),
    );
  }

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
                  ProfessionalColors.accentGreen,
                ],
              ).createShader(bounds),
              child: const Text(
                'SPORTS', // ✅ Title Updated
                style: TextStyle(
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

  Widget _buildBody(double screenWidth, double screenHeight) {
    if (isLoading) {
      return ProfessionalSportsLoadingIndicator(
          message: 'Loading Sports Channels...');
    } else if (_fullSportsList.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildSportsList(screenWidth, screenHeight);
    }
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
              Icons.sports_soccer, // ✅ Icon Updated for Sports
              size: 40,
              color: ProfessionalColors.accentBlue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Sports Channels Found', // ✅ Text Updated
            style: TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later',
            style: TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ ==========================================================
// ✅ Supporting Widgets (Adapted for Sports Theme)
// ✅ ==========================================================

class ProfessionalSportsCard extends StatefulWidget {
  final SportsNetworkModel network;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final Function(Color) onColorChange;

  const ProfessionalSportsCard({
    Key? key,
    required this.network,
    required this.focusNode,
    required this.onTap,
    required this.onColorChange,
  }) : super(key: key);

  @override
  _ProfessionalSportsCardState createState() =>
      _ProfessionalSportsCardState();
}

class _ProfessionalSportsCardState
    extends State<ProfessionalSportsCard> with TickerProviderStateMixin {
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
    _scaleController =
        AnimationController(duration: AnimationTiming.slow, vsync: this);
    _glowController =
        AnimationController(duration: AnimationTiming.medium, vsync: this);
    _shimmerController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this)
      ..repeat();

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
        CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut));

    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!mounted) return;
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
    widget.focusNode.removeListener(_handleFocusChange);
    _scaleController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
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
            _buildNetworkImage(screenWidth, posterHeight),
            if (_isFocused) _buildFocusBorder(),
            if (_isFocused) _buildShimmerEffect(),
            if (_isFocused) _buildHoverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkImage(double screenWidth, double posterHeight) {
    return Container(
      width: double.infinity,
      height: posterHeight,
      child: widget.network.logo != null && widget.network.logo!.isNotEmpty
          ? Image.network(
              widget.network.logo!,
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
            Icons.sports_soccer, // ✅ Updated Icon
            size: height * 0.25,
            color: ProfessionalColors.textSecondary,
          ),
          const SizedBox(height: 8),
          const Text(
            'SPORTS',
            style: TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
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
            child: Icon(
              Icons.play_arrow_rounded,
              color: _dominantColor,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalTitle(double screenWidth) {
    final networkName = widget.network.name.toUpperCase();

    return Container(
      width: bannerwdt,
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
          networkName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class ProfessionalSportsViewAllButton extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback onTap;

  const ProfessionalSportsViewAllButton({
    Key? key,
    required this.focusNode,
    required this.onTap,
  }) : super(key: key);

  @override
  _ProfessionalSportsViewAllButtonState createState() =>
      _ProfessionalSportsViewAllButtonState();
}

class _ProfessionalSportsViewAllButtonState
    extends State<ProfessionalSportsViewAllButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;
  final Color _focusColor = ProfessionalColors.accentBlue;

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
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });

    if (_isFocused) {
      _scaleController.forward();
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
                _buildButtonBody(),
                _buildButtonTitle(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonBody() {
    final posterHeight = _isFocused ? focussedBannerhgt : bannerhgt;
    return Container(
      height: posterHeight,
      width: bannerwdt,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProfessionalColors.cardDark.withOpacity(0.8),
            ProfessionalColors.surfaceDark.withOpacity(0.8),
          ],
        ),
        border: Border.all(
          width: _isFocused ? 3 : 0,
          color: _isFocused ? _focusColor : Colors.transparent,
        ),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: _focusColor.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 3,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 30,
                color:
                    _isFocused ? _focusColor : ProfessionalColors.textPrimary,
              ),
              const SizedBox(height: 8),
              Text(
                'VIEW ALL',
                style: TextStyle(
                  color:
                      _isFocused ? _focusColor : ProfessionalColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonTitle() {
    return Container(
      width: bannerwdt,
      child: AnimatedDefaultTextStyle(
        duration: AnimationTiming.medium,
        style: TextStyle(
          fontSize: _isFocused ? 13 : 11,
          fontWeight: FontWeight.w600,
          color: _isFocused ? _focusColor : ProfessionalColors.textPrimary,
        ),
        child: const Text(
          'SEE ALL',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class ProfessionalSportsLoadingIndicator extends StatefulWidget {
  final String message;
  const ProfessionalSportsLoadingIndicator({
    Key? key,
    this.message = 'Loading...',
  }) : super(key: key);

  @override
  _ProfessionalSportsLoadingIndicatorState createState() =>
      _ProfessionalSportsLoadingIndicatorState();
}

class _ProfessionalSportsLoadingIndicatorState
    extends State<ProfessionalSportsLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this)
      ..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
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
                    colors: const [
                      ProfessionalColors.accentBlue,
                      ProfessionalColors.accentGreen,
                      ProfessionalColors.accentRed,
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
                    Icons.sports_soccer,
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
        ],
      ),
    );
  }
}