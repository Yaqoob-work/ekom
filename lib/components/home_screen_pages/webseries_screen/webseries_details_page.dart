






// import 'dart:async';
// import 'dart:convert';
// import 'package:mobi_tv_entertainment/components/provider/device_info_provider.dart';
// import 'package:mobi_tv_entertainment/components/services/history_service.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/custom_video_player.dart';
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
// // import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart'; // Assume NewsItemModel is defined below
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// // import '../../video_widget/socket_service.dart';

// // // =================================================================
// // // ⭐️ UPDATED NewsItemModel Class
// // // =================================================================
// // // This class is created based on the new API response structure.
// // class NewsItemModel {
// //   final String id;
// //   final String name;
// //   final String description;
// //   final String banner;
// //   final String url;
// //   final dynamic status;
// //   final String? thumbnail;
// //   final String? poster;
// //   final String updatedAt;
// //   final String? contentType;
// //   final String? source;

// //   NewsItemModel({
// //     required this.id,
// //     required this.name,
// //     required this.description,
// //     required this.banner,
// //     required this.url,
// //     this.status,
// //     this.thumbnail,
// //     this.poster,
// //     required this.updatedAt,
// //     this.contentType,
// //     this.source,
// //   });

// //   factory NewsItemModel.fromJson(Map<String, dynamic> json) {
// //     return NewsItemModel(
// //       id: json['id']?.toString() ?? '',
// //       name: json['Episoade_Name'] ?? '', // ✅ Updated from 'name'
// //       description: json['episoade_description'] ?? '', // ✅ Updated from 'description'
// //       banner: json['episoade_image'] ?? '', // ✅ Updated from 'banner'
// //       url: json['url'] ?? '',
// //       status: json['status'],
// //       // Fallbacks for thumbnail and poster using the new image key
// //       thumbnail: json['episoade_image'],
// //       poster: json['episoade_image'],
// //       updatedAt: json['updated_at'] ?? '',
// //       contentType: json['type']?.toString(), // Maps 'type' to contentType
// //       source: json['source'],
// //     );
// //   }
// // }

// // =================================================================
// // Enum and Models
// // =================================================================
// enum NavigationMode {
//   seasons,
//   episodes,
// }

// class SeasonModel {
//   final int id;
//   final String sessionName;
//   final String updatedAt;
//   final String banner;
//   final int seasonOrder;
//   final int webSeriesId;
//   final int status;

//   SeasonModel({
//     required this.id,
//     required this.sessionName,
//     required this.updatedAt,
//     required this.banner,
//     required this.seasonOrder,
//     required this.webSeriesId,
//     required this.status,
//   });

//   factory SeasonModel.fromJson(Map<String, dynamic> json) {
//     return SeasonModel(
//       id: json['id'] ?? 0,
//       sessionName: json['Session_Name'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       banner: json['banner'] ?? '',
//       seasonOrder: json['season_order'] ?? 1,
//       webSeriesId: json['web_series_id'] ?? 0,
//       status: json['status'] ?? 1,
//     );
//   }
// }

// // =================================================================
// // ⭐️ Cache Manager Class with UPDATED saveEpisodesCache
// // =================================================================
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
//                 'updated_at': season.updatedAt,
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

//   // ✅ UPDATED: Save episodes data to cache using new keys
//   static Future<void> saveEpisodesCache(
//       int seasonId, List<NewsItemModel> episodes) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cacheKey = '$_episodesCacheKeyPrefix$seasonId';
//       final lastUpdatedKey = '${_lastUpdatedKeyPrefix}episodes_$seasonId';

//       final episodesJson = episodes
//           .map((episode) => {
//                 'id': int.tryParse(episode.id),
//                 'Episoade_Name': episode.name, // Save with new key
//                 'episoade_description': episode.description, // Save with new key
//                 'episoade_image': episode.banner, // Save with new key
//                 'url': episode.url,
//                 'status': episode.status,
//                 'type': episode.contentType != null
//                     ? int.tryParse(episode.contentType!)
//                     : null,
//                 'source': episode.source,
//                 'updated_at': episode.updatedAt,
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

// // =================================================================
// // Main Widget
// // =================================================================

// class WebSeriesDetailsPage extends StatefulWidget {
//   final int id;
//   final String banner;
//   final String poster;
//   final String logo;
//   final String name;
//   final String updatedAt;

//   const WebSeriesDetailsPage({
//     Key? key,
//     required this.id,
//     required this.banner,
//     required this.poster,
//     required this.logo,
//     required this.name,
//     required this.updatedAt,
//   }) : super(key: key);

//   @override
//   _WebSeriesDetailsPageState createState() => _WebSeriesDetailsPageState();
// }

// class _WebSeriesDetailsPageState extends State<WebSeriesDetailsPage>
//     with WidgetsBindingObserver, TickerProviderStateMixin {
//   final ScrollController _scrollController = ScrollController();
//   final ScrollController _seasonsScrollController = ScrollController();
//   final FocusNode _mainFocusNode = FocusNode();

//   List<SeasonModel> _seasons = [];
//   Map<int, List<NewsItemModel>> _episodesMap = {};

//   int _selectedSeasonIndex = 0;
//   int _selectedEpisodeIndex = 0;

//   NavigationMode _currentMode = NavigationMode.seasons;

//   final Map<int, FocusNode> _seasonsFocusNodes = {};
//   final Map<String, FocusNode> _episodeFocusNodes = {};

//   String _errorMessage = "";
//   String _authKey = '';

//   Timer? _instructionTimer;

//   List<SeasonModel> _filteredSeasons = [];
//   Map<int, List<NewsItemModel>> _filteredEpisodesMap = {};

//   bool _isLoading = false;
//   bool _isProcessing = false;
//   bool _isLoadingEpisodes = false;
//   bool _isBackgroundRefreshing = false;

//   late AnimationController _navigationModeController;
//   late AnimationController _instructionController;
//   late AnimationController _pageTransitionController;

//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

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
//     _initializeAnimations();
//     _loadAuthKey();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _scrollController.dispose();
//     _seasonsScrollController.dispose();
//     _mainFocusNode.dispose();
//     _seasonsFocusNodes.values.forEach((node) => node.dispose());
//     _episodeFocusNodes.values.forEach((node) => node.dispose());
//     _navigationModeController.dispose();
//     _instructionController.dispose();
//     _pageTransitionController.dispose();
//     _instructionTimer?.cancel();
//     super.dispose();
//   }

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

//   Future<void> _initializePageWithCache() async {
//     print('🚀 Initializing web series page with cache for show ${widget.id}');
//     final cachedSeasons =
//         await WebSeriesCacheManager.getSeasonsCache(widget.id);

//     if (cachedSeasons != null && cachedSeasons.isNotEmpty) {
//       print('⚡ Loading web series from cache instantly');
//       await _loadSeasonsFromCache(cachedSeasons);
//       _performBackgroundRefresh();
//     } else {
//       print('📡 No web series cache available, loading from API');
//       await _fetchSeasonsFromAPI(showLoading: true);
//     }
//   }

//   Future<void> _loadSeasonsFromCache(List<SeasonModel> cachedSeasons) async {
//     final activeSeasons = _filterActiveSeasons(cachedSeasons);

//     setState(() {
//       _seasons = cachedSeasons;
//       _filteredSeasons = activeSeasons;
//       _isLoading = false;
//       _errorMessage = "";
//     });

//     _seasonsFocusNodes.clear();
//     for (int i = 0; i < _filteredSeasons.length; i++) {
//       _seasonsFocusNodes[i] = FocusNode();
//     }

//     if (_filteredSeasons.isNotEmpty) {
//       _pageTransitionController.forward();
//       _fetchEpisodes(_filteredSeasons[0].id);

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           _seasonsFocusNodes[0]?.requestFocus();
//         }
//       });
//     }
//   }

//   Future<void> _performBackgroundRefresh() async {
//     print('🔄 Starting web series background refresh');
//     setState(() {
//       _isBackgroundRefreshing = true;
//     });

//     try {
//       final freshSeasons = await _fetchSeasonsFromAPIDirectly();
//       if (freshSeasons != null) {
//         final cachedSeasons = _seasons;
//         final hasChanges = WebSeriesCacheManager.areSeasonsDifferent(
//             cachedSeasons, freshSeasons);

//         if (hasChanges) {
//           print('🔄 Web series changes detected, updating UI silently');
//           await WebSeriesCacheManager.saveSeasonsCache(widget.id, freshSeasons);
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

//     if (currentSelectedSeasonId != null) {
//       final newIndex =
//           _filteredSeasons.indexWhere((s) => s.id == currentSelectedSeasonId);
//       if (newIndex >= 0) {
//         setState(() {
//           _selectedSeasonIndex = newIndex;
//         });
//       }
//     }

//     _seasonsFocusNodes.clear();
//     for (int i = 0; i < _filteredSeasons.length; i++) {
//       _seasonsFocusNodes[i] = FocusNode();
//     }
//   }

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
//         await WebSeriesCacheManager.saveSeasonsCache(widget.id, seasons);
//         await _loadSeasonsFromCache(seasons);
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = "Error: ${e.toString()}";
//       });
//     }
//   }

//   Future<List<SeasonModel>?> _fetchSeasonsFromAPIDirectly() async {
//             String authKey = SessionManager.authKey ;
//       var url = Uri.parse(SessionManager.baseUrl + 'getSeasons/${widget.id}');

//     final response = await https.get(url,
//       // Uri.parse(
//       //     'https://dashboard.cpplayers.com/api/v2/getSeasons/${widget.id}'),
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
//         return data.map((season) => SeasonModel.fromJson(season)).toList();
//       }
//     }
//     throw Exception('Failed to load seasons (${response.statusCode})');
//   }

//   Future<void> _fetchEpisodes(int seasonId) async {
//     if (_filteredEpisodesMap.containsKey(seasonId)) {
//       setState(() {
//         _selectedSeasonIndex =
//             _filteredSeasons.indexWhere((season) => season.id == seasonId);
//         _selectedEpisodeIndex = 0;
//       });
//       _setNavigationMode(NavigationMode.episodes);
//       return;
//     }

//     final cachedEpisodes =
//         await WebSeriesCacheManager.getEpisodesCache(seasonId);

//     if (cachedEpisodes != null) {
//       await _loadEpisodesFromCache(seasonId, cachedEpisodes);
//       _performEpisodesBackgroundRefresh(seasonId);
//     } else {
//       await _fetchEpisodesFromAPI(seasonId, showLoading: true);
//     }
//   }

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

//   Future<void> _performEpisodesBackgroundRefresh(int seasonId) async {
//     try {
//       final freshEpisodes = await _fetchEpisodesFromAPIDirectly(seasonId);

//       if (freshEpisodes != null) {
//         final cachedEpisodes = _episodesMap[seasonId] ?? [];
//         final hasChanges = WebSeriesCacheManager.areEpisodesDifferent(
//             cachedEpisodes, freshEpisodes);

//         if (hasChanges) {
//           print('🔄 Web series episodes changes detected for season $seasonId');
//           await WebSeriesCacheManager.saveEpisodesCache(
//               seasonId, freshEpisodes);
//           await _loadEpisodesFromCache(seasonId, freshEpisodes);
//         }
//       }
//     } catch (e) {
//       print('❌ Web series episodes background refresh failed: $e');
//     }
//   }

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
//         await WebSeriesCacheManager.saveEpisodesCache(seasonId, episodes);
//         await _loadEpisodesFromCache(seasonId, episodes);
//       }
//     } catch (e) {
//       setState(() {
//         _isLoadingEpisodes = false;
//         _errorMessage = "Error loading episodes: ${e.toString()}";
//       });
//     }
//   }

//   Future<List<NewsItemModel>?> _fetchEpisodesFromAPIDirectly(
//       int seasonId) async {
//             String authKey = SessionManager.authKey ;
//       var url = Uri.parse(SessionManager.baseUrl + 'getEpisodes/$seasonId/0');

//     final response = await https.get(url,
//       // Uri.parse(
//       //     'https://dashboard.cpplayers.com/api/v2/getEpisodes/$seasonId/0'),
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
//         return data.map((e) => NewsItemModel.fromJson(e)).toList();
//       }
//     }
//     throw Exception('Failed to load episodes for season $seasonId');
//   }

//   Future<void> _refreshDataOnReturn() async {
//     print('🔄 Refreshing web series data on return from video player');
//     await _performBackgroundRefresh();

//     if (_filteredSeasons.isNotEmpty &&
//         _selectedSeasonIndex < _filteredSeasons.length) {
//       final currentSeasonId = _filteredSeasons[_selectedSeasonIndex].id;
//       if (_filteredEpisodesMap.containsKey(currentSeasonId)) {
//         await _performEpisodesBackgroundRefresh(currentSeasonId);
//       }
//     }
//   }

//   Future<void> _playEpisode(NewsItemModel episode) async {
//     if (_isProcessing) return;

//     setState(() => _isProcessing = true);

//     try {
//       print('Updating user history for: ${episode.name}');
//       int? currentUserId = SessionManager.userId;
//       final int? parsedContentType = int.tryParse(episode.contentType ?? '');
//       final int? parsedId = int.tryParse(episode.id ?? '');

//       if (currentUserId != null &&
//           parsedContentType != null &&
//           parsedId != null) {
//         await HistoryService.updateUserHistory(
//           userId: currentUserId,
//           contentType: parsedContentType,
//           eventId: parsedId,
//           eventTitle: episode.name,
//           url: episode.url,
//           categoryId: 0,
//         );
//       }
//     } catch (e) {
//       print("History update failed, but proceeding to play. Error: $e");
//     }

//     try {
//       if (mounted) {
//         if (episode.source == 'youtube' || isYoutubeUrl(episode.url)) {
//           final deviceInfo = context.read<DeviceInfoProvider>();
//           if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => YoutubeWebviewPlayer(
//                   videoUrl: episode.url,
//                   name: episode.name,
//                 ),
//               ),
//             );
//           } else {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => CustomYoutubePlayer(
//                   videoData: VideoData(
//                     id: episode.url,
//                     title: episode.name,
//                     youtubeUrl: episode.url,
//                     thumbnail: episode.thumbnail ?? '',
//                     description: episode.description,
//                   ),
//                   playlist: [
//                     VideoData(
//                       id: episode.url,
//                       title: episode.name,
//                       youtubeUrl: episode.url,
//                       thumbnail: episode.thumbnail ?? '',
//                       description: episode.description,
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//         } else {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => VideoScreen(
//                 videoUrl: episode.url,
//                 bannerImageUrl: episode.banner,
//                 channelList: [],
//                 videoId: int.tryParse(episode.id),
//                 name: episode.name,
//                 liveStatus: false,
//                 updatedAt: episode.updatedAt,
//                 source: 'isWebSeries',
//               ),
//             ),
//           );
//         }
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
//     if (episodes.isEmpty) return;

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
//         _playEpisode(episodes[_selectedEpisodeIndex]);
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
//     return _filteredEpisodesMap[_filteredSeasons[_selectedSeasonIndex].id] ?? [];
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
//         alignment: 0.5,
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

//   bool _isValidImageUrl(String? url) {
//     if (url == null || url.isEmpty) return false;
//     try {
//       final uri = Uri.parse(url);
//       return (uri.scheme == 'http' || uri.scheme == 'https') &&
//           uri.host.isNotEmpty;
//     } catch (e) {
//       return false;
//     }
//   }

//   Widget _buildEnhancedImage({
//     required String imageUrl,
//     required double width,
//     required double height,
//     BoxFit fit = BoxFit.cover,
//     Widget? fallbackWidget,
//     required String cachedKey,
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
//                 cacheKey: cachedKey,
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
//                       valueColor:
//                           AlwaysStoppedAnimation<Color>(Colors.blue),
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
//             _buildBackgroundLayer(),
//             _buildMainContentWithLayout(),
//             _buildTopNavigationBar(),
//             if (_isProcessing) _buildProcessingOverlay(),
//             if (_isBackgroundRefreshing) _buildBackgroundRefreshIndicator(),
//           ],
//         ),
//       ),
//     );
//   }

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
//         child: const Row(
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
//             SizedBox(width: 6),
//             Text(
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
//         Positioned.fill(
//           child: CachedNetworkImage(
//             imageUrl: widget.banner,
//             fit: BoxFit.cover,
//             errorWidget: (_, __, ___) => Container(
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
//     final String uniqueImageUrl = "${widget.logo}?v=${widget.updatedAt}";
//     final String uniqueCacheKey = "${widget.id.toString()}_${widget.updatedAt}";
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
//                 if (_isValidImageUrl(widget.logo))
//                   CachedNetworkImage(
//                     imageUrl: uniqueImageUrl,
//                     width: 50,
//                     height: 50,
//                     fit: BoxFit.contain,
//                     cacheKey: uniqueCacheKey,
//                   ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Text(
//                     widget.name.toUpperCase(),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                       letterSpacing: 1.5,
//                     ),
//                     textAlign: TextAlign.center,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
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
//       top: 100,
//       left: 0,
//       right: 0,
//       bottom: 20,
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
//           Expanded(
//             flex: 3,
//             child: _buildSeasonsPanel(),
//           ),
//           const SizedBox(width: 20),
//           Expanded(
//             flex: 5,
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
//                   "SEASONS",
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
//                 const Text(
//                   "EPISODES",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.0,
//                   ),
//                 ),
//                 const Spacer(),
//                 if (_filteredSeasons.isNotEmpty &&
//                     _selectedSeasonIndex < _filteredSeasons.length)
//                   Expanded(
//                     child: Text(
//                       _filteredSeasons[_selectedSeasonIndex].sessionName,
//                       style: TextStyle(
//                         color: Colors.grey[400],
//                         fontSize: 16,
//                       ),
//                       textAlign: TextAlign.end,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 const SizedBox(width: 12),
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
//     final String uniqueImageUrl = "${season.banner}?v=${season.updatedAt}";
//     final String uniqueCacheKey = "${season.id.toString()}_${season.updatedAt}";

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
//               _buildEnhancedImage(
//                 imageUrl: uniqueImageUrl,
//                 width: 50,
//                 height: 50,
//                 cachedKey: uniqueCacheKey,
//                 fit: BoxFit.cover,
//                 fallbackWidget: Container(
//                   width: 50,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: isFocused
//                           ? [Colors.blue, Colors.blue.shade300]
//                           : [Colors.grey[700]!, Colors.grey[600]!],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Center(
//                     child: Text(
//                       '${season.seasonOrder}',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
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
//                         if (episodeCount > 0)
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
//     final String uniqueImageUrl = "${episode.banner}?v=${episode.updatedAt}";
//     final String uniquePosterImageUrl =
//         "${episode.poster}?v=${episode.updatedAt}";
//     final String uniqueCacheKey =
//         "${episode.id.toString()}_${episode.updatedAt}";

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
//                 : null,
//             color: !isFocused
//                 ? Colors.grey[900]?.withOpacity(0.4)
//                 : null,
//             borderRadius: BorderRadius.circular(16),
//             border: isFocused
//                 ? Border.all(color: Colors.green, width: 2)
//                 : Border.all(color: Colors.white.withOpacity(0.1), width: 1),
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
//               Container(
//                 margin: const EdgeInsets.all(12),
//                 width: 140,
//                 height: 90,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     _buildEnhancedImage(
//                       imageUrl: uniqueImageUrl,
//                       width: 140,
//                       height: 90,
//                       cachedKey: uniqueCacheKey,
//                       fallbackWidget: _buildEnhancedImage(
//                         imageUrl: uniquePosterImageUrl,
//                         width: 140,
//                         height: 90,
//                         cachedKey: "poster_$uniqueCacheKey",
//                       ),
//                     ),
//                     if (isProcessing)
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.7),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Center(
//                           child: SpinKitRing(
//                             color: Colors.green,
//                             size: 30,
//                             lineWidth: 3,
//                           ),
//                         ),
//                       )
//                     else if (isFocused)
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.5),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Center(
//                           child: Icon(
//                             Icons.play_arrow,
//                             color: Colors.white,
//                             size: 48,
//                           ),
//                         ),
//                       )
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
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
//                       const SizedBox(height: 8),
//                       Text(
//                         'Episode ${index + 1}',
//                         style: TextStyle(
//                           color: Colors.grey[400],
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
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
//           Icon(
//             Icons.movie_filter_outlined,
//             color: Colors.grey[700],
//             size: 64,
//           ),
//           const SizedBox(height: 20),
//           Text(
//             "No Episodes Found",
//             style: TextStyle(
//               color: Colors.grey[400],
//               fontSize: 18,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "This season may not have episodes yet.",
//             style: TextStyle(color: Colors.grey[600], fontSize: 14),
//           ),
//         ],
//       ),
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
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 24, vertical: 12),
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
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }






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

// // =================================================================
// // Enum and Models
// // =================================================================
// enum NavigationMode {
//   seasons,
//   episodes,
// }

// class SeasonModel {
//   final int id;
//   final String sessionName;
//   final String updatedAt;
//   final String banner;
//   final int seasonOrder;
//   final int webSeriesId;
//   final int status;

//   SeasonModel({
//     required this.id,
//     required this.sessionName,
//     required this.updatedAt,
//     required this.banner,
//     required this.seasonOrder,
//     required this.webSeriesId,
//     required this.status,
//   });

//   factory SeasonModel.fromJson(Map<String, dynamic> json) {
//     return SeasonModel(
//       id: json['id'] ?? 0,
//       sessionName: json['Session_Name'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       banner: json['banner'] ?? '',
//       seasonOrder: json['season_order'] ?? 1,
//       webSeriesId: json['web_series_id'] ?? 0,
//       status: json['status'] ?? 1,
//     );
//   }
// }

// // =================================================================
// // Cache Manager Class
// // =================================================================
// class WebSeriesCacheManager {
//   static const String _cacheKeyPrefix = 'web_series_cache_';
//   static const String _episodesCacheKeyPrefix = 'episodes_cache_';
//   static const String _lastUpdatedKeyPrefix = 'last_updated_';
//   static const Duration _cacheValidDuration = Duration(hours: 6);

//   static Future<void> saveSeasonsCache(int showId, List<SeasonModel> seasons) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cacheKey = '$_cacheKeyPrefix$showId';
//       final lastUpdatedKey = '$_lastUpdatedKeyPrefix$showId';

//       final seasonsJson = seasons.map((season) => {
//         'id': season.id,
//         'Session_Name': season.sessionName,
//         'banner': season.banner,
//         'season_order': season.seasonOrder,
//         'web_series_id': season.webSeriesId,
//         'status': season.status,
//         'updated_at': season.updatedAt,
//       }).toList();

//       await prefs.setString(cacheKey, jsonEncode(seasonsJson));
//       await prefs.setInt(lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);
//     } catch (e) {
//       print('❌ Error saving web series seasons cache: $e');
//     }
//   }

//   static Future<List<SeasonModel>?> getSeasonsCache(int showId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cacheKey = '$_cacheKeyPrefix$showId';
//       final lastUpdatedKey = '$_lastUpdatedKeyPrefix$showId';

//       final cachedData = prefs.getString(cacheKey);
//       final lastUpdated = prefs.getInt(lastUpdatedKey);

//       if (cachedData == null || lastUpdated == null) return null;

//       final cacheAge = DateTime.now().millisecondsSinceEpoch - lastUpdated;
//       if (cacheAge > _cacheValidDuration.inMilliseconds) return null;

//       final List<dynamic> seasonsJson = jsonDecode(cachedData);
//       return seasonsJson.map((json) => SeasonModel.fromJson(json)).toList();
//     } catch (e) {
//       return null;
//     }
//   }

//   static Future<void> saveEpisodesCache(int seasonId, List<NewsItemModel> episodes) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cacheKey = '$_episodesCacheKeyPrefix$seasonId';
//       final lastUpdatedKey = '${_lastUpdatedKeyPrefix}episodes_$seasonId';

//       final episodesJson = episodes.map((episode) => {
//         'id': int.tryParse(episode.id),
//         'Episoade_Name': episode.name,
//         'episoade_description': episode.description,
//         'episoade_image': episode.banner,
//         'url': episode.url,
//         'status': episode.status,
//         'type': episode.contentType != null ? int.tryParse(episode.contentType!) : null,
//         'source': episode.source,
//         'updated_at': episode.updatedAt,
//       }).toList();

//       await prefs.setString(cacheKey, jsonEncode(episodesJson));
//       await prefs.setInt(lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);
//     } catch (e) {
//       print('❌ Error saving web series episodes cache: $e');
//     }
//   }

//   static Future<List<NewsItemModel>?> getEpisodesCache(int seasonId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cacheKey = '$_episodesCacheKeyPrefix$seasonId';
//       final lastUpdatedKey = '${_lastUpdatedKeyPrefix}episodes_$seasonId';

//       final cachedData = prefs.getString(cacheKey);
//       final lastUpdated = prefs.getInt(lastUpdatedKey);

//       if (cachedData == null || lastUpdated == null) return null;

//       final cacheAge = DateTime.now().millisecondsSinceEpoch - lastUpdated;
//       if (cacheAge > _cacheValidDuration.inMilliseconds) return null;

//       final List<dynamic> episodesJson = jsonDecode(cachedData);
//       return episodesJson.map((json) => NewsItemModel.fromJson(json)).toList();
//     } catch (e) {
//       return null;
//     }
//   }

//   static bool areSeasonsDifferent(List<SeasonModel> cached, List<SeasonModel> fresh) {
//     if (cached.length != fresh.length) return true;
//     for (int i = 0; i < cached.length; i++) {
//       if (cached[i].updatedAt != fresh[i].updatedAt) return true;
//     }
//     return false;
//   }

//   static bool areEpisodesDifferent(List<NewsItemModel> cached, List<NewsItemModel> fresh) {
//     if (cached.length != fresh.length) return true;
//     for (int i = 0; i < cached.length; i++) {
//       if (cached[i].updatedAt != fresh[i].updatedAt) return true;
//     }
//     return false;
//   }
// }

// // =================================================================
// // Main Widget
// // =================================================================

// class WebSeriesDetailsPage extends StatefulWidget {
//   final int id;
//   final String banner;
//   final String poster;
//   final String logo;
//   final String name;
//   final String updatedAt;

//   const WebSeriesDetailsPage({
//     Key? key,
//     required this.id,
//     required this.banner,
//     required this.poster,
//     required this.logo,
//     required this.name,
//     required this.updatedAt,
//   }) : super(key: key);

//   @override
//   _WebSeriesDetailsPageState createState() => _WebSeriesDetailsPageState();
// }

// class _WebSeriesDetailsPageState extends State<WebSeriesDetailsPage>
//     with WidgetsBindingObserver, TickerProviderStateMixin {
//   final ScrollController _scrollController = ScrollController();
//   final ScrollController _seasonsScrollController = ScrollController();
//   final FocusNode _mainFocusNode = FocusNode();

//   List<SeasonModel> _seasons = [];
//   Map<int, List<NewsItemModel>> _episodesMap = {};

//   int _selectedSeasonIndex = 0;
//   int _selectedEpisodeIndex = 0;

//   NavigationMode _currentMode = NavigationMode.seasons;

//   final Map<int, FocusNode> _seasonsFocusNodes = {};
//   final Map<String, FocusNode> _episodeFocusNodes = {};

//   String _errorMessage = "";
//   String _authKey = '';

//   Timer? _instructionTimer;

//   List<SeasonModel> _filteredSeasons = [];
//   Map<int, List<NewsItemModel>> _filteredEpisodesMap = {};

//   bool _isLoading = false;
//   bool _isProcessing = false;
//   bool _isLoadingEpisodes = false;
//   bool _isBackgroundRefreshing = false;

//   late AnimationController _navigationModeController;
//   late AnimationController _instructionController;
//   late AnimationController _pageTransitionController;

//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   List<SeasonModel> _filterActiveSeasons(List<SeasonModel> seasons) {
//     return seasons.where((season) => season.status == 1).toList();
//   }

//   List<NewsItemModel> _filterActiveEpisodes(List<NewsItemModel> episodes) {
//     return episodes.where((episode) {
//       try {
//         final status = episode.status;
//         if (status == null) return false;
//         if (status is int) return status == 1;
//         if (status is String) return status == '1';
//         return false;
//       } catch (e) {
//         return false;
//       }
//     }).toList();
//   }

//   @override
//   void initState() {
//     super.initState();
//     SecureUrlService.refreshSettings();
//     WidgetsBinding.instance.addObserver(this);
//     _initializeAnimations();
//     _loadAuthKey();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _scrollController.dispose();
//     _seasonsScrollController.dispose();
//     _mainFocusNode.dispose();
//     _seasonsFocusNodes.values.forEach((node) => node.dispose());
//     _episodeFocusNodes.values.forEach((node) => node.dispose());
//     _navigationModeController.dispose();
//     _instructionController.dispose();
//     _pageTransitionController.dispose();
//     _instructionTimer?.cancel();
//     super.dispose();
//   }

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

//   Future<void> _initializePageWithCache() async {
//     final cachedSeasons = await WebSeriesCacheManager.getSeasonsCache(widget.id);

//     if (cachedSeasons != null && cachedSeasons.isNotEmpty) {
//       await _loadSeasonsFromCache(cachedSeasons);
//       _performBackgroundRefresh();
//     } else {
//       await _fetchSeasonsFromAPI(showLoading: true);
//     }
//   }

//   Future<void> _loadSeasonsFromCache(List<SeasonModel> cachedSeasons) async {
//     final activeSeasons = _filterActiveSeasons(cachedSeasons);

//     setState(() {
//       _seasons = cachedSeasons;
//       _filteredSeasons = activeSeasons;
//       _isLoading = false;
//       _errorMessage = "";
//     });

//     _seasonsFocusNodes.clear();
//     for (int i = 0; i < _filteredSeasons.length; i++) {
//       _seasonsFocusNodes[i] = FocusNode();
//     }

//     if (_filteredSeasons.isNotEmpty) {
//       _pageTransitionController.forward();
//       _fetchEpisodes(_filteredSeasons[0].id);

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           _seasonsFocusNodes[0]?.requestFocus();
//         }
//       });
//     }
//   }

//   Future<void> _performBackgroundRefresh() async {
//     setState(() => _isBackgroundRefreshing = true);
//     try {
//       final freshSeasons = await _fetchSeasonsFromAPIDirectly();
//       if (freshSeasons != null) {
//         final cachedSeasons = _seasons;
//         final hasChanges = WebSeriesCacheManager.areSeasonsDifferent(cachedSeasons, freshSeasons);

//         if (hasChanges) {
//           await WebSeriesCacheManager.saveSeasonsCache(widget.id, freshSeasons);
//           await _updateSeasonsData(freshSeasons);
//         }
//       }
//     } catch (e) {
//       print('❌ Web series background refresh failed: $e');
//     } finally {
//       if (mounted) setState(() => _isBackgroundRefreshing = false);
//     }
//   }

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

//     if (currentSelectedSeasonId != null) {
//       final newIndex = _filteredSeasons.indexWhere((s) => s.id == currentSelectedSeasonId);
//       if (newIndex >= 0) {
//         setState(() => _selectedSeasonIndex = newIndex);
//       }
//     }

//     _seasonsFocusNodes.clear();
//     for (int i = 0; i < _filteredSeasons.length; i++) {
//       _seasonsFocusNodes[i] = FocusNode();
//     }
//   }

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
//         await WebSeriesCacheManager.saveSeasonsCache(widget.id, seasons);
//         await _loadSeasonsFromCache(seasons);
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = "Error: ${e.toString()}";
//       });
//     }
//   }

//   Future<List<SeasonModel>?> _fetchSeasonsFromAPIDirectly() async {
//     String authKey = SessionManager.authKey;
//     var url = Uri.parse(SessionManager.baseUrl + 'getSeasons/${widget.id}');

//     final response = await https.get(url, headers: {
//       'auth-key': authKey,
//       'Accept': 'application/json',
//       'Content-Type': 'application/json',
//       'domain': SessionManager.savedDomain,
//     }).timeout(const Duration(seconds: 15));

//     if (response.statusCode == 200) {
//       String responseBody = response.body.trim();
//       if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
//         final List<dynamic> data = jsonDecode(responseBody);
//         return data.map((season) => SeasonModel.fromJson(season)).toList();
//       }
//     }
//     throw Exception('Failed to load seasons (${response.statusCode})');
//   }

//   Future<void> _fetchEpisodes(int seasonId) async {
//     if (_filteredEpisodesMap.containsKey(seasonId)) {
//       setState(() {
//         _selectedSeasonIndex = _filteredSeasons.indexWhere((season) => season.id == seasonId);
//         _selectedEpisodeIndex = 0;
//       });
//       _setNavigationMode(NavigationMode.episodes);
//       return;
//     }

//     final cachedEpisodes = await WebSeriesCacheManager.getEpisodesCache(seasonId);

//     if (cachedEpisodes != null) {
//       await _loadEpisodesFromCache(seasonId, cachedEpisodes);
//       _performEpisodesBackgroundRefresh(seasonId);
//     } else {
//       await _fetchEpisodesFromAPI(seasonId, showLoading: true);
//     }
//   }

//   Future<void> _loadEpisodesFromCache(int seasonId, List<NewsItemModel> cachedEpisodes) async {
//     final activeEpisodes = _filterActiveEpisodes(cachedEpisodes);

//     _episodeFocusNodes.clear();
//     for (var episode in activeEpisodes) {
//       _episodeFocusNodes[episode.id] = FocusNode();
//     }

//     setState(() {
//       _episodesMap[seasonId] = cachedEpisodes;
//       _filteredEpisodesMap[seasonId] = activeEpisodes;
//       _selectedSeasonIndex = _filteredSeasons.indexWhere((s) => s.id == seasonId);
//       _selectedEpisodeIndex = 0;
//       _isLoadingEpisodes = false;
//     });

//     _setNavigationMode(NavigationMode.episodes);
//   }

//   Future<void> _performEpisodesBackgroundRefresh(int seasonId) async {
//     try {
//       final freshEpisodes = await _fetchEpisodesFromAPIDirectly(seasonId);
//       if (freshEpisodes != null) {
//         final cachedEpisodes = _episodesMap[seasonId] ?? [];
//         final hasChanges = WebSeriesCacheManager.areEpisodesDifferent(cachedEpisodes, freshEpisodes);

//         if (hasChanges) {
//           await WebSeriesCacheManager.saveEpisodesCache(seasonId, freshEpisodes);
//           await _loadEpisodesFromCache(seasonId, freshEpisodes);
//         }
//       }
//     } catch (e) {
//       print('❌ Web series episodes background refresh failed: $e');
//     }
//   }

//   Future<void> _fetchEpisodesFromAPI(int seasonId, {bool showLoading = false}) async {
//     if (showLoading) setState(() => _isLoadingEpisodes = true);

//     try {
//       final episodes = await _fetchEpisodesFromAPIDirectly(seasonId);
//       if (episodes != null) {
//         await WebSeriesCacheManager.saveEpisodesCache(seasonId, episodes);
//         await _loadEpisodesFromCache(seasonId, episodes);
//       }
//     } catch (e) {
//       setState(() {
//         _isLoadingEpisodes = false;
//         _errorMessage = "Error loading episodes: ${e.toString()}";
//       });
//     }
//   }

//   Future<List<NewsItemModel>?> _fetchEpisodesFromAPIDirectly(int seasonId) async {
//     String authKey = SessionManager.authKey;
//     var url = Uri.parse(SessionManager.baseUrl + 'getEpisodes/$seasonId/0');

//     final response = await https.get(url, headers: {
//       'auth-key': authKey,
//       'Accept': 'application/json',
//       'Content-Type': 'application/json',
//       'domain': SessionManager.savedDomain,
//     }).timeout(const Duration(seconds: 15));

//     if (response.statusCode == 200) {
//       String responseBody = response.body.trim();
//       if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
//         final List<dynamic> data = jsonDecode(responseBody);
//         return data.map((e) => NewsItemModel.fromJson(e)).toList();
//       }
//     }
//     throw Exception('Failed to load episodes for season $seasonId');
//   }

//   Future<void> _refreshDataOnReturn() async {
//     await _performBackgroundRefresh();
//     if (_filteredSeasons.isNotEmpty && _selectedSeasonIndex < _filteredSeasons.length) {
//       final currentSeasonId = _filteredSeasons[_selectedSeasonIndex].id;
//       if (_filteredEpisodesMap.containsKey(currentSeasonId)) {
//         await _performEpisodesBackgroundRefresh(currentSeasonId);
//       }
//     }
//   }

//   Future<void> _playEpisode(NewsItemModel episode) async {
//     if (_isProcessing) return;
//     setState(() => _isProcessing = true);

//     try {
//       int? currentUserId = SessionManager.userId;
//       final int? parsedContentType = int.tryParse(episode.contentType ?? '');
//       final int? parsedId = int.tryParse(episode.id ?? '');

//       if (currentUserId != null && parsedContentType != null && parsedId != null) {
//         await HistoryService.updateUserHistory(
//           userId: currentUserId,
//           contentType: parsedContentType,
//           eventId: parsedId,
//           eventTitle: episode.name,
//           url: episode.url,
//           categoryId: 0,
//         );
//       }
//     } catch (e) {
//       print("History update failed: $e");
//     }

//     try {
//       if (mounted) {
//               String rawUrl = episode.url;
//       print('rawurl: $rawUrl');
//       String playableUrl = await SecureUrlService.getSecureUrl(rawUrl);
//         if (episode.source == 'youtube' || isYoutubeUrl(episode.url)) {
//           final deviceInfo = context.read<DeviceInfoProvider>();
//           if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => YoutubeWebviewPlayer(
//                   videoUrl: playableUrl,
//                   name: episode.name,
//                 ),
//               ),
//             );
//           } else {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => CustomYoutubePlayer(
//                   videoData: VideoData(
//                     id: playableUrl,
//                     title: episode.name,
//                     youtubeUrl: playableUrl,
//                     thumbnail: episode.thumbnail ?? '',
//                     description: episode.description,
//                   ),
//                   playlist: [
//                     VideoData(
//                       id: playableUrl,
//                       title: episode.name,
//                       youtubeUrl: playableUrl,
//                       thumbnail: episode.thumbnail ?? '',
//                       description: episode.description,
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//         } else {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => VideoScreen(
//                 videoUrl: playableUrl,
//                 bannerImageUrl: episode.banner,
//                 channelList: [],
//                 videoId: int.tryParse(episode.id),
//                 name: episode.name,
//                 liveStatus: false,
//                 updatedAt: episode.updatedAt,
//                 source: 'isWebSeries',
//               ),
//             ),
//           );
//         }
//         await _refreshDataOnReturn();
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Error playing video'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isProcessing = false);
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
//       setState(() => _selectedSeasonIndex = index);
//       _fetchEpisodes(_filteredSeasons[index].id);
//     }
//   }

//   void _handleSeasonsNavigation(RawKeyEvent event) {
//     switch (event.logicalKey) {
//       case LogicalKeyboardKey.arrowDown:
//         if (_selectedSeasonIndex < _filteredSeasons.length - 1) {
//           setState(() => _selectedSeasonIndex++);
//           _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
//         }
//         break;
//       case LogicalKeyboardKey.arrowUp:
//         if (_selectedSeasonIndex > 0) {
//           setState(() => _selectedSeasonIndex--);
//           _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
//         }
//         break;
//       case LogicalKeyboardKey.enter:
//       case LogicalKeyboardKey.select:
//       case LogicalKeyboardKey.arrowRight:
//         if (_filteredSeasons.isNotEmpty) _selectSeason(_selectedSeasonIndex);
//         break;
//     }
//   }

//   void _handleEpisodesNavigation(RawKeyEvent event) {
//     final episodes = _currentEpisodes;
//     if (episodes.isEmpty) return;

//     switch (event.logicalKey) {
//       case LogicalKeyboardKey.arrowDown:
//         if (_selectedEpisodeIndex < episodes.length - 1) {
//           setState(() => _selectedEpisodeIndex++);
//           _scrollAndFocusEpisode(_selectedEpisodeIndex);
//         }
//         break;
//       case LogicalKeyboardKey.arrowUp:
//         if (_selectedEpisodeIndex > 0) {
//           setState(() => _selectedEpisodeIndex--);
//           _scrollAndFocusEpisode(_selectedEpisodeIndex);
//         }
//         break;
//       case LogicalKeyboardKey.enter:
//       case LogicalKeyboardKey.select:
//         _playEpisode(episodes[_selectedEpisodeIndex]);
//         break;
//       case LogicalKeyboardKey.arrowLeft:
//       case LogicalKeyboardKey.escape:
//         _setNavigationMode(NavigationMode.seasons);
//         break;
//     }
//   }

//   List<NewsItemModel> get _currentEpisodes {
//     if (_filteredSeasons.isEmpty || _selectedSeasonIndex >= _filteredSeasons.length) {
//       return [];
//     }
//     return _filteredEpisodesMap[_filteredSeasons[_selectedSeasonIndex].id] ?? [];
//   }

//   void _setNavigationMode(NavigationMode mode) {
//     setState(() => _currentMode = mode);
//     if (mode == NavigationMode.seasons) {
//       _navigationModeController.reverse();
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
//       });
//     } else {
//       _navigationModeController.forward();
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_currentEpisodes.isNotEmpty) {
//           _episodeFocusNodes[_currentEpisodes[_selectedEpisodeIndex].id]?.requestFocus();
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
//         alignment: 0.5,
//       );
//     }
//   }

//   void _initializeAnimations() {
//     _navigationModeController = AnimationController(
//         duration: const Duration(milliseconds: 400), vsync: this);
//     _instructionController = AnimationController(
//         duration: const Duration(milliseconds: 600), vsync: this);
//     _pageTransitionController = AnimationController(
//         duration: const Duration(milliseconds: 800), vsync: this);

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
//         parent: _pageTransitionController, curve: Curves.easeInOut));
//     _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero)
//         .animate(CurvedAnimation(
//             parent: _pageTransitionController, curve: Curves.easeOutCubic));
//   }

//   bool _isValidImageUrl(String? url) {
//     if (url == null || url.trim().isEmpty) return false;
//     if (url.contains('null') || url.startsWith('?')) return false;

//     try {
//       final uri = Uri.parse(url);
//       return (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
//     } catch (e) {
//       return false;
//     }
//   }

//   // =================================================================
//   // ✅ FIXED: Helper Method Updates for Placeholders
//   // =================================================================
//   Widget _buildEnhancedImage({
//     required String imageUrl,
//     required double width,
//     required double height,
//     BoxFit fit = BoxFit.cover,
//     Widget? fallbackWidget,
//     required String cachedKey,
//   }) {
//     // Check for invalid URL and return fallback directly
//     if (!_isValidImageUrl(imageUrl)) {
//       return fallbackWidget ?? _buildDefaultImagePlaceholder(width, height);
//     }

//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.grey[800],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: CachedNetworkImage(
//           imageUrl: imageUrl,
//           width: width,
//           height: height,
//           fit: fit,
//           cacheKey: cachedKey,
//           placeholder: (context, url) => Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.grey[800]!, Colors.grey[700]!],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: const Center(
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//               ),
//             ),
//           ),
//           errorWidget: (context, url, error) =>
//               fallbackWidget ?? _buildDefaultImagePlaceholder(width, height),
//           fadeInDuration: const Duration(milliseconds: 300),
//           fadeOutDuration: const Duration(milliseconds: 100),
//         ),
//       ),
//     );
//   }

//   // ✅ Added optional IconData to customize placeholder
//   Widget _buildDefaultImagePlaceholder(double width, double height, {IconData icon = Icons.broken_image}) {
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
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: Colors.grey, size: 32), // Using dynamic icon
//             const SizedBox(height: 4),
//             const Text(
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
//             _buildBackgroundLayer(),
//             _buildMainContentWithLayout(),
//             _buildTopNavigationBar(),
//             if (_isProcessing) _buildProcessingOverlay(),
//             if (_isBackgroundRefreshing) _buildBackgroundRefreshIndicator(),
//           ],
//         ),
//       ),
//     );
//   }

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
//                 color: Colors.blue.withOpacity(0.3),
//                 blurRadius: 8,
//                 spreadRadius: 2),
//           ],
//         ),
//         child: const Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//                 width: 12,
//                 height: 12,
//                 child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
//             SizedBox(width: 6),
//             Text('Updating...',
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 10,
//                     fontWeight: FontWeight.w600)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBackgroundLayer() {
//     String safeBanner = "";
//     if (_isValidImageUrl(widget.banner)) {
//        safeBanner = widget.banner;
//     }

//     return Stack(
//       children: [
//         Positioned.fill(
//           child: safeBanner.isNotEmpty
//               ? CachedNetworkImage(
//                   imageUrl: safeBanner,
//                   fit: BoxFit.cover,
//                   errorWidget: (_, __, ___) => _buildDefaultBackground(),
//                 )
//               : _buildDefaultBackground(),
//         ),
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

//   Widget _buildDefaultBackground() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f0f23)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//     );
//   }

//   Widget _buildTopNavigationBar() {
//     String uniqueImageUrl = "";
//     if (_isValidImageUrl(widget.logo)) {
//       uniqueImageUrl = "${widget.logo}?v=${widget.updatedAt}";
//     }
//     final String uniqueCacheKey = "${widget.id.toString()}_${widget.updatedAt}";

//     return Positioned(
//       top: 0, left: 0, right: 0,
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
//                 if (uniqueImageUrl.isNotEmpty)
//                   CachedNetworkImage(
//                     imageUrl: uniqueImageUrl,
//                     width: 50,
//                     height: 50,
//                     fit: BoxFit.contain,
//                     cacheKey: uniqueCacheKey,
//                     errorWidget: (_,__,___) => const SizedBox(width: 50, height: 50),
//                   ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Text(
//                     widget.name.toUpperCase(),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                       letterSpacing: 1.5,
//                     ),
//                     textAlign: TextAlign.center,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
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
//       top: 100, left: 0, right: 0, bottom: 20,
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
//     if (_isLoading && _seasons.isEmpty) return _buildLoadingWidget();
//     if (_errorMessage.isNotEmpty && _seasons.isEmpty) return _buildErrorWidget();
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(flex: 3, child: _buildSeasonsPanel()),
//           const SizedBox(width: 20),
//           Expanded(flex: 5, child: _buildEpisodesPanel()),
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
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blue.withOpacity(0.2), Colors.transparent],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//               borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(14), topRight: Radius.circular(14)),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                         color: Colors.blue.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(8)),
//                     child: const Icon(Icons.list_alt,
//                         color: Colors.blue, size: 24)),
//                 const SizedBox(width: 12),
//                 const Text("SEASONS",
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1.0)),
//                 const Spacer(),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                       color: Colors.blue.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(12)),
//                   child: Text('${_filteredSeasons.length}',
//                       style: const TextStyle(
//                           color: Colors.blue,
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold)),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(child: _buildSeasonsList()),
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
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.green.withOpacity(0.2), Colors.transparent],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//               borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(14), topRight: Radius.circular(14)),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                         color: Colors.green.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(8)),
//                     child: const Icon(Icons.play_circle_outline,
//                         color: Colors.green, size: 24)),
//                 const SizedBox(width: 12),
//                 const Text("EPISODES",
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1.0)),
//                 const Spacer(),
//                 if (_filteredSeasons.isNotEmpty &&
//                     _selectedSeasonIndex < _filteredSeasons.length)
//                   Expanded(
//                     child: Text(
//                       _filteredSeasons[_selectedSeasonIndex].sessionName,
//                       style: TextStyle(color: Colors.grey[400], fontSize: 16),
//                       textAlign: TextAlign.end,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 const SizedBox(width: 12),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                       color: Colors.green.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(12)),
//                   child: Text('${_currentEpisodes.length}',
//                       style: const TextStyle(
//                           color: Colors.green,
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold)),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//               child: _isLoadingEpisodes
//                   ? _buildLoadingWidget()
//                   : _buildEpisodesList()),
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
    
//     String uniqueImageUrl = "";
//     if (_isValidImageUrl(season.banner)) {
//       uniqueImageUrl = "${season.banner}?v=${season.updatedAt}";
//     }
//     final String uniqueCacheKey = "${season.id.toString()}_${season.updatedAt}";

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
//                     ? Border.all(
//                         color: Colors.white.withOpacity(0.3), width: 1)
//                     : null,
//             boxShadow: isFocused
//                 ? [
//                     BoxShadow(
//                         color: Colors.blue.withOpacity(0.3),
//                         blurRadius: 12,
//                         spreadRadius: 2)
//                   ]
//                 : null,
//           ),
//           child: Row(
//             children: [
//               _buildEnhancedImage(
//                 imageUrl: uniqueImageUrl,
//                 width: 50,
//                 height: 50,
//                 cachedKey: uniqueCacheKey,
//                 fit: BoxFit.cover,
//                 fallbackWidget: Container(
//                   width: 50,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: isFocused
//                           ? [Colors.blue, Colors.blue.shade300]
//                           : [Colors.grey[700]!, Colors.grey[600]!],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Center(
//                     child: Text(
//                       '${season.seasonOrder}',
//                       style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
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
//                         if (episodeCount > 0)
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 4),
//                             decoration: BoxDecoration(
//                                 color: Colors.green.withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(12)),
//                             child: Text('$episodeCount episodes',
//                                 style: const TextStyle(
//                                     color: Colors.green,
//                                     fontSize: 11,
//                                     fontWeight: FontWeight.w600)),
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               AnimatedRotation(
//                 turns: isFocused ? 0.0 : -0.25,
//                 duration: const Duration(milliseconds: 300),
//                 child: Icon(Icons.chevron_right,
//                     color: isFocused ? Colors.blue : Colors.grey[600],
//                     size: 24),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEpisodesList() {
//     final episodes = _currentEpisodes;
//     if (episodes.isEmpty) return _buildEmptyEpisodesState();
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

//     // 1. Valid Banner Check
//     String uniqueImageUrl = "";
//     if (_isValidImageUrl(episode.banner)) {
//         uniqueImageUrl = "${episode.banner}?v=${episode.updatedAt}";
//     }

//     // 2. Valid Poster Check
//     String uniquePosterImageUrl = "";
//     if (_isValidImageUrl(episode.poster)) {
//         uniquePosterImageUrl = "${episode.poster}?v=${episode.updatedAt}";
//     }
    
//     final String uniqueCacheKey = "${episode.id.toString()}_${episode.updatedAt}";
    
//     // 3. Fallback Placeholder (Now with Play Icon)
//     Widget placeholder = _buildDefaultImagePlaceholder(140, 90, icon: Icons.play_circle_outline);

//     // 4. Safe Poster Widget (checks validity before trying)
//     Widget posterWidget = uniquePosterImageUrl.isNotEmpty
//         ? _buildEnhancedImage(
//             imageUrl: uniquePosterImageUrl,
//             width: 140,
//             height: 90,
//             cachedKey: "poster_$uniqueCacheKey",
//             fallbackWidget: placeholder, // Recursive stop: if poster fails, show placeholder
//           )
//         : placeholder;

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
//                 : null,
//             color: !isFocused ? Colors.grey[900]?.withOpacity(0.4) : null,
//             borderRadius: BorderRadius.circular(16),
//             border: isFocused
//                 ? Border.all(color: Colors.green, width: 2)
//                 : Border.all(color: Colors.white.withOpacity(0.1), width: 1),
//             boxShadow: isFocused
//                 ? [
//                     BoxShadow(
//                         color: Colors.green.withOpacity(0.3),
//                         blurRadius: 12,
//                         spreadRadius: 2)
//                   ]
//                 : null,
//           ),
//           child: Row(
//             children: [
//               Container(
//                 margin: const EdgeInsets.all(12),
//                 width: 140,
//                 height: 90,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     // ✅ FIXED: Logic to try Banner -> then Poster -> then Placeholder
//                     if (uniqueImageUrl.isNotEmpty)
//                         _buildEnhancedImage(
//                           imageUrl: uniqueImageUrl,
//                           width: 140,
//                           height: 90,
//                           cachedKey: uniqueCacheKey,
//                           fallbackWidget: posterWidget, // Try poster if banner fails
//                         )
//                     else
//                         posterWidget, // Try poster directly if banner URL is invalid

//                     // Overlay logic (Processing or Focused Play Icon)
//                     if (isProcessing)
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.7),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Center(
//                           child: SpinKitRing(
//                               color: Colors.green, size: 30, lineWidth: 3),
//                         ),
//                       )
//                     else if (isFocused)
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.5),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Center(
//                           child: Icon(Icons.play_arrow,
//                               color: Colors.white, size: 48),
//                         ),
//                       )
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
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
//                       const SizedBox(height: 8),
//                       Text(
//                         'Episode ${index + 1}',
//                         style:
//                             TextStyle(color: Colors.grey[400], fontSize: 12),
//                       ),
//                     ],
//                   ),
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
//           Icon(Icons.movie_filter_outlined,
//               color: Colors.grey[700], size: 64),
//           const SizedBox(height: 20),
//           Text("No Episodes Found",
//               style: TextStyle(color: Colors.grey[400], fontSize: 18)),
//           const SizedBox(height: 8),
//           Text("This season may not have episodes yet.",
//               style: TextStyle(color: Colors.grey[600], fontSize: 14)),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SpinKitFadingCircle(color: highlightColor, size: 60.0),
//           const SizedBox(height: 20),
//           const Text('Loading...',
//               style: TextStyle(color: Colors.white, fontSize: 16)),
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
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(_errorMessage,
//                 style: TextStyle(color: Colors.grey[300], fontSize: 14),
//                 textAlign: TextAlign.center),
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
//               SpinKitPulse(color: highlightColor, size: 80),
//               const SizedBox(height: 24),
//               const Text(
//                 'Loading Video...',
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600),
//               ),
//             ],
//           ),
//         ),
//       ),
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

// =================================================================
// Enum and Models
// =================================================================
enum NavigationMode {
  seasons,
  episodes,
}

class SeasonModel {
  final int id;
  final String sessionName;
  final String updatedAt;
  final String banner;
  final int seasonOrder;
  final int webSeriesId;
  final int status;

  SeasonModel({
    required this.id,
    required this.sessionName,
    required this.updatedAt,
    required this.banner,
    required this.seasonOrder,
    required this.webSeriesId,
    required this.status,
  });

  factory SeasonModel.fromJson(Map<String, dynamic> json) {
    return SeasonModel(
      id: json['id'] ?? 0,
      sessionName: json['Session_Name'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      banner: json['banner'] ?? '',
      seasonOrder: json['season_order'] ?? 1,
      webSeriesId: json['web_series_id'] ?? 0,
      status: json['status'] ?? 1,
    );
  }
}

// =================================================================
// Main Widget
// =================================================================

class WebSeriesDetailsPage extends StatefulWidget {
  final int id;
  final String banner;
  final String poster;
  final String logo;
  final String name;
  final String updatedAt;

  const WebSeriesDetailsPage({
    Key? key,
    required this.id,
    required this.banner,
    required this.poster,
    required this.logo,
    required this.name,
    required this.updatedAt,
  }) : super(key: key);

  @override
  _WebSeriesDetailsPageState createState() => _WebSeriesDetailsPageState();
}

class _WebSeriesDetailsPageState extends State<WebSeriesDetailsPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _seasonsScrollController = ScrollController();
  final FocusNode _mainFocusNode = FocusNode();

  List<SeasonModel> _seasons = [];
  Map<int, List<NewsItemModel>> _episodesMap = {};

  int _selectedSeasonIndex = 0;
  int _selectedEpisodeIndex = 0;

  NavigationMode _currentMode = NavigationMode.seasons;

  final Map<int, FocusNode> _seasonsFocusNodes = {};
  final Map<String, FocusNode> _episodeFocusNodes = {};

  String _errorMessage = "";
  String _authKey = '';

  Timer? _instructionTimer;

  List<SeasonModel> _filteredSeasons = [];
  Map<int, List<NewsItemModel>> _filteredEpisodesMap = {};

  bool _isLoading = false;
  bool _isProcessing = false;
  bool _isLoadingEpisodes = false;

  late AnimationController _navigationModeController;
  late AnimationController _instructionController;
  late AnimationController _pageTransitionController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<SeasonModel> _filterActiveSeasons(List<SeasonModel> seasons) {
    return seasons.where((season) => season.status == 1).toList();
  }

  List<NewsItemModel> _filterActiveEpisodes(List<NewsItemModel> episodes) {
    return episodes.where((episode) {
      try {
        final status = episode.status;
        if (status == null) return false;
        if (status is int) return status == 1;
        if (status is String) return status == '1';
        return false;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    SecureUrlService.refreshSettings();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    _loadAuthKey();
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

        _seasonsFocusNodes.clear();
        for (int i = 0; i < _filteredSeasons.length; i++) {
          _seasonsFocusNodes[i] = FocusNode();
        }

        if (_filteredSeasons.isNotEmpty) {
          _pageTransitionController.forward();
          _fetchEpisodes(_filteredSeasons[0].id);

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

  Future<List<SeasonModel>?> _fetchSeasonsFromAPIDirectly() async {
    String authKey = SessionManager.authKey;
    var url = Uri.parse(SessionManager.baseUrl + 'getSeasons/${widget.id}');

    final response = await https.get(url, headers: {
      'auth-key': authKey,
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'domain': SessionManager.savedDomain,
    }).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      String responseBody = response.body.trim();
      if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
        final List<dynamic> data = jsonDecode(responseBody);
        return data.map((season) => SeasonModel.fromJson(season)).toList();
      }
    }
    throw Exception('Failed to load seasons (${response.statusCode})');
  }

  Future<void> _fetchEpisodes(int seasonId) async {
    // Check if we have data in memory map
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

  Future<void> _fetchEpisodesFromAPI(int seasonId,
      {bool showLoading = false}) async {
    if (showLoading) setState(() => _isLoadingEpisodes = true);

    try {
      final episodes = await _fetchEpisodesFromAPIDirectly(seasonId);

      if (episodes != null) {
        final activeEpisodes = _filterActiveEpisodes(episodes);

        _episodeFocusNodes.clear();
        for (var episode in activeEpisodes) {
          _episodeFocusNodes[episode.id] = FocusNode();
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

  Future<List<NewsItemModel>?> _fetchEpisodesFromAPIDirectly(
      int seasonId) async {
    String authKey = SessionManager.authKey;
    var url = Uri.parse(SessionManager.baseUrl + 'getEpisodes/$seasonId/0');

    final response = await https.get(url, headers: {
      'auth-key': authKey,
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'domain': SessionManager.savedDomain,
    }).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      String responseBody = response.body.trim();
      if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
        final List<dynamic> data = jsonDecode(responseBody);
        return data.map((e) => NewsItemModel.fromJson(e)).toList();
      }
    }
    throw Exception('Failed to load episodes for season $seasonId');
  }

  Future<void> _refreshDataOnReturn() async {
    // Refresh current season episodes to get latest progress
    if (_filteredSeasons.isNotEmpty &&
        _selectedSeasonIndex < _filteredSeasons.length) {
      final currentSeasonId = _filteredSeasons[_selectedSeasonIndex].id;
      // Clear memory cache for this season to force reload
      _filteredEpisodesMap.remove(currentSeasonId);
      await _fetchEpisodes(currentSeasonId);
    }
  }

  Future<void> _playEpisode(NewsItemModel episode) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      int? currentUserId = SessionManager.userId;
      final int? parsedContentType = int.tryParse(episode.contentType ?? '');
      final int? parsedId = int.tryParse(episode.id ?? '');

      if (currentUserId != null &&
          parsedContentType != null &&
          parsedId != null) {
        await HistoryService.updateUserHistory(
          userId: currentUserId,
          contentType: parsedContentType,
          eventId: parsedId,
          eventTitle: episode.name,
          url: episode.url,
          categoryId: 0,
        );
      }
    } catch (e) {
      print("History update failed: $e");
    }

    try {
      if (mounted) {
        String rawUrl = episode.url;
        print('rawurl: $rawUrl');
        String playableUrl = await SecureUrlService.getSecureUrl(rawUrl);
        if (episode.source == 'youtube' || isYoutubeUrl(episode.url)) {
          final deviceInfo = context.read<DeviceInfoProvider>();
          if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => YoutubeWebviewPlayer(
                  videoUrl: playableUrl,
                  name: episode.name,
                ),
              ),
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomYoutubePlayer(
                  videoData: VideoData(
                    id: playableUrl,
                    title: episode.name,
                    youtubeUrl: playableUrl,
                    thumbnail: episode.thumbnail ?? '',
                    description: episode.description,
                  ),
                  playlist: [
                    VideoData(
                      id: playableUrl,
                      title: episode.name,
                      youtubeUrl: playableUrl,
                      thumbnail: episode.thumbnail ?? '',
                      description: episode.description,
                    ),
                  ],
                ),
              ),
            );
          }
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoScreen(
                videoUrl: playableUrl,
                bannerImageUrl: episode.banner,
                channelList: [],
                videoId: int.tryParse(episode.id),
                name: episode.name,
                liveStatus: false,
                updatedAt: episode.updatedAt,
                source: 'isWebSeries',
              ),
            ),
          );
        }
        await _refreshDataOnReturn();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error playing video'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
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

  void _selectSeason(int index) {
    if (index >= 0 && index < _filteredSeasons.length) {
      setState(() => _selectedSeasonIndex = index);
      _fetchEpisodes(_filteredSeasons[index].id);
    }
  }

  void _handleSeasonsNavigation(RawKeyEvent event) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        if (_selectedSeasonIndex < _filteredSeasons.length - 1) {
          setState(() => _selectedSeasonIndex++);
          _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
        }
        break;
      case LogicalKeyboardKey.arrowUp:
        if (_selectedSeasonIndex > 0) {
          setState(() => _selectedSeasonIndex--);
          _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
        }
        break;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.select:
      case LogicalKeyboardKey.arrowRight:
        if (_filteredSeasons.isNotEmpty) _selectSeason(_selectedSeasonIndex);
        break;
    }
  }

  void _handleEpisodesNavigation(RawKeyEvent event) {
    final episodes = _currentEpisodes;
    if (episodes.isEmpty) return;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        if (_selectedEpisodeIndex < episodes.length - 1) {
          setState(() => _selectedEpisodeIndex++);
          _scrollAndFocusEpisode(_selectedEpisodeIndex);
        }
        break;
      case LogicalKeyboardKey.arrowUp:
        if (_selectedEpisodeIndex > 0) {
          setState(() => _selectedEpisodeIndex--);
          _scrollAndFocusEpisode(_selectedEpisodeIndex);
        }
        break;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.select:
        _playEpisode(episodes[_selectedEpisodeIndex]);
        break;
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.escape:
        _setNavigationMode(NavigationMode.seasons);
        break;
    }
  }

  List<NewsItemModel> get _currentEpisodes {
    if (_filteredSeasons.isEmpty ||
        _selectedSeasonIndex >= _filteredSeasons.length) {
      return [];
    }
    return _filteredEpisodesMap[_filteredSeasons[_selectedSeasonIndex].id] ??
        [];
  }

  void _setNavigationMode(NavigationMode mode) {
    setState(() => _currentMode = mode);
    if (mode == NavigationMode.seasons) {
      _navigationModeController.reverse();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
      });
    } else {
      _navigationModeController.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentEpisodes.isNotEmpty) {
          _episodeFocusNodes[_currentEpisodes[_selectedEpisodeIndex].id]
              ?.requestFocus();
        }
      });
    }
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

  Future<void> _scrollAndFocusEpisode(int index) async {
    if (index < 0 || index >= _currentEpisodes.length) return;
    final context = _episodeFocusNodes[_currentEpisodes[index].id]?.context;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    }
  }

  void _initializeAnimations() {
    _navigationModeController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _instructionController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _pageTransitionController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _pageTransitionController, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(
            begin: const Offset(0.0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _pageTransitionController, curve: Curves.easeOutCubic));
  }

  bool _isValidImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    if (url.contains('null') || url.startsWith('?')) return false;

    try {
      final uri = Uri.parse(url);
      return (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // =================================================================
  // Helper Method Updates for Placeholders
  // =================================================================
  Widget _buildEnhancedImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? fallbackWidget,
    required String cachedKey,
  }) {
    // Check for invalid URL and return fallback directly
    if (!_isValidImageUrl(imageUrl)) {
      return fallbackWidget ?? _buildDefaultImagePlaceholder(width, height);
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[800],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          cacheKey: cachedKey,
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
              fallbackWidget ?? _buildDefaultImagePlaceholder(width, height),
          fadeInDuration: const Duration(milliseconds: 300),
          fadeOutDuration: const Duration(milliseconds: 100),
        ),
      ),
    );
  }

  // Optional IconData to customize placeholder
  Widget _buildDefaultImagePlaceholder(double width, double height,
      {IconData icon = Icons.broken_image}) {
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey, size: 32), // Using dynamic icon
            const SizedBox(height: 4),
            const Text(
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
            _buildBackgroundLayer(),
            _buildMainContentWithLayout(),
            _buildTopNavigationBar(),
            if (_isProcessing) _buildProcessingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundLayer() {
    String safeBanner = "";
    if (_isValidImageUrl(widget.banner)) {
      safeBanner = widget.banner;
    }

    return Stack(
      children: [
        Positioned.fill(
          child: safeBanner.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: safeBanner,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _buildDefaultBackground(),
                )
              : _buildDefaultBackground(),
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

  Widget _buildDefaultBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f0f23)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildTopNavigationBar() {
    String uniqueImageUrl = "";
    if (_isValidImageUrl(widget.logo)) {
      uniqueImageUrl = "${widget.logo}?v=${widget.updatedAt}";
    }
    final String uniqueCacheKey =
        "${widget.id.toString()}_${widget.updatedAt}";

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
                if (uniqueImageUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: uniqueImageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                    cacheKey: uniqueCacheKey,
                    errorWidget: (_, __, ___) =>
                        const SizedBox(width: 50, height: 50),
                  ),
                const SizedBox(width: 16),
                Expanded(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContentWithLayout() {
    return Positioned(
      top: 100,
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
    if (_isLoading && _seasons.isEmpty) return _buildLoadingWidget();
    if (_errorMessage.isNotEmpty && _seasons.isEmpty)
      return _buildErrorWidget();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _buildSeasonsPanel()),
          const SizedBox(width: 20),
          Expanded(flex: 5, child: _buildEpisodesPanel()),
        ],
      ),
    );
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.withOpacity(0.2), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.list_alt,
                        color: Colors.blue, size: 24)),
                const SizedBox(width: 12),
                const Text("SEASONS",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text('${_filteredSeasons.length}',
                      style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(child: _buildSeasonsList()),
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.withOpacity(0.2), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.play_circle_outline,
                        color: Colors.green, size: 24)),
                const SizedBox(width: 12),
                const Text("EPISODES",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0)),
                const Spacer(),
                if (_filteredSeasons.isNotEmpty &&
                    _selectedSeasonIndex < _filteredSeasons.length)
                  Expanded(
                    child: Text(
                      _filteredSeasons[_selectedSeasonIndex].sessionName,
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text('${_currentEpisodes.length}',
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
              child: _isLoadingEpisodes
                  ? _buildLoadingWidget()
                  : _buildEpisodesList()),
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

    String uniqueImageUrl = "";
    if (_isValidImageUrl(season.banner)) {
      uniqueImageUrl = "${season.banner}?v=${season.updatedAt}";
    }
    final String uniqueCacheKey =
        "${season.id.toString()}_${season.updatedAt}";

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
                    ? Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1)
                    : null,
            boxShadow: isFocused
                ? [
                    BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2)
                  ]
                : null,
          ),
          child: Row(
            children: [
              _buildEnhancedImage(
                imageUrl: uniqueImageUrl,
                width: 50,
                height: 50,
                cachedKey: uniqueCacheKey,
                fit: BoxFit.cover,
                fallbackWidget: Container(
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${season.seasonOrder}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      season.sessionName,
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
                        if (episodeCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12)),
                            child: Text('$episodeCount episodes',
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: isFocused ? 0.0 : -0.25,
                duration: const Duration(milliseconds: 300),
                child: Icon(Icons.chevron_right,
                    color: isFocused ? Colors.blue : Colors.grey[600],
                    size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodesList() {
    final episodes = _currentEpisodes;
    if (episodes.isEmpty) return _buildEmptyEpisodesState();
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: episodes.length,
      itemBuilder: (context, index) => _buildEpisodeItem(index),
    );
  }

  void _onEpisodeTap(int index) {
    if (_currentEpisodes.isNotEmpty && index < _currentEpisodes.length) {
      setState(() {
        _selectedEpisodeIndex = index;
        _currentMode = NavigationMode.episodes;
      });
      _episodeFocusNodes[_currentEpisodes[index].id]?.requestFocus();
      _playEpisode(_currentEpisodes[index]);
    }
  }

  Widget _buildEpisodeItem(int index) {
    final episode = _currentEpisodes[index];
    final isSelected = index == _selectedEpisodeIndex;
    final isFocused = _currentMode == NavigationMode.episodes && isSelected;
    final isProcessing = _isProcessing && isSelected;

    // 1. Valid Banner Check
    String uniqueImageUrl = "";
    if (_isValidImageUrl(episode.banner)) {
      uniqueImageUrl = "${episode.banner}?v=${episode.updatedAt}";
    }

    // 2. Valid Poster Check
    String uniquePosterImageUrl = "";
    if (_isValidImageUrl(episode.poster)) {
      uniquePosterImageUrl = "${episode.poster}?v=${episode.updatedAt}";
    }

    final String uniqueCacheKey =
        "${episode.id.toString()}_${episode.updatedAt}";

    // 3. Fallback Placeholder (Now with Play Icon)
    Widget placeholder =
        _buildDefaultImagePlaceholder(140, 90, icon: Icons.play_circle_outline);

    // 4. Safe Poster Widget (checks validity before trying)
    Widget posterWidget = uniquePosterImageUrl.isNotEmpty
        ? _buildEnhancedImage(
            imageUrl: uniquePosterImageUrl,
            width: 140,
            height: 90,
            cachedKey: "poster_$uniqueCacheKey",
            fallbackWidget:
                placeholder, // Recursive stop: if poster fails, show placeholder
          )
        : placeholder;

    return GestureDetector(
      onTap: () => _onEpisodeTap(index),
      child: Focus(
        focusNode: _episodeFocusNodes[episode.id],
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
                : null,
            color: !isFocused ? Colors.grey[900]?.withOpacity(0.4) : null,
            borderRadius: BorderRadius.circular(16),
            border: isFocused
                ? Border.all(color: Colors.green, width: 2)
                : Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2)
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.all(12),
                width: 140,
                height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Logic to try Banner -> then Poster -> then Placeholder
                    if (uniqueImageUrl.isNotEmpty)
                      _buildEnhancedImage(
                        imageUrl: uniqueImageUrl,
                        width: 140,
                        height: 90,
                        cachedKey: uniqueCacheKey,
                        fallbackWidget:
                            posterWidget, // Try poster if banner fails
                      )
                    else
                      posterWidget, // Try poster directly if banner URL is invalid

                    // Overlay logic (Processing or Focused Play Icon)
                    if (isProcessing)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: SpinKitRing(
                              color: Colors.green, size: 30, lineWidth: 3),
                        ),
                      )
                    else if (isFocused)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(Icons.play_arrow,
                              color: Colors.white, size: 48),
                        ),
                      )
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
                        episode.name,
                        style: TextStyle(
                          color: isFocused ? Colors.green : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Episode ${index + 1}',
                        style:
                            TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
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
          Icon(Icons.movie_filter_outlined,
              color: Colors.grey[700], size: 64),
          const SizedBox(height: 20),
          Text("No Episodes Found",
              style: TextStyle(color: Colors.grey[400], fontSize: 18)),
          const SizedBox(height: 8),
          Text("This season may not have episodes yet.",
              style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(color: highlightColor, size: 60.0),
          const SizedBox(height: 20),
          const Text('Loading...',
              style: TextStyle(color: Colors.white, fontSize: 16)),
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
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_errorMessage,
                style: TextStyle(color: Colors.grey[300], fontSize: 14),
                textAlign: TextAlign.center),
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
              SpinKitPulse(color: highlightColor, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Loading Video...',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}