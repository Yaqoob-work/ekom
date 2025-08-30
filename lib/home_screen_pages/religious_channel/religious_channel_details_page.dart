// import 'dart:async';
// import 'dart:convert';
// import 'package:mobi_tv_entertainment/video_widget/custom_video_player.dart';
// import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as https;
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player.dart';
// import 'package:mobi_tv_entertainment/video_widget/youtube_webview_player.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../video_widget/socket_service.dart';

// // Define highlightColor constant
// const Color highlightColor =
//     Color(0xFF4FC3F7); // Light blue color for highlights

// enum NavigationMode {
//   shows,
//   episodes,
// }

// // Religious Show Model
// class ReligiousShowModel {
//   final int id;
//   final int channelId;
//   final String title;
//   final String genre;
//   final String description;
//   final String thumbnail;
//   final int status;
//   final int relOrder;

//   ReligiousShowModel({
//     required this.id,
//     required this.channelId,
//     required this.title,
//     required this.genre,
//     required this.description,
//     required this.thumbnail,
//     required this.status,
//     required this.relOrder,
//   });

//   factory ReligiousShowModel.fromJson(Map<String, dynamic> json) {
//     return ReligiousShowModel(
//       id: json['id'] ?? 0,
//       channelId: json['channel_id'] ?? 0,
//       title: json['title'] ?? '',
//       genre: json['genre'] ?? '',
//       description: json['description'] ?? '',
//       thumbnail: json['thumbnail'] ?? '',
//       status: json['status'] ?? 1,
//       relOrder: json['rel_order'] ?? 1,
//     );
//   }
// }

// // Religious Episode Model
// class ReligiousEpisodeModel {
//   final int id;
//   final int showId;
//   final int episodeOrder;
//   final String title;
//   final String episodeImage;
//   final String episodeDescription;
//   final String source;
//   final String url;
//   final int status;

//   ReligiousEpisodeModel({
//     required this.id,
//     required this.showId,
//     required this.episodeOrder,
//     required this.title,
//     required this.episodeImage,
//     required this.episodeDescription,
//     required this.source,
//     required this.url,
//     required this.status,
//   });

//   factory ReligiousEpisodeModel.fromJson(Map<String, dynamic> json) {
//     return ReligiousEpisodeModel(
//       id: json['id'] ?? 0,
//       showId: json['show_id'] ?? 0,
//       episodeOrder: json['episode_order'] ?? 1,
//       title: json['title'] ?? '',
//       episodeImage: json['episode_image'] ?? '',
//       episodeDescription: json['episode_description'] ?? '',
//       source: json['source'] ?? '',
//       url: json['url'] ?? '',
//       status: json['status'] ?? 1,
//     );
//   }
// }

// // Cache Manager Class for Religious Shows Data
// class ReligiousShowsCacheManager {
//   static const String _cacheKeyPrefix = 'religious_shows_cache_';
//   static const String _episodesCacheKeyPrefix = 'religious_episodes_cache_';
//   static const String _lastUpdatedKeyPrefix = 'last_updated_';
//   static const Duration _cacheValidDuration = Duration(hours: 6);

//   // Save shows data to cache
//   static Future<void> saveShowsCache(
//       int channelId, List<ReligiousShowModel> shows) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cacheKey = '$_cacheKeyPrefix$channelId';
//       final lastUpdatedKey = '$_lastUpdatedKeyPrefix$channelId';

//       final showsJson = shows
//           .map((show) => {
//                 'id': show.id,
//                 'channel_id': show.channelId,
//                 'title': show.title,
//                 'genre': show.genre,
//                 'description': show.description,
//                 'thumbnail': show.thumbnail,
//                 'status': show.status,
//                 'rel_order': show.relOrder,
//               })
//           .toList();

//       await prefs.setString(cacheKey, jsonEncode(showsJson));
//       await prefs.setInt(lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);

//       print('✅ Religious shows cache saved for channel $channelId');
//     } catch (e) {
//       print('❌ Error saving religious shows cache: $e');
//     }
//   }

//   // Get shows data from cache
//   static Future<List<ReligiousShowModel>?> getShowsCache(int channelId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cacheKey = '$_cacheKeyPrefix$channelId';
//       final lastUpdatedKey = '$_lastUpdatedKeyPrefix$channelId';

//       final cachedData = prefs.getString(cacheKey);
//       final lastUpdated = prefs.getInt(lastUpdatedKey);

//       if (cachedData == null || lastUpdated == null) {
//         return null;
//       }

//       // Check if cache is still valid
//       final cacheAge = DateTime.now().millisecondsSinceEpoch - lastUpdated;
//       final isExpired = cacheAge > _cacheValidDuration.inMilliseconds;

//       if (isExpired) {
//         print('⏰ Religious shows cache expired for channel $channelId');
//         return null;
//       }

//       final List<dynamic> showsJson = jsonDecode(cachedData);
//       final shows =
//           showsJson.map((json) => ReligiousShowModel.fromJson(json)).toList();

//       print(
//           '✅ Religious shows cache loaded for channel $channelId (${shows.length} shows)');
//       return shows;
//     } catch (e) {
//       print('❌ Error loading religious shows cache: $e');
//       return null;
//     }
//   }

//   // Save episodes data to cache
//   static Future<void> saveEpisodesCache(
//       int showId, List<ReligiousEpisodeModel> episodes) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cacheKey = '$_episodesCacheKeyPrefix$showId';
//       final lastUpdatedKey = '${_lastUpdatedKeyPrefix}episodes_$showId';

//       final episodesJson = episodes
//           .map((episode) => {
//                 'id': episode.id,
//                 'show_id': episode.showId,
//                 'episode_order': episode.episodeOrder,
//                 'title': episode.title,
//                 'episode_image': episode.episodeImage,
//                 'episode_description': episode.episodeDescription,
//                 'source': episode.source,
//                 'url': episode.url,
//                 'status': episode.status,
//               })
//           .toList();

//       await prefs.setString(cacheKey, jsonEncode(episodesJson));
//       await prefs.setInt(lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);

//       print('✅ Religious episodes cache saved for show $showId');
//     } catch (e) {
//       print('❌ Error saving religious episodes cache: $e');
//     }
//   }

//   // Get episodes data from cache
//   static Future<List<ReligiousEpisodeModel>?> getEpisodesCache(
//       int showId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cacheKey = '$_episodesCacheKeyPrefix$showId';
//       final lastUpdatedKey = '${_lastUpdatedKeyPrefix}episodes_$showId';

//       final cachedData = prefs.getString(cacheKey);
//       final lastUpdated = prefs.getInt(lastUpdatedKey);

//       if (cachedData == null || lastUpdated == null) {
//         return null;
//       }

//       // Check if cache is still valid
//       final cacheAge = DateTime.now().millisecondsSinceEpoch - lastUpdated;
//       final isExpired = cacheAge > _cacheValidDuration.inMilliseconds;

//       if (isExpired) {
//         print('⏰ Religious episodes cache expired for show $showId');
//         return null;
//       }

//       final List<dynamic> episodesJson = jsonDecode(cachedData);
//       final episodes = episodesJson
//           .map((json) => ReligiousEpisodeModel.fromJson(json))
//           .toList();

//       print(
//           '✅ Religious episodes cache loaded for show $showId (${episodes.length} episodes)');
//       return episodes;
//     } catch (e) {
//       print('❌ Error loading religious episodes cache: $e');
//       return null;
//     }
//   }

//   // Compare two show lists and check if they're different
//   static bool areShowsDifferent(
//       List<ReligiousShowModel> cached, List<ReligiousShowModel> fresh) {
//     if (cached.length != fresh.length) return true;

//     for (int i = 0; i < cached.length; i++) {
//       final c = cached[i];
//       final f = fresh[i];

//       if (c.id != f.id ||
//           c.title != f.title ||
//           c.status != f.status ||
//           c.thumbnail != f.thumbnail) {
//         return true;
//       }
//     }
//     return false;
//   }

//   // Compare two episode lists and check if they're different
//   static bool areEpisodesDifferent(
//       List<ReligiousEpisodeModel> cached, List<ReligiousEpisodeModel> fresh) {
//     if (cached.length != fresh.length) return true;

//     for (int i = 0; i < cached.length; i++) {
//       final c = cached[i];
//       final f = fresh[i];

//       if (c.id != f.id ||
//           c.title != f.title ||
//           c.status != f.status ||
//           c.url != f.url) {
//         return true;
//       }
//     }
//     return false;
//   }

//   // Clear all cache for a specific channel
//   static Future<void> clearChannelCache(int channelId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('$_cacheKeyPrefix$channelId');
//       await prefs.remove('$_lastUpdatedKeyPrefix$channelId');
//       print('🗑️ Cleared religious shows cache for channel $channelId');
//     } catch (e) {
//       print('❌ Error clearing religious shows cache: $e');
//     }
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
//   _ReligiousChannelDetailsPageState createState() =>
//       _ReligiousChannelDetailsPageState();
// }

// class _ReligiousChannelDetailsPageState
//     extends State<ReligiousChannelDetailsPage>
//     with WidgetsBindingObserver, TickerProviderStateMixin {
//   final SocketService _socketService = SocketService();
//   final ScrollController _scrollController = ScrollController();
//   final ScrollController _showsScrollController = ScrollController();
//   final FocusNode _mainFocusNode = FocusNode();

//   // Data structures
//   List<ReligiousShowModel> _shows = [];
//   Map<int, List<ReligiousEpisodeModel>> _episodesMap = {};

//   int _selectedShowIndex = 0;
//   int _selectedEpisodeIndex = 0;

//   NavigationMode _currentMode = NavigationMode.shows;

//   final Map<int, FocusNode> _showsFocusNodes = {};
//   final Map<String, FocusNode> _episodeFocusNodes = {};

//   String _errorMessage = "";
//   String _authKey = '';

//   // Filtered data variables for active content
//   List<ReligiousShowModel> _filteredShows = [];
//   Map<int, List<ReligiousEpisodeModel>> _filteredEpisodesMap = {};

//   // Loading states
//   bool _isLoading = false;
//   bool _isProcessing = false;
//   bool _isLoadingEpisodes = false;
//   bool _isBackgroundRefreshing = false;

//   // Animation Controllers
//   late AnimationController _navigationModeController;
//   late AnimationController _pageTransitionController;

//   // Animations
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   // Filter methods for active content
//   List<ReligiousShowModel> _filterActiveShows(List<ReligiousShowModel> shows) {
//     return shows.where((show) => show.status == 1).toList();
//   }

//   List<ReligiousEpisodeModel> _filterActiveEpisodes(
//       List<ReligiousEpisodeModel> episodes) {
//     return episodes.where((episode) => episode.status == 1).toList();
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _socketService.initSocket();

//     _initializeAnimations();
//     _loadAuthKey();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _scrollController.dispose();
//     _showsScrollController.dispose();
//     _mainFocusNode.dispose();
//     _showsFocusNodes.values.forEach((node) => node.dispose());
//     _episodeFocusNodes.values.forEach((node) => node.dispose());
//     _socketService.dispose();
//     _navigationModeController.dispose();
//     _pageTransitionController.dispose();
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
//     print(
//         '🚀 Initializing religious shows page with cache for channel ${widget.id}');

//     // Try to load from cache first
//     final cachedShows =
//         await ReligiousShowsCacheManager.getShowsCache(widget.id);

//     if (cachedShows != null && cachedShows.isNotEmpty) {
//       // Show cached data immediately
//       print('⚡ Loading religious shows from cache instantly');
//       await _loadShowsFromCache(cachedShows);

//       // Start background refresh
//       _performBackgroundRefresh();
//     } else {
//       // No cache available, load from API with loading indicator
//       print('📡 No religious shows cache available, loading from API');
//       await _fetchShowsFromAPI(showLoading: true);
//     }
//   }

//   // Load shows from cache and update UI instantly
//   Future<void> _loadShowsFromCache(List<ReligiousShowModel> cachedShows) async {
//     final activeShows = _filterActiveShows(cachedShows);

//     setState(() {
//       _shows = cachedShows;
//       _filteredShows = activeShows;
//       _isLoading = false;
//       _errorMessage = "";
//     });

//     // Create focus nodes for active shows
//     _showsFocusNodes.clear();
//     for (int i = 0; i < _filteredShows.length; i++) {
//       _showsFocusNodes[i] = FocusNode();
//     }

//     if (_filteredShows.isNotEmpty) {
//       _pageTransitionController.forward();

//       // <<< MODIFICATION START: Pehle show ke episodes turant fetch karein
//       // Hum `await` nahi laga rahe hain taaki UI build hota rahe
//       // aur episodes background mein load ho jaayein.
//       _fetchEpisodes(_filteredShows[0].id);
//       // <<< MODIFICATION END

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           // Focus ab episodes load hone par set hoga.
//           // Isliye neeche di gayi line ko comment ya remove kar dein.
//           // _showsFocusNodes[0]?.requestFocus();
//         }
//       });
//     }
//   }

//   // Perform background refresh without showing loading indicators
//   Future<void> _performBackgroundRefresh() async {
//     print('🔄 Starting religious shows background refresh');
//     setState(() {
//       _isBackgroundRefreshing = true;
//     });

//     try {
//       final freshShows = await _fetchShowsFromAPIDirectly();

//       if (freshShows != null) {
//         // Compare with cached data
//         final cachedShows = _shows;
//         final hasChanges = ReligiousShowsCacheManager.areShowsDifferent(
//             cachedShows, freshShows);

//         if (hasChanges) {
//           print('🔄 Religious shows changes detected, updating UI silently');

//           // Save new data to cache
//           await ReligiousShowsCacheManager.saveShowsCache(
//               widget.id, freshShows);

//           // Update UI without disrupting user experience
//           await _updateShowsData(freshShows);
//         } else {
//           print('✅ No religious shows changes detected in background refresh');
//         }
//       }
//     } catch (e) {
//       print('❌ Religious shows background refresh failed: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isBackgroundRefreshing = false;
//         });
//       }
//     }
//   }

//   // Update shows data while preserving user's current selection
//   Future<void> _updateShowsData(List<ReligiousShowModel> newShows) async {
//     final activeShows = _filterActiveShows(newShows);
//     final currentSelectedShowId =
//         _filteredShows.isNotEmpty && _selectedShowIndex < _filteredShows.length
//             ? _filteredShows[_selectedShowIndex].id
//             : null;

//     setState(() {
//       _shows = newShows;
//       _filteredShows = activeShows;
//     });

//     // Try to maintain user's current selection
//     if (currentSelectedShowId != null) {
//       final newIndex =
//           _filteredShows.indexWhere((s) => s.id == currentSelectedShowId);
//       if (newIndex >= 0) {
//         setState(() {
//           _selectedShowIndex = newIndex;
//         });
//       }
//     }

//     // Recreate focus nodes if needed
//     _showsFocusNodes.clear();
//     for (int i = 0; i < _filteredShows.length; i++) {
//       _showsFocusNodes[i] = FocusNode();
//     }
//   }

//   // Fetch shows from API with loading indicator
//   Future<void> _fetchShowsFromAPI({bool showLoading = false}) async {
//     if (showLoading) {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = "Loading shows...";
//       });
//     }

//     try {
//       final shows = await _fetchShowsFromAPIDirectly();

//       if (shows != null) {
//         // Save to cache
//         await ReligiousShowsCacheManager.saveShowsCache(widget.id, shows);

//         // Update UI
//         await _loadShowsFromCache(shows);
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = "Error: ${e.toString()}";
//       });
//     }
//   }

//   // Direct API call for shows
//   Future<List<ReligiousShowModel>?> _fetchShowsFromAPIDirectly() async {
//     final prefs = await SharedPreferences.getInstance();
//     final authKey = prefs.getString('auth_key') ?? _authKey;

//     final response = await https.get(
//       Uri.parse(
//           'https://acomtv.coretechinfo.com/public/api/getReligiousShows/${widget.id}'),
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
//         return data.map((show) => ReligiousShowModel.fromJson(show)).toList();
//       }
//     }

//     throw Exception('Failed to load religious shows (${response.statusCode})');
//   }

//   // Enhanced episodes fetching with cache
//   Future<void> _fetchEpisodes(int showId) async {
//     // Check if already loaded
//     if (_filteredEpisodesMap.containsKey(showId)) {
//       setState(() {
//         _selectedShowIndex =
//             _filteredShows.indexWhere((show) => show.id == showId);
//         _selectedEpisodeIndex = 0;
//       });
//       _setNavigationMode(NavigationMode.episodes);
//       return;
//     }

//     // Try cache first
//     final cachedEpisodes =
//         await ReligiousShowsCacheManager.getEpisodesCache(showId);

//     if (cachedEpisodes != null) {
//       // Load from cache instantly
//       await _loadEpisodesFromCache(showId, cachedEpisodes);
//     } else {
//       // Load from API with loading indicator
//       await _fetchEpisodesFromAPI(showId, showLoading: true);
//     }
//   }

//   // Load episodes from cache
//   Future<void> _loadEpisodesFromCache(
//       int showId, List<ReligiousEpisodeModel> cachedEpisodes) async {
//     final activeEpisodes = _filterActiveEpisodes(cachedEpisodes);

//     _episodeFocusNodes.clear();
//     for (var episode in activeEpisodes) {
//       _episodeFocusNodes[episode.id.toString()] = FocusNode();
//     }

//     setState(() {
//       _episodesMap[showId] = cachedEpisodes;
//       _filteredEpisodesMap[showId] = activeEpisodes;
//       _selectedShowIndex = _filteredShows.indexWhere((s) => s.id == showId);
//       _selectedEpisodeIndex = 0;
//       _isLoadingEpisodes = false;
//     });

//     _setNavigationMode(NavigationMode.episodes);
//   }

//   // Fetch episodes from API with loading indicator
//   Future<void> _fetchEpisodesFromAPI(int showId,
//       {bool showLoading = false}) async {
//     if (showLoading) {
//       setState(() {
//         _isLoadingEpisodes = true;
//       });
//     }

//     try {
//       final episodes = await _fetchEpisodesFromAPIDirectly(showId);

//       if (episodes != null) {
//         // Save to cache
//         await ReligiousShowsCacheManager.saveEpisodesCache(showId, episodes);

//         // Update UI
//         await _loadEpisodesFromCache(showId, episodes);
//       }
//     } catch (e) {
//       setState(() {
//         _isLoadingEpisodes = false;
//         _errorMessage = "Error loading episodes: ${e.toString()}";
//       });
//     }
//   }

//   // Direct API call for episodes
//   Future<List<ReligiousEpisodeModel>?> _fetchEpisodesFromAPIDirectly(
//       int showId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final authKey = prefs.getString('auth_key') ?? _authKey;

//     final response = await https.get(
//       Uri.parse(
//           'https://acomtv.coretechinfo.com/public/api/getReligiousShowsEpisodes/$showId'),
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
//         return data.map((e) => ReligiousEpisodeModel.fromJson(e)).toList();
//       }
//     }

//     throw Exception('Failed to load episodes for show $showId');
//   }

//   Future<void> _playEpisode(ReligiousEpisodeModel episode) async {
//     if (_isProcessing) return;

//     setState(() => _isProcessing = true);

//     try {
//       if (mounted) {
//         if (episode.source.toLowerCase() == 'youtube'
//             // || isYoutubeUrl(episode.url)
//             ) {
//           await Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => YoutubeWebviewPlayer(
//                         videoUrl: episode.url,
//                         name: episode.title,
//                       )));
//         } else {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => CustomYoutubePlayer(
//                 videoData: VideoData(
//                   id: episode.url,
//                   title: episode.title,
//                   youtubeUrl: episode.url,
//                   thumbnail: episode.episodeImage,
//                   description: episode.episodeDescription,
//                 ),
//                 playlist: [
//                   VideoData(
//                     id: episode.url,
//                     title: episode.title,
//                     youtubeUrl: episode.url,
//                     thumbnail: episode.episodeImage,
//                     description: episode.episodeDescription,
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
//             builder: (context) => CustomVideoPlayer(
//               videoUrl: episode.url,
//             ),
//           ),
//         );
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

//   void _selectShow(int index) {
//     if (index >= 0 && index < _filteredShows.length) {
//       setState(() {
//         _selectedShowIndex = index;
//       });
//       _fetchEpisodes(_filteredShows[index].id);
//     }
//   }

//   void _handleShowsNavigation(RawKeyEvent event) {
//     switch (event.logicalKey) {
//       case LogicalKeyboardKey.arrowDown:
//         if (_selectedShowIndex < _filteredShows.length - 1) {
//           setState(() {
//             _selectedShowIndex++;
//           });
//           _showsFocusNodes[_selectedShowIndex]?.requestFocus();
//         }
//         break;

//       case LogicalKeyboardKey.arrowUp:
//         if (_selectedShowIndex > 0) {
//           setState(() {
//             _selectedShowIndex--;
//           });
//           _showsFocusNodes[_selectedShowIndex]?.requestFocus();
//         }
//         break;

//       case LogicalKeyboardKey.enter:
//       case LogicalKeyboardKey.select:
//       case LogicalKeyboardKey.arrowRight:
//         if (_filteredShows.isNotEmpty) {
//           _selectShow(_selectedShowIndex);
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
//         _setNavigationMode(NavigationMode.shows);
//         break;
//     }
//   }

//   List<ReligiousEpisodeModel> get _currentEpisodes {
//     if (_filteredShows.isEmpty || _selectedShowIndex >= _filteredShows.length) {
//       return [];
//     }
//     return _filteredEpisodesMap[_filteredShows[_selectedShowIndex].id] ?? [];
//   }

//   void _setNavigationMode(NavigationMode mode) {
//     setState(() {
//       _currentMode = mode;
//     });

//     if (mode == NavigationMode.shows) {
//       _navigationModeController.reverse();
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_selectedShowIndex < _showsFocusNodes.length) {
//           _showsFocusNodes[_selectedShowIndex]?.requestFocus();
//         }
//       });
//     } else {
//       _navigationModeController.forward();
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_currentEpisodes.isNotEmpty &&
//             _selectedEpisodeIndex < _currentEpisodes.length) {
//           _episodeFocusNodes[
//                   _currentEpisodes[_selectedEpisodeIndex].id.toString()]
//               ?.requestFocus();
//         }
//       });
//     }
//   }

//   void _handleKeyEvent(RawKeyEvent event) {
//     if (_isProcessing) return;

//     if (event is RawKeyDownEvent) {
//       switch (_currentMode) {
//         case NavigationMode.shows:
//           _handleShowsNavigation(event);
//           break;
//         case NavigationMode.episodes:
//           _handleEpisodesNavigation(event);
//           break;
//       }
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

//   void _initializeAnimations() {
//     _navigationModeController = AnimationController(
//       duration: const Duration(milliseconds: 400),
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

//             // Processing Overlay
//             if (_isProcessing) _buildProcessingOverlay(),

//             // Background refresh indicator (subtle)
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
//           child: _isValidImageUrl(widget.banner)
//               ? CachedNetworkImage(
//                   imageUrl: widget.banner,
//                   fit: BoxFit.cover,
//                   placeholder: (context, url) => Container(
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Color(0xFF1a1a2e),
//                           Color(0xFF16213e),
//                           Color(0xFF0f0f23),
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                     ),
//                   ),
//                   errorWidget: (context, url, error) => Container(
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Color(0xFF1a1a2e),
//                           Color(0xFF16213e),
//                           Color(0xFF0f0f23),
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                     ),
//                   ),
//                 )
//               : Container(
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Color(0xFF1a1a2e),
//                         Color(0xFF16213e),
//                         Color(0xFF0f0f23),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                   ),
//                 ),
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
//                 // Channel Title
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
//     if (_isLoading && _shows.isEmpty) {
//       return _buildLoadingWidget();
//     }

//     if (_errorMessage.isNotEmpty && _shows.isEmpty) {
//       return _buildErrorWidget();
//     }

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Left Panel - Shows
//           Expanded(
//             flex: 2,
//             child: _buildShowsPanel(),
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

//   Widget _buildShowsPanel() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: _currentMode == NavigationMode.shows
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
//                   "SHOWS",
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
//                     '${_filteredShows.length}',
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
//           // Shows List
//           Expanded(
//             child: _buildShowsList(),
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
//                       "EPISODES",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1.0,
//                       ),
//                     ),
//                     if (_filteredShows.isNotEmpty &&
//                         _selectedShowIndex < _filteredShows.length)
//                       Text(
//                         _filteredShows[_selectedShowIndex].title,
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

//   Widget _buildShowsList() {
//     return ListView.builder(
//       controller: _showsScrollController,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       itemCount: _filteredShows.length,
//       itemBuilder: (context, index) => _buildShowItem(index),
//     );
//   }

//   void _onShowTap(int index) {
//     setState(() {
//       _selectedShowIndex = index;
//       _currentMode = NavigationMode.shows;
//     });
//     _showsFocusNodes[index]?.requestFocus();
//     _selectShow(index);
//   }

//   Widget _buildShowItem(int index) {
//     final show = _filteredShows[index];
//     final isFocused =
//         _currentMode == NavigationMode.shows && index == _selectedShowIndex;

//     return GestureDetector(
//       onTap: () => _onShowTap(index),
//       child: Focus(
//         focusNode: _showsFocusNodes[index],
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
//                 : null,
//             color: !isFocused ? Colors.grey[900]?.withOpacity(0.4) : null,
//             borderRadius: BorderRadius.circular(12),
//             border: isFocused ? Border.all(color: Colors.blue, width: 2) : null,
//           ),
//           child: Row(
//             children: [
//               // Show thumbnail
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(25),
//                   color: Colors.grey[700],
//                 ),
//                 child: _isValidImageUrl(show.thumbnail)
//                     ? ClipRRect(
//                         borderRadius: BorderRadius.circular(25),
//                         child: CachedNetworkImage(
//                           imageUrl: show.thumbnail,
//                           fit: BoxFit.cover,
//                           errorWidget: (context, url, error) => Center(
//                             child: Text(
//                               '${show.relOrder}',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       )
//                     : Center(
//                         child: Text(
//                           '${show.relOrder}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//               ),
//               const SizedBox(width: 16),
//               // Show info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       show.title,
//                       style: TextStyle(
//                         color: isFocused ? Colors.blue : Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       show.genre.isNotEmpty ? show.genre : 'Religious',
//                       style: TextStyle(
//                         color: Colors.grey[400],
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.chevron_right,
//                 color: isFocused ? Colors.blue : Colors.grey[600],
//                 size: 24,
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
//       _episodeFocusNodes[_currentEpisodes[index].id.toString()]?.requestFocus();
//       _playEpisode(_currentEpisodes[index]);
//     }
//   }

//   Widget _buildEpisodeItem(int index) {
//     final episodes = _currentEpisodes;
//     if (index >= episodes.length) return Container();

//     final episode = episodes[index];
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
//               // Enhanced Thumbnail
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
//                               "EP ${episode.episodeOrder}",
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

//                     // Try to load episode image
//                     if (_isValidImageUrl(episode.episodeImage))
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: CachedNetworkImage(
//                           imageUrl: episode.episodeImage,
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
//                             // Fallback to show thumbnail
//                             if (_filteredShows.isNotEmpty &&
//                                 _selectedShowIndex < _filteredShows.length &&
//                                 _isValidImageUrl(
//                                     _filteredShows[_selectedShowIndex]
//                                         .thumbnail)) {
//                               return CachedNetworkImage(
//                                 imageUrl: _filteredShows[_selectedShowIndex]
//                                     .thumbnail,
//                                 width: 140,
//                                 height: 90,
//                                 fit: BoxFit.cover,
//                                 errorWidget: (context, url, error) {
//                                   // Fallback to channel banner
//                                   if (_isValidImageUrl(widget.banner)) {
//                                     return CachedNetworkImage(
//                                       imageUrl: widget.banner,
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
//                       ),

//                     // Play/Loading overlay
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
//                         episode.title,
//                         style: TextStyle(
//                           color: isFocused ? Colors.green : Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),

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
//                               'Episode ${episode.episodeOrder}',
//                               style: TextStyle(
//                                 color:
//                                     isFocused ? Colors.green : Colors.grey[300],
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Action Button Area
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Container(
//                   width: 56,
//                   height: 56,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: isFocused
//                           ? [Colors.green, Colors.green.shade400]
//                           : [Colors.grey[700]!, Colors.grey[600]!],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(28),
//                     boxShadow: isFocused
//                         ? [
//                             BoxShadow(
//                               color: Colors.green.withOpacity(0.5),
//                               blurRadius: 12,
//                               spreadRadius: 3,
//                             )
//                           ]
//                         : null,
//                   ),
//                   child: isProcessing
//                       ? const SpinKitRing(
//                           color: Colors.white,
//                           size: 24,
//                           lineWidth: 2,
//                         )
//                       : const Icon(
//                           Icons.play_arrow,
//                           color: Colors.white,
//                           size: 32,
//                         ),
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
//             Icons.video_library_outlined,
//             color: Colors.grey[500],
//             size: 64,
//           ),
//           const SizedBox(height: 20),
//           Text(
//             "Press Enter To Load Episodes",
//             style: TextStyle(
//               color: Colors.grey[400],
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
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
import 'package:mobi_tv_entertainment/provider/device_info_provider.dart';
import 'package:mobi_tv_entertainment/video_widget/custom_video_player.dart';
import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player.dart';
import 'package:mobi_tv_entertainment/video_widget/youtube_webview_player.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../video_widget/socket_service.dart';

// Define highlightColor constant
const Color highlightColor =
    Color(0xFF4FC3F7); // Light blue color for highlights

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
  static Future<List<ReligiousEpisodeModel>?> getEpisodesCache(
      int showId) async {
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
      final episodes = episodesJson
          .map((json) => ReligiousEpisodeModel.fromJson(json))
          .toList();

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
  _ReligiousChannelDetailsPageState createState() =>
      _ReligiousChannelDetailsPageState();
}

class _ReligiousChannelDetailsPageState
    extends State<ReligiousChannelDetailsPage>
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
  late AnimationController _pageTransitionController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Filter methods for active content
  List<ReligiousShowModel> _filterActiveShows(List<ReligiousShowModel> shows) {
    return shows.where((show) => show.status == 1).toList();
  }

  List<ReligiousEpisodeModel> _filterActiveEpisodes(
      List<ReligiousEpisodeModel> episodes) {
    return episodes.where((episode) => episode.status == 1).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _socketService.initSocket();

    _initializeAnimations();
    _loadAuthKey();
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
    _pageTransitionController.dispose();
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
    print(
        '🚀 Initializing religious shows page with cache for channel ${widget.id}');

    // Try to load from cache first
    final cachedShows =
        await ReligiousShowsCacheManager.getShowsCache(widget.id);

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
      _pageTransitionController.forward();

      // Automatically fetch episodes for the first show without waiting.
      // This allows the UI to remain responsive while episodes load in the background.
      _fetchEpisodes(_filteredShows[0].id);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Focus is now set when episodes are loaded.
        }
      });
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
          await ReligiousShowsCacheManager.saveShowsCache(
              widget.id, freshShows);

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
    final currentSelectedShowId =
        _filteredShows.isNotEmpty && _selectedShowIndex < _filteredShows.length
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
          'https://acomtv.coretechinfo.com/public/api/v2/getReligiousShows/${widget.id}'),
      headers: {
        'auth-key': authKey,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'domain': 'coretechinfo.com',
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
      _selectedShowIndex = _filteredShows.indexWhere((s) => s.id == showId);
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
          'https://acomtv.coretechinfo.com/public/api/v2/getReligiousShowsEpisodes/$showId'),
      headers: {
        'auth-key': authKey,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'domain': 'coretechinfo.com',
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

  Future<void> _playEpisode(ReligiousEpisodeModel episode) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      if (mounted) {
        if (episode.source.toLowerCase() == 'youtube'
            // || isYoutubeUrl(episode.url)
            ) {
          final deviceInfo = context.read<DeviceInfoProvider>();

          if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
            print('isAFTSS');
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => YoutubeWebviewPlayer(
                          videoUrl: episode.url,
                          name: episode.title,
                        )));
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomYoutubePlayer(
                  videoData: VideoData(
                    id: episode.url,
                    title: episode.title,
                    youtubeUrl: episode.url,
                    thumbnail: episode.episodeImage,
                    description: episode.episodeDescription,
                  ),
                  playlist: [
                    VideoData(
                      id: episode.url,
                      title: episode.title,
                      youtubeUrl: episode.url,
                      thumbnail: episode.episodeImage,
                      description: episode.episodeDescription,
                    ),
                  ],
                ),
              ),
            );
          }
        }
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

  void _selectShow(int index) {
    if (index >= 0 && index < _filteredShows.length) {
      setState(() {
        _selectedShowIndex = index;
      });
      _fetchEpisodes(_filteredShows[index].id);
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

  List<ReligiousEpisodeModel> get _currentEpisodes {
    if (_filteredShows.isEmpty || _selectedShowIndex >= _filteredShows.length) {
      return [];
    }
    return _filteredEpisodesMap[_filteredShows[_selectedShowIndex].id] ?? [];
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
        if (_currentEpisodes.isNotEmpty &&
            _selectedEpisodeIndex < _currentEpisodes.length) {
          _episodeFocusNodes[
                  _currentEpisodes[_selectedEpisodeIndex].id.toString()]
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

  void _initializeAnimations() {
    _navigationModeController = AnimationController(
      duration: const Duration(milliseconds: 400),
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

  // Helper method for URL validation
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

            // Processing Overlay
            if (_isProcessing) _buildProcessingOverlay(),

            // Background refresh indicator (subtle)
            if (_isBackgroundRefreshing) _buildBackgroundRefreshIndicator(),
          ],
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

  Widget _buildTopNavigationBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80, // MODIFIED: Reduced height
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContentWithLayout() {
    return Positioned(
      top: 80, // MODIFIED: Adjusted top position
      left: 0,
      right: 0,
      bottom: 0, // MODIFIED: Extended to bottom
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
            child: const Text(
              // MODIFIED: Simplified header
              "SHOWS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
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
            child: Column(
              // MODIFIED: Simplified header
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "EPISODES",
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

  void _onShowTap(int index) {
    setState(() {
      _selectedShowIndex = index;
      _currentMode = NavigationMode.shows;
    });
    _showsFocusNodes[index]?.requestFocus();
    _selectShow(index);
  }

  Widget _buildShowItem(int index) {
    final show = _filteredShows[index];
    final isFocused =
        _currentMode == NavigationMode.shows && index == _selectedShowIndex;

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
            color: !isFocused ? Colors.grey[900]?.withOpacity(0.4) : null,
            borderRadius: BorderRadius.circular(12),
            border: isFocused ? Border.all(color: Colors.blue, width: 2) : null,
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            // Fallback to show thumbnail
                            if (_filteredShows.isNotEmpty &&
                                _selectedShowIndex < _filteredShows.length &&
                                _isValidImageUrl(
                                    _filteredShows[_selectedShowIndex]
                                        .thumbnail)) {
                              return CachedNetworkImage(
                                imageUrl: _filteredShows[_selectedShowIndex]
                                    .thumbnail,
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
                                      errorWidget: (context, url, error) =>
                                          Container(),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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

                      const SizedBox(height: 12),

                      // Episode Metadata
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
                              'Episode ${episode.episodeOrder}',
                              style: TextStyle(
                                color:
                                    isFocused ? Colors.green : Colors.grey[300],
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
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
            "No Episodes Found", // MODIFIED: Updated message
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
