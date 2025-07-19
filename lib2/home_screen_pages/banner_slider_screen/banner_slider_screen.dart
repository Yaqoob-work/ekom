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
import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player_4k.dart';
import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart';
import 'package:mobi_tv_entertainment/widgets/utils/color_service.dart';
import 'package:mobi_tv_entertainment/widgets/utils/random_light_color_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/small_widgets/app_assets.dart';

// Simple implementation of ImageCacheService for demonstration
class ImageCacheStats {
  final int totalFiles;
  final double totalSizeMB;
  ImageCacheStats({required this.totalFiles, required this.totalSizeMB});
}

class ImageCacheService {
  Future<void> init() async {
    // Initialize cache if needed
  }

  Future<bool> isCached(String url) async {
    // Always return false for demonstration
    return false;
  }

  Future<void> downloadAndCacheImage(String url) async {
    // Simulate download and cache
    await Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> clearCache() async {
    // Simulate clearing cache
    await Future.delayed(Duration(milliseconds: 100));
  }

  Future<ImageCacheStats> getCacheStats() async {
    // Return dummy stats
    return ImageCacheStats(totalFiles: 0, totalSizeMB: 0.0);
  }
}

Future<Map<String, String>> getAuthHeaders() async {
  String authKey = '';

  try {
    if (AuthManager.hasValidAuthKey) {
      authKey = AuthManager.authKey;
    }
  } catch (e) {}

  if (authKey.isEmpty && globalAuthKey.isNotEmpty) {
    authKey = globalAuthKey;
  }

  if (authKey.isEmpty) {
    try {
      final prefs = await SharedPreferences.getInstance();
      authKey = prefs.getString('auth_key') ?? '';
      if (authKey.isNotEmpty) {
        globalAuthKey = authKey;
      }
    } catch (e) {}
  }

  if (authKey.isEmpty) {
    authKey = 'vLQTuPZUxktl5mVW';
  }

  return {
    'auth-key': authKey,
    // 'x-api-key': authKey,
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    // 'User-Agent': 'MobiTV/1.0',
  };
}

class ApiConfig {
  static const String PRIMARY_BASE_URL =
      'https://acomtv.coretechinfo.com/public/api';

  static const List<String> FEATURED_TV_ENDPOINTS = [
    '$PRIMARY_BASE_URL/getCustomImageSlider',
  ];

  static const List<String> BANNER_ENDPOINTS = [
    '$PRIMARY_BASE_URL/getCustomImageSlider',
  ];
}

Future<Map<String, String>> fetchVideoDataByIdFromBanners(
    String contentId) async {
  final prefs = await SharedPreferences.getInstance();
  final cachedData = prefs.getString('live_featured_tv');

  List<dynamic> responseData;

  try {
    if (cachedData != null) {
      responseData = json.decode(cachedData);
    } else {
      Map<String, String> headers = await getAuthHeaders();
      bool success = false;
      String responseBody = '';

      for (int i = 0; i < ApiConfig.FEATURED_TV_ENDPOINTS.length; i++) {
        String endpoint = ApiConfig.FEATURED_TV_ENDPOINTS[i];

        try {
          Map<String, String> currentHeaders = Map.from(headers);

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
                json.decode(body);
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
      await prefs.setString('live_featured_tv', responseBody);
    }

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

Future<List<dynamic>> fetchBannersData() async {
  Map<String, String> headers = await getAuthHeaders();
  bool success = false;
  String responseBody = '';

  for (int i = 0; i < ApiConfig.BANNER_ENDPOINTS.length; i++) {
    String endpoint = ApiConfig.BANNER_ENDPOINTS[i];

    try {
      Map<String, String> currentHeaders = Map.from(headers);

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
            json.decode(body);
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

class _BannerSliderState extends State<BannerSlider>
    with SingleTickerProviderStateMixin {
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

  Map<String, Uint8List> _bannerCache = {};
  late FocusProvider _refreshProvider;
  final ImageCacheService _imageCacheService = ImageCacheService();

  // 🌟 NEW: Animation controllers for shimmer effect
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // 🌟 Initialize shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _initializeSlider();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _socketService.dispose();

    // 🌟 Dispose shimmer controller
    _shimmerController.dispose();

    if (_timer.isActive) {
      _timer.cancel();
    }

    _buttonFocusNode.dispose();
    super.dispose();
  }

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
                                    // 🌟 Main banner image with shimmer
                                    _buildBannerWithShimmer(
                                        banner, focusProvider),

                                    // Gradient overlay
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

                            // Watch Now Button with enhanced styling
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
                                            LogicalKeyboardKey.select ||
                                        event.logicalKey ==
                                            LogicalKeyboardKey.enter) {
                                      if (selectedContentId != null) {
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

                            // Page indicators
                            if (bannerList.length > 1)
                              Positioned(
                                top: screenhgt * 0.05,
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
                          ],
                        ),
        );
      },
    );
  }

  // 🌟 NEW: Build banner with shimmer effect
  Widget _buildBannerWithShimmer(
      NewsItemModel banner, FocusProvider focusProvider) {
    return Container(
      margin: const EdgeInsets.only(top: 1),
      width: screenwdt,
      height: screenhgt,
      child: Stack(
        children: [
          // Main banner image
          CachedNetworkImage(
            imageUrl: banner.banner,
            fit: BoxFit.fill,
            placeholder: (context, url) => Image.asset('assets/streamstarting.gif'),
            errorWidget: (context, url, error) =>
                Image.asset('assets/streamstarting.gif'),
            cacheKey: banner.contentId,
            fadeInDuration: Duration(milliseconds: 500),
            memCacheHeight: 800,
            memCacheWidth: 1200,
            width: screenwdt,
            height: screenhgt,
          ),

          // 🌟 Shimmer effect overlay
          if (focusProvider.isButtonFocused)
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
                        end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.3, 0.5, 0.7, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),

          // 🌟 Enhanced glow effect when focused
          if (focusProvider.isButtonFocused)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      (focusProvider.currentFocusColor ?? Colors.blue)
                          .withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

          // 🌟 Border glow effect
          if (focusProvider.isButtonFocused)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: (focusProvider.currentFocusColor ?? Colors.blue)
                        .withOpacity(0.3),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 🌟 Alternative shimmer effect method (more subtle)
  Widget _buildSubtleShimmer(
      NewsItemModel banner, FocusProvider focusProvider) {
    return Container(
      margin: const EdgeInsets.only(top: 1),
      width: screenwdt,
      height: screenhgt,
      child: Stack(
        children: [
          // Main image
          CachedNetworkImage(
            imageUrl: banner.banner,
            fit: BoxFit.fill,
            placeholder: (context, url) => Image.asset('assets/streamstarting.gif'),
            errorWidget: (context, url, error) =>
                Image.asset('assets/streamstarting.gif'),
            cacheKey: banner.contentId,
            fadeInDuration: Duration(milliseconds: 500),
            memCacheHeight: 800,
            memCacheWidth: 1200,
          ),

          // Subtle shimmer when focused
          if (focusProvider.isButtonFocused)
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.05),
                          Colors.transparent,
                        ],
                        stops: [
                          (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                          _shimmerAnimation.value.clamp(0.0, 1.0),
                          (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // 🌟 Professional shimmer effect (SubVod style)
  Widget _buildProfessionalShimmer(
      NewsItemModel banner, FocusProvider focusProvider) {
    return Container(
      margin: const EdgeInsets.only(top: 1),
      width: screenwdt,
      height: screenhgt,
      child: Stack(
        children: [
          // Main banner image
          CachedNetworkImage(
            imageUrl: banner.banner,
            fit: BoxFit.fill,
            placeholder: (context, url) => Image.asset('assets/streamstarting.gif'),
            errorWidget: (context, url, error) =>
                Image.asset('assets/streamstarting.gif'),
            cacheKey: banner.contentId,
            fadeInDuration: Duration(milliseconds: 500),
            memCacheHeight: 800,
            memCacheWidth: 1200,
          ),

          // Professional shimmer effect (same as SubVod)
          if (focusProvider.isButtonFocused)
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
                        end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
                        colors: [
                          Colors.transparent,
                          (focusProvider.currentFocusColor ?? Colors.blue)
                              .withOpacity(0.15),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _initializeSlider();
  // }

  Future<void> _initializeSlider() async {
    // Initialize image cache service first
    await _imageCacheService.init();

    sharedDataProvider = context.read<SharedDataProvider>();

    _socketService.initSocket();
    _pageController = PageController();

    _buttonFocusNode.addListener(() {
      if (_buttonFocusNode.hasFocus) {
        widget.onFocusChange?.call(true);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FocusProvider>().setWatchNowFocusNode(_buttonFocusNode);
    });

    _buttonFocusNode.addListener(_onButtonFocusNode);

    await _loadCachedData();

    if (bannerList.isNotEmpty) {
      _startAutoSlide();
      // Preload images for better performance
      _preloadImages();
    }
  }

  // Preload images in background for smooth experience
  Future<void> _preloadImages() async {
    for (final banner in bannerList) {
      try {
        // Check if already cached
        final isCached = await _imageCacheService.isCached(banner.banner);

        if (!isCached) {
          // Download in background without blocking UI
          _imageCacheService
              .downloadAndCacheImage(banner.banner)
              .catchError((e) {
            print('Failed to preload image: ${banner.banner}');
          });
        }
      } catch (e) {
        print('Error preloading image: $e');
      }
    }
  }

  // Enhanced fetchBanners with image preloading
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

      final List<dynamic> responseData = await fetchBannersData();

      if (cachedBanners != null) {
        try {
          final cachedData = json.decode(cachedBanners);
          if (json.encode(cachedData) == json.encode(responseData)) {
            // Data hasn't changed, but still preload any missing images
            if (!isBackgroundFetch) {
              setState(() => isLoading = false);
            }
            _preloadImages();
            return;
          }
        } catch (e) {}
      }

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
        errorMessage = '';
      });

      await prefs.setString('banners', json.encode(responseData));

      if (bannerList.isNotEmpty) {
        await _fetchBannerColors();
        if (!_timer.isActive) {
          _startAutoSlide();
        }
        // Preload images after successful fetch
        _preloadImages();
      }
    } catch (e) {
      if (!isBackgroundFetch) {
        setState(() {
          errorMessage = 'Failed to load banners: $e';
          isLoading = false;
        });
      }
    }
  }

  // Add cache management methods
  Future<void> clearImageCache() async {
    try {
      await _imageCacheService.clearCache();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image cache cleared successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to clear cache: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> showCacheInfo() async {
    try {
      final stats = await _imageCacheService.getCacheStats();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Cache Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total cached files: ${stats.totalFiles}'),
                Text('Cache size: ${stats.totalSizeMB.toStringAsFixed(2)} MB'),
                SizedBox(height: 10),
                Text(
                  'Cache helps load images faster and reduces data usage.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  clearImageCache();
                },
                child: Text('Clear Cache'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get cache info: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // @override
  // void dispose() {
  //   _pageController.dispose();
  //   _socketService.dispose();

  //   if (_timer.isActive) {
  //     _timer.cancel();
  //   }

  //   _buttonFocusNode.dispose();

  //   super.dispose();
  // }

  // Enhanced _loadCachedData with image cache check
  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedBanners = prefs.getString('banners');

    if (cachedBanners != null) {
      try {
        final List<dynamic> responseData = json.decode(cachedBanners);

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
          // Check which images are cached and preload missing ones
          _preloadImages();
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

  // Future<void> _initializeSlider() async {
  //   sharedDataProvider = context.read<SharedDataProvider>();

  //   _socketService.initSocket();
  //   _pageController = PageController();

  //   _buttonFocusNode.addListener(() {
  //     if (_buttonFocusNode.hasFocus) {
  //       widget.onFocusChange?.call(true);
  //     }
  //   });

  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<FocusProvider>().setWatchNowFocusNode(_buttonFocusNode);
  //   });

  //   _buttonFocusNode.addListener(_onButtonFocusNode);

  //   await _loadCachedData();

  //   if (bannerList.isNotEmpty) {
  //     _startAutoSlide();
  //   }
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _refreshProvider = context.watch<FocusProvider>();

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
    } catch (e) {}
  }

  // @override
  // void dispose() {
  //   _pageController.dispose();
  //   _socketService.dispose();

  //   if (_timer.isActive) {
  //     _timer.cancel();
  //   }

  //   _buttonFocusNode.dispose();

  //   super.dispose();
  // }

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
              _pageController.jumpToPage(0);
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

  bool isYoutubeUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }

    url = url.toLowerCase().trim();

    bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url);
    if (isYoutubeId) {
      return true;
    }

    bool isYoutubeUrl = url.contains('youtube.com') ||
        url.contains('youtu.be') ||
        url.contains('youtube.com/shorts/');

    return isYoutubeUrl;
  }

  String formatUrl(String url, {Map<String, String>? params}) {
    if (url.isEmpty) {
      throw Exception("Empty URL provided");
    }

    return url;
  }

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

  // Future<void> fetchBanners({bool isBackgroundFetch = false}) async {
  //   if (!isBackgroundFetch) {
  //     setState(() {
  //       isLoading = true;
  //       errorMessage = '';
  //     });
  //   }

  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final cachedBanners = prefs.getString('banners');

  //     final List<dynamic> responseData = await fetchBannersData();

  //     for (int i = 0; i < responseData.length; i++) {
  //       final item = responseData[i];
  //     }

  //     if (cachedBanners != null) {
  //       try {
  //         final cachedData = json.decode(cachedBanners);
  //         if (json.encode(cachedData) == json.encode(responseData)) {
  //           return;
  //         }
  //       } catch (e) {}
  //     }

  //     List<NewsItemModel> filteredBanners = [];

  //     for (var banner in responseData) {
  //       try {
  //         bool isActive = false;

  //         if (banner['status'] != null) {
  //           var status = banner['status'];

  //           if (status is String) {
  //             isActive = status == "1" ||
  //                 status.toLowerCase() == "active" ||
  //                 status.toLowerCase() == "true";
  //           } else if (status is int) {
  //             isActive = status == 1;
  //           } else if (status is bool) {
  //             isActive = status;
  //           }
  //         } else {
  //           isActive = true;
  //         }

  //         if (isActive) {
  //           try {
  //             final newsItem = NewsItemModel.fromJson(banner);
  //             filteredBanners.add(newsItem);
  //           } catch (e) {}
  //         } else {}
  //       } catch (e) {}
  //     }

  //     setState(() {
  //       bannerList = filteredBanners;
  //       selectedContentId = bannerList.isNotEmpty ? bannerList[0].id : null;
  //       isLoading = false;
  //       errorMessage = '';
  //     });

  //     await prefs.setString('banners', json.encode(responseData));

  //     for (int i = 0; i < bannerList.length; i++) {
  //       final banner = bannerList[i];
  //     }

  //     if (bannerList.isNotEmpty) {
  //       await _fetchBannerColors();
  //       if (!_timer.isActive) {
  //         _startAutoSlide();
  //       }
  //     } else {}
  //   } catch (e) {
  //     if (!isBackgroundFetch) {
  //       setState(() {
  //         errorMessage = 'Failed to load banners: $e';
  //         isLoading = false;
  //       });
  //     }
  //   }
  // }

  // Future<void> _loadCachedData() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final cachedBanners = prefs.getString('banners');

  //   if (cachedBanners != null) {
  //     try {
  //       final List<dynamic> responseData = json.decode(cachedBanners);

  //       List<NewsItemModel> filteredBanners = [];

  //       for (var banner in responseData) {
  //         try {
  //           bool isActive = false;

  //           if (banner['status'] != null) {
  //             var status = banner['status'];

  //             if (status is String) {
  //               isActive = status == "1" ||
  //                   status.toLowerCase() == "active" ||
  //                   status.toLowerCase() == "true";
  //             } else if (status is int) {
  //               isActive = status == 1;
  //             } else if (status is bool) {
  //               isActive = status;
  //             }
  //           } else {
  //             isActive = true;
  //           }

  //           if (isActive) {
  //             try {
  //               final newsItem = NewsItemModel.fromJson(banner);
  //               filteredBanners.add(newsItem);
  //             } catch (e) {}
  //           }
  //         } catch (e) {}
  //       }

  //       setState(() {
  //         bannerList = filteredBanners;
  //         selectedContentId = bannerList.isNotEmpty ? bannerList[0].id : null;
  //         isLoading = false;
  //       });

  //       if (bannerList.isNotEmpty) {
  //         await _fetchBannerColors();
  //       }
  //     } catch (e) {
  //       setState(() => isLoading = false);
  //     }
  //   } else {
  //     setState(() => isLoading = false);
  //   }

  //   fetchBanners(isBackgroundFetch: true);
  // }

  Future<void> fetchAndPlayVideo(
      String contentId, List<NewsItemModel> channelList) async {
    if (_isNavigating) {
      return;
    }

    _isNavigating = true;

    bool shouldPlayVideo = true;
    bool shouldPop = true;

    try {
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

      final responseData = await fetchVideoDataByIdFromBanners(contentId);

      if (shouldPop && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (shouldPlayVideo && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoScreen(
              videoUrl: responseData['url'] ?? '',
              channelList: channelList,
              videoId: int.tryParse(contentId) ?? 0,
              videoType: responseData['type'] ?? '',
              isLive: true,
              isVOD: false,
              bannerImageUrl: responseData['banner'] ?? '',
              startAtPosition: Duration.zero,
              isBannerSlider: true,
              source: 'isBannerSlider',
              isSearch: false,
              unUpdatedUrl: responseData['url'] ?? '',
              name: responseData['name'] ?? '',
              liveStatus: true,
              seasonId: null,
              isLastPlayedStored: false,
            ),
          ),

          // builder: (context) => YouTubePlayerScreen(
          //   videoData: VideoData(
          //     id: contentId,
          //     title: responseData['name'] ?? '',
          //     youtubeUrl: responseData['url'] ?? '',
          //     thumbnail: responseData['banner'] ?? '',
          //   ),
          //   playlist: channelList
          //       .map((m) => VideoData(
          //             id: m.id,
          //             title: m.name,
          //             youtubeUrl: m.url,
          //             thumbnail: m.banner,
          //           ))
          //       .toList(),
          // ),
        );
      }
    } catch (e) {
      if (shouldPop && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

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

  void _scrollToFocusedItem(int index) {
    // Remove this method as it's not needed anymore
  }

  Uint8List _getCachedImage(String base64String) {
    try {
      if (!_bannerCache.containsKey(base64String)) {
        final base64Content = base64String.split(',').last;
        _bannerCache[base64String] = base64Decode(base64Content);
      }
      return _bannerCache[base64String]!;
    } catch (e) {
      return Uint8List.fromList([
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0x00,
        0x00,
        0x00,
        0x0D,
        0x49,
        0x48,
        0x44,
        0x52,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x01,
        0x08,
        0x02,
        0x00,
        0x00,
        0x00,
        0x90,
        0x77,
        0x53,
        0xDE,
        0x00,
        0x00,
        0x00,
        0x0C,
        0x49,
        0x44,
        0x41,
        0x54,
        0x78,
        0x01,
        0x63,
        0x00,
        0x01,
        0x00,
        0x05,
        0x00,
        0x01,
        0xE2,
        0x26,
        0x05,
        0x9B,
        0x00,
        0x00,
        0x00,
        0x00,
        0x49,
        0x45,
        0x4E,
        0x44,
        0xAE,
        0x42,
        0x60,
        0x82
      ]);
    }
  }

  bool isLiveVideoUrl(String url) {
    String lowerUrl = url.toLowerCase().trim();

    if (RegExp(r'^[a-zA-Z0-9_-]{10,15}$').hasMatch(lowerUrl)) {
      return false;
    }

    if (!lowerUrl.startsWith('http://') && !lowerUrl.startsWith('https://')) {
      return false;
    }

    if (lowerUrl.contains(".m3u8") ||
        lowerUrl.contains("live") ||
        lowerUrl.contains("stream") ||
        lowerUrl.contains("broadcast") ||
        lowerUrl.contains("playlist")) {
      return true;
    }

    List<String> videoExtensions = [".mp4", ".mov", ".avi", ".flv", ".mkv"];
    for (String ext in videoExtensions) {
      if (lowerUrl.endsWith(ext)) {
        return false;
      }
    }

    return false;
  }

  List<bool> checkLiveVideoList(List<String> urls) {
    return urls.map(isYoutubeUrl).toList();
  }

  String safeToString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey.shade800,
      child: Image.asset(localImage),
    );
  }

  bool get isSliderReady =>
      !isLoading && errorMessage.isEmpty && bannerList.isNotEmpty;

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
}

extension DurationExtension on Duration {
  String toHHMMSS() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = inHours > 0 ? '${twoDigits(inHours)}:' : '';
    String minutes = twoDigits(inMinutes.remainder(60));
    String seconds = twoDigits(inSeconds.remainder(60));
    return '$hours$minutes:$seconds';
  }
}

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

String formatAuthKey(String? key) {
  if (key == null || key.isEmpty) return '';

  key = key.trim();

  if (key.length < 10) {}

  return key;
}

Future<bool> checkEndpointHealth(String endpoint) async {
  try {
    final response =
        await https.head(Uri.parse(endpoint)).timeout(Duration(seconds: 5));
    return response.statusCode == 200 || response.statusCode == 405;
  } catch (e) {
    return false;
  }
}

Future<String> getBestApiEndpoint(List<String> endpoints) async {
  for (String endpoint in endpoints) {
    if (await checkEndpointHealth(endpoint)) {
      return endpoint;
    }
  }

  return endpoints.first;
}

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
