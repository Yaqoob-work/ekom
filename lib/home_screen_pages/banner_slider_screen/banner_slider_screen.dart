// banner_slider1
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/provider/shared_data_provider.dart';
import 'package:mobi_tv_entertainment/video_widget/socket_service.dart';
import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart';
import 'package:mobi_tv_entertainment/widgets/utils/color_service.dart';
import 'package:mobi_tv_entertainment/widgets/utils/random_light_color_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enhanced function to get auth headers with dynamic auth key
Future<Map<String, String>> getAuthHeaders() async {
  String authKey = '';

  // Try to get from AuthManager first (if available)
  try {
    if (AuthManager.hasValidAuthKey) {
      authKey = AuthManager.authKey;
    }
  } catch (e) {}

  // Fallback to global variable
  if (authKey.isEmpty && globalAuthKey.isNotEmpty) {
    authKey = globalAuthKey;
  }

  // Last resort: get from SharedPreferences
  if (authKey.isEmpty) {
    try {
      final prefs = await SharedPreferences.getInstance();
      authKey = prefs.getString('auth_key') ?? '';
      if (authKey.isNotEmpty) {
        // Update global variable for next time
        globalAuthKey = authKey;
      }
    } catch (e) {}
  }

  if (authKey.isEmpty) {
    authKey = 'vLQTuPZUxktl5mVW'; // Fallback key
  }

  return {
    'auth-key': authKey, // Primary auth header
    'x-api-key': authKey, // Fallback for compatibility
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'User-Agent': 'MobiTV/1.0',
  };
}

// API configuration with multiple endpoints
class ApiConfig {
  static const String PRIMARY_BASE_URL =
      'https://acomtv.coretechinfo.com/public/api';
  static const String SECONDARY_BASE_URL =
      'https://acomtv.coretechinfo.com/api';
  static const String FALLBACK_BASE_URL = 'https://api.ekomflix.com/android';

  static const List<String> FEATURED_TV_ENDPOINTS = [
    '$PRIMARY_BASE_URL/getCustomImageSlider',
    '$SECONDARY_BASE_URL/getCustomImageSlider',
    '$FALLBACK_BASE_URL/getCustomImageSlider',
  ];

  static const List<String> BANNER_ENDPOINTS = [
    '$PRIMARY_BASE_URL/getCustomImageSlider',
    '$SECONDARY_BASE_URL/getCustomImageSlider',
    '$FALLBACK_BASE_URL/getCustomImageSlider',
  ];
}

// Enhanced fetchLiveFeaturedTVById with multiple endpoint support
Future<Map<String, String>> fetchVideoDataByIdFromBanners(
    String contentId) async {
  final prefs = await SharedPreferences.getInstance();
  final cachedData = prefs.getString('live_featured_tv');

  List<dynamic> responseData;

  try {
    // Use cached data if available
    if (cachedData != null) {
      responseData = json.decode(cachedData);
    } else {
      // Try multiple API endpoints with auth key
      Map<String, String> headers = await getAuthHeaders();
      bool success = false;
      String responseBody = '';

      for (int i = 0; i < ApiConfig.FEATURED_TV_ENDPOINTS.length; i++) {
        String endpoint = ApiConfig.FEATURED_TV_ENDPOINTS[i];

        try {
          Map<String, String> currentHeaders = Map.from(headers);

          // For fallback endpoint, use old header format
          if (endpoint.contains('api.ekomflix.com')) {
            currentHeaders = {
              'x-api-key': 'vLQTuPZUxktl5mVW',
              'Accept': 'application/json',
            };
          }

          final response = await https
              .get(
                Uri.parse(endpoint),
                headers: currentHeaders,
              )
              .timeout(Duration(seconds: 15));

          if (response.statusCode == 200) {
            String body = response.body.trim();
            if (body.startsWith('[') || body.startsWith('{')) {
              try {
                json.decode(body); // Validate JSON
                responseBody = body;
                success = true;
                break;
              } catch (e) {
                continue;
              }
            } else {
              continue;
            }
          } else {
            continue;
          }
        } catch (e) {
          continue;
        }
      }

      if (!success) {
        throw Exception('Failed to load featured live TV from all endpoints');
      }

      responseData = json.decode(responseBody);
      // Cache the successful response
      await prefs.setString('live_featured_tv', responseBody);
    }

    // Find the matched item by id
    final matchedItem = responseData.firstWhere(
      (channel) => channel['id'].toString() == contentId,
      orElse: () => null,
    );

    if (matchedItem == null) {
      throw Exception('Content with ID $contentId not found');
    }

    return {
      'url': matchedItem['url'] ?? '',
      'type': matchedItem['type'] ?? '',
      'banner': matchedItem['banner'] ?? '',
      'name': matchedItem['name'] ?? '',
      'stream_type': matchedItem['stream_type'] ?? '',
    };
  } catch (e) {
    throw Exception('Something went wrong: $e');
  }
}

// Enhanced fetch banners function
Future<List<dynamic>> fetchBannersData() async {
  Map<String, String> headers = await getAuthHeaders();
  bool success = false;
  String responseBody = '';

  for (int i = 0; i < ApiConfig.BANNER_ENDPOINTS.length; i++) {
    String endpoint = ApiConfig.BANNER_ENDPOINTS[i];

    try {
      Map<String, String> currentHeaders = Map.from(headers);

      // For fallback endpoint, use old header format
      if (endpoint.contains('api.ekomflix.com')) {
        currentHeaders = {
          'x-api-key': 'vLQTuPZUxktl5mVW',
          'Accept': 'application/json',
        };
      }

      final response = await https
          .get(
            Uri.parse(endpoint),
            headers: currentHeaders,
          )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        String body = response.body.trim();
        if (body.startsWith('[') || body.startsWith('{')) {
          try {
            json.decode(body); // Validate JSON
            responseBody = body;
            success = true;
            break;
          } catch (e) {
            continue;
          }
        } else {
          continue;
        }
      } else {
        continue;
      }
    } catch (e) {
      continue;
    }
  }

  if (!success) {
    throw Exception('Failed to load banners from all endpoints');
  }

  final List<dynamic> responseData = json.decode(responseBody);

  return responseData;
}

// // Global Event Bus for refresh events
// class GlobalEventBus {
//   static final StreamController<RefreshPageEvent> _eventBus =
//       StreamController<RefreshPageEvent>.broadcast();

//   static Stream<RefreshPageEvent> get eventBus => _eventBus.stream;

//   static void fire(RefreshPageEvent event) {
//     _eventBus.add(event);
//   }

//   static void dispose() {
//     _eventBus.close();
//   }
// }

class GlobalEventBus {
  static final GlobalEventBus _instance = GlobalEventBus._internal();
  factory GlobalEventBus() => _instance;

  final StreamController<RefreshPageEvent> _controller =
      StreamController<RefreshPageEvent>.broadcast();

  GlobalEventBus._internal();

  Stream<RefreshPageEvent> get events => _controller.stream;
  void fire(RefreshPageEvent event) => _controller.add(event);
  void dispose() => _controller.close();
}

class RefreshPageEvent {
  final String pageId;

  RefreshPageEvent(this.pageId);
}

class BannerSlider extends StatefulWidget {
  final Function(bool)? onFocusChange;
  const BannerSlider(
      {Key? key, this.onFocusChange, required FocusNode focusNode})
      : super(key: key);
  @override
  _BannerSliderState createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  // State variables
  List<Map<String, dynamic>> lastPlayedVideos = [];
  late SharedDataProvider sharedDataProvider;
  final SocketService _socketService = SocketService();
  List<NewsItemModel> bannerList = [];
  Map<String, Color> bannerColors = {};
  bool isLoading = true;
  String errorMessage = '';
  late PageController _pageController;
  late Timer _timer;
  String? selectedContentId;
  final FocusNode _buttonFocusNode = FocusNode();
  bool _isNavigating = false;
  final int _maxRetries = 3;
  final int _retryDelay = 5;
  final PaletteColorService _paletteColorService = PaletteColorService();
  // late StreamSubscription refreshSubscription;
  Key refreshKey = UniqueKey();
  late ScrollController _lastPlayedScrollController;
  double _itemWidth = 0;

  // Image caching
  Map<String, Uint8List> _bannerCache = {};
  late FocusProvider _refreshProvider;

  @override
  void initState() {
    super.initState();
    _initializeSlider();
  }

  Future<void> _initializeSlider() async {
    _lastPlayedScrollController = ScrollController();
    sharedDataProvider = context.read<SharedDataProvider>();

    // Initialize socket service
    _socketService.initSocket();
    _pageController = PageController();

    // Set up focus listeners
    _buttonFocusNode.addListener(() {
      if (_buttonFocusNode.hasFocus) {
        widget.onFocusChange?.call(true);
      }
    });

    // Post frame callback setup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sharedDataProvider.updateLastPlayedVideos(lastPlayedVideos);
      context.read<FocusProvider>().setWatchNowFocusNode(_buttonFocusNode);

      if (lastPlayedVideos.isNotEmpty) {
        final firstBannerFocusNode =
            lastPlayedVideos[0]['focusNode'] as FocusNode;
        context
            .read<FocusProvider>()
            .setFirstLastPlayedFocusNode(firstBannerFocusNode);
      }
    });

    _buttonFocusNode.addListener(_onButtonFocusNode);

    // Load data
    await _loadLastPlayedVideos();
    await _loadCachedData();

    if (bannerList.isNotEmpty) {
      _startAutoSlide();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Provider ko listen karo
    _refreshProvider = context.watch<FocusProvider>();

    // Check if refresh is needed
    if (_refreshProvider.shouldRefreshBanners ||
        _refreshProvider.shouldRefreshLastPlayed) {
      _handleProviderRefresh();
    }
  }

  Future<void> _handleProviderRefresh() async {
    if (!mounted) return;

    try {
      if (_refreshProvider.shouldRefreshBanners) {
        await fetchBanners(isBackgroundFetch: true);
        _refreshProvider.markBannersRefreshed();
      }

      if (_refreshProvider.shouldRefreshLastPlayed) {
        await _loadLastPlayedVideos();
        _refreshProvider.markLastPlayedRefreshed();

        // UI refresh ke liye
        if (mounted) {
          setState(() {
            refreshKey = UniqueKey();
          });
        }
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    // Unregister focus elements
    for (int i = 0; i < lastPlayedVideos.length; i++) {
      context.read<FocusProvider>().unregisterElementKey('lastPlayed_$i');
    }

    // Dispose controllers and subscriptions
    _lastPlayedScrollController.dispose();
    _pageController.dispose();
    _socketService.dispose();

    if (_timer.isActive) {
      _timer.cancel();
    }

    _buttonFocusNode.dispose();

    super.dispose();
  }

  // Fetch banner colors for UI enhancement
  Future<void> _fetchBannerColors() async {
    for (var banner in bannerList) {
      try {
        final imageUrl = banner.banner;
        final secondaryColor =
            await _paletteColorService.getSecondaryColor(imageUrl);

        if (mounted) {
          setState(() {
            bannerColors[banner.contentId] = secondaryColor;
          });
        }
      } catch (e) {}
    }
  }

  // Auto slide functionality
  void _startAutoSlide() {
    if (bannerList.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        try {
          if (_pageController.hasClients) {
            if (_pageController.page == bannerList.length - 1) {
              _pageController.jumpToPage(0); // Jump to first page
            } else {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            }
          }
        } catch (e) {}
      });
    }
  }

  // YouTube URL detection
  bool isYoutubeUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }

    url = url.toLowerCase().trim();

    // Check if it's a YouTube ID (exactly 11 characters)
    bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url);
    if (isYoutubeId) {
      return true;
    }

    // Check for regular YouTube URLs
    bool isYoutubeUrl = url.contains('youtube.com') ||
        url.contains('youtu.be') ||
        url.contains('youtube.com/shorts/');

    return isYoutubeUrl;
  }

  // Format URL utility
  String formatUrl(String url, {Map<String, String>? params}) {
    if (url.isEmpty) {
      throw Exception("Empty URL provided");
    }

    // // Handle YouTube ID by converting to full URL if needed
    // if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url)) {
    //   url = "https://www.youtube.com/watch?v=$url";
    // }

    // Remove any existing query parameters
    // url = url.split('?')[0];

    // Add new query parameters
    // if (params != null && params.isNotEmpty) {
    //   url += '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&');
    // }

    return url;
  }

  // Button focus handling
  void _onButtonFocusNode() {
    if (_buttonFocusNode.hasFocus) {
      final random = Random();
      final color = Color.fromRGBO(
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
        1,
      );
      context.read<FocusProvider>().setButtonFocus(true, color: color);
      context.read<ColorProvider>().updateColor(color, true);
    } else {
      context.read<FocusProvider>().resetFocus();
      context.read<ColorProvider>().resetColor();
    }
  }

  // Banner Slider Debug Fix - fetchBanners method update

  // Update this method in your banner_slider.dart
  Future<void> fetchBanners({bool isBackgroundFetch = false}) async {
    if (!isBackgroundFetch) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedBanners = prefs.getString('banners');

      // Fetch data from API
      final List<dynamic> responseData = await fetchBannersData();

      // DEBUG: Print raw API response
      for (int i = 0; i < responseData.length; i++) {
        final item = responseData[i];
      }

      // Check if API response is different from cached data
      if (cachedBanners != null) {
        try {
          final cachedData = json.decode(cachedBanners);
          if (json.encode(cachedData) == json.encode(responseData)) {
            return;
          }
        } catch (e) {}
      }

      // Process and update banner data with better filtering
      List<NewsItemModel> filteredBanners = [];

      for (var banner in responseData) {
        try {
          // Check multiple status formats
          bool isActive = false;

          if (banner['status'] != null) {
            var status = banner['status'];

            // Handle different status formats
            if (status is String) {
              isActive = status == "1" ||
                  status.toLowerCase() == "active" ||
                  status.toLowerCase() == "true";
            } else if (status is int) {
              isActive = status == 1;
            } else if (status is bool) {
              isActive = status;
            }
          } else {
            // If no status field, consider it active
            isActive = true;
          }

          if (isActive) {
            try {
              final newsItem = NewsItemModel.fromJson(banner);
              filteredBanners.add(newsItem);
            } catch (e) {}
          } else {}
        } catch (e) {}
      }

      setState(() {
        bannerList = filteredBanners;
        selectedContentId = bannerList.isNotEmpty ? bannerList[0].id : null;
        isLoading = false;
        errorMessage = '';
      });

      // Cache the data
      await prefs.setString('banners', json.encode(responseData));

      // Debug: Print final banner list
      for (int i = 0; i < bannerList.length; i++) {
        final banner = bannerList[i];
      }

      // Fetch colors and start auto slide
      if (bannerList.isNotEmpty) {
        await _fetchBannerColors();
        if (!_timer.isActive) {
          _startAutoSlide();
        }
      } else {}
    } catch (e) {
      if (!isBackgroundFetch) {
        setState(() {
          errorMessage = 'Failed to load banners: $e';
          isLoading = false;
        });
      }
    }
  }

  // Also update _loadCachedData method for consistency
  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedBanners = prefs.getString('banners');

    if (cachedBanners != null) {
      try {
        final List<dynamic> responseData = json.decode(cachedBanners);

        // Use same filtering logic as fetchBanners
        List<NewsItemModel> filteredBanners = [];

        for (var banner in responseData) {
          try {
            bool isActive = false;

            if (banner['status'] != null) {
              var status = banner['status'];

              if (status is String) {
                isActive = status == "1" ||
                    status.toLowerCase() == "active" ||
                    status.toLowerCase() == "true";
              } else if (status is int) {
                isActive = status == 1;
              } else if (status is bool) {
                isActive = status;
              }
            } else {
              isActive = true;
            }

            if (isActive) {
              try {
                final newsItem = NewsItemModel.fromJson(banner);
                filteredBanners.add(newsItem);
              } catch (e) {}
            }
          } catch (e) {}
        }

        setState(() {
          bannerList = filteredBanners;
          selectedContentId = bannerList.isNotEmpty ? bannerList[0].id : null;
          isLoading = false;
        });

        if (bannerList.isNotEmpty) {
          await _fetchBannerColors();
        }
      } catch (e) {
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }

    // Fetch fresh data in background
    fetchBanners(isBackgroundFetch: true);
  }

  // Enhanced video fetching and playing
  Future<void> fetchAndPlayVideo(
      String contentId, List<NewsItemModel> channelList) async {
    if (_isNavigating) {
      return;
    }

    _isNavigating = true;

    bool shouldPlayVideo = true;
    bool shouldPop = true;

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async {
              shouldPlayVideo = false;
              shouldPop = false;
              return true;
            },
            child: Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SpinKitFadingCircle(
                      color: borderColor,
                      size: 50.0,
                    ),
                    SizedBox(height: 15),
                    Text(
                      '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: nametextsz,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      // Fetch video data with enhanced error handling
      final responseData = await fetchVideoDataByIdFromBanners(contentId);

      if (responseData['url'] == null || responseData['url']?.isEmpty == true) {
        throw Exception('Invalid video URL received');
      }

      String originalUrl = responseData['url']!;
      String videoUrl = responseData['url']!;
      String videoType = responseData['type'] ?? '';
      String streamType = responseData['stream_type'] ?? '';

      // Handle YouTube videos with retries
      bool isYoutube = videoType.toLowerCase() == 'youtube' ||
          streamType.toLowerCase() == 'youtubelive' ||
          isYoutubeUrl(originalUrl);

      if (isYoutube) {
        for (int i = 0; i < _maxRetries; i++) {
          try {
            videoUrl = await _socketService.getUpdatedUrl(videoUrl);

            if (videoUrl.isEmpty) {
              throw Exception('Empty URL returned from socket service');
            }

            break;
          } catch (e) {
            if (i == _maxRetries - 1) {
              throw Exception(
                  'Failed to get updated YouTube URL after $_maxRetries attempts');
            }

            await Future.delayed(Duration(seconds: _retryDelay));
          }
        }
      }

      // Determine live status
      bool liveStatus = isYoutube || streamType.toLowerCase() == 'youtubelive';

      // Close loading dialog
      if (shouldPop && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Navigate to video screen
      if (shouldPlayVideo && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoScreen(
              videoUrl: videoUrl,
              channelList: channelList,
              videoId: int.tryParse(contentId) ?? 0,
              videoType: videoType,
              isLive: liveStatus,
              isVOD: false,
              bannerImageUrl: responseData['banner'] ?? '',
              startAtPosition: Duration.zero,
              isBannerSlider: true,
              source: 'isBannerSlider',
              isSearch: false,
              unUpdatedUrl: originalUrl,
              name: responseData['name'] ?? 'Unknown',
              liveStatus: liveStatus,
              seasonId: null,
              isLastPlayedStored: false,
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (shouldPop && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      _isNavigating = false;
    }
  }

  // Scroll to focused item in continue watching section
  void _scrollToFocusedItem(int index) {
    if (!_lastPlayedScrollController.hasClients) return;

    _itemWidth = screenwdt * 0.15 + 10;
    double targetOffset = index * _itemWidth;
    double currentOffset = _lastPlayedScrollController.offset;
    double viewportWidth =
        _lastPlayedScrollController.position.viewportDimension;

    if (targetOffset < currentOffset ||
        targetOffset + _itemWidth > currentOffset + viewportWidth) {
      _lastPlayedScrollController.animateTo(
        targetOffset,
        duration: Duration(milliseconds: 1000),
        curve: Curves.linear,
      );
    }
  }

// Image caching for base64 images (continued)
  Uint8List _getCachedImage(String base64String) {
    try {
      if (!_bannerCache.containsKey(base64String)) {
        // Decode only the base64 content after "data:image/..." prefix
        final base64Content = base64String.split(',').last;
        _bannerCache[base64String] = base64Decode(base64Content);
      }
      return _bannerCache[base64String]!;
    } catch (e) {
      // Return a 1x1 transparent pixel as fallback
      return Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG header
        0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
        0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1 dimensions
        0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, // 8-bit RGB
        0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41, // IDAT chunk
        0x54, 0x78, 0x01, 0x63, 0x00, 0x01, 0x00, 0x05, // Compressed data
        0x00, 0x01, 0xE2, 0x26, 0x05, 0x9B, 0x00, 0x00, // Checksum
        0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, // IEND chunk
        0x60, 0x82
      ]);
    }
  }

  // Check if URL is a live video
  bool isLiveVideoUrl(String url) {
    String lowerUrl = url.toLowerCase().trim();

    if (RegExp(r'^[a-zA-Z0-9_-]{10,15}$').hasMatch(lowerUrl)) {
      return false; // Custom IDs are typically not live
    }

    if (!lowerUrl.startsWith('http://') && !lowerUrl.startsWith('https://')) {
      return false; // Invalid URL format
    }

    // Check for live stream indicators
    if (lowerUrl.contains(".m3u8") ||
        lowerUrl.contains("live") ||
        lowerUrl.contains("stream") ||
        lowerUrl.contains("broadcast") ||
        lowerUrl.contains("playlist")) {
      return true;
    }

    // Check for video file extensions (typically not live)
    List<String> videoExtensions = [".mp4", ".mov", ".avi", ".flv", ".mkv"];
    for (String ext in videoExtensions) {
      if (lowerUrl.endsWith(ext)) {
        return false;
      }
    }

    return false;
  }

  // Check live status for multiple URLs
  List<bool> checkLiveVideoList(List<String> urls) {
    return urls.map(isYoutubeUrl).toList();
  }

  // Build progress display for videos
  Widget _buildProgressDisplay(Map<String, dynamic> videoData, bool hasFocus) {
    Duration totalDuration = videoData['duration'] ?? Duration.zero;
    Duration currentPosition = videoData['position'] ?? Duration.zero;
    String url = videoData['videoUrl'] ?? '';
    bool liveStatus = videoData['liveStatus'] ?? false;

    double playedProgress = (totalDuration.inMilliseconds > 0)
        ? (currentPosition.inMilliseconds / totalDuration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String hours =
          duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : '';
      String minutes = twoDigits(duration.inMinutes.remainder(60));
      String seconds = twoDigits(duration.inSeconds.remainder(60));
      return '$hours$minutes:$seconds';
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: hasFocus
                ? const Color.fromARGB(200, 16, 62, 99)
                : Colors.transparent,
            borderRadius: hasFocus ? BorderRadius.circular(4.0) : null,
          ),
          child: Stack(
            children: [
              LinearProgressIndicator(
                minHeight: 4,
                value: playedProgress,
                color: Colors.red.withOpacity(0.8),
                backgroundColor: Colors.grey[800],
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatDuration(currentPosition),
              style: TextStyle(
                color: hasFocus ? Colors.blue : Colors.green,
                fontSize: minitextsz,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!liveStatus)
              Text(
                formatDuration(totalDuration),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: minitextsz,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (liveStatus)
              Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: minitextsz,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ],
    );
  }

  // Add new video to last played list
  void addNewBannerOrVideo(Map<String, dynamic> newVideo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> storedVideos =
          prefs.getStringList('last_played_videos') ?? [];

      String newVideoEntry =
          '${newVideo['videoUrl']}|${newVideo['position'].inMilliseconds}|${newVideo['duration'].inMilliseconds}|${newVideo['liveStatus']}|${newVideo['bannerImageUrl']}|${newVideo['videoId']}|${newVideo['name']}|${newVideo['seasonId']}';

      // Remove if already exists to avoid duplicates
      storedVideos
          .removeWhere((entry) => entry.startsWith('${newVideo['videoUrl']}|'));

      // Add to beginning of list
      storedVideos.insert(0, newVideoEntry);

      // Keep only last 10 videos
      if (storedVideos.length > 8) {
        storedVideos = storedVideos.take(10).toList();
      }

      await prefs.setStringList('last_played_videos', storedVideos);

      // Refresh the UI
      await _loadLastPlayedVideos();
    } catch (e) {}
  }

  // // Load last played videos from storage
  // Future<void> _loadLastPlayedVideos() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final storedVideos = prefs.getStringList('last_played_videos');

  //     if (storedVideos != null && storedVideos.isNotEmpty) {
  //       List<Map<String, dynamic>> loadedVideos = [];

  //       for (String videoEntry in storedVideos) {
  //         try {
  //           List<String> details = videoEntry.split('|');
  //           if (details.length >= 8) {
  //             Duration duration =
  //                 Duration(milliseconds: int.tryParse(details[2]) ?? 0);
  //             Duration position =
  //                 Duration(milliseconds: int.tryParse(details[1]) ?? 0);
  //             bool liveStatus = details[3].toLowerCase() == 'true';

  //             loadedVideos.add({
  //               'videoUrl': details[0],
  //               'position': position,
  //               'duration': duration,
  //               'liveStatus': liveStatus,
  //               'bannerImageUrl': details[4],
  //               'videoId': details[5],
  //               'name': details[6],
  //               'focusNode':
  //                   FocusNode(), // Create new focus node for each video
  //               'seasonId': details[7]
  //             });
  //           }
  //         } catch (e) {}
  //       }

  //       if (mounted) {
  //         setState(() {
  //           lastPlayedVideos = loadedVideos;
  //         });
  //       }

  //       // printLastPlayedPositions();

  //       // Update shared data provider
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         if (mounted) {
  //           sharedDataProvider.updateLastPlayedVideos(lastPlayedVideos);
  //         }
  //       });
  //     } else {
  //       if (mounted) {
  //         setState(() {
  //           lastPlayedVideos = [];
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         lastPlayedVideos = [];
  //       });
  //     }
  //   }
  // }


// Updated _playVideo method to work with your new NewsItemModel structure

void _playVideo(Map<String, dynamic> videoData, Duration position) async {
  print('🎬 _playVideo called with: ${videoData['name']}');
  
  if (_isNavigating) {
    print('❌ Already navigating, returning');
    return;
  }

  _isNavigating = true;
  bool shouldPlayVideo = true;
  bool shouldPop = true;

  try {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async {
          shouldPlayVideo = false;
          shouldPop = false;
          return true;
        },
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoadingIndicator(),
                SizedBox(height: 15),
                Text(
                  'Loading ${videoData['name'] ?? 'Video'}...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: nametextsz,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Create channel list from last played videos using proper NewsItemModel structure
    List<NewsItemModel> channelList = lastPlayedVideos.asMap().entries.map((entry) {
      final video = entry.value;
      int index = entry.key;
      
      // Safe string conversion helper
      String safeToString(dynamic value, {String defaultValue = ''}) {
        if (value == null) return defaultValue;
        return value.toString();
      }

      String videoUrl = safeToString(video['videoUrl']);
      String videoIdString = safeToString(video['videoId'], defaultValue: '0');
      String videoName = safeToString(video['name'], defaultValue: 'Unknown Video');
      String bannerUrl = safeToString(video['bannerImageUrl']);
      String seasonIdString = safeToString(video['seasonId'], defaultValue: '0');
      
      print('📺 Creating NewsItemModel for: $videoName');
      print('   Original URL: $videoUrl');
      print('   Video ID: $videoIdString');
      
      // // Handle YouTube ID conversion
      // if (videoUrl.isNotEmpty && !videoUrl.startsWith('http') && videoUrl.length == 11) {
      //   videoUrl = 'https://www.youtube.com/watch?v=$videoUrl';
      //   print('   Converted URL: $videoUrl');
      // }
      
      bool isYoutube = isYoutubeUrl(videoUrl);
      bool isLive = video['liveStatus'] == true;
      String streamType = isYoutube ? 'YoutubeLive' : 'M3u8';
      String contentType = isLive ? '0' : '1'; // 0 for live, 1 for VOD

      print('   Stream Type: $streamType');
      print('   Content Type: $contentType');
      print('   Is Live: $isLive');

      return NewsItemModel(
        id: videoIdString,
        index: index.toString(),
        name: videoName,
        unUpdatedUrl: safeToString(video['videoUrl']), // Keep original URL
        description: '',
        thumbnail_high: '',
        banner: bannerUrl,
        image: bannerUrl,
        poster: bannerUrl,
        url: videoUrl, // Use converted URL
        videoId: videoIdString,
        streamType: streamType,
        type: streamType,
        genres: '',
        status: '1', // Always active for last played
        category: 'Last Played',
        contentId: videoIdString,
        contentType: contentType,
        isYoutubeVideo: isYoutube,
        isFocused: false,
        position: video['position'] ?? Duration.zero,
        liveStatus: isLive,
        // Episode-specific fields with defaults
        order: '0',
        seasonId: seasonIdString,
        downloadable: '0',
        source: 'isLastPlayedVideos',
        skipAvailable: '0',
        introStart: '0',
        introEnd: '0',
        endCreditsMarker: '0',
        drmUuid: '',
        drmLicenseUri: '',
        // Season-specific fields with defaults
        seasonName: '',
        webSeriesId: '',
      );
    }).toList();

    print('📋 Created channel list with ${channelList.length} items');

    String originalUrl = safeToString(videoData['videoUrl']);
    String updatedUrl = originalUrl;
    
    // Validate URL
    if (originalUrl.isEmpty) {
      throw Exception('Empty video URL');
    }

    print('🔗 Original URL: $originalUrl');

    // Convert YouTube ID to full URL if needed
    // if (!originalUrl.startsWith('http') && originalUrl.length == 11) {
    //   originalUrl = 'https://www.youtube.com/watch?v=$originalUrl';
    //   updatedUrl = originalUrl;
    //   print('🔄 Converted YouTube ID to full URL: $originalUrl');
    // }

    // Handle YouTube URL updates
    if (isYoutubeUrl(updatedUrl)) {
      print('📹 Detected YouTube URL, getting updated URL...');
      try {
        updatedUrl = await _socketService.getUpdatedUrl(updatedUrl);
        print('✅ Updated YouTube URL: $updatedUrl');
        
        if (updatedUrl.isEmpty) {
          throw Exception('Failed to get updated YouTube URL');
        }
      } catch (e) {
        print('❌ YouTube URL update failed: $e');
        throw Exception('Failed to process YouTube URL: $e');
      }
    }

    // Close loading dialog
    if (shouldPop && context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    Duration startAtPosition = videoData['position'] as Duration? ?? Duration.zero;
    Duration totalDuration = videoData['duration'] as Duration? ?? Duration.zero;
    bool isLive = videoData['liveStatus'] == true;
    
    print('⏰ Start position: ${startAtPosition.inSeconds} seconds');
    print('⏰ Total duration: ${totalDuration.inSeconds} seconds');
    print('🔴 Is Live: $isLive');
    print('🚀 Navigating to VideoScreen...');

    // Navigate to video screen
    if (shouldPlayVideo && context.mounted) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoScreen(
            videoUrl: updatedUrl,
            unUpdatedUrl: originalUrl,
            channelList: channelList,
            bannerImageUrl: safeToString(videoData['bannerImageUrl']),
            startAtPosition: startAtPosition,
            totalDuration: totalDuration,
            videoType: isYoutubeUrl(updatedUrl) ? 'youtube' : 'M3u8',
            isLive: isLive,
            isVOD: !isLive,
            isSearch: false,
            isHomeCategory: false,
            isBannerSlider: false,
            videoId: int.tryParse(safeToString(videoData['videoId'], defaultValue: '0')) ?? 0,
            source: 'isLastPlayedVideos',
            name: safeToString(videoData['name'], defaultValue: 'Unknown Video'),
            liveStatus: isLive,
            seasonId: int.tryParse(safeToString(videoData['seasonId'], defaultValue: '0')),
            isLastPlayedStored: true,
          ),
        ),
      );
      
      print('✅ Navigation completed with result: $result');
      
      // Refresh last played videos when returning
      if (result == true) {
        await _loadLastPlayedVideos();
        if (mounted) {
          setState(() {
            refreshKey = UniqueKey();
          });
        }
      }
    }
  } catch (e) {
    print('❌ Error in _playVideo: $e');
    print('📍 Stack trace: ${StackTrace.current}');
    
    // Close loading dialog if still open
    if (shouldPop && context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    // Show error message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to play video: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
          duration: Duration(seconds: 5),
        ),
      );
    }
  } finally {
    _isNavigating = false;
    print('🏁 _playVideo method finished');
  }
}

// Helper method for safe string conversion (add this to your class)
String safeToString(dynamic value, {String defaultValue = ''}) {
  if (value == null) return defaultValue;
  return value.toString();
}

// Updated _loadLastPlayedVideos method with better error handling
Future<void> _loadLastPlayedVideos() async {
  print('🔄 Loading last played videos...');
  
  try {
    final prefs = await SharedPreferences.getInstance();
    final storedVideos = prefs.getStringList('last_played_videos');

    if (storedVideos != null && storedVideos.isNotEmpty) {
      List<Map<String, dynamic>> loadedVideos = [];

      for (int i = 0; i < storedVideos.length; i++) {
        String videoEntry = storedVideos[i];
        print('🔍 Processing entry $i: $videoEntry');
        
        try {
          List<String> details = videoEntry.split('|');
          if (details.length >= 8) {
            Duration duration = Duration(milliseconds: int.tryParse(details[2]) ?? 0);
            Duration position = Duration(milliseconds: int.tryParse(details[1]) ?? 0);
            bool liveStatus = details[3].toLowerCase() == 'true';

            // Create video data with all required fields
            Map<String, dynamic> videoData = {
              'videoUrl': details[0],
              'position': position,
              'duration': duration,
              'liveStatus': liveStatus,
              'bannerImageUrl': details[4],
              'videoId': details[5],
              'name': details[6],
              'focusNode': FocusNode(),
              'seasonId': details[7],
              'source': 'isLastPlayedVideos',
              'category': 'Last Played',
              'genres': '',
              'poster': details[4], // Use banner as poster
              'contentType': liveStatus ? '0' : '1',
              'streamType': isYoutubeUrl(details[0]) ? 'YoutubeLive' : 'M3u8',
              'status': '1',
              'isYoutubeVideo': isYoutubeUrl(details[0]),
            };

            loadedVideos.add(videoData);
            print('✅ Successfully loaded: ${details[6]}');
            
            // Debug the video data structure
            print('📊 Video data keys: ${videoData.keys.toList()}');
          } else {
            print('❌ Invalid entry format: ${details.length} parts, expected at least 8');
          }
        } catch (e) {
          print('❌ Error processing entry $i: $e');
        }
      }

      if (mounted) {
        setState(() {
          lastPlayedVideos = loadedVideos;
        });
        print('✅ Updated state with ${loadedVideos.length} videos');
      }

      // Update shared data provider
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          sharedDataProvider.updateLastPlayedVideos(lastPlayedVideos);
          print('✅ Updated shared data provider');
        }
      });
    } else {
      print('📭 No stored videos found');
      if (mounted) {
        setState(() {
          lastPlayedVideos = [];
        });
      }
    }
  } catch (e) {
    print('❌ Error loading last played videos: $e');
    if (mounted) {
      setState(() {
        lastPlayedVideos = [];
      });
    }
  }
  
  print('🏁 Finished loading last played videos');
}

// Add this debug method to check data structure
void debugVideoDataStructure() {
  print('🔍 DEBUG: Last Played Videos Data Structure');
  print('📊 Total videos: ${lastPlayedVideos.length}');
  
  for (int i = 0; i < lastPlayedVideos.length && i < 3; i++) { // Debug first 3 videos
    final video = lastPlayedVideos[i];
    print('📺 Video $i structure:');
    video.forEach((key, value) {
      print('   $key: ${value?.toString() ?? 'NULL'} (${value.runtimeType})');
    });
    print('   ---');
  }
}

  // // Print debug info for last played positions
  // void printLastPlayedPositions() {
  //   for (int i = 0; i < lastPlayedVideos.length; i++) {
  //     final video = lastPlayedVideos[i];
  //     final position = video['position'] ?? Duration.zero;
  //     final name = video['name'] ?? 'Unknown';
  //   }
  // }

  // // Play a video from last played list
  // void _playVideo(Map<String, dynamic> videoData, Duration position) async {
  //   if (_isNavigating) {
  //     return;
  //   }

  //   _isNavigating = true;

  //   bool shouldPlayVideo = true;
  //   bool shouldPop = true;

  //   // Show loading dialog
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) => WillPopScope(
  //       onWillPop: () async {
  //         shouldPlayVideo = false;
  //         shouldPop = false;
  //         return true;
  //       },
  //       child: Center(
  //         child: Container(
  //           padding: EdgeInsets.all(20),
  //           decoration: BoxDecoration(
  //             color: Colors.black87,
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               LoadingIndicator(),
  //               SizedBox(height: 15),
  //               Text(
  //                 'Loading ${videoData['name']}...',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: nametextsz,
  //                 ),
  //                 textAlign: TextAlign.center,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );

  //   // Set timeout for navigation
  //   Timer(Duration(seconds: 15), () {
  //     if (_isNavigating) {
  //       _isNavigating = false;
  //     }
  //   });

  //   try {
  //     // Create channel list from last played videos
  //     List<NewsItemModel> channelList =
  //         lastPlayedVideos.asMap().entries.map((entry) {
  //       final video = entry.value;
  //       String videoUrl = video['videoUrl'] ?? '';
  //       String videoIdString = video['videoId'] ?? '0';
  //       String streamType = isYoutubeUrl(videoUrl) ? 'YoutubeLive' : 'M3u8';

  //       return NewsItemModel(
  //         videoId: video['videoId'],
  //         id: videoIdString,
  //         url: videoUrl,
  //         banner: video['bannerImageUrl'] ?? '',
  //         name: video['name'] ?? '',
  //         poster: video['poster'] ?? '',
  //         category: video['category'] ?? '',
  //         contentId: videoIdString,
  //         status: '1',
  //         streamType: streamType,
  //         type: streamType,
  //         contentType: '1',
  //         genres: '',
  //         position: video['position'],
  //         liveStatus: video['liveStatus'],
  //         index: '',
  //         image: '',
  //         source: video['source'],
  //         unUpdatedUrl: '',
  //       );
  //     }).toList();

  //     String source = videoData['source'] ?? 'isLastPlayedVideos';
  //     // int videoId = int.tryParse(videoData['videoId']?.toString() ?? '0') ?? 0;
  //     String originalUrl = videoData['videoUrl'];
  //     String updatedUrl = videoData['videoUrl'];

  //     // Handle YouTube URL updates
  //     if (isYoutubeUrl(updatedUrl)) {
  //       try {
  //         updatedUrl = await _socketService.getUpdatedUrl(updatedUrl);
  //       } catch (e) {}
  //     }

  //     // Close loading dialog
  //     if (shouldPop && context.mounted) {
  //       Navigator.of(context, rootNavigator: true).pop();
  //     }

  //     Duration startAtPosition =
  //         videoData['position'] as Duration? ?? Duration.zero;

  //     // Navigate to video screen
  //     if (shouldPlayVideo && context.mounted) {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => VideoScreen(
  //             videoUrl: updatedUrl,
  //             unUpdatedUrl: originalUrl,
  //             channelList: channelList,
  //             bannerImageUrl: videoData['bannerImageUrl'] ?? '',
  //             startAtPosition: startAtPosition,
  //             totalDuration: videoData['duration'],
  //             videoType: '',
  //             isLive: source == 'isLiveScreen',
  //             isVOD: source == 'isVOD',
  //             isSearch: source == 'isSearchScreen',
  //             isHomeCategory: source == 'isHomeCategory',
  //             isBannerSlider: source == 'isBannerSlider',
  //             videoId: videoData['videoId'],
  //             source: 'isLastPlayedVideos',
  //             name: videoData['name'] ?? '',
  //             liveStatus: videoData['liveStatus'],
  //             seasonId: videoData['seasonId'],
  //             isLastPlayedStored: true,
  //           ),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (shouldPop && context.mounted) {
  //       Navigator.of(context, rootNavigator: true).pop();
  //     }

  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Something went wrong'),
  //           backgroundColor: Colors.red.shade700,
  //         ),
  //       );
  //     }
  //   } finally {
  //     _isNavigating = false;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<FocusProvider>(
      builder: (context, focusProvider, child) {
        return Scaffold(
          backgroundColor: cardColor,
          body: isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitFadingCircle(color: borderColor, size: 50.0),
                      SizedBox(height: 20),
                      Text(
                        '...',
                        style: TextStyle(
                          color: hintColor,
                          fontSize: nametextsz,
                        ),
                      ),
                    ],
                  ),
                )
              : errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 50,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Something Went Wrong',
                            style: TextStyle(
                              fontSize: menutextsz,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              errorMessage,
                              style: TextStyle(
                                fontSize: minitextsz,
                                color: hintColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => fetchBanners(),
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : bannerList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                color: hintColor.withOpacity(0.5),
                                size: 50,
                              ),
                              SizedBox(height: 20),
                              Text(
                                '',
                                style: TextStyle(
                                  color: hintColor,
                                  fontSize: nametextsz,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            // Main banner slider
                            PageView.builder(
                              controller: _pageController,
                              itemCount: bannerList.length,
                              onPageChanged: (index) {
                                if (mounted) {
                                  setState(() {
                                    selectedContentId =
                                        bannerList[index].contentId.toString();
                                  });
                                }
                              },
                              itemBuilder: (context, index) {
                                final banner = bannerList[index];
                                return Stack(
                                  alignment: AlignmentDirectional.topCenter,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 1),
                                      width: screenwdt,
                                      height: screenhgt,
                                      child: CachedNetworkImage(
                                        imageUrl: banner.banner,
                                        fit: BoxFit.fill,
                                        placeholder: (context, url) =>
                                            localImage,
                                        errorWidget: (context, url, error) =>
                                            localImage,
                                        cacheKey: banner.contentId,
                                        fadeInDuration:
                                            Duration(milliseconds: 500),
                                        memCacheHeight: 800,
                                        memCacheWidth: 1200,
                                      ),
                                    ),

                                    // Gradient overlay for better text visibility
                                    Container(
                                      margin: const EdgeInsets.only(top: 1),
                                      width: screenwdt,
                                      height: screenhgt,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.3),
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                          stops: [0.0, 0.5, 1.0],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            // Watch Now button
                            Positioned(
                              top: screenhgt * 0.03,
                              left: screenwdt * 0.02,
                              child: Focus(
                                focusNode: _buttonFocusNode,
                                onKeyEvent: (node, event) {
                                  if (event.logicalKey ==
                                      LogicalKeyboardKey.arrowRight) {
                                    if (_pageController.hasClients &&
                                        _pageController.page != null &&
                                        _pageController.page! <
                                            bannerList.length - 1) {
                                      _pageController.nextPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                      return KeyEventResult.handled;
                                    }
                                  } else if (event.logicalKey ==
                                      LogicalKeyboardKey.arrowLeft) {
                                    if (_pageController.hasClients &&
                                        _pageController.page != null &&
                                        _pageController.page! > 0) {
                                      _pageController.previousPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                      return KeyEventResult.handled;
                                    }
                                  } else if (event is KeyDownEvent) {
                                    if (event.logicalKey ==
                                        LogicalKeyboardKey.arrowDown) {
                                      if (lastPlayedVideos.isNotEmpty) {
                                        context
                                            .read<FocusProvider>()
                                            .requestLastPlayedFocus();
                                        FocusScope.of(context).requestFocus(
                                            lastPlayedVideos[0]['focusNode']);
                                        return KeyEventResult.handled;
                                      }
                                    } else if (event.logicalKey ==
                                            LogicalKeyboardKey.select ||
                                        event.logicalKey ==
                                            LogicalKeyboardKey.enter) {
                                      if (selectedContentId != null) {
                                        // fetchAndPlayVideo(selectedContentId!, bannerList);
                                        final banner = bannerList.firstWhere(
                                            (b) =>
                                                b.contentId ==
                                                selectedContentId);
                                        fetchAndPlayVideo(
                                            banner.id, bannerList);
                                      }
                                      return KeyEventResult.handled;
                                    }
                                  }
                                  return KeyEventResult.ignored;
                                },
                                child: GestureDetector(
                                  onTap: () {
                                    if (selectedContentId != null) {
                                      // fetchAndPlayVideo(selectedContentId!, bannerList);
                                      final banner = bannerList.firstWhere(
                                          (b) =>
                                              b.contentId == selectedContentId);
                                      fetchAndPlayVideo(banner.id, bannerList);
                                    }
                                  },
                                  child: RandomLightColorWidget(
                                    hasFocus: focusProvider.isButtonFocused,
                                    childBuilder: (Color randomColor) {
                                      return AnimatedContainer(
                                        duration: Duration(milliseconds: 200),
                                        margin:
                                            EdgeInsets.all(screenwdt * 0.001),
                                        padding: EdgeInsets.symmetric(
                                          vertical: screenhgt * 0.02,
                                          horizontal: screenwdt * 0.02,
                                        ),
                                        decoration: BoxDecoration(
                                          color: focusProvider.isButtonFocused
                                              ? Colors.black87
                                              : Colors.black.withOpacity(0.6),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: focusProvider.isButtonFocused
                                                ? focusProvider
                                                        .currentFocusColor ??
                                                    randomColor
                                                : Colors.white.withOpacity(0.3),
                                            width: focusProvider.isButtonFocused
                                                ? 3.0
                                                : 1.0,
                                          ),
                                          boxShadow:
                                              focusProvider.isButtonFocused
                                                  ? [
                                                      BoxShadow(
                                                        color: (focusProvider
                                                                    .currentFocusColor ??
                                                                randomColor)
                                                            .withOpacity(0.5),
                                                        blurRadius: 20.0,
                                                        spreadRadius: 5.0,
                                                      ),
                                                    ]
                                                  : [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.3),
                                                        blurRadius: 10.0,
                                                        spreadRadius: 2.0,
                                                      ),
                                                    ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.play_arrow,
                                              color: focusProvider
                                                      .isButtonFocused
                                                  ? focusProvider
                                                          .currentFocusColor ??
                                                      randomColor
                                                  : hintColor,
                                              size: menutextsz * 1.2,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Watch Now',
                                              style: TextStyle(
                                                fontSize: menutextsz,
                                                color: focusProvider
                                                        .isButtonFocused
                                                    ? focusProvider
                                                            .currentFocusColor ??
                                                        randomColor
                                                    : hintColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),

                            // Banner indicator dots
                            if (bannerList.length > 1)
                              Positioned(
                                top: screenhgt * 0.05,
                                // left: 0,
                                right: screenwdt * 0.05,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:
                                      bannerList.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    bool isSelected = selectedContentId ==
                                        bannerList[index].contentId;

                                    return AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 4),
                                      width: isSelected ? 12 : 8,
                                      height: isSelected ? 12 : 8,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                            // Continue Watching Section
                            if (lastPlayedVideos.isNotEmpty)
                              buildContinueWatchingSection(),
                          ],
                        ),
        );
      },
    );
  }

  // Build Continue Watching Section
  Widget buildContinueWatchingSection() {
    return Positioned(
      bottom: screenhgt * 0.01,
      left: 0,
      right: 0,
      child: Container(
        child: Column(
          key: refreshKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.025),
              child: Container(
                padding: EdgeInsets.all(screenwdt * 0.005),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history,
                      color: hintColor,
                      size: menutextsz,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Continue Watching',
                      style: TextStyle(
                        fontSize: menutextsz,
                        color: hintColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: hintColor,
                      size: menutextsz,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: screenhgt * 0.01),

            // Videos List

            // Videos List (continued from previous part)
            SizedBox(
              height: screenhgt * 0.27,
              child: ListView.builder(
                controller: _lastPlayedScrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemCount:
                    lastPlayedVideos.length > 10 ? 10 : lastPlayedVideos.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> videoData = lastPlayedVideos[index];
                  FocusNode focusNode = videoData['focusNode'] ?? FocusNode();
                  lastPlayedVideos[index]['focusNode'] = focusNode;

                  // Register focus element
                  final GlobalKey itemKey = GlobalKey();
                  context
                      .read<FocusProvider>()
                      .registerElementKey('lastPlayed_$index', itemKey);

                  // Set first item focus node
                  if (index == 0) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context
                          .read<FocusProvider>()
                          .setFirstLastPlayedFocusNode(focusNode);
                    });
                  }

                  return Container(
                    key: itemKey,
                    child: Focus(
                      focusNode: focusNode,
                      onFocusChange: (hasFocus) {
                        if (hasFocus) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              _scrollToFocusedItem(index);
                            });
                            context
                                .read<FocusProvider>()
                                .scrollToElement('lastPlayed_$index');
                            context
                                .read<FocusProvider>()
                                .setLastPlayedFocus(index);
                          });
                        }
                      },
                      // onKey: (node, event) {
                      //   if (event is RawKeyDownEvent) {
                      //     if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                      //       Future.delayed(Duration(milliseconds: 100), () {
                      //         context
                      //             .read<FocusProvider>()
                      //             .requestWatchNowFocus();
                      //       });
                      //       return KeyEventResult.handled;
                      //     } else if (event.logicalKey ==
                      //         LogicalKeyboardKey.arrowDown) {
                      //       context
                      //           .read<FocusProvider>()
                      //           .requestMusicItemFocus(context);
                      //       return KeyEventResult.handled;
                      //     } else if (event.logicalKey ==
                      //         LogicalKeyboardKey.arrowRight) {
                      //       if (index < lastPlayedVideos.length - 1) {
                      //         FocusScope.of(context).requestFocus(
                      //             lastPlayedVideos[index + 1]['focusNode']);
                      //         return KeyEventResult.handled;
                      //       }
                      //     } else if (event.logicalKey ==
                      //         LogicalKeyboardKey.arrowLeft) {
                      //       if (index > 0) {
                      //         FocusScope.of(context).requestFocus(
                      //             lastPlayedVideos[index - 1]['focusNode']);
                      //         return KeyEventResult.handled;
                      //       }
                      //     } else if (event.logicalKey ==
                      //             LogicalKeyboardKey.select ||
                      //         event.logicalKey == LogicalKeyboardKey.enter) {
                      //       _playVideo(videoData, videoData['position']);
                      //       return KeyEventResult.handled;
                      //     }
                      //   }
                      //   return KeyEventResult.ignored;
                      // },

                      onKey: (node, event) {
  if (event is RawKeyDownEvent) {
    print('🎹 Key pressed: ${event.logicalKey}');
    
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      Future.delayed(Duration(milliseconds: 100), () {
        context.read<FocusProvider>().requestWatchNowFocus();
      });
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      context.read<FocusProvider>().requestMusicItemFocus(context);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (index < lastPlayedVideos.length - 1) {
        FocusScope.of(context).requestFocus(
          lastPlayedVideos[index + 1]['focusNode']
        );
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (index > 0) {
        FocusScope.of(context).requestFocus(
          lastPlayedVideos[index - 1]['focusNode']
        );
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.select ||
               event.logicalKey == LogicalKeyboardKey.enter) {
      print('✅ Enter/Select pressed - playing video: ${videoData['name']}');
      _playVideo(videoData, videoData['position']);
      return KeyEventResult.handled;
    }
  }
  return KeyEventResult.ignored;
},
                      child: GestureDetector(
                        onTap: () {
                          _playVideo(videoData, videoData['position']);
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          width: screenwdt * 0.15,
                          height: screenhgt * 0.25,
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: focusNode.hasFocus
                                ? Colors.black.withOpacity(0.9)
                                : Colors.transparent,
                            border: Border.all(
                              color: focusNode.hasFocus
                                  ? Colors.blue
                                  : Colors.transparent,
                              width: focusNode.hasFocus ? 3 : 0,
                            ),
                            boxShadow: focusNode.hasFocus
                                ? [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.5),
                                      blurRadius: 15,
                                      spreadRadius: 3,
                                    )
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    )
                                  ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Video Title
                                if (focusNode.hasFocus)
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.9),
                                    ),
                                    child: Text(
                                      videoData['name'] ?? 'Unknown Video',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: nametextsz,
                                        color: Colors.white,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                // Video Thumbnail
                                Expanded(
                                  flex: 3,
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        child: videoData['bannerImageUrl']
                                                    ?.startsWith(
                                                        'data:image') ==
                                                true
                                            ? Image.memory(
                                                _getCachedImage(videoData[
                                                    'bannerImageUrl']),
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    _buildErrorImage(),
                                              )
                                            : CachedNetworkImage(
                                                imageUrl: videoData[
                                                        'bannerImageUrl'] ??
                                                    localImage,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                placeholder: (context, url) =>
                                                    Container(
                                                  color: Colors.grey.shade800,
                                                  child: Center(
                                                    child: SpinKitFadingCircle(
                                                      color: Colors.blue,
                                                      size: 20.0,
                                                    ),
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        _buildErrorImage(),
                                              ),
                                      ),

                                      // Play overlay
                                      if (focusNode.hasFocus)
                                        Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          color: Colors.black.withOpacity(0.3),
                                          child: Center(
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.blue
                                                    .withOpacity(0.9),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.play_arrow,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),

                                      // Live indicator
                                      if (videoData['liveStatus'] == true)
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'LIVE',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: minitextsz * 0.8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Progress and Duration
                                Container(
                                  padding: EdgeInsets.all(8),
                                  child: _buildProgressDisplay(
                                      videoData, focusNode.hasFocus),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build error image widget
  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey.shade800,
      child: localImage,
    );
  }

  // // Cleanup and additional utility methods
  // void debugPrintBannerInfo() {}

  // // Print current banner list for debugging
  // void printBannerList() {
  //   for (int i = 0; i < bannerList.length; i++) {
  //     final banner = bannerList[i];
  //   }
  // }

  // Check if slider is ready
  bool get isSliderReady =>
      !isLoading && errorMessage.isEmpty && bannerList.isNotEmpty;

  // Get current banner info
  Map<String, dynamic>? get currentBannerInfo {
    if (selectedContentId == null || bannerList.isEmpty) return null;

    try {
      final banner = bannerList.firstWhere(
        (b) => b.contentId == selectedContentId,
        orElse: () => bannerList.first,
      );

      return {
        'id': banner.contentId,
        'name': banner.name,
        'banner': banner.banner,
        'url': banner.url,
        'type': banner.type,
      };
    } catch (e) {
      return null;
    }
  }
} // End of _BannerSliderState class

// Additional utility functions outside the class

// Extension for better duration formatting
extension DurationExtension on Duration {
  String toHHMMSS() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = inHours > 0 ? '${twoDigits(inHours)}:' : '';
    String minutes = twoDigits(inMinutes.remainder(60));
    String seconds = twoDigits(inSeconds.remainder(60));
    return '$hours$minutes:$seconds';
  }
}

// Global functions for banner slider management
class BannerSliderManager {
  static BannerSlider? _instance;

  static void setInstance(BannerSlider instance) {
    _instance = instance;
  }

  static BannerSlider? get instance => _instance;

  static void refreshBanners() {
    GlobalEventBus().fire(RefreshPageEvent('uniquePageId'));
  }

  static void clearInstance() {
    _instance = null;
  }
}

// Helper function to validate and format auth key
String formatAuthKey(String? key) {
  if (key == null || key.isEmpty) return '';

  // Remove any whitespace
  key = key.trim();

  // Basic validation - check if it looks like a valid key
  if (key.length < 10) {}

  return key;
}

// Helper function to check API endpoint health
Future<bool> checkEndpointHealth(String endpoint) async {
  try {
    final response =
        await https.head(Uri.parse(endpoint)).timeout(Duration(seconds: 5));
    return response.statusCode == 200 ||
        response.statusCode == 405; // 405 is also acceptable for HEAD requests
  } catch (e) {
    return false;
  }
}

// Helper function to get the best available API endpoint
Future<String> getBestApiEndpoint(List<String> endpoints) async {
  for (String endpoint in endpoints) {
    if (await checkEndpointHealth(endpoint)) {
      return endpoint;
    }
  }

  return endpoints.first;
}

// // Debug helper to print all available SharedPreferences keys
// Future<void> debugPrintSharedPreferences() async {
//   try {
//     final prefs = await SharedPreferences.getInstance();
//     final keys = prefs.getKeys();

//     for (String key in keys) {
//       final value = prefs.get(key);
//     }
//   } catch (e) {}
// }

// Network helper function to retry API calls
Future<T> retryApiCall<T>(
  Future<T> Function() apiCall, {
  int maxRetries = 3,
  Duration delay = const Duration(seconds: 2),
}) async {
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await apiCall();
    } catch (e) {
      if (attempt == maxRetries) {
        rethrow;
      }

      await Future.delayed(delay);
    }
  }

  throw Exception('All retry attempts failed');
}

// Cache management helper
class CacheManager {
  static const String BANNER_CACHE_KEY = 'banners';
  static const String FEATURED_TV_CACHE_KEY = 'live_featured_tv';
  static const String LAST_PLAYED_CACHE_KEY = 'last_played_videos';

  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(BANNER_CACHE_KEY);
      await prefs.remove(FEATURED_TV_CACHE_KEY);
    } catch (e) {}
  }

  static Future<void> clearBannerCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(BANNER_CACHE_KEY);
    } catch (e) {}
  }

  static Future<Map<String, int>> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final bannerSize = prefs.getString(BANNER_CACHE_KEY)?.length ?? 0;
      final featuredTVSize =
          prefs.getString(FEATURED_TV_CACHE_KEY)?.length ?? 0;
      final lastPlayedCount =
          prefs.getStringList(LAST_PLAYED_CACHE_KEY)?.length ?? 0;

      return {
        'bannerCacheSize': bannerSize,
        'featuredTVCacheSize': featuredTVSize,
        'lastPlayedCount': lastPlayedCount,
      };
    } catch (e) {
      return {};
    }
  }
}
