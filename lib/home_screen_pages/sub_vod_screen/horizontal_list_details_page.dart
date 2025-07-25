



import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as https;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/home_screen_pages/tv_show/tv_show.dart';
import 'package:mobi_tv_entertainment/home_screen_pages/tv_show/tv_show_final_details_page.dart';
import 'package:mobi_tv_entertainment/video_widget/custom_video_player.dart';
import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player.dart';
import 'package:mobi_tv_entertainment/video_widget/socket_service.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

// Animation Timing
class AnimationTiming {
  static const Duration ultraFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration focus = Duration(milliseconds: 300);
  static const Duration scroll = Duration(milliseconds: 800);
}

// API Service
class ApiService {
  static Future<Map<String, String>> getHeaders() async {
    await AuthManager.initialize();
    String authKey = AuthManager.authKey;

    if (authKey.isEmpty) {
      throw Exception('Auth key not found. Please login again.');
    }

    return {
      'auth-key': authKey,
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  static String get baseUrl => 'https://acomtv.coretechinfo.com/public/api/';
}

// Helper functions
int safeParseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;

  if (value is int) {
    return value;
  } else if (value is String) {
    return int.tryParse(value) ?? defaultValue;
  } else if (value is double) {
    return value.toInt();
  }

  return defaultValue;
}

String safeParseString(dynamic value, {String defaultValue = ''}) {
  if (value == null) return defaultValue;
  return value.toString();
}

// Movie Item Model
class MovieItem {
  final int id;
  final String name;
  final String description;
  final String genres;
  final String releaseDate;
  final int? runtime;
  final String sourceType;
  final String? youtubeTrailer;
  final String movieUrl;
  final String? poster;
  final String? banner;
  final int status;
  final int contentType;

  MovieItem({
    required this.id,
    required this.name,
    required this.description,
    required this.genres,
    required this.releaseDate,
    this.runtime,
    required this.sourceType,
    this.youtubeTrailer,
    required this.movieUrl,
    this.poster,
    this.banner,
    required this.status,
    required this.contentType,
  });

  factory MovieItem.fromJson(Map<String, dynamic> json) {
    return MovieItem(
      id: safeParseInt(json['id']),
      name: safeParseString(json['name'], defaultValue: 'No Name'),
      description: safeParseString(json['description'], defaultValue: ''),
      genres: safeParseString(json['genres'], defaultValue: 'Unknown'),
      releaseDate: safeParseString(json['release_date'], defaultValue: ''),
      runtime: json['runtime'] != null ? safeParseInt(json['runtime']) : null,
      sourceType: safeParseString(json['source_type'], defaultValue: ''),
      youtubeTrailer: json['youtube_trailer'],
      movieUrl: safeParseString(json['movie_url'], defaultValue: ''),
      poster: json['poster'],
      banner: json['banner'],
      status: safeParseInt(json['status']),
      contentType: safeParseInt(json['content_type']),
    );
  }

  bool get isActive => status == 1;
}

// Optimized Cache Manager for Vod
class TVShowCacheManager {
  static const String _cacheKeyPrefix = 'vod_cache_';
  static const String _timestampKeyPrefix = 'vod_timestamp_';
  static const Duration _cacheValidDuration = Duration(hours: 2); // Cache validity period

  // Save Vod to cache
  static Future<void> saveTVShowsToCache(int tvChannelId, List<TVShowDetailsModel> tvShows) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cacheKeyPrefix$tvChannelId';
      final timestampKey = '$_timestampKeyPrefix$tvChannelId';
      
      // Convert Vod to JSON
      final jsonList = tvShows.map((show) => {
        'id': show.id,
        'name': show.name,
        'banner': show.banner,
        'genre': show.genre,
        'description': show.description,
        'tv_channel_id': show.tvChannelId,
        'release_date': show.releaseDate,
        'status': show.status,
        'order': show.order,
        'created_at': show.createdAt,
        'updated_at': show.updatedAt,
      }).toList();
      
      final jsonString = json.encode(jsonList);
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      
      await prefs.setString(cacheKey, jsonString);
      await prefs.setInt(timestampKey, currentTimestamp);
      
      print('✅ Vod cached successfully for channel $tvChannelId');
    } catch (e) {
      print('❌ Error saving Vod to cache: $e');
    }
  }

  // Load Vod from cache
  static Future<List<TVShowDetailsModel>?> loadTVShowsFromCache(int tvChannelId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cacheKeyPrefix$tvChannelId';
      final timestampKey = '$_timestampKeyPrefix$tvChannelId';
      
      final jsonString = prefs.getString(cacheKey);
      final timestamp = prefs.getInt(timestampKey);
      
      if (jsonString == null || timestamp == null) {
        print('📋 No cache found for channel $tvChannelId');
        return null;
      }
      
      // Check if cache is still valid
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      final isExpired = cacheAge > _cacheValidDuration.inMilliseconds;
      
      print('📋 Cache age: ${Duration(milliseconds: cacheAge).inMinutes} minutes');
      print('📋 Cache expired: $isExpired');
      
      final List<dynamic> jsonList = json.decode(jsonString);
      final tvShows = jsonList.map((json) => TVShowDetailsModel.fromJson(json)).toList();
      
      print('✅ Loaded ${tvShows.length} Vod from cache for channel $tvChannelId');
      return tvShows;
    } catch (e) {
      print('❌ Error loading Vod from cache: $e');
      return null;
    }
  }

  // Check if cache exists and is valid
  static Future<bool> isCacheValid(int tvChannelId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampKey = '$_timestampKeyPrefix$tvChannelId';
      final timestamp = prefs.getInt(timestampKey);
      
      if (timestamp == null) return false;
      
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      return cacheAge <= _cacheValidDuration.inMilliseconds;
    } catch (e) {
      return false;
    }
  }

  // Clear cache for specific channel
  static Future<void> clearCacheForChannel(int tvChannelId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cacheKeyPrefix$tvChannelId';
      final timestampKey = '$_timestampKeyPrefix$tvChannelId';
      
      await prefs.remove(cacheKey);
      await prefs.remove(timestampKey);
      
      print('🗑️ Cache cleared for channel $tvChannelId');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }
}

// Fetch Movie URL Function - Fresh API calls without cache
Future<String?> fetchMovieUrlByContentId(BuildContext context, int contentId) async {
  try {
    final headers = await ApiService.getHeaders();

    final response = await https.get(
      Uri.parse('${ApiService.baseUrl}getAllMovies'),
      headers: headers,
    );

    print('🔍 Fetching fresh movie URL for content ID: $contentId');

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);

      for (var movieJson in body) {
        final MovieItem movie = MovieItem.fromJson(movieJson);

        if (movie.id == contentId &&
            movie.isActive &&
            movie.movieUrl.isNotEmpty) {
          print('✅ Fresh movie URL found: ${movie.movieUrl}');
          return movie.movieUrl;
        }
      }

      print('❌ No movie URL found for content ID: $contentId');
      return null;
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('Failed to fetch movies: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error fetching movie URL: $e');
    rethrow;
  }
}

// isYoutubeUrl helper function
bool isYoutubeUrl(String url) {
  if (url.isEmpty) return false;
  return RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url) ||
      url.contains('youtube.com') ||
      url.contains('youtu.be');
}

// TV Show Details Model
class TVShowDetailsModel {
  final int id;
  final String name;
  final String? banner;
  final String? genre;
  final String? description;
  final int tvChannelId;
  final String? releaseDate;
  final int status;
  final int order;
  final String? createdAt;
  final String? updatedAt;

  TVShowDetailsModel({
    required this.id,
    required this.name,
    this.banner,
    this.genre,
    this.description,
    required this.tvChannelId,
    this.releaseDate,
    required this.status,
    required this.order,
    this.createdAt,
    this.updatedAt,
  });

  factory TVShowDetailsModel.fromJson(Map<String, dynamic> json) {
    return TVShowDetailsModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      banner: json['banner'],
      genre: json['genre'],
      description: json['description'],
      tvChannelId: json['tv_channel_id'] ?? 0,
      releaseDate: json['release_date'],
      status: json['status'] ?? 0,
      order: json['order'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

// Professional TV Show Loading Indicator
class ProfessionalTVShowLoadingIndicator extends StatefulWidget {
  final String message;

  const ProfessionalTVShowLoadingIndicator({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  _ProfessionalTVShowLoadingIndicatorState createState() =>
      _ProfessionalTVShowLoadingIndicatorState();
}

class _ProfessionalTVShowLoadingIndicatorState
    extends State<ProfessionalTVShowLoadingIndicator>
    with TickerProviderStateMixin {
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
                    Icons.live_tv_rounded,
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




// Main HorizontalListDetailsPage Class with Proper Focus Management
class HorizontalListDetailsPage extends StatefulWidget {
  final int tvChannelId;
  final String channelName;
  final String? channelLogo;

  const HorizontalListDetailsPage({
    Key? key,
    required this.tvChannelId,
    required this.channelName,
    this.channelLogo,
  }) : super(key: key);

  @override
  _HorizontalListDetailsPageState createState() => _HorizontalListDetailsPageState();
}

class _HorizontalListDetailsPageState extends State<HorizontalListDetailsPage>
    with TickerProviderStateMixin {
  List<TVShowDetailsModel> tvShowsList = [];
  bool isLoading = true;
  bool isRefreshing = false;
  String? errorMessage;
  
  // ✅ Fixed Focus Management - Similar to MoviesGridView
  Map<String, FocusNode> _tvShowFocusNodes = {};
  late ScrollController _scrollController;
  bool _isLoading = false;
  
  // Video Loading State
  bool _isVideoLoading = false;
  String _loadingShowName = '';
  final SocketService _socketService = SocketService();

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late AnimationController _headerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _headerSlideAnimation;


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeAnimations();
    _startAnimations();
    _initializeData();
    
    _socketService.initSocket();
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

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    _headerController.forward();
    _fadeController.forward();
  }

  // Smart initialization: Cache first, then fresh data
  Future<void> _initializeData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      print('🚀 Initializing Vod data for channel ${widget.tvChannelId}');

      // Try to load from cache first
      final cachedData = await TVShowCacheManager.loadTVShowsFromCache(widget.tvChannelId);
      
      if (cachedData != null && cachedData.isNotEmpty) {
        print('📋 Loading from cache: ${cachedData.length} shows');
        setState(() {
          tvShowsList = cachedData;
          isLoading = false;
        });
        
        // ✅ Initialize focus nodes AFTER data is loaded
        _initializeTVShowFocusNodes();
        _staggerController.forward();
        
        // Now fetch fresh data in background
        _fetchFreshDataInBackground();
      } else {
        print('🌐 No cache found, fetching from API');
        // No cache, fetch fresh data
        await _fetchTVShowsFromAPI(showLoading: true);
      }
    } catch (e) {
      print('❌ Error in initialization: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading Vod: $e';
      });
    }
  }

  // Fetch fresh data in background - ONLY UPDATE CACHE, NOT UI
  Future<void> _fetchFreshDataInBackground() async {
    try {
      print('🔄 Fetching fresh data in background (cache only)...');
      setState(() {
        isRefreshing = true;
      });

      final freshData = await _getTVShowsFromAPI();
      
      if (freshData != null && freshData.isNotEmpty) {
        print('🔄 Fresh data received, updating cache silently');
        
        // ALWAYS save fresh data to cache (regardless of changes)
        await TVShowCacheManager.saveTVShowsToCache(widget.tvChannelId, freshData);
        print('✅ Cache updated with fresh data (${freshData.length} shows)');
        
        // Optional: Log if data has changed (for debugging)
        if (_hasDataChanged(tvShowsList, freshData)) {
          print('📊 Data has changed but UI not updated (cache-only mode)');
        } else {
          print('📊 Data unchanged, cache timestamp refreshed');
        }
      }
    } catch (e) {
      print('❌ Background cache refresh failed: $e');
      // Don't show error for background refresh
    } finally {
      if (mounted) {
        setState(() {
          isRefreshing = false;
        });
      }
    }
  }

  // Check if data has changed
  bool _hasDataChanged(List<TVShowDetailsModel> oldData, List<TVShowDetailsModel> newData) {
    if (oldData.length != newData.length) return true;
    
    for (int i = 0; i < oldData.length; i++) {
      if (oldData[i].id != newData[i].id || 
          oldData[i].name != newData[i].name ||
          oldData[i].banner != newData[i].banner) {
        return true;
      }
    }
    return false;
  }

  // Fetch Vod from API (with optional loading indicator)
  Future<void> _fetchTVShowsFromAPI({bool showLoading = false}) async {
    try {
      if (showLoading) {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
      }

      final freshData = await _getTVShowsFromAPI();
      
      if (freshData != null) {
        setState(() {
          tvShowsList = freshData;
          if (showLoading) isLoading = false;
        });

        // Save to cache
        await TVShowCacheManager.saveTVShowsToCache(widget.tvChannelId, freshData);
        
        if (tvShowsList.isNotEmpty) {
          // ✅ Initialize focus nodes AFTER data is loaded
          _initializeTVShowFocusNodes();
          _staggerController.forward();
          print('✅ Successfully loaded ${tvShowsList.length} Vod from API');
        } else {
          setState(() {
            errorMessage = 'No Vod found for this channel';
          });
        }
      }
    } catch (e) {
      setState(() {
        if (showLoading) isLoading = false;
        errorMessage = 'Error loading Vod: $e';
      });
      print('❌ Error fetching Vod from API: $e');
    }
  }

  // Core API call method
  Future<List<TVShowDetailsModel>?> _getTVShowsFromAPI() async {
    final prefs = await SharedPreferences.getInstance();
    String authKey = prefs.getString('auth_key') ?? '';

    final response = await https.get(
      Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllContentsOfNetwork/${widget.tvChannelId}'),
      headers: {
        'auth-key': authKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    print('🔍 API Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => TVShowDetailsModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load Vod: ${response.statusCode}');
    }
  }

  // ✅ FIXED: Professional Focus Nodes Creation - Similar to MoviesGridView
  void _initializeTVShowFocusNodes() {
    // Safely dispose existing nodes first
    for (var entry in _tvShowFocusNodes.entries) {
      try {
        entry.value.removeListener(() {});
        entry.value.dispose();
      } catch (e) {
        print('⚠️ Error disposing focus node ${entry.key}: $e');
      }
    }

    // Clear the map and create new nodes
    _tvShowFocusNodes.clear();

    // Create focus nodes for all Vod
    for (var tvShow in tvShowsList) {
      String tvShowId = tvShow.id.toString();
      _tvShowFocusNodes[tvShowId] = FocusNode()
        ..addListener(() {
          if (mounted && _tvShowFocusNodes[tvShowId]!.hasFocus) {
            _scrollToFocusedItem(tvShowId);
          }
        });
    }

    // ✅ Set focus to first TV show after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && tvShowsList.isNotEmpty && _tvShowFocusNodes.isNotEmpty) {
        final firstTVShowId = tvShowsList[0].id.toString();
        if (_tvShowFocusNodes.containsKey(firstTVShowId)) {
          try {
            FocusScope.of(context).requestFocus(_tvShowFocusNodes[firstTVShowId]);
            print('✅ Focus set to first TV show: $firstTVShowId');
          } catch (e) {
            print('⚠️ Error setting initial focus: $e');
          }
        }
      }
    });
  }

  // ✅ Fixed scroll to focused item
  void _scrollToFocusedItem(String itemId) {
    if (!mounted) return;

    try {
      final focusNode = _tvShowFocusNodes[itemId];
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
      print('⚠️ Error scrolling to focused item: $e');
    }
  }

  // Enhanced TV Show Selection with loading handling
  Future<void> _handleTVShowTap(TVShowDetailsModel tvShow) async {
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
                      color: ProfessionalColors.accentGreen.withOpacity(0.3),
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
                            ProfessionalColors.accentGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Loading TV Show...',
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

        // Try to get movie URL by content ID first
        String? movieUrl = await fetchMovieUrlByContentId(context, tvShow.id);
        
        // If no movie URL found, use the banner as fallback
        String videoUrl = movieUrl ?? tvShow.banner ?? '';
        
        print('🎬 Video URL for ${tvShow.name}: $videoUrl');
        
        if (videoUrl.isEmpty) {
          throw Exception('No video URL found for this TV show');
        }

        // Navigate to appropriate player
        if (isYoutubeUrl(videoUrl)) {
          videoUrl = await _socketService.getUpdatedUrl(videoUrl);
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoScreen(
                videoUrl: videoUrl,
                name: tvShow.name,
                unUpdatedUrl: videoUrl,
                channelList: const [],
                bannerImageUrl: tvShow.banner ?? '',
                startAtPosition: Duration.zero,
                videoType: 'vod',
                isLive: false,
                isVOD: true,
                isLastPlayedStored: false,
                isSearch: false,
                isBannerSlider: false,
                videoId: tvShow.id,
                seasonId: null,
                source: 'vod',
                liveStatus: false,
              ),
            ),
          );
          // await Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => CustomYoutubePlayer(
          //       videoUrl: videoUrl, name: tvShow.name,
          //     ),
          //   ),
          // );
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomVideoPlayer(
                videoUrl: videoUrl,
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

        String errorMessage = 'Error loading TV show';
        if (e.toString().contains('network') ||
            e.toString().contains('connection')) {
          errorMessage = 'Network error. Please check your connection';
        } else if (e.toString().contains('format') ||
            e.toString().contains('codec')) {
          errorMessage = 'Video format not supported';
        } else if (e.toString().contains('not found') ||
            e.toString().contains('404')) {
          errorMessage = 'TV show not found or unavailable';
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
              onPressed: () => _handleTVShowTap(tvShow),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Manual refresh method
  Future<void> _manualRefresh() async {
    await _fetchTVShowsFromAPI(showLoading: true);
  }



  // ✅ ENHANCED: Fixed AppBar Layout - Similar to Grid Page Structure
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: ProfessionalColors.primaryDark,
    body: Container(
      // Background Gradient
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
                  height: MediaQuery.of(context).padding.top + 100, // AppBar total height
                ),
                Expanded(child: _buildTVShowsGrid()),
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

          // ✅ Loading Overlay - Always on top
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: ProfessionalTVShowLoadingIndicator(message: 'Loading TV Show...'),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

// ✅ Enhanced AppBar with Fixed Position
Widget _buildProfessionalAppBar() {
  return Container(
    // ✅ Enhanced AppBar with proper z-index and blur effect
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ProfessionalColors.primaryDark.withOpacity(0.98), // More opaque for fixed position
          ProfessionalColors.surfaceDark.withOpacity(0.95),
          ProfessionalColors.surfaceDark.withOpacity(0.9),
          ProfessionalColors.surfaceDark.withOpacity(0.7),
          Colors.transparent,
        ],
      ),
      // ✅ Add bottom border for better separation
      border: Border(
        bottom: BorderSide(
          color: ProfessionalColors.accentGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      // ✅ Enhanced shadow for fixed position
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 15,
          offset: const Offset(0, 3),
        ),
        BoxShadow(
          color: ProfessionalColors.primaryDark.withOpacity(0.8),
          blurRadius: 8,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: ClipRRect(
      child: BackdropFilter(
        // ✅ Enhanced blur effect for better visibility
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          decoration: BoxDecoration(
            // ✅ Additional overlay for better readability
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 15,
            left: 40,
            right: 40,
            bottom: 5,
          ),
          child: Row(
            children: [
              // ✅ Enhanced Back Button with better visibility
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      ProfessionalColors.accentGreen.withOpacity(0.4),
                      ProfessionalColors.accentBlue.withOpacity(0.4),
                    ],
                  ),
                  // ✅ Enhanced shadow for better visibility
                  boxShadow: [
                    BoxShadow(
                      color: ProfessionalColors.accentGreen.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                  // ✅ Border for better definition
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
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
              
              // ✅ Enhanced Title Section
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left side - Channel info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ Enhanced title with better contrast
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                ProfessionalColors.accentGreen,
                                ProfessionalColors.accentBlue,
                              ],
                            ).createShader(bounds),
                            child: Text(
                              widget.channelName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.8),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                  Shadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // ✅ Enhanced subtitle with better visibility
                          Row(
                            children: [
                              // Shows count badge with enhanced visibility
                              // Container(
                              //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              //   decoration: BoxDecoration(
                              //     gradient: LinearGradient(
                              //       colors: [
                              //         ProfessionalColors.accentGreen.withOpacity(0.4),
                              //         ProfessionalColors.accentBlue.withOpacity(0.3),
                              //       ],
                              //     ),
                              //     borderRadius: BorderRadius.circular(15),
                              //     border: Border.all(
                              //       color: ProfessionalColors.accentGreen.withOpacity(0.6),
                              //       width: 1,
                              //     ),
                              //     // ✅ Enhanced shadow for better visibility
                              //     boxShadow: [
                              //       BoxShadow(
                              //         color: ProfessionalColors.accentGreen.withOpacity(0.3),
                              //         blurRadius: 8,
                              //         offset: const Offset(0, 2),
                              //       ),
                              //       BoxShadow(
                              //         color: Colors.black.withOpacity(0.4),
                              //         blurRadius: 4,
                              //         offset: const Offset(0, 1),
                              //       ),
                              //     ],
                              //   ),
                              //   child: Text(
                              //     '${tvShowsList.length} Shows Available',
                              //     style: const TextStyle(
                              //       color: Colors.white,
                              //       fontSize: 12,
                              //       fontWeight: FontWeight.w600,
                              //       shadows: [
                              //         Shadow(
                              //           color: Colors.black87,
                              //           blurRadius: 3,
                              //           offset: Offset(0, 1),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              
                              // // ✅ Enhanced refresh status indicator
                              // if (isRefreshing) ...[
                              //   const SizedBox(width: 8),
                              //   Container(
                              //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              //     decoration: BoxDecoration(
                              //       color: ProfessionalColors.accentBlue.withOpacity(0.3),
                              //       borderRadius: BorderRadius.circular(12),
                              //       border: Border.all(
                              //         color: ProfessionalColors.accentBlue.withOpacity(0.5),
                              //         width: 1,
                              //       ),
                              //       boxShadow: [
                              //         BoxShadow(
                              //           color: ProfessionalColors.accentBlue.withOpacity(0.3),
                              //           blurRadius: 6,
                              //           offset: const Offset(0, 2),
                              //         ),
                              //       ],
                              //     ),
                              //     child: Row(
                              //       mainAxisSize: MainAxisSize.min,
                              //       children: [
                              //         SizedBox(
                              //           width: 12,
                              //           height: 12,
                              //           child: CircularProgressIndicator(
                              //             strokeWidth: 2,
                              //             valueColor: AlwaysStoppedAnimation<Color>(
                              //               Colors.white,
                              //             ),
                              //           ),
                              //         ),
                              //         const SizedBox(width: 6),
                              //         const Text(
                              //           'Updating...',
                              //           style: TextStyle(
                              //             color: Colors.white,
                              //             fontSize: 10,
                              //             fontWeight: FontWeight.w500,
                              //             shadows: [
                              //               Shadow(
                              //                 color: Colors.black54,
                              //                 blurRadius: 2,
                              //                 offset: Offset(0, 1),
                              //               ),
                              //             ],
                              //           ),
                              //         ),
                                    // ],
                                  // ),
                                // ),
                              // ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Right side - Action buttons and logo
                    Row(
                      children: [
                        // ✅ Enhanced Refresh button with better visibility
                        // Container(
                        //   decoration: BoxDecoration(
                        //     shape: BoxShape.circle,
                        //     gradient: LinearGradient(
                        //       colors: [
                        //         ProfessionalColors.accentBlue.withOpacity(0.4),
                        //         ProfessionalColors.accentPurple.withOpacity(0.4),
                        //       ],
                        //     ),
                        //     // ✅ Enhanced shadow for better visibility
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: ProfessionalColors.accentBlue.withOpacity(0.4),
                        //         blurRadius: 8,
                        //         offset: const Offset(0, 3),
                        //       ),
                        //       BoxShadow(
                        //         color: Colors.black.withOpacity(0.3),
                        //         blurRadius: 4,
                        //         offset: const Offset(0, 1),
                        //       ),
                        //     ],
                        //     // ✅ Border for better definition
                        //     border: Border.all(
                        //       color: Colors.white.withOpacity(0.2),
                        //       width: 1,
                        //     ),
                        //   ),
                        //   child: IconButton(
                        //     icon: Icon(
                        //       Icons.refresh_rounded,
                        //       color: isRefreshing 
                        //           ? ProfessionalColors.accentBlue 
                        //           : Colors.white,
                        //       size: 20,
                        //     ),
                        //     onPressed: isRefreshing ? null : _manualRefresh,
                        //     tooltip: 'Refresh Shows',
                        //   ),
                        // ),
                        
                        // const SizedBox(width: 12),



                        Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      ProfessionalColors.accentGreen.withOpacity(0.4),
                                      ProfessionalColors.accentBlue.withOpacity(0.3),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: ProfessionalColors.accentGreen.withOpacity(0.6),
                                    width: 1,
                                  ),
                                  // ✅ Enhanced shadow for better visibility
                                  boxShadow: [
                                    BoxShadow(
                                      color: ProfessionalColors.accentGreen.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${tvShowsList.length} Shows Available',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black87,
                                        blurRadius: 3,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                        const SizedBox(width: 12),

                        
                        // ✅ Enhanced Channel Logo with better visibility
                        if (widget.channelLogo != null)
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(27.5),
                              border: Border.all(
                                color: ProfessionalColors.accentGreen.withOpacity(0.6),
                                width: 2,
                              ),
                              // ✅ Enhanced shadow for better visibility
                              boxShadow: [
                                BoxShadow(
                                  color: ProfessionalColors.accentGreen.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25.5),
                              child: Image.network(
                                widget.channelLogo!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          ProfessionalColors.accentGreen,
                                          ProfessionalColors.accentBlue,
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        ProfessionalColors.accentGreen,
                                        ProfessionalColors.accentBlue,
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.live_tv,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: ProfessionalColors.primaryDark,
  //     body: Stack(
  //       children: [
  //         // Background Gradient
  //         Container(
  //           decoration: BoxDecoration(
  //             gradient: LinearGradient(
  //               begin: Alignment.topCenter,
  //               end: Alignment.bottomCenter,
  //               colors: [
  //                 ProfessionalColors.primaryDark,
  //                 ProfessionalColors.surfaceDark.withOpacity(0.8),
  //                 ProfessionalColors.primaryDark,
  //               ],
  //             ),
  //           ),
  //         ),

  //         // Main Content
  //         FadeTransition(
  //           opacity: _fadeAnimation,
  //           child: Column(
  //             children: [
  //               _buildProfessionalAppBar(),
  //               Expanded(child: _buildTVShowsGrid()),
  //             ],
  //           ),
  //         ),

  //         // Loading Overlay
  //         if (_isLoading)
  //           Container(
  //             color: Colors.black.withOpacity(0.7),
  //             child: const Center(
  //               child: ProfessionalTVShowLoadingIndicator(message: 'Loading TV Show...'),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildProfessionalAppBar() {
  //   return Container(
  //     padding: EdgeInsets.only(
  //       top: MediaQuery.of(context).padding.top + 10,
  //       left: 20,
  //       right: 20,
  //       bottom: 20,
  //     ),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topCenter,
  //         end: Alignment.bottomCenter,
  //         colors: [
  //           ProfessionalColors.surfaceDark.withOpacity(0.9),
  //           ProfessionalColors.surfaceDark.withOpacity(0.7),
  //           Colors.transparent,
  //         ],
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             gradient: LinearGradient(
  //               colors: [
  //                 ProfessionalColors.accentGreen.withOpacity(0.2),
  //                 ProfessionalColors.accentBlue.withOpacity(0.2),
  //               ],
  //             ),
  //           ),
  //           child: IconButton(
  //             icon: const Icon(
  //               Icons.arrow_back_rounded,
  //               color: Colors.white,
  //               size: 24,
  //             ),
  //             onPressed: () => Navigator.pop(context),
  //           ),
  //         ),
  //         const SizedBox(width: 16),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               ShaderMask(
  //                 shaderCallback: (bounds) => const LinearGradient(
  //                   colors: [
  //                     ProfessionalColors.accentGreen,
  //                     ProfessionalColors.accentBlue,
  //                   ],
  //                 ).createShader(bounds),
  //                 child: Text(
  //                   widget.channelName,
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 24,
  //                     fontWeight: FontWeight.w700,
  //                     letterSpacing: 1.0,
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 4),
  //               Row(
  //                 children: [
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  //                     decoration: BoxDecoration(
  //                       gradient: LinearGradient(
  //                         colors: [
  //                           ProfessionalColors.accentGreen.withOpacity(0.2),
  //                           ProfessionalColors.accentBlue.withOpacity(0.1),
  //                         ],
  //                       ),
  //                       borderRadius: BorderRadius.circular(15),
  //                       border: Border.all(
  //                         color: ProfessionalColors.accentGreen.withOpacity(0.3),
  //                         width: 1,
  //                       ),
  //                     ),
  //                     child: Text(
  //                       '${tvShowsList.length} Shows Available',
  //                       style: const TextStyle(
  //                         color: ProfessionalColors.accentGreen,
  //                         fontSize: 12,
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                   ),
  //                   if (isRefreshing) ...[
  //                     const SizedBox(width: 8),
  //                     Container(
  //                       width: 16,
  //                       height: 16,
  //                       child: const CircularProgressIndicator(
  //                         strokeWidth: 2,
  //                         valueColor: AlwaysStoppedAnimation<Color>(
  //                           ProfessionalColors.accentBlue,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //         // Refresh button
  //         Container(
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             gradient: LinearGradient(
  //               colors: [
  //                 ProfessionalColors.accentBlue.withOpacity(0.2),
  //                 ProfessionalColors.accentPurple.withOpacity(0.2),
  //               ],
  //             ),
  //           ),
  //           child: IconButton(
  //             icon: Icon(
  //               Icons.refresh_rounded,
  //               color: isRefreshing ? ProfessionalColors.accentBlue : Colors.white,
  //               size: 20,
  //             ),
  //             onPressed: isRefreshing ? null : _manualRefresh,
  //           ),
  //         ),
  //         const SizedBox(width: 8),
  //         if (widget.channelLogo != null)
  //           Container(
  //             width: 50,
  //             height: 50,
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(25),
  //               border: Border.all(
  //                 color: ProfessionalColors.accentGreen.withOpacity(0.3),
  //                 width: 2,
  //               ),
  //             ),
  //             child: ClipRRect(
  //               borderRadius: BorderRadius.circular(23),
  //               child: Image.network(
  //                 widget.channelLogo!,
  //                 fit: BoxFit.cover,
  //                 errorBuilder: (context, error, stackTrace) => Container(
  //                   decoration: const BoxDecoration(
  //                     gradient: LinearGradient(
  //                       colors: [
  //                         ProfessionalColors.accentGreen,
  //                         ProfessionalColors.accentBlue,
  //                       ],
  //                     ),
  //                   ),
  //                   child: const Icon(
  //                     Icons.live_tv,
  //                     color: Colors.white,
  //                     size: 24,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }



//   // Enhanced AppBar method for HorizontalListDetailsPage
// Widget _buildProfessionalAppBar() {
//   return Container(
//     // ✅ Enhanced AppBar with proper z-index and blur effect
//     decoration: BoxDecoration(
//       gradient: LinearGradient(
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//         colors: [
//           ProfessionalColors.primaryDark.withOpacity(0.95), // More opaque
//           ProfessionalColors.surfaceDark.withOpacity(0.9),
//           ProfessionalColors.surfaceDark.withOpacity(0.8),
//           Colors.transparent,
//         ],
//       ),
//       // ✅ Add bottom border for better separation
//       border: Border(
//         bottom: BorderSide(
//           color: ProfessionalColors.accentGreen.withOpacity(0.2),
//           width: 1,
//         ),
//       ),
//       // ✅ Add subtle shadow
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.3),
//           blurRadius: 10,
//           offset: const Offset(0, 2),
//         ),
//       ],
//     ),
//     child: ClipRRect(
//       child: BackdropFilter(
//         // ✅ Add blur effect for modern look
//         filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
//         child: Container(
//           padding: EdgeInsets.only(
//             top: MediaQuery.of(context).padding.top + 20,
//             left: 40,
//             right: 40,
//             bottom: 15, // Add bottom padding
//           ),
//           child: Row(
//             children: [
//               // ✅ Enhanced Back Button
//               Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors: [
//                       ProfessionalColors.accentGreen.withOpacity(0.3),
//                       ProfessionalColors.accentBlue.withOpacity(0.3),
//                     ],
//                   ),
//                   // ✅ Add elevation to back button
//                   boxShadow: [
//                     BoxShadow(
//                       color: ProfessionalColors.accentGreen.withOpacity(0.3),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.arrow_back_rounded,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ),
//               const SizedBox(width: 16),
              
//               // ✅ Enhanced Title Section
//               Expanded(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Left side - Channel info
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // ✅ Enhanced title with better shadow
//                           ShaderMask(
//                             shaderCallback: (bounds) => const LinearGradient(
//                               colors: [
//                                 ProfessionalColors.accentGreen,
//                                 ProfessionalColors.accentBlue,
//                               ],
//                             ).createShader(bounds),
//                             child: Text(
//                               widget.channelName,
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.w700,
//                                 letterSpacing: 1.0,
//                                 shadows: [
//                                   Shadow(
//                                     color: Colors.black.withOpacity(0.5),
//                                     blurRadius: 4,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           // ✅ Enhanced subtitle with status indicators
//                           Row(
//                             children: [
//                               // Shows count badge
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: [
//                                       ProfessionalColors.accentGreen.withOpacity(0.3),
//                                       ProfessionalColors.accentBlue.withOpacity(0.2),
//                                     ],
//                                   ),
//                                   borderRadius: BorderRadius.circular(15),
//                                   border: Border.all(
//                                     color: ProfessionalColors.accentGreen.withOpacity(0.4),
//                                     width: 1,
//                                   ),
//                                   // ✅ Add elevation to count badge
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: ProfessionalColors.accentGreen.withOpacity(0.2),
//                                       blurRadius: 6,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Text(
//                                   '${tvShowsList.length} Shows Available',
//                                   style: const TextStyle(
//                                     color: ProfessionalColors.accentGreen,
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                     shadows: [
//                                       Shadow(
//                                         color: Colors.black54,
//                                         blurRadius: 2,
//                                         offset: Offset(0, 1),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
                              
//                               // ✅ Refresh status indicator
//                               if (isRefreshing) ...[
//                                 const SizedBox(width: 8),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                   decoration: BoxDecoration(
//                                     color: ProfessionalColors.accentBlue.withOpacity(0.2),
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: Border.all(
//                                       color: ProfessionalColors.accentBlue.withOpacity(0.3),
//                                       width: 1,
//                                     ),
//                                   ),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       SizedBox(
//                                         width: 12,
//                                         height: 12,
//                                         child: CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                           valueColor: AlwaysStoppedAnimation<Color>(
//                                             ProfessionalColors.accentBlue,
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(width: 6),
//                                       const Text(
//                                         'Updating...',
//                                         style: TextStyle(
//                                           color: ProfessionalColors.accentBlue,
//                                           fontSize: 10,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
                    
//                     // Right side - Action buttons and logo
//                     Row(
//                       children: [
//                         // ✅ Enhanced Refresh button
//                         Container(
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             gradient: LinearGradient(
//                               colors: [
//                                 ProfessionalColors.accentBlue.withOpacity(0.3),
//                                 ProfessionalColors.accentPurple.withOpacity(0.3),
//                               ],
//                             ),
//                             // ✅ Add elevation to refresh button
//                             boxShadow: [
//                               BoxShadow(
//                                 color: ProfessionalColors.accentBlue.withOpacity(0.3),
//                                 blurRadius: 6,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: IconButton(
//                             icon: Icon(
//                               Icons.refresh_rounded,
//                               color: isRefreshing 
//                                   ? ProfessionalColors.accentBlue 
//                                   : Colors.white,
//                               size: 20,
//                             ),
//                             onPressed: isRefreshing ? null : _manualRefresh,
//                             tooltip: 'Refresh Shows',
//                           ),
//                         ),
                        
//                         const SizedBox(width: 12),
                        
//                         // ✅ Enhanced Channel Logo
//                         if (widget.channelLogo != null)
//                           Container(
//                             width: 55,
//                             height: 55,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(27.5),
//                               border: Border.all(
//                                 color: ProfessionalColors.accentGreen.withOpacity(0.4),
//                                 width: 2,
//                               ),
//                               // ✅ Add elevation to logo
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: ProfessionalColors.accentGreen.withOpacity(0.3),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 3),
//                                 ),
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.2),
//                                   blurRadius: 4,
//                                   offset: const Offset(0, 1),
//                                 ),
//                               ],
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(25.5),
//                               child: Image.network(
//                                 widget.channelLogo!,
//                                 fit: BoxFit.cover,
//                                 loadingBuilder: (context, child, loadingProgress) {
//                                   if (loadingProgress == null) return child;
//                                   return Container(
//                                     decoration: const BoxDecoration(
//                                       gradient: LinearGradient(
//                                         colors: [
//                                           ProfessionalColors.accentGreen,
//                                           ProfessionalColors.accentBlue,
//                                         ],
//                                       ),
//                                     ),
//                                     child: Center(
//                                       child: SizedBox(
//                                         width: 16,
//                                         height: 16,
//                                         child: CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                           valueColor: AlwaysStoppedAnimation<Color>(
//                                             Colors.white,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 errorBuilder: (context, error, stackTrace) => Container(
//                                   decoration: const BoxDecoration(
//                                     gradient: LinearGradient(
//                                       colors: [
//                                         ProfessionalColors.accentGreen,
//                                         ProfessionalColors.accentBlue,
//                                       ],
//                                     ),
//                                   ),
//                                   child: const Icon(
//                                     Icons.live_tv,
//                                     color: Colors.white,
//                                     size: 24,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

  Widget _buildTVShowsGrid() {
    if (isLoading && tvShowsList.isEmpty) {
      return const ProfessionalTVShowLoadingIndicator(
        message: 'Loading Vod...',
      );
    } else if (errorMessage != null && tvShowsList.isEmpty) {
      return _buildErrorWidget();
    } else if (tvShowsList.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildProfessionalGridView();
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
              Icons.error_outline,
              size: 40,
              color: ProfessionalColors.accentRed,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Error Loading Vod',
            style: TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Unknown error occurred',
            style: const TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _manualRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: ProfessionalColors.accentGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white),
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
                  ProfessionalColors.accentGreen.withOpacity(0.2),
                  ProfessionalColors.accentGreen.withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.live_tv_outlined,
              size: 40,
              color: ProfessionalColors.accentGreen,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Shows Found for ${widget.channelName}',
            style: const TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for new shows',
            style: TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalGridView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: tvShowsList.length,
        clipBehavior: Clip.none,
        itemBuilder: (context, index) {
          final tvShow = tvShowsList[index];
          String tvShowId = tvShow.id.toString();

          // ✅ Safe check for focus node existence - Similar to MoviesGridView
          if (!_tvShowFocusNodes.containsKey(tvShowId)) {
            print('⚠️ Focus node not found for TV show: $tvShowId');
            return const SizedBox.shrink(); // Return empty widget if focus node missing
          }

          FocusNode focusNode = _tvShowFocusNodes[tvShowId]!;

          return AnimatedBuilder(
            animation: _staggerController,
            builder: (context, child) {
              final delay = (index / tvShowsList.length) * 0.5;
              final animationValue = Interval(
                delay,
                delay + 0.5,
                curve: Curves.easeOutCubic,
              ).transform(_staggerController.value);

              return Transform.translate(
                offset: Offset(0, 50 * (1 - animationValue)),
                child: Opacity(
                  opacity: animationValue,
                  child: ProfessionalTVShowCard(
                    tvShow: tvShow,
                    focusNode: focusNode,
                    onTap: () => _handleTVShowTap(tvShow),
                    index: index,
                    channelName: widget.channelName,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Dispose animation controllers
        try {
      _socketService.dispose();
    } catch (e) {}
    _fadeController.dispose();
    _staggerController.dispose();
    _headerController.dispose();
    _scrollController.dispose();
    _socketService.dispose();
    
    // ✅ FIXED: Safely dispose all focus nodes - Similar to MoviesGridView
    for (var entry in _tvShowFocusNodes.entries) {
      try {
        entry.value.removeListener(() {});
        entry.value.dispose();
        print('✅ Disposed focus node: ${entry.key}');
      } catch (e) {
        print('⚠️ Error disposing focus node ${entry.key}: $e');
      }
    }
    _tvShowFocusNodes.clear();
    
    super.dispose();
  }
}

// ✅ FIXED: Professional TV Show Card with Proper Focus Management
class ProfessionalTVShowCard extends StatefulWidget {
  final TVShowDetailsModel tvShow;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int index;
  final String channelName;

  const ProfessionalTVShowCard({
    Key? key,
    required this.tvShow,
    required this.focusNode,
    required this.onTap,
    required this.index,
    required this.channelName,
  }) : super(key: key);

  @override
  _ProfessionalTVShowCardState createState() => _ProfessionalTVShowCardState();
}

class _ProfessionalTVShowCardState extends State<ProfessionalTVShowCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  Color _dominantColor = ProfessionalColors.accentGreen;
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
    if (!mounted) return;
    
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
          // ✅ Arrow key navigation similar to MoviesGridView
          else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            // Find next TV show focus node
            final currentIndex = widget.index;
            final parent = context.findAncestorStateOfType<_HorizontalListDetailsPageState>();
            if (parent != null && currentIndex < parent.tvShowsList.length - 1) {
              final nextTvShowId = parent.tvShowsList[currentIndex + 1].id.toString();
              if (parent._tvShowFocusNodes.containsKey(nextTvShowId)) {
                FocusScope.of(context).requestFocus(parent._tvShowFocusNodes[nextTvShowId]);
                return KeyEventResult.handled;
              }
            }
          }
          else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            // Find previous TV show focus node
            final currentIndex = widget.index;
            final parent = context.findAncestorStateOfType<_HorizontalListDetailsPageState>();
            if (parent != null && currentIndex > 0) {
              final prevTvShowId = parent.tvShowsList[currentIndex - 1].id.toString();
              if (parent._tvShowFocusNodes.containsKey(prevTvShowId)) {
                FocusScope.of(context).requestFocus(parent._tvShowFocusNodes[prevTvShowId]);
                return KeyEventResult.handled;
              }
            }
          }
          else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Find TV show above (6 columns grid)
            final currentIndex = widget.index;
            final parent = context.findAncestorStateOfType<_HorizontalListDetailsPageState>();
            if (parent != null && currentIndex >= 6) {
              final aboveTvShowId = parent.tvShowsList[currentIndex - 6].id.toString();
              if (parent._tvShowFocusNodes.containsKey(aboveTvShowId)) {
                FocusScope.of(context).requestFocus(parent._tvShowFocusNodes[aboveTvShowId]);
                return KeyEventResult.handled;
              }
            }
          }
          else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Find TV show below (6 columns grid)
            final currentIndex = widget.index;
            final parent = context.findAncestorStateOfType<_HorizontalListDetailsPageState>();
            if (parent != null && currentIndex + 6 < parent.tvShowsList.length) {
              final belowTvShowId = parent.tvShowsList[currentIndex + 6].id.toString();
              if (parent._tvShowFocusNodes.containsKey(belowTvShowId)) {
                FocusScope.of(context).requestFocus(parent._tvShowFocusNodes[belowTvShowId]);
                return KeyEventResult.handled;
              }
            }
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
                      _buildTVShowImage(),
                      if (_isFocused) _buildFocusBorder(),
                      _buildGradientOverlay(),
                      _buildTVShowInfo(),
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

  Widget _buildTVShowImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: widget.tvShow.banner != null && widget.tvShow.banner!.isNotEmpty
          ? Image.network(
              widget.tvShow.banner!,
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
              Icons.live_tv_outlined,
              size: 40,
              color: ProfessionalColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              widget.channelName.toUpperCase(),
              style: TextStyle(
                color: ProfessionalColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: ProfessionalColors.accentGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'HD',
                style: TextStyle(
                  color: ProfessionalColors.accentGreen,
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

  Widget _buildTVShowInfo() {
    final tvShowName = widget.tvShow.name;

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
              tvShowName.toUpperCase(),
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
            if (_isFocused && widget.tvShow.genre != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ProfessionalColors.accentGreen.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ProfessionalColors.accentGreen.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.tvShow.genre!.split(',').first.toUpperCase(),
                      style: const TextStyle(
                        color: ProfessionalColors.accentGreen,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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


