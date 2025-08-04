







// import 'dart:async';
// import 'dart:convert';
// import 'package:mobi_tv_entertainment/video_widget/custom_video_player.dart';
// import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as https;
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/movies_screen/movies.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player.dart';
// import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../video_widget/socket_service.dart';

// enum NavigationMode {
//   seasons,
//   episodes,
// }

// // Cache Manager Class for Web Series Data
// class WebSeriesCacheManager {
//   static const String _cacheKeyPrefix = 'web_series_cache_';
//   static const String _episodesCacheKeyPrefix = 'episodes_cache_';
//   static const String _lastUpdatedKeyPrefix = 'last_updated_';
//   static const Duration _cacheValidDuration =
//       Duration(hours: 6); // Cache validity period

//   // Save seasons data to cache
//   static Future<void> saveSeasonsCache(
//       int showId, List<SeasonModel> seasons) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cacheKey = '$_cacheKeyPrefix$showId';
//       final lastUpdatedKey = '$_lastUpdatedKeyPrefix$showId';

//       final seasonsJson = seasons
//           .map((season) => {
//                 'id': season.id,
//                 'Session_Name': season.sessionName,
//                 'banner': season.banner,
//                 'season_order': season.seasonOrder,
//                 'web_series_id': season.webSeriesId,
//                 'status': season.status,
//               })
//           .toList();

//       await prefs.setString(cacheKey, jsonEncode(seasonsJson));
//       await prefs.setInt(lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);

//       print('✅ Web Series seasons cache saved for show $showId');
//     } catch (e) {
//       print('❌ Error saving web series seasons cache: $e');
//     }
//   }

//   // Get seasons data from cache
//   static Future<List<SeasonModel>?> getSeasonsCache(int showId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cacheKey = '$_cacheKeyPrefix$showId';
//       final lastUpdatedKey = '$_lastUpdatedKeyPrefix$showId';

//       final cachedData = prefs.getString(cacheKey);
//       final lastUpdated = prefs.getInt(lastUpdatedKey);

//       if (cachedData == null || lastUpdated == null) {
//         return null;
//       }

//       // Check if cache is still valid
//       final cacheAge = DateTime.now().millisecondsSinceEpoch - lastUpdated;
//       final isExpired = cacheAge > _cacheValidDuration.inMilliseconds;

//       if (isExpired) {
//         print('⏰ Web Series seasons cache expired for show $showId');
//         return null;
//       }

//       final List<dynamic> seasonsJson = jsonDecode(cachedData);
//       final seasons =
//           seasonsJson.map((json) => SeasonModel.fromJson(json)).toList();

//       print(
//           '✅ Web Series seasons cache loaded for show $showId (${seasons.length} seasons)');
//       return seasons;
//     } catch (e) {
//       print('❌ Error loading web series seasons cache: $e');
//       return null;
//     }
//   }

//   // Save episodes data to cache
//   static Future<void> saveEpisodesCache(
//       int seasonId, List<NewsItemModel> episodes) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cacheKey = '$_episodesCacheKeyPrefix$seasonId';
//       final lastUpdatedKey = '${_lastUpdatedKeyPrefix}episodes_$seasonId';

//       final episodesJson = episodes
//           .map((episode) => {
//                 'id': episode.id,
//                 'name': episode.name,
//                 'description': episode.description,
//                 'banner': episode.banner,
//                 'url': episode.url,
//                 'status': episode.status,
//                 // Add other fields as needed
//               })
//           .toList();

//       await prefs.setString(cacheKey, jsonEncode(episodesJson));
//       await prefs.setInt(lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);

//       print('✅ Web Series episodes cache saved for season $seasonId');
//     } catch (e) {
//       print('❌ Error saving web series episodes cache: $e');
//     }
//   }

//   // Get episodes data from cache
//   static Future<List<NewsItemModel>?> getEpisodesCache(int seasonId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cacheKey = '$_episodesCacheKeyPrefix$seasonId';
//       final lastUpdatedKey = '${_lastUpdatedKeyPrefix}episodes_$seasonId';

//       final cachedData = prefs.getString(cacheKey);
//       final lastUpdated = prefs.getInt(lastUpdatedKey);

//       if (cachedData == null || lastUpdated == null) {
//         return null;
//       }

//       // Check if cache is still valid
//       final cacheAge = DateTime.now().millisecondsSinceEpoch - lastUpdated;
//       final isExpired = cacheAge > _cacheValidDuration.inMilliseconds;

//       if (isExpired) {
//         print('⏰ Web Series episodes cache expired for season $seasonId');
//         return null;
//       }

//       final List<dynamic> episodesJson = jsonDecode(cachedData);
//       final episodes =
//           episodesJson.map((json) => NewsItemModel.fromJson(json)).toList();

//       print(
//           '✅ Web Series episodes cache loaded for season $seasonId (${episodes.length} episodes)');
//       return episodes;
//     } catch (e) {
//       print('❌ Error loading web series episodes cache: $e');
//       return null;
//     }
//   }

//   // Compare two season lists and check if they're different
//   static bool areSeasonsDifferent(
//       List<SeasonModel> cached, List<SeasonModel> fresh) {
//     if (cached.length != fresh.length) return true;

//     for (int i = 0; i < cached.length; i++) {
//       final c = cached[i];
//       final f = fresh[i];

//       if (c.id != f.id ||
//           c.sessionName != f.sessionName ||
//           c.status != f.status ||
//           c.banner != f.banner) {
//         return true;
//       }
//     }
//     return false;
//   }

//   // Compare two episode lists and check if they're different
//   static bool areEpisodesDifferent(
//       List<NewsItemModel> cached, List<NewsItemModel> fresh) {
//     if (cached.length != fresh.length) return true;

//     for (int i = 0; i < cached.length; i++) {
//       final c = cached[i];
//       final f = fresh[i];

//       if (c.id != f.id ||
//           c.name != f.name ||
//           c.status != f.status ||
//           c.url != f.url) {
//         return true;
//       }
//     }
//     return false;
//   }

//   // Clear all cache for a specific show
//   static Future<void> clearShowCache(int showId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('$_cacheKeyPrefix$showId');
//       await prefs.remove('$_lastUpdatedKeyPrefix$showId');
//       print('🗑️ Cleared web series cache for show $showId');
//     } catch (e) {
//       print('❌ Error clearing web series cache: $e');
//     }
//   }
// }

// class SeasonModel {
//   final int id;
//   final String sessionName;
//   final String banner;
//   final int seasonOrder;
//   final int webSeriesId;
//   final int status;

//   SeasonModel({
//     required this.id,
//     required this.sessionName,
//     required this.banner,
//     required this.seasonOrder,
//     required this.webSeriesId,
//     required this.status,
//   });

//   factory SeasonModel.fromJson(Map<String, dynamic> json) {
//     return SeasonModel(
//       id: json['id'] ?? 0,
//       sessionName: json['Session_Name'] ?? '',
//       banner: json['banner'] ?? '',
//       seasonOrder: json['season_order'] ?? 1,
//       webSeriesId: json['web_series_id'] ?? 0,
//       status: json['status'] ?? 1,
//     );
//   }
// }

// class ReligiousChannelDetailsPage extends StatefulWidget {
//   final int id;
//   final String banner;
//   final String poster;
//   final String name;

//   const ReligiousChannelDetailsPage({
//     Key? key,
//     required this.id,
//     required this.banner,
//     required this.poster,
//     required this.name,
//   }) : super(key: key);

//   @override
//   _ReligiousChannelDetailsPageState createState() => _ReligiousChannelDetailsPageState();
// }

// class _ReligiousChannelDetailsPageState extends State<ReligiousChannelDetailsPage>
//     with WidgetsBindingObserver, TickerProviderStateMixin {
//   final SocketService _socketService = SocketService();
//   final ScrollController _scrollController = ScrollController();
//   final ScrollController _seasonsScrollController = ScrollController();
//   final FocusNode _mainFocusNode = FocusNode();

//   // Data structures
//   List<SeasonModel> _seasons = [];
//   Map<int, List<NewsItemModel>> _episodesMap = {};

//   int _selectedSeasonIndex = 0;
//   int _selectedEpisodeIndex = 0;

//   NavigationMode _currentMode = NavigationMode.seasons;

//   final Map<int, FocusNode> _seasonsFocusNodes = {};
//   final Map<String, FocusNode> _episodeFocusNodes = {};

//   String _errorMessage = "";
//   String _authKey = '';

//   bool _showInstructions = true;
//   Timer? _instructionTimer;

//   // Filtered data variables for active content
//   List<SeasonModel> _filteredSeasons = [];
//   Map<int, List<NewsItemModel>> _filteredEpisodesMap = {};

//   // Loading states
//   bool _isLoading = false; // Only true when no cache and loading from API
//   bool _isProcessing = false;
//   bool _isLoadingEpisodes = false;
//   bool _isBackgroundRefreshing = false; // New flag for background refresh

//   // Animation Controllers
//   late AnimationController _navigationModeController;
//   late AnimationController _instructionController;
//   late AnimationController _pageTransitionController;

//   // Animations
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   // Filter methods for active content
//   List<SeasonModel> _filterActiveSeasons(List<SeasonModel> seasons) {
//     return seasons.where((season) => season.status == 1).toList();
//   }

//   List<NewsItemModel> _filterActiveEpisodes(List<NewsItemModel> episodes) {
//     return episodes.where((episode) {
//       try {
//         final status = episode.status;
//         if (status == null) return false;

//         if (status is int) {
//           return status == 1;
//         } else if (status is String) {
//           return status == '1';
//         }
//         return false;
//       } catch (e) {
//         return false;
//       }
//     }).toList();
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _socketService.initSocket();

//     _initializeAnimations();
//     _loadAuthKey();
//     _startInstructionTimer();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _scrollController.dispose();
//     _seasonsScrollController.dispose();
//     _mainFocusNode.dispose();
//     _seasonsFocusNodes.values.forEach((node) => node.dispose());
//     _episodeFocusNodes.values.forEach((node) => node.dispose());
//     _socketService.dispose();
//     _navigationModeController.dispose();
//     _instructionController.dispose();
//     _pageTransitionController.dispose();
//     _instructionTimer?.cancel();
//     super.dispose();
//   }

//   // Load auth key and initialize page
//   Future<void> _loadAuthKey() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       setState(() {
//         _authKey = prefs.getString('auth_key') ?? '';
//         if (_authKey.isEmpty) {
//           _authKey = globalAuthKey ?? '';
//         }
//       });

//       if (_authKey.isEmpty) {
//         setState(() {
//           _errorMessage = "Authentication required. Please login again.";
//           _isLoading = false;
//         });
//         return;
//       }

//       await _initializePageWithCache();
//     } catch (e) {
//       setState(() {
//         _errorMessage = "Error loading authentication: ${e.toString()}";
//         _isLoading = false;
//       });
//     }
//   }

//   // Enhanced initialization with smart caching
//   Future<void> _initializePageWithCache() async {
//     print('🚀 Initializing web series page with cache for show ${widget.id}');

//     // Try to load from cache first
//     final cachedSeasons =
//         await WebSeriesCacheManager.getSeasonsCache(widget.id);

//     if (cachedSeasons != null && cachedSeasons.isNotEmpty) {
//       // Show cached data immediately
//       print('⚡ Loading web series from cache instantly');
//       await _loadSeasonsFromCache(cachedSeasons);

//       // Start background refresh
//       _performBackgroundRefresh();
//     } else {
//       // No cache available, load from API with loading indicator
//       print('📡 No web series cache available, loading from API');
//       await _fetchSeasonsFromAPI(showLoading: true);
//     }
//   }

//   // Load seasons from cache and update UI instantly
//   Future<void> _loadSeasonsFromCache(List<SeasonModel> cachedSeasons) async {
//     final activeSeasons = _filterActiveSeasons(cachedSeasons);

//     setState(() {
//       _seasons = cachedSeasons;
//       _filteredSeasons = activeSeasons;
//       _isLoading = false;
//       _errorMessage = "";
//     });

//     // Create focus nodes for active seasons
//     _seasonsFocusNodes.clear();
//     for (int i = 0; i < _filteredSeasons.length; i++) {
//       _seasonsFocusNodes[i] = FocusNode();
//     }

//     if (_filteredSeasons.isNotEmpty) {
//       _setNavigationMode(NavigationMode.seasons);
//       _pageTransitionController.forward();

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           _seasonsFocusNodes[0]?.requestFocus();
//         }
//       });
//     }
//   }

//   // Perform background refresh without showing loading indicators
//   Future<void> _performBackgroundRefresh() async {
//     print('🔄 Starting web series background refresh');
//     setState(() {
//       _isBackgroundRefreshing = true;
//     });

//     try {
//       final freshSeasons = await _fetchSeasonsFromAPIDirectly();

//       if (freshSeasons != null) {
//         // Compare with cached data
//         final cachedSeasons = _seasons;
//         final hasChanges = WebSeriesCacheManager.areSeasonsDifferent(
//             cachedSeasons, freshSeasons);

//         if (hasChanges) {
//           print('🔄 Web series changes detected, updating UI silently');

//           // Save new data to cache
//           await WebSeriesCacheManager.saveSeasonsCache(widget.id, freshSeasons);

//           // Update UI without disrupting user experience
//           await _updateSeasonsData(freshSeasons);
//         } else {
//           print('✅ No web series changes detected in background refresh');
//         }
//       }
//     } catch (e) {
//       print('❌ Web series background refresh failed: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isBackgroundRefreshing = false;
//         });
//       }
//     }
//   }

//   // Update seasons data while preserving user's current selection
//   Future<void> _updateSeasonsData(List<SeasonModel> newSeasons) async {
//     final activeSeasons = _filterActiveSeasons(newSeasons);
//     final currentSelectedSeasonId = _filteredSeasons.isNotEmpty &&
//             _selectedSeasonIndex < _filteredSeasons.length
//         ? _filteredSeasons[_selectedSeasonIndex].id
//         : null;

//     setState(() {
//       _seasons = newSeasons;
//       _filteredSeasons = activeSeasons;
//     });

//     // Try to maintain user's current selection
//     if (currentSelectedSeasonId != null) {
//       final newIndex =
//           _filteredSeasons.indexWhere((s) => s.id == currentSelectedSeasonId);
//       if (newIndex >= 0) {
//         setState(() {
//           _selectedSeasonIndex = newIndex;
//         });
//       }
//     }

//     // Recreate focus nodes if needed
//     _seasonsFocusNodes.clear();
//     for (int i = 0; i < _filteredSeasons.length; i++) {
//       _seasonsFocusNodes[i] = FocusNode();
//     }
//   }

//   // Fetch seasons from API with loading indicator
//   Future<void> _fetchSeasonsFromAPI({bool showLoading = false}) async {
//     if (showLoading) {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = "Loading seasons...";
//       });
//     }

//     try {
//       final seasons = await _fetchSeasonsFromAPIDirectly();

//       if (seasons != null) {
//         // Save to cache
//         await WebSeriesCacheManager.saveSeasonsCache(widget.id, seasons);

//         // Update UI
//         await _loadSeasonsFromCache(seasons);
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = "Error: ${e.toString()}";
//       });
//     }
//   }

//   // Direct API call for seasons
//   Future<List<SeasonModel>?> _fetchSeasonsFromAPIDirectly() async {
//     final prefs = await SharedPreferences.getInstance();
//     final authKey = prefs.getString('auth_key') ?? _authKey;

//     final response = await https.get(
//       Uri.parse(
//           'https://acomtv.coretechinfo.com/public/api/getSeasons/${widget.id}'),
//       headers: {
//         'auth-key': authKey,
//         'Accept': 'application/json',
//         'Content-Type': 'application/json',
//       },
//     ).timeout(const Duration(seconds: 15));

//     if (response.statusCode == 200) {
//       String responseBody = response.body.trim();
//       if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
//         final List<dynamic> data = jsonDecode(responseBody);
//         return data.map((season) => SeasonModel.fromJson(season)).toList();
//       }
//     }

//     throw Exception('Failed to load seasons (${response.statusCode})');
//   }

//   // Enhanced episodes fetching with cache
//   Future<void> _fetchEpisodes(int seasonId) async {
//     // Check if already loaded
//     if (_filteredEpisodesMap.containsKey(seasonId)) {
//       setState(() {
//         _selectedSeasonIndex =
//             _filteredSeasons.indexWhere((season) => season.id == seasonId);
//         _selectedEpisodeIndex = 0;
//       });
//       _setNavigationMode(NavigationMode.episodes);
//       return;
//     }

//     // Try cache first
//     final cachedEpisodes =
//         await WebSeriesCacheManager.getEpisodesCache(seasonId);

//     if (cachedEpisodes != null) {
//       // Load from cache instantly
//       await _loadEpisodesFromCache(seasonId, cachedEpisodes);

//       // Start background refresh for episodes
//       _performEpisodesBackgroundRefresh(seasonId);
//     } else {
//       // Load from API with loading indicator
//       await _fetchEpisodesFromAPI(seasonId, showLoading: true);
//     }
//   }

//   // Load episodes from cache
//   Future<void> _loadEpisodesFromCache(
//       int seasonId, List<NewsItemModel> cachedEpisodes) async {
//     final activeEpisodes = _filterActiveEpisodes(cachedEpisodes);

//     _episodeFocusNodes.clear();
//     for (var episode in activeEpisodes) {
//       _episodeFocusNodes[episode.id] = FocusNode();
//     }

//     setState(() {
//       _episodesMap[seasonId] = cachedEpisodes;
//       _filteredEpisodesMap[seasonId] = activeEpisodes;
//       _selectedSeasonIndex =
//           _filteredSeasons.indexWhere((s) => s.id == seasonId);
//       _selectedEpisodeIndex = 0;
//       _isLoadingEpisodes = false;
//     });

//     _setNavigationMode(NavigationMode.episodes);
//   }

//   // Background refresh for episodes
//   Future<void> _performEpisodesBackgroundRefresh(int seasonId) async {
//     try {
//       final freshEpisodes = await _fetchEpisodesFromAPIDirectly(seasonId);

//       if (freshEpisodes != null) {
//         final cachedEpisodes = _episodesMap[seasonId] ?? [];
//         final hasChanges = WebSeriesCacheManager.areEpisodesDifferent(
//             cachedEpisodes, freshEpisodes);

//         if (hasChanges) {
//           print('🔄 Web series episodes changes detected for season $seasonId');

//           // Save to cache
//           await WebSeriesCacheManager.saveEpisodesCache(
//               seasonId, freshEpisodes);

//           // Update UI
//           await _loadEpisodesFromCache(seasonId, freshEpisodes);
//         }
//       }
//     } catch (e) {
//       print('❌ Web series episodes background refresh failed: $e');
//     }
//   }

//   // Fetch episodes from API with loading indicator
//   Future<void> _fetchEpisodesFromAPI(int seasonId,
//       {bool showLoading = false}) async {
//     if (showLoading) {
//       setState(() {
//         _isLoadingEpisodes = true;
//       });
//     }

//     try {
//       final episodes = await _fetchEpisodesFromAPIDirectly(seasonId);

//       if (episodes != null) {
//         // Save to cache
//         await WebSeriesCacheManager.saveEpisodesCache(seasonId, episodes);

//         // Update UI
//         await _loadEpisodesFromCache(seasonId, episodes);
//       }
//     } catch (e) {
//       setState(() {
//         _isLoadingEpisodes = false;
//         _errorMessage = "Error loading episodes: ${e.toString()}";
//       });
//     }
//   }

//   // Direct API call for episodes
//   Future<List<NewsItemModel>?> _fetchEpisodesFromAPIDirectly(
//       int seasonId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final authKey = prefs.getString('auth_key') ?? _authKey;

//     final response = await https.get(
//       Uri.parse(
//           'https://acomtv.coretechinfo.com/public/api/getEpisodes/$seasonId/0'),
//       headers: {
//         'auth-key': authKey,
//         'Accept': 'application/json',
//         'Content-Type': 'application/json',
//       },
//     ).timeout(const Duration(seconds: 15));

//     if (response.statusCode == 200) {
//       String responseBody = response.body.trim();
//       if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
//         final List<dynamic> data = jsonDecode(responseBody);
//         return data.map((e) => NewsItemModel.fromJson(e)).toList();
//       }
//     }

//     throw Exception('Failed to load episodes for season $seasonId');
//   }

//   // Method to refresh data when returning from video player
//   Future<void> _refreshDataOnReturn() async {
//     print('🔄 Refreshing web series data on return from video player');
//     await _performBackgroundRefresh();

//     // Also refresh current season's episodes if any are loaded
//     if (_filteredSeasons.isNotEmpty &&
//         _selectedSeasonIndex < _filteredSeasons.length) {
//       final currentSeasonId = _filteredSeasons[_selectedSeasonIndex].id;
//       if (_filteredEpisodesMap.containsKey(currentSeasonId)) {
//         await _performEpisodesBackgroundRefresh(currentSeasonId);
//       }
//     }
//   }

//   // Updated play episode method with refresh on return
//   Future<void> _playEpisode(NewsItemModel episode) async {
//     if (_isProcessing) return;

//     setState(() => _isProcessing = true);

//     try {
//       String url = episode.url;

//       if (mounted) {
//         dynamic result;

//         if (isYoutubeUrl(episode.url)) {
//           result = await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => CustomYoutubePlayer(
//                 videoUrl: episode.url,
//                 name: episode.name,
//               ),
//             ),
//           );
//         } else {
//           result = await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => CustomVideoPlayer(
//                 videoUrl: episode.url,
//               ),
//             ),
//           );
//         }

//         // Refresh data after returning from video player
//         await _refreshDataOnReturn();
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Error playing video'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isProcessing = false);
//       }
//     }
//   }

//   bool isYoutubeUrl(String? url) {
//     if (url == null || url.isEmpty) return false;
//     url = url.toLowerCase().trim();
//     return RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url) ||
//         url.contains('youtube.com') ||
//         url.contains('youtu.be') ||
//         url.contains('youtube.com/shorts/');
//   }

//   void _selectSeason(int index) {
//     if (index >= 0 && index < _filteredSeasons.length) {
//       setState(() {
//         _selectedSeasonIndex = index;
//       });
//       _fetchEpisodes(_filteredSeasons[index].id);
//     }
//   }

//   void _handleSeasonsNavigation(RawKeyEvent event) {
//     switch (event.logicalKey) {
//       case LogicalKeyboardKey.arrowDown:
//         if (_selectedSeasonIndex < _filteredSeasons.length - 1) {
//           setState(() {
//             _selectedSeasonIndex++;
//           });
//           _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
//         }
//         break;

//       case LogicalKeyboardKey.arrowUp:
//         if (_selectedSeasonIndex > 0) {
//           setState(() {
//             _selectedSeasonIndex--;
//           });
//           _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
//         }
//         break;

//       case LogicalKeyboardKey.enter:
//       case LogicalKeyboardKey.select:
//       case LogicalKeyboardKey.arrowRight:
//         if (_filteredSeasons.isNotEmpty) {
//           _selectSeason(_selectedSeasonIndex);
//         }
//         break;
//     }
//   }

//   void _handleEpisodesNavigation(RawKeyEvent event) {
//     final episodes = _currentEpisodes;

//     switch (event.logicalKey) {
//       case LogicalKeyboardKey.arrowDown:
//         if (_selectedEpisodeIndex < episodes.length - 1) {
//           setState(() {
//             _selectedEpisodeIndex++;
//           });
//           _scrollAndFocusEpisode(_selectedEpisodeIndex);
//         }
//         break;

//       case LogicalKeyboardKey.arrowUp:
//         if (_selectedEpisodeIndex > 0) {
//           setState(() {
//             _selectedEpisodeIndex--;
//           });
//           _scrollAndFocusEpisode(_selectedEpisodeIndex);
//         }
//         break;

//       case LogicalKeyboardKey.enter:
//       case LogicalKeyboardKey.select:
//         if (episodes.isNotEmpty) {
//           _playEpisode(episodes[_selectedEpisodeIndex]);
//         }
//         break;

//       case LogicalKeyboardKey.arrowLeft:
//       case LogicalKeyboardKey.escape:
//         _setNavigationMode(NavigationMode.seasons);
//         break;
//     }
//   }

//   List<NewsItemModel> get _currentEpisodes {
//     if (_filteredSeasons.isEmpty ||
//         _selectedSeasonIndex >= _filteredSeasons.length) {
//       return [];
//     }
//     return _filteredEpisodesMap[_filteredSeasons[_selectedSeasonIndex].id] ??
//         [];
//   }

//   void _setNavigationMode(NavigationMode mode) {
//     setState(() {
//       _currentMode = mode;
//     });

//     if (mode == NavigationMode.seasons) {
//       _navigationModeController.reverse();
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
//       });
//     } else {
//       _navigationModeController.forward();
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_currentEpisodes.isNotEmpty) {
//           _episodeFocusNodes[_currentEpisodes[_selectedEpisodeIndex].id]
//               ?.requestFocus();
//         }
//       });
//     }
//   }

//   void _handleKeyEvent(RawKeyEvent event) {
//     if (_isProcessing) return;

//     if (event is RawKeyDownEvent) {
//       switch (_currentMode) {
//         case NavigationMode.seasons:
//           _handleSeasonsNavigation(event);
//           break;
//         case NavigationMode.episodes:
//           _handleEpisodesNavigation(event);
//           break;
//       }
//     }
//   }

//   Future<void> _scrollAndFocusEpisode(int index) async {
//     if (index < 0 || index >= _currentEpisodes.length) return;

//     final context = _episodeFocusNodes[_currentEpisodes[index].id]?.context;
//     if (context != null) {
//       await Scrollable.ensureVisible(
//         context,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         alignment: 0.3,
//       );
//     }
//   }

//   void _initializeAnimations() {
//     _navigationModeController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );

//     _instructionController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _pageTransitionController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _pageTransitionController,
//       curve: Curves.easeInOut,
//     ));

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0.0, 0.1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _pageTransitionController,
//       curve: Curves.easeOutCubic,
//     ));
//   }

//   void _startInstructionTimer() {
//     _instructionController.forward();
//     _instructionTimer = Timer(const Duration(seconds: 6), () {
//       if (mounted) {
//         _instructionController.reverse();
//         setState(() {
//           _showInstructions = false;
//         });
//       }
//     });
//   }

//   void _showInstructionsAgain() {
//     setState(() {
//       _showInstructions = true;
//     });
//     _instructionController.forward();
//     _startInstructionTimer();
//   }

//   // Helper method for URL validation
//   bool _isValidImageUrl(String url) {
//     if (url.isEmpty) return false;

//     try {
//       final uri = Uri.parse(url);
//       if (!uri.hasAbsolutePath) return false;
//       if (uri.scheme != 'http' && uri.scheme != 'https') return false;

//       final path = uri.path.toLowerCase();
//       return path.contains('.jpg') ||
//           path.contains('.jpeg') ||
//           path.contains('.png') ||
//           path.contains('.webp') ||
//           path.contains('.gif') ||
//           path.contains('image') ||
//           path.contains('thumb') ||
//           path.contains('banner');
//     } catch (e) {
//       return false;
//     }
//   }

//   // Enhanced image widget builder
//   Widget _buildEnhancedImage({
//     required String imageUrl,
//     required double width,
//     required double height,
//     BoxFit fit = BoxFit.cover,
//     Widget? fallbackWidget,
//   }) {
//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.grey[800],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: _isValidImageUrl(imageUrl)
//             ? CachedNetworkImage(
//                 imageUrl: imageUrl,
//                 width: width,
//                 height: height,
//                 fit: fit,
//                 placeholder: (context, url) => Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.grey[800]!, Colors.grey[700]!],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                   ),
//                   child: const Center(
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//                     ),
//                   ),
//                 ),
//                 errorWidget: (context, url, error) =>
//                     fallbackWidget ??
//                     _buildDefaultImagePlaceholder(width, height),
//                 fadeInDuration: const Duration(milliseconds: 300),
//                 fadeOutDuration: const Duration(milliseconds: 100),
//               )
//             : fallbackWidget ?? _buildDefaultImagePlaceholder(width, height),
//       ),
//     );
//   }

//   // Default placeholder builder
//   Widget _buildDefaultImagePlaceholder(double width, double height) {
//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.grey[800]!, Colors.grey[700]!],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.broken_image, color: Colors.grey, size: 32),
//             SizedBox(height: 4),
//             Text(
//               "No Image",
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 10,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: RawKeyboardListener(
//         focusNode: _mainFocusNode,
//         autofocus: true,
//         onKey: _handleKeyEvent,
//         child: Stack(
//           children: [
//             // Beautiful Background
//             _buildBackgroundLayer(),

//             // Main Content with proper spacing
//             _buildMainContentWithLayout(),

//             // Top Navigation Bar (Fixed Position)
//             _buildTopNavigationBar(),

//             // Help Button (Fixed Position)
//             _buildHelpButton(),

//             // Instructions Overlay (Bottom)
//             if (_showInstructions) _buildInstructionsOverlay(),

//             // Processing Overlay
//             if (_isProcessing) _buildProcessingOverlay(),

//             // Background refresh indicator (subtle)
//             if (_isBackgroundRefreshing) _buildBackgroundRefreshIndicator(),
//           ],
//         ),
//       ),
//     );
//   }

//   // New method to show subtle background refresh indicator
//   Widget _buildBackgroundRefreshIndicator() {
//     return Positioned(
//       top: 100,
//       right: 20,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: Colors.blue.withOpacity(0.8),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.blue.withOpacity(0.3),
//               blurRadius: 8,
//               spreadRadius: 2,
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//               width: 12,
//               height: 12,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//               ),
//             ),
//             const SizedBox(width: 6),
//             const Text(
//               'Updating...',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 10,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBackgroundLayer() {
//     return Stack(
//       children: [
//         // Background Image
//         Positioned.fill(
//           child: Image.network(
//             widget.banner,
//             fit: BoxFit.cover,
//             errorBuilder: (_, __, ___) => Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Color(0xFF1a1a2e),
//                     Color(0xFF16213e),
//                     Color(0xFF0f0f23),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//             ),
//           ),
//         ),

//         // Gradient Overlays for better readability
//         Positioned.fill(
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.black.withOpacity(0.4),
//                   Colors.black.withOpacity(0.7),
//                   Colors.black.withOpacity(0.9),
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),
//         ),

//         // Side gradients for better separation
//         Positioned.fill(
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.black.withOpacity(0.8),
//                   Colors.transparent,
//                   Colors.black.withOpacity(0.6),
//                 ],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTopNavigationBar() {
//     return Positioned(
//       top: 0,
//       left: 0,
//       right: 0,
//       child: Container(
//         height: 100,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Colors.black.withOpacity(0.9),
//               Colors.black.withOpacity(0.7),
//               Colors.transparent,
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             child: Row(
//               children: [
//                 // Current Mode Indicator
//                 AnimatedBuilder(
//                   animation: _navigationModeController,
//                   builder: (context, child) {
//                     return Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.8),
//                         borderRadius: BorderRadius.circular(25),
//                         border: Border.all(
//                           color: _currentMode == NavigationMode.seasons
//                               ? Colors.blue
//                               : Colors.green,
//                           width: 5,
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: (_currentMode == NavigationMode.seasons
//                                     ? Colors.blue
//                                     : Colors.green)
//                                 .withOpacity(0.3),
//                             blurRadius: 8,
//                             spreadRadius: 2,
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             _currentMode == NavigationMode.seasons
//                                 ? Icons.list_alt
//                                 : Icons.play_circle_outline,
//                             color: _currentMode == NavigationMode.seasons
//                                 ? Colors.blue
//                                 : Colors.green,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             _currentMode == NavigationMode.seasons
//                                 ? 'BROWSING SEASONS'
//                                 : 'BROWSING EPISODES',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),

//                 const Spacer(),

//                 // Series Title
//                 Expanded(
//                   flex: 2,
//                   child: Center(
//                     child: Text(
//                       widget.name.toUpperCase(),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                         letterSpacing: 1.5,
//                       ),
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ),

//                 const Spacer(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHelpButton() {
//     return Positioned(
//       top: 50,
//       right: 20,
//       child: SafeArea(
//         child: GestureDetector(
//           onTap: _showInstructionsAgain,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.8),
//               borderRadius: BorderRadius.circular(25),
//               border:
//                   Border.all(color: Colors.white.withOpacity(0.5), width: 1),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.white.withOpacity(0.1),
//                   blurRadius: 8,
//                   spreadRadius: 1,
//                 ),
//               ],
//             ),
//             child: const Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.help_outline, color: Colors.white, size: 18),
//                 SizedBox(width: 6),
//                 Text(
//                   'HELP',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMainContentWithLayout() {
//     return Positioned(
//       top: 100, // Below navigation bar
//       left: 0,
//       right: 0,
//       bottom: 80, // Above instructions
//       child: FadeTransition(
//         opacity: _fadeAnimation,
//         child: SlideTransition(
//           position: _slideAnimation,
//           child: _buildMainContent(),
//         ),
//       ),
//     );
//   }

//   Widget _buildMainContent() {
//     if (_isLoading && _seasons.isEmpty) {
//       return _buildLoadingWidget();
//     }

//     if (_errorMessage.isNotEmpty && _seasons.isEmpty) {
//       return _buildErrorWidget();
//     }

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Left Panel - Seasons
//           Expanded(
//             flex: 2,
//             child: _buildSeasonsPanel(),
//           ),

//           const SizedBox(width: 20),

//           // Right Panel - Episodes
//           Expanded(
//             flex: 3,
//             child: _buildEpisodesPanel(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSeasonsPanel() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: _currentMode == NavigationMode.seasons
//               ? Colors.blue.withOpacity(0.5)
//               : Colors.white.withOpacity(0.1),
//           width: 2,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.blue.withOpacity(0.2),
//                   Colors.transparent,
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(14),
//                 topRight: Radius.circular(14),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(
//                     Icons.list_alt,
//                     color: Colors.blue,
//                     size: 24,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 const Text(
//                   "ACTIVE SEASONS",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.0,
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     '${_filteredSeasons.length}',
//                     style: const TextStyle(
//                       color: Colors.blue,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Seasons List
//           Expanded(
//             child: _buildSeasonsList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEpisodesPanel() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: _currentMode == NavigationMode.episodes
//               ? Colors.green.withOpacity(0.5)
//               : Colors.white.withOpacity(0.1),
//           width: 2,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.green.withOpacity(0.2),
//                   Colors.transparent,
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(14),
//                 topRight: Radius.circular(14),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(
//                     Icons.play_circle_outline,
//                     color: Colors.green,
//                     size: 24,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "ACTIVE EPISODES",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1.0,
//                       ),
//                     ),
//                     if (_filteredSeasons.isNotEmpty &&
//                         _selectedSeasonIndex < _filteredSeasons.length)
//                       Text(
//                         _filteredSeasons[_selectedSeasonIndex].sessionName,
//                         style: TextStyle(
//                           color: Colors.grey[400],
//                           fontSize: 12,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                   ],
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     '${_currentEpisodes.length}',
//                     style: const TextStyle(
//                       color: Colors.green,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Episodes List
//           Expanded(
//             child: _isLoadingEpisodes
//                 ? _buildLoadingWidget()
//                 : _buildEpisodesList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSeasonsList() {
//     return ListView.builder(
//       controller: _seasonsScrollController,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       itemCount: _filteredSeasons.length,
//       itemBuilder: (context, index) => _buildSeasonItem(index),
//     );
//   }

//   void _onSeasonTap(int index) {
//     setState(() {
//       _selectedSeasonIndex = index;
//       _currentMode = NavigationMode.seasons;
//     });
//     _seasonsFocusNodes[index]?.requestFocus();
//     _selectSeason(index);
//   }

//   Widget _buildSeasonItem(int index) {
//     final season = _filteredSeasons[index];
//     final isSelected = index == _selectedSeasonIndex;
//     final isFocused = _currentMode == NavigationMode.seasons && isSelected;
//     final episodeCount = _filteredEpisodesMap[season.id]?.length ?? 0;

//     return GestureDetector(
//       onTap: () => _onSeasonTap(index),
//       child: Focus(
//         focusNode: _seasonsFocusNodes[index],
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           margin: const EdgeInsets.symmetric(vertical: 6),
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             gradient: isFocused
//                 ? LinearGradient(
//                     colors: [
//                       Colors.blue.withOpacity(0.3),
//                       Colors.blue.withOpacity(0.1),
//                     ],
//                     begin: Alignment.centerLeft,
//                     end: Alignment.centerRight,
//                   )
//                 : isSelected
//                     ? LinearGradient(
//                         colors: [
//                           Colors.white.withOpacity(0.1),
//                           Colors.white.withOpacity(0.05),
//                         ],
//                         begin: Alignment.centerLeft,
//                         end: Alignment.centerRight,
//                       )
//                     : null,
//             color: !isFocused && !isSelected
//                 ? Colors.grey[900]?.withOpacity(0.4)
//                 : null,
//             borderRadius: BorderRadius.circular(12),
//             border: isFocused
//                 ? Border.all(color: Colors.blue, width: 2)
//                 : isSelected
//                     ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
//                     : null,
//             boxShadow: isFocused
//                 ? [
//                     BoxShadow(
//                       color: Colors.blue.withOpacity(0.3),
//                       blurRadius: 12,
//                       spreadRadius: 2,
//                     )
//                   ]
//                 : null,
//           ),
//           child: Row(
//             children: [
//               // Enhanced Season Image with multiple fallbacks
//               Stack(
//                 children: [
//                   // Background with season number
//                   Container(
//                     width: 50,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: isFocused
//                             ? [Colors.blue, Colors.blue.shade300]
//                             : [Colors.grey[700]!, Colors.grey[600]!],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(25),
//                       boxShadow: [
//                         BoxShadow(
//                           color: (isFocused ? Colors.blue : Colors.grey[700]!)
//                               .withOpacity(0.4),
//                           blurRadius: 6,
//                           spreadRadius: 1,
//                         )
//                       ],
//                     ),
//                     child: Center(
//                       child: Text(
//                         '${season.seasonOrder}',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                         ),
//                       ),
//                     ),
//                   ),

//                   // Season image overlay (if available)
//                   if (_isValidImageUrl(season.banner))
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(25),
//                       child: _buildEnhancedImage(
//                         imageUrl: season.banner,
//                         width: 50,
//                         height: 50,
//                         fit: BoxFit.cover,
//                         fallbackWidget:
//                             Container(), // Transparent fallback to show background
//                       ),
//                     ),
//                 ],
//               ),

//               const SizedBox(width: 16),

//               // Season Info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       season.sessionName,
//                       style: TextStyle(
//                         color: isFocused ? Colors.blue : Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 6),
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: isFocused
//                                 ? Colors.blue.withOpacity(0.2)
//                                 : Colors.grey[700]?.withOpacity(0.5),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             'Season ${season.seasonOrder}',
//                             style: TextStyle(
//                               color: isFocused ? Colors.blue : Colors.grey[300],
//                               fontSize: 11,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                         if (episodeCount > 0) ...[
//                           const SizedBox(width: 8),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: Colors.green.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               '$episodeCount episodes',
//                               style: const TextStyle(
//                                 color: Colors.green,
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               AnimatedRotation(
//                 turns: isFocused ? 0.0 : -0.25,
//                 duration: const Duration(milliseconds: 300),
//                 child: Icon(
//                   Icons.chevron_right,
//                   color: isFocused ? Colors.blue : Colors.grey[600],
//                   size: 24,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEpisodesList() {
//     final episodes = _currentEpisodes;

//     if (episodes.isEmpty) {
//       return _buildEmptyEpisodesState();
//     }

//     return ListView.builder(
//       controller: _scrollController,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       itemCount: episodes.length,
//       itemBuilder: (context, index) => _buildEpisodeItem(index),
//     );
//   }

//   void _onEpisodeTap(int index) {
//     if (_currentEpisodes.isNotEmpty && index < _currentEpisodes.length) {
//       setState(() {
//         _selectedEpisodeIndex = index;
//         _currentMode = NavigationMode.episodes;
//       });
//       _episodeFocusNodes[_currentEpisodes[index].id]?.requestFocus();
//       _playEpisode(_currentEpisodes[index]);
//     }
//   }

//   Widget _buildEpisodeItem(int index) {
//     final episode = _currentEpisodes[index];
//     final isSelected = index == _selectedEpisodeIndex;
//     final isFocused = _currentMode == NavigationMode.episodes && isSelected;
//     final isProcessing = _isProcessing && isSelected;

//     return GestureDetector(
//       onTap: () => _onEpisodeTap(index),
//       child: Focus(
//         focusNode: _episodeFocusNodes[episode.id],
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           margin: const EdgeInsets.symmetric(vertical: 8),
//           decoration: BoxDecoration(
//             gradient: isFocused
//                 ? LinearGradient(
//                     colors: [
//                       Colors.green.withOpacity(0.3),
//                       Colors.green.withOpacity(0.1),
//                     ],
//                     begin: Alignment.centerLeft,
//                     end: Alignment.centerRight,
//                   )
//                 : isSelected
//                     ? LinearGradient(
//                         colors: [
//                           Colors.white.withOpacity(0.1),
//                           Colors.white.withOpacity(0.05),
//                         ],
//                         begin: Alignment.centerLeft,
//                         end: Alignment.centerRight,
//                       )
//                     : null,
//             color: !isFocused && !isSelected
//                 ? Colors.grey[900]?.withOpacity(0.4)
//                 : null,
//             borderRadius: BorderRadius.circular(16),
//             border: isFocused
//                 ? Border.all(color: Colors.green, width: 2)
//                 : isSelected
//                     ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
//                     : null,
//             boxShadow: isFocused
//                 ? [
//                     BoxShadow(
//                       color: Colors.green.withOpacity(0.3),
//                       blurRadius: 12,
//                       spreadRadius: 2,
//                     )
//                   ]
//                 : null,
//           ),
//           child: Row(
//             children: [
//               // Enhanced Thumbnail with multiple fallbacks
//               Container(
//                 margin: const EdgeInsets.all(12),
//                 width: 140,
//                 height: 90,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.4),
//                       blurRadius: 8,
//                       spreadRadius: 2,
//                     )
//                   ],
//                 ),
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     // Default background with episode info
//                     Container(
//                       width: 140,
//                       height: 90,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [Colors.grey[800]!, Colors.grey[700]!],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.video_library,
//                               color: Colors.grey[400],
//                               size: 28,
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               "EP ${index + 1}",
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     // Try to load images with fallback priority
//                     if (_isValidImageUrl(episode.banner))
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: CachedNetworkImage(
//                           imageUrl: episode.banner,
//                           width: 140,
//                           height: 90,
//                           fit: BoxFit.cover,
//                           placeholder: (context, url) => Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [Colors.grey[800]!, Colors.grey[700]!],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ),
//                             ),
//                             child: const Center(
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor:
//                                     AlwaysStoppedAnimation<Color>(Colors.blue),
//                               ),
//                             ),
//                           ),
//                           errorWidget: (context, url, error) {
//                             // Fallback to series banner
//                             if (_isValidImageUrl(widget.banner)) {
//                               return CachedNetworkImage(
//                                 imageUrl: widget.banner,
//                                 width: 140,
//                                 height: 90,
//                                 fit: BoxFit.cover,
//                                 errorWidget: (context, url, error) {
//                                   // Fallback to poster
//                                   if (_isValidImageUrl(widget.poster)) {
//                                     return CachedNetworkImage(
//                                       imageUrl: widget.poster,
//                                       width: 140,
//                                       height: 90,
//                                       fit: BoxFit.cover,
//                                       errorWidget: (context, url, error) =>
//                                           Container(),
//                                     );
//                                   }
//                                   return Container();
//                                 },
//                               );
//                             }
//                             return Container();
//                           },
//                           fadeInDuration: const Duration(milliseconds: 300),
//                           fadeOutDuration: const Duration(milliseconds: 100),
//                         ),
//                       )
//                     else if (_isValidImageUrl(widget.banner))
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: CachedNetworkImage(
//                           imageUrl: widget.banner,
//                           width: 140,
//                           height: 90,
//                           fit: BoxFit.cover,
//                           placeholder: (context, url) => Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [Colors.grey[800]!, Colors.grey[700]!],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ),
//                             ),
//                             child: const Center(
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor:
//                                     AlwaysStoppedAnimation<Color>(Colors.blue),
//                               ),
//                             ),
//                           ),
//                           errorWidget: (context, url, error) {
//                             // Fallback to poster
//                             if (_isValidImageUrl(widget.poster)) {
//                               return CachedNetworkImage(
//                                 imageUrl: widget.poster,
//                                 width: 140,
//                                 height: 90,
//                                 fit: BoxFit.cover,
//                                 errorWidget: (context, url, error) =>
//                                     Container(),
//                               );
//                             }
//                             return Container();
//                           },
//                           fadeInDuration: const Duration(milliseconds: 300),
//                           fadeOutDuration: const Duration(milliseconds: 100),
//                         ),
//                       )
//                     else if (_isValidImageUrl(widget.poster))
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: CachedNetworkImage(
//                           imageUrl: widget.poster,
//                           width: 140,
//                           height: 90,
//                           fit: BoxFit.cover,
//                           placeholder: (context, url) => Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [Colors.grey[800]!, Colors.grey[700]!],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ),
//                             ),
//                             child: const Center(
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor:
//                                     AlwaysStoppedAnimation<Color>(Colors.blue),
//                               ),
//                             ),
//                           ),
//                           errorWidget: (context, url, error) => Container(),
//                           fadeInDuration: const Duration(milliseconds: 300),
//                           fadeOutDuration: const Duration(milliseconds: 100),
//                         ),
//                       ),

//                     // Play/Loading overlay with beautiful animations
//                     if (isProcessing)
//                       Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.8),
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                         child: const SpinKitRing(
//                           color: Colors.green,
//                           size: 30,
//                           lineWidth: 3,
//                         ),
//                       )
//                     else if (isFocused)
//                       Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [Colors.green, Colors.green.shade400],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.circular(25),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.green.withOpacity(0.5),
//                               blurRadius: 10,
//                               spreadRadius: 2,
//                             )
//                           ],
//                         ),
//                         child: const Icon(
//                           Icons.play_arrow,
//                           color: Colors.white,
//                           size: 28,
//                         ),
//                       )
//                     else if (isSelected)
//                       Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Icon(
//                           Icons.play_arrow,
//                           color: Colors.white,
//                           size: 24,
//                         ),
//                       ),
//                   ],
//                 ),
//               ),

//               // Episode Information
//               Expanded(
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Episode Title
//                       Text(
//                         episode.name,
//                         style: TextStyle(
//                           color: isFocused ? Colors.green : Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),

//                       // const SizedBox(height: 8),

//                       // // Episode Description
//                       // if (episode.description.isNotEmpty)
//                       //   Text(
//                       //     episode.description,
//                       //     style: TextStyle(
//                       //       color: Colors.grey[400],
//                       //       fontSize: 13,
//                       //       height: 1.3,
//                       //     ),
//                       //     maxLines: 3,
//                       //     overflow: TextOverflow.ellipsis,
//                       //   ),

//                       const SizedBox(height: 12),

//                       // Episode Metadata
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 5),
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: isFocused
//                                     ? [
//                                         Colors.green.withOpacity(0.3),
//                                         Colors.green.withOpacity(0.1)
//                                       ]
//                                     : [
//                                         Colors.grey[700]!.withOpacity(0.5),
//                                         Colors.grey[800]!.withOpacity(0.3)
//                                       ],
//                               ),
//                               borderRadius: BorderRadius.circular(15),
//                               border: Border.all(
//                                 color: isFocused
//                                     ? Colors.green.withOpacity(0.5)
//                                     : Colors.grey[600]!.withOpacity(0.3),
//                               ),
//                             ),
//                             child: Text(
//                               'Episode ${index + 1}',
//                               style: TextStyle(
//                                 color:
//                                     isFocused ? Colors.green : Colors.grey[300],
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           if (isFocused)
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: Colors.green.withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: const Text(
//                                 'READY TO PLAY',
//                                 style: TextStyle(
//                                   color: Colors.green,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Action Button Area
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     AnimatedScale(
//                       scale: isFocused ? 1.2 : 1.0,
//                       duration: const Duration(milliseconds: 300),
//                       child: Container(
//                         width: 56,
//                         height: 56,
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: isFocused
//                                 ? [Colors.green, Colors.green.shade400]
//                                 : isSelected
//                                     ? [
//                                         Colors.white.withOpacity(0.3),
//                                         Colors.white.withOpacity(0.1)
//                                       ]
//                                     : [Colors.grey[700]!, Colors.grey[600]!],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.circular(28),
//                           boxShadow: isFocused
//                               ? [
//                                   BoxShadow(
//                                     color: Colors.green.withOpacity(0.5),
//                                     blurRadius: 12,
//                                     spreadRadius: 3,
//                                   )
//                                 ]
//                               : null,
//                         ),
//                         child: isProcessing
//                             ? const SpinKitRing(
//                                 color: Colors.white,
//                                 size: 24,
//                                 lineWidth: 2,
//                               )
//                             : const Icon(
//                                 Icons.play_arrow,
//                                 color: Colors.white,
//                                 size: 32,
//                               ),
//                       ),
//                     ),
//                     if (isFocused) ...[
//                       const SizedBox(height: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.green.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Text(
//                           'PRESS ENTER',
//                           style: TextStyle(
//                             color: Colors.green,
//                             fontSize: 9,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyEpisodesState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.grey[800]?.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(50),
//             ),
//             child: Icon(
//               Icons.video_library_outlined,
//               color: Colors.grey[500],
//               size: 64,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             "No Active Episodes Available",
//             style: TextStyle(
//               color: Colors.grey[400],
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "This season has no active episodes",
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 14,
//             ),
//           ),
//           if (_currentMode == NavigationMode.seasons) ...[
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: Colors.blue.withOpacity(0.3)),
//               ),
//               child: const Text(
//                 "Select another season or check back later",
//                 style: TextStyle(
//                   color: Colors.blue,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildInstructionsOverlay() {
//     return Positioned(
//       bottom: 0,
//       left: 0,
//       right: 0,
//       child: FadeTransition(
//         opacity: _instructionController,
//         child: Container(
//           margin: const EdgeInsets.all(20),
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Colors.black.withOpacity(0.95),
//                 Colors.black.withOpacity(0.85),
//               ],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//             borderRadius: BorderRadius.circular(16),
//             border:
//                 Border.all(color: highlightColor.withOpacity(0.3), width: 1),
//             boxShadow: [
//               BoxShadow(
//                 color: highlightColor.withOpacity(0.2),
//                 blurRadius: 20,
//                 spreadRadius: 5,
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.gamepad, color: highlightColor, size: 20),
//                   const SizedBox(width: 8),
//                   Text(
//                     'NAVIGATION GUIDE',
//                     style: TextStyle(
//                       color: highlightColor,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       letterSpacing: 1.0,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   if (_currentMode == NavigationMode.seasons) ...[
//                     _buildInstructionItem(
//                         '↑ ↓', 'Navigate Seasons', Icons.list_alt),
//                     _buildInstructionItem(
//                         '→ ENTER', 'Select Season', Icons.chevron_right),
//                     _buildInstructionItem('← BACK', 'Exit', Icons.exit_to_app),
//                   ] else ...[
//                     _buildInstructionItem(
//                         '↑ ↓', 'Navigate Episodes', Icons.video_library),
//                     _buildInstructionItem(
//                         'ENTER', 'Play Episode', Icons.play_arrow),
//                     _buildInstructionItem(
//                         '← BACK', 'Back to Seasons', Icons.arrow_back),
//                   ],
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInstructionItem(String keys, String action, IconData icon) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 highlightColor.withOpacity(0.3),
//                 highlightColor.withOpacity(0.1),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: highlightColor.withOpacity(0.5)),
//           ),
//           child: Text(
//             keys,
//             style: TextStyle(
//               color: highlightColor,
//               fontWeight: FontWeight.bold,
//               fontSize: 12,
//             ),
//           ),
//         ),
//         const SizedBox(height: 6),
//         Icon(icon, color: Colors.white70, size: 16),
//         const SizedBox(height: 4),
//         Text(
//           action,
//           style: const TextStyle(
//             color: Colors.white70,
//             fontSize: 11,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildLoadingWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SpinKitFadingCircle(
//             color: highlightColor,
//             size: 60.0,
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             'Loading...',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorWidget() {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.all(20),
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.8),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.red.withOpacity(0.5), width: 1),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.error_outline, color: Colors.red, size: 64),
//             const SizedBox(height: 16),
//             const Text(
//               'Something went wrong',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _errorMessage,
//               style: TextStyle(color: Colors.grey[300], fontSize: 14),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: () => _loadAuthKey(),
//               icon: const Icon(Icons.refresh),
//               label: const Text('Try Again'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: highlightColor,
//                 foregroundColor: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProcessingOverlay() {
//     return Container(
//       color: Colors.black54,
//       child: Center(
//         child: Container(
//           padding: const EdgeInsets.all(32),
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.9),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: highlightColor.withOpacity(0.3)),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SpinKitPulse(
//                 color: highlightColor,
//                 size: 80,
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 'Loading Video...',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Please wait',
//                 style: TextStyle(
//                   color: Colors.grey[400],
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class LoadingIndicator extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SpinKitFadingCircle(
//       color: highlightColor,
//       size: 50.0,
//     );
//   }
// }








import 'dart:async';
import 'dart:convert';
import 'package:mobi_tv_entertainment/video_widget/custom_video_player.dart';
import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobi_tv_entertainment/home_screen_pages/movies_screen/movies.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player.dart';
import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../video_widget/socket_service.dart';

// Define highlightColor constant
const Color highlightColor = Color(0xFF4FC3F7); // Light blue color for highlights

enum NavigationMode {
  shows,
  episodes,
}

// Religious Show Model
class ReligiousShowModel {
  final int id;
  final int channelId;
  final String title;
  final String genre;
  final String description;
  final String thumbnail;
  final int status;
  final int relOrder;

  ReligiousShowModel({
    required this.id,
    required this.channelId,
    required this.title,
    required this.genre,
    required this.description,
    required this.thumbnail,
    required this.status,
    required this.relOrder,
  });

  factory ReligiousShowModel.fromJson(Map<String, dynamic> json) {
    return ReligiousShowModel(
      id: json['id'] ?? 0,
      channelId: json['channel_id'] ?? 0,
      title: json['title'] ?? '',
      genre: json['genre'] ?? '',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      status: json['status'] ?? 1,
      relOrder: json['rel_order'] ?? 1,
    );
  }
}

// Religious Episode Model
class ReligiousEpisodeModel {
  final int id;
  final int showId;
  final int episodeOrder;
  final String title;
  final String episodeImage;
  final String episodeDescription;
  final String source;
  final String url;
  final int status;

  ReligiousEpisodeModel({
    required this.id,
    required this.showId,
    required this.episodeOrder,
    required this.title,
    required this.episodeImage,
    required this.episodeDescription,
    required this.source,
    required this.url,
    required this.status,
  });

  factory ReligiousEpisodeModel.fromJson(Map<String, dynamic> json) {
    return ReligiousEpisodeModel(
      id: json['id'] ?? 0,
      showId: json['show_id'] ?? 0,
      episodeOrder: json['episode_order'] ?? 1,
      title: json['title'] ?? '',
      episodeImage: json['episode_image'] ?? '',
      episodeDescription: json['episode_description'] ?? '',
      source: json['source'] ?? '',
      url: json['url'] ?? '',
      status: json['status'] ?? 1,
    );
  }
}

// Cache Manager Class for Religious Shows Data
class ReligiousShowsCacheManager {
  static const String _cacheKeyPrefix = 'religious_shows_cache_';
  static const String _episodesCacheKeyPrefix = 'religious_episodes_cache_';
  static const String _lastUpdatedKeyPrefix = 'last_updated_';
  static const Duration _cacheValidDuration = Duration(hours: 6);

  // Save shows data to cache
  static Future<void> saveShowsCache(
      int channelId, List<ReligiousShowModel> shows) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cacheKeyPrefix$channelId';
      final lastUpdatedKey = '$_lastUpdatedKeyPrefix$channelId';

      final showsJson = shows
          .map((show) => {
                'id': show.id,
                'channel_id': show.channelId,
                'title': show.title,
                'genre': show.genre,
                'description': show.description,
                'thumbnail': show.thumbnail,
                'status': show.status,
                'rel_order': show.relOrder,
              })
          .toList();

      await prefs.setString(cacheKey, jsonEncode(showsJson));
      await prefs.setInt(lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);

      print('✅ Religious shows cache saved for channel $channelId');
    } catch (e) {
      print('❌ Error saving religious shows cache: $e');
    }
  }

  // Get shows data from cache
  static Future<List<ReligiousShowModel>?> getShowsCache(int channelId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cacheKeyPrefix$channelId';
      final lastUpdatedKey = '$_lastUpdatedKeyPrefix$channelId';

      final cachedData = prefs.getString(cacheKey);
      final lastUpdated = prefs.getInt(lastUpdatedKey);

      if (cachedData == null || lastUpdated == null) {
        return null;
      }

      // Check if cache is still valid
      final cacheAge = DateTime.now().millisecondsSinceEpoch - lastUpdated;
      final isExpired = cacheAge > _cacheValidDuration.inMilliseconds;

      if (isExpired) {
        print('⏰ Religious shows cache expired for channel $channelId');
        return null;
      }

      final List<dynamic> showsJson = jsonDecode(cachedData);
      final shows =
          showsJson.map((json) => ReligiousShowModel.fromJson(json)).toList();

      print(
          '✅ Religious shows cache loaded for channel $channelId (${shows.length} shows)');
      return shows;
    } catch (e) {
      print('❌ Error loading religious shows cache: $e');
      return null;
    }
  }

  // Save episodes data to cache
  static Future<void> saveEpisodesCache(
      int showId, List<ReligiousEpisodeModel> episodes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_episodesCacheKeyPrefix$showId';
      final lastUpdatedKey = '${_lastUpdatedKeyPrefix}episodes_$showId';

      final episodesJson = episodes
          .map((episode) => {
                'id': episode.id,
                'show_id': episode.showId,
                'episode_order': episode.episodeOrder,
                'title': episode.title,
                'episode_image': episode.episodeImage,
                'episode_description': episode.episodeDescription,
                'source': episode.source,
                'url': episode.url,
                'status': episode.status,
              })
          .toList();

      await prefs.setString(cacheKey, jsonEncode(episodesJson));
      await prefs.setInt(lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);

      print('✅ Religious episodes cache saved for show $showId');
    } catch (e) {
      print('❌ Error saving religious episodes cache: $e');
    }
  }

  // Get episodes data from cache
  static Future<List<ReligiousEpisodeModel>?> getEpisodesCache(int showId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_episodesCacheKeyPrefix$showId';
      final lastUpdatedKey = '${_lastUpdatedKeyPrefix}episodes_$showId';

      final cachedData = prefs.getString(cacheKey);
      final lastUpdated = prefs.getInt(lastUpdatedKey);

      if (cachedData == null || lastUpdated == null) {
        return null;
      }

      // Check if cache is still valid
      final cacheAge = DateTime.now().millisecondsSinceEpoch - lastUpdated;
      final isExpired = cacheAge > _cacheValidDuration.inMilliseconds;

      if (isExpired) {
        print('⏰ Religious episodes cache expired for show $showId');
        return null;
      }

      final List<dynamic> episodesJson = jsonDecode(cachedData);
      final episodes =
          episodesJson.map((json) => ReligiousEpisodeModel.fromJson(json)).toList();

      print(
          '✅ Religious episodes cache loaded for show $showId (${episodes.length} episodes)');
      return episodes;
    } catch (e) {
      print('❌ Error loading religious episodes cache: $e');
      return null;
    }
  }

  // Compare two show lists and check if they're different
  static bool areShowsDifferent(
      List<ReligiousShowModel> cached, List<ReligiousShowModel> fresh) {
    if (cached.length != fresh.length) return true;

    for (int i = 0; i < cached.length; i++) {
      final c = cached[i];
      final f = fresh[i];

      if (c.id != f.id ||
          c.title != f.title ||
          c.status != f.status ||
          c.thumbnail != f.thumbnail) {
        return true;
      }
    }
    return false;
  }

  // Compare two episode lists and check if they're different
  static bool areEpisodesDifferent(
      List<ReligiousEpisodeModel> cached, List<ReligiousEpisodeModel> fresh) {
    if (cached.length != fresh.length) return true;

    for (int i = 0; i < cached.length; i++) {
      final c = cached[i];
      final f = fresh[i];

      if (c.id != f.id ||
          c.title != f.title ||
          c.status != f.status ||
          c.url != f.url) {
        return true;
      }
    }
    return false;
  }

  // Clear all cache for a specific channel
  static Future<void> clearChannelCache(int channelId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_cacheKeyPrefix$channelId');
      await prefs.remove('$_lastUpdatedKeyPrefix$channelId');
      print('🗑️ Cleared religious shows cache for channel $channelId');
    } catch (e) {
      print('❌ Error clearing religious shows cache: $e');
    }
  }
}

class ReligiousChannelDetailsPage extends StatefulWidget {
  final int id;
  final String banner;
  final String poster;
  final String name;

  const ReligiousChannelDetailsPage({
    Key? key,
    required this.id,
    required this.banner,
    required this.poster,
    required this.name,
  }) : super(key: key);

  @override
  _ReligiousChannelDetailsPageState createState() => _ReligiousChannelDetailsPageState();
}

class _ReligiousChannelDetailsPageState extends State<ReligiousChannelDetailsPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final SocketService _socketService = SocketService();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _showsScrollController = ScrollController();
  final FocusNode _mainFocusNode = FocusNode();

  // Data structures
  List<ReligiousShowModel> _shows = [];
  Map<int, List<ReligiousEpisodeModel>> _episodesMap = {};

  int _selectedShowIndex = 0;
  int _selectedEpisodeIndex = 0;

  NavigationMode _currentMode = NavigationMode.shows;

  final Map<int, FocusNode> _showsFocusNodes = {};
  final Map<String, FocusNode> _episodeFocusNodes = {};

  String _errorMessage = "";
  String _authKey = '';

  bool _showInstructions = true;
  Timer? _instructionTimer;

  // Filtered data variables for active content
  List<ReligiousShowModel> _filteredShows = [];
  Map<int, List<ReligiousEpisodeModel>> _filteredEpisodesMap = {};

  // Loading states
  bool _isLoading = false;
  bool _isProcessing = false;
  bool _isLoadingEpisodes = false;
  bool _isBackgroundRefreshing = false;

  // Animation Controllers
  late AnimationController _navigationModeController;
  late AnimationController _instructionController;
  late AnimationController _pageTransitionController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Filter methods for active content
  List<ReligiousShowModel> _filterActiveShows(List<ReligiousShowModel> shows) {
    return shows.where((show) => show.status == 1).toList();
  }

  List<ReligiousEpisodeModel> _filterActiveEpisodes(List<ReligiousEpisodeModel> episodes) {
    return episodes.where((episode) => episode.status == 1).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _socketService.initSocket();

    _initializeAnimations();
    _loadAuthKey();
    _startInstructionTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _showsScrollController.dispose();
    _mainFocusNode.dispose();
    _showsFocusNodes.values.forEach((node) => node.dispose());
    _episodeFocusNodes.values.forEach((node) => node.dispose());
    _socketService.dispose();
    _navigationModeController.dispose();
    _instructionController.dispose();
    _pageTransitionController.dispose();
    _instructionTimer?.cancel();
    super.dispose();
  }

  // Load auth key and initialize page
  Future<void> _loadAuthKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _authKey = prefs.getString('auth_key') ?? '';
        if (_authKey.isEmpty) {
          _authKey = globalAuthKey ?? '';
        }
      });

      if (_authKey.isEmpty) {
        setState(() {
          _errorMessage = "Authentication required. Please login again.";
          _isLoading = false;
        });
        return;
      }

      await _initializePageWithCache();
    } catch (e) {
      setState(() {
        _errorMessage = "Error loading authentication: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  // Enhanced initialization with smart caching
  Future<void> _initializePageWithCache() async {
    print('🚀 Initializing religious shows page with cache for channel ${widget.id}');

    // Try to load from cache first
    final cachedShows = await ReligiousShowsCacheManager.getShowsCache(widget.id);

    if (cachedShows != null && cachedShows.isNotEmpty) {
      // Show cached data immediately
      print('⚡ Loading religious shows from cache instantly');
      await _loadShowsFromCache(cachedShows);

      // Start background refresh
      _performBackgroundRefresh();
    } else {
      // No cache available, load from API with loading indicator
      print('📡 No religious shows cache available, loading from API');
      await _fetchShowsFromAPI(showLoading: true);
    }
  }

  // Load shows from cache and update UI instantly
  Future<void> _loadShowsFromCache(List<ReligiousShowModel> cachedShows) async {
    final activeShows = _filterActiveShows(cachedShows);

    setState(() {
      _shows = cachedShows;
      _filteredShows = activeShows;
      _isLoading = false;
      _errorMessage = "";
    });

    // Create focus nodes for active shows
    _showsFocusNodes.clear();
    for (int i = 0; i < _filteredShows.length; i++) {
      _showsFocusNodes[i] = FocusNode();
    }

    if (_filteredShows.isNotEmpty) {
      _setNavigationMode(NavigationMode.shows);
      _pageTransitionController.forward();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showsFocusNodes[0]?.requestFocus();
        }
      });
    }
  }

  // Rest of the methods with proper variable names...
  Widget _buildEpisodeItem(int index) {
    final episodes = _currentEpisodes;
    if (index >= episodes.length) return Container();
    
    final episode = episodes[index];
    final isSelected = index == _selectedEpisodeIndex;
    final isFocused = _currentMode == NavigationMode.episodes && isSelected;
    final isProcessing = _isProcessing && isSelected;

    return GestureDetector(
      onTap: () => _onEpisodeTap(index),
      child: Focus(
        focusNode: _episodeFocusNodes[episode.id.toString()],
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: isFocused
                ? LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0.3),
                      Colors.green.withOpacity(0.1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : isSelected
                    ? LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
            color: !isFocused && !isSelected
                ? Colors.grey[900]?.withOpacity(0.4)
                : null,
            borderRadius: BorderRadius.circular(16),
            border: isFocused
                ? Border.all(color: Colors.green, width: 2)
                : isSelected
                    ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                    : null,
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Enhanced Thumbnail
              Container(
                margin: const EdgeInsets.all(12),
                width: 140,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Default background with episode info
                    Container(
                      width: 140,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey[800]!, Colors.grey[700]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.video_library,
                              color: Colors.grey[400],
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "EP ${episode.episodeOrder}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Try to load episode image
                    if (_isValidImageUrl(episode.episodeImage))
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: episode.episodeImage,
                          width: 140,
                          height: 90,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.grey[800]!, Colors.grey[700]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            // Fallback to show thumbnail
                            if (_filteredShows.isNotEmpty && 
                                _selectedShowIndex < _filteredShows.length &&
                                _isValidImageUrl(_filteredShows[_selectedShowIndex].thumbnail)) {
                              return CachedNetworkImage(
                                imageUrl: _filteredShows[_selectedShowIndex].thumbnail,
                                width: 140,
                                height: 90,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  // Fallback to channel banner
                                  if (_isValidImageUrl(widget.banner)) {
                                    return CachedNetworkImage(
                                      imageUrl: widget.banner,
                                      width: 140,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) => Container(),
                                    );
                                  }
                                  return Container();
                                },
                              );
                            }
                            return Container();
                          },
                          fadeInDuration: const Duration(milliseconds: 300),
                          fadeOutDuration: const Duration(milliseconds: 100),
                        ),
                      ),

                    // Play/Loading overlay
                    if (isProcessing)
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const SpinKitRing(
                          color: Colors.green,
                          size: 30,
                          lineWidth: 3,
                        ),
                      )
                    else if (isFocused)
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green, Colors.green.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                  ],
                ),
              ),

              // Episode Information
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Episode Title
                      Text(
                        episode.title,
                        style: TextStyle(
                          color: isFocused ? Colors.green : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Episode Description (if available and not too long)
                      if (episode.episodeDescription.isNotEmpty && 
                          episode.episodeDescription.length < 200)
                        Text(
                          episode.episodeDescription,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const SizedBox(height: 12),

                      // Episode Metadata
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isFocused
                                    ? [
                                        Colors.green.withOpacity(0.3),
                                        Colors.green.withOpacity(0.1)
                                      ]
                                    : [
                                        Colors.grey[700]!.withOpacity(0.5),
                                        Colors.grey[800]!.withOpacity(0.3)
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isFocused
                                    ? Colors.green.withOpacity(0.5)
                                    : Colors.grey[600]!.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              'Episode ${episode.episodeOrder}',
                              style: TextStyle(
                                color: isFocused ? Colors.green : Colors.grey[300],
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: episode.source == 'youtube' 
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.purple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  episode.source == 'youtube' 
                                      ? Icons.play_circle_filled
                                      : Icons.video_library,
                                  color: episode.source == 'youtube' 
                                      ? Colors.red 
                                      : Colors.purple,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  episode.source.toUpperCase(),
                                  style: TextStyle(
                                    color: episode.source == 'youtube' 
                                        ? Colors.red 
                                        : Colors.purple,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Action Button Area
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isFocused
                          ? [Colors.green, Colors.green.shade400]
                          : [Colors.grey[700]!, Colors.grey[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: isFocused
                        ? [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 3,
                            )
                          ]
                        : null,
                  ),
                  child: isProcessing
                      ? const SpinKitRing(
                          color: Colors.white,
                          size: 24,
                          lineWidth: 2,
                        )
                      : const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods that were missing
  List<ReligiousEpisodeModel> get _currentEpisodes {
    if (_filteredShows.isEmpty || _selectedShowIndex >= _filteredShows.length) {
      return [];
    }
    return _filteredEpisodesMap[_filteredShows[_selectedShowIndex].id] ?? [];
  }

  void _onEpisodeTap(int index) {
    if (_currentEpisodes.isNotEmpty && index < _currentEpisodes.length) {
      setState(() {
        _selectedEpisodeIndex = index;
        _currentMode = NavigationMode.episodes;
      });
      _episodeFocusNodes[_currentEpisodes[index].id.toString()]?.requestFocus();
      _playEpisode(_currentEpisodes[index]);
    }
  }

  Future<void> _playEpisode(ReligiousEpisodeModel episode) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      if (mounted) {
        if (isYoutubeUrl(episode.url)) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomYoutubePlayer(
                videoUrl: episode.url,
                name: episode.title,
              ),
            ),
          );
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomVideoPlayer(
                videoUrl: episode.url,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error playing video'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  bool isYoutubeUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    url = url.toLowerCase().trim();
    return RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url) ||
        url.contains('youtube.com') ||
        url.contains('youtu.be') ||
        url.contains('youtube.com/shorts/');
  }

  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      if (!uri.hasAbsolutePath) return false;
      if (uri.scheme != 'http' && uri.scheme != 'https') return false;

      final path = uri.path.toLowerCase();
      return path.contains('.jpg') ||
          path.contains('.jpeg') ||
          path.contains('.png') ||
          path.contains('.webp') ||
          path.contains('.gif') ||
          path.contains('image') ||
          path.contains('thumb') ||
          path.contains('banner');
    } catch (e) {
      return false;
    }
  }

  // Perform background refresh without showing loading indicators
  Future<void> _performBackgroundRefresh() async {
    print('🔄 Starting religious shows background refresh');
    setState(() {
      _isBackgroundRefreshing = true;
    });

    try {
      final freshShows = await _fetchShowsFromAPIDirectly();

      if (freshShows != null) {
        // Compare with cached data
        final cachedShows = _shows;
        final hasChanges = ReligiousShowsCacheManager.areShowsDifferent(
            cachedShows, freshShows);

        if (hasChanges) {
          print('🔄 Religious shows changes detected, updating UI silently');

          // Save new data to cache
          await ReligiousShowsCacheManager.saveShowsCache(widget.id, freshShows);

          // Update UI without disrupting user experience
          await _updateShowsData(freshShows);
        } else {
          print('✅ No religious shows changes detected in background refresh');
        }
      }
    } catch (e) {
      print('❌ Religious shows background refresh failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isBackgroundRefreshing = false;
        });
      }
    }
  }

  // Update shows data while preserving user's current selection
  Future<void> _updateShowsData(List<ReligiousShowModel> newShows) async {
    final activeShows = _filterActiveShows(newShows);
    final currentSelectedShowId = _filteredShows.isNotEmpty &&
            _selectedShowIndex < _filteredShows.length
        ? _filteredShows[_selectedShowIndex].id
        : null;

    setState(() {
      _shows = newShows;
      _filteredShows = activeShows;
    });

    // Try to maintain user's current selection
    if (currentSelectedShowId != null) {
      final newIndex =
          _filteredShows.indexWhere((s) => s.id == currentSelectedShowId);
      if (newIndex >= 0) {
        setState(() {
          _selectedShowIndex = newIndex;
        });
      }
    }

    // Recreate focus nodes if needed
    _showsFocusNodes.clear();
    for (int i = 0; i < _filteredShows.length; i++) {
      _showsFocusNodes[i] = FocusNode();
    }
  }

  // Fetch shows from API with loading indicator
  Future<void> _fetchShowsFromAPI({bool showLoading = false}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = "Loading shows...";
      });
    }

    try {
      final shows = await _fetchShowsFromAPIDirectly();

      if (shows != null) {
        // Save to cache
        await ReligiousShowsCacheManager.saveShowsCache(widget.id, shows);

        // Update UI
        await _loadShowsFromCache(shows);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error: ${e.toString()}";
      });
    }
  }

  // Direct API call for shows
  Future<List<ReligiousShowModel>?> _fetchShowsFromAPIDirectly() async {
    final prefs = await SharedPreferences.getInstance();
    final authKey = prefs.getString('auth_key') ?? _authKey;

    final response = await https.get(
      Uri.parse(
          'https://acomtv.coretechinfo.com/public/api/getReligiousShows/${widget.id}'),
      headers: {
        'auth-key': authKey,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      String responseBody = response.body.trim();
      if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
        final List<dynamic> data = jsonDecode(responseBody);
        return data.map((show) => ReligiousShowModel.fromJson(show)).toList();
      }
    }

    throw Exception('Failed to load religious shows (${response.statusCode})');
  }

  void _selectShow(int index) {
    if (index >= 0 && index < _filteredShows.length) {
      setState(() {
        _selectedShowIndex = index;
      });
      _fetchEpisodes(_filteredShows[index].id);
    }
  }

  // Enhanced episodes fetching with cache
  Future<void> _fetchEpisodes(int showId) async {
    // Check if already loaded
    if (_filteredEpisodesMap.containsKey(showId)) {
      setState(() {
        _selectedShowIndex =
            _filteredShows.indexWhere((show) => show.id == showId);
        _selectedEpisodeIndex = 0;
      });
      _setNavigationMode(NavigationMode.episodes);
      return;
    }

    // Try cache first
    final cachedEpisodes =
        await ReligiousShowsCacheManager.getEpisodesCache(showId);

    if (cachedEpisodes != null) {
      // Load from cache instantly
      await _loadEpisodesFromCache(showId, cachedEpisodes);
    } else {
      // Load from API with loading indicator
      await _fetchEpisodesFromAPI(showId, showLoading: true);
    }
  }

  // Load episodes from cache
  Future<void> _loadEpisodesFromCache(
      int showId, List<ReligiousEpisodeModel> cachedEpisodes) async {
    final activeEpisodes = _filterActiveEpisodes(cachedEpisodes);

    _episodeFocusNodes.clear();
    for (var episode in activeEpisodes) {
      _episodeFocusNodes[episode.id.toString()] = FocusNode();
    }

    setState(() {
      _episodesMap[showId] = cachedEpisodes;
      _filteredEpisodesMap[showId] = activeEpisodes;
      _selectedShowIndex =
          _filteredShows.indexWhere((s) => s.id == showId);
      _selectedEpisodeIndex = 0;
      _isLoadingEpisodes = false;
    });

    _setNavigationMode(NavigationMode.episodes);
  }

  // Fetch episodes from API with loading indicator
  Future<void> _fetchEpisodesFromAPI(int showId,
      {bool showLoading = false}) async {
    if (showLoading) {
      setState(() {
        _isLoadingEpisodes = true;
      });
    }

    try {
      final episodes = await _fetchEpisodesFromAPIDirectly(showId);

      if (episodes != null) {
        // Save to cache
        await ReligiousShowsCacheManager.saveEpisodesCache(showId, episodes);

        // Update UI
        await _loadEpisodesFromCache(showId, episodes);
      }
    } catch (e) {
      setState(() {
        _isLoadingEpisodes = false;
        _errorMessage = "Error loading episodes: ${e.toString()}";
      });
    }
  }

  // Direct API call for episodes
  Future<List<ReligiousEpisodeModel>?> _fetchEpisodesFromAPIDirectly(
      int showId) async {
    final prefs = await SharedPreferences.getInstance();
    final authKey = prefs.getString('auth_key') ?? _authKey;

    final response = await https.get(
      Uri.parse(
          'https://acomtv.coretechinfo.com/public/api/getReligiousShowsEpisodes/$showId'),
      headers: {
        'auth-key': authKey,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      String responseBody = response.body.trim();
      if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
        final List<dynamic> data = jsonDecode(responseBody);
        return data.map((e) => ReligiousEpisodeModel.fromJson(e)).toList();
      }
    }

    throw Exception('Failed to load episodes for show $showId');
  }

  void _setNavigationMode(NavigationMode mode) {
    setState(() {
      _currentMode = mode;
    });

    if (mode == NavigationMode.shows) {
      _navigationModeController.reverse();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_selectedShowIndex < _showsFocusNodes.length) {
          _showsFocusNodes[_selectedShowIndex]?.requestFocus();
        }
      });
    } else {
      _navigationModeController.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentEpisodes.isNotEmpty && _selectedEpisodeIndex < _currentEpisodes.length) {
          _episodeFocusNodes[_currentEpisodes[_selectedEpisodeIndex].id.toString()]
              ?.requestFocus();
        }
      });
    }
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (_isProcessing) return;

    if (event is RawKeyDownEvent) {
      switch (_currentMode) {
        case NavigationMode.shows:
          _handleShowsNavigation(event);
          break;
        case NavigationMode.episodes:
          _handleEpisodesNavigation(event);
          break;
      }
    }
  }

  void _handleShowsNavigation(RawKeyEvent event) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        if (_selectedShowIndex < _filteredShows.length - 1) {
          setState(() {
            _selectedShowIndex++;
          });
          _showsFocusNodes[_selectedShowIndex]?.requestFocus();
        }
        break;

      case LogicalKeyboardKey.arrowUp:
        if (_selectedShowIndex > 0) {
          setState(() {
            _selectedShowIndex--;
          });
          _showsFocusNodes[_selectedShowIndex]?.requestFocus();
        }
        break;

      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.select:
      case LogicalKeyboardKey.arrowRight:
        if (_filteredShows.isNotEmpty) {
          _selectShow(_selectedShowIndex);
        }
        break;
    }
  }

  void _handleEpisodesNavigation(RawKeyEvent event) {
    final episodes = _currentEpisodes;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        if (_selectedEpisodeIndex < episodes.length - 1) {
          setState(() {
            _selectedEpisodeIndex++;
          });
          _scrollAndFocusEpisode(_selectedEpisodeIndex);
        }
        break;

      case LogicalKeyboardKey.arrowUp:
        if (_selectedEpisodeIndex > 0) {
          setState(() {
            _selectedEpisodeIndex--;
          });
          _scrollAndFocusEpisode(_selectedEpisodeIndex);
        }
        break;

      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.select:
        if (episodes.isNotEmpty) {
          _playEpisode(episodes[_selectedEpisodeIndex]);
        }
        break;

      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.escape:
        _setNavigationMode(NavigationMode.shows);
        break;
    }
  }

  Future<void> _scrollAndFocusEpisode(int index) async {
    if (index < 0 || index >= _currentEpisodes.length) return;

    final context = _episodeFocusNodes[_currentEpisodes[index].id.toString()]?.context;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
    }
  }

  void _initializeAnimations() {
    _navigationModeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _instructionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startInstructionTimer() {
    _instructionController.forward();
    _instructionTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        _instructionController.reverse();
        setState(() {
          _showInstructions = false;
        });
      }
    });
  }

  void _showInstructionsAgain() {
    setState(() {
      _showInstructions = true;
    });
    _instructionController.forward();
    _startInstructionTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: _mainFocusNode,
        autofocus: true,
        onKey: _handleKeyEvent,
        child: Stack(
          children: [
            // Beautiful Background
            _buildBackgroundLayer(),

            // Main Content with proper spacing
            _buildMainContentWithLayout(),

            // Top Navigation Bar (Fixed Position)
            _buildTopNavigationBar(),

            // Help Button (Fixed Position)
            _buildHelpButton(),

            // Instructions Overlay (Bottom)
            if (_showInstructions) _buildInstructionsOverlay(),

            // Processing Overlay
            if (_isProcessing) _buildProcessingOverlay(),

            // Background refresh indicator (subtle)
            if (_isBackgroundRefreshing) _buildBackgroundRefreshIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundLayer() {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: _isValidImageUrl(widget.banner)
              ? CachedNetworkImage(
                  imageUrl: widget.banner,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1a1a2e),
                          Color(0xFF16213e),
                          Color(0xFF0f0f23),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1a1a2e),
                          Color(0xFF16213e),
                          Color(0xFF0f0f23),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                )
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1a1a2e),
                        Color(0xFF16213e),
                        Color(0xFF0f0f23),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
        ),

        // Gradient Overlays for better readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Side gradients for better separation
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Add placeholder methods for missing UI components
  Widget _buildMainContentWithLayout() {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      bottom: 80,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildMainContent(),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading && _shows.isEmpty) {
      return _buildLoadingWidget();
    }

    if (_errorMessage.isNotEmpty && _shows.isEmpty) {
      return _buildErrorWidget();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel - Shows
          Expanded(
            flex: 2,
            child: _buildShowsPanel(),
          ),
          const SizedBox(width: 20),
          // Right Panel - Episodes
          Expanded(
            flex: 3,
            child: _buildEpisodesPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildShowsPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _currentMode == NavigationMode.shows
              ? Colors.blue.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.2),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.list_alt,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "ACTIVE SHOWS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_filteredShows.length}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Shows List
          Expanded(
            child: _buildShowsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodesPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _currentMode == NavigationMode.episodes
              ? Colors.green.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.2),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.play_circle_outline,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ACTIVE EPISODES",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    if (_filteredShows.isNotEmpty &&
                        _selectedShowIndex < _filteredShows.length)
                      Text(
                        _filteredShows[_selectedShowIndex].title,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentEpisodes.length}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Episodes List
          Expanded(
            child: _isLoadingEpisodes
                ? _buildLoadingWidget()
                : _buildEpisodesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildShowsList() {
    return ListView.builder(
      controller: _showsScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _filteredShows.length,
      itemBuilder: (context, index) => _buildShowItem(index),
    );
  }

  Widget _buildShowItem(int index) {
    final show = _filteredShows[index];
    final isSelected = index == _selectedShowIndex;
    final isFocused = _currentMode == NavigationMode.shows && isSelected;

    return GestureDetector(
      onTap: () => _onShowTap(index),
      child: Focus(
        focusNode: _showsFocusNodes[index],
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isFocused
                ? LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.3),
                      Colors.blue.withOpacity(0.1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: !isFocused
                ? Colors.grey[900]?.withOpacity(0.4)
                : null,
            borderRadius: BorderRadius.circular(12),
            border: isFocused
                ? Border.all(color: Colors.blue, width: 2)
                : null,
          ),
          child: Row(
            children: [
              // Show thumbnail
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.grey[700],
                ),
                child: _isValidImageUrl(show.thumbnail)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: CachedNetworkImage(
                          imageUrl: show.thumbnail,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Center(
                            child: Text(
                              '${show.relOrder}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          '${show.relOrder}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              // Show info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      show.title,
                      style: TextStyle(
                        color: isFocused ? Colors.blue : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      show.genre.isNotEmpty ? show.genre : 'Religious',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isFocused ? Colors.blue : Colors.grey[600],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onShowTap(int index) {
    setState(() {
      _selectedShowIndex = index;
      _currentMode = NavigationMode.shows;
    });
    _showsFocusNodes[index]?.requestFocus();
    _selectShow(index);
  }

  Widget _buildEpisodesList() {
    final episodes = _currentEpisodes;

    if (episodes.isEmpty) {
      return _buildEmptyEpisodesState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: episodes.length,
      itemBuilder: (context, index) => _buildEpisodeItem(index),
    );
  }

  Widget _buildEmptyEpisodesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            color: Colors.grey[500],
            size: 64,
          ),
          const SizedBox(height: 20),
          Text(
            "No Episodes Available",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Add remaining UI methods
  Widget _buildTopNavigationBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                // Current Mode Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: _currentMode == NavigationMode.shows
                          ? Colors.blue
                          : Colors.green,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _currentMode == NavigationMode.shows
                            ? Icons.list_alt
                            : Icons.play_circle_outline,
                        color: _currentMode == NavigationMode.shows
                            ? Colors.blue
                            : Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _currentMode == NavigationMode.shows
                            ? 'BROWSING SHOWS'
                            : 'BROWSING EPISODES',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Channel Title
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      widget.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpButton() {
    return Positioned(
      top: 50,
      right: 20,
      child: SafeArea(
        child: GestureDetector(
          onTap: _showInstructionsAgain,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.help_outline, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  'HELP',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _instructionController,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.95),
                Colors.black.withOpacity(0.85),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: highlightColor.withOpacity(0.3), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gamepad, color: highlightColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'NAVIGATION GUIDE',
                    style: TextStyle(
                      color: highlightColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (_currentMode == NavigationMode.shows) ...[
                    _buildInstructionItem('↑ ↓', 'Navigate Shows', Icons.list_alt),
                    _buildInstructionItem('→ ENTER', 'Select Show', Icons.chevron_right),
                    _buildInstructionItem('← BACK', 'Exit', Icons.exit_to_app),
                  ] else ...[
                    _buildInstructionItem('↑ ↓', 'Navigate Episodes', Icons.video_library),
                    _buildInstructionItem('ENTER', 'Play Episode', Icons.play_arrow),
                    _buildInstructionItem('← BACK', 'Back to Shows', Icons.arrow_back),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String keys, String action, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                highlightColor.withOpacity(0.3),
                highlightColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: highlightColor.withOpacity(0.5)),
          ),
          child: Text(
            keys,
            style: TextStyle(
              color: highlightColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(
          action,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(
            color: highlightColor,
            size: 60.0,
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading...',
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
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.5), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.grey[300], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _loadAuthKey(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: highlightColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: highlightColor.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinKitPulse(
                color: highlightColor,
                size: 80,
              ),
              const SizedBox(height: 24),
              const Text(
                'Loading Video...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundRefreshIndicator() {
    return Positioned(
      top: 100,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Updating...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(
      color: highlightColor,
      size: 50.0,
    );
  }
}
