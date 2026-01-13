// import 'dart:async';
// import 'dart:convert';
// import 'package:mobi_tv_entertainment/components/provider/device_info_provider.dart';
// import 'package:mobi_tv_entertainment/components/services/history_service.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/custom_video_player.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as https;
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/movies_screen/movies.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/custom_youtube_player.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/youtube_webview_player.dart';
// import 'package:mobi_tv_entertainment/components/widgets/models/news_item_model.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// // import '../../video_widget/socket_service.dart';

// enum NavigationMode {
//   seasons,
//   episodes,
// }

// // Cache Manager Class for TV Show Data
// class TvShowCacheManager {
//   static const String _cacheKeyPrefix = 'tv_show_cache_';
//   static const String _episodesCacheKeyPrefix = 'episodes_cache_';
//   static const String _lastUpdatedKeyPrefix = 'last_updated_';
//   static const Duration _cacheValidDuration =
//       Duration(hours: 6); // Cache validity period

//   // Save seasons data to cache
//   static Future<void> saveSeasonsCache(
//       int showId, List<ShowSeasonModel> seasons) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cacheKey = '$_cacheKeyPrefix$showId';
//       final lastUpdatedKey = '$_lastUpdatedKeyPrefix$showId';

//       final seasonsJson = seasons
//           .map((season) => {
//                 'id': season.id,
//                 'show_id': season.showId,
//                 'title': season.title,
//                 'poster': season.poster,
//                 'release_year': season.releaseYear,
//                 'status': season.status,
//                 'created_at': season.createdAt,
//                 'updated_at': season.updatedAt,
//               })
//           .toList();

//       await prefs.setString(cacheKey, jsonEncode(seasonsJson));
//       await prefs.setInt(lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);

//       print('✅ Seasons cache saved for show $showId');
//     } catch (e) {
//       print('❌ Error saving seasons cache: $e');
//     }
//   }

//   // Get seasons data from cache
//   static Future<List<ShowSeasonModel>?> getSeasonsCache(int showId) async {
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
//         print('⏰ Seasons cache expired for show $showId');
//         return null;
//       }

//       final List<dynamic> seasonsJson = jsonDecode(cachedData);
//       final seasons =
//           seasonsJson.map((json) => ShowSeasonModel.fromJson(json)).toList();

//       print(
//           '✅ Seasons cache loaded for show $showId (${seasons.length} seasons)');
//       return seasons;
//     } catch (e) {
//       print('❌ Error loading seasons cache: $e');
//       return null;
//     }
//   }

//   // Save episodes data to cache
//   static Future<void> saveEpisodesCache(
//       int seasonId, List<ShowEpisodeModel> episodes) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cacheKey = '$_episodesCacheKeyPrefix$seasonId';
//       final lastUpdatedKey = '${_lastUpdatedKeyPrefix}episodes_$seasonId';

//       final episodesJson = episodes
//           .map((episode) => {
//                 'id': episode.id,
//                 'season_id': episode.seasonId,
//                 'title': episode.title,
//                 'episode_number': episode.episodeNumber,
//                 'description': episode.description,
//                 'duration': episode.duration,
//                 'streaming_type': episode.streamingType,
//                 'video_url': episode.videoUrl,
//                 'thumbnail': episode.thumbnail,
//                 'release_date': episode.releaseDate,
//                 'status': episode.status,
//                 'created_at': episode.createdAt,
//                 'updated_at': episode.updatedAt,
//               })
//           .toList();

//       await prefs.setString(cacheKey, jsonEncode(episodesJson));
//       await prefs.setInt(lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);

//       print('✅ Episodes cache saved for season $seasonId');
//     } catch (e) {
//       print('❌ Error saving episodes cache: $e');
//     }
//   }

//   // Get episodes data from cache
//   static Future<List<ShowEpisodeModel>?> getEpisodesCache(int seasonId) async {
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
//         print('⏰ Episodes cache expired for season $seasonId');
//         return null;
//       }

//       final List<dynamic> episodesJson = jsonDecode(cachedData);
//       final episodes =
//           episodesJson.map((json) => ShowEpisodeModel.fromJson(json)).toList();

//       print(
//           '✅ Episodes cache loaded for season $seasonId (${episodes.length} episodes)');
//       return episodes;
//     } catch (e) {
//       print('❌ Error loading episodes cache: $e');
//       return null;
//     }
//   }

//   // Compare two lists and check if they're different
//   static bool areSeasonsDifferent(
//       List<ShowSeasonModel> cached, List<ShowSeasonModel> fresh) {
//     if (cached.length != fresh.length) return true;

//     for (int i = 0; i < cached.length; i++) {
//       final c = cached[i];
//       final f = fresh[i];

//       if (c.id != f.id ||
//           c.title != f.title ||
//           c.status != f.status ||
//           c.updatedAt != f.updatedAt) {
//         return true;
//       }
//     }
//     return false;
//   }

//   // Compare two episode lists and check if they're different
//   static bool areEpisodesDifferent(
//       List<ShowEpisodeModel> cached, List<ShowEpisodeModel> fresh) {
//     if (cached.length != fresh.length) return true;

//     for (int i = 0; i < cached.length; i++) {
//       final c = cached[i];
//       final f = fresh[i];

//       if (c.id != f.id ||
//           c.title != f.title ||
//           c.status != f.status ||
//           c.updatedAt != f.updatedAt) {
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
//       print('🗑️ Cleared cache for show $showId');
//     } catch (e) {
//       print('❌ Error clearing cache: $e');
//     }
//   }
// }

// // Updated Season Model for new API structure
// class ShowSeasonModel {
//   final int id;
//   final int showId;
//   final String title;
//   final String? poster;
//   final String releaseYear;
//   final int status;
//   final String createdAt;
//   final String updatedAt;

//   ShowSeasonModel({
//     required this.id,
//     required this.showId,
//     required this.title,
//     this.poster,
//     required this.releaseYear,
//     required this.status,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory ShowSeasonModel.fromJson(Map<String, dynamic> json) {
//     return ShowSeasonModel(
//       id: json['id'] ?? 0,
//       showId: json['show_id'] ?? 0,
//       title: json['title'] ?? '',
//       poster: json['poster'],
//       releaseYear: json['release_year'] ?? '',
//       status: json['status'] ?? 1,
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//     );
//   }
// }

// // New Episode Model for new API structure
// class ShowEpisodeModel {
//   final int id;
//   final int seasonId;
//   final String title;
//   final int episodeNumber;
//   final String description;
//   final String duration;
//   final String streamingType;
//   final String videoUrl;
//   final String thumbnail;
//   final String releaseDate;
//   final int status;
//   final String createdAt;
//   final String updatedAt;

//   ShowEpisodeModel({
//     required this.id,
//     required this.seasonId,
//     required this.title,
//     required this.episodeNumber,
//     required this.description,
//     required this.duration,
//     required this.streamingType,
//     required this.videoUrl,
//     required this.thumbnail,
//     required this.releaseDate,
//     required this.status,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory ShowEpisodeModel.fromJson(Map<String, dynamic> json) {
//     return ShowEpisodeModel(
//       id: json['id'] ?? 0,
//       seasonId: json['season_id'] ?? 0,
//       title: json['title'] ?? '',
//       episodeNumber: json['episode_number'] ?? 0,
//       description: json['description'] ?? '',
//       duration: json['duration'] ?? '',
//       streamingType: json['streaming_type'] ?? '',
//       videoUrl: json['video_url'] ?? '',
//       thumbnail: json['thumbnail'] ?? '',
//       releaseDate: json['release_date'] ?? '',
//       status: json['status'] ?? 0,
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//     );
//   }
// }

// class TvShowFinalDetailsPage extends StatefulWidget {
//   final int id;
//   final String banner;
//   final String poster;
//   final String name;

//   const TvShowFinalDetailsPage({
//     Key? key,
//     required this.id,
//     required this.banner,
//     required this.poster,
//     required this.name,
//   }) : super(key: key);

//   @override
//   _TvShowFinalDetailsPageState createState() => _TvShowFinalDetailsPageState();
// }

// class _TvShowFinalDetailsPageState extends State<TvShowFinalDetailsPage>
//     with WidgetsBindingObserver, TickerProviderStateMixin {
//   // final SocketService _socketService = SocketService();
//   final ScrollController _scrollController = ScrollController();
//   final ScrollController _seasonsScrollController = ScrollController();
//   final FocusNode _mainFocusNode = FocusNode();

//   // Updated data structures for new API
//   List<ShowSeasonModel> _seasons = [];
//   Map<int, List<ShowEpisodeModel>> _episodesMap = {};

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
//   List<ShowSeasonModel> _filteredSeasons = [];
//   Map<int, List<ShowEpisodeModel>> _filteredEpisodesMap = {};

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
//   List<ShowSeasonModel> _filterActiveSeasons(List<ShowSeasonModel> seasons) {
//     return seasons.where((season) => season.status == 1).toList();
//   }

//   List<ShowEpisodeModel> _filterActiveEpisodes(
//       List<ShowEpisodeModel> episodes) {
//     return episodes.where((episode) => episode.status == 1).toList();
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     // _socketService.initSocket();
//     SecureUrlService.refreshSettings();
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
//     // _socketService.dispose();
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
//         _authKey = prefs.getString('result_auth_key') ?? '';
//         if (_authKey.isEmpty) {
//           _authKey = SessionManager.authKey;
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
//     print('🚀 Initializing page with cache for show ${widget.id}');

//     // Try to load from cache first
//     final cachedSeasons = await TvShowCacheManager.getSeasonsCache(widget.id);

//     if (cachedSeasons != null && cachedSeasons.isNotEmpty) {
//       // Show cached data immediately
//       print('⚡ Loading from cache instantly');
//       await _loadSeasonsFromCache(cachedSeasons);

//       // Start background refresh
//       _performBackgroundRefresh();
//     } else {
//       // No cache available, load from API with loading indicator
//       print('📡 No cache available, loading from API');
//       await _fetchSeasonsFromAPI(showLoading: true);
//     }
//   }

//   // Load seasons from cache and update UI instantly
//   Future<void> _loadSeasonsFromCache(
//       List<ShowSeasonModel> cachedSeasons) async {
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
//       //
//       // ✅ CHANGE: Automatically fetch episodes for the first season
//       await _fetchEpisodes(_filteredSeasons[0].id);
//       //
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           _seasonsFocusNodes[0]?.requestFocus();
//         }
//       });
//     }
//   }

//   // Perform background refresh without showing loading indicators
//   Future<void> _performBackgroundRefresh() async {
//     print('🔄 Starting background refresh');
//     setState(() {
//       _isBackgroundRefreshing = true;
//     });

//     try {
//       final freshSeasons = await _fetchSeasonsFromAPIDirectly();

//       if (freshSeasons != null) {
//         // Compare with cached data
//         final cachedSeasons = _seasons;
//         final hasChanges =
//             TvShowCacheManager.areSeasonsDifferent(cachedSeasons, freshSeasons);

//         if (hasChanges) {
//           print('🔄 Changes detected, updating UI silently');

//           // Save new data to cache
//           await TvShowCacheManager.saveSeasonsCache(widget.id, freshSeasons);

//           // Update UI without disrupting user experience
//           await _updateSeasonsData(freshSeasons);
//         } else {
//           print('✅ No changes detected in background refresh');
//         }
//       }
//     } catch (e) {
//       print('❌ Background refresh failed: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isBackgroundRefreshing = false;
//         });
//       }
//     }
//   }

//   // Update seasons data while preserving user's current selection
//   Future<void> _updateSeasonsData(List<ShowSeasonModel> newSeasons) async {
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
//         await TvShowCacheManager.saveSeasonsCache(widget.id, seasons);

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
//   Future<List<ShowSeasonModel>?> _fetchSeasonsFromAPIDirectly() async {
//     String authKey = SessionManager.authKey;
//     var url = Uri.parse(SessionManager.baseUrl + 'getShowSeasons/${widget.id}');

//     final response = await https.get(
//       url,
//       // Uri.parse(
//       // 'https://dashboard.cpplayers.com/api/v2/getShowSeasons/${widget.id}'),
//       headers: {
//         'auth-key': authKey,
//         'Accept': 'application/json',
//         'Content-Type': 'application/json',
//         'domain': SessionManager.savedDomain,
//       },
//     ).timeout(const Duration(seconds: 15));

//     if (response.statusCode == 200) {
//       String responseBody = response.body.trim();
//       if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
//         final List<dynamic> data = jsonDecode(responseBody);
//         return data.map((season) => ShowSeasonModel.fromJson(season)).toList();
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
//     final cachedEpisodes = await TvShowCacheManager.getEpisodesCache(seasonId);

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
//       int seasonId, List<ShowEpisodeModel> cachedEpisodes) async {
//     final activeEpisodes = _filterActiveEpisodes(cachedEpisodes);

//     _episodeFocusNodes.clear();
//     for (var episode in activeEpisodes) {
//       _episodeFocusNodes[episode.id.toString()] = FocusNode();
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
//         final hasChanges = TvShowCacheManager.areEpisodesDifferent(
//             cachedEpisodes, freshEpisodes);

//         if (hasChanges) {
//           print('🔄 Episodes changes detected for season $seasonId');

//           // Save to cache
//           await TvShowCacheManager.saveEpisodesCache(seasonId, freshEpisodes);

//           // Update UI
//           await _loadEpisodesFromCache(seasonId, freshEpisodes);
//         }
//       }
//     } catch (e) {
//       print('❌ Episodes background refresh failed: $e');
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
//         await TvShowCacheManager.saveEpisodesCache(seasonId, episodes);

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
//   Future<List<ShowEpisodeModel>?> _fetchEpisodesFromAPIDirectly(
//       int seasonId) async {
//     String authKey = SessionManager.authKey;
//     var url =
//         Uri.parse(SessionManager.baseUrl + 'getShowSeasonsEpisodes/$seasonId');

//     final response = await https.get(
//       url,
//       // Uri.parse(
//       //     'https://dashboard.cpplayers.com/api/v2/getShowSeasonsEpisodes/$seasonId'),
//       headers: {
//         'auth-key': authKey,
//         'Accept': 'application/json',
//         'Content-Type': 'application/json',
//         'domain': SessionManager.savedDomain,
//       },
//     ).timeout(const Duration(seconds: 15));

//     if (response.statusCode == 200) {
//       String responseBody = response.body.trim();
//       if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
//         final List<dynamic> data = jsonDecode(responseBody);
//         return data.map((e) => ShowEpisodeModel.fromJson(e)).toList();
//       }
//     }

//     throw Exception('Failed to load episodes for season $seasonId');
//   }

//   // Method to refresh data when returning from video player
//   Future<void> _refreshDataOnReturn() async {
//     print('🔄 Refreshing data on return from video player');
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
//   Future<void> _playEpisode(ShowEpisodeModel episode) async {
//     if (_isProcessing) return;

//     setState(() => _isProcessing = true);

//     try {
//       print('Updating user history for: ${episode.title}');
//       int? currentUserId = SessionManager.userId;
//       final int? parsedId = episode.id;

//       await HistoryService.updateUserHistory(
//         userId: currentUserId!, // 1. User ID
//         contentType: 4, // 2. Content Type (channel के लिए 4)
//         eventId: parsedId!, // 3. Event ID (channel की ID)
//         eventTitle: episode.title, // 4. Event Title (channel का नाम)
//         url: episode.videoUrl ?? '', // 5. URL (channel का URL)
//         categoryId: 0, // 6. Category ID (डिफ़ॉल्ट 1)
//       );
//     } catch (e) {
//       print("History update failed, but proceeding to play. Error: $e");
//     }

//     try {
//       // String url = episode.videoUrl;
//       String rawUrl = episode.videoUrl;
//       print('rawurl: $rawUrl');
//       String playableUrl = await SecureUrlService.getSecureUrl(rawUrl);

//       if (mounted) {
//         dynamic result;

//         if (episode.streamingType.toLowerCase() == 'youtube') {
//           final deviceInfo = context.read<DeviceInfoProvider>();

//           if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
//             print('isAFTSS');

//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => YoutubeWebviewPlayer(
//                   videoUrl: playableUrl,
//                   name: episode.title,
//                 ),
//               ),
//             );
//           } else {
//             result = await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => CustomYoutubePlayer(
//                   // videoUrl: episode.videoUrl,
//                   // name: episode.title,
//                   videoData: VideoData(
//                     id: playableUrl,
//                     title: episode.title,
//                     youtubeUrl: playableUrl,
//                     thumbnail: episode.thumbnail ?? '',
//                     description: episode.description ?? '',
//                   ),
//                   playlist: [
//                     VideoData(
//                       id: playableUrl,
//                       title: episode.title,
//                       youtubeUrl: playableUrl,
//                       thumbnail: episode.thumbnail ?? '',
//                       description: episode.description ?? '',
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//         } else {
//           // result = await Navigator.push(
//           //   context,
//           //   MaterialPageRoute(
//           //     builder: (context) => CustomVideoPlayer(
//           //       videoUrl: episode.videoUrl,
//           //     ),
//           //   ),
//           // );

//           result = await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => VideoScreen(
//                 videoUrl: playableUrl,
//                 bannerImageUrl: episode.thumbnail,
//                 channelList: [],
//                 // isLive: false,
//                 // isSearch: false,
//                 videoId: episode.id,
//                 name: episode.title,
//                 liveStatus: false,
//                 updatedAt: episode.updatedAt,
//                 source: 'isTvShow',
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

//   // Rest of your existing methods remain the same...
//   // [Include all other methods from your original code here]

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

//             // ✅ CHANGE: REMOVED Top Navigation Bar
//             // _buildTopNavigationBar(),

//             // ✅ CHANGE: REMOVED Help Button
//             // _buildHelpButton(),

//             // ✅ CHANGE: REMOVED Instructions Overlay
//             // if (_showInstructions) _buildInstructionsOverlay(),

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
//           _episodeFocusNodes[
//                   _currentEpisodes[_selectedEpisodeIndex].id.toString()]
//               ?.requestFocus();
//         }
//       });
//     }
//   }

//   List<ShowEpisodeModel> get _currentEpisodes {
//     if (_filteredSeasons.isEmpty ||
//         _selectedSeasonIndex >= _filteredSeasons.length) {
//       return [];
//     }
//     return _filteredEpisodesMap[_filteredSeasons[_selectedSeasonIndex].id] ??
//         [];
//   }

//   // ✅ MODIFIED: Updated _selectSeason method
//   void _selectSeason(int index) {
//     if (index >= 0 && index < _filteredSeasons.length) {
//       setState(() {
//         _selectedSeasonIndex = index;
//       });
//       _fetchEpisodes(_filteredSeasons[index].id);
//     }
//   }

//   // ✅ MODIFIED: Updated _handleSeasonsNavigation method
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

//       // case LogicalKeyboardKey.escape:
//       // case LogicalKeyboardKey.goBack:
//       //   Navigator.of(context).pop(true);
//       //   break;
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

//       // case LogicalKeyboardKey.goBack:
//       //   Navigator.of(context).pop(true);
//       //   break;
//     }
//   }

//   void _onEpisodeTap(int index) {
//     if (_currentEpisodes.isNotEmpty && index < _currentEpisodes.length) {
//       setState(() {
//         _selectedEpisodeIndex = index;
//         _currentMode = NavigationMode.episodes;
//       });
//       _episodeFocusNodes[_currentEpisodes[index].id.toString()]?.requestFocus();
//       _playEpisode(_currentEpisodes[index]);
//     }
//   }

//   Future<void> _scrollAndFocusEpisode(int index) async {
//     if (index < 0 || index >= _currentEpisodes.length) return;

//     final context =
//         _episodeFocusNodes[_currentEpisodes[index].id.toString()]?.context;
//     if (context != null) {
//       await Scrollable.ensureVisible(
//         context,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         alignment: 0.3,
//       );
//     }
//   }

//   // // ✅ MODIFIED: Updated _handleEpisodesNavigation method
//   // void _handleEpisodesNavigation(RawKeyEvent event) {
//   //   final episodes = _currentEpisodes;

//   //   switch (event.logicalKey) {
//   //     case LogicalKeyboardKey.arrowDown:
//   //       if (_selectedEpisodeIndex < episodes.length - 1) {
//   //         setState(() {
//   //           _selectedEpisodeIndex++;
//   //         });
//   //         _scrollAndFocusEpisode(_selectedEpisodeIndex);
//   //       }
//   //       break;

//   //     case LogicalKeyboardKey.arrowUp:
//   //       if (_selectedEpisodeIndex > 0) {
//   //         setState(() {
//   //           _selectedEpisodeIndex--;
//   //         });
//   //         _scrollAndFocusEpisode(_selectedEpisodeIndex);
//   //       }
//   //       break;

//   //     case LogicalKeyboardKey.enter:
//   //     case LogicalKeyboardKey.select:
//   //       if (episodes.isNotEmpty) {
//   //         _playEpisode(episodes[_selectedEpisodeIndex]);
//   //       }
//   //       break;

//   //     case LogicalKeyboardKey.arrowLeft:
//   //     case LogicalKeyboardKey.escape:
//   //       _setNavigationMode(NavigationMode.seasons);
//   //       break;

//   //     case LogicalKeyboardKey.goBack:
//   //       Navigator.of(context).pop(true);
//   //       break;
//   //   }
//   // }

//   // // ✅ MODIFIED: Updated _currentEpisodes getter
//   // List<NewsItemModel> get _currentEpisodes {
//   //   if (_filteredSeasons.isEmpty ||
//   //       _selectedSeasonIndex >= _filteredSeasons.length) {
//   //     return [];
//   //   }
//   //   return _filteredEpisodesMap[_filteredSeasons[_selectedSeasonIndex].id] ??
//   //       [];
//   // }

//   // ✅ MODIFIED: Updated _buildSeasonsPanel method
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
//                 FittedBox(
//                   child: Text(
//                     widget.name.toUpperCase(),
//                     style: TextStyle(
//                       color: Colors.white,
//                       // fontSize: screenwdt * 0.02,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 1.0,
//                     ),
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

//   // ✅ MODIFIED: Updated _buildEpisodesPanel method
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
// //  FittedBox(
// //    child: const Text(
// //    "ACTIVE EPISODES",
// //                         style: TextStyle(
// //                           color: Color.fromRGBO(255, 255, 255, 1),
// //                           // fontSize: 18,
// //                           fontWeight: FontWeight.bold,
// //                           letterSpacing: 1.0,
// //                         ),
// //                       ),
// //  ),
//                     if (_filteredSeasons.isNotEmpty &&
//                         _selectedSeasonIndex < _filteredSeasons.length)
//                       FittedBox(
//                         child: Text(
//                           _filteredSeasons[_selectedSeasonIndex].title,
//                           style: TextStyle(
//                             color: Colors.grey[400],
//                             // fontSize: 12,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
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

//   // ✅ MODIFIED: Updated _buildSeasonsList method
//   Widget _buildSeasonsList() {
//     return ListView.builder(
//       controller: _seasonsScrollController,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       itemCount: _filteredSeasons.length,
//       itemBuilder: (context, index) => _buildSeasonItem(index),
//     );
//   }

//   // ✅ MODIFIED: Updated _onSeasonTap method
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
//               // Season Image/Icon
//               Stack(
//                 children: [
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
//                         'S${index + 1}',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ),

//                   // Season poster overlay (if available)
//                   if (season.poster != null && _isValidImageUrl(season.poster!))
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(25),
//                       child: _buildEnhancedImage(
//                         imageUrl: season.poster!,
//                         width: 50,
//                         height: 50,
//                         fit: BoxFit.cover,
//                         fallbackWidget: Container(),
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
//                       season.title,
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
//                             season.releaseYear,
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

//   // // ✅ MODIFIED: Updated _buildSeasonItem method
//   // Widget _buildSeasonItem(int index) {
//   //   final season = _filteredSeasons[index];
//   //   final isSelected = index == _selectedSeasonIndex;
//   //   final isFocused = _currentMode == NavigationMode.seasons && isSelected;
//   //   final episodeCount = _filteredEpisodesMap[season.id]?.length ?? 0;

//   //   return GestureDetector(
//   //     onTap: () => _onSeasonTap(index),
//   //     child: Focus(
//   //       focusNode: _seasonsFocusNodes[index],
//   //       child: AnimatedContainer(
//   //         duration: const Duration(milliseconds: 300),
//   //         margin: const EdgeInsets.symmetric(vertical: 6),
//   //         padding: const EdgeInsets.all(16),
//   //         decoration: BoxDecoration(
//   //           gradient: isFocused
//   //               ? LinearGradient(
//   //                   colors: [
//   //                     Colors.blue.withOpacity(0.3),
//   //                     Colors.blue.withOpacity(0.1),
//   //                   ],
//   //                   begin: Alignment.centerLeft,
//   //                   end: Alignment.centerRight,
//   //                 )
//   //               : isSelected
//   //                   ? LinearGradient(
//   //                       colors: [
//   //                         Colors.white.withOpacity(0.1),
//   //                         Colors.white.withOpacity(0.05),
//   //                       ],
//   //                       begin: Alignment.centerLeft,
//   //                       end: Alignment.centerRight,
//   //                     )
//   //                   : null,
//   //           color: !isFocused && !isSelected
//   //               ? Colors.grey[900]?.withOpacity(0.4)
//   //               : null,
//   //           borderRadius: BorderRadius.circular(12),
//   //           border: isFocused
//   //               ? Border.all(color: Colors.blue, width: 2)
//   //               : isSelected
//   //                   ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
//   //                   : null,
//   //           boxShadow: isFocused
//   //               ? [
//   //                   BoxShadow(
//   //                     color: Colors.blue.withOpacity(0.3),
//   //                     blurRadius: 12,
//   //                     spreadRadius: 2,
//   //                   )
//   //                 ]
//   //               : null,
//   //         ),
//   //         child: Row(
//   //           children: [
//   //             // Enhanced Season Image with multiple fallbacks
//   //             Stack(
//   //               children: [
//   //                 // Background with season number
//   //                 Container(
//   //                   width: 50,
//   //                   height: 50,
//   //                   decoration: BoxDecoration(
//   //                     gradient: LinearGradient(
//   //                       colors: isFocused
//   //                           ? [Colors.blue, Colors.blue.shade300]
//   //                           : [Colors.grey[700]!, Colors.grey[600]!],
//   //                       begin: Alignment.topLeft,
//   //                       end: Alignment.bottomRight,
//   //                     ),
//   //                     borderRadius: BorderRadius.circular(25),
//   //                     boxShadow: [
//   //                       BoxShadow(
//   //                         color: (isFocused ? Colors.blue : Colors.grey[700]!)
//   //                             .withOpacity(0.4),
//   //                         blurRadius: 6,
//   //                         spreadRadius: 1,
//   //                       )
//   //                     ],
//   //                   ),
//   //                   child: Center(
//   //                     child: Text(
//   //                       '${season.seasonOrder}',
//   //                       style: const TextStyle(
//   //                         color: Colors.white,
//   //                         fontWeight: FontWeight.bold,
//   //                         fontSize: 18,
//   //                       ),
//   //                     ),
//   //                   ),
//   //                 ),

//   //                 // Season image overlay (if available)
//   //                 if (_isValidImageUrl(season.banner))
//   //                   ClipRRect(
//   //                     borderRadius: BorderRadius.circular(25),
//   //                     child: _buildEnhancedImage(
//   //                       imageUrl: season.banner,
//   //                       width: 50,
//   //                       height: 50,
//   //                       fit: BoxFit.cover,
//   //                       fallbackWidget:
//   //                           Container(), // Transparent fallback to show background
//   //                     ),
//   //                   ),
//   //               ],
//   //             ),

//   //             const SizedBox(width: 16),

//   //             // Season Info
//   //             Expanded(
//   //               child: Column(
//   //                 crossAxisAlignment: CrossAxisAlignment.start,
//   //                 children: [
//   //                   Text(
//   //                     season.sessionName,
//   //                     style: TextStyle(
//   //                       color: isFocused ? Colors.blue : Colors.white,
//   //                       fontWeight: FontWeight.bold,
//   //                       fontSize: 16,
//   //                     ),
//   //                     maxLines: 2,
//   //                     overflow: TextOverflow.ellipsis,
//   //                   ),
//   //                   const SizedBox(height: 6),
//   //                   Row(
//   //                     children: [
//   //                       Container(
//   //                         padding: const EdgeInsets.symmetric(
//   //                             horizontal: 8, vertical: 4),
//   //                         decoration: BoxDecoration(
//   //                           color: isFocused
//   //                               ? Colors.blue.withOpacity(0.2)
//   //                               : Colors.grey[700]?.withOpacity(0.5),
//   //                           borderRadius: BorderRadius.circular(12),
//   //                         ),
//   //                         child: Text(
//   //                           'Season ${season.seasonOrder}',
//   //                           style: TextStyle(
//   //                             color: isFocused ? Colors.blue : Colors.grey[300],
//   //                             fontSize: 11,
//   //                             fontWeight: FontWeight.w600,
//   //                           ),
//   //                         ),
//   //                       ),
//   //                       if (episodeCount > 0) ...[
//   //                         const SizedBox(width: 8),
//   //                         Container(
//   //                           padding: const EdgeInsets.symmetric(
//   //                               horizontal: 8, vertical: 4),
//   //                           decoration: BoxDecoration(
//   //                             color: Colors.green.withOpacity(0.2),
//   //                             borderRadius: BorderRadius.circular(12),
//   //                           ),
//   //                           child: Text(
//   //                             '$episodeCount episodes',
//   //                             style: const TextStyle(
//   //                               color: Colors.green,
//   //                               fontSize: 11,
//   //                               fontWeight: FontWeight.w600,
//   //                             ),
//   //                           ),
//   //                         ),
//   //                       ],
//   //                     ],
//   //                   ),
//   //                 ],
//   //               ),
//   //             ),

//   //             AnimatedRotation(
//   //               turns: isFocused ? 0.0 : -0.25,
//   //               duration: const Duration(milliseconds: 300),
//   //               child: Icon(
//   //                 Icons.chevron_right,
//   //                 color: isFocused ? Colors.blue : Colors.grey[600],
//   //                 size: 24,
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }

//   // ✅ MODIFIED: Updated _buildEmptyEpisodesState method
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

//   // Back button को handle करने के लिए method
//   Future<bool> _onWillPop() async {
//     // अगर episodes mode में हैं तो seasons mode पर जाएं
//     if (_currentMode == NavigationMode.episodes) {
//       _setNavigationMode(NavigationMode.seasons);
//       return false; // App को close नहीं करें
//     }
//     // Navigator.of(context).pop(true);
//     // अगर seasons mode में हैं तो homepage पर जाएं
//     // _navigateToHome();
//     return false; // App को close नहीं करें
//   }

//   void _showInstructionsAgain() {
//     setState(() {
//       _showInstructions = true;
//     });
//     _instructionController.forward();
//     _startInstructionTimer();
//   }

//   // Future<void> _loadAuthKey() async {
//   //   await AuthManager.initialize();
//   //   setState(() {
//   //     _authKey = AuthManager.authKey;
//   //     if (_authKey.isEmpty) {
//   //       _authKey = globalAuthKey;
//   //     }
//   //   });

//   //   if (_authKey.isEmpty) {
//   //     setState(() {
//   //       _errorMessage = "Authentication required. Please login again.";
//   //       _isLoading = false;
//   //     });
//   //     return;
//   //   }

//   //   _initializePage();
//   // }

//   // void _setNavigationMode(NavigationMode mode) {
//   //   setState(() {
//   //     _currentMode = mode;
//   //   });

//   //   if (mode == NavigationMode.seasons) {
//   //     _navigationModeController.reverse();
//   //     WidgetsBinding.instance.addPostFrameCallback((_) {
//   //       _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
//   //     });
//   //   } else {
//   //     _navigationModeController.forward();
//   //     WidgetsBinding.instance.addPostFrameCallback((_) {
//   //       if (_currentEpisodes.isNotEmpty) {
//   //         _episodeFocusNodes[_currentEpisodes[_selectedEpisodeIndex].id]
//   //             ?.requestFocus();
//   //       }
//   //     });
//   //   }
//   // }

//   // Future<void> _playEpisode(NewsItemModel episode) async {
//   //   if (_isProcessing) return;

//   //   setState(() => _isProcessing = true);

//   //   try {
//   //     String url = episode.url;

//   //     // if (isYoutubeUrl(url)) {
//   //     //   try {
//   //     //     url = await _socketService.getUpdatedUrl(url);
//   //     //     // .timeout(const Duration(seconds: 10), onTimeout: () => url);
//   //     //   } catch (e) {
//   //     //     print("Error updating URL: $e");
//   //     //   }
//   //     // }

//   //     if (mounted) {
//   //       if (isYoutubeUrl(episode.url)) {
//   //         await Navigator.push(
//   //           context,
//   //           MaterialPageRoute(
//   //             // builder: (context) => VideoScreen(
//   //             //   videoUrl: url,
//   //             //   unUpdatedUrl: episode.url,
//   //             //   channelList: _currentEpisodes,
//   //             //   bannerImageUrl: widget.banner?? widget.poster,
//   //             //   startAtPosition: Duration.zero,
//   //             //   videoType: widget.source,
//   //             //   isLive: false,
//   //             //   isVOD: false,
//   //             //   isSearch: false,
//   //             //   isBannerSlider: false,
//   //             //   videoId: int.tryParse(episode.id),
//   //             //   source: 'webseries_details_page',
//   //             //   name: episode.name,
//   //             //   liveStatus: false,
//   //             //   seasonId: _seasons[_selectedSeasonIndex].id,
//   //             //   isLastPlayedStored: false,
//   //             // ),

//   //             builder: (context) => CustomYouTubePlayer(
//   //               videoUrl: episode.url,
//   //             ),
//   //           ),
//   //         );
//   //       } else {
//   //         await Navigator.push(
//   //           context,
//   //           MaterialPageRoute(
//   //             // builder: (context) => VideoScreen(
//   //             //   videoUrl: url,
//   //             //   unUpdatedUrl: episode.url,
//   //             //   channelList: _currentEpisodes,
//   //             //   bannerImageUrl: widget.banner?? widget.poster,
//   //             //   startAtPosition: Duration.zero,
//   //             //   videoType: widget.source,
//   //             //   isLive: false,
//   //             //   isVOD: false,
//   //             //   isSearch: false,
//   //             //   isBannerSlider: false,
//   //             //   videoId: int.tryParse(episode.id),
//   //             //   source: 'webseries_details_page',
//   //             //   name: episode.name,
//   //             //   liveStatus: false,
//   //             //   seasonId: _seasons[_selectedSeasonIndex].id,
//   //             //   isLastPlayedStored: false,
//   //             // ),

//   //             builder: (context) => CustomVideoPlayer(
//   //               videoUrl: episode.url,
//   //             ),
//   //           ),
//   //         );
//   //       }
//   //     }
//   //   } catch (e) {
//   //     if (mounted) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('Error playing video'),
//   //           backgroundColor: Colors.red,
//   //         ),
//   //       );
//   //     }
//   //   } finally {
//   //     if (mounted) {
//   //       setState(() => _isProcessing = false);
//   //     }
//   //   }
//   // }

//   // bool isYoutubeUrl(String? url) {
//   //   if (url == null || url.isEmpty) return false;
//   //   url = url.toLowerCase().trim();
//   //   return RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url) ||
//   //       url.contains('youtube.com') ||
//   //       url.contains('youtu.be') ||
//   //       url.contains('youtube.com/shorts/');
//   // }

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

//   // Future<void> _scrollAndFocusEpisode(int index) async {
//   //   if (index < 0 || index >= _currentEpisodes.length) return;

//   //   final context = _episodeFocusNodes[_currentEpisodes[index].id]?.context;
//   //   if (context != null) {
//   //     await Scrollable.ensureVisible(
//   //       context,
//   //       duration: const Duration(milliseconds: 300),
//   //       curve: Curves.easeInOut,
//   //       alignment: 0.3,
//   //     );
//   //   }
//   // }

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
//       // ✅ CHANGE: Adjusted top and bottom values
//       top: 20, // Below navigation bar
//       left: 0,
//       right: 0,
//       bottom: 20, // Above instructions
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

// // // OnTap handler for episode selection and playback
// //   void _onEpisodeTap(int index) {
// //     if (_currentEpisodes.isNotEmpty && index < _currentEpisodes.length) {
// //       setState(() {
// //         _selectedEpisodeIndex = index;
// //         _currentMode = NavigationMode.episodes;
// //       });
// //       _episodeFocusNodes[_currentEpisodes[index].id]?.requestFocus();
// //       _playEpisode(_currentEpisodes[index]);
// //     }
// //   }

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

//   // ================================
// // COMPLETE _buildEpisodeItem METHOD
// // Replace your existing _buildEpisodeItem method with this
// // ================================

//   Widget _buildEpisodeItem(int index) {
//     final episode = _currentEpisodes[index];
//     final isSelected = index == _selectedEpisodeIndex;
//     final isFocused = _currentMode == NavigationMode.episodes && isSelected;
//     final isProcessing = _isProcessing && isSelected;

//     return GestureDetector(
//       onTap: () => _onEpisodeTap(index),
//       child: Focus(
//         focusNode: _episodeFocusNodes[episode.id.toString()],
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
//               // ================================
//               // ENHANCED THUMBNAIL WITH MULTIPLE FALLBACKS
//               // ================================
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
//                     if (_isValidImageUrl(episode.thumbnail))
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: CachedNetworkImage(
//                           imageUrl: episode.thumbnail,
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

//               // ================================
//               // EPISODE INFORMATION
//               // ================================
//               Expanded(
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Episode Title
//                       Text(
//                         episode.title,
//                         style: TextStyle(
//                           color: isFocused ? Colors.green : Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),

//                       const SizedBox(height: 8),

//                       // ✅ CHANGE: REMOVED Episode Description
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

//                       // const SizedBox(height: 12),

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

//               // ================================
//               // ACTION BUTTON AREA
//               // ================================
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
import 'package:mobi_tv_entertainment/components/provider/device_info_provider.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';
import 'package:mobi_tv_entertainment/components/video_widget/custom_video_player.dart';
import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/movies_screen/movies.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/video_widget/custom_youtube_player.dart';
import 'package:mobi_tv_entertainment/components/video_widget/youtube_webview_player.dart';
import 'package:mobi_tv_entertainment/components/widgets/models/news_item_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NavigationMode {
  seasons,
  episodes,
}

// Updated Season Model
class ShowSeasonModel {
  final int id;
  final int showId;
  final String title;
  final String? poster;
  final String releaseYear;
  final int status;
  final String createdAt;
  final String updatedAt;

  ShowSeasonModel({
    required this.id,
    required this.showId,
    required this.title,
    this.poster,
    required this.releaseYear,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShowSeasonModel.fromJson(Map<String, dynamic> json) {
    return ShowSeasonModel(
      id: json['id'] ?? 0,
      showId: json['show_id'] ?? 0,
      title: json['title'] ?? '',
      poster: json['poster'],
      releaseYear: json['release_year'] ?? '',
      status: json['status'] ?? 1,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

// Updated Episode Model
class ShowEpisodeModel {
  final int id;
  final int seasonId;
  final String title;
  final int episodeNumber;
  final String description;
  final String duration;
  final String streamingType;
  final String videoUrl;
  final String thumbnail;
  final String releaseDate;
  final int status;
  final String createdAt;
  final String updatedAt;

  ShowEpisodeModel({
    required this.id,
    required this.seasonId,
    required this.title,
    required this.episodeNumber,
    required this.description,
    required this.duration,
    required this.streamingType,
    required this.videoUrl,
    required this.thumbnail,
    required this.releaseDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShowEpisodeModel.fromJson(Map<String, dynamic> json) {
    return ShowEpisodeModel(
      id: json['id'] ?? 0,
      seasonId: json['season_id'] ?? 0,
      title: json['title'] ?? '',
      episodeNumber: json['episode_number'] ?? 0,
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      streamingType: json['streaming_type'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      releaseDate: json['release_date'] ?? '',
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class TvShowFinalDetailsPage extends StatefulWidget {
  final int id;
  final String banner;
  final String poster;
  final String name;

  const TvShowFinalDetailsPage({
    Key? key,
    required this.id,
    required this.banner,
    required this.poster,
    required this.name,
  }) : super(key: key);

  @override
  _TvShowFinalDetailsPageState createState() => _TvShowFinalDetailsPageState();
}

class _TvShowFinalDetailsPageState extends State<TvShowFinalDetailsPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _seasonsScrollController = ScrollController();
  final FocusNode _mainFocusNode = FocusNode();

  // Data structures
  List<ShowSeasonModel> _seasons = [];
  Map<int, List<ShowEpisodeModel>> _episodesMap = {};

  int _selectedSeasonIndex = 0;
  int _selectedEpisodeIndex = 0;

  NavigationMode _currentMode = NavigationMode.seasons;

  final Map<int, FocusNode> _seasonsFocusNodes = {};
  final Map<String, FocusNode> _episodeFocusNodes = {};

  String _errorMessage = "";
  String _authKey = '';

  bool _showInstructions = true;
  Timer? _instructionTimer;

  // Filtered data variables for active content
  List<ShowSeasonModel> _filteredSeasons = [];
  Map<int, List<ShowEpisodeModel>> _filteredEpisodesMap = {};

  // Loading states
  bool _isLoading = false;
  bool _isProcessing = false;
  bool _isLoadingEpisodes = false;

  // Animation Controllers
  late AnimationController _navigationModeController;
  late AnimationController _instructionController;
  late AnimationController _pageTransitionController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Filter methods for active content
  List<ShowSeasonModel> _filterActiveSeasons(List<ShowSeasonModel> seasons) {
    return seasons.where((season) => season.status == 1).toList();
  }

  List<ShowEpisodeModel> _filterActiveEpisodes(
      List<ShowEpisodeModel> episodes) {
    return episodes.where((episode) => episode.status == 1).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SecureUrlService.refreshSettings();
    _initializeAnimations();
    _loadAuthKey();
    _startInstructionTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _seasonsScrollController.dispose();
    _mainFocusNode.dispose();
    _seasonsFocusNodes.values.forEach((node) => node.dispose());
    _episodeFocusNodes.values.forEach((node) => node.dispose());
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
        _authKey = prefs.getString('result_auth_key') ?? '';
        if (_authKey.isEmpty) {
          _authKey = SessionManager.authKey;
        }
      });

      if (_authKey.isEmpty) {
        setState(() {
          _errorMessage = "Authentication required. Please login again.";
          _isLoading = false;
        });
        return;
      }

      await _fetchSeasonsFromAPI();
    } catch (e) {
      setState(() {
        _errorMessage = "Error loading authentication: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  // Fetch seasons from API directly
  Future<void> _fetchSeasonsFromAPI() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final seasons = await _fetchSeasonsFromAPIDirectly();

      if (seasons != null) {
        final activeSeasons = _filterActiveSeasons(seasons);

        setState(() {
          _seasons = seasons;
          _filteredSeasons = activeSeasons;
          _isLoading = false;
        });

        // Create focus nodes for active seasons
        _seasonsFocusNodes.clear();
        for (int i = 0; i < _filteredSeasons.length; i++) {
          _seasonsFocusNodes[i] = FocusNode();
        }

        if (_filteredSeasons.isNotEmpty) {
          _setNavigationMode(NavigationMode.seasons);
          _pageTransitionController.forward();
          // Automatically fetch episodes for the first season
          await _fetchEpisodes(_filteredSeasons[0].id);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _seasonsFocusNodes[0]?.requestFocus();
            }
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error: ${e.toString()}";
      });
    }
  }

  // Direct API call for seasons
  Future<List<ShowSeasonModel>?> _fetchSeasonsFromAPIDirectly() async {
    String authKey = SessionManager.authKey;
    var url =
        Uri.parse(SessionManager.baseUrl + 'getShowSeasons/${widget.id}');

    final response = await https.get(
      url,
      headers: {
        'auth-key': authKey,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'domain': SessionManager.savedDomain,
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      String responseBody = response.body.trim();
      if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
        final List<dynamic> data = jsonDecode(responseBody);
        return data.map((season) => ShowSeasonModel.fromJson(season)).toList();
      }
    }

    throw Exception('Failed to load seasons (${response.statusCode})');
  }

  // Fetch episodes directly from API
  Future<void> _fetchEpisodes(int seasonId) async {
    // Check if already loaded in memory map
    if (_filteredEpisodesMap.containsKey(seasonId)) {
      setState(() {
        _selectedSeasonIndex =
            _filteredSeasons.indexWhere((season) => season.id == seasonId);
        _selectedEpisodeIndex = 0;
      });
      _setNavigationMode(NavigationMode.episodes);
      return;
    }

    // Load from API
    await _fetchEpisodesFromAPI(seasonId, showLoading: true);
  }

  // Fetch episodes from API with loading indicator
  Future<void> _fetchEpisodesFromAPI(int seasonId,
      {bool showLoading = false}) async {
    if (showLoading) {
      setState(() {
        _isLoadingEpisodes = true;
      });
    }

    try {
      final episodes = await _fetchEpisodesFromAPIDirectly(seasonId);

      if (episodes != null) {
        final activeEpisodes = _filterActiveEpisodes(episodes);

        _episodeFocusNodes.clear();
        for (var episode in activeEpisodes) {
          _episodeFocusNodes[episode.id.toString()] = FocusNode();
        }

        setState(() {
          _episodesMap[seasonId] = episodes;
          _filteredEpisodesMap[seasonId] = activeEpisodes;
          _selectedSeasonIndex =
              _filteredSeasons.indexWhere((s) => s.id == seasonId);
          _selectedEpisodeIndex = 0;
          _isLoadingEpisodes = false;
        });

        _setNavigationMode(NavigationMode.episodes);
      }
    } catch (e) {
      setState(() {
        _isLoadingEpisodes = false;
        _errorMessage = "Error loading episodes: ${e.toString()}";
      });
    }
  }

  // Direct API call for episodes
  Future<List<ShowEpisodeModel>?> _fetchEpisodesFromAPIDirectly(
      int seasonId) async {
    String authKey = SessionManager.authKey;
    var url = Uri.parse(
        SessionManager.baseUrl + 'getShowSeasonsEpisodes/$seasonId');

    final response = await https.get(
      url,
      headers: {
        'auth-key': authKey,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'domain': SessionManager.savedDomain,
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      String responseBody = response.body.trim();
      if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
        final List<dynamic> data = jsonDecode(responseBody);
        return data.map((e) => ShowEpisodeModel.fromJson(e)).toList();
      }
    }

    throw Exception('Failed to load episodes for season $seasonId');
  }

  // Method to refresh data when returning from video player
  Future<void> _refreshDataOnReturn() async {
    // Refresh current season's episodes to get latest data (e.g. progress if supported)
    if (_filteredSeasons.isNotEmpty &&
        _selectedSeasonIndex < _filteredSeasons.length) {
      final currentSeasonId = _filteredSeasons[_selectedSeasonIndex].id;
      // Clear memory cache for this season to force reload
      _filteredEpisodesMap.remove(currentSeasonId);
      await _fetchEpisodes(currentSeasonId);
    }
  }

  // Updated play episode method with refresh on return
  Future<void> _playEpisode(ShowEpisodeModel episode) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      print('Updating user history for: ${episode.title}');
      int? currentUserId = SessionManager.userId;
      final int? parsedId = episode.id;

      await HistoryService.updateUserHistory(
        userId: currentUserId!, // 1. User ID
        contentType: 4, // 2. Content Type (channel के लिए 4)
        eventId: parsedId!, // 3. Event ID (channel की ID)
        eventTitle: episode.title, // 4. Event Title (channel का नाम)
        url: episode.videoUrl ?? '', // 5. URL (channel का URL)
        categoryId: 0, // 6. Category ID (डिफ़ॉल्ट 1)
      );
    } catch (e) {
      print("History update failed, but proceeding to play. Error: $e");
    }

    try {
      String rawUrl = episode.videoUrl;
      print('rawurl: $rawUrl');
      String playableUrl = await SecureUrlService.getSecureUrl(rawUrl);

      if (mounted) {
        dynamic result;

        if (episode.streamingType.toLowerCase() == 'youtube') {
          final deviceInfo = context.read<DeviceInfoProvider>();

          if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
            print('isAFTSS');

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => YoutubeWebviewPlayer(
                  videoUrl: playableUrl,
                  name: episode.title,
                ),
              ),
            );
          } else {
            result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomYoutubePlayer(
                  videoData: VideoData(
                    id: playableUrl,
                    title: episode.title,
                    youtubeUrl: playableUrl,
                    thumbnail: episode.thumbnail ?? '',
                    description: episode.description ?? '',
                  ),
                  playlist: [
                    VideoData(
                      id: playableUrl,
                      title: episode.title,
                      youtubeUrl: playableUrl,
                      thumbnail: episode.thumbnail ?? '',
                      description: episode.description ?? '',
                    ),
                  ],
                ),
              ),
            );
          }
        } else {
          result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoScreen(
                videoUrl: playableUrl,
                bannerImageUrl: episode.thumbnail,
                channelList: [],
                videoId: episode.id,
                name: episode.title,
                liveStatus: false,
                updatedAt: episode.updatedAt,
                source: 'isTvShow',
              ),
            ),
          );
        }

        // Refresh data after returning from video player
        await _refreshDataOnReturn();
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

            _buildTopNavigationBar(),

            _buildHelpButton(),

            if (_showInstructions) _buildInstructionsOverlay(),

            // Processing Overlay
            if (_isProcessing) _buildProcessingOverlay(),
          ],
        ),
      ),
    );
  }

  void _setNavigationMode(NavigationMode mode) {
    setState(() {
      _currentMode = mode;
    });

    if (mode == NavigationMode.seasons) {
      _navigationModeController.reverse();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
      });
    } else {
      _navigationModeController.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentEpisodes.isNotEmpty) {
          _episodeFocusNodes[
                  _currentEpisodes[_selectedEpisodeIndex].id.toString()]
              ?.requestFocus();
        }
      });
    }
  }

  List<ShowEpisodeModel> get _currentEpisodes {
    if (_filteredSeasons.isEmpty ||
        _selectedSeasonIndex >= _filteredSeasons.length) {
      return [];
    }
    return _filteredEpisodesMap[_filteredSeasons[_selectedSeasonIndex].id] ??
        [];
  }

  void _selectSeason(int index) {
    if (index >= 0 && index < _filteredSeasons.length) {
      setState(() {
        _selectedSeasonIndex = index;
      });
      _fetchEpisodes(_filteredSeasons[index].id);
    }
  }

  void _handleSeasonsNavigation(RawKeyEvent event) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        if (_selectedSeasonIndex < _filteredSeasons.length - 1) {
          setState(() {
            _selectedSeasonIndex++;
          });
          _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
        }
        break;

      case LogicalKeyboardKey.arrowUp:
        if (_selectedSeasonIndex > 0) {
          setState(() {
            _selectedSeasonIndex--;
          });
          _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
        }
        break;

      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.select:
      case LogicalKeyboardKey.arrowRight:
        if (_filteredSeasons.isNotEmpty) {
          _selectSeason(_selectedSeasonIndex);
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
        _setNavigationMode(NavigationMode.seasons);
        break;
    }
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

  Future<void> _scrollAndFocusEpisode(int index) async {
    if (index < 0 || index >= _currentEpisodes.length) return;

    final context =
        _episodeFocusNodes[_currentEpisodes[index].id.toString()]?.context;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
    }
  }

  Widget _buildSeasonsPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _currentMode == NavigationMode.seasons
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
                FittedBox(
                  child: Text(
                    widget.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_filteredSeasons.length}',
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

          // Seasons List
          Expanded(
            child: _buildSeasonsList(),
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
                    if (_filteredSeasons.isNotEmpty &&
                        _selectedSeasonIndex < _filteredSeasons.length)
                      FittedBox(
                        child: Text(
                          _filteredSeasons[_selectedSeasonIndex].title,
                          style: TextStyle(
                            color: Colors.grey[400],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  Widget _buildSeasonsList() {
    return ListView.builder(
      controller: _seasonsScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _filteredSeasons.length,
      itemBuilder: (context, index) => _buildSeasonItem(index),
    );
  }

  void _onSeasonTap(int index) {
    setState(() {
      _selectedSeasonIndex = index;
      _currentMode = NavigationMode.seasons;
    });
    _seasonsFocusNodes[index]?.requestFocus();
    _selectSeason(index);
  }

  Widget _buildSeasonItem(int index) {
    final season = _filteredSeasons[index];
    final isSelected = index == _selectedSeasonIndex;
    final isFocused = _currentMode == NavigationMode.seasons && isSelected;
    final episodeCount = _filteredEpisodesMap[season.id]?.length ?? 0;

    return GestureDetector(
      onTap: () => _onSeasonTap(index),
      child: Focus(
        focusNode: _seasonsFocusNodes[index],
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
            borderRadius: BorderRadius.circular(12),
            border: isFocused
                ? Border.all(color: Colors.blue, width: 2)
                : isSelected
                    ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                    : null,
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Season Image/Icon
              Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isFocused
                            ? [Colors.blue, Colors.blue.shade300]
                            : [Colors.grey[700]!, Colors.grey[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: (isFocused ? Colors.blue : Colors.grey[700]!)
                              .withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'S${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  // Season poster overlay (if available)
                  if (season.poster != null && _isValidImageUrl(season.poster!))
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: _buildEnhancedImage(
                        imageUrl: season.poster!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        fallbackWidget: Container(),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 16),

              // Season Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      season.title,
                      style: TextStyle(
                        color: isFocused ? Colors.blue : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isFocused
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.grey[700]?.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            season.releaseYear,
                            style: TextStyle(
                              color: isFocused ? Colors.blue : Colors.grey[300],
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (episodeCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$episodeCount episodes',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              AnimatedRotation(
                turns: isFocused ? 0.0 : -0.25,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.chevron_right,
                  color: isFocused ? Colors.blue : Colors.grey[600],
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyEpisodesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[800]?.withOpacity(0.3),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.video_library_outlined,
              color: Colors.grey[500],
              size: 64,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No Active Episodes Available",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "This season has no active episodes",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          if (_currentMode == NavigationMode.seasons) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Text(
                "Select another season or check back later",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
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

  Widget _buildEnhancedImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? fallbackWidget,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[800],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _isValidImageUrl(imageUrl)
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                width: width,
                height: height,
                fit: fit,
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
                errorWidget: (context, url, error) =>
                    fallbackWidget ??
                    _buildDefaultImagePlaceholder(width, height),
                fadeInDuration: const Duration(milliseconds: 300),
                fadeOutDuration: const Duration(milliseconds: 100),
              )
            : fallbackWidget ?? _buildDefaultImagePlaceholder(width, height),
      ),
    );
  }

  Widget _buildDefaultImagePlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[800]!, Colors.grey[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: Colors.grey, size: 32),
            SizedBox(height: 4),
            Text(
              "No Image",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
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

  Future<bool> _onWillPop() async {
    if (_currentMode == NavigationMode.episodes) {
      _setNavigationMode(NavigationMode.seasons);
      return false;
    }
    return false;
  }

  void _showInstructionsAgain() {
    setState(() {
      _showInstructions = true;
    });
    _instructionController.forward();
    _startInstructionTimer();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (_isProcessing) return;

    if (event is RawKeyDownEvent) {
      switch (_currentMode) {
        case NavigationMode.seasons:
          _handleSeasonsNavigation(event);
          break;
        case NavigationMode.episodes:
          _handleEpisodesNavigation(event);
          break;
      }
    }
  }

  Widget _buildBackgroundLayer() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            widget.banner,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
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
        ),
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
                AnimatedBuilder(
                  animation: _navigationModeController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: _currentMode == NavigationMode.seasons
                              ? Colors.blue
                              : Colors.green,
                          width: 5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_currentMode == NavigationMode.seasons
                                    ? Colors.blue
                                    : Colors.green)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _currentMode == NavigationMode.seasons
                                ? Icons.list_alt
                                : Icons.play_circle_outline,
                            color: _currentMode == NavigationMode.seasons
                                ? Colors.blue
                                : Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _currentMode == NavigationMode.seasons
                                ? 'BROWSING SEASONS'
                                : 'BROWSING EPISODES',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Spacer(),
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
              border:
                  Border.all(color: Colors.white.withOpacity(0.5), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
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

  Widget _buildMainContentWithLayout() {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      bottom: 20,
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
    if (_isLoading && _seasons.isEmpty) {
      return _buildLoadingWidget();
    }

    if (_errorMessage.isNotEmpty && _seasons.isEmpty) {
      return _buildErrorWidget();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildSeasonsPanel(),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 3,
            child: _buildEpisodesPanel(),
          ),
        ],
      ),
    );
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

  Widget _buildEpisodeItem(int index) {
    final episode = _currentEpisodes[index];
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
                              "EP ${index + 1}",
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
                    if (_isValidImageUrl(episode.thumbnail))
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: episode.thumbnail,
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            if (_isValidImageUrl(widget.banner)) {
                              return CachedNetworkImage(
                                imageUrl: widget.banner,
                                width: 140,
                                height: 90,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  if (_isValidImageUrl(widget.poster)) {
                                    return CachedNetworkImage(
                                      imageUrl: widget.poster,
                                      width: 140,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          Container(),
                                    );
                                  }
                                  return Container();
                                },
                              );
                            } else if (_isValidImageUrl(widget.poster)) {
                              return CachedNetworkImage(
                                imageUrl: widget.poster,
                                width: 140,
                                height: 90,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    Container(),
                              );
                            }
                            return Container();
                          },
                          fadeInDuration: const Duration(milliseconds: 300),
                          fadeOutDuration: const Duration(milliseconds: 100),
                        ),
                      )
                    else if (_isValidImageUrl(widget.banner))
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: widget.banner,
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            if (_isValidImageUrl(widget.poster)) {
                              return CachedNetworkImage(
                                imageUrl: widget.poster,
                                width: 140,
                                height: 90,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    Container(),
                              );
                            }
                            return Container();
                          },
                          fadeInDuration: const Duration(milliseconds: 300),
                          fadeOutDuration: const Duration(milliseconds: 100),
                        ),
                      )
                    else if (_isValidImageUrl(widget.poster))
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: widget.poster,
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(),
                          fadeInDuration: const Duration(milliseconds: 300),
                          fadeOutDuration: const Duration(milliseconds: 100),
                        ),
                      ),
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
                      )
                    else if (isSelected)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
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
                              'Episode ${index + 1}',
                              style: TextStyle(
                                color:
                                    isFocused ? Colors.green : Colors.grey[300],
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isFocused)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'READY TO PLAY',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: isFocused ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isFocused
                                ? [Colors.green, Colors.green.shade400]
                                : isSelected
                                    ? [
                                        Colors.white.withOpacity(0.3),
                                        Colors.white.withOpacity(0.1)
                                      ]
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
                    if (isFocused) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PRESS ENTER',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
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
            border:
                Border.all(color: highlightColor.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: highlightColor.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
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
                  if (_currentMode == NavigationMode.seasons) ...[
                    _buildInstructionItem(
                        '↑ ↓', 'Navigate Seasons', Icons.list_alt),
                    _buildInstructionItem(
                        '→ ENTER', 'Select Season', Icons.chevron_right),
                    _buildInstructionItem(
                        '← BACK', 'Exit', Icons.exit_to_app),
                  ] else ...[
                    _buildInstructionItem(
                        '↑ ↓', 'Navigate Episodes', Icons.video_library),
                    _buildInstructionItem(
                        'ENTER', 'Play Episode', Icons.play_arrow),
                    _buildInstructionItem(
                        '← BACK', 'Back to Seasons', Icons.arrow_back),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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