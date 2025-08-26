// import 'dart:async';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'dart:math' as math;
// import 'dart:ui';
// import 'package:http/http.dart' as https;
// import 'package:provider/provider.dart';

// // Professional Color Palette
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

// // ✅ OPTIMIZED GENERIC LIVE CHANNELS WIDGET WITH STATUS FILTERING
// class GenericLiveChannels extends StatefulWidget {
//   final Function(bool)? onFocusChange;
//   final FocusNode focusNode;
//   final String apiCategory; // 'Music', 'Movie', 'Entertainment', 'News', etc.
//   final String displayTitle; // 'MUSIC', 'MOVIES', 'ENTERTAINMENT', 'NEWS', etc.
//   final int
//       navigationIndex; // 0=Live, 1=Entertainment, 2=Music, 3=Movie, 4=News, etc.

//   const GenericLiveChannels({
//     Key? key,
//     this.onFocusChange,
//     required this.focusNode,
//     required this.apiCategory,
//     required this.displayTitle,
//     required this.navigationIndex,
//   }) : super(key: key);

//   @override
//   _GenericLiveChannelsState createState() => _GenericLiveChannelsState();
// }

// class _GenericLiveChannelsState extends State<GenericLiveChannels>
//     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
//   @override
//   bool get wantKeepAlive => true;

//   // ✅ OPTIMIZED: Separate data for display and grid with status filtering
//   List<NewsChannel> displayChannelsList =
//       []; // Only 7 ACTIVE channels for home page display
//   List<NewsChannel> fullChannelsList = []; // All ACTIVE channels for grid view
//   int totalActiveChannelsCount = 0; // Total ACTIVE channels count from API

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
//   Map<String, FocusNode> channelFocusNodes = {};
//   FocusNode? _viewAllFocusNode;
//   Color _currentAccentColor = ProfessionalColors.accentBlue;

//   // Controllers
//   final ScrollController _scrollController = ScrollController();
//   late final String _cacheKey;
//   Timer? _backgroundFetchTimer;
//   bool _isBackgroundFetching = false;



//   // ✅ OPTIMIZED: Modified initState and data loading methods

// @override
// void initState() {
//   super.initState();
//   _cacheKey = 'live_channels_${widget.apiCategory}';
//   _initializeAnimations();
//   _initializeViewAllFocusNode();
//   _setupFocusProvider();
  
//   // ✅ NEW: Load data with optimized caching strategy
//   _loadDataWithCaching();
//   _startBackgroundFetching();
// }

// // ✅ NEW: Optimized data loading with instant cache + background refresh
// Future<void> _loadDataWithCaching() async {
//   if (!mounted) return;

//   // Step 1: Try to load from cache instantly
//   final cachedData = await _loadFromCache();
  
//   if (cachedData != null && cachedData.isNotEmpty) {
//     // ✅ INSTANT: Show cached data immediately
//     if (mounted) {
//       setState(() {
//         displayChannelsList = cachedData.take(7).toList();
//         totalActiveChannelsCount = cachedData.length;
//         _initializeChannelFocusNodes();
//         _isLoading = false;
//       });
//       _headerAnimationController.forward();
//       _listAnimationController.forward();
//     }
    
//     print('✅ Cache data loaded instantly: ${cachedData.length} channels');
    
//     // Step 2: Fetch fresh data in background to update cache
//     _fetchFreshDataInBackground();
//   } else {
//     // ✅ NO CACHE: Show loading and fetch from API
//     print('❌ No cache found, fetching from API...');
//     setState(() {
//       _isLoading = true;
//     });
//     await _fetchDisplayChannels();
//   }
// }

// // ✅ NEW: Background cache update WITHOUT UI changes
// Future<void> _fetchFreshDataInBackground() async {
//   if (!mounted) return;
  
//   try {
//     print('🔄 Fetching fresh data in background...');
//     final freshData = await _fetchChannelsFromAPI();
    
//     if (freshData.isNotEmpty) {
//       final cachedData = await _loadFromCache();
      
//       // Compare fresh data with cached data
//       if (cachedData == null || !_areChannelListsEqual(cachedData, freshData)) {
//         print('🆕 Fresh data different from cache, updating...');
        
//         // ✅ ONLY UPDATE CACHE - DO NOT UPDATE UI
//         await _saveToCache(freshData);
        
//         // ✅ REMOVED: UI update code - keeping current UI as is
//         // User jo dekh raha hai woh same rahega
        
//         print('✅ Cache updated with fresh data (UI unchanged)');
//       } else {
//         print('✅ Cache data is already fresh, no update needed');
//       }
//     }
//   } catch (e) {
//     print('❌ Background fetch error: $e');
//     // Don't show error to user since this is background operation
//   }
// }

// // ✅ MODIFIED: Enhanced cache loading with better error handling
// Future<List<NewsChannel>?> _loadFromCache() async {
//   try {
//     final prefs = await SharedPreferences.getInstance();
//     final cachedString = prefs.getString(_cacheKey);
    
//     if (cachedString != null && cachedString.isNotEmpty) {
//       final cachedList = jsonDecode(cachedString) as List;
//       final channels = cachedList.map((item) => NewsChannel.fromJson(item)).toList();
      
//       // ✅ Filter active channels from cache too
//       final activeChannels = _filterActiveChannels(channels);
      
//       print('📦 Cache loaded: ${activeChannels.length} active channels');
//       return activeChannels;
//     }
//   } catch (e) {
//     print('❌ Error loading from cache: $e');
//     // Clear corrupted cache
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_cacheKey);
//     } catch (clearError) {
//       print('❌ Error clearing corrupted cache: $clearError');
//     }
//   }
//   return null;
// }

// // ✅ ENHANCED: Better cache saving with validation
// Future<void> _saveToCache(List<NewsChannel> channels) async {
//   try {
//     if (channels.isEmpty) {
//       print('⚠️ Not saving empty channels list to cache');
//       return;
//     }
    
//     final prefs = await SharedPreferences.getInstance();
//     final jsonList = channels.map((channel) => channel.toJson()).toList();
//     final jsonString = jsonEncode(jsonList);
    
//     await prefs.setString(_cacheKey, jsonString);
//     print('💾 Cache saved: ${channels.length} channels');
//   } catch (e) {
//     print('❌ Error saving to cache: $e');
//   }
// }

// // ✅ OPTIMIZED: Background fetching with cache-only updates
// void _startBackgroundFetching() {
//   // Cancel any existing timer
//   _backgroundFetchTimer?.cancel();

//   // Start new timer that runs every 2 minutes for silent cache updates
//   _backgroundFetchTimer = Timer.periodic(Duration(minutes: 2), (timer) {
//     if (!mounted) {
//       timer.cancel();
//       return;
//     }
//     // ✅ Silent cache update - no UI changes
//     _fetchDataInBackground();
//   });

//   // Also update cache after 10 seconds of initial load (silent)
//   Timer(Duration(seconds: 10), () {
//     if (mounted) {
//       print('🔄 Starting silent cache update...');
//       _fetchDataInBackground();
//     }
//   });
// }

// // ✅ ENHANCED: Improved data comparison
// bool _areChannelListsEqual(List<NewsChannel> list1, List<NewsChannel> list2) {
//   if (list1.length != list2.length) return false;

//   for (int i = 0; i < list1.length; i++) {
//     if (list1[i].id != list2[i].id ||
//         list1[i].url != list2[i].url ||
//         list1[i].status != list2[i].status ||
//         list1[i].name != list2[i].name ||
//         list1[i].banner != list2[i].banner) {
//       return false;
//     }
//   }

//   return true;
// }

// // ✅ MODIFIED: API fetch method remains same but with better logging
// Future<List<NewsChannel>> _fetchChannelsFromAPI() async {
//   try {
//     final prefs = await SharedPreferences.getInstance();
//     String authKey = prefs.getString('auth_key') ?? '';

//     print('🌐 Fetching channels from API for category: ${widget.apiCategory}');

//     final response = await https.get(
//       Uri.parse('https://acomtv.coretechinfo.com/public/api/getFeaturedLiveTV'),
//       headers: {'auth-key': authKey},
//     );

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);

//       if (widget.apiCategory == 'All') {
//         List<NewsChannel> allChannels = [];
//         data.forEach((categoryName, channelsData) {
//           if (channelsData is List) {
//             allChannels.addAll(channelsData
//                 .map((item) => NewsChannel.fromJson(item))
//                 .toList());
//           }
//         });
//         final activeChannels = _filterActiveChannels(allChannels);
//         print('✅ API fetched ${activeChannels.length} active channels (All categories)');
//         return activeChannels;
//       } else if (data.containsKey(widget.apiCategory)) {
//         final List<dynamic> channelsData = data[widget.apiCategory];
//         final allChannels = channelsData.map((item) => NewsChannel.fromJson(item)).toList();
//         final activeChannels = _filterActiveChannels(allChannels);
//         print('✅ API fetched ${activeChannels.length} active channels (${widget.apiCategory})');
//         return activeChannels;
//       }
//     } else {
//       print('❌ API error: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('❌ API fetch error: $e');
//   }

//   return [];
// }

// // ✅ SIMPLIFIED: Display channels fetch now just calls the API method
// Future<void> _fetchDisplayChannels() async {
//   if (!mounted) return;

//   setState(() {
//     _isLoading = true;
//     _errorMessage = '';
//   });

//   try {
//     final freshData = await _fetchChannelsFromAPI();

//     if (freshData.isNotEmpty) {
//       // Save to cache
//       await _saveToCache(freshData);

//       if (mounted) {
//         setState(() {
//           totalActiveChannelsCount = freshData.length;
//           displayChannelsList = freshData.take(7).toList();
//           _initializeChannelFocusNodes();
//           _isLoading = false;
//         });

//         _headerAnimationController.forward();
//         _listAnimationController.forward();
//       }
//     } else {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           // Don't show error message if we already have cached data
//           if (displayChannelsList.isEmpty) {
//             _errorMessage = 'No ${widget.apiCategory} channels found';
//           }
//         });
//       }
//     }
//   } catch (e) {
//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//         // Don't show error message if we already have cached data
//         if (displayChannelsList.isEmpty) {
//           _errorMessage = 'Network error: Please check connection';
//         }
//       });
//     }
//   }
// }

// // ✅ NEW: Method to manually refresh data (can be called from pull-to-refresh)
// Future<void> _refreshData() async {
//   try {
//     final freshData = await _fetchChannelsFromAPI();
    
//     if (freshData.isNotEmpty) {
//       await _saveToCache(freshData);
      
//       if (mounted) {
//         setState(() {
//           displayChannelsList = freshData.take(7).toList();
//           totalActiveChannelsCount = freshData.length;
//           _initializeChannelFocusNodes();
//         });
//       }
      
//       print('✅ Manual refresh completed');
//     }
//   } catch (e) {
//     print('❌ Manual refresh error: $e');
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to refresh data'),
//           backgroundColor: ProfessionalColors.accentRed,
//         ),
//       );
//     }
//   }
// }

// // ✅ ENHANCED: Better disposal with proper cleanup
// @override
// void dispose() {
//   _backgroundFetchTimer?.cancel();
//   _isBackgroundFetching = false;
  
//   print('🧹 Disposing ${widget.displayTitle} channels widget');
  
//   _headerAnimationController.dispose();
//   _listAnimationController.dispose();

//   for (var entry in channelFocusNodes.entries) {
//     try {
//       entry.value.removeListener(() {});
//       entry.value.dispose();
//     } catch (e) {}
//   }
//   channelFocusNodes.clear();

//   try {
//     _viewAllFocusNode?.removeListener(() {});
//     _viewAllFocusNode?.dispose();
//   } catch (e) {}

//   try {
//     _scrollController.dispose();
//   } catch (e) {}

//   _isNavigating = false;
//   super.dispose();
// }



//   // @override
//   // void initState() {
//   //   super.initState();
//   //   _cacheKey = 'live_channels_${widget.apiCategory}';
//   //   _initializeAnimations();
//   //   _initializeViewAllFocusNode();
//   //   _setupFocusProvider();
//   //   // _fetchDisplayChannels(); // ✅ Fetch only display channels initially
//   //   _loadInitialData(); // Changed from _fetchDisplayChannels
//   //   _startBackgroundFetching();
//   // }

//   // void _startBackgroundFetching() {
//   //   // Cancel any existing timer
//   //   _backgroundFetchTimer?.cancel();

//   //   // Start new timer that runs every 30 seconds
//   //   _backgroundFetchTimer = Timer.periodic(Duration(seconds: 30), (timer) {
//   //     if (!mounted) {
//   //       timer.cancel();
//   //       return;
//   //     }
//   //     _fetchDataInBackground();
//   //   });

//   //   // Also fetch immediately
//   //   _fetchDataInBackground();
//   // }

//   // Future<void> _loadInitialData() async {
//   //   // Try to load from cache first
//   //   final cachedData = await _loadFromCache();

//   //   if (cachedData != null && cachedData.isNotEmpty) {
//   //     if (mounted) {
//   //       setState(() {
//   //         displayChannelsList = cachedData.take(7).toList();
//   //         totalActiveChannelsCount = cachedData.length;
//   //         _initializeChannelFocusNodes();
//   //         _isLoading = false;
//   //       });
//   //       _headerAnimationController.forward();
//   //       _listAnimationController.forward();
//   //     }
//   //   }

//   //   // Always fetch fresh data (will update cache if needed)
//   //   await _fetchDisplayChannels();
//   // }

//   // Future<List<NewsChannel>?> _loadFromCache() async {
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final cachedString = prefs.getString(_cacheKey);

//   //     if (cachedString != null) {
//   //       final cachedList = jsonDecode(cachedString) as List;
//   //       return cachedList.map((item) => NewsChannel.fromJson(item)).toList();
//   //     }
//   //   } catch (e) {
//   //     print('Error loading from cache: $e');
//   //   }
//   //   return null;
//   // }

//   // Future<void> _saveToCache(List<NewsChannel> channels) async {
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final jsonList = channels.map((channel) => channel.toJson()).toList();
//   //     await prefs.setString(_cacheKey, jsonEncode(jsonList));
//   //   } catch (e) {
//   //     print('Error saving to cache: $e');
//   //   }
//   // }

//   Future<void> _fetchDataInBackground() async {
//     if (_isBackgroundFetching || !mounted) return;

//     _isBackgroundFetching = true;
//     try {
//       final freshData = await _fetchChannelsFromAPI();
//       final cachedData = await _loadFromCache();

//       // Compare fresh data with cached data
//       if (cachedData == null || !_areChannelListsEqual(cachedData, freshData)) {
//         // Update cache
//         await _saveToCache(freshData);

//         // Update UI if needed
//         if (mounted) {
//           setState(() {
//             // displayChannelsList = freshData.take(7).toList();
//             totalActiveChannelsCount = freshData.length;
//             _initializeChannelFocusNodes();
//           });
//         }
//       }
//     } catch (e) {
//       print('Background fetch error: $e');
//     } finally {
//       _isBackgroundFetching = false;
//     }
//   }

//   // bool _areChannelListsEqual(List<NewsChannel> list1, List<NewsChannel> list2) {
//   //   if (list1.length != list2.length) return false;

//   //   for (int i = 0; i < list1.length; i++) {
//   //     if (list1[i].id != list2[i].id ||
//   //         list1[i].url != list2[i].url ||
//   //         list1[i].status != list2[i].status) {
//   //       return false;
//   //     }
//   //   }

//   //   return true;
//   // }

//   // Future<List<NewsChannel>> _fetchChannelsFromAPI() async {
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     String authKey = prefs.getString('auth_key') ?? '';

//   //     final response = await https.get(
//   //       Uri.parse(
//   //           'https://acomtv.coretechinfo.com/public/api/getFeaturedLiveTV'),
//   //       headers: {'auth-key': authKey},
//   //     );

//   //     if (response.statusCode == 200) {
//   //       final Map<String, dynamic> data = json.decode(response.body);

//   //       if (widget.apiCategory == 'All') {
//   //         List<NewsChannel> allChannels = [];
//   //         data.forEach((categoryName, channelsData) {
//   //           if (channelsData is List) {
//   //             allChannels.addAll(channelsData
//   //                 .map((item) => NewsChannel.fromJson(item))
//   //                 .toList());
//   //           }
//   //         });
//   //         return _filterActiveChannels(allChannels);
//   //       } else if (data.containsKey(widget.apiCategory)) {
//   //         final List<dynamic> channelsData = data[widget.apiCategory];
//   //         return _filterActiveChannels(
//   //             channelsData.map((item) => NewsChannel.fromJson(item)).toList());
//   //       }
//   //     }
//   //   } catch (e) {
//   //     print('API fetch error: $e');
//   //   }

//   //   return [];
//   // }

//   // // Modify existing _fetchDisplayChannels to use _fetchChannelsFromAPI
//   // Future<void> _fetchDisplayChannels() async {
//   //   if (!mounted) return;

//   //   setState(() {
//   //     _isLoading = true;
//   //     _errorMessage = '';
//   //   });

//   //   try {
//   //     final freshData = await _fetchChannelsFromAPI();

//   //     if (freshData.isNotEmpty) {
//   //       // Save to cache
//   //       await _saveToCache(freshData);

//   //       if (mounted) {
//   //         setState(() {
//   //           totalActiveChannelsCount = freshData.length;
//   //           displayChannelsList = freshData.take(7).toList();
//   //           _initializeChannelFocusNodes();
//   //           _isLoading = false;
//   //         });

//   //         _headerAnimationController.forward();
//   //         _listAnimationController.forward();
//   //       }
//   //     } else {
//   //       if (mounted) {
//   //         setState(() {
//   //           // _errorMessage = 'No ${widget.apiCategory} channels found';
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

//   // @override
//   // void dispose() {
//   //   _backgroundFetchTimer?.cancel();
//   //   _isBackgroundFetching = false;
//   //   _headerAnimationController.dispose();
//   //   _listAnimationController.dispose();

//   //   for (var entry in channelFocusNodes.entries) {
//   //     try {
//   //       entry.value.removeListener(() {});
//   //       entry.value.dispose();
//   //     } catch (e) {}
//   //   }
//   //   channelFocusNodes.clear();

//   //   try {
//   //     _viewAllFocusNode?.removeListener(() {});
//   //     _viewAllFocusNode?.dispose();
//   //   } catch (e) {}

//   //   try {
//   //     _scrollController.dispose();
//   //   } catch (e) {}

//   //   _isNavigating = false;
//   //   super.dispose();
//   // }

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

//           // ✅ GENERIC: Register with navigation index for all pages
//           focusProvider.registerGenericChannelFocus(
//               widget.navigationIndex, _scrollController, widget.focusNode);

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

//   // ✅ NEW: Filter only active channels (status = 1)
//   List<NewsChannel> _filterActiveChannels(List<NewsChannel> channels) {
//     return channels.where((channel) => channel.status == 1).toList();
//   }

//   // // ✅ NEW: Fetch only 7 ACTIVE channels for display (Fast loading)
//   // Future<void> _fetchDisplayChannels() async {
//   //   if (!mounted) return;

//   //   setState(() {
//   //     _isLoading = true;
//   //     _errorMessage = '';
//   //   });

//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     String authKey = prefs.getString('auth_key') ?? '';

//   //     final response = await https.get(
//   //       Uri.parse('https://acomtv.coretechinfo.com/public/api/getFeaturedLiveTV'),
//   //       headers: {'auth-key': authKey},
//   //     );

//   //     if (response.statusCode == 200) {
//   //       final Map<String, dynamic> data = json.decode(response.body);

//   //       // ✅ NEW: Handle different category types with status filtering
//   //       if (widget.apiCategory == 'All') {
//   //         // Combine all channels from all categories
//   //         List<NewsChannel> allChannels = [];

//   //         data.forEach((categoryName, channelsData) {
//   //           if (channelsData is List) {
//   //             List<NewsChannel> categoryChannels = channelsData
//   //                 .map((item) => NewsChannel.fromJson(item))
//   //                 .toList();
//   //             allChannels.addAll(categoryChannels);
//   //           }
//   //         });

//   //         // ✅ FILTER: Only active channels (status = 1)
//   //         List<NewsChannel> activeChannels = _filterActiveChannels(allChannels);

//   //         if (mounted) {
//   //           setState(() {
//   //             totalActiveChannelsCount = activeChannels.length;
//   //             // ✅ OPTIMIZED: Only take first 7 ACTIVE channels for display
//   //             displayChannelsList = activeChannels.take(7).toList();
//   //             _initializeChannelFocusNodes();
//   //             _isLoading = false;
//   //           });

//   //           _headerAnimationController.forward();
//   //           _listAnimationController.forward();
//   //         }
//   //       }
//   //       // ✅ EXISTING: Category-specific channels with status filtering
//   //       else if (data.containsKey(widget.apiCategory)) {
//   //         final List<dynamic> channelsData = data[widget.apiCategory];

//   //         List<NewsChannel> allChannels = channelsData
//   //             .map((item) => NewsChannel.fromJson(item))
//   //             .toList();

//   //         // ✅ FILTER: Only active channels (status = 1)
//   //         List<NewsChannel> activeChannels = _filterActiveChannels(allChannels);

//   //         if (mounted) {
//   //           setState(() {
//   //             totalActiveChannelsCount = activeChannels.length;
//   //             // ✅ OPTIMIZED: Only take first 7 ACTIVE channels for display
//   //             displayChannelsList = activeChannels.take(7).toList();
//   //             _initializeChannelFocusNodes();
//   //             _isLoading = false;
//   //           });

//   //           _headerAnimationController.forward();
//   //           _listAnimationController.forward();
//   //         }
//   //       } else {
//   //         if (mounted) {
//   //           setState(() {
//   //             _errorMessage = 'No ${widget.apiCategory} channels found';
//   //             _isLoading = false;
//   //           });
//   //         }
//   //       }
//   //     } else {
//   //       if (mounted) {
//   //         setState(() {
//   //           _errorMessage = 'Failed to load channels (${response.statusCode})';
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

//   // ✅ NEW: Fetch full ACTIVE channels list when needed (for grid view)
//   Future<void> _fetchFullChannelsList() async {
//     if (!mounted || _isLoadingFullList || fullChannelsList.isNotEmpty) return;

//     setState(() {
//       _isLoadingFullList = true;
//     });

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String authKey = prefs.getString('auth_key') ?? '';

//       final response = await https.get(
//         Uri.parse(
//             'https://acomtv.coretechinfo.com/public/api/getFeaturedLiveTV'),
//         headers: {'auth-key': authKey},
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);

//         if (widget.apiCategory == 'All') {
//           // Combine all channels from all categories
//           List<NewsChannel> allChannels = [];

//           data.forEach((categoryName, channelsData) {
//             if (channelsData is List) {
//               List<NewsChannel> categoryChannels = channelsData
//                   .map((item) => NewsChannel.fromJson(item))
//                   .toList();
//               allChannels.addAll(categoryChannels);
//             }
//           });

//           // ✅ FILTER: Only active channels (status = 1)
//           List<NewsChannel> activeChannels = _filterActiveChannels(allChannels);

//           if (mounted) {
//             setState(() {
//               fullChannelsList = activeChannels;
//               _isLoadingFullList = false;
//             });
//           }
//         } else if (data.containsKey(widget.apiCategory)) {
//           final List<dynamic> channelsData = data[widget.apiCategory];

//           List<NewsChannel> allChannels =
//               channelsData.map((item) => NewsChannel.fromJson(item)).toList();

//           // ✅ FILTER: Only active channels (status = 1)
//           List<NewsChannel> activeChannels = _filterActiveChannels(allChannels);

//           if (mounted) {
//             setState(() {
//               fullChannelsList = activeChannels;
//               _isLoadingFullList = false;
//             });
//           }
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoadingFullList = false;
//         });
//       }
//     }
//   }

//   void _initializeChannelFocusNodes() {
//     // Clear existing focus nodes
//     for (var node in channelFocusNodes.values) {
//       try {
//         node.removeListener(() {});
//         node.dispose();
//       } catch (e) {}
//     }
//     channelFocusNodes.clear();

//     // ✅ OPTIMIZED: Create focus nodes only for display channels
//     for (var channel in displayChannelsList) {
//       try {
//         String channelId = channel.id.toString();
//         channelFocusNodes[channelId] = FocusNode()
//           ..addListener(() {
//             if (mounted && channelFocusNodes[channelId]!.hasFocus) {
//               _scrollToFocusedItem(channelId);
//             }
//           });
//       } catch (e) {
//         // Silent error handling
//       }
//     }

//     // Register with focus provider
//     _registerChannelsFocus();
//   }

//   void _registerChannelsFocus() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && displayChannelsList.isNotEmpty) {
//         try {
//           final focusProvider =
//               Provider.of<FocusProvider>(context, listen: false);

//           // Register first channel with focus provider using generic method
//           final firstChannelId = displayChannelsList[0].id.toString();
//           if (channelFocusNodes.containsKey(firstChannelId)) {
//             focusProvider.registerGenericChannelFocus(widget.navigationIndex,
//                 _scrollController, channelFocusNodes[firstChannelId]!);
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
//   //     final focusNode = channelFocusNodes[itemId];
//   //     if (focusNode != null &&
//   //         focusNode.hasFocus &&
//   //         focusNode.context != null) {
//   //       Scrollable.ensureVisible(
//   //         focusNode.context!,
//   //         alignment: 0.02,
//   //         duration: AnimationTiming.scroll,
//   //         curve: Curves.easeInOutCubic,
//   //       );
//   //     }
//   //   } catch (e) {}
//   // }


//   void _scrollToFocusedItem(String itemId) {
//   if (!mounted) return;

//   try {
//     // Find the index of the focused item
//     int focusedIndex = displayChannelsList.indexWhere((channel) => channel.id.toString() == itemId);
    
//     if (focusedIndex != -1) {
//       // Calculate horizontal offset for the focused item
//       final double itemWidth = bannerwdt; // Same as your card width
//       final double itemMargin = 12.0; // Horizontal margin between items
//       final double targetOffset = focusedIndex * (itemWidth + itemMargin);
      
//       // Animate to specific horizontal position
//       _scrollController.animateTo(
//         targetOffset,
//         duration: AnimationTiming.scroll,
//         curve: Curves.easeInOutCubic,
//       );
      
//       print('🎯 Horizontal scroll to index $focusedIndex: ${displayChannelsList[focusedIndex].name}');
//     }
//   } catch (e) {
//     print('❌ Horizontal scroll error: $e');
//   }
// }

//   // ✅ OPTIMIZED: Convert display channels to NewsItemModel
//   List<NewsItemModel> _convertDisplayChannelsToNewsItems() {
//     return displayChannelsList.map((channel) {
//       String categoryName = widget.apiCategory == 'All'
//           ? (channel.genres.toLowerCase().isNotEmpty
//               ? channel.genres.toLowerCase()
//               : 'live')
//           : widget.apiCategory.toLowerCase();

//       return NewsItemModel(
//         id: channel.id.toString(),
//         videoId: '',
//         name: channel.name,
//         description: channel.description ?? '',
//         banner: channel.banner,
//         poster: channel.banner,
//         category: categoryName,
//         url: channel.url,
//         streamType: channel.streamType,
//         type: channel.streamType,
//         genres: channel.genres,
//         status: channel.status.toString(),
//         index: displayChannelsList.indexOf(channel).toString(),
//         image: channel.banner,
//         unUpdatedUrl: channel.url,
//       );
//     }).toList();
//   }

//   // ✅ NEW: Convert full channels to NewsItemModel (for grid view)
//   List<NewsItemModel> _convertFullChannelsToNewsItems() {
//     return fullChannelsList.map((channel) {
//       String categoryName = widget.apiCategory == 'All'
//           ? (channel.genres.toLowerCase().isNotEmpty
//               ? channel.genres.toLowerCase()
//               : 'live')
//           : widget.apiCategory.toLowerCase();

//       return NewsItemModel(
//         id: channel.id.toString(),
//         videoId: '',
//         name: channel.name,
//         description: channel.description ?? '',
//         banner: channel.banner,
//         poster: channel.banner,
//         category: categoryName,
//         url: channel.url,
//         streamType: channel.streamType,
//         type: channel.streamType,
//         genres: channel.genres,
//         status: channel.status.toString(),
//         index: fullChannelsList.indexOf(channel).toString(),
//         image: channel.banner,
//         unUpdatedUrl: channel.url,
//       );
//     }).toList();
//   }

//   // ✅ OPTIMIZED: Handle channel tap with display channels
//   Future<void> _handleChannelTap(NewsChannel channel) async {
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
//                       'Loading channel...',
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

//     Timer(Duration(seconds: 10), () {
//       _isNavigating = false;
//     });

//     try {
//       String categoryName = widget.apiCategory == 'All'
//           ? (channel.genres.toLowerCase().isNotEmpty
//               ? channel.genres.toLowerCase()
//               : 'live')
//           : widget.apiCategory.toLowerCase();

//       // Current channel ko NewsItemModel में convert करें
//       NewsItemModel currentChannel = NewsItemModel(
//         id: channel.id.toString(),
//         videoId: '',
//         name: channel.name,
//         description: channel.description ?? '',
//         banner: channel.banner,
//         poster: channel.banner,
//         category: categoryName,
//         url: channel.url,
//         streamType: channel.streamType,
//         type: channel.streamType,
//         genres: channel.genres,
//         status: channel.status.toString(),
//         index: displayChannelsList.indexOf(channel).toString(),
//         image: channel.banner,
//         unUpdatedUrl: channel.url,
//       );

//       // ✅ OPTIMIZED: Use display channels for navigation
//       List<NewsItemModel> allChannels = _convertDisplayChannelsToNewsItems();

//       if (dialogShown) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }

//       bool liveStatus = true;

//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => VideoScreen(
//             videoUrl: currentChannel.url,
//             bannerImageUrl: currentChannel.banner,
//             startAtPosition: Duration.zero,
//             videoType: currentChannel.streamType,
//             channelList: allChannels,
//             isLive: true,
//             isVOD: false,
//             isBannerSlider: false,
//             source: 'isLiveScreen',
//             isSearch: false,
//             videoId: int.tryParse(currentChannel.id),
//             unUpdatedUrl: currentChannel.url,
//             name: currentChannel.name,
//             // seasonId: null,
//             // isLastPlayedStored: false,
//             liveStatus: liveStatus,
//           ),
//         ),
//       );
//     } catch (e) {
//       if (dialogShown) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Something Went Wrong')),
//       );
//     } finally {
//       _isNavigating = false;
//     }
//   }

//   // ✅ OPTIMIZED: Navigate to grid view and fetch full list if needed
//   void _navigateToChannelsGrid() async {
//     if (!_isNavigating && mounted) {
//       // ✅ Fetch full channels list if not already loaded
//       if (fullChannelsList.isEmpty) {
//         await _fetchFullChannelsList();
//       }

//       if (mounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ProfessionalChannelsGridView(
//               channelsList: fullChannelsList.isNotEmpty
//                   ? fullChannelsList
//                   : displayChannelsList,
//               categoryTitle: widget.displayTitle,
//               categoryName: widget.apiCategory,
//             ),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Consumer<ColorProvider>(
//       builder: (context, colorProv, child) {
//         final bgColor = colorProv.isItemFocused
//             ? colorProv.dominantColor.withOpacity(0.1)
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
//                   ProfessionalColors.primaryDark,
//                   ProfessionalColors.surfaceDark.withOpacity(0.5),
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
//             // ✅ OPTIMIZED: Show total ACTIVE channels count
//             if (totalActiveChannelsCount > 0)
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       ProfessionalColors.accentBlue.withOpacity(0.2),
//                       ProfessionalColors.accentPurple.withOpacity(0.2),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: ProfessionalColors.accentBlue.withOpacity(0.3),
//                     width: 1,
//                   ),
//                 ),
//                 child: Text(
//                   '${totalActiveChannelsCount} Live Channels',
//                   style: const TextStyle(
//                     color: ProfessionalColors.textSecondary,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBody(double screenWidth, double screenHeight) {
//     if (_isLoading) {
//       return ProfessionalLoadingIndicator(
//           message: 'Loading ${widget.displayTitle} Channels...');
//     } else if (_errorMessage.isNotEmpty) {
//       return _buildErrorWidget();
//     } else if (displayChannelsList.isEmpty) {
//       return _buildEmptyWidget();
//     } else {
//       return _buildChannelsList(screenWidth, screenHeight);
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
//             onPressed:
//                 _fetchDisplayChannels, // ✅ CHANGED: Fetch display channels
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
//               Icons.tv_outlined,
//               size: 40,
//               color: ProfessionalColors.accentBlue,
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'No Live ${widget.displayTitle} Channels',
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

//   Widget _buildChannelsList(double screenWidth, double screenHeight) {
//     // ✅ OPTIMIZED: Show ViewAll only if total ACTIVE channels > 7
//     bool showViewAll = totalActiveChannelsCount > 7;

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
//           // ✅ OPTIMIZED: Always show exactly 7 channels + ViewAll if needed
//           itemCount: showViewAll ? 8 : displayChannelsList.length,
//           itemBuilder: (context, index) {
//             if (showViewAll && index == 7) {
//               return Focus(
//                 focusNode: _viewAllFocusNode,
//                 onFocusChange: (hasFocus) {
//                   if (hasFocus && mounted) {
//                     Color viewAllColor = ProfessionalColors.gradientColors[
//                         math.Random()
//                             .nextInt(ProfessionalColors.gradientColors.length)];

//                     try {
//                       context
//                           .read<ColorProvider>()
//                           .updateColor(viewAllColor, true);
//                     } catch (e) {
//                       print('ViewAll color update failed: $e');
//                     }
//                   } else if (mounted) {
//                     try {
//                       context.read<ColorProvider>().resetColor();
//                     } catch (e) {
//                       print('ViewAll color reset failed: $e');
//                     }
//                   }
//                 },
//                 onKey: (FocusNode node, RawKeyEvent event) {
//                   if (event is RawKeyDownEvent) {
//                     if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey ==
//                         LogicalKeyboardKey.arrowLeft) {
//                       if (displayChannelsList.isNotEmpty &&
//                           displayChannelsList.length > 6) {
//                         String channelId = displayChannelsList[6].id.toString();
//                         FocusScope.of(context)
//                             .requestFocus(channelFocusNodes[channelId]);
//                         return KeyEventResult.handled;
//                       }
//                     } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                       // ✅ GENERIC: Navigate to corresponding navigation button
//                       try {
//                         context
//                             .read<FocusProvider>()
//                             .requestNavigationFocus(widget.navigationIndex);
//                         print(
//                             '🎯 ViewAll -> ${widget.displayTitle} navigation button');
//                       } catch (e) {
//                         print('❌ ViewAll navigation failed: $e');
//                       }
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey ==
//                         LogicalKeyboardKey.arrowDown) {
//                       // Navigate to next section
//                       FocusScope.of(context).unfocus();
//                       Future.delayed(const Duration(milliseconds: 50), () {
//                         if (mounted) {
//                           try {
//                             // context
//                             //     .read<FocusProvider>()
//                             //     .requestFirstSubVodFocus();

//                             context
//                                 .read<FocusProvider>()
//                                 .requestFirstHorizontalListNetworksFocus();
//                           } catch (e) {
//                             print('Next section focus request failed: $e');
//                           }
//                         }
//                       });
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey == LogicalKeyboardKey.select) {
//                       _navigateToChannelsGrid();
//                       return KeyEventResult.handled;
//                     }
//                   }
//                   return KeyEventResult.ignored;
//                 },
//                 child: GestureDetector(
//                   onTap: _navigateToChannelsGrid,
//                   child: ProfessionalViewAllButton(
//                     focusNode: _viewAllFocusNode!,
//                     onTap: _navigateToChannelsGrid,
//                     totalChannels:
//                         totalActiveChannelsCount, // ✅ Show total ACTIVE channels
//                   ),
//                 ),
//               );
//             }

//             var channel = displayChannelsList[index];
//             return _buildChannelItem(channel, index, screenWidth, screenHeight);
//           },
//         ),
//       ),
//     );
//   }

//   // ✅ Build channel item with dynamic navigation
//   Widget _buildChannelItem(
//       NewsChannel channel, int index, double screenWidth, double screenHeight) {
//     String channelId = channel.id.toString();

//     channelFocusNodes.putIfAbsent(
//       channelId,
//       () => FocusNode()
//         ..addListener(() {
//           if (mounted && channelFocusNodes[channelId]!.hasFocus) {
//             _scrollToFocusedItem(channelId);
//           }
//         }),
//     );

//     return Focus(
//       focusNode: channelFocusNodes[channelId],
//       onFocusChange: (hasFocus) async {
//         if (hasFocus && mounted) {
//           try {
//             // ✅ ENHANCED: Generate dynamic color for background
//             Color dominantColor = ProfessionalColors.gradientColors[
//                 math.Random()
//                     .nextInt(ProfessionalColors.gradientColors.length)];

//             // ✅ ENHANCED: Update background color when channel focused
//             try {
//               context.read<ColorProvider>().updateColor(dominantColor, true);
//             } catch (e) {
//               print('Color provider update failed: $e');
//             }

//             widget.onFocusChange?.call(true);
//           } catch (e) {
//             print('Focus change handling failed: $e');
//           }
//         } else if (mounted) {
//           try {
//             // ✅ ENHANCED: Reset background when unfocused
//             context.read<ColorProvider>().resetColor();
//           } catch (e) {
//             print('Color reset failed: $e');
//           }
//           widget.onFocusChange?.call(false);
//         }
//       },
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//             if (index < displayChannelsList.length - 1 && index != 6) {
//               String nextChannelId =
//                   displayChannelsList[index + 1].id.toString();
//               FocusScope.of(context)
//                   .requestFocus(channelFocusNodes[nextChannelId]);
//               return KeyEventResult.handled;
//             } else if (index == 6 && totalActiveChannelsCount > 7) {
//               FocusScope.of(context).requestFocus(_viewAllFocusNode);
//               return KeyEventResult.handled;
//             }
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//             if (index > 0) {
//               String prevChannelId =
//                   displayChannelsList[index - 1].id.toString();
//               FocusScope.of(context)
//                   .requestFocus(channelFocusNodes[prevChannelId]);
//               return KeyEventResult.handled;
//             }
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//             // ✅ GENERIC: Navigate to corresponding navigation button
//             try {
//               context
//                   .read<FocusProvider>()
//                   .requestNavigationFocus(widget.navigationIndex);
//               print(
//                   '🎯 ${widget.displayTitle} channel -> navigation button (index: ${widget.navigationIndex})');
//             } catch (e) {
//               print('❌ Navigation focus failed: $e');
//             }
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//             // Navigate to next section
//             FocusScope.of(context).unfocus();
//             Future.delayed(const Duration(milliseconds: 50), () {
//               if (mounted) {
//                 try {
//                   // context.read<FocusProvider>().requestSubVodFocus();
//                   // context.read<FocusProvider>().requestFirstSubVodFocus();
//                   context
//                                 .read<FocusProvider>()
//                                 .requestFirstHorizontalListNetworksFocus();
//                 } catch (e) {
//                   print('Next section focus request failed: $e');
//                 }
//               }
//             });
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.select) {
//             _handleChannelTap(channel);
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: () => _handleChannelTap(channel),
//         child: ProfessionalChannelCard(
//           channel: channel,
//           focusNode: channelFocusNodes[channelId]!,
//           onTap: () => _handleChannelTap(channel),
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

// // ✅ PROFESSIONAL CHANNEL CARD - Generic for all categories
// class ProfessionalChannelCard extends StatefulWidget {
//   final NewsChannel channel;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final Function(Color) onColorChange;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalChannelCard({
//     Key? key,
//     required this.channel,
//     required this.focusNode,
//     required this.onTap,
//     required this.onColorChange,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalChannelCardState createState() =>
//       _ProfessionalChannelCardState();
// }

// class _ProfessionalChannelCardState extends State<ProfessionalChannelCard>
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
//             _buildChannelImage(screenWidth, posterHeight),
//             if (_isFocused) _buildFocusBorder(),
//             if (_isFocused) _buildShimmerEffect(),
//             _buildStatusBadge(),
//             if (_isFocused) _buildHoverOverlay(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildChannelImage(double screenWidth, double posterHeight) {
//     return Container(
//       width: double.infinity,
//       height: posterHeight,
//       child: widget.channel.banner.isNotEmpty
//           ? Image.network(
//               widget.channel.banner,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) =>
//                   _buildImagePlaceholder(posterHeight),
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return _buildImagePlaceholder(posterHeight);
//               },
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
//               color: ProfessionalColors.accentGreen
//                   .withOpacity(0.2), // ✅ Always green for LIVE
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Text(
//               'LIVE',
//               style: TextStyle(
//                 color:
//                     ProfessionalColors.accentGreen, // ✅ Always green for LIVE
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

//   Widget _buildStatusBadge() {
//     return Positioned(
//       top: 8,
//       right: 8,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//         decoration: BoxDecoration(
//           // ✅ Since we only show status=1 channels, always show as LIVE/GREEN
//           color: ProfessionalColors.accentGreen.withOpacity(0.9),
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 6,
//               height: 6,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(width: 4),
//             const Text(
//               'LIVE', // ✅ Always show LIVE since status=1
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 8,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
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
//     final channelName = widget.channel.name.toUpperCase();

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
//           channelName,
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }

// // ✅ PROFESSIONAL VIEW ALL BUTTON
// class ProfessionalViewAllButton extends StatefulWidget {
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int totalChannels;

//   const ProfessionalViewAllButton({
//     Key? key,
//     required this.focusNode,
//     required this.onTap,
//     required this.totalChannels,
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
//                     height:
//                         _isFocused ? screenHeight * 0.28 : screenHeight * 0.22,
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
//                     '${widget.totalChannels}',
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
//       child: const Text(
//         'ALL CHANNELS',
//         textAlign: TextAlign.center,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//       ),
//     );
//   }
// }

// // ✅ PROFESSIONAL LOADING INDICATOR
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





// // // ✅ PROFESSIONAL CHANNELS GRID VIEW WITH STATUS FILTERING
// // class ProfessionalChannelsGridView extends StatefulWidget {
// //   final List<NewsChannel> channelsList;
// //   final String categoryTitle;
// //   final String categoryName;

// //   const ProfessionalChannelsGridView({
// //     Key? key,
// //     required this.channelsList,
// //     required this.categoryTitle,
// //     required this.categoryName,
// //   }) : super(key: key);

// //   @override
// //   _ProfessionalChannelsGridViewState createState() =>
// //       _ProfessionalChannelsGridViewState();
// // }

// // class _ProfessionalChannelsGridViewState
// //     extends State<ProfessionalChannelsGridView> with TickerProviderStateMixin {
// //   late Map<String, FocusNode> _channelFocusNodes;
// //   bool _isLoading = false;

// //   // Animation Controllers
// //   late AnimationController _fadeController;
// //   late AnimationController _staggerController;
// //   late Animation<double> _fadeAnimation;

// //   @override
// //   void initState() {
// //     super.initState();

// //     // ✅ NEW: Filter active channels in grid view too
// //     List<NewsChannel> activeChannels =
// //         widget.channelsList.where((channel) => channel.status == 1).toList();

// //     _channelFocusNodes = {
// //       for (var channel in activeChannels) channel.id.toString(): FocusNode()
// //     };

// //     // Set up focus for the first channel
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (activeChannels.isNotEmpty) {
// //         final firstChannelId = activeChannels[0].id.toString();
// //         if (_channelFocusNodes.containsKey(firstChannelId)) {
// //           FocusScope.of(context)
// //               .requestFocus(_channelFocusNodes[firstChannelId]);
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

// //   // ✅ UPDATED: Grid view handle channel tap with status filtering
// //   Future<void> _handleGridChannelTap(NewsChannel channel) async {
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
// //                         'Loading Channel...',
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

// //       // ✅ NEW: Dynamic category assignment for grid view too
// //       String categoryName = widget.categoryName == 'All'
// //           ? (channel.genres.toLowerCase().isNotEmpty
// //               ? channel.genres.toLowerCase()
// //               : 'live')
// //           : widget.categoryName.toLowerCase();

// //       // ✅ Filter active channels for navigation
// //       List<NewsChannel> activeChannels =
// //           widget.channelsList.where((ch) => ch.status == 1).toList();

// //       // Current channel ko NewsItemModel में convert करें
// //       NewsItemModel currentChannel = NewsItemModel(
// //         id: channel.id.toString(),
// //         videoId: '',
// //         name: channel.name,
// //         description: channel.description ?? '',
// //         banner: channel.banner,
// //         poster: channel.banner,
// //         category: categoryName, // ✅ CHANGED: Dynamic category
// //         url: channel.url,
// //         streamType: channel.streamType,
// //         type: channel.streamType,
// //         genres: channel.genres,
// //         status: channel.status.toString(),
// //         index: activeChannels.indexOf(channel).toString(),
// //         image: channel.banner,
// //         unUpdatedUrl: channel.url,
// //       );

// //       // ✅ Sabhi ACTIVE channels को convert करें
// //       List<NewsItemModel> allChannels = activeChannels.map((ch) {
// //         String chCategoryName = widget.categoryName == 'All'
// //             ? (ch.genres.toLowerCase().isNotEmpty
// //                 ? ch.genres.toLowerCase()
// //                 : 'live')
// //             : widget.categoryName.toLowerCase();

// //         return NewsItemModel(
// //           id: ch.id.toString(),
// //           videoId: '',
// //           name: ch.name,
// //           description: ch.description ?? '',
// //           banner: ch.banner,
// //           poster: ch.banner,
// //           category: chCategoryName, // ✅ CHANGED: Dynamic category
// //           url: ch.url,
// //           streamType: ch.streamType,
// //           type: ch.streamType,
// //           genres: ch.genres,
// //           status: ch.status.toString(),
// //           index: activeChannels.indexOf(ch).toString(),
// //           image: ch.banner,
// //           unUpdatedUrl: ch.url,
// //         );
// //       }).toList();

// //       if (mounted) {
// //         if (dialogShown) {
// //           Navigator.of(context, rootNavigator: true).pop();
// //         }

// //         // VideoScreen navigate करें with all ACTIVE channels
// //         await Navigator.push(
// //           context,
// //           MaterialPageRoute(
// //             builder: (context) => VideoScreen(
// //               videoUrl: currentChannel.url,
// //               bannerImageUrl: currentChannel.banner,
// //               startAtPosition: Duration.zero,
// //               videoType: currentChannel.streamType,
// //               channelList: allChannels,
// //               isLive: true,
// //               isVOD: false,
// //               isBannerSlider: false,
// //               source: 'isLiveScreen',
// //               isSearch: false,
// //               videoId: int.tryParse(currentChannel.id),
// //               unUpdatedUrl: currentChannel.url,
// //               name: currentChannel.name,
// //               seasonId: null,
// //               isLastPlayedStored: false,
// //               liveStatus: true,
// //             ),
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         if (dialogShown) {
// //           Navigator.of(context, rootNavigator: true).pop();
// //         }
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: const Text('Error loading channel'),
// //             backgroundColor: ProfessionalColors.accentRed,
// //             behavior: SnackBarBehavior.floating,
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(10),
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
// //     for (var node in _channelFocusNodes.values) {
// //       try {
// //         node.dispose();
// //       } catch (e) {}
// //     }
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // ✅ Filter active channels for display
// //     List<NewsChannel> activeChannels =
// //         widget.channelsList.where((channel) => channel.status == 1).toList();

// //     return Consumer<ColorProvider>(
// //       builder: (context, colorProv, child) {
// //         final bgColor = colorProv.isItemFocused
// //             ? colorProv.dominantColor.withOpacity(0.1)
// //             : ProfessionalColors.primaryDark;

// //         return Scaffold(
// //           backgroundColor: ProfessionalColors.primaryDark,
// //           body: Stack(
// //             children: [
// //               // Background Gradient
// //               Container(
// //                 decoration: BoxDecoration(
// //                   gradient: LinearGradient(
// //                     begin: Alignment.topCenter,
// //                     end: Alignment.bottomCenter,
// //                     colors: [
// //                       ProfessionalColors.primaryDark,
// //                       ProfessionalColors.surfaceDark.withOpacity(0.8),
// //                       ProfessionalColors.primaryDark,
// //                     ],
// //                   ),
// //                 ),
// //               ),

// //               // Main Content
// //               FadeTransition(
// //                 opacity: _fadeAnimation,
// //                 child: Column(
// //                   children: [
// //                     _buildProfessionalAppBar(activeChannels.length),
// //                     Expanded(
// //                       child: _buildChannelsGrid(activeChannels),
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //               // Loading Overlay
// //               if (_isLoading)
// //                 Container(
// //                   color: Colors.black.withOpacity(0.7),
// //                   child: const Center(
// //                     child: ProfessionalLoadingIndicator(
// //                         message: 'Loading Channel...'),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildProfessionalAppBar(int activeChannelsCount) {
// //     return Container(
// //       // padding: EdgeInsets.only(
// //       //   top: MediaQuery.of(context).padding.top + 10,
// //       //   left: 20,
// //       //   right: 20,
// //       //   bottom: 20,
// //       // ),
// //       padding: EdgeInsets.only(
// //           left: screenwdt * 0.05,
// //           right: screenwdt * 0.05,
// //           top: screenhgt * 0.02,
// //           bottom: screenhgt * 0.02),

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
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
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
// //               ],
// //             ),
// //           ),
// //           Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// //             decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 colors: [
// //                   ProfessionalColors.accentGreen
// //                       .withOpacity(0.2), // ✅ Green for LIVE
// //                   ProfessionalColors.accentGreen.withOpacity(0.1),
// //                 ],
// //               ),
// //               borderRadius: BorderRadius.circular(15),
// //               border: Border.all(
// //                 color: ProfessionalColors.accentGreen
// //                     .withOpacity(0.3), // ✅ Green for LIVE
// //                 width: 1,
// //               ),
// //             ),
// //             child: Text(
// //               '${activeChannelsCount} Live Channels Available', // ✅ Show only ACTIVE channels
// //               style: const TextStyle(
// //                 color: ProfessionalColors.accentGreen, // ✅ Green text for LIVE
// //                 fontSize: 12,
// //                 fontWeight: FontWeight.w500,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildChannelsGrid(List<NewsChannel> activeChannels) {
// //     if (activeChannels.isEmpty) {
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
// //                 Icons.tv_outlined,
// //                 size: 40,
// //                 color: ProfessionalColors.accentBlue,
// //               ),
// //             ),
// //             const SizedBox(height: 24),
// //             Text(
// //               'No Live ${widget.categoryTitle} Channels',
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
// //       padding: EdgeInsets.only(
// //           left: screenwdt * 0.05,
// //           right: screenwdt * 0.05,
// //           top: screenhgt * 0.02),
// //       child: GridView.builder(
// //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //           crossAxisCount: 6,
// //           mainAxisSpacing: 16,
// //           crossAxisSpacing: 25,
// //           childAspectRatio: 1.5,
// //         ),
// //         itemCount: activeChannels.length, // ✅ Only ACTIVE channels
// //         clipBehavior: Clip.none,
// //         itemBuilder: (context, index) {
// //           final channel = activeChannels[index];
// //           String channelId = channel.id.toString();

// //           return AnimatedBuilder(
// //             animation: _staggerController,
// //             builder: (context, child) {
// //               final delay = (index / activeChannels.length) * 0.5;
// //               final animationValue = Interval(
// //                 delay,
// //                 delay + 0.5,
// //                 curve: Curves.easeOutCubic,
// //               ).transform(_staggerController.value);

// //               return Transform.translate(
// //                 offset: Offset(0, 50 * (1 - animationValue)),
// //                 child: Opacity(
// //                   opacity: animationValue,
// //                   child: ProfessionalGridChannelCard(
// //                     channel: channel,
// //                     focusNode: _channelFocusNodes[channelId]!,
// //                     onTap: () => _handleGridChannelTap(channel),
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




// // ✅ PROFESSIONAL GRID CHANNEL CARD WITH STATUS FILTERING
// class ProfessionalGridChannelCard extends StatefulWidget {
//   final NewsChannel channel;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalGridChannelCard({
//     Key? key,
//     required this.channel,
//     required this.focusNode,
//     required this.onTap,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalGridChannelCardState createState() =>
//       _ProfessionalGridChannelCardState();
// }

// class _ProfessionalGridChannelCardState
//     extends State<ProfessionalGridChannelCard> with TickerProviderStateMixin {
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
//                       _buildChannelImage(),
//                       if (_isFocused) _buildFocusBorder(),
//                       _buildGradientOverlay(),
//                       _buildChannelInfo(),
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

//   Widget _buildChannelImage() {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       child: widget.channel.banner.isNotEmpty
//           ? Image.network(
//               widget.channel.banner,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) =>
//                   _buildImagePlaceholder(),
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return _buildImagePlaceholder();
//               },
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
//                 color: ProfessionalColors.accentGreen
//                     .withOpacity(0.2), // ✅ Always green for LIVE
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: const Text(
//                 'LIVE',
//                 style: TextStyle(
//                   color:
//                       ProfessionalColors.accentGreen, // ✅ Always green for LIVE
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

//   Widget _buildChannelInfo() {
//     final channelName = widget.channel.name;

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
//               channelName.toUpperCase(),
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
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: ProfessionalColors.accentGreen
//                           .withOpacity(0.3), // ✅ Always green since status=1
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: ProfessionalColors.accentGreen.withOpacity(0.5),
//                         width: 1,
//                       ),
//                     ),
//                     child: const Text(
//                       'LIVE', // ✅ Always show LIVE since we filter status=1
//                       style: TextStyle(
//                         color: ProfessionalColors.accentGreen,
//                         fontSize: 8,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
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
//                       '#${widget.channel.channelNumber}',
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





// // ✅ NEWS CHANNEL MODEL CLASS
// class NewsChannel {
//   final int id;
//   final int channelNumber;
//   final String name;
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
//       description: json['description'],
//       banner: json['banner'] ?? '',
//       url: json['url'] ?? '',
//       streamType: json['stream_type'] ?? '',
//       genres: json['genres'] ?? '',
//       status: json['status'] ?? 0,
//     );
//   }
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'channel_number': channelNumber,
//       'name': name,
//       'description': description,
//       'banner': banner,
//       'url': url,
//       'stream_type': streamType,
//       'genres': genres,
//       'status': status,
//     };
//   }
// }




// // ✅ ENHANCED: Professional Channels Grid View with Movies-Style Management
// class ProfessionalChannelsGridView extends StatefulWidget {
//   final List<NewsChannel> channelsList;
//   final String categoryTitle;
//   final String categoryName;

//   const ProfessionalChannelsGridView({
//     Key? key,
//     required this.channelsList,
//     required this.categoryTitle,
//     required this.categoryName,
//   }) : super(key: key);

//   @override
//   _ProfessionalChannelsGridViewState createState() =>
//       _ProfessionalChannelsGridViewState();
// }

// class _ProfessionalChannelsGridViewState extends State<ProfessionalChannelsGridView>
//     with TickerProviderStateMixin {
  
//   // ✅ Enhanced Focus Management with Scrolling (like Movies)
//   Map<String, FocusNode> _channelFocusNodes = {};
//   bool _isLoading = false;
//   int gridFocusedIndex = 0;
//   final int columnsCount = 6;
//   late ScrollController _scrollController;
//   late List<NewsChannel> activeChannels; // Filtered active channels

//   // Animation Controllers
//   late AnimationController _fadeController;
//   late AnimationController _staggerController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
    
//     // ✅ Initialize ScrollController
//     _scrollController = ScrollController();

//     // ✅ Filter active channels (status = 1)
//     activeChannels = widget.channelsList.where((channel) => channel.status == 1).toList();

//     // ✅ Initialize focus nodes with scroll listeners
//     _initializeChannelFocusNodes();

//     // Set up focus for the first channel
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusFirstGridItem();
//     });

//     _initializeAnimations();
//     _startStaggeredAnimation();
//   }

//   // ✅ Initialize focus nodes with scroll functionality (same as Movies)
//   void _initializeChannelFocusNodes() {
//     // Safely dispose existing nodes first
//     for (var entry in _channelFocusNodes.entries) {
//       try {
//         entry.value.removeListener(() {});
//         entry.value.dispose();
//       } catch (e) {
//         print('⚠️ Error disposing channel focus node ${entry.key}: $e');
//       }
//     }

//     _channelFocusNodes.clear();

//     // Create focus nodes for all active channels with String keys
//     for (int i = 0; i < activeChannels.length; i++) {
//       String channelId = activeChannels[i].id.toString();
//       _channelFocusNodes[channelId] = FocusNode()
//         ..addListener(() {
//           if (mounted && _channelFocusNodes[channelId]!.hasFocus) {
//             setState(() {
//               gridFocusedIndex = i;
//             });
//             _scrollToFocusedItem(channelId);
//           }
//         });
//     }

//     print('✅ Created ${_channelFocusNodes.length} channel grid focus nodes');
//   }

//   // ✅ Focus first grid item (same as Movies)
//   void _focusFirstGridItem() {
//     if (activeChannels.isNotEmpty && _channelFocusNodes.isNotEmpty) {
//       final firstChannelId = activeChannels[0].id.toString();
//       if (_channelFocusNodes.containsKey(firstChannelId)) {
//         try {
//           setState(() {
//             gridFocusedIndex = 0;
//           });
//           FocusScope.of(context).requestFocus(_channelFocusNodes[firstChannelId]);
//           print('✅ Focus set to first channel grid item: $firstChannelId');
//         } catch (e) {
//           print('⚠️ Error setting initial channel grid focus: $e');
//         }
//       }
//     }
//   }

//   // ✅ Scroll to focused item (exactly like Movies)
//   void _scrollToFocusedItem(String itemId) {
//     if (!mounted) return;

//     try {
//       final focusNode = _channelFocusNodes[itemId];
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
//       print('⚠️ Error scrolling to focused channel item: $e');
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

//   // ✅ Enhanced Grid Navigation (same as Movies)
//   void _navigateGrid(LogicalKeyboardKey key) {
//     if (_isLoading) return;

//     int newIndex = gridFocusedIndex;
//     final int totalItems = activeChannels.length;
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
//       final newChannelId = activeChannels[newIndex].id.toString();
//       if (_channelFocusNodes.containsKey(newChannelId)) {
//         setState(() {
//           gridFocusedIndex = newIndex;
//         });
//         FocusScope.of(context).requestFocus(_channelFocusNodes[newChannelId]);
//         HapticFeedback.lightImpact();
//         print('🎯 Navigated to channel grid item $newIndex');
//       }
//     }
//   }

//   // ✅ Enhanced Channel Tap Handler with better error handling
//   Future<void> _handleGridChannelTap(NewsChannel channel) async {
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
//                         'Loading Channel...',
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

//       // ✅ Dynamic category assignment for grid view
//       String categoryName = widget.categoryName == 'All'
//           ? (channel.genres.toLowerCase().isNotEmpty
//               ? channel.genres.toLowerCase()
//               : 'live')
//           : widget.categoryName.toLowerCase();

//       // Current channel ko NewsItemModel में convert करें
//       NewsItemModel currentChannel = NewsItemModel(
//         id: channel.id.toString(),
//         videoId: '',
//         name: channel.name,
//         description: channel.description ?? '',
//         banner: channel.banner,
//         poster: channel.banner,
//         category: categoryName,
//         url: channel.url,
//         streamType: channel.streamType,
//         type: channel.streamType,
//         genres: channel.genres,
//         status: channel.status.toString(),
//         index: activeChannels.indexOf(channel).toString(),
//         image: channel.banner,
//         unUpdatedUrl: channel.url,
//       );

//       // ✅ Convert all active channels
//       List<NewsItemModel> allChannels = activeChannels.map((ch) {
//         String chCategoryName = widget.categoryName == 'All'
//             ? (ch.genres.toLowerCase().isNotEmpty
//                 ? ch.genres.toLowerCase()
//                 : 'live')
//             : widget.categoryName.toLowerCase();

//         return NewsItemModel(
//           id: ch.id.toString(),
//           videoId: '',
//           name: ch.name,
//           description: ch.description ?? '',
//           banner: ch.banner,
//           poster: ch.banner,
//           category: chCategoryName,
//           url: ch.url,
//           streamType: ch.streamType,
//           type: ch.streamType,
//           genres: ch.genres,
//           status: ch.status.toString(),
//           index: activeChannels.indexOf(ch).toString(),
//           image: ch.banner,
//           unUpdatedUrl: ch.url,
//         );
//       }).toList();

//       if (mounted) {
//         if (dialogShown) {
//           Navigator.of(context, rootNavigator: true).pop();
//         }

//         // VideoScreen navigate करें with all ACTIVE channels
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => VideoScreen(
//               videoUrl: currentChannel.url,
//               bannerImageUrl: currentChannel.banner,
//               startAtPosition: Duration.zero,
//               videoType: currentChannel.streamType,
//               channelList: allChannels,
//               isLive: true,
//               isVOD: false,
//               isBannerSlider: false,
//               source: 'isLiveScreen',
//               isSearch: false,
//               videoId: int.tryParse(currentChannel.id),
//               unUpdatedUrl: currentChannel.url,
//               name: currentChannel.name,
//               // seasonId: null,
//               // isLastPlayedStored: false,
//               liveStatus: true,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         if (dialogShown) {
//           Navigator.of(context, rootNavigator: true).pop();
//         }

//         // ✅ Enhanced error handling
//         String errorMessage = 'Error loading channel';
//         if (e.toString().contains('network') ||
//             e.toString().contains('connection')) {
//           errorMessage = 'Network error. Please check your connection';
//         } else if (e.toString().contains('format') ||
//             e.toString().contains('codec')) {
//           errorMessage = 'Stream format not supported';
//         } else if (e.toString().contains('not found') ||
//             e.toString().contains('404')) {
//           errorMessage = 'Channel not found or unavailable';
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
//               onPressed: () => _handleGridChannelTap(channel),
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
//             final channelIndex = activeChannels.indexWhere((ch) => ch.id == channel.id);
//             if (channelIndex != -1) {
//               final channelId = channel.id.toString();
//               if (_channelFocusNodes.containsKey(channelId)) {
//                 setState(() {
//                   gridFocusedIndex = channelIndex;
//                 });
//                 FocusScope.of(context).requestFocus(_channelFocusNodes[channelId]);
//                 print('✅ Restored channel grid focus to ${channel.name}');
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
//     for (var entry in _channelFocusNodes.entries) {
//       try {
//         entry.value.removeListener(() {});
//         entry.value.dispose();
//         print('✅ Disposed channel grid focus node: ${entry.key}');
//       } catch (e) {
//         print('⚠️ Error disposing channel grid focus node ${entry.key}: $e');
//       }
//     }
//     _channelFocusNodes.clear();
    
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ColorProvider>(
//       builder: (context, colorProv, child) {
//         final bgColor = colorProv.isItemFocused
//             ? colorProv.dominantColor.withOpacity(0.1)
//             : ProfessionalColors.primaryDark;

//         return Scaffold(
//           backgroundColor: ProfessionalColors.primaryDark,
//           body: Container(
//             // ✅ Background Gradient like Movies/VOD
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
//             child: Stack(
//               children: [
//                 // ✅ Main Content with proper padding for AppBar
//                 FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: Column(
//                     children: [
//                       // ✅ AppBar height placeholder to push content down
//                       SizedBox(
//                         height: MediaQuery.of(context).padding.top + 80, // AppBar total height
//                       ),
//                       Expanded(
//                         child: _buildChannelsGrid(),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // ✅ AppBar positioned on top with proper z-index (VOD Style)
//                 Positioned(
//                   top: 0,
//                   left: 0,
//                   right: 0,
//                   child: _buildProfessionalAppBar(),
//                 ),

//                 // ✅ Loading Overlay - Always on top
//                 if (_isLoading)
//                   Positioned.fill(
//                     child: Container(
//                       color: Colors.black.withOpacity(0.7),
//                       child: const Center(
//                         child: ProfessionalLoadingIndicator(message: 'Loading Channel...'),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ✅ Professional AppBar with VOD/Movies Style
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
//         // ✅ Add bottom border for better separation (Live theme color)
//         border: Border(
//           bottom: BorderSide(
//             color: ProfessionalColors.accentGreen.withOpacity(0.2), // Live theme color
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
//                 // ✅ Back Button with Live theme colors
//                 Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: LinearGradient(
//                       colors: [
//                         ProfessionalColors.accentGreen.withOpacity(0.3), // Live theme
//                         ProfessionalColors.accentBlue.withOpacity(0.3),
//                       ],
//                     ),
//                     // ✅ Add elevation to back button
//                     boxShadow: [
//                       BoxShadow(
//                         color: ProfessionalColors.accentGreen.withOpacity(0.3),
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
//                       // ✅ Title with Live theme colors and better shadow
//                       ShaderMask(
//                         shaderCallback: (bounds) => const LinearGradient(
//                           colors: [
//                             ProfessionalColors.accentGreen, // Live theme
//                             ProfessionalColors.accentBlue,
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
//                       // ✅ Count badge with Live theme colors and elevation
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               ProfessionalColors.accentGreen.withOpacity(0.3), // Live theme
//                               ProfessionalColors.accentBlue.withOpacity(0.2),
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(15),
//                           border: Border.all(
//                             color: ProfessionalColors.accentGreen.withOpacity(0.4),
//                             width: 1,
//                           ),
//                           // ✅ Add elevation to count badge
//                           boxShadow: [
//                             BoxShadow(
//                               color: ProfessionalColors.accentGreen.withOpacity(0.2),
//                               blurRadius: 6,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Text(
//                           '${activeChannels.length} Live Channels Available',
//                           style: const TextStyle(
//                             color: ProfessionalColors.accentGreen, // Live theme
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

//   Widget _buildChannelsGrid() {
//     if (activeChannels.isEmpty) {
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
//                     ProfessionalColors.accentGreen.withOpacity(0.2),
//                     ProfessionalColors.accentGreen.withOpacity(0.1),
//                   ],
//                 ),
//               ),
//               child: const Icon(
//                 Icons.tv_outlined,
//                 size: 40,
//                 color: ProfessionalColors.accentGreen,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'No Live ${widget.categoryTitle} Channels',
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
//             if (gridFocusedIndex < activeChannels.length) {
//               _handleGridChannelTap(activeChannels[gridFocusedIndex]);
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
//             crossAxisSpacing: 25,
//             childAspectRatio: 1.5,
//           ),
//           itemCount: activeChannels.length,
//           clipBehavior: Clip.none, // ✅ Allow shadows to be visible
//           itemBuilder: (context, index) {
//             final channel = activeChannels[index];
//             String channelId = channel.id.toString();

//             // ✅ Safe check for focus node existence
//             if (!_channelFocusNodes.containsKey(channelId)) {
//               print('⚠️ Channel grid focus node not found for Channel: $channelId');
//               return const SizedBox.shrink();
//             }

//             return AnimatedBuilder(
//               animation: _staggerController,
//               builder: (context, child) {
//                 final delay = (index / activeChannels.length) * 0.5;
//                 final animationValue = Interval(
//                   delay,
//                   delay + 0.5,
//                   curve: Curves.easeOutCubic,
//                 ).transform(_staggerController.value);

//                 return Transform.translate(
//                   offset: Offset(0, 50 * (1 - animationValue)),
//                   child: Opacity(
//                     opacity: animationValue,
//                     child: ProfessionalGridChannelCard(
//                       channel: channel,
//                       focusNode: _channelFocusNodes[channelId]!,
//                       onTap: () => _handleGridChannelTap(channel),
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





import 'dart:async';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:http/http.dart' as https;
import 'package:provider/provider.dart';

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

// ✅ OPTIMIZED GENERIC LIVE CHANNELS WIDGET WITH STATUS FILTERING
class GenericLiveChannels extends StatefulWidget {
  final Function(bool)? onFocusChange;
  final FocusNode focusNode;
  final String apiCategory; // 'Music', 'Movie', 'Entertainment', 'News', etc.
  final String displayTitle; // 'MUSIC', 'MOVIES', 'ENTERTAINMENT', 'NEWS', etc.
  final int
      navigationIndex; // 0=Live, 1=Entertainment, 2=Music, 3=Movie, 4=News, etc.

  const GenericLiveChannels({
    Key? key,
    this.onFocusChange,
    required this.focusNode,
    required this.apiCategory,
    required this.displayTitle,
    required this.navigationIndex,
  }) : super(key: key);

  @override
  _GenericLiveChannelsState createState() => _GenericLiveChannelsState();
}

class _GenericLiveChannelsState extends State<GenericLiveChannels>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  // ✅ OPTIMIZED: Separate data for display and grid with status filtering
  List<NewsChannel> displayChannelsList =
      []; // Only 7 ACTIVE channels for home page display
  List<NewsChannel> fullChannelsList = []; // All ACTIVE channels for grid view
  int totalActiveChannelsCount = 0; // Total ACTIVE channels count from API

  bool _isLoading = true;
  String _errorMessage = '';
  bool _isNavigating = false;
  bool _isLoadingFullList = false;

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;

  // Focus management
  Map<String, FocusNode> channelFocusNodes = {};
  FocusNode? _viewAllFocusNode;
  Color _currentAccentColor = ProfessionalColors.accentBlue;

  // Controllers
  final ScrollController _scrollController = ScrollController();
  late final String _cacheKey;
  Timer? _backgroundFetchTimer;
  bool _isBackgroundFetching = false;

  // ✅ OPTIMIZED: Modified initState and data loading methods

  @override
  void initState() {
    super.initState();
    _cacheKey = 'live_channels_${widget.apiCategory}';
    _initializeAnimations();
    _initializeViewAllFocusNode();
    _setupFocusProvider();

    // ✅ NEW: Load data with optimized caching strategy
    _loadDataWithCaching();
    _startBackgroundFetching();
  }

// ✅ NEW: Optimized data loading with instant cache + background refresh
  Future<void> _loadDataWithCaching() async {
    if (!mounted) return;

    // Step 1: Try to load from cache instantly
    final cachedData = await _loadFromCache();

    if (cachedData != null && cachedData.isNotEmpty) {
      // ✅ INSTANT: Show cached data immediately
      if (mounted) {
        setState(() {
          displayChannelsList = cachedData.take(7).toList();
          totalActiveChannelsCount = cachedData.length;
          _initializeChannelFocusNodes();
          _isLoading = false;
        });
        _headerAnimationController.forward();
        _listAnimationController.forward();
      }

      print('✅ Cache data loaded instantly: ${cachedData.length} channels');

      // Step 2: Fetch fresh data in background to update cache
      _fetchFreshDataInBackground();
    } else {
      // ✅ NO CACHE: Show loading and fetch from API
      print('❌ No cache found, fetching from API...');
      setState(() {
        _isLoading = true;
      });
      await _fetchDisplayChannels();
    }
  }

// ✅ NEW: Background cache update WITHOUT UI changes
  Future<void> _fetchFreshDataInBackground() async {
    if (!mounted) return;

    try {
      print('🔄 Fetching fresh data in background...');
      final freshData = await _fetchChannelsFromAPI();

      if (freshData.isNotEmpty) {
        final cachedData = await _loadFromCache();

        // Compare fresh data with cached data
        if (cachedData == null ||
            !_areChannelListsEqual(cachedData, freshData)) {
          print('🆕 Fresh data different from cache, updating...');

          // ✅ ONLY UPDATE CACHE - DO NOT UPDATE UI
          await _saveToCache(freshData);

          // ✅ REMOVED: UI update code - keeping current UI as is
          // User jo dekh raha hai woh same rahega

          print('✅ Cache updated with fresh data (UI unchanged)');
        } else {
          print('✅ Cache data is already fresh, no update needed');
        }
      }
    } catch (e) {
      print('❌ Background fetch error: $e');
      // Don't show error to user since this is background operation
    }
  }

// ✅ MODIFIED: Enhanced cache loading with better error handling
  Future<List<NewsChannel>?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString(_cacheKey);

      if (cachedString != null && cachedString.isNotEmpty) {
        final cachedList = jsonDecode(cachedString) as List;
        final channels =
            cachedList.map((item) => NewsChannel.fromJson(item)).toList();

        // ✅ Filter active channels from cache too
        final activeChannels = _filterActiveChannels(channels);

        print('📦 Cache loaded: ${activeChannels.length} active channels');
        return activeChannels;
      }
    } catch (e) {
      print('❌ Error loading from cache: $e');
      // Clear corrupted cache
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_cacheKey);
      } catch (clearError) {
        print('❌ Error clearing corrupted cache: $clearError');
      }
    }
    return null;
  }

// ✅ ENHANCED: Better cache saving with validation
  Future<void> _saveToCache(List<NewsChannel> channels) async {
    try {
      if (channels.isEmpty) {
        print('⚠️ Not saving empty channels list to cache');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonList = channels.map((channel) => channel.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await prefs.setString(_cacheKey, jsonString);
      print('💾 Cache saved: ${channels.length} channels');
    } catch (e) {
      print('❌ Error saving to cache: $e');
    }
  }

// ✅ OPTIMIZED: Background fetching with cache-only updates
  void _startBackgroundFetching() {
    // Cancel any existing timer
    _backgroundFetchTimer?.cancel();

    // Start new timer that runs every 2 minutes for silent cache updates
    _backgroundFetchTimer = Timer.periodic(Duration(minutes: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      // ✅ Silent cache update - no UI changes
      _fetchDataInBackground();
    });

    // Also update cache after 10 seconds of initial load (silent)
    Timer(Duration(seconds: 10), () {
      if (mounted) {
        print('🔄 Starting silent cache update...');
        _fetchDataInBackground();
      }
    });
  }

// ✅ ENHANCED: Improved data comparison
  bool _areChannelListsEqual(
      List<NewsChannel> list1, List<NewsChannel> list2) {
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id ||
          list1[i].url != list2[i].url ||
          list1[i].status != list2[i].status ||
          list1[i].name != list2[i].name ||
          list1[i].banner != list2[i].banner) {
        return false;
      }
    }

    return true;
  }

// ✅ MODIFIED: API fetch method remains same but with better logging
  Future<List<NewsChannel>> _fetchChannelsFromAPI() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String authKey = prefs.getString('auth_key') ?? '';

      print(
          '🌐 Fetching channels from API for category: ${widget.apiCategory}');

      final response = await https.get(
        Uri.parse(
            'https://acomtv.coretechinfo.com/public/api/getFeaturedLiveTV'),
        headers: {'auth-key': authKey},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (widget.apiCategory == 'All') {
          List<NewsChannel> allChannels = [];
          data.forEach((categoryName, channelsData) {
            if (channelsData is List) {
              allChannels.addAll(channelsData
                  .map((item) => NewsChannel.fromJson(item))
                  .toList());
            }
          });
          final activeChannels = _filterActiveChannels(allChannels);
          print(
              '✅ API fetched ${activeChannels.length} active channels (All categories)');
          return activeChannels;
        } else if (data.containsKey(widget.apiCategory)) {
          final List<dynamic> channelsData = data[widget.apiCategory];
          final allChannels =
              channelsData.map((item) => NewsChannel.fromJson(item)).toList();
          final activeChannels = _filterActiveChannels(allChannels);
          print(
              '✅ API fetched ${activeChannels.length} active channels (${widget.apiCategory})');
          return activeChannels;
        }
      } else {
        print('❌ API error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API fetch error: $e');
    }

    return [];
  }

// ✅ SIMPLIFIED: Display channels fetch now just calls the API method
  Future<void> _fetchDisplayChannels() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final freshData = await _fetchChannelsFromAPI();

      if (freshData.isNotEmpty) {
        // Save to cache
        await _saveToCache(freshData);

        if (mounted) {
          setState(() {
            totalActiveChannelsCount = freshData.length;
            displayChannelsList = freshData.take(7).toList();
            _initializeChannelFocusNodes();
            _isLoading = false;
          });

          _headerAnimationController.forward();
          _listAnimationController.forward();
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            // Don't show error message if we already have cached data
            if (displayChannelsList.isEmpty) {
              _errorMessage = 'No ${widget.apiCategory} channels found';
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Don't show error message if we already have cached data
          if (displayChannelsList.isEmpty) {
            _errorMessage = 'Network error: Please check connection';
          }
        });
      }
    }
  }

// ✅ NEW: Method to manually refresh data (can be called from pull-to-refresh)
  Future<void> _refreshData() async {
    try {
      final freshData = await _fetchChannelsFromAPI();

      if (freshData.isNotEmpty) {
        await _saveToCache(freshData);

        if (mounted) {
          setState(() {
            displayChannelsList = freshData.take(7).toList();
            totalActiveChannelsCount = freshData.length;
            _initializeChannelFocusNodes();
          });
        }

        print('✅ Manual refresh completed');
      }
    } catch (e) {
      print('❌ Manual refresh error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh data'),
            backgroundColor: ProfessionalColors.accentRed,
          ),
        );
      }
    }
  }

// ✅ ENHANCED: Better disposal with proper cleanup
  @override
  void dispose() {
    _backgroundFetchTimer?.cancel();
    _isBackgroundFetching = false;

    print('🧹 Disposing ${widget.displayTitle} channels widget');

    _headerAnimationController.dispose();
    _listAnimationController.dispose();

    for (var entry in channelFocusNodes.entries) {
      try {
        entry.value.removeListener(() {});
        entry.value.dispose();
      } catch (e) {}
    }
    channelFocusNodes.clear();

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

  Future<void> _fetchDataInBackground() async {
    if (_isBackgroundFetching || !mounted) return;

    _isBackgroundFetching = true;
    try {
      final freshData = await _fetchChannelsFromAPI();
      final cachedData = await _loadFromCache();

      // Compare fresh data with cached data
      if (cachedData == null || !_areChannelListsEqual(cachedData, freshData)) {
        // Update cache
        await _saveToCache(freshData);

        // Update UI if needed
        if (mounted) {
          setState(() {
            // displayChannelsList = freshData.take(7).toList();
            totalActiveChannelsCount = freshData.length;
            _initializeChannelFocusNodes();
          });
        }
      }
    } catch (e) {
      print('Background fetch error: $e');
    } finally {
      _isBackgroundFetching = false;
    }
  }

  void _setupFocusProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final focusProvider =
              Provider.of<FocusProvider>(context, listen: false);

          // ✅ Special handling for Live page (index 0)
          if (widget.navigationIndex == 0) {
            focusProvider.setLiveChannelsFocusNode(widget.focusNode);
            print('✅ Live focus node specially registered');
          }

          // ✅ GENERIC: Register with navigation index for all pages
          focusProvider.registerGenericChannelFocus(
              widget.navigationIndex, _scrollController, widget.focusNode);

          print(
              '✅ Generic focus registered for ${widget.displayTitle} (index: ${widget.navigationIndex})');
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
                math.Random().nextInt(ProfessionalColors.gradientColors.length)];
          });
        }
      });
  }

  // ✅ NEW: Filter only active channels (status = 1)
  List<NewsChannel> _filterActiveChannels(List<NewsChannel> channels) {
    return channels.where((channel) => channel.status == 1).toList();
  }

  // ✅ NEW: Fetch full ACTIVE channels list when needed (for grid view)
  Future<void> _fetchFullChannelsList() async {
    if (!mounted || _isLoadingFullList || fullChannelsList.isNotEmpty) return;

    setState(() {
      _isLoadingFullList = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String authKey = prefs.getString('auth_key') ?? '';

      final response = await https.get(
        Uri.parse(
            'https://acomtv.coretechinfo.com/public/api/getFeaturedLiveTV'),
        headers: {'auth-key': authKey},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (widget.apiCategory == 'All') {
          // Combine all channels from all categories
          List<NewsChannel> allChannels = [];

          data.forEach((categoryName, channelsData) {
            if (channelsData is List) {
              List<NewsChannel> categoryChannels = channelsData
                  .map((item) => NewsChannel.fromJson(item))
                  .toList();
              allChannels.addAll(categoryChannels);
            }
          });

          // ✅ FILTER: Only active channels (status = 1)
          List<NewsChannel> activeChannels =
              _filterActiveChannels(allChannels);

          if (mounted) {
            setState(() {
              fullChannelsList = activeChannels;
              _isLoadingFullList = false;
            });
          }
        } else if (data.containsKey(widget.apiCategory)) {
          final List<dynamic> channelsData = data[widget.apiCategory];

          List<NewsChannel> allChannels =
              channelsData.map((item) => NewsChannel.fromJson(item)).toList();

          // ✅ FILTER: Only active channels (status = 1)
          List<NewsChannel> activeChannels =
              _filterActiveChannels(allChannels);

          if (mounted) {
            setState(() {
              fullChannelsList = activeChannels;
              _isLoadingFullList = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFullList = false;
        });
      }
    }
  }

  void _initializeChannelFocusNodes() {
    // Clear existing focus nodes
    for (var node in channelFocusNodes.values) {
      try {
        node.removeListener(() {});
        node.dispose();
      } catch (e) {}
    }
    channelFocusNodes.clear();

    // ✅ OPTIMIZED: Create focus nodes only for display channels
    for (var channel in displayChannelsList) {
      try {
        String channelId = channel.id.toString();
        channelFocusNodes[channelId] = FocusNode()
          ..addListener(() {
            if (mounted && channelFocusNodes[channelId]!.hasFocus) {
              _scrollToFocusedItem(channelId);
            }
          });
      } catch (e) {
        // Silent error handling
      }
    }

    // Register with focus provider
    _registerChannelsFocus();
  }

  void _registerChannelsFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && displayChannelsList.isNotEmpty) {
        try {
          final focusProvider =
              Provider.of<FocusProvider>(context, listen: false);

          // Register first channel with focus provider using generic method
          final firstChannelId = displayChannelsList[0].id.toString();
          if (channelFocusNodes.containsKey(firstChannelId)) {
            focusProvider.registerGenericChannelFocus(widget.navigationIndex,
                _scrollController, channelFocusNodes[firstChannelId]!);
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

  void _scrollToFocusedItem(String itemId) {
    if (!mounted) return;

    try {
      // Find the index of the focused item
      int focusedIndex =
          displayChannelsList.indexWhere((channel) => channel.id.toString() == itemId);

      if (focusedIndex != -1) {
        // Calculate horizontal offset for the focused item
        final double itemWidth = bannerwdt; // Same as your card width
        final double itemMargin = 12.0; // Horizontal margin between items
        final double targetOffset = focusedIndex * (itemWidth + itemMargin);

        // Animate to specific horizontal position
        _scrollController.animateTo(
          targetOffset,
          duration: AnimationTiming.scroll,
          curve: Curves.easeInOutCubic,
        );

        print(
            '🎯 Horizontal scroll to index $focusedIndex: ${displayChannelsList[focusedIndex].name}');
      }
    } catch (e) {
      print('❌ Horizontal scroll error: $e');
    }
  }

  // ✅ OPTIMIZED: Convert display channels to NewsItemModel
  List<NewsItemModel> _convertDisplayChannelsToNewsItems() {
    return displayChannelsList.map((channel) {
      String categoryName = widget.apiCategory == 'All'
          ? (channel.genres.toLowerCase().isNotEmpty
              ? channel.genres.toLowerCase()
              : 'live')
          : widget.apiCategory.toLowerCase();

      return NewsItemModel(
        id: channel.id.toString(),
        videoId: '',
        name: channel.name,
        description: channel.description ?? '',
        banner: channel.banner,
        poster: channel.banner,
        category: categoryName,
        url: channel.url,
        streamType: channel.streamType,
        type: channel.streamType,
        genres: channel.genres,
        status: channel.status.toString(),
        index: displayChannelsList.indexOf(channel).toString(),
        image: channel.banner,
        unUpdatedUrl: channel.url,
      );
    }).toList();
  }

  // ✅ NEW: Convert full channels to NewsItemModel (for grid view)
  List<NewsItemModel> _convertFullChannelsToNewsItems() {
    return fullChannelsList.map((channel) {
      String categoryName = widget.apiCategory == 'All'
          ? (channel.genres.toLowerCase().isNotEmpty
              ? channel.genres.toLowerCase()
              : 'live')
          : widget.apiCategory.toLowerCase();

      return NewsItemModel(
        id: channel.id.toString(),
        videoId: '',
        name: channel.name,
        description: channel.description ?? '',
        banner: channel.banner,
        poster: channel.banner,
        category: categoryName,
        url: channel.url,
        streamType: channel.streamType,
        type: channel.streamType,
        genres: channel.genres,
        status: channel.status.toString(),
        index: fullChannelsList.indexOf(channel).toString(),
        image: channel.banner,
        unUpdatedUrl: channel.url,
      );
    }).toList();
  }

  // ✅ OPTIMIZED: Handle channel tap with display channels
  Future<void> _handleChannelTap(NewsChannel channel) async {
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
                      'Loading channel...',
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

    Timer(Duration(seconds: 10), () {
      _isNavigating = false;
    });

    try {
      String categoryName = widget.apiCategory == 'All'
          ? (channel.genres.toLowerCase().isNotEmpty
              ? channel.genres.toLowerCase()
              : 'live')
          : widget.apiCategory.toLowerCase();

      // Current channel ko NewsItemModel में convert करें
      NewsItemModel currentChannel = NewsItemModel(
        id: channel.id.toString(),
        videoId: '',
        name: channel.name,
        description: channel.description ?? '',
        banner: channel.banner,
        poster: channel.banner,
        category: categoryName,
        url: channel.url,
        streamType: channel.streamType,
        type: channel.streamType,
        genres: channel.genres,
        status: channel.status.toString(),
        index: displayChannelsList.indexOf(channel).toString(),
        image: channel.banner,
        unUpdatedUrl: channel.url,
      );

      // ✅ OPTIMIZED: Use display channels for navigation
      List<NewsItemModel> allChannels =
          _convertDisplayChannelsToNewsItems();

      if (dialogShown) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      bool liveStatus = true;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoScreen(
            videoUrl: currentChannel.url,
            bannerImageUrl: currentChannel.banner,
            startAtPosition: Duration.zero,
            videoType: currentChannel.streamType,
            channelList: allChannels,
            isLive: true,
            isVOD: false,
            isBannerSlider: false,
            source: 'isLiveScreen',
            isSearch: false,
            videoId: int.tryParse(currentChannel.id),
            unUpdatedUrl: currentChannel.url,
            name: currentChannel.name,
            liveStatus: liveStatus,
          ),
        ),
      );
    } catch (e) {
      if (dialogShown) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something Went Wrong')),
      );
    } finally {
      _isNavigating = false;
    }
  }

  // ✅ OPTIMIZED: Navigate to grid view and fetch full list if needed
  void _navigateToChannelsGrid() async {
    if (!_isNavigating && mounted) {
      // ✅ Fetch full channels list if not already loaded
      if (fullChannelsList.isEmpty) {
        await _fetchFullChannelsList();
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfessionalChannelsGridView(
              channelsList: fullChannelsList.isNotEmpty
                  ? fullChannelsList
                  : displayChannelsList,
              categoryTitle: widget.displayTitle,
              categoryName: widget.apiCategory,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<ColorProvider>(
      builder: (context, colorProv, child) {
        final bgColor = colorProv.isItemFocused
            ? colorProv.dominantColor.withOpacity(0.1)
            : ProfessionalColors.primaryDark;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            // ✅ CHANGED: Updated gradient to match movies style for a more vibrant effect
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
            // ✅ OPTIMIZED: Show total ACTIVE channels count
            if (totalActiveChannelsCount > 0)
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
                  '${totalActiveChannelsCount} Live Channels',
                  style: const TextStyle(
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

  Widget _buildBody(double screenWidth, double screenHeight) {
    if (_isLoading) {
      return ProfessionalLoadingIndicator(
          message: 'Loading ${widget.displayTitle} Channels...');
    } else if (_errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    } else if (displayChannelsList.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildChannelsList(screenWidth, screenHeight);
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
            onPressed:
                _fetchDisplayChannels, // ✅ CHANGED: Fetch display channels
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
              Icons.tv_outlined,
              size: 40,
              color: ProfessionalColors.accentBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Live ${widget.displayTitle} Channels',
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

  Widget _buildChannelsList(double screenWidth, double screenHeight) {
    // ✅ OPTIMIZED: Show ViewAll only if total ACTIVE channels > 7
    bool showViewAll = totalActiveChannelsCount > 7;

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
          // ✅ OPTIMIZED: Always show exactly 7 channels + ViewAll if needed
          itemCount: showViewAll ? 8 : displayChannelsList.length,
          itemBuilder: (context, index) {
            if (showViewAll && index == 7) {
              return Focus(
                focusNode: _viewAllFocusNode,
                onFocusChange: (hasFocus) {
                  if (hasFocus && mounted) {
                    Color viewAllColor = ProfessionalColors.gradientColors[
                        math.Random()
                            .nextInt(ProfessionalColors.gradientColors.length)];

                    try {
                      context
                          .read<ColorProvider>()
                          .updateColor(viewAllColor, true);
                    } catch (e) {
                      print('ViewAll color update failed: $e');
                    }
                  } else if (mounted) {
                    try {
                      context.read<ColorProvider>().resetColor();
                    } catch (e) {
                      print('ViewAll color reset failed: $e');
                    }
                  }
                },
                onKey: (FocusNode node, RawKeyEvent event) {
                  if (event is RawKeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                      return KeyEventResult.handled;
                    } else if (event.logicalKey ==
                        LogicalKeyboardKey.arrowLeft) {
                      if (displayChannelsList.isNotEmpty &&
                          displayChannelsList.length > 6) {
                        String channelId =
                            displayChannelsList[6].id.toString();
                        FocusScope.of(context)
                            .requestFocus(channelFocusNodes[channelId]);
                        return KeyEventResult.handled;
                      }
                    } else if (event.logicalKey ==
                        LogicalKeyboardKey.arrowUp) {
                      // ✅ GENERIC: Navigate to corresponding navigation button
                      try {
                        context
                            .read<FocusProvider>()
                            .requestNavigationFocus(widget.navigationIndex);
                        print(
                            '🎯 ViewAll -> ${widget.displayTitle} navigation button');
                      } catch (e) {
                        print('❌ ViewAll navigation failed: $e');
                      }
                      return KeyEventResult.handled;
                    } else if (event.logicalKey ==
                        LogicalKeyboardKey.arrowDown) {
                      // Navigate to next section
                      FocusScope.of(context).unfocus();
                      Future.delayed(const Duration(milliseconds: 50), () {
                        if (mounted) {
                          try {
                            context
                                .read<FocusProvider>()
                                .requestFirstHorizontalListNetworksFocus();
                          } catch (e) {
                            print('Next section focus request failed: $e');
                          }
                        }
                      });
                      return KeyEventResult.handled;
                    } else if (event.logicalKey == LogicalKeyboardKey.select) {
                      _navigateToChannelsGrid();
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: GestureDetector(
                  onTap: _navigateToChannelsGrid,
                  child: ProfessionalViewAllButton(
                    focusNode: _viewAllFocusNode!,
                    onTap: _navigateToChannelsGrid,
                    totalChannels:
                        totalActiveChannelsCount, // ✅ Show total ACTIVE channels
                  ),
                ),
              );
            }

            var channel = displayChannelsList[index];
            return _buildChannelItem(channel, index, screenWidth, screenHeight);
          },
        ),
      ),
    );
  }

  // ✅ Build channel item with dynamic navigation
  Widget _buildChannelItem(
      NewsChannel channel, int index, double screenWidth, double screenHeight) {
    String channelId = channel.id.toString();

    channelFocusNodes.putIfAbsent(
      channelId,
      () => FocusNode()
        ..addListener(() {
          if (mounted && channelFocusNodes[channelId]!.hasFocus) {
            _scrollToFocusedItem(channelId);
          }
        }),
    );

    return Focus(
      focusNode: channelFocusNodes[channelId],
      onFocusChange: (hasFocus) async {
        if (hasFocus && mounted) {
          try {
            // ✅ ENHANCED: Generate dynamic color for background
            Color dominantColor = ProfessionalColors.gradientColors[
                math.Random()
                    .nextInt(ProfessionalColors.gradientColors.length)];

            // ✅ ENHANCED: Update background color when channel focused
            try {
              context.read<ColorProvider>().updateColor(dominantColor, true);
            } catch (e) {
              print('Color provider update failed: $e');
            }

            widget.onFocusChange?.call(true);
          } catch (e) {
            print('Focus change handling failed: $e');
          }
        } else if (mounted) {
          try {
            // ✅ ENHANCED: Reset background when unfocused
            context.read<ColorProvider>().resetColor();
          } catch (e) {
            print('Color reset failed: $e');
          }
          widget.onFocusChange?.call(false);
        }
      },
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (index < displayChannelsList.length - 1 && index != 6) {
              String nextChannelId =
                  displayChannelsList[index + 1].id.toString();
              FocusScope.of(context)
                  .requestFocus(channelFocusNodes[nextChannelId]);
              return KeyEventResult.handled;
            } else if (index == 6 && totalActiveChannelsCount > 7) {
              FocusScope.of(context).requestFocus(_viewAllFocusNode);
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (index > 0) {
              String prevChannelId =
                  displayChannelsList[index - 1].id.toString();
              FocusScope.of(context)
                  .requestFocus(channelFocusNodes[prevChannelId]);
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // ✅ GENERIC: Navigate to corresponding navigation button
            try {
              context
                  .read<FocusProvider>()
                  .requestNavigationFocus(widget.navigationIndex);
              print(
                  '🎯 ${widget.displayTitle} channel -> navigation button (index: ${widget.navigationIndex})');
            } catch (e) {
              print('❌ Navigation focus failed: $e');
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Navigate to next section
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                try {
                  context
                      .read<FocusProvider>()
                      .requestFirstHorizontalListNetworksFocus();
                } catch (e) {
                  print('Next section focus request failed: $e');
                }
              }
            });
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.select) {
            _handleChannelTap(channel);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _handleChannelTap(channel),
        child: ProfessionalChannelCard(
          channel: channel,
          focusNode: channelFocusNodes[channelId]!,
          onTap: () => _handleChannelTap(channel),
          onColorChange: (color) {
            setState(() {
              _currentAccentColor = color;
            });
          },
          index: index,
          categoryTitle: widget.displayTitle,
        ),
      ),
    );
  }
}


// ✅ COMPLETE: Modified ProfessionalChannelCard with all methods
class ProfessionalChannelCard extends StatefulWidget {
  final NewsChannel channel;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final Function(Color) onColorChange;
  final int index;
  final String categoryTitle;

  const ProfessionalChannelCard({
    Key? key,
    required this.channel,
    required this.focusNode,
    required this.onTap,
    required this.onColorChange,
    required this.index,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  _ProfessionalChannelCardState createState() =>
      _ProfessionalChannelCardState();
}

class _ProfessionalChannelCardState extends State<ProfessionalChannelCard>
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
      // ✅ FIXED: Get color from ColorProvider instead of generating new one
      _updateDominantColorFromProvider();
      HapticFeedback.lightImpact();
    } else {
      _scaleController.reverse();
      _glowController.reverse();
    }
  }

  // ✅ NEW: Get the same color that's used for background
  void _updateDominantColorFromProvider() {
    try {
      final colorProvider = context.read<ColorProvider>();
      if (colorProvider.isItemFocused) {
        setState(() {
          _dominantColor = colorProvider.dominantColor;
        });
        widget.onColorChange(_dominantColor);
      }
    } catch (e) {
      // Fallback to default if ColorProvider is not available
      _dominantColor = ProfessionalColors.accentBlue;
      widget.onColorChange(_dominantColor);
    }
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
            _buildChannelImage(screenWidth, posterHeight),
            if (_isFocused) _buildFocusBorder(),
            if (_isFocused) _buildShimmerEffect(),
            _buildStatusBadge(),
            if (_isFocused) _buildHoverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelImage(double screenWidth, double posterHeight) {
    return Container(
      width: double.infinity,
      height: posterHeight,
      child: widget.channel.banner.isNotEmpty
          ? Image.network(
              widget.channel.banner,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildImagePlaceholder(posterHeight),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildImagePlaceholder(posterHeight);
              },
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
            Icons.tv_outlined,
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
              color: ProfessionalColors.accentGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: ProfessionalColors.accentGreen,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ UPDATED: _buildFocusBorder now uses the same color as background
  Widget _buildFocusBorder() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 3,
            color: _dominantColor, // This now matches the background color
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

  Widget _buildStatusBadge() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: ProfessionalColors.accentGreen.withOpacity(0.9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'LIVE',
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
    final channelName = widget.channel.name.toUpperCase();

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
          channelName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ✅ PROFESSIONAL VIEW ALL BUTTON
class ProfessionalViewAllButton extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int totalChannels;

  const ProfessionalViewAllButton({
    Key? key,
    required this.focusNode,
    required this.onTap,
    required this.totalChannels,
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
      width: bannerwdt,
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
                    '${widget.totalChannels}',
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
      child: const Text(
        'ALL CHANNELS',
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}






// ✅ PROFESSIONAL LOADING INDICATOR
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
                    transform:
                        GradientRotation(_animation.value * 2 * math.pi),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: ProfessionalColors.primaryDark,
                  ),
                  child: const Icon(
                    Icons.tv_rounded,
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

// ✅ NEWS CHANNEL MODEL CLASS
class NewsChannel {
  final int id;
  final int channelNumber;
  final String name;
  final String? description;
  final String banner;
  final String url;
  final String streamType;
  final String genres;
  final int status;

  NewsChannel({
    required this.id,
    required this.channelNumber,
    required this.name,
    this.description,
    required this.banner,
    required this.url,
    required this.streamType,
    required this.genres,
    required this.status,
  });

  factory NewsChannel.fromJson(Map<String, dynamic> json) {
    return NewsChannel(
      id: json['id'] ?? 0,
      channelNumber: json['channel_number'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      banner: json['banner'] ?? '',
      url: json['url'] ?? '',
      streamType: json['stream_type'] ?? '',
      genres: json['genres'] ?? '',
      status: json['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel_number': channelNumber,
      'name': name,
      'description': description,
      'banner': banner,
      'url': url,
      'stream_type': streamType,
      'genres': genres,
      'status': status,
    };
  }
}




// ✅ PROFESSIONAL GRID CHANNEL CARD WITH STATUS FILTERING
class ProfessionalGridChannelCard extends StatefulWidget {
  final NewsChannel channel;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int index;
  final String categoryTitle;

  const ProfessionalGridChannelCard({
    Key? key,
    required this.channel,
    required this.focusNode,
    required this.onTap,
    required this.index,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  _ProfessionalGridChannelCardState createState() =>
      _ProfessionalGridChannelCardState();
}

class _ProfessionalGridChannelCardState
    extends State<ProfessionalGridChannelCard> with TickerProviderStateMixin {
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
                      _buildChannelImage(),
                      if (_isFocused) _buildFocusBorder(),
                      _buildGradientOverlay(),
                      _buildChannelInfo(),
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

  Widget _buildChannelImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: widget.channel.banner.isNotEmpty
          ? Image.network(
              widget.channel.banner,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildImagePlaceholder(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildImagePlaceholder();
              },
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
              Icons.tv_outlined,
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
                color: ProfessionalColors.accentGreen
                    .withOpacity(0.2), // ✅ Always green for LIVE
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color:
                      ProfessionalColors.accentGreen, // ✅ Always green for LIVE
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

  Widget _buildChannelInfo() {
    final channelName = widget.channel.name;

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
              channelName.toUpperCase(),
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ProfessionalColors.accentGreen
                          .withOpacity(0.3), // ✅ Always green since status=1
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ProfessionalColors.accentGreen.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'LIVE', // ✅ Always show LIVE since we filter status=1
                      style: TextStyle(
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
                      '#${widget.channel.channelNumber}',
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








// ✅ ENHANCED: Professional Channels Grid View with Movies-Style Management
class ProfessionalChannelsGridView extends StatefulWidget {
  final List<NewsChannel> channelsList;
  final String categoryTitle;
  final String categoryName;

  const ProfessionalChannelsGridView({
    Key? key,
    required this.channelsList,
    required this.categoryTitle,
    required this.categoryName,
  }) : super(key: key);

  @override
  _ProfessionalChannelsGridViewState createState() =>
      _ProfessionalChannelsGridViewState();
}

class _ProfessionalChannelsGridViewState extends State<ProfessionalChannelsGridView>
    with TickerProviderStateMixin {
  
  // ✅ Enhanced Focus Management with Scrolling (like Movies)
  Map<String, FocusNode> _channelFocusNodes = {};
  bool _isLoading = false;
  int gridFocusedIndex = 0;
  final int columnsCount = 6;
  late ScrollController _scrollController;
  late List<NewsChannel> activeChannels; // Filtered active channels

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // ✅ Initialize ScrollController
    _scrollController = ScrollController();

    // ✅ Filter active channels (status = 1)
    activeChannels = widget.channelsList.where((channel) => channel.status == 1).toList();

    // ✅ Initialize focus nodes with scroll listeners
    _initializeChannelFocusNodes();

    // Set up focus for the first channel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusFirstGridItem();
    });

    _initializeAnimations();
    _startStaggeredAnimation();
  }

  // ✅ Initialize focus nodes with scroll functionality (same as Movies)
  void _initializeChannelFocusNodes() {
    // Safely dispose existing nodes first
    for (var entry in _channelFocusNodes.entries) {
      try {
        entry.value.removeListener(() {});
        entry.value.dispose();
      } catch (e) {
        print('⚠️ Error disposing channel focus node ${entry.key}: $e');
      }
    }

    _channelFocusNodes.clear();

    // Create focus nodes for all active channels with String keys
    for (int i = 0; i < activeChannels.length; i++) {
      String channelId = activeChannels[i].id.toString();
      _channelFocusNodes[channelId] = FocusNode()
        ..addListener(() {
          if (mounted && _channelFocusNodes[channelId]!.hasFocus) {
            setState(() {
              gridFocusedIndex = i;
            });
            _scrollToFocusedItem(channelId);
          }
        });
    }

    print('✅ Created ${_channelFocusNodes.length} channel grid focus nodes');
  }

  // ✅ Focus first grid item (same as Movies)
  void _focusFirstGridItem() {
    if (activeChannels.isNotEmpty && _channelFocusNodes.isNotEmpty) {
      final firstChannelId = activeChannels[0].id.toString();
      if (_channelFocusNodes.containsKey(firstChannelId)) {
        try {
          setState(() {
            gridFocusedIndex = 0;
          });
          FocusScope.of(context).requestFocus(_channelFocusNodes[firstChannelId]);
          print('✅ Focus set to first channel grid item: $firstChannelId');
        } catch (e) {
          print('⚠️ Error setting initial channel grid focus: $e');
        }
      }
    }
  }

  // ✅ Scroll to focused item (exactly like Movies)
  void _scrollToFocusedItem(String itemId) {
    if (!mounted) return;

    try {
      final focusNode = _channelFocusNodes[itemId];
      if (focusNode != null &&
          focusNode.hasFocus &&
          focusNode.context != null) {
        Scrollable.ensureVisible(
          focusNode.context!,
          alignment: 0.1, // Keep focused item visible
          duration: AnimationTiming.scroll,
          curve: Curves.easeInOutCubic,
        );
      }
    } catch (e) {
      print('⚠️ Error scrolling to focused channel item: $e');
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

  // ✅ Enhanced Grid Navigation (same as Movies)
  void _navigateGrid(LogicalKeyboardKey key) {
    if (_isLoading) return;

    int newIndex = gridFocusedIndex;
    final int totalItems = activeChannels.length;
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
      final newChannelId = activeChannels[newIndex].id.toString();
      if (_channelFocusNodes.containsKey(newChannelId)) {
        setState(() {
          gridFocusedIndex = newIndex;
        });
        FocusScope.of(context).requestFocus(_channelFocusNodes[newChannelId]);
        HapticFeedback.lightImpact();
        print('🎯 Navigated to channel grid item $newIndex');
      }
    }
  }

  // ✅ Enhanced Channel Tap Handler with better error handling
  Future<void> _handleGridChannelTap(NewsChannel channel) async {
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
                        'Loading Channel...',
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

      // ✅ Dynamic category assignment for grid view
      String categoryName = widget.categoryName == 'All'
          ? (channel.genres.toLowerCase().isNotEmpty
              ? channel.genres.toLowerCase()
              : 'live')
          : widget.categoryName.toLowerCase();

      // Current channel ko NewsItemModel में convert करें
      NewsItemModel currentChannel = NewsItemModel(
        id: channel.id.toString(),
        videoId: '',
        name: channel.name,
        description: channel.description ?? '',
        banner: channel.banner,
        poster: channel.banner,
        category: categoryName,
        url: channel.url,
        streamType: channel.streamType,
        type: channel.streamType,
        genres: channel.genres,
        status: channel.status.toString(),
        index: activeChannels.indexOf(channel).toString(),
        image: channel.banner,
        unUpdatedUrl: channel.url,
      );

      // ✅ Convert all active channels
      List<NewsItemModel> allChannels = activeChannels.map((ch) {
        String chCategoryName = widget.categoryName == 'All'
            ? (ch.genres.toLowerCase().isNotEmpty
                ? ch.genres.toLowerCase()
                : 'live')
            : widget.categoryName.toLowerCase();

        return NewsItemModel(
          id: ch.id.toString(),
          videoId: '',
          name: ch.name,
          description: ch.description ?? '',
          banner: ch.banner,
          poster: ch.banner,
          category: chCategoryName,
          url: ch.url,
          streamType: ch.streamType,
          type: ch.streamType,
          genres: ch.genres,
          status: ch.status.toString(),
          index: activeChannels.indexOf(ch).toString(),
          image: ch.banner,
          unUpdatedUrl: ch.url,
        );
      }).toList();

      if (mounted) {
        if (dialogShown) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        // VideoScreen navigate करें with all ACTIVE channels
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoScreen(
              videoUrl: currentChannel.url,
              bannerImageUrl: currentChannel.banner,
              startAtPosition: Duration.zero,
              videoType: currentChannel.streamType,
              channelList: allChannels,
              isLive: true,
              isVOD: false,
              isBannerSlider: false,
              source: 'isLiveScreen',
              isSearch: false,
              videoId: int.tryParse(currentChannel.id),
              unUpdatedUrl: currentChannel.url,
              name: currentChannel.name,
              // seasonId: null,
              // isLastPlayedStored: false,
              liveStatus: true,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        if (dialogShown) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        // ✅ Enhanced error handling
        String errorMessage = 'Error loading channel';
        if (e.toString().contains('network') ||
            e.toString().contains('connection')) {
          errorMessage = 'Network error. Please check your connection';
        } else if (e.toString().contains('format') ||
            e.toString().contains('codec')) {
          errorMessage = 'Stream format not supported';
        } else if (e.toString().contains('not found') ||
            e.toString().contains('404')) {
          errorMessage = 'Channel not found or unavailable';
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
              onPressed: () => _handleGridChannelTap(channel),
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
            final channelIndex = activeChannels.indexWhere((ch) => ch.id == channel.id);
            if (channelIndex != -1) {
              final channelId = channel.id.toString();
              if (_channelFocusNodes.containsKey(channelId)) {
                setState(() {
                  gridFocusedIndex = channelIndex;
                });
                FocusScope.of(context).requestFocus(_channelFocusNodes[channelId]);
                print('✅ Restored channel grid focus to ${channel.name}');
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
    _scrollController.dispose(); // ✅ Dispose ScrollController
    
    // ✅ Safely dispose all focus nodes
    for (var entry in _channelFocusNodes.entries) {
      try {
        entry.value.removeListener(() {});
        entry.value.dispose();
        print('✅ Disposed channel grid focus node: ${entry.key}');
      } catch (e) {
        print('⚠️ Error disposing channel grid focus node ${entry.key}: $e');
      }
    }
    _channelFocusNodes.clear();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorProvider>(
      builder: (context, colorProv, child) {
        final bgColor = colorProv.isItemFocused
            ? colorProv.dominantColor.withOpacity(0.1)
            : ProfessionalColors.primaryDark;

        return Scaffold(
          backgroundColor: ProfessionalColors.primaryDark,
          body: Container(
            // ✅ Background Gradient like Movies/VOD
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
                        height: MediaQuery.of(context).padding.top + 80, // AppBar total height
                      ),
                      Expanded(
                        child: _buildChannelsGrid(),
                      ),
                    ],
                  ),
                ),

                // ✅ AppBar positioned on top with proper z-index (VOD Style)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildProfessionalAppBar(),
                ),

                // ✅ Loading Overlay - Always on top
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.7),
                      child: const Center(
                        child: ProfessionalLoadingIndicator(message: 'Loading Channel...'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ Professional AppBar with VOD/Movies Style
  Widget _buildProfessionalAppBar() {
    return Container(
      // ✅ Enhanced AppBar with proper z-index and blur effect
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ProfessionalColors.primaryDark.withOpacity(0.95), // More opaque
            ProfessionalColors.surfaceDark.withOpacity(0.9),
            ProfessionalColors.surfaceDark.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
        // ✅ Add bottom border for better separation (Live theme color)
        border: Border(
          bottom: BorderSide(
            color: ProfessionalColors.accentGreen.withOpacity(0.2), // Live theme color
            width: 1,
          ),
        ),
        // ✅ Add subtle shadow
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
          // ✅ Add blur effect for modern look
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 40,
              right: 40,
              bottom: 5, // Add bottom padding
            ),
            child: Row(
              children: [
                // ✅ Back Button with Live theme colors
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        ProfessionalColors.accentGreen.withOpacity(0.3), // Live theme
                        ProfessionalColors.accentBlue.withOpacity(0.3),
                      ],
                    ),
                    // ✅ Add elevation to back button
                    boxShadow: [
                      BoxShadow(
                        color: ProfessionalColors.accentGreen.withOpacity(0.3),
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
                      // ✅ Title with Live theme colors and better shadow
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            ProfessionalColors.accentGreen, // Live theme
                            ProfessionalColors.accentBlue,
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
                      // ✅ Count badge with Live theme colors and elevation
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ProfessionalColors.accentGreen.withOpacity(0.3), // Live theme
                              ProfessionalColors.accentBlue.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: ProfessionalColors.accentGreen.withOpacity(0.4),
                            width: 1,
                          ),
                          // ✅ Add elevation to count badge
                          boxShadow: [
                            BoxShadow(
                              color: ProfessionalColors.accentGreen.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${activeChannels.length} Live Channels Available',
                          style: const TextStyle(
                            color: ProfessionalColors.accentGreen, // Live theme
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

  Widget _buildChannelsGrid() {
    if (activeChannels.isEmpty) {
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
                    ProfessionalColors.accentGreen.withOpacity(0.2),
                    ProfessionalColors.accentGreen.withOpacity(0.1),
                  ],
                ),
              ),
              child: const Icon(
                Icons.tv_outlined,
                size: 40,
                color: ProfessionalColors.accentGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Live ${widget.categoryTitle} Channels',
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
        if (event is RawKeyDownEvent && !_isLoading) {
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
            if (gridFocusedIndex < activeChannels.length) {
              _handleGridChannelTap(activeChannels[gridFocusedIndex]);
            }
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          controller: _scrollController, // ✅ Added ScrollController
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            mainAxisSpacing: 16,
            crossAxisSpacing: 25,
            childAspectRatio: 1.5,
          ),
          itemCount: activeChannels.length,
          clipBehavior: Clip.none, // ✅ Allow shadows to be visible
          itemBuilder: (context, index) {
            final channel = activeChannels[index];
            String channelId = channel.id.toString();

            // ✅ Safe check for focus node existence
            if (!_channelFocusNodes.containsKey(channelId)) {
              print('⚠️ Channel grid focus node not found for Channel: $channelId');
              return const SizedBox.shrink();
            }

            return AnimatedBuilder(
              animation: _staggerController,
              builder: (context, child) {
                final delay = (index / activeChannels.length) * 0.5;
                final animationValue = Interval(
                  delay,
                  delay + 0.5,
                  curve: Curves.easeOutCubic,
                ).transform(_staggerController.value);

                return Transform.translate(
                  offset: Offset(0, 50 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: ProfessionalGridChannelCard(
                      channel: channel,
                      focusNode: _channelFocusNodes[channelId]!,
                      onTap: () => _handleGridChannelTap(channel),
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