import 'dart:async';
import 'dart:convert';
import 'package:mobi_tv_entertainment/components/provider/device_info_provider.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';
import 'package:mobi_tv_entertainment/components/video_widget/custom_video_player.dart';
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
  matches,
}

// Cache Manager Class for Tournament Data
class TournamentCacheManager {
  static const String _cacheKeyPrefix = 'tournament_cache_';
  static const String _matchesCacheKeyPrefix = 'matches_cache_';
  static const String _lastUpdatedKeyPrefix = 'last_updated_';
  static const Duration _cacheValidDuration =
      Duration(hours: 6); // Cache validity period

  // Save seasons data to cache
  static Future<void> saveSeasonsCache(
      int tournamentId, List<TournamentSeasonModel> seasons) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cacheKeyPrefix$tournamentId';
      final lastUpdatedKey = '$_lastUpdatedKeyPrefix$tournamentId';

      print(
          '💾 Saving ${seasons.length} seasons to cache for tournament $tournamentId');

      final seasonsJson = seasons
          .map((season) => {
                'id': season.id,
                'sports_tournament_id': season.sportsTournamentId,
                'season_title': season.seasonTitle,
                'start_date': season.startDate,
                'end_date': season.endDate,
                'logo': season.logo,
                'description': season.description,
                'status': season.status,
                'created_at': season.createdAt,
                'updated_at': season.updatedAt,
                'deleted_at': season.deletedAt,
                'season_order': season.seasonOrder,
              })
          .toList();

      await prefs.setString(cacheKey, jsonEncode(seasonsJson));
      await prefs.setInt(lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);

      print(
          '✅ Seasons cache saved for tournament $tournamentId - ${seasons.length} seasons');

      // Debug: Print what we saved
      for (var season in seasons) {
        print(
            '💾 Saved season: ID=${season.id}, Title=${season.seasonTitle}, Status=${season.status}');
      }
    } catch (e) {
      print('❌ Error saving tournament seasons cache: $e');
    }
  }

  // Get seasons data from cache
  static Future<List<TournamentSeasonModel>?> getSeasonsCache(
      int tournamentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cacheKeyPrefix$tournamentId';
      final lastUpdatedKey = '$_lastUpdatedKeyPrefix$tournamentId';

      final cachedData = prefs.getString(cacheKey);
      final lastUpdated = prefs.getInt(lastUpdatedKey);

      if (cachedData == null || lastUpdated == null) {
        return null;
      }

      // Check if cache is still valid
      final cacheAge = DateTime.now().millisecondsSinceEpoch - lastUpdated;
      final isExpired = cacheAge > _cacheValidDuration.inMilliseconds;

      if (isExpired) {
        print(
            '⏰ Tournament seasons cache expired for tournament $tournamentId');
        return null;
      }

      final List<dynamic> seasonsJson = jsonDecode(cachedData);
      final seasons = seasonsJson
          .map((json) => TournamentSeasonModel.fromJson(json))
          .toList();

      print(
          '✅ Tournament seasons cache loaded for tournament $tournamentId (${seasons.length} seasons)');
      return seasons;
    } catch (e) {
      print('❌ Error loading tournament seasons cache: $e');
      return null;
    }
  }

  // // Save matches data to cache
  // static Future<void> saveMatchesCache(
  //     int seasonId, List<TournamentMatchModel> matches) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final cacheKey = '$_matchesCacheKeyPrefix$seasonId';
  //     final lastUpdatedKey = '${_lastUpdatedKeyPrefix}matches_$seasonId';

  //     final matchesJson = matches
  //         .map((match) => {
  //               'id': match.id,
  //               'tournament_season_id': match.tournamentSeasonId,
  //               'match_title': match.matchTitle,
  //               'match_type': match.matchType,
  //               'match_date': match.matchDate,
  //               'match_time': match.matchTime,
  //               'description': match.description,
  //               'streaming_info': match.streamingInfo,
  //               'video_url': match.videoUrl,
  //               'playlist_id': match.playlistId,
  //               'thumbnail_url': match.thumbnailUrl,
  //               'status': match.status,
  //               'created_at': match.createdAt,
  //               'updated_at': match.updatedAt,
  //               'deleted_at': match.deletedAt,
  //               'match_order': match.matchOrder,
  //             })
  //         .toList();

  //     await prefs.setString(cacheKey, jsonEncode(matchesJson));
  //     await prefs.setInt(lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);

  //     print('✅ Tournament matches cache saved for season $seasonId');
  //   } catch (e) {
  //     print('❌ Error saving tournament matches cache: $e');
  //   }
  // }

  // In TournamentCacheManager class

  static Future<void> saveMatchesCache(
      int seasonId, List<TournamentMatchModel> matches) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_matchesCacheKeyPrefix$seasonId';
      final lastUpdatedKey = '${_lastUpdatedKeyPrefix}matches_$seasonId';

      final matchesJson = matches
          .map((match) => {
                'id': match.id,
                'tournament_season_id': match.tournamentSeasonId,
                'match_title': match.matchTitle,
                'match_type': match.matchType,
                'match_date': match.matchDate,
                'match_time': match.matchTime,
                'description': match.description,
                'streaming_info': match.streamingInfo,
                'video_url': match.videoUrl,
                'stream_type': match.streamType, // Add this line
                'playlist_id': match.playlistId,
                'thumbnail_url': match.thumbnailUrl,
                'status': match.status,
                'created_at': match.createdAt,
                'updated_at': match.updatedAt,
                'deleted_at': match.deletedAt,
                'match_order': match.matchOrder,
              })
          .toList();

      await prefs.setString(cacheKey, jsonEncode(matchesJson));
      await prefs.setInt(lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);

      print('✅ Tournament matches cache saved for season $seasonId');
    } catch (e) {
      print('❌ Error saving tournament matches cache: $e');
    }
  }

  // Get matches data from cache
  static Future<List<TournamentMatchModel>?> getMatchesCache(
      int seasonId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_matchesCacheKeyPrefix$seasonId';
      final lastUpdatedKey = '${_lastUpdatedKeyPrefix}matches_$seasonId';

      final cachedData = prefs.getString(cacheKey);
      final lastUpdated = prefs.getInt(lastUpdatedKey);

      if (cachedData == null || lastUpdated == null) {
        return null;
      }

      // Check if cache is still valid
      final cacheAge = DateTime.now().millisecondsSinceEpoch - lastUpdated;
      final isExpired = cacheAge > _cacheValidDuration.inMilliseconds;

      if (isExpired) {
        print('⏰ Tournament matches cache expired for season $seasonId');
        return null;
      }

      final List<dynamic> matchesJson = jsonDecode(cachedData);
      final matches = matchesJson
          .map((json) => TournamentMatchModel.fromJson(json))
          .toList();

      print(
          '✅ Tournament matches cache loaded for season $seasonId (${matches.length} matches)');
      return matches;
    } catch (e) {
      print('❌ Error loading tournament matches cache: $e');
      return null;
    }
  }

  // Compare two lists and check if they're different
  static bool areSeasonsDifferent(
      List<TournamentSeasonModel> cached, List<TournamentSeasonModel> fresh) {
    if (cached.length != fresh.length) return true;

    for (int i = 0; i < cached.length; i++) {
      final c = cached[i];
      final f = fresh[i];

      if (c.id != f.id ||
          c.seasonTitle != f.seasonTitle ||
          c.status != f.status ||
          c.updatedAt != f.updatedAt) {
        return true;
      }
    }
    return false;
  }

  // Compare two match lists and check if they're different
  static bool areMatchesDifferent(
      List<TournamentMatchModel> cached, List<TournamentMatchModel> fresh) {
    if (cached.length != fresh.length) return true;

    for (int i = 0; i < cached.length; i++) {
      final c = cached[i];
      final f = fresh[i];

      if (c.id != f.id ||
          c.matchTitle != f.matchTitle ||
          c.status != f.status ||
          c.updatedAt != f.updatedAt) {
        return true;
      }
    }
    return false;
  }

  // Clear all cache for a specific tournament
  static Future<void> clearTournamentCache(int tournamentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_cacheKeyPrefix$tournamentId');
      await prefs.remove('$_lastUpdatedKeyPrefix$tournamentId');
      print('🗑️ Cleared cache for tournament $tournamentId');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }
}

// Tournament Season Model for new API structure
class TournamentSeasonModel {
  final int id;
  final int sportsTournamentId;
  final String seasonTitle;
  final String startDate;
  final String endDate;
  final String? logo;
  final String description;
  final int status;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int seasonOrder;

  TournamentSeasonModel({
    required this.id,
    required this.sportsTournamentId,
    required this.seasonTitle,
    required this.startDate,
    required this.endDate,
    this.logo,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.seasonOrder,
  });

  factory TournamentSeasonModel.fromJson(Map<String, dynamic> json) {
    print('🔍 Creating TournamentSeasonModel from JSON: $json');

    try {
      final model = TournamentSeasonModel(
        id: json['id'] ?? 0,
        sportsTournamentId: json['sports_tournament_id'] ?? 0,
        seasonTitle: json['season_title'] ?? '',
        startDate: json['start_date'] ?? '',
        endDate: json['end_date'] ?? '',
        logo: json['logo'],
        description: json['description'] ?? '',
        status: json['status'] ?? 1,
        createdAt: json['created_at'] ?? '',
        updatedAt: json['updated_at'] ?? '',
        deletedAt: json['deleted_at'],
        seasonOrder: json['season_order'] ?? 0,
      );

      print(
          '✅ Successfully created TournamentSeasonModel: ID=${model.id}, Title=${model.seasonTitle}, Status=${model.status}');
      return model;
    } catch (e) {
      print('❌ Error in TournamentSeasonModel.fromJson: $e');
      rethrow;
    }
  }
}

// // Tournament Match Model for new API structure
// class TournamentMatchModel {
//   final int id;
//   final int tournamentSeasonId;
//   final String matchTitle;
//   final String matchType;
//   final String matchDate;
//   final String matchTime;
//   final String description;
//   final String streamingInfo;
//   final String? videoUrl;
//   final String? playlistId;
//   final String? thumbnailUrl;
//   final int status;
//   final String createdAt;
//   final String updatedAt;
//   final String? deletedAt;
//   final int matchOrder;

//   TournamentMatchModel({
//     required this.id,
//     required this.tournamentSeasonId,
//     required this.matchTitle,
//     required this.matchType,
//     required this.matchDate,
//     required this.matchTime,
//     required this.description,
//     required this.streamingInfo,
//     this.videoUrl,
//     this.playlistId,
//     this.thumbnailUrl,
//     required this.status,
//     required this.createdAt,
//     required this.updatedAt,
//     this.deletedAt,
//     required this.matchOrder,
//   });

//   factory TournamentMatchModel.fromJson(Map<String, dynamic> json) {
//     return TournamentMatchModel(
//       id: json['id'] ?? 0,
//       tournamentSeasonId: json['tournament_season_id'] ?? 0,
//       matchTitle: json['match_title'] ?? '',
//       matchType: json['match_type'] ?? '',
//       matchDate: json['match_date'] ?? '',
//       matchTime: json['match_time'] ?? '',
//       description: json['description'] ?? '',
//       streamingInfo: json['streaming_info'] ?? '',
//       videoUrl: json['video_url'],
//       playlistId: json['playlist_id'],
//       thumbnailUrl: json['thumbnail_url'],
//       status: json['status'] ?? 0,
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       deletedAt: json['deleted_at'],
//       matchOrder: json['match_order'] ?? 0,
//     );
//   }
// }

class TournamentMatchModel {
  final int id;
  final int tournamentSeasonId;
  final String matchTitle;
  final String matchType;
  final String matchDate;
  final String matchTime;
  final String description;
  final String streamingInfo;
  final String? videoUrl;
  final String? streamType; // Add this line
  final String? playlistId;
  final String? thumbnailUrl;
  final int status;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int matchOrder;

  TournamentMatchModel({
    required this.id,
    required this.tournamentSeasonId,
    required this.matchTitle,
    required this.matchType,
    required this.matchDate,
    required this.matchTime,
    required this.description,
    required this.streamingInfo,
    this.videoUrl,
    this.streamType, // Add this line
    this.playlistId,
    this.thumbnailUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.matchOrder,
  });

  factory TournamentMatchModel.fromJson(Map<String, dynamic> json) {
    return TournamentMatchModel(
      id: json['id'] ?? 0,
      tournamentSeasonId: json['tournament_season_id'] ?? 0,
      matchTitle: json['match_title'] ?? '',
      matchType: json['match_type'] ?? '',
      matchDate: json['match_date'] ?? '',
      matchTime: json['match_time'] ?? '',
      description: json['description'] ?? '',
      streamingInfo: json['streaming_info'] ?? '',
      videoUrl: json['video_url'],
      streamType: json['stream_type'], // Add this line
      playlistId: json['playlist_id'],
      thumbnailUrl: json['thumbnail_url'],
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'],
      matchOrder: json['match_order'] ?? 0,
    );
  }
}

class TournamentFinalDetailsPage extends StatefulWidget {
  final int id;
  final String banner;
  final String poster;
  final String name;
  final String updatedAt;

  const TournamentFinalDetailsPage({
    Key? key,
    required this.id,
    required this.banner,
    required this.poster,
    required this.name,
    required this.updatedAt,
  }) : super(key: key);

  @override
  _TournamentFinalDetailsPageState createState() =>
      _TournamentFinalDetailsPageState();
}

class _TournamentFinalDetailsPageState extends State<TournamentFinalDetailsPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // final SocketService _socketService = SocketService();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _seasonsScrollController = ScrollController();
  final FocusNode _mainFocusNode = FocusNode();

  // Updated data structures for new API
  List<TournamentSeasonModel> _seasons = [];
  Map<int, List<TournamentMatchModel>> _matchesMap = {};

  int _selectedSeasonIndex = 0;
  int _selectedMatchIndex = 0;

  NavigationMode _currentMode = NavigationMode.seasons;

  final Map<int, FocusNode> _seasonsFocusNodes = {};
  final Map<String, FocusNode> _matchFocusNodes = {};

  String _errorMessage = "";
  String _authKey = '';

  // Filtered data variables for active content
  List<TournamentSeasonModel> _filteredSeasons = [];
  Map<int, List<TournamentMatchModel>> _filteredMatchesMap = {};

  // Loading states
  bool _isLoading = false;
  bool _isProcessing = false;
  bool _isLoadingMatches = false;
  bool _isBackgroundRefreshing = false;

  // Animation Controllers
  late AnimationController _navigationModeController;
  late AnimationController _pageTransitionController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Filter methods for active content
  List<TournamentSeasonModel> _filterActiveSeasons(
      List<TournamentSeasonModel> seasons) {
    print('🔍 Filtering seasons: Total=${seasons.length}');
    final activeSeasons = seasons.where((season) {
      print(
          '🔍 Season ${season.id}: ${season.seasonTitle} - Status: ${season.status}');
      return season.status == 1;
    }).toList();
    print('🔍 Active seasons after filter: ${activeSeasons.length}');
    return activeSeasons;
  }

  List<TournamentMatchModel> _filterActiveMatches(
      List<TournamentMatchModel> matches) {
    print('🔍 Filtering matches: Total=${matches.length}');
    final activeMatches = matches.where((match) {
      print(
          '🔍 Match ${match.id}: ${match.matchTitle} - Status: ${match.status}');
      return match.status == 1;
    }).toList();
    print('🔍 Active matches after filter: ${activeMatches.length}');
    return activeMatches;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // _socketService.initSocket();

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
    _matchFocusNodes.values.forEach((node) => node.dispose());
    // _socketService.dispose();
    _navigationModeController.dispose();
    _pageTransitionController.dispose();
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
    print('🚀 Initializing page with cache for tournament ${widget.id}');

    // Try to load from cache first
    final cachedSeasons =
        await TournamentCacheManager.getSeasonsCache(widget.id);

    if (cachedSeasons != null && cachedSeasons.isNotEmpty) {
      // Show cached data immediately
      print(
          '⚡ Loading from cache instantly - found ${cachedSeasons.length} cached seasons');
      await _loadSeasonsFromCache(cachedSeasons);

      // Start background refresh
      _performBackgroundRefresh();
    } else {
      // No cache available, load from API with loading indicator
      print('📡 No cache available, loading from API');
      setState(() {
        _isLoading = true;
        _errorMessage = "Loading tournament data...";
      });
      await _fetchSeasonsFromAPI(showLoading: true);
    }
  }

  // Load seasons from cache and automatically fetch matches for the first season
  Future<void> _loadSeasonsFromCache(
      List<TournamentSeasonModel> cachedSeasons) async {
    print('🔍 Loading ${cachedSeasons.length} seasons from cache');

    final activeSeasons = _filterActiveSeasons(cachedSeasons);
    print('🔍 Found ${activeSeasons.length} active seasons after filtering');

    setState(() {
      _seasons = cachedSeasons;
      _filteredSeasons = activeSeasons;
      _isLoading = false;
      _errorMessage = "";
    });

    // Create focus nodes for active seasons
    _seasonsFocusNodes.clear();
    for (int i = 0; i < _filteredSeasons.length; i++) {
      _seasonsFocusNodes[i] = FocusNode();
    }

    if (_filteredSeasons.isNotEmpty) {
      _pageTransitionController.forward();
      // **MODIFICATION: Automatically load matches for the first season**
      print(
          '✅ Seasons loaded, now fetching matches for the first season automatically.');
      await _fetchMatches(_filteredSeasons[0].id);
    } else {
      print('❌ No active seasons found');
      setState(() {
        _errorMessage = "No active seasons available for this tournament";
      });
    }
  }

  // Perform background refresh without showing loading indicators
  Future<void> _performBackgroundRefresh() async {
    print('🔄 Starting background refresh');
    setState(() {
      _isBackgroundRefreshing = true;
    });

    try {
      final freshSeasons = await _fetchSeasonsFromAPIDirectly();

      if (freshSeasons != null) {
        // Compare with cached data
        final cachedSeasons = _seasons;
        final hasChanges = TournamentCacheManager.areSeasonsDifferent(
            cachedSeasons, freshSeasons);

        if (hasChanges) {
          print('🔄 Changes detected, updating UI silently');

          // Save new data to cache
          await TournamentCacheManager.saveSeasonsCache(
              widget.id, freshSeasons);

          // Update UI without disrupting user experience
          await _updateSeasonsData(freshSeasons);
        } else {
          print('✅ No changes detected in background refresh');
        }
      }
    } catch (e) {
      print('❌ Background refresh failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isBackgroundRefreshing = false;
        });
      }
    }
  }

  // Update seasons data while preserving user's current selection
  Future<void> _updateSeasonsData(
      List<TournamentSeasonModel> newSeasons) async {
    final activeSeasons = _filterActiveSeasons(newSeasons);
    final currentSelectedSeasonId = _filteredSeasons.isNotEmpty &&
            _selectedSeasonIndex < _filteredSeasons.length
        ? _filteredSeasons[_selectedSeasonIndex].id
        : null;

    setState(() {
      _seasons = newSeasons;
      _filteredSeasons = activeSeasons;
    });

    // Try to maintain user's current selection
    if (currentSelectedSeasonId != null) {
      final newIndex =
          _filteredSeasons.indexWhere((s) => s.id == currentSelectedSeasonId);
      if (newIndex >= 0) {
        setState(() {
          _selectedSeasonIndex = newIndex;
        });
      }
    }

    // Recreate focus nodes if needed
    _seasonsFocusNodes.clear();
    for (int i = 0; i < _filteredSeasons.length; i++) {
      _seasonsFocusNodes[i] = FocusNode();
    }
  }

  // Fetch seasons from API with loading indicator
  Future<void> _fetchSeasonsFromAPI({bool showLoading = false}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = "Loading tournament seasons...";
      });
    }

    try {
      print('🔄 Fetching seasons from API...');
      final seasons = await _fetchSeasonsFromAPIDirectly();

      if (seasons != null) {
        print('📦 Received ${seasons.length} seasons from API');

        // Debug each season
        for (var season in seasons) {
          print(
              '📦 API Season: ID=${season.id}, Title=${season.seasonTitle}, Status=${season.status}');
        }

        // Save to cache
        await TournamentCacheManager.saveSeasonsCache(widget.id, seasons);

        // Update UI
        await _loadSeasonsFromCache(seasons);
      } else {
        print('❌ Seasons is null from API');
        setState(() {
          _isLoading = false;
          _errorMessage = "No tournament data received from server";
        });
      }
    } catch (e) {
      print('❌ Error in _fetchSeasonsFromAPI: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = "Error: ${e.toString()}";
      });
    }
  }

  // Direct API call for seasons
  Future<List<TournamentSeasonModel>?> _fetchSeasonsFromAPIDirectly() async {
      String authKey = SessionManager.authKey ;
      var url = Uri.parse(SessionManager.baseUrl + 'getTouranamentSeasons/${widget.id}');

    try {
      final response = await https.get(url,
        // Uri.parse(
        //     'https://dashboard.cpplayers.com/public/api/v2/getTouranamentSeasons/${widget.id}'),
        headers: {
          'auth-key': authKey,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'domain': SessionManager.savedDomain,
        },
      ).timeout(const Duration(seconds: 15));

      print('🔍 ResponseStatus Code: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        String responseBody = response.body.trim();

        if (responseBody.isEmpty) {
          print('❌ Empty response body');
          return [];
        }

        if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
          try {
            final dynamic jsonData = jsonDecode(responseBody);
            print('🔍 Parsed JSON type: ${jsonData.runtimeType}');
            print('🔍 ParsedJSON: $jsonData');

            if (jsonData is List) {
              final List<dynamic> data = jsonData;
              print('🔍 Found ${data.length} seasons in response');

              if (data.isEmpty) {
                print('⚠️ API returned empty list of seasons');
                return [];
              }

              final seasons = data.map((season) {
                print('🔍 Processing season: $season');
                try {
                  final seasonModel = TournamentSeasonModel.fromJson(season);
                  print(
                      '✅ Created season model: ID=${seasonModel.id}, Title=${seasonModel.seasonTitle}, Status=${seasonModel.status}');
                  return seasonModel;
                } catch (e) {
                  print('❌ Error creating season model: $e');
                  rethrow;
                }
              }).toList();

              print('✅ Successfully parsed ${seasons.length} seasons');
              return seasons;
            } else {
              print('❌ Response is not a List, it is: ${jsonData.runtimeType}');
              return [];
            }
          } catch (e) {
            print('❌ JSON parsing error: $e');
            throw Exception('Failed to parse JSON: $e');
          }
        } else {
          print(
              '❌ Response does not start with [ or {, starts with: ${responseBody.substring(0, 10)}');
          throw Exception('Invalid JSON format');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception in _fetchSeasonsFromAPIDirectly: $e');
      rethrow;
    }
  }

  // Enhanced matches fetching with cache
  Future<void> _fetchMatches(int seasonId) async {
    // Check if already loaded
    if (_filteredMatchesMap.containsKey(seasonId)) {
      setState(() {
        _selectedSeasonIndex =
            _filteredSeasons.indexWhere((season) => season.id == seasonId);
        _selectedMatchIndex = 0;
      });
      _setNavigationMode(NavigationMode.matches);
      return;
    }

    // Try cache first
    final cachedMatches =
        await TournamentCacheManager.getMatchesCache(seasonId);

    if (cachedMatches != null) {
      // Load from cache instantly
      await _loadMatchesFromCache(seasonId, cachedMatches);

      // Start background refresh for matches
      _performMatchesBackgroundRefresh(seasonId);
    } else {
      // Load from API with loading indicator
      await _fetchMatchesFromAPI(seasonId, showLoading: true);
    }
  }

  // Load matches from cache
  Future<void> _loadMatchesFromCache(
      int seasonId, List<TournamentMatchModel> cachedMatches) async {
    final activeMatches = _filterActiveMatches(cachedMatches);

    _matchFocusNodes.clear();
    for (var match in activeMatches) {
      _matchFocusNodes[match.id.toString()] = FocusNode();
    }

    setState(() {
      _matchesMap[seasonId] = cachedMatches;
      _filteredMatchesMap[seasonId] = activeMatches;
      _selectedSeasonIndex =
          _filteredSeasons.indexWhere((s) => s.id == seasonId);
      _selectedMatchIndex = 0;
      _isLoadingMatches = false;
    });

    _setNavigationMode(NavigationMode.matches);
  }

  // Background refresh for matches
  Future<void> _performMatchesBackgroundRefresh(int seasonId) async {
    try {
      final freshMatches = await _fetchMatchesFromAPIDirectly(seasonId);

      if (freshMatches != null) {
        final cachedMatches = _matchesMap[seasonId] ?? [];
        final hasChanges = TournamentCacheManager.areMatchesDifferent(
            cachedMatches, freshMatches);

        if (hasChanges) {
          print('🔄 Matches changes detected for season $seasonId');

          // Save to cache
          await TournamentCacheManager.saveMatchesCache(seasonId, freshMatches);

          // Update UI
          await _loadMatchesFromCache(seasonId, freshMatches);
        }
      }
    } catch (e) {
      print('❌ Matches background refresh failed: $e');
    }
  }

  // Fetch matches from API with loading indicator
  Future<void> _fetchMatchesFromAPI(int seasonId,
      {bool showLoading = false}) async {
    if (showLoading) {
      setState(() {
        _isLoadingMatches = true;
      });
    }

    try {
      final matches = await _fetchMatchesFromAPIDirectly(seasonId);

      if (matches != null) {
        // Save to cache
        await TournamentCacheManager.saveMatchesCache(seasonId, matches);

        // Update UI
        await _loadMatchesFromCache(seasonId, matches);
      }
    } catch (e) {
      setState(() {
        _isLoadingMatches = false;
        _errorMessage = "Error loading matches: ${e.toString()}";
      });
    }
  }

  // Direct API call for matches
  Future<List<TournamentMatchModel>?> _fetchMatchesFromAPIDirectly(
      int seasonId) async {
      String authKey = SessionManager.authKey ;
      var url = Uri.parse(SessionManager.baseUrl + 'getTouranamentSeasonsEvents/$seasonId');

    try {
      final response = await https.get(url,
        // Uri.parse(
        //     'https://dashboard.cpplayers.com/public/api/v2/getTouranamentSeasonsEvents/$seasonId'),
        headers: {
          'auth-key': authKey,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'domain': SessionManager.savedDomain,
        },
      ).timeout(const Duration(seconds: 15));

      print('🔍 Matches Response Status Code: ${response.statusCode}');
      print('🔍 Matches Response Body: ${response.body}');

      if (response.statusCode == 200) {
        String responseBody = response.body.trim();

        if (responseBody.isEmpty) {
          print('❌ Empty matches response body');
          return [];
        }

        if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
          try {
            final dynamic jsonData = jsonDecode(responseBody);
            print('🔍 Matches Parsed JSON type: ${jsonData.runtimeType}');
            print('🔍 Matches Parsed JSON: $jsonData');

            if (jsonData is List) {
              final List<dynamic> data = jsonData;
              print('🔍 Found ${data.length} matches in response');

              final matches = data.map((match) {
                print('🔍 Processing match: $match');
                return TournamentMatchModel.fromJson(match);
              }).toList();

              print('✅ Successfully parsed ${matches.length} matches');
              return matches;
            } else {
              print(
                  '❌ Matches response is not a List, it is: ${jsonData.runtimeType}');
              return [];
            }
          } catch (e) {
            print('❌ Matches JSON parsing error: $e');
            throw Exception('Failed to parse matches JSON: $e');
          }
        } else {
          print(
              '❌ Matches response does not start with [ or {, starts with: ${responseBody.substring(0, 10)}');
          throw Exception('Invalid matches JSON format');
        }
      } else {
        print('❌ Matches HTTP Error: ${response.statusCode}');
        print('❌ Matches Error Body: ${response.body}');
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception in _fetchMatchesFromAPIDirectly: $e');
      rethrow;
    }
  }

  // Method to refresh data when returning from video player
  Future<void> _refreshDataOnReturn() async {
    print('🔄 Refreshing data on return from video player');
    await _performBackgroundRefresh();

    // Also refresh current season's matches if any are loaded
    if (_filteredSeasons.isNotEmpty &&
        _selectedSeasonIndex < _filteredSeasons.length) {
      final currentSeasonId = _filteredSeasons[_selectedSeasonIndex].id;
      if (_filteredMatchesMap.containsKey(currentSeasonId)) {
        await _performMatchesBackgroundRefresh(currentSeasonId);
      }
    }
  }

  // // Updated play match method with refresh on return
  // Future<void> _playMatch(TournamentMatchModel match) async {
  //   if (_isProcessing) return;

  //   setState(() => _isProcessing = true);

  //   try {
  //     String? url = match.videoUrl;

  //     if (url == null || url.isEmpty) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Video URL not available for this match'),
  //             backgroundColor: Colors.orange,
  //           ),
  //         );
  //       }
  //       return;
  //     }

  //     if (mounted) {
  //       dynamic result;

  //       if ( isYoutubeUrl(url)) {
  //         result = await Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => CustomYoutubePlayer(
  //               // videoUrl: url,
  //               // name: match.matchTitle,
  //               videoData: VideoData(
  //                 id: match.videoUrl ?? '',
  //                 title: match.matchTitle,
  //                 youtubeUrl: match.videoUrl ?? '',
  //                 thumbnail: match.thumbnailUrl ?? '',
  //                 description: match.description ?? '',
  //               ),
  //               playlist: [
  //                 VideoData(
  //                   id: match.videoUrl ?? '',
  //                   title: match.matchTitle,
  //                   youtubeUrl: match.videoUrl ?? '',
  //                   thumbnail: match.thumbnailUrl ?? '',
  //                   description: match.description ?? '',
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       } else {
  //         result = await Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => CustomVideoPlayer(
  //               videoUrl: url,
  //             ),
  //           ),
  //         );
  //       }

  //       // Refresh data after returning from video player
  //       await _refreshDataOnReturn();
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Error playing video'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isProcessing = false);
  //     }
  //   }
  // }

  // In _TournamentFinalDetailsPageState class

  Future<void> _playMatch(TournamentMatchModel match) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      print('Updating user history for: ${match.matchTitle}');
      int? currentUserId = SessionManager.userId;
      // final int? parsedContentType = int.tryParse(match.contentType ?? '');
      final int? parsedId = match.id;

      await HistoryService.updateUserHistory(
        userId: currentUserId!, // 1. User ID
        contentType: 8, // 2. Content Type (match के लिए 4)
        eventId: parsedId!, // 3. Event ID (match की ID)
        eventTitle: match.matchTitle, // 4. Event Title (match का नाम)
        url: match.videoUrl ?? '', // 5. URL (match का URL)
        categoryId: 0, // 6. Category ID (डिफ़ॉल्ट 1)
      );
    } catch (e) {
      print("History update failed, but proceeding to play. Error: $e");
    }

    try {
      String? url = match.videoUrl;

      if (url == null || url.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video URL not available for this match'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (mounted) {
        dynamic result;

        if (match.streamType == 'youtube'
            // || isYoutubeUrl(url)
            ) {
          final deviceInfo = context.read<DeviceInfoProvider>();

          if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
            print('isAFTSS');
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => YoutubeWebviewPlayer(
                          videoUrl: match.videoUrl ?? '',
                          name: match.matchTitle,
                        )));
          } else {
            result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomYoutubePlayer(
                  videoData: VideoData(
                    id: match.videoUrl ?? '',
                    title: match.matchTitle,
                    youtubeUrl: match.videoUrl ?? '',
                    thumbnail: match.thumbnailUrl ?? '',
                    description: match.description ?? '',
                  ),
                  playlist: [
                    VideoData(
                      id: match.videoUrl ?? '',
                      title: match.matchTitle,
                      youtubeUrl: match.videoUrl ?? '',
                      thumbnail: match.thumbnailUrl ?? '',
                      description: match.description ?? '',
                    ),
                  ],
                ),
              ),
            );
          }
        } else {
          // result = await Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => CustomVideoPlayer(
          //       videoUrl: url,
          //     ),
          //   ),
          // );
          result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoScreen(
                videoUrl: url,
                bannerImageUrl: match.thumbnailUrl ?? '',
                channelList: [],
                source: 'isSports',
                // isLive: false,
                // isSearch: false,
                videoId: match.id,
                name: match.matchTitle,
                liveStatus: false,
                updatedAt: match.updatedAt,
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

  // New method to show subtle background refresh indicator
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
        if (_currentMatches.isNotEmpty) {
          _matchFocusNodes[_currentMatches[_selectedMatchIndex].id.toString()]
              ?.requestFocus();
        }
      });
    }
  }

  List<TournamentMatchModel> get _currentMatches {
    if (_filteredSeasons.isEmpty ||
        _selectedSeasonIndex >= _filteredSeasons.length) {
      return [];
    }
    return _filteredMatchesMap[_filteredSeasons[_selectedSeasonIndex].id] ?? [];
  }

  // Updated _selectSeason method
  void _selectSeason(int index) {
    if (index >= 0 && index < _filteredSeasons.length) {
      setState(() {
        _selectedSeasonIndex = index;
      });
      _fetchMatches(_filteredSeasons[index].id);
    }
  }

  // Updated _handleSeasonsNavigation method
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

  void _handleMatchesNavigation(RawKeyEvent event) {
    final matches = _currentMatches;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        if (_selectedMatchIndex < matches.length - 1) {
          setState(() {
            _selectedMatchIndex++;
          });
          _scrollAndFocusMatch(_selectedMatchIndex);
        }
        break;

      case LogicalKeyboardKey.arrowUp:
        if (_selectedMatchIndex > 0) {
          setState(() {
            _selectedMatchIndex--;
          });
          _scrollAndFocusMatch(_selectedMatchIndex);
        }
        break;

      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.select:
        if (matches.isNotEmpty) {
          _playMatch(matches[_selectedMatchIndex]);
        }
        break;

      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.escape:
        _setNavigationMode(NavigationMode.seasons);
        break;
    }
  }

  void _onMatchTap(int index) {
    if (_currentMatches.isNotEmpty && index < _currentMatches.length) {
      setState(() {
        _selectedMatchIndex = index;
        _currentMode = NavigationMode.matches;
      });
      _matchFocusNodes[_currentMatches[index].id.toString()]?.requestFocus();
      _playMatch(_currentMatches[index]);
    }
  }

  Future<void> _scrollAndFocusMatch(int index) async {
    if (index < 0 || index >= _currentMatches.length) return;

    final context =
        _matchFocusNodes[_currentMatches[index].id.toString()]?.context;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
    }
  }

  // Updated _buildSeasonsPanel method
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
                    Icons.sports_soccer,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "ACTIVE SEASONS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
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

  // Updated _buildMatchesPanel method
  Widget _buildMatchesPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _currentMode == NavigationMode.matches
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
                    Icons.sports_esports,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ACTIVE MATCHES",
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    if (_filteredSeasons.isNotEmpty &&
                        _selectedSeasonIndex < _filteredSeasons.length)
                      Text(
                        _filteredSeasons[_selectedSeasonIndex].seasonTitle,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentMatches.length}',
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

          // Matches List
          Expanded(
            child:
                _isLoadingMatches ? _buildLoadingWidget() : _buildMatchesList(),
          ),
        ],
      ),
    );
  }

  // Updated _buildSeasonsList method
  Widget _buildSeasonsList() {
    return ListView.builder(
      controller: _seasonsScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _filteredSeasons.length,
      itemBuilder: (context, index) => _buildSeasonItem(index),
    );
  }

  // Updated _onSeasonTap method
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
    final matchCount = _filteredMatchesMap[season.id]?.length ?? 0;

    final String uniqueImageUrl = "${season.logo}?v=${season.updatedAt}";
    // final String uniqueBannerImageUrl = "${widget.banner}?v=${widget.updatedAt}";
    // ✅ Naya unique cache key banayein
    final String uniqueCacheKey = "${season.id.toString()}_${season.updatedAt}";

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
                        'S${season.seasonOrder}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  // Season logo overlay (if available)
                  if (season.logo != null && _isValidImageUrl(season.logo!))
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: _buildEnhancedImage(
                        imageUrl: uniqueImageUrl,
                        cacheKey: uniqueCacheKey,
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
                      season.seasonTitle,
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
                        if (matchCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$matchCount matches',
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

  // Updated _buildEmptyMatchesState method
  Widget _buildEmptyMatchesState() {
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
              Icons.sports_soccer_outlined,
              color: Colors.grey[500],
              size: 64,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No Active Matches Available",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "This season has no active matches",
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
          path.contains('banner') ||
          path.contains('logo');
    } catch (e) {
      return false;
    }
  }

  // Enhanced image widget builder
  Widget _buildEnhancedImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? fallbackWidget,
    required String cacheKey,
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
                cacheKey: cacheKey,
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

  // Default placeholder builder
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

  // bool isYoutubeUrl(String? url) {
  //   if (url == null || url.isEmpty) return false;
  //   url = url.toLowerCase().trim();
  //   return RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url) ||
  //       url.contains('youtube.com') ||
  //       url.contains('youtu.be') ||
  //       url.contains('youtube.com/shorts/');
  // }

  void _handleKeyEvent(RawKeyEvent event) {
    if (_isProcessing) return;

    if (event is RawKeyDownEvent) {
      switch (_currentMode) {
        case NavigationMode.seasons:
          _handleSeasonsNavigation(event);
          break;
        case NavigationMode.matches:
          _handleMatchesNavigation(event);
          break;
      }
    }
  }

  Widget _buildBackgroundLayer() {
    return Stack(
      children: [
        // Background Image
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
                // Tournament Title
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
      // **MODIFICATION: Adjusted layout constraints**
      top: 70, // Below navigation bar
      left: 0,
      right: 0,
      bottom: 0, // Extend to the bottom of the screen
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
          // Left Panel - Seasons
          Expanded(
            flex: 2,
            child: _buildSeasonsPanel(),
          ),

          const SizedBox(width: 20),

          // Right Panel - Matches
          Expanded(
            flex: 4,
            child: _buildMatchesPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesList() {
    final matches = _currentMatches;

    if (matches.isEmpty) {
      return _buildEmptyMatchesState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: matches.length,
      itemBuilder: (context, index) => _buildMatchItem(index),
    );
  }

  Widget _buildMatchItem(int index) {
    final match = _currentMatches[index];
    final isSelected = index == _selectedMatchIndex;
    final isFocused = _currentMode == NavigationMode.matches && isSelected;
    final isProcessing = _isProcessing && isSelected;

    final String uniqueImageUrl = "${match.thumbnailUrl}?v=${match.updatedAt}";
    final String uniqueBannerImageUrl =
        "${widget.banner}?v=${widget.updatedAt}";
    final String uniquePosterImageUrl =
        "${widget.poster}?v=${widget.updatedAt}";
    // ✅ Naya unique cache key banayein
    final String uniqueCacheKey = "${match.id.toString()}_${match.updatedAt}";

    return GestureDetector(
      onTap: () => _onMatchTap(index),
      child: Focus(
        focusNode: _matchFocusNodes[match.id.toString()],
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
              // Enhanced Thumbnail with multiple fallbacks
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
                    // Default background with match info
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
                              Icons.sports_soccer,
                              color: Colors.grey[400],
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              match.matchType,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Try to load images with fallback priority
                    if (match.thumbnailUrl != null &&
                        _isValidImageUrl(match.thumbnailUrl!))
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: uniqueImageUrl,
                          width: 140,
                          height: 90,
                          cacheKey: uniqueCacheKey,
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
                            // Fallback to tournament banner
                            if (_isValidImageUrl(widget.banner)) {
                              return CachedNetworkImage(
                                imageUrl: uniqueBannerImageUrl,
                                width: 140,
                                height: 90,
                                cacheKey: uniqueCacheKey,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  // Fallback to poster
                                  if (_isValidImageUrl(widget.poster)) {
                                    return CachedNetworkImage(
                                      imageUrl: uniquePosterImageUrl,
                                      width: 140,
                                      height: 90,
                                      cacheKey: uniqueCacheKey,
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
                      )
                    else if (_isValidImageUrl(widget.banner))
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: uniqueBannerImageUrl,
                          width: 140,
                          height: 90,
                          cacheKey: uniqueCacheKey,
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
                            // Fallback to poster
                            if (_isValidImageUrl(widget.poster)) {
                              return CachedNetworkImage(
                                imageUrl: uniquePosterImageUrl,
                                width: 140,
                                height: 90,
                                cacheKey: uniqueCacheKey,
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
                          imageUrl: uniquePosterImageUrl,
                          width: 140,
                          height: 90,
                          cacheKey: uniqueCacheKey,
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

                    // Play/Loading overlay with beautiful animations
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

                    // Video availability indicator
                    if (match.videoUrl == null || match.videoUrl!.isEmpty)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Live streaming indicator
                    if (match.streamingInfo.toLowerCase().contains('live'))
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
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
                      ),
                  ],
                ),
              ),

              // Match Information
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Match Title
                      Text(
                        match.matchTitle,
                        style: TextStyle(
                          color: isFocused ? Colors.green : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Match Type
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isFocused
                              ? Colors.green.withOpacity(0.2)
                              : Colors.grey[700]?.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          match.matchType,
                          style: TextStyle(
                            color: isFocused ? Colors.green : Colors.grey[300],
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Match Date and Time
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Colors.grey[500],
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${match.matchDate.split(' ')[0]} at ${match.matchTime}',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Streaming Info and Status
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: match.streamingInfo
                                      .toLowerCase()
                                      .contains('live')
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              match.streamingInfo,
                              style: TextStyle(
                                color: match.streamingInfo
                                        .toLowerCase()
                                        .contains('live')
                                    ? Colors.red
                                    : Colors.blue,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isFocused &&
                              match.videoUrl != null &&
                              match.videoUrl!.isNotEmpty) ...[
                            const SizedBox(width: 8),
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Action Button Area
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
                            colors: match.videoUrl == null ||
                                    match.videoUrl!.isEmpty
                                ? [Colors.grey[600]!, Colors.grey[700]!]
                                : isFocused
                                    ? [Colors.green, Colors.green.shade400]
                                    : isSelected
                                        ? [
                                            Colors.white.withOpacity(0.3),
                                            Colors.white.withOpacity(0.1)
                                          ]
                                        : [
                                            Colors.grey[700]!,
                                            Colors.grey[600]!
                                          ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: isFocused &&
                                  match.videoUrl != null &&
                                  match.videoUrl!.isNotEmpty
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
                            : Icon(
                                match.videoUrl == null ||
                                        match.videoUrl!.isEmpty
                                    ? Icons.not_interested
                                    : Icons.play_arrow,
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
                          color:
                              match.videoUrl == null || match.videoUrl!.isEmpty
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          match.videoUrl == null || match.videoUrl!.isEmpty
                              ? ''
                              : 'PRESS ENTER',
                          style: TextStyle(
                            color: match.videoUrl == null ||
                                    match.videoUrl!.isEmpty
                                ? Colors.red
                                : Colors.green,
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
